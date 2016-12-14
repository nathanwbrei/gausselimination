

using Gadfly
using DataFrames



function main()

    #df0 = parseGroup("baseline", "baseline/output/")
    #writetable("plots/0_all_results.csv", df0)
    df0 = readtable("plots/0_all_results.csv")

    # ====================================================================
    # Verify that the MPI time variance increases with the number of nodes
    # ====================================================================

    #df1 = df0[(df0[:experiment] .== "baseline") & (df0[:procs] .== 16), :]

    #df2 = DataFrame(nodes=df1[:nodes], problemSize=df1[:problemSize], mpiTime=df1[:mpiTime])
    #writetable("1_baseline_filtered.csv", df2)

    #df2 = decolumnize(df, :procs,
    #                  [:computeTime, :mpiTime, :ioTime],
    #                  ["Compute time", "MPI time", "IO time"])
    #writetable("2_baseline_decolumnized.csv", df2)



    #df3 = aggregate(df2, [:problemSize, :nodes], [mean, var, minimum, maximum])
    #writetable("2_baseline_aggregated.csv", df3)

    #p = plot(
    #    x = df3[:problemSize],
    #    y = df3[:mpiTime_mean],
    #    ymax=df3[:mpiTime_maximum],
    #    ymin=df3[:mpiTime_minimum],
    #    color = df3[:nodes],
    #    Geom.point,
    #    Geom.line,
    #    Geom.ribbon,
    #    Guide.xlabel("Number of ranks"),
    #    Guide.ylabel("Wall clock time"),
    #    Guide.title("Strong scalability"),
    #    Scale.x_log2
    #)
    #draw(PDF("myplot.pdf", 6inch, 6inch), p)

    # ====================================================================
    # Strong scaling:
    #    Hold problemSize, nodes constant.
    #    Plot procs vs mpiTime, computeTime, totalTime
    # ====================================================================
    # TODO: This assumes our table contains only the smallest feasible :nodes for each :procs
    #       Which is true now, but might change in the future


    # TODO: Consider changing mean to median
    # TODO: Weak scaling is wrong, needs to be fixed problem size per processor
    # TODO: Consider summing up all ranks per sample

    df1 = df0[(df0[:experiment] .== "baseline") & (df0[:problemSize] .== 1024), :]

    df2 = df1[[:procs, :mpiTime, :computeTime, :totalTime]]

    df3 = stack(df2, [:mpiTime, :computeTime, :totalTime])

    df4 = aggregate(df3, [:procs, :variable], [mean, var, minimum, maximum])

    writetable("plots/2.1_strong_filtered.csv", df1)
    writetable("plots/2.2_strong_stacked.csv", df3)
    writetable("plots/2.3_strong_aggregated.csv", df4)

    p = plot(
        x = df4[:procs],
        y = df4[:value_mean],
        ymax=df4[:value_maximum],
        ymin=df4[:value_minimum],
        color = df4[:variable],
        Geom.point,
        Geom.line,
        #Geom.errorbar,
        Geom.ribbon,
        Guide.xlabel("Number of ranks"),
        Guide.ylabel("Wall clock time [s]"),
        Guide.title("Baseline: Strong scalability"),
        Scale.x_log2,
        Scale.y_log10
    )
    draw(PDF("plots/baseline_strong.pdf", 6inch, 6inch), p)



    # ====================================================================
    # Weak scaling:
    #    Hold procs, nodes constant.
    #    Plot problemSize vs mpiTime, computeTime, totalTime
    # ====================================================================
    # TODO: This assumes our table contains only the smallest feasible :nodes for each :procs
    #       Which is true now, but might change in the future

    df1 = df0[(df0[:experiment] .== "baseline") & (df0[:procs] .== 32), :]

    df2 = df1[[:problemSize, :mpiTime, :computeTime, :totalTime]]

    df3 = stack(df2, [:mpiTime, :computeTime, :totalTime])

    df4 = aggregate(df3, [:problemSize, :variable], [mean, var, minimum, maximum])

    writetable("plots/3.1_weak_filtered.csv", df1)
    writetable("plots/3.2_weak_stacked.csv", df3)
    writetable("plots/3.3_weak_aggregated.csv", df4)

    p = plot(
        x = df4[:problemSize],
        y = df4[:value_mean],
        ymax=df4[:value_maximum],
        ymin=df4[:value_minimum],
        color = df4[:variable],
        Geom.point,
        Geom.line,
        #Geom.errorbar,
        Geom.ribbon,
        Guide.xlabel("Problem size"),
        Guide.ylabel("Wall clock time [s]"),
        Guide.title("Baseline: Weak scalability"),
        Scale.x_log2,
        Scale.y_log10
    )
    draw(PDF("plots/baseline_weak.pdf", 6inch, 6inch), p)
end

function parseGroup(group, inputdir)
    filename_re = r"_(\d+)_node_(\d+)_procs_([\d\.]+)\.out$"
    files = readlines(`ls $inputdir`)
    results = DataFrame()

    for filename in files

        full_filename = pwd() * "/" * inputdir * "/" * strip(filename)

        if (m=match(filename_re, filename)) != nothing
            print("Parsing $full_filename")
            nodes = parse(Int, m[1])
            procs = parse(Int, m[2])
            jobid = m[3]
            df = parseFile(inputdir*strip(filename), group, jobid, nodes, procs)
            results = vcat(results, df)

        else
            print("Ignoring $full_filename")
        end
    end
    results
end



function parseFile(filename, group, jobid, nodes, procs)
    df = DataFrame(experiment=[],
                   jobId=[],
                   nodes=[],
                   procs=[],
                   sample=[],
                   problemSize=[],
                   rank=[],
                   ioTime=[],
                   setupTime=[],
                   computeTime=[],
                   mpiTime=[],
                   totalTime=[])
    sample = 0
    problemsize = "None"

    re1 = r"WRITE:.*x([\d]+)\.sol\"$"
    re2 = r"\[R(\d+)\] Times: IO: ([\d\.]+)\; Setup: ([\d\.]+)\; Compute: ([\d\.]+)\; MPI: ([\d\.]+)\; Total: ([\d\.]+)\;$"

    print("Opening '" * filename * "'...")
    print("CWD is " * pwd())

    fp = open(filename)
    lines = readlines(fp)
    close(fp)

    for l in lines

        if startswith(l, "Solving")
            sample += 1

        elseif (m = match(re1, l)) != nothing
            problemsize = m[1]

        elseif (m = match(re2, l)) != nothing
            push!(df, @data([group,
                             jobid,
                             nodes,
                             procs,
                             sample,
                             parse(Int, problemsize),
                             parse(Int, m[1]),
                             parse(Float64, m[2]),
                             parse(Float64, m[3]),
                             parse(Float64, m[4]),
                             parse(Float64, m[5]),
                             parse(Float64, m[6])]))

        else
            print("Ignoring line: " * l)
        end
    end
    df
end

