require "digest"

module JekyllLilyPondConverter
  class NamingPolicy
    def generate_name(snippet)
      Digest::SHA256.hexdigest(snippet) 
    end
  end
end
