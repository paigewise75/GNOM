include("../plots_setup_Nd.jl")
include("../GNOMv2_figures")



source_functions = (s_sed, s_river,s_dust)
source_names = Tuple(Symbol(string(sₖ)[3:end]) for sₖ in source_functions)
source_vectors = Tuple(sₖ(p) for sₖ in source_functions)
source_iso_vectors = Tuple(sₖ(p) for sₖ in source_iso_functions)
sources = (; zip(source_names, source_vectors)...)


# Masks
ATL = isatlantic(latvec(grd), lonvec(grd), OCEANS)
PAC = ispacific(latvec(grd), lonvec(grd), OCEANS)


# Unit 
uout = Mmol/yr
uin = mol/m^3/s

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
    x1 =[]
    for (i,s1) in enumerate(sources)
        s1 = s1 .* ATL
        u∫dxdy = u"kmol/m/yr"
        # ∫dxdy_s1 = ∫dxdy(s1 * upreferred(uDNd) / s, grd) .|> u∫dxdy # Source
        ∫dxdy_s1 = round.((∫dxdy(s1*uin.*vectorize(grd.δz_3D, grd),grd)).|>uout|>ustrip,digits = 3) # Flux
        x = vcat(0, repeat(ustrip.(∫dxdy_s1), inner=2), 0)
        push!(x1,x)
        # Add legend information
        push!(legend_labels, string(source_names[i]))
        push!(legend_colors, ColorSchemes.colorschemes[:tableau_colorblind][i])
        # Plot
        poly!(ax, Point2f0.(zip(x1[i], vcat(0, y, maximum(zbot)))),color=ColorSchemes.colorschemes[:tableau_colorblind][i],label = legend_labels[i])

    end


    Makie.ylims!(ax, (6000, -50))
    # Makie.xlims!(ax, (0, maximum(ax.finallimits[])[1]))
    ax.yticks = 0:1000:6000
    ax.ylabel = "Depth (m)"
    ax.xlabel = "Flux of source horizontally integrated ($(uout))" #Flux
    # ax.xlabel = "∫dxdy sed. source ($(u∫dxdy))"
    ax.title = "Atlantic"
    # poly!(legend=:outerbottom)
    #hideydecorations!(ax, grid=false)
    text!(ax, 0, 0, text=panellabels[4]; label_opts...)

    # Pacific
    ax = fig[1,2] = Axis(fig)
    x1 =[]
    for (i,s1) in enumerate(sources)
        s1 = s1 .* PAC
        u∫dxdy = u"kmol/m/yr"
        # ∫dxdy_s1 = ∫dxdy(s1 * upreferred(uDNd) / s, grd) .|> u∫dxdy
        ∫dxdy_s1 = round.((∫dxdy(s1*uin.*vectorize(grd.δz_3D, grd),grd)).|>uout|>ustrip,digits = 3) # Flux 
        x = vcat(0, repeat(ustrip.(∫dxdy_s1), inner=2), 0)
        push!(x1,x)
        poly!(ax, Point2f0.(zip(x1[i], vcat(0, y, maximum(zbot)))),color=ColorSchemes.colorschemes[:tableau_colorblind][i], label = legend_labels[i])
    end


    Makie.ylims!(ax, (6000, -50))
    # Makie.xlims!(ax, (0, maximum(ax.finallimits[])[1]))
    ax.yticks = 0:1000:6000
    ax.ylabel = "Depth (m)"
    ax.xlabel = "Flux of source horizontally integrated ($(uout))" #Flux
    # ax.xlabel = "∫dxdy sed. source ($(u∫dxdy))" 
    ax.title = "Pacific"
    # poly!(legend=:outerbottom)
    #hideydecorations!(ax, grid=false)
    text!(ax, 0, 0, text=panellabels[4]; label_opts...)
    Legend(fig[1,3], [PolyElement(color = legend_colors[1]), PolyElement(color = legend_colors[2]), (PolyElement(color = legend_colors[3]))], legend_labels, framevisible = false)
end

fig = Figure(resolution=(1200,500))
integrate_sources!(fig)
display(fig)