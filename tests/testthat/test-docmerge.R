# Test sub_placeholders function
test_that("sub_placeholders replaces non-NA values correctly", {
  # Create a simple template
  template_path <- tempfile(fileext = ".docx")
  output_path <- tempfile(fileext = ".docx")

  # Create a basic document with placeholders
  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc, "Dear <<name>>")
  doc <- officer::body_add_par(doc, "Your gift is <<gift>>")
  print(doc, target = template_path)

  # Test replacements
  replacements <- list(name = "John Doe", gift = "a book")
  sub_placeholders(template_path, replacements, output_path)

  # Read the output and check
  result <- officer::read_docx(output_path)
  result_text <- officer::docx_summary(result)$text

  expect_true(any(grepl("John Doe", result_text)))
  expect_true(any(grepl("a book", result_text)))
  expect_false(any(grepl("<<name>>", result_text)))
  expect_false(any(grepl("<<gift>>", result_text)))

  # Cleanup
  unlink(c(template_path, output_path))
})

test_that("sub_placeholders removes paragraphs with NA values", {
  # Create template with multiple paragraphs
  template_path <- tempfile(fileext = ".docx")
  output_path <- tempfile(fileext = ".docx")

  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc, "Name: <<name>>")
  doc <- officer::body_add_par(doc, "Address Line 2: <<addr2>>")
  doc <- officer::body_add_par(doc, "City: <<city>>")
  print(doc, target = template_path)

  # Test with NA value for addr2
  replacements <- list(name = "Jane Smith", addr2 = NA, city = "London")
  sub_placeholders(template_path, replacements, output_path)

  # Read the output
  result <- officer::read_docx(output_path)
  result_text <- officer::docx_summary(result)$text

  # Check that non-NA values are replaced
  expect_true(any(grepl("Jane Smith", result_text)))
  expect_true(any(grepl("London", result_text)))

  # Check that the paragraph with NA placeholder is removed
  expect_false(any(grepl("<<addr2>>", result_text)))
  expect_false(any(grepl("Address Line 2:", result_text)))

  # Cleanup
  unlink(c(template_path, output_path))
})

test_that("sub_placeholders handles multiple NA placeholders", {
  # Create template
  template_path <- tempfile(fileext = ".docx")
  output_path <- tempfile(fileext = ".docx")

  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc, "Field 1: <<field1>>")
  doc <- officer::body_add_par(doc, "Field 2: <<field2>>")
  doc <- officer::body_add_par(doc, "Field 3: <<field3>>")
  doc <- officer::body_add_par(doc, "Field 4: <<field4>>")
  print(doc, target = template_path)

  # Test with multiple NAs
  replacements <- list(
    field1 = "Value 1",
    field2 = NA,
    field3 = NA,
    field4 = "Value 4"
  )
  sub_placeholders(template_path, replacements, output_path)

  # Read the output
  result <- officer::read_docx(output_path)
  result_text <- officer::docx_summary(result)$text

  # Check that non-NA values are present
  expect_true(any(grepl("Value 1", result_text)))
  expect_true(any(grepl("Value 4", result_text)))

  # Check that NA paragraphs are removed
  expect_false(any(grepl("Field 2:", result_text)))
  expect_false(any(grepl("Field 3:", result_text)))

  # Cleanup
  unlink(c(template_path, output_path))
})

test_that("sub_placeholders works with different placeholder markup styles", {
  # Test with curly braces
  template_path <- tempfile(fileext = ".docx")
  output_path <- tempfile(fileext = ".docx")

  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc, "Name: {{name}}")
  doc <- officer::body_add_par(doc, "Optional: {{optional}}")
  doc <- officer::body_add_par(doc, "City: {{city}}")
  print(doc, target = template_path)

  replacements <- list(name = "Alice", optional = NA, city = "Paris")
  sub_placeholders(
    template_path,
    replacements,
    output_path,
    ph_start = "{{",
    ph_end = "}}"
  )

  result <- officer::read_docx(output_path)
  result_text <- officer::docx_summary(result)$text

  expect_true(any(grepl("Alice", result_text)))
  expect_true(any(grepl("Paris", result_text)))
  expect_false(any(grepl("Optional:", result_text)))
  expect_false(any(grepl("\\{\\{optional\\}\\}", result_text)))

  unlink(c(template_path, output_path))

  # Test with percent signs
  template_path2 <- tempfile(fileext = ".docx")
  output_path2 <- tempfile(fileext = ".docx")

  doc2 <- officer::read_docx()
  doc2 <- officer::body_add_par(doc2, "Product: %product%")
  doc2 <- officer::body_add_par(doc2, "Discount: %discount%")
  doc2 <- officer::body_add_par(doc2, "Price: %price%")
  print(doc2, target = template_path2)

  replacements2 <- list(product = "Widget", discount = NA, price = "$9.99")
  sub_placeholders(
    template_path2,
    replacements2,
    output_path2,
    ph_start = "%",
    ph_end = "%"
  )

  result2 <- officer::read_docx(output_path2)
  result2_text <- officer::docx_summary(result2)$text

  expect_true(any(grepl("Widget", result2_text)))
  expect_true(any(grepl("\\$9\\.99", result2_text)))
  expect_false(any(grepl("Discount:", result2_text)))
  expect_false(any(grepl("%discount%", result2_text)))

  unlink(c(template_path2, output_path2))
})

