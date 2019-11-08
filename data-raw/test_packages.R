create_empty_package <- function(package_name, version) {
    package_path <- file.path(tempdir(), package_name)
    dir.create(package_path)

    writeLines(
        "exportPattern(\"^[^\\\\.]\")",
        file.path(package_path, "NAMESPACE")
    )

    writeLines(c(
        paste("Package:", package_name),
        "Title: What the Package Does (One Line, Title Case)",
        paste("Version:", version),
        "Authors@R:",
        "    person(given = 'First',",
        "           family = 'Last',",
        "           role = c('aut', 'cre'),",
        "           email = 'first.last@example.com',",
        "           comment = c(ORCID = 'YOUR-ORCID-ID'))",
        "Description: What the package does (one paragraph).",
        "License: What license it uses",
        "Encoding: UTF-8",
        "LazyData: true"),
        file.path(package_path, "DESCRIPTION")
    )

    devtools::build(pkg = package_path)
}


file.copy(create_empty_package("foo", "0.0.1"), here::here("inst", "testdata"), overwrite = TRUE)
file.copy(create_empty_package("foo", "0.0.2"), here::here("inst", "testdata"), overwrite = TRUE)

file.copy(create_empty_package("bar", "0.0.1"), here::here("inst", "testdata"), overwrite = TRUE)
