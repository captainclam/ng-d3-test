(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var app, enter, points, redraw, retrieve, store;

_.templateSettings.interpolate = /{{([\s\S]+?)}}/g;

retrieve = function(k) {
  return JSON.parse(localStorage.getItem(k));
};

store = function(k, v) {
  return localStorage.setItem(k, JSON.stringify(v));
};

points = retrieve('points') || [];

app = angular.module('app', []);

app.controller('AppCtrl', function($scope) {
  $scope.r = retrieve('r') || 32;
  $scope.changeEverything = function() {
    store('r', $scope.r);
    d3.selectAll('circle').attr('r', $scope.r).attr('fill', $scope.color);
    return d3.selectAll('text').style('font-size', $scope.r + 'px').attr('fill', $scope.color);
  };
  return $scope.clearStorage = function() {
    localStorage.removeItem('points');
    points = [];
    d3.selectAll('svg *').remove();
    return redraw();
  };
});

redraw = function() {
  var b, from, line, point, r, svg, to, _i, _len, _results;
  svg = d3.select('svg');
  svg.selectAll('*').remove();
  line = d3.svg.line();
  console.log(points);
  r = retrieve('r');
  svg.selectAll('circle').data(points).enter().append('circle').attr('cx', function(d) {
    return d.x;
  }).attr('cy', function(d) {
    return d.y;
  }).attr('r', function(d) {
    return r;
  }).attr('fill', 'steelblue');
  _results = [];
  for (_i = 0, _len = points.length; _i < _len; _i++) {
    point = points[_i];
    if (point.linkTo) {
      b = _.findWhere(points, {
        id: point.linkTo
      });
      from = [point.x, point.y];
      to = [b.x, b.y];
      _results.push(svg.append('path').datum([from, to]).attr('d', line).attr('class', 'line'));
    } else {
      _results.push(void 0);
    }
  }
  return _results;
};

enter = function(scope, element, attrs) {
  var drawPoint, lastitem, line, svg;
  svg = d3.select('svg');
  line = d3.svg.line();
  lastitem = null;
  drawPoint = function(_arg) {
    var id, item, x, y;
    x = _arg.x, y = _arg.y, id = _arg.id;
    return item = svg.append('circle').attr('r', scope.r).attr('cx', x).attr('cy', y).attr('fill', 'steelblue').datum({
      id: id
    });
  };
  redraw();
  svg.append("text").attr("y", 40).attr("x", 40).attr("dy", ".47em").style("text-anchor", "start").style("fill", "#004669").text("Test Text");
  return element.on('click', function(e) {
    var currentitem, datum, point, x, y;
    console.log('click');
    d3.select(e.target).attr('class', 'selected');
    if (e.target.nodeName === 'circle') {
      if (lastitem) {
        lastitem = d3.select(lastitem);
        currentitem = d3.select(e.target);
        console.log('draw spline from', lastitem, 'to', e.target);
        datum = lastitem.datum();
        point = _.findWhere(points, {
          id: datum.id
        });
        point.linkTo = currentitem.datum().id;
        store('points', points);
        redraw();
        lastitem = null;
      } else {
        lastitem = e.target;
      }
      d3.select(e.target).attr('stroke', 'black');
    } else {
      lastitem = null;
      x = e.offsetX;
      y = e.offsetY;
      point = {
        x: x,
        y: y,
        id: points.length + 1
      };
      drawPoint(point);
      points.push(point);
      store('points', points);
    }
    d3.selectAll('text').on('mousedown', function() {
      var item;
      item = d3.select(this);
      item.attr('class', 'selected');
      svg.on('mousemove', function() {
        var coord;
        coord = d3.mouse(element[0]);
        item.attr('x', coord[0]);
        return item.attr('y', coord[1]);
      });
      return svg.on('mouseup', function(e) {
        svg.on('mousemove', null);
        return svg.on('mouseup', null);
      });
    });
    return d3.selectAll('circle').on('mousedown', function() {
      var item;
      console.log('mousedown');
      item = d3.select(this);
      item.attr('class', 'selected');
      svg.on('mousemove', function() {
        var coord, offset;
        coord = d3.mouse(element[0]);
        offset = scope.r / 2;
        item.attr('cx', coord[0] - offset);
        return item.attr('cy', coord[1] - offset);
      });
      return svg.on('mouseup', function(e) {
        var coord, offset;
        if (d3.event) {
          d3.event.preventDefault();
          d3.event.stopPropagation();
        }
        coord = d3.mouse(element[0]);
        offset = scope.r / 2;
        console.log('mouseup. save pos of', item.datum());
        point = _.findWhere(points, {
          id: item.datum().id
        });
        if (point) {
          point.x = coord[0] - offset;
          point.y = coord[1] - offset;
          store('points', points);
          redraw();
        }
        item.attr('class', '');
        svg.on('mousemove', null);
        return svg.on('mouseup', null);
      });
    });
  });
};

app.directive('enter', function() {
  return enter;
});


},{}]},{},[1]);