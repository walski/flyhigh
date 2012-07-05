class PlaygroundController < ApplicationController
  def index
  end

  def dynamicimage
    filename = File.expand_path("./tmp/photos/#{params[:set]}/#{params[:image]}.jpg", Rails.root)
    send_file(filename,
      :filename      =>  "#{params[:image]}.jpg",
      :type          =>  'image/jpeg',
      :disposition  =>  'inline',
      :buffer_size  =>  '4096')
  end

  def curtain
    filename = File.expand_path("./tmp/photos/curtain.jpg", Rails.root)
    send_file(filename,
      :filename      =>  "curtain.jpg",
      :type          =>  'image/jpeg',
      :disposition  =>  'inline',
      :buffer_size  =>  '4096')
  end
end