is_win_or_mac <- function() {
    sysname <- tolower(Sys.info()[["sysname"]])

    if ("windows" %in% sysname || "mac" %in% sysname) {
        return(TRUE)
    } else {
        return(FALSE)
    }
}


package_ext <- function(package_file) {
    if (endsWith(package_file, ".tar.gz")) {
        file_ext <- "tar.gz"
    } else {
        file_ext <- tools::file_ext(package_file)
    }

    match.arg(file_ext, c("tar.gz", "tgz", "zip"))
}


package_name_from_filename <- function(package_file) {
    package_file_sans_path <- basename(package_file)
    substr(package_file_sans_path, 1, regexpr("_", package_file_sans_path) - 1)
}
