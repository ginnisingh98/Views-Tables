--------------------------------------------------------
--  DDL for Package PA_FUNDS_CONTROL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FUNDS_CONTROL_UTILS" AUTHID CURRENT_USER as
-- $Header: PAFCUTLS.pls 120.14.12010000.3 2009/06/05 04:10:26 apaul ship $

--Global variables declared to  use as one level cache
-- this improves the performance significantly
  	g_project_id		pa_bc_packets.project_id%type := null;
	g_bdgt_version_id	pa_bc_packets.budget_version_id%type := null;
	g_calling_mode		VARCHAR2(25)  := null;
	g_calling_mode1		VARCHAR2(25)  := null;
	g_calling_mode2		VARCHAR2(25)  := null;
	g_calling_mode3		VARCHAR2(25)  := null;
	g_task_id		pa_bc_packets.task_id%type  := null;
	g_exp_type		pa_bc_packets.expenditure_type%type  := null;
	g_exp_item_date		DATE  := null;
	g_exp_org_id		pa_bc_packets.expenditure_organization_id%type := null;
	g_budget_ccid		pa_bc_packets.budget_ccid%type := null;
	g_start_date		DATE := null;
	g_end_date		DATE := null;
	g_rlmi			pa_bc_packets.resource_list_member_id%type := null;
	g_period_name		pa_bc_packets.period_name%type := null;
	g_compiled_set_id       NUMBER  := null;
	g_multiplier            NUMBER  := null;
	g_fnd_reqd_flag         VARCHAR2(25)  := null;
	g_encum_type_id 	NUMBER  := null;
	g_ext_bdgt_link		VARCHAR2(25)  := null;
	g_sch_rev_id            NUMBER  := null;

        -- Bug 5373272
        g_event_type_code            xla_events.event_type_code%TYPE := NULL ;
        g_document_distribution_id   pa_bc_packets.document_distribution_id%TYPE := NULL ;
        g_document_distribution_type pa_bc_packets.document_distribution_type%TYPE := NULL ;
        g_parent_distribution_id     pa_bc_packets.document_distribution_id%TYPE := NULL ;

PROCEDURE init_util_variables;
-- this API gets the compiled multipliers for the given task and expenditure organization id
-- and expenditure item date for burden calculations
FUNCTION get_fc_compiled_multiplier
		( p_exp_org_id 	   IN  NUMBER,
		  p_task_id        IN  VARCHAR2,
		  P_exp_item_date  IN  date,
		  p_sch_type       IN varchar2 default 'C',
		  p_exp_type       IN  varchar2
		) return NUMBER ;

-- This api gets the compiled set id for the given task,expenditure organization id
-- and expenditure item date for burden calculations
FUNCTION get_fc_compiled_set_id
	( p_task_id  	IN NUMBER
	 ,p_ei_date     IN DATE
       	,p_org_id	IN NUMBER
        ,p_sch_type	IN VARCHAR2 DEFAULT 'C'
        ,p_calling_mode	IN VARCHAR2 DEFAULT 'COMPILE_SET_ID'
	,p_exp_type     IN VARCHAR2  /** added for Burdening changes PAL */
	) return NUMBER ;

-- This API gets the burden cost for the given expenditure item id  and cdl line number
-- from the cost distribution lines all
FUNCTION get_fc_proj_burdn_cost
		(p_exp_item_id 	IN NUMBER
		,p_line_num	IN NUMBER
		)return NUMBER ;

-- This is a PLSQL Record for holding the information of the open and closed periods
TYPE rec_closed_period IS  RECORD(period_name  gl_period_statuses.period_name%type,
                                         start_date     date,
                                         end_date       date,
                                         closing_status VARCHAR2(1)
                                        );
--  This is a PLSQL Table of type PLSQL Record
TYPE tab_closed_period IS  TABLE OF rec_closed_period index by binary_integer;


-- This Api gets the open and closed periods start date, end date, period name and status
-- for the given start date ( Amount type) and end date ( boundary code) and sob
-- the out parameter will be in form of PLSQL  table and also it returns the no of rows in
-- plsql table
PROCEDURE get_gl_periods
                (p_start_date           IN      date
                ,p_end_date             IN      date
                ,p_set_of_books_id      IN      gl_period_statuses.set_of_books_id%type
                ,x_tab_count            IN OUT  NOCOPY Number
                ,x_tab_pds              IN OUT  NOCOPY pa_funds_control_utils.tab_closed_period
                ,x_return_status        IN OUT  NOCOPY varchar2
                );

