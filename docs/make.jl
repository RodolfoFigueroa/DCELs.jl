using DCELs
using Documenter

DocMeta.setdocmeta!(DCELs, :DocTestSetup, :(using DCELs); recursive=true)

makedocs(;
    modules=[DCELs],
    authors="Rodolfo Figueroa Soriano <4rodolfofigueroa2@gmail.com>",
    repo="https://github.com/RodolfoFigueroa/DCELs.jl/blob/{commit}{path}#{line}",
    sitename="DCELs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://RodolfoFigueroa.github.io/DCELs.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/RodolfoFigueroa/DCELs.jl",
    devbranch="main",
)
