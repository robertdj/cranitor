create_empty_package <- function(package_name, version) {
    package_path <- file.path(tempdir(), package_name)
    dir.create(package_path)

    writeLines(
        "exportPattern(\"^[^\\\\.]\")",
        file.path(package_path, "NAMESPACE")
    )

    writeLines(c(
        paste("Package:", package_name),
        "Title: Test package for cranitor",
        paste("Version:", version),
        "Authors@R: person('First', 'Last', role = c('aut', 'cre'), email = 'first.last@example.com')",
        "Description: Test package for cranitor.",
        "License: MIT",
        "Encoding: UTF-8",
        "LazyData: true"
    ),
    file.path(package_path, "DESCRIPTION")
    )

    pkgbuild::build(path = package_path, binary = FALSE)
}


file.copy(create_empty_package("foo", "0.0.1"), here::here("inst", "testdata"), overwrite = TRUE)
file.copy(create_empty_package("foo", "0.0.2"), here::here("inst", "testdata"), overwrite = TRUE)

file.copy(create_empty_package("bar", "0.0.1"), here::here("inst", "testdata"), overwrite = TRUE)
