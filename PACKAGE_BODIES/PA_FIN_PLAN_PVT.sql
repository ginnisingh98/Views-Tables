--------------------------------------------------------
--  DDL for Package Body PA_FIN_PLAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FIN_PLAN_PVT" AS
/* $Header: PAFPPVTB.pls 120.12.12010000.3 2009/04/30 10:33:08 bifernan ship $
   Start of Comments
   Package name     : PA_FIN_PLAN_UTILS
   Purpose          : utility API's for Org Forecast pages
   History          :
   NOTE             :
   End of Comments
*/

g_module_name VARCHAR2(100) := 'pa.plsql.PA_FIN_PLAN_PVT';
Delete_Ver_Exc_PVT EXCEPTION;

-- PROCEDURE lock_unlock_version
-- created 8/27/02
-- This procedure locks/unlocks a budget version, based on the value of p_action.
-- If p_action = null, then this procedure acts as a lock toggle (if the version was
-- originally locked, it would unlock the version)
-- If p_person_id is null, then it will find the person id based on p_user_id.
-- This procedure assumes that a person can only unlock the versions he/she has locked.
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE lock_unlock_version
    (p_budget_version_id      IN  pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number  IN  pa_budget_versions.record_version_number%TYPE,
     p_action                 IN  VARCHAR2, -- 'L' for lock, 'U' for unlock
     p_user_id                IN  NUMBER,
     p_person_id              IN  NUMBER,  -- can be null
     x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     p_unlock_locked_ver_flag IN VARCHAR2) IS

cursor bv_csr is
select locked_by_person_id
  from pa_budget_versions
  where budget_version_id = p_budget_version_id;
bv_rec bv_csr%ROWTYPE;

l_locked_by_person_id   pa_budget_versions.locked_by_person_id%TYPE; -- for lock/unlock toggle
l_person_id             NUMBER(15);
l_resource_id           NUMBER(15);
l_resource_name         per_all_people_f.full_name%TYPE; -- VARCHAR2(80); for bug # 2933777

-- error handling variables
  l_valid_flag      VARCHAR2(1);
  l_debug_mode      VARCHAR2(30);
  l_msg_count       NUMBER := 0;
  l_data            VARCHAR2(2000);
  l_msg_data        VARCHAR2(2000);
  l_error_msg_code  VARCHAR2(30);
  l_msg_index_out   NUMBER;
  l_return_status   VARCHAR2(2000);

  -- Error messages are stacked for AMG. Hence it is necessary that the
  -- error message in the stacke are not cleared. Using the variable
  -- l_initial_msg_count to do the comparisions and it stores the number
  -- of error messages on stack at the start of this API.
  l_initial_msg_count NUMBER;

BEGIN
    --FND_MSG_PUB.initialize;
    l_initial_msg_count := FND_MSG_PUB.count_msg;

    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PA_FIN_PLAN_PUB.lock_unlock_version');
    END IF;
    x_msg_count := 0;

    /* CHECK FOR BUSINESS RULES VIOLATIONS */
    /* check for null budget_version_id */
    if p_budget_version_id is NULL then
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_NO_PLAN_VERSION');
    end if;
    /* check to see if the budget version we're updating has */
    /* been updated by someone else already */
    PA_FIN_PLAN_UTILS.Check_Record_Version_Number
            (p_unique_index             => p_budget_version_id,
             p_record_version_number    => p_record_version_number,
             x_valid_flag               => l_valid_flag,
             x_return_status            => l_return_status,
             x_error_msg_code           => l_error_msg_code);
    if x_return_status = FND_API.G_RET_STS_ERROR then
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('lock_unlock_version: ' || 'record version number error ');
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => l_error_msg_code);
    end if;

    /* if we do not have a person_id, make sure that we have a valid user_id */
    /* In the following API, l_resource_name is obtained since it is an OUT
       variable. There is no business logic based on l_resource_name. */

    if p_person_id is null then
      PA_COMP_PROFILE_PUB.GET_USER_INFO
          (p_user_id         => p_user_id,
           x_person_id       => l_person_id,
           x_resource_id     => l_resource_id,
           x_resource_name   => l_resource_name);
      if l_person_id is null then
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_BAD_USER_ID');
      end if; -- error with p_user_id
    else
      l_person_id := p_person_id;
    end if;

    /* check to see if the user is trying to unlock a file that is currently */
    /* locked by another user.  the user can unlock only those files he/she  */
    /* has locked. */
    if nvl(p_unlock_locked_ver_flag,'N') = 'N'        /* Bug 5179225 User can also unlock those versions which are unlocked by Others, provided that he has a privilege UNLOCK_ANY_STRUCTURE*/
    then
    open bv_csr;
    fetch bv_csr into bv_rec;
    if not bv_csr%NOTFOUND then
      --if p_action = 'U' and not (bv_rec.locked_by_person_id = l_person_id) then
      --Irrespective of the action, if the locked_by_person_id and l_person_id
      --are different, an error should be thrown. AMG UT2
      if not ( nvl(bv_rec.locked_by_person_id,l_person_id) = l_person_id ) then
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_LOCKED_BY_USER',
                             p_token1              => 'USERNAME',
                             p_value1              => pa_fin_plan_utils.get_person_name(bv_rec.locked_by_person_id));
       end if;
      end if;

      /* Bug 5349962: R12 Perf Fix: Putting a close cursor statement. Closing the cursor only when it returns any row. */
      close bv_csr;
      /* Bug 5349962 */

    end if;

/* If There are ANY Busines Rules Violations , Then Do NOT Proceed: RETURN */
    l_msg_count := FND_MSG_PUB.count_msg;
    --if l_msg_count > 0 then
    if l_msg_count > l_initial_msg_count then
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
	IF p_pa_debug_mode = 'Y' THEN
            pa_debug.reset_err_stack;
	END IF;
            return;
    end if;

    /* IF NO BUSINESS RULES VIOLATIONS, PROCEED WITH LOCK/UNLOCK */
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('lock_unlock_version: ' || 'no business rules violations');
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --if l_msg_count = 0 then
    if l_msg_count = l_initial_msg_count then
       SAVEPOINT PA_FP_LOCK_UNLOCK;
       -- LOCK the version
       if p_action = 'L' then
         update pa_budget_versions
           set locked_by_person_id = l_person_id,
               record_version_number = p_record_version_number + 1,
               last_update_date=SYSDATE,
               last_updated_by=FND_GLOBAL.user_id,
               last_update_login=FND_GLOBAL.login_id
           where budget_version_id = p_budget_version_id;
       -- UNLOCK the version
       elsif p_action = 'U' then
         update pa_budget_versions
           set locked_by_person_id = null,
               record_version_number = p_record_version_number + 1,
               last_update_date=SYSDATE,
               last_updated_by=FND_GLOBAL.user_id,
               last_update_login=FND_GLOBAL.login_id
           where budget_version_id = p_budget_version_id;
       -- if p_action neither 'L' nor 'U', then we assume it's a lock/unlock toggle
       else
         select nvl(locked_by_person_id, -1)
           into l_locked_by_person_id
           from pa_budget_versions
           where budget_version_id = p_budget_version_id;
         -- it was unlocked before:  UNLOCK --> LOCK
         if l_locked_by_person_id = -1 then
           update pa_budget_versions
             set locked_by_person_id = l_person_id,
                 record_version_number = p_record_version_number + 1,
                 last_update_date=SYSDATE,
                 last_updated_by=FND_GLOBAL.user_id,
                 last_update_login=FND_GLOBAL.login_id
             where budget_version_id = p_budget_version_id;
         -- it was locked before:  LOCK --> UNLOCK
         else
           update pa_budget_versions
             set locked_by_person_id = null,
                 record_version_number = p_record_version_number + 1,
                 last_update_date=SYSDATE,
                 last_updated_by=FND_GLOBAL.user_id,
                 last_update_login=FND_GLOBAL.login_id
             where budget_version_id = p_budget_version_id;
         end if;
       end if; -- p_action value
       return;
    end if;

EXCEPTION
    when others then
      rollback to PA_FP_LOCK_UNLOCK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_PUB',
                               p_procedure_name   => 'lock_unlock_version');
	IF p_pa_debug_mode = 'Y' THEN
	      pa_debug.reset_err_stack;
	END IF;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
END lock_unlock_version;



/* ------------------------------------------------------------------------ */

-- 11/16/02 dlai: bug fix 2668857 - when joining pa_projects_all with
--                pa_project_types_all, need to join based on org_id as well

-- 12-FEB-04 jwhite    - Bug 3440026
--                       Commented obsolete call to
--                       PA_BUDGET_UTILS.summerize_project_totals
--                       for Baseline_FinPlan procedure.

-- 21-Sep-04  Raja     - Bug 3841942
--    In FP M for creation of none time phased budgets transaction start/end dates
--    are not compulsory. So, the logic to synch budget lines data with changed
--    transaction start/end dates is not applicable. Commented out the required code


--
-- 12-SEP-05 jwhite    - Bug 4583454. Restore FP Support
--                       PSI/summarization.
--                       Minor Change: Restored insert to
--                       pa_resource_list_members and
--                       pa_resource_list_uses.


PROCEDURE Baseline_FinPlan
    (p_project_id                 IN    pa_budget_versions.project_id%TYPE,
     p_budget_version_id          IN    pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number      IN    pa_budget_versions.record_version_number%TYPE,
     p_orig_budget_version_id     IN    pa_budget_versions.budget_version_id%TYPE,
     p_orig_record_version_number IN    pa_budget_versions.record_version_number%TYPE,
     p_verify_budget_rules        IN    VARCHAR2,
     x_fc_version_created_flag    OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_return_status              OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                  OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                   OUT   NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

-- error handling variables
l_valid_flag      VARCHAR2(1); -- for PA_FIN_PLAN_UTILS.Check_Record_Version_Number
l_msg_count       NUMBER := 0;
l_err_msg_count   NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_error_msg_code  VARCHAR2(30);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);
l_err_stage       VARCHAR2(200);
l_valid1_flag     VARCHAR2(1);
l_valid2_flag     VARCHAR2(1);
x_err_code        NUMBER;
x_err_stage       VARCHAR2(2000);
x_err_stack       VARCHAR2(2000);

-- local variables
l_budget_type_code          pa_budget_versions.budget_type_code%TYPE;
l_project_type_class_code   pa_project_types.project_type_class_code%TYPE;
l_version_type              pa_budget_versions.version_type%TYPE;
l_ac_flag                   VARCHAR2(1);
l_ar_flag                   VARCHAR2(1);
l_resource_list_id          pa_budget_versions.resource_list_id%TYPE;
l_time_phased_type_code     pa_budget_entry_methods.time_phased_type_code%TYPE;
l_fin_plan_level_code       VARCHAR2(30);
l_fin_plan_class_code       pa_fin_plan_types_b.plan_class_code%TYPE;
l_fin_plan_type_id          pa_proj_fp_options.fin_plan_type_id%TYPE;
l_budget_entry_method_code  pa_budget_entry_methods.budget_entry_method_code%TYPE;
l_entry_level_code          pa_budget_entry_methods.entry_level_code%TYPE;
l_pm_product_code           pa_budget_versions.pm_product_code%TYPE;
l_workflow_is_used          VARCHAR2(1); -- flag to determine if workflow is used
l_warnings_only_flag        VARCHAR2(1);
l_funding_level             varchar2(2) default NULL;
l_mark_as_original          varchar2(30) default 'N';
l_created_by                pa_budget_versions.created_by%TYPE;
x_resource_list_assgmt_id   NUMBER;
v_emp_id                    NUMBER; -- employee id
v_project_start_date        date;
v_project_completion_date   date;
--The following varible is added to make program consistent with the
--changed copy_version procedure prototype
l_target_version_id         PA_BUDGET_VERSIONS.budget_version_id%TYPE;
l_fc_version_id1            PA_BUDGET_VERSIONS.budget_version_id%TYPE;
l_fc_version_id2            PA_BUDGET_VERSIONS.budget_version_id%TYPE;
l_ci_id_tbl                 pa_plsql_datatypes.idTabTyp;
l_fc_version_type           PA_BUDGET_VERSIONS.version_type%TYPE;
l_version_name              PA_BUDGET_VERSIONS.version_name%TYPE;
l_base_line_ver_exists      VARCHAR2(1);
l_curr_work_ver_id          pa_budget_versions.budget_version_id%TYPE;
l_curr_work_fp_opt_id       pa_proj_fp_options.proj_fp_options_id%TYPE;
l_fp_options_id             pa_proj_fp_options.proj_fp_options_id%TYPE;
l_auto_baseline_project     pa_projects_all.baseline_funding_flag%TYPE;

l_fc_plan_type_ids_tbl       SYSTEM.pa_num_tbl_type DEFAULT SYSTEM.pa_num_tbl_type();
l_fc_pt_pref_code_tbl        SYSTEM.pa_varchar2_30_tbl_type DEFAULT SYSTEM.pa_varchar2_30_tbl_type();
l_primary_cost_fcst_flag_tbl SYSTEM.pa_varchar2_1_tbl_type DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
l_primary_rev_fcst_flag_tbl  SYSTEM.pa_varchar2_1_tbl_type DEFAULT SYSTEM.pa_varchar2_1_tbl_type();
l_dummy                      VARCHAR2(1);
l_module_name                VARCHAR2(100):='PAFPPVTB.Baseline_FinPlan';
l_tmp_incl_method_code_tbl   SYSTEM.pa_varchar2_30_tbl_type DEFAULT SYSTEM.pa_varchar2_30_tbl_type(); -- Bug 3756079
l_temp_ci_id_tbl             SYSTEM.pa_num_tbl_type DEFAULT SYSTEM.pa_num_tbl_type(); -- Bug 3756079
l_version_type_tbl           SYSTEM.pa_varchar2_30_tbl_type DEFAULT SYSTEM.pa_varchar2_30_tbl_type(); -- Bug 3756079
l_cw_creation_date_tbl       SYSTEM.PA_DATE_TBL_TYPE DEFAULT SYSTEM.PA_DATE_TBL_TYPE(); -- Bug 3756079
l_bl_creation_date_tbl       SYSTEM.PA_DATE_TBL_TYPE DEFAULT SYSTEM.PA_DATE_TBL_TYPE(); -- Bug 3756079



 -- Bug 4583454, jwhite, 12-SEP-05 -------------------
 l_migration_code            pa_resource_lists_all_bg.migration_code%TYPE := NULL;
 l_uncategorized_flag        pa_resource_lists_all_bg.uncategorized_flag%TYPE := NULL;



CURSOR c_chk_rej_codes
IS
SELECT 'Y'
FROM    DUAL
WHERE   EXISTS (SELECT 1
                FROM   pa_budget_lines pbl
                WHERE  pbl.budget_version_id = p_budget_version_id
                AND(       pbl.cost_rejection_code         IS NOT NULL
                    OR     pbl.revenue_rejection_code      IS NOT NULL
                    OR     pbl.burden_rejection_code       IS NOT NULL
                    OR     pbl.other_rejection_code        IS NOT NULL
                    OR     pbl.pc_cur_conv_rejection_code  IS NOT NULL
                    OR     pbl.pfc_cur_conv_rejection_code IS NOT NULL));

BEGIN
  FND_MSG_PUB.initialize;
	IF p_pa_debug_mode = 'Y' THEN
	  pa_debug.init_err_stack('PA_FIN_PLAN_PUB.Baseline_FinPlan');
	END IF;
  l_created_by:=FND_GLOBAL.user_id;
  l_msg_count := 0;

  ------------ CHECK FOR BUSINESS RULES VIOLATIONS --------------
  -- 1. RECORD VERSION NUMBER -- If record_version_number of p_budget_version_id
  --    has changed, return error:
  -- check to see if the old current baselined budget version has
  -- been updated by someone else already
  -- if p_orig_budget_version_id = null then there is currently not a baselined version
  -- in this case, ignore this check
  if p_orig_budget_version_id IS NOT null then
      PA_FIN_PLAN_UTILS.Check_Record_Version_Number
              (p_unique_index             => p_orig_budget_version_id,
               p_record_version_number    => p_orig_record_version_number,
               x_valid_flag               => l_valid2_flag,
               x_return_status            => x_return_status,   --l_return_status,   Bug 2691822
               x_error_msg_code           => l_error_msg_code);
      if not((l_valid1_flag='Y') and (l_valid2_flag='Y')) then
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Baseline_FinPlan: ' || 'BUSINESS RULE VIOLATION: Check_Record_Version_Number failed');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
        p_msg_name            => l_error_msg_code);
      end if;
  end if;

----- IF THERE ARE ANY BUSINESS RULES VIOLATIONS, DO NOT PROCEED ----
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
	IF p_pa_debug_mode = 'Y' THEN
	     pa_debug.reset_err_stack;
	END IF;
     return;
  end if;

  ----- IF NO BUSINESS RULES VIOLATIONS, PROCEED AS USUAL -----
--dbms_output.put_line('All violation checks passed');

  -- retrieve all necessary parameters for further processing
  -- Fix for bug 2640785 approved plan type flags to be got from budget versions
  -- instead from plan version level fp options.
  -- budget version version_type to be used instead of preference_code from
  -- proj_fp_options.

  savepoint before_fp_baseline;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_fc_version_created_flag := 'N';

  select bv.budget_type_code,
         bv.resource_list_id,
         bv.version_type,
         pt.project_type_class_code,
         bv.approved_rev_plan_type_flag,
         bv.approved_cost_plan_type_flag,
         DECODE(bv.version_type,
                'COST',opt.cost_time_phased_code,
                'REVENUE',opt.revenue_time_phased_code,
                opt.all_time_phased_code),
         DECODE(bv.version_type,
                'COST',opt.cost_fin_plan_level_code,
                'REVENUE',opt.revenue_fin_plan_level_code,
                opt.all_fin_plan_level_code),
         bv.budget_entry_method_code,
         bv.pm_product_code,
         /* bv.created_by, Commented for bug 6176649 */
         opt.fin_plan_type_id,
         pavl.plan_class_code,
         nvl(pr.baseline_funding_flag,'N')
    into l_budget_type_code,
         l_resource_list_id,
         l_version_type,
         l_project_type_class_code,
         l_ar_flag,
         l_ac_flag,
         l_time_phased_type_code,
         l_fin_plan_level_code,
         l_budget_entry_method_code,
         l_pm_product_code,
         /* l_created_by, Commented for bug 6176649 */
         l_fin_plan_type_id,
         l_fin_plan_class_code,
         l_auto_baseline_project
     from pa_project_types_all pt,
          pa_projects_all pr,
          pa_budget_versions bv,
          pa_proj_fp_options opt,
          pa_fin_plan_types_b pavl
     where  bv.budget_version_id = p_budget_version_id and
            opt.fin_plan_version_id = bv.budget_version_id and
            bv.project_id = pr.project_id and
            pr.project_type = pt.project_type and
            --nvl(pr.org_id,-99) = nvl(pt.org_id,-99) and --Bug 5374346
            pr.org_id = pt.org_id and
            opt.fin_plan_type_id = pavl.fin_plan_type_id and
            opt.fin_plan_option_level_code = 'PLAN_VERSION';

  --If the budget version being baselined is an approved revenue version, then the baseline should not happen
  --if that version has budget lines with rejection codes
  IF l_ar_flag='Y' THEN

      OPEN c_chk_rej_codes;
      FETCH c_chk_rej_codes INTO l_dummy;
      IF c_chk_rej_codes%FOUND THEN

          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage:= 'budget lines with rejection codes EXIST in ar version';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
          END IF;

          PA_UTILS.ADD_MESSAGE
          (p_app_short_name => 'PA',
           p_msg_name       => 'PA_FP_AR_BV_REJ_CODES_EXIST');


           CLOSE c_chk_rej_codes;
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      CLOSE c_chk_rej_codes;

  END IF;


  if l_budget_entry_method_code is not null then
    select entry_level_code
      into l_entry_level_code
      from pa_budget_entry_methods
      where budget_entry_method_code = l_budget_entry_method_code;
  end if;

--dbms_output.put_line('big select statement executed');
  -- Check whether workflow is being used for this project budget
  -- If so, get the employee id based on the baselined_by_user_id
  PA_CLIENT_EXTN_BUDGET_WF.Budget_Wf_Is_Used
        (p_draft_version_id     =>      p_budget_version_id,
         p_project_id           =>      p_project_id,
         p_budget_type_code     =>      NULL,
         p_pm_product_code      =>      l_pm_product_code,
         p_fin_plan_type_id     =>      l_fin_plan_type_id,
         p_version_type         =>      l_version_type,
         p_result               =>      l_workflow_is_used,
         p_err_code             =>      x_err_code,               --l_return_status,  Bug 2691822.
         p_err_stage            =>      l_err_stage,
         p_err_stack            =>      l_msg_data);
   If l_workflow_is_used =  'T' Then
     v_emp_id := pa_utils.GetEmpIdFromUser(pa_budget_wf.g_baselined_by_user_id);
   end if;
--dbms_output.put_line('PA_CLIENT_EXTN_BUDGET_WF.Budget_Wf_Is_Used executed');
  -- Verify budget rules if indicated
  -- This API call is different from in PA_BUDGET_CORE.baseline
  -- We need to set p_budget_type_code = null so that the verify API will use
  -- p_fin_plan_type_id and p_version_type for the new budget model
  if p_verify_budget_rules = 'Y' then

    PA_BUDGET_UTILS.Verify_Budget_Rules
            (p_draft_version_id         =>      p_budget_version_id,
             p_mark_as_original         =>      l_mark_as_original,
             p_event                    =>      'BASELINE',
             p_project_id               =>      p_project_id,
             p_budget_type_code         =>      NULL,
             p_fin_plan_type_id         =>      l_fin_plan_type_id,
             p_version_type             =>      l_version_type,
             p_resource_list_id         =>      l_resource_list_id,
             p_project_type_class_code  =>      l_project_type_class_code,
             p_created_by               =>      l_created_by,
             p_calling_module           =>      'PA_SS_FIN_PLANNING',
             p_warnings_only_flag       =>      l_warnings_only_flag,
             p_err_msg_count            =>      l_err_msg_count,
             p_err_code                 =>      x_err_code,
             p_err_stage                =>      x_err_stage,
             p_err_stack                =>      x_err_stack);

    -- if the only messages are warnings, we can proceed as usual.  Otherwise,
    -- return with error messages

    if (l_err_msg_count > 0 ) then
          if (l_warnings_only_flag = 'N') then
            /*
            PA_UTILS.Add_Message(p_app_short_name => 'PA',
                                 p_msg_name => x_err_code);
            */

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
    end if;
  end if; -- verify budget rules


