--------------------------------------------------------
--  DDL for Package Body PA_FIN_PLAN_TYPE_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FIN_PLAN_TYPE_GLOBAL" as
/* $Header: PAFPPTGB.pls 120.1 2005/08/19 16:28:30 mwasowic noship $
   Start of Comments
   Package name     : PA_FIN_PLAN_TYPE_GLOBAL
   Purpose          : API's for Org Forecast: PLANS Page
   History          :
   NOTE             :
   End of Comments
*/

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

function Get_Project_Id return NUMBER is
BEGIN
  return pa_fin_plan_type_global.G_PROJECT_ID;
END Get_Project_Id;

/*
function Get_Plan_Class_Code return VARCHAR2 is
BEGIN
  return pa_fin_plan_type_global.G_PLAN_CLASS_CODE;
END Get_Plan_Class_Code;
*/

PROCEDURE set_global_variables
    (p_project_id      IN   pa_budget_versions.project_id%TYPE,
     -- p_plan_class_code IN    pa_fin_plan_types_b.plan_class_code%TYPE,
     x_factor_by_code  OUT  NOCOPY pa_proj_fp_options.factor_by_code%TYPE, --File.Sql.39 bug 4440895
     x_return_status   OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count       OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data    OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
BEGIN
  x_return_status    := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  pa_fin_plan_type_global.G_PROJECT_ID := p_project_id;
  -- pa_fin_plan_type_global.G_PLAN_CLASS_CODE := p_plan_class_code;
  -- *** bug fix 2770782: retrieve x_budget_status code from project-level row ***
  select nvl(po.factor_by_code, 1)
    into x_factor_by_code
    from pa_proj_fp_options po
    where po.project_id = p_project_id and
          po.fin_plan_option_level_code = 'PROJECT';

EXCEPTION WHEN NO_DATA_FOUND THEN
               x_factor_by_code := 1;
          WHEN OTHERS THEN
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 x_msg_count     := 1;
                 x_msg_data      := SQLERRM;
                 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_TYPE_GLOBAL',
                                          p_procedure_name   => 'set_global_variables');
END set_global_variables;

PROCEDURE pa_fp_get_orgfcst_version_id( p_project_id          IN   NUMBER,
                                        p_plan_type_id        IN   NUMBER,
                                    p_plan_status_code    IN   VARCHAR2,
                                    x_orgfcst_version_id  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   )
IS
cursor cb_csr is
 select budget_version_id
   from   pa_budget_versions
   where  project_id = p_project_id and
          fin_plan_type_id = p_plan_type_id and
          version_type = 'ORG_FORECAST' and
          current_flag = 'Y';
cb_rec cb_csr%ROWTYPE;

cursor cw_csr is
 select budget_version_id
   from   pa_budget_versions
   where  project_id = p_project_id and
          fin_plan_type_id = p_plan_type_id and
          version_type = 'ORG_FORECAST' and
          current_working_flag = 'Y';
cw_rec cw_csr%ROWTYPE;

BEGIN
x_return_status    := FND_API.G_RET_STS_SUCCESS;
IF p_plan_status_code = 'CB' THEN
  open cb_csr;
  fetch cb_csr into cb_rec;
  if cb_csr%NOTFOUND then
	x_orgfcst_version_id := -1;
  else
	x_orgfcst_version_id := cb_rec.budget_version_id;
  end if;
  close cb_csr;
ELSE
  open cw_csr;
  fetch cw_csr into cw_rec;
  if cw_csr%NOTFOUND then
	x_orgfcst_version_id := -1;
  else
	x_orgfcst_version_id := cw_rec.budget_version_id;
  end if;
  close cw_csr;
END IF;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_TYPE_GLOBAL',
                               p_procedure_name   => 'pa_fp_get_orgfcst_version_id');
END pa_fp_get_orgfcst_version_id;
/* ------------------------------------------------------------------- */

