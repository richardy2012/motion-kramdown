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
# RM require 'kramdown/parser/kramdown/list'
# RM require 'kramdown/parser/kramdown/html'

module Kramdown
  module Parser
    class Kramdown

      LAZY_END_HTML_SPAN_ELEMENTS = Kramdown::Parser::Html::HTML_SPAN_ELEMENTS + %w{script}  # RM
      LAZY_END_HTML_START = /<(?>(?!(?:#{LAZY_END_HTML_SPAN_ELEMENTS.join('|')})\b)#{REXML::Parsers::BaseParser::UNAME_STR})/
      LAZY_END_HTML_STOP = /<\/(?!(?:#{LAZY_END_HTML_SPAN_ELEMENTS.join('|')})\b)#{REXML::Parsers::BaseParser::UNAME_STR}\s*>/m

      OPT_SPACE_LAZY_END_HTML_START = /^#{OPT_SPACE}#{LAZY_END_HTML_START}/m  # RM Oniguruma -> ICU
      OPT_SPACE_LAZY_END_HTML_STOP  = /^#{OPT_SPACE}#{LAZY_END_HTML_STOP}/m   # RM Oniguruma -> ICU

      LAZY_END = /#{BLANK_LINE}|#{IAL_BLOCK_START}|#{EOB_MARKER}|#{OPT_SPACE_LAZY_END_HTML_STOP}|#{OPT_SPACE_LAZY_END_HTML_START}|\Z/  # RM

      PARAGRAPH_START = /^#{OPT_SPACE}[^ \t].*?\n/
      PARAGRAPH_MATCH = /^.*?\n/
      PARAGRAPH_END = /#{LAZY_END}|#{DEFINITION_LIST_START}/

      # Parse the paragraph at the current location.
      def parse_paragraph
        start_line_number = @src.current_line_number
        result = @src.scan(PARAGRAPH_MATCH)
        while !@src.match?(self.class::PARAGRAPH_END)
          result << @src.scan(PARAGRAPH_MATCH)
        end
        result.rstrip!
        if @tree.children.last && @tree.children.last.type == :p
          @tree.children.last.children.first.value << "\n" << result
        else
          @tree.children << new_block_el(:p, nil, nil, :location => start_line_number)
          result.lstrip!
          add_text(result, @tree.children.last)
        end
        true
      end
      define_parser(:paragraph, PARAGRAPH_START)

    end
  end
end
