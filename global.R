library(dplyr)
require(curl)

get_place_name<-function(lng,lat,api_key){
  base_url<-"https://maps.googleapis.com/maps/api/geocode/json?"
  latlng<-paste0("latlng=",lat,",",lng)
  sensor<-paste0("sensor=false")
  key<-paste0("key=",api_key)
  result_type<-paste0("result_type=administrative_area_level_2")
  
  urls<-paste(paste0(base_url,latlng),sensor,key,result_type,sep="&")
  res<-NULL
  for(url in urls){
    result<-jsonlite::fromJSON(curl(url))
    res<-c(res,if_else(is.null(result$results$formatted_address),"Loc Not found",result$results$formatted_address))
  }
  
  return(res)
  
}

