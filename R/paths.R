source_package_dir <- function(cran_root) {
    fs::path(cran_root, "src", "contrib")
}


linux_package_dir <- function(r_version, distro, cran_root) {
    fs::path(cran_root, "__linux__", distro, r_version, "src", "contrib")
}


win_base_package_dir <- function(cran_root) {
    fs::path(cran_root, "bin", "windows", "contrib")
}


win_package_dir <- function(r_version = getRversion(), cran_root) {
    UseMethod("win_package_dir", r_version)
}


win_package_dir.character <- function(r_version, cran_root) {
    assertthat::assert_that(
        assertthat::is.string(r_version)
    )

    version_parts <- strsplit(r_version, split = ".", fixed = TRUE)[[1]]
    if (!all(grepl("[[:digit:]]+", version_parts)))
        rlang::abort("Only numbers are allowed in R version")

    if (length(version_parts) == 2) {
        version_string <- r_version
    } else if (length(version_parts) == 3) {
        version_string <- paste(version_parts[1:2], collapse = ".")
    } else {
        rlang::abort("Version number should have 2 or 3 digits")
    }

    fs::path(win_base_package_dir(cran_root), version_string)
}


win_package_dir.R_system_version <- function(r_version, cran_root) {
    fs::path(
        win_base_package_dir(cran_root), paste0(r_version$major, ".", r_version$minor)
    )
}


list_win_package_dirs <- function(cran_root) {
    win_dir <- win_base_package_dir(cran_root)

    if (isTRUE(fs::dir_exists(win_dir))) {
        basename(fs::dir_ls(win_dir, type = "dir"))
    } else {
        return(character(0))
    }
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

