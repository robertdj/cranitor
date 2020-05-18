#' Make a demo CRAN
#'
#' @param cran_root The folder containing the demo CRAN. If `NULL`, the folder `demo_cran` will be
#' created in a temporary folder.
#' @param packages A vector of file names for packages to be imported. If empty, a number of
#' packages are made with [create_empty_package()].
#' @param binary Only relevant if `packages` is empty. Make binary packages in the demo CRAN? Only
#' used on Windows and macOS.
#'
#' @return The folder `cran_root`
#'
#' @export
make_demo_cran <- function(cran_root = NULL, packages = character(0), binary = FALSE) {
    if (is.null(cran_root))
        cran_root <- fs::path(fs::path_temp(), "demo_cran")

    assertthat::assert_that(
        assertthat::is.string(cran_root),
        # fs::is_dir(cran_root),
        is.character(packages),
        assertthat::is.flag(binary)
    )

    if (dir.exists(cran_root)) {
        warning(cran_root, " already exists. It is now replaced.")
        fs::dir_delete(cran_root)
    }

    # make_local_cran(cran_root)

    if (length(packages) == 0) {
        # TODO: Replace purrr with Map or mapply

        if (isTRUE(binary) && is_win_or_mac()) {
            binary <- c(TRUE, FALSE)
        } else {
            binary <- FALSE
        }

        # TODO: Get all combinations of names and `binary` with expand.grid
        package_params <- tidyr::crossing(
            data.frame(
                package_name = c("foo", "foo", "bar"),
                version = c("0.0.1", "0.0.2", "0.0.1")
            ),
            binary = binary
        )

        packages <- purrr::pmap_chr(package_params, create_empty_package, quiet = TRUE)
    }

    purrr::walk2(cran_root, packages, update_cran)

    clean_cran(cran_root)

    return(cran_root)
}


#' Make an empty package
#'
#' @param package_name The name of the package
#' @param version The version of the package
#' @param ... Arguments for [pkgbuild::build()]
#'
#' @details The package consists of a `DESCRIPTION` file and a `NAMESPACE` file.
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
