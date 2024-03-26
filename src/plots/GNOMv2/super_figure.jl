include("../plots_setup_Nd.jl")

# 1. Atlantic and Pacific [Nd] and εNd
# 2. RMSE vertical
# 3. sed flux vs depth
# 4. integrated sources
# 5. diagnsotic table



# Create the figure
fig = Figure(resolution=(2000, 1800))
label_opts = (fontsize=20, align=(:left,:bottom), offset=(4,4), space=:relative, font=labelfont, color=:black)

# 1. 
isbasins = [isatlantic2, ispacific2]
basins = ["ATL", "PAC"]
basin_longnames = ["Atlantic", "Pacific"]
colors = PlotUtils.cgrad([:blue, :red])
model_thickness = 2.5
obs_thickness = 1
# Function to average data
# that groups model and obs. by OCIM depths
function basin_profile_mean_and_std(isbasin, xmodel::Vector{T}, xmodelatobs, xdepthatobs, xobs, xwetobs, iobswet) where T
    ibasin = findall(isbasin(xobs.lat[iobswet], xobs.lon[iobswet], OCEANS))
    xmodelmean = T[]
    xmodelerror = T[]
    xobsmean = T[]
    xobserror = T[]
    depths = eltype(grd.depth)[]
    for (iz,z) in enumerate(grd.depth)
        idepth = findall(xdepthatobs[ibasin] .== ustrip(z))
        if !isempty(idepth)
            xmodel_atz = xmodelatobs[ibasin][idepth]
            xobs_atz = xwetobs[ibasin][idepth]
            push!(xmodelmean, mean(xmodel_atz))
            push!(xmodelerror, std(xmodel_atz, corrected=false))
            push!(xobsmean, mean(xobs_atz))
            push!(xobserror, std(xobs_atz, corrected=false))
            push!(depths, z)
        end
    end
    return ustrip.(xmodelmean), ustrip.(xmodelerror), ustrip.(xobsmean), ustrip.(xobserror), ustrip.(depths)
end
# Function for whole plot
function plot_profiles_v2!(fig)
    label_pos = reshape([ "a", "d", "b", "e"],(2,2))
    axs = Array{Any}(undef, (2, 2))
    for (itracer, (xmodel, xobs, ux)) in enumerate(zip((DNdmodel, εNdmodel), (DNdobs, εNdobs), (uDNd, uεNd)))
        xmodelatobs, xdepthatobs, iobswet, xwetobs = _locations(xmodel, xobs, ux)
        for (ibasin, isbasin) in enumerate(isbasins)
            ax = axs[itracer, ibasin] = fig[itracer, ibasin] = Axis(fig, xaxisposition = :top, xticklabelalign = (:center, :bottom))#, title = titles[itracer])
            xmodelmean, xmodelerror, xobsmean, xobserror, depths = basin_profile_mean_and_std(isbasin, xmodel, xmodelatobs, xdepthatobs, xobs, xwetobs, iobswet)
            xribbon!(ax, xmodelmean, xmodelerror, depths; color=colors[ibasin], αribbon, linewidth=model_thickness, ylims)
            xerrorbars!(ax, xobsmean, xobserror, depths, color=colors[ibasin], linewidth=obs_thickness)
            itracer == 1 && (ax.xlabel = "[Nd] ($(uDNd))")
            itracer == 2 && (ax.xlabel = "εNd ($(uεNd))")
            ibasin == 1 && (ax.ylabel = "Depth (m)")
            if itracer == 1 
                Makie.xlims!(ax, (0, 60))
            else
                Makie.xlims!(ax,(-15,1))
            end
            text!(ax, 0, 0, text=label_pos[ibasin, itracer], fontsize=20, align=(:left,:bottom), space=:relative, offset=(4,4), font=labelfont, color=:black)
                        # text!(ax, 0, 0, text=reshape(panellabels[1:4], (2,2))[ibasin, itracer], fontsize=20, align=(:left,:bottom), space=:relative, offset=(4,4), font=labelfont, color=:black)
            numobs =  count(isbasin(xobs.lat[iobswet], xobs.lon[iobswet], OCEANS))
            text!(ax, 1, 0, text=string(basins[ibasin], " ($numobs obs)"), align=(:right,:bottom), space=:relative, offset=(-4,4), font=labelfont, color=colors[ibasin])
        end
    end
    return axs
