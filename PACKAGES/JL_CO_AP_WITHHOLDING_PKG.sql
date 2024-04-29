--------------------------------------------------------
--  DDL for Package JL_CO_AP_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_CO_AP_WITHHOLDING_PKG" AUTHID CURRENT_USER AS
/* $Header: jlcopwhs.pls 120.1 2002/11/14 19:12:41 thwon ship $ */

/**************************************************************************
 *                                                                        *
 * Name       : Jl_Co_Ap_Do_Withholding                                   *
 * Purpose    : This is the main Colombian withholding tax calculation    *
 *              routine. This procedure can be divided into three         *
 *              processing units (just like the core calculation routine) *
 *              1. Create Temporary Distribution Lines                    *
 *              2. Create AWT Distribution Lines                          *
 *              3. Create AWT Invoices                                    *
 *                                                                        *
 **************************************************************************/

PROCEDURE Jl_Co_Ap_Do_Withholding
                   (P_Invoice_Id 		IN	Number,
                    P_AWT_Date			IN 	Date,
                    P_Calling_Module		IN	Varchar2,
                    P_Amount			IN	Number,
                    P_Payment_Num		IN	Number Default Null,
                    P_Last_Updated_By		IN 	Number,
                    P_Last_Update_login		IN	Number,
                    P_Program_Application_Id	IN	Number Default Null,
                    P_Program_Id		IN	Number Default Null,
                    P_Request_Id		IN 	Number Default Null,
                    P_AWT_Success		OUT NOCOPY	Varchar2
                    );


END JL_CO_AP_WITHHOLDING_PKG;

 

/
