library(ggplot2)

# ---------------------------------------------------
# AUXILLARY FUNCTIONS: FOR COMPUTING EXPONENTIAL DISTRIBUTION 
# ---------------------------------------------------
getExpDist <- function(n, lambda) rexp(n,lambda)
getExpDistMean <- function(lambda) 1/lambda
getExpDistStdDev <- function(lambda) 1/lambda
getSimulationExpDistMeansDataFrame <- function(n, lambda, nosim) {
  output = NULL
  for (i in 1 : nosim) output = c(output, mean(getExpDist(n=n,lambda=lambda)))
  data.frame(x_axis = output)
}
scaleStepBreaks <- function(mean_mu,distance) ((mean_mu-distance):(mean_mu+distance))

# ---------------------------------------------------
# SHINY SERVER IO
# ---------------------------------------------------
shinyServer(
    function(input, output) {
      
      # ---------------------------------------------------
      # REACTIVE CALCULATIONS
      # ---------------------------------------------------
      expDistDF <- reactive({ getExpDist(input$paramN, input$paramLambda) })
      expDistMean <- reactive({ getExpDistMean(input$paramLambda) })
      expDistSD <- reactive ({ getExpDistStdDev(lambda = input$paramLambda) })
      expDistVariance <- reactive({ expDistSD() / sqrt(input$paramN) })
      
      simulationExpDistMeansDF <-  reactive({ getSimulationExpDistMeansDataFrame(input$paramN,input$paramLambda,input$paramNoSim) }) 
      simulationExpDistMean <-  reactive({ mean(simulationExpDistMeansDF()$x_axis) })
      simulationExpDistVariance <-  reactive({ var(simulationExpDistMeansDF()$x_axis) })
    
      qnormY <- reactive({ (simulationExpDistMeansDF()$x_axis - expDistMean()) / (expDistSD()/sqrt(input$paramN)) }) 
      
      # ---------------------------------------------------
      # RENDER OUTPUTS:
      # ---------------------------------------------------
      output$copyParameters <- renderPrint( paste0("The settings for the simuation below are as follows; Lambda=",input$paramLambda, ", # Exps=",input$paramN, ", # Sims=",input$paramNoSim))
      output$copyExpDistMean <- renderPrint({ paste0("The Exponential Distribution Mean is ", round(expDistMean(),4)) })
      output$copyExpDistSD <- renderPrint({ paste0("The Standard Deviation for this Exponential Distribution is ", round(expDistSD(),4)) })

      listMeans <- reactive({ round( c(simulationExpDistMean(),expDistMean()), 4) })
      rowMeans <- c("Mean from the simulation samples","Theoretical mean")
      meansDF <- reactive({ data.frame("MEAN"=listMeans(), row.names=rowMeans) })
      output$tableMeans <- renderTable( meansDF() )
      
      listVariances <- reactive({ round( c(simulationExpDistVariance(),expDistVariance()), 4) })
      rowVariances <- c("Variance from the simulation samples ","Theoretical variance")
      variancesDF <- reactive({ data.frame("VARIANCE"=listVariances(), row.names=rowVariances) })
      output$tableVariances <- renderTable( variancesDF() )
      
      # PLOT HISTOGRAM 
      output$graphExpHistogram <- renderPlot({
        qplot( expDistDF(), geom = "histogram", binwidth = 0.5,
          fill = I("lightgreen"), colour = I("black"), ylab = "Count (Frequency)",
          main = paste0(input$paramN," Random Exponentials"), xlab = "Exponentials") + 
          geom_vline(xintercept =  mean(expDistDF()))
      })
      
      # PLOT EXPONENTIAL DISTRIBUTION WITH DENSITY
      output$graphExpDistDensity <- renderPlot({
        ggplot(
          data = simulationExpDistMeansDF()) +    # SET DATA
          aes(x = x_axis) +                     # SET X AXIS
          geom_histogram(                       # PLOT HISTOGRAM
            binwidth=0.05, alpha=input$paramLambda, aes(y=..density..), colour="black", fill="light blue") +
          labs(                                 # ADD LABELS
            title="Sampling Distribution Density (RED) vs the Standard Normal Density (BLUE)",
            x="Means", y="Density (Scaled by Lambda") +
          scale_x_continuous(                   # SET X-AXIS SCALE
            breaks=scaleStepBreaks(expDistMean(),4)) +
          geom_density(                         # SAMPLE MEANS DENSITY CURVE (RED)
            colour="red", size= 1) +
          stat_function(                        # SET DISTRIBUTED NORMAL DENSITY CURVE (BLUE)
            fun = dnorm, size = 1, colour = "blue",
            args = list(mean = expDistMean(), sd = expDistVariance()) ) +
          geom_vline(                           #THEORETICAL MEAN LINE (BLUE)
            xintercept = expDistMean(), size=1, colour="blue", show.legend = TRUE) +
          scale_colour_manual("",
                              breaks = c("red", "blue"),values = c( "red"="red", "red"="blue"))+
          geom_vline(                           #  SAMPLE MEAN LINE (RED)
            xintercept = simulationExpDistMean(), size=1, colour="red", show.legend = TRUE)          
      })
      
      # QUANTILE QNORM PLOT 
      output$graphExpDistQuantile <- renderPlot({
        par(mar=c(4,4,0,0)+0.1,mgp=c(2,1,0))
        qqnorm(simulationExpDistMeansDF()$x_axis, main = NULL)
        qqline(simulationExpDistMeansDF()$x_axis)
      })
  }
)