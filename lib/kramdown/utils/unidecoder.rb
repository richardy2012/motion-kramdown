# -*- coding: utf-8 -*-
#
#--
# Copyright (C) 2009-2015 Thomas Leitner <t_leitner@gmx.at>
#
# This file is part of kramdown which is licensed under the MIT.
#++
#
# This file is based on code originally from the Stringex library and needs the data files from
# Stringex to work correctly.

module Kramdown
  module Utils

    # Provides the ability to tranliterate Unicode strings into plain ASCII ones.
    module Unidecoder

      # RM gem 'stringex' if defined?(Gem)
      # RM TODO path = $:.find {|dir| File.directory?(File.join(File.expand_path(dir), "stringex", "unidecoder_data"))}
      path = 'lib' # RM TODO

      if RUBY_VERSION <= '1.8.6' || !path
        def self.decode(string)
          string
        end
      else

        CODEPOINTS = Hash.new do |h, k|
          if File.exists?(File.join(path, "stringex", "unidecoder_data", "#{k}.yml")) # RM
            h[k] = YAML::load(File.join(path, "stringex", "unidecoder_data", "#{k}.yml")) # RM
          end # RM
        end

        # Transliterate string from Unicode into ASCII.
        def self.decode(string)
          string.gsub(/[^\x00-\x7f]/u) do |codepoint|
            begin
              unpacked = codepoint.unpack("U")[0]
              CODEPOINTS["x%02x" % (unpacked >> 8)][unpacked & 255]
            rescue
              "?"
            end
          end
        end

      end

    end

  end
end
