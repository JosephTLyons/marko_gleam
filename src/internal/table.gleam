import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub opaque type Table {
  Table(rows: List(Dict(String, String)))
}

pub fn build_table(rows: List(Dict(String, String))) -> Result(Table, Nil) {
  let rows_have_same_headers =
    rows
    |> list.window_by_2()
    |> list.all(fn(a) { dict.keys(a.0) == dict.keys(a.1) })

  use <- bool.guard(!rows_have_same_headers, Error(Nil))

  Ok(Table(rows))
}

pub fn get_headers(table: Table) -> Result(List(String), Nil) {
  use first_row <- result.try(list.first(table.rows))
  Ok(
    first_row
    |> dict.keys(),
  )
}

// TODO: Make this better later - should it just return an Int?
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
  use headers <- result.try(get_headers(table))

  let column_widths =
    headers
    |> list.try_map(fn(header) { get_column_width(table, header) })
  use column_widths <- result.try(column_widths)

  headers
  |> list.zip(column_widths)
  |> dict.from_list()
  |> Ok()
}
