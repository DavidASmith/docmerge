#' Subsitute placeholders
#'
#' @param template_doc The path to the template document.
#' @param replacements A named list of placeholders and their corresponding values to replace in the template.
#' @param output_doc The path where the modified document will be saved.
#'
#' @returns A Word document saved to the specified output path with placeholders replaced by their respective values.
#'
#' @export
#' @examples
#' \dontrun{sub_placeholders("template.docx", list(name = "John Doe"), "output.docx")}
sub_placeholders <- function(template_doc, replacements, output_doc) {
  # Read Word document
  doc <- officer::read_docx(template_doc)

  # First, identify and remove paragraphs for NA values
  # This prevents issues with cursor positioning after text replacements
  na_placeholders <- names(replacements)[sapply(replacements, is.na)]

  # Remove paragraphs containing NA placeholders
  for (ph in na_placeholders) {
    doc <- delete_paragraph_if_na(doc, ph, replacements[[ph]])
  }

  # Then, replace inline placeholders for non-NA values
  non_na_replacements <- replacements[!sapply(replacements, is.na)]

  for (ph in names(non_na_replacements)) {
    val <- non_na_replacements[[ph]]

    # Additional safety check
    if (!is.na(val) && !is.null(val)) {
      (doc <- officer::body_replace_all_text(
        doc,
        old_value = paste0("<<", ph, ">>"),
        new_value = as.character(val),
        only_at_cursor = FALSE
      ))
    }
  }

  # Save the output to working directory
  print(doc, target = output_doc)
}
