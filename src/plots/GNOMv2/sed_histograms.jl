# Need to have sed flux as a function of eNd 

include("../plots_setup_Nd.jl")

function sed_histograms!(fig)
    label_opts = (fontsize=20, align=(:left,:bottom), offset=(4,4), space=:relative, font=labelfont, color=:black)

    # left panel = ϕ(z) vs εNd 
    ax = fig[1,1] = Axis(fig)
    u = u"pmol/yr"
    upref = upreferred(u)/(100^2)u"m^2/cm^2"
    b = f_topo.*(ustrip.(ϕ_bot(p))/(100^2)) #pmol/m^2/yr
    v = f_topo.*(ustrip(vector_of_volumes(grd)./vectorize(grd.δz_3D, grd))) # m^2
    f_bot = ustrip(b.*v) #pmol/m^2/yr * m^2 = pmol/yr

    # f_bot = ustrip.(u, (f_topo.*ustrip.(u,ϕ_bot(p).* upref))./v)
    r_εNd = round.(ustrip.(per10000, shifted_ε_sed(p)), digits = 2) # released Nd from sediments

    j_0 = Float64[]
    r_0 = Float64[]

    for i in (round.(minimum(r_εNd),digits = 0)):1:(round.(maximum(r_εNd),digits = 0))
       indices = findall(x -> x>i && x < (i+1), r_εNd)
       j = sum(f_bot[indices])
       push!(j_0,j)
       push!(r_0,i)
    end
    barplot!(r_0, j_0, xlabel = "εNd Released from Sediment", ylabel = "Total Flux (pmol/yr)")
    ax.ylabel = "Seafloor Sediment flux, ($(u))"
    ax.xlabel = "Sediment Flux εNd"
    ax.xticks = -40:5:20
    # ax.yticks = minimum(j_0):1000:6000
    text!(ax, 0, 0, text=panellabels[3]; label_opts...)

    # right panel = sed area vs εNd
    ax = fig[1,2] = Axis(fig)
    u = u"m^2"
    upref = upreferred(u)
    r_εNd = round.(ustrip.(per10000, shifted_ε_sed(p)), digits = 2) # released Nd from sediments
    a_sed = v

    a_0 = Float64[]
    r_0 = Float64[]

    for i in (round.(minimum(r_εNd),digits = 0)):1:(round.(maximum(r_εNd),digits = 0))
       indices = findall(x -> x>i && x < (i+1), r_εNd)
       a = sum(a_sed[indices])
       push!(a_0,a)
       push!(r_0,i)
    end
    barplot!(r_0, a_0, color="orange")
    ax.ylabel = "Sediment Area ($(u))"
    ax.xlabel = "Sediment Flux εNd"
    ax.xticks = -40:5:20
    text!(ax, 0, 0, text=panellabels[3]; label_opts...)
end

# Create the figure
fig = Figure(resolution=(1000,500))
sed_histograms!(fig)

if use_GLMakie
    display(fig) # show the output wiht GLMakie
else
    save(joinpath(archive_path, "sed_release_histogram_$(lastcommit)_run$(run_num).pdf"), fig)
    nothing # just so that no output is spat out
end

nothing
