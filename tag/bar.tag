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

            // スケールと出力レンジの定義
            var xScale = d3.scale.ordinal().rangeRoundBands([0, width], 0.5); // 幅と余白の比率
            xScale.domain(data.map(function (d) {
                return d.name;
            }));

            var max = opts.max || d3.max(data.map(function (d) {
                return d.value;
            }));
            if(innerMargin.top > 0){
                var yScale = d3.scale.linear().domain([0, max * height / (height - innerMargin.top)]).range([height, 0]);
            }else{
                var yScale = d3.scale.linear().domain([0, max]).range([height, 0]);
            }

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

            var bars;
            var tmpTranslate = function(d){
                return translate(xScale(d.name)+ xScale.rangeBand() / 2 , yScale(d.value));
            };
            if(opts.comp){
                console.log("comp found!");
                bars = base.selectAll(".bar")
                        .data(data)
                        .enter().append("g")
                        .attr("class", "bar")
                        .attr("transform", tmpTranslate)
                        .each(function (d) {
                            riot.mount(this, opts.comp, {
                                data: d,
                                width:xScale.rangeBand(),
                                height: height - yScale(d.value),
                                radius: d.radius // 呼び出し側の責任で用意する
                            });
                        });
            }else{
                if(opts.barImg){
                    bars = base.selectAll(".bar-img").data(data).enter().append("g").attr({
                        class: "bar-img",
                        transform: tmpTranslate
                    }).each(function(d){
                        var self = d3.select(this);
                        var barHeight = height - yScale(d.value);
                        var count = parseInt(barHeight / opts.barImg.slide);
//                        console.log(count);
//                        console.log("barHeight", barHeight);
//                        console.log("count * opts.barImg.slide +  opts.barImg.height", count * opts.barImg.slide +  opts.barImg.height);
//                        console.log("barHeight + opts.barImg.height/2", barHeight + opts.barImg.height/2);
//                        console.log((count - 1) * opts.barImg.slide +  opts.barImg.height > barHeight + opts.barImg.height/2);
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
                    bars = base.selectAll(".bar")
                            .data(data)
                            .enter().append("rect")
                            .attr("class", "bar")
                            .attr({
                                x: function (d) {
                                    return xScale(d.name);
                                },
                                y: function (d) {
                                    return d.transition ?  height : yScale(d.value);
                                },
                                fill:function(d){
                                    return d.fill || d.color || opts.color ||"black";
                                },
                                stroke: function(d){return d.stroke}
                            })
                            .attr("width", xScale.rangeBand())
                            .attr("height", function (d) {
                                return d.transition ? 0 : height - yScale(d.value);
                            });
                    bars.filter(function(d){
                                return d.transition;
                            }).transition().duration(1000).attr({
                                y: function (d) {
                                    return yScale(d.value);
                                },
                                height: function (d) {
                                    return height - yScale(d.value);
                                },
                            });
                }
            }
            // draw onBar name
            if(data.filter(function(d){return d.nameOnBar;})){
                bars.append("text").text(function(d){
                    return opts.nameOnBarFormat ? opts.nameOnBarFormat(d.nameOnBar) : d.nameOnBar;
                }).attr({
                    dy: -20,
                    class: "nameOnBar"
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
        });

    </script>
</bar>