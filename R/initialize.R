# Mini CRAN wrapper ---------------------------------------------------------------------------

#' Make a local CRAN
#'
#' Make a local CRAN with source packages and binary packages for Windows.
#'
#' @inheritParams update_cran
make_local_cran <- function(cran_root) {
    fs::dir_create(source_package_dir(cran_root))
    fs::dir_create(win_package_dir(cran_root))
}

