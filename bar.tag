<bar>
    <script>
        this.mixin(RiotD3Mixin);

        this.on("update", function () {
            console.log("bar update!");

            var base = this.base;
            var width = this.width;
            var height = this.height;
            var margin = this.margin;
            var innerMargin = this.innerMargin;

            if(opts.patternFunc){
                opts.patternFunc(base);
            }

            // スケールと出力レンジの定義
            var xScale = d3.scale.ordinal().rangeRoundBands([0, width], 0.5); // 幅と余白の比率
            xScale.domain(data.map(function (d) {
                return d.name;
            }));

            var max = d3.max(data.map(function (d) {
                return d.value;
            }));
            if(innerMargin.top > 0){
                var yScale = d3.scale.linear().domain([0, max * height / (height - innerMargin.top)]).range([height, 0]);
            }else{
                var yScale = d3.scale.linear().domain([0, max]).range([height, 0]);
            }

            // 軸の定義
            var xAxis = d3.svg.axis()
                    .scale(xScale)
                    .orient("bottom")
                    .innerTickSize(opts.showGrid ? - height : 0)
                    .outerTickSize(0)
                    .tickPadding(10);

            var yAxis = d3.svg.axis()
                    .scale(yScale)
                    .innerTickSize(opts.showGrid ? - width : 0)
                    .outerTickSize(0)
                    .orient("left")
                    .tickPadding(10);
            if(opts.yFormat){
                yAxis.tickFormat(opts.yFormat);
            }

            base.select(".x").call(xAxis);

            var xAxisObj = base.append("g")
                    .attr("class", "x axis")
                    .attr("transform", "translate(0," + height + ")")
                    .call(xAxis)
                    .selectAll("text")
                    .style("text-anchor", "middle");

            if(opts.xTitle){
                xAxisObj.append("text").text(opts.xTitle).style("text-anchor", "middle")
                        .attr("transform", "translate(130,40)");
            }

            // y軸をsvgに表示
            var yAxisObj = base.append("g")
                    .attr("class", "y axis")
                    .call(yAxis);

            if(opts.yTitle){
                yAxisObj.append("text")
                        .text(opts.yTitle).style("text-anchor", "end")
                        .attr("transform", "translate(0,-10)");
            }

            if(opts.comp){
                console.log("comp found!");
                var translate = function(d){
                    return "translate(" + (xScale(d.name)+ xScale.rangeBand()/2) + "," + yScale(d.value) + ")";
                }
                base.selectAll(".bar")
                        .data(data)
                        .enter().append("g")
                        .attr("class", "bar")
                        .attr("transform", translate)
                        .each(function (d) {
                            riot.mount(this, opts.comp, {
                                data: d,
                                width:xScale.rangeBand(),
                                height: height - yScale(d.value),
                                radius: d.radius, // 呼び出し側の責任で用意する
                            });
                        });
            }else{
                base.selectAll(".bar")
                        .data(data)
                        .enter().append("rect")
                        .attr("class", "bar")
                        .attr({
                            x: function (d) {
                                return xScale(d.name);
                            },
                            y: function (d) {
                                return yScale(d.value);
                            },
                            fill:function(d){
                                return d.fill || d.color || opts.color ||"black";
                            },
                            stroke: function(d){return d.stroke}
                        })
                        .attr("width", xScale.rangeBand())
                        .attr("height", function (d) {
                            return height - yScale(d.value);
                        });
            }
        });

    </script>
</bar>