--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_INV_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_INV_TRANSFER" AS
-- $Header: PAXPTRXB.pls 120.3 2005/08/19 17:18:29 mwasowic noship $

   /*----------------------------------------------------------------------+
    |                Determine AR Transaction Type                         |
    +----------------------------------------------------------------------*/

Procedure Get_AR_Trx_Type ( 	P_Project_ID		IN	Number,
				P_Draft_Invoice_Num	IN	Number,
				P_Invoice_Class		IN	Varchar2,
                                P_Project_Amount        IN      Number,
                                P_Project_Currency_Code IN      Varchar2,
                                P_Inv_Currency_Code     IN      Varchar2,
				P_Invoice_Amount	IN	Number,
				P_AR_Trx_Type_ID	IN	Number,
				X_AR_Trx_Type_ID	OUT	NOCOPY Number,   --File.Sql.39 bug 4440895
				X_Status		OUT	NOCOPY Number ) IS --File.Sql.39 bug 4440895

BEGIN

-- Reset the output parameters.
X_AR_Trx_Type_ID := NULL;
X_Status := 0;

EXCEPTION

When OTHERS then
	X_Status := SQLCODE;
	RAISE;

END Get_AR_Trx_Type;

END PA_Client_Extn_Inv_Transfer;

/
