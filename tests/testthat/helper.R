clean_test_cran <- function(cran_root) {
    withr::defer_parent(fs::dir_delete(cran_root))
}


make_test_library <- function() {
    test_library <- fs::dir_create(fs::path(tempdir(), "cranitor", "r_test_library"))
    withr::defer_parent(fs::dir_delete(test_library))

    return(test_library)
}
