--------------------------------------------------------
--  DDL for Package PA_INVOICE_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_INVOICE_TRANSFER" AUTHID CURRENT_USER AS
-- $Header: PAXVTRXS.pls 120.1 2005/08/19 17:23:05 mwasowic noship $

	Procedure Client_Extn_Driver( P_Project_ID	        IN	Number,
					P_Draft_Invoice_Num	IN	Number,
					P_Draft_Invoice_Type    IN	Varchar2,
					P_AR_Trx_Type		IN	Varchar2,
					X_AR_Trx_Type		OUT	NOCOPY Varchar2, --File.Sql.39 bug 4440895
					X_Reject_Code		OUT	NOCOPY Varchar2 ); --File.Sql.39 bug 4440895

	Procedure Validate_AR_Trx_Type ( P_AR_Trx_Type_ID IN Number,
                                         P_Project_Id     IN Number,
                                         P_Draft_Inv_Num  In Number,
					P_Invoice_Date    IN Date,
					X_AR_Trx_Type 	 OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
					X_Reject_Code	 OUT NOCOPY Varchar2 ); --File.Sql.39 bug 4440895

END PA_Invoice_Transfer;

 

/
