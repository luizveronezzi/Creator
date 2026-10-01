<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <RootNamespace>[[NamespaceRoot]].Infrastructure</RootNamespace>
    <AssemblyName>[[ProjectPrefix]].Infrastructure</AssemblyName>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.EntityFrameworkCore" Version="9.0.20" />
    <PackageReference Include="Pomelo.EntityFrameworkCore.MySql" Version="9.0.0" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\[[ProjectPrefix]].Application\[[ProjectPrefix]].Application.csproj" />
    <ProjectReference Include="..\[[ProjectPrefix]].Domain\[[ProjectPrefix]].Domain.csproj" />
  </ItemGroup>

</Project>
