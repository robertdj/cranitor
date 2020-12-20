#' Make a demo CRAN
#'
#' @param packages A vector of file names for packages to be imported. If empty, a number of
#' packages are made with [create_empty_package()].
#' @param cran_root The folder containing the demo CRAN. If `NULL`, the folder `demo_cran` will be
#' created in a temporary folder.
#' @param binary Only relevant if `packages` is empty. Make binary packages in the demo CRAN? Only
#' used on Windows and macOS.
#' @param distro Only relevant on Linux and when `binary` is `TRUE`. An indicative name of the Linux
#' distribution being used. The only restriction is that it should fit in a URL. As an example,
#' `ubuntu/focal` is a permitted name.
#'
#' @return The folder `cran_root`
#'
#' @export
make_demo_cran <- function(packages = character(0), cran_root = NULL, binary = FALSE,
                           distro = NA_character_) {
    if (is.null(cran_root))
        cran_root <- make_random_demo_cran_path()

    assertthat::assert_that(
        is.character(packages),
        assertthat::is.string(cran_root),
        assertthat::is.flag(binary)
    )

    if (binary && is_linux() && is.na(distro))
        rlang::abort("For binary packages 'distro' must be set")

    if (dir.exists(cran_root)) {
        stop(cran_root, " already exists.")
    }

    if (length(packages) == 0) {
        if (isTRUE(binary)) {
            binary <- c(TRUE, FALSE)
        } else {
            binary <- FALSE
        }

        package_params <- merge(
            data.frame(
                package_name = c("foo", "foo", "bar"),
                version = c("0.0.1", "0.0.2", "0.0.1")
            ),
            as.data.frame(binary)
        )

        packages <- purrr::pmap_chr(package_params, create_empty_package, quiet = TRUE)
    }

    purrr::walk(packages, update_cran, cran_root = cran_root, distro = distro)

    clean_cran(cran_root)

    return(cran_root)
}


make_random_demo_cran_path <- function() {
    fs::path_temp("demo_cran", strftime(Sys.time(), format = "%Y-%m-%d_%H-%M-%S"))
}


#' Make an empty package
#'
#' @param package_name The name of the package
#' @param version The version of the package
#' @param ... Arguments for [pkgbuild::build()]
#'
#' @details The package consists of a `DESCRIPTION` file and a `NAMESPACE` file.
#' Note that the `pkgbuild` package is required.
#'
#' @return The path of the built package.
#'
#' @export
create_empty_package <- function(package_name, version, ...) {
    if (!rlang::is_installed("pkgbuild"))
        rlang::abort("'create_empty_package' requires pkgbuild")

    package_path <- fs::path_temp(package_name)
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
