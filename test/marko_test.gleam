import gleam/dict
import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import marko
import internal/table

pub fn main() {
  gleeunit.main()
}

// TODO pull "Dog" into const?
// TODO return actual errors instead of Nil?

pub fn horizontal_rule_test() {
  marko.horizontal_rule
  |> should.equal("---")
}

pub fn bold_test() {
  marko.bold("Dog")
  |> should.equal("**Dog**")
}

pub fn code_inline_test() {
  marko.code_inline("Dog")
  |> should.equal("`Dog`")
}

pub fn code_block_test() {
  marko.code_block("Dog", None)
  |> should.equal("```\nDog\n```")

  marko.code_block("Dog", Some("rs"))
  |> should.equal("```rs\nDog\n```")
}

pub fn header_test() {
  marko.header("Dog", 1)
  |> should.equal("# Dog")

  marko.header("Dog", 2)
  |> should.equal("## Dog")

  marko.header("Dog", 3)
  |> should.equal("### Dog")

  marko.header("Dog", -1)
  |> should.equal("Dog")
}

pub fn image_test() {
  marko.image("Dog", "/path/to/dog_image.png")
  |> should.equal("![Dog](/path/to/dog_image.png)")
}

pub fn indent_test() {
  marko.indent("Dog", 1)
  |> should.equal(" Dog")

  marko.indent("Dog", 2)
  |> should.equal("  Dog")

  marko.indent("Dog", 4)
  |> should.equal("    Dog")

  marko.indent("Dog", -1)
  |> should.equal("Dog")
}

pub fn italic_test() {
  marko.italic("Dog")
  |> should.equal("*Dog*")
}

pub fn link_test() {
  marko.link("Dog", "www.dogs.com")
  |> should.equal("[Dog](www.dogs.com)")
}

pub fn unordered_list_item_test() {
  marko.unordered_list_item("Dog")
  |> should.equal("- Dog")
}

pub fn ordered_list_item_test() {
  marko.ordered_list_item("Dog")
  |> should.equal("1. Dog")
}

pub fn quote_test() {
  marko.quote("Dog")
  |> should.equal("> Dog")
}

pub fn strike_test() {
  marko.strike("Dog")
  |> should.equal("~~Dog~~")
}

pub fn task_test() {
  marko.task("Dog", True)
  |> should.equal("- [X] Dog")

  marko.task("Dog", False)
  |> should.equal("- [ ] Dog")
}

// Test table

pub fn no_rows_test() {
  let rows = []
  rows
  |> table.build_table()
  |> should.equal(Error(Nil))
}

pub fn get_headers_test() {
  let rows = [
    dict.from_list([#("Name", "Joseph"), #("Profession", "Developer")]),
    dict.from_list([#("Name", "Sam"), #("Profession", "Carpenter")]),
  ]

  let assert Ok(t) = table.build_table(rows)
  let headers = table.get_headers(t)

  headers
  |> should.equal(["Name", "Profession"])
}

pub fn different_headers_test() {
  let rows = [
    dict.from_list([#("Names", "Joseph"), #("Profession", "Developer")]),
    dict.from_list([#("Name", "Sam"), #("Profession", "Carpenter")]),
  ]
  let table_lines = table.build_table(rows)

  table_lines
  |> should.equal(Error(Nil))
}

pub fn column_width_test() {
  let rows = [
    dict.from_list([#("Name", "Joseph"), #("Profession", "Developer")]),
    dict.from_list([#("Name", "Sam"), #("Profession", "Carpenter")]),
  ]

  let assert Ok(t) = table.build_table(rows)
  t
  |> table.get_column_width("Name")
  |> should.equal(Ok(6))

  t
  |> table.get_column_width("Profession")
  |> should.equal(Ok(10))
}

pub fn column_widths_test() {
  let rows = [
    dict.from_list([#("Name", "Joseph"), #("Profession", "Developer")]),
    dict.from_list([#("Name", "Sam"), #("Profession", "Carpenter")]),
  ]

  let assert Ok(t) = table.build_table(rows)
  let column_widths =
    t
    |> table.get_column_widths()

  column_widths
  |> dict.get("Name")
  |> should.equal(Ok(6))

  column_widths
  |> dict.get("Profession")
  |> should.equal(Ok(10))
}

// Test markdown table

pub fn markdown_table_test() {
  let rows = [
    dict.from_list([#("Name", "Joseph"), #("Profession", "Developer")]),
    dict.from_list([#("Name", "Sam"), #("Profession", "Carpenter")]),
  ]
  let table_lines = marko.create_markdown_table(rows)

  // TODO: Can formatting be skipped here?
  let expected_output =
    "| Name   | Profession |\n| ------ | ---------- |\n| Joseph | Developer  |\n| Sam    | Carpenter  |"

  table_lines
  |> should.equal(Ok(expected_output))
}
