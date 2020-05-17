cran_root <- fs::path_temp("cranitor_test", "demo_cran")


package_tbl <- tibble::tribble(
    ~package_name, ~version,
    "foo", "0.0.1",
    "foo", "0.0.2",
    "bar", "0.0.1",
)

package_names <- do.call(paste, c(package_tbl, sep = "_"))

src_package_paths <- purrr::pmap_chr(
    package_tbl, create_empty_package,
    binary = FALSE, quiet = TRUE, dest_path = fs::path_temp()
)

names(src_package_paths) <- package_names

if (is_win_or_mac()) {
    bin_package_paths <- purrr::pmap_chr(
        package_tbl, create_empty_package,
        binary = TRUE, quiet = TRUE, dest_path = fs::path_temp()
    )

    names(bin_package_paths) <- package_names
}

