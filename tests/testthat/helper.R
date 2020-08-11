clean_test_cran <- function(cran_root) {
    withr::defer_parent(fs::dir_delete(cran_root))
}


make_test_library <- function() {
    test_library <- fs::dir_create(fs::path(tempdir(), "cranitor", "r_test_library"))
    withr::defer_parent(fs::dir_delete(test_library))

    return(test_library)
}


make_baz_archive <- function(tmp_file) {
    withr::with_tempdir({
        withr::defer(fs::dir_delete("baz"))
        fs::dir_create("baz")

        writeLines("foobar", con = fs::path("baz", tmp_file))

        targz_file <-  fs::path_temp("baz_0.0.1.tar.gz")
        # TODO: defer_parent causes "segfault from C stack overflow" in R 3.6.3, but not in 4.0.0
        # withr::defer_parent(fs::file_delete(targz_file))

        utils::tar(
            tarfile = targz_file, files = fs::path("baz", tmp_file),
            compression = "gzip", compression_level = 9L, tar = "tar"
        )
    })

    return(targz_file)
}
