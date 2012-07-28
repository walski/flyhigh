matchesImageName = (image, imagePath) ->
  imagePath.indexOf(image) == imagePath.length - image.length || imagePath.indexOf("#{image}.jpg") == imagePath.length - "#{image}.jpg".length

immediateRouting = true

Router = Backbone.Router.extend({
  routes: {
    "": "root",
    ":chapter/:image": "image"
  },

  root: ->
    window.lurch.navigation.setChapter(0)
    window.lurch.navigation.setImage(0)
    window.lurch.navigation.reset(immediateRouting)

  image: (chapterName, image) ->
    chapter = window.lurch.chapters[chapterName]
    unless chapter
      console.log('no chapter!', chapterName)
      window.lurch.router.navigate('/')
      return

    i = 0
    for chapterImage in chapter.images
      imageIndex = i if matchesImageName(image, chapterImage.urls.small)
      i++

    unless imageIndex
      console.log('no image!', image)
      window.lurch.router.navigate('/')
      return

    window.lurch.navigation.setChapter(window.lurch.toc.indexOf(chapterName))
    window.lurch.navigation.setImage(imageIndex)
    window.lurch.navigation.reset(true)

  navigateToImage: (chapter, image) ->
    chapterName = window.lurch.toc[chapter]
    imageUrl = window.lurch.chapters[chapterName].images[image].urls.small
    imageName = imageUrl.split(/\//)
    imageName = imageName[imageName.length - 2]
    imageName = imageName.replace(/\.jpg$/, '')
    window.lurch.router.navigate("/#{chapterName}/#{imageName}", trigger: false)
});

window.lurch ||= {}
window.lurch.router = new Router()

$(window).on 'lurch:init', ->
    Backbone.history.start({pushState: false})
    immediateRouting = false