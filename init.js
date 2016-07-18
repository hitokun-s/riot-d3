var RiotD3Mixin = {
    init: function () {

        console.log("riot d3 init");
        
        var opts = this.opts;

        opts.xAxis = opts.xAxis == undefined ? true : opts.xAxis;
        opts.yAxis = opts.yAxis == undefined ? true : opts.yAxis;

        var margin = opts.margin || {};
        this.margin = {
            top: margin.top || 0,
            right: margin.right || 0,
            bottom: margin.bottom || 0,
            left: margin.left || 0
        };
        var width = opts.width;
        var height = opts.height;

        var innerMargin = opts.innerMargin || {};
        this.innerMargin = {
            top: innerMargin.top || 0,
            right: innerMargin.right || 0,
            bottom: innerMargin.bottom || 0,
            left: innerMargin.left || 0
        };

        this.base = d3.select(this.root);
        if(["svg","g"].indexOf(this.root.tagName.toLowerCase()) < 0){ // I have root svg! Not a child of any other svg element.
            this.base = this.base.append("svg").attr({
                width: opts.width,
                height: opts.height
            }).append("g").attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")");
        }
        this.base.classed("base", true);

        this.width = width - (this.margin.left + this.margin.right); // inner width
        this.height = height - (this.margin.top + this.margin.bottom); // inner height
    }
};

