--------------------------------------------------------
--  DDL for Package Body PA_PLANNING_ELEMENT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PLANNING_ELEMENT_UTILS" AS
/* $Header: PAFPPEUB.pls 120.10.12010000.6 2009/10/09 06:33:03 rrambati ship $
   Start of Comments
   Package name     : pa_planning_element_utils
   Purpose          : API's for Edit Plan / Task Details page
   History          :
   NOTE             :
   End of Comments
*/

/* CHANGE HISTORY
 * 05/18/2004 dlai In the select statements to populate x_current_version_id and x_original_version_id,
 *		   joined str.element_version_id to bv.project_structure_version_id instead of
 *                 str.pev_structure_id to bv.project_structure_version_id (bug 3622609)
 */
/* This procedure should be used for the Workplan Task Details page ONLY!
 */

--These variables are internally used by the API get_fin_struct_id. They should not be used by other
--APIs in this package. These are created for bug 3546208
l_edit_plan_project_id                                pa_projects_all.project_id%TYPE;
l_edit_plan_struct_id                                 pa_budget_versions.project_structure_version_id%TYPE;
l_edit_plan_bv_id                                     pa_budget_versions.budget_version_id%TYPE;

PROCEDURE get_workplan_bvids
  (p_project_id           IN  pa_budget_versions.project_id%TYPE,
   p_element_version_id   IN  pa_proj_element_versions.element_version_id%TYPE,
   x_current_version_id   OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_baselined_version_id OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_published_version_id OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data             OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
 l_wp_structure_version_id    pa_budget_versions.project_structure_version_id%TYPE;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  begin
  -- RETRIEVE THE WORKPLAN STRUCTURE VERSION ID which is used for
  -- join with pa_budget_versions
  select evs.element_version_id -- changed by shyugen
    into l_wp_structure_version_id
    from pa_proj_element_versions ev,
         pa_proj_elem_ver_structure evs
    where ev.project_id = p_project_id and
          ev.element_version_id = p_element_version_id and
          ev.project_id = evs.project_id and -- Added for perf fix - 3961665
          ev.parent_structure_version_id = evs.element_version_id;

  exception
    when NO_DATA_FOUND then
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count     := 1;
    x_msg_data      := SQLERRM;
    FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'pa_planning_element_utils',
                             p_procedure_name   => 'get_workplan_bvids');
    return;
  end;

  begin
  -- RETRIEVE CURRENT VERSION ID
  select budget_version_id
    into x_current_version_id
    from pa_budget_versions
    where project_id = p_project_id and
          wp_version_flag = 'Y' and
          project_structure_version_id = l_wp_structure_version_id;
  exception
    when NO_DATA_FOUND then
      x_current_version_id := -1;
  end;
  -- RETRIEVE CURRENT BASELINED VERSION ID
  begin
  select bv.budget_version_id
    into x_baselined_version_id
    from pa_proj_elem_ver_structure str,
         pa_proj_element_versions ppev1,
         pa_proj_element_versions ppev2,
         pa_budget_versions bv
    where ppev1.element_version_id = p_element_version_id
          and ppev1.project_id = ppev2.project_id
          and ppev1.proj_element_id = ppev2.proj_element_id  -- all the other task versions
          and ppev2.parent_structure_version_id = str.element_version_id --the structure version of each task version
          and ppev2.project_id = str.project_id
          and str.current_flag = 'Y' --the baselined structure version
          and str.element_version_id = bv.project_structure_version_id
          and bv.wp_version_flag = 'Y';
  exception
    when NO_DATA_FOUND then
      x_baselined_version_id := -1;
  end;
  -- RETRIEVE LATEST PUBLISHED VERSION ID
  begin
  select bv.budget_version_id
    into x_published_version_id
    from pa_proj_elem_ver_structure str,
         pa_proj_element_versions ppev1,
         pa_proj_element_versions ppev2,
         pa_budget_versions bv
    where ppev1.element_version_id = p_element_version_id
          and ppev1.project_id = ppev2.project_id
          and ppev1.proj_element_id = ppev2.proj_element_id  -- all the other task versions
          and ppev2.parent_structure_version_id = str.element_version_id --the structure version of each task version
          and ppev2.project_id = str.project_id
          and latest_eff_published_flag = 'Y' --the structure version which is latest published
          and str.element_version_id = bv.project_structure_version_id
          and bv.wp_version_flag = 'Y';
  exception
    when NO_DATA_FOUND then
      x_published_version_id := -1;
  end;
EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count     := 1;
    x_msg_data      := SQLERRM;
    FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'pa_planning_element_utils',
                             p_procedure_name   => 'get_workplan_bvids');
END get_workplan_bvids;

/* CHANGE HISTORY
 * 03/04/2004 dlai modified behavior of get_finplan_bvids.  New summary:
 *            If p_budget_version_id is a BUDGET version:
 *              x_current_version_id = current baselined version of same plan type
 *              x_original_version_id = original baselined version of same plan type
 *              x_prior_fcst_version_id = current baselined version of PRIMARY FORECAST plan type
 *            If p_budget_version is a FORECAST version:
 *              x_current_version_id = current baselined version of APPROVED BUDGET plan type (-1 if not existing)
 *              x_original_version_id = -1 (don't need original baselined version of AB plan type)
 *              x_prior_fcst_version_id = current baselined version of same plan type
 * 03/04/2005 dlai added additional input parameter: p_view_plan_flag.  If this value is 'Y',
 *            then even if the plan version is FORECAST, we will still return the current and
 *            original budget version id's
 * 07/14/2005 dlai if p_budget_version is a FORECAST version, x_original_version_id will
 *                 be passed if it exists (regardless of the value of p_view_plan_flag)
 */
PROCEDURE get_finplan_bvids
  (p_project_id          IN  pa_budget_versions.project_id%TYPE,
   p_budget_version_id   IN  pa_budget_versions.budget_version_id%TYPE,
   p_view_plan_flag      IN  VARCHAR2 default 'N',
   x_current_version_id  OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_original_version_id OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_prior_fcst_version_id OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data            OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
 l_plan_class_code	pa_fin_plan_types_b.plan_class_code%TYPE;
 l_fin_plan_pref_code   pa_proj_fp_options.fin_plan_preference_code%TYPE;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  select pt.plan_class_code,
         po.fin_plan_preference_code
    into l_plan_class_code,
         l_fin_plan_pref_code
    from pa_budget_versions bv,
         pa_fin_plan_types_b pt,
         pa_proj_fp_options po
    where bv.budget_version_id = p_budget_version_id and
          bv.fin_plan_type_id = pt.fin_plan_type_id and
          bv.budget_version_id = po.fin_plan_version_id;
  if l_plan_class_code = 'BUDGET' then
    -- CURRENT PLAN VERSION IS BUDGET PLAN CLASS
    begin
    -- RETRIEVE CURRENT BASELINED VERSION (IF IT EXISTS)
    select bv.budget_version_id
      into x_current_version_id
      from pa_proj_fp_options po,
           pa_budget_versions bv,
	   pa_proj_fp_options po2
      where po.project_id = p_project_id and
            po.fin_plan_version_id = p_budget_version_id and
            po.fin_plan_option_level_code = 'PLAN_VERSION' and
	    po.project_id = po2.project_id and
	    po.fin_plan_type_id = po2.fin_plan_type_id and
	    po.fin_plan_preference_code = po2.fin_plan_preference_code and
  	    po2.fin_plan_option_level_code = 'PLAN_VERSION' and
	    po2.fin_plan_version_id = bv.budget_version_id and
            bv.current_flag = 'Y';
    exception
      when NO_DATA_FOUND then
        x_current_version_id := -1;
    end;
    -- RETRIEVE ORIGINAL BASELINED VERSION (IF IT EXISTS)
    begin
    select bv.budget_version_id
      into x_original_version_id
      from pa_proj_fp_options po,
           pa_budget_versions bv,
	   pa_proj_fp_options po2
      where po.project_id = p_project_id and
            po.fin_plan_version_id = p_budget_version_id and
            po.fin_plan_option_level_code = 'PLAN_VERSION' and
	    po.project_id = po2.project_id and
  	    po.fin_plan_type_id = po2.fin_plan_type_id and
	    po.fin_plan_preference_code = po2.fin_plan_preference_code and
	    po2.fin_plan_option_level_code = 'PLAN_VERSION' and
	    po2.fin_plan_version_id = bv.budget_version_id and
            bv.current_original_flag = 'Y'; -- bug fix 3630207
    exception
      when NO_DATA_FOUND then
        x_original_version_id := -1;
    end;
    -- RETRIEVE PRIMARY FORECAST BASELINED VERSION (IF IT EXISTS)
    if l_fin_plan_pref_code = 'COST_ONLY' then
      -- looking for PRIMARY COST FORECAST plan type
        begin
          select bv.budget_version_id
	    into x_prior_fcst_version_id
	    from pa_proj_fp_options po,
		 pa_budget_versions bv
	    where po.project_id = p_project_id and
		  po.fin_plan_option_level_code = 'PLAN_VERSION' and
		  bv.primary_cost_forecast_flag = 'Y' and
 		  po.fin_plan_version_id = bv.budget_version_id and
		  bv.current_flag = 'Y';
        exception
	  when NO_DATA_FOUND then
        	x_prior_fcst_version_id := -1;
        end;
    else
      -- looking for PRIMARY REVENUE FORECAST plan type
        begin
          select bv.budget_version_id
	    into x_prior_fcst_version_id
	    from pa_proj_fp_options po,
		 pa_budget_versions bv
	    where po.project_id = p_project_id and
		  po.fin_plan_option_level_code = 'PLAN_VERSION' and
		  bv.primary_rev_forecast_flag = 'Y' and
 		  po.fin_plan_version_id = bv.budget_version_id and
		  bv.current_flag = 'Y';
        exception
	  when NO_DATA_FOUND then
        	x_prior_fcst_version_id := -1;
        end;
    end if; -- l_fin_plan_pref_code

  else
    -- CURRENT PLAN VERSION IS FORECAST PLAN CLASS
    begin
      select bv.budget_version_id
        into x_prior_fcst_version_id
        from pa_proj_fp_options po,
             pa_budget_versions bv,
	     pa_proj_fp_options po2
        where po.project_id = p_project_id and
              po.fin_plan_version_id = p_budget_version_id and
              po.fin_plan_option_level_code = 'PLAN_VERSION' and
	      po.project_id = po2.project_id and
	      po.fin_plan_type_id = po2.fin_plan_type_id and
	      po.fin_plan_preference_code = po2.fin_plan_preference_code and
    	      po2.fin_plan_option_level_code = 'PLAN_VERSION' and
	      po2.fin_plan_version_id = bv.budget_version_id and
              bv.current_flag = 'Y';
    exception
      when NO_DATA_FOUND then
        x_prior_fcst_version_id := -1;
    end;
    -- RETRIEVE APPROVED BUDGET INFO (IF IT EXISTS)
    -- 4477233: for Forecast version, always return original baselined info
      -- retrieve original baselined info
      if l_fin_plan_pref_code = 'COST_ONLY' then
        -- looking for APPROVED COST BUDGET plan type
          begin
            select bv.budget_version_id
	      into x_original_version_id
	      from pa_proj_fp_options po,
		   pa_budget_versions bv
  	      where po.project_id = p_project_id and
		    po.fin_plan_option_level_code = 'PLAN_VERSION' and
		    bv.approved_cost_plan_type_flag = 'Y' and
  		    po.fin_plan_version_id = bv.budget_version_id and
		    bv.current_original_flag = 'Y';
          exception
	    when NO_DATA_FOUND then
        	x_original_version_id := -1; -- Bug 7668837
          end;
      elsif l_fin_plan_pref_code = 'REVENUE_ONLY' then
        -- looking for APPROVED REVENUE BUDGET plan type
          begin
            select bv.budget_version_id
	      into x_original_version_id
	      from pa_proj_fp_options po,
		   pa_budget_versions bv
  	      where po.project_id = p_project_id and
		    po.fin_plan_option_level_code = 'PLAN_VERSION' and
		    bv.approved_rev_plan_type_flag = 'Y' and
  		    po.fin_plan_version_id = bv.budget_version_id and
		    bv.current_original_flag = 'Y';
          exception
	    when NO_DATA_FOUND then
        	x_original_version_id := -1; -- Bug 7668837
          end;
      else
        -- looking for APPROVED COST AND REVENUE BUDGET plan type
        begin
          select bv.budget_version_id
	    into x_original_version_id
	    from pa_proj_fp_options po,
		 pa_budget_versions bv
	    where po.project_id = p_project_id and
		  po.fin_plan_option_level_code = 'PLAN_VERSION' and
	          bv.approved_cost_plan_type_flag = 'Y' and
		  bv.approved_rev_plan_type_flag = 'Y' and
 		  po.fin_plan_version_id = bv.budget_version_id and
		  bv.current_original_flag = 'Y';
        exception
	  when NO_DATA_FOUND then
        	x_original_version_id := -1; -- Bug 7668837
        end;
      end if; -- l_fin_plan_pref_code


    if l_fin_plan_pref_code = 'COST_ONLY' then
      -- looking for APPROVED COST BUDGET plan type
        begin
          select bv.budget_version_id
	    into x_current_version_id
	    from pa_proj_fp_options po,
		 pa_budget_versions bv
	    where po.project_id = p_project_id and
		  po.fin_plan_option_level_code = 'PLAN_VERSION' and
		  bv.approved_cost_plan_type_flag = 'Y' and
 		  po.fin_plan_version_id = bv.budget_version_id and
		  bv.current_flag = 'Y';
        exception
	  when NO_DATA_FOUND then
        	x_current_version_id := -1;
        end;
    else
      -- looking for APPROVED REVENUE BUDGET plan type
        begin
          select bv.budget_version_id
	    into x_current_version_id
	    from pa_proj_fp_options po,
		 pa_budget_versions bv
	    where po.project_id = p_project_id and
		  po.fin_plan_option_level_code = 'PLAN_VERSION' and
		  bv.approved_rev_plan_type_flag = 'Y' and
 		  po.fin_plan_version_id = bv.budget_version_id and
		  bv.current_flag = 'Y';
        exception
	  when NO_DATA_FOUND then
        	x_current_version_id := -1;
        end;
    end if; -- l_fin_plan_pref_code

  end if; -- l_plan_class_code
EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count     := 1;
    x_msg_data      := SQLERRM;
    FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'pa_planning_element_utils',
                             p_procedure_name   => 'get_finplan_bvids');
END get_finplan_bvids;

FUNCTION get_task_name_and_number
  (p_project_or_task        IN VARCHAR2,  -- 'PROJECT' or 'TASK'
   p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE) return VARCHAR2 is
  l_return_value  VARCHAR2(2000);
BEGIN
  if p_project_or_task = 'PROJECT' then
    -- GET PROJECT NAME AND NUMBER
    select pa.name || ' (' || pa.segment1 || ')'
      into l_return_value
      from pa_resource_assignments ra,
           pa_projects_all pa
      where ra.resource_assignment_id = p_resource_assignment_id and
            ra.project_id = pa.project_id;
  else
    -- GET TASK NAME AND NUMBER
    select pe.name || ' (' || pe.element_number || ')'
      into l_return_value
      from pa_resource_assignments ra,
           pa_proj_elements pe
      where ra.resource_assignment_id = p_resource_assignment_id and
            ra.task_id =  pe.proj_element_id;
  end if;
  return l_return_value;
EXCEPTION
  when NO_DATA_FOUND then
    return null;
  when OTHERS then
    return null;
END get_task_name_and_number;
/* Bug 3840851: Fin strucutre function call was used before l_project_id was
 * retrieved!. Since the selects which use this function in the below api will
 * always return one record, removed the local variable for structure version id
 * and included direct function call for retrieving fin struct ver id in the
 * selects. */
-- Bug 4057673. Added a parameter p_fin_plan_level_code. It will be either 'P','L' or 'M'
--depending on the planning level of the budget version
FUNCTION get_project_task_level
  (p_resource_assignment_id   IN pa_resource_assignments.resource_assignment_id%TYPE,
   p_fin_plan_level_code      IN pa_proj_fp_options.cost_fin_plan_level_code%TYPE) return VARCHAR2 is

 l_project_id	        pa_resource_assignments.project_id%TYPE;
 l_element_version_id   pa_resource_assignments.wbs_element_version_id%TYPE;
 l_rlm_id	            pa_resource_assignments.resource_list_member_id%TYPE;
 l_uncat_rlm_id         pa_resource_list_members.resource_list_member_id%TYPE;
 l_summary_task_flag    VARCHAR2(1);
 l_return_value         VARCHAR2(80);

 CURSOR cur_obj_rel
   IS
     select object_id_to1 from pa_object_relationships
       where object_id_to1 = l_element_version_id and
             object_id_from1 = PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(l_project_id)
             and object_type_from = 'PA_STRUCTURES'
             and relationship_type = 'S';
/*
 CURSOR cur_obj_rel
   IS
    SELECT 'x'
      FROM  pa_object_relationships
     WHERE object_id_to1 = l_element_version_id and
           rownum < 2 and
           object_type_from = 'PA_TASKS';
*/
 v_dummy_id          pa_resource_assignments.wbs_element_version_id%TYPE;
 --Bug 4057673.This variable will be set to Y for tasks that are both top and lowest
 l_top_and_lowest_task_flag    VARCHAR2(1);

BEGIN
  l_return_value := 'INVALID VALUE';
  l_uncat_rlm_id  := pa_planning_element_utils.get_project_uncat_rlmid;
  l_top_and_lowest_task_flag := 'N';--Bug 4057673
  -- we have an element_version_id; need to determine what level task it is
  BEGIN
	  select pelm.element_version_id,
    		 ra.resource_list_member_id,
             ra.project_id
	    into l_element_version_id,
		     l_rlm_id,
             l_project_id
	    from pa_resource_assignments ra,
             pa_proj_element_versions pelm
	    where ra.resource_assignment_id = p_resource_assignment_id
        AND  pelm.proj_element_id(+)=ra.task_id
        AND  pelm.parent_structure_Version_id(+)=PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(ra.project_id);
  EXCEPTION
    when NO_DATA_FOUND then
	return l_return_value;
  END;
  /* l_element_version_id could be 0 or null if not a task-level row:
   * bug 3455681
   */
  if (l_element_version_id is null or l_element_version_id = 0) then
    -- no element_version_id; must be PROJECT row or resource row
      l_return_value := 'PROJECT';
    /*
    if l_rlm_id = l_uncat_rlm_id then
      l_return_value := 'PROJECT';
    else
      l_return_value := 'RESOURCE';
    end if;
    */
  else
    open cur_obj_rel;
    fetch cur_obj_rel into v_dummy_id;
    if cur_obj_rel%FOUND then
      -- the task is a TOP task or a LOWEST_TASK
      l_summary_task_flag :=
	    PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(l_element_version_id);
      if l_summary_task_flag = 'N' then
        -- task is a Lowest Task
        l_return_value := 'LOWEST_TASK';
        l_top_and_lowest_task_flag := 'Y';--Bug 4057673
      else
        -- task is a Top Task
        l_return_value := 'TOP_TASK';
      end if;
    else
      l_summary_task_flag :=
	    PA_PROJ_ELEMENTS_UTILS.is_summary_task_or_structure(l_element_version_id);
      if l_summary_task_flag = 'N' then
        -- task is a Lowest Task
        l_return_value := 'LOWEST_TASK';
      else
        l_return_value := 'MIDDLE_TASK';
      end if;
    end if; -- cursor%FOUND
    close cur_obj_rel;
  end if; -- TASK
  --Bug 4057673. If the task is both top and lowest then depending on planning level return either TOP or LOWEST for
  --task level.
  IF l_top_and_lowest_task_flag = 'Y'  THEN

      IF p_fin_plan_level_code = 'T' THEN

          l_return_value := 'TOP_TASK';

      ELSIF p_fin_plan_level_code = 'L' THEN

          l_return_value := 'LOWEST_TASK';

      END IF;

  END IF;
  return l_return_value;
END get_project_task_level;

FUNCTION get_res_class_name
  (p_res_class_code IN pa_resource_classes_b.resource_class_code%TYPE) return VARCHAR2 is
 l_return_value   VARCHAR2(240) := 'invalid value';
BEGIN
  select name
    into l_return_value
    from pa_resource_classes_vl
    where resource_class_code = p_res_class_code;
  return l_return_value;
EXCEPTION
  when NO_DATA_FOUND then
    return null;
  when OTHERS then
    return null;
END get_res_class_name;

FUNCTION get_res_type_name
  (p_res_type_code IN pa_res_types_b.res_type_code%TYPE) return VARCHAR2 is
 l_return_value  VARCHAR2(240) := 'invalid value';
BEGIN
  select name
    into l_return_value
    from pa_res_types_vl
    where res_type_code = p_res_type_code;
  return l_return_value;
EXCEPTION
  when NO_DATA_FOUND then
    return null;
  when OTHERS then
    return null;
END get_res_type_name;

FUNCTION get_project_role_name
  (p_project_role_id IN pa_project_role_types_b.project_role_id%TYPE) return VARCHAR2 IS
 l_return_value    VARCHAR2(80) := 'invalid value';
BEGIN
  select meaning
    into l_return_value
    -- Bug Fix 4452472
    -- replaced the _vl with _tl
    -- from pa_project_role_types_vl
    from pa_project_role_types_tl
    where project_role_id = p_project_role_id and
          language = userenv('LANG');
  return l_return_value;
EXCEPTION
  when NO_DATA_FOUND then
    return null;
  when OTHERS then
    return null;
END get_project_role_name;

FUNCTION get_supplier_name
  (p_supplier_id IN po_vendors.vendor_id%TYPE) return VARCHAR2 is
 l_return_value  VARCHAR2(80) := 'invalid value';
