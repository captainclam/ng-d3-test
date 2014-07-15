_.templateSettings.interpolate = /{{([\s\S]+?)}}/g

app = angular.module 'app', []

app.controller 'AppCtrl', ($scope) ->
  $scope.r = 64

  $scope.changeEverything = ->
    console.log 'changeEverything'
    d3.select('circle').attr('r', $scope.r)

  # $scope.reposition = (e) ->
  #   cx = e.offsetX
  #   cy = e.offsetY
  #   $('circle').attr {cx, cy}

lastitem = null

app.directive 'enter', ->
  return (scope, element, attrs) ->

    svg = d3.select('svg')
    line = d3.svg.line()

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
            # .call(redraw)
          lastitem = null
        else
          lastitem = e.target
        d3.select(e.target).attr('stroke', 'black')
      else
        x = e.offsetX
        y = e.offsetY
        item = svg.append('circle')
          .attr('r', scope.r)
          .attr('cx', x)
          .attr('cy', y)
          .attr('fill', 'steelblue')

      # d3.selectAll('circle').on 'mousedown', ->
      #   console.log 'mousedown'
      #   item = d3.select(this)

      #   svg.on 'mousemove', ->
      #     coord = d3.mouse(element[0])
      #     offset = (scope.r / 2)
      #     item.attr 'cx', coord[0] - offset
      #     item.attr 'cy', coord[1] - offset

      #   svg.on 'mouseup', (e) ->
      #     d3.event.stopPropagation()
      #     svg.on 'mousemove', null
      #     svg.on 'mouseup', null

      #   svg.on 'click', (e) ->
      #     d3.event.stopPropagation()
      #     svg.on 'mousemove', null
      #     svg.on 'mouseup', null


# if d3.event
#   d3.event.preventDefault()
#   d3.event.stopPropagation()
