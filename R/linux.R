update_cran_linux <- function(targz_file, cran_root, distro) {
    assertthat::assert_that(
        assertthat::is.string(cran_root),
        fs::is_file(targz_file),
        package_ext(targz_file) == "tar.gz",
        assertthat::is.string(distro),
        pkg.peek::is_package_built(targz_file)
    )

    meta <- pkg.peek::get_package_meta(zip_file)
    if (tolower(meta$Built$OStype) != "unix")
        stop(zip_file, " not built on Linux")

    r_version <- pkg.peek::get_r_version(targz_file)
    linux_dir <- linux_package_dir(r_version, distro, cran_root)
    if (linux_dir != fs::path_sanitize(linux_dir))
        rlang::abort(paste0("'", linux_dir, "' is not a valid path"))

    import_linux_package(targz_file, linux_dir)

    archive_linux_packages(linux_dir)

    tools::write_PACKAGES(linux_dir, type = "source")
}


import_linux_package <- function(targz_file, linux_dir) {
    if (isFALSE(fs::dir_exists(linux_dir)))
        fs::dir_create(linux_dir)

    # TODO: copy or move?
    fs::file_copy(targz_file, linux_dir)
}


archive_linux_packages <- function(linux_dir) {
    linux_packages <- fs::dir_ls(linux_dir, type = "file", glob = "*.tar.gz")

    package_names <- package_name_from_filename(linux_packages)
    packages_by_name <- split(linux_packages, package_names)

    purrr::walk(packages_by_name, archive_single_linux_package)
}


archive_single_linux_package <- function(package_files) {
    package_name <- unique(package_name_from_filename(package_files))
    assertthat::assert_that(
        assertthat::is.string(package_name)
    )

    if (length(package_files) <= 1)
        return(invisible(NULL))

    sorted_packages <- sort_files_by_version(package_files)

    fs::file_delete(sorted_packages[-1])
}