BEGIN
  select vendor_name
    into l_return_value
    from po_vendors
    where vendor_id = p_supplier_id;
  return l_return_value;
EXCEPTION
  when NO_DATA_FOUND then
    return null;
  when OTHERS then
    return null;
END get_supplier_name;

FUNCTION get_schedule_role_name
  (p_proj_assignment_id IN pa_project_assignments.assignment_id%TYPE) return VARCHAR2 is
 l_return_value   VARCHAR2(80) := 'invalid value';
BEGIN
  select assignment_name
    into l_return_value
    from pa_project_assignments
    where assignment_id = p_proj_assignment_id;
  return l_return_value;
EXCEPTION
  when NO_DATA_FOUND then
    return null;
  when OTHERS then
    return null;
END get_schedule_role_name;

FUNCTION get_spread_curve_name
  (p_spread_curve_id IN pa_spread_curves_b.spread_curve_id%TYPE) return VARCHAR2 is
 l_return_value   VARCHAR2(240);
BEGIN
  select name
    into l_return_value
    -- Bug Fix 4452472
    -- replaced the _vl with _tl
    -- from pa_spread_curves_vl
    from pa_spread_curves_tl
    where spread_curve_id = p_spread_curve_id and
          language = userenv('LANG');
  return l_return_value;
EXCEPTION
  when NO_DATA_FOUND then
    return null;
  when OTHERS then
    return null;
END get_spread_curve_name;

FUNCTION get_mfc_cost_type_name
  (p_mfc_cost_type_id IN pa_resource_assignments.mfc_cost_type_id%TYPE) return VARCHAR2 is
 l_return_value   VARCHAR2(80);
BEGIN
  select cost_type
    into l_return_value
    from cst_cost_types_v
    where cost_type_id = p_mfc_cost_type_id;
  return l_return_value;
EXCEPTION
  when NO_DATA_FOUND then
    return null;
  when OTHERS then
    return null;
END get_mfc_cost_type_name;

FUNCTION get_project_uncat_rlmid return NUMBER is
 l_uncat_resource_list_id    pa_resource_lists.resource_list_id%TYPE;
 l_uncat_rlm_id              pa_resource_assignments.resource_list_member_id%TYPE;
 l_track_as_labor_flag       pa_resources.track_as_labor_flag%TYPE;
 l_unit_of_measure           pa_resource_assignments.unit_of_measure%TYPE;
 l_return_status	     VARCHAR2(1);
 l_msg_count		     NUMBER;
 l_msg_data		     VARCHAR2(2000);
BEGIN
  pa_fin_plan_utils.Get_Uncat_Resource_List_Info
         (x_resource_list_id        => l_uncat_resource_list_id
         ,x_resource_list_member_id => l_uncat_rlm_id
         ,x_track_as_labor_flag     => l_track_as_labor_flag
         ,x_unit_of_measure         => l_unit_of_measure
         ,x_return_status           => l_return_status
         ,x_msg_count               => l_msg_count
         ,x_msg_data                => l_msg_data);
  if l_return_status = FND_API.G_RET_STS_SUCCESS then
	return l_uncat_rlm_id;
  else
	return null;
  end if;
EXCEPTION
  when OTHERS then
    return null;
END get_project_uncat_rlmid;


/* PROCEDURE get_common_budget_version_info
 * This procedure is used to populate attributes for a particular row in the
 * PlanningElementsCommonVO.
 * INPUT: p_budget_version_id - budget version id
 *        p_resource_assignment_id - particular planning element row
 *        p_project_currency_code - project currency code
 *        p_projfunc_currency_code - project functional currency code
 *        p_txn_currency_code - applicable if the planning element is planned in
 *                              multi-currency
 * OUTPUT: row-level attributes for the budget version's planning element for a
 *         particular currency
 * REVISION HISTORY:
 * 07/08/2004 - dlai - added the following input parameters so ETC rates can
 *            be displayed for baselined and latest published versions (Task
 *            Assignments):    x_etc_avg_rev_rate, x_etc_avg_raw_cost_rate,
 *            x_etc_avg_burd_cost_rate
 * 07/15/2004 - dlai - added the following output parameters for bug 3622609:
 *            x_schedule_start_date, x_schedule_end_date
 * 11/16/2004 - dlai - when no budget lines exist for a particular
 *            txn_currency_code (which is not proj or projfunc currency), be
 *            sure to return null for txn amounts, and not rely on the amounts in
 *            pa_resource_assignments
 * 02/08/2005 - dlai - when looking for match, the records should also have
 *            the same unit_of_measure in addition to task-res-txncurrency
 * 05/10/2005 - dlai - margin parameters are returned as null if
 *            p_budget_version_id refers to COST_ONLY or REVENUE_ONLY version
 */
PROCEDURE get_common_budget_version_info
  (p_budget_version_id       IN  pa_budget_versions.budget_version_id%TYPE,
   p_resource_assignment_id  IN  pa_resource_assignments.resource_assignment_id%TYPE,
   p_project_currency_code   IN  pa_projects_all.project_currency_code%TYPE,
   p_projfunc_currency_code  IN  pa_projects_all.projfunc_currency_code%TYPE,
   p_txn_currency_code       IN  pa_budget_lines.txn_currency_code%TYPE,
   p_line_start_date         IN  pa_budget_lines.start_date%TYPE := to_date(NULL),
   p_line_end_date           IN  pa_budget_lines.end_date%TYPE := to_date(NULL),
   x_budget_version_id       OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_planning_start_date     OUT NOCOPY pa_resource_assignments.planning_start_date%TYPE, --File.Sql.39 bug 4440895
   x_planning_end_date       OUT NOCOPY pa_resource_assignments.planning_end_date%TYPE, --File.Sql.39 bug 4440895
   x_schedule_start_date     OUT NOCOPY pa_resource_assignments.schedule_start_date%TYPE, --File.Sql.39 bug 4440895
   x_schedule_end_date	     OUT NOCOPY pa_resource_assignments.schedule_start_date%TYPE, --File.Sql.39 bug 4440895
   x_quantity                OUT NOCOPY pa_resource_assignments.total_plan_quantity%TYPE, --File.Sql.39 bug 4440895
   x_revenue_txn_cur         OUT NOCOPY pa_budget_lines.txn_revenue%TYPE, --File.Sql.39 bug 4440895
   x_revenue_proj_cur        OUT NOCOPY pa_resource_assignments.total_project_revenue%TYPE, --File.Sql.39 bug 4440895
   x_revenue_proj_func_cur   OUT NOCOPY pa_resource_assignments.total_plan_revenue%TYPE, --File.Sql.39 bug 4440895
   x_raw_cost_txn_cur        OUT NOCOPY pa_budget_lines.txn_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_raw_cost_proj_cur       OUT NOCOPY pa_resource_assignments.total_project_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_raw_cost_proj_func_cur  OUT NOCOPY pa_resource_assignments.total_plan_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_burd_cost_txn_cur       OUT NOCOPY pa_budget_lines.txn_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_burd_cost_proj_cur      OUT NOCOPY pa_resource_assignments.total_project_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_burd_cost_proj_func_cur OUT NOCOPY pa_resource_assignments.total_plan_burdened_cost%TYPE, --File.Sql.39 bug 4440895
--   x_burd_multiplier         OUT pa_budget_lines.txn_burden_multiplier%TYPE, -- FPM2 data model changes
   x_init_rev_rate           OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_avg_rev_rate            OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_init_raw_cost_rate      OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_avg_raw_cost_rate       OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_init_burd_cost_rate     OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_avg_burd_cost_rate      OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_margin_txn_cur          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_margin_proj_cur         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_margin_proj_func_cur    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_margin_pct              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_avg_rev_rate	     OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_avg_raw_cost_rate   OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_avg_burd_cost_rate  OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

 l_project_id                 pa_resource_assignments.project_id%TYPE;
 l_task_id		      pa_resource_assignments.task_id%TYPE;
 l_resource_list_member_id    pa_resource_assignments.resource_list_member_id%TYPE;
 l_resource_assignment_id     pa_resource_assignments.resource_assignment_id%TYPE;
 l_unit_of_measure            pa_resource_assignments.unit_of_measure%TYPE;

 l_budget_lines_exist_flag    VARCHAR2(1);  -- whether budget lines exist for planning element

 l_start_date		      pa_budget_lines.start_date%TYPE;
 l_end_date		      pa_budget_lines.end_date%TYPE;
 l_period_name		      pa_budget_lines.period_name%TYPE;
 l_quantity		      pa_budget_lines.quantity%TYPE;
 l_txn_raw_cost		      pa_budget_lines.raw_cost%TYPE;
 l_txn_burdened_cost	      pa_budget_lines.burdened_cost%TYPE;
 l_txn_revenue		      pa_budget_lines.revenue%TYPE;
 l_init_quantity	      pa_budget_lines.init_quantity%TYPE;
 l_txn_init_raw_cost	      pa_budget_lines.txn_init_raw_cost%TYPE;
 l_txn_init_burdened_cost     pa_budget_lines.txn_init_burdened_cost%TYPE;
 l_txn_init_revenue	      pa_budget_lines.txn_init_revenue%TYPE;
 l_init_raw_cost_rate	      NUMBER;
 l_init_burd_cost_rate        NUMBER;
 l_init_revenue_rate	      NUMBER;
 l_etc_init_raw_cost_rate     NUMBER;
 l_etc_init_burd_cost_rate    NUMBER;
 l_etc_init_revenue_rate      NUMBER;

 cursor raid_csr is
   select ra.resource_assignment_id
     from pa_resource_assignments ra
     where ra.project_id = l_project_id and
           ra.budget_version_id = p_budget_version_id and
           ra.task_id = l_task_id and
           ra.resource_list_member_id = l_resource_list_member_id and
           ra.unit_of_measure = l_unit_of_measure;
 raid_rec raid_csr%ROWTYPE;

 cursor budget_lines_csr is
   select 'Y'
     from pa_budget_lines
     where resource_assignment_id = l_resource_assignment_id and
           txn_currency_code = p_txn_currency_code;
  budget_lines_rec budget_lines_csr%ROWTYPE;

 -- Bug Fix 3732157
 -- Moving the code from the body to here as a cursor.

 -- Bug 6459226: Replacing the queries from pa_resource_asgn_curr
 -- with pa_budget_lines once again because this cursor is called
 -- in case budget lines exist and on Edit Budget Line page, we
 -- have to show the periodic split up of amounts.


 --Bug 6836806 Modifying the cursor to display periodic level information under current budget columns
 --for budget lines when viewed at period level data.
 -- Reverting the changes coz the budget line infomatin should be picked from pa_budget_lines in order view
 -- data periodically when planning start/end dates are passed.
 CURSOR get_budget_line_amts_for_dates IS
 select ra.planning_start_date,
                 ra.planning_end_date,
                 ra.schedule_start_date,
                 ra.schedule_end_date,
                 SUM(bl.quantity),
                 SUM(bl.txn_revenue),
                 SUM(bl.project_revenue), --ra.total_project_revenue,
                 SUM(bl.revenue),         --ra.total_plan_revenue,
                 SUM(bl.txn_raw_cost),
                 SUM(bl.project_raw_cost), --ra.total_project_raw_cost,
                 SUM(bl.raw_cost),         --ra.total_plan_raw_cost,
                 SUM(bl.txn_burdened_cost),
                 SUM(bl.project_burdened_cost), --ra.total_project_burdened_cost,
                 SUM(bl.burdened_cost),         --ra.total_plan_burdened_cost,
                 null,  -- x_init_rev_rate (TO BE CALCULATED)
		 DECODE(SUM(bl.quantity),
			0, 0,
			null, null,
			SUM(bl.txn_revenue)/SUM(bl.quantity)),
                 null,  -- x_init_raw_cost_rate (TO BE CALCULATED)
		 DECODE(SUM(bl.quantity),
			0, 0,
			null, null,
			SUM(bl.txn_raw_cost)/SUM(bl.quantity)),
                 null,  -- x_init_burd_cost_rate (TO BE CALCULATED)
		 DECODE(SUM(bl.quantity),
			0, 0,
			null, null,
			SUM(bl.txn_burdened_cost)/SUM(bl.quantity)),
		 DECODE(po.fin_plan_preference_code,
                        'COST_ONLY', to_number(null),
			'REVENUE_ONLY', to_number(null),
                 	 DECODE(po.margin_derived_from_code,
                                'B', SUM(bl.txn_revenue) - SUM(bl.txn_burdened_cost),
                                SUM(bl.txn_revenue) - SUM(bl.txn_raw_cost))),
		 DECODE(po.fin_plan_preference_code,
			'COST_ONLY', to_number(null),
			'REVENUE_ONLY', to_number(null),
	                 DECODE(po.margin_derived_from_code,
                   	        'B', SUM(bl.project_revenue) - SUM(bl.project_burdened_cost),
                                SUM(bl.project_revenue) - SUM(bl.project_raw_cost))),
		 DECODE(po.fin_plan_preference_code,
			'COST_ONLY', to_number(null),
			'REVENUE_ONLY', to_number(null),
	                 DECODE(po.margin_derived_from_code,
        	                'B', SUM(bl.revenue) - SUM(bl.burdened_cost),
                                SUM(bl.revenue) - SUM(bl.raw_cost))),
		 DECODE(po.fin_plan_preference_code,
			'COST_ONLY', to_number(null),
			'REVENUE_ONLY', to_number(null),
	                 DECODE(SUM(bl.project_revenue),
        	                0, 0,
                   		null, to_number(null),
                   		DECODE(po.margin_derived_from_code,
                     		       'B', 100*(SUM(bl.project_revenue) - SUM(bl.project_burdened_cost))/SUM(bl.project_revenue),
                     			100*(SUM(bl.project_revenue) - SUM(bl.project_raw_cost)))/SUM(bl.project_revenue))),
		DECODE(SUM(bl.quantity) - SUM(nvl(bl.init_quantity,0)),
                         0, 0,
                         null, 0,
                         (SUM(bl.txn_revenue) - SUM(nvl(bl.txn_init_revenue,0)))/(SUM(bl.quantity) - SUM(nvl(bl.init_quantity,0)))),
		DECODE(SUM(bl.quantity) - SUM(nvl(init_quantity,0)),
                         0, 0,
                         null, 0,
                         (SUM(bl.txn_raw_cost) - SUM(nvl(bl.txn_init_raw_cost,0)))/(SUM(bl.quantity) - SUM(nvl(init_quantity,0)))),
		DECODE(SUM(bl.quantity) - SUM(nvl(init_quantity,0)),
                         0, 0,
                         null, 0,
                         (SUM(bl.txn_burdened_cost) - SUM(nvl(bl.txn_init_burdened_cost,0)))/(SUM(bl.quantity) - SUM(nvl(init_quantity,0))))
            from pa_resource_assignments ra,
                 pa_budget_lines bl,
                 pa_budget_versions bv,
                 pa_proj_fp_options po
            where ra.resource_assignment_id = l_resource_assignment_id and
                  ra.resource_assignment_id = bl.resource_assignment_id and
                  bl.txn_currency_code = p_txn_currency_code and
                  ra.budget_version_id = bv.budget_version_id and
                  bv.budget_version_id = po.fin_plan_version_id and
                  po.fin_plan_option_level_code = 'PLAN_VERSION' and
                  bl.start_date BETWEEN p_line_start_date and p_line_end_date
            group by bl.resource_assignment_id,
                     bl.txn_currency_code,
                     ra.planning_start_date,
                     ra.planning_end_date,
		     po.margin_derived_from_code,
                     ra.schedule_start_date,
                     ra.schedule_end_date,
		     po.fin_plan_preference_code;

--            SELECT ra.planning_start_date,
--                   ra.planning_end_date,
--                   ra.schedule_start_date,
--                   ra.schedule_end_date,
--                   rac.total_display_quantity,
--                   rac.total_txn_revenue,
--                   rac.total_project_revenue, --ra.total_project_revenue,
--                   rac.total_projfunc_revenue,         --ra.total_plan_revenue,
--                   rac.total_txn_raw_cost,
--                   rac.total_project_raw_cost, --ra.total_project_raw_cost,
--                   rac.total_projfunc_raw_cost,         --ra.total_plan_raw_cost,
--                   rac.total_txn_burdened_cost,
--                   rac.total_project_burdened_cost, --ra.total_project_burdened_cost,
--                   rac.total_projfunc_burdened_cost,         --ra.total_plan_burdened_cost,
--  /*
--                   SUM(bl.quantity),
--                   SUM(bl.txn_revenue),
--                   SUM(bl.project_revenue), --ra.total_project_revenue,
--                   SUM(bl.revenue),         --ra.total_plan_revenue,
--                   SUM(bl.txn_raw_cost),
--                   SUM(bl.project_raw_cost), --ra.total_project_raw_cost,
--                   SUM(bl.raw_cost),         --ra.total_plan_raw_cost,
--                   SUM(bl.txn_burdened_cost),
--                   SUM(bl.project_burdened_cost), --ra.total_project_burdened_cost,
--                   SUM(bl.burdened_cost),         --ra.total_plan_burdened_cost,
--  */
--                   NULL,  -- x_init_rev_rate (TO BE CALCULATED)
--  /*
--  		 DECODE(SUM(bl.quantity),
--  			0, 0,
--  			NULL, NULL,
--  			SUM(bl.txn_revenue)/SUM(bl.quantity)),
--  */
--           DECODE(ra.rate_based_flag, 'Y', rac.txn_average_bill_rate, TO_NUMBER(NULL)),
--                   NULL,  -- x_init_raw_cost_rate (TO BE CALCULATED)
--  /*
--  		 DECODE(SUM(bl.quantity),
--  			0, 0,
--  			NULL, NULL,
--  			SUM(bl.txn_raw_cost)/SUM(bl.quantity)),
--  */
--           DECODE(ra.rate_based_flag, 'Y', rac.txn_average_raw_cost_rate, TO_NUMBER(NULL)),
--                   NULL,  -- x_init_burd_cost_rate (TO BE CALCULATED)
--  /*
--  		 DECODE(SUM(bl.quantity),
--  			0, 0,
--  			NULL, NULL,
--  			SUM(bl.txn_burdened_cost)/SUM(bl.quantity)),
--  */
--           DECODE(ra.rate_based_flag, 'Y', rac.txn_average_burden_cost_rate, TO_NUMBER(NULL)),
--  		 DECODE(po.fin_plan_preference_code,
--                          'COST_ONLY', TO_NUMBER(NULL),
--  			'REVENUE_ONLY', TO_NUMBER(NULL),
--                   	 DECODE(po.margin_derived_from_code,
--  --                                'B', SUM(bl.txn_revenue) - SUM(bl.txn_burdened_cost),
--  --                                SUM(bl.txn_revenue) - SUM(bl.txn_raw_cost))),
--                                  'B', rac.total_txn_revenue - rac.total_txn_burdened_cost,
--                                  rac.total_txn_revenue - rac.total_txn_raw_cost)),
--  		 DECODE(po.fin_plan_preference_code,
--  			'COST_ONLY', TO_NUMBER(NULL),
--  			'REVENUE_ONLY', TO_NUMBER(NULL),
--  	                 DECODE(po.margin_derived_from_code,
--  --                   	        'B', SUM(bl.project_revenue) - SUM(bl.project_burdened_cost),
--  --                                SUM(bl.project_revenue) - SUM(bl.project_raw_cost))),
--                     	        'B', rac.total_project_revenue - rac.total_project_burdened_cost,
--                                  rac.total_project_revenue - rac.total_project_raw_cost)),
--  		 DECODE(po.fin_plan_preference_code,
--  			'COST_ONLY', TO_NUMBER(NULL),
--  			'REVENUE_ONLY', TO_NUMBER(NULL),
--  	                 DECODE(po.margin_derived_from_code,
--  --        	                'B', SUM(bl.reve nue) - SUM(bl.burdened_cost),
--  --                                SUM(bl.revenue) - SUM(bl.raw_cost))),
--         	                'B', rac.total_projfunc_revenue - rac.total_projfunc_burdened_cost,
--                                  rac.total_projfunc_revenue - rac.total_projfunc_raw_cost)),
--  			 DECODE(po.fin_plan_preference_code,
--  			'COST_ONLY', TO_NUMBER(NULL),
--  			'REVENUE_ONLY', TO_NUMBER(NULL),
--  --	                 DECODE(SUM(bl.project_revenue),
--  	                 DECODE(rac.total_project_revenue,
--          	                0, 0,
--                     		NULL, TO_NUMBER(NULL),
--                     		DECODE(po.margin_derived_from_code,
--  --                     		       'B', 100*(SUM(bl.project_revenue) - SUM(bl.project_burdened_cost))/SUM(bl.project_revenue),
--  --                     			100*(SUM(bl.project_revenue) - SUM(bl.project_raw_cost)))/SUM(bl.project_revenue))),
--                       		       'B', 100*(rac.total_project_revenue - rac.total_project_burdened_cost)/rac.total_project_revenue,
--                       			100*(rac.total_project_revenue - rac.total_project_raw_cost)/rac.total_project_revenue))),
--  /*
--  		DECODE(SUM(bl.quantity) - SUM(NVL(bl.init_quantity,0)),
--                           0, 0,
--                           NULL, 0,
--                           (SUM(bl.txn_revenue) - SUM(NVL(bl.txn_init_revenue,0)))/(SUM(bl.quantity) - SUM(NVL(bl.init_quantity,0)))),
--  */
--           DECODE(ra.rate_based_flag, 'Y', rac.txn_etc_bill_rate, TO_NUMBER(NULL)),
--  /*
--  		DECODE(SUM(bl.quantity) - SUM(NVL(init_quantity,0)),
--                           0, 0,
--                           NULL, 0,
--                           (SUM(bl.txn_raw_cost) - SUM(NVL(bl.txn_init_raw_cost,0)))/(SUM(bl.quantity) - SUM(NVL(init_quantity,0)))),
--  */
--           DECODE(ra.rate_based_flag, 'Y', rac.txn_etc_raw_cost_rate, TO_NUMBER(NULL)),
--  /*
--  		DECODE(SUM(bl.quantity) - SUM(NVL(init_quantity,0)),
--                           0, 0,
--                           NULL, 0,
--                           (SUM(bl.txn_burdened_cost) - SUM(NVL(bl.txn_init_burdened_cost,0)))/(SUM(bl.quantity) - SUM(NVL(init_quantity,0))))
--  */
--            DECODE(ra.rate_based_flag, 'Y', rac.txn_etc_burden_cost_rate, TO_NUMBER(NULL))
--              FROM pa_resource_assignments ra,
--  --                 pa_budget_lines bl,
--                   pa_resource_asgn_curr rac,
--                   pa_budget_versions bv,
--                   pa_proj_fp_options po
--              WHERE ra.resource_assignment_id = l_resource_assignment_id AND
--  --                  ra.resource_assignment_id = bl.resource_assignment_id AND
--  --                  bl.txn_currency_code = p_txn_currency_code AND
--                    ra.resource_assignment_id = rac.resource_assignment_id AND
--                    rac.txn_currency_code = p_txn_currency_code AND
--                    ra.budget_version_id = bv.budget_version_id AND
--                    bv.budget_version_id = po.fin_plan_version_id AND
--                    po.fin_plan_option_level_code = 'PLAN_VERSION';
--  --                  bl.start_date BETWEEN p_line_start_date AND p_line_end_date
--  /*
--              GROUP BY bl.resource_assignment_id,
--                       bl.txn_currency_code,
--                       ra.planning_start_date,
--                       ra.planning_end_date,
--  		     po.margin_derived_from_code,
--                       ra.schedule_start_date,
--                       ra.schedule_end_date,
--  		     po.fin_plan_preference_code;
--  */
-- End bug 6836806.

 -- ERROR HANDLING VARIABLES
 l_return_status      VARCHAR2(1);
 l_msg_count          NUMBER :=0;
 l_data               VARCHAR2(2000);
 l_msg_data           VARCHAR2(2000);
 l_error_msg_code     VARCHAR2(30);
 l_msg_index_out      NUMBER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if (p_budget_version_id is null) or (p_resource_assignment_id is null) then
    x_return_status := FND_API.G_RET_STS_ERROR;
    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_COMMONVO_ERROR');
  else
    x_budget_version_id := p_budget_version_id;
    -- NOTE: p_resource_assignment_id refers to the resource assignment for the
    -- CURRENT DISPLAYED budget version.  We need to figure out the resource
    -- assignment for the resource that correlates to p_budget_version_id

    -- get task_id and resource_list_member_id that we will need to match
    select ra.project_id,
           ra.task_id,
           ra.resource_list_member_id,
           ra.unit_of_measure
      into l_project_id,
           l_task_id,
           l_resource_list_member_id,
           l_unit_of_measure
      from pa_resource_assignments ra
      where ra.resource_assignment_id = p_resource_assignment_id;
    open raid_csr;
    fetch raid_csr into raid_rec;
    if raid_csr%NOTFOUND then
      -- no match found: return null for all attribute values
      x_planning_start_date   := null;
      x_planning_end_date := null;
      x_schedule_start_date := null;
      x_schedule_end_date := null;
      x_quantity := null;
      x_revenue_txn_cur := null;
      x_revenue_proj_cur := null;
      x_revenue_proj_func_cur := null;
      x_raw_cost_txn_cur := null;
      x_raw_cost_proj_cur := null;
      x_raw_cost_proj_func_cur := null;
      x_burd_cost_txn_cur := null;
      x_burd_cost_proj_cur := null;
      x_burd_cost_proj_func_cur := null;
      x_init_rev_rate := null;
      x_avg_rev_rate := null;
      x_init_raw_cost_rate := null;
      x_avg_raw_cost_rate := null;
      x_init_burd_cost_rate := null;
      x_avg_burd_cost_rate := null;
      x_margin_txn_cur := null;
      x_margin_proj_cur := null;
      x_margin_proj_func_cur := null;
      x_margin_pct := null;
      x_etc_avg_rev_rate := null;
      x_etc_avg_raw_cost_rate := null;
      x_etc_avg_burd_cost_rate := null;

    else
      l_resource_assignment_id := raid_rec.resource_assignment_id;
      -- figure out whether or not budget lines exist for the planning element
      open budget_lines_csr;
      fetch budget_lines_csr into budget_lines_rec;
      if budget_lines_csr%NOTFOUND then
        l_budget_lines_exist_flag := 'N';
      else
        l_budget_lines_exist_flag := 'Y';
      end if;
      close budget_lines_csr;

      if l_budget_lines_exist_flag = 'N' then
        -- query pa_resource_assignments only
        x_init_rev_rate := null;
        x_avg_rev_rate := null;
        x_init_raw_cost_rate := null;
        x_avg_raw_cost_rate := null;
        x_init_burd_cost_rate := null;
        x_avg_burd_cost_rate := null;
        -- bug 3979904: query pa_resource_assignments only if p_txn_currency_code
        -- is the same as project currency or project functional currency
        -- bug 4091886: if no budget lines exist for a particular task-res-currency
        -- combination, then even PC and PFC values should be nulled-out
        begin
        select ra.planning_start_date,  -- x_planning_start_date
               ra.planning_end_date,  -- x_planning_end_date
               ra.schedule_start_date, -- x_schedule_start_date
               ra.schedule_end_date,  -- x_schedule_end_date
               to_number(null), -- x_quantity
