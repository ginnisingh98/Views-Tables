--------------------------------------------------------
--  DDL for Package Body PA_FIN_PLAN_CREATE_VER_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FIN_PLAN_CREATE_VER_GLOBAL" as
/* $Header: PAFPCVGB.pls 120.2 2005/08/19 16:26:03 mwasowic noship $
   Start of Comments
   Package name     : PA_FIN_PLAN_CREATE_VER_GLOBAL
   Purpose          : API's for Org Forecast: Create Versions Page
   History          :
   NOTE             :
   End of Comments
*/
/*
G_PROJECT_ID		NUMBER;
G_FIN_PLAN_TYPE_ID	NUMBER;
G_BUDGET_VERSION_ID	NUMBER;
*/
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

function get_project_id return NUMBER is
  begin
    return G_PROJECT_ID;
  end get_project_id;

function get_fin_plan_type_id return NUMBER is
  begin
    return G_FIN_PLAN_TYPE_ID;
  end get_fin_plan_type_id;

function get_budget_version_id return NUMBER is
  begin
    return G_BUDGET_VERSION_ID;
  end get_budget_version_id;

function get_lookup_planning_level
  (p_planning_level_code  IN  pa_proj_fp_options.all_fin_plan_level_code%TYPE)
return VARCHAR2 is
  l_planning_level pa_lookups.meaning%type;
BEGIN
  select meaning
    into l_planning_level
    from pa_lookups
    where lookup_type = 'BUDGET ENTRY LEVEL' and
	  lookup_code = p_planning_level_code;
  return l_planning_level;
END get_lookup_planning_level;

function get_lookup_time_phase
  (p_time_phased_code  IN  pa_proj_fp_options.cost_time_phased_code%TYPE)
return VARCHAR2 is
  l_time_phase     pa_lookups.meaning%type;
BEGIN
  select meaning
    into l_time_phase
    from pa_lookups
    where lookup_type = 'BUDGET TIME PHASED TYPE' and
	  lookup_code = p_time_phased_code;
  return l_time_phase;
END get_lookup_time_phase;

function get_resource_list_name
  (p_resource_list_id  IN  pa_resource_lists.resource_list_id%TYPE)
return VARCHAR2 is
  l_resource_list_name   pa_resource_lists_tl.name%type;
BEGIN
  select name
    into l_resource_list_name
    from pa_resource_lists
    where resource_list_id = p_resource_list_id;
  return l_resource_list_name;
END get_resource_list_name;

/* ==============================================================
   9/11/02 ADDED FUNCTIONS TO RETRIEVE GL/PA START/END PERIOD
   NAMES FOR CREATE VERSION PAGE
   ============================================================== */
FUNCTION get_gl_current_start_period
  (p_project_id		IN	pa_proj_period_profiles.project_id%TYPE)
return VARCHAR2 is

cursor l_csr is
select period_name1
  from pa_proj_period_profiles
  where project_id = p_project_id and
	plan_period_type = 'GL' and
	current_flag = 'Y';
l_rec l_csr%ROWTYPE;
BEGIN
  open l_csr;
  fetch l_csr into l_rec;
  if l_csr%NOTFOUND then
    return null;
  else
    return l_rec.period_name1;
  end if;
  close l_csr;
END get_gl_current_start_period;


FUNCTION get_gl_current_end_period
  (p_project_id		IN	pa_proj_period_profiles.project_id%TYPE)
return VARCHAR2 is
cursor l_csr is
select profile_end_period_name
  from pa_proj_period_profiles
  where project_id = p_project_id and
	plan_period_type = 'GL' and
	current_flag = 'Y';
l_rec l_csr%ROWTYPE;
BEGIN
  open l_csr;
  fetch l_csr into l_rec;
  if l_csr%NOTFOUND then
    return null;
  else
    return l_rec.profile_end_period_name;
  end if;
  close l_csr;
END get_gl_current_end_period;


FUNCTION get_pa_current_start_period
  (p_project_id		IN	pa_proj_period_profiles.project_id%TYPE)
return VARCHAR2 is
cursor l_csr is
select period_name1
  from pa_proj_period_profiles
  where project_id = p_project_id and
	plan_period_type = 'PA' and
	current_flag = 'Y';
l_rec l_csr%ROWTYPE;
BEGIN
  open l_csr;
  fetch l_csr into l_rec;
  if l_csr%NOTFOUND then
    return null;
  else
    return l_rec.period_name1;
  end if;
  close l_csr;
END get_pa_current_start_period;


FUNCTION get_pa_current_end_period
  (p_project_id		IN	pa_proj_period_profiles.project_id%TYPE)
return VARCHAR2 is
cursor l_csr is
select profile_end_period_name
  from pa_proj_period_profiles
  where project_id = p_project_id and
	plan_period_type = 'PA' and
	current_flag = 'Y';
l_rec l_csr%ROWTYPE;
BEGIN
  open l_csr;
  fetch l_csr into l_rec;
  if l_csr%NOTFOUND then
    return null;
  else
    return l_rec.profile_end_period_name;
  end if;
  close l_csr;
END get_pa_current_end_period;