-----------------------------------------------------------------------------------
--This API is a wrapper for the get_budgt_ctrl_options This api provides differenct
--options for the given project_id and calling mode
-----------------------------------------------------------------------------------
-- This api checks whether the funds check required for the given
-- project  the return value  is 'Y' or 'N'
FUNCTION  get_fnd_reqd_flag
	(p_project_id	IN 	NUMBER
	,p_calling_mode IN	VARCHAR2 -- STD / CBC
	) return varchar2 ;

-- This api gives the budget version id for the given project id
FUNCTION  get_bdgt_version_id
	(p_project_id	IN 	NUMBER
	,p_calling_mode IN	VARCHAR2  -- STD / CBC
	) return PA_BUDGET_VERSIONS.budget_version_id%TYPE ;

-- this api gets the encumbrance type id for the given project id

FUNCTION  get_encum_type_id
	(p_project_id	              IN 	NUMBER
	,p_calling_mode               IN	VARCHAR2   -- STD / CBC
	) return NUMBER ;

-- this api checks the budget is linked with GL or not the valid
-- return values are 'Y' or 'N'

FUNCTION  get_bdgt_link
	(p_project_id	IN 	NUMBER
	,p_calling_mode IN	VARCHAR2   -- STD / CBC
	) return varchar2 ;

--The following API returns the Budget CCID for a given project, task,
--resource list member id, budget version id and start_date.
PROCEDURE Get_Budget_CCID (
                 p_project_id           in number,
                 p_task_id              in number,
                 p_top_task_id          in number,
                 p_res_list_mem_id      in number,
                 p_start_date           in date,
                 p_budget_version_id    in number,
                 p_entry_level_code     in varchar2,
                 x_budget_ccid          out NOCOPY number,
	         x_budget_line_id       out NOCOPY number,
                 x_return_status        out NOCOPY varchar2,
                 x_error_message_code   out NOCOPY varchar2);

--The following API returns the Time Phased Type Code for a budget_version_id.
PROCEDURE Get_Time_Phased_Type_Code(
              p_budget_version_id       in number,
              x_time_phased_type_code   out NOCOPY varchar2,
              x_return_status           out NOCOPY varchar2,
              x_error_message_code      out NOCOPY varchar2);

--The following API gets the current baselined budget version id for the project id.
PROCEDURE Get_Baselined_Budget_Version(
            p_calling_mode        in varchar2,
            p_project_id          in number,
            x_base_version_id     out NOCOPY number,
            x_res_list_id         out NOCOPY number,
            x_entry_level_code    out NOCOPY varchar2,
            x_return_status       out NOCOPY varchar2,
            x_error_message_code  out NOCOPY varchar2);

--The following API returns the available balance for the budget_version, budget_CCID and start date
--from PA_BUDGET_ACCT_LINES
FUNCTION Get_Acct_Line_Balance(
            p_budget_version_id in number,
            p_start_date in date,
            p_end_date in date,
            p_budget_ccid in number) RETURN NUMBER;

--The following API returns true if the budget has been baselined before else false if it is the
--first time we are baselining.
FUNCTION Is_Budget_Baselined_Before(p_project_id in number) RETURN VARCHAR2;

--This function submits the sweeper process a concurrent request.
--This function is called at the end of the Tieback_BC_Entities procedure from
--the budget form during baselining.
FUNCTION RunSweeper RETURN NUMBER;

PROCEDURE print_message(p_msg in varchar2);


-- #This function has been created in base release 12 for SLA - FC integration project
-- #Function "Is_account_change_allowed" is the API that will be called from
-- #budgets form and from funds check tieback processing. This function will
-- #check if there exists any transaction, against any budget line, whose
-- #account has been modified. It will return 'N' if there exists transaction
-- #against a budget line, else it will return 'Y'.

FUNCTION Is_account_change_allowed (P_budget_version_id       IN Number,
        			    P_resource_assignment_id  IN Number,
        			    P_period_name             IN Varchar2,
        			    P_budget_entry_level_code IN Varchar2 default null)
