require "commonmark/version"
require "commonmark/parser"

module Commonmark
  module_function

  def parse(markdown_input)
    Commonmark::Parser.parse(markdown_input)
  rescue Parslet::ParseFailed => failure
    failure.cause.ascii_tree
    # raise
  end



end
