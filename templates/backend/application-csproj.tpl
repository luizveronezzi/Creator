<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <RootNamespace>[[NamespaceRoot]].Application</RootNamespace>
    <AssemblyName>[[ProjectPrefix]].Application</AssemblyName>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="FluentValidation" Version="12.1.1" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\[[ProjectPrefix]].Domain\[[ProjectPrefix]].Domain.csproj" />
  </ItemGroup>

</Project>
