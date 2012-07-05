window.lurch ||= {}

class Minimap
  init: ->
    @map = $('#minimap')
    @pages = @map.find('.pages')
    @initialFadeOver = false
  show: (speed = 2000) ->
    @map.fadeIn speed, =>
      @initialFadeOver = true
    @map.width(@pages.width() + 10)
    @map.height(@pages.height())
  hide: =>
    @map.fadeOut 500
  addPage: (images) ->
    @pages.append(JST['minimap/page'](images: images))
  activate: (page, image) ->
    @show(200) if @initialFadeOver
    clearTimeout(@hideTimeout) if @hideTimeout
    @hideTimeout = setTimeout(@hide, 4000)

    @pages.find('.active').removeClass('active')
    @pages.find('.page:nth-child(' + (page + 1) + ') li:nth-child(' + (image + 1) + ')').addClass('active')

window.lurch.minimap = new Minimap