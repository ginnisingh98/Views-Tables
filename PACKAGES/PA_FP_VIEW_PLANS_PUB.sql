--------------------------------------------------------
--  DDL for Package PA_FP_VIEW_PLANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_VIEW_PLANS_PUB" AUTHID CURRENT_USER as
/* $Header: PAFPVPLS.pls 120.1.12010000.2 2009/07/22 01:02:03 snizam ship $
   Start of Comments
   Package name     : pa_fin_plan_maint_ver_global
   Purpose          : API's for Financial Planning: View Plans Page
   History          :
   NOTE             :
   End of Comments
*/

type av_tab_project_id is
    TABLE of pa_resource_assignments.project_id%TYPE index by BINARY_INTEGER;
type av_tab_task_id is
    TABLE of pa_resource_assignments.task_id%TYPE index by BINARY_INTEGER;
type av_tab_resource_list_member_id is
    TABLE of pa_resource_assignments.resource_list_member_id%TYPE index by BINARY_INTEGER;
type av_tab_cost_budget_version_id is
    TABLE of pa_resource_assignments.budget_version_id%TYPE index by BINARY_INTEGER;
type av_tab_cost_res_assignment_id is
    TABLE of pa_resource_assignments.resource_assignment_id%TYPE index by BINARY_INTEGER;
type av_tab_rev_budget_version_id is
    TABLE of pa_resource_assignments.budget_version_id%TYPE index by BINARY_INTEGER;
type av_tab_rev_res_assignment_id is
    TABLE of pa_resource_assignments.resource_assignment_id%TYPE index by BINARY_INTEGER;
type av_tab_element_name is
    TABLE of VARCHAR2(1000) index by BINARY_INTEGER;
type av_tab_element_level is
    TABLE of VARCHAR2(50) index by BINARY_INTEGER;
type av_tab_labor_hours is
    TABLE of pa_resource_assignments.total_utilization_hours%TYPE index by BINARY_INTEGER; --Bug 7514054
type av_tab_burdened_cost is
    TABLE of pa_resource_assignments.total_plan_burdened_cost%TYPE index by BINARY_INTEGER; --Bug 7514054
type av_tab_raw_cost is
    TABLE of pa_resource_assignments.total_plan_raw_cost%TYPE index by BINARY_INTEGER; --Bug 7514054
type av_tab_revenue is
    TABLE of pa_resource_assignments.total_plan_revenue%TYPE index by BINARY_INTEGER; --Bug 7514054
type av_tab_margin is
    TABLE of pa_resource_assignments.total_plan_revenue%TYPE index by BINARY_INTEGER; --Bug 7514054
type av_tab_margin_percent is
    TABLE of pa_resource_assignments.total_utilization_percent%TYPE index by BINARY_INTEGER; --Bug 7514054
type av_tab_line_editable is
    TABLE of VARCHAR2(1) index by BINARY_INTEGER;
type av_tab_row_level is
    TABLE of NUMBER index by BINARY_INTEGER;
type av_tab_amount_type is
    TABLE of pa_proj_periods_denorm.amount_type_code%TYPE index by BINARY_INTEGER;
type av_tab_amount_subtype is
    TABLE of pa_proj_periods_denorm.amount_subtype_code%TYPE index by BINARY_INTEGER;
type av_tab_period_numbers is
    TABLE of pa_proj_periods_denorm.period_amount1%TYPE index by BINARY_INTEGER;
type av_tab_amount_type_id is
    TABLE of pa_proj_periods_denorm.amount_type_id%TYPE index by BINARY_INTEGER;
type av_tab_amount_subtype_id is
    TABLE of pa_proj_periods_denorm.amount_subtype_id%TYPE index by BINARY_INTEGER;
type av_tab_unit_of_measure is
    TABLE of pa_resource_assignments.unit_of_measure%TYPE index by BINARY_INTEGER;
