_.templateSettings.interpolate = /{{([\s\S]+?)}}/g

# just for prototyping
retrieve = (k) -> JSON.parse localStorage.getItem k
store = (k, v) -> localStorage.setItem k, JSON.stringify v

points = retrieve('points') or []
console.log points

app = angular.module 'app', []

app.controller 'AppCtrl', ($scope) ->
  $scope.r = 32

  $scope.changeEverything = ->
    console.log 'changeEverything'
    d3.selectAll('circle').attr('r', $scope.r)

  # $scope.reposition = (e) ->
  #   cx = e.offsetX
  #   cy = e.offsetY
  #   $('circle').attr {cx, cy}

lastitem = null

app.directive 'enter', ->
  return (scope, element, attrs) ->

    svg = d3.select('svg')
    line = d3.svg.line()

    drawPoint = ({x, y}) ->
      item = svg.append('circle')
        .attr('r', scope.r)
        .attr('cx', x)
        .attr('cy', y)
        .attr('fill', 'steelblue')

    for point in points
      drawPoint point

    element.on 'click', (e) ->
      # console.log 'click'
      # console.log e.target
      if e.target.nodeName is 'circle'
        # alert 'clicked a circle'
        if lastitem
          from = [
            d3.select(lastitem).attr('cx')
            d3.select(lastitem).attr('cy')
          ]
          to = [
            d3.select(e.target).attr('cx')
            d3.select(e.target).attr('cy')
          ]
          console.log 'draw spline from', lastitem, 'to', e.target
          svg.append('path')
            .datum([from, to])
            .attr('d', line)
            .attr('class', 'line')
            # .call(redraw) # need to store these lines in array and replan them
          lastitem = null
        else
          lastitem = e.target
        d3.select(e.target).attr('stroke', 'black')
      else
        # add new point
        lastitem = null
        x = e.offsetX
        y = e.offsetY
        drawPoint {x, y}
        points.push {x, y}
        store 'points', points

      d3.selectAll('circle').on 'mousedown', ->
        console.log 'mousedown'
        item = d3.select(this)

        svg.on 'mousemove', ->
          coord = d3.mouse(element[0])
          offset = (scope.r / 2)
          item.attr 'cx', coord[0] - offset
          item.attr 'cy', coord[1] - offset

        svg.on 'mouseup', (e) ->
          if d3.event
            d3.event.preventDefault()
            d3.event.stopPropagation()
          svg.on 'mousemove', null
          svg.on 'mouseup', null
