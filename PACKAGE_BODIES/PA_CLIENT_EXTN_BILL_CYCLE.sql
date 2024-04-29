--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_BILL_CYCLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_BILL_CYCLE" AS
-- $Header: PAXIBCXB.pls 115.0 99/07/16 15:25:24 porting ship $

function    Get_Next_Billing_Date (
                X_Project_ID            IN  Number,
                X_Project_Start_Date    IN  Date,
                X_Billing_Cycle_ID      IN  Number,
                X_Bill_Thru_Date        IN  Date,
                X_Last_Bill_Thru_Date   IN  Date
                                 )   RETURN Date
IS

Last_Date	Date := sysdate;

BEGIN

NULL;

RETURN Last_Date;

EXCEPTION

   WHEN OTHERS then
   RAISE;

END Get_Next_Billing_Date;

--------------------------------------------------------------------
END PA_Client_Extn_Bill_Cycle;


/
