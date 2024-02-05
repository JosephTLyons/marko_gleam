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
    |> unordered_list()

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

pub fn unordered_list(items: List(String)) -> String {
  items
  |> list.map(fn(item) { "- " <> item })
  |> string.join("\n")
}

pub fn ordered_list(items: List(String)) -> String {
  items
  |> enumerate()
  |> list.map(fn(a) {
    let bullet = int.to_string(a.0) <> "."
    bullet <> " " <> a.1
  })
  |> string.join("\n")
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

  let value_pad_dict = table.get_column_widths(t)
  let headers = table.get_headers(t)

  let padded_headers =
    headers
    |> list.map(fn(header) {
      let assert Ok(pad) =
        value_pad_dict
        |> dict.get(header)

      header
      |> string.pad_right(pad, " ")
    })

  let separators =
    headers
    |> list.map(fn(header) {
      let assert Ok(pad) =
        value_pad_dict
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
          value_pad_dict
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

  Ok(markdown_table)
}

fn row_string(rows: List(String)) {
  "| "
  <> rows
  |> string.join(" | ")
  <> " |"
}
