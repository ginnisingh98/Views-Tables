--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_RETENTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_RETENTION" as
/* $Header: PAXBRTCB.pls 120.2 2005/08/19 17:09:50 mwasowic noship $ */

 /*----------------------------------------------------------------------+
  |                Retention Billing Template                            |
  +----------------------------------------------------------------------*/
Procedure Bill_Retention (
			  P_Customer_ID                 in  number,
                          P_Project_ID                  in  number,
                          P_Top_Task_ID                 in  number,
                          X_Bill_Retention_Flag        out NOCOPY varchar2, --File.Sql.39 bug 4440895
                          X_Bill_Percentage             out NOCOPY number, --File.Sql.39 bug 4440895
                          X_Bill_Amount                 out NOCOPY number, --File.Sql.39 bug 4440895
                          X_Status                      out NOCOPY number    ) is --File.Sql.39 bug 4440895
   BEGIN
	-- Reset the output parameters.
	X_status := 0;

	-- This extension will be called only if the billing method is chosen as
        -- 'Client Extension' in the retention setup for a customer, project and top task
        -- Add your Retention Billing Logic here.
	-- If you want to bill the retention set the X_Bill_retention_flag to 'N'.
	-- If it's null or set to 'N', Billing of retention will not be Done.
        -- Do not add 'commit' or 'rollback' in your code, since Oracle
        -- Projects controls the transaction for you.

   EXCEPTION
	when others then
             X_Bill_Retention_Flag   := NULL; --NOCOPY
             X_Bill_Percentage       := NULL; --NOCOPY
             X_Bill_Amount           := NULL; --NOCOPY
        -- Add your exception handler here.
	-- To raise an application error, assign a positive number to X_Status.
	-- To raise an ORACLE error, assign SQLCODE to X_Status.
	RAISE;

   END Bill_Retention;


end PA_Client_Extn_Retention;

/
