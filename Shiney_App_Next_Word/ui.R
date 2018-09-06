#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(shinythemes)
library(DT)
library(ggplot2)
library(plotly)
library(markdown)


# Define UI for application that draws a histogram
shinyUI(fluidPage(
  #theme
  theme = shinytheme("sandstone"),
  # Application title
  titlePanel("Next Word Prediction"),
  
  #tabs
  navbarPage("An app to predict the next word while you enter text",
             
             
           tabPanel("Next Word Prediction",
                    
                    
                    fluidRow(
                      
                      column(3),
                      column(6,
                             tags$div(textInput("text", 
                                                label = h3("Enter Text:"),
                                                value = ),
                                      br(),
                                      tags$hr(),
                                      h3("Predicted Next Word:"),
                                      tags$span(style="color:darkred",
                                                tags$strong(tags$h3(textOutput("guess_1")))),
                                      br(),
                                      tags$hr(),
                                      h4("Second Guess:"),
                                      tags$span(style="color:grey",
                                                tags$strong(tags$h3(textOutput("guess_2")))),
                                      br(),
                                      tags$hr(),
                                      h4("Third Guess:"),
                                      tags$span(style="color:grey",
                                                tags$strong(tags$h4(textOutput("guess_3")))),
                                      br(),
                                      tags$hr(),                                    
                                      align="center")
                      ),
                      column(3)
                    )
           ),         
  

    tabPanel("N-Gram Plots",

              fluidRow(
                column(width = 5,
                       uiOutput("ngramSelectP")
                ),
                column(width = 5, offset = 1,
                       sliderInput("n_terms",
                                   "Select number of n-grams to view:",
                                   min = 5,
                                   max = 50,
                                   value = 25)
                )
              ),
              hr(),
              plotlyOutput("ngramPlot",height=800, width = 900)

              
              
            ),

    tabPanel("View Data",
             h2("N-Gram Data Set"),
             hr(),
             fluidRow(
               column(width = 5,
                      uiOutput("ngramSelectT")
               )
             ),
             DT::dataTableOutput("ngramtable")
    ),
    tabPanel("Documentation", includeMarkdown("documentation.md")

             

             )
    )
  ))

