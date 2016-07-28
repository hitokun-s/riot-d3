<profit-donut>
    <script>
        this.mixin(RiotD3Mixin);

        var color = d3.scale.category10();

        var pie = d3.layout.pie()
                .startAngle(0).endAngle(Math.PI * 2)
                .value(function (d) {
                    return d.value;
                }).sort(null);

        var base = this.base;
        var width = this.width;
        var height = this.height;
        var margin = this.margin;
        var innerMargin = this.innerMargin;

        base.attr("class","profit-donut");

        var oriData = opts.data;
        var arc = d3.svg.arc().outerRadius(opts.radius).innerRadius(opts.radius - 30);

        var red = d3.rgb("lightcoral").toString();
        var blue = d3.rgb("lightblue").darker(0.5).toString();
        var data;
        if(oriData.profit > 0){
            data = [
                {name:"profit", value: oriData.profit, color: blue, year:~~(oriData.name)},
                {name:"", value: oriData.sales - oriData.profit, color:"lightgrey", year:~~(oriData.name)},
            ]
        }else{
            data = [
                {name:"", value: oriData.sales + oriData.profit, color:"lightgrey", year:~~(oriData.name)},
                {name:"profit", value: -oriData.profit, color: red, year:~~(oriData.name)}
            ]
        }

        var g = base.selectAll(".arc")
                .data(pie(data))
                .enter().append("g")
                .attr("class", "arc");

        g.append("path")
                .attr("d", arc)
                .style("opacity", 0)
                .on("click", function(d){
                    RiotControl.trigger("profitDonutClicked", d.data);
                    base.selectAll("path").attr("fill", function(d){
                        return d.data.color;
                    });
                })
                .attr("fill", function (d, i) {
                    return d.data.color;
                }).transition().duration(1000).style("opacity", 1);

        base.append("text").attr("font-size", 40)
                .attr("fill", oriData.profit > 0 ? blue : red)
                .attr("transform", "translate(0," + (-opts.radius - 10) + ")")
                .style("text-anchor", "middle")
                .text(~~(oriData.profit * 100 / oriData.sales) + "%");

        base.on("mouseover", function(){
            base.selectAll("path").attr("fill", "lightblue");
        }).on("mouseout", function(){
            base.selectAll("path").attr("fill", function(d){
                return d.data.color;
            });
        });
    </script>
</profit-donut>