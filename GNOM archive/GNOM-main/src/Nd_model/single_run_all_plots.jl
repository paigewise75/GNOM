# You are running a single run
# that will create DNd, εNd, and p.

# This lines sets up the model (and `F`) only once,
# so that you rerunning this file will not repeat the entire model setup
!isdefined(Main, :F) && include("model_setup.jl")

# This should create a new run name every time you run the file
# And add an empty runXXX file to the single_runs folder

allsingleruns_path = joinpath(output_path, "single_runs")
mkpath(output_path)
mkpath(allsingleruns_path)
# Check previous runs and get new run number
run_num = let
    previous_run_nums = [parse(Int, match(r"run(\d+)", f).captures[1]) for f in readdir(allsingleruns_path) if (contains(f, "run") && isdir(joinpath(allsingleruns_path, f)))]
    run_num = 1
    while run_num ∈ previous_run_nums
        run_num += 1
    end
    run_num
end
@info "This is run $run_num"
lastcommit = "single" # misnomer to call this lastcommit but simpler
archive_path = joinpath(allsingleruns_path, "run$run_num")
mkpath(archive_path)
reload = false # prevents loading other runs
use_GLMakie = false # Set to true for interactive mode if plotting with Makie later


# Chose your parameter values here. Optimized parameters
# — as published in Pasquier, Hines, et al. (2021) —
# are shown in comment (leave them there
# if you want to refer back to them)
p = Params(
    α_a =          0.0246593,
    α_c =           -17.7573per10000,
    α_GRL =          1.69489,
    σ_ε =           0.425818per10000,
    c_river =        31.9508pM,
    c_gw =           111.093pM,
    σ_hydro =         2.2354Mmol/yr,
    ε_hydro =       -3.67926per10000,
    ϕ_0 =            63096.1pmol/cm^2/yr,
    ϕ_∞ =            41.0516pmol/cm^2/yr,
    z_0 =            23.9716m,
    ε_EAsia_dust =  -11.1951per10000,
    ε_NEAf_dust =   -10.0858per10000,
    ε_NWAf_dust =   -13.9373per10000,
    ε_NAm_dust =    -4.24949per10000,
    ε_SAf_dust =      -17.98per10000,
    ε_SAm_dust =    -6.66528per10000,
    ε_MECA_dust =   -2.27667per10000,
    ε_Aus_dust =    -3.47185per10000,
    ε_Sahel_dust =  -9.50506per10000,
    β_EAsia_dust =       5.0per100,
    β_NEAf_dust =        5.0per100,
    β_NWAf_dust =        5.0per100,
    β_NAm_dust =         5.0per100,
    β_SAf_dust =         5.0per100,
    β_SAm_dust =         5.0per100,
    β_MECA_dust =        5.0per100,
    β_Aus_dust =         5.0per100,
    β_Sahel_dust =       5.0per100,
    ε_volc =         12.5136per10000,
    β_volc =            10.0per100,
    K_prec =      0.00112462/(mol/m^3),
    f_prec =        0.530366,
    w₀_prec =            0.7,
    K_POC =          16.6237,
    f_POC =         0.335344,
    w₀_POC =            40.0m/d,
    K_bSi =          68.4158/(mol/m^3),
    f_bSi =         0.929526,
    w₀_bSi =           714.0,
    K_dust =        0.652356/(mg/m^3), # changed from g/m^3 to mg/m^3
    f_dust =        0.170647,
    w₀_dust =            1.0km/yr,
)
# p = Params(
#     α_a = 0.807776
#     α_c = -0.616094per10000
#     α_GRL = 0.975825
#     σ_ε = 0.280312per10000
#     c_river = 635.482pM
#     c_gw = 89.5979pM
#     σ_hydro = 0.360472Mmol/yr
#     ε_hydro = 8.92452per10000
#     ϕ_0 = 14.9992pmol/cm^2/yr
#     ϕ_∞ = 171.026pmol/cm^2/yr
#     z_0 = 351.438m
#     ε_EAsia_dust = -11.3865per10000
#     ε_NEAf_dust = -13.0669per10000
#     ε_NWAf_dust = -14.2935per10000
#     ε_NAm_dust = -4.69149per10000
#     ε_SAf_dust = -14.1905per10000
#     ε_SAm_dust = -6.83543per10000
#     ε_MECA_dust = -4.71907per10000
#     ε_Aus_dust = -3.62971per10000
#     ε_Sahel_dust = -9.44225per10000
#     β_EAsia_dust = 85.9885per100
#     β_NEAf_dust = 2.52284per100
#     β_NAm_dust = 27.2513per100
#     β_NWAf_dust = 9.25903per100
#     β_SAf_dust = 62.2948per100
#     β_SAm_dust = 64.7789per100
#     β_MECA_dust = 86.9615per100
#     β_Aus_dust = 20.5632per100
#     β_Sahel_dust = 81.0706per100
#     ε_volc = 13.2828per10000
#     β_volc = 82.1559per100
#     K_prec = 0.00929035/(mol/m^3)
#     f_prec = 0.578063
#     w₀_prec = 0.7km/yr
#     K_POC = 0.161426/(mol/m^3)
#     f_POC = 0.782604
#     w₀_POC = 40.0km/yr
#     K_bSi = 120.682/(mol/m^3)
#     f_bSi = 0.987528
#     w₀_bSi = 714.0km/yr
#     K_dust = 3.78696/(mol/m^3)
#     f_dust = 0.417136
#     w₀_dust = 1.0km/yr
# )


tp_opt = AIBECS.table(p)# table of parameters
# "opt" is a misnomer but it is simpler for plotting scripts

# Save model parameters table and headcommit for safekeeping
jldsave(joinpath(archive_path, "model$(headcommit)_single_run$(run_num)_$(circname).jld2"); headcommit, tp_opt)

# Figure out how to write tp_opt into .md file not .jld2
open(joinpath(archive_path, "model$(headcommit)_single_run$(run_num)_$(circname).md"), "w") do file; write(file, "Head Commit: $headcommit\nTP Opt: $tp_opt\n") end

# Set the problem with the parameters above
prob = SteadyStateProblem(F, x, p)

# solve the system
sol = solve(prob, CTKAlg(), preprint="Nd & εNd solve ", τstop=ustrip(s, 1e3Myr)).u

# unpack nominal isotopes
DNd, DRNd = unpack_tracers(sol, grd)
DNdmodel = uconvert.(uDNd, DNd * upreferred(uDNd))

# compute εNd
εNd = ε.(DRNd ./ DNd)
εNdmodel = uconvert.(uεNd, εNd * upreferred(uεNd))

# For plotting, you can either
# follow the plotting scripts from the GNOM repository and use Makie
# or use Plots.jl (not a dependency of GNOM)
# I would recommend installing Plots.jl in your default environment anyway,
# so that it can be called even from inside the GNOM environment.
# You can then use the Plots.jl recipes exported by AIBECS, e.g.,
#
# julia> plotzonalaverage(εNd .|> per10000, grd, mask=ATL)

# To help manually adjust parameters, below is a little loop
# to check how much Nd each scavenging particle type removes
println("Scavenging removal:")
for t in instances(ScavenginParticle)
    println("- $(string(t)[2:end]): ", ∫dV(T_D(t, p) * 1/s * DNd * mol/m^3, grd) |> Mmol/yr)
end

include("../plots/GMDpaper/all_plots.jl")