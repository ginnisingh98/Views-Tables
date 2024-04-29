--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_BILL_CYCLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_BILL_CYCLE" AUTHID CURRENT_USER AS
-- $Header: PAXIBCXS.pls 120.3 2006/07/25 06:36:40 lveerubh noship $
/*#
 * This extension contains a function to derive the next billing date for a project.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Billing Cycle Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_INVOICE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : Get_Next_Billing_Date
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : Oracle Projects Billing Client Extension for Determining
--                 the Next Billing Date
-- Parameters    :
-- IN              X_Project_ID          IN   NUMBER     Required
--                          Project Identifier. Corresponds to the Column
--                          PROJECT_ID of PA_PROJECTS_ALL Table
--		   X_Project_Start_Date  IN   Date       Optional
--			    Project Start Date. Corresponds to the Column
--			    START_DATE of PA_PROJECTS_ALL Table
--			    and used as NVL( START_DATE, CREATION_DATE)
--                 X_Billing_Cycle_ID    IN   NUMBER     Optional
--                          Billing Cycle ID. Corresponds to the Column
--                          BILLING_CYCLE_ID of PA_PROJECTS_ALL Table
--                 X_Bill_Thru_Date      IN   DATE       Required
--                          Bill Through Date for the Invoice Generation
--			    Process.
--                 X_Last_Bill_Thru_Date IN   DATE       Required
--                          Last Bill Through Date. Corresponds to the Column
--			    BILL_THROUGH_DATE of PA_DRAFT_INVOICES_ALL Table
-- RETURNS	   DATE
--
-- End of Comments
/*#
 * This function returns a value for the next billing date.
 * @return Returns the next billing date
 * @param X_Project_ID The identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param X_Project_Start_Date The start date of the project
 * @rep:paraminfo {@rep:required}
 * @param X_Billing_Cycle_ID   The identifier of the billing cycle code
 * @rep:paraminfo {@rep:required}
 * @param X_Bill_Thru_Date   The bill through date entered for the process
 * @rep:paraminfo {@rep:required}
 * @param X_Last_Bill_Thru_Date The last bill through date of the project
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Next Billing Date
 * @rep:compatibility S
*/
function	Get_Next_Billing_Date (
					X_Project_ID		IN	Number,
					X_Project_Start_Date	IN	Date,
					X_Billing_Cycle_ID	IN	Number,
					X_Bill_Thru_Date	IN	Date,
					X_Last_Bill_Thru_Date	IN	Date
								)	RETURN Date;
pragma RESTRICT_REFERENCES ( Get_Next_Billing_Date, WNDS, WNPS );

END PA_Client_Extn_Bill_Cycle;


/
