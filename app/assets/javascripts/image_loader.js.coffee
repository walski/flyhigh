class ImageLoader
  constructor: (@images, @progress_callback) ->
    @loaded = []
    @loader = new PreloadJS()

    @loader.onProgress = @progress_callback
    @loader.onError = (e) ->
      console.log("An error occured while loading this website. Please try again later.") if console.log

    @loader.setMaxConnections(5);
    @loader.loadManifest @images

window.lurch ||= {}
window.lurch.ImageLoader = ImageLoader