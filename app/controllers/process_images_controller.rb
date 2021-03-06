class ProcessImagesController < ApplicationController

  def create
    processing_starting_time = Time.now

    data_url = params['base64'];
    data_url = remove_mime_type(data_url);

    image = MiniMagick::Image.read(Base64.decode64(data_url))
    image.format 'png'

    image.combine_options do |i|
      # i.channel "A"
      # i.blur "0x3"
      # i.channel "RGB"
      # i.blur "0x3"

      i.colorspace "Gray"
    end

    file_content = open(image.path) { |f| f.read }
    payload = {"base64": Base64.strict_encode64(file_content)}

    while (Time.now - processing_starting_time).to_f * 1000 < params['minimum_process_time'].to_f
    end

    render json: payload
  end

  private
    def remove_mime_type data
      start = data.index ';base64,'
      if start
        data[(start+8)..-1]
      else
        data
      end
    end
end