/*
               DECODE(p_txn_currency_code,
                      p_project_currency_code, ra.total_plan_quantity,
                      p_projfunc_currency_code, ra.total_plan_quantity,
                      to_number(null)),  -- x_quantity
*/
               to_number(null), -- x_revenue_txn_cur
/*
               DECODE(p_txn_currency_code,
                      p_project_currency_code, ra.total_project_revenue,
                      p_projfunc_currency_code, ra.total_plan_revenue,
                      to_number(null)),  -- x_revenue_txn_cur
*/
               to_number(null), /*ra.total_project_revenue,*/  -- x_revenue_proj_cur
               to_number(null), /*ra.total_plan_revenue,*/  -- x_revenue_proj_func_cur
               to_number(null), -- x_raw_cost_txn_cur
/*
               DECODE(p_txn_currency_code,
                      p_project_currency_code, ra.total_project_raw_cost,
                      p_projfunc_currency_code, ra.total_plan_raw_cost,
                      to_number(null)),  -- x_raw_cost_txn_cur
*/
               to_number(null), /*ra.total_project_raw_cost,*/  -- x_raw_cost_proj_cur
               to_number(null), /*ra.total_plan_raw_cost,*/  -- x_raw_cost_proj_func_cur
               to_number(null), -- x_burd_cost_txn_cur
/*
               DECODE(p_txn_currency_code,
                      p_project_currency_code, ra.total_project_burdened_cost,
                      p_projfunc_currency_code, ra.total_plan_burdened_cost,
                      to_number(null)), -- x_burd_cost_txn_cur
*/
               to_number(null), /*ra.total_project_burdened_cost,*/  -- x_burd_cost_proj_cur
               to_number(null), /*ra.total_plan_burdened_cost,*/  -- x_burd_cost_proj_func_cur
               to_number(null), -- x_margin_txn_cur
/*
               DECODE(p_txn_currency_code,
                      p_project_currency_code, DECODE(po.margin_derived_from_code,
                          'B', ra.total_project_revenue - ra.total_project_burdened_cost,
                          ra.total_project_revenue - ra.total_project_raw_cost),
                      p_projfunc_currency_code, DECODE(po.margin_derived_from_code,
                          'B', ra.total_plan_revenue - ra.total_plan_burdened_cost,
                          ra.total_plan_revenue - ra.total_plan_raw_cost),
                      to_number(null)),  -- x_margin_txn_cur
*/
               to_number(null),
/*               DECODE(po.margin_derived_from_code,
                   'B', ra.total_project_revenue - ra.total_project_burdened_cost,
                   ra.total_project_revenue - ra.total_project_raw_cost),  -- x_margin_proj_cur
*/
               to_number(null),
/*               DECODE(po.margin_derived_from_code,
                 'B', ra.total_plan_revenue - ra.total_plan_burdened_cost,
                 ra.total_plan_revenue - ra.total_plan_raw_cost),  -- x_margin_proj_func_cur
*/
	       DECODE(po.fin_plan_preference_code,
	              'COST_ONLY', to_number(null),
		      'REVENUE_ONLY', to_number(null),
                      DECODE(nvl(ra.total_project_revenue,0),
                             0, 0,
                             DECODE(po.margin_derived_from_code,
                             'B', 100*(ra.total_project_revenue - ra.total_project_burdened_cost)/ra.total_project_revenue,
                             100*(ra.total_project_revenue - ra.total_project_raw_cost)/ra.total_project_revenue)))  -- x_margin_pct
          into x_planning_start_date,
               x_planning_end_date,
               x_schedule_start_date,
               x_schedule_end_date,
               x_quantity,
               x_revenue_txn_cur,
               x_revenue_proj_cur,
               x_revenue_proj_func_cur,
               x_raw_cost_txn_cur,
               x_raw_cost_proj_cur,
               x_raw_cost_proj_func_cur,
               x_burd_cost_txn_cur,
               x_burd_cost_proj_cur,
               x_burd_cost_proj_func_cur,
               x_margin_txn_cur,
               x_margin_proj_cur,
               x_margin_proj_func_cur,
               x_margin_pct
          from pa_resource_assignments ra,
               pa_budget_versions bv,
               pa_proj_fp_options po
          where ra.resource_assignment_id = l_resource_assignment_id and
                ra.budget_version_id = bv.budget_version_id and
                bv.budget_version_id = po.fin_plan_version_id and
                po.fin_plan_option_level_code = 'PLAN_VERSION';
       exception
            when NO_DATA_FOUND then
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := 1;
              x_msg_data := SQLERRM;
              FND_MSG_PUB.add_exc_msg(p_pkg_name       => 'PA_PLANNING_ELEMENT_UTILS',
                                      p_procedure_name => 'get_common_budget_version_info');
        end;
      else
        -- budget lines exist, so query pa_resource_assignment and pa_budget_lines
        -- Bug Fix 3732157.
        -- Budget lines cursor is not considering the dates while checking the
        -- lines existence. While fetching the data within a certain date range
        -- is failing as the lines doesnt exist in that range.
        -- Making this as a cursor to get rid of the no data found exception
        -- and if cursor not found then we initialize all the out vars to null.

        IF p_line_start_date IS NOT NULL AND p_line_end_date IS NOT NULL THEN

        OPEN get_budget_line_amts_for_dates;
        FETCH get_budget_line_amts_for_dates INTO
                 x_planning_start_date,
                 x_planning_end_date,
                 x_schedule_start_date,
                 x_schedule_end_date,
                 x_quantity,
                 x_revenue_txn_cur,
                 x_revenue_proj_cur,
                 x_revenue_proj_func_cur,
                 x_raw_cost_txn_cur,
                 x_raw_cost_proj_cur,
                 x_raw_cost_proj_func_cur,
                 x_burd_cost_txn_cur,
                 x_burd_cost_proj_cur,
                 x_burd_cost_proj_func_cur,
                 x_init_rev_rate,
                 x_avg_rev_rate,
                 x_init_raw_cost_rate,
                 x_avg_raw_cost_rate,
                 x_init_burd_cost_rate,
                 x_avg_burd_cost_rate,
                 x_margin_txn_cur,
                 x_margin_proj_cur,
                 x_margin_proj_func_cur,
                 x_margin_pct,
		 x_etc_avg_rev_rate,
		 x_etc_avg_raw_cost_rate,
		 x_etc_avg_burd_cost_rate;

        IF get_budget_line_amts_for_dates%NOTFOUND THEN

              x_planning_start_date   := null;
      	      x_planning_end_date := null;
              x_schedule_start_date := null;
              x_schedule_end_date := null;
              x_quantity := null;
              x_revenue_txn_cur := null;
              x_revenue_proj_cur := null;
              x_revenue_proj_func_cur := null;
              x_raw_cost_txn_cur := null;
              x_raw_cost_proj_cur := null;
              x_raw_cost_proj_func_cur := null;
              x_burd_cost_txn_cur := null;
              x_burd_cost_proj_cur := null;
              x_burd_cost_proj_func_cur := null;
              x_init_rev_rate := null;
              x_avg_rev_rate := null;
              x_init_raw_cost_rate := null;
              x_avg_raw_cost_rate := null;
              x_init_burd_cost_rate := null;
              x_avg_burd_cost_rate := null;
              x_margin_txn_cur := null;
              x_margin_proj_cur := null;
              x_margin_proj_func_cur := null;
              x_margin_pct := null;
	      x_etc_avg_rev_rate := null;
	      x_etc_avg_raw_cost_rate := null;
	      x_etc_avg_burd_cost_rate := null;

        END IF;

        CLOSE get_budget_line_amts_for_dates;

        ELSE -- p_line_start_date IS NULL AND/OR p_line_end_date IS NULL THEN

          SELECT ra.planning_start_date,
                 ra.planning_end_date,
                 ra.schedule_start_date,
                 ra.schedule_end_date,
                 rac.total_display_quantity,
                 rac.total_txn_revenue,
                 rac.total_project_revenue, --ra.total_project_revenue,
                 rac.total_projfunc_revenue,         --ra.total_plan_revenue,
                 rac.total_txn_raw_cost,
                 rac.total_project_raw_cost, --ra.total_project_raw_cost,
                 rac.total_projfunc_raw_cost,         --ra.total_plan_raw_cost,
                 rac.total_txn_burdened_cost,
                 rac.total_project_burdened_cost, --ra.total_project_burdened_cost,
                 rac.total_projfunc_burdened_cost,         --ra.total_plan_burdened_cost,
/*
                 SUM(bl.quantity),
                 SUM(bl.txn_revenue),
                 SUM(bl.project_revenue), --ra.total_project_revenue,
                 SUM(bl.revenue),         --ra.total_plan_revenue,
                 SUM(bl.txn_raw_cost),
                 SUM(bl.project_raw_cost), --ra.total_project_raw_cost,
                 SUM(bl.raw_cost),         --ra.total_plan_raw_cost,
                 SUM(bl.txn_burdened_cost),
                 SUM(bl.project_burdened_cost), --ra.total_project_burdened_cost,
                 SUM(bl.burdened_cost),         --ra.total_plan_burdened_cost,
*/
                 NULL,  -- x_init_rev_rate (TO BE CALCULATED)
                 --AVG(nvl(bl.txn_bill_rate_override,bl.txn_standard_bill_rate)),
/*
		 DECODE(SUM(bl.quantity),
			0, 0,
			NULL, NULL,
			SUM(bl.txn_revenue)/SUM(bl.quantity)),
*/
         DECODE(ra.rate_based_flag, 'Y', rac.txn_average_bill_rate, TO_NUMBER(NULL)),
                 NULL,  -- x_init_raw_cost_rate (TO BE CALCULATED)
                 --AVG(nvl(bl.txn_cost_rate_override,bl.txn_standard_cost_rate)),
/*
		 DECODE(SUM(bl.quantity),
			0, 0,
			NULL, NULL,
			SUM(bl.txn_raw_cost)/SUM(bl.quantity)),
*/
         DECODE(ra.rate_based_flag, 'Y', rac.txn_average_raw_cost_rate, TO_NUMBER(NULL)),
                 NULL,  -- x_init_burd_cost_rate (TO BE CALCULATED)
                 --AVG(nvl(bl.burden_cost_rate_override,bl.burden_cost_rate)),
/*
		 DECODE(SUM(bl.quantity),
			0, 0,
			NULL, NULL,
			SUM(bl.txn_burdened_cost)/SUM(bl.quantity)),
*/
         DECODE(ra.rate_based_flag, 'Y', rac.txn_average_burden_cost_rate, TO_NUMBER(NULL)),
		 DECODE(po.fin_plan_preference_code,
                        'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
                 	 DECODE(po.margin_derived_from_code,
--                                'B', SUM(bl.txn_revenue) - SUM(bl.txn_burdened_cost),
--                                SUM(bl.txn_revenue) - SUM(bl.txn_raw_cost))),
                                'B', rac.total_txn_revenue - rac.total_txn_burdened_cost,
                                rac.total_txn_revenue - rac.total_txn_raw_cost)),
		 DECODE(po.fin_plan_preference_code,
			'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
	                 DECODE(po.margin_derived_from_code,
--                   	        'B', SUM(bl.project_revenue) - SUM(bl.project_burdened_cost),
--                                SUM(bl.project_revenue) - SUM(bl.project_raw_cost))),
                   	        'B', rac.total_project_revenue - rac.total_project_burdened_cost,
                                rac.total_project_revenue - rac.total_project_raw_cost)),
		 DECODE(po.fin_plan_preference_code,
			'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
	                 DECODE(po.margin_derived_from_code,
--        	                'B', SUM(bl.reve nue) - SUM(bl.burdened_cost),
--                                SUM(bl.revenue) - SUM(bl.raw_cost))),
       	                'B', rac.total_projfunc_revenue - rac.total_projfunc_burdened_cost,
                                rac.total_projfunc_revenue - rac.total_projfunc_raw_cost)),
			 DECODE(po.fin_plan_preference_code,
			'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
--	                 DECODE(SUM(bl.project_revenue),
	                 DECODE(rac.total_project_revenue,
        	                0, 0,
                   		NULL, TO_NUMBER(NULL),
                   		DECODE(po.margin_derived_from_code,
--                     		       'B', 100*(SUM(bl.project_revenue) - SUM(bl.project_burdened_cost))/SUM(bl.project_revenue),
--                     			100*(SUM(bl.project_revenue) - SUM(bl.project_raw_cost)))/SUM(bl.project_revenue))),
                     		       'B', 100*(rac.total_project_revenue - rac.total_project_burdened_cost)/rac.total_project_revenue,
                     			100*(rac.total_project_revenue - rac.total_project_raw_cost)/rac.total_project_revenue))),
/*
		 DECODE(SUM(bl.quantity) - SUM(NVL(bl.init_quantity,0)),
                         0, 0,
                         NULL, 0,
                         (SUM(bl.txn_revenue) - SUM(NVL(bl.txn_init_revenue,0)))/(SUM(bl.quantity) - SUM(NVL(bl.init_quantity,0)))),
*/
         DECODE(ra.rate_based_flag, 'Y', rac.txn_etc_bill_rate, TO_NUMBER(NULL)),
/*
		 DECODE(SUM(bl.quantity) - SUM(NVL(init_quantity,0)),
                         0, 0,
                         NULL, 0,
                         (SUM(bl.txn_raw_cost) - SUM(NVL(bl.txn_init_raw_cost,0)))/(SUM(bl.quantity) - SUM(NVL(init_quantity,0)))),
*/
         DECODE(ra.rate_based_flag, 'Y', rac.txn_etc_raw_cost_rate, TO_NUMBER(NULL)),
/*
		 DECODE(SUM(bl.quantity) - SUM(NVL(init_quantity,0)),
                         0, 0,
                         NULL, 0,
                         (SUM(bl.txn_burdened_cost) - SUM(NVL(bl.txn_init_burdened_cost,0)))/(SUM(bl.quantity) - SUM(NVL(init_quantity,0))))
*/
         DECODE(ra.rate_based_flag, 'Y', rac.txn_etc_burden_cost_rate, TO_NUMBER(NULL))
            INTO x_planning_start_date,
                 x_planning_end_date,
                 x_schedule_start_date,
                 x_schedule_end_date,
                 x_quantity,
                 x_revenue_txn_cur,
                 x_revenue_proj_cur,
                 x_revenue_proj_func_cur,
                 x_raw_cost_txn_cur,
                 x_raw_cost_proj_cur,
                 x_raw_cost_proj_func_cur,
                 x_burd_cost_txn_cur,
                 x_burd_cost_proj_cur,
                 x_burd_cost_proj_func_cur,
                 x_init_rev_rate,
                 x_avg_rev_rate,
                 x_init_raw_cost_rate,
                 x_avg_raw_cost_rate,
                 x_init_burd_cost_rate,
                 x_avg_burd_cost_rate,
                 x_margin_txn_cur,
                 x_margin_proj_cur,
                 x_margin_proj_func_cur,
                 x_margin_pct,
                 x_etc_avg_rev_rate,
                 x_etc_avg_raw_cost_rate,
                 x_etc_avg_burd_cost_rate
            FROM pa_resource_assignments ra,
--                 pa_budget_lines bl,
                 pa_resource_asgn_curr rac,
                 pa_budget_versions bv,
                 pa_proj_fp_options po
            WHERE ra.resource_assignment_id = l_resource_assignment_id AND
--                  ra.resource_assignment_id = bl.resource_assignment_id AND
--                  bl.txn_currency_code = p_txn_currency_code AND
                  rac.resource_assignment_id = ra.resource_assignment_id AND
                  rac.txn_currency_code = p_txn_currency_code AND
                  ra.budget_version_id = bv.budget_version_id AND
                  bv.budget_version_id = po.fin_plan_version_id AND
                  po.fin_plan_option_level_code = 'PLAN_VERSION';