--dbms_output.put_line('proceeding with baselining');
  --- BUDGET RULES VERIFIED AND OK, PROCEED WITH BASELINING ---

  -- if version is APPROVED REVENUE plan type, and project is CONTRACT project,
  -- 1.  Check funding level (pa_billing_core.check_funding_level)
  -- 2.  Call update funding (pa_billing_core.update_funding)

  IF ((l_ar_flag = 'Y') AND (l_project_type_class_code = 'CONTRACT')) THEN
    pa_billing_core.check_funding_level (p_project_id,
                                         l_funding_level,
                                         x_err_code,
                                         x_err_stage,
                                         x_err_stack);
    if (x_err_code <> 0) then
            PA_UTILS.Add_Message(p_app_short_name => 'PA',
                                 p_msg_name => x_err_code);

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


    pa_billing_core.update_funding (p_project_id,
                                    l_funding_level,
                                    x_err_code,
                                    x_err_stage,
                                    x_err_stack);
    if (x_err_code <> 0) then
            PA_UTILS.Add_Message(p_app_short_name => 'PA',
                                 p_msg_name => x_err_code);

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

  ELSIF ((l_ac_flag = 'Y') AND (l_project_type_class_code <> 'CONTRACT')) THEN
    -- if the version is APPROVED COST plan type, and project is NOT CONTRACT,
    -- 1.  Call update funding (pa_billing_core.update_funding)
    pa_billing_core.update_funding(p_project_id,
                                   l_funding_level,     -- Funding level
                                   x_err_code,
                                   x_err_stage,
                                   x_err_stack);
    if (x_err_code <> 0) then
            PA_UTILS.Add_Message(p_app_short_name => 'PA',
                                 p_msg_name => x_err_code);

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

END IF;  -- of AR revenue budget

  /* set the status_code back to "Working" from "Submitted" for the version we're baselining */
--dbms_output.put_line('updating pa_budget_versions');
  update pa_budget_versions
    set last_update_date = SYSDATE,
        last_updated_by = FND_GLOBAL.user_id,
        last_update_login = FND_GLOBAL.login_id,
        budget_status_code =  PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING, -- bug 3978894 'W',
        record_version_number = record_version_number+1
    where budget_version_id = p_budget_version_id;

    --Bug 3882819. The impact of  partially implemented change orders should be considered
    --as fully implemented when the approved revenue version gets baselined.For AutoBaselined projects
    --the  baselining will happen for each and implementation (full/partial also) of financial impact
    --and hence partial implementation of change orders should be supported even after baselining.
    IF l_ar_flag ='Y' AND
       NVL(l_auto_baseline_project,'N')='N' THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Updating the rev_partially_impl_flag in partially implemented CIs';
        pa_debug.write('pa_fin_plan_pvt: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        UPDATE pa_budget_versions
        SET    last_update_date = SYSDATE,
               last_updated_by = FND_GLOBAL.user_id,
               last_update_login = FND_GLOBAL.login_id,
               record_version_number = record_version_number+1,
               rev_partially_impl_flag='N'
        WHERE  project_id = p_project_id
        AND    ci_id IS NOT NULL
        AND    rev_partially_impl_flag='Y';

        IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'No of records updated '||SQL%ROWCOUNT;
        pa_debug.write('pa_fin_plan_pvt: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

    END IF;

--dbms_output.put_line('Set status code back to working from submitted');
  -- IF baselined_version_id DOES NOT EXIST:
  --    1. Create resource list assignments (pa_res_list_assignments.create_rl_assgmt)
  --    2. Create resource list uses (pa_res_list_assignments.create_rl_uses)


    if (p_orig_budget_version_id IS NULL) then
--dbms_output.put_line('NO ORIG BASELINED VERSION');



    -- Bug 4583454, jwhite, 12-SEP-05 -------------------------------------------
    -- Restoration of FP Budget Support in PSI/summrizartion also requires
    -- restoration of these two procedure calls for the following:
    -- 1) Resource lists originally created in the Resource List form.
    -- 2) Uncategorized "None" Resource Lists.
    --

    SELECT migration_code
           ,uncategorized_flag
    INTO   l_migration_code, l_uncategorized_flag
    FROM   pa_resource_lists_all_bg
    WHERE  resource_list_id = l_resource_list_id;


    IF ( (nvl(l_migration_code,'M') = 'M')
             OR  (l_uncategorized_flag = 'Y')  )
      THEN



           pa_res_list_assignments.create_rl_assgmt(x_project_id => p_project_id,
                                                    X_Resource_list_id =>l_resource_list_id,
                                                    X_Resource_list_Assgmt_id => x_resource_list_assgmt_id,
                                                    X_err_code => x_err_code,
                                                    X_err_stage =>x_err_stage,
                                                    x_err_stack =>x_err_stack);
           -- if oracle or application error, return

           if (x_err_code <> 0) then
                 PA_UTILS.Add_Message(p_app_short_name => 'PA',
                                      p_msg_name => x_err_code);

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

           pa_res_list_assignments.create_rl_uses(X_Project_id => p_project_id,
                                                  X_Resource_list_Assgmt_id => x_resource_list_assgmt_id,
                             --CONFIRM WITH JEFF AS THIS API EXPECTS A BUDGET_TYPE_CODE
                             --Reference update by Ramesh in bug 2622657. Should have use l_fin_plan_type_id
                             --as X_Use_Code
                                                  X_Use_Code => l_fin_plan_type_id,
                                                  X_err_code => x_err_code,
                                                  X_err_stage => x_err_stage,
                                                  X_err_stack => x_err_stack);
            -- if oracle or application error, return.

            if (x_err_code <> 0) then
                 PA_UTILS.Add_Message(p_app_short_name => 'PA',
                                      p_msg_name => x_err_code);

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

      END IF; -- l_migration_code

      -- Bug 4583454, jwhite, 12-SEP-05 -------------------------------------------


  else
  -- IF baselined_version_id EXISTS --> set CURRENT_FLAG to 'N' to remove current baselined
  -- status
    update pa_budget_versions
      set last_update_date = SYSDATE,
          last_updated_by = FND_GLOBAL.user_id,
          last_update_login = FND_GLOBAL.login_id,
          current_flag = 'N',
          record_version_number = record_version_number+1
      where budget_version_id=p_orig_budget_version_id;
--dbms_output.put_line('THERE IS ORIG BUDGET VERSION ID: set it to be NOT CURRENT BASELINED');
  end if;

  -- Proceed with the rest of the steps for baselining (see PAFPPUBB.Baseline for all
  -- the steps for baselining)

  /* create a copy, labeled as 'BASELINED' */

  PA_FIN_PLAN_PUB.Copy_Version
            (p_project_id           => p_project_id,
             p_source_version_id    => p_budget_version_id,
             p_copy_mode            => 'B',
             p_calling_module       => 'FINANCIAL_PLANNING',
             px_target_version_id   => l_target_version_id,
             x_return_status        => x_return_status,      --l_return_status, bug 2691822
             x_msg_count            => l_msg_count,
             x_msg_data             => l_msg_data);
  /* PA_FIN_PLAN_PUB.Copy_Version may have generated errors */
--dbms_output.put_line('PA_FIN_PLAN_PUB.Copy_Version executed');
  if x_return_status <> FND_API.G_RET_STS_SUCCESS then     -- bug 2691822
            PA_UTILS.Add_Message(p_app_short_name => 'PA',
                                 p_msg_name => x_err_code);

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
  /* Bug 3756079:-dbora- The following piece of code flips the value of
   * inclusion_method_code and creation_date in pa_fp_merged_ctrl_items for the existing
   * working version and the newly created baselined version as this value
   * would be used in the view included change document page to show various
   * change documents included in that version
   */
  IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'After Copy Version-- Firing Select';
        pa_debug.write('pa_fin_plan_pvt: ' || l_module_name,pa_debug.g_err_stage,5);
  END IF;

  SELECT ci_id, inclusion_method_code, version_type, creation_date
  BULK COLLECT INTO l_temp_ci_id_tbl, l_tmp_incl_method_code_tbl, l_version_type_tbl, l_cw_creation_date_tbl
  FROM    pa_fp_merged_ctrl_items
  WHERE   plan_version_id = p_budget_version_id
  AND     project_id = p_project_id;

  -- selecting creation_date for the baselined version
  SELECT creation_date
  BULK COLLECT INTO l_bl_creation_date_tbl
  FROM    pa_fp_merged_ctrl_items
  WHERE   plan_version_id = l_target_version_id
  AND     project_id = p_project_id;

  IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Rows returned in ci_id tbl: ' || l_temp_ci_id_tbl.COUNT;
        pa_debug.write('pa_fin_plan_pvt: ' || l_module_name,pa_debug.g_err_stage,5);
  END IF;
  -- Flipping inclusion_method_code, creation_date, Updating the WHO columns for the baselined version
  IF l_temp_ci_id_tbl.COUNT > 0 THEN
       FORALL i in l_temp_ci_id_tbl.FIRST..l_temp_ci_id_tbl.LAST
            UPDATE pa_fp_merged_ctrl_items
            SET    inclusion_method_code = l_tmp_incl_method_code_tbl(i),
                   creation_date = l_cw_creation_date_tbl(i),
                   last_update_login = FND_GLOBAL.login_id,
                   last_updated_by   = FND_GLOBAL.user_id,
                   last_update_date  = SYSDATE
            WHERE  plan_version_id = l_target_version_id
            AND    project_id = p_project_id
            AND    ci_id = l_temp_ci_id_tbl(i)
            AND    version_type = l_version_type_tbl(i);
  END IF;

  -- Flipping inclusion_method_code, creation_date, Updating the WHO columns for the working version
  IF l_temp_ci_id_tbl.COUNT > 0 THEN
       FORALL i in l_temp_ci_id_tbl.FIRST..l_temp_ci_id_tbl.LAST
            UPDATE pa_fp_merged_ctrl_items
            SET    inclusion_method_code = 'COPIED',
                   creation_date = l_bl_creation_date_tbl(i),
                   last_update_login = FND_GLOBAL.login_id,
                   last_updated_by   = FND_GLOBAL.user_id,
                   last_update_date  = SYSDATE
            WHERE  plan_version_id = p_budget_version_id
            AND    project_id = p_project_id
            AND    ci_id = l_temp_ci_id_tbl(i)
            AND    version_type = l_version_type_tbl(i);
  END IF;
  -- Bug 4187704: grouped the update statments into 2 distinct sets for baselined and working versions
  -- Bug 3756079: Finish

/* Bug 3841942 Raja 21-Sep-04
   For none time phased budgets transaction start and end dates are not
   only criteria. The following logic is not applicable beyond FP M

  -- Handle project date/task date changes
  --  If the effective dates on Project/Tasks
  -- has changed for Non Time phased budgets, then update the
  -- start and end dates on the budget lines.

  if (l_time_phased_type_code = 'N') and (l_entry_level_code = 'P') then -- Project Level
      select start_date,completion_date
        into v_project_start_date,
             v_project_completion_date
        from pa_projects_all
        where project_id = p_project_id;

      if (v_project_start_date is null ) or (v_project_completion_date is null) then
            PA_UTILS.Add_Message(p_app_short_name => 'PA',
                                 p_msg_name => 'PA_BU_NO_PROJ_END_DATE');
      end if;

      update pa_budget_lines
        set start_date= v_project_start_date,
            end_date = v_project_completion_date
        where resource_assignment_id in
            (select resource_assignment_id
             from pa_resource_assignments
             where budget_version_id = l_target_version_id)
        and ((start_date <> v_project_start_date) OR (end_date <> v_project_completion_date));

    -- Check that rows should be updated only if the project start or end
    -- dates are different from the budget start and end dates

      elsif (l_time_phased_type_code = 'N') then -- Task Level

        select start_date,completion_date
        into v_project_start_date,
             v_project_completion_date
        from pa_projects_all
        where project_id = p_project_id;

        for bl_rec in (select start_date,
                       completion_date ,
                       resource_assignment_id
                   from pa_tasks t ,pa_resource_assignments r
                   where t.task_id = r.task_id and
                         r.budget_version_id = l_target_version_id)
          loop
            bl_rec.start_date := nvl(bl_rec.start_date,v_project_start_date);
            bl_rec.completion_date := nvl(bl_rec.completion_date ,v_project_completion_date);

  -- Check that rows should be updated only if the task start or end
  -- dates are different from the budget start and end dates

            if (bl_rec.start_date is null) or (bl_rec.completion_date is null) then
              PA_UTILS.Add_Message(p_app_short_name => 'PA',
                                 p_msg_name => 'PA_BU_NO_TASK_PROJ_DATE');
            else
              update pa_budget_lines
                set start_date = bl_rec.start_date,
                    end_date   = bl_rec.completion_date
                where resource_assignment_id = bl_rec.resource_assignment_id and
                      ((start_date <> bl_rec.start_date) or (end_date <> bl_rec.completion_date));
            end if;

        end loop;

  end if;


x_msg_count := FND_MSG_PUB.Count_Msg;
if x_msg_count = 1 then
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE,
                      p_msg_index      => 1,
                      p_data           => x_msg_data,
                      p_msg_index_out  => l_msg_index_out);
end if;
if x_msg_count > 0 then
  x_return_status := FND_API.G_RET_STS_ERROR;
end if;

Bug 3841942 Raja 21-Sep-04 */

    --Bug 4094762. Code that creates the intial forecast version (its there below the PJI API call) assumes that the pji
    --data exists for the baselined version. Hence the PJI API call should be made before that code gets executed.
    /* FP M - Reporting lines integration */
    BEGIN
    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.write('Baseline_Finplan','Calling PJI_FM_XBS_ACCUM_MAINT.PLAN_BASELINE ' ,5);
         pa_debug.write('Baseline_Finplan','p_baseline_version_id  '|| p_budget_version_id,5);
         pa_debug.write('Baseline_Finplan', 'p_new_version_id '|| l_target_version_id,5);
    END IF;
         PJI_FM_XBS_ACCUM_MAINT.PLAN_BASELINE   (
              p_baseline_version_id => p_budget_version_id,
              p_new_version_id      => l_target_version_id,
              x_return_status       => l_return_status,
              x_msg_code            => l_error_msg_code);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
              PA_UTILS.ADD_MESSAGE(p_app_short_name      => PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA,
                                   p_msg_name            => l_error_msg_code);

              RAISE pa_fin_plan_pub.rollback_on_error;
         END IF;
    END;

    /* FP M - If approved budget version is baselined for the first time, forecast version should be created */

    /* Business rules given by PM (JR) - 21st Feb 2004

      # An initial forecast version will be created as per copy from the budget version, including the plan settings and amounts. For example:

      o In the budget version, cost and revenue are planned together, whereas in the forecast plan type, cost and revenue are planned separately
      X Two initial forecast versions will be created: cost version and forecast version.

      o In the budget version, cost and revenue are planned separately, whereas in the forecast plan type, cost and revenue are planned together:
      X An initial forecast version will be created: cost and revenue version.
      X Either cost amount or revenue amounts will be copied to that  initial forecast version, depending on which budget version is first baselined (cost or revenue).

      o In the budget version, cost and revenue are planned separately, as in the forecast plan type.
      X When cost budget is baselined, the initial cost forecast version will be created.
      X When revenue budget is baselined, the initial revenue forecast version will be created. */

    IF l_fin_plan_class_code = 'BUDGET' and
       (l_ar_flag  = 'Y' or
        l_ac_flag  = 'Y') THEN /* Only if the version that is being baselined is an AR or AC BUDGET version */

         IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('PAFPPVTB.BASELINE_FINPLAN','BUDGET plan class and ac flag is ' || l_ar_flag || ' and ac flag is ' || l_ac_flag,3);
         END IF;

         Begin
              Select 'Y'
              Into   l_base_line_ver_exists
              From   Pa_Budget_Versions
              Where  Project_id = p_project_id
              And    budget_type_code is null /* Bug 4200168*/
              And    Fin_plan_type_id = l_fin_plan_type_id
              And    Budget_status_code = 'B'
              And    Version_type = l_version_type
              And    Ci_Id Is Null
              And    Budget_version_id <> l_target_version_id
              And    Rownum < 2;
         Exception
         When No_Data_Found Then
              l_base_line_ver_exists := 'N';
         End;

         IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('PAFPPVTB.BASELINE_FINPLAN','l_base_line_ver_exists ' || l_base_line_ver_exists || ' l_version_type ' || l_version_type,3);
         END IF;

         If l_base_line_ver_exists = 'N' THEN /* No further processing for creation of forecast version is required if an appr baseline version already exists */

              Select fin_plan_type_id,fin_plan_preference_code,primary_cost_forecast_flag, primary_rev_forecast_flag
              Bulk Collect
              Into   l_fc_plan_type_ids_tbl,l_fc_pt_pref_code_tbl,l_primary_cost_fcst_flag_tbl,l_primary_rev_fcst_flag_tbl
              From   Pa_proj_fp_options
              Where  Project_Id = p_project_id
              And    Fin_Plan_Option_Level_Code = 'PLAN_TYPE'
              And    (primary_cost_forecast_flag = 'Y' or
                      primary_rev_forecast_flag = 'Y');

              If l_fc_plan_type_ids_tbl.count > 0 Then /* Only if forecast plan types have been added to the project */

                   FOR i IN l_fc_plan_type_ids_tbl.FIRST .. l_fc_plan_type_ids_tbl.LAST LOOP

                        IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.write('PAFPPVTB.BASELINE_FINPLAN','l_fc_plan_type_ids_tbl ' || l_fc_plan_type_ids_tbl(i) ||
                                                                        ' l_fc_pt_pref_code_tbl ' || l_fc_pt_pref_code_tbl(i),3);
                        END IF;

                        l_curr_work_ver_id := Null;
                        l_curr_work_fp_opt_id := Null;
                        l_fc_version_type  := Null;
                        l_version_name := Null;

                        If (l_version_type = 'ALL' or l_version_type = 'COST')  and
                           (l_fc_pt_pref_code_tbl(i) <> 'REVENUE_ONLY') and
                           (l_ac_flag = 'Y') and
                           (l_primary_cost_fcst_flag_tbl(i) = 'Y') THEN

                             IF l_fc_pt_pref_code_tbl(i)  = 'COST_AND_REV_SAME' THEN
                                  l_fc_version_type := 'ALL';
                                  l_version_name := ' ';
                             ELSE
                                  l_fc_version_type := 'COST';
                                  l_version_name := ' Cost ';
                             END IF;

                             Pa_Fin_Plan_Utils.Get_Curr_Working_Version_Info(
                                  p_project_id            => p_project_id
                                  ,p_fin_plan_type_id     => l_fc_plan_type_ids_tbl(i)
                                  ,p_version_type         => l_fc_version_type
                                  ,x_fp_options_id        => l_fp_options_id
                                  ,x_fin_plan_version_id  => l_curr_work_ver_id
                                  ,x_return_status        => x_return_status
                                  ,x_msg_count            => x_msg_count
                                  ,x_msg_data             => x_msg_data);

                             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                  IF P_PA_DEBUG_MODE = 'Y' THEN
                                       pa_debug.g_err_stage:='Pa_Fin_Plan_Utils.Get_Curr_Working_Version_Info errored: project_id : ' ||
                                                             p_project_id || ' : plan type id : ' || l_fc_plan_type_ids_tbl(i) ||
                                                             ' : version_type : ' || l_fc_version_type;
                                       pa_debug.write('PAFPPVTB.BASELINE_FINPLAN',pa_debug.g_err_stage,5);
                                  END IF;

                                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                             END IF;

                             /* FC Version would be created only when one already doesnt exists */
                             If l_curr_work_ver_id IS NULL THEN

                                  Pa_fin_plan_pub.Create_Version (
                                      p_project_id                        => p_project_id
                                      ,p_fin_plan_type_id                 => l_fc_plan_type_ids_tbl(i)
                                      ,p_element_type                     => l_fc_version_type
                                      ,p_version_name                     => 'Initial' || l_version_name || 'Forecast Version'
                                      ,p_description                      => 'Initial' || l_version_name || 'Forecast Version'
                                      ,p_calling_context                  => PA_FP_CONSTANTS_PKG.G_CREATE_DRAFT
                                      ,px_budget_version_id               => l_curr_work_ver_id
                                      ,x_proj_fp_option_id                => l_curr_work_fp_opt_id
                                      ,x_return_status                    => x_return_status
                                      ,x_msg_count                        => x_msg_count
                                      ,x_msg_data                         => x_msg_data);

                                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                       IF P_PA_DEBUG_MODE = 'Y' THEN
                                            pa_debug.g_err_stage:='Pa_fin_plan_pub.Create_Version errored. p_project_id ' ||
                                                                  p_project_id || ' : plan type id : ' || l_fc_plan_type_ids_tbl(i) ||
                                                                  ' : version_type : ' || l_fc_version_type;
                                            pa_debug.write('PAFPPVTB.BASELINE_FINPLAN',pa_debug.g_err_stage,5);
                                       END IF;

                                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                                  END IF;

                                  PA_FIN_PLAN_PUB.Copy_Version
                                       (p_project_id              => p_project_id,
                                        p_source_version_id       => l_target_version_id,
                                        p_copy_mode               => 'W',
                                        p_calling_module          => 'FINANCIAL_PLANNING',
                                        px_target_version_id      => l_curr_work_ver_id,
                                        x_return_status           => x_return_status,
                                        x_msg_count               => l_msg_count,
                                        x_msg_data                => l_msg_data);


                                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                       IF P_PA_DEBUG_MODE = 'Y' THEN
                                            pa_debug.g_err_stage:='PA_FIN_PLAN_PUB.Copy_Version errored: project_id : ' ||
                                                                  p_project_id || ' : l_target_version_id  : ' ||
                                                                  l_target_version_id || ' : l_fc_plan_type_ids_tbl(i) : ' ||
                                                                  l_fc_plan_type_ids_tbl(i);
                                            pa_debug.write('PAFPPVTB.BASELINE_FINPLAN',pa_debug.g_err_stage,5);
                                       END IF;

                                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                                  END IF;

                                  IF P_PA_DEBUG_MODE = 'Y' THEN
                                       pa_debug.write('PAFPPVTB.BASELINE_FINPLAN','l_curr_work_ver_id ' || l_curr_work_ver_id,3);
                                  END IF;

                                  x_fc_version_created_flag := 'Y';

                             END IF;

                        END IF;

                        l_curr_work_ver_id := Null;
                        l_curr_work_fp_opt_id := Null;
                        l_fc_version_type  := Null;
                        l_version_name := Null;

                        If (l_version_type = 'ALL' or l_version_type = 'REVENUE')  and
                           (l_fc_pt_pref_code_tbl(i) <> 'COST_ONLY') and
                           (l_ar_flag = 'Y') and
                           (l_primary_rev_fcst_flag_tbl(i) = 'Y') and
                           /* Bug 4200168: since we already have the current working version info from the previous call*/
                           (NOT(l_version_type = 'ALL' and l_fc_pt_pref_code_tbl(i) = 'COST_AND_REV_SAME'))THEN

                             IF l_fc_pt_pref_code_tbl(i)  = 'COST_AND_REV_SAME' THEN
                                  l_fc_version_type := 'ALL';
                                  l_version_name := ' ';
                             ELSE
                                  l_fc_version_type := 'REVENUE';
                                  l_version_name := ' Revenue ';
                             END IF;


                             Pa_Fin_Plan_Utils.Get_Curr_Working_Version_Info(
                                  p_project_id            => p_project_id
                                  ,p_fin_plan_type_id     => l_fc_plan_type_ids_tbl(i)
                                  ,p_version_type         => l_fc_version_type
                                  ,x_fp_options_id        => l_fp_options_id
                                  ,x_fin_plan_version_id  => l_curr_work_ver_id
                                  ,x_return_status        => x_return_status
                                  ,x_msg_count            => x_msg_count
                                  ,x_msg_data             => x_msg_data);

                             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                  IF P_PA_DEBUG_MODE = 'Y' THEN
                                       pa_debug.g_err_stage:='Pa_Fin_Plan_Utils.Get_Curr_Working_Version_Info errored: project_id : ' ||
                                                             p_project_id || ' : plan type id : ' || l_fc_plan_type_ids_tbl(i) ||
                                                             ' : version_type : ' || l_fc_version_type;
                                       pa_debug.write('PAFPPVTB.BASELINE_FINPLAN',pa_debug.g_err_stage,5);
                                  END IF;

                                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                             END IF;

                             /* FC Version would be created only when one already doesnt exists */
                             If l_curr_work_ver_id IS NULL THEN

                                  Pa_fin_plan_pub.Create_Version (
                                      p_project_id                        => p_project_id
                                      ,p_fin_plan_type_id                 => l_fc_plan_type_ids_tbl(i)
                                      ,p_element_type                     => l_fc_version_type
                                      ,p_version_name                     => 'Initial' || l_version_name || 'Forecast Version'
                                      ,p_description                      => 'Initial' || l_version_name || 'Forecast Version'
                                      ,p_calling_context                  => PA_FP_CONSTANTS_PKG.G_CREATE_DRAFT
                                      ,px_budget_version_id               => l_curr_work_ver_id
                                      ,x_proj_fp_option_id                => l_curr_work_fp_opt_id
                                      ,x_return_status                    => x_return_status
                                      ,x_msg_count                        => x_msg_count
                                      ,x_msg_data                         => x_msg_data);

                                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                       IF P_PA_DEBUG_MODE = 'Y' THEN
                                            pa_debug.g_err_stage:='Pa_fin_plan_pub.Create_Version errored. p_project_id ' ||
                                                                  p_project_id || ' : plan type id : ' || l_fc_plan_type_ids_tbl(i) ||
                                                                  ' : version_type : ' || l_fc_version_type;
                                            pa_debug.write('PAFPPVTB.BASELINE_FINPLAN',pa_debug.g_err_stage,5);
                                       END IF;

                                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                                  END IF;

                                  PA_FIN_PLAN_PUB.Copy_Version
                                       (p_project_id              => p_project_id,
                                        p_source_version_id       => l_target_version_id,
                                        p_copy_mode               => 'W',
                                        p_calling_module          => 'FINANCIAL_PLANNING',
                                        px_target_version_id      => l_curr_work_ver_id,
                                        x_return_status           => x_return_status,
                                        x_msg_count               => l_msg_count,
                                        x_msg_data                => l_msg_data);


                                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                       IF P_PA_DEBUG_MODE = 'Y' THEN
                                            pa_debug.g_err_stage:='PA_FIN_PLAN_PUB.Copy_Version errored: project_id : ' ||
                                                                  p_project_id || ' : l_target_version_id  : ' ||
                                                                  l_target_version_id || ' : l_fc_plan_type_ids_tbl(i) : ' ||
                                                                  l_fc_plan_type_ids_tbl(i);
                                            pa_debug.write('PAFPPVTB.BASELINE_FINPLAN',pa_debug.g_err_stage,5);
                                       END IF;

                                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                                  END IF;

                                  IF P_PA_DEBUG_MODE = 'Y' THEN
                                       pa_debug.write('PAFPPVTB.BASELINE_FINPLAN','l_curr_work_ver_id ' || l_curr_work_ver_id,3);
                                  END IF;

                                  x_fc_version_created_flag := 'Y';

                             END IF;

                        END IF;

                   END LOOP; /* FOR i IN l_fc_plan_type_ids_tbl.FIRST .. l_fc_plan_type_ids_tbl.LAST LOOP */

              END IF; /* If l_fc_plan_type_ids_tbl.count > 0 Then */

         END IF; /* If l_base_line_ver_exists = 'N' THEN */

    END IF; /* IF l_fin_plan_class_code = 'BUDGET' and (l_ar_flag  = 'Y' or l_ac_flag  = 'Y') THEN */

	IF p_pa_debug_mode = 'Y' THEN
	    pa_debug.reset_err_stack;
	END IF;
