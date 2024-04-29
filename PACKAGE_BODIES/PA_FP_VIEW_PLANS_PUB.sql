--------------------------------------------------------
--  DDL for Package Body PA_FP_VIEW_PLANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_VIEW_PLANS_PUB" as
/* $Header: PAFPVPLB.pls 120.3.12010000.4 2009/08/17 09:20:46 kmaddi ship $
   Start of Comments
   Package name     : PA_FP_VIEW_PLANS_PUB
   Purpose          : API's for Financial Planning: View Plans Page
   History          :
   NOTE             :
   End of Comments
*/

-- added code to retrieve: PROJFUNC_CURRENCY_CODE, DEFAULT_AMOUNT_TYPE_CODE
-- DEFAULT_AMT_SUBTYPE_CODE
-- 6/20 added code to return view_currency_code based on view_currency_type
-- 11/15/2002: x_budget_status_code, x_ar_flag defaulted to that of p_orgfcst_version_id
--	       x_plan_type_id, x_plan_fp_options_id defaulted to that of
--		p_orgfcst_version_id
-- 19-Sep-2002 bug 3146974 Added a new out paramter x_auto_baselined_flag
PROCEDURE pa_fp_viewplan_hgrid_init
    ( p_user_id              IN  NUMBER,
      p_orgfcst_version_id   IN  NUMBER,
      p_period_start_date    IN  VARCHAR2,
      p_user_cost_version_id IN  pa_budget_versions.budget_version_id%TYPE,
      p_user_rev_version_id  IN  pa_budget_versions.budget_version_id%TYPE,
      px_display_quantity    IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      px_display_rawcost     IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      px_display_burdcost    IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      px_display_revenue     IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      px_display_margin      IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      px_display_marginpct   IN  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      p_view_currency_type   IN  VARCHAR2,
      p_amt_or_pd            IN  VARCHAR2,
      x_view_currency_code   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_display_from         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_cost_locked_name     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_rev_locked_name      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_plan_period_type     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_labor_hrs_from_code  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_cost_budget_status_code  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_rev_budget_status_code   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_calc_margin_from     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_cost_bv_id           OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
      x_revenue_bv_id        OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
      x_plan_type_id         OUT NOCOPY pa_budget_versions.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
      x_plan_fp_options_id   OUT NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
      x_ar_flag              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_factor_by_code       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_diff_pd_profile_flag OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_old_pd_profile_flag  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_refresh_pd_flag      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_cost_rv_number       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_rev_rv_number        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_time_phase_code      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
--    x_primary_pp_bv_id     OUT pa_budget_versions.budget_version_id%TYPE,
      x_in_period_profile    OUT NOCOPY VARCHAR2, -- 'B' for before, 'A' for after --File.Sql.39 bug 4440895
      x_prec_pds_flag        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_succ_pds_flag        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_refresh_req_id       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_uncat_rlmid          OUT NOCOPY NUMBER, -- for View Link SQL --File.Sql.39 bug 4440895
      x_def_amt_subt_code    OUT NOCOPY VARCHAR2, -- for View Link SQL --File.Sql.39 bug 4440895
      x_plan_class_code      OUT NOCOPY VARCHAR2, -- for Plan Class Security (FP L) --File.Sql.39 bug 4440895
      x_auto_baselined_flag  OUT NOCOPY VARCHAR2, -- for bug 3146974 --File.Sql.39 bug 4440895
      x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_msg_data             OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
l_projfunc_currency_code PA_PROJECTS_ALL.PROJFUNC_CURRENCY_CODE%TYPE;
l_default_amount_type_code      VARCHAR2(30);
l_default_amount_subtype_code   VARCHAR2(30);
l_start_date                    DATE;
ll_plan_start_date              DATE;
pp_plan_start_date              DATE; -- start_date according to period profile id
ll_plan_end_date                DATE;
ll_plan_period_type             VARCHAR2(30);
l_diff_pd_profile_flag          VARCHAR2(1);

-- error-handling variables
l_return_status  VARCHAR2(2);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(80);
l_msg_index_out  NUMBER;

l_num_of_periods   NUMBER;
l_project_id       NUMBER;
l_org_id           NUMBER;
l_cost_or_revenue  VARCHAR2(1);
l_cost_version_number       pa_budget_versions.version_number%TYPE;
l_rev_version_number        pa_budget_versions.version_number%TYPE;
l_cost_version_name         pa_budget_versions.version_name%TYPE;
l_rev_version_name          pa_budget_versions.version_name%TYPE;
l_fin_plan_type_id          pa_budget_versions.fin_plan_type_id%TYPE;
l_margin_derived_from_code  pa_proj_fp_options.margin_derived_from_code%TYPE;
l_labor_hours_from_code     pa_proj_fp_options.report_labor_hrs_from_code%TYPE;
l_cost_time_phase_code      pa_proj_fp_options.all_time_phased_code%TYPE;
l_rev_time_phase_code       pa_proj_fp_options.all_time_phased_code%TYPE;

l_user_bv_flag              VARCHAR2(1);
l_is_cost_locked_by_user    VARCHAR2(1);
l_cost_locked_by_person_id  NUMBER;
l_is_rev_locked_by_user     VARCHAR2(1);
l_rev_locked_by_person_id   NUMBER;

-- local variables for calling Pa_Prj_Period_Profile_Utils.Get_Prj_Period_Profile_Dtls
l_period_profile_id     NUMBER;
l_period_profile_type   VARCHAR2(80);
l_plan_period_type      VARCHAR2(80);
l_period_set_name       VARCHAR2(80);
l_gl_period_type        VARCHAR2(30);
l_plan_start_date       DATE;
l_plan_end_date         DATE;
l_number_of_periods     NUMBER;

-- local variables for calling Pa_Prj_Period_Profile_Utils procedures
l_cur_period_profile_id     pa_proj_period_profiles.period_profile_id%TYPE;
l_cur_start_period          VARCHAR2(30);
l_cur_end_period            VARCHAR2(30);
l_cur_period_number         NUMBER;
l_cur_period_name           VARCHAR2(100);
l_cur_period_start_date     DATE;
l_cur_period_end_date       DATE;

-- other variables for Period Profile info
l_plan_processing_code      pa_budget_versions.plan_processing_code%TYPE;
l_plan_processing_code2     pa_budget_versions.plan_processing_code%TYPE;
l_request_id                pa_budget_versions.request_id%TYPE;

-- variables for default settings
l_plan_pref_code        pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_cost_amount_set_id    pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
l_rev_amount_set_id     pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE; --for costandrevsep
l_all_amount_set_id     pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE; --for costandrevtog
l_version_type          pa_budget_versions.version_type%TYPE;
l_display_quantity      VARCHAR2(1);
l_display_rawcost       VARCHAR2(1);
l_display_burdcost      VARCHAR2(1);
l_display_revenue       VARCHAR2(1);
l_display_margin        VARCHAR2(1);
l_display_marginpct     VARCHAR2(1);

-- uncategorized list info
l_uncat_resource_list_id    pa_resource_lists.resource_list_id%TYPE;
l_uncat_rlm_id              pa_resource_assignments.resource_list_member_id%TYPE;
l_track_as_labor_flag       pa_resources.track_as_labor_flag%TYPE;
l_unit_of_measure           pa_resource_assignments.unit_of_measure%TYPE;

-- Bug 8463760
l_uncategorized_flag        pa_resource_lists_all_bg.uncategorized_flag%TYPE;

BEGIN
  --hr_utility.trace_on(null, 'dlai');
  --hr_utility.trace('STARTING');
  x_return_status    := FND_API.G_RET_STS_SUCCESS;
--  x_primary_pp_bv_id := p_orgfcst_version_id;
  pa_fp_view_plans_pub.G_FP_VIEW_VERSION_ID := p_orgfcst_version_id;
  pa_fp_view_plans_pub.G_AMT_OR_PD := p_amt_or_pd; -- this will be used by other procedures

  -- populate G_UNCAT_RLM_ID: the uncategorized resource list member id
  pa_fin_plan_utils.Get_Uncat_Resource_List_Info
         (x_resource_list_id        => l_uncat_resource_list_id
         ,x_resource_list_member_id => l_uncat_rlm_id
         ,x_track_as_labor_flag     => l_track_as_labor_flag
         ,x_unit_of_measure         => l_unit_of_measure
         ,x_return_status           => l_return_status
         ,x_msg_count               => l_msg_count
         ,x_msg_data                => l_msg_data);
  pa_fp_view_plans_pub.G_UNCAT_RLM_ID := l_uncat_rlm_id;
  x_uncat_rlmid := l_uncat_rlm_id;
--hr_utility.trace('Uncategorized Resource List Member Id is ' || to_char(l_uncat_rlm_id));
--hr_utility.trace('Amt/Period toggle is ' || pa_fp_view_plans_pub.G_AMT_OR_PD);
        select bv.project_id,
	       DECODE(p_view_currency_type,
		     'PROJ', pa.project_currency_code,
		     'PROJFUNC', pa.projfunc_currency_code,
		     'TXN')
         into  l_project_id,
	       l_projfunc_currency_code
         from  pa_budget_versions bv,
	       pa_projects_all pa
        where  bv.budget_version_id = p_orgfcst_version_id and
	       bv.project_id = pa.project_id;
       select nvl(org_id,-99)
         into l_org_id
         from pa_projects_all
         where project_id = l_project_id;
       pa_fp_view_plans_pub.G_FP_ORG_ID := l_org_id;
       x_view_currency_code := l_projfunc_currency_code;	-- OUTPUT: x_view_currency_code

  -- bug 3146974 GET AUTO BASELINED FLAG
  x_auto_baselined_flag :=
           Pa_Fp_Control_Items_Utils.IsFpAutoBaselineEnabled(l_project_id); -- OUTPUT: x_auto_baselined_flag

  BEGIN
        select fin_plan_start_date, fin_plan_end_date, fin_plan_type_id
--	       default_amount_type_code,
--	       default_amount_subtype_code
         into  ll_plan_start_date,ll_plan_end_date, l_fin_plan_type_id
--	       l_default_amount_type_code,
--	       l_default_amount_subtype_code
         from  pa_proj_fp_options
        where  fin_plan_version_id = p_orgfcst_version_id;

	-- PLAN CLASS CODE (for Plan Class Security: FPL)
 	x_plan_class_code :=  pa_fin_plan_type_global.plantype_to_planclass
		(l_project_id, l_fin_plan_type_id);

	-- DERIVE MARGIN FROM CODE: get from PLAN TYPE entry
	select proj_fp_options_id,
	       margin_derived_from_code,
	       report_labor_hrs_from_code
	  into x_plan_fp_options_id,				-- OUTPUT: x_plan_fp_options_id
	       l_margin_derived_from_code,
	       l_labor_hours_from_code
	  from pa_proj_fp_options
	  where project_id = l_project_id and
		fin_plan_type_id = l_fin_plan_type_id and
		fin_plan_option_level_code='PLAN_TYPE';
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
      --hr_utility.trace('no_data_found 1');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg
	( p_pkg_name         => 'PA_FP_VIEW_PLANS_PUB',
          p_procedure_name   => 'pa_fp_viewplan_hgrid_init:plan start/end dates: 100');
  END;
  --hr_utility.trace('stage 100 passed');
  x_plan_type_id := l_fin_plan_type_id;				-- OUTPUT: x_plan_type_id
  pa_fp_view_plans_pub.G_FP_CALC_MARGIN_FROM := l_margin_derived_from_code;
  x_calc_margin_from := l_margin_derived_from_code;		-- OUTPUT: x_calc_margin_from
  pa_fp_view_plans_pub.G_FP_CALC_QUANTITY_FROM := l_labor_hours_from_code;
  x_labor_hrs_from_code := l_labor_hours_from_code;		-- OUTPUT: x_labor_hrs_from_code

-- ===== ASSUMPTIONS ===== --
-- 1. p_orgfcst_version_id will ALWAYS be populated (if the user selected version(s),
--      then p_orgfcst_version_id will be the id for one of the selected versions)
-- 2. If user selected a single version where cost and revenue planned together,
--      p_user_cost_version_id and p_user_rev_version_id will have the same id
-- ======================= --

-- USER CUSTOMIZATIONS (ADVANCED DISPLAY OPTIONS PAGE)
-- see if we are displaying data from user-selected version
	if (p_user_cost_version_id is not null) or (p_user_rev_version_id is not null) then
	  l_user_bv_flag := 'Y';
	else
	  l_user_bv_flag := 'N';
	end if;

-- set the display from flags
	if l_user_bv_flag = 'Y' then
 	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_QUANTITY := px_display_quantity;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_RAWCOST := px_display_rawcost;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_BURDCOST := px_display_burdcost;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_REVENUE := px_display_revenue;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGIN := px_display_margin;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGINPCT := px_display_marginpct;
--	  x_factor_by_code := null;
	  x_factor_by_code := 1; --doesn't matter: we should've gotten it in the URL
	else
	  -- retrieve default settings
	  select po.cost_amount_set_id,
		 po.revenue_amount_set_id,
		 po.all_amount_set_id,
		 bv.version_type,
--		 po.factor_by_code,
		 po.fin_plan_preference_code
	    into l_cost_amount_set_id,
		 l_rev_amount_set_id,
		 l_all_amount_set_id,
		 l_version_type,
--		 x_factor_by_code,
		 l_plan_pref_code
	    from pa_budget_versions bv,
		 pa_proj_fp_options po
	    where bv.budget_version_id = p_orgfcst_version_id and
		  bv.fin_plan_type_id = po.fin_plan_type_id and
		  po.project_id = l_project_id and
		  po.fin_plan_option_level_code = 'PLAN_TYPE';
	-- *** retrieve FACTOR_BY_CODE from PROJECT-LEVEL ROW (bug 2638873) ***
	-- *** 01/30/03: 2778424 - If PROJECT-LEVEL row does not exist, return 1
        BEGIN
	    select nvl(po.factor_by_code, 1)
	      into x_factor_by_code			-- OUTPUT: x_factor_by_code
	      from pa_proj_fp_options po
	    where po.project_id = l_project_id and
		  po.fin_plan_option_level_code = 'PROJECT';
	EXCEPTION WHEN NO_DATA_FOUND THEN
               x_factor_by_code := 1;
	END;

	  -- QUERY FLAGS FROM AMOUNT SETS, DEPENDING ON FIN PLAN PREF CODE
	  if l_plan_pref_code = 'COST_ONLY' then
	    select nvl(cost_qty_flag,'N'),
		   nvl(raw_cost_flag, 'N'),
		   nvl(burdened_cost_flag, 'N'),
		   nvl(revenue_flag, 'N'),
		   'N',
		   'N'
	      into l_display_quantity,
	  	   l_display_rawcost,
	  	   l_display_burdcost,
	  	   l_display_revenue,
	  	   l_display_margin,
	  	   l_display_marginpct
	      from pa_fin_plan_amount_sets
	      where fin_plan_amount_set_id = l_cost_amount_set_id;

	  elsif l_plan_pref_code = 'REVENUE_ONLY' then
	    select nvl(revenue_qty_flag, 'N'),
		   nvl(raw_cost_flag, 'N'),
		   nvl(burdened_cost_flag, 'N'),
		   nvl(revenue_flag, 'N'),
		   'N',
		   'N'
	      into l_display_quantity,
	  	   l_display_rawcost,
	  	   l_display_burdcost,
	  	   l_display_revenue,
	  	   l_display_margin,
	  	   l_display_marginpct
	      from pa_fin_plan_amount_sets
	      where fin_plan_amount_set_id = l_rev_amount_set_id;

	  elsif l_plan_pref_code = 'COST_AND_REV_SAME' then
	    select nvl(all_qty_flag, 'N'),
		   nvl(raw_cost_flag, 'N'),
		   nvl(burdened_cost_flag, 'N'),
		   nvl(revenue_flag, 'N'),
		   'Y',
		   'Y'
	      into l_display_quantity,
	  	   l_display_rawcost,
	  	   l_display_burdcost,
	  	   l_display_revenue,
	  	   l_display_margin,
	  	   l_display_marginpct
	      from pa_fin_plan_amount_sets
	      where fin_plan_amount_set_id = l_all_amount_set_id;

	  else
	    select DECODE(cost_as.cost_qty_flag,
			  'Y', 'Y',
			  DECODE(rev_as.revenue_qty_flag,
				 'Y', 'Y',
				 'N')),
		   nvl(cost_as.raw_cost_flag, 'N'),
		   nvl(cost_as.burdened_cost_flag, 'N'),
		   nvl(rev_as.revenue_flag, 'N'),
		   'Y',
		   'Y'
	      into l_display_quantity,
	  	   l_display_rawcost,
	  	   l_display_burdcost,
	  	   l_display_revenue,
	  	   l_display_margin,
	  	   l_display_marginpct
	      from pa_fin_plan_amount_sets cost_as,
		   pa_fin_plan_amount_sets rev_as
	      where cost_as.fin_plan_amount_set_id = l_cost_amount_set_id and
		    rev_as.fin_plan_amount_set_id = l_rev_amount_set_id;
	  end if;

 	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_QUANTITY := l_display_quantity;
	  px_display_quantity := l_display_quantity;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_RAWCOST := l_display_rawcost;
	  px_display_rawcost := l_display_rawcost;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_BURDCOST := l_display_burdcost;
	  px_display_burdcost := l_display_burdcost;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_REVENUE := l_display_revenue;
	  px_display_revenue := l_display_revenue;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGIN := l_display_margin;
	  px_display_margin := l_display_margin;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGINPCT := l_display_marginpct;
	  px_display_marginpct := l_display_marginpct;
	end if;
--hr_utility.trace('quantityflag= ' || pa_fp_view_plans_pub.G_DISPLAY_FLAG_QUANTITY);
--hr_utility.trace('rawcostflag= ' || pa_fp_view_plans_pub.G_DISPLAY_FLAG_RAWCOST);
--hr_utility.trace('burdenedcostflag= ' || pa_fp_view_plans_pub.G_DISPLAY_FLAG_BURDCOST);
--hr_utility.trace('revenueflag= ' || pa_fp_view_plans_pub.G_DISPLAY_FLAG_REVENUE);
--hr_utility.trace('marginflag= ' || pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGIN);
--hr_utility.trace('marginpctflag= ' || pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGINPCT);

-- set the DEFAULT AMOUNT TYPE/SUBTYPE CODES, based on order of hierarchy
	if pa_fp_view_plans_pub.G_DISPLAY_FLAG_QUANTITY = 'Y' then
	  l_default_amount_type_code := 'QUANTITY';
	  l_default_amount_subtype_code := 'QUANTITY';
	elsif pa_fp_view_plans_pub.G_DISPLAY_FLAG_RAWCOST = 'Y' then
	  l_default_amount_type_code := 'COST';
	  l_default_amount_subtype_code := 'RAW_COST';
	elsif pa_fp_view_plans_pub.G_DISPLAY_FLAG_BURDCOST = 'Y' then
	  l_default_amount_type_code := 'COST';
	  l_default_amount_subtype_code := 'BURDENED_COST';
	elsif pa_fp_view_plans_pub.G_DISPLAY_FLAG_REVENUE = 'Y' then
	  l_default_amount_type_code := 'REVENUE';
	  l_default_amount_subtype_code := 'REVENUE';
	elsif pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGIN = 'Y' then
	  l_default_amount_type_code := 'MARGIN';
	  l_default_amount_subtype_code := 'MARGIN';
	else
	  l_default_amount_type_code := 'MARGIN_PERCENT';
	  l_default_amount_subtype_code := 'MARGIN_PERCENT';
	end if; -- set default amount type codes

-- set the user-defined budget versions source
	if l_user_bv_flag = 'Y' then
	  if (p_user_cost_version_id = p_user_rev_version_id) then
	    pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID := p_user_cost_version_id;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := p_user_cost_version_id;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_ID := p_user_rev_version_id;
	  else
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := p_user_cost_version_id;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_ID := p_user_rev_version_id;
	  end if;
	  select approved_rev_plan_type_flag
	    into x_ar_flag					-- OUTPUT: x_ar_flag
	    from pa_proj_fp_options
	    where project_id = l_project_id and
		  fin_plan_type_id = l_fin_plan_type_id and
		  fin_plan_option_level_code='PLAN_TYPE';

	else
           -- retrieve l_cost_or_revenue: applicable only for COST_AND_REV_SEP
           -- this param is passed to populate_tmp_table
           -- this param is useful only if the user did not select budget versions
           select DECODE(version_type,
       		         'REVENUE', 'R',
		         'COST', 'C',
		         null),
	          nvl(approved_rev_plan_type_flag, 'N')
	     into l_cost_or_revenue,
	          x_ar_flag					-- OUTPUT: x_ar_flag
	     from pa_budget_versions
	     where budget_version_id = p_orgfcst_version_id;
	end if;
-- END OF USER CUSTOMIZATIONS (ADVANCED DISPLAY OPTIONS)
	pa_fp_view_plans_pub.G_DEFAULT_AMOUNT_TYPE_CODE := l_default_amount_type_code;
	pa_fp_view_plans_pub.G_DEFAULT_AMT_SUBTYPE_CODE := l_default_amount_subtype_code;
	x_def_amt_subt_code := l_default_amount_subtype_code;   -- OUTPUT: x_def_amt_subt_code
	pa_fp_view_plans_pub.G_FP_CURRENCY_CODE := l_projfunc_currency_code;
	pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE := p_view_currency_type;
  --hr_utility.trace('reached end of user customizations section: 200');


-- SETTING PERIOD INFORMATION --
-- ONLY IF IN PERIODIC MODE --

  if p_amt_or_pd = 'P' then
    BEGIN
/* Commented for bug 7514054
        select pp.plan_period_type,
	       pp.period1_start_date,
	       pp.period_profile_id
        into   ll_plan_period_type,
	       pp_plan_start_date,
	       l_period_profile_id
        from   pa_proj_period_profiles pp,
               pa_budget_versions pbv
        where  pbv.budget_version_id = p_orgfcst_version_id
         and   pbv.period_profile_id = pp.period_profile_id;
      Ends commented for 7514054 and added below code
*/
      select min(start_date) into pp_plan_start_date from
    pa_budget_lines
    where budget_version_id = p_orgfcst_version_id;

	  select decode(nvl(cost_time_phased_code,
	  nvl(revenue_time_phased_code, all_time_phased_code)), 'G', 'GL', 'P', 'PA', 'N')
	  into ll_plan_period_type					-- OUTPUT: ll_plan_period_type
	    from pa_proj_fp_options
	    where project_id = l_project_id and
		  fin_plan_type_id = l_fin_plan_type_id and
		  fin_plan_option_level_code='PLAN_TYPE';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg
	( p_pkg_name         => 'PA_FP_VIEW_PLANS_PUB',
          p_procedure_name   => 'pa_fp_viewplan_hgrid_init:plan period type: 300');
    END;
    --hr_utility.trace('after selecting from pa_proj_period_profiles: 300 succeeded');

	-- get period info based on period_profile_id
	/* Starts Commented for bug 7456425
	  Pa_Prj_Period_Profile_Utils.Get_Prj_Period_Profile_Dtls(
                          p_period_profile_id   => l_period_profile_id,
                          p_debug_mode          => 'Y',
                          p_add_msg_in_stack    => 'Y',
                          x_period_profile_type => l_period_profile_type,
                          x_plan_period_type    => l_plan_period_type,
                          x_period_set_name     => l_period_set_name,
                          x_gl_period_type      => l_gl_period_type,
                          x_plan_start_date     => l_plan_start_date,
                          x_plan_end_date       => l_plan_end_date,
                          x_number_of_periods   => l_number_of_periods,
                          x_return_status       => l_return_status,
                          x_msg_data            => l_msg_data);
	-- get current period info
--hr_utility.trace('executed get_prj_Period_profile_dtls');
--hr_utility.trace('l_period_profile_type= ' || l_period_profile_type);
--hr_utility.trace('l_plan_period_type= ' || l_plan_period_type);
	  Pa_Prj_Period_Profile_Utils.Get_Curr_Period_Profile_Info(
              p_project_id          => l_project_id
             ,p_period_type         => l_plan_period_type
             ,p_period_profile_type => 'FINANCIAL_PLANNING'
             ,x_period_profile_id   => l_cur_period_profile_id
             ,x_start_period        => l_cur_start_period
             ,x_end_period          => l_cur_end_period
             ,x_return_status       => l_return_status
             ,x_msg_count           => l_msg_count
             ,x_msg_data            => l_msg_data);
--hr_utility.trace('executed get_curr_period_profile_info');
--hr_utility.trace('l_plan_period_type= ' || l_plan_period_type);
--hr_utility.trace('l_cur_period_profile_id= ' || l_cur_period_profile_id);
--hr_utility.trace('l_cur_start_period= ' || l_cur_start_period);
--hr_utility.trace('l_cur_end_period= ' || l_cur_end_period);

	if l_period_profile_id = l_cur_period_profile_id then
	  x_old_pd_profile_flag := 'N';				-- OUTPUT: x_old_pd_profile_flag
	else
	  x_old_pd_profile_flag := 'Y';
	end if;
	Ends commented for 7456425*/

--	if ll_plan_start_date is null or ll_plan_end_date is null then
	  ll_plan_start_date := l_plan_start_date;
	  ll_plan_end_date := l_plan_end_date;
--	end if;

/* Starts - Added for bug 7456425 */

	-- Bug 8463770
  /*
	select min(start_date), max(end_date)
	into ll_plan_start_date, ll_plan_end_date
	from pa_budget_lines
	where resource_assignment_id in (select
	resource_assignment_id from
	pa_budget_versions where budget_version_id  = p_orgfcst_version_id);
  */

	select min(start_date), max(end_date)
	into ll_plan_start_date, ll_plan_end_date
	from pa_budget_lines
	where budget_version_id = p_orgfcst_version_id;
  -- Bug 8463770

/* Ends- Added for bug 7456425 */

	pa_fp_view_plans_pub.G_FP_PLAN_START_DATE := ll_plan_start_date;
	pa_fp_view_plans_pub.G_FP_PLAN_END_DATE := ll_plan_end_date;
	pa_fp_view_plans_pub.G_FP_PERIOD_TYPE := ll_plan_period_type;
	x_plan_period_type := ll_plan_period_type;		-- OUTPUT: x_plan_period_type
        if ll_plan_period_type = 'GL' THEN
          l_num_of_periods := 6;
        else
          l_num_of_periods := 13;
        end if;
/* Starts commented for 7456425
	  -- get current period profile info
	  Pa_Prj_Period_Profile_Utils.get_current_period_info
	    (p_period_profile_id        => l_period_profile_id,
	     x_cur_period_number        => l_cur_period_number,
	     x_cur_period_name          => l_cur_period_name,
	     x_cur_period_start_date    => l_cur_period_start_date,
	     x_cur_period_end_date      => l_cur_period_end_date,
	     x_return_status            => l_return_status,
	     x_msg_count                => l_msg_count,
	     x_msg_data                 => l_msg_data);

Ends Commented for 7456425 */

	  if l_cur_period_number = -2 then
	    x_in_period_profile := 'B'; -- for 'before period profile'
	  elsif l_cur_period_number = -1 then
	    x_in_period_profile := 'A'; -- for 'after period profile'
	  else
	    x_in_period_profile := 'C';
	  end if;


	if p_period_start_date = 'N' Then
          l_start_date :=  to_char(ll_plan_start_date);
	  -- 11/7/2002: IF no value retrieved from fin_plan_start_date, then use the first start
	  --	      date according to the period profile id
	  if l_start_date is null then
	    l_start_date := to_char(pp_plan_start_date);
	  end if;
	elsif p_period_start_date = 'L' Then
          pa_fp_view_plans_pub.G_FP_VIEW_START_DATE1:=ll_plan_end_date;
          pa_fp_view_plans_pub.pa_fp_set_periods_nav (
                                  p_direction      => 'BACKWARD',
                                  p_num_of_periods => l_num_of_periods,
                                  p_period_type    => ll_plan_period_type,
                                  x_start_date     => l_start_date,
                                  x_return_status  => l_return_status,
                                  x_msg_count      => l_msg_count,
                                  x_msg_data       => l_msg_data);
	elsif p_period_start_date = 'C' then
	  -- if sysdate falls before first period start date, start from beginning
	  if l_cur_period_number = -2 then
	    l_start_date := to_char(ll_plan_start_date);
	    if l_start_date is null then
		l_start_date := to_char(pp_plan_start_date);
	    end if;
	  -- if sysdate falls after last period end date, display the ending periods
	  elsif l_cur_period_number = -1 then
            pa_fp_view_plans_pub.G_FP_VIEW_START_DATE1:=ll_plan_end_date;
            pa_fp_view_plans_pub.pa_fp_set_periods_nav (
                                  p_direction      => 'BACKWARD',
                                  p_num_of_periods => l_num_of_periods,
                                  p_period_type    => ll_plan_period_type,
                                  x_start_date     => l_start_date,
                                  x_return_status  => l_return_status,
                                  x_msg_count      => l_msg_count,
                                  x_msg_data       => l_msg_data);

	  else
	    l_start_date := to_char(l_cur_period_start_date);
	  end if;

        else
          l_start_date := p_period_start_date;
        end if;

        pa_fp_view_plans_pub.pa_fp_set_periods
		( p_period_start_date => l_start_date,
                  p_period_type       => ll_plan_period_type,
                  x_return_status     => l_return_status,
                  x_msg_count         => l_msg_count,
                  x_msg_data          => l_msg_data);

  --hr_utility.trace('END OF SETTING PERIOD INFORMATION: 400');

  end if; -- check p_amt_or_pd flag
-- END OF SETTING PERIOD INFORMATION --


-- POPULATE THE GLOBAL TEMPORARY TABLE --
-- we expect the following to be done after this procedure:
-- 1. global variables should be set:
-- 	G_DISPLAY_FROM
--	G_FP_COST_VERSION_ID (may be set already, if user-entered)
--	G_FP_COST_VERSION_NUMBER
--	G_FP_COST_VERSION_NAME
--	G_FP_REV_VERSION_ID (may be set already, if user-entered)
--	G_FP_REV_VERSION_NAME
--	G_FP_REV_VERSION_NUMBER
--	G_FP_ALL_VERSION_ID (may be set already, if user-entered)
--	G_FP_ALL_VERSION_NAME
--	G_FP_ALL_VERSION_NUMBER
--hr_utility.trace('calling view_plan_temp_tables');
	-- delete residual data in the temp tables
	DELETE from PA_FIN_VP_AMTS_VIEW_TMP;
	DELETE from PA_FIN_VP_PDS_VIEW_TMP;
	pa_fp_view_plans_pub.view_plan_temp_tables
    		(p_project_id		=> l_project_id,
     		 p_budget_version_id	=> p_orgfcst_version_id,
     		 p_cost_or_revenue	=> l_cost_or_revenue,
		 p_user_bv_flag		=> l_user_bv_flag,
     		 x_cost_version_number	=> l_cost_version_number,
     		 x_rev_version_number	=> l_rev_version_number,
     		 x_cost_version_name	=> l_cost_version_name,
     		 x_rev_version_name	=> l_rev_version_name,
		 x_diff_pd_profile_flag => l_diff_pd_profile_flag,
     		 x_return_status	=> l_return_status,
     		 x_msg_count		=> l_msg_count,
     		 x_msg_data		=> l_msg_data );
	-- if view_plan_temp_tables fails, error out right away
	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    x_msg_count := FND_MSG_PUB.Count_Msg;
	    if x_msg_count = 1 then
      		PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_msg_data,
                      p_msg_index_out  => l_msg_index_out);
	    end if;
	    return;
	end if;

	--Start Bug 8463760
	-- For uncategorized resource lists there is no need to store data against the resource list member ids coz
	-- they are dummy ids for internal tracking and this is causing showing of data in twice at lowest level.
	SELECT NVL(rl.uncategorized_flag, 'N')
	INTO l_uncategorized_flag
	FROM pa_budget_versions bv,
       pa_resource_lists_all_bg rl
  WHERE bv.budget_version_id = p_orgfcst_version_id AND
        bv.resource_list_id = rl.resource_list_id;


  IF l_uncategorized_flag = 'Y' THEN
  	DELETE FROM pa_fin_vp_amts_view_tmp
  	WHERE project_id=l_project_id	AND
  	      resource_list_member_id > 0;

  	DELETE FROM pa_fin_vp_pds_view_tmp tmp1
  	WHERE tmp1.project_id=l_project_id	AND
  	      tmp1.resource_list_member_id = 0
  	      and exists (select 1 from pa_fin_vp_pds_view_tmp tmp2
  	                  where tmp2.task_id=tmp1.task_id
  	                  and   tmp2.resource_list_member_id>0);
  END IF;
  --End Bug 8463760

--hr_utility.trace('after calling view_plan_temp_tables: 500');
-- END OF POPULATING GLOBAL TEMPORARY TABLE --

  x_display_from := pa_fp_view_plans_pub.G_DISPLAY_FROM;	-- OUTPUT: x_display_from
  x_diff_pd_profile_flag := l_diff_pd_profile_flag;		-- OUTPUT: x_diff_pd_profile_flag
  -- NEED THIS IN CASE NOT USER-SPECIFIED
  if pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID is not null then
    if pa_fp_view_plans_pub.G_FP_COST_VERSION_ID is null then
      pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID;
    end if;
    if pa_fp_view_plans_pub.G_FP_REV_VERSION_ID is null then
      pa_fp_view_plans_pub.G_FP_REV_VERSION_ID := pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID;
    end if;
  end if;

-- figure out x_time_phase_code: to decide whether or not to display the amt/pd toggle
-- also, set x_refresh_pd_flag and x_refresh_req_id
-- also set preceding/succeeding periods flags
  if pa_fp_view_plans_pub.G_DISPLAY_FROM = 'ANY' then
	select nvl(all_time_phased_code, 'N')
	  into x_time_phase_code				-- OUTPUT: x_time_phase_code
	  from pa_proj_fp_options
	  where fin_plan_version_id = pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID;
	x_prec_pds_flag := Pa_Prj_Period_Profile_Utils.has_preceding_periods
	  	(pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID);
	x_succ_pds_flag := Pa_Prj_Period_Profile_Utils.has_succeeding_periods
	  	(pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID);
	select plan_processing_code,
	       request_id
	  into l_plan_processing_code,
	       l_request_id
	  from pa_budget_versions
	  where budget_version_id = pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID;
	if l_plan_processing_code = 'PPP' then
	  x_refresh_pd_flag := 'Y';				-- OUTPUT: x_refresh_pd_flag
	  x_refresh_req_id := l_request_id;			-- OUTPUT: x_refresh_req_id
	else
	  x_refresh_pd_flag := 'N';				-- OUTPUT: x_refresh_pd_flag
	  x_refresh_req_id := -1;				-- OUTPUT: x_refresh_req_id
	end if;
  elsif pa_fp_view_plans_pub.G_DISPLAY_FROM = 'COST' then
	select nvl(cost_time_phased_code, 'N')
	  into x_time_phase_code				-- OUTPUT: x_time_phase_code
	  from pa_proj_fp_options
	  where fin_plan_version_id = pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
	x_prec_pds_flag := Pa_Prj_Period_Profile_Utils.has_preceding_periods
	  	(pa_fp_view_plans_pub.G_FP_COST_VERSION_ID);
	x_succ_pds_flag := Pa_Prj_Period_Profile_Utils.has_succeeding_periods
	  	(pa_fp_view_plans_pub.G_FP_COST_VERSION_ID);
	select plan_processing_code,
	       request_id
	  into l_plan_processing_code,
	       l_request_id
	  from pa_budget_versions
	  where budget_version_id = pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
	if l_plan_processing_code = 'PPP' then
	  x_refresh_pd_flag := 'Y';				-- OUTPUT: x_refresh_pd_flag
	  x_refresh_req_id := l_request_id;			-- OUTPUT: x_refresh_req_id
	else
	  x_refresh_pd_flag := 'N';				-- OUTPUT: x_refresh_pd_flag
	  x_refresh_req_id := -1;				-- OUTPUT: x_refresh_req_id
	end if;
  elsif pa_fp_view_plans_pub.G_DISPLAY_FROM = 'REVENUE' then
	select nvl(revenue_time_phased_code, 'N')
	  into x_time_phase_code				-- OUTPUT: x_time_phase_code
	  from pa_proj_fp_options
	  where fin_plan_version_id = pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
	x_prec_pds_flag := Pa_Prj_Period_Profile_Utils.has_preceding_periods
	  	(pa_fp_view_plans_pub.G_FP_REV_VERSION_ID);
	x_succ_pds_flag := Pa_Prj_Period_Profile_Utils.has_succeeding_periods
	  	(pa_fp_view_plans_pub.G_FP_REV_VERSION_ID);
	select plan_processing_code,
	       request_id
	  into l_plan_processing_code,
	       l_request_id
	  from pa_budget_versions
	  where budget_version_id = pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
	if l_plan_processing_code = 'PPP' then
	  x_refresh_pd_flag := 'Y';				-- OUTPUT: x_refresh_pd_flag
	  x_refresh_req_id := l_request_id;			-- OUTPUT: x_refresh_req_id
	else
	  x_refresh_pd_flag := 'N';				-- OUTPUT: x_refresh_pd_flag
	  x_refresh_req_id := -1;				-- OUTPUT: x_refresh_req_id
	end if;
  else
	select nvl(cost_time_phased_code, 'N')
	  into l_cost_time_phase_code
	  from pa_proj_fp_options
	  where fin_plan_version_id = pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
	select nvl(revenue_time_phased_code, 'N')
	  into l_rev_time_phase_code
	  from pa_proj_fp_options
	  where fin_plan_version_id = pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
	-- if cost and rev versions have different time phase codes, there is no way to
	-- merge them in periodic view
	if l_cost_time_phase_code <> l_rev_time_phase_code then
	  x_time_phase_code := 'N';				-- OUTPUT: x_time_phase_code
	else
	  x_time_phase_code := l_cost_time_phase_code;		-- OUTPUT: x_time_phase_code
	end if;

/*
	-- **** if have TWO versions, may need to set x_primary_pp_bv_id ****
	--      if p_orgfcst_version_id does not have a period_profile_id
	if (x_time_phase_code <> 'N') and
	   (pa_fp_view_plans_util.has_period_profile_id(p_orgfcst_version_id) = 'N') then
	  if pa_fp_view_plans_util.has_period_profile_id(pa_fp_view_plans_pub.G_FP_COST_VERSION_ID) = 'Y' then
	    x_primary_pp_bv_id := pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
	  elsif pa_fp_view_plans_util.has_period_profile_id(pa_fp_view_plans_pub.G_FP_REV_VERSION_ID) = 'Y' then
	    x_primary_pp_bv_id := pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
	  end if;
	end if;
*/
	if   Pa_Prj_Period_Profile_Utils.has_preceding_periods
	   	(pa_fp_view_plans_pub.G_FP_COST_VERSION_ID) = 'Y' or
	     Pa_Prj_Period_Profile_Utils.has_preceding_periods
	  	(pa_fp_view_plans_pub.G_FP_REV_VERSION_ID) = 'Y' then
          x_prec_pds_flag := 'Y';
	else
	  x_prec_pds_flag := 'N';
	end if;
	if   Pa_Prj_Period_Profile_Utils.has_succeeding_periods
	    	(pa_fp_view_plans_pub.G_FP_COST_VERSION_ID) = 'Y' or
	     Pa_Prj_Period_Profile_Utils.has_succeeding_periods
	  	(pa_fp_view_plans_pub.G_FP_REV_VERSION_ID) = 'Y' then
	  x_succ_pds_flag := 'Y';
	else
	  x_succ_pds_flag := 'N';
	end if;
	x_refresh_req_id := -1;
	select plan_processing_code,
	       request_id
	  into l_plan_processing_code,
	       l_request_id
	  from pa_budget_versions
	  where budget_version_id = pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
	if l_request_id is not null then
	  x_refresh_req_id := l_request_id;
	end if;
	select plan_processing_code,
	       request_id
	  into l_plan_processing_code2,
	       l_request_id
	  from pa_budget_versions
	  where budget_version_id = pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
	if l_request_id is not null then
	  x_refresh_req_id := l_request_id;
	end if;
	if (l_plan_processing_code = 'PPP') or (l_plan_processing_code2 = 'PPP') then
	  x_refresh_pd_flag := 'Y';
	else
	  x_refresh_pd_flag := 'N';
	end if;
  end if;
  -- PRECEDING/SUCCEEDING PERIODS:
  -- if we are not displaying the first period in profile, hide preceding periods
  -- if we are not displaying the last period in profile, hide succeeding periods
  if p_amt_or_pd = 'P' then
    if pa_fp_view_plans_pub.G_FP_VIEW_START_DATE1 <> pa_fp_view_plans_pub.G_FP_PLAN_START_DATE then
	x_prec_pds_flag := 'N';
    end if;
    if pa_fp_view_plans_pub.G_FP_PERIOD_TYPE = 'GL' then
	if pa_fp_view_plans_pub.G_FP_VIEW_END_DATE6 < pa_fp_view_plans_pub.G_FP_PLAN_END_DATE then
	      x_succ_pds_flag := 'N';
	end if;
    else
	if pa_fp_view_plans_pub.G_FP_VIEW_END_DATE13 < pa_fp_view_plans_pub.G_FP_PLAN_END_DATE then
	      x_succ_pds_flag := 'N';
	end if;
    end if;
  end if;
  -- -----> BEGIN bug fix 2821568 <-----
  pa_fp_view_plans_pub.G_DISPLAY_FLAG_PREC := x_prec_pds_flag;
  pa_fp_view_plans_pub.G_DISPLAY_FLAG_SUCC := x_succ_pds_flag;
  -- -----> END bug fix 2821568   <-----

-- ----> BEGIN bug fix 2812381 <----
  if pa_fp_view_plans_pub.G_DISPLAY_FROM = 'ANY' then
    x_cost_bv_id := pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID;
    x_revenue_bv_id := pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID;
  elsif pa_fp_view_plans_pub.G_DISPLAY_FROM = 'COST' then
    x_cost_bv_id := pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
    x_revenue_bv_id := -1;
  elsif pa_fp_view_plans_pub.G_DISPLAY_FROM = 'REVENUE' then
    x_cost_bv_id := -1;
    x_revenue_bv_id := pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
  else
    x_cost_bv_id := pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
    x_revenue_bv_id := pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
  end if;
/*
  x_cost_bv_id := pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
  if x_cost_bv_id is null then
	if pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID is null then
	  x_cost_bv_id := -1;
	else
	  x_cost_bv_id := pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID;
	end if;
  end if;
  x_revenue_bv_id := pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
  if x_revenue_bv_id is null then
	if pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID is null then
	  x_revenue_bv_id := -1;
	else
	  x_revenue_bv_id := pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID;
	end if;
  end if;
*/
-- ----> END bug fix 2812381 <----

-- figure out LOCKED BY after version sources set; also get RECORD VERSION NUMBERS
    -- COST VERSION
  if (pa_fp_view_plans_pub.G_FP_COST_VERSION_ID is not null) and
     (pa_fp_view_plans_pub.G_DISPLAY_FROM in ('COST', 'BOTH', 'ANY')) then
--hr_utility.trace('figuring out cost LOCKED BY');
    select record_version_number,				-- OUTPUT: x_cost_rv_number
	   budget_status_code					-- OUTPUT: x_cost_budget_status_code
      into x_cost_rv_number,
	   x_cost_budget_status_code
      from pa_budget_versions
--4/16/03      where budget_version_id = pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
      where budget_version_id = x_cost_bv_id;
    pa_fin_plan_utils.Check_Locked_By_User
	(p_user_id		=> p_user_id,
--4/16/03	 p_budget_version_id	=> pa_fp_view_plans_pub.G_FP_COST_VERSION_ID,
	 p_budget_version_id	=> x_cost_bv_id,
	 x_is_locked_by_userid	=> l_is_cost_locked_by_user,
	 x_locked_by_person_id	=> l_cost_locked_by_person_id,
	 x_return_status	=> l_return_status,
	 x_msg_count		=> l_msg_count,
	 x_msg_data		=> l_msg_data);
    if l_is_cost_locked_by_user = 'N' then
      if l_cost_locked_by_person_id is null then
        x_cost_locked_name := 'NONE';
      else
        x_cost_locked_name := pa_fin_plan_utils.get_person_name(l_cost_locked_by_person_id);
      end if;
    else
      x_cost_locked_name := 'SELF';
    end if; -- is_cost_locked_by_user
  end if; -- END:COST VERSION

    -- REVENUE VERSION
  if (pa_fp_view_plans_pub.G_FP_REV_VERSION_ID is not null) and
     (pa_fp_view_plans_pub.G_DISPLAY_FROM in ('REVENUE', 'BOTH', 'ANY')) then
--hr_utility.trace('figuring out revenue LOCKED BY');
    select record_version_number,				-- OUTPUT: x_rev_rv_number
	   budget_status_code					-- OUTPUT: x_rev_budget_status_code
      into x_rev_rv_number,
	   x_rev_budget_status_code
      from pa_budget_versions
--      where budget_version_id = pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
      where budget_version_id = x_revenue_bv_id;
    pa_fin_plan_utils.Check_Locked_By_User
	(p_user_id		=> p_user_id,
--	 p_budget_version_id	=> pa_fp_view_plans_pub.G_FP_REV_VERSION_ID,
	 p_budget_version_id	=> x_revenue_bv_id,
	 x_is_locked_by_userid	=> l_is_rev_locked_by_user,
	 x_locked_by_person_id	=> l_rev_locked_by_person_id,
	 x_return_status	=> l_return_status,
	 x_msg_count		=> l_msg_count,
	 x_msg_data		=> l_msg_data);
    if l_is_rev_locked_by_user = 'N' then
      if l_rev_locked_by_person_id is null then
        x_rev_locked_name := 'NONE';
      else
        x_rev_locked_name := pa_fin_plan_utils.get_person_name(l_rev_locked_by_person_id);
      end if;
    else
      x_rev_locked_name := 'SELF';
    end if; -- is_rev_locked_by_user
  end if; -- END:REVENUE VERSION


--hr_utility.trace('after calling locked version stuff');
--hr_utility.trace('G_FP_PERIOD_TYPE = ' || pa_fp_view_plans_pub.G_FP_PERIOD_TYPE);
--hr_utility.trace('G_FP_VIEW_START_DATE1 = ' || to_char(pa_fp_view_plans_pub.G_FP_VIEW_START_DATE1));
--hr_utility.trace('G_FP_VIEW_START_DATE2 = ' || to_char(pa_fp_view_plans_pub.G_FP_VIEW_START_DATE2));
--hr_utility.trace('G_FP_VIEW_START_DATE3 = ' || to_char(pa_fp_view_plans_pub.G_FP_VIEW_START_DATE3));
--hr_utility.trace('G_FP_VIEW_START_DATE4 = ' || to_char(pa_fp_view_plans_pub.G_FP_VIEW_START_DATE4));
--hr_utility.trace('G_FP_VIEW_START_DATE5 = ' || to_char(pa_fp_view_plans_pub.G_FP_VIEW_START_DATE5));
--hr_utility.trace('G_FP_VIEW_START_DATE6 = ' || to_char(pa_fp_view_plans_pub.G_FP_VIEW_START_DATE6));
--hr_utility.trace('x_cost_rv_number= ' || TO_CHAR(x_cost_rv_number));
--hr_utility.trace('x_rev_rv_number= ' || TO_CHAR(x_rev_rv_number));

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg
	( p_pkg_name         => 'PA_FP_VIEW_PLANS_PUB',
          p_procedure_name   => 'pa_fp_viewplan_hgrid_init');

END pa_fp_viewplan_hgrid_init;
/* ------------------------------------------------------------------------- */

PROCEDURE pa_fp_viewplan_hgrid_init_ci
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
    ) is

l_projfunc_currency_code PA_PROJECTS_ALL.PROJFUNC_CURRENCY_CODE%TYPE;
l_default_amount_type_code 	VARCHAR2(30);
l_default_amount_subtype_code 	VARCHAR2(30);
l_start_date DATE;
ll_plan_start_date DATE;
pp_plan_start_date DATE; -- start_date according to period profile id
ll_plan_end_date DATE;
ll_plan_period_type VARCHAR2(30);
l_diff_pd_profile_flag		VARCHAR2(1);

-- error-handling variables
l_return_status  VARCHAR2(2);
l_msg_count  NUMBER;
l_msg_data  VARCHAR2(80);
l_msg_index_out NUMBER;

l_num_of_periods NUMBER;
l_project_id NUMBER;
l_org_id NUMBER;
l_cost_or_revenue  VARCHAR2(1);
l_cost_version_number		pa_budget_versions.version_number%TYPE;
l_rev_version_number		pa_budget_versions.version_number%TYPE;
l_cost_version_name		pa_budget_versions.version_name%TYPE;
l_rev_version_name		pa_budget_versions.version_name%TYPE;
l_fin_plan_type_id		pa_budget_versions.fin_plan_type_id%TYPE;
l_margin_derived_from_code	pa_proj_fp_options.margin_derived_from_code%TYPE;
l_labor_hours_from_code		pa_proj_fp_options.report_labor_hrs_from_code%TYPE;
l_cost_time_phase_code		pa_proj_fp_options.all_time_phased_code%TYPE;
l_rev_time_phase_code		pa_proj_fp_options.all_time_phased_code%TYPE;

l_user_bv_flag			VARCHAR2(1);
l_is_cost_locked_by_user	VARCHAR2(1);
l_cost_locked_by_person_id	NUMBER;
l_is_rev_locked_by_user		VARCHAR2(1);
l_rev_locked_by_person_id	NUMBER;

-- local variables for calling Pa_Prj_Period_Profile_Utils.Get_Prj_Period_Profile_Dtls
l_period_profile_id		NUMBER;
l_period_profile_type 		VARCHAR2(80);
l_plan_period_type		VARCHAR2(80);
l_period_set_name		VARCHAR2(80);
l_gl_period_type		VARCHAR2(30);
l_plan_start_date		DATE;
l_plan_end_date			DATE;
l_number_of_periods		NUMBER;

-- local variables for calling Pa_Prj_Period_Profile_Utils.Get_Curr_Period_Profile_Info
l_cur_period_profile_id		pa_proj_period_profiles.period_profile_id%TYPE;
l_cur_start_period		VARCHAR2(30);
l_cur_end_period		VARCHAR2(30);

-- variables for default settings
l_amount_set_id			pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
l_version_type			pa_budget_versions.version_type%TYPE;
l_display_quantity		VARCHAR2(1);
l_display_rawcost		VARCHAR2(1);
l_display_burdcost		VARCHAR2(1);
l_display_revenue		VARCHAR2(1);
l_display_margin		VARCHAR2(1);
l_display_marginpct		VARCHAR2(1);

l_proj_fp_options_id   pa_proj_fp_options.proj_fp_options_id%TYPE;
l_working_or_baselined VARCHAR2(30);
l_ar_flag	       pa_budget_versions.approved_rev_plan_type_flag%TYPE;
l_ac_flag	       pa_budget_versions.approved_cost_plan_type_flag%TYPE;

cursor ci_csr is
  select bv.budget_version_id,
	 po.proj_fp_options_id,
	 NVL(po.plan_in_multi_curr_flag, 'N') as plan_in_multi_curr_flag
  from pa_budget_versions bv,
       pa_proj_fp_options po
  where bv.project_id = p_project_id and
        bv.ci_id = p_ci_id and
	bv.budget_version_id = po.fin_plan_version_id and
	po.fin_plan_option_level_code='PLAN_VERSION';
ci_rec ci_csr%ROWTYPE;

l_fp_preference_code	     pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_report_labor_hrs_from_code pa_proj_fp_options.report_labor_hrs_from_code%TYPE;
l_multi_curr_flag	     pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
l_margin_derived_code        pa_proj_fp_options.margin_derived_from_code%TYPE;
l_grouping_type              VARCHAR2(30);
l_compl_grouping_type        VARCHAR2(30);
l_cost_planning_level        pa_proj_fp_options.all_fin_plan_level_code%TYPE;
l_rev_planning_level         pa_proj_fp_options.all_fin_plan_level_code%TYPE;
l_resource_list_id           pa_budget_versions.resource_list_id%TYPE;
l_compl_resource_list_id     pa_budget_versions.resource_list_id%TYPE;
l_rv_number		     pa_budget_versions.record_version_number%TYPE;
l_compl_rv_number	     pa_budget_versions.record_version_number%TYPE;
l_uncategorized_flag	     pa_resource_lists.uncategorized_flag%TYPE;
l_compl_uncategorized_flag   pa_resource_lists.uncategorized_flag%TYPE;

l_is_cost_locked_by_user	VARCHAR2(1);
l_is_rev_locked_by_user		VARCHAR2(1);
l_cost_locked_by_person_id	NUMBER;
l_rev_locked_by_person_id	NUMBER;

l_ci_row_index			NUMBER := 0;
l_ci_budget_version_id		pa_budget_versions.budget_version_id%TYPE;

-- uncategorized list info
l_uncat_resource_list_id	pa_resource_lists.resource_list_id%TYPE;
l_uncat_rlm_id			pa_resource_assignments.resource_list_member_id%TYPE;
l_track_as_labor_flag		pa_resources.track_as_labor_flag%TYPE;
l_unit_of_measure		pa_resource_assignments.unit_of_measure%TYPE;

BEGIN
  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- GET AUTO BASELINED FLAG
  x_auto_baselined_flag :=
	Pa_Fp_Control_Items_Utils.IsFpAutoBaselineEnabled(p_project_id);

  -- populate G_UNCAT_RLM_ID: the uncategorized resource list member id
  pa_fin_plan_utils.Get_Uncat_Resource_List_Info
         (x_resource_list_id        => l_uncat_resource_list_id
         ,x_resource_list_member_id => l_uncat_rlm_id
         ,x_track_as_labor_flag     => l_track_as_labor_flag
         ,x_unit_of_measure         => l_unit_of_measure
         ,x_return_status           => l_return_status
         ,x_msg_count               => l_msg_count
         ,x_msg_data                => l_msg_data);
  pa_fp_view_plans_pub.G_UNCAT_RLM_ID := l_uncat_rlm_id;

-- FIRST, deal with all the initialization that we did in the non-Hgrid page
---------- BEGIN non-Hgrid initialization ----------

  -- GET PROJECT CURRENCY
  select projfunc_currency_code
    into x_view_currency_code
    from pa_projects_all
    where project_id = p_project_id;

  open ci_csr;
  loop
    fetch ci_csr into ci_rec;
    exit when ci_csr%NOTFOUND;
      l_ci_row_index := l_ci_row_index + 1;

      --- >>>> PROCESSING FOR FIRST ROW <<<< ---
      if l_ci_row_index = 1 then
        l_ci_budget_version_id := ci_rec.budget_version_id;
        pa_fp_view_plans_pub.G_FP_VIEW_VERSION_ID := l_ci_budget_version_id;
        select fin_plan_type_id,
	       proj_fp_options_id
        into l_fin_plan_type_id,
	     l_proj_fp_options_id
        from pa_proj_fp_options
        where project_id = p_project_id and
	      fin_plan_version_id = ci_rec.budget_version_id and
              fin_plan_option_level_code = 'PLAN_VERSION';

        select DECODE(rl.group_resource_type_id,
	  	      0, 'NONGROUPED',
		      'GROUPED'),
               nvl(bv.resource_list_id,0),
	       nvl(bv.budget_status_code, 'W'),
	       DECODE(bv.budget_status_code,
		      'B', 'B',
		      'W'),
	       DECODE(bv.version_type,
		      'COST', 'C',
		      'REVENUE', 'R',
		      'N'),
	       bv.record_version_number,
	       nvl(bv.approved_cost_plan_type_flag, 'N'),
	       nvl(bv.approved_rev_plan_type_flag, 'N'),
	       nvl(rl.uncategorized_flag, 'N')
           into l_grouping_type,
	        l_resource_list_id,
	        x_budget_status_code,
	        l_working_or_baselined,
	        l_cost_or_revenue,
	        l_rv_number,
	        l_ac_flag,
	        l_ar_flag,
		l_uncategorized_flag
           from pa_budget_versions bv,
                pa_resource_lists_all_bg rl
           where bv.budget_version_id = ci_rec.budget_version_id and
                 bv.resource_list_id = rl.resource_list_id;

	-- >>>> BUG FIX 2650878: project or projfunc, depending on AR flag <<<<
	  if l_ar_flag = 'Y' then
	    -- APPROVED REVENUE: go with Project Functional Currency
	    x_ar_flag := 'Y';
	    -- get PROJECT CURRENCY
	    select projfunc_currency_code
	      into x_view_currency_code
	      from pa_projects_all
	      where project_id = p_project_id;
	    pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE := 'PROJFUNC';
	  else
	    -- NOT APPROVED REVENUE: go with Project Currency
	    x_ar_flag := 'N';
	    -- get PROJECT CURRENCY
	    select project_currency_code
	      into x_view_currency_code
	      from pa_projects_all
	      where project_id = p_project_id;
	    pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE := 'PROJECT';
	  end if; -- approved revenue flag
	/*
	if l_uncategorized_flag = 'Y' then
	  x_planned_resources_flag := 'N';
	else
	  x_planned_resources_flag := 'Y';
	end if;
	*/
        select fin_plan_preference_code
          into l_fp_preference_code
          from pa_proj_fp_options
          where project_id = p_project_id and
                fin_plan_type_id = l_fin_plan_type_id and
                fin_plan_option_level_code = 'PLAN_TYPE';

        -- retrieve report_labor_hrs, margin_derived codes from PLAN TYPE entry
        select report_labor_hrs_from_code,
	       margin_derived_from_code
          into l_report_labor_hrs_from_code,
	       l_margin_derived_code
          from pa_proj_fp_options
          where project_id = p_project_id and
	        fin_plan_type_id = l_fin_plan_type_id and
                fin_plan_option_level_code = 'PLAN_TYPE';
        pa_fp_view_plans_pub.G_FP_CALC_QUANTITY_FROM := l_report_labor_hrs_from_code;
        pa_fp_view_plans_pub.G_FP_PLAN_TYPE_ID := l_fin_plan_type_id;
        --pa_fp_view_plans_pub.G_MULTI_CURR_FLAG := ci_rec.plan_in_multi_curr_flag;

        pa_fp_view_plans_pub.G_FP_CALC_MARGIN_FROM := l_margin_derived_code;

        if l_fp_preference_code = 'COST_AND_REV_SAME' then
          pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := l_ci_budget_version_id;
          pa_fp_view_plans_pub.G_FP_REV_VERSION_ID  := l_ci_budget_version_id;
    	  --pa_fp_view_plans_pub.G_COST_VERSION_GROUPING := l_grouping_type;
    	  --pa_fp_view_plans_pub.G_REV_VERSION_GROUPING := l_grouping_type;
    	  pa_fp_view_plans_pub.G_DISPLAY_FROM := 'ANY';
    	  --x_grouping_type := l_grouping_type;
    	  -- set planning level code for page: P, T, L, or M
    	  /*
	  select all_fin_plan_level_code
      	    into l_cost_planning_level
      	    from pa_proj_fp_options
      	    where proj_fp_options_id = l_proj_fp_options_id;
    	  x_planning_level := l_cost_planning_level;
	  */
    	  x_cost_rv_number := l_rv_number;
    	  x_rev_rv_number := l_rv_number;
    	  --x_cost_rl_id := l_resource_list_id;
    	  --x_rev_rl_id := l_resource_list_id;

	elsif l_fp_preference_code = 'COST_ONLY' then
          pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := l_ci_budget_version_id;
          pa_fp_view_plans_pub.G_FP_REV_VERSION_ID  := -1;
    	  --pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_grouping_type;
    	  --pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_grouping_type;
    	  pa_fp_view_plans_pub.G_DISPLAY_FROM := 'COST';
    	  --x_grouping_type := l_grouping_type;
    	  -- set planning level code for page: P, T, L, or M
	  /*
    	  select cost_fin_plan_level_code
      	    into l_cost_planning_level
      	    from pa_proj_fp_options
      	    where proj_fp_options_id = l_proj_fp_options_id;
    	  x_planning_level := l_cost_planning_level;
	  */
    	  x_cost_rv_number := l_rv_number;
    	  x_rev_rv_number := -1;
    	  --x_cost_rl_id := l_resource_list_id;
    	  --x_rev_rl_id := -1;

	elsif l_fp_preference_code = 'REVENUE_ONLY' then
          pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := -1;
          pa_fp_view_plans_pub.G_FP_REV_VERSION_ID  := l_ci_budget_version_id;
    	  --pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_grouping_type;
    	  --pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_grouping_type;
    	  pa_fp_view_plans_pub.G_DISPLAY_FROM := 'REVENUE';
    	  --x_grouping_type := l_grouping_type;
    	  -- set planning level code for page: P, T, L, or M
	  /*
    	  select revenue_fin_plan_level_code
      	    into l_rev_planning_level
      	    from pa_proj_fp_options
      	    where proj_fp_options_id = l_proj_fp_options_id;
    	  x_planning_level := l_rev_planning_level;
	  */
    	  x_cost_rv_number := -1;
    	  x_rev_rv_number := l_rv_number;
    	  --x_cost_rl_id := -1;
    	  --x_rev_rl_id := l_resource_list_id;
	end if;

      --- >>>> PROCESSING FOR SECOND ROW <<<< ---
      else
        -- what we do w/second row depends on the PLAN PREFERENCE CODE
	-- NOTE: if COST_AND_REV_SAME, then we will NOT get a second row

        if l_fp_preference_code = 'COST_ONLY' then
	  -- this second row must be the complementary REVENUE version
          select DECODE(rl.group_resource_type_id,
		        0, 'NONGROUPED',
		        'GROUPED'),
                 rl.resource_list_id,
		 bv.record_version_number,
		 nvl(rl.uncategorized_flag, 'N')
            into l_compl_grouping_type,
		 l_compl_resource_list_id,
		 l_compl_rv_number,
		 l_compl_uncategorized_flag
            from pa_budget_versions bv,
                 pa_resource_lists_all_bg rl
            where bv.budget_version_id = ci_rec.budget_version_id and
                  bv.resource_list_id = rl.resource_list_id;
          pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := l_ci_budget_version_id;
          pa_fp_view_plans_pub.G_FP_REV_VERSION_ID  := ci_rec.budget_version_id;
          --pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_grouping_type;
          --pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_compl_grouping_type;
          pa_fp_view_plans_pub.G_DISPLAY_FROM := 'BOTH';
	  /*
          if l_grouping_type = 'GROUPED' then
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'GROUPED';
            else
              x_grouping_type := 'MIXED';
            end if;
          else
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'MIXED';
            else
              x_grouping_type := 'NONGROUPED';
            end if;
          end if;
	  */
	  x_cost_rv_number := l_rv_number;
	  x_rev_rv_number := l_compl_rv_number;
          --x_cost_rl_id := l_resource_list_id;
          --x_rev_rl_id := l_compl_resource_list_id;
          -- planning level code for cost version: P, T, L, or M
	  /*
          select cost_fin_plan_level_code
            into l_cost_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = l_proj_fp_options_id;
          -- planning level code for revenue (compl) version
          select revenue_fin_plan_level_code
            into l_rev_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = ci_rec.proj_fp_options_id;
          -- PLANNING LEVEL = 'P' if one of the planning levels is P
          if (l_cost_planning_level = 'P') or (l_rev_planning_level = 'P') then
            x_planning_level := 'P';
          else
            x_planning_level := l_cost_planning_level;
          end if;
	  if pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG = 'N' or ci_rec.plan_in_multi_curr_flag = 'N' then
	    pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG := 'N';
	  end if;
	  */

        elsif l_fp_preference_code = 'REVENUE_ONLY' then
	  -- this second row must be the complementary COST version
          select DECODE(rl.group_resource_type_id,
		        0, 'NONGROUPED',
		        'GROUPED'),
		 rl.resource_list_id,
		 bv.record_version_number,
		 nvl(rl.uncategorized_flag, 'N')
            into l_compl_grouping_type,
		 l_compl_resource_list_id,
		 l_compl_rv_number,
		 l_compl_uncategorized_flag
            from pa_budget_versions bv,
                 pa_resource_lists_all_bg rl
            where bv.budget_version_id = ci_rec.budget_version_id and
                  bv.resource_list_id = rl.resource_list_id;
          pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := ci_rec.budget_version_id;
          pa_fp_view_plans_pub.G_FP_REV_VERSION_ID  := l_ci_budget_version_id;
          --pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_compl_grouping_type;
          --pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_grouping_type;
          pa_fp_view_plans_pub.G_DISPLAY_FROM := 'BOTH';
	  /*
          if l_grouping_type = 'GROUPED' then
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'GROUPED';
            else
              x_grouping_type := 'MIXED';
            end if;
          else
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'MIXED';
            else
              x_grouping_type := 'NONGROUPED';
            end if;
          end if;
	  */
	  x_cost_rv_number := l_compl_rv_number;
	  x_rev_rv_number := l_rv_number;
          --x_cost_rl_id := l_resource_list_id;
          --x_rev_rl_id := l_compl_resource_list_id;
          -- planning level code for cost (compl) version: P, T, L, or M
	  /*
          select cost_fin_plan_level_code
            into l_cost_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = ci_rec.proj_fp_options_id;
          -- planning level code for revenue version
          select revenue_fin_plan_level_code
            into l_rev_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = l_proj_fp_options_id;
          -- PLANNING LEVEL = 'P' if one of the planning levels is P
          if (l_cost_planning_level = 'P') or (l_rev_planning_level = 'P') then
            x_planning_level := 'P';
          else
            x_planning_level := l_rev_planning_level;
          end if;
	  if pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG = 'N' or ci_rec.plan_in_multi_curr_flag = 'N' then
	    pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG := 'N';
	  end if;
	  */

        elsif l_fp_preference_code = 'COST_AND_REV_SEP' then
	  if l_cost_or_revenue = 'R' then
	    -- this second row must be the complementary COST version
          select DECODE(rl.group_resource_type_id,
		        0, 'NONGROUPED',
		        'GROUPED'),
		 rl.resource_list_id,
		 bv.record_version_number,
		 nvl(rl.uncategorized_flag, 'N')
            into l_compl_grouping_type,
		 l_compl_resource_list_id,
		 l_compl_rv_number,
		 l_compl_uncategorized_flag
            from pa_budget_versions bv,
                 pa_resource_lists_all_bg rl
            where bv.budget_version_id = ci_rec.budget_version_id and
                  bv.resource_list_id = rl.resource_list_id;
          pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := ci_rec.budget_version_id;
          pa_fp_view_plans_pub.G_FP_REV_VERSION_ID  := l_ci_budget_version_id;
          --pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_compl_grouping_type;
          --pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_grouping_type;
          pa_fp_view_plans_pub.G_DISPLAY_FROM := 'BOTH';
	  /*
          if l_grouping_type = 'GROUPED' then
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'GROUPED';
            else
              x_grouping_type := 'MIXED';
            end if;
          else
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'MIXED';
            else
              x_grouping_type := 'NONGROUPED';
            end if;
          end if;
	  */
	  x_cost_rv_number := l_compl_rv_number;
	  x_rev_rv_number := l_rv_number;
          --x_cost_rl_id := l_resource_list_id;
          --x_rev_rl_id := l_compl_resource_list_id;
          -- planning level code for cost (compl) version: P, T, L, or M
	  /*
          select cost_fin_plan_level_code
            into l_cost_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = ci_rec.proj_fp_options_id;
          -- planning level code for revenue version
          select revenue_fin_plan_level_code
            into l_rev_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = l_proj_fp_options_id;
          -- PLANNING LEVEL = 'P' if one of the planning levels is P
          if (l_cost_planning_level = 'P') or (l_rev_planning_level = 'P') then
            x_planning_level := 'P';
          else
            x_planning_level := l_rev_planning_level;
          end if;
	  if pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG = 'N' or ci_rec.plan_in_multi_curr_flag = 'N' then
	    pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG := 'N';
	  end if;
	  */

 	  else
	    -- this second row must be the complementary REVENUE version
          select DECODE(rl.group_resource_type_id,
		        0, 'NONGROUPED',
		        'GROUPED'),
                 rl.resource_list_id,
		 bv.record_version_number,
		 nvl(rl.uncategorized_flag, 'N')
            into l_compl_grouping_type,
		 l_compl_resource_list_id,
		 l_compl_rv_number,
		 l_compl_uncategorized_flag
            from pa_budget_versions bv,
                 pa_resource_lists_all_bg rl
            where bv.budget_version_id = ci_rec.budget_version_id and
                  bv.resource_list_id = rl.resource_list_id;
          pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := l_ci_budget_version_id;
          pa_fp_view_plans_pub.G_FP_REV_VERSION_ID  := ci_rec.budget_version_id;
          --pa_fp_view_plans_txn_pub.G_COST_VERSION_GROUPING := l_grouping_type;
          --pa_fp_view_plans_txn_pub.G_REV_VERSION_GROUPING := l_compl_grouping_type;
          pa_fp_view_plans_pub.G_DISPLAY_FROM := 'BOTH';
	  /*
          if l_grouping_type = 'GROUPED' then
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'GROUPED';
            else
              x_grouping_type := 'MIXED';
            end if;
          else
            if l_compl_grouping_type = 'GROUPED' then
              x_grouping_type := 'MIXED';
            else
              x_grouping_type := 'NONGROUPED';
            end if;
          end if;
	  */
	  x_cost_rv_number := l_rv_number;
	  x_rev_rv_number := l_compl_rv_number;
          --x_cost_rl_id := l_resource_list_id;
          --x_rev_rl_id := l_compl_resource_list_id;
          -- planning level code for cost version: P, T, L, or M
	  /*
          select cost_fin_plan_level_code
            into l_cost_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = l_proj_fp_options_id;
          -- planning level code for revenue (compl) version
          select revenue_fin_plan_level_code
            into l_rev_planning_level
            from pa_proj_fp_options
            where proj_fp_options_id = ci_rec.proj_fp_options_id;
          -- PLANNING LEVEL = 'P' if one of the planning levels is P
          if (l_cost_planning_level = 'P') or (l_rev_planning_level = 'P') then
            x_planning_level := 'P';
          else
            x_planning_level := l_cost_planning_level;
          end if;
	  if pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG = 'N' or ci_rec.plan_in_multi_curr_flag = 'N' then
	    pa_fp_view_plans_txn_pub.G_MULTI_CURR_FLAG := 'N';
	  end if;
	  */
	  end if;
        end if;
      end if;
  end loop;
  close ci_csr;
---------- END non-Hgrid initialization ----------

---------- BEGIN Hgrid initialization

        select bv.project_id,
	       DECODE(p_view_currency_type,
		     'PROJ', pa.project_currency_code,
		     'PROJFUNC', pa.projfunc_currency_code,
		     'TXN')
         into  l_project_id,
	       l_projfunc_currency_code
         from  pa_budget_versions bv,
	       pa_projects_all pa
        where  bv.budget_version_id = pa_fp_view_plans_pub.G_FP_VIEW_VERSION_ID and
	       bv.project_id = pa.project_id;
       select nvl(org_id,-99)
         into l_org_id
         from pa_projects_all
         where project_id = l_project_id;
       pa_fp_view_plans_pub.G_FP_ORG_ID := l_org_id;
       x_view_currency_code := l_projfunc_currency_code;	-- OUTPUT: x_view_currency_code

  BEGIN
        select fin_plan_start_date, fin_plan_end_date, fin_plan_type_id
--	       default_amount_type_code,
--	       default_amount_subtype_code
         into  ll_plan_start_date,ll_plan_end_date, l_fin_plan_type_id
--	       l_default_amount_type_code,
--	       l_default_amount_subtype_code
         from  pa_proj_fp_options
        where  fin_plan_version_id = pa_fp_view_plans_pub.G_FP_VIEW_VERSION_ID;

	-- DERIVE MARGIN FROM CODE: get from PLAN TYPE entry
	select proj_fp_options_id,
	       margin_derived_from_code,
	       report_labor_hrs_from_code
	  into x_plan_fp_options_id,				-- OUTPUT: x_plan_fp_options_id
	       l_margin_derived_from_code,
	       l_labor_hours_from_code
	  from pa_proj_fp_options
	  where project_id = l_project_id and
		fin_plan_type_id = l_fin_plan_type_id and
		fin_plan_option_level_code='PLAN_TYPE';
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
      --hr_utility.trace('no_data_found 1');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg
	( p_pkg_name         => 'PA_FP_VIEW_PLANS_PUB',
          p_procedure_name   => 'pa_fp_viewplan_hgrid_init:plan start/end dates: 100');
  END;
  --hr_utility.trace('stage 100 passed');
  x_plan_type_id := l_fin_plan_type_id;				-- OUTPUT: x_plan_type_id
  pa_fp_view_plans_pub.G_FP_CALC_MARGIN_FROM := l_margin_derived_from_code;
  x_calc_margin_from := l_margin_derived_from_code;		-- OUTPUT: x_calc_margin_from
  pa_fp_view_plans_pub.G_FP_CALC_QUANTITY_FROM := l_labor_hours_from_code;
  x_labor_hrs_from_code := l_labor_hours_from_code;		-- OUTPUT: x_labor_hrs_from_code


-- USER CUSTOMIZATIONS (ADVANCED DISPLAY OPTIONS PAGE)
-- see if we are displaying data from user-selected version
	if (p_user_cost_version_id is not null) or (p_user_rev_version_id is not null) then
	  l_user_bv_flag := 'Y';
	else
	  l_user_bv_flag := 'N';
	end if;

-- set the display from flags
	if l_user_bv_flag = 'Y' then
 	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_QUANTITY := p_display_quantity;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_RAWCOST := p_display_rawcost;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_BURDCOST := p_display_burdcost;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_REVENUE := p_display_revenue;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGIN := p_display_margin;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGINPCT := p_display_marginpct;
	  x_factor_by_code := null;
	else
	  -- retrieve default settings
	  select DECODE(bv.version_type,
			'COST', po.cost_amount_set_id,
			'REVENUE', po.revenue_amount_set_id,
			po.all_amount_set_id),
		 bv.version_type,
		 po.factor_by_code
	    into l_amount_set_id,
		 l_version_type,
		 x_factor_by_code			-- OUTPUT: x_factor_by_code
	    from pa_budget_versions bv,
		 pa_proj_fp_options po
	    where bv.budget_version_id = pa_fp_view_plans_pub.G_FP_VIEW_VERSION_ID and
		  bv.fin_plan_type_id = po.fin_plan_type_id and
		  po.project_id = l_project_id and
		  po.fin_plan_option_level_code = 'PLAN_TYPE';
	  select DECODE(l_version_type,
			'COST', nvl(cost_qty_flag,'N'),
			'REVENUE', nvl(revenue_qty_flag, 'N'),
			nvl(all_qty_flag, 'N')),
		 nvl(raw_cost_flag, 'N'),
		 nvl(burdened_cost_flag, 'N'),
		 nvl(revenue_flag, 'N'),
		 DECODE(l_version_type,
			'ALL', 'Y',
			'N'),
		 DECODE(l_version_type,
			'ALL', 'Y',
			'N')
	    into l_display_quantity,
	  	 l_display_rawcost,
	  	 l_display_burdcost,
	  	 l_display_revenue,
	  	 l_display_margin,
	  	 l_display_marginpct
	    from pa_fin_plan_amount_sets
	    where fin_plan_amount_set_id = l_amount_set_id;
 	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_QUANTITY := l_display_quantity;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_RAWCOST := l_display_rawcost;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_BURDCOST := l_display_burdcost;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_REVENUE := l_display_revenue;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGIN := l_display_margin;
	  pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGINPCT := l_display_marginpct;
	end if;
--hr_utility.trace('quantityflag= ' || pa_fp_view_plans_pub.G_DISPLAY_FLAG_QUANTITY);
--hr_utility.trace('rawcostflag= ' || pa_fp_view_plans_pub.G_DISPLAY_FLAG_RAWCOST);
--hr_utility.trace('burdenedcostflag= ' || pa_fp_view_plans_pub.G_DISPLAY_FLAG_BURDCOST);
--hr_utility.trace('revenueflag= ' || pa_fp_view_plans_pub.G_DISPLAY_FLAG_REVENUE);
--hr_utility.trace('marginflag= ' || pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGIN);
--hr_utility.trace('marginpctflag= ' || pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGINPCT);

-- set the DEFAULT AMOUNT TYPE/SUBTYPE CODES, based on order of hierarchy
	if pa_fp_view_plans_pub.G_DISPLAY_FLAG_QUANTITY = 'Y' then
	  l_default_amount_type_code := 'QUANTITY';
	  l_default_amount_subtype_code := 'QUANTITY';
	elsif pa_fp_view_plans_pub.G_DISPLAY_FLAG_RAWCOST = 'Y' then
	  l_default_amount_type_code := 'COST';
	  l_default_amount_subtype_code := 'RAW_COST';
	elsif pa_fp_view_plans_pub.G_DISPLAY_FLAG_BURDCOST = 'Y' then
	  l_default_amount_type_code := 'COST';
	  l_default_amount_subtype_code := 'BURDENED_COST';
	elsif pa_fp_view_plans_pub.G_DISPLAY_FLAG_REVENUE = 'Y' then
	  l_default_amount_type_code := 'REVENUE';
	  l_default_amount_subtype_code := 'REVENUE';
	elsif pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGIN = 'Y' then
	  l_default_amount_type_code := 'MARGIN';
	  l_default_amount_subtype_code := 'MARGIN';
	else
	  l_default_amount_type_code := 'MARGIN_PERCENT';
	  l_default_amount_subtype_code := 'MARGIN_PERCENT';
	end if; -- set default amount type codes

-- set the user-defined budget versions source
	if l_user_bv_flag = 'Y' then
	  if (p_user_cost_version_id = p_user_rev_version_id) then
	    pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID := p_user_cost_version_id;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := p_user_cost_version_id;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_ID := p_user_rev_version_id;
	  else
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := p_user_cost_version_id;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_ID := p_user_rev_version_id;
	  end if;
	  select approved_rev_plan_type_flag
	    into x_ar_flag					-- OUTPUT: x_ar_flag
	    from pa_proj_fp_options
	    where project_id = l_project_id and
		  fin_plan_type_id = l_fin_plan_type_id and
		  fin_plan_option_level_code='PLAN_TYPE';

	else
           -- retrieve l_cost_or_revenue: applicable only for COST_AND_REV_SEP
           -- this param is passed to populate_tmp_table
           -- this param is useful only if the user did not select budget versions
           select DECODE(version_type,
       		         'REVENUE', 'R',
		         'COST', 'C',
		         null),
	          nvl(budget_status_code, 'W'),
	          nvl(approved_rev_plan_type_flag, 'N')
	     into l_cost_or_revenue,
	          x_budget_status_code,				-- OUTPUT: x_budget_status_code
	          x_ar_flag					-- OUTPUT: x_ar_flag
	     from pa_budget_versions
	     where budget_version_id = pa_fp_view_plans_pub.G_FP_VIEW_VERSION_ID;
	end if;
-- END OF USER CUSTOMIZATIONS (ADVANCED DISPLAY OPTIONS)
	pa_fp_view_plans_pub.G_DEFAULT_AMOUNT_TYPE_CODE := l_default_amount_type_code;
	pa_fp_view_plans_pub.G_DEFAULT_AMT_SUBTYPE_CODE := l_default_amount_subtype_code;
	pa_fp_view_plans_pub.G_FP_CURRENCY_CODE := l_projfunc_currency_code;
	pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE := p_view_currency_type;
  --hr_utility.trace('reached end of user customizations section: 200');

  BEGIN
/* Commented for bug 7514054
        select pp.plan_period_type,
	       pp.period1_start_date,
	       pp.period_profile_id
        into   ll_plan_period_type,
	       pp_plan_start_date,
	       l_period_profile_id
        from   pa_proj_period_profiles pp,
               pa_budget_versions pbv
        where  pbv.budget_version_id = pa_fp_view_plans_pub.G_FP_VIEW_VERSION_ID
         and   pp.period_profile_id = pbv.period_profile_id;
  Ends commented for 7514054 and added below code
*/
	select min(start_date) into pp_plan_start_date from
    pa_budget_lines
    where budget_version_id = pa_fp_view_plans_pub.G_FP_VIEW_VERSION_ID;

	  select decode(nvl(cost_time_phased_code,
	  nvl(revenue_time_phased_code, all_time_phased_code)), 'G', 'GL', 'P', 'PA', 'N')
	    into ll_plan_period_type					-- OUTPUT: ll_plan_period_type
	    from pa_proj_fp_options
	    where project_id = l_project_id and
		  fin_plan_type_id = l_fin_plan_type_id and
		  fin_plan_option_level_code='PLAN_TYPE';

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg
	( p_pkg_name         => 'PA_FP_VIEW_PLANS_PUB',
          p_procedure_name   => 'pa_fp_viewplan_hgrid_init:plan period type: 300');
  END;
  --hr_utility.trace('after selecting from pa_proj_period_profiles: 300 succeeded');


-- SETTING PERIOD INFORMATION --
-- ONLY IF IN PERIODIC MODE --

  if p_amt_or_pd = 'P' then
	-- get period info based on period_profile_id
	  Pa_Prj_Period_Profile_Utils.Get_Prj_Period_Profile_Dtls(
                          p_period_profile_id   => l_period_profile_id,
                          p_debug_mode          => 'Y',
                          p_add_msg_in_stack    => 'Y',
                          x_period_profile_type => l_period_profile_type,
                          x_plan_period_type    => l_plan_period_type,
                          x_period_set_name     => l_period_set_name,
                          x_gl_period_type      => l_gl_period_type,
                          x_plan_start_date     => l_plan_start_date,
                          x_plan_end_date       => l_plan_end_date,
                          x_number_of_periods   => l_number_of_periods,
                          x_return_status       => l_return_status,
                          x_msg_data            => l_msg_data);
	-- get current period info
--hr_utility.trace('executed get_prj_Period_profile_dtls');
--hr_utility.trace('l_period_profile_type= ' || l_period_profile_type);
--hr_utility.trace('l_plan_period_type= ' || l_plan_period_type);
	  Pa_Prj_Period_Profile_Utils.Get_Curr_Period_Profile_Info(
              p_project_id          => l_project_id
             ,p_period_type         => l_plan_period_type
             ,p_period_profile_type => 'FINANCIAL_PLANNING'
             ,x_period_profile_id   => l_cur_period_profile_id
             ,x_start_period        => l_cur_start_period
             ,x_end_period          => l_cur_end_period
             ,x_return_status       => l_return_status
             ,x_msg_count           => l_msg_count
             ,x_msg_data            => l_msg_data);
--hr_utility.trace('executed get_curr_period_profile_info');
--hr_utility.trace('l_plan_period_type= ' || l_plan_period_type);
--hr_utility.trace('l_cur_period_profile_id= ' || l_cur_period_profile_id);
--hr_utility.trace('l_cur_start_period= ' || l_cur_start_period);
--hr_utility.trace('l_cur_end_period= ' || l_cur_end_period);

	if l_period_profile_id = l_cur_period_profile_id then
	  x_old_pd_profile_flag := 'N';				-- OUTPUT: x_old_pd_profile_flag
	else
	  x_old_pd_profile_flag := 'Y';
	end if;

	if ll_plan_start_date is null or ll_plan_end_date is null then
	  ll_plan_start_date := l_plan_start_date;
	  ll_plan_end_date := l_plan_end_date;
	end if;

	pa_fp_view_plans_pub.G_FP_PLAN_START_DATE := ll_plan_start_date;
	pa_fp_view_plans_pub.G_FP_PLAN_END_DATE := ll_plan_end_date;
	pa_fp_view_plans_pub.G_FP_PERIOD_TYPE := ll_plan_period_type;
	x_plan_period_type := ll_plan_period_type;		-- OUTPUT: x_plan_period_type
        if ll_plan_period_type = 'GL' THEN
          l_num_of_periods := 6;
        else
          l_num_of_periods := 13;
        end if;

	if p_period_start_date = 'N' Then
          l_start_date :=  to_char(ll_plan_start_date);
	  -- 11/7/2002: IF no value retrieved from fin_plan_start_date, then use the first start
	  --	      date according to the period profile id
	  if l_start_date is null then
	    l_start_date := to_char(pp_plan_start_date);
	  end if;
	elsif p_period_start_date = 'L' Then
          pa_fp_view_plans_pub.G_FP_VIEW_START_DATE1:=ll_plan_end_date;
          pa_fp_view_plans_pub.pa_fp_set_periods_nav (
                                  p_direction      => 'BACKWARD',
                                  p_num_of_periods => l_num_of_periods,
                                  p_period_type    => ll_plan_period_type,
                                  x_start_date     => l_start_date,
                                  x_return_status  => l_return_status,
                                  x_msg_count      => l_msg_count,
                                  x_msg_data       => l_msg_data);
        else
          l_start_date := p_period_start_date;
        end if;

        pa_fp_view_plans_pub.pa_fp_set_periods
		( p_period_start_date => l_start_date,
                  p_period_type       => ll_plan_period_type,
                  x_return_status     => l_return_status,
                  x_msg_count         => l_msg_count,
                  x_msg_data          => l_msg_data);
  --hr_utility.trace('END OF SETTING PERIOD INFORMATION: 400');

  end if; -- check p_amt_or_pd flag
-- END OF SETTING PERIOD INFORMATION --


-- POPULATE THE GLOBAL TEMPORARY TABLE --
-- we expect the following to be done after this procedure:
-- 1. global variables should be set:
-- 	G_DISPLAY_FROM
--	G_FP_COST_VERSION_ID (may be set already, if user-entered)
--	G_FP_COST_VERSION_NUMBER
--	G_FP_COST_VERSION_NAME
--	G_FP_REV_VERSION_ID (may be set already, if user-entered)
--	G_FP_REV_VERSION_NAME
--	G_FP_REV_VERSION_NUMBER
--	G_FP_ALL_VERSION_ID (may be set already, if user-entered)
--	G_FP_ALL_VERSION_NAME
--	G_FP_ALL_VERSION_NUMBER
--hr_utility.trace('calling view_plan_temp_tables');
	-- delete residual data in the temp tables
	DELETE from PA_FIN_VP_AMTS_VIEW_TMP;
	DELETE from PA_FIN_VP_PDS_VIEW_TMP;

/*  -- since we've already found the complements, we call the appropriate
 *     global temp table populating procedures ourselves
	pa_fp_view_plans_pub.view_plan_temp_tables
    		(p_project_id		=> l_project_id,
     		 p_budget_version_id	=> p_orgfcst_version_id,
     		 p_cost_or_revenue	=> l_cost_or_revenue,
		 p_user_bv_flag		=> l_user_bv_flag,
     		 x_cost_version_number	=> l_cost_version_number,
     		 x_rev_version_number	=> l_rev_version_number,
     		 x_cost_version_name	=> l_cost_version_name,
     		 x_rev_version_name	=> l_rev_version_name,
		 x_diff_pd_profile_flag => l_diff_pd_profile_flag,
     		 x_return_status	=> l_return_status,
     		 x_msg_count		=> l_msg_count,
     		 x_msg_data		=> l_msg_data );
	-- if view_plan_temp_tables fails, error out right away
	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    x_msg_count := FND_MSG_PUB.Count_Msg;
	    if x_msg_count = 1 then
      		PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_msg_data,
                      p_msg_index_out  => l_msg_index_out);
	    end if;
	    return;
	end if;
*/
-- END OF POPULATING GLOBAL TEMPORARY TABLE --
/*
  x_display_from := pa_fp_view_plans_pub.G_DISPLAY_FROM;	-- OUTPUT: x_display_from
  x_diff_pd_profile_flag := l_diff_pd_profile_flag;		-- OUTPUT: x_diff_pd_profile_flag
  -- NEED THIS IN CASE NOT USER-SPECIFIED
  if pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID is not null then
    if pa_fp_view_plans_pub.G_FP_COST_VERSION_ID is null then
      pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID;
    end if;
    if pa_fp_view_plans_pub.G_FP_REV_VERSION_ID is null then
      pa_fp_view_plans_pub.G_FP_REV_VERSION_ID := pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID;
    end if;
  end if;

-- figure out x_time_phase_code: to decide whether or not to display the amt/pd toggle
  if pa_fp_view_plans_pub.G_DISPLAY_FROM = 'ANY' then
	select nvl(all_time_phased_code, 'N')
	  into x_time_phase_code				-- OUTPUT: x_time_phase_code
	  from pa_proj_fp_options
	  where fin_plan_version_id = pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID;
  elsif pa_fp_view_plans_pub.G_DISPLAY_FROM = 'COST' then
	select nvl(cost_time_phased_code, 'N')
	  into x_time_phase_code				-- OUTPUT: x_time_phase_code
	  from pa_proj_fp_options
	  where fin_plan_version_id = pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
  elsif pa_fp_view_plans_pub.G_DISPLAY_FROM = 'REVENUE' then
	select nvl(revenue_time_phased_code, 'N')
	  into x_time_phase_code				-- OUTPUT: x_time_phase_code
	  from pa_proj_fp_options
	  where fin_plan_version_id = pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
  else
	select nvl(cost_time_phased_code, 'N')
	  into l_cost_time_phase_code
	  from pa_proj_fp_options
	  where fin_plan_version_id = pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
	select nvl(revenue_time_phased_code, 'N')
	  into l_rev_time_phase_code
	  from pa_proj_fp_options
	  where fin_plan_version_id = pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
	if l_cost_time_phase_code <> 'Y' and l_rev_time_phase_code <> 'Y' then
	  x_time_phase_code := 'N';				-- OUTPUT: x_time_phase_code
	else
	  x_time_phase_code := l_cost_time_phase_code;		-- OUTPUT: x_time_phase_code
	end if;
  end if;

  x_cost_bv_id := pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
  if x_cost_bv_id is null then
	if pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID is null then
	  x_cost_bv_id := -1;
	else
	  x_cost_bv_id := pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID;
	end if;
  end if;
  x_revenue_bv_id := pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
  if x_revenue_bv_id is null then
	if pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID is null then
	  x_revenue_bv_id := -1;
	else
	  x_revenue_bv_id := pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID;
	end if;
  end if;

-- figure out LOCKED BY after version sources set; also get RECORD VERSION NUMBERS
    -- COST VERSION
  if pa_fp_view_plans_pub.G_FP_COST_VERSION_ID is not null then
--hr_utility.trace('figuring out cost LOCKED BY');
    select record_version_number,				-- OUTPUT: x_cost_rv_number
	   budget_status_code					-- OUTPUT: x_budget_status_code
      into x_cost_rv_number,
	   x_budget_status_code
      from pa_budget_versions
      where budget_version_id = pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
    pa_fin_plan_utils.Check_Locked_By_User
	(p_user_id		=> p_user_id,
	 p_budget_version_id	=> pa_fp_view_plans_pub.G_FP_COST_VERSION_ID,
	 x_is_locked_by_userid	=> l_is_cost_locked_by_user,
	 x_locked_by_person_id	=> l_cost_locked_by_person_id,
	 x_return_status	=> l_return_status,
	 x_msg_count		=> l_msg_count,
	 x_msg_data		=> l_msg_data);
    if l_is_cost_locked_by_user = 'N' then
      if l_cost_locked_by_person_id is null then
        x_cost_locked_name := 'NONE';
      else
        x_cost_locked_name := pa_fin_plan_utils.get_person_name(l_cost_locked_by_person_id);
      end if;
    else
      x_cost_locked_name := 'SELF';
    end if; -- is_cost_locked_by_user
  end if; -- END:COST VERSION

    -- REVENUE VERSION
  if pa_fp_view_plans_pub.G_FP_REV_VERSION_ID is not null then
--hr_utility.trace('figuring out revenue LOCKED BY');
    select record_version_number,				-- OUTPUT: x_rev_rv_number
	   budget_status_code					-- OUTPUT: x_budget_status_code
      into x_rev_rv_number,
	   x_budget_status_code
      from pa_budget_versions
      where budget_version_id = pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
    pa_fin_plan_utils.Check_Locked_By_User
	(p_user_id		=> p_user_id,
	 p_budget_version_id	=> pa_fp_view_plans_pub.G_FP_REV_VERSION_ID,
	 x_is_locked_by_userid	=> l_is_rev_locked_by_user,
	 x_locked_by_person_id	=> l_rev_locked_by_person_id,
	 x_return_status	=> l_return_status,
	 x_msg_count		=> l_msg_count,
	 x_msg_data		=> l_msg_data);
    if l_is_rev_locked_by_user = 'N' then
      if l_rev_locked_by_person_id is null then
        x_rev_locked_name := 'NONE';
      else
        x_rev_locked_name := pa_fin_plan_utils.get_person_name(l_rev_locked_by_person_id);
      end if;
    else
      x_rev_locked_name := 'SELF';
    end if; -- is_rev_locked_by_user
  end if; -- END:REVENUE VERSION


--hr_utility.trace('after calling locked version stuff');
--hr_utility.trace('G_FP_PERIOD_TYPE = ' || pa_fp_view_plans_pub.G_FP_PERIOD_TYPE);
--hr_utility.trace('G_FP_VIEW_START_DATE1 = ' || to_char(pa_fp_view_plans_pub.G_FP_VIEW_START_DATE1));
--hr_utility.trace('G_FP_VIEW_START_DATE2 = ' || to_char(pa_fp_view_plans_pub.G_FP_VIEW_START_DATE2));
--hr_utility.trace('G_FP_VIEW_START_DATE3 = ' || to_char(pa_fp_view_plans_pub.G_FP_VIEW_START_DATE3));
--hr_utility.trace('G_FP_VIEW_START_DATE4 = ' || to_char(pa_fp_view_plans_pub.G_FP_VIEW_START_DATE4));
--hr_utility.trace('G_FP_VIEW_START_DATE5 = ' || to_char(pa_fp_view_plans_pub.G_FP_VIEW_START_DATE5));
--hr_utility.trace('G_FP_VIEW_START_DATE6 = ' || to_char(pa_fp_view_plans_pub.G_FP_VIEW_START_DATE6));
--hr_utility.trace('x_cost_rv_number= ' || TO_CHAR(x_cost_rv_number));
--hr_utility.trace('x_rev_rv_number= ' || TO_CHAR(x_rev_rv_number));
--hr_utility.trace('x_budget_status_code= ' || x_budget_status_code);
*/

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg
	( p_pkg_name         => 'PA_FP_VIEW_PLANS_PUB',
          p_procedure_name   => 'pa_fp_viewplan_hgrid_init');
END pa_fp_viewplan_hgrid_init_ci;


/*
PROCEDURE pa_fp_viewby_set_globals
	( p_amount_type_code       IN   VARCHAR2,
          p_resource_assignment_id IN   NUMBER,
	  p_budget_version_id      IN   NUMBER,
          p_start_period           IN   VARCHAR2,
          x_return_status          OUT  VARCHAR2,
          x_msg_count              OUT  NUMBER,
          x_msg_data               OUT  VARCHAR2)
IS

l_budget_version_id NUMBER;
l_return_status  VARCHAR2(2);
l_msg_count  NUMBER;
l_msg_data  VARCHAR2(80);
l_start_date VARCHAR2(30);

BEGIN

x_return_status    := FND_API.G_RET_STS_SUCCESS;

pa_fp_view_plans_pub.G_FP_AMOUNT_TYPE_CODE := p_amount_type_code;
pa_fp_view_plans_pub.G_FP_RA_ID := p_resource_assignment_id;
l_budget_version_id    := p_budget_version_id;

l_start_date  := p_start_period;

pa_fp_view_plans_pub.pa_fp_set_orgfcst_version_id
	(p_orgfcst_version_id 	=> l_budget_version_id,
	 p_period_start_date 	=> l_start_date,
         x_return_status 	=> l_return_status,
         x_msg_count    	=> l_msg_count,
         x_msg_data   		=> l_msg_data);
EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg
	( p_pkg_name         => 'PA_FP_VIEW_PLANS_PUB',
          p_procedure_name   => 'pa_fp_viewby_set_globals');
END pa_fp_viewby_set_globals;
*/

PROCEDURE pa_fp_set_periods
	( p_period_start_date   IN   VARCHAR2,
	  p_period_type		IN   VARCHAR2,
          x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data               OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
l_start_date		DATE;
v_start_date_tab	PA_FORECAST_GLOB.DateTabTyp;
v_end_date_tab          PA_FORECAST_GLOB.DateTabTyp;
i			NUMBER;
l_rownum		NUMBER;

CURSOR C1(l_start_date IN DATE, l_rownum IN NUMBER) IS
  SELECT * FROM(
      SELECT start_date,end_date
      FROM pa_fp_periods_tmp_v
     WHERE start_date  >= l_start_date
       order by start_date
           )
  where rownum <= l_rownum;

BEGIN
	x_return_status    := FND_API.G_RET_STS_SUCCESS;
        /* Bug Fix 4373890
           Adding a format mask for the GSCC file.Date.5 fix
        */
        l_start_date := to_date(p_period_start_date);---,'YYYY/MM/DD');
        i := 0;

   if p_period_type = 'GL' THEN

      l_rownum := 6;

   elsif p_period_type = 'PA' THEN

      l_rownum := 13;

   end if;


      OPEN C1(l_start_date,l_rownum);

    LOOP

          FETCH C1 INTO v_start_date_tab(i),v_end_date_tab(i);

--     dbms_output.put_line('i: '||i);
          i := i+1;
hr_utility.trace('ok so far');
          EXIT WHEN C1%NOTFOUND;

    END LOOP;

       CLOSE C1;

   -- BUG FIX 3142192: not all 6 (or 13) periods may exist, if we are
   -- starting with the Current Period
   -- 1. initialized all global start date variables to null
   -- 2. populated global variables only if records exist for them in the
   --    PL/SQL table

   pa_fp_view_plans_pub.G_FP_VIEW_START_DATE1 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_START_DATE2 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_START_DATE3 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_START_DATE4 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_START_DATE5 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_START_DATE6 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_START_DATE7 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_START_DATE8 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_START_DATE9 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_START_DATE10 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_START_DATE11 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_START_DATE12 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_START_DATE13 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_END_DATE1 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_END_DATE2 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_END_DATE3 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_END_DATE4 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_END_DATE5 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_END_DATE6 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_END_DATE7 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_END_DATE8 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_END_DATE9 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_END_DATE10 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_END_DATE11 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_END_DATE12 := null;
   pa_fp_view_plans_pub.G_FP_VIEW_END_DATE13 := null;


   if i > 1 then
     pa_fp_view_plans_pub.G_FP_VIEW_START_DATE1 :=  v_start_date_tab(0);
     pa_fp_view_plans_pub.G_FP_VIEW_END_DATE1 :=  v_end_date_tab(0);
   end if;
   if i > 2 then
     pa_fp_view_plans_pub.G_FP_VIEW_START_DATE2 :=  v_start_date_tab(1);
     pa_fp_view_plans_pub.G_FP_VIEW_END_DATE2 :=  v_end_date_tab(1);
   end if;
   if i > 3 then
     pa_fp_view_plans_pub.G_FP_VIEW_START_DATE3 :=  v_start_date_tab(2);
     pa_fp_view_plans_pub.G_FP_VIEW_END_DATE3 :=  v_end_date_tab(2);
   end if;
   if i > 4 then
     pa_fp_view_plans_pub.G_FP_VIEW_START_DATE4 :=  v_start_date_tab(3);
     pa_fp_view_plans_pub.G_FP_VIEW_END_DATE4 :=  v_end_date_tab(3);
   end if;
   if i > 5 then
     pa_fp_view_plans_pub.G_FP_VIEW_START_DATE5 :=  v_start_date_tab(4);
     pa_fp_view_plans_pub.G_FP_VIEW_END_DATE5 :=  v_end_date_tab(4);
   end if;
   if i > 6 then
     pa_fp_view_plans_pub.G_FP_VIEW_START_DATE6 :=  v_start_date_tab(5);
     pa_fp_view_plans_pub.G_FP_VIEW_END_DATE6 :=  v_end_date_tab(5);
   end if;

   if p_period_type = 'PA' THEN
   if i > 7 then
     pa_fp_view_plans_pub.G_FP_VIEW_START_DATE7 :=  v_start_date_tab(6);
     pa_fp_view_plans_pub.G_FP_VIEW_END_DATE7 :=  v_end_date_tab(6);
   end if;
   if i > 8 then
     pa_fp_view_plans_pub.G_FP_VIEW_START_DATE8 :=  v_start_date_tab(7);
     pa_fp_view_plans_pub.G_FP_VIEW_END_DATE8 :=  v_end_date_tab(7);
   end if;
   if i > 9 then
     pa_fp_view_plans_pub.G_FP_VIEW_START_DATE9 :=  v_start_date_tab(8);
     pa_fp_view_plans_pub.G_FP_VIEW_END_DATE9 :=  v_end_date_tab(8);
   end if;
   if i > 10 then
     pa_fp_view_plans_pub.G_FP_VIEW_START_DATE10 :=  v_start_date_tab(9);
     pa_fp_view_plans_pub.G_FP_VIEW_END_DATE10 :=  v_end_date_tab(9);
   end if;
   if i > 11 then
     pa_fp_view_plans_pub.G_FP_VIEW_START_DATE11 :=  v_start_date_tab(10);
     pa_fp_view_plans_pub.G_FP_VIEW_END_DATE11 :=  v_end_date_tab(10);
   end if;
   if i > 12 then
     pa_fp_view_plans_pub.G_FP_VIEW_START_DATE12 :=  v_start_date_tab(11);
     pa_fp_view_plans_pub.G_FP_VIEW_END_DATE12 :=  v_end_date_tab(11);
   end if;
   if i > 13 then
     pa_fp_view_plans_pub.G_FP_VIEW_START_DATE13 :=  v_start_date_tab(12);
     pa_fp_view_plans_pub.G_FP_VIEW_END_DATE13 :=  v_end_date_tab(12);
   end if;
   end if;

   -- END BUG FIX 3142192

END pa_fp_set_periods;


-- REVISION HISTORY:
-- 14-JAN-03 dlai  restricted cursors to contain only periods in period profile
PROCEDURE pa_fp_set_periods_nav
	( p_direction	     	  IN 	VARCHAR2,
          p_num_of_periods   	  IN 	NUMBER,
          p_period_type		  IN    VARCHAR2,
          x_start_date            OUT   NOCOPY VARCHAR2,	 --File.Sql.39 bug 4440895
          x_return_status         OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count             OUT   NOCOPY NUMBER,   --File.Sql.39 bug 4440895
          x_msg_data              OUT   NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_start_date	 DATE;
ll_start_date	 DATE;
ll_end_date	 DATE;
l_period_type	 VARCHAR2(2);
l_rownum         NUMBER;
l_return_status  VARCHAR2(2);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(80);


CURSOR C_forward(l_start_date IN DATE) IS

      SELECT start_date, end_date
      FROM pa_fp_periods_tmp_v
     WHERE start_date  > l_start_date and
	   start_date between pa_fp_view_plans_pub.G_FP_PLAN_START_DATE and
			      pa_fp_view_plans_pub.G_FP_PLAN_END_DATE
       order by start_date;


CURSOR C_backward(l_start_date IN DATE) IS

      SELECT start_date
      FROM pa_fp_periods_tmp_v
     WHERE start_date < l_start_date and
	   start_date between pa_fp_view_plans_pub.G_FP_PLAN_START_DATE and
			      pa_fp_view_plans_pub.G_FP_PLAN_END_DATE
       order by start_date desc;

BEGIN
--hr_utility.trace_on(null, 'dlai');
	l_rownum := p_num_of_periods;
	ll_start_date := null;
        l_start_date := pa_fp_view_plans_pub.G_FP_VIEW_START_DATE1;

        l_period_type := p_period_type;

 IF p_direction = 'FORWARD' THEN

    OPEN C_forward(l_start_date);

  LOOP

     FETCH C_forward INTO ll_start_date, ll_end_date;

     EXIT WHEN C_forward%NOTFOUND;
     EXIT WHEN C_forward%ROWCOUNT = l_rownum;

  END LOOP;
  -- if we've reached the end of the period profile, we need go loop back
  -- 6 or 13 periods, depending on the period type
  if ll_end_date = pa_fp_view_plans_pub.G_FP_PLAN_END_DATE then
    if pa_fp_view_plans_pub.G_FP_PERIOD_TYPE = 'PA' then
	l_rownum := 12;
    	OPEN C_backward(ll_start_date);
    	LOOP
          FETCH C_backward INTO ll_start_date;
     	  EXIT WHEN C_backward%NOTFOUND;
     	  EXIT WHEN C_backward%ROWCOUNT = l_rownum;
    	END LOOP;
    	CLOSE C_backward;
    elsif pa_fp_view_plans_pub.G_FP_PERIOD_TYPE = 'GL' then
	l_rownum := 5;
    	OPEN C_backward(ll_start_date);
    	LOOP
          FETCH C_backward INTO ll_start_date;
     	  EXIT WHEN C_backward%NOTFOUND;
     	  EXIT WHEN C_backward%ROWCOUNT = l_rownum;
    	END LOOP;
    	CLOSE C_backward;
    end if;
  end if;

   CLOSE C_forward;



 ELSIF p_direction = 'BACKWARD' THEN

       OPEN C_backward(l_start_date);

  LOOP
     FETCH C_backward INTO ll_start_date;
--hr_utility.trace('current ll_startdate= ' || to_char(ll_start_date));
     EXIT WHEN C_backward%NOTFOUND;
     EXIT WHEN C_backward%ROWCOUNT = l_rownum;

  END LOOP;

  CLOSE C_backward;

END IF;
 if ll_start_date is null then
   x_start_date := l_start_date;
 else
   x_start_date := to_char(ll_start_date);
 end if;
--hr_utility.trace('x_start_date= ' || x_start_date);
END pa_fp_set_periods_nav;


FUNCTION Get_Version_ID return NUMBER is
BEGIN
   return pa_fp_view_plans_pub.G_FP_VIEW_VERSION_ID;
END Get_Version_ID;

/* Added for bug 7514054 */
FUNCTION Get_Fp_Period_Type return VARCHAR2 is
BEGIN
    return pa_fp_view_plans_pub.G_FP_PERIOD_TYPE;
END Get_Fp_Period_Type;
/* Ends added for 7514054 */

FUNCTION Get_Cost_Version_Id return Number is
BEGIN
    return pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
END Get_Cost_Version_id;

FUNCTION Get_Rev_Version_Id return Number is
BEGIN
    return pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
END Get_Rev_Version_Id;

FUNCTION Get_Org_ID return NUMBER is
BEGIN
   return pa_fp_view_plans_pub.G_FP_ORG_ID;
END Get_Org_ID;

FUNCTION Get_Plan_Type_ID return NUMBER is
BEGIN
   return pa_fp_view_plans_pub.G_FP_PLAN_TYPE_ID;
END Get_Plan_Type_ID;

FUNCTION Get_Derive_Margin_From_Code return VARCHAR2 is
BEGIN
    return pa_fp_view_plans_pub.G_FP_CALC_MARGIN_FROM;
END Get_Derive_Margin_From_Code;

FUNCTION Get_Report_Labor_Hrs_From_Code return VARCHAR2 is
BEGIN
    return pa_fp_view_plans_pub.G_FP_CALC_QUANTITY_FROM;
END Get_Report_Labor_Hrs_From_Code;

FUNCTION Get_Resource_assignment_ID return NUMBER is
BEGIN
   return pa_fp_view_plans_pub.G_FP_RA_ID;
END Get_Resource_assignment_ID;

FUNCTION Get_Amount_Type_code return VARCHAR2 is
BEGIN
   return pa_fp_view_plans_pub.G_FP_AMOUNT_TYPE_CODE;
END Get_Amount_Type_code;

FUNCTION Get_Adj_Reason_Code return VARCHAR2 is
BEGIN
   return pa_fp_view_plans_pub.G_FP_ADJ_REASON_CODE;
END Get_Adj_Reason_Code;

FUNCTION Get_Uncat_Res_List_Member_Id return NUMBER is
BEGIN
   return pa_fp_view_plans_pub.G_UNCAT_RLM_ID;
END Get_Uncat_Res_List_Member_Id;

FUNCTION Get_Period_Start_Date1 return Date is
BEGIN
   return pa_fp_view_plans_pub.G_FP_VIEW_START_DATE1;
END Get_Period_Start_Date1;

FUNCTION Get_Period_Start_Date2 return Date is
BEGIN
   return pa_fp_view_plans_pub.G_FP_VIEW_START_DATE2;
END Get_Period_Start_Date2;

FUNCTION Get_Period_Start_Date3 return Date is
BEGIN
   return pa_fp_view_plans_pub.G_FP_VIEW_START_DATE3;
END Get_Period_Start_Date3;

FUNCTION Get_Period_Start_Date4 return Date is
BEGIN
   return pa_fp_view_plans_pub.G_FP_VIEW_START_DATE4;
END Get_Period_Start_Date4;

FUNCTION Get_Period_Start_Date5 return Date is
BEGIN
   return pa_fp_view_plans_pub.G_FP_VIEW_START_DATE5;
END Get_Period_Start_Date5;

FUNCTION Get_Period_Start_Date6 return Date is
BEGIN
   return pa_fp_view_plans_pub.G_FP_VIEW_START_DATE6;
END Get_Period_Start_Date6;

FUNCTION Get_Period_Start_Date7 return Date is
BEGIN
   return pa_fp_view_plans_pub.G_FP_VIEW_START_DATE7;
END Get_Period_Start_Date7;

FUNCTION Get_Period_Start_Date8 return Date is
BEGIN
   return pa_fp_view_plans_pub.G_FP_VIEW_START_DATE8;
END Get_Period_Start_Date8;

FUNCTION Get_Period_Start_Date9 return Date is
BEGIN
   return pa_fp_view_plans_pub.G_FP_VIEW_START_DATE9;
END Get_Period_Start_Date9;

FUNCTION Get_Period_Start_Date10 return Date is
BEGIN
   return pa_fp_view_plans_pub.G_FP_VIEW_START_DATE10;
END Get_Period_Start_Date10;

FUNCTION Get_Period_Start_Date11 return Date is
BEGIN
   return pa_fp_view_plans_pub.G_FP_VIEW_START_DATE11;
END Get_Period_Start_Date11;

FUNCTION Get_Period_Start_Date12 return Date is
BEGIN
   return pa_fp_view_plans_pub.G_FP_VIEW_START_DATE12;
END Get_Period_Start_Date12;


FUNCTION Get_Period_Start_Date13 return Date is
BEGIN
   return pa_fp_view_plans_pub.G_FP_VIEW_START_DATE13;
END Get_Period_Start_Date13;

FUNCTION Get_Plan_Start_Date return Date is
BEGIN
   return pa_fp_view_plans_pub.G_FP_PLAN_START_DATE;
END Get_Plan_Start_Date;

FUNCTION Get_Plan_End_Date return Date is
BEGIN
   return pa_fp_view_plans_pub.G_FP_PLAN_END_DATE;
END Get_Plan_End_Date;

FUNCTION Get_Prec_Pds_Flag return VARCHAR2 is
BEGIN
   return pa_fp_view_plans_pub.G_DISPLAY_FLAG_PREC;
END Get_Prec_Pds_Flag;

FUNCTION Get_Succ_Pds_Flag return VARCHAR2 is
BEGIN
   return pa_fp_view_plans_pub.G_DISPLAY_FLAG_SUCC;
END Get_Succ_Pds_Flag;

FUNCTION Get_Currency_Code return VARCHAR2 is
BEGIN
   return pa_fp_view_plans_pub.G_FP_CURRENCY_CODE;
END Get_Currency_Code;

FUNCTION Get_Currency_Type return VARCHAR2 is
BEGIN
  return pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE;
END Get_Currency_Type;

FUNCTION Get_Default_Amount_Type_Code return VARCHAR2 is
BEGIN
  return pa_fp_view_plans_pub.G_DEFAULT_AMOUNT_TYPE_CODE;
END Get_Default_Amount_Type_Code;

FUNCTION Get_Default_Amt_Subtype_Code return VARCHAR2 is
BEGIN
  return pa_fp_view_plans_pub.G_DEFAULT_AMT_SUBTYPE_CODE;
END Get_Default_Amt_Subtype_Code;

FUNCTION Get_Cost_Version_Number return NUMBER is
BEGIN
  return pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER;
END Get_Cost_Version_Number;

FUNCTION Get_Rev_Version_Number return NUMBER is
BEGIN
  return pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER;
END Get_Rev_Version_Number;

FUNCTION Get_All_Version_Number return NUMBER is
BEGIN
  return pa_fp_view_plans_pub.G_FP_ALL_VERSION_NUMBER;
END Get_All_Version_Number;

FUNCTION Get_Cost_Version_Name return VARCHAR2 is
BEGIN
  return pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME;
END Get_Cost_Version_Name;

FUNCTION Get_Rev_Version_Name return VARCHAR2 is
BEGIN
  return pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME;
END Get_Rev_Version_Name;

FUNCTION Get_All_Version_Name return VARCHAR2 is
BEGIN
  return pa_fp_view_plans_pub.G_FP_ALL_VERSION_NAME;
END Get_All_Version_Name;

FUNCTION Get_Period_Type return VARCHAR2 is
BEGIN
  return pa_fp_view_plans_pub.G_FP_PERIOD_TYPE;
END Get_Period_Type;

PROCEDURE Set_Cost_Version_Number (p_version_number	IN NUMBER) is
BEGIN
  pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := p_version_number;
END Set_Cost_Version_Number;

PROCEDURE Set_Rev_Version_Number (p_version_number	IN NUMBER) is
BEGIN
  pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := p_version_number;
END Set_Rev_Version_Number;

PROCEDURE Set_Cost_Version_Name (p_version_name	IN VARCHAR2) is
BEGIN
  pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME := p_version_name;
END Set_Cost_Version_Name;

PROCEDURE Set_Rev_Version_Name (p_version_name IN VARCHAR2) is
BEGIN
  pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := p_version_name;
END Set_Rev_Version_Name;


/* ------------------------------------------------------------------ */
-- Procedure view_plan_temp_tables is the top-level procedure call for
-- populating the global temporary tables (periodic and non-periodic).
-- FIRST, check value of p_user_bv_flag:
--	if Y, then user selected the budget versions(s) to be displayed
--	if N, then user did NOT select the budget version, and we do the following:
-- Global temporary tables are populated according to the following logic:
-- If FIN_PLAN_PREFERENCE_CODE is
-- 	'COST_AND_REV_SAME': the BV contains both cost and revenue numbers,
--	  so call pa_fp_vp_pop_tables_together
--	'COST_ONLY': only process the Cost version: pa_fp_vp_pop_tables_single
--	'REVENUE_ONLY': only process the Rev version: pa_fp_vp_pop_tables_single
--	'COST_AND_REV_SEP':
--	  IF complementary BV found and period profiles compatible, then
--	  pa_fp_vp_pop_tables_separate
--	  ELSE pa_fp_vp_pop_tables_single using the single BV
-- 11/22/02: out parameter: x_diff_pd_profile_flag -> 'Y' when don't match
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
     x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     )
as

l_fin_plan_type_id	pa_budget_versions.fin_plan_type_id%TYPE;

cursor l_ra_csr is
    select * from pa_resource_assignments where budget_version_id=p_budget_version_id;
l_ra_rec l_ra_csr%ROWTYPE;

-- the following four cursors are used to find a complementary plan
-- version if our version is 'COST_ONLY' or 'REVENUE_ONLY'
-- ie. "l_compl_r_w_csr" means that our version is a working revenue version
/*
cursor l_compl_c_w_csr is
    select bv.budget_version_id,
           po.proj_fp_options_id
      from pa_proj_fp_options po,
           pa_budget_versions bv
      where po.project_id = p_project_id and
            po.fin_plan_type_id = l_fin_plan_type_id and -- same plan type
            po.fin_plan_preference_code = 'REVENUE_ONLY' and
            po.fin_plan_option_level_code = 'PLAN_VERSION' and
            po.fin_plan_version_id = bv.budget_version_id and
            bv.current_working_flag = 'Y';
l_compl_c_w_rec l_compl_c_w_csr%ROWTYPE;

cursor l_compl_c_b_csr is
    select bv.budget_version_id,
           po.proj_fp_options_id
      from pa_proj_fp_options po,
           pa_budget_versions bv
      where po.project_id = p_project_id and
            po.fin_plan_type_id = l_fin_plan_type_id and -- same plan type
            po.fin_plan_preference_code = 'REVENUE_ONLY' and
            po.fin_plan_option_level_code = 'PLAN_VERSION' and
            po.fin_plan_version_id = bv.budget_version_id and
            bv.current_flag = 'Y';
l_compl_c_b_rec l_compl_c_b_csr%ROWTYPE;

cursor l_compl_r_w_csr is
    select bv.budget_version_id,
           po.proj_fp_options_id
      from pa_proj_fp_options po,
           pa_budget_versions bv
      where po.project_id = p_project_id and
            po.fin_plan_type_id = l_fin_plan_type_id and -- same plan type
            po.fin_plan_preference_code = 'COST_ONLY' and
            po.fin_plan_option_level_code = 'PLAN_VERSION' and
            po.fin_plan_version_id = bv.budget_version_id and
            bv.current_working_flag = 'Y';
l_compl_r_w_rec l_compl_r_w_csr%ROWTYPE;

cursor l_compl_r_b_csr is
    select bv.budget_version_id,
           po.proj_fp_options_id
      from pa_proj_fp_options po,
           pa_budget_versions bv
      where po.project_id = p_project_id and
            po.fin_plan_type_id = l_fin_plan_type_id and -- same plan type
            po.fin_plan_preference_code = 'COST_ONLY' and
            po.fin_plan_option_level_code = 'PLAN_VERSION' and
            po.fin_plan_version_id = bv.budget_version_id and
            bv.current_flag = 'Y';
l_compl_r_b_rec l_compl_r_b_csr%ROWTYPE;
*/
cursor l_compl_crsep_c_w_csr is
    select bv.budget_version_id,
           po.proj_fp_options_id
      from pa_proj_fp_options po,
           pa_budget_versions bv
      where po.project_id = p_project_id and
            po.fin_plan_type_id = l_fin_plan_type_id and -- same plan type
--            po.fin_plan_preference_code = 'COST_AND_REV_SEP' and
            po.fin_plan_option_level_code = 'PLAN_VERSION' and
            po.fin_plan_version_id = bv.budget_version_id and
            bv.version_type = 'REVENUE' and
            bv.current_working_flag = 'Y';
l_compl_crsep_c_w_rec l_compl_crsep_c_w_csr%ROWTYPE;

cursor l_compl_crsep_r_w_csr is
    select bv.budget_version_id,
           po.proj_fp_options_id
      from pa_proj_fp_options po,
           pa_budget_versions bv
      where po.project_id = p_project_id and
            po.fin_plan_type_id = l_fin_plan_type_id and -- same plan type
--            po.fin_plan_preference_code = 'COST_AND_REV_SEP' and
            po.fin_plan_option_level_code = 'PLAN_VERSION' and
            po.fin_plan_version_id = bv.budget_version_id and
            bv.version_type = 'COST' and
            bv.current_working_flag = 'Y';
l_compl_crsep_r_w_rec l_compl_crsep_r_w_csr%ROWTYPE;

-- the following four cursors are used to find a complementary plan
-- version if our version is 'COST_AND_REV_SEP'
-- ie. "l_compl_crsep_c_b_csr" means that our version is a baselined cost version
cursor l_compl_crsep_c_b_csr is
    select bv.budget_version_id,
           po.proj_fp_options_id
      from pa_proj_fp_options po,
           pa_budget_versions bv
      where po.project_id = p_project_id and
            po.fin_plan_type_id = l_fin_plan_type_id and -- same plan type
--            po.fin_plan_preference_code = 'COST_AND_REV_SEP' and
            po.fin_plan_option_level_code = 'PLAN_VERSION' and
            po.fin_plan_version_id = bv.budget_version_id and
            bv.version_type = 'REVENUE' and
            bv.current_flag = 'Y';
l_compl_crsep_c_b_rec l_compl_crsep_c_b_csr%ROWTYPE;

cursor l_compl_crsep_r_b_csr is
     select bv.budget_version_id,
            po.proj_fp_options_id
       from pa_proj_fp_options po,
            pa_budget_versions bv
       where po.project_id = p_project_id and
             po.fin_plan_type_id = l_fin_plan_type_id and -- same plan type
--             po.fin_plan_preference_code = 'COST_AND_REV_SEP' and
             po.fin_plan_option_level_code = 'PLAN_VERSION' and
             po.fin_plan_version_id = bv.budget_version_id and
             bv.version_type = 'COST' and
             bv.current_flag = 'Y';
l_compl_crsep_r_b_rec l_compl_crsep_r_b_csr%ROWTYPE;

l_fp_preference_code          pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_working_or_baselined	      VARCHAR2(1);
l_compl_budget_version_id     pa_budget_versions.budget_version_id%TYPE;
l_compl_proj_fp_options_id    pa_proj_fp_options.proj_fp_options_id%TYPE;
l_compl_plan_level_code       pa_proj_fp_options.cost_fin_plan_level_code%TYPE;
l_period_profile_id1	      pa_proj_period_profiles.period_profile_id%TYPE;
l_period_profile_id2	      pa_proj_period_profiles.period_profile_id%TYPE;
l_cost_version_number         pa_budget_versions.version_number%TYPE;
l_rev_version_number          pa_budget_versions.version_number%TYPE;
l_cost_version_name           pa_budget_versions.version_name%TYPE;
l_rev_version_name            pa_budget_versions.version_name%TYPE;
l_diff_pd_profile_flag	      VARCHAR2(1);

-- values used to populate temp table
l_element_name      VARCHAR2(1000);

-- for Advanced Display Options customization
l_primary_bvid		     pa_budget_versions.budget_version_id%TYPE;

-- error handling variables
l_return_status		VARCHAR2(1);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(80);

begin
  pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '100: entered procedure', 2);
--hr_utility.trace_on(null, 'dlai');
--hr_utility.trace('entered view_plan_temp_tables');
--hr_utility.trace('p_budget_version_id= ' || TO_CHAR(p_budget_version_id));
  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT VIEW_PLAN_TEMP_TABLES;
  l_diff_pd_profile_flag := 'N';

  -- FOR ADVANCED DISPLAY OPTIONS CUSTOMIZATION: USER-SELECTED BUDGET VERSIONS
  -- order of checking: ALL, COST, REVENUE
  if p_user_bv_flag = 'Y' then
--hr_utility.trace('p_user_bv_flag = Y');
	-- assume that the BV_ID variables have already been set
	if pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID is not null then
	  l_primary_bvid := pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID;
	elsif pa_fp_view_plans_pub.G_FP_COST_VERSION_ID is not null then
	  l_primary_bvid := pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
	else
	  l_primary_bvid := pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
	end if;
--hr_utility.trace('allversionid= ' || to_char(pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID));
--hr_utility.trace('COSTversionid= ' || to_char(pa_fp_view_plans_pub.G_FP_COST_VERSION_ID));
--hr_utility.trace('REVversionid= ' || to_char(pa_fp_view_plans_pub.G_FP_REV_VERSION_ID));

--hr_utility.trace('selecting from pa_budget_versions');
	select DECODE(budget_status_code,
		      'B', 'B',
		      'W'),
	       fin_plan_type_id
    	  into l_working_or_baselined,
	       l_fin_plan_type_id
    	  from pa_budget_versions
    	  where budget_version_id = p_budget_version_id;
  	-- retrieve fin_plan_preference_code from PLAN_TYPE record
  	select fin_plan_preference_code
    	  into l_fp_preference_code
    	  from pa_proj_fp_options
    	  where fin_plan_type_id = l_fin_plan_type_id and
                                   fin_plan_option_level_code = 'PLAN_TYPE' and
	  			   project_id = p_project_id;

	-- figure out display_from:
	if l_fp_preference_code = 'COST_AND_REV_SAME' then
--hr_utility.trace('user_specified: COST_AND_REV_SAME');
	  pa_fp_view_plans_pub.G_DISPLAY_FROM := 'ANY';
	  if pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID is null then
	    if pa_fp_view_plans_pub.G_FP_COST_VERSION_ID is not null then
	      pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID := pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
	    else
	      pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID := pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
	    end if;
	  end if;
  	  select version_name,
                 version_number
    	    into l_cost_version_name,
                 l_cost_version_number
    	    from pa_budget_versions
    	    where budget_version_id = p_budget_version_id;
  	  l_rev_version_name := l_cost_version_name;
  	  l_rev_version_number := l_cost_version_number;
	  pa_fp_view_plans_pub.G_FP_ALL_VERSION_NAME := l_cost_version_name;
	  pa_fp_view_plans_pub.G_FP_ALL_VERSION_NUMBER := l_cost_version_number;
	  pa_fp_view_plans_pub.pa_fp_vp_pop_tables_together
        	(p_project_id        => p_project_id,
         	 p_budget_version_id => pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID,
	 	 x_return_status     => l_return_status,
         	 x_msg_count         => l_msg_count,
         	 x_msg_data          => l_msg_data);

	elsif l_fp_preference_code = 'COST_ONLY' then
--hr_utility.trace('user_specified: COST_ONLY');
	  pa_fp_view_plans_pub.G_DISPLAY_FROM := 'COST';
	  select version_number,
           	 version_name
      	    into l_cost_version_number,
                 l_cost_version_name
      	    from pa_budget_versions
      	    where budget_version_id = p_budget_version_id;
    	  l_rev_version_number := null;
    	  l_rev_version_name := ' ';
	  pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := l_cost_version_number;
	  pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME := l_cost_version_name;
          pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
  	        (p_project_id           => p_project_id,
        	 p_budget_version_id    => pa_fp_view_plans_pub.G_FP_COST_VERSION_ID,
                 p_cost_or_rev          => 'C',
	         x_return_status        => l_return_status,
                 x_msg_count            => l_msg_count,
                 x_msg_data             => l_msg_data);

	elsif l_fp_preference_code = 'REVENUE_ONLY' then
--hr_utility.trace('user_specified: REVENUE_ONLY');
	  pa_fp_view_plans_pub.G_DISPLAY_FROM := 'REVENUE';
    	  select version_number,
          	 version_name
      	    into l_rev_version_number,
           	 l_rev_version_name
      	    from pa_budget_versions
      	    where budget_version_id = p_budget_version_id;
    	  l_cost_version_number := null;
    	  l_cost_version_name := ' ';
	  pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := l_rev_version_name;
	  pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := l_rev_version_number;
          pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
  	        (p_project_id           => p_project_id,
        	 p_budget_version_id    => pa_fp_view_plans_pub.G_FP_REV_VERSION_ID,
                 p_cost_or_rev          => 'R',
	         x_return_status        => l_return_status,
                 x_msg_count            => l_msg_count,
                 x_msg_data             => l_msg_data);

	else
--hr_utility.trace('user_specified: COST_AND_REV_SEP');
	  if (pa_fp_view_plans_pub.G_FP_COST_VERSION_ID is not null) and
	     (pa_fp_view_plans_pub.G_FP_REV_VERSION_ID is not null) then

	-- BEFORE MERGING, MAKE SURE PERIOD PROFILES MATCH
 	    select period_profile_id
	      into l_period_profile_id1
	      from pa_budget_versions
	      where budget_version_id = pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
	    select period_profile_id
	      into l_period_profile_id2
	      from pa_budget_versions
	      where budget_version_id = pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
--hr_utility.trace('retrieved the period profile ids');
	    if (pa_fp_view_plans_util.check_compatible_pd_profiles
		  (p_period_profile_id1	=> l_period_profile_id1,
		   p_period_profile_id2	=> l_period_profile_id2) = 'Y') or
	       not (pa_fp_view_plans_pub.G_AMT_OR_PD = 'P') then
--hr_utility.trace('user_specified: period_profile matches');
	   -- PERIOD PROFILES MATCH: GO AHEAD WITH MERGING
	      pa_fp_view_plans_pub.G_DISPLAY_FROM := 'BOTH';
              select version_number,
                     version_name
                into l_cost_version_number,
                     l_cost_version_name
                from pa_budget_versions
                where budget_version_id = pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
	      pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := l_cost_version_number;
	      pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME := l_cost_version_name;
              select version_number,
                     version_name
                into l_rev_version_number,
                     l_rev_version_name
                from pa_budget_versions
                where budget_version_id = pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
	      pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := l_rev_version_number;
	      pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := l_rev_version_name;
--hr_utility.trace('entering pa_fp_vp_pop_tables_separate');
              pa_fp_view_plans_pub.pa_fp_vp_pop_tables_separate
                  (p_project_id               => p_project_id,
                   p_cost_budget_version_id   => pa_fp_view_plans_pub.G_FP_COST_VERSION_ID,
                   p_rev_budget_version_id    => pa_fp_view_plans_pub.G_FP_REV_VERSION_ID,
	           x_return_status            => l_return_status,
                   x_msg_count                => l_msg_count,
                   x_msg_data                 => l_msg_data);
--hr_utility.trace('exiting pa_fp_vp_pop_tables_separate');
	    else
	   -- PERIOD PROFILES DO NOT MATCH: ERROR MESSAGE
--hr_utility.trace('user-defined bvs: merge failed because mismatch pd profiles');
	      l_diff_pd_profile_flag := 'Y';
	      pa_fp_view_plans_pub.G_DISPLAY_FROM := 'BOTH';
              select version_number,
                     version_name
                into l_cost_version_number,
                     l_cost_version_name
                from pa_budget_versions
                where budget_version_id = pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
	      pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := l_cost_version_number;
	      pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME := l_cost_version_name;
              select version_number,
                     version_name
                into l_rev_version_number,
                     l_rev_version_name
                from pa_budget_versions
                where budget_version_id = pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
	      pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := l_rev_version_number;
	      pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := l_rev_version_name;
              pa_fp_view_plans_pub.pa_fp_vp_pop_tables_separate
                  (p_project_id               => p_project_id,
                   p_cost_budget_version_id   => pa_fp_view_plans_pub.G_FP_COST_VERSION_ID,
                   p_rev_budget_version_id    => pa_fp_view_plans_pub.G_FP_REV_VERSION_ID,
	           x_return_status            => l_return_status,
                   x_msg_count                => l_msg_count,
                   x_msg_data                 => l_msg_data);
	    end if;
	  else
	      if pa_fp_view_plans_pub.G_FP_COST_VERSION_ID is not null then
		pa_fp_view_plans_pub.G_DISPLAY_FROM := 'COST';
	  	select version_number,
           		version_name
      	    	  into l_cost_version_number,
                 	l_cost_version_name
      	    	  from pa_budget_versions
      	    	  where budget_version_id = pa_fp_view_plans_pub.G_FP_COST_VERSION_ID;
    	  	l_rev_version_number := null;
    	  	l_rev_version_name := ' ';
		pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME := l_cost_version_name;
		pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := l_cost_version_number;
	          pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
  		        (p_project_id           => p_project_id,
        		 p_budget_version_id    => pa_fp_view_plans_pub.G_FP_COST_VERSION_ID,
                 	p_cost_or_rev          => 'C',
	         	x_return_status        => l_return_status,
                 	x_msg_count            => l_msg_count,
                 	x_msg_data             => l_msg_data);

		else
		  pa_fp_view_plans_pub.G_DISPLAY_FROM := 'REVENUE';
    	  	   select version_number,
          	 	  version_name
      	    	    into l_rev_version_number,
           	 	  l_rev_version_name
      	    	    from pa_budget_versions
      	    	    where budget_version_id = pa_fp_view_plans_pub.G_FP_REV_VERSION_ID;
    	  	  l_cost_version_number := null;
    	  	  l_cost_version_name := ' ';
		  pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := l_rev_version_number;
		  pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := l_rev_version_name;
	          pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
  	        	(p_project_id           => p_project_id,
        	 	 p_budget_version_id    => pa_fp_view_plans_pub.G_FP_REV_VERSION_ID,
                 	 p_cost_or_rev          => 'R',
	         	 x_return_status        => l_return_status,
                 	 x_msg_count            => l_msg_count,
                 	 x_msg_data             => l_msg_data);
		end if;
	  end if; -- both versions not null
	end if; -- l_fp_preference_code

-- USER DID NOT SPECIFY ANY BUDGET VERSIONS; PROCEED AS NORMAL
  else
    --hr_utility.trace('USER DID NOT SPECIFY ANY BUDGET VERSIONS: 1000');

  select DECODE(budget_status_code,
		'B', 'B',
		'W'),
	 fin_plan_type_id
    into l_working_or_baselined,
	 l_fin_plan_type_id
    from pa_budget_versions
    where budget_version_id = p_budget_version_id;
  -- retrieve fin_plan_preference_code from PLAN_TYPE record
  select fin_plan_preference_code
    into l_fp_preference_code
    from pa_proj_fp_options
    where fin_plan_type_id = l_fin_plan_type_id and
          fin_plan_option_level_code = 'PLAN_TYPE' and
	  project_id = p_project_id;

  -- if the preference code is 'COST_AND_REV_SAME', then we only need this one version
  -- we blindly insert all rows for the budget version into the temp table
  if l_fp_preference_code = 'COST_AND_REV_SAME' then
    pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '200: pref = COST_AND_REV_SAME', 1);
  --hr_utility.trace('COST_AND_REV_SAME');
  pa_fp_view_plans_pub.G_DISPLAY_FROM := 'ANY';
  select version_name,
         version_number
    into l_cost_version_name,
         l_cost_version_number
    from pa_budget_versions
    where budget_version_id = p_budget_version_id;
  l_rev_version_name := l_cost_version_name;
  l_rev_version_number := l_cost_version_number;
  pa_fp_view_plans_pub.G_FP_ALL_VERSION_ID := p_budget_version_id;
  pa_fp_view_plans_pub.G_FP_ALL_VERSION_NAME := l_cost_version_name;
  pa_fp_view_plans_pub.G_FP_ALL_VERSION_NUMBER := l_cost_version_number;
    pa_fp_view_plans_pub.pa_fp_vp_pop_tables_together
        (p_project_id        => p_project_id,
         p_budget_version_id => p_budget_version_id,
	 x_return_status     => l_return_status,
         x_msg_count         => l_msg_count,
         x_msg_data          => l_msg_data);

  -- if the preference code is 'COST_ONLY', then we have the bvID of the COST version
  -- and we don't have to do anything else
  elsif l_fp_preference_code = 'COST_ONLY' then
    pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '300: pref=COST_ONLY', 1);
    --hr_utility.trace('COST_ONLY');
    pa_fp_view_plans_pub.G_DISPLAY_FROM := 'COST';
    select version_number,
           version_name
      into l_cost_version_number,
           l_cost_version_name
      from pa_budget_versions
      where budget_version_id = p_budget_version_id;
    l_rev_version_number := null;
    l_rev_version_name := ' ';
    pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := p_budget_version_id;
    pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME := l_cost_version_name;
    pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := l_cost_version_number;
    pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
            (p_project_id		=> p_project_id,
	     p_budget_version_id	=> p_budget_version_id,
	     p_cost_or_rev		=> 'C',
	     x_return_status            => l_return_status,
             x_msg_count                => l_msg_count,
             x_msg_data                 => l_msg_data);

  elsif l_fp_preference_code = 'REVENUE_ONLY' then
    pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '400: pref=REVENUE_ONLY', 1);
    --hr_utility.trace('REVENUE_ONLY');
    pa_fp_view_plans_pub.G_DISPLAY_FROM := 'REVENUE';
    select version_number,
           version_name
      into l_rev_version_number,
           l_rev_version_name
      from pa_budget_versions
      where budget_version_id = p_budget_version_id;
    l_cost_version_number := null;
    l_cost_version_name := ' ';
    pa_fp_view_plans_pub.G_FP_REV_VERSION_ID := p_budget_version_id;
    pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := l_rev_version_name;
    pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := l_rev_version_number;
    pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
	    (p_project_id		=> p_project_id,
	     p_budget_version_id	=> p_budget_version_id,
	     p_cost_or_rev		=> 'R',
	     x_return_status            => l_return_status,
             x_msg_count                => l_msg_count,
             x_msg_data                 => l_msg_data);


  -- if preference_code is 'COST_AND_REV_SEP' we look for the other one
  -- the other one will also have preference_code  = 'COST_AND_REV_SEP', and we will
  -- have to inspect bv.version_type (which can be 'COST', 'REVENUE', etc)
  else
    -- find the appropriate current working version
    pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '400: pref=COST_AND_REV_SEP', 1);
    --hr_utility.trace('COST_AND_REV_SEP');
    if l_working_or_baselined = 'W' then
      -- determine whether we have the COST or REVENUE version, and look for the other one
      if p_cost_or_revenue = 'C' then
        pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '500: pref=COST_AND_REV_SEP, WORKING, COST', 2);
        --hr_utility.trace('we have a working cost version');
        -- we have the COST version, so look for REVENUE version with 'COST_AND_REV_SEP'
        open l_compl_crsep_c_w_csr;
        fetch l_compl_crsep_c_w_csr into l_compl_crsep_c_w_rec;
        if l_compl_crsep_c_w_csr%NOTFOUND then
          l_compl_budget_version_id := -99;
          l_compl_proj_fp_options_id := -99;
        else
          l_compl_budget_version_id := l_compl_crsep_c_w_rec.budget_version_id;
          l_compl_proj_fp_options_id := l_compl_crsep_c_w_rec.proj_fp_options_id;
        end if; -- l_compl_crsep_c_w_csr: no data found
        close l_compl_crsep_c_w_csr;
        if l_compl_budget_version_id = -99 then
          -- did not find a compl for the COST version; just process COST version
          pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '600: pref=COST_AND_REV_SEP, WORKING, COST - did not find complement', 1);
          --hr_utility.trace('could NOT find complement for working cost version');
	  pa_fp_view_plans_pub.G_DISPLAY_FROM := 'COST';
          select version_number,
                 version_name
            into l_cost_version_number,
                 l_cost_version_name
            from pa_budget_versions
            where budget_version_id = p_budget_version_id;
          l_rev_version_number := null;
          l_rev_version_name := ' ';
	  pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := p_budget_version_id;
	  pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME := l_cost_version_name;
	  pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := l_cost_version_number;
          pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
              (p_project_id           => p_project_id,
               p_budget_version_id    => p_budget_version_id,
               p_cost_or_rev          => 'C',
	       x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);
        else
          -- found a compl for the COST version: merge only if period profiles are compatible
	  select period_profile_id
	    into l_period_profile_id1
	    from pa_budget_versions
	    where budget_version_id = p_budget_version_id;
	  select period_profile_id
	    into l_period_profile_id2
	    from pa_budget_versions
	    where budget_version_id = l_compl_budget_version_id;
	  if (pa_fp_view_plans_util.check_compatible_pd_profiles
		(p_period_profile_id1	=> l_period_profile_id1,
		 p_period_profile_id2	=> l_period_profile_id2) = 'Y') or
	     not (pa_fp_view_plans_pub.G_AMT_OR_PD = 'P') then
	    --merge the COST and REVENUE versions
            pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '700: pref=COST_AND_REV_SEP, WORKING, COST - found complement,and passed period profile check', 1);
	    --hr_utility.trace('found complement for working cost version AND period profile match');
	    pa_fp_view_plans_pub.G_DISPLAY_FROM := 'BOTH';
            select version_number,
                   version_name
              into l_cost_version_number,
                   l_cost_version_name
              from pa_budget_versions
              where budget_version_id = p_budget_version_id;
            select version_number,
                   version_name
              into l_rev_version_number,
                   l_rev_version_name
              from pa_budget_versions
              where budget_version_id = l_compl_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := p_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := l_cost_version_number;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME	:= l_cost_version_name;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_ID := l_compl_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := l_rev_version_name;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := l_rev_version_number;
            pa_fp_view_plans_pub.pa_fp_vp_pop_tables_separate
                (p_project_id               => p_project_id,
                 p_cost_budget_version_id   => p_budget_version_id,
                 p_rev_budget_version_id    => l_compl_budget_version_id,
	         x_return_status            => l_return_status,
                 x_msg_count                => l_msg_count,
                 x_msg_data                 => l_msg_data);
	  else
	    -- the period profiles didn't match: only process one of the versions
            pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '800: pref=COST_AND_REV_SEP, WORKING, COST - found complement,BUT did not pass period profile check', 1);
	    --hr_utility.trace('found complement for working cost version BUT no per profile match');
	    l_diff_pd_profile_flag := 'Y';

	    pa_fp_view_plans_pub.G_DISPLAY_FROM := 'COST';
            select version_number,
                   version_name
              into l_cost_version_number,
                   l_cost_version_name
              from pa_budget_versions
              where budget_version_id = p_budget_version_id;
            l_rev_version_number := null;
            l_rev_version_name := ' ';
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := p_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME := l_cost_version_name;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := l_cost_version_number;
            pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
              (p_project_id           => p_project_id,
               p_budget_version_id    => p_budget_version_id,
               p_cost_or_rev          => 'C',
	       x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);

/* -- INCOMPATIBLE PERIOD PROFILES: WORKING COST ---
 * ERROR MESSAGE HANDLING HERE
	    pa_fp_view_plans_pub.G_DISPLAY_FROM := 'COST';
            select version_number,
                   version_name
              into l_cost_version_number,
                   l_cost_version_name
              from pa_budget_versions
              where budget_version_id = p_budget_version_id;
            l_rev_version_number := null;
            l_rev_version_name := ' ';
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME := l_cost_version_name;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := l_cost_version_number;
	    pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
              (p_project_id           => p_project_id,
               p_budget_version_id    => p_budget_version_id,
               p_cost_or_rev          => 'C',
	       x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);
*/
	  end if;
        end if; -- l_compl_budget_version_id is null
      else
        -- we have the REVENUE version, so look for COST version with 'COST_AND_REV_SEP'
        pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '900: pref=COST_AND_REV_SEP, WORKING, REVENUE', 1);
        --hr_utility.trace('we have a working revenue version');
        open l_compl_crsep_r_w_csr;
        fetch l_compl_crsep_r_w_csr into l_compl_crsep_r_w_rec;
        if l_compl_crsep_r_w_csr%NOTFOUND then
          l_compl_budget_version_id := -99;
          l_compl_proj_fp_options_id := -99;
        else
          l_compl_budget_version_id := l_compl_crsep_r_w_rec.budget_version_id;
          l_compl_proj_fp_options_id := l_compl_crsep_r_w_rec.proj_fp_options_id;
        end if; --l_compl_crsep_r_w_csr: no data found
        close l_compl_crsep_r_w_csr;
        if l_compl_budget_version_id = -99 then
          -- did not find a compl for the REVENUE version; just process REVENUE version
          pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '1000: pref=COST_AND_REV_SEP, WORKING, REVENUE - did not find complement', 1);
        --hr_utility.trace('could not find complement for working revenue version');
	  pa_fp_view_plans_pub.G_DISPLAY_FROM := 'REVENUE';
          select version_number,
                 version_name
            into l_rev_version_number,
                 l_rev_version_name
            from pa_budget_versions
            where budget_version_id = p_budget_version_id;
          l_cost_version_number := null;
          l_cost_version_name := ' ';
	  pa_fp_view_plans_pub.G_FP_REV_VERSION_ID := p_budget_version_id;
	  pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := l_rev_version_name;
	  pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := l_rev_version_number;
          pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
              (p_project_id           => p_project_id,
               p_budget_version_id    => p_budget_version_id,
               p_cost_or_rev          => 'R',
	       x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);
        else
          -- found a compl for the REVENUE version; merge only if period profiles are compatible
	  select period_profile_id
	    into l_period_profile_id1
	    from pa_budget_versions
	    where budget_version_id = p_budget_version_id;
	  select period_profile_id
	    into l_period_profile_id2
	    from pa_budget_versions
	    where budget_version_id = l_compl_budget_version_id;
	  if (pa_fp_view_plans_util.check_compatible_pd_profiles
		(p_period_profile_id1	=> l_period_profile_id1,
		 p_period_profile_id2	=> l_period_profile_id2) = 'Y') or
	     not (pa_fp_view_plans_pub.G_AMT_OR_PD = 'P') then
	    --merge the COST and REVENUE versions
            pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '1100: pref=COST_AND_REV_SEP, WORKING, REVENUE - found complement, and passed period profiles test', 1);
            --hr_utility.trace('found compl for working revenue version AND period profile match');
	    pa_fp_view_plans_pub.G_DISPLAY_FROM := 'BOTH';
            select version_number,
                   version_name
              into l_rev_version_number,
                   l_rev_version_name
              from pa_budget_versions
              where budget_version_id = p_budget_version_id;
            select version_number,
                   version_name
              into l_cost_version_number,
                   l_cost_version_name
              from pa_budget_versions
              where budget_version_id = l_compl_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := l_compl_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := l_cost_version_number;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME	:= l_cost_version_name;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_ID := p_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := l_rev_version_name;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := l_rev_version_number;
            pa_fp_view_plans_pub.pa_fp_vp_pop_tables_separate
                (p_project_id               => p_project_id,
                 p_cost_budget_version_id   => l_compl_budget_version_id,
                 p_rev_budget_version_id    => p_budget_version_id,
	         x_return_status            => l_return_status,
                 x_msg_count                => l_msg_count,
                 x_msg_data                 => l_msg_data);
	  else
	    -- the period profiles didn't match: only process one of the versions
            pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '1200: pref=COST_AND_REV_SEP, WORKING, REVENUE - found complement, BUT did not pass period profiles test', 1);
            --hr_utility.trace('found compl for working revenue version BUT no per profile match');
	    l_diff_pd_profile_flag := 'Y';
	    pa_fp_view_plans_pub.G_DISPLAY_FROM := 'REVENUE';
            select version_number,
                   version_name
              into l_rev_version_number,
                   l_rev_version_name
              from pa_budget_versions
              where budget_version_id = p_budget_version_id;
            l_cost_version_number := null;
            l_cost_version_name := ' ';
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_ID := p_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := l_rev_version_name;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := l_rev_version_number;
            pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
              (p_project_id           => p_project_id,
               p_budget_version_id    => p_budget_version_id,
               p_cost_or_rev          => 'R',
	       x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);
/* -- INCOMPATIBLE PERIOD PROFILES: WORKING COST ---
 * ERROR MESSAGE HANDLING HERE
	    pa_fp_view_plans_pub.G_DISPLAY_FROM := 'REVENUE';
            select version_number,
                   version_name
              into l_rev_version_number,
                   l_rev_version_name
              from pa_budget_versions
              where budget_version_id = p_budget_version_id;
            l_cost_version_number := null;
            l_cost_version_name := ' ';
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := l_rev_version_name;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := l_rev_version_number;
	    pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
              (p_project_id           => p_project_id,
               p_budget_version_id    => p_budget_version_id,
               p_cost_or_rev          => 'R',
	       x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);
*/
	  end if;
        end if; -- l_compl_budget_version_id is null
      end if; -- p_cost_or_revenue = 'C'

    -- find the appropriate current baselined version
    else
      -- determine whether we have the COST or REVENUE version, and look for the other one
      if p_cost_or_revenue = 'C' then
        -- we have the COST version, so look for REVENUE version with 'COST_AND_REV_SEP'
        pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '1300: pref=COST_AND_REV_SEP, BASELINED, COST', 1);
        --hr_utility.trace('we have a baselined cost version');
        open l_compl_crsep_c_b_csr;
        fetch l_compl_crsep_c_b_csr into l_compl_crsep_c_b_rec;
        if l_compl_crsep_c_b_csr%NOTFOUND then
          l_compl_budget_version_id := -99;
          l_compl_proj_fp_options_id := -99;
        else
          l_compl_budget_version_id := l_compl_crsep_c_b_rec.budget_version_id;
          l_compl_proj_fp_options_id := l_compl_crsep_c_b_rec.proj_fp_options_id;
        end if; -- l_compl_crsep_c_b_csr: no data found
        close l_compl_crsep_c_b_csr;
        if l_compl_budget_version_id = -99 then
          -- did not find a compl for the COST version; just process COST version
          pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '1400: pref=COST_AND_REV_SEP, BASELINED, COST - did not find complement', 1);
	  --hr_utility.trace('could not find complement for baselined cost version');
	  pa_fp_view_plans_pub.G_DISPLAY_FROM := 'COST';
          select version_number,
                 version_name
              into l_cost_version_number,
                   l_cost_version_name
              from pa_budget_versions
              where budget_version_id = p_budget_version_id;
          l_rev_version_number := null;
          l_rev_version_name := ' ';
	  pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := p_budget_version_id;
	  pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME := l_cost_version_name;
	  pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := l_cost_version_number;
          pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
              (p_project_id           => p_project_id,
               p_budget_version_id    => p_budget_version_id,
               p_cost_or_rev          => 'C',
	       x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);
        else
          -- found a compl for the COST version; merge only if period profiles are compatible
	  select period_profile_id
	    into l_period_profile_id1
	    from pa_budget_versions
	    where budget_version_id = p_budget_version_id;
	  select period_profile_id
	    into l_period_profile_id2
	    from pa_budget_versions
	    where budget_version_id = l_compl_budget_version_id;
	  if (pa_fp_view_plans_util.check_compatible_pd_profiles
		(p_period_profile_id1	=> l_period_profile_id1,
		 p_period_profile_id2	=> l_period_profile_id2) = 'Y') or
	     not (pa_fp_view_plans_pub.G_AMT_OR_PD = 'P') then
	    --merge the COST and REVENUE versions
            pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '1500: pref=COST_AND_REV_SEP, BASELINED, COST - found complement, and passed period profiles test', 1);
	    --hr_utility.trace('found compl for baselined cost AND period profile match');
	    pa_fp_view_plans_pub.G_DISPLAY_FROM := 'BOTH';
            select version_number,
                   version_name
              into l_cost_version_number,
                   l_cost_version_name
              from pa_budget_versions
              where budget_version_id = p_budget_version_id;
            select version_number,
                   version_name
              into l_rev_version_number,
                   l_rev_version_name
              from pa_budget_versions
              where budget_version_id = l_compl_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := p_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := l_cost_version_number;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME	 := l_cost_version_name;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_ID := l_compl_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := l_rev_version_name;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := l_rev_version_number;
            pa_fp_view_plans_pub.pa_fp_vp_pop_tables_separate
                (p_project_id               => p_project_id,
                 p_cost_budget_version_id   => p_budget_version_id,
                 p_rev_budget_version_id    => l_compl_budget_version_id,
	         x_return_status            => l_return_status,
                 x_msg_count                => l_msg_count,
                 x_msg_data                 => l_msg_data);
          else
            -- period_profiles don't match; process only the COST version
            pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '1600: pref=COST_AND_REV_SEP, BASELINED, COST - found complement, BUT did not pass period profiles test', 1);
	    --hr_utility.trace('found compl for baselined cost BUT no period profile match');
	    l_diff_pd_profile_flag := 'Y';
	    pa_fp_view_plans_pub.G_DISPLAY_FROM := 'COST';
            select version_number,
                   version_name
                into l_cost_version_number,
                     l_cost_version_name
                from pa_budget_versions
                where budget_version_id = p_budget_version_id;
            l_rev_version_number := null;
            l_rev_version_name := ' ';
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := p_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME := l_cost_version_name;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := l_cost_version_number;
            pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
              (p_project_id           => p_project_id,
               p_budget_version_id    => p_budget_version_id,
               p_cost_or_rev          => 'C',
	       x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);
/* -- INCOMPATIBLE PERIOD PROFILES: WORKING COST ---
 * ERROR MESSAGE HANDLING HERE
	    pa_fp_view_plans_pub.G_DISPLAY_FROM := 'COST';
            select version_number,
                   version_name
              into l_cost_version_number,
                   l_cost_version_name
              from pa_budget_versions
              where budget_version_id = p_budget_version_id;
            l_rev_version_number := null;
            l_rev_version_name := ' ';
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME := l_cost_version_name;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := l_cost_version_number;
            pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
              (p_project_id           => p_project_id,
               p_budget_version_id    => p_budget_version_id,
               p_cost_or_rev          => 'C',
	       x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);
*/
	  end if; -- period profiles match
        end if; -- l_compl_budget_version_id is null

      else
        -- we have the REVENUE version, so look for COST version with 'COST_AND_REV_SEP'
        pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '1700: pref=COST_AND_REV_SEP, BASELINED, REVENUE', 1);
        --hr_utility.trace('we have a baselined revenue version');
        open l_compl_crsep_r_b_csr;
        fetch l_compl_crsep_r_b_csr into l_compl_crsep_r_b_rec;
        if l_compl_crsep_r_b_csr%NOTFOUND then
          l_compl_budget_version_id := -99;
          l_compl_proj_fp_options_id := -99;
        else
          l_compl_budget_version_id := l_compl_crsep_r_b_rec.budget_version_id;
          l_compl_proj_fp_options_id := l_compl_crsep_r_b_rec.proj_fp_options_id;
        end if; -- l_compl_crsep_r_b_csr: no data found
        close l_compl_crsep_r_b_csr;
        if l_compl_budget_version_id = -99 then
          -- did not find a compl for the REVENUE version; just process REVENUE version
          pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '1800: pref=COST_AND_REV_SEP, BASELINED, REVENUE - did not find complement', 1);
          --hr_utility.trace('we have a baselined revenue version');
	  pa_fp_view_plans_pub.G_DISPLAY_FROM := 'REVENUE';
          select version_number,
                 version_name
            into l_rev_version_number,
                 l_rev_version_name
            from pa_budget_versions
            where budget_version_id = p_budget_version_id;
          l_cost_version_number := null;
          l_cost_version_name := ' ';
	  pa_fp_view_plans_pub.G_FP_REV_VERSION_ID := p_budget_version_id;
	  pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := l_rev_version_name;
	  pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := l_rev_version_number;
          pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
              (p_project_id           => p_project_id,
               p_budget_version_id    => p_budget_version_id,
               p_cost_or_rev          => 'R',
	       x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);
        else
          -- found a compl for the REVENUE version; merge only if period profiles are compatible
	  select period_profile_id
	    into l_period_profile_id1
	    from pa_budget_versions
	    where budget_version_id = p_budget_version_id;
	  select period_profile_id
	    into l_period_profile_id2
	    from pa_budget_versions
	    where budget_version_id = l_compl_budget_version_id;
	  if (pa_fp_view_plans_util.check_compatible_pd_profiles
		(p_period_profile_id1	=> l_period_profile_id1,
		 p_period_profile_id2	=> l_period_profile_id2) = 'Y') or
	     not (pa_fp_view_plans_pub.G_AMT_OR_PD = 'P') then
	    --merge the COST and REVENUE versions
            pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '1900: pref=COST_AND_REV_SEP, BASELINED, REVENUE - found complement, and passed period profiles test', 1);
            --hr_utility.trace('found compl for baselined revenue version AND period profile match');
	    pa_fp_view_plans_pub.G_DISPLAY_FROM := 'BOTH';
            select version_number,
                   version_name
              into l_rev_version_number,
                   l_rev_version_name
              from pa_budget_versions
              where budget_version_id = p_budget_version_id;
            select version_number,
                   version_name
              into l_cost_version_number,
                   l_cost_version_name
              from pa_budget_versions
              where budget_version_id = l_compl_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := l_compl_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NUMBER := l_cost_version_number;
	    pa_fp_view_plans_pub.G_FP_COST_VERSION_NAME	:= l_cost_version_name;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_ID := p_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := l_rev_version_name;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := l_rev_version_number;
            pa_fp_view_plans_pub.pa_fp_vp_pop_tables_separate
                (p_project_id               => p_project_id,
                 p_cost_budget_version_id   => l_compl_budget_version_id,
                 p_rev_budget_version_id    => p_budget_version_id,
	         x_return_status            => l_return_status,
                 x_msg_count                => l_msg_count,
                 x_msg_data                 => l_msg_data);
          else
	    -- period profiles not compatible; just process REVENUE version
            pa_debug.write('pa_fp_view_plans_pub.view_plan_temp_tables', '2000: pref=COST_AND_REV_SEP, BASELINED, REVENUE - found complement, BUT did not pass period profiles test', 1);
            --hr_utility.trace('found compl for baselined revenue version BUT no per profile match');
	    l_diff_pd_profile_flag := 'Y';
	    pa_fp_view_plans_pub.G_DISPLAY_FROM := 'REVENUE';
            select version_number,
                   version_name
              into l_rev_version_number,
                   l_rev_version_name
              from pa_budget_versions
              where budget_version_id = p_budget_version_id;
            l_cost_version_number := null;
            l_cost_version_name := ' ';
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_ID := p_budget_version_id;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := l_rev_version_name;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := l_rev_version_number;
            pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
              (p_project_id           => p_project_id,
               p_budget_version_id    => p_budget_version_id,
               p_cost_or_rev          => 'R',
	       x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);
/* -- INCOMPATIBLE PERIOD PROFILES: WORKING COST ---
 * ERROR MESSAGE HANDLING HERE
	    pa_fp_view_plans_pub.G_DISPLAY_FROM := 'REVENUE';
            select version_number,
                   version_name
              into l_rev_version_number,
                   l_rev_version_name
              from pa_budget_versions
              where budget_version_id = p_budget_version_id;
            l_cost_version_number := -1;
            l_cost_version_name := ' ';
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NAME := l_rev_version_name;
	    pa_fp_view_plans_pub.G_FP_REV_VERSION_NUMBER := l_rev_version_number;
            pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single
                (p_project_id           => p_project_id,
                 p_budget_version_id    => p_budget_version_id,
                 p_cost_or_rev          => 'R',
	         x_return_status        => l_return_status,
                 x_msg_count            => l_msg_count,
                 x_msg_data             => l_msg_data);
*/
          end if; -- period_profiles compatible
        end if; -- l_compl_budget_version_id is null
      end if; -- p_cost_or_revenue = 'C'
    end if; -- l_working_or_baselined = 'W'
  end if;
  x_cost_version_number := l_cost_version_number;
  x_rev_version_number := l_rev_version_number;
  x_cost_version_name := l_cost_version_name;
  x_rev_version_name := l_rev_version_name;

  end if; -- p_user_bv_flag
  x_diff_pd_profile_flag := l_diff_pd_profile_flag;
  --hr_utility.trace('diff_pd_profile_flag= ' || x_diff_pd_profile_flag);

EXCEPTION
  when others then
--hr_utility.trace('UNHANDLED EXCEPTION');
    rollback to VIEW_PLAN_TEMP_TABLES;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count     := 1;
    x_msg_data      := SQLERRM;
    FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FP_VIEW_PLANS_PUB',
                             p_procedure_name   => 'view_plan_temp_tables');
    pa_debug.reset_err_stack;
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

end; -- procedure view_plan_temp_tables
/* --------------------------------------------------------------------- */




-- modified for new AMOUNT_TYPE_CODE and AMOUNT_SUBTYPE_CODE
-- added logic for inserting RAW_COST and calculating MARGIN 6/20/02
-- 11/13/2002 Dlai:  updated cursors to select project OR projfunc numbers
--		     added logic for inserting rows for periodic view only if
--		     flag='Y' for that amount type
-- 11/21/2002 Dlai:  amts view global temporary table: new column = UNIT_OF_MEASURE
-- 11/25/2002 Dlai: select ra.total_plan_quantity for labor hours
-- 02/17/2003 Dlai: added l_pd_unit_of_measure (bug 2807032)
-- 02/20/2003 Dlai: added l_has_child_element/l_pd_has_child_element
-- 07/25/2003 Dlai: for PA_FIN_VP_PDS_VIEW_TMP, populate project_total
procedure pa_fp_vp_pop_tables_separate
    (p_project_id               IN  pa_budget_versions.project_id%TYPE,
     p_cost_budget_version_id   IN  pa_budget_versions.budget_version_id%TYPE,
     p_rev_budget_version_id    IN  pa_budget_versions.budget_version_id%TYPE,
     x_return_status            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    )
is
    /* local variables */
    l_found_complement                  BOOLEAN;
    l_report_labor_hrs_from_code        pa_proj_fp_options.report_labor_hrs_from_code%TYPE;
    l_cur_resource_assignment_id        pa_resource_assignments.resource_assignment_id%TYPE;
    l_quantity_res_assignment_id	pa_resource_assignments.resource_assignment_id%TYPE;
    l_row_number                        NUMBER; -- keep track of number of rows in PERIODS PL/SQL table
    l_cost_row_number                   NUMBER; -- PERIODS PL/SQL: cost row for calculating margin
    l_revenue_row_number                NUMBER; -- PERIODS PL/SQL: rev row for calculating margin
    l_period_profile_id                 pa_proj_period_profiles.period_profile_id%TYPE; -- used to retrieve values for period numbers
    l_default_amount_type_code          pa_proj_fp_options.default_amount_type_code%TYPE;
    l_default_amount_subtype_code       pa_proj_fp_options.default_amount_subtype_code%TYPE;
    l_currency_type			VARCHAR2(30);

  cursor av_cost_csr is
    select ra.project_id,
           ra.task_id,
           ra.resource_list_member_id,
           ra.budget_version_id,
           ra.resource_assignment_id,
           -1 as revenue_budget_version_id,  -- revenue_budget_version_id
           -1 as revenue_res_assignment_id,  -- revenue_resource_assignment_id
           pa_fp_view_plans_util.assign_element_name
                (ra.project_id,
                 ra.task_id,
                 ra.resource_list_member_id)  as element_name,  -- element_name
           pa_fp_view_plans_util.assign_element_level
                (ra.project_id,
		 ra.budget_version_id,
                 ra.task_id,
                 ra.resource_list_member_id) as element_level, -- element_level
           DECODE(pa_fp_view_plans_pub.G_FP_CALC_QUANTITY_FROM,
                  'REVENUE', 0,
--                  ra.total_utilization_hours) as labor_hours,
                  ra.total_plan_quantity) as labor_hours,
           DECODE(pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE,
		  'PROJ', ra.total_project_burdened_cost,
		  ra.total_plan_burdened_cost) as burdened_cost,  -- burdened_cost
           DECODE(pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE,
		  'PROJ', ra.total_project_raw_cost,
		  ra.total_plan_raw_cost) as raw_cost, -- raw_cost
           0 as revenue,  -- revenue
           0 as margin,  -- margin
           0 as margin_percent,  -- margin_percent
           DECODE(ra.resource_assignment_type,
                 'ROLLED_UP', 'N',
                 'USER_ENTERED', 'Y',
                 'Y') as line_editable_flag, -- line_editable_flag
           pa_fp_view_plans_util.assign_row_level
                (ra.project_id,
                 ra.task_id,
                 ra.resource_list_member_id) as row_level,
           pa_fp_view_plans_util.assign_parent_element
                (ra.project_id,
                 ra.task_id,
                 ra.resource_list_member_id) as parent_element_name,
	   ra.unit_of_measure
    from pa_resource_assignments ra
    where ra.budget_version_id = p_cost_budget_version_id and
	  ((ra.resource_assignment_type = 'USER_ENTERED' and
            exists (select 1 from pa_budget_lines bl
                    where bl.budget_version_id = ra.budget_version_id and
                          bl.resource_assignment_id = ra.resource_assignment_id)) or
           ra.resource_assignment_type = 'ROLLED_UP');

  cursor av_revenue_csr is
    select ra.project_id,
           ra.task_id,
           ra.resource_list_member_id,
           -1 as cost_budget_version_id,  -- cost_budget_version_id
           -1 as cost_res_assignment_id,  -- cost_resource_assignment_id
           ra.budget_version_id,
           ra.resource_assignment_id,
           pa_fp_view_plans_util.assign_element_name
                (ra.project_id,
                 ra.task_id,
                 ra.resource_list_member_id) as element_name,  -- element_name
           pa_fp_view_plans_util.assign_element_level
                (ra.project_id,
		 ra.budget_version_id,
                 ra.task_id,
                 ra.resource_list_member_id) as element_level, -- element_level
           DECODE(pa_fp_view_plans_pub.G_FP_CALC_QUANTITY_FROM,
--                  'REVENUE', ra.total_utilization_hours,
                  'REVENUE', ra.total_plan_quantity,
                  0) as labor_hours, -- labor_hrs: 0 if not reported from this COST/REVENUE version
           0 as burdened_cost,  -- burdened_cost
           0 as raw_cost,  -- raw_cost
           DECODE(pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE,
		  'PROJ', ra.total_project_revenue,
		  ra.total_plan_revenue) as revenue,  -- revenue
           0 as margin,  -- margin: leave this null until we visit the row again
           0 as margin_percent,  -- margin_percent: leave this null until we visit the row again
           DECODE(ra.resource_assignment_type,
                  'ROLLED_UP', 'N',
                  'USER_ENTERED', 'Y',
                  'Y'),  -- line_editable_flag
           pa_fp_view_plans_util.assign_row_level
                (ra.project_id,
                 ra.task_id,
                 ra.resource_list_member_id) as row_level,
           pa_fp_view_plans_util.assign_parent_element
                (ra.project_id,
                 ra.task_id,
                 ra.resource_list_member_id) as parent_element_name,
	   ra.unit_of_measure
    from pa_resource_assignments ra
    where ra.budget_version_id = p_rev_budget_version_id and
	  ((ra.resource_assignment_type = 'USER_ENTERED' and
            exists (select 1 from pa_budget_lines bl
                    where bl.budget_version_id = ra.budget_version_id and
                          bl.resource_assignment_id = ra.resource_assignment_id)) or
           ra.resource_assignment_type = 'ROLLED_UP');

    /* COST budget version: PL/SQL tables */
    l_c_project_id                      pa_fp_view_plans_pub.av_tab_project_id;
    l_c_task_id                         pa_fp_view_plans_pub.av_tab_task_id;
    l_c_resource_list_member_id         pa_fp_view_plans_pub.av_tab_resource_list_member_id;
    l_c_cost_budget_version_id          pa_fp_view_plans_pub.av_tab_cost_budget_version_id;
    l_c_cost_res_assignment_id          pa_fp_view_plans_pub.av_tab_cost_res_assignment_id;
    l_c_revenue_budget_version_id       pa_fp_view_plans_pub.av_tab_rev_budget_version_id;
    l_c_revenue_res_assignment_id       pa_fp_view_plans_pub.av_tab_rev_res_assignment_id;
    l_c_element_name                    pa_fp_view_plans_pub.av_tab_element_name;
    l_c_element_level                   pa_fp_view_plans_pub.av_tab_element_level;
    l_c_labor_hours                     pa_fp_view_plans_pub.av_tab_labor_hours;
    l_c_burdened_cost                   pa_fp_view_plans_pub.av_tab_burdened_cost;
    l_c_raw_cost                        pa_fp_view_plans_pub.av_tab_raw_cost;
    l_c_revenue                         pa_fp_view_plans_pub.av_tab_revenue;
    l_c_margin                          pa_fp_view_plans_pub.av_tab_margin;
    l_c_margin_percent                  pa_fp_view_plans_pub.av_tab_margin_percent;
    l_c_line_editable_flag              pa_fp_view_plans_pub.av_tab_line_editable;
    l_c_row_level			            pa_fp_view_plans_pub.av_tab_row_level;
    l_c_parent_element_name             pa_fp_view_plans_pub.av_tab_element_name;
    l_c_unit_of_measure			pa_fp_view_plans_pub.av_tab_unit_of_measure;
    l_c_has_child_element		pa_fp_view_plans_pub.av_tab_has_child_element;

    /* REVENUE budget version: PL/SQL tables */
    l_r_project_id                      pa_fp_view_plans_pub.av_tab_project_id;
    l_r_task_id                         pa_fp_view_plans_pub.av_tab_task_id;
    l_r_resource_list_member_id         pa_fp_view_plans_pub.av_tab_resource_list_member_id;
    l_r_cost_budget_version_id          pa_fp_view_plans_pub.av_tab_cost_budget_version_id;
    l_r_cost_res_assignment_id          pa_fp_view_plans_pub.av_tab_cost_res_assignment_id;
    l_r_revenue_budget_version_id       pa_fp_view_plans_pub.av_tab_rev_budget_version_id;
    l_r_revenue_res_assignment_id       pa_fp_view_plans_pub.av_tab_rev_res_assignment_id;
    l_r_element_name                    pa_fp_view_plans_pub.av_tab_element_name;
    l_r_element_level                   pa_fp_view_plans_pub.av_tab_element_level;
    l_r_labor_hours                     pa_fp_view_plans_pub.av_tab_labor_hours;
    l_r_burdened_cost                   pa_fp_view_plans_pub.av_tab_burdened_cost;
    l_r_raw_cost                        pa_fp_view_plans_pub.av_tab_raw_cost;
    l_r_revenue                         pa_fp_view_plans_pub.av_tab_revenue;
    l_r_margin                          pa_fp_view_plans_pub.av_tab_margin;
    l_r_margin_percent                  pa_fp_view_plans_pub.av_tab_margin_percent;
    l_r_line_editable_flag              pa_fp_view_plans_pub.av_tab_line_editable;
    l_r_row_level			pa_fp_view_plans_pub.av_tab_row_level;
    l_r_parent_element_name             pa_fp_view_plans_pub.av_tab_element_name;
    l_r_unit_of_measure			pa_fp_view_plans_pub.av_tab_unit_of_measure;
    l_r_has_child_element		pa_fp_view_plans_pub.av_tab_has_child_element;

    /* PL/SQL table for PERIODS VIEW */
    l_pd_project_id                     pa_fp_view_plans_pub.av_tab_project_id;
    l_pd_task_id                        pa_fp_view_plans_pub.av_tab_task_id;
    l_pd_resource_list_member_id        pa_fp_view_plans_pub.av_tab_resource_list_member_id;
    l_pd_unit_of_measure		pa_fp_view_plans_pub.av_tab_unit_of_measure;
    l_pd_cost_budget_version_id         pa_fp_view_plans_pub.av_tab_cost_budget_version_id;
    l_pd_cost_res_assignment_id         pa_fp_view_plans_pub.av_tab_cost_res_assignment_id;
    l_pd_revenue_budget_version_id      pa_fp_view_plans_pub.av_tab_rev_budget_version_id;
    l_pd_revenue_res_assignment_id      pa_fp_view_plans_pub.av_tab_rev_res_assignment_id;
    l_pd_element_name                   pa_fp_view_plans_pub.av_tab_element_name;
    l_pd_element_level                  pa_fp_view_plans_pub.av_tab_element_level;
    l_pd_line_editable_flag             pa_fp_view_plans_pub.av_tab_line_editable;
    l_pd_row_level                      pa_fp_view_plans_pub.av_tab_row_level;
    l_pd_parent_element_name            pa_fp_view_plans_pub.av_tab_element_name;
    l_pd_amount_type                    pa_fp_view_plans_pub.av_tab_amount_type;
    l_pd_amount_subtype                 pa_fp_view_plans_pub.av_tab_amount_subtype;
    l_pd_amount_type_id                 pa_fp_view_plans_pub.av_tab_amount_type_id;
    l_pd_amount_subtype_id              pa_fp_view_plans_pub.av_tab_amount_subtype_id;
    l_pd_period_1                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_2                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_3                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_4                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_5                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_6                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_7                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_8                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_9                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_10                      pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_11                      pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_12                      pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_13                      pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_preceding			pa_fp_view_plans_pub.av_tab_preceding_amts;
    l_pd_succeeding			pa_fp_view_plans_pub.av_tab_succeeding_amts;
    l_pd_has_child_element		pa_fp_view_plans_pub.av_tab_has_child_element;
    l_pd_project_total			pa_fp_view_plans_pub.av_tab_period_numbers;
-- local debugging variables
    l_err_stage		NUMBER(15);

begin
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_separate', '100: entering procedure', 2);
l_err_stage := 100;
--hr_utility.trace('entered pa_fp_vp_pop_tables_separate');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  SAVEPOINT VIEW_PLANS_POP_TABLES_SEP;

  -- used to query pa_proj_periods_denorm table
  select DECODE(pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE,
		'PROJFUNC', 'PROJ_FUNCTIONAL',
		'PROJ', 'PROJECT',
		'TRANSACTION')
    into l_currency_type
    from dual;

  pa_fp_view_plans_pub.G_FP_REV_VERSION_ID :=  p_rev_budget_version_id;
  pa_fp_view_plans_pub.G_FP_COST_VERSION_ID := p_cost_budget_version_id;
  pa_fp_view_plans_pub.G_DISPLAY_FROM := 'BOTH';
l_err_stage := 200;
  -- this is for populating PERIODS PL/SQL table
  l_row_number := 0;
  select NVL(po.report_labor_hrs_from_code, 'COST'),
	 pa_fp_view_plans_pub.G_DEFAULT_AMOUNT_TYPE_CODE,
	 pa_fp_view_plans_pub.G_DEFAULT_AMT_SUBTYPE_CODE,
--         po.default_amount_type_code,
--         po.default_amount_subtype_code
	 bv.period_profile_id
    into l_report_labor_hrs_from_code,
         l_default_amount_type_code,
         l_default_amount_subtype_code,
	 l_period_profile_id
    from pa_proj_fp_options po,
	 pa_budget_versions bv
    where bv.budget_version_id = p_cost_budget_version_id and
	  bv.fin_plan_type_id = po.fin_plan_type_id and
	  po.project_id = p_project_id and
          po.fin_plan_option_level_code = 'PLAN_TYPE';
l_err_stage := 300;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_separate', '200: periodprofileid= ' || l_period_profile_id, 1);
  -- insert all cost rows into the COST PL/SQL table
  open av_cost_csr;
  fetch av_cost_csr bulk collect into
         l_c_project_id,
         l_c_task_id,
         l_c_resource_list_member_id,
         l_c_cost_budget_version_id,
         l_c_cost_res_assignment_id,
         l_c_revenue_budget_version_id,
         l_c_revenue_res_assignment_id,
         l_c_element_name,
         l_c_element_level,
         l_c_labor_hours,
         l_c_burdened_cost,
         l_c_raw_cost,
         l_c_revenue,
         l_c_margin,
         l_c_margin_percent,
         l_c_line_editable_flag,
	 l_c_row_level,
         l_c_parent_element_name,
	 l_c_unit_of_measure;
  close av_cost_csr;
l_err_stage := 400;
  -- insert all revenue rows into the REVENUE PL/SQL table
  open av_revenue_csr;
  fetch av_revenue_csr bulk collect into
         l_r_project_id,
         l_r_task_id,
         l_r_resource_list_member_id,
         l_r_cost_budget_version_id,
         l_r_cost_res_assignment_id,
         l_r_revenue_budget_version_id,
         l_r_revenue_res_assignment_id,
         l_r_element_name,
         l_r_element_level,
         l_r_labor_hours,
         l_r_burdened_cost,
         l_r_raw_cost,
         l_r_revenue,
         l_r_margin,
         l_r_margin_percent,
         l_r_line_editable_flag,
    	 l_r_row_level,
         l_r_parent_element_name,
	 l_r_unit_of_measure;
  close av_revenue_csr;
l_err_stage := 500;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_separate', '300: bulk collected into pl/sql tables', 1);
  -- now, iterate through all rows in the COST table,
--hr_utility.trace('l_c_project_id.first = ' || TO_CHAR(l_c_project_id.first));
  for i in nvl(l_c_project_id.first,0)..nvl(l_c_project_id.last,-1) loop
    l_found_complement := false;
    -- look for a row in REVENUE table with same project-task-resource id combo
    for j in nvl(l_r_project_id.first,0)..nvl(l_r_project_id.last,-1) loop
      if (l_r_project_id(j) = l_c_project_id(i)) and
         (l_r_task_id(j) = l_c_task_id(i)) and
--	 (l_r_revenue_res_assignment_id(j) = l_c_cost_res_assignment_id(i)) and
         ((l_r_resource_list_member_id(j) = l_c_resource_list_member_id(i)) or
	  (l_r_resource_list_member_id(j) = 0 and l_c_resource_list_member_id(i) = pa_fp_view_plans_pub.Get_Uncat_Res_List_Member_Id) or
	  (l_r_resource_list_member_id(j) = pa_fp_view_plans_pub.Get_Uncat_Res_List_Member_Id and l_c_resource_list_member_id(i) = 0)) then
        -- a match has been found: add data from REVENUE PL/SQL to the COST PL/SQL table
--hr_utility.trace('FOUND MATCH');
--hr_utility.trace('cost res assid= ' || to_char(l_c_cost_res_assignment_id(i)));
--hr_utility.trace('rev res assid= ' || to_char(l_r_revenue_res_assignment_id(j)));
        l_found_complement := true;
        l_c_revenue_budget_version_id(i) := l_r_revenue_budget_version_id(j);
        l_c_revenue_res_assignment_id(i) := l_r_revenue_res_assignment_id(j);
        l_c_revenue(i) := l_r_revenue(j);
        if (pa_fp_view_plans_pub.G_FP_CALC_MARGIN_FROM = 'R') or (l_c_burdened_cost(i) is null) then
          l_c_margin(i) := l_c_revenue(i) - l_c_raw_cost(i);
        else
          l_c_margin(i) := l_c_revenue(i) - l_c_burdened_cost(i);
        end if; -- burdened_cost is null
        -- divide by zero special case
        if l_c_revenue(i) = 0 then
          l_c_margin_percent(i) := 0;
        else
          l_c_margin_percent(i) := l_c_margin(i) / l_c_revenue(i);
        end if;

	if pa_fp_view_plans_pub.G_FP_CALC_QUANTITY_FROM = 'REVENUE' then
	  l_c_labor_hours(i) := l_r_labor_hours(j);
	else
          l_c_labor_hours(i) := l_c_labor_hours(i);
	end if;
        l_c_has_child_element(i) :=
	   pa_fp_view_plans_pub.has_child_rows
     		(l_c_project_id(i),
		 l_c_cost_budget_version_id(i),
		 l_c_revenue_budget_version_id(i),
		 l_c_task_id(i),
		 l_c_resource_list_member_id(i),
		 null,
		 'A');

        /* ---- populate the PERIODS PL/SQL table with the following rows ---- */
        /* ---- COST, REVENUE, MARGIN, MARGIN_PERCENT, LABOR_HOURS        ---- */
	/* 11/12/2002 --> check to see if flag = 'Y' before creating row  */
	/* ONLY if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'		      */
     if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P' then
        -- start with the COST version as the source
        l_cur_resource_assignment_id := l_c_cost_res_assignment_id(i);

        -- process the QUANTITY row based on the value of l_report_labor_hrs_from_code
        if l_report_labor_hrs_from_code = 'COST' then
	if pa_fp_view_plans_pub.G_DISPLAY_FLAG_QUANTITY = 'Y' then
  --hr_utility.trace('adding QUANTITY row');
          l_row_number := l_row_number + 1;  -- increment row counter
          l_pd_project_id(l_row_number) := l_c_project_id(i);
          l_pd_task_id(l_row_number) := l_c_task_id(i);
          l_pd_resource_list_member_id(l_row_number) := l_c_resource_list_member_id(i);
	  l_pd_unit_of_measure(l_row_number) := l_c_unit_of_measure(i);
          l_pd_cost_budget_version_id(l_row_number) := l_c_cost_budget_version_id(i);
          l_pd_cost_res_assignment_id(l_row_number) := l_c_cost_res_assignment_id(i);
          l_pd_revenue_budget_version_id(l_row_number) := -1;
          l_pd_revenue_res_assignment_id(l_row_number) := -1;
          l_pd_element_name(l_row_number) := l_c_element_name(i);
          l_pd_element_level(l_row_number) := l_c_element_level(i);
          l_pd_row_level(l_row_number) := l_c_row_level(i);
          l_pd_line_editable_flag(l_row_number) := l_c_line_editable_flag(i);
          l_pd_parent_element_name(l_row_number) := l_c_parent_element_name(i);
          l_pd_amount_type(l_row_number) := 'QUANTITY';
          l_pd_amount_subtype(l_row_number) := 'QUANTITY';
          l_pd_amount_type_id(l_row_number) := 215; -- amount_type_id of 'QUANTITY'
          l_pd_amount_subtype_id(l_row_number) := 215; -- amount_subtype_id of 'QUANTITY'
          -- DEFAULT_AMOUNT_TYPE/SUBTYPE_CODE check: if not the default, then demote
          if not ((l_default_amount_type_code = 'QUANTITY') and
                  (l_default_amount_subtype_code = 'QUANTITY')) then
            l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
            l_pd_element_name(l_row_number) := null;
	    l_pd_has_child_element(l_row_number) := 'N';
	  else
	    l_pd_has_child_element(l_row_number) := 'Y';
          end if;
          l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 1);
--hr_utility.trace('VALUE is = ' || to_char(l_pd_period_1(l_row_number)));
--hr_utility.trace('get_period_n_value for period 2');
          l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 2);
          l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 3);
          l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 4);
          l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 5);
          l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 6);
          l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 7);
          l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 8);
          l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 9);
          l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 10);
          l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 11);
          l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 12);
          l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 13);
          l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 0);
          l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 14);
	  l_pd_project_total(l_row_number) := l_c_labor_hours(i); -- bug 2699651
	end if; -- display_flag: QUANTITY
        end if; -- QUANTITY

	if pa_fp_view_plans_pub.G_DISPLAY_FLAG_BURDCOST = 'Y' then
  --hr_utility.trace('adding BURDENED COST row');
        -- process the BURDENED_COST row from the COST version
        l_row_number := l_row_number + 1;  -- increment row counter
        -- 02/14/03 dlai:  use appropriate cost row based on G_FP_CALC_MARGIN_FROM
        if pa_fp_view_plans_pub.G_FP_CALC_MARGIN_FROM = 'B' then
          l_cost_row_number := l_row_number;
        end if;
     /*
        if l_c_burdened_cost(i) is not null then
          l_cost_row_number := l_row_number; -- used when calculating margin, margin_percent
        end if;
     */
        l_pd_project_id(l_row_number) := l_c_project_id(i);
        l_pd_task_id(l_row_number) := l_c_task_id(i);
        l_pd_resource_list_member_id(l_row_number) := l_c_resource_list_member_id(i);
	l_pd_unit_of_measure(l_row_number) := null;
        l_pd_cost_budget_version_id(l_row_number) := l_c_cost_budget_version_id(i);
        l_pd_cost_res_assignment_id(l_row_number) := l_c_cost_res_assignment_id(i);
        l_pd_revenue_budget_version_id(l_row_number) := -1;
        l_pd_revenue_res_assignment_id(l_row_number) := -1;
        l_pd_element_name(l_row_number) := l_c_element_name(i);
        l_pd_element_level(l_row_number) := l_c_element_level(i);
        l_pd_row_level(l_row_number) := l_c_row_level(i);
        l_pd_line_editable_flag(l_row_number) := l_c_line_editable_flag(i);
        l_pd_parent_element_name(l_row_number) := l_c_parent_element_name(i);
        l_pd_amount_type(l_row_number) := 'COST';
        l_pd_amount_subtype(l_row_number) := 'BURDENED_COST';
        l_pd_amount_type_id(l_row_number) := 150; -- amount_type_id for 'COST'
        l_pd_amount_subtype_id(l_row_number) := 165; -- amount_subtype_id for 'BURDENED_COST'
        -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
        if not ((l_default_amount_type_code = 'COST') and
                (l_default_amount_subtype_code = 'BURDENED_COST')) then
          l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
          l_pd_element_name(l_row_number) := null;
	  l_pd_has_child_element(l_row_number) := 'N';
	else
	  l_pd_has_child_element(l_row_number) := 'Y';
        end if;
        l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 1);
--hr_utility.trace('VALUE is = ' || to_char(l_pd_period_1(l_row_number)));
        l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 2);
        l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 3);
        l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 4);
        l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 5);
        l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 6);
        l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 7);
        l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 8);
        l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 9);
        l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 10);
        l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 11);
        l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 12);
        l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 13);
        l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 0);
        l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 14);
	l_pd_project_total(l_row_number) := l_c_burdened_cost(i); -- bug 2699651
	end if; -- display_flag: BURDENED_COST

	if pa_fp_view_plans_pub.G_DISPLAY_FLAG_RAWCOST = 'Y' then
  --hr_utility.trace('adding RAW COST row');
        -- process the RAW_COST row from the COST version
        l_row_number := l_row_number + 1;  -- increment row counter
        -- 02/14/03 dlai:  use appropriate cost row based on G_FP_CALC_MARGIN_FROM
        if pa_fp_view_plans_pub.G_FP_CALC_MARGIN_FROM <> 'B' then
          l_cost_row_number := l_row_number;
        end if;
     /*
        if l_c_burdened_cost(i) is null then
          l_cost_row_number := l_row_number; -- used when calculating margin, margin_percent
        end if; -- if burdened_cost is null, calculate margin using revenue - raw_cost
     */
        l_pd_project_id(l_row_number) := l_c_project_id(i);
        l_pd_task_id(l_row_number) := l_c_task_id(i);
        l_pd_resource_list_member_id(l_row_number) := l_c_resource_list_member_id(i);
	l_pd_unit_of_measure(l_row_number) := null;
        l_pd_cost_budget_version_id(l_row_number) := l_c_cost_budget_version_id(i);
        l_pd_cost_res_assignment_id(l_row_number) := l_c_cost_res_assignment_id(i);
        l_pd_revenue_budget_version_id(l_row_number) := -1;
        l_pd_revenue_res_assignment_id(l_row_number) := -1;
        l_pd_element_name(l_row_number) := l_c_element_name(i);
        l_pd_element_level(l_row_number) := l_c_element_level(i);
        l_pd_row_level(l_row_number) := l_c_row_level(i);
        l_pd_line_editable_flag(l_row_number) := l_c_line_editable_flag(i);
        l_pd_parent_element_name(l_row_number) := l_c_parent_element_name(i);
        l_pd_amount_type(l_row_number) := 'COST';
        l_pd_amount_subtype(l_row_number) := 'RAW_COST';
        l_pd_amount_type_id(l_row_number) := 150; -- amount_type_id for 'COST'
        l_pd_amount_subtype_id(l_row_number) := 160; -- amount_subtype_id for 'RAW_COST'
        -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
        if not ((l_default_amount_type_code = 'COST') and
                (l_default_amount_subtype_code = 'RAW_COST')) then
          l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
          l_pd_element_name(l_row_number) := null;
	  l_pd_has_child_element(l_row_number) := 'N';
	else
	  l_pd_has_child_element(l_row_number) := 'Y';
        end if;
        l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 1);
        l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 2);
        l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 3);
        l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 4);
        l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 5);
        l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 6);
        l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 7);
        l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 8);
        l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 9);
        l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 10);
        l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 11);
        l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 12);
        l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 13);
        l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 0);
        l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id	   => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 14);
	l_pd_project_total(l_row_number) := l_c_raw_cost(i); -- bug 2699651
	end if; --display_flag: RAW COST

        -- now use the REVENUE version as the source
        l_cur_resource_assignment_id := l_r_revenue_res_assignment_id(j);
        -- process the UTILIZATION row based on the value of l_report_labor_hrs_from_code
        if l_report_labor_hrs_from_code = 'REVENUE' then

	if pa_fp_view_plans_pub.G_DISPLAY_FLAG_QUANTITY = 'Y' then
          l_row_number := l_row_number + 1;  -- increment row counter
          l_pd_project_id(l_row_number) := l_r_project_id(j);
          l_pd_task_id(l_row_number) := l_r_task_id(j);
          l_pd_resource_list_member_id(l_row_number) := l_r_resource_list_member_id(j);
    	  l_pd_unit_of_measure(l_row_number) := l_r_unit_of_measure(j);
          l_pd_cost_budget_version_id(l_row_number) := -1;
          l_pd_cost_res_assignment_id(l_row_number) := -1;
          l_pd_revenue_budget_version_id(l_row_number) := l_r_revenue_budget_version_id(j);
          l_pd_revenue_res_assignment_id(l_row_number) := l_r_revenue_res_assignment_id(j);
          l_pd_element_name(l_row_number) := l_r_element_name(j);
          l_pd_element_level(l_row_number) := l_r_element_level(j);
          l_pd_row_level(l_row_number) := l_r_row_level(j);
          l_pd_line_editable_flag(l_row_number) := l_r_line_editable_flag(j);
          l_pd_parent_element_name(l_row_number) := l_r_parent_element_name(j);
          l_pd_amount_type(l_row_number) := 'QUANTITY';
          l_pd_amount_subtype(l_row_number) := 'QUANTITY';
          l_pd_amount_type_id(l_row_number) := 215; -- amount_type_id for 'QUANTITY'
          l_pd_amount_subtype_id(l_row_number) := 215; -- amount_subtype_id for 'QUANTITY'
          -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
          if not ((l_default_amount_type_code = 'QUANTITY') and
                  (l_default_amount_subtype_code = 'QUANTITY')) then
            l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
            l_pd_element_name(l_row_number) := null;
	    l_pd_has_child_element(l_row_number) := 'N';
	  else
	    l_pd_has_child_element(l_row_number) := 'Y';
          end if;
          l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 1);
          l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 1);
          l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 2);
          l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 3);
          l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 4);
          l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 5);
          l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 6);
          l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 7);
          l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 8);
          l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 9);
          l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 10);
          l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 11);
          l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 12);
          l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 13);
          l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 0);
          l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 14);
	  l_pd_project_total(l_row_number) := l_r_labor_hours(j); -- bug 2699651
	end if; --display_flag: QUANTITY
        end if; -- QUANTITY

	if pa_fp_view_plans_pub.G_DISPLAY_FLAG_REVENUE = 'Y' then
  --hr_utility.trace('adding REVENUE row');
        -- process the REVENUE row for this REVENUE version
        l_row_number := l_row_number + 1;  -- increment row counter
        l_revenue_row_number := l_row_number; -- used when calculating margin, margin_percent
        l_pd_project_id(l_row_number) := l_r_project_id(j);
        l_pd_task_id(l_row_number) := l_r_task_id(j);
        l_pd_resource_list_member_id(l_row_number) := l_r_resource_list_member_id(j);
	l_pd_unit_of_measure(l_row_number) := null;
        l_pd_cost_budget_version_id(l_row_number) := -1;
        l_pd_cost_res_assignment_id(l_row_number) := -1;
        l_pd_revenue_budget_version_id(l_row_number) := l_r_revenue_budget_version_id(j);
        l_pd_revenue_res_assignment_id(l_row_number) := l_r_revenue_res_assignment_id(j);
        l_pd_element_name(l_row_number) := l_r_element_name(j);
        l_pd_element_level(l_row_number) := l_r_element_level(j);
        l_pd_row_level(l_row_number) := l_r_row_level(j);
        l_pd_line_editable_flag(l_row_number) := l_r_line_editable_flag(j);
        l_pd_parent_element_name(l_row_number) := l_r_parent_element_name(j);
        l_pd_amount_type(l_row_number) := 'REVENUE';
        l_pd_amount_subtype(l_row_number) := 'REVENUE';
        l_pd_amount_type_id(l_row_number) := 100; -- amount_type_id for 'REVENUE'
        l_pd_amount_subtype_id(l_row_number) := 100; -- amount_subtype_id for 'REVENUE'
        -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
        if not ((l_default_amount_type_code = 'REVENUE') and
                (l_default_amount_subtype_code = 'REVENUE')) then
          l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
          l_pd_element_name(l_row_number) := null;
	  l_pd_has_child_element(l_row_number) := 'N';
	else
	  l_pd_has_child_element(l_row_number) := 'Y';
        end if;
        l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 1);
        l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 2);
        l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 3);
        l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 4);
        l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 5);
        l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 6);
        l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 7);
        l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 8);
        l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 9);
        l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 10);
        l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 11);
        l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 12);
        l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 13);
        l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 0);
        l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 14);
	l_pd_project_total(l_row_number) := l_r_revenue(j); -- bug 2699651
	end if; -- display_flag: REVENUE

	if pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGIN = 'Y' then
  --hr_utility.trace('adding MARGIN row');
        -- finally, insert the MARGIN and MARGIN_PERCENT rows
        -- MARGIN row
        l_row_number := l_row_number + 1;  -- increment row counter
        l_pd_project_id(l_row_number) := l_c_project_id(i);
        l_pd_task_id(l_row_number) := l_c_task_id(i);
        l_pd_resource_list_member_id(l_row_number) := l_c_resource_list_member_id(i);
	l_pd_unit_of_measure(l_row_number) := null;
        l_pd_cost_budget_version_id(l_row_number) := l_c_cost_budget_version_id(i);
        l_pd_cost_res_assignment_id(l_row_number) := l_c_cost_res_assignment_id(i);
        l_pd_revenue_budget_version_id(l_row_number) := l_r_revenue_budget_version_id(j);
        l_pd_revenue_res_assignment_id(l_row_number) := l_r_revenue_res_assignment_id(j);
        l_pd_element_name(l_row_number) := l_c_element_name(i);
        l_pd_element_level(l_row_number) := l_c_element_level(i);
        l_pd_row_level(l_row_number) := l_c_row_level(i);
        --l_pd_line_editable_flag(l_row_number) := l_c_line_editable_flag(i);
	l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit margin
        l_pd_parent_element_name(l_row_number) := l_c_parent_element_name(i);
        l_pd_amount_type(l_row_number) := 'MARGIN';
        l_pd_amount_subtype(l_row_number) := 'MARGIN';
        l_pd_amount_type_id(l_row_number) := 230; -- amount_type_id of MARGIN
        l_pd_amount_subtype_id(l_row_number) := 230; -- amount_subtype_id of MARGIN
        -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
        if not ((l_default_amount_type_code = 'MARGIN') and
                (l_default_amount_subtype_code = 'MARGIN')) then
          l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
          l_pd_element_name(l_row_number) := null;
	  l_pd_has_child_element(l_row_number) := 'N';
	else
	  l_pd_has_child_element(l_row_number) := 'Y';
        end if;
        l_pd_period_1(l_row_number) := l_pd_period_1(l_revenue_row_number)-l_pd_period_1(l_cost_row_number);
        l_pd_period_2(l_row_number) := l_pd_period_2(l_revenue_row_number)-l_pd_period_2(l_cost_row_number);
        l_pd_period_3(l_row_number) := l_pd_period_3(l_revenue_row_number)-l_pd_period_3(l_cost_row_number);
        l_pd_period_4(l_row_number) := l_pd_period_4(l_revenue_row_number)-l_pd_period_4(l_cost_row_number);
        l_pd_period_5(l_row_number) := l_pd_period_5(l_revenue_row_number)-l_pd_period_5(l_cost_row_number);
        l_pd_period_6(l_row_number) := l_pd_period_6(l_revenue_row_number)-l_pd_period_6(l_cost_row_number);
        l_pd_period_7(l_row_number) := l_pd_period_7(l_revenue_row_number)-l_pd_period_7(l_cost_row_number);
        l_pd_period_8(l_row_number) := l_pd_period_8(l_revenue_row_number)-l_pd_period_8(l_cost_row_number);
        l_pd_period_9(l_row_number) := l_pd_period_9(l_revenue_row_number)-l_pd_period_9(l_cost_row_number);
        l_pd_period_10(l_row_number) := l_pd_period_10(l_revenue_row_number)-l_pd_period_10(l_cost_row_number);
        l_pd_period_11(l_row_number) := l_pd_period_11(l_revenue_row_number)-l_pd_period_11(l_cost_row_number);
        l_pd_period_12(l_row_number) := l_pd_period_12(l_revenue_row_number)-l_pd_period_12(l_cost_row_number);
        l_pd_period_13(l_row_number) := l_pd_period_13(l_revenue_row_number)-l_pd_period_13(l_cost_row_number);
        l_pd_preceding(l_row_number) := l_pd_preceding(l_revenue_row_number)-l_pd_preceding(l_cost_row_number);
        l_pd_succeeding(l_row_number) := l_pd_succeeding(l_revenue_row_number)-l_pd_succeeding(l_cost_row_number);
	l_pd_project_total(l_row_number) := l_pd_project_total(l_revenue_row_number)-l_pd_project_total(l_cost_row_number); -- bug 2699651
	end if; -- display_flag: MARGIN

	if pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGINPCT = 'Y' then
  --hr_utility.trace('adding MARGIN PERCENT row');
        -- MARGIN_PERCENT
        l_row_number := l_row_number + 1;  -- increment row counter
        l_pd_project_id(l_row_number) := l_c_project_id(i);
        l_pd_task_id(l_row_number) := l_c_task_id(i);
        l_pd_resource_list_member_id(l_row_number) := l_c_resource_list_member_id(i);
	l_pd_unit_of_measure(l_row_number) := null;
        l_pd_cost_budget_version_id(l_row_number) := l_c_cost_budget_version_id(i);
        l_pd_cost_res_assignment_id(l_row_number) := l_c_cost_res_assignment_id(i);
        l_pd_revenue_budget_version_id(l_row_number) := l_r_revenue_budget_version_id(j);
        l_pd_revenue_res_assignment_id(l_row_number) := l_r_revenue_res_assignment_id(j);
        l_pd_element_name(l_row_number) := l_c_element_name(i);
        l_pd_element_level(l_row_number) := l_c_element_level(i);
        l_pd_row_level(l_row_number) := l_c_row_level(i);
        --l_pd_line_editable_flag(l_row_number) := l_c_line_editable_flag(i);
	l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit margin_pct
        l_pd_parent_element_name(l_row_number) := l_c_parent_element_name(i);
        l_pd_amount_type(l_row_number) := 'MARGIN_PERCENT';
        l_pd_amount_subtype(l_row_number) := 'MARGIN_PERCENT';
        l_pd_amount_type_id(l_row_number) := 231; -- amount_type_id of MARGIN_PERCENT
        l_pd_amount_subtype_id(l_row_number) := 231; -- amount_subtype_id of MARGIN_PERCENT
        -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
        if not ((l_default_amount_type_code = 'MARGIN_PERCENT') and
                (l_default_amount_subtype_code = 'MARGIN_PERCENT')) then
          l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
          l_pd_element_name(l_row_number) := null;
	  l_pd_has_child_element(l_row_number) := 'N';
	else
	  l_pd_has_child_element(l_row_number) := 'Y';
        end if;
        l_pd_period_1(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_1(l_cost_row_number),l_pd_period_1(l_revenue_row_number));
        l_pd_period_2(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_2(l_cost_row_number),l_pd_period_2(l_revenue_row_number));
        l_pd_period_3(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_3(l_cost_row_number),l_pd_period_3(l_revenue_row_number));
        l_pd_period_4(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_4(l_cost_row_number),l_pd_period_4(l_revenue_row_number));
        l_pd_period_5(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_5(l_cost_row_number),l_pd_period_5(l_revenue_row_number));
        l_pd_period_6(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_6(l_cost_row_number),l_pd_period_6(l_revenue_row_number));
        l_pd_period_7(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_7(l_cost_row_number),l_pd_period_7(l_revenue_row_number));
        l_pd_period_8(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_8(l_cost_row_number),l_pd_period_8(l_revenue_row_number));
        l_pd_period_9(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_9(l_cost_row_number),l_pd_period_9(l_revenue_row_number));
        l_pd_period_10(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_10(l_cost_row_number),l_pd_period_10(l_revenue_row_number));
        l_pd_period_11(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_11(l_cost_row_number),l_pd_period_11(l_revenue_row_number));
        l_pd_period_12(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_12(l_cost_row_number),l_pd_period_12(l_revenue_row_number));
        l_pd_period_13(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_13(l_cost_row_number),l_pd_period_13(l_revenue_row_number));
        l_pd_preceding(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_preceding(l_cost_row_number),l_pd_preceding(l_revenue_row_number));
        l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_succeeding(l_cost_row_number),l_pd_succeeding(l_revenue_row_number));
	l_pd_project_total(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_project_total(l_cost_row_number),l_pd_project_total(l_revenue_row_number)); -- bug 2699651
	end if; -- display_flag: MARGIN PERCENT
     end if; -- pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'
/*
        l_r_project_id.delete(j);
        l_r_task_id.delete(j);
        l_r_resource_list_member_id.delete(j);
        l_r_cost_budget_version_id.delete(j);
        l_r_cost_res_assignment_id.delete(j);
        l_r_revenue_budget_version_id.delete(j);
        l_r_revenue_res_assignment_id.delete(j);
        l_r_element_name.delete(j);
        l_r_element_level.delete(j);
        l_r_labor_hours.delete(j);
        l_r_burdened_cost.delete(j);
        l_r_revenue.delete(j);
        l_r_margin.delete(j);
        l_r_margin_percent.delete(j);
        l_r_line_editable_flag.delete(j);
        exit;
*/
      end if;
      if l_found_complement then
	-- after transferring data, delete row from REVENUE PL/SQL table:
	-- to do this, we need to shift up all subsequent rows, and delete the very last row
	  if j=l_r_project_id.last then
	    -- We've reached the last row; delete it
            l_r_project_id.delete(j);
            l_r_task_id.delete(j);
            l_r_resource_list_member_id.delete(j);
            l_r_cost_budget_version_id.delete(j);
            l_r_cost_res_assignment_id.delete(j);
            l_r_revenue_budget_version_id.delete(j);
            l_r_revenue_res_assignment_id.delete(j);
            l_r_element_name.delete(j);
            l_r_element_level.delete(j);
            l_r_labor_hours.delete(j);
            l_r_burdened_cost.delete(j);
            l_r_revenue.delete(j);
            l_r_margin.delete(j);
            l_r_margin_percent.delete(j);
            l_r_line_editable_flag.delete(j);
             l_r_raw_cost.delete(j);
      	     l_r_row_level.delete(j);
             l_r_parent_element_name.delete(j);
	     l_r_unit_of_measure.delete(j);
	  else
	    -- shift up all rows after deleted row
            l_r_project_id(j) := l_r_project_id(j+1);
            l_r_task_id(j) := l_r_task_id(j+1);
            l_r_resource_list_member_id(j) := l_r_resource_list_member_id(j+1);
            l_r_cost_budget_version_id(j) := l_r_cost_budget_version_id(j+1);
            l_r_cost_res_assignment_id(j) := l_r_cost_res_assignment_id(j+1);
            l_r_revenue_budget_version_id(j) := l_r_revenue_budget_version_id(j+1);
            l_r_revenue_res_assignment_id(j) := l_r_revenue_res_assignment_id(j+1);
            l_r_element_name(j) := l_r_element_name(j+1);
            l_r_element_level(j) := l_r_element_level(j+1);
            l_r_labor_hours(j) := l_r_labor_hours(j+1);
            l_r_burdened_cost(j) := l_r_burdened_cost(j+1);
            l_r_revenue(j) := l_r_revenue(j+1);
            l_r_margin(j) := l_r_margin(j+1);
            l_r_margin_percent(j) := l_r_margin_percent(j+1);
            l_r_line_editable_flag(j) := l_r_line_editable_flag(j+1);
             l_r_raw_cost(j) := l_r_raw_cost(j+1);
      	     l_r_row_level(j) := l_r_row_level(j+1);
             l_r_parent_element_name(j) := l_r_parent_element_name(j+1);
	     l_r_unit_of_measure(j) := l_r_unit_of_measure(j+1);
	  end if;
      end if; -- found complement in loop: SHIFT ALL SUBSEQUENT ROWS UP AND DELETE LAST ROW
    end loop; -- REVENUE PL/SQL loop
    if not l_found_complement then

      -- did not find a complement in REVENUE PL/SQL table; pad revenue #'s with 0's
      l_c_revenue(i) := 0;
      l_c_margin(i) := 0;
      l_c_margin_percent(i) := 0;
      l_c_has_child_element(i) :=
	   pa_fp_view_plans_pub.has_child_rows
     		(l_c_project_id(i),
		 l_c_cost_budget_version_id(i),
		 -1,
		 l_c_task_id(i),
		 l_c_resource_list_member_id(i),
		 null,
		 'A');
      /* ---- populate the PERIODS PL/SQL table with the following rows ---- */
      /* ---- COST, REVENUE, MARGIN, MARGIN_PERCENT, LABOR_HOURS        ---- */
      /* 11/12/2002:  populate the rows only if flag = 'Y'		     */
      /* ONLY if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'		 	     */
      -- use the COST version as the source for COST row
      l_cur_resource_assignment_id := l_c_cost_res_assignment_id(i);
     if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P' then
      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_QUANTITY = 'Y' then
      -- process the QUANTITY row based on the value of l_report_labor_hrs_from_code
      if l_report_labor_hrs_from_code = 'COST' then
        l_row_number := l_row_number + 1;  -- increment row counter
        l_pd_project_id(l_row_number) := l_c_project_id(i);
        l_pd_task_id(l_row_number) := l_c_task_id(i);
        l_pd_resource_list_member_id(l_row_number) := l_c_resource_list_member_id(i);
    	l_pd_unit_of_measure(l_row_number) := l_c_unit_of_measure(i);
        l_pd_cost_budget_version_id(l_row_number) := l_c_cost_budget_version_id(i);
        l_pd_cost_res_assignment_id(l_row_number) := l_c_cost_res_assignment_id(i);
        l_pd_revenue_budget_version_id(l_row_number) := -1;
        l_pd_revenue_res_assignment_id(l_row_number) := -1;
        l_pd_element_name(l_row_number) := l_c_element_name(i);
        l_pd_element_level(l_row_number) := l_c_element_level(i);
        l_pd_row_level(l_row_number) := l_c_row_level(i);
        l_pd_line_editable_flag(l_row_number) := l_c_line_editable_flag(i);
        l_pd_parent_element_name(l_row_number) := l_c_parent_element_name(i);
        l_pd_amount_type(l_row_number) := 'QUANTITY';
        l_pd_amount_subtype(l_row_number) := 'QUANTITY';
        l_pd_amount_type_id(l_row_number) := 215; -- amount_type_id of 'QUANTITY'
        l_pd_amount_subtype_id(l_row_number) := 215; -- amount_subtype_id of 'QUANTITY'
        -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
        if not ((l_default_amount_type_code = 'QUANTITY') and
                (l_default_amount_subtype_code = 'QUANTITY')) then
          l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
          l_pd_element_name(l_row_number) := null;
	  l_pd_has_child_element(l_row_number) := 'N';
	else
	  l_pd_has_child_element(l_row_number) := 'Y';
        end if;
        l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 1);
        l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 2);
        l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 3);
        l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 4);
        l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 5);
        l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 6);
        l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 7);
        l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 8);
        l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 9);
        l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 10);
        l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 11);
        l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 12);
        l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 13);
        l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 0);
        l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 14);
	l_pd_project_total(l_row_number) := l_c_labor_hours(i); -- bug 2699651
      -- we need to insert an empty QUANTITY row if it's not reported from COST version
      else
        l_row_number := l_row_number + 1;  -- increment row counter
        l_pd_project_id(l_row_number) := l_c_project_id(i);
        l_pd_task_id(l_row_number) := l_c_task_id(i);
        l_pd_resource_list_member_id(l_row_number) := l_c_resource_list_member_id(i);
    	l_pd_unit_of_measure(l_row_number) := l_c_unit_of_measure(i);
        l_pd_cost_budget_version_id(l_row_number) := l_c_cost_budget_version_id(i);
        l_pd_cost_res_assignment_id(l_row_number) := l_c_cost_res_assignment_id(i);
        l_pd_revenue_budget_version_id(l_row_number) := -1;
        l_pd_revenue_res_assignment_id(l_row_number) := -1;
        l_pd_element_name(l_row_number) := l_c_element_name(i);
        l_pd_element_level(l_row_number) := l_c_element_level(i);
        l_pd_row_level(l_row_number) := l_c_row_level(i);
        --l_pd_line_editable_flag(l_row_number) := l_c_line_editable_flag(i);
	l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit dummy insert
        l_pd_parent_element_name(l_row_number) := l_c_parent_element_name(i);
        l_pd_amount_type(l_row_number) := 'QUANTITY';
        l_pd_amount_subtype(l_row_number) := 'QUANTITY';
        l_pd_amount_type_id(l_row_number) := 215; -- amount_type_id of QUANTITY
        l_pd_amount_subtype_id(l_row_number) := 215; -- amount_subtype_id of QUANTITY
        -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
        if not ((l_default_amount_type_code = 'QUANTITY') and
                (l_default_amount_subtype_code = 'QUANTITY')) then
          l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
          l_pd_element_name(l_row_number) := null;
	  l_pd_has_child_element(l_row_number) := 'N';
	else
	  l_pd_has_child_element(l_row_number) := 'Y';
        end if;
        l_pd_period_1(l_row_number) := null;
        l_pd_period_2(l_row_number) := null;
        l_pd_period_3(l_row_number) := null;
        l_pd_period_4(l_row_number) := null;
        l_pd_period_5(l_row_number) := null;
        l_pd_period_6(l_row_number) := null;
        l_pd_period_7(l_row_number) := null;
        l_pd_period_8(l_row_number) := null;
        l_pd_period_9(l_row_number) := null;
        l_pd_period_10(l_row_number) := null;
        l_pd_period_11(l_row_number) := null;
        l_pd_period_12(l_row_number) := null;
        l_pd_period_13(l_row_number) := null;
	l_pd_preceding(l_row_number) := null;
	l_pd_succeeding(l_row_number) := null;
	l_pd_project_total(l_row_number) := null; -- bug 2699651
      end if; -- QUANTITY
      end if; -- display_flag: QUANTITY

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_BURDCOST = 'Y' then
      -- process the BURDENED_COST row for this COST version
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_c_project_id(i);
      l_pd_task_id(l_row_number) := l_c_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_c_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := null;
      l_pd_cost_budget_version_id(l_row_number) := l_c_cost_budget_version_id(i);
      l_pd_cost_res_assignment_id(l_row_number) := l_c_cost_res_assignment_id(i);
      l_pd_revenue_budget_version_id(l_row_number) := -1;
      l_pd_revenue_res_assignment_id(l_row_number) := -1;
      l_pd_element_name(l_row_number) := l_c_element_name(i);
      l_pd_element_level(l_row_number) := l_c_element_level(i);
      l_pd_row_level(l_row_number) := l_c_row_level(i);
      l_pd_line_editable_flag(l_row_number) := l_c_line_editable_flag(i);
      l_pd_parent_element_name(l_row_number) := l_c_parent_element_name(i);
      l_pd_amount_type(l_row_number) := 'COST';
      l_pd_amount_subtype(l_row_number) := 'BURDENED_COST';
      l_pd_amount_type_id(l_row_number) := 150; -- amount_type_id for 'COST'
      l_pd_amount_subtype_id(l_row_number) := 165; -- amount_subtype_id for 'BURDENED_COST'
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'COST') and
              (l_default_amount_subtype_code = 'BURDENED_COST')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 165,
                    p_period_number        => 1);
      l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 165,
                    p_period_number        => 2);
      l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 165,
                    p_period_number        => 3);
      l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 165,
                    p_period_number        => 4);
      l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 5);
      l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 165,
                    p_period_number        => 6);
      l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 165,
                    p_period_number        => 7);
      l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 165,
                    p_period_number        => 8);
      l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 165,
                    p_period_number        => 9);
      l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 165,
                    p_period_number        => 10);
      l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 165,
                    p_period_number        => 11);
      l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 165,
                    p_period_number        => 12);
      l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 165,
                    p_period_number        => 13);
      l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 165,
                    p_period_number        => 0);
      l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 165,
                    p_period_number        => 14);
      l_pd_project_total(l_row_number) := l_c_burdened_cost(i); -- bug 2699651
      end if; -- display_flag: BURDENED_COST

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_RAWCOST = 'Y' then
      -- process the RAW_COST row for this COST version
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_c_project_id(i);
      l_pd_task_id(l_row_number) := l_c_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_c_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := null;
      l_pd_cost_budget_version_id(l_row_number) := l_c_cost_budget_version_id(i);
      l_pd_cost_res_assignment_id(l_row_number) := l_c_cost_res_assignment_id(i);
      l_pd_revenue_budget_version_id(l_row_number) := -1;
      l_pd_revenue_res_assignment_id(l_row_number) := -1;
      l_pd_element_name(l_row_number) := l_c_element_name(i);
      l_pd_element_level(l_row_number) := l_c_element_level(i);
      l_pd_row_level(l_row_number) := l_c_row_level(i);
      l_pd_line_editable_flag(l_row_number) := l_c_line_editable_flag(i);
      l_pd_parent_element_name(l_row_number) := l_c_parent_element_name(i);
      l_pd_amount_type(l_row_number) := 'COST';
      l_pd_amount_subtype(l_row_number) := 'RAW_COST';
      l_pd_amount_type_id(l_row_number) := 150; -- amount_type_id for 'COST'
      l_pd_amount_subtype_id(l_row_number) := 160; -- amount_subtype_id for 'RAW_COST'
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'COST') and
              (l_default_amount_subtype_code = 'RAW_COST')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 160,
                    p_period_number        => 1);
      l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 160,
                    p_period_number        => 2);
      l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 160,
                    p_period_number        => 3);
      l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 160,
                    p_period_number        => 4);
      l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 160,
                    p_period_number        => 5);
      l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 160,
                    p_period_number        => 6);
      l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 160,
                    p_period_number        => 7);
      l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 160,
                    p_period_number        => 8);
      l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 160,
                    p_period_number        => 9);
      l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 160,
                    p_period_number        => 10);
      l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 160,
                    p_period_number        => 11);
      l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 160,
                    p_period_number        => 12);
      l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 160,
                    p_period_number        => 13);
      l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 160,
                    p_period_number        => 0);
      l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_cost_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_cost_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 160,
                    p_period_number        => 14);
      l_pd_project_total(l_row_number) := l_c_raw_cost(i); -- bug 2699651
      end if; -- display_flag: RAW COST

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_REVENUE = 'Y' then
      -- insert (0'S) for REVENUE row
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_c_project_id(i);
      l_pd_task_id(l_row_number) := l_c_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_c_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := null;
      l_pd_cost_budget_version_id(l_row_number) := l_c_cost_budget_version_id(i);
      l_pd_cost_res_assignment_id(l_row_number) := l_c_cost_res_assignment_id(i);
      l_pd_revenue_budget_version_id(l_row_number) := -1;
      l_pd_revenue_res_assignment_id(l_row_number) := -1;
      l_pd_element_name(l_row_number) := l_c_element_name(i);
      l_pd_element_level(l_row_number) := l_c_element_level(i);
      l_pd_row_level(l_row_number) := l_c_row_level(i);
      --l_pd_line_editable_flag(l_row_number) := l_c_line_editable_flag(i);
      l_pd_line_editable_flag(l_row_number) := 'N'; -- there is no revenue RAID
      l_pd_parent_element_name(l_row_number) := l_c_parent_element_name(i);
      l_pd_amount_type(l_row_number) := 'REVENUE';
      l_pd_amount_subtype(l_row_number) := 'REVENUE';
      l_pd_amount_type_id(l_row_number) := 100; -- amount_type_id of REVENUE
      l_pd_amount_subtype_id(l_row_number) := 100; -- amount_subtype_id of REVENUE
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'REVENUE') and
              (l_default_amount_subtype_code = 'REVENUE')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := null;
      l_pd_period_2(l_row_number) := null;
      l_pd_period_3(l_row_number) := null;
      l_pd_period_4(l_row_number) := null;
      l_pd_period_5(l_row_number) := null;
      l_pd_period_6(l_row_number) := null;
      l_pd_period_7(l_row_number) := null;
      l_pd_period_8(l_row_number) := null;
      l_pd_period_9(l_row_number) := null;
      l_pd_period_10(l_row_number) := null;
      l_pd_period_11(l_row_number) := null;
      l_pd_period_12(l_row_number) := null;
      l_pd_period_13(l_row_number) := null;
      l_pd_preceding(l_row_number) := null;
      l_pd_succeeding(l_row_number) := null;
      l_pd_project_total(l_row_number) := null; -- bug 2699651
      end if; -- display_flag: REVENUE

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGIN = 'Y' then
      -- insert (0's) for MARGIN row
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_c_project_id(i);
      l_pd_task_id(l_row_number) := l_c_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_c_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := null;
      l_pd_cost_budget_version_id(l_row_number) := l_c_cost_budget_version_id(i);
      l_pd_cost_res_assignment_id(l_row_number) := l_c_cost_res_assignment_id(i);
      l_pd_revenue_budget_version_id(l_row_number) := -1;
      l_pd_revenue_res_assignment_id(l_row_number) := -1;
      l_pd_element_name(l_row_number) := l_c_element_name(i);
      l_pd_element_level(l_row_number) := l_c_element_level(i);
      l_pd_row_level(l_row_number) := l_c_row_level(i);
      --l_pd_line_editable_flag(l_row_number) := l_c_line_editable_flag(i);
      l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit inserted row
      l_pd_parent_element_name(l_row_number) := l_c_parent_element_name(i);
      l_pd_amount_type(l_row_number) := 'MARGIN';
      l_pd_amount_subtype(l_row_number) := 'MARGIN';
      l_pd_amount_type_id(l_row_number) := 230; -- amount_type_id of MARGIN
      l_pd_amount_subtype_id(l_row_number) := 230; -- amount_subtype_id of MARGIN
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'MARGIN') and
              (l_default_amount_subtype_code = 'MARGIN')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := null;
      l_pd_period_2(l_row_number) := null;
      l_pd_period_3(l_row_number) := null;
      l_pd_period_4(l_row_number) := null;
      l_pd_period_5(l_row_number) := null;
      l_pd_period_6(l_row_number) := null;
      l_pd_period_7(l_row_number) := null;
      l_pd_period_8(l_row_number) := null;
      l_pd_period_9(l_row_number) := null;
      l_pd_period_10(l_row_number) := null;
      l_pd_period_11(l_row_number) := null;
      l_pd_period_12(l_row_number) := null;
      l_pd_period_13(l_row_number) := null;
      l_pd_preceding(l_row_number) := null;
      l_pd_succeeding(l_row_number) := null;
      l_pd_project_total(l_row_number) := null; -- bug 2699651
      end if; -- display_flag: MARGIN

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGINPCT = 'Y' then
      -- insert (0'S) for MARGIN_PERCENT row
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_c_project_id(i);
      l_pd_task_id(l_row_number) := l_c_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_c_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := null;
      l_pd_cost_budget_version_id(l_row_number) := l_c_cost_budget_version_id(i);
      l_pd_cost_res_assignment_id(l_row_number) := l_c_cost_res_assignment_id(i);
      l_pd_revenue_budget_version_id(l_row_number) := -1;
      l_pd_revenue_res_assignment_id(l_row_number) := -1;
      l_pd_element_name(l_row_number) := l_c_element_name(i);
      l_pd_element_level(l_row_number) := l_c_element_level(i);
      l_pd_row_level(l_row_number) := l_c_row_level(i);
      --l_pd_line_editable_flag(l_row_number) := l_c_line_editable_flag(i);
      l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit inserted row
      l_pd_parent_element_name(l_row_number) := l_c_parent_element_name(i);
      l_pd_amount_type(l_row_number) := 'MARGIN_PERCENT';
      l_pd_amount_subtype(l_row_number) := 'MARGIN_PERCENT';
      l_pd_amount_type_id(l_row_number) := 231; -- amount_type_id of MARGIN_PERCENT
      l_pd_amount_subtype_id(l_row_number) := 231; -- amount_subtype_id of MARGIN_PERCENT
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'MARGIN_PERCENT') and
              (l_default_amount_subtype_code = 'MARGIN_PERCENT')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := null;
      l_pd_period_2(l_row_number) := null;
      l_pd_period_3(l_row_number) := null;
      l_pd_period_4(l_row_number) := null;
      l_pd_period_5(l_row_number) := null;
      l_pd_period_6(l_row_number) := null;
      l_pd_period_7(l_row_number) := null;
      l_pd_period_8(l_row_number) := null;
      l_pd_period_9(l_row_number) := null;
      l_pd_period_10(l_row_number) := null;
      l_pd_period_11(l_row_number) := null;
      l_pd_period_12(l_row_number) := null;
      l_pd_period_13(l_row_number) := null;
      l_pd_preceding(l_row_number) := null;
      l_pd_succeeding(l_row_number) := null;
      l_pd_project_total(l_row_number) := null; -- bug 2699651
      end if; -- display_flag: MARGIN PERCENT
     end if; -- pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'
    end if; -- not found_complement
  end loop; -- COST PL/SQL loop
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_separate', '400: iterated through cost pl/sql table', 1);
l_err_stage := 600;
  -- after looping through the COST PL/SQL table, iterate through the REVENUE PL/SQL
  -- table, and copy over the untouched rows for PERIOD PL/SQL table
  for k in nvl(l_r_project_id.first,0)..nvl(l_r_project_id.last,-1) loop

    -- copy over the REVENUE PL/SQL rows into PERIODS PL/SQL table, padding cost #'s with 0's
    l_cur_resource_assignment_id := l_r_revenue_res_assignment_id(k);

   if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P' then
    if pa_fp_view_plans_pub.G_DISPLAY_FLAG_QUANTITY = 'Y' then
    -- process the QUANTITY row based on the value of l_report_labor_hrs_from_code
    if l_report_labor_hrs_from_code = 'REVENUE' then
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_r_project_id(k);
      l_pd_task_id(l_row_number) := l_r_task_id(k);
      l_pd_resource_list_member_id(l_row_number) := l_r_resource_list_member_id(k);
      l_pd_unit_of_measure(l_row_number) := l_r_unit_of_measure(k);
      l_pd_cost_budget_version_id(l_row_number) := -1;
      l_pd_cost_res_assignment_id(l_row_number) := -1;
      l_pd_revenue_budget_version_id(l_row_number) := l_r_revenue_budget_version_id(k);
      l_pd_revenue_res_assignment_id(l_row_number) := l_r_revenue_res_assignment_id(k);
      l_pd_element_name(l_row_number) := l_r_element_name(k);
      l_pd_element_level(l_row_number) := l_r_element_level(k);
      l_pd_row_level(l_row_number) := l_r_row_level(k);
      l_pd_line_editable_flag(l_row_number) := l_r_line_editable_flag(k);
      l_pd_parent_element_name(l_row_number) := l_r_parent_element_name(k);
      l_pd_amount_type(l_row_number) := 'QUANTITY';
      l_pd_amount_subtype(l_row_number) := 'QUANTITY';
      l_pd_amount_type_id(l_row_number) := 215; -- amount_type_id of 'QUANTITY'
      l_pd_amount_subtype_id(l_row_number) := 215; -- amount_subtype_id of 'QUANTITY'
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'QUANTITY') and
              (l_default_amount_subtype_code = 'QUANTITY')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
        l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 1);
      l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 2);
      l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 3);
      l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 4);
      l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 5);
      l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 6);
      l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 7);
      l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 8);
      l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 9);
      l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 10);
      l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 11);
      l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 12);
      l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 13);
      l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 0);
      l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 14);
      l_pd_project_total(l_row_number) := l_r_labor_hours(k); -- bug 2699651
      -- we need to insert an empty QUANTITY row if it's not reported from REVENUE version
    else
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_r_project_id(k);
      l_pd_task_id(l_row_number) := l_r_task_id(k);
      l_pd_resource_list_member_id(l_row_number) := l_r_resource_list_member_id(k);
      l_pd_unit_of_measure(l_row_number) := l_r_unit_of_measure(k);
      l_pd_cost_budget_version_id(l_row_number) := -1;
      l_pd_cost_res_assignment_id(l_row_number) := -1;
      l_pd_revenue_budget_version_id(l_row_number) := l_r_revenue_budget_version_id(k);
      l_pd_revenue_res_assignment_id(l_row_number) := l_r_revenue_res_assignment_id(k);
      l_pd_element_name(l_row_number) := l_r_element_name(k);
      l_pd_element_level(l_row_number) := l_r_element_level(k);
      l_pd_row_level(l_row_number) := l_r_row_level(k);
      --l_pd_line_editable_flag(l_row_number) := l_r_line_editable_flag(k);
      l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit inserted row
      l_pd_parent_element_name(l_row_number) := l_r_parent_element_name(k);
      l_pd_amount_type(l_row_number) := 'QUANTITY';
      l_pd_amount_subtype(l_row_number) := 'QUANTITY';
      l_pd_amount_type_id(l_row_number) := 215; -- amount_type_id of QUANTITY
      l_pd_amount_subtype_id(l_row_number) := 215; -- amount_subtype_id of QUANTITY
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'QUANTITY') and
              (l_default_amount_subtype_code = 'QUANTITY')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := null;
      l_pd_period_2(l_row_number) := null;
      l_pd_period_3(l_row_number) := null;
      l_pd_period_4(l_row_number) := null;
      l_pd_period_5(l_row_number) := null;
      l_pd_period_6(l_row_number) := null;
      l_pd_period_7(l_row_number) := null;
      l_pd_period_8(l_row_number) := null;
      l_pd_period_9(l_row_number) := null;
      l_pd_period_10(l_row_number) := null;
      l_pd_period_11(l_row_number) := null;
      l_pd_period_12(l_row_number) := null;
      l_pd_period_13(l_row_number) := null;
      l_pd_preceding(l_row_number) := null;
      l_pd_succeeding(l_row_number) := null;
      l_pd_project_total(l_row_number) := null; -- bug 2699651
    end if; -- QUANTITY
    end if; -- display_flag: QUANTITY

    if pa_fp_view_plans_pub.G_DISPLAY_FLAG_REVENUE = 'Y' then
    -- process the REVENUE row for this REVENUE version
    l_row_number := l_row_number + 1;  -- increment row counter
    l_pd_project_id(l_row_number) := l_r_project_id(k);
    l_pd_task_id(l_row_number) := l_r_task_id(k);
    l_pd_resource_list_member_id(l_row_number) := l_r_resource_list_member_id(k);
    l_pd_unit_of_measure(l_row_number) := null;
    l_pd_cost_budget_version_id(l_row_number) := -1;
    l_pd_cost_res_assignment_id(l_row_number) := -1;
    l_pd_revenue_budget_version_id(l_row_number) := l_r_revenue_budget_version_id(k);
    l_pd_revenue_res_assignment_id(l_row_number) := l_r_revenue_res_assignment_id(k);
    l_pd_element_name(l_row_number) := l_r_element_name(k);
    l_pd_element_level(l_row_number) := l_r_element_level(k);
    l_pd_row_level(l_row_number) := l_r_row_level(k);
    l_pd_parent_element_name(l_row_number) := l_r_parent_element_name(k);
    l_pd_line_editable_flag(l_row_number) := l_r_line_editable_flag(k);
    l_pd_amount_type(l_row_number) := 'REVENUE';
    l_pd_amount_subtype(l_row_number) := 'REVENUE';
    l_pd_amount_type_id(l_row_number) := 100; -- amount_type_code of 'REVENUE'
    l_pd_amount_subtype_id(l_row_number) := 100; -- amount_subtype_code of 'REVENUE'
    -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
    if not ((l_default_amount_type_code = 'REVENUE') and
            (l_default_amount_subtype_code = 'REVENUE')) then
      l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
      l_pd_element_name(l_row_number) := null;
      l_pd_has_child_element(l_row_number) := 'N';
    else
      l_pd_has_child_element(l_row_number) := 'Y';
    end if;
    l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 1);
    l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 2);
    l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 3);
    l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 4);
    l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 5);
    l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 6);
    l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 7);
    l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 8);
    l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 9);
    l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 10);
    l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 11);
    l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 12);
    l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 13);
    l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 0);
    l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_revenue_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_revenue_res_assignment_id(l_row_number),
		    p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 14);
    l_pd_project_total(l_row_number) := l_r_revenue(k); -- bug 2699651
    end if; -- display_flag: REVENUE

    if pa_fp_view_plans_pub.G_DISPLAY_FLAG_BURDCOST = 'Y' then
    -- insert (0'S) for BURDENED_COST row
    l_row_number := l_row_number + 1;  -- increment row counter
    l_pd_project_id(l_row_number) := l_r_project_id(k);
    l_pd_task_id(l_row_number) := l_r_task_id(k);
    l_pd_resource_list_member_id(l_row_number) := l_r_resource_list_member_id(k);
    l_pd_unit_of_measure(l_row_number) := null;
    l_pd_cost_budget_version_id(l_row_number) := -1;
    l_pd_cost_res_assignment_id(l_row_number) := -1;
    l_pd_revenue_budget_version_id(l_row_number) := l_r_revenue_budget_version_id(k);
    l_pd_revenue_res_assignment_id(l_row_number) := l_r_revenue_res_assignment_id(k);
    l_pd_element_name(l_row_number) := l_r_element_name(k);
    l_pd_element_level(l_row_number) := l_r_element_level(k);
    l_pd_row_level(l_row_number) := l_r_row_level(k);
    l_pd_parent_element_name(l_row_number) := l_r_parent_element_name(k);
    --l_pd_line_editable_flag(l_row_number) := l_r_line_editable_flag(k);
    l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit inserted rows
    l_pd_amount_type(l_row_number) := 'COST';
    l_pd_amount_subtype(l_row_number) := 'BURDENED_COST';
    l_pd_amount_type_id(l_row_number) := 150; -- amount_type_id of COST
    l_pd_amount_subtype_id(l_row_number) := 165; -- amount_subtype_id of BURDENED_COST
    -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
    if not ((l_default_amount_type_code = 'COST') and
            (l_default_amount_subtype_code = 'BURDENED_COST')) then
      l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
      l_pd_element_name(l_row_number) := null;
      l_pd_has_child_element(l_row_number) := 'N';
    else
      l_pd_has_child_element(l_row_number) := 'Y';
    end if;
    l_pd_period_1(l_row_number) := null;
    l_pd_period_2(l_row_number) := null;
    l_pd_period_3(l_row_number) := null;
    l_pd_period_4(l_row_number) := null;
    l_pd_period_5(l_row_number) := null;
    l_pd_period_6(l_row_number) := null;
    l_pd_period_7(l_row_number) := null;
    l_pd_period_8(l_row_number) := null;
    l_pd_period_9(l_row_number) := null;
    l_pd_period_10(l_row_number) := null;
    l_pd_period_11(l_row_number) := null;
    l_pd_period_12(l_row_number) := null;
    l_pd_period_13(l_row_number) := null;
    l_pd_preceding(l_row_number) := null;
    l_pd_succeeding(l_row_number) := null;
    l_pd_project_total(l_row_number) := null; -- bug 2699651
    end if; -- display_flag: BURDENED COST

    if pa_fp_view_plans_pub.G_DISPLAY_FLAG_RAWCOST = 'Y' then
    -- insert (0'S) for RAW_COST row
    l_row_number := l_row_number + 1;  -- increment row counter
    l_pd_project_id(l_row_number) := l_r_project_id(k);
    l_pd_task_id(l_row_number) := l_r_task_id(k);
    l_pd_resource_list_member_id(l_row_number) := l_r_resource_list_member_id(k);
    l_pd_unit_of_measure(l_row_number) := null;
    l_pd_cost_budget_version_id(l_row_number) := -1;
    l_pd_cost_res_assignment_id(l_row_number) := -1;
    l_pd_revenue_budget_version_id(l_row_number) := l_r_revenue_budget_version_id(k);
    l_pd_revenue_res_assignment_id(l_row_number) := l_r_revenue_res_assignment_id(k);
    l_pd_element_name(l_row_number) := l_r_element_name(k);
    l_pd_element_level(l_row_number) := l_r_element_level(k);
    l_pd_row_level(l_row_number) := l_r_row_level(k);
    l_pd_parent_element_name(l_row_number) := l_r_parent_element_name(k);
    --l_pd_line_editable_flag(l_row_number) := l_r_line_editable_flag(k);
    l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit inserted row
    l_pd_amount_type(l_row_number) := 'COST';
    l_pd_amount_subtype(l_row_number) := 'RAW_COST';
    l_pd_amount_type_id(l_row_number) := 150; -- amount_type_id of COST
    l_pd_amount_subtype_id(l_row_number) := 160; -- amount_subtype_id of BURDENED_COST
    -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
    if not ((l_default_amount_type_code = 'COST') and
            (l_default_amount_subtype_code = 'RAW_COST')) then
      l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
      l_pd_element_name(l_row_number) := null;
      l_pd_has_child_element(l_row_number) := 'N';
    else
      l_pd_has_child_element(l_row_number) := 'Y';
    end if;
    l_pd_period_1(l_row_number) := null;
    l_pd_period_2(l_row_number) := null;
    l_pd_period_3(l_row_number) := null;
    l_pd_period_4(l_row_number) := null;
    l_pd_period_5(l_row_number) := null;
    l_pd_period_6(l_row_number) := null;
    l_pd_period_7(l_row_number) := null;
    l_pd_period_8(l_row_number) := null;
    l_pd_period_9(l_row_number) := null;
    l_pd_period_10(l_row_number) := null;
    l_pd_period_11(l_row_number) := null;
    l_pd_period_12(l_row_number) := null;
    l_pd_period_13(l_row_number) := null;
    l_pd_preceding(l_row_number) := null;
    l_pd_succeeding(l_row_number) := null;
    l_pd_project_total(l_row_number) := null; -- bug 2699651
    end if; -- display_flag: RAW COST

    if pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGIN = 'Y' then
    -- insert (0'S) for MARGIN row
    l_row_number := l_row_number + 1;  -- increment row counter
    l_pd_project_id(l_row_number) := l_r_project_id(k);
    l_pd_task_id(l_row_number) := l_r_task_id(k);
    l_pd_resource_list_member_id(l_row_number) := l_r_resource_list_member_id(k);
    l_pd_unit_of_measure(l_row_number) := null;
    l_pd_cost_budget_version_id(l_row_number) := -1;
    l_pd_cost_res_assignment_id(l_row_number) := -1;
    l_pd_revenue_budget_version_id(l_row_number) := l_r_revenue_budget_version_id(k);
    l_pd_revenue_res_assignment_id(l_row_number) := l_r_revenue_res_assignment_id(k);
    l_pd_element_name(l_row_number) := l_r_element_name(k);
    l_pd_element_level(l_row_number) := l_r_element_level(k);
    l_pd_row_level(l_row_number) := l_r_row_level(k);
    --l_pd_line_editable_flag(l_row_number) := l_r_line_editable_flag(k);
    l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit inserted row
    l_pd_parent_element_name(l_row_number) := l_r_parent_element_name(k);
    l_pd_amount_type(l_row_number) := 'MARGIN';
    l_pd_amount_subtype(l_row_number) := 'MARGIN';
    l_pd_amount_type_id(l_row_number) := 230; -- amount_type_id of MARGIN
    l_pd_amount_subtype_id(l_row_number) := 230; -- amount_type_id of MARGIN
    -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
    if not ((l_default_amount_type_code = 'MARGIN') and
            (l_default_amount_subtype_code = 'MARGIN')) then
      l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
      l_pd_element_name(l_row_number) := null;
      l_pd_has_child_element(l_row_number) := 'N';
    else
      l_pd_has_child_element(l_row_number) := 'Y';
    end if;
    l_pd_period_1(l_row_number) := null;
    l_pd_period_2(l_row_number) := null;
    l_pd_period_3(l_row_number) := null;
    l_pd_period_4(l_row_number) := null;
    l_pd_period_5(l_row_number) := null;
    l_pd_period_6(l_row_number) := null;
    l_pd_period_7(l_row_number) := null;
    l_pd_period_8(l_row_number) := null;
    l_pd_period_9(l_row_number) := null;
    l_pd_period_10(l_row_number) := null;
    l_pd_period_11(l_row_number) := null;
    l_pd_period_12(l_row_number) := null;
    l_pd_period_13(l_row_number) := null;
    l_pd_preceding(l_row_number) := null;
    l_pd_succeeding(l_row_number) := null;
    l_pd_project_total(l_row_number) := null; -- bug 2699651
    end if; -- display_flag: MARGIN

    if pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGINPCT = 'Y' then
    -- insert (0'S) for MARGIN_PERCENT row
    l_row_number := l_row_number + 1;  -- increment row counter
    l_pd_project_id(l_row_number) := l_r_project_id(k);
    l_pd_task_id(l_row_number) := l_r_task_id(k);
    l_pd_resource_list_member_id(l_row_number) := l_r_resource_list_member_id(k);
    l_pd_unit_of_measure(l_row_number) := null;
    l_pd_cost_budget_version_id(l_row_number) := -1;
    l_pd_cost_res_assignment_id(l_row_number) := -1;
    l_pd_revenue_budget_version_id(l_row_number) := l_r_revenue_budget_version_id(k);
    l_pd_revenue_res_assignment_id(l_row_number) := l_r_revenue_res_assignment_id(k);
    l_pd_element_name(l_row_number) := l_r_element_name(k);
    l_pd_element_level(l_row_number) := l_r_element_level(k);
    l_pd_row_level(l_row_number) := l_r_row_level(k);
    --l_pd_line_editable_flag(l_row_number) := l_r_line_editable_flag(k);
    l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit inserted row
    l_pd_parent_element_name(l_row_number) := l_r_parent_element_name(k);
    l_pd_amount_type(l_row_number) := 'MARGIN_PERCENT';
    l_pd_amount_subtype(l_row_number) := 'MARGIN_PERCENT';
    l_pd_amount_type_id(l_row_number) := 231; -- amount_type_id of MARGIN_PERCENT
    l_pd_amount_subtype_id(l_row_number) := 231; -- amount_type_id of MARGIN_PERCENT
    -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
    if not ((l_default_amount_type_code = 'MARGIN_PERCENT') and
            (l_default_amount_subtype_code = 'MARGIN_PERCENT')) then
      l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
      l_pd_element_name(l_row_number) := null;
      l_pd_has_child_element(l_row_number) := 'N';
    else
      l_pd_has_child_element(l_row_number) := 'Y';
    end if;
    l_pd_period_1(l_row_number) := null;
    l_pd_period_2(l_row_number) := null;
    l_pd_period_3(l_row_number) := null;
    l_pd_period_4(l_row_number) := null;
    l_pd_period_5(l_row_number) := null;
    l_pd_period_6(l_row_number) := null;
    l_pd_period_7(l_row_number) := null;
    l_pd_period_8(l_row_number) := null;
    l_pd_period_9(l_row_number) := null;
    l_pd_period_10(l_row_number) := null;
    l_pd_period_11(l_row_number) := null;
    l_pd_period_12(l_row_number) := null;
    l_pd_period_13(l_row_number) := null;
    l_pd_preceding(l_row_number) := null;
    l_pd_succeeding(l_row_number) := null;
    l_pd_project_total(l_row_number) := null; -- bug 2699651
    end if; -- display_flag: MARGIN PERCENT
   end if; -- pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'
  end loop; -- REVENUE PL/SQL loop: the untouched rows
l_err_stage := 700;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_separate', '500: iterated through rev pl/sql table', 1);

  /* TRANSFER DATA FROM PL/SQL TABLES TO GLOBAL TEMPORARY TABLES */

  -- POPULATE global temporary table PA_FIN_VP_AMTS_VIEW_TMP from the
  -- COST PL/SQL table
  -- rows in the COST PL/SQL table

  if pa_fp_view_plans_pub.G_AMT_OR_PD = 'A' then
    forall x in nvl(l_c_project_id.first,0)..nvl(l_c_project_id.last,-1)
      insert into pa_fin_vp_amts_view_tmp
        (project_id,
         task_id,
         resource_list_member_id,
         element_name,
         element_level,
         labor_hours,
         burdened_cost,
         raw_cost,
         revenue,
         margin,
         margin_percent,
         editable_flag,
   	 row_level,
         parent_element_name,
	 cost_resource_assignment_id,
	 rev_resource_assignment_id,
	 all_resource_assignment_id,
	 unit_of_measure,
	 has_child_element) values
        (l_c_project_id(x),
         l_c_task_id(x),
         l_c_resource_list_member_id(x),
         l_c_element_name(x),
         l_c_element_level(x),
         l_c_labor_hours(x),
         l_c_burdened_cost(x),
         l_c_raw_cost(x),
         l_c_revenue(x),
         l_c_margin(x),
         l_c_margin_percent(x),
         l_c_line_editable_flag(x),
 	 l_c_row_level(x),
         l_c_parent_element_name(x),
	 l_c_cost_res_assignment_id(x),
	 l_c_revenue_res_assignment_id(x),
	 -1,
	 l_c_unit_of_measure(x),
	 l_c_has_child_element(x));
l_err_stage := 800;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_separate', '600: transfer from cost pl/sql table to amts_tmp table', 1);
  -- rows in the REVENUE PL/SQL table
    forall y in nvl(l_r_project_id.first,0)..nvl(l_r_project_id.last,-1)
      insert into pa_fin_vp_amts_view_tmp
        (project_id,
         task_id,
         resource_list_member_id,
         element_name,
         element_level,
         labor_hours,
         burdened_cost,
         raw_cost,
         revenue,
         margin,
         margin_percent,
         editable_flag,
         row_level,
         parent_element_name,
	 cost_resource_assignment_id,
	 rev_resource_assignment_id,
	 all_resource_assignment_id,
	 unit_of_measure,
	 has_child_element) values
        (l_r_project_id(y),
         l_r_task_id(y),
         l_r_resource_list_member_id(y),
         l_r_element_name(y),
         l_r_element_level(y),
         l_r_labor_hours(y),
         0, -- burdened_cost
         0, -- raw_cost
         l_r_revenue(y),
         0, -- margin
         0, -- margin_percent
         l_r_line_editable_flag(y),
	 l_r_row_level(y),
         l_r_parent_element_name(y),
	 -1,
	 l_r_revenue_res_assignment_id(y),
	 -1,
	 l_r_unit_of_measure(y),
	 'Y'); -- PERFORMANCE LIABILITY: FOR UNMARRIED REVENUE ROWS, WE SAY ALWAYS HAVE CHILD
  end if; -- pa_fp_view_plans_pub.G_AMT_OR_PD= 'A'
l_err_stage := 900;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_separate', '700: transfer from rev pl/sql table to amts_tmp table', 1);
--hr_utility.trace('total rows is ' || to_char(nvl(l_c_project_id.last,0) + nvl(l_r_project_id.last,0)));
  -- POPULATE global temporary table PA_FIN_VP_PDS_VIEW_TMP from the
  -- PERIODS PL/SQL table
  if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P' then
--hr_utility.trace('inserting into pa_fin_vp_pds_view_tmp for POP_TEM_TABLES_SEP');
--hr_utility.trace('l_pd_project_id.last= ' || to_char(l_pd_project_id.last));
    forall z in nvl(l_pd_project_id.first,0)..nvl(l_pd_project_id.last,-1)
      insert into pa_fin_vp_pds_view_tmp
        (project_id,
         task_id,
         resource_list_member_id,
	 uom,
         element_name,
         element_level,
         editable_flag,
         row_level,
         parent_element_name,
         amount_type,
         amount_subtype,
         amount_type_id,
         amount_subtype_id,
         period_amount1,
         period_amount2,
         period_amount3,
         period_amount4,
         period_amount5,
         period_amount6,
         period_amount7,
         period_amount8,
         period_amount9,
         period_amount10,
         period_amount11,
         period_amount12,
         period_amount13,
	 cost_resource_assignment_id,
	 rev_resource_assignment_id,
	 all_resource_assignment_id,
	 preceding_periods_amount,
	 succeeding_periods_amount,
	 has_child_element,
	 project_total) values
        (l_pd_project_id(z),
         l_pd_task_id(z),
         l_pd_resource_list_member_id(z),
	 l_pd_unit_of_measure(z),
         l_pd_element_name(z),
         l_pd_element_level(z),
         l_pd_line_editable_flag(z),
         l_pd_row_level(z),
         l_pd_parent_element_name(z),
         l_pd_amount_type(z),
         l_pd_amount_subtype(z),
         l_pd_amount_type_id(z),
         l_pd_amount_subtype_id(z),
         l_pd_period_1(z),
         l_pd_period_2(z),
         l_pd_period_3(z),
         l_pd_period_4(z),
         l_pd_period_5(z),
         l_pd_period_6(z),
         l_pd_period_7(z),
         l_pd_period_8(z),
         l_pd_period_9(z),
         l_pd_period_10(z),
         l_pd_period_11(z),
         l_pd_period_12(z),
         l_pd_period_13(z),
	 l_pd_cost_res_assignment_id(z),
	 l_pd_revenue_res_assignment_id(z),
	 -1,
	 l_pd_preceding(z),
	 l_pd_succeeding(z),
	 l_pd_has_child_element(z),
	 l_pd_project_total(z));
  end if; --pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'
l_err_stage:= 1000;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_separate', '700: transfer from pds pl/sql table to pds_tmp table', 1);
  commit;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_separate', '800: leaving procedure', 2);
EXCEPTION
when others then
      rollback to VIEW_PLANS_POP_TABLES_SEP;
--hr_utility.trace('error stage= ' || to_char(l_err_stage));
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FP_VIEW_PLANS_PUB',
                               p_procedure_name   => 'pa_fp_vp_pop_tables_separate');
      pa_debug.reset_err_stack;
      return;
end pa_fp_vp_pop_tables_separate;
/* ------------------------------------------------------------------ */

/* PROCEDURE: pa_fp_vp_pop_tables_together
 * Populates pa_fin_vp_amts_view_tmp assuming that both cost and revenue numbers are
 * stored in same budget version
 */
-- modified for new AMOUNT_TYPE_CODE and AMOUNT_SUBTYPE_CODE
-- modified for RAW_COST logic and MARGIN calculation logic 06/20/02
-- 11/12/2002 Dlai: updated cursors to select project OR projfunc amounts
--		     added logic for inserting rows for periodic view only if
--		     flag='Y' for that amount type
-- 11/25/2002 Dlai: select ra.total_plan_quantity for labor hours
-- 02/17/2003 Dlai: added l_pd_unit_of_measure (bug 2807032)
-- 02/20/2003 Dlai: added l_has_child_element/l_pd_has_child_element
-- 07/25/2003 Dlai: for PA_FIN_VP_PDS_VIEW_TMP, populate project_total
procedure pa_fp_vp_pop_tables_together
    (p_project_id           IN  pa_budget_versions.project_id%TYPE,
     p_budget_version_id    IN  pa_budget_versions.budget_version_id%TYPE,
     x_return_status            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                 OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is

  /* LOCAL VARIABLES */
  l_report_labor_hrs_from_code        pa_proj_fp_options.report_labor_hrs_from_code%TYPE;
  l_cur_resource_assignment_id        pa_resource_assignments.resource_assignment_id%TYPE;
  l_row_number                        NUMBER; -- keep track of number of rows in PERIODS PL/SQL table
  l_cost_row_number                   NUMBER; -- PERIODS PL/SQL: cost row for calculating margin
  l_revenue_row_number                NUMBER; -- PERIODS PL/SQL: rev row for calculating margin
  l_period_profile_id                 pa_proj_period_profiles.period_profile_id%TYPE; -- used to retrieve values for period numbers
  l_default_amount_type_code          pa_proj_fp_options.default_amount_type_code%TYPE;
  l_default_amount_subtype_code       pa_proj_fp_options.default_amount_subtype_code%TYPE;
  l_currency_type	              VARCHAR2(30);

   /* Added for bug 7514054 */
   cursor parent_tasks_csr(p_task_id in NUMBER) is
	select t.task_id from pa_tasks t
	START WITH t.task_id = p_task_id
	CONNECT BY prior t.parent_task_id = t.task_id;

   cursor rollup_period_amt_csr is
   select rowid, p.* from pa_fin_vp_pds_view_tmp p
   order by row_level desc;
  /* Ends added for 7514054 */

  cursor av_csr is
    select ra.project_id,
           ra.task_id,
           ra.resource_list_member_id,
           ra.budget_version_id,
           ra.resource_assignment_id,
           pa_fp_view_plans_util.assign_element_name
                (ra.project_id,
                 ra.task_id,
                 ra.resource_list_member_id) as element_name,  -- element_name
           pa_fp_view_plans_util.assign_element_level
                (ra.project_id,
		 ra.budget_version_id,
                 ra.task_id,
                 ra.resource_list_member_id) as element_level, -- element_level
--           ra.total_utilization_hours as labor_hours,
           ra.total_plan_quantity as labor_hours,
           DECODE(pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE,
		  'PROJ', ra.total_project_burdened_cost,
		  ra.total_plan_burdened_cost) as burdened_cost,  -- burdened_cost
           DECODE(pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE,
		  'PROJ', ra.total_project_raw_cost,
		  ra.total_plan_raw_cost) as raw_cost,  -- raw_cost
           DECODE(pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE,
		  'PROJ', ra.total_project_revenue,
		  ra.total_plan_revenue) as revenue,  -- revenue
           DECODE(pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE,
		  'PROJ', DECODE(pa_fp_view_plans_pub.G_FP_CALC_MARGIN_FROM,
			     'R', (ra.total_project_revenue - ra.total_project_raw_cost),
			     (ra.total_project_revenue - ra.total_project_burdened_cost)),
		  DECODE(pa_fp_view_plans_pub.G_FP_CALC_MARGIN_FROM,
		  'R', (ra.total_plan_revenue - total_plan_raw_cost),
		  (ra.total_plan_revenue - ra.total_plan_burdened_cost))) as margin,  -- margin
           DECODE(pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE,
		  'PROJ',
			 DECODE(ra.total_project_revenue,
                         0, 0,
                         null, null,
			 DECODE(pa_fp_view_plans_pub.G_FP_CALC_MARGIN_FROM,
			   'R', (ra.total_project_revenue - ra.total_project_raw_cost)/
				 ra.total_project_revenue,
                           (ra.total_project_revenue - ra.total_project_burdened_cost)/
			    ra.total_project_revenue)),
		  DECODE(ra.total_plan_revenue,
                         0, 0,
                         null, null,
                         DECODE(pa_fp_view_plans_pub.G_FP_CALC_MARGIN_FROM,
			   'R', (ra.total_plan_revenue - ra.total_plan_raw_cost)/
				 ra.total_plan_revenue,
			   (ra.total_plan_revenue - ra.total_plan_burdened_cost)/
			    ra.total_plan_revenue))) as margin_percent,  -- margin_percent
           DECODE(ra.resource_assignment_type,
                 'ROLLED_UP', 'N',
                 'USER_ENTERED', 'Y',
                 'Y') as line_editable_flag, -- line_editable_flag
           pa_fp_view_plans_util.assign_row_level
                (ra.project_id,
                 ra.task_id,
                 ra.resource_list_member_id) as row_level,
           pa_fp_view_plans_util.assign_parent_element
                (ra.project_id,
                 ra.task_id,
                 ra.resource_list_member_id) as parent_element_name,
	   ra.unit_of_measure,
	   pa_fp_view_plans_pub.has_child_rows
     		(p_project_id,
		 p_budget_version_id,
		 -1,
		 ra.task_id,
		 ra.resource_list_member_id,
		 null,
		 'A') as has_child_element
    from pa_resource_assignments ra,
         pa_proj_fp_options po
    where ra.budget_version_id = p_budget_version_id and
          ra.budget_version_id = po.fin_plan_version_id and
          po.fin_plan_option_level_code='PLAN_VERSION' and
	  ((ra.resource_assignment_type = 'USER_ENTERED' and
            exists (select 1 from pa_budget_lines bl
                    where bl.budget_version_id = ra.budget_version_id and
                          bl.resource_assignment_id = ra.resource_assignment_id)) or
           ra.resource_assignment_type = 'ROLLED_UP');

  /* PL/SQL tables */
    l_project_id                 pa_fp_view_plans_pub.av_tab_project_id;
    l_task_id                    pa_fp_view_plans_pub.av_tab_task_id;
    l_resource_list_member_id    pa_fp_view_plans_pub.av_tab_resource_list_member_id;
    l_budget_version_id          pa_fp_view_plans_pub.av_tab_cost_budget_version_id;
    l_res_assignment_id          pa_fp_view_plans_pub.av_tab_cost_res_assignment_id;
    l_element_name               pa_fp_view_plans_pub.av_tab_element_name;
    l_element_level              pa_fp_view_plans_pub.av_tab_element_level;
    l_labor_hours                pa_fp_view_plans_pub.av_tab_labor_hours;
    l_burdened_cost              pa_fp_view_plans_pub.av_tab_burdened_cost;
    l_raw_cost                   pa_fp_view_plans_pub.av_tab_raw_cost;
    l_revenue                    pa_fp_view_plans_pub.av_tab_revenue;
    l_margin                     pa_fp_view_plans_pub.av_tab_margin;
    l_margin_percent             pa_fp_view_plans_pub.av_tab_margin_percent;
    l_line_editable_flag         pa_fp_view_plans_pub.av_tab_line_editable;
    l_row_level			 pa_fp_view_plans_pub.av_tab_row_level;
    l_parent_element_name        pa_fp_view_plans_pub.av_tab_element_name;
    l_unit_of_measure		 pa_fp_view_plans_pub.av_tab_unit_of_measure;
    l_has_child_element		 pa_fp_view_plans_pub.av_tab_has_child_element;

        /* Added for bug 7514054 */
    t_project_id                      pa_fp_view_plans_pub.av_tab_project_id;
    t_task_id                         pa_fp_view_plans_pub.av_tab_task_id;
    t_resource_list_member_id         pa_fp_view_plans_pub.av_tab_resource_list_member_id;
    t_budget_version_id               pa_fp_view_plans_pub.av_tab_cost_budget_version_id;
    t_res_assignment_id               pa_fp_view_plans_pub.av_tab_cost_res_assignment_id;
    t_element_name                    pa_fp_view_plans_pub.av_tab_element_name;
    t_element_level                   pa_fp_view_plans_pub.av_tab_element_level;
    t_labor_hours                     pa_fp_view_plans_pub.av_tab_labor_hours;
    t_burdened_cost                   pa_fp_view_plans_pub.av_tab_burdened_cost;
    t_raw_cost                        pa_fp_view_plans_pub.av_tab_raw_cost;
    t_revenue                         pa_fp_view_plans_pub.av_tab_revenue;
    t_margin                          pa_fp_view_plans_pub.av_tab_margin;
    t_margin_percent                  pa_fp_view_plans_pub.av_tab_margin_percent;
    t_line_editable_flag              pa_fp_view_plans_pub.av_tab_line_editable;
    t_row_level			              pa_fp_view_plans_pub.av_tab_row_level;
    t_parent_element_name             pa_fp_view_plans_pub.av_tab_element_name;
    t_unit_of_measure		          pa_fp_view_plans_pub.av_tab_unit_of_measure;
    t_has_child_element		          pa_fp_view_plans_pub.av_tab_has_child_element;

    /* PL/SQL table for PERIODS VIEW */
    l_pd_project_id                     pa_fp_view_plans_pub.av_tab_project_id;
    l_pd_task_id                        pa_fp_view_plans_pub.av_tab_task_id;
    l_pd_resource_list_member_id        pa_fp_view_plans_pub.av_tab_resource_list_member_id;
    l_pd_unit_of_measure		pa_fp_view_plans_pub.av_tab_unit_of_measure;
    l_pd_budget_version_id              pa_fp_view_plans_pub.av_tab_cost_budget_version_id;
    l_pd_res_assignment_id              pa_fp_view_plans_pub.av_tab_cost_res_assignment_id;
    l_pd_element_name                   pa_fp_view_plans_pub.av_tab_element_name;
    l_pd_element_level                  pa_fp_view_plans_pub.av_tab_element_level;
    l_pd_line_editable_flag             pa_fp_view_plans_pub.av_tab_line_editable;
    l_pd_row_level                      pa_fp_view_plans_pub.av_tab_row_level;
    l_pd_parent_element_name            pa_fp_view_plans_pub.av_tab_element_name;
    l_pd_amount_type                    pa_fp_view_plans_pub.av_tab_amount_type;
    l_pd_amount_subtype                 pa_fp_view_plans_pub.av_tab_amount_subtype;
    l_pd_amount_type_id                 pa_fp_view_plans_pub.av_tab_amount_type_id;
    l_pd_amount_subtype_id              pa_fp_view_plans_pub.av_tab_amount_subtype_id;
    l_pd_period_1                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_2                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_3                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_4                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_5                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_6                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_7                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_8                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_9                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_10                      pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_11                      pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_12                      pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_13                      pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_preceding			pa_fp_view_plans_pub.av_tab_preceding_amts;
    l_pd_succeeding			pa_fp_view_plans_pub.av_tab_succeeding_amts;
    l_pd_has_child_element		pa_fp_view_plans_pub.av_tab_has_child_element;
    l_pd_project_total			pa_fp_view_plans_pub.av_tab_period_numbers; -- bug 2699651
-- local debugging variables
    l_err_stage		NUMBER(15);
    /* Added for 7514054 */
	l_loop_count    NUMBER(15);
	l_inc_count     NUMBER(15);
	l_check         NUMBER;
    inc number :=0;

	t_period_amount1  NUMBER;
	t_period_amount2  NUMBER;
	t_period_amount3   NUMBER;
	t_period_amount4   NUMBER;
	t_period_amount5   NUMBER;
	t_period_amount6   NUMBER;
	t_period_amount7   NUMBER;
	t_period_amount8   NUMBER;
	t_period_amount9   NUMBER;
	t_period_amount10  NUMBER;
	t_period_amount11  NUMBER;
	t_period_amount12  NUMBER;
	t_period_amount13  NUMBER;

begin
  --hr_utility.trace_on(null, 'dlai');
l_err_stage := 100;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_together', '100: entering pa_fp_vp_pop_tables_together', 2);
  --hr_utility.trace('entered pa_fp_vp_pop_tables_together: 100');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  SAVEPOINT VIEW_PLANS_POP_TABLES_SAME;

  -- used to query pa_proj_periods_denorm table
  select DECODE(pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE,
		'PROJFUNC', 'PROJ_FUNCTIONAL',
		'PROJ', 'PROJECT',
		'TRANSACTION')
    into l_currency_type
    from dual;

  -- this is for populating PERIODS PL/SQL table
  l_row_number := 0;
  select NVL(po.report_labor_hrs_from_code, 'COST'),
	 pa_fp_view_plans_pub.G_DEFAULT_AMOUNT_TYPE_CODE,
	 pa_fp_view_plans_pub.G_DEFAULT_AMT_SUBTYPE_CODE,
--         po.default_amount_type_code,
--         po.default_amount_subtype_code
	 bv.period_profile_id
    into l_report_labor_hrs_from_code,
         l_default_amount_type_code,
         l_default_amount_subtype_code,
	 l_period_profile_id
    from pa_proj_fp_options po,
	 pa_budget_versions bv
    where bv.budget_version_id = p_budget_version_id and
	  bv.fin_plan_type_id = po.fin_plan_type_id and
	  po.project_id = p_project_id and
	  po.fin_plan_option_level_code = 'PLAN_TYPE';
l_err_stage := 200;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_together', '200: retrieved periodprofileid= ' || l_period_profile_id, 1);
  --hr_utility.trace('retrieved period profile id: 200');
  -- populate the AMOUNTS PL/SQL table

  /* Modified below code for bug 7514054 */

  open av_csr;
  fetch av_csr bulk collect into
        t_project_id,
          t_task_id,
          t_resource_list_member_id,
          t_budget_version_id,
          t_res_assignment_id,
          t_element_name,
          t_element_level,
          t_labor_hours,
          t_burdened_cost,
          t_raw_cost,
          t_revenue,
          t_margin,
          t_margin_percent,
          t_line_editable_flag,
	      t_row_level,
          t_parent_element_name,
	      t_unit_of_measure,
	      t_has_child_element;
  close av_csr;

  /* Added for bug 7514054 */

     for i in nvl(t_project_id.first,0)..nvl(t_project_id.last,-1) loop
    l_project_id(i) :=                          t_project_id(i);
    l_task_id(i) :=                             t_task_id(i);
    l_resource_list_member_id(i) :=             t_resource_list_member_id(i);
    l_budget_version_id(i) :=                   t_budget_version_id(i);
    l_res_assignment_id(i) :=                   t_res_assignment_id(i);
    l_element_name(i) :=                        t_element_name(i);
    l_element_level(i) :=                       t_element_level(i);
    l_labor_hours(i) :=                    t_labor_hours(i);
    l_burdened_cost(i) :=                       t_burdened_cost(i);
    l_raw_cost(i) :=                            t_raw_cost(i);
    l_revenue(i) :=                             t_revenue(i);
    l_margin(i) :=                              t_margin(i);
    l_margin_percent(i) :=                      t_margin_percent(i);
    l_line_editable_flag(i) :=                  t_line_editable_flag(i);
    l_row_level(i) := 			       	      t_row_level(i);
    l_parent_element_name(i) :=                 t_parent_element_name(i);
    l_unit_of_measure(i) := 		   	      t_unit_of_measure(i);
    l_has_child_element(i) := 		   	      t_has_child_element(i);
     end loop;

 l_loop_count := nvl(l_project_id.last,-1);
if (l_loop_count > 0) then
 l_inc_count := l_loop_count+1;

  /* First Insert the project level record */
  select
	l_project_id(1),
	0,
	0,
	l_budget_version_id(1),
	-2,
	pa_fp_view_plans_util.assign_element_name
	(l_project_id(1),
	0,
	0) ,
	pa_fp_view_plans_util.assign_element_level
	(l_project_id(1),
	l_budget_version_id(1),
	0,
	0),
	0,
	0,-- as burdened_cost,
	0,-- as raw_cost,
	0,
	0, -- margin
	0, -- margin_percent
	'N', -- line_editable_flag
	pa_fp_view_plans_util.assign_row_level
	(l_project_id(1),
	0,
	0) ,
	pa_fp_view_plans_util.assign_parent_element
	(l_project_id(1),
	0,
	0) ,
	l_unit_of_measure(1),
	pa_fp_view_plans_pub.has_child_rows
	(l_project_id(1),
	l_budget_version_id(1),
	-1,
	0,
	0,
	null,
	'A')
	into
	l_project_id(l_inc_count),
	l_task_id(l_inc_count),
	l_resource_list_member_id(l_inc_count),
	l_budget_version_id(l_inc_count),
	l_res_assignment_id(l_inc_count),
	l_element_name(l_inc_count),
	l_element_level(l_inc_count),
	l_labor_hours(l_inc_count),
	l_burdened_cost(l_inc_count),
	l_raw_cost(l_inc_count),
	l_revenue(l_inc_count),
	l_margin(l_inc_count),
	l_margin_percent(l_inc_count),
	l_line_editable_flag(l_inc_count),
	l_row_level(l_inc_count),
	l_parent_element_name(l_inc_count),
	l_unit_of_measure(l_inc_count),
	l_has_child_element(l_inc_count)
	from dual;


 /* Now loop through all the resource assignments fetched and insert the parent record if its not found or rollup the amounts if its found */
 for i in 1..l_loop_count loop

   /* rolling up the project level amounts */
    if (l_task_id(l_loop_count+1) = 0 and l_resource_list_member_id(l_loop_count+1) = 0) then
          l_burdened_cost(l_loop_count+1) := l_burdened_cost(l_loop_count+1) + l_burdened_cost(i);
		  l_labor_hours(l_loop_count+1) := l_labor_hours(l_loop_count+1) + l_labor_hours(i);
		  l_raw_cost(l_loop_count+1) := l_raw_cost(l_loop_count+1) + l_raw_cost(i);
		  l_revenue(l_loop_count+1) := l_revenue(l_loop_count+1) + l_revenue(i);

    end if;

	 for task_rec in parent_tasks_csr(l_task_id(i))
	  loop
		 l_check := 0;
		for z in nvl(l_project_id.first,0)..nvl(l_project_id.last,-1)
		loop
		   if (l_project_id(z) = l_project_id(i) and l_task_id(z) = task_rec.task_id
		       and l_resource_list_member_id(z) = 0) then
		       l_burdened_cost(z) := l_burdened_cost(z) + l_burdened_cost(i);
		       l_labor_hours(z) := l_labor_hours(z) + l_labor_hours(i);
		       l_raw_cost(z) := l_raw_cost(z) + l_raw_cost(i);
			    l_revenue(z) := l_revenue(z) + l_revenue(i);
			   l_check := 1;
		   end if;
		end loop;
		if (l_check = 0) then
	  /* Parent task level record is not available, insert now */
	  l_inc_count := l_inc_count + 1;

	  select
		l_project_id(i),
		task_rec.task_id,
		0,
		l_budget_version_id(i),
		-2,
		pa_fp_view_plans_util.assign_element_name
		(l_project_id(i),
		task_rec.task_id,
		0) ,
		pa_fp_view_plans_util.assign_element_level
		(l_project_id(i),
		l_budget_version_id(i),
		task_rec.task_id,
		0),
		l_labor_hours(i),
		l_burdened_cost(i),-- as burdened_cost,
		l_raw_cost(i),-- as raw_cost,
		l_revenue(i),
		0, -- margin
		0, -- margin_percent
		'N', -- line_editable_flag
		pa_fp_view_plans_util.assign_row_level
		(l_project_id(i),
		task_rec.task_id,
		0) ,
		pa_fp_view_plans_util.assign_parent_element
		(l_project_id(i),
		task_rec.task_id,
		0) ,
		l_unit_of_measure(i),
		pa_fp_view_plans_pub.has_child_rows
		(l_project_id(i),
		l_budget_version_id(i),
		-1,
		task_rec.task_id,
		0,
		null,
		'A')
		into
		l_project_id(l_inc_count),
		l_task_id(l_inc_count),
		l_resource_list_member_id(l_inc_count),
		l_budget_version_id(l_inc_count),
		l_res_assignment_id(l_inc_count),
		l_element_name(l_inc_count),
		l_element_level(l_inc_count),
		l_labor_hours(l_inc_count),
		l_burdened_cost(l_inc_count),
		l_raw_cost(l_inc_count),
		l_revenue(l_inc_count),
		l_margin(l_inc_count),
		l_margin_percent(l_inc_count),
		l_line_editable_flag(l_inc_count),
		l_row_level(l_inc_count),
		l_parent_element_name(l_inc_count),
		l_unit_of_measure(l_inc_count),
		l_has_child_element(l_inc_count)
		from dual;
		end if;

    end loop;

 end loop;

end if;
/* Ends added for bug 7514054 */
l_err_stage := 300;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_together', '300: bulk collected into amts pl/sql table', 1);
  --hr_utility.trace('bulk collected into amts pl/sql table: 300');
  --hr_utility.trace('number of rows = ' || TO_CHAR(l_project_id.last));

  -- populate the PERIODS PL/SQL table
  -- ONLY if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'
  if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P' then
--hr_utility.trace('l_project_id.first= ' || to_char(l_project_id.first));
--hr_utility.trace('l_project_id.last= ' || to_char(l_project_id.last));
   for i in nvl(l_project_id.first,0)..nvl(l_project_id.last,-1) loop
--hr_utility.trace('i= ' || to_char(i));
  --hr_utility.trace('loop: ' || to_char(i));
    if pa_fp_view_plans_pub.G_DISPLAY_FLAG_QUANTITY = 'Y' then
    l_row_number := l_row_number + 1;
    -- process the QUANTITY numbers
    l_pd_project_id(l_row_number) := l_project_id(i);
    l_pd_task_id(l_row_number) := l_task_id(i);
    l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
    l_pd_unit_of_measure(l_row_number) := l_unit_of_measure(i);
    l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
    l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
    l_pd_element_name(l_row_number) := l_element_name(i);
    l_pd_element_level(l_row_number) := l_element_level(i);
    l_pd_row_level(l_row_number) := l_row_level(i);
    l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
    l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
    l_pd_amount_type(l_row_number) := 'QUANTITY';
    l_pd_amount_subtype(l_row_number) := 'QUANTITY';
    l_pd_amount_type_id(l_row_number) := 215; -- amount_type_id for QUANTITY
    l_pd_amount_subtype_id(l_row_number) := 215; -- amount_subtype_id for QUANTITY
    -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
    if not ((l_default_amount_type_code = 'QUANTITY') and
            (l_default_amount_subtype_code = 'QUANTITY')) then
      l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
      l_pd_element_name(l_row_number) := null;
      l_pd_has_child_element(l_row_number) := 'N';
    else
      l_pd_has_child_element(l_row_number) := 'Y';
    end if;
--hr_utility.trace('quantity: period1');
--hr_utility.trace('p_period_profile_id= ' || to_char(l_period_profile_id));
--hr_utility.trace('p_resource_assignment_id= ' || to_char(l_pd_res_assignment_id(l_row_number)));
--hr_utility.trace('p_project_currency_type= ' || l_currency_type);
    l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 215,
                p_period_number        => 1);
    l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 215,
                p_period_number        => 2);
    l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 215,
                p_period_number        => 3);
    l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 215,
                p_period_number        => 4);
    l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 215,
                p_period_number        => 5);
    l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 215,
                p_period_number        => 6);
    l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 215,
                p_period_number        => 7);
    l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 215,
                p_period_number        => 8);
    l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 215,
                p_period_number        => 9);
    l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 215,
                p_period_number        => 10);
    l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 215,
                p_period_number        => 11);
    l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 215,
                p_period_number        => 12);
    l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 215,
                p_period_number        => 13);
    l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 215,
                p_period_number        => 0);
    l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 215,
                p_period_number        => 14);
    l_pd_project_total(l_row_number) := l_labor_hours(i); -- bug 2699651
    end if; -- display_flag: QUANTITY

    if pa_fp_view_plans_pub.G_DISPLAY_FLAG_BURDCOST = 'Y' then
    -- process the BURDENED_COST numbers
    l_row_number := l_row_number + 1;
    l_pd_project_id(l_row_number) := l_project_id(i);
    l_pd_task_id(l_row_number) := l_task_id(i);
    l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
    l_pd_unit_of_measure(l_row_number) := null;
    l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
    l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
    l_pd_element_name(l_row_number) := l_element_name(i);
    l_pd_element_level(l_row_number) := l_element_level(i);
    l_pd_row_level(l_row_number) := l_row_level(i);
    l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
    l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
    l_pd_amount_type(l_row_number) := 'COST';
    l_pd_amount_subtype(l_row_number) := 'BURDENED_COST';
    l_pd_amount_type_id(l_row_number) := 150; -- amount_type_id for COST
    l_pd_amount_subtype_id(l_row_number) := 165; -- amount_subtype_id for BURDENED_COST
    -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
    if not ((l_default_amount_type_code = 'COST') and
            (l_default_amount_subtype_code = 'BURDENED_COST')) then
      l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
      l_pd_element_name(l_row_number) := null;
      l_pd_has_child_element(l_row_number) := 'N';
    else
      l_pd_has_child_element(l_row_number) := 'Y';
    end if;
    -- 02/14/03 dlai:  use appropriate cost row based on G_FP_CALC_MARGIN_FROM
    if pa_fp_view_plans_pub.G_FP_CALC_MARGIN_FROM = 'B' then
      l_cost_row_number := l_row_number;
    end if;
/*
    if l_burdened_cost(i) is not null then
      l_cost_row_number := l_row_number;
    end if;
*/
--hr_utility.trace('burdened cost: period1');
    l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 165,
                p_period_number        => 1);
    l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 165,
                p_period_number        => 2);
    l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 165,
                p_period_number        => 3);
    l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 165,
                p_period_number        => 4);
    l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 165,
                p_period_number        => 5);
    l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 165,
                p_period_number        => 6);
    l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 165,
                p_period_number        => 7);
    l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 165,
                p_period_number        => 8);
    l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 165,
                p_period_number        => 9);
    l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 165,
                p_period_number        => 10);
    l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 165,
                p_period_number        => 11);
    l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 165,
                p_period_number        => 12);
    l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 165,
                p_period_number        => 13);
    l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 165,
                p_period_number        => 0);
    l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 165,
                p_period_number        => 14);
    l_pd_project_total(l_row_number) := l_burdened_cost(i); -- bug 2699651
    end if; -- display_flag: BURDENED COST

    if pa_fp_view_plans_pub.G_DISPLAY_FLAG_RAWCOST = 'Y' then
    -- process the RAW_COST numbers
    l_row_number := l_row_number + 1;
    l_pd_project_id(l_row_number) := l_project_id(i);
    l_pd_task_id(l_row_number) := l_task_id(i);
    l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
    l_pd_unit_of_measure(l_row_number) := null;
    l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
    l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
    l_pd_element_name(l_row_number) := l_element_name(i);
    l_pd_element_level(l_row_number) := l_element_level(i);
    l_pd_row_level(l_row_number) := l_row_level(i);
    l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
    l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
    l_pd_amount_type(l_row_number) := 'COST';
    l_pd_amount_subtype(l_row_number) := 'RAW_COST';
    l_pd_amount_type_id(l_row_number) := 150; -- amount_type_id for COST
    l_pd_amount_subtype_id(l_row_number) := 160; -- amount_subtype_id for RAW_COST
    -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
    if not ((l_default_amount_type_code = 'COST') and
            (l_default_amount_subtype_code = 'RAW_COST')) then
      l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
      l_pd_element_name(l_row_number) := null;
      l_pd_has_child_element(l_row_number) := 'N';
    else
      l_pd_has_child_element(l_row_number) := 'Y';
    end if;
    -- 02/14/03 dlai:  use appropriate cost row based on G_FP_CALC_MARGIN_FROM
    if pa_fp_view_plans_pub.G_FP_CALC_MARGIN_FROM <> 'B' then
      l_cost_row_number := l_row_number;
    end if;
/*
    if l_burdened_cost(i) is null then
      l_cost_row_number := l_row_number;
    end if;
*/
--hr_utility.trace('raw cost: period1');
    l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 160,
                p_period_number        => 1);
    l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 160,
                p_period_number        => 2);
    l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 160,
                p_period_number        => 3);
    l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 160,
                p_period_number        => 4);
    l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 160,
                p_period_number        => 5);
    l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 160,
                p_period_number        => 6);
    l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 160,
                p_period_number        => 7);
    l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 160,
                p_period_number        => 8);
    l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 160,
                p_period_number        => 9);
    l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 160,
                p_period_number        => 10);
    l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 160,
                p_period_number        => 11);
    l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 160,
                p_period_number        => 12);
    l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 160,
                p_period_number        => 13);
    l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 160,
                p_period_number        => 0);
    l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                --p_amount_type_id       => 150,
                p_amount_type_id       => 160,
                p_period_number        => 14);
    l_pd_project_total(l_row_number) := l_raw_cost(i); -- bug 2699651
    end if; -- display_flag: RAW COST

    if pa_fp_view_plans_pub.G_DISPLAY_FLAG_REVENUE = 'Y' then
    -- process REVENUE information
    l_row_number := l_row_number + 1;
    l_pd_project_id(l_row_number) := l_project_id(i);
    l_pd_task_id(l_row_number) := l_task_id(i);
    l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
    l_pd_unit_of_measure(l_row_number) := null;
    l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
    l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
    l_pd_element_name(l_row_number) := l_element_name(i);
    l_pd_element_level(l_row_number) := l_element_level(i);
    l_pd_row_level(l_row_number) := l_row_level(i);
    l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
    l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
    l_pd_amount_type(l_row_number) := 'REVENUE';
    l_pd_amount_subtype(l_row_number) := 'REVENUE';
    l_pd_amount_type_id(l_row_number) := 100; -- amount_type_id for REVENUE
    l_pd_amount_subtype_id(l_row_number) := 100; -- amount_subtype_id for REVENUE
    -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
    if not ((l_default_amount_type_code = 'REVENUE') and
            (l_default_amount_subtype_code = 'REVENUE')) then
      l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
      l_pd_element_name(l_row_number) := null;
      l_pd_has_child_element(l_row_number) := 'N';
    else
      l_pd_has_child_element(l_row_number) := 'Y';
    end if;
    l_revenue_row_number := l_row_number;
--hr_utility.trace('revenue: period1');
    l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 100,
                p_period_number        => 1);
    l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 100,
                p_period_number        => 2);
    l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 100,
                p_period_number        => 3);
    l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 100,
                p_period_number        => 4);
    l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 100,
                p_period_number        => 5);
    l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 100,
                p_period_number        => 6);
    l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 100,
                p_period_number        => 7);
    l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 100,
                p_period_number        => 8);
    l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 100,
                p_period_number        => 9);
    l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 100,
                p_period_number        => 10);
    l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 100,
                p_period_number        => 11);
    l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 100,
                p_period_number        => 12);
    l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 100,
                p_period_number        => 13);
    l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 100,
                p_period_number        => 0);
    l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
               (p_period_profile_id    => l_period_profile_id,
		p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
	        p_project_currency_type => l_currency_type,
                p_amount_type_id       => 100,
                p_period_number        => 14);
    l_pd_project_total(l_row_number) := l_revenue(i); -- bug 2699651
    end if; -- display_flag: REVENUE

    if pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGIN = 'Y' then
    -- calculate and insert the MARGIN row
    l_row_number := l_row_number + 1;
    l_pd_project_id(l_row_number) := l_project_id(i);
    l_pd_task_id(l_row_number) := l_task_id(i);
    l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
    l_pd_unit_of_measure(l_row_number) := null;
    l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
    l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
    l_pd_element_name(l_row_number) := l_element_name(i);
    l_pd_element_level(l_row_number) := l_element_level(i);
    l_pd_row_level(l_row_number) := l_row_level(i);
    l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
    l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
    l_pd_amount_type(l_row_number) := 'MARGIN';
    l_pd_amount_subtype(l_row_number) := 'MARGIN';
    l_pd_amount_type_id(l_row_number) := 230; -- amount_type_id for MARGIN
    l_pd_amount_subtype_id(l_row_number) := 230; -- amount_subtype_id for MARGIN
    -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
    if not ((l_default_amount_type_code = 'MARGIN') and
            (l_default_amount_subtype_code = 'MARGIN')) then
      l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
      l_pd_element_name(l_row_number) := null;
      l_pd_has_child_element(l_row_number) := 'N';
    else
      l_pd_has_child_element(l_row_number) := 'Y';
    end if;
    l_pd_period_1(l_row_number) := l_pd_period_1(l_revenue_row_number)-l_pd_period_1(l_cost_row_number);
    l_pd_period_2(l_row_number) := l_pd_period_2(l_revenue_row_number)-l_pd_period_2(l_cost_row_number);
    l_pd_period_3(l_row_number) := l_pd_period_3(l_revenue_row_number)-l_pd_period_3(l_cost_row_number);
    l_pd_period_4(l_row_number) := l_pd_period_4(l_revenue_row_number)-l_pd_period_4(l_cost_row_number);
    l_pd_period_5(l_row_number) := l_pd_period_5(l_revenue_row_number)-l_pd_period_5(l_cost_row_number);
    l_pd_period_6(l_row_number) := l_pd_period_6(l_revenue_row_number)-l_pd_period_6(l_cost_row_number);
    l_pd_period_7(l_row_number) := l_pd_period_7(l_revenue_row_number)-l_pd_period_7(l_cost_row_number);
    l_pd_period_8(l_row_number) := l_pd_period_8(l_revenue_row_number)-l_pd_period_8(l_cost_row_number);
    l_pd_period_9(l_row_number) := l_pd_period_9(l_revenue_row_number)-l_pd_period_9(l_cost_row_number);
    l_pd_period_10(l_row_number) := l_pd_period_10(l_revenue_row_number)-l_pd_period_10(l_cost_row_number);
    l_pd_period_11(l_row_number) := l_pd_period_11(l_revenue_row_number)-l_pd_period_11(l_cost_row_number);
    l_pd_period_12(l_row_number) := l_pd_period_12(l_revenue_row_number)-l_pd_period_12(l_cost_row_number);
    l_pd_period_13(l_row_number) := l_pd_period_13(l_revenue_row_number)-l_pd_period_13(l_cost_row_number);
    l_pd_preceding(l_row_number) := l_pd_preceding(l_revenue_row_number)-l_pd_preceding(l_cost_row_number);
    l_pd_succeeding(l_row_number) := l_pd_succeeding(l_revenue_row_number)-l_pd_succeeding(l_cost_row_number);
    l_pd_project_total(l_row_number) := l_pd_project_total(l_revenue_row_number)-l_pd_project_total(l_cost_row_number); -- bug 2699651
    end if; -- display_flag: MARGIN

    if pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGINPCT = 'Y' then
    -- calculate and insert the MARGIN_PERCENT row
    l_row_number := l_row_number + 1;
    l_pd_project_id(l_row_number) := l_project_id(i);
    l_pd_task_id(l_row_number) := l_task_id(i);
    l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
    l_pd_unit_of_measure(l_row_number) := null;
    l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
    l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
    l_pd_element_name(l_row_number) := l_element_name(i);
    l_pd_element_level(l_row_number) := l_element_level(i);
    l_pd_row_level(l_row_number) := l_row_level(i);
    l_pd_parent_element_name(l_row_number) := l_row_level(i);
    l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
    l_pd_amount_type(l_row_number) := 'MARGIN_PERCENT';
    l_pd_amount_subtype(l_row_number) := 'MARGIN_PERCENT';
    l_pd_amount_type_id(l_row_number) := 231; -- amount_type_id of MARGIN_PERCENT
    l_pd_amount_subtype_id(l_row_number) := 231; -- amount_subtype_id of MARGIN_PERCENT
    -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
    if not ((l_default_amount_type_code = 'MARGIN_PERCENT') and
            (l_default_amount_subtype_code = 'MARGIN_PERCENT')) then
      l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
      l_pd_element_name(l_row_number) := null;
      l_pd_has_child_element(l_row_number) := 'N';
    else
      l_pd_has_child_element(l_row_number) := 'Y';
    end if;
    l_pd_period_1(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_1(l_cost_row_number),l_pd_period_1(l_revenue_row_number));
    l_pd_period_2(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_2(l_cost_row_number),l_pd_period_2(l_revenue_row_number));
    l_pd_period_3(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_3(l_cost_row_number),l_pd_period_3(l_revenue_row_number));
    l_pd_period_4(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_4(l_cost_row_number),l_pd_period_4(l_revenue_row_number));
    l_pd_period_5(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_5(l_cost_row_number),l_pd_period_5(l_revenue_row_number));
    l_pd_period_6(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_6(l_cost_row_number),l_pd_period_6(l_revenue_row_number));
    l_pd_period_7(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_7(l_cost_row_number),l_pd_period_7(l_revenue_row_number));
    l_pd_period_8(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_8(l_cost_row_number),l_pd_period_8(l_revenue_row_number));
    l_pd_period_9(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_9(l_cost_row_number),l_pd_period_9(l_revenue_row_number));
    l_pd_period_10(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_10(l_cost_row_number),l_pd_period_10(l_revenue_row_number));
    l_pd_period_11(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_11(l_cost_row_number),l_pd_period_11(l_revenue_row_number));
    l_pd_period_12(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_12(l_cost_row_number),l_pd_period_12(l_revenue_row_number));
    l_pd_period_13(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_period_13(l_cost_row_number),l_pd_period_13(l_revenue_row_number));
    l_pd_preceding(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_preceding(l_cost_row_number),l_pd_preceding(l_revenue_row_number));
    l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_succeeding(l_cost_row_number),l_pd_succeeding(l_revenue_row_number));
    end if; -- display_from: MARGIN PERCENT
    l_pd_project_total(l_row_number) := pa_fp_view_plans_util.calc_margin_percent(l_pd_project_total(l_cost_row_number),l_pd_project_total(l_revenue_row_number)); -- bug 2699651
   end loop;
  end if; -- pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'
l_err_stage := 400;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_together', '400: populated the pds pl/sql tables', 1);
  --hr_utility.trace('populated the pds pl/sql tables: 400');

  /* TRANSFER DATA FROM PL/SQL TABLES TO GLOBAL TEMPORARY TABLES */
  -- POPULATE global temporary table PA_FIN_VP_AMTS_VIEW_TMP
  -- ONLY if pa_fp_view_plans_pub.G_AMT_OR_PD = 'A'
  if pa_fp_view_plans_pub.G_AMT_OR_PD = 'A' then
   forall i in nvl(l_project_id.first,0)..nvl(l_project_id.last,-1)
    insert into pa_fin_vp_amts_view_tmp
        (project_id,
         task_id,
         resource_list_member_id,
         element_name,
         element_level,
         labor_hours,
         burdened_cost,
         raw_cost,
         revenue,
         margin,
         margin_percent,
         editable_flag,
	 row_level,
         parent_element_name,
	 cost_resource_assignment_id,
	 rev_resource_assignment_id,
	 all_resource_assignment_id,
	 unit_of_measure,
	 has_child_element) values
        (l_project_id(i),
         l_task_id(i),
         l_resource_list_member_id(i),
         l_element_name(i),
         l_element_level(i),
         l_labor_hours(i),
         l_burdened_cost(i),
         l_raw_cost(i),
         l_revenue(i),
         l_margin(i),
         l_margin_percent(i),
         l_line_editable_flag(i),
	 l_row_level(i),
         l_parent_element_name(i),
	 -1,
	 -1,
	 l_res_assignment_id(i),
 	 l_unit_of_measure(i),
	 l_has_child_element(i));
l_err_stage := 500;
   pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_together', '500: populated the amts_tmp tables', 1);
   --hr_utility.trace('populated the amts_tmp table: 500');
   commit;
  end if; -- pa_fp_view_plans_pub.G_AMT_OR_PD = 'A'

  -- POPULATE global temporary table PA_FIN_VP_PDS_VIEW_TMP from the
  -- PERIODS PL/SQL table
  -- ONLY if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'
  if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P' then
--hr_utility.trace('l_pd_project_id.first= ' || TO_CHAR(l_pd_project_id.first));
--hr_utility.trace('l_pd_project_id.last= ' || TO_CHAR(l_pd_project_id.last));
   forall z in nvl(l_pd_project_id.first,0)..nvl(l_pd_project_id.last,-1)
      insert into pa_fin_vp_pds_view_tmp
        (project_id,
         task_id,
         resource_list_member_id,
	 uom,
         element_name,
         element_level,
         editable_flag,
         row_level,
         parent_element_name,
         amount_type,
         amount_subtype,
         amount_type_id,
         amount_subtype_id,
         period_amount1,
         period_amount2,
         period_amount3,
         period_amount4,
         period_amount5,
         period_amount6,
         period_amount7,
         period_amount8,
         period_amount9,
         period_amount10,
         period_amount11,
         period_amount12,
         period_amount13,
	 cost_resource_assignment_id,
	 rev_resource_assignment_id,
	 all_resource_assignment_id,
	 preceding_periods_amount,
	 succeeding_periods_amount,
	 has_child_element,
	 project_total) values
        (l_pd_project_id(z),
         l_pd_task_id(z),
         l_pd_resource_list_member_id(z),
	 l_pd_unit_of_measure(z),
         l_pd_element_name(z),
         l_pd_element_level(z),
         l_pd_line_editable_flag(z),
         l_pd_row_level(z),
         l_pd_parent_element_name(z),
         l_pd_amount_type(z),
         l_pd_amount_subtype(z),
         l_pd_amount_type_id(z),
         l_pd_amount_subtype_id(z),
         l_pd_period_1(z),
         l_pd_period_2(z),
         l_pd_period_3(z),
         l_pd_period_4(z),
         l_pd_period_5(z),
         l_pd_period_6(z),
         l_pd_period_7(z),
         l_pd_period_8(z),
         l_pd_period_9(z),
         l_pd_period_10(z),
         l_pd_period_11(z),
         l_pd_period_12(z),
         l_pd_period_13(z),
	 -1,
	 -1,
	 l_pd_res_assignment_id(z),
	 l_pd_preceding(z),
	 l_pd_succeeding(z),
	 l_pd_has_child_element(z),
	 l_pd_project_total(z));

	 /* Logic to rollp the Period amounts to the parent levels */

   for rollup_rec in rollup_period_amt_csr
   loop
		t_period_amount1 := null;
		t_period_amount2 := null;
		t_period_amount3 := null;
		t_period_amount4 := null;
		t_period_amount5 := null;
		t_period_amount6 := null;
		t_period_amount7 := null;
		t_period_amount8 := null;
		t_period_amount9 := null;
		t_period_amount10 := null;
		t_period_amount11 := null;
		t_period_amount12 := null;
		t_period_amount13 := null;

    select  period_amount1,
			period_amount2,
			period_amount3,
			period_amount4,
			period_amount5,
			period_amount6,
			period_amount7,
			period_amount8,
			period_amount9,
			period_amount10,
			period_amount11,
			period_amount12,
			period_amount13
		into
		    t_period_amount1,
			t_period_amount2,
			t_period_amount3,
			t_period_amount4,
			t_period_amount5,
			t_period_amount6,
			t_period_amount7,
			t_period_amount8,
			t_period_amount9,
			t_period_amount10,
			t_period_amount11,
			t_period_amount12,
			t_period_amount13
	from pa_fin_vp_pds_view_tmp
    where rowid = rollup_rec.rowid;

  if (rollup_rec.element_name is not null) then
    update pa_fin_vp_pds_view_tmp p
	set  p.period_amount1 = nvl(p.period_amount1, 0)+nvl(t_period_amount1,0),
         p.period_amount2 = nvl(p.period_amount2, 0)+nvl(t_period_amount2, 0),
         p.period_amount3 = nvl(p.period_amount3, 0)+nvl(t_period_amount3, 0),
         p.period_amount4 = nvl(p.period_amount4, 0)+nvl(t_period_amount4, 0),
         p.period_amount5 = nvl(p.period_amount5, 0)+nvl(t_period_amount5, 0),
         p.period_amount6 = nvl(p.period_amount6, 0)+nvl(t_period_amount6, 0),
         p.period_amount7 = nvl(p.period_amount7, 0)+nvl(t_period_amount7, 0),
         p.period_amount8 = nvl(p.period_amount8, 0)+nvl(t_period_amount8, 0),
         p.period_amount9 = nvl(p.period_amount9, 0)+nvl(t_period_amount9, 0),
         p.period_amount10 = nvl(p.period_amount10, 0)+nvl(t_period_amount10, 0),
         p.period_amount11 = nvl(p.period_amount11, 0)+nvl(t_period_amount11, 0),
         p.period_amount12 = nvl(p.period_amount12, 0)+nvl(t_period_amount12, 0),
         p.period_amount13 = nvl(p.period_amount13, 0)+nvl(t_period_amount13, 0)
	where p.row_level < rollup_rec.row_level
	  and p.amount_type = rollup_rec.amount_type
      and rollup_rec.element_name is not null
	    and p.element_name = rollup_rec.parent_element_name
		and p.element_name is not null;
   else
    update pa_fin_vp_pds_view_tmp p
	set  p.period_amount1 = nvl(p.period_amount1, 0)+nvl(t_period_amount1,0),
         p.period_amount2 = nvl(p.period_amount2, 0)+nvl(t_period_amount2, 0),
         p.period_amount3 = nvl(p.period_amount3, 0)+nvl(t_period_amount3, 0),
         p.period_amount4 = nvl(p.period_amount4, 0)+nvl(t_period_amount4, 0),
         p.period_amount5 = nvl(p.period_amount5, 0)+nvl(t_period_amount5, 0),
         p.period_amount6 = nvl(p.period_amount6, 0)+nvl(t_period_amount6, 0),
         p.period_amount7 = nvl(p.period_amount7, 0)+nvl(t_period_amount7, 0),
         p.period_amount8 = nvl(p.period_amount8, 0)+nvl(t_period_amount8, 0),
         p.period_amount9 = nvl(p.period_amount9, 0)+nvl(t_period_amount9, 0),
         p.period_amount10 = nvl(p.period_amount10, 0)+nvl(t_period_amount10, 0),
         p.period_amount11 = nvl(p.period_amount11, 0)+nvl(t_period_amount11, 0),
         p.period_amount12 = nvl(p.period_amount12, 0)+nvl(t_period_amount12, 0),
         p.period_amount13 = nvl(p.period_amount13, 0)+nvl(t_period_amount13, 0)
	where p.row_level < rollup_rec.row_level
	  and p.amount_subtype = rollup_rec.amount_subtype
      and rollup_rec.element_name is null
	    and p.element_name is null
		and (p.project_id,p.task_id, p.resource_list_member_id,row_level)
		in (select p1.project_id, p1.task_id, p1.resource_list_member_id, p1.row_level
		from pa_fin_vp_pds_view_tmp p1
		where p1.element_name = (select p2.parent_element_name from
               pa_fin_vp_pds_view_tmp p2
               where p2.row_level = rollup_rec.row_level
                 and p2.element_name is not null
                 and p2.project_id = rollup_rec.project_id
                 and p2.task_id = rollup_rec.task_id
                 and p2.resource_list_member_id = rollup_rec.resource_list_member_id
				 and rownum<2
               )
          );
	end if;
   end loop;

   /* Ends logic to rollup the period aounts to the parent levels */

l_err_stage := 600;
   pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_together', '600: populated the pds_tmp tables', 1);
   --hr_utility.trace('populated the pds_temp table: 600');
   commit;
  end if; -- pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_together', '700: leaving procedure', 2);

EXCEPTION
when others then
      rollback to VIEW_PLANS_POP_TABLES_SAME;
--hr_utility.trace('l_err_stage= ' || to_char(l_err_stage));
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FP_VIEW_PLANS_PUB',
                               p_procedure_name   => 'View_Plans_Pop_Tables_Tog');
      pa_debug.reset_err_stack;
      return;
end pa_fp_vp_pop_tables_together;
/* ------------------------------------------------------------- */

/* PROCEDURE: pa_fp_vp_pop_tables_single
 * Populates pa_fin_vp_amts_view_tmp assuming that only one budget version
 * (either COST_ONLY or REVENUE_ONLY) is supplied
 */
-- modified for new AMOUNT_TYPE_CODE and AMOUNT_SUBTYPE_CODE
-- modified for logic for RAW_COST and MARGIN 06/20/02
-- 11/12/2002 Dlai: updated cursors to select project OR projfunc amounts
--		     added logic for inserting rows for periodic view only if
--		     flag='Y' for that amount type
-- 11/25/2002 Dlai: for labor_hrs column, query ra.total_plan_quantity
-- 02/17/2003 Dlai: added l_pd_unit_of_measure (bug 2807032)
-- 02/20/2003 Dlai: added l_has_child_element/l_pd_has_child_element
-- 07/25/2003 Dlai: for PA_FIN_VP_PDS_VIEW_TMP, populate project_total
-- 10/07/2003 Dlai: added l_pd_project_total(l_row_number) := null for Margin row
procedure pa_fp_vp_pop_tables_single
    (p_project_id           IN	pa_budget_versions.project_id%TYPE,
     p_budget_version_id    IN	pa_budget_versions.budget_version_id%TYPE,
     p_cost_or_rev          IN	VARCHAR2,
     x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data             OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
as

    /* local variables */
    l_report_labor_hrs_from_code        pa_proj_fp_options.report_labor_hrs_from_code%TYPE;
    l_cur_resource_assignment_id        pa_resource_assignments.resource_assignment_id%TYPE;
    l_row_number                        NUMBER; -- keep track of number of rows in PERIODS PL/SQL table
    l_period_profile_id                 pa_proj_period_profiles.period_profile_id%TYPE; -- used to retrieve values for period numbers
    l_default_amount_type_code          VARCHAR2(30);
    l_default_amount_subtype_code       VARCHAR2(30);
    l_currency_type			VARCHAR2(30);

    /* Added for bug 7514054 */
	l_cnt number;

  cursor parent_tasks_csr(p_task_id in NUMBER) is
	select t.task_id from pa_tasks t
	START WITH t.task_id = p_task_id
	CONNECT BY prior t.parent_task_id = t.task_id;


   cursor rollup_period_amt_csr is
   select rowid, p.* from pa_fin_vp_pds_view_tmp p
   order by row_level desc;

/* Ends added for bug 7514054 */

  cursor av_cost_csr is
    select ra.project_id,
           ra.task_id,
           ra.resource_list_member_id,
           ra.budget_version_id,
           ra.resource_assignment_id,
           pa_fp_view_plans_util.assign_element_name
                (ra.project_id,
                 ra.task_id,
                 ra.resource_list_member_id) as element_name,  -- element_name
           pa_fp_view_plans_util.assign_element_level
                (ra.project_id,
		 ra.budget_version_id,
                 ra.task_id,
                 ra.resource_list_member_id) as element_level, -- element_level
           DECODE(po.report_labor_hrs_from_code,
                  'REVENUE', 0,
--                  ra.total_utilization_hours) as labor_hours,
                  ra.total_plan_quantity) as labor_hours,
           DECODE(pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE,
		  'PROJ', ra.total_project_burdened_cost,
		  ra.total_plan_burdened_cost) as burdened_cost,  -- burdened_cost
           DECODE(pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE,
		  'PROJ', ra.total_project_raw_cost,
		  ra.total_plan_raw_cost) as raw_cost,  -- raw_cost
           0 as revenue,  -- revenue
           0 as margin,  -- margin
           0 as margin_percent,  -- margin_percent
           DECODE(ra.resource_assignment_type,
                 'ROLLED_UP', 'N',
                 'USER_ENTERED', 'Y',
                 'Y') as line_editable_flag, -- line_editable_flag
           pa_fp_view_plans_util.assign_row_level
                (ra.project_id,
                 ra.task_id,
                 ra.resource_list_member_id) as row_level,
           pa_fp_view_plans_util.assign_parent_element
                (ra.project_id,
                 ra.task_id,
                 ra.resource_list_member_id) as parent_element_name,
	   ra.unit_of_measure,
	   pa_fp_view_plans_pub.has_child_rows
     		(p_project_id,
		 p_budget_version_id,
		 -1,
		 ra.task_id,
		 ra.resource_list_member_id,
		 null,
		 'A') as has_child_element
    from pa_resource_assignments ra,
         pa_proj_fp_options po
    where ra.budget_version_id = p_budget_version_id and
          ra.budget_version_id = po.fin_plan_version_id and
          po.fin_plan_option_level_code='PLAN_VERSION' and
	  ((ra.resource_assignment_type = 'USER_ENTERED' and
            exists (select 1 from pa_budget_lines bl
                    where bl.budget_version_id = ra.budget_version_id and
                          bl.resource_assignment_id = ra.resource_assignment_id)) or
           ra.resource_assignment_type = 'ROLLED_UP');

  cursor av_rev_csr is
    select ra.project_id,
           ra.task_id,
           ra.resource_list_member_id,
           ra.budget_version_id,
           ra.resource_assignment_id,
           pa_fp_view_plans_util.assign_element_name
                (ra.project_id,
                 ra.task_id,
                 ra.resource_list_member_id) as element_name,  -- element_name
           pa_fp_view_plans_util.assign_element_level
                (ra.project_id,
		 ra.budget_version_id,
                 ra.task_id,
                 ra.resource_list_member_id) as element_level, -- element_level
           DECODE(po.report_labor_hrs_from_code,
                  'COST', 0,
--                  ra.total_utilization_hours) as labor_hours,
                  ra.total_plan_quantity) as labor_hours,
           0 as burdened_cost,  -- burdened_cost
           0 as raw_cost,  -- raw_cost
           DECODE(pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE,
		  'PROJ', ra.total_project_revenue,
		  ra.total_plan_revenue) as revenue,  -- revenue
           0 as margin,  -- margin
           0 as margin_percent,  -- margin_percent
           DECODE(ra.resource_assignment_type,
                 'ROLLED_UP', 'N',
                 'USER_ENTERED', 'Y',
                 'Y') as line_editable_flag, -- line_editable_flag
           pa_fp_view_plans_util.assign_row_level
                (ra.project_id,
                 ra.task_id,
                 ra.resource_list_member_id) as row_level,
           pa_fp_view_plans_util.assign_parent_element
                (ra.project_id,
                 ra.task_id,
                 ra.resource_list_member_id) as parent_element_name,
	   ra.unit_of_measure,
	   pa_fp_view_plans_pub.has_child_rows
     		(p_project_id,
		 p_budget_version_id,
		 -1,
		 ra.task_id,
		 ra.resource_list_member_id,
		 null,
		 'A') as has_child_element
    from pa_resource_assignments ra,
         pa_proj_fp_options po
    where ra.budget_version_id = p_budget_version_id and
          ra.budget_version_id = po.fin_plan_version_id and
          po.fin_plan_option_level_code='PLAN_VERSION' and
	  ((ra.resource_assignment_type = 'USER_ENTERED' and
            exists (select 1 from pa_budget_lines bl
                    where bl.budget_version_id = ra.budget_version_id and
                          bl.resource_assignment_id = ra.resource_assignment_id)) or
           ra.resource_assignment_type = 'ROLLED_UP');

    /* AMOUNTS VIEW PL/SQL tables */
    l_project_id                      pa_fp_view_plans_pub.av_tab_project_id;
    l_task_id                         pa_fp_view_plans_pub.av_tab_task_id;
    l_resource_list_member_id         pa_fp_view_plans_pub.av_tab_resource_list_member_id;
    l_budget_version_id               pa_fp_view_plans_pub.av_tab_cost_budget_version_id;
    l_res_assignment_id               pa_fp_view_plans_pub.av_tab_cost_res_assignment_id;
    l_element_name                    pa_fp_view_plans_pub.av_tab_element_name;
    l_element_level                   pa_fp_view_plans_pub.av_tab_element_level;
    l_labor_hours                     pa_fp_view_plans_pub.av_tab_labor_hours;
    l_burdened_cost                   pa_fp_view_plans_pub.av_tab_burdened_cost;
    l_raw_cost                        pa_fp_view_plans_pub.av_tab_raw_cost;
    l_revenue                         pa_fp_view_plans_pub.av_tab_revenue;
    l_margin                          pa_fp_view_plans_pub.av_tab_margin;
    l_margin_percent                  pa_fp_view_plans_pub.av_tab_margin_percent;
    l_line_editable_flag              pa_fp_view_plans_pub.av_tab_line_editable;
    l_row_level			      pa_fp_view_plans_pub.av_tab_row_level;
    l_parent_element_name             pa_fp_view_plans_pub.av_tab_element_name;
    l_unit_of_measure		      pa_fp_view_plans_pub.av_tab_unit_of_measure;
    l_has_child_element		      pa_fp_view_plans_pub.av_tab_has_child_element;

    /* Added for bug 7514054 */
    t_project_id                      pa_fp_view_plans_pub.av_tab_project_id;
    t_task_id                         pa_fp_view_plans_pub.av_tab_task_id;
    t_resource_list_member_id         pa_fp_view_plans_pub.av_tab_resource_list_member_id;
    t_budget_version_id               pa_fp_view_plans_pub.av_tab_cost_budget_version_id;
    t_res_assignment_id               pa_fp_view_plans_pub.av_tab_cost_res_assignment_id;
    t_element_name                    pa_fp_view_plans_pub.av_tab_element_name;
    t_element_level                   pa_fp_view_plans_pub.av_tab_element_level;
    t_labor_hours                     pa_fp_view_plans_pub.av_tab_labor_hours;
    t_burdened_cost                   pa_fp_view_plans_pub.av_tab_burdened_cost;
    t_raw_cost                        pa_fp_view_plans_pub.av_tab_raw_cost;
    t_revenue                         pa_fp_view_plans_pub.av_tab_revenue;
    t_margin                          pa_fp_view_plans_pub.av_tab_margin;
    t_margin_percent                  pa_fp_view_plans_pub.av_tab_margin_percent;
    t_line_editable_flag              pa_fp_view_plans_pub.av_tab_line_editable;
    t_row_level			              pa_fp_view_plans_pub.av_tab_row_level;
    t_parent_element_name             pa_fp_view_plans_pub.av_tab_element_name;
    t_unit_of_measure		          pa_fp_view_plans_pub.av_tab_unit_of_measure;
    t_has_child_element		          pa_fp_view_plans_pub.av_tab_has_child_element;

    /* PL/SQL table for PERIODS VIEW */
    l_pd_project_id                     pa_fp_view_plans_pub.av_tab_project_id;
    l_pd_task_id                        pa_fp_view_plans_pub.av_tab_task_id;
    l_pd_resource_list_member_id        pa_fp_view_plans_pub.av_tab_resource_list_member_id;
    l_pd_unit_of_measure		pa_fp_view_plans_pub.av_tab_unit_of_measure;
    l_pd_budget_version_id              pa_fp_view_plans_pub.av_tab_cost_budget_version_id;
    l_pd_res_assignment_id              pa_fp_view_plans_pub.av_tab_cost_res_assignment_id;
    l_pd_element_name                   pa_fp_view_plans_pub.av_tab_element_name;
    l_pd_element_level                  pa_fp_view_plans_pub.av_tab_element_level;
    l_pd_line_editable_flag             pa_fp_view_plans_pub.av_tab_line_editable;
    l_pd_row_level                      pa_fp_view_plans_pub.av_tab_row_level;
    l_pd_parent_element_name            pa_fp_view_plans_pub.av_tab_element_name;
    l_pd_amount_type                    pa_fp_view_plans_pub.av_tab_amount_type;
    l_pd_amount_subtype                 pa_fp_view_plans_pub.av_tab_amount_subtype;
    l_pd_amount_type_id                 pa_fp_view_plans_pub.av_tab_amount_type_id;
    l_pd_amount_subtype_id              pa_fp_view_plans_pub.av_tab_amount_subtype_id;
    l_pd_period_1                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_2                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_3                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_4                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_5                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_6                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_7                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_8                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_9                       pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_10                      pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_11                      pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_12                      pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_period_13                      pa_fp_view_plans_pub.av_tab_period_numbers;
    l_pd_preceding			pa_fp_view_plans_pub.av_tab_preceding_amts;
    l_pd_succeeding			pa_fp_view_plans_pub.av_tab_succeeding_amts;
    l_pd_has_child_element	        pa_fp_view_plans_pub.av_tab_has_child_element;
    l_pd_project_total			pa_fp_view_plans_pub.av_tab_period_numbers; --bug 2699651
-- local debugging variables
    l_err_stage		NUMBER(15);
    /* Added for bug 7514054 */
	l_loop_count    NUMBER(15);
	l_inc_count     NUMBER(15);
	l_check         NUMBER;
   inc number :=0;

	t_period_amount1  NUMBER;
	t_period_amount2  NUMBER;
	t_period_amount3   NUMBER;
	t_period_amount4   NUMBER;
	t_period_amount5   NUMBER;
	t_period_amount6   NUMBER;
	t_period_amount7   NUMBER;
	t_period_amount8   NUMBER;
	t_period_amount9   NUMBER;
	t_period_amount10  NUMBER;
	t_period_amount11  NUMBER;
	t_period_amount12  NUMBER;
	t_period_amount13     NUMBER;

begin
  --hr_utility.trace_on(null, 'dlai');
l_err_stage := 100;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single', '100: entering procedure', 2);
  --hr_utility.trace('entered pa_fp_vp_pop_tables_single:100');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  SAVEPOINT VIEW_PLANS_POP_TABLES_SINGLE;
  -- used to query pa_proj_periods_denorm table
  select DECODE(pa_fp_view_plans_pub.G_FP_CURRENCY_TYPE,
		'PROJFUNC', 'PROJ_FUNCTIONAL',
		'PROJ', 'PROJECT',
		'TRANSACTION')
    into l_currency_type
    from dual;

  -- this is for populating PERIODS PL/SQL table
  l_row_number := 0;
  select NVL(po.report_labor_hrs_from_code, 'COST'),
--         po.default_amount_type_code,
--         po.default_amount_subtype_code
	 pa_fp_view_plans_pub.G_DEFAULT_AMOUNT_TYPE_CODE,
	 pa_fp_view_plans_pub.G_DEFAULT_AMT_SUBTYPE_CODE,
	 bv.period_profile_id
    into l_report_labor_hrs_from_code,
         l_default_amount_type_code,
         l_default_amount_subtype_code,
	 l_period_profile_id
    from pa_proj_fp_options po,
	 pa_budget_versions bv
    where bv.budget_version_id = p_budget_version_id and
	  bv.fin_plan_type_id = po.fin_plan_type_id and
	  po.project_id = p_project_id and
          po.fin_plan_option_level_code = 'PLAN_TYPE';
l_err_stage := 200;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single', '200: retrieved periodprofileid= ' || l_period_profile_id, 1);
  --hr_utility.trace('retrieved periodprofileid: 200');
  -- populate AMOUNTS PL/SQL TABLES
  if p_cost_or_rev = 'C' then
    pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single', '300: this is a COST version - populating amts pl/sql tables', 1);
    /* Modified below code for bug 7514054 */

    open av_cost_csr;
    fetch av_cost_csr bulk collect into
          t_project_id,
          t_task_id,
          t_resource_list_member_id,
          t_budget_version_id,
          t_res_assignment_id,
          t_element_name,
          t_element_level,
          t_labor_hours,
          t_burdened_cost,
          t_raw_cost,
          t_revenue,
          t_margin,
          t_margin_percent,
          t_line_editable_flag,
	      t_row_level,
          t_parent_element_name,
	      t_unit_of_measure,
	      t_has_child_element;
    close av_cost_csr;

    /* Added below code for 7514054 */

	     for i in nvl(t_project_id.first,0)..nvl(t_project_id.last,-1) loop
		    l_project_id(i) :=                          t_project_id(i);
		    l_task_id(i) :=                             t_task_id(i);
		    l_resource_list_member_id(i) :=             t_resource_list_member_id(i);
		    l_budget_version_id(i) :=                   t_budget_version_id(i);
		    l_res_assignment_id(i) :=                   t_res_assignment_id(i);
		    l_element_name(i) :=                        t_element_name(i);
		    l_element_level(i) :=                       t_element_level(i);
		    l_labor_hours(i) :=                    t_labor_hours(i);
		    l_burdened_cost(i) :=                       t_burdened_cost(i);
		    l_raw_cost(i) :=                            t_raw_cost(i);
		    l_revenue(i) :=                             t_revenue(i);
		    l_margin(i) :=                              t_margin(i);
		    l_margin_percent(i) :=                      t_margin_percent(i);
		    l_line_editable_flag(i) :=                  t_line_editable_flag(i);
		    l_row_level(i) := 			       	      t_row_level(i);
		    l_parent_element_name(i) :=                 t_parent_element_name(i);
		    l_unit_of_measure(i) := 		   	      t_unit_of_measure(i);
		    l_has_child_element(i) := 		   	      t_has_child_element(i);
		end loop;

/* Insert the project/task level records here */

 l_loop_count := nvl(l_project_id.last,-1);
if (l_loop_count > 0) then
 l_inc_count := l_loop_count+1;

  /* First Insert the project level record */
  select
	l_project_id(1),
	0,
	0,
	l_budget_version_id(1),
	-2,
	pa_fp_view_plans_util.assign_element_name
	(l_project_id(1),
	0,
	0) ,
	pa_fp_view_plans_util.assign_element_level
	(l_project_id(1),
	l_budget_version_id(1),
	0,
	0),
	0,
	0,-- as burdened_cost,
	0,-- as raw_cost,
	0,
	0, -- margin
	0, -- margin_percent
	'N', -- line_editable_flag
	pa_fp_view_plans_util.assign_row_level
	(l_project_id(1),
	0,
	0) ,
	pa_fp_view_plans_util.assign_parent_element
	(l_project_id(1),
	0,
	0) ,
	l_unit_of_measure(1),
	pa_fp_view_plans_pub.has_child_rows
	(l_project_id(1),
	l_budget_version_id(1),
	-1,
	0,
	0,
	null,
	'A')
	into
	l_project_id(l_inc_count),
	l_task_id(l_inc_count),
	l_resource_list_member_id(l_inc_count),
	l_budget_version_id(l_inc_count),
	l_res_assignment_id(l_inc_count),
	l_element_name(l_inc_count),
	l_element_level(l_inc_count),
	l_labor_hours(l_inc_count),
	l_burdened_cost(l_inc_count),
	l_raw_cost(l_inc_count),
	l_revenue(l_inc_count),
	l_margin(l_inc_count),
	l_margin_percent(l_inc_count),
	l_line_editable_flag(l_inc_count),
	l_row_level(l_inc_count),
	l_parent_element_name(l_inc_count),
	l_unit_of_measure(l_inc_count),
	l_has_child_element(l_inc_count)
	from dual;


 /* Now loop through all the resource assignments fetched and insert the parent record if its not found or rollup the amounts if its found */
 for i in 1..l_loop_count loop

   /* rolling up the project level amounts */
    if (l_task_id(l_loop_count+1) = 0 and l_resource_list_member_id(l_loop_count+1) = 0) then
          l_burdened_cost(l_loop_count+1) := l_burdened_cost(l_loop_count+1) + l_burdened_cost(i);
		  l_labor_hours(l_loop_count+1) := l_labor_hours(l_loop_count+1) + l_labor_hours(i);
		  l_raw_cost(l_loop_count+1) := l_raw_cost(l_loop_count+1) + l_raw_cost(i);

    end if;

	 for task_rec in parent_tasks_csr(l_task_id(i))
	  loop
		 l_check := 0;

		for z in nvl(l_project_id.first,0)..nvl(l_project_id.last,-1)
		loop
		   if (l_project_id(z) = l_project_id(i) and l_task_id(z) = task_rec.task_id
		       and l_resource_list_member_id(z) = 0) then
		       l_burdened_cost(z) := l_burdened_cost(z) + l_burdened_cost(i);
		       l_labor_hours(z) := l_labor_hours(z) + l_labor_hours(i);
		       l_raw_cost(z) := l_raw_cost(z) + l_raw_cost(i);
			   l_check := 1;
		   end if;
		end loop;
		if (l_check = 0) then

			/* Parent task level record is not available, insert now */
		  l_inc_count := l_inc_count + 1;

		  select
			l_project_id(i),
			task_rec.task_id,
			0,
			l_budget_version_id(i),
			-2,
			pa_fp_view_plans_util.assign_element_name
			(l_project_id(i),
			task_rec.task_id,
			0) ,
			pa_fp_view_plans_util.assign_element_level
			(l_project_id(i),
			l_budget_version_id(i),
			task_rec.task_id,
			0),
			l_labor_hours(i),
			l_burdened_cost(i),-- as burdened_cost,
			l_raw_cost(i),-- as raw_cost,
			0,
			0, -- margin
			0, -- margin_percent
			'N', -- line_editable_flag
			pa_fp_view_plans_util.assign_row_level
			(l_project_id(i),
			task_rec.task_id,
			0) ,
			pa_fp_view_plans_util.assign_parent_element
			(l_project_id(i),
			task_rec.task_id,
			0) ,
			l_unit_of_measure(i),
			pa_fp_view_plans_pub.has_child_rows
			(l_project_id(i),
			l_budget_version_id(i),
			-1,
			task_rec.task_id,
			0,
			null,
			'A')
			into
			l_project_id(l_inc_count),
			l_task_id(l_inc_count),
			l_resource_list_member_id(l_inc_count),
			l_budget_version_id(l_inc_count),
			l_res_assignment_id(l_inc_count),
			l_element_name(l_inc_count),
			l_element_level(l_inc_count),
			l_labor_hours(l_inc_count),
			l_burdened_cost(l_inc_count),
			l_raw_cost(l_inc_count),
			l_revenue(l_inc_count),
			l_margin(l_inc_count),
			l_margin_percent(l_inc_count),
			l_line_editable_flag(l_inc_count),
			l_row_level(l_inc_count),
			l_parent_element_name(l_inc_count),
			l_unit_of_measure(l_inc_count),
			l_has_child_element(l_inc_count)
			from dual;
		end if;

    end loop;

 end loop;

end if;

/* Ends- Insert the project/task level records */

	/* Ends added code for 7514054 */
l_err_stage := 300;
    /* ---- populate the PERIODS PL/SQL table with the following rows ---- */
    /* ---- COST, REVENUE, MARGIN, MARGIN_PERCENT, QUANTITY           ---- */
    /* ONLY IF pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'		           */
    if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P' then
--hr_utility.trace('l_project_id.first= ' || to_char(l_project_id.first));
--hr_utility.trace('l_project_id.last= ' || to_char(l_project_id.last));
     for i in nvl(l_project_id.first,0)..nvl(l_project_id.last,-1) loop
--hr_utility.trace('i= ' || to_char(i));
      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_QUANTITY = 'Y' then
      -- process QUANTITY numbers based on report_labor_hrs_from_code
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_project_id(i);
      l_pd_task_id(l_row_number) := l_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := l_unit_of_measure(i);
      l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
      l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
      l_pd_element_name(l_row_number) := l_element_name(i);
      l_pd_element_level(l_row_number) := l_element_level(i);
      l_pd_row_level(l_row_number) := l_row_level(i);
      l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
      l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
      l_pd_amount_type(l_row_number) := 'QUANTITY';
      l_pd_amount_subtype(l_row_number) := 'QUANTITY';
      l_pd_amount_type_id(l_row_number) := 215; -- amount_type for 'QUANTITY'
      l_pd_amount_subtype_id(l_row_number) := 215; -- amount_subtype for 'QUANTITY'
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'QUANTITY') and
              (l_default_amount_subtype_code = 'QUANTITY')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      if (l_report_labor_hrs_from_code = 'COST') then
--hr_utility.trace('try to getperiodnvalue');
--hr_utility.trace('raid= ' || to_char(l_pd_res_assignment_id(l_row_number)));
--hr_utility.trace('ppid= ' || to_char(l_period_profile_id));
        l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 1);
--hr_utility.trace('reached here');
        l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 2);
        l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 3);
        l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 4);
        l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 5);
        l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 6);
        l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 7);
        l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 8);
        l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 9);
        l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 10);
        l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 11);
        l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 12);
        l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 13);
        l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 0);
        l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 14);
	l_pd_project_total(l_row_number) := l_labor_hours(i); -- bug 2699651
      else
      	    l_pd_unit_of_measure(l_row_number) := l_unit_of_measure(i);
            l_pd_period_1(l_row_number) := null;
            l_pd_period_2(l_row_number) := null;
            l_pd_period_3(l_row_number) := null;
            l_pd_period_4(l_row_number) := null;
            l_pd_period_5(l_row_number) := null;
            l_pd_period_6(l_row_number) := null;
            l_pd_period_7(l_row_number) := null;
            l_pd_period_8(l_row_number) := null;
            l_pd_period_9(l_row_number) := null;
            l_pd_period_10(l_row_number) := null;
            l_pd_period_11(l_row_number) := null;
            l_pd_period_12(l_row_number) := null;
            l_pd_period_13(l_row_number) := null;
	    l_pd_preceding(l_row_number) := null;
	    l_pd_succeeding(l_row_number) := null;
	    l_pd_line_editable_flag(l_row_number) := 'N'; --do not edit inserted row
	    l_pd_project_total(l_row_number) := null; -- bug 2699651
      end if; -- report_labour_hrs_from_code = 'COST'
      end if; -- display_from: QUANTITY

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_BURDCOST = 'Y' then
      -- process BURDENED_COST numbers from COST BUDGET VERSION
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_project_id(i);
      l_pd_task_id(l_row_number) := l_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := null;
      l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
      l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
      l_pd_element_name(l_row_number) := l_element_name(i);
      l_pd_element_level(l_row_number) := l_element_level(i);
      l_pd_row_level(l_row_number) := l_row_level(i);
      l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
      l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
      l_pd_amount_type(l_row_number) := 'COST';
      l_pd_amount_subtype(l_row_number) := 'BURDENED_COST';
      l_pd_amount_type_id(l_row_number) := 150; -- amount_type_id for 'COST'
      l_pd_amount_subtype_id(l_row_number) := 165; -- amount_subtype_id for 'BURDENED_COST'
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'COST') and
              (l_default_amount_subtype_code = 'BURDENED_COST')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 1);
      l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 2);
      l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 3);
      l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 4);
      l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 5);
      l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 6);
      l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 7);
      l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 8);
      l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 9);
      l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 10);
      l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 11);
      l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 12);
      l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 13);
      l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 0);
      l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 165,
                    p_period_number        => 14);
      l_pd_project_total(l_row_number) := l_burdened_cost(i); -- bug 2699651
      end if; -- display_flag: BURDENED COST

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_RAWCOST = 'Y' then
      -- process RAW_COST numbers from COST BUDGET VERSION
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_project_id(i);
      l_pd_task_id(l_row_number) := l_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := null;
      l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
      l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
      l_pd_element_name(l_row_number) := l_element_name(i);
      l_pd_element_level(l_row_number) := l_element_level(i);
      l_pd_row_level(l_row_number) := l_row_level(i);
      l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
      l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
      l_pd_amount_type(l_row_number) := 'COST';
      l_pd_amount_subtype(l_row_number) := 'RAW_COST';
      l_pd_amount_type_id(l_row_number) := 150; -- amount_type_id for 'COST'
      l_pd_amount_subtype_id(l_row_number) := 160; -- amount_subtype_id for 'RAW_COST'
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'COST') and
              (l_default_amount_subtype_code = 'RAW_COST')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 1);
      l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 2);
      l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 3);
      l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 4);
      l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 5);
      l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 6);
      l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 7);
      l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 8);
      l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 9);
      l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 10);
      l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 11);
      l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 12);
      l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 13);
      l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 0);
      l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    --p_amount_type_id       => 150,
                    p_amount_type_id       => 160,
                    p_period_number        => 14);
      l_pd_project_total(l_row_number) := l_raw_cost(i); -- bug 2699651
      end if; -- display_flag: RAW COST

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_REVENUE = 'Y' then
      -- POPULATE null'S for REVENUE row in PERIODS PL/SQL TABLE
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_project_id(i);
      l_pd_task_id(l_row_number) := l_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := null;
      l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
      l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
      l_pd_element_name(l_row_number) := l_element_name(i);
      l_pd_element_level(l_row_number) := l_element_level(i);
      l_pd_row_level(l_row_number) := l_row_level(i);
      l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
      --l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
      l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit inserted row
      l_pd_amount_type(l_row_number) := 'REVENUE';
      l_pd_amount_subtype(l_row_number) := 'REVENUE';
      l_pd_amount_type_id(l_row_number) := 100; -- amount_type_id of REVENUE
      l_pd_amount_subtype_id(l_row_number) := 100; -- amount_subtype_id of REVENUE
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'REVENUE') and
              (l_default_amount_subtype_code = 'REVENUE')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := null;
      l_pd_period_2(l_row_number) := null;
      l_pd_period_3(l_row_number) := null;
      l_pd_period_4(l_row_number) := null;
      l_pd_period_5(l_row_number) := null;
      l_pd_period_6(l_row_number) := null;
      l_pd_period_7(l_row_number) := null;
      l_pd_period_8(l_row_number) := null;
      l_pd_period_9(l_row_number) := null;
      l_pd_period_10(l_row_number) := null;
      l_pd_period_11(l_row_number) := null;
      l_pd_period_12(l_row_number) := null;
      l_pd_period_13(l_row_number) := null;
      l_pd_preceding(l_row_number) := null;
      l_pd_succeeding(l_row_number) := null;
      l_pd_project_total(l_row_number) := null; -- bug 2699651
      end if; -- display_from: REVENUE

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGIN = 'Y' then
      -- POPULATE 0'S for MARGIN row in PERIODS PL/SQL TABLE
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_project_id(i);
      l_pd_task_id(l_row_number) := l_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := null;
      l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
      l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
      l_pd_element_name(l_row_number) := l_element_name(i);
      l_pd_element_level(l_row_number) := l_element_level(i);
      l_pd_row_level(l_row_number) := l_row_level(i);
      l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
      --l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
      l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit inserted row
      l_pd_amount_type(l_row_number) := 'MARGIN';
      l_pd_amount_subtype(l_row_number) := 'MARGIN';
      l_pd_amount_type_id(l_row_number) := 230; -- amount_type_id of MARGIN
      l_pd_amount_subtype_id(l_row_number) := 230; -- amount_subtype_id of MARGIN
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'MARGIN') and
              (l_default_amount_subtype_code = 'MARGIN')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := null;
      l_pd_period_2(l_row_number) := null;
      l_pd_period_3(l_row_number) := null;
      l_pd_period_4(l_row_number) := null;
      l_pd_period_5(l_row_number) := null;
      l_pd_period_6(l_row_number) := null;
      l_pd_period_7(l_row_number) := null;
      l_pd_period_8(l_row_number) := null;
      l_pd_period_9(l_row_number) := null;
      l_pd_period_10(l_row_number) := null;
      l_pd_period_11(l_row_number) := null;
      l_pd_period_12(l_row_number) := null;
      l_pd_period_13(l_row_number) := null;
      l_pd_preceding(l_row_number) := null;
      l_pd_succeeding(l_row_number) := null;
      l_pd_project_total(l_row_number) := null; -- bug 3179756
      end if; -- display_from: MARGIN

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGINPCT = 'Y' then
      -- POPULATE 0'S for MARGIN_PERCENT row in PERIODS PL/SQL TABLE
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_project_id(i);
      l_pd_task_id(l_row_number) := l_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := null;
      l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
      l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
      l_pd_element_name(l_row_number) := l_element_name(i);
      l_pd_element_level(l_row_number) := l_element_level(i);
      l_pd_row_level(l_row_number) := l_row_level(i);
      l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
      --l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
      l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit inserted row
      l_pd_amount_type(l_row_number) := 'MARGIN_PERCENT';
      l_pd_amount_subtype(l_row_number) := 'MARGIN_PERCENT';
      l_pd_amount_type_id(l_row_number) := 231; -- amount_type_id of MARGIN_PERCENT
      l_pd_amount_subtype_id(l_row_number) := 231; -- amount_subtype_id of MARGIN_PERCENT
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'MARGIN_PERCENT') and
              (l_default_amount_subtype_code = 'MARGIN_PERCENT')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := null;
      l_pd_period_2(l_row_number) := null;
      l_pd_period_3(l_row_number) := null;
      l_pd_period_4(l_row_number) := null;
      l_pd_period_5(l_row_number) := null;
      l_pd_period_6(l_row_number) := null;
      l_pd_period_7(l_row_number) := null;
      l_pd_period_8(l_row_number) := null;
      l_pd_period_9(l_row_number) := null;
      l_pd_period_10(l_row_number) := null;
      l_pd_period_11(l_row_number) := null;
      l_pd_period_12(l_row_number) := null;
      l_pd_period_13(l_row_number) := null;
      l_pd_preceding(l_row_number) := null;
      l_pd_succeeding(l_row_number) := null;
      l_pd_project_total(l_row_number) := null; -- bug 2699651
      end if; --display_from: MARGIN PERCENT
     end loop;
    end if; --pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'
l_err_stage := 400;
    pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single', '400: COST version - FINISHED populating amts pl/sql tables', 1);

  -- POPULATE global temporary table PA_FIN_VP_AMTS_VIEW_TMP
  -- ONLY if pa_fp_view_plans_pub.G_AMT_OR_PD = 'A'
  if pa_fp_view_plans_pub.G_AMT_OR_PD = 'A' then
   forall i in nvl(l_project_id.first,0)..nvl(l_project_id.last,-1)
      insert into pa_fin_vp_amts_view_tmp
        (project_id,
         task_id,
         resource_list_member_id,
         element_name,
         element_level,
         labor_hours,
         burdened_cost,
         raw_cost,
         revenue,
         margin,
         margin_percent,
         editable_flag,
	 row_level,
         parent_element_name,
	 cost_resource_assignment_id,
	 rev_resource_assignment_id,
	 all_resource_assignment_id,
	 unit_of_measure,
	 has_child_element) values
        (l_project_id(i),
         l_task_id(i),
         l_resource_list_member_id(i),
         l_element_name(i),
         l_element_level(i),
         nvl(l_labor_hours(i), 0),
         nvl(l_burdened_cost(i), 0),
         nvl(l_raw_cost(i), 0),
         null, -- revenue
         null, -- margin
         null, -- margin percent
         l_line_editable_flag(i),
	 l_row_level(i),
         l_parent_element_name(i),
	 l_res_assignment_id(i),
	 -1,
	 -1,
	 l_unit_of_measure(i),
	 l_has_child_element(i));
  end if; --pa_fp_view_plans_pub.G_AMT_OR_PD= 'A'
l_err_stage := 500;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single', '800: amts temp table populated', 1);

  -- POPULATE global temporary table PA_FIN_VP_PDS_VIEW_TMP
  -- ONLY if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'
  if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P' then
   forall z in nvl(l_pd_project_id.first,0)..nvl(l_pd_project_id.last,-1)
       insert into pa_fin_vp_pds_view_tmp
        (project_id,
         task_id,
         resource_list_member_id,
	 uom,
         element_name,
         element_level,
         editable_flag,
         row_level,
         parent_element_name,
         amount_type,
         amount_subtype,
         amount_type_id,
         amount_subtype_id,
         period_amount1,
         period_amount2,
         period_amount3,
         period_amount4,
         period_amount5,
         period_amount6,
         period_amount7,
         period_amount8,
         period_amount9,
         period_amount10,
         period_amount11,
         period_amount12,
         period_amount13,
	 cost_resource_assignment_id,
	 rev_resource_assignment_id,
	 all_resource_assignment_id,
	 preceding_periods_amount,
	 succeeding_periods_amount,
	 has_child_element,
	 project_total) values
        (l_pd_project_id(z),
         l_pd_task_id(z),
         l_pd_resource_list_member_id(z),
	 l_pd_unit_of_measure(z),
         l_pd_element_name(z),
         l_pd_element_level(z),
         l_pd_line_editable_flag(z),
         l_pd_row_level(z),
         l_pd_parent_element_name(z),
         l_pd_amount_type(z),
         l_pd_amount_subtype(z),
         l_pd_amount_type_id(z),
         l_pd_amount_subtype_id(z),
         nvl(l_pd_period_1(z), 0),
         nvl(l_pd_period_2(z), 0),
         nvl(l_pd_period_3(z), 0),
         nvl(l_pd_period_4(z), 0),
         nvl(l_pd_period_5(z), 0),
         nvl(l_pd_period_6(z), 0),
         nvl(l_pd_period_7(z), 0),
         nvl(l_pd_period_8(z), 0),
         nvl(l_pd_period_9(z), 0),
         nvl(l_pd_period_10(z), 0),
         nvl(l_pd_period_11(z), 0),
         nvl(l_pd_period_12(z), 0),
         nvl(l_pd_period_13(z), 0),
	 l_pd_res_assignment_id(z),
	 -1,
	 -1,
	 l_pd_preceding(z),
	 l_pd_succeeding(z),
	 l_pd_has_child_element(z),
	 l_pd_project_total(z));

/* Added below code for bug 7514054 */
	/* Logic to rollp the Period amounts to the parent levels */

   for rollup_rec in rollup_period_amt_csr
   loop
		t_period_amount1 := null;
		t_period_amount2 := null;
		t_period_amount3 := null;
		t_period_amount4 := null;
		t_period_amount5 := null;
		t_period_amount6 := null;
		t_period_amount7 := null;
		t_period_amount8 := null;
		t_period_amount9 := null;
		t_period_amount10 := null;
		t_period_amount11 := null;
		t_period_amount12 := null;
		t_period_amount13 := null;

        select  period_amount1,
			period_amount2,
			period_amount3,
			period_amount4,
			period_amount5,
			period_amount6,
			period_amount7,
			period_amount8,
			period_amount9,
			period_amount10,
			period_amount11,
			period_amount12,
			period_amount13
		into
		    t_period_amount1,
			t_period_amount2,
			t_period_amount3,
			t_period_amount4,
			t_period_amount5,
			t_period_amount6,
			t_period_amount7,
			t_period_amount8,
			t_period_amount9,
			t_period_amount10,
			t_period_amount11,
			t_period_amount12,
			t_period_amount13
	from pa_fin_vp_pds_view_tmp
    where rowid = rollup_rec.rowid;

 if (rollup_rec.element_name is not null) then
    update pa_fin_vp_pds_view_tmp p
	set  p.period_amount1 = nvl(p.period_amount1, 0)+nvl(t_period_amount1,0),
         p.period_amount2 = nvl(p.period_amount2, 0)+nvl(t_period_amount2, 0),
         p.period_amount3 = nvl(p.period_amount3, 0)+nvl(t_period_amount3, 0),
         p.period_amount4 = nvl(p.period_amount4, 0)+nvl(t_period_amount4, 0),
         p.period_amount5 = nvl(p.period_amount5, 0)+nvl(t_period_amount5, 0),
         p.period_amount6 = nvl(p.period_amount6, 0)+nvl(t_period_amount6, 0),
         p.period_amount7 = nvl(p.period_amount7, 0)+nvl(t_period_amount7, 0),
         p.period_amount8 = nvl(p.period_amount8, 0)+nvl(t_period_amount8, 0),
         p.period_amount9 = nvl(p.period_amount9, 0)+nvl(t_period_amount9, 0),
         p.period_amount10 = nvl(p.period_amount10, 0)+nvl(t_period_amount10, 0),
         p.period_amount11 = nvl(p.period_amount11, 0)+nvl(t_period_amount11, 0),
         p.period_amount12 = nvl(p.period_amount12, 0)+nvl(t_period_amount12, 0),
         p.period_amount13 = nvl(p.period_amount13, 0)+nvl(t_period_amount13, 0)
	where p.row_level < rollup_rec.row_level
	  and p.amount_subtype = rollup_rec.amount_subtype
      and rollup_rec.element_name is not null
	    and p.element_name = rollup_rec.parent_element_name
		and p.element_name is not null;
	else
    update pa_fin_vp_pds_view_tmp p
	set  p.period_amount1 = nvl(p.period_amount1, 0)+nvl(t_period_amount1,0),
         p.period_amount2 = nvl(p.period_amount2, 0)+nvl(t_period_amount2, 0),
         p.period_amount3 = nvl(p.period_amount3, 0)+nvl(t_period_amount3, 0),
         p.period_amount4 = nvl(p.period_amount4, 0)+nvl(t_period_amount4, 0),
         p.period_amount5 = nvl(p.period_amount5, 0)+nvl(t_period_amount5, 0),
         p.period_amount6 = nvl(p.period_amount6, 0)+nvl(t_period_amount6, 0),
         p.period_amount7 = nvl(p.period_amount7, 0)+nvl(t_period_amount7, 0),
         p.period_amount8 = nvl(p.period_amount8, 0)+nvl(t_period_amount8, 0),
         p.period_amount9 = nvl(p.period_amount9, 0)+nvl(t_period_amount9, 0),
         p.period_amount10 = nvl(p.period_amount10, 0)+nvl(t_period_amount10, 0),
         p.period_amount11 = nvl(p.period_amount11, 0)+nvl(t_period_amount11, 0),
         p.period_amount12 = nvl(p.period_amount12, 0)+nvl(t_period_amount12, 0),
         p.period_amount13 = nvl(p.period_amount13, 0)+nvl(t_period_amount13, 0)
	where p.row_level < rollup_rec.row_level
	  and p.amount_subtype = rollup_rec.amount_subtype
      and rollup_rec.element_name is null
	    and p.element_name is null
		and (p.project_id,p.task_id, p.resource_list_member_id,row_level)
		in (select p1.project_id, p1.task_id, p1.resource_list_member_id, p1.row_level
		from pa_fin_vp_pds_view_tmp p1
		where p1.element_name = (select p2.parent_element_name from
               pa_fin_vp_pds_view_tmp p2
               where p2.row_level = rollup_rec.row_level
                 and p2.element_name is not null
                 and p2.project_id = rollup_rec.project_id
                 and p2.task_id = rollup_rec.task_id
                 and p2.resource_list_member_id = rollup_rec.resource_list_member_id
				 and rownum<2
               )
          );
	end if;
   end loop;
/* Ends added for 7514054 */
  end if; -- pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'
l_err_stage := 600;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single', '900: pds temp table populated', 1);


  elsif p_cost_or_rev = 'R' then
l_err_stage := 700;
    pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single', '500: this is a REVENUE version - populating amts pl/sql tables', 1);
    --hr_utility.trace('this is a REVENUE version: 500');
    /* Modified below code for 7514054 */

    open av_rev_csr;
    fetch av_rev_csr bulk collect into
          t_project_id,
          t_task_id,
          t_resource_list_member_id,
          t_budget_version_id,
          t_res_assignment_id,
          t_element_name,
          t_element_level,
          t_labor_hours,
          t_burdened_cost,
          t_raw_cost,
          t_revenue,
          t_margin,
          t_margin_percent,
          t_line_editable_flag,
	      t_row_level,
          t_parent_element_name,
	      t_unit_of_measure,
	      t_has_child_element;
    close av_rev_csr;

    /* Added below code for 7514054 */

     for i in nvl(t_project_id.first,0)..nvl(t_project_id.last,-1) loop
	    l_project_id(i) :=                          t_project_id(i);
	    l_task_id(i) :=                             t_task_id(i);
	    l_resource_list_member_id(i) :=             t_resource_list_member_id(i);
	    l_budget_version_id(i) :=                   t_budget_version_id(i);
	    l_res_assignment_id(i) :=                   t_res_assignment_id(i);
	    l_element_name(i) :=                        t_element_name(i);
	    l_element_level(i) :=                       t_element_level(i);
	    l_labor_hours(i) :=                    t_labor_hours(i);
	    l_burdened_cost(i) :=                       t_burdened_cost(i);
	    l_raw_cost(i) :=                            t_raw_cost(i);
	    l_revenue(i) :=                             t_revenue(i);
	    l_margin(i) :=                              t_margin(i);
	    l_margin_percent(i) :=                      t_margin_percent(i);
	    l_line_editable_flag(i) :=                  t_line_editable_flag(i);
	    l_row_level(i) := 			       	      t_row_level(i);
	    l_parent_element_name(i) :=                 t_parent_element_name(i);
	    l_unit_of_measure(i) := 		   	      t_unit_of_measure(i);
	    l_has_child_element(i) := 		   	      t_has_child_element(i);
     end loop;

/* Insert the project/task level records here */


 l_loop_count := nvl(l_project_id.last,-1);
if (l_loop_count > 0) then
 l_inc_count := l_loop_count+1;

  /* First Insert the project level record */
  select
	l_project_id(1),
	0,
	0,
	l_budget_version_id(1),
	-2,
	pa_fp_view_plans_util.assign_element_name
	(l_project_id(1),
	0,
	0) ,
	pa_fp_view_plans_util.assign_element_level
	(l_project_id(1),
	l_budget_version_id(1),
	0,
	0),
	0,
	0,-- as burdened_cost,
	0,-- as raw_cost,
	0,
	0, -- margin
	0, -- margin_percent
	'N', -- line_editable_flag
	pa_fp_view_plans_util.assign_row_level
	(l_project_id(1),
	0,
	0) ,
	pa_fp_view_plans_util.assign_parent_element
	(l_project_id(1),
	0,
	0) ,
	l_unit_of_measure(1),
	pa_fp_view_plans_pub.has_child_rows
	(l_project_id(1),
	l_budget_version_id(1),
	-1,
	0,
	0,
	null,
	'A')
	into
	l_project_id(l_inc_count),
	l_task_id(l_inc_count),
	l_resource_list_member_id(l_inc_count),
	l_budget_version_id(l_inc_count),
	l_res_assignment_id(l_inc_count),
	l_element_name(l_inc_count),
	l_element_level(l_inc_count),
	l_labor_hours(l_inc_count),
	l_burdened_cost(l_inc_count),
	l_raw_cost(l_inc_count),
	l_revenue(l_inc_count),
	l_margin(l_inc_count),
	l_margin_percent(l_inc_count),
	l_line_editable_flag(l_inc_count),
	l_row_level(l_inc_count),
	l_parent_element_name(l_inc_count),
	l_unit_of_measure(l_inc_count),
	l_has_child_element(l_inc_count)
	from dual;

 /* Now loop through all the resource assignments fetched and insert the parent record if its not found or rollup the amounts if its found */
 for i in 1..l_loop_count loop
   /* rolling up the project level amounts */
    if (l_task_id(l_loop_count+1) = 0 and l_resource_list_member_id(l_loop_count+1) = 0) then
          l_revenue(l_loop_count+1) := l_revenue(l_loop_count+1) + l_revenue(i);
		  l_labor_hours(l_loop_count+1) := l_labor_hours(l_loop_count+1) + l_labor_hours(i);

    end if;

	 for task_rec in parent_tasks_csr(l_task_id(i))
	  loop
		 l_check := 0;
		for z in nvl(l_project_id.first,0)..nvl(l_project_id.last,-1)
		loop
		   if (l_project_id(z) = l_project_id(i) and l_task_id(z) = task_rec.task_id
		       and l_resource_list_member_id(z) = 0) then
		       l_revenue(z) := l_revenue(z) + l_revenue(i);
		       l_labor_hours(z) := l_labor_hours(z) + l_labor_hours(i);

			   l_check := 1;

		   end if;
		end loop;
		if (l_check = 0) then
	  /* Parent task level record is not available, insert now */
	  l_inc_count := l_inc_count + 1;

	  select
		l_project_id(i),
		task_rec.task_id,
		0,
		l_budget_version_id(i),
		-2,
		pa_fp_view_plans_util.assign_element_name
		(l_project_id(i),
		task_rec.task_id,
		0) ,
		pa_fp_view_plans_util.assign_element_level
		(l_project_id(i),
		l_budget_version_id(i),
		task_rec.task_id,
		0),
		l_labor_hours(i),
		0,-- as burdened_cost,
		0,-- as raw_cost,
		l_revenue(i),
		0, -- margin
		0, -- margin_percent
		'N', -- line_editable_flag
		pa_fp_view_plans_util.assign_row_level
		(l_project_id(i),
		task_rec.task_id,
		0) ,
		pa_fp_view_plans_util.assign_parent_element
		(l_project_id(i),
		task_rec.task_id,
		0) ,
		l_unit_of_measure(i),
		pa_fp_view_plans_pub.has_child_rows
		(l_project_id(i),
		l_budget_version_id(i),
		-1,
		task_rec.task_id,
		0,
		null,
		'A')
		into
		l_project_id(l_inc_count),
		l_task_id(l_inc_count),
		l_resource_list_member_id(l_inc_count),
		l_budget_version_id(l_inc_count),
		l_res_assignment_id(l_inc_count),
		l_element_name(l_inc_count),
		l_element_level(l_inc_count),
		l_labor_hours(l_inc_count),
		l_burdened_cost(l_inc_count),
		l_raw_cost(l_inc_count),
		l_revenue(l_inc_count),
		l_margin(l_inc_count),
		l_margin_percent(l_inc_count),
		l_line_editable_flag(l_inc_count),
		l_row_level(l_inc_count),
		l_parent_element_name(l_inc_count),
		l_unit_of_measure(l_inc_count),
		l_has_child_element(l_inc_count)
		from dual;
		end if;

    end loop;

 end loop;

end if;

/*Ends new rollup Amounts logic */

	/* Ends added for 7514054 */

l_err_stage := 800;
    /* ---- populate the PERIODS PL/SQL table with the following rows ---- */
    /* ---- COST, REVENUE, MARGIN, MARGIN_PERCENT, QUANTITY           ---- */
    /* ONLY if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'			   */
--hr_utility.trace('number of rows in csr= ' || TO_CHAR(l_project_id.last));
    if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P' then
     for i in nvl(l_project_id.first,0)..nvl(l_project_id.last,-1) loop

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_QUANTITY = 'Y' then
--hr_utility.trace('inserting row for Quantity: ' || TO_CHAR(i));
      -- process the QUANTITY numbers based on report_labor_hrs_from_code
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_project_id(i);
      l_pd_task_id(l_row_number) := l_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := l_unit_of_measure(i);
      l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
      l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
      l_pd_element_name(l_row_number) := l_element_name(i);
      l_pd_element_level(l_row_number) := l_element_level(i);
      l_pd_row_level(l_row_number) := l_row_level(i);
      l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
      l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
      l_pd_amount_type(l_row_number) := 'QUANTITY';
      l_pd_amount_subtype(l_row_number) := 'QUANTITY';
      l_pd_amount_type_id(l_row_number) := 215; -- amount_type_id for 'QUANTITY'
      l_pd_amount_subtype_id(l_row_number) := 215; -- amount_subtype_id for 'QUANTITY'
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'QUANTITY') and
              (l_default_amount_subtype_code = 'QUANTITY')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      if (l_report_labor_hrs_from_code = 'REVENUE') then
        l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 1);
        l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 2);
        l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 3);
        l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 4);
        l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 5);
        l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 6);
        l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 7);
        l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 8);
        l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 9);
        l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 10);
        l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 11);
        l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 12);
        l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 13);
        l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 0);
        l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 215,
                    p_period_number        => 14);
      l_pd_project_total(l_row_number) := l_labor_hours(i); -- bug 2699651
      else
        l_pd_unit_of_measure(l_row_number) := l_unit_of_measure(i);
        l_pd_period_1(l_row_number) := null;
        l_pd_period_2(l_row_number) := null;
        l_pd_period_3(l_row_number) := null;
        l_pd_period_4(l_row_number) := null;
        l_pd_period_5(l_row_number) := null;
        l_pd_period_6(l_row_number) := null;
        l_pd_period_7(l_row_number) := null;
        l_pd_period_8(l_row_number) := null;
        l_pd_period_9(l_row_number) := null;
        l_pd_period_10(l_row_number) := null;
        l_pd_period_11(l_row_number) := null;
        l_pd_period_12(l_row_number) := null;
        l_pd_period_13(l_row_number) := null;
	l_pd_preceding(l_row_number) := null;
	l_pd_succeeding(l_row_number) := null;
	l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit inserted row
        l_pd_project_total(l_row_number) := null; -- bug 2699651
      end if; -- QUANTITY
      end if; -- display_flag: QUANTITY

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_REVENUE = 'Y' then
--hr_utility.trace('inserting row for Revenue: ' || TO_CHAR(i));
      -- process REVENUE numbers from REVENUE BUDGET VERSION
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_project_id(i);
      l_pd_task_id(l_row_number) := l_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := null;
      l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
      l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
      l_pd_element_name(l_row_number) := l_element_name(i);
      l_pd_element_level(l_row_number) := l_element_level(i);
      l_pd_row_level(l_row_number) := l_row_level(i);
      l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
      l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
      l_pd_amount_type(l_row_number) := 'REVENUE';
      l_pd_amount_subtype(l_row_number) := 'REVENUE';
      l_pd_amount_type_id(l_row_number) := 100; -- amount_type_id for 'REVENUE'
      l_pd_amount_subtype_id(l_row_number) := 100; -- amount_subtype_id for 'REVENUE'
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'REVENUE') and
              (l_default_amount_subtype_code = 'REVENUE')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 1);
      l_pd_period_2(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 2);
      l_pd_period_3(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 3);
      l_pd_period_4(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 4);
      l_pd_period_5(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 5);
      l_pd_period_6(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 6);
      l_pd_period_7(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 7);
      l_pd_period_8(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 8);
      l_pd_period_9(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 9);
      l_pd_period_10(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 10);
      l_pd_period_11(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 11);
      l_pd_period_12(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 12);
      l_pd_period_13(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 13);
      l_pd_preceding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 0);
      l_pd_succeeding(l_row_number) := pa_fp_view_plans_util.get_period_n_value
                   (p_period_profile_id    => l_period_profile_id,
		    p_budget_version_id    => l_pd_budget_version_id(l_row_number),
		    p_resource_assignment_id => l_pd_res_assignment_id(l_row_number),
 	            p_project_currency_type => l_currency_type,
                    p_amount_type_id       => 100,
                    p_period_number        => 14);
      l_pd_project_total(l_row_number) := l_revenue(i); -- bug 2699651
      end if; -- display_from: REVENUE

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_BURDCOST = 'Y' then
--hr_utility.trace('creating row for burdened cost: ' || TO_CHAR(i));
      -- POPULATE null'S for BURDENED_COST row in PERIODS PL/SQL TABLE
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_project_id(i);
      l_pd_task_id(l_row_number) := l_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := null;
      l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
      l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
      l_pd_element_name(l_row_number) := l_element_name(i);
      l_pd_element_level(l_row_number) := l_element_level(i);
      l_pd_row_level(l_row_number) := l_row_level(i);
      l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
      --l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
      l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit inserted row
      l_pd_amount_type(l_row_number) := 'COST';
      l_pd_amount_subtype(l_row_number) := 'BURDENED_COST';
      l_pd_amount_type_id(l_row_number) := 150; -- amount_type_id of COST
      l_pd_amount_subtype_id(l_row_number) := 165; -- amount_subtype_id of BURDENED_COST
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'COST') and
              (l_default_amount_subtype_code = 'BURDENED_COST')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := null;
      l_pd_period_2(l_row_number) := null;
      l_pd_period_3(l_row_number) := null;
      l_pd_period_4(l_row_number) := null;
      l_pd_period_5(l_row_number) := null;
      l_pd_period_6(l_row_number) := null;
      l_pd_period_7(l_row_number) := null;
      l_pd_period_8(l_row_number) := null;
      l_pd_period_9(l_row_number) := null;
      l_pd_period_10(l_row_number) := null;
      l_pd_period_11(l_row_number) := null;
      l_pd_period_12(l_row_number) := null;
      l_pd_period_13(l_row_number) := null;
      l_pd_preceding(l_row_number) := null;
      l_pd_succeeding(l_row_number) := null;
      l_pd_project_total(l_row_number) := null; -- bug 2699651
      end if; -- display_from: BURDENED COST

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_RAWCOST = 'Y' then
--hr_utility.trace('inserting row for RawCost: ' || TO_CHAR(i));
      -- POPULATE null'S for RAW_COST row in PERIODS PL/SQL TABLE
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_project_id(i);
      l_pd_task_id(l_row_number) := l_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := null;
      l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
      l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
      l_pd_element_name(l_row_number) := l_element_name(i);
      l_pd_element_level(l_row_number) := l_element_level(i);
      l_pd_row_level(l_row_number) := l_row_level(i);
      l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
      --l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
      l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit inserted row
      l_pd_amount_type(l_row_number) := 'COST';
      l_pd_amount_subtype(l_row_number) := 'RAW_COST';
      l_pd_amount_type_id(l_row_number) := 150; -- amount_type_id of COST
      l_pd_amount_subtype_id(l_row_number) := 160; -- amount_subtype_id of RAW_COST
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'COST') and
              (l_default_amount_subtype_code = 'RAW_COST')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := null;
      l_pd_period_2(l_row_number) := null;
      l_pd_period_3(l_row_number) := null;
      l_pd_period_4(l_row_number) := null;
      l_pd_period_5(l_row_number) := null;
      l_pd_period_6(l_row_number) := null;
      l_pd_period_7(l_row_number) := null;
      l_pd_period_8(l_row_number) := null;
      l_pd_period_9(l_row_number) := null;
      l_pd_period_10(l_row_number) := null;
      l_pd_period_11(l_row_number) := null;
      l_pd_period_12(l_row_number) := null;
      l_pd_period_13(l_row_number) := null;
      l_pd_preceding(l_row_number) := null;
      l_pd_succeeding(l_row_number) := null;
      l_pd_project_total(l_row_number) := null; -- bug 2699651
      end if; -- display_from: RAW COST

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGIN = 'Y' then
--hr_utility.trace('inserting row for Margin: ' || TO_CHAR(i));
      -- POPULATE null'S for MARGIN row in PERIODS PL/SQL TABLE
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_project_id(i);
      l_pd_task_id(l_row_number) := l_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := null;
      l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
      l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
      l_pd_element_name(l_row_number) := l_element_name(i);
      l_pd_element_level(l_row_number) := l_element_level(i);
      l_pd_row_level(l_row_number) := l_row_level(i);
      l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
      --l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
      l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit inserted row
      l_pd_amount_type(l_row_number) := 'MARGIN';
      l_pd_amount_subtype(l_row_number) := 'MARGIN';
      l_pd_amount_type_id(l_row_number) := 230; -- amount_type_id of MARGIN
      l_pd_amount_subtype_id(l_row_number) := 230; -- amount_subtype_id of MARGIN
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'MARGIN') and
              (l_default_amount_subtype_code = 'MARGIN')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := null;
      l_pd_period_2(l_row_number) := null;
      l_pd_period_3(l_row_number) := null;
      l_pd_period_4(l_row_number) := null;
      l_pd_period_5(l_row_number) := null;
      l_pd_period_6(l_row_number) := null;
      l_pd_period_7(l_row_number) := null;
      l_pd_period_8(l_row_number) := null;
      l_pd_period_9(l_row_number) := null;
      l_pd_period_10(l_row_number) := null;
      l_pd_period_11(l_row_number) := null;
      l_pd_period_12(l_row_number) := null;
      l_pd_period_13(l_row_number) := null;
      l_pd_preceding(l_row_number) := null;
      l_pd_succeeding(l_row_number) := null;
      l_pd_project_total(l_row_number) := null; -- bug 2699651
      end if; -- display_from: MARGIN

      if pa_fp_view_plans_pub.G_DISPLAY_FLAG_MARGINPCT = 'Y' then
--hr_utility.trace('inserting row for MarginPct: ' || TO_CHAR(i));
      -- POPULATE null'S for MARGIN_PERCENT row in PERIODS PL/SQL TABLE
      l_row_number := l_row_number + 1;  -- increment row counter
      l_pd_project_id(l_row_number) := l_project_id(i);
      l_pd_task_id(l_row_number) := l_task_id(i);
      l_pd_resource_list_member_id(l_row_number) := l_resource_list_member_id(i);
      l_pd_unit_of_measure(l_row_number) := null;
      l_pd_budget_version_id(l_row_number) := l_budget_version_id(i);
      l_pd_res_assignment_id(l_row_number) := l_res_assignment_id(i);
      l_pd_element_name(l_row_number) := l_element_name(i);
      l_pd_element_level(l_row_number) := l_element_level(i);
      l_pd_row_level(l_row_number) := l_row_level(i);
      l_pd_parent_element_name(l_row_number) := l_parent_element_name(i);
      --l_pd_line_editable_flag(l_row_number) := l_line_editable_flag(i);
      l_pd_line_editable_flag(l_row_number) := 'N'; -- cannot edit inserted row
      l_pd_amount_type(l_row_number) := 'MARGIN_PERCENT';
      l_pd_amount_subtype(l_row_number) := 'MARGIN_PERCENT';
      l_pd_amount_type_id(l_row_number) := 231; -- amount_type_id of MARGIN_PERCENT
      l_pd_amount_subtype_id(l_row_number) := 231; -- amount_subtype_id of MARGIN_PERCENT
      -- DEFAULT_AMOUNT_TYPE_CODE check: if not the default, then demote
      if not ((l_default_amount_type_code = 'MARGIN_PERCENT') and
              (l_default_amount_subtype_code = 'MARGIN_PERCENT')) then
        l_pd_parent_element_name(l_row_number) := l_pd_element_name(l_row_number);
        l_pd_element_name(l_row_number) := null;
	l_pd_has_child_element(l_row_number) := 'N';
      else
	l_pd_has_child_element(l_row_number) := 'Y';
      end if;
      l_pd_period_1(l_row_number) := null;
      l_pd_period_2(l_row_number) := null;
      l_pd_period_3(l_row_number) := null;
      l_pd_period_4(l_row_number) := null;
      l_pd_period_5(l_row_number) := null;
      l_pd_period_6(l_row_number) := null;
      l_pd_period_7(l_row_number) := null;
      l_pd_period_8(l_row_number) := null;
      l_pd_period_9(l_row_number) := null;
      l_pd_period_10(l_row_number) := null;
      l_pd_period_11(l_row_number) := null;
      l_pd_period_12(l_row_number) := null;
      l_pd_period_13(l_row_number) := null;
      l_pd_preceding(l_row_number) := null;
      l_pd_succeeding(l_row_number) := null;
      l_pd_project_total(l_row_number) := null; -- bug 2699651
      end if; --display_from: MARGIN PERCENT
     end loop;
    end if; -- pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'
l_err_stage:= 900;
    pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single', '600: REVENUE version - FINISHED populating amts pl/sql tables', 1);
    --hr_utility.trace('finished populating amts pl/sql tables: 600');

  -- POPULATE global temporary table PA_FIN_VP_AMTS_VIEW_TMP
  -- only if pa_fp_view_plans_pub.G_AMT_OR_PD = 'A'
 if pa_fp_view_plans_pub.G_AMT_OR_PD = 'A' then
  forall i in nvl(l_project_id.first,0)..nvl(l_project_id.last,-1)
    insert into pa_fin_vp_amts_view_tmp
        (project_id,
         task_id,
         resource_list_member_id,
         element_name,
         element_level,
         labor_hours,
         burdened_cost,
         raw_cost,
         revenue,
         margin,
         margin_percent,
         editable_flag,
	 row_level,
         parent_element_name,
	 cost_resource_assignment_id,
	 rev_resource_assignment_id,
	 all_resource_assignment_id,
	 unit_of_measure,
	 has_child_element) values
        (l_project_id(i),
         l_task_id(i),
         l_resource_list_member_id(i),
         l_element_name(i),
         l_element_level(i),
         nvl(l_labor_hours(i), 0),
         null, -- burdened_cost
         null, -- raw_cost
         nvl(l_revenue(i), 0),
         null, -- margin
         null, -- margin_percent
         l_line_editable_flag(i),
	 l_row_level(i),
         l_parent_element_name(i),
	 -1,
	 l_res_assignment_id(i),
	 -1,
	 l_unit_of_measure(i),
	 l_has_child_element(i));
l_err_stage:= 1000;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single', '800: amts temp table populated', 1);
  --hr_utility.trace('amts temp table populated: 800');
 end if; -- pa_fp_view_plans_pub.G_AMT_OR_PD= 'A'

  -- POPULATE global temporary table PA_FIN_VP_PDS_VIEW_TMP
  -- only if in periodic mode
 if pa_fp_view_plans_pub.G_AMT_OR_PD = 'P' then
  forall z in nvl(l_pd_project_id.first,0)..nvl(l_pd_project_id.last,-1)
      insert into pa_fin_vp_pds_view_tmp
        (project_id,
         task_id,
         resource_list_member_id,
	 uom,
         element_name,
         element_level,
         editable_flag,
         row_level,
         parent_element_name,
         amount_type,
         amount_subtype,
         amount_type_id,
         amount_subtype_id,
         period_amount1,
         period_amount2,
         period_amount3,
         period_amount4,
         period_amount5,
         period_amount6,
         period_amount7,
         period_amount8,
         period_amount9,
         period_amount10,
         period_amount11,
         period_amount12,
         period_amount13,
	 cost_resource_assignment_id,
	 rev_resource_assignment_id,
	 all_resource_assignment_id,
	 preceding_periods_amount,
	 succeeding_periods_amount,
	 has_child_element,
	 project_total) values
        (l_pd_project_id(z),
         l_pd_task_id(z),
         l_pd_resource_list_member_id(z),
	 l_pd_unit_of_measure(z),
         l_pd_element_name(z),
         l_pd_element_level(z),
         l_pd_line_editable_flag(z),
         l_pd_row_level(z),
         l_pd_parent_element_name(z),
         l_pd_amount_type(z),
         l_pd_amount_subtype(z),
         l_pd_amount_type_id(z),
         l_pd_amount_subtype_id(z),
         nvl(l_pd_period_1(z), 0),
         nvl(l_pd_period_2(z), 0),
         nvl(l_pd_period_3(z), 0),
         nvl(l_pd_period_4(z), 0),
         nvl(l_pd_period_5(z), 0),
         nvl(l_pd_period_6(z), 0),
         nvl(l_pd_period_7(z), 0),
         nvl(l_pd_period_8(z), 0),
         nvl(l_pd_period_9(z), 0),
         nvl(l_pd_period_10(z), 0),
         nvl(l_pd_period_11(z), 0),
         nvl(l_pd_period_12(z), 0),
         nvl(l_pd_period_13(z), 0),
	 -1,
	 l_pd_res_assignment_id(z),
	 -1,
	 l_pd_preceding(z),
	 l_pd_succeeding(z),
	 l_pd_has_child_element(z),
	 l_pd_project_total(z));

/* Added below code for 7514054 */

	/* Logic to rollp the Period amounts to the parent levels */

   for rollup_rec in rollup_period_amt_csr
   loop
		t_period_amount1 := null;
		t_period_amount2 := null;
		t_period_amount3 := null;
		t_period_amount4 := null;
		t_period_amount5 := null;
		t_period_amount6 := null;
		t_period_amount7 := null;
		t_period_amount8 := null;
		t_period_amount9 := null;
		t_period_amount10 := null;
		t_period_amount11 := null;
		t_period_amount12 := null;
		t_period_amount13 := null;

		select  period_amount1,
			period_amount2,
			period_amount3,
			period_amount4,
			period_amount5,
			period_amount6,
			period_amount7,
			period_amount8,
			period_amount9,
			period_amount10,
			period_amount11,
			period_amount12,
			period_amount13
		into
		    t_period_amount1,
			t_period_amount2,
			t_period_amount3,
			t_period_amount4,
			t_period_amount5,
			t_period_amount6,
			t_period_amount7,
			t_period_amount8,
			t_period_amount9,
			t_period_amount10,
			t_period_amount11,
			t_period_amount12,
			t_period_amount13
	from pa_fin_vp_pds_view_tmp
    where rowid = rollup_rec.rowid;

  if rollup_rec.element_name is not null then

    update pa_fin_vp_pds_view_tmp p
	set  p.period_amount1 = nvl(p.period_amount1, 0)+nvl(t_period_amount1,0),
         p.period_amount2 = nvl(p.period_amount2, 0)+nvl(t_period_amount2, 0),
         p.period_amount3 = nvl(p.period_amount3, 0)+nvl(t_period_amount3, 0),
         p.period_amount4 = nvl(p.period_amount4, 0)+nvl(t_period_amount4, 0),
         p.period_amount5 = nvl(p.period_amount5, 0)+nvl(t_period_amount5, 0),
         p.period_amount6 = nvl(p.period_amount6, 0)+nvl(t_period_amount6, 0),
         p.period_amount7 = nvl(p.period_amount7, 0)+nvl(t_period_amount7, 0),
         p.period_amount8 = nvl(p.period_amount8, 0)+nvl(t_period_amount8, 0),
         p.period_amount9 = nvl(p.period_amount9, 0)+nvl(t_period_amount9, 0),
         p.period_amount10 = nvl(p.period_amount10, 0)+nvl(t_period_amount10, 0),
         p.period_amount11 = nvl(p.period_amount11, 0)+nvl(t_period_amount11, 0),
         p.period_amount12 = nvl(p.period_amount12, 0)+nvl(t_period_amount12, 0),
         p.period_amount13 = nvl(p.period_amount13, 0)+nvl(t_period_amount13, 0)
	where p.row_level < rollup_rec.row_level
	  and p.amount_subtype = rollup_rec.amount_subtype
      and rollup_rec.element_name is not null
	    and p.element_name = rollup_rec.parent_element_name
		and p.element_name is not null;
   else
    update pa_fin_vp_pds_view_tmp p
	set  p.period_amount1 = nvl(p.period_amount1, 0)+nvl(t_period_amount1,0),
         p.period_amount2 = nvl(p.period_amount2, 0)+nvl(t_period_amount2, 0),
         p.period_amount3 = nvl(p.period_amount3, 0)+nvl(t_period_amount3, 0),
         p.period_amount4 = nvl(p.period_amount4, 0)+nvl(t_period_amount4, 0),
         p.period_amount5 = nvl(p.period_amount5, 0)+nvl(t_period_amount5, 0),
         p.period_amount6 = nvl(p.period_amount6, 0)+nvl(t_period_amount6, 0),
         p.period_amount7 = nvl(p.period_amount7, 0)+nvl(t_period_amount7, 0),
         p.period_amount8 = nvl(p.period_amount8, 0)+nvl(t_period_amount8, 0),
         p.period_amount9 = nvl(p.period_amount9, 0)+nvl(t_period_amount9, 0),
         p.period_amount10 = nvl(p.period_amount10, 0)+nvl(t_period_amount10, 0),
         p.period_amount11 = nvl(p.period_amount11, 0)+nvl(t_period_amount11, 0),
         p.period_amount12 = nvl(p.period_amount12, 0)+nvl(t_period_amount12, 0),
         p.period_amount13 = nvl(p.period_amount13, 0)+nvl(t_period_amount13, 0)
	where p.row_level < rollup_rec.row_level
	  and p.amount_subtype = rollup_rec.amount_subtype
      and rollup_rec.element_name is null
	    and p.element_name is null
		and (p.project_id,p.task_id, p.resource_list_member_id,row_level)
		in (select p1.project_id, p1.task_id, p1.resource_list_member_id, p1.row_level
		from pa_fin_vp_pds_view_tmp p1
		where p1.element_name = (select p2.parent_element_name from
               pa_fin_vp_pds_view_tmp p2
               where p2.row_level = rollup_rec.row_level
                 and p2.element_name is not null
                 and p2.project_id = rollup_rec.project_id
                 and p2.task_id = rollup_rec.task_id
                 and p2.resource_list_member_id = rollup_rec.resource_list_member_id
				 and rownum<2
               )
          );
	end if;
   end loop;

    /* Ends logic to rollup the period aounts to the parent levels */

/* Ends added for 7514054 */
 end if; -- pa_fp_view_plans_pub.G_AMT_OR_PD = 'P'
l_err_stage := 1100;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single', '900: pds temp table populated', 1);


  else
    pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single', '700: INVALID VALUE FOR p_cost_or_rev', 4);
    --hr_utility.trace('invalid value for p_cost_or_rev');
  end if;
  commit;
  pa_debug.write('pa_fp_view_plans_pub.pa_fp_vp_pop_tables_single', '1000: exiting procedure', 2);

EXCEPTION
when others then
      rollback to VIEW_PLANS_POP_TABLES_SINGLE;
--hr_utility.trace('l_err_stage= ' || to_char(l_err_stage));
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FP_VIEW_PLANS_PUB',
                               p_procedure_name   => 'View_Plans_Pop_Tables_Single');
      pa_debug.reset_err_stack;
      return;
end pa_fp_vp_pop_tables_single;


-- ============ FUNCTION has_child_rows ===============
-- HISTORY:
-- 20-Feb-2003 dlai    created: for Hgrid performance enhancement

FUNCTION has_child_rows
    (p_project_id               IN  pa_resource_assignments.project_id%TYPE,
     p_budget_version_id1	IN  pa_resource_assignments.budget_version_id%TYPE,
     p_budget_version_id2   IN  pa_resource_assignments.budget_version_id%TYPE,
     p_task_id                  IN  pa_resource_assignments.task_id%TYPE,
     p_resource_list_member_id  IN  pa_resource_assignments.resource_list_member_id%TYPE,
     p_amount_subtype_code	IN  pa_proj_periods_denorm.amount_subtype_code%TYPE,
     p_amt_or_periodic		IN  VARCHAR2) return VARCHAR2
IS

l_return_value   VARCHAR2(1);
l_res_parent_member_id  pa_resource_list_members.parent_member_id%TYPE;
l_resource_list_id      pa_resource_list_members.resource_list_id%TYPE;

cursor project_children_csr is
/* Bug 3106741 rewritten for performance improvement
  select ra.task_id -- doesn't matter what we select here
    from pa_resource_assignments ra,
	   pa_tasks t
    where (ra.budget_version_id in (p_budget_version_id1, p_budget_version_id2) and
	     ra.task_id=0 and
	     not (ra.resource_list_member_id in (0,pa_fp_view_plans_pub.Get_Uncat_Res_List_Member_Id))) or
          (ra.budget_version_id in (p_budget_version_id1, p_budget_version_id2) and
           ra.task_id <> 0 and
	     ra.task_id = t.task_id and
           t.parent_task_id is null);
*/
select 1 from dual where exists (
select  ra.task_id -- doesn't matter what we select here
  from  pa_resource_assignments ra
 where  ra.budget_version_id in (p_budget_version_id1, p_budget_version_id2)
   and  (
           ( ra.task_id=0
             and  not (ra.resource_list_member_id in (0,pa_fp_view_plans_pub.Get_Uncat_Res_List_Member_Id)))
         or
            (exists (select  1
                      from  pa_tasks pt
                     where  pt.task_id = pt.top_task_id
                       and  pt.task_id = ra.task_id))
          ));

project_children_rec project_children_csr%ROWTYPE;

cursor task_children_csr is
/* Bug 3106741 rewritten for performance improvement
  select ra.task_id
    from pa_resource_assignments ra,
         pa_tasks t
    where (ra.budget_version_id in(p_budget_version_id1, p_budget_version_id2) and
           ra.task_id=p_task_id and
           not (ra.resource_list_member_id in (0,pa_fp_view_plans_pub.Get_Uncat_Res_List_Member_Id))) or
          (ra.budget_version_id in (p_budget_version_id1, p_budget_version_id2) and
           ra.task_id = t.task_id and t.parent_task_id = p_task_id);
*/
select 1 from dual where exists (
select   ra.task_id
  from   pa_resource_assignments ra
  where  ra.budget_version_id in(p_budget_version_id1, p_budget_version_id2) and
         (
            (ra.task_id=p_task_id and
             not (ra.resource_list_member_id in
                     (0,pa_fp_view_plans_pub.Get_Uncat_Res_List_Member_Id)
                 )
             )
         or
            (exists (select 1
                     from   pa_tasks t
                     where  ra.task_id = t.task_id
                     and    t.parent_task_id = p_task_id)
            )
         ));

task_children_rec task_children_csr%ROWTYPE;

cursor rg_children_csr is
  select resource_list_member_id
    from pa_resource_list_members
    where parent_member_id = p_resource_list_member_id;
rg_children_rec rg_children_csr%ROWTYPE;

BEGIN
if (p_resource_list_member_id = pa_fp_view_plans_pub.Get_Uncat_Res_List_Member_Id and
    p_task_id = 0) or
   (p_resource_list_member_id = 0 and
    p_task_id = 0) then
  /* THIS IS A PROJECT-LEVEL ROW */
  /* to look for children of a PROJECT-LEVEL row, look for resources/resource groups AND
   * for tasks
   */
  open project_children_csr;
  fetch project_children_csr into project_children_rec;
  if project_children_csr%NOTFOUND then
    if p_amt_or_periodic = 'A' then
      l_return_value := 'N';
    else
      if p_amount_subtype_code = pa_fp_view_plans_pub.Get_Default_Amt_Subtype_Code then
	    l_return_value := 'Y';
	  else
	    l_return_value := 'N';
      end if;
    end if;
  else
    l_return_value := 'Y';
  end if;
  close project_children_csr;

elsif p_resource_list_member_id = 0 or
      p_resource_list_member_id = pa_fp_view_plans_pub.Get_Uncat_Res_List_Member_Id then
  /* THIS IS A TASK-LEVEL ROW */
  /* to look for children of a TASK-LEVEL row, look for resources/resource groups AND
   * for sub-tasks
   */
  open task_children_csr;
  fetch task_children_csr into task_children_rec;
  if task_children_csr%NOTFOUND then
    if p_amt_or_periodic = 'A' then
      l_return_value := 'N';
    else
      if p_amount_subtype_code = pa_fp_view_plans_pub.Get_Default_Amt_Subtype_Code then
	    l_return_value := 'Y';
	  else
	    l_return_value := 'N';
      end if;
    end if;
  else
    l_return_value := 'Y';
  end if;
  close task_children_csr;
else
  /* THIS IS EITHER A RESOURCE LIST OR A RESOURCE */
  select nvl(parent_member_id, -99),
         resource_list_id
    into l_res_parent_member_id,
         l_resource_list_id
    from pa_resource_list_members
    where resource_list_member_id = p_resource_list_member_id;
  if l_res_parent_member_id = -99 then
    /* THIS IS A RESOURCE LIST */
    open rg_children_csr;
    fetch rg_children_csr into rg_children_rec;
    if rg_children_csr%NOTFOUND then
      if p_amt_or_periodic = 'A' then
        l_return_value := 'N';
      else
        if p_amount_subtype_code = pa_fp_view_plans_pub.Get_Default_Amt_Subtype_Code then
	      l_return_value := 'Y';
	    else
	      l_return_value := 'N';
        end if;
      end if;
    else
      l_return_value := 'Y';
    end if;
    close rg_children_csr;
  else
    /* THIS IS A RESOURCE; IT COULD HAVE CHILDREN IF IN PERIODIC MODE */
    if p_amt_or_periodic = 'A' then
      l_return_value := 'N';
    else
      if p_amount_subtype_code = pa_fp_view_plans_pub.Get_Default_Amt_Subtype_Code then
	    l_return_value := 'Y';
	  else
	    l_return_value := 'N';
      end if;
    end if;
  end if;
end if;
return l_return_value;
END has_child_rows;


END pa_fp_view_plans_pub;

/
