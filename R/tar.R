update_cran_tar <- function(targz_file, cran_root, distro) {
    assertthat::assert_that(
        assertthat::is.string(cran_root),
        fs::is_file(targz_file),
        package_ext(targz_file) == "tar.gz"
    )

    if (pkg.peek::is_package_built(targz_file)) {
        update_cran_linux(targz_file, cran_root, distro)
    } else {
        update_cran_source(targz_file, cran_root)
    }
}
