#' Create the filter sequence container
#'
#' This function combines rules into a sequence container
#'
#' @param context Defines the level that the filter logic should operate on. Valid values for sequential filters is visitors and visits. See Details
#' @param rules List of rules created using `filter_rule()` function. Must wrapped in a list() function.
#' @param sequence  How should the sequence of items be considered. Options: `in_order` (default), `before`, `after`, `and`, `or`
#' @param exclude Excludes the entire sequence container which will include all rules.
#' @param exclude_checkpoint Which checkpoints (rules) should be excluded. Example `c(1, 4)`. See Details
#'
#' @details
#'
#' **Context**
#'
#' The rules in a filter have a context that specify the level of operation. The context can be visitors, visits or hits.
#' As an example, let's build a filter rule where revenue is greater than 0 (meaning a purchase took place) and change the context to see how things change.
#' If the context is set to visitors, the filter includes all hits from visitors that have a purchase of some kind during a visit. This is useful in analyzing customer behavior in visits leading up to a purchase and possibly behavior after a purchase.
#' the context is set to visits, the filter includes all hits from visits where a purchase occurred. This is useful for seeing the behavior of a visitor in immediate page views leading up to the purchase.
#' If the context is set to hit, the filter only includes hits where a purchase occurred, and no other hits. This is useful in seeing which products were most popular.
#' In the above example, the context for the container listed is hits. This means that the container only evaluates data at the hit level, (in contrast to visit or visitor level). The rows in the container are also at the hit level.
#'
#' **Exclude checkpoint**
#'
#' Ensures the next checkpoint doesn't happen between the
#' preceding checkpoint and the subsequent checkpoint. If there is no subsequent
#' checkpoint then the excluded checkpoint must not occur at any point after
#' the preceding checkpoint. If there is no preceding checkpoint then the
#' excluded checkpoint must not have occurred at any point preceding the
#' subsequent checkpoint.
#'
#' **More Information**
#'
#' Sequential filters can be difficult to get right. Referencing this article
#' can help: https://experienceleague.adobe.com/docs/analytics-platform/using/cja-components/cja-filters/filters-overview.html?lang=en
#'
#' @example
#' \dontrun
#' # basic use case
#' filter_seq(context = 'visits', rules = list(rule1, rule2),
#' sequence = 'in_order', exclude = FALSE)
#'
#' @return a structured list of containers to be used to build the filter
#'
#' @import dplyr assertthat stringr
#'
#' @export
#'
#'
filter_seq <- function(context = 'visits',
                       rules = NULL,
                       sequence = 'in_order',
                       exclude = FALSE,
                       exclude_checkpoint = NULL) {

  # validate 'sequence' argument value
  if (!sequence %in% c("in_order", "after", "before", "and", "or")) {
    stop("Make sure the `sequence` argument is either 'in_order' (default), 'after', 'before', 'and', or 'or'.")
  }
  # validate 'context' argument value
  if (!context %in% c("hits", "visits", "visitors")) {
    stop("Make sure the `context` argument is either 'hits', 'visits' (default), or 'visitors'")
  }
  # validate 'exclude' argument value
  if (!is.logical(exclude)) {
    stop("The argument `exclude` must be either True or False.")
  }
  # validate 'exclude_checkpoint' argument value
  if (!is.null(exclude_checkpoint) & !is.numeric(exclude_checkpoint)) {
    stop("The argument 'exclude_checkpoint' needs to be NULL, a single number, or a vector of numbers defining the rules you want to exclude.")
  }
  #define the sequence direction
  f.seq_dir <- function(sequence){
    dplyr::case_when(sequence == 'in_order' ~ 'sequence',
                     sequence == 'after' ~ 'sequence-prefix',
                     sequence == 'before' ~ 'sequence-suffix',
                     sequence == 'and' ~ 'sequence-and',
                     sequence == 'or' ~ 'sequence-or')
  }
  sequence_dir <- f.seq_dir(sequence)
  ## Append the exclusion list item
  if (!is.null(exclude_checkpoint)) {
    new_checkpoints <- (exclude_checkpoint-1) + (seq(length(exclude_checkpoint)) - 1)
    for (i in new_checkpoints) {
      rules <- append(rules,
                      list(list(func = 'exclude-next-checkpoint')),
                      after = i)
    }
  }
  ## Add in the necessary 'container' and 'hits' variables to each rule for the sequence to work
  rule_items <- list()
  for (i in seq_along(rules)) {
    if (!is.null(rules[[i]]$val)) {
      rule_items <- append(rule_items, list(
        list(context = 'hits',
             func = 'container',
             pred = rules[[i]])
      ))
    } else if (length(rules[[i]]) == 2) {
      if (is.list(rules[[i]][[1]])){
        for(item in seq(length(rules[[i]]))) {
          rule_items <- append(rule_items, rules[[i]][item])
        } }
    } else {
      rule_items <- append(rule_items, list(rules[[i]]))
    }
  }

  ##Create the different json strings
  f.sequence <- function(context, sequence_dir, rule_items, exclude) {
    if (!exclude) {
      list(
        func = 'container',
        context = context,
        pred = list(
          func = sequence_dir,
          stream = rule_items
        )
      )
    } else if (exclude) {
      list(
        func = 'container',
        context = context,
        pred = list(
          func = 'without',
          pred = list(
            func = sequence_dir,
            stream = rule_items
          )
        )
      )
    }
  }
  f.pref_suff <- function(context, sequence_dir, rule_items, exclude) {
    if (exclude == FALSE) {
      list(
        func = 'container',
        context = context,
        pred = list(
          func = sequence_dir,
          context = context,
          stream = rule_items
        )
      )
    } else if (exclude == TRUE) {
      list(
        func = 'container',
        context = context,
        pred = list(
          func = 'without',
          pred = list(
            func = sequence_dir,
            context = context,
            stream = rule_items
          )
        )
      )
    }
  }
  f.and_or <- function(context, sequence_dir, rule_items, exclude) {
    if (exclude == FALSE) {
      list(
        func = 'container',
        context = context,
        pred = list(
          func = sequence_dir,
          checkpoints = rule_items
        )
      )
    } else if (exclude == TRUE){
      list(
        func = 'container',
        context = context,
        pred = list(
          func = 'without',
          pred = list(
            func = sequence_dir,
            checkpoints = rule_items
          )
        )
      )
    }
  }
  sequence_items <- if (sequence_dir == 'sequence') {
    f.sequence(context, sequence_dir, rule_items, exclude)
  } else if (sequence_dir %in% c('sequence-prefix', 'sequence-suffix')) {
    f.pref_suff(context, sequence_dir, rule_items, exclude)
  } else if (sequence_dir %in% c('sequence-and', 'sequence-or')) {
    f.and_or(context, sequence_dir = rule_items, exclude)
  }
  sequence_items
}

