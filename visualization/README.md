This is an instruction for implementing an visualized distribution tool for polymorphic HERV-K. 

1. User inputs: 

1.1 population: population.json (e.g, get population information from the 1000 genomes dataset: population, then converted into a json file)
```
perl generatepopulation.pl population population.json
```
1.2 matrix of ploymorphic predictions: polymat.json (mat.dat: 20 rows)
```
perl generatejson.pl poly mat.dat population polymat.json   
```

2. explanations for other json data files:

dataset.json:  globlal map  
chromosomes.json:  polymorphic HERV-K coordinates


-------------------------------

validate json online: https://jsonlint.com/
