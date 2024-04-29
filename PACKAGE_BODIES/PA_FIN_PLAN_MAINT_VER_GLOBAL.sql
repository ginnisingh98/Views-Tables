--------------------------------------------------------
--  DDL for Package Body PA_FIN_PLAN_MAINT_VER_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FIN_PLAN_MAINT_VER_GLOBAL" as
/* $Header: PAFPMVGB.pls 120.4.12010000.3 2009/06/25 11:02:08 rthumma ship $
   Start of Comments
   Package name     : PA_FIN_PLAN_MAINT_VER_GLOBAL
   Purpose          : API's for Org Forecast: Maintain Versions Page
   History          :
   NOTE             :
   End of Comments
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

function get_login_person_id return NUMBER is
  begin
    return G_LOGIN_PERSON_ID;
  end get_login_person_id;

 /* Added for bug 5629469 */
 	 /*this function returns the security available to the user for submit/rework/baseline a version*/
 	 function get_fin_plan_security(SecurityType IN VARCHAR2) return VARCHAR2 is
 	   begin
 	     IF(SecurityType = 'Submit') THEN return G_SECURITY_S;
 	      ELSIF(SecurityType = 'Rework') THEN return G_SECURITY_R;
 	       ELSIF(SecurityType = 'Baseline') THEN return G_SECURITY_B;
 	     END IF;
 	   end get_fin_plan_security;



 /* ---------------------------------------------------------------- */	 /* ---------------------------------------------------------------- */

 	 /* Added for bug 5629469 */
 	 /*this procedure sets the security available to the user for submit/rework/baseline a version*/
 	 procedure set_global_finplan_security
 	          ( paFinplanSecType  IN  VARCHAR2,
 	            paFinplanSec      IN  VARCHAR2 := NULL,
 	            x_return_status   OUT NOCOPY VARCHAR2,
 	            x_msg_count       OUT NOCOPY  NUMBER,
 	            x_msg_data        OUT NOCOPY VARCHAR2 ) IS
 	 begin
 	    x_msg_count := 0;
 	    x_return_status := FND_API.G_RET_STS_SUCCESS;

 	    IF(paFinplanSecType = 'Submit') THEN pa_fin_plan_maint_ver_global.G_SECURITY_S := paFinplanSec;
 	      ELSIF(paFinplanSecType = 'Rework') THEN pa_fin_plan_maint_ver_global.G_SECURITY_R := paFinplanSec;
 	       ELSIF(paFinplanSecType = 'Baseline') THEN pa_fin_plan_maint_ver_global.G_SECURITY_B := paFinplanSec;
 	     END IF;


 	    exception
 	         when others then
 	             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 	             x_msg_count     := 1;
 	             x_msg_data      := SQLERRM;
 	             FND_MSG_PUB.add_exc_msg(p_pkg_name         => 'PA_FIN_PLAN_MAIN_VER_GLOBAL',
 	                                 p_procedure_name   => 'set_global_finplan_security');

 	 end set_global_finplan_security;


