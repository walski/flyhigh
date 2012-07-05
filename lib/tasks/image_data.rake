require 'json'

task :image_data do
  photo_base_folder = File.expand_path('../../../app/assets/images/photos/*', __FILE__)
  photo_folders = Dir[photo_base_folder]

  assets_base_path = '/assets/photos/'

  chapters = {}
  photo_folders.each do |folder|
    chapter_name = File.basename(folder)
    images = Dir[File.expand_path('./*.jpg', folder)].map do |photo|
      {url: File.expand_path("./#{chapter_name}/#{File.basename(photo)}", assets_base_path)}
    end

    chapters[chapter_name] = {
      title: chapter_name,
      images: images
    }
  end

  result =  "window.lurch ||= {}"
  result << "\n\n"
  result << "window.lurch.toc = "
  result << JSON.pretty_generate(chapters.keys)
  result << "\n\n"
  result << "window.lurch.chapters = "
  result << JSON.pretty_generate(chapters)

  result.gsub!(/\}\s+\}$/m, "},\n")
  result << "\n"
  result << "  byIndex: (index) ->\n"
  result << "    window.lurch.chapters[window.lurch.toc[index]]\n"
  result << "}"

  puts result
end