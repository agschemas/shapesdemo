# Experimental cotton data

This includes captured experimental data expressed as RDF and conforming to an extensible schema for multi-domain experimental data.

## Schema

The multi-tiered schemas optimize for re-use by capturing commonalities across agricultural experiements (study design and results) as well as the specific domain details of the individual studies.
The tiers are:
1. [`Experiment`](schemas/Experiment.shex) -- study design, as well as cross-cutting structures like weather and geological data.
2. [`Crop`](schemas/Crop.shex) -- commonalities shared between different crops. An analogous schema would include commonalities for livestock.
3. Domain-specific terms, demonstrated by [`Cotton`](schemas/Cotton.shex).
These schemas are captured in the "Boxology".

## Data

The above schemas identify exactly how instance data should be expressed in RDF.
The [`cotton-experiment-1`](data/cotton-experiment-1.ttl) file includes data taken from spreadsheets representing experimental results.
In order to illustrate the usage of this data, synthetic data is included.
This synthetic data would be replaced with actual captured data when those data pipelines are established.

## Demonstration Query

The SPARQL query [query/weather.srq] illustrates a research question expressed as a SPARQL query: is harvest weight more sensitive to coldest temp or average low temp?

When executed over the [above data](data/cotton-experiment-1.ttl), we see that the example data shows a stronger sensitivity to the absolute minimum temperature:
| ?minMinTemp | ?avgMinTemp | ?weight                                               |
|-------------|-------------|-------------------------------------------------------|
|           5 |         5.8 | "11000.0"^^<http://www.w3.org/2001/XMLSchema#decimal> |
|           4 |         6.0 | "10000.0"^^<http://www.w3.org/2001/XMLSchema#decimal> |


While the data includes weather data which was invented to illustrate this point, the query itself represents a typical reseearch question which could be composed and evaluated as fast as people can conceive of the questions.
An explanation of the query follows:

### prefixes
These provide a syntactic shorthand and thus a more human-readable and maintainable query.
```
BASE <http://instance.example/>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX : <http://nal.example/schema#>
PREFIX agschema: <http://agschemas.org/>

PREFIX ucum: <https://ucum.org/ucum>
PREFIX geo: <http://www.opengis.net/ont/geosparql#>
```

### variables of interest
The SELECT clause specifies which of the variables used in the graph patterns will be returned.
Here we ask for
1. `minMinTemp`: absolute minimum temperature over the growth period
2. `avgMinTemp`: the average minimum temperature over the growth period
3. `weight`: the harvest weight for experimental lot

```
SELECT ?minMinTemp ?avgMinTemp ?weight {
```

### find all tests over the cultivar NG4545 in every experiment
**Variables**:
1. `exp`: every experiment in the system
2. `sample`: every sample in that experiment
3. `lot`: the lot/treatment for that sample
**Restrictions**:
1. `cultivar "NG4545"`: restrict to only the samples for the "NG4545" cultivar
```
  # across all samples in all experiments on NG4545
  ?exp agschema:test [
    agschema:corpus ?sample ;    
  ] .
  ?sample
    agschema:cultivar "NG4545" ;
    agschema:careAndFeeding ?lot .
```

### get the harvest weight
**Variables**:
1. `weight`: for every sample, the lot has a harvenst weight
```
  ?lot
    agschema:harvestWeight ?weight .
```
### aggregate the lows temperatures for every period
The above query components construct rows for every sample and its associated lot data.
We now use a nested query to find every moment captured in the weather data (e.g. daily or hourly, ...) and then use aggregate functions to calcuate the minimum and average low temperature over the course of the test.
**Variables**:
1. `weather`: the weather data associated with the sample's lot
2. `minTemp1`: the minimum temperature (at the atomicity of the captured weather data)  
```
  { SELECT ?sample
           (MIN (xsd:float(STR(?minTemp1))) AS ?minMinTemp)
           (AVG (xsd:float(STR(?minTemp1))) AS ?avgMinTemp)
    {
      ?sample
        agschema:weather ?weather .
      ?weather
        agschema:minTemp ?minTemp1 .
    } GROUP BY ?sample }
```
