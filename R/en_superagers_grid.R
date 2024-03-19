
#' Elastic net superagers over a grid of alpha, lambda
#'
#' Use (tidy) long data format as input.
#'
#' @param dat list of ct_long and sa_long dataframes
#' @param best_lambda_method oneSE or best?
#' @param lambda_seq Define lambdas in advance; vector
#' @param alpha_seq The elasticnet mixing parameter, with \eqn{0≤\alpha≤1}. The penalty is defined as
#'              \eqn{(1-α)/2||β||_2^2+α||β||_1}. \code{alpha=1} is the lasso penalty,
#'              \code{alpha=0} the ridge penalty.
#' @param pmax Limit the maximum number of variables ever to be non-zero
#' @return the result of running \link{\code{train}}
#'
#' @import caret glmnet
#' @export
#'
en_superagers_grid <- function(dat,
                               best_lambda_method = "oneSE",
                               lambda_seq = c(0.5, 0.4, 0.3, 0.2, 0.1, 0.01),
                               alpha_seq = c(0,0.5,1),
                               pmax = 10,
                               nfolds = 10) {
  
  ct_long <- dat$ct_long
  sa_long <- dat$sa_long
  
  # transform to wide format
  controls <-
    ct_long |>
    arrange(region) |>
    dcast(id ~ Label, value.var = "value") |>
    mutate(status = 0) |>
    select(-id)
  
  superagers <-
    sa_long |>
    arrange(region) |>
    dcast(id ~ Label, value.var = "value") |>
    mutate(status = 1) |>
    select(-id)
  
  dat <-
    rbind(controls, superagers) |>
    as.data.frame() |>
    mutate(status = as.factor(status))
  
  # all combinations
  tuneGrid <- expand.grid(alpha = alpha_seq,
                          lambda = lambda_seq)
  
  # fit model
  model <- caret::train(
    status ~ .,
    data = dat,
    method = "glmnet",
    tuneGrid = tuneGrid,
    # preProcess = c("center", "scale"),
    trControl = trainControl(
      # method = "cv",   # resampling method
      method = "repeatedcv",
      # method = "LOOCV",  ##TODO: why doesn't this work?
      selectionFunction = best_lambda_method,   # how to pick optimal tuning parameter
      # oneSE addresses over fit
      number = nfolds, # cv folds
      repeats = 10
    )#,
    # threshold = 0.3,
    # tuneLength = 25    # number of alpha, lambda to try ie granularity grid
  )
 
  model
}