return Varchar2;

-- ## Another variation of is_account_change_allowed
-- ## This is called from pa_budget_account_pkg and pa_funds_control_pkg

FUNCTION   Is_Account_change_allowed2
              (p_budget_version_id       IN Number,
               p_project_id              IN Number,
               p_top_task_id             IN Number,
               p_task_id                 IN Number,
               p_parent_resource_id      IN Number,
               p_resource_list_member_id IN Number,
               p_start_date              IN Date,
               p_period_name             IN Varchar2,
               p_entry_level_code        IN Varchar2,
               p_mode                    IN Varchar2)
return Varchar2;

-- #R12 Funds management enhancement
-- #API name     : get_sla_notupgraded_flag
-- #Type         : private
-- #Description  : Returns Y/N depending on whether the distribution and associated
-- #              budget passed as input are notupgraded

FUNCTION get_sla_notupgraded_flag ( p_application_id            IN NUMBER,
                                    p_entity_code               IN VARCHAR2,
                                    p_document_header_id	IN NUMBER,
                                    p_document_distribution_id	IN NUMBER,
                                    p_dist_link_type 	        IN VARCHAR2,
                                    p_budget_version_id       	IN NUMBER,
                                    p_budget_line_id            IN NUMBER  ) RETURN VARCHAR2;


-- #R12 Funds management enhancement
-- #API name     : Update_bvid_blid_on_cdl_bccom
-- #Type         : private
-- #Description  : Stamps latest budget version id and  budget_line_id on
--                 1. CDL when called from baselining process
--                 2. CDL and bc commitments when called from yearend rollover process

PROCEDURE Update_bvid_blid_on_cdl_bccom ( p_bud_ver_id  IN NUMBER,
                                          p_calling_mode IN VARCHAR2);

-- #Bug 5191768
-- #API name     : Get_cost_rejection_reason
-- #Type         : private
-- #Description  : Returns PA/GMS lookup meaning for the failure lookup code

FUNCTION Get_cost_rejection_reason ( p_Lookup_code               IN VARCHAR2,
				     p_sponsored_flag            IN VARCHAR2)
return VARCHAR2;

-- #R12 Funds management enhancement
-- #API name     : get_ap_acct_reversal_attr
-- #Type         : private
-- #Description  : Returns parent distribution id if its a AP cancel scenario and
--                 SLA accounting reversal logic will be fired if this api returns NOT NULL

FUNCTION get_ap_acct_reversal_attr ( p_event_type_code               IN VARCHAR2,
                                     p_document_distribution_id      IN NUMBER  ,
				     p_document_distribution_type    IN VARCHAR2 ) RETURN NUMBER;

-----------------------------------------------------------------------------------
-- #R12 Funds management enhancement
-- #API name     : get_ap_sla_reversed_status
-- #Type         : private
-- #Description  : Returns 'Y' if AP is cancelled and the SLA lines associated with
--                 AP has been reversed .Business flow cannot be used in this scenario.
-------------------------------------------------------------------------------------
FUNCTION get_ap_sla_reversed_status (p_invoice_id              IN NUMBER,
                                     p_invoice_distribution_id IN NUMBER ) RETURN VARCHAR2;

-----------------------------------------------------------------------------------
-- R12 Funds Management Uptake
-- Procedure to derive credit/debit side of the amount for PO and REQ  distributions
-------------------------------------------------------------------------------------
FUNCTION DERIVE_PO_REQ_AMT_SIDE (p_event_type_code     IN VARCHAR2,
                                 p_main_or_backing_doc IN VARCHAR2,
                                 p_distribution_type   IN VARCHAR2 ) RETURN NUMBER;

-- Bug 5206341 : Function to check if there exists any closed periods in current budget version
FUNCTION CLOSED_PERIODS_EXISTS_IN_BUDG (p_budget_version_id IN NUMBER) RETURN VARCHAR2;

-- This Api returns 'Y' if project has funds check enbaled.
FUNCTION is_funds_check_enabled(p_proj_id IN NUMBER )return VARCHAR2;

END PA_FUNDS_CONTROL_UTILS ;

/
