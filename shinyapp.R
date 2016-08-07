usePackage<-function(p){
  # load a package if installed, else load after installation.
  # Args: p: package name in quotes
  if (!is.element(p, installed.packages()[,1])){
    print(paste('Package:',p,'Not found, Installing Now...'))
    suppressMessages(install.packages(p, dep = TRUE))
  }
  print(paste('Loading Package :',p))
  require(p, character.only = TRUE)  
}
usePackage("shiny")
setwd("/Users/smallwes/develop/academic/coursera/datascience/c9-dp/project1")
runApp("shinyapp")

#usePackage('rsconnect')
#rsconnect::setAccountInfo(name='smallwesley',
#                          token='C4E2DC18520DA9F3EE621E0F6DBCDCC0',
#                          secret='vZj2yNIyUEVZDy7nOCcigCJ6unkRbVq52jT1DeYk')
#rsconnect::deployApp('/Users/smallwes/develop/academic/coursera/datascience/c9-dp/project1/shinyapp')

#usePackage("devtools")
#devtools::install_github('rstudio/shinyapps')
#library(shinyapps)
#rsconnect::setAccountInfo(name='smallwesley', token='C4E2DC18520DA9F3EE621E0F6DBCDCC0', secret='vZj2yNIyUEVZDy7nOCcigCJ6unkRbVq52jT1DeYk')

library(shinyapps)
deployApp()