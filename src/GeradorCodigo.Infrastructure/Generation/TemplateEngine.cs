using System.Collections;
using System.Text.RegularExpressions;
using GeradorCodigo.Application.Interfaces;

namespace GeradorCodigo.Infrastructure.Generation;

/// <summary>
/// Engine de templates com sintaxe:
///   [[Propriedade]]                          → valor (também [[a.b]] e [[.]] para o item atual)
///   [[#each Colecao]] ... [[/each]]          → repetição (suporta aninhamento)
///   [[#if Valor]] ... [[else]] ... [[/if]]   → condicional (suporta aninhamento)
/// O delimitador [[ ]] evita colisão com interpolações do Angular ({{ }}).
/// </summary>
public sealed partial class TemplateEngine : ITemplateEngine
{
    private readonly string _templatesDirectory;
    private readonly Dictionary<string, string> _cache = new(StringComparer.OrdinalIgnoreCase);

    public TemplateEngine(string templatesDirectory)
    {
        _templatesDirectory = templatesDirectory;
    }

    public string Render(string templateName, object model)
    {
        return RenderBlock(LoadTemplate(templateName), [model]);
    }

    private string RenderBlock(string text, IReadOnlyList<object> contextStack)
    {
        var output = new System.Text.StringBuilder();
        var index = 0;

        while (index < text.Length)
        {
            var open = text.IndexOf("[[", index, StringComparison.Ordinal);
            if (open < 0)
            {
                output.Append(text, index, text.Length - index);
                break;
            }

            output.Append(text, index, open - index);
            var tag = OpenTagRegex().Match(text, open);

            if (!tag.Success || tag.Index != open)
            {
                // '[' literal imediatamente antes de uma tag (ex.: '[' de um array em
                // '= [[[#each ...]]'): emite o '[' e reprocessa a partir dele.
                if (tag.Success && tag.Index == open + 1 && text[open] == '[')
                {
                    output.Append('[');
                    index = open + 1;
                    continue;
                }

                // [[literal]] sem tag estruturada: resolve como placeholder simples.
                var placeholder = PlaceholderRegex().Match(text, open);
                if (placeholder.Success && placeholder.Index == open)
                {
                    output.Append(Format(Resolve(placeholder.Groups[1].Value, contextStack)));
                    index = placeholder.Length + open;
                    continue;
                }

                if (placeholder.Success && placeholder.Index == open + 1 && text[open] == '[')
                {
                    output.Append('[');
                    index = open + 1;
                    continue;
                }

                output.Append("[[");
                index = open + 2;
                continue;
            }

            var kind = tag.Groups[1].Value;
            var path = tag.Groups[2].Value;
            var bodyEnd = FindClosingTag(text, tag.Index + tag.Length, kind);
            var body = text[(tag.Index + tag.Length)..bodyEnd.StartIndex];

            if (kind == "each")
            {
                var collection = Resolve(path, contextStack);
                if (collection is not string && collection is IEnumerable enumerable)
                {
                    foreach (var item in enumerable)
                    {
                        var inner = new List<object>(contextStack);
                        if (item is not null)
                        {
                            inner.Insert(0, item);
                        }

                        output.Append(RenderBlock(body, inner));
                    }
                }
            }
            else
            {
                var (condition, elseBody) = SplitElse(body);
                var branch = IsTruthy(Resolve(path, contextStack)) ? condition : elseBody;
                output.Append(RenderBlock(branch, contextStack));
            }

            index = bodyEnd.EndIndex;
        }

        return output.ToString();
    }

    private static (int StartIndex, int EndIndex) FindClosingTag(string text, int from, string kind)
    {
        var depth = 1;
        var scan = from;

        while (scan < text.Length)
        {
            var nextOpen = OpenTagRegex().Match(text, scan);
            var closeTag = CloseTagRegex().Match(text, scan);

            if (closeTag.Success && (!nextOpen.Success || closeTag.Index < nextOpen.Index))
            {
                depth--;
                if (depth == 0)
                {
                    return (closeTag.Index, closeTag.Index + closeTag.Length);
                }

                scan = closeTag.Index + closeTag.Length;
                continue;
            }

            if (nextOpen.Success)
            {
                depth++;
                scan = nextOpen.Index + nextOpen.Length;
                continue;
            }

            break;
        }

        throw new FormatError($"Bloco [[#{kind}]] sem fechamento no template.");
    }

