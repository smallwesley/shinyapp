library(ggplot2)

# ---------------------------------------------------
# AUXILLARY FUNCTIONS: FOR COMPUTING EXPONENTIAL DISTRIBUTION 
# ---------------------------------------------------

# COMPUTE: 
getExpDist <- function(n, lambda) rexp(n,lambda)
getExpDistMean <- function(lambda) 1/lambda
getExpDistStdDev <- function(lambda) 1/lambda
getSimulationExpDistMeansDataFrame <- function(n, lambda, nosim) {
  output = NULL
  for (i in 1 : nosim) output = c(output, mean(getExpDist(n=n,lambda=lambda)))
  data.frame(x_axis = output)
}

# Function for PLOT Breaks on x-axis
scaleStepBreaks <- function(mean_mu,distance) ((mean_mu-distance):(mean_mu+distance))

# Calculate Standard Deviation Endpoints; Interval based on distance from the mean
getStdDevSampleInterval <- function(g, mu, stddev) c(mu - stddev * g, mu + stddev * g)

# For a list of results, calculate the precentage of results that lie within the standard dev.
calculateSamplePercentageWithinStdDevInterval <- function(g, list, mu, stddev, tLen) {
  sdGroup <- getStdDevSampleInterval(g, mu, stddev)
  validSdGroup <- NULL
  for ( i in 1:length(list) ) 
    if (list[i] >= sdGroup[1] & list[i] <= sdGroup[2]) validSdGroup <- c(validSdGroup, list[[i]])
  round(length(validSdGroup)/tLen, 2)
}

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
      simulationExpDistSD <-  reactive({ sd(simulationExpDistMeansDF()$x_axis) })
      simulationExpDistVariance <-  reactive({ var(simulationExpDistMeansDF()$x_axis) })
    
      qnormY <- reactive({ (simulationExpDistMeansDF()$x_axis - expDistMean()) / (expDistSD()/sqrt(input$paramN)) }) 
      
      # ---------------------------------------------------
      # RENDER OUTPUTS:
      # ---------------------------------------------------
      output$copyParameters <- renderPrint( paste0("The settings for the simuation below are as follows; Lambda=",input$paramLambda, ", # Exps=",input$paramN, ", # Sims=",input$paramNoSim))
      output$copyExpDistMean <- renderPrint({ paste0("The Exponential Distribution Mean is ", round(expDistMean(),4)) })
      output$copyExpDistSD <- renderPrint({ paste0("The Standard Deviation for this Exponential Distribution is ", round(expDistSD(),4)) })

      # MEANS TABLE
      listMeans <- reactive({ round( c(simulationExpDistMean(),expDistMean()), 4) })
      rowMeans <- c("Mean from the simulation samples","Theoretical mean")
      meansDF <- reactive({ data.frame("MEAN"=listMeans(), row.names=rowMeans) })
      output$tableMeans <- renderTable( meansDF() )
      
      # VARIANCES TABLE
      listVariances <- reactive({ round( c(simulationExpDistVariance(),expDistVariance()), 4) })
      rowVariances <- c("Variance from the simulation samples ","Theoretical variance")
      variancesDF <- reactive({ data.frame("VARIANCE"=listVariances(), row.names=rowVariances) })
      output$tableVariances <- renderTable( variancesDF() )
      
      # SAMPLING DISTRIBUTION TABLE 
      samp <- reactive({ simulationExpDistMeansDF()$x_axis })
      lenSamp <- reactive({ length(samp()) })
      output$samp_len <- renderPrint({ paste0("Length = ",lenSamp()) })
      samp_mu <- reactive({ mean(samp()) })
      output$samp_mu <- renderPrint({ paste0("Mean = ",samp_mu()) })
      samp_sd <- reactive({ sd(samp()) })
      output$samp_sd <- renderPrint({ paste0("Std-Dev = ",samp_sd(), " (Standard Deviation)") })
      listSampDistIntv <- reactive({ c( paste(as.character(getStdDevSampleInterval(1, samp_mu(),samp_sd())), collapse=", "), paste(as.character(getStdDevSampleInterval(2, samp_mu(),samp_sd())), collapse=", "), paste(as.character(getStdDevSampleInterval(3, samp_mu(),samp_sd())), collapse=", ")) })
      listCoveragePercentage <- reactive({ c(calculateSamplePercentageWithinStdDevInterval(1, samp(), samp_mu(),samp_sd(), lenSamp()), calculateSamplePercentageWithinStdDevInterval(2, samp(), samp_mu(),samp_sd(), lenSamp()),calculateSamplePercentageWithinStdDevInterval(3, samp(), samp_mu(),samp_sd(), lenSamp())) })
      rowSampDist <- c("1","2","3")
      sampDistDF <- reactive({ data.frame("Sampling Distrbution Interval"=listSampDistIntv(), "Coverage Percentage"=listCoveragePercentage() ,row.names=rowSampDist) })
      output$tableSampDist <- renderTable( sampDistDF() )
      
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