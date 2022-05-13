compare_me <- function(dat1, dat2) {
  
  is.even <- function(x) x %% 2 == 0
  
  xx <- full_join(x = dat1,
                  y = dat2) %>% 
    group_by_at(1) %>%
    filter(n() != 1) %>%
    ungroup() %>%
    arrange_at(1)
  
  out <- split(xx, f = xx[,1])
  
  mini <- map(out, .f = list(. %>% select(where(~n_distinct(.) > 1)))) %>% 
    bind_rows(.id = "groups") %>%
    rename(idvar = groups) %>%
    pivot_longer(cols = -c(idvar),
                 names_to = "name",
                 values_to = "value") %>%
    na.omit() %>%
    mutate(row = as.numeric(row_number())) %>%
    mutate(file = if_else(is.even(row) == TRUE, "dat2", "dat1")) %>%
    select(-row) %>%
    pivot_wider(
      id_cols = c(idvar, name),
      names_from = file, 
      values_from = value) %>%
    as.data.frame()
  
  return(mini)
}
