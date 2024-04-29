--------------------------------------------------------
--  DDL for Package PA_BUDGET_FUND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_FUND_PKG" AUTHID CURRENT_USER as
-- $Header: PABBFNDS.pls 120.5 2006/09/20 16:51:08 bkattupa noship $



--
-- Procedure            : check_or_reserve_funds
-- Purpose              : procedure called from budgets forms.
--                        This process will verify if funds check is required
--                        or not. Accordingly the procedure will call gl and/or
--                        cbc funds check procedure for each account summary line
--                        for input budget version id.

--Parameters            :
--                        p_calling_code :  CHECK_FUNDS/CHECK_BASELINE/RESERVE_BASELINE
--                        x_dual_bdgt_cntrl_flag : Y --> Yes, N --> No

PROCEDURE check_or_reserve_funds ( p_project_id             IN   NUMBER,
                                   p_budget_version_id      IN   NUMBER,
                                   p_calling_mode           IN   VARCHAR2,
                                   x_dual_bdgt_cntrl_flag   OUT  NOCOPY VARCHAR2,
                                   x_cc_budget_version_id   OUT  NOCOPY NUMBER,
                                   x_return_status          OUT  NOCOPY VARCHAR2,
                                   x_msg_count              OUT  NOCOPY NUMBER,
                                   x_msg_data               OUT  NOCOPY VARCHAR2 );

--
-- Procedure            : get_budget_ctrl_options
-- Purpose              : To get Budget Control Options for given project id and
--                        calling mode.
--Parameters            :
--                        p_calling_code :  STANDARD/COMMITMENT/BUDGET
--                        x_fck_req_flag --> Y (Yes), N (No), Null (Error)
--                        x_bdgt_intg_flag --> G (GL) , C (CC) , N (None) , Null (Error)

PROCEDURE get_budget_ctrl_options ( p_project_id          IN   NUMBER,
                                 p_budget_type_code       IN   VARCHAR2,
                                 p_calling_mode           IN   VARCHAR2,
                                 x_fck_req_flag           OUT  NOCOPY VARCHAR2,
                                 x_bdgt_intg_flag         OUT  NOCOPY VARCHAR2,
                                 x_bdgt_ver_id            OUT  NOCOPY NUMBER,
                                 x_encum_type_id          OUT  NOCOPY NUMBER,
                                 x_balance_type           OUT  NOCOPY VARCHAR2,
                                 x_return_status          OUT  NOCOPY VARCHAR2,
                                 x_msg_count              OUT  NOCOPY NUMBER,
                                 x_msg_data               OUT  NOCOPY VARCHAR2 );


--
-- Procedure            : upd_bdgt_acct_bal
-- Purpose              : Update the account level balances for given account, period
--                        and budget version id.
--Parameters            :
--                       p_amount
--                            +ve amount : means amount is send for liquidation.
--                            -ve amount : means amount is send for reservation.
--                        process : Update the available balance field with :
--                                  available_balance - p_amount.
--

PROCEDURE upd_bdgt_acct_bal (    p_gl_period_name         IN   VARCHAR2,
                                 p_budget_version_id      IN  NUMBER,
                                 p_ccid                   IN  NUMBER,
                                 p_amount                 IN  NUMBER,
                                 x_return_status          OUT  NOCOPY VARCHAR2,
                                 x_msg_count              OUT  NOCOPY NUMBER,
                                 x_msg_data               OUT  NOCOPY VARCHAR2 );


--
-- Procedure            : upd_bdgt_acct_bal_no_fck
-- Purpose              : Update the amount available column in pa_budget_acct_lines
--                        table during budget baselining process. This is called when
--                        funds check is not required during baselining process.
--                        The projects funds check process deternimes this by comparing
--                        current budget's budget lines with the previous budget's budget
--                        lines. In this case only amounts have changed.
--                        Apply the following formula :
--                          CA = ( CB - PB ) + PA
--
--                          CA : Current Available Amount
--                          CB : Current Budget Amount
--                          PB : Previous Budget Amount
--                          PA : Previous Available Amount
--Parameters            :
--                       p_amount
--                            +ve amount : means amount is send for liquidation.
--                            -ve amount : means amount is send for reservation.
--                        process : Update the available balance field with :
--                                  available_balance - p_amount.
--

PROCEDURE upd_bdgt_acct_bal_no_fck (  p_budget_version_id      IN  NUMBER,
                                 x_return_status          OUT  NOCOPY VARCHAR2,
                                 x_msg_count              OUT  NOCOPY NUMBER,
                                 x_msg_data               OUT  NOCOPY VARCHAR2 );

--
-- Function		: Is_bdgt_intg_enabled
-- Purpose		: This functions returns a true/false for a given project_id
--			  and mode
-- Parameters		: P_mode	S-> Standard , C -> Commitment
--			  p_budget_version_id

FUNCTION Is_bdgt_intg_enabled (p_project_id             IN  NUMBER,
			       p_mode			IN  VARCHAR2)
