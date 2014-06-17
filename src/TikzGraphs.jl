module TikzGraphs

export plot, LayeredLayout, SpringLayout

using TikzPictures
using Graphs

type LayeredLayout
end

type SpringLayout
  randomSeed
  SpringLayout(;randomSeed=0) = new(randomSeed)
end

function plot(g::GenericGraph)
  return plot(g, LayeredLayout())
end

function plotHelper(g::GenericGraph, libraryname::String, layoutname::String, options::String = "")
  preamble = "\\usetikzlibrary{graphs}\n"
  preamble *= "\\usetikzlibrary{graphdrawing}\n"
  preamble *= "\\usegdlibrary{$libraryname}\n"
  data = "\\graph [$layoutname, $options] {\n"
  for e in edges(g)
    a = source(e, g)
    b = target(e, g)
    data *= "$a -> $b;\n"
  end
  data *= "};\n"
  TikzPicture(data, preamble=preamble)
end

function plot(g::GenericGraph, p::LayeredLayout)
  plotHelper(g, "layered", "layered layout")
end

function plot(g::GenericGraph, p::SpringLayout)
  options = "random seed = $(p.randomSeed)"
  plotHelper(g, "force", "spring layout", options)
end

end # module