test_that("docmerge creates multiple documents from dataframe", {
  # Create template
  template_path <- tempfile(fileext = ".docx")
  output_dir <- tempdir()

  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc, "Name: <<name>>")
  doc <- officer::body_add_par(doc, "City: <<city>>")
  print(doc, target = template_path)

  # Create test data
  input_data <- data.frame(
    name = c("Alice", "Bob"),
    city = c("Paris", "Berlin"),
    file_name = c("doc1", "doc2")
  )

  # Run docmerge
  result <- docmerge(template_path, input_data, output_dir)

  # Check that files were created
  expect_true(file.exists(file.path(output_dir, "doc1.docx")))
  expect_true(file.exists(file.path(output_dir, "doc2.docx")))

  # Check content of first document
  doc1 <- officer::read_docx(file.path(output_dir, "doc1.docx"))
  doc1_text <- officer::docx_summary(doc1)$text
  expect_true(any(grepl("Alice", doc1_text)))
  expect_true(any(grepl("Paris", doc1_text)))

  # Cleanup
  unlink(c(
    template_path,
    file.path(output_dir, "doc1.docx"),
    file.path(output_dir, "doc2.docx")
  ))
})

test_that("docmerge handles NA values in dataframe", {
  # Create template
  template_path <- tempfile(fileext = ".docx")
  output_dir <- tempdir()

  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc, "Name: <<name>>")
  doc <- officer::body_add_par(doc, "Address: <<address>>")
  doc <- officer::body_add_par(doc, "City: <<city>>")
  print(doc, target = template_path)

  # Create test data with NA
  input_data <- data.frame(
    name = c("Charlie"),
    address = NA,
    city = c("Tokyo"),
    file_name = c("doc_with_na")
  )

  # Run docmerge
  docmerge(template_path, input_data, output_dir)

  # Check that file was created
  output_file <- file.path(output_dir, "doc_with_na.docx")
  expect_true(file.exists(output_file))

  # Check content
  result_doc <- officer::read_docx(output_file)
  result_text <- officer::docx_summary(result_doc)$text

  # Non-NA values should be present
  expect_true(any(grepl("Charlie", result_text)))
  expect_true(any(grepl("Tokyo", result_text)))

  # NA paragraph should be removed
  expect_false(any(grepl("Address:", result_text)))
  expect_false(any(grepl("<<address>>", result_text)))

  # Cleanup
  unlink(c(template_path, output_file))
})

test_that("docmerge works with custom placeholder markup", {
  # Create template with curly braces
  template_path <- tempfile(fileext = ".docx")
  output_dir <- tempdir()

  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc, "Name: {{name}}")
  doc <- officer::body_add_par(doc, "Address: {{address}}")
  doc <- officer::body_add_par(doc, "City: {{city}}")
  print(doc, target = template_path)

  # Create test data with NA
  input_data <- data.frame(
    name = c("Diana", "Edward"),
    address = c(NA, "10 Downing St"),
    city = c("Rome", "London"),
    file_name = c("doc_curly1", "doc_curly2")
  )

  # Run docmerge with custom markup
  docmerge(
    template_path,
    input_data,
    output_dir,
    ph_start = "{{",
    ph_end = "}}"
  )

  # Check first document (with NA)
  output_file1 <- file.path(output_dir, "doc_curly1.docx")
  expect_true(file.exists(output_file1))

  result1 <- officer::read_docx(output_file1)
  result1_text <- officer::docx_summary(result1)$text

  expect_true(any(grepl("Diana", result1_text)))
  expect_true(any(grepl("Rome", result1_text)))
  expect_false(any(grepl("Address:", result1_text)))

  # Check second document (no NA)
  output_file2 <- file.path(output_dir, "doc_curly2.docx")
  expect_true(file.exists(output_file2))

  result2 <- officer::read_docx(output_file2)
  result2_text <- officer::docx_summary(result2)$text

  expect_true(any(grepl("Edward", result2_text)))
  expect_true(any(grepl("10 Downing St", result2_text)))
  expect_true(any(grepl("London", result2_text)))

  # Cleanup
  unlink(c(template_path, output_file1, output_file2))
})

test_that("sub_placeholders handles edge cases", {
  # Test with empty string (not NA)
  template_path <- tempfile(fileext = ".docx")
  output_path <- tempfile(fileext = ".docx")

  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc, "Name: <<name>>")
  doc <- officer::body_add_par(doc, "Note: <<note>>")
  print(doc, target = template_path)

  replacements <- list(name = "Test", note = "")
  sub_placeholders(template_path, replacements, output_path)

  result <- officer::read_docx(output_path)
  result_text <- officer::docx_summary(result)$text

  # Empty string should replace placeholder but keep paragraph
  expect_true(any(grepl("Test", result_text)))
  expect_true(any(grepl("Note:", result_text)))
  expect_false(any(grepl("<<note>>", result_text)))

  unlink(c(template_path, output_path))

  # Test with NULL value
  template_path2 <- tempfile(fileext = ".docx")
  output_path2 <- tempfile(fileext = ".docx")

  doc2 <- officer::read_docx()
  doc2 <- officer::body_add_par(doc2, "Field: <<field>>")
  print(doc2, target = template_path2)

  replacements2 <- list(field = NULL)
  sub_placeholders(template_path2, replacements2, output_path2)

  result2 <- officer::read_docx(output_path2)
  result2_text <- officer::docx_summary(result2)$text

  # NULL should be treated like NA and remove the paragraph
  expect_false(any(grepl("Field:", result2_text)))

  unlink(c(template_path2, output_path2))
})
