<diff-bar>
    <script>
        this.mixin(RiotD3Mixin);

        this.on("update", function () {
            console.log("diff-bar update!");

            var base = this.base;
            var width = this.width;
            var height = this.height;
            var margin = this.margin;
            var innerMargin = this.innerMargin;

            var data = opts.data;

            // スケールと出力レンジの定義
            var xScale = d3.scale.ordinal().rangeRoundBands([0, width], opts.bandRatio || 0.5); // 幅と余白の比率
            xScale.domain(data.map(function (d) {
                return d.name;
            }));

            var max = d3.max(data.map(function (d) {
                return d.value;
            }));
            if (innerMargin.top > 0) {
                var yScale = d3.scale.linear().domain([0, max * height / (height - innerMargin.top)]).range([height, 0]);
            } else {
                var yScale = d3.scale.linear().domain([0, max]).range([height, 0]);
            }

            // calculate value differences
            var diffs = [0];
            data.reduce(function(a,b){
                diffs.push(b.value - a.value);
                return b
            });
            console.log("diff-bar data:", data);

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
                d.diff = diffs[i];
                d.x = xScale(d.name);
                d.width = xScale.rangeBand();
                d.height = height - yScale(Math.abs(d.diff));
                d.midx = d.x + d.width/2;
                d.y = d.diff >= 0 ? yScale(d.value) : yScale(data[i - 1].value);
                d.top = d.y;
                d.bottom = d.top + d.height;
                console.log("name",d.name);
                console.log("top",d.top);
                console.log("bottom",d.bottom);
                console.log("height",d.height);
                if(i == 0){
                    return;
                }
                var prev = data[i - 1];
                if(diffs[i - 1] >= 0){
                    pathData.push([
                        {x:prev.midx, y:prev.top},
                        {x: d.midx, y:prev.top},
                    ])
                }else{
                    pathData.push([
                        {x:prev.midx, y:prev.bottom},
                        {x: d.midx, y:prev.bottom},
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
            // shrink path to make a space for arrow
            if(opts.arrow){
                data.forEach(function(d,i){
                    if(d.diff > 0){
                        d.top = d.top + Math.min(d.width / 2, d.height - 1);
                    }else{
                        d.bottom = d.bottom - Math.min(d.width / 2, d.height - 1);
                    }
                });
            }
            var bars = base.selectAll("path.diff-bar")
                    .data(data.slice(1))
                    .enter()
                    .append("path").classed("diff-bar", true)
                    .attr("d", function (d) {
                        var lineData = [
                            {x:d.midx, y: d.top},
                            {x:d.midx, y: d.bottom}
                        ];
                        return line(d.diff > 0 ? lineData.reverse() : lineData);
                    })
                    .attr({
                        fill: function (d) {
                            return d.fill || d.color || opts.color || "black";
                        },
                        stroke: function (d) {
                            return d.stroke || opts.color;
                        },
                        "stroke-width": (opts.relativeBandRatio || 1) * xScale.rangeBand()
                    });

            if(opts.arrow){
                var unit = xScale.rangeBand() / 2;
                console.log("0 0 " + unit * 2 + " " + unit * 2);
                var id = new Date().getTime();
                var marker = base.append("defs").append("marker").attr({
                            'id': "arrowhead" + id,
                            markerUnits: "userSpaceOnUse",
                            'refX': 1, // to hide boundary line between body and arrow
                            'refY': unit,
                            'markerWidth': unit,
                            'markerHeight': unit * 2,
                            'orient': "auto"
                        });
                marker.append("path").attr({
                            d: "M 0,0 V " + (unit * 2) + " L " + unit + ","+ unit + " Z",
                            fill: opts.color || "black"
                        });
                bars.attr('marker-end',"url(#arrowhead" + id + ")");
            }

            console.log(pathData);

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
        });

    </script>
</diff-bar>