type av_tab_preceding_amts is
    TABLE of pa_proj_periods_denorm.preceding_periods_amount%TYPE index by BINARY_INTEGER;
type av_tab_succeeding_amts is
    TABLE of pa_proj_periods_denorm.succeeding_periods_amount%TYPE index by BINARY_INTEGER;
type av_tab_has_child_element is
    TABLE of VARCHAR2(1) index by BINARY_INTEGER;

G_DEFAULT_AMOUNT_TYPE_CODE	VARCHAR2(30);
G_DEFAULT_AMT_SUBTYPE_CODE	VARCHAR2(30);
G_FP_COST_VERSION_ID		NUMBER(15);
G_FP_COST_VERSION_NUMBER	NUMBER(15);
G_FP_COST_VERSION_NAME		VARCHAR2(60);
G_FP_REV_VERSION_ID		NUMBER(15);
G_FP_REV_VERSION_NAME		VARCHAR2(60);
G_FP_REV_VERSION_NUMBER		NUMBER(15);
G_FP_ALL_VERSION_ID		NUMBER(15);
G_FP_ALL_VERSION_NAME		VARCHAR2(60);
G_FP_ALL_VERSION_NUMBER		NUMBER(15);
G_FP_CALC_MARGIN_FROM		VARCHAR2(30);
G_FP_CALC_QUANTITY_FROM		VARCHAR2(30);
G_DISPLAY_FROM			VARCHAR2(10); -- 'ANY', 'COST', 'REVENUE', or 'BOTH'
G_AMT_OR_PD			VARCHAR2(1); -- 'A' for amounts, 'P' for periodic
G_UNCAT_RLM_ID			NUMBER(15); -- uncategorized resource list member id

-- Display Customization Variables
G_DISPLAY_FLAG_QUANTITY		VARCHAR2(1);
G_DISPLAY_FLAG_RAWCOST		VARCHAR2(1);
G_DISPLAY_FLAG_BURDCOST		VARCHAR2(1);
G_DISPLAY_FLAG_REVENUE		VARCHAR2(1);
G_DISPLAY_FLAG_MARGIN		VARCHAR2(1);
G_DISPLAY_FLAG_MARGINPCT	VARCHAR2(1);
G_DISPLAY_FLAG_PREC		VARCHAR2(1);
G_DISPLAY_FLAG_SUCC		VARCHAR2(1);

G_FP_ORG_ID		number;
G_FP_VIEW_VERSION_ID	number;
G_FP_PLAN_TYPE_ID	number;
G_FP_RA_ID              number;
G_FP_AMOUNT_TYPE_CODE   VARCHAR2(30);--:='COST';
G_FP_ADJ_REASON_CODE    VARCHAR2(15);--:='REVENUE';
G_FP_CURRENCY_CODE	VARCHAR2(15);--:='USD';
G_FP_CURRENCY_TYPE      VARCHAR2(30);
G_FP_VIEW_START_DATE1   date;--:=to_date('01-Mar-02');
G_FP_VIEW_START_DATE2   date;--:=to_date('01-Apr_02');
G_FP_VIEW_START_DATE3   date;--:=to_date('01-May-02');
G_FP_VIEW_START_DATE4   date;--:=to_date('01-Jun-02');
G_FP_VIEW_START_DATE5   date;--:=to_date('01-Jul-02');
G_FP_VIEW_START_DATE6   date;--:=to_date('01-Aug-02');
G_FP_VIEW_START_DATE7   date;--:=to_date('01-Feb-03');
G_FP_VIEW_START_DATE8   date;--:=to_date('01-Mar-03');
G_FP_VIEW_START_DATE9   date;--:=to_date('01-Apr-03');
G_FP_VIEW_START_DATE10  date;--:=to_date('01-May-03');
G_FP_VIEW_START_DATE11  date;--:=to_date('01-Jun-03');
G_FP_VIEW_START_DATE12  date;--:=to_date('01-Jul-03');
G_FP_VIEW_START_DATE13  date;--:=to_date('01-Aug-03');
G_FP_VIEW_END_DATE1   date;--:=to_date('31-Mar-02');
G_FP_VIEW_END_DATE2   date;--:=to_date('30-Apr-02');
G_FP_VIEW_END_DATE3   date;--:=to_date('31-May-02');
G_FP_VIEW_END_DATE4   date;--:=to_date('30-Jun-02');
G_FP_VIEW_END_DATE5   date;--:=to_date('31-Jul-02');
G_FP_VIEW_END_DATE6   date;--:=to_date('31-Aug-02');
G_FP_VIEW_END_DATE7   date;--:=to_date('28-Feb-03');
G_FP_VIEW_END_DATE8   date;--:=to_date('31-Mar-03');
G_FP_VIEW_END_DATE9   date;--:=to_date('30-Apr-03');
G_FP_VIEW_END_DATE10  date;--:=to_date('31-May-03');
G_FP_VIEW_END_DATE11  date;--:=to_date('30-Jun-03');
G_FP_VIEW_END_DATE12  date;--:=to_date('31-Jul-03');
G_FP_VIEW_END_DATE13  date;--:=to_date('31-Aug-03');
G_FP_PERIOD_TYPE      VARCHAR2(30);
G_FP_PLAN_START_DATE  date;--:=to_date('01-Mar-02');
G_FP_PLAN_END_DATE    date;--:=to_date('31-Aug-02');

