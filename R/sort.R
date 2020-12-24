sort_files_by_version <- function(package_files) {
    # TODO: This is also tested in archive_source_single_package
    filenames_sans_path <- basename(package_files)
    package_name <- unique(package_name_from_filename(filenames_sans_path))

    if (length(package_name) != 1)
        stop("sort_files_by_version: Only archives of a single package allowed")

    package_file_pattern <- paste0(
        "^", package_name,
        "_(([[:digit:]]{1,}(\\.|_)){3,4}).*(tar\\.gz|tgz|zip)$"
    )

    version_numbers_plus_dot <- sub(package_file_pattern, "\\1", filenames_sans_path)
    version_numbers_as_strings <- substr(
        version_numbers_plus_dot, 1, nchar(version_numbers_plus_dot) - 1
    )
    version_numbers <- package_version(version_numbers_as_strings)

    package_files[order(version_numbers, decreasing = TRUE)]
}
