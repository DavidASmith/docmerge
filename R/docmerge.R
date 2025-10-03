#' Generate word documents from template and dataframe of inputs
#'
#' @param template_doc The path to the template document.
#' @param merge_inputs A dataframe or tibble where each row represents a set of
#' placeholders and their corresponding values to be replaced in the template.
#' @param output_path The directory where the generated documents will be saved.
#'
#' @returns A series of Word documents saved to the specified output path, each
#' corresponding to a row in the merge_inputs dataframe with placeholders replaced
#' by their respective values.
#'
#' @export
#' @examples
#' \dontrun{docmerge("template.docx", input_df, "./output")}
docmerge <- function(template_doc, merge_inputs, output_path = "./") {
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
        paste0(output_path, "/", file_name, ".docx")
      )
    })
}