-- x_primary_pp_bv_id stores the bvid of the version with a valid period profile id
-- (in case of COST_AND_REV_SEP and only one has a period profile id)
PROCEDURE pa_fp_viewplan_hgrid_init
	( p_user_id		 IN  NUMBER,
	  p_orgfcst_version_id   IN  NUMBER,
          p_period_start_date    IN  VARCHAR2,
	  p_user_cost_version_id IN  pa_budget_versions.budget_version_id%TYPE,
	  p_user_rev_version_id	 IN  pa_budget_versions.budget_version_id%TYPE,
	  px_display_quantity	 IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  px_display_rawcost	 IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  px_display_burdcost	 IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  px_display_revenue	 IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  px_display_margin	 IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  px_display_marginpct	 IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  p_view_currency_type	 IN  VARCHAR2,
	  p_amt_or_pd		 IN  VARCHAR2,
	  x_view_currency_code	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_display_from	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_cost_locked_name	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_rev_locked_name	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_plan_period_type	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_labor_hrs_from_code	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_cost_budget_status_code	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_rev_budget_status_code	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_calc_margin_from	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_cost_bv_id		 OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
	  x_revenue_bv_id	 OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
	  x_plan_type_id	 OUT NOCOPY pa_budget_versions.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
	  x_plan_fp_options_id	 OUT NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
	  x_ar_flag		 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_factor_by_code	 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_diff_pd_profile_flag OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_old_pd_profile_flag	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_refresh_pd_flag	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_cost_rv_number	 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_rev_rv_number	 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_time_phase_code	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
--	  x_primary_pp_bv_id	 OUT pa_budget_versions.budget_version_id%TYPE,
	  x_in_period_profile	 OUT NOCOPY VARCHAR2, -- 'B' for before, 'A' for after --File.Sql.39 bug 4440895
	  x_prec_pds_flag	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_succ_pds_flag	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_refresh_req_id 	 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_uncat_rlmid		 OUT NOCOPY NUMBER, -- for View Link SQL --File.Sql.39 bug 4440895
	  x_def_amt_subt_code	 OUT NOCOPY VARCHAR2, -- for View Link SQL --File.Sql.39 bug 4440895
	  x_plan_class_code	 OUT NOCOPY VARCHAR2, -- for Plan Class Security (FP L) --File.Sql.39 bug 4440895
      x_auto_baselined_flag  OUT NOCOPY VARCHAR2,  -- for bug 3146974 --File.Sql.39 bug 4440895
          x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure pa_fp_viewplan_hgrid_init_ci
    	 (p_project_id           IN  pa_budget_versions.project_id%TYPE,
     	  p_ci_id    	    	 IN  pa_budget_versions.ci_id%TYPE,
     	  p_user_id		 IN  NUMBER,
          p_period_start_date    IN  VARCHAR2,
	  p_user_cost_version_id IN  pa_budget_versions.budget_version_id%TYPE,
	  p_user_rev_version_id	 IN  pa_budget_versions.budget_version_id%TYPE,
	  p_display_quantity	 IN  VARCHAR2,
	  p_display_rawcost	 IN  VARCHAR2,
	  p_display_burdcost	 IN  VARCHAR2,
	  p_display_revenue	 IN  VARCHAR2,
	  p_display_margin	 IN  VARCHAR2,
	  p_display_marginpct	 IN  VARCHAR2,
	  p_view_currency_type	 IN  VARCHAR2,
	  p_amt_or_pd		 IN  VARCHAR2,
	  x_view_currency_code	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_display_from	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_cost_locked_name	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_rev_locked_name	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_plan_period_type	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_labor_hrs_from_code	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_budget_status_code	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_calc_margin_from	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_cost_bv_id		 OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
	  x_revenue_bv_id	 OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
	  x_plan_type_id	 OUT NOCOPY pa_budget_versions.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
	  x_plan_fp_options_id	 OUT NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
	  x_ar_flag		 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_factor_by_code	 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_diff_pd_profile_flag OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_old_pd_profile_flag	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_refresh_pd_flag	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_cost_rv_number	 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_rev_rv_number	 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	  x_time_phase_code	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	  x_auto_baselined_flag	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    );

/*
PROCEDURE pa_fp_viewby_set_globals(
                                       p_amount_type_code       IN   VARCHAR2,
                                       p_resource_assignment_id IN   NUMBER,
                                       p_budget_version_id      IN   NUMBER,
                                       p_start_period           IN   VARCHAR2,
                                       x_return_status          OUT  VARCHAR2,
                                       x_msg_count              OUT  NUMBER,
                                       x_msg_data               OUT  VARCHAR2
                                   );
*/
PROCEDURE pa_fp_set_periods (
                                       p_period_start_date      IN   VARCHAR2,
                                       p_period_type            IN   VARCHAR2,
                                       x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                       x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

                            );

PROCEDURE pa_fp_set_periods_nav ( p_direction             IN    VARCHAR2,
                                  p_num_of_periods        IN    NUMBER,
                                  p_period_type           IN    VARCHAR2,
                                  x_start_date            OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_return_status         OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count             OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data              OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			         );

FUNCTION Get_Version_ID return Number;
FUNCTION Get_Fp_Period_Type return VARCHAR2; /* Added for bug 7514054*/
FUNCTION Get_Cost_Version_Id return Number;
FUNCTION Get_Rev_Version_Id return Number;
FUNCTION Get_Org_ID return Number;
FUNCTION Get_Plan_Type_ID return NUMBER;
FUNCTION Get_Derive_Margin_From_Code return VARCHAR2;
FUNCTION Get_Report_Labor_Hrs_From_Code return VARCHAR2;
FUNCTION Get_Resource_assignment_ID return NUMBER;
FUNCTION Get_Amount_Type_code return VARCHAR2;
FUNCTION Get_Adj_Reason_code return VARCHAR2;
FUNCTION Get_Currency_Code return VARCHAR2;
FUNCTION Get_Currency_Type return VARCHAR2;
FUNCTION Get_Uncat_Res_List_Member_Id return NUMBER;
FUNCTION Get_Period_Start_Date1 return Date;
FUNCTION Get_Period_Start_Date2 return Date;
FUNCTION Get_Period_Start_Date3 return Date;
FUNCTION Get_Period_Start_Date4 return Date;
FUNCTION Get_Period_Start_Date5 return Date;
FUNCTION Get_Period_Start_Date6 return Date;
FUNCTION Get_Period_Start_Date7 return Date;
FUNCTION Get_Period_Start_Date8 return Date;
FUNCTION Get_Period_Start_Date9 return Date;
FUNCTION Get_Period_Start_Date10 return Date;
FUNCTION Get_Period_Start_Date11 return Date;
FUNCTION Get_Period_Start_Date12 return Date;
FUNCTION Get_Period_Start_Date13 return Date;
FUNCTION Get_Plan_Start_Date return Date;
FUNCTION Get_Plan_End_Date return Date;
FUNCTION Get_Prec_Pds_Flag return VARCHAR2;
FUNCTION Get_Succ_Pds_Flag return VARCHAR2;

FUNCTION Get_Default_Amount_Type_Code return VARCHAR2;
FUNCTION Get_Default_Amt_Subtype_Code return VARCHAR2;
FUNCTION Get_Cost_Version_Number return NUMBER;
FUNCTION Get_Rev_Version_Number return NUMBER;
FUNCTION Get_Cost_Version_Name return VARCHAR2;
FUNCTION Get_Rev_Version_Name return VARCHAR2;
FUNCTION Get_All_Version_Name return VARCHAR2;
FUNCTION Get_All_Version_Number return NUMBER;
FUNCTION Get_Period_Type return VARCHAR2;
PROCEDURE Set_Cost_Version_Number (p_version_number IN NUMBER);
PROCEDURE Set_Rev_Version_Number (p_version_number IN NUMBER);
PROCEDURE Set_Cost_Version_Name (p_version_name	IN VARCHAR2);
PROCEDURE Set_Rev_Version_Name (p_version_name IN VARCHAR2);

/* ------------------------------------------------------------- */

/* populates the global temporary tables */
procedure view_plan_temp_tables
    (p_project_id           IN  pa_budget_versions.project_id%TYPE,
     p_budget_version_id    IN  pa_budget_versions.budget_version_id%TYPE,
     p_cost_or_revenue      IN  VARCHAR2,
     p_user_bv_flag	    IN  VARCHAR2,
     x_cost_version_number  OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_rev_version_number   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_cost_version_name    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_rev_version_name     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_diff_pd_profile_flag OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_return_status	    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count	    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data		    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    );

procedure pa_fp_vp_pop_tables_separate
    (p_project_id               IN  pa_budget_versions.project_id%TYPE,
     p_cost_budget_version_id   IN  pa_budget_versions.budget_version_id%TYPE,
     p_rev_budget_version_id    IN  pa_budget_versions.budget_version_id%TYPE,
     x_return_status		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count		OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data			OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     );

procedure pa_fp_vp_pop_tables_together
    (p_project_id               IN  pa_budget_versions.project_id%TYPE,
     p_budget_version_id        IN  pa_budget_versions.budget_version_id%TYPE,
     x_return_status		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count		OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data			OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     );

procedure pa_fp_vp_pop_tables_single
    (p_project_id           IN	pa_budget_versions.project_id%TYPE,
     p_budget_version_id    IN	pa_budget_versions.budget_version_id%TYPE,
     p_cost_or_rev          IN	VARCHAR2,
     x_return_status		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count		OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data			OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    );

function has_child_rows
    (p_project_id               IN  pa_resource_assignments.project_id%TYPE,
     p_budget_version_id1	IN  pa_resource_assignments.budget_version_id%TYPE,
     p_budget_version_id2   IN  pa_resource_assignments.budget_version_id%TYPE,
     p_task_id                  IN  pa_resource_assignments.task_id%TYPE,
     p_resource_list_member_id  IN  pa_resource_assignments.resource_list_member_id%TYPE,
     p_amount_subtype_code	IN  pa_proj_periods_denorm.amount_subtype_code%TYPE,
     p_amt_or_periodic		IN  VARCHAR2) return VARCHAR2;

end pa_fp_view_plans_pub;

/
