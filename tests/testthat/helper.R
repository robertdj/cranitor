make_test_library <- function() {
    fs::dir_create(fs::path(tempdir(), "cranitor", "r_test_library"))
}


make_corrupted_archive <- function(tmp_file) {
    withr::with_tempdir({
        fs::dir_create(dirname(tmp_file))
        writeLines("foobar", con = tmp_file)

        targz_file <- fs::path_temp("baz_0.0.1.tar.gz")

        utils::tar(
            tarfile = targz_file, files = tmp_file,
            compression = "gzip", compression_level = 9L, tar = "tar"
        )
    })

    return(targz_file)
}
