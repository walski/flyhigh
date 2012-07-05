$ ->
  navigation = window.lurch.navigation;
  key('down, space',  -> navigation.nextImage() and false);
  key('up',           -> navigation.prevImage() and false);
  key('right',        -> navigation.nextChapter() and false);
  key('left',         -> navigation.prevChapter() and false);

  browserWindow = $(window)
  browserWindow.on 'mousewheel', window.lurch.application.reactToScroll
  browserWindow.on 'DOMMouseScroll', window.lurch.application.reactToScroll

  $('#canvas').on "click", ".chapter .image", (e) ->
    e.preventDefault()
    navigation.nextImage()