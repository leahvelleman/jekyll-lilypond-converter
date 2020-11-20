module JekyllLilyPondConverter
  class Handler
    def initialize(content:, naming_policy:, image_format:, site_manager:, static_file_builder:)
      @content = content
      @naming_policy = naming_policy
      @image_format = image_format
      @site_manager = site_manager
      @static_file_builder = static_file_builder
    end

    def execute
      ensure_valid_image_format

      lilies.each do |lily|
        unless File.exist?("lily_images/" + lily.image_filename)
          puts("Regenerating #{lily.code_filename}")
          write_lily_code_file(lily)
          generate_lily_image(lily)
        end
        add_lily_image_to_site(lily)
        replace_snippet_with_image_link(lily)
      end
      content
    end

    private
    attr_reader :content, :naming_policy, :image_format, :site_manager, :static_file_builder

    def ensure_valid_image_format
      unless ["svg", "png"].include?(image_format)
        raise INVALID_IMAGE_FORMAT_ERROR
      end
    end

    def write_lily_code_file(lily)
      open(lily.code_filename, 'w') do |code_file|
        code_file.puts(preamble+lily.code+postamble)
      end
    end

    def generate_lily_image(lily)
      system("lilypond", "-dresolution=600", lilypond_output_format_option, lily.code_filename)
      system("timidity", lily.midi_filename, "-Ow", "-o", lily.audio_filename)
      system("mv", lily.code_filename, "lily_images/")
      system("mv", lily.image_filename, "lily_images/")
      system("mv", lily.midi_filename, "lily_images/")
      system("mv", lily.audio_filename, "lily_images/")
    end

    def add_lily_image_to_site(lily)
      site_manager.add_image(static_file_builder, lily.code_filename)
      site_manager.add_image(static_file_builder, lily.image_filename)
      site_manager.add_image(static_file_builder, lily.midi_filename)
      site_manager.add_image(static_file_builder, lily.audio_filename)
    end

    def replace_snippet_with_image_link(lily)
      content.gsub!(lily.snippet, lily.image_link)
    end

    def lilies
      lily_snippets.map do |snippet|
        Lily.new(naming_policy.generate_name(snippet), image_format, snippet)
      end
    end

    def lily_snippets
      content.scan(/```lilypond.+?```\n/m)
    end

    def preamble
      """
\\version \"2.20.0\"
#(set-global-staff-size 18)
\\include \"fasola.ily\"
\\paper{
    indent=0\\mm
    #(define dump-extents #t)
    page-breaking = #ly:one-line-auto-height-breaking
    paper-width = 4\\in
    left-margin = 3\\mm
    right-margin = 3\\mm
    top-margin = 3\\mm
    bottom-margin = 3\\mm
    oddHeaderMarkup = ##f
    evenHeaderMarkup = ##f
    oddFooterMarkup = ##f
    evenFooterMarkup = ##f
    ragged-right = ##t
    system-count = #1
}
\\score {
      """
    end

    def postamble
      """
  \\layout {
    \\context {
      \\Lyrics
      \\override LyricText #'font-name = \"Times New Roman,\"
    }
  }
  \\midi { 
    \\tempo 4 = 160
  }
}
      """
    end

    def lilypond_output_format_option
      image_format == "png" ? "--png" : "-dbackend=svg"
    end
  end
end
