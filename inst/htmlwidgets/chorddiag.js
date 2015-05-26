HTMLWidgets.widget({

  name: 'chorddiag',
  type: 'output',

  initialize: function(el, width, height) {

    d3.select(el).append("svg")
                 .attr("width", width)
                 .attr("height", height);

    return d3.layout.chord();

  },

  resize: function(el, width, height, chord) {

    d3.select(el).select("svg")
                 .attr("width", width)
                 .attr("height", height);

    this.renderValue(el, chord.params, chord);

  },

  renderValue: function(el, params, chord) {

    // save params for reference from resize method
    chord.params = params;

    var matrix = params.matrix,
        options = params.options;

    // get width and height, calculate min for use in diagram size
    var width = el.offsetWidth,
        height = el.offsetHeight,
        d = Math.min(width, height);

    var margin = options.margin,
        groupNames = options.groupNames,
        groupColors = options.groupColors,
        groupThickness = options.groupThickness,
        groupPadding = options.groupPadding,
        groupnamePadding = options.groupnamePadding,
        groupnameFontsize = options.groupnameFontsize,
        groupedgeColor = options.groupedgeColor,
        chordedgeColor = options.chordedgeColor,
        showTicks = options.showTicks,
        tickInterval = options.tickInterval,
        ticklabelFontsize = options.ticklabelFontsize,
        showTooltips = options.showTooltips,
        tooltipUnit = options.tooltipUnit,
        tooltipTo = options.tooltipTo,
        tooltipFro = options.tooltipFro
        precision = options.precision;

    d3.select(el).selectAll("div.d3-tip").remove();

    if (showTooltips) {
        var chordTip = d3.tip()
                         .attr('class', 'd3-tip')
                         .direction('ne')
                         .offset([0, 0])
                         .html(function(d) {
                             // indexes
                             var i = d.source.index,
                                 j = d.target.index;
                             // values
                             var vij = matrix[i][j].toFixed(precision),
                                 vji = matrix[j][i].toFixed(precision);
                             var dir1 = groupNames[i] + tooltipTo + groupNames[j] + ": " + vij + tooltipUnit,
                                 dir2 = groupNames[j] + tooltipFro + groupNames[i] + ": " + vji + tooltipUnit;
                             return dir1 + "</br>" + dir2;
                         });

        var groupTip = d3.tip()
                         .attr('class', 'd3-tip')
                         .html(function(d) {
                             var value = d.value.toFixed(precision);
                             return groupNames[d.index] + " (total): " + value + tooltipUnit;
                         });
    }

    var svgContainer = d3.select(el).select("svg");
    svgContainer.selectAll("*").remove();

    // apply chord settings and data
    chord.padding(groupPadding)
         .sortSubgroups(d3.descending)
         .matrix(matrix);

    // calculate outer and inner radius for chord diagram
    var outerRadius = (d - 2 * margin) / 2,
        innerRadius = outerRadius * (1 - groupThickness);

    // create ordinal color fill scale from groupColors
    var fillScale = d3.scale.ordinal()
                            .domain(d3.range(matrix.length))
                            .range(groupColors);

    // calculate horizontal and vertical translation values
    var xTranslate = Math.max(width / 2, outerRadius + margin),
        yTranslate = Math.max(height / 2, outerRadius + margin);

    var svg = svgContainer.append("g");
    svg.attr("transform", "translate(" + xTranslate + "," + yTranslate + ")")

    if (showTooltips) {
       svg.call(chordTip)
          .call(groupTip);
    }

    // create groups
    var groups = svg.append("g").attr("class", "group")
                                .selectAll("path")
                                .data(chord.groups)
                                .enter().append("path");

    // style groups and define mouse events
    groups.style("fill", function(d) { return fillScale(d.index); })
          .style("stroke", function(d) { return fillScale(d.index); })
          .attr("d", d3.svg.arc().innerRadius(innerRadius).outerRadius(outerRadius))
          .on("mouseover", function(d) {
              if (showTooltips) return groupTip.show(d);
          })
          .on("mouseout", function(d) {
              if (showTooltips) return groupTip.hide(d);
          });

    if (groupedgeColor) {
        groups.style("stroke", groupedgeColor);
    } else {
        groups.style("stroke", function(d) { return fillScale(d.index); });
    }

    if (showTicks) {
        // create ticks for groups
        var ticks = svg.append("g").attr("class", "tick").selectAll("g")
            .data(chord.groups)
            .enter().append("g").selectAll("g")
            .data(groupTicks)
            .enter().append("g")
            .attr("transform", function(d) {
                return "rotate(" + (d.angle * 180 / Math.PI - 90) + ")"
                     + "translate(" + outerRadius + ", 0)";
                });

        // add tick marks
        ticks.append("line")
             .attr("x1", 1)
             .attr("y1", 0)
             .attr("x2", 5)
             .attr("y2", 0)
             .style("stroke", "#000");

        // add tick labels
        ticks.append("text")
             .attr("x", 8)
             .attr("dy", ".35em")
             .style("font-size", ticklabelFontsize + "px")
             //.style("font-family", "sans-serif")
             .attr("transform", function(d) { return d.angle > Math.PI ? "rotate(180)translate(-16)" : null; })
             .style("text-anchor", function(d) { return d.angle > Math.PI ? "end" : null; })
             .text(function(d) { return d.label; });
    }

    // create chords
    var chords = svg.append("g").attr("class", "chord")
                    .selectAll("path")
                    .data(chord.chords)
                    .enter().append("path")
                    .attr("d", d3.svg.chord().radius(innerRadius));

    // style chords and define mouse events
    chords.style("fill", function(d) { return fillScale(d.target.index); })
          .style("stroke", chordedgeColor)
          .style("fill-opacity", 0.67)
          .style("stroke-width", "0.5px")
          .style("opacity", 1)
          .on("mouseover", function(d) {
              if (showTooltips) return chordTip.show(d);
          }) //fade2(0.1))
          .on("mouseout", function(d) {
              if (showTooltips) return chordTip.hide(d);
          }); //fade2(1));

    // create group labels
    var names = svg.append("g").attr("class", "name").selectAll("g")
                   .data(chord.groups)
                   .enter().append("g")
                   .on("mouseover", fade(0.1))
                   .on("mouseout", fade(1))
                   .selectAll("g")
                   .data(groupLabels)
                   .enter().append("g")
                   .attr("transform", function(d) {
                       return "rotate(" + (d.angle * 180 / Math.PI - 90) + ")"
                            + "translate(" + (outerRadius + groupnamePadding) + ", 0)";
                       });
    names.append("text")
        .attr("x", 25)
        .attr("dy", ".35em")
        .style("font-size", groupnameFontsize + "px")
        //.style("font-family", "sans-serif")
        .attr("transform", function(d) { return d.angle > Math.PI ? "rotate(180)translate(-50)" : null; })
        .style("text-anchor", function(d) { return d.angle > Math.PI ? "end" : null; })
        .text(function(d) { return d.label; })
        .attr("id", function(d) { return d.label; });

    // returns an array of tick angles and labels, given a group
    function groupTicks(d) {
      var k = (d.endAngle - d.startAngle) / d.value;
      return d3.range(0, d.value, tickInterval).map(function(v, i) {
        return {
          angle: v * k + d.startAngle,
          label: i % 5 ? null : v
        };
      });
    }

    function groupLabels(d) {
      return d3.range(0, d.value, 100).map(function(v, i) {
        return {
          angle: (d.startAngle + d.endAngle) / 2,
          label: i ? null : groupNames[d.index]
        };
      });
    }

    // returns an event handler for fading all chords not belonging to a
    // specific group
    function fade(opacity) {
      return function(g, i) {
        svg.selectAll(".chord path")
            .filter(function(d) { return d.source.index != i
                                      && d.target.index != i; })
            .transition()
            .style("opacity", opacity)
      };
    }

    // returns an event handler for fading all chords except for the one
    // given
    function fade2(opacity) {
      return function(g, i) {
        svg.selectAll(".chord path")
            .filter(function(d) { return d.source.index != g.source.index
                                      || d.target.index != g.target.index;
            })
            .transition()
            .style("opacity", opacity);
      };
    }

  }  // end renderValue function

});

