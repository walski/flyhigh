window.lurch ||= {}

window.lurch.application = {
  scrollTimeout: null,
  reactToScroll: (e) ->
    window.lurch.navigation.stopScroll()
    clearTimeout(@scrollTimeout) if @scrollTimeout
    @scrollTimeout = setTimeout(window.lurch.navigation.adjustSelection, 100)
}

$ ->
  body = $('body')
  canvas = $('#canvas')
  browserWindow = $(window)
  progressIndicator = $('#progress-indicator')
  imagesShown = false
  minimap = $('#minimap')

  window.lurch.environment = {width: 0, height: 0}

  setupEnvironment = ->
    window.lurch.environment.width = browserWindow.width()
    window.lurch.environment.height = browserWindow.height()

  resizeImages = ->
    setupEnvironment()

    canvas.find('.chapter').height(window.lurch.environment.height).width(window.lurch.environment.width)

  browserResize = ->
    resizeImages()
    window.lurch.navigation.reset()

  hidePreloader = ->
    progressIndicator.fadeOut 300, ->
      progressIndicator.remove()

  showImages = ->
    return if imagesShown
    imagesShown = true

    canvas.width(window.lurch.toc.length * window.lurch.environment.width)
    canvas.height(window.lurch.environment.height)

    $('#logo').show()

    minimapPages = minimap.find('.pages')
    for chapterName in window.lurch.toc
      chapter = window.lurch.chapters[chapterName]
      canvas.append(JST['images/chapter'](images: chapter.images))
      window.lurch.minimap.addPage(chapter.images)

    resizeImages()
    window.lurch.minimap.show()
    setTimeout(hidePreloader, 1000)

  resizePreloader = ->
    preloaderDisplay = progressIndicator.find('.display');
    width = browserWindow.width()
    height = browserWindow.height()
    preloaderDisplay.css(left: (width / 2) - (preloaderDisplay.width() / 2), top: (height / 2) - (preloaderDisplay.height() / 2))
    circle = preloaderDisplay.find('.circle')
    offsetX = width / 2 - circle.width() / 2
    offsetY = height / 2 - circle.height() / 2
    circle.css('background-position-x': offsetX * -1, 'background-position-y': offsetY * -1, 'background-size': '' + width + 'px ' + height + 'px')
    preloaderDisplay

  showPreloader = (images) ->
    browserWindow.resize(resizePreloader)
    resizePreloader().fadeIn()
    progressIndicator.find('a.start').click (e) =>
      e.preventDefault()
      showImages() if progressIndicator.is('.progress-100')

    preLoader = new window.lurch.ImageLoader images, ->
      progressIndicator.attr('class', '').addClass("progress-#{parseInt(@progress * 100)}")

  init = ->
    window.lurch.minimap.init()

    images = []
    for chapterName in window.lurch.toc
      chapter = window.lurch.chapters[chapterName]
      images = images.concat(chapter.images.map (image) -> image.urls.small)
    showPreloader(images)

  browserWindow.resize(browserResize)
  setupEnvironment()
  init()
  browserWindow.trigger('lurch:init')