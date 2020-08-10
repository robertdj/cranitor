test_that("Import non-package archive", {
    targz_file <- make_baz_archive("foobar")
    # TODO: Remove this defer when defer_parent in make_baz_archive works
    withr::defer(fs::file_delete(targz_file))

    expect_error(
        update_cran(fs::path_temp("demo_cran"), targz_file),
        "baz/DESCRIPTION does not exist"
    )
})


test_that("Import archive with corrupted DESCRIPTION", {
    targz_file <- make_baz_archive("DESCRIPTION")
    # TODO: Remove this defer when defer_parent in make_baz_archive works
    withr::defer(fs::file_delete(targz_file))

    expect_error(
        update_cran(fs::path_temp("demo_cran"), targz_file),
        "Malformed DESCRIPTION"
    )
})
