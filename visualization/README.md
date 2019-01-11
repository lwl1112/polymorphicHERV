This is a tool to visually depict the distribution of polymorphic HERV-K on the world map across a population
There are two user inputs: population.json and polymat.json 


# How to generate user inputs: population.json, polymat.json. 

codes can be found in ```generate_json/```

## Get population information from the 1000 genomes dataset: population, which contains 'Sample \tab Population' from 

http://www.internationalgenome.org/data-portal/sample

Convert that into population.json (remove last , in json).
```
perl generatepopulation.pl population population.json
```

## prepare a matrix: mat.dat, each row indicating predictions of individuals (0: absense, other numbers: presence) for one polymorphic HERV-K, 
Convert that into polymat.json (remove last , in json).
```
perl generatejson.pl poly mat.dat population polymat.json   
```

# Explanation for other json data files:

dataset.json:  globlal map  
chromosomes.json:  polymorphic HERV-K coordinates


-------------------------------

validate json online: https://jsonlint.com/
