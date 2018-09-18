## Release Summary
Package updated to fix recently broken CRAN package check on Windows.

## Test environments
* local OS X install, R 3.5.0
* ubuntu 14.04.5 (on travis-ci), R 3.4.1
* local Windows install, R 3.5.1

## R CMD check results
There were no ERRORs or WARNINGs.

There were two NOTEs. The size of the package can be explained by the data it contains. We changed the maintainer, but the new maintainer was thoroughly involved in the maintenance and authorship of earlier versions.

  checking installed package size ... NOTE
    installed size is  5.2Mb
    sub-directories of 1Mb or more:
      data   5.0Mb
  
  checking CRAN incoming feasibility ... NOTE
    Maintainer: 'Jay Lee <jaylee@reed.edu>'
    
    New maintainer:
      Jay Lee <jaylee@reed.edu>
    
    Old maintainer(s):
      Matthew Yancheff <yanchefm@reed.edu>

## Downstream dependencies
There are currently no downstream dependencies for this package.
