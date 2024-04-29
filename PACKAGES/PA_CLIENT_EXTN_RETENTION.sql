--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_RETENTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_RETENTION" AUTHID CURRENT_USER as
/* $Header: PAXBRTCS.pls 120.4 2006/07/25 06:36:18 lveerubh noship $ */
/*#
 * This extension can be customized to define a company's business rules to bill withheld amounts.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Retention Billing Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_INVOICE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : Bill_Retention
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : Oracle Projects Billing Client Extension for
--                 Retention Billing.
-- Parameters    :
-- IN              P_Project_ID          IN   NUMBER     Required
--                          Project Identifier. Corresponds to the Column
--                          PROJECT_ID of PA_PROJECTS_ALL Table
--                 P_Customer_ID   IN   NUMBER     Required
--                          Customer Identifier. Corresponds to the Column
--                          CUSTOMER_ID of the RA_CUSTOMERS Table
--                 P_Top_Task_ID          IN   NUMBER     Optional
--                          Top Task Identifier. Corresponds to the Column
--                          TASK_ID of PA_TASKS Table
-- OUT             X_Bill_Retention_Flag        OUT   VARCHAR2  Required
--                          Bill Retention Flag. Valid values are
--                            Y             -  Bill Retention
--                            Other Values  -  Do not Bill Retention
--                 X_Bill_Percentage     OUT   NUMBER  Optional
--                          The retention percentage to be billed.
--                          Required if Bill Retention flag is 'Y' and X_Bill_amount is
--                          NULL
--                 X_Bill_Amount     OUT   NUMBER  Optional
--                          The retention amount to be billed.
--                          Required if Bill Retention flag is 'Y' and X_Bill_percentage is
--                          NULL
--                 X_Status              OUT   VARCHAR2  Optional
--                          Return Status of the Procedure. Values are
--                               = 0    - Successfull Execution
--                               < 0    - Oracle Error
--                               > 0    - Application Error
--
-- End of Comments
/*----------------------------------------------------------------------------*/


/*#
 * This procedure can be customized to define a company's business rules to bill withheld amounts.
 * @param P_Customer_ID  Identifier of the customer for whom retention is to be billed
 * @rep:paraminfo {@rep:required}
 * @param P_Project_ID   Identifier of the project for which retention is to be billed
 * @rep:paraminfo {@rep:required}
 * @param P_Top_Task_ID Identifier of the top task for which retention is to be billed.
 * A value is entered only if the retention level is top task.
 * @rep:paraminfo {@rep:required}
 * @param X_Bill_Retention_Flag Flag indicating bill retention. A value of Y indicates
 * that the retention will be billed using the percentage or amount specified in the extension.
 * @rep:paraminfo {@rep:required}
 * @param X_Bill_Percentage   Retention billing percentage
 * @rep:paraminfo {@rep:required}
 * @param X_Bill_Amount Retention bill amount
 * @rep:paraminfo {@rep:required}
 * @param X_Status  Status indicating whether an error occurred. The valid values are =0 (Success), <0 (SQL Error) OR >0 (Application Error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Retention Billing
 * @rep:compatibility S
*/

Procedure Bill_Retention (
                          P_Customer_ID                 in  number,
                          P_Project_ID                  in  number,
                          P_Top_Task_ID                 in  number,
                          X_Bill_Retention_Flag        out NOCOPY varchar2, --File.Sql.39 bug 4440895
                          X_Bill_Percentage             out NOCOPY number, --File.Sql.39 bug 4440895
                          X_Bill_Amount                 out NOCOPY number, --File.Sql.39 bug 4440895
                          X_Status                      out NOCOPY number    );  --File.Sql.39 bug 4440895

END PA_Client_Extn_Retention;

/
