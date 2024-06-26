include("../plots_setup_Nd.jl")




surfacemask = horizontalslice(ones(count(iswet(grd))), grd, depth=0)
function plot_εNd_sources!(fig, fun)
    islog = fun == log10
    u = islog ? u"mol/m^2/yr" : u"μmol/m^2/yr"
    sources = [s_dust, s_sed]
    sources_iso =[s_dust_iso, s_sed_iso]
    hms = Vector{Any}(undef, 2)
    axs = Array{Any,2}(undef, (length(sources), 2))
    # all maps (Nd source and εNd of source)
    for (i, (s1,s2)) in enumerate(zip(sources, sources_iso))
        # s1 and s2 are the Nd source and the isotope source
        ∫s1 = ∫dz(s1(p) .* u"mol/m^3/s", grd)
        ∫s2 = ∫dz(s2(p) .* u"mol/m^3/s", grd)
        # plot Nd source
        ∫Nd = fun.(ustrip.(u, permutedims(∫s1, (2,1))))
        axs[i,1] = fig[i,1] = Axis(fig, backgroundcolor=seafloor_color)
        ax = axs[i,1]
        mapit!(ax, clon, mypolys(clon), color=continent_color)
        hms[1] = Makie.heatmap!(ax, sclons, lats, view(∫Nd, ilon, :),
                          colormap = islog ? logσcmap : σcmap, nan_color=nan_color)
        mapit!(ax, clon, mypolys(clon), color=:transparent, strokecolor=:black, strokewidth=1)
        mylatlons!(ax, latticks45, lonticks60)
        i≠length(sources) && hidexdecorations!(ax, ticks=false, grid=false)
        hms[1].colorrange = islog ? logσclims : σclims
        # plot εNd of source
        ∫εNd = permutedims(ustrip.(R2ε(∫s2 ./ ∫s1)), (2,1))
        axs[i,2] = fig[i,2] = Axis(fig, backgroundcolor=seafloor_color)
        ax = axs[i,2]
        mapit!(ax, clon, mypolys(clon), color=continent_color)
        hms[2] = Makie.heatmap!(ax, sclons, lats, view(∫εNd, ilon, :), colormap=εcmap, nan_color=nan_color)
        mapit!(ax, clon, mypolys(clon), color=:transparent, strokecolor=:black, strokewidth=1)
        mylatlons!(ax, latticks45, lonticks60)
        i≠length(sources) && hidexdecorations!(ax, ticks=false, grid=false)
        hideydecorations!(ax, ticks=false, grid=false)
        hms[2].colorrange = εclims
    end
    # annotations (must come after?)
    for (i, (s1,s2)) in enumerate(zip(sources, sources_iso))
        text!(axs[i,1], 0, 0, text=string(panellabels[i]), align = (:left, :bottom), offset = (2, 2), space = :relative, fontsize=20, font=labelfont, color=:white)
        text!(axs[i,2], 0, 0, text=string(panellabels[i+length(sources)]), align = (:left, :bottom), offset = (2, 2), space = :relative, fontsize=20, font=labelfont, color=:white)
        text!(axs[i,1], 60, 45, text=string(s1)[3:end] * " Nd", fontsize=20, align=(:left,:bottom), offset = (4, -2), font=labelfont, color=:white)
        text!(axs[i,2], 60, 45, text=string(s1)[3:end] * " εNd", fontsize=20, align=(:left,:bottom), offset = (4, -2), font=labelfont, color=:white)
    end
    # colorbars
    label = islog ? "log₁₀(Nd source flux / ($u))" : "Nd source flux ($u)"
    cbar1 = fig[end+1, 1] = Colorbar(fig, hms[1], label=label, vertical=false, flipaxis=false, ticklabelalign = (:center, :top))
    cbar1.width = Relative(3/4)
    cbar1.height = 30
    cbar1.tellheight = true
    cbar2 = fig[end, 2] = Colorbar(fig, hms[2], label="εNd ($per10000)", vertical=false, flipaxis=false, ticklabelalign=(:center, :top), ticks=εclims[1]:5:εclims[2])
    cbar2.width = Relative(3/4)
    cbar2.height = 30
    cbar2.tellheight = true
    nothing
end

fun = log10
    local fig = Figure(resolution = (1500, 1800), backgroundcolor=:white)
    plot_εNd_sources!(fig, fun)
    trim!(fig.layout)
    if use_GLMakie
        display(fig) # show the output wiht GLMakie
    else
        str = (fun == log10) ? "log_" : ""
        save(joinpath(archive_path, "source_$(str)maps_$(lastcommit)_run$(run_num).png"), fig)
        nothing # just so that no output is spat out
    end

