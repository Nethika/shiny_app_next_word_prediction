#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
library(tm)
library(ngram)
library(stringr)
library(reshape)
library(stylo)
library(dplyr)
library(ggplot2)
library(plotly)



keeps <- c("ngram", "freq")
source('predictNext.R', local = TRUE)


shinyServer(function(input, output) {
  
  #############
  
  wordPrediction <- reactive({
    text <- input$text
    wordPrediction <- predict_next(text)
  })

  output$guess_1 <- renderText(wordPrediction()[1])
  output$guess_2 <- renderText(wordPrediction()[2])
  output$guess_3<- renderText(wordPrediction()[3])
                                      


  ############
  # ngram Plot Data:
  output$ngramSelectP <- renderUI({
    selectInput("ngram_n_p", "Select a ngram to view data:", choices = c('2-grams','3-grams','4-grams','5-grams'),selected = "5-grams" )
  })
  
  dataset_1 <- reactive({
    
    if (is.null(input$ngram_n_p)){
      return(data.frame(ngram=NA,freq=NA))
    } else {

        if (input$ngram_n_p == '2-grams'){
          d_f <- head(df_2gram,50)
          d_f$ngram <- paste0(d_f$ngrams$first," ",d_f$ngrams$second)
          d_f <- d_f[keeps]
        }
        if (input$ngram_n_p == '3-grams'){
          d_f <- head(df_3gram,50)
          d_f$ngram <- paste0(d_f$ngrams$first," ",d_f$ngrams$second," ",d_f$ngrams$third)
          d_f <- d_f[keeps]
        }
        if (input$ngram_n_p == '4-grams'){
          d_f <- head(df_4gram,50)
          d_f$ngram <- paste0(d_f$ngrams$first," ",d_f$ngrams$second," ",d_f$ngrams$third," ",d_f$ngrams$forth)
          d_f <- d_f[keeps]
        }
        if (input$ngram_n_p == '5-grams'){
          d_f <- head(df_5gram,50)
          d_f$ngram <- paste0(d_f$ngrams$first," ",d_f$ngrams$second," ",d_f$ngrams$third," ",d_f$ngrams$forth," ",d_f$ngrams$fifth)
          d_f <- d_f[keeps]
        }
      return(d_f)
    }
    
  })
  
  # ngram Table Data:
  output$ngramSelectT <- renderUI({
    selectInput("ngram_n_t", "Select a ngram to view data:", choices = c('2-grams','3-grams','4-grams','5-grams'),selected = "5-grams" )
  })
  
  dataset_2 <- reactive({

      
      if (is.null(input$ngram_n_t)){
        return()
      } else {
      
          if (input$ngram_n_t == '2-grams'){
            d_f <- head(df_2gram,50)
            d_f$ngram <- paste0(d_f$ngrams$first," ",d_f$ngrams$second)
            d_f <- d_f[keeps]
          }
          if (input$ngram_n_t == '3-grams'){
            d_f <- head(df_3gram,50)
            d_f$ngram <- paste0(d_f$ngrams$first," ",d_f$ngrams$second," ",d_f$ngrams$third)
            d_f <- d_f[keeps]
          }
          if (input$ngram_n_t == '4-grams'){
            d_f <- head(df_4gram,50)
            d_f$ngram <- paste0(d_f$ngrams$first," ",d_f$ngrams$second," ",d_f$ngrams$third," ",d_f$ngrams$forth)
            d_f <- d_f[keeps]
          }
          if (input$ngram_n_t == '5-grams'){
            d_f <- head(df_5gram,50)
            d_f$ngram <- paste0(d_f$ngrams$first," ",d_f$ngrams$second," ",d_f$ngrams$third," ",d_f$ngrams$forth," ",d_f$ngrams$fifth)
            d_f <- d_f[keeps]
          
          }
        return(d_f)
      }
    
  })
  
  output$ngramtable = DT::renderDataTable({

    dataset_2()
    
  })
  
  
  
  output$ngramPlot <- renderPlotly({
    theme_set(theme_bw())
    
    p_gram<- ggplot(dataset_1()[1:input$n_terms,], aes(x=reorder(ngram, -freq), y=freq)) + 
      geom_bar(stat="identity", width=.5, fill="tomato3") + 
      labs(title="N-Grams", 
           y="frequency",
           x ="") +
      theme(axis.text.x = element_text(angle=90, vjust = 1, hjust = 1))
    ggplotly(p_gram)
  })
  
    
  })
  

