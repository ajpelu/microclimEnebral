# Method step
Sensorización del enebral en Sierra Nevada. 

- [Formulario de introducción de datos de las visitas de campo](https://forms.gle/kULKy1tEuW1YsMUc8). En `./forms/visitas_sensores.gform´ se encuentra el formulario. 
- [Datos de las visitas a campo](). En `./forms/visitas_sensores_records.gsheet´ se encuentra la tabla. 

## Metadatos de los sensores desplegados 
- De cada sensor es necesaria una información importante (*e.g.* serial number, fecha de inicio, etc) 
- Se ha creado una función `metadataTidbit()` que obtiene algunos metadatos básicos de cada registrador. En concreto esta función devuelve: 

     - serial number 
     - nombre dado al sensor 
     - tiempo de incio del registrador 
     - tiempo de fin del registrador 

- El script [`R/get_metadata_tidbit.R`](R/get_metadata_tidbit.R) procesa los archivos de detalle que se pueden obtener a partir de cada archivo `.hobo` para obtener los metadatos de todos los registradores y los exporta como un csv (`sensor_metadata.csv`) que se almacena en [`data/sensor_metadata.csv`](data/sensor_metadata.csv). El procedimiento es el siguiente: 

  - Descarga de los datos en el campo (hobo)
  - Crear una carpeta con los datos brutos por cada fecha de descarga con el nombre YYYY_MM_DD dentro de [`data/hobo_raw`](data/hobo_raw)
  - Copiar (sobreescribir) los datos brutos a [`data/hobo_last`](data/hobo_last) 
  - Abrir los archivos de `hobo_last` con el software HOBOWarePro y exportar de cada archivo `.hobo` un txt de sus detalles, y guardarlo en [`data/hobo_detail`](data/hobo_detail) 

<p align="center">
<img src="https://raw.githubusercontent.com/ajpelu/microclimEnebral/master/doc/exportar_detalles.png" height="300">
</p>

  - Ejecutar el script [`R/get_metadata_tidbit.R`](R/get_metadata_tidbit.R)

## Lectura de los datos de los sensores 

- Abrimos cada archivo hobo presente en [`data/hobo_last`](data/hobo_last) con HOBOWarePro
- Exportamos cada archivo `.hobo` como `.csv`. Para ello clicamos en "Export Table Data" 

<p align="center">
<img src="https://raw.githubusercontent.com/ajpelu/microclimEnebral/master/doc/exportar_data.png" height="300">
</p>

y luego seleccionamos las variables a exportar 
<p align="center">
<img src="https://raw.githubusercontent.com/ajpelu/microclimEnebral/master/doc/exportar_data_variables.png" height="250">
</p>

- Los datos se guardan en [`data/hobo_last`](data/hobo_last) con formato `.csv`. 

## Generar archivo de datos  


## Workflow 

https://dreampuf.github.io/GraphvizOnline 

```
digraph G {

  subgraph cluster_0 {
    /*style=filled;
    color=lightgrey;*/
    node [style=filled];
    hobo_raw -> hobo_last -> HOBOWare -> hobo_details;
    hobo_details -> gmd; 
    gmd -> sensor_metadata;
    label = "Get metadata \nfrom Hobo files";
  }

hobo_raw[shape=box]; 
hobo_last[shape=box];
hobo_details[shape=box,label="/hobo_details\n sensorDetalles.txt"];
HOBOWare[shape=hexagon,sytle=filled,color=".5 .2 1.0"];
gmd[label="get_metadata_tidbit.R",color="steelblue2",shape="box"];

  subgraph cluster_1 {
    node [style=filled];
    hobo_csv -> bulkRead; 
    bulkRead -> readHobo; 
    bulkRead -> validate;
    label = "Read data";
  }

hobo_csv[shape=box,label="/hobo_last\n sensorName.csv"];
bulkRead[color="steelblue2",shape=box,label="bulk Read.R"]
readHobo[label="readHobo.R",color="steelblue2",shape=box];
validate[label="Validate by range", shape=box]


  subgraph cluster_2 {
      node[style=filled];
      temp -> tempMD[style="invis"];
      tempMD -> tempSpatial[style="invis"];
      label = "generate RDS"

temp[label="temp_microenebral.rds",color=yellowgreen,style=filled]
tempSpatial[label="temp_microenebral_spatial.rds",color=yellowgreen,style=filled]
tempMD[label="temp_microenebral_md.rds",color=yellowgreen, style=filled]

validate -> temp;
readHobo -> temp;
bulkRead -> tempSpatial;
bulkRead -> tempMD;

  } 


HOBOWare -> hobo_csv
}
```

