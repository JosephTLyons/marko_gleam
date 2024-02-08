import gleam/bool
import gleam/dict
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string
import internal/table

// TODO - return actual errors instead of Nil

// TODO Delete
pub fn main() {
  let text =
    "Visit this link about dogs!"
    |> bold()
    |> link("www.dogs.com")
    |> task(True)

  io.println(text)

  let text =
    "def main():\n    print('Hello, Dog!')"
    |> code_block(Some("py"))

  io.println(text)

  let text =
    ["pet", "a", "dog"]
    |> list.map(fn(item) {
      item
      |> unordered_list_item()
      |> indent(4)
    })
    |> string.join("\n")

  io.println(text)

  let rows = [
    dict.from_list([#("Name", "Joseph"), #("Profession", "Developer")]),
    dict.from_list([#("Name", "Sam"), #("Profession", "Carpenter")]),
  ]

  let lines = create_markdown_table(rows)
  use lines <- result.try(lines)

  io.println(lines)

  Ok(Nil)
}

pub const horizontal_rule = "---"

pub fn bold(text: String) -> String {
  "**" <> text <> "**"
}

pub fn code_inline(text: String) -> String {
  "`" <> text <> "`"
}

pub fn code_block(text, language: option.Option(String)) -> String {
  let language =
    language
    |> option.unwrap("")

  "```" <> language <> "\n" <> text <> "\n```"
}

pub fn header(text: String, level: Int) -> String {
  use <- bool.guard({ level <= 0 }, text)

  let prefix =
    "#"
    |> string.repeat(level)

  prefix <> " " <> text
}

// TODO: is string the right thing for a path in Gleam?
pub fn image(text: String, path: String) -> String {
  "![" <> text <> "](" <> path <> ")"
}

pub fn indent(text: String, level: Int) -> String {
  use <- bool.guard(level <= 0, text)

  let prefix =
    " "
    |> string.repeat(level)

  prefix <> text
}

pub fn italic(text: String) -> String {
  "*" <> text <> "*"
}

// TODO: is string the right thing for a link in Gleam?
pub fn link(text: String, link: String) -> String {
  "[" <> text <> "]" <> "(" <> link <> ")"
}

pub fn unordered_list_item(text: String) -> String {
  "- " <> text
}

pub fn ordered_list_item(text: String) -> String {
  "1. " <> text
}

pub fn quote(text: String) -> String {
  "> " <> text
}

pub fn strike(text: String) -> String {
  "~~" <> text <> "~~"
}

pub fn task(text: String, is_complete: Bool) -> String {
  let is_complete_symbol = case is_complete {
    True -> "X"
    False -> " "
  }

  "- [" <> is_complete_symbol <> "] " <> text
}

// TODO: Ewww
pub fn create_markdown_table(
  rows: List(dict.Dict(String, String)),
) -> Result(String, Nil) {
  use t <- result.try(table.build_table(rows))

  let column_widths = table.get_column_widths(t)
  let headers = table.get_headers(t)

  let padded_headers =
    headers
    |> list.map(fn(header) {
      let assert Ok(pad) =
        column_widths
        |> dict.get(header)

      header
      |> string.pad_right(pad, " ")
    })

  let separators =
    headers
    |> list.map(fn(header) {
      let assert Ok(pad) =
        column_widths
        |> dict.get(header)
      string.repeat("-", pad)
    })

  let markdown_table = [row_string(padded_headers), row_string(separators)]

  // TODO: Ewwww
  let padded_rows =
    rows
    |> list.map(fn(row) {
      row
      |> dict.to_list()
      // TODO: Is there a way to destructure a tuple as it is passed into a function?
      |> list.map(fn(item) {
        let assert Ok(pad) =
          column_widths
          |> dict.get(item.0)

        item.1
        |> string.pad_right(pad, " ")
      })
    })

  let row_strings =
    padded_rows
    |> list.map(fn(padded_row) { row_string(padded_row) })

  let markdown_table =
    markdown_table
    |> list.append(row_strings)
    |> string.join("\n")

  Ok(markdown_table)
}

fn row_string(rows: List(String)) {
  "| "
  <> rows
  |> string.join(" | ")
  <> " |"
}
