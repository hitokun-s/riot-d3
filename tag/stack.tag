<stack>
    <script>
        this.mixin(RiotD3Mixin);

        var color = d3.scale.category10();

        this.on("update", function () {
            console.log("stack update!");

            var base = this.base;
            var width = this.width;
            var height = this.height;
            var margin = this.margin;
            var innerMargin = this.innerMargin;

            base.classed("stack", true);

            var data = opts.data;

            if(opts.orientation == "horizontal"){
                var r = width / sum(data, "value");
                var stackWidth = 0;
                data.forEach(function(d,i){
                    d.width = r * d.value;
                    d.x = stackWidth;
                    stackWidth += d.width;
                });
                var g = base.selectAll("rect")
                        .data(data)
                        .enter()
                        .append("rect").attr({
                            fill: function (d, i) {
                                return color(i);
                            },
                            y: -height / 2,
                            x: function (d, i) {
                                return d.x;
                            },
                            height: height,
                            width: function (d) {
                                return d.width;
                            }
                        })
            }else{
                var r = height / sum(data, "value");
                var stackHeight = height;
                data.forEach(function(d,i){
                    d.height = r * d.value;
                    stackHeight -= d.height;
                    d.y = stackHeight;
                });
                var g = base.selectAll("rect")
                        .data(data)
                        .enter()
                        .append("rect").attr({
                            fill: function (d, i) {
                                return color(i);
                            },
                            x: -width / 2,
                            y: function (d, i) {
                                return d.y;
                            },
                            width: width,
                            height: function (d) {
                                return d.height;
                            }
                        })
            }
        });

    </script>
</stack>