end
# Create the plot
axs = plot_profiles_v2!(fig)
# Add customized legend
obs_stl=(color=:black, linewidth=obs_thickness, linestyle=nothing)
group_modelobs = [
    [PolyElement(color=(:black, αribbon), strokecolor=:transparent),
     LineElement(color=:black, linewidth=model_thickness, linestyle=nothing, linepoints = Point2f0[(0.6, 0), (0.4, 1)])],
    [LineElement(;obs_stl...),
     LineElement(;obs_stl..., linepoints = Point2f0[(0.6, 0), (0.4, 1)]),
     LineElement(;obs_stl..., linepoints = Point2f0[(0, 0.35), (0, 0.65)]),
     LineElement(;obs_stl..., linepoints = Point2f0[(1, 0.35), (1, 0.65)])]
]
leg = Legend(fig, group_modelobs, ["Model", "Observations"]) ;
leg.orientation = :horizontal
fig[end+1,:] = leg
leg.tellheight = true


# 2. 
Nd_bounds = (0.0, 40.0)
εNd_bounds = (-20.0, 5.0)

tracer_names = ("[Nd]", "εNd")
labels = ("(a)", "(b)")

# cmap = cgrad(:oslo, 10, categorical=true, rev=true)
cmap = cgrad(:dense)
cmap2 = cgrad(cmap[2:end], categorical=true) # to skip the white color to leave the grid behind (prettier)

function myjointpdf2!(fig)
    axs = Array{Any}(undef, 2)
    cos = []
    for (itracer, (xmodel, xobs, ux, boundary, tracer_name, label)) in enumerate(zip((DNdmodel, εNdmodel), (DNdobs, εNdobs), (uDNd, uεNd), (Nd_bounds, εNd_bounds), tracer_names, labels))
        xmodelatobs, xdepthatobs, iobswet, xwetobs = _locations(xmodel, xobs, ux)
        #@show size.([xwetobs, xmodelatobs])
        x, y = ustrip.(xwetobs), ustrip.(xmodelatobs)
        bw = (boundary[2]-boundary[1])/150
        D = kde((x, y); boundary=(boundary, boundary), bandwidth=(bw,bw))

        # calculate cumulative density from density
        δx = step(D.x)
        δy = step(D.y)
        Q = vec(D.density) * δx * δy
        idx = sortperm(Q)
        Q_sorted = Q[idx]
        Dcum = similar(D.density)
        Dcum[idx] .= 100cumsum(Q_sorted)

        ax = fig[itracer,3] = Axis(fig, aspect = AxisAspect(1))
        co = Makie.contourf!(ax, D.x, D.y, Dcum, levels=10:10:100, colormap=cmap2)
        lines!(ax, collect(boundary), collect(boundary), linestyle=:dash, color=:black)
        #scatter!(ax, x, y, markersize=1)
        Makie.xlims!(ax, boundary)
        Makie.ylims!(ax, boundary)
        ax.xlabel = "Observed " * tracer_name * " ($ux)"
        ax.ylabel = "Modelled " * tracer_name * " ($ux)"

        # Add label
        Label(fig, bbox = ax.scene.px_area, label, fontsize=20, halign=:left, valign=:top, padding=(10,10,5,5), font=labelfont, color=:black)

        # Root mean square error
        RMSE = sqrt(mean((x - y).^2))
        Label(fig, bbox = ax.scene.px_area, sprintf1("RMSE = %.2f $ux", RMSE), fontsize=15, halign=:right, valign=:bottom, padding=(10,10,10,10), font=labelfont, color=:black)
        text!(ax, 0, 0, text=panellabels[10+itracer]; label_opts...)

        push!(axs, ax)
        push!(cos, co)
    end
    axs

    # colorbar
    cbar = fig[3, 3] = Colorbar(fig, #cos[1],
                                  colormap=cmap, ticks = 0:10:100, limits=(0,100),
                                  label="Percentile", vertical=false, flipaxis=false, ticklabelalign = (:center, :top))
    cbar.width = Relative(3/4)
    cbar.height = 30
    cbar.tellheight = true

    # make top plots square
    sublayout = GridLayout()
    fig[1:2, 1] = sublayout
    colsize!(sublayout, 1, Aspect(1,1))


    fig
end
# Create the plot
use_GLMakie && display(fig)
myjointpdf2!(fig)


