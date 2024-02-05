import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Table {
  Table(headers: List(String), rows: List(Dict(String, String)))
}

// Make this better later - should it just return an Int?
pub fn get_column_width(table: Table, header: String) -> Result(Int, Nil) {
  let header_length =
    header
    |> string.length()

  let values = list.try_map(table.rows, fn(row) { dict.get(row, header) })
  use values <- result.try(values)

  let values_max_length =
    values
    |> list.map(fn(s) { string.length(s) })
    |> list.reduce(fn(a, b) { int.max(a, b) })

  use values_max_length <- result.try(values_max_length)

  Ok(int.max(header_length, values_max_length))
}

pub fn get_column_widths(table: Table) -> Result(Dict(String, Int), Nil) {
  let column_widths =
    table.headers
    |> list.try_map(fn(header) { get_column_width(table, header) })
  use column_widths <- result.try(column_widths)

  table.headers
  |> list.zip(column_widths)
  |> dict.from_list()
  |> Ok()
}
