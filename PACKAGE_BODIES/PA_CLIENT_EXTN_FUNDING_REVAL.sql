--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_FUNDING_REVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_FUNDING_REVAL" AS
/* $Header: PAXBFRCB.pls 120.2 2005/08/19 17:09:01 mwasowic noship $ */

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
Procedure Funding_Revaluation_factor (
                          P_Project_ID                  IN  NUMBER,
                          P_Top_Task_ID                 IN  NUMBER,
                          P_Agreement_ID                IN  NUMBER,
                          P_Funding_Currency            IN  VARCHAR2,
                          P_ProjFunc_Currency           IN  VARCHAR2,
                          P_InvProc_Currency            IN  VARCHAR2,
			  P_reval_through_date   	IN   DATE,
			  P_reval_rate_date   		IN   DATE,
  			  P_projfunc_rate_type          IN   VARCHAR2,
                          P_reval_projfunc_rate         IN   NUMBER,
                          P_invproc_rate_type           IN   VARCHAR2,
                          P_reval_invproc_rate          IN   NUMBER,
			  P_Funding_Backlog_Amount      IN   NUMBER ,
			  P_Funding_paid_Amount         IN   NUMBER,
			  P_Funding_Unpaid_Amount       IN   NUMBER,
			  P_Projfunc_Backlog_Amount     IN   NUMBER,
			  P_Projfunc_paid_Amount        IN   NUMBER,
			  P_Projfunc_Unpaid_Amount      IN   NUMBER,
			  P_Invproc_Backlog_amount      IN   NUMBER,
			  X_funding_reval_factor       OUT   NOCOPY NUMBER,  --File.Sql.39 bug 4440895
			  X_Status                     OUT   NOCOPY NUMBER) IS --File.Sql.39 bug 4440895

l_funding_reval_factor    NUMBER:=1;
x1_funding_reval_factor    NUMBER:= x_funding_reval_factor;

BEGIN
     x_funding_reval_factor := l_funding_reval_factor;
     x_status		    :=0;
EXCEPTION
   when others then
       x_funding_reval_factor := x1_funding_reval_factor;  -- NOCOPY
END Funding_Revaluation_Factor;

END PA_Client_Extn_Funding_Reval;

/
