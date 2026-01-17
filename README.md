# docmerge

<!-- badges: start -->
<!-- badges: end -->

docmerge helps you to generate multiple Microsoft Word documents from R. You can use a Word document as a template, with placeholders for data to be filled in from R. docmerge will then create a separate Word document for each row of data you provide.

## Installation

You can install the development version of docmerge [GitHub](https://github.com/DavidASmith/docmerge) with:

``` r
# install.packages("devtools")
devtools::install_github("DavidASmith/docmerge)")
```

## Example

Create a Word document to use as a template, with placeholders for the text you want to change in each output document. By default, placeholders are indicated by double angle brackets, e.g. `<<name>>`.

An example template is included with the package. It's path can be found like this:

``` r
example_template <- system.file(
  "extdata",
  "letter_template.docx",
  package = "docmerge"
)
```

Then create a data frame with the data to fill in the placeholders. An example data frame is included in the package:

``` r
gift_details
```

Then use docmerge to generate documents (one for each row in the data frame):

``` r
docmerge(default_template, gift_details)
```

Output Word documents are written to the current working directory. You can specify an alternative using the `output_path` argument.

Note that you can specify the output file name by including a column named `file_name` in your data frame. If this ia absent, files will be named `1.docx`, `2.docx`, etc.