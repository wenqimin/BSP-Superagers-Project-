#' Model fit statistics
#'
#' @param dat Data list of control and superager in wide format.
#' @param res
#' @param lambda
#' @param s lambda; default \code{NA}
#'
#' @return Accuracy, AUC, obs vs predicted
#' @references \url{https://en.wikipedia.org/wiki/List_of_Crayola_crayon_colors}
#'             \url{https://glmnet.stanford.edu/articles/glmnet.html}
#' @export
#'
fit_stats_rf <- function(dat,
                      res) {
  
    pred <- predict(res,
                    newx = as.matrix(dat[, 1:(ncol(dat)-1)]),
                    type = "response")
    ppred <- predict(res,
                     newx = as.matrix(dat[, 1:(ncol(dat)-1)]),
                     type = "prob") # prob

  
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
