--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_RTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_RTE" as
/* $Header: PAXTRT1B.pls 120.2 2006/06/26 23:05:28 eyefimov noship $ */

PROCEDURE check_approval
           ( X_Expenditure_Id         In Number,
             X_Incurred_By_Person_Id  In Number,
             X_Expenditure_End_Date   In Date,
             X_Exp_Class_Code         In Varchar2,
             X_Amount                 In Number,
             X_Approver_Id            In Number,
             X_Routed_To_Mode         In Varchar2,
             P_Timecard_Table         IN Pa_Otc_Api.Timecard_Table Default PA_CLIENT_EXTN_RTE.dummy,
             P_Module                 IN VARCHAR2 DEFAULT NULL,
             X_Status                Out NOCOPY Number,
             X_Application_Id        Out NOCOPY Varchar2,
             X_Message_Code          Out NOCOPY Varchar2,
             X_Token_1               Out NOCOPY Varchar2,
             X_Token_2               Out NOCOPY Varchar2,
             X_Token_3               Out NOCOPY Varchar2,
             X_Token_4               Out NOCOPY Varchar2,
             X_Token_5               Out NOCOPY Varchar2 )
IS

     -- Declare your local variables here

BEGIN

     /*
        This client extension contains no default code, but can be used by customers
        to review and approve expenditures based on delivered values and pass back
        message if final authority for approver does not exist.

        The mandatory OUT Parameter x_indicates the return status of the API.
        The following values are valid:

        = 0 Approver had final authority to approve the expenditure.
        < 0 Unexpected error occurred in extension
        > 0 Approver did not have the final authority to approve the expenditure.
     */

     -- Initialize output parameters
     X_Status := 0;
     X_message_code   := NULL ;
     X_Application_Id := NULL ;
     X_Token_1        := NULL ; -- Token Name => 'TOKEN_1'
     X_Token_2        := NULL ; -- Token Name => 'TOKEN_2'
     X_Token_3        := NULL ; -- Token Name => 'TOKEN_3'
     X_Token_4        := NULL ; -- Token Name => 'TOKEN_4'
     X_Token_5        := NULL ; -- Token Name => 'TOKEN_5'

     -- Define your business rules here

EXCEPTION
  WHEN OTHERS THEN
    -- Define your exception handler here.
    -- To raise an ORACLE error, assign SQLCODE to x_status.
       X_status := SQLCODE;
END check_approval;


END PA_CLIENT_EXTN_RTE;

/
