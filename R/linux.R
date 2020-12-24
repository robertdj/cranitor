update_cran_linux <- function(targz_file, cran_root, distro) {
    assertthat::assert_that(
        assertthat::is.string(cran_root),
        assertthat::is.string(distro)
    )

    r_version <- pkg.peek::get_r_version(targz_file)
    linux_dir <- linux_package_dir(r_version, distro, cran_root)
    # TODO: Check if linux_dir is a valid path

    import_linux_package(targz_file, linux_dir)

    archive_linux_packages(linux_dir)

    tools::write_PACKAGES(linux_dir, type = "source")
}


import_linux_package <- function(targz_file, linux_dir) {
    assertthat::assert_that(
        fs::is_file(targz_file),
        package_ext(targz_file) == "tar.gz",
        pkg.peek::is_package_built(targz_file)
    )

    if (isFALSE(fs::dir_exists(linux_dir))) {
        path <- tryCatch(
            fs::dir_create(linux_dir),
            error = identity
        )

        if (inherits(path, "identity"))
            rlang::abort(paste(linux_dir, "is not a valid path"))
    }

    meta <- pkg.peek::get_package_meta(targz_file)
    if (tolower(meta$Built$OStype) != "unix")
        stop(targz_file, " not built on Linux")

    pkg_name <- pkg.peek::get_package_name(targz_file)
    pkg_version <- pkg.peek::get_package_version(targz_file)
    imported_name <- paste0(pkg_name, "_", pkg_version, ".tar.gz")
    package_path <- fs::path(linux_dir, imported_name)

    fs::file_copy(targz_file, package_path)
}


archive_linux_packages <- function(linux_dir) {
    linux_packages <- fs::dir_ls(linux_dir, type = "file", glob = "*.tar.gz")

    package_names <- package_name_from_filename(linux_packages)
    packages_by_name <- split(linux_packages, package_names)

    purrr::walk(packages_by_name, archive_single_binary_package)
}
