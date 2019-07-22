# Twitter Bag-of-Word Analysis with ShinyApp

To use the app, click [here](https://kevinch0810zxc.shinyapps.io/TwitteR/)

## What is this App
This Shiny App allows you to search for tweets that contain a certain keyword of your choice. Then it will display the sentiment scores (see reference for details) of those tweets, and a wordcloud that shows you the words most frequently used along with your keyword.

There are two versions of this app: **Basic Search** and **Advanced Search**. The primary difference is that Basic Search will grab only the newest tweets (within the date range that you can specify), while Advanced Search will take X number of tweets from each day and make a boxplot instead of a scatter plot.

### Basic Search
![alt text](https://github.com/kevinch0810zxc/Twitter-Keyword/blob/master/basic1.png)
![alt text](https://github.com/kevinch0810zxc/Twitter-Keyword/blob/master/basic2.png)

### Advanced Search
![alt text](https://github.com/kevinch0810zxc/Twitter-Keyword/blob/master/advanced1.png)
![alt text](https://github.com/kevinch0810zxc/Twitter-Keyword/blob/master/advanced2.png)

## Limitations
  1. Due to the restrictions of Standard Search API, only the **most recent and popular** tweets can be pulled.
  2. Currently, there is **no way** to search tweets within a specific timeframe.
  3. There is a maximum amount of tweets each search can pull. However, this should not affect the functionality of this app.
 
 ## Reference
The sentiment score is calculated based on the combined and augmented version of Jockers (2017) & Rinker's augmented Hu & Liu (2004) positive/negative word list.
 
1. *Jockers, M. L. (2017). Syuzhet: Extract sentiment and plot arcs from Text. Retrived from [here](https://github.com/mjockers/syuzhet)*
2. *Hu, M., & Liu, B. (2004). Mining and summarizing customer reviews. Proceedings of the ACM SIGKDD International Conference on Knowledge Discovery & Data Mining (KDD-2004). Seattle, Washington.*
