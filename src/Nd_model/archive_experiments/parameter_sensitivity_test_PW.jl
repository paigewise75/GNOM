# You are running a single run
# that will create DNd, εNd, and p.

# This lines sets up the model (and `F`) only once,
# so that you rerunning this file will not repeat the entire model setup
!isdefined(Main, :F) && include("model_setup.jl")

allsingleruns_path = joinpath(output_path, "single_runs")
mkpath(output_path)
mkpath(allsingleruns_path)

# This should create a new run name every time you run the file
# And add an empty runXXX file to the single_runs folder
sensitivity_path = joinpath(allsingleruns_path, "$p_i")
mkpath(sensitivity_path)

# Check previous runs and get new run number
run_num = let
    previous_run_nums = [parse(Int, match(r"run(\d+)", f).captures[1]) for f in readdir(sensitivity_path) if (contains(f, "run") && isdir(joinpath(sensitivity_path, f)))]
        run_num = 1
        while run_num ∈ previous_run_nums
            run_num += 1
        end
        run_num
end
@info "This is run $run_num changing $(p_i)"
lastcommit = "single" # misnomer to call this lastcommit but simpler
sensitivity_path = joinpath(sensitivity_path,"run$run_num")
mkpath(sensitivity_path)


reload = false # prevents loading other runs
use_GLMakie = false # Set to true for interactive mode if plotting with Makie later


# Chose your "base" parameter values here.
# Note that here I am not using the `Params` function, but a simple "Tuple"
p0 = (
    α_a =                  5.51344, # 6.79
    α_c =                 -12.1612per10000, # -12.7per10000
    α_GRL =                 1.6257,# 1.57
    σ_ε =                 0.311346per10000, # 0.379per10000
    c_river =              509.224pM, # 376.0pM
    c_gw =                 113.722pM, # 109.0pM
    σ_hydro =              1.0e-10Mmol/yr, # 0.792Mmol/yr
    ε_hydro =                 10.0per10000, # 10.9per10000
    ϕ_0 =                  39.5663pmol/cm^2/yr, # 83.7pmol/cm^2/yr
    ϕ_∞ =                  1.07387pmol/cm^2/yr, # 1.11pmol/cm^2/yr
    z_0 =                  305.393m, # 170.0m
    ε_EAsia_dust =        -10.3307per10000, # -7.6per10000
    ε_NEAf_dust =         -13.7866per10000, # -13.7per10000
    ε_NWAf_dust =         -12.4613per10000, # -12.3per10000
    ε_NAm_dust =          -7.08689per10000, # -4.25per10000
    ε_SAf_dust =          -20.8211per10000, # -21.6per10000
    ε_SAm_dust =           -3.4277per10000, # -3.15per10000
    ε_MECA_dust =          -1.8745per10000, # 0.119per10000
    ε_Aus_dust =          -4.43421per10000, # -4.03per10000
    ε_Sahel_dust =        -12.1238per10000, # -11.9per10000
    β_EAsia_dust =         3.69809per100, # 23.0per100
    β_NEAf_dust =          4.03127per100, # 23.3per100
    β_NWAf_dust =          2.44869per100, # 3.17per100
    β_NAm_dust =           3.21908per100, # 82.8per100
    β_SAf_dust =            4.1829per100, # 38.5per100
    β_SAm_dust =            1.1545per100, # 2.52per100
    β_MECA_dust =          2.02466per100, # 14.7per100
    β_Aus_dust =           1.62141per100, # 11.6per100
    β_Sahel_dust =         1.97046per100, # 2.95per100
    ε_volc =               5.42087per10000, # 13.1per10000
    β_volc =               2.10581per100, # 76.0per100
    K_prec =            0.00488087/(mol/m^3), # 0.00576/(mol/m^3)
    f_prec =              0.125863, # 0.124
    w₀_prec =                  0.7km/yr, # 0.7km/yr
    K_POC =               0.412189/(mol/m^3), # 0.524/(mol/m^3)
    f_POC =               0.378695, # 0.312
    w₀_POC =                  40.0m/d, # 40.0m/d
    K_bSi =               0.616421/(mol/m^3), # 2.56/(mol/m^3)
    f_bSi =               0.566809, # 0.784
    w₀_bSi =               714.069m/d, # 714.0m/d
    K_dust =              0.000119/(g/m^3), # 1.7/(g/m^3)
    f_dust =             0.0659166, # 0.0861
    w₀_dust =                  1.0km/yr, # 1.0km/yr
)



println("\nMultiplying $p_i by $mag")
p = Params(; p0..., p_i => mag * getfield(p0, p_i))
        
tp_opt = AIBECS.table(p) # table of parameters
# "opt" is a misnomer but it is simpler for plotting scripts

# Save model parameters table and headcommit for safekeeping
jldsave(joinpath(sensitivity_path, "model$(headcommit)_single_run$(run_num)_$(p_i).jld2"); headcommit, tp_opt)
write(joinpath(sensitivity_path, "model$(headcommit)_single_run$(run_num)_$(p_i).md"), string(tp_opt))

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

