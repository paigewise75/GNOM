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
    α_a =               6.45276,
    α_c =              -13.7422per10000,
    α_GRL =             1.69054,
    σ_ε =              0.330175per10000,
    c_river =           377.196pM,
    c_gw =              109.275pM,
    σ_hydro =           1.0e-10Mmol/yr,
    ε_hydro =              10.0per10000,
    ϕ_0 =               50.2891pmol/cm^2/yr,
    ϕ_∞ =               1.03707pmol/cm^2/yr,
    z_0 =               254.202m,
    ε_EAsia_dust =     -5.88622per10000,
    ε_NEAf_dust =      -13.8684per10000,
    ε_NWAf_dust =      -12.1785per10000,
    ε_NAm_dust =       -4.28184per10000,
    ε_SAf_dust =       -20.4214per10000,
    ε_SAm_dust =        -3.0745per10000,
    ε_MECA_dust =      -1.72877per10000,
    ε_Aus_dust =       -3.86294per10000,
    ε_Sahel_dust =     -11.9669per10000,
    β_EAsia_dust =      25.5131per100,
    β_NEAf_dust =       24.4037per100,
    β_NWAf_dust =        1.8691per100,
    β_NAm_dust =         76.929per100,
    β_SAf_dust =        52.4305per100,
    β_SAm_dust =        1.40808per100,
    β_MECA_dust =       2.28289per100,
    β_Aus_dust =        3.00365per100,
    β_Sahel_dust =       1.6293per100,
    ε_volc =            5.43921per10000,
    β_volc =            2.55449per100,
    K_prec =         0.00629263/(mol/m^3),
    f_prec =           0.120359,
    w₀_prec =               0.7,
    K_POC =            0.492207,
    f_POC =            0.467976,
    w₀_POC =               40.0m/d,
    K_bSi =             2.25397/(mol/m^3),
    f_bSi =             0.77551,
    w₀_bSi =            714.069,
    K_dust =        0.000738994/(mg/m^3), # changed from g/m^3 to mg/m^3
    f_dust =          0.0741093,
    w₀_dust =               1.0km/yr,
)

tp_opt = AIBECS.table(p)# table of parameters
# "opt" is a misnomer but it is simpler for plotting scripts

# Save model parameters table and headcommit for safekeeping
jldsave(joinpath(archive_path, "model$(headcommit)_single_run$(run_num)_$(circname).jld2"); headcommit, tp_opt)
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