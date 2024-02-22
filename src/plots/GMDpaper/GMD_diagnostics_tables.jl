
# Compute the diagnostics only once, unless rediagnose=true
 (!isdefined(Main, :fDNd_wtags) || rediagnose) && include("GMD_diagnostics_setup.jl")



# Table 3 in GMD paper (source magnitudes, contributions, and bulk ages)
let
    # Dict for long names
    ktostr = Dict(:dust => "Mineral dust",
                  :volc => "Volcanic ash",
                  :sed => "Sedimentary flux",
                  :river => "Riverine discharge",
                  :gw => "Groundwater discharge",
                  :hydro => "Hydrothermal vents",
                  :tot => "Total")

    # units
    uout = Mmol/yr
    uin = mol/m^3/s

    # make a table
    df = DataFrame(
        Symbol("Source type")=>[ktostr[k] for k in keys(sources)],
        Symbol("Mmol/yr")=>[round.(∫dV(sₖ*uin,grd)|>uout|>ustrip,digits = 3) for sₖ in collect(sources)],
        Symbol("Percent of Total Source")=>[round.(∫dV(sₖ,grd)/∫dV(sources.tot,grd)|>per100|>ustrip,digits = 3) for sₖ in collect(sources)],
        Symbol("Nd Concentration (pM)")=>[round.(totalaverage(DNdₖ*upreferred(uDNd).|>uDNd,grd)|>ustrip,digits = 3) for DNdₖ in collect(DNdₖs)],
        Symbol("Percent of Total Nd")=>[round.(∫dV(DNdₖ,grd)/∫dV(DNd,grd)|>per100|>ustrip,digits = 3) for DNdₖ in collect(DNdₖs)],
        # Symbol("Residence Time (yr)")=>[round.(∫dV(DNdₖ,grd)/∫dV(sₖ,grd)*s|>yr|>ustrip,digits = 3) for (DNdₖ,sₖ) in zip(collect(DNdₖs), collect(sources))]
    )
    @show df


    # Make a LaTeX table
    formatters = (v,i,j) -> (j ≥ 3) ? string("\$", (v ≥ 10 ? Int : identity)(parse(Float64, sprintf1("%.2g", v))), "\$") : v
    f = pretty_table(df, backend = Val(:latex), formatters=formatters, nosubheader=true)

    filepath = joinpath(archive_path,"run_num$(run_num)_sourcemagnitude.tex")
    generate_latex_table(df, filepath)

#     filepath = joinpath(archive_path,"run_num$(run_num)_sourcemagnitude.txt")
#     open(filepath, "w") do f
#         pretty_table(f,df)
#    end

end


