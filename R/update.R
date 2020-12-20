#' Update local CRAN with the package
#'
#' Import package files into a local CRAN and update the metadata. Check the README in the repo.
#'
#' @param package_file The location of the package file in either `tar.gz` format (source/Linux),
#' `zip` (Windows) or `tgz` (Mac).
#' @param cran_root The folder containing the CRAN.
#' @param distro Only relevant for **binary** Linux packages. The name of the Linux distribution
#' compiling the package. The only restriction is that it should fit in a URL. As an example,
#' `ubuntu/focal` is a permitted name.
#'
#' @export
update_cran <- function(package_file, cran_root, distro = "ubuntu/focal") {
    switch(
        package_ext(package_file),
        "tar.gz" = update_cran_tar(package_file, cran_root, distro),
        "zip"    = update_cran_win(package_file, cran_root)
        # "tgz"    = update_cran_mac(package_file, cran_root)
    )
}


package_name_from_filename <- function(package_file) {
    package_file_sans_path <- basename(package_file)
    substr(package_file_sans_path, 1, regexpr("_", package_file_sans_path) - 1)
}
