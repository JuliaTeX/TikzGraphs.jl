__precompile__()

module TikzGraphs

export plot, Layouts
import LightGraphs: DiGraph, Graph, vertices, edges, src, dst

preamble = read(joinpath(dirname(@__FILE__), "..", "src", "preamble.tex"), String)

const AbstractGraph = Union{Graph, DiGraph}

using TikzPictures

module Layouts
    export Layered, Spring, SimpleNecklace

    abstract type Layout end

    struct Layered <: Layout end

    struct Spring <: Layout
        randomSeed
        Spring(;randomSeed=42) = new(randomSeed)
    end

    struct SimpleNecklace <: Layout
    end
end

using .Layouts

plot(g, layout::Layouts.Layout, labels::Vector{T}=map(string, vertices(g)); args...) where {T<:AbstractString} = plot(g; layout=layout, labels=labels, args...)
plot(g, labels::Vector{T}; args...) where {T<:AbstractString} = plot(g; layout=Layered(), labels=labels, args...)

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
edge_str(g::DiGraph) = "->"
edge_str(g::Graph) = "--"

function plot(g::AbstractGraph; layout::Layouts.Layout = Layered(), labels::Vector{T}=map(string, vertices(g)), edge_labels::Dict = Dict(), node_styles::Dict = Dict(), node_style="", edge_styles::Dict = Dict(), edge_style="", options="") where T<:AbstractString
    o = IOBuffer()
    println(o, "\\graph [$(layoutname(layout)), $(options_str(layout))] {")
    for v in vertices(g)
        nodeHelper(o, v, labels, node_styles, node_style)
    end
    println(o, ";")
    for e in edges(g)
        a = src(e)
        b = dst(e)
        print(o, "$a $(edge_str(g))")
        edgeHelper(o, a, b, edge_labels, edge_styles, edge_style)
        println(o, "$b;")
    end
    println(o, "};")
    mypreamble = preamble * "\n\\usegdlibrary{$(libraryname(layout))}"
    TikzPicture(String(take!(o)), preamble=mypreamble, options=options)
end

for (_layout, _libraryname, _layoutname) in [
    (:Layered, "layered", "layered layout"),
    (:Spring, "force", "spring layout"),
    (:SimpleNecklace, "circular", "simple necklace layout")
    ]
    @eval libraryname(p::$(_layout)) = $_libraryname
    @eval layoutname(p::$(_layout)) = $_layoutname
end

options_str(p::Layouts.Layout) = ""
options_str(p::Spring) = "random seed = $(p.randomSeed)"

end # module