PROCEDURE pa_fp_get_finplan_version_id
    (p_project_id          IN   NUMBER,
     p_plan_type_id        IN   NUMBER,
     p_plan_status_code    IN   VARCHAR2,
     x_cost_version_id     OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_rev_version_id      OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data            OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is

-- we will get only one version per cursor
cursor working_cost_csr is
    select budget_version_id
      from pa_budget_versions
      where project_id = p_project_id and
            fin_plan_type_id = p_plan_type_id and
            version_type in ('COST', 'ALL') and
            current_working_flag = 'Y';
working_cost_rec working_cost_csr%ROWTYPE;

cursor working_revenue_csr is
    select budget_version_id
      from pa_budget_versions
      where project_id = p_project_id and
            fin_plan_type_id = p_plan_type_id and
            version_type in ('REVENUE', 'ALL') and
            current_working_flag = 'Y';
working_revenue_rec working_revenue_csr%ROWTYPE;

cursor baselined_cost_csr is
    select budget_version_id
      from pa_budget_versions
      where project_id = p_project_id and
            fin_plan_type_id = p_plan_type_id and
            version_type in ('COST', 'ALL') and
            current_flag = 'Y';
baselined_cost_rec baselined_cost_csr%ROWTYPE;

cursor baselined_revenue_csr is
    select budget_version_id
      from pa_budget_versions
      where project_id = p_project_id and
            fin_plan_type_id = p_plan_type_id and
            version_type in ('REVENUE', 'ALL') and
            current_flag = 'Y';
baselined_revenue_rec baselined_revenue_csr%ROWTYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  -- looking for the current baselined cost/revenue versions
  if p_plan_status_code = 'CB' then
    open baselined_cost_csr;
    fetch baselined_cost_csr into baselined_cost_rec;
    if baselined_cost_csr%NOTFOUND then
      x_cost_version_id := -1;
    else
      x_cost_version_id := baselined_cost_rec.budget_version_id;
    end if; -- baselined_cost_csr%NOTFOUND
    close baselined_cost_csr;
    open baselined_revenue_csr;
    fetch baselined_revenue_csr into baselined_revenue_rec;
    if baselined_revenue_csr%NOTFOUND then
      x_rev_version_id := -1;
    else
      x_rev_version_id := baselined_revenue_rec.budget_version_id;
    end if;  -- baselined_revenue_csr%NOTFOUND
    close baselined_revenue_csr;
  -- looking for the current working cost/revenue versions
  else
    open working_cost_csr;
    fetch working_cost_csr into working_cost_rec;
    if working_cost_csr%NOTFOUND then
      x_cost_version_id := -1;
    else
      x_cost_version_id := working_cost_rec.budget_version_id;
    end if; -- working_cost_csr%NOTFOUND
    close working_cost_csr;
    open working_revenue_csr;
    fetch working_revenue_csr into working_revenue_rec;
    if working_revenue_csr%NOTFOUND then
      x_rev_version_id := -1;
    else
      x_rev_version_id := working_revenue_rec.budget_version_id;
    end if; -- working_revenue_csr%NOTFOUND
    close working_revenue_csr;
  end if;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_TYPE_GLOBAL',
                               p_procedure_name   => 'pa_fp_get_finplan_version_id');

END pa_fp_get_finplan_version_id;
/* ------------------------------------------------------------------- */

