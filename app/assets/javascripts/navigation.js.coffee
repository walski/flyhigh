class Navigation
  @chapter = 0
  @image = 0
  @scrollSpeed = 500

  @setChapter = (chapter) =>
    return false unless chapter >= 0 && chapter < window.lurch.toc.length
    maxImage = window.lurch.chapters.byIndex(chapter).images.length - 1
    @image = maxImage if @image > maxImage
    @chapter = chapter

  @setImage = (image) =>
    return false unless image >= 0 && image < window.lurch.chapters.byIndex(@chapter).images.length

    @image = image

  @stopScroll = =>
    @body().stop(true)

  @loadHDTimeout = null

  @loadHD = =>
    hdUrl = window.lurch.chapters[window.lurch.toc[@chapter]].images[@image].urls.large
    image = $('[data-hd-image-url="' + hdUrl + '"]')
    hdImage = image.find('.hd-image')
    if hdImage.length < 1
      hdImage = $(JST['images/hd'](url: hdUrl))
      image.append(hdImage)
    hdImage.addClass('active')

  @reset = (immediately) =>
    clearTimeout(@loadHDTimeout) if @loadHDTimeout
    $('.hd-image').removeClass('active')

    window.lurch.minimap.activate(@chapter, @image)
    @setChapter(@chapter)
    @setImage(@image)

    @loadHDTimeout = setTimeout(@loadHD, 1000)

    new_x = @chapter * window.lurch.environment.width
    new_y = @image * window.lurch.environment.height

    @body().stop(true)
    if immediately
      @body().scrollLeft(new_x)
      @body().animate({scrollTop: new_y}, duration: @scrollSpeed)
    else
      @body().animate({
        scrollLeft: new_x,
        scrollTop: new_y
      }, duration: @scrollSpeed)

    window.lurch.router.navigateToImage(@chapter, @image)

  @adjustSelection = =>
    return if @scrollLock

    newImage = @imageByScroll()
    @image = newImage if newImage != @image

    newChapter = @chapterByScroll()
    @chapter = newChapter if newChapter != @chapter

    @reset()

  @nextImage = =>
    @setImage(@image + 1)
    @reset()

  @prevImage = =>
    @setImage(@image - 1)
    @reset()

  @nextChapter = =>
    @setChapter(@chapter + 1)
    @reset()

  @prevChapter = =>
    @setChapter(@chapter - 1)
    @reset()

  @imageByScroll = =>
    Math.round(@body().scrollTop() / window.lurch.environment.height)

  @chapterByScroll = =>
    Math.round(@body().scrollLeft() / window.lurch.environment.width)

  @body = =>
    @_body ||= if $.browser.webkit then $('body') else $('html')

window.lurch ||= {}
window.lurch.navigation = Navigation