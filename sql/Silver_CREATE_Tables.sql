DROP TABLE IF EXISTS [Silver].[Customers];
CREATE TABLE [Silver].[Customers] (
    CustomerId VARCHAR(50),
    CustomerName VARCHAR(100),
    CustomerCategory VARCHAR(50),
    IsActive BIT
);

DROP TABLE IF EXISTS [Silver].[Invoices];
CREATE TABLE [Silver].[Invoices] (
    CompanyId VARCHAR(20),
    CustomerId VARCHAR(50),
    CountryId VARCHAR(10),
    DocumentNumber VARCHAR(100),
    DocumentType VARCHAR(50),
    PostingDate DATE,
    Entry VARCHAR(50),
    EntryType VARCHAR(50),
    Amount DECIMAL(18,2),
    IsActive BIT
);

DROP TABLE IF EXISTS [Silver].[Payments];
CREATE TABLE [Silver].[Payments] (
    CompanyId VARCHAR(20),
    CustomerId VARCHAR(50),
    CountryId VARCHAR(10),
    DocumentNumber VARCHAR(100),
    DocumentType VARCHAR(50),
    PostingDate DATE,
    Entry VARCHAR(50),
    EntryType VARCHAR(50),
    Amount DECIMAL(18,2),
    InvoiceNumber VARCHAR(100),
    InvoiceEntry VARCHAR(50),
    PaymentHash VARBINARY(8000),
    IsActive BIT
);