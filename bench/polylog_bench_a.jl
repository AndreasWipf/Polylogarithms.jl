# check the Bernoulli numbers and polynomials
#    this is mostly just a check that code is correct
#    most errors are arising because of errors in the functions being used
using Polylogarithms
using BenchmarkTools
using DataFrames, CSV
using PyPlot
using Printf
include("utilities.jl")

series_1 = Polylogarithms.polylog_series_1
series_2 = Polylogarithms.polylog_series_2
series_3 = Polylogarithms.polylog_series_3
L = Symbol("Li_s(z)")
    

# input data from Mathematica and reparse into complex numbers
for C=1:3
    filename = @sprintf("../data/polylog_test_data_a_%d.csv", C)
    data1 = CSV.read(filename; delim=",", type=String)
    #    has trouble reading in numbers like "2." so read all into strings, and parse
    data1[!,:s] = parse.(Complex{Float64}, data1[!,:s] )
    data1[!,:r] = parse.(Float64, data1[!,:r] )
    data1[!,:theta] = parse.(Float64, data1[!,:theta] )
    data1[!,:z] = parse.(Complex{Float64}, data1[!,:z] )
    data1[!,L] = parse.(Complex{Float64}, data1[!,L] )
    # check that complex numbers are being read in correctly
    z = data1[!,:z]
    z2 = data1[!,:r] .* exp.( im* data1[!,:theta] )
    error = data1[!,:z] .- z2
    maximum_abs_error = maximum(abs.(error))
    # [data1[1:10,:z] parse.(Complex{Float64}, data1[1:10,:z] ) z2[1:10] ]
    # [data1[1:10,:z]  z2[1:10] ]
    println("max error in parsing is ", maximum_abs_error)
    
    # figure(1)
    # plot(real.(z), imag.(z), "o")
    # axis("equal")
    
    m = size(data1,1)
    Li = data1[!,L]
    s = data1[!,:s]
    su = unique(s)
    if length(su) > 1
        error()
    else
        su = su[1]
    end
    S1 = zeros(Complex{Float64}, m)
    S2 = zeros(Complex{Float64}, m)
    n1 = zeros(Int64, m)
    error1 = zeros(Float64, m)
    rel_error1 = zeros(Float64, m)
    n2 = zeros(Int64, m)
    error2 = zeros(Float64, m)
    rel_error2 = zeros(Float64, m)
    
    for i=1:m
        print(".")
        result1 = series_1(s[i], z[i])
        S1[i] = result1[1]
        n1[i] = result1[2]
        error1[i] = abs( S1[i] - Li[i]  )
        rel_error1[i] = error1[i]/abs( Li[i] )
        
        result2 = series_2(s[i], z[i])
        S2[i] = result2[1]
        n2[i] = result2[2]
        error2[i] = abs( S2[i] - Li[i]  )
        rel_error2[i] = error2[i]/abs( Li[i] )
    end
    println("")
    println("max abs. error1 = $(maximum( abs.(error1) ))")
    println("max abs. error2 = $(maximum( abs.(error2) ))")
    
    fig = figure(@sprintf("../data/polylog_bench_a_%02d.csv", C), figsize=(10,10))
    clf()
    title(@sprintf("s = %f + %f i", real(su), imag(su) )
    d = 0.01

    subplot(221)
    semilogy( data1[!,:r] .- d, rel_error1, "o")
    semilogy( data1[!,:r] .+ d, rel_error2, "+")
    xlabel("r")
    ylabel("relative absolute error")
    plot([0,1], [1,1]*Polylogarithms.default_accuracy)
    xlim([0, 1.15])
    # ylim([1.0-e15, 1.0e-10])
    
    subplot(223)
    semilogy( data1[!,:r] .- d, n1, "o")
    semilogy( data1[!,:r] .+ d, n2, "g+")
    θ = unique(data1[!,:theta])
    for i=1:length(θ)
        k = findall(data1[!,:theta] .== θ[i])
        plot(data1[k,:r] .+ d, n2[k], "g:")
        text(data1[k[end],:r]+2*d, n2[k[end]], "$(θ[i]/π)"; verticalalignment="center")
    end
    text(1.0, 72, "θ/π"; verticalalignment="center")
    xlabel("r")
    ylabel("number of terms")
    plot([0,1], [1,1]*Polylogarithms.default_max_iterations)
    xlim([0, 1.15])
    
    subplot(222)
    semilogy( data1[!,:theta] ./ π .- d, rel_error1, "o")
    semilogy( data1[!,:theta] ./ π .+ d, rel_error2, "+")
    xlabel("θ/π")
    ylabel("relative absolute error")
    plot([0,1], [1,1]*Polylogarithms.default_accuracy)
    
    subplot(224)
    semilogy( data1[!,:theta] ./ π .- d, n1, "o")
    semilogy( data1[!,:theta] ./ π .+ d, n2, "+")
    xlabel("θ/π")
    ylabel("number of terms")
    plot([0,1], [1,1]*Polylogarithms.default_max_iterations)
    
    # savefig(@sprintf("../data/polylog_bench_a_%02d.svg", C))
    savefig(@sprintf("../data/polylog_bench_a_%02d.pdf", C))
end
    