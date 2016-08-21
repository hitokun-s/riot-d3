<left-right-bar>
    <script>
        this.mixin(RiotD3Mixin);

        this.on("update", function () {

                    var base = this.base;
                    var width = this.width;
                    var height = this.height;
                    var margin = this.margin;
                    var innerMargin = this.innerMargin;

                    var data = opts.data;

                    var max = opts.max || d3.max(data.map(function (d) {
                                return Math.abs(d.value);
                            }));
                    console.log(max);
                    console.log("width:", width);

                    if (opts.annotation) {
                        base.append("text").text(opts.annotation).attr({
                            class: "annotation",
                            x: width,
                            y: -opts.margin.top + 20
                        }).style("text-anchor", "end");
                    }


                    var xScale = d3.scale.ordinal().rangeRoundBands([0, height], opts.barWidthRatio || 0.5); // 幅と余白の比率
                    xScale.domain(data.map(function (d) {
                        return d.name;
                    }));

                    var halfWidth = width / 2;
                    var yScale;
                    if (innerMargin.side && innerMargin.side > 0) {
                        yScale = d3.scale.linear().domain([
                            -max * halfWidth / (halfWidth - innerMargin.side),
                            max * halfWidth / (halfWidth - innerMargin.side)]).range([0, width]);
                    } else {
                        yScale = d3.scale.linear().domain([-max, max]).range([0, width]);
                    }
                    console.log("yscale-700",yScale(-700));

//                    var xAxis = d3.svg.axis()
//                            .scale(xScale)
//                            .orient("left")
//                            .innerTickSize(0)
//                            .outerTickSize(0)
//                            .tickPadding(20);

                    var yAxis = d3.svg.axis()
                            .scale(yScale)
                            .innerTickSize(opts.showGrid ? -height : 0)
                            .outerTickSize(0)
                            .orient("top")
                            .tickPadding(10);
                    if (opts.yFormat) {
                        yAxis.tickFormat(opts.yFormat);
                    }

                    if (opts.showYAxis == undefined || opts.showYAxis) {
                        var yAxisObj = base.append("g")
                                .attr("class", "y axis")
                                .call(yAxis);
                    }

                    if (opts.yTitle) {
                        yAxisObj.append("text")
                                .text(opts.yTitle).style("text-anchor", "end")
                                .attr("transform", "translate(0,-10)");
                    }

                    var tmpTranslate = function (d) {
                        return translate(0, xScale(d.name) + xScale.rangeBand() / 2);
                    };
                    var bars = base.selectAll(".bar")
                            .data(data)
                            .enter().append("g")
                            .attr("class", "bar").attr("transform", tmpTranslate);


                    if (opts.barImg) {
                        bars.each(function (d) {
                            var selfNode = this;
                            var self = d3.select(this);
                            var barWidth = yScale(d.value);
                            var count = parseInt(barWidth / opts.barImg.slide);
                            if ((count - 1) * opts.barImg.slide + opts.barImg.width > barWidth + opts.barImg.width / 2) {
                                count--;
                            }
                            if (d.transition) {
                                var counter = 0;
                                var timer = setInterval(function () {
                                    self.append("svg:image")
                                            .attr('y', -xScale.rangeBand() / 2)
                                            .attr('x', yScale(d.value) + opts.barImg.slide * counter)
                                            .attr('height', xScale.rangeBand())
                                            .attr('width', opts.barImg.width)
                                            .attr("xlink:href", opts.barImg.url);
                                    counter++;
                                    if (counter >= count) {
                                        clearTimeout(timer);
                                        self.select("text").attr("visibility", "visible");
                                    }
                                }, 1000 / count);
                            } else {
                                for (var i = 0; i < count; i++) {
                                    self.append("svg:image")
                                            .attr('y', -xScale.rangeBand() / 2)
                                            .attr('x', yScale(d.value) + opts.barImg.slide * counter)
                                            .attr('height', xScale.rangeBand())
                                            .attr('width', opts.barImg.width)
                                            .attr("xlink:href", opts.barImg.url);
                                }
                            }
                        });
                    } else {
                        var rect = bars.append("rect").attr({
                            y: -xScale.rangeBand() / 2,
                            x: function(d){
                                if(d.transition){
                                    return halfWidth;
                                }else{
                                    return d.value >= 0 ? halfWidth : yScale(d.value);
                                }
                            },
                            height: xScale.rangeBand(),
                            width: function (d) {
                                return d.transition ? 0 : Math.abs(yScale(d.value) - halfWidth);
                            },
                            fill: function (d) {
                                return d.fill || d.color || opts.color || "black";
                            },
                            stroke: function (d) {
                                return d.stroke;
                            }
                        });
                        rect.filter(function (d) {
                            return d.transition;
                        }).transition().duration(1000).attr({
                            width: function (d) {
                                return Math.abs(yScale(d.value) - halfWidth);
                            },
                            x: function(d){
                                return d.value >= 0 ? halfWidth : yScale(d.value);
                            }
                        }).each("end", function (d) {
                            d3.select(this.parentNode).select("text").attr("visibility", "visible");
                        })
                    }

                    // draw onBar name
                    if (data.filter(function (d) {
                                return d.nameOnBar;
                            })) {
                        bars.append("text").text(function (d) {
                            return opts.nameOnBarFormat ? opts.nameOnBarFormat(d.nameOnBar) : d.nameOnBar;
                        }).attr({
                            x: function (d) {
                                return yScale(d.value);
                            },
                            dx: opts.nameOnBarMargin || 10,
                            dy: "0.3em",
                            class: "nameOnBar",
                            visibility: function (d) {
                                return d.transition ? "hidden" : "visible";
                            },
                            fill: function (d) {
                                return d.color || "red";
                            }
                        }).style("text-anchor", "start");
                    }

//                    if (opts.showXAxis == undefined || opts.showXAxis) {
//                        var xAxisObj = base.append("g")
//                                .attr("class", "x axis")
//                                .call(xAxis)
//                                .selectAll("text")
//                                .style("text-anchor", "middle");
//                    }

//                    if (opts.xTitle) {
//                        xAxisObj.append("text").text(opts.xTitle).style("text-anchor", "middle")
//                                .attr("transform", "translate(130,40)");
//                    }

                    // legends
                    if (opts.comp && opts.legend) {
                        var legendLinear = d3.legend.color().shapeWidth(20).scale(colorScale)
                        //                        .shape('circle')
                                .shapePadding(10)
                                //                        .orient('horizontal')
                                .labelOffset(10);

                        base.append('g').attr({
                            class: 'legendLinear',
                            transform: translate(width, 10)
                        }).call(legendLinear);
                    }

                    if (opts.showLine) {
                        // TODO 横向きチャートには未対応
                        //tmpTranslate
                        var pathData = data.map(function (d) {
                            //translate(xScale(d.name)+ xScale.rangeBand() / 2 , yScale(d.value));
                            return {x: xScale(d.name) + xScale.rangeBand() / 2, y: yScale(d.value)}
                        });
                        var line = d3.svg.line()
                                .x(function (d) {
                                    return d.x
                                })
                                .y(function (d) {
                                    return d.y
                                });
//                        .interpolate("cardinal");
                        base.append("path").datum(pathData).classed("lineOnBar", true)
                                .attr("d", line).attr({
                            "stroke-dasharray": "3 3",
                            stroke: "gray",
                            fill: "none"
                        });
                        base.selectAll("circle.circleOnBar").data(pathData).enter().append("circle").classed("circleOnBar", true)
                                .attr({
                                    cx: function (d) {
                                        return d.x
                                    },
                                    cy: function (d) {
                                        return d.y
                                    },
                                    r: 5
                                });
                    }

                }
        );

    </script>
</left-right-bar>