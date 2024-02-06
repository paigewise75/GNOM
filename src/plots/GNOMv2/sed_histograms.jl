# Need to have sed flux as a function of eNd 

include("../plots_setup_Nd.jl")

function sed_histograms!(fig)
    # zbot = sort(unique(bottomdepthvec(grd)))
    # ztop = sort(unique(topdepthvec(grd)))
    # yticks = vcat(0, zbot)
    # y = reduce(vcat, [zt, zb] for (zt, zb) in zip(ztop, zbot))
    label_opts = (fontsize=20, align=(:left,:bottom), offset=(4,4), space=:relative, font=labelfont, color=:black)

    # left panel is just ϕ(z)
    ax = fig[1,1] = Axis(fig)
    u = u"pmol/cm^2/yr"
    upref = upreferred(u)
    r_εNd = round.(ustrip.(per10000, shifted_ε_sed(p)), digits = 2) # released Nd from sediments
    f_bot = round.(ustrip.(u, ϕ_bot(p) .* upref), digits = 2)

    # Rearrange as a step function to match model source
    # scatter!(ax,f_bot[1:100],r_εNd[1:100])
    # Makie.ylims!(ax, ( 6000, -50))
    #xlims!(ax, (0, 1.05maximum(v)))
    # Makie.xlims!(ax, (0, maximum(ax.finallimits[])[1]))
    


    # ax.ylabel = "Seafloor Sediment flux, ($(u))"
    # ax.xlabel = "Sediment Flux εNd"
    # text!(ax, 0, 0, text=panellabels[3]; label_opts...)
end

# Create the figure
fig = Figure(resolution=(800,1000))
sed_histograms!(fig)

if use_GLMakie
    display(fig) # show the output wiht GLMakie
else
    save(joinpath(archive_path, "sed_release_histogram_$(lastcommit)_run$(run_num).pdf"), fig)
    nothing # just so that no output is spat out
end

nothing
