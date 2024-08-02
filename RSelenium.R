
setwd("C:/Users/Propietario/Desktop/What_means_invasive")
df <- readxl::read_xlsx("no_invasive_cites.xlsx")
df1<- df %>% filter(is.na(`Number of citations`))


system("docker ps")
  
system("docker stop 968c3bf4dd50")
system("docker rm 968c3bf4dd50")
system("docker run -d -p 4445:4444 -p 5900:5900 selenium/standalone-chrome-debug")
system("docker ps")


system('docker run -d --privileged -p 4445:4444 -p 5900:5900 selenium/standalone-chrome-debug')


system('docker run -d -p 4445:4444 selenium/standalone-chrome-debug')
remDr <- remoteDriver(remoteServerAddr = "localhost",
                      port = 4445L,
                      browserName = "chrome")
res <- data.frame()
for(n in unique(df1$`Article Title`)) {
  tryCatch({
  remDr$open()
  remDr$navigate("https://scholar.google.com/")
  Sys.sleep(5)
  search_box <- remDr$findElement(using = "name", value = "q")
  paper_name <- n
  search_box$sendKeysToElement(list(paper_name))
  remDr$executeScript("arguments[0].form.submit();", list(search_box))
  Sys.sleep(5)
  page_source <- remDr$getPageSource()[[1]]
  citation_element <- remDr$findElement(using = "xpath", value = "//a[contains(text(),'Počet citací tohoto článku')]")
  citation_text <- citation_element$getElementText()[[1]]
  citation_count <- str_extract(citation_text, "\\d+")
  print(paste("Citation count:", citation_count))
  Sys.sleep(5)
  res <- rbind(res, data.frame(Article = n, Citations = citation_count))
  }, error = function(e) {
    print(paste("Error processing article:", n, "Error:", e$message))
  }, finally = {
    remDr$close()
  })
}


remDr$open()
remDr$navigate("https://scholar.google.com/")

Sys.sleep(5)
# For GISD:
#search_box <- remDr$findElement(using = "css selector", value = "#search-text")  
#sp <- "Dreissena polymorpha"
#search_box$sendKeysToElement(list(sp))
#remDr$executeScript("arguments[0].click();", list(remDr$findElement(using = "id", value = "go")))

#species_link <- remDr$findElement(using = "css selector", value = "a[href*='speciesname/']")
#species_link$clickElement()


# For Google Scholar:
search_box <- remDr$findElement(using = "name", value = "q")
paper_name <- "Taming the terminological tempest in invasion science"
search_box$sendKeysToElement(list(paper_name))
remDr$executeScript("arguments[0].form.submit();", list(search_box))

Sys.sleep(5)

page_source <- remDr$getPageSource()[[1]]

citation_element <- remDr$findElement(using = "xpath", value = "//a[contains(text(),'Počet citací tohoto článku')]")
citation_text <- citation_element$getElementText()[[1]]
citation_count <- str_extract(citation_text, "\\d+")
print(paste("Citation count:", citation_count))

Sys.sleep(5)


remDr$close()

