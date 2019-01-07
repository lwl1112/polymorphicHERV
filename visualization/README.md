This is an instruction for implementing an visualized distribution tool for polymorphic HERV-K. 

1. User inputs: 

1.1 get population information from the 1000 genomes dataset: population, 

then converted into a json file: population.json as follows.
```
perl generate_json/generatepopulation.pl generate_json/population generate_json/population.json
```

1.2 prepare a matrix: mat.dat, each row indicating predictions of individuals (0: absense, 1: presence) for one polymporhic HERV-K ,

then converted into a json file: polymat.json as follows.
```
perl generate_json/generatejson.pl generate_json/poly generate_json/mat.dat generate_json/population generate_json/polymat.json   
```

2. explanations for other json data files:

dataset.json:  globlal map  
chromosomes.json:  polymorphic HERV-K coordinates


-------------------------------

validate json online: https://jsonlint.com/
