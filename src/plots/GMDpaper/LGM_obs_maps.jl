# include("../../Nd_model/model_setup.jl")
# include("../load.jl") # this is the model-independent load.jl script
# include("../plots_setup_Nd.jl")
# include("../../Nd_model/LGM_obs.jl")

# mcol = [RGBA(c.r, c.g, c.b, 1.0) for c in ColorSchemes.okabe_ito[1:3]]
# mshp = [:dtriangle, :diamond, :hexagon]

surfacemask = horizontalslice(ones(count(iswet(grd))), grd, depth=0)
function plot_obs_maps!(fig)
    # plot of [Nd]
    # axs = Array{Any,2}(undef, (2, 1))
    axs[1,1] = fig[1,1] = Axis(fig, backgroundcolor=seafloor_color)
    ax = axs[1,1]
    scts = Vector{Any}(undef, 3) # to store scatter marker for legend
    # mapit!(ax, clon, mypolys(clon), color=continent_color)
    sources = ["Du et al 2020"] # Du et al 
    # for (i,source) in enumerate(sources)
    #     df = select(DNdobs, [:lat, :lon])[DNdobs.source .== source,:] 
    #     scts[i] = myscatter!(ax, centerlon.(df.lon), df.lat; marker=mshp[i], color=mcol[i], strokewidth=1, markersize)
    # end
    # mapit!(ax, clon, mypolys(clon), color=:transparent, strokewidth=1, strokecolor=:black)
    # mylatlons!(ax, latticks45, lonticks60)
    # hidexdecorations!(ax, ticks=false, grid=false)

    # plot εNd of source
    # axs[2,1] = fig[2,1] = Axis(fig, backgroundcolor=seafloor_color)
    # ax = axs[2,1]
    mapit!(ax, clon, mypolys(clon), color=continent_color)
    # for (i,source) in enumerate(sources)
    # df = select(LGM_εNdobs, [:lat, :lon])[LGM_εNdobs.source .== sources,:] 
    # myscatter!(ax, centerlon.((LGM_εNdobs.lon), LGM_εNdobs.lat))
    # end
    df = select(v, [:lat, :lon])[v.source .== sources,:] 
    myscatter!(ax, centerlon.((v.lon), v.lat))
    mapit!(ax, clon, mypolys(clon), color=:transparent, strokewidth=1, strokecolor=:black)
    mylatlons!(ax, latticks45, lonticks60)
    # annotations (must come after?)
    # text!(axs[1,1], 0, 0, text=string("(a)"), fontsize=20, align=(:left,:bottom), space=:relative, offset=(4,4), font="Dejavu Sans", color=:white)
    # text!(axs[2,1], 0, 0, text=string("(b)"), fontsize=20, align=(:left,:bottom), space=:relative, offset=(4,4), font="Dejavu Sans", color=:white)
    # # text!(axs[1,1], 60, 45, text="Nd obs", fontsize=20, align=(:left,:bottom), font="Dejavu Sans", color=:white)
    # text!(axs[2,1], 60, 45, text="εNd obs", fontsize=20, align=(:left,:bottom), font="Dejavu Sans", color=:white)
    # nothing

    # Legend
    # markers = [MarkerElement(; marker, color, markersize=15, strokewidth=1) for (marker,color) in zip(mshp, mcol)]
    # leg = Legend(fig, markers, sources)
    # leg.orientation = :horizontal
    # leg.tellheight = true
    # fig[3,1] = leg
end
fig = Figure(resolution = (650, 700), backgroundcolor=:white)
plot_obs_maps!(fig)
trim!(fig.layout)
if use_GLMakie
    display(fig) # show the output wiht GLMakie
else
    save(joinpath(archive_path, "LGM_obs_maps.pdf"), fig)
    nothing # just so that no output is spat out
end
