require 'fileutils'
require 'tmpdir'

def photo_dir
  File.expand_path('../../../tmp/photos', __FILE__)
end

def photos_for(chapter)
  base_path = File.expand_path("./#{chapter}", photo_dir)
  Dir[File.expand_path("./*.jpg", base_path)]
end

def generate_toc
  Dir[File.expand_path('./*', photo_dir)].map do |path|
    File.directory?(path) ? File.basename(path) : nil
  end.compact
end

def generate_chapter(name)
  {
    title:  get_chapter_name(name),
    images: get_chapter_images(name)
  }
end

def get_chapter_name(name)
  name
end

def get_chapter_images(name)
  photos_for(name).map do |photo|
    photo = photo.gsub(/^.*\/photos\//, '')
    file = "/assets/photos/#{photo}"

    urls = {
      original: "#{file}/original.jpg"
    }
    VARIANTS.each {|variant, resolution| urls[variant] = "#{file}/#{variant}.jpg"}

    {
      urls: urls
    }
  end
end

def image_target_path
  target_path = File.expand_path('../../../app/assets/images/photos', __FILE__)
end

def data_target_path
  target_path = File.expand_path('../../../app/assets/javascripts/data.js.coffee', __FILE__)
end

VARIANTS = {
  small:  [638, 384],
  medium: [1366, 768],
  large:  [1920, 1080]
}

namespace :lurch do
  task :process_photos do
    FileUtils.rm_r(image_target_path, force: true, secure: true)

    generate_toc.each do |chapter|
      photos_for(chapter).each do |photo_source|
        photo_target = File.expand_path("./#{photo_source.gsub(/^.*\/tmp\/photos\//, '/')}", image_target_path)
        FileUtils.mkdir_p(photo_target)
        target_file = File.expand_path('./original.jpg', photo_target)
        FileUtils.copy(photo_source, target_file)
        ImageScience.with_image(target_file) do |img|
          VARIANTS.each do |variant, resolution|
            img.resize(resolution.first, resolution.last) do |img2|
              img2.save File.expand_path("./#{variant}.jpg", photo_target)
            end
          end
        end
      end
    end

    curtain_source = File.expand_path('./curtain.jpg', photo_dir)
    curtain_target = File.expand_path('./curtain.jpg', image_target_path)
    FileUtils.copy(curtain_source, curtain_target)
  end

  task :generate_data_file do
    toc = generate_toc

    chapters = {}
    toc.each do |chapter|
      chapters[chapter] = generate_chapter(chapter)
    end

    File.open(data_target_path, 'w') do |file|
      file.puts "window.lurch ||= {}"
      file.puts "window.lurch.toc = #{JSON.pretty_generate(toc)}"
      file.puts "window.lurch.chapters = #{JSON.pretty_generate(chapters)}"
      file.puts "window.lurch.chapters.byIndex = (index) -> window.lurch.chapters[window.lurch.toc[index]]"
    end
  end

  task :cleanup do
    FileUtils.rm_r(image_target_path, force: true, secure: true)
    FileUtils.rm(data_target_path)
  end

  task :generate => [:process_photos, :generate_data_file] do
    Rake::Task['rails_static:delete_block_file'].invoke
    Rake::Task['rails_static:generate'].invoke
    Rake::Task['lurch:cleanup'].invoke
  end

  desc "Deploy the page to GitHub pages"
  task :deploy => :generate do
    Dir.mktmpdir do |deploy_dir|
      FileUtils.cp_r(File.expand_path('./.git', Rails.root), File.expand_path('./.git', deploy_dir))

      cd deploy_dir do
        `git co gh-pages`
        `git filter-branch -f --index-filter "git rm -rf --cached --ignore-unmatch -f *" HEAD`
        `rm -rf *`
        Dir[File.expand_path('./tmp/rails_static/*', Rails.root)].each do |file|
          FileUtils.cp_r(file, deploy_dir)
        end
        FileUtils.copy(File.expand_path('./tmp/photos/CNAME', Rails.root), deploy_dir)
        `git add .`
        message = "Site updated at #{Time.now.utc}"
        `git commit -m \"#{message}\"`
        `git push origin gh-pages --force`
      end
    end
  end

  desc "Start a live server for development"
  task :live => :generate_data_file do
    Signal.trap("INT")  { Rake::Task['lurch:cleanup'].invoke; exit }
    ENV['LURCHLIVE'] = 'true'
    `bundle exec rails server`
  end
end