/*
            GROUP BY bl.resource_assignment_id,
                     bl.txn_currency_code,
                     ra.planning_start_date,
                     ra.planning_end_date,
                     ra.schedule_start_date,
                     ra.schedule_end_date,
                     --ra.total_project_revenue,
                     --ra.total_plan_revenue,
                     --ra.total_project_raw_cost,
                     --ra.total_plan_raw_cost,
                     --ra.total_project_burdened_cost,
                     --ra.total_plan_burdened_cost,
		     po.margin_derived_from_code,
		     po.fin_plan_preference_code;
*/


        END IF; --  p_line_start_date IS NOT NULL AND p_line_end_date IS NOT NULL
	  -- CALCULATE THE AVG RATES
	  pa_planning_element_utils.get_initial_budget_line_info
	  (p_resource_assignment_id	=> p_resource_assignment_id,
	   p_txn_currency_code		=> p_txn_currency_code,
           p_line_start_date            => p_line_start_date,
           p_line_end_date              => p_line_end_date,
	   x_start_date			=> l_start_date,
	   x_end_date			=> l_end_date,
	   x_period_name		=> l_period_name,
	   x_quantity			=> l_quantity,
	   x_txn_raw_cost		=> l_txn_raw_cost,
	   x_txn_burdened_cost		=> l_txn_burdened_cost,
	   x_txn_revenue		=> l_txn_revenue,
	   x_init_quantity		=> l_init_quantity,
	   x_txn_init_raw_cost		=> l_txn_init_raw_cost,
	   x_txn_init_burdened_cost	=> l_txn_init_burdened_cost,
	   x_txn_init_revenue		=> l_txn_init_revenue,
	   x_init_raw_cost_rate		=> l_init_raw_cost_rate,
	   x_init_burd_cost_rate	=> l_init_burd_cost_rate,
	   x_init_revenue_rate		=> l_init_revenue_rate,
	   x_etc_init_raw_cost_rate     => l_etc_init_raw_cost_rate,
	   x_etc_init_burd_cost_rate	=> l_etc_init_burd_cost_rate,
	   x_etc_init_revenue_rate	=> l_etc_init_revenue_rate,
	   x_return_status		=> l_return_status,
	   x_msg_count			=> l_msg_count,
	   x_msg_data			=> l_msg_data);

          x_init_rev_rate := l_init_revenue_rate;
          x_init_raw_cost_rate := l_init_raw_cost_rate;
          x_init_burd_cost_rate := l_init_burd_cost_rate;

      end if;
    end if;
  end if; -- if l_resource_assignment_id found
  close raid_csr;

  -- Check message stack for error messages
  if x_return_status <> FND_API.G_RET_STS_SUCCESS then
    l_msg_count := FND_MSG_PUB.count_msg;
    if l_msg_count = 1 THEN
       PA_INTERFACE_UTILS_PUB.get_messages
             (p_encoded        => FND_API.G_TRUE
             ,p_msg_index      => 1
             ,p_msg_count      => l_msg_count
             ,p_msg_data       => l_msg_data
             ,p_data           => l_data
             ,p_msg_index_out  => l_msg_index_out);
       x_msg_data := l_data;
       x_msg_count := l_msg_count;
    else
      x_msg_count := l_msg_count;
    end if;
  end if;
EXCEPTION
    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG (p_pkg_name       => 'PA_PLANNING_ELEMENT_UTILS',
                               p_procedure_name => 'get_common_budget_version_info');
      x_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data          := SQLERRM;
END get_common_budget_version_info;


/*
 * REVISION HISTORY:
 * 07/08/2004 - dlai - added the following input parameters so ETC rates can
 *            be displayed for baselined and latest published versions (Task
 *            Assignments):    x_etc_avg_rev_rate, x_etc_avg_raw_cost_rate,
 *            x_etc_avg_burd_cost_rate
 * 07/15/2004 - dlai - added the following output parameters for bug 3622609:
 *            x_schedule_start_date, x_schedule_end_date
 * 12/10/2004 - dlai - when no budget lines exist for a particular
 *            txn_currency_code (which is not proj or projfunc currency), be
 *            sure to return null for txn amounts, and not rely on the amounts in
 *            pa_resource_assignments
 * 12/19/2004 removed all references to pa_resource_assignments.init columns
 * 02/08/2005 - dlai - when looking for match, the records should also have
 *            the same unit_of_measure in addition to task-res-txncurrency
 * 05/10/2005 - dlai - margin parameters are returned as null if
 *            p_budget_version_id refers to COST_ONLY or REVENUE_ONLY version
 * 06/02/2005 - dlai - queries for etc amounts should use nvl(..,0) so that they
 *            are calculate correctly in case the act or fcst amounts are null
 */
PROCEDURE get_common_bv_info_fcst
  (p_budget_version_id       IN  pa_budget_versions.budget_version_id%TYPE,
   p_resource_assignment_id  IN  pa_resource_assignments.resource_assignment_id%TYPE,
   p_project_currency_code   IN  pa_projects_all.project_currency_code%TYPE,
   p_projfunc_currency_code  IN  pa_projects_all.projfunc_currency_code%TYPE,
   p_txn_currency_code       IN  pa_budget_lines.txn_currency_code%TYPE,
   p_line_start_date         IN  pa_budget_lines.start_date%TYPE := to_date(NULL),
   p_line_end_date           IN  pa_budget_lines.end_date%TYPE := to_date(NULL),
   x_budget_version_id       OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_planning_start_date     OUT NOCOPY pa_resource_assignments.planning_start_date%TYPE, --File.Sql.39 bug 4440895
   x_planning_end_date       OUT NOCOPY pa_resource_assignments.planning_end_date%TYPE, --File.Sql.39 bug 4440895
   x_schedule_start_date     OUT NOCOPY pa_resource_assignments.schedule_start_date%TYPE, --File.Sql.39 bug 4440895
   x_schedule_end_date	     OUT NOCOPY pa_resource_assignments.schedule_start_date%TYPE, --File.Sql.39 bug 4440895
   x_act_quantity            OUT NOCOPY pa_resource_assignments.total_plan_quantity%TYPE, --File.Sql.39 bug 4440895
   x_etc_quantity            OUT NOCOPY pa_resource_assignments.total_plan_quantity%TYPE, --File.Sql.39 bug 4440895
   x_fcst_quantity           OUT NOCOPY pa_resource_assignments.total_plan_quantity%TYPE, --File.Sql.39 bug 4440895
   x_act_revenue_txn_cur         OUT NOCOPY pa_budget_lines.txn_revenue%TYPE, --File.Sql.39 bug 4440895
   x_act_revenue_proj_cur        OUT NOCOPY pa_resource_assignments.total_project_revenue%TYPE, --File.Sql.39 bug 4440895
   x_act_revenue_proj_func_cur   OUT NOCOPY pa_resource_assignments.total_plan_revenue%TYPE, --File.Sql.39 bug 4440895
   x_etc_revenue_txn_cur         OUT NOCOPY pa_budget_lines.txn_revenue%TYPE, --File.Sql.39 bug 4440895
   x_etc_revenue_proj_cur        OUT NOCOPY pa_resource_assignments.total_project_revenue%TYPE, --File.Sql.39 bug 4440895
   x_etc_revenue_proj_func_cur   OUT NOCOPY pa_resource_assignments.total_plan_revenue%TYPE, --File.Sql.39 bug 4440895
   x_fcst_revenue_txn_cur         OUT NOCOPY pa_budget_lines.txn_revenue%TYPE, --File.Sql.39 bug 4440895
   x_fcst_revenue_proj_cur        OUT NOCOPY pa_resource_assignments.total_project_revenue%TYPE, --File.Sql.39 bug 4440895
   x_fcst_revenue_proj_func_cur   OUT NOCOPY pa_resource_assignments.total_plan_revenue%TYPE, --File.Sql.39 bug 4440895
   x_act_raw_cost_txn_cur        OUT NOCOPY pa_budget_lines.txn_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_act_raw_cost_proj_cur       OUT NOCOPY pa_resource_assignments.total_project_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_act_raw_cost_proj_func_cur  OUT NOCOPY pa_resource_assignments.total_plan_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_etc_raw_cost_txn_cur        OUT NOCOPY pa_budget_lines.txn_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_etc_raw_cost_proj_cur       OUT NOCOPY pa_resource_assignments.total_project_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_etc_raw_cost_proj_func_cur  OUT NOCOPY pa_resource_assignments.total_plan_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_fcst_raw_cost_txn_cur        OUT NOCOPY pa_budget_lines.txn_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_fcst_raw_cost_proj_cur       OUT NOCOPY pa_resource_assignments.total_project_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_fcst_raw_cost_proj_func_cur  OUT NOCOPY pa_resource_assignments.total_plan_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_act_burd_cost_txn_cur       OUT NOCOPY pa_budget_lines.txn_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_act_burd_cost_proj_cur      OUT NOCOPY pa_resource_assignments.total_project_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_act_burd_cost_proj_func_cur OUT NOCOPY pa_resource_assignments.total_plan_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_etc_burd_cost_txn_cur       OUT NOCOPY pa_budget_lines.txn_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_etc_burd_cost_proj_cur      OUT NOCOPY pa_resource_assignments.total_project_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_etc_burd_cost_proj_func_cur OUT NOCOPY pa_resource_assignments.total_plan_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_fcst_burd_cost_txn_cur       OUT NOCOPY pa_budget_lines.txn_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_fcst_burd_cost_proj_cur      OUT NOCOPY pa_resource_assignments.total_project_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_fcst_burd_cost_proj_func_cur OUT NOCOPY pa_resource_assignments.total_plan_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_act_rev_rate           OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_init_rev_rate           OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_avg_rev_rate            OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_act_raw_cost_rate      OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_init_raw_cost_rate      OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_avg_raw_cost_rate       OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_act_burd_cost_rate     OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_init_burd_cost_rate     OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_avg_burd_cost_rate      OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_act_margin_txn_cur          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_act_margin_proj_cur         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_act_margin_proj_func_cur    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_margin_txn_cur          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_margin_proj_cur         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_margin_proj_func_cur    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_fcst_margin_txn_cur          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_fcst_margin_proj_cur         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_fcst_margin_proj_func_cur    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_act_margin_pct              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_margin_pct              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_fcst_margin_pct              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

 l_project_id                 pa_resource_assignments.project_id%TYPE;
 l_task_id		      pa_resource_assignments.task_id%TYPE;
 l_resource_list_member_id    pa_resource_assignments.resource_list_member_id%TYPE;
 l_resource_assignment_id     pa_resource_assignments.resource_assignment_id%TYPE;
 l_unit_of_measure            pa_resource_assignments.unit_of_measure%TYPE;
 l_margin_derived_from_code   pa_proj_fp_options.margin_derived_from_code%TYPE;

 l_budget_lines_exist_flag    VARCHAR2(1);  -- whether budget lines exist for planning element

 l_start_date		      pa_budget_lines.start_date%TYPE;
 l_end_date		      pa_budget_lines.end_date%TYPE;
 l_period_name		      pa_budget_lines.period_name%TYPE;
 l_quantity		      pa_budget_lines.quantity%TYPE;
 l_txn_raw_cost		      pa_budget_lines.raw_cost%TYPE;
 l_txn_burdened_cost	      pa_budget_lines.burdened_cost%TYPE;
 l_txn_revenue		      pa_budget_lines.revenue%TYPE;
 l_init_quantity	      pa_budget_lines.init_quantity%TYPE;
 l_txn_init_raw_cost	      pa_budget_lines.txn_init_raw_cost%TYPE;
 l_txn_init_burdened_cost     pa_budget_lines.txn_init_burdened_cost%TYPE;
 l_txn_init_revenue	      pa_budget_lines.txn_init_revenue%TYPE;
 l_init_raw_cost_rate	      NUMBER;
 l_init_burd_cost_rate	      NUMBER;
 l_init_revenue_rate	      NUMBER;
 l_etc_init_raw_cost_rate     NUMBER;
 l_etc_init_burd_cost_rate    NUMBER;
 l_etc_init_revenue_rate      NUMBER;

 cursor raid_csr is
   select ra.resource_assignment_id
     from pa_resource_assignments ra
     where ra.project_id = l_project_id and
           ra.budget_version_id = p_budget_version_id and
           ra.task_id = l_task_id and
           ra.resource_list_member_id = l_resource_list_member_id and
           ra.unit_of_measure = l_unit_of_measure;
 raid_rec raid_csr%ROWTYPE;

 cursor budget_lines_csr is
   select 'Y'
     from pa_budget_lines
     where resource_assignment_id = l_resource_assignment_id and
           txn_currency_code = p_txn_currency_code;
  budget_lines_rec budget_lines_csr%ROWTYPE;

 CURSOR get_fcst_line_amts_for_dates IS
           SELECT ra.planning_start_date,        -- x_planning_start_date
                 ra.planning_end_date,          -- x_planning_end_date
                 ra.schedule_start_date,        -- x_schedule_start_date
                 ra.schedule_end_date,          -- x_schedule_end_date
                 rac.total_init_quantity,         -- x_act_quantity
                 DECODE(ra.rate_based_flag, 'Y', NVL(rac.total_display_quantity,0) - NVL(rac.total_init_quantity,0), 0), -- x_etc_quantity, Bug 5726773
                 rac.total_display_quantity,        -- x_fcst_quantity
                 rac.total_txn_init_revenue,      -- x_act_revenue_txn_cur
                 rac.total_project_init_revenue,  -- x_act_revenue_proj_cur
                 rac.total_projfunc_init_revenue,          -- x_act_revenue_proj_func_cur
                 NVL(rac.total_txn_revenue,0) - NVL(rac.total_txn_init_revenue,0), -- x_etc_revenue_txn_cur
                 NVL(rac.total_project_revenue,0) - NVL(rac.total_project_init_revenue,0), -- x_etc_revenue_proj_cur
                 NVL(rac.total_projfunc_revenue,0) - NVL(rac.total_projfunc_init_revenue,0), -- x_etc_revenue_proj_func_cur
                 rac.total_txn_revenue,           -- x_fcst_revenue_txn_cur
                 rac.total_project_revenue,      -- x_fcst_revenue_proj_cur
                 rac.total_projfunc_revenue,         -- x_fcst_revenue_proj_func_cur
                 rac.total_txn_init_raw_cost,     -- x_act_raw_cost_txn_cur
                 rac.total_project_init_raw_cost, -- x_act_raw_cost_proj_cur
                 rac.total_projfunc_init_raw_cost,         -- x_act_raw_cost_proj_func_cur
                 NVL(rac.total_txn_raw_cost,0) - NVL(rac.total_txn_init_raw_cost,0), -- x_etc_raw_cost_txn_cur
                 NVL(rac.total_project_raw_cost,0) - NVL(rac.total_project_init_raw_cost,0),-- x_etc_raw_cost_proj_cur
                 NVL(rac.total_projfunc_raw_cost,0) - NVL(rac.total_projfunc_init_raw_cost,0),-- x_etc_raw_cost_proj_func_cur
                 rac.total_txn_raw_cost,           -- x_fcst_raw_cost_txn_cur
                 rac.total_project_raw_cost,      -- x_fcst_raw_cost_proj_cur
                 rac.total_projfunc_raw_cost,         -- x_fcst_raw_cost_proj_func_cur
                 rac.total_txn_init_burdened_cost,     -- x_act_burd_cost_txn_cur
                 rac.total_project_init_bd_cost, -- x_act_burd_cost_proj_cur
                 rac.total_projfunc_init_bd_cost,         -- x_act_burd_cost_proj_func_cur
                 NVL(rac.total_txn_burdened_cost,0) - NVL(rac.total_txn_init_burdened_cost,0), -- x_etc_burd_cost_txn_cur
                 NVL(rac.total_project_burdened_cost,0) - NVL(rac.total_project_init_bd_cost,0), -- x_etc_burd_cost_proj_cur
                 NVL(rac.total_projfunc_burdened_cost,0) - NVL(rac.total_projfunc_init_bd_cost,0), -- x_etc_burd_cost_proj_func_cur
                 rac.total_txn_burdened_cost,           -- x_fcst_burd_cost_txn_cur
                 rac.total_project_burdened_cost,      -- x_fcst_burd_cost_proj_cur
                 rac.total_projfunc_burdened_cost,         -- x_fcst_burd_cost_proj_func_cur
/*
                 SUM(bl.init_quantity),         -- x_act_quantity
                 SUM(NVL(bl.quantity,0)) - SUM(NVL(bl.init_quantity,0)), -- x_etc_quantity
                 SUM(bl.quantity),        -- x_fcst_quantity
                 SUM(txn_init_revenue),      -- x_act_revenue_txn_cur
                 SUM(bl.project_init_revenue),  -- x_act_revenue_proj_cur
                 SUM(bl.init_revenue),          -- x_act_revenue_proj_func_cur
                 SUM(NVL(bl.txn_revenue,0)) - SUM(NVL(bl.txn_init_revenue,0)), -- x_etc_revenue_txn_cur
                 SUM(NVL(bl.project_revenue,0)) - SUM(NVL(bl.project_init_revenue,0)), -- x_etc_revenue_proj_cur
                 SUM(NVL(bl.revenue,0)) - SUM(NVL(bl.init_revenue,0)), -- x_etc_revenue_proj_func_cur
                 SUM(bl.txn_revenue),           -- x_fcst_revenue_txn_cur
                 SUM(bl.project_revenue),      -- x_fcst_revenue_proj_cur
                 SUM(bl.revenue),         -- x_fcst_revenue_proj_func_cur
                 SUM(bl.txn_init_raw_cost),     -- x_act_raw_cost_txn_cur
                 SUM(bl.project_init_raw_cost), -- x_act_raw_cost_proj_cur
                 SUM(bl.init_raw_cost),         -- x_act_raw_cost_proj_func_cur
                 SUM(NVL(bl.txn_raw_cost,0)) - SUM(NVL(bl.txn_init_raw_cost,0)), -- x_etc_raw_cost_txn_cur
                 SUM(NVL(bl.project_raw_cost,0)) - SUM(NVL(bl.project_init_raw_cost,0)), -- x_etc_raw_cost_proj_cur
                 SUM(NVL(bl.raw_cost,0)) - SUM(NVL(bl.init_raw_cost,0)), -- x_etc_raw_cost_proj_func_cur
                 SUM(bl.txn_raw_cost),           -- x_fcst_raw_cost_txn_cur
                 SUM(bl.project_raw_cost),      -- x_fcst_raw_cost_proj_cur
                 SUM(bl.raw_cost),         -- x_fcst_raw_cost_proj_func_cur
                 SUM(bl.txn_init_burdened_cost),     -- x_act_burd_cost_txn_cur
                 SUM(bl.project_init_burdened_cost), -- x_act_burd_cost_proj_cur
                 SUM(bl.init_burdened_cost),         -- x_act_burd_cost_proj_func_cur
                 SUM(NVL(bl.txn_burdened_cost,0)) - SUM(NVL(bl.txn_init_burdened_cost,0)), -- x_etc_burd_cost_txn_cur
                 SUM(NVL(bl.project_burdened_cost,0)) - SUM(NVL(bl.project_init_burdened_cost,0)), -- x_etc_burd_cost_proj_cur
                 SUM(NVL(bl.burdened_cost,0)) - SUM(NVL(bl.init_burdened_cost,0)), -- x_etc_burd_cost_proj_func_cur
                 SUM(bl.txn_burdened_cost),           -- x_fcst_burd_cost_txn_cur
                 SUM(bl.project_burdened_cost),      -- x_fcst_burd_cost_proj_cur
                 SUM(bl.burdened_cost),         -- x_fcst_burd_cost_proj_func_cur
*/
                 NULL,                                -- x_act_rev_rate (TO BE CALCULATED)
                 NULL,                                -- x_etc_init_rev_rate (TO BE CALCULATED)
                 NULL,				    -- x_etc_avg_rev_rate (TO BE CALCULATED)
                 NULL,                                -- x_act_raw_cost_rate (TO BE CALCULATED)
                 NULL,                                -- x_etc_init_raw_cost_rate (TO BE CALCULATED)
                 NULL,                                -- x_etc_avg_raw_cost_rate (TO BE CALCULATED)
                 NULL,                                -- x_act_burd_cost_rate  (TO BE CALCULATED)
                 NULL,                                -- x_etc_init_burd_cost_rate (TO BE CALCULATED)
                 NULL,                                -- x_etc_avg_burd_cost_rate (TO BE CALCULATED)
		 DECODE(po.fin_plan_preference_code,
		 	'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
	                 DECODE(po.margin_derived_from_code,
--        	                'B', SUM(bl.txn_init_revenue) - SUM(bl.txn_init_burdened_cost),
--                	        SUM(bl.txn_init_revenue) - SUM(bl.txn_init_raw_cost))), -- x_act_margin_txn_cur
        	                'B', rac.total_txn_init_revenue - rac.total_txn_init_burdened_cost,
                	        rac.total_txn_init_revenue - rac.total_txn_init_raw_cost)), -- x_act_margin_txn_cur
		 DECODE(po.fin_plan_preference_code,
		 	'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
	                 DECODE(po.margin_derived_from_code,
--        	                'B', SUM(bl.project_init_revenue) - SUM(bl.project_init_burdened_cost),
--                	        SUM(bl.project_init_revenue) - SUM(bl.project_init_raw_cost))),  -- x_act_margin_proj_cur
        	                'B', rac.total_project_init_revenue - rac.total_project_init_bd_cost,
                	        rac.total_project_init_revenue - rac.total_project_init_raw_cost)),  -- x_act_margin_proj_cur
		 DECODE(po.fin_plan_preference_code,
		 	'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
	                 DECODE(po.margin_derived_from_code,
--        	                'B', SUM(bl.init_revenue) - SUM(bl.init_burdened_cost),
--                	        SUM(bl.init_revenue) - SUM(bl.init_raw_cost))),  -- x_act_margin_proj_func_cur
        	                'B', rac.total_projfunc_init_revenue - rac.total_projfunc_init_bd_cost,
                	        rac.total_projfunc_init_revenue - rac.total_projfunc_init_raw_cost)),  -- x_act_margin_proj_func_cur
                 NULL, -- x_etc_margin_txn_cur (TO BE POPULATED)
                 NULL, -- x_etc_margin_proj_cur (TO BE POPULATED)
                 NULL, -- x_etc_margin_proj_func_cur   (TO BE POPULATED)
		 DECODE(po.fin_plan_preference_code,
		 	'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
	                 DECODE(po.margin_derived_from_code,
--        	                'B', SUM(bl.txn_revenue) - SUM(bl.txn_burdened_cost),
--                	        SUM(bl.txn_revenue) - SUM(bl.txn_raw_cost))), -- x_fcst_margin_txn_cur
        	                'B', rac.total_txn_revenue - rac.total_txn_burdened_cost,
                	        rac.total_txn_revenue - rac.total_txn_raw_cost)), -- x_fcst_margin_txn_cur
		 DECODE(po.fin_plan_preference_code,
		 	'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
	                 DECODE(po.margin_derived_from_code,
--        	                'B', SUM(bl.project_revenue) - SUM(bl.project_burdened_cost),
--                	        SUM(bl.project_revenue) - SUM(bl.project_raw_cost))), -- x_fcst_margin_proj_cur
        	                'B', rac.total_project_revenue - rac.total_project_burdened_cost,
                	        rac.total_project_revenue - rac.total_project_raw_cost)), -- x_fcst_margin_proj_cur
		 DECODE(po.fin_plan_preference_code,
		 	'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
	                 DECODE(po.margin_derived_from_code,
--        	                'B', SUM(bl.revenue) - SUM(bl.burdened_cost),
--                	        SUM(bl.revenue) - SUM(bl.raw_cost))), -- x_fcst_margin_proj_func_cur
        	                'B', rac.total_projfunc_revenue - rac.total_projfunc_burdened_cost,
                	        rac.total_projfunc_revenue - rac.total_projfunc_raw_cost)), -- x_fcst_margin_proj_func_cur
                 NULL, -- x_act_margin_pct (TO BE POPULATED)
                 NULL, -- x_etc_margin_pct  (TO BE POPULATED)
                 NULL, -- x_fcst_margin_pct (TO BE POPULATED)
                 po.margin_derived_from_code
            FROM pa_resource_assignments ra,
