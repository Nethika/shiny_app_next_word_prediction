# Next word Prediction

#read n-gram data
df_2gram<- readRDS("./data/2gram_s.rds")
df_3gram<- readRDS("./data/3gram_s.rds")
df_4gram<- readRDS("./data/4gram_s.rds")
df_5gram<- readRDS("./data/5gram_s.rds")

guess_1 =""
guess_2 =""
guess_3 =""

dataCleaner<-function(text){
  
  cleanText <- tolower(text)
  cleanText <- removePunctuation(cleanText)
  cleanText <- removeNumbers(cleanText)
  cleanText <- str_replace_all(cleanText, "[^[:alnum:]]", " ")
  cleanText <- stripWhitespace(cleanText)
  
  return(cleanText)
}

cleanInput <- function(text){
  
  textInput <- dataCleaner(text)
  textInput <- txt.to.words(textInput)
  
  return(textInput)
}



predict_next <- function(text){
  
  text_input <- cleanInput(text)
  word_count <- length(text_input)
  
  if (word_count>=5) {
    text_input = tail(text_input, 4) 
    word_count = 4
  }
  if (word_count==4) {
    df_possible <- df_5gram[df_5gram$ngrams$first==text_input[1] & 
                              df_5gram$ngrams$second==text_input[2] & 
                              df_5gram$ngrams$third==text_input[3] &
                              df_5gram$ngrams$forth==text_input[4],]
    guess_1 <- as.character(df_possible$ngrams$fifth[1])
    guess_2 <- as.character(df_possible$ngrams$fifth[2])
    guess_3 <- as.character(df_possible$ngrams$fifth[3])
    if (is.na(guess_1)) {
      text_input = tail(text_input, 3)
      word_count = 3
    }
    
  } 
  
  if (word_count==3) {
    df_possible <- df_4gram[df_4gram$ngrams$first==text_input[1] & 
                              df_4gram$ngrams$second==text_input[2] & 
                              df_4gram$ngrams$third==text_input[3],]
    guess_1 <- as.character(df_possible$ngrams$forth[1])
    guess_2 <- as.character(df_possible$ngrams$forth[2])
    guess_3 <- as.character(df_possible$ngrams$forth[3])
    if (is.na(guess_1)) {
      text_input = tail(text_input, 2)
      word_count = 2
    }
  } 
  if (word_count==2) {
    df_possible <- df_3gram[df_3gram$ngrams$first==text_input[1] & 
                              df_3gram$ngrams$second==text_input[2],]
    guess_1 <- as.character(df_possible$ngrams$third[1])
    guess_2 <- as.character(df_possible$ngrams$third[2])
    guess_3 <- as.character(df_possible$ngrams$third[3])
    if (is.na(guess_1)){
      text_input = tail(text_input, 1)
      word_count = 1
    }
  } 
  if (word_count==1) {
    df_possible <- df_2gram[df_2gram$ngrams$first==text_input[1],]
    guess_1 <- as.character(df_possible$ngrams$second[1])
    guess_2 <- as.character(df_possible$ngrams$second[2])
    guess_3 <- as.character(df_possible$ngrams$second[3])
    if (is.na(guess_1)){
      guess_1 = "the"
    }
  }

  return(c(guess_1,guess_2,guess_3))

}





