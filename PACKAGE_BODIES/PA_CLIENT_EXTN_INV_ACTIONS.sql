--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_INV_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_INV_ACTIONS" as
/* $Header: PAXPIACB.pls 120.1 2005/08/19 17:16:48 mwasowic noship $ */

 /*----------------------------------------------------------------------+
  |                Approve Customer Invoice Template                     |
  +----------------------------------------------------------------------*/
  Procedure Approve_Invoice ( P_Project_ID             in  number,
                              P_Draft_Invoice_Num      in  number,
                              P_Invoice_Class          in  varchar2,
                              P_Project_Amount         in  number,
                              P_Project_Currency_Code  in  varchar2,
                              P_Inv_Currency_Code      in  varchar2,
                              P_Invoice_Amount         in  number,
                              X_Approve_Flag           out NOCOPY varchar2, --File.Sql.39 bug 4440895
                              X_Status                 out NOCOPY number    ) is --File.Sql.39 bug 4440895
   BEGIN
	-- Reset the output parameters.
	X_Approve_Flag := NULL;
	X_status := 0;

	-- Add your Approve Invoice Logic here.
	-- If you want to Approve the Invoice set X_Approve_Flag to 'Y'.
	-- If it's null or set to 'N', Approval of Invoice will not be Done.
        -- Do not add 'commit' or 'rollback' in your code, since Oracle
        -- Projects controls the transaction for you.

   EXCEPTION
	when others then
        -- Add your exception handler here.
	-- To raise an application error, assign a positive number to X_Status.
	-- To raise an ORACLE error, assign SQLCODE to X_Status.
	RAISE;

   END Approve_Invoice;


 /*----------------------------------------------------------------------+
  |               Release Customer Invoice Template                      |
  +----------------------------------------------------------------------*/
  Procedure Release_Invoice ( P_Project_ID               in  number,
                              P_Draft_Invoice_Num        in  number,
                              P_Invoice_Class            in  varchar2,
                              P_Project_Amount           in  number,
                              P_Project_Currency_Code    in  varchar2,
                              P_Inv_Currency_Code        in  varchar2,
                              P_Invoice_Amount           in  number,
                              X_Release_Flag             out NOCOPY varchar2, --File.Sql.39 bug 4440895
                              X_RA_Invoice_Date          out NOCOPY date, --File.Sql.39 bug 4440895
                              X_RA_Invoice_Num           out NOCOPY varchar2, --File.Sql.39 bug 4440895
                              X_Status                   out NOCOPY number,  --File.Sql.39 bug 4440895
			      X_Credit_Memo_Reason_Code  out NOCOPY varchar2) is --File.Sql.39 bug 4440895
   BEGIN
        -- Reset the output parameters.
        X_Release_Flag := NULL;
        X_status := 0;
        X_Credit_Memo_Reason_Code := NULL;
        -- Add your Release Invoice Logic here.
        -- If you want to Approve the Invoice set X_Release_Flag to 'Y'.
        -- If it's null or set to 'N', Release of Invoice will not be Done.
        -- Do not add 'commit' or 'rollback' in your code, since Oracle
        -- Projects controls the transaction for you.

   EXCEPTION
        when others then
        -- Add your exception handler here.
        -- To raise an application error, assign a positive number to X_Status.
        -- To raise an ORACLE error, assign SQLCODE to X_Status.
        RAISE;

   END Release_Invoice;

/* Overloaded Procedure Release_invoice for credit memo reason */
Procedure Release_Invoice (   P_Project_ID               in  number,
                              P_Draft_Invoice_Num        in  number,
                              P_Invoice_Class            in  varchar2,
                              P_Project_Amount           in  number,
                              P_Project_Currency_Code    in  varchar2,
                              P_Inv_Currency_Code        in  varchar2,
                              P_Invoice_Amount           in  number,
                              X_Release_Flag             out NOCOPY varchar2, --File.Sql.39 bug 4440895
                              X_RA_Invoice_Date          out NOCOPY date, --File.Sql.39 bug 4440895
                              X_RA_Invoice_Num           out NOCOPY varchar2, --File.Sql.39 bug 4440895
                              X_Status                   out NOCOPY number) is --File.Sql.39 bug 4440895

new_excp        exception;
BEGIN
Raise new_excp;
END Release_Invoice ;


end PA_Client_Extn_Inv_Actions;

/