procedure set_project_id
  (p_project_id		IN	pa_budget_versions.project_id%TYPE,
   x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data		OUT	NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
  BEGIN
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
    G_PROJECT_ID := p_project_id;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_CREATE_VER_GLOBAL',
                               p_procedure_name   => 'set_project_id');
  end set_project_id;

procedure set_fin_plan_type_id
  (p_fin_plan_type_id	IN	pa_budget_versions.fin_plan_type_id%TYPE,
   x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data		OUT	NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
  BEGIN
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
    G_FIN_PLAN_TYPE_ID := p_fin_plan_type_id;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_CREATE_VER_GLOBAL',
                               p_procedure_name   => 'set_fin_plan_type_id');
  end set_fin_plan_type_id;

procedure set_budget_version_id
  (p_budget_version_id	IN	pa_budget_versions.budget_version_id%TYPE,
   x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data		OUT	NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
  BEGIN
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
    G_BUDGET_VERSION_ID := p_budget_version_id;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_CREATE_VER_GLOBAL',
                               p_procedure_name   => 'set_budget_version_id');
  end set_budget_version_id;

procedure set_global_values
  (p_project_id		IN	pa_budget_versions.project_id%TYPE,
   p_fin_plan_type_id	IN	pa_budget_versions.fin_plan_type_id%TYPE,
   p_budget_version_id	IN	pa_budget_versions.budget_version_id%TYPE,
   p_user_id              IN  NUMBER,
   x_locked_by_user_flag  OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data		OUT	NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
l_return_status		VARCHAR2(1);
l_msg_count		NUMBER(15);
l_msg_data		VARCHAR2(2000);
l_locked_by_person_id	pa_budget_versions.locked_by_person_id%TYPE;

  BEGIN
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('pa_fin_plan_create_ver_global.set_global_values');
    END IF;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
    G_PROJECT_ID := p_project_id;
    G_FIN_PLAN_TYPE_ID := p_fin_plan_type_id;
    G_BUDGET_VERSION_ID := p_budget_version_id;

    -- bug 2961541: x_locked_by_user_flag
    pa_fin_plan_utils.Check_Locked_By_User
        (p_user_id              => p_user_id,
         p_budget_version_id    => p_budget_version_id,
         x_is_locked_by_userid  => x_locked_by_user_flag,
         x_locked_by_person_id  => l_locked_by_person_id,
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data);
    if l_locked_by_person_id is null then
      x_locked_by_user_flag := 'Y';  -- unlocked is equivalent to locked by user
    end if;
    pa_debug.reset_err_stack;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_CREATE_VER_GLOBAL',
                               p_procedure_name   => 'set_global_values');
  end set_global_values;

