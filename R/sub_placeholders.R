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