EXCEPTION

    when pa_fin_plan_pvt.baseline_finplan_error then
        rollback to before_fp_baseline;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        return;
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
      rollback to before_fp_baseline;
      --Bug 4044009
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
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
	IF p_pa_debug_mode = 'Y' THEN
	      pa_debug.reset_err_stack;
	END IF;
    --Bug 4044009
    RETURN;
    when others then
        rollback to before_fp_baseline;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg(p_pkg_name         => 'PA_FIN_PLAN_PVT',
                                p_procedure_name   => 'Baseline_FinPlan');
	IF p_pa_debug_mode = 'Y' THEN
        pa_debug.reset_err_stack;
	END IF;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;

END Baseline_FinPlan;
/* ------------------------------------------------------------------------ */

-- HISTORY
-- 11/16/02 dlai: bug fix 2668857 - when joining pa_projects_all with
--                pa_project_types_all, need to join based on org_id as well
PROCEDURE Submit_Current_Working_FinPlan
    (p_project_id               IN      pa_budget_versions.project_id%TYPE,
     p_budget_version_id        IN      pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number    IN      pa_budget_versions.record_version_number%TYPE,
     x_return_status            OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                 OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

-- error handling variables
l_valid_flag      VARCHAR2(1); -- for PA_FIN_PLAN_UTILS.Check_Record_Version_Number
l_msg_count       NUMBER := 0;
l_err_msg_count   NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_error_msg_code  VARCHAR2(30);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);
l_err_code        NUMBER;
l_err_stage       VARCHAR2(2000);
l_err_stack       VARCHAR2(2000);

-- local variables
l_budget_type_code          pa_budget_versions.budget_type_code%TYPE;
l_resource_list_id          pa_budget_versions.resource_list_id%TYPE;
l_project_type_class_code   pa_project_types.project_type_class_code%TYPE;
l_version_type              pa_budget_versions.version_type%TYPE;
l_ac_flag                   VARCHAR2(1);
l_ar_flag                   VARCHAR2(1);
l_time_phased_type_code     pa_budget_entry_methods.time_phased_type_code%TYPE;
l_fin_plan_level_code       VARCHAR2(30);
l_fin_plan_type_code        VARCHAR2(30);
l_fin_plan_type_id          pa_proj_fp_options.fin_plan_type_id%TYPE;
l_entry_level_code          pa_budget_entry_methods.entry_level_code%TYPE;
l_pm_product_code           pa_budget_versions.pm_product_code%TYPE;
l_workflow_is_used          VARCHAR2(1); -- flag to determine if workflow is used
l_warnings_only_flag        VARCHAR2(1);
l_mark_as_original          varchar2(30) := 'N';
l_created_by                pa_budget_versions.created_by%TYPE;
v_emp_id                    NUMBER; -- employee id

BEGIN
  FND_MSG_PUB.initialize;
  IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.init_err_stack('PA_FIN_PLAN_PUB.Submit_Current_Working_FinPlan');
  END IF;
  x_msg_count := 0;

  /* Added for bug 6176649 */
  l_created_by:=FND_GLOBAL.user_id;


  ------------ CHECK FOR BUSINESS RULES VIOLATIONS --------------
  -- 1. RECORD VERSION NUMBER -- If record_version_number of p_budget_version_id
  --    has changed, return error:
  PA_FIN_PLAN_UTILS.Check_Record_Version_Number
            (p_unique_index             => p_budget_version_id,
             p_record_version_number    => p_record_version_number,
             x_valid_flag               => l_valid_flag,
             x_return_status            => l_return_status,
             x_error_msg_code           => l_error_msg_code);
    if x_return_status = FND_API.G_RET_STS_ERROR then
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Submit_Current_Working_FinPlan: ' || 'record version number error ');
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => l_error_msg_code);
    end if;

  ----- IF THERE ARE ANY BUSINESS RULES VIOLATIONS, DO NOT PROCEED ----
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
	IF p_pa_debug_mode = 'Y' THEN
	     pa_debug.reset_err_stack;
	END IF;
     return;
  end if;

  ----- IF NO BUSINESS RULES VIOLATIONS, PROCEED AS USUAL -----
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  savepoint before_fp_sbmt_cur_working;
--dbms_output.put_line('passed all violations');
  -- retrieve all necessary parameters for further processing
    select bv.budget_type_code,
           bv.resource_list_id,
           bv.version_type,
           pt.project_type_class_code,
           opt.approved_rev_plan_type_flag,
           opt.approved_cost_plan_type_flag,
         DECODE
         (opt.fin_plan_preference_code,
         'COST_ONLY',opt.cost_time_phased_code,
         'REVENUE_ONLY',opt.revenue_time_phased_code,
         'COST_AND_REV_SAME',opt.all_time_phased_code,
         DECODE
                (bv.version_type,
                'COST',opt.cost_time_phased_code,
                'REVENUE',opt.revenue_time_phased_code
                )
         ),
         DECODE
         (opt.fin_plan_preference_code,
         'COST_ONLY',opt.cost_fin_plan_level_code,
         'REVENUE_ONLY',opt.revenue_fin_plan_level_code,
         'COST_AND_REV_SAME',opt.all_fin_plan_level_code,
         DECODE
                (bv.version_type,
                'COST',opt.cost_fin_plan_level_code,
                'REVENUE',opt.revenue_fin_plan_level_code
                )
         ),
         pavl.fin_plan_type_code,
--           entry_level_code,
           bv.pm_product_code,
           /* bv.created_by,  Commented for bug 6176649 */
           opt.fin_plan_type_id
      into l_budget_type_code,
           l_resource_list_id,
           l_version_type,
         l_project_type_class_code,
         l_ar_flag,
         l_ac_flag,
           l_time_phased_type_code,
           l_fin_plan_level_code,
           l_fin_plan_type_code,
--           l_entry_level_code,
           l_pm_product_code,
           /* l_created_by,  Commented for bug 6176649 */
           l_fin_plan_type_id
       from pa_project_types_all pt,
              pa_projects_all pr,
              pa_budget_versions bv,
--            pa_budget_entry_methods be,
            pa_proj_fp_options opt,
            pa_fin_plan_types_b pavl
       where  bv.budget_version_id = p_budget_version_id and
              opt.fin_plan_version_id = bv.budget_version_id and
              bv.project_id = pr.project_id and
--              be.budget_entry_method_code = bv.budget_entry_method_code and
              pr.project_type = pt.project_type and
              --nvl(pr.org_id,-99) = nvl(pt.org_id,-99) and --Bug 5374346
              pr.org_id = pt.org_id and
              opt.fin_plan_type_id = pavl.fin_plan_type_id and
            opt.fin_plan_option_level_code = 'PLAN_VERSION';
--dbms_output.put_line('big select statement passed');
    -- Verify budget rules if indicated
    -- This API call is different from in PA_BUDGET_CORE.baseline
    -- We need to set p_budget_type_code = null so that the verify API will use
    -- p_fin_plan_type_id and p_version_type for the new budget model

        PA_BUDGET_UTILS.Verify_Budget_Rules
                (p_draft_version_id        =>   p_budget_version_id,
                 p_mark_as_original        =>   l_mark_as_original,
                 p_event                   =>   'SUBMIT',
                 p_project_id              =>   p_project_id,
                 p_budget_type_code        =>   NULL,
                 p_fin_plan_type_id        =>   l_fin_plan_type_id,
                 p_version_type            =>   l_version_type,
                 p_resource_list_id        =>   l_resource_list_id,
                 p_project_type_class_code =>   l_project_type_class_code,
                 p_created_by              =>   l_created_by,
                 p_calling_module          =>   'PA_SS_FIN_PLANNING',
                 p_warnings_only_flag      =>   l_warnings_only_flag,
                 p_err_msg_count           =>   l_err_msg_count,
                 p_err_code                =>   l_err_code,
                 p_err_stage               =>   l_err_stage,
                 p_err_stack               =>   l_err_stack);
        -- if the only messages are warnings, we can proceed as usual.  Otherwise,
        -- return with error messages

	/* Bug 6176649: Modified the error handling to add the message name to the stack in
	   case l_warnings_only_flag = 'N' */

        if (l_err_msg_count > 0 ) then
            if (l_warnings_only_flag = 'N') then

               x_return_status := FND_API.G_RET_STS_ERROR;
               x_msg_count := FND_MSG_PUB.Count_Msg;
               if x_msg_count = 1 then
                   PA_INTERFACE_UTILS_PUB.get_messages
                       (p_encoded        => FND_API.G_TRUE,
                        p_msg_index      => 1,
                        p_data           => x_msg_data,
                        p_msg_index_out  => l_msg_index_out);
               end if;
               RETURN;
            end if;
        end if;
--dbms_output.put_line('Verify_Budget_Rules called');
  --- BUDGET RULES VERIFIED AND OK, PROCEED WITH SUBMITTING CURRENT WORKING ---
  /* set the status_code to "S"  for the version we're submitting */
     update pa_budget_versions
       set last_update_date = SYSDATE,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id,
           budget_status_code = PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_SUBMITTED, -- bug 3978894 'S',
           record_version_number = record_version_number+1
       where budget_version_id = p_budget_version_id;
--dbms_output.put_line('update pa_budget_versions statement executed');
    -- Check whether workflow is being used for this project budget
    -- If so, get the employee id based on the baselined_by_user_id
    PA_CLIENT_EXTN_BUDGET_WF.Budget_Wf_Is_Used
        (p_draft_version_id     =>      p_budget_version_id,
         p_project_id           =>      p_project_id,
         p_budget_type_code     =>      NULL,
         p_pm_product_code      =>      l_pm_product_code,
         p_fin_plan_type_id     =>      l_fin_plan_type_id,
         p_version_type         =>      l_version_type,
         p_result               =>      l_workflow_is_used,
         p_err_code             =>      l_err_code,
         p_err_stage            =>      l_err_stage,
         p_err_stack            =>      l_err_stack);
--dbms_output.put_line('PA_CLIENT_EXTN_BUDGET_WF.Budget_Wf_Is_Used called');
    -- l_err_code = 0 ==> SUCCESS
    if l_err_code <> 0 then
      -- PA_CLIENT_EXTN_BUDGET_WF.Budget_Wf_Is_Used returned errors
--dbms_output.put_line('PA_CLIENT_EXTN_BUDGET_WF.Budget_Wf_Is_Used: RETURNED ERRORS');
      raise pa_fin_plan_pvt.check_wf_error;
    else
      If l_workflow_is_used =  'T' Then
        v_emp_id := pa_utils.GetEmpIdFromUser(pa_budget_wf.g_baselined_by_user_id);

        PA_BUDGET_WF.START_BUDGET_WF
         (p_draft_version_id    => p_budget_version_id,
          p_project_id          => p_project_id,
          p_budget_type_code    => NULL,
          p_mark_as_original    => l_mark_as_original,
          p_fck_req_flag        => NULL,
          p_bgt_intg_flag       => NULL,
          p_fin_plan_type_id    => l_fin_plan_type_id,
          p_version_type        => l_version_type,
          p_err_code            => l_err_code,
          p_err_stage           => l_err_stage,
          p_err_stack           => l_err_stack);
--dbms_output.put_line('START_BUDGET_WF called');
        -- l_err_code = 0 ==> SUCCESS
        if l_err_code <> 0 then
          -- PA_BUDGET_WF.START_BUDGET_WF returned errors
          raise pa_fin_plan_pvt.start_wf_error;
        else
          -- update pa_budget_versions: set wf_status_code =  'IN_ROUTE'
          update pa_budget_versions
            set wf_status_code = 'IN_ROUTE'
            where budget_version_id = p_budget_version_id;
        end if;
      end if;
    end if;

EXCEPTION
    when check_wf_error then
      rollback to before_fp_sbmt_cur_working;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    when start_wf_error then
      rollback to before_fp_sbmt_cur_working;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    when others then
        rollback to before_fp_sbmt_cur_working;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        FND_MSG_PUB.add_exc_msg(p_pkg_name         => 'PA_FIN_PLAN_PVT',
                                p_procedure_name   => 'Submit_Current_Working_FinPlan');
	IF p_pa_debug_mode = 'Y' THEN
        pa_debug.reset_err_stack;
	END IF;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;

END Submit_Current_Working_FinPlan;
/* ------------------------------------------------------------------------ */

/* get_included_ci is used in different modes as follows:
   p_from_bv_id -- Source version from where ci's need to be linked.
   p_to_bv_id   -- Target version where the ci's need to be linked. This
                   may be null if only ci's from source is required.
   p_impact_status -- can be NULL -- All Ci's,
                             CI_IMPACT_IMPLEMENTED -- Implemented ci's,
                             CI_IMPACT_PENDING -- Un-implemented ci's.

   When both p_from_bv_id and p_to_bv_id are passed then the resultant
   table x_ci_rec_tab is a table of ci's linked in p_from_bv_id version and
   not in p_to_bv_id version.

   Bug 3106741 For better performance the cursoe has been spilt into c1 and c2.
   Cursor c1 would be opened if  p_to_bv_id is not null.
   Cursor c2 would be opened if  p_to_bv_id is null.

   Modified for 3550073. Selected the amount columns in pa_fp_merged_ctrl_items in the
   cursors
*/

PROCEDURE Get_Included_Ci
    ( p_from_bv_id     IN pa_budget_versions.budget_version_id%TYPE
     ,p_to_bv_id       IN pa_budget_versions.budget_version_id%TYPE --DEFAULT NULL
     ,p_impact_status  IN pa_ci_impacts.status_code%TYPE
     ,x_ci_rec_tab    OUT NOCOPY pa_fin_plan_pvt.ci_rec_tab
     ,x_return_status OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count     OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data      OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS

cursor c1 is
       select f.ci_id, f.ci_plan_version_id, im.ci_impact_id ,
              f.version_type,
              f.impl_proj_func_raw_cost ,
              f.impl_proj_func_burdened_cost,
              f.impl_proj_func_revenue,
              f.impl_proj_raw_cost ,
              f.impl_proj_burdened_cost,
              f.impl_proj_revenue,
              decode(f.version_type,'COST',f.impl_quantity,NULL) impl_cost_ppl_qty,
              decode(f.version_type,'COST',f.impl_equipment_quantity,NULL) impl_cost_equip_qty,
              decode(f.version_type,'REVENUE',f.impl_quantity,NULL) impl_rev_ppl_qty,
              decode(f.version_type,'REVENUE',f.impl_equipment_quantity,NULL) impl_rev_equip_qty,
              f.impl_agr_revenue impl_agr_revenue,
              pbv.rev_partially_impl_flag rev_partially_impl_flag
         from pa_fp_merged_ctrl_items f,
              pa_ci_impacts im ,
              pa_budget_versions pbv
        where f.plan_version_id = p_from_bv_id
          and pbv.budget_version_id=f.ci_plan_version_id
          and im.ci_id = f.ci_id
          and im.impact_type_code IN ('FINPLAN_COST','FINPLAN_REVENUE')
          and im.status_code = nvl(p_impact_status,im.status_code)
          and decode(im.impact_type_code,
                     'FINPLAN_COST','COST',
                     'FINPLAN_REVENUE','REVENUE') = f.version_type
          and f.project_id=pbv.project_id
          and not exists
              (select 'x' from pa_fp_merged_ctrl_items t
                where t.plan_version_id = p_to_bv_id
                  and t.ci_id = f.ci_id
                  and f.version_type = t.version_type
                  and t.ci_plan_version_id = f.ci_plan_version_id
                  and t.project_id=f.project_id);
          --and p_to_bv_id IS NOT NULL;
cursor c2 is
       select f.ci_id, f.ci_plan_version_id, im.ci_impact_id ,
              f.version_type,
              f.impl_proj_func_raw_cost ,
              f.impl_proj_func_burdened_cost,
              f.impl_proj_func_revenue,
              f.impl_proj_raw_cost ,
              f.impl_proj_burdened_cost,
              f.impl_proj_revenue,
              decode(f.version_type,'COST',f.impl_quantity,NULL) impl_cost_ppl_qty,
              decode(f.version_type,'COST',f.impl_equipment_quantity,NULL) impl_cost_equip_qty,
              decode(f.version_type,'REVENUE',f.impl_quantity,NULL) impl_rev_ppl_qty,
              decode(f.version_type,'REVENUE',f.impl_equipment_quantity,NULL) impl_rev_equip_qty,
              f.impl_agr_revenue impl_agr_revenue,
              pbv.rev_partially_impl_flag rev_partially_impl_flag
         from pa_fp_merged_ctrl_items f,
              pa_ci_impacts im,
              pa_budget_versions pbv
        where f.plan_version_id = p_from_bv_id
          and pbv.budget_version_id=f.ci_plan_version_id
          and im.ci_id = f.ci_id
          and im.impact_type_code IN ('FINPLAN_COST','FINPLAN_REVENUE')
          and decode(im.impact_type_code,
                     'FINPLAN_COST','COST',
                     'FINPLAN_REVENUE','REVENUE') = f.version_type
          and im.status_code = nvl(p_impact_status,im.status_code)
          and f.project_id=pbv.project_id;
          --and p_to_bv_id IS NULL;

l_msg_index_out number;

BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     x_ci_rec_tab.delete;

     If  p_to_bv_id is not null then

         Open c1;

         Loop
           Fetch c1 into x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).ci_id,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).ci_plan_version_id,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).ci_impact_id,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).version_type,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_pfc_raw_cost,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_pfc_burd_cost,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_pfc_revenue,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_pc_raw_cost,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_pc_burd_cost,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_pc_revenue,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_cost_ppl_qty,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_cost_equip_qty,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_rev_ppl_qty,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_rev_equip_qty,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_agr_revenue,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).rev_partially_impl_flag;
           Exit when c1%NOTFOUND;
         End Loop;

         Close c1;
     Else
         Open c2;

         Loop
           Fetch c2 into x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).ci_id,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).ci_plan_version_id,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).ci_impact_id,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).version_type,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_pfc_raw_cost,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_pfc_burd_cost,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_pfc_revenue,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_pc_raw_cost,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_pc_burd_cost,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_pc_revenue,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_cost_ppl_qty,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_cost_equip_qty,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_rev_ppl_qty,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_rev_equip_qty,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).impl_agr_revenue,
                         x_ci_rec_tab(nvl(x_ci_rec_tab.last,0)+1).rev_partially_impl_flag;

           Exit when c2%NOTFOUND;
         End Loop;

         Close c2;

     End if;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count := FND_MSG_PUB.Count_Msg;

  EXCEPTION WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count := 1;
       x_msg_data  := substr(SQLERRM,1,240);

       fnd_msg_pub.add_exc_msg
           ( p_pkg_name       => 'pa_fin_plan_pvt'
            ,p_procedure_name => 'Get_Included_Ci'
            ,p_error_text     => substr(SQLERRM,1,240));

