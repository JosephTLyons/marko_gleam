import gleam/bool
import gleam/dict
import gleam/int
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
    ["hey", "there", "bud"]
    |> list()

  io.println(text)

  let rows = [
    dict.from_list([#("Name", "Joseph"), #("Profession", "Developer")]),
    dict.from_list([#("Name", "Sam"), #("Profession", "Carpenter")]),
  ]

  let lines = create_markdown_table(rows)
  use lines <- result.try(lines)

  lines
  |> list.each(fn(line) { io.debug(line) })

  Ok(Nil)
}

pub const divider = "---"

pub fn bold(text: String) -> String {
  "**" <> text <> "**"
}

// TODO: bullet() and list() are inconsistent in how they work - both make a list
// TODO: Should be one function with a bool?
// TODO: should it take in a list or be called multiple times?
pub fn bullet(text: String) -> String {
  "- " <> text
}

pub fn code_inline(text: String) -> String {
  "`" <> text <> "`"
}

// TODO: Should we return string or list of strings?
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

// TODO: Should we return string or list of strings?
pub fn list(items: List(String)) -> String {
  let leave = list.is_empty(items)
  use <- bool.guard(leave, "")

  let formatted_items =
    items
    |> enumerate()
    |> list.map(fn(a) {
      let bullet = int.to_string(a.0) <> "."
      bullet <> " " <> a.1
    })
    |> string.join("\n")

  formatted_items
}

fn enumerate(items: List(a)) -> List(#(Int, a)) {
  list.range(1, list.length(items) + 1)
  |> list.zip(items)
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

// TODO: Should we return string or list of strings?
// TODO: Ewww
pub fn create_markdown_table(
  rows: List(dict.Dict(String, String)),
) -> Result(List(String), Nil) {
  use t <- result.try(table.build_table(rows))

  let value_pad_dict =
    t
    |> table.get_column_widths()

  let headers = table.get_headers(t)

  let padded_headers =
    headers
    |> list.try_map(fn(header) {
      value_pad_dict
      |> dict.get(header)
      |> result.map(fn(pad) {
        header
        |> string.pad_right(pad, " ")
      })
    })

  use padded_headers <- result.try(padded_headers)

  let separators =
    headers
    |> list.try_map(fn(header) {
      value_pad_dict
      |> dict.get(header)
      |> result.map(fn(pad) { string.repeat("-", pad) })
    })

  use separators <- result.try(separators)

  let markdown_table = [row_string(padded_headers), row_string(separators)]

  // TODO: Ewwww
  let padded_rows =
    rows
    |> list.map(fn(row) {
      row
      |> dict.to_list()
      // TODO: Is there a way to destructure a tuple as it is passed into a function?
      |> list.map(fn(item) {
        let pad =
          value_pad_dict
          |> dict.get(item.0)
          // TODO: This must be dealt with
          |> result.unwrap(0)

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

  Ok(markdown_table)
}

fn row_string(rows: List(String)) {
  "| "
  <> rows
  |> string.join(" | ")
  <> " |"
}