--                 pa_budget_lines bl,
                 pa_resource_asgn_curr rac,
                 pa_budget_versions bv,
                 pa_proj_fp_options po
            WHERE ra.resource_assignment_id = l_resource_assignment_id AND
--                  ra.resource_assignment_id = bl.resource_assignment_id AND
--                  bl.txn_currency_code = p_txn_currency_code AND
                  ra.resource_assignment_id = rac.resource_assignment_id AND
                  rac.txn_currency_code =  p_txn_currency_code AND
                  ra.budget_version_id = bv.budget_version_id AND
                  bv.budget_version_id = po.fin_plan_version_id AND
                  po.fin_plan_option_level_code = 'PLAN_VERSION';
				  --AND bl.start_date BETWEEN p_line_start_date AND p_line_end_date
/*
            GROUP BY ra.transaction_source_code,
--                     ra.init_plan_quantity,
                     ra.total_plan_quantity,
		     bl.resource_assignment_id,
                     bl.txn_currency_code,
                     ra.planning_start_date,
                     ra.planning_end_date,
                     ra.schedule_start_date,
                     ra.schedule_end_date,
                     --ra.total_project_revenue,
                     --ra.total_plan_revenue,
                     --ra.total_project_raw_cost,
                     --ra.total_plan_raw_cost,
                     --ra.total_project_burdened_cost,
                     --ra.total_plan_burdened_cost,
		     po.margin_derived_from_code,
		     po.fin_plan_preference_code;
*/


 -- ERROR HANDLING VARIABLES
 l_return_status      VARCHAR2(1);
 l_msg_count          NUMBER :=0;
 l_data               VARCHAR2(2000);
 l_msg_data           VARCHAR2(2000);
 l_error_msg_code     VARCHAR2(30);
 l_msg_index_out      NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if (p_budget_version_id is null) or (p_resource_assignment_id is null) then
    x_return_status := FND_API.G_RET_STS_ERROR;
    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                         p_msg_name       => 'PA_FP_COMMONVO_ERROR');
  else
    x_budget_version_id := p_budget_version_id;
    -- NOTE: p_resource_assignment_id refers to the resource assignment for the
    -- CURRENT DISPLAYED budget version.  We need to figure out the resource
    -- assignment for the resource that correlates to p_budget_version_id

    -- get task_id and resource_list_member_id that we will need to match
    select ra.project_id,
           ra.task_id,
           ra.resource_list_member_id,
           ra.unit_of_measure
      into l_project_id,
           l_task_id,
           l_resource_list_member_id,
           l_unit_of_measure
      from pa_resource_assignments ra
      where ra.resource_assignment_id = p_resource_assignment_id;
    open raid_csr;
    fetch raid_csr into raid_rec;
    if raid_csr%NOTFOUND then
      -- no match found: return null for all attribute values
   x_budget_version_id          := null;
   x_planning_start_date        := null;
   x_planning_end_date          := null;
   x_schedule_start_date        := null;
   x_schedule_end_date          := null;
   x_act_quantity               := null;
   x_etc_quantity               := null;
   x_fcst_quantity              := null;
   x_act_revenue_txn_cur        := null;
   x_act_revenue_proj_cur       := null;
   x_act_revenue_proj_func_cur  := null;
   x_etc_revenue_txn_cur        := null;
   x_etc_revenue_proj_cur       := null;
   x_etc_revenue_proj_func_cur  := null;
   x_fcst_revenue_txn_cur       := null;
   x_fcst_revenue_proj_cur      := null;
   x_fcst_revenue_proj_func_cur := null;
   x_act_raw_cost_txn_cur       := null;
   x_act_raw_cost_proj_cur      := null;
   x_act_raw_cost_proj_func_cur := null;
   x_etc_raw_cost_txn_cur       := null;
   x_etc_raw_cost_proj_cur      := null;
   x_etc_raw_cost_proj_func_cur := null;
   x_fcst_raw_cost_txn_cur      := null;
   x_fcst_raw_cost_proj_cur     := null;
   x_fcst_raw_cost_proj_func_cur := null;
   x_act_burd_cost_txn_cur      := null;
   x_act_burd_cost_proj_cur     := null;
   x_act_burd_cost_proj_func_cur := null;
   x_etc_burd_cost_txn_cur      := null;
   x_etc_burd_cost_proj_cur     := null;
   x_etc_burd_cost_proj_func_cur := null;
   x_fcst_burd_cost_txn_cur     := null;
   x_fcst_burd_cost_proj_cur    := null;
   x_fcst_burd_cost_proj_func_cur := null;
   x_act_rev_rate               := null;
   x_etc_init_rev_rate          := null;
   x_etc_avg_rev_rate           := null;
   x_act_raw_cost_rate          := null;
   x_etc_init_raw_cost_rate     := null;
   x_etc_avg_raw_cost_rate      := null;
   x_act_burd_cost_rate         := null;
   x_etc_init_burd_cost_rate    := null;
   x_etc_avg_burd_cost_rate     := null;
   x_act_margin_txn_cur         := null;
   x_act_margin_proj_cur        := null;
   x_act_margin_proj_func_cur   := null;
   x_etc_margin_txn_cur         := null;
   x_etc_margin_proj_cur        := null;
   x_etc_margin_proj_func_cur   := null;
   x_fcst_margin_txn_cur        := null;
   x_fcst_margin_proj_cur       := null;
   x_fcst_margin_proj_func_cur  := null;
   x_act_margin_pct             := null;
   x_etc_margin_pct             := null;
   x_fcst_margin_pct            := null;

    else
      l_resource_assignment_id := raid_rec.resource_assignment_id;
      -- figure out whether or not budget lines exist for the planning element
      open budget_lines_csr;
      fetch budget_lines_csr into budget_lines_rec;
      if budget_lines_csr%NOTFOUND then
        l_budget_lines_exist_flag := 'N';
      else
        l_budget_lines_exist_flag := 'Y';
      end if;
      close budget_lines_csr;

      if l_budget_lines_exist_flag = 'N' then
        -- query pa_resource_assignments only
        -- bug 3979904: query pa_resource_assignments only if p_txn_currency_code
        -- is the same as project currency or project functional currency
        begin
        select ra.planning_start_date,        -- x_planning_start_date
               ra.planning_end_date,          -- x_planning_end_date
               ra.schedule_start_date,	      -- x_schedule_start_date
               ra.schedule_end_date,          -- x_schedule_end_date
               to_number(null),               -- x_act_quantity
               to_number(null),               -- x_etc_quantity
               to_number(null),               -- x_fcst_quantity
               to_number(null),               -- x_act_revenue_txn_cur
               to_number(null),               -- x_act_revenue_proj_cur
               to_number(null),               -- x_act_revenue_proj_func_cur
               to_number(null),               -- x_etc_revenue_txn_cur
               to_number(null),               -- x_etc_revenue_proj_cur
               to_number(null),               -- x_etc_revenue_proj_func_cur
               to_number(null),               -- x_fcst_revenue_txn_cur
               to_number(null),               -- x_fcst_revenue_proj_cur
               to_number(null),               -- x_fcst_revenue_proj_func_cur
               to_number(null),               -- x_act_raw_cost_txn_cur
               to_number(null),               -- x_act_raw_cost_proj_cur
               to_number(null),               -- x_act_raw_cost_proj_func_cur
               to_number(null),               -- x_etc_raw_cost_txn_cur
               to_number(null),               -- x_etc_raw_cost_proj_cur
               to_number(null),               -- x_etc_raw_cost_proj_func_cur
               to_number(null),               -- x_fcst_raw_cost_txn_cur
               to_number(null),               -- x_fcst_raw_cost_proj_cur
               to_number(null),               -- x_fcst_raw_cost_proj_func_cur
               to_number(null),               -- x_act_burd_cost_txn_cur
               to_number(null),               -- x_act_burd_cost_proj_cur
               to_number(null),               -- x_act_burd_cost_proj_func_cur
               to_number(null),               -- x_etc_burd_cost_txn_cur
               to_number(null),               -- x_etc_burd_cost_proj_cur
               to_number(null),               -- x_etc_burd_cost_proj_func_cur
               to_number(null),               -- x_fcst_burd_cost_txn_cur
               to_number(null),               -- x_fcst_burd_cost_proj_cur
               to_number(null),               -- x_fcst_burd_cost_proj_func_cur
               to_number(null),               -- x_act_rev_rate
               to_number(null),               -- x_etc_init_rev_rate
               to_number(null),		      -- x_etc_avg_rev_rate,
               to_number(null),               -- x_act_raw_cost_rate
               to_number(null),               -- x_etc_init_raw_cost_rate
               to_number(null),               -- x_etc_avg_raw_cost_rate
               to_number(null),               -- x_act_burd_cost_rate
               to_number(null),               -- x_etc_init_burd_cost_rate
               to_number(null),               -- x_etc_avg_burd_cost_rate
               to_number(null),               -- x_act_margin_txn_cur
               to_number(null),               -- x_act_margin_proj_cur
               to_number(null),               -- x_act_margin_proj_func_cur
               to_number(null),               -- x_etc_margin_txn_cur
               to_number(null),               -- x_etc_margin_proj_cur
               to_number(null),               -- x_etc_margin_proj_func_cur
               to_number(null),               -- x_fcst_margin_txn_cur
               to_number(null),               -- x_fcst_margin_proj_cur
               to_number(null),               -- x_fcst_margin_proj_func_cur
               to_number(null),               -- x_act_margin_pct
               to_number(null),               -- x_etc_margin_pct
               to_number(null),               -- x_fcst_margin_pct
               po.margin_derived_from_code
          into x_planning_start_date,
               x_planning_end_date,
               x_schedule_start_date,
               x_schedule_end_date,
               x_act_quantity,
               x_etc_quantity,
               x_fcst_quantity,
               x_act_revenue_txn_cur,
               x_act_revenue_proj_cur,
               x_act_revenue_proj_func_cur,
               x_etc_revenue_txn_cur,
               x_etc_revenue_proj_cur,
               x_etc_revenue_proj_func_cur,
               x_fcst_revenue_txn_cur,
               x_fcst_revenue_proj_cur,
               x_fcst_revenue_proj_func_cur,
               x_act_raw_cost_txn_cur,
               x_act_raw_cost_proj_cur,
               x_act_raw_cost_proj_func_cur,
               x_etc_raw_cost_txn_cur,
               x_etc_raw_cost_proj_cur,
               x_etc_raw_cost_proj_func_cur,
               x_fcst_raw_cost_txn_cur,
               x_fcst_raw_cost_proj_cur,
               x_fcst_raw_cost_proj_func_cur,
               x_act_burd_cost_txn_cur,
               x_act_burd_cost_proj_cur,
               x_act_burd_cost_proj_func_cur,
               x_etc_burd_cost_txn_cur,
               x_etc_burd_cost_proj_cur,
               x_etc_burd_cost_proj_func_cur,
               x_fcst_burd_cost_txn_cur,
               x_fcst_burd_cost_proj_cur,
               x_fcst_burd_cost_proj_func_cur,
               x_act_rev_rate,
               x_etc_init_rev_rate,
	       x_etc_avg_rev_rate,
               x_act_raw_cost_rate,
               x_etc_init_raw_cost_rate,
               x_etc_avg_raw_cost_rate,
               x_act_burd_cost_rate,
               x_etc_init_burd_cost_rate,
               x_etc_avg_burd_cost_rate,
               x_act_margin_txn_cur,
               x_act_margin_proj_cur,
               x_act_margin_proj_func_cur,
               x_etc_margin_txn_cur,
               x_etc_margin_proj_cur,
               x_etc_margin_proj_func_cur,
               x_fcst_margin_txn_cur,
               x_fcst_margin_proj_cur,
               x_fcst_margin_proj_func_cur,
               x_act_margin_pct,
               x_etc_margin_pct,
               x_fcst_margin_pct,
               l_margin_derived_from_code
          from pa_resource_assignments ra,
               pa_budget_versions bv,
               pa_proj_fp_options po
          where ra.resource_assignment_id = l_resource_assignment_id and
                ra.budget_version_id = bv.budget_version_id and
                bv.budget_version_id = po.fin_plan_version_id and
                po.fin_plan_option_level_code = 'PLAN_VERSION';
        exception
            when NO_DATA_FOUND then
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := 1;
              x_msg_data := SQLERRM;
              FND_MSG_PUB.add_exc_msg(p_pkg_name       => 'PA_PLANNING_ELEMENT_UTILS',
                                      p_procedure_name => 'get_common_budget_version_info');
        end;
        -- Calculate the remaining OUT parameters
        if l_margin_derived_from_code = 'B' then
        	x_etc_margin_txn_cur := x_etc_revenue_txn_cur - x_etc_burd_cost_txn_cur;
               	x_etc_margin_proj_cur := x_etc_revenue_txn_cur - x_etc_burd_cost_txn_cur;
                x_etc_margin_proj_func_cur := x_etc_revenue_txn_cur - x_etc_burd_cost_txn_cur;
        else
        	x_etc_margin_txn_cur := x_etc_revenue_txn_cur - x_etc_raw_cost_txn_cur;
               	x_etc_margin_proj_cur := x_etc_revenue_txn_cur - x_etc_raw_cost_txn_cur;
                x_etc_margin_proj_func_cur := x_etc_revenue_txn_cur - x_etc_raw_cost_txn_cur;
        end if; -- l_margin_derived_from_code
        if x_act_revenue_proj_cur is not null then
		if x_act_revenue_proj_cur = 0 then
		  x_act_margin_pct := 0;
		else
		  x_act_margin_pct := 100 * x_act_margin_proj_cur / x_act_revenue_proj_cur;
		end if; -- x_act_revenue_proj_cur = 0
        end if;
        if x_etc_revenue_proj_cur is not null then
		if x_etc_revenue_proj_cur = 0 then
		  x_etc_margin_pct := 0;
		else
		  x_etc_margin_pct := 100 * x_etc_margin_proj_cur / x_etc_revenue_proj_cur;
		end if; -- x_etc_revenue_proj_cur = 0
        end if;
        if x_fcst_revenue_proj_cur is not null then
		if x_fcst_revenue_proj_cur = 0 then
		  x_fcst_margin_pct := 0;
		else
		  x_fcst_margin_pct := 100 * x_fcst_margin_proj_cur / x_fcst_revenue_proj_cur;
		end if; -- x_fcst_revenue_proj_cur = 0
        end if;

      else
        -- budget lines exist, so query pa_resource_assignment and pa_budget_lines
        IF p_line_start_date IS NOT NULL AND p_line_end_date IS NOT NULL THEN

          OPEN get_fcst_line_amts_for_dates;
          FETCH get_fcst_line_amts_for_dates INTO
                 x_planning_start_date,
                 x_planning_end_date,
                 x_schedule_start_date,
                 x_schedule_end_date,
                 x_act_quantity,
                 x_etc_quantity,
                 x_fcst_quantity,
                 x_act_revenue_txn_cur,
                 x_act_revenue_proj_cur,
                 x_act_revenue_proj_func_cur,
                 x_etc_revenue_txn_cur,
                 x_etc_revenue_proj_cur,
                 x_etc_revenue_proj_func_cur,
                 x_fcst_revenue_txn_cur,
                 x_fcst_revenue_proj_cur,
                 x_fcst_revenue_proj_func_cur,
                 x_act_raw_cost_txn_cur,
                 x_act_raw_cost_proj_cur,
                 x_act_raw_cost_proj_func_cur,
                 x_etc_raw_cost_txn_cur,
                 x_etc_raw_cost_proj_cur,
                 x_etc_raw_cost_proj_func_cur,
                 x_fcst_raw_cost_txn_cur,
                 x_fcst_raw_cost_proj_cur,
                 x_fcst_raw_cost_proj_func_cur,
                 x_act_burd_cost_txn_cur,
                 x_act_burd_cost_proj_cur,
                 x_act_burd_cost_proj_func_cur,
                 x_etc_burd_cost_txn_cur,
                 x_etc_burd_cost_proj_cur,
                 x_etc_burd_cost_proj_func_cur,
                 x_fcst_burd_cost_txn_cur,
                 x_fcst_burd_cost_proj_cur,
                 x_fcst_burd_cost_proj_func_cur,
                 x_act_rev_rate,
                 x_etc_init_rev_rate,
	         x_etc_avg_rev_rate,
                 x_act_raw_cost_rate,
                 x_etc_init_raw_cost_rate,
                 x_etc_avg_raw_cost_rate,
                 x_act_burd_cost_rate,
                 x_etc_init_burd_cost_rate,
                 x_etc_avg_burd_cost_rate,
                 x_act_margin_txn_cur,
                 x_act_margin_proj_cur,
                 x_act_margin_proj_func_cur,
                 x_etc_margin_txn_cur,
                 x_etc_margin_proj_cur,
                 x_etc_margin_proj_func_cur,
                 x_fcst_margin_txn_cur,
                 x_fcst_margin_proj_cur,
                 x_fcst_margin_proj_func_cur,
                 x_act_margin_pct,
                 x_etc_margin_pct,
                 x_fcst_margin_pct,
                 l_margin_derived_from_code;

        IF get_fcst_line_amts_for_dates%NOTFOUND THEN
                 x_planning_start_date := null;
                 x_planning_end_date := null;
                 x_schedule_start_date := null;
                 x_schedule_end_date := null;
                 x_act_quantity := null;
                 x_etc_quantity := null;
                 x_fcst_quantity := null;
                 x_act_revenue_txn_cur := null;
                 x_act_revenue_proj_cur := null;
                 x_act_revenue_proj_func_cur := null;
                 x_etc_revenue_txn_cur := null;
                 x_etc_revenue_proj_cur := null;
                 x_etc_revenue_proj_func_cur := null;
                 x_fcst_revenue_txn_cur := null;
                 x_fcst_revenue_proj_cur := null;
                 x_fcst_revenue_proj_func_cur := null;
                 x_act_raw_cost_txn_cur := null;
                 x_act_raw_cost_proj_cur := null;
                 x_act_raw_cost_proj_func_cur := null;
                 x_etc_raw_cost_txn_cur := null;
                 x_etc_raw_cost_proj_cur := null;
                 x_etc_raw_cost_proj_func_cur := null;
                 x_fcst_raw_cost_txn_cur := null;
                 x_fcst_raw_cost_proj_cur := null;
                 x_fcst_raw_cost_proj_func_cur := null;
                 x_act_burd_cost_txn_cur := null;
                 x_act_burd_cost_proj_cur := null;
                 x_act_burd_cost_proj_func_cur := null;
                 x_etc_burd_cost_txn_cur := null;
                 x_etc_burd_cost_proj_cur := null;
                 x_etc_burd_cost_proj_func_cur := null;
                 x_fcst_burd_cost_txn_cur := null;
                 x_fcst_burd_cost_proj_cur := null;
                 x_fcst_burd_cost_proj_func_cur := null;
                 x_act_rev_rate := null;
                 x_etc_init_rev_rate := null;
	         x_etc_avg_rev_rate := null;
                 x_act_raw_cost_rate := null;
                 x_etc_init_raw_cost_rate := null;
                 x_etc_avg_raw_cost_rate := null;
                 x_act_burd_cost_rate := null;
                 x_etc_init_burd_cost_rate := null;
                 x_etc_avg_burd_cost_rate := null;
                 x_act_margin_txn_cur := null;
                 x_act_margin_proj_cur := null;
                 x_act_margin_proj_func_cur := null;
                 x_etc_margin_txn_cur := null;
                 x_etc_margin_proj_cur := null;
                 x_etc_margin_proj_func_cur := null;
                 x_fcst_margin_txn_cur := null;
                 x_fcst_margin_proj_cur := null;
                 x_fcst_margin_proj_func_cur := null;
                 x_act_margin_pct := null;
                 x_etc_margin_pct := null;
                 x_fcst_margin_pct := null;
                 l_margin_derived_from_code := null;
          END IF;

          CLOSE get_fcst_line_amts_for_dates;

        ELSE --p_line_start_date IS NULL AND/OR p_line_end_date IS NULL THEN
          SELECT ra.planning_start_date,        -- x_planning_start_date
                 ra.planning_end_date,          -- x_planning_end_date
                 ra.schedule_start_date,        -- x_schedule_start_date
                 ra.schedule_end_date,          -- x_schedule_end_date
                 rac.total_init_quantity,         -- x_act_quantity
                 DECODE(ra.rate_based_flag, 'Y', NVL(rac.total_display_quantity,0) - NVL(rac.total_init_quantity,0), 0), -- x_etc_quantity, Bug 5726773
                 rac.total_display_quantity,        -- x_fcst_quantity
                 rac.total_txn_init_revenue,      -- x_act_revenue_txn_cur
                 rac.total_project_init_revenue,  -- x_act_revenue_proj_cur
                 rac.total_projfunc_init_revenue,          -- x_act_revenue_proj_func_cur
                 NVL(rac.total_txn_revenue,0) - NVL(rac.total_txn_init_revenue,0), -- x_etc_revenue_txn_cur
                 NVL(rac.total_project_revenue,0) - NVL(rac.total_project_init_revenue,0), -- x_etc_revenue_proj_cur
                 NVL(rac.total_projfunc_revenue,0) - NVL(rac.total_projfunc_init_revenue,0), -- x_etc_revenue_proj_func_cur
                 rac.total_txn_revenue,           -- x_fcst_revenue_txn_cur
                 rac.total_project_revenue,      -- x_fcst_revenue_proj_cur
                 rac.total_projfunc_revenue,         -- x_fcst_revenue_proj_func_cur
                 rac.total_txn_init_raw_cost,     -- x_act_raw_cost_txn_cur
                 rac.total_project_init_raw_cost, -- x_act_raw_cost_proj_cur
                 rac.total_projfunc_init_raw_cost,         -- x_act_raw_cost_proj_func_cur
                 NVL(rac.total_txn_raw_cost,0) - NVL(rac.total_txn_init_raw_cost,0), -- x_etc_raw_cost_txn_cur
                 NVL(rac.total_project_raw_cost,0) - NVL(rac.total_project_init_raw_cost,0),-- x_etc_raw_cost_proj_cur
                 NVL(rac.total_projfunc_raw_cost,0) - NVL(rac.total_projfunc_init_raw_cost,0),-- x_etc_raw_cost_proj_func_cur
                 rac.total_txn_raw_cost,           -- x_fcst_raw_cost_txn_cur
                 rac.total_project_raw_cost,      -- x_fcst_raw_cost_proj_cur
                 rac.total_projfunc_raw_cost,         -- x_fcst_raw_cost_proj_func_cur
                 rac.total_txn_init_burdened_cost,     -- x_act_burd_cost_txn_cur
                 rac.total_project_init_bd_cost, -- x_act_burd_cost_proj_cur
                 rac.total_projfunc_init_bd_cost,         -- x_act_burd_cost_proj_func_cur
                 NVL(rac.total_txn_burdened_cost,0) - NVL(rac.total_txn_init_burdened_cost,0), -- x_etc_burd_cost_txn_cur
                 NVL(rac.total_project_burdened_cost,0) - NVL(rac.total_project_init_bd_cost,0), -- x_etc_burd_cost_proj_cur
                 NVL(rac.total_projfunc_burdened_cost,0) - NVL(rac.total_projfunc_init_bd_cost,0), -- x_etc_burd_cost_proj_func_cur
                 rac.total_txn_burdened_cost,           -- x_fcst_burd_cost_txn_cur
                 rac.total_project_burdened_cost,      -- x_fcst_burd_cost_proj_cur
                 rac.total_projfunc_burdened_cost,         -- x_fcst_burd_cost_proj_func_cur
