## Loading Data and Exploratory analysis 

library(ngram)
library(stringr)
library(qdapRegex)
library(tm)
library(reshape)
library(stylo)
library(dplyr)

file_blogs = "./dataset/en_US/en_US.blogs.txt"
file_twitter = "./dataset/en_US/en_US.twitter.txt"
file_news = "./dataset/en_US/en_US.news.txt"

list_paths = list(blogs = file_blogs, twitter = file_twitter, news = file_news)

# function to size of files
fn_size <- function(file_name){
  f_size<-file.info(file_name)
  size_kb = f_size$size/1024
  size_mb = size_kb/1024
  return(size_mb)
}

# function to word count
fn_words <- function(text){
  wordcount(text, sep = " ", count.function = sum)
}

# function to read lines
fn_rlines <- function(file_name){
  con <- file(file_name)
  f_lines <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
  close(con)
  return(f_lines)
}

# function to write lines
fn_wlines <- function(list_lines,file_name){
  fileConn<-file(file_name)
  writeLines(list_lines, fileConn)
  close(fileConn)
}

# function to sample data
fn_sample <- function (x,perc){
  #rbinom(x, 1, prob = percent)
  sample(x, length(x) * perc)
} 

# files paths 
blogs <- fn_rlines(file_blogs)
twitter <- fn_rlines(file_twitter)
news <- fn_rlines(file_news)


# put corpura into a list
list_corpora <- list(blogs = blogs, twitter = twitter, news = news)


# data frame to store counts
df_corpora <- data.frame(source = c("blogs", "twitter", "news"), size_MB = NA, line_count = NA, word_count = NA)

# get line count and word count for each Corpura
df_corpora$size_MB <- sapply(list_paths, fn_size)
df_corpora$line_count <- sapply(list_corpora, length)
df_corpora$word_count <- sapply(list_corpora, fn_words)

rm(list_corpora)


# create a list of random variables
set.seed(123)
percent <- 0.05

blogs_sample <- fn_sample(blogs,percent)
twitter_sample <- fn_sample(twitter,percent)
news_sample <- fn_sample(news,percent)

rm(blogs)
rm(twitter)
rm(news)

#####################

.f = function() {
  
  ## unwanted code here:
  ## saving samples asnd load from files.


  s_file_blogs <- './samples/sample_blogs.txt'
  s_file_twitter <- './samples/sample_twitter.txt'
  s_file_news <- './samples/sample_news.txt'
  
  list_s_paths = list(blogs = s_file_blogs, twitter = s_file_twitter, news = s_file_news)
  
  ########################
  
  #save samples to files
  
  fn_wlines(blogs_sample,s_file_blogs)
  fn_wlines(twitter_sample,s_file_twitter)
  fn_wlines(news_sample,s_file_news)
  
  #load sample data from files
  blogs_sample <- fn_rlines(s_file_blogs)
  twitter_sample <- fn_rlines(s_file_twitter)
  news_sample <- fn_rlines(s_file_news)

}


#####################

# create a list to store samples
list_sample <- list(blogs = blogs_sample, twitter = twitter_sample , news = news_sample)

# create a data frame for samples
df_sample <- data.frame(source = c("blogs", "twitter", "news"), line_count = NA, word_count = NA)

# get counts of samples
df_sample$line_count <- sapply(list_sample, length)
df_sample$word_count <- sapply(list_sample, fn_words)

rm(list_sample)


# Preprocess Data

### helper functions
stringi_toLower <- function(x) stringi::stri_trans_tolower(x)
remove_URL <- function(x) gsub("http:[[:alnum:]]*", "", x)
remove_HashTags <- function(x) gsub("#\\S+", "", x)
remove_TwitterHandles <- function(x) gsub("@\\S+", "", x)
remove_nonAscii <- function(x) gsub("[^\x01-\x7F]", "", x)
fix_whitespaces <- function(x) qdapRegex::rm_white(x)
## List of Bad Words and Top Swear Words Banned by Google 
profanity_words <- fn_rlines("list.txt")

