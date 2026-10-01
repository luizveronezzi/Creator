namespace GeradorCodigo.Application.Interfaces;

/// <summary>
/// Porta para renderização de templates. A implementação carrega os arquivos de
/// template do disco e substitui placeholders e blocos de repetição.
/// </summary>
public interface ITemplateEngine
{
    string Render(string templateName, object model);
}
