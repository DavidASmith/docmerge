#' Generate word documents from template and dataframe of inputs
#'
#' @param template_doc
#' @param merge_inputs
#' @param output_path
#' @param ph_start
#' @param ph_end
#'
#' @returns
#'
#' @export
#' @examples
docmerge <- function(
  template_doc,
  merge_inputs,
  output_path = "./",
  ph_start = "<<",
  ph_end = ">>"
) {
  if (!("file_name" %in% names(merge_inputs))) {
    merge_inputs <- merge_inputs |>
      dplyr::mutate(file_name = dplyr::row_number())
  }

  merge_inputs |>
    apply(1, function(x) {
      #browser()
      replacements <- x |>
        as.list()
      file_name <- x[["file_name"]]
      replacements[["file_name"]] <- NULL

      sub_placeholders(
        template_doc,
        replacements,
        paste0(output_path, "/", file_name, ".docx"),
        ph_start,
        ph_end
      )
    })
}