/*
                 SUM(bl.init_quantity),         -- x_act_quantity
                 SUM(NVL(bl.quantity,0)) - SUM(NVL(bl.init_quantity,0)), -- x_etc_quantity
                 SUM(bl.quantity),        -- x_fcst_quantity
                 SUM(txn_init_revenue),      -- x_act_revenue_txn_cur
                 SUM(bl.project_init_revenue),  -- x_act_revenue_proj_cur
                 SUM(bl.init_revenue),          -- x_act_revenue_proj_func_cur
                 SUM(NVL(bl.txn_revenue,0)) - SUM(NVL(bl.txn_init_revenue,0)), -- x_etc_revenue_txn_cur
                 SUM(NVL(bl.project_revenue,0)) - SUM(NVL(bl.project_init_revenue,0)), -- x_etc_revenue_proj_cur
                 SUM(NVL(bl.revenue,0)) - SUM(NVL(bl.init_revenue,0)), -- x_etc_revenue_proj_func_cur
                 SUM(bl.txn_revenue),           -- x_fcst_revenue_txn_cur
                 SUM(bl.project_revenue),      -- x_fcst_revenue_proj_cur
                 SUM(bl.revenue),         -- x_fcst_revenue_proj_func_cur
                 SUM(bl.txn_init_raw_cost),     -- x_act_raw_cost_txn_cur
                 SUM(bl.project_init_raw_cost), -- x_act_raw_cost_proj_cur
                 SUM(bl.init_raw_cost),         -- x_act_raw_cost_proj_func_cur
                 SUM(NVL(bl.txn_raw_cost,0)) - SUM(NVL(bl.txn_init_raw_cost,0)), -- x_etc_raw_cost_txn_cur
                 SUM(NVL(bl.project_raw_cost,0)) - SUM(NVL(bl.project_init_raw_cost,0)), -- x_etc_raw_cost_proj_cur
                 SUM(NVL(bl.raw_cost,0)) - SUM(NVL(bl.init_raw_cost,0)), -- x_etc_raw_cost_proj_func_cur
                 SUM(bl.txn_raw_cost),           -- x_fcst_raw_cost_txn_cur
                 SUM(bl.project_raw_cost),      -- x_fcst_raw_cost_proj_cur
                 SUM(bl.raw_cost),         -- x_fcst_raw_cost_proj_func_cur
                 SUM(bl.txn_init_burdened_cost),     -- x_act_burd_cost_txn_cur
                 SUM(bl.project_init_burdened_cost), -- x_act_burd_cost_proj_cur
                 SUM(bl.init_burdened_cost),         -- x_act_burd_cost_proj_func_cur
                 SUM(NVL(bl.txn_burdened_cost,0)) - SUM(NVL(bl.txn_init_burdened_cost,0)), -- x_etc_burd_cost_txn_cur
                 SUM(NVL(bl.project_burdened_cost,0)) - SUM(NVL(bl.project_init_burdened_cost,0)), -- x_etc_burd_cost_proj_cur
                 SUM(NVL(bl.burdened_cost,0)) - SUM(NVL(bl.init_burdened_cost,0)), -- x_etc_burd_cost_proj_func_cur
                 SUM(bl.txn_burdened_cost),           -- x_fcst_burd_cost_txn_cur
                 SUM(bl.project_burdened_cost),      -- x_fcst_burd_cost_proj_cur
                 SUM(bl.burdened_cost),         -- x_fcst_burd_cost_proj_func_cur
*/
                 NULL,                                -- x_act_rev_rate (TO BE CALCULATED)
                 NULL,                                -- x_etc_init_rev_rate (TO BE CALCULATED)
                 NULL,				    -- x_etc_avg_rev_rate (TO BE CALCULATED)
                 NULL,                                -- x_act_raw_cost_rate (TO BE CALCULATED)
                 NULL,                                -- x_etc_init_raw_cost_rate (TO BE CALCULATED)
                 NULL,                                -- x_etc_avg_raw_cost_rate (TO BE CALCULATED)
                 NULL,                                -- x_act_burd_cost_rate  (TO BE CALCULATED)
                 NULL,                                -- x_etc_init_burd_cost_rate (TO BE CALCULATED)
                 NULL,                                -- x_etc_avg_burd_cost_rate (TO BE CALCULATED)
		 DECODE(po.fin_plan_preference_code,
		 	'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
	                 DECODE(po.margin_derived_from_code,
--        	                'B', SUM(bl.txn_init_revenue) - SUM(bl.txn_init_burdened_cost),
--                	        SUM(bl.txn_init_revenue) - SUM(bl.txn_init_raw_cost))), -- x_act_margin_txn_cur
        	                'B', rac.total_txn_init_revenue - rac.total_txn_init_burdened_cost,
                	        rac.total_txn_init_revenue - rac.total_txn_init_raw_cost)), -- x_act_margin_txn_cur
		 DECODE(po.fin_plan_preference_code,
		 	'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
	                 DECODE(po.margin_derived_from_code,
--        	                'B', SUM(bl.project_init_revenue) - SUM(bl.project_init_burdened_cost),
--                	        SUM(bl.project_init_revenue) - SUM(bl.project_init_raw_cost))),  -- x_act_margin_proj_cur
        	                'B', rac.total_project_init_revenue - rac.total_project_init_bd_cost,
                	        rac.total_project_init_revenue - rac.total_project_init_raw_cost)),  -- x_act_margin_proj_cur
		 DECODE(po.fin_plan_preference_code,
		 	'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
	                 DECODE(po.margin_derived_from_code,
--        	                'B', SUM(bl.init_revenue) - SUM(bl.init_burdened_cost),
--                	        SUM(bl.init_revenue) - SUM(bl.init_raw_cost))),  -- x_act_margin_proj_func_cur
        	                'B', rac.total_projfunc_init_revenue - rac.total_projfunc_init_bd_cost,
                	        rac.total_projfunc_init_revenue - rac.total_projfunc_init_raw_cost)),  -- x_act_margin_proj_func_cur
                 NULL, -- x_etc_margin_txn_cur (TO BE POPULATED)
                 NULL, -- x_etc_margin_proj_cur (TO BE POPULATED)
                 NULL, -- x_etc_margin_proj_func_cur   (TO BE POPULATED)
		 DECODE(po.fin_plan_preference_code,
		 	'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
	                 DECODE(po.margin_derived_from_code,
--        	                'B', SUM(bl.txn_revenue) - SUM(bl.txn_burdened_cost),
--                	        SUM(bl.txn_revenue) - SUM(bl.txn_raw_cost))), -- x_fcst_margin_txn_cur
        	                'B', rac.total_txn_revenue - rac.total_txn_burdened_cost,
                	        rac.total_txn_revenue - rac.total_txn_raw_cost)), -- x_fcst_margin_txn_cur
		 DECODE(po.fin_plan_preference_code,
		 	'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
	                 DECODE(po.margin_derived_from_code,
--        	                'B', SUM(bl.project_revenue) - SUM(bl.project_burdened_cost),
--                	        SUM(bl.project_revenue) - SUM(bl.project_raw_cost))), -- x_fcst_margin_proj_cur
        	                'B', rac.total_project_revenue - rac.total_project_burdened_cost,
                	        rac.total_project_revenue - rac.total_project_raw_cost)), -- x_fcst_margin_proj_cur
		 DECODE(po.fin_plan_preference_code,
		 	'COST_ONLY', TO_NUMBER(NULL),
			'REVENUE_ONLY', TO_NUMBER(NULL),
	                 DECODE(po.margin_derived_from_code,
--        	                'B', SUM(bl.revenue) - SUM(bl.burdened_cost),
--                	        SUM(bl.revenue) - SUM(bl.raw_cost))), -- x_fcst_margin_proj_func_cur
        	                'B', rac.total_projfunc_revenue - rac.total_projfunc_burdened_cost,
                	        rac.total_projfunc_revenue - rac.total_projfunc_raw_cost)), -- x_fcst_margin_proj_func_cur
                 NULL, -- x_act_margin_pct (TO BE POPULATED)
                 NULL, -- x_etc_margin_pct  (TO BE POPULATED)
                 NULL, -- x_fcst_margin_pct (TO BE POPULATED)
                 po.margin_derived_from_code
            into x_planning_start_date,
                 x_planning_end_date,
		 x_schedule_start_date,
		 x_schedule_end_date,
                 x_act_quantity,
                 x_etc_quantity,
                 x_fcst_quantity,
                 x_act_revenue_txn_cur,
                 x_act_revenue_proj_cur,
                 x_act_revenue_proj_func_cur,
                 x_etc_revenue_txn_cur,
                 x_etc_revenue_proj_cur,
                 x_etc_revenue_proj_func_cur,
                 x_fcst_revenue_txn_cur,
                 x_fcst_revenue_proj_cur,
                 x_fcst_revenue_proj_func_cur,
                 x_act_raw_cost_txn_cur,
                 x_act_raw_cost_proj_cur,
                 x_act_raw_cost_proj_func_cur,
                 x_etc_raw_cost_txn_cur,
                 x_etc_raw_cost_proj_cur,
                 x_etc_raw_cost_proj_func_cur,
                 x_fcst_raw_cost_txn_cur,
                 x_fcst_raw_cost_proj_cur,
                 x_fcst_raw_cost_proj_func_cur,
                 x_act_burd_cost_txn_cur,
                 x_act_burd_cost_proj_cur,
                 x_act_burd_cost_proj_func_cur,
                 x_etc_burd_cost_txn_cur,
                 x_etc_burd_cost_proj_cur,
                 x_etc_burd_cost_proj_func_cur,
                 x_fcst_burd_cost_txn_cur,
                 x_fcst_burd_cost_proj_cur,
                 x_fcst_burd_cost_proj_func_cur,
                 x_act_rev_rate,
                 x_etc_init_rev_rate,
	         x_etc_avg_rev_rate,
                 x_act_raw_cost_rate,
                 x_etc_init_raw_cost_rate,
                 x_etc_avg_raw_cost_rate,
                 x_act_burd_cost_rate,
                 x_etc_init_burd_cost_rate,
                 x_etc_avg_burd_cost_rate,
                 x_act_margin_txn_cur,
                 x_act_margin_proj_cur,
                 x_act_margin_proj_func_cur,
                 x_etc_margin_txn_cur,
                 x_etc_margin_proj_cur,
                 x_etc_margin_proj_func_cur,
                 x_fcst_margin_txn_cur,
                 x_fcst_margin_proj_cur,
                 x_fcst_margin_proj_func_cur,
                 x_act_margin_pct,
                 x_etc_margin_pct,
                 x_fcst_margin_pct,
                 l_margin_derived_from_code
            FROM pa_resource_assignments ra,
--                 pa_budget_lines bl,
                 pa_resource_asgn_curr rac,
                 pa_budget_versions bv,
                 pa_proj_fp_options po
            where ra.resource_assignment_id = l_resource_assignment_id and
--                  ra.resource_assignment_id = bl.resource_assignment_id and
--                  bl.txn_currency_code = p_txn_currency_code and
                  ra.resource_assignment_id = rac.resource_assignment_id and
                  rac.txn_currency_code = p_txn_currency_code and
                  ra.budget_version_id = bv.budget_version_id and
                  bv.budget_version_id = po.fin_plan_version_id and
                  po.fin_plan_option_level_code = 'PLAN_VERSION';
/*
            group by ra.transaction_source_code,
                     --ra.init_plan_quantity,
                     --ra.total_plan_quantity,
		     bl.resource_assignment_id,
                     bl.txn_currency_code,
                     ra.planning_start_date,
                     ra.planning_end_date,
		     ra.schedule_start_date,
		     ra.schedule_end_date,
                     --ra.total_project_revenue,
                     --ra.total_plan_revenue,
                     --ra.total_project_raw_cost,
                     --ra.total_plan_raw_cost,
                     --ra.total_project_burdened_cost,
                     --ra.total_plan_burdened_cost,
		     po.margin_derived_from_code,
		     po.fin_plan_preference_code;
*/
        END IF; --p_line_start_date IS NOT NULL AND p_line_end_date IS NOT NULL

          -- CALCULATE THE RATE/MARGIN/MARGINPCT VALUES

	  pa_planning_element_utils.get_initial_budget_line_info
	  (p_resource_assignment_id	=> p_resource_assignment_id,
	   p_txn_currency_code		=> p_txn_currency_code,
           p_line_start_date            => p_line_start_date,
           p_line_end_date              => p_line_end_date,
	   x_start_date			=> l_start_date,
	   x_end_date			=> l_end_date,
	   x_period_name		=> l_period_name,
	   x_quantity			=> l_quantity,
	   x_txn_raw_cost		=> l_txn_raw_cost,
	   x_txn_burdened_cost		=> l_txn_burdened_cost,
	   x_txn_revenue		=> l_txn_revenue,
	   x_init_quantity		=> l_init_quantity,
	   x_txn_init_raw_cost		=> l_txn_init_raw_cost,
	   x_txn_init_burdened_cost	=> l_txn_init_burdened_cost,
	   x_txn_init_revenue		=> l_txn_init_revenue,
	   x_init_raw_cost_rate		=> l_init_raw_cost_rate,
	   x_init_burd_cost_rate	=> l_init_burd_cost_rate,
	   x_init_revenue_rate		=> l_init_revenue_rate,
	   x_etc_init_raw_cost_rate     => l_etc_init_raw_cost_rate,
	   x_etc_init_burd_cost_rate	=> l_etc_init_burd_cost_rate,
	   x_etc_init_revenue_rate	=> l_etc_init_revenue_rate,
	   x_return_status		=> l_return_status,
	   x_msg_count			=> l_msg_count,
	   x_msg_data			=> l_msg_data);

	  if x_act_quantity is not null then
		if x_act_quantity = 0 then
	            x_act_rev_rate := 0;
                    x_act_raw_cost_rate := 0;
                    x_act_burd_cost_rate := 0;
		else
	            x_act_rev_rate := x_act_revenue_txn_cur / x_act_quantity;
                    x_act_raw_cost_rate := x_act_raw_cost_txn_cur / x_act_quantity;
                    x_act_burd_cost_rate := x_act_burd_cost_txn_cur / x_act_quantity;
		end if; -- x_act_quantity = 0
	  end if; -- x_act_quantity is not null

	 /* when calculating etc rates, use etc quantity, not fcst quantity */
	  if x_etc_quantity is not null then
		if x_etc_quantity = 0 then
		    x_etc_avg_rev_rate := 0;
                    x_etc_avg_raw_cost_rate := 0;
                    x_etc_avg_burd_cost_rate := 0;
		else
		    x_etc_avg_rev_rate := x_etc_revenue_txn_cur / x_etc_quantity;
                    x_etc_avg_raw_cost_rate := x_etc_raw_cost_txn_cur / x_etc_quantity;
                    x_etc_avg_burd_cost_rate := x_etc_burd_cost_txn_cur / x_etc_quantity;
		end if; -- x_fcst_quantity = 0;
          else
	     x_etc_avg_rev_rate := 0;
             x_etc_avg_raw_cost_rate := 0;
             x_etc_avg_burd_cost_rate := 0;
	  end if; -- x_fcst_quantity is not null

          x_etc_init_rev_rate := l_etc_init_revenue_rate;
          x_etc_init_raw_cost_rate := l_etc_init_raw_cost_rate;
          x_etc_init_burd_cost_rate := l_etc_init_burd_cost_rate;

        if l_margin_derived_from_code = 'B' then
        	x_etc_margin_txn_cur := x_etc_revenue_txn_cur - x_etc_burd_cost_txn_cur;
               	x_etc_margin_proj_cur := x_etc_revenue_txn_cur - x_etc_burd_cost_txn_cur;
                x_etc_margin_proj_func_cur := x_etc_revenue_txn_cur - x_etc_burd_cost_txn_cur;
        else
        	x_etc_margin_txn_cur := x_etc_revenue_txn_cur - x_etc_raw_cost_txn_cur;
               	x_etc_margin_proj_cur := x_etc_revenue_txn_cur - x_etc_raw_cost_txn_cur;
                x_etc_margin_proj_func_cur := x_etc_revenue_txn_cur - x_etc_raw_cost_txn_cur;
        end if; -- l_margin_derived_from_code
        if x_act_revenue_proj_cur is not null then
		if x_act_revenue_proj_cur = 0 then
		  x_act_margin_pct := 0;
		else
		  x_act_margin_pct := 100 * x_act_margin_proj_cur / x_act_revenue_proj_cur;
		end if; -- x_act_revenue_proj_cur = 0
        end if;
        if x_etc_revenue_proj_cur is not null then
		if x_etc_revenue_proj_cur = 0 then
		  x_etc_margin_pct := 0;
		else
		  x_etc_margin_pct := 100 * x_etc_margin_proj_cur / x_etc_revenue_proj_cur;
		end if; -- x_etc_revenue_proj_cur = 0
        end if;
        if x_fcst_revenue_proj_cur is not null then
		if x_fcst_revenue_proj_cur = 0 then
		  x_fcst_margin_pct := 0;
		else
		  x_fcst_margin_pct := 100 * x_fcst_margin_proj_cur / x_fcst_revenue_proj_cur;
		end if; -- x_fcst_revenue_proj_cur = 0
        end if;

      end if;
    end if;
  end if; -- if l_resource_assignment_id found
  close raid_csr;
  -- Check message stack for error messages
  if x_return_status <> FND_API.G_RET_STS_SUCCESS then
    l_msg_count := FND_MSG_PUB.count_msg;
    if l_msg_count = 1 THEN
       PA_INTERFACE_UTILS_PUB.get_messages
             (p_encoded        => FND_API.G_TRUE
             ,p_msg_index      => 1
             ,p_msg_count      => l_msg_count
             ,p_msg_data       => l_msg_data
             ,p_data           => l_data
             ,p_msg_index_out  => l_msg_index_out);
       x_msg_data := l_data;
       x_msg_count := l_msg_count;
    else
      x_msg_count := l_msg_count;
    end if;
  end if;
