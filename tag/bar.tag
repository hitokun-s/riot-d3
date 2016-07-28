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

            var data = opts.data;

            if(opts.patternFunc){
                opts.patternFunc(base);
            }
            var max = opts.max || d3.max(data.map(function (d) {
                        return d.value;
                    }));

            if(opts.annotation){
                base.append("text").text(opts.annotation).attr({
                    class: "annotation",
                    x: width,
                    y: - opts.margin.top + 20
                }).style("text-anchor", "end");
            }

            if(opts.orientation == "horizontal"){

                var xScale = d3.scale.ordinal().rangeRoundBands([0, height], opts.barWidthRatio || 0.5); // 幅と余白の比率
                xScale.domain(data.map(function (d) {
                    return d.name;
                }));

                if(innerMargin.right > 0){
                    var yScale = d3.scale.linear().domain([0, max * width / (width - innerMargin.right)]).range([0, width]);
                }else{
                    var yScale = d3.scale.linear().domain([0, max]).range([0, width]);
                }

                var xAxis = d3.svg.axis()
                        .scale(xScale)
                        .orient("left")
                        .innerTickSize(0)
                        .outerTickSize(0)
                        .tickPadding(20);

                var yAxis = d3.svg.axis()
                        .scale(yScale)
                        .innerTickSize(opts.showGrid ? -height : 0)
                        .outerTickSize(0)
                        .orient("top")
                        .tickPadding(10);
                if(opts.yFormat){
                    yAxis.tickFormat(opts.yFormat);
                }

                if(opts.showYAxis == undefined || opts.showYAxis){
                    var yAxisObj = base.append("g")
                            .attr("class", "y axis")
                            .call(yAxis);
                }

                if(opts.yTitle){
                    yAxisObj.append("text")
                            .text(opts.yTitle).style("text-anchor", "end")
                            .attr("transform", "translate(0,-10)");
                }

                var tmpTranslate = function(d){
                    return translate(0 , xScale(d.name) + xScale.rangeBand() / 2);
                };
                var bars = base.selectAll(".bar")
                        .data(data)
                        .enter().append("g")
                        .attr("class", "bar").attr("transform", tmpTranslate);

                if(opts.comp){
                    console.log("comp found!");
                    bars.each(function (d) {
                        riot.mount(this, opts.comp, {
                            data: opts.comp == "treemap" ? d : d.data || d.children || d,
                            width: yScale(d.value),
                            height: xScale.rangeBand(),
                            asComp: true,
                            clickEventName: opts.clickEventName,
                            radius: d.radius, // 呼び出し側の責任で用意する
                            orientation: opts.orientation
                        });
                    });
                }else{
                    if(opts.barImg){
                        bars.each(function(d){
                            var selfNode = this;
                            var self = d3.select(this);
                            var barWidth = yScale(d.value);
                            var count = parseInt(barWidth / opts.barImg.slide);
                            if((count - 1) * opts.barImg.slide +  opts.barImg.width > barWidth + opts.barImg.width/2){
                                count--;
                            }
                            if(d.transition){
                                var counter = 0;
                                var timer = setInterval(function(){
                                    self.append("svg:image")
                                            .attr('y', - xScale.rangeBand()/2)
                                            .attr('x', yScale(d.value) + opts.barImg.slide * counter)
                                            .attr('height', xScale.rangeBand())
                                            .attr('width', opts.barImg.width)
                                            .attr("xlink:href", opts.barImg.url);
                                    counter++;
                                    if(counter >= count){
                                        clearTimeout(timer);
                                        self.select("text").attr("visibility","visible");
                                    }
                                }, 1000 / count);
                            }else{
                                for (var i = 0; i < count; i++) {
                                    self.append("svg:image")
                                            .attr('y', - xScale.rangeBand()/2)
                                            .attr('x', yScale(d.value) + opts.barImg.slide * counter)
                                            .attr('height', xScale.rangeBand())
                                            .attr('width', opts.barImg.width)
                                            .attr("xlink:href", opts.barImg.url);
                                }
                            }
                        });
                    }else{
                        var rect = bars.append("rect").attr({
                            y: - xScale.rangeBand() / 2,
                            x: 0,
                            height: xScale.rangeBand(),
                            width: function (d) {
                                return d.transition ? 0 : yScale(d.value);
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
                                return yScale(d.value);
                            },
                        }).each("end", function(d){
                            d3.select(this.parentNode).select("text").attr("visibility","visible");
                        })
                    }
                }

                // draw onBar name
                if(data.filter(function(d){return d.nameOnBar;})){
                    bars.append("text").text(function(d){
                        return opts.nameOnBarFormat ? opts.nameOnBarFormat(d.nameOnBar) : d.nameOnBar;
                    }).attr({
                        x: function(d){ return yScale(d.value); },
                        dx: 10,
                        dy: "0.3em",
                        class: "nameOnBar",
                        visibility: function(d){
                            return d.transition ? "hidden": "visible";
                        },
                        fill: function(d){return d.color || "red";}
                    }).style("text-anchor", "start");
                }

                if(opts.showXAxis == undefined || opts.showXAxis){
                    var xAxisObj = base.append("g")
                            .attr("class", "x axis")
                            .call(xAxis)
                            .selectAll("text")
                            .style("text-anchor", "middle");
                }

                if(opts.xTitle){
                    xAxisObj.append("text").text(opts.xTitle).style("text-anchor", "middle")
                            .attr("transform", "translate(130,40)");
                }
            }else{

                // スケールと出力レンジの定義
                var xScale = d3.scale.ordinal().rangeRoundBands([0, width], opts.barWidthRatio || 0.5); // 幅と余白の比率
                xScale.domain(data.map(function (d) {
                    return d.name;
                }));

                if(innerMargin.top > 0){
                    var yScale = d3.scale.linear().domain([0, max * height / (height - innerMargin.top)]).range([height, 0]);
                }else{
                    var yScale = d3.scale.linear().domain([0, max]).range([height, 0]);
                }

                var xAxis = d3.svg.axis()
                        .scale(xScale)
                        .orient("bottom")
                        .innerTickSize(0)
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

                if(opts.showYAxis == undefined || opts.showYAxis){
                    var yAxisObj = base.append("g")
                            .attr("class", "y axis")
                            .call(yAxis);
                }

                if(opts.yTitle){
                    yAxisObj.append("text")
                            .text(opts.yTitle).style("text-anchor", "end")
                            .attr("transform", "translate(0,-10)");
                }

                var tmpTranslate = function(d){
                    return translate(xScale(d.name)+ xScale.rangeBand() / 2 , yScale(d.value));
                };
                var bars = base.selectAll(".bar")
                        .data(data)
                        .enter().append("g")
                        .attr("class", "bar").attr("transform", tmpTranslate);

                if(opts.comp){
                    console.log("comp found!");
                    bars.each(function (d) {
                        riot.mount(this, opts.comp, {
                            data: opts.comp == "treemap" ? d : d.data || d.children || d,
                            width:xScale.rangeBand(),
                            height: height - yScale(d.value),
                            asComp: true,
                            clickEventName: opts.clickEventName,
                            radius: d.radius, // 呼び出し側の責任で用意する
                            orientation: opts.orientation
                        });
                    });
                }else{
                    if(opts.barImg){
                        bars.each(function(d){
                            var selfNode = this;
                            var self = d3.select(this);
                            var barHeight = height - yScale(d.value);
                            var count = parseInt(barHeight / opts.barImg.slide);
                            if((count - 1) * opts.barImg.slide +  opts.barImg.height > barHeight + opts.barImg.height/2){
                                count--;
                            }
                            if(d.transition){
                                var counter = 0;
                                var timer = setInterval(function(){
                                    self.append("svg:image")
                                            .attr('x', - xScale.rangeBand()/2)
                                            .attr('y', height - yScale(d.value) - opts.barImg.height - opts.barImg.slide * counter)
                                            .attr('width', xScale.rangeBand())
                                            .attr('height', opts.barImg.height)
                                            .attr("xlink:href", opts.barImg.url);
                                    counter++;
                                    if(counter >= count){
                                        clearTimeout(timer);
                                        self.select("text").attr("visibility","visible");
                                    }
                                }, 1000 / count);
                            }else{
                                for (var i = 0; i < count; i++) {
                                    self.append("svg:image")
                                            .attr('x', -xScale.rangeBand() / 2)
                                            .attr('y', height - yScale(d.value) - opts.barImg.height - opts.barImg.slide * i)
                                            .attr('width', xScale.rangeBand())
                                            .attr('height', opts.barImg.height)
                                            .attr("xlink:href", opts.barImg.url);
                                }
                            }
                        });
                    }else{
                        var rect = bars.append("rect").attr({
                            x: - xScale.rangeBand() / 2,
                            y: function (d) {
                                return d.transition ? height - yScale(d.value) : 0;
                            },
                            width: xScale.rangeBand(),
                            height: function (d) {
                                return d.transition ? 0 : height - yScale(d.value);
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
                            y: 0,
                            height: function (d) {
                                return height - yScale(d.value);
                            },
                        }).each("end", function(d){
                            d3.select(this.parentNode).select("text").attr("visibility","visible");
                        })
                    }
                }

                // draw onBar name
                if(data.filter(function(d){return d.nameOnBar;})){
                    bars.append("text").text(function(d){
                        return opts.nameOnBarFormat ? opts.nameOnBarFormat(d.nameOnBar) : d.nameOnBar;
                    }).attr({
                        dy: -20,
                        class: "nameOnBar",
                        visibility: function(d){
                            return d.transition ? "hidden": "visible";
                        },
                        fill: function(d){return d.color || "red";}
                    }).style("text-anchor", "middle");
                }

                if(opts.showXAxis == undefined || opts.showXAxis){
                    var xAxisObj = base.append("g")
                            .attr("class", "x axis")
                            .attr("transform", "translate(0," + height + ")")
                            .call(xAxis)
                            .selectAll("text")
                            .style("text-anchor", "middle");
                }

                if(opts.xTitle){
                    xAxisObj.append("text").text(opts.xTitle).style("text-anchor", "middle")
                            .attr("transform", "translate(130,40)");
                }
            }

        });

    </script>
</bar>