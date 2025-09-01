library(officer)
devtools::load_all()


# Test
template_path <- system.file(
  "extdata",
  "letter_template.docx",
  package = "docmerge"
)

docmerge(template_path, gifts)
