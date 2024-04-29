--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_PTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_PTE" AUTHID CURRENT_USER as
-- $Header: PAXPTEES.pls 120.3 2006/07/25 19:39:54 skannoji noship $
/*#
 * This extension contains procedures that you can use to define conditions under which expense reports are approved automatically.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname AutoApproval
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_LABOR_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

dummy Pa_Otc_Api.Timecard_Table;

-- Added a parameter to Check_Time_Exp_Proj_User to handle admin entry
-- in Web Expenses
/*#
 * You can use this procedure to return the AutoApproval profile option value defined for the user.
 * @param X_person_id Identifier of the person.
 * @param X_fnd_user_id Identifier of the FND user.
 * @param X_approved Value of the AutoApproval profile option.
 * @rep:paraminfo {@rep:required}
 * @param X_msg_text Message text.
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check Time Expense Project User
 * @rep:compatibility S
*/
PROCEDURE  Check_Time_Exp_Proj_User(X_person_id   IN NUMBER DEFAULT NULL,
                                    X_fnd_user_id IN NUMBER DEFAULT NULL,
                                    X_approved    IN OUT NOCOPY VARCHAR2,
                                    X_msg_text    OUT NOCOPY VARCHAR2 );


-- This Procedure can be customized to provide any additional validation that
-- might be required for a user .
-- If no changes are made, this procedure will return the value as set
-- in the profile option
/*#
 * This API contains the default logic to read the values of the AutoApproval profile options.
 * @param X_source The source of the expenditure
 * @rep:paraminfo {@rep:required}
 * @param X_exp_class_code The expenditure Class(OT for timecards and OE for expense reports)
 * @param X_txn_id System-generated identifier of the expenditure.
 * @param X_exp_ending_date Ending date of the expenditure week.
 * @param X_person_id The identifier for the employee transcation.
 * @param P_Timecard_table Table of expenditure items included on the timecard.
 * @param P_module The module calling the procedure (for example, Self-Service Time or Oracle Time and Labor).
 * @param X_approved Value of the AutoApproval profile option
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Expenditure Auto Approval
 * @rep:compatibility S
*/
PROCEDURE Get_Exp_AutoApproval (X_source          IN VARCHAR2,
                                X_exp_class_code  IN VARCHAR2 DEFAULT NULL,
                                X_txn_id          IN NUMBER DEFAULT NULL,
	               	            X_exp_ending_date IN DATE DEFAULT NULL,
                                X_person_id       IN NUMBER DEFAULT NULL,
			                    P_Timecard_Table  IN Pa_Otc_Api.Timecard_Table DEFAULT PAGTCX.dummy,
                                P_Module          IN VARCHAR2 DEFAULT NULL,
                                X_approved        IN OUT NOCOPY VARCHAR2);

--  This procedure can be customized to provide any additional
--  validations that might be required. If no changes are made, this procedure
--  will return the value as set in the profile option.

end PA_CLIENT_EXTN_PTE;

 

/
