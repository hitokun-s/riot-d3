<floating-bar>
    <script>
        this.mixin(RiotD3Mixin);

        this.on("update", function () {
            console.log("diff-bar update!");

            var base = this.base;
            var width = this.width;
            var height = this.height;
            var margin = this.margin;
            var innerMargin = this.innerMargin;

            // 各データは、valueではなく（あってもいいが）、bottom, top プロパティを持つ
            var data = opts.data;
            var metadata = opts.metadata || {};

            // スケールと出力レンジの定義
            var xScale = d3.scale.ordinal().rangeRoundBands([0, width], opts.bandRatio || 0.5); // 幅と余白の比率
            xScale.domain(data.map(function (d) {
                return d.name;
            }));

            var max = d3.max(data.map(function (d) {
                return d.top;
            }));
            if (innerMargin.top > 0) {
                var yScale = d3.scale.linear().domain([0, max * height / (height - innerMargin.top)]).range([height, 0]);
            } else {
                var yScale = d3.scale.linear().domain([0, max]).range([height, 0]);
            }

            if (opts.yAxis) {
                var yAxis = d3.svg.axis()
                        .scale(yScale)
                        .innerTickSize(opts.showGrid ? -width : 0)
                        .outerTickSize(0)
                        .orient("left")
                        .tickPadding(10);
                if (opts.yFormat) {
                    yAxis.tickFormat(opts.yFormat);
                }
                // y軸をsvgに表示
                var yAxisObj = base.append("g")
                        .attr("class", "y axis")
                        .call(yAxis);

                if (opts.yTitle) {
                    yAxisObj.append("text")
                            .text(opts.yTitle).style("text-anchor", "end")
                            .attr("transform", "translate(0,-10)");
                }
            }

            var pathData = [];
            data.forEach(function(d,i){

                d.x = xScale(d.name);
                d.width = xScale.rangeBand();
                d.midx = d.x + d.width/2;

                if(i == 0){
                    return;
                }
                var prev = data[i - 1];
                if(d.top == prev.top || d.bottom == prev.top){
                    pathData.push([
                        {x:prev.midx, y: yScale(prev.top)},
                        {x: d.midx, y: yScale(prev.top)},
                    ])
                }
                if(d.bottom == prev.bottom || d.top == prev.bottom){
                    pathData.push([
                        {x:prev.midx, y: yScale(prev.bottom)},
                        {x: d.midx, y: yScale(prev.bottom)},
                    ])
                }
            });

            var line = d3.svg.line()
                    .x(function (d) {return d.x})
                    .y(function (d) {return d.y})
                    .interpolate("cardinal");

            if (opts.comp) {
                console.error("not supported!");
                alert("not supported!");
            }

            var tmpTranslate = function(d){
                return translate(xScale(d.name)+ xScale.rangeBand() / 2 , yScale(d.top));
            };
            var bars = base.selectAll(".floating-bar")
                    .data(data)
                    .enter().append("g").attr({
                        transform: tmpTranslate,
                        class: "floating-bar"
                    });

            bars.append("rect").attr({
                x: - (opts.relativeBandRatio || 1) * xScale.rangeBand() / 2 ,
                y: 0,
                width: (opts.relativeBandRatio || 1) * xScale.rangeBand(),
                height: function (d) {
                    return height - yScale(d.top - d.bottom);
                },
                fill: function (d) {
                    return d.color || opts.color || "black";
                },
                stroke: function (d) {
                    return d.stroke || opts.color;
                },
            }).on("click", function (d) {
                RiotControl.trigger("diffBarClicked", d, metadata);
            });

            // draw onBar name
            if(data.filter(function(d){return d.nameOnBar;})){
                bars.append("text").text(function(d) {
                    return opts.nameOnBarFormat ? opts.nameOnBarFormat(d.nameOnBar) : d.nameOnBar;
                }).attr({
                    dy: -20,
                    class: "nameOnBar"
                }).style("text-anchor", "middle").on("click", function(d){
                    RiotControl.trigger("diffBarClicked", d, metadata);
                });
            }

            bars.on("mouseover", function(d){
                d.oriColor = d3.select(this).select("rect").attr("fill");
                d3.select(this).selectAll("path,rect").attr({
                    fill: "#fad1d1",
                    stroke: "#fad1d1",
                });
                d3.select(this).select("text").attr("font-weight","bold");
            }).on("mouseout", function(d){
                d3.select(this).selectAll("path,rect").attr({
                    fill: d.oriColor,
                    stroke: d.oriColor,
                });
                d3.select(this).select("text").attr("font-weight","normal");
            })

            base.selectAll("path.horizon")
                    .data(pathData)
                    .enter()
                    .append("path").classed("horizon", true)
                    .attr("d", function (d) {
                        return line(d);
                    }).attr({
                "stroke-dasharray":"3 3",
                stroke:"gray"
            });

            if(opts.xAxis) {
                var xAxis = d3.svg.axis()
                        .scale(xScale)
                        .orient("bottom")
                        .innerTickSize(opts.showGrid ? -height : 0)
                        .outerTickSize(0)
                        .tickPadding(10);
                if (opts.xFormat) {
                    xAxis.tickFormat(opts.xFormat);
                }
                var xAxisObj = base.append("g")
                        .attr("class", "x axis")
                        .attr("transform", "translate(0," + height + ")")
                        .call(xAxis)
                        .selectAll("text")
                        .style("text-anchor", "middle");

                if (opts.xTitle) {
                    xAxisObj.append("text").text(opts.xTitle).style("text-anchor", "middle")
                            .attr("transform", "translate(130,40)");
                }
            }
        });

    </script>
</floating-bar>