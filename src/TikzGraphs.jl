module TikzGraphs

export plot, Layouts

using Compat

preamble = readstring(joinpath(dirname(@__FILE__), "..", "src", "preamble.tex"))

using TikzPictures
using LightGraphs
using Compat

module Layouts

export Layered, Spring, SimpleNecklace

abstract Layout

type Layered <: Layout
end

type Spring <: Layout
    randomSeed
    Spring(;randomSeed=42) = new(randomSeed)
end

type SimpleNecklace <: Layout
end

end

using .Layouts

plot{T<:AbstractString}(g::LightGraphs.SimpleGraph, layout::Layouts.Layout, labels::Vector{T}=map(string, vertices(g)); args...) = plot(g; layout=layout, labels=labels, args...)
plot{T<:AbstractString}(g::LightGraphs.SimpleGraph, labels::Vector{T}; args...) = plot(g; layout=Layered(), labels=labels, args...)

function edgeHelper(o::IOBuffer, a, b, edge_labels, edge_styles, edge_style)
    print(o, " [$(edge_style),")
    if haskey(edge_labels, (a,b))
        print(o, "edge label={$(edge_labels[(a,b)])},")
    end
    if haskey(edge_styles, (a,b))
        print(o, "$(edge_styles[(a,b)]),")
    end
    print(o, "] ")
end

function nodeHelper(o::IOBuffer, v, labels, node_styles, node_style)
    print(o, "$v/\"$(labels[v])\" [$(node_style)")
    if haskey(node_styles, v)
        print(o, ",$(node_styles[v])")
    end
    println(o, "],")
end

# helper function for edge type
edge_str(g::LightGraphs.DiGraph) = "->"
edge_str(g::LightGraphs.Graph) = "--"

function plot{T<:AbstractString}(g::LightGraphs.SimpleGraph; layout::Layouts.Layout = Layered(), labels::Vector{T}=map(string, vertices(g)), edge_labels::Dict = Dict(), node_styles::Dict = Dict(), node_style="", edge_styles::Dict = Dict(), edge_style="")
    o = IOBuffer()
    println(o, "\\graph [$(layoutname(layout)), $(options(layout))] {")
    for v in LightGraphs.vertices(g)
        nodeHelper(o, v, labels, node_styles, node_style)
    end
    println(o, ";")
    for e in LightGraphs.edges(g)
        a = src(e)
        b = dst(e)
        print(o, "$a $(edge_str(g))")
        edgeHelper(o, a, b, edge_labels, edge_styles, edge_style)
        println(o, "$b;")
    end
    println(o, "};")
    mypreamble = preamble * "\n\\usegdlibrary{$(libraryname(layout))}"
    TikzPicture(takebuf_string(o), preamble=mypreamble)
end

for (_layout, _libraryname, _layoutname) in [
    (:Layered, "layered", "layered layout"),
    (:Spring, "force", "spring layout"),
    (:SimpleNecklace, "circular", "simple necklace layout")
    ]
    @eval libraryname(p::$(_layout)) = $_libraryname
    @eval layoutname(p::$(_layout)) = $_layoutname
end

options(p::Layouts.Layout) = ""
options(p::Spring) = "random seed = $(p.randomSeed)"

end # module
