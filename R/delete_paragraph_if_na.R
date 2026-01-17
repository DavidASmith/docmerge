#' Deletes the entire paragraph for the placeholder if the value is NA
#'
#' @param doc A Word document object created by officer
#' @param placeholder The placeholder name without angle brackets
#' @param value The value to check for NA
#'
#' @returns A Word document object with the paragraph removed if value is NA
#'
#' @export
#' @examples
#' \dontrun{delete_paragraph_if_na(doc, placeholder, value)}
delete_paragraph_if_na <- function(doc, placeholder, value) {
  if (!is.na(value)) {
    return(doc)
  }

  # Get initial document summary
  pos <- officer::docx_summary(doc)

  # Create the full placeholder with angle brackets
  full_placeholder <- paste0("<<", placeholder, ">>")

  # Find all paragraphs containing the placeholder
  matching_paras <- which(
    grepl(full_placeholder, pos$text, fixed = TRUE) &
      pos$content_type == "paragraph"
  )

  # Process paragraphs in reverse order to maintain correct indices
  if (length(matching_paras) > 0) {
    for (i in rev(matching_paras)) {
      # Use doc_index to position cursor correctly
      doc <- officer::cursor_reach(doc, keyword = full_placeholder)
      doc <- officer::body_remove(doc)

      # Refresh document structure after each removal
      pos <- officer::docx_summary(doc)

      # Check if there are still instances to remove
      remaining_instances <- which(
        grepl(full_placeholder, pos$text, fixed = TRUE) &
          pos$content_type == "paragraph"
      )

      # If no more instances, break the loop
      if (length(remaining_instances) == 0) {
        break
      }
    }
  }

  doc
}