procedure get_start_end_period
  (x_period_start_date	OUT	NOCOPY pa_proj_fp_options.fin_plan_start_date%TYPE, --File.Sql.39 bug 4440895
   x_period_end_date	OUT	NOCOPY pa_proj_fp_options.fin_plan_end_date%TYPE, --File.Sql.39 bug 4440895
   x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data		OUT	NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
  l_org_fcst_period_type  pa_forecasting_options_all.org_fcst_period_type%TYPE;
  l_period_set_name       pa_implementations_all.period_set_name%TYPE;
  l_act_period_type       gl_periods.period_type%TYPE;
  l_org_projfunc_currency_code	gl_sets_of_books.currency_code%TYPE;
  l_number_of_periods     pa_forecasting_options_all.number_of_periods%TYPE;
  l_org_time_phased_code   pa_proj_fp_options.all_time_phased_code%TYPE;
  l_weighted_or_full_code pa_forecasting_options_all.weighted_or_full_code%TYPE;
  l_org_project_template_id   pa_forecasting_options_all.org_fcst_project_template_id%TYPE;
  l_org_structure_version_id pa_implementations_all.org_structure_version_id%TYPE;
  l_fcst_start_date       pa_proj_fp_options.fin_plan_start_date%TYPE;
  l_fcst_end_date         pa_proj_fp_options.fin_plan_end_date%TYPE;
  l_org_id                pa_forecasting_options_all.org_id%TYPE;
  l_return_status   VARCHAR2(2000);
  l_error_msg_code  VARCHAR2(30);

  BEGIN
    pa_fp_org_fcst_utils.get_forecast_option_details
           (x_fcst_period_type      => l_org_fcst_period_type,
            x_period_set_name       => l_period_set_name,
            x_act_period_type       => l_act_period_type,
	    x_org_projfunc_currency_code  =>  l_org_projfunc_currency_code,
            x_number_of_periods     => l_number_of_periods,
            x_weighted_or_full_code => l_weighted_or_full_code,
            x_org_proj_template_id  => l_org_project_template_id,
            x_org_structure_version_id => l_org_structure_version_id,
            x_fcst_start_date       => l_fcst_start_date,
            x_fcst_end_date         => l_fcst_end_date,
            x_org_id                => l_org_id,
            x_return_status         => l_return_status,
            x_err_code              => l_error_msg_code);
    if l_return_status=FND_API.G_RET_STS_SUCCESS then
      x_period_start_date := l_fcst_start_date;
      x_period_end_date := l_fcst_end_date;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    end if;
  END get_start_end_period;

/* ========================================================
   HISTORY:
   8/21/02 -- added nvl to org_project_flag query: null --> 'N'
   8/22/02 -- added x_fin_plan_pref_code
   9/16/03 -- modified logic for x_plan_class_code: possible values:
              FORECAST, APPROVED_BUDGET, NON_APPROVED_BUDGET
   5/25/05 -- added x_approved_budget_flag param
   ======================================================== */
procedure Create_Versions_Init
	(p_project_id		IN	pa_projects_all.project_id%TYPE,
	 p_fin_plan_type_id	IN	pa_fin_plan_types_b.fin_plan_type_id%TYPE,
	 x_org_project_flag	OUT	NOCOPY pa_project_types_all.org_project_flag%TYPE, --File.Sql.39 bug 4440895
	 x_proj_fp_options_id	OUT	NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
	 x_fin_plan_type_code	OUT	NOCOPY pa_fin_plan_types_b.fin_plan_type_code%TYPE, --File.Sql.39 bug 4440895
	 x_plan_class_code	OUT	NOCOPY pa_fin_plan_types_b.plan_class_code%TYPE, --File.Sql.39 bug 4440895
	 x_approved_budget_flag	OUT	NOCOPY pa_proj_fp_options.approved_cost_plan_type_flag%TYPE, --File.Sql.39 bug 4440895
	 x_fin_plan_pref_code	OUT	NOCOPY pa_proj_fp_options.fin_plan_preference_code%TYPE, --File.Sql.39 bug 4440895
	 x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	 x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
	 x_msg_data		OUT	NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

  l_org_project_flag	pa_project_types_all.org_project_flag%TYPE;
  l_proj_fp_options_id	pa_proj_fp_options.proj_fp_options_id%TYPE;
  l_fin_plan_type_code	pa_fin_plan_types_b.fin_plan_type_code%TYPE;
  l_plan_class_code	pa_fin_plan_types_b.plan_class_code%TYPE;
  l_fin_plan_pref_code	pa_proj_fp_options.fin_plan_preference_code%TYPE;
  l_approved_budget_flag pa_proj_fp_options.approved_cost_plan_type_flag%TYPE;

  l_msg_count		NUMBER := 0;
  l_msg_data		VARCHAR2(2000);
  l_data		VARCHAR2(2000);
  l_msg_index_out	NUMBER;

  begin
	IF P_PA_DEBUG_MODE = 'Y' THEN
	   pa_debug.init_err_stack('pa_fin_plan_create_ver_global.Create_Versions_Init');
	END IF;
	x_msg_count := 0;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	select
	  nvl(pt.org_project_flag, 'N')
	into
	  l_org_project_flag
	from
	  pa_projects_all p,
	  pa_project_types_all pt
	where
	  p.project_id=p_project_id and
	  p.project_type=pt.project_type and
	  p.org_id = pt.org_id; -- R12 MOAC 4447573: nvl(p.org_id,-99) = nvl(pt.org_id, -99)

	select fin_plan_type_code,
	       plan_class_code
	into l_fin_plan_type_code,
	     l_plan_class_code
	from pa_fin_plan_types_b
	where fin_plan_type_id = p_fin_plan_type_id;

	select proj_fp_options_id,
	       fin_plan_preference_code,
	       DECODE(fin_plan_preference_code,
		      'COST_ONLY', nvl(approved_cost_plan_type_flag, 'N'),
		      'REVENUE_ONLY', nvl(approved_rev_plan_type_flag, 'N'),
		      DECODE(approved_cost_plan_type_flag,
			     'Y', 'Y',
			     nvl(approved_rev_plan_type_flag, 'N')))
	into l_proj_fp_options_id,
	     l_fin_plan_pref_code,
             l_approved_budget_flag
	from pa_proj_fp_options
	where project_id = p_project_id and
	      fin_plan_type_id = p_fin_plan_type_id and
	      fin_plan_option_level_code = 'PLAN_TYPE';

	x_org_project_flag := l_org_project_flag;
	x_fin_plan_type_code := l_fin_plan_type_code;
	x_proj_fp_options_id := l_proj_fp_options_id;
        x_approved_budget_flag := l_approved_budget_flag;
  /* BUG FIX 3144444: new logic for x_plan_class_code for Plan Class Security:
                      possible values: FORECAST, APPROVED_BUDGET, NON_APPROVED_BUDGET
  */
	--x_plan_class_code := l_plan_class_code;
        x_plan_class_code := pa_fin_plan_type_global.plantype_to_planclass
				(p_project_id, p_fin_plan_type_id);
	x_fin_plan_pref_code := l_fin_plan_pref_code;

	G_PROJECT_ID := p_project_id;
	G_FIN_PLAN_TYPE_ID := p_fin_plan_type_id;
	pa_debug.reset_err_stack;

  exception
    when others then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg(p_pkg_name         => 'pa_fin_plan_create_ver_global',
                                p_procedure_name   => 'Create_Versions_Init');
  end Create_Versions_Init;



END pa_fin_plan_create_ver_global;

/
