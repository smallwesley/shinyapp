---
title: "EDS Tool - Help/Documentation"
author: "Wesley Small (smallwesley)"
date: "August 7, 2016"
output: html_document
---

# Exponential Distribution Simulation Help

This tool allows use to quickly investigate the exponential distribution and compare it with the Central Limit Theorem (CLT). With the Central Limit Theorem, the rule states that the distribution of average of IID (Independant & Identically Distributed) variables, (when properly normalized), becomes that of a standard normal distribution.  This is more evident as the sample size increases.

## To Use this Tool:

This tool has a basic interface to allowing use to specify the parameters of the exponential distribution.  
You can modify the the parameters entered into the exponential formula and investigate the distribution of a large sampling of averages of groups (no of simulations). This tool has reactive interface so once your modify the parameters in the left panel, you will see some modifications to the summary view in the primary panel.

1. Use the slide to change the lambda rate used in the calculations.

2. Modify the number of exponentials in your experiments.

3. Modify the number of simulations that will be calculated for the primary simulation.

4. In the main panel on the right, toggle between the tabs/panes to see different results, plots and charts about the exponential distribution.

* * *

## Review of some of the parameters within the EDS Tool:

| Parameter          | Variable        | Value                      | Notes       |
|--------------------|---------------|------------------------------|--------------|
| Exponential Distribution | getExpDist | function(n, lambda) rexp(n,lambda) | See Param-Note 1 below |
| Mean  | getExpDistMean |function(lambda) 1/lambda  |   |
| Standard Deviation | getExpDistStdDev | function(lambda) 1/lambda|   |
| Rate Parameter | lambda | 0.2 | Note: Default value |
| Observations Count | n | 40 | Note: Default Value |
| Simulation Count | nosim | 1000 | Note: Default Value |
| Theoretical Mean | expDistMean | getExpDistMean(lambda) = 5 | |

Param-Note 1: The expontential distribution can be simulated with this function *getExpDist*, where *lambda* is a rate parameter. We will pass in the number of exponentials we want to be calculated.

