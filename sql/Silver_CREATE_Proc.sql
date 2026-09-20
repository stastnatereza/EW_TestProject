CREATE OR ALTER PROCEDURE Silver.Transformation
AS
BEGIN

    -- CUSTOMERS
    WITH CustomersTransformation AS (
        SELECT 
            TRIM(CustomerId) AS CustomerId,
            TRIM(CustomerName) AS CustomerName,
            UPPER(LEFT(TRIM(CustomerCategory), 1)) + LOWER(SUBSTRING(TRIM(CustomerCategory), 2, 8000)) AS CustomerCategory,
            ROW_NUMBER() OVER (PARTITION BY TRIM(CustomerId) ORDER BY TRIM(CustomerName)) AS RowNum
        FROM [Bronze_LH].[dbo].[customers]
    ),
    CustomersSource AS (
        SELECT 
            CustomerId, 
            CustomerName, 
            CustomerCategory
        FROM CustomersTransformation
        WHERE RowNum = 1
    )
    MERGE INTO Silver.Customers AS Target
    USING CustomersSource AS Source
    ON Target.CustomerId = Source.CustomerId
    WHEN MATCHED THEN 
        UPDATE SET 
            Target.CustomerName = Source.CustomerName,
            Target.CustomerCategory = Source.CustomerCategory,
            Target.IsActive = 1
    WHEN NOT MATCHED BY TARGET THEN 
        INSERT (CustomerId, CustomerName, CustomerCategory, IsActive)
        VALUES (Source.CustomerId, Source.CustomerName, Source.CustomerCategory, 1)
    WHEN NOT MATCHED BY SOURCE THEN 
        UPDATE SET Target.IsActive = 0;


    -- INVOICES
    WITH InvoicesTransformation AS (
        SELECT 
            TRIM(CompanyId) AS CompanyId,
            TRIM(CustomerId) AS CustomerId,
            TRIM(CountryId) AS CountryId,
            TRIM(DocumentNumber) AS DocumentNumber,
            TRIM(DocumentType) AS DocumentType,
            TRY_CAST(PostingDate AS DATE) AS PostingDate,
            TRIM(Entry) AS Entry,
            TRIM(EntryType) AS EntryType,
            TRY_CAST(Amount AS DECIMAL(18,2)) AS Amount,
            ROW_NUMBER() OVER (PARTITION BY TRIM(DocumentNumber) ORDER BY PostingDate) AS RowNum
        FROM [Bronze_LH].[dbo].[invoices]
    ),
    InvoicesSource AS (
        SELECT 
            CompanyId, 
            CustomerId, 
            CountryId,
            DocumentNumber,
            DocumentType,
            PostingDate,
            Entry,
            EntryType,
            Amount
        FROM InvoicesTransformation
        WHERE RowNum = 1
    )
    MERGE INTO Silver.Invoices AS Target
    USING InvoicesSource AS Source
    ON Target.DocumentNumber = Source.DocumentNumber
    WHEN MATCHED THEN 
        UPDATE SET 
            Target.CompanyId = Source.CompanyId,
            Target.CustomerId = Source.CustomerId,
            Target.CountryId = Source.CountryId,
            Target.DocumentType = Source.DocumentType,
            Target.PostingDate = Source.PostingDate,
            Target.Entry = Source.Entry,
            Target.EntryType = Source.EntryType,
            Target.Amount = Source.Amount,
            Target.IsActive = 1
    WHEN NOT MATCHED BY TARGET THEN 
        INSERT (CompanyId, CustomerId, CountryId, DocumentNumber, DocumentType, PostingDate, Entry, EntryType, Amount, IsActive)
        VALUES (Source.CompanyId, Source.CustomerId, Source.CountryId, Source.DocumentNumber, Source.DocumentType, Source.PostingDate, Source.Entry, Source.EntryType, Source.Amount, 1)
    WHEN NOT MATCHED BY SOURCE THEN 
        UPDATE SET Target.IsActive = 0;

    -- PAYMENTS
    WITH PaymentsTransformation AS (
        SELECT 
            TRIM(CompanyId) AS CompanyId,
            TRIM(CustomerId) AS CustomerId,
            TRIM(CountryId) AS CountryId,
            TRIM(DocumentNumber) AS DocumentNumber,
            TRIM(DocumentType) AS DocumentType,
            TRY_CAST(PostingDate AS DATE) AS PostingDate,
            TRIM(Entry) AS Entry,
            TRIM(EntryType) AS EntryType,
            TRY_CAST(Amount AS DECIMAL(18,2)) AS Amount,
            TRIM(InvoiceNumber) AS InvoiceNumber,
            TRIM(InvoiceEntry) AS InvoiceEntry,
            HASHBYTES('SHA2_256', CONCAT(TRIM(DocumentNumber), '|', TRIM(InvoiceNumber), '|', CAST(TRY_CAST(Amount AS DECIMAL(18,2)) AS VARCHAR(50)))) AS PaymentHash
        FROM [Bronze_LH].[dbo].[payments]
    ),
    PaymentsSource AS (
        SELECT *, 
            ROW_NUMBER() OVER (PARTITION BY PaymentHash ORDER BY PostingDate) as RowNum    
        FROM PaymentsTransformation
    )
    MERGE INTO Silver.Payments AS Target
    USING (SELECT * FROM PaymentsSource WHERE RowNum = 1) AS Source
    ON Target.PaymentHash = Source.PaymentHash
    WHEN MATCHED THEN 
        UPDATE SET 
            Target.CompanyId = Source.CompanyId,
            Target.CustomerId = Source.CustomerId,
            Target.CountryId = Source.CountryId,
            Target.DocumentType = Source.DocumentType,
            Target.PostingDate = Source.PostingDate,
            Target.Entry = Source.Entry,
            Target.EntryType = Source.EntryType,
            Target.InvoiceEntry = Source.InvoiceEntry,
            Target.IsActive = 1
    WHEN NOT MATCHED BY TARGET THEN 
        INSERT (CompanyId, CustomerId, CountryId, DocumentNumber, DocumentType, PostingDate, Entry, EntryType, Amount, InvoiceNumber, InvoiceEntry, PaymentHash, IsActive)
        VALUES (Source.CompanyId, Source.CustomerId, Source.CountryId, Source.DocumentNumber, Source.DocumentType, Source.PostingDate, Source.Entry, Source.EntryType, Source.Amount, Source.InvoiceNumber, Source.InvoiceEntry, Source.PaymentHash, 1)
    WHEN NOT MATCHED BY SOURCE THEN 
        UPDATE SET Target.IsActive = 0;

END;