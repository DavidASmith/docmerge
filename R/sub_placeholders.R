#' Subsitute placeholders
#'
#' @param template_doc The path to the template document.
#' @param replacements A named list of placeholders and their corresponding values to replace in the template.
#' @param output_doc The path where the modified document will be saved.
#' @param ph_start The string that denotes the start of a placeholder (default is "<<").
#' @param ph_end The string that denotes the end of a placeholder (default is ">>").
#'
#' @returns A Word document saved to the specified output path with placeholders replaced by their respective values.
#'
#' @export
#' @examples
#' \dontrun{sub_placeholders("template.docx", list(name = "John Doe"), "output.docx")}
sub_placeholders <- function(
  template_doc,
  replacements,
  output_doc,
  ph_start = "<<",
  ph_end = ">>"
) {
  # Read Word document
  doc <- officer::read_docx(template_doc)

  # First, identify and remove paragraphs for NA/NULL values
  # This prevents issues with cursor positioning after text replacements
  # Use a function that handles both NA and NULL properly
  is_na_or_null <- function(x) {
    is.null(x) || (length(x) == 1 && is.na(x))
  }
  
  na_placeholders <- names(replacements)[vapply(replacements, is_na_or_null, logical(1))]

  # Remove paragraphs containing NA placeholders
  for (ph in na_placeholders) {
    doc <- delete_paragraph_if_na(doc, ph, replacements[[ph]], ph_start, ph_end)
  }

  # Then, replace inline placeholders for non-NA values
  non_na_replacements <- replacements[!vapply(replacements, is_na_or_null, logical(1))]

  for (ph in names(non_na_replacements)) {
    val <- non_na_replacements[[ph]]

    # Additional safety check
    if (!is.na(val) && !is.null(val)) {
      # Use fixed=TRUE to avoid regex interpretation issues with special characters
      (doc <- officer::body_replace_all_text(
        doc,
        old_value = paste0(ph_start, ph, ph_end),
        new_value = as.character(val),
        only_at_cursor = FALSE,
        fixed = TRUE
      ))
    }
  }

  # Save the output to working directory
  print(doc, target = output_doc)
}
