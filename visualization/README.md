This is a tool to visually depict the distribution of polymorphic HERV-K on the world map across a population
There are two user inputs: population.json and polymat.json 


# How to generate user inputs: population.json, polymat.json. 

1. The code to generate the two files can be found in the folder ```generate_json/```

The 1000 genomes dataset describes where each sample was sequenced (Check out 
http://www.internationalgenome.org/data-portal/sample). Download the file from there and convert it to a json file using the script (remove last , in json).
```
perl generatepopulation.pl population population.json
```

2. Prepare a matrix: mat.dat, each row indicating predictions of individuals (0: absense, other numbers: presence) for one polymorphic HERV-K, 
Convert that into polymat.json (remove last , in json).
```
perl generatejson.pl poly mat.dat population polymat.json   
```

# Explanation for other json data files:

dataset.json:  globlal map  
chromosomes.json:  polymorphic HERV-K coordinates


-------------------------------

validate json online: https://jsonlint.com/
