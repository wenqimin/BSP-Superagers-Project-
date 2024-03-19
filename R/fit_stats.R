
#' Model fit statistics
#'
#' @param dat Data list of control and superager in long format.
#' @param res
#' @param glmnet Logical. Which package engine to use.
#' @param s lambda; default \code{NA}
#'
#' @return RMSE, R-squared, obs vs predicted
#' @references \url{https://en.wikipedia.org/wiki/List_of_Crayola_crayon_colors}
#'             \url{https://glmnet.stanford.edu/articles/glmnet.html}
#' @export
#'
fit_stats <- function(dat,
                      res,
                      glmnet = FALSE,
                      s = NA) {
  
  ct_long <- dat$ct_long
  sa_long <- dat$sa_long
  
  # transform to wide format
  controls <-
    ct_long %>%
    arrange(region) %>%
    dcast(id ~ Label, value.var = "value") %>%
    mutate(status = 0) %>%
    select(-id)
  
  superagers <-
    sa_long %>%
    arrange(region) %>%
    dcast(id ~ Label, value.var = "value") %>%
    mutate(status = 1) %>%
    select(-id)
  
  dat <-
    rbind(controls, superagers) %>%
    as.data.frame() %>%
    mutate(status = as.factor(status))
  
  ##TODO:
  if (glmnet) {
    pred <- predict(res,
                    newx = as.matrix(dat[, 1:(ncol(dat)-1)]),
                    s = s,
                    type = "class")
    ppred <- predict(res,
                     newx = as.matrix(dat[, 1:(ncol(dat)-1)]),
                     s = s,
                     type = "response") # prob
  } else {
    pred <- predict(res, dat, type = "raw")
    ppred <- predict(res, dat, type = "prob")
  }
  
  ## from cv.glmnet
  # pred.glmnet <-
  #   predict(res$finalModel,
  #           newx = dat,
  #           type = "response",
  #           s = res$bestTune$lambda)
  #           # s = "lambda.min")
  
  # prediction performance against data
  stats <-
    data.frame(
      RMSE = RMSE(as.numeric(pred),
                  as.numeric(dat$status)),
      Rsquare = R2(as.numeric(pred),
                   as.numeric(dat$status)))
  
  list(pred = pred,
       # pred.glmnet = pred.glmnet,
       ppred = ppred,
       stats = stats,
       obs_status = as.numeric(dat$status))
}
