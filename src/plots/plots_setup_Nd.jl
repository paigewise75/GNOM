use_GLMakie = false
# Load the model functions
(!isdefined(Main, :prob) || resetup) && include("../Nd_model/model_setup.jl")

# Load the plots setup
# (!isdefined(Main, :εNd_transects) || reload) && include("load.jl")
(!isdefined(Main, :εNd_transects) || reload) && include("load_GNOMv2.jl")
(!isdefined(Main, :numformat) || retools) && include("tools.jl")