# 3.
function sed_source_profiles!(fig)
    zbot = sort(unique(bottomdepthvec(grd)))
    ztop = sort(unique(topdepthvec(grd)))
    yticks = vcat(0, zbot)
    y = reduce(vcat, [zt, zb] for (zt, zb) in zip(ztop, zbot))
    label_opts = (fontsize=20, align=(:left,:bottom), offset=(4,4), space=:relative, font=labelfont, color=:black)

    # left panel is just ϕ(z)
    ax = fig[1,4] = Axis(fig)
    u = u"pmol/cm^2/yr"
    upref = upreferred(u)
    z = 0:1:6000
    v = ustrip.(u, ϕ(p).(z) .* upref)

    # Rearrange as a step function to match model source
    lines!(ax, v, z)
    Makie.ylims!(ax, (6000, -50))
    ax.yticks = 0:1000:6000
    ax.xlabel = "Base sed. flux, ϕ(z) ($(u))"
    ax.ylabel = "depth (m)"
    # text!(ax, 0, 0, text=panellabels[3]; label_opts...)
    # label
    text!(ax, 0, 0, text=panellabels[9]; label_opts...)
    # panel for alpha curve
    ax1 = fig[2,4] = Axis(fig)
    εs = upreferred.(collect(range(εclims..., length=1001) * per10000))
    αs = α_quad(εs, p)
    vlines!(ax1, [ustrip.(p.α_c)], linestyle=:dash, color=:gray)
    lines!(ax1, ustrip.(per10000, εs), αs)
    ax1.xlabel = "εNd (‱)"
    ax1.ylabel = "Scaling factor α(εNd)"
    Makie.ylims!(ax1, low=0.0)
    Makie.xlims!(ax1, εclims)
    text!(ax1, 0, 0, text=panellabels[10]; label_opts...)

    fig 
end
sed_source_profiles!(fig)


# 4. 
source_functions = (s_sed, s_river, s_dust, s_gw)
# source_functions = (s_sed, s_river, s_dust)
# source_iso_functions = (s_dust_iso, s_volc_iso, s_sed_iso, s_river_iso, s_gw_iso)
source_names = Tuple(Symbol(string(sₖ)[3:end]) for sₖ in source_functions)
source_vectors = Tuple(sₖ(p) for sₖ in source_functions)
# source_iso_vectors = Tuple(sₖ(p) for sₖ in source_iso_functions)
sources = (; zip(source_names, source_vectors)...)
# Masks
ATL = isatlantic(latvec(grd), lonvec(grd), OCEANS)
PAC = ispacific(latvec(grd), lonvec(grd), OCEANS)
# Units
uout = Mmol/yr
uin = mol/m^3/s
u∫dxdy = u"kmol/m/yr"

function integrate_sources!(fig)
    ax = fig[4,1] = Axis(fig)
    zbot = sort(unique(bottomdepthvec(grd)))
    ztop = sort(unique(topdepthvec(grd)))
    yticks = vcat(0, zbot)
    y = reduce(vcat, [zt, zb] for (zt, zb) in zip(ztop, zbot))
    label_opts = (fontsize=20, align=(:left,:bottom), offset=(4,4), space=:relative, font=labelfont, color=:black)
    # Arrays to store legend information
    legend_labels = String[]
    legend_colors = Color[]

    # Atlantic 
    for i in 1:length(source_names)
        ∫dxdy_source = vcat(0, repeat(ustrip.(round.((∫dxdy((sources[i].*ATL)*uin.*vectorize(grd.δz_3D, grd),grd)).|>uout|>ustrip,digits = 3)), inner=2), 0)
        # Add legend information
        push!(legend_labels, string(source_names[i]))
        push!(legend_colors, palette(:berlin,7)[i])
        # Plot
        poly!(ax, Point2f0.(zip(∫dxdy_source, vcat(0, y, maximum(zbot)))),color=palette(:berlin,7)[i], label = legend_labels[i])
    end
    Makie.ylims!(ax, (6000, -50))
    # Makie.xlims!(ax, (0, 8))
    ax.yticks = 0:1000:6000
    ax.ylabel = "Depth (m)"
    ax.xlabel = "Flux of source horizontally integrated ($(uout))" #Flux
    ax.title = "Atlantic"
    text!(ax, 0, 0, text=panellabels[5]; label_opts...)
    Legend(fig[5,1], [PolyElement(color = legend_colors[1]), PolyElement(color = legend_colors[2]), (PolyElement(color = legend_colors[3])),(PolyElement(color = legend_colors[4]))], legend_labels, framevisible = false, orientation = :horizontal)

    # Pacific
    legend_labels = String[]
    legend_colors = Color[]
    ax = fig[4,2] = Axis(fig)
    for i in 1:length(source_names)
        ∫dxdy_source = vcat(0, repeat(ustrip.(round.((∫dxdy((sources[i].*PAC)*uin.*vectorize(grd.δz_3D, grd),grd)).|>uout|>ustrip,digits = 3)), inner=2), 0)
        push!(legend_labels, string(source_names[i]))
        push!(legend_colors, palette(:berlin,7, rev = true)[i])
        # Plot
        poly!(ax, Point2f0.(zip(∫dxdy_source, vcat(0, y, maximum(zbot)))),color=palette(:berlin,7, rev=true)[i], label = legend_labels[i])
    end
    Makie.ylims!(ax, (6000, -50))
    # Makie.xlims!(ax, (0, 8))
    ax.yticks = 0:1000:6000
    ax.ylabel = "Depth (m)"
    ax.xlabel = "Flux of source horizontally integrated ($(uout))" #Flux
    ax.title = "Pacific"
    text!(ax, 0, 0, text=panellabels[6]; label_opts...)

    # Source Legend
    Legend(fig[5,2], [PolyElement(color = legend_colors[1]), PolyElement(color = legend_colors[2]), (PolyElement(color = legend_colors[3])),(PolyElement(color = legend_colors[4]))], legend_labels, framevisible = false, orientation = :horizontal)
    fig
