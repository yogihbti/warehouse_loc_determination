library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)

# Leaflet bindings are a bit slow; for now we'll just sample to compensate


function(input, output, session) {
  
  #Define Reactive values 
  data_read<-reactiveVal(NULL)
  cluster_df<-reactiveVal(NULL)
  ## Interactive Map ###########################################
      
  # Create the map
  # Tiles selected for Indian region
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "https://{s}.tiles.mapbox.com/v4/openstreetmap.1b68f018/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoiamluYWxmb2ZsaWEiLCJhIjoiY2psejFtZG8wMWhnMjNwcGFqdTNjaGF2MCJ9.ZQVAZAw8Xtg4H2YSuG4PlA",
        attribution = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors by Mapbox'
      ) %>%
      setView(lng = 79.85, lat = 21.14, zoom = 4)
  })
  
  # Download file handler
  output$downloadData <- downloadHandler(
    filename = "geo_data_input.csv",
    content = function(file) {
      write.csv(data.frame(Longitude="",Latitude="",SalesVal=0),
                file, row.names = FALSE)
    }
  )
  
  #load data from file to a reactive variable
  
  data_read <- reactive({ 
    req(input$file1) ## ?req #  require that the input is available
    
    inFile <- input$file1 
    df <- read.csv(inFile$datapath, header = input$header)
    return(df)
  })

  #observe for input file and reactive value to be available to update the map
  
  observeEvent(input$file1,{
        leafletProxy("map", data = data_read()) %>%
        clearShapes() %>%
        addCircles(lng=~Longitude, lat=~Latitude, radius=~log(SalesVal)*5000,fillOpacity=.4,weight = 1 ,color="orange")
    }
    
  )
  
  #observe the clustering button clicked- do the clustering to set color groups
  observeEvent(input$run_cluster,{
    set.seed(input$seed)
    #browser()
    if(!is.null(input$file1)){
      df<-data_read()
      df_matrix<-df[,c("Latitude","Longitude")]
      cluster_geo=kmeans(df_matrix,input$no_of_wh)
      df$cluster<-as.factor(cluster_geo$cluster)
      pal<-colorFactor("viridis",df$cluster)
      #browser()
      leafletProxy("map", data = df) %>%
        clearShapes() %>%
        clearMarkers() %>%
        addCircles(lng=~Longitude, lat=~Latitude,
                   radius=~log(SalesVal)*5000,
                   fillOpacity=.4,
                   weight = 1,
                   color=~pal(cluster),group=~cluster)
      cluster_df(df)
    }else{
      showNotification("First upload a file.")
    }
    
  })
  
  observeEvent(input$find_cog,{
    if(!is.null(input$run_cluster)){
      api_key<-readLines("api_key")
      df<-cluster_df()
      cog_center<- df %>% 
        group_by(cluster) %>% 
        summarise(lon_center=weighted.mean(Longitude,SalesVal),
                  lat_center=weighted.mean(Latitude,SalesVal)) 
      place_name<-get_place_name(cog_center$lon_center,cog_center$lat_center,api_key)
      cog_center$place_name<-place_name
      
      pal<-colorFactor("viridis",df$cluster)
      #browser()
      leafletProxy("map", data = df) %>%
        clearShapes() %>%
        clearMarkers() %>% 
        addCircles(lng=~Longitude, lat=~Latitude,
                   radius=~log(SalesVal)*5000,
                   fillOpacity=.4,
                   weight = 1,color=~pal(cluster)) %>% 
        addMarkers(lng=~lon_center,lat=~lat_center,popup=~place_name,data =cog_center)
    }else{
      showNotification("First upload a file.")
    }
    
  })
  
}