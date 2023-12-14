include("../Nd_model/model_setup.jl")

# p0 is a tuple of parameter symbols and values 
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

# Iterate through the keys in p0
for item in keys(p0)
    global p_i = item
    
    # Runs parameter_sensitivity_test_PW varying the magnitude of the param of interest
    for z in [0.5, 1, 2]  
        global mag = z  
        include("parameter_sensitivity_test_PW.jl")
        include("../plots/GMDpaper/profiles_v2.jl")
    end 
end 

println("Done!")