procedure set_global_values
	(p_project_id		IN	pa_projects_all.project_id%TYPE,
	 p_fin_plan_type_id	IN	pa_fin_plan_types_b.fin_plan_type_id%TYPE,
	 p_user_id		IN	VARCHAR2,
	 x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	 x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
	 x_msg_data		OUT	NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

l_person_id	VARCHAR2(80);
l_resource_id	VARCHAR2(80);
l_resource_name VARCHAR(240); /* Added this line for bug 3456811 */
  begin
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_fin_plan_maint_ver_global.G_PROJECT_ID := p_project_id;
    pa_fin_plan_maint_ver_global.G_FIN_PLAN_TYPE_ID := p_fin_plan_type_id;

    PA_COMP_PROFILE_PUB.GET_USER_INFO
	(p_user_id         => p_user_id,
         x_person_id       => l_person_id,
         x_resource_id     => l_resource_id, /* Added the ending comma for bug 3456811 */
         x_resource_name   => l_resource_name );/* Added this line for bug 3456811 */

    pa_fin_plan_maint_ver_global.G_LOGIN_PERSON_ID := l_person_id;

    exception
        when others then
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count     := 1;
            x_msg_data      := SQLERRM;
            FND_MSG_PUB.add_exc_msg(p_pkg_name         => 'PA_FIN_PLAN_MAIN_VER_GLOBAL',
                                p_procedure_name   => 'set_global_values');
  end set_global_values;
/* ---------------------------------------------------------------- */

-- HISTORY
-- 11/15/2002 - bug fix 2668857: when querying pa_project_types_all, need
--		to also use org_id to avoid returning multiple rows
procedure Maintain_Versions_Init
	(p_project_id		IN	pa_projects_all.project_id%TYPE,
	 p_fin_plan_options_id	IN	pa_proj_fp_options.proj_fp_options_id%TYPE,
	 p_fin_plan_type_id	IN	pa_fin_plan_types_b.fin_plan_type_id%TYPE,
	 x_fin_plan_type_name	OUT	NOCOPY pa_fin_plan_types_tl.name%TYPE, --File.Sql.39 bug 4440895
	 x_fin_plan_pref_code	OUT	NOCOPY pa_proj_fp_options.fin_plan_preference_code%TYPE, --File.Sql.39 bug 4440895
	 x_org_project_flag	OUT	NOCOPY pa_project_types_all.org_project_flag%TYPE, --File.Sql.39 bug 4440895
	 x_currency_code	OUT	NOCOPY pa_projects_all.projfunc_currency_code%TYPE,	 --File.Sql.39 bug 4440895
	 x_proj_currency_code	OUT	NOCOPY pa_projects_all.project_currency_code%TYPE, --File.Sql.39 bug 4440895
	 x_fin_plan_type_code	OUT	NOCOPY pa_fin_plan_types_b.fin_plan_type_code%TYPE, --File.Sql.39 bug 4440895
	 x_fin_plan_class_code	OUT	NOCOPY pa_fin_plan_types_b.plan_class_code%TYPE, --File.Sql.39 bug 4440895
	 x_derive_margin_from_code OUT  NOCOPY pa_proj_fp_options.margin_derived_from_code%TYPE, --File.Sql.39 bug 4440895
	 x_report_labor_hrs_code OUT  NOCOPY pa_proj_fp_options.report_labor_hrs_from_code%TYPE, --File.Sql.39 bug 4440895
	 x_auto_baseline_flag	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	 x_ar_flag		OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	 x_plan_type_processing_code OUT NOCOPY pa_proj_fp_options.plan_processing_code%TYPE, --File.Sql.39 bug 4440895
         x_navg_inc_co_code OUT    NOCOPY VARCHAR2,--Bug 5845142
	 x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	 x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
	 x_msg_data		OUT	NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

l_fin_plan_type_name	pa_fin_plan_types_tl.name%TYPE;
l_fin_plan_type_code	pa_fin_plan_types_b.fin_plan_type_code%TYPE;
l_plan_class_code	pa_fin_plan_types_b.plan_class_code%TYPE;
l_fin_plan_pref_code	pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_report_labor_hrs_from_code pa_proj_fp_options.report_labor_hrs_from_code%TYPE;
l_derive_margin_from_code pa_proj_fp_options.margin_derived_from_code%TYPE;
l_org_project_flag	pa_project_types_all.org_project_flag%TYPE;
l_currency_code		pa_projects_all.projfunc_currency_code%TYPE;
l_proj_currency_code	pa_projects_all.project_currency_code%TYPE;

l_msg_count		NUMBER := 0;
l_msg_data		VARCHAR2(2000);
l_data			VARCHAR2(2000);
l_msg_index_out		NUMBER;

cursor wbs_errored_versions_csr is
select budget_version_id
  from pa_budget_versions
  where project_id = p_project_id and
	fin_plan_type_id = p_fin_plan_type_id and
	plan_processing_code = 'WUE' and
	process_update_wbs_flag = 'Y';
wbs_errored_versions_rec wbs_errored_versions_csr%ROWTYPE;

begin
	IF P_PA_DEBUG_MODE = 'Y' THEN
	   pa_debug.init_err_stack('pa_fin_plan_maint_ver_global.Maintain_Versions_Init');
	END IF;
	x_msg_count := 0;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- get AUTO BASELINED FLAG
  x_auto_baseline_flag :=
	Pa_Fp_Control_Items_Utils.IsFpAutoBaselineEnabled(p_project_id);

  -- bug 2768332: get APPROVED REVENUE FLAG
	select
	  fin_plan_preference_code,
	  margin_derived_from_code,
	  report_labor_hrs_from_code,
	  nvl(approved_rev_plan_type_flag, 'N')
	into
	  l_fin_plan_pref_code,
	  l_derive_margin_from_code,
	  l_report_labor_hrs_from_code,
	  x_ar_flag
	from
	  pa_proj_fp_options
	where
	  proj_fp_options_id=p_fin_plan_options_id;
	if (l_fin_plan_pref_code is null) then
		l_msg_count := l_msg_count + 1;
		x_return_status := FND_API.G_RET_STS_ERROR;
	else
		x_fin_plan_pref_code := l_fin_plan_pref_code;
		x_derive_margin_from_code := l_derive_margin_from_code;
		x_report_labor_hrs_code := l_report_labor_hrs_from_code;
	end if;

	-- populate x_plan_type_processing_code;
	open wbs_errored_versions_csr;
	fetch wbs_errored_versions_csr into wbs_errored_versions_rec;
	if wbs_errored_versions_csr%ROWCOUNT > 0 then
	  x_plan_type_processing_code := 'WUE'; -- simulate error
	else
	  x_plan_type_processing_code := 'WUS';
	end if;
	close wbs_errored_versions_csr;

	select
	  p.projfunc_currency_code,
	  p.project_currency_code,
	  NVL(pt.org_project_flag, 'N')
	into
	  l_currency_code,
	  l_proj_currency_code,
	  l_org_project_flag
	from
	  pa_projects_all p,
	  pa_project_types_all pt
	where
	  p.project_id=p_project_id and
	  p.project_type=pt.project_type and
	  p.org_id = pt.org_id; -- R12 MOAC 4447573: nvl(p.org_id, -99) = nvl(pt.org_id, -99)

	if (l_currency_code is null) or (l_proj_currency_code is null) then
		l_msg_count := l_msg_count + 1;
		x_return_status := FND_API.G_RET_STS_ERROR;
	else
		x_currency_code := l_currency_code;
		x_proj_currency_code := l_proj_currency_code;
	end if;
	x_org_project_flag := l_org_project_flag;

	select
	  name
	into
	  l_fin_plan_type_name
	from
	  pa_fin_plan_types_tl
	where
	  fin_plan_type_id = p_fin_plan_type_id
          and language = USERENV('LANG');

	if (l_fin_plan_type_name is null) then
		l_msg_count := l_msg_count +1;
		x_return_status := FND_API.G_RET_STS_ERROR;
	else
		x_fin_plan_type_name := l_fin_plan_type_name;
	end if;

  /* ================================================
     Code added to select plan_type_code so that Maintain
     Versions page can distinguish between ORG_FORECAST and
     non-ORG_FORECAST.
     Code added to select plan_class_code so that Maintain
     Versions page can set "Return to" link appropriately
     ================================================ */
        select fin_plan_type_code,
	       plan_class_code
          into l_fin_plan_type_code,
	       l_plan_class_code
          from pa_fin_plan_types_b
          where fin_plan_type_id = p_fin_plan_type_id;

        x_fin_plan_type_code := l_fin_plan_type_code;
	-- x_fin_plan_class_code := l_plan_class_code;
	x_fin_plan_class_code :=
	   pa_fin_plan_type_global.plantype_to_planclass
		(p_project_id, p_fin_plan_type_id);
    -- Bug 5845142. Please refer to the bug for more details
    x_navg_inc_co_code:='NONE';
    IF Pa_Fp_Control_Items_Utils.check_valid_combo
       ( p_project_id         => p_project_id
        ,p_targ_app_cost_flag => 'N'
        ,p_targ_app_rev_flag  => 'N') = 'N' THEN

        x_navg_inc_co_code:='PA_FP_CANT_INCL_CO_UANPP_AMT';

    END IF;
    if l_msg_count > 0 then
	x_msg_count := 1;
	x_msg_data := SQLERRM;
        pa_debug.reset_err_stack;
	return;
    end if;

pa_debug.reset_err_stack;

exception
    when others then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg(p_pkg_name         => 'pa_fin_plan_maint_ver_global',
                                p_procedure_name   => 'Maintain_Versions_Init');
	raise FND_API.G_EXC_UNEXPECTED_ERROR;
end Maintain_Versions_Init;


procedure Create_Working_Copy
    (p_project_id               IN      pa_budget_versions.project_id%TYPE,
     p_source_version_id        IN      pa_budget_versions.budget_version_id%TYPE,
     p_copy_mode                IN      VARCHAR2,
     p_adj_percentage           IN      NUMBER DEFAULT 0,
     p_calling_module           IN      VARCHAR2 DEFAULT PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST,
     px_target_version_id       IN  OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                     OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

l_version_name		VARCHAR2(80);

-- error-handling variables
l_return_status		VARCHAR2(1);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(1000);
l_msg_index_out		NUMBER;

BEGIN
  SAVEPOINT create_working_copy;
  pa_fin_plan_pub.Copy_Version
	(p_project_id 		=> p_project_id,
         p_source_version_id	=> p_source_version_id,
         p_copy_mode 		=> p_copy_mode,
         p_calling_module 	=> p_calling_module,
         px_target_version_id 	=> px_target_version_id,
         x_return_status 	=> l_return_status,
         x_msg_count 		=> l_msg_count,
         x_msg_data		=> l_msg_data);
  if l_return_status = FND_API.G_RET_STS_SUCCESS then
    -- prepend 'Copy: ' to version name
    select version_name
      into l_version_name
      from pa_budget_versions
      where budget_version_id = px_target_version_id;
    FND_MESSAGE.SET_NAME('PA','PA_FP_COPY_MESSAGE');
    l_version_name:= FND_MESSAGE.GET || ': ' || l_version_name;
    -- bug 3139862 the maximum value version_name column can hold is 60 characters
    -- It could be that after appending "copy: " the version name exceeds 60 char
    -- So, the version_name should be truncated
    l_version_name := substr(l_version_name, 1, 60);
    update pa_budget_versions
      set version_name = l_version_name
      where budget_version_id = px_target_version_id;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  else
    rollback to create_working_copy;
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
  end if; -- status=SUCCESS
exception
    when others then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg(p_pkg_name         => 'pa_fin_plan_maint_ver_global',
                                p_procedure_name   => 'Create_Working_Copy');
	raise FND_API.G_EXC_UNEXPECTED_ERROR;
END Create_Working_Copy;


PROCEDURE Resubmit_Concurrent_Process
    (p_project_id		IN	pa_projects_all.project_id%TYPE,
     x_return_status                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
l_structure_version_id	NUMBER;

-- error-handling variables
l_return_status		VARCHAR2(1);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(1000);
l_msg_index_out		NUMBER;

BEGIN
    IF P_PA_DEBUG_MODE = 'Y' THEN
	pa_debug.init_err_stack('pa_fin_plan_maint_ver_global.Maintain_Versions_Init');
    END IF;
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- retrieve l_structure_version_id
    l_structure_version_id :=
	PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(p_project_id);
    PA_PROJ_TASK_STRUC_PUB.PROCESS_WBS_UPDATES_WRP
	(p_project_id		=> p_project_id,
	 p_structure_version_id => l_structure_version_id,
	 x_return_status	=> l_return_status,
	 x_msg_count		=> l_msg_count,
	 x_msg_data		=> l_msg_data);
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
    end if;
    return;
exception
    when others then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg(p_pkg_name         => 'pa_fin_plan_maint_ver_global',
                                p_procedure_name   => 'Resubmit_Concurrent_Process');
	raise FND_API.G_EXC_UNEXPECTED_ERROR;
END Resubmit_Concurrent_Process;

END pa_fin_plan_maint_ver_global;

/
