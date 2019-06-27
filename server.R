library(shiny)
library(twitteR)
library(sentimentr)
library(ggplot2)
library(tidyquant)
library(dplyr)
library(scales)
library(tm)

consumer_key = "YOUR API KEY"
consumer_secret = "YOUR API SECRET"
access_token = "YOUR ACCESS TOKEN"
access_secret = "YOUR ACCESS SECRET"

setup_twitter_oauth(consumer_key, consumer_secret,
                    access_token, access_secret)


shinyServer(function(input, output) {
  ################################################START OF PANEL 2
  
  hashtag <- reactive({
    if (input$hashtag == "no") {
      "no"
    } else if (input$hashtag == "yes") {
      "yes"
    }
  })
  
  ################################################START OF TAB 1
  
  observeEvent(input$search, handlerExpr = {
    req(input$keyword)
    req(input$daterange[2] - input$daterange[1] != 0)
    
    if (input$hashtag == "no") {
      keytweets = try(searchTwitter(
        searchString = paste(input$keyword, " -filter:retweets", sep = ""),
        since = as.character(input$daterange[1]),
        until = as.character(input$daterange[2]),
        n = input$amount,
        lang = "en",
        retryOnRateLimit = 120
      ))
    }
    else if (input$hashtag == "yes") {
      keytweets = try(searchTwitter(
        searchString = paste("#", input$keyword, " -filter:retweets", sep = ""),
        since = as.character(input$daterange[1]),
        until = as.character(input$daterange[2]),
        n = input$amount,
        lang = "en",
        retryOnRateLimit = 120
      ))
    }
    
    keytweets <- twListToDF(keytweets)
    
    output$howmany <- renderText({
      paste("We have retrived", nrow(keytweets), "Tweets for you!")
    })
    
    text <- keytweets$text
    
    #text cleaning
    temp <- replace_emoji(text)
    temp <- gsub("@\\w+", " ", temp)
    temp <- gsub("(?!')[[:punct:]]", "", temp, perl = TRUE)
    temp <- gsub("[[:cntrl:]]", "", temp)
    temp <- gsub("[[:digit:]]", "", temp)
    temp <- tolower(temp)
    temp <- gsub("http\\w+", "", temp)
    temp <- gsub("[ \t]{2,}", " ", temp)
    temp <- gsub("^\\s+|\\s+$", "", temp)
    temp <- gsub(paste("( |^)", input$keyword, sep = ""), "", temp)
    temp <- gsub("^\\s+|\\s+$", "", temp)
    
    word.list <- strsplit(temp, " ")
    words <- unlist(word.list)
    words <- words[!words %in% stopwords(kind = "english")]
    words <- data.frame(table(words))
    
    temp <- get_sentences(temp)
    
    #Calculating Sentiment Score
    sentimentscore <- sentiment(temp)
    sentimentscore <-
      aggregate(sentimentscore, by = list(sentimentscore$element_id), function(x)
        sum(x))
    sentimentscore <- cbind(sentimentscore, keytweets$created)
    sentimentscore %>% rename(index = 1, created = 6) -> sentimentscore
    
    
    p <- ggplot(sentimentscore, aes(created, sentiment)) +
      labs(x = "Time", y = "Sentiment Score") +
      geom_point() +
      theme(axis.text.x = element_text(angle = 0, hjust = 0.5)) +
      scale_x_datetime(labels = date_format("%Y-%m-%d %H:%M:%S"))
    
    #Plot 1 (ALL)
    output$score <- renderPlot(
      if(input$ma == FALSE){
        print(p)
      }
      else{
        print(p + geom_ma(linetype = "solid", size = 1, n = input$period))
      }
    )
    
    
    output$distribution <- renderTable(
      matrix(data = c(
        sum(sentimentscore$sentiment > 0),
        sum(sentimentscore$sentiment < 0), 
        sum(sentimentscore$sentiment == 0), 
        sum(sentimentscore$sentiment[sentimentscore$sentiment > 0]),
        sum(sentimentscore$sentiment[sentimentscore$sentiment < 0]), 
        sum(sentimentscore$sentiment[sentimentscore$sentiment == 0])),
        nrow = 2, ncol = 3, byrow = TRUE, dimnames = list(
          c("How Many","Total Score"), 
          c("Positive Tweets","Negative Tweets","Neutral or Not Related"))
      ),
      align = "c", rownames = TRUE
    )
    ################################################END OF TAB 1
    
    ################################################START OF TAB 2
    cloudtable <- words[order(-words$Freq),]
    
    output$wordcloud <- renderWordcloud2({
      cloud <- cloudtable %>% 
        filter(Freq >= input$freq)
      
      validate(
        need(input$max <= nrow(cloud), "Selected size greater than number of elements in data")
      )
      
      cloud <- head(cloud, n = input$max)
      
      wordcloud2(cloud, color="random-light", size = .6)
    })
    
    ################################################END OF TAB 2
    
  })
  ################################################END OF PANEL 2
  
  
  
  ################################################START OF PANEL 3
  
  hashtag2 <- reactive({
    if (input$hashtag2 == "no") {
      "no"
    } else if (input$hashtag2 == "yes") {
      "yes"
    }
  })
  
  ################################################START OF TAB 3
  
  observeEvent(input$search2, handlerExpr = {
    req(input$keyword2)
    req(input$daterange2[2] - input$daterange2[1] != 0)
    
    range <- input$daterange2[2] - input$daterange2[1]
    
    if (input$hashtag2 == "no") {
      keytweets <- list()
      try(for (i in 1:range) {
        tweetlist <- searchTwitter(
          searchString = paste(input$keyword2, " -filter:retweets", sep = ""),
          since = as.character(input$daterange2[1] + i - 1),
          until = as.character(input$daterange2[1] + i),
          n = input$amount2,
          lang = "en",
          retryOnRateLimit = 120
        )
        keytweets <- c(keytweets, tweetlist)
      }
      )
    }
    else if (input$hashtag2 == "yes") {
      keytweets <- list()
      try(for (i in 1:range) {
        tweetlist <- searchTwitter(
          searchString = paste("#", input$keyword2, " -filter:retweets", sep = ""),
          since = as.character(input$daterange2[1] + i - 1),
          until = as.character(input$daterange2[1] + i),
          n = input$amount2,
          lang = "en",
          retryOnRateLimit = 120
        )
        keytweets <- c(keytweets, tweetlist)
      }
      )
    }
    
    keytweets <- twListToDF(keytweets)
    
    output$howmany2 <- renderText({
      paste("We have retrived", nrow(keytweets), "Tweets you!")
    })
    
    text <- keytweets$text
    
    #text cleaning
    temp <- replace_emoji(text)
    temp <- gsub("@\\w+", " ", temp)
    temp <- gsub("(?!')[[:punct:]]", "", temp, perl = TRUE)
    temp <- gsub("[[:cntrl:]]", "", temp)
    temp <- gsub("[[:digit:]]", "", temp)
    temp <- tolower(temp)
    temp <- gsub("http\\w+", "", temp)
    temp <- gsub("[ \t]{2,}", " ", temp)
    temp <- gsub("^\\s+|\\s+$", "", temp)
    temp <- gsub(paste("( |^)", input$keyword2, sep = ""), "", temp)
    temp <- gsub("^\\s+|\\s+$", "", temp)
    
    word.list <- strsplit(temp, " ")
    words <- unlist(word.list)
    words <- words[!words %in% stopwords(kind = "english")]
    words <- data.frame(table(words))
    
    temp <- get_sentences(temp)
    
    #Calculating Sentiment Score
    sentimentscore <- sentiment(temp)
    sentimentscore <-
      aggregate(sentimentscore, by = list(sentimentscore$element_id), function(x) sum(x))
    sentimentscore <- cbind(sentimentscore, keytweets$created)
    sentimentscore %>% rename(index = 1, created = 6) -> sentimentscore
    
    #Plot 2 (ALL)
    sentimentscore$created <- as.Date(sentimentscore$created)
    output$score2 <- renderPlot(
      ggplot(sentimentscore, aes(created, sentiment)) +
        labs(x = "Time", y = "Sentiment Score")+
        geom_boxplot(aes(group = created)) +
        theme(axis.text.x = element_text(angle = 0, hjust = 0.5))
    )
    
    output$distribution2 <- renderTable(
      matrix(data = c(
        sum(sentimentscore$sentiment > 0),
        sum(sentimentscore$sentiment < 0), 
        sum(sentimentscore$sentiment == 0), 
        sum(sentimentscore$sentiment[sentimentscore$sentiment > 0]),
        sum(sentimentscore$sentiment[sentimentscore$sentiment < 0]), 
        sum(sentimentscore$sentiment[sentimentscore$sentiment == 0])),
        nrow = 2, ncol = 3, byrow = TRUE, dimnames = list(
          c("How Many","Total Score"), 
          c("Positive Tweets","Negative Tweets","Neutral or Not Related"))
      ),
      align = "c", rownames = TRUE
    )
    ################################################END OF TAB 3
    
    ################################################START OF TAB 4
    cloudtable <- words[order(-words$Freq),]
    
    output$wordcloud2 <- renderWordcloud2({
      cloud <- cloudtable %>% 
        filter(Freq >= input$freq2)
      
      validate(
        need(input$max <= nrow(cloud), "Selected size greater than number of elements in data")
      )
      
      cloud <- head(cloud, n = input$max2)
      wordcloud2(cloud, color="random-light", size = .6)
    })
    
    ################################################END OF TAB 4
    
  })################################################END OF PANEL 3
  
}
)


