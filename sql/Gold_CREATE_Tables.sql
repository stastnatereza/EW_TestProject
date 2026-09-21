DROP TABLE IF EXISTS [Gold].[Dim_Date];
CREATE TABLE [Gold].[Dim_Date] (
    DateKey INT,
    DateValue DATE,
    Year INT,
    Month INT,
    Day INT
);

DROP TABLE IF EXISTS [Gold].[Dim_Customer];
CREATE TABLE [Gold].[Dim_Customer] (
    CustomerId VARCHAR(50),
    CustomerName VARCHAR(100),
    CustomerCategory VARCHAR(50)
);

DROP TABLE IF EXISTS [Gold].[Fact_Invoices];
CREATE TABLE [Gold].[Fact_Invoices] (
    CompanyId VARCHAR(20),
    CustomerId VARCHAR(50),
    CountryId VARCHAR(10),
    DocumentNumber VARCHAR(100),
    PostingDate DATE,
    InvoicedAmount DECIMAL(18,2),
    PaidAmount DECIMAL(18,2),
    RemainingAmount DECIMAL(18,2),
    InvoiceStatus VARCHAR(50)
);