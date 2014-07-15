_.templateSettings.interpolate = /{{([\s\S]+?)}}/g

# just for prototyping
retrieve = (k) -> JSON.parse localStorage.getItem k
store = (k, v) -> localStorage.setItem k, JSON.stringify v

points = retrieve('points') or []

app = angular.module 'app', []

app.controller 'AppCtrl', ($scope) ->
  $scope.r = retrieve('r') or 32

  $scope.changeEverything = ->
    store 'r', $scope.r
    d3.selectAll('circle').attr('r', $scope.r)

  $scope.clearStorage = ->
    localStorage.removeItem 'points'
    redraw()

redraw = ->
  svg = d3.select('svg')
  line = d3.svg.line()
  console.log points
  r = retrieve 'r' # ugh
  svg.selectAll('circle')
    .data(points)
    .enter()
    .append('circle')
    .attr('cx', (d) -> d.x)
    .attr('cy', (d) -> d.y)
    .attr('r', (d) -> r)
    .attr('fill', 'steelblue')

  for point in points
    # todo: linkTo needs to be an array, because can have multiple links
    if point.linkTo
      b = _.findWhere points, id: point.linkTo
      from = [point.x, point.y]
      to = [b.x, b.y]
      svg.append('path')
        .datum([from, to])
        .attr('d', line)
        .attr('class', 'line')

enter = (scope, element, attrs) ->

  svg = d3.select('svg')
  line = d3.svg.line()

  lastitem = null

  drawPoint = ({x, y, id}) ->
    item = svg.append('circle')
      .attr('r', scope.r)
      .attr('cx', x)
      .attr('cy', y)
      .attr('fill', 'steelblue')
      .datum({id})

  redraw()

  element.on 'click', (e) ->
    # console.log 'click'
    # console.log e.target
    if e.target.nodeName is 'circle'
      # alert 'clicked a circle'
      if lastitem
        lastitem = d3.select(lastitem)
        currentitem = d3.select(e.target)

        console.log 'draw spline from', lastitem, 'to', e.target

        datum = lastitem.datum()
        point = _.findWhere points, id: datum.id
        point.linkTo = currentitem.datum().id
        store 'points', points

        redraw()
        lastitem = null
      else
        lastitem = e.target
      d3.select(e.target).attr('stroke', 'black')
    else
      # add new point
      lastitem = null
      x = e.offsetX
      y = e.offsetY
      point = {x, y, id: points.length+1}
      drawPoint point
      points.push point
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
        # todo: update pos in arr
        if d3.event
          d3.event.preventDefault()
          d3.event.stopPropagation()
        svg.on 'mousemove', null
        svg.on 'mouseup', null


app.directive 'enter', -> enter
