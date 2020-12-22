package_tbl <- data.frame(
    package_name = c("foo", "foo", "bar"),
    version = c("0.0.1", "0.0.2", "0.0.1")
)


# Source --------------------------------------------------------------------------------------

package_names <- do.call(paste, c(package_tbl, sep = "_"))

src_package_paths <- purrr::pmap_chr(
    package_tbl, create_empty_package,
    binary = FALSE, quiet = TRUE, dest_path = fs::path_temp()
)

names(src_package_paths) <- package_names


# Binary --------------------------------------------------------------------------------------

bin_package_paths <- purrr::pmap_chr(
    package_tbl, create_empty_package,
    binary = TRUE, quiet = TRUE, dest_path = fs::path_temp()
)

names(bin_package_paths) <- package_names

package_paths <- c(src_package_paths, bin_package_paths)
