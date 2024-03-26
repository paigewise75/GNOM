# Load model functions and all
use_GLMakie = false
#================================================
Loading input and output data for plots
================================================#
plot_path = joinpath(root_path, "src", "plots")
# Reloading some packages in case the optimization was already ru
using AIBECS
using JLD2
using GEOTRACES
using Statistics
using OceanBasins
using OceanographyCruises
using DataFrames
using Distributions
using DataDeps
using DataStructures
using Interpolations
using Dates
using Colors
using ColorSchemes
using ColorSchemeTools
using KernelDensity
using GeometryBasics
using Inpaintings
using Shapefile
using RemoteFiles
using Unitful
using PlotUtils
using NCDatasets
using XLSX
using Formatting
using NearestNeighbors
# Chose the plotting backend (CairoMakie for PDFs, GLMakie for "live" windows)
if use_GLMakie
    using GLMakie; GLMakie.activate!()
    # GLMakie.WINDOW_CONFIG.vsync[] = false
else
    using CairoMakie; CairoMakie.activate!()
end
BACKEND = use_GLMakie ? GLMakie : CairoMakie

if isdefined(Main, :newrun)
    if newrun == "Sed Flux/Bottom Up"
        file_name = "optimized_output_fe47ba4f_run19_OCIM2.jld2" # Bottom Up 
    elseif newrun == "Best Run"
        file_name = "optimized_output_767c7e31_run7_OCIM2.jld2" # Best Run
    elseif newrun == "Omit Sources/No Dust"
        file_name = "optimized_output_11df75c6_run3_OCIM2.jld2" # No Dust 
    elseif newrun == "Omit Sources/No Rivers"
        file_name = "optimized_output_11df75c6_run2_OCIM2.jld2" # No Rivers
    elseif newrun == "Omit Sources/No Sed"
        file_name = "optimized_output_11df75c6_run1_OCIM2.jld2" # No Sed
    elseif newrun== "Reactivity Parameter/Horizontal sed flux"
        file_name = "optimized_output_fe47ba4f_run21_OCIM2.jld2" # Reactivity Parameter
    elseif newrun== "Sed Flux/Shallow Sed Only"
        file_name = "optimized_output_fe47ba4f_run2_OCIM2.jld2" # Shallow Sed Only
    else 
        print("Check file path!")
    end
    archive_path = joinpath(output_path,"archive", "GNOMv2",newrun)
    file_path = joinpath(archive_path, file_name)
    DNd, εNd, εNdobs, DNdobs, s_optimized, tp_opt = jldopen(file_path) do f
        f["DNd"], f["εNd"], f["εNdobs"], f["DNdobs"], f["s_optimized"], f["tp_opt"]
    end
    # Remake optimized parameters (note the parameters must exist in the current commit otherwise you're in trouble)
    p = Params(; zip(tp_opt.Symbol,tp_opt.Value)...)
    run_num = 1
    lastcommit = newrun
# if isdefined(Main, :lastcommit) && lastcommit == "single"
#     include("../Nd_model/obs.jl") # creates DNdobs and εNdobs
    # All the other variables should be the output of single_run.jl
else
    # Path for loading data and saving figures
    using LibGit2
    # Note that this archive path is built differently from the model setup:
    # When running the model, I use the head commit, but when plotting,
    # I use the last commit with a saved model run.
    archive_path, lastcommit = let
        allarchives_path = joinpath(output_path, "archive")
        # if ARGS is pro rvided it should contain the commit's first 8 characters
        # lastcommit = get(ARGS, 1, splitpath(first(sort(map(f -> (joinpath(allarchives_path, f), Dates.unix2datetime(mtime(f))), filter(isdir, readdir(allarchives_path, join=true))), by=last, rev=true))[1])[end])
        # lastcommit = "daec0095"
        # lastcommit = "767c7e31"
        # lastcommit = "11df75c6"
        # lastcommit = "036aae4c"
        # lastcommit = "e77fe068"
        @show lastcommit
        # archive_path = joinpath(output_path, "archive", lastcommit)
        archive_path = joinpath(output_path, "archive", "GNOMv2","Reactivity Parameter","Alpha = 1")
        archive_path, lastcommit
    end
    # DNd, εNd, εNdobs, DNdobs, s_optimized, tp_opt = jldopen(joinpath(archive_path, "optimized_output_daec0095_run1_OCIM2.jld2")) do f
    DNd, εNd, εNdobs, DNdobs, s_optimized, tp_opt = jldopen(file_path) do f
        f["DNd"], f["εNd"], f["εNdobs"], f["DNdobs"], f["s_optimized"], f["tp_opt"]
    end
    # Remake optimized parameters (note the parameters must exist in the current commit otherwise you're in trouble)
    p = Params(; zip(tp_opt.Symbol,tp_opt.Value)...)
end


iwet = findall(vec(iswet(grd)))
ρSW = 1.035u"kg/L" # approximate mean sea water density to convert mol/kg to mol/m^3
OCEANS = oceanpolygons()

#mkpath(output_path)
#mkpath(archive_path)
BG = :white
EXT = :png


fig_path = output_path
# convert model and obs to match units
DNdmodel = uconvert.(uDNd, DNd * upreferred(uDNd))
εNdmodel = uconvert.(uεNd, εNd * upreferred(uεNd))
# TODO maybe use `Transects` to convert `obs` directly
# instead of reloading through GEOTRACES
# and having to reconvert the obs
using OceanographyCruises
Nd_transects = uconvert(uDNd, GEOTRACES.transects("Nd") * ρSW)
εNd_transects = uconvert(uεNd, GEOTRACES.transects("εNd"))

# Load shapefile for land
#using GeoDatasets
#landlon, landlat, landdata = GeoDatasets.landseamask(;resolution='l', grid=5)
#segments = GeoDatasets.gshhg('c', [1,6])

reload = true

