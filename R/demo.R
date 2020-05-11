#' Make a demo CRAN
#'
#' @param cran_root The folder containing the demo CRAN. If `NULL`, the folder `demo_cran` will be
#' created in a temporary folder.
#'
#' @return The folder `cran_root`
#'
#' @export
make_demo_cran <- function(cran_root = NULL) {
    if (is.null(cran_root))
        cran_root <- fs::path(fs::path_temp(), "demo_cran")

    if (dir.exists(cran_root)) {
        warning(cran_root, " already exists. It is now replaced.")
        unlink(cran_root, recursive = TRUE)
    }

    make_local_cran(cran_root)

    import_source_package(cran_root, create_empty_package("foo", "0.0.1", quiet = TRUE))
    import_source_package(cran_root, create_empty_package("foo", "0.0.2", quiet = TRUE))
    import_source_package(cran_root, create_empty_package("bar", "0.0.1", quiet = TRUE))

    archive_package(cran_root, "foo")
    archive_package(cran_root, "bar")

    make_archive_metadata(cran_root)

    tools::write_PACKAGES(source_package_dir(cran_root), type = "source")

    return(cran_root)
}


#' Make a demo package
#'
#' @param package_name The name of the package
#' @param version The version of the package
#' @param ... Parameters for [pkgbuild::build()]
#'
#' @details The demo package consists of a `DESCRIPTION` file and a `NAMESPACE` file.
#'
#' @return The path of the built package.
#'
#' @export
create_empty_package <- function(package_name, version, ...) {
    package_path <- fs::path(tempdir(), package_name)
    fs::dir_create(package_path)
    withr::defer(fs::dir_delete(package_path))

    writeLines(
        "exportPattern(\"^[^\\\\.]\")",
        con = fs::path(package_path, "NAMESPACE")
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
    con = fs::path(package_path, "DESCRIPTION")
    )

    pkgbuild::build(path = package_path, ...)
}
