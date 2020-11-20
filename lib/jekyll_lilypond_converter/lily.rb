module JekyllLilyPondConverter
  class Lily
    attr_reader :snippet

    def initialize(id, extension, snippet)
      @id = id
      @extension = extension
      @snippet = snippet
    end

    def code_filename
      "#{id}.ly"
    end

    def image_filename
      "#{id}.#{extension}"
    end

    def midi_filename
      "#{id}.midi"
    end

    def audio_filename
      "#{id}.wav"
    end

    def image_link
      %(

<div class="music">
  <audio id="#{id}" preload="auto" tabindex="0">
    <source src="/lily_images/#{audio_filename}">
  </audio>
  <div class="score">
    <img src="/lily_images/#{image_filename}" 
         alt="Musical example">
  </div>
</div>
<div role="menubar" class="lilymenu">
  <a onclick="document.getElementById('#{id}').play()">Play audio</a> |
  <a arial-label="Download MIDI file" href="/lily_images/#{midi_filename}">Download MIDI file</a>
</div>\n\n
      )
    end

    def code
      strip_delimiters(snippet)
    end

    private
    attr_reader :id, :extension

    def strip_delimiters(snippet)
      snippet.gsub(/```lilypond\n/, "").gsub(/```\n/, "")
    end
  end
end
