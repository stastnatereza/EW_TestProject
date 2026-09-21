CREATE OR ALTER PROCEDURE Gold.Modeling
AS
BEGIN
    
    -- DIM_DATE tabulka
    TRUNCATE TABLE Gold.Dim_Date;

    DECLARE @StartDate DATE = '2023-01-01';
    DECLARE @EndDate DATE = '2023-01-31';

    WHILE @StartDate <= @EndDate
    BEGIN
        INSERT INTO Gold.Dim_Date (DateKey, DateValue, Year, Month, Day)
        VALUES (
            CAST(FORMAT(@StartDate, 'yyyyMMdd') AS INT),
            @StartDate,
            YEAR(@StartDate),
            MONTH(@StartDate),
            DAY(@StartDate)
        );

        SET @StartDate = DATEADD(DAY, 1, @StartDate);
    END;


    -- DIM_CUSTOMER tabulka
    TRUNCATE TABLE Gold.Dim_Customer;

    INSERT INTO Gold.Dim_Customer (
        CustomerId, 
        CustomerName, 
        CustomerCategory
    )
    SELECT 
        CustomerId,
        CustomerName,
        CustomerCategory
    FROM Silver.Customers 
    WHERE IsActive = 1;
    

    -- FACT_INVOICES tabulka
    TRUNCATE TABLE Gold.Fact_Invoices;

    WITH AggPayments AS (
        SELECT 
            InvoiceNumber,
            SUM(Amount) AS PaidAmount
        FROM Silver.Payments
        WHERE IsActive = 1
        GROUP BY InvoiceNumber
    ),
    InvoiceEvaluation AS (
        SELECT
            i.CompanyId,
            i.CustomerId,
            i.CountryId,
            i.DocumentNumber,
            i.PostingDate,
            i.Amount AS InvoicedAmount,
            ISNULL(p.PaidAmount, 0) AS PaidAmount,
            i.Amount - ISNULL(p.PaidAmount, 0) AS RemainingAmount
        FROM Silver.Invoices i
        LEFT JOIN AggPayments p ON i.DocumentNumber = p.InvoiceNumber
        WHERE i.IsActive = 1
    )

    INSERT INTO Gold.Fact_Invoices (
        CompanyId, 
        CustomerId, 
        CountryId,
        DocumentNumber,
        PostingDate,
        InvoicedAmount, 
        PaidAmount, 
        RemainingAmount, 
        InvoiceStatus
    )
    SELECT 
        CompanyId,
        CustomerId,
        CountryId,
        DocumentNumber,
        PostingDate,
        InvoicedAmount,
        PaidAmount,
        RemainingAmount,
        CASE 
            WHEN RemainingAmount <= 0 THEN 'Paid'
            WHEN PaidAmount > 0 AND RemainingAmount > 0 THEN 'Partially Paid'
            ELSE 'Open'
        END AS InvoiceStatus
    FROM InvoiceEvaluation;

END;