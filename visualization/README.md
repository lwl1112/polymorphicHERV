This is an instruction for implementing an visualized distribution tool for polymorphic HERV-K. 

1. How to generate user inputs: population.json, polymat.json. 
codes can be found in ```generate_json/```

1.1 get population information from the 1000 genomes dataset: population, 
then converted into population.json.
```
perl generatepopulation.pl population population.json
```

1.2 prepare a matrix: mat.dat, each row indicating predictions of individuals (0: absense, 1: presence) for one polymporhic HERV-K, 
then converted int polymat.json.
```
perl generatejson.pl poly mat.dat population polymat.json   
```

2. explanations for other json data files:

dataset.json:  globlal map  
chromosomes.json:  polymorphic HERV-K coordinates


-------------------------------

validate json online: https://jsonlint.com/
