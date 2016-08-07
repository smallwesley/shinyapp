shinyUI(
  fluidPage(
    titlePanel(
      h1("Exponential Distribution Simulations (EDS)")),
    sidebarLayout(
      sidebarPanel(
        "This EDS Tool investigates the exponential distribution with comparison to Central Limit Theorem (CLT). ",
        hr(),
        HTML('<a href="help.html" target="_blank">Click here for detailed Help</a>'),
        hr(),
        "Choose how random exponentials will be distributed:",
        sliderInput("paramLambda", "Lambda Rate:", 0.1, 0.9, 0.2, step=0.1),
        numericInput("paramN", "No. of Exponentials:", 40, min=10, max=1000, step=10),
        numericInput("paramNoSim", "No. of Simulations:", 1000, min=50, max= 10000, step=100 )
        ),
      mainPanel(
        tabsetPanel(
          tabPanel(
            "Summary & Histogram", 
            textOutput("copyParameters"),
            hr(),
            textOutput("copyExpDistMean"),
            textOutput("copyExpDistSD"),
            hr(),
            p("This histogram plot shows a single distribution of *X* of random exponentials."),
            plotOutput("graphExpHistogram")
          ),
          tabPanel(
            "Distributed Density Visualization",
            p("The following density plot is based on computing sufficiently large number averages of a collection independent random variable sets (Number of Simulations), *the sampling distribution*, the data when plotted will approximately match that of standard normal bell curve (density shown in blue), and thus will be normally distributed."),
            plotOutput("graphExpDistDensity"),
            hr(),
            tableOutput("tableMeans"),
            hr(),
            tableOutput("tableVariances")
          ),
          tabPanel(
            "Quantile Plot Visualization",
            p("The Quantile Plot of the distribution of exponential random variables (non-scaled). When the plotted averages resemble a staight line, it demonstrates the sample population is normally distributed."),
            plotOutput("graphExpDistQuantile")
          ),
          tabPanel(
            "Sampling Distribution",
            p("For a sampling distribution to be normal it should statify attributes of a standard normal:"),
            tags$ul(
              tags$li("Where 68% distribution lies within 1 standard deviation from it's distribution mean."),
              tags$li("Secondly, 97% lies within 2 standard deviations awat from from distribution mean."),
              tags$li("Lastly, 99% lies within 3 standard deviations from the distribution mean.")
            ),
            hr(),
            h4("The sampling population characteristics:"),
            verbatimTextOutput("samp_mu"),
            verbatimTextOutput("samp_sd"),
            verbatimTextOutput("samp_len"),
            hr(),
            h5("The first field indicates the standard deviation value from mean."),
            tableOutput("tableSampDist")
          ) 
        )
      )
    )
  )
)