clean_test_cran <- function(cran_root) {
    withr::defer_parent(fs::dir_delete(cran_root))
}
