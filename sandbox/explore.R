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

# Load template

input |>
  apply(1, function(x) {
    #browser()
    out_doc <- read_docx(template)
    for (bkm in names(x)) {
      body_replace_text_at_bkm(out_doc, bkm, x[bkm])
    }
    print(out_doc, target = paste0(x["name"], ".docx"))
  })