EXCEPTION
    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG (p_pkg_name       => 'PA_PLANNING_ELEMENT_UTILS',
                               p_procedure_name => 'get_common_bv_info_fcst');
      x_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data          := SQLERRM;
END get_common_bv_info_fcst;


procedure get_initial_budget_line_info
  (p_resource_assignment_id	IN  pa_resource_assignments.resource_assignment_id%TYPE,
   p_txn_currency_code		IN  pa_budget_lines.txn_currency_code%TYPE,
   p_line_start_date            IN  pa_budget_lines.start_date%TYPE := to_date(NULL),
   p_line_end_date              IN  pa_budget_lines.end_date%TYPE := to_date(NULL),
   x_start_date			OUT NOCOPY pa_budget_lines.start_date%TYPE, --File.Sql.39 bug 4440895
   x_end_date			OUT NOCOPY pa_budget_lines.end_date%TYPE, --File.Sql.39 bug 4440895
   x_period_name		OUT NOCOPY pa_budget_lines.period_name%TYPE, --File.Sql.39 bug 4440895
   x_quantity			OUT NOCOPY pa_budget_lines.quantity%TYPE, --File.Sql.39 bug 4440895
   x_txn_raw_cost		OUT NOCOPY pa_budget_lines.raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_txn_burdened_cost		OUT NOCOPY pa_budget_lines.burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_txn_revenue		OUT NOCOPY pa_budget_lines.revenue%TYPE, --File.Sql.39 bug 4440895
   x_init_quantity		OUT NOCOPY pa_budget_lines.init_quantity%TYPE, --File.Sql.39 bug 4440895
   x_txn_init_raw_cost		OUT NOCOPY pa_budget_lines.txn_init_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_txn_init_burdened_cost	OUT NOCOPY pa_budget_lines.txn_init_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_txn_init_revenue		OUT NOCOPY pa_budget_lines.txn_init_revenue%TYPE, --File.Sql.39 bug 4440895
   x_init_raw_cost_rate		OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_init_burd_cost_rate	OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_init_revenue_rate		OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_init_raw_cost_rate     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_init_burd_cost_rate	OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_init_revenue_rate	OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_return_status		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count			OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data			OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
BEGIN
  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_line_start_date IS NOT NULL AND p_line_end_date IS NOT NULL THEN
    select bl.start_date,
	   bl.end_date,
	   bl.period_name,
--	   bl.quantity,
	   bl.display_quantity, --IPM
           bl.txn_raw_cost,
           bl.txn_burdened_cost,
           bl.txn_revenue,
           bl.init_quantity,
           bl.txn_init_raw_cost,
           bl.txn_init_burdened_cost,
           bl.txn_init_revenue
      into x_start_date,
	   x_end_date,
	   x_period_name,
           x_quantity,
           x_txn_raw_cost,
           x_txn_burdened_cost,
           x_txn_revenue,
           x_init_quantity,
           x_txn_init_raw_cost,
           x_txn_init_burdened_cost,
           x_txn_init_revenue
      from pa_budget_lines bl
      where bl.resource_assignment_id = p_resource_assignment_id and
            bl.txn_currency_code = p_txn_currency_code and
            bl.start_date BETWEEN p_line_start_date and p_line_end_date and
            start_date = (select min(start_date)
			    from pa_budget_lines
			    where resource_assignment_id = p_resource_assignment_id and
			          txn_currency_code = p_txn_currency_code);
  ELSE -- p_line_start_date IS NULL AND/OR p_line_end_date IS NULL
    select bl.start_date,
	   bl.end_date,
	   bl.period_name,
--	   bl.quantity,
	   bl.display_quantity, -- IPM
           bl.txn_raw_cost,
           bl.txn_burdened_cost,
           bl.txn_revenue,
           bl.init_quantity,
           bl.txn_init_raw_cost,
           bl.txn_init_burdened_cost,
           bl.txn_init_revenue
      into x_start_date,
	   x_end_date,
	   x_period_name,
           x_quantity,
           x_txn_raw_cost,
           x_txn_burdened_cost,
           x_txn_revenue,
           x_init_quantity,
           x_txn_init_raw_cost,
           x_txn_init_burdened_cost,
           x_txn_init_revenue
      from pa_budget_lines bl
      where bl.resource_assignment_id = p_resource_assignment_id and
            bl.txn_currency_code = p_txn_currency_code and
            start_date = (select min(start_date)
			    from pa_budget_lines
			    where resource_assignment_id = p_resource_assignment_id and
			          txn_currency_code = p_txn_currency_code);
  END IF; -- p_line_start_date IS NOT NULL AND p_line_end_date IS NOT NULL
    -- CALCULATE THE RATES
    if x_quantity is not null then
	if x_quantity = 0 then
	  x_init_raw_cost_rate := 0;
	  x_init_burd_cost_rate := 0;
	  x_init_revenue_rate := 0;
	  x_etc_init_raw_cost_rate := 0;
	  x_etc_init_burd_cost_rate := 0;
	  x_etc_init_revenue_rate := 0;
	else
 	  x_init_raw_cost_rate := x_txn_raw_cost / x_quantity;
	  x_init_burd_cost_rate := x_txn_burdened_cost / x_quantity;
	  x_init_revenue_rate := x_txn_revenue / x_quantity;
	  x_etc_init_raw_cost_rate := (x_txn_raw_cost - x_txn_init_raw_cost) / x_quantity;
	  x_etc_init_burd_cost_rate := (x_txn_burdened_cost - x_txn_init_burdened_cost) / x_quantity;
	  x_etc_init_revenue_rate := (x_txn_revenue - x_txn_init_revenue) / x_quantity;
	end if; -- x_txn_quantity = 0
    end if; -- x_txn_quantity is not null
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    /*
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count     := 1;
    x_msg_data      := SQLERRM;
    FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PLANNING_ELEMENT_UTILS',
                             p_procedure_name   => 'get_initial_budget_line_info');
    */
    x_start_date := null;
    x_end_date := null;
    x_period_name := null;
    x_quantity := null;
    x_txn_raw_cost := null;
    x_txn_burdened_cost := null;
    x_txn_revenue := null;
    x_init_quantity := null;
    x_txn_init_raw_cost := null;
    x_txn_init_burdened_cost := null;
    x_txn_init_revenue := null;
    x_init_raw_cost_rate := null;
    x_init_burd_cost_rate := null;
    x_init_revenue_rate := null;
    x_etc_init_raw_cost_rate := null;
    x_etc_init_burd_cost_rate := null;
    x_etc_init_revenue_rate := null;
    return;
    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG (p_pkg_name       => 'PA_PLANNING_ELEMENT_UTILS',
                               p_procedure_name => 'get_common_budget_version_info_fcst');
      x_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data          := SQLERRM;
END get_initial_budget_line_info;


/* REVISION HISTORY:
 * 07/16/2004 dlai - instead of looping through each element_version_id and
 *            calling add_planning_transaction each time, we can now just call
 *            add_planning_transaction once with the p_one_to_one_mapping param
 * 01/09/2004 sagarwal - Removed Commented out code from add_new_resource_assignments
 *            and re-wrote this API. Old Code for this API can be reffered in
 *            version 115.29 of PAFPPEUB.pls
 */
PROCEDURE add_new_resource_assignments
  (p_context                        IN  VARCHAR2,
   p_project_id                     IN  pa_budget_versions.project_id%TYPE,
   p_budget_version_id              IN  pa_budget_versions.budget_version_id%TYPE,
   p_task_elem_version_id_tbl       IN  SYSTEM.PA_NUM_TBL_TYPE         DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_resource_list_member_id_tbl    IN  SYSTEM.PA_NUM_TBL_TYPE         DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_quantity_tbl                   IN  SYSTEM.PA_NUM_TBL_TYPE         DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_currency_code_tbl              IN  SYSTEM.PA_VARCHAR2_15_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE(),
   p_raw_cost_tbl                   IN  SYSTEM.PA_NUM_TBL_TYPE         DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_burdened_cost_tbl              IN  SYSTEM.PA_NUM_TBL_TYPE         DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_revenue_tbl                    IN  SYSTEM.PA_NUM_TBL_TYPE         DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_cost_rate_tbl                  IN  SYSTEM.PA_NUM_TBL_TYPE         DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_bill_rate_tbl                  IN  SYSTEM.PA_NUM_TBL_TYPE         DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_burdened_rate_tbl              IN  SYSTEM.PA_NUM_TBL_TYPE         DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_unplanned_flag_tbl             IN  SYSTEM.PA_VARCHAR2_1_TBL_TYPE  DEFAULT SYSTEM.PA_VARCHAR2_1_TBL_TYPE(),
   p_expenditure_type_tbl           IN  SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE(), --added for Enc
   x_return_status                  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                       OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

  -- begin PL/SQL tables to pass to add_planning_transaction API
  l_task_elem_version_id_tbl    SYSTEM.pa_num_tbl_type          := SYSTEM.pa_num_tbl_type();
  l_resource_list_member_id_tbl SYSTEM.pa_num_tbl_type          := SYSTEM.pa_num_tbl_type();
  l_quantity_tbl                SYSTEM.pa_num_tbl_type          := SYSTEM.pa_num_tbl_type();
  l_currency_code_tbl           SYSTEM.PA_VARCHAR2_15_TBL_TYPE  := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
  l_raw_cost_tbl                SYSTEM.pa_num_tbl_type          := SYSTEM.pa_num_tbl_type();
  l_burdened_cost_tbl           SYSTEM.pa_num_tbl_type          := SYSTEM.pa_num_tbl_type();
  l_revenue_tbl                 SYSTEM.pa_num_tbl_type          := SYSTEM.pa_num_tbl_type();
  l_cost_rate_tbl               SYSTEM.pa_num_tbl_type          := SYSTEM.pa_num_tbl_type();
  l_bill_rate_tbl               SYSTEM.pa_num_tbl_type          := SYSTEM.pa_num_tbl_type();
  l_burdened_rate_tbl           SYSTEM.pa_num_tbl_type          := SYSTEM.pa_num_tbl_type();
  l_unplanned_flag_tbl          SYSTEM.PA_VARCHAR2_1_TBL_TYPE   := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
  l_expenditure_type_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();  --added for Enc
  -- end PL/SQL tables to pass to add_planning_transaction API

  --Start of variables used for debugging
      l_msg_count          NUMBER :=0;
      l_data               VARCHAR2(2000);
      l_msg_data           VARCHAR2(2000);
      l_error_msg_code     VARCHAR2(30);
      l_msg_index_out      NUMBER;
      l_return_status      VARCHAR2(2000);
      l_debug_mode         VARCHAR2(30);
  --End of variables used for debugging

  -- Start of Variable used for comparisons and calling ADD PLAN TXN API
     l_structure_version_id  PA_PROJ_ELEMENT_VERSIONS.PARENT_STRUCTURE_VERSION_ID%TYPE;
     l_bl_already_exists   VARCHAR2(1) := 'N';
     l_rec_already_exists  VARCHAR2(1) := 'N';
     l_index               NUMBER      := 1;

BEGIN

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    PA_DEBUG.Set_Curr_Function( p_function   => 'PAFPPEUB.add_new_resource_assignments',
                                p_debug_mode => l_debug_mode );

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Adding minimum Validations Here - COUNT of tables to be Same';
        pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
    END IF;
    IF (p_task_elem_version_id_tbl.COUNT <> p_resource_list_member_id_tbl.COUNT OR
        p_resource_list_member_id_tbl.COUNT <> p_currency_code_tbl.COUNT) THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_task_elem_version_id_tbl.COUNT : '||p_task_elem_version_id_tbl.COUNT ;
            pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='p_resource_list_member_id_tbl.COUNT : '||p_resource_list_member_id_tbl.COUNT ;
            pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='p_currency_code_tbl.COUNT : '||p_currency_code_tbl.COUNT ;
            pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                             p_token1         => 'PROCEDURENAME',
                             p_value1         => 'PAFPPTPB.add_new_resource_assignments',
                             p_token2         => 'STAGE',
                             p_value2         => 'I/P Table Counts are not Equal');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF (p_task_elem_version_id_tbl.COUNT = 0) THEN
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='elem_version_id table is empty - RETURNING ... ';
            pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
        END IF;
        pa_debug.reset_curr_function;
        RETURN;
    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Fetching PARENT_STRUCTURE_VERSION_ID';
        pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
    END IF;
    l_structure_version_id := PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(p_project_id);

/*
  Scheme Used Below To derive Data to be passed to Add Planning TXN API.
  Let the Folowing I/P Data is passed to this API.
  1) t1 r1 c1
  2) t1 r1 c1
  3) t2 r2 c2
  4) t2 r2 c3
  5) t3 r3 c3

  System State is such that Budget Lines Already Exists for
  1) t2 r2 c3
  2) t3 r3 c3

  In this case add_planning_txn API should be called with the following data
  1)t1 r1 c1 and
  3)t2 r2 c2
  Basically records 2)4) and 5) have to be skipped.

  For Dev reference -
      By I/P Set of tables - parameters passed to add_new_resource_assignments
      are referred.
      By O/P Set of tables - parameters passed to add_planning_transaction API
      are referred.

  For Each Element Passed in the I/P Set of tables
    Check If Budget line exists for task/rlm/currency combination
    If Budget line already exists then jump to next element of I/P tables
    and skip the current I/P Record.
    ElsIf Budget line does not exist then
       Check if the if a record already exists in the O/P Set of Tables
       for task/rlm/currency I/P combination.
       If record does not exists then populate the O/P set of tables
       Else if a record already exists then skip the record for
       for task/rlm/currency I/P combination.
*/

    IF p_task_elem_version_id_tbl.COUNT > 0 THEN
       FOR i IN p_task_elem_version_id_tbl.FIRST .. p_task_elem_version_id_tbl.LAST LOOP
           IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Loop 1 : p_task_elem_version_id_tbl('||i||') - '||p_task_elem_version_id_tbl(i);
              pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
           END IF;

           -- Resetting flags Used
           l_bl_already_exists := 'N';
           l_rec_already_exists := 'N';

           IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Checking if budget lines exist or not';
              pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
           END IF;

           -- For a Project level record p_task_elem_version_id_tbl is passed as 0
           IF p_task_elem_version_id_tbl(i) <> 0 THEN -- For Task level record
              BEGIN
                   SELECT 'Y'
                     INTO l_bl_already_exists
                     FROM DUAL
                     WHERE EXISTS ( SELECT 1
                                      FROM PA_BUDGET_LINES PBL,PA_RESOURCE_ASSIGNMENTS PRA,PA_PROJ_ELEMENT_VERSIONS PEV
                                     WHERE PRA.PROJECT_ID                  = p_project_id
                                       AND PRA.BUDGET_VERSION_ID           = p_budget_version_id
                                       AND PRA.RESOURCE_LIST_MEMBER_ID     = p_resource_list_member_id_tbl(i)
                                       AND PEV.PROJ_ELEMENT_ID             = PRA.TASK_ID
                                       AND PEV.PARENT_STRUCTURE_VERSION_ID = l_structure_version_id
                                       AND PEV.ELEMENT_VERSION_ID          = p_task_elem_version_id_tbl(i)
                                       AND PBL.RESOURCE_ASSIGNMENT_ID      = PRA.RESOURCE_ASSIGNMENT_ID
                                       AND PBL.TXN_CURRENCY_CODE           = p_currency_code_tbl(i) );

                   IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='Budget Lines EXIST - l_bl_already_exists :'||l_bl_already_exists;
                      pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
                   END IF;

              EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        l_bl_already_exists := 'N';
                        IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage:='Budget Lines DONT EXIST - l_bl_already_exists :'||l_bl_already_exists;
                           pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
                        END IF;
              END;

           ELSE -- For Project level record

              BEGIN
                   -- SQL Repository Bug 4884718; SQL ID 14903213
                   -- Fixed Merge Join Cartesian violation by commenting out
                   -- PA_PROJ_ELEMENT_VERSIONS from the FROM clause of the
                   -- query below. It seems to be a copy/past artifact, as it
                   -- is not references anywhere in the WHERE clause.

                   SELECT 'Y'
                     INTO l_bl_already_exists
                     FROM DUAL
                     WHERE EXISTS ( SELECT 1
                                      FROM PA_BUDGET_LINES PBL,PA_RESOURCE_ASSIGNMENTS PRA
                                        --,PA_PROJ_ELEMENT_VERSIONS PEV /* Bug 4884718; SQL ID 14903213 */
                                     WHERE PRA.PROJECT_ID                  = p_project_id
                                       AND PRA.BUDGET_VERSION_ID           = p_budget_version_id
                                       AND PRA.RESOURCE_LIST_MEMBER_ID     = p_resource_list_member_id_tbl(i)
                                       AND PRA.TASK_ID                     = 0
                                       AND PBL.RESOURCE_ASSIGNMENT_ID      = PRA.RESOURCE_ASSIGNMENT_ID
                                       AND PBL.TXN_CURRENCY_CODE           = p_currency_code_tbl(i) );

                   IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='Budget Lines EXIST - l_bl_already_exists :'||l_bl_already_exists;
                      pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
                   END IF;

              EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        l_bl_already_exists := 'N';
                        IF l_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage:='Budget Lines DONT EXIST - l_bl_already_exists :'||l_bl_already_exists;
                           pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
                        END IF;
              END;
           END IF;

           -- Note record will be skipped if the BL already exists
           -- If BL/RA does not exists for I/P params Loop through Output Tables
           -- By Output tables, Tables to be passed to Add API are referred.
           IF l_bl_already_exists = 'N' THEN

              IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='BL Does Not Exist';
                 pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
              END IF;

              -- If Output Table is not Empty
              IF l_task_elem_version_id_tbl.COUNT > 0 THEN
                 -- Loop Though Output Table
                 FOR k IN l_task_elem_version_id_tbl.FIRST .. l_task_elem_version_id_tbl.LAST LOOP
                     IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='Loop 3 : l_task_elem_version_id_tbl('||k||') - '||l_task_elem_version_id_tbl(k);
                        pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
                     END IF;
                     -- Compare if I/P Params have alreayd been added to output table or not.
                     IF ((p_task_elem_version_id_tbl(i) = l_task_elem_version_id_tbl(k)) AND
                         (p_resource_list_member_id_tbl(i) = l_resource_list_member_id_tbl(k)) AND
                         (p_currency_code_tbl(i) = l_currency_code_tbl(k))) THEN
                          -- If Already Added Set l_rec_already_exists to Y
                          IF l_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage:='Output Rec Exists';
                             pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
                          END IF;
                          l_rec_already_exists := 'Y';
                          EXIT;
                     ELSE
                          --Set l_rec_already_exists to N
                          l_rec_already_exists := 'N';
                     END IF;
                 END LOOP;
              ELSE
                 -- If Output Table is Empty Set l_rec_already_exists to N
                 l_rec_already_exists := 'N';
              END IF;

              -- If Output Table does not have the I/P Rec add I/P Rec to Output Tables
              IF l_rec_already_exists = 'N' THEN
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Add to Output Rec';
                    pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
                 END IF;

                 l_task_elem_version_id_tbl.extend(1);
                 l_resource_list_member_id_tbl.extend(1);
                 l_quantity_tbl.extend(1);
                 l_currency_code_tbl.extend(1);
                 l_raw_cost_tbl.extend(1);
                 l_burdened_cost_tbl.extend(1);
                 l_revenue_tbl.extend(1);
                 l_cost_rate_tbl.extend(1);
                 l_bill_rate_tbl.extend(1);
                 l_expenditure_type_tbl.extend(1);

                 l_burdened_rate_tbl.extend(1);
                 l_unplanned_flag_tbl.extend(1);

                 l_task_elem_version_id_tbl(l_index)    :=   p_task_elem_version_id_tbl(i);
                 l_resource_list_member_id_tbl(l_index) :=   p_resource_list_member_id_tbl(i);
                 l_currency_code_tbl(l_index)           :=   p_currency_code_tbl(i);
                 IF p_quantity_tbl.EXISTS(i) THEN
                     l_quantity_tbl(l_index)                :=   p_quantity_tbl(i);
                 END IF;
                 IF p_raw_cost_tbl.EXISTS(i) THEN
                     l_raw_cost_tbl(l_index)                :=   p_raw_cost_tbl(i);
                 END IF;
                 IF p_burdened_cost_tbl.EXISTS(i) THEN
                     l_burdened_cost_tbl(l_index)           :=   p_burdened_cost_tbl(i);
                 END IF;
                 IF p_revenue_tbl.EXISTS(i) THEN
                     l_revenue_tbl(l_index)                 :=   p_revenue_tbl(i);
                 END IF;
                 IF p_cost_rate_tbl.EXISTS(i) THEN
                     l_cost_rate_tbl(l_index)               :=   p_cost_rate_tbl(i);
                 END IF;
                 IF p_bill_rate_tbl.EXISTS(i) THEN
                     l_bill_rate_tbl(l_index)               :=   p_bill_rate_tbl(i);
                 END IF;
                 IF p_burdened_rate_tbl.EXISTS(i) THEN
                     l_burdened_rate_tbl(l_index)           :=   p_burdened_rate_tbl(i);
                 END IF;
                 IF p_unplanned_flag_tbl.EXISTS(i) THEN
                     l_unplanned_flag_tbl(l_index)          :=   p_unplanned_flag_tbl(i);
                 END IF;
                  IF p_expenditure_type_tbl.EXISTS(i) THEN
                    l_expenditure_type_tbl(l_index) := p_expenditure_type_tbl(i);    --added for Enc
                  END IF;
                 l_index := l_index +1;
              END IF;

           ELSE -- i.e. l_bl_already_exists = 'Y'
              IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='BL Exists - Skipping Rec p_task_elem_version_id_tbl : '||p_task_elem_version_id_tbl(i);
                 pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);

                 pa_debug.g_err_stage:='BL Exists - Skipping Rec p_resource_list_member_id_tbl : '||p_resource_list_member_id_tbl(i);
                 pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);

                 pa_debug.g_err_stage:='BL Exists - Skipping Rec p_currency_code_tbl : '||p_currency_code_tbl(i);
                 pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
              END IF;
           END IF;

       END LOOP;

    ELSE
        -- If Empty Tables are passed to Wrapper API. Simply Return
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='elem_version_id table is empty - RETURNING ... '||p_context;
            pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
        END IF;
        pa_debug.reset_curr_function;
        RETURN;
    END IF;

  IF l_debug_mode = 'Y' THEN
      pa_debug.g_err_stage:='Calling Add Planning TXN API';
      pa_debug.write('PAFPPEUB.add_new_resource_assignments',pa_debug.g_err_stage,3);
  END IF;

  pa_fp_planning_transaction_pub.add_planning_transactions
        (p_context                      => p_context,
         p_one_to_one_mapping_flag      => 'Y',
         p_skip_duplicates_flag         => 'Y',
         p_project_id                   => p_project_id,
         p_budget_version_id            => p_budget_version_id,
         p_task_elem_version_id_tbl     => l_task_elem_version_id_tbl,
         p_resource_list_member_id_tbl  => l_resource_list_member_id_tbl,
         p_quantity_tbl                 => l_quantity_tbl,
         p_currency_code_tbl            => l_currency_code_tbl,
         p_raw_cost_tbl                 => l_raw_cost_tbl,
         p_burdened_cost_tbl            => l_burdened_cost_tbl,
         p_revenue_tbl                  => l_revenue_tbl,
         p_cost_rate_tbl                => l_cost_rate_tbl,
         p_bill_rate_tbl                => l_bill_rate_tbl,
         p_burdened_rate_tbl            => l_burdened_rate_tbl,
         p_unplanned_flag_tbl           => l_unplanned_flag_tbl,
         p_expenditure_type_tbl         => l_expenditure_type_tbl, --for Enc
         x_return_status                => l_return_status,
         x_msg_count                    => l_msg_count,
         x_msg_data                     => l_msg_data);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:='ADD PLAN TXN Returned Error';
          pa_debug.write('PA_PLANNING_ELEMENT_UTILS.add_new_resource_assignments',pa_debug.g_err_stage,3);
      END IF;

      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
  END IF;

  pa_debug.reset_curr_function;

