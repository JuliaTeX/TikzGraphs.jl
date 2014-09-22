module TikzGraphs

export plot, Layouts

preamble = readall(joinpath(Pkg.dir("TikzGraphs"), "src", "preamble.tex"))

using TikzPictures
using Graphs

module Layouts

export Layered, Spring

abstract Layout

type Layered <: Layout
end

type Spring <: Layout
  randomSeed
  Spring(;randomSeed=0) = new(randomSeed)
end

end

using .Layouts

plot(g::GenericGraph) = plot(g, Layered())
plot(g::GenericGraph, labels::Vector{String}) = plot(g, Layered(), labels)

function plotHelper(g::GenericGraph, libraryname::String, layoutname::String, options::String)
  o = IOBuffer()
  println(o, "\\graph [$layoutname, $options] {")
  for e in edges(g)
    a = source(e, g)
    b = target(e, g)
    println(o, "$a -> $b;")
  end
  # include isolated nodes
  for v in vertices(g)
    if in_degree(v, g) == 0 && out_degree(v, g) == 0
      println(o, "$v;")
    end
  end
  println(o, "};")
  mypreamble = preamble * "\n\\usegdlibrary{$libraryname}"
  TikzPicture(takebuf_string(o), preamble=mypreamble)
end

function plotHelper{T<:String}(g::GenericGraph, libraryname::String, layoutname::String, options::String, labels::Vector{T})
  o = IOBuffer()
  println(o, "\\graph [$layoutname, $options] {")
  for e in edges(g)
    a = source(e, g)
    b = target(e, g)
    println(o, "\"$(labels[a])\" -> \"$(labels[b])\";")
  end
  # include isolated nodes
  for v in vertices(g)
    if in_degree(v, g) == 0 && out_degree(v, g) == 0
      println(o, "\"$(labels[v])\";")
    end
  end
  println(o, "};")
  mypreamble = preamble * "\n\\usegdlibrary{$libraryname}"
  TikzPicture(takebuf_string(o), preamble=mypreamble)
end

function plot(g::GenericGraph, p::Layered)
  plotHelper(g, "layered", "layered layout", "")
end

function plot(g::GenericGraph, p::Spring)
  options = "random seed = $(p.randomSeed)"
  plotHelper(g, "force", "spring layout", options)
end

function plot(g::GenericGraph, p::Layered, labels::Vector{String})
  plotHelper(g, "layered", "layered layout", "", labels)
end

function plot(g::GenericGraph, p::Spring, labels::Vector{String})
  options = "random seed = $(p.randomSeed)"
  plotHelper(g, "force", "spring layout", options, labels)
end

end # module
