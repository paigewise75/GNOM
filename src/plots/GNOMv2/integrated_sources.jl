include("../plots_setup_Nd.jl")
# include("../GNOMv2_figures")



# Put the source vectors in a named tuple for convenience
source_functions = (s_sed, s_river, s_dust, s_gw, s_volc, s_hydro)
# source_functions = (s_sed, s_river, s_dust)
source_iso_functions = (s_dust_iso, s_volc_iso, s_sed_iso, s_river_iso, s_gw_iso, s_hydro_iso)
source_names = Tuple(Symbol(string(sₖ)[3:end]) for sₖ in source_functions)
source_vectors = Tuple(sₖ(p) for sₖ in source_functions)
source_iso_vectors = Tuple(sₖ(p) for sₖ in source_iso_functions)
sources = (; zip(source_names, source_vectors)...)
sources_iso = (; zip(source_names, source_iso_vectors)...)


# Masks
ATL = isatlantic(latvec(grd), lonvec(grd), OCEANS)
PAC = ispacific(latvec(grd), lonvec(grd), OCEANS)

# Units
uout = Mmol/yr
uin = mol/m^3/s
u∫dxdy = u"kmol/m/yr"

# Isotopes
# u∫dxdy = u"kmol/m/yr"
# ∫s1 = ∫dxdy(s_tot(p) .* u"mol/m^3/s", grd)
# ∫s2 = ∫dxdy(s_tot_iso(p) .* u"mol/m^3/s", grd)
# ∫dxdy_s_tot_iso = round.(R2ε(∫s2 ./ ∫s1),digits = 3) 
# ∫dxdy_s_tot = round.((∫dxdy(s_tot(p)*uin.*vectorize(grd.δz_3D, grd),grd)).|>uout,digits = 3) # Flux 
# x_tot = vcat(0, repeat(ustrip.(∫dxdy_s_tot), inner=2), 0)
# x_tot_iso = vcat(0, repeat(ustrip.(∫dxdy_s_tot_iso), inner=2), 0)



suout = per10000

function integrate_sources!(fig)
    ax = fig[1,1] = Axis(fig)
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
        push!(legend_colors, ColorSchemes.colorschemes[:tableau_colorblind][i])
        # Plot
        poly!(ax, Point2f0.(zip(∫dxdy_source, vcat(0, y, maximum(zbot)))),color=ColorSchemes.colorschemes[:tableau_colorblind][i], label = legend_labels[i])
    end
    Makie.ylims!(ax, (6000, -50))
    Makie.xlims!(ax, (0, 8))
    ax.yticks = 0:1000:6000
    ax.ylabel = "Depth (m)"
    ax.xlabel = "Flux of source horizontally integrated ($(uout))" #Flux
    ax.title = "Atlantic"
    text!(ax, 0, 0, text=panellabels[1]; label_opts...)

    # Pacific
    ax = fig[1,2] = Axis(fig)
    for i in 1:length(source_names)
        ∫dxdy_source = vcat(0, repeat(ustrip.(round.((∫dxdy((sources[i].*PAC)*uin.*vectorize(grd.δz_3D, grd),grd)).|>uout|>ustrip,digits = 3)), inner=2), 0)
        # Plot
        poly!(ax, Point2f0.(zip(∫dxdy_source, vcat(0, y, maximum(zbot)))),color=ColorSchemes.colorschemes[:tableau_colorblind][i], label = legend_labels[i])
    end
    Makie.ylims!(ax, (6000, -50))
    Makie.xlims!(ax, (0, 8))
    ax.yticks = 0:1000:6000
    ax.ylabel = "Depth (m)"
    ax.xlabel = "Flux of source horizontally integrated ($(uout))" #Flux
    ax.title = "Pacific"
    text!(ax, 0, 0, text=panellabels[2]; label_opts...)

    # Source Legend
    Legend(fig[1,3], [PolyElement(color = legend_colors[1]), PolyElement(color = legend_colors[2]), (PolyElement(color = legend_colors[3])),(PolyElement(color = legend_colors[4])),(PolyElement(color = legend_colors[5])),(PolyElement(color = legend_colors[6]))], legend_labels, framevisible = false)
    # Legend(fig[1,3], [PolyElement(color = legend_colors[1]), PolyElement(color = legend_colors[2]), (PolyElement(color = legend_colors[3]))], legend_labels, framevisible = false)



    # Pacific
    ax = fig[2,2] = Axis(fig)
    s_tot

    # for i in length(x_tot)
    #     poly!(ax, Point2f0.(zip((s_plot[i], vcat(0, y, maximum(zbot))[i])),color=get(εcmap, x_tot_iso[i], εclims)))
    # end 
    # # poly!(ax, Point2f0.(zip(x_tot_iso, vcat(0, y, maximum(zbot)))),color=)
    ∫dxdy_source_tot = vcat(0, repeat(ustrip.(round.((∫dxdy((s_tot(p).*PAC)*uin.*vectorize(grd.δz_3D, grd),grd)).|>uout|>ustrip,digits = 3)), inner=2), 0)
    for i in 2:2:50
        # @show Point2f0.(zip(∫dxdy_source_tot, vcat(0, y, maximum(zbot))))[i]
        # if i == 48 || i ==50
        #     poly!(ax, Point2f0.(zip(∫dxdy_source_tot, vcat(0, y, maximum(zbot))))[i])
        # else
        #     poly!(ax,Point2f0.(zip(∫dxdy_source_tot[i:i+1], vcat(0, y, maximum(zbot))[i:i+1])))
        # end
        poly!(ax,Point2f0.(zip(∫dxdy_source_tot[1:40], vcat(0, y, maximum(zbot))[1:50])))
    end

    Makie.ylims!(ax, (6000, -50))
    Makie.xlims!(ax, (0, 8))
    ax.yticks = 0:1000:6000
    ax.ylabel = "Depth (m)"
    ax.xlabel = "Flux of source horizontally integrated ($(uout))" #Flux
    # ax.xlabel = "∫dxdy sed. source ($(u∫dxdy))" 
    ax.title = "Pacific"
    # poly!(legend=:outerbottom)
    #hideydecorations!(ax, grid=false)
    text!(ax, 0, 0, text=panellabels[4]; label_opts...)


end

fig = Figure(resolution=(1200,800))
integrate_sources!(fig)

# if use_GLMakie
    display(fig) # show the output wiht GLMakie
# else
#     save(joinpath(archive_path, "integrated_sources_$(lastcommit)_run$(run_num).png"), fig)
#     nothing # just so that no output is spat out
# end