end
integrate_sources!(fig)

# 5.
# (!isdefined(Main, :fDNd_wtags) || rediagnose) && include("../GMDpaper/GMD_diagnostics_setup.jl")
# function diag_table!(fig)
#     ax = [4,2]
#     # Dict for long names
#     ktostr = Dict(:dust => "Mineral dust",
#                   :volc => "Volcanic ash",
#                   :sed => "Sedimentary flux",
#                   :river => "Riverine discharge",
#                   :gw => "Groundwater discharge",
#                   :hydro => "Hydrothermal vents",
#                   :tot => "Total")

#     # units
#     uout = Mmol/yr
#     uin = mol/m^3/s

#     # make a table
#     df = DataFrame(
#         Symbol("Source type")=>[ktostr[k] for k in keys(sources)],
#         Symbol("Mmol/yr")=>[round.(∫dV(sₖ*uin,grd)|>uout|>ustrip,digits = 3) for sₖ in collect(sources)],
#         Symbol("Percent of Total Source")=>[round.(∫dV(sₖ,grd)/∫dV(sources.tot,grd)|>per100|>ustrip,digits = 3) for sₖ in collect(sources)],
#         Symbol("Nd Concentration (pM)")=>[round.(totalaverage(DNdₖ*upreferred(uDNd).|>uDNd,grd)|>ustrip,digits = 3) for DNdₖ in collect(DNdₖs)],
#         Symbol("Percent of Total Nd")=>[round.(∫dV(DNdₖ,grd)/∫dV(DNd,grd)|>per100|>ustrip,digits = 3) for DNdₖ in collect(DNdₖs)],
#         # Symbol("Residence Time (yr)")=>[round.(∫dV(DNdₖ,grd)/∫dV(sₖ,grd)*s|>yr|>ustrip,digits = 3) for (DNdₖ,sₖ) in zip(collect(DNdₖs), collect(sources))]
#     )


# end

# diag_table!(fig)


# 6.