PROCEDURE delete_plan_type_from_project
    (p_project_id        IN  pa_budget_versions.project_id%TYPE,
     p_fin_plan_type_id  IN  pa_budget_versions.fin_plan_type_id%TYPE,
     x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data          OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is

cursor plan_type_versions_csr is
select budget_version_id
  from pa_budget_versions
  where project_id = p_project_id and
        fin_plan_type_id = p_fin_plan_type_id;
plan_type_versions_rec plan_type_versions_csr%ROWTYPE;

cursor plan_type_code_csr is
select fin_plan_type_code
  from pa_fin_plan_types_b
  where fin_plan_type_id = p_fin_plan_type_id;
plan_type_code_rec plan_type_code_csr%ROWTYPE;

-- Bug 3619687 Cursor to return all the fp options that need to be
-- updated up on delete
CURSOR  fp_options_cur(c_project_id NUMBER, c_fin_plan_type_id NUMBER) IS
SELECT   gen_src_cost_plan_type_id
       , gen_src_cost_plan_version_id
       , gen_src_cost_plan_ver_code
       , gen_src_rev_plan_type_id
       , gen_src_rev_plan_version_id
       , gen_src_rev_plan_ver_code
       , gen_src_all_plan_type_id
       , gen_src_all_plan_version_id
       , gen_src_all_plan_ver_code
       , fin_plan_option_level_code
       , proj_fp_options_id
FROM   pa_proj_fp_options
WHERE  project_id = c_project_id
AND    fin_plan_type_id IS NOT NULL -- eliminates project level record
AND    fin_plan_type_id <> c_fin_plan_type_id -- eliminates plan type being deleted
AND    (gen_src_cost_plan_type_id = c_fin_plan_type_id OR
        gen_src_rev_plan_type_id  = c_fin_plan_type_id OR
        gen_src_all_plan_type_id  = c_fin_plan_type_id);

fp_options_rec      fp_options_cur%ROWTYPE;

-- Bug 3619687 Cursor to return the default generation source plan type
CURSOR def_gen_src_plan_type_cur (c_project_id NUMBER, c_fin_plan_type_id NUMBER)IS
SELECT pt.fin_plan_type_id  as fin_plan_type_id
       ,pt.plan_class_code  as plan_class_code
FROM   pa_proj_fp_options o
       ,pa_fin_plan_types_vl pt
WHERE  o.project_id = c_project_id
AND    o.fin_plan_option_level_code = 'PLAN_TYPE'
AND    o.fin_plan_type_id <> c_fin_plan_type_id
AND    o.fin_plan_preference_code <> 'REVENUE_ONLY'
AND    o.fin_plan_type_id = pt.fin_plan_type_id
AND    nvl(pt.use_for_workplan_flag, 'N') = 'N'
ORDER BY name ASC;

l_def_gen_src_plan_type_id     pa_fin_plan_types_b.fin_plan_type_id%TYPE;
l_def_gen_src_plan_class_code  pa_fin_plan_types_b.plan_class_code%TYPE;

-- error handling variables
l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_error_msg_code  VARCHAR2(30);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);

BEGIN
  FND_MSG_PUB.initialize;
  IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.init_err_stack('PA_FIN_PLAN_TYPE_GLOBAL.delete_plan_type_from_project');
  END IF;
  x_msg_count := 0;
  /* CHECK FOR BUSINESS RULES VIOLATIONS */
  -- If versions of the plan type exist in the project, cannot delete plan type
  open plan_type_versions_csr;
  fetch plan_type_versions_csr into plan_type_versions_rec;
  if not (plan_type_versions_csr%NOTFOUND) then
    x_return_status := FND_API.G_RET_STS_ERROR;
    PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                         p_msg_name            => 'PA_FP_DELETE_PLAN_TYPE_ERROR');
  end if;
  close plan_type_versions_csr;

  -- Cannot delete the Org Forecasting plan type
  open plan_type_code_csr;
  fetch plan_type_code_csr into plan_type_code_rec;
  if not (plan_type_code_csr%NOTFOUND) then
    if plan_type_code_rec.fin_plan_type_code = 'ORG_FORECAST' then
      x_return_status := FND_API.G_RET_STS_ERROR;
      PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_CANNOT_DELETE_ORGFCST');
    end if;
  end if;
  close plan_type_code_csr;

/* If There are ANY Business Rules Violations , Then Do NOT Proceed: RETURN */
    l_msg_count := FND_MSG_PUB.count_msg;
    if l_msg_count > 0 then
        if l_msg_count = 1 then
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
            else
             x_msg_count := l_msg_count;
        end if;
            pa_debug.reset_err_stack;
            return;
    end if;

