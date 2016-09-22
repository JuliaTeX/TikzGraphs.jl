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

plot(g::LightGraphs.SimpleGraph) = plot(g, Layered())
plot{T<:AbstractString}(g::LightGraphs.SimpleGraph, labels::Vector{T}) = plot(g, Layered(), labels)

function plotHelper(g::LightGraphs.SimpleGraph, libraryname::AbstractString, layoutname::AbstractString, options::AbstractString)
  o = IOBuffer()
  println(o, "\\graph [$layoutname, $options] {")
  for e in LightGraphs.edges(g)
    a = src(e)
    b = dst(e)
    println(o, "$a -> $b;")
  end
  # include isolated nodes
  for v in LightGraphs.vertices(g)
    if indegree(g, v) == 0 && outdegree(g, v) == 0
      println(o, "$v;")
    end
  end
  println(o, "};")
  mypreamble = preamble * "\n\\usegdlibrary{$libraryname}"
  TikzPicture(takebuf_string(o), preamble=mypreamble)
end

function plotHelper{T<:AbstractString}(g::LightGraphs.SimpleGraph, libraryname::AbstractString, layoutname::AbstractString, options::AbstractString, labels::Vector{T})
  o = IOBuffer()
  println(o, "\\graph [$layoutname, $options] {")
  for v in LightGraphs.vertices(g)
    println(o, "$v/\"$(labels[v])\",")
  end
  println(o, ";")
  for e in LightGraphs.edges(g)
    a = src(e)
    b = dst(e)
    println(o, "$a -> $b;")
  end
  println(o, "};")
  mypreamble = preamble * "\n\\usegdlibrary{$libraryname}"
  TikzPicture(takebuf_string(o), preamble=mypreamble)
end

function plot(g::LightGraphs.SimpleGraph, p::Layered)
  plotHelper(g, "layered", "layered layout", "")
end

function plot(g::LightGraphs.SimpleGraph, p::Spring)
  options = "random seed = $(p.randomSeed)"
  plotHelper(g, "force", "spring layout", options)
end

function plot(g::LightGraphs.SimpleGraph, p::SimpleNecklace)
  plotHelper(g, "circular", "simple necklace layout", "")
end

function plot{T<:AbstractString}(g::LightGraphs.SimpleGraph, p::Layered, labels::Vector{T})
  plotHelper(g, "layered", "layered layout", "", labels)
end

function plot{T<:AbstractString}(g::LightGraphs.SimpleGraph, p::Spring, labels::Vector{T})
  options = "random seed = $(p.randomSeed)"
  plotHelper(g, "force", "spring layout", options, labels)
end

function plot{T<:AbstractString}(g::LightGraphs.SimpleGraph, p::SimpleNecklace, labels::Vector{T})
  plotHelper(g, "circular", "simple necklace layout", "", labels)
end

end # module
