test_that("Import non-package archive", {
    targz_file <- make_corrupted_archive("foobar")
    # TODO: Remove this defer when defer_parent in make_corrupted_archive works
    withr::defer(fs::file_delete(targz_file))

    expect_error(
        update_cran(targz_file, fs::path_temp("demo_cran")),
        "baz/DESCRIPTION does not exist"
    )
})


test_that("Import archive with corrupted DESCRIPTION", {
    targz_file <- make_corrupted_archive("baz/DESCRIPTION")
    # TODO: Remove this defer when defer_parent in make_corrupted_archive works
    withr::defer(fs::file_delete(targz_file))

    expect_error(
        update_cran(targz_file, fs::path_temp("demo_cran")),
        "Malformed DESCRIPTION"
    )
})
