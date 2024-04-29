--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_FUNDING_REVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_FUNDING_REVAL" AUTHID CURRENT_USER AS
/* $Header: PAXBFRCS.pls 120.4 2006/07/25 06:35:51 lveerubh noship $ */
/*#
 * This extension can be customized to specify funding revaluation factor to revise the funding amount.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Funding Revaluation Factor Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_INVOICE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/


/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : Funding_Revaluation_factor
-- Type          : Public
-- Pre-Reqs      : None
-- Function      : Oracle Projects Billing Client Extension for
--                 Funding Revalution Factor.
-- Parameters    :
-- IN              P_Project_ID          IN   NUMBER     Required
--                          Project Identifier. Corresponds to the Column
--                          PROJECT_ID of PA_PROJECTS_ALL Table
--                 P_Top_Task_ID          IN   NUMBER     Optional
--                          Top Task Identifier. Corresponds to the Column
--                          TASK_ID of PA_TASKS Table
--                 P_Agreement_ID   IN   NUMBER     Required
--                          Agreement Identifier. Corresponds to the Column
--                          AGREEMENT_ID of the PA_AGREEMENTS_ALL Table
--                 P_Funding_Currency       IN   VARCHAR2  Required
--                          Funding Currency .
--                          FUNDING_CURRENCY_CODE of the PA_SUMMARY_PROJECT_FUNDINGS Table
--                 P_InvProc_Currency       IN   VARCHAR2  Required
--                          Invoice Processing Currency .
--                          INVPROC_CURRENCY_CODE of the PA_SUMMARY_PROJECT_FUNDINGS Table
--                 P_reval_through_date   IN   DATE     Required
--                          Revaluation Through Date
--                 P_reval_rate_date   IN   DATE     Required
--                          Revaluation Rate Date
--                 P_reval_rate_type   IN   VARCHAR2     Required
--                          Revaluation Rate Type
--                 P_revaluation_rate   IN   NUMBER     Required
--                          Revaluation Exchange Rate
--                 P_Funding_Backlog_Amount       IN   NUMBER  Required
--                          Backlog Amount in Funding Currency .
--                 P_Funding_paid_Amount       IN   NUMBER  Required
--                          Paid Amount in Funding Currency .
--                 P_Funding_Unpaid_Amount       IN   NUMBER  Required
--                          Unpaid Amount in Funding Currency .
--                 P_Projfunc_Backlog_Amount       IN   NUMBER  Required
--                          Backlog Amount in Project Functional Currency .
--                 P_Projfunc_paid_Amount       IN   NUMBER  Required
--                          Paid Amount in Project Functional Currency .
--                 P_Projfunc_Unpaid_Amount       IN   NUMBER  Required
--                          Unpaid Amount in Project Functional Currency .
--                 P_Invproc_Backlog_amount       IN   NUMBER  Optional
--                          Backlog  Amount in Invoice Processing Currency .
--                 X_funding_reval_factor     OUT   NUMBER  DEFAULT 1
--                 X_Status              OUT   VARCHAR2  Optional
--                          Return Status of the Procedure. Values are
--                               = 0    - Successfull Execution
--                               < 0    - Oracle Error
--                               > 0    - Application Error
--
-- End of Comments
/*----------------------------------------------------------------------------*/



/*#
 * This extension is used to apply a funding revaluation to the funding backlog amount.
 * @param P_Project_ID Identifier of the project for which the revaluation process will be applied.
 * Please provide a value.
 * @rep:paraminfo {@rep:required}
 * @param P_Top_Task_ID The identifier of the top task
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param P_Agreement_ID  Identifier of the agreement for which the revaluation process will be applied
 * @rep:paraminfo {@rep:required}
 * @param P_Funding_Currency The funding currency code
 * @rep:paraminfo {@rep:required}
 * @param P_Projfunc_currency The project functional currency code
 * @rep:paraminfo {@rep:required}
 * @param P_InvProc_Currency  The invoice processing currency code
 * @rep:paraminfo {@rep:required}
 * @param P_reval_through_date The revaluation through date
 * @rep:paraminfo {@rep:required}
 * @param P_reval_rate_date The date for the revaluation rate
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param P_projfunc_rate_type  The rate type of the project functional currency
 * @rep:paraminfo {@rep:required}
 * @param P_reval_projfunc_rate The project functional rate for the revaluation
 * @rep:paraminfo {@rep:required}
 * @param P_invproc_rate_type The rate type of the invoice processing currency
 * @rep:paraminfo {@rep:required}
 * @param P_reval_invproc_rate The revaluation rate for the invoice processing currency
 * @rep:paraminfo {@rep:required}
 * @param P_Funding_Backlog_Amount The funding backlog amount
 * @rep:paraminfo {@rep:required}
 * @param P_Funding_paid_Amount The paid funding amount
 * @rep:paraminfo {@rep:required}
 * @param P_Funding_Unpaid_Amount The unpaid funding amount
 * @rep:paraminfo {@rep:required}
 * @param P_Projfunc_Backlog_Amount The backlog amount in project functional currency
 * @rep:paraminfo {@rep:required}
 * @param P_Projfunc_paid_Amount The paid amount in project functional currency
 * @rep:paraminfo {@rep:required}
 * @param P_Projfunc_Unpaid_Amount The unpaid amount in project functional currency
 * @rep:paraminfo {@rep:required}
 * @param P_Invproc_Backlog_amount The backlog amount in invoice processing currency
 * @rep:paraminfo {@rep:required}
 * @param X_funding_reval_factor  The funding revaluation factor. This factor is applied
 * to the backlog funding amount.
 * @rep:paraminfo {@rep:required}
 * @param X_Status  Displays the status of the process. Indicates whether the process had errors or not.
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Funding Revaluation Factor Extension
 * @rep:compatibility S
*/


Procedure Funding_Revaluation_factor (
                          P_Project_ID                  IN  NUMBER,
                          P_Top_Task_ID                 IN  NUMBER,
                          P_Agreement_ID                IN  NUMBER,
                          P_Funding_Currency            IN  VARCHAR2,
                          P_Projfunc_currency           IN  VARCHAR2,
                          P_InvProc_Currency            IN  VARCHAR2,
			  P_reval_through_date   	IN   DATE,
			  P_reval_rate_date   		IN   DATE,
			  P_projfunc_rate_type   	IN   VARCHAR2,
			  P_reval_projfunc_rate            IN   NUMBER,
			  P_invproc_rate_type   	IN   VARCHAR2,
			  P_reval_invproc_rate            IN   NUMBER,
			  P_Funding_Backlog_Amount      IN   NUMBER ,
			  P_Funding_paid_Amount         IN   NUMBER,
			  P_Funding_Unpaid_Amount       IN   NUMBER,
			  P_Projfunc_Backlog_Amount     IN   NUMBER,
			  P_Projfunc_paid_Amount        IN   NUMBER,
			  P_Projfunc_Unpaid_Amount      IN   NUMBER,
			  P_Invproc_Backlog_amount      IN   NUMBER,
			  X_funding_reval_factor       OUT   NOCOPY NUMBER,  --File.Sql.39 bug 4440895
			  X_Status                     OUT   NOCOPY NUMBER); --File.Sql.39 bug 4440895

END PA_Client_Extn_Funding_Reval;

/
