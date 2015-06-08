 require 'parslet'

 module Commonmark
  class Grammar < Parslet::Parser

    rule(:cr)         { match('\n') }
    rule(:eol?)       { cr | any.absent?  }
    rule(:line_body)  { (eol?.absent? >> any).repeat(1) }
    rule(:line)       { cr | (line_body >> eol?) }
    rule(:text) { line.as(:text) }

    rule(:paragraph_line) { (line_body).as(:paragraph_line) >> eol? }

    rule(:paragraph) { paragraph_line.repeat(1).as(:paragraph) >> (cr.repeat(1) | any.absent?) }

    rule(:dash) { str('-') }
    rule(:space) { match(' ') }
    rule(:tab) { match('\t').repeat(1) }

    rule(:hr_char) { str('-') | str('*') | str('_') }
    rule(:hr_delimiter) { space }

    rule(:hr) { space.repeat(0, 3) >> (hr_char >> hr_delimiter.repeat).repeat(3).as(:hr) >> eol? }

    rule(:unordered_list_item) { dash >> space >> (line_body).as(:li) >> eol?}
    rule(:unordered_list) { unordered_list_item.repeat(1).as(:ul) }

    rule(:code_line) { space.repeat(4) >> (line_body >> eol?).as(:code_line) }
    rule(:code_block) { code_line.repeat(1).as(:code_block) }


    rule(:markdown) { (hr | unordered_list | code_block | paragraph ).repeat(1) }

    root :markdown
  end

  class CodeblockTransform < Parslet::Transform
    rule(code_line: simple(:code_line)) { code_line }
    rule(code_block: sequence(:code_lines)) {
      "<pre><code>#{code_lines.join("\n")}</code></pre>"
    }

    rule(li: simple(:li)) {
      "<li>#{li}</li>\n"
    }

    rule(ul: sequence(:list)) {
    %(<ul>
#{list.join}</ul>)
    }

    rule(hr: simple(:hr)) { "<hr />\n" }

    rule(paragraph_line: simple(:line)) { line }
    rule(paragraph: sequence(:paragraph_lines)) { "<p>#{paragraph_lines.join("\n")}</p>" }
  end

  class Parser
    def self.parse(markdown_input)
      tree = Grammar.new.parse(markdown_input)

      File.open('/web/parsed_markdown/tree.kikou', 'w').puts tree
      CodeblockTransform.new.apply(tree)
    end
  end
end