END Get_Included_Ci;

--Modified for 3550073. Handled the FINPLAN_COST, FINPLAN_REVENUE records in pa_ci_impacts
--Reset the rev_partially_impl flag for the CIs partially implemented in the old current working version
PROCEDURE handle_ci_links
    ( p_source_bv_id   IN pa_budget_versions.budget_version_id%TYPE
     ,p_target_bv_id   IN pa_budget_versions.budget_version_id%TYPE
     ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS

cursor c1 is
       select 'Y',
              bv.project_id,
              bv.fin_plan_type_id,
              bv.version_type
         from pa_fin_plan_types_b pt
             ,pa_budget_versions bv
        where pt.fin_plan_type_id = bv.fin_plan_type_id
          and bv.budget_version_id = p_target_bv_id
          and (pt.approved_cost_plan_type_flag = 'Y'
                            OR
               pt.approved_rev_plan_type_flag = 'Y');

l_approved_budget_plan_type varchar2(1) := 'N';
l_project_id           pa_projects_all.project_id%TYPE;
l_fin_plan_type_id     pa_budget_versions.fin_plan_type_id%TYPE;
l_version_type         pa_budget_versions.version_type%TYPE;
l_fp_options_id        pa_proj_fp_options.proj_fp_options_id%TYPE;
l_fin_plan_version_id  pa_proj_fp_options.fin_plan_version_id%TYPE;
l_ci_rec_tab           pa_fin_plan_pvt.ci_rec_tab;
l_return_status        VARCHAR2(2000);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_msg_index_out        number;
l_stage                NUMBER := null;
l_impact_type_code     pa_ci_impacts.impact_type_code%TYPE;

BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_stage := 10;
      open c1;
      l_stage := 20;
      fetch c1 into l_approved_budget_plan_type,
                    l_project_id,
                    l_fin_plan_type_id,
                    l_version_type;

      IF c1%notfound then
         l_stage := 30;
         l_approved_budget_plan_type := 'N';
      END IF;
      close c1;

         l_stage := 40;

      IF l_approved_budget_plan_type = 'Y' then
            l_stage := 50;
         /* Get latest baselined info */
            pa_fin_plan_utils.Get_Baselined_Version_Info(
                     p_project_id           => l_project_id
                    ,p_fin_plan_type_id     => l_fin_plan_type_id
                    ,p_version_type         => l_version_type
                    ,x_fp_options_id        => l_fp_options_id
                    ,x_fin_plan_version_id  => l_fin_plan_version_id
                    ,x_return_status        => l_return_status
                    ,x_msg_count            => l_msg_count
                    ,x_msg_data             => l_msg_data);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               fnd_msg_pub.add_exc_msg
                                      ( p_pkg_name       => 'pa_fin_plan_pvt'
                                       ,p_procedure_name => 'handle_ci_links'
                                       ,p_error_text     => to_char(l_stage)||': '||substr(SQLERRM,1,240));
            ELSE
               /* Get ci linked to latest baselined versions and not already present
                  in target version */
                  l_stage := 60;

               IF l_fin_plan_version_id IS NOT NULL THEN

                     l_stage := 70;
                     l_ci_rec_tab.delete;

                  pa_fin_plan_pvt.Get_Included_Ci(
                    p_from_bv_id    => l_fin_plan_version_id /* Baselined Version */
                  , p_to_bv_id      => p_target_bv_id        /* New Current Working */
                  , p_impact_status => NULL
                  , x_ci_rec_tab    => l_ci_rec_tab
                  , x_return_status => l_return_status
                  , x_msg_count     => l_msg_count
                  , x_msg_data      => l_msg_data);


                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     fnd_msg_pub.add_exc_msg
                                      ( p_pkg_name       => 'pa_fin_plan_pvt'
                                       ,p_procedure_name => 'handle_ci_links'
                                       ,p_error_text     => to_char(l_stage)||': '||substr(SQLERRM,1,240));
                  ELSE
                          l_stage := 80;
                       IF l_ci_rec_tab.count > 0 THEN
                              l_stage := 90;
                          FOR i in 1..l_ci_rec_tab.count LOOP
                              l_stage := 100;

                               pa_fp_ci_merge.FP_CI_LINK_CONTROL_ITEMS(
                                p_project_id            => l_project_id
                                ,p_s_fp_version_id      => l_ci_rec_tab(i).ci_plan_version_id
                                ,p_t_fp_version_id      => p_target_bv_id
                                ,p_inclusion_method     => 'COPIED'
                                --Added for bug 3550073
                                ,p_version_type         => l_ci_rec_tab(i).version_type
                                ,p_ci_id                => l_ci_rec_tab(i).ci_id
                                ,p_cost_ppl_qty         => l_ci_rec_tab(i).impl_cost_ppl_qty
                                ,p_rev_ppl_qty          => l_ci_rec_tab(i).impl_rev_ppl_qty
                                ,p_cost_equip_qty       => l_ci_rec_tab(i).impl_cost_equip_qty
                                ,p_rev_equip_qty        => l_ci_rec_tab(i).impl_rev_equip_qty
                                ,p_impl_pfc_raw_cost    => l_ci_rec_tab(i).impl_pfc_raw_cost
                                ,p_impl_pfc_revenue     => l_ci_rec_tab(i).impl_pfc_revenue
                                ,p_impl_pfc_burd_cost   => l_ci_rec_tab(i).impl_pfc_burd_cost
                                ,p_impl_pc_raw_cost     => l_ci_rec_tab(i).impl_pc_raw_cost
                                ,p_impl_pc_revenue      => l_ci_rec_tab(i).impl_pc_revenue
                                ,p_impl_pc_burd_cost    => l_ci_rec_tab(i).impl_pc_burd_cost
                                ,p_impl_agr_revenue     => l_ci_rec_tab(i).impl_agr_revenue
                                ,x_return_status        => l_return_status
                                ,x_msg_count            => l_msg_count
                                ,x_msg_data             => l_msg_data
                               )  ;

                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                   fnd_msg_pub.add_exc_msg
                                      ( p_pkg_name       => 'pa_fin_plan_pvt'
                                       ,p_procedure_name => 'handle_ci_links'
                                       ,p_error_text     => to_char(l_stage)||': '||substr(SQLERRM,1,240));
                                END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS
                          END LOOP;
                       END IF; -- l_ci_rec_tab.count > 0
                  END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS
               END IF; -- l_fin_plan_version_id IS NOT NULL
            END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS

                  /* Get CI from Old Current Working and not there in New Current Working
                     and change their status to un-implemented - At this stage New Current Working
                     contains the links to ci from Latest Baselined version */
                     l_stage := 110;
                     l_ci_rec_tab.delete;

                  pa_fin_plan_pvt.Get_Included_Ci(
                    p_from_bv_id    => p_source_bv_id  /* Old Current Working */
                  , p_to_bv_id      => p_target_bv_id  /* New Current Working */
                  , p_impact_status => 'CI_IMPACT_IMPLEMENTED'
                  , x_ci_rec_tab    => l_ci_rec_tab
                  , x_return_status => l_return_status
                  , x_msg_count     => l_msg_count
                  , x_msg_data      => l_msg_data);


                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     fnd_msg_pub.add_exc_msg
                                      ( p_pkg_name       => 'pa_fin_plan_pvt'
                                       ,p_procedure_name => 'handle_ci_links'
                                       ,p_error_text     => to_char(l_stage)||': '||substr(SQLERRM,1,240));
                  ELSE
                          l_stage := 120;
                       IF l_ci_rec_tab.count > 0 THEN
                          l_stage := 130;
                          FOR i in 1..l_ci_rec_tab.count LOOP
                              l_stage := 140;

                              IF  l_ci_rec_tab(i).version_type='COST' THEN
                                  l_impact_type_code:='FINPLAN_COST';
                              ELSIF l_ci_rec_tab(i).version_type='REVENUE' THEN
                                 l_impact_type_code:='FINPLAN_REVENUE';
                              END IF;

                              --If the CI has got partially implemented in the old current working version then the
                              --reset the rev_partially_impl_flag in the ci version
                              IF l_ci_rec_tab(i).rev_partially_impl_flag ='Y' THEN

                                  UPDATE pa_budget_versions
                                  SET    rev_partially_impl_flag='N',
                                         record_version_number=nvl(record_version_number,0)+1,
                                         last_updated_by=fnd_global.user_id,
                                         last_update_login=fnd_global.login_id,
                                         last_update_date=sysdate
                                  WHERE  budget_Version_id=l_ci_rec_tab(i).ci_plan_version_id;

                              END IF;

                              pa_fp_ci_merge.fp_ci_update_impact
                                 ( p_ci_id                 => l_ci_rec_tab(i).ci_id
                                  ,p_status_code           => 'CI_IMPACT_PENDING'
                                  ,p_impact_type_code      => l_impact_type_code
                                  --,p_record_version_number => l_ci_rec_tab(i).record_version_number
                                  ,x_return_status         => l_return_status
                                  ,x_msg_count             => l_msg_count
                                  ,x_msg_data              => l_msg_data);

                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                   fnd_msg_pub.add_exc_msg
                                      ( p_pkg_name       => 'pa_fin_plan_pvt'
                                       ,p_procedure_name => 'handle_ci_links'
                                       ,p_error_text     => to_char(l_stage)||': '||substr(SQLERRM,1,240));
                                END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS
                          END LOOP;
                       END IF; -- l_ci_rec_tab.count > 0
                  END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS


                  /* Get CI from New Current Working which have not been implemented
                     and change their status to implemented */
                     l_stage := 150;
                     l_ci_rec_tab.delete;

                  pa_fin_plan_pvt.Get_Included_Ci(
                    p_from_bv_id    => p_target_bv_id  /* New Current Working */
                  , p_to_bv_id      => NULL
                  , p_impact_status => 'CI_IMPACT_PENDING'
                  , x_ci_rec_tab    => l_ci_rec_tab
                  , x_return_status => l_return_status
                  , x_msg_count     => l_msg_count
                  , x_msg_data      => l_msg_data);


                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     fnd_msg_pub.add_exc_msg
                     ( p_pkg_name       => 'pa_fin_plan_pvt'
                      ,p_procedure_name => 'handle_ci_links'
                      ,p_error_text     => to_char(l_stage)||': '||substr(SQLERRM,1,240));
                  ELSE
                          l_stage := 160;
                       IF l_ci_rec_tab.count > 0 THEN
                          l_stage := 170;
                          FOR i in 1..l_ci_rec_tab.count LOOP
                              l_stage := 180;

                              IF  l_ci_rec_tab(i).version_type='COST' THEN
                                  l_impact_type_code:='FINPLAN_COST';
                              ELSIF l_ci_rec_tab(i).version_type='REVENUE' THEN
                                 l_impact_type_code:='FINPLAN_REVENUE';
                              END IF;

                              pa_fp_ci_merge.fp_ci_update_impact
                                 ( p_ci_id                 => l_ci_rec_tab(i).ci_id
                                  ,p_status_code           => 'CI_IMPACT_IMPLEMENTED'
                                  ,p_impact_type_code      => l_impact_type_code
                                  --,p_record_version_number => l_ci_rec_tab(i).record_version_number
                                  ,x_return_status         => l_return_status
                                  ,x_msg_count             => l_msg_count
                                  ,x_msg_data              => l_msg_data);

                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                   fnd_msg_pub.add_exc_msg
                                      ( p_pkg_name       => 'pa_fin_plan_pvt'
                                       ,p_procedure_name => 'handle_ci_links'
                                       ,p_error_text     => to_char(l_stage)||': '||substr(SQLERRM,1,240));
                                END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS
                          END LOOP;
                       END IF; -- l_ci_rec_tab.count > 0
                  END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS

      END IF; -- l_approved_budget_plan_type = 'Y'
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_msg_count := FND_MSG_PUB.Count_Msg;

  EXCEPTION WHEN NO_DATA_FOUND THEN
                 l_approved_budget_plan_type := 'N';
            WHEN OTHERS THEN
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 x_msg_count := FND_MSG_PUB.Count_Msg;
                 IF x_msg_count = 1 THEN
                    pa_interface_utils_pub.get_messages ( p_encoded      => FND_API.G_TRUE
                                                         ,p_msg_index    => 1
                                                         ,p_data         => x_msg_data
                                                         ,p_msg_index_out => l_msg_index_out);
                 END IF;
                 fnd_msg_pub.add_exc_msg
                     ( p_pkg_name       => 'pa_fin_plan_pvt'
                      ,p_procedure_name => 'handle_ci_links'
                      ,p_error_text     => to_char(l_stage)||': '||substr(SQLERRM,1,240));

                 fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                            p_data  => x_msg_data);
END handle_ci_links;

/*
     This api uses the input parameters to create a project finplanning option for a plan
     version and also creates the finplan budget version. If any of the nullable parameters
     are not passed, the plan type options are used for the plan version finplan option. This
     API is similar to pa_budget_utils.create_draft
*/

