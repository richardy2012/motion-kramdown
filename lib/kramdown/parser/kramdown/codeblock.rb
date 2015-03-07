# -*- coding: utf-8 -*-
#
#--
# Copyright (C) 2009-2015 Thomas Leitner <t_leitner@gmx.at>
#
# This file is part of kramdown which is licensed under the MIT.
#++
#

# RM require 'kramdown/parser/kramdown/blank_line'
# RM require 'kramdown/parser/kramdown/extensions'
# RM require 'kramdown/parser/kramdown/eob'
# RM require 'kramdown/parser/kramdown/paragraph'

module Kramdown
  module Parser
    class Kramdown

      CODEBLOCK_START = INDENT
      CODEBLOCK_MATCH = /(?:#{BLANK_LINE}?(?:#{INDENT}[ \t]*\S.*\n)+(?:(?!#{IAL_BLOCK_START}|#{EOB_MARKER}|#{OPT_SPACE_LAZY_END_HTML_STOP}|#{OPT_SPACE_LAZY_END_HTML_START})^[ \t]*\S.*\n)*)*/
      # RM modified CODEBLOCK_MATCH with new combined OPT_SPACE_LAZY_END_HTML_STOP/START to support RM changes

      # Parse the indented codeblock at the current location.
      def parse_codeblock
        start_line_number = @src.current_line_number
        data = @src.scan(self.class::CODEBLOCK_MATCH)
        data.gsub!(/\n( {0,3}\S)/, ' \\1')
        data.gsub!(INDENT, '')
        @tree.children << new_block_el(:codeblock, data, nil, :location => start_line_number)
        true
      end
      define_parser(:codeblock, CODEBLOCK_START)


      FENCED_CODEBLOCK_START = /^~{3,}/
      FENCED_CODEBLOCK_MATCH = /^((~){3,})\s*?(\w+)?\s*?\n(.*?)^\1\2*\s*?\n/m

      # Parse the fenced codeblock at the current location.
      def parse_codeblock_fenced
        if @src.check(self.class::FENCED_CODEBLOCK_MATCH)
          start_line_number = @src.current_line_number
          @src.pos += @src.matched_size
          el = new_block_el(:codeblock, @src[4], nil, :location => start_line_number)
          lang = @src[3].to_s.strip
          el.attr['class'] = "language-#{lang}" unless lang.empty?
          @tree.children << el
          true
        else
          false
        end
      end
      define_parser(:codeblock_fenced, FENCED_CODEBLOCK_START)

    end
  end
end
