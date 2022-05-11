# GitHub Repo for Computational Journalism project

- The main data analysis files are in the directory `data-findings`,
where the `acs.Rmd` file examines ACS data from the Atlanta area, 
and also uses some data pulled from the [NCLD Land Use](https://developers.google.com/earth-engine/datasets/catalog/USGS_NLCD_RELEASES_2019_REL_NLCD) dataset available on Google Earth Engine; the code for pulling this data
into a usable format can be found in `atlanta-land-type.ipynb`.

- The folder `data` contains various types of data; some downloaded
externally, and some exported from the analyses run in the aforementioned
notebooks.

- The folders which have a prefix of `ga-` consist of various shape files
for different geographies within the state of Georgia.

- The folder `vids` consists of various satellite imagery timelapses
of different areas within Georgia.

- The folder `scrap` is a collection of random notebooks; you're more than
welcome to have a look, but I'm going to let you know it's a mess in
advance.