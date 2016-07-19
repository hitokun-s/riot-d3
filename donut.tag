<donut>
    <script>
        this.mixin(RiotD3Mixin);

        this.on("update", function () {

            var color = d3.scale.category10();

            var base = this.base;
            var width = this.width;
            var height = this.height;
            var margin = this.margin;
            var radius = Math.min(width, height) / 2;
            var data = opts.data;
            var metadata = opts.metadata || {};

            var tmp = base.attr("transform").match(/translate\((.*),(.*)\)/);
            var x = ~~tmp[1], y = ~~tmp[2];
            base.attr("transform", "translate(" + (x + radius) + "," + ( y + radius) + ")");

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
                        d.color = color(i);
                    });
                });
            }else{
                data.forEach(function(d, i){
                    d.color = color(i);
                });
                var _data = [data];
                if (type == 2) {
                    var tmp = [];
                    data.forEach(function (d){
                        d.children.forEach(function(child){
                            child.color = d.color;
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
                    .startAngle(0).endAngle(Math.PI * 2)
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
                            d.innerRadius = 0;
                            d.outerRadius = radius;
                            return "translate(" + arcs[i].centroid(d) + ")";
                        })
                        .attr("dy", ".35em")
                        .style("text-anchor", "middle")
                        .text(function (d, i) {
                            return d.data.name;
                        });
            });
            if(metadata.title){
                base.append("text").text(metadata.title).style("text-anchor", "middle");
            }
        });
    </script>
</donut>