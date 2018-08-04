using TikzGraphs
using Test

@assert success(`lualatex -v`)
using NBInclude
nbinclude(joinpath(dirname(@__FILE__), "..", "doc", "TikzGraphs.ipynb"))
