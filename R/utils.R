is_win_or_mac <- function() {
    sysname <- tolower(Sys.info()[["sysname"]])

    if ("windows" %in% sysname || "mac" %in% sysname) {
        return(TRUE)
    } else {
        return(FALSE)
    }
}


package_ext <- function(package_file) {
    if (endsWith(package_file, ".tar.gz"))
        return("tar.gz")

    file_ext <- tools::file_ext(package_file)
    if (file_ext %in% c("tgz", "zip"))
        return(file_ext)

    stop("'", file_ext, "' is not a valid package file extention")
}


is_installed <- function(pkg) {
    isTRUE(requireNamespace(pkg, quietly = TRUE))
}
