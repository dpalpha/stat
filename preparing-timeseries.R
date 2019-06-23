library(lubridate)

dataset = read.csv('dataset212.csv')

elapsed_months <- function(end_date, start_date) {
    ed <- as.POSIXlt(end_date)
    sd <- as.POSIXlt(start_date)
    12 * (ed$year - sd$year) + (ed$mon - sd$mon)
}

mob<-function (begin, end) {
      begin<-paste(substr(begin,1,6),"01",sep="")
      end<-paste(substr(end,1,6),"01",sep="")
      mob1<-as.period(interval(ymd(begin),ymd(end)))
      mob<-mob1@year*12+mob1@month
      mob
}

mos<-function (begin, end) {
      mos1<-as.period(interval(ymd(begin),ymd(end)))
      mos<-mos1@year*12+mos1@month
      mos
}

dataset = dataset %>% mutate(
            'M9' = as.Date(datetime) %m+% months(9) <= Sys.Date(),
            'M12' = as.Date(datetime) %m+% months(12) <= Sys.Date(),
            'M18' = as.Date(datetime) %m+% months(18) <= Sys.Date(),
            'diffd' = as.double(difftime(lubridate::ymd(as.Date(datetime)),lubridate::ymd(Sys.Date()),units = "days")),
            'mos' = mos(as.Date(datetime), Sys.Date()),
            'mob' = mos(as.Date(datetime), Sys.Date()),
            'elapsed_months' = elapsed_months(as.Date(datetime), Sys.Date())
    
    
)