surfacemask = horizontalslice(ones(count(iswet(grd))), grd, depth=0)
function plot_εNd_sources!(fig, fun)
    islog = fun == log10
    u = islog ? u"mol/m^2/yr" : u"μmol/m^2/yr"
    sources = [s_dust, s_sed]
    sources_iso =[s_dust_iso, s_sed_iso]
    hms = Vector{Any}(undef, 2)
    # axs = Array{Any,2}(undef, (length(sources), 2))
    # all maps (Nd source and εNd of source)
    for (i, (s1,s2)) in enumerate(zip(sources, sources_iso))
        # s1 and s2 are the Nd source and the isotope source
        ∫s1 = ∫dz(s1(p) .* u"mol/m^3/s", grd)
        ∫s2 = ∫dz(s2(p) .* u"mol/m^3/s", grd)
        # plot Nd source
        # ∫Nd = fun.(ustrip.(u, permutedims(∫s1, (2,1))))
        # axs[i,1] = fig[i,1] = Axis(fig, backgroundcolor=seafloor_color)
        # ax = axs[i,1]
        # mapit!(ax, clon, mypolys(clon), color=continent_color)
        # hms[1] = Makie.heatmap!(ax, sclons, lats, view(∫Nd, ilon, :),
        #                   colormap = islog ? logσcmap : σcmap, nan_color=nan_color)
        # mapit!(ax, clon, mypolys(clon), color=:transparent, strokecolor=:black, strokewidth=1)
        # mylatlons!(ax, latticks45, lonticks60)
        # i≠length(sources) && hidexdecorations!(ax, ticks=false, grid=false)
        # hms[1].colorrange = islog ? logσclims : σclims
        # plot εNd of source
        ∫εNd = permutedims(ustrip.(R2ε(∫s2 ./ ∫s1)), (2,1))
        # axs[i,5] = fig[i,5] = Axis(fig, backgroundcolor=seafloor_color)
        ax = fig[4,i+2] = Axis(fig)
        mapit!(ax, clon, mypolys(clon), color=continent_color)
        hms[2] = Makie.heatmap!(ax, sclons, lats, view(∫εNd, ilon, :), colormap=εcmap, nan_color=nan_color)
        mapit!(ax, clon, mypolys(clon), color=:transparent, strokecolor=:black, strokewidth=1)
        mylatlons!(ax, latticks45, lonticks60)
        i≠length(sources) && hidexdecorations!(ax, ticks=false, grid=false)
        hideydecorations!(ax, ticks=false, grid=false)
        hms[2].colorrange = εclims
        # text!(axs[i,1], 0, 0, text=string(panellabels[i]), align = (:left, :bottom), offset = (2, 2), space = :relative, fontsize=20, font=labelfont, color=:white)
        text!(ax, 0, 0, text=panellabels[6+i]; label_opts...)
        # text!(axs[i,5], 60, 45, text=string(s1)[3:end] * " Nd", fontsize=20, align=(:left,:bottom), offset = (4, -2), font=labelfont, color=:white)
        text!(ax, 60, 45, text=string(s1)[3:end] * " εNd", fontsize=20, align=(:left,:bottom), offset = (4, -2), font=labelfont, color=:white)
    end
    # annotations (must come after?)
    # for (i, (s1,s2)) in enumerate(zip(sources, sources_iso))
    #     # text!(axs[i,1], 0, 0, text=string(panellabels[i]), align = (:left, :bottom), offset = (2, 2), space = :relative, fontsize=20, font=labelfont, color=:white)
    #     text!(ax, 0, 0, text=panellabels[6+i]; label_opts...)
    #     # text!(axs[i,5], 60, 45, text=string(s1)[3:end] * " Nd", fontsize=20, align=(:left,:bottom), offset = (4, -2), font=labelfont, color=:white)
    #     text!(ax, 60, 45, text=string(s1)[3:end] * " εNd", fontsize=40, align=(:left,:bottom), offset = (4, -2), font=labelfont, color=:white)
    # end
    # colorbars
    # label = islog ? "log₁₀(Nd source flux / ($u))" : "Nd source flux ($u)"
    # cbar1 = fig[end+1, 1] = Colorbar(fig, hms[1], label=label, vertical=false, flipaxis=false, ticklabelalign = (:center, :top))
    # cbar1.width = Relative(3/4)
    # cbar1.height = 30
    # cbar1.tellheight = true
    cbar2 = fig[5, 4] = Colorbar(fig, hms[2], label="εNd ($per10000)", vertical=false, flipaxis=false, ticklabelalign=(:center, :top), ticks=εclims[1]:5:εclims[2])
    cbar2.width = Relative(3/4)
    cbar2.height = 30
    cbar2.tellheight = true
    nothing
end

fun = log10
local fig = Figure(resolution = (1500, 1800), backgroundcolor=:white)
plot_εNd_sources!(fig, fun)
trim!(fig.layout)

display(fig)
# if use_GLMakie
#     display(fig) # show the output wiht GLMakie
# else
#     save(joinpath(archive_path, "super_figure_$(split(lastcommit)[end])_run$(run_num).png"), fig)
#     nothing # just so that no output is spat out
# end
