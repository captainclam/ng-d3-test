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

    d3.selectAll('circle')
      .attr('r', $scope.r)
      .attr('fill', $scope.color)

    d3.selectAll('text')
      .style('font-size', $scope.r + 'px')
      .attr('fill', $scope.color)

  $scope.clearStorage = ->
    localStorage.removeItem 'points'
    points = []
    d3.selectAll('svg *').remove()
    redraw()

redraw = ->
  svg = d3.select('svg')
  svg.selectAll('*').remove()
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

  svg.append("text")
    .attr("y", 40)
    .attr("x", 40)
    .attr("dy", ".47em")                        
    .style("text-anchor", "start")
    .style("fill", "#004669")
    .text("Test Text");

  element.on 'click', (e) ->
    console.log 'click'
    # console.log e.target
    d3.select(e.target).attr('class', 'selected')
    
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


    d3.selectAll('text').on 'mousedown', ->
      item = d3.select(this)
      item.attr('class', 'selected')

      svg.on 'mousemove', ->
        coord = d3.mouse(element[0])
        item.attr 'x', coord[0]
        item.attr 'y', coord[1]

      svg.on 'mouseup', (e) ->
        svg.on 'mousemove', null
        svg.on 'mouseup', null

    d3.selectAll('circle').on 'mousedown', ->
      console.log 'mousedown'
      item = d3.select(this)
      item.attr('class', 'selected')

      svg.on 'mousemove', ->
        coord = d3.mouse(element[0])
        offset = (scope.r / 2)
        item.attr 'cx', coord[0] - offset
        item.attr 'cy', coord[1] - offset

      svg.on 'mouseup', (e) ->
        if d3.event
          d3.event.preventDefault()
          d3.event.stopPropagation()

        coord = d3.mouse(element[0])
        offset = (scope.r / 2)
        console.log 'mouseup. save pos of', item.datum()
        point = _.findWhere points, id: item.datum().id
        if point
          point.x = coord[0] - offset
          point.y = coord[1] - offset
          store 'points', points
          redraw()

        item.attr('class', '')

        svg.on 'mousemove', null
        svg.on 'mouseup', null


app.directive 'enter', -> enter
