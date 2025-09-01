#' Deletes the entire paragraph for the placeholder if the value is NA
#'
#' @param doc
#' @param placeholder
#' @param value
#' @param ph_start
#' @param ph_end
#'
#' @returns
#'
#' @export
#' @examples
delete_paragraph_if_na <- function(
  doc,
  placeholder,
  value,
  ph_start = "<<",
  ph_end = ">>"
) {
  if (!is.na(value)) {
    return(doc)
  }

  # Move cursor to paragraph containing placeholder
  pos <- officer::docx_summary(doc)
  # Create the full placeholder with angle brackets
  full_placeholder <- paste0(ph_start, placeholder, ph_end)
  para_id <- pos$doc_index[
    grepl(full_placeholder, pos$text) & pos$content_type == "paragraph"
  ]

  if (length(para_id) > 0) {
    # Set cursor at that paragraph
    doc <- officer::cursor_reach(doc, keyword = placeholder)
    # Remove the paragraph at the cursor
    doc <- officer::body_remove(doc)
  }

  doc
}
