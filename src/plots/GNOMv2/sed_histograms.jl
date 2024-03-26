# Need to have sed flux as a function of eNd 

include("../plots_setup_Nd.jl")

function sed_histograms!(fig)
    label_opts = (fontsize=20, align=(:left,:bottom), offset=(4,4), space=:relative, font=labelfont, color=:black)

    # left panel = ϕ(z) vs εNd 
    ax = fig[1,1] = Axis(fig)
    u = u"pmol/cm^2/yr"
    v = ustrip(vectorize(grd.δz_3D, grd))*100 # cm
    uin = pmol/cm^3/yr
    f_bot = s_sed(p).*v.*f_topo
    f_bot_noGRL = (s_sed(p)./α_GRL(p)).*v.*f_topo
    r_εNd = round.(ustrip.(per10000, shifted_ε_sed(p)), digits = 2) # released Nd from sediments

    j_0 = Float64[] # mean sed flux
    r_0 = Float64[] # εNd
    m_0 = Float64[] # total sed flux
    n_0 = Float64[] # mean sed flux without GRL

    for i in (round.(minimum(r_εNd),digits = 0))-2:5:(round.(maximum(r_εNd),digits = 0))+3
        indices = findall(x -> x>i && x < (i+4), r_εNd)
        j = mean(f_bot[indices])
        m = sum(f_bot[indices])
        n = mean(f_bot_noGRL[indices])
        push!(j_0,j)
        push!(r_0,i)
        push!(m_0,m)
        push!(n_0,n)
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

    # for i in (round.(minimum(r_εNd),digits = 0)):1:(round.(maximum(r_εNd),digits = 0))
    #    indices = findall(x -> x>i && x < (i+1), r_εNd)
    #    a = sum(a_sed[indices])
    #    push!(a_0,a)
    #    push!(r_0,i)
    # end

    for i in (round.(minimum(r_εNd),digits = 0))-2:5:(round.(maximum(r_εNd),digits = 0))+3
        indices = findall(x -> x>i && x < (i+5), r_εNd)
        a = sum(a_sed[indices])
        push!(a_0,a)
        push!(r_0,i)
     end

    barplot!(r_0, a_0, color="orange")
    ax.ylabel = "Total Sediment Area ($(u))"
    ax.xlabel = "Sediment Flux εNd"
    ax.xticks = -40:5:20
    text!(ax, 0, 0, text=panellabels[3]; label_opts...)
    return r_0, a_0, j_0, m_0, n_0
end

# Create the figure
fig = Figure(resolution=(1000,500))
sed_histograms!(fig)

# if use_GLMakie
#     display(fig) # show the output wiht GLMakie
# else
#     save(joinpath(archive_path, "sed_release_histogram_$(lastcommit)_run$(run_num).png"), fig)
#     nothing # just so that no output is spat out
# end


# nothing
out = sed_histograms!(fig)

using CSV

function save_data_to_csv(filename, out)
    r_0, a_0, j_0,n_0,m_0 = out
    data = Dict("r_0" => r_0, "a_0" => a_0, "j_0" => j_0, "n_0" => n_0, "m_0" => m_0)
    CSV.write(filename, data)
end