PROCEDURE CREATE_DRAFT
   (  p_project_id                      IN      pa_budget_versions.project_id%TYPE
     ,p_fin_plan_type_id                IN      pa_budget_versions.fin_plan_type_id%TYPE
     ,p_version_type                    IN      pa_budget_versions.version_type%TYPE
     -- Bug Fix: 4569365. Removed MRC code.
     -- ,p_calling_context                 IN      pa_mrc_finplan.g_calling_module%TYPE
     ,p_calling_context                 IN      VARCHAR2
     ,p_time_phased_code                IN      pa_proj_fp_options.cost_time_phased_code%TYPE
     ,p_resource_list_id                IN      pa_budget_versions.resource_list_id%TYPE
     ,p_fin_plan_level_code             IN      pa_proj_fp_options.cost_fin_plan_level_code%TYPE
     ,p_plan_in_mc_flag                 IN      pa_proj_fp_options.plan_in_multi_curr_flag%TYPE
     ,p_version_name                    IN      pa_budget_versions.version_name%TYPE
     ,p_description                     IN      pa_budget_versions.description%TYPE
     ,p_change_reason_code              IN      pa_budget_versions.change_reason_code%TYPE
     ,p_raw_cost_flag                   IN      pa_fin_plan_amount_sets.raw_cost_flag%TYPE
     ,p_burdened_cost_flag              IN      pa_fin_plan_amount_sets.burdened_cost_flag%TYPE
     ,p_revenue_flag                    IN      pa_fin_plan_amount_sets.revenue_flag%TYPE
     ,p_cost_qty_flag                   IN      pa_fin_plan_amount_sets.cost_qty_flag%TYPE
     ,p_revenue_qty_flag                IN      pa_fin_plan_amount_sets.revenue_qty_flag%TYPE
     ,p_all_qty_flag                    IN      pa_fin_plan_amount_sets.all_qty_flag%TYPE
     ,p_attribute_category              IN      pa_budget_versions.attribute_category%TYPE
     ,p_attribute1                      IN      pa_budget_versions.attribute1%TYPE
     ,p_attribute2                      IN      pa_budget_versions.attribute2%TYPE
     ,p_attribute3                      IN      pa_budget_versions.attribute3%TYPE
     ,p_attribute4                      IN      pa_budget_versions.attribute4%TYPE
     ,p_attribute5                      IN      pa_budget_versions.attribute5%TYPE
     ,p_attribute6                      IN      pa_budget_versions.attribute6%TYPE
     ,p_attribute7                      IN      pa_budget_versions.attribute7%TYPE
     ,p_attribute8                      IN      pa_budget_versions.attribute8%TYPE
     ,p_attribute9                      IN      pa_budget_versions.attribute9%TYPE
     ,p_attribute10                     IN      pa_budget_versions.attribute10%TYPE
     ,p_attribute11                     IN      pa_budget_versions.attribute11%TYPE
     ,p_attribute12                     IN      pa_budget_versions.attribute12%TYPE
     ,p_attribute13                     IN      pa_budget_versions.attribute13%TYPE
     ,p_attribute14                     IN      pa_budget_versions.attribute14%TYPE
     ,p_attribute15                     IN      pa_budget_versions.attribute15%TYPE
     ,p_projfunc_cost_rate_type         IN      pa_proj_fp_options.projfunc_cost_rate_type%TYPE
     ,p_projfunc_cost_rate_date_type    IN      pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE
     ,p_projfunc_cost_rate_date         IN      pa_proj_fp_options.projfunc_cost_rate_date%TYPE
     ,p_projfunc_rev_rate_type          IN      pa_proj_fp_options.projfunc_rev_rate_type%TYPE
     ,p_projfunc_rev_rate_date_type     IN      pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE
     ,p_projfunc_rev_rate_date          IN      pa_proj_fp_options.projfunc_rev_rate_date%TYPE
     ,p_project_cost_rate_type          IN      pa_proj_fp_options.project_cost_rate_type%TYPE
     ,p_project_cost_rate_date_type     IN      pa_proj_fp_options.project_cost_rate_date_type%TYPE
     ,p_project_cost_rate_date          IN      pa_proj_fp_options.project_cost_rate_date%TYPE
     ,p_project_rev_rate_type           IN      pa_proj_fp_options.project_rev_rate_type%TYPE
     ,p_project_rev_rate_date_type      IN      pa_proj_fp_options.project_rev_rate_date_type%TYPE
     ,p_project_rev_rate_date           IN      pa_proj_fp_options.project_rev_rate_date%TYPE
     ,p_pm_product_code                 IN      pa_budget_versions.pm_product_code%TYPE
     ,p_pm_budget_reference             IN      pa_budget_versions.pm_budget_reference%TYPE
     ,p_budget_lines_tab                IN      pa_fin_plan_pvt.budget_lines_tab
     -- Start of additional columns for Bug :- 2634900  . Commented out the default parameters.
     ,p_ci_id                           IN     pa_budget_versions.ci_id%TYPE                    --:= NULL
     ,p_est_proj_raw_cost               IN     pa_budget_versions.est_project_raw_cost%TYPE     --:= NULL
     ,p_est_proj_bd_cost                IN     pa_budget_versions.est_project_burdened_cost%TYPE--:= NULL
     ,p_est_proj_revenue                IN     pa_budget_versions.est_project_revenue%TYPE      --:= NULL
     ,p_est_qty                         IN     pa_budget_versions.est_quantity%TYPE             --:= NULL
     ,p_est_equip_qty                   IN     pa_budget_versions.est_equipment_quantity%TYPE   --FP.M
     ,p_impacted_task_id                IN     pa_tasks.task_id%TYPE                            --:= NULL
     ,p_agreement_id                    IN     pa_budget_versions.agreement_id%TYPE             --:= NULL
     -- End of additional columns for Bug :- 2634900
     -- Added the two flags below as part of changes to AMG for finplan model
     ,p_create_new_curr_working_flag    IN      VARCHAR2
     ,p_replace_current_working_flag    IN      VARCHAR2
     ,x_budget_version_id               OUT      NOCOPY pa_budget_versions.budget_version_id%TYPE --File.Sql.39 bug 4440895
     ,x_return_status                   OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                       OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                        OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_error_msg_code                VARCHAR2(30);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(1);
l_debug_mode                    VARCHAR2(30);

CURSOR impacted_task_cur(c_impacted_task_id  pa_tasks.task_id%TYPE) IS
SELECT pt.parent_task_id parent_task_id,
       pt.top_task_id top_task_id ,
       pelm.element_Version_id element_Version_id
FROM   pa_tasks pt,
       pa_proj_element_versions pelm
WHERE  pt.task_id = c_impacted_task_id
AND    pelm.proj_element_id=pt.task_id
AND    pelm.parent_structure_version_id=PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID( p_project_id);

impacted_task_rec               impacted_task_cur%ROWTYPE;

l_fp_options_id                 pa_proj_fp_options.proj_fp_options_id%TYPE;
l_baselined_version_id          pa_budget_versions.budget_version_id%TYPE;
l_curr_work_version_id          pa_budget_versions.budget_version_id%TYPE;
l_amount_set_id                 pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;

l_cost_amount_set_id            pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
l_rev_amount_set_id             pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
l_all_amount_set_id             pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
l_created_version_id            pa_budget_versions.budget_version_id%TYPE;
l_resource_list_id              pa_budget_versions.resource_list_id%TYPE;
l_plan_pref_code                pa_proj_fp_options.fin_plan_preference_code%TYPE;

l_uncat_rlmid                   pa_resource_assignments.resource_list_member_id%TYPE;
l_track_as_labor_flag           pa_resource_list_members.track_as_labor_flag%TYPE;
l_unit_of_measure               pa_resource_assignments.unit_of_measure%TYPE;

l_ci_rec_tab                    pa_fin_plan_pvt.ci_rec_tab;  /* Included for bug 2672654 */

-- Bug Fix: 4569365. Removed MRC code.
-- l_calling_context               pa_mrc_finplan.g_calling_module%TYPE; /* Bug# 2674353 */
l_calling_context               VARCHAR2(30);
l_record_version_number         pa_budget_versions.record_version_number%TYPE; /* Bug 2688610 */

l_mixed_resource_planned_flag   VARCHAR2(1);-- Added for Bug:-2625872

l_proj_fp_options_id            pa_proj_fp_options.proj_fp_options_id%TYPE;
l_CW_version_id                 pa_budget_versions.budget_version_id%TYPE;
l_CW_record_version_number      pa_budget_versions.record_version_number%TYPE;
l_user_id                       NUMBER :=0;
l_created_ver_rec_ver_num       pa_budget_versions.record_version_number%TYPE;
l_task_elem_version_id_tbl      SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
l_rlm_id_tbl                    SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
	IF p_pa_debug_mode = 'Y' THEN
	      pa_debug.set_err_stack('PA_FIN_PLAN_PVT.CREATE_DRAFT');
	END IF;
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.set_process('CREATE_DRAFT: ' || 'PLSQL','LOG',l_debug_mode);
      END IF;


        pa_debug.g_err_stage:='Entering Create_draft';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,2);
        END IF;

        l_calling_context :=  nvl(p_calling_context,PA_FP_CONSTANTS_PKG.G_CREATE_DRAFT); /* Bug# 2674353 */
        l_resource_list_id := p_resource_list_id; --bug#2831968

        IF p_ci_id is NULL THEN  -- Bug # 2672654

        pa_debug.g_err_stage:='Control item id is null';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

      /* Validation for the resource list */
      /* Get the currently baselined version id */
      pa_fin_plan_utils.Get_Baselined_Version_Info(
          p_project_id                  => p_project_id
          ,p_fin_plan_type_id           => p_fin_plan_type_id
          ,p_version_type               => p_version_type
          ,x_fp_options_id              => l_fp_options_id
          ,x_fin_plan_version_id        => l_baselined_version_id
          ,x_return_status              => x_return_status
          ,x_msg_count                  => x_msg_count
          ,x_msg_data                   => x_msg_data );

        IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                pa_debug.g_err_stage:= 'Error Calling Get_Baselined_Version_Info';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        pa_debug.g_err_stage:= 'current Baselined Version id ->' || l_baselined_version_id;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;
        -- bug#2831968 l_resource_list_id := p_resource_list_id;

        /* Commenting for bug 8367755
        IF (l_baselined_version_id IS NOT NULL) THEN
           IF (pa_fin_plan_utils.Get_Resource_List_Id(l_baselined_version_id) <> l_resource_list_id) THEN
                     pa_debug.g_err_stage:='Current baselined versions and passed resource list id are not same';
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,5);
                     END IF;

                     PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                          p_msg_name      => 'PA_BU_BASE_RES_LIST_EXISTS');
                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;
        END IF;
        */

        pa_debug.g_err_stage:='Entering of validation for resource list';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

      /* End of validation for resource list */

      /* Get draft version */

      pa_fin_plan_utils.Get_Curr_Working_Version_Info(
           p_project_id            => p_project_id
          ,p_fin_plan_type_id      => p_fin_plan_type_id
          ,p_version_type          => p_version_type
          ,x_fp_options_id         => l_fp_options_id
          ,x_fin_plan_version_id   => l_curr_work_version_id
          ,x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        Raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      pa_debug.g_err_stage:='Current working version id -> ' || l_curr_work_version_id;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      IF (l_curr_work_version_id is not null) THEN    /* Bug 2672654 */
        pa_fin_plan_pvt.Get_Included_Ci(
              p_from_bv_id     => l_curr_work_version_id
             ,p_to_bv_id       => NULL
             ,p_impact_status  => NULL
             ,x_ci_rec_tab     => l_ci_rec_tab        /* Bug 2672654 */
             ,x_return_status  => x_return_status
             ,x_msg_count      => x_msg_count
             ,x_msg_data       => x_msg_data );

        IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                pa_debug.g_err_stage:= 'Could not obtain the CI information for the version';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        ELSE
                pa_debug.g_err_stage:= 'obtained the CI information for the version';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                END IF;
        END IF;

        /* Bug 2688610 - should call delete_version rather than delete_version_helper.
        pa_fin_plan_pub.Delete_Version_Helper
            ( p_budget_version_id     => l_curr_work_version_id
             ,x_return_status         => x_return_status
             ,x_msg_count             => x_msg_count
             ,x_msg_data              => x_msg_data );
        */

        -- Do not delete the version if called from create draft. Changes due to AMG

        IF nvl(p_replace_current_working_flag,'N')= 'Y' THEN

              l_record_version_number := pa_fin_plan_utils.Retrieve_Record_Version_Number
                                            (p_budget_version_id => l_curr_work_version_id);

              --Try to lock the version before deleting the version. This is required so as not to delete
              --versions locked by other users.  AMG UT2
              l_user_id := FND_GLOBAL.User_id;
              pa_fin_plan_pvt.lock_unlock_version
                       (p_budget_version_id       => l_curr_work_version_id,
                        p_record_version_number   => l_record_version_number,
                        p_action                  => 'L',
                        p_user_id                 => l_user_id,
                        p_person_id               => NULL,
                        x_return_status           => x_return_status,
                        x_msg_count               => x_msg_count,
                        x_msg_data                => x_msg_data) ;

                  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'Error in lock unlock version - cannot delete working version';
                              pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,5);
                        END IF;

                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                  END IF;

              l_record_version_number := pa_fin_plan_utils.Retrieve_Record_Version_Number
                                            (p_budget_version_id => l_curr_work_version_id);

              pa_fin_plan_pub.delete_version
                  (     p_project_id            => p_project_id
                       ,p_budget_version_id     => l_curr_work_version_id
                       ,p_record_version_number => l_record_version_number
                       ,x_return_status         => x_return_status
                       ,x_msg_count             => x_msg_count
                       ,x_msg_data              => x_msg_data
                      );

              IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                      pa_debug.g_err_stage:= 'Could not delete the current working version';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                      END IF;
                      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              ELSE
                      pa_debug.g_err_stage:= 'Deleted the current working version';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                      END IF;
              END IF;

        END IF;--IF l_calling_context <> PA_FP_CONSTANTS_PKG.G_CREATE_DRAFT THEN

      END IF; --l_curr_work_version_id is not null
      ELSE
                pa_debug.g_err_stage:= 'p_ci_id is not null - control item version';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                END IF;
      END IF; -- p_ci_id is NULL. Bug 2672654

        --Get the preference code
        IF(p_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST) THEN
                l_plan_pref_code := PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY;
        ELSIF(p_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE) THEN
                l_plan_pref_code := PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY;
        ELSIF(p_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL) THEN
                l_plan_pref_code := PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME;
        END IF;

        pa_debug.g_err_stage:= 'Preference code is -> ' || l_plan_pref_code;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;

        --Get the amount set id.
        pa_fin_plan_utils.GET_OR_CREATE_AMOUNT_SET_ID
        (
                 p_raw_cost_flag            => p_raw_cost_flag
                ,p_burdened_cost_flag       => p_burdened_cost_flag
                ,p_revenue_flag             => p_revenue_flag
                ,p_cost_qty_flag            => p_cost_qty_flag
                ,p_revenue_qty_flag         => p_revenue_qty_flag
                ,p_all_qty_flag             => p_all_qty_flag
                ,p_plan_pref_code           => l_plan_pref_code
/* Changes for FP.M, Tracking Bug No - 3354518
Passing three new arguments p_bill_rate_flag,
p_cost_rate_flag, p_burden_rate below for
new columns in pa_fin_plan_amount_sets  and changes done in
called API */
                ,p_bill_rate_flag           => 'Y'
                ,p_cost_rate_flag           => 'Y'
                ,p_burden_rate_flag         => 'Y'
                ,x_cost_amount_set_id       => l_cost_amount_set_id
                ,x_revenue_amount_set_id    => l_rev_amount_set_id
                ,x_all_amount_set_id        => l_all_amount_set_id
                ,x_message_count            => x_msg_count
                ,x_return_status            => x_return_status
                ,x_message_data             => x_msg_data
        );

        IF(p_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST) THEN
                l_amount_set_id := l_cost_amount_set_id;
        ELSIF(p_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE) THEN
                l_amount_set_id := l_rev_amount_set_id;
        ELSIF(p_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL) THEN
                l_amount_set_id := l_all_amount_set_id;
        END IF;

        pa_debug.g_err_stage:= 'amount set id is -> ' || l_amount_set_id;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;

        l_created_version_id := NULL;
      /* Create the plan version */
      pa_fin_plan_pub.Create_Version (
             p_project_id               => p_project_id
            ,p_fin_plan_type_id         => p_fin_plan_type_id
            ,p_element_type             => p_version_type
            ,p_version_name             => p_version_name
            ,p_description              => p_description
            -- change for CI impact start. Bug # 2634900.
            ,p_ci_id                    => p_ci_id              --NULL
            ,p_est_proj_raw_cost        => p_est_proj_raw_cost  --NULL
            ,p_est_proj_bd_cost         => p_est_proj_bd_cost   --NULL
            ,p_est_proj_revenue         => p_est_proj_revenue   --NULL
            ,p_est_qty                  => p_est_qty            --NULL
            ,p_est_equip_qty            => p_est_equip_qty      --NULL
            ,p_impacted_task_id         => p_impacted_task_id   --NULL
            ,p_agreement_id             => p_agreement_id       --NULL
            -- change for CI impact end. Bug # 2634900.
            ,p_calling_context          => l_calling_context
            ,p_plan_in_multi_curr_flag  => p_plan_in_mc_flag
            ,p_fin_plan_level_code      => p_fin_plan_level_code
            ,p_resource_list_id         => l_resource_list_id
            ,p_time_phased_code         => p_time_phased_code
            ,p_amount_set_id            => l_amount_set_id
            ,px_budget_version_id       => l_created_version_id
            ,x_proj_fp_option_id        => l_fp_options_id
            ,x_return_status            => x_return_status
            ,x_msg_count                => x_msg_count
            ,x_msg_data                 => x_msg_data );

        IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                pa_debug.g_err_stage:= 'Error in calling Create_Version';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

      x_budget_version_id := l_created_version_id;


      pa_debug.g_err_stage:= 'Created budget version id is : '||l_created_version_id;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      -- If the created version is a NON-CI version "AND"  --- added this condition for bug 2881681
      -- If either of the replace current working or Create working version flags is Y then make
      -- the newly created version the current working version. Changes due to finplan in AMG

      IF    (p_ci_id IS NULL) AND
            (p_create_new_curr_working_flag = 'Y' OR
             p_replace_current_working_flag = 'Y') THEN

            -- Get the details of the current working version so as to pass it to the
            -- Set Current Working API.

            pa_fin_plan_utils.Get_Curr_Working_Version_Info(
                   p_project_id            => p_project_id
                  ,p_fin_plan_type_id      => p_fin_plan_type_id
                  ,p_version_type          => p_version_type
                  ,x_fp_options_id         => l_proj_fp_options_id
                  ,x_fin_plan_version_id   => l_CW_version_id
                  ,x_return_status         => x_return_status
                  ,x_msg_count             => x_msg_count
                  ,x_msg_data              => x_msg_data );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            -- Further processing is required only if the newly created version is not the current working verion

            IF  l_created_version_id <>  l_CW_version_id THEN

                  --Get the record version number of the current working version
                  l_CW_record_version_number  := pa_fin_plan_utils.Retrieve_Record_Version_Number(l_CW_version_id);

                  --Get the record version number of the newly created version
                  l_created_ver_rec_ver_num  := pa_fin_plan_utils.Retrieve_Record_Version_Number(l_created_version_id);
                  l_user_id := FND_GLOBAL.User_id;
                  pa_fin_plan_pvt.lock_unlock_version
                       (p_budget_version_id       => l_CW_version_id,
                        p_record_version_number   => l_CW_record_version_number,
                        p_action                  => 'L',
                        p_user_id                 => l_user_id,
                        p_person_id               => NULL,
                        x_return_status           => x_return_status,
                        x_msg_count               => x_msg_count,
                        x_msg_data                => x_msg_data) ;

                  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'Error executing lock unlock version';
                              pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,3);
                        END IF;

                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                  END IF;

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'About to call set current working version';
                        pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  -- Getting the rec ver number again as it will be incremented by the api  lock_unlock_version
                  l_CW_record_version_number  := pa_fin_plan_utils.Retrieve_Record_Version_Number(l_CW_version_id);

                  pa_fin_plan_pub.Set_Current_Working
                        (p_project_id                  => p_project_id,
                         p_budget_version_id           => l_created_version_id,
                         p_record_version_number       => l_created_ver_rec_ver_num,
                         p_orig_budget_version_id      => l_CW_version_id,
                         p_orig_record_version_number  => l_CW_record_version_number,
                         x_return_status               => x_return_status,
                         x_msg_count                   => x_msg_count,
                         x_msg_data                    => x_msg_data);

                  IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                              pa_debug.g_err_stage:= 'Error executing Set_Current_Working ';
                              pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;

            END IF; --  IF  l_created_version_id <>  l_CW_version_id THEN

      END IF; --IF  (p_create_new_curr_working_flag = 'Y' OR




      --The above call to the create version api has not created RAs,elements.
      --need to update the options and version table.

      --start of changes for options table.
/*
        need to update the following in fp_options.
                conversion attributes.
*/
        /*
            Bug 2670747 - The MC attributes need to be updated only if MC flag is Y
        */
        IF (p_plan_in_mc_flag = 'Y') THEN
        update pa_proj_fp_options
        set  projfunc_cost_rate_type            = p_projfunc_cost_rate_type
            ,projfunc_cost_rate_date_type       = p_projfunc_cost_rate_date_type
            ,projfunc_cost_rate_date            = p_projfunc_cost_rate_date
            ,projfunc_rev_rate_type             = p_projfunc_rev_rate_type
            ,projfunc_rev_rate_date_type        = p_projfunc_rev_rate_date_type
            ,projfunc_rev_rate_date             = p_projfunc_rev_rate_date
            ,project_cost_rate_type             = p_project_cost_rate_type
            ,project_cost_rate_date_type        = p_project_cost_rate_date_type
            ,project_cost_rate_date             = p_project_cost_rate_date
            ,project_rev_rate_type              = p_project_rev_rate_type
            ,project_rev_rate_date_type         = p_project_rev_rate_date_type
            ,project_rev_rate_date              = p_project_rev_rate_date
        where proj_fp_options_id = l_fp_options_id;
        END IF; --End of Bug fix 2670747

        --End of changes corresponding to options table.

        --Start of changes for budget versions table.
        /*
                need to update the following in budget_versions
                change reason code,
                product code, budget reference.
        */
        update pa_budget_versions
        set     change_reason_code = p_change_reason_code,
                pm_product_code = p_pm_product_code,
                pm_budget_reference = p_pm_budget_reference,
                attribute_category  = p_attribute_category,
                attribute1          = p_attribute1,
                attribute2          = p_attribute2,
                attribute3          = p_attribute3,
                attribute4          = p_attribute4,
                attribute5          = p_attribute5,
                attribute6          = p_attribute6,
                attribute7          = p_attribute7,
                attribute8          = p_attribute8,
                attribute9          = p_attribute9,
                attribute10         = p_attribute10,
                attribute11         = p_attribute11,
                attribute12         = p_attribute12,
                attribute13         = p_attribute13,
                attribute14         = p_attribute14,
                attribute15         = p_attribute15
        where budget_version_id = l_created_version_id;

        --End of changes corresponding to budget versions table.

        /* Bug# 2676352 - For automatic baselined ci versions, budget_lines_tab is not passed and we should
           be creating resource assignments and fp elements based on defaults. It is to be noted that for
           autobaseline case, resource list id is always none and hence calling insert_defaults should be fine */

        IF (l_calling_context = PA_FP_CONSTANTS_PKG.G_AUTOMATIC_BASELINE AND p_ci_id IS NOT NULL) THEN

            IF ( p_impacted_task_id IS NULL OR
                   p_fin_plan_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT ) THEN

-- <Patchset M: B and F impact changes : AMG:>-- Bug # 3507156
-- References to PA_FP_ELEMENTS table have been commented out (FP M)
-- Comment START.
/*
                -- Create fp elements and resource assignments for the budget version and the impacted task id

                pa_debug.g_err_stage:='Calling pa_fp_elements_pub.insert_default...';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,3);
                END IF;

                Pa_Fp_Elements_Pub.Insert_Default (
                                      p_proj_fp_options_id    => l_fp_options_id
                                     ,p_element_type          => p_version_type
                                     ,p_planning_level        => p_fin_plan_level_code
                                     ,p_resource_list_id      => l_resource_list_id
                                    -- Bug 2920954 Start of parameters added for post FP-K oneoff patch
                                     ,p_select_res_auto_flag  => NULL
                                     ,p_res_planning_level    => NULL
                                     --Bug 2920954 End of parameters added for post FP-K oneoff patch
                                     ,x_return_status         => x_return_status
                                     ,x_msg_count             => x_msg_count
                                     ,x_msg_data              => x_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  Raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;


                pa_debug.g_err_stage:='Calling pa_fp_elements_pub.create_enterable_resources...';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,3);
                END IF;

                Pa_Fp_Elements_Pub.Create_Enterable_Resources (
                                     p_plan_version_id        => l_created_version_id
                                     ,x_return_status         => x_return_status
                                     ,x_msg_count             => x_msg_count
                                     ,x_msg_data              => x_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  Raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

*/
--<Patchset M: B and F impact changes : AMG:>-- Bug # 3507156
-- Comment END
-- Added a call to pa_fp_planning_transaction_pub.create_default_task_plan_txns

                pa_debug.g_err_stage:='Calling pa_fp_planning_transaction_pub.create_default_task_plan_txns...';

                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,3);
                END IF;
                 pa_fp_planning_transaction_pub.create_default_task_plan_txns(
                 P_budget_version_id              =>     l_created_version_id
                ,P_version_plan_level_code        =>     p_fin_plan_level_code
                ,X_return_status                  =>     x_return_status
                ,X_msg_count                      =>     x_msg_count
                ,X_msg_data                       =>     x_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  Raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

            ELSE

              -- Fetching top task id and parent task id of impacted task id

              pa_debug.g_err_stage:= 'Fetching impacted task details';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
              END IF;

              OPEN  impacted_task_cur(p_impacted_task_id);
              FETCH impacted_task_cur INTO impacted_task_rec;
              CLOSE impacted_task_cur;

              --Insert a new record into pa_resoruce_assignments


              DECLARE
                l_dummy_res_list_id PA_RESOURCE_LISTS_ALL_BG.resource_list_id%TYPE;
                l_dummy_row_id      ROWID;
                l_dummy_ra_id       PA_RESOURCE_ASSIGNMENTS.resource_assignment_id%TYPE;
              BEGIN

                PA_FIN_PLAN_UTILS.Get_Uncat_Resource_List_Info
                (x_resource_list_id        => l_dummy_res_list_id
                ,x_resource_list_member_id => l_uncat_rlmid
                ,x_track_as_labor_flag     => l_track_as_labor_flag
                ,x_unit_of_measure         => l_unit_of_measure
                ,x_return_status           => x_return_status
                ,x_msg_count               => x_msg_count
                ,x_msg_data                => x_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  pa_debug.g_err_stage := 'Error while fetching uncat res list id info ...';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

                l_task_elem_version_id_tbl.extend();
                l_task_elem_version_id_tbl(1) := impacted_task_rec.element_version_id;
                l_rlm_id_tbl.extend();
                l_rlm_id_tbl(1) := l_uncat_rlmid;
                Pa_Fp_Planning_Transaction_Pub.Add_Planning_Transactions(
                             p_context                     =>     'BUDGET',--It will always be budget as CIs can be
                                                                           --created only for Budgets
                             p_project_id                  =>      p_project_id,
                             p_budget_version_id           =>      l_created_version_id,
                             p_task_elem_version_id_tbl    =>      l_task_elem_version_id_tbl,
                             p_resource_list_member_id_tbl =>      l_rlm_id_tbl,
                             x_return_status               =>      x_return_status,
                             x_msg_count                   =>      x_msg_count,
                             x_msg_data                    =>      x_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      pa_debug.g_err_stage:= 'Exception while inserting a row into pa_resource_assignments;';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                      END IF;
                      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

             END;

            END IF;

        --call PA_FIN_PLAN_PVT.CRETAE_FINPLAN_LINES. This API will create
        --resource assignments, elements and budget lines for the version.
        /* Bug# 2672654 - create_fin_plan_lines API needs to be called only if p_budget_lines_tab is not null */

        ELSIF ( nvl(p_budget_lines_tab.last,0) > 0 ) THEN

--Bug # 3507156-<Patchset M: B and F impact changes : AMG:>
--Commented the call to PA_FIN_PLAN_PVT.CREATE_FINPLAN_LINES
--Comment START
/*
                PA_FIN_PLAN_PVT.CREATE_FINPLAN_LINES
                    ( p_calling_context         => l_calling_context -- Bug# 2674353
                     ,p_fin_plan_version_id     => l_created_version_id
                     ,p_budget_lines_tab        => p_budget_lines_tab
                     ,x_return_status           => x_return_status
                     ,x_msg_count               => x_msg_count
                     ,x_msg_data                => x_msg_data );

                IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                        pa_debug.g_err_stage:= 'Error Calling CREATE_FINPLAN_LINES';
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
*/
--Bug # 3507156-<Patchset M: B and F impact changes : AMG:>
--Added a call to PA_FIN_PLAN_PVT.ADD_FIN_PLAN_LINES

               PA_FIN_PLAN_PVT.ADD_FIN_PLAN_LINES
                   ( p_calling_context         =>      l_calling_context
                    ,p_fin_plan_version_id     =>      l_created_version_id
                    ,p_finplan_lines_tab       =>      p_budget_lines_tab
                    ,x_return_status           =>      x_return_status
                    ,x_msg_count               =>      x_msg_count
                    ,x_msg_data                =>      x_msg_data );

                IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                        pa_debug.g_err_stage:= 'Error Calling ADD_FIN_PLAN_LINES';
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
        END IF;

        pa_debug.g_err_stage:= 'Restoring the Control Item links if any';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;

/* Commented out for bug 3550073
       IF ( nvl(l_ci_rec_tab.last,0) > 0 ) THEN
           FOR i in l_ci_rec_tab.first..l_ci_rec_tab.last LOOP

               pa_fp_ci_merge.FP_CI_LINK_CONTROL_ITEMS (
                  p_project_id      => p_project_id
                 ,p_s_fp_version_id => l_ci_rec_tab(i).ci_plan_version_id
                 ,p_t_fp_version_id => l_created_version_id
                 ,x_return_status   => x_return_status
                 ,x_msg_count       => x_msg_count
                 ,x_msg_data        => x_msg_data);

                 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        pa_debug.g_err_stage:= 'Error Calling FP_CI_LINK_CONTROL_ITEMS';
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF; -- l_return_status <> FND_API.G_RET_STS_SUCCESS

           END LOOP;  --first..last
        END IF; -- l_ci_rec_tab is not null */


      pa_debug.g_err_stage:= 'Exiting CREATE_DRAFT';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL2);
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
              pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
              pa_debug.reset_err_stack;
	END IF;
           RAISE;

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fin_plan_pvt'
                                  ,p_procedure_name  => 'CREATE_DRAFT');
          pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('CREATE_DRAFT: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             pa_debug.reset_err_stack;
	  END IF;
          RAISE;

END CREATE_DRAFT;

/*
        This procedure would use the input budget_line_tbl to insert records into
        pa_resource_assignments, pa_budget_lines, pa_mc_budget_lines and also takes
        care of rolling up the resource assignments and maintaining the denorm table.
*/
PROCEDURE CREATE_FINPLAN_LINES
    ( -- Bug Fix: 4569365. Removed MRC code.
	  -- p_calling_context         IN      pa_mrc_finplan.g_calling_module%TYPE /* Bug# 2674353 */
	  p_calling_context         IN      VARCHAR2
     ,p_fin_plan_version_id     IN      pa_budget_versions.budget_version_id%TYPE
     ,p_budget_lines_tab        IN      pa_fin_plan_pvt.budget_lines_tab
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_error_msg_code                VARCHAR2(30);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(1);
l_debug_mode                    VARCHAR2(30);

/* Start of table variables for members of p_budget_lines_table */

        l_task_id_tab                                   task_id_tab;
        l_resource_list_member_id_tab                   resource_list_member_id_tab;
        l_description_tab                               description_tab;
        l_start_date_tab                                start_date_tab;
        l_end_date_tab                                  end_date_tab;
        l_period_name_tab                               period_name_tab;
        l_quantity_tab                                  quantity_tab;
        l_unit_of_measure_tab                           unit_of_measure_tab;
        l_track_as_labor_flag_tab                       track_as_labor_flag_tab;
        l_txn_currency_code_tab                         txn_currency_code_tab;
        l_raw_cost_tab                                  raw_cost_tab;
        l_burdened_cost_tab                             burdened_cost_tab;
        l_revenue_tab                                   revenue_tab;
        l_txn_raw_cost_tab                              txn_raw_cost_tab;
        l_txn_burdened_cost_tab                         txn_burdened_cost_tab;
        l_txn_revenue_tab                               txn_revenue_tab;
        l_project_raw_cost_tab                          project_raw_cost_tab;
        l_project_burdened_cost_tab                     project_burdened_cost_tab;
        l_project_revenue_tab                           project_revenue_tab;
        l_change_reason_code_tab                        change_reason_code_tab;
        l_attribute_category_tab                        attribute_category_tab;
        l_attribute1_tab                                attribute1_tab;
        l_attribute2_tab                                attribute2_tab;
        l_attribute3_tab                                attribute3_tab;
        l_attribute4_tab                                attribute4_tab;
        l_attribute5_tab                                attribute5_tab;
        l_attribute6_tab                                attribute6_tab;
        l_attribute7_tab                                attribute7_tab;
        l_attribute8_tab                                attribute8_tab;
        l_attribute9_tab                                attribute9_tab;
        l_attribute10_tab                               attribute10_tab;
        l_attribute11_tab                               attribute11_tab;
        l_attribute12_tab                               attribute12_tab;
        l_attribute13_tab                               attribute13_tab;
        l_attribute14_tab                               attribute14_tab;
        l_attribute15_tab                               attribute15_tab;
        l_PF_COST_RATE_TYPE_tab                         PF_COST_RATE_TYPE_tab;
        l_PF_COST_RATE_DATE_TYPE_tab                    PF_COST_RATE_DATE_TYPE_tab;
        l_PF_COST_RATE_DATE_tab                         PF_COST_RATE_DATE_tab;
        l_PF_COST_RATE_tab                              PF_COST_RATE_tab;
        l_PF_REV_RATE_TYPE_tab                          PF_REV_RATE_TYPE_tab;
        l_PF_REV_RATE_DATE_TYPE_tab                     PF_REV_RATE_DATE_TYPE_tab;
        l_PF_REV_RATE_DATE_tab                          PF_REV_RATE_DATE_tab;
        l_PF_REV_RATE_tab                               PF_REV_RATE_tab;
        l_PJ_COST_RATE_TYPE_tab                         PJ_COST_RATE_TYPE_tab;
        l_PJ_COST_RATE_DATE_TYPE_tab                    PJ_COST_RATE_DATE_TYPE_tab;
        l_PJ_COST_RATE_DATE_tab                         PJ_COST_RATE_DATE_tab;
        l_PJ_COST_RATE_tab                              PJ_COST_RATE_tab;
        l_PJ_REV_RATE_TYPE_tab                          PJ_REV_RATE_TYPE_tab;
        l_PJ_REV_RATE_DATE_TYPE_tab                     PJ_REV_RATE_DATE_TYPE_tab;
        l_PJ_REV_RATE_DATE_tab                          PJ_REV_RATE_DATE_tab;
        l_PJ_REV_RATE_tab                               PJ_REV_RATE_tab;
        l_pm_product_code_tab                           pm_product_code_tab;
        l_pm_budget_line_reference_tab                  pm_budget_line_reference_tab;
        l_quantity_source_tab                           quantity_source_tab;
        l_raw_cost_source_tab                           raw_cost_source_tab;
        l_burdened_cost_source_tab                      burdened_cost_source_tab;
        l_revenue_source_tab                            revenue_source_tab;
        l_resource_assignment_id_tab                    resource_assignment_id_tab;

/* End of table variables for members of p_budget_lines_table */
   -- Bug Fix: 4569365. Removed MRC code.
   -- l_calling_context  pa_mrc_finplan.g_calling_module%TYPE;
   l_calling_context  VARCHAR2(30);

    /* #2727304 */
       l_proj_currency_code     pa_projects_all.project_currency_code%TYPE;
       l_projfunc_currency_code pa_projects_all.projfunc_currency_code%TYPE;

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
	IF p_pa_debug_mode = 'Y' THEN
	      pa_debug.set_err_stack('pa_fin_plan_pvt.CREATE_FINPLAN_LINES');
	END IF;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.set_process('CREATE_FINPLAN_LINES: ' || 'PLSQL','LOG',l_debug_mode);
      END IF;


      -- Check for business rules violations

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters - CREATE_FINPLAN_LINES';
          pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      --Validate plan version id

      IF (p_fin_plan_version_id IS NULL)
      THEN
          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage:= 'fin_plan_version_id = '|| p_fin_plan_version_id;
              pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,5);
          END IF;

          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name     => 'PA_FP_INV_PARAM_PASSED');

          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      l_calling_context := p_calling_context; /* Bug# 2674353 */

      --Populate the individual column tables so that we can do a bulk
      --insert into resource assignments table.

      IF nvl(p_budget_lines_tab.last,0) > 0 THEN
           FOR i in p_budget_lines_tab.first..p_budget_lines_tab.last LOOP

                 l_task_id_tab(i)                                := p_budget_lines_tab(i).system_reference1;
                 l_resource_list_member_id_tab(i)                := p_budget_lines_tab(i).system_reference2;
                 l_description_tab(i)                            := p_budget_lines_tab(i).description;
                 l_start_date_tab(i)                             := p_budget_lines_tab(i).start_date;
                 l_end_date_tab(i)                               := p_budget_lines_tab(i).end_date;
                 l_period_name_tab(i)                            := p_budget_lines_tab(i).period_name;
                 l_quantity_tab(i)                               := p_budget_lines_tab(i).quantity;
                 l_unit_of_measure_tab(i)                        := p_budget_lines_tab(i).system_reference4;
                 l_track_as_labor_flag_tab(i)                    := p_budget_lines_tab(i).system_reference5;
                 l_txn_currency_code_tab(i)                      := p_budget_lines_tab(i).txn_currency_code;
                 l_raw_cost_tab(i)                               := p_budget_lines_tab(i).projfunc_raw_cost;
                 l_burdened_cost_tab(i)                          := p_budget_lines_tab(i).projfunc_burdened_cost;
                 l_revenue_tab(i)                                := p_budget_lines_tab(i).projfunc_revenue;
                 l_txn_raw_cost_tab(i)                           := p_budget_lines_tab(i).txn_raw_cost;
                 l_txn_burdened_cost_tab(i)                      := p_budget_lines_tab(i).txn_burdened_cost;
                 l_txn_revenue_tab(i)                            := p_budget_lines_tab(i).txn_revenue;
                 l_project_raw_cost_tab(i)                       := p_budget_lines_tab(i).project_raw_cost;
                 l_project_burdened_cost_tab(i)                  := p_budget_lines_tab(i).project_burdened_cost;
                 l_project_revenue_tab(i)                        := p_budget_lines_tab(i).project_revenue;
                 l_change_reason_code_tab(i)                     := p_budget_lines_tab(i).change_reason_code;
                 l_attribute_category_tab(i)                     := p_budget_lines_tab(i).attribute_category;
                 l_attribute1_tab(i)                             := p_budget_lines_tab(i).attribute1;
                 l_attribute2_tab(i)                             := p_budget_lines_tab(i).attribute2;
                 l_attribute3_tab(i)                             := p_budget_lines_tab(i).attribute3;
                 l_attribute4_tab(i)                             := p_budget_lines_tab(i).attribute4;
                 l_attribute5_tab(i)                             := p_budget_lines_tab(i).attribute5;
                 l_attribute6_tab(i)                             := p_budget_lines_tab(i).attribute6;
                 l_attribute7_tab(i)                             := p_budget_lines_tab(i).attribute7;
                 l_attribute8_tab(i)                             := p_budget_lines_tab(i).attribute8;
                 l_attribute9_tab(i)                             := p_budget_lines_tab(i).attribute9;
                 l_attribute10_tab(i)                            := p_budget_lines_tab(i).attribute10;
                 l_attribute11_tab(i)                            := p_budget_lines_tab(i).attribute11;
                 l_attribute12_tab(i)                            := p_budget_lines_tab(i).attribute12;
                 l_attribute13_tab(i)                            := p_budget_lines_tab(i).attribute13;
                 l_attribute14_tab(i)                            := p_budget_lines_tab(i).attribute14;
                 l_attribute15_tab(i)                            := p_budget_lines_tab(i).attribute15;
                 l_PF_COST_RATE_TYPE_tab(i)                      := p_budget_lines_tab(i).PROJFUNC_COST_RATE_TYPE;
                 l_PF_COST_RATE_DATE_TYPE_tab(i)                 := p_budget_lines_tab(i).PROJFUNC_COST_RATE_DATE_TYPE;
                 l_PF_COST_RATE_DATE_tab(i)                      := p_budget_lines_tab(i).PROJFUNC_COST_RATE_DATE;
                 l_PF_COST_RATE_tab(i)                           := p_budget_lines_tab(i).PROJFUNC_COST_EXCHANGE_RATE;
                 l_PF_REV_RATE_TYPE_tab(i)                       := p_budget_lines_tab(i).PROJFUNC_REV_RATE_TYPE;
                 l_PF_REV_RATE_DATE_TYPE_tab(i)                  := p_budget_lines_tab(i).PROJFUNC_REV_RATE_DATE_TYPE;
                 l_PF_REV_RATE_DATE_tab(i)                       := p_budget_lines_tab(i).PROJFUNC_REV_RATE_DATE;
                 l_PF_REV_RATE_tab(i)                            := p_budget_lines_tab(i).PROJFUNC_REV_EXCHANGE_RATE;
                 l_PJ_COST_RATE_TYPE_tab(i)                      := p_budget_lines_tab(i).PROJECT_COST_RATE_TYPE;
                 l_PJ_COST_RATE_DATE_TYPE_tab(i)                 := p_budget_lines_tab(i).PROJECT_COST_RATE_DATE_TYPE;
                 l_PJ_COST_RATE_DATE_tab(i)                      := p_budget_lines_tab(i).PROJECT_COST_RATE_DATE;
                 l_PJ_COST_RATE_tab(i)                           := p_budget_lines_tab(i).PROJECT_COST_EXCHANGE_RATE;
                 l_PJ_REV_RATE_TYPE_tab(i)                       := p_budget_lines_tab(i).PROJECT_REV_RATE_TYPE;
                 l_PJ_REV_RATE_DATE_TYPE_tab(i)                  := p_budget_lines_tab(i).PROJECT_REV_RATE_DATE_TYPE;
                 l_PJ_REV_RATE_DATE_tab(i)                       := p_budget_lines_tab(i).PROJECT_REV_RATE_DATE;
                 l_PJ_REV_RATE_tab(i)                            := p_budget_lines_tab(i).PROJECT_REV_EXCHANGE_RATE;
                 l_pm_product_code_tab(i)                        := p_budget_lines_tab(i).pm_product_code;
                 l_pm_budget_line_reference_tab(i)               := p_budget_lines_tab(i).pm_budget_line_reference;
                 l_quantity_source_tab(i)                        := p_budget_lines_tab(i).quantity_source;
                 l_raw_cost_source_tab(i)                        := p_budget_lines_tab(i).raw_cost_source;
                 l_burdened_cost_source_tab(i)                   := p_budget_lines_tab(i).burdened_cost_source;
                 l_revenue_source_tab(i)                         := p_budget_lines_tab(i).revenue_source;
                 l_resource_assignment_id_tab(i)                 := p_budget_lines_tab(i).resource_assignment_id;

           END LOOP;
      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:= 'populated the plsql tables';
          pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);

          pa_debug.g_err_stage:= 'Delete records if any from the rollup tmp';
          pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      delete from pa_fp_rollup_tmp;   /* Included after UT */

     /* 2727304: Getting the Proj and Proj Func Currencies of the Fin Plan version's project.
        These will be used to populate the Proj and Projfunc currency codes in the
        pa_fp_rollup_tmp table in case they are not being passed to this API. */

      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:= 'Getting the proj and projfunc currency codes';
         pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      SELECT project_currency_code
            ,projfunc_currency_code
       INTO l_proj_currency_code
            ,l_projfunc_currency_code
       FROM pa_projects_all
      WHERE project_id = (SELECT project_id
                            FROM pa_budget_versions
                           WHERE budget_version_id = p_fin_plan_version_id);

      --Bulk insert into the rollup tmp table.
      IF nvl(p_budget_lines_tab.last,0) > 0 THEN
              FORALL i in p_budget_lines_tab.first..p_budget_lines_tab.last
              Insert into pa_fp_rollup_tmp
              (
                       system_reference1           --task_id
                      ,system_reference2           --rlmid
                      ,description
                      ,start_date
                      ,end_date
                      ,period_name
                      ,quantity
                      ,system_reference4           --unit_of_measure
                      ,system_reference5           --track_as_labor_flag
                      ,txn_currency_code
                      ,project_currency_code       --added for #2727304
                      ,projfunc_currency_code      --added for #2727304
                      ,projfunc_raw_cost
                      ,projfunc_burdened_cost
                      ,projfunc_revenue
                      ,txn_raw_cost
                      ,txn_burdened_cost
                      ,txn_revenue
                      ,project_raw_cost
                      ,project_burdened_cost
                      ,project_revenue
                      ,change_reason_code
                      ,attribute_category
                      ,attribute1
                      ,attribute2
                      ,attribute3
                      ,attribute4
                      ,attribute5
                      ,attribute6
                      ,attribute7
                      ,attribute8
                      ,attribute9
                      ,attribute10
                      ,attribute11
                      ,attribute12
                      ,attribute13
                      ,attribute14
                      ,attribute15
                      ,PROJFUNC_COST_RATE_TYPE
                      ,PROJFUNC_COST_RATE_DATE_TYPE
                      ,PROJFUNC_COST_RATE_DATE
                      ,PROJFUNC_COST_EXCHANGE_RATE
                      ,PROJFUNC_REV_RATE_TYPE
                      ,PROJFUNC_REV_RATE_DATE_TYPE
                      ,PROJFUNC_REV_RATE_DATE
                      ,PROJFUNC_REV_EXCHANGE_RATE
                      ,PROJECT_COST_RATE_TYPE
                      ,PROJECT_COST_RATE_DATE_TYPE
                      ,PROJECT_COST_RATE_DATE
                      ,PROJECT_COST_EXCHANGE_RATE
                      ,PROJECT_REV_RATE_TYPE
                      ,PROJECT_REV_RATE_DATE_TYPE
                      ,PROJECT_REV_RATE_DATE
                      ,PROJECT_REV_EXCHANGE_RATE
                      ,pm_product_code
                      ,pm_budget_line_reference
                      ,quantity_source
                      ,raw_cost_source
                      ,burdened_cost_source
                      ,revenue_source
                      ,resource_assignment_id
                      ,budget_version_id
              )
              Values
              (
                       l_task_id_tab(i)
                      ,l_resource_list_member_id_tab(i)
                      ,l_description_tab(i)
                      ,l_start_date_tab(i)
                      ,l_end_date_tab(i)
                      ,l_period_name_tab(i)
                      ,l_quantity_tab(i)
                      ,l_unit_of_measure_tab(i)
                      ,l_track_as_labor_flag_tab(i)
                      ,l_txn_currency_code_tab(i)
                      ,l_proj_currency_code         --added for #2727304
                      ,l_projfunc_currency_code     --added for #2727304
                      ,l_raw_cost_tab(i)
                      ,l_burdened_cost_tab(i)
                      ,l_revenue_tab(i)
                      ,l_txn_raw_cost_tab(i)
                      ,l_txn_burdened_cost_tab(i)
                      ,l_txn_revenue_tab(i)
                      ,l_project_raw_cost_tab(i)
                      ,l_project_burdened_cost_tab(i)
                      ,l_project_revenue_tab(i)
                      ,l_change_reason_code_tab(i)
                      ,l_attribute_category_tab(i)
                      ,l_attribute1_tab(i)
                      ,l_attribute2_tab(i)
                      ,l_attribute3_tab(i)
                      ,l_attribute4_tab(i)
                      ,l_attribute5_tab(i)
                      ,l_attribute6_tab(i)
                      ,l_attribute7_tab(i)
                      ,l_attribute8_tab(i)
                      ,l_attribute9_tab(i)
                      ,l_attribute10_tab(i)
                      ,l_attribute11_tab(i)
                      ,l_attribute12_tab(i)
                      ,l_attribute13_tab(i)
                      ,l_attribute14_tab(i)
                      ,l_attribute15_tab(i)
                      ,l_PF_COST_RATE_TYPE_tab(i)
                      ,l_PF_COST_RATE_DATE_TYPE_tab(i)
                      ,l_PF_COST_RATE_DATE_tab(i)
                      ,l_PF_COST_RATE_tab(i)
                      ,l_PF_REV_RATE_TYPE_tab(i)
                      ,l_PF_REV_RATE_DATE_TYPE_tab(i)
                      ,l_PF_REV_RATE_DATE_tab(i)
                      ,l_PF_REV_RATE_tab(i)
                      ,l_PJ_COST_RATE_TYPE_tab(i)
                      ,l_PJ_COST_RATE_DATE_TYPE_tab(i)
                      ,l_PJ_COST_RATE_DATE_tab(i)
                      ,l_PJ_COST_RATE_tab(i)
                      ,l_PJ_REV_RATE_TYPE_tab(i)
                      ,l_PJ_REV_RATE_DATE_TYPE_tab(i)
                      ,l_PJ_REV_RATE_DATE_tab(i)
                      ,l_PJ_REV_RATE_tab(i)
                      ,l_pm_product_code_tab(i)
                      ,l_pm_budget_line_reference_tab(i)
                      ,l_quantity_source_tab(i)
                      ,l_raw_cost_source_tab(i)
                      ,l_burdened_cost_source_tab(i)
                      ,l_revenue_source_tab(i)
                      ,l_resource_assignment_id_tab(i)
                      ,p_fin_plan_version_id
              );
      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:= 'number of records inserted -> ' || sql%ROWCOUNT;
          pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      --Call procedure pa_fp_elements_pub.CREATE_ASSGMT_FROM_ROLLUPTMP to create
      --resource assignments and elements.

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:= 'calling create_assgmt_from_rolluptmp';
          pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      pa_fp_elements_pub.create_assgmt_from_rolluptmp
          ( p_fin_plan_version_id     => p_fin_plan_version_id
           ,x_return_status           => x_return_status
           ,x_msg_count               => x_msg_count
           ,x_msg_data                => x_msg_data );

      IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage:= 'Error Calling create_assgmt_from_rolluptmp';
              pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,5);
          END IF;
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      --Bug # 3507156-<Patchset M: B and F impact changes : AMG:>
      --Commented the api PROCESS_MODIFIED_LINES
      --Comment START
      /*
          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage:= 'calling PROCESS_MODIFIED_LINES';
              pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;

          --Call process_modified_lines in edit line package.
          PA_FP_EDIT_LINE_PKG.PROCESS_MODIFIED_LINES
           (  p_calling_context           => l_calling_context -- Bug# 2674353
             ,p_resource_assignment_id    => NULL
             ,p_fin_plan_version_id       => p_fin_plan_version_id
             ,x_return_status             => x_return_status
             ,x_msg_count                 => x_msg_count
             ,x_msg_data                  => x_msg_data );

          IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN

                  IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.g_err_stage:= 'Error Calling PROCESS_MODIFIED_LINES';
                      pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:= 'Exiting CREATE_FINPLAN_LINES';
            pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
        END IF;

      */
      --Bug # 3507156-<Patchset M: B and F impact changes : AMG:>
      --Replaced PA_FP_EDIT_LINE_PKG.PROCESS_MODIFIED_LINES with an insert to pa_budget_lines

      -- Bug 3825873 17-JUL-2004 Do not insert amounts as calculate first checks existing values
      -- and the input values are different and then only acts on the record.

      --Bug 4133468. Calculate Api will be called after this insert stmt(call is in add_finplan_lines API).In autobaseline
      --flow, to make sure that the project currency amounts stamped by the calculate API are same as the project currency
      --amounts in the funding lines, exchange rate is stamped as (pc in funding lines)/(pfc in funding lines) and
      --rate type is stamped as User for project revenue conversion attrs.

      /* -----------------------------------------------------------------------------------------
       * Bug 4221590: commenting out the following code to avoid creation of budget lines
       * with null quantities, instead population pa_fp_spread_calc_tmp1, so that calculate
       * api can use that to insert/spread the budget lines passed from AMG/MSP
      *----------------------------------------------------------------------------------------
      INSERT INTO pa_budget_lines(
                 RESOURCE_ASSIGNMENT_ID
                ,BUDGET_LINE_ID
                ,BUDGET_VERSION_ID
                ,START_DATE
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_LOGIN
                ,END_DATE
                ,PERIOD_NAME
                ,QUANTITY
                ,RAW_COST
                ,BURDENED_COST
                ,REVENUE
                ,CHANGE_REASON_CODE
                ,DESCRIPTION
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,RAW_COST_SOURCE
                ,BURDENED_COST_SOURCE
                ,QUANTITY_SOURCE
                ,REVENUE_SOURCE
                ,PROJFUNC_CURRENCY_CODE
                ,PROJFUNC_COST_RATE_TYPE
                ,PROJFUNC_COST_EXCHANGE_RATE
                ,PROJFUNC_COST_RATE_DATE_TYPE
                ,PROJFUNC_COST_RATE_DATE
                ,PROJECT_CURRENCY_CODE
                ,PROJECT_COST_RATE_TYPE
                ,PROJECT_COST_EXCHANGE_RATE
                ,PROJECT_COST_RATE_DATE_TYPE
                ,PROJECT_COST_RATE_DATE
                ,PROJECT_RAW_COST
                ,PROJECT_BURDENED_COST
                ,PROJECT_REVENUE
                ,TXN_RAW_COST
                ,TXN_BURDENED_COST
                ,TXN_REVENUE
                ,TXN_CURRENCY_CODE
                ,BUCKETING_PERIOD_CODE
                ,PROJFUNC_REV_RATE_DATE_TYPE
                ,PROJFUNC_REV_RATE_DATE
                ,PROJFUNC_REV_RATE_TYPE
                ,PROJFUNC_REV_EXCHANGE_RATE
                ,PROJECT_REV_RATE_TYPE
                ,PROJECT_REV_EXCHANGE_RATE
                ,PROJECT_REV_RATE_DATE_TYPE
                ,PROJECT_REV_RATE_DATE
                ,PM_PRODUCT_CODE
                ,PM_BUDGET_LINE_REFERENCE ) -- Added for bug 3833724

       (SELECT
                 RESOURCE_ASSIGNMENT_ID
                ,pa_budget_lines_s.nextval
                ,p_fin_plan_version_id
                ,START_DATE
                ,SYSDATE
                ,FND_GLOBAL.USER_ID
                ,SYSDATE
                ,FND_GLOBAL.USER_ID
                ,FND_GLOBAL.LOGIN_ID
                ,END_DATE
                ,PERIOD_NAME
                ,null--QUANTITY
                ,null--PROJFUNC_RAW_COST
                ,null--PROJFUNC_BURDENED_COST
                ,NULL--PROJFUNC_REVENUE
                ,CHANGE_REASON_CODE
                ,DESCRIPTION
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,nvl(RAW_COST_SOURCE,decode(PROJFUNC_RAW_COST,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                ,nvl(BURDENED_COST_SOURCE,decode(PROJFUNC_BURDENED_COST,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                ,nvl(QUANTITY_SOURCE,decode(QUANTITY,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                ,nvl(REVENUE_SOURCE,decode(PROJFUNC_REVENUE,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                ,PROJFUNC_CURRENCY_CODE
                ,PROJFUNC_COST_RATE_TYPE
                ,PROJFUNC_COST_EXCHANGE_RATE
                ,PROJFUNC_COST_RATE_DATE_TYPE
                ,PROJFUNC_COST_RATE_DATE
                ,PROJECT_CURRENCY_CODE
                ,PROJECT_COST_RATE_TYPE
                ,PROJECT_COST_EXCHANGE_RATE
                ,PROJECT_COST_RATE_DATE_TYPE
                ,PROJECT_COST_RATE_DATE
                ,null--PROJECT_RAW_COST
                ,null--PROJECT_BURDENED_COST
                ,null--PROJECT_REVENUE
                ,null--TXN_RAW_COST
                ,null--TXN_BURDENED_COST
                ,null--TXN_REVENUE
                ,TXN_CURRENCY_CODE
                ,BUCKETING_PERIOD_CODE
                ,PROJFUNC_REV_RATE_DATE_TYPE
                ,PROJFUNC_REV_RATE_DATE
                ,PROJFUNC_REV_RATE_TYPE
                ,PROJFUNC_REV_EXCHANGE_RATE
                ,DECODE(p_calling_context,
                        PA_FP_CONSTANTS_PKG.G_AUTOMATIC_BASELINE,'User',
                        PROJECT_REV_RATE_TYPE)--Bug 4133468. PROJECT_REV_RATE_TYPE
                ,DECODE(p_calling_context,
                        PA_FP_CONSTANTS_PKG.G_AUTOMATIC_BASELINE,DECODE(PROJFUNC_REVENUE,
                                                                        NULL,NULL,
                                                                        0,0,
                                                                        (PROJECT_REVENUE/PROJFUNC_REVENUE)),
                        PROJECT_REV_EXCHANGE_RATE)--Bug 4133468. PROJECT_REV_EXCHANGE_RATE
                ,DECODE(p_calling_context,
                        PA_FP_CONSTANTS_PKG.G_AUTOMATIC_BASELINE,NULL,
                        PROJECT_REV_RATE_DATE_TYPE)--Bug 4133468. PROJECT_REV_RATE_DATE_TYPE
                ,DECODE(p_calling_context,
                        PA_FP_CONSTANTS_PKG.G_AUTOMATIC_BASELINE,NULL,
                        PROJECT_REV_RATE_DATE)--Bug 4133468. PROJECT_REV_RATE_DATE
                ,PM_PRODUCT_CODE    -- , l_pm_product_code   changed to pm_product_code for bug 3833724
                ,PM_BUDGET_LINE_REFERENCE   -- Added for bug 3833724
      FROM  pa_fp_rollup_tmp tmp
      WHERE tmp.budget_line_id IS NULL
      AND   (tmp.txn_raw_cost IS NOT NULL
            or tmp.txn_burdened_cost IS NOT NULL
            or tmp.quantity IS NOT NULL
            or tmp.txn_revenue IS NOT NULL));

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:= 'number of records inserted -> ' || sql%ROWCOUNT;
          pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;
      ---------------------------------------------------------------------------------------------*/

      /* Bug 4221590:inserting into PA_FP_SPREAD_CALC_TMP1 */
      DELETE FROM PA_FP_SPREAD_CALC_TMP1;

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:= 'inserting into pa_fp_spread_calc_tmp1 -> ' || sql%ROWCOUNT;
          pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      INSERT INTO PA_FP_SPREAD_CALC_TMP1(
                 RESOURCE_ASSIGNMENT_ID
                ,BUDGET_VERSION_ID
                ,START_DATE
                ,BL_CREATION_DATE
                ,BL_CREATED_BY
                ,END_DATE
                ,PERIOD_NAME
                ,CHANGE_REASON_CODE
                ,DESCRIPTION
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,RAW_COST_SOURCE
                ,BURDENED_COST_SOURCE
                ,QUANTITY_SOURCE
                ,REVENUE_SOURCE
                ,PROJFUNC_CURRENCY_CODE
                ,PROJFUNC_COST_RATE_TYPE
                ,PROJFUNC_COST_EXCHANGE_RATE
                ,PROJFUNC_COST_RATE_DATE_TYPE
                ,PROJFUNC_COST_RATE_DATE
                ,PROJECT_CURRENCY_CODE
                ,PROJECT_COST_RATE_TYPE
                ,PROJECT_COST_EXCHANGE_RATE
                ,PROJECT_COST_RATE_DATE_TYPE
                ,PROJECT_COST_RATE_DATE
                ,TXN_CURRENCY_CODE
                ,BUCKETING_PERIOD_CODE
                ,PROJFUNC_REV_RATE_DATE_TYPE
                ,PROJFUNC_REV_RATE_DATE
                ,PROJFUNC_REV_RATE_TYPE
                ,PROJFUNC_REV_EXCHANGE_RATE
                ,PROJECT_REV_RATE_TYPE
                ,PROJECT_REV_EXCHANGE_RATE
                ,PROJECT_REV_RATE_DATE_TYPE
                ,PROJECT_REV_RATE_DATE
                ,PM_PRODUCT_CODE
                ,PM_BUDGET_LINE_REFERENCE ) -- Added for bug 3833724
       (SELECT
                 RESOURCE_ASSIGNMENT_ID
                ,p_fin_plan_version_id
                ,START_DATE
                ,SYSDATE
                ,FND_GLOBAL.USER_ID
                ,END_DATE
                ,PERIOD_NAME
                ,CHANGE_REASON_CODE
                ,DESCRIPTION
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,nvl(RAW_COST_SOURCE,decode(PROJFUNC_RAW_COST,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                ,nvl(BURDENED_COST_SOURCE,decode(PROJFUNC_BURDENED_COST,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                ,nvl(QUANTITY_SOURCE,decode(QUANTITY,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                ,nvl(REVENUE_SOURCE,decode(PROJFUNC_REVENUE,null,null,PA_FP_CONSTANTS_PKG.G_AMOUNT_SOURCE_MANUAL_M))
                ,PROJFUNC_CURRENCY_CODE
                ,PROJFUNC_COST_RATE_TYPE
                ,PROJFUNC_COST_EXCHANGE_RATE
                ,PROJFUNC_COST_RATE_DATE_TYPE
                ,PROJFUNC_COST_RATE_DATE
                ,PROJECT_CURRENCY_CODE
                ,PROJECT_COST_RATE_TYPE
                ,PROJECT_COST_EXCHANGE_RATE
                ,PROJECT_COST_RATE_DATE_TYPE
                ,PROJECT_COST_RATE_DATE
                ,TXN_CURRENCY_CODE
                ,BUCKETING_PERIOD_CODE
                ,PROJFUNC_REV_RATE_DATE_TYPE
                ,PROJFUNC_REV_RATE_DATE
                ,PROJFUNC_REV_RATE_TYPE
                ,PROJFUNC_REV_EXCHANGE_RATE
                ,DECODE(p_calling_context,
                        PA_FP_CONSTANTS_PKG.G_AUTOMATIC_BASELINE,'User',
                        PROJECT_REV_RATE_TYPE)--Bug 4133468. PROJECT_REV_RATE_TYPE
                ,DECODE(p_calling_context,
                        PA_FP_CONSTANTS_PKG.G_AUTOMATIC_BASELINE,DECODE(PROJFUNC_REVENUE,
                                                                        NULL,NULL,
                                                                        0,0,
                                                                        (PROJECT_REVENUE/PROJFUNC_REVENUE)),
                        PROJECT_REV_EXCHANGE_RATE)--Bug 4133468. PROJECT_REV_EXCHANGE_RATE
                ,DECODE(p_calling_context,
                        PA_FP_CONSTANTS_PKG.G_AUTOMATIC_BASELINE,NULL,
                        PROJECT_REV_RATE_DATE_TYPE)--Bug 4133468. PROJECT_REV_RATE_DATE_TYPE
                ,DECODE(p_calling_context,
                        PA_FP_CONSTANTS_PKG.G_AUTOMATIC_BASELINE,NULL,
                        PROJECT_REV_RATE_DATE)--Bug 4133468. PROJECT_REV_RATE_DATE
                ,PM_PRODUCT_CODE    -- , l_pm_product_code   changed to pm_product_code for bug 3833724
                ,PM_BUDGET_LINE_REFERENCE   -- Added for bug 3833724
      FROM  pa_fp_rollup_tmp tmp
      WHERE tmp.budget_line_id IS NULL);  /*Changed for bug 4224464. When a budget line is passed for which amounts and quantity
                                         were not passed i.e these values were miss_xxx values then these lines wont get selected here
                                         but in this case our intent should be to not update these columns for these lines and update
                                         the rest of the coulmns*/
/*      AND   (tmp.txn_raw_cost IS NOT NULL
            or tmp.txn_burdened_cost IS NOT NULL
            or tmp.quantity IS NOT NULL
            or tmp.txn_revenue IS NOT NULL));*/

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:= 'number of records inserted -> ' || sql%ROWCOUNT;
          pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
      END IF;

      -- Bug 3861261 Update resource assignments planning start and end date
      -- as the min(start_date) and max(end_date) of the corresponding budget lines
      -- Start changes for Bug 6432606
      -- In the AMG API flow for a scenario when task is having actuals the budget line
      -- corresponding that is not getting processed and stored in pa_fp_spread_calc_tmp1
      -- coz of that start date of that budget line is not taken in consideration.
      -- To avoid this planning_start_date is updated with original value if the original
      -- planning_start_date is least.
      IF(p_calling_context = PA_FP_CONSTANTS_PKG.G_AMG_API) THEN
        -- For scenario if actuals exist then planning start date for resource assignment
        -- should be least of the value presnt in   pa_fp_spread_calc_tmp1 and pa_budget_lines
        -- else it should be least of value present in pa_fp_spread_calc_tmp1.
        update pa_resource_assignments  pra
        set    (planning_start_date, planning_end_date)
                = (select decode(min(pbl.start_date),NULL,
                                  nvl(min(tmp.start_date), planning_start_date),
                                  least(nvl(min(tmp.start_date), planning_start_date),
                                        nvl(min(pbl.start_date), planning_start_date))),
                          nvl(max(tmp.end_date), planning_end_date)
              from   pa_fp_spread_calc_tmp1 tmp, pa_budget_lines pbl
              where  tmp.resource_assignment_id = pra.resource_assignment_id
                and  pbl.resource_assignment_id (+)= tmp.resource_assignment_id)
        where  pra.budget_version_id = p_fin_plan_version_id;
      ELSE
        update pa_resource_assignments  pra
        set    (planning_start_date, planning_end_date)
              = (select nvl(min(start_date), planning_start_date),
                        nvl(max(end_date), planning_end_date)
                 from   pa_fp_spread_calc_tmp1 tmp /* Bug 4221590 */
                 where  tmp.resource_assignment_id = pra.resource_assignment_id)
        where  pra.budget_version_id = p_fin_plan_version_id;
      END IF;
      --End changes for Bug 6432606

	IF p_pa_debug_mode = 'Y' THEN
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
               pa_debug.g_err_stage:= 'Invalid Arguments Passed';
               pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,5);
               pa_debug.reset_err_stack;
 	   END IF;
           RAISE;

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fin_plan_pvt'
                                  ,p_procedure_name  => 'CREATE_FINPLAN_LINES');
          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
              pa_debug.write('CREATE_FINPLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,5);
              pa_debug.reset_err_stack;
	END IF;
          RAISE;

END CREATE_FINPLAN_LINES;

/*Given the name of a plan type this function returns the
  Id of that plan type if it exists. Otherwise Null is
  returned
*/

FUNCTION Fetch_Plan_Type_Id
(p_fin_plan_type_name pa_fin_plan_types_tl.name%TYPE) RETURN NUMBER IS

CURSOR l_get_plan_type_id_csr
        (p_fin_plan_type_name pa_fin_plan_types_tl.name%TYPE )
IS
SELECT fin_plan_type_id
FROM   pa_fin_plan_types_vl
WHERE  name=p_fin_plan_type_name;

x_fin_plan_type_id  pa_fin_plan_types_b.fin_plan_type_id%TYPE;

BEGIN

    OPEN  l_get_plan_type_id_csr(p_fin_plan_type_name);
    FETCH l_get_plan_type_id_csr INTO x_fin_plan_type_id;

    IF (l_get_plan_type_id_csr%FOUND) THEN

        CLOSE  l_get_plan_type_id_csr;
        RETURN x_fin_plan_type_id;

    ELSE

        CLOSE  l_get_plan_type_id_csr;
        RETURN NULL;

    END IF;

END  Fetch_Plan_Type_Id;

/*This Procudure accepts plan type id and plan type name. If plan type id is not null
  its validity is checked and an error message is thrown if the id is invalid.If the name
  (and not id)  is passed, and if it is valid (case sensitive search is made while trying ot
  find the id of the name) tehe Id is passed. Otherwise an error message is thrown
*/

PROCEDURE convert_plan_type_name_to_id
( p_fin_plan_type_id    IN  pa_fin_plan_types_b.fin_plan_type_id%TYPE
 ,p_fin_plan_type_name  IN  pa_fin_plan_types_tl.name%TYPE
 ,x_fin_plan_type_id    OUT NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
 ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS

 CURSOR l_fin_plan_type_id_csr
        (p_fin_plan_type_id pa_fin_plan_types_b.fin_plan_type_id%TYPE)
 IS
 SELECT fin_plan_type_id
 FROM   pa_fin_plan_types_b
 WHERE  fin_plan_type_id=p_fin_plan_type_id;

 l_msg_count                     NUMBER := 0;
 l_data                          VARCHAR2(2000);
 l_msg_data                      VARCHAR2(2000);
 l_msg_index_out                 NUMBER;
 l_debug_mode                    VARCHAR2(1);

 l_debug_level2                  CONSTANT NUMBER := 2;
 l_debug_level3                  CONSTANT NUMBER := 3;
 l_debug_level4                  CONSTANT NUMBER := 4;
 l_debug_level5                  CONSTANT NUMBER := 5;

 BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

	IF p_pa_debug_mode = 'Y' THEN
	      pa_debug.set_curr_function( p_function   => 'convert_plan_type_name_to_id',
                                 p_debug_mode => l_debug_mode );
	END IF;
      -- If fin plan type id is passed. validate the fin plan type id. If it is not passed
      -- then convert name to fin plan type id
      IF (p_fin_plan_type_id IS NOT NULL) THEN

            OPEN l_fin_plan_type_id_csr(p_fin_plan_type_id);
            FETCH l_fin_plan_type_id_csr INTO x_fin_plan_type_id;

            IF(l_fin_plan_type_id_csr%NOTFOUND) THEN

                  PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_INVALID_PLAN_TYPE',
                      p_token1         => 'PLAN_TYPE',
                      p_value1         =>  p_fin_plan_type_id);

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  x_fin_plan_type_id:=NULL;
                  CLOSE l_fin_plan_type_id_csr;
                  IF l_debug_mode='Y' THEN
                  pa_debug.g_err_stage := 'p_fin_plan_type_id is '||p_fin_plan_type_id ;
                  pa_debug.write('convert_plan_type_name_to_id: ' || g_module_name
                                                              ,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            ELSE

                  close l_fin_plan_type_id_csr;
                  x_fin_plan_type_id:=p_fin_plan_type_id;

            END IF;

      ELSIF ( p_fin_plan_type_name IS NOT NULL) THEN

            x_fin_plan_type_id := fetch_plan_type_id(p_fin_plan_type_name);
            IF(x_fin_plan_type_id IS NULL) THEN

                  PA_UTILS.ADD_MESSAGE
                     (p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_INVALID_PLAN_TYPE',
                      p_token1         => 'PLAN_TYPE',
                      p_value1         =>  p_fin_plan_type_name);

                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF l_debug_mode='Y' THEN
                        pa_debug.g_err_stage := 'p_fin_plan_type_name is '||p_fin_plan_type_name ;
                        pa_debug.write('convert_plan_type_name_to_id: ' || g_module_name
                                                                    ,pa_debug.g_err_stage,l_debug_level5);
                  END IF;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;
            IF l_debug_mode='Y' THEN
                 pa_debug.g_err_stage := 'x_fin_plan_type_id derived is '||x_fin_plan_type_id ;
                 pa_debug.write('convert_plan_type_name_to_id: ' || g_module_name
                                                              ,pa_debug.g_err_stage,l_debug_level5);
            END IF;


      ELSE

            PA_UTILS.ADD_MESSAGE
                 (p_app_short_name => 'PA',
                  p_msg_name       => 'PA_FP_INV_PARAM_PASSED');

             x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      IF l_debug_mode='Y' THEN
            pa_debug.g_err_stage := 'p_fin_plan_type_name is '||p_fin_plan_type_name ;
            pa_debug.write('convert_plan_type_name_to_id: ' || g_module_name
                                                        ,pa_debug.g_err_stage,l_debug_level5);
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
	 IF l_debug_mode='Y' THEN
            pa_debug.reset_curr_function;
	 END IF;
            RETURN;

      WHEN OTHERS THEN

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count     := 1;
            x_msg_data      := SQLERRM;


            FND_MSG_PUB.add_exc_msg
                         ( p_pkg_name        => 'pa_fin_plan_pvt'
                          ,p_procedure_name  => 'convert_plan_type_name_to_id'
                          ,p_error_text      => x_msg_data);

            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
                pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                    l_debug_level5);
                pa_debug.reset_curr_function;
            END IF;
            RAISE;

END convert_plan_type_name_to_id;

/*=====================================================================
Procedure Name:      DELETE_WP_OPTION

This procedure is added as part of FPM Development. Tracking Bug - 3354518.

Purpose:             This api Deletes the proj fp options data pertaining
                      to the workplan type attached to the project for
                      the passed project id.
                      Deletes data from the following tables -
                        1)   pa_proj_fp_options
                        2)   pa_fp_txn_currencies
                        3)   pa_proj_period_profiles
                        4)   pa_fp_upgrade_audit

Please note that all validations before calling this API shall be done
in the calling entity.

Parameters:
IN                   1) p_project_id - project id.
=======================================================================*/
PROCEDURE Delete_wp_option
     (p_project_id           IN    pa_projects_all.project_id%TYPE
     ,x_return_status        OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count            OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data             OUT   NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
     IS

    --Start of variables used for debugging
      l_msg_count          NUMBER :=0;
      l_data               VARCHAR2(2000);
      l_msg_data           VARCHAR2(2000);
      l_error_msg_code     VARCHAR2(30);
      l_msg_index_out      NUMBER;
      l_return_status      VARCHAR2(2000);
      l_debug_mode         VARCHAR2(30);
    --End of variables used for debugging

      l_proj_fp_options_id   pa_proj_fp_options.proj_fp_options_id%TYPE;
      l_sv_id_tbl          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
      l_sv_id_count        NUMBER;

      cursor c_struct_ver(c_project_id pa_projects_all.project_id%TYPE) IS
      SELECT project_structure_version_id
      FROM pa_budget_versions
      WHERE project_id = c_project_id
      AND nvl(wp_version_flag,'N') = 'Y';

 BEGIN

    SAVEPOINT DELETE_WP_OPTION_SAVE;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'N');
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
	IF p_pa_debug_mode = 'Y' THEN
	    PA_DEBUG.Set_Curr_Function( p_function   => 'PA_FIN_PLAN_PVT.Delete_wp_option',
                                p_debug_mode => l_debug_mode );
	END IF;
---------------------------------------------------------------
-- validating input parameter p_project_id.
-- p_project_id cannot be passed as null.
---------------------------------------------------------------
    IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Validating input parameters';
       pa_debug.write('Delete_wp_option: ' || g_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL)
    THEN

             IF l_debug_mode = 'Y' THEN
                pa_debug.write('Delete_wp_options Project Id is null: ' || g_module_name,pa_debug.g_err_stage,5);
             END IF;

             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                  p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

---------------------------------------------------------------
--Fetch proj_fp_options_id
---------------------------------------------------------------

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Fetching proj_fp_options_id ';
        pa_debug.write('Delete_wp_option: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

    SELECT  pfo.proj_fp_options_id
      INTO  l_proj_fp_options_id
      FROM  pa_proj_fp_options pfo
           ,pa_fin_plan_types_b pft
     WHERE  pfo.project_id = p_project_id
       AND  pfo.fin_plan_type_id = pft.fin_plan_type_id
       AND  pfo.fin_plan_option_level_code =  PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE
       AND  nvl(pft.use_for_workplan_flag,'N') = 'Y';

-----------------------------------------------------------------
--  Fetching the workplan structure version ids for the project id
--  passed into the PLSql table l_sv_id_tbl and then calling API
--  Delete_wp_budget_versions
-----------------------------------------------------------------

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Fetching the workplan structure ids for the project id';
        pa_debug.write('Delete_wp_option: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

    OPEN c_struct_ver(p_project_id);

     FETCH c_struct_ver BULK COLLECT INTO l_sv_id_tbl;
       IF c_struct_ver%NOTFOUND THEN
            IF p_pa_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'No Structure versions for the project_id passed - project_id: '||p_project_id;
               pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            END IF;
       END IF;
    CLOSE c_struct_ver;

    l_sv_id_count := l_sv_id_tbl.count;

    IF l_sv_id_count > 0 THEN

       IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Deleting all version data for the wp structure version ids pertaining to project_id:'||p_project_id;
        pa_debug.write('Delete_wp_option: ' || g_module_name,pa_debug.g_err_stage,3);
       END IF;

      Delete_wp_budget_versions
      (p_struct_elem_version_id_tbl =>   l_sv_id_tbl
      ,x_return_status              =>   l_return_status
      ,x_msg_count                  =>   l_msg_count
      ,x_msg_data                   =>   l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Call to Delete_wp_budget_versions is returning error status';
             pa_debug.write('Delete_wp_option: ' || g_module_name,pa_debug.g_err_stage,3);
          END IF;
         RAISE Delete_Ver_Exc_PVT;
      END IF;

    END IF;

-- Bug 5743297: Moved the following DELETE statements which were before the Delete_wp_budget_versions API
-- call to here for avoiding NO_DATA_FOUND.
---------------------------------------------------------------
--Deleting data from respective tables
---------------------------------------------------------------

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Deleting data from respective tables';
        pa_debug.write('Delete_wp_option: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     -- delete from pa_proj_fp_options table
    DELETE FROM pa_proj_fp_options WHERE proj_fp_options_id = l_proj_fp_options_id;

     -- delete from pa_fp_txn_currencies
    DELETE FROM pa_fp_txn_currencies WHERE proj_fp_options_id = l_proj_fp_options_id;

     -- delete from pa_fp_upgrade_audit
    DELETE FROM pa_fp_upgrade_audit WHERE proj_fp_options_id = l_proj_fp_options_id;

     IF l_debug_mode = 'Y' THEN
       pa_debug.reset_curr_function;
     END IF;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
         IF l_debug_mode = 'Y' THEN
           pa_debug.reset_curr_function;
         END IF;
     WHEN Delete_Ver_Exc_PVT THEN
          ROLLBACK TO SAVEPOINT PA_FP_PUB_DELETE_VER;
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
              pa_debug.g_err_stage:='Delete_wp_budget_versions returned error';
              pa_debug.write('Delete_wp_option: ' || g_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_curr_function;
           END IF;

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
              pa_debug.write('Delete_wp_option: ' || g_module_name,pa_debug.g_err_stage,5);
              pa_debug.reset_curr_function;
           END IF;

     WHEN Others THEN
          ROLLBACK TO SAVEPOINT DELETE_WP_OPTION_SAVE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FIN_PLAN_PVT'
                                  ,p_procedure_name  => 'Delete_wp_option');

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write('Delete_wp_option: ' || g_module_name,pa_debug.g_err_stage,5);
              pa_debug.reset_curr_function;
          END IF;
          RAISE;

END Delete_wp_option;

/*=====================================================================
 * Procedure Name:      DELETE_WP_BUDGET_VERSIONS
 * This procedure is added as part of FPM Development. Trackinb Bug - 3354518.
 * Purpose:              This API deletes the budget_versions for all the
 *                       workplan structure version ids passed.
 * Parameters: 1) p_struct_elem_version_id_tbl IN SYSTEM.pa_num_tbl_type
 *=======================================================================*/
  PROCEDURE Delete_wp_budget_versions
     (p_struct_elem_version_id_tbl IN    SYSTEM.pa_num_tbl_type
     ,x_return_status              OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                  OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                   OUT   NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
     IS

--Start of variables used for debugging
      l_msg_count          NUMBER :=0;
      l_data               VARCHAR2(2000);
      l_msg_data           VARCHAR2(2000);
      l_error_msg_code     VARCHAR2(30);
      l_msg_index_out      NUMBER;
      l_return_status      VARCHAR2(2000);
      l_debug_mode         VARCHAR2(30);
--End of variables used for debugging

      l_sv_id_tbl_count    NUMBER;

      cursor c_budget_ver(c_structure_version_id pa_budget_versions.project_structure_version_id%TYPE) IS
        SELECT budget_version_id,record_version_number,project_id
          FROM pa_budget_versions
         WHERE project_structure_version_id = nvl(c_structure_version_id,-99)
         AND   nvl(wp_version_flag,'N')='Y';

   BEGIN
    SAVEPOINT PA_FP_PUB_DELETE_VER;

       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       l_debug_mode := NVL(l_debug_mode, 'N');
       x_msg_count := 0;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
	IF p_pa_debug_mode = 'Y' THEN
	       PA_DEBUG.Set_Curr_Function( p_function   => 'PA_FIN_PLAN_PVT.Delete_wp_bugdet_versions',
                                   p_debug_mode => l_debug_mode );
	END IF;

------------------------------------------------------------------------
-- Check if the PLSql Table p_struct_elem_version_id_tbl has no records.
------------------------------------------------------------------------

         IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Checking for existence of data in PLsql table p_struct_elem_version_id_tbl';
            pa_debug.write('Delete_wp_bugdet_versions: ' || g_module_name,pa_debug.g_err_stage,3);
         END IF;

         l_sv_id_tbl_count := p_struct_elem_version_id_tbl.COUNT;

         IF l_sv_id_tbl_count = 0 THEN
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;


------------------------------------------------------------------
-- Derive budget_version_id based on structure_version_id passed
------------------------------------------------------------------

        --------------------------------------------------
        -- Loop through all the structure_verion_id passed
        --------------------------------------------------
        FOR i in p_struct_elem_version_id_tbl.first .. p_struct_elem_version_id_tbl.last LOOP --LoopA

             IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Outer loop : '||i;
                pa_debug.write('Delete_wp_bugdet_versions: ' || g_module_name,pa_debug.g_err_stage,3);
             END IF;

            -----------------------------------------------------------
            -- For each stucture_version_id fetch the budget_version_id
            -----------------------------------------------------------
            FOR c1 IN c_budget_ver(p_struct_elem_version_id_tbl(i)) LOOP --LoopB

              ------------------------------------------------------------------
              -- If no budget versions exist for the structure_version_id passed
              -- iterate through the out loop LoopA
              ------------------------------------------------------------------

                  IF c_budget_ver%NOTFOUND THEN
                     IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Could not fetch budget_version_id !!!...';
                        pa_debug.write(g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                     END IF;
                  EXIT; -- Come out of LoopB, Jump to next iteration of LoopA
                  END IF;

             ------------------------------------------------------------------
             -- Call Delete_Version for Version_id to delete all version
             -- data for the budget_version_id fetched.
             ------------------------------------------------------------------
                 pa_fin_plan_pub.Delete_Version
                 (p_budget_version_id     => c1.budget_version_id,
                  p_record_version_number => c1.record_version_number,
                  p_context               => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN,
                  p_project_id            => c1.project_id,
                  x_return_Status         => l_return_Status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE Delete_Ver_Exc_PVT;
                 END IF;

            END LOOP;   -- LoopB Closed
        END LOOP; -- LoopA Closed
      IF p_pa_debug_mode = 'Y' THEN
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

           IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:='Invalid Arguments Passed';
              pa_debug.write('Delete_wp_budget_version: ' || g_module_name,pa_debug.g_err_stage,5);
              pa_debug.reset_curr_function;
          END IF;

    WHEN Delete_Ver_Exc_PVT THEN
          ROLLBACK TO SAVEPOINT PA_FP_PUB_DELETE_VER;
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
             pa_debug.g_err_stage:='Delete_version_helper returned error';
             pa_debug.write('Delete_wp_options: ' || g_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_curr_function;
        END IF;

    WHEN Others THEN
          ROLLBACK TO SAVEPOINT DELETE_WP_OPTION_SAVE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FIN_PLAN_PVT'
                                  ,p_procedure_name  => 'Delete_wp_budget_versions');

           IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write('Delete_wp_budget_versions: ' || g_module_name,pa_debug.g_err_stage,5);
              pa_debug.reset_curr_function;
           END IF;
          RAISE;

END Delete_wp_budget_versions;

PROCEDURE ADD_FIN_PLAN_LINES
    ( -- Bug Fix: 4569365. Removed MRC code.
	  -- p_calling_context         IN      pa_mrc_finplan.g_calling_module%TYPE
	  p_calling_context         IN      VARCHAR2
     ,p_fin_plan_version_id     IN      pa_budget_versions.budget_version_id%TYPE
     ,p_finplan_lines_tab       IN      pa_fin_plan_pvt.budget_lines_tab
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

     l_msg_count                     NUMBER := 0;
     l_data                          VARCHAR2(2000);
     l_msg_data                      VARCHAR2(2000);
     l_error_msg_code                VARCHAR2(30);
     l_msg_index_out                 NUMBER;
     l_return_status                 VARCHAR2(1);
     l_debug_mode                    VARCHAR2(30);
     l_resource_name                 VARCHAR2(30);
     l_err_code                      NUMBER:=0;
     l_debug_level3                  CONSTANT NUMBER := 3;
     l_debug_level5                  CONSTANT NUMBER := 5;

     l_resource_assignment_tab       SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
     l_delete_budget_lines_tab       SYSTEM.pa_varchar2_1_tbl_type     := SYSTEM.pa_varchar2_1_tbl_type();
     l_spread_amts_flag_tab          SYSTEM.pa_varchar2_1_tbl_type     := SYSTEM.pa_varchar2_1_tbl_type();
     l_line_start_date_tab           SYSTEM.pa_date_tbl_type           := SYSTEM.pa_date_tbl_type();
     l_line_end_date_tab             SYSTEM.pa_date_tbl_type           := SYSTEM.pa_date_tbl_type();
     i                               NUMBER;
     l_lines_count                   NUMBER; -- Bug 3639983
     l_module_name                   VARCHAR2(30) := 'pa.plsql.PA_FIN_PLAN_PVT';
     l_project_id                    pa_budget_versions.project_id%TYPE;
     l_fp_version_ids                SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
     l_txn_currency_code_tab         SYSTEM.pa_varchar2_15_tbl_type    := SYSTEM.pa_varchar2_15_tbl_type();
     l_txn_currency_override_tab     SYSTEM.pa_varchar2_15_tbl_type    := SYSTEM.pa_varchar2_15_tbl_type();
     l_total_qty_tab                 SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
     l_total_raw_cost_tab            SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
     l_total_burdened_cost_tab       SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
     l_total_revenue_tab             SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
     l_number_null_tab               SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type(); --bug 3825873

     -- bug 4221650: added the following
     l_ver_time_phased_code          pa_proj_fp_options.cost_time_phased_code%TYPE;

     CURSOR get_proj_id_csr IS
     SELECT project_id FROM pa_budget_versions
     WHERE budget_version_id = p_fin_plan_version_id ;

     BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');

	IF p_pa_debug_mode = 'Y' THEN
	     PA_DEBUG.Set_Curr_Function( p_function   => 'PA_FIN_PLAN_PVT.ADD_FIN_PLAN_LINES',
                                 p_debug_mode => l_debug_mode );
	END IF;
     l_lines_count := p_finplan_lines_tab.COUNT;
     IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Validating input parameter - plan lines count cannot be 0';
            pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

-- Change of Code for Bug 3639983 Starts Here
     IF l_lines_count = 0 THEN
         IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='No Lines to be added - Returning';
                pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
                pa_debug.reset_curr_function;
        END IF;
         RETURN;
     END IF;
-- Change of Code for Bug 3639983 Ends Here

     IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Calling CREATE_FINPLAN_LINES';
            pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     --Call to api PA_FIN_PLAN_PVT.CREATE_FINPLAN_LINES

     IF ( nvl(p_finplan_lines_tab.last,0) > 0 ) THEN

         PA_FIN_PLAN_PVT.CREATE_FINPLAN_LINES
             ( p_calling_context         => p_calling_context
              ,p_fin_plan_version_id     => p_fin_plan_version_id
              ,p_budget_lines_tab        => p_finplan_lines_tab
              ,x_return_status           => x_return_status
              ,x_msg_count               => x_msg_count
              ,x_msg_data                => x_msg_data );

         IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Return Status After CREATE_FINPLAN_LINES :'||x_return_status;
                pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
         END IF;

         IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN

                 IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage:= 'Error Calling CREATE_FINPLAN_LINES';
                 pa_debug.write('CREATE_DRAFT: '||g_module_name,pa_debug.g_err_stage,5);
                 END IF;

                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

         END IF;

     END IF;

-- Change of Code for Bug 3639983 Starts Here
     IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Extending lenght of all local empty table to l_lines_count';
            pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

    l_line_start_date_tab.extend(l_lines_count);
    l_line_end_date_tab.extend(l_lines_count);
    l_total_qty_tab.extend(l_lines_count);
    l_txn_currency_code_tab.extend(l_lines_count);
    l_total_raw_cost_tab.extend(l_lines_count);
    l_total_burdened_cost_tab.extend(l_lines_count);
    l_total_revenue_tab.extend(l_lines_count);
    l_resource_assignment_tab.extend(l_lines_count);
    l_delete_budget_lines_tab.extend(l_lines_count);
    l_spread_amts_flag_tab.extend(l_lines_count);
    l_number_null_tab.extend(l_lines_count); -- bug 3825873

-- Change of Code for Bug 3639983 Ends Here
-- Change of Code for Bug 3732414 Starts Here
    SELECT start_date,
           end_date,
           quantity,
           txn_currency_code,
           txn_raw_cost,
           txn_burdened_cost,
           txn_revenue,
           resource_assignment_id,
           'N' delete_budget_lines,
           'N' spread_amouts,
           NULL
    BULK   COLLECT INTO
          l_line_start_date_tab
         ,l_line_end_date_tab
         ,l_total_qty_tab
         ,l_txn_currency_code_tab
         ,l_total_raw_cost_tab
         ,l_total_burdened_cost_tab
         ,l_total_revenue_tab
         ,l_resource_assignment_tab
         ,l_delete_budget_lines_tab
         ,l_spread_amts_flag_tab
         ,l_number_null_tab -- bug 3825873
    FROM   pa_fp_rollup_tmp;

-- Change of Code for Bug 3732414 Ends Here

     IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Fetching project Id from get_proj_id_csr';
            pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     OPEN get_proj_id_csr ;
     FETCH get_proj_id_csr into l_project_id ;
     CLOSE get_proj_id_csr;

     -- Calling PA_FP_CALC_PLAN_PKG.calculate api
     IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Calling Calculate API';
            pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='Calling Calculate API l_project_id'||l_project_id;
            pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='Calling Calculate API p_fin_plan_version_id'||p_fin_plan_version_id;
            pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='Calling Calculate API l_resource_assignment_tab'||l_resource_assignment_tab.COUNT;
            pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='Calling Calculate API l_delete_budget_lines_tab'||l_delete_budget_lines_tab.COUNT;
            pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='Calling Calculate API l_spread_amts_flag_tab'||l_spread_amts_flag_tab.COUNT;
            pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);

            pa_debug.g_err_stage:='Calling Calculate API l_txn_currency_code_tab'||l_txn_currency_code_tab.COUNT;
            pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);

     END IF;

     -- bug 4221650: checking for the time phased code of the version to call
     -- calculate api in either 'RESOURCE_ASSIGNMENT' or in 'BUDGET_LINE' mode

     l_ver_time_phased_code := PA_FIN_PLAN_UTILS.get_time_phased_code (p_fin_plan_version_id);

     IF NOT l_ver_time_phased_code = 'N' THEN

         IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:=' Calling Calculate in BUDGET_LINE mode';
                pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
         END IF;

         -- bug 3825873 17-JUL-2004 Corrected the input parameters
          /*Bug 4224464 Added the if condition to ditinguish the call to calculate API in AMG flow from other flows.
           We are passing the parameter p_calling_module as G_AMG_API if its a AMG flow. This parameter would be internally used by
           calculate API to skip the call to client extensions for AMG flows.
          Also added the parameter so as not to delete the PA_FP_SPREAD_CALC_TMP1 table in calcualte API . This parameter whould be
          passed   in all the flows so as not to delete the PA_FP_SPREAD_CALC_TMP1 table.*/
           IF(p_calling_context = PA_FP_CONSTANTS_PKG.G_AMG_API)
           THEN
              PA_FP_CALC_PLAN_PKG.calculate
                           ( p_project_id                       => l_project_id
                            ,p_budget_version_id                => p_fin_plan_version_id
                            ,p_source_context                   => 'BUDGET_LINE'
                            ,p_refresh_rates_flag               => 'N'
                            ,p_refresh_conv_rates_flag          => 'N'
                            ,p_conv_rates_required_flag         => 'Y'
                            ,p_spread_required_flag             => 'Y'
                            ,p_rollup_required_flag             => 'Y'
                            ,p_mass_adjust_flag                 => 'N'
                            ,p_resource_assignment_tab          => l_resource_assignment_tab
                            ,p_delete_budget_lines_tab          => l_delete_budget_lines_tab
                            ,p_spread_amts_flag_tab             => l_spread_amts_flag_tab
                            ,p_txn_currency_code_tab            => l_txn_currency_code_tab
                            ,p_total_qty_tab                    => l_total_qty_tab
                            ,p_addl_qty_tab                     => l_number_null_tab
                            ,p_total_raw_cost_tab               => l_total_raw_cost_tab
                            ,p_addl_raw_cost_tab                => l_number_null_tab
                            ,p_total_burdened_cost_tab          => l_total_burdened_cost_tab
                            ,p_addl_burdened_cost_tab           => l_number_null_tab
                            ,p_total_revenue_tab                => l_total_revenue_tab
                            ,p_addl_revenue_tab                 => l_number_null_tab
                            ,p_line_start_date_tab              => l_line_start_date_tab
                            ,p_line_end_date_tab                => l_line_end_date_tab
                            ,p_raw_cost_rate_tab                => l_number_null_tab
                            ,p_rw_cost_rate_override_tab        => l_number_null_tab
                            ,p_b_cost_rate_tab                  => l_number_null_tab
                            ,p_b_cost_rate_override_tab         => l_number_null_tab
                            ,p_bill_rate_tab                    => l_number_null_tab
                            ,p_bill_rate_override_tab           => l_number_null_tab
                            ,p_del_spread_calc_tmp1_flg         => 'N'  /* Bug: 4309290.Added the parameter to identify if
                                                                           PA_FP_SPREAD_CALC_TMP1 is to be deleted or not. Frm AMG flow
                                                                           we will pass N and for other calls to calculate api it would
                                                                           be yes */
                            ,p_calling_module                   => PA_FP_CONSTANTS_PKG.G_AMG_API
                            ,x_return_status                    => x_return_status
                            ,x_msg_count                        => x_msg_count
                            ,x_msg_data                         => x_msg_data);
           ELSE
              PA_FP_CALC_PLAN_PKG.calculate
                           ( p_project_id                       => l_project_id
                            ,p_budget_version_id                => p_fin_plan_version_id
                            ,p_source_context                   => 'BUDGET_LINE'
                            ,p_refresh_rates_flag               => 'N'
                            ,p_refresh_conv_rates_flag          => 'N'
                            ,p_conv_rates_required_flag         => 'Y'
                            ,p_spread_required_flag             => 'Y'
                            ,p_rollup_required_flag             => 'Y'
                            ,p_mass_adjust_flag                 => 'N'
                            ,p_resource_assignment_tab          => l_resource_assignment_tab
                            ,p_delete_budget_lines_tab          => l_delete_budget_lines_tab
                            ,p_spread_amts_flag_tab             => l_spread_amts_flag_tab
                            ,p_txn_currency_code_tab            => l_txn_currency_code_tab
                            ,p_total_qty_tab                    => l_total_qty_tab
                            ,p_addl_qty_tab                     => l_number_null_tab
                            ,p_total_raw_cost_tab               => l_total_raw_cost_tab
                            ,p_addl_raw_cost_tab                => l_number_null_tab
                            ,p_total_burdened_cost_tab          => l_total_burdened_cost_tab
                            ,p_addl_burdened_cost_tab           => l_number_null_tab
                            ,p_total_revenue_tab                => l_total_revenue_tab
                            ,p_addl_revenue_tab                 => l_number_null_tab
                            ,p_line_start_date_tab              => l_line_start_date_tab
                            ,p_line_end_date_tab                => l_line_end_date_tab
                            ,p_raw_cost_rate_tab                => l_number_null_tab
                            ,p_rw_cost_rate_override_tab        => l_number_null_tab
                            ,p_b_cost_rate_tab                  => l_number_null_tab
                            ,p_b_cost_rate_override_tab         => l_number_null_tab
                            ,p_bill_rate_tab                    => l_number_null_tab
                            ,p_bill_rate_override_tab           => l_number_null_tab
                            ,p_del_spread_calc_tmp1_flg         => 'N'
                            ,x_return_status                    => x_return_status
                            ,x_msg_count                        => x_msg_count
                            ,x_msg_data                         => x_msg_data);
           END IF;
     ELSE
         -- bug 4221650:
         IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:=' Calling Calculate in RESOURCE_ASSIGNMENT mode';
                pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
         END IF;

          /*Bug 4224464 Added the if condition to ditinguish the call to calculate API in AMG flow from other flows.
           We are passing the parameter p_calling_module as G_AMG_API if its a AMG flow. This parameter would be internally used by
           calculate API to skip the call to client extensions for AMG flows.
          Also added the parameter so as not to delete the PA_FP_SPREAD_CALC_TMP1 table in calcualte API . This parameter whould be
          passed   in all the flows so as not to delete the PA_FP_SPREAD_CALC_TMP1 table.*/
           IF(p_calling_context = PA_FP_CONSTANTS_PKG.G_AMG_API)
           THEN
                 PA_FP_CALC_PLAN_PKG.calculate
                              ( p_project_id                       => l_project_id
                               ,p_budget_version_id                => p_fin_plan_version_id
                               ,p_source_context                   => 'RESOURCE_ASSIGNMENT'
                               ,p_resource_assignment_tab          => l_resource_assignment_tab
                               ,p_spread_amts_flag_tab             => l_spread_amts_flag_tab
                               ,p_txn_currency_code_tab            => l_txn_currency_code_tab
                               ,p_total_qty_tab                    => l_total_qty_tab
                               ,p_total_raw_cost_tab               => l_total_raw_cost_tab
                               ,p_total_burdened_cost_tab          => l_total_burdened_cost_tab
                               ,p_total_revenue_tab                => l_total_revenue_tab
                               ,p_line_start_date_tab              => l_line_start_date_tab
                               ,p_line_end_date_tab                => l_line_end_date_tab
                               ,p_calling_module                   => PA_FP_CONSTANTS_PKG.G_AMG_API
                               ,p_del_spread_calc_tmp1_flg         => 'N'
                               ,x_return_status                    => x_return_status
                               ,x_msg_count                        => x_msg_count
                               ,x_msg_data                         => x_msg_data);
           ELSE
                 PA_FP_CALC_PLAN_PKG.calculate
                              ( p_project_id                       => l_project_id
                               ,p_budget_version_id                => p_fin_plan_version_id
                               ,p_source_context                   => 'RESOURCE_ASSIGNMENT'
                               ,p_resource_assignment_tab          => l_resource_assignment_tab
                               ,p_spread_amts_flag_tab             => l_spread_amts_flag_tab
                               ,p_txn_currency_code_tab            => l_txn_currency_code_tab
                               ,p_total_qty_tab                    => l_total_qty_tab
                               ,p_total_raw_cost_tab               => l_total_raw_cost_tab
                               ,p_total_burdened_cost_tab          => l_total_burdened_cost_tab
                               ,p_total_revenue_tab                => l_total_revenue_tab
                               ,p_line_start_date_tab              => l_line_start_date_tab
                               ,p_line_end_date_tab                => l_line_end_date_tab
                               ,p_del_spread_calc_tmp1_flg         => 'N'
                               ,x_return_status                    => x_return_status
                               ,x_msg_count                        => x_msg_count
                               ,x_msg_data                         => x_msg_data);
           END IF;  -- IF(p_calling_context = PA_FP_CONSTANTS_PKG.G_AMG_API)

     END IF;

     IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Return Status After CALCULATE :'||x_return_status;
            pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Called API PA_FP_CALC_PLAN_PKG.calculate returned error';
             pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
          END IF;

     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;
     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting ADD FIN PLAN LINES  x_return_status: '||x_return_status;
        pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,3);
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

           pa_debug.g_err_stage:= 'Invalid Arguments Passed';

           IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             pa_debug.reset_curr_function;
           END IF;
           RETURN;

     WHEN others THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count     := 1;
           x_msg_data      := SQLERRM;

           FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'pa_fin_plan_pvt'
                                   ,p_procedure_name  => 'ADD_FIN_PLAN_LINES');
           pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;

           IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('ADD_FIN_PLAN_LINES: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             pa_debug.reset_curr_function;
           END IF;
           RAISE;

END ADD_FIN_PLAN_LINES;

END pa_fin_plan_pvt;

/
