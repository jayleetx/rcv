
Ranked Choice Voting — R Package
================================

[![Build Status](https://travis-ci.org/ds-elections/rcv.svg?branch=master)](https://travis-ci.org/ds-elections/rcv)

`rcv` helps you work directly with raw ballot image and cast vote record data to run elections.

**Features**

-   Read in ballot image and master lookup files
-   Merge these files to get a "readable" ballot layout
-   Conduct elections, and view a round-by-round table of results
-   Visualize the flow of voters with an interactive Sankey diagram
-   Compatible with `dplyr`/`magrittr` pipe syntax (`%>%`)

**Installation**

We're on [CRAN](https://cran.r-project.org/package=rcv) now! You can install our first release:

``` r
install.packages("rcv")
```

Or, you can install the development version of `rcv` here:

``` r
devtools::install_github("ds-elections/rcv")
```

Created by:

-   Jay Lee, <jaylee@reed.edu>
-   Matthew Yancheff, <yanchefm@reed.edu>

The style of this README is inspired by the [googlesheets](%22github.com/jennybc/googlesheets%22) R package.

Basic Workflow Demo
-------------------

`sf_bos_ballot` is included as an example raw ballot image, and `sf_bos_lookup` as an example raw master lookup. Both are included as `.rda`s, and they are in the "WinEDS" format. This data comes from the 2016 San Francisco Board of Supervisors elections ([San Francisco Department of Elections](http://www.sfelections.org/results/20161108/#english_detail)).

``` r
head(sf_bos_ballot)
```

    ## # A tibble: 6 x 1
    ##                                              X1
    ##                                           <chr>
    ## 1 000000900000660300000010020000406001000012800
    ## 2 000000900000660300000010020000406002000000001
    ## 3 000000900000660300000010020000406003000000001
    ## 4 000000900000660400000010020000406001000012300
    ## 5 000000900000660400000010020000406002000012500
    ## 6 000000900000660400000010020000406003000012100

``` r
head(sf_bos_lookup)
```

    ## # A tibble: 6 x 1
    ##                                                                            X1
    ##                                                                         <chr>
    ## 1 Candidate 0000121SAMUEL KWONG                                      00000010
    ## 2 Candidate 0000131TIM E. DONNELLY                                   00000010
    ## 3 Candidate 0000133DEAN PRESTON                                      00000010
    ## 4 Candidate 0000135JOEL ENGARDIO                                     00000010
    ## 5 Candidate 0000140MELISSA SAN MIGUEL                                00000010
    ## 6 Candidate 0000144AHSHA SAFAI                                       00000010

#### Cleaning Data

The streamlined version of this process is done with the `clean_ballot()` function. `b_header` and `l_header` are logical values, based on whether the ballot and lookup file respectively have a header for the first row.

``` r
cleaned <- clean_ballot(ballot = sf_bos_ballot, b_header = T, 
                        lookup = sf_bos_lookup, l_header = T, 
                        format = "WinEDS")
knitr::kable(head(readable(cleaned)))
```

| contest                          | pref\_voter\_id | 1                | 2                | 3                |
|:---------------------------------|:----------------|:-----------------|:-----------------|:-----------------|
| Board of Supervisors, District 1 | 000006603       | SANDRA LEE FEWER | NA               | NA               |
| Board of Supervisors, District 1 | 000006604       | MARJAN PHILHOUR  | DAVID LEE        | SAMUEL KWONG     |
| Board of Supervisors, District 1 | 000006605       | DAVID LEE        | RICHIE GREENBERG | BRIAN J. LARKIN  |
| Board of Supervisors, District 1 | 000006606       | MARJAN PHILHOUR  | DAVID LEE        | SANDRA LEE FEWER |
| Board of Supervisors, District 1 | 000006607       | BRIAN J. LARKIN  | ANDY THORNLEY    | JASON JUNGREIS   |
| Board of Supervisors, District 1 | 000006608       | MARJAN PHILHOUR  | NA               | NA               |

To access intermediate steps, the following process can be used.

``` r
# Import and label ballot image
a <- import_data(data = sf_bos_ballot, header = T) %>%
    label(image = "ballot", format = "WinEDS")

# Import and label master lookup
b <- import_data(data = sf_bos_lookup, header = T) %>%
    label(image = "lookup", format = "WinEDS")

# Merge these two tables
c <- characterize(ballot = a, lookup = b, format = "WinEDS")

knitr::kable(head(readable(c)))
```

| contest                          | pref\_voter\_id | 1                | 2                | 3                |
|:---------------------------------|:----------------|:-----------------|:-----------------|:-----------------|
| Board of Supervisors, District 1 | 000006603       | SANDRA LEE FEWER | NA               | NA               |
| Board of Supervisors, District 1 | 000006604       | MARJAN PHILHOUR  | DAVID LEE        | SAMUEL KWONG     |
| Board of Supervisors, District 1 | 000006605       | DAVID LEE        | RICHIE GREENBERG | BRIAN J. LARKIN  |
| Board of Supervisors, District 1 | 000006606       | MARJAN PHILHOUR  | DAVID LEE        | SANDRA LEE FEWER |
| Board of Supervisors, District 1 | 000006607       | BRIAN J. LARKIN  | ANDY THORNLEY    | JASON JUNGREIS   |
| Board of Supervisors, District 1 | 000006608       | MARJAN PHILHOUR  | NA               | NA               |

The `readable()` function takes the clean image, which is formatted for ease in computation, and formats it to be easily read manually.

#### Running Elections

This is done with the `rcv_tally()` function. `sf_bos_clean` is included as an example of a pre-cleaned ballot using the functions above. We will run the District 1 election from this ballot image.

``` r
results <- rcv_tally(sf_bos_clean, "Board of Supervisors, District 1")
knitr::kable(results)
```

| candidate          |  round1|  round2|  round3|  round4|  round5|  round6|  round7|  round8|  round9|
|:-------------------|-------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|
| SANDRA LEE FEWER   |   12550|   12689|   12777|   12840|   13029|   13093|   13225|   13354|   14705|
| MARJAN PHILHOUR    |   11067|   11135|   11247|   11348|   11487|   11680|   11837|   12086|   13126|
| DAVID LEE          |    3396|    3408|    3488|    3551|    3622|    3857|    3961|    4093|      NA|
| RICHIE GREENBERG   |     974|     984|    1042|    1220|    1272|    1386|    1508|      NA|      NA|
| BRIAN J. LARKIN    |     747|     773|     832|     896|     956|     997|      NA|      NA|      NA|
| SAMUEL KWONG       |     740|     744|     760|     785|     814|      NA|      NA|      NA|      NA|
| JONATHAN LYENS     |     609|     652|     679|     726|      NA|      NA|      NA|      NA|      NA|
| JASON JUNGREIS     |     611|     626|     654|      NA|      NA|      NA|      NA|      NA|      NA|
| SHERMAN R. D'SILVA |     557|     566|      NA|      NA|      NA|      NA|      NA|      NA|      NA|
| ANDY THORNLEY      |     359|      NA|      NA|      NA|      NA|      NA|      NA|      NA|      NA|
| NA                 |    3499|    3532|    3630|    3743|    3929|    4096|    4578|    5576|    7278|

Sandra Lee Fewer wins in Round 9, with 14,705 votes to Marjan Philhour's 13,126. 4,360 votes were left blank, marked invalid, or exhausted in this election.

#### Visualizing Data

We have two recommended methods of visualizing RCV data. Both utilize a flowchart called a "Sankey diagram" to show the transfer of voters between rounds. We will use each method to visualize the transfer of voters in the San Francisco District 7 Board of Supervisors election, because District 1 has too many crossings to be readable.

Method 1 (preferred because it is interactive, quicker, and more readable) uses the `networkD3` package:

``` r
d3_7 <- rcv::make_d3list(results = sf_7_results)
networkD3::sankeyNetwork(Links = d3_7$values, Nodes = d3_7$names,
                         Source = "source", Target = "target",
                         Value = "value", NodeID = "candidate", units = "voters",
                         fontSize = 12, nodeWidth = 20)
```

![](Sankey.png)

Method 2 uses the `alluvial` package (this type of graphic is also called an alluvial diagram):

``` r
alluvial_7 <- rcv::make_alluvialdf(image = sf_bos_clean,
                                   rcvcontest = "Board of Supervisors, District 7")
alluvial::alluvial(
  alluvial_7[,1:4], freq = alluvial_7$frequency,
  col = ifelse(alluvial_7$round4 == "NORMAN YEE", "lightgreen", "gray"),
  border = "gray", alpha = 0.7, blocks = TRUE
)
```

![](README_files/figure-markdown_github/unnamed-chunk-8-1.png)
