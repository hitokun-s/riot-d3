<donut>
    <script>
        this.mixin(RiotD3Mixin);

        this.on("update", function () {

            var color = d3.scale.category10();

            var base = this.base;
            var width = this.width;
            var height = this.height;
            var margin = this.margin;
            var data = opts.data;
            var metadata = opts.metadata || {};

            var tmp = base.attr("transform").match(/translate\((.*),(.*)\)/);
            var x = ~~tmp[1], y = ~~tmp[2];

            var radius, startAngle, endAngle;
            if(opts.semiCircle){
                radius = Math.min(width / 2, height);
                base.attr("transform", "translate(" + (x + width/2) + "," + ( y + height/2 + radius / 2) + ")");
                startAngle = - Math.PI/2;
                endAngle = Math.PI/2;
            }else{
                radius = Math.min(width, height) / 2;
                base.attr("transform", "translate(" + (x + width/2) + "," + ( y + height/2) + ")");
                startAngle = 0;
                endAngle = Math.PI * 2;
            }

            /**
             * Suppoting 3 data patterns.
             *
             * (Type 1) Simple(Single) Donut
             * [{ name: hoge, value: 100},,,]
             *
             * (Type 2) Multiple Donut with children(break down) data
             * [
             *    {
             *       name: hoge,
             *       value: 100,
             *       children: [
             *          {name: fuga, value: 30},,,
             *       ]
             *    }
             * ]
             *
             * (Type 3) Multiple Donut with different data
             * [
             *    [{ name: hoge, value: 100},,,],
             *    [{ name: hoge, value: 200},,,],,,,
             * ]
             */
            var type = 0;
            if(data[0].length){
                type = 3;
            }else{
                type = data[0].children ? 2 : 1;
            }
            console.log("type", type);

            // if type == 1 or 2, convert data type into type 3
            if(type == 3){
                data.forEach(function(datum){
                    datum.forEach(function(d, i){
                        d.color = d.color || color(i);
                    });
                });
            }else{
                data.forEach(function(d, i){
                    d.color = d.color || color(i);
                });
                var _data = [data];
                if (type == 2) {
                    var tmp = [];
                    data.forEach(function (d){
                        d.children.forEach(function(child){
                            child.color = child.color || d.color;
                            tmp.push(child);
                        });
                    });
                    _data.push(tmp);
                }
                data = _data;
            }

            // cal arcs
            var innerRadius, donutThickness, arcs;
            if(opts.innerRadiusRatio){
                innerRadius = radius * opts.innerRadiusRatio;
                donutThickness = (radius - innerRadius) / data.length;
            }else{
                innerRadius = donutThickness = radius / (data.length + 1);
            }
            arcs = data.map(function(d, i){
                var tmpInnerRadius = innerRadius +  donutThickness * i;
                return d3.svg.arc().outerRadius(tmpInnerRadius + donutThickness).innerRadius(tmpInnerRadius);
            });

            var pie = d3.layout.pie()
                    .startAngle(startAngle).endAngle(endAngle)
                    .value(function (d) {
                        return d.value;
                    }).sort(null);

            data.forEach(function(datum, i){

                var g = base.selectAll(".arc" + i)
                        .data(pie(datum))
                        .enter().append("g")
                        .attr("class", "arc").classed("arc" + i, true);

                g.append("path")
                        .attr("d", arcs[i])
                        .attr("fill", function (d, i) {
                            return d.data.color;
                        }).on("click", function (d) {
                    RiotControl.trigger("donutClicked", d);
                });

                g.append("text")
                        .attr("transform", function (d) {
                            if(opts.labelOutside){
                                d.innerRadius = radius;
                                d.outerRadius = radius + 50;
                                console.log(d);
                                var t = arcs[i].centroid(d);
                                var ratio = (radius + 30) / ((radius + innerRadius) / 2);
                                return translate(t[0] * ratio, t[1] * ratio);
                            } else {
                                d.innerRadius = 0;
                                d.outerRadius = radius;
                                return "translate(" + arcs[i].centroid(d) + ")";
                            }
                        })
                        .attr("dy", ".35em")
                        .style("text-anchor", "middle")
                        .text(function (d, i) {
                            return d.data.name;
                        });
            });
            if(metadata.title){
                base.append("text").text(metadata.title).attr("font-size", "2em").style("text-anchor", "middle");
            }
            if(metadata.titleLeft){
                base.append("text").text(metadata.titleLeft).style("text-anchor", "middle")
                        .attr("transform", translate(-(radius + innerRadius)/2 , 20));
            }
            if(metadata.titleRight){
                base.append("text").text(metadata.titleRight).style("text-anchor", "middle")
                        .attr("transform", translate((radius + innerRadius)/2 , 20));
            }

            // threshold props: ratio, title
            if(opts.threshold){
                var unit = 5;
                var totalAngle = opts.semiCircle ? Math.PI : Math.PI * 2;
                var angle = totalAngle * opts.threshold.ratio;
                var x = (radius + unit * 2) * Math.cos(angle);
                var y = (radius + unit * 2) * Math.sin(angle);
                base.append("text").text(opts.threshold.title)
                        .attr("transform", "translate(" + x + "," + (-y) + ")")
                        .attr("dy", "-5")
                        .style("text-anchor", "middle");
                var line = d3.svg.line()
                        .x(function (d) {return d.x})
                        .y(function (d) {return d.y})
                        .interpolate("cardinal");

                var id = new Date().getTime();
                var marker = base.append("defs").append("marker").attr({
                    'id': "arrowhead" + id,
                    markerUnits: "userSpaceOnUse",
                    'refX': unit * 2, // to hide boundary line between body and arrow
                    'refY': unit,
                    'markerWidth': unit * 2,
                    'markerHeight': unit * 2,
                    'orient': "auto"
                });
//                marker.append("path").attr({
//                    d: "M " + unit * 2 + ",0 V " + (unit * 2) + " L 0" + "," + unit + " Z", // reverse arrow
//                    fill: "black",
//                    visibility:"visible"
//                });

//                base.append("path").attr("d", line([
//                    {x:0, y:0},
//                    {x:x, y:-y}
//                ])).attr({
//                    class: "threshold",
//                    stroke: " black",
//                    visibility:"hidden"
//                }).attr('marker-end',"url(#arrowhead" + id + ")");

                base.append("path").attr({
                    d: "M " + (-unit) + ",0 H " + unit + " L 0" + "," + (unit * 2) + " Z", // reverse arrow
                    fill: "black",
                    transform: "translate(" + x + "," + (-y) + ") rotate(" + (90 - angle * 180 / Math.PI) + ")"
                });
            }

            // ラベルを最前面に（なぜこれでうまくいく？）
            base.selectAll("text").order(function(){
                return true;
            })

            if(opts.callback){
                opts.callback(base);
            }
        });
    </script>
</donut>