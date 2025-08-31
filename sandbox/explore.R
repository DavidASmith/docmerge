library(tibble)
library(officer)

input <- tibble(
  addr1 = c(
    "124 Conch St.",
    "32 Windsor Gardens",
    "20 Ingram St.",
    "127 Inkerman Terrace"
  ),
  addr2 = c("Bikini Bottom", NA, "Forest Hills", NA),
  city = c("Pacific Ocean", "London", "New York", "Newcastle"),
  country = c(NA, "UK", "USA", "UK"),
  name = c(
    "Spongebob Squarepants",
    "Paddington Bear",
    "Peter Parker",
    "Terry Collier"
  ),
  gift = c(
    "crabby patties",
    "marmalade sandwiches",
    "radioactive spiders",
    "brown ale"
  )
)

template <- "letter_template.docx"

input |>
  apply(1, function(x) {
    #browser()
    out_doc <- read_docx(template)
    for (placeholder in names(x)) {
      body_replace_all_text(
        out_doc,
        old_value = paste0("<<", placeholder, ">>"),
        new_value = x[placeholder]
      )
    }
    print(out_doc, target = paste0(x["name"], ".docx"))
  })
