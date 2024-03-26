include("../plots_setup_Nd.jl")

zbot = sort(unique(bottomdepthvec(grd)))
ztop = sort(unique(topdepthvec(grd)))
y = reduce(vcat, [zt, zb] for (zt, zb) in zip(ztop, zbot))

source_functions = (s_sed, s_river, s_dust, s_gw, s_volc, s_hydro)
# source_functions = (s_sed, s_river, s_dust)
source_names = Tuple(Symbol(string(sₖ)[3:end]) for sₖ in source_functions)
source_vectors = Tuple(sₖ(p) for sₖ in source_functions)
sources = (; zip(source_names, source_vectors)...)

# Masks
ATL = isatlantic(latvec(grd), lonvec(grd), OCEANS)
PAC = ispacific(latvec(grd), lonvec(grd), OCEANS)

# Units
uout = Mmol/yr
uin = mol/m^3/s
u∫dxdy = u"kmol/m/yr"

dxdy_sources = Dict{Symbol, Vector{Float64}}()

for i in 1:length(sources)
    ∫dxdy_source_ATL = vcat(0, repeat(ustrip.(round.((∫dxdy((sources[i].*ATL)*uin.*vectorize(grd.δz_3D, grd),grd)).|>uout|>ustrip,digits = 3)), inner=2), 0)
    ∫dxdy_source_PAC = vcat(0, repeat(ustrip.(round.((∫dxdy((sources[i].*PAC)*uin.*vectorize(grd.δz_3D, grd),grd)).|>uout|>ustrip,digits = 3)), inner=2), 0)
    
    dxdy_sources[Symbol("$(source_names[i])_ATL")] = ∫dxdy_source_ATL
    dxdy_sources[Symbol("$(source_names[i])_PAC")] = ∫dxdy_source_PAC
    dxdy_sources[Symbol("depth")] = vcat(0, y, maximum(zbot))
end

CSV.write(joinpath(data_path,"$(lastcommit)_run$(run_num)_Int.csv"), DataFrame(dxdy_sources))
