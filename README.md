
Ranked Choice Voting -- R Package
=================================

`rcv` helps you work directly with raw ballot image and cast vote record data to run elections.

**Features**

-   Read in ballot image and master lookup files
-   Merge these files to get a "readable" ballot layout
-   Conduct elections, and view a round-by-round table of results
-   Compatible with `dplyr`/`magrittr` pipe syntax (`%>%`)

You can install the development version of `rcv`:

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

    ## # A tibble: 6 × 1
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

    ## # A tibble: 6 × 1
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

| contest                          | pref\_voter\_id | precinct | 1                | 2                | 3                |
|:---------------------------------|:----------------|:---------|:-----------------|:-----------------|:-----------------|
| Board of Supervisors, District 1 | 000006603       | Pct 9133 | SANDRA LEE FEWER | NA               | NA               |
| Board of Supervisors, District 1 | 000006604       | Pct 9133 | MARJAN PHILHOUR  | DAVID LEE        | SAMUEL KWONG     |
| Board of Supervisors, District 1 | 000006605       | Pct 9133 | DAVID LEE        | RICHIE GREENBERG | BRIAN J. LARKIN  |
| Board of Supervisors, District 1 | 000006606       | Pct 9133 | MARJAN PHILHOUR  | DAVID LEE        | SANDRA LEE FEWER |
| Board of Supervisors, District 1 | 000006607       | Pct 9133 | BRIAN J. LARKIN  | ANDY THORNLEY    | JASON JUNGREIS   |
| Board of Supervisors, District 1 | 000006608       | Pct 9133 | MARJAN PHILHOUR  | NA               | NA               |

To access intermediate steps, the following process can be used.

``` r
# Import and label ballot image
a <- import_data(data = sf_bos_ballot, header = T) %>%
    label(image = "ballot", format = "WinEDS")

# Import and label master lookup
b <- import_data(data = sf_bos_lookup, header = T) %>%
    label(image = "lookup", format = "WinEDS")

# Merge these two tables
c <- characterize(ballot = a, lookup = b)

knitr::kable(head(readable(c)))
```

| contest                          | pref\_voter\_id | precinct | 1                | 2                | 3                |
|:---------------------------------|:----------------|:---------|:-----------------|:-----------------|:-----------------|
| Board of Supervisors, District 1 | 000006603       | Pct 9133 | SANDRA LEE FEWER | NA               | NA               |
| Board of Supervisors, District 1 | 000006604       | Pct 9133 | MARJAN PHILHOUR  | DAVID LEE        | SAMUEL KWONG     |
| Board of Supervisors, District 1 | 000006605       | Pct 9133 | DAVID LEE        | RICHIE GREENBERG | BRIAN J. LARKIN  |
| Board of Supervisors, District 1 | 000006606       | Pct 9133 | MARJAN PHILHOUR  | DAVID LEE        | SANDRA LEE FEWER |
| Board of Supervisors, District 1 | 000006607       | Pct 9133 | BRIAN J. LARKIN  | ANDY THORNLEY    | JASON JUNGREIS   |
| Board of Supervisors, District 1 | 000006608       | Pct 9133 | MARJAN PHILHOUR  | NA               | NA               |

The `readable()` function takes the clean image, which is formatted for ease in computation, and formats it to be easily read manually.

#### Running Elections

This is done with the `rcv_tally()` function. `sf_bos_clean` is included as an example of a pre-cleaned ballot using the functions above. We will run the District 1 election from this ballot image.

``` r
results <- rcv_tally(sf_bos_clean, "Board of Supervisors, District 1")
knitr::kable(results)
```

|                    |  round1|  round2|  round3|  round4|  round5|  round6|  round7|  round8|  round9|
|--------------------|-------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|
| SANDRA LEE FEWER   |   12550|   12689|   12748|   12932|   13000|   14292|   14413|   14540|   14704|
| MARJAN PHILHOUR    |   11067|   11135|   11309|   11436|   11539|   12513|   12755|   12917|   13100|
| BRIAN J. LARKIN    |     747|     773|     810|     870|     929|    1085|    1272|    1360|      NA|
| SHERMAN R. D'SILVA |     557|     566|     594|     637|     704|     849|     950|      NA|      NA|
| RICHIE GREENBERG   |     974|     984|    1086|    1132|    1315|    1456|      NA|      NA|      NA|
| DAVID LEE          |    3396|    3408|    3633|    3699|    3756|      NA|      NA|      NA|      NA|
| JASON JUNGREIS     |     611|     626|     646|     670|      NA|      NA|      NA|      NA|      NA|
| JONATHAN LYENS     |     609|     652|     669|      NA|      NA|      NA|      NA|      NA|      NA|
| SAMUEL KWONG       |     740|     744|      NA|      NA|      NA|      NA|      NA|      NA|      NA|
| ANDY THORNLEY      |     359|      NA|      NA|      NA|      NA|      NA|      NA|      NA|      NA|
| NA                 |    3499|    3522|    3573|    3615|    3660|    4083|    4195|    4259|    4348|

Sandra Lee Fewer wins in Round 9, with 14,704 votes to Marjan Philhour's 13,100. 4,348 votes were left blank, marked invalid, or exhausted in this election.