RETURN BOOLEAN 	;

--
-- Procedure            : copy_budgetary_controls
-- Purpose              : This procedure is called from the copy project api.
--                        This api will copy budgetary controls from one
--                        project to another project.
-- Parameters           :

PROCEDURE copy_budgetary_controls (p_from_project_id      IN   NUMBER,
                                   p_to_project_id        IN   NUMBER,
                                   x_return_status             OUT  NOCOPY VARCHAR2,
                                   x_msg_count                 OUT  NOCOPY NUMBER,
                                   x_msg_data                  OUT  NOCOPY VARCHAR2 );

--
-- Procedure            : release_bc_lock
-- Purpose              :

-- Parameters           :

PROCEDURE release_bc_lock (p_project_id      IN   NUMBER ,
                            x_return_status          OUT  NOCOPY VARCHAR2,
                            x_msg_count              OUT  NOCOPY NUMBER,
                            x_msg_data               OUT  NOCOPY VARCHAR2 );

--
-- Function		: Is_pa_bc_enabled
-- Purpose		: This functions returns true if the profile option
--			  PA_BC_ENABLED is set as 'Y' otherwise flase.
-- Parameters		: None.
--

FUNCTION Is_pa_bc_enabled  RETURN BOOLEAN 	;

--
-- Function             : Is_Budget_Locked
-- Purpose              : This functions returns true if the Budget is locked
--                        otherwise false.
-- Parameters           : Lock_Name
--

FUNCTION Is_Budget_Locked ( P_Lock_Name  IN VARCHAR2) RETURN BOOLEAN ;

-- -------------------------------------------------------------------------------+
-- PROCEDURE Create_events_and_fundscheck
-- Purpose: This procedure create accounting events and calls BC Funds check
--          API for budget baseline/re-baseline/year-end processing/check funds
--          for budget
-- Parameters and values:
-- p_calling_module       - 'Year_End_Rollover' (Year End)/'Cost_Budget'/
--                          'Cmt_Budget'/'Revenue_Budget'/'Dual_Budget'(Budgets)
-- p_mode                 - 'Reserve_Baseline'/'Check_Baseline'/'Force'(Year-end)
-- p_external_budget_code - 'GL'/'CC'/'Dual'
-- p_budget_version_id    -  GL Budget version id
-- p_cc_budget_version_id -  CC Budget version id
-- p_Result_code          - 'S' for success amd 'E' for failure (OUT parameter)
--
-- Called from : check_or_reserve_funds
--               pa_year_end_rollover_pkg.year_end_rollover
-- -------------------------------------------------------------------------------+
	PROCEDURE create_events_and_fundscheck
	(P_calling_module       IN Varchar2,
         P_mode                 IN Varchar2,
         P_External_Budget_Code IN Varchar2,
         P_budget_version_id    IN Number,
         P_cc_budget_version_id IN Number,
         P_result_code         OUT NOCOPY Varchar2);

-- ----------------------------------------------------------------------------------+
-- Following new global variables are being defined for SLA-BC Integration
-- These global variables will be accessed in pa_xla_interface_pkg and
-- pa_funds_control_pkg
-- GLOBAL Variables are:
-- --------------------
 g_budget_amount_code         VARCHAR2(1);  -- 'C' for Cost and 'R' for Revenue
 g_processing_mode            VARCHAR2(15); -- YEAR_END or BASELINE or CHECK_FUNDS
 g_balance_type               VARCHAR2(1);  -- E/B
 g_external_link              VARCHAR2(4);  -- GL/DUAL
 g_cost_rebaseline_flag       VARCHAR2(1);  -- Y/N
 g_cc_rebaseline_flag         VARCHAR2(1);  -- Y/N
 g_cost_current_bvid          pa_budget_versions.budget_version_id%TYPE;
--                              (Current baselined/draft version)
 g_cost_prev_bvid             pa_budget_versions.budget_version_id%TYPE;
--                              (Last baselined budget version to reverse)
 g_cc_current_bvid            pa_budget_versions.budget_version_id%TYPE;
--                              (Current baselined/draft version)
 g_cc_prev_bvid               pa_budget_versions.budget_version_id%TYPE;
--                              (Last baselined budget version to reverse)
--
-- -----------------------------------------------------------------------------------+

   FUNCTION Get_previous_bvid(p_project_id              IN NUMBER,
                              p_budget_type_code        IN VARCHAR2,
                              p_curr_budget_status_code IN VARCHAR2)
   return NUMBER;

-- -----------------------------------------------------------------------------------+
-- Function Unburdened_cdl_exists .. returns BOOLEAN
-- This function checks if there are any unburdened CDLs that exists for a budget
-- If there exists, it returns TRUE ..else for all case ..it returns FALSE
-- Accessed from PAXBUEBU - Budget form ..
-- -----------------------------------------------------------------------------------+
   FUNCTION Unburdened_cdl_exists(X_project_id IN Number)
   RETURN BOOLEAN;


END PA_BUDGET_FUND_PKG;

 

/
