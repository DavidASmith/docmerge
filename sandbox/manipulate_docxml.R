library(officer)

# Function to delete paragraph containing placeholder if value is NA
delete_paragraph_if_na <- function(doc, placeholder, value) {
  if (!is.na(value)) {
    return(doc)
  }

  # Move cursor to paragraph containing placeholder
  pos <- docx_summary(doc)
  # Create the full placeholder with angle brackets
  full_placeholder <- paste0("<<", placeholder, ">>")
  para_id <- pos$doc_index[
    grepl(full_placeholder, pos$text) & pos$content_type == "paragraph"
  ]

  if (length(para_id) > 0) {
    # Set cursor at that paragraph
    doc <- cursor_reach(doc, keyword = placeholder)
    # Remove the paragraph at the cursor
    doc <- body_remove(doc)
  }

  doc
}

# Example values for placeholders
replacements <- list(
  addr1 = "124 Conch St.",
  addr2 = NA, # NA → delete paragraph
  city = "Bikini Bottom",
  country = "Pacific Ocean",
  name = "SpongeBob",
  gift = "Jellyfishing Kit"
)

# Read Word document
doc <- read_docx("letter_template.docx")

# Replace inline placeholders
for (ph in names(replacements)) {
  val <- replacements[[ph]]

  if (!is.na(val)) {
    doc <- body_replace_all_text(
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
print(doc, target = "output.docx")

