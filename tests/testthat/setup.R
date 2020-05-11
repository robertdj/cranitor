create_empty_package <- function(package_name, version, ...) {
    package_path <- file.path(tempdir(), package_name)
    dir.create(package_path)
    withr::defer(fs::dir_delete(package_path))

    writeLines(
        "exportPattern(\"^[^\\\\.]\")",
        con = file.path(package_path, "NAMESPACE")
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
    con = file.path(package_path, "DESCRIPTION")
    )

    pkgbuild::build(path = package_path, ...)
}


package_tbl <- tibble::tribble(
    ~package_name, ~version,
    "foo", "0.0.1",
    "foo", "0.0.2",
    "bar", "0.0.1",
)

package_names <- do.call(paste, c(package_tbl, sep = "_"))

src_package_paths <- purrr::pmap_chr(
    package_tbl, create_empty_package,
    binary = FALSE, quiet = TRUE, dest_path = fs::path_temp()
)

names(src_package_paths) <- package_names

sysname <- tolower(Sys.info()[["sysname"]])
if ("windows" %in% sysname || "mac" %in% sysname) {
    bin_package_paths <- purrr::pmap_chr(
        package_tbl, create_empty_package,
        binary = TRUE, quiet = TRUE, dest_path = fs::path_temp()
    )

    names(bin_package_paths) <- package_names
}
