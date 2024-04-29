--------------------------------------------------------
--  DDL for Package Body AP_TE_EIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_TE_EIS_PKG" AS
/* $Header: apteeisb.pls 120.2 2004/10/25 22:39:11 pjena noship $ */

DEBUG CONSTANT BOOLEAN := FALSE;


PROCEDURE GetInvoiceTotal(
			P_Start_Date IN Date,
			P_End_Date   IN Date,
			P_Result     IN OUT NOCOPY NUMBER) IS
BEGIN

  select nvl(SUM(d.amount),0)
  into   P_Result
  from AP_INVOICES i,
       AP_INVOICE_DISTRIBUTIONS d
  where i.invoice_id = d.invoice_id
  and i.invoice_type_lookup_code = 'EXPENSE REPORT'
  and d.accounting_date >= P_Start_Date
  and d.accounting_date <= P_End_Date;
EXCEPTION
  when NO_DATA_FOUND then
  BEGIN
    P_Result := 0;
  END;
END GetInvoiceTotal;

PROCEDURE GetInvoiceCount(
			P_Payables   IN NUMBER,
			P_Project    IN NUMBER,
			P_Selfserve  IN NUMBER,
			P_Result     IN OUT NOCOPY NUMBER) IS
BEGIN

  P_Result := P_Payables + P_Project + P_Selfserve;

END GetInvoiceCount;


PROCEDURE GetInvoiceAverage(
			P_Total      IN NUMBER,
			P_Count      IN NUMBER,
			P_Result     IN OUT NOCOPY NUMBER) IS

BEGIN
  IF (P_Count = 0) THEN
    P_Result := 0;
  ELSE
    P_Result := P_Total / P_Count;
  END IF;

END GetInvoiceAverage;


PROCEDURE GetPaymentTotal(
			P_Set_Of_Books_Id IN VARCHAR2 ,
			P_Start_Date      IN Date,
			P_End_Date        IN Date,
			P_Result          IN OUT NOCOPY NUMBER) IS

BEGIN
  select SUM(P.amount)
  into P_Result
  from AP_INVOICE_PAYMENTS p,
       AP_INVOICES i
  where p.invoice_id = i.invoice_id
  and   p.set_of_books_id = P_Set_Of_Books_ID
  and   i.invoice_type_lookup_code = 'EXPENSE REPORT'
  and   p.accounting_date >= P_Start_Date
  and   p.accounting_date <= P_End_Date;
EXCEPTION
  when OTHERS then
  BEGIN
   P_Result := 0;
  END;

END GetPaymentTotal;


PROCEDURE GetPaymentCount(
			P_Set_Of_Books_Id IN VARCHAR2 ,
			P_Start_Date      IN Date,
			P_End_Date        IN Date,
			P_Result          IN OUT NOCOPY NUMBER) IS

BEGIN
  select COUNT(p.invoice_payment_id)
  into P_Result
  from AP_INVOICE_PAYMENTS p,
       AP_INVOICES i
  where p.invoice_id = i.invoice_id
  and   p.set_of_books_id = P_Set_Of_Books_ID
  and   i.invoice_type_lookup_code = 'EXPENSE REPORT'
  and   p.accounting_date >= P_Start_Date
  and   p.accounting_date <= P_End_Date;
EXCEPTION
  when OTHERS then
  BEGIN
   P_Result := 0;
  END;
END GetPaymentCount;

PROCEDURE GetPaymentAverage(
			P_Set_Of_Books_Id IN VARCHAR2 ,
			P_Start_Date      IN Date,
			P_End_Date        IN Date,
			P_Result          IN OUT NOCOPY NUMBER) IS

BEGIN
  select AVG(p.amount)
  into P_Result
  from AP_INVOICE_PAYMENTS p,
       AP_INVOICES i
  where p.invoice_id = i.invoice_id
  and   p.set_of_books_id = P_Set_Of_Books_ID
  and   i.invoice_type_lookup_code = 'EXPENSE REPORT'
  and   p.accounting_date >= P_Start_Date
  and   p.accounting_date <= P_End_Date;

EXCEPTION
  when OTHERS then
  BEGIN
   P_Result := 0;
  END;
END GetPaymentAverage;



PROCEDURE GetPayablesInvoiceCount(
                        P_Set_Of_Books_Id IN VARCHAR2 ,
			P_Start_Date      IN Date,
			P_End_Date        IN Date,
			P_Result          IN OUT NOCOPY NUMBER) IS
BEGIN

  select COUNT(DISTINCT(I.invoice_id))
  into P_Result
  from AP_INVOICES I,
       AP_INVOICE_DISTRIBUTIONS D
  where I.invoice_id = D.invoice_id
  and D.Set_Of_Books_Id = P_Set_Of_Books_Id
  and I.invoice_type_lookup_code = 'EXPENSE REPORT'
  and I.source in ('XpenseXpress', 'Manual Invoice Entry')
  and D.accounting_date >= P_Start_Date
  and D.accounting_date <= P_End_Date;

EXCEPTION
  when OTHERS then
  BEGIN
   P_Result := 0;
  END;

END GetPayablesInvoiceCount;

PROCEDURE GetProjectInvoiceCount(
                        P_Set_Of_Books_Id IN VARCHAR2 ,
			P_Start_Date      IN Date,
			P_End_Date        IN Date,
			P_Result          IN OUT NOCOPY NUMBER) IS
BEGIN

  select COUNT(DISTINCT(I.invoice_id))
  into P_Result
  from AP_INVOICES I,
       AP_INVOICE_DISTRIBUTIONS D
  where I.invoice_id = D.invoice_id
  and   I.source = 'Oracle Project Accounting'
  and   D.set_of_books_id = P_Set_Of_Books_Id
  and   D.accounting_date >= P_Start_Date
  and   D.accounting_date <= P_End_Date;
EXCEPTION
  when OTHERS then
  BEGIN
   P_Result := 0;
  END;
END GetProjectInvoiceCount;

PROCEDURE GetSelfServeInvoiceCount(
                        P_Set_Of_Books_Id IN VARCHAR2 ,
			P_Start_Date      IN Date,
			P_End_Date        IN Date,
			P_Result          IN OUT NOCOPY NUMBER) IS

BEGIN

  select COUNT(DISTINCT(I.invoice_id))
  into P_Result
  from AP_INVOICES I,
       AP_INVOICE_DISTRIBUTIONS D
  where I.invoice_id = D.invoice_id
  and D.Set_Of_Books_Id = P_Set_Of_Books_Id
  and I.source = 'SelfService'
  and D.accounting_date >= P_Start_Date
  and D.accounting_date <= P_End_Date;

EXCEPTION
  when OTHERS then
  BEGIN
   P_Result := 0;
  END;

END GetSelfServeInvoiceCount;


END AP_TE_EIS_PKG;

/
