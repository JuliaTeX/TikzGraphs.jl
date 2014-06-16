module TikzGraphs

export plot

using TikzPictures
using Graphs

type LayeredLayout
end

type SpringLayout
end

function plot(g::GenericGraph)
  return plot(g, LayeredLayout())
end

function plotHelper(g::GenericGraph, libraryname::String, layoutname::String)
  preamble = "\\usetikzlibrary{graphs}\n"
  preamble *= "\\usetikzlibrary{graphdrawing}\n"
  preamble *= "\\usegdlibrary{$libraryname}\n"
  data = "\\graph [$layoutname] {\n"
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
  plotHelper(g, "force", "spring layout")
end

end # module
