context("date")

test_that("datetimes are converted to e.g. 2013-01-02 05:00:00", {
  in.str <- c("17 Mar 1983 06:33:44 AM",
                "17 Mar 1984 01:59:55 PM")
  time.obj <- strptime(in.str, "%d %b %Y %I:%M:%S %p")
  out.str <- strftime(time.obj, "%Y-%m-%d %H:%M:%S")
  df <- rbind(data.frame(who="me", time.obj, dollars=c(1.1, 5.6)),
              data.frame(who="you", time.obj, dollars=c(10.2, 0)))
  gg <- qplot(time.obj, dollars, data=df, color=who, geom="line")
  info <- gg2list(gg)
  expect_equal(length(info), 3)
  expect_identical(info$kwargs$layout$xaxis$type, "date")
  for(trace in info[1:2]){
    expect_identical(trace$x, out.str)
  }

  save_outputs(gg, "date-strings")
})

test_that("class Date is supported", {
  df <- data.frame(x=c("2013-01-01", "2013-01-02", "2013-01-03"),
                   y=c(2, 3, 2.5))
  df$x <- as.Date(df$x)
  gg <- ggplot(df) + geom_line(aes(x=x, y=y))
  info <- gg2list(gg)
  expect_equal(length(info), 2)
  expect_identical(info$kwargs$layout$xaxis$type, "date")
  expect_identical(info[[1]]$x[1], "2013-01-01 00:00:00")

  save_outputs(gg, "date-class-Date")
})

test_that("scale_x_date and irregular time series work", {
  set.seed(423)
  df <- data.frame(date = seq(as.Date("2121-12-12"), len=100, by="1 day")[sample(100, 50)],
                   price = runif(50))
  df <- df[order(df$date), ]
  dt <- qplot(date, price, data=df, geom="line") + theme(aspect.ratio = 1/4)
  g <- dt + scale_x_date()
  ## for future tests: (uses package 'scales')
  # g2 <- dt + scale_x_date(breaks=date_breaks("1 week"),
  #                        minor_breaks=date_breaks("1 day"),
  #                        labels = date_format("%b/%W"))

  info <- gg2list(dt)
  info_w_scale <- gg2list(g)

  expect_equal(length(info), 2)  # one trace + layout
  expect_identical(info[[1]]$x[31], "2122-02-09 00:00:00")
  expect_equal(length(info_w_scale), 2)  # one trace + layout
  expect_identical(info_w_scale[[1]]$x[31], "2122-02-09 00:00:00")
  expect_identical(info$kwargs$layout$xaxis$type, "date")
  expect_identical(info_w_scale$kwargs$layout$xaxis$type, "date")
  expect_equal(length(info_w_scale[[2]]), length(info[[2]]))  # similar layout

  save_outputs(dt, "date-irregular-time-series")
})
