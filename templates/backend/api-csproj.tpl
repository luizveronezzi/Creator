<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <RootNamespace>[[NamespaceRoot]].Api</RootNamespace>
    <AssemblyName>[[ProjectPrefix]].Api</AssemblyName>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="HotChocolate.AspNetCore" Version="16.6.6" />
    <PackageReference Include="Swashbuckle.AspNetCore" Version="10.2.3" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\[[ProjectPrefix]].Application\[[ProjectPrefix]].Application.csproj" />
    <ProjectReference Include="..\[[ProjectPrefix]].Infrastructure\[[ProjectPrefix]].Infrastructure.csproj" />
  </ItemGroup>

</Project>
