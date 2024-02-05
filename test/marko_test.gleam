import gleam/list
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

pub fn divider_test() {
  marko.divider
  |> should.equal("---")
}

pub fn bold_test() {
  marko.bold("Dog")
  |> should.equal("**Dog**")
}

pub fn bullet_test() {
  marko.bullet("Dog")
  |> should.equal("- Dog")
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

pub fn list_test() {
  marko.list(["Dog", "Doggy", "Doggo"])
  |> should.equal("1. Dog\n2. Doggy\n3. Doggo")
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

pub fn column_width_test() {
  let rows = [
    dict.from_list([#("Name", "Joseph"), #("Profession", "Developer")]),
    dict.from_list([#("Name", "Sam"), #("Profession", "Carpenter")]),
  ]

  let assert Ok(row) =
    rows
    |> list.first

  let headers =
    row
    |> dict.keys()

  let t = table.Table(headers, rows)
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

  let assert Ok(row) =
    rows
    |> list.first

  let headers =
    row
    |> dict.keys()

  let t = table.Table(headers, rows)
  let column_widths =
    t
    |> table.get_column_widths()

  let assert Ok(column_widths) = column_widths

  column_widths
  |> dict.get("Name")
  |> should.equal(Ok(6))

  column_widths
  |> dict.get("Profession")
  |> should.equal(Ok(10))
}

pub fn table_empty_headers_test() {
  let rows = [
    dict.from_list([#("Name", "Joseph"), #("Profession", "Developer")]),
    dict.from_list([#("Name", "Sam"), #("Profession", "Carpenter")]),
  ]
  let headers = []
  let table_lines = marko.create_markdown_table(headers, rows)

  table_lines
  |> should.equal(Error(Nil))
}

pub fn table_empty_row_test() {
  let rows = []
  let headers = ["Name", "Profession"]
  let table_lines = marko.create_markdown_table(headers, rows)

  table_lines
  |> should.equal(Error(Nil))
}

pub fn table_with_values_test() {
  let rows = [
    dict.from_list([#("Name", "Joseph"), #("Profession", "Developer")]),
    dict.from_list([#("Name", "Sam"), #("Profession", "Carpenter")]),
  ]
  let headers = ["Name", "Profession"]

  let table_lines = marko.create_markdown_table(headers, rows)

  let expected_output = [
    "| Name   | Profession |", "| ------ | ---------- |",
    "| Joseph | Developer  |", "| Sam    | Carpenter  |",
  ]

  table_lines
  |> should.equal(Ok(expected_output))
}
