source_package_dir <- function(cran_root) {
    fs::path(cran_root, "src", "contrib")
}


win_package_dir <- function(cran_root, r_version = getRversion()) {
    assertthat::assert_that(
        inherits(r_version, "R_system_version")
    )

    fs::path(
        cran_root, "bin", "windows", "contrib", paste0(r_version$major, ".", r_version$minor)
    )
}


list_win_package_dirs <- function(cran_root) {
    # TODO: Not so elegant with dirname
    win_dir <- dirname(win_package_dir(cran_root))

    if (isFALSE(fs::dir_exists(win_dir)))
        return(list())

    win_versions_as_strings <- basename(fs::dir_ls(win_dir, type = "dir"))

    R_system_version(paste(win_versions_as_strings, "0", sep = "."))
}



mac_package_dir <- function(cran_root) {
    # TODO: macOS name?
    fs::path(cran_root, "bin", "macosx", "contrib")
}


archive_metadata_path <- function(cran_root) {
    fs::path(source_package_dir(cran_root), "Meta", "archive.rds")
}


archive_path <- function(cran_root) {
    fs::path(source_package_dir(cran_root), "Archive")
}

