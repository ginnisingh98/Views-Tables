--------------------------------------------------------
--  DDL for Package Body PA_FIN_PLAN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FIN_PLAN_UTILS" as
/* $Header: PAFPUTLB.pls 120.16.12010000.8 2009/07/24 15:00:22 rthumma ship $
   Start of Comments
   Package name     : PA_FIN_PLAN_UTILS
   Purpose          : utility API's for Org Forecast pages
   History          :
   NOTE             :
   End of Comments
*/

l_module_name VARCHAR2(100) := 'pa.plsql.pa_fin_plan_utils';
Invalid_Arg_Exc  EXCEPTION;
Invalid_Call_Exc  EXCEPTION; /* Added for FP.M, Tracking bug no.3354518 */

-- This function takes a lookup type and code, and returns the meaning
-- useful when wanting to populate VO's with the meaning for display
-- in a table
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

--bug 5962744

G_Chg_Reason    varchar2(80);

function get_lookup_value
    (p_lookup_type      pa_lookups.lookup_type%TYPE,
     p_lookup_code      pa_lookups.lookup_code%TYPE) return VARCHAR2
is
l_return_value      VARCHAR2(80);
begin
  select meaning
    into l_return_value
    from pa_lookups
    where lookup_type = p_lookup_type and
          lookup_code = p_lookup_code;
  return l_return_value;
exception
   WHEN NO_DATA_FOUND then
      return null;
   WHEN OTHERS then
      return null;
end get_lookup_value;


procedure Check_Record_Version_Number
    (p_unique_index             IN  NUMBER,
     p_record_version_number    IN  NUMBER,
     x_valid_flag               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_return_status                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_error_msg_code           OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
l_record_version_number         pa_budget_versions.record_version_number%TYPE;
begin
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_valid_flag := 'Y';
    select
        record_version_number
    into
        l_record_version_number
    from
        pa_budget_versions
    where
        budget_version_id=p_unique_index;
    /* compare results */
    if p_record_version_number is NULL then
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
    elsif p_record_version_number <> l_record_version_number then
        x_valid_flag := 'N';
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_msg_code := 'PA_XC_RECORD_CHANGED';
        return;
    end if;
/*
exception
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_UTILS',
                               p_procedure_name   => 'Check_Record_Version_Number');
*/
end Check_Record_Version_Number;

/* This function checks whether a plan type can be added to a project or not
   This will be called from the Add Plan Type page. This is due to bug
   2607945*/
FUNCTION Is_Plan_Type_Addition_Allowed
          (p_project_id                   IN   pa_projects_all.project_id%TYPE
          ,p_fin_plan_type_id             IN   pa_fin_plan_types_b.fin_plan_type_id%TYPE
          ) RETURN VARCHAR2 IS

l_valid_status                       VARCHAR2(1):='S';
l_migrated_frm_bdgt_typ_code       pa_fin_plan_types_b.migrated_frm_bdgt_typ_code%TYPE;
l_approved_cost_plan_type_flag     pa_fin_plan_types_b.approved_cost_plan_type_flag%TYPE;
l_approved_rev_plan_type_flag      pa_fin_plan_types_b.approved_rev_plan_type_flag%TYPE;
l_budget_version_id                pa_budget_Versions.budget_version_id%TYPE;

BEGIN
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.init_err_stack ('pa_fin_plan_utils.is_plan_type_addition_allowed');
       END IF;

/* Changes for FP.M, Tracking Bug No - 3354518. Adding conditon in the where clause below to
check for new column use_for_workplan flag. This column indicates if a plan type is being
used for workplan or not. Since we cannot add a workplan plantype to a project for budgeting
we are introducing this check.Please note that this API is used for addition of finplan
types only*/

SELECT migrated_frm_bdgt_typ_code
             ,approved_cost_plan_type_flag
             ,approved_rev_plan_type_flag
       INTO l_migrated_frm_bdgt_typ_code
            ,l_approved_cost_plan_type_flag
            ,l_approved_rev_plan_type_flag
       FROM pa_fin_plan_types_b
       WHERE fin_plan_type_id = p_fin_plan_type_id
         AND nvl(use_for_workplan_flag,'N')='N'; -- Added for Changes for FP.M, Tracking Bug No - 3354518


      IF (l_migrated_frm_bdgt_typ_code IS NULL) THEN
                 IF (l_approved_cost_plan_type_flag ='Y') THEN
                    BEGIN
                      SELECT budget_version_id
                      INTO   l_budget_version_id
                      FROM   pa_budget_versions
                      WHERE  project_id = p_project_id
                      AND    budget_type_code=PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AC
                      AND    rownum = 1;

                      RETURN ('PA_FP_AC_BUDGET_TYPE_EXISTS');

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           l_valid_status :='S';
                    END;
                 END IF;

                 IF (l_approved_rev_plan_type_flag ='Y')  THEN
                    BEGIN
                      SELECT budget_version_id
                      INTO   l_budget_version_id
                      FROM   pa_budget_versions
                      WHERE  project_id = p_project_id
                      AND    budget_type_code=PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AR
                      AND    rownum = 1;

                      RETURN 'PA_FP_AR_BUDGET_TYPE_EXISTS';

                    EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            l_valid_status :='S';
                    END;
                 END IF;


      ELSE
              BEGIN
                   SELECT budget_version_id
                   INTO   l_budget_version_id
                   FROM   pa_budget_versions
                   WHERE  project_id = p_project_id
                   AND    budget_type_code=l_migrated_frm_bdgt_typ_code
                   AND    rownum = 1;

                   RETURN 'PA_FP_BUDGET_TYPE_NOT_UPGRADED';
              EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                          l_valid_status :='S';
              END;
      END IF;
 IF P_PA_DEBUG_MODE = 'Y' THEN
	pa_debug.reset_err_stack;
	END IF;
RETURN l_valid_status;
 EXCEPTION

/* Changes for FP.M, Tracking Bug No - 3354518. Adding Exception handling for NO_DATA_FOUND
to return Failure Status as per the where clause added above for use_for_workplan_flag */
     WHEN NO_DATA_FOUND THEN
 IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.reset_err_stack;
 END IF;
          RETURN 'F';

        WHEN OTHERS THEN
 IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.reset_err_stack;
 END IF;
          RETURN 'F';

 END is_plan_type_addition_allowed;

function Retrieve_Record_Version_Number
    (p_budget_version_id     IN   pa_budget_versions.budget_version_id%TYPE)
    return number
is
l_record_version_number  pa_budget_versions.record_version_number%TYPE;

begin
    select
        nvl(record_version_number, 0)
    into
        l_record_version_number
    from
        pa_budget_versions
    where
        budget_version_id=p_budget_version_id;
    return l_record_version_number;
end Retrieve_Record_Version_Number;

function Plan_Amount_Exists
    (p_budget_version_id IN pa_budget_versions.budget_version_id%TYPE)
    return varchar2 is
   l_exists  varchar2(1) := 'N';
begin

  select 'Y'
  into   l_exists
  from   pa_budget_lines a,
         pa_resource_assignments b
  where  a.resource_assignment_id = b.resource_assignment_id
  and    b.budget_version_id = p_budget_version_id
  and    rownum < 2;

  return l_exists;

exception
  when no_data_found then
    return 'N';
end Plan_Amount_Exists;


/*
  API Name               : Plan_Amount_Exists_Task_Res
  API Description   : Return 'Y' if at least one record exists in Resource Assignments (pa_resource_assignments)
                           for the given Budget Version Id, Task Id, Resource List Member Id
  API Created By    : Vthakkar
  API Creation Date : 15-MAR-2004
*/

FUNCTION Plan_Amount_Exists_Task_Res
               (p_budget_version_id         IN pa_budget_versions.budget_version_id%TYPE ,
                p_task_id                         IN pa_tasks.task_id%TYPE Default Null,
                p_resource_list_member_id   IN pa_resource_list_members.RESOURCE_LIST_MEMBER_ID%TYPE Default Null
     ) RETURN VARCHAR2
IS
   l_exists  varchar2(1) := 'N';
begin

  select 'Y'
    into l_exists
    from pa_budget_lines a,
         pa_resource_assignments b
   where a.resource_assignment_id = b.resource_assignment_id
     and b.budget_version_id = p_budget_version_id
      and b.task_id   = Nvl(p_task_id,b.task_id)
      and b.resource_list_member_id = Nvl(p_resource_list_member_id,b.resource_list_member_id)
     and rownum < 2;

  return l_exists;

exception
  when no_data_found then
    return 'N';
end Plan_Amount_Exists_Task_Res;

/*=============================================================================
  This function is used to return resource list id of the finplan version
==============================================================================*/

Function Get_Resource_List_Id (
         p_fin_plan_version_id  IN   pa_proj_fp_options.fin_plan_version_id %TYPE )
RETURN   pa_proj_fp_options.all_resource_list_id%TYPE
IS

   l_resource_list_id  pa_proj_fp_options.all_resource_list_id%TYPE;

BEGIN

   SELECT DECODE(fin_plan_preference_code,
                 PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME, all_resource_list_id,
                 PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY,         cost_resource_list_id,
                 PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY,      revenue_resource_list_id)
   INTO   l_resource_list_id
   FROM   pa_proj_fp_options
   WHERE  fin_plan_version_id = p_fin_plan_version_id;

   RETURN l_resource_list_id;

END Get_Resource_List_Id;

/*=============================================================================
  This function is used to return time phased code of the finplan version.

  Bug :- 2634985. The api has been modified to return the time phasing details
  irrespective of whether the budget version is of old busdget model or new
  financial model.
==============================================================================*/

FUNCTION Get_Time_Phased_code (
         p_fin_plan_version_id  IN   pa_proj_fp_options.fin_plan_version_id %TYPE )
RETURN   pa_proj_fp_options.all_time_phased_code%TYPE
IS

   l_budget_entry_method_code   pa_budget_versions.budget_entry_method_code%TYPE;
   l_budget_type_code           pa_budget_versions.budget_type_code%TYPE;

   l_time_phased_code           pa_proj_fp_options.all_time_phased_code%TYPE;

BEGIN

   -- Fetch the  budget_entry_method_code  of the budget version.
   -- 1) If it is not null, then fetch time phasing code from pa_budget_entry_methods table
   -- 2) If its null, fetch the tim pahsing code from the pa_proj_fp_options table.

   BEGIN
           SELECT   budget_type_code,
                    budget_entry_method_code
           INTO     l_budget_type_code,
                    l_budget_entry_method_code
           FROM     pa_budget_versions
           WHERE    budget_version_id = p_fin_plan_version_id;
   EXCEPTION
          WHEN OTHERS THEN
              RETURN NULL;
   END;


   IF   l_budget_type_code  IS NOT NULL
   THEN
           BEGIN
                   SELECT time_phased_type_code
                   INTO   l_time_phased_code
                   FROM   pa_budget_entry_methods
                   WHERE  budget_entry_method_code = l_budget_entry_method_code;
           EXCEPTION
                  WHEN OTHERS THEN
                      RETURN NULL;
           END;
   ELSE
           BEGIN
                   SELECT DECODE(fin_plan_preference_code,
                                 PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME, all_time_phased_code,
                                 PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY,         cost_time_phased_code,
                                 PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY,      revenue_time_phased_code)
                   INTO   l_time_phased_code
                   FROM   pa_proj_fp_options
                   WHERE  fin_plan_version_id = p_fin_plan_version_id;
           EXCEPTION
                  WHEN OTHERS THEN
                      RETURN NULL;
           END;
   END IF;

   RETURN l_time_phased_code;

END Get_Time_Phased_Code;

/*=============================================================================
  This function is used to return plan level code of the finplan version
==============================================================================*/

FUNCTION Get_Fin_Plan_Level_Code(
         p_fin_plan_version_id  IN   pa_proj_fp_options.fin_plan_version_id %TYPE )
RETURN   pa_proj_fp_options.all_fin_plan_level_code%TYPE
IS

   l_fin_plan_level_code  pa_proj_fp_options.all_fin_plan_level_code%TYPE;

BEGIN

   SELECT DECODE(fin_plan_preference_code,
                 PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME, all_fin_plan_level_code,
                 PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY,         cost_fin_plan_level_code,
                 PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY,      revenue_fin_plan_level_code)
   INTO   l_fin_plan_level_code
   FROM   pa_proj_fp_options
   WHERE  fin_plan_version_id = p_fin_plan_version_id;

   RETURN l_fin_plan_level_code;

END Get_Fin_Plan_Level_code;


/*=============================================================================
  This function is used to return multi currency flag for the finplan version
==============================================================================*/

FUNCTION Get_Multi_Curr_Flag(
         p_fin_plan_version_id  IN   pa_proj_fp_options.fin_plan_version_id %TYPE )
RETURN   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE
IS

   l_multi_curr_flag  pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;

BEGIN

   SELECT PLAN_IN_MULTI_CURR_FLAG
   INTO   l_multi_curr_flag
   FROM   pa_proj_fp_options
   WHERE  fin_plan_version_id = p_fin_plan_version_id;

   RETURN l_multi_curr_flag;

END Get_Multi_Curr_Flag;

/*=============================================================================
  This function returns planning level when an option id is input
==============================================================================*/

/* Changes for FP.M, Tracking Bug No - 3354518
Modifying the type of the IN parameter p_element_type
below as pa_fp_elements is being obsoleted. */

FUNCTION GET_OPTION_PLANNING_LEVEL(
         P_proj_fp_options_id  IN  pa_proj_fp_options.proj_fp_options_id%TYPE,
/*         p_element_type        IN  pa_fp_elements.element_type%TYPE)
   Modified as part of Changes for FP.M, Tracking Bug No - 3354518*/
         p_element_type        IN  pa_budget_versions.version_type%TYPE)
RETURN   pa_proj_fp_options.all_fin_plan_level_code%TYPE
IS
   l_fin_plan_level_code  pa_proj_fp_options.all_fin_plan_level_code%TYPE;

BEGIN

   SELECT DECODE(fin_plan_preference_code,
                 PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME, all_fin_plan_level_code,
                 PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY,         cost_fin_plan_level_code,
                 PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY,      revenue_fin_plan_level_code,
                 PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP,
                        DECODE(p_element_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,cost_fin_plan_level_code,
                                              PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE, revenue_fin_plan_level_code))
   INTO   l_fin_plan_level_code
   FROM   pa_proj_fp_options
   WHERE  proj_fp_options_id = p_proj_fp_options_id;

   RETURN l_fin_plan_level_code;

END GET_OPTION_PLANNING_LEVEL;


/*=============================================================================
  This function is used to return amount set id  of the finplan version
==============================================================================*/

FUNCTION Get_Amount_Set_Id(
         p_fin_plan_version_id  IN   pa_proj_fp_options.fin_plan_version_id %TYPE )
RETURN   pa_proj_fp_options.all_amount_set_id%TYPE
IS

   l_amount_set_id  pa_proj_fp_options.all_amount_set_id%TYPE;

BEGIN

   SELECT DECODE(fin_plan_preference_code,
                 PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME, all_amount_set_id,
                 PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY,         cost_amount_set_id,
                 PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY,      revenue_amount_set_id)
   INTO   l_amount_set_id
   FROM   pa_proj_fp_options
   WHERE  fin_plan_version_id = p_fin_plan_version_id;

   RETURN l_amount_set_id;

END Get_Amount_Set_Id;

/*=============================================================================
 Function Get_Period_Profile_End_Date
 Created: 9/18/02 by dlai
 Use: for Create Plan Version page VO query
==============================================================================*/

FUNCTION Get_Period_Profile_Start_Date
        (p_period_profile_id    IN   pa_budget_versions.period_profile_id%TYPE)
return pa_proj_period_profiles.period_name1%TYPE is
l_start_date    pa_proj_period_profiles.period_name1%TYPE;
BEGIN
  l_start_date := null;
  if p_period_profile_id is not null then
    select period_name1
      into l_start_date
      from pa_proj_period_profiles
      where period_profile_id = p_period_profile_id;
  end if; -- p_period_profile_id is not null
  return l_start_date;
EXCEPTION
  when no_data_found then
    return l_start_date;
END Get_Period_Profile_Start_Date;


/*=============================================================================
 Function Get_Period_Profile_End_Date
 Created: 9/18/02 by dlai
 Use: for Create Plan Version page VO query
==============================================================================*/
FUNCTION Get_Period_Profile_End_Date
        (p_period_profile_id    IN   pa_budget_versions.period_profile_id%TYPE)
return pa_proj_period_profiles.profile_end_period_name%TYPE is
l_end_date      pa_proj_period_profiles.profile_end_period_name%TYPE;
BEGIN
  l_end_date := null;
  if p_period_profile_id is not null then
    select profile_end_period_name
      into l_end_date
      from pa_proj_period_profiles
      where period_profile_id = p_period_profile_id;
  end if; -- p_period_profile_id is not null
  return l_end_date;
EXCEPTION
  when no_data_found then
    return l_end_date;
END Get_Period_Profile_End_Date;


/* This fuction will return  workplan budget version res_list_id */
FUNCTION Get_wp_bv_res_list_id
   ( p_proj_structure_version_id NUMBER)
RETURN NUMBER IS

l_wp_bv_res_list_id  NUMBER:=NULL;

BEGIN
    SELECT resource_list_id
    INTO   l_wp_bv_res_list_id
    FROM   pa_budget_versions
    WHERE  project_structure_version_id=p_proj_structure_version_id AND
    NVL(WP_VERSION_FLAG,'N')  = 'Y';

   RETURN l_wp_bv_res_list_id;

EXCEPTION
      WHEN  OTHERS THEN
            RETURN l_wp_bv_res_list_id;

END Get_wp_bv_res_list_id;

/*=============================================================================
   This function will return the time phase code
   of the budget_version_id for a given wp_structure_version_id.
   P->PA, G->Gl, N->None
==============================================================================*/
FUNCTION Get_wp_bv_time_phase
    (p_wp_structure_version_id IN PA_BUDGET_VERSIONS.PROJECT_STRUCTURE_VERSION_ID%TYPE)
RETURN VARCHAR2 IS
     x_time_phased_code   PA_PROJ_FP_OPTIONS.COST_TIME_PHASED_CODE%TYPE;
BEGIN
            SELECT  DECODE(BV.VERSION_TYPE,
                           'COST', OPT.COST_TIME_PHASED_CODE,
                           'REVENUE',OPT.REVENUE_TIME_PHASED_CODE,
                           'ALL',OPT.ALL_TIME_PHASED_CODE)
            INTO   x_time_phased_code
            FROM   PA_BUDGET_VERSIONS BV, PA_PROJ_FP_OPTIONS OPT
            WHERE  BV.BUDGET_VERSION_ID            = OPT.FIN_PLAN_VERSION_ID
            AND    BV.PROJECT_STRUCTURE_VERSION_ID = p_wp_structure_version_id
            AND    NVL(BV.WP_VERSION_FLAG,'N')  = 'Y'
            AND    bv.project_id = opt.project_id         -- added bug 6892631
            AND    bv.fin_plan_type_id = opt.fin_plan_type_id; -- added bug 6892631

            RETURN x_time_phased_code;
EXCEPTION
    WHEN OTHERS THEN
       RETURN null;

END Get_wp_bv_time_phase;

/*=============================================================================
   This function will return the approved cost budget current baselined version.
   If version is not available then it will return null value.
==============================================================================*/
FUNCTION Get_app_budget_cost_cb_ver
    (p_project_id     IN   pa_projects_all.project_id%TYPE)
RETURN NUMBER IS

  x_app_bdgt_cost_cb_ver  pa_budget_versions.budget_version_id%TYPE;

BEGIN

     /* Bug 3955810.
        In order to take care the old budget model also, removed the check
        for version_type is not null. In old budget model, version_type was
        not populated, but APPROVED_COST_PLAN_TYPE_FLAG is populated. */
     SELECT budget_version_id
     INTO   x_app_bdgt_cost_cb_ver
     FROM   pa_budget_versions
     WHERE  project_id     = p_project_id
     AND    nvl(APPROVED_COST_PLAN_TYPE_FLAG,'N') = 'Y'
     AND    budget_status_code                    = 'B'
     AND    current_flag                          = 'Y';

     RETURN x_app_bdgt_cost_cb_ver;

EXCEPTION
    WHEN OTHERS THEN
       RETURN null;
END Get_app_budget_cost_cb_ver;




/*=============================================================================
 This api is used to return latest baselined version info for given project id,
 plan type and version type
==============================================================================*/

PROCEDURE Get_Baselined_Version_Info(
          p_project_id            IN   pa_projects_all.project_id%TYPE
          ,p_fin_plan_type_id     IN   pa_budget_versions.fin_plan_type_id%TYPE
          ,p_version_type         IN   pa_budget_versions.version_type%TYPE
          ,x_fp_options_id         OUT  NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE --File.Sql.39 bug 4440895
          ,x_fin_plan_version_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_version_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data             OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS
    --Start of variables used for debugging

    l_msg_count          NUMBER :=0;
    l_data               VARCHAR2(2000);
    l_msg_data           VARCHAR2(2000);
    l_error_msg_code     VARCHAR2(30);
    l_msg_index_out      NUMBER;
    l_return_status      VARCHAR2(2000);
    l_debug_mode         VARCHAR2(30);

    --End of variables used for debugging

    l_fp_preference_code    pa_proj_fp_options.fin_plan_preference_code%TYPE;
    l_version_type          pa_budget_versions.version_type%TYPE;
    l_baselined_version_id  pa_budget_versions.budget_version_id%TYPE;
    l_fp_options_id         pa_proj_fp_options.proj_fp_options_id%TYPE;


BEGIN

 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Get_Baselined_Version_Info');
 END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Get_Baselined_Version_Info: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for business rules violations

    pa_debug.g_err_stage:='Validating input parameters';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Baselined_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL) OR
       (p_fin_plan_type_id IS NULL)
    THEN

             pa_debug.g_err_stage:='Project_id = '||p_project_id;
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('Get_Baselined_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);
             END IF;
             pa_debug.g_err_stage:='Fin_plan_type_id = '||p_fin_plan_type_id;
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('Get_Baselined_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);
             END IF;

             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

             RAISE Invalid_Arg_Exc;

    END IF;

    --Fetch fin plan preference code

    pa_debug.g_err_stage:='Fetching fin plan preference code ';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Baselined_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    SELECT fin_plan_preference_code
    INTO   l_fp_preference_code
    FROM   pa_proj_fp_options
    WHERE  project_id = p_project_id
    AND    fin_plan_type_id = p_fin_plan_type_id
    AND    fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;

    IF (l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) AND

       (p_version_type IS NULL) THEN

          --In this case version_type should be passed and so raise error

          pa_debug.g_err_stage:='Version_Type = '||p_version_type;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Get_Baselined_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);
          END IF;

          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                      p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

          RAISE Invalid_Arg_Exc;

    END IF;

    pa_debug.g_err_stage:='Parameter validation complete ';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Baselined_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Fetch  l_element_type ifn't passed and could be derived

    IF p_version_type IS NULL THEN

      IF l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME THEN

         l_version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL;

      ELSIF l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY THEN

         l_version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST;

      ELSIF l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY THEN

         l_version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE;

      END IF;

    END IF;

    --get baselined version if any

    pa_debug.g_err_stage:='Fetching Baselined Version';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Baselined_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    BEGIN

        SELECT budget_version_id
        INTO   l_baselined_version_id
        FROM   pa_budget_versions
        WHERE  project_id = p_project_id
        AND    fin_plan_type_id = p_fin_plan_type_id
        AND    version_type = NVL(p_version_type,l_version_type)
        AND    current_flag = 'Y'
        AND    ci_id IS NULL;         -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause ci_id IS NULL--Bug # 3507156

        --Fetch fp options id using plan version id

        pa_debug.g_err_stage:='Fetching fp options id';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Baselined_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        SELECT proj_fp_options_id
        INTO   l_fp_options_id
        FROM   pa_proj_fp_options
        WHERE  fin_plan_version_id = l_baselined_version_id;

    EXCEPTION

       WHEN NO_DATA_FOUND THEN

             l_baselined_version_id := NULL;

             l_fp_options_id := NULL;

    END;

    --return the parameters to calling program

    x_fin_plan_version_id := l_baselined_version_id;

    x_fp_options_id := l_fp_options_id;

    pa_debug.g_err_stage:='Exiting Get_Baselined_Version_Info';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Baselined_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
       pa_debug.reset_err_stack;
    END IF;
EXCEPTION

     WHEN Invalid_Arg_Exc THEN

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

           pa_debug.g_err_stage:='Invalid Arguments Passed';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('Get_Baselined_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);
              pa_debug.reset_err_stack;
	END IF;
           RAISE;

     WHEN Others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FIN_PLAN_UTILS'
                                  ,p_procedure_name  => 'GET_BASELINED_VERSION_INFO');

          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Get_Baselined_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_err_stack;
	END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Get_Baselined_Version_Info;


--=========================================================================
--bug #3224177
--      Refer to Update "16-JAN-04 sagarwal" in the history above.
--      This has been added as part of code merge
-- This procedure deletes the Financial Planning data pertaining
-- to the project id given as input parameter from
--      1. pa_fp_txn_currencies
--      2. pa_proj_fp_options
--      3. pa_fp_elements
--      4. pa_proj_period_profiles
--==========================================================================

procedure Delete_Fp_Options(
 p_project_id            IN       PA_FP_TXN_CURRENCIES.PROJECT_ID%TYPE
  , x_err_code           IN OUT   NOCOPY NUMBER) --File.Sql.39 bug 4440895
  is
  begin

  -- delete from pa_proj_fp_options table
    delete from pa_proj_fp_options where project_id=p_project_id;

  -- delete from pa_fp_txn_currencies table
    delete from pa_fp_txn_currencies where project_id=p_project_id;

/* Changes for FPM, Tracking Bug No - 3354518
   Commenting out code below   for delete statment from pa_fp_elements
   as this table is getting obsoleted */
   -- delete from pa_fp_elements table
/*    delete from pa_fp_elements where project_id=p_project_id; */

    -- delete from pa_proj_period_profiles table
    delete from pa_proj_period_profiles where project_id=p_project_id;

    /* Bug 3683382 this delete is not required functionally as records can not
       exist for a project level option in this table
    -- delete from pa_resource_assignments table
    delete from pa_resource_assignments where project_id = p_project_id;
    */

   /*start of bug 3342975 Refer to Update "16-JAN-04 sagarwal"
    in the history above. This has been added as part of code merge */
    -- delete from pa_fp_excluded_elements table

/* Changes for FPM, Tracking Bug No - 3354518
   Commenting out code below   for delete statment from pa_fp_excluded_elements
   as this table is getting obsoleted */
/* delete from pa_fp_excluded_elements where project_id = p_project_id; */

    -- delete from PA_FP_UPGRADE_AUDIT table
    delete from PA_FP_UPGRADE_AUDIT where project_id = p_project_id;

      /*end of bug 3342975 */
   exception
        when others then
                 x_err_code := SQLCODE;
                rollback;
         return;

  end Delete_Fp_Options;
--=========================================================================
--bug #3224177
--      Refer to Update "16-JAN-04 sagarwal" in the history above.
--      This has been added as part of code merge
-- This procedure updates the Project Currency in pa_fp_txn_currencies
-- whenever Porject currency is updated

-- FP M Phase II Development
-- Bug 3583619
--     Whenever there is a change in PC for a project, the change should be
--     propogated for workplan settings as well. In this case, validation api
--     takes care of not allowing the change if there is already any amount.
--     But, we can not disallow the change for the fact that there is workplan
--     plan type attached or workplan versions are present as user has no way
--     deleting the workplan plan type attached. This implies that all the fp
--     options of the project should be updated when this api is called.
--     Rewritten the complete api to update multiple options
--==========================================================================
PROCEDURE Update_Txn_Currencies
    (p_project_id        IN        PA_FP_TXN_CURRENCIES.PROJECT_ID%TYPE
     ,p_proj_curr_code   IN        PA_FP_TXN_CURRENCIES.TXN_CURRENCY_CODE%TYPE)
is
     cursor get_all_fp_options_cur is
        select proj_fp_options_id
        from   pa_proj_fp_options
        where  project_id = p_project_id;

     get_all_fp_options_rec  get_all_fp_options_cur%ROWTYPE;

     cursor get_project_currency (c_proj_fp_options_id NUMBER)is
        select fp_txn_currency_id,
               txn_currency_code
        from  pa_fp_txn_currencies
        where project_id = p_project_id
        and   project_currency_flag='Y'
        and   proj_fp_options_id = c_proj_fp_options_id;

     cursor get_proj_func_currency (c_proj_fp_options_id NUMBER)is
        select fp_txn_currency_id,
               txn_currency_code
        from  pa_fp_txn_currencies
        where project_id = p_project_id
        and   projfunc_currency_flag='Y'
        and   proj_fp_options_id = c_proj_fp_options_id;

     cursor check_proj_currency_exists (c_proj_fp_options_id NUMBER)is
         select fp_txn_currency_id
         from   pa_fp_txn_currencies
         where  project_id = p_project_id
         and    txn_currency_code = p_proj_curr_code
         and    project_currency_flag='N'
         and    proj_fp_options_id = c_proj_fp_options_id;

     /* Bug 5364011: The following code is introduced to update the plan_in_multi_curr_flag as 'Y'
        in pa_proj_fp_options, if the newly entered project currency is different from the
        existing project funtional currency. */
     TYPE plan_in_multi_curr_tbl IS TABLE OF pa_proj_fp_options.proj_fp_options_id%TYPE
     INDEX BY BINARY_INTEGER;
     l_plan_in_multi_curr_tbl plan_in_multi_curr_tbl;
     cnt NUMBER := 0;

     l_proj_curr_code       pa_fp_txn_currencies.txn_currency_code%TYPE;
     l_projfunc_curr_code   pa_fp_txn_currencies.txn_currency_code%TYPE;
     l_txn_currency_id      NUMBER;
     l_pc_currency_id       NUMBER;
     l_pfc_currency_id      NUMBER;

 begin
     open get_all_fp_options_cur;
     loop
         l_pc_currency_id := NULL;
         l_proj_curr_code := NULL;
         l_txn_currency_id := NULL;
         l_projfunc_curr_code := NULL;
         l_pfc_currency_id   := NULL;

         fetch get_all_fp_options_cur
          into  get_all_fp_options_rec;

         exit when get_all_fp_options_cur%NOTFOUND;

         -- for each of the options found update project currency

         open get_project_currency(get_all_fp_options_rec.proj_fp_options_id);
           fetch get_project_currency
            into l_pc_currency_id,l_proj_curr_code;
         close get_project_currency;

         open get_proj_func_currency(get_all_fp_options_rec.proj_fp_options_id);
           fetch get_proj_func_currency
           into l_pfc_currency_id,l_projfunc_curr_code;
         close get_proj_func_currency;

         if l_proj_curr_code is not null then
             if trim(l_proj_curr_code) <> trim(p_proj_curr_code) then

                 open check_proj_currency_exists(get_all_fp_options_rec.proj_fp_options_id);
                  fetch check_proj_currency_exists
                   into l_txn_currency_id;
                 close check_proj_currency_exists;

                 If trim(l_proj_curr_code) <> trim(l_projfunc_curr_code) then

                      -- if project currency is not equal to project functional currency

                       if (l_txn_currency_id is not NULL) then

                           -- delete the old project currency

                           delete from pa_fp_txn_currencies
                           where fp_txn_currency_id = l_txn_currency_id;

                           -- check if the new project currency selected by user is PFC
                           if (l_pfc_currency_id <> l_txn_currency_id) then

                               update pa_fp_txn_currencies
                               set txn_currency_code = p_proj_curr_code
                               where fp_txn_currency_id = l_pc_currency_id;

                           else
                               -- new PC selected by user is PFC

                               update pa_fp_txn_currencies
                               set txn_currency_code = p_proj_curr_code,
                                   projfunc_currency_flag = 'Y'
                               where fp_txn_currency_id = l_pc_currency_id;
                           end if; -- END FOR l_pfc_currency_id <> l_txn_currency_id
                       else
                           update pa_fp_txn_currencies
                           set txn_currency_code = p_proj_curr_code
                           where fp_txn_currency_id = l_pc_currency_id;

                       end if;
                 else
                     -- project currency and project functional currency are the same
                     -- update PC flag to N

                     update pa_fp_txn_currencies
                     set project_currency_flag='N'
                     where fp_txn_currency_id = l_pc_currency_id;

                     if (l_txn_currency_id is not NULL) then
                         -- if already existing txn currency is selected as PC
                         update pa_fp_txn_currencies
                         set project_currency_flag='Y'
                         where fp_txn_currency_id = l_txn_currency_id;
                     else
                         -- insert the new PC

                         INSERT INTO PA_FP_TXN_CURRENCIES (
                                              fp_txn_currency_id
                                              ,proj_fp_options_id
                                              ,project_id
                                              ,fin_plan_type_id
                                              ,fin_plan_version_id
                                              ,txn_currency_code
                                              ,default_rev_curr_flag
                                              ,default_cost_curr_flag
                                              ,default_all_curr_flag
                                              ,project_currency_flag
                                              ,projfunc_currency_flag
                                              ,last_update_date
                                              ,last_updated_by
                                              ,creation_date
                                              ,created_by
                                              ,last_update_login
                                              ,project_cost_exchange_rate
                                              ,project_rev_exchange_rate
                                              ,projfunc_cost_exchange_Rate
                                              ,projfunc_rev_exchange_Rate
                                              )
                                  SELECT pa_fp_txn_currencies_s.NEXTVAL
                                 ,      PROJ_FP_OPTIONS_ID
                                 ,      PROJECT_ID
                                 ,      FIN_PLAN_TYPE_ID
                                 ,      FIN_PLAN_VERSION_ID
                                 ,      p_proj_curr_code
                                 ,      DEFAULT_REV_CURR_FLAG
                                 ,      DEFAULT_COST_CURR_FLAG
                                 ,      DEFAULT_ALL_CURR_FLAG
                                 ,     'Y'
                                 ,     'N'
                                 ,      sysdate
                                 ,      fnd_global.user_id
                                 ,      sysdate
                                 ,      fnd_global.user_id
                                 ,      fnd_global.login_id
                                 ,      PROJECT_COST_EXCHANGE_RATE
                                 ,      PROJECT_REV_EXCHANGE_RATE
                                 ,      PROJFUNC_COST_EXCHANGE_RATE
                                 ,      PROJFUNC_REV_EXCHANGE_RATE
                                 FROM PA_FP_TXN_CURRENCIES
                                 where fp_txn_currency_id = l_pc_currency_id;
                     end if; -- l_txn_currency_id is not NULL ends
                 end if; -- l_proj_curr_code <> l_projfunc_curr_code ends
             end if; -- trim(l_proj_curr_code) <> trim(p_proj_curr_code)
         end if;

         /* Bug 5364011: The following code is introduced to update the plan_in_multi_curr_flag as 'Y'
            in pa_proj_fp_options, if the newly entered project currency is different from the existing
            project functional currency. */
            IF trim(p_proj_curr_code) <> trim(l_projfunc_curr_code) THEN
                cnt := cnt+1;
                l_plan_in_multi_curr_tbl(cnt) := get_all_fp_options_rec.proj_fp_options_id;
            END IF;

     end loop;
         /* Bug 5364011: The following code is introduced to update the plan_in_multi_curr_flag as 'Y'
            in pa_proj_fp_options, if the newly entered project currency is different from the existing
            project functional currency. */
           IF l_plan_in_multi_curr_tbl.COUNT > 0 THEN
              FORALL opt IN l_plan_in_multi_curr_tbl.FIRST..l_plan_in_multi_curr_tbl.LAST
                 UPDATE pa_proj_fp_options
                 SET    plan_in_multi_curr_flag = 'Y',
                        record_version_number = record_version_number+1
                 WHERE  proj_fp_options_id = l_plan_in_multi_curr_tbl(opt);
           END IF;
           l_plan_in_multi_curr_tbl.DELETE;

     close get_all_fp_options_cur;


exception
        when others then
        rollback;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Update_Txn_Currencies;


/*=============================================================================
 This api is used to return current working version info for given plan type,
 project id and version type
==============================================================================*/

PROCEDURE Get_Curr_Working_Version_Info(
          p_project_id            IN   pa_projects_all.project_id%TYPE
          ,p_fin_plan_type_id     IN   pa_budget_versions.fin_plan_type_id%TYPE
          ,p_version_type         IN   pa_budget_versions.version_type%TYPE
          ,x_fp_options_id         OUT  NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE --File.Sql.39 bug 4440895
          ,x_fin_plan_version_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_version_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data             OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

    --Start of variables used for debugging

    l_msg_count          NUMBER :=0;
    l_data               VARCHAR2(2000);
    l_msg_data           VARCHAR2(2000);
    l_error_msg_code     VARCHAR2(30);
    l_msg_index_out      NUMBER;
    l_return_status      VARCHAR2(2000);
    l_debug_mode         VARCHAR2(30);

    --End of variables used for debugging


    l_fp_preference_code  pa_proj_fp_options.fin_plan_preference_code%TYPE;
    l_version_type        pa_budget_versions.version_type%TYPE;
    l_current_working_version_id pa_budget_versions.budget_version_id%TYPE;
    l_fp_options_id       pa_proj_fp_options.proj_fp_options_id%TYPE;


BEGIN

   IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Get_Curr_Working_Version_Info');
   END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Get_Curr_Working_Version_Info: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for business rules violations

    pa_debug.g_err_stage:='Validating input parameters';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Curr_Working_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL) OR
       (p_fin_plan_type_id IS NULL)
    THEN

             pa_debug.g_err_stage:='Project_id = '||p_project_id;
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('Get_Curr_Working_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);
             END IF;
             pa_debug.g_err_stage:='Fin_plan_type_id = '||p_fin_plan_type_id;
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('Get_Curr_Working_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);
             END IF;

             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

             RAISE Invalid_Arg_Exc;

    END IF;

    --Fetch fin plan preference code

    pa_debug.g_err_stage:='Fetching fin plan preference code ';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Curr_Working_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    SELECT fin_plan_preference_code
    INTO   l_fp_preference_code
    FROM   pa_proj_fp_options
    WHERE  project_id = p_project_id
    AND    fin_plan_type_id = p_fin_plan_type_id
    AND    fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;

    IF (l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) AND

       (p_version_type IS NULL) THEN

          --In this case version_type should be passed and so raise error

          pa_debug.g_err_stage:='Version_Type = '||p_version_type;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Get_Curr_Working_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);
          END IF;

          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                      p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

          RAISE Invalid_Arg_Exc;

    END IF;

    pa_debug.g_err_stage:='Parameter validation complete ';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Curr_Working_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Fetch  l_element_type ifn't passed and could be derived

    IF p_version_type IS NULL THEN

      IF l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME THEN

         l_version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL;

      ELSIF l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY THEN

         l_version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST;

      ELSIF l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY THEN

         l_version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE;

      END IF;

    END IF;

    --Fetch the current working version

    BEGIN

        pa_debug.g_err_stage:='Fetching current working Version';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Curr_Working_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        SELECT budget_version_id
        INTO   l_current_working_version_id
        FROM   pa_budget_versions
        WHERE  project_id = p_project_id
        AND    fin_plan_type_id = p_fin_plan_type_id
        AND    version_type = NVL(p_version_type,l_version_type)
        AND    current_working_flag = 'Y'
        AND    ci_id IS NULL;         -- <Patchset M:B and F impact changes : AMG:> -- Added an extra clause ci_id IS NULL--Bug # 3507156

        --Fetch fp options id using plan version id

        pa_debug.g_err_stage:='Fetching fp option id';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Curr_Working_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        SELECT proj_fp_options_id
        INTO   l_fp_options_id
        FROM   pa_proj_fp_options
        WHERE  fin_plan_version_id = l_current_working_version_id;

    EXCEPTION

       WHEN NO_DATA_FOUND THEN

             l_current_working_version_id := NULL;

             l_fp_options_id := NULL;

    END;

    --return the parameters to calling programme

    x_fin_plan_version_id := l_current_working_version_id;

    x_fp_options_id := l_fp_options_id;

    pa_debug.g_err_stage:='Exiting Get_Curr_Working _Version_Info';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Curr_Working_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
    pa_debug.reset_err_stack;
END IF;
EXCEPTION

     WHEN Invalid_Arg_Exc THEN

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

           pa_debug.g_err_stage:='Invalid Arguments Passed';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('Get_Curr_Working_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);

           pa_debug.reset_err_stack;
	END IF;
           RAISE;

     WHEN Others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FIN_PLAN_UTILS'
                                  ,p_procedure_name  => 'Get_Curr_Working_Version_Info');

          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Get_Curr_Working_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);

          pa_debug.reset_err_stack;
	END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Get_Curr_Working_Version_Info;

/*=============================================================================
 This api is used to return approved cost plan type for given project
==============================================================================*/


PROCEDURE Get_Appr_Cost_Plan_Type_Info(
          p_project_id     IN   pa_projects_all.project_id%TYPE
          ,x_plan_type_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count     OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data      OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

    --Start of variables used for debugging

    l_msg_count          NUMBER :=0;
    l_data               VARCHAR2(2000);
    l_msg_data           VARCHAR2(2000);
    l_error_msg_code     VARCHAR2(30);
    l_msg_index_out      NUMBER;
    l_return_status      VARCHAR2(2000);
    l_debug_mode         VARCHAR2(30);

    --End of variables used for debugging

    l_fin_plan_type_id   pa_proj_fp_options.fin_plan_type_id%TYPE;


BEGIN

 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Get_Appr_Cost_Plan_Type_Info');
END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Get_Appr_Cost_Plan_Type_Info: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for business rules violations

    pa_debug.g_err_stage:='Validating input parameters';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Appr_Cost_Plan_Type_Info: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    -- project_id can't be null

    IF (p_project_id IS NULL)   THEN

        pa_debug.g_err_stage:='Project_id = '||p_project_id;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Appr_Cost_Plan_Type_Info: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE Invalid_Arg_Exc;

    END IF;

    pa_debug.g_err_stage:='Parameter validation complete ';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Appr_Cost_Plan_Type_Info: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Fetch approved plan type id

    BEGIN

        pa_debug.g_err_stage:='Fetching approved cost plan type id';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Appr_Cost_Plan_Type_Info: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        SELECT fin_plan_type_id
        INTO   l_fin_plan_type_id
        FROM   pa_proj_fp_options
        WHERE  project_id = p_project_id
          AND  fin_plan_option_level_code = 'PLAN_TYPE'
          AND  approved_cost_plan_type_flag = 'Y';

    EXCEPTION

         WHEN  NO_DATA_FOUND THEN

               l_fin_plan_type_id := NULL;

    END;

    --return the plan type id

    x_plan_type_id := l_fin_plan_type_id ;

    pa_debug.g_err_stage:='Exiting Get_Appr_Cost_Plan_Type_Info';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Appr_Cost_Plan_Type_Info: ' || l_module_name,pa_debug.g_err_stage,3);

    pa_debug.reset_err_stack;
END IF;
EXCEPTION

     WHEN Invalid_Arg_Exc THEN

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

           pa_debug.g_err_stage:='Invalid Arguments Passed';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('Get_Appr_Cost_Plan_Type_Info: ' || l_module_name,pa_debug.g_err_stage,5);

           pa_debug.reset_err_stack;
	END IF;
           RAISE;

     WHEN Others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FIN_PLAN_UTILS'
                                  ,p_procedure_name  => 'Get_Appr_Cost_Plan_Type_Info');

          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Get_Appr_Cost_Plan_Type_Info: ' || l_module_name,pa_debug.g_err_stage,5);

          pa_debug.reset_err_stack;
	END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Appr_Cost_Plan_Type_Info;

/*=============================================================================
 This api is used to return approved rev plan type for given project
==============================================================================*/

PROCEDURE Get_Appr_Rev_Plan_Type_Info(
          p_project_id     IN   pa_projects_all.project_id%TYPE
          ,x_plan_type_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count     OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data      OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS
    --Start of variables used for debugging

    l_msg_count          NUMBER :=0;
    l_data               VARCHAR2(2000);
    l_msg_data           VARCHAR2(2000);
    l_error_msg_code     VARCHAR2(30);
    l_msg_index_out      NUMBER;
    l_return_status      VARCHAR2(2000);
    l_debug_mode         VARCHAR2(30);

    --End of variables used for debugging

    l_fin_plan_type_id   pa_proj_fp_options.fin_plan_type_id%TYPE;


BEGIN

 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Get_Appr_Rev_Plan_Type_Info');
END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Get_Appr_Rev_Plan_Type_Info: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for business rules violations

    pa_debug.g_err_stage:='Validating input parameters';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Appr_Rev_Plan_Type_Info: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    -- project_id can't be null

    IF (p_project_id IS NULL)   THEN

        pa_debug.g_err_stage:='Project_id = '||p_project_id;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Appr_Rev_Plan_Type_Info: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE Invalid_Arg_Exc;

    END IF;

    pa_debug.g_err_stage:='Parameter validation complete ';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Appr_Rev_Plan_Type_Info: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Fetch approved plan type id

    BEGIN

        pa_debug.g_err_stage:='Fetching approved rev plan type id';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Appr_Rev_Plan_Type_Info: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        SELECT fin_plan_type_id
        INTO   l_fin_plan_type_id
        FROM   pa_proj_fp_options
        WHERE  project_id = p_project_id
          AND  fin_plan_option_level_code = 'PLAN_TYPE'
          AND  approved_rev_plan_type_flag = 'Y';

    EXCEPTION

        WHEN NO_DATA_FOUND THEN

              l_fin_plan_type_id := NULL;

    END;

    --return the plan type id

    x_plan_type_id := l_fin_plan_type_id ;

    pa_debug.g_err_stage:='Exiting Get_Appr_Rev_Plan_Type_Info';
    IF P_PA_DEBUG_MODE = 'Y' THEN
	       pa_debug.write('Get_Appr_Rev_Plan_Type_Info: ' || l_module_name,pa_debug.g_err_stage,3);
	    pa_debug.reset_err_stack;
	END IF;
EXCEPTION

     WHEN Invalid_Arg_Exc THEN

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

           pa_debug.g_err_stage:='Invalid Arguments Passed';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('Get_Appr_Rev_Plan_Type_Info: ' || l_module_name,pa_debug.g_err_stage,5);

           pa_debug.reset_err_stack;
	END IF;
           RAISE;

     WHEN Others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FIN_PLAN_UTILS'
                                  ,p_procedure_name  => 'Get_Appr_Rev_Plan_Type_Info');

          pa_debug.g_err_stage:='Unexpeted Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Get_Appr_Rev_Plan_Type_Info: ' || l_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_err_stack;
END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Appr_Rev_Plan_Type_Info;

/*=================================================================================
The procedure gets the amount set id for the combination of in flags if exists or
creates a new record in PA_FIN_PLAN_AMOUNT_SETS and returns it.

===================================================================================*/
PROCEDURE GET_OR_CREATE_AMOUNT_SET_ID
(
        p_raw_cost_flag          IN  pa_fin_plan_amount_sets.raw_cost_flag%TYPE,
        p_burdened_cost_flag     IN  pa_fin_plan_amount_sets.burdened_cost_flag%TYPE,
        p_revenue_flag           IN  pa_fin_plan_amount_sets.revenue_flag%TYPE,
        p_cost_qty_flag          IN  pa_fin_plan_amount_sets.cost_qty_flag%TYPE,
        p_revenue_qty_flag       IN  pa_fin_plan_amount_sets.revenue_qty_flag%TYPE,
        p_all_qty_flag           IN  pa_fin_plan_amount_sets.all_qty_flag%TYPE,
        p_plan_pref_code         IN  pa_proj_fp_options.fin_plan_preference_code%TYPE,
/* Changes for FP.M, Tracking Bug No - 3354518
Adding three new IN parameters p_bill_rate_flag,
p_cost_rate_flag, p_burden_rate below for
new columns in pa_fin_plan_amount_sets */
        p_bill_rate_flag         IN  pa_fin_plan_amount_sets.bill_rate_flag%TYPE,
         p_cost_rate_flag         IN  pa_fin_plan_amount_sets.cost_rate_flag%TYPE,
         p_burden_rate_flag       IN  pa_fin_plan_amount_sets.burden_rate_flag%TYPE,
        x_cost_amount_set_id     OUT NOCOPY pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE, --File.Sql.39 bug 4440895
        x_revenue_amount_set_id  OUT NOCOPY pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE, --File.Sql.39 bug 4440895
        x_all_amount_set_id      OUT NOCOPY pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE, --File.Sql.39 bug 4440895
        x_message_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_message_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

pragma autonomous_transaction;

l_status          VARCHAR2(10);
l_debug_mode      VARCHAR2(30);
l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_error_msg_code  VARCHAR2(30);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);



BEGIN
 IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_err_stack ('PA_FIN_PLAN_UTILS.GET_OR_CREATE_AMOUNT_SET_ID');
END IF;
        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'Y');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.set_process('GET_OR_CREATE_AMOUNT_SET_ID: ' || 'PLSQL','LOG',l_debug_mode);
        END IF;
        x_message_count := 0;

        x_return_status := FND_API.G_RET_STS_SUCCESS;


        -- Check for business rules violations

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage := 'Parameter Validation';
           pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        -- Check for all flags and preference code being null

/* Changes for FP.M, Tracking Bug No - 3354518
Adding checks for null value for three new
parameters p_bill_rate_flag,p_cost_rate_flag,
and p_burden_rate below based on the new
columns in pa_fin_plan_amount_sets */

        IF  p_raw_cost_flag is null or
            p_burdened_cost_flag is null or
            p_revenue_flag is null or
            p_cost_qty_flag is null or
            p_revenue_qty_flag is null or
            p_all_qty_flag is null or
            p_plan_pref_code is null or
             p_bill_rate_flag is null or
            p_cost_rate_flag is null or
            p_burden_rate_flag is null
            THEN

            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := 'All null flags or preference code is null';
                pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage := 'preference code is ' || p_plan_pref_code;
                pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage := 'raw cost flag is ' || p_raw_cost_flag;
                pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage := 'burdened cost flag is ' || p_burdened_cost_flag;
                pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage := 'cost quantity flag is ' || p_cost_qty_flag;
                pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage := 'revenue quantity flag is ' || p_revenue_qty_flag;
                pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage := 'all quantity flag is ' || p_all_qty_flag;
                pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage := 'revenue flag is ' || p_revenue_flag;
                pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,5);
            END IF;

/* Changes for FP.M, Tracking Bug No - 3354518
Adding debug code for three new
parameters p_bill_rate_flag,p_cost_rate_flag,
and p_burden_rate below based on the new
columns in pa_fin_plan_amount_sets */


            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := 'bill rate flag is ' || p_bill_rate_flag;
                pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage := 'cost rate flag is ' || p_cost_rate_flag;
                pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage := 'burden rate flag is ' || p_burden_rate_flag;
                pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,5);
            END IF;
/* Changes for FP.M, Tracking Bug No - 3354518 End here */


              PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                 p_msg_name            => 'PA_FP_INV_PARAM_PASSED');

            RAISE Invalid_Arg_Exc;

        END IF;

        -- End of business rule validations.

        pa_debug.g_err_stage := 'Get or Create cost amount set id';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        IF (p_plan_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY or p_plan_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) then
          BEGIN

/* Changes for FP.M, Tracking Bug No - 3354518
Appending where clause for three new column bill_rate_flag,
cost_rate_flag, burden_rate added to  pa_fin_plan_amount_sets
below*/
            select fin_plan_amount_set_id
                  into x_cost_amount_set_id
                  from pa_fin_plan_amount_sets
                  where
                  raw_cost_flag=p_raw_cost_flag and
                  burdened_cost_flag=p_burdened_cost_flag and
                  cost_qty_flag=p_cost_qty_flag and
                  revenue_flag = 'N' and
                  revenue_qty_flag = 'N' and
                  all_qty_flag = 'N' and
/* Changes for FPM Start here ,Tracking Bug No - 3354518*/
                  bill_rate_flag = 'N' and
                  cost_rate_flag = p_cost_rate_flag and
                  burden_rate_flag = p_burden_rate_flag and
/* Changes for FPM End here ,Tracking Bug No - 3354518*/
                  amount_set_type_code=PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST;

                  l_status := 'OLD';
              EXCEPTION
                  when NO_DATA_FOUND then
                           l_status := 'NEW';
              END;

                 pa_debug.g_err_stage := 'Create cost amount set id';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,3);
                 END IF;

/* Changes for FP.M, Tracking Bug No - 3354518
Adding three new column bill_rate_flag,cost_rate_flag,
burden_rate to the insert statment below */

              IF l_status = 'NEW' THEN
                  INSERT INTO PA_FIN_PLAN_AMOUNT_SETS (
                  FIN_PLAN_AMOUNT_SET_ID,
                  AMOUNT_SET_TYPE_CODE,
                  RAW_COST_FLAG,
                  BURDENED_COST_FLAG,
                  COST_QTY_FLAG,
                  REVENUE_FLAG,
                  REVENUE_QTY_FLAG,
                  ALL_QTY_FLAG,
                  TP_COST_FLAG,
                  TP_REVENUE_FLAG,
                  UTIL_PERCENT_FLAG,
                  UTIL_HOURS_FLAG,
                  CAPACITY_FLAG,
                  PRE_DEFINED_FLAG,
/* Changes for FPM Start here ,Tracking Bug No - 3354518*/
                  BILL_RATE_FLAG,
                  COST_RATE_FLAG,
                  BURDEN_RATE_FLAG,
/* Changes for FPM Start here ,Tracking Bug No - 3354518*/
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN
                   )
                  VALUES (
                  pa_fin_plan_amount_sets_s.NEXTVAL,
                  'COST',
                  p_raw_cost_flag,
                  p_burdened_cost_flag,
                  p_cost_qty_flag,
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
                  'N',
/* Changes for FPM Start here ,Tracking Bug No - 3354518*/
                  'N',
                   p_cost_rate_flag,
                   p_burden_rate_flag,
/* Changes for FPM End here ,Tracking Bug No - 3354518*/
                  SYSDATE,
                  fnd_global.user_id,
                  sysdate,
                  fnd_global.user_id,
                  fnd_global.login_id) RETURNING FIN_PLAN_AMOUNT_SET_ID INTO x_cost_amount_set_id;

                  --SELECT pa_fin_plan_amount_sets_s.currval
                  --into x_cost_amount_set_id
                  --from dual;

                END IF;
        END IF; -- cost only


        pa_debug.g_err_stage := 'Get or Create revenue amount set id';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        IF p_plan_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY or p_plan_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP THEN
                BEGIN

/* Changes for FP.M, Tracking Bug No - 3354518
Appending where clause for three new column bill_rate_flag,
cost_rate_flag, burden_rate added to  pa_fin_plan_amount_sets
below*/
                  select fin_plan_amount_set_id
                  into x_revenue_amount_set_id
                  from pa_fin_plan_amount_sets
                  where
                  revenue_flag=p_revenue_flag and
                  revenue_qty_flag=p_revenue_qty_flag and
                  raw_cost_flag = 'N' and
                  burdened_cost_flag = 'N' and
                  cost_qty_flag = 'N' and
                  all_qty_flag = 'N' and
/* Changes for FPM Start here ,Tracking Bug No - 3354518*/
                  bill_rate_flag = p_bill_rate_flag and
                  cost_rate_flag = 'N' and
                  burden_rate_flag = 'N' and
/* Changes for FPM End here ,Tracking Bug No - 3354518*/
                  amount_set_type_code = 'REVENUE';

                  l_status := 'OLD';
                EXCEPTION
                  when NO_DATA_FOUND then
                           l_status := 'NEW';
                END;

                pa_debug.g_err_stage := 'Create revenue amount set id';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

                IF l_status = 'NEW' THEN

/* Changes for FP.M, Tracking Bug No - 3354518
Adding three new column bill_rate_flag,cost_rate_flag,
burden_rate to the insert statment below */

            INSERT INTO PA_FIN_PLAN_AMOUNT_SETS (
                      FIN_PLAN_AMOUNT_SET_ID,
                      AMOUNT_SET_TYPE_CODE,
                      RAW_COST_FLAG,
                      BURDENED_COST_FLAG,
                      COST_QTY_FLAG,
                      REVENUE_FLAG,
                      REVENUE_QTY_FLAG,
                      ALL_QTY_FLAG,
                      TP_COST_FLAG,
                      TP_REVENUE_FLAG,
                      UTIL_PERCENT_FLAG,
                      UTIL_HOURS_FLAG,
                      CAPACITY_FLAG,
                      PRE_DEFINED_FLAG,
    /* Changes for FPM Start here ,Tracking Bug No - 3354518*/
                      BILL_RATE_FLAG,
                      COST_RATE_FLAG,
                      BURDEN_RATE_FLAG,
    /* Changes for FPM End here ,Tracking Bug No - 3354518*/
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATE_LOGIN
                  )
                  VALUES (
                      pa_fin_plan_amount_sets_s.NEXTVAL,
                      'REVENUE',
                      'N',
                      'N',
                      'N',
                      p_revenue_flag,
                      p_revenue_qty_flag,
                      'N',
                      'N',
                      'N',
                      'N',
                      'N',
                      'N',
                      'N',
    /* Changes for FPM Start here ,Tracking Bug No - 3354518*/
                      p_bill_rate_flag,
              'N',
              'N',
    /* Changes for FPM End here ,Tracking Bug No - 3354518*/
                      SYSDATE,
                      fnd_global.user_id,
                      sysdate,
                      fnd_global.user_id,
                      fnd_global.login_id)
                  RETURNING FIN_PLAN_AMOUNT_SET_ID INTO x_revenue_amount_set_id;

                  --select pa_fin_plan_amount_sets_s.currval
                  --into x_revenue_amount_set_id
                  --from dual;

                END IF;
        END IF; -- revenue only

        pa_debug.g_err_stage := 'Get or Create all amount set id';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        IF p_plan_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME THEN
             BEGIN
/* Changes for FP.M, Tracking Bug No - 3354518
Appending where clause for three new column bill_rate_flag,
cost_rate_flag, burden_rate added to pa_fin_plan_amount_sets
below*/
                  select fin_plan_amount_set_id
                  into x_all_amount_set_id
                  from pa_fin_plan_amount_sets
                  where
                  raw_cost_flag=p_raw_cost_flag and
                  burdened_cost_flag=p_burdened_cost_flag and
                  revenue_flag=p_revenue_flag and
                  all_qty_flag=p_all_qty_flag and
                  cost_qty_flag = 'N' and
                  revenue_qty_flag = 'N' and
/* Changes for FPM Start here ,Tracking Bug No - 3354518*/
                  bill_rate_flag = p_bill_rate_flag and
                  cost_rate_flag = p_cost_rate_flag and
                  burden_rate_flag = p_burden_rate_flag and
/* Changes for FPM End here ,Tracking Bug No - 3354518*/
                  amount_set_type_code = 'ALL';


                  l_status := 'OLD';
              EXCEPTION
                  when NO_DATA_FOUND then
                           l_status := 'NEW';
              END;

                pa_debug.g_err_stage := 'Create cost amount set id';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

                IF l_status = 'NEW' THEN
 /* Changes for FP.M, Tracking Bug No - 3354518
Adding three new column bill_rate_flag,cost_rate_flag,
burden_rate to the insert statment below */
                 INSERT INTO PA_FIN_PLAN_AMOUNT_SETS (
                      FIN_PLAN_AMOUNT_SET_ID,
                      AMOUNT_SET_TYPE_CODE,
                      RAW_COST_FLAG,
                      BURDENED_COST_FLAG,
                      COST_QTY_FLAG,
                      REVENUE_FLAG,
                      REVENUE_QTY_FLAG,
                      ALL_QTY_FLAG ,
                      TP_COST_FLAG,
                      TP_REVENUE_FLAG,
                      UTIL_PERCENT_FLAG,
                      UTIL_HOURS_FLAG,
                      CAPACITY_FLAG,
                      PRE_DEFINED_FLAG,
    /* Changes for FPM Start here ,Tracking Bug No - 3354518*/
                      BILL_RATE_FLAG,
                      COST_RATE_FLAG,
                      BURDEN_RATE_FLAG,
    /* Changes for FPM End here ,Tracking Bug No - 3354518*/
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATE_LOGIN
                  )
                  VALUES (
                      pa_fin_plan_amount_sets_s.NEXTVAL,
                      'ALL',
                      p_raw_cost_flag,
                      p_burdened_cost_flag,
                      'N',
                      p_revenue_flag,
                      'N',
                      p_all_qty_flag,
                      'N',
                      'N',
                      'N',
                      'N',
                      'N',
                      'N',
    /* Changes for FPM Start here ,Tracking Bug No - 3354518*/
                      p_bill_rate_flag,
                      p_cost_rate_flag,
                      p_burden_rate_flag,
    /* Changes for FPM End here ,Tracking Bug No - 3354518*/
                      SYSDATE,
                      fnd_global.user_id,
                      sysdate,
                      fnd_global.user_id,
                      fnd_global.login_id)
                  RETURNING FIN_PLAN_AMOUNT_SET_ID INTO x_all_amount_set_id;

                  --select pa_fin_plan_amount_sets_s.currval
                  --into x_all_amount_set_id
                  --from dual;
         END IF;
   END IF; -- cost and revenue

   commit;
 IF P_PA_DEBUG_MODE = 'Y' THEN
   pa_debug.reset_err_stack;
END IF;
EXCEPTION
   WHEN Invalid_Arg_Exc THEN

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count = 1 THEN

             PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded        => FND_API.G_TRUE
                    ,p_msg_index      => 1
                    ,p_msg_count      => l_msg_count
                    ,p_msg_data       => l_msg_data
                    ,p_data           => l_data
                    ,p_msg_index_out  => l_msg_index_out);

             x_message_data := l_data;
             x_message_count := l_msg_count;

        ELSE

            x_message_count := l_msg_count;

        END IF;

        x_return_status:= FND_API.G_RET_STS_ERROR;

 IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.reset_err_stack;
  END IF;
        rollback;

 WHEN Others THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_message_count     := 1;
        x_message_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_FIN_PLAN_UTILS'
                                ,p_procedure_name => 'GET_OR_CREATE_AMOUNT_SET_ID');

        pa_debug.g_err_stage:='Unexpected Error';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('GET_OR_CREATE_AMOUNT_SET_ID: ' || l_module_name,pa_debug.g_err_stage,5);

        pa_debug.reset_err_stack;
	END IF;
        rollback;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_OR_CREATE_AMOUNT_SET_ID;

/*=================================================================================
Given the amount set id the procedure return the flags.
===================================================================================*/
PROCEDURE GET_PLAN_AMOUNT_FLAGS(
      P_AMOUNT_SET_ID       IN  PA_FIN_PLAN_AMOUNT_SETS.fin_plan_amount_set_id%TYPE,
      X_RAW_COST_FLAG       OUT NOCOPY PA_FIN_PLAN_AMOUNT_SETS.raw_cost_flag%TYPE, --File.Sql.39 bug 4440895
      X_BURDENED_FLAG       OUT NOCOPY PA_FIN_PLAN_AMOUNT_SETS.burdened_cost_flag%TYPE, --File.Sql.39 bug 4440895
      X_REVENUE_FLAG        OUT NOCOPY PA_FIN_PLAN_AMOUNT_SETS.revenue_flag%TYPE, --File.Sql.39 bug 4440895
      X_COST_QUANTITY_FLAG  OUT NOCOPY PA_FIN_PLAN_AMOUNT_SETS.cost_qty_flag%TYPE, --File.Sql.39 bug 4440895
      X_REV_QUANTITY_FLAG   OUT NOCOPY PA_FIN_PLAN_AMOUNT_SETS.revenue_qty_flag%TYPE, --File.Sql.39 bug 4440895
      X_ALL_QUANTITY_FLAG   OUT NOCOPY PA_FIN_PLAN_AMOUNT_SETS.all_qty_flag%TYPE, --File.Sql.39 bug 4440895
/* Changes for FP.M, Tracking Bug No - 3354518
Adding three new OUT parameters x_bill_rate_flag,
x_cost_rate_flag, x_burden_rate below for
new columns in pa_fin_plan_amount_sets */
      X_BILL_RATE_FLAG      OUT  NOCOPY pa_fin_plan_amount_sets.bill_rate_flag%TYPE, --File.Sql.39 bug 4440895
      X_COST_RATE_FLAG      OUT  NOCOPY pa_fin_plan_amount_sets.cost_rate_flag%TYPE, --File.Sql.39 bug 4440895
      X_BURDEN_RATE_FLAG    OUT  NOCOPY pa_fin_plan_amount_sets.burden_rate_flag%TYPE,           --File.Sql.39 bug 4440895
      x_message_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_message_data        OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
        l_debug_mode      VARCHAR2(30);
        l_msg_count       NUMBER := 0;
        l_data            VARCHAR2(2000);
        l_msg_data        VARCHAR2(2000);
        l_error_msg_code  VARCHAR2(30);
        l_msg_index_out   NUMBER;
        l_return_status   VARCHAR2(2000);

BEGIN

	 IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_err_stack ('PA_FIN_PLAN_UTILS.GET_PLAN_AMOUNT_FLAGS');
	END IF;
        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'Y');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.set_process('GET_PLAN_AMOUNT_FLAGS: ' || 'PLSQL','LOG',l_debug_mode);
        END IF;
        x_message_count := 0;

        x_return_status := FND_API.G_RET_STS_SUCCESS;


        -- Check for business rules violations

        pa_debug.g_err_stage := 'Parameter Validation';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('GET_PLAN_AMOUNT_FLAGS: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        -- Check for amount set id being null


        IF  P_AMOUNT_SET_ID is null THEN

            pa_debug.g_err_stage := 'Check for null AMOUNT SET ID';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('GET_PLAN_AMOUNT_FLAGS: ' || l_module_name,pa_debug.g_err_stage,5);
            END IF;

            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                 p_msg_name            => 'PA_FP_INV_PARAM_PASSED');

            RAISE Invalid_Arg_Exc;

        END IF;
/* Changes for FP.M, Tracking Bug No - 3354518
Appending where clause for three new column bill_rate_flag,
cost_rate_flag, burden_rate added to pa_fin_plan_amount_sets
below*/

        select raw_cost_flag,
          burdened_cost_flag,
          revenue_flag,
          cost_qty_flag,
          revenue_qty_flag,
          all_qty_flag,
/* Changes for FPM Start here ,Tracking Bug No - 3354518*/
          bill_rate_flag,
          cost_rate_flag,
          burden_rate_flag
/* Changes for FPM End here ,Tracking Bug No - 3354518*/
        into
          X_RAW_COST_FLAG,
          X_BURDENED_FLAG,
          X_REVENUE_FLAG,
          X_COST_QUANTITY_FLAG,
          X_REV_QUANTITY_FLAG,
          X_ALL_QUANTITY_FLAG,
/* Changes for FPM Start here ,Tracking Bug No - 3354518*/
          X_BILL_RATE_FLAG,
          X_COST_RATE_FLAG,
          X_BURDEN_RATE_FLAG
/* Changes for FPM End here ,Tracking Bug No - 3354518*/
        from
          PA_FIN_PLAN_AMOUNT_SETS
        where
          fin_plan_amount_set_id = P_AMOUNT_SET_ID;

 IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.reset_err_stack;
 END IF;
EXCEPTION
   WHEN Invalid_Arg_Exc THEN

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count = 1 THEN

             PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded        => FND_API.G_TRUE
                    ,p_msg_index      => 1
                    ,p_msg_count      => l_msg_count
                    ,p_msg_data       => l_msg_data
                    ,p_data           => l_data
                    ,p_msg_index_out  => l_msg_index_out);

             x_message_data := l_data;
             x_message_count := l_msg_count;

        ELSE

            x_message_count := l_msg_count;

        END IF;

        x_return_status:= FND_API.G_RET_STS_ERROR;

 IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.reset_err_stack;
END IF;
        RAISE;

 WHEN Others THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_message_count     := 1;
        x_message_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_FIN_PLAN_UTILS'
                                ,p_procedure_name => 'GET_PLAN_AMOUNT_FLAGS');

        pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('GET_PLAN_AMOUNT_FLAGS: ' || l_module_name,pa_debug.g_err_stage,5);

        pa_debug.reset_err_stack;
       END IF;
        rollback;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_PLAN_AMOUNT_FLAGS;

/* =====================================================
   FUNCTION is_orgforecast_plan
   Takes as input a budget version id, and returns 'Y' if
   its PLAN_TYPE_CODE is 'ORG_FORECAST'.  Otherwise, returns 'N'
   ===================================================== */
FUNCTION is_orgforecast_plan
    (p_budget_version_id    IN  pa_budget_versions.budget_version_id%TYPE)
return VARCHAR2
is

l_plan_type_code    pa_fin_plan_types_b.fin_plan_type_code%TYPE;
l_return_value      VARCHAR2(1);
BEGIN
  l_return_value := 'N';
  select pt.fin_plan_type_code
    into l_plan_type_code
    from pa_budget_versions bv,
         pa_fin_plan_types_b pt
    where bv.budget_version_id = p_budget_version_id and
          bv.fin_plan_type_id = pt.fin_plan_type_id;
  if l_plan_type_code = 'ORG_FORECAST' then
    l_return_value := 'Y';
  end if;
  return(l_return_value);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          return(l_return_value);
     WHEN OTHERS THEN
          return(l_return_value);
END is_orgforecast_plan;


/* =====================================================
   FUNCTION get_person_name
   Takes as input the person_id, and returns the person
   name.  Returns null if name not found.
   ===================================================== */
FUNCTION get_person_name (p_person_id  IN  NUMBER) return VARCHAR2 is

l_person_name   VARCHAR2(240);

BEGIN
  select full_name
    into l_person_name
    from per_people_x
    where person_id = p_person_id;
  return l_person_name;

EXCEPTION
  WHEN  NO_DATA_FOUND THEN
    IF p_person_id = -98 THEN
        return 'PeriodProfileRefresh'; /* Added this IF block for bug 2746379 */
    ELSIF  p_person_id = -99 THEN
        return 'WBSRefresh'; /* Added this IF block for bug 3123826 */
    ELSE
        return null;
    END IF;
  WHEN OTHERS THEN
    return null;
END get_person_name;

/* =====================================================
   PROCEDURE  Get_Peceding_Suceeding_Prd_Info
   Procedure which returns the start date and enddate
   period info of Succeeding and Preceding periods
   ===================================================== */


PROCEDURE Get_Peceding_Suceeding_Pd_Info
      (   p_resource_assignment_id     IN  pa_budget_lines.RESOURCE_ASSIGNMENT_ID%TYPE
         ,p_txn_currency_code          IN  pa_budget_lines.TXN_CURRENCY_CODE%TYPE
         ,x_preceding_prd_start_date  OUT  NOCOPY DATE --File.Sql.39 bug 4440895
         ,x_preceding_prd_end_date    OUT  NOCOPY DATE --File.Sql.39 bug 4440895
         ,x_succeeding_prd_start_date OUT  NOCOPY DATE --File.Sql.39 bug 4440895
         ,x_succeeding_prd_end_date   OUT  NOCOPY DATE --File.Sql.39 bug 4440895
         ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ) IS

  CURSOR period_info_cur IS
  SELECT start_date
        ,end_date
        ,bucketing_period_code
    FROM pa_budget_lines
   WHERE resource_assignment_id = p_resource_assignment_id
     AND txn_currency_code = p_txn_currency_code
     AND bucketing_period_code in ('SD','PD');

     l_period_info_rec    period_info_cur%ROWTYPE;
     l_return_status      VARCHAR2(2000);
     l_msg_count          NUMBER :=0;
     l_msg_data           VARCHAR2(2000);
     l_data               VARCHAR2(2000);
     l_msg_index_out      NUMBER;
     l_debug_mode         VARCHAR2(30);
     l_module_name VARCHAR2(100) := 'pa.plsql.PA_FIN_PLAN_UTILS';

 BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Get_Peceding_Suceeding_Prd_Info');
END IF;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('Get_Peceding_Suceeding_Pd_Info: ' || 'PLSQL','LOG',l_debug_mode);
     END IF;

     -- Check for not null parameters

     pa_debug.g_err_stage := 'Checking for valid parameters:';
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Get_Peceding_Suceeding_Pd_Info: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF (p_resource_assignment_id  IS NULL) OR
        (p_txn_currency_code IS NULL)
     THEN

         pa_debug.g_err_stage := 'resource_assignment_id='||to_char(p_resource_assignment_id);
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Get_Peceding_Suceeding_Pd_Info: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;
         pa_debug.g_err_stage := 'txn currency code ='||p_txn_currency_code;
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Get_Peceding_Suceeding_Pd_Info: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;

         PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;

      FOR  l_period_info_rec IN  period_info_cur LOOP
              IF ( l_period_info_rec.bucketing_period_code = 'PD' ) THEN
                       x_preceding_prd_start_date := l_period_info_rec.start_date ;
                       x_preceding_prd_end_date := l_period_info_rec.end_date ;
              ELSIF ( l_period_info_rec.bucketing_period_code = 'SD') THEN
                       x_succeeding_prd_start_date := l_period_info_rec.start_date ;
                       x_succeeding_prd_end_date := l_period_info_rec.end_date ;
              END IF;

     END LOOP;
 IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.reset_err_stack;
 END IF;
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

         pa_debug.g_err_stage:='Invalid Arguments Passed';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Get_Peceding_Suceeding_Pd_Info: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;

         x_return_status:= FND_API.G_RET_STS_ERROR;

 IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.reset_err_stack;
END IF;
         RAISE;

   WHEN Others THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FIN_PLAN_UTILS'
                        ,p_procedure_name  => 'Get_Peceding_Suceeding_Pd_Info');

        pa_debug.g_err_stage:='Unexpected Error';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Peceding_Suceeding_Pd_Info: ' || l_module_name,pa_debug.g_err_stage,5);
        pa_debug.reset_err_stack;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END Get_Peceding_Suceeding_Pd_Info;


/* =====================================================
   PROCEDURE  Get_Element_Proj_PF_Amounts
   Returns the sum of raw,burdened,revenue and quantity in
   project and project Functional currencies.
   ===================================================== */

 PROCEDURE Get_Element_Proj_PF_Amounts
         (
           p_resource_assignment_id       IN   pa_budget_lines.RESOURCE_ASSIGNMENT_ID%TYPE
          ,p_txn_currency_code            IN   pa_budget_lines.TXN_CURRENCY_CODE%TYPE
          ,x_quantity                     OUT  NOCOPY pa_budget_lines.QUANTITY%TYPE --File.Sql.39 bug 4440895
          ,x_project_raw_cost             OUT  NOCOPY pa_budget_lines.TXN_RAW_COST%TYPE --File.Sql.39 bug 4440895
          ,x_project_burdened_cost        OUT  NOCOPY pa_budget_lines.TXN_BURDENED_COST%TYPE --File.Sql.39 bug 4440895
          ,x_project_revenue              OUT  NOCOPY pa_budget_lines.TXN_REVENUE%TYPE --File.Sql.39 bug 4440895
          ,x_projfunc_raw_cost            OUT  NOCOPY pa_budget_lines.TXN_RAW_COST%TYPE --File.Sql.39 bug 4440895
          ,x_projfunc_burdened_cost       OUT  NOCOPY pa_budget_lines.TXN_BURDENED_COST%TYPE --File.Sql.39 bug 4440895
          ,x_projfunc_revenue             OUT  NOCOPY pa_budget_lines.TXN_REVENUE%TYPE --File.Sql.39 bug 4440895
          ,x_return_status                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                    OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          )
  IS

       l_return_status      VARCHAR2(2000);
       l_msg_count          NUMBER :=0;
       l_msg_data           VARCHAR2(2000);
       l_data               VARCHAR2(2000);
       l_msg_index_out      NUMBER;
       l_debug_mode         VARCHAR2(30);
       l_module_name VARCHAR2(100) := 'pa.plsql.PA_FIN_PLAN_UTILS';

  BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Get_Element_Prj_Pf_Amounts');
  END IF;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('Get_Element_Proj_PF_Amounts: ' || 'PLSQL','LOG',l_debug_mode);
     END IF;

     -- Check for not null parameters

     pa_debug.g_err_stage := 'Checking for valid parameters:';
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Get_Element_Proj_PF_Amounts: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF (p_resource_assignment_id  IS NULL) OR
        (p_txn_currency_code IS NULL)
     THEN

         pa_debug.g_err_stage := 'resource_assignment_id='||to_char(p_resource_assignment_id);
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Get_Element_Proj_PF_Amounts: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;
         pa_debug.g_err_stage := 'txn currency code ='||p_txn_currency_code;
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Get_Element_Proj_PF_Amounts: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;

         PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;

     BEGIN
     SELECT sum(nvl(QUANTITY,0))
           ,sum(nvl(RAW_COST,0))
           ,sum(nvl(BURDENED_COST,0))
           ,sum(nvl(REVENUE,0))
           ,sum(nvl(PROJECT_RAW_COST,0))
           ,sum(nvl(PROJECT_BURDENED_COST,0))
           ,sum(nvl(PROJECT_REVENUE,0))
      INTO  x_quantity
           ,x_projfunc_raw_cost
           ,x_projfunc_burdened_cost
           ,x_projfunc_revenue
           ,x_project_raw_cost
           ,x_project_burdened_cost
           ,x_project_revenue
      FROM pa_budget_lines
     WHERE resource_assignment_id = p_resource_assignment_id
       AND txn_currency_code = p_txn_currency_code ;
    EXCEPTION

            WHEN NO_DATA_FOUND THEN
            pa_debug.g_err_stage :='Invalid Combination of res. Assgnt Id and Txn currency code ';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('Get_Element_Proj_PF_Amounts: ' || l_module_name,pa_debug.g_err_stage,1);
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name => 'PA_BUDGET_LINE_NOT_FOUND' );
            RAISE PA_FP_ELEMENTS_PUB.Invalid_Arg_Exc;

          END;
 IF P_PA_DEBUG_MODE = 'Y' THEN
   pa_debug.reset_err_stack;
END IF;
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

              pa_debug.g_err_stage:='Invalid Arguments Passed';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('Get_Element_Proj_PF_Amounts: ' || l_module_name,pa_debug.g_err_stage,5);
              END IF;

              x_return_status:= FND_API.G_RET_STS_ERROR;

 IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.reset_err_stack;
  END IF;
              RAISE;

        WHEN Others THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count     := 1;
             x_msg_data      := SQLERRM;

             FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FIN_PLAN_UTILS'
                             ,p_procedure_name  => 'Get_Element_Proj_PF_Amounts');

             pa_debug.g_err_stage:='Unexpected Error';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('Get_Element_Proj_PF_Amounts: ' || l_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_err_stack;
	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END  Get_Element_Proj_PF_Amounts ;

 PROCEDURE Check_Version_Name_Or_id
          (
           p_budget_version_id            IN   pa_budget_versions.BUDGET_VERSION_ID%TYPE
          ,p_project_id                   IN   pa_budget_versions.project_id%TYPE                -- Bug 2770562
          ,p_version_name                 IN   pa_budget_versions.VERSION_NAME%TYPE
          ,p_check_id_flag                IN   VARCHAR2
          ,x_budget_version_id            OUT  NOCOPY pa_budget_versions.BUDGET_VERSION_ID%TYPE --File.Sql.39 bug 4440895
          ,x_return_status                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                    OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          )

  IS
  l_msg_count                     NUMBER := 0;
  l_data                          VARCHAR2(2000);
  l_msg_data                      VARCHAR2(2000);
  l_msg_index_out                 NUMBER;
  l_debug_mode                    VARCHAR2(1);

  BEGIN
        x_msg_count := 0;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack ('pa_fin_plan_utils.check_version_name_or_id');
 END IF;
        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'N');
        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'Validating input parameters';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;

        IF (p_project_id IS NULL)                       -- Bug 2770562
        THEN
             IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'project id is null ';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
             END IF;
             PA_UTILS.ADD_MESSAGE
                   (p_app_short_name => 'PA',
                     p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;


        IF p_budget_version_id IS NOT NULL AND p_budget_version_id <> FND_API.G_MISS_NUM THEN
          IF p_check_id_flag = 'Y' THEN
            SELECT budget_version_id
            INTO   x_budget_version_id
            FROM   pa_budget_versions
            WHERE  budget_version_id = p_budget_version_id;
          ELSIF p_check_id_flag = 'N' THEN
             x_budget_version_id := p_budget_version_id;
          END IF;
        ELSE
           IF (p_version_name IS NOT NULL) THEN
             SELECT budget_version_id
             INTO   x_budget_version_id
             FROM   pa_budget_versions
             WHERE  version_name = p_version_name
             AND    project_id = p_project_id ;            -- Bug 2770562
          ELSE
             x_budget_version_id := NULL;
          END IF;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
	 IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.reset_err_stack;
	 END IF;
 EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN               -- Bug 2770562

          x_return_status := FND_API.G_RET_STS_ERROR;
          l_msg_count := FND_MSG_PUB.count_msg;

          IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
	 IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.reset_err_stack;
	END IF;
          x_budget_version_id := null;
          RETURN;

        WHEN NO_DATA_FOUND THEN
          x_return_status     := FND_API.G_RET_STS_ERROR;
          x_msg_count         := 1;
          PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                               p_msg_name            => 'PA_FP_VERSION_NAME_AMBIGOUS');
          x_budget_version_id := NULL;
        WHEN TOO_MANY_ROWS THEN
          x_return_status     := FND_API.G_RET_STS_ERROR;
          x_msg_count         := 1;
          PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                               p_msg_name            => 'PA_FP_VERSION_NAME_AMBIGOUS');
          x_budget_version_id := NULL;
        WHEN OTHERS THEN
          FND_MSG_PUB.ADD_EXC_MSG (p_pkg_name       => 'PA_FIN_PLAN_UTILS',
                                   p_procedure_name => pa_debug.g_err_stack );
          x_return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_data          := SQLERRM;
          x_budget_version_id := NULL;
          RAISE;
 END Check_Version_Name_Or_Id;

PROCEDURE Check_Currency_Name_Or_Code
          (
           p_txn_currency_code            IN   pa_fp_txn_currencies.txn_currency_code%TYPE
          ,p_currency_code_name           IN   VARCHAR2
          ,p_check_id_flag                IN   VARCHAR2
          ,x_txn_currency_code            OUT  NOCOPY pa_fp_txn_currencies.txn_currency_code%TYPE --File.Sql.39 bug 4440895
          ,x_return_status                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                    OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ) IS
 BEGIN
 IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack ('pa_fin_plan_utils.Check_Currency_Name_Or_Code');
 END IF;
        IF p_txn_currency_code IS NOT NULL  THEN
          pa_debug.g_err_stage:='Txn Currency Code is not null';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Check_Currency_Name_Or_Code: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          IF p_check_id_flag = 'Y' THEN
            SELECT txn_currency_code
            INTO  x_txn_currency_code
            FROM  pa_fp_txn_currencies
            WHERE  txn_currency_code = p_txn_currency_code;
          ELSIF p_check_id_flag = 'N' THEN
             x_txn_currency_code := p_txn_currency_code;
          END IF;
        ELSE
           pa_debug.g_err_stage:='Txn Currency Code is  null';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('Check_Currency_Name_Or_Code: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

           IF (p_currency_code_name IS NOT NULL) THEN
             pa_debug.g_err_stage:='Currency Code Name String is not null';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('Check_Currency_Name_Or_Code: ' || l_module_name,pa_debug.g_err_stage,3);
             END IF;

             -- Bug 4874283 - performance fix.  use TL table and rewrite select
             -- so that the NAME, LANGUAGE index can be used, if appropriate
             --
             -- SELECT currency_code
             -- INTO   x_txn_currency_code
             -- FROM   fnd_currencies_vl
             -- WHERE  p_currency_code_name = currency_code || ' - ' || name;

             SELECT currency_code
             INTO   x_txn_currency_code
             FROM   fnd_currencies_tl
             WHERE  name = replace(p_currency_code_name, currency_code || ' - ')
             AND    language = USERENV('LANG');

          ELSE
             pa_debug.g_err_stage:='Currency Code Name String is  null';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('Check_Currency_Name_Or_Code: ' || l_module_name,pa_debug.g_err_stage,3);
             END IF;
             x_txn_currency_code := NULL;
          END IF;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
	 IF P_PA_DEBUG_MODE = 'Y' THEN
	        pa_debug.reset_err_stack;
	  END IF;
 EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status     := FND_API.G_RET_STS_ERROR;
          x_msg_count         := 1;
          x_msg_data          := 'PA_FP_CURR_INVALID';
          x_txn_currency_code := NULL;
        WHEN TOO_MANY_ROWS THEN
          x_return_status     := FND_API.G_RET_STS_ERROR;
          x_msg_count         := 1;
          x_msg_data          := 'PA_FP_CURR_INVALID';
          x_txn_currency_code := NULL;
        WHEN OTHERS THEN
          fnd_msg_pub.add_exc_msg
           (p_pkg_name => 'PA_FIN_PLAN_UTILS',
            p_procedure_name => pa_debug.g_err_stack );
            x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
            x_txn_currency_code := NULL;
         RAISE;
 END Check_Currency_Name_Or_Code;

/* Changes for FP.M, Tracking Bug No - 3354518
Replacing all references of PA_TASKS by PA_STRUCT_TASK_WBS_V*/
/* Commenting code below for FP.M changes, Tracking Bug No - 3354518 */
/*PROCEDURE check_task_name_or_id
    (p_project_id       IN  pa_tasks.project_id%TYPE,
     p_task_id          IN  pa_tasks.task_id%TYPE,
     p_task_name        IN  pa_tasks.task_name%TYPE,
     p_check_id_flag    IN  VARCHAR2,
     x_task_id          OUT pa_tasks.task_id%TYPE,
     x_return_status    OUT VARCHAR2,
     x_msg_count        OUT NUMBER,
     x_error_msg        OUT VARCHAR2)*/
/* Rewriting procedure declaration below to refer to pa_struct_task_wbs_v
instead of pa_tasks - as part of worplan structure model changes in FP.M */
PROCEDURE check_task_name_or_id
    (p_project_id       IN  PA_STRUCT_TASK_WBS_V.project_id%TYPE,
     p_task_id          IN  PA_STRUCT_TASK_WBS_V.task_id%TYPE,
     p_task_name        IN  PA_STRUCT_TASK_WBS_V.task_name%TYPE,
     p_check_id_flag    IN  VARCHAR2,
     x_task_id          OUT NOCOPY PA_STRUCT_TASK_WBS_V.task_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_error_msg        OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
  l_msg_index_out       NUMBER;
BEGIN
 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.init_err_stack ('pa_fin_plan_utils.check_task_name_or_id');
 END IF;
    if p_task_id is not null AND p_task_id <> FND_API.G_MISS_NUM then
    if p_check_id_flag = 'Y' then
      -- validate the id that was passed in
      select task_id
        into x_task_id
        from PA_STRUCT_TASK_WBS_V -- Changes for FP.M, Tracking Bug No - 3354518
        where task_id = p_task_id;
    elsif p_check_id_flag = 'N' then
      -- just return the p_task_id, since we're not validating
      x_task_id := p_task_id;
    end if; -- p_check_id_flag
  else
    if p_task_name is not null then
      -- p_task_id = null, so we need to find the id
      select task_id
        into x_task_id
        from PA_STRUCT_TASK_WBS_V  -- Changes for FP.M, Tracking Bug No - 3354518
        where project_id = p_project_id and
              task_name = p_task_name;
    else
      x_task_id := null;
    end if;
  end if; -- p_task_id is null
  x_return_status := FND_API.G_RET_STS_SUCCESS;
	 IF P_PA_DEBUG_MODE = 'Y' THEN
	  pa_debug.reset_err_stack;
	 END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_task_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_error_msg := 'PA_FP_TASK_NAME_AMBIGUOUS';
      PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_FP_TASK_NAME_AMBIGUOUS');
      if x_msg_count = 1 then
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_error_msg,
                      p_msg_index_out  => l_msg_index_out);
      end if;
    WHEN TOO_MANY_ROWS THEN
      x_task_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_error_msg := 'PA_FP_TASK_NAME_AMBIGUOUS';
      PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_FP_TASK_NAME_AMBIGUOUS');
      if x_msg_count = 1 then
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_error_msg,
                      p_msg_index_out  => l_msg_index_out);
      end if;
    WHEN OTHERS THEN
      x_task_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.add_exc_msg(p_pkg_name        => 'PA_FIN_PLAN_UTILS',
                              p_procedure_name  => 'check_task_name_or_id');
      RAISE;
END check_task_name_or_id;

/* Changes for FP.M, Tracking Bug No - 3354518
   The procedure check_resource_gp_name_or_id is being obsoleted as the
   concept of Resource group is no longer there in case of the New dev
   model of FP.M. However we are adding code in the procedure below to raise
   a exception unconditionally for tracking/debuging purposes at the moment.
   Basically to note any calls made to this procedure. Eventually we shall be
   commenting out this procedure because of its nonusage.  */
-- returns RESOURCE_LIST_MEMBER_ID of resource group
PROCEDURE check_resource_gp_name_or_id
    (p_resource_id      IN  pa_resources.resource_id%TYPE,
     p_resource_name    IN  pa_resources.name%TYPE,
     p_check_id_flag    IN  VARCHAR2,
     x_resource_id      OUT NOCOPY pa_resource_list_members.resource_list_member_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_error_msg        OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
  l_msg_index_out       NUMBER;
BEGIN
 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.init_err_stack ('pa_fin_plan_utils.check_resource_gp_name_or_id');
 END IF;
    raise Invalid_Call_Exc; /* Changes for FP.M, Tracking Bug No - 3354518 */
    /*** bug 3683382 this piece code would never be executed as there is a immediate raise
    if p_resource_id is not null AND p_resource_id <> FND_API.G_MISS_NUM then
        if p_check_id_flag = 'Y' then
          -- validate the id that was passed in
          select resource_list_member_id
            into x_resource_id
            from pa_resource_list_members
            where resource_list_member_id = p_resource_id;
        elsif p_check_id_flag = 'N' then
          -- just return the p_resource_id, since we're not validating
          x_resource_id := p_resource_id;
        end if; -- p_check_id_flag
    else
        if p_resource_name is not null then
          -- p_resource_id = null, so we need to find the id
          select rlm.resource_list_member_id
            into x_resource_id
            from pa_resources r,
                 pa_resource_list_members rlm
            where r.name = p_resource_name and
                  r.resource_id = rlm.resource_id and
                  rlm.parent_member_id is null;
        else
          x_resource_id := null;
        end if;
    end if; -- p_resource_id is null
  bug 3683382 ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
	 IF P_PA_DEBUG_MODE = 'Y' THEN
	  pa_debug.reset_err_stack;
	END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_resource_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_error_msg := 'PA_FP_RES_NAME_AMBIGUOUS';
      PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_FP_RES_NAME_AMBIGUOUS');
      if x_msg_count = 1 then
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_error_msg,
                      p_msg_index_out  => l_msg_index_out);
      end if;
    WHEN TOO_MANY_ROWS THEN
      x_resource_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_error_msg := 'PA_FP_RES_NAME_AMBIGUOUS';
      PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_FP_RES_NAME_AMBIGUOUS');
      if x_msg_count = 1 then
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_error_msg,
                      p_msg_index_out  => l_msg_index_out);
      end if;
    WHEN Invalid_Call_Exc THEN  /* Changes for FP.M, Tracking Bug No - 3354518, Adding Exception handling block for Invalid_Call_Exc */
      x_resource_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.add_exc_msg(p_pkg_name        => 'PA_FIN_PLAN_UTILS',
                              p_procedure_name  => 'check_resource_gp_name_or_id');
      RAISE;
    WHEN OTHERS THEN
      x_resource_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.add_exc_msg(p_pkg_name        => 'PA_FIN_PLAN_UTILS',
                              p_procedure_name  => 'check_resource_gp_name_or_id');
      RAISE;
END check_resource_gp_name_or_id;

PROCEDURE check_resource_name_or_id
    (p_resource_id      IN  pa_resources.resource_id%TYPE,
     p_resource_name    IN  pa_resources.name%TYPE,
     p_check_id_flag    IN  VARCHAR2,
     x_resource_id      OUT NOCOPY pa_resources.resource_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_error_msg        OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
  l_msg_index_out       NUMBER;
BEGIN
 IF P_PA_DEBUG_MODE = 'Y' THEN
  pa_debug.init_err_stack ('pa_fin_plan_utils.check_resource_name_or_id');
 END IF;
  if p_resource_id is not null AND p_resource_id <> FND_API.G_MISS_NUM then
    if p_check_id_flag = 'Y' then
      -- validate the id that was passed in
      select resource_id
        into x_resource_id
        from pa_resources
        where resource_id = p_resource_id;
    elsif p_check_id_flag = 'N' then
      -- just return the p_resource_id, since we're not validating
      x_resource_id := p_resource_id;
    end if; -- p_check_id_flag
  else
    if p_resource_name is not null then
      -- p_resource_id = null, so we need to find the id
      select resource_id
        into x_resource_id
        from pa_resources
        where name = p_resource_name;
    else
      x_resource_id := null;
    end if;
  end if; -- p_resource_id is null
  x_return_status := FND_API.G_RET_STS_SUCCESS;
	 IF P_PA_DEBUG_MODE = 'Y' THEN
	  pa_debug.reset_err_stack;
	END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_resource_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_error_msg := 'PA_FP_RES_NAME_AMBIGUOUS';
      PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_FP_RES_NAME_AMBIGUOUS');
      if x_msg_count = 1 then
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_error_msg,
                      p_msg_index_out  => l_msg_index_out);
      end if;
    WHEN TOO_MANY_ROWS THEN
      x_resource_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      x_error_msg := 'PA_FP_RES_NAME_AMBIGUOUS';
      PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_FP_RES_NAME_AMBIGUOUS');
      if x_msg_count = 1 then
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_error_msg,
                      p_msg_index_out  => l_msg_index_out);
      end if;
    WHEN OTHERS THEN
      x_resource_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.add_exc_msg(p_pkg_name        => 'PA_FIN_PLAN_UTILS',
                              p_procedure_name  => 'check_resource_name_or_id');
      RAISE;
END check_resource_name_or_id;


FUNCTION Check_Proj_Fp_Options_Exists
  (p_project_id PA_PROJ_FP_OPTIONS.PROJECT_ID%type)
    return NUMBER
  IS
  l_dummy number;
BEGIN
     select 1
        into   l_dummy
        from   sys.dual
        where  exists
        /* Changes for FP.M, Tracking Bug No - 3354518
           Adding conditon in the where clause below to
           check for new column use_for_workplan flag.
           This column indicates if a plan type is being
           used for workplan or not.
        So adding a join to pa_fin_plan_types_b and checking status of use_for_workplan_flag.
           Without this check the function would return success status even if WP plantype exists */
            (select 1 from pa_proj_fp_options pfo, pa_fin_plan_types_b pft -- Added pa_fin_plan_types_b for FP.M changes
                where pfo.project_id = p_project_id
          /*Changes for FP.M start here */
            and pfo.fin_plan_option_level_code='PLAN_TYPE' /*bug 3224177 added fin_plan_option_level_code check*/
            and nvl(pfo.fin_plan_type_id,-99) = pft.fin_plan_type_id
            and nvl(pft.use_for_workplan_flag,'N') = 'N');
          /*Changes for FP.M end here */
        return 1;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
         return 0;
     WHEN OTHERS THEn
         return SQLCODE;
END Check_Proj_Fp_Options_Exists;



/* =================================================================
   FUNCTION get_amttype_id:  Created 9/14/02 by Danny Lai
   This function takes in an amount type code and returns the id
   associated with it.
   ================================================================= */
FUNCTION get_amttype_id
  ( p_amt_typ_code     IN pa_amount_types_b.amount_type_code%TYPE) RETURN NUMBER
is
    l_amount_type_id pa_amount_types_b.amount_type_id%TYPE;
    l_amt_code pa_fp_org_fcst_gen_pub.char240_data_type_table;   /* manoj: referred to pa_fp_org_fcst_gen_pub */
    l_amt_id   pa_fp_org_fcst_gen_pub.number_data_type_table;    /* manoj: referred to pa_fp_org_fcst_gen_pub */

    l_debug_mode VARCHAR2(30);

    CURSOR get_amt_det IS
    SELECT atb.amount_type_id
          ,atb.amount_type_code
      FROM pa_amount_types_b atb
     WHERE atb.amount_type_class = 'R';

    l_stage number := 0;

BEGIN
 IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.init_err_stack('pa_fin_plan_utils.get_amttype_id');
 END IF;

     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('get_amttype_id: ' || 'PLSQL','LOG',l_debug_mode);
     END IF;

       l_amount_type_id := -99;

       IF l_amt_code.last IS NULL THEN
          OPEN get_amt_det;
          LOOP
              FETCH get_amt_det into l_amt_id(nvl(l_amt_id.last+1,1))
                                    ,l_amt_code(nvl(l_amt_code.last+1,1));
              EXIT WHEN get_amt_det%NOTFOUND;
          END LOOP;
          CLOSE get_amt_det;
       END IF;

       IF l_amt_code.last IS NOT NULL THEN
          FOR i in l_amt_id.first..l_amt_id.last LOOP
              IF l_amt_code(i) = p_amt_typ_code THEN
                 l_amount_type_id := l_amt_id(i);
              END IF;
          END LOOP;
       END IF;
       IF l_amount_type_id = -99 THEN
                 pa_debug.g_err_stage := 'p_amt_typ_code         ['||p_amt_typ_code          ||']';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write_file('get_amttype_id: ' || pa_debug.g_err_stage);
                 END IF;
       END IF;
	 IF P_PA_DEBUG_MODE = 'Y' THEN
	       pa_debug.reset_err_stack;
	  END IF;
       RETURN(l_amount_type_id);

EXCEPTION
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'pa_fin_plan_utils.get_amttype_id'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);

              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('get_amttype_id: ' || SQLERRM);
                 pa_debug.reset_err_stack;
     	      END IF;
              RAISE;
END get_amttype_id;

/*=============================================================================
  Procedure Check_Locked_By_User:  Created 09/10/2002 by Danny Lai
  This function accepts a userid and a budget_version_id.
  If the budget version is locked by the user, x_locked_by_userid = 'Y'
  Otherwise, x_locked_by_userid = 'N' and x_locked_by_userid stores the user
  who has the version locked.
==============================================================================*/

PROCEDURE Check_Locked_By_User
        (p_user_id              IN      NUMBER,
         p_budget_version_id    IN      pa_budget_versions.budget_version_id%TYPE,
         x_is_locked_by_userid  OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_locked_by_person_id  OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
         x_return_status        OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_msg_count            OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
         x_msg_data             OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

cursor budget_csr is
  select locked_by_person_id,
         budget_status_code
    from pa_budget_versions
    where budget_version_id = p_budget_version_id;
budget_rec budget_csr%ROWTYPE;

l_person_id     pa_budget_versions.locked_by_person_id%TYPE;
l_resource_id   NUMBER;
l_resource_name per_all_people_f.full_name%TYPE; -- VARCHAR2(80); for bug # 2933777

-- local error handling variables
l_msg_count     NUMBER := 0;
l_msg_data      VARCHAR2(2000);
l_data          VARCHAR2(2000);
l_msg_index_out NUMBER;
l_module_name  VARCHAR2(100) := 'pa.plsql.pa_fin_plan_utils';

BEGIN
  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF P_PA_DEBUG_MODE = 'Y' THEN
  pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Check_Locked_By_User');
 END IF;
  /* CHECK FOR BUSINESS RULES VIOLATIONS */

  -- Check for VALID USER ID
IF P_PA_DEBUG_MODE = 'Y' THEN
  pa_debug.g_err_stage := 'calling get user info';
  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
END IF;
  /*
  Bug 2933777 : l_resource_name is obtained from the following procedure. But is not required
  for processing in this API. Hence UTF 8 impact is limited to fetching the value into a
  variable of correct length.
  */
  PA_COMP_PROFILE_PUB.GET_USER_INFO
          (p_user_id         => p_user_id,
           x_person_id       => l_person_id,
           x_resource_id     => l_resource_id,
           x_resource_name   => l_resource_name);
IF P_PA_DEBUG_MODE = 'Y' THEN
  pa_debug.g_err_stage := 'l_person_id = ' || l_person_id;
  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
END IF;
  if l_person_id is null then
    PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                         p_msg_name            => 'PA_FP_BAD_USER_ID');
    x_return_status := FND_API.G_RET_STS_ERROR;
  end if; -- error with p_user_id

  -- Check for VALID BUDGET VERSION ID
IF P_PA_DEBUG_MODE = 'Y' THEN
  pa_debug.g_err_stage := 'opening budget_csr';
  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
END IF;
  open budget_csr;
  fetch budget_csr into budget_rec;
  if budget_csr%NOTFOUND then
	IF P_PA_DEBUG_MODE = 'Y' THEN
	    pa_debug.g_err_stage := 'budget_csr notfound true';
	    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
	END IF;
    PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                         p_msg_name            => 'PA_FP_INVALID_PLAN_VERSION');
    x_return_status := FND_API.G_RET_STS_ERROR;
  end if; -- invalid budget_version_id
  close budget_csr;

  /* If There are ANY Business Rules Violations , Then Do NOT Proceed: RETURN */
    l_msg_count := FND_MSG_PUB.count_msg;
    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
	IF P_PA_DEBUG_MODE = 'Y' THEN
	        pa_debug.g_err_stage := 'l_msg_count = ' || l_msg_count;
	        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
	END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
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
	 IF P_PA_DEBUG_MODE = 'Y' THEN
	        pa_debug.reset_err_stack;
	END IF;
        return;
    end if;

  /* If NO VIOLATIONS, proceed */

  -- BASELINED VERSIONS ARE NEVER LOCKED BY ANYONE
  if budget_rec.budget_status_code = 'B' then
	IF P_PA_DEBUG_MODE = 'Y' THEN
	    pa_debug.g_err_stage := 'budget_rec.budget_status_code  = ' || budget_rec.budget_status_code;
	    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
	END IF;
    x_is_locked_by_userid := 'N';
  else
	IF P_PA_DEBUG_MODE = 'Y' THEN
	    pa_debug.g_err_stage := 'budget_rec.locked_by_person_id  = ' || budget_rec.locked_by_person_id;
	    pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
	END IF;
    if budget_rec.locked_by_person_id is null then
      -- BUDGET IS UNLOCKED

      x_is_locked_by_userid := 'N';
      x_locked_by_person_id := null;

    -- BUDGET IS LOCKED: LOOK FOR MATCH
    else
      if budget_rec.locked_by_person_id = l_person_id then
        -- FOUND MATCH
        x_is_locked_by_userid := 'Y';
        x_locked_by_person_id := l_person_id;
      else
        -- NO MATCH: VERSION IS LOCKED BY SOMEONE ELSE
        x_is_locked_by_userid := 'N';
        -- BUG FIX 2829725: incorrect locked_by_user_id
        --x_locked_by_person_id := l_person_id;
        x_locked_by_person_id := budget_rec.locked_by_person_id;
      end if; -- matching person id's
    end if; -- locked_by_person_id is null
  end if; -- budget_status_code
IF P_PA_DEBUG_MODE = 'Y' THEN
  pa_debug.g_err_stage := 'exiting check_locked_by_user';
  pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
  pa_debug.reset_err_stack;
END IF;
EXCEPTION
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name        => 'PA_FIN_PLAN_UTILS',
                              p_procedure_name  => 'Check_Locked_By_User');
 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.reset_err_stack;
 END IF;
      RAISE;
END Check_Locked_By_User;


/*=============================================================================
  Procedure Check_Both_Locked_By_User:  Created 09/10/2002 by Danny Lai
  This function accepts a userid and TWO budget_version_id's.
  If the budget version is locked by the user, x_locked_by_userid = 'Y'
  Otherwise, x_locked_by_userid = 'N'
  (this procedure calls Check_Locked_By_User twice)
==============================================================================*/

PROCEDURE Check_Both_Locked_By_User
        (p_user_id              IN      NUMBER,
         p_budget_version_id1   IN      pa_budget_versions.budget_version_id%TYPE,
         p_budget_version_id2   IN      pa_budget_versions.budget_version_id%TYPE,
         x_is_locked_by_userid  OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_return_status        OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_msg_count            OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
         x_msg_data             OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
l_is_locked_by_userid1 VARCHAR2(1);
l_is_locked_by_userid2 VARCHAR2(1);
l_locked_by_person_id   pa_budget_versions.locked_by_person_id%TYPE;

-- local error handling variables
l_return_status VARCHAR2(1);
l_msg_count     NUMBER := 0;
l_msg_data      VARCHAR2(2000);
l_data          VARCHAR2(2000);
l_msg_index_out NUMBER;

BEGIN
  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF P_PA_DEBUG_MODE = 'Y' THEN
  pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Check_Locked_By_User');
END IF;
  pa_fin_plan_utils.Check_Locked_By_User
        (p_user_id              => p_user_id,
         p_budget_version_id    => p_budget_version_id1,
         x_is_locked_by_userid  => l_is_locked_by_userid1,
         x_locked_by_person_id  => l_locked_by_person_id,
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data);
  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise pa_fin_plan_utils.Check_Locked_By_User_Exception;
  end if;

  pa_fin_plan_utils.Check_Locked_By_User
        (p_user_id              => p_user_id,
         p_budget_version_id    => p_budget_version_id2,
         x_is_locked_by_userid  => l_is_locked_by_userid2,
         x_locked_by_person_id  => l_locked_by_person_id,
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data);
  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise pa_fin_plan_utils.Check_Locked_By_User_Exception;
  end if;

  if l_is_locked_by_userid1 = 'Y' and l_is_locked_by_userid2 = 'Y' then
    x_is_locked_by_userid := 'Y';
  else
    x_is_locked_by_userid := 'N';
  end if;
 IF P_PA_DEBUG_MODE = 'Y' THEN
  pa_debug.reset_err_stack;
 END IF;
EXCEPTION
  WHEN pa_fin_plan_utils.Check_Locked_By_User_Exception THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('Check_Both_Locked_By_User: ' || 'Check_Locked_By_User_Exception reached');
      END IF;
      FND_MSG_PUB.add_exc_msg(p_pkg_name        => 'PA_FIN_PLAN_UTILS',
                              p_procedure_name  => 'Check_Both_Locked_By_User');
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name        => 'PA_FIN_PLAN_UTILS',
                              p_procedure_name  => 'Check_Both_Locked_By_User');
      RAISE;

END Check_Both_Locked_By_User;

FUNCTION check_budget_trans_exists
        (p_project_id           IN      pa_projects_all.project_id%TYPE)
        return VARCHAR2 is
l_return VARCHAR2(1) := 'N';
BEGIN
/* Bug 3106741
   Modified the second exists clause to avoid FT scan on pa_fp_txn_currencies
   table. As an index is available on proj_fp_options_id for the above table,
   pa_proj_fp_options table has been included to fetch all the options that
   belong to a given project.
 */

/* Commenting out the select statment below for FP.M, Tracking Bug No - 3354518
   The Select statement is modified and re-written below.
   Please note that the similar change is also done for bug no - 3224177 in version 115.117.
   The Select statment below has lot of redundant code which can be simplified
   to check for the existence of PLAN_TYPE fp_options only haveing use_for_workplan
   not set to 'Y'. Please note that this API will not be called for workplan Usage*/
/*
  Select 'Y'
  Into   l_return
  From   dual
  Where  exists (Select 'x'
                from    pa_budget_lines bl,
                        pa_budget_versions bv
                where   bl.budget_version_id = bv.budget_version_id
                and     bv.project_id = p_project_id)
          OR  exists (Select 'x'                       -- included for bug 3224177
               from  pa_proj_fp_options pfo,
                        pa_projects_all pa where
                        pfo.project_id = pa.project_id and
                              pa.project_id = p_project_id and
                              pfo.fin_plan_option_level_code = 'PLAN_TYPE');
/* commented for bug 3224177 starts
  OR    exists (Select 'x'
               from     pa_fp_txn_currencies fpcurr,
                        pa_proj_fp_options pfo, -- bug 3106741
                        pa_projects_all pa
               where    pa.project_currency_code = fpcurr.txn_currency_code
               and      pa.project_id = fpcurr.project_id
               and      fpcurr.project_currency_flag = 'Y'
               and      pfo.proj_fp_options_id = fpcurr.proj_fp_options_id -- bug 3106741
               and      pfo.project_id = pa.project_id -- bug 3106741
               and      pa.project_id = p_project_id
            and      pfo.fin_plan_option_level_code = 'PLAN_TYPE'  ); end of bug 3224177 comment*/


 /* Changes for FP.M, Tracking Bug No - 3354518 End here */
 /* Modified Select Clause */
  Select 'Y'
  Into   l_return
  From   dual
  Where  exists (Select 'x'
                from    pa_budget_lines bl,
                        pa_budget_versions bv
                where   bl.budget_version_id = bv.budget_version_id
                and     bv.project_id = p_project_id)
   OR  exists (Select   'x'                       -- included for bug 3224177
                 from   pa_proj_fp_options pfo, pa_fin_plan_types_b pft ,
                        pa_projects_all pa
             where   pfo.project_id = pa.project_id and
                        pa.project_id = p_project_id and
                        /* Commented out the below for bug 5364011*/
--                        pfo.fin_plan_option_level_code = 'PLAN_TYPE' and
                        pfo.fin_plan_option_level_code = 'PLAN_VERSION' and -- Bug 5364011.
               pfo.fin_plan_type_id = pft.fin_plan_type_id and
               nvl(pft.use_for_workplan_flag,'N') = 'N');

  /* Changes for FP.M, Tracking Bug No - 3354518 End here */

  return l_return;
Exception
  When No_Data_Found Then
    return l_return;
END check_budget_trans_exists;

FUNCTION enable_auto_baseline
        (p_project_id           IN      pa_projects_all.project_id%TYPE)
        return VARCHAR2 is
Cursor c1 is
Select  'Y'
from   pa_proj_fp_options po /* Bug# 2665767 - Plan type option alone can be checked */
where  po.approved_rev_plan_type_flag = 'Y'
and    po.fin_plan_preference_code = 'COST_AND_REV_SAME'
and    po.fin_plan_option_level_code = 'PLAN_TYPE'
and    po.project_id = p_project_id;

c1_rec   c1%rowtype;
l_return VARCHAR2(1);
BEGIN
  open c1;
  fetch c1 into c1_rec;
  if c1%notfound then
    close c1;
    l_return := 'Y';
  else
    close c1;
    l_return := 'N';
  end if;
  return l_return;
END enable_auto_baseline;


PROCEDURE Get_Resource_List_Info
         (p_resource_list_id           IN   pa_resource_lists.RESOURCE_LIST_ID%TYPE
         ,x_res_list_is_uncategorized  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_is_resource_list_grouped   OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_group_resource_type_id     OUT  NOCOPY pa_resource_lists.GROUP_RESOURCE_TYPE_ID%TYPE --File.Sql.39 bug 4440895
         ,x_return_status              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count                  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                   OUT  NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


       l_return_status      VARCHAR2(2000);
       l_msg_count          NUMBER :=0;
       l_msg_data           VARCHAR2(2000);
       l_data               VARCHAR2(2000);
       l_msg_index_out      NUMBER;
       l_debug_mode         VARCHAR2(30);

BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Get_Resource_List_Info');
END IF;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('Get_Resource_List_Info: ' || 'PLSQL','LOG',l_debug_mode);
     END IF;

     -- Check for not null parameters

     pa_debug.g_err_stage := 'Checking for valid parameters:';
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Get_Resource_List_Info: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF (p_resource_list_id  IS NULL)

     THEN

         pa_debug.g_err_stage := 'resource list id ='||to_char(p_resource_list_id);
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Get_Resource_List_Info: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;
         PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;

     SELECT nvl(uncategorized_flag,'N')
           ,decode (group_resource_type_id,0,'N','Y')
           ,group_resource_type_id
       INTO x_res_list_is_uncategorized
           ,x_is_resource_list_grouped
           ,x_group_resource_type_id
       FROM pa_resource_lists
      WHERE resource_list_id = p_resource_list_id ;

 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.reset_err_stack;
  END IF;
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

              pa_debug.g_err_stage:='Invalid Arguments Passed';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('Get_Resource_List_Info: ' || l_module_name,pa_debug.g_err_stage,5);
              END IF;

              x_return_status:= FND_API.G_RET_STS_ERROR;

 IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.reset_err_stack;
 END IF;
              RAISE;

        WHEN Others THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count     := 1;
             x_msg_data      := SQLERRM;

             FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FIN_PLAN_UTILS'
                             ,p_procedure_name  => 'Get_Resource_List_Info');

             pa_debug.g_err_stage:='Unexpected Error';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('Get_Resource_List_Info: ' || l_module_name,pa_debug.g_err_stage,5);

             pa_debug.reset_err_stack;
	     END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Get_Resource_List_Info ;


/* Changes for FPM, Tracking Bug - 3354518
   Adding Procedure Get_Resource_List_Info below.
   Please note that this proceedure is a overloaded procedure.
   The reason behind overloading this procedure below is the
   is the addiditon of three fields use_for_wp_flag,control_flag
   and migration_code to pa_resource_lists_all_bg */
PROCEDURE Get_Resource_List_Info
         (p_resource_list_id           IN   pa_resource_lists.RESOURCE_LIST_ID%TYPE
         ,x_res_list_is_uncategorized  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_is_resource_list_grouped   OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_group_resource_type_id     OUT  NOCOPY pa_resource_lists.GROUP_RESOURCE_TYPE_ID%TYPE --File.Sql.39 bug 4440895
         ,x_use_for_wp_flag            OUT  NOCOPY pa_resource_lists_all_bg.use_for_wp_flag%TYPE /*New Column added for FPM */ --File.Sql.39 bug 4440895
         ,x_control_flag               OUT  NOCOPY pa_resource_lists_all_bg.control_flag%TYPE /*New Column added for FPM */ --File.Sql.39 bug 4440895
         ,x_migration_code             OUT  NOCOPY pa_resource_lists_all_bg.migration_code%TYPE /*New Column added for FPM */ --File.Sql.39 bug 4440895
         ,x_return_status              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count                  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                   OUT  NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


       l_return_status      VARCHAR2(2000);
       l_msg_count          NUMBER :=0;
       l_msg_data           VARCHAR2(2000);
       l_data               VARCHAR2(2000);
       l_msg_index_out      NUMBER;
       l_debug_mode         VARCHAR2(30);

BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Get_Resource_List_Info');
END IF;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('Get_Resource_List_Info(Overloaded): ' || 'PLSQL','LOG',l_debug_mode);
     END IF;

     -- Check for not null parameters

     pa_debug.g_err_stage := 'Checking for valid parameters:';
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Get_Resource_List_Info(Overloaded): ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF (p_resource_list_id  IS NULL)

     THEN

         pa_debug.g_err_stage := 'resource list id ='||to_char(p_resource_list_id);
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Get_Resource_List_Info(Overloaded): ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;
         PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;

     SELECT nvl(uncategorized_flag,'N')
           ,decode (group_resource_type_id,0,'N','Y')
           ,group_resource_type_id
        ,use_for_wp_flag
           ,control_flag
        ,migration_code
       INTO x_res_list_is_uncategorized
           ,x_is_resource_list_grouped
           ,x_group_resource_type_id
        ,x_use_for_wp_flag
           ,x_control_flag
           ,x_migration_code
       FROM pa_resource_lists_all_bg
      WHERE resource_list_id = p_resource_list_id ;

 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.reset_err_stack;
 END IF;
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

              pa_debug.g_err_stage:='Invalid Arguments Passed';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('Get_Resource_List_Info(Overloaded): ' || l_module_name,pa_debug.g_err_stage,5);
              END IF;

              x_return_status:= FND_API.G_RET_STS_ERROR;

 IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.reset_err_stack;
 END IF;
              RAISE;

        WHEN Others THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count     := 1;
             x_msg_data      := SQLERRM;

             FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FIN_PLAN_UTILS'
                             ,p_procedure_name  => 'Get_Resource_List_Info');

             pa_debug.g_err_stage:='Unexpected Error';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('Get_Resource_List_Info: ' || l_module_name,pa_debug.g_err_stage,5);
                pa_debug.reset_err_stack;
	     END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Get_Resource_List_Info ;

/* This api should be used only for budgets created using self-service. */
PROCEDURE Get_Uncat_Resource_List_Info
         (x_resource_list_id           OUT   NOCOPY pa_resource_lists.RESOURCE_LIST_ID%TYPE --File.Sql.39 bug 4440895
         ,x_resource_list_member_id    OUT   NOCOPY pa_resource_list_members.RESOURCE_LIST_MEMBER_ID%TYPE --File.Sql.39 bug 4440895
         ,x_track_as_labor_flag        OUT   NOCOPY pa_resource_list_members.TRACK_AS_LABOR_FLAG%TYPE --File.Sql.39 bug 4440895
         ,x_unit_of_measure            OUT   NOCOPY pa_resources.UNIT_OF_MEASURE%TYPE --File.Sql.39 bug 4440895
         ,x_return_status              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count                  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                   OUT  NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

    l_debug_mode         VARCHAR2(30);
    l_business_group_id  pa_resource_lists_all_bg.business_group_id%TYPE; -- bug 2760675

BEGIN

 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Get_Uncat_Resource_List_Info');
  END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    END IF;

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.g_err_stage:='Executing the uncat res list info select...';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
    END IF;

    l_business_group_id := pa_utils.business_group_id; -- bug 2760675

    -- performance bug fix 2788668

 /* 4/22 TEMPORARY FIX: added where clause to prevent multiple rows
  * from being returned:  prlm.object_type='RESOURCE_LIST'
  * The final fix is pending discussion w/architects.  This fix was made
  * so Q/A can continue
  */

 /* Bug 4052562 - Pa_resources is obsolete for FP M. Also, there would
 *  be 4 default rlms for every resource list. As such, in FP M, the
 *  uncat rlm would have unit of measure as DOLLARS and this is available
 *  in rlm table itself. Track_as_labor_flag is obsolete for FP M.
 *  This change would also improve the performance and RLM's N5 index would be
 *  used.
 */
--  select /*+ Use_NL(prlm,pr) index(prlm, PA_RESOURCE_LIST_MEMBERS_N1) */
  select pbg.resource_list_id,
         prlm.track_as_labor_flag,
         prlm.resource_list_member_id,
         prlm.unit_of_measure
    into x_resource_list_id,
        x_track_as_labor_flag,
        x_resource_list_member_id,
        x_unit_of_measure
    from pa_resource_lists_all_bg pbg,
        pa_resource_list_members prlm
    where pbg.business_group_id = l_business_group_id and -- bug 2760675  pa_utils.business_group_id and
          pbg.uncategorized_flag = 'Y' and
          prlm.resource_list_id = pbg.resource_list_id and
          prlm.object_id = pbg.resource_list_id and
          prlm.object_type = 'RESOURCE_LIST' and
          prlm.resource_class_code = 'FINANCIAL_ELEMENTS' and
          prlm.resource_class_flag = 'Y';
/*
        SELECT pbg.resource_list_id
              ,prlm.track_as_labor_flag
              ,prlm.resource_list_member_id
              ,pr.unit_of_measure
         INTO x_resource_list_id
              ,x_track_as_labor_flag
              ,x_resource_list_member_id
              ,x_unit_of_measure
         FROM pa_resource_lists_all_bg pbg
             ,pa_resource_list_members prlm
             ,pa_resources pr
        WHERE prlm.resource_list_id = pbg.resource_list_id
          AND pbg.resource_list_id = prlm.resource_list_id
          AND prlm.resource_id = pr.resource_id
          AND pbg.uncategorized_flag = 'Y'
          AND pbg.business_group_id =  pa_utils.business_group_id;
*/
 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.reset_err_stack;
 END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:='Uncat Res List could not be found!!!';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => 'PA_BU_NO_UNCAT_RESOURCE_LIST' );
 IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.reset_err_stack;
 END IF;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

END Get_Uncat_Resource_List_Info;

/*=============================================================================
 This api is a wrapper over the api Get_Appr_Cost_Plan_Type_Info in order to
 consider the effects of upgrade. As the user might go for the partial upgrade
 of budget types in a project, it is necessary to check for AC plan type in the
 old model.
 Return value :
   If an Approved cost plan type is attached to a project then the API returns
   a non-negative, non-zero value. else returns NULL.
==============================================================================*/


PROCEDURE Is_AC_PT_Attached_After_UPG(
          p_project_id     IN   pa_projects_all.project_id%TYPE
          ,x_plan_type_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count     OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data      OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

    --Start of variables used for debugging

    l_msg_count          NUMBER :=0;
    l_data               VARCHAR2(2000);
    l_msg_data           VARCHAR2(2000);
    l_error_msg_code     VARCHAR2(30);
    l_msg_index_out      NUMBER;
    l_return_status      VARCHAR2(2000);
    l_debug_mode         VARCHAR2(30);

    --End of variables used for debugging

    l_fin_plan_type_id   pa_proj_fp_options.fin_plan_type_id%TYPE;
    l_budget_type_code   pa_budget_types.budget_type_code%Type;
    l_ac_budget_type_code pa_budget_types.budget_type_code%TYPE := 'AC'; --Bug 3764635.

BEGIN

 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Is_AC_PT_Attached_After_UPG');
 END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Is_AC_PT_Attached_After_UPG: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for business rules violations

    pa_debug.g_err_stage:='Validating input parameters';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Is_AC_PT_Attached_After_UPG: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    -- project_id can't be null

    IF (p_project_id IS NULL)   THEN

        pa_debug.g_err_stage:='Project_id = '||p_project_id;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Is_AC_PT_Attached_After_UPG: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE Invalid_Arg_Exc;

    END IF;

    pa_debug.g_err_stage:='Parameter validation complete ';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Is_AC_PT_Attached_After_UPG: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Fetch approved plan type id

    BEGIN

        pa_debug.g_err_stage:='Fetching approved cost plan type id from the new model';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Is_AC_PT_Attached_After_UPG: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        Get_Appr_Cost_Plan_Type_Info(
                   p_project_id    => p_project_id
                  ,x_plan_type_id  => l_fin_plan_type_id
                  ,x_return_status => x_return_status
                  ,x_msg_count     => x_msg_count
                  ,x_msg_data      => x_msg_data);



        IF l_fin_plan_type_id is NULL THEN -- AC plan type doesnot exist in the new model.
                                      -- So check in the old model.
            BEGIN

                select bud.budget_type_code
                into l_budget_type_code
                from pa_budget_types bud
                where bud.budget_type_code = l_ac_budget_type_code --Bug 3764635.
                and exists
                (
                  select budget_version_id
                  from pa_budget_versions
                  where project_id = p_project_id         -- project id.
                  and budget_type_code = bud.budget_type_code
                );

                l_fin_plan_type_id := 1;

             EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        l_fin_plan_type_id := NULL;
             END;

        END IF;

    END;

    --return the plan type id

    x_plan_type_id := l_fin_plan_type_id ;

    pa_debug.g_err_stage:='Exiting Is_AC_PT_Attached_After_UPG';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Is_AC_PT_Attached_After_UPG: ' || l_module_name,pa_debug.g_err_stage,3);
       pa_debug.reset_err_stack;
    END IF;
EXCEPTION

     WHEN Invalid_Arg_Exc THEN

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

           pa_debug.g_err_stage:='Invalid Arguments Passed';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('Is_AC_PT_Attached_After_UPG: ' || l_module_name,pa_debug.g_err_stage,5);
               pa_debug.reset_err_stack;
	   END IF;
           RAISE;

     WHEN Others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FIN_PLAN_UTILS'
                                  ,p_procedure_name  => 'Is_AC_PT_Attached_After_UPG');

          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Is_AC_PT_Attached_After_UPG: ' || l_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_err_stack;
	  END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Is_AC_PT_Attached_After_UPG;


/*=============================================================================
This api is a wrapper over the api Get_Appr_Rev_Plan_Type_Info in order to
 consider the effects of upgrade. As the user might go for the partial upgrade
 of budget types in a project, it is necessary to check for AR plan type in the
 old model.
 Return value :
   If an Approved revenue plan type is attached to a project then the API returns
   a non-negative, non-zero value. else returns NULL.
==============================================================================*/

PROCEDURE Is_AR_PT_Attached_After_UPG(
          p_project_id     IN   pa_projects_all.project_id%TYPE
          ,x_plan_type_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count     OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data      OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS
    --Start of variables used for debugging

    l_msg_count          NUMBER :=0;
    l_data               VARCHAR2(2000);
    l_msg_data           VARCHAR2(2000);
    l_error_msg_code     VARCHAR2(30);
    l_msg_index_out      NUMBER;
    l_return_status      VARCHAR2(2000);
    l_debug_mode         VARCHAR2(30);

    --End of variables used for debugging

    l_fin_plan_type_id   pa_proj_fp_options.fin_plan_type_id%TYPE;
    l_budget_type_code   pa_budget_types.budget_type_code%TYPE;
    l_ar_budget_type_code pa_budget_types.budget_type_code%TYPE := 'AR'; --Bug 3764635.

BEGIN

 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Is_AR_PT_Attached_After_UPG');
 END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Is_AR_PT_Attached_After_UPG: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for business rules violations

    pa_debug.g_err_stage:='Validating input parameters';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Is_AR_PT_Attached_After_UPG: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    -- project_id can't be null

    IF (p_project_id IS NULL)   THEN

        pa_debug.g_err_stage:='Project_id = '||p_project_id;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Is_AR_PT_Attached_After_UPG: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE Invalid_Arg_Exc;

    END IF;

    pa_debug.g_err_stage:='Parameter validation complete ';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Is_AR_PT_Attached_After_UPG: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Fetch approved plan type id

    BEGIN

        pa_debug.g_err_stage:='Fetching approved revenue plan type id from the new model';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Is_AR_PT_Attached_After_UPG: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        Get_Appr_Rev_Plan_Type_Info(
                   p_project_id    => p_project_id
                  ,x_plan_type_id  => l_fin_plan_type_id
                  ,x_return_status => x_return_status
                  ,x_msg_count     => x_msg_count
                  ,x_msg_data      => x_msg_data);



        IF l_fin_plan_type_id is NULL THEN -- AR plan type doesnot exist in the new model.
                                      -- So check in the old model.
            BEGIN

                select bud.budget_type_code
                into l_budget_type_code
                from pa_budget_types bud
                where bud.budget_type_code = l_ar_budget_type_code --Bug 3764635.
                and exists
                (
                  select budget_version_id
                  from pa_budget_versions
                  where project_id = p_project_id         -- project id.
                  and budget_type_code = bud.budget_type_code
                );

                l_fin_plan_type_id := 1;

             EXCEPTION

                WHEN NO_DATA_FOUND THEN
                        l_fin_plan_type_id := NULL;
             END;

        END IF;

    END;

    --return the plan type id

    x_plan_type_id := l_fin_plan_type_id ;

    pa_debug.g_err_stage:='Exiting Is_AR_PT_Attached_After_UPG';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Is_AR_PT_Attached_After_UPG: ' || l_module_name,pa_debug.g_err_stage,3);
    pa_debug.reset_err_stack;
	END IF;
EXCEPTION

     WHEN Invalid_Arg_Exc THEN

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

           pa_debug.g_err_stage:='Invalid Arguments Passed';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('Is_AR_PT_Attached_After_UPG: ' || l_module_name,pa_debug.g_err_stage,5);

           pa_debug.reset_err_stack;
	END IF;
           RAISE;

     WHEN Others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FIN_PLAN_UTILS'
                                  ,p_procedure_name  => 'Is_AR_PT_Attached_After_UPG');

          pa_debug.g_err_stage:='Unexpeted Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Is_AR_PT_Attached_After_UPG: ' || l_module_name,pa_debug.g_err_stage,5);

          pa_debug.reset_err_stack;
	END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Is_AR_PT_Attached_After_UPG;

/*=============================================================================
 Function Get_budget_version_number
 The function returns the max version number available for the given project_id,
 fin_plan_type_id and version_type combination

 06-Jul-2004 Raja  bug 3677924
                   p_lock_required_flag input value is not being used. Modified
                   the code such that lock is acquired only if this parameter
                   is passed as 'Y'.
==============================================================================*/

PROCEDURE Get_Max_Budget_Version_Number
        (p_project_id         IN      pa_budget_versions.project_id%TYPE
        ,p_fin_plan_type_id   IN      pa_budget_versions.fin_plan_type_id%TYPE
        ,p_version_type       IN      pa_budget_versions.version_type%TYPE
        ,p_copy_mode          IN      VARCHAR2
        ,p_ci_id              IN      NUMBER
        ,p_lock_required_flag IN      VARCHAR2
        ,x_version_number     OUT     NOCOPY pa_budget_versions.version_number%TYPE --File.Sql.39 bug 4440895
        ,x_return_status      OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count          OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_msg_data           OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_msg_count          NUMBER :=0;
l_data               VARCHAR2(2000);
l_msg_data           VARCHAR2(2000);
l_error_msg_code     VARCHAR2(30);
l_msg_index_out      NUMBER;
l_return_status      VARCHAR2(2000);
l_debug_mode         VARCHAR2(30);

l_version_number        pa_budget_versions.version_number%TYPE;

BEGIN

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
  IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_curr_function( p_function =>'Get_Max_Budget_Version_Number',
                                   p_debug_mode => l_debug_mode);
  END IF;
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for NOT NULL parameters

    IF (p_project_id       IS NULL) OR
       (p_fin_plan_type_id IS NULL) OR
       (p_version_type     IS NULL) OR
       (p_copy_mode        IS NULL)
    THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Project_id = '||p_project_id;
            pa_debug.write('Get_Max_Budget_Version_Number: ' || l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:='p_fin_plan_type_id = '||p_fin_plan_type_id;
            pa_debug.write('Get_Max_Budget_Version_Number: ' || l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:='p_version_type = '||p_version_type;
            pa_debug.write('Get_Max_Budget_Version_Number: ' || l_module_name,pa_debug.g_err_stage,5);

            pa_debug.g_err_stage:='p_copy_mode = '||p_copy_mode;
            pa_debug.write('Get_Max_Budget_Version_Number: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE Invalid_Arg_Exc;

    END IF;

    IF  p_copy_mode = PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING THEN
        IF p_ci_id IS NULL THEN
            BEGIN
                SELECT NVL(max(version_number),0)
                INTO   l_version_number
                FROM   pa_budget_versions
                WHERE  project_id = p_project_id
                AND    fin_plan_type_id = p_fin_plan_type_id
                AND    version_type = p_version_type
                AND    budget_status_code IN (PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING,
                                         PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_SUBMITTED)
                AND    ci_id IS NULL;
            EXCEPTION
                WHEN OTHERS THEN

                           IF P_PA_DEBUG_MODE = 'Y' THEN
                               pa_debug.g_err_stage:='Error while fetching max version number';
                               pa_debug.write('Get_Max_Budget_Version_Number: ' || l_module_name,pa_debug.g_err_stage,3);

                	   pa_debug.reset_curr_function;
		END IF;
                            RAISE;
            END;

            IF l_version_number <> 0 AND nvl(p_lock_required_flag, 'N') = 'Y' THEN  --bug 3677924
            BEGIN
                SELECT version_number
                INTO   l_version_number
                FROM   pa_budget_versions
                WHERE  project_id = p_project_id
                AND    fin_plan_type_id = p_fin_plan_type_id
                AND    version_type = p_version_type
                AND    budget_status_code IN (PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING,
                             PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_SUBMITTED)
                AND    ci_id is null
                AND    version_number = l_version_number
                FOR    UPDATE;
            EXCEPTION
                WHEN OTHERS THEN

                           IF P_PA_DEBUG_MODE = 'Y' THEN
                               pa_debug.g_err_stage:='Error while fetching version number';
                               pa_debug.write('Get_Max_Budget_Version_Number: ' || l_module_name,pa_debug.g_err_stage,3);

                	   pa_debug.reset_curr_function;
			END IF;
                            RAISE;
            END;
            END IF;
        ELSE
            SELECT NVL(max(version_number),0)
            INTO   l_version_number
            FROM   pa_budget_versions
            WHERE  project_id = p_project_id
            AND    fin_plan_type_id = p_fin_plan_type_id
            AND    version_type = p_version_type
            AND    budget_status_code IN (PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING,
                                         PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_SUBMITTED)
            AND    ci_id = p_ci_id;

            IF l_version_number <> 0 AND nvl(p_lock_required_flag, 'N') = 'Y' THEN   -- bug 3677924
                SELECT version_number
                INTO   l_version_number
                FROM   pa_budget_versions
                WHERE  project_id = p_project_id
                AND    fin_plan_type_id = p_fin_plan_type_id
                AND    version_type = p_version_type
                AND    budget_status_code IN (PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING,
                             PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_SUBMITTED)
                AND    ci_id = p_ci_id
                AND    version_number = l_version_number
                FOR    UPDATE;
            END IF;
        END IF;
    ELSIF  p_copy_mode = PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_BASELINED THEN

           SELECT NVL(max(version_number),0)
           INTO   l_version_number
           FROM   pa_budget_versions
           WHERE  project_id = p_project_id
           AND    fin_plan_type_id = p_fin_plan_type_id
           AND    version_type = p_version_type
           AND    budget_status_code IN (PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_BASELINED);

    END IF;

    x_version_number:= l_version_number;
 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.reset_curr_function;
END IF;
EXCEPTION
     WHEN Invalid_Arg_Exc THEN

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
          pa_debug.g_err_stage:='Invalid Arguments Passed';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Get_Max_Budget_Version_Number: ' || l_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
	END IF;
          RETURN;

     WHEN Others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                                  ,p_procedure_name  => 'Get_Budget_Version_Number');
          pa_debug.g_err_stage:='Unexpeted Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Get_Max_Budget_Version_Number: ' || l_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
	END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Max_Budget_Version_Number;

FUNCTION get_period_start_date (p_input_date IN pa_periods_all.start_date%TYPE,
                                p_time_phased_code IN pa_proj_fp_options.cost_time_phased_Code%TYPE) RETURN DATE
IS
l_start_date pa_periods_all.start_date%TYPE;
BEGIN
	IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Inside get_period_start_date and input date is '||p_input_date||' time phasing is : '||p_time_phased_code;
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
	END IF;
        IF p_time_phased_code = PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P THEN
            IF p_input_date IS NOT NULL THEN
                SELECT start_date
                INTO   l_start_date
                FROM   pa_periods
                WHERE  p_input_date between start_date and end_date;
            END IF;
        ELSIF p_time_phased_code = PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G THEN
            IF p_input_date IS NOT NULL THEN
                SELECT  g.start_date
                INTO    l_start_date
                FROM    PA_IMPLEMENTATIONS  i,
                        GL_PERIOD_STATUSES g
                WHERE   g.set_of_books_id = i.set_of_books_id
                  AND   g.application_id = pa_period_process_pkg.application_id
                  AND   g.adjustment_period_flag = 'N'
                  AND   p_input_date between  g.start_date and g.end_date;
            END IF;
        END IF;
return l_start_date;
/* Bug 2644537 */
EXCEPTION
        WHEN NO_DATA_FOUND THEN
                return NULL;
END;

FUNCTION get_period_end_date (p_input_date IN pa_periods_all.end_date%TYPE,
                              p_time_phased_code IN pa_proj_fp_options.cost_time_phased_Code%TYPE) RETURN DATE
IS
l_end_date pa_periods_all.end_date%TYPE;
BEGIN
IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Inside get_period_end_date and input date is '||p_input_date||' time phasing is : '||p_time_phased_code;
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
END IF;
        IF p_time_phased_code = PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P THEN
            IF p_input_date IS NOT NULL THEN
                SELECT end_date
                INTO   l_end_date
                FROM   pa_periods
                WHERE  p_input_date between start_date and end_date;
            END IF;

        ELSIF p_time_phased_code = PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G THEN
            IF p_input_date IS NOT NULL THEN
                SELECT  g.end_date
                INTO    l_end_date
                FROM    PA_IMPLEMENTATIONS  i,
                        GL_PERIOD_STATUSES g
                WHERE   g.set_of_books_id = i.set_of_books_id
                  AND   g.application_id = pa_period_process_pkg.application_id
                  AND   g.adjustment_period_flag = 'N'
                  AND   p_input_date between  g.start_date and g.end_date;
            END IF;
        END IF;
return l_end_date;
/* Bug 2644537 */
EXCEPTION
        WHEN NO_DATA_FOUND THEN
                return NULL;
END;

/*==============================================================================
   This api returns the Current Baselined Version for a given project and
   budget_type_code or fin_plan_type combination.

   1)If the plan type is COST_AND_REV_SAME, then it returns 'ALL' version
   2)If it is COST_ONLY or COST_AND_REV_SEP then it returns 'COST'  version
 ===============================================================================*/

PROCEDURE GET_COST_BASE_VERSION_INFO
   (  p_project_id              IN      pa_budget_versions.project_id%TYPE
     ,p_fin_plan_Type_id        IN      pa_budget_versions.fin_plan_type_id%TYPE
     ,p_budget_type_code        IN      pa_budget_versions.budget_type_code%TYPE
     ,x_budget_version_id       OUT     NOCOPY pa_budget_versions.budget_version_id%TYPE --File.Sql.39 bug 4440895
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_error_msg_code                VARCHAR2(30);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_debug_mode                    VARCHAR2(30);
l_err_code                      NUMBER;
l_err_stage                     VARCHAR2(2000);
l_err_stack                     VARCHAR2(2000);

l_fin_plan_preference_code      pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_fp_options_id                 pa_proj_fp_options.proj_fp_options_id%TYPE;

l_version_type                  pa_budget_versions.version_type%TYPE;

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.GET_COST_BASE_VERSION_INFO');
 END IF;
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.set_process('GET_COST_BASE_VERSION_INFO: ' || 'PLSQL','LOG',l_debug_mode);
      END IF;

      -- Check for business rules violations

      pa_debug.g_err_stage:= 'Validating input parameters';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('GET_COST_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      --Check if plan version id is null

      IF (p_project_id IS NULL) OR
         ((p_budget_type_code IS NULL ) AND (p_fin_plan_type_id IS NULL)) OR
         ((p_budget_type_code IS NOT NULL ) AND (p_fin_plan_type_id IS NOT NULL))
      THEN

                   pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('GET_COST_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                   END IF;
                   pa_debug.g_err_stage:= 'p_budget_type_code = '|| p_budget_type_code;
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('GET_COST_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                   END IF;
                   pa_debug.g_err_stage:= 'p_fin_plan_type_id = '|| p_fin_plan_type_id;
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('GET_COST_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                   END IF;

                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                          p_msg_name     => 'PA_FP_INV_PARAM_PASSED');

                   RAISE PA_FP_ELEMENTS_PUB.Invalid_Arg_Exc;

      END IF;

      --If plan type id is passed then give the COST version OR ALL version based upon the fin_plan_type_id

      IF p_fin_plan_type_id IS NOT NULL
      THEN

                    -- Fetch fin_plan_preference code of the plan type to determine the version that has to be fetched.

                    BEGIN
                            SELECT fin_plan_preference_code
                            INTO   l_fin_plan_preference_code
                            FROM   pa_proj_fp_options
                            WHERE  project_id = p_project_id
                            AND    fin_plan_type_id = p_fin_plan_type_id
                            AND    fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;
                    EXCEPTION
                            WHEN others THEN
                                  pa_debug.g_err_stage:= 'While fetching Preference Code'||SQLERRM;
                                  IF P_PA_DEBUG_MODE = 'Y' THEN
                                     pa_debug.write('GET_COST_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                                  END IF;
                                  RAISE ;
                    END;

                    -- Based on  fin_plan_preference code, fetch all version for cost_and_rev_same plan type and
                    -- for other plan types fetch cost version..

                    IF  l_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME
                    THEN
                                  l_version_type := PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL;
                    ELSE
                                  l_version_type := PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST;
                    END IF;

                    PA_FIN_PLAN_UTILS.Get_Baselined_Version_Info(
                                   p_project_id             =>    p_project_id
                                  ,p_fin_plan_type_id       =>    p_fin_plan_type_id
                                  ,p_version_type           =>    l_version_type
                                  ,x_fp_options_id          =>    l_fp_options_id
                                  ,x_fin_plan_version_id    =>    x_budget_version_id
                                  ,x_return_status          =>    x_return_status
                                  ,x_msg_count              =>    x_msg_count
                                  ,x_msg_data               =>    x_msg_data );

                   IF    x_budget_version_id IS NULL
                   THEN
                          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                          x_msg_count     := 1;
                          x_msg_data      := 'PA_BU_CORE_NO_VERSION_ID';
                   END IF;

      ELSE
                   --If Budget type code is passed then give the appopriate  baselined version

                   pa_budget_utils.get_baselined_version_id (
                                 x_project_id            =>   p_project_id
                                ,x_budget_type_code      =>   p_budget_type_code
                                ,x_budget_version_id     =>   x_budget_version_id
                                ,x_err_code              =>   l_err_code
                                ,x_err_stage             =>   l_err_stage
                                ,x_err_stack             =>   l_err_stack );

                   --Initialise the out parameters

                   IF    l_err_code <> 0
                   THEN
                          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                          x_msg_count     := 1;
                          x_msg_data      := l_err_stage;
                   END IF;
       END IF;

      pa_debug.g_err_stage:= 'Exiting GET_COST_BASE_VERSION_INFO';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('GET_COST_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

      pa_debug.reset_err_stack;
	END IF;
  EXCEPTION

     WHEN PA_FP_ELEMENTS_PUB.Invalid_Arg_Exc THEN

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

           pa_debug.g_err_stage:= 'Invalid Arguments Passed';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('GET_COST_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
           END IF;

           x_return_status := FND_API.G_RET_STS_ERROR;
 IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.reset_err_stack;
 END IF;
   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                                  ,p_procedure_name  => 'GET_COST_BASE_VERSION_INFO');
          pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('GET_COST_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          pa_debug.reset_err_stack;
	END IF;
END GET_COST_BASE_VERSION_INFO;

/*==============================================================================
   This api returns the Current Baselined Version for a given project and
   budget_type_code or fin_plan_type combination.

   1)If the plan type is COST_AND_REV_SAME, then it returns 'ALL' version
   2)If it is REVENUE_ONLY or COST_AND_REV_SEP then it returns 'REVENUE'  version
 ===============================================================================*/

PROCEDURE GET_REV_BASE_VERSION_INFO
   (  p_project_id              IN      pa_budget_versions.project_id%TYPE
     ,p_fin_plan_Type_id        IN      pa_budget_versions.fin_plan_type_id%TYPE
     ,p_budget_type_code        IN      pa_budget_versions.budget_type_code%TYPE
     ,x_budget_version_id       OUT     NOCOPY pa_budget_versions.budget_version_id%TYPE --File.Sql.39 bug 4440895
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_error_msg_code                VARCHAR2(30);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_debug_mode                    VARCHAR2(30);
l_err_code                      NUMBER;
l_err_stage                     VARCHAR2(2000);
l_err_stack                     VARCHAR2(2000);

l_fin_plan_preference_code      pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_fp_options_id                 pa_proj_fp_options.proj_fp_options_id%TYPE;

l_version_type                  pa_budget_versions.version_type%TYPE;

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.GET_REV_BASE_VERSION_INFO');
 END IF;
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.set_process('GET_REV_BASE_VERSION_INFO: ' || 'PLSQL','LOG',l_debug_mode);
      END IF;

      -- Check for business rules violations

      pa_debug.g_err_stage:= 'Validating input parameters';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('GET_REV_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      --Check if plan version id is null

      IF (p_project_id IS NULL) OR
         ((p_budget_type_code IS NULL ) AND (p_fin_plan_type_id IS NULL)) OR
         ((p_budget_type_code IS NOT NULL ) AND (p_fin_plan_type_id IS NOT NULL))
      THEN

                   pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('GET_REV_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                   END IF;
                   pa_debug.g_err_stage:= 'p_budget_type_code = '|| p_budget_type_code;
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('GET_REV_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                   END IF;
                   pa_debug.g_err_stage:= 'p_fin_plan_type_id = '|| p_fin_plan_type_id;
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('GET_REV_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                   END IF;

                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                          p_msg_name     => 'PA_FP_INV_PARAM_PASSED');

                   RAISE PA_FP_ELEMENTS_PUB.Invalid_Arg_Exc;

      END IF;

      --If plan type id is passed then give the COST version OR ALL version based upon the fin_plan_type_id

      IF p_fin_plan_type_id IS NOT NULL
      THEN

                    -- Fetch fin_plan_preference code of the plan type to determine the version that has to be fetched.

                    BEGIN
                            SELECT fin_plan_preference_code
                            INTO   l_fin_plan_preference_code
                            FROM   pa_proj_fp_options
                            WHERE  project_id = p_project_id
                            AND    fin_plan_type_id = p_fin_plan_type_id
                            AND    fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;
                    EXCEPTION
                            WHEN others THEN

                                  pa_debug.g_err_stage:= 'While fetching Preference Code'||SQLERRM;
                                  IF P_PA_DEBUG_MODE = 'Y' THEN
                                     pa_debug.write('GET_REV_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                                  END IF;
                                  RAISE;
                    END;

                    -- Based on  fin_plan_preference code, fetch all version for cost_and_rev_same plan type and
                    -- for other plan types fetch cost version..

                    IF  l_fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME
                    THEN
                                  l_version_type := PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL;
                    ELSE
                                  l_version_type := PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_REVENUE;
                    END IF;

                    PA_FIN_PLAN_UTILS.Get_Baselined_Version_Info(
                                   p_project_id             =>    p_project_id
                                  ,p_fin_plan_type_id       =>    p_fin_plan_type_id
                                  ,p_version_type           =>    l_version_type
                                  ,x_fp_options_id          =>    l_fp_options_id
                                  ,x_fin_plan_version_id    =>    x_budget_version_id
                                  ,x_return_status          =>    x_return_status
                                  ,x_msg_count              =>    x_msg_count
                                  ,x_msg_data               =>    x_msg_data );

                    IF    x_budget_version_id IS NULL
                    THEN
                           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                           x_msg_count     := 1;
                           x_msg_data      := 'PA_BU_CORE_NO_VERSION_ID';
                    END IF;


      ELSE
                   --If Budget type code is passed then give the appopriate  baselined version

                   pa_budget_utils.get_baselined_version_id (
                                 x_project_id            =>   p_project_id
                                ,x_budget_type_code      =>   p_budget_type_code
                                ,x_budget_version_id     =>   x_budget_version_id
                                ,x_err_code              =>   l_err_code
                                ,x_err_stage             =>   l_err_stage
                                ,x_err_stack             =>   l_err_stack );

                   --Initialise the out parameters

                   IF    l_err_code <> 0
                   THEN
                          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                          x_msg_count     := 1;
                          x_msg_data      := l_err_stage;
                   END IF;
      END IF;


      pa_debug.g_err_stage:= 'Exiting GET_REV_BASE_VERSION_INFO';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('GET_REV_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         pa_debug.reset_err_stack;
	END IF;
  EXCEPTION

     WHEN PA_FP_ELEMENTS_PUB.Invalid_Arg_Exc THEN

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

           pa_debug.g_err_stage:= 'Invalid Arguments Passed';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('GET_REV_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
           END IF;

           x_return_status := FND_API.G_RET_STS_ERROR;
 IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.reset_err_stack;
 END IF;
   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                                  ,p_procedure_name  => 'GET_REV_BASE_VERSION_INFO');
          pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('GET_REV_BASE_VERSION_INFO: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          pa_debug.reset_err_stack;
	END IF;
END GET_REV_BASE_VERSION_INFO;

/*==============================================================================
 Following two function just calls the usual pa_debug.acquire/release_user_lock
 but in AUTONOMOUS mode .This two functions are added as part of fix for #2622476.
 ==============================================================================*/

FUNCTION ACQUIRE_USER_LOCK
   ( X_LOCK_NAME     IN      VARCHAR2 )
RETURN NUMBER
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

   RETURN pa_debug.Acquire_User_Lock(X_LOCK_NAME) ;

END ACQUIRE_USER_LOCK ;

FUNCTION RELEASE_USER_LOCK
   ( X_LOCK_NAME     IN      VARCHAR2 )
RETURN NUMBER
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  RETURN pa_debug.Release_User_Lock(X_LOCK_NAME) ;

END RELEASE_USER_LOCK ;

/*==================================================================
   This api converts the estimated amounts of a control item version
   entered in project currency to project functional currency.
 ==================================================================*/

PROCEDURE get_converted_amounts
   (  p_budget_version_id       IN   pa_budget_versions.budget_version_id%TYPE
     ,p_txn_raw_cost            IN   pa_budget_versions.est_project_raw_cost%TYPE
     ,p_txn_burdened_cost       IN   pa_budget_versions.est_project_burdened_cost%TYPE
     ,p_txn_revenue             IN   pa_budget_versions.est_project_revenue%TYPE
     ,p_txn_currency_Code       IN   pa_projects_all.project_currency_code%TYPE
     ,p_project_currency_code   IN   pa_projects_all.project_currency_code%TYPE
     ,p_projfunc_currency_code  IN   pa_projects_all.projfunc_currency_code%TYPE
     ,x_project_raw_cost        OUT  NOCOPY pa_budget_versions.est_projfunc_raw_cost%TYPE --File.Sql.39 bug 4440895
     ,x_project_burdened_cost   OUT  NOCOPY pa_budget_versions.est_projfunc_burdened_cost%TYPE --File.Sql.39 bug 4440895
     ,x_project_revenue         OUT  NOCOPY pa_budget_versions.est_projfunc_revenue%TYPE --File.Sql.39 bug 4440895
     ,x_projfunc_raw_cost       OUT  NOCOPY pa_budget_versions.est_projfunc_raw_cost%TYPE --File.Sql.39 bug 4440895
     ,x_projfunc_burdened_cost  OUT  NOCOPY pa_budget_versions.est_projfunc_burdened_cost%TYPE --File.Sql.39 bug 4440895
     ,x_projfunc_revenue        OUT  NOCOPY pa_budget_versions.est_projfunc_revenue%TYPE --File.Sql.39 bug 4440895
     ,x_return_status           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_error_msg_code                VARCHAR2(30);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_debug_mode                    VARCHAR2(30);

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_err_stack('PA_FIN_PLAN_UITLS.get_converted_amounts');
 END IF;
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.set_process('get_converted_amounts: ' || 'PLSQL','LOG',l_debug_mode);
      END IF;

      -- Check for business rules violations

      pa_debug.g_err_stage:= 'Validating input parameters';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('get_converted_amounts: ' || l_module_name,pa_debug.g_err_stage,
                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      --Check if plan version id is null

      IF   (p_budget_version_id      IS NULL) OR
           (p_txn_currency_Code      IS NULL) OR
           (p_project_currency_Code  IS NULL) OR
           (p_projfunc_currency_code IS NULL)
      THEN

              pa_debug.g_err_stage:= 'p_budget_version_id = '|| p_budget_version_id;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('get_converted_amounts: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              END IF;
              pa_debug.g_err_stage:= 'p_txn_currency_Code = '|| p_txn_currency_Code;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('get_converted_amounts: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              END IF;
              pa_debug.g_err_stage:= 'p_project_currency_Code = '|| p_project_currency_Code;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('get_converted_amounts: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              END IF;
              pa_debug.g_err_stage:= 'p_projfunc_currency_code = '|| p_projfunc_currency_code;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('get_converted_amounts: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              END IF;

              PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_INV_PARAM_PASSED');

              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      DELETE FROM pa_fp_rollup_tmp;
      INSERT INTO pa_fp_rollup_tmp(
             resource_assignment_id,
             start_date,
             end_date,
             txn_currency_code,
             project_currency_code,
             projfunc_currency_code,
             txn_raw_cost,
             txn_burdened_cost,
             txn_revenue             )
      VALUES(
              -1,
              sysdate,
              sysdate,
              p_project_currency_Code,
              p_project_currency_Code,
              p_projfunc_currency_Code,
              p_txn_raw_cost,
              p_txn_burdened_cost,
              p_txn_revenue      );

      PA_FP_MULTI_CURRENCY_PKG.convert_txn_currency
        ( p_budget_version_id       =>      p_budget_version_id
         ,p_entire_version          =>      'N'
         ,x_return_status           =>      x_return_status
         ,x_msg_count               =>      x_msg_count
         ,x_msg_data                =>      x_msg_data );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RETURN;
      END IF;

      SELECT PROJFUNC_RAW_COST,
             PROJFUNC_BURDENED_COST,
             PROJFUNC_REVENUE,
             PROJECT_RAW_COST,
             PROJECT_BURDENED_COST,
             PROJECT_REVENUE
      INTO
         x_projfunc_raw_cost,
         x_projfunc_burdened_cost,
         x_projfunc_revenue,
         x_project_raw_cost,
         x_project_burdened_cost,
         x_project_revenue
      FROM Pa_Fp_Rollup_Tmp
      WHERE RESOURCE_ASSIGNMENT_ID = -1;

      pa_debug.g_err_stage:= 'Exiting get_converted_amounts';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('get_converted_amounts: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         pa_debug.reset_err_stack;
      END IF;
  EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           x_return_status := FND_API.G_RET_STS_ERROR;
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

           pa_debug.g_err_stage:= 'Invalid Arguments Passed';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('get_converted_amounts: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
           pa_debug.reset_err_stack;
	END IF;
           RAISE;

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                           ,p_procedure_name  => 'conv_est_amounts_of_ci_version'
                           ,p_error_text      => sqlerrm);
          pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('get_converted_amounts: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          pa_debug.reset_err_stack;
	END IF;
          RAISE;

END get_converted_amounts;

------------------------------------------------------------------------------

--  =================================================

--Name:                 check_proj_fin_plan_exists
--Type:                 Function
--
--Description:  This function is called primarily from Billing and Projects Maintenance packages
--
--                  If both the p_plan_type_id and the p_version_type IN-parameters are passed with
--                  NON-null values, then the FP logic must check for the plan_type and appropriate
--                  Approved budget flags based on x_plan_type_code.
--
--              Valid Values for x_plan_type_code are:
--              AC -- Approved Cost Budget   AR -- Approved Revenue Budget
--
--              For x_budget_status_code = B(aseline)
--              1.  As per design doc, if 'AC' or 'AR' plan types passed as x_plan_type_code
--                  AND X_FIN_PLAN_TYPE_ID IS NOT NULL,
--                    THEN
--                       Use the approved_cost/rev_plan_type_flags to determine if ANY AC/AR baselined
--                       budgets have been created for FP model.
--                       IF not then if version_type is passed as 'ALL' return success as both Cost and
--                          revenue versions will be baselined together and as it may be the first time
--                          such a case is being created, there would be no baseline versions existing.

  function check_proj_fin_plan_exists (x_project_id             IN number,
                                       x_budget_version_id      IN number,
                                       x_budget_status_code     IN varchar2,
                                       x_plan_type_code         IN varchar2,
                                       x_fin_plan_type_id       IN NUMBER,
                                       x_version_type           IN VARCHAR2
                                    )
  return number

  is

     dummy number := 0;

BEGIN



     -- Check for Valid Budget_Status_Code ---------------------------

     IF nvl(x_budget_status_code,'X') <> 'B'
        THEN
          dummy := 0;
          RETURN dummy;
     END IF;

 -- FP Model --------------


         IF (  NVL(x_plan_type_code,'X') IN ('AC','AR')  ) THEN
               IF (x_plan_type_code = 'AC') THEN

                     BEGIN
                        select 1
                        into   dummy
                        from   dual
                        where  exists
                        (select 1
                         from   pa_budget_versions bv
                         where  bv.project_id = x_project_id
                         --and    bv.fin_plan_type_id = x_fin_plan_type_id
                         and    bv.approved_cost_plan_type_flag = 'Y'
                         and    bV.current_flag = 'Y');

                      EXCEPTION WHEN NO_DATA_FOUND THEN
                        IF x_version_type = 'ALL' THEN
                           dummy := 1;
                        ELSE
                           dummy := 0;
                        END IF;
                     END;

               ELSE -- Must be 'AR'

                     BEGIN
                        select 1
                        into   dummy
                        from   dual
                        where  exists
                        (select 1
                         from   pa_budget_versions bv
                         where  bv.project_id = x_project_id
                         --and    bv.fin_plan_type_id = x_fin_plan_type_id
                         and    bv.approved_rev_plan_type_flag = 'Y'
                         and    bV.current_flag = 'Y');

                     EXCEPTION WHEN NO_DATA_FOUND THEN
                        IF x_version_type = 'ALL' THEN
                           dummy := 1;
                        ELSE
                           dummy := 0;
                        END IF;
                     END;
               END IF;
         END IF; -- (NVL(x_plan_type_code,'X') IN ('AC','AR'))

    RETURN dummy;
Exception when others THEN
    return sqlcode;
END check_proj_fin_plan_exists;

------------------------------------------------------------------------------

--  =================================================

--Name:                 check_task_fin_plan_exists
--Type:                 Function
--
--Description:  This function is called primarily from Billing and Projects Maintenance packages
--
--                  If both the p_plan_type_id and the p_version_type IN-parameters are passed with
--                  NON-null values, then the FP logic must check for the plan_type and appropriate
--                  Approved budget flags based on x_plan_type_code.
--
--              Valid Values for x_plan_type_code are:
--              AC -- Approved Cost Budget   AR -- Approved Revenue Budget
--
--              For x_budget_status_code = B(aseline)
--              1.  As per design doc, if 'AC' or 'AR' plan types passed as x_plan_type_code
--                  AND X_FIN_PLAN_TYPE_ID IS NOT NULL,
--                    THEN
--                       Use the approved_cost/rev_plan_type_flags to determine if ANY AC/AR baselined
--                       budgets have been created for FP model.
--                       IF not then if version_type is passed as 'ALL' return success as both Cost and
--                          revenue versions will be baselined together and as it may be the first time
--                          such a case is being created, there would be no baseline versions existing.

  function check_task_fin_plan_exists (x_task_id                IN number,
                                       x_budget_version_id      IN number,
                                       x_budget_status_code     IN varchar2,
                                       x_plan_type_code         IN varchar2,
                                       x_fin_plan_type_id       IN NUMBER,
                                       x_version_type           IN VARCHAR2 )
  return number

  is

     dummy number := 0;

BEGIN



     -- Check for Valid Budget_Status_Code ---------------------------

     IF nvl(x_budget_status_code,'X') <> 'B'
        THEN
          dummy := 0;
          RETURN dummy;
     END IF;

 -- FP Model --------------


         IF (  NVL(x_plan_type_code,'X') IN ('AC','AR')  ) THEN
               IF (x_plan_type_code = 'AC') THEN

                     BEGIN

                        select 1
                          into   dummy
                          from   dual
                          where  exists
                          (select 1
                           from   pa_budget_versions bv
                                  , pa_tasks t
                                  , pa_resource_assignments a
                           where  a.budget_version_id = bv.budget_version_id
                           and    a.task_id = t.task_id
                           and    a.resource_assignment_type = 'USER_ENTERED'
                           and    t.top_task_id = x_task_id
                           --and    bv.fin_plan_type_id = x_fin_plan_type_id
                           and    bv.approved_cost_plan_type_flag = 'Y'
                           and    bV.current_flag = 'Y');

                      EXCEPTION WHEN NO_DATA_FOUND THEN
                        IF x_version_type = 'ALL' THEN
                           dummy := 1;
                        ELSE
                           dummy := 0;
                        END IF;
                     END;

               ELSE -- Must be 'AR'

                     BEGIN
                        select 1
                          into   dummy
                          from   dual
                          where  exists
                          (select 1
                           from   pa_budget_versions bv
                                  , pa_tasks t
                                  , pa_resource_assignments a
                           where  a.budget_version_id = bv.budget_version_id
                           and    a.task_id = t.task_id
                           and    a.resource_assignment_type = 'USER_ENTERED'
                           and    t.top_task_id = x_task_id
                           --and    bv.fin_plan_type_id = x_fin_plan_type_id
                           and    bv.approved_rev_plan_type_flag = 'Y'
                           and    bV.current_flag = 'Y');

                     EXCEPTION WHEN NO_DATA_FOUND THEN
                        IF x_version_type = 'ALL' THEN
                           dummy := 1;
                        ELSE
                           dummy := 0;
                        END IF;
                     END;
               END IF;
         END IF; -- (NVL(x_plan_type_code,'X') IN ('AC','AR'))

    RETURN dummy;
Exception when others THEN
    return sqlcode;
END check_task_fin_plan_exists;
/*==================================================================
   This api returns the start and end dates for the given period name
   along with the plan period type, ie., PA/GL period.
   If the period is not found the api raises error.
 ==================================================================*/

PROCEDURE Get_Period_Details
   (  p_period_name           IN   pa_periods.period_name%TYPE
/*  Changes for FPM. Tracking Bug - 3354518
    Modifying the datatype of parameter p_plan_period_type below to varchar2 */
/*   ,p_plan_period_type      IN   pa_proj_period_profiles.plan_period_type%TYPE */
     ,p_plan_period_type      IN   VARCHAR2
     ,x_start_date            OUT  NOCOPY DATE --File.Sql.39 bug 4440895
     ,x_end_date              OUT  NOCOPY DATE --File.Sql.39 bug 4440895
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Get_Period_Details');
      pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
 END IF;
      -- Check for NOT NULL parameters
      IF (p_period_name IS NULL) OR
         (p_plan_period_type IS NULL)
      THEN
          IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'p_period_name = '|| p_period_name;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'p_plan_period_type = '|| p_plan_period_type;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;
          PA_UTILS.ADD_MESSAGE
                 (p_app_short_name => 'PA',
                  p_msg_name       => 'PA_FP_INV_PARAM_PASSED');

          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      IF     p_plan_period_type = 'PA' THEN

             BEGIN
                   SELECT  start_date
                          ,end_date
                   INTO    x_start_date
                          ,x_end_date
                   FROM   pa_periods
                   WHERE  period_name = p_period_name;
             EXCEPTION
                 WHEN OTHERS THEN
                        IF p_pa_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'Error while fetching the details of pa_period'||SQLERRM;
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        END IF;
                        RAISE;
             END;
      ELSIF  p_plan_period_type = 'GL' THEN

             BEGIN
                   SELECT  start_date
                          ,end_date
                   INTO    x_start_date
                          ,x_end_date
                   FROM    gl_period_statuses g
                          ,pa_implementations i
                   WHERE  g.application_id = pa_period_process_pkg.application_id
                   AND    g.set_of_books_id = i.set_of_books_id
                   AND    g.adjustment_period_flag = 'N'
                   AND    g.period_name = p_period_name;

             EXCEPTION
                 WHEN OTHERS THEN
                        IF p_pa_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'Error while fetching the details of gl_period'||SQLERRM;
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        END IF;
                        RAISE;
             END;
      END IF;

      IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Exiting Get_Period_Details';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
	      pa_debug.reset_err_stack;
	END IF;
 EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           x_return_status := FND_API.G_RET_STS_ERROR;
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
	 IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.reset_err_stack;
	END IF;
           RAISE;

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                           ,p_procedure_name  => 'Get_Period_Details'
                           ,p_error_text      => SQLERRM);
          IF p_pa_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          pa_debug.reset_err_stack;
	END IF;
          RAISE;
END Get_Period_Details;

/*==================================================================
   This api retruns the period that is p_number_of_periods away from
   the p_period_name.

   i) If the number_of_periods is positive it returns
      the period retuned has a start date greater than start date of
      the input period.
   ii)If the number_of_periods is negative the period returned has a
      start date less than the inpt period start date
 ==================================================================*/

/*  Changes for FPM. Tracking Bug - 3354518
    Modifying the datatype of parameter p_plan_period_type below to varchar2
    and x_shifted_period_start_date and x_shifted_period_end_date as date*/

PROCEDURE Get_Shifted_Period (
        p_period_name                   IN      pa_periods.period_name%TYPE
/*     ,p_plan_period_type              IN      pa_proj_period_profiles.plan_period_type%TYPE */
       ,p_plan_period_type              IN      VARCHAR2
       ,p_number_of_periods             IN      NUMBER
       ,x_shifted_period                OUT     NOCOPY pa_periods.period_name%TYPE --File.Sql.39 bug 4440895
/*     ,x_shifted_period_start_date     OUT   pa_proj_period_profiles.period1_start_date%TYPE
       ,x_shifted_period_end_date       OUT     pa_proj_period_profiles.period1_end_date%TYPE */
       ,x_shifted_period_start_date     OUT     NOCOPY DATE   --File.Sql.39 bug 4440895
       ,x_shifted_period_end_date       OUT     NOCOPY DATE --File.Sql.39 bug 4440895
       ,x_return_status                 OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_msg_count                     OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
       ,x_msg_data                      OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS
l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);

l_start_date                    pa_periods.start_date%TYPE;
l_end_date                      pa_periods.end_date%TYPE;

BEGIN
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Get_Shifted_Period');
      pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
END IF;
      -- check for not null parameters
      IF (p_period_name IS NULL)      OR
         (p_plan_period_type IS NULL) OR
         (p_number_of_periods IS NULL)
      THEN
            IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'p_period_name = '|| p_period_name;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'p_plan_period_type = '|| p_plan_period_type;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'p_number_of_periods = '|| p_number_of_periods;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            END IF;
            PA_UTILS.ADD_MESSAGE
                   (p_app_short_name => 'PA',
                    p_msg_name       => 'PA_FP_INV_PARAM_PASSED');

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- Fetch the start and end dates of the input period name

      Pa_Fin_Plan_Utils.Get_Period_Details(
                p_period_name       =>   p_period_name
               ,p_plan_period_type  =>   p_plan_period_type
               ,x_start_date        =>   l_start_date
               ,x_end_date          =>   l_end_date
               ,x_return_status     =>   l_return_status
               ,x_msg_count         =>   l_msg_count
               ,x_msg_data          =>   l_msg_data );

      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      IF p_plan_period_type = 'PA' THEN
           BEGIN
                   IF p_number_of_periods > 0 THEN

                       SELECT  period_name
                              ,start_date
                              ,end_date
                       INTO    x_shifted_period
                              ,x_shifted_period_start_date
                              ,x_shifted_period_end_date
                       FROM   pa_periods a
                       WHERE  p_number_of_periods = (SELECT COUNT(*) FROM pa_periods b
                                                     WHERE  b.start_date < a.start_date
                                                     AND    b.start_date >= l_start_date )
			/* bug fix:5090115: added this to avoid FTS on pa_periods */
			AND a.start_date >= l_start_date ;

                   ELSIF p_number_of_periods < 0 THEN

                       SELECT  /*+ index(a pa_periods_u2) */
			       period_name
                              ,start_date
                              ,end_date
                       INTO    x_shifted_period
                              ,x_shifted_period_start_date
                              ,x_shifted_period_end_date
                       FROM   pa_periods a
                       WHERE  ABS(p_number_of_periods) = (SELECT COUNT(*) FROM pa_periods b
                                                          WHERE  b.start_date > a.start_date
                                                          AND    b.start_date <= l_start_date )
			/* bug fix:5090115: added this to avoid FTS on pa_periods */
			AND a.start_date <= l_start_date ;

                   ELSIF  p_number_of_periods = 0 THEN

                        x_shifted_period             :=   p_period_name;
                        x_shifted_period_start_date  :=   l_start_date;
                        x_shifted_period_end_date    :=   l_end_date;

                   END IF;
           EXCEPTION
                   /*Fix for bug 2753123 starts */
                   WHEN NO_DATA_FOUND THEN
                       IF p_pa_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:= 'Failed in shifting PA profile as Periods do not exist .'||SQLERRM;
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                       END IF;
                       PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                             p_msg_name       => 'PA_BU_INVALID_NEW_PERIOD');
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    /*Fix for bug 2753123 ends */
                   WHEN OTHERS THEN
                        IF p_pa_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'Unexp error while fetching shifted PA period'||SQLERRM;
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        END IF;
                        RAISE;
           END;
      ELSIF p_plan_period_type = 'GL' THEN

            BEGIN
               IF p_number_of_periods > 0 THEN
                       SELECT  period_name
                              ,start_date
                              ,end_date
                       INTO    x_shifted_period
                              ,x_shifted_period_start_date
                              ,x_shifted_period_end_date
                       FROM   gl_period_statuses g1
                             ,pa_implementations i
                       WHERE  g1.application_id = pa_period_process_pkg.application_id
                       AND    g1.set_of_books_id = i.set_of_books_id
                       AND    g1.adjustment_period_flag = 'N'
                       AND    p_number_of_periods = (SELECT COUNT(*)
                                                     FROM   gl_period_statuses g2
                                                           ,pa_implementations i2
                                                     WHERE  g2.adjustment_period_flag = 'N'
                                                     AND    g2.application_id =pa_period_process_pkg.application_id
                                                     AND    g2.set_of_books_id = i2.set_of_books_id
                                                     AND    g2.start_date < g1.start_date
                                                     AND    g2.start_date >= l_start_date);

               ELSIF p_number_of_periods < 0 THEN

                       SELECT  period_name
                              ,start_date
                              ,end_date
                       INTO   x_shifted_period
                              ,x_shifted_period_start_date
                              ,x_shifted_period_end_date
                       FROM   gl_period_statuses g1
                             ,pa_implementations i
                       WHERE  g1.application_id = pa_period_process_pkg.application_id
                       AND    g1.set_of_books_id = i.set_of_books_id
                       AND    g1.adjustment_period_flag = 'N'
                       AND    abs(p_number_of_periods) = (SELECT COUNT(*)
                                                          FROM   gl_period_statuses g2
                                                                ,pa_implementations i2
                                                          WHERE  g2.adjustment_period_flag = 'N'
                                                          AND    g2.application_id = pa_period_process_pkg.application_id
                                                          AND    g2.set_of_books_id = i2.set_of_books_id
                                                          AND    g2.start_date > g1.start_date
                                                          AND    g2.start_date <= l_start_date);
                 ELSIF  p_number_of_periods = 0 THEN

                        x_shifted_period             :=   p_period_name;
                        x_shifted_period_start_date  :=   l_start_date;
                        x_shifted_period_end_date    :=   l_end_date;

                 END IF;
            EXCEPTION
               /*Fix for bug 2753123 starts */
               WHEN NO_DATA_FOUND THEN
                       IF p_pa_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage:= 'Failed in shifting GL profile as Periods do not exist .'||SQLERRM;
                            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        END IF;
                        PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                             p_msg_name       => 'PA_BU_INVALID_NEW_PERIOD');
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               /*Fix for bug 2753123 ends */
               WHEN OTHERS THEN
                        IF p_pa_debug_mode = 'Y' THEN
                                pa_debug.g_err_stage:= 'Unexp error while fetching shifted GL period'||SQLERRM;
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        END IF;
                        RAISE;
            END;

      END IF;

      IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Exiting Get_Shifted_Period';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      pa_debug.reset_err_stack;
	END IF;
  EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           x_return_status := FND_API.G_RET_STS_ERROR;
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
 IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.reset_err_stack;
 END IF;
           RAISE;

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                           ,p_procedure_name  => 'Get_Shifted_Period'
                           ,p_error_text      => SQLERRM);
          IF p_pa_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          pa_debug.reset_err_stack;
	END IF;
          RAISE;
END Get_Shifted_Period;

/* This function takes the returns est_quantity or labor_quantity (planned qty) from pa_budget_lines
   based on the parameter p_quantity ('ESTIMATED','PLANNED'). This values are return for CI version
   if p_version_code is CTRL_ITEM_VERSION. If p_version_code CURRENT_BASELINED_VERSION then the qty
   is returned from the current baselined version */
/* Bug 3749781: New allowed value for p_version_code  : CURRENT_WORKING_VERSION
                                  and p_quantity_type : EQUIPMENT added */

FUNCTION Get_Approved_Budget_Ver_Qty (
        p_project_id                     IN NUMBER
       ,p_version_code                  IN  VARCHAR2 /* CTRL_ITEM_VERSION or CURRENT_BASELINED_VERSION or CURRENT_WORKING_VERSION*/
       ,p_quantity_type                 IN  VARCHAR2 /* ESTIMATED or PLANNED or EQUIPMENT */
       ,p_ci_id                         IN  NUMBER)
    RETURN pa_budget_lines.quantity%TYPE is

/* cur_ci_ver, cur_working_ver and cur_baselined_ver should have the same number and datatype of columns */

cursor cur_ci_ver(c_version_type     pa_budget_versions.version_type%TYPE,
                  c_ci_id            pa_budget_versions.ci_id%TYPE) IS
SELECT budget_version_id, labor_quantity, est_quantity, equipment_quantity
FROM   pa_budget_versions
WHERE  project_id = p_project_id
-- Bug 5845142
-- AND    version_type = nvl(c_version_type,version_type)
AND    DECODE(c_version_type,
              'COST',approved_cost_plan_type_flag,
              'Y')='Y'
AND    ci_id = c_ci_id;

/* cur_ci_ver and cur_baselined_ver should have the same number and datatype of columns */

cursor cur_baselined_ver(c_version_type     pa_budget_versions.version_type%TYPE) IS
SELECT budget_version_id, labor_quantity, est_quantity, equipment_quantity
FROM   pa_budget_versions
WHERE  project_id = p_project_id
AND    current_flag = 'Y'
AND    version_type = nvl(c_version_type,version_type)
AND    (NVL(Approved_Cost_Plan_Type_Flag ,'N') = 'Y' OR
       NVL(Approved_Rev_Plan_Type_Flag  ,'N') = 'Y' );

cursor cur_working_ver(c_version_type     pa_budget_versions.version_type%TYPE) IS
SELECT budget_version_id, labor_quantity, est_quantity, equipment_quantity
FROM   pa_budget_versions
WHERE  project_id = p_project_id
AND    current_working_flag = 'Y'
AND    version_type = nvl(c_version_type,version_type)
AND    (NVL(Approved_Cost_Plan_Type_Flag ,'N') = 'Y' OR
       NVL(Approved_Rev_Plan_Type_Flag  ,'N') = 'Y' );

cur_ci_ver_rec                  cur_ci_ver%rowtype;
l_ver_count                     NUMBER;

C_BASELINED_VERSION   CONSTANT  VARCHAR2(30) := 'CURRENT_BASELINED_VERSION';
C_WORKING_VERSION     CONSTANT  VARCHAR2(30) := 'CURRENT_WORKING_VERSION';
C_CTRL_ITEM_VERSION   CONSTANT  VARCHAR2(30) := 'CTRL_ITEM_VERSION';
C_ESTIMATED_QUANTITY  CONSTANT  VARCHAR2(30) := 'ESTIMATED';
C_PLANNED_QUANTITY    CONSTANT  VARCHAR2(30) := 'PLANNED';
C_EQUIPMENT_QUANTITY  CONSTANT  VARCHAR2(30) := 'EQUIPMENT';

BEGIN

      IF p_pa_debug_mode = 'Y' THEN
              pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Get_Approved_Budget_Ver_Qty');
              pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
      END IF;

      -- Check for business rules violations

      IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Validating input parameters';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                         PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      IF ((p_project_id IS NULL) OR (p_version_code IS NULL) OR (p_quantity_type IS NULL)) OR
           ((p_version_code = C_CTRL_ITEM_VERSION) AND (p_ci_id IS NULL)) THEN
              IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        pa_debug.g_err_stage:= 'p_version_code = '|| p_version_code;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        pa_debug.g_err_stage:= 'p_quantity_type = '|| p_quantity_type;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        pa_debug.g_err_stage:= 'p_ci_id = '|| p_ci_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              END IF;
              PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      IF p_version_code = C_CTRL_ITEM_VERSION THEN

          /* Check the number of version types attached to the ci id.
             It would be two, if preference code of the appr budget type is COST_AND_REV_SEP
             OR
             two appr budget plan types are attached to the project (one cost appr plan type and
             another crev appr plan type). So, when the count is two,
             only the cost version is considered for deriving the qty info.
             If the count is count is one, the qty info should be taken from the available version */

          SELECT count(1)
          INTO   l_ver_count
          FROM   pa_budget_versions
          WHERE  project_id = p_project_id
          AND    ci_id = p_ci_id;

          IF l_ver_count = 2 THEN

              OPEN cur_ci_ver(PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST, p_ci_id);
              FETCH cur_ci_ver INTO cur_ci_ver_rec;
              IF cur_ci_ver%NOTFOUND THEN
                  IF p_pa_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Could not fetch cost ci version details!!!...';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;
              END IF;
              CLOSE cur_ci_ver;

          ELSIF l_ver_count = 1 THEN

              OPEN cur_ci_ver(null, p_ci_id);
              FETCH cur_ci_ver INTO cur_ci_ver_rec;
              IF cur_ci_ver%NOTFOUND THEN
                  IF p_pa_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Could not fetch ci version details!!!...';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;
              END IF;
              CLOSE cur_ci_ver;

          ELSIF l_ver_count <> 0 THEN

              /* There should not be a case where there more more than 2 versions !! */

              IF p_pa_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'More than 2 ctrl item versions for the project!!!';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                             PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;
          END IF;

      ELSIF p_version_code = C_BASELINED_VERSION THEN

          SELECT count(1)
          INTO   l_ver_count
          FROM   pa_budget_versions
          WHERE  project_id = p_project_id
          AND    current_flag = 'Y'
          AND    (Approved_Cost_Plan_Type_Flag = 'Y' OR
                 Approved_Rev_Plan_Type_Flag = 'Y' );

          IF l_ver_count = 2 THEN

              OPEN cur_baselined_ver(PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST);
              FETCH cur_baselined_ver INTO cur_ci_ver_rec;
              CLOSE cur_baselined_ver;

          ELSIF l_ver_count = 1 THEN

              OPEN cur_baselined_ver(null);
              FETCH cur_baselined_ver INTO cur_ci_ver_rec;
              CLOSE cur_baselined_ver;

          ELSIF l_ver_count <> 0 THEN

              /* There should not be a case where there more more than 2 versions !! */

              IF p_pa_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'More than 2 current baselined item versions for the project!!!';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                             PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;

          END IF;

      ELSIF p_version_code = C_WORKING_VERSION THEN

          SELECT count(1)
          INTO   l_ver_count
          FROM   pa_budget_versions
          WHERE  project_id = p_project_id
          AND    current_working_flag = 'Y'
          AND    (Approved_Cost_Plan_Type_Flag = 'Y' OR
                 Approved_Rev_Plan_Type_Flag = 'Y' );

          IF l_ver_count = 2 THEN

              OPEN cur_working_ver(PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST);
              FETCH cur_working_ver INTO cur_ci_ver_rec;
              CLOSE cur_working_ver;

          ELSIF l_ver_count = 1 THEN

              OPEN cur_working_ver(null);
              FETCH cur_working_ver INTO cur_ci_ver_rec;
              CLOSE cur_working_ver;

          ELSIF l_ver_count <> 0 THEN

              /* There should not be a case where there more more than 2 versions !! */

              IF p_pa_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'More than 2 current working versions for the project!!!';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                             PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;

          END IF;


      END IF;

      IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Exiting Pa_Fin_Plan_Utils.Get_Approved_Budget_Ver_Qty';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                         PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
              pa_debug.reset_err_stack;

      END IF;

      IF p_quantity_type = C_ESTIMATED_QUANTITY THEN
        return cur_ci_ver_rec.est_quantity;
      ELSIF p_quantity_type = C_PLANNED_QUANTITY THEN
          return cur_ci_ver_rec.labor_quantity;
      ELSIF p_quantity_type = C_EQUIPMENT_QUANTITY THEN
          return cur_ci_ver_rec.equipment_quantity;
      ELSE
          return Null;
      END IF;


 EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           IF p_pa_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'Invalid arg exception ..';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                   pa_debug.reset_err_stack;
           END IF;
           RAISE;

   WHEN others THEN

          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'Pa_Fin_Plan_Utils'
                           ,p_procedure_name  => 'Get_Approved_Budget_Ver_Qty'
                           ,p_error_text      => sqlerrm);

          IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Unexpected Error'||sqlerrm;
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              pa_debug.reset_err_stack;

          END IF;
          RAISE;

END Get_Approved_Budget_Ver_Qty;


/*This API is internally used to validate whether all the rate types and rate date types passed
  are valid or not. This is called from VALIDATE_CURRENCY_ATTRIBUTES when it is called from
  AMG
*/
PROCEDURE VALIDATE_INPUT_PARAMS
                     (p_project_cost_rate_type             IN  pa_proj_fp_options.project_cost_rate_type%TYPE
                     ,p_project_cost_rate_date_typ         IN  pa_proj_fp_options.project_cost_rate_date_type%TYPE
                     ,p_projfunc_cost_rate_type            IN  pa_proj_fp_options.projfunc_cost_rate_type%TYPE
                     ,p_projfunc_cost_rate_date_typ        IN  pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE
                     ,p_project_rev_rate_type              IN  pa_proj_fp_options.project_rev_rate_type%TYPE
                     ,p_project_rev_rate_date_typ          IN  pa_proj_fp_options.project_rev_rate_date_type%TYPE
                     ,p_projfunc_rev_rate_type             IN  pa_proj_fp_options.projfunc_rev_rate_type%TYPE
                     ,p_projfunc_rev_rate_date_typ         IN  pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE
                     ,p_project_currency_code              IN  pa_projects_all.project_currency_code%TYPE
                     ,p_projfunc_currency_code             IN  pa_projects_all.projfunc_currency_code%TYPE
                     ,p_txn_currency_code                  IN  pa_budget_lines.txn_currency_code%TYPE
                     ,x_return_status                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                     ,x_msg_count                          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                     ,x_msg_data                           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                     ) IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_debug_mode                    VARCHAR2(30);
l_exists                        VARCHAR2(1);

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.validate_input_params');
 END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF l_debug_mode = 'Y' THEN
        pa_debug.set_process('PLSQL','LOG',l_debug_mode);
        pa_debug.g_err_stage:='About to validate the values for currency conversion attributes passed for AMG';
        pa_debug.write('validate_input_params: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    /*Validate Rate Type*/
    BEGIN
        SELECT 'Y'
        INTO   l_exists
        FROM    dual
        WHERE   EXISTS (SELECT 'X'
                    FROM   pa_conversion_types_v
                    WHERE  ((p_project_cost_rate_type IS NULL
                             OR p_project_cost_rate_type=conversion_type)  OR

                             p_project_currency_code IN( p_txn_currency_code
                                                        ,p_projfunc_currency_code))
                    AND    rownum=1)

        AND     EXISTS (SELECT 'X'
                    FROM   pa_conversion_types_v
                    WHERE  ((p_projfunc_cost_rate_type IS NULL
                             OR p_projfunc_cost_rate_type=conversion_type) OR

                             p_projfunc_currency_code = p_txn_currency_code )
                    AND    rownum=1)

        AND     EXISTS (SELECT 'X'
                    FROM   pa_conversion_types_v
                    WHERE  ((p_project_rev_rate_type IS NULL
                             OR p_project_rev_rate_type=conversion_type)  OR

                             p_project_currency_code IN( p_txn_currency_code
                                                        ,p_projfunc_currency_code))
                    AND    rownum=1)

        AND     EXISTS (SELECT 'X'
                    FROM   pa_conversion_types_v
                    WHERE  ((p_projfunc_rev_rate_type IS NULL
                             OR p_projfunc_rev_rate_type=conversion_type)  OR

                              p_projfunc_currency_code = p_txn_currency_code )
                    AND    rownum=1);

    EXCEPTION

       WHEN NO_DATA_FOUND  THEN
          X_RETURN_STATUS :=  FND_API.G_RET_STS_ERROR;
          PA_UTILS.add_message
            (p_app_short_name => 'PA',
             p_msg_name       => 'PA_FP_INCORRECT_RATE_TYPE_AMG',
             p_token1         => 'TASK',
             p_value1         =>  pa_budget_pvt.g_task_number,
             p_token2         => 'SOURCE_NAME',
             p_value2         => pa_budget_pvt.g_resource_alias,
             p_token3         => 'START_DATE',
             p_value3         => to_char(pa_budget_pvt.g_start_date));
END;

    /*VALIDATE RATE DATE TYPE*/
    BEGIN
        SELECT 'Y'
        INTO l_exists
        FROM    dual
        WHERE   EXISTS (SELECT 'X'
                    FROM   pa_lookups
                    WHERE  lookup_type='PA_FP_RATE_DATE_TYPE'
                    AND    ((p_project_cost_rate_date_typ IS NULL
                             OR p_project_cost_rate_date_typ=lookup_code) OR

                             p_project_currency_code IN( p_txn_currency_code
                                                        ,p_projfunc_currency_code))
                    AND    rownum=1)

        AND     EXISTS (SELECT 'X'
                    FROM   pa_lookups
                    WHERE  lookup_type='PA_FP_RATE_DATE_TYPE'
                    AND    ((p_projfunc_cost_rate_date_typ IS NULL
                             OR p_projfunc_cost_rate_date_typ=lookup_code)  OR

                             p_projfunc_currency_code = p_txn_currency_code )
                    AND    rownum=1)

        AND     EXISTS (SELECT 'X'
                    FROM   pa_lookups
                    WHERE  lookup_type='PA_FP_RATE_DATE_TYPE'
                    AND    ((p_project_rev_rate_date_typ IS NULL
                             OR p_project_rev_rate_date_typ=lookup_code) OR

                            p_project_currency_code IN( p_txn_currency_code
                                                       ,p_projfunc_currency_code))
                    AND    rownum=1)

        AND     EXISTS (SELECT 'X'
                    FROM   pa_lookups
                    WHERE  lookup_type='PA_FP_RATE_DATE_TYPE'
                    AND    ((p_projfunc_rev_rate_date_typ IS NULL
                             OR p_projfunc_rev_rate_date_typ=lookup_code) OR

                             p_projfunc_currency_code = p_txn_currency_code )
                    AND    rownum=1)  ;

    EXCEPTION

       WHEN NO_DATA_FOUND  THEN
          X_RETURN_STATUS :=  FND_API.G_RET_STS_ERROR;
          PA_UTILS.add_message
            (p_app_short_name => 'PA',
             p_msg_name       => 'PA_FP_INVALID_RATE_DT_TYPE_AMG',
             p_token1         => 'TASK',
             p_value1         =>  pa_budget_pvt.g_task_number,
             p_token2         => 'SOURCE_NAME',
             p_value2         => pa_budget_pvt.g_resource_alias,
             p_token3         => 'START_DATE',
             p_value3         => to_char(pa_budget_pvt.g_start_date));

    END;

    IF l_debug_mode='Y' THEN
        pa_debug.g_err_stage:= 'Exiting validate_input_params';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

	   pa_debug.reset_err_stack;
	END IF;
EXCEPTION

WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg
         ( p_pkg_name       => 'PA_FIN_PLAN_UTILS'
          ,p_procedure_name => 'validate_input_params'
          ,p_error_text     => sqlerrm);

        pa_debug.G_Err_Stack := SQLERRM;
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('validate_input_params' || l_module_name,pa_debug.G_Err_Stack,4);
        pa_debug.reset_err_stack;
	END IF;
        RAISE;

END  validate_input_params;

/*This procedure validates a set of conversion attributes. It returns  a validity code indicating
  the validity of conversion attributes. The values of validity code are

  RATE_TYPE_NULL       which indicates that the rate type is null
  RATE_DATE_TYPE_NULL  which indicates that the rate date type is null
  RATE_DATE_NULL       which indicates that the rate date is null
  VALID_CONV_ATTR      which indicates that the attributes passed are valid.
  NULL_ATTR            which indicates that the attributes passed are null
  RATE_NULL            which indicates that the rate passed is null
*/

PROCEDURE VALIDATE_CONV_ATTRIBUTES
          ( px_rate_type         IN OUT  NOCOPY pa_proj_fp_options.projfunc_cost_rate_type%TYPE --File.Sql.39 bug 4440895
           ,px_rate_date_type    IN OUT  NOCOPY pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE --File.Sql.39 bug 4440895
           ,px_rate_date         IN OUT  NOCOPY pa_proj_fp_options.projfunc_cost_rate_date%TYPE --File.Sql.39 bug 4440895
           ,px_rate              IN OUT  NOCOPY pa_budget_lines.project_cost_exchange_rate%TYPE --File.Sql.39 bug 4440895
           ,p_amount_type_code   IN      VARCHAR2
           ,p_currency_type_code IN      VARCHAR2
           ,p_calling_context    IN      VARCHAR2
           ,x_first_error_code      OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          )  IS
l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_debug_mode                    VARCHAR2(30);

BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.VALIDATE_CONV_ATTRIBUTES');
 END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF l_debug_mode = 'Y' THEN
        pa_debug.set_process('PLSQL','LOG',l_debug_mode);
        pa_debug.g_err_stage:='Validating the given set of conversion attributes';
        pa_debug.write('validate_set_of_conv_attrs: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF((px_rate_type IS NULL)      AND
       (px_rate_date_type IS NULL) AND
       (px_rate_date IS NULL) )    THEN

          /* Null Combination of conversion attributes is valid in the case of create update plan type
             pages. Hence this check is made
          */

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='All the attributes are null';
               pa_debug.write('validate_set_of_conv_attrs: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          IF(p_calling_context=PA_FP_CONSTANTS_PKG.G_CR_UP_PLAN_TYPE_PAGE) THEN
               /* Do Nothing as this will be checked in validate_currency_attributes */
               NULL;
          ELSE
               x_return_status := FND_API.G_RET_STS_ERROR;
               /*PA_UTILS.ADD_MESSAGE
                             (p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_RATE_TYPE_REQ');
               */
               /*
                  NOTE: The following message is different from the first error code that is being
                  passed back. This specific message is being used as this accepts tokens.
               */
               IF  (p_calling_context=PA_FP_CONSTANTS_PKG.G_AMG_API_DETAIL ) THEN

                     PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                        p_msg_name      => 'PA_FP_INVALID_RATE_TYPE_AMG',
                        p_token1        => 'TASK',
                        p_value1        =>  pa_budget_pvt.g_task_number,
                        p_token2        => 'SOURCE_NAME',
                        p_value2        =>  pa_budget_pvt.g_resource_alias,
                        p_token3        => 'START_DATE',
                        p_value3        => to_char(pa_budget_pvt.g_start_date),
                        p_token4        => 'COST_REV',
                        p_value4        => p_amount_type_code,
                        p_token5        => 'PROJECT_PROJFUNC',
                        p_value5        => p_currency_type_code );


               ELSE

                     PA_UTILS.ADD_MESSAGE
                            (p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INVALID_RATE_TYPE',
                              p_token1        => 'COST_REV',
                              p_value1        => p_amount_type_code,
                              p_token2        => 'PROJECT_PROJFUNC',
                              p_value2        => p_currency_type_code );

               END IF;

               /* for any other context error messages need to be added */
          END IF;

          x_first_error_code := 'PA_FP_RATE_TYPE_REQ';

    ELSIF (px_rate_type IS NULL) THEN

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Rate Type is Null';
               pa_debug.write('validate_set_of_conv_attrs: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          IF  (p_calling_context=PA_FP_CONSTANTS_PKG.G_AMG_API_DETAIL ) THEN

                PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                        p_msg_name      => 'PA_FP_INVALID_RATE_TYPE_AMG',
                        p_token1        => 'TASK',
                        p_value1        =>  pa_budget_pvt.g_task_number,
                        p_token2        => 'SOURCE_NAME',
                        p_value2        =>  pa_budget_pvt.g_resource_alias,
                        p_token3        => 'START_DATE',
                        p_value3        => to_char(pa_budget_pvt.g_start_date),
                        p_token4        => 'COST_REV',
                        p_value4        => p_amount_type_code,
                        p_token5        => 'PROJECT_PROJFUNC',
                        p_value5        => p_currency_type_code );
          ELSE

                PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                        p_msg_name      => 'PA_FP_INVALID_RATE_TYPE',
                        p_token1        => 'COST_REV',
                        p_value1        => p_amount_type_code,
                        p_token2        => 'PROJECT_PROJFUNC',
                        p_value2        => p_currency_type_code );

          END IF;

          IF x_first_error_code IS NULL THEN
               x_first_error_code := 'PA_FP_INVALID_RATE_TYPE';
          END IF;

    ELSIF (px_rate_type = PA_FP_CONSTANTS_PKG.G_RATE_TYPE_USER ) THEN

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Rate Type is User';
               pa_debug.write('validate_set_of_conv_attrs: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;
          --Added the constant G_AMG_API_HEADER as part of changes due to finplan model in AMG
          IF (px_rate IS NULL AND nvl(p_calling_context,'-99') NOT IN ( PA_FP_CONSTANTS_PKG.G_CR_UP_PLAN_TYPE_PAGE
                                                                        ,PA_FP_CONSTANTS_PKG.G_AMG_API_HEADER) )THEN

               /* on create update plan type it is allowed that when rate type is user there is no rate defined
               */
               x_return_status := FND_API.G_RET_STS_ERROR;

               IF  (p_calling_context=PA_FP_CONSTANTS_PKG.G_AMG_API_DETAIL ) THEN
                     PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                        p_msg_name      => 'PA_FP_USER_EXCH_RATE_REQ_AMG',
                        p_token1        => 'TASK',
                        p_value1        =>  pa_budget_pvt.g_task_number,
                        p_token2        => 'SOURCE_NAME',
                        p_value2        =>  pa_budget_pvt.g_resource_alias,
                        p_token3        => 'START_DATE',
                        p_value3        => to_char(pa_budget_pvt.g_start_date),
                        p_token4        => 'COST_REV',
                        p_value4        => p_amount_type_code,
                        p_token5        => 'PROJECT_PROJFUNC',
                        p_value5        => p_currency_type_code );
               ELSE
               /*
                   NOTE : The following error message that is being used does not take tokens.
                   As of now for WEBADI and Create Update Plan type context, this is not an
                   issue. But when this api is being used for the other contexts like AMG and
                   edit plan line details page,... this message should be changed so as to accept
                   tokens.
               */
                     PA_UTILS.ADD_MESSAGE
                          (p_app_short_name => 'PA',
                           p_msg_name      => 'PA_FP_USER_EXCH_RATE_REQ',
                           p_token1        => 'COST_REV',
                           p_value1        => p_amount_type_code,
                           p_token2        => 'PROJECT_PROJFUNC',
                           p_value2        => p_currency_type_code );
              END IF;


          ELSE

               /* Null out the Rate Date Type and Rate Date */
               px_rate_date_type := null;
               px_rate_date := null;
--             x_validity_code:=PA_FP_CONSTANTS_PKG.G_VALID_CONV_ATTR; Not required

          END IF;

          IF x_first_error_code IS NULL THEN
               x_first_error_code := 'PA_FP_USER_EXCH_RATE_REQ';
          END IF;

    /* this means that rate type is not null and its value is not user */
    ELSIF (px_rate_date_type IS NULL) THEN

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Rate Date Type is Null';
               pa_debug.write('validate_set_of_conv_attrs: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          IF  (p_calling_context=PA_FP_CONSTANTS_PKG.G_AMG_API_DETAIL ) THEN

                PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                        p_msg_name      => 'PA_FP_INVALID_RATE_DT_TYP_AMG',
                        p_token1        => 'TASK',
                        p_value1        =>  pa_budget_pvt.g_task_number,
                        p_token2        => 'SOURCE_NAME',
                        p_value2        =>  pa_budget_pvt.g_resource_alias,
                        p_token3        => 'START_DATE',
                        p_value3        => to_char(pa_budget_pvt.g_start_date),
                        p_token4        => 'COST_REV',
                        p_value4        => p_amount_type_code,
                        p_token5        => 'PROJECT_PROJFUNC',
                        p_value5        => p_currency_type_code );
          ELSE
                PA_UTILS.ADD_MESSAGE
                              (p_app_short_name => 'PA',
                                p_msg_name      => 'PA_FP_INVALID_RATE_DATE_TYPE',
                                p_token1        => 'COST_REV',
                                p_value1        => p_amount_type_code,
                                p_token2        => 'PROJECT_PROJFUNC',
                                p_value2        => p_currency_type_code );

          END IF;

          IF x_first_error_code IS NULL THEN
               x_first_error_code := 'PA_FP_INVALID_RATE_DATE_TYPE';
          END IF;

    /* this means that rate type is not null and its value is not user and rate_date_type value is FIXED */
    ELSIF px_rate_date_type = PA_FP_CONSTANTS_PKG.G_RATE_DATE_TYPE_FIXED_DATE THEN

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Rate Date Type is Fixed';
               pa_debug.write('validate_set_of_conv_attrs: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          /* Rate Date Should not be null */
          IF (px_rate_date IS NULL) THEN

               x_return_status := FND_API.G_RET_STS_ERROR;
               IF  (p_calling_context=PA_FP_CONSTANTS_PKG.G_AMG_API_DETAIL ) THEN
                     PA_UTILS.ADD_MESSAGE
                            (p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INVALID_RATE_DATE_AMG',
                              p_token1        => 'TASK',
                              p_value1        =>  pa_budget_pvt.g_task_number,
                              p_token2        => 'SOURCE_NAME',
                              p_value2        =>  pa_budget_pvt.g_resource_alias,
                              p_token3        => 'START_DATE',
                              p_value3        => to_char(pa_budget_pvt.g_start_date),
                              p_token4        => 'COST_REV',
                              p_value4        => p_amount_type_code,
                              p_token5        => 'PROJECT_PROJFUNC',
                              p_value5        => p_currency_type_code );
               ELSE
                     PA_UTILS.ADD_MESSAGE
                                (p_app_short_name => 'PA',
                                  p_msg_name      => 'PA_FP_INVALID_RATE_DATE',
                                  p_token1        => 'COST_REV',
                                  p_value1        => p_amount_type_code,
                                  p_token2        => 'PROJECT_PROJFUNC',
                                  p_value2        => p_currency_type_code );
               END IF;

               IF x_first_error_code IS NULL THEN
                    x_first_error_code := 'PA_FP_INVALID_RATE_DATE';
               END IF;
          ELSE
               px_rate:=null;
--             x_validity_code := PA_FP_CONSTANTS_PKG.G_VALID_CONV_ATTR; Not required
          END IF;

    /* This means that rate type is not null and its value is not user
       and rate_date_type is not null and its value is NOT FIXED. This is a valid set.*/
    ELSE
          /* CHECK IF THIS NEEDS TO BE DONE IN CASE ITS CALLED FROM EDIT PLAN LINE PAGES */
          px_rate_date := null;
          px_rate := null;
--        x_validity_code:=PA_FP_CONSTANTS_PKG.G_VALID_CONV_ATTR;

    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Exiting validate_conv_attributes';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

    pa_debug.reset_err_stack;
END IF;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg
         ( p_pkg_name       => 'PA_FIN_PLAN_UTILS'
          ,p_procedure_name => 'VALIDATE_CONV_ATTRIBUTES'
          ,p_error_text     => sqlerrm);

        pa_debug.G_Err_Stack := SQLERRM;
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('CHECK_MRC_INSTALL: ' || l_module_name,pa_debug.G_Err_Stack,4);
        pa_debug.reset_err_stack;
	END IF;
        RAISE;

END  VALIDATE_CONV_ATTRIBUTES;

/* This method is called for validating the currency attributes. In addition to the 12 conversion
   attributes this procedure also takes the context from which it is called , PC and PFC as
   parameters. This method  in turn calls  VALIDATE_CONV_ATTRIBUTES. The values for context are
   CR_UP_PLAN_TYPE_PAGE (for create Update plan type page)
   AMG_API (for AMG APIs)
*/

PROCEDURE VALIDATE_CURRENCY_ATTRIBUTES
          ( px_project_cost_rate_type        IN OUT  NOCOPY pa_proj_fp_options.project_cost_rate_type%TYPE --File.Sql.39 bug 4440895
           ,px_project_cost_rate_date_typ    IN OUT  NOCOPY pa_proj_fp_options.project_cost_rate_date_type%TYPE --File.Sql.39 bug 4440895
           ,px_project_cost_rate_date        IN OUT  NOCOPY pa_proj_fp_options.project_cost_rate_date%TYPE --File.Sql.39 bug 4440895
           ,px_project_cost_exchange_rate    IN OUT  NOCOPY pa_budget_lines.project_cost_exchange_rate%TYPE --File.Sql.39 bug 4440895
           ,px_projfunc_cost_rate_type       IN OUT  NOCOPY pa_proj_fp_options.projfunc_cost_rate_type%TYPE --File.Sql.39 bug 4440895
           ,px_projfunc_cost_rate_date_typ   IN OUT  NOCOPY pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE --File.Sql.39 bug 4440895
           ,px_projfunc_cost_rate_date       IN OUT  NOCOPY pa_proj_fp_options.projfunc_cost_rate_date%TYPE --File.Sql.39 bug 4440895
           ,px_projfunc_cost_exchange_rate   IN OUT  NOCOPY pa_budget_lines.projfunc_cost_exchange_rate%TYPE --File.Sql.39 bug 4440895
           ,px_project_rev_rate_type         IN OUT  NOCOPY pa_proj_fp_options.project_rev_rate_type%TYPE --File.Sql.39 bug 4440895
           ,px_project_rev_rate_date_typ     IN OUT  NOCOPY pa_proj_fp_options.project_rev_rate_date_type%TYPE --File.Sql.39 bug 4440895
           ,px_project_rev_rate_date         IN OUT  NOCOPY pa_proj_fp_options.project_rev_rate_date%TYPE --File.Sql.39 bug 4440895
           ,px_project_rev_exchange_rate     IN OUT  NOCOPY pa_budget_lines.project_rev_exchange_rate%TYPE --File.Sql.39 bug 4440895
           ,px_projfunc_rev_rate_type        IN OUT  NOCOPY pa_proj_fp_options.projfunc_rev_rate_type%TYPE --File.Sql.39 bug 4440895
           ,px_projfunc_rev_rate_date_typ    IN OUT  NOCOPY pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE --File.Sql.39 bug 4440895
           ,px_projfunc_rev_rate_date        IN OUT  NOCOPY pa_proj_fp_options.projfunc_rev_rate_date%TYPE --File.Sql.39 bug 4440895
           ,px_projfunc_rev_exchange_rate    IN OUT  NOCOPY pa_budget_lines.projfunc_rev_exchange_rate%TYPE --File.Sql.39 bug 4440895
           ,p_project_currency_code          IN      pa_projects_all.project_currency_code%TYPE
           ,p_projfunc_currency_code         IN      pa_projects_all.projfunc_currency_code%TYPE
           ,p_txn_currency_code              IN      pa_projects_all.projfunc_currency_code%TYPE
           ,p_context                        IN      VARCHAR2
           ,p_attrs_to_be_validated          IN      VARCHAR2  -- valid values are COST, REVENUE , BOTH
           ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          )IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_debug_mode                    VARCHAR2(30);
/*
l_loop_count                    NUMBER;
l_rate_type                     pa_proj_fp_options.project_cost_rate_type%TYPE;
l_rate_date_type                pa_proj_fp_options.project_cost_rate_date_type%TYPE;
l_rate_date                     pa_proj_fp_options.project_cost_rate_date%TYPE;
l_rate                          pa_budget_lines.project_rev_exchange_rate%TYPE ;
l_validity_code                 VARCHAR2(30);*/
l_pc_cost_validity_code         VARCHAR2(30) := PA_FP_CONSTANTS_PKG.G_VALID_CONV_ATTR;
l_pc_rev_validity_code          VARCHAR2(30) := PA_FP_CONSTANTS_PKG.G_VALID_CONV_ATTR;
l_pfc_cost_validity_code        VARCHAR2(30) := PA_FP_CONSTANTS_PKG.G_VALID_CONV_ATTR;
l_pfc_rev_validity_code         VARCHAR2(30) := PA_FP_CONSTANTS_PKG.G_VALID_CONV_ATTR;
l_project_token                 fnd_new_messages.message_text%TYPE; --bug 2848406 VARCHAR2(30);
l_projfunc_token                fnd_new_messages.message_text%TYPE; --bug 2848406 VARCHAR2(30);
l_cost_token                    fnd_new_messages.message_text%TYPE; --bug 2848406 VARCHAR2(30);
l_rev_token                     fnd_new_messages.message_text%TYPE; --bug 2848406 VARCHAR2(30);
/*
l_project_projfunc_token        VARCHAR2(30);
l_cost_rev_token                VARCHAR2(30);
*/
l_any_error_occurred_flag       VARCHAR2(1);
l_first_error_code              VARCHAR2(30); /* used for webADI */

BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.VALIDATE_CURRENCY_ATTRIBUTES');
 END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF l_debug_mode = 'Y' THEN
    pa_debug.set_process('PLSQL','LOG',l_debug_mode);
    END IF;
    IF (p_project_currency_code IS NULL OR
       p_projfunc_currency_code IS NULL OR
       p_context                IS NULL OR
       p_attrs_to_be_validated  IS NULL ) THEN

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='p_project_currency_code = ' || p_project_currency_code;
             pa_debug.write('Get_Baselined_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);

             pa_debug.g_err_stage:='p_projfunc_currency_code = ' || p_projfunc_currency_code;
             pa_debug.write('Get_Baselined_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);

             pa_debug.g_err_stage:='p_context = ' || p_context;
             pa_debug.write('Get_Baselined_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);

             pa_debug.g_err_stage:='p_attrs_to_be_validated = ' || p_attrs_to_be_validated;
             pa_debug.write('Get_Baselined_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);
          END IF;

          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Invalid parameters passed' ;
             pa_debug.write('validate_currency_attributes: ' || l_module_name,pa_debug.g_err_stage,1);
          END IF;
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;


    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='About to validate the currency conversion attributes';
        pa_debug.write('validate_currency_attributes: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    /*Get the message tokens that may be required while validating the attributes*/

    FND_MESSAGE.SET_NAME ('PA',PA_FP_CONSTANTS_PKG.G_COST_TOKEN_MESSAGE);
    l_cost_token := FND_MESSAGE.GET;

    FND_MESSAGE.SET_NAME ('PA',PA_FP_CONSTANTS_PKG.G_REV_TOKEN_MESSAGE);
    l_rev_token := FND_MESSAGE.GET;

    FND_MESSAGE.SET_NAME ('PA',PA_FP_CONSTANTS_PKG.G_PROJECT_TOKEN_MESSAGE);
    l_project_token := FND_MESSAGE.GET;

    FND_MESSAGE.SET_NAME ('PA',PA_FP_CONSTANTS_PKG.G_PROJFUNC_TOKEN_MESSAGE);
    l_projfunc_token := FND_MESSAGE.GET;

    IF (p_context=PA_FP_CONSTANTS_PKG.G_AMG_API_HEADER OR
        p_context=PA_FP_CONSTANTS_PKG.G_AMG_API_DETAIL ) THEN

        VALIDATE_INPUT_PARAMS(p_project_cost_rate_type      =>     px_project_cost_rate_type
                             ,p_project_cost_rate_date_typ  =>     px_project_cost_rate_date_typ
                             ,p_projfunc_cost_rate_type     =>     px_projfunc_cost_rate_type
                             ,p_projfunc_cost_rate_date_typ =>     px_projfunc_cost_rate_date_typ
                             ,p_project_rev_rate_type       =>     px_project_rev_rate_type
                             ,p_project_rev_rate_date_typ   =>     px_project_rev_rate_date_typ
                             ,p_projfunc_rev_rate_type      =>     px_projfunc_rev_rate_type
                             ,p_projfunc_rev_rate_date_typ  =>     px_projfunc_rev_rate_date_typ
                             ,p_project_currency_code       =>     p_project_currency_code
                             ,p_projfunc_currency_code      =>     p_projfunc_currency_code
                             ,p_txn_currency_code           =>     p_txn_currency_code
                             ,x_return_status               =>     x_return_status
                             ,x_msg_count                   =>     x_msg_count
                             ,x_msg_data                    =>     x_msg_data);

         /* Throw the error if the above API is not successfully executed */
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Values for rate type and rate date types are not valied' ;
               pa_debug.write('validate_currency_attributes: ' || l_module_name,pa_debug.g_err_stage,1);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

         END IF;
    END IF;

    /* In the following IF conditions the set of conversion attributes to be validated are
       populated in to local variables. Depending on the parameter p_attrs_to_be_validated
       Either Cost or Revenue or Both are validatead
    */

    /* initialize any error occurred flag to N */
    l_any_error_occurred_flag := 'N';

    /* Initialize the globals to null in webadi context */
    IF p_context = PA_FP_CONSTANTS_PKG.G_WEBADI THEN
            g_first_error_code     := NULL;
            g_pc_pfc_context       := NULL;
            g_cost_rev_context     := NULL;
    END IF;

    IF(p_attrs_to_be_validated =  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST OR
       p_attrs_to_be_validated =  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH) THEN

     -- Txn curr code <> PFC
        --IF PFC needs to be validated THEN
     IF nvl(p_txn_currency_code,'-99') <> p_projfunc_currency_code THEN
                /* Validate the project functional Cost attributes*/
                VALIDATE_CONV_ATTRIBUTES( px_rate_type        => px_projfunc_cost_rate_type
                                         ,px_rate_date_type   => px_projfunc_cost_rate_date_typ
                                         ,px_rate_date        => px_projfunc_cost_rate_date
                                         ,px_rate             => px_projfunc_cost_exchange_rate
                                         ,p_amount_type_code  => l_cost_token
                                         ,p_currency_type_code=> l_projfunc_token
                                         ,p_calling_context   => p_context
                                         ,x_first_error_code  => l_first_error_code
                                         ,x_return_status     => x_return_status
                                         ,x_msg_count         => x_msg_count
                                         ,x_msg_data          => x_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'failed for PFC COST attributes' ;
                      pa_debug.write('validate_currency_attributes: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   l_any_error_occurred_flag := 'Y';

                   /* webADI looks only for the first error message */
                   --IF p_context = PA_FP_CONSTANTS_PKG.G_WEBADI and
                   IF g_first_error_code IS NULL and
                      l_first_error_code IS NOT NULL THEN

                      g_first_error_code := l_first_error_code;
                      g_pc_pfc_context     := PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_PROJFUNC;
                      g_cost_rev_context   := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST;

                      /* No further processing is required in context of webadi */
                      --RETURN;

                   END IF;
                END IF;

                l_pfc_cost_validity_code := nvl(l_first_error_code,PA_FP_CONSTANTS_PKG.G_VALID_CONV_ATTR);

        END IF;

        --IF PC needs to be validated THEN
     IF nvl(p_txn_currency_code,'-99') <> p_project_currency_code AND
            p_projfunc_currency_code <> p_project_currency_code THEN
                /* Validate the project functional Cost attributes*/
                VALIDATE_CONV_ATTRIBUTES( px_rate_type        => px_project_cost_rate_type
                                         ,px_rate_date_type   => px_project_cost_rate_date_typ
                                         ,px_rate_date        => px_project_cost_rate_date
                                         ,px_rate             => px_project_cost_exchange_rate
                                         ,p_amount_type_code  => l_cost_token
                                         ,p_currency_type_code=> l_project_token
                                         ,p_calling_context   => p_context
                                         ,x_first_error_code  => l_first_error_code
                                         ,x_return_status     => x_return_status
                                         ,x_msg_count         => x_msg_count
                                         ,x_msg_data          => x_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'failed for PC COST attributes' ;
                      pa_debug.write('validate_currency_attributes: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   l_any_error_occurred_flag := 'Y';

                   /* webADI looks only for the first error message */
                   --IF p_context = PA_FP_CONSTANTS_PKG.G_WEBADI and
                   IF g_first_error_code IS NULL and
                      l_first_error_code IS NOT NULL
                   THEN
                      g_first_error_code   := l_first_error_code;
                      g_pc_pfc_context     := PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_PROJECT;
                      g_cost_rev_context   := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST;

                      /* No further processing is required in context of webadi */
                   --   RETURN;
                   END IF;

                END IF;
                l_pc_cost_validity_code := nvl(l_first_error_code,PA_FP_CONSTANTS_PKG.G_VALID_CONV_ATTR);
        END IF;

        -- If PC = PFC copy the PFC attributes to PC.  WEBADI UT
        IF p_project_currency_code = p_projfunc_currency_code THEN
             px_project_cost_rate_type     := px_projfunc_cost_rate_type;
             px_project_cost_rate_date_typ := px_projfunc_cost_rate_date_typ;
             px_project_cost_rate_date     := px_projfunc_cost_rate_date;
             px_project_cost_exchange_rate := px_projfunc_cost_exchange_rate;
        END IF;

    END IF; -- element type cost or both.

    IF(p_attrs_to_be_validated =  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE OR
       p_attrs_to_be_validated =  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH) THEN

        --IF PFC needs to be validated THEN
     IF nvl(p_txn_currency_code,'-99') <> p_projfunc_currency_code THEN
                /* Validate the project functional Cost attributes*/
                VALIDATE_CONV_ATTRIBUTES( px_rate_type        => px_projfunc_rev_rate_type
                                         ,px_rate_date_type   => px_projfunc_rev_rate_date_typ
                                         ,px_rate_date        => px_projfunc_rev_rate_date
                                         ,px_rate             => px_projfunc_rev_exchange_rate
                                         ,p_amount_type_code  => l_rev_token
                                         ,p_currency_type_code=> l_projfunc_token
                                         ,p_calling_context   => p_context
                                         ,x_first_error_code  => l_first_error_code
                                         ,x_return_status     => x_return_status
                                         ,x_msg_count         => x_msg_count
                                         ,x_msg_data          => x_msg_data);
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'failed for PC COST attributes' ;
                      pa_debug.write('validate_currency_attributes: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   l_any_error_occurred_flag := 'Y';

                   /* webADI looks only for the first error message */
                   --IF p_context = PA_FP_CONSTANTS_PKG.G_WEBADI and
                   IF g_first_error_code IS NULL and
                      l_first_error_code IS NOT NULL
                   THEN
                      g_first_error_code := l_first_error_code;
                      g_pc_pfc_context     := PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_PROJFUNC;
                      g_cost_rev_context   := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_REVENUE;

                      /* No further processing is required in context of webadi */
                      --RETURN;
                   END IF;

                END IF;

                l_pfc_rev_validity_code := nvl(l_first_error_code,PA_FP_CONSTANTS_PKG.G_VALID_CONV_ATTR);
        END IF;

        --IF PC needs to be validated THEN
     IF nvl(p_txn_currency_code,'-99') <> p_project_currency_code AND
           p_projfunc_currency_code <> p_project_currency_code THEN
                /* Validate the project functional Cost attributes*/
                VALIDATE_CONV_ATTRIBUTES( px_rate_type        => px_project_rev_rate_type
                                         ,px_rate_date_type   => px_project_rev_rate_date_typ
                                         ,px_rate_date        => px_project_rev_rate_date
                                         ,px_rate             => px_project_rev_exchange_rate
                                         ,p_amount_type_code  => l_rev_token
                                         ,p_currency_type_code=> l_project_token
                                         ,p_calling_context   => p_context
                                         ,x_first_error_code  => l_first_error_code
                                         ,x_return_status     => x_return_status
                                         ,x_msg_count         => x_msg_count
                                         ,x_msg_data          => x_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage := 'failed for PC COST attributes' ;
                      pa_debug.write('validate_currency_attributes: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   l_any_error_occurred_flag := 'Y';

                   /* webADI looks only for the first error message */
                   --IF p_context = PA_FP_CONSTANTS_PKG.G_WEBADI and
                   IF g_first_error_code IS NULL and
                      l_first_error_code IS NOT NULL
                   THEN
                      g_first_error_code := l_first_error_code;
                      g_pc_pfc_context     := PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_PROJECT;
                      g_cost_rev_context   := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_REVENUE;

                      /* No further processing is required in context of webadi */
                      --RETURN;

                   END IF;

                END IF;
                l_pc_rev_validity_code := nvl(l_first_error_code,PA_FP_CONSTANTS_PKG.G_VALID_CONV_ATTR);
        END IF;

        -- If PC = PFC copy the PFC attributes to PC.  WEBADI UT
        IF p_project_currency_code = p_projfunc_currency_code THEN
             px_project_rev_rate_type     := px_projfunc_rev_rate_type;
             px_project_rev_rate_date_typ := px_projfunc_rev_rate_date_typ;
             px_project_rev_rate_date     := px_projfunc_rev_rate_date;
             px_project_rev_exchange_rate := px_projfunc_rev_exchange_rate;
        END IF;

    END IF;

   /*Do the Additional validations required in the case of Create / Update plan type page*/

   IF l_debug_mode='Y' THEN
      pa_debug.g_err_stage:= 'p_context is '||p_context;
      pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
   END IF;

   IF (p_context=PA_FP_CONSTANTS_PKG.G_CR_UP_PLAN_TYPE_PAGE) THEN

      /*Either all the cost attributes should be null or both project and project functional
        cost attributes should be valid
      */

      IF(l_pfc_cost_validity_code = 'PA_FP_RATE_TYPE_REQ' AND
         nvl(l_pc_cost_validity_code,'-99') <> 'PA_FP_RATE_TYPE_REQ'  ) THEN

          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name      => 'PA_FP_INVALID_RATE_TYPE',
                                p_token1        => 'COST_REV',
                                p_value1        => l_cost_token,
                                p_token2        => 'PROJECT_PROJFUNC',
                                p_value2        => l_projfunc_token );

      ELSIF(l_pc_cost_validity_code = 'PA_FP_RATE_TYPE_REQ'  AND
            nvl(l_pfc_cost_validity_code,'-99') <> 'PA_FP_RATE_TYPE_REQ') THEN

          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name      => 'PA_FP_INVALID_RATE_TYPE',
                                p_token1        => 'COST_REV',
                                p_value1        => l_cost_token,
                                p_token2        => 'PROJECT_PROJFUNC',
                                p_value2        => l_project_token );
      END IF;

      /*Either all the revenue attributes should be null or both project and project functional
        revene attributes should be valid
      */

      IF(l_pfc_rev_validity_code = 'PA_FP_RATE_TYPE_REQ' AND
         nvl(l_pc_rev_validity_code,'-99') <> 'PA_FP_RATE_TYPE_REQ'  ) THEN

          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name      => 'PA_FP_INVALID_RATE_TYPE',
                                p_token1        => 'COST_REV',
                                p_value1        => l_rev_token,
                                p_token2        => 'PROJECT_PROJFUNC',
                                p_value2        => l_projfunc_token );

      ELSIF(l_pc_rev_validity_code = 'PA_FP_RATE_TYPE_REQ' AND
            nvl(l_pfc_rev_validity_code,'-99') <> 'PA_FP_RATE_TYPE_REQ' ) THEN

          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name      => 'PA_FP_INVALID_RATE_TYPE',
                                p_token1        => 'COST_REV',
                                p_value1        => l_rev_token,
                                p_token2        => 'PROJECT_PROJFUNC',
                                p_value2        => l_project_token );

      END IF;

   END IF;

   IF l_any_error_occurred_flag = 'Y' THEN
      IF l_debug_mode='Y' THEN
          pa_debug.g_err_stage:= 'some of the conversion attributes failed.. Returning error';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   IF l_debug_mode='Y' THEN
       pa_debug.g_err_stage:= 'Exiting validate_currency_attributes';
       pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

   pa_debug.reset_err_stack;
END IF;
EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);

             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.reset_err_stack;
  END IF;
      RETURN;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg
         ( p_pkg_name       => 'PA_FIN_PLAN_UTILS'
          ,p_procedure_name => 'VALIDATE_CURRENCY_ATTRIBUTES'
          ,p_error_text     => sqlerrm);

        pa_debug.G_Err_Stack := SQLERRM;
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('CHECK_MRC_INSTALL: ' || l_module_name,pa_debug.G_Err_Stack,4);
        pa_debug.reset_err_stack;
	END IF;
        RAISE;

END  VALIDATE_CURRENCY_ATTRIBUTES;

/*==================================================================
   This api retrieves the plan type id and the option for it given
   the plan version id. This API is included for the bug 2728552.
 ==================================================================*/

PROCEDURE GET_PLAN_TYPE_OPTS_FOR_VER
   (
         p_plan_version_id        IN     pa_proj_fp_options.fin_plan_version_id%TYPE
        ,x_fin_plan_type_id      OUT  NOCOPY pa_proj_fp_options.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
        ,x_plan_type_option_id   OUT  NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE --File.Sql.39 bug 4440895
           ,x_version_type          OUT  NOCOPY pa_budget_versions.version_type%TYPE --File.Sql.39 bug 4440895
           ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

   )
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

cursor plan_type_cur(c_version_id pa_proj_fp_options.fin_plan_version_id%TYPE) is
        select o.fin_plan_type_id,o.proj_fp_options_id,v.version_type
        from pa_proj_fp_options o,pa_budget_versions v
        where o.fin_plan_type_id = v.fin_plan_type_id
        and   o.project_id       = v.project_id
        and   v.budget_version_id = c_version_id
        and   o.fin_plan_option_level_code = 'PLAN_TYPE';

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
      IF l_debug_mode = 'Y' THEN
              pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.GET_PLAN_TYPE_OPTS_FOR_VER');
              pa_debug.set_process('PLSQL','LOG',l_debug_mode);
      END IF;

      -- Check for business rules violations
      IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Entering PA_FIN_PLAN_UTILS.GET_PLAN_TYPE_OPTS_FOR_VER';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                         PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Validating input parameters';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                         PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      IF (p_plan_version_id IS NULL) THEN
              IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'plan version id is null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              END IF;
              PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                        p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      open plan_type_cur(p_plan_version_id);
      fetch plan_type_cur
      into x_fin_plan_type_id,x_plan_type_option_id,x_version_type;

      IF plan_type_cur%NOTFOUND THEN
              IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Plan type record not found';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              END IF;
           CLOSE plan_type_cur;
           RAISE NO_DATA_FOUND;
      END IF;

      CLOSE plan_type_cur;

      IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'Plan type id->'||x_fin_plan_type_id;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
          pa_debug.g_err_stage:= 'Plan type option id->'||x_plan_type_option_id;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Exiting GET_PLAN_TYPE_OPTS_FOR_VER';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                         PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
              pa_debug.reset_err_stack;

      END IF;

 EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           x_return_status := FND_API.G_RET_STS_ERROR;
           l_msg_count := FND_MSG_PUB.count_msg;

           IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
           IF l_debug_mode = 'Y' THEN
                   pa_debug.reset_err_stack;
           END IF;
           RETURN;

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                           ,p_procedure_name  => 'GET_PLAN_TYPE_OPTS_FOR_VER'
                           ,p_error_text      => x_msg_data);

          IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
              pa_debug.write(L_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              pa_debug.reset_err_stack;

          END IF;
          RAISE;

END GET_PLAN_TYPE_OPTS_FOR_VER;

/*============================================================================
  This api is used to return the project and projfunc currency codes and the
  cost and bill rate types defined for them.
  If they aren't available at pa_projects_all table, we fetch them from the
  implementations table. If they are not avaialable, null would be returned.
 =============================================================================*/

PROCEDURE Get_Project_Curr_Attributes
   (  p_project_id                      IN   pa_projects_all.project_id%TYPE
     ,x_multi_currency_billing_flag     OUT  NOCOPY pa_projects_all.multi_currency_billing_flag%TYPE --File.Sql.39 bug 4440895
     ,x_project_currency_code           OUT  NOCOPY pa_projects_all.project_currency_code%TYPE --File.Sql.39 bug 4440895
     ,x_projfunc_currency_code          OUT  NOCOPY pa_projects_all.projfunc_currency_code%TYPE --File.Sql.39 bug 4440895
     ,x_project_cost_rate_type          OUT  NOCOPY pa_projects_all.project_rate_type%TYPE --File.Sql.39 bug 4440895
     ,x_projfunc_cost_rate_type         OUT  NOCOPY pa_projects_all.projfunc_cost_rate_type%TYPE --File.Sql.39 bug 4440895
     ,x_project_bil_rate_type           OUT  NOCOPY pa_projects_all.project_bil_rate_type%TYPE --File.Sql.39 bug 4440895
     ,x_projfunc_bil_rate_type          OUT  NOCOPY pa_projects_all.projfunc_bil_rate_type%TYPE --File.Sql.39 bug 4440895
     ,x_return_status                   OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                       OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                        OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;

BEGIN
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
IF P_PA_DEBUG_MODE = 'Y' THEN
      PA_DEBUG.Set_Curr_Function( p_function   => 'Get_Project_Curr_Attributes',
                                  p_debug_mode => p_pa_debug_mode );
END IF;
      -- Check for NOT NULL parameters
      IF (p_project_id IS NULL)
      THEN
            IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'Invalid Arguments Passed';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            END IF;
            PA_UTILS.ADD_MESSAGE
                   (p_app_short_name => 'PA',
                    p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- Fetch the cost rate types for project currency and projfunc currency

      IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Fetching cost rate types for project = '||p_project_id;
              pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      SELECT  p.multi_currency_billing_flag
             ,p.project_currency_code
             ,p.projfunc_currency_code
             ,NVL(p.project_rate_type,i.default_rate_type)       project_cost_rate_type
             ,NVL(p.projfunc_cost_rate_type,i.default_rate_type) projfunc_cost_rate_type
             ,p.project_bil_rate_type
             ,p.projfunc_bil_rate_type
      INTO    x_multi_currency_billing_flag
             ,x_project_currency_code
             ,x_projfunc_currency_code
             ,x_project_cost_rate_type
             ,x_projfunc_cost_rate_type
             ,x_project_bil_rate_type
             ,x_projfunc_bil_rate_type
      FROM   pa_projects_all p
             ,pa_implementations_all i
      WHERE  p.project_id = p_project_id
      --AND    NVL(p.org_id,-99) = NVL(i.org_id,-99);
	 AND    p.org_id = i.org_id; /* Bug 3174677: Added the NVL ,Refer to Update
                                                       "16-JAN-04 sagarwal" in the history above.
											This has been added as part of code merge */

      IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Exiting Get_Project_Curr_Attributes';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      pa_debug.reset_curr_function;
	END IF;
  EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           x_return_status := FND_API.G_RET_STS_ERROR;
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
 IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.reset_curr_function;
END IF;
           RAISE;
   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                           ,p_procedure_name  => 'Get_Project_Curr_Attributes'
                           ,p_error_text      => SQLERRM);
          IF p_pa_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          pa_debug.reset_curr_function;
	END IF;
          RAISE;
END Get_Project_Curr_Attributes;

PROCEDURE IsRevVersionCreationAllowed
    ( p_project_id                      IN   pa_projects_all.project_id%TYPE
     ,p_fin_plan_type_id                IN   pa_fin_plan_types_b.fin_plan_type_id%TYPE
     ,x_creation_allowed                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_return_status                   OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                       OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                        OUT  NOCOPY VARCHAR2) AS --File.Sql.39 bug 4440895

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                  VARCHAR2(1);

/* Changes for FP.M, Tracking Bug No - 3354518
   Added use_for_workplan_flag column from pa_proj_fp_options
   in the select statment below
   Please note that this API will not be called for Workplan Usage*/

cursor autobaseline_appr_rev_info_cur is
SELECT nvl(pr.baseline_funding_flag,'N') baseline_funding_flag, pfo.approved_rev_plan_type_flag,
       pft.use_for_workplan_flag -- Added for FP.M ,Tracking Bug No - 3354518
FROM   pa_projects_all pr, pa_proj_fp_options pfo,
       pa_fin_plan_types_b pft -- Added for FP.M ,Tracking Bug No - 3354518
WHERE  pr.project_id = pfo.project_id
AND    pfo.fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE
AND    pfo.fin_plan_type_id = p_fin_plan_type_id
AND    pfo.project_id = p_project_id
AND    pft.fin_plan_type_id = p_fin_plan_type_id; -- Added for FP.M ,Tracking Bug No - 3354518

cur_rec autobaseline_appr_rev_info_cur%ROWTYPE;

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_Debug.set_curr_function( p_function   => 'IsRevVersionCreationAllowed',
                                  p_debug_mode => l_debug_mode );
END IF;
      -- Check for business rules violations

      IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Validating input parameters';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                         PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      IF (p_project_id IS NULL) OR (p_fin_plan_type_id IS NULL)
      THEN
              IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        pa_debug.g_err_stage:= 'p_fin_plan_type_id = '|| p_fin_plan_type_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              END IF;
              PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                       p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      x_creation_allowed := 'Y';

      open autobaseline_appr_rev_info_cur;
      fetch autobaseline_appr_rev_info_cur into cur_rec;
      IF autobaseline_appr_rev_info_cur%NOTFOUND THEN
              RAISE NO_DATA_FOUND;
      END IF;

/* Changes for FP.M, Tracking Bug No - 3354518
   Added check use_for_workplan_flag column below in the
   since we cannot create revenue version for a workplan type
      Please note that this API will not be called for Workplan Usage*/

      IF (cur_rec.baseline_funding_flag = 'Y' and cur_rec.approved_rev_plan_type_flag = 'Y') or (cur_rec.use_for_workplan_flag = 'Y') THEN
           x_creation_allowed := 'N';
      END IF;

      IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Exiting IsRevVersionCreationAllowed';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                         PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      pa_debug.reset_curr_function;
	END IF;
 EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF autobaseline_appr_rev_info_cur%ISOPEN THEN
            CLOSE autobaseline_appr_rev_info_cur;
        END IF;

        IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
 IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.reset_curr_function;
END IF;
        RETURN;

   WHEN others THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        IF autobaseline_appr_rev_info_cur%ISOPEN THEN
            CLOSE autobaseline_appr_rev_info_cur;
        END IF;

        FND_MSG_PUB.add_exc_msg
                        ( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                         ,p_procedure_name  => 'IsRevVersionCreationAllowed'
                         ,p_error_text      => x_msg_data);

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                   PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        pa_debug.reset_curr_function;
	END IF;
        RAISE;

END IsRevVersionCreationAllowed;


/*==================================================================
   This api takes the lookup type and lookup meaning as the input and
   returns the lookup code.
 ==================================================================*/

PROCEDURE GET_LOOKUP_CODE
          (
                 p_lookup_type                      IN   pa_lookups.lookup_type%TYPE
                ,p_lookup_meaning                   IN   pa_lookups.meaning%TYPE
                ,x_lookup_code                      OUT  NOCOPY pa_lookups.lookup_code%TYPE --File.Sql.39 bug 4440895
                ,x_return_status                    OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                ,x_msg_count                        OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                ,x_msg_data                         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          )
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

cursor lookups_cur is
select lookup_code
from   pa_lookups
where  lookup_type = p_lookup_type
and    meaning     = p_lookup_meaning;

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_curr_function( p_function   => 'GET_LOOKUP_CODE',
                                  p_debug_mode => l_debug_mode );
END IF;
      -- Check for business rules violations

      IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Validating input parameters';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                         PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      IF (p_lookup_type IS NULL) OR
         (p_lookup_meaning IS NULL)
      THEN
              IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'p_lookup_type = '|| p_lookup_type;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        pa_debug.g_err_stage:= 'p_lookup_meaning = '|| p_lookup_meaning;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                 PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              END IF;
              PA_UTILS.ADD_MESSAGE
                      (p_app_short_name => 'PA',
                        p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      open lookups_cur;
      fetch lookups_cur
      into x_lookup_code;

      IF lookups_cur%NOTFOUND THEN
              IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'could not obtain lookup code';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                        PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              END IF;
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      close lookups_cur;

      IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Exiting GET_LOOKUP_CODE';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                         PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      pa_debug.reset_curr_function;
	END IF;
 EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF lookups_cur%ISOPEN THEN
                close lookups_cur;
        END IF;

        IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
 IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.reset_curr_function;
END IF;
        RETURN;

   WHEN others THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        IF lookups_cur%ISOPEN THEN
                close lookups_cur;
        END IF;

        FND_MSG_PUB.add_exc_msg
                        ( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                         ,p_procedure_name  => 'GET_LOOKUP_CODE'
                         ,p_error_text      => x_msg_data);

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                   PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        pa_debug.reset_curr_function;
	END IF;
        RAISE;

END GET_LOOKUP_CODE;

FUNCTION HAS_PLANNABLE_ELEMENTS
         (p_budget_version_id IN   pa_budget_versions.budget_version_id%TYPE)
RETURN VARCHAR2 is

cursor cur_check_elements is
SELECT 'Y'
FROM   dual
WHERE  EXISTS (SELECT 'x'
               FROM   pa_resource_assignments
               WHERE  budget_version_id = p_budget_version_id);

l_exists varchar2(1) := 'N';

BEGIN

    OPEN cur_check_elements;
    FETCH cur_check_elements INTO l_exists;
    RETURN l_exists;
    IF cur_check_elements%ISOPEN THEN
        close cur_check_elements;
    END IF;

END HAS_PLANNABLE_ELEMENTS;

--Given the project id and fin plan type id this procedure
--derives the version type if it is not passed
--Vesion type should be passed when the preference code of the plan type is
--COST_AND_REV_SEP, else an error will be thrown
PROCEDURE get_version_type
( p_project_id               IN     pa_projects_all.project_id%TYPE
 ,p_fin_plan_type_id         IN     pa_proj_fp_options.fin_plan_type_id%TYPE
 ,px_version_type            IN OUT NOCOPY pa_budget_Versions.version_type%TYPE --File.Sql.39 bug 4440895
 ,x_return_status            OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                 OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )IS

      CURSOR  l_proj_fp_options_csr
      IS
      SELECT fin_plan_preference_code
      FROM   pa_proj_fp_options
      WHERE  project_id=p_project_id
      AND    fin_plan_type_id=p_fin_plan_type_id
      AND    fin_plan_option_level_code= PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;

      l_proj_fp_options_rec           l_proj_fp_options_csr%ROWTYPE;

      l_msg_count                     NUMBER := 0;
      l_data                          VARCHAR2(2000);
      l_msg_data                      VARCHAR2(2000);
      l_msg_index_out                 NUMBER;
      l_debug_mode                    VARCHAR2(1);

      l_debug_level2         CONSTANT NUMBER := 2;
      l_debug_level3         CONSTANT NUMBER := 3;
      l_debug_level4         CONSTANT NUMBER := 4;
      l_debug_level5         CONSTANT NUMBER := 5;
      l_fin_plan_type_name            pa_fin_plan_types_tl.name%TYPE;
      l_segment1                      pa_projects_all.segment1%TYPE;

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_curr_function( p_function   => 'get_version_type',
                                 p_debug_mode  => l_debug_mode );
END IF;

      BEGIN --Added for bug 4224464
      -- Get the name of the plan type
      SELECT name
      INTO   l_fin_plan_type_name
      FROM   pa_fin_plan_types_vl
      WHERE  fin_plan_type_id = p_fin_plan_type_id;

      EXCEPTION
	WHEN NO_DATA_FOUND THEN   -- bug 3454650

       PA_UTILS.ADD_MESSAGE
          (p_app_short_name => 'PA',
           p_msg_name       => 'PA_FP_INVALID_PLAN_TYPE',
           p_token1         => 'PROJECT_ID',
           p_value1         =>  p_project_id,
           p_token2         => 'PLAN_TYPE_ID',
           p_value2         =>  p_fin_plan_type_id,
           p_token3         => 'VERSION_TYPE',
           p_value3         =>  px_version_type);

       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END;

      -- Get the segment1 of the project
      SELECT segment1
      INTO   l_segment1
      FROM   pa_projects_all
      WHERE  project_id = p_project_id ;

      OPEN  l_proj_fp_options_csr;
      FETCH l_proj_fp_options_csr
      INTO  l_proj_fp_options_rec;

      IF l_proj_fp_options_csr%NOTFOUND THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                  pa_debug.g_err_stage:= 'p_fin_plan_type_id = '|| p_fin_plan_type_id;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            END IF;

            PA_UTILS.ADD_MESSAGE
                   (p_app_short_name => 'PA',
                    p_msg_name       => 'PA_FP_NO_PLAN_TYPE_OPTION',
                    p_token1         => 'PROJECT',
                    p_value1         =>  l_segment1,
                    p_token2         => 'PLAN_TYPE',
                    p_value2         =>  l_fin_plan_type_name);


            CLOSE l_proj_fp_options_csr;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;
      CLOSE l_proj_fp_options_csr;

      IF (l_proj_fp_options_rec.fin_plan_preference_code
                                                       =PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY) THEN

            IF ( px_version_type IS NULL ) THEN

                  px_version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST ;

            ELSIF(px_version_type <> PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST) THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Version type passed is '||px_version_type ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_INVALID_VERSION_TYPE',
                      p_token1         => 'PROJECT',
                      p_value1         =>  l_segment1,
                      p_token2         => 'PLAN_TYPE',
                      p_value2         =>  l_fin_plan_type_name,
                      p_token3         => 'VERSION_TYPE',
                      p_value3         =>  px_version_type);

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

      ELSIF (l_proj_fp_options_rec.fin_plan_preference_code
                                         =PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY) THEN

            IF ( px_version_type IS NULL) THEN

                  px_version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE ;

            ELSIF(px_version_type <> PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE) THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Version type passed is '||px_version_type ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_INVALID_VERSION_TYPE',
                      p_token1         => 'PROJECT',
                      p_value1         =>  l_segment1,
                      p_token2         => 'PLAN_TYPE',
                      p_value2         =>  l_fin_plan_type_name,
                      p_token3         => 'VERSION_TYPE',
                      p_value3         =>  px_version_type);
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

      ELSIF (l_proj_fp_options_rec.fin_plan_preference_code
                                   =PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME) THEN

            IF ( px_version_type IS NULL ) THEN

                  px_version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL ;

            ELSIF(px_version_type <> PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL) THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Version type passed is '||px_version_type ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                  END IF;

                  PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_INVALID_VERSION_TYPE',
                      p_token1         => 'PROJECT',
                      p_value1         =>  l_segment1,
                      p_token2         => 'PLAN_TYPE',
                      p_value2         =>  l_fin_plan_type_name,
                      p_token3         => 'VERSION_TYPE',
                      p_value3         =>  px_version_type);

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

      ELSIF (l_proj_fp_options_rec.fin_plan_preference_code
                                 =PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) THEN

            IF( px_version_type IS NULL) THEN

                  IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage := 'Version type passed is null' ;
                         pa_debug.write( l_module_name,pa_debug.g_err_stage, l_debug_level3);
                  END IF;

                  PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_VERSION_NULL_AT_CRS_PT',
                      p_token1         => 'PROJECT',
                      p_value1         =>  l_segment1,
                      p_token2         => 'PLAN_TYPE',
                      p_value2         =>  l_fin_plan_type_name);
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            ELSIF( px_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST
                  OR px_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE) THEN

                      px_version_type:= px_version_type ;
            ELSE-- version type is neither COST nor REVENUE

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Version type passed is '||px_version_type ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_INVALID_VERSION_TYPE',
                      p_token1         => 'PROJECT',
                      p_value1         =>  l_segment1,
                      p_token2         => 'PLAN_TYPE',
                      p_value2         =>  l_fin_plan_type_name,
                      p_token3         => 'VERSION_TYPE',
                      p_value3         =>  px_version_type);

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

      END IF;--Version type derivation ends

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Leaving get version type';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                              l_debug_level3);

      pa_debug.reset_curr_function;
	END IF;
EXCEPTION

WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

      IF x_return_status IS NULL OR
         x_return_status = FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.reset_curr_function;
END IF;
      RETURN;

WHEN others THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

      FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'pa_fin_plan_utils'
                    ,p_procedure_name  => 'get_Version_type'
                    ,p_error_text      => x_msg_data);

      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
      pa_debug.reset_curr_function;
      END IF;
      RAISE;
END get_version_type;


-- This procedure returns the budget version id
-- given the project id ,plan type id, version type and version number
-- If found returns valid budget version id
-- Null is returned other wise
PROCEDURE get_version_id
( p_project_id               IN   pa_projects_all.project_id%TYPE
 ,p_fin_plan_type_id         IN   pa_proj_fp_options.fin_plan_type_id%TYPE
 ,p_version_type             IN   pa_budget_Versions.version_type%TYPE
 ,p_version_number           IN   pa_budget_Versions.version_number%TYPE
 ,x_budget_version_id        OUT  NOCOPY pa_budget_Versions.budget_version_id%TYPE --File.Sql.39 bug 4440895
 ,x_ci_id                    OUT  NOCOPY pa_budget_Versions.ci_id%TYPE --File.Sql.39 bug 4440895
 ,x_return_status            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                 OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )IS

      l_msg_count                     NUMBER := 0;
      l_data                          VARCHAR2(2000);
      l_msg_data                      VARCHAR2(2000);
      l_msg_index_out                 NUMBER;
      l_debug_mode                    VARCHAR2(1);

      l_debug_level3                  CONSTANT NUMBER := 3;
      l_debug_level5                  CONSTANT NUMBER := 5;
      l_module                        VARCHAR2(100) := l_module_name || 'get_version_id';

      CURSOR l_budget_version_id_csr
      IS
      SELECT budget_version_id,
             ci_id
      FROM   pa_budget_versions
      WHERE  project_id=p_project_id
      AND    fin_plan_type_id=p_fin_plan_type_id
      AND    version_type=p_version_type
      AND    version_number=p_version_number
      AND    budget_status_code='W';

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_curr_function( p_function   => 'get_version_id',p_debug_mode => l_debug_mode );
END IF;
      -- Check for business rules violations

      IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(l_module,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      IF (p_project_id        IS NULL OR
          p_fin_plan_type_id  IS NULL OR
          p_version_type      IS NULL OR
          p_version_number    IS NULL ) THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Project Id is ' || p_project_id;
                  pa_debug.write(l_module,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_fin_plan_type_id is '||p_fin_plan_type_id;
                  pa_debug.write(l_module,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_version_type is '||p_version_type;
                  pa_debug.write(l_module,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_version_number is ' ||p_version_number;
                  pa_debug.write(l_module,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                   p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      OPEN  l_budget_version_id_csr ;
      FETCH l_budget_version_id_csr INTO x_budget_version_id,x_ci_id;
      CLOSE l_budget_version_id_csr;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Exiting get_version_id';
            pa_debug.write(l_module,pa_debug.g_err_stage,l_debug_level3);
            pa_debug.reset_curr_function;
      END IF;

EXCEPTION
WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
 IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.reset_curr_function;
END IF;
     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                    ,p_procedure_name  => 'get_version_id'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module,pa_debug.g_err_stage,l_debug_level5);
     pa_debug.reset_curr_function;
     END IF;
     RAISE;
END get_version_id;

-- This procedure accepts budget version id and checks the follwing
-- 1.is the project enabled for auto baselining
-- 2. is the version approved for revenue and is the version type revenue
-- If both 1 and 2 are met it returns F for the parameter x_result
-- T is returned otherise

PROCEDURE perform_autobasline_checks
( p_budget_version_id     IN  pa_budget_versions.budget_version_id%TYPE
 ,x_result                OUT NOCOPY VARCHAR2     --File.Sql.39 bug 4440895
 ,x_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
      l_msg_count                     NUMBER := 0;
      l_data                          VARCHAR2(2000);
      l_msg_data                      VARCHAR2(2000);
      l_msg_index_out                 NUMBER;
      l_debug_mode                    VARCHAR2(1);

      l_debug_level3                  CONSTANT NUMBER := 3;
      l_debug_level5                  CONSTANT NUMBER := 5;
      l_module                        VARCHAR2(100) := l_module_name || 'get_version_id';

      CURSOR l_autobaseline_check_csr
      IS
      SELECT  pbv.budget_type_code
             ,pbv.fin_plan_type_id
             ,pbv.version_type
             ,pfo.approved_rev_plan_type_flag
             ,p.baseline_funding_flag
      FROM    pa_budget_versions pbv
             ,pa_proj_fp_options pfo
             ,pa_projects_all p
      WHERE   pbv.budget_version_id=p_budget_version_id
      AND     pfo.fin_plan_version_id(+)=pbv.budget_version_id
      AND     p.project_id=pbv.project_id;

      l_autobaseline_check_rec        l_autobaseline_check_csr%ROWTYPE;
BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_result:='T';
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');


IF l_debug_mode = 'Y' THEN
      pa_debug.set_curr_function( p_function   => 'perform_autobasline_checks',p_debug_mode => l_debug_mode );
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(l_module,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      IF (p_budget_version_id  IS NULL ) THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_budget_version_id is ' ||p_budget_version_id;
                  pa_debug.write(l_module,pa_debug.g_err_stage,l_debug_level3);
            END IF;

            PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                   p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      OPEN  l_autobaseline_check_csr;
      FETCH l_autobaseline_check_csr INTO l_autobaseline_check_rec;
      IF (l_autobaseline_check_csr%NOTFOUND) THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_budget_version_id is ' || p_budget_version_id;
                  pa_debug.write(l_module,pa_debug.g_err_stage,l_debug_level3);
            END IF;
            CLOSE l_autobaseline_check_csr;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;
      CLOSE l_autobaseline_check_csr;

      IF (l_autobaseline_check_rec.baseline_funding_flag='Y')  THEN
            IF nvl( l_autobaseline_check_rec.budget_type_code,'N')=
                               PA_FP_CONSTANTS_PKG.G_BUDGET_TYPE_CODE_AR   THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Auto base line error in budget model' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  x_result := 'F';

            ELSIF  (l_autobaseline_check_rec.budget_type_code IS NULL AND
                    l_autobaseline_check_rec.approved_rev_plan_type_flag = 'Y' AND
                    l_autobaseline_check_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE) THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Auto base line error in finplan model' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  END IF;

                  x_result := 'F';

            END IF;

      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Exiting perform_autobasline_checks ';
            pa_debug.write(l_module,pa_debug.g_err_stage,l_debug_level3);
      pa_debug.reset_curr_function;
      END IF;
EXCEPTION
WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
 IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.reset_curr_function;
END IF;
     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                    ,p_procedure_name  => 'perform_autobasline_checks'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module,pa_debug.g_err_stage,l_debug_level5);
     pa_debug.reset_curr_function;
	END IF;
     RAISE;
END perform_autobasline_checks;

/*==================================================================
   This api derives verion type for a given budget type code.
   If the budget amount code is 'c' , it returns 'COST'
   If the budget amount code is 'R' , it returns 'REVENUE'
   If the budget amount code is 'ALL' , it returns 'ALL'
 ==================================================================*/

PROCEDURE get_version_type_for_bdgt_type
   (  p_budget_type_code      IN   pa_budget_versions.budget_type_code%TYPE
     ,x_version_type          OUT  NOCOPY pa_budget_versions.version_type%TYPE --File.Sql.39 bug 4440895
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);

BEGIN
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
IF p_pa_debug_mode = 'Y' THEN
      PA_DEBUG.Set_Curr_Function( p_function   => 'Get_version_type_for_bdgt_type',
                                  p_debug_mode => p_pa_debug_mode );
END IF;
      -- Check for NOT NULL parameters
      IF (p_budget_type_code IS NULL)
      THEN
            IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'p_budget_type_code = '|| p_budget_type_code;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            END IF;
            PA_UTILS.ADD_MESSAGE
                   (p_app_short_name => 'PA',
                    p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- derive version type using the budget amount code

      BEGIN
           SELECT DECODE(budget_amount_code, 'C',   PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_COST,
                                             'R',   PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_REVENUE,
                                             'ALL', PA_FP_CONSTANTS_PKG.G_VERSION_TYPE_ALL)
           INTO   x_version_type
           FROM   pa_budget_types
           WHERE  budget_type_code = p_budget_type_code;
      EXCEPTION
           WHEN NO_DATA_FOUND THEN
                IF p_pa_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'no data found error in get_version_type_for_bdgt_type'||SQLERRM;
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                END IF;

                PA_UTILS.ADD_MESSAGE(
                       p_app_short_name  => 'PA'
                      ,p_msg_name        => 'PA_BUDGET_TYPE_IS_INVALID' );

                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END;

      IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Exiting get_version_type_for_bdgt_type';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      pa_debug.reset_curr_function;
	END IF;
  EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           x_return_status := FND_API.G_RET_STS_ERROR;
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
	 IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.reset_curr_function;
	END IF;
           RETURN;
   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                           ,p_procedure_name  => 'get_version_type_for_bdgt_type'
                           ,p_error_text      => sqlerrm);
          IF p_pa_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'unexp error in get_version_type_for_bdgt_type'||SQLERRM;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          pa_debug.reset_curr_function;
	END IF;
          RAISE;
END get_version_type_for_bdgt_type;

--
--    03-JUN-03 jwhite   Bug 2955756 (Merged from branch 85, Post-K Rollup QA)
--                       For the validate_editable_bv procedure,  there appeared
--                       to be three issues:
--
--                       1) For one OA session, when the user submits a plan, the
--                          message stack count is incremented by one.
--
--                          Therefore, removed logic assuming one one message in
--                          stack.
--
--                       2) When user encounters properly rendered submit error from
--                          this api and then changes the plan back to working
--                          and then logs out and logs back in as a different
--                          user to test second user-locked error in this api, the previous
--                          submit error improperly reappears.
--
--                          FND_MSG_PUB.initialize seemed to address this issue.
--
--                       3) Sometimes, but not always, passing G_TRUE for the
--                          non-encoded (no-token) submit message appeared to
--                          result in a "null" being rendered on the attachments
--                          page.
--
--                          For the submit error, pass p_encoded as G_FALSE.
--
--
--     22-JUL-03 jwhite   Bug 3057564
--                        For the validate_editable_bv procedure,
--                        add new logic and message code for plan
--                        version locked by a process.

--     03-Nov-03 dbora    Bug 3986129: FP.M Web ADI Dev changes made to call this
--                        for Web ADI related validations as well.
--                        new parameter p_context is added with default value of
--                        'ATTACHEMENT'. Other valid value is 'WEBADI'.
--
/*  PROCEDURE validate_editable_bv
 *  This procedure tests whether a budget version is editable.  It is editable if all
 *  of the following are true:
 *  1. The budget version is not in a Submitted status
 *  2. The budget version is unlocked, or locked by the logged-in user
 *  If a budget version is NOT editable, the an error message will be added to the stack:
 *  PA_FP_ATTACH_SUBMITTED - if version is in a Submitted status
 *  PA_FP_ATTACH_LOCKED_BY_USER - if version is locked by another user
 *
 *  USED BY:
 *  - Attachments for Financial Planning (Post-K one-off)
 *  - pa_fp_webadi_pkg.validate_header_info (FP.M)
 */
PROCEDURE validate_editable_bv
    (p_budget_version_id     IN  pa_budget_versions.budget_version_id%TYPE,
     p_user_id               IN  NUMBER,

     --Bug 3986129: FP.M Web ADI Dev changes, a new parameter added
     p_context               IN  VARCHAR2,
     p_excel_calling_mode    IN  VARCHAR2,
     x_locked_by_person_id   OUT NOCOPY pa_budget_versions.locked_by_person_id%TYPE, --File.Sql.39 bug 4440895
     x_err_code              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count             OUT NOCOPY NUMBER,   --File.Sql.39 bug 4440895
     x_msg_data              OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

l_person_id                   NUMBER(15);
l_resource_id                 NUMBER(15);
l_resource_name               VARCHAR2(240);

l_budget_status_code          pa_budget_versions.budget_status_code%TYPE;
l_locked_by_person_id         pa_budget_versions.locked_by_person_id%TYPE;
l_locked_by_name              VARCHAR2(240);

-- error-handling variables
l_msg_count               NUMBER(15);
l_msg_data                VARCHAR2(2000);
l_data                    VARCHAR2(2000);
l_msg_index_out           NUMBER(15);

   -- Bug 3057564, jwhite, 22-JUL-03 -----------------------------
   l_request_id                pa_budget_versions.request_id%TYPE;

-- Bug 3986129: FP.M Web ADI Dev. Added the followings
l_edit_after_baseline_flag        pa_fin_plan_types_b.edit_after_baseline_flag%TYPE;
l_project_id                      pa_projects_all.project_id%TYPE;
l_fin_plan_type_id                pa_fin_plan_types_b.fin_plan_type_id%TYPE;
l_version_type                    pa_budget_versions.version_type%TYPE;
is_edit_allowed                   VARCHAR2(1) := 'Y';

l_debug_mode                 VARCHAR2(1);
l_debug_level3               CONSTANT NUMBER := 3;
l_module_name                VARCHAR2(100) := 'validate_editable_bv' ;
l_plan_processing_code       pa_budget_versions.plan_processing_code%TYPE;

BEGIN

  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

  FND_MSG_PUB.initialize;

  IF l_debug_mode = 'Y' THEN
       pa_debug.Set_Curr_Function
             ( p_function    => l_module_name,
               p_debug_mode  => l_debug_mode);
  END IF;
  IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Entering validate_editable_bv';
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
       pa_debug.g_err_stage:='p_context passed: ' || p_context;
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- get the person_id: used for locking checks
  PA_COMP_PROFILE_PUB.GET_USER_INFO
          (p_user_id         => p_user_id,
           x_person_id       => l_person_id,
           x_resource_id     => l_resource_id,
           x_resource_name   => l_resource_name);

    SELECT budget_status_code,
           locked_by_person_id,
           request_id,           -- Bug 3057564
           plan_processing_code
    INTO   l_budget_status_code,
           x_locked_by_person_id,
           l_request_id,         -- Bug 3057564
           l_plan_processing_code
    FROM   pa_budget_versions
    WHERE  budget_version_id = p_budget_version_id;

  if l_budget_status_code = 'S' then
        if p_context <> 'WEBADI' then
             IF p_context <> PA_FP_CONSTANTS_PKG.G_AMG_API THEN

                 x_err_code := 'PA_FP_ATTACH_SUBMITTED';

                 PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                      p_msg_name            => 'PA_FP_ATTACH_SUBMITTED');

                 l_msg_count := FND_MSG_PUB.Count_Msg;

                  -- bug 2955756 --------------------------------------

                  PA_INTERFACE_UTILS_PUB.get_messages
                       (p_encoded        => FND_API.G_FALSE
                        ,p_msg_index      => 1
                        ,p_msg_count      => l_msg_count
                        ,p_msg_data       => l_msg_data
                        ,p_data           => l_data
                        ,p_msg_index_out  => l_msg_index_out);

                  x_msg_data := l_data;
                  x_msg_count := l_msg_count;

                  -- ---------------------------------------------------


                 /*
                  if l_msg_count = 1 then
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
                */

                /*
                   if x_msg_count = 1 then
                      PA_INTERFACE_UTILS_PUB.get_messages
                             (p_encoded        => FND_API.G_TRUE,
                              p_msg_index      => 1,
                              p_data           => x_msg_data,
                              p_msg_index_out  => l_msg_index_out);
                   end if;
                */
                RAISE PA_FP_CONSTANTS_PKG.Just_Ret_Exc;
            ELSE
                -- AMG context
                x_err_code := 'PA_FP_SUBMITTED_VERSION';

                 PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                      p_msg_name            => 'PA_FP_SUBMITTED_VERSION');

                 l_msg_count := FND_MSG_PUB.Count_Msg;

                  PA_INTERFACE_UTILS_PUB.get_messages
                       (p_encoded        => FND_API.G_FALSE
                        ,p_msg_index      => 1
                        ,p_msg_count      => l_msg_count
                        ,p_msg_data       => l_msg_data
                        ,p_data           => l_data
                        ,p_msg_index_out  => l_msg_index_out);

                  x_msg_data := l_data;
                  x_msg_count := l_msg_count;

                  RAISE PA_FP_CONSTANTS_PKG.Just_Ret_Exc;
            END IF;
       ELSE -- p_context = 'WEBADI'
              IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Web ADI: Submitted Error';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                   pa_debug.g_err_stage:='Populating Error Flag - Code';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
              END IF;

              x_err_code := 'PA_FP_WA_BV_SUBMITTED_ERR';

              RAISE PA_FP_CONSTANTS_PKG.Just_Ret_Exc;
       end if; -- p_context
  end if; -- version submitted

   -- Bug 3057564, jwhite, 22-JUL-03 -----------------------------
   -- Add logic for plan version locked by a process

   IF ( ( nvl( x_locked_by_person_id,0) = -98 )
       AND ( l_request_id is NOT NULL )    ) THEN
        IF p_context <> PA_FP_CONSTANTS_PKG.G_AMG_API THEN
            x_err_code := 'PA_FP_ATTACH_LOCKED_BY_PRC';

            PA_UTILS.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name       => 'PA_FP_ATTACH_LOCKED_BY_PRC');

            l_msg_count := FND_MSG_PUB.Count_Msg;

            PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_FALSE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);

            x_msg_data := l_data;
            x_msg_count := l_msg_count;

            RAISE PA_FP_CONSTANTS_PKG.Just_Ret_Exc;
        ELSE
            -- AMG context
            x_err_code := 'PA_FP_LOCKED_BY_PROCESSING';

            PA_UTILS.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name       => 'PA_FP_LOCKED_BY_PROCESSING');

            l_msg_count := FND_MSG_PUB.Count_Msg;

            PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_FALSE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);

            x_msg_data := l_data;
            x_msg_count := l_msg_count;

            RAISE PA_FP_CONSTANTS_PKG.Just_Ret_Exc;
        END IF;
   END IF; -- locked by process

   -- End Bug 3057564 --------------------------------------------

  -- checking plan_processing_code for webadi context
  IF p_context = 'WEBADI' THEN
      IF p_excel_calling_mode = 'STANDARD' THEN
          IF l_plan_processing_code = 'XLUP' OR
             l_plan_processing_code = 'XLUE' THEN
                 -- the version is locked for processing or the version
                 -- has some processing errors.
                 IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Web ADI: Process Locked Error';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                     pa_debug.g_err_stage:='Populating Error Flag - Code';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 END IF;

               x_err_code := 'PA_FP_WA_BV_LOCKED_PRC_ERR';

               RAISE PA_FP_CONSTANTS_PKG.Just_Ret_Exc;
          END IF;
      END IF;
  END IF;

  if x_locked_by_person_id is not null  then
    if l_person_id <> x_locked_by_person_id then

        if p_context <> 'WEBADI' then
            IF p_context <> PA_FP_CONSTANTS_PKG.G_AMG_API THEN
                x_err_code := 'PA_FP_ATTACH_LOCKED_BY_USER';
                -- BUG FIX 2933867: use locked_by_person_id for error msg
                l_locked_by_name := pa_fin_plan_utils.get_person_name(x_locked_by_person_id);
                PA_UTILS.ADD_MESSAGE
                  ( p_app_short_name => 'PA',
                    p_msg_name       => 'PA_FP_ATTACH_LOCKED_BY_USER',
                    p_token1         => 'PERSON_NAME',
                    p_value1         => l_locked_by_name);
                /*
                 PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                      p_msg_name            => 'PA_FP_ATTACH_LOCKED_BY_USER');
                */

                l_msg_count := FND_MSG_PUB.Count_Msg;


                -- bug 2955756 --------------------------------------

                PA_INTERFACE_UTILS_PUB.get_messages
                       (p_encoded        => FND_API.G_TRUE
                        ,p_msg_index      => 1
                        ,p_msg_count      => l_msg_count
                        ,p_msg_data       => l_msg_data
                        ,p_data           => l_data
                        ,p_msg_index_out  => l_msg_index_out);

                x_msg_data := l_data;
                x_msg_count := l_msg_count;

                -- ---------------------------------------------------

                /*
                   if l_msg_count = 1 then
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
                */

                /*
                   x_msg_count := FND_MSG_PUB.Count_Msg;
                   if x_msg_count = 1 then
                      PA_INTERFACE_UTILS_PUB.get_messages
                         (p_encoded        => FND_API.G_TRUE,
                          p_msg_index      => 1,
                          p_data           => x_msg_data,
                          p_msg_index_out  => l_msg_index_out);
                   end if;
                */
                RAISE PA_FP_CONSTANTS_PKG.Just_Ret_Exc;
            ELSE
                -- AMG context
                x_err_code := 'PA_FP_LOCKED_BY_USER';

                PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_LOCKED_BY_USER');

                l_msg_count := FND_MSG_PUB.Count_Msg;

                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_FALSE
                      ,p_msg_index      => 1
                      ,p_msg_count      => l_msg_count
                      ,p_msg_data       => l_msg_data
                      ,p_data           => l_data
                      ,p_msg_index_out  => l_msg_index_out);

                x_msg_data := l_data;
                x_msg_count := l_msg_count;

                RAISE PA_FP_CONSTANTS_PKG.Just_Ret_Exc;
            END IF;
        ELSE -- p_context = 'WEBADI'
               IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:='Web ADI: BV Locked Error';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                     pa_debug.g_err_stage:='Populating Error Flag - Code';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;

               x_err_code := 'PA_FP_WA_BV_LOCKED_ERR';

               RAISE PA_FP_CONSTANTS_PKG.Just_Ret_Exc;
        end if; -- p_context
    end if;  -- version locked by another user
  end if;

  -- Bug 3986129: FP.M Web ADI Dev. Added additional check for 'allow_edit_after_baseline flag
  IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Validating for Allow Edit after Baseline';
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  END IF;

  BEGIN
       SELECT Nvl(fpt.edit_after_baseline_flag, 'N'),
              bv.project_id,
              bv.fin_plan_type_id,
              bv.version_type
       INTO   l_edit_after_baseline_flag,
              l_project_id,
              l_fin_plan_type_id,
              l_version_type
       FROM   pa_fin_plan_types_b fpt,
              pa_budget_versions  bv
       WHERE  bv.budget_version_id = p_budget_version_id
       AND    bv.fin_plan_type_id = fpt.fin_plan_type_id;

   EXCEPTION
         WHEN NO_DATA_FOUND THEN
              IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='No data found for edit after baseline flag';
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
              END IF;
              RAISE;
         WHEN OTHERS THEN
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  x_msg_count     := 1;
                  x_msg_data      := SQLERRM;
                  FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'pa_fin_plan_utils',
                                           p_procedure_name   => 'validate_editable_bv');
 IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.reset_err_stack;
  END IF;
   END;

   IF l_edit_after_baseline_flag = 'N' THEN
         -- a singular select to check if there is any already baselined version
         -- for that plan type and version type
         -- is_edit_allowed flag is defaulted to 'Y'

         BEGIN
              SELECT 'N'
              INTO   is_edit_allowed
              FROM   DUAL
              WHERE  EXISTS ( SELECT 'X'
                              FROM   pa_budget_versions a
                              WHERE  a.project_id = l_project_id
                              AND    a.fin_plan_type_id = l_fin_plan_type_id
                              AND    a.version_type = l_version_type
                              AND    a.budget_status_code = 'B');
         EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    is_edit_allowed := 'Y';
         END;

         IF is_edit_allowed = 'N' THEN
               IF p_context <> 'WEBADI' THEN
                    -- use the messages for attachment
                    x_err_code := 'PA_FP_PLAN_TYPE_NON_EDITABLE';

                    PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_PLAN_TYPE_NON_EDITABLE');

                    l_msg_count := FND_MSG_PUB.Count_Msg;

                    PA_INTERFACE_UTILS_PUB.get_messages
                          (p_encoded        => FND_API.G_TRUE
                          ,p_msg_index      => 1
                          ,p_msg_count      => l_msg_count
                          ,p_msg_data       => l_msg_data
                          ,p_data           => l_data
                          ,p_msg_index_out  => l_msg_index_out);

                    x_msg_data := l_data;
                    x_msg_count := l_msg_count;

                    RAISE PA_FP_CONSTANTS_PKG.Just_Ret_Exc;
               ELSE -- p_context = 'WEBADI'
                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='Web ADI: BV Non Edit Error';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        pa_debug.g_err_stage:='Populating Error Flag - Code';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                    END IF;
                    -- Use new messages for the context of WEBADI
                    x_err_code := 'PA_FP_WA_BV_BL_NON_EDIT';

                    RAISE PA_FP_CONSTANTS_PKG.Just_Ret_Exc;
               END IF; -- p_context
         END IF;
   END IF; -- edit_after_baseline

  IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Leaving validate_editable_bv';
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
       pa_debug.Reset_Curr_Function;
  END IF;

EXCEPTION
  WHEN PA_FP_CONSTANTS_PKG.Just_Ret_Exc THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF l_debug_mode = 'Y' THEN
            pa_debug.Reset_Curr_Function;
      END IF;
      RETURN;

  WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'pa_fin_plan_utils',
                               p_procedure_name   => 'validate_editable_bv');
 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.reset_err_stack;
 END IF;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'pa_fin_plan_utils',
                               p_procedure_name   => 'validate_editable_bv');
 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.reset_err_stack;
  END IF;
      RAISE;
END validate_editable_bv;

/* Bug 2920954 - This is a new API that does the processing necessary to check if a
   task can be deleted from old budgets model, organization forecasting, and new
   Budgeting and Forecasting perspective. For old budgets model and organization
   forecasting, presence of a task in resource assignments table implies that amounts
   exist for the task and so the task can not be deleted. For financial planning model,
   since records exists in pa_resource_assignments even when no budget lines exists,
   pa_fp_elements table has to be verified to check if plan amounts exist for a task.
   If p_validation_mode is U,
     p_task_id should not be present in BASELINED versions and should not be present in
     other versions with amounts
   If p_validation_mode is R,
     p_task_id should not be present in any version.
   Bug 2993894, in Restricted mode deletion of a task is not allowed if the task is
   referenced for any of the options(project/plan type/ plan version) in pa_fp_elements table.
 */

PROCEDURE check_delete_task_ok
     ( /* p_task_id               IN   pa_tasks.task_id%TYPE Commenting out NOCOPY for to replace  --File.Sql.39 bug 4440895
     pa_tasks by PA_STRUCT_TASK_WBS_V as part of FP.M, Tracking Bug No - 3354518 */
     p_task_id               IN   pa_struct_task_wbs_v.task_id%TYPE
     ,p_validation_mode       IN   VARCHAR2
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

l_debug_level2                  CONSTANT NUMBER := 2;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level4                  CONSTANT NUMBER := 4;
l_debug_level5                  CONSTANT NUMBER := 5;

l_validation_success            VARCHAR2(1) := 'Y'; /* Y when delete is allowed, N when delete is not allowed */

/* Changes for FP.M, Tracking Bug No - 3354518
Replacing all references of PA_TASKS by PA_STRUCT_TASK_WBS_V
and of PA_FP_ELEMNTS by PA_RESOURCE_ASSIGNMENTS
as PA_FP_ELEMENTS is being obsoleted*/


CURSOR delete_task_R_mode_cur IS
SELECT 'N' validation_success  /* If cursor returns a record, deletion is not allowed */
FROM   DUAL
WHERE  EXISTS (
 /*  Commenting out as part of FP.M, Tracking Bug No - 3354518
     Since We will now check the existence of a budget version
     (having wp_version_flag = 'N') using pa_budget_version and
     pa_resource_assignments */

     /*    SELECT 1
                 FROM   pa_fp_elements fe */
                        /* Bug 2993894 ,pa_budget_versions bv */ -- Commenting out code for FP.M, Tracking Bug No - 3354518
        /*         WHERE  fe.task_id IN
                           (SELECT pt.task_id
                            FROM  PA_TASKS pt */ -- Commenting out code for FP.M, Tracking Bug No - 3354518
                   /* pa_tasks pt Commenting out for to replace pa_tasks by PA_STRUCT_TASK_WBS_V
                             as part of FP.M, Tracking Bug No - 3354518 */
     /*            CONNECT BY PRIOR pt.task_id = pt.parent_task_id
                            START WITH pt.task_id = p_task_id)*/ -- Commenting out code for FP.M, Tracking Bug No - 3354518
                 /* Bug 2993894 AND    bv.budget_version_id = fe.fin_plan_version_id */
       /*        UNION ALL  */ -- Commenting out code for FP.M, Tracking Bug No - 3354518
                 SELECT 1
                 FROM   pa_resource_assignments r,
                        pa_budget_versions bv
                 WHERE  r.task_id IN
                          (SELECT pt.task_id  /*Changing refernece of pa_struct_task_wbs_v below to pa_tasks*/
                           FROM   PA_TASKS pt /*Reverting changes for FPM, view pa_struct_task_wbs_v cannot be used in connect by clause*/
                  CONNECT BY PRIOR pt.task_id = pt.parent_task_id
                           START WITH pt.task_id = p_task_id)
                 AND    bv.budget_version_id = r.budget_version_id
                 AND    nvl(bv.wp_version_flag,'N') = 'N'); -- Added for FP.M, Tracking Bug No - 3354518
-- Commenting Out code Below for FOM DEv Changes -- Bug 3640517 -- Starts
/*                 AND    (bv.budget_type_code IS NOT NULL
                         OR
                         bv.fin_plan_type_id IN (SELECT fpt.fin_plan_type_id
                                                  FROM   pa_fin_plan_types_b fpt
                                                  WHERE  fpt.fin_plan_type_code = 'ORG_FORECAST')));
*/
-- Commenting Out code Above for FPM DEv Changes -- Bug 3640517 -- Ends

/* Commenting out cursor for FPM chnages - Tracking bug - 3354518 */
/* The above cursor delete_task_R_mode_cur shall be used for both restricted as well as unrestructed mode */
/*
CURSOR delete_task_U_mode_cur IS
SELECT 'N' validation_success -- If cursor returns a record, deletion is not allowed
FROM   DUAL
WHERE  EXISTS (
                 SELECT 1
                 FROM    -- pa_fp_elements fe Commenting out for to replace pa_fp_elements by PA_RESOURCE_ASSIGNMENTS as part of FP.M, Tracking Bug No - 3354518
               pa_resource_assignments fe,
                        pa_budget_versions bv
                 WHERE  fe.task_id IN
                           (SELECT pt.task_id
                            FROM   PA_STRUCT_TASK_WBS_V pt
                   -- pa_tasks pt Commenting out for to replace pa_tasks by PA_STRUCT_TASK_WBS_V as part of FP.M, Tracking Bug No - 3354518
                   CONNECT BY PRIOR pt.task_id = pt.parent_task_id
                            START WITH pt.task_id = p_task_id)
                 -- AND    bv.budget_version_id = fe.fin_plan_version_id
                 -- Part of Changes for FP.M, Tracking Bug No - 3354518 , replace fin_plan_version_id by budget_version_id
                  AND    bv.budget_version_id = fe.budget_version_id
                 AND    (fe.plan_amount_exists_flag = 'Y' OR bv.budget_status_code = 'B')
           AND     nvl(bv.wp_version_flag,'N') = 'N' -- Added for FP.M, Tracking Bug No - 3354518
                 UNION ALL
                 SELECT 1
                 FROM   pa_resource_assignments r,
                        pa_budget_versions bv
                 WHERE  r.task_id IN
                          (SELECT pt.task_id
                           FROM    PA_STRUCT_TASK_WBS_V pt
                  -- pa_tasks pt Commenting out for to replace pa_tasks by PA_STRUCT_TASK_WBS_V as part of FP.M, Tracking Bug No - 3354518
               CONNECT BY PRIOR pt.task_id = pt.parent_task_id
                           START WITH pt.task_id = p_task_id)
                 AND    bv.budget_version_id = r.budget_version_id
           AND     nvl(bv.wp_version_flag,'N') = 'N' -- Added for FP.M, Tracking Bug No - 3354518
                 AND    (bv.budget_type_code IS NOT NULL
                         OR
                         bv.fin_plan_type_id IN (SELECT fpt.fin_plan_type_id
                                                  FROM   pa_fin_plan_types_b fpt
                                                  WHERE  fpt.fin_plan_type_code = 'ORG_FORECAST')));
*/



BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
 IF l_debug_mode = 'Y' THEN
     pa_debug.set_curr_function( p_function   => 'check_delete_task_ok',
                                 p_debug_mode => l_debug_mode );

     -- Check for business rules violations
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF (p_task_id IS NULL)
     THEN
          IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_task_id = '|| p_task_id;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                           l_debug_level5);
                  pa_debug.g_err_stage:= 'p_validation_mode = '|| p_validation_mode;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                           l_debug_level5);
          END IF;
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                  p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;

     IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'p_validation_mode = '|| p_validation_mode;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
     END IF;


/* Commenting out code below for FPM chnages - Tracking bug - 3354518 */
/* The  cursor delete_task_R_mode_cur shall be used for both restricted as well as unrestructed mode */

/*
IF p_validation_mode = 'U' THEN

          OPEN delete_task_U_mode_cur;
          FETCH delete_task_U_mode_cur into l_validation_success;
          CLOSE delete_task_U_mode_cur;

     ELSIF p_validation_mode = 'R' THEN

          OPEN delete_task_R_mode_cur;
          FETCH delete_task_R_mode_cur into l_validation_success;
          CLOSE delete_task_R_mode_cur;

     ELSE

          Raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
END IF;
*/


IF ((p_validation_mode = 'U') OR ( p_validation_mode = 'R' )) THEN

          OPEN delete_task_R_mode_cur;
          FETCH delete_task_R_mode_cur into l_validation_success;
          CLOSE delete_task_R_mode_cur;
ELSE

          Raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
END IF;



     IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'l_validation_success = '|| l_validation_success;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
     END IF;

     IF l_validation_success = 'N' THEN
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                  p_msg_name      => 'PA_TSK_BUDGET_EXIST');
          RAISE FND_API.G_Exc_Error;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting check_delete_task_ok';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
     pa_debug.reset_curr_function;
	END IF;
EXCEPTION

WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
 IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.reset_curr_function;
END IF;
     RETURN;

WHEN FND_API.G_Exc_Error THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
 IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.reset_curr_function;
END IF;
     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'pa_fin_plan_utils'
                    ,p_procedure_name  => 'check_delete_task_ok'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
     pa_debug.reset_curr_function;
	END IF;
     RAISE;
END check_delete_task_ok;

PROCEDURE check_reparent_task_ok
     (p_task_id               IN   pa_tasks.task_id%TYPE
     ,p_old_parent_task_id    IN   pa_tasks.task_id%TYPE
     ,p_new_parent_task_id    IN   pa_tasks.task_id%TYPE
     ,p_validation_mode       IN   VARCHAR2
     ,x_return_status        OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count            OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data             OUT   NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

-- validation variables
l_is_parent_lowest_task       NUMBER(1);
l_parent_top_task_id          pa_tasks.top_task_id%TYPE;
l_task_name                   pa_tasks.task_name%TYPE;
l_old_parent_task_name        pa_tasks.task_name%TYPE;
l_new_parent_task_name        pa_tasks.task_name%TYPE;

-- debugging variables
l_module_name                 VARCHAR2(100) := 'check_reparent_task_ok';
l_return_status               VARCHAR2(1);
l_msg_count                   NUMBER := 0;
l_data                        VARCHAR2(2000);
l_msg_data                    VARCHAR2(2000);
l_msg_index_out               NUMBER;
l_debug_mode                   VARCHAR2(1);

cursor task_ra_csr (tid  pa_tasks.task_id%TYPE) is
select 1
  from pa_resource_assignments
  where task_id = tid;
task_ra_rec task_ra_csr%ROWTYPE;

BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
 IF l_debug_mode = 'Y' THEN
     pa_debug.set_curr_function( p_function   => 'check_reparent_task_ok',
                                 p_debug_mode => l_debug_mode );
     -- check for business rules violations

          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF (p_task_id IS NULL) or (p_old_parent_task_id is NULL) or (p_new_parent_task_id is NULL) THEN
          IF l_debug_mode = 'Y' THEN
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
          END IF;
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                 p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;
     -- end of business rules violations check

     IF (p_old_parent_task_id = p_new_parent_task_id) THEN
         -- not really a re-parenting procedure, so just return successfully
 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.reset_curr_function;
END IF;
         return;
     END IF; -- old parent = new parent

     -- VALIDATION: Affected task
     pa_fin_plan_utils.check_delete_task_ok
        (p_task_id               => p_task_id,
      p_validation_mode   => p_validation_mode,
--         x_delete_task_ok_flag   => l_delete_task_ok_flag,
           x_return_status     => l_return_status,
           x_msg_count         => l_msg_count,
           x_msg_data          => l_msg_data);
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count;
      x_msg_data := l_msg_data;
/* NO NEED TO ADD ERROR MESSAGE TO STACK:
   Justification: Error message will be added by check_delete_task_ok
         PA_UTILS.ADD_MESSAGE
             ( p_app_short_name => 'PA',
               p_msg_name       => 'PA_FP_REPARENT_ERR_TASK',
               p_token1         => 'TASK_NAME',
               p_value1         => l_task_name);
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count = 1 and x_msg_data IS NULL THEN
              PA_INTERFACE_UTILS_PUB.get_messages
                  (p_encoded        => FND_API.G_TRUE,
                   p_msg_index      => 1,
                   p_msg_count      => l_msg_count,
                   p_msg_data       => l_msg_data,
                   p_data           => l_data,
                   p_msg_index_out  => l_msg_index_out);
              x_msg_data := l_data;
              x_msg_count := l_msg_count;
         ELSE
              x_msg_count := l_msg_count;
         END IF;
*/
 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.reset_curr_function;
END IF;
         return;
     END IF; -- validation: affected task

/*   UPDATE FROM VEJAYARA:
     Validation done for old_parent_task_id is not required. This is because,
     we dont expect to have any lines in RA table for parent_task_id when
     amounts dont exists for the impacted_Task_id (checked by the call to
     check_delete_task_ok). If there are other lowest tasks with amounts, the
     old_parent_task_id will have a record in RA table and it is ok to have
     that record. Presence of that record is not business violation for reparenting.

     -- VALIDATION: Old parent task
     open task_ra_csr(p_old_parent_task_id);
     fetch task_ra_csr into task_ra_rec;
     IF task_ra_csr%FOUND then
         -- records in pa_resource_assignments: VALIDATION FAILED
         x_return_status := FND_API.G_RET_STS_ERROR;
         BEGIN
           select task_name
             into l_task_name
             from pa_tasks
             where task_id = p_task_id;
           select task_name
             into l_old_parent_task_name
             from pa_tasks
             where task_id = p_old_parent_task_id;
         EXCEPTION
           when NO_DATA_FOUND then
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END;
         PA_UTILS.ADD_MESSAGE
             ( p_app_short_name => 'PA',
               p_msg_name       => 'PA_FP_REPARENT_ERR_OLDPRT',
               p_token1         => 'TASK_NAME',
               p_value1         => l_task_name,
               p_token2         => 'PARENT_TASK_NAME',
               p_value2         => l_old_parent_task_name);
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count = 1 and x_msg_data IS NULL THEN
              PA_INTERFACE_UTILS_PUB.get_messages
                  (p_encoded        => FND_API.G_TRUE,
                   p_msg_index      => 1,
                   p_msg_count      => l_msg_count,
                   p_msg_data       => l_msg_data,
                   p_data           => l_data,
                   p_msg_index_out  => l_msg_index_out);
              x_msg_data := l_data;
              x_msg_count := l_msg_count;
         ELSE
              x_msg_count := l_msg_count;
         END IF;
         close task_ra_csr;
 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.reset_curr_function;
END IF;
         return;
     END IF;
     close task_ra_csr;
*/

     -- VALIDATION: New parent task
     select top_task_id
       into l_parent_top_task_id
       from pa_tasks
       where task_id = p_new_parent_task_id;
     l_is_parent_lowest_task := pa_budget_utils2.check_task_lowest_in_budgets
            (x_task_id            => p_new_parent_task_id,
             x_top_task_id        => l_parent_top_task_id,
             x_validation_mode    => p_validation_mode);
     IF (l_is_parent_lowest_task = 1) THEN
         -- new parent task is a plannable lowest task: VALIDATION FAILURE
         x_return_status := FND_API.G_RET_STS_ERROR;
         BEGIN
           select task_name
             into l_task_name
             from pa_tasks
             where task_id = p_task_id;
           select task_name
             into l_new_parent_task_name
             from pa_tasks
             where task_id = p_new_parent_task_id;
         EXCEPTION
           when NO_DATA_FOUND then
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END;
         PA_UTILS.ADD_MESSAGE
             ( p_app_short_name => 'PA',
               p_msg_name       => 'PA_FP_REPARENT_ERR_NEWPRT',
--               p_token1         => 'TASK_NAME',
--               p_value1         => l_task_name,
               p_token1         => 'PARENT_TASK_NAME',
               p_value1         => l_new_parent_task_name);
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count = 1 and x_msg_data IS NULL THEN
              PA_INTERFACE_UTILS_PUB.get_messages
                  (p_encoded        => FND_API.G_TRUE,
                   p_msg_index      => 1,
                   p_msg_count      => l_msg_count,
                   p_msg_data       => l_msg_data,
                   p_data           => l_data,
                   p_msg_index_out  => l_msg_index_out);
              x_msg_data := l_data;
              x_msg_count := l_msg_count;
         ELSE
              x_msg_count := l_msg_count;
         END IF;
 IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.reset_curr_function;
END IF;
         return;
     END IF;
 IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.reset_curr_function;
END IF;
EXCEPTION
  WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;
     IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
 IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.reset_curr_function;
END IF;
     RETURN;
  WHEN others THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;
     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'pa_fin_plan_utils'
                    ,p_procedure_name  => 'check_reparent_task_ok'
                    ,p_error_text      => x_msg_data);
     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
     pa_debug.reset_curr_function;
END IF;
     RAISE;
END check_reparent_task_ok;

/* Part of changes for FP.M, Tracking Bug No - 3354518
This function is being called by PA_FP_ELEMENTS_PUB currently to verify,
if PA_FP_ELEMENTS contains a entry for this task.
This procedure is now obsoleted.
However noticing that this procedure is re-usable,
we change all references to pa_tasks to pa_struct_task_wbs_v
and all references of pa_fp_elements to pa_resource_assignments*/

FUNCTION check_task_in_fp_option
    (
  /*  p_task_id                IN   pa_tasks.task_id%TYPE  */
  /*  Changing reference of pa_tasks to pa_struct_task_wbs_v  */
      p_task_id                IN   pa_struct_task_wbs_v.task_id%TYPE)

    RETURN VARCHAR2 AS

     l_exists VARCHAR2(1) := 'N';

     CURSOR C1 IS
     SELECT 'Y'
     FROM   DUAL
  /*  Changing reference of pa_fp_elements to pa_resource_assignments  */
     WHERE  EXISTS (SELECT 'X' FROM pa_resource_assignments WHERE TASK_ID = P_TASK_ID);
/*     WHERE  EXISTS (SELECT 'X' FROM PA_FP_ELEMENTS WHERE TASK_ID = P_TASK_ID); */

BEGIN

     OPEN C1;
     FETCH C1 INTO l_exists;
     CLOSE C1;

     RETURN l_exists;

END check_task_in_fp_option;


/* End of changes for FPM, Tracking Bug No - 3354518 */

--Name:        Get_Budgeted_Amount
--Type:                  Function
--
--Description:          This function is used by Capital-Project calling
--                      objects to get the following:
--
--                      1) PROEJCT or LOWEST-LEVEL TASK for a given project
--                      2) COST budget or FP plan version
--                      3) Cost TOTAL amounts
--                      4) RETURN RAW or BURDENED cost amount
--
--                      Amount is the project functional amount for the
--                      the CURRNET BASELINED budget/plan version.
--
--                      Since this is an internal function, validations are NOT
--                      performed on the IN-parameters:
--
--                         Indeed, as directed by management, if the calling object
--                         wants cost amounts for an approved cost plan type,
--                         it is the responsibility of the calling object to pass
--                         a fin_plan_type_id for an approved cost plan type.
--
--                      As per design, if no data found, zero is returned.
--
--
--
--Called subprograms:    None.
--
--Notes:
--                      Accuracy is important for this function.
--
--                      PROJECT-level amounts:
--
--                      1)    The old model SQL is coded in light of historical
--                            quality issues with the Budget Form population of the
--                            pa_budget_versions denormalized amounts.
--
--                      2)    The new model SQL is coded with the assumption that
--                            there should be few bugs, if any, for the project-level
--                            denormalized columns. Additionally, since there are far more
--                            budget lines (multiple row types) for FP plans, performance
--                            is more of a consideration.
--
--                      TASK-level amounts:
--
--                      The SQLs are coded more with accuracy in mind than performance.
--
--History:
--    27-MAY-03 jwhite  - Created
--
--    29-MAY-03 jwhite  - As directed by managment, substituted a
--                        version_type filter for approved_cost filter.
--
-- IN Parameters
--    p_project_id              - Always passed.
--
--    p_task_id                 - Passed as NULL if project-level amounts requested.
--
--    p_fin_plan_type_id        - Query FP model if p_fin_plan_type_id is N-O-T null.
--
--    p_budget_type_code        - Query pre-FP model if p_fin_plan_type_id is NULL.
--
--    p_amount_type             - Passed as 'R' to return raw cost; 'B' to return burdened cost.


FUNCTION Get_Budgeted_Amount
   (
     p_project_id              IN   pa_projects_all.project_id%TYPE
     , p_task_id               IN   pa_tasks.task_id%TYPE
     , p_fin_plan_type_id      IN   pa_proj_fp_options.fin_plan_type_id%TYPE
     , p_budget_type_code      IN   pa_budget_versions.budget_type_code%TYPE
     , p_amount_type           IN   VARCHAR2
   )  RETURN NUMBER
IS



     -- Project-Level Amounts --------------------------
     --

     -- OLD (Pre-FP) Model

     CURSOR projOld_csr
     IS
     SELECT   sum(l.raw_cost)
              , sum(l.burdened_cost)
     FROM     pa_budget_versions v
              , pa_resource_assignments a
              , pa_budget_lines  l
     WHERE    v.project_id = p_project_id
     AND      v.budget_type_code = p_budget_type_code
     AND      v.current_flag  = 'Y'
     AND      v.budget_version_id = a.budget_version_id
     AND      a.resource_assignment_id = l.resource_assignment_id;


     -- NEW FP Model

     CURSOR projNewFp_csr
     IS
     SELECT   raw_cost
              , burdened_cost
     FROM     pa_budget_versions
     WHERE    project_id = p_project_id
     AND      fin_plan_type_id  = p_fin_plan_type_id
     AND      current_flag  = 'Y'
     AND      version_type IN ('COST','ALL');



     -- Task-Level Amounts ------------------------------------
     --

     -- OLD (Pre-FP) Model M-U-S-T Join to Budget Lines

     CURSOR taskOld_csr
     IS
     SELECT   sum(l.raw_cost)
              , sum(l.burdened_cost)
     FROM     pa_budget_versions v
              , pa_resource_assignments a
              , pa_budget_lines  l
     WHERE    v.project_id = p_project_id
     AND      v.budget_type_code = p_budget_type_code
     AND      v.current_flag  = 'Y'
     AND      v.budget_version_id = a.budget_version_id
     AND      a.task_id = p_task_id
     AND      a.resource_assignment_id = l.resource_assignment_id;


     -- NEW FP Model Can join to PA_RESOURCE_ASSIGNMENTS for Denormalized Amounts
     --
     -- !!!   * * *   PLEASE NOTE   * * *    !!!
     --    For this cursor, the pa_resource_assignments table contains multiple
     --    row types for a given baselined version,i.e.:
     --
     --      ROLLED_UP
     --      USER_ENTERED
     --
     --    The ROLLED_UP rows may be subject to a numerous bugs over time, given
     --    the complexity of the logic. Therefore, the rolled-up amounts may
     --    often be incorrect over time.
     --
     --    As a result, this cursor favors accuracy over performance and
     --    joins to 'USER_ENTERED' rows.
     --
     --

     CURSOR taskNewFp_csr
     IS
     SELECT   sum(a.TOTAL_PLAN_RAW_COST)
              , sum(a.TOTAL_PLAN_BURDENED_COST)
     FROM     pa_budget_versions v
              , pa_resource_assignments a
     WHERE    v.project_id = p_project_id
     AND      v.fin_plan_type_id = p_fin_plan_type_id
     AND      v.current_flag  = 'Y'
     AND      v.budget_version_id = a.budget_version_id
     AND      a.task_id = p_task_id
     AND      a.RESOURCE_ASSIGNMENT_TYPE = 'USER_ENTERED'
     AND      version_type IN ('COST','ALL');




     l_raw_cost       NUMBER := 0;
     l_burdened_cost  NUMBER := 0;


BEGIN


   IF ( p_fin_plan_type_id IS NULL)
     THEN

      --  OLD Model Processing ----------------------

      IF ( p_task_id IS NULL )
        THEN

          -- Get Project-level Amounts

          OPEN  projOld_csr;
          FETCH projOld_csr INTO l_raw_cost, l_burdened_cost;
          CLOSE projOld_csr;

      ELSE

          -- Get Task-level Amounts


          OPEN  taskOld_csr;
          FETCH taskOld_csr INTO l_raw_cost, l_burdened_cost;
          CLOSE taskOld_csr;


      END IF; -- p_task_id IS NULL



   ELSE

      --  NEW FP Model Processing ---------------------

      IF ( p_task_id IS NULL )
        THEN

          -- Get Project-level Amounts

          OPEN  projNewFp_csr;
          FETCH projNewFp_csr INTO l_raw_cost, l_burdened_cost;
          CLOSE projNewFp_csr;

      ELSE

          -- Get Task-level Amounts


          OPEN  taskNewFp_csr;
          FETCH taskNewFp_csr INTO l_raw_cost, l_burdened_cost;
          CLOSE taskNewFp_csr;


      END IF; -- p_task_id IS NULL



   END IF; -- p_fin_plan_type_id IS NULL



   -- Conditionally RETURN Raw or Burdended Cost

   IF ( p_amount_type = 'R')
    THEN
       -- return raw cost

       RETURN l_raw_cost;

    ELSE
      -- return BURDENED cost

       RETURN l_burdened_cost;

   END IF; -- p_amount_type = 'R'



   EXCEPTION
      WHEN NO_DATA_FOUND then
        RETURN 0;
   WHEN OTHERS then
        RETURN 0;

END Get_Budgeted_Amount;

PROCEDURE Check_if_plan_type_editable (
 P_project_id            In              Number
,P_fin_plan_type_id      IN              Number
,P_version_type          IN              VARCHAR2
,X_editable_flag         OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,X_return_status         OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,X_msg_count             OUT             NOCOPY NUMBER --File.Sql.39 bug 4440895
,X_msg_data              OUT             NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

AS

    -- Start of variables used for debugging purpose

     l_msg_count          NUMBER :=0;
     l_data               VARCHAR2(2000);
     l_msg_data           VARCHAR2(2000);
     l_error_msg_code     VARCHAR2(30);
     l_msg_index_out      NUMBER;
     l_return_status      VARCHAR2(2000);
     l_debug_mode         VARCHAR2(30);

    -- End of variables used for debugging purpose



BEGIN

     FND_MSG_PUB.initialize;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.set_curr_function( p_function => 'Check_if_plan_type_editable',
                                     p_debug_mode => l_debug_mode );
     END IF;
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     -- Check for business rules violations


     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Validating input parameters';
         pa_debug.write('Check_if_plan_type_editable: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     -- Check if project id, fp option id and Version type are null

     IF (p_project_id       IS NULL) OR
        (p_fin_plan_type_id IS NULL) OR
        (p_version_type IS NULL)
     THEN


         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Project_id = '||p_project_id;
             pa_debug.write('Check_if_plan_type_editable: ' || l_module_name,pa_debug.g_err_stage,5);

             pa_debug.g_err_stage:='Fin_plan_type_id = '||p_fin_plan_type_id;
             pa_debug.write('Check_if_plan_type_editable: ' || l_module_name,pa_debug.g_err_stage,5);

             pa_debug.g_err_stage:='Version_type = '||p_version_type;
             pa_debug.write('Check_if_plan_type_editable: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;


         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');


         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write('Check_if_plan_type_editable: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;

     BEGIN
         select edit_after_baseline_flag
         into   x_editable_flag
         from pa_fin_plan_types_b
         where fin_plan_type_id = p_fin_plan_type_id;
     EXCEPTION
         WHEN OTHERS THEN

                           IF P_PA_DEBUG_MODE = 'Y' THEN
                               pa_debug.g_err_stage:='Error while fetching edit_after_baseline_flag';
                               pa_debug.write('Check_if_plan_type_editable: ' || l_module_name,pa_debug.g_err_stage,3);
                           END IF;
                           RAISE;
     END;

     IF nvl(x_editable_flag,'Y') <> 'Y' THEN

         BEGIN
          select 'N'
             into  x_editable_flag
             from  dual where exists (
                 select 1
                 from   pa_budget_versions
                 where  project_id = p_project_id
                 and    fin_plan_type_id = p_fin_plan_type_id
                 and    version_type = p_version_type
                 and    budget_status_code = 'B' );
         EXCEPTION
             WHEN NO_DATA_FOUND THEN

                           IF P_PA_DEBUG_MODE = 'Y' THEN
                               pa_debug.g_err_stage:='No base versions exist';
                               pa_debug.write('Check_if_plan_type_editable: ' || l_module_name,pa_debug.g_err_stage,3);
                           END IF;

                           x_editable_flag := 'Y';

         END;
     ELSE
         x_editable_flag := 'Y';
     END IF;

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Exiting Check_if_plan_type_editable:';
         pa_debug.write('Check_if_plan_type_editable: ' || l_module_name,pa_debug.g_err_stage,3);

    --Reset the error stack

	     pa_debug.reset_curr_function;
	END IF;
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
--           pa_debug.g_err_stage:='Invalid Arguments Passed';
--           pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
 IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.reset_curr_function;
END IF;
           RETURN;

     WHEN Others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FIN_PLAN_UTILS'
                                  ,p_procedure_name  => 'CHECK_IF_PLAN_TYPE_EDITABLE');
          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
              pa_debug.write('Check_if_plan_type_editable: ' || l_module_name,pa_debug.g_err_stage,5);
          pa_debug.reset_curr_function;
	END IF;
          RAISE;

END Check_if_plan_type_editable;

PROCEDURE End_date_active_val
    (p_start_date_active              IN     Date,
     p_end_date_active                IN     Date,
     x_return_status                  OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                      OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                       OUT    NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
 l_msg_count       NUMBER;
 l_msg_index_out   NUMBER;
 l_data            VARCHAR2(2000);
 l_msg_data        VARCHAR2(2000);
BEGIN

  IF p_start_date_active IS NULL THEN
        /* Start date must be entered */
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_MANDATORY_INFO_MISSING');
  END IF;

  IF p_start_date_active > nvl(p_end_date_active,p_start_date_active) THEN
        /* The End Date cannot be earlier than the Start Date.  */
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_INVALID_END_DATE');
  END IF;

    l_msg_count := FND_MSG_PUB.count_msg;

    IF l_msg_count > 0 THEN
        IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
        ELSE
             x_msg_count := l_msg_count;
        END IF;
        return;
    ELSE
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_UTILS',
                               p_procedure_name   => 'end_date_active_val');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END End_date_active_val;

/*=============================================================================
 This api is used to return current original version info for given plan type,
 project id and version type
==============================================================================*/

PROCEDURE Get_Curr_Original_Version_Info(
          p_project_id            IN   pa_projects_all.project_id%TYPE
          ,p_fin_plan_type_id     IN   pa_budget_versions.fin_plan_type_id%TYPE
          ,p_version_type         IN   pa_budget_versions.version_type%TYPE
          ,x_fp_options_id        OUT  NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE --File.Sql.39 bug 4440895
          ,x_fin_plan_version_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_version_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data             OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

    --Start of variables used for debugging

    l_msg_count          NUMBER :=0;
    l_data               VARCHAR2(2000);
    l_msg_data           VARCHAR2(2000);
    l_error_msg_code     VARCHAR2(30);
    l_msg_index_out      NUMBER;
    l_return_status      VARCHAR2(2000);
    l_debug_mode         VARCHAR2(30);

    --End of variables used for debugging

    l_fp_preference_code            pa_proj_fp_options.fin_plan_preference_code%TYPE;
    l_version_type                  pa_budget_versions.version_type%TYPE;
    l_current_original_version_id   pa_budget_versions.budget_version_id%TYPE;
    l_fp_options_id                 pa_proj_fp_options.proj_fp_options_id%TYPE;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    IF l_debug_mode = 'Y' THEN
       pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.Get_Curr_Original_Version_Info');
       pa_debug.set_process('Get_Curr_Original_Version_Info: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;

    -- Check for business rules violations

    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Validating input parameters';
       pa_debug.write('Get_Curr_Original_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id       IS NULL) OR
       (p_fin_plan_type_id IS NULL)
    THEN

             IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Project_id = '||p_project_id;
                pa_debug.write('Get_Curr_Original_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);

                pa_debug.g_err_stage:='Fin_plan_type_id = '||p_fin_plan_type_id;
                pa_debug.write('Get_Curr_Original_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);
             END IF;

             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    --Fetch fin plan preference code

    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Fetching fin plan preference code ';
       pa_debug.write('Get_Curr_Original_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    SELECT fin_plan_preference_code
    INTO   l_fp_preference_code
    FROM   pa_proj_fp_options
    WHERE  project_id = p_project_id
    AND    fin_plan_type_id = p_fin_plan_type_id
    AND    fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;

    IF (l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) AND
       (p_version_type IS NULL)
    THEN

          --In this case version_type should be passed and so raise error

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Version_Type = '||p_version_type;
             pa_debug.write('Get_Curr_Original_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);
          END IF;

          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                      p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Parameter validation complete ';
       pa_debug.write('Get_Curr_Original_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Fetch  l_element_type ifn't passed and could be derived

    IF p_version_type IS NULL THEN

      IF l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME THEN

         l_version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL;

      ELSIF l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY THEN

         l_version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST;

      ELSIF l_fp_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY THEN

         l_version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE;

      END IF;

    END IF;

    --Fetch the current original version

    BEGIN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Fetching current original Version';
           pa_debug.write('Get_Curr_Original_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        SELECT budget_version_id
        INTO   l_current_original_version_id
        FROM   pa_budget_versions
        WHERE  project_id = p_project_id
        AND    fin_plan_type_id = p_fin_plan_type_id
        AND    version_type = NVL(p_version_type,l_version_type)
        AND    budget_status_code = 'B'
        AND    current_original_flag = 'Y';

        --Fetch fp options id using plan version id

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Fetching fp option id';
           pa_debug.write('Get_Curr_Original_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        SELECT proj_fp_options_id
        INTO   l_fp_options_id
        FROM   pa_proj_fp_options
        WHERE  fin_plan_version_id = l_current_original_version_id;

    EXCEPTION

      WHEN NO_DATA_FOUND THEN

             l_current_original_version_id := NULL;
             l_fp_options_id := NULL;

    END;

    -- return the parameters to calling programme
    x_fin_plan_version_id := l_current_original_version_id;
    x_fp_options_id := l_fp_options_id;

    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Exiting Get_Curr_Original_Version_Info';
       pa_debug.write('Get_Curr_Original_Version_Info: ' || l_module_name,pa_debug.g_err_stage,3);
       pa_debug.reset_err_stack;
    END IF;

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

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write('Get_Curr_Original_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);

             -- reset error stack
             pa_debug.reset_err_stack;
          END IF;
          RETURN;

     WHEN Others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FIN_PLAN_UTILS'
                                  ,p_procedure_name  => 'Get_Curr_Original_Version_Info');

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write('Get_Curr_Original_Version_Info: ' || l_module_name,pa_debug.g_err_stage,5);

             -- reset error stack
             pa_debug.reset_err_stack;
          END IF;
          RAISE;
END Get_Curr_Original_Version_Info;

/*=============================================================================
 This api is used to derive actual_amts_thru_period for a version. The api also
 returns first future PA/GL periods if they are available. This api is called
 from plan setting pages to maintain Include unspent amount through period lov.
==============================================================================*/

PROCEDURE GET_ACTUAL_AMTS_THRU_PERIOD(
           p_budget_version_id       IN   pa_budget_versions.budget_version_id%TYPE
          ,x_record_version_number   OUT   NOCOPY pa_budget_versions.record_version_number%TYPE --File.Sql.39 bug 4440895
          ,x_actual_amts_thru_period OUT   NOCOPY pa_budget_versions.actual_amts_thru_period%TYPE --File.Sql.39 bug 4440895
          ,x_first_future_pa_period  OUT   NOCOPY pa_periods_all.period_name%TYPE --File.Sql.39 bug 4440895
          ,x_first_future_gl_period  OUT   NOCOPY pa_periods_all.period_name%TYPE --File.Sql.39 bug 4440895
          ,x_return_status           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count               OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

    --Start of variables used for debugging

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER := 0;
    l_msg_data           VARCHAR2(2000);
    l_data               VARCHAR2(2000);
    l_msg_index_out      NUMBER;
    l_debug_mode         VARCHAR2(30);

    --End of variables used for debugging

    CURSOR future_gl_periods_cur  IS
    SELECT gl.period_name
    FROM   pa_implementations i
           , gl_period_statuses gl
    WHERE  gl.application_id     = PA_Period_Process_PKG.Application_ID
    AND    gl.set_of_books_id    = i.set_of_books_id
    AND    gl.adjustment_period_flag = 'N'
    AND    closing_status = 'F'
    ORDER BY gl.start_date;

    CURSOR future_pa_periods_cur    IS
    SELECT period_name
    FROM   pa_periods
    WHERE  status = 'F'
    ORDER BY start_date;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function

 IF l_debug_mode = 'Y' THEN
    pa_debug.set_curr_function(
                p_function   =>'PA_FIN_PLAN_UTILS.GET_ACTUAL_AMTS_THRU_PERIOD'
               ,p_debug_mode => l_debug_mode );

    -- Check for business rules violations
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write('GET_ACTUAL_AMTS_THRU_PERIOD: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_budget_version_id IS NULL)
    THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='p_budget_version_id = '|| p_budget_version_id;
           pa_debug.write('GET_ACTUAL_AMTS_THRU_PERIOD: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- Using bv id derive ACTUAL_AMTS_THRU_PERIOD from versions table
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Fetching actual_amts_thru_period';
        pa_debug.write('GET_ACTUAL_AMTS_THRU_PERIOD: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    SELECT actual_amts_thru_period
           ,record_version_number
    INTO   x_actual_amts_thru_period
           ,x_record_version_number
    FROM   pa_budget_versions
    WHERE  budget_version_id = p_budget_version_id;

    -- Fetch first future PA period
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Fetching first future PA period';
        pa_debug.write('GET_ACTUAL_AMTS_THRU_PERIOD: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    -- Fetch the first period. There might not be any future period
    OPEN  future_pa_periods_cur;
    FETCH future_pa_periods_cur INTO x_first_future_pa_period;
    CLOSE future_pa_periods_cur;

    -- Fetch first future GL period
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='first future PA period = '|| x_first_future_pa_period;
        pa_debug.write('GET_ACTUAL_AMTS_THRU_PERIOD: ' || l_module_name,pa_debug.g_err_stage,3);
        pa_debug.g_err_stage:='Fetching first future GL period';
        pa_debug.write('GET_ACTUAL_AMTS_THRU_PERIOD: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    -- Fetch first gl period, there might not be any gl period
    OPEN  future_pa_periods_cur;
    FETCH future_pa_periods_cur INTO x_first_future_gl_period;
    CLOSE future_pa_periods_cur;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='first future GL period = '||x_first_future_gl_period;
        pa_debug.write('GET_ACTUAL_AMTS_THRU_PERIOD: ' || l_module_name,pa_debug.g_err_stage,3);
        pa_debug.g_err_stage:='Exiting GET_ACTUAL_AMTS_THRU_PERIOD';
        pa_debug.write('GET_ACTUAL_AMTS_THRU_PERIOD: ' || l_module_name,pa_debug.g_err_stage,3);

    -- Reset curr function
	    pa_debug.reset_curr_function();
	END IF;
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

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
           pa_debug.write('GET_ACTUAL_AMTS_THRU_PERIOD: ' || l_module_name,pa_debug.g_err_stage,5);

       -- Reset curr function
       pa_debug.reset_curr_function();
	END IF;
       RETURN;
   WHEN Others THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                               ,p_procedure_name  => 'GET_ACTUAL_AMTS_THRU_PERIOD');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('GET_ACTUAL_AMTS_THRU_PERIOD: ' || l_module_name,pa_debug.g_err_stage,5);

       -- Reset curr function
       pa_debug.Reset_Curr_Function();
	END IF;
       RAISE;
END GET_ACTUAL_AMTS_THRU_PERIOD;

/* To determine if a task is a planning element or not */
-- Modified for Bug 3840993 --sagarwal
FUNCTION IS_TASK_A_PLANNING_ELEMENT(
           p_budget_version_id        IN pa_budget_versions.budget_version_id%TYPE
          ,p_task_id                  IN pa_tasks.task_id%TYPE)
RETURN VARCHAR2 IS
l_exists               VARCHAR2(1);
l_structure_version_id pa_budget_versions.project_structure_version_id%TYPE;

BEGIN
     /* Commented and modified for bug#5614245
        SELECT NVL(project_structure_version_id, PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(project_id )) */
     SELECT NVL(project_structure_version_id, pa_planning_element_utils.get_fin_struct_id(project_id, budget_version_id) )
     INTO   l_structure_version_id
     FROM   pa_budget_versions
     WHERE  budget_Version_id=p_budget_version_id;

    IF p_task_id <> 0 THEN -- For Task Level Records
       SELECT 'Y'
       INTO   l_exists
       FROM   DUAL
       WHERE  EXISTS (SELECT 'x'
                      FROM  PA_RESOURCE_ASSIGNMENTS a,  pa_proj_element_versions pelm
                      WHERE a.budget_version_id = p_budget_version_id
                      AND   a.task_id = pelm.proj_element_id
                      AND   a.resource_class_code = PA_FP_CONSTANTS_PKG.G_RESOURCE_CLASS_CODE_FIN
                      AND   a.task_id = p_task_id
                      AND   a.resource_class_flag = 'Y'
                      AND   pelm.parent_structure_version_id= l_structure_version_id);
    ELSE -- For Project Level Records
       SELECT 'Y'
       INTO   l_exists
       FROM   DUAL
       WHERE  EXISTS (SELECT 'x'
                      FROM  PA_RESOURCE_ASSIGNMENTS a
                      WHERE a.budget_version_id = p_budget_version_id
                      AND   a.resource_class_code = PA_FP_CONSTANTS_PKG.G_RESOURCE_CLASS_CODE_FIN
                      AND   a.task_id = p_task_id
                      AND   a.resource_class_flag = 'Y');
    END IF;

     RETURN l_exists;
EXCEPTION
WHEN NO_DATA_FOUND THEN
     RETURN 'N';
WHEN OTHERS THEN
     RETURN Null;
END IS_TASK_A_PLANNING_ELEMENT;

/* To determine if a task has resources attached to it as planning element */

FUNCTION IS_RESOURCE_ATTACHED_TO_TASK(
          p_budget_version_id        IN pa_budget_versions.budget_version_id%TYPE
          ,p_task_id                 IN pa_resource_assignments.task_id%TYPE)
         --,p_wbs_element_version_id   IN pa_resource_assignments.wbs_element_version_id%TYPE)
RETURN VARCHAR2 IS
l_exists VARCHAR2(1);
BEGIN
-- sagarwal -- Removed redundant join to pa_budget_versions from select statement below
     SELECT 'Y'
     INTO   l_exists
     FROM   DUAL
     WHERE  EXISTS (SELECT 'x'
                    FROM  PA_RESOURCE_ASSIGNMENTS a
                    WHERE a.budget_version_id = p_budget_version_id
                    AND   a.task_id           = p_task_id
                    --Commented for bug 3793136
                    --AND   a.wbs_element_version_id = p_wbs_element_version_id
                    AND   NOT(a.resource_class_code = PA_FP_CONSTANTS_PKG.G_RESOURCE_CLASS_CODE_FIN
                           and a.resource_class_flag = 'Y')    );

     RETURN l_exists;
EXCEPTION
WHEN NO_DATA_FOUND THEN
     RETURN 'N';
WHEN OTHERS THEN
     RETURN Null;
END IS_RESOURCE_ATTACHED_TO_TASK;

/*====================================================================
  To determince if a resource list can be updated for a workplan. If
  progress exists for the strucuture or task, its not allowed
  irrespective of  versioning is enabled or disbled. Else if versioning
  is disabled then if task assignments exist then its not allowed.
  Rest of the cases it can be changed.

  Bug 3619687 Changed the validations such that
    1. Check if versioning is enabled
        a. if published version exists change is not allowed
        b. else allow change
    2. If versioning disabled case,
        a. if progress exists against project or any of the tasks
           change is not allowed
        b. else allow change
 ====================================================================*/

PROCEDURE IS_WP_RL_UPDATEABLE(
           p_project_id                     IN   pa_budget_versions.project_id%TYPE
          ,x_wp_rl_update_allowed_flag      OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_reason_msg_code                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_return_status                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                      OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                       OUT  NOCOPY VARCHAR2)AS --File.Sql.39 bug 4440895

    --Start of variables used for debugging

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER := 0;
    l_msg_data           VARCHAR2(2000);
    l_data               VARCHAR2(2000);
    l_msg_index_out      NUMBER;
    l_debug_mode         VARCHAR2(30);

    --End of variables used for debugging

    l_progress_exists          VARCHAR2(1);
    l_is_sharing_enabled       VARCHAR2(1);
    l_is_versioning_enabled    VARCHAR2(1);
    l_structure_id             NUMBER;
    l_task_id                  NUMBER;

    CURSOR get_wp_id IS
      SELECT ppe.proj_element_id
        from pa_proj_elements ppe,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       where ppe.project_id = p_project_id
         and ppe.proj_element_id = ppst.proj_element_id
         and ppst.structure_type_id = pst.structure_type_id
         and pst.structure_type_class_code = 'WORKPLAN';

    CURSOR get_tasks (c_structure_id pa_proj_elements.proj_element_id%TYPE) IS
      SELECT ppev1.proj_element_id
        FROM pa_proj_element_versions ppev1,
             pa_proj_element_versions ppev2
       WHERE ppev2.object_type = 'PA_STRUCTURES'
         AND ppev2.project_id = p_project_id
         AND ppev2.proj_element_id = c_structure_id
         AND ppev1.parent_structure_version_id = ppev2.element_version_id
         AND ppev1.object_type = 'PA_TASKS';
      /*** Bug 3683382 modified the query for performance
      SELECT proj_element_id
        from pa_proj_elements
       where project_id = p_project_id
         and object_type = 'PA_TASKS'
         and proj_element_id IN (
             select ppev1.proj_element_id
               from pa_proj_element_versions ppev1,
                    pa_proj_element_versions ppev2
              where ppev2.object_type = 'PA_STRUCTURES'
                and ppev2.project_id = p_project_id
                and ppev2.proj_element_id = c_structure_id
                and ppev1.parent_structure_version_id = ppev2.element_version_id);
       3683382 ***/

BEGIN
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function
 IF l_debug_mode = 'Y' THEN
    pa_debug.set_curr_function(
                p_function   =>'PA_FIN_PLAN_UTILS.IS_WP_RL_UPDATEABLE'
               ,p_debug_mode => l_debug_mode );
END IF;

    IF (p_project_id IS NULL)
    THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Project_id = '|| p_project_id;
           pa_debug.write('IS_WP_RL_UPDATEABLE: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- Check if versioning is enabled or not
    l_is_versioning_enabled :=
            PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(p_project_id);

    IF l_is_versioning_enabled = 'Y' THEN

        -- If published version exists then res list update is not allowed
        IF ('Y' = PA_PROJ_TASK_STRUC_PUB.Published_version_exists(p_project_id))
        THEN
            x_wp_rl_update_allowed_flag  :=  'N';
            x_reason_msg_code := 'PA_FP_PRL_PUBLISHED_VER_EXISTS';
        ELSE
            -- publised version does not exist
            -- for a versioning enabled case, progress can be entered only after publish
            x_wp_rl_update_allowed_flag  :=  'Y';
            x_reason_msg_code :=  null;
        END IF;

    ELSE -- versioning disabled structure

        -- Check if progress exists against project or any task
        l_progress_exists := 'N'; -- initialise to 'N'

        -- Fetch workplan structure id
        OPEN get_wp_id;
        FETCH get_wp_id into l_structure_id;
        CLOSE get_wp_id;

        IF (PA_PROJECT_STRUCTURE_UTILS.check_proj_progress_exist
                (p_project_id, l_structure_id, 'WORKPLAN') = 'Y')    -- Added a new parameter while calling 'check_proj_progress_exist' for the BUG 6914708
        THEN
            l_progress_exists := 'Y';
        ELSE
             OPEN get_tasks(l_structure_id);
             LOOP
               FETCH get_tasks INTO l_task_id;
               EXIT WHEN get_tasks%NOTFOUND;

               IF (PA_PROJECT_STRUCTURE_UTILS.check_task_progress_exist(l_task_id) = 'Y')
               THEN
                 l_progress_exists := 'Y';
                 EXIT;
               END IF;
             END LOOP;
             CLOSE get_tasks;
        END IF;

        IF l_progress_exists ='Y' THEN

             -- Progress exists and hence resource list cannot be changed
             x_wp_rl_update_allowed_flag  :=  'N';
             x_reason_msg_code :=  'PA_FP_PRL_PROGRESS_EXISTS_ERR';

        ELSE -- Progress does not exist

             x_wp_rl_update_allowed_flag  :=  'Y';
             x_reason_msg_code :=  null;

        END IF;     -- progress
    END IF; -- versioning

    -- reset curr function
 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.reset_curr_function();
END IF;
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

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
           pa_debug.write('IS_WP_RL_UPDATEABLE: ' || l_module_name,pa_debug.g_err_stage,5);

       -- reset curr function
           pa_debug.reset_curr_function();
	END IF;
       RETURN;
   WHEN Others THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                               ,p_procedure_name  => 'IS_WP_RL_UPDATEABLE');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('IS_WP_RL_UPDATEABLE: ' || l_module_name,pa_debug.g_err_stage,5);
       -- reset curr function
           pa_debug.Reset_Curr_Function();
	END IF;
       RAISE;

END IS_WP_RL_UPDATEABLE;

/*=============================================================================
This api checks if any plan type marked for primary forecast cost usage has been
attached to the project and returns id of that plan type if found. Else null
would be returned
==============================================================================*/

PROCEDURE IS_PRI_FCST_COST_PT_ATTACHED(
          p_project_id     IN   pa_projects_all.project_id%TYPE
          ,x_plan_type_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count     OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data      OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

    --Start of variables used for debugging

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER := 0;
    l_msg_data           VARCHAR2(2000);
    l_data               VARCHAR2(2000);
    l_msg_index_out      NUMBER;
    l_debug_mode         VARCHAR2(30);

    --End of variables used for debugging

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function
 IF l_debug_mode = 'Y' THEN
    pa_debug.set_curr_function(
                p_function   =>'PA_FIN_PLAN_UTILS.IS_PRI_FCST_COST_PT_ATTACHED'
               ,p_debug_mode => l_debug_mode );

    -- Check for business rules violations

        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write('IS_PRI_FCST_COST_PT_ATTACHED: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL)
    THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Project_id = '||p_project_id;
           pa_debug.write('IS_PRI_FCST_COST_PT_ATTACHED: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    BEGIN
        SELECT fin_plan_type_id
        INTO   x_plan_type_id
        FROM   pa_proj_fp_options
        WHERE  project_id = p_project_id
          AND  fin_plan_option_level_code = 'PLAN_TYPE'
          AND  nvl(primary_cost_forecast_flag,'N') = 'Y' ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_plan_type_id := null;
    END;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting IS_PRI_FCST_COST_PT_ATTACHED';
        pa_debug.write('IS_PRI_FCST_COST_PT_ATTACHED: ' || l_module_name,pa_debug.g_err_stage,3);
       -- reset curr function
       pa_debug.reset_curr_function();
    END IF;
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

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
           pa_debug.write('IS_PRI_FCST_COST_PT_ATTACHED: ' || l_module_name,pa_debug.g_err_stage,5);
       -- reset curr function
          pa_debug.reset_curr_function();
	END IF;
       RETURN;
   WHEN Others THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                               ,p_procedure_name  => 'IS_PRI_FCST_COST_PT_ATTACHED');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('IS_PRI_FCST_COST_PT_ATTACHED: ' || l_module_name,pa_debug.g_err_stage,5);
       -- reset curr function
          pa_debug.Reset_Curr_Function();
	END IF;
       RAISE;
END IS_PRI_FCST_COST_PT_ATTACHED;

/*=============================================================================
This api checks if any plan type marked for primary forecast revenue usage has
been attached to the project and returns id of that plan type if found. Else null
would be returned
==============================================================================*/

PROCEDURE IS_PRI_FCST_REV_PT_ATTACHED(
          p_project_id     IN   pa_projects_all.project_id%TYPE
          ,x_plan_type_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count     OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data      OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

    --Start of variables used for debugging

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER := 0;
    l_msg_data           VARCHAR2(2000);
    l_data               VARCHAR2(2000);
    l_msg_index_out      NUMBER;
    l_debug_mode         VARCHAR2(30);

    --End of variables used for debugging

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function
 IF l_debug_mode = 'Y' THEN
    pa_debug.set_curr_function(
                p_function   =>'PA_FIN_PLAN_UTILS.IS_PRI_FCST_REV_PT_ATTACHED'
               ,p_debug_mode => l_debug_mode );

    -- Check for business rules violations
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write('IS_PRI_FCST_REV_PT_ATTACHED: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL)
    THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Project_id = '||p_project_id;
           pa_debug.write('IS_PRI_FCST_REV_PT_ATTACHED: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    BEGIN
        SELECT fin_plan_type_id
        INTO   x_plan_type_id
        FROM   pa_proj_fp_options
        WHERE  project_id = p_project_id
        AND    fin_plan_option_level_code = 'PLAN_TYPE'
        AND    nvl(primary_rev_forecast_flag,'N') = 'Y' ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_plan_type_id := null;
    END;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting IS_PRI_FCST_REV_PT_ATTACHED';
        pa_debug.write('IS_PRI_FCST_REV_PT_ATTACHED: ' || l_module_name,pa_debug.g_err_stage,3);
    -- reset curr function
       pa_debug.reset_curr_function();
   END IF;
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

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
           pa_debug.write('IS_PRI_FCST_REV_PT_ATTACHED: ' || l_module_name,pa_debug.g_err_stage,5);
       -- reset curr function
          pa_debug.reset_curr_function();
       END IF;
       RETURN;
   WHEN Others THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                               ,p_procedure_name  => 'IS_PRI_FCST_REV_PT_ATTACHED');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('IS_PRI_FCST_REV_PT_ATTACHED: ' || l_module_name,pa_debug.g_err_stage,5);
       -- reset curr function
         pa_debug.Reset_Curr_Function();
       END IF;
       RAISE;
END IS_PRI_FCST_REV_PT_ATTACHED;

FUNCTION is_wp_resource_list
         (p_project_id       IN   pa_projects_all.project_id%TYPE
         ,p_resource_list_id IN
pa_resource_lists_all_bg.resource_list_id%TYPE) RETURN VARCHAR2 IS
l_wp_resource_list_flag VARCHAR2(1);
BEGIN
     BEGIN
          select  'Y'
          into    l_wp_resource_list_flag
          from    dual
          where   exists (select 'x'
                          from   pa_proj_fp_options a, pa_fin_plan_types_b b
                          where  a.project_id = p_project_id
                          and    a.fin_plan_option_level_code <> 'PROJECT'
                          and    a.fin_plan_type_id = b.fin_plan_type_id
                          and    (a.cost_resource_list_id = p_resource_list_id or
                                 a.revenue_resource_list_id = p_resource_list_id or
                                 a.all_resource_list_id = p_resource_list_id)
                          and    b.use_for_workplan_flag = 'Y');
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
               l_wp_resource_list_flag := 'N';
     END;
     return l_wp_resource_list_flag;
END is_wp_resource_list;

FUNCTION is_fp_resource_list
         (p_project_id       IN   pa_projects_all.project_id%TYPE
         ,p_resource_list_id IN pa_resource_lists_all_bg.resource_list_id%TYPE)
RETURN VARCHAR2 IS
l_fp_resource_list_flag VARCHAR2(1);
BEGIN
     BEGIN
          select  'Y'
          into    l_fp_resource_list_flag
          from    dual
          where   exists (select 'x'
                          from   pa_proj_fp_options a
                          where  a.project_id = p_project_id
                          and    not exists (select 'x'
                                             from   pa_fin_plan_types_b b
                                             where  a.fin_plan_type_id = b.fin_plan_type_id
                                             and    b.use_for_workplan_flag = 'Y')
                          and    (a.cost_resource_list_id = p_resource_list_id or
                                  a.revenue_resource_list_id = p_resource_list_id or
                                  a.all_resource_list_id = p_resource_list_id));
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
               l_fp_resource_list_flag := 'N';
     END;
     return l_fp_resource_list_flag;
END is_fp_resource_list;

/* Returns the current working version ids for a given plan type.
   Returns -1 if the plan type cannot have a version of that version type
   Returns NULL if no working version exists for the plan type*/

PROCEDURE GET_CURR_WORKING_VERSION_IDS(P_fin_plan_type_id         IN       Pa_fin_plan_types_b.fin_plan_type_id%TYPE       -- Id of the plan types
                                      ,P_project_id               IN       Pa_budget_versions.project_id%TYPE         -- Id of the Project
                                      ,X_cost_budget_version_id   OUT      NOCOPY Pa_budget_versions.budget_version_id%TYPE  -- ID of the cost version associated with the CI --File.Sql.39 bug 4440895
                                      ,X_rev_budget_version_id    OUT      NOCOPY Pa_budget_versions.budget_version_id%TYPE  -- ID of the revenue version associated with the CI --File.Sql.39 bug 4440895
                                      ,X_all_budget_version_id    OUT      NOCOPY Pa_budget_versions.budget_version_id%TYPE  -- ID of the all version associated with the CI --File.Sql.39 bug 4440895
                                      ,x_return_status            OUT      NOCOPY VARCHAR2  -- Indicates the exit status of the API --File.Sql.39 bug 4440895
                                      ,x_msg_data                 OUT      NOCOPY VARCHAR2  -- Indicates the error occurred --File.Sql.39 bug 4440895
                                      ,X_msg_count                OUT      NOCOPY NUMBER)   -- Indicates the number of error messages --File.Sql.39 bug 4440895
IS
     l_plan_pref_code  pa_proj_fp_options.fin_plan_preference_code%TYPE;
     l_fp_options_id   pa_proj_fp_options.proj_fp_options_id%TYPE;

     -- Start of variables used for debugging purpose

      l_msg_count          NUMBER :=0;
      l_data               VARCHAR2(2000);
      l_msg_data           VARCHAR2(2000);
      l_msg_index_out      NUMBER;
      l_return_status      VARCHAR2(2000);
      l_debug_mode         VARCHAR2(1);
      l_debug_level3       CONSTANT NUMBER := 3;
      l_debug_level5       CONSTANT NUMBER := 5;
      l_mod_name           VARCHAR2(100) := l_module_name || '.GET_CURR_WORKING_VERSION_IDS'  ;
      l_token_name         VARCHAR2(30) :='PROCEDURENAME';

    -- End of variables used for debugging purpose

BEGIN

     IF l_debug_mode = 'Y' THEN
     pa_debug.set_curr_function( p_function   => 'GET_CURR_WORKING_VERSION_IDS',
                                     p_debug_mode => P_PA_debug_mode );
     END IF;

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Validate that the input parameters are not null
     IF P_fin_plan_type_id IS NULL OR P_project_id IS NULL THEN
          IF P_PA_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='fin_plan_type_id = '||p_fin_plan_type_id;
              pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);

              pa_debug.g_err_stage:='project_id = '||p_project_id;
              pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);

          END IF;


          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name      => 'PA_FP_INV_PARAM_PASSED',
                               p_token1 => l_token_name,
                               p_value1 => l_mod_name);


          IF P_PA_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Invalid Arguments Passed';
              pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

     IF P_PA_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Entering GET_CURR_WORKING_VERSION_IDS';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

     BEGIN
          SELECT  fin_plan_preference_code
          INTO    l_plan_pref_code
          FROM    pa_proj_fp_options
          WHERE   fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE
          AND     project_id = p_project_id
          AND     fin_plan_type_id = p_fin_plan_type_id;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
               IF P_PA_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='No data found while getting fin_plan_preference_code ';
                    pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END;

     X_cost_budget_version_id := -1;
     X_rev_budget_version_id  := -1;
     X_all_budget_version_id  := -1;

     -- Get_Curr_Working_Version_Info returns NULL if there is no working version of that version type
     If l_plan_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY  OR
        l_plan_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP  then
          PA_FIN_PLAN_UTILS.Get_Curr_Working_Version_Info(p_project_id           =>  p_project_id
                                                         ,p_fin_plan_type_id     =>  p_fin_plan_type_id
                                                         ,p_version_type         =>  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST
                                                         ,x_fp_options_id        =>  l_fp_options_id
                                                         ,x_fin_plan_version_id  =>  X_cost_budget_version_id
                                                         ,x_return_status        =>  l_return_status
                                                         ,x_msg_count            =>  l_msg_count
                                                         ,x_msg_data             =>  l_msg_data);

          IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                IF P_PA_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'Error in Get_Curr_Working_Version_Info: COST context';
                     pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
                END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
     END IF;
     If l_plan_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY  OR
           l_plan_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP  then
          PA_FIN_PLAN_UTILS.Get_Curr_Working_Version_Info(p_project_id           =>  p_project_id
                                                         ,p_fin_plan_type_id     =>  p_fin_plan_type_id
                                                         ,p_version_type         =>  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
                                                         ,x_fp_options_id        =>  l_fp_options_id
                                                         ,x_fin_plan_version_id  =>  X_rev_budget_version_id
                                                         ,x_return_status        =>  l_return_status
                                                         ,x_msg_count            =>  l_msg_count
                                                         ,x_msg_data             =>  l_msg_data);
          IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                IF P_PA_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'Error in Get_Curr_Working_Version_Info: REV context';
                     pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
                END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
     END IF;
     If l_plan_pref_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME    then
          PA_FIN_PLAN_UTILS.Get_Curr_Working_Version_Info(p_project_id           =>  p_project_id
                                                         ,p_fin_plan_type_id     =>  p_fin_plan_type_id
                                                         ,p_version_type         =>  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL
                                                         ,x_fp_options_id        =>  l_fp_options_id
                                                         ,x_fin_plan_version_id  =>  x_all_budget_version_id
                                                         ,x_return_status        =>  l_return_status
                                                         ,x_msg_count            =>  l_msg_count
                                                         ,x_msg_data             =>  l_msg_data);

          IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                IF P_PA_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'Error in Get_Curr_Working_Version_Info: ALL context';
                     pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
                END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;


     END IF;

     IF P_PA_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:= 'Exiting GET_CURR_WORKING_VERSION_IDS';
                 pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
            pa_debug.reset_curr_function;
     END IF;
EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
          l_msg_count := FND_MSG_PUB.count_msg;

          IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
	 IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.reset_curr_function;
	END IF;
           RETURN;

     WHEN Others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FIN_PLAN_UTILS'
                                  ,p_procedure_name  => 'GET_CURR_WORKING_VERSION_IDS');
          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
               pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
          pa_debug.reset_curr_function;
	END IF;
          RAISE;

END GET_CURR_WORKING_VERSION_IDS;


/* Returns the various OUT parameters for the current working version(s) OR
   for a change order

   Depending upon the value of p_version_type  labor/equipement hours either from the cost version or revenue version
   will be returned.Valid values are NULL, 'COST', 'REVENUE' AND 'ALL'. If p_version_type is null labor/equipment hours will be
   returned from the cost version. For bug 3662077
*/
-- Added New Params for Quantity in GET_PROJ_IMPACT_AMOUNTS - Bug 3902176

-- p_version parameter was earlier used to retieve the cost or revenue or all quantity figures.
-- Since cost and revenue quantity figures are now both alreayd being retrieved and are passed
-- in separate out params, p_version parameter is no longer required.
-- Commenting out references of p_version_type_below - Bug 3902176

PROCEDURE GET_PROJ_IMPACT_AMOUNTS(p_cost_budget_version_id  IN   Pa_budget_versions.budget_version_id%TYPE            --  ID of the cost version associated with the CI
                                 ,p_rev_budget_version_id   IN   Pa_budget_versions.budget_version_id%TYPE            --  ID of the revenue version associated with the CI
                                 ,p_all_budget_version_id   IN   Pa_budget_versions.budget_version_id%TYPE            --  ID of the all version associated with the CI
--                                 ,p_version_type            IN   pa_budget_versions.version_type%TYPE
                                 ,X_proj_raw_cost           OUT  NOCOPY Pa_budget_versions.total_project_raw_cost%TYPE       --  Raw Cost in PC --File.Sql.39 bug 4440895
                                 ,X_proj_burdened_cost      OUT  NOCOPY Pa_budget_versions.total_project_burdened_cost%TYPE  --  Burdened Cost in PC --File.Sql.39 bug 4440895
                                 ,X_proj_revenue            OUT  NOCOPY Pa_budget_versions.total_project_revenue%TYPE        --  Revenue in PC --File.Sql.39 bug 4440895
                                 ,X_labor_hrs_cost          OUT  NOCOPY Pa_budget_versions.labor_quantity%TYPE               --  Labor Hours Cost --File.Sql.39 bug 4440895
                                 ,X_equipment_hrs_cost      OUT  NOCOPY Pa_budget_versions.equipment_quantity%TYPE           --  Equipment Hours Cost --File.Sql.39 bug 4440895
                                 ,X_labor_hrs_rev           OUT  NOCOPY Pa_budget_versions.labor_quantity%TYPE               --  Labor Hours Revenue --File.Sql.39 bug 4440895
                                 ,X_equipment_hrs_rev       OUT  NOCOPY Pa_budget_versions.equipment_quantity%TYPE           --  Equipment Hours Revenue --File.Sql.39 bug 4440895
                                 ,X_margin                  OUT  NOCOPY Number                                               --  Margin --File.Sql.39 bug 4440895
                                 ,X_margin_percent          OUT  NOCOPY Number                                               --  Margin percent --File.Sql.39 bug 4440895
                                 ,X_margin_derived_from_code OUT  NOCOPY pa_proj_fp_options.margin_derived_from_code%TYPE     --  margin_derived_from_code - Bug 3734840 --File.Sql.39 bug 4440895
                                 ,x_return_status           OUT  NOCOPY VARCHAR2                                             --  Indicates the exit status of the API --File.Sql.39 bug 4440895
                                 ,x_msg_data                OUT  NOCOPY VARCHAR2                                             --  Indicates the error occurred --File.Sql.39 bug 4440895
                                 ,X_msg_count               OUT  NOCOPY NUMBER)                                              --  Indicates the number of error messages --File.Sql.39 bug 4440895
IS
l_margin_derived_from_code    pa_proj_fp_options.margin_derived_from_code%TYPE;
l_budget_version_id           Pa_budget_versions.budget_version_id%TYPE;

-- Start of variables used for debugging purpose

      l_msg_count          NUMBER :=0;
      l_data               VARCHAR2(2000);
      l_msg_data           VARCHAR2(2000);
      l_msg_index_out      NUMBER;
      l_return_status      VARCHAR2(2000);
      l_debug_mode         VARCHAR2(1);
      l_debug_level3       CONSTANT NUMBER := 3;
      l_debug_level5       CONSTANT NUMBER := 5;
      l_mod_name           VARCHAR2(100) := l_module_name || '.GET_PROJ_IMPACT_AMOUNTS' ;
      l_token_name         VARCHAR2(30) :='PROCEDURENAME';

-- End of variables used for debugging purpose


BEGIN

  IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_curr_function( p_function   => 'GET_PROJ_IMPACT_AMOUNTS',
                                     p_debug_mode => P_PA_debug_mode );
END IF;
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- See if all the input parameters passed are invalid
    IF nvl(p_all_budget_version_id,-1) = -1 AND nvl(p_cost_budget_version_id,-1) = -1
    AND nvl(p_rev_budget_version_id,-1) = -1 THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Invalid Arguments Passed';
               pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;


         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                p_msg_name      => 'PA_FP_INV_PARAM_PASSED',
                                p_token1 => l_token_name,
                                p_value1 => l_mod_name);

         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;


-- Bug 3902176
/*
     --p_version_type should be either COST or REVENUE if not null
     IF p_version_type IS NOT NULL AND
        p_version_type NOT IN ('COST', 'REVENUE','ALL') THEN

        IF P_PA_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_version_type = '||p_version_type;
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;


         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name      => 'PA_FP_INV_PARAM_PASSED',
                            p_token1 => l_token_name,
                            p_value1 => l_mod_name);


         IF P_PA_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Invalid Arguments Passed';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;
*/

    IF P_PA_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Entering GET_PROJ_IMPACT_AMOUNTS';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    /* l_budget_version_id is used to get margin_derived_from_code.
       This is derived if an 'ALL' version exists or if both 'cost' and revenue' versions exist because
       margin has a meaning only in these two cases*/
    IF nvl(p_all_budget_version_id,-1) <> -1 THEN
         l_budget_version_id := p_all_budget_version_id;
    ELSIF nvl(p_cost_budget_version_id,-1) <> -1 AND nvl(p_rev_budget_version_id,-1) <> -1 THEN
         l_budget_version_id := p_cost_budget_version_id;
    END IF;

    IF l_budget_version_id IS NOT NULL THEN
         BEGIN
               SELECT    nvl(pfo.margin_derived_from_code,'B')
               INTO      l_margin_derived_from_code
               FROM      pa_proj_fp_options pfo
               WHERE     pfo.fin_plan_version_id=l_budget_version_id ;
         EXCEPTION
              WHEN NO_DATA_FOUND THEN
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.g_err_stage:='No Data Found while fetching margin_derived_from_code';
                          pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
                     END IF;
                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END;
    END IF;

    x_margin_derived_from_code := l_margin_derived_from_code; -- Bug 3734840

    X_proj_raw_cost      := NULL;
    X_proj_burdened_cost := NULL;
    X_proj_revenue       := NULL;
    X_labor_hrs_cost     := NULL;
    X_equipment_hrs_cost := NULL;
    X_labor_hrs_rev      := NULL;
    X_equipment_hrs_rev  := NULL;
    X_margin             := NULL;
    X_margin_percent     := NULL;

 -- Modified Sqls Below for 3902176.
 -- Please note that for a ALL Version, x_xxxx_hrs_cost and x_xxxx_hrs_rev will contain the same figures
 -- of the ALL version. However all code will use x_xxxx_hrs_cost figures for ALL version references.

        IF NVL(p_cost_budget_version_id,-1) <> -1 or NVL(p_all_budget_version_id,-1) <> -1 THEN
             BEGIN
                SELECT    labor_quantity,
                          Equipment_quantity,
                          Total_project_raw_cost,
                          Total_project_burdened_cost
                INTO      x_labor_hrs_cost,
                          x_equipment_hrs_cost,
                          x_proj_raw_cost,
                          x_proj_burdened_cost
                FROM      pa_budget_versions
                WHERE     budget_version_id = decode(nvl(p_cost_budget_version_id,-1),-1,p_all_budget_version_id,p_cost_budget_version_id);
             EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                               IF P_PA_DEBUG_MODE = 'Y' THEN
                                   pa_debug.g_err_stage:='No data found while fetching quantity and amounts. Context: Cost/All version type';
                                   pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
                               END IF;
                               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END;
        END IF;
        IF NVL(p_rev_budget_version_id,-1) <> -1 or NVL(p_all_budget_version_id,-1) <> -1 THEN
             BEGIN
                     SELECT    labor_quantity,
                               Equipment_quantity,
                               Total_project_revenue
                     INTO      x_labor_hrs_rev,
                               x_equipment_hrs_rev,
                               x_proj_revenue
                     FROM      pa_budget_versions
                     WHERE     budget_version_id = decode(nvl(p_rev_budget_version_id,-1),-1,p_all_budget_version_id,p_rev_budget_version_id);
             EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                               IF P_PA_DEBUG_MODE = 'Y' THEN
                                   pa_debug.g_err_stage:='No data found while fetching quantity and amounts. Context: Rev/All version type';
                                   pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
                               END IF;
                               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END;
         END IF;

-- Bug 3902176.
-- Below code-logic for deriving quantity is not required anymore as both Cost and Revenue Quantity
-- are now being derived and passed as separate params.
/*
     --If the verison type passed is REVENUE then the labor/equipment hours should be derived from the REVENUE version
     --Otherwise cost labor/equipement hours will be returned if exist and revenue labor/equipment hours will be
     --returned if cost labor/equipement hours do not exist. Bug 3662077
     IF p_version_type='REVENUE' THEN

        x_labor_hrs := l_labor_hrs;
        x_equipment_hrs := l_equipment_hrs;

     ELSIF NVL(p_cost_budget_version_id,-1) = -1 AND NVL(p_all_budget_version_id,-1) = -1  THEN
        x_labor_hrs := l_labor_hrs;
        x_equipment_hrs := l_equipment_hrs;
     END IF;
*/

    IF l_budget_version_id IS NOT NULL THEN
         IF l_margin_derived_from_code = PA_FP_CONSTANTS_PKG.G_MARGIN_DERIVED_FROM_CODE_R THEN
              x_margin := nvl(x_proj_revenue,0) - nvl(x_proj_raw_cost,0);
         ELSE
              x_margin := nvl(x_proj_revenue,0) - nvl(x_proj_burdened_cost,0);
         END IF;

         IF x_proj_revenue IS NULL or x_proj_revenue = 0 THEN
              x_margin_percent := x_proj_revenue;
         ELSE
              x_margin_percent := (x_margin/x_proj_revenue)*100;
         END IF;
    END IF;


    IF P_PA_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Exiting GET_PROJ_IMPACT_AMOUNTS';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
    pa_debug.reset_curr_function;
    END IF;
EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
          l_msg_count := FND_MSG_PUB.count_msg;

          IF l_msg_count = 1 and x_msg_data IS NULL THEN
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

 IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.reset_curr_function;
END IF;
           RETURN;

     WHEN Others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FIN_PLAN_UTILS'
                                  ,p_procedure_name  => 'GET_PROJ_IMPACT_AMOUNTS');
          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
               pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
          pa_debug.reset_curr_function;
	END IF;
          RAISE;


END GET_PROJ_IMPACT_AMOUNTS;


/* PROCEDURE GET_SUMMARY_AMOUNTS
   -----------------------------
   Mandatory input parameters: 1. p_context,p_project_id and p_ci_id
                                         OR
                               2. p_context,p_project_id and p_fin_plan_type_id

   Valid values for p_context: 1. PA_FP_CONSTANTS_PKG.G_CI_VERSION_AMOUNTS. (In this case p_ci_id has to be passed)
                               2. PA_FP_CONSTANTS_PKG.G_PLAN_TYPE_CWV_AMOUNTS. (In this case p_fin_plan_type_id has to be passed)

   Depending on the value of p_context, the API returns the OUT parameters with respect to either the CI versions of the passed ci_id
   or the current working version of the fin_plan_type_id in the context of a project (p_project_id)

   Depending upon the value of p_version_type  labor/equipement hours either from the cost version or revenue version
   will be returned.Valid values are NULL, 'COST', 'REVENUE' AND 'ALL'. If p_version_type is null labor/equipment hours will be
   returned from the cost version. For bug 3662077*/

-- Added New Params for Quantity in Get_Summary_Amounts - Bug 3902176

-- p_version parameter was earlier used to retieve the cost or revenue or all quantity figures.
-- Since cost and revenue quantity figures are now both alreayd being retrieved and are passed
-- in separate out params, p_version parameter is no longer required.
-- Commenting out references of p_version_type_below - Bug 3902176

PROCEDURE GET_SUMMARY_AMOUNTS(p_context                 IN              VARCHAR2
                             ,P_project_id              IN              Pa_projects_all.project_id%TYPE                           --  Id of the project .
                             ,P_ci_id                   IN              Pa_budget_versions.ci_id%TYPE  DEFAULT  NULL              --  Controm item id of the change document
                             ,P_fin_plan_type_id        IN              Pa_fin_plan_types_b.fin_plan_type_id%TYPE  DEFAULT  NULL
--                             ,p_version_type            IN              pa_budget_versions.version_type%TYPE
                             ,X_proj_raw_cost           OUT             NOCOPY Pa_budget_versions.total_project_raw_cost%TYPE            --  Raw Cost in PC --File.Sql.39 bug 4440895
                             ,X_proj_burdened_cost      OUT             NOCOPY Pa_budget_versions.total_project_burdened_cost%TYPE       --  Burdened Cost in PC --File.Sql.39 bug 4440895
                             ,X_proj_revenue            OUT             NOCOPY Pa_budget_versions.total_project_revenue%TYPE             --  Revenue in PC --File.Sql.39 bug 4440895
                             ,X_margin                  OUT             NOCOPY NUMBER                                                    --  MARGIN --File.Sql.39 bug 4440895
                             ,X_margin_percent          OUT             NOCOPY NUMBER                                                    --  MARGIN percent --File.Sql.39 bug 4440895
                             ,X_labor_hrs_cost          OUT             NOCOPY Pa_budget_versions.labor_quantity%TYPE                    --  Labor Hours Cost --File.Sql.39 bug 4440895
                             ,X_equipment_hrs_cost      OUT             NOCOPY Pa_budget_versions.equipment_quantity%TYPE                --  Equipment Hours Cost --File.Sql.39 bug 4440895
                             ,X_labor_hrs_rev           OUT             NOCOPY Pa_budget_versions.labor_quantity%TYPE                    --  Labor Hours Revenue --File.Sql.39 bug 4440895
                             ,X_equipment_hrs_rev       OUT             NOCOPY Pa_budget_versions.equipment_quantity%TYPE                --  Equipment Hours Revenue --File.Sql.39 bug 4440895
                             ,X_cost_budget_version_id  OUT             NOCOPY Pa_budget_versions.budget_version_id%TYPE                 --  Cost Budget Verison Id --File.Sql.39 bug 4440895
                             ,X_rev_budget_version_id   OUT             NOCOPY Pa_budget_versions.budget_version_id%TYPE                 --  Revenue Budget Verison Id --File.Sql.39 bug 4440895
                             ,X_all_budget_version_id   OUT             NOCOPY Pa_budget_versions.budget_version_id%TYPE                 --  All Budget Verison Id --File.Sql.39 bug 4440895
                             ,X_margin_derived_from_code OUT             NOCOPY pa_proj_fp_options.margin_derived_from_code%TYPE          --  margin_derived_from_code of cost version - Bug 3734840 --File.Sql.39 bug 4440895
                             ,x_return_status           OUT             NOCOPY VARCHAR2                                                  --  Indicates the exit status of the API --File.Sql.39 bug 4440895
                             ,x_msg_data                OUT             NOCOPY VARCHAR2                                                  --  Indicates the error occurred --File.Sql.39 bug 4440895
                             ,X_msg_count               OUT             NOCOPY NUMBER)                                                   --  Indicates the number of error messages --File.Sql.39 bug 4440895
IS
     -- Start of variables used for debugging purpose

      l_msg_count          NUMBER :=0;
      l_data               VARCHAR2(2000);
      l_msg_data           VARCHAR2(2000);
      l_msg_index_out      NUMBER;
      l_return_status      VARCHAR2(2000);
      l_debug_mode         VARCHAR2(1);
      l_debug_level3       CONSTANT NUMBER := 3;
      l_debug_level5       CONSTANT NUMBER := 5;
      l_mod_name           VARCHAR2(100) := l_module_name || '.GET_SUMMARY_AMOUNTS' ;
      l_token_name         VARCHAR2(30) :='PROCEDURENAME';

      -- End of variables used for debugging purpose

BEGIN

 IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.set_curr_function( p_function   => 'GET_SUMMARY_AMOUNTS',
                                 p_debug_mode => P_PA_debug_mode );
END IF;
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Check for business rules violations

     IF P_PA_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='Validating input parameters';
         pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     -- Check if p_context or project id is NULL
     IF p_context IS NULL OR p_project_id IS NULL THEN

          IF P_PA_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Ci_id = '||p_ci_id;
              pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

              pa_debug.g_err_stage:='project_id = '||p_project_id;
              pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

          END IF;


          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name      => 'PA_FP_INV_PARAM_PASSED',
                               p_token1 => l_token_name,
                               p_value1 => l_mod_name);


          IF P_PA_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Invalid Arguments Passed';
              pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
          END IF;
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;


-- Bug 3902176 -- p_version_type is not passed anymore
/*
     --p_version_type should be either COST or REVENUE if not null
     IF p_version_type IS NOT NULL AND
        p_version_type NOT IN ('COST', 'REVENUE','ALL') THEN

        IF P_PA_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Ci_id = '||p_ci_id;
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

            pa_debug.g_err_stage:='p_context = '||p_context;
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

         END IF;


         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name      => 'PA_FP_INV_PARAM_PASSED',
                            p_token1 => l_token_name,
                            p_value1 => l_mod_name);


         IF P_PA_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Invalid Arguments Passed';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;
*/


     -- Check if fin_plan_type_id and ci id are null

     IF p_context = PA_FP_CONSTANTS_PKG.G_CI_VERSION_AMOUNTS THEN
          IF (p_ci_id IS NULL)
          THEN

               IF P_PA_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Ci_id = '||p_ci_id;
                   pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

                   pa_debug.g_err_stage:='p_context = '||p_context;
                   pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

               END IF;


               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name      => 'PA_FP_INV_PARAM_PASSED',
                                    p_token1 => l_token_name,
                                    p_value1 => l_mod_name);


               IF P_PA_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Invalid Arguments Passed';
                   pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

          END IF;

      ELSIF p_context = PA_FP_CONSTANTS_PKG.G_PLAN_TYPE_CWV_AMOUNTS THEN
           IF (p_fin_plan_type_id IS NULL)
           THEN

               IF P_PA_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Fin_plan_type_id = '||p_fin_plan_type_id;
                   pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

                   pa_debug.g_err_stage:='p_context = '||p_context;
                   pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

               END IF;


               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name      => 'PA_FP_INV_PARAM_PASSED',
                                    p_token1 => l_token_name,
                                    p_value1 => l_mod_name);


               IF P_PA_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:='Invalid Arguments Passed';
                   pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
               END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;

      END IF;

      IF P_PA_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Entering GET_SUMMARY_AMOUNTS';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      IF p_context = PA_FP_CONSTANTS_PKG.G_CI_VERSION_AMOUNTS THEN
           Pa_Fp_Control_Items_Utils.GET_CI_VERSIONS(P_ci_id                  => p_ci_id,
                                                     X_cost_budget_version_id => x_cost_budget_version_id,
                                                     X_rev_budget_version_id  => x_rev_budget_version_id,
                                                     X_all_budget_version_id  => x_all_budget_version_id,
                                                     x_return_status          => l_return_status,
                                                     x_msg_data               => l_msg_data,
                                                     X_msg_count              => l_msg_count);

           IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                IF P_PA_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'Error in GET_CI_VERSIONS';
                     pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;

-- Added New Params for Quantity(Cost/Rev) in call to GET_PROJ_IMPACT_AMOUNTS - Bug 3902176
           PA_FIN_PLAN_UTILS.GET_PROJ_IMPACT_AMOUNTS(p_cost_budget_version_id => x_cost_budget_version_id
                                                    ,p_rev_budget_version_id  => x_rev_budget_version_id
                                                    ,p_all_budget_version_id  => x_all_budget_version_id
--                                                    ,p_version_type           => p_version_type  -- Bug 3902176
                                                    ,X_proj_raw_cost          => x_proj_raw_cost
                                                    ,X_proj_burdened_cost     => x_proj_burdened_cost
                                                    ,X_proj_revenue           => x_proj_revenue
                                                    ,x_labor_hrs_cost         => x_labor_hrs_cost
                                                    ,x_equipment_hrs_cost     => x_equipment_hrs_cost
                                                    ,x_labor_hrs_rev          => x_labor_hrs_rev
                                                    ,x_equipment_hrs_rev      => x_equipment_hrs_rev
                                                    ,X_margin                 => x_margin
                                                    ,X_margin_percent         => x_margin_percent
                                                    ,x_margin_derived_from_code => x_margin_derived_from_code -- Bug 3734840
                                                    ,x_return_status          => l_return_status
                                                    ,x_msg_data               => l_msg_data
                                                    ,X_msg_count              => l_msg_count);

           IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                IF P_PA_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'Error in GET_PROJ_IMPACT_AMOUNTS';
                     pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
                END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;
      ELSIF p_context = PA_FP_CONSTANTS_PKG.G_PLAN_TYPE_CWV_AMOUNTS THEN
            pa_fin_plan_utils.GET_CURR_WORKING_VERSION_IDS(P_fin_plan_type_id         => P_fin_plan_type_id
                                                          ,P_project_id               => p_project_id
                                                          ,X_cost_budget_version_id   => x_cost_budget_version_id
                                                          ,X_rev_budget_version_id    => x_rev_budget_version_id
                                                          ,X_all_budget_version_id    => x_all_budget_version_id
                                                          ,x_return_status            => l_return_status
                                                          ,x_msg_data                 => l_msg_data
                                                          ,X_msg_count                => l_msg_count);

            IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                IF P_PA_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'Error in GET_CURR_WORKING_VERSION_IDS';
                     pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
                END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

           --Get the project impact amounts only if the current working version exists. Bug 3661627
           IF nvl(x_all_budget_version_id,-1) <> -1 OR nvl(x_cost_budget_version_id,-1) <> -1
              OR nvl(x_rev_budget_version_id,-1) <> -1 THEN

-- Added New Params for Quantity(Cost/Rev) in call to GET_PROJ_IMPACT_AMOUNTS - Bug 3902176
                PA_FIN_PLAN_UTILS.GET_PROJ_IMPACT_AMOUNTS(p_cost_budget_version_id => x_cost_budget_version_id
                                                         ,p_rev_budget_version_id  => x_rev_budget_version_id
                                                         ,p_all_budget_version_id  => x_all_budget_version_id
--                                                         ,p_version_type           => p_version_type  -- Bug 3902176
                                                         ,X_proj_raw_cost          => x_proj_raw_cost
                                                         ,X_proj_burdened_cost     => x_proj_burdened_cost
                                                         ,X_proj_revenue           => x_proj_revenue
                                                         ,x_labor_hrs_cost         => x_labor_hrs_cost
                                                         ,x_equipment_hrs_cost     => x_equipment_hrs_cost
                                                         ,x_labor_hrs_rev          => x_labor_hrs_rev
                                                         ,x_equipment_hrs_rev      => x_equipment_hrs_rev
                                                         ,X_margin                 => x_margin
                                                         ,X_margin_percent         => x_margin_percent
                                                         ,x_margin_derived_from_code => x_margin_derived_from_code -- Bug 3734840
                                                         ,x_return_status          => l_return_status
                                                         ,x_msg_data               => l_msg_data
                                                         ,X_msg_count              => l_msg_count);

               IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                    IF P_PA_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Error in GET_PROJ_IMPACT_AMOUNTS';
                         pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
                    END IF;
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               END IF;
           END IF;
      END IF;


      IF P_PA_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Exiting GET_SUMMARY_AMOUNTS';
           pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

	      pa_debug.reset_curr_function;
	END IF;
EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
          l_msg_count := FND_MSG_PUB.count_msg;

          IF l_msg_count = 1 and x_msg_data IS NULL THEN
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

IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.reset_curr_function;
END IF;
           RETURN;

     WHEN Others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FIN_PLAN_UTILS'
                                  ,p_procedure_name  => 'GET_SUMMARY_AMOUNTS');
          IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
               pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
          pa_debug.reset_curr_function;
	END IF;
          RAISE;


END GET_SUMMARY_AMOUNTS;


/* Function returns 'Y' if budget version has budget lines with rejection code. */
FUNCTION does_bv_have_rej_lines(p_budget_version_id IN pa_budget_versions.budget_version_id%TYPE)
RETURN VARCHAR2
IS
   l_exists  varchar2(1) := 'N';
begin
    select 'Y'
    into  l_exists
    from  dual
    where exists
    (select 1
    from  pa_budget_lines
    where budget_version_id = p_budget_version_id
    and   (cost_rejection_code IS NOT NULL
    OR    revenue_rejection_code IS NOT NULL
    OR    burden_rejection_code IS NOT NULL
    OR    other_rejection_code IS NOT NULL
    OR    pc_cur_conv_rejection_code IS NOT NULL
    OR    pfc_cur_conv_rejection_code IS NOT NULL));

    return l_exists;

exception
    when no_data_found then
        return 'N';

end does_bv_have_rej_lines;

--------------------------------------------------------------------------------
-- This API is called during deleting a Rate Sch to check if the Rate Schedule
-- is being reference by any Plan Type or not.
-- In case if it is referenced then the 'N' is returned , or else 'Y' is returned
--------------------------------------------------------------------------------
FUNCTION check_delete_sch_ok(
         p_bill_rate_sch_id      IN   pa_std_bill_rate_schedules_all.bill_rate_sch_id%TYPE)
RETURN VARCHAR2 IS
  --Start of variables used for debugging
      l_debug_mode         VARCHAR2(30);
      l_debug_level3       CONSTANT NUMBER := 3;
      l_debug_level5       CONSTANT NUMBER := 5;
      l_mod_name           VARCHAR2(100) := l_module_name;
  --End of variables used for debugging

      l_delete_ok        VARCHAR2(1);

BEGIN

     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

  -- Input Paramter Validations
     IF P_PA_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='Validating input parameters';
         pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     IF (p_bill_rate_sch_id IS NULL)
     THEN
         IF P_PA_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='p_bill_rate_sch_id is NULL';
             pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
         END IF;
     END IF;

     BEGIN
      SELECT 'N'
        INTO l_delete_ok
        FROM DUAL
       WHERE EXISTS (SELECT 1
                       FROM PA_PROJ_FP_OPTIONS
                      WHERE RES_CLASS_RAW_COST_SCH_ID = p_bill_rate_sch_id OR
                            RES_CLASS_BILL_RATE_SCH_ID = p_bill_rate_sch_id OR
                            COST_EMP_RATE_SCH_ID = p_bill_rate_sch_id OR
                            COST_JOB_RATE_SCH_ID = p_bill_rate_sch_id OR
                            COST_NON_LABOR_RES_RATE_SCH_ID = p_bill_rate_sch_id OR
                            COST_RES_CLASS_RATE_SCH_ID = p_bill_rate_sch_id OR
                            REV_EMP_RATE_SCH_ID = p_bill_rate_sch_id OR
                            REV_JOB_RATE_SCH_ID = p_bill_rate_sch_id OR
                            REV_NON_LABOR_RES_RATE_SCH_ID = p_bill_rate_sch_id OR
                            REV_RES_CLASS_RATE_SCH_ID = p_bill_rate_sch_id);
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_delete_ok := 'Y';
     END;

    RETURN l_delete_ok;

END check_delete_sch_ok;
-----------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- This API is called during deleting a Burden Rate Sch to check if the Burden Rate
-- Schedule is being reference by any Plan Type or not.
-- In case if it is referenced then the 'N' is returned , or else 'Y' is returned
--------------------------------------------------------------------------------
FUNCTION check_delete_burd_sch_ok(
         p_ind_rate_sch_id      IN   pa_ind_rate_schedules_all_bg.ind_rate_sch_id%TYPE)
RETURN VARCHAR2
IS
  --Start of variables used for debugging
      l_debug_mode         VARCHAR2(30);
      l_debug_level3       CONSTANT NUMBER := 3;
      l_debug_level5       CONSTANT NUMBER := 5;
      l_mod_name           VARCHAR2(100) := l_module_name;
  --End of variables used for debugging

      l_delete_ok        VARCHAR2(1);

BEGIN

     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

  -- Input Paramter Validations
     IF P_PA_debug_mode = 'Y' THEN
         pa_debug.g_err_stage:='Validating input parameters';
         pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     IF (p_ind_rate_sch_id IS NULL)
     THEN
         IF P_PA_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='p_ind_rate_sch_id is NULL';
             pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
         END IF;
     END IF;

     BEGIN
      SELECT 'N'
        INTO l_delete_ok
        FROM DUAL
       WHERE EXISTS (SELECT 1
                       FROM PA_PROJ_FP_OPTIONS
                      WHERE COST_BURDEN_RATE_SCH_ID = p_ind_rate_sch_id);

     EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_delete_ok := 'Y';
     END;

    RETURN l_delete_ok;

END check_delete_burd_sch_ok;


/* -------------------------------------------------------------------------------------------
 * FUNCTION: Validate_Uncheck_MC_Flag
 * Function to check for the validity of the event of unchecking of 'Plan in Multi Currency'
 * check box in the 'Edit Planning Options' screen. This api is called just before committing
 * the changes done in the page and is called for both workplan and budgeting and forecasting
 * context and this is indicated by the value of input parameter p_context, for which the
 * valid values are 'WORKPLAN' and 'FINPLAN'. If the context is 'WORKPLAN' the input parameter
 * p_budget_version_id would be null. The api returns 'Y' if the event is valid and allowed
 * and returns 'N' otherwise.
 *--------------------------------------------------------------------------------------------*/
 FUNCTION Validate_Uncheck_MC_Flag (
              p_project_id             IN         pa_projects_all.project_id%TYPE,
              p_context                IN         VARCHAR2,
              p_budget_version_id      IN         pa_budget_versions.budget_version_id%TYPE)
 RETURN  VARCHAR2
 IS
      --Start of variables used for debugging
      l_debug_mode         VARCHAR2(30);
      l_debug_level2       CONSTANT NUMBER := 2;
      l_debug_level3       CONSTANT NUMBER := 3;
      l_debug_level5       CONSTANT NUMBER := 5;
      l_mod_name           VARCHAR2(100)   := l_module_name || ':Validate_Uncheck_MC_Flag';
      l_token_name         VARCHAR2(30) :='PROCEDURENAME';
      --End of variables used for debugging
      l_currency_code      VARCHAR2(30);
      is_valid_flag        VARCHAR2(30);

 BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.set_curr_function( p_function   => 'Validate_Uncheck_MC_Flag',
                                  p_debug_mode => P_PA_DEBUG_MODE );

            pa_debug.g_err_stage:='Entering Validate_Uncheck_MC_Flag';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level2);

      -- Checking, if the input parameters are null
            pa_debug.g_err_stage:='Validating Input Parameters';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      IF p_project_id IS NULL OR p_context IS NULL THEN
          IF P_PA_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='p_project_id = '||p_project_id;
              pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

              pa_debug.g_err_stage:='p_context = '||p_context;
              pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);

          END IF;

          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                               p_token1         => l_token_name,
                               p_value1         => l_mod_name);


          IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:='Invalid Arguments Passed';
                pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
                   pa_debug.reset_err_stack;
	END IF;
          RAISE INVALID_ARG_EXC;
      ELSE
            IF p_context = 'FINPLAN' AND p_budget_version_id IS NULL THEN
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                       p_token1         => l_token_name,
                                       p_value1         => l_mod_name);


                  IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.g_err_stage:='Invalid Arguments Passed';
                       pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
                           pa_debug.reset_err_stack;
		END IF;
                  RAISE INVALID_ARG_EXC;
            END IF;
      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Input Parameters validation done';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      -- Getting the project currency code
      IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Getting the project currency code';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      SELECT project_currency_code
      INTO   l_currency_code
      FROM   pa_projects_all
      WHERE  project_id = p_project_id;

      IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Project Currency Code: ' || l_currency_code;
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      IF p_context = 'WORKPLAN' THEN
            BEGIN
                  SELECT   'N'
                  INTO     is_valid_flag
                  FROM     dual
                  WHERE    EXISTS (SELECT   1
                                   FROM     pa_budget_versions bv,
                                            pa_budget_lines    bl
                                   WHERE    bv.project_id = p_project_id
                                   AND      bv.wp_version_flag = 'Y'
                                   AND      bv.budget_version_id = bl.budget_version_id
                                   AND      bl.txn_currency_code <> l_currency_code);
            EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                       is_valid_flag := 'Y';
            END;
      ELSIF p_context = 'FINPLAN' THEN
            BEGIN
                  SELECT   'N'
                  INTO     is_valid_flag
                  FROM     dual
                  WHERE    EXISTS (SELECT   1
                                   FROM     pa_budget_lines
                                   WHERE    budget_version_id = p_budget_version_id
                                   AND      txn_currency_code <> l_currency_code);
            EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                       is_valid_flag := 'Y';
            END;
      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Value returned: ' || is_valid_flag;
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level2);
      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Leaving Validate_Uncheck_MC_Flag';
            pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level2);
	      pa_debug.reset_curr_function;
	END IF;
      RETURN is_valid_flag;

 EXCEPTION
      WHEN OTHERS THEN
            FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                                    ,p_procedure_name  => 'Validate_Uncheck_MC_Flag');
            IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
                  pa_debug.write(l_mod_name,pa_debug.g_err_stage,l_debug_level5);
            pa_debug.reset_curr_function;
	END IF;
            RAISE;
 END Validate_Uncheck_MC_Flag;

/*=============================================================================
 This api is called to check if a txn currency can be deleted for an fp option.
 For workplan case,
    A txn currency can not be deleted if
      1. the currency is project currency or
      2. the currency is project functional currency or
      3. amounts exist against the currency in any of the workplan versions

  For Budgets and Forecasting case,
    A txn currency can not be deleted if
      1. the currency is project currency or
      2. the currency is project functional currency or
      3. option is a version and amounts exist against the currency
==============================================================================*/

FUNCTION Check_delete_txn_cur_ok(
          p_project_id            IN   pa_projects_all.project_id%TYPE
          ,p_context              IN   VARCHAR2 -- FINPLAN or WORKPLAN
          ,p_fin_plan_version_id  IN   pa_budget_versions.budget_version_id%TYPE
          ,p_txn_currency_code    IN   fnd_currencies.currency_code%TYPE
) RETURN VARCHAR2
IS
   l_delete_ok_flag     varchar2(1);

   CURSOR project_info_cur IS
     SELECT project_currency_code
            ,projfunc_currency_code
     FROM   pa_projects_all
     WHERE  project_id = p_project_id;
   project_info_rec  project_info_cur%ROWTYPE;
BEGIN
    -- Set curr function
 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_curr_function(
                p_function   =>'PA_FIN_PLAN_UTILS.Check_delete_txn_cur_ok'
               ,p_debug_mode => P_PA_DEBUG_MODE );

    -- Validate input parameters
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write('Check_delete_txn_cur_ok: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL) OR
       (p_context    IS NULL) OR
       (p_context = 'FINPLAN' AND nvl(p_fin_plan_version_id, -99) = -99) OR
       (p_txn_currency_code IS NULL)
    THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='p_project_id = '||p_project_id;
           pa_debug.write('Check_delete_txn_cur_ok: ' || l_module_name,pa_debug.g_err_stage,5);

           pa_debug.g_err_stage:='p_context = '||p_context;
           pa_debug.write('Check_delete_txn_cur_ok: ' || l_module_name,pa_debug.g_err_stage,5);

           pa_debug.g_err_stage:='p_fin_plan_version_id = '||p_fin_plan_version_id;
           pa_debug.write('Check_delete_txn_cur_ok: ' || l_module_name,pa_debug.g_err_stage,5);

           pa_debug.g_err_stage:='p_txn_currency_code = '||p_txn_currency_code;
           pa_debug.write('Check_delete_txn_cur_ok: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                              p_token1         => 'PROCEDURENAME',
                              p_value1         => 'PA_FIN_PLAN_UTILS.Check_delete_txn_cur_ok');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- Derive project and project funcional currencies
    OPEN project_info_cur;
    FETCH project_info_cur INTO
         project_info_rec;
    CLOSE project_info_cur;

    -- Initialising l_delete_ok_flag to 'Y'
    l_delete_ok_flag := 'Y';

    IF p_context = 'FINPLAN' THEN

         IF  p_txn_currency_code IN (project_info_rec.project_currency_code,
                                     project_info_rec.projfunc_currency_code)
         THEN
             l_delete_ok_flag := 'N';
         ELSE  -- Check if amounts exist against this currency
             BEGIN
                 SELECT 'N' INTO l_delete_ok_flag
                 FROM DUAL
                 WHERE EXISTS
                     ( select 1 from pa_budget_lines bl
                       where  bl.budget_version_id = p_fin_plan_version_id
                       and    bl.txn_currency_code = p_txn_currency_code
                     );
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      null;
             END;
         END IF;
    ELSIF p_context = 'WORKPLAN' THEN

         IF  p_txn_currency_code IN (project_info_rec.project_currency_code,
                                     project_info_rec.projfunc_currency_code)
         THEN
             l_delete_ok_flag := 'N';
         ELSE  -- Check if amounts exist against this currency
             BEGIN
                 SELECT 'N' INTO l_delete_ok_flag
                 FROM DUAL
                 WHERE EXISTS
                     ( select 1 from pa_budget_versions bv, pa_budget_lines bl
                       where  bv.project_id = p_project_id
                       and    bv.wp_version_flag = 'Y'
                       and    bl.budget_version_id = bv.budget_version_id
                       and    bl.txn_currency_code = p_txn_currency_code
                     );
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      null;
             END;
         END IF;

    END IF; -- p_context

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Exiting Check_delete_txn_cur_ok';
        pa_debug.write('Check_delete_txn_cur_ok: ' || l_module_name,pa_debug.g_err_stage,3);

    -- reset curr function
    pa_debug.reset_curr_function();
	END IF;
    RETURN l_delete_ok_flag;

EXCEPTION
   WHEN Others THEN

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                               ,p_procedure_name  => 'Check_delete_txn_cur_ok');

       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('Check_delete_txn_cur_ok: ' || l_module_name,pa_debug.g_err_stage,5);

       -- reset curr function
          pa_debug.Reset_Curr_Function();
	END IF;
       RAISE;
END Check_delete_txn_cur_ok;

/*=============================================================================
  This api is called to check if amounts exist for any of the workplan versions
  of the project in budgets data model.
==============================================================================*/

FUNCTION check_if_amounts_exist_for_wp(
           p_project_id           IN   pa_projects_all.project_id%TYPE
) RETURN VARCHAR2
IS
   l_amounts_exist_flag  VARCHAR2(1)  := 'N';
BEGIN
    -- Set curr function
 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_curr_function(
                p_function   =>'PA_FIN_PLAN_UTILS.check_if_amounts_exist_for_wp'
               ,p_debug_mode => P_PA_DEBUG_MODE );

    -- Validate input parameters

        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write('check_if_amounts_exist_for_wp: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL)
    THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='p_project_id = '||p_project_id;
           pa_debug.write('check_if_amounts_exist_for_wp: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                              p_token1         => 'PROCEDURENAME',
                              p_value1         => 'PA_FIN_PLAN_UTILS.check_if_amounts_exist_for_wp');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- Check if budget line exists for any of the workplan versions of the project
	Begin
        SELECT 'Y' INTO l_amounts_exist_flag
        FROM dual WHERE EXISTS
            (SELECT 1
             FROM   pa_budget_lines bl,
                    pa_budget_versions bv
             WHERE  bv.project_id = p_project_id
             AND    bv.wp_version_flag = 'Y'
             AND    bl.budget_version_id = bv.budget_version_id);
    Exception
       When no_data_found Then
           l_amounts_exist_flag := 'N';
    End;


    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Exiting check_if_amounts_exist_for_wp';
        pa_debug.write('check_if_amounts_exist_for_wp: ' || l_module_name,pa_debug.g_err_stage,3);

    -- reset curr function
    pa_debug.reset_curr_function();
    END IF;
    RETURN l_amounts_exist_flag;

EXCEPTION
   WHEN Others THEN

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                               ,p_procedure_name  => 'check_if_amounts_exist_for_wp');

       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('check_if_amounts_exist_for_wp: ' || l_module_name,pa_debug.g_err_stage,5);

       -- reset curr function
       pa_debug.Reset_Curr_Function();
	END IF;
       RAISE;
END check_if_amounts_exist_for_wp;

/*=============================================================================
  This api is called to check if task assignments exist for any of the workplan
  versions of the given project
==============================================================================*/

FUNCTION check_if_task_asgmts_exist(
           p_project_id           IN   pa_projects_all.project_id%TYPE
) RETURN VARCHAR2
IS
   l_task_assignments_exist_flag  VARCHAR2(1);
BEGIN
    -- Set curr function
 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_curr_function(
                p_function   =>'PA_FIN_PLAN_UTILS.check_if_task_asgmts_exist'
               ,p_debug_mode => P_PA_DEBUG_MODE );

    -- Validate input parameters

        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write('check_if_task_asgmts_exist: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL)
    THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='p_project_id = '||p_project_id;
           pa_debug.write('check_if_task_asgmts_exist: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                              p_token1         => 'PROCEDURENAME',
                              p_value1         => 'PA_FIN_PLAN_UTILS.check_if_task_asgmts_exist');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- Check if task assignments exist for any of the workplan versions of the project
    Begin
        SELECT 'Y' INTO l_task_assignments_exist_flag
        FROM dual WHERE EXISTS
            (SELECT 1
             FROM   pa_budget_versions bv,
                    pa_resource_assignments ra
             WHERE  bv.project_id = p_project_id
             AND    bv.wp_version_flag = 'Y'
             AND    ra.budget_version_id = bv.budget_version_id
             AND    ra.ta_display_flag = 'Y');
    Exception
       When no_data_found Then
           l_task_assignments_exist_flag := 'N';
    End;


    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Exiting check_if_task_asgmts_exist';
        pa_debug.write('check_if_task_asgmts_exist: ' || l_module_name,pa_debug.g_err_stage,3);

    -- reset curr function
	    pa_debug.reset_curr_function();
	END IF;
    RETURN l_task_assignments_exist_flag;

EXCEPTION
   WHEN Others THEN

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                               ,p_procedure_name  => 'check_if_task_asgmts_exist');

       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('check_if_task_asgmts_exist: ' || l_module_name,pa_debug.g_err_stage,5);

       -- reset curr function
       pa_debug.Reset_Curr_Function();
	END IF;
       RAISE;
END check_if_task_asgmts_exist;

/*=============================================================================
  This api is called to check if amounts exist for any of the budget versions
  of the project - plan type combination. This is used as of now to restrict
  RBS change at plan type level.
==============================================================================*/

FUNCTION check_if_amounts_exist_for_fp(
           p_project_id           IN   pa_projects_all.project_id%TYPE
           ,p_fin_plan_type_id    IN   pa_fin_plan_types_b.fin_plan_type_id %TYPE
) RETURN VARCHAR2
IS
   l_amounts_exist_flag  VARCHAR2(1)  := 'N';
BEGIN
    -- Set curr function
 IF P_PA_DEBUG_MODE = 'Y' THEN
    pa_debug.set_curr_function(
                p_function   =>'PA_FIN_PLAN_UTILS.check_if_amounts_exist_for_fp'
               ,p_debug_mode => P_PA_DEBUG_MODE );

    -- Validate input parameters

        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write('check_if_amounts_exist_for_fp: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL) OR (p_fin_plan_type_id IS NULL)
    THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='p_project_id = '||p_project_id;
           pa_debug.write('check_if_amounts_exist_for_fp: ' || l_module_name,pa_debug.g_err_stage,5);

           pa_debug.g_err_stage:='p_fin_plan_type_id = '||p_fin_plan_type_id;
           pa_debug.write('check_if_amounts_exist_for_fp: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                              p_token1         => 'PROCEDURENAME',
                              p_value1         => 'PA_FIN_PLAN_UTILS.check_if_amounts_exist_for_fp');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- Check if budget line exists for any of the budget versions of the project-plan type
	Begin
        SELECT 'Y' INTO l_amounts_exist_flag
        FROM dual WHERE EXISTS
            (SELECT 1
             FROM   pa_budget_lines bl,
                    pa_budget_versions bv
             WHERE  bv.project_id = p_project_id
             AND    bv.fin_plan_type_id = p_fin_plan_type_id
             AND    bl.budget_version_id = bv.budget_version_id);
    Exception
       When no_data_found Then
           l_amounts_exist_flag := 'N';
    End;


    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Exiting check_if_amounts_exist_for_fp';
        pa_debug.write('check_if_amounts_exist_for_fp: ' || l_module_name,pa_debug.g_err_stage,3);

    -- reset curr function
	    pa_debug.reset_curr_function();
	END IF;
    RETURN l_amounts_exist_flag;

EXCEPTION
   WHEN Others THEN

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FIN_PLAN_UTILS'
                               ,p_procedure_name  => 'check_if_amounts_exist_for_fp');

       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('check_if_amounts_exist_for_fp: ' || l_module_name,pa_debug.g_err_stage,5);

       -- reset curr function
          pa_debug.Reset_Curr_Function();
	END IF;
       RAISE;
END check_if_amounts_exist_for_fp;

/*===================================================================================
 This api is used to validate the plan processing code if it passed, or to return
 the same for the budget version id that is passed in budget context or for the
 ci_id passed for the CI version context and throw an error in case they are not valid
=====================================================================================*/

PROCEDURE return_and_vldt_plan_prc_code
(
       p_add_msg_to_stack             IN       VARCHAR2
      ,p_calling_context              IN       VARCHAR2
      ,p_budget_version_id            IN       pa_budget_versions.budget_version_id%TYPE
      ,p_source_ci_id_tbl             IN       SYSTEM.pa_num_tbl_type
      ,p_target_ci_id                 IN       pa_control_items.ci_id%TYPE
      ,p_plan_processing_code         IN       pa_budget_versions.plan_processing_code%TYPE
      ,x_final_plan_prc_code          OUT      NOCOPY pa_budget_versions.plan_processing_code%TYPE --File.Sql.39 bug 4440895
      ,x_targ_request_id              OUT      NOCOPY pa_budget_versions.request_id%TYPE --File.Sql.39 bug 4440895
      ,x_return_status                OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                    OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data                     OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

    --Start of variables used for debugging
    l_return_status                            VARCHAR2(1);
    l_msg_count                                NUMBER := 0;
    l_msg_data                                 VARCHAR2(2000);
    l_data                                     VARCHAR2(2000);
    l_msg_index_out                            NUMBER;
    l_debug_mode                               VARCHAR2(30);
    l_debug_level3                             CONSTANT NUMBER :=3;
    l_debug_level5                             CONSTANT NUMBER :=5;

    --End of variables used for debugging
    l_module_name                              VARCHAR2(200) :=  'PAFPUTLB.return_and_vldt_plan_prc_code';
    l_plan_processing_code                     VARCHAR2(30);

    l_src_ci_impact_type_tbl                   SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
    l_no_of_targ_ci_version                    NUMBER;
    l_no_of_src_ci_version                     NUMBER;
    l_targ_ci_ver_plan_prc_code                pa_budget_versions.plan_processing_code%TYPE;
    l_targ_cost_ci_ver_plan_prc_cd             pa_budget_versions.plan_processing_code%TYPE;
    l_targ_rev_ci_ver_plan_prc_cd              pa_budget_versions.plan_processing_code%TYPE;
    l_targ_cost_ci_err_flag                    VARCHAR2(1)   := 'N';
    l_targ_rev_ci_err_flag                     VARCHAR2(1)   := 'N';
    l_incomp_imapact_exists                    VARCHAR2(1)   := 'N';
    l_targ_request_id                          pa_budget_versions.request_id%TYPE;
    l_targ_cost_ci_req_id                      pa_budget_versions.request_id%TYPE;
    l_targ_rev_ci_req_id                       pa_budget_versions.request_id%TYPE;
    l_targ_ci_request_id                       pa_budget_versions.request_id%TYPE;

BEGIN

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_debug_mode = 'Y' THEN
          PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                      p_debug_mode => l_debug_mode );
    END IF;
    IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Entering into pa.plsql.pa_fin_plan_utils.return_and_vldt_plan_prc_code';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.g_err_stage := 'Validating input parameters';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
    END IF;

    IF p_calling_context = 'BUDGET' THEN
          IF p_budget_version_id IS NULL AND
             p_plan_processing_code IS  NULL THEN

              IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='p_budget_version_id: '|| p_budget_version_id ;
                  pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

                  pa_debug.g_err_stage:='p_plan_processing_code: '|| p_plan_processing_code ;
                  pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
              END IF;

              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

    ELSIF p_calling_context = 'CI' THEN
          IF p_source_ci_id_tbl.COUNT = 0 AND
             p_target_ci_id IS  NULL THEN

              IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:='p_source_ci_id_tbl.COUNT: '|| p_source_ci_id_tbl.COUNT ;
                  pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

                  pa_debug.g_err_stage:='p_target_ci_id: '|| p_target_ci_id ;
                  pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
              END IF;

              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
    END IF;

    IF p_calling_context = 'BUDGET' THEN
          IF p_plan_processing_code IS NULL THEN

              SELECT plan_processing_code,
                     request_id
              INTO   l_plan_processing_code,
                     l_targ_request_id
              FROM   pa_budget_versions
              WHERE  budget_version_id = p_budget_version_id;
          ELSE
              l_plan_processing_code := p_plan_processing_code;
          END IF;

          IF p_add_msg_to_stack = 'Y' THEN
                IF l_plan_processing_code = 'XLUP' THEN
                      PA_UTILS.ADD_MESSAGE
                           (p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_LOCKED_BY_PROCESSING');
                      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                ELSIF l_plan_processing_code = 'XLUE' THEN
                      PA_UTILS.ADD_MESSAGE
                           (p_app_short_name => 'PA',
                            p_msg_name       => 'PA_FP_WA_CONC_PRC_FAILURE_MSG');
                      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
          END IF;

          x_final_plan_prc_code := l_plan_processing_code;
          x_targ_request_id := l_targ_request_id;
    ELSIF p_calling_context = 'CI' THEN
          BEGIN
                SELECT COUNT(*)
                INTO   l_no_of_targ_ci_version
                FROM   pa_budget_versions
                WHERE  ci_id = p_target_ci_id;

                IF l_no_of_targ_ci_version = 1 THEN
                     -- irrespective of the version type for the target CI version
                     -- fetch the plan_processing_code
                     SELECT plan_processing_code,
                            request_id
                     INTO   l_targ_ci_ver_plan_prc_code,
                            l_targ_request_id
                     FROM   pa_budget_versions
                     WHERE  ci_id = p_target_ci_id;

                     IF p_add_msg_to_stack = 'Y' THEN
                        IF l_targ_ci_ver_plan_prc_code = 'XLUP' THEN
                            PA_UTILS.ADD_MESSAGE
                                 (p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_LOCKED_BY_PROCESSING');
                            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        ELSIF l_targ_ci_ver_plan_prc_code = 'XLUE' THEN
                            PA_UTILS.ADD_MESSAGE
                                 (p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_WA_CONC_PRC_FAILURE_MSG');
                            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        END IF;
                     ELSE
                        x_final_plan_prc_code := l_targ_ci_ver_plan_prc_code;
                        x_targ_request_id := l_targ_request_id;
                     END IF;
                -- if there are two versions for the CI
                ELSE
                     SELECT plan_processing_code,
                            request_id
                     INTO   l_targ_cost_ci_ver_plan_prc_cd,
                            l_targ_cost_ci_req_id
                     FROM   pa_budget_versions
                     WHERE  ci_id = p_target_ci_id
                     AND    version_type = 'COST';

                     SELECT plan_processing_code,
                            request_id
                     INTO   l_targ_rev_ci_ver_plan_prc_cd,
                            l_targ_rev_ci_req_id
                     FROM   pa_budget_versions
                     WHERE  ci_id = p_target_ci_id
                     AND    version_type = 'REVENUE';


                     IF l_targ_cost_ci_ver_plan_prc_cd = 'XLUP' OR
                        l_targ_cost_ci_ver_plan_prc_cd = 'XLUE' THEN
                            l_targ_ci_ver_plan_prc_code := l_targ_cost_ci_ver_plan_prc_cd;
                            l_targ_ci_request_id := l_targ_cost_ci_req_id;
                            l_targ_cost_ci_err_flag := 'Y';
                     ELSE
                            l_targ_ci_ver_plan_prc_code := null;
                            l_targ_ci_request_id := null;
                     END IF;

                     IF l_targ_rev_ci_ver_plan_prc_cd = 'XLUP' OR
                        l_targ_rev_ci_ver_plan_prc_cd = 'XLUE' THEN
                            l_targ_ci_ver_plan_prc_code := l_targ_rev_ci_ver_plan_prc_cd;
                            l_targ_ci_request_id := l_targ_rev_ci_req_id;
                            l_targ_rev_ci_err_flag := 'Y';
                     ELSE
                            l_targ_ci_ver_plan_prc_code := null;
                            l_targ_ci_request_id := null;
                     END IF;

                     -- if both the target CI versions are not accessible, then staright away throw error
                     -- if both the target CI versions are valid for access, then don't return error
                     -- if either of the target CI version has some process lock/error,
                     -- loop thru the source ci id table to find out the impact type of each source CI
                     -- if the source has an impact type for which the target version is accessible, then
                     -- no need to throw error, otherwise the merge should be disallowed.

                     IF l_targ_cost_ci_err_flag = 'Y' AND
                        l_targ_rev_ci_err_flag = 'Y' THEN
                              IF p_add_msg_to_stack = 'Y' THEN
                                    IF l_targ_ci_ver_plan_prc_code = 'XLUP' THEN
                                        PA_UTILS.ADD_MESSAGE
                                             (p_app_short_name => 'PA',
                                              p_msg_name       => 'PA_FP_LOCKED_BY_PROCESSING');
                                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                    ELSIF l_targ_ci_ver_plan_prc_code = 'XLUE' THEN
                                        PA_UTILS.ADD_MESSAGE
                                             (p_app_short_name => 'PA',
                                              p_msg_name       => 'PA_FP_WA_CONC_PRC_FAILURE_MSG');
                                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                    END IF;
                              ELSE
                                    x_final_plan_prc_code := l_targ_ci_ver_plan_prc_code;
                                    x_targ_request_id := l_targ_ci_request_id;
                              END IF;
                     ELSIF l_targ_cost_ci_err_flag = 'N' AND
                           l_targ_rev_ci_err_flag = 'N' THEN
                              -- do nothing just return
                              x_final_plan_prc_code := null;
                              x_targ_request_id := null;
                     ELSE
                           IF p_source_ci_id_tbl.COUNT > 0 THEN
                              -- call a function to get the impact type of all the source ci_ids
                              FOR i IN p_source_ci_id_tbl.FIRST .. p_source_ci_id_tbl.LAST LOOP
                                    l_src_ci_impact_type_tbl.EXTEND(1);
                                    l_src_ci_impact_type_tbl(l_src_ci_impact_type_tbl.COUNT) := PA_FP_CONTROL_ITEMS_UTILS.is_impact_exists(p_source_ci_id_tbl(i));
                              END LOOP;

                              IF l_targ_cost_ci_err_flag = 'Y' AND
                                   l_targ_rev_ci_err_flag = 'N' THEN
                                         -- check if atleast any of the source CI has cost impact
                                         IF l_src_ci_impact_type_tbl.COUNT > 0 THEN
                                                FOR i IN l_src_ci_impact_type_tbl.FIRST .. l_src_ci_impact_type_tbl.LAST LOOP
                                                      IF l_src_ci_impact_type_tbl(i) = 'COST' THEN
                                                            l_incomp_imapact_exists := 'Y';
                                                            EXIT;
                                                      END IF;
                                                END LOOP;
                                         END IF;
                                         IF l_incomp_imapact_exists = 'Y' THEN
                                               -- throw error
                                               IF p_add_msg_to_stack = 'Y' THEN
                                                     IF l_targ_ci_ver_plan_prc_code = 'XLUP' THEN
                                                         PA_UTILS.ADD_MESSAGE
                                                              (p_app_short_name => 'PA',
                                                               p_msg_name       => 'PA_FP_LOCKED_BY_PROCESSING');
                                                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                                     ELSIF l_targ_ci_ver_plan_prc_code = 'XLUE' THEN
                                                         PA_UTILS.ADD_MESSAGE
                                                              (p_app_short_name => 'PA',
                                                               p_msg_name       => 'PA_FP_WA_CONC_PRC_FAILURE_MSG');
                                                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                                     END IF;
                                               ELSE
                                                     x_final_plan_prc_code := l_targ_ci_ver_plan_prc_code;
                                                     x_targ_request_id := l_targ_ci_request_id;
                                               END IF;
                                         ELSE
                                               -- do nothing just return
                                               x_final_plan_prc_code := null;
                                         END IF;
                              ELSIF l_targ_cost_ci_err_flag = 'N' AND
                                      l_targ_rev_ci_err_flag = 'Y' THEN
                                         -- check if atleast any of the source CI has cost impact
                                         IF l_src_ci_impact_type_tbl.COUNT > 0 THEN
                                                FOR i IN l_src_ci_impact_type_tbl.FIRST .. l_src_ci_impact_type_tbl.LAST LOOP
                                                      IF l_src_ci_impact_type_tbl(i) = 'REVENUE' THEN
                                                            l_incomp_imapact_exists := 'Y';
                                                            EXIT;
                                                      END IF;
                                                END LOOP;
                                         END IF;
                                         IF l_incomp_imapact_exists = 'Y' THEN
                                               -- throw error
                                               IF p_add_msg_to_stack = 'Y' THEN
                                                     IF l_targ_ci_ver_plan_prc_code = 'XLUP' THEN
                                                         PA_UTILS.ADD_MESSAGE
                                                              (p_app_short_name => 'PA',
                                                               p_msg_name       => 'PA_FP_LOCKED_BY_PROCESSING');
                                                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                                     ELSIF l_targ_ci_ver_plan_prc_code = 'XLUE' THEN
                                                         PA_UTILS.ADD_MESSAGE
                                                              (p_app_short_name => 'PA',
                                                               p_msg_name       => 'PA_FP_WA_CONC_PRC_FAILURE_MSG');
                                                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                                     END IF;
                                               ELSE
                                                     x_final_plan_prc_code := l_targ_ci_ver_plan_prc_code;
                                                     x_targ_request_id := l_targ_ci_request_id;
                                               END IF;
                                         ELSE
                                               -- do nothing just return
                                               x_final_plan_prc_code := null;
                                               x_targ_request_id := null;
                                         END IF;
                              END IF;
                           ELSE -- if source ci_id tbl is null
                              -- raise error for the failed version
                              IF l_targ_cost_ci_err_flag = 'Y'  OR
                                 l_targ_cost_ci_err_flag = 'Y' THEN
                                    IF p_add_msg_to_stack = 'Y' THEN
                                          IF l_targ_ci_ver_plan_prc_code = 'XLUP' THEN
                                              PA_UTILS.ADD_MESSAGE
                                                   (p_app_short_name => 'PA',
                                                    p_msg_name       => 'PA_FP_LOCKED_BY_PROCESSING');
                                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                          ELSIF l_targ_ci_ver_plan_prc_code = 'XLUE' THEN
                                              PA_UTILS.ADD_MESSAGE
                                                   (p_app_short_name => 'PA',
                                                    p_msg_name       => 'PA_FP_WA_CONC_PRC_FAILURE_MSG');
                                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                                          END IF;
                                    ELSE
                                          x_final_plan_prc_code := l_targ_ci_ver_plan_prc_code;
                                          x_targ_request_id := l_targ_ci_request_id;
                                    END IF;
                              END IF;
                           END IF; -- if source ci_id tbl is not null
                     END IF; -- if either cost or rev version has error
                END IF; -- 2 target ci versions
          EXCEPTION
                WHEN NO_DATA_FOUND THEN
                      x_final_plan_prc_code := null;
          END;
    END IF; -- p_calling_context

    IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Leaving into pa.plsql.pa_fin_plan_utils.return_and_vldt_plan_prc_code';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

	    pa_debug.reset_curr_function();
	END IF;
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

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
           pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);

       -- reset curr function
	       pa_debug.reset_curr_function();
	END IF;
       RETURN;
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fin_plan_utils'
                               ,p_procedure_name  => 'return_and_vldt_plan_prc_code');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write( l_module_name,pa_debug.g_err_stage,l_debug_level5);
       -- reset curr function
       pa_debug.Reset_Curr_Function();
	END IF;
       RAISE;

END return_and_vldt_plan_prc_code;

--Bug: 3619687 Added a function to check that the preference code the plan type is not used as a generation source for any other plan type

FUNCTION Is_source_for_gen_options
          (p_project_id                   IN   pa_projects_all.project_id%TYPE
          ,p_fin_plan_type_id             IN   pa_fin_plan_types_b.fin_plan_type_id%TYPE
          ,p_preference_code              IN   pa_proj_fp_options.fin_plan_preference_code%TYPE
          ) RETURN VARCHAR2 IS

       l_valid_status  VARCHAR2(1)  := 'S';
       l_exists        VARCHAR2(1);

BEGIN

           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.init_err_stack ('pa_fin_plan_utils.Is_source_for_generation_options');
           END IF;

    /* Changes for FP.M, Tracking Bug No - 3619687. Making a check if the plan version/type is
    a source of generation fot other plan types*/
    BEGIN
    IF ( p_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY) THEN
         SELECT 1 INTO l_exists FROM dual WHERE EXISTS (SELECT fin_plan_type_id
         FROM PA_PROJ_FP_OPTIONS
         WHERE Project_id = p_project_id AND
         (GEN_SRC_REV_PLAN_TYPE_ID = p_fin_plan_type_id
         OR GEN_SRC_COST_PLAN_TYPE_ID= p_fin_plan_type_id
         OR GEN_SRC_ALL_PLAN_TYPE_ID = p_fin_plan_type_id));
         RETURN ('PA_FP_IS_GEN_OPTNS_SRC');
        END IF;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_valid_status :='S';
    END;
    RETURN ( l_valid_status );
END Is_source_for_gen_options;


 /* bug 4494740: The following function is included here which would return
    the percent complete for the financial structure version when the financial
    structure_version_id and the status_flags are passed as input. This function
    is introduced as part of performance improvement for FP.M excel download.
  */
  FUNCTION get_physical_pc_complete
        ( p_project_id                  IN           pa_projects_all.project_id%TYPE,
          p_proj_element_id             IN           pa_proj_element_versions.proj_element_id%TYPE)

  RETURN NUMBER IS

        l_msg_count            NUMBER;
        l_msg_data             VARCHAR2(2000);
        l_return_status        VARCHAR2(1);

        l_return_value         NUMBER;
        l_structure_status     VARCHAR2(30);
        l_physic_pc_complete   NUMBER;

  BEGIN

--	Replaced the p_proj_element_id with nvl(p_proj_element_id,0) Bug 5335146
        IF g_fp_wa_task_pc_compl_tbl.EXISTS(NVL(p_proj_element_id,0)) THEN
            l_return_value := g_fp_wa_task_pc_compl_tbl(NVL(p_proj_element_id,0));
        ELSE

            IF g_fp_wa_struct_status_flag = 'Y' THEN
                l_structure_status := 'PUBLISHED';
            ELSE
                l_structure_status := 'WORKING';
            END IF;

            PA_PROGRESS_UTILS.REDEFAULT_BASE_PC
               (p_project_id             => p_project_id,
                p_proj_element_id        => p_proj_element_id,
                p_structure_type         => 'FINANCIAL',
                p_object_type            => 'PA_TASKS',
                p_as_of_date             => trunc(SYSDATE),
                p_structure_version_id   => g_fp_wa_struct_ver_id,
                p_structure_status       => l_structure_status,
                p_calling_context        => 'FINANCIAL_PLANNING',
                x_base_percent_complete  => l_physic_pc_complete,
                x_return_status          => l_return_status,
                x_msg_count              => l_msg_count,
                x_msg_data               => l_msg_data);

            IF l_return_status = 'S' THEN
                l_return_value := l_physic_pc_complete;
                g_fp_wa_task_pc_compl_tbl(NVL(p_proj_element_id,0)) := l_physic_pc_complete;
            END IF;
        END IF;

        RETURN l_return_value;

  END get_physical_pc_complete;

  FUNCTION set_webadi_download_var
         (p_structure_version_id        IN           pa_proj_element_versions.parent_structure_version_id%TYPE,
          p_structure_status_flag       IN           VARCHAR2)

  RETURN VARCHAR2
  IS
       l_return_null_value            VARCHAR2(1);
  BEGIN
        g_fp_wa_struct_ver_id      := p_structure_version_id;
        g_fp_wa_struct_status_flag := p_structure_status_flag;

        RETURN l_return_null_value;
  END set_webadi_download_var;

  FUNCTION get_fp_wa_struct_ver_id
  RETURN NUMBER
  IS
  BEGIN
        RETURN g_fp_wa_struct_ver_id;
  END get_fp_wa_struct_ver_id;


  /* This procedure is called from FPWebadiAMImpl.java to get the structure version id
   * and the structure version status flag to be used as URL parameter for BNE URL
   */
  PROCEDURE return_struct_ver_info
        (p_budget_version_id    IN              pa_budget_versions.budget_version_id%TYPE,
         x_struct_version_id    OUT    NOCOPY   pa_proj_element_versions.parent_structure_version_id%TYPE,
         x_struct_status_flag   OUT    NOCOPY   VARCHAR2,
         x_return_status        OUT    NOCOPY   VARCHAR2,
         x_msg_count            OUT    NOCOPY   NUMBER,
         x_msg_data             OUT    NOCOPY   VARCHAR2)

  IS
        l_debug_mode           VARCHAR2(30);
        l_module_name          VARCHAR2(100) := 'PAFPWAUB.return_struct_ver_info';
        l_msg_count            NUMBER := 0;
        l_data                 VARCHAR2(2000);
        l_msg_data             VARCHAR2(2000);
        l_msg_index_out        NUMBER;
        l_debug_level3         CONSTANT NUMBER :=3;
        l_project_id           pa_projects_all.project_id%TYPE;


  BEGIN
        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

        x_msg_count := 0;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF l_debug_mode = 'Y' THEN
            PA_DEBUG.Set_Curr_Function(p_function   => l_module_name,
                                       p_debug_mode => l_debug_mode );
        END IF;

        IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Entering return_struct_ver_info';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
              pa_debug.g_err_stage:='Validating input parameters';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;

        IF p_budget_version_id IS NULL THEN
            IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage := 'p_budget_version_id is passed as null';
                 pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
            END IF;
            pa_utils.add_message(p_app_short_name   => 'PA',
                                 p_msg_name         => 'PA_FP_INV_PARAM_PASSED',
                                 p_token1           => 'PROCEDURENAME',
                                 p_value1           => l_module_name);

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Deriving project_id';
             pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
        END IF;

        BEGIN
            SELECT project_id
            INTO   l_project_id
            FROM   pa_budget_versions
            WHERE  budget_version_id = p_budget_version_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                IF l_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Invalid budget_version_id passed';
                     pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
                END IF;
                pa_utils.add_message(p_app_short_name   => 'PA',
                                     p_msg_name         => 'PA_FP_INV_PARAM_PASSED',
                                     p_token1           => 'PROCEDURENAME',
                                     p_value1           => l_module_name);

                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END;

        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Getting structure version id';
             pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
        END IF;

        x_struct_version_id := pa_planning_element_utils.get_fin_struct_id(l_project_id,p_budget_version_id);
        x_struct_status_flag := PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(l_project_id, x_struct_version_id);

        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Values returned->';
             pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
             pa_debug.g_err_stage := 'x_struct_version_id-> ' || x_struct_version_id;
             pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
             pa_debug.g_err_stage := 'x_struct_status_flag-> ' || x_struct_status_flag;
             pa_debug.write(l_module_name, pa_debug.g_err_stage, l_debug_level3);
        END IF;

        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Leaving return_struct_ver_info';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
             pa_debug.reset_curr_function;
        END IF;

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
             END IF;
             IF l_debug_mode = 'Y' THEN
                pa_debug.reset_curr_function;
             END IF;
        WHEN OTHERS THEN
           FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PAFPWAUB'
                                   ,p_procedure_name  => 'return_struct_ver_info');

           IF l_debug_mode = 'Y' THEN
                 pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                 pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
           END IF;
           IF l_debug_mode = 'Y' THEN
                pa_debug.reset_curr_function;
           END IF;
           RAISE;
  END return_struct_ver_info;

  /* This fuction calls pa_fin_plan_utils.get_time_phased_code to get the time phased
   * code for the version and caches it in a package variable for the first time
   * and uses it to read and return to avoid select every time for each row
   * in the excel download view query
   */
  FUNCTION get_cached_time_phased_code (bv_id     IN     pa_budget_versions.budget_version_id%TYPE)
  RETURN VARCHAR2
  IS
        l_time_phased_code          pa_proj_fp_options.cost_time_phased_code%TYPE;
  BEGIN
        IF g_fp_wa_time_phased_code IS NOT NULL THEN
            l_time_phased_code := g_fp_wa_time_phased_code;
        ELSE
            l_time_phased_code := pa_fin_plan_utils.get_time_phased_code(bv_id);
            g_fp_wa_time_phased_code := l_time_phased_code;
        END IF;

        RETURN l_time_phased_code;
  END;

  -- 4494740 changes end here

  /*=============================================================================
 This api is used as a wrapper API to pa_budget_pub.create_draft_budget
==============================================================================*/ --4738996 Starts here

PROCEDURE create_draft_budget_wrp(
  p_api_version_number            IN  NUMBER
 ,p_commit                        IN  VARCHAR2        := FND_API.G_FALSE
 ,p_init_msg_list                 IN  VARCHAR2        := FND_API.G_FALSE
 ,p_msg_count                     OUT NOCOPY NUMBER
 ,p_msg_data                      OUT NOCOPY VARCHAR2
 ,p_return_status                 OUT NOCOPY VARCHAR2
 ,p_pm_product_code               IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_budget_reference           IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_budget_version_name           IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id                 IN  NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference          IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code              IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code            IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_entry_method_code             IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_name            IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_id              IN  NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category            IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_lines_in               IN  PA_BUDGET_PUB.budget_line_in_tbl_type
 ,p_budget_lines_out              OUT NOCOPY PA_BUDGET_PUB.budget_line_out_tbl_type

 /*Parameters due fin plan model */
 ,p_fin_plan_type_id              IN   pa_fin_plan_types_b.fin_plan_type_id%TYPE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_name            IN   pa_fin_plan_types_vl.name%TYPE                     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type                  IN   pa_budget_versions.version_type%TYPE               := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_fin_plan_level_code           IN   pa_proj_fp_options.cost_fin_plan_level_code%TYPE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_time_phased_code              IN   pa_proj_fp_options.cost_time_phased_code%TYPE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_plan_in_multi_curr_flag       IN   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_type       IN   pa_proj_fp_options.projfunc_cost_rate_type%TYPE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date_typ   IN   pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date       IN   pa_proj_fp_options.projfunc_cost_rate_date%TYPE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_rev_rate_type        IN   pa_proj_fp_options.projfunc_rev_rate_type%TYPE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date_typ    IN   pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date        IN   pa_proj_fp_options.projfunc_rev_rate_date%TYPE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_cost_rate_type        IN   pa_proj_fp_options.project_cost_rate_type%TYPE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date_typ    IN   pa_proj_fp_options.project_cost_rate_date_type%TYPE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date        IN   pa_proj_fp_options.project_cost_rate_date%TYPE  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_rev_rate_type         IN   pa_proj_fp_options.project_rev_rate_type%TYPE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date_typ     IN   pa_proj_fp_options.project_rev_rate_date_type%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date         IN   pa_proj_fp_options.project_rev_rate_date%TYPE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_raw_cost_flag                 IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_burdened_cost_flag            IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_revenue_flag                  IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cost_qty_flag                 IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_revenue_qty_flag              IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_all_qty_flag                  IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_create_new_curr_working_flag  IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_replace_current_working_flag  IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_using_resource_lists_flag	  IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 )
      IS

    --Start of variables used for debugging

    l_msg_count                      NUMBER := 0;
    l_data                           VARCHAR2(2000);
    l_msg_data                       VARCHAR2(2000);
    l_msg_index_out                  NUMBER;
    l_error_msg_code     VARCHAR2(30);
    l_return_status      VARCHAR2(2000);
    l_debug_mode         VARCHAR2(30);
    l_debug_level5                  CONSTANT NUMBER := 5;
    l_workflow_started	VARCHAR2(1);
    --End of variables used for debugging
    l_budget_lines_out_tbl          pa_budget_pub.budget_line_out_tbl_type;
    l_fp_preference_code    pa_proj_fp_options.fin_plan_preference_code%TYPE;
    l_version_type          pa_budget_versions.version_type%TYPE;
    l_baselined_version_id  pa_budget_versions.budget_version_id%TYPE;
    l_fp_options_id         pa_proj_fp_options.proj_fp_options_id%TYPE;
    l_approved_fin_plan_type_id      pa_fin_plan_types_b.fin_plan_type_id%TYPE;

    -- Bug 8681652
    l_baseline_funding_flag  pa_projects_all.baseline_funding_flag%TYPE;
    l_budget_version_name    pa_budget_versions.version_name%TYPE;

BEGIN

    pa_debug.set_err_stack('PA_FIN_PLAN_UTILS.create_draft_budget_wrp');
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('create_draft_budget_wrp: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;

    -- Bug 8681652
    select baseline_funding_flag
    into l_baseline_funding_flag
    from pa_projects_all
    where project_id = p_pa_project_id;

    IF ( p_budget_version_name IS NULL OR p_budget_version_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
         AND l_baseline_funding_flag = 'Y'
    THEN
          l_budget_version_name := to_char(sysdate);
    ELSE
          l_budget_version_name := p_budget_version_name;
    END IF;

     -- Call the utility function that gives the id of the approved revenue plan type, if exists,
                  -- that is added to the project
     pa_fin_plan_utils.Get_Appr_Rev_Plan_Type_Info(
      p_project_id     => p_pa_project_id
     ,x_plan_type_id  =>  l_approved_fin_plan_type_id
     ,x_return_status =>  l_return_status
     ,x_msg_count     =>  l_msg_count
     ,x_msg_data      =>  l_msg_data) ;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

               IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage := 'Get_Appr_Cost_Plan_Type_Info API returned error' ;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
               END IF;
     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                  -- The Get_Appr_Cost_Plan_Type_Info api got executed successfully.
     ELSIF(  l_approved_fin_plan_type_id IS NOT NULL)  THEN

    --Call create_draft_budget
--dbms_output.put_line('control comes here');
   --  dbms_output.put_line('Value of yeessssssss l_approved_fin_plan_type_id'||l_approved_fin_plan_type_id);

     pa_budget_pub.create_draft_budget( p_api_version_number   => p_api_version_number
                        ,p_commit               => FND_API.G_FALSE
                        ,p_init_msg_list        => FND_API.G_FALSE
                        ,p_msg_count            => l_msg_count
                        ,p_msg_data             => l_msg_data
                        ,p_return_status        => l_return_status
                        ,p_pm_product_code      => p_pm_product_code
                        ,p_budget_version_name  => l_budget_version_name  -- Bug 8681652
                        ,p_pa_project_id        => p_pa_project_id
                        ,p_pm_project_reference => p_pm_project_reference
                        ,p_budget_type_code     => NULL
                        ,p_change_reason_code   => Null
                        ,p_description          => 'Default Created by Projects AMG Agreement Funding'
                        ,p_entry_method_code    => NULL
                        ,p_resource_list_name   => p_resource_list_name
                        ,p_resource_list_id     => p_resource_list_id
                        ,p_attribute_category   => p_attribute_category
                        ,p_attribute1           => p_attribute1
                        ,p_attribute2           => p_attribute2
                        ,p_attribute3           => p_attribute3
                        ,p_attribute4           => p_attribute4
                        ,p_attribute5           => p_attribute5
                        ,p_attribute6           => p_attribute6
                        ,p_attribute7           => p_attribute7
                        ,p_attribute8           => p_attribute8
                        ,p_attribute9           => p_attribute9
                        ,p_attribute10          => p_attribute10
                        ,p_attribute11          => p_attribute11
                        ,p_attribute12          => p_attribute12
                        ,p_attribute13          => p_attribute13
                        ,p_attribute14          => p_attribute14
                        ,p_attribute15          => p_attribute15
                        ,p_budget_lines_in      => p_budget_lines_in
                        ,p_budget_lines_out     => l_budget_lines_out_tbl
			,p_fin_plan_type_id     => l_approved_fin_plan_type_id
			,p_version_type         => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
			,p_revenue_flag         => 'Y'
			, p_revenue_qty_flag    => 'Y');
                       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
                           THEN
			     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			     p_msg_count     := 1;
                             p_msg_data      := 'Exiting create_draft_budget_wrp';
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                       ELSIF l_return_status = FND_API.G_RET_STS_ERROR
                         THEN
			  p_return_status := FND_API.G_RET_STS_ERROR;
			     p_msg_count     := 1;
                             p_msg_data      := 'Exiting create_draft_budget_wrp';
                        RAISE FND_API.G_EXC_ERROR;
                         END IF;


        -- dbms_output.put_line('about to call baseline_budget ... ');
        -- dbms_output.put_line('Before setting the value of PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB = '|| PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB);
        PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB := 'Y';

	PA_BUDGET_PUB.BASELINE_BUDGET
	( p_api_version_number                  => p_api_version_number
 	 ,p_commit                              => FND_API.G_FALSE
 	 ,p_init_msg_list                       => FND_API.G_FALSE
 	 ,p_msg_count                           => p_msg_count
 	 ,p_msg_data                            => p_msg_data
 	 ,p_return_status                       => l_return_status
 	 ,p_workflow_started                    => l_workflow_started
 	 ,p_pm_product_code                     => p_pm_product_code
 	 ,p_pa_project_id                       => p_pa_project_id
 	 ,p_pm_project_reference                => p_pm_project_reference
 	 ,p_budget_type_code                    => NULL
 	 ,p_mark_as_original                    => 'Y'
	 ,p_fin_plan_type_id                    => l_approved_fin_plan_type_id
	 ,p_version_type                        => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
	 );
       --  dbms_output.put_line('returned from BASELINE_BUDGET ... status = '||l_return_status);

	IF (nvl(PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB,'N') = 'Y') THEN
		PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB := 'N'; -- reset the value bug 3099706
	END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;

     ELSIF(  l_approved_fin_plan_type_id IS  NULL)  THEN
  --   dbms_output.put_line('Value of l_approved_fin_plan_type_id'||l_approved_fin_plan_type_id);
 pa_budget_pub.create_draft_budget( p_api_version_number   => p_api_version_number
                        ,p_commit               => FND_API.G_FALSE
                        ,p_init_msg_list        => FND_API.G_FALSE
                        ,p_msg_count            => l_msg_count
                        ,p_msg_data             => l_msg_data
                        ,p_return_status        => l_return_status
                        ,p_pm_product_code      => p_pm_product_code
                        ,p_budget_version_name  => l_budget_version_name  -- Bug 8681652
                        ,p_pa_project_id        => p_pa_project_id
                        ,p_pm_project_reference => p_pm_project_reference
                        ,p_budget_type_code     => 'AR'
                        ,p_change_reason_code   => Null
                        ,p_description          => 'Default Created by Projects AMG Agreement Funding'
                        ,p_entry_method_code    => p_entry_method_code
                        ,p_resource_list_name   => p_resource_list_name
                        ,p_resource_list_id     => p_resource_list_id
                        ,p_attribute_category   => p_attribute_category
                        ,p_attribute1           => p_attribute1
                        ,p_attribute2           => p_attribute2
                        ,p_attribute3           => p_attribute3
                        ,p_attribute4           => p_attribute4
                        ,p_attribute5           => p_attribute5
                        ,p_attribute6           => p_attribute6
                        ,p_attribute7           => p_attribute7
                        ,p_attribute8           => p_attribute8
                        ,p_attribute9           => p_attribute9
                        ,p_attribute10          => p_attribute10
                        ,p_attribute11          => p_attribute11
                        ,p_attribute12          => p_attribute12
                        ,p_attribute13          => p_attribute13
                        ,p_attribute14          => p_attribute14
                        ,p_attribute15          => p_attribute15
                        ,p_budget_lines_in      => p_budget_lines_in
                        ,p_budget_lines_out     => l_budget_lines_out_tbl);

			  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
                           THEN
			     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			     p_msg_count     := 1;
                             p_msg_data      := 'Exiting create_draft_budget_wrp';
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                       ELSIF l_return_status = FND_API.G_RET_STS_ERROR
                         THEN
			  p_return_status := FND_API.G_RET_STS_ERROR;
			     p_msg_count     := 1;
                             p_msg_data      := 'Exiting create_draft_budget_wrp';
                        RAISE FND_API.G_EXC_ERROR;
                         END IF;

      --   dbms_output.put_line('about to call baseline_budget ... ');
      --   dbms_output.put_line('Before setting the value of PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB = '|| PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB);
        PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB := 'Y';

	PA_BUDGET_PUB.BASELINE_BUDGET
	( p_api_version_number                  => p_api_version_number
 	 ,p_commit                              => FND_API.G_FALSE
 	 ,p_init_msg_list                       => FND_API.G_FALSE
 	 ,p_msg_count                           => p_msg_count
 	 ,p_msg_data                            => p_msg_data
 	 ,p_return_status                       => l_return_status
 	 ,p_workflow_started                    => l_workflow_started
 	 ,p_pm_product_code                     => p_pm_product_code
 	 ,p_pa_project_id                       => p_pa_project_id
 	 ,p_pm_project_reference                => p_pm_project_reference
 	 ,p_budget_type_code                    => 'AR'
 	 ,p_mark_as_original                    => 'Y'
	);
      --   dbms_output.put_line('returned from BASELINE_BUDGET ... status = '||l_return_status);

	IF (nvl(PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB,'N') = 'Y') THEN
		PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB := 'N'; -- reset the value bug 3099706
	END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
END IF;

    pa_debug.g_err_stage:='Exiting create_draft_budget_wrp';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('create_draft_budget_wrp: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;
    pa_debug.reset_err_stack;

EXCEPTION

     WHEN Invalid_Arg_Exc THEN

          l_msg_count := FND_MSG_PUB.count_msg;

          IF l_msg_count = 1 THEN

               PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => 1
                      ,p_msg_count      => l_msg_count
                      ,p_msg_data       => l_msg_data
                      ,p_data           => l_data
                      ,p_msg_index_out  => l_msg_index_out);

               p_msg_data := l_data;

               p_msg_count := l_msg_count;
          ELSE

              p_msg_count := l_msg_count;

          END IF;

           p_return_status := FND_API.G_RET_STS_ERROR;

           pa_debug.g_err_stage:='Invalid Arguments Passed';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('create_draft_budget_wrp: ' || l_module_name,pa_debug.g_err_stage,5);
           END IF;

           pa_debug.reset_err_stack;

           RAISE;

     WHEN Others THEN

          p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          p_msg_count     := 1;
          p_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FIN_PLAN_UTILS'
                                  ,p_procedure_name  => 'create_draft_budget_wrp');

          pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('create_draft_budget_wrp: ' || l_module_name,pa_debug.g_err_stage,5);
          END IF;

          pa_debug.reset_err_stack;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END create_draft_budget_wrp;
--4738996 Ends here

/*
  API Name          : Get_NP_RA_Description
  API Description   : Returns the description for the Non Periodic Resource Assignment
  API Created By    : kchaitan
  API Creation Date : 07-MAY-2007
*/

FUNCTION Get_NP_RA_Description
               (p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE Default Null,
                p_txn_currency_code      IN pa_budget_lines.txn_currency_code%TYPE Default Null
     ) RETURN VARCHAR2
IS
l_description pa_budget_lines.description%TYPE;
begin

    select description
    into   l_description
    from  pa_budget_lines
    where resource_assignment_id = p_resource_assignment_id
    and   txn_currency_code      = p_txn_currency_code;

    return l_description;

exception
    when no_data_found then
        return null;

end Get_NP_RA_Description;

/*
  API Name          : Get_Change_Reason
  API Description   : Returns the Change Reason Meaning for the Non Periodic and Periodic Resource Assignment
  API Created By    : kchaitan
  API Creation Date : 07-MAY-2007
*/

FUNCTION Get_Change_Reason
               (p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE Default Null,
                p_txn_currency_code      IN pa_budget_lines.txn_currency_code%TYPE Default Null,
                p_time_phased_code       IN varchar2
     ) RETURN VARCHAR2
IS
l_chg_rsn_code pa_budget_lines.change_reason_code%TYPE;
l_chg_rsn      varchar2(80) := null;
begin

    If p_time_phased_code <> 'N' Then
        If G_Chg_Reason is null Then
            select meaning
            into G_Chg_Reason
            from pa_lookups
            where lookup_type = 'BUDGET CHANGE REASON'
            and lookup_code   = 'MULTIPLE';
        End if;
        return G_Chg_Reason;
    End if;

    select change_reason_code
    into   l_chg_rsn_code
    from  pa_budget_lines
    where resource_assignment_id = p_resource_assignment_id
    and   txn_currency_code      = p_txn_currency_code;

    IF l_chg_rsn_code is not null Then
        select meaning
        into l_chg_rsn
        from pa_lookups
        where lookup_type = 'BUDGET CHANGE REASON'
        and lookup_code   = l_chg_rsn_code;
    End If;

    return l_chg_rsn;
    --return l_chg_rsn_code;

exception
    when no_data_found then
        return null;

end Get_Change_Reason;

-- gboomina added for bug 8318932 - start
/* B-F -This function is used to get the
copy_etc_from_plan_flag in the generation options in case of cost forecast*/
FUNCTION get_copy_etc_from_plan_flag
(p_project_id           IN     pa_proj_fp_options.project_id%TYPE,
p_fin_plan_type_id     IN     pa_proj_fp_options.fin_plan_type_id%TYPE,
p_fin_plan_option_code IN     pa_proj_fp_options.fin_plan_option_level_code%TYPE,
p_budget_version_id    IN     pa_budget_versions.budget_version_id%TYPE)
RETURN pa_proj_fp_options.copy_etc_from_plan_flag%type
IS
  l_copy_etc_from_plan_flag pa_proj_fp_options.copy_etc_from_plan_flag%type ;
  BEGIN
    -- Modified to get copy etc from plan flag at plan type level also
    IF p_budget_version_id is NOT NULL THEN
     select pr.copy_etc_from_plan_flag
     into l_copy_etc_from_plan_flag
     from pa_budget_versions bu, pa_proj_fp_options pr
     where bu.budget_version_id = pr.fin_plan_version_id and
          bu.budget_version_id = p_budget_version_id ;
    ELSE
      select copy_etc_from_plan_flag
        into  l_copy_etc_from_plan_flag
        from   pa_proj_fp_options
        where  project_id = p_project_id
        and    fin_plan_type_id = p_fin_plan_type_id
        and    fin_plan_option_level_code = p_fin_plan_option_code;
    END IF;

    return l_copy_etc_from_plan_flag ;

  EXCEPTION
    when no_data_found then
    return null;

END get_copy_etc_from_plan_flag ;
-- gboomina added for bug 8318932 - end

END PA_FIN_PLAN_UTILS;

/
