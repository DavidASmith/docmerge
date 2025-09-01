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


# Example values for placeholders
replacements <- list(
  addr1 = "124 Conch St.",
  addr2 = NA, # NA → delete paragraph
  city = "Bikini Bottom",
  country = "Pacific Ocean",
  name = "SpongeBob",
  gift = "Jellyfishing Kit"
)


# Test

if (!("file_name" %in% names(input))) {
  input <- input |>
    dplyr::mutate(file_name = dplyr::row_number())
}

input |>
  apply(1, function(x) {
    #browser()
    replacements <- x |>
      as.list()
    file_name <- x[["file_name"]]
    replacements[["file_name"]] <- NULL

    sub_placeholders(
      "letter_template.docx",
      replacements,
      paste0(file_name, ".docx")
    )
  })
