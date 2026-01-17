library(officer)
devtools::load_all()


input <- tibble::tibble(
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

# Test

docmerge("inst/extdata/letter_template.docx", input)
