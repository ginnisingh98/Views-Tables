--------------------------------------------------------
--  DDL for Package AP_TE_EIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_TE_EIS_PKG" AUTHID CURRENT_USER AS
/* $Header: apteeiss.pls 120.2 2004/10/25 22:39:29 pjena noship $ */

PROCEDURE GetInvoiceTotal(
			P_Start_Date IN Date,
			P_End_Date   IN Date,
			P_Result     IN OUT NOCOPY NUMBER);

PROCEDURE GetInvoiceCount(
			P_Payables   IN NUMBER,
			P_Project    IN NUMBER,
			P_Selfserve  IN NUMBER,
			P_Result     IN OUT NOCOPY NUMBER);

PROCEDURE GetInvoiceAverage(
			P_Total      IN NUMBER,
			P_Count      IN NUMBER,
			P_Result     IN OUT NOCOPY NUMBER);

PROCEDURE GetPaymentTotal(
			P_Set_Of_Books_Id IN VARCHAR2 ,
			P_Start_Date      IN Date,
			P_End_Date        IN Date,
			P_Result          IN OUT NOCOPY NUMBER);

PROCEDURE GetPaymentCount(
			P_Set_Of_Books_Id IN VARCHAR2 ,
			P_Start_Date      IN Date,
			P_End_Date        IN Date,
			P_Result          IN OUT NOCOPY NUMBER);
PROCEDURE GetPaymentAverage(
			P_Set_Of_Books_Id IN VARCHAR2 ,
			P_Start_Date      IN Date,
			P_End_Date        IN Date,
			P_Result          IN OUT NOCOPY NUMBER);


PROCEDURE GetPayablesInvoiceCount(
                       	P_Set_Of_Books_Id IN VARCHAR2 ,
			P_Start_Date      IN Date,
			P_End_Date        IN Date,
			P_Result          IN OUT NOCOPY NUMBER);

PROCEDURE GetProjectInvoiceCount(
                       	P_Set_Of_Books_Id IN VARCHAR2 ,
			P_Start_Date      IN Date,
			P_End_Date        IN Date,
			P_Result          IN OUT NOCOPY NUMBER);

PROCEDURE GetSelfServeInvoiceCount(
                        P_Set_Of_Books_Id IN VARCHAR2 ,
			P_Start_Date      IN Date,
			P_End_Date        IN Date,
			P_Result          IN OUT NOCOPY NUMBER);


END AP_TE_EIS_PKG;

 

/
