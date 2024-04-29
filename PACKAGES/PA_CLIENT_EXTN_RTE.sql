--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_RTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_RTE" AUTHID CURRENT_USER as
-- $Header: PAXTRT1S.pls 120.5 2006/07/29 11:40:44 skannoji noship $
/*#
 * Oracle Projects provides a template package that contains the procedure that you can modify to implement check approval extensions.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Check Approval
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_LABOR_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
 */

/*#
 * Procedure that can be modified to implement check approval extensions
 * @param X_Expenditure_Id The internal identifier of the expenditure
 * @rep:paraminfo {@rep:required}
 * @param X_Incurred_By_Person_Id The identifier of the employee who submitted expenditure
 * @rep:paraminfo {@rep:required}
 * @param X_Expenditure_End_Date The ending date of the expenditure period
 * @rep:paraminfo {@rep:required}
 * @param X_Exp_Class_Code Identifer of expenditure type, either (OT for timesheets or OE for expense reports)
 * @rep:paraminfo {@rep:required}
 * @param X_Amount  Amount of the expenditure. The value must be "hours" if the value of X_EXP_CLASS_CODE is OT. For other expenditure types the value can be "P"T or "dollars"
 * @rep:paraminfo {@rep:required}
 * @param X_Approver_Id Identifier of the employee approving the expenditure
 * @rep:paraminfo {@rep:required}
 * @param X_Routed_To_Mode Responsibility of approving employee(SUPERVISOR or ALL)
 * @rep:paraminfo {@rep:required}
 * @param P_Timecard_Table The entire timecard in PL/SQL table format (used when this procedure is called from Oracle Time and Labor)
 * @rep:paraminfo {@rep:required}
 * @param P_Module Application calling this expenditure. (OTL for Oracle Time and Labor)
 * @rep:paraminfo {@rep:required}
 * @param X_Status Status indicating whether an error occurred. The valid values are =0 (Success), <0 OR >0 (Application Error)
 * @rep:paraminfo {@rep:required}
 * @param X_Application_Id Short name of application defined in AOL (PA for Oracle Projects)
 * @rep:paraminfo {@rep:required}
 * @param X_Message_Code Message Code
 * @rep:paraminfo {@rep:required}
 * @param X_Token_1 Message token used in warning messages
 * @rep:paraminfo {@rep:required}
 * @param X_Token_2 Message token used in warning messages
 * @rep:paraminfo {@rep:required}
 * @param X_Token_3 Message token used in warning messages
 * @rep:paraminfo {@rep:required}
 * @param X_Token_4 Message token used in warning messages
 * @rep:paraminfo {@rep:required}
 * @param X_Token_5 Message token used in warning messages
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check Approval Extension
 * @rep:compatibility S
 */

dummy Pa_Otc_Api.Timecard_Table;

Procedure check_approval
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
             X_Token_5               Out NOCOPY Varchar2 );

end PA_CLIENT_EXTN_RTE ;
 

/
