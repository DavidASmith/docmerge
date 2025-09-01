#' Subsitute placeholders
#'
#' @param template_doc
#' @param replacements
#' @param output_doc
#'
#' @returns
#'
#' @export
#' @examples
sub_placeholders <- function(template_doc, replacements, output_doc) {
  # Read Word document
  doc <- officer::read_docx(template_doc)

  # Replace inline placeholders
  for (ph in names(replacements)) {
    val <- replacements[[ph]]

    if (!is.na(val)) {
      doc <- officer::body_replace_all_text(
        doc,
        old_value = paste0("<<", ph, ">>"),
        new_value = val,
        only_at_cursor = FALSE
      )
    }
  }

  # Delete paragraphs for NA values
  for (ph in names(replacements)) {
    val <- replacements[[ph]]
    doc <- delete_paragraph_if_na(doc, ph, val)
  }

  # Save the output to working directory
  print(doc, target = output_doc)
}
