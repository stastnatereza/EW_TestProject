file_path = "Files/DS3_Payments.csv" 
table_name = "dbo.Payments"

df = (
    spark.read.format("csv")
    .option("header", "true")
    .option("delimiter", ";")
    .option("inferSchema", "false")
    .load(file_path)
)

df.write.format("delta").mode("overwrite").saveAsTable(table_name)
