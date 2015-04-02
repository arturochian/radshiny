# radshiny

Simple R package to create multi-page shiny apps

I've simply copied the most important infrastructure from Vincent Nijs' [Radiant](https://github.com/vnijs/radiant) package for business analytics and wrapped it in an R package. This allows the quick creation of the infrastructure for multi-page shiny apps. The navigation recursion should allow may levels of nested navigation, but I've only done it up to two.

Not revolutionary, but it should save a bit of time.

Usage:

```
devtools::install_github('benjh33/radshiny')

nav <- list('page1', 'page2', page3 = list('sub1', 'sub2'))
radshiny::createRadShiny('yourAppName', dir = getwd() , nav = nav)
```

Here's an example: [nba-2014](http://ec2-23-22-236-244.compute-1.amazonaws.com:3838/nba-2014/)