/* IF NO BUSINESS RULES VIOLATIONS: PROCEED WITH DELETE PLAN TYPE */
  SAVEPOINT PA_FP_DELETE_PLAN_TYPE;

  -- Bug 3619687 if plan type id is the genration source plan type for any other option
  -- update the column with default plan type. Default plan type is determined through
  -- ordering all the other attached plan types in ascending order by name. The first
  -- plan type in that arrangement is the default used for updating all such options

  -- First fetch the default generation source plan type id
  OPEN def_gen_src_plan_type_cur(p_project_id, p_fin_plan_type_id);
  FETCH def_gen_src_plan_type_cur
    INTO l_def_gen_src_plan_type_id,l_def_gen_src_plan_class_code;
  CLOSE def_gen_src_plan_type_cur;

  -- Check if any of the fp options exist with the input plan type as generation source
  OPEN fp_options_cur(p_project_id, p_fin_plan_type_id);
  LOOP
      FETCH  fp_options_cur INTO fp_options_rec;
      EXIT WHEN fp_options_cur%NOTFOUND;

      IF nvl(fp_options_rec.gen_src_cost_plan_type_id, -1) = p_fin_plan_type_id THEN

          fp_options_rec.gen_src_cost_plan_type_id :=  l_def_gen_src_plan_type_id;

          IF 'PLAN_VERSION' = fp_options_rec.fin_plan_option_level_code  THEN
              fp_options_rec.gen_src_cost_plan_version_id := null;
              fp_options_rec.gen_src_cost_plan_ver_code := null;
          ELSE
              fp_options_rec.gen_src_cost_plan_version_id := null;
              IF 'FORECAST' =  nvl(l_def_gen_src_plan_class_code, '-99') THEN
                  fp_options_rec.gen_src_cost_plan_ver_code := 'CURRENT_APPROVED';
              ELSIF 'BUDGET' =   nvl(l_def_gen_src_plan_class_code, '-99') THEN
                  fp_options_rec.gen_src_cost_plan_ver_code := 'CURRENT_BASELINED';
              ELSE
                  fp_options_rec.gen_src_cost_plan_ver_code := null;
              END IF;
          END IF;

      END IF;

      IF nvl(fp_options_rec.gen_src_rev_plan_type_id, -1) = p_fin_plan_type_id THEN

          fp_options_rec.gen_src_rev_plan_type_id :=  l_def_gen_src_plan_type_id;

          IF 'PLAN_VERSION' = fp_options_rec.fin_plan_option_level_code  THEN
              fp_options_rec.gen_src_rev_plan_version_id := null;
              fp_options_rec.gen_src_rev_plan_ver_code := null;
          ELSE
              fp_options_rec.gen_src_rev_plan_version_id := null;
              IF 'FORECAST' =  nvl(l_def_gen_src_plan_class_code, '-99') THEN
                  fp_options_rec.gen_src_rev_plan_ver_code := 'CURRENT_APPROVED';
              ELSIF 'BUDGET' =   nvl(l_def_gen_src_plan_class_code, '-99') THEN
                  fp_options_rec.gen_src_rev_plan_ver_code := 'CURRENT_BASELINED';
              ELSE
                  fp_options_rec.gen_src_rev_plan_ver_code := null;
              END IF;
          END IF;

      END IF;

      IF nvl(fp_options_rec.gen_src_all_plan_type_id, -1) = p_fin_plan_type_id THEN

          fp_options_rec.gen_src_all_plan_type_id :=  l_def_gen_src_plan_type_id;

          IF 'PLAN_VERSION' = fp_options_rec.fin_plan_option_level_code  THEN
              fp_options_rec.gen_src_all_plan_version_id := null;
              fp_options_rec.gen_src_all_plan_ver_code := null;
          ELSE
              fp_options_rec.gen_src_all_plan_version_id := null;
              IF 'FORECAST' =   nvl(l_def_gen_src_plan_class_code, '-99') THEN
                  fp_options_rec.gen_src_all_plan_ver_code := 'CURRENT_APPROVED';
              ELSIF 'BUDGET' =   nvl(l_def_gen_src_plan_class_code, '-99') THEN
                  fp_options_rec.gen_src_all_plan_ver_code := 'CURRENT_BASELINED';
              ELSE
                  fp_options_rec.gen_src_all_plan_ver_code := null;
              END IF;
          END IF;

      END IF;

      -- Update pa_proj_fp_options table
      UPDATE pa_proj_fp_options
      SET    gen_src_cost_plan_type_id      = fp_options_rec.gen_src_cost_plan_type_id
           , gen_src_cost_plan_version_id   = fp_options_rec.gen_src_cost_plan_version_id
           , gen_src_cost_plan_ver_code     = fp_options_rec.gen_src_cost_plan_ver_code
           , gen_src_rev_plan_type_id       = fp_options_rec.gen_src_rev_plan_type_id
           , gen_src_rev_plan_version_id    = fp_options_rec.gen_src_rev_plan_version_id
           , gen_src_rev_plan_ver_code      = fp_options_rec.gen_src_rev_plan_ver_code
           , gen_src_all_plan_type_id       = fp_options_rec.gen_src_all_plan_type_id
           , gen_src_all_plan_version_id    = fp_options_rec.gen_src_all_plan_version_id
           , gen_src_all_plan_ver_code      = fp_options_rec.gen_src_all_plan_ver_code
           , record_version_number          = record_version_number + 1
           , last_update_date               = SYSDATE
           , last_updated_by                = FND_GLOBAL.user_id
           , last_update_login              = FND_GLOBAL.login_id
      WHERE proj_fp_options_id = fp_options_rec.proj_fp_options_id;

  END LOOP;
  CLOSE fp_options_cur;
  -- End of changes for Bug 3619687

  -- delete from PA_FP_ELEMENTS

  /*
    Bug 3106741 For pa_fp_elements there is no index avaialable on project_id and plan_type_id
    to avoid full table scan pa_proj_fp_options would be used to fetch all the relevant option_ids
   */

  delete from pa_fp_elements e
    where e.proj_fp_options_id in (select o.proj_fp_options_id from pa_proj_fp_options o
                                 where  o.project_id = p_project_id and
                                        o.fin_plan_type_id = p_fin_plan_type_id);
  /*
    Bug 3106741 For pa_fp_txn_currencies there is no index avaialable on project_id and plan_type_id
    to avoid full table scan pa_proj_fp_options would be used to fetch all the relevant option_ids
   */

  -- delete from PA_FP_TXN_CURRENCIES
  delete from pa_fp_txn_currencies tc
    where tc.proj_fp_options_id in (select o.proj_fp_options_id
                                    from   pa_proj_fp_options o
                                    where  o.project_id = p_project_id and  --Replaced project_id with p_project_id
                                                                          --for bug 2740553
                                           o.fin_plan_type_id = p_fin_plan_type_id);

  --For Bug 2976168. Should delete the records from pa_fp_excluded_elements also

  IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.g_err_stage:= 'About to delete from pa_fp_excluded_elements';
       pa_debug.write('delete_plan_type_from_project : PA_FIN_PLAN_TYPE_GLOBAL',pa_debug.g_err_stage,3);
  END IF;

  /* Using proj_fp_options_id join instead of directly using project_id, fin_plan_type_id to take
     advantage of pa_fp_excluded_index_u1 index on pa_fp_excluded_elements */

  DELETE
  FROM   pa_fp_excluded_elements ee
  WHERE  ee.proj_fp_options_id IN (SELECT pfo.proj_fp_options_id
                                   FROM   pa_proj_fp_options pfo
                                   WHERE  pfo.project_id = p_project_id
                                   AND    pfo.fin_plan_type_id=p_fin_plan_type_id);

  IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.g_err_stage:= To_char(SQL%ROWCOUNT) || ' records deleted.';
    pa_debug.write('delete_plan_type_from_project : PA_FIN_PLAN_TYPE_GLOBAL',pa_debug.g_err_stage,3);
  END IF;

  -- finally, delete from PA_PROJ_FP_OPTIONS
  delete from pa_proj_fp_options
    where project_id = p_project_id and
          fin_plan_option_level_code = 'PLAN_TYPE' and
          fin_plan_type_id = p_fin_plan_type_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  pa_debug.reset_err_stack;