    private static (string Condition, string ElseBody) SplitElse(string body)
    {
        var depth = 0;
        var scan = 0;

        while (scan < body.Length)
        {
            var nextOpen = OpenTagRegex().Match(body, scan);
            var closeTag = CloseTagRegex().Match(body, scan);
            var elseTag = ElseTagRegex().Match(body, scan);

            if (elseTag.Success && depth == 0
                && (!nextOpen.Success || elseTag.Index < nextOpen.Index)
                && (!closeTag.Success || elseTag.Index < closeTag.Index))
            {
                return (body[..elseTag.Index], body[(elseTag.Index + elseTag.Length)..]);
            }

            if (closeTag.Success && (!nextOpen.Success || closeTag.Index < nextOpen.Index))
            {
                depth = Math.Max(0, depth - 1);
                scan = closeTag.Index + closeTag.Length;
                continue;
            }

            if (nextOpen.Success)
            {
                depth++;
                scan = nextOpen.Index + nextOpen.Length;
                continue;
            }

            break;
        }

        return (body, string.Empty);
    }

    private object? Resolve(string path, IReadOnlyList<object> contextStack)
    {
        if (path is "." or "$this")
        {
            return contextStack.Count > 0 ? contextStack[0] : null;
        }

        foreach (var context in contextStack)
        {
            var value = ResolveFrom(context, path);
            if (value is not null)
            {
                return value;
            }
        }

        return null;
    }

    private static object? ResolveFrom(object target, string path)
    {
        object? current = target;

        foreach (var segment in path.Split('.'))
        {
            if (current is null)
            {
                return null;
            }

            if (current is IDictionary<string, object?> dictionary)
            {
                if (!dictionary.TryGetValue(segment, out current))
                {
                    return null;
                }

                continue;
            }

            if (current is string text && segment == "Length")
            {
                current = text.Length;
                continue;
            }

            var property = current.GetType().GetProperty(
                segment, System.Reflection.BindingFlags.Public
                       | System.Reflection.BindingFlags.Instance
                       | System.Reflection.BindingFlags.IgnoreCase);

            if (property is null)
            {
                return null;
            }

            current = property.GetValue(current);
        }

        return current;
    }

    private static bool IsTruthy(object? value) => value switch
    {
        null => false,
        bool boolean => boolean,
        string text => text.Length > 0,
        int number => number != 0,
        IEnumerable enumerable => enumerable.Cast<object?>().Any(item => item is not null),
        _ => true,
    };

    private static string Format(object? value) => value switch
    {
        null => string.Empty,
        bool boolean => boolean ? "true" : "false",
        _ => value.ToString() ?? string.Empty,
    };

    private string LoadTemplate(string templateName)
    {
        lock (_cache)
        {
            if (_cache.TryGetValue(templateName, out var cached))
            {
                return cached;
            }
        }

        var path = Path.Combine(
            _templatesDirectory,
            templateName.Replace('/', Path.DirectorySeparatorChar) + ".tpl");

        if (!File.Exists(path))
        {
            throw new FileNotFoundException($"Template não encontrado: {templateName} ({path})");
        }

        var content = File.ReadAllText(path);
        lock (_cache)
        {
            _cache[templateName] = content;
        }

        return content;
    }

    [GeneratedRegex(@"\[\[#(each|if) ([A-Za-z0-9_.]+)\]\]")]
    private static partial Regex OpenTagRegex();

    [GeneratedRegex(@"\[\[/(each|if)\]\]")]
    private static partial Regex CloseTagRegex();

    [GeneratedRegex(@"\[\[else\]\]")]
    private static partial Regex ElseTagRegex();

    [GeneratedRegex(@"\[\[([A-Za-z0-9_.]+)\]\]")]
    private static partial Regex PlaceholderRegex();

    private sealed class FormatError(string message) : FormatException(message);
}