# function to Preprocess
fn_preprocess <- function(list_text){
  corpus_text <- tm::Corpus(VectorSource(list_text))
  corpus_text <- tm::tm_map(corpus_text, content_transformer(remove_URL))
  corpus_text <- tm::tm_map(corpus_text, content_transformer(remove_HashTags))
  corpus_text <- tm::tm_map(corpus_text, content_transformer(remove_TwitterHandles))
  corpus_text <- tm::tm_map(corpus_text, content_transformer(remove_nonAscii))
  corpus_text <- tm::tm_map(corpus_text, content_transformer(stringi_toLower))
  #corpus_text <- tm::tm_map(corpus_text, removeWords, stopwords("en"))
  corpus_text <- tm::tm_map(corpus_text, removeWords, profanity_words)
  corpus_text <- tm::tm_map(corpus_text, removePunctuation)
  corpus_text <- tm::tm_map(corpus_text, removeNumbers)
  corpus_text <- tm::tm_map(corpus_text, content_transformer(fix_whitespaces))
  return (corpus_text)
  
}

Encoding(blogs_sample) <- "UTF-8"
Encoding(twitter_sample) <- "UTF-8"
Encoding(news_sample) <- "UTF-8"

corpus_blogs <- fn_preprocess(blogs_sample)
corpus_twitter <- fn_preprocess(twitter_sample)
corpus_news <- fn_preprocess(news_sample)

rm(blogs_sample)
rm(twitter_sample)
rm(news_sample)

# ngram tokenizing

str_blogs <- concatenate ( lapply ( corpus_blogs , "[", 1) )
str_twitter <- concatenate ( lapply ( corpus_twitter , "[", 1) )
str_news <- concatenate ( lapply ( corpus_news , "[", 1) )

rm(corpus_blogs)
rm(corpus_twitter)
rm(corpus_news)

full_string <- concatenate (str_blogs,str_twitter,str_news)

rm(str_blogs)
rm(str_twitter)
rm(str_news)

## 1-grams
ng1 <- ngram (full_string , n =1)
df_1gram <- get.phrasetable ( ng1 )
#df_1gram <- df_1gram[order(df_1gram$freq,decreasing = TRUE),] # already ordered 
df_1gram = df_1gram[, 1:2] # drop probability keep only ngram and freq

## 2-grams
ng2 <- ngram (full_string , n =2)
df_2gram <- get.phrasetable ( ng2 )
df_2gram = df_2gram[, 1:2] # drop probability keep only ngram and freq
df_2gram = transform(df_2gram, ngrams = colsplit(ngrams, split = "\\ ", names = c('first', 'second')))

## 3-grams
ng3 <- ngram (full_string , n =3)
df_3gram <- get.phrasetable ( ng3 )
df_3gram = df_3gram[, 1:2] # drop probability keep only ngram and freq
df_3gram = transform(df_3gram, ngrams = colsplit(ngrams, split = "\\ ", names = c('first', 'second','third')))

## 4-grams
ng4 <- ngram (full_string , n =4)
df_4gram <- get.phrasetable ( ng4 )
df_4gram = df_4gram[, 1:2] # drop probability keep only ngram and freq
df_4gram = transform(df_4gram, ngrams = colsplit(ngrams, split = "\\ ", names = c('first', 'second','third','forth')))

## 5-grams
ng5 <- ngram (full_string , n =5)
df_5gram <- get.phrasetable ( ng5 )
df_5gram = df_5gram[, 1:2] # drop probability keep only ngram and freq
df_5gram = transform(df_5gram, ngrams = colsplit(ngrams, split = "\\ ", names = c('first', 'second','third','forth','fifth')))

# Write ngram data as rds files
saveRDS(df_1gram, file = "./data/1gram_s.rds")
saveRDS(df_2gram, file = "./data/2gram_s.rds")
saveRDS(df_3gram, file = "./data/3gram_s.rds")
saveRDS(df_4gram, file = "./data/4gram_s.rds")
saveRDS(df_5gram, file = "./data/5gram_s.rds")
