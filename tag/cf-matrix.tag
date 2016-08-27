<cf-matrix>
    <script>
        this.mixin(RiotD3Mixin);

        this.on("update", function () {

                    var base = this.base;
                    var width = this.width;
                    var height = this.height;
                    var margin = this.margin;
                    var innerMargin = this.innerMargin;

                    var tmp = base.attr("transform").match(/translate\((.*),(.*)\)/);
                    var x = ~~tmp[1], y = ~~tmp[2];
                    base.attr("transform", "translate(" + (x + width / 2) + "," + ( y + height / 2) + ")");
                    var size = Math.min(width, height);

                    var data = opts.data;

                    var max = opts.max || Math.max(
                            d3.max(data.map(function (d) {
                                return Math.abs(d.x);
                            })),
                            d3.max(data.map(function (d) {
                                return Math.abs(d.y);
                            }))
                    );

                    if (opts.annotation) {
                        base.append("text").text(opts.annotation).attr({
                            class: "annotation",
                            x: width,
                            y: -opts.margin.top + 20
                        }).style("text-anchor", "end");
                    }

            // background
            base.selectAll(".bg").data([
                {x:0, y:-size/2, fill:"#C9DAF8"},
                {x:-size/2, y:0, fill:"#ccc"},
                {x:-size/2, y:-size/2, fill:"#eee"},
                {x:0, y:0, fill:"#eee"},
            ]).enter().append("rect").classed("bg",true).attr({
                x: function(d){return d.x},
                y: function(d){return d.y},
                width: size/2,
                height: size/2,
                fill: function(d){return d.fill}
            });
            var line = d3.svg.line()
                    .x(function (d) {return d.x})
                    .y(function (d) {return d.y})
                    .interpolate("cardinal");
            base.append("path").attr({
                d: line([{x: -size/2, y:-size/2}, {x:size/2, y:size/2}]),
                stroke:"white",
                "stroke-width":3
            });

            base.selectAll(".areaTitle").data([
                {x: size/2 - 10, y: -size/2 + 15, text:"停滞期", "text-anchor": "end"},
                {x: -size/2 + 10, y: size/2 - 15, text:"破綻期", "text-anchor": "start"},
                {x: -size/2 + 10, y: 0 - 15, text:"後退期", "text-anchor": "start"},
                {x: 0 - 10, y: -size/2 + 15, text:"低迷期", "text-anchor": "end"},
                {x: 0 + 10, y: size/2 - 15, text:"投資期", "text-anchor": "start"},
                {x: size/2 - 10, y: 0 + 15, text:"安定期", "text-anchor": "end"},
            ]).enter().append("text").attr({
                class:"areaTitle",
                x: function(d){return d.x},
                y: function(d){return d.y},
                dy: "0.35em",
                "text-anchor": function(d){return d["text-anchor"]}
            }).text(function(d){return d.text});


                    var xScale = d3.scale.linear().domain([-max, max]).range([-size / 2, size / 2]);
                    var yScale = d3.scale.linear().domain([-max, max]).range([size / 2, -size / 2]);

            // main line
            base.append("path").attr({
                d: line(data.map(function(d){
                    return {x:xScale(d.x), y:yScale(d.y)};
                })),
                stroke:"red",
                "stroke-width":2,
                fill:"none"
            });

                    var yAxis = d3.svg.axis()
                            .scale(yScale)
                            .orient("left")
                            .innerTickSize(0)
                            .outerTickSize(0)
                            .tickPadding(20);

                    var xAxis = d3.svg.axis()
                            .scale(xScale)
                            .innerTickSize(0)
                            .outerTickSize(0)
                            .orient("bottom")
                            .tickPadding(10);
                    if (opts.yFormat) {
                        yAxis.tickFormat(opts.yFormat);
                    }

                    if (opts.showYAxis == undefined || opts.showYAxis) {
                        var yAxisObj = base.append("g")
                                .attr("class", "y axis")
                                .call(yAxis).selectAll("text").attr("visibility","hidden");
                    }

                    if (opts.yTitle) {
                        yAxisObj.append("text")
                                .text(opts.yTitle).style("text-anchor", "end")
                                .attr("transform", translate(0, -size/2));
                    }

                    if (opts.showXAxis == undefined || opts.showXAxis) {
                        var xAxisObj = base.append("g")
                                .attr("class", "x axis")
                                .call(xAxis).selectAll("text").attr("visibility","hidden");
                    }

                    if (opts.xTitle) {
                        xAxisObj.append("text").text(opts.xTitle).style("text-anchor", "middle")
                                .attr("transform", translate(size/2, 0));
                    }

            }
    );

    </script>
</cf-matrix>