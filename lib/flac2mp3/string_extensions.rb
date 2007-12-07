module Flac2mp3
  module StringExtensions
    def safequote
      gsub(/(\W)/, '\\\\\1')
    end
  end
end
