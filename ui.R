library(shiny)
library(wordcloud2)

# Define UI for application that draws a histogram
shinyUI(navbarPage(
  title = "TwitteR",
  
  tabPanel("Basic Search",
           ## START OF FIRST TAB
           tabsetPanel(
             ## SENTIMENT TABLE AND GRAPH 1
             tabPanel(
               "Sentiment Score",
               fluid = TRUE,
               sidebarLayout(
                 sidebarPanel(
                   fluidRow(column(
                     12,
                     h4(
                       "Type any keyword you want to search on Twitter.
                       This app will return the most recent tweets that contain your keyword and calculate
                       their sentiment scores."
                     ),
                     h5(
                       "Note: The calculation of sentiment score is based on Jockers (2017) & Rinker's
                       augmented Hu & Liu (2004) positive/negative word list"
                     ),
                     br()
                     )),
                   
                   textInput(inputId = "keyword",
                             label = "Your Keyword:"),
                   
                   sliderInput(
                     "amount",
                     "How many Tweets do you want?",
                     min = 10,
                     max = 500,
                     value = 250,
                     step = 10
                   ),
                   
                   radioButtons(
                     "hashtag",
                     "Is your keyword a #hashtag?",
                     c("No" = "no",
                       "Yes" = "yes")
                   ),
                   
                   dateRangeInput(
                     "daterange",
                     "Date Range:",
                     start  = Sys.Date() - 7,
                     end    = Sys.Date(),
                     min    = Sys.Date() - 7,
                     max    = Sys.Date(),
                     format = "mm/dd/yy",
                     separator = " - "
                   ),
                   
                   actionButton("search", "Start Searching!"),
                   
                   
                   textOutput("howmany"),
                   
                   conditionalPanel(
                     condition = "input.search == true",
                     checkboxInput("ma", strong("Add Moving Average"), FALSE)
                   ),
                   
                   conditionalPanel(
                     condition = "input.ma == true",
                     sliderInput(
                       "period",
                       "Adjust Averagin Period",
                       min = 1,
                       max = 10,
                       value = 4,
                       step = 1
                     )
                   )
                   
                   ),
                 mainPanel(tableOutput("distribution"),
                           plotOutput("score")
                 )
                   )
           ),
           ## WORD CLOUD 1
           tabPanel(
             "Word Correlation",
             fluid = TRUE,
             sidebarLayout(
               sidebarPanel(
                 sliderInput(
                   "freq",
                   "Minimum Frequency:",
                   min = 1,
                   max = 50,
                   value = 1
                 ),
                 
                 sliderInput(
                   "max",
                   "Number of Words on Screen:",
                   min = 2,
                   max = 300,
                   value = 10
                 )
               ),
               mainPanel(
                 wordcloud2Output("wordcloud"))
             )
           )
  )),
  ## END OF FIRST TAB
  
  tabPanel("Advanced Search",
           tabsetPanel(
             ## SENTIMENT TABLE AND GRAPH 2
             tabPanel(
               "Sentiment Score",
               fluid = TRUE,
               sidebarLayout(
                 sidebarPanel(
                   fluidRow(column(
                     12,
                     h4(
                       "Advanced Search is an extention to the basic search app. The difference is that this will search
                       X number of tweets for each date within the date range."
                     )
                     ),
                     br()),
                   
                   textInput(inputId = "keyword2",
                             label = "Your Keyword:"),
                   
                   sliderInput(
                     "amount2",
                     "How many Tweets do you want for each day?",
                     min = 10,
                     max = 100,
                     value = 50,
                     step = 1
                   ),
                   
                   radioButtons(
                     "hashtag2",
                     "Is your keyword a #hashtag?",
                     c("No" = "no",
                       "Yes" = "yes")
                   ),
                   
                   dateRangeInput(
                     "daterange2",
                     "Date Range:",
                     start  = Sys.Date() - 7,
                     end    = Sys.Date(),
                     min    = Sys.Date() - 7,
                     max    = Sys.Date(),
                     format = "mm/dd/yy",
                     separator = " - "
                   ),
                   
                   actionButton("search2", "Start Searching!"),
                   
                   textOutput("howmany2")
                   
                   
                   ),
                 mainPanel(tableOutput("distribution2"),
                           plotOutput("score2"))
                 )
             ),
             ## WORD CLOUD 2
             tabPanel(
               "Word Correlation",
               fluid = TRUE,
               sidebarLayout(
                 sidebarPanel(
                   sliderInput(
                     "freq2",
                     "Minimum Frequency:",
                     min = 1,
                     max = 50,
                     value = 1
                   ),
                   
                   sliderInput(
                     "max2",
                     "Number of Words on Screen:",
                     min = 3,
                     max = 300,
                     value = 100
                   )
                 ),
                 mainPanel(wordcloud2Output("wordcloud2"))
               )
             )
  ))
  ))





