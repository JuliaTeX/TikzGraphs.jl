module TikzGraphs

export plot, Layouts

preamble = readall(joinpath(dirname(@__FILE__), "..", "src", "preamble.tex"))

using TikzPictures
using Graphs
using LightGraphs
using Compat

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
plot{T<:AbstractString}(g::GenericGraph, labels::Vector{T}) = plot(g, Layered(), labels)

function plotHelper(g::GenericGraph, libraryname::AbstractString, layoutname::AbstractString, options::AbstractString)
  o = IOBuffer()
  println(o, "\\graph [$layoutname, $options] {")
  for e in Graphs.edges(g)
    a = source(e, g)
    b = target(e, g)
    println(o, "$a -> $b;")
  end
  # include isolated nodes
  for v in Graphs.vertices(g)
    if in_degree(v, g) == 0 && out_degree(v, g) == 0
      println(o, "$v;")
    end
  end
  println(o, "};")
  mypreamble = preamble * "\n\\usegdlibrary{$libraryname}"
  TikzPicture(takebuf_string(o), preamble=mypreamble)
end

function plotHelper{T<:AbstractString}(g::GenericGraph, libraryname::AbstractString, layoutname::AbstractString, options::AbstractString, labels::Vector{T})
  o = IOBuffer()
  println(o, "\\graph [$layoutname, $options] {")
  for e in Graphs.edges(g)
    a = source(e, g)
    b = target(e, g)
    println(o, "\"$(labels[a])\" -> \"$(labels[b])\";")
  end
  # include isolated nodes
  for v in Graphs.vertices(g)
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

function plot{T<:AbstractString}(g::GenericGraph, p::Layered, labels::Vector{T})
  plotHelper(g, "layered", "layered layout", "", labels)
end

function plot{T<:AbstractString}(g::GenericGraph, p::Spring, labels::Vector{T})
  options = "random seed = $(p.randomSeed)"
  plotHelper(g, "force", "spring layout", options, labels)
end

###################################
####### LightGraphs support #######
###################################
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
  for e in LightGraphs.edges(g)
    a = src(e)
    b = dst(e)
    println(o, "\"$(labels[a])\" -> \"$(labels[b])\";")
  end
  # include isolated nodes
  for v in LightGraphs.vertices(g)
    if indegree(g, v) == 0 && outdegree(g, v) == 0
      println(o, "\"$(labels[v])\";")
    end
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

function plot{T<:AbstractString}(g::LightGraphs.SimpleGraph, p::Layered, labels::Vector{T})
  plotHelper(g, "layered", "layered layout", "", labels)
end

function plot{T<:AbstractString}(g::LightGraphs.SimpleGraph, p::Spring, labels::Vector{T})
  options = "random seed = $(p.randomSeed)"
  plotHelper(g, "force", "spring layout", options, labels)
end

end # module
