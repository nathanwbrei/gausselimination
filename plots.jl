

using Gadfly
using DataFrames
using RDatasets

Gadfly.push_theme(:dark)

function parseOutfile()
    

end


function makeSimpleDF()
    df = DataFrame(numProcs=[], problemSize=[], mpiTime=[], computeTime=[], ioTime=[])
    push!(df, @data([4, 128, 10, 20, 30]))
    push!(df, @data([8, 128, 10, 15, 30]))
    push!(df, @data([16, 128, 10, 10, 30]))
    push!(df, @data([32, 128, 10, 5, 30]))
    push!(df, @data([64, 128, 10, 1, 30]))
    df
end


function makeNoisyDF()
    df = DataFrame(numProcs=[], problemSize=[], mpiTime=[], computeTime=[], ioTime=[])
    push!(df, @data([4, 128, 10, 20, 30]))
    push!(df, @data([8, 128, 10, 15, 30]))
    push!(df, @data([16, 128, 10, 10, 30]))
    push!(df, @data([32, 128, 10, 5, 30]))
    push!(df, @data([64, 128, 10, 1, 30]))
    push!(df, @data([4, 128, 12, 20, 30]))
    push!(df, @data([8, 128, 10, 17, 30]))
    push!(df, @data([16, 128, 19, 10, 30]))
    push!(df, @data([32, 128, 10, 5, 30]))
    push!(df, @data([64, 128, 11, 1, 20]))
    push!(df, @data([4, 128, 12, 20, 30]))
    push!(df, @data([8, 128, 16, 15, 20]))
    push!(df, @data([16, 128, 11, 10, 30]))
    push!(df, @data([32, 128, 13, 5, 30]))
    push!(df, @data([64, 128, 12, 1, 30]))
    df
end



function decolumnize(df, iv, dvs, labels)
  xx = repeat(df[iv], outer=length(dvs))
  gg = repeat(labels, inner=size(df,1))
  yy = []
  for dv in dvs
      yy = vcat(yy, df[dv])
  end
  DataFrame(x = xx, y = yy, g = gg)
end


df = makeNoisyDF()
df0 = df[df[:problemSize] .== 128, :]
df1 = decolumnize(df, :numProcs,
                  [:computeTime, :mpiTime, :ioTime],
                  ["Compute time", "MPI time", "IO time"])
df2 = aggregate(df1, [:x, :g], [mean, minimum, maximum])

#df2[:y_max] = df2[:y_mean]+sqrt(df2[:y_var])
#df2[:y_min] = df2[:y_mean]-sqrt(df2[:y_var])

p = plot(
  x = df2[:x], y = df2[:y_mean], ymax=df2[:y_maximum], ymin=df2[:y_minimum], color = df2[:g],
  Geom.point,
  Geom.line,
  Geom.ribbon,
  Guide.xlabel("Number of ranks"),
  Guide.ylabel("Wall clock time"),
  Guide.title("Strong scalability"),
  Scale.x_log2
)

draw(PDF("myplot.pdf", 6inch, 6inch), p)

# p = plot(
#   layer(x=df2[:numProcs],
#         y=df2[:ioTime_mean],
#         Theme(default_color=colorant"green"),
#         Geom.line),
#   layer(x=df2[:numProcs],
#         y=df2[:computeTime_mean],
#         Geom.point,
#         Theme(default_color=colorant"blue")),
#   Guide.xlabel("Problem size"),
#   Guide.ylabel("Wall clock time"),
#   Guide.title("Weak scalability"),
#   Scale.x_log2,
#   Scale.y_log10
# )

#plot(x=rand(10), y=rand(10),
#     Guide.manual_color_key("Some Title",
#                            ["item one", "item two", "item three"],
#                            ["red", "green", "blue"]))