EXCEPTION
     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                (p_encoded        => FND_API.G_TRUE
                ,p_msg_index      => 1
                ,p_msg_count      => l_msg_count
                ,p_msg_data       => l_msg_data
                ,p_data           => l_data
                ,p_msg_index_out  => l_msg_index_out);
                 x_msg_data := l_data;
                 x_msg_count := l_msg_count;
          ELSE
             x_msg_count := l_msg_count;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          pa_debug.reset_curr_function;

     WHEN OTHERS THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_PLANNING_ELEMENT_UTILS'
                                  ,p_procedure_name  => 'add_new_resource_assignments');

          IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
            pa_debug.write('add_new_resource_assignments',pa_debug.g_err_stage,5);
          END IF;
          pa_debug.reset_curr_function;
          RAISE;

END add_new_resource_assignments;


/* This procedure is used to retrieve:
   FND_API.G_MISS_NUM (x_num)
   FND_API.G_MISS_CHAR (x_char)
   FND_API.G_MISS_DATE (x_date)
   so it can be passed to the Java-side for further use
*/
PROCEDURE get_fnd_miss_constants
   (x_num  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_char OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_date OUT NOCOPY DATE) IS --File.Sql.39 bug 4440895
BEGIN
    x_num:=FND_API.G_MISS_NUM;
    x_char:=FND_API.G_MISS_CHAR;
    x_date:=FND_API.G_MISS_DATE;
END get_fnd_miss_constants;

/* REVISION HISTORY
 * Created: 07/20/2004 by DLAI for bug 3747582
 */
FUNCTION get_bv_name_from_id
   (p_budget_version_id IN pa_budget_versions.budget_version_id%TYPE) return VARCHAR2 is
 l_return_value pa_budget_versions.version_name%TYPE;
BEGIN
  select version_name
    into l_return_value
    from pa_budget_versions
    where budget_version_id = p_budget_version_id;
  return l_return_value;
EXCEPTION
  when NO_DATA_FOUND then
     return null;
  when others then
     return null;
END get_bv_name_from_id;

--Created for bug 3546208. This function will return the financial structure version id for the project
--id passed.
FUNCTION get_fin_struct_id(p_project_id        pa_projects_all.project_id%TYPE,
                           p_budget_version_id pa_budget_versions.budget_Version_id%TYPE)
RETURN NUMBER
IS
BEGIN
    IF (l_edit_plan_project_id IS NULL OR
        l_edit_plan_struct_id  IS NULL OR
        l_edit_plan_bv_id IS NULL) OR
       (l_edit_plan_project_id <>  NVL(p_project_id,-99) OR
        l_edit_plan_bv_id <> NVL(p_budget_version_id,-99)) THEN

        SELECT DECODE(wp_version_flag,
                      'Y',project_structure_version_id,
                      PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(project_id))
        INTO   l_edit_plan_struct_id
        FROM   pa_budget_versions
        WHERE  budget_Version_id=p_budget_version_id;

        l_edit_plan_project_id:= p_project_id;
        l_edit_plan_bv_id     := p_budget_version_id;

    END IF;
    RETURN l_edit_plan_struct_id;
END get_fin_struct_id;


-- This function returns the wbs element name, either from the wbs_element_version_id
-- or from the proj_element_id.  If using proj_element_id, then p_use_element_version_id_flag
-- must be set to 'N'
FUNCTION get_wbs_element_name_from_id
   (p_project_id	      IN  pa_projects_all.project_id%TYPE,
    p_wbs_element_version_id  IN  pa_resource_assignments.wbs_element_version_id%TYPE,
    p_wbs_project_element_id  IN  pa_proj_element_versions.proj_element_id%TYPE,
    p_use_element_version_flag IN VARCHAR2)
return VARCHAR2
IS
 l_return_value   pa_proj_elements.name%TYPE;
BEGIN
  select name
    into l_return_value
    from pa_projects_all
    where project_id = p_project_id;
    -- if wbs_element_version_id is 0 or -1, then it is a project-level row
  if p_wbs_element_version_id = 0 or p_wbs_element_version_id = -1 then
    return l_return_value;
  else
    if p_use_element_version_flag = 'N' then
      -- using proj_element_id
      select pe.name
        into l_return_value
        from pa_proj_elements pe
        where pe.proj_element_id = p_wbs_project_element_id;
      return l_return_value;
    else
      -- using wbs_element_version_id
      select pe.name
        into l_return_value
	from pa_proj_element_versions pev,
	     pa_proj_elements pe
	where pev.element_version_id = p_wbs_element_version_id and
 	      pev.proj_element_id = pe.proj_element_id;
	return l_return_value;
    end if; -- use wbs_element_version_id
  end if;
EXCEPTION
  when NO_DATA_FOUND then
     return null;
  when others then
     return null;
END get_wbs_element_name_from_id;


FUNCTION get_proj_element_id
   (p_wbs_element_version_id  IN  pa_proj_element_versions.element_version_id%TYPE)
return NUMBER
IS
 l_return_value pa_proj_element_versions.proj_element_id%TYPE;
BEGIN
  select proj_element_id
    into l_return_value
    from pa_proj_element_versions
    where element_version_id = p_wbs_element_version_id;
  return l_return_value;
EXCEPTION
  when NO_DATA_FOUND then
     return null;
  when others then
     return null;
END get_proj_element_id;

FUNCTION get_rbs_element_name_from_id
    (p_rbs_element_version_id  IN  pa_rbs_elements.rbs_element_id%TYPE)
return VARCHAR2
IS
 l_return_value pa_rbs_element_names_vl.resource_name%TYPE;
BEGIN
  select names.resource_name
    into l_return_value
    from pa_rbs_elements ele,
         pa_rbs_element_names_vl names
    where ele.rbs_element_id = p_rbs_element_version_id and
          ele.rbs_element_name_id = names.rbs_element_name_id;
  return l_return_value;
EXCEPTION
  when NO_DATA_FOUND then
     return null;
  when others then
     return null;
END get_rbs_element_name_from_id;


FUNCTION get_task_percent_complete
    (p_project_id	     IN pa_projects_all.project_id%TYPE,
     p_budget_version_id     IN pa_budget_versions.budget_version_id%TYPE,
     p_proj_element_id       IN pa_proj_element_versions.proj_element_id%TYPE,
     p_calling_context       IN VARCHAR2) return NUMBER
is
 l_return_value             NUMBER;
 l_structure_type	    VARCHAR2(30) := 'FINANCIAL'; -- could also be 'WORKPLAN'
 l_object_type              VARCHAR2(30) := 'PA_TASKS';
 l_structure_status_flag    VARCHAR2(1) := null;
 l_structure_version_id     pa_proj_element_versions.parent_structure_version_id%TYPE;
 l_structure_status         VARCHAR2(30) := null;
 l_base_percent_complete    NUMBER := null;
 l_return_status VARCHAR2(1);
 l_msg_count NUMBER;
 l_msg_data  VARCHAR2(2000);
BEGIN
--hr_utility.trace_on(null, 'dlai');
--hr_utility.trace('ENTERING GET PERCENT COMPLETE API');
  l_return_value := null;
  l_structure_version_id :=
        pa_planning_element_utils.get_fin_struct_id(p_project_id,p_budget_version_id);
  l_structure_status_flag :=
	PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(
                p_project_id,
                l_structure_version_id);
  if l_structure_status_flag = 'Y' then
    l_structure_status := 'PUBLISHED';
  else
    l_structure_status := 'WORKING';
  end if;
/*
hr_utility.trace('p_project_id is ' || to_char(p_project_id));
hr_utility.trace('p_proj_element_id is ' || to_char(p_proj_element_id));
hr_utility.trace('p_structure_type is ' || l_structure_type);
hr_utility.trace('p_object_type is ' || l_object_type);
hr_utility.trace('p_as_of_date is ' || to_char(trunc(SYSDATE)));
hr_utility.trace('p_structure_version_id is ' || to_char(l_structure_version_id));
hr_utility.trace('p_structure_status is ' || l_structure_status);
hr_utility.trace('p_calling_context is ' || p_calling_context);
hr_utility.trace('x_base_percent_complete is ' || to_char(l_base_percent_complete));
hr_utility.trace('x_return_status is ' || l_return_status);
hr_utility.trace('x_msg_count is ' || to_char(l_msg_count));
hr_utility.trace('x_msg_data is ' || l_msg_data);
*/
  PA_PROGRESS_UTILS.REDEFAULT_BASE_PC
       (p_project_id             => p_project_id,
        p_proj_element_id        => p_proj_element_id,
        p_structure_type         => l_structure_type,
        p_object_type            => l_object_type,
        p_as_of_date             => trunc(SYSDATE),
        p_structure_version_id   => l_structure_version_id,
        p_structure_status       => l_structure_status,
        p_calling_context        => p_calling_context,
        x_base_percent_complete  => l_base_percent_complete,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data);
  if l_return_status = 'S' then
    l_return_value := l_base_percent_complete;
  end if;
  return l_return_value;
EXCEPTION
  when NO_DATA_FOUND then
     return null;
  when others then
     return null;
END get_task_percent_complete;

/* Bug 5524803: Added the below API to return the prior forecast version id
   to be used by PJI team.
   This procedure returns a different value of 'x_prior_fcst_version_id' compared
   to the get_finplan_bvids. This procedure has been specifically created for
   PJI team.

   If p_budget_version_id is a BUDGET version:
      x_prior_fcst_version_id = Version previous to the current baselined version
                                of PRIMARY FORECAST plan type
   If p_budget_version is a FORECAST version:
      x_prior_fcst_version_id = Version previous to the current baselined version
                                of same plan type
*/
FUNCTION get_prior_forecast_version_id
  (p_plan_version_id     IN  pa_budget_versions.budget_version_id%TYPE,
   p_project_id          IN  pa_projects_all.project_id%TYPE
  ) return NUMBER
is
 l_plan_class_code        pa_fin_plan_types_b.plan_class_code%TYPE;
 l_fin_plan_pref_code     pa_proj_fp_options.fin_plan_preference_code%TYPE;
 l_curr_fcst_ver_id       pa_budget_versions.budget_version_id%TYPE := NULL;
 l_curr_fcst_ver_num      pa_budget_versions.version_number%TYPE := NULL;
 l_fp_type_id             pa_budget_versions.fin_plan_type_id%TYPE := NULL;
 l_version_type           pa_budget_versions.version_type%TYPE := NULL;
 x_prior_fcst_version_id  pa_budget_versions.budget_version_id%TYPE := NULL;


BEGIN
  select pt.plan_class_code,
         decode(bv.version_type,'COST','COST_ONLY','REVENUE','REVENUE_ONLY',
         'ALL','COST_AND_REV_SAME')
    into l_plan_class_code,
         l_fin_plan_pref_code
    from pa_budget_versions bv,
         pa_fin_plan_types_b pt
    where bv.budget_version_id = p_plan_version_id and
          bv.fin_plan_type_id = pt.fin_plan_type_id;

  if l_plan_class_code = 'BUDGET' then
    -- CURRENT PLAN VERSION IS BUDGET PLAN CLASS
    -- RETRIEVE PRIMARY FORECAST BASELINED VERSION (IF IT EXISTS)
    if l_fin_plan_pref_code = 'COST_ONLY' then
      -- looking for PRIMARY COST FORECAST plan type
        begin
          select bv.budget_version_id,
                 bv.version_number
            into l_curr_fcst_ver_id,
                 l_curr_fcst_ver_num
            from  pa_budget_versions bv
            where bv.project_id = p_project_id and
                  bv.primary_cost_forecast_flag = 'Y' and
                  bv.current_flag = 'Y';

          select bv1.budget_version_id
            into x_prior_fcst_version_id
            from pa_budget_versions bv1
           where bv1.project_id = p_project_id
             and bv1.primary_cost_forecast_flag = 'Y'
             and bv1.budget_status_code = 'B'
             /*and bv1.version_number = l_curr_fcst_ver_num - 1;
		commented and added below for bug 6870324 */
             and bv1.version_number = (select max(bv2.version_number)
	                              from pa_budget_versions bv2
				      where bv2.project_id = p_project_id
				        and bv2.primary_cost_forecast_flag = 'Y'
					and bv2.budget_status_code = 'B'
					and bv2.version_number < l_curr_fcst_ver_num
				      );


        exception
          when NO_DATA_FOUND then
                x_prior_fcst_version_id := -1;
        end;
    elsif l_fin_plan_pref_code = 'REVENUE_ONLY' then
      -- looking for PRIMARY REVENUE FORECAST plan type
        begin
          select bv.budget_version_id,
                 bv.version_number
            into l_curr_fcst_ver_id,
                 l_curr_fcst_ver_num
            from  pa_budget_versions bv
            where bv.project_id = p_project_id and
                  bv.primary_rev_forecast_flag = 'Y' and
                  bv.current_flag = 'Y';

          select bv1.budget_version_id
            into x_prior_fcst_version_id
            from pa_budget_versions bv1
           where bv1.project_id = p_project_id
             and bv1.primary_rev_forecast_flag = 'Y'
             and bv1.budget_status_code = 'B'
             /*and bv1.version_number = l_curr_fcst_ver_num - 1;
		commented and added below for bug 6870324 */
             and bv1.version_number = (select max(bv2.version_number)
	                              from pa_budget_versions bv2
				      where bv2.project_id = p_project_id
				        and bv2.primary_rev_forecast_flag = 'Y'
					and bv2.budget_status_code = 'B'
					and bv2.version_number < l_curr_fcst_ver_num
				      );

        exception
          when NO_DATA_FOUND then
                x_prior_fcst_version_id := -1;
        end;
    elsif l_fin_plan_pref_code = 'COST_AND_REV_SAME' then
      -- looking for PRIMARY 'ALL' FORECAST plan type
        begin
          select bv.budget_version_id,
                 bv.version_number
            into l_curr_fcst_ver_id,
                 l_curr_fcst_ver_num
            from  pa_budget_versions bv
            where bv.project_id = p_project_id and
                  bv.primary_rev_forecast_flag = 'Y' and
                  bv.primary_cost_forecast_flag = 'Y'  and
                  bv.current_flag = 'Y';
          select bv1.budget_version_id
            into x_prior_fcst_version_id
            from pa_budget_versions bv1
           where bv1.project_id = p_project_id
             and bv1.primary_rev_forecast_flag = 'Y'
             and bv1.primary_cost_forecast_flag = 'Y'
             and bv1.budget_status_code = 'B'
             /*and bv1.version_number = l_curr_fcst_ver_num - 1;
		commented and added below for bug 6870324 */
             and bv1.version_number = (select max(bv2.version_number)
	                              from pa_budget_versions bv2
				      where bv2.project_id = p_project_id
				        and bv2.primary_rev_forecast_flag = 'Y'
				        and bv2.primary_cost_forecast_flag = 'Y'
					and bv2.budget_status_code = 'B'
					and bv2.version_number < l_curr_fcst_ver_num
				      );

        exception
          when NO_DATA_FOUND then

                begin
                  select bv.budget_version_id,
                         bv.version_number
                    into l_curr_fcst_ver_id,
                         l_curr_fcst_ver_num
                    from  pa_budget_versions bv
                    where bv.project_id = p_project_id and
                          bv.primary_cost_forecast_flag = 'Y' and
                          bv.current_flag = 'Y';

                  select bv1.budget_version_id
                    into x_prior_fcst_version_id
                    from pa_budget_versions bv1
                   where bv1.project_id = p_project_id
                     and bv1.primary_cost_forecast_flag = 'Y'
                     and bv1.budget_status_code = 'B'
		     /*and bv1.version_number = l_curr_fcst_ver_num - 1;
			commented and added below for bug 6870324 */
		     and bv1.version_number = (select max(bv2.version_number)
					      from pa_budget_versions bv2
					      where bv2.project_id = p_project_id
						and bv2.primary_cost_forecast_flag = 'Y'
						and bv2.budget_status_code = 'B'
						and bv2.version_number < l_curr_fcst_ver_num
					      );

                exception
                  when NO_DATA_FOUND then

                        begin
                          select bv.budget_version_id,
                                 bv.version_number
                            into l_curr_fcst_ver_id,
                                 l_curr_fcst_ver_num
                            from  pa_budget_versions bv
                            where bv.project_id = p_project_id and
                                  bv.primary_rev_forecast_flag = 'Y'  and
                                  bv.current_flag = 'Y';

                          select bv1.budget_version_id
                            into x_prior_fcst_version_id
                            from pa_budget_versions bv1
                           where bv1.project_id = p_project_id
                             and bv1.primary_rev_forecast_flag = 'Y'
                             and bv1.budget_status_code = 'B'
			     /*and bv1.version_number = l_curr_fcst_ver_num - 1;
				commented and added below for bug 6870324 */
			     and bv1.version_number = (select max(bv2.version_number)
						      from pa_budget_versions bv2
						      where bv2.project_id = p_project_id
							and bv2.primary_rev_forecast_flag = 'Y'
							and bv2.budget_status_code = 'B'
							and bv2.version_number < l_curr_fcst_ver_num
						      );

                        exception
                          when NO_DATA_FOUND then
                                x_prior_fcst_version_id := -1;
                        end;
                end;
        end;

    end if; -- l_fin_plan_pref_code

  else
    -- CURRENT PLAN VERSION IS FORECAST PLAN CLASS
    begin
      select bv2.budget_version_id,
             bv2.version_number,
             bv2.fin_plan_type_id,
             bv2.version_type
        into l_curr_fcst_ver_id,
             l_curr_fcst_ver_num,
             l_fp_type_id,
             l_version_type
        from pa_budget_versions bv1,
             pa_budget_versions bv2
        where bv1.project_id = p_project_id and
              bv1.budget_version_id = p_plan_version_id and
              bv1.project_id = bv2.project_id and
              bv1.fin_plan_type_id = bv2.fin_plan_type_id and
              bv1.version_type = bv2.version_type and
              bv2.current_flag = 'Y';

      select budget_version_id
        into x_prior_fcst_version_id
        from pa_budget_versions
        where project_id = p_project_id and
              fin_plan_type_id = l_fp_type_id and
              version_type = l_version_type and
              budget_status_code = 'B' and
              /* version_number = l_curr_fcst_ver_num - 1;
      		commented and added below for bug 6870324 */
		version_number = (select max(bv1.version_number)
		                  from pa_budget_versions bv1
				  where bv1.project_id = p_project_id
				  and bv1.fin_plan_type_id = l_fp_type_id
				  and bv1.version_type = l_version_type
				  and bv1.budget_status_code = 'B'
				  and bv1.version_number < l_curr_fcst_ver_num
				  );


    exception
      when NO_DATA_FOUND then
        x_prior_fcst_version_id := -1;
    end;

  end if; -- l_plan_class_code
  RETURN x_prior_fcst_version_id;
EXCEPTION
  when no_data_found then
       RETURN NULL;
END get_prior_forecast_version_id;

END pa_planning_element_utils;

/