exception
  when others then
  rollback to PA_FP_DELETE_PLAN_TYPE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_TYPE_GLOBAL',
                               p_procedure_name   => 'delete_plan_type_from_project');
      pa_debug.reset_err_stack;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
END delete_plan_type_from_project;


-- CREATED FOR FP L
-- Created by:    Danny Lai
-- Creation Date: 05/21/03
-- SUMMARY: Given a plan type id, this function returns one of the following:
--          FORECAST - if the plan type is a forecast plan class
--          APPROVED_BUDGET - if the plan type is an approved budget plan class
--	    NON_APPROVED_BUDGET - if the plan type is a non-approved budget plan class
-- This is used for FUNCTION SECURITY checks in Budgeting/Forecasting OA pages
FUNCTION plantype_to_planclass
    (p_project_id		IN  pa_proj_fp_options.project_id%TYPE,
     p_fin_plan_type_id    	IN  pa_proj_fp_options.fin_plan_type_id%TYPE)
return VARCHAR2 is
l_plan_class_code	pa_fin_plan_types_b.plan_class_code%TYPE;
l_approved_cost_pt_flag pa_fin_plan_types_b.approved_cost_plan_type_flag%TYPE;
l_approved_rev_pt_flag  pa_fin_plan_types_b.approved_rev_plan_type_flag%TYPE;
l_return_value		VARCHAR2(80);
BEGIN
    select plan_class_code
      into l_plan_class_code
      from pa_fin_plan_types_b
      where fin_plan_type_id = p_fin_plan_type_id;
    select approved_cost_plan_type_flag,
	   approved_rev_plan_type_flag
      into l_approved_cost_pt_flag,
	   l_approved_rev_pt_flag
      from pa_proj_fp_options
      where project_id = p_project_id and
            fin_plan_type_id = p_fin_plan_type_id and
            fin_plan_option_level_code = 'PLAN_TYPE';
    if l_approved_cost_pt_flag = 'Y' or l_approved_rev_pt_flag = 'Y' then
	l_return_value := 'APPROVED_BUDGET';
    else
	if l_plan_class_code = 'FORECAST' then
	    l_return_value := 'FORECAST';
	else
	    l_return_value := 'NON_APPROVED_BUDGET';
	end if;
    end if;
