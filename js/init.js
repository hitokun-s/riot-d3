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
        if(["svg","g"].indexOf(this.root.tagName.toLowerCase()) < 0){ // I must own root svg! Not a child of any other svg element.
            this.base = this.base.append("svg").attr({
                width: opts.width,
                height: opts.height
            }).append("g").attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")");
        }
        this.base.classed("base", true);

        this.width = width - (this.margin.left + this.margin.right); // inner width
        this.height = height - (this.margin.top + this.margin.bottom); // inner height
    },
};

var getTranslate = function(translateStr){
    var tmp = translateStr.match(/translate\((.*),(.*)\)/);
    return {x : ~~tmp[1], y : ~~tmp[2]};
}

var translate = function(x, y){
    return "translate(" + x + "," + y + ")";
}

var sum = function(data, prop){
    var total = 0;
    data.forEach(function(d){
        total = total + d[prop];
    });
    return total;
}

// from https://github.com/substack/point-in-polygon
var pointInPolygon = function (point, vs) {
    // ray-casting algorithm based on
    // http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
    var xi, xj, i, intersect,
        x = point[0],
        y = point[1],
        inside = false;
    for (var i = 0, j = vs.length - 1; i < vs.length; j = i++) {
        xi = vs[i][0],
            yi = vs[i][1],
            xj = vs[j][0],
            yj = vs[j][1],
            intersect = ((yi > y) != (yj > y))
                && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
        if (intersect) inside = !inside;
    }
    return inside;
}

// valueもしくはdiffをもつデータを受け取って、floatingデータ（bottom, top）を計算付加して返す
// 1番目のデータは、valueを持つ必要がある。
var addFloating = function(data){
    data[0].bottom = 0;
    data[0].top = data[0].value;
    data[0].main = data[0].top;
    data.reduce(function(a,b){
        if(b.diff){
            if(b.diff >= 0){
                b.top = a.main + b.diff;
                b.bottom = a.main;
                b.main = b.top;
            }else{
                b.top = a.main;
                b.bottom = a.main + b.diff;
                b.main = b.bottom;
            }
        }
        if(b.value){
            b.top = b.value;
            b.bottom = 0;
            b.main = b.top;
        }
        return b;
    });
    return data;
}
