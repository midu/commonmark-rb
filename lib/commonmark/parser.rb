 require 'parslet'

 module Commonmark
  class Grammar < Parslet::Parser

    rule(:cr)         { match('\n') }
    rule(:eol?)       { cr | any.absent?  }
    rule(:line_body)  { (eol?.absent? >> any).repeat(1) }
    rule(:line)       { cr | (line_body >> eol?) }
    rule(:text) { line.as(:text) }

    rule(:paragraph) { (line).repeat(1).as(:paragraph) }

    rule(:dash) { str('-') }
    rule(:space) { match(' ') }
    rule(:tab) { match('\t').repeat(1) }

    rule(:hr_char) { str('-') | str('*') | str('_') }
    rule(:hr) { space.repeat(0, 3) >> hr_char.repeat(3, nil).as(:hr) >> eol? }

    rule(:unordered_list_item) { dash >> space >> (line_body).as(:li) >> eol?}
    rule(:unordered_list) { unordered_list_item.repeat(1).as(:ul) }

    rule(:code_line) { space.repeat(4) >> (line_body >> eol?).as(:code_line) }
    rule(:code_block) { code_line.repeat(1).as(:code_block) }


    rule(:markdown) { (unordered_list | hr | code_block | paragraph ).repeat(1) }

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

    rule(paragraph: simple(:paragraph)) { "<p>#{paragraph}</p>" }
  end

  class Parser
    def self.parse(markdown_input)
      tree = Grammar.new.parse(markdown_input)
      # puts tree
      File.open('/web/parsed_markdown/tree.kikou', 'w').puts tree
      CodeblockTransform.new.apply(tree)
    end
  end
end