/*
    if l_plan_class_code = 'FORECAST' then
        l_return_value := 'FORECAST';
    else
        if l_approved_cost_pt_flag = 'Y' or l_approved_rev_pt_flag = 'Y' then
	    l_return_value := 'APPROVED_BUDGET';
        else
            l_return_value := 'NON_APPROVED_BUDGET';
        end if;
    end if;
*/
    return l_return_value;
EXCEPTION
	when NO_DATA_FOUND then
	  return 'INVALID_PLAN_TYPE';
	when others then
	  return 'INVALID_PLAN_TYPE';
END plantype_to_planclass;


-- CREATED FOR FP L
-- Created by:    Danny Lai
-- Creation Date: 05/21/03
-- SUMMARY: Given a budget version id, this function returns one of the following:
--          FORECAST - if the version is a forecast plan class
--          APPROVED_BUDGET - if the version is an approved budget plan class
--	    NON_APPROVED_BUDGET - if the version is a non-approved budget plan class
-- This is used for FUNCTION SECURITY checks in Budgeting/Forecasting OA pages
FUNCTION planversion_to_planclass
    (p_fin_plan_version_id	IN  pa_budget_versions.budget_version_id%TYPE)
return VARCHAR2 is
l_return_value	VARCHAR2(80);
BEGIN
    return l_return_value;
EXCEPTION
	when NO_DATA_FOUND then
	  return 'INVALID_PLAN_TYPE';
	when others then
	  return 'INVALID_PLAN_TYPE';
END planversion_to_planclass;

END pa_fin_plan_type_global;

/
