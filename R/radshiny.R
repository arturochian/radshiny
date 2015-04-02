#' radshiny: A simple package to create multipage shiny apps
#'
#' The package provides one function, createRadShiny, which creates a shiny app in
#' the specified directory based on the navigation described in the input.
#'
#' @section Doesn't do much...
#'
#' @docType package
#' @name radshiny
NULL

.onLoad <- function(libname, pkgname) {
  op <- options()
  op.radshiny <- list(
    radshiny.path = "~/R-dev",
    radshiny.install.args = "",
    radshiny.name = "Ben Hunter",
    radshiny.desc.author = '"Ben Hunter <bjameshunter@gmail.com> [aut, cre]"',
    radshiny.desc.license = "MIT"
  )
  toset <- !(names(op.radshiny) %in% names(op))
  if(any(toset)) options(op.radshiny[toset])

  # packageStartupMessage("");

  invisible()
}

.onUnload <- function(libname, pkgname) {

}


#' Create multi-page shiny app
#'
#' Create multi-page shiny app in the specified directory with optional
#' navigation list.
#'
#' Lengthy description of this simple function
#'
#' @param dir directory under which app structure will be built. Defaults to cwd
#' @param nav A list or list of lists depicting the names in the navigation menu
#'   and submenus.
#'
#' @seealso \href{https://github.com/vnijs/radiant}{Radiant}
#' @aliases multipageshiny
#' @return Returns TRUE if everything worked out okay, else FALSE.
#' @examples
#' # the defaults
#' createRadShiny()
#' # custom navigation
#' createRadShiny('sweetApp', nav = list('home', 'p1', 'p2' = list('p2.1', 'p2.2')))
createRadShiny <- function(name = 'radshiny', dir = getwd(), nav,
                           packages = .additionalPackages,
                           tryPackages = c('DiagrammeR')) {

  ## provide a simple navigation if user hasn't specified
  if(missing(nav))
    nav <- list('page1', 'page2', 'page3' = list('sub1', 'sub2'))

  root <- file.path(dir, name)
  dir.create(file.path(root, 'www'), recursive = TRUE)
  .createDirectories(nav, root)

  # copy necessary www files
  file.copy(file.path(system.file(package='radshiny'), 'www'),
            root,
            recursive = TRUE)

  ## put requested packages in single string and write to global.R
  packageString <- paste(sapply(packages, function(d) { sprintf('library(%s)', d)}),
                         collapse = '\n')
  write(c(packageString, 'source("shinyUtils.R")'), file.path(root, 'global.R'))

  # create navigation from list and insert into ui.R
  navString <- paste0(.writeNav(nav, character()), collapse = ',\n')
  menu <- sprintf("library(shiny)\n\nmenus = tagList(\n%s\n)", navString)
  firstPage <- ifelse(names(nav)[1] == "", nav[[1]], names(nav)[1])
  uiString <- sprintf(.uiString, firstPage, firstPage)
  write(c(menu,"\n", uiString), file.path(root, 'ui.R'))

  # create server.R
  serverString <- sprintf(.serverString,
                          paste(.writeServer(nav), collapse = ''))
  write(serverString, file.path(root, 'server.R'))

  # write navigation functions to general utility file
  file.copy(file.path(system.file(package = 'radshiny'), "shinyUtils.R"),
            file.path(root, "shinyUtils.R"))
}

.createDirectories <- function(lst, directory) {
  for (i in 1:length(lst)) {
    if (is.list(lst[[i]])){
      .createDirectories(lst[[i]], file.path(directory, names(lst[i])))
    } else {
      dir.create(file.path(directory, lst[[i]]), recursive = TRUE)
      file.create(file.path(directory, lst[[i]], paste0(lst[[i]], '.R')))
      file.create(file.path(directory, lst[[i]], paste0(lst[[i]], '.Rmd')))
    }
  }
}

.writeServer <- function(lst, observers = character(), loc) {
  for (i in 1:length(lst)) {
    if (is.list(lst[[i]])) {
      relLoc <- ifelse(missing(loc), names(lst[i]),
                       file.path(loc, names(lst[i])))
      observers <- .writeServer(lst[[i]], observers = observers,
                                loc = relLoc)
    } else {
      relLoc <- ifelse(missing(loc), lst[[i]], file.path(loc, lst[[i]]))
      id = gsub(.Platform$file.sep, '_', relLoc)
      observers <- c(observers, sprintf(.observeString, id, relLoc))
    }
  }
  observers
}

.writeNav <- function(lst, navs = character(), prefix = '', depth = 1) {
  tabs <- paste0(rep('\t', depth), collapse = '')
  for (i in 1:length(lst)) {
    if (is.list(lst[[i]])) {
      tabs <- paste0(rep('\t', depth), collapse = '')
      pfix <- paste0(prefix, names(lst[i]),
                     sep = '_')
      nested <- paste(.writeNav(lst[[i]],
                                prefix = pfix,
                                depth = depth + 1),
                      collapse = ',\n')
      nested <- sprintf("%snavbarMenu('%s', \n%s%s\n)",
                        tabs,
                        R.utils::capitalize(names(lst[i])),
                        nested,
                        tabs)
      navs <- c(navs, nested)
    } else {
      navs <- c(navs, sprintf("%stabPanel('%s', id = '%s')",
                              tabs,
                              R.utils::capitalize(lst[[i]]),
                              paste(prefix, lst[[i]], sep = '')))
    }
  }
  navs
}
