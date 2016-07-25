<treemap>
    <script>
        this.mixin(RiotD3Mixin);
        var color = d3.scale.category20();

        var ancester = function(d, gen){
            switch(gen){
                case 1: return d.parent;
                case 2: return d.parent.parent;
                case 3: return d.parent.parent.parent;
            }
            return null;
        }

        this.on("update", function () {
            console.log("treemap update!");

            var base = this.base;
            var width = this.width;
            var height = this.height;
            var margin = this.margin;
            var innerMargin = this.innerMargin;

            var data = opts.data;
            var metadata = opts.metadata || {};
            var clickEventName = opts.clickEventName || "treemapClicked";

            var showDepth = opts.showDepth || 3; // TODO fix me!
            var clickTargetDepth = opts.clickTargetDepth || 0; // TODO fix me!

            var treemap = d3.layout.treemap().size([width, height]).sticky(false).mode('slice-dice')
                    .children(function (d, depth) {
                        return depth >= showDepth ? null : d.children;
                    });

            // データ形式の想定
//            data = {
//                name: "",
//                children: [
//                    {
//                        name: "right",
//                        children: data.right
//                    },
//                    {
//                        name: "left",
//                        children: data.left
//                    }
//                ]
//            };

            var treemapData = treemap.value(function (d) {
                return d.value;
            }).nodes(data);

            console.log("treemapData", treemapData);

            var boxGroup = base.selectAll("g") //Boxグループを追加
                    .data(treemapData)
                    .enter()
                    .append("g");
            if(opts.asComp){
                boxGroup.attr("transform", "translate(" + (-width/2) + ",0)");
            }
            var box = boxGroup.append('rect')
                    .attr({
                        stroke: "white",
                        "stroke-width": 1
                    })
                    .attr("x", function (d) {
                        return d.x
                    })
                    .attr("y", function (d) {
                        return d.y
                    })
                    .attr("width", function (d) {
                        return d.dx
                    })
                    .attr("height", function (d) {
                        return d.dy
                    })
                    .attr("fill", function(d, i){
                        d.color = d.color || color(i);
                        return d.depth == showDepth ? d.color : "transparent";
                    });
            if(opts.showText){
                boxGroup.append('text').text(function (d) {
                    return d.name;
                })
                        .attr("x", function (d) {
                            return d.x + d.dx / 2;
                        })
                        .attr("y", function (d) {
                            return d.y + d.dy / 2;
                        })
                        //                .attr("font-size", function (d) {
                        //                    var rect_height = d.dy;
                        //                    return Math.min(rect_height, 20);
                        //                })
                        //                .attr("stroke-width", function (d) {
                        //                    var rect_height = d.dy;
                        //                    return rect_height < 20 ? 1 : 2;
                        //                })
                        .attr({
                            fill: "black",
                            "stroke-width": 2,
                            "font-weight": "bold",
                            "font-family": "MS Gothic",
                            "text-anchor": "middle",
                            "dominant-baseline": "middle"
                            //visibility:"hidden"
                        }).attr("writing-mode", function (d) {
                    // 縦にしても横にしても箱に収まらない場合は、文字を非表示にする
                    var bbox = this.getBBox();
                    // chrome: horizontal-tb, vertical-rl
                    // IE : lr, rl, tb の三種類（chromeでも効く）
                    // forefoxでは未実装という話：http://stackoverflow.com/questions/25396685/svg-text-element-property-writing-mode-tb-does-not-work-in-firefox
                    if (bbox.width < d.dx && bbox.height < d.dy) {
                        return "horizontal-tb";
                    }
                    if (bbox.width < d.dy && bbox.height < d.dx) {
                        //return "vertical-rl";
                        return "tb";
                    }
                    this.setAttribute("visibility", "hidden");
                }).attr("fill", function (d) {
                    // show labels only for the last children rect
                    return d.depth == showDepth ? "black" : "transparent";
                });
            }

            // ラベルを最前面に（なぜこれでうまくいく？）
            base.selectAll("text").order(function(){
                return true;
            });

            var mouseout = function(d){
                base.selectAll("rect").filter(function(_d){
                    return _d.depth == showDepth && ancester(_d, showDepth - clickTargetDepth) == d;
                }).attr("fill", function(d){
                    return d.color;
                });
            }

            // move clickable level rects to the front
            boxGroup.sort(function (e1, e2) {
                return e1.depth == clickTargetDepth;
            });
            // and set event to them
            base.selectAll("rect").filter(function(d){
                return d.depth == clickTargetDepth;
            }).on("mouseover", function(d){
                base.selectAll("rect").filter(function(_d){
                    return _d.depth == showDepth && ancester(_d, showDepth - clickTargetDepth) == d;
                }).attr("fill","lightgrey");
            }).on("mouseout", mouseout)
            .on("click", function(d){
                mouseout(d);
                RiotControl.trigger(clickEventName, d, metadata);
            });
        });

    </script>
</treemap>