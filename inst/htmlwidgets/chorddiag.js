HTMLWidgets.widget({

  name: 'chorddiag',

  type: 'output',

  initialize: function(el, width, height) {
    //return {};

    d3.select(el).append("svg")
        .attr("width", width)
        .attr("height", height)
        .append("g")
        .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

    return d3.layout.chord();
  },

  resize: function(el, width, height, instance) {
    //if (instance.params)
      //this.drawGraphic(el, instance.params, width, height);

    d3.select(el).select("svg")
      .attr("width", width)
      .attr("height", height);

      //chord.size([width, height]).resume();

  },

  renderValue: function(el, params, instance) {

    // save params for reference from resize method
    instance.params = params;

    /*
    // draw the graphic
    this.drawGraphic(el, x, el.offsetWidth, el.offsetHeight);

  },

  drawGraphic: function(el, x, width, height) {
  */

    var matrix = params.matrix,
        options = params.options;

    var groupnames = options.groupnames,
        groupcolors = options.groupcolors,
        tickInterval = options.tickInterval,
        groupnamePadding = options.groupnamePadding

    var chord = d3.layout.chord()
        .padding(.05)
        .sortSubgroups(d3.descending)
        .matrix(matrix);

    var width = 500,
        height = 500,
        innerRadius = Math.min(width, height) * .31,
        outerRadius = innerRadius * 1.1;

    var fill = d3.scale.ordinal()
        .domain(d3.range(matrix.length))
        .range(groupcolors);

    var svg = d3.select(el).selectAll("g");

    svg.append("g").selectAll("path")
        .data(chord.groups)
        .enter().append("path")
        .style("fill", function(d) { return fill(d.index); })
        .style("stroke", function(d) { return fill(d.index); })
        .attr("d", d3.svg.arc().innerRadius(innerRadius).outerRadius(outerRadius))
        .on("mouseover", fade(.1))
        .on("mouseout", fade(1));

    var ticks = svg.append("g").selectAll("g")
        .data(chord.groups)
        .enter().append("g").selectAll("g")
        .data(groupTicks)
        .enter().append("g")
        .attr("transform", function(d) {
          return "rotate(" + (d.angle * 180 / Math.PI - 90) + ")"
              + "translate(" + outerRadius + ",0)";
        });

    ticks.append("line")
        .attr("x1", 1)
        .attr("y1", 0)
        .attr("x2", 5)
        .attr("y2", 0)
        .style("stroke", "#000");

    ticks.append("text")
        .attr("x", 8)
        .attr("dy", ".35em")
        .attr("transform", function(d) { return d.angle > Math.PI ? "rotate(180)translate(-16)" : null; })
        .style("text-anchor", function(d) { return d.angle > Math.PI ? "end" : null; })
        .text(function(d) { return d.label; });

    svg.append("g")
        .attr("class", "chord")
        .selectAll("path")
        .data(chord.chords)
        .enter().append("path")
        .attr("d", d3.svg.chord().radius(innerRadius))
        .style("fill", function(d) { return fill(d.target.index); })
        .style("opacity", 1);

    // Returns an array of tick angles and labels, given a group.
    function groupTicks(d) {
      var k = (d.endAngle - d.startAngle) / d.value;
      return d3.range(0, d.value, tickInterval).map(function(v, i) {
        return {
          angle: v * k + d.startAngle,
          label: i % 5 ? null : v
        };
      });
    }

    // Returns an event handler for fading a given chord group.
    function fade(opacity) {
      return function(g, i) {
        svg.selectAll(".chord path")
            .filter(function(d) { return d.source.index != i && d.target.index != i; })
            .transition()
            .style("opacity", opacity);
      };
    }

    // !!!essai pour ajouter un titre !!! perso
    var noms = svg.append("g").selectAll("g")
        .data(chord.groups)
        .enter().append("g").selectAll("g")
        .data(groupNoms)
        .enter().append("g")
        .attr("transform", function(d) {
          return "rotate(" + (d.angle * 180 / Math.PI - 90) + ")"
              + "translate(" + (outerRadius + groupnamePadding) + ", 0)";
        })

    noms.append("text")
        .attr("x", 25)
        .attr("dy", ".35em")
    	.style("font-size", "18px")
        .attr("transform", function(d) { return d.angle > Math.PI ? "rotate(180)translate(-50)" : null; })
        .style("text-anchor", function(d) { return d.angle > Math.PI ? "end" : null; })
        .text(function(d) { return d.label; })
        .attr("d", arc)
        .on("mouseover", fade(.1))
        .on("mouseout", fade(1));

    function groupNoms(d) {
      return d3.range(0, d.value, 100).map(function(v, i) {	//sais pas comment le faire une seule fois ???
        return {
          angle: (d.startAngle + d.endAngle) / 2,
          label: i ? null : groupnames[d.index]
        };
      });
    }
  }

});

