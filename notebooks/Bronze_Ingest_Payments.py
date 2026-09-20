file_path = "Files/DS3_Payments.csv" 
table_name = "dbo.Payments"

df = (
    spark.read.format("csv")
    .option("header", "true")       # První řádek jako název sloupce
    .option("delimiter", ";")       # Definice oddělovače
    .option("inferSchema", "false") # Všechny datové typy jako string beze změny
    .load(file_path)
)

df.write.format("delta").mode("overwrite").saveAsTable(table_name)