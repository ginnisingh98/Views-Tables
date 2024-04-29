--------------------------------------------------------
--  DDL for Package Body PA_FIN_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FIN_PLAN_PUB" as
/* $Header: PAFPPUBB.pls 120.18.12010000.9 2009/10/23 13:07:27 arbandyo ship $
   Start of Comments
   Package name     : PA_FIN_PLAN_PUB
   Purpose          : utility API's for Org Forecast pages
   History          :
   NOTE             :
   End of Comments
*/

/* BUG NO:- 2331201 For FINPLAN these pacakge level variables have been included */

   l_module_name VARCHAR2(100) := 'pa.plsql.pa_fin_plan_pub';
   -- Bug Fix: 4569365. Removed MRC code.
   -- g_mrc_exception  EXCEPTION; /* FPB2 */

/* ------------------------------------------------------------------------- */


P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

--Bug 3964755. Introduced the parameter p_calling_context. Valid values are NULL and 'COPY_PROJECT'
procedure Submit_Current_Working
    (p_calling_context                  IN     VARCHAR2                                         DEFAULT NULL,
     p_project_id                       IN     pa_budget_versions.project_id%TYPE,
     p_budget_version_id                IN     pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number            IN     pa_budget_versions.record_version_number%TYPE,
     x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
l_debug_mode      VARCHAR2(30);
l_valid_flag              VARCHAR2(1);
l_current_working_flag    pa_budget_versions.current_working_flag%TYPE;
l_budget_status_code      pa_budget_versions.budget_status_code%TYPE;
l_plan_processing_code    pa_budget_versions.plan_processing_code%TYPE;
l_locked_by_person_id   pa_budget_versions.locked_by_person_id%TYPE;
/* Bug# 2661650 - _vl to _b/_tl for performance changes */
l_fin_plan_type_code      pa_fin_plan_types_b.fin_plan_type_code%TYPE;

l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_error_msg_code  VARCHAR2(30);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);

begin
    FND_MSG_PUB.initialize;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PA_FIN_PLAN_PUB.Submit_Current_Working');
    END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Submit_Current_Working: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
/* CHECK FOR BUSINESS RULES VIOLATIONS */
    /* check for null budget_version_id */
    if p_budget_version_id is NULL then
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_NO_PLAN_VERSION');
    end if;
    /* check to see if the budget version we're updating is a WORKING version; */
    /* only CURRENT WORKING versions can be submitted */
    select
        current_working_flag,
        budget_status_code,
        plan_processing_code,
  locked_by_person_id
    into
        l_current_working_flag,
        l_budget_status_code,
        l_plan_processing_code,
  l_locked_by_person_id
    from
        pa_budget_versions
    where
        budget_version_id = p_budget_version_id;
      select pt.fin_plan_type_code
        into l_fin_plan_type_code
        from pa_proj_fp_options po,
             pa_fin_plan_types_b pt /* Bug# 2661650 - _vl to _b/_tl for performance changes */
        where po.project_id = p_project_id and
              po.fin_plan_version_id = p_budget_version_id and
              po.fin_plan_option_level_code = 'PLAN_VERSION' and
              po.fin_plan_type_id = pt.fin_plan_type_id;
    /* allow user to Submit a version that's already Submitted */
    if not ((l_current_working_flag = 'Y') and (l_budget_status_code in ('W', 'S'))) then
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Submit_Current_Working: ' || 'selected budget version is not a current working version');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_SUBMIT_CURRENT_WORKING');
    end if;
    /* check to see if the budget version is currently under regeneration.  If so, we */
    /* cannot submit it for baselining */
    /*** BUG FIX 2779674: check for regeneration in progress OR period profile refresh
     *** in progress
     */
    -- if l_plan_processing_code <> PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G then
    if nvl(l_plan_processing_code,'X') = PA_FP_CONSTANTS_PKG.G_PLAN_PROC_CODE_P then
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_SUBMIT_GENERATED');
    end if;
    if nvl(l_plan_processing_code,'X') = PA_FP_CONSTANTS_PKG.G_PLAN_PROC_CODE_PPP then
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_SUBMIT_PP_REFRESHING');
    end if;

    /* check to see if the budget version we're updating to be current working has */
    /* been updated by someone else already */
    PA_FIN_PLAN_UTILS.Check_Record_Version_Number
            (p_unique_index             => p_budget_version_id,
             p_record_version_number    => p_record_version_number,
             x_valid_flag               => l_valid_flag,
             x_return_status            => l_return_status,
             x_error_msg_code           => l_error_msg_code);
    if x_return_status = FND_API.G_RET_STS_ERROR then
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Submit_Current_Working: ' || 'record version number error ');
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => l_error_msg_code);
    end if;

    /* Check to see if the plan version is locked.  An unlocked plan version cannot be submitted */
    --Bug 3964755. This check is not required in copy project flow. In this flow, the version would be created,
    --submitted and baselined by the API that copies the project. This check would result in an error since
    --locked_by_person_id is not copied in copy_budget_version API. Hence skipping this check
    -- Bug 4276265: do not check for lock if plan version is Org Forecasting version
    if (l_locked_by_person_id is null)  AND
       NVL(p_calling_context, '-99') <> 'COPY_PROJECT' AND
       NVL(l_fin_plan_type_code,'-99') <> 'ORG_FORECAST' then --Bug 5456482
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_SUBMIT_UNLOCKED_VER');
    end if; --locked_by_person_id is null

/* If There are ANY Busines Rules Violations , Then Do NOT Proceed: RETURN */
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

/* If There are NO Business Rules Violations , Then proceed with Submit Current Working */
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('Submit_Current_Working: ' || 'no business rules violations');
    END IF;
    if l_msg_count = 0 then
      SAVEPOINT PA_FIN_PLAN_PUB_SUBMIT_WORKING;

      /* FINPLANNING PATCHSET K: If the plan type is not ORG_FORECAST, then call
         pa_fin_plan_pvt.Submit_Current_Working_FinPlan
       */
      if l_fin_plan_type_code = 'ORG_FORECAST' then
        /* set the BUDGET_STATUS_CODE from 'W' to 'S' */
        update
            pa_budget_versions
        set
            last_update_date=SYSDATE,
            last_updated_by=FND_GLOBAL.user_id,
            last_update_login=FND_GLOBAL.login_id,
            budget_status_code = 'S',
            record_version_number=record_version_number+1    /* increment record_version_number */
        where
            budget_version_id=p_budget_version_id;
      -- CALL PA_FIN_PLAN_PVT.Submit_Current_Working_FinPlan for non ORG_FORECAST
      else
        PA_FIN_PLAN_PVT.Submit_Current_Working_FinPlan
            (p_project_id             => p_project_id,
             p_budget_version_id      => p_budget_version_id,
             p_record_version_number  => p_record_version_number,
             x_return_status          => l_return_status,
             x_msg_count              => l_msg_count,
             x_msg_data               => l_msg_data);
        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          -- PA_FIN_PLAN_PVT.Submit_Current_Working_FinPlan RETURNED ERRORS
          rollback to PA_FIN_PLAN_PUB_SUBMIT_WORKING;
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
          pa_debug.reset_err_stack;
          return;
        end if;
      end if; -- l_fin_plan_type_code

    end if;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.reset_err_stack;

exception
    when pa_fin_plan_pub.rollback_on_error then
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('Submit_Current_Working: ' || 'Procedure Submit_working: rollback_on_error exception');
      END IF;
      rollback to PA_FIN_PLAN_PUB_SUBMIT_WORKING;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    when others then
      rollback to PA_FIN_PLAN_PUB_SUBMIT_WORKING;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_PUB',
                               p_procedure_name   => 'Submit_Current_Working');
      pa_debug.reset_err_stack;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
end Submit_Current_Working;
/* ------------------------------------------------------------------------- */

-- ** BUG FIX 2615778: orig budget version id, record version numbers can be null **
--    BUG FIX 2733848: check resource_list_id to see it matches with baselined versions
-- FP M -- Resource list is changeable even if baselined version exists. Versions can
-- be set as CW, even if the resource list of the version that is being made CW doesnt
-- match the resource list of the baselined version.
procedure Set_Current_Working
    (p_project_id                   IN     pa_budget_versions.project_id%TYPE,
     p_budget_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number        IN     pa_budget_versions.record_version_number%TYPE,
     p_orig_budget_version_id       IN     pa_budget_versions.budget_version_id%TYPE,
     p_orig_record_version_number   IN     pa_budget_versions.record_version_number%TYPE,
     x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
l_debug_mode      VARCHAR2(30);
l_valid1_flag     VARCHAR2(1);
l_valid2_flag     VARCHAR2(1);
l_budget_status_code    pa_budget_versions.budget_status_code%TYPE;
l_cur_work_bv_id        pa_budget_versions.budget_version_id%TYPE;
l_fin_plan_type_id      pa_budget_versions.fin_plan_type_id%TYPE;
l_version_type          pa_budget_versions.version_type%TYPE;
l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_return_status   VARCHAR2(2000);
l_error_msg_code  VARCHAR2(30);
l_msg_index_out   NUMBER;
l_attributes_same_flag VARCHAR2(1);
l_exists          VARCHAR2(1);

-- for BUG FIX 2733848
l_resource_list_id     pa_budget_versions.resource_list_id%TYPE;

begin
    FND_MSG_PUB.initialize;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PA_FIN_PLAN_PUB.Set_Current_Working');
    END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Set_Current_Working: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
/* CHECK FOR BUSINESS RULES VIOLATIONS */
    /* check for null budget_version_id */
    if p_budget_version_id is NULL then
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Set_Current_Working: ' || 'no budget version id entered');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_NO_PLAN_VERSION');
    end if;
    /* check to see if the budget version we're setting to be current working has */
    /* been updated by someone else already */
    PA_FIN_PLAN_UTILS.Check_Record_Version_Number
            (p_unique_index             => p_budget_version_id,
             p_record_version_number    => p_record_version_number,
             x_valid_flag               => l_valid1_flag,
             x_return_status            => l_return_status,
             x_error_msg_code           => l_error_msg_code);
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('Set_Current_Working: ' || 'record version check #1: return status is ' || l_valid1_flag);
    END IF;
    /* check to see if the old current working budget version has been updated */
    /* by someone else already */
    /* BUT, need to check if there was an old current working version */
    if p_orig_budget_version_id is not null then
      PA_FIN_PLAN_UTILS.Check_Record_Version_Number
              (p_unique_index             => p_orig_budget_version_id,
               p_record_version_number    => p_orig_record_version_number,
               x_valid_flag               => l_valid2_flag,
               x_return_status            => x_return_status,
               x_error_msg_code           => l_error_msg_code);
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('Set_Current_Working: ' || 'record version check #2: return status is ' || l_valid2_flag);
      END IF;
      if (not ((l_valid1_flag = 'Y')and (l_valid2_flag='Y'))) then
          PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                               p_msg_name            => l_error_msg_code);
      end if;
      /* check to see if the old current working budget version has been submitted */
      select
         budget_status_code
        ,fin_plan_type_id
        ,version_type
      into
          l_budget_status_code
         ,l_fin_plan_type_id
         ,l_version_type
      from
          pa_budget_versions
      where
          budget_version_id=p_orig_budget_version_id;
      if (l_budget_status_code='S') and (p_budget_version_id <> p_orig_budget_version_id) then
          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                               p_msg_name            => 'PA_FP_VERSION_SUBMITTED_ERR');
      end if;
    end if; -- p_orig_budget_version_id is not null


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

    /* Fix for bug 2651851:
       When the user tries to set a new approved budget plan version to be the current
       working version, a check must be made to see the new plan version has the same
       time phase, planning level, and resource list as the existing current working
       plan version:

       If it does, the new version will successfully be set to be the current working
       version.

       If it does not, and submitted or approved but unimplemented financial impact
       change orders do not exist, the new version will successfully be set to be the
       current working version.

       If it does not, and submitted or approved but unimplemented financial impact
       change orders do exist, an error message will be displayed */

       BEGIN
         Select budget_version_id
           into l_cur_work_bv_id
         from pa_budget_versions bv
        where bv.project_id       = p_project_id
          and bv.fin_plan_type_id = l_fin_plan_type_id
          and bv.version_type     = l_version_type
          and bv.current_working_flag = 'Y'
          and bv.ci_id            IS NULL
          and ((DECODE(bv.version_type,'COST',bv.approved_cost_plan_type_flag,
                                    'REVENUE',bv.approved_rev_plan_type_flag,
                                    'N') = 'Y')
              OR
             (bv.approved_cost_plan_type_flag = 'Y' and
              bv.approved_rev_plan_type_flag  = 'Y')) ;
       EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  l_cur_work_bv_id := -9999;
       END;

       IF p_orig_budget_version_id = l_cur_work_bv_id THEN
          /* The original current working budget is of approved plan type so additional checks */
             Pa_Fp_Control_Items_Utils.Compare_Source_Target_Ver_Attr
                ( p_source_bv_id         => p_orig_budget_version_id
                 ,p_target_bv_id         => p_budget_version_id
                 ,x_attributes_same_flag => l_attributes_same_flag
                 ,x_return_status        => l_return_status
                 ,x_msg_count            => l_msg_count
                 ,x_msg_data             => l_msg_data);

             IF l_attributes_same_flag = 'N' THEN
                BEGIN
                /*
                select 'Y'
                  into l_exists
                  from dual
                 where exists (select 'x'
                                 from pa_budget_versions bv
                                     ,pa_control_items   ci
                                     ,pa_ci_impacts      cp
                                     --For bug 3550073
                                     ,pa_ci_statuses_v   pcs
                                     ,pa_pt_co_impl_statuses pcis
                                where bv.project_id                    = p_project_id
                                  and bv.fin_plan_type_id              = l_fin_plan_type_id
                                  and bv.version_type                  = l_version_type
                                  and ci.ci_id                         = bv.ci_id
                                  and pcs.ci_type_id                   = ci.ci_type_id
                                  and pcs.project_status_code          = ci.status_code
                                  and pcs.project_system_status_code   IN ('CI_APPROVED','CI_SUBMITTED')
                                  and cp.ci_id                         = ci.ci_id
                                  and cp.impact_type_code              <> 'FINPLAN'
                                  and cp.impact_type_code              =  DECODE(bv.version_type,
                                                                                'COST','FINPLAN_COST',
                                                                                'REVENUE','FINPLAN_REVENUE',
                                                                                cp.impact_type_code)
                                  and cp.status_code                   = 'CI_IMPACT_PENDING'
                                  and pcis.fin_plan_type_id            = bv.fin_plan_type_id
                                  and pcis.ci_type_id                  = ci.ci_type_id
                                  and pcis.version_type                = bv.version_type
                                  and pcis.status_code                 = pcs.project_status_code);
                */
                -- Bug 3828512 changed the validation to look for eligible change
                -- documents against the target current working version. If any
                -- that are not already included in baseline version, throw an
                -- error as such change documents can not be included in the target
                -- current working version. We ignore change documents that are part
                -- of baseline versions for the reason that we just mark them as copied
                -- and not actually merged

                select 'Y'
                  into l_exists
                  from dual
                 where exists
                     (select 'x'
                       from pa_fp_eligible_ci_v eligible
                      where eligible.project_id = p_project_id
                        and eligible.fin_plan_type_id = l_fin_plan_type_id
                        and eligible.ci_version_type = l_version_type
                        and eligible.project_system_status_code IN ('CI_APPROVED','CI_SUBMITTED')
                        -- filter cis that are already part of target cur working version
                        and eligible.ci_id not in (select merged.ci_id
                                                     from pa_fp_merged_ctrl_items merged
                                                    where merged.plan_version_id = p_budget_version_id
                                                      and merged.project_id = p_project_id
                                                  )
                        -- filter cis included in current baseline version
                        and eligible.ci_id not in (select merged.ci_id
                                                     from pa_fp_merged_ctrl_items merged,
                                                          pa_budget_versions cur_baseline
                                                    where cur_baseline.project_id = p_project_id
                                                      and cur_baseline.fin_plan_type_id = l_fin_plan_type_id
                                                      and cur_baseline.version_type = l_version_type
                                                      and cur_baseline.budget_status_code = 'B'
                                                      and cur_baseline.current_flag = 'Y'
                                                      and merged.plan_version_id = cur_baseline.budget_version_id
                                                      and merged.project_id = cur_baseline.project_id));
                EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                               l_exists := 'N';
                END;
             END IF; -- l_attributes_same_flag = 'N'

             IF l_exists = 'Y' THEN
                pa_utils.add_message
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_SET_CURNT_WORK_NOT_ALLWD');
                fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                           p_data  => x_msg_data);
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
             END IF; -- l_exists = 'Y'
       END IF; -- Approved budget plan version

   /* Ssarma: Enhancement for Control items when the plan type is approved budget.

      Business Rule: Only approved ci's can be included in approved budget versions.

      1. The new current working version gets all the ci_links from the latest baselined
         budget version.
      2. The ci's linked to old current working and not present in the
         new current working are made un-implemented. These are the ones
         that have been implemented after the latest baselined version.
      3. The ci's linked with the new current working and not implemented are
         set to implemented.
   */

   pa_fin_plan_pvt.handle_ci_links(
      p_source_bv_id  => p_orig_budget_version_id  -- Old Current Working Version
     ,p_target_bv_id  => p_budget_version_id       -- New Current Working Version
     ,x_return_status => l_return_status
     ,x_msg_count     => l_msg_count
     ,x_msg_data      => l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
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
      END IF;

/* If There are NO Business Rules Violations , Then proceed with Set Current Working */
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('Set_Current_Working: ' || 'no business rules violations: beginning Set Current Working');
    END IF;
    if l_msg_count = 0 then
        SAVEPOINT PA_FIN_PLAN_PUB_SET_WORKING;
            /* remove the CURRENT_WORKING status from the old current working version */
            /* ONLY if there is an old current working version */
            if p_orig_budget_version_id is not null then
                update
                    pa_budget_versions
                set
                    last_update_date=SYSDATE,
                    last_updated_by=FND_GLOBAL.user_id,
                    last_update_login=FND_GLOBAL.login_id,
                    current_working_flag='N',
                    record_version_number=record_version_number+1    /* increment record_version_number */
                where
                    budget_version_id=p_orig_budget_version_id;
            end if;
            /* crown the CURRENT_WORKING status to the new current working version */
            update
                pa_budget_versions
            set
                last_update_date=SYSDATE,
                last_updated_by=FND_GLOBAL.user_id,
                last_update_login=FND_GLOBAL.login_id,
                current_working_flag='Y',
                record_version_number=record_version_number+1    /* increment record_version_number */
            where
                budget_version_id=p_budget_version_id;
    end if;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.reset_err_stack;
exception
    when pa_fin_plan_pub.rollback_on_error then
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('Procedure Set_Current_Working: rollback_on_error exception');
      END IF;
      rollback to PA_FIN_PLAN_PUB_SET_WORKING;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    when others then
        rollback to PA_FIN_PLAN_PUB_SET_WORKING;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_PUB',
                               p_procedure_name   => 'Set_Current_Working');
        pa_debug.reset_err_stack;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
end Set_Current_Working;
/* ------------------------------------------------------------------------- */

procedure Rework_Submitted
    (p_project_id                   IN     pa_budget_versions.project_id%TYPE,
     p_budget_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number        IN     pa_budget_versions.record_version_number%TYPE,
     x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
l_debug_mode      VARCHAR2(30);
l_valid_flag              VARCHAR2(1);
l_current_working_flag    pa_budget_versions.current_working_flag%TYPE;
l_budget_status_code      pa_budget_versions.budget_status_code%TYPE;

l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_error_msg_code  VARCHAR2(30);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);

begin
    FND_MSG_PUB.initialize;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PA_FIN_PLAN_PUB.Rework_Submitted');
    END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Rework_Submitted: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;

/* CHECK FOR BUSINESS RULES VIOLATIONS */
    /* check for null budget_version_id */
    if p_budget_version_id is NULL then
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_NO_PLAN_VERSION');
    end if;
    /* check to see if the budget version we're updating is a SUBMITTED version; */
    /* only SUBMITTED versions can be reworked */
    select
        budget_status_code,
        current_working_flag
    into
        l_budget_status_code,
        l_current_working_flag
    from
        pa_budget_versions
    where
        budget_version_id = p_budget_version_id;
    if ((l_budget_status_code <> 'S') or (l_current_working_flag <> 'Y')) then
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Rework_Submitted: ' || 'version is not a submitted current working version');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_REWORK_SUBMITTED');
    end if;
    /* check to see if the budget version we're updating to be current working has */
    /* been updated by someone else already */
    PA_FIN_PLAN_UTILS.Check_Record_Version_Number
            (p_unique_index             => p_budget_version_id,
             p_record_version_number    => p_record_version_number,
             x_valid_flag               => l_valid_flag,
             x_return_status            => l_return_status,
             x_error_msg_code           => l_error_msg_code);
    if x_return_status = FND_API.G_RET_STS_ERROR then
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => l_error_msg_code);
    end if;

/* If There are ANY Busines Rules Violations , Then Do NOT Proceed: RETURN */
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

/* If There are NO Business Rules Violations , Then proceed with Rework Submitted */
    if l_msg_count = 0 then
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Rework_Submitted: ' || 'no business logic errors; proceeding with Rework Submitted');
        END IF;
        SAVEPOINT PA_FIN_PLAN_PUB_REWORK;
        /* set the BUDGET_STATUS_CODE from 'W' to 'S' */
        update
            pa_budget_versions
        set
            last_update_date=SYSDATE,
            last_updated_by=FND_GLOBAL.user_id,
            last_update_login=FND_GLOBAL.login_id,
            budget_status_code = 'W',
            record_version_number=record_version_number+1    /* increment record_version_number */
        where
            budget_version_id=p_budget_version_id;
    end if;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.reset_err_stack;

exception
    when pa_fin_plan_pub.rollback_on_error then
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('Procedure Rework_Submitted: rollback_on_error exception');
      END IF;
      rollback to PA_FIN_PLAN_PUB_REWORK;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    when others then
      rollback to PA_FIN_PLAN_PUB_REWORK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_PUB',
                               p_procedure_name   => 'Rework_Submitted');
      pa_debug.reset_err_stack;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
end Rework_Submitted;
/* ------------------------------------------------------------------------- */

procedure Mark_As_Original
    (p_project_id                   IN     pa_budget_versions.project_id%TYPE,
     p_budget_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number        IN     pa_budget_versions.record_version_number%TYPE,
     p_orig_budget_version_id       IN     pa_budget_versions.budget_version_id%TYPE,
     p_orig_record_version_number   IN     pa_budget_versions.record_version_number%TYPE,
     x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
l_debug_mode      VARCHAR2(30);
l_valid1_flag     VARCHAR2(1);
l_valid2_flag     VARCHAR2(1);
l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_return_status   VARCHAR2(2000);
l_error_msg_code  VARCHAR2(30);
l_msg_index_out   NUMBER;

begin
    FND_MSG_PUB.initialize;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PA_FIN_PLAN_PUB.Mark_As_Original');
    END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Mark_As_Original: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
/* CHECK FOR BUSINESS RULES VIOLATIONS */
    /* check for null budget_version_id */
    if p_budget_version_id is NULL then
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_NO_PLAN_VERSION');
    end if;
    /* check to see if the budget version we're setting to be original baselined has */
    /* been updated by someone else already */
    PA_FIN_PLAN_UTILS.Check_Record_Version_Number
            (p_unique_index             => p_budget_version_id,
             p_record_version_number    => p_record_version_number,
             x_valid_flag               => l_valid1_flag,
             x_return_status            => l_return_status,
             x_error_msg_code           => l_error_msg_code);
    /* check to see if the old original baselined budget version has been updated */
   /* by someone else already */

   /* Bug # 2639285 - Included the check for p_orig_budget_version_id is not null*/
   IF p_orig_budget_version_id IS NOT NULL THEN
   PA_FIN_PLAN_UTILS.Check_Record_Version_Number
            (p_unique_index             => p_orig_budget_version_id,
             p_record_version_number    => p_orig_record_version_number,
             x_valid_flag               => l_valid2_flag,
             x_return_status            => x_return_status,
             x_error_msg_code           => l_error_msg_code);
    if not((l_valid1_flag='Y') and (l_valid2_flag='Y')) then
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => l_error_msg_code);
    end if;
    END IF;

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

/* If There are NO Business Rules Violations , Then proceed with Mark As Original */
    if l_msg_count = 0 then
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Mark_As_Original: ' || 'no business violations; continuing with Mark As Original');
        END IF;
        SAVEPOINT PA_FIN_PLAN_PUB_MARK_ORIGINAL;
        /* remove the ORIGINAL status from the old original version */

    /* Bug # 2639285 - Included the update in case p_orig_budget_version_id is null */
    IF p_orig_budget_version_id is null THEN

        update pa_budget_versions a
        set    original_flag = 'Y',
        current_original_flag = 'N',
        last_update_date = SYSDATE,
        last_updated_by=FND_GLOBAL.user_id,
        last_update_login=FND_GLOBAL.login_id,
        record_version_number = record_version_number + 1
        where  (a.project_id,a.fin_plan_type_id,a.version_type) =
                (select b.project_id,b.fin_plan_type_id,b.version_type
                 from   pa_budget_versions b
                 where  b.budget_version_id = p_budget_version_id)
        and    a.budget_version_id <> p_budget_version_id
        and    current_original_flag = 'Y';
    ELSE
        update
            pa_budget_versions
        set
            last_update_date=SYSDATE,
            last_updated_by=FND_GLOBAL.user_id,
            last_update_login=FND_GLOBAL.login_id,
            original_flag = 'Y',
            current_original_flag='N',
            record_version_number = record_version_number + 1 /* increment record_version_number */
        where
            budget_version_id=p_orig_budget_version_id;
     END IF;
        /* crown the ORIGINAL status to the new original version */
        update
            pa_budget_versions
        set
            last_update_date=SYSDATE,
            last_updated_by=FND_GLOBAL.user_id,
            last_update_login=FND_GLOBAL.login_id,
            original_flag = 'Y',
            current_original_flag='Y',
            record_version_number = record_version_number + 1 /* increment record_version_number */
        where
            budget_version_id=p_budget_version_id;
    end if;

    /* FP M - Reporting lines integration */

    DECLARE
         l_budget_version_ids SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(p_budget_version_id);
    BEGIN
         pa_debug.write('Mark_As_Original','Calling PJI_FM_XBS_ACCUM_MAINT.PLAN_ORIGINAL ' ,5);
         pa_debug.write('Mark_As_Original','p_baseline_version_id  '|| p_budget_version_id,5);
         PJI_FM_XBS_ACCUM_MAINT.PLAN_ORIGINAL (
              p_original_version_id => p_budget_version_id,
              x_return_status       => l_return_status,
              x_msg_code            => l_error_msg_code);

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
              PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                   p_msg_name            => l_error_msg_code);

              RAISE pa_fin_plan_pub.rollback_on_error;
         END IF;

    END;


exception
    when pa_fin_plan_pub.rollback_on_error then
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('Procedure Mark_As_Original: rollback_on_error exception');
      END IF;
      rollback to PA_FIN_PLAN_PUB_MARK_ORIGINAL;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    when others then
        rollback to PA_FIN_PLAN_PUB_MARK_ORIGINAL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_PUB',
                                 p_procedure_name   => 'Mark_As_Original');
        pa_debug.reset_err_stack;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
end Mark_As_Original;
/* ------------------------------------------------------------------------- */


----------------------------------------------------------------------------------------
-- Delete_Version API -  Adding p_context IN parameter as part of FPM changes
-- The permissible values for p_context are ('BUDGET' and 'WORKPLAN'). This
-- parameter is added since this api shall be called also from wrokplan perspective
-- FPM onwards. This parameter is defaulted as 'BUGDET' is the spec. So existing calls
-- need not be modified
----------------------------------------------------------------------------------------
procedure Delete_Version
    (p_project_id                   IN     pa_budget_versions.project_id%TYPE,
     p_budget_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number        IN     pa_budget_versions.record_version_number%TYPE,
     p_context                      IN     VARCHAR2,
     x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
as
l_debug_mode      VARCHAR2(30);
l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_error_msg_code  VARCHAR2(30);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);

l_valid_flag            VARCHAR2(1);
l_budget_status_code    pa_budget_versions.budget_status_code%TYPE;
l_version_type          pa_budget_versions.version_type%TYPE;
l_current_working_flag  VARCHAR2(1);
l_fin_plan_type_id      pa_budget_versions.fin_plan_type_id%TYPE;
l_max_version           NUMBER;
l_cur_work_bv_id        pa_budget_versions.budget_version_id%TYPE;
l_exists                varchar2(1);
l_module_name           VARCHAR2(100):='PAFPPUBB.delete_version';
l_wp_fin_plan_type_id   pa_fin_plan_types_b.fin_plan_type_id%TYPE;
l_budget_version_id_tbl SYSTEM.PA_NUM_TBL_TYPE;

/* Bug 2688610 - Add the following two locals*/
l_baseline_funding_flag            pa_projects_all.baseline_funding_flag%TYPE;
l_approved_rev_plan_type_flag      pa_budget_versions.approved_rev_plan_type_flag%TYPE;

-- Bug 3354518 FP M Doosan Phase 1 changes
l_current_original_flag         pa_budget_versions.current_original_flag%TYPE;
l_current_flag          pa_budget_versions.original_flag%TYPE;

cursor l_resource_assignments_csr is
select unique
    resource_assignment_id
from
    pa_resource_assignments
where
    budget_version_id=p_budget_version_id;
l_resource_assignments_rec l_resource_assignments_csr%ROWTYPE;

begin
    FND_MSG_PUB.initialize;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PA_FIN_PLAN_PUB.Delete_Version');
    END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Delete_Version: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;

--------------------------------------------------------------------
-- Checking for ellgible values of p_context ('WORKPLAN' or 'BUDGET')
--------------------------------------------------------------------
    IF NOT ((p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET) OR
            (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN)) THEN
              IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='p_context value is invalid  -  p_context :' || p_context;
                      pa_debug.write('PA_FIN_PLAN_PUB.Delete_Version: ' || l_module_name,pa_debug.g_err_stage,5);
              END IF;
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

/* CHECK FOR BUSINESS RULES VIOLATIONS */
    /* check for null budget_version_id */
    if p_budget_version_id is NULL AND p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET then
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_NO_PLAN_VERSION');
    end if;

    IF p_context=PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN AND
       p_budget_version_id IS NULL AND
       p_project_id IS NULL THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'p_context '||p_context;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

           pa_debug.g_err_stage:= 'p_budget_version_id '||p_budget_version_id;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

           pa_debug.g_err_stage:= 'p_project_id '||p_project_id;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                           p_msg_name         => 'PA_FP_INV_PARAM_PASSED',
                           p_token1           => 'PROCEDURENAME',
                           p_value1           => l_module_name);
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;



----------------------------------------------------------------------
-- CHECK FOR BUSINESS RULES VIOLATIONS
-- only for BUDGET Context   -- BUSINESS RULES CHECK FOR BUDGET STARTS
----------------------------------------------------------------------
    IF ((p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET) AND (p_budget_version_id IS NOT NULL)) THEN
    /* check to see if the budget version we're updating to be current working has */
    /* been updated by someone else already */
    PA_FIN_PLAN_UTILS.Check_Record_Version_Number
            (p_unique_index             => p_budget_version_id,
             p_record_version_number    => p_record_version_number,
             x_valid_flag               => l_valid_flag,
             x_return_status            => l_return_status,
             x_error_msg_code           => l_error_msg_code);
    if x_return_status = FND_API.G_RET_STS_ERROR then
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => l_error_msg_code);
    end if;
    /* check to make sure that budget_status_code = 'W' */
    /* we can delete only working versions (cannot delete submitted, baselined) */
    select
        budget_status_code,
        current_working_flag,
        fin_plan_type_id,
        version_type,
        current_original_flag,     -- Bug 3354518 FP M
        current_flag       -- Bug 3354518 FP M
    into
        l_budget_status_code,
        l_current_working_flag,
        l_fin_plan_type_id,
        l_version_type,
        l_current_original_flag,    -- Bug 3354518 FP M
        l_current_flag      -- Bug 3354518 FP M
    from
        pa_budget_versions
    where
        budget_version_id = p_budget_version_id;

    if  l_budget_status_code <> 'W' then
        if l_budget_status_code = 'S' then
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('Delete_Version: ' || 'budget status code is S');
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                 p_msg_name            => 'PA_FP_DELETE_WORKING');
        elsif (l_budget_status_code = 'B' and           -- Bug 3354518 FP M
               (l_current_original_flag = 'Y' OR l_current_flag = 'Y')) then
               -- baseline versions marked as current or original can not be deleted
               x_return_status := FND_API.G_RET_STS_ERROR;
               PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                    p_msg_name            => 'PA_FP_DEL_CUR_OR_ORIG_BASELINE');

        end if;                                        -- Bug 3354518 FP M
    end if;

    /* Begin Fix for bug 2688610 : The control item validation needs to be by passed in
       case of autobaselined project and approved revenue plan version.
    */
    BEGIN
        select p.baseline_funding_flag, v.approved_rev_plan_type_flag
        into l_baseline_funding_flag, l_approved_rev_plan_type_flag
        from pa_projects_all p, pa_budget_versions v
        where p.project_id = v.project_id
        and v.budget_version_id = p_budget_version_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        pa_debug.write(l_module_name,'Error getting version details',3);
        RAISE;
    END;

    IF NOT (nvl(l_baseline_funding_flag,'N') = 'Y' AND
                nvl(l_approved_rev_plan_type_flag,'N') = 'Y') THEN


    /* Begin Fix for bug 2651851 : Once the financial impact of a change order exists,
                             the current working approved budget plan version
                             cannot be deleted. */

    BEGIN
    Select budget_version_id
           into l_cur_work_bv_id
         from pa_budget_versions bv
        where bv.project_id       = p_project_id
          and bv.fin_plan_type_id = l_fin_plan_type_id
          and bv.version_type     = l_version_type
          and bv.current_working_flag = 'Y'
          and bv.ci_id            IS NULL
          and ((DECODE(bv.version_type,'COST',bv.approved_cost_plan_type_flag,
                                    'REVENUE',bv.approved_rev_plan_type_flag,
                                    'N') = 'Y')
              OR
             (bv.approved_cost_plan_type_flag = 'Y' and
              bv.approved_rev_plan_type_flag  = 'Y')) ;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
              l_cur_work_bv_id := -9999;
    END;

    IF p_budget_version_id = l_cur_work_bv_id THEN
       /* The version to be deleted is also the current working approved budget plan
          version. Check to see if any financial impact of a change order exists for
          this project plan type combination and if so then return an error and do
          not delete the current working version (p_budget_version_id) */

          BEGIN

                SELECT 'Y'
                  INTO l_exists
                  FROM dual
                 WHERE EXISTS ( SELECT 'X' from pa_budget_versions pb,pa_control_items pci -- added pa_control_items pci for bug 3741051
                                 WHERE pb.project_id = p_project_id --added the alias name for bug 3741051
                                   AND pb.fin_plan_type_id = l_fin_plan_type_id -- added the alias name for bug 3741051
                                   AND pb.version_type = l_version_type -- added the alias name for bug 3741051
           AND pb.project_id = pci.project_id -- added for bug 3741051
           AND pb.ci_id = pci.ci_id -- added for bug 3741051
           AND pci.status_code <> 'CI_CANCELED'-- added for bug 3741051
            );
          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    l_exists := 'N';
          END;

        IF l_exists = 'Y' THEN
           pa_utils.add_message
                        ( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_BV_CI_NO_DELETE');

                   fnd_msg_pub.count_and_get (p_count => x_msg_count,
                                              p_data  => x_msg_data);
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   return;
        END IF; -- l_exists = 'Y'
    END IF; -- p_budget_version_id = l_cur_work_bv_id

    /* End   Fix for bug 2651851 : Once the financial impact of a change order exists,
                             the current working approved budget plan version
                             cannot be deleted. */
    END IF;
    /* End Fix for bug 2688610 : The control item validation needs to be by passed in
       case of autobaselined project and approved revenue plan version.
    */

END IF;
--------------------------------------------------------------------------------
-- End of check for p_context = 'BUDGET' -- BUSINESS RULES CHECK FOR BUDGET ENDS
--------------------------------------------------------------------------------
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


/* If There are NO Business Rules Violations , Then proceed with Delete Version */
    if l_msg_count = 0 then
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Delete_Version: ' || 'no business errors: continuing with Delete Version');
        END IF;
        SAVEPOINT PA_FIN_PLAN_PUB_DELETE;
        IF p_context=PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN THEN

            BEGIN
                SELECT fin_plan_type_id
                INTO   l_wp_fin_plan_type_id
                FROM   pa_fin_plan_types_b
                WHERE  use_for_workplan_flag='Y';
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:= 'Workplan plan type does not exist';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;
                RETURN;
            END;

        ELSE

            l_wp_fin_plan_type_id:=NULL;

        END IF;
        /* call Delete_Version_Helper to delete everything but the entry in PA_BUDGET_VERSIONS and PA_PROJ_FP_OPTIONS */
        pa_fin_plan_pub.Delete_Version_Helper
            (p_project_id           => p_project_id,
             p_context              => p_context,
             p_budget_version_id    => p_budget_version_id,
             x_return_status        => l_return_status,
             x_msg_count            => l_msg_count,
             x_msg_data             => l_msg_data);
        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            raise pa_fin_plan_pub.rollback_on_error;
        end if;

        /* PA_PROJ_FIN_PLAN_OPTIONS: delete row (keyed on fin_plan_version_id) */

        -- Made changes for sql id
        IF p_budget_version_id IS NOT NULL THEN

            delete
            from
                pa_proj_fp_options
            where
                fin_plan_version_id= p_budget_version_id AND
                project_id=nvl(p_project_id,project_id) AND
                fin_plan_type_id = nvl(l_wp_fin_plan_type_id,fin_plan_type_id);

        ELSIF p_project_id IS NOT NULL THEN
            delete
            from
                pa_proj_fp_options
            where
            fin_plan_version_id=nvl(p_budget_version_id,fin_plan_version_id) AND
            project_id=p_project_id AND
            (fin_plan_type_id IS NULL OR
            fin_plan_type_id = nvl(l_wp_fin_plan_type_id,fin_plan_type_id));

        END IF;




        /* PA_BUDGET_VERSIONS delete row */
        /* Bug 4873352 - Split this delete based on i/p parameter null condition
         * to avoid FTS - Sql id : 14903057 */
        if p_budget_version_id is not null then
           /* Added for bug 8708651 */
           if PJI_PA_DEL_MAIN.g_from_conc is null then
             delete
             from
                 pa_budget_versions
             where
                 budget_version_id=p_budget_version_id AND
                 project_id=nvl(p_project_id,project_id) AND
                 fin_plan_type_id = nvl(l_wp_fin_plan_type_id,fin_plan_type_id)
             returning budget_version_id
             bulk collect into l_budget_version_id_tbl    ;

          else
            update PA_BUDGET_VERSIONS
            set PURGED_FLAG = 'Y',
                last_update_date = sysdate,
                last_updated_by = FND_GLOBAL.USER_ID,
                request_id = FND_GLOBAL.CONC_REQUEST_ID /* Added for bug 9049425 */
            WHERE budget_version_id=p_budget_version_id
            returning budget_version_id
            bulk collect into l_budget_version_id_tbl;

          end if;
          /* Added for bug 8708651 */

        elsif p_project_id is not null then
             delete
             from
                 pa_budget_versions
             where
                 budget_version_id=nvl(p_budget_version_id,budget_version_id) AND
                 project_id=p_project_id AND
                 fin_plan_type_id = nvl(l_wp_fin_plan_type_id,fin_plan_type_id)
             returning budget_version_id
             bulk collect into l_budget_version_id_tbl    ;
        else
        /* For budget context, bv id cannot be null;
         * For wp context, combination of project id and bv id cannot be null;
         * Given this, this else part would never get executed. Including for
         * future cases, in case this logic changes or addtl parameters are included.
         */
             delete
             from
                 pa_budget_versions
             where
                 budget_version_id=nvl(p_budget_version_id,budget_version_id) AND
                 project_id=nvl(p_project_id,project_id) AND
                 fin_plan_type_id = nvl(l_wp_fin_plan_type_id,fin_plan_type_id)
             returning budget_version_id
             bulk collect into l_budget_version_id_tbl    ;
        end if;

----------------------------------------------------------------------
-- CHECK FOR CURRENT WORKING VERSIONS
-- only for BUDGET Context   -- CHECK FOR CURRENT WORKING VERSIONS STARTS
----------------------------------------------------------------------
    IF p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET THEN

        /* if the deleted version was the current working version, need to find a replacement */
        if l_current_working_flag='Y' then
            /* find next most recent version */
            select
                nvl(max(version_number), 0)
            into
                l_max_version
            from
                pa_budget_versions
            where
                project_id = p_project_id and
                fin_plan_type_id = l_fin_plan_type_id and
                budget_status_code = 'W' and
                version_type = l_version_type and
/* BUG FIX 2638356: do not accidentally select Control Items */
                ci_id is null;

            /* make it the Current Working version */
            if (l_max_version <> 0) then
                update
                    pa_budget_versions
                set
                    current_working_flag = 'Y',
                    last_update_date=SYSDATE,
                    last_updated_by=FND_GLOBAL.user_id,
                    last_update_login=FND_GLOBAL.login_id,
                    record_version_number=record_version_number+1
                where
                    project_id = p_project_id and
                    fin_plan_type_id = l_fin_plan_type_id and
                    budget_status_code = 'W' and
                    version_type       = l_version_type and
                    version_number = l_max_version;
            end if;
        end if;

    END IF;
----------------------------------------------------------------------
-- CHECK FOR CURRENT WORKING VERSIONS
-- only for BUDGET Context   -- CHECK FOR CURRENT WORKING VERSIONS ENDS
----------------------------------------------------------------------
        -- Delete attachements which are associated with the budget version
    fnd_attached_documents2_pkg.delete_attachments
               (X_entity_name             => 'PA_BUDGET_VERSIONS',
                X_pk1_value               => to_char(p_budget_version_id),
                X_delete_document_flag    => 'Y');

    /* FP M - Reporting lines integration */

    BEGIN
         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write(l_module_name,'Calling PJI_FM_XBS_ACCUM_MAINT.PLAN_DELETE ' ,5);
             pa_debug.write(l_module_name,'p_fp_version_ids  count '|| l_budget_version_id_tbl.count,5);
         END IF;
         /* Very sure that there is only one record in the plsql table. Just having the loop  */
         FOR I in 1..l_budget_version_id_tbl.count LOOP
              pa_debug.write(l_module_name,'p_fp_version_ids   ('|| i || ')' || l_budget_version_id_tbl(i),5);
         END LOOP;
         IF l_budget_version_id_tbl.COUNT>0 THEN
             PJI_FM_XBS_ACCUM_MAINT.PLAN_DELETE (
                  p_fp_version_ids   => l_budget_version_id_tbl,
                  x_return_status    => l_return_status,
                  x_msg_code         => l_error_msg_code);

             IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                       p_msg_name            => l_error_msg_code);

                  RAISE pa_fin_plan_pub.rollback_on_error;
             END IF;
        END IF;

    END;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.reset_err_stack;
end if;

exception

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

    when pa_fin_plan_pub.rollback_on_error then
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('Procedure Delete_Version: rollback_on_error exception');
      END IF;
      rollback to PA_FIN_PLAN_PUB_DELETE;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    when others then
        rollback to PA_FIN_PLAN_PUB_DELETE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_PUB',
                                 p_procedure_name   => 'Delete_Version');
        pa_debug.reset_err_stack;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
end Delete_Version;
/* ------------------------------------------------------------------------- */

--p_context can be PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET or PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN.
--p_budget_version_id is mandatory whenever p_context is PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET.
--When PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN, data for the version will be deleted when p_budget_version_id
--is passed. Otherwise when p_project_id is passed data for the entire project will be deleted.
procedure Delete_Version_Helper
    (p_project_id                   IN     pa_projects_all.project_id%TYPE ,
     p_context                      IN     VARCHAR2 ,
     p_budget_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
     x_return_status                OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                     OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
l_debug_mode      VARCHAR2(30);
l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);

l_valid_flag            VARCHAR2(1);
l_budget_status_code    pa_budget_versions.budget_status_code%TYPE;
l_max_version           NUMBER;

l_project_id             pa_budget_versions.project_id%TYPE;
l_ci_id                  pa_budget_versions.ci_id%TYPE;
l_budget_version_id_tbl  pa_plsql_datatypes.idTabTyp;
l_proj_fp_options_id_tbl pa_plsql_datatypes.idTabTyp;
l_module_name            VARCHAR2(100):='PAFPPUBB.Delete_Version_Helper';
i                        NUMBER;
l_wp_fin_plan_type_id    pa_fin_plan_types_b.fin_plan_type_id%TYPE;

  -- IPM Arch Enhancement - Bug 4865563
   l_fp_cols_rec                   PA_FP_GEN_AMOUNT_UTILS.FP_COLS;  --This variable will be used to call pa_resource_asgn_curr maintenance api
   l_debug_level5                  NUMBER:=5;

-- start of changes for bug 2779637
/*
cursor l_resource_assignments_csr is
select unique
    resource_assignment_id
from
    pa_resource_assignments
where
    budget_version_id=p_budget_version_id;
l_resource_assignments_rec l_resource_assignments_csr%ROWTYPE;
*/


-- end of changes bug 2779637
begin
    /*=================================================================
    BUG NO:- 2331201 for fin plan these two lines  have been modified
    =================================================================*/
    --FND_MSG_PUB.initialize;
    --pa_debug.init_err_stack('PA_FIN_PLAN_PUB.Delete_Version_Helper');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.set_err_stack('PA_FIN_PLAN_PUB.Delete_Version_Helper');

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Delete_Version: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
/* CHECK FOR BUSINESS RULES VIOLATIONS */
    /* check for null budget_version_id */
    IF NOT ((p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET) OR
            (p_context = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN)) THEN
              IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:='p_context value is invalid  -  p_context :' || p_context;
                      pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
              END IF;
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                   p_token1         => 'PROCEDURENAME',
                                   p_value1         => l_module_name);
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    if p_budget_version_id is NULL AND p_context=PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET then
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_NO_PLAN_VERSION');
    end if;

    IF p_context=PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN AND
       p_budget_version_id IS NULL AND
       p_project_id IS NULL THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'p_context '||p_context;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

           pa_debug.g_err_stage:= 'p_budget_version_id '||p_budget_version_id;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

           pa_debug.g_err_stage:= 'p_project_id '||p_project_id;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                           p_msg_name         => 'PA_FP_INV_PARAM_PASSED',
                           p_token1           => 'PROCEDURENAME',
                           p_value1           => l_module_name);
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
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

/* If There are NO Business Rules Violations , Then proceed with Delete Version Helper*/
    if l_msg_count = 0 then
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Delete_Version: ' || 'no business errors: continuing with Delete Version Helper');
        END IF;
        SAVEPOINT PA_FIN_PLAN_PUB_DELETE_H;
        IF p_context=PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN THEN

            BEGIN
                SELECT fin_plan_type_id
                INTO   l_wp_fin_plan_type_id
                FROM   pa_fin_plan_types_b
                WHERE  use_for_workplan_flag='Y';
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:= 'Workplan plan type does not exist';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;
                RETURN;
            END;

        ELSE

            l_wp_fin_plan_type_id:=NULL;

        END IF;

        -- The budget version ids and option ids fetched with this SELECT
        -- will be used in deleting from other tables. The DMLs when executed with these IDs will use the indexes
        --improve the performence
        IF p_budget_version_id IS NOT NULL THEN

            SELECT proj_fp_options_id,
                   fin_plan_version_id
            BULK COLLECT INTO
                   l_proj_fp_options_id_tbl,
                   l_budget_Version_id_tbl
            FROM   pa_proj_fp_options
            WHERE  fin_plan_version_id=p_budget_version_id
            AND    fin_plan_type_id = nvl(l_wp_fin_plan_type_id,fin_plan_type_id);

        ELSE

            SELECT proj_fp_options_id,
                   fin_plan_version_id
            BULK COLLECT INTO
                   l_proj_fp_options_id_tbl,
                   l_budget_Version_id_tbl
            FROM   pa_proj_fp_options
            WHERE  project_id=p_project_id
            AND    (fin_plan_type_id = nvl(l_wp_fin_plan_type_id,fin_plan_type_id) OR
                   fin_plan_type_id IS NULL);

        END IF;

        IF p_context=PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET THEN

            FORALL i IN 1..l_budget_Version_id_tbl.COUNT

                /* PA_FIN_PLAN_ADJ_LINES: delete row (keyed on budget_version_id) */
                delete
                from
                    pa_fin_plan_adj_lines
                where
                    budget_version_id=l_budget_Version_id_tbl(i);

        END IF;

        IF p_context=PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET THEN

            FORALL i IN 1..l_budget_Version_id_tbl.COUNT

                /* PA_FP_ADJ_ELEMENTS: delete row (keyed on budget_version_id) */
                delete
                from
                    pa_fp_adj_elements
                where
                    budget_version_id=l_budget_Version_id_tbl(i);

        END IF;

        IF p_context=PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET THEN

            FORALL i IN 1..l_budget_Version_id_tbl.COUNT

                /* PA_ORG_FORECAST_LINES: delete row (keyed on budget_version_id as of 2/20/2002) */
                delete
                from
                    pa_org_forecast_lines
                where
                    budget_version_id = l_budget_Version_id_tbl(i);

        END IF;

        IF p_context=PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET THEN
            FORALL i IN 1..l_budget_Version_id_tbl.COUNT
                /* PA_ORG_FORECAST_ELEMENTS: delete row (keyed on budget_version_id) */
                delete
                from
                    pa_org_fcst_elements
                where
                    budget_version_id=l_budget_Version_id_tbl(i);
        END IF;

        ----  start of changes for bug 2779637 ----
        /* for performance its better to use budget_version_id for the deletion of budget lines*/

        /*
        -- PA_BUDGET_LINES: delete row (keyed on PA_RESOURCE_ASSIGNMENTS.resource_assignment_id)
        open l_resource_assignments_csr;
        loop
            fetch l_resource_assignments_csr into l_resource_assignments_rec;
            exit when l_resource_assignments_csr%NOTFOUND;
            delete
            from
                pa_budget_lines
            where
                resource_assignment_id=l_resource_assignments_rec.resource_assignment_id;
        end loop;
        close l_resource_assignments_csr;
        */
        FORALL i IN 1..l_budget_Version_id_tbl.COUNT
            delete
            from
                pa_budget_lines
            where
                budget_version_id=l_budget_Version_id_tbl(i);
         ----   end  of changes for bug 2779637  ----

        FORALL i IN 1..l_budget_Version_id_tbl.COUNT
            /* PA_RESOURCE_ASSIGNMENTS: delete row (keyed on budget_version_id) */
            delete
            from
                pa_resource_assignments
            where
                budget_version_id=l_budget_Version_id_tbl(i);
        -- Bug Fix: 4569365. Removed MRC code.
        /*
        FORALL i IN 1..l_budget_Version_id_tbl.COUNT
            -- FPB2: MRC : PA_MC_BUDGET_LINES: delete row (keyed on budget_Version_id)
            delete
            from
                pa_mc_budget_lines
            where
                budget_version_id = l_budget_Version_id_tbl(i);
        */
        FORALL i IN 1..l_proj_fp_options_id_tbl.COUNT
            delete
            from
               pa_fp_txn_currencies
            where
               proj_fp_options_id = l_proj_fp_options_id_tbl(i); -- bug 2779637

        --IPM Arch Enhancement Bug 4865563 Start
           FOR i IN 1..l_budget_Version_id_tbl.COUNT LOOP
           if l_budget_Version_id_tbl(i) is not null then  --bug 5441949
               PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                   (P_BUDGET_VERSION_ID              => l_budget_Version_id_tbl(i),
                    X_FP_COLS_REC                    => l_fp_cols_rec,
                    X_RETURN_STATUS                  => l_return_status,
                    X_MSG_COUNT                      => l_msg_count,
                    X_MSG_DATA                       => l_msg_data);

                    IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                       IF P_PA_debug_mode = 'Y' THEN
                                       pa_debug.g_err_stage:= 'Error in PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DETAILS';
                                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                       END IF;
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

               pa_res_asg_currency_pub.maintain_data
               (p_fp_cols_rec        => l_fp_cols_rec,
                p_calling_module     => 'UPDATE_PLAN_TRANSACTION',
                p_delete_flag        => 'Y',
                p_version_level_flag => 'Y',
                x_return_status      => l_return_status,
                x_msg_data           => l_msg_count,
                x_msg_count          => l_msg_data);


                    IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                       IF P_PA_debug_mode = 'Y' THEN
                                       pa_debug.g_err_stage:= 'Error in PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA';
                                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                       END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;
                  end if;        --bug 5441949
           END LOOP;
           --IPM Architechture Enhancement Bug 4865563 - End

        /*================================================================
        End of changes for Bug:- 2331201
        =================================================================*/
        /*===================================================================
          Start of changes for Bug :- 2634900 , Control Item Changes On APIs
        ===================================================================*/
        IF p_context=PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET THEN
            BEGIN
               SELECT project_id,
                      ci_id
               INTO   l_project_id,
                      l_ci_id
               FROM   pa_budget_versions
               WHERE  budget_version_id = p_budget_version_id;
            EXCEPTION
               WHEN OTHERS THEN
                  pa_debug.g_err_stage:= 'Error while Fetching the data for '||p_budget_version_id;
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write('Delete_Version: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                  END IF;
                  RAISE;
            END;

            IF l_ci_id IS NULL THEN

                FORALL i IN 1..l_budget_Version_id_tbl.COUNT
                    DELETE FROM pa_fp_merged_ctrl_items
                    WHERE project_id = l_project_id
                    AND   plan_version_id = l_budget_Version_id_tbl(i);
            ELSE --(l_ci_id IS NOT NULL )

                FORALL i IN 1..l_budget_Version_id_tbl.COUNT
                    DELETE FROM pa_fp_merged_ctrl_items
                    WHERE project_id = l_project_id
                    AND   ci_plan_version_id = l_budget_Version_id_tbl(i);
            END IF;
        END IF;




        IF p_budget_version_id IS NOT NULL THEN
            -- Bug 3572548 Update all the budget versions that have the input budget version id
            -- gen source version id with null for that column as this is being deleted

            UPDATE pa_proj_fp_options
            SET   gen_src_cost_plan_version_id = DECODE(gen_src_cost_plan_version_id
                                             ,p_budget_version_id,NULL,gen_src_cost_plan_version_id)
                 ,gen_src_rev_plan_version_id = DECODE(gen_src_rev_plan_version_id
                                             ,p_budget_version_id,NULL,gen_src_rev_plan_version_id)
                 ,gen_src_all_plan_version_id = DECODE(gen_src_all_plan_version_id
                                             ,p_budget_version_id,NULL,gen_src_all_plan_version_id)
                 ,gen_src_cost_wp_version_id = DECODE(gen_src_cost_wp_version_id
                                             ,p_budget_version_id,NULL,gen_src_cost_wp_version_id)
                 ,gen_src_rev_wp_version_id = DECODE(gen_src_rev_wp_version_id
                                             ,p_budget_version_id,NULL,gen_src_rev_wp_version_id)
                 ,gen_src_all_wp_version_id = DECODE(gen_src_all_wp_version_id
                                             ,p_budget_version_id,NULL,gen_src_all_wp_version_id)
                 ,record_version_number       = record_version_number + 1
                 ,last_update_date            = SYSDATE
                 ,last_updated_by             = FND_GLOBAL.user_id
                 ,last_update_login           = FND_GLOBAL.login_id
            WHERE project_id = l_project_id
            AND   fin_plan_option_level_code = 'PLAN_VERSION'
            AND   (gen_src_cost_plan_version_id = p_budget_version_id OR
                   gen_src_rev_plan_version_id = p_budget_version_id OR
                   gen_src_all_plan_version_id = p_budget_version_id OR
                   gen_src_cost_wp_version_id  = p_budget_version_id OR
                   gen_src_rev_wp_version_id   = p_budget_version_id OR
                   gen_src_all_wp_version_id   = p_budget_version_id );
        END IF;
    end if;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.reset_err_stack;

exception
    when pa_fin_plan_pub.rollback_on_error then
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('Procedure Delete_Version_Helper: rollback_on_error exception');
      END IF;
      rollback to PA_FIN_PLAN_PUB_DELETE_H;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    when others then
        rollback to PA_FIN_PLAN_PUB_DELETE_H;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_PUB',
                                 p_procedure_name   => 'Delete_Version_Helper');
        pa_debug.reset_err_stack;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
end Delete_Version_Helper;

--Bug 4290043. This is a private API called by copy version. This will return variables to indicate whether to
--copy the actuals, missing rates and amounts
--All the Input parameters are mandator. No validations are done since this is a private and only called by copy
--version
PROCEDURE get_copy_paramters
(
      p_source_project_id               IN       pa_projects_all.project_id%TYPE,
      p_target_project_id               IN       pa_projects_all.project_id%TYPE,
      p_source_plan_class_code          IN       pa_fin_plan_types_b.plan_class_code%TYPE,
      p_target_plan_class_code          IN       pa_fin_plan_types_b.plan_class_code%TYPE,
      p_source_version_type             IN       pa_budget_versions.version_type%TYPE,
      p_target_version_type             IN       pa_budget_versions.version_type%TYPE,
      x_copy_actuals_flag               OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_derv_rates_missing_amts_flag    OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
l_debug_mode                               VARCHAR2(30);
l_module_name                              VARCHAR2(100);

BEGIN
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    l_module_name := 'PAFPPUBB.get_copy_paramters';

    -- Set curr function
    IF l_debug_mode = 'Y' THEN
        pa_debug.set_curr_function(
                    p_function   =>'PAFPPUBB.get_copy_paramters'
                   ,p_debug_mode => l_debug_mode );

        pa_debug.g_err_stage:='In get_copy_paramters';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='p_source_project_id '||p_source_project_id;
        pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='p_target_project_id '||p_target_project_id;
        pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='p_source_plan_class_code '||p_source_plan_class_code;
        pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='p_target_plan_class_code '||p_target_plan_class_code;
        pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='p_source_version_type '||p_source_version_type;
        pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='p_target_version_type '||p_target_version_type;
        pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

    END IF;

    x_copy_actuals_flag:='Y';
    x_derv_rates_missing_amts_flag:='N';

    IF p_source_project_id <> p_target_project_id OR
       p_source_plan_class_code <> p_target_plan_class_code OR
       p_source_version_type <>  p_target_version_type THEN

        x_copy_actuals_flag := 'N';

    END IF;

    IF (p_source_plan_class_code='FORECAST' AND p_target_plan_class_code = 'BUDGET') OR
        p_source_version_type <>  p_target_version_type THEN

        x_derv_rates_missing_amts_flag := 'Y';

    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.reset_curr_function;

        pa_debug.g_err_stage:='x_copy_actuals_flag '||x_copy_actuals_flag;
        pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='x_derv_rates_missing_amts_flag '||x_derv_rates_missing_amts_flag;
        pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage:='Exiting get_copy_paramters';
        pa_debug.write( l_module_name,pa_debug.g_err_stage,3);

    END IF;


END get_copy_paramters;

/*===============================================================================
  Bug No. 2331201
  This is an existing api, used in ORG FORECASTING, modified completely for
  Financial Planning. This api has been used to copy data from one version to
  another during create working copy and baselining a version. Now this api
  would also be used to copy budgets/finplans  and would be called from
  pa_fp_copy_from_pkg.copy_plan.Hence this api takes care of copying one verion to
  an already existing version also.

  Bug No. 2920954
  When p_copy_mode is B, pa_fp_elements and pa_resource_assignments will be copied
  to have only planning elements and ras with plan amounts. Calls to
  pa_fp_elements_pub.copy_elements and pa_fp_copy_from_pkg.create_res_tasks_maps
  modified to include new parameters.

  NOTE:- Do not populate px_target_version_id till the end of the program.



 r11.5 FP.M Developement ----------------------------------

 08-JAN-2004 jwhite        Bug 3362316

                           Extensively rewrote Copy_Version and referenced
                           procedures calls.

 05-JUL-2004 rravipat      Bug 3731925
                           When a working version is created as a copy of another
                           version, working version should inherit rbs from parent
                           plan type record.
 04-Nov-2006 nkumbi        IPM Codde Merge: Bug 5099353: Modified the api to do the rollup when
                           a Pre-IPM source version is copied to a IPM level target version, before
                           the Optional Upgrade process is run on the source version.
  ================================================================================*/

PROCEDURE Copy_Version
    (p_project_id               IN      pa_budget_versions.project_id%TYPE,
     p_source_version_id        IN      pa_budget_versions.budget_version_id%TYPE,
     p_copy_mode                IN      VARCHAR2,
     p_adj_percentage           IN      NUMBER DEFAULT 0,
     p_calling_module           IN      VARCHAR2 DEFAULT PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST,
     p_pji_rollup_required      IN      VARCHAR2 DEFAULT 'Y',  --Bug 4200168
     px_target_version_id       IN  OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_debug_mode      VARCHAR2(30);
l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_error_msg_code  VARCHAR2(30);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);

l_adj_percentage  NUMBER := NVL(p_adj_percentage,0);
        --Make adjustment percentage zero if passed as null

l_source_proj_fp_options_id pa_proj_fp_options.proj_fp_options_id%TYPE;
l_source_fp_preference_code pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_source_element_type       pa_fp_elements.element_type%TYPE;
l_source_profile_id         pa_budget_versions.period_profile_id%TYPE;
l_source_fin_plan_type_id   pa_proj_fp_options.fin_plan_type_id%TYPE;


l_target_proj_fp_options_id pa_proj_fp_options.proj_fp_options_id%TYPE;
l_target_fin_plan_type_id   pa_proj_fp_options.fin_plan_type_id%TYPE;
l_target_fp_preference_code pa_proj_fp_options.fin_plan_preference_code%TYPE;
l_plan_in_multi_curr_flag   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;

l_target_element_type       pa_fp_elements.element_type%TYPE;

l_budget_version_id         pa_budget_versions.budget_version_id%TYPE;
l_target_version_id         pa_budget_versions.budget_version_id%TYPE;
l_target_profile_id         pa_budget_versions.period_profile_id%TYPE;

l_project_id                pa_projects_all.project_id%TYPE;

  -- Bug 3362316, 08-JAN-2003: Local Vars for Populating Reporting Lines  --------------------------



  l_source_ver_id_tbl      SYSTEM.pa_num_tbl_type := system.pa_num_tbl_type();

  l_dest_ver_id_tbl        SYSTEM.pa_num_tbl_type := system.pa_num_tbl_type();

  l_source_ver_type_tbl  SYSTEM.pa_varchar2_30_tbl_type := system.pa_varchar2_30_tbl_type();

  l_dest_ver_type_tbl    SYSTEM.pa_varchar2_30_tbl_type := system.pa_varchar2_30_tbl_type();


  -- End, Bug 3362316, 08-JAN-2003: Local Vars for Populating Reporting Lines  --------------------------

    -- Local variables for 3156057

  l_target_appr_rev_plan_flag     pa_budget_versions.approved_rev_plan_type_flag%TYPE;
  l_source_appr_rev_plan_flag     pa_budget_versions.approved_rev_plan_type_flag%TYPE;
  l_source_plan_in_mc_flag        pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;
  l_source_ver_rbs_version_id     pa_proj_fp_options.rbs_version_id%TYPE;-- Bug 3731925
  l_target_pt_lvl_rbs_version_id  pa_proj_fp_options.rbs_version_id%TYPE;-- Bug 3731925

  --Declared for Bug 4290043
  l_source_plan_class_code        pa_fin_plan_types_b.plan_class_code%TYPE;
  l_target_plan_class_code        pa_fin_plan_types_b.plan_class_code%TYPE;
  l_copy_actuals_flag             VARCHAR2(1);
  l_derv_rates_missing_amts_flag  VARCHAR2(1);

  --IPM Architechture Enhancement Bug 4865563
     l_src_fp_cols_rec               PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
     l_fp_cols_rec                   PA_FP_GEN_AMOUNT_UTILS.FP_COLS;  --This variable will be used to call pa_resource_asgn_curr maintenance api
     l_src_version_type              VARCHAR2(15);
     l_target_version_type           VARCHAR2(15);
     l_ra_id_tbl                     SYSTEM.pa_num_tbl_type := system.pa_num_tbl_type();
     l_txn_currency_code_tbl         SYSTEM.pa_varchar2_15_tbl_type := system.pa_varchar2_15_tbl_type();
     l_txn_raw_cost_rate_ovd_tbl     SYSTEM.pa_num_tbl_type := system.pa_num_tbl_type();
     l_txn_burden_cost_rate_ovd_tbl  SYSTEM.pa_num_tbl_type := system.pa_num_tbl_type();
     l_txn_bill_rate_ovd_tbl         SYSTEM.pa_num_tbl_type := system.pa_num_tbl_type();
     l_debug_level5                  NUMBER:=5;

   /* Bug 5099353 Start */
     l_is_eligible_for_rollup        VARCHAR2(1);
     l_chk_tgt_ver_status            VARCHAR2(1);

     Cursor is_eligible_for_rollup(c_project_id                IN NUMBER,
                                   c_source_proj_fp_options_id IN NUMBER)  is
     Select 'Y' from dual
     where EXISTS(
       select 1
       from pa_budget_versions pbv
       where pbv.budget_version_id = p_source_version_id and pbv.prc_generated_flag='M')
     and NOT EXISTS(
       select 1
       from PA_FP_UPGRADE_AUDIT pua
       where pua.project_id = c_project_id
       and pua.proj_fp_options_id_rup = c_source_proj_fp_options_id
       and pua.upgraded_flag = 'Y');

     Cursor chk_tgt_ver_status is
     Select 'Y' from dual
     where exists (select 1 from pa_budget_versions pbv where pbv.budget_version_id = px_target_version_id and pbv.budget_Status_code = 'W' )
     and exists (select 1 from pa_budget_lines bl, pa_budget_versions pbv
                 where pbv.budget_version_id = px_target_version_id
                 and pbv.budget_version_id = bl.budget_version_id
                 and (bl.cost_rejection_code  IS NOT NULL
                      OR bl.revenue_rejection_code IS NOT NULL
                      OR bl.burden_rejection_code IS NOT NULL
                      OR bl.pfc_cur_conv_rejection_code IS NOT NULL
                      OR bl.pc_cur_conv_rejection_code IS NOT NULL)
                 );
   /* Bug 5099353 End */



BEGIN

    pa_debug.set_err_stack ('PA_FIN_PLAN_PUB.Copy_Version');
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Copy_Version: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for business rules violations

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Parameter Validation';
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    -- Check for null source_version_id

    IF p_source_version_id IS NULL THEN
        pa_debug.g_err_stage := 'Source_plan='||p_source_version_id;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_NO_PLAN_VERSION');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    SAVEPOINT PA_FIN_PLAN_PUB_COPY_VERSION;

    --Initialise l_budget_version_id.

    l_budget_version_id := px_target_version_id;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Source_plan='||p_source_version_id;
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage := 'Target_plan='||l_budget_version_id;
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Bug 4290043. Fire the SQLs to get the details of the source/target version ids.
    --Fetch proj fp options id for source version
    --Bug 4290043. Selected source plan class code

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Fetching the Source version details';
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    SELECT  pfo.proj_fp_options_id
           ,pfo.fin_plan_preference_code
           ,pfo.project_id
           ,pfo.fin_plan_type_id
           ,DECODE(pfo.fin_plan_preference_code,
                   PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,
                   PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY , PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE,
                   PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL),
           pfo.plan_in_multi_curr_flag,
           nvl(pfo.approved_rev_plan_type_flag,'N'),
           pfo.rbs_version_id,
           fin.plan_class_code
    INTO   l_source_proj_fp_options_id
           ,l_source_fp_preference_code
           ,l_project_id
           ,l_source_fin_plan_type_id
           ,l_source_element_type
           ,l_source_plan_in_mc_flag
           ,l_source_appr_rev_plan_flag
           ,l_source_ver_rbs_version_id -- Bug 3731925
           ,l_source_plan_class_code
    FROM   pa_proj_fp_options pfo,
           pa_fin_plan_types_b fin
    WHERE  pfo.fin_plan_version_id = p_source_version_id
    AND    fin.fin_plan_type_id=pfo.fin_plan_type_id;

    --Fetch proj fp options id for target version if its already existing.

    IF px_target_version_id IS NOT NULL THEN

       SELECT  pfo.proj_fp_options_id
              ,pfo.fin_plan_preference_code
              ,pfo.fin_plan_type_id
              ,DECODE(pfo.fin_plan_preference_code,
                   PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,
                   PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY , PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE,
                   PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL),
               nvl(pfo.approved_rev_plan_type_flag,'N'),
               fin.plan_class_code
       INTO   l_target_proj_fp_options_id
              ,l_target_fp_preference_code
              ,l_target_fin_plan_type_id
              ,l_target_element_type
              ,l_target_appr_rev_plan_flag
              ,l_target_plan_class_code
       FROM   pa_proj_fp_options pfo,
              pa_fin_plan_types_b fin
       WHERE  pfo.fin_plan_version_id = l_budget_version_id
       AND    pfo.fin_plan_type_id = fin.fin_plan_type_id;

    ELSE
       --Initialise l_target_element_type to 'BOTH'

       l_target_element_type := 'BOTH';
       l_target_proj_fp_options_id := NULL;
       l_target_fin_plan_type_id := l_source_fin_plan_type_id;
       l_target_fp_preference_code := l_source_fp_preference_code;
       l_target_plan_class_code :=  l_source_plan_class_code;

    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'l_source_proj_fp_options_id ='||l_source_proj_fp_options_id;
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage := 'l_source_fp_preference_code = '||l_source_fp_preference_code;
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage := 'l_source_project_id = '||l_project_id;
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage := 'l_source_fin_plan_type_id ='||l_source_fin_plan_type_id;
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage := 'l_source_element_type = '||l_source_element_type;
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;



    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'l_target_proj_fp_options_id ='||l_target_proj_fp_options_id;
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage := 'l_target_fp_preference_code = '||l_target_fp_preference_code;
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage := 'l_target_fin_plan_type_id = '||l_target_fin_plan_type_id;
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage := 'l_target_element_type ='||l_target_element_type;
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Call the API to decide on whether to copy actuals/rates or not. Bug 4290043
    get_copy_paramters
    (p_source_project_id             => l_project_id,
     p_target_project_id             => l_project_id,
     p_source_plan_class_code        => l_source_plan_class_code,
     p_target_plan_class_code        => l_target_plan_class_code,
     p_source_version_type           => l_source_fp_preference_code,
     p_target_version_type           => l_target_fp_preference_code,
     x_copy_actuals_flag             => l_copy_actuals_flag,
     x_derv_rates_missing_amts_flag  => l_derv_rates_missing_amts_flag);


    -- Calling copy_budget_version api.This api will update the budget version incase its
    -- already existing else it will create a new version.

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Copying budget version';
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Bug 4290043 .Added the parameters for copy actuals flag and copy missing amounts/rates fla
    PA_FP_COPY_FROM_PKG.Copy_Budget_Version(
                 p_source_project_id        =>  p_project_id
                 ,p_target_project_id       =>  p_project_id
                 ,p_source_version_id       =>  p_source_version_id
                 ,p_copy_mode               =>  p_copy_mode
                 ,p_adj_percentage          =>  l_adj_percentage
                 ,p_calling_module          =>  p_calling_module
                 ,p_copy_actuals_flag       =>  l_copy_actuals_flag
                 ,px_target_version_id      =>  l_budget_version_id
                 ,x_return_status           =>  l_return_status
                 ,x_msg_count               =>  l_msg_count
                 ,x_msg_data                =>  l_msg_data );

    -- Start of changes for BUG :- 2634900
    -- Copy the links from the links for the source plan version in the
    -- PA_FP_MERGED_CTRL_ITEMS table  to the target version.


    pa_fp_ci_merge.copy_merged_ctrl_items
           (  p_project_id            =>  p_project_id
             ,p_source_version_id     =>  p_source_version_id
             ,p_target_version_id     =>  l_budget_version_id
             ,x_return_status         =>  l_return_status
             ,x_msg_count             =>  l_msg_count
             ,x_msg_data              =>  l_msg_data );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- End of changes for BUG :- 2634900

    --Calling create fp option api to insert  or update pa_proj_fp_options.
    --In case of create working copy, it will insert into pa_proj_fp_options.
    --In case of target version is passed in copy plan, we update pa_proj_fp_options.


    --Calling create fp option api

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Calling create_fp_option api';
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    PA_PROJ_FP_OPTIONS_PUB.create_fp_option (
               px_target_proj_fp_option_id   =>  l_target_proj_fp_options_id
               ,p_source_proj_fp_option_id   =>  l_source_proj_fp_options_id
               ,p_target_fp_option_level_code => PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION
               ,p_target_fp_preference_code  =>  l_target_fp_preference_code
               ,p_target_fin_plan_version_id =>  l_budget_version_id --newly derived ot passed value
               ,p_target_project_id          =>  l_project_id        --project_id of source version
               ,p_target_plan_type_id        =>  l_target_fin_plan_type_id  --plan type id of target version
               ,x_return_status              =>  l_return_status
               ,x_msg_count                  =>  l_msg_count
               ,x_msg_data                   =>  l_msg_data );

    --Calling apis specific to FIN_PLAN

    --Calling api which inserts/updates elements into pa_fp_elements

    IF p_calling_module = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN THEN


          --Calling an api to copy transaction currencies selected in source version to target version
          --Fetch multi currency flag for the target/new budget.

          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage := 'Fetching multi currency flag for the target/new budget';
              pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          SELECT pfo.plan_in_multi_curr_flag
          INTO   l_plan_in_multi_curr_flag
          FROM   pa_proj_fp_options pfo
          WHERE  pfo.fin_plan_version_id = l_budget_version_id;

/*          IF l_plan_in_multi_curr_flag = 'Y' THEN     Commented for bug 2706430 */

                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := 'Calling copy_fp_txn_currencies api';
                    pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;

                PA_FP_TXN_CURRENCIES_PUB.copy_fp_txn_currencies (
                             p_source_fp_option_id   => l_source_proj_fp_options_id
                             ,p_target_fp_option_id  => l_target_proj_fp_options_id
                             ,p_target_fp_preference_code => NULL
                             ,p_plan_in_multi_curr_flag => l_plan_in_multi_curr_flag    --bug 2706430
                             ,x_return_status        => l_return_status
                             ,x_msg_count            => l_msg_count
                             ,x_msg_data             => l_msg_data );
/*          END IF;                Commented for bug 2706430   */
    END IF;

    --Calling copy_resource_assignments to insert records in pa_resource_assignments using
    --pa_fp_ra_map_tmp.


    --If the calling module is Financial Planning then its not required to go thru te route of
    --create_res_Task_maps as copy_resource_assignments would take care of the mapping logic too
    IF p_calling_module = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'Calling copy_resource_assignment';
            pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        PA_FP_COPY_FROM_PKG.copy_resource_assignments(
                         p_source_plan_version_id   => p_source_version_id
                         ,p_target_plan_version_id  => l_budget_version_id
                         ,p_adj_percentage          => l_adj_percentage
                         ,x_return_status           => l_return_status
                         ,x_msg_count               => l_msg_count
                         ,x_msg_data                => l_msg_data );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            pa_debug.g_err_stage := 'PA_FP_COPY_FROM_PKG.copy_resource_assignments returned error';
            pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;

        --Delete budget lines of target version if any then insert new rows for target
        --using source budget lines depending on adjustment percentage. If adjustment
        --percentage is non zero,amount columns aren't copied and also roll up records
        --aren't entered.

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'Calling copy_budget_lines';
            pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        /* 3156057: If source plan is mc enabled but not appr rev and the target is appr rev,
                      then copy copy_budget_lines_appr_rev will be called to group the source
                      budget lines by PFC for creating target budget lines */

        IF l_source_appr_rev_plan_flag = 'N' and l_source_plan_in_mc_flag = 'Y' and l_target_appr_rev_plan_flag = 'Y' THEN

               IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage:='Copying a mc enabled version into a appr rev plan type version.';
                    pa_debug.write('Copy_Plan: ' ||  l_module_name,pa_debug.g_err_stage,3);
               END IF;

            --Bug 4290043. Added  p_derv_rates_missing_amts_flag. Note that actuals will never be copied in this
            --case since the target is always Budget
            PA_FP_COPY_FROM_PKG.copy_budget_lines_appr_rev (
                          p_source_plan_version_id        => p_source_version_id
                          ,p_target_plan_version_id       => l_budget_version_id
                          ,p_adj_percentage               => l_adj_percentage
                          ,p_derv_rates_missing_amts_flag => l_derv_rates_missing_amts_flag
                          ,x_return_status                => l_return_status
                          ,x_msg_count                    => l_msg_count
                          ,x_msg_data                     => l_msg_data );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

        ELSE

            --Bug 4290043. Added p_copy_actuals_flag and p_derv_rates_missing_amts_flag
            PA_FP_COPY_FROM_PKG.copy_budget_lines (
                          p_source_plan_version_id          => p_source_version_id
                          ,p_target_plan_version_id         => l_budget_version_id
                          ,p_adj_percentage                 => l_adj_percentage
                          ,p_copy_actuals_flag              => l_copy_actuals_flag
                          ,p_derv_rates_missing_amts_flag   => l_derv_rates_missing_amts_flag
                          ,x_return_status                  => l_return_status
                          ,x_msg_count                      => l_msg_count
                          ,x_msg_data                       => l_msg_data );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                pa_debug.g_err_stage := 'PA_FP_COPY_FROM_PKG.copy_budget_lines returned error';
                pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;


        END IF; -- 3156057

    --In Org Forecasting Context, create res task maps should be called to create the mapping between source
    --and target resource assignments. After that resource assignments and budget lines should be copied.
    ELSIF p_calling_module = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST THEN

        --Calling create_res_task_maps api to generate new resource_assignment_ids
        --and store them in pa_fp_ra_map_tmp table


        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'Calling create_res_task_maps';
            pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        pa_fp_org_fcst_gen_pub.create_res_task_maps(
                p_source_project_id       => p_project_id
                ,p_target_project_id      => p_project_id
                ,p_source_plan_version_id => p_source_version_id
                ,p_adj_percentage         => l_adj_percentage
                ,p_copy_mode              => p_copy_mode      /* Bug 2920954 */
                ,p_calling_module         => p_calling_module /* Bug 2920954 */
                ,x_return_status          => l_return_status
                ,x_msg_count              => l_msg_count
                ,x_msg_data               => l_msg_data );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            pa_debug.g_err_stage := 'pa_fp_org_fcst_gen_pub.create_res_task_maps returned error';
            pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;


        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'Calling copy_resource_assignment';
            pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        pa_fp_org_fcst_gen_pub.copy_resource_assignments(
                         p_source_plan_version_id   => p_source_version_id
                         ,p_target_plan_version_id  => l_budget_version_id
                         ,p_adj_percentage          => l_adj_percentage
                         ,x_return_status           => l_return_status
                         ,x_msg_count               => l_msg_count
                         ,x_msg_data                => l_msg_data );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            pa_debug.g_err_stage := 'pa_fp_org_fcst_gen_pub.copy_resource_assignments returned error';
            pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;


        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'Calling copy_budget_lines';
            pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        pa_fp_org_fcst_gen_pub.copy_budget_lines (
                      p_source_plan_version_id   => p_source_version_id
                      ,p_target_plan_version_id  => l_budget_version_id
                      ,p_adj_percentage          => l_adj_percentage
                      ,x_return_status           => l_return_status
                      ,x_msg_count               => l_msg_count
                      ,x_msg_data                => l_msg_data );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            pa_debug.g_err_stage := 'pa_fp_org_fcst_gen_pub.copy_budget_lines returned error';
            pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        END IF;


    END IF;

    --Calling convert_txn_currency to complete pa_budget_lines by converting
    --txn currency'amounts into project projfunc amounts for finplan.

    --Bug 4290043. IF the target version can have missing amounts which will be derived during copyu
    --then the PC/PFC amounts should be rederived. Note that even if l_derv_rates_missing_amts_flag is Y,
    --only the rates will be derived(and not amounts) when l_source_fp_preference_code is same as
    --l_target_fp_preference_code and hence the MC api need not be called
    IF p_calling_module = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN
       AND (l_adj_percentage <> 0
         OR ( l_derv_rates_missing_amts_flag='Y' AND
              l_source_fp_preference_code <> l_target_fp_preference_code)) THEN

       /* 3156057 */

     IF l_source_appr_rev_plan_flag = 'N' and l_source_plan_in_mc_flag = 'Y' and l_target_appr_rev_plan_flag = 'Y' THEN

           IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:='Not calling convert_txn_currency since copying a mc enabled version into a appr rev plan type version.';
                pa_debug.write('Copy_Plan: ' ||  l_module_name,pa_debug.g_err_stage,3);
           END IF;

     ELSE

            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage := 'Calling convert_txn_currency';
                pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;

            PA_FP_MULTI_CURRENCY_PKG.convert_txn_currency (
                              p_budget_version_id   => l_budget_version_id
                              ,p_entire_version     => 'Y'
                              ,x_return_status      => l_return_status
                              ,x_msg_count          => l_msg_count
                              ,x_msg_data           => l_msg_data );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN /* Bug# 2644641 */
         raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
       END IF;
     END IF; -- 3156057
    END IF;

    -- Bug Fix: 4569365. Removed MRC code.
    /* FPB2: MRC - Needs to done only in case of FINPLAN */

    /*
    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Calling mrc api ........ ';
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF p_calling_module = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN THEN

       -- Nvl is handled because we donot want to overwrite calling_module set already ,eg., COPY_PROJECTS

       PA_MRC_FINPLAN.G_CALLING_MODULE := Nvl(PA_MRC_FINPLAN.G_CALLING_MODULE,PA_MRC_FINPLAN.G_COPY_VERSION);

       IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='before mrc api ........ MRC Calling module : ' || PA_MRC_FINPLAN.G_CALLING_MODULE;
           pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
              PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                        (x_return_status      => l_return_status,
                         x_msg_count          => l_msg_count,
                         x_msg_data           => l_msg_data);
       END IF;

       IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
          (PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' OR
           (PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'B' and p_copy_mode = 'B')) THEN

                --Bug 4290043. If amounts/rates are derived in the target version then MRC lines should not be copied
                --from source and they should be created by looking at budget lines of target
                IF nvl(l_adj_percentage,0) = 0 AND
                   PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A'  AND
                   (l_derv_rates_missing_amts_flag = 'N'  OR
                    l_source_fp_preference_code = l_target_fp_preference_code ) THEN

                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage:='before mrc api adj % is zero ';
                        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    -- 3156057: If source plan is mc enabled but not appr rev and the target is appr rev,
                    --                  then copy_mc_budget_lines_appr_rev will be called to group the source
                    --                  mc budget lines by currency for creating target mc budget lines

                         IF l_source_appr_rev_plan_flag = 'N'
                         and l_source_plan_in_mc_flag = 'Y'
                         and l_target_appr_rev_plan_flag = 'Y' THEN


                                   IF P_PA_DEBUG_MODE = 'Y' THEN
                                       pa_debug.g_err_stage:='calling copy_mc_budget_lines_appr_rev ';
                                       pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                                    END IF;


                                 PA_MRC_FINPLAN.COPY_MC_BUDGET_LINES_APPR_REV
                                     (p_source_fin_plan_version_id => p_source_version_id,
                                      p_target_fin_plan_version_id => l_budget_version_id,
                                      x_return_status              => l_return_status,
                                      x_msg_count                  => x_msg_count,
                                      x_msg_data                   => x_msg_data);

                                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                                  END IF;

                         ELSE

                                   IF P_PA_DEBUG_MODE = 'Y' THEN
                                       pa_debug.g_err_stage:='calling copy_mc_budget_lines ';
                                       pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                                    END IF;

                                 PA_MRC_FINPLAN.COPY_MC_BUDGET_LINES
                                     (p_source_fin_plan_version_id => p_source_version_id,
                                      p_target_fin_plan_version_id => l_budget_version_id,
                                      x_return_status              => l_return_status,
                                      x_msg_count                  => x_msg_count,
                                      x_msg_data                   => x_msg_data);

                         END IF; -- 3156057

                ELSE

                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage:='before mrc api adj % is NOT zero ';
                        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;

                        PA_MRC_FINPLAN.MAINTAIN_ALL_MC_BUDGET_LINES
-- Bug# 2657812 - Commented -  (p_fin_plan_version_id => p_source_version_id, - mrc should be done for target
-- Bug# 2657812
                        (p_fin_plan_version_id => l_budget_version_id, -- Target version should be passed
                                p_entire_version      => 'Y',
                                x_return_status       => l_return_status,
                                x_msg_count           => x_msg_count,
                                x_msg_data            => x_msg_data);

                END IF;
       END IF;

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE g_mrc_exception;
       END IF;

       PA_MRC_FINPLAN.G_CALLING_MODULE := NULL;

     END IF;
     */

    --Bug 4290043. Rollup API should be called if any of the amounts in the target version are re-derived
    IF l_adj_percentage = 0 AND
      ( l_derv_rates_missing_amts_flag='N' OR
        l_source_fp_preference_code = l_target_fp_preference_code)THEN
        --Fetch source profile id
        BEGIN
                SELECT period_profile_id
                INTO   l_source_profile_id
                FROM   PA_BUDGET_VERSIONS
                WHERE  budget_version_id = p_source_version_id;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                      l_source_profile_id := NULL;
        END;

        --Fetch target profile id

        BEGIN
                SELECT period_profile_id
                INTO   l_target_profile_id
                FROM   PA_BUDGET_VERSIONS
                WHERE  budget_version_id = l_budget_version_id;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_target_profile_id := NULL;
        END;

        IF (l_source_profile_id IS NOT NULL)  AND (l_target_profile_id IS NOT NULL) THEN
             IF l_source_profile_id = l_target_profile_id THEN


              -- Bug 3362316, 08-JAN-2003: Added New IF/END IF fro ORG_FORECAST  ----------

              IF p_calling_module = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST
                  THEN


                  --copy the  period denorm directly from source to target

                  IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.g_err_stage := 'Calling copy_periods_denorm api';
                      pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  PA_FP_COPY_FROM_PKG.copy_periods_denorm (
                               p_source_plan_version_id   => p_source_version_id
                               ,p_target_plan_version_id  => l_budget_version_id
                               ,p_calling_module          => p_calling_module
                               ,x_return_status           => l_return_status
                               ,x_msg_count               => l_msg_count
                               ,x_msg_data                => l_msg_data );


               END IF;

               -- End, Bug 3362316, 08-JAN-2003: Added New IF/END IF fro ORG_FORECAST  --------


              ELSIF p_calling_module = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST THEN

                    /* Please note that in case of org forecast, we are NOT using the current
                       period profile id for the target version. We copy the period profile id
                       from the source version. This is a known bug and bug# 2521711 is logged
                       to track this change. When this bug is fixed, we need to comment the
                       below update and call to copy_period_denorm and call call_maintain_plan_matrix
                       instead. We also need to change call_maintain_plan_matrix and create_org_fcst_elements
                       to fix this issue */

                    --Update the new budget version/target's period profile id as that of the source version

                    UPDATE pa_budget_versions
                    SET    period_profile_id = l_source_profile_id
                    WHERE  budget_version_id = l_budget_version_id;

                    --Calling copy_periods_denorm api

                    pa_debug.g_err_stage := 'Calling copy_periods_denorm api';
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    PA_FP_COPY_FROM_PKG.copy_periods_denorm (
                               p_source_plan_version_id   => p_source_version_id
                               ,p_target_plan_version_id  => l_budget_version_id
                               ,p_calling_module          => p_calling_module
                               ,x_return_status           => l_return_status
                               ,x_msg_count               => l_msg_count
                               ,x_msg_data                => l_msg_data );

                    /*--if source and target profile ids are different then call
                    --call_maintain_plan_matrix api

                    pa_debug.g_err_stage := 'Calling call_maintain_plan_matrix api';
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    Call_maintain_plan_matrix(
                           p_budget_version_id => l_budget_version_id,
                           p_data_source    => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST,
                           x_return_status     => l_return_status,
                           x_msg_count         => l_msg_count,
                           x_msg_data          => l_msg_data ); */
              END IF;
        END IF; --l_target_profile_id IS NOT NULL
       END IF; --l_adj_percentage

     --IPM Arch Enhancement - Start - Bug 4865563
       IF p_calling_module <> PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST THEN

               PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                   (P_BUDGET_VERSION_ID              => p_source_version_id,
                    X_FP_COLS_REC                    => l_src_fp_cols_rec,
                    X_RETURN_STATUS                  => l_return_status,
                    X_MSG_COUNT                      => l_msg_count,
                    X_MSG_DATA                       => l_msg_data);

                    IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                       IF P_PA_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Error in SRC PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DETAILS';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                       END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

                PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                   (P_BUDGET_VERSION_ID              => l_budget_version_id,
                    X_FP_COLS_REC                    => l_fp_cols_rec,
                    X_RETURN_STATUS                  => l_return_status,
                    X_MSG_COUNT                      => l_msg_count,
                    X_MSG_DATA                       => l_msg_data);

                    IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                       IF P_PA_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Error in TARGET PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DETAILS';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                       END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

               l_src_version_type :=l_src_fp_cols_rec.x_version_type;
               l_target_version_type :=l_fp_cols_rec.x_version_type;

                   --Calling populate_display_qty for populating display_quantity in pa_budget_lines
                   PA_BUDGET_LINES_UTILS.populate_display_qty
                   (p_budget_version_id    => l_budget_version_id,
                    p_context              => 'FINANCIAL',
                    p_use_temp_table_flag  => 'N',
                    x_return_status        => l_return_status);

                IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                   IF P_PA_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Error in PA_BUDGET_LINES_UTILS.populate_display_qty';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                   END IF;
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

           IF (l_source_appr_rev_plan_flag = 'N' AND l_source_plan_in_mc_flag = 'Y') and l_target_appr_rev_plan_flag = 'Y' THEN

               pa_res_asg_currency_pub.maintain_data
               (p_fp_cols_rec        => l_fp_cols_rec,
                p_calling_module     => 'COPY_PLAN',
                p_rollup_flag        => 'Y',
                p_version_level_flag => 'Y',
                x_return_status      => l_return_status,
                x_msg_data           => l_msg_count,
                x_msg_count          => l_msg_data);


                    IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                       IF P_PA_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Error in PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                       END IF;
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;

           ELSIF (l_adj_percentage = 0 AND l_src_version_type = l_target_version_type) THEN

               pa_res_asg_currency_pub.maintain_data
               (p_fp_cols_rec        => l_fp_cols_rec,
                p_calling_module     => 'COPY_PLAN',
                p_copy_flag          => 'Y',
                p_src_version_id     => p_source_version_id,
                p_copy_mode          => 'COPY_ALL',
                p_version_level_flag => 'Y',
                x_return_status      => l_return_status,
                x_msg_data           => l_msg_count,
                x_msg_count          => l_msg_data);

           ELSE

               -- Copy only the overrides
               pa_res_asg_currency_pub.maintain_data
               (p_fp_cols_rec        => l_fp_cols_rec,
                p_calling_module     => 'COPY_PLAN',
                p_copy_flag          => 'Y',
                p_copy_mode          => 'COPY_OVERRIDES',
                p_src_version_id     => p_source_version_id,
                p_version_level_flag => 'Y',
                x_return_status      => l_return_status,
                x_msg_data           => l_msg_data,
                x_msg_count          => l_msg_count);

                IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                   IF P_PA_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'Error in PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA - Copy Overrides';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                   END IF;
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

               -- Does the rollup from budget lines
                pa_res_asg_currency_pub.maintain_data
                (p_fp_cols_rec        => l_fp_cols_rec,
                p_calling_module     => 'COPY_PLAN',
                p_rollup_flag        => 'Y',
                p_src_version_id     => p_source_version_id,
                p_version_level_flag => 'Y',
                x_return_status      => l_return_status,
                x_msg_data           => l_msg_data,
                x_msg_count          => l_msg_count);

                IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                   IF P_PA_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Error in PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA - Rollup';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                   END IF;
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;
           END IF;

       END IF;  --p_calling_module <> PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST

       IF NOT (l_adj_percentage = 0 AND
           ( l_derv_rates_missing_amts_flag='N' OR
            l_source_fp_preference_code = l_target_fp_preference_code))THEN
           --Calling rollup_budget_versions.This api rolls up resource assignments,
           --creates proj denorm at entered level, creates rollup proj denorm and
           --updates budget version with summed up values

           IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage := 'Calling rollup_budget_versions api - 1st rollup';
               pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

           PA_FP_ROLLUP_PKG.rollup_budget_version (
                         p_budget_version_id   => l_budget_version_id
                         ,p_entire_version     => 'Y'
                         ,x_return_status      => l_return_status
                         ,x_msg_count          => l_msg_count
                         ,x_msg_data           => l_msg_data );
   /* Bug 5099353 Start */
       ELSIF p_calling_module <> PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST then

           open is_eligible_for_rollup(p_project_id,l_source_proj_fp_options_id);
           fetch is_eligible_for_rollup into l_is_eligible_for_rollup;
           close is_eligible_for_rollup;

           If l_is_eligible_for_rollup = 'Y' then
               open chk_tgt_ver_status;
               fetch chk_tgt_ver_status into l_chk_tgt_ver_status;
               close chk_tgt_ver_status;
               If l_chk_tgt_ver_status = 'Y' then

                         IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.g_err_stage := 'Calling rollup_budget_versions api - 2nd rollup';
                             pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                         END IF;


           PA_FP_ROLLUP_PKG.rollup_budget_version (
                       p_budget_version_id   => l_budget_version_id
                       ,p_entire_version     => 'Y'
                       ,x_return_status      => l_return_status
                       ,x_msg_count          => l_msg_count
                       ,x_msg_data           => l_msg_data );
              End if;
           End if;
  /* Bug 5099353 End */
       END IF;
     --IPM Arch Enhancement - End - Bug 4865563



    -- Bug 3362316, 08-JAN-2003: Populate Reporting Lines Entity  --------------------------


    IF (p_calling_module = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN)
    THEN
        IF p_copy_mode = 'B' THEN

          /* We want to handle the reporting lines integration for baseline case
             in baseline api. Partly because start/end dates of budget lines could
             change during baseline and also for the reason that all api calls
             pertaining to baseline are in one api */
             null;

        ELSIF p_copy_mode = 'W' THEN

            -- bug 3731925 Check if rbs version id for the target version needs to be
            -- updated with plan type level value
            Select rbs_version_id
            into   l_target_pt_lvl_rbs_version_id
            from   pa_proj_fp_options opt
            where  opt.project_id = p_project_id
            and    opt.fin_plan_type_id = l_target_fin_plan_type_id
            and    opt.fin_plan_option_level_code = 'PLAN_TYPE';

            If nvl(l_source_ver_rbs_version_id,-99) <> nvl(l_target_pt_lvl_rbs_version_id,-99) THEN
                -- rbs needs to be updated with parent plan type level record
                -- do not copy summarization data
                pa_fp_planning_transaction_pub.Refresh_rbs_for_versions(
                   p_project_id           => p_project_id
                  ,p_fin_plan_type_id     => l_target_fin_plan_type_id
                  ,p_calling_context      => 'SINGLE_VERSION'
                  ,p_budget_version_id    => l_budget_version_id
                  ,x_return_status        => l_return_status
                  ,x_msg_count            => l_msg_count
                  ,x_msg_data             => l_msg_data);

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:='Called API Refresh_rbs_for_versions returned error';
                        pa_debug.write('Refresh_Plan_Txns:  ' || l_module_name,pa_debug.g_err_stage,5);
                   END IF;
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               END IF;


            ELSE   -- bug 3731925 rbs version is same so summarization data can be copied

               IF p_pji_rollup_required = 'Y' THEN --for Bug 4200168
                    /* 3156057: If source plan is mc enabled but not appr rev and the target is appr rev,
                     PJI copy api should not be called and PJI CREATE api should be called as is it could
                     be that PJI team is doing currency level rollups and the copying from source version
                     which had multiple currecnies would cause data integriy issues
                     (target AR version would show data in MC in view plan pages). */

                     --Bug 4290043. If amounts/rates are derived in the target version then PJI lines should
                     --not be copied from source and they should be created by looking at budget lines of target
                     IF (l_source_appr_rev_plan_flag = 'N' AND
                         l_source_plan_in_mc_flag = 'Y' AND
                         l_target_appr_rev_plan_flag = 'Y') OR
             l_source_fp_preference_code <> l_target_fp_preference_code OR --Added for bug 42344402
                         l_adj_percentage <> 0  OR  -- Bug 4085235: Added this condition to call plan_create
                         l_derv_rates_missing_amts_flag = 'Y' THEN

                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.g_err_stage := 'Calling PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE';
                          pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                       END IF;

                       l_dest_ver_id_tbl.extend(1);
                       l_dest_ver_id_tbl(1)   := l_budget_version_id;

                       --Bug 3969851. Plan_delete should be called before calling plan_create
                       PJI_FM_XBS_ACCUM_MAINT.PLAN_DELETE (
                          p_fp_version_ids   => l_dest_ver_id_tbl,
                          x_return_status    => l_return_status,
                          x_msg_code         => l_error_msg_code);

                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
                           IF P_PA_DEBUG_MODE = 'Y' THEN
                              pa_debug.g_err_stage := 'API PJI_FM_XBS_ACCUM_MAINT.PLAN_DELETE returned ERROR 1 '|| l_error_msg_code;
                              pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,5);
                           END IF;

                           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                       END IF;


                       PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE(p_fp_version_ids => l_dest_ver_id_tbl
                                                        , x_return_status => l_return_status
                                                        , x_msg_code => l_error_msg_code);

                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                       END IF;

                     ELSE

                       l_source_ver_id_tbl.extend(1);
                       l_dest_ver_id_tbl.extend(1);
                       l_source_ver_type_tbl.extend(1);
                       l_dest_ver_type_tbl.extend(1);

                       l_source_ver_id_tbl(1) := p_source_version_id;

                       l_dest_ver_id_tbl(1)   := l_budget_version_id;

                       -- Fetch source IN-parameter values

                       BEGIN

                         SELECT decode(budget_status_code,'S','W',budget_status_code)
                         INTO   l_source_ver_type_tbl(1)
                         FROM   PA_BUDGET_VERSIONS
                         WHERE  budget_version_id = p_source_version_id;
                        EXCEPTION
                             WHEN NO_DATA_FOUND THEN
                                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                       END;


                       BEGIN

                         SELECT budget_status_code
                         INTO   l_dest_ver_type_tbl(1) /* This should always be W since we are inside "IF p_copy_mode = W" */
                         FROM   PA_BUDGET_VERSIONS
                         WHERE  budget_version_id = l_budget_version_id;
                        EXCEPTION
                             WHEN NO_DATA_FOUND THEN
                                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                       END;

                       IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.g_err_stage := 'Calling PJI_FM_XBS_ACCUM_MAINT.FINPLAN_COPY';
                           pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                       END IF;


                       PJI_FM_XBS_ACCUM_MAINT.FINPLAN_COPY(
                              p_source_fp_version_ids => l_source_ver_id_tbl
                              , p_dest_fp_version_ids => l_dest_ver_id_tbl
                              , p_source_fp_version_types => l_source_ver_type_tbl
                              , p_dest_fp_version_types => l_dest_ver_type_tbl
                              , x_return_status => l_return_status
                              , x_msg_code => l_error_msg_code);

                       -- Dev Note: Most of the other FP api calls were NOT followed by error and rollback
                       --           processing logic. However, in other high-level procedures in this
                       --           package, calls to Reporting Lines apis are followed by error and
                       --           rollback conditional logic.
                       --
                       --           Confirmed strategy with Sanjay Sarma, 19-MAR-2004.
                       --

                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                         THEN

                          PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA'
                                               , p_msg_name            => l_error_msg_code);

                          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                       END IF;

                     END IF;
               END IF;     --  IF p_pji_rollup_required = 'Y' THEN --for Bug 4200168
            END If; -- If l_source_ver_rbs_version_id <> l_target_pt_lvl_rbs_version_id
        END IF; -- p_copy_mode


      -- End, Bug 3362316, 08-JAN-2003: Populate Reporting Lines Entity  ----------------------
     END IF;-- p_calling_module = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN)

    --IF p_calling_module is PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST then call create_org_fcst_elements to insert into
    --pa_fp_adj_elements,pa_fin_plan_adj_lines,pa_org_fcst_elements,pa_org_forecast_lines.

    IF p_calling_module = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST THEN

          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := 'Calling create_org_fcst_elements api';
             pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          PA_FIN_PLAN_PUB.create_org_fcst_elements (
                  p_project_id          => p_project_id,
                  p_source_version_id   => p_source_version_id,
                  p_target_version_id   => l_budget_version_id,
                  x_return_status       => l_return_status,
                  x_msg_count           => l_msg_count,
                  x_msg_data            => l_msg_data );
    END IF;

    px_target_version_id := l_budget_version_id;


    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage := 'Exiting Copy_Version';
        pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    pa_debug.reset_err_stack;

 EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        ROLLBACK TO PA_FIN_PLAN_PUB_COPY_VERSION;
        -- Bug Fix: 4569365. Removed MRC code.
        -- PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
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
           pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.reset_err_stack;

   WHEN Others THEN
        ROLLBACK TO PA_FIN_PLAN_PUB_COPY_VERSION;
        -- Bug Fix: 4569365. Removed MRC code.
        -- PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_FIN_PLAN_PUB'
                                ,p_procedure_name => 'COPY_VERSION');
        pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Copy_Version: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;
        pa_debug.reset_err_stack;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Copy_Version;

/* ------------------------------------------------------------------------- */

procedure Baseline
    (p_project_id                   IN  pa_budget_versions.project_id%TYPE,
     p_budget_version_id            IN  pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number        IN  pa_budget_versions.record_version_number%TYPE,
     p_orig_budget_version_id       IN  pa_budget_versions.budget_version_id%TYPE,
     p_orig_record_version_number   IN  pa_budget_versions.record_version_number%TYPE,
     x_fc_version_created_flag      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_return_status                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
/* Bug# 2661650 - _vl to _b/_tl for performance changes */
l_fin_plan_type_code    pa_fin_plan_types_b.fin_plan_type_code%TYPE;
l_debug_mode      VARCHAR2(30);
l_valid1_flag     VARCHAR2(1);
l_valid2_flag     VARCHAR2(1);
l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_error_msg_code  VARCHAR2(30);
l_return_status   VARCHAR2(2000);
l_msg_index_out   NUMBER;

l_created_by        pa_budget_versions.created_by%TYPE;
l_emp_id            NUMBER;

--The following varible is added to make program consistent with the
--changed copy_version procedure prototype

l_target_version_id PA_BUDGET_VERSIONS.budget_version_id%TYPE;
--Bug 4145705
l_version_type               pa_budget_versions.version_type%TYPE;
l_fin_plan_type_id           pa_budget_versions.fin_plan_type_id%TYPE;
l_orig_budget_version_id     pa_budget_versions.budget_version_id%TYPE;
l_orig_record_version_number pa_budget_versions.record_Version_number%TYPE;
l_temp                       NUMBER;

begin
    FND_MSG_PUB.initialize;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PA_FIN_PLAN_PUB.Baseline');
    END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Baseline: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
/* CHECK FOR BUSINESS RULES VIOLATIONS */
    /* check for null budget_version_id */
    if p_budget_version_id is NULL then
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Baseline: ' || 'BUSINESS RULE VIOLATION: p_budget_version_id is null');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_NO_PLAN_VERSION');
    end if;
    /* check to see if the current user is an EMPLOYEE; ONLY EMPLOYEES CAN BASELINE */
    l_created_by:=FND_GLOBAL.user_id;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('Baseline: ' || 'created by= ' || l_created_by);
    END IF;
    l_emp_id := PA_UTILS.GetEmpIdFromUser(l_created_by);
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('Baseline: ' || 'employee id= ' || l_emp_id);
    END IF;
    if l_emp_id IS NULL then
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Baseline: ' || 'BUSINESS RULE VIOLATION: l_emp_id is NULL');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_ALL_WARN_NO_EMPL_REC');
    end if;
    /* check to see if the budget version we're setting to be current baselined has */
    /* been updated by someone else already */
    PA_FIN_PLAN_UTILS.Check_Record_Version_Number
            (p_unique_index             => p_budget_version_id,
             p_record_version_number    => p_record_version_number,
             x_valid_flag               => l_valid1_flag,
             x_return_status            => l_return_status,
             x_error_msg_code           => l_error_msg_code);
    /* check to see if the old current baselined budget version has */
    /* been updated by someone else already */
    /* if p_orig_budget_version_id = null then there is currently not a baselined version */
    /* in this case, ignore this check
    if p_orig_budget_version_id <> null then */
    if p_orig_budget_version_id is not null then
        PA_FIN_PLAN_UTILS.Check_Record_Version_Number
            (p_unique_index             => p_orig_budget_version_id,
             p_record_version_number    => p_orig_record_version_number,
             x_valid_flag               => l_valid2_flag,
             x_return_status            => l_return_status,
             x_error_msg_code           => l_error_msg_code);
        if not((l_valid1_flag='Y') and (l_valid2_flag='Y')) then
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('Baseline: ' || 'BUSINESS RULE VIOLATION: Check_Record_Version_Number failed');
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                 p_msg_name            => l_error_msg_code);
        end if;
    end if;
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

/* If There are NO Business Rules Violations , Then proceed with Baseline */
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('no business rules violations; proceeding with baseline');
    END IF;
    SAVEPOINT PA_FIN_PLAN_PUB_BASELINE;

    /* FINPLANNING PATCHSET K: If the plan type is not ORG_FORECAST, then call
       pa_fin_plan_pvt.Submit_Current_Working_FinPlan
     */
    --Bug 4145705.Selected version type and fin plan type id
    select pt.fin_plan_type_code,
           pbv.version_type,
           pbv.fin_plan_type_id
      into l_fin_plan_type_code,
           l_version_type,
           l_fin_plan_type_id
      from pa_budget_versions pbv,
           pa_fin_plan_types_b pt  /* Bug# 2661650 - _vl to _b/_tl for performance changes */
      where pbv.budget_version_id = p_budget_version_id and
            pbv.fin_plan_type_id = pt.fin_plan_type_id ;


    if l_fin_plan_type_code = 'ORG_FORECAST' then

      /* set the status_code back to "Working" from "Submitted" for the version we baseline */
      update
        pa_budget_versions
      set
        last_update_date = SYSDATE,
        last_updated_by = FND_GLOBAL.user_id,
        last_update_login = FND_GLOBAL.login_id,
        budget_status_code = 'W',
        record_version_number = record_version_number+1
      where
        budget_version_id = p_budget_version_id;
      /* remove Current Baselined status from current baselined version */
      update
          pa_budget_versions
      set
        last_update_date = SYSDATE,
        last_updated_by = FND_GLOBAL.user_id,
        last_update_login = FND_GLOBAL.login_id,
        current_flag = 'N',
        record_version_number = record_version_number+1
      where
        budget_version_id=p_orig_budget_version_id;
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('the old baselined version is no longer the current baselined version');
      END IF;
      /* create a copy, labeled as 'BASELINED' */
      PA_FIN_PLAN_PUB.Copy_Version
        (p_project_id           => p_project_id,
         p_source_version_id    => p_budget_version_id,
         p_copy_mode            => 'B',
         px_target_version_id   => l_target_version_id,
                  --added to make the call consistent with new extension
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data);
      /* PA_FIN_PLAN_PUB.Copy_Version may have generated errors */
      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          rollback to PA_FIN_PLAN_PUB_BASELINE;
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
        raise pa_fin_plan_pub.rollback_on_error;
      end if;
    else

      --Bug 4145705. The following block has been added to address the issue where in multiple current baselined versions
      --were getting created. This code on detecting such cases will throw an error
      BEGIN

          SELECT budget_version_id,
                 record_version_number
          INTO   l_orig_budget_version_id,
                 l_orig_record_version_number
          FROM   pa_budget_versions
          WHERE  project_id=p_project_id
          AND    fin_plan_type_id=l_fin_plan_type_id
          AND    version_type=l_version_type
          AND    current_flag='Y';

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_orig_budget_version_id:=NULL;
        l_orig_record_version_number:=NULL;

      WHEN TOO_MANY_ROWS THEN

          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                p_token1         => 'PROCEDURENAME',
                p_value1         => 'PAFPPUBB.Baseline',
                p_token2         => 'STAGE',
                p_value2         => 'l_orig_budget_version_id IS '||l_orig_budget_version_id
                                    ||' AND p_orig_budget_version_id IS '||p_orig_budget_version_id );

          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      WHEN OTHERS THEN

          IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage := 'Unexpected error while deriving l_orig_budget_version_id '||sqlerrm;
                  pa_debug.write('PAFPPUBB.Baseline',pa_debug.g_err_stage,5);
          END IF;
          RAISE;
      END;

      IF NVL(l_orig_budget_version_id,-99) <>  NVL(p_orig_budget_version_id,NVL(l_orig_budget_version_id,-99)) THEN

          IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage := 'l_orig_budget_version_id IS NOT SAME AS p_orig_budget_version_id' ;
                  pa_debug.write('PAFPPUBB.Baseline',pa_debug.g_err_stage,5);

                  pa_debug.g_err_stage := 'l_orig_budget_version_id '||l_orig_budget_version_id ;
                  pa_debug.write('PAFPPUBB.Baseline',pa_debug.g_err_stage,5);

                  pa_debug.g_err_stage := 'p_orig_budget_version_id '||p_orig_budget_version_id ;
                  pa_debug.write('PAFPPUBB.Baseline',pa_debug.g_err_stage,5);

          END IF;
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                p_token1         => 'PROCEDURENAME',
                p_value1         => 'PAFPPUBB.Baseline',
                p_token2         => 'STAGE',
                p_value2         => 'l_orig_budget_version_id IS '||l_orig_budget_version_id
                                    ||' AND p_orig_budget_version_id IS '||p_orig_budget_version_id );

          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      ELSIF p_orig_budget_version_id IS NOT NULL THEN

        l_orig_budget_version_id:=p_orig_budget_version_id;
        l_orig_record_version_number:=p_orig_record_version_number;

      END IF;
      --End of block for bug 4145705

      -- call PA_FIN_PLAN_PVT.Baseline_FinPlan for NON ORG_FORECAST types
      PA_FIN_PLAN_PVT.Baseline_FinPlan
        (p_project_id                 => p_project_id,
         p_budget_version_id          => p_budget_version_id,
         p_record_version_number      => p_record_version_number,
         p_orig_budget_version_id     => l_orig_budget_version_id,
         p_orig_record_version_number => l_orig_record_version_number,
         p_verify_budget_rules        => 'Y',
         x_fc_version_created_flag    => x_fc_version_created_flag,
         x_return_status              => l_return_status,
         x_msg_count                  => l_msg_count,
         x_msg_data                   => l_msg_data);
      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        -- PA_FIN_PLAN_PVT.Baseline_FinPlan RETURNED ERRORS
        rollback to PA_FIN_PLAN_PUB_BASELINE;
        x_return_status := FND_API.G_RET_STS_ERROR;
        /*
           PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_data           => x_msg_data,
                  p_msg_index_out  => l_msg_index_out);
           x_msg_count := l_msg_count;
        else
           x_msg_count := l_msg_count;
        end if; */
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
      --Bug 4145705
      SELECT COUNT(*)
      INTO   l_temp
      FROM   pa_budget_versions
      WHERE  project_id=p_project_id
      AND    fin_plan_type_id=l_fin_plan_type_id
      AND    version_type=l_version_type
      AND    current_flag='Y';
      IF l_temp <> 1 THEN

          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                p_token1         => 'PROCEDURENAME',
                p_value1         => 'PAFPPUBB.Baseline',
                p_token2         => 'STAGE',
                p_value2         => 'No. of current baselined versions '||l_temp);

          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

    end if; -- l_fin_plan_type_code = ORG_FORECAST

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.reset_err_stack;

exception
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
           ROLLBACK TO PA_FIN_PLAN_PUB_BASELINE;
           x_return_status := FND_API.G_RET_STS_ERROR;
           pa_debug.reset_curr_function;
    when pa_fin_plan_pub.rollback_on_error then
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('Procedure Baseline: rollback_on_error exception');
      END IF;
      rollback to PA_FIN_PLAN_PUB_BASELINE;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    when others then
        rollback to PA_FIN_PLAN_PUB_BASELINE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg(p_pkg_name         => 'PA_FIN_PLAN_PUB',
                                p_procedure_name   => 'Baseline');
        pa_debug.reset_err_stack;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
end Baseline;
/* ------------------------------------------------------------------------- */

procedure Create_Version_OrgFcst
    (p_project_id                   IN     pa_budget_versions.project_id%TYPE,
     p_fin_plan_type_id             IN     pa_budget_versions.fin_plan_type_id%TYPE,
     p_fin_plan_options_id          IN     pa_proj_fp_options.proj_fp_options_id%TYPE,
     p_version_name                 IN     pa_budget_versions.version_name%TYPE,
     p_description                  IN     pa_budget_versions.description%TYPE,
     p_resource_list_id             IN     pa_budget_versions.resource_list_id%TYPE,
     x_budget_version_id            OUT    NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is

/* error handling variables */
l_debug_mode      VARCHAR2(30);
l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_error_msg_code  VARCHAR2(2000);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);

l_version_type    pa_budget_versions.version_type%TYPE;
l_version_type_code     pa_fin_plan_types_b.fin_plan_type_code%TYPE;
l_max_version     pa_budget_versions.version_number%TYPE;
l_current_working_flag  pa_budget_versions.current_working_flag%TYPE;

l_budget_version_id     pa_budget_versions.budget_version_id%TYPE;         /* newly-created budget_version_id */
l_proj_fin_plan_options_id   pa_proj_fp_options.proj_fp_options_id%TYPE;
l_row_id            ROWID;
l_resource_list_id      pa_budget_versions.resource_list_id%TYPE;
l_org_fcst_period_type  pa_forecasting_options_all.org_fcst_period_type%TYPE;
l_org_time_phased_code   pa_proj_fp_options.all_time_phased_code%TYPE;
l_org_amount_set_id      pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE;
l_org_structure_version_id pa_implementations_all.org_structure_version_id%TYPE;
l_period_set_name       pa_implementations_all.period_set_name%TYPE;
l_act_period_type       gl_periods.period_type%TYPE;
l_org_projfunc_currency_code    gl_sets_of_books.currency_code%TYPE;
l_number_of_periods     pa_forecasting_options_all.number_of_periods%TYPE;
l_request_id            pa_budget_versions.request_id%TYPE;
l_weighted_or_full_code pa_forecasting_options_all.weighted_or_full_code%TYPE;
l_fcst_start_date       pa_proj_fp_options.fin_plan_start_date%TYPE;
l_fcst_end_date         pa_proj_fp_options.fin_plan_end_date%TYPE;
l_org_project_template_id   pa_forecasting_options_all.org_fcst_project_template_id%TYPE;
l_org_id                pa_forecasting_options_all.org_id%TYPE;
l_period_profile_id     pa_proj_period_profiles.period_profile_id%TYPE;
l_ppp_start_date        DATE;
l_ppp_end_date          DATE;
l_pa_period_type        pa_implementations_all.pa_period_type%TYPE;

cursor amount_set_csr is
select
    fin_plan_amount_set_id
from
    pa_fin_plan_amount_sets
where
    amount_set_type_code = 'ALL';
amount_set_rec amount_set_csr%ROWTYPE;

cursor plan_options_csr is
select
    proj_fp_options_id
from
    pa_proj_fp_options
where
    project_id=p_project_id and
    fin_plan_type_id=p_fin_plan_type_id and
    fin_plan_option_level_code = 'PLAN_TYPE';
plan_options_rec plan_options_csr%ROWTYPE;

begin
    FND_MSG_PUB.initialize;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PA_FIN_PLAN_PUB.Create_Version_OrgFcst');
    END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Create_Version_OrgFcst: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
/* CHECK FOR BUSINESS RULES VIOLATIONS */
    /* check for null version_name */
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write_file('Create_Version_OrgFcst: ' || 'starting procedure: initial message count= ' || FND_MSG_PUB.count_msg);
    END IF;
    if p_version_name is NULL then
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_NO_PLAN_VERSION_NAME');
    end if;

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

/* If There are NO Business Rules Violations , Then proceed with Create Version Apply */
    if l_msg_count = 0 then
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'no business rules violations');
        END IF;
        SAVEPOINT PA_FP_PUB_CREATE_VER_ORGFCST;
        /* Get the version_type by querying pa_fin_plan_types_b using fin_plan_type_id */
        select
                fin_plan_type_code,
                name
            into
                l_version_type_code,
                l_version_type
            from
                pa_fin_plan_types_vl
            where
                fin_plan_type_id=p_fin_plan_type_id;
        if (l_version_type is null) then
            raise NO_DATA_FOUND;
        end if;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'version type selected with no problems');
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'version type code is ' || l_version_type_code);
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'version type name is ' || l_version_type);
        END IF;
        /* Get the max version_number for working versions of this plan type */
        select
                nvl(max(version_number), 0)
            into
                l_max_version
            from
                pa_budget_versions
            where
                project_id = p_project_id and
                fin_plan_type_id = p_fin_plan_type_id and
                budget_status_code in ('W', 'S');
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'max version number is ' || l_max_version);
        END IF;
        /* Get the resource_list_id to be used; if it was not passed to this procedure, */
        /* we can retrieve it from FND_PROFILE if the version_type is ORG_FORECAST */
        if p_resource_list_id is NULL then
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'p_resource_list_id is null');
            END IF;
            if l_version_type_code = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST then
                l_resource_list_id := FND_PROFILE.value('PA_FORECAST_RESOURCE_LIST');
            else
                l_msg_count := l_msg_count + 1;
                if x_msg_count = 1 then
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
                 raise pa_fin_plan_pub.rollback_on_error;
             end if;
        else
            l_resource_list_id := p_resource_list_id;
        end if;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'resource list is ' || l_resource_list_id);
        END IF;
        /* retrieve the period type, start date, and end date from pa_forecasting_options */
        pa_fp_org_fcst_utils.get_forecast_option_details
           (x_fcst_period_type      => l_org_fcst_period_type,
            x_period_set_name       => l_period_set_name,
            x_act_period_type       => l_act_period_type,
            x_org_projfunc_currency_code    => l_org_projfunc_currency_code,
            x_number_of_periods     => l_number_of_periods,
            x_weighted_or_full_code => l_weighted_or_full_code,
            x_org_proj_template_id  => l_org_project_template_id,
            x_org_structure_version_id => l_org_structure_version_id,
            x_fcst_start_date       => l_fcst_start_date,
            x_fcst_end_date         => l_fcst_end_date,
            x_org_id                => l_org_id,
            x_return_status         => l_return_status,
            x_err_code              => l_error_msg_code);
/*
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'l_org_fcst_period_type is ' || l_org_fcst_period_type);
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'l_period_set_name is ' || l_period_set_name);
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'l_act_period_type is ' || l_act_period_type);
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'l_org_projfunc_currency_code is ' || l_org_projfunc_currency_code);
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'l_number_of_periods is ' || l_number_of_periods);
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'l_org_project_template_id is ' || l_org_project_template_id);
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'l_org_structure_version_id is ' || l_org_structure_version_id);
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'l_org_id is ' || l_org_id);
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'l_return_status is ' || l_return_status);
        END IF;
*/
        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'error with pa_fp_org_fcst_utils.get_forecast_option_details');
            END IF;
            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                 p_msg_name            => l_error_msg_code);
            raise pa_fin_plan_pub.rollback_on_error;
        end if;

        if l_org_fcst_period_type = PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL then
            l_org_time_phased_code := PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G;
        elsif l_org_fcst_period_type = PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA then
            l_org_time_phased_code := PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P;
        end if;
        /* GETTING PERIOD PROFILE ID: first check to see if we can find it; if not, then
         * we create one
         */
        pa_fp_org_fcst_utils.get_period_profile
            (p_project_id               => p_project_id,
             p_period_profile_type      => PA_FP_CONSTANTS_PKG.G_PD_PROFILE_FIN_PLANNING,
             p_plan_period_type         => l_org_fcst_period_type,
             p_period_set_name          => l_period_set_name,
             p_act_period_type          => l_act_period_type,
             p_start_date               => l_fcst_start_date,
             p_number_of_periods        => l_number_of_periods,
             x_period_profile_id        => l_period_profile_id,
             x_return_status            => l_return_status,
             x_err_code                 => l_error_msg_code);
        /* create a new PERIOD PROFILE ID if one does not exist */
        if l_period_profile_id < 0 then
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'l_period_profile_id < 0');
            END IF;
            l_period_profile_id := NULL;
            if l_org_fcst_period_type = PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA then
                l_pa_period_type := l_act_period_type;
            else
                l_pa_period_type := NULL;
            end if;
/*
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'entering pa_prj_period_profile_utils.maintain_prj_period_profile');
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'project id is ' || p_project_id);
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'p_plan_period_type is ' || l_org_fcst_period_type);
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'p_period_set_name is ' || l_period_set_name);
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'p_gl_period_type is ' || l_act_period_type);
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'p_pa_period_type is ' || l_pa_period_type);
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'p_start_date is ' || l_fcst_start_date);
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'px_end_date is ' || l_fcst_end_date);
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'px_period_profile_id is ' || l_period_profile_id);
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'px_number_of_periods is ' || l_number_of_periods);
            END IF;
*/
            pa_prj_period_profile_utils.maintain_prj_period_profile
                (p_project_id               => p_project_id,
                 p_period_profile_type      => PA_FP_CONSTANTS_PKG.G_PD_PROFILE_FIN_PLANNING,
                 p_plan_period_type         => l_org_fcst_period_type,
                 p_period_set_name          => l_period_set_name,
                 p_gl_period_type           => l_act_period_type,
                 p_pa_period_type           => l_pa_period_type,
                 p_start_date               => l_fcst_start_date,
                 px_end_date                => l_fcst_end_date,
                 px_period_profile_id       => l_period_profile_id,
                 p_commit_flag              => 'N',
                 px_number_of_periods       => l_number_of_periods,
                 x_plan_start_date          => l_ppp_start_date,
                 x_plan_end_date            => l_ppp_end_date,
                 x_return_status            => l_return_status,
                 x_msg_count                => l_msg_count,
                 x_msg_data                 => l_msg_data);
        end if;
        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'error with pa_prj_period_profile_utils.maintain_prj_period_profile');
            END IF;
            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                 p_msg_name            => l_msg_data);
            raise pa_fin_plan_pub.rollback_on_error;
        end if;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Create_Version_OrgFcst: ' || ' the new period profile id is ' || l_period_profile_id);
        END IF;
        /* create the plan version */
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'calling pa_fp_budget_versions_pkg.Insert_Row to create a budget version');
        END IF;
        select pa_budget_versions_s.nextVal into l_budget_version_id from dual;
        /* the new version is the current working only if it's the ONLY working version */
        if (l_max_version = 0) then
            l_current_working_flag := 'Y';
        else
            l_current_working_flag := 'N';
        end if;
        pa_fp_budget_versions_pkg.Insert_Row
           (px_budget_version_id        => l_budget_version_id,  /* unique budget_version_id for new version */
            p_project_id                => p_project_id,          /* the ID of the project */
            p_budget_type_code          => NULL,
            p_version_number            => l_max_version+1,      /* version_number incremented */
            p_budget_status_code        => 'W',                  /* 'Working' version */
            p_current_flag              => 'N',                  /* 'Working' version */
            p_original_flag             => 'N',                  /* 'Working' version */
            p_current_original_flag     => 'N',                  /* 'Working' version */
            p_resource_accumulated_flag => 'N',   /* HARDCODED VALUE */
            p_resource_list_id          => l_resource_list_id,
            p_version_name              =>  p_version_name,     /* user-entered value */
            p_budget_entry_method_code  => NULL,
            p_baselined_by_person_id    => NULL,
            p_baselined_date            => NULL,
            p_change_reason_code        => NULL,
            p_labor_quantity            => NULL,
            p_labor_unit_of_measure     => NULL,
            p_raw_cost                  => NULL,
            p_burdened_cost             => NULL,
            p_revenue                   => NULL,
            p_description               => p_description,      /* user-entered value */
            p_attribute_category        => NULL,
            p_attribute1                => NULL,
            p_attribute2                => NULL,
            p_attribute3                => NULL,
            p_attribute4                => NULL,
            p_attribute5                => NULL,
            p_attribute6                => NULL,
            p_attribute7                => NULL,
            p_attribute8                => NULL,
            p_attribute9                => NULL,
            p_attribute10               => NULL,
            p_attribute11               => NULL,
            p_attribute12               => NULL,
            p_attribute13               => NULL,
            p_attribute14               => NULL,
            p_attribute15               => NULL,
            p_first_budget_period       => NULL,
            p_pm_product_code           => NULL,
            p_pm_budget_reference       => NULL,
            p_wf_status_code            => NULL,
            p_adw_notify_flag           => NULL,
            p_prc_generated_flag        => NULL,
            p_plan_run_date             => NULL,
            p_plan_processing_code      => NULL, /* plan_processing_code = null, since we're not running the generate concurrent process*/
            p_period_profile_id         => l_period_profile_id,     /* use newly-generated period_profile_id */
            p_fin_plan_type_id          => p_fin_plan_type_id,
            p_parent_plan_version_id    => NULL,
            p_project_structure_version_id => NULL,
            p_current_working_flag      => l_current_working_flag,
            p_total_borrowed_revenue    => NULL,
            p_total_tp_revenue_in       => NULL,
            p_total_tp_revenue_out      => NULL,
            p_total_revenue_adj         => NULL,
            p_total_lent_resource_cost  => NULL,
            p_total_tp_cost_in          => NULL,
            p_total_tp_cost_out         => NULL,
            p_total_cost_adj            => NULL,
            p_total_unassigned_time_cost => NULL,
            p_total_utilization_percent  => NULL,
            p_total_utilization_hours    => NULL,
            p_total_utilization_adj      => NULL,
            p_total_capacity             => NULL,
            p_total_head_count           => NULL,
            p_total_head_count_adj       => NULL,
            p_version_type               => l_version_type_code,
            p_request_id                 => NULL,           /* will be changed later in the script */
            x_row_id                     => l_row_id,
            x_return_status              => l_return_status);
        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'error with pa_prj_period_profile_utils.maintain_prj_period_profile');
            END IF;
            /* error message added to the stack in the table handler; we don't need to do it here */
            raise pa_fin_plan_pub.rollback_on_error;
        end if;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'new budget version id is ' || l_budget_version_id);
        END IF;
        x_budget_version_id := l_budget_version_id;


/* create new PROJECT PLANNING OPTION for level=PLAN_TYPE, if it doesn't already exist */
        /* retrieve the amount_set_id for org forecast */
        open amount_set_csr;
        fetch amount_set_csr into amount_set_rec;
        if amount_set_csr%NOTFOUND then
            close amount_set_csr;
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'no data found in amount_sets');
            END IF;
            raise pa_fin_plan_pub.rollback_on_error;
        else
            l_org_amount_set_id := amount_set_rec.fin_plan_amount_set_id;
            close amount_set_csr;
        end if;

        l_proj_fin_plan_options_id := null;
        open plan_options_csr;
        fetch plan_options_csr into plan_options_rec;
        if plan_options_csr%NOTFOUND then
            close plan_options_csr;
             /* raise NO_DATA_FOUND; no error thrown here, because it's part of the logic */
        else
            l_proj_fin_plan_options_id := plan_options_rec.proj_fp_options_id;
            close plan_options_csr;
        end if;

        if l_proj_fin_plan_options_id is NULL then
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'no planning options for plan_type level: creating one now');
            END IF;
        /* call table handler to create planning options for plan_type */
            select pa_proj_fp_options_s.nextVal into l_proj_fin_plan_options_id from dual;
            pa_proj_fp_options_pkg.Insert_Row
               (px_proj_fp_options_id     =>  l_proj_fin_plan_options_id,
                p_project_id                    =>  p_project_id,
                p_fin_plan_option_level_code    =>  'PLAN_TYPE',
                p_fin_plan_type_id              =>  p_fin_plan_type_id,
                p_fin_plan_start_date           =>  NULL,               /* for PLAN_TYPE level */
                p_fin_plan_end_date             =>  NULL,               /* for PLAN_TYPE level */
                p_fin_plan_preference_code      =>  'COST_AND_REV_SAME',     /* for org_forecast */
                p_cost_amount_set_id            =>  NULL,                    /* for org_forecast */
                p_revenue_amount_set_id         =>  NULL,                    /* for org_forecast */
                p_all_amount_set_id             =>  l_org_amount_set_id,     /* for org_forecast */
                p_cost_fin_plan_level_code      =>  NULL,                   /* for org_forecast */
                p_cost_time_phased_code         =>  NULL,                   /* for org_forecast */
                p_cost_resource_list_id         =>  NULL,                   /* for org_forecast */
                p_revenue_fin_plan_level_code   =>  NULL,                   /* for org_forecast */
                p_revenue_time_phased_code      =>  NULL,                   /* for org_forecast */
                p_revenue_resource_list_id      =>  NULL,                   /* for org_forecast */
                p_all_fin_plan_level_code       =>  'L',                     /* for org_forecast */
                p_all_time_phased_code          =>  l_org_time_phased_code, /* for org_forecast */
                p_all_resource_list_id          =>  l_resource_list_id,
                p_report_labor_hrs_from_code    =>  'COST',                 /* for org_forecast */
                p_fin_plan_version_id           =>  NULL,                 /* use l_budget_version_id only at the VERSION_TYPE level */
                x_row_id                        =>  l_row_id,
                x_return_status                 =>  l_return_status);
            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write_file('Create_Version_OrgFcst: ' || 'error with pa_fp_proj_fplan_options_pkg.Insert_Row: plan_type level');
                END IF;
                /* error message added to the stack in the table handler; we don't need to do it here */
                raise pa_fin_plan_pub.rollback_on_error;
            end if;
        end if;
        /* create planning option for plan VERSION */
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Create_Version_OrgFcst: ' || 'creating planning options for PLAN_VERSION level');
        END IF;
        select pa_proj_fp_options_s.nextVal into l_proj_fin_plan_options_id from dual;
        pa_proj_fp_options_pkg.Insert_Row
               (px_proj_fp_options_id     => l_proj_fin_plan_options_id,
                p_project_id                    => p_project_id,
                p_fin_plan_option_level_code    => 'PLAN_VERSION',
                p_fin_plan_type_id              => p_fin_plan_type_id,
                p_fin_plan_start_date           => l_fcst_start_date,
                p_fin_plan_end_date             => l_fcst_end_date,
                p_fin_plan_preference_code      => 'COST_AND_REV_SAME',     /* for org_forecast */
                p_cost_amount_set_id            => NULL,                    /* for org_forecast */
                p_revenue_amount_set_id         => NULL,                    /* for org_forecast */
                p_all_amount_set_id             => l_org_amount_set_id,     /* for org_forecast */
                p_cost_fin_plan_level_code      => NULL,                   /* for org_forecast */
                p_cost_time_phased_code         => NULL,                   /* for org_forecast */
                p_cost_resource_list_id         => NULL,                   /* for org_forecast */
                p_revenue_fin_plan_level_code   => NULL,                   /* for org_forecast */
                p_revenue_time_phased_code      => NULL,                   /* for org_forecast */
                p_revenue_resource_list_id      => NULL,                   /* for org_forecast */
                p_all_fin_plan_level_code       => 'L',                     /* for org_forecast */
                p_all_time_phased_code          => l_org_time_phased_code, /* for org_forecast */
                p_all_resource_list_id          => l_resource_list_id,
                p_report_labor_hrs_from_code    => 'COST',                 /* for org_forecast */
                p_fin_plan_version_id           => l_budget_version_id,
                x_row_id                        => l_row_id,
                x_return_status                 => l_return_status);
            if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write_file('Create_Version_OrgFcst: ' || 'error with pa_fp_proj_fplan_options_pkg.Insert_Row: plan_version level');
                END IF;
                /* error message added to the stack in the table handler; we don't need to do it here */
                raise pa_fin_plan_pub.rollback_on_error;
            end if;
        l_msg_count := FND_MSG_PUB.count_msg;
        if l_msg_count = 0 then
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            pa_debug.reset_err_stack;
        else
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('Create_Version_OrgFcst: ' || 'l_msg_count is ' || l_msg_count);
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
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
                raise pa_fin_plan_pub.rollback_on_error;
            end if;
        end if;
    end if;

exception
    when pa_fin_plan_pub.rollback_on_error then
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('Create_Version_OrgFcst: rollback_on_error exception');
      END IF;
      rollback to PA_FP_PUB_CREATE_VER_ORGFCST;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    when others then
        rollback to PA_FP_PUB_CREATE_VER_ORGFCST;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_PUB',
                                 p_procedure_name   => 'Create_Version_OrgFcst');
        pa_debug.reset_err_stack;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
end Create_Version_OrgFcst;
/* ------------------------------------------------------------------------- */

procedure Regenerate
    (p_project_id                   IN     pa_budget_versions.project_id%TYPE,
     p_budget_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number        IN     pa_budget_versions.record_version_number%TYPE,
     x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
l_debug_mode      VARCHAR2(30);
l_msg_count       NUMBER := 0;
l_valid_flag      VARCHAR2(1);
l_budget_status_code    pa_budget_versions.budget_status_code%TYPE;
l_request_id      NUMBER;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_error_msg_code  VARCHAR2(30);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);
/* Moac Changes */
l_org_id      NUMBER;

begin
    FND_MSG_PUB.initialize;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PA_FIN_PLAN_PUB.Regenerate');
    END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Regenerate: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
/* CHECK FOR BUSINESS RULES VIOLATIONS */
    /* check for null budget_version_id */
    if p_budget_version_id is NULL then
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_NO_PLAN_VERSION');
    end if;

/* check to see if the budget version we're regenerating has */
    /* been updated by someone else already */
    PA_FIN_PLAN_UTILS.Check_Record_Version_Number
            (p_unique_index             => p_budget_version_id,
             p_record_version_number    => p_record_version_number,
             x_valid_flag               => l_valid_flag,
             x_return_status            => l_return_status,
             x_error_msg_code           => l_error_msg_code);
    if x_return_status = FND_API.G_RET_STS_ERROR then
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => l_error_msg_code);
    end if;

/* check to see if the budget version is in the submitted status.  we cannot */
/* regenerate the budget version if it's in the submitted status. */
    /** MOAC Changes:4510784
    select
        budget_status_code
    into
        l_budget_status_code
    from
        pa_budget_versions
    where
        budget_version_id=p_budget_version_id;
    **/
    -- get org id to initiaize before submit the fnd request
    SELECT  pp.org_id
        ,bv.budget_status_code
        INTO    l_org_id
        ,l_budget_status_code
        FROM    pa_projects_all pp
            ,pa_budget_versions bv
        WHERE   pp.project_id = bv.project_id
    AND     bv.budget_version_id = p_budget_version_id;
    /* End of bug fix:4510784 */

    if l_budget_status_code = 'S' then
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_REGEN_SUBMITTED');
    end if;

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

/* If There are NO Business Rules Violations , Then proceed with Regenerate */
    if l_msg_count = 0 then
        SAVEPOINT PA_FIN_PLAN_PUB_REGENERATE;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('no business logic errors; proceeding with regenerate');
        END IF;
        /* submit the concurrent request to generate the forecast */
        /* will need to FND_REQUEST.set_mode if submit_request is called from database trigger */

        /* SUBMIT THE REQUEST ONLY WHEN version_type = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST */
       /* Moac changes:4510784 initialize org id before submitting the request for single org context */
        MO_GLOBAL.INIT('PA');
            If P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.Log_Message(p_message => 'Calling MO_GLOBAL.SET_POLICY_CONTEXT for OrgId:'||l_org_id);
            End If;
            MO_GLOBAL.SET_POLICY_CONTEXT('S',l_org_id);
        FND_REQUEST.SET_ORG_ID(l_org_id);
            l_request_id := FND_REQUEST.submit_request
               (application                =>   'PA',
                program                    =>   'PAFPORGF',   /* refer to HLD: Generate Organization Forecast */
                description                =>   NULL,
                start_time                 =>   NULL,
                sub_request                =>   false,
                argument1                  =>   NULL,
                argument2                  =>   NULL,
                argument3                  =>   NULL,
                argument4                  =>   NULL,
                argument5                  =>   NULL,
                argument6                  =>   p_budget_version_id);
            if l_request_id = 0 then
                x_return_status := FND_API.G_RET_STS_ERROR;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write_file('Regenerate: ' || 'l_request_id=0; ERROR');
                END IF;
                /* FND_MESSAGE.RETRIEVE; */
                l_msg_data := FND_MESSAGE.GET;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write_file('Regenerate: ' || 'the error message is ' || l_msg_data);
                END IF;
                /* PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                     p_msg_name            => FND_MESSAGE.GET); */
                l_msg_count := 1;
                /*l_msg_count := FND_MSG_PUB.count_msg;*/
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
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
            else
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write_file('Regenerate: ' || 'concurrent process submitted successfully; stamping request_id');
                END IF;
                update
                    pa_budget_versions
                set
                    request_id = l_request_id,
                    plan_processing_code = PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P,     /* "Generation in process" */
                    record_version_number = record_version_number + 1
                where
                    budget_version_id = p_budget_version_id;
            end if;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            pa_debug.reset_err_stack;
    end if;

exception
    when pa_fin_plan_pub.rollback_on_error then
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('Regenerate: rollback_on_error exception');
      END IF;
      rollback to PA_FIN_PLAN_PUB_REGENERATE;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;

    when others then
        rollback to PA_FIN_PLAN_PUB_REGENERATE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_PUB',
                                 p_procedure_name   => 'Regenerate');
        pa_debug.reset_err_stack;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
end Regenerate;

/* ------------------------------------------------------------------------- */

procedure Update_Version
    (p_project_id                   IN     pa_budget_versions.project_id%TYPE
     ,p_budget_version_id            IN     pa_budget_versions.budget_version_id%TYPE
     ,p_record_version_number        IN     pa_budget_versions.record_version_number%TYPE
     ,p_version_name                 IN     pa_budget_versions.version_name%TYPE
     ,p_description                  IN     pa_budget_versions.description%TYPE
     ,p_change_reason_code           IN     pa_budget_versions.change_reason_code%TYPE
    -- Start of additional columns for Bug :- 3088010
    ,p_attribute_category               IN     pa_budget_versions.attribute_category%TYPE
    ,p_attribute1                       IN     pa_budget_versions.attribute1%TYPE
    ,p_attribute2                       IN     pa_budget_versions.attribute2%TYPE
    ,p_attribute3                       IN     pa_budget_versions.attribute3%TYPE
    ,p_attribute4                       IN     pa_budget_versions.attribute4%TYPE
    ,p_attribute5                       IN     pa_budget_versions.attribute5%TYPE
    ,p_attribute6                       IN     pa_budget_versions.attribute6%TYPE
    ,p_attribute7                       IN     pa_budget_versions.attribute7%TYPE
    ,p_attribute8                       IN     pa_budget_versions.attribute8%TYPE
    ,p_attribute9                       IN     pa_budget_versions.attribute9%TYPE
    ,p_attribute10                      IN     pa_budget_versions.attribute10%TYPE
    ,p_attribute11                      IN     pa_budget_versions.attribute11%TYPE
    ,p_attribute12                      IN     pa_budget_versions.attribute12%TYPE
    ,p_attribute13                      IN     pa_budget_versions.attribute13%TYPE
    ,p_attribute14                      IN     pa_budget_versions.attribute14%TYPE
    ,p_attribute15                      IN     pa_budget_versions.attribute15%TYPE
    -- End of additional columns for Bug :- 3088010
     ,x_return_status                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                        OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                         OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is
l_debug_mode      VARCHAR2(30);
l_valid_flag              VARCHAR2(1);
l_current_working_flag    pa_budget_versions.current_working_flag%TYPE;
l_record_version_number   pa_budget_versions.record_version_number%TYPE;

l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_error_msg_code  VARCHAR2(30);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);

begin
    FND_MSG_PUB.initialize;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PA_FIN_PLAN_PUB.Update_Version');
    END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Update_Version: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;
/* CHECK FOR BUSINESS RULES VIOLATIONS */
    /* check for null budget_version_id */
    if p_budget_version_id is NULL then
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_NO_PLAN_VERSION');
    end if;
    /* check to see if the budget version we're updating to be current working has */
    /* been updated by someone else already */
    PA_FIN_PLAN_UTILS.Check_Record_Version_Number
            (p_unique_index             => p_budget_version_id,
             p_record_version_number    => p_record_version_number,
             x_valid_flag               => l_valid_flag,
             x_return_status            => l_return_status,
             x_error_msg_code           => l_error_msg_code);
    if x_return_status = FND_API.G_RET_STS_ERROR then
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => l_error_msg_code);
    end if;

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

/* If There are NO Business Rules Violations , Then proceed with Update Version */
    if l_msg_count = 0 then
        SAVEPOINT PA_FIN_PLAN_PUB_UPDATE_VERSION;
        l_record_version_number := p_record_version_number + 1;

        UPDATE
            PA_BUDGET_VERSIONS
        SET
            record_version_number       = l_record_version_number,
            version_name                = p_version_name,
            description                 = p_description,
            change_reason_code          = p_change_reason_code,
            last_update_date            = SYSDATE,
            last_updated_by             = FND_GLOBAL.user_id,
            last_update_login           = FND_GLOBAL.login_id,
            /* Code addition for bug 3088010 starts */
            attribute_category          = p_attribute_category,
            attribute1                  = p_attribute1,
            attribute2                  = p_attribute2,
            attribute3                  = p_attribute3,
            attribute4                  = p_attribute4,
            attribute5                  = p_attribute5,
            attribute6                  = p_attribute6,
            attribute7                  = p_attribute7,
            attribute8                  = p_attribute8,
            attribute9                  = p_attribute9,
            attribute10                 = p_attribute10,
            attribute11                 = p_attribute11,
            attribute12                 = p_attribute12,
            attribute13                 = p_attribute13,
            attribute14                 = p_attribute14,
            attribute15                 = p_attribute15
            /* Code addition for bug 3088010 ends */
        WHERE
            budget_version_id           = p_budget_version_id;
    end if;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.reset_err_stack;

exception
    when others then
      rollback to PA_FIN_PLAN_PUB_UPDATE_VERSION;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_PUB',
                               p_procedure_name   => 'Update_Version');
      pa_debug.reset_err_stack;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
end Update_Version;
/*========================================================================
  Bug no.:- 2331201
  This api is called from Copy_version and called only in the case of '
  ORG_FORECAST'
=========================================================================*/
procedure Create_Org_Fcst_Elements (
    p_project_id               IN      pa_projects_all.project_id%TYPE,
    p_source_version_id        IN      pa_budget_versions.budget_version_id%TYPE,
    p_target_version_id        IN      pa_budget_versions.budget_version_id%TYPE,
    x_return_status               OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count                   OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data                    OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

AS

l_debug_mode      VARCHAR2(30);
l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_error_msg_code  VARCHAR2(30);
l_msg_index_out   NUMBER;


l_resource_assignment_id    pa_resource_assignments.resource_assignment_id%TYPE;
l_forecast_element_id       pa_org_forecast_lines.forecast_element_id%TYPE;
l_adj_element_id            pa_fp_adj_elements.adj_element_id%TYPE;

cursor l_ra_csr is
    select
        resource_assignment_id
    from
        pa_resource_assignments
    where
        budget_version_id=p_source_version_id;

l_ra_rec l_ra_csr%ROWTYPE;

cursor l_fe_csr is
    select
        forecast_element_id
    from
        pa_org_fcst_elements
    where
        budget_version_id=p_source_version_id;

l_fe_rec l_fe_csr%ROWTYPE;

cursor l_fl_csr is
    select
        forecast_line_id
    from
        pa_org_forecast_lines
    where
        forecast_element_id=l_fe_rec.forecast_element_id;

l_fl1_rec l_fl_csr%ROWTYPE;

cursor l_ae_csr is
    select
        adj_element_id
    from
        pa_fp_adj_elements
    where
        budget_version_id = p_source_version_id and
        resource_assignment_id = l_ra_rec.resource_assignment_id;

l_ae_rec l_ae_csr%ROWTYPE;

begin

     pa_debug.set_err_stack ('PA_FIN_PLAN_PUB.Create_Org_Fcst_Elements');
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('Create_Org_Fcst_Elements: ' || 'PLSQL','LOG',l_debug_mode);
     END IF;
     x_msg_count := 0;

     /* CHECK FOR BUSINESS RULES VIOLATIONS */
         /* check for null budget_version_id */
         if (p_source_version_id is null)  or (p_target_version_id is null) then
             x_return_status := FND_API.G_RET_STS_ERROR;
             PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                  p_msg_name            => 'PA_FP_NO_PLAN_VERSION');
         end if;

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

     /* If there are no Business Rules violations, then continue with Create_Org_Fcst_Elements */
     if l_msg_count = 0 then
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('Create_Org_Fcst_Elements: ' || 'no business violations; continuing with create org fcst elements');
           END IF;

           x_return_status    := FND_API.G_RET_STS_SUCCESS;

           open l_ra_csr;
           loop
               fetch l_ra_csr into l_ra_rec;
               exit when l_ra_csr%NOTFOUND;

               --Fetch corresponding target resource assignment id from pa_fp_ra_map_tmp

               select target_res_assignment_id
               into   l_resource_assignment_id
               from   pa_fp_ra_map_tmp
               where  source_res_assignment_id = l_ra_rec.resource_assignment_id;

               /* PA_FP_ADJ_ELEMENTS: Insert new row for all existing rows with the same budget_version_id */
               open l_ae_csr;
               loop
                       fetch l_ae_csr into l_ae_rec;
                       exit when l_ae_csr%NOTFOUND;
                       select pa_fp_adj_elements_s.nextVal into l_adj_element_id from dual;
                       insert into pa_fp_adj_elements(
                           adj_element_id,
                           project_id,
                           budget_version_id,
                           resource_assignment_id,
                           task_id,
                            adjustment_reason_code,
                            adjustment_comments,
                            creation_date,
                            created_by,
                            last_update_login,
                            last_updated_by,
                            last_update_date)
                      select
                            l_adj_element_id,       /* use newly-created adj_element_id */
                            ae.project_id,
                            p_target_version_id,    /* use newly-created budget_version_id */
                            l_resource_assignment_id,   /* use newly-created resource_assignment_id */
                            ae.task_id,
                            ae.adjustment_reason_code,
                            ae.adjustment_comments,
                            SYSDATE,                /* creation_date */
                            FND_GLOBAL.user_id,     /* created_by */
                            FND_GLOBAL.login_id,    /* last_update_login */
                            FND_GLOBAL.user_id,     /* last_updated_by */
                            SYSDATE                 /* last_update_date */
                      from
                               pa_fp_adj_elements ae
                      where
                               ae.adj_element_id = l_ae_rec.adj_element_id;
                      /* PA_FIN_PLAN_ADJ_LINES: Insert new row for all rows with the old adj_element_id*/
                      insert into pa_fin_plan_adj_lines (
                                    adj_element_id,
                                    creation_date,
                                    created_by,
                                    last_update_login,
                                    last_updated_by,
                                    last_update_date,
                                    fin_plan_adj_line_id,
                                    project_id,
                                    task_id,
                                    budget_version_id,
                                    resource_assignment_id,
                                    period_name,
                                    start_date,
                                    end_date,
                                    raw_cost_adjustment,
                                    burdened_cost_adjustment,
                                    revenue_adjustment,
                                    utilization_adjustment,
                                    head_count_adjustment)
                      select
                                    l_adj_element_id,               /* use newly-created adj_element_id */
                                    SYSDATE,                        /* creation_date */
                                    FND_GLOBAL.user_id,             /* created_by */
                                    FND_GLOBAL.login_id,            /* last_update_login */
                                    FND_GLOBAL.user_id,             /* last_updated_by */
                                    SYSDATE,                        /* last_update_date */
                                    pa_fin_plan_adj_lines_s.nextVal, /* use nextVal for fin_plan_adj_line_id */
                                    al.project_id,
                                    al.task_id,
                                    p_target_version_id,            /* use newly-created budget_version_id */
                                    l_resource_assignment_id,       /* use newly-created resource assignment id */
                                    al.period_name,
                                    al.start_date,
                                    al.end_date,
                                    al.raw_cost_adjustment,
                                    al.burdened_cost_adjustment,
                                    al.revenue_adjustment,
                                    al.utilization_adjustment,
                                    al.head_count_adjustment
                      from
                                    pa_fin_plan_adj_lines al
                      where
                                   al.adj_element_id=l_ae_rec.adj_element_id;



                      /* PA_PROJECT_PERIODS_DENORM: Insert a new row for every record whose budget_version_id and
                         resource_assignment_id match our old ones */
                      /* key on OBJECT_ID = adj_element_id of the original version */
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write_file('Create_Org_Fcst_Elements: ' || 'inserting into pa_project_periods_denorm');
                      END IF;
                      insert into pa_proj_periods_denorm (
                          creation_date,
                          created_by,
                          last_update_login,
                          last_updated_by,
                          last_update_date,
                          budget_version_id,
                          resource_assignment_id,
                          object_id,
                          object_type_code,
                          period_profile_id,
                          amount_type_code,
                          amount_subtype_code,
                          amount_type_id,
                          amount_subtype_id,
                          currency_type,
                          currency_code,
                          preceding_periods_amount,
                          succeeding_periods_amount,
                          prior_period_amount,
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
                          period_amount14,
                          period_amount15,
                          period_amount16,
                          period_amount17,
                          period_amount18,
                          period_amount19,
                          period_amount20,
                          period_amount21,
                          period_amount22,
                          period_amount23,
                          period_amount24,
                          period_amount25,
                          period_amount26,
                          period_amount27,
                          period_amount28,
                          period_amount29,
                          period_amount30,
                          period_amount31,
                          period_amount32,
                          period_amount33,
                          period_amount34,
                          period_amount35,
                          period_amount36,
                          period_amount37,
                          period_amount38,
                          period_amount39,
                          period_amount40,
                          period_amount41,
                          period_amount42,
                          period_amount43,
                          period_amount44,
                          period_amount45,
                          period_amount46,
                          period_amount47,
                          period_amount48,
                          period_amount49,
                          period_amount50,
                          period_amount51,
                          period_amount52,
                          project_id,
                          parent_assignment_id)
                      select
                          SYSDATE,                            /* creation_date */
                          FND_GLOBAL.user_id,                 /* created_by */
                          FND_GLOBAL.login_id,                /* last_update_login */
                          FND_GLOBAL.user_id,                 /* last_updated_by */
                          SYSDATE,                            /* last_update_date */
                          p_target_version_id,                /* use newly-created budget_version_id */
                          ppd.resource_assignment_id,   /* copy over resource_assignment_id */
                          l_adj_element_id,           /* object_id is the newly-created adj_element_id */
                          ppd.object_type_code,
                          ppd.period_profile_id,
                          ppd.amount_type_code,
                          ppd.amount_subtype_code,
                          ppd.amount_type_id,
                          ppd.amount_subtype_id,
                          ppd.currency_type,
                          ppd.currency_code,
                          ppd.preceding_periods_amount,
                          ppd.succeeding_periods_amount,
                          ppd.prior_period_amount,
                          ppd.period_amount1,
                          ppd.period_amount2,
                          ppd.period_amount3,
                          ppd.period_amount4,
                          ppd.period_amount5,
                          ppd.period_amount6,
                          ppd.period_amount7,
                          ppd.period_amount8,
                          ppd.period_amount9,
                          ppd.period_amount10,
                          ppd.period_amount11,
                          ppd.period_amount12,
                          ppd.period_amount13,
                          ppd.period_amount14,
                          ppd.period_amount15,
                          ppd.period_amount16,
                          ppd.period_amount17,
                          ppd.period_amount18,
                          ppd.period_amount19,
                          ppd.period_amount20,
                          ppd.period_amount21,
                          ppd.period_amount22,
                          ppd.period_amount23,
                          ppd.period_amount24,
                          ppd.period_amount25,
                          ppd.period_amount26,
                          ppd.period_amount27,
                          ppd.period_amount28,
                          ppd.period_amount29,
                          ppd.period_amount30,
                          ppd.period_amount31,
                          ppd.period_amount32,
                          ppd.period_amount33,
                          ppd.period_amount34,
                          ppd.period_amount35,
                          ppd.period_amount36,
                          ppd.period_amount37,
                          ppd.period_amount38,
                          ppd.period_amount39,
                          ppd.period_amount40,
                          ppd.period_amount41,
                          ppd.period_amount42,
                          ppd.period_amount43,
                          ppd.period_amount44,
                          ppd.period_amount45,
                          ppd.period_amount46,
                          ppd.period_amount47,
                          ppd.period_amount48,
                          ppd.period_amount49,
                          ppd.period_amount50,
                          ppd.period_amount51,
                          ppd.period_amount52,
                          p_project_id, --passed value
                          NULL    --Org_Forecast doesn't have rollup
                      from
                          pa_proj_periods_denorm ppd
                      where
                          ppd.budget_version_id = p_source_version_id and
                          ppd.object_id = l_ae_rec.adj_element_id;

               end loop; -- l_ae_csr
               close l_ae_csr;

           end loop; -- l_ra_csr
           close l_ra_csr;



          /* PA_ORG_FCST_ELEMENTS: Insert a new row for each row that contained the old budget version */
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('Create_Org_Fcst_Elements: ' || 'insert into pa_org_forecast_elements');
           END IF;
           open l_fe_csr;
           loop
                  /* generate next forecast_element_id into local variable */
                  select pa_org_fcst_elements_s.nextVal into l_forecast_element_id from dual;
                  fetch l_fe_csr into l_fe_rec;
                  exit when l_fe_csr%NOTFOUND;
                  insert into pa_org_fcst_elements (
                      creation_date,
                      created_by,
                      last_update_login,
                      last_updated_by,
                      last_update_date,
                      forecast_element_id,
                      organization_id,
                      org_id,
                      budget_version_id,
                      project_id,
                      task_id,
                      provider_receiver_code,
                      other_organization_id,
                      other_org_id,
                      txn_project_id,
                      assignment_id,
                      resource_id,
                      record_version_number)
                  select
                      SYSDATE,                        /* creation_date */
                      FND_GLOBAL.user_id,             /* created_by */
                      FND_GLOBAL.login_id,            /* last_update_login */
                      FND_GLOBAL.user_id,             /* last_updated_by */
                      SYSDATE,                        /* last_update_date */
                      l_forecast_element_id,  /* use newly-generated forecast_element_id */
                      fe.organization_id,
                      fe.org_id,
                      p_target_version_id,            /* use newly-generated budget_version_id */
                      fe.project_id,
                      fe.task_id,
                      fe.provider_receiver_code,
                      fe.other_organization_id,
                      fe.other_org_id,
                      fe.txn_project_id,
                      fe.assignment_id,
                      fe.resource_id,
                      1                               /* record_version_number = 1 */
                  from
                      pa_org_fcst_elements fe
                  where
                      forecast_element_id=l_fe_rec.forecast_element_id;
                  /* PA_ORG_FORECAST_LINES: create a new row for every row whose forecast_element_id matches
                     the one we're using */
                  open l_fl_csr;
                  loop
                      fetch l_fl_csr into l_fl1_rec;
                      exit when l_fl_csr%NOTFOUND;
                      insert into pa_org_forecast_lines (
                          creation_date,
                          created_by,
                          last_update_login,
                          last_updated_by,
                          last_update_date,
                          forecast_line_id,
                          forecast_element_id,
                          project_id,
                          task_id,
                          period_name,
                          start_date,
                          end_date,
                          quantity,
                          raw_cost,
                          burdened_cost,
                          tp_cost_in,
                          tp_cost_out,
                          revenue,
                          tp_revenue_in,
                          tp_revenue_out,
                          record_version_number,
                          borrowed_revenue,
                          lent_resource_cost,
                          unassigned_time_cost,
                          budget_version_id)
                      select
                          SYSDATE,                                /* creation_date */
                          FND_GLOBAL.user_id,                     /* created_by */
                          FND_GLOBAL.login_id,                    /* last_update_login */
                          FND_GLOBAL.user_id,                     /* last_updated_by */
                          SYSDATE,                                /* last_update_date */
                          pa_org_forecast_lines_s.nextVal,        /* use nextVal to generate next forecast_line_id */
                          l_forecast_element_id,                  /* use newly-created forecast_element_id */
                          fl.project_id,
                          fl.task_id,
                          fl.period_name,
                          fl.start_date,
                          fl.end_date,
                          fl.quantity,
                          fl.raw_cost,
                          fl.burdened_cost,
                          fl.tp_cost_in,
                          fl.tp_cost_out,
                          fl.revenue,
                          fl.tp_revenue_in,
                          fl.tp_revenue_out,
                          1,                                              /* record_version_number */
                          fl.borrowed_revenue,
                          fl.lent_resource_cost,
                          fl.unassigned_time_cost,
                          p_target_version_id
                      from
                          pa_org_forecast_lines fl
                      where
                          fl.forecast_line_id=l_fl1_rec.forecast_line_id;
                  end loop; /* PA_ORG_FORECAST_LINES */
                  close l_fl_csr;
                  /* PA_PROJECT_PERIODS_DENORM: Insert a new row for every record whose budget_version_id and resource_assignment_id match our old ones */
                  /* key on OBJECT_ID = forecast_element_id of the original version */
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('Create_Org_Fcst_Elements: ' || 'inserting into pa_project_periods_denorm');
                  END IF;
                  insert into pa_proj_periods_denorm (
                      creation_date,
                      created_by,
                      last_update_login,
                      last_updated_by,
                      last_update_date,
                      budget_version_id,
                      resource_assignment_id,
                      object_id,
                      object_type_code,
                      period_profile_id,
                      amount_type_code,
                      amount_subtype_code,
                      amount_type_id,
                      amount_subtype_id,
                      currency_type,
                      currency_code,
                      preceding_periods_amount,
                      succeeding_periods_amount,
                      prior_period_amount,
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
                      period_amount14,
                      period_amount15,
                      period_amount16,
                      period_amount17,
                      period_amount18,
                      period_amount19,
                      period_amount20,
                      period_amount21,
                      period_amount22,
                      period_amount23,
                      period_amount24,
                      period_amount25,
                      period_amount26,
                      period_amount27,
                      period_amount28,
                      period_amount29,
                      period_amount30,
                      period_amount31,
                      period_amount32,
                      period_amount33,
                      period_amount34,
                      period_amount35,
                      period_amount36,
                      period_amount37,
                      period_amount38,
                      period_amount39,
                      period_amount40,
                      period_amount41,
                      period_amount42,
                      period_amount43,
                      period_amount44,
                      period_amount45,
                      period_amount46,
                      period_amount47,
                      period_amount48,
                      period_amount49,
                      period_amount50,
                      period_amount51,
                      period_amount52,
                      project_id,
                      parent_assignment_id)
                  select
                      SYSDATE,                            /* creation_date */
                      FND_GLOBAL.user_id,                 /* created_by */
                      FND_GLOBAL.login_id,                /* last_update_login */
                      FND_GLOBAL.user_id,                 /* last_updated_by */
                      SYSDATE,                            /* last_update_date */
                      p_target_version_id,                /* use newly-created budget_version_id */
                      ppd.resource_assignment_id,         /* use the existing resource_assignment_id */
                      l_forecast_element_id,              /* object_id is the newly-created forecast_element_id */
                      ppd.object_type_code,
                      ppd.period_profile_id,
                      ppd.amount_type_code,
                      ppd.amount_subtype_code,
                      ppd.amount_type_id,
                      ppd.amount_subtype_id,
                      ppd.currency_type,
                      ppd.currency_code,
                      ppd.preceding_periods_amount,
                      ppd.succeeding_periods_amount,
                      ppd.prior_period_amount,
                      ppd.period_amount1,
                      ppd.period_amount2,
                      ppd.period_amount3,
                      ppd.period_amount4,
                      ppd.period_amount5,
                      ppd.period_amount6,
                      ppd.period_amount7,
                      ppd.period_amount8,
                      ppd.period_amount9,
                      ppd.period_amount10,
                      ppd.period_amount11,
                      ppd.period_amount12,
                      ppd.period_amount13,
                      ppd.period_amount14,
                      ppd.period_amount15,
                      ppd.period_amount16,
                      ppd.period_amount17,
                      ppd.period_amount18,
                      ppd.period_amount19,
                      ppd.period_amount20,
                      ppd.period_amount21,
                      ppd.period_amount22,
                      ppd.period_amount23,
                      ppd.period_amount24,
                      ppd.period_amount25,
                      ppd.period_amount26,
                      ppd.period_amount27,
                      ppd.period_amount28,
                      ppd.period_amount29,
                      ppd.period_amount30,
                      ppd.period_amount31,
                      ppd.period_amount32,
                      ppd.period_amount33,
                      ppd.period_amount34,
                      ppd.period_amount35,
                      ppd.period_amount36,
                      ppd.period_amount37,
                      ppd.period_amount38,
                      ppd.period_amount39,
                      ppd.period_amount40,
                      ppd.period_amount41,
                      ppd.period_amount42,
                      ppd.period_amount43,
                      ppd.period_amount44,
                      ppd.period_amount45,
                      ppd.period_amount46,
                      ppd.period_amount47,
                      ppd.period_amount48,
                      ppd.period_amount49,
                      ppd.period_amount50,
                      ppd.period_amount51,
                      ppd.period_amount52,
                      p_project_id, /* project_id */
                      NULL --as Org_Fcst doen't have rollup
                  from
                      pa_proj_periods_denorm ppd
                  where
                      ppd.budget_version_id = p_source_version_id and
                      ppd.object_id = l_fe_rec.forecast_element_id;

           end loop; /* l_fe_csr*/
           close l_fe_csr;

        pa_debug.reset_err_stack;
    end if;

exception

    when others then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_PUB',
                                 p_procedure_name   => 'Create_Org_Fcst_Elements');
        pa_debug.reset_err_stack;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;

end create_org_fcst_elements;


/*=====================================================================
  Bug No. 2331201 For finplan this api has been added
  This api Creates a working fin plan version.The version inherits its
  properties from plan type.This api creates records in
  pa_proj_fp_options , pa_resource_assignments,
  pa_fp_txn_currencies and pa_budget_versions.
  If px_budget_version_id is passed it is assumed that new version
  id is created and passed to the api, else new value is created.

--    26-JUN-2003 jwhite        - Plannable Task Dev Effort:
--                                Make code changes to Create_Version procedure to
--                                enable population of new parameters on
--                                PA_FP_BUDGET_VERSIONS_PKG.Insert_Row table handler.

--
--    01-JUL-2003 jwhite        - bug 2989874
--                                For Create_Version procedure, default ci from the current
--                                working version.

--    07-JUL-2003 jwhite        - bug 2989874:
--                                As per IDC UT, made numerous modifications to the
--                                Create_Version procedure.

--    30-SEP-2003 rravipat      - bug 3165956
--                                if p_time_phased_code is passed as
--                                'P', l_time_phased_code should be 'PA'
--                                'G', l_time_phased_code should be 'GL'
--                                as this value is used to fetch period_profile_id

--    31-MAY-2004 rravipat      - bug 3658232
--                                For finplan, when new version is being created all
--                                the setup should be inherited from parent
--                                plan type. Resource assignments data should be
--                                copied from current working version if planning
--                                level and resource list match. Else default
--                                planning elements are created

--    21-SEP-2004 rravipat      - bug 3867302
--                                For ci versions reporting data is not maintained
--    06-DEC-2004 dlai    - bug 3831449
--          do not create records in pa_resource_assignments
--          if p_calling_context is GENERATE

--    07-Nov-2005 dbora           Bug 4724017: Redone the fix done for bug 4534591
--                                in 11.5 as CDM Enhancement.
--                                Changes made to avoid creating default planning
--                                transactions, if the version being created uses
--                                a categorized resource list. This is a deviation
--                                from the update 1-MAY-2004 rravipat - bug 3658232
--                                Please look at the bug for details.
=====================================================================*/

PROCEDURE Create_Version (
    p_project_id                        IN     NUMBER
    ,p_fin_plan_type_id                 IN     NUMBER
    ,p_element_type                     IN     VARCHAR2
    ,p_version_name                     IN     VARCHAR2
    ,p_description                      IN     VARCHAR2
    -- Start of additional columns for Bug :- 2634900
    ,p_ci_id                            IN     pa_budget_versions.ci_id%TYPE                    --:= NULL
    ,p_est_proj_raw_cost                IN     pa_budget_versions.est_project_raw_cost%TYPE     --:= NULL
    ,p_est_proj_bd_cost                 IN     pa_budget_versions.est_project_burdened_cost%TYPE--:= NULL
    ,p_est_proj_revenue                 IN     pa_budget_versions.est_project_revenue%TYPE      --:= NULL
    ,p_est_qty                          IN     pa_budget_versions.est_quantity%TYPE             --:= NULL
    ,p_est_equip_qty                    IN     pa_budget_versions.est_equipment_quantity%TYPE   --:= NULL FP.M
    ,p_impacted_task_id                 IN     pa_tasks.task_id%TYPE                            --:= NULL
    ,p_agreement_id                     IN     pa_budget_versions.agreement_id%TYPE             --:= NULL
    ,p_calling_context                  IN     VARCHAR2                                         --:= NULL
    -- End of additional columns for Bug :- 2634900
    -- Start of additional columns for Bug :- 2649474
    ,p_resource_list_id                 IN     pa_budget_versions.resource_list_id%TYPE         --:= NULL
    ,p_time_phased_code                 IN     pa_proj_fp_options.cost_time_phased_code%TYPE    --:= NULL
    ,p_fin_plan_level_code              IN     pa_proj_fp_options.cost_fin_plan_level_code%TYPE --:= NULL
    ,p_plan_in_multi_curr_flag          IN     pa_proj_fp_options.plan_in_multi_curr_flag%TYPE  --:= NULL
    ,p_amount_set_id                    IN     pa_proj_fp_options.cost_amount_set_id%TYPE       --:= NULL
    -- End of additional columns for Bug :- 2649474
    -- Start of additional columns for Bug :- 3088010
    ,p_attribute_category               IN     pa_budget_versions.attribute_category%TYPE
    ,p_attribute1                       IN     pa_budget_versions.attribute1%TYPE
    ,p_attribute2                       IN     pa_budget_versions.attribute2%TYPE
    ,p_attribute3                       IN     pa_budget_versions.attribute3%TYPE
    ,p_attribute4                       IN     pa_budget_versions.attribute4%TYPE
    ,p_attribute5                       IN     pa_budget_versions.attribute5%TYPE
    ,p_attribute6                       IN     pa_budget_versions.attribute6%TYPE
    ,p_attribute7                       IN     pa_budget_versions.attribute7%TYPE
    ,p_attribute8                       IN     pa_budget_versions.attribute8%TYPE
    ,p_attribute9                       IN     pa_budget_versions.attribute9%TYPE
    ,p_attribute10                      IN     pa_budget_versions.attribute10%TYPE
    ,p_attribute11                      IN     pa_budget_versions.attribute11%TYPE
    ,p_attribute12                      IN     pa_budget_versions.attribute12%TYPE
    ,p_attribute13                      IN     pa_budget_versions.attribute13%TYPE
    ,p_attribute14                      IN     pa_budget_versions.attribute14%TYPE
    ,p_attribute15                      IN     pa_budget_versions.attribute15%TYPE
    -- End of additional columns for Bug :- 3088010
    ,px_budget_version_id               IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,p_struct_elem_version_id           IN     pa_proj_element_versions.element_version_id%TYPE --For Bug 3354518
    ,p_pm_product_code                  IN pa_budget_versions.pm_product_code%TYPE DEFAULT NULL
    ,p_finplan_reference                IN pa_budget_versions.pm_budget_reference%TYPE DEFAULT NULL
    ,p_change_reason_code               IN pa_budget_versions.change_reason_code%TYPE DEFAULT NULL
    ,p_pji_rollup_required              IN VARCHAR2                                   DEFAULT 'Y'  --Bug 4200168
    ,x_proj_fp_option_id                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status                       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                            OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
AS

    l_module_name varchar2(30):= 'pa.plsql.pa_fin_plan_pub';

     -- Start of variables used for debugging purpose

     l_msg_count          NUMBER :=0;
     l_data               VARCHAR2(2000);
     l_msg_data           VARCHAR2(2000);
     l_error_msg_code     VARCHAR2(30);
     l_msg_index_out      NUMBER;
     l_return_status      VARCHAR2(2000);
     l_debug_mode         VARCHAR2(30);

     -- End of variables used for debugging purpose

     l_max_version_number               pa_budget_versions.version_number%TYPE;
     l_new_budget_version_id            pa_budget_versions.budget_version_id%TYPE;
     l_current_working_flag             pa_budget_versions.current_working_flag%TYPE;
     l_dummy_version_id                 pa_budget_versions.budget_version_id%TYPE;
     l_new_proj_fp_options_id           pa_proj_fp_options.proj_fp_options_id%TYPE;
     l_project_currency_code            pa_projects_all.project_currency_code%TYPE;
     l_projfunc_currency_code           pa_projects_all.projfunc_currency_code%TYPE;
     l_dummy_currency_code              pa_projects_all.projfunc_currency_code%TYPE;
     l_est_projfunc_raw_cost            pa_budget_versions.est_projfunc_raw_cost%TYPE;
     l_est_projfunc_bd_cost             pa_budget_versions.est_projfunc_burdened_cost%TYPE;
     l_est_projfunc_revenue             pa_budget_versions.est_projfunc_revenue%TYPE;
     l_est_project_raw_cost             pa_budget_versions.est_project_raw_cost%TYPE;
     l_est_project_bd_cost              pa_budget_versions.est_project_burdened_cost%TYPE;
     l_est_project_revenue              pa_budget_versions.est_project_revenue%TYPE;
     l_agreement_num                    pa_agreements_all.agreement_num%TYPE;
     l_agreement_amount                 pa_agreements_all.amount%TYPE;
     l_agreement_currency_code          pa_agreements_all.agreement_currency_code%TYPE;

     --l_mixed_resource_planned_flag      VARCHAR2(1); --Added for Bug:-2625872

     l_plan_type_mc_flag          pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;  --Bug 2661237

     /* Project level conversion attributes var for bug 2661237 */

        l_multi_currency_billing_flag           pa_projects_all.multi_currency_billing_flag%TYPE;
        l_baseline_funding_flag                 pa_projects_all.baseline_funding_flag%TYPE;
        l_revproc_currency_code                 pa_projects_all.revproc_currency_code%TYPE;
        l_invproc_currency_type                 pa_projects_all.invproc_currency_type%TYPE;
        l_invproc_currency_code                 pa_projects_all.revproc_currency_code%TYPE;
        l_project_bil_rate_date_code            pa_projects_all.project_bil_rate_date_code%TYPE;
        l_project_bil_rate_type                 pa_projects_all.project_bil_rate_type%TYPE;
        l_project_bil_rate_date                 pa_projects_all.project_bil_rate_date%TYPE;
        l_project_bil_exchange_rate             pa_projects_all.project_bil_exchange_rate%TYPE;
        l_projfunc_bil_rate_date_code           pa_projects_all.projfunc_bil_rate_date_code%TYPE;
        l_projfunc_bil_rate_type                pa_projects_all.projfunc_bil_rate_type%TYPE;
        l_projfunc_bil_rate_date                pa_projects_all.projfunc_bil_rate_date%TYPE;
        l_projfunc_bil_exchange_rate            pa_projects_all.projfunc_bil_exchange_rate%TYPE;
        l_funding_rate_date_code                pa_projects_all.funding_rate_date_code%TYPE;
        l_funding_rate_type                     pa_projects_all.funding_rate_type%TYPE;
        l_funding_rate_date                     pa_projects_all.funding_rate_date%TYPE;
        l_funding_exchange_rate                 pa_projects_all.funding_exchange_rate%TYPE;

      /* End of variable definition for bug 2661237 */

     l_res_list_uncategorized_flag   VARCHAR2(1);
     l_res_list_control_flag         VARCHAR2(1);
     l_gl_start_period               gl_periods.period_name%TYPE;
     l_gl_end_period                 gl_periods.period_name%TYPE;
     l_gl_start_Date                 VARCHAR2(100);
     l_pa_start_period               pa_periods_all.period_name%TYPE;
     l_pa_end_period                 pa_periods_all.period_name%TYPE;
     l_pa_start_date                 VARCHAR2(100);
     l_plan_version_exists_flag      VARCHAR2(1);
     l_prj_start_date                VARCHAR2(100);
     l_prj_end_date                  VARCHAR2(100);
     l_budget_version_ids            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

     -- 01-JUL-2003 Default ci from current working version (bug 2989874)
       l_ci_apprv_cw_bv_id              pa_budget_versions.budget_version_id%TYPE  :=NULL;

      -- Added by pseethar. Used for workplan flag, derivered from pa_fin_plan_types_b
       l_WP_VERSION_FLAG   pa_fin_plan_types_b.USE_FOR_WORKPLAN_FLAG%TYPE;

CURSOR  plan_type_info_cur (
  c_project_id       NUMBER,
  c_fin_plan_type_id NUMBER )IS
SELECT  proj_fp_options_id
       ,project_id
       ,fin_plan_option_level_code
       ,fin_plan_preference_code
       ,plan_in_multi_curr_flag
       ,approved_cost_plan_type_flag
       ,approved_rev_plan_type_flag
       ,all_fin_plan_level_code
       ,all_time_phased_code
       ,all_resource_list_id
       ,all_amount_set_id
       ,all_current_planning_period
       ,all_period_mask_id
       ,RBS_VERSION_ID
       ,select_all_res_auto_flag
       ,cost_fin_plan_level_code
       ,cost_time_phased_code
       ,cost_resource_list_id
       ,cost_amount_set_id
       ,select_cost_res_auto_flag
       ,cost_current_planning_period
       ,cost_period_mask_id
       ,revenue_fin_plan_level_code
       ,revenue_resource_list_id
       ,revenue_time_phased_code
       ,revenue_amount_set_id
       ,select_rev_res_auto_flag
       ,primary_cost_forecast_flag
       ,primary_rev_forecast_flag
       ,rev_current_planning_period
       ,rev_period_mask_id
       ,copy_etc_from_plan_flag --skkoppul bug 8318932 - added  for AAI enhancement
FROM   pa_proj_fp_options
WHERE  project_id = c_project_id
  AND  fin_plan_type_id = c_fin_plan_type_id
  AND  fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_TYPE;

plan_type_info_rec plan_type_info_cur%ROWTYPE;

CURSOR  plan_version_info_cur (
  c_project_id       NUMBER,
  c_fin_plan_type_id NUMBER,
  c_fin_plan_version_id NUMBER  )IS
SELECT   pfo.proj_fp_options_id
       , pfo.project_id
       , pfo.fin_plan_option_level_code
       , pfo.fin_plan_preference_code
       , pfo.plan_in_multi_curr_flag
       , pfo.approved_cost_plan_type_flag
       , pfo.approved_rev_plan_type_flag
       , pfo.all_fin_plan_level_code
       , pfo.all_time_phased_code
       , pfo.all_resource_list_id
       , pfo.all_amount_set_id
       , pfo.all_current_planning_period
       , pfo.all_period_mask_id
       , pfo.rbs_version_id
       , pfo.select_all_res_auto_flag
       , pfo.cost_fin_plan_level_code
       , pfo.cost_time_phased_code
       , pfo.cost_resource_list_id
       , pfo.cost_amount_set_id
       , pfo.select_cost_res_auto_flag
       , pfo.cost_current_planning_period
       , pfo.cost_period_mask_id
       , pfo.revenue_fin_plan_level_code
       , pfo.revenue_resource_list_id
       , pfo.revenue_time_phased_code
       , pfo.revenue_amount_set_id
       , pfo.select_rev_res_auto_flag
       , pfo.rev_current_planning_period
       , pfo.rev_period_mask_id
       , pfo.primary_cost_forecast_flag
       , pfo.primary_rev_forecast_flag
       , bv.actual_amts_thru_period
       , bv.project_structure_version_id
FROM   pa_proj_fp_options pfo, pa_budget_versions bv
WHERE  pfo.project_id = c_project_id
  AND  pfo.fin_plan_type_id = c_fin_plan_type_id
  AND  pfo.fin_plan_version_id = c_fin_plan_version_id
  AND  bv.budget_version_id =  c_fin_plan_version_id
  AND  fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION;

plan_version_info_rec  plan_version_info_cur%ROWTYPE;

TYPE new_version_rec_type IS RECORD (
   fin_plan_option_level_code     PA_PROJ_FP_OPTIONS.fin_plan_option_level_code%TYPE
  ,fin_plan_preference_code       PA_PROJ_FP_OPTIONS.fin_plan_preference_code%TYPE
  ,fin_plan_level_code            PA_PROJ_FP_OPTIONS.cost_fin_plan_level_code%TYPE
  ,time_phased_code               PA_PROJ_FP_OPTIONS.cost_time_phased_code%TYPE
  ,resource_list_id               PA_PROJ_FP_OPTIONS.cost_resource_list_id%TYPE
  ,amount_set_id                  PA_PROJ_FP_OPTIONS.cost_amount_set_id%TYPE
  ,current_planning_period        PA_PROJ_FP_OPTIONS.cost_CURRENT_PLANNING_PERIOD%TYPE
  ,period_mask_id                 PA_PROJ_FP_OPTIONS.cost_PERIOD_MASK_ID%TYPE
  ,plan_in_multi_curr_flag        PA_PROJ_FP_OPTIONS.plan_in_multi_curr_flag%TYPE
  ,approved_cost_plan_type_flag   PA_PROJ_FP_OPTIONS.approved_cost_plan_type_flag%TYPE
  ,approved_rev_plan_type_flag    PA_PROJ_FP_OPTIONS.approved_rev_plan_type_flag%TYPE
  ,select_res_auto_flag           PA_PROJ_FP_OPTIONS.select_cost_res_auto_flag%TYPE
  ,source_fp_options_id           PA_PROJ_FP_OPTIONS.PROJ_FP_OPTIONS_ID%TYPE
  ,version_type                   PA_BUDGET_VERSIONS.version_type%TYPE
  ,project_structure_version_id   PA_BUDGET_VERSIONS.project_structure_version_id%TYPE
  ,rbs_version_id                 PA_PROJ_FP_OPTIONS.rbs_version_id%TYPE
  ,primary_cost_forecast_flag     PA_BUDGET_VERSIONS.primary_cost_forecast_flag%TYPE
  ,primary_rev_forecast_flag      PA_BUDGET_VERSIONS.primary_rev_forecast_flag%TYPE
  ,actual_amts_thru_period        PA_BUDGET_VERSIONS.actual_amts_thru_period%TYPE := NULL
  );

new_version_info_rec    new_version_rec_type;

l_curr_work_ver_exists_flag         VARCHAR2(1);
l_fp_options_id                     pa_proj_fp_options.proj_fp_options_id%TYPE;
l_fin_plan_version_id               pa_proj_fp_options.fin_plan_version_id%TYPE;
l_cw_fin_plan_level_code            VARCHAR2(30);
l_cw_ver_res_list_id                NUMBER;
l_row_id                            rowid;
l_copy_res_assmt_from_cwv_flag      VARCHAR2(1);
     -- ---------------------------------------------------------------------------
l_src_bv_id_for_copying_ra          pa_budget_versions.budget_version_id%TYPE;

l_txn_source_id_tbl          SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_res_list_member_id_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_rbs_element_id_tbl         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_txn_accum_header_id_tbl    SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_pji_rollup_required       VARCHAR2(1);



BEGIN

     FND_MSG_PUB.initialize;
     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');
     pa_debug.set_curr_function( p_function => 'Create_Version',
                                 p_debug_mode => l_debug_mode );
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     -- Check for business rules violations

--Added this if for the bug 4200168
    IF p_pji_rollup_required = 'Y' THEN
        l_pji_rollup_required := 'Y';
    ELSE
        l_pji_rollup_required := 'N';
    END IF;


     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Validating input parameters';
         pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     -- Check if source and target fp option ids are null

     IF (p_project_id       IS NULL) OR
        (p_fin_plan_type_id IS NULL) OR
        (p_version_name IS NULL)
     THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Project_id = '||p_project_id;
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,5);
             pa_debug.g_err_stage:='Fin_plan_type_id = '||p_fin_plan_type_id;
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,5);
             pa_debug.g_err_stage:='Version_name = '||p_version_name;
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,5);
             pa_debug.g_err_stage:='Description = '||p_description;
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;

         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');


         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;

     --Bug 3354518. If the calling context is WORKPLAN and if p_struct_elem_version_id IS NULL then
     --Throw error
     IF (p_calling_context =PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN AND
         p_struct_elem_version_id IS NULL) THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='p_struct_elem_version_id in workplan context is'||p_struct_elem_version_id;
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;

     --Fetch plan type values

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Fetching plan type properties';
         pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     OPEN plan_type_info_cur(p_project_id,p_fin_plan_type_id);
     FETCH plan_type_info_cur INTO plan_type_info_rec;
     CLOSE plan_type_info_cur;

     --Raise an error if element type isn't passed for cost and rev separate plan type

     IF ( plan_type_info_rec.fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) AND
        (p_element_type IS NULL )
     THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Element_type input can not be null for this plan type';
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;

         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;

     IF (p_element_type IS NULL) THEN

          IF    plan_type_info_rec.fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY THEN

                new_version_info_rec.version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST;

          ELSIF plan_type_info_rec.fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY THEN

                new_version_info_rec.version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE;

          ELSIF plan_type_info_rec.fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME THEN

                new_version_info_rec.version_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL;

          END IF;
     ELSE
          new_version_info_rec.version_type := p_element_type;
     END IF;

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Element_type = '||new_version_info_rec.version_type;
        pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF ( p_ci_id IS NOT NULL )
     THEN
         -- Fetch current working approved budget version id
         Pa_Fp_Control_Items_Utils.CHK_APRV_CUR_WORKING_BV_EXISTS(
                  p_project_id       => p_project_id,
                  p_fin_plan_type_id => p_fin_plan_type_id,
                  p_version_type     => new_version_info_rec.version_type,
                  x_cur_work_bv_id   => l_ci_apprv_cw_bv_id,
                  x_return_status    => l_return_status,
                  x_msg_count        => l_msg_count,
                  x_msg_data         => l_msg_data );
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;

         OPEN plan_version_info_cur (p_project_id,p_fin_plan_type_id, l_ci_apprv_cw_bv_id);
         FETCH plan_version_info_cur INTO plan_version_info_rec;
         CLOSE plan_version_info_cur;

         l_curr_work_ver_exists_flag :='Y';

     ELSE
         pa_fin_plan_utils. Get_Curr_Working_Version_Info(
                   p_project_id          => p_project_id
                  ,p_fin_plan_type_id    => p_fin_plan_type_id
                  ,p_version_type        => p_element_type
                  ,x_fp_options_id       => l_fp_options_id
                  ,x_fin_plan_version_id => l_fin_plan_version_id
                  ,x_return_status       => l_return_status
                  ,x_msg_count           => l_msg_count
                  ,x_msg_data            => l_msg_data );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;

         IF ( l_fin_plan_version_id IS NOT NULL )
         THEN
             OPEN plan_version_info_cur (p_project_id,p_fin_plan_type_id, l_fin_plan_version_id);
             FETCH plan_version_info_cur INTO plan_version_info_rec;
             CLOSE plan_version_info_cur;

             l_curr_work_ver_exists_flag := 'Y';

         ELSE
             l_curr_work_ver_exists_flag := 'N';
         END IF;
     END IF;

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Parameter validation complete';
         pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     -- Derive fin_plan_level_code, resource list id plan version based on element type
     IF ( new_version_info_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST )
     THEN
         l_cw_fin_plan_level_code  :=  plan_version_info_rec.cost_fin_plan_level_code;
         l_cw_ver_res_list_id      :=  plan_version_info_rec.cost_resource_list_id;
     ELSIF new_version_info_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
     THEN
         l_cw_fin_plan_level_code  :=  plan_version_info_rec.revenue_fin_plan_level_code;
         l_cw_ver_res_list_id      :=  plan_version_info_rec.revenue_resource_list_id;
     ELSE
         l_cw_fin_plan_level_code  :=  plan_version_info_rec.all_fin_plan_level_code;
         l_cw_ver_res_list_id      :=  plan_version_info_rec.all_resource_list_id;
     END IF;

     -- Bug 3658080 copy options info from current working version only for ci versions
     IF (p_ci_id is not null)   AND
        (NVL(p_calling_context,'-99') <> PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN)
     THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Assigning values to new_version_info_rec' ;
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;

        -- bug 3658080 l_copy_res_assmt_from_cwv_flag := 'Y';

         new_version_info_rec.fin_plan_option_level_code := plan_version_info_rec.fin_plan_option_level_code;
         new_version_info_rec.fin_plan_preference_code := plan_version_info_rec.fin_plan_preference_code;
         new_version_info_rec.plan_in_multi_curr_flag := plan_version_info_rec.plan_in_multi_curr_flag;
         new_version_info_rec.approved_cost_plan_type_flag := plan_version_info_rec.approved_cost_plan_type_flag;
         new_version_info_rec.approved_rev_plan_type_flag := plan_version_info_rec.approved_rev_plan_type_flag;
         new_version_info_rec.primary_cost_forecast_flag := plan_version_info_rec.primary_cost_forecast_flag;
         new_version_info_rec.primary_rev_forecast_flag := plan_version_info_rec.primary_rev_forecast_flag;
         new_version_info_rec.project_structure_version_id := plan_version_info_rec.project_structure_version_id;
         new_version_info_rec.source_fp_options_id := plan_version_info_rec.proj_fp_options_id;

         IF ( new_version_info_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST )
         THEN

             IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage:='Element type is COST'||new_version_info_rec.version_type ;
                 pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
             END IF;

           new_version_info_rec.fin_plan_level_code :=  plan_version_info_rec.cost_fin_plan_level_code;
             new_version_info_rec.time_phased_code    :=  plan_version_info_rec.cost_time_phased_code;
             new_version_info_rec.resource_list_id    :=  plan_version_info_rec.cost_resource_list_id;
             new_version_info_rec.amount_set_id       :=  plan_version_info_rec.cost_amount_set_id;
             new_version_info_rec.select_res_auto_flag := plan_version_info_rec.select_cost_res_auto_flag;
             new_version_info_rec.CURRENT_PLANNING_PERIOD := plan_version_info_rec.cost_CURRENT_PLANNING_PERIOD;
             new_version_info_rec.PERIOD_MASK_ID      :=  plan_version_info_rec.cost_PERIOD_MASK_ID;

         ELSIF ( new_version_info_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE ) THEN

             IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage:='Element type is REVENUE'||new_version_info_rec.version_type ;
                 pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
             END IF;

             new_version_info_rec.fin_plan_level_code := plan_version_info_rec.revenue_fin_plan_level_code;
             new_version_info_rec.time_phased_code := plan_version_info_rec.revenue_time_phased_code;
             new_version_info_rec.resource_list_id  :=   plan_version_info_rec.revenue_resource_list_id;
             new_version_info_rec.amount_set_id :=   plan_version_info_rec.revenue_amount_set_id;
             new_version_info_rec.select_res_auto_flag := plan_version_info_rec.select_rev_res_auto_flag;
             new_version_info_rec.CURRENT_PLANNING_PERIOD := plan_version_info_rec.rev_CURRENT_PLANNING_PERIOD;
             new_version_info_rec.PERIOD_MASK_ID :=  plan_version_info_rec.rev_PERIOD_MASK_ID;

         ELSE

             IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage:='Element type is ALL'||new_version_info_rec.version_type ;
                 pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
             END IF;

             new_version_info_rec.fin_plan_level_code := plan_version_info_rec.all_fin_plan_level_code;
             new_version_info_rec.time_phased_code := plan_version_info_rec.all_time_phased_code;
             new_version_info_rec.resource_list_id  :=   plan_version_info_rec.all_resource_list_id;
             new_version_info_rec.amount_set_id :=   plan_version_info_rec.all_amount_set_id;
             new_version_info_rec.select_res_auto_flag := plan_version_info_rec.select_all_res_auto_flag;
             new_version_info_rec.CURRENT_PLANNING_PERIOD := plan_version_info_rec.all_CURRENT_PLANNING_PERIOD;
             new_version_info_rec.PERIOD_MASK_ID :=  plan_version_info_rec.all_PERIOD_MASK_ID;

         END IF;

     ELSE
         new_version_info_rec.fin_plan_option_level_code := PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION ;

         -- bug 3658080 l_copy_res_assmt_from_cwv_flag:='N';

         -- If plan type's preference code is cost and rev sep then use
         -- new_version_info_rec.version_type to derive preference code
         -- for plan version.

         IF ( plan_type_info_rec.fin_plan_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) THEN
             IF ( new_version_info_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST ) THEN
                 new_version_info_rec.fin_plan_preference_code := PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY;
             ELSIF new_version_info_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE THEN
                 new_version_info_rec.fin_plan_preference_code := PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY;
             END IF;
         ELSE
             --If not then plan version preference code would be same as
             --plan type's preference code

             new_version_info_rec.fin_plan_preference_code := plan_type_info_rec.fin_plan_preference_code;
         END IF;

         new_version_info_rec.plan_in_multi_curr_flag := plan_type_info_rec.plan_in_multi_curr_flag;
         new_version_info_rec.approved_cost_plan_type_flag := plan_type_info_rec.approved_cost_plan_type_flag;
         new_version_info_rec.approved_rev_plan_type_flag := plan_type_info_rec.approved_rev_plan_type_flag;
         new_version_info_rec.primary_cost_forecast_flag := plan_type_info_rec.primary_cost_forecast_flag;
         new_version_info_rec.primary_rev_forecast_flag := plan_type_info_rec.primary_rev_forecast_flag;
         new_version_info_rec.project_structure_version_id := NULL;
         new_version_info_rec.source_fp_options_id := plan_type_info_rec.proj_fp_options_id;

         IF ( new_version_info_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST )
         THEN
             new_version_info_rec.fin_plan_level_code := plan_type_info_rec.cost_fin_plan_level_code;
             new_version_info_rec.time_phased_code := plan_type_info_rec.cost_time_phased_code;
             new_version_info_rec.resource_list_id  :=   plan_type_info_rec.cost_resource_list_id;
             new_version_info_rec.amount_set_id :=   plan_type_info_rec.cost_amount_set_id;
             new_version_info_rec.select_res_auto_flag := plan_type_info_rec.select_cost_res_auto_flag;
             new_version_info_rec.CURRENT_PLANNING_PERIOD := plan_type_info_rec.cost_CURRENT_PLANNING_PERIOD;
             new_version_info_rec.PERIOD_MASK_ID :=  plan_type_info_rec.cost_PERIOD_MASK_ID;
         ELSIF ( new_version_info_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE ) THEN
             new_version_info_rec.fin_plan_level_code := plan_type_info_rec.revenue_fin_plan_level_code;
             new_version_info_rec.time_phased_code := plan_type_info_rec.revenue_time_phased_code;
             new_version_info_rec.resource_list_id  :=   plan_type_info_rec.revenue_resource_list_id;
             new_version_info_rec.amount_set_id :=   plan_type_info_rec.revenue_amount_set_id;
             new_version_info_rec.select_res_auto_flag := plan_type_info_rec.select_rev_res_auto_flag;
             new_version_info_rec.CURRENT_PLANNING_PERIOD := plan_type_info_rec.rev_CURRENT_PLANNING_PERIOD;
             new_version_info_rec.PERIOD_MASK_ID :=  plan_type_info_rec.rev_PERIOD_MASK_ID;
         ELSE
             new_version_info_rec.fin_plan_level_code := plan_type_info_rec.all_fin_plan_level_code;
             new_version_info_rec.time_phased_code := plan_type_info_rec.all_time_phased_code;
             new_version_info_rec.resource_list_id  :=   plan_type_info_rec.all_resource_list_id;
             new_version_info_rec.amount_set_id :=   plan_type_info_rec.all_amount_set_id;
             new_version_info_rec.select_res_auto_flag := plan_type_info_rec.select_all_res_auto_flag;
             new_version_info_rec.CURRENT_PLANNING_PERIOD := plan_type_info_rec.all_CURRENT_PLANNING_PERIOD;
             new_version_info_rec.PERIOD_MASK_ID :=  plan_type_info_rec.all_PERIOD_MASK_ID;
         END IF;

     END IF;

     /* Bug# 2637789 */
     IF ( new_version_info_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST ) THEN
         new_version_info_rec.approved_rev_plan_type_flag := 'N';
         new_version_info_rec.primary_rev_forecast_flag := 'N';
     ELSIF  ( new_version_info_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE ) THEN
         new_version_info_rec.approved_cost_plan_type_flag := 'N';
         new_version_info_rec.primary_cost_forecast_flag := 'N';
     END IF;

     IF ( p_fin_plan_level_code IS NOT NULL )
     THEN
         new_version_info_rec.fin_plan_level_code := p_fin_plan_level_code;
     END IF;

     l_plan_type_mc_flag := new_version_info_rec.plan_in_multi_curr_flag;

     IF ( p_plan_in_multi_curr_flag IS NOT NULL )
     THEN
         new_version_info_rec.plan_in_multi_curr_flag := p_plan_in_multi_curr_flag;
     END IF;

     IF ( p_resource_list_id IS NOT NULL )
     THEN

         new_version_info_rec.resource_list_id := p_resource_list_id;

         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='p_resource_list_id = '|| p_resource_list_id;
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);

             pa_debug.g_err_stage:='fetching control flag and uncategorized flag for res list: '|| p_resource_list_id;
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;

         -- Add resources automatically flag should be y only for project specific res lists
         SELECT nvl(control_flag,'Y'),
                nvl(uncategorized_flag,'N')
         INTO   l_res_list_control_flag,
                l_res_list_uncategorized_flag
         FROM   pa_resource_lists_all_bg
         WHERE  resource_list_id = p_resource_list_id;

         IF (l_res_list_control_flag = 'Y' OR l_res_list_uncategorized_flag = 'Y')
         THEN

             new_version_info_rec.select_res_auto_flag  := 'N';

         ELSE
             IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.g_err_stage:='Calling PA_CREATE_RESOURCE.CREATE_PROJ_RESOURCE_LIST for res list: '|| p_resource_list_id;
                 pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
             END IF;
             -- Call create_proj_resource_list api for this resource  list

             PA_CREATE_RESOURCE.CREATE_PROJ_RESOURCE_LIST (
                    p_project_id            =>   p_project_id
                   ,p_resource_list_id      =>   p_resource_list_id
                   ,x_return_status         =>   x_return_status
                   ,x_msg_count             =>   x_msg_count
                   ,x_error_msg_data        =>   x_msg_data );

             IF  x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;
         END IF;
     ELSE -- added for bug 4724017
         -- this code block would be executed for all the flows other than the AMG flow.
         -- the uncategorized info is required to call pa_fp_planning_transaction_pub.create_default_task_plan_txns
         -- conditionally only for uncategorized resource lists only.
         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Fetching uncategorized flag when resource list id is not passed';
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;

         BEGIN
            SELECT nvl(uncategorized_flag,'N')
            INTO   l_res_list_uncategorized_flag
            FROM   pa_resource_lists_all_bg
            WHERE  resource_list_id = new_version_info_rec.resource_list_id;

            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:='l_res_list_uncategorized_flag: ' || l_res_list_uncategorized_flag;
                pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage:='No uncategorized flag found for the resource list id passed';
                    pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END; -- bug 4724017 ends.
     END IF;

     IF p_time_phased_code IS NOT NULL
     THEN
         -- If input time phase code is different from time phased code value of new_version_info_rec
         -- time phased code , period mask id and current_planning_period should not be defaulted

         IF  p_time_phased_code <> new_version_info_rec.time_phased_code
         THEN
             new_version_info_rec.time_phased_code :=  p_time_phased_code;
             IF p_time_phased_code IN ('N')
             THEN
                 -- Current planning period and period mask id should be null
                 new_version_info_rec.current_planning_period := NULL;
                 new_version_info_rec.period_mask_id :=  NULL;

             ELSIF p_time_phased_code IN ('G', 'P')
             THEN
                 -- Derive default current planning period and current period mask
                 Pa_Prj_Period_Profile_Utils.Get_Prj_Defaults(
                       p_project_id                 => p_project_id
                      ,p_info_flag                  => 'ALL'
                      ,p_create_defaults            => 'N'
                      ,x_gl_start_period            => l_gl_start_period
                      ,x_gl_end_period              => l_gl_end_period
                      ,x_gl_start_Date              => l_gl_start_Date
                      ,x_pa_start_period            => l_pa_start_period
                      ,x_pa_end_period              => l_pa_end_period
                      ,x_pa_start_date              => l_pa_start_date
                      ,x_plan_version_exists_flag   => l_plan_version_exists_flag
                      ,x_prj_start_date             => l_prj_start_date
                      ,x_prj_end_date               => l_prj_end_date);

                 IF  p_time_phased_code = 'P'
                 THEN
                     new_version_info_rec.period_mask_id :=  2;
                     new_version_info_rec.current_planning_period := l_pa_start_period;
                 ELSIF p_time_phased_code = 'G'
                 THEN
                     new_version_info_rec.period_mask_id :=  1;
                     new_version_info_rec.current_planning_period := l_gl_start_period;
                 END IF;
             END IF;
         END IF;
     END IF; -- p_time_phased_code is not null

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='new_version_info_rec.resource_list_id = '|| new_version_info_rec.resource_list_id || 'new_version_info_rec.time_phased_code = ' || new_version_info_rec.time_phased_code;
        pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     --Start of changes for Bug :- 2570250

     --Fetch the MAX  working version for this plan type

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Fetching max working version number for this plan type';
        pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     PA_FIN_PLAN_UTILS.Get_Max_Budget_Version_Number
        (p_project_id          =>   p_project_id
        ,p_fin_plan_type_id    =>   p_fin_plan_type_id
        ,p_version_type        =>   new_version_info_rec.version_type
        ,p_copy_mode           =>   PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING
        ,p_ci_id               =>   p_ci_id
        ,p_lock_required_flag  =>   'Y'
        ,x_version_number      =>   l_max_version_number
        ,x_return_status       =>   x_return_status
        ,x_msg_count           =>   x_msg_count
        ,x_msg_data            =>   x_msg_data );

     IF   x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

     --End of changes for Bug :- 2570250

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='l_max_version_number = '|| l_max_version_number ;
        pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

-- Start of changes for Bug :- 2650427

     /* For control item versions current_working_flag is always set to 'N'. Now
        there is a possibility that max_version is > 0 and still there is no current
        working version. Hence a non-ci version should be set to current working in
        case there is no current working already available.
     */
     /*
     --Populate l_current_working_flag
     IF l_max_version_number = 0 THEN l_current_working_flag := 'Y';
     ELSE l_current_working_flag := 'N';
     END IF;
     */

     IF p_ci_id IS NOT NULL THEN
          l_current_working_flag := 'N';
     ELSE
         BEGIN
              /* Bug 2668667 , in the following select clause, version type condition is necessary
                 in the following sceniaro. If the plan type is attached is cost_and_rev_sep and
                 a cost version is created and then a revenue version is created. Now , the revenue
                 version should also be set as current_working_version. */

               SELECT budget_version_id
               INTO   l_dummy_version_id
               FROM   pa_budget_versions
               WHERE  project_id = p_project_id
               AND    fin_plan_type_id = p_fin_plan_type_id
               AND    version_type = new_version_info_rec.version_type   -- Bug :- 2668667
               AND    current_working_flag = 'Y';

               -- If a current_working_version already exists then set
               -- current_working flag to 'N'

               l_current_working_flag := 'N';
         EXCEPTION
               WHEN NO_DATA_FOUND THEN
                     -- If no current_working_version already exists,make the
                     -- current_version as current_working_version
                     l_current_working_flag := 'Y';
               WHEN OTHERS THEN

                    IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage:='Error while fetching current_working budget_version_id';
                        pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                     END IF;
                     RAISE;
         END;
     END IF;

     -- End of changes for Bug :- 2650427


     --Fetch new budget version id if budget version id isn't passed

     IF (px_budget_version_id IS NULL) THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:='Fetching new budget_version_id';
            pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;

         SELECT pa_budget_versions_s.NEXTVAL
         INTO   l_new_budget_version_id
         FROM   DUAL;
     ELSE
         l_new_budget_version_id := px_budget_version_id;
     END IF;


      --Create a new record in pa_budget_versions using plan type properties

     IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage:='Calling budget_versions table handler to insert new row ';
         pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     -- Getting the Use for workplan flag to populate WP_VERSION_FLAG in pa_budget_versions
     SELECT use_for_workplan_flag
     INTO   l_wp_version_flag
     FROM   pa_fin_plan_types_b
     WHERE  fin_plan_type_id = p_fin_plan_type_id;

     /* This fix is done during IB1 testing of FP M. There are some flows, which
      * are creation more than one budget version for the same workplan version. To
      * identify such flows, the following check is being made so that dev can fix
      * such issues */

     Declare
          l_exists varchar2(1);
     Begin
          Select 'Y'
          Into   l_exists
          From   pa_budget_versions
          Where  project_structure_version_id =
                  nvl(p_struct_elem_version_id,new_version_info_rec.project_structure_version_id)
          And    wp_version_flag = 'Y'
          And    exists (select 'x' from pa_budget_versions b
                         where b.budget_version_id =
                                 nvl(l_ci_apprv_cw_bv_id,l_fin_plan_version_id)
                         and b.wp_version_flag = 'Y') ;

          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Project_id = '||p_project_id;
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,5);
             pa_debug.g_err_stage:='Fin_plan_type_id = '||p_fin_plan_type_id;
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,5);
             pa_debug.g_err_stage:='Version_name = '||p_version_name;
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,5);
             pa_debug.g_err_stage:='Description = '||p_description;
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,5);
             pa_debug.g_err_stage:='proj sv id = ' || nvl(p_struct_elem_version_id,new_version_info_rec.project_structure_version_id);
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,5);
             pa_debug.g_err_stage:='calling context = ' || p_calling_context;
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;

         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'DUPLICATE_WP_BEING_CREATED');

         IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     Exception
          When No_Data_Found Then
               Null;
     End;

     pa_fp_budget_versions_pkg.Insert_Row
           (px_budget_version_id                =>      l_new_budget_version_id, -- unique budget_version_id for new version
            p_project_id                        =>      p_project_id,          -- the ID of the project
            p_budget_type_code                  =>      NULL,
            p_version_number                    =>      l_max_version_number+1,      -- version_number incremented
            p_budget_status_code                =>      'W',                  -- 'Working' version
            p_current_flag                      =>      'N',                  -- 'Working' version
            p_original_flag                     =>      'N',                  -- 'Working' version
            p_current_original_flag             =>      'N',                  -- 'Working' version
            p_resource_accumulated_flag         =>      'N',   -- HARDCODED VALUE
            p_resource_list_id                  =>      new_version_info_rec.resource_list_id,
            p_version_name                      =>      p_version_name,     -- user-entered value
            p_budget_entry_method_code          =>      NULL,
            p_baselined_by_person_id            =>      NULL,
            p_baselined_date                    =>      NULL,
            p_change_reason_code                =>      NULL,
            p_labor_quantity                    =>      NULL,
            p_labor_unit_of_measure             =>      'HOURS',
            p_raw_cost                          =>      NULL,
            p_burdened_cost                     =>      NULL,
            p_revenue                           =>      NULL,
            p_description                       =>      p_description,      -- user-entered value
            --Bug3088010 start: Changed NULL to the parameters passed in to this api
            p_attribute_category                =>      p_attribute_category,   --NULL,
            p_attribute1                        =>      p_attribute1,           --NULL,
            p_attribute2                        =>      p_attribute2,           --NULL,
            p_attribute3                        =>      p_attribute3,           --NULL,
            p_attribute4                        =>      p_attribute4,           --NULL,
            p_attribute5                        =>      p_attribute5,           --NULL,
            p_attribute6                        =>      p_attribute6,           --NULL,
            p_attribute7                        =>      p_attribute7,           --NULL,
            p_attribute8                        =>      p_attribute8,           --NULL,
            p_attribute9                        =>      p_attribute9,           --NULL,
            p_attribute10                       =>      p_attribute10,          --NULL,
            p_attribute11                       =>      p_attribute11,          --NULL,
            p_attribute12                       =>      p_attribute12,          --NULL,
            p_attribute13                       =>      p_attribute13,          --NULL,
            p_attribute14                       =>      p_attribute14,          --NULL,
            p_attribute15                       =>      p_attribute15,          --NULL,
            --Bug3088010 end: Changed NULL to the parameters passed in to this api
            p_first_budget_period               =>      NULL,
            p_pm_product_code                   =>      p_pm_product_code,  --NULL, --Bug 5403751
            p_pm_budget_reference               =>      NULL,
            p_wf_status_code                    =>      NULL,
            p_adw_notify_flag                   =>      NULL,
            p_prc_generated_flag                =>      NULL,
            p_plan_run_date                     =>      NULL,
            p_plan_processing_code              =>      NULL,
            p_fin_plan_type_id                  =>      p_fin_plan_type_id,
            p_parent_plan_version_id            =>      NULL,
            p_project_structure_version_id      =>      nvl(p_struct_elem_version_id,new_version_info_rec.project_structure_version_id),
            p_current_working_flag              =>      l_current_working_flag,
            p_total_borrowed_revenue            =>      NULL,
            p_total_tp_revenue_in               =>      NULL,
            p_total_tp_revenue_out              =>      NULL,
            p_total_revenue_adj                 =>      NULL,
            p_total_lent_resource_cost          =>      NULL,
            p_total_tp_cost_in                  =>      NULL,
            p_total_tp_cost_out                 =>      NULL,
            p_total_cost_adj                    =>      NULL,
            p_total_unassigned_time_cost        =>      NULL,
            p_total_utilization_percent         =>      NULL,
            p_total_utilization_hours           =>      NULL,
            p_total_utilization_adj             =>      NULL,
            p_total_capacity                    =>      NULL,
            p_total_head_count                  =>      NULL,
            p_total_head_count_adj              =>      NULL,
            p_version_type                      =>      new_version_info_rec.version_type,
            p_request_id                        =>      FND_GLOBAL.conc_request_id,
            p_total_project_raw_cost            =>      NULL,
            p_total_project_burdened_cost       =>      NULL,
            p_total_project_revenue             =>      NULL,
            p_locked_by_person_id               =>      NULL,
            p_approved_cost_plan_type_flag      =>      new_version_info_rec.approved_cost_plan_type_flag,
            p_approved_rev_plan_type_flag       =>      new_version_info_rec.approved_rev_plan_type_flag,
            p_est_project_raw_cost              =>      p_est_proj_raw_cost,
            p_est_project_burdened_cost         =>      p_est_proj_bd_cost,
            p_est_project_revenue               =>      p_est_proj_revenue,
            p_est_quantity                      =>      p_est_qty,
            p_est_equip_qty                     =>      p_est_equip_qty,
            p_est_projfunc_raw_cost             =>      NULL,
            p_est_projfunc_burdened_cost        =>      NULL,
            p_est_projfunc_revenue              =>      NULL,
            p_ci_id                             =>      p_ci_id,
            p_agreement_id                      =>      p_agreement_id,
            p_refresh_required_flag             =>      NULL, -- redundant in patchset M
            p_object_type_code                  =>      'PROJECT',
            p_object_id                         =>      p_project_id,
            p_primary_cost_forecast_flag        =>      new_version_info_rec.primary_cost_forecast_flag,
            p_primary_rev_forecast_flag         =>      new_version_info_rec.PRIMARY_REV_FORECAST_FLAG,
            p_rev_partially_impl_flag           =>      'N',
            p_equipment_quantity                =>      NULL,
            p_pji_summarized_flag               =>      'N',
            p_wp_version_flag                   =>      l_WP_VERSION_FLAG,
            p_current_planning_period           =>      new_version_info_rec.CURRENT_PLANNING_PERIOD,
            p_period_mask_id                    =>      new_version_info_rec.PERIOD_MASK_ID,
            p_actual_amts_thru_period           =>      new_version_info_rec.actual_amts_thru_period,
            p_last_amt_gen_date                 =>      NULL,
            x_row_id                            =>      l_row_id,
            x_return_status                     =>      x_return_status);

     -- End, jwhite, 26-JUN-2003: Plannable Task Effort --------------------------------

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;

     pa_budget_utils.Get_Project_Currency_Info  -- Bug # 2634900
     (
        p_project_id                    => p_project_id
      , x_projfunc_currency_code        => l_projfunc_currency_code
      , x_project_currency_code         => l_project_currency_code
      , x_txn_currency_code             => l_dummy_currency_code
      , x_msg_count                     => x_msg_count
      , x_msg_data                      => x_msg_data
      , x_return_status                 => x_return_status
     );

    IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:= 'Could not obtain currency info for the project';
            pa_debug.write('Create_Version: ' || l_module_name,
                               pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
         END IF;
         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    -- for a control item budget version, the only plannable currency should be
    -- agreement currency.

    IF (p_ci_id IS NOT NULL) AND (p_agreement_id IS NOT NULL) THEN   -- Bug # 2634900
        -- Fetch the project and project functional currency codes of the project

        -- Obtain the agreement currency code.
        Pa_Fp_Control_Items_Utils.get_fp_ci_agreement_dtls(
                    p_project_id                    =>  p_project_id
                   ,p_ci_id                         =>  p_ci_id
                   ,x_agreement_num                 =>  l_agreement_num
                   ,x_agreement_amount              =>  l_agreement_amount
                   ,x_agreement_currency_code       =>  l_agreement_currency_code
                   ,x_msg_data                      =>  x_msg_data
                   ,x_msg_count                     =>  x_msg_count
                   ,x_return_status                 =>  x_return_status );

        IF  (l_agreement_currency_code IS NULL) OR
            (x_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:='Agreement_currency_code is null';
               pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        IF (l_agreement_currency_code NOT IN (l_projfunc_currency_code,l_project_currency_code)) THEN
                new_version_info_rec.plan_in_multi_curr_flag := 'Y';
        END IF;
    END IF;
    -- end of changes for Bug :- 2634900

    -- Create record in PA_PROJ_FP_OPTIONS
    -- Calling create_fp_options api to create new record for the created plan version


    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.g_err_stage:='Calling create_fp_option api';
        pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    PA_PROJ_FP_OPTIONS_PUB.create_fp_option (
               px_target_proj_fp_option_id   =>  l_new_proj_fp_options_id
               ,p_source_proj_fp_option_id   =>  new_version_info_rec.source_fp_options_id
               ,p_target_fp_option_level_code => PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION
               ,p_target_fp_preference_code  =>  new_version_info_rec.fin_plan_preference_code
               ,p_target_fin_plan_version_id =>  l_new_budget_version_id
               ,p_target_project_id          =>  p_project_id
               ,p_target_plan_type_id        =>  p_fin_plan_type_id
               ,x_return_status              =>  x_return_status
               ,x_msg_count                  =>  x_msg_count
               ,x_msg_data                   =>  x_msg_data );

    IF   x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    --Update the fp option created for plan version with the passed  i/p parameters if they are not null

    IF new_version_info_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST THEN
         UPDATE pa_proj_fp_options
         SET    cost_amount_set_id           =   NVL(p_amount_set_id,new_version_info_rec.amount_set_id),
                plan_in_multi_curr_flag      =   new_version_info_rec.plan_in_multi_curr_flag,
                cost_fin_plan_level_code     =   new_version_info_rec.fin_plan_level_code,
                cost_time_phased_code        =   new_version_info_rec.time_phased_code,
                cost_resource_list_id        =   new_version_info_rec.resource_list_id,
                select_cost_res_auto_flag    =   new_version_info_rec.select_res_auto_flag,
                cost_current_planning_period =   new_version_info_rec.current_planning_period,
                cost_period_mask_id          =   new_version_info_rec.period_mask_id,
                rbs_version_id               =   Decode(p_ci_id, null, rbs_version_id, null), -- bug 3867302
                --gboomina bug 8318932 - AAI enhancement - start
                copy_etc_from_plan_flag      =   plan_type_info_rec.copy_etc_from_plan_flag
                --gboomina bug 8318932 - AAI enhancement - end
         WHERE  proj_fp_options_id = l_new_proj_fp_options_id;
    ELSIF new_version_info_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE THEN
         UPDATE pa_proj_fp_options
         SET    revenue_amount_set_id         =   NVL(p_amount_set_id,new_version_info_rec.amount_set_id),
                plan_in_multi_curr_flag       =   new_version_info_rec.plan_in_multi_curr_flag,
                revenue_fin_plan_level_code   =   new_version_info_rec.fin_plan_level_code,
                revenue_time_phased_code      =   new_version_info_rec.time_phased_code,
                revenue_resource_list_id      =   new_version_info_rec.resource_list_id,
                select_rev_res_auto_flag      =   new_version_info_rec.select_res_auto_flag,
                rev_current_planning_period   =   new_version_info_rec.current_planning_period,
                rev_period_mask_id            =   new_version_info_rec.period_mask_id,
                rbs_version_id                =   Decode(p_ci_id, null, rbs_version_id, null) -- bug 3867302
         WHERE  proj_fp_options_id = l_new_proj_fp_options_id;
    ELSIF new_version_info_rec.version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL THEN
         UPDATE pa_proj_fp_options
         SET    all_amount_set_id             =   NVL(p_amount_set_id,new_version_info_rec.amount_set_id),
                plan_in_multi_curr_flag       =   new_version_info_rec.plan_in_multi_curr_flag,
                all_fin_plan_level_code       =   new_version_info_rec.fin_plan_level_code,
                all_time_phased_code          =   new_version_info_rec.time_phased_code,
                all_resource_list_id          =   new_version_info_rec.resource_list_id,
                select_all_res_auto_flag      =   new_version_info_rec.select_res_auto_flag,
                all_current_planning_period   =   new_version_info_rec.current_planning_period,
                all_period_mask_id            =   new_version_info_rec.period_mask_id,
                rbs_version_id                =   Decode(p_ci_id, null, rbs_version_id, null) -- bug 3867302
         WHERE  proj_fp_options_id = l_new_proj_fp_options_id;
    END IF;

    -- Start of bug changes :- 2649474 (Baseline funding without budget Changes)
    --Calling copy_fp_txn_currencies api

    IF p_agreement_id IS NOT NULL THEN

        -- Insert the agreement_currency into pa_fp_txn_currencies table

        PA_FP_TXN_CURRENCIES_PUB.enter_agreement_curr_for_ci
             (  p_project_id              =>  p_project_id
               ,p_fin_plan_version_id     =>  l_new_budget_version_id
               ,p_ci_id                   =>  p_ci_id
               ,p_project_currency_code   =>  l_project_currency_code
               ,p_projfunc_currency_code  =>  l_projfunc_currency_code
               ,x_return_status           =>  x_return_status
               ,x_msg_count               =>  x_msg_count
               ,x_msg_data                =>  x_msg_data );

        IF   x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

    ELSE

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.g_err_stage:='Calling COPY_FP_TXN_CURRENCIES api';
           pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
        END IF;

        PA_FP_TXN_CURRENCIES_PUB.COPY_FP_TXN_CURRENCIES (
             p_source_fp_option_id           =>   new_version_info_rec.source_fp_options_id
             ,p_target_fp_option_id          =>   l_new_proj_fp_options_id
             ,p_target_fp_preference_code    =>   null
             ,p_plan_in_multi_curr_flag      =>   new_version_info_rec.plan_in_multi_curr_flag
             ,x_return_status                =>   x_return_status
             ,x_msg_count                    =>   x_msg_count
             ,x_msg_data                     =>   x_msg_data );

        IF   x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

    END IF;

    --Bug 3867302  For ci versions reporting data is not maintained
    IF l_pji_rollup_required = 'Y' THEN --for Bug 4200168
        IF p_ci_id IS NULL THEN
            /* FP M - Reporting lines integration */
            l_budget_version_ids.delete;
            l_budget_version_ids   := SYSTEM.pa_num_tbl_type(l_new_budget_version_id);

            IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('Create_Version: ' || l_module_name,'Calling PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE ' ,5);
                pa_debug.write('Create_Version: ' || l_module_name,'p_fp_version_ids count '|| l_budget_version_ids.count(),5);
            END IF;

            /* We are sure that there is only one record. But just looping the std way */
            FOR I in l_budget_version_ids.first..l_budget_version_ids.last LOOP
               pa_debug.write('Create_Version: ' || l_module_name,''|| l_budget_version_ids(i),5);
            END LOOP;

              PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE (
                     p_fp_version_ids   => l_budget_version_ids,
                     x_return_status    => l_return_status,
                     x_msg_code         => l_msg_data);

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
                   PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                        p_msg_name            => l_msg_data);
                   RAISE  PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              END IF;

        END IF;
    END IF;
    /*
       In control item context for a project enabled for auto baseline funding
       and PC=PFC get the conversion attributes from the project. Bug 2661237.
    */
    IF ( nvl(l_plan_type_mc_flag,'N') = 'N' and
         nvl(new_version_info_rec.plan_in_multi_curr_flag,'N') = 'Y' AND
         p_agreement_id IS NOT NULL
       ) OR
       (
         nvl(l_plan_type_mc_flag,'N') = 'Y' and
         nvl(new_version_info_rec.plan_in_multi_curr_flag,'N') = 'Y' AND
         p_agreement_id IS NOT NULL AND
         l_project_currency_code = l_projfunc_currency_code
       )
    THEN

        pa_multi_currency_billing.get_project_defaults (
            p_project_id                       => p_project_id
           ,x_multi_currency_billing_flag      => l_multi_currency_billing_flag
           ,x_baseline_funding_flag            => l_baseline_funding_flag
           ,x_revproc_currency_code            => l_revproc_currency_code
           ,x_invproc_currency_type            => l_invproc_currency_type
           ,x_invproc_currency_code            => l_invproc_currency_code
           ,x_project_currency_code            => l_project_currency_code
           ,x_project_bil_rate_date_code       => l_project_bil_rate_date_code
           ,x_project_bil_rate_type            => l_project_bil_rate_type
           ,x_project_bil_rate_date            => l_project_bil_rate_date
           ,x_project_bil_exchange_rate        => l_project_bil_exchange_rate
           ,x_projfunc_currency_code           => l_projfunc_currency_code
           ,x_projfunc_bil_rate_date_code      => l_projfunc_bil_rate_date_code
           ,x_projfunc_bil_rate_type           => l_projfunc_bil_rate_type
           ,x_projfunc_bil_rate_date           => l_projfunc_bil_rate_date
           ,x_projfunc_bil_exchange_rate       => l_projfunc_bil_exchange_rate
           ,x_funding_rate_date_code           => l_funding_rate_date_code
           ,x_funding_rate_type                => l_funding_rate_type
           ,x_funding_rate_date                => l_funding_rate_date
           ,x_funding_exchange_rate            => l_funding_exchange_rate
           ,x_return_status                    => x_return_status
           ,x_msg_count                        => x_msg_count
           ,x_msg_data                         => x_msg_data   );

/*     IF nvl(l_multi_currency_billing_flag,'N') = 'N' THEN
         -- This will never occur as the required validation is done in the agreement form.
               PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                    p_msg_name      => 'PAFP_NO_PROJ_CONV_ATTR');
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       ELSE
*/             /* check for FP compatible rate date type - PC*/
               IF l_project_bil_rate_date is not null THEN  -- Takes care of FIXED_DATE

                       -- Rate Date will be as it is.
                       -- Rate Date type is FIXED_DATE.
                       l_project_bil_rate_date_code  := PA_FP_CONSTANTS_PKG.G_RATE_DATE_TYPE_FIXED_DATE;

               ELSIF l_project_bil_rate_date_code IS NOT NULL AND
                     l_project_bil_rate_type <> PA_FP_CONSTANTS_PKG.G_RATE_TYPE_USER THEN  --Takes care of PA_INVOICE_DATE

                       l_project_bil_rate_date_code  := PA_FP_CONSTANTS_PKG.G_RATE_DATE_TYPE_START_DATE;

               ELSIF l_project_bil_rate_type = PA_FP_CONSTANTS_PKG.G_RATE_TYPE_USER THEN    --USER rate type.

                       update pa_fp_txn_currencies
                       set project_rev_exchange_rate = l_project_bil_exchange_rate
                       where proj_fp_options_id = l_new_proj_fp_options_id
                       and txn_currency_code = l_agreement_currency_code;

               END IF;

               /* check for FP compatible rate date type - PFC*/
               IF l_projfunc_bil_rate_date IS NOT NULL THEN  -- Takes care of FIXED_DATE
                    -- Rate Date will be as it is.
                     l_projfunc_bil_rate_date_code  := PA_FP_CONSTANTS_PKG.G_RATE_DATE_TYPE_FIXED_DATE;

               ELSIF l_projfunc_bil_rate_date_code IS NOT NULL AND
                     l_projfunc_bil_rate_type <> PA_FP_CONSTANTS_PKG.G_RATE_TYPE_USER THEN  --Takes care of PA_INVOICE_DATE

                      l_projfunc_bil_rate_date_code  := PA_FP_CONSTANTS_PKG.G_RATE_DATE_TYPE_START_DATE;

               ELSIF l_projfunc_bil_rate_type = PA_FP_CONSTANTS_PKG.G_RATE_TYPE_USER then    --USER rate type.

                     update pa_fp_txn_currencies
                     set projfunc_rev_exchange_rate = l_projfunc_bil_exchange_rate
                     where proj_fp_options_id = l_new_proj_fp_options_id
                     and txn_currency_code = l_agreement_currency_code;

               END IF;

               UPDATE   pa_proj_fp_options
               SET      PROJECT_REV_RATE_TYPE         = l_project_bil_rate_type
                       ,PROJECT_REV_RATE_DATE_TYPE    = l_project_bil_rate_date_code
                       ,PROJECT_REV_RATE_DATE         = l_project_bil_rate_date
                       ,PROJFUNC_REV_RATE_TYPE        = l_projfunc_bil_rate_type
                       ,PROJFUNC_REV_RATE_DATE_TYPE   = l_projfunc_bil_rate_date_code
                       ,PROJFUNC_REV_RATE_DATE        = l_projfunc_bil_rate_date
                WHERE  proj_fp_options_id = l_new_proj_fp_options_id;
/*     END IF;*/
    END IF;

    -- End of bug changes :- 2649474

    /*
        Bug 2678651 - The API get_converted_amounts should be called after the option
        for the version in case of CI is created - Moved the code to after the option
        is created.
    */
    IF p_ci_id IS NOT NULL THEN

         PA_FIN_PLAN_UTILS.get_converted_amounts
               (  p_budget_version_id       =>  l_new_budget_version_id
                 ,p_txn_raw_cost            =>  p_est_proj_raw_cost
                 ,p_txn_burdened_cost       =>  p_est_proj_bd_cost
                 ,p_txn_revenue             =>  p_est_proj_revenue
                 ,p_txn_currency_Code       =>  l_project_currency_Code
                 ,p_project_currency_Code   =>  l_project_currency_Code
                 ,p_projfunc_currency_code  =>  l_projfunc_currency_code
                 ,x_project_raw_cost        =>  l_est_project_raw_cost
                 ,x_project_burdened_cost   =>  l_est_project_bd_cost
                 ,x_project_revenue         =>  l_est_project_revenue
                 ,x_projfunc_raw_cost       =>  l_est_projfunc_raw_cost
                 ,x_projfunc_burdened_cost  =>  l_est_projfunc_bd_cost
                 ,x_projfunc_revenue        =>  l_est_projfunc_revenue
                 ,x_return_status           =>  x_return_status
                 ,x_msg_count               =>  x_msg_count
                 ,x_msg_data                =>  x_msg_data );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;

         -- Update the budget versions table with the converted estimated amounts in projfunc currency

         UPDATE Pa_Budget_Versions SET
             est_projfunc_raw_cost      =  l_est_projfunc_raw_cost,
             est_projfunc_burdened_cost =  l_est_projfunc_bd_cost,
             est_projfunc_revenue       =  l_est_projfunc_revenue
         WHERE  Budget_Version_Id       =  l_new_budget_version_id;
     END IF;
     /* End of changes for Bug 2678651 */

     -- Bug 3658080 Logic to derive if res assignments data should be
     -- copied from current working version or create defaults

     IF  p_ci_id IS NOT NULL
     THEN
         l_copy_res_assmt_from_cwv_flag:='Y';
     ELSIF ( l_curr_work_ver_exists_flag = 'Y' ) AND
           ( new_version_info_rec.fin_plan_level_code = l_cw_fin_plan_level_code) AND
           ( new_version_info_rec.resource_list_id = l_cw_ver_res_list_id )
     THEN
         l_copy_res_assmt_from_cwv_flag:='Y';
     ELSE
         l_copy_res_assmt_from_cwv_flag:='N';
     END IF;

     -- If calling context is create_draft or automatic baseline this api need not
     -- create resource assignments for the budget version

     /* Did null handing for bug 2663313 */
     /* 3831449: do not create records in pa_resource_assignments if p_calling_context is GENERATE */
     IF nvl(p_calling_context,'-99') NOT IN  (PA_FP_CONSTANTS_PKG.G_CREATE_DRAFT,
                                              -- Bug Fix: 4569365. Removed MRC code.
                                              -- PA_MRC_FINPLAN.G_AUTOMATIC_BASELINE,
                                              'AUTOMATIC_BASELINE', --Bug 5700400: Autobaseline case was commented earlier by mistake.
                                              PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN,
                'GENERATE', PA_FP_CONSTANTS_PKG.G_AMG_API) --Added this for bug 4224464
     THEN

         --Start of changes for Bug :- 2634900

         IF p_impacted_task_id IS NULL THEN

              --  If current working version doesn't exist, call
              --  create_default_task_plan_txns to create default
              --  planning transactions
              IF l_copy_res_assmt_from_cwv_flag = 'N'
              THEN
              -- added for bug 4724017:
              -- Creation of default planning transaction is not done for versions
              -- being created with categorized resource list.
                  IF l_res_list_uncategorized_flag = 'Y' THEN
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.g_err_stage:='Calling create_default_task_plan_txns api';
                          pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                      END IF;

                      pa_fp_planning_transaction_pub.create_default_task_plan_txns
                      (    p_budget_version_id       => l_new_budget_version_id
                         , p_version_plan_level_code => new_version_info_rec.fin_plan_level_code
                         , x_return_status           => x_return_status
                         , x_msg_count               => l_msg_count
                         , x_msg_data                => l_msg_data
                      );

                      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                      END IF;
                  END IF; -- bug 4724017 ends
              ELSE


                  IF p_ci_id IS NULL THEN
                      l_src_bv_id_for_copying_ra :=  l_fin_plan_version_id ;
                  ELSE
                      l_src_bv_id_for_copying_ra :=  l_ci_apprv_cw_bv_id ;
                  END IF;

                  IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.g_err_stage:='Calling copy_resource_assignments api';
                      pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  pa_fp_copy_from_pkg.copy_resource_assignments
                  (     p_source_plan_version_id => l_src_bv_id_for_copying_ra
                      , p_target_plan_version_id => l_new_budget_version_id
                      , p_adj_percentage         => -99
                      , p_calling_context        => 'CREATE_VERSION'
                      , x_return_status          => x_return_status
                      , x_msg_count              => l_msg_count
                      , x_msg_data               => l_msg_data
                  );

                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;

                  -- For normal budget versions when res assignments data is copied
                  -- from current working version, if rbs of versions is not same as
                  -- that of plan type's rbs, rbs refresh is necessary
                  IF  (nvl(plan_type_info_rec.rbs_version_id, -99)  <>
                              nvl(plan_version_info_rec.rbs_version_id, -99)) AND
                      p_ci_id IS NULL
                  THEN
                      -- RBS refresh is necessary for the resource assignments data
                      IF  plan_type_info_rec.rbs_version_id IS NOT NULL THEN
                          -- Call RBS mapping api for the entire version
                          PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs(
                               p_budget_version_id         =>   l_new_budget_version_id
                              ,p_resource_list_id          =>   new_version_info_rec.resource_list_id
                              ,p_rbs_version_id            =>   plan_type_info_rec.rbs_version_id
                              ,p_calling_process           =>   'RBS_REFRESH'
                              ,p_calling_context           =>   'PLSQL'
                              ,p_process_code              =>   'RBS_MAP'
                              ,p_calling_mode              =>   'BUDGET_VERSION'
                              ,p_init_msg_list_flag        =>   'N'
                              ,p_commit_flag               =>   'N'
                              ,x_txn_source_id_tab         =>   l_txn_source_id_tbl
                              ,x_res_list_member_id_tab    =>   l_res_list_member_id_tbl
                              ,x_rbs_element_id_tab        =>   l_rbs_element_id_tbl
                              ,x_txn_accum_header_id_tab   =>   l_txn_accum_header_id_tbl
                              ,x_return_status             =>   x_return_status
                              ,x_msg_count                 =>   x_msg_count
                              ,x_msg_data                  =>   x_msg_data);

                          -- Check return status
                          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                          END IF;

                          -- Check if out table has any records first
                          IF nvl(l_txn_source_id_tbl.last,0) >= 1 THEN
                              -- Update resource assignments data for the version
                              FORALL j IN l_txn_source_id_tbl.first .. l_txn_source_id_tbl.last
                                  UPDATE pa_resource_assignments
                                  SET     rbs_element_id          =  l_rbs_element_id_tbl(j)
                                         ,txn_accum_header_id     =  l_txn_accum_header_id_tbl(j)
                                         ,record_version_number   =  record_version_number + 1
                                         ,last_update_date        =  SYSDATE
                                         ,last_updated_by         =  FND_GLOBAL.user_id
                                         ,last_update_login       =  FND_GLOBAL.login_id
                                  WHERE  budget_version_id = l_new_budget_version_id
                                  AND    resource_assignment_id = l_txn_source_id_tbl(j);
                          END IF;
                      ELSE -- rbs version id is null

                            -- Update all the resource assigments with null for rbs _element_id
                            UPDATE pa_resource_assignments
                            SET     rbs_element_id          =  null
                                   ,txn_accum_header_id     =  null
                                   ,record_version_number   =  record_version_number + 1
                                   ,last_update_date        =  SYSDATE
                                   ,last_updated_by         =  FND_GLOBAL.user_id
                                   ,last_update_login       =  FND_GLOBAL.login_id
                            WHERE  budget_version_id = l_new_budget_version_id;

                      END IF;
                  END IF;
              END IF;  -- ( l_copy_res_assmt_from_cwv_flag = 'N'  )

         ELSE
               -- Create resource assignments for the budget version and the impacted task id

               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage:='Calling Create_CI_Resource_Assignments';
                  pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
               END IF;

               PA_FP_ELEMENTS_PUB.Create_CI_Resource_Assignments
                             (  p_project_id              =>    p_project_id
                               ,p_budget_version_id       =>    l_new_budget_version_id
                               ,p_version_type            =>    new_version_info_rec.version_type
                               ,p_impacted_task_id        =>    p_impacted_task_id
                               ,x_return_status           =>    x_return_status
                               ,x_msg_count               =>    x_msg_count
                               ,x_msg_data                =>    x_msg_data );

               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 Raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               END IF;

         END IF;

         --End of changes for Bug :- 2634900
    END IF; -- calling context

      -- IPM Architecture Enhancement Bug 4865563
       /* If there is no budget lines for some resource assignments of the current budget versions
        * then, the maintenance api would not create data in the new entity. In that scenario, we have
        * to insert those resource assignment with default applicable currency
        */
       PA_FIN_PLAN_PUB.create_default_plan_txn_rec
           (p_budget_version_id => l_new_budget_version_id,
            p_calling_module    => 'COPY_PLAN',
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                  THEN
                     IF p_pa_debug_mode = 'Y' THEN
                         pa_debug.write_file('Failed due to error in PA_FIN_PLAN_PUB.create_default_plan_txn_rec',5);
                     END IF;
                     raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                END IF;
    -- End of changes for Bug :- 2649474


    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.g_err_stage:='Exiting Create_Version';
       pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Return the out parameters

    px_budget_version_id := l_new_budget_version_id;

    x_proj_fp_option_id  := l_new_proj_fp_options_id;

    --Reset the error stack

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
--           pa_debug.g_err_stage:='Invalid Arguments Passed';
--           pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
           pa_debug.reset_curr_function;
           RETURN;

     WHEN Others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FIN_PLAN_PUB'
                                  ,p_procedure_name  => 'CREATE_VERSION');
          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
              pa_debug.write('Create_Version: ' || l_module_name,pa_debug.g_err_stage,5);
          END IF;
          pa_debug.reset_curr_function;
          RAISE;

END Create_Version;

/*===================================================================
This private procedure fetches start date of the period into which the
profile start period falls and end date of period into which period
end date falls.
===================================================================*/
PROCEDURE Get_start_and_end_dates(
            p_period_type              IN  VARCHAR2
            ,p_profile_start_date      IN  DATE
            ,p_profile_end_date        IN  DATE
            ,x_start_period_start_date OUT NOCOPY DATE --File.Sql.39 bug 4440895
            ,x_end_period_end_date     OUT NOCOPY DATE) --File.Sql.39 bug 4440895
AS
BEGIN

   IF p_period_type = PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA THEN

      BEGIN
          SELECT start_date
          INTO   x_start_period_start_date
          FROM   PA_PERIODS
          WHERE  p_profile_start_date BETWEEN start_date AND end_date;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
                SELECT MIN(START_DATE)
                INTO   x_start_period_start_date
                FROM   PA_PERIODS;
      END;

      BEGIN
          SELECT end_date
          INTO   x_end_period_end_date
          FROM   PA_PERIODS
          WHERE  p_profile_end_date BETWEEN start_date AND end_date;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
                 SELECT MAX(end_date)
                 INTO   x_end_period_end_date
                 FROM   PA_PERIODS;
      END;

   ELSIF P_PERIOD_TYPE = PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL THEN

          BEGIN
               --Fetch the start date of the period in to which p_profile_start_date falls
               SELECT start_date
               INTO   x_start_period_start_date
               FROM   GL_PERIOD_STATUSES g
                     ,PA_IMPLEMENTATIONS i
               WHERE  adjustment_period_flag = 'N'
               AND    g.application_id = pa_period_process_pkg.application_id
               AND    g.set_of_books_id = i.set_of_books_id
               AND    p_profile_start_date BETWEEN g.start_date AND g.end_date;
          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                        SELECT MIN(start_date)
                        INTO   x_start_period_start_date
                        FROM   GL_PERIOD_STATUSES g
                              ,PA_IMPLEMENTATIONS i
                        WHERE  adjustment_period_flag = 'N'
                        AND    g.application_id = pa_period_process_pkg.application_id
                        AND    g.set_of_books_id = i.set_of_books_id;
          END;

          BEGIN
               --Fetch the end date of the period in to which p_profile_end_date falls
               SELECT end_date
               INTO   x_end_period_end_date
               FROM   GL_PERIOD_STATUSES g
                     ,PA_IMPLEMENTATIONS i
               WHERE  adjustment_period_flag = 'N'
               AND    g.application_id = pa_period_process_pkg.application_id
               AND    g.set_of_books_id = i.set_of_books_id
               AND    p_profile_end_date BETWEEN g.start_date AND g.end_date;
          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                        SELECT MAX(end_date)
                        INTO   x_end_period_end_date--Selected the max(end_date) into x_end_period_end_date. Bug 3329002.
                        FROM   GL_PERIOD_STATUSES g
                              ,PA_IMPLEMENTATIONS i
                        WHERE  adjustment_period_flag = 'N'
                        AND    g.application_id = pa_period_process_pkg.application_id
                        AND    g.set_of_books_id = i.set_of_books_id;
          END;
   END IF;
END Get_start_and_end_dates;

/*===================================================================
  This procedure is called from Create_Fresh_Period_Profile api
===================================================================*/

PROCEDURE Get_Profile_Start_Date(
    p_profile_end_date    IN DATE
    ,p_period_type        IN VARCHAR2
    ,x_profile_start_date     OUT NOCOPY DATE --File.Sql.39 bug 4440895
    ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data               OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
AS
    l_profile_start_date     pa_periods.start_date%TYPE;
   -- l_end_period_start_date  pa_periods.end_date%TYPE;

BEGIN
/*
     pa_debug.g_err_stage := 'Entered get_profile_start_date';
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Get_Profile_Start_Date: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;
     pa_debug.g_err_stage := 'p_profile_end_date = ' || p_profile_end_date;
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Get_Profile_Start_Date: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;
     pa_debug.g_err_stage := 'p_period_type = ' || p_period_type;
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Get_Profile_Start_Date: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;
*/
     IF p_period_type = PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA THEN

          BEGIN
               --Select start date of period which is 51 periods before end period
               SELECT start_date
               INTO   l_profile_start_date
               FROM   pa_periods a
               WHERE  51= (SELECT COUNT(*) FROM pa_periods b
                           WHERE  a.start_date < b.start_date
                           AND    b.start_date <= p_profile_end_date );
          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    --IF no such period existing select the first available period
/*
                    pa_debug.g_err_stage := 'Fetching MIN of start date as profile start date';
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('Get_Profile_Start_Date: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;
*/
                    SELECT MIN(start_date)
                    INTO   l_profile_start_date
                    FROM   pa_periods;
          END;

     ELSIF p_period_type = PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL THEN

          BEGIN
               --Fetch the start date of the period in to which p_profile_end_date falls
               --Select start date of periods which is 51 periods before end period

               SELECT start_date
               INTO   l_profile_start_date
               FROM   GL_PERIOD_STATUSES a
                     ,PA_IMPLEMENTATIONS i
               WHERE  a.application_id = pa_period_process_pkg.application_id
               AND    a.set_of_books_id = i.set_of_books_id
               AND    a.adjustment_period_flag = 'N'
               AND    51= (SELECT COUNT(*) FROM GL_PERIOD_STATUSES b
                                               ,PA_IMPLEMENTATIONS i2
                           WHERE  b.adjustment_period_flag = 'N'
                           AND    b.application_id = pa_period_process_pkg.application_id
                           AND    b.set_of_books_id = i2.set_of_books_id
                           AND    a.start_date < b.start_date
                           AND    b.start_date <= p_profile_end_date);
          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    --IF no such period existing select the first available period
/*
                    pa_debug.g_err_stage := 'Fetching the first available period';
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('Get_Profile_Start_Date: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;
*/
                    SELECT MIN(start_date)
                    INTO   l_profile_start_date
                    FROM   GL_PERIOD_STATUSES a
                          ,PA_IMPLEMENTATIONS i
                    WHERE  a.application_id = pa_period_process_pkg.application_id
                    AND    a.set_of_books_id = i.set_of_books_id
                    AND    a.adjustment_period_flag = 'N';
          END;
     END IF;

    x_profile_start_date := l_profile_start_date;

    pa_debug.g_err_stage := 'Exiting Get_Profile_Start_Date';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Profile_Start_Date: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

EXCEPTION

   WHEN Others THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FIN_PLAN_PUB'
                        ,p_procedure_name  => 'Get_Profile_Start_Date');
        pa_debug.g_err_stage:='Unexpected Error' || SQLERRM;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Profile_Start_Date: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;
        RAISE;

END Get_Profile_Start_Date;

/*===================================================================
  This procedure is called from Create_Fresh_Period_Profile api
===================================================================*/
PROCEDURE Get_Profile_End_Date(
    p_profile_start_date    IN DATE
    ,p_period_type          IN VARCHAR2
    ,x_profile_end_date     OUT NOCOPY DATE --File.Sql.39 bug 4440895
    ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data             OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
AS
    l_profile_end_date           pa_periods.end_date%TYPE;
BEGIN
/*
     pa_debug.g_err_stage := 'Entered get_profile_end_date';
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Get_Profile_End_Date: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;
     pa_debug.g_err_stage := 'p_profile_start_date = ' || p_profile_start_date;
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Get_Profile_End_Date: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;
     pa_debug.g_err_stage := 'p_period_type = ' || p_period_type;
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Get_Profile_End_Date: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;
*/
     IF p_period_type = PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL THEN

             BEGIN
                  --Fetch the start date of the period in to which p_profile_start_date falls
                  --Select the 51st period's start date  from start period as profile end date

                  SELECT end_date
                  INTO   l_profile_end_date
                  FROM   GL_PERIOD_STATUSES a
                        ,PA_IMPLEMENTATIONS i
                  WHERE  a.application_id = pa_period_process_pkg.application_id
                  AND    a.set_of_books_id = i.set_of_books_id
                  AND    a.adjustment_period_flag = 'N'
                  AND    51= (SELECT COUNT(*) FROM GL_PERIOD_STATUSES b
                                                  ,PA_IMPLEMENTATIONS i2
                              WHERE  b.adjustment_period_flag = 'N'
                              AND    b.application_id = pa_period_process_pkg.application_id
                              AND    b.set_of_books_id = i2.set_of_books_id
                              AND    a.start_date > b.start_date
                              AND    b.start_date >= p_profile_start_date);
             EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       --IF no such period existing select the last available period
/*
                       pa_debug.g_err_stage := 'Fetching last period available';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write('Get_Profile_End_Date: ' || l_module_name,pa_debug.g_err_stage,3);
                       END IF;
*/
                       SELECT MAX(end_date)
                       INTO   l_profile_end_date
                       FROM   GL_PERIOD_STATUSES a
                             ,PA_IMPLEMENTATIONS i
                       WHERE  a.application_id = pa_period_process_pkg.application_id
                       AND    a.set_of_books_id = i.set_of_books_id
                       AND    a.adjustment_period_flag = 'N';
             END;

    ELSIF p_period_type = PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA THEN

             BEGIN
                  --Fetch the start date of the period in to which p_profile_start_date falls
                  --Select the 51st period's start date  from start period as profile end date

                  pa_debug.g_err_stage := 'Fetching profile end date';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write('Get_Profile_End_Date: ' || l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  SELECT end_date
                  INTO   l_profile_end_date
                  FROM   pa_periods a
                  WHERE  51= (SELECT COUNT(*) FROM pa_periods b
                              WHERE  a.start_date > b.start_date
                              AND    b.start_date >= p_profile_start_date );

             EXCEPTION
                       WHEN NO_DATA_FOUND THEN

                       --IF no such period existing select the last available period
/*
                       pa_debug.g_err_stage := 'Fetching last available period';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write('Get_Profile_End_Date: ' || l_module_name,pa_debug.g_err_stage,3);
                       END IF;
 */
                       SELECT MAX(end_date)
                       INTO   l_profile_end_date
                       FROM   pa_periods;
             END;
    END IF;

    x_profile_end_date := l_profile_end_date;

    pa_debug.g_err_stage := 'Exiting Get_Profile_End_Date';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Get_Profile_End_Date: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

EXCEPTION

   WHEN Others THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FIN_PLAN_PUB'
                        ,p_procedure_name  => 'Get_Profile_End_Date');
        pa_debug.g_err_stage:='Unexpected Error' ||SQLERRM;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Get_Profile_End_Date: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Profile_End_Date;


/*===================================================================
  This api creates records in pa_proj_period_profiles for a project
  and plan period type based on
  1)project start and end dates if both are available
  2)The  budget lines period distribution in the target project id
===================================================================*/

PROCEDURE Create_Fresh_Period_Profile(
    p_project_id           IN     NUMBER
    ,p_period_type         IN     VARCHAR2
    ,x_period_profile_id   OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count           OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data            OUT    NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
AS

    l_return_status      VARCHAR2(2000);
    l_msg_count          NUMBER :=0;
    l_msg_data           VARCHAR2(2000);
    l_data               VARCHAR2(2000);
    l_msg_index_out      NUMBER;
    l_debug_mode         VARCHAR2(30);


    l_start_date         gl_periods.start_date%TYPE;
    l_end_date           gl_periods.end_date%TYPE;
    l_profile_start_date gl_periods.start_date%TYPE;
    l_profile_end_date   gl_periods.end_date%TYPE;

    l_project_start_date       gl_periods.start_date%TYPE;
    l_project_completion_date  gl_periods.end_date%TYPE;

    l_number_of_periods     NUMBER;
    l_period_set_name       gl_sets_of_books.period_set_name%TYPE;
    l_accounted_period_type gl_sets_of_books.accounted_period_type%TYPE;
    l_pa_period_type        pa_implementations.pa_period_type%TYPE;

    l_plan_start_date       gl_periods.start_date%TYPE;
    l_plan_end_date         gl_periods.end_date%TYPE;

    l_period_profile_id     pa_budget_versions.period_profile_id%TYPE;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    pa_debug.set_err_stack('Create_Fresh_Period_Profile');
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Create_Fresh_Period_Profile: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;

    -- Check if  source project id is  NULL,if so throw an error message

    pa_debug.g_err_stage := 'Checking for valid parameters:';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL)  OR (p_period_type IS NULL) THEN

        pa_debug.g_err_stage := 'Project='||p_project_id;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;
        pa_debug.g_err_stage := 'Period_type = '||p_period_type;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                             p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    pa_debug.g_err_stage := 'Parameter validation complete';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Fetch project start and completion dates

    SELECT start_date
           ,completion_date
    INTO   l_project_start_date
           ,l_project_completion_date
    FROM   pa_projects_all
    WHERE  project_id = p_project_id;

    -- IF both start and completion dates are not null choose them as
    -- period profiles' start date and end dates

    IF (l_project_start_date IS NOT NULL) AND
       (l_project_completion_date IS NOT NULL)
    THEN
         pa_debug.g_err_stage := 'Calling get_start_and_end_dates procedure';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;

         Get_start_and_end_dates( p_period_type              => p_period_type
                                  ,p_profile_start_date      => l_project_start_date
                                  ,p_profile_end_date        => l_project_completion_date
                                  ,x_start_period_start_date => l_start_date
                                  ,x_end_period_end_date     => l_end_date);

    ELSE
         --Fetch MIN and MAX of start dates of pa_budget_lines

         pa_debug.g_err_stage := 'Selecting start and end dates from pa_budget_lines of the project';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;

         SELECT MIN (pbl.start_date)
                ,MAX(pbl.end_date)
         INTO   l_start_date
                ,l_end_date
         FROM   pa_budget_versions pbv             --bug#2708524 pa_resource_assignments pra
                ,pa_budget_lines pbl
         WHERE  pbv.project_id = p_project_id
         AND    pbl.budget_version_id = pbv.budget_version_id
         AND    PA_FIN_PLAN_UTILS.GET_TIME_PHASED_CODE(pbv.budget_version_id)
                          = DECODE(p_period_type,PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL,PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G,
                                                 PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA,PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P) ;


    END IF;

    -- IF l_start_date or l_end_date is null at this step, we would just return to
    -- the calling program as there is no way we can create period profile for  this project.

    IF l_start_date IS NULL OR l_end_date IS NULL THEN

            pa_debug.g_err_stage := 'Profile id cant be created';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;
            x_period_profile_id := NULL;
            pa_debug.reset_err_stack;
            RETURN;
     END IF;

    -- Fetch period_set_name, accounted_period_type and pa_period_type
    -- required for creation of period profiles as follows

    pa_debug.g_err_stage := 'Fetching accounted_period_type, pa_period_type';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    SELECT b.period_set_name
           ,DECODE(p_period_type,
                   PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA ,pa_period_type,
                   PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL ,accounted_period_type) --accounted_period_type
           ,DECODE(p_period_type,
                   PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA ,pa_period_type,
                   PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL ,NULL) --pa_period_type
    INTO  l_period_set_name
          ,l_accounted_period_type
          ,l_pa_period_type
    FROM  pa_implementations  a
          ,gl_sets_of_books  b
    WHERE  a.set_of_books_id = b.set_of_books_id;

    IF TRUNC(SYSDATE) BETWEEN l_start_date AND l_end_date THEN /*2690087*/

         --Select the number of periods between start and end date
/*
         pa_debug.g_err_stage := 'Fetching number of periods';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;
*/
         IF p_period_type = PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA THEN

               SELECT count(*)
               INTO   l_number_of_periods
               FROM   PA_PERIODS
               WHERE  start_date BETWEEN TRUNC(SYSDATE) AND l_end_date; /*2690087*/

         ELSIF p_period_type = PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL THEN

               SELECT count(*)
               INTO   l_number_of_periods
               FROM   GL_PERIOD_STATUSES a
                     ,PA_IMPLEMENTATIONS i
               WHERE  a.application_id = pa_period_process_pkg.application_id
               AND    a.set_of_books_id = i.set_of_books_id
               AND    a.adjustment_period_flag = 'N'
               AND    start_date BETWEEN TRUNC(SYSDATE) AND l_end_date; -- Bug :- 2623941, last condition has been put for 2623941
               /* Bug:- 2690087, sysdate has been changed to trunc(sysdate) */

         END IF;

         IF l_number_of_periods < 52 THEN

              --Select end date as start date of end period

              l_profile_end_date := l_end_date;

              pa_debug.g_err_stage := 'Calling get_profile_start_date';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

              Get_Profile_Start_Date (
                       p_profile_end_date    => l_profile_end_date
                       ,p_period_type        => p_period_type
                       ,x_profile_start_date => l_profile_start_date
                       ,x_return_status      => l_return_status
                       ,x_msg_count          => l_msg_count
                       ,x_msg_data           => l_msg_data );

               --If fetched l_profile_start_date is less than l_start_date then
               --choose l_start_date as l_profile_start_date

               IF l_profile_start_date < l_start_date THEN

                   l_profile_start_date := l_start_date;

               END IF;

         ELSIF l_number_of_periods >= 52 THEN

            /* Start of changes for the bug :- 2623941 */

              /* l_profile_start_date := SYSDATE; */  --commented out for bug :- 2623941

              BEGIN
                   --Fetch the start date of the period in to which sysdate falls

                   IF p_period_type = PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_GL THEN

                           SELECT start_date
                           INTO   l_profile_start_date
                           FROM   GL_PERIOD_STATUSES g
                                 ,PA_IMPLEMENTATIONS i
                           WHERE  adjustment_period_flag = 'N'
                           AND    g.application_id = pa_period_process_pkg.application_id
                           AND    g.set_of_books_id = i.set_of_books_id
                           AND    TRUNC(SYSDATE) BETWEEN g.start_date AND g.end_date; /* Bug:- 2690087 */

                   ELSIF p_period_type = PA_FP_CONSTANTS_PKG.G_PERIOD_TYPE_PA THEN

                          SELECT start_date
                          INTO   l_profile_start_date
                          FROM   PA_PERIODS
                          WHERE  TRUNC(SYSDATE) BETWEEN start_date AND end_date; /* Bug:- 2690087 */

                   END IF;

              EXCEPTION
                   WHEN Others THEN
                        pa_debug.g_err_stage:='Fetching start date of the period into which sysdate falls'||SQLERRM;
                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,5);
                        END IF;
                        RAISE;
              END;

            /* End of changes for the bug :- 2623941 */

              pa_debug.g_err_stage := 'Calling get_profile_end_date';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

              Get_Profile_End_Date (
                       p_profile_start_date =>  l_profile_start_date
                       ,p_period_type       =>  p_period_type
                       ,x_profile_end_date  =>  l_profile_end_date
                       ,x_return_status     =>  l_return_status
                       ,x_msg_count         =>  l_msg_count
                       ,x_msg_data          =>  l_msg_data );

               --If l_end_date is less than fetched l_profile_end_date then
               --choose l_end_date as l_profile_end_date

               IF l_end_date < l_profile_end_date THEN

                   l_profile_end_date := l_end_date;

               END IF;

         END IF; --l_number_of_periods

    ELSIF (l_start_date > TRUNC(SYSDATE))   THEN  /* Bug:- 2690087 */

         --Select start_date as start date of start period

         l_profile_start_date := l_start_date;

         pa_debug.g_err_stage := 'Calling get_profile_end_date';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;

         Get_Profile_End_Date (
                  p_profile_start_date =>  l_profile_start_date
                  ,p_period_type       =>  p_period_type
                  --,p_period_set_name   =>  l_period_set_name
                  ,x_profile_end_date  => l_profile_end_date
                  ,x_return_status     => l_return_status
                  ,x_msg_count         => l_msg_count
                  ,x_msg_data          => l_msg_data );

         --If l_end_date is less than fetched l_profile_end_date then
         --choose l_end_date as l_profile_end_date

         IF l_end_date < l_profile_end_date THEN

             l_profile_end_date := l_end_date;

         END IF;

    ELSIF (l_end_date < TRUNC(SYSDATE)) THEN /* Bug:- 2690087 */

         --Select end date as profile periods last period start date

         l_profile_end_date := l_end_date;

         pa_debug.g_err_stage := 'Calling get_profile_start_date';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;

         Get_Profile_Start_Date (
                  p_profile_end_date   =>  l_profile_end_date
                  ,p_period_type       =>  p_period_type
                  --,p_period_set_name   =>  l_period_set_name
                  ,x_profile_start_date => l_profile_start_date
                  ,x_return_status      => l_return_status
                  ,x_msg_count          => l_msg_count
                  ,x_msg_data           => l_msg_data );

          --If fetched l_profile_start_date is less than l_start_date then
          --choose l_start_date as l_profile_start_date

          IF l_profile_start_date < l_start_date THEN

              l_profile_start_date := l_start_date;

          END IF;

    END IF; --SYSDATE BETWEEN l_start_date AND l_end_date

    --Call maintain_prj_period_profile to create fresh period profile id

    --Null out  number of periods

    l_number_of_periods:= NULL;

    pa_debug.g_err_stage := 'Calling Maintain_Prj_Period_Profile api';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    Pa_Prj_Period_Profile_Utils.Maintain_Prj_Period_Profile(
                   p_project_id           => p_project_id
                   ,p_period_profile_type => PA_FP_CONSTANTS_PKG.G_PD_PROFILE_FIN_PLANNING
                   ,p_plan_period_type    => p_period_type
                   ,p_period_set_name     => l_period_set_name
                   ,p_gl_period_type      => l_accounted_period_type
                   ,p_pa_period_type      => l_pa_period_type
                   ,p_start_date          => l_profile_start_date
                   ,px_end_date           => l_profile_end_date
                   ,px_period_profile_id  => l_period_profile_id
                   ,p_commit_flag         => 'N'
                   ,px_number_of_periods  => l_number_of_periods
                   ,x_plan_start_date     => l_plan_start_date
                   ,x_plan_end_date       => l_plan_end_date
                   ,x_return_status       => l_return_status
                   ,x_msg_count           => l_msg_count
                   ,x_msg_data            => l_msg_data );

    --Return the newly fetched profile id

    x_period_profile_id := l_period_profile_id;
    pa_debug.g_err_stage := ' exiting Create_Fresh_Period_Profile';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;
    pa_debug.reset_err_stack;

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
           pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;
        x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.reset_err_stack;
        RAISE;

   WHEN Others THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FIN_PLAN_PUB'
                        ,p_procedure_name  => 'Create_Fresh_Period_Profile');
        pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Create_Fresh_Period_Profile: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;
        pa_debug.reset_err_stack;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Create_Fresh_Period_Profile;

/*=======================================================================================*/

 PROCEDURE INSERT_PLAN_LINES_TMP_BULK
                                  (p_res_assignment_tbl        IN   p_res_assignment_tbl_typ
                                  ,p_period_name_tbl           IN   p_period_name_tbl_typ
                                  ,p_start_date_tbl            IN   p_start_date_tbl_typ
                                  ,p_end_date_tbl              IN   p_end_date_tbl_typ
                                  ,p_currency_type             IN   pa_proj_periods_denorm.currency_type%TYPE
                                  ,p_currency_code_tbl         IN   p_currency_code_tbl_typ
                                  ,p_quantity_tbl              IN   p_quantity_tbl_typ
                                  ,p_raw_cost_tbl              IN   p_cost_tbl_typ
                                  ,p_burdened_cost_tbl         IN   p_cost_tbl_typ
                                  ,p_revenue_tbl               IN   p_cost_tbl_typ
                                  ,p_old_quantity_tbl          IN   p_quantity_tbl_typ
                                  ,p_old_raw_cost_tbl          IN   p_cost_tbl_typ
                                  ,p_old_burdened_cost_tbl     IN   p_cost_tbl_typ
                                  ,p_old_revenue_tbl           IN   p_cost_tbl_typ
                                  ,p_margin_tbl                IN   p_cost_tbl_typ
                                  ,p_margin_percent_tbl        IN   p_cost_tbl_typ
                                  ,p_old_margin_tbl            IN   p_cost_tbl_typ
                                  ,p_old_margin_percent_tbl    IN   p_cost_tbl_typ
                                  ,p_buck_period_code_tbl      IN   p_buck_period_code_tbl_typ
                                  ,p_parent_assignment_id_tbl  IN   p_res_assignment_tbl_typ
                                  ,p_delete_flag_tbl           IN   p_delete_flag_tbl_typ
                                  ,p_source_txn_curr_code_tbl  IN   p_currency_code_tbl_typ
                                  ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  ,x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                                  ,x_msg_data                  OUT  NOCOPY VARCHAR2  ) IS --File.Sql.39 bug 4440895

  l_stage NUMBER :=100 ;
  l_debug_mode VARCHAR2(1) ;

 BEGIN

     -- Set the error stack.
        pa_debug.set_err_stack('PA_FIN_PLAN_PUB.INSERT_PLAN_LINES_TMP_BULK');

     -- Get the Debug mode into local variable and set it to 'Y' if its NULL
        fnd_profile.get('pa_debug_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'Y');

     -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.set_process('INSERT_PLAN_LINES_TMP_BULK: ' || 'PLSQL','LOG',l_debug_mode);
        END IF;

        pa_debug.g_err_stage := TO_CHAR(l_stage)||':In PA_FIN_PLAN_PUB.INSERT_PLAN_LINES_TMP_BULK ';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('INSERT_PLAN_LINES_TMP_BULK: ' || l_module_name,pa_debug.g_err_stage,2);
        END IF;


         /*
          * Bulk Insert records into PA_FP_ELEMENTS table for the records fetched
          * from cursor top_task_cur.
          */
       pa_debug.g_err_stage := TO_CHAR(l_stage)||': INSERT into fin plan lines tmp';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('INSERT_PLAN_LINES_TMP_BULK: ' || l_module_name,pa_debug.g_err_stage,2);
       END IF;


   FORALL i in p_res_assignment_tbl.first..p_res_assignment_tbl.last
                 INSERT INTO PA_FIN_PLAN_LINES_TMP (
                          OBJECT_ID
                         ,OBJECT_TYPE_CODE
                         ,RESOURCE_ASSIGNMENT_ID
                         ,PERIOD_NAME
                         ,START_DATE
                         ,END_DATE
                         ,CURRENCY_TYPE
                         ,CURRENCY_CODE
                         ,QUANTITY
                         ,RAW_COST
                         ,BURDENED_COST
                         ,REVENUE
                         ,OLD_QUANTITY
                         ,OLD_RAW_COST
                         ,OLD_BURDENED_COST
                         ,OLD_REVENUE
                         ,MARGIN
                         ,MARGIN_PERCENTAGE
                         ,OLD_MARGIN
                         ,OLD_MARGIN_PERCENTAGE
                         ,BUCKETING_PERIOD_CODE
                         ,PARENT_ASSIGNMENT_ID
                         ,DELETE_FLAG
                         ,SOURCE_TXN_CURRENCY_CODE
                         )
               VALUES  (  p_res_assignment_tbl(i) /* Bug#  2677867-Object id should not be -1 even for FP */
                         ,PA_FP_CONSTANTS_PKG.G_OBJECT_TYPE_RES_ASSIGNMENT
                         ,p_res_assignment_tbl(i)
                         ,p_period_name_tbl(i)
                         ,p_start_date_tbl(i)
                         ,p_end_date_tbl(i)
                         ,p_currency_type
                         ,p_currency_code_tbl(i)
                         ,p_quantity_tbl(i)
                         ,p_raw_cost_tbl(i)
                         ,p_burdened_cost_tbl(i)
                         ,p_revenue_tbl(i)
                         ,p_old_quantity_tbl(i) /* Bug # 2738047 : Corrected the order of the table */
                         ,p_old_raw_cost_tbl(i)
                         ,p_old_burdened_cost_tbl(i)
                         ,p_old_revenue_tbl(i)
                         ,p_margin_tbl(i)
                         ,p_margin_percent_tbl(i)
                         ,p_old_margin_tbl(i)
                         ,p_old_margin_percent_tbl(i)
                         ,p_buck_period_code_tbl(i)
                         ,p_parent_assignment_id_tbl(i)
                         ,p_delete_flag_tbl(i)
                         ,p_source_txn_curr_code_tbl(i)) ;

                 pa_debug.g_err_stage := TO_CHAR(l_stage)||': INSERTED ' || sql%rowcount || ' recs into fin plan lines tmp';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write('INSERT_PLAN_LINES_TMP_BULK: ' || l_module_name,pa_debug.g_err_stage,2);
                 END IF;

          pa_debug.reset_err_stack;  -- bug 2815593
  EXCEPTION
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_COPY_FROM_PKG'
              ,p_procedure_name =>  pa_debug.G_Err_Stack );
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('INSERT_PLAN_LINES_TMP_BULK: ' || l_module_name,SQLERRM,4);
             pa_debug.write('INSERT_PLAN_LINES_TMP_BULK: ' || l_module_name,pa_debug.G_Err_Stack,4);
          END IF;
          pa_debug.reset_err_stack;

          raise FND_API.G_EXC_UNEXPECTED_ERROR ;

 END INSERT_PLAN_LINES_TMP_BULK ;


/*---------------------------------------------------------------------------------------------
  This procedure will populate the Lines Temp table pa_fin_plan_lines_tmp, with records from
  Budget Lines with appropriate values and call Maintain Matrix API to update the
  USER_ENTERED level records into pa_proj_periods_denorm table.
---------------------------------------------------------------------------------------------*/
PROCEDURE Call_Maintain_Plan_Matrix (
    p_budget_version_id    IN     pa_budget_versions.budget_version_id%TYPE
    ,p_data_source         IN     VARCHAR2
    ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data               OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
AS

     l_msg_count       NUMBER := 0;
     l_data            VARCHAR2(2000);
     l_msg_data        VARCHAR2(2000);
     l_msg_index_out   NUMBER;
     l_return_status   VARCHAR2(2000);
     l_debug_mode      VARCHAR2(30);

     l_project_id               pa_budget_versions.PROJECT_ID%TYPE;
     l_period_profile_id        pa_budget_versions.PERIOD_PROFILE_ID%TYPE;
     l_budget_version_type      pa_budget_versions.VERSION_TYPE%TYPE;
     l_fp_preference_code       pa_proj_fp_options.FIN_PLAN_PREFERENCE_CODE%TYPE;
     l_margin_derived_from_code pa_proj_fp_options.MARGIN_DERIVED_FROM_CODE%TYPE;

     l_plsql_max_array_size     NUMBER := 200;
     l_tbl_index                NUMBER := 1;

     /* Record Definitions */
     amt_rec pa_plan_matrix.amount_type_tabtyp;

     /* all table types */
     l_res_assignment_tbl      p_res_assignment_tbl_typ;
     l_period_name_tbl         p_period_name_tbl_typ ;
     l_start_date_tbl          p_start_date_tbl_typ;
     l_end_date_tbl            p_end_date_tbl_typ;

     l_txn_raw_cost_tbl        p_cost_tbl_typ;
     l_txn_burdened_cost_tbl   p_cost_tbl_typ;
     l_txn_revenue_tbl         p_cost_tbl_typ;
     l_txn_margin_tbl          p_cost_tbl_typ;
     l_txn_margin_percent_tbl  p_cost_tbl_typ;

     l_proj_raw_cost_tbl       p_cost_tbl_typ;
     l_proj_burdened_cost_tbl  p_cost_tbl_typ;
     l_proj_revenue_tbl        p_cost_tbl_typ;
     l_proj_margin_tbl         p_cost_tbl_typ;
     l_proj_margin_percent_tbl p_cost_tbl_typ;

     l_projfunc_raw_cost_tbl       p_cost_tbl_typ;
     l_projfunc_burd_cost_tbl      p_cost_tbl_typ;
     l_projfunc_revenue_tbl        p_cost_tbl_typ;
     l_projfunc_margin_tbl         p_cost_tbl_typ;
     l_projfunc_margin_percent_tbl p_cost_tbl_typ;

     l_quantity_tbl                p_quantity_tbl_typ;

     l_old_txn_raw_cost_tbl              p_cost_tbl_typ;
     l_old_txn_burdened_cost_tbl         p_cost_tbl_typ;
     l_old_txn_revenue_tbl               p_cost_tbl_typ;
     l_old_txn_margin_tbl                p_cost_tbl_typ;
     l_old_txn_margin_percent_tbl        p_cost_tbl_typ;


     l_old_proj_raw_cost_tbl             p_cost_tbl_typ;
     l_old_proj_burd_cost_tbl            p_cost_tbl_typ;
     l_old_proj_revenue_tbl              p_cost_tbl_typ;
     l_old_proj_margin_tbl               p_cost_tbl_typ;
     l_old_proj_margin_percent_tbl       p_cost_tbl_typ;

     l_old_projfunc_raw_cost_tbl         p_cost_tbl_typ;
     l_old_projfunc_burd_cost_tbl        p_cost_tbl_typ;
     l_old_projfunc_revenue_tbl          p_cost_tbl_typ;
     l_old_projfunc_margin_tbl           p_cost_tbl_typ;
     l_old_projfunc_margin_pct_tbl       p_cost_tbl_typ;

     l_old_quantity_tbl                  p_quantity_tbl_typ;

     l_txn_curr_code_tbl       p_currency_code_tbl_typ;
     l_proj_curr_code_tbl      p_currency_code_tbl_typ;
     l_projfunc_curr_code_tbl  p_currency_code_tbl_typ;

     l_buck_period_code_tbl    p_buck_period_code_tbl_typ;
     l_delete_flag_tbl         p_delete_flag_tbl_typ;
     l_parent_assignment_tbl   p_res_assignment_tbl_typ;

     /* 2602869: In the below cursors when populating the margin percentage,
        if the divisor, i.e. revenue is 0 then making it NULL, so that the
        margin % becomes NULL and there is no divide by 0 error. */

     CURSOR budget_lines_cur IS
     SELECT  pbl.resource_assignment_id
            ,period_name
            ,start_date
            ,end_date
            ,txn_currency_code
            ,project_currency_code
            ,projfunc_currency_code
            ,quantity
            ,txn_raw_cost
            ,txn_burdened_cost
            ,txn_revenue
            ,null txn_margin
            ,null txn_margin_percent
            ,project_raw_cost
            ,project_burdened_cost
            ,project_revenue
            ,(project_revenue - decode(l_margin_derived_from_code,'R',project_raw_cost
                                                                 ,'B',project_burdened_cost)) project_margin
            ,((project_revenue - decode(l_margin_derived_from_code,'R',project_raw_cost
                                                                  ,'B',project_burdened_cost))/
                                                                  decode(project_revenue,0,NULL,project_revenue))*100
               project_margin_percentage
            ,raw_cost
            ,burdened_cost
            ,revenue
            ,(revenue - decode(l_margin_derived_from_code,'R',raw_cost
                                                         ,'B',burdened_cost)) projfunc_margin
            ,((revenue - decode(l_margin_derived_from_code,'R',raw_cost
                                                          ,'B',burdened_cost))/
                                                           decode(revenue,0,NULL,revenue))*100 projfunc_margin_percentage
            ,null old_quantity
            ,null old_txn_raw_cost
            ,null old_txn_burdened_cost
            ,null old_txn_revenue
            ,null old_txn_margin
            ,null old_txn_margin_percent
            ,null old_proj_raw_cost
            ,null old_proj_burdened_cost
            ,null old_proj_revenue
            ,null old_proj_margin
            ,null old_proj_margin_percent
            ,null old_projfunc_raw_cost
            ,null old_projfunc_burdened_cost
            ,null old_projfunc_revenue
            ,null old_projfunc_margin
            ,null old_projfunc_margin_percent
            ,bucketing_period_code
            ,pra.parent_assignment_id
            ,null delete_flag
       FROM pa_resource_assignments pra, pa_budget_lines pbl
      WHERE pra.budget_version_id = p_budget_version_id
        AND pra.resource_assignment_id = pbl.resource_assignment_id;

     CURSOR rollup_tmp_cur IS
     SELECT  frt.resource_assignment_id
            ,period_name
            ,start_date
            ,end_date
            ,txn_currency_code
            ,project_currency_code
            ,projfunc_currency_code
            ,quantity
            ,txn_raw_cost
            ,txn_burdened_cost
            ,txn_revenue
            ,null txn_margin
            ,null txn_margin_percent
            ,project_raw_cost
            ,project_burdened_cost
            ,project_revenue
            ,(project_revenue - decode(l_margin_derived_from_code,'R',project_raw_cost
                                                                 ,'B',project_burdened_cost)) project_margin
            ,((project_revenue - decode(l_margin_derived_from_code,'R',project_raw_cost
                                                                  ,'B',project_burdened_cost))/
                                                                  decode(project_revenue,0,NULL,project_revenue))*100
               project_margin_percentage
            ,projfunc_raw_cost
            ,projfunc_burdened_cost
            ,projfunc_revenue
            ,(projfunc_revenue - decode(l_margin_derived_from_code,'R',projfunc_raw_cost
                                                                  ,'B',projfunc_burdened_cost)) projfunc_margin
            ,((projfunc_revenue - decode(l_margin_derived_from_code,'R',projfunc_raw_cost
                                                                   ,'B',projfunc_burdened_cost))/
                                                                   decode(projfunc_revenue,0,NULL,projfunc_revenue))*100
               projfunc_margin_percentage
            ,old_quantity
            ,NULL old_txn_raw_cost
            ,NULL old_txn_burdened_cost
            ,null old_txn_revenue
            ,null old_txn_margin
            ,null old_txn_margin_percent
            ,old_proj_raw_cost
            ,old_proj_burdened_cost
            ,old_proj_revenue
            ,(old_proj_revenue - decode(l_margin_derived_from_code,'R',old_proj_raw_cost
                                                                   ,'B',old_proj_burdened_cost)) old_project_margin
            ,((old_proj_revenue - decode(l_margin_derived_from_code,'R',old_proj_raw_cost
                                                                   ,'B',old_proj_burdened_cost))/
                                                                   decode(old_proj_revenue,0,NULL,old_proj_revenue))*100
               old_project_margin_percentage
            ,old_projfunc_raw_cost
            ,old_projfunc_burdened_cost
            ,old_projfunc_revenue
            ,(old_projfunc_revenue - decode(l_margin_derived_from_code,'R',old_projfunc_raw_cost
                                                                   ,'B',old_projfunc_burdened_cost)) projfunc_margin
            ,((old_projfunc_revenue - decode(l_margin_derived_from_code,'R',old_projfunc_raw_cost
                                                                    ,'B',old_projfunc_burdened_cost))/
                                                                 decode(old_projfunc_revenue,0,NULL,old_projfunc_revenue))*100
               old_projfunc_margin_percentage
            ,bucketing_period_code
            ,pra.parent_assignment_id
            ,delete_flag
       FROM pa_resource_assignments pra, pa_fp_rollup_tmp frt
      WHERE pra.budget_version_id = p_budget_version_id
        AND pra.resource_assignment_id = frt.resource_assignment_id;

BEGIN


     -- Set the error stack.
        pa_debug.set_err_stack('PA_FIN_PLAN_PUB.Call_Maintain_Plan_Matrix');

     -- Get the Debug mode into local variable and set it to 'Y'if its NULL
        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'Y');

     -- Initialize the return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.set_process('Call_Maintain_Plan_Matrix: ' || 'PLSQL','LOG',l_debug_mode);
         END IF;

         pa_debug.g_err_stage := 'Getting the project and profile id';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;

     /* Get the value of the Project_ID and the Period Profile ID for the
        Budget Version. */

           SELECT project_id,
                  period_profile_id
             INTO l_project_id,
                  l_period_profile_id
             FROM pa_budget_versions
            WHERE budget_version_id = p_budget_version_id;

     /* Get the value of the Preference code of the Budget Version. Margin and
        Margin % have to be populated only if the Preference code is
        'COST_AND_REV_SAME'. */
         pa_debug.g_err_stage := 'Getting the fin plan preference code';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;


         SELECT  fin_plan_preference_code, margin_derived_from_code
           INTO  l_fp_preference_code, l_margin_derived_from_code
           FROM  pa_proj_fp_options
          WHERE  fin_plan_version_id = p_budget_version_id;


          IF (p_data_source = PA_FP_CONSTANTS_PKG.G_DATA_SOURCE_BUDGET_LINE) THEN
              pa_debug.g_err_stage := 'opening budget_lines_cur';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

              OPEN budget_lines_cur;
          ELSIF (p_data_source =  PA_FP_CONSTANTS_PKG.G_DATA_SOURCE_ROLLUP_TMP) THEN
              pa_debug.g_err_stage := 'opening rollup_tmp_cur';
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,3);
              END IF;

              OPEN rollup_tmp_cur;
          END IF;

          delete from PA_FIN_PLAN_LINES_TMP;
          LOOP
               IF (p_data_source = PA_FP_CONSTANTS_PKG.G_DATA_SOURCE_BUDGET_LINE) THEN

                      pa_debug.g_err_stage := 'fetching from budget_lines_cur';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,3);
                      END IF;

                       FETCH budget_lines_cur
                       BULK COLLECT INTO
                              l_res_assignment_tbl
                             ,l_period_name_tbl
                             ,l_start_date_tbl
                             ,l_end_date_tbl
                             ,l_txn_curr_code_tbl
                             ,l_proj_curr_code_tbl
                             ,l_projfunc_curr_code_tbl
                             ,l_quantity_tbl
                             ,l_txn_raw_cost_tbl
                             ,l_txn_burdened_cost_tbl
                             ,l_txn_revenue_tbl
                             ,l_txn_margin_tbl
                             ,l_txn_margin_percent_tbl
                             ,l_proj_raw_cost_tbl
                             ,l_proj_burdened_cost_tbl
                             ,l_proj_revenue_tbl
                             ,l_proj_margin_tbl
                             ,l_proj_margin_percent_tbl
                             ,l_projfunc_raw_cost_tbl
                             ,l_projfunc_burd_cost_tbl
                             ,l_projfunc_revenue_tbl
                             ,l_projfunc_margin_tbl
                             ,l_projfunc_margin_percent_tbl
                             ,l_old_quantity_tbl
                             ,l_old_txn_raw_cost_tbl
                             ,l_old_txn_burdened_cost_tbl
                             ,l_old_txn_revenue_tbl
                             ,l_old_txn_margin_tbl
                             ,l_old_txn_margin_percent_tbl
                             ,l_old_proj_raw_cost_tbl
                             ,l_old_proj_burd_cost_tbl
                             ,l_old_proj_revenue_tbl
                             ,l_old_proj_margin_tbl
                             ,l_old_proj_margin_percent_tbl
                             ,l_old_projfunc_raw_cost_tbl
                             ,l_old_projfunc_burd_cost_tbl
                             ,l_old_projfunc_revenue_tbl
                             ,l_old_projfunc_margin_tbl
                             ,l_old_projfunc_margin_pct_tbl
                             ,l_buck_period_code_tbl
                             ,l_parent_assignment_tbl
                             ,l_delete_flag_tbl
                         LIMIT l_plsql_max_array_size;

               ELSIF (p_data_source =  PA_FP_CONSTANTS_PKG.G_DATA_SOURCE_ROLLUP_TMP) THEN

                      pa_debug.g_err_stage := 'fetching from rollup_tmp_cur';
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,3);
                      END IF;

                       FETCH rollup_tmp_cur
                       BULK COLLECT INTO
                              l_res_assignment_tbl
                             ,l_period_name_tbl
                             ,l_start_date_tbl
                             ,l_end_date_tbl
                             ,l_txn_curr_code_tbl
                             ,l_proj_curr_code_tbl
                             ,l_projfunc_curr_code_tbl
                             ,l_quantity_tbl
                             ,l_txn_raw_cost_tbl
                             ,l_txn_burdened_cost_tbl
                             ,l_txn_revenue_tbl
                             ,l_txn_margin_tbl
                             ,l_txn_margin_percent_tbl
                             ,l_proj_raw_cost_tbl
                             ,l_proj_burdened_cost_tbl
                             ,l_proj_revenue_tbl
                             ,l_proj_margin_tbl
                             ,l_proj_margin_percent_tbl
                             ,l_projfunc_raw_cost_tbl
                             ,l_projfunc_burd_cost_tbl
                             ,l_projfunc_revenue_tbl
                             ,l_projfunc_margin_tbl
                             ,l_projfunc_margin_percent_tbl
                             ,l_old_quantity_tbl
                             ,l_old_txn_raw_cost_tbl
                             ,l_old_txn_burdened_cost_tbl
                             ,l_old_txn_revenue_tbl
                             ,l_old_txn_margin_tbl
                             ,l_old_txn_margin_percent_tbl
                             ,l_old_proj_raw_cost_tbl
                             ,l_old_proj_burd_cost_tbl
                             ,l_old_proj_revenue_tbl
                             ,l_old_proj_margin_tbl
                             ,l_old_proj_margin_percent_tbl
                             ,l_old_projfunc_raw_cost_tbl
                             ,l_old_projfunc_burd_cost_tbl
                             ,l_old_projfunc_revenue_tbl
                             ,l_old_projfunc_margin_tbl
                             ,l_old_projfunc_margin_pct_tbl
                             ,l_buck_period_code_tbl
                             ,l_parent_assignment_tbl
                             ,l_delete_flag_tbl
                         LIMIT l_plsql_max_array_size;
               END IF;

                 pa_debug.g_err_stage := 'Data Source is Budget Lines';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,3);
                 END IF;

                /* Insert the Transaction, Project and Project Functional currency
                   columns as rows into the Lines Temp table one after the other selecting
                   from the Budget Lines. So, three inserts statements are required.   */

                /* Inserting the Transaction Currency records into the Lines Temp table with
                   the Amount Type code as 'TRANSACTION'. */

                 pa_debug.g_err_stage := 'Inserting Transaction Currency Records';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,3);
                 END IF;

               IF NVL(l_start_date_tbl.last,0) >= 1 THEN
                       /* insert txn amounts */
                       pa_debug.g_err_stage := 'calling insert_plan_lines_tmp_bulk for txn curr';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,3);
                       END IF;

                       insert_plan_lines_tmp_bulk(
                               p_res_assignment_tbl         =>   l_res_assignment_tbl
                              ,p_period_name_tbl            =>   l_period_name_tbl
                              ,p_start_date_tbl             =>   l_start_date_tbl
                              ,p_end_date_tbl               =>   l_end_date_tbl
                              ,p_currency_type              =>   PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_TRANSACTION
                              ,p_currency_code_tbl          =>   l_txn_curr_code_tbl
                              ,p_quantity_tbl               =>   l_quantity_tbl
                              ,p_raw_cost_tbl               =>   l_txn_raw_cost_tbl
                              ,p_burdened_cost_tbl          =>   l_txn_burdened_cost_tbl
                              ,p_revenue_tbl                =>   l_txn_revenue_tbl
                              ,p_old_quantity_tbl           =>   l_old_quantity_tbl
                              ,p_old_raw_cost_tbl           =>   l_old_txn_raw_cost_tbl
                              ,p_old_burdened_cost_tbl      =>   l_old_txn_burdened_cost_tbl
                              ,p_old_revenue_tbl            =>   l_old_txn_revenue_tbl
                              ,p_margin_tbl                 =>   l_txn_margin_tbl
                              ,p_margin_percent_tbl         =>   l_txn_margin_percent_tbl
                              ,p_old_margin_tbl             =>   l_old_txn_margin_tbl
                              ,p_old_margin_percent_tbl     =>   l_old_txn_margin_percent_tbl
                              ,p_buck_period_code_tbl       =>   l_buck_period_code_tbl
                              ,p_parent_assignment_id_tbl   =>   l_parent_assignment_tbl
                              ,p_delete_flag_tbl            =>   l_delete_flag_tbl
                              ,p_source_txn_curr_code_tbl   =>   l_txn_curr_code_tbl
                              ,x_return_status              =>   l_return_status
                              ,x_msg_count                  =>   l_msg_count
                              ,x_msg_data                   =>   l_msg_data );

                       /* insert project amounts */
                       pa_debug.g_err_stage := 'calling insert_plan_lines_tmp_bulk for proj curr';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,3);
                       END IF;

                       insert_plan_lines_tmp_bulk(
                               p_res_assignment_tbl        =>   l_res_assignment_tbl
                              ,p_period_name_tbl           =>   l_period_name_tbl
                              ,p_start_date_tbl            =>   l_start_date_tbl
                              ,p_end_date_tbl              =>   l_end_date_tbl
                              ,p_currency_type             =>   PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_PROJECT
                              ,p_currency_code_tbl         =>   l_proj_curr_code_tbl
                              ,p_quantity_tbl              =>   l_quantity_tbl
                              ,p_raw_cost_tbl              =>   l_proj_raw_cost_tbl
                              ,p_burdened_cost_tbl         =>   l_proj_burdened_cost_tbl
                              ,p_revenue_tbl               =>   l_proj_revenue_tbl
                              ,p_old_quantity_tbl          =>   l_old_quantity_tbl
                              ,p_old_raw_cost_tbl          =>   l_old_proj_raw_cost_tbl
                              ,p_old_burdened_cost_tbl     =>   l_old_proj_burd_cost_tbl
                              ,p_old_revenue_tbl           =>   l_old_proj_revenue_tbl
                              ,p_margin_tbl                =>   l_proj_margin_tbl
                              ,p_margin_percent_tbl        =>   l_proj_margin_percent_tbl
                              ,p_old_margin_tbl            =>   l_old_proj_margin_tbl
                              ,p_old_margin_percent_tbl    =>   l_old_proj_margin_percent_tbl
                              ,p_buck_period_code_tbl      =>   l_buck_period_code_tbl
                              ,p_parent_assignment_id_tbl  =>   l_parent_assignment_tbl
                              ,p_delete_flag_tbl           =>   l_delete_flag_tbl
                              ,p_source_txn_curr_code_tbl  =>   l_txn_curr_code_tbl
                              ,x_return_status             =>   l_return_status
                              ,x_msg_count                 =>   l_msg_count
                              ,x_msg_data                  =>   l_msg_data );

                       /* insert project functional amounts */
                       pa_debug.g_err_stage := 'calling insert_plan_lines_tmp_bulk for projfunc curr';
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                          pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,3);
                       END IF;


                       insert_plan_lines_tmp_bulk(
                               p_res_assignment_tbl         =>   l_res_assignment_tbl
                              ,p_period_name_tbl            =>   l_period_name_tbl
                              ,p_start_date_tbl             =>   l_start_date_tbl
                              ,p_end_date_tbl               =>   l_end_date_tbl
                              ,p_currency_type              =>   PA_FP_CONSTANTS_PKG.G_CURRENCY_TYPE_PROJFUNC
                              ,p_currency_code_tbl          =>   l_projfunc_curr_code_tbl
                              ,p_quantity_tbl               =>   l_quantity_tbl
                              ,p_raw_cost_tbl               =>   l_projfunc_raw_cost_tbl
                              ,p_burdened_cost_tbl          =>   l_projfunc_burd_cost_tbl
                              ,p_revenue_tbl                =>   l_projfunc_revenue_tbl
                              ,p_old_quantity_tbl           =>   l_old_quantity_tbl
                              ,p_old_raw_cost_tbl           =>   l_old_projfunc_raw_cost_tbl
                              ,p_old_burdened_cost_tbl      =>   l_old_projfunc_burd_cost_tbl
                              ,p_old_revenue_tbl            =>   l_old_projfunc_revenue_tbl
                              ,p_margin_tbl                 =>   l_projfunc_margin_tbl
                              ,p_margin_percent_tbl         =>   l_projfunc_margin_percent_tbl
                              ,p_old_margin_tbl             =>   l_old_projfunc_margin_tbl
                              ,p_old_margin_percent_tbl     =>   l_old_projfunc_margin_pct_tbl
                              ,p_buck_period_code_tbl       =>   l_buck_period_code_tbl
                              ,p_parent_assignment_id_tbl   =>   l_parent_assignment_tbl
                              ,p_delete_flag_tbl            =>   l_delete_flag_tbl
                              ,p_source_txn_curr_code_tbl   =>   l_txn_curr_code_tbl
                              ,x_return_status              =>   l_return_status
                              ,x_msg_count                  =>   l_msg_count
                              ,x_msg_data                   =>   l_msg_data );

               END IF; /* end of only if something is fetched */

               EXIT WHEN nvl(l_start_date_tbl.last,0) < l_plsql_max_array_size;

        END LOOP; -- loop for bulk insert

     IF (p_data_source = PA_FP_CONSTANTS_PKG.G_DATA_SOURCE_BUDGET_LINE) THEN
         pa_debug.g_err_stage := 'closing budget_lines_cur';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;

         CLOSE budget_lines_cur;
     ELSIF (p_data_source =  PA_FP_CONSTANTS_PKG.G_DATA_SOURCE_ROLLUP_TMP) THEN
         pa_debug.g_err_stage := 'closing rollup_tmp_cur';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,3);
         END IF;

         CLOSE rollup_tmp_cur;
     END IF;

     IF (p_data_source = PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST) THEN

          -- This portion to be filled up by the HQ team.

          null;

     END IF; /* End IF of check for the Data Source. */


     /* Call PA_PLAN_MATRIX.MAINTAIN_PLAN_MATRIX to populate the Denorm table
        'PA_PROJ_PERIODS_DENORM' in order to report in a matrix format if the
        Plan version is tim phased by PA or GL periods. */

     /* First populate the amt_rec PL/SQL table with the Amount Type and the
        Amount Sub Type codes based on the Budget Version Type
        to pass to the Maintain Plan Matrix procedure. */

          pa_debug.g_err_stage := 'Populating the Amount Types and Amount Sub Types';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          SELECT version_type
            INTO l_budget_version_type
            FROM PA_BUDGET_VERSIONS
           WHERE pa_budget_versions.budget_version_id = p_budget_version_id;

          amt_rec(l_tbl_index).amount_type_code := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_QUANTITY;
          amt_rec(l_tbl_index).amount_subtype_code := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_QUANTITY;
          amt_rec(l_tbl_index).amount_type_id := pa_fin_plan_utils.get_amttype_id(p_amt_typ_code => PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_QUANTITY);
          amt_rec(l_tbl_index).amount_subtype_id := pa_fin_plan_utils.get_amttype_id(p_amt_typ_code => PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_QUANTITY);

          IF (l_budget_version_type = 'ALL') THEN

                  l_tbl_index := l_tbl_index + 1;
                  amt_rec(l_tbl_index).amount_type_code := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST;
                  amt_rec(l_tbl_index).amount_subtype_code := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_RAW_COST;
                  amt_rec(l_tbl_index).amount_type_id := pa_fin_plan_utils.get_amttype_id(p_amt_typ_code => PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST);
                  amt_rec(l_tbl_index).amount_subtype_id := pa_fin_plan_utils.get_amttype_id(p_amt_typ_code => PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_RAW_COST);

                  l_tbl_index := l_tbl_index + 1;
                  amt_rec(l_tbl_index).amount_type_code := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST;
                  amt_rec(l_tbl_index).amount_subtype_code := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_BURD_COST;
                  amt_rec(l_tbl_index).amount_type_id := pa_fin_plan_utils.get_amttype_id(p_amt_typ_code => PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST);
                  amt_rec(l_tbl_index).amount_subtype_id := pa_fin_plan_utils.get_amttype_id(p_amt_typ_code => PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_BURD_COST);

                  l_tbl_index := l_tbl_index + 1;
                  amt_rec(l_tbl_index).amount_type_code := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_REVENUE;
                  amt_rec(l_tbl_index).amount_subtype_code := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_REVENUE;
                  amt_rec(l_tbl_index).amount_type_id := pa_fin_plan_utils.get_amttype_id(p_amt_typ_code => PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_REVENUE);
                  amt_rec(l_tbl_index).amount_subtype_id := pa_fin_plan_utils.get_amttype_id(p_amt_typ_code => PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_REVENUE);

          ELSIF (l_budget_version_type = 'COST') THEN

                  l_tbl_index := l_tbl_index + 1;
                  amt_rec(l_tbl_index).amount_type_code := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST;
                  amt_rec(l_tbl_index).amount_subtype_code := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_RAW_COST;
                  amt_rec(l_tbl_index).amount_type_id := pa_fin_plan_utils.get_amttype_id(p_amt_typ_code => PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST);
                  amt_rec(l_tbl_index).amount_subtype_id := pa_fin_plan_utils.get_amttype_id(p_amt_typ_code => PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_RAW_COST);

                  l_tbl_index := l_tbl_index + 1;
                  amt_rec(l_tbl_index).amount_type_code := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST;
                  amt_rec(l_tbl_index).amount_subtype_code := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_BURD_COST;
                  amt_rec(l_tbl_index).amount_type_id := pa_fin_plan_utils.get_amttype_id(p_amt_typ_code => PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_COST);
                  amt_rec(l_tbl_index).amount_subtype_id := pa_fin_plan_utils.get_amttype_id(p_amt_typ_code => PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_BURD_COST);

          ELSIF (l_budget_version_type = 'REVENUE') THEN

                  l_tbl_index := l_tbl_index + 1;
                  amt_rec(l_tbl_index).amount_type_code := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_REVENUE;
                  amt_rec(l_tbl_index).amount_subtype_code := PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_REVENUE;
                  amt_rec(l_tbl_index).amount_type_id := pa_fin_plan_utils.get_amttype_id(p_amt_typ_code => PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_REVENUE);
                  amt_rec(l_tbl_index).amount_subtype_id := pa_fin_plan_utils.get_amttype_id(p_amt_typ_code => PA_FP_CONSTANTS_PKG.G_AMOUNT_TYPE_REVENUE);

          END IF;

          /* Calling the Maintain_Plan_Matrix API to recalculate profile period amounts as well
             as preceding and succeeding period amounts in the Denorm Table. */

          pa_debug.g_err_stage := 'Calling the Maintain Plan Matrix procedure';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

          PA_PLAN_MATRIX.Maintain_Plan_Matrix(
                             p_amount_type_tab   => amt_rec,
                             p_period_profile_id => l_period_profile_id,
                             p_prior_period_flag => 'N',
                             p_commit_flag       => 'N',
                             p_budget_version_id => p_budget_version_id,
                             p_project_id        => l_project_id,
                             p_debug_mode        => l_debug_mode,
                             p_add_msg_in_stack  => 'Y',
                             p_calling_module    => PA_FP_CONSTANTS_PKG.G_PD_PROFILE_FIN_PLANNING,
                             x_return_status     => x_return_status,
                             x_msg_count         => x_msg_count,
                             x_msg_data          => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            Raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

          pa_debug.reset_err_stack;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_PUB',
                                 p_procedure_name   => 'Call_Maintain_Plan_Matrix');

        pa_debug.g_err_stage:='Unexpected Error';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Call_Maintain_Plan_Matrix: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;
        pa_debug.reset_err_stack;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;

END Call_Maintain_Plan_Matrix;

/*=============================================================================
 This api would be called in the context of workplan. This procedure deletes
 any exsiting res list assignment and creates new assignment for the input
 resource list.
==============================================================================*/

PROCEDURE Refresh_res_list_assignment (
     p_project_id             IN    pa_budget_versions.project_id%TYPE
    ,p_resource_list_id       IN    pa_budget_versions.resource_list_id%TYPE
    ,x_return_status          OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count              OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data               OUT   NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
AS

    --Start of variables used for debugging
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER := 0;
    l_msg_index_out      NUMBER;
    l_data               VARCHAR2(2000);
    l_msg_data           VARCHAR2(2000);
    l_debug_mode         VARCHAR2(30);

    -- Variables declared for calling plsql apis
    l_err_code           NUMBER;
    l_err_stage          VARCHAR2(2000);
    l_err_stack          VARCHAR2(2000);

    -- Other variables
    l_existing_rl_assignment_id     pa_resource_list_assignments.resource_list_assignment_id%TYPE;
    l_new_rl_assignment_id          pa_resource_list_assignments.resource_list_assignment_id%TYPE;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function
    pa_debug.set_curr_function(
                p_function   =>'PA_FIN_PLAN_PUB.Refresh_res_list_assignment'
               ,p_debug_mode => l_debug_mode );


    -- Check for business rule violations

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write('Refresh_res_list_assignment: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id       IS NULL) OR
       (p_resource_list_id IS NULL)
    THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='p_project_id = '|| p_project_id;
           pa_debug.write('Refresh_res_list_assignment: ' || l_module_name,pa_debug.g_err_stage,5);

           pa_debug.g_err_stage:='p_resource_list_id = '|| p_resource_list_id;
           pa_debug.write('Refresh_res_list_assignment: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- Check if there already exists a resource list assignment

    BEGIN
        SELECT resource_list_assignment_id
        INTO   l_existing_rl_assignment_id
        FROM   pa_resource_list_assignments
        WHERE  project_id = p_project_id
        AND    resource_list_id = p_resource_list_id
        AND    used_in_wp_flag  = 'Y' ;

        -- If resource list assignment exists it needs to be deleted first
        l_err_code        :=    0;
        l_err_stage       :=    null;
        l_err_stack       :=    null;

        PA_RES_LIST_ASSIGNMENTS.Delete_Rl_Assgmt(
                 X_Resource_list_Assgmt_id   =>  l_existing_rl_assignment_id
                ,X_err_code                  =>  l_err_code
                ,X_err_stage                 =>  l_err_stage
                ,x_err_stack                 =>  l_err_stack );
        IF  l_err_code <> 0 THEN
            -- Add the error message
            IF l_err_stage IS NOT NULL THEN
                PA_UTILS.ADD_MESSAGE(
                         p_app_short_name => 'PA'
                        ,p_msg_name       => l_err_stage);
            END IF;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
    EXCEPTION
        When No_Data_Found Then
            null;    -- do nothing
    END;

    -- Create new res list assignment for the passed resource list

    PA_RES_LIST_ASSIGNMENTS.Create_Rl_Assgmt (
               X_project_id               =>  p_project_id
              ,X_resource_list_id         =>  p_resource_list_id
              ,X_resource_list_Assgmt_id  =>  l_new_rl_assignment_id
              ,X_err_code                 =>  l_err_code
              ,X_err_stage                =>  l_err_stage
              ,X_err_stack                =>  l_err_stack );

    IF  l_err_code <> 0 THEN
        -- Add the error message
        IF l_err_stage IS NOT NULL THEN
            PA_UTILS.ADD_MESSAGE(
                     p_app_short_name => 'PA'
                    ,p_msg_name       => l_err_stage);
        END IF;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting Refresh_res_list_assignment';
        pa_debug.write('Refresh_res_list_assignment: ' || l_module_name,pa_debug.g_err_stage,3);

        -- reset curr function
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
           pa_debug.g_err_stage:='Invalid Arguments Passed Or called api raised an error';
           pa_debug.write('Refresh_res_list_assignment: ' || l_module_name,pa_debug.g_err_stage,5);

           -- reset curr function
           pa_debug.reset_curr_function;
       END IF;
       RETURN;
   WHEN Others THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FIN_PLAN_PUB'
                               ,p_procedure_name  => 'Refresh_res_list_assignment');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('Refresh_res_list_assignment: ' || l_module_name,pa_debug.g_err_stage,5);

           -- reset curr function
           pa_debug.reset_curr_function;
       END IF;
       RAISE;
END Refresh_res_list_assignment;

 /* bug 4865563: Added the following procedure which accepts a
    * budget version id and inserts records in the new IPM table PA_RESOURCE_ASGN_CURR
    * for the resource assignments which do not have budget lines and hence
    * not taken care by the new plannig transaction level entiy maintenance API.
    * These resource assignments are inserted with default currency as applicable.
    *
    * This API is called from upgrade_budget_versions API[PAFPUPGB.pls].
    */


   PROCEDURE create_default_plan_txn_rec
             (p_budget_version_id          IN    pa_budget_versions.budget_version_id%TYPE,
              p_calling_module             IN    VARCHAR2,
	      p_ra_id_tbl                  IN    SYSTEM.PA_NUM_TBL_TYPE         DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),  /* 7161809 */
	      p_curr_code_tbl              IN    SYSTEM.PA_VARCHAR2_15_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE(),  /* 7161809 */
	      p_expenditure_type_tbl       IN    SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE(), /* Enc */
              x_return_status              OUT NOCOPY  VARCHAR2,
              x_msg_count                  OUT NOCOPY  NUMBER,
              x_msg_data                   OUT NOCOPY  VARCHAR2)
   IS

   l_return_status                 VARCHAR2(2000);
   l_msg_count                     NUMBER :=0;
   l_msg_data                      VARCHAR2(2000);
   l_data                          VARCHAR2(2000);
   l_msg_index_out                 NUMBER;
   l_debug_mode                    VARCHAR2(30);

   CURSOR def_plan_txn_to_ins_csr
   IS
   SELECT ra.resource_assignment_id
   FROM   pa_resource_assignments ra
   WHERE  ra.budget_version_id = p_budget_version_id
   AND    NOT EXISTS (SELECT 'X'
                      FROM   pa_resource_asgn_curr rac
                      WHERE  rac.resource_assignment_id = ra.resource_assignment_id
                      AND    rac.budget_version_id = ra.budget_version_id);

   --Bug 8223977
   CURSOR rate_update_cur
   IS
   SELECT prac.resource_assignment_id,
          prac.txn_raw_cost_rate_override,
          prac.txn_burden_cost_rate_override,
          prac.txn_bill_rate_override
   FROM pa_resource_asgn_curr prac,
        pa_resource_asgn_curr_tmp pract
   WHERE prac.resource_assignment_id = pract.resource_assignment_id
     and prac.budget_version_id = pract.budget_version_id;

   l_def_plan_txn_ra_id_tbl        SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
   l_def_txn_curr_code             pa_budget_lines.txn_currency_code%TYPE;
   l_curr_code_temp_tbl            SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();   /* 7161809 */
   l_expenditure_type_tbl          SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();   /* EnC */
   l_agr_curr_code                 pa_agreements_all.agreement_currency_code%TYPE;
   l_proj_curr_code                pa_projects_all.project_currency_code%TYPE;
   l_pfunc_curr_code               pa_projects_all.projfunc_currency_code%TYPE;

   l_ci_id                         pa_budget_versions.ci_id%TYPE;
   l_agreement_id                  pa_budget_versions.agreement_id%TYPE;
   l_app_rev_flag                  pa_budget_versions.approved_rev_plan_type_flag%TYPE;

   -- IPM Arch Enhancement - Bug 4865563
   l_fp_cols_rec                   PA_FP_GEN_AMOUNT_UTILS.FP_COLS;  --This variable will be used to call pa_resource_asgn_curr maintenance api
   l_debug_level5                  NUMBER:=5;

   --Bug 8223977
   l_res_assignment_id_tbl         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
   l_burd_cost_rate_ovr_tbl      	 SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
   l_raw_cost_rate_ovr_tbl         SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
   l_bill_rate_ovr_tbl             SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();

   BEGIN
       x_msg_count := 0;
       x_msg_data  := NULL;
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       l_debug_mode := NVL(l_debug_mode, 'Y');

       IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_err_stack('PA_FIN_PLAN_PUB.create_default_plan_txn_rec');
            pa_debug.set_process('PLSQL','LOG',l_debug_mode);

            pa_debug.g_err_stage := 'Entered create_default_plan_txn_rec';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

            -- Check for not null parameters

            pa_debug.g_err_stage := 'Checking for valid parameters:';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;

       IF p_budget_version_id       IS NULL OR
          p_calling_module          IS NULL THEN
           IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage := 'p_budget_version_id = '||p_budget_version_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage := 'p_calling_module = '||p_calling_module;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
           END IF;

           PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

       END IF;
       IF p_pa_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Parameter validation complete';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;

        if (p_calling_module = 'UPDATE_PLAN_TRANSACTION') then  /* janani */
	    l_def_plan_txn_ra_id_tbl := p_ra_id_tbl;
        else
	    OPEN def_plan_txn_to_ins_csr;
	    FETCH def_plan_txn_to_ins_csr
	    BULK COLLECT INTO l_def_plan_txn_ra_id_tbl;
	    CLOSE def_plan_txn_to_ins_csr;
         END IF;     /* janani */

	 l_curr_code_temp_tbl := p_curr_code_tbl;  /* janani */
	 l_expenditure_type_tbl := p_expenditure_type_tbl; /*EnC */
    l_curr_code_temp_tbl.extend(l_def_plan_txn_ra_id_tbl.COUNT);  /* janani */
    l_expenditure_type_tbl.extend(l_def_plan_txn_ra_id_tbl.COUNT); /*EnC */


       IF l_def_plan_txn_ra_id_tbl.COUNT = 0 THEN
           IF p_pa_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'No resource assignment to default, returning';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
               pa_debug.reset_err_stack;
           END IF;
           RETURN;
       END IF;

       IF l_def_plan_txn_ra_id_tbl.COUNT > 0 THEN
             IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage := 'Getting currency information';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
             END IF;

           BEGIN
                 SELECT pbv.ci_id,
                        pbv.agreement_id,
                        pbv.approved_rev_plan_type_flag,
                        ppa.project_currency_code,
                        ppa.projfunc_currency_code
                 INTO   l_ci_id,
                        l_agreement_id,
                        l_app_rev_flag,
                        l_proj_curr_code,
                        l_pfunc_curr_code
                 FROM   pa_budget_versions pbv,
                        pa_projects_all ppa
                 WHERE  pbv.budget_version_id = p_budget_version_id
                 AND    ppa.project_id = pbv.project_id;
           EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                     IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'Invalid budget version id';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     END IF;
                     PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                          p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END;

           -- bug 5007734: for upgrade context, when this API is called to upgrade forms based
           -- budget versions to sswa plan versions, the txn currency should always be PFC
           IF p_calling_module = 'UPGRADE' THEN
               l_def_txn_curr_code := l_pfunc_curr_code;
           ELSE
               -- create version flow: proceed with the usual currency defaulting logic
               IF l_ci_id IS NOT NULL THEN
                    /* ci version context */
                         IF p_pa_debug_mode = 'Y' THEN
                            pa_debug.g_err_stage := 'Ci_id is not null';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                         END IF;
                    IF l_app_rev_flag = 'Y' THEN
                        IF l_agreement_id IS NOT NULL THEN
                            /* txn currency should be the agreement currency */
                            BEGIN
                                SELECT agreement_currency_code
                                INTO   l_agr_curr_code
                                FROM   pa_agreements_all
                                WHERE  agreement_id = l_agreement_id;
                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                    IF p_pa_debug_mode = 'Y' THEN
                                       pa_debug.g_err_stage := 'Invalid agreement id';
                                       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                                    END IF;
                                    PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                                         p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
                                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                            END;
                            l_def_txn_curr_code := l_agr_curr_code;
                        ELSE
                           /* it is possible, that for upgraded data, the agreement information may be missing.
                            * in this case, when user visits the change order page, he has to select a valid
                            * agreement before proceeding. In that case, all the existing budget lines for the revenue/all
                            * change order is deleted and new budget lines would be created with the agreement currency
                            * as the txn currency. But, to create the planning transaction with the default currency,
                            * in the new entity for change orders, which do not have an agreement yet, we are defaulting
                            * PFC as the txn currency. Anyway, this would be deleted, when user selects a valid agreement.
                            */
                           l_def_txn_curr_code := l_pfunc_curr_code;
                        END IF;
                    ELSE
                        /* txn currency should be the project currency */
                        l_def_txn_curr_code := l_proj_curr_code;
                    END IF;
               ELSE
                    IF l_app_rev_flag = 'Y' THEN
                        /* txn currency should be the project functional currency */
                        l_def_txn_curr_code := l_pfunc_curr_code;
                    ELSE
                        /* txn currency should be the project currency */
                        l_def_txn_curr_code := l_proj_curr_code;
                    END IF;
               END IF; -- if ci_id not null
           END IF; -- p_calling_module

           IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage := 'l_def_txn_curr_code: ' || l_def_txn_curr_code;
              pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
           END IF;

           DELETE pa_resource_asgn_curr_tmp;
           /* bulk insert the left over resource assignments into the new table with default txn currency
            * derived above */
           FORALL k IN l_def_plan_txn_ra_id_tbl.FIRST .. l_def_plan_txn_ra_id_tbl.LAST
               INSERT INTO pa_resource_asgn_curr_tmp
                   (RA_TXN_ID,
                    BUDGET_VERSION_ID,
                    RESOURCE_ASSIGNMENT_ID,
                    TXN_CURRENCY_CODE,
                    expenditure_type)
                   VALUES
                   (pa_resource_asgn_curr_s.nextval,
                    p_budget_version_id,
                    l_def_plan_txn_ra_id_tbl(k),
                    /*l_def_txn_curr_code);    */
		    nvl(l_curr_code_temp_tbl(k),l_def_txn_curr_code),   /* janani */
		    l_expenditure_type_tbl(k));
			--Start Bug 8223977
		     -- The overriden rates present in pa_resource_asgn_curr should be retained.
		     -- when resource is added using add row option .Updating the same in tmp table.
					OPEN rate_update_cur;
						FETCH rate_update_cur
						BULK COLLECT INTO
						l_res_assignment_id_tbl,
						l_raw_cost_rate_ovr_tbl,
						l_burd_cost_rate_ovr_tbl,
						l_bill_rate_ovr_tbl;
					CLOSE rate_update_cur;

					IF l_res_assignment_id_tbl.COUNT > 0 THEN
						FORALL i in l_res_assignment_id_tbl.FIRST .. l_res_assignment_id_tbl.LAST
						UPDATE pa_resource_asgn_curr_tmp
						   SET txn_raw_cost_rate_override = l_raw_cost_rate_ovr_tbl(i),
						       txn_burden_cost_rate_override = l_burd_cost_rate_ovr_tbl(i),
						       txn_bill_rate_override = l_bill_rate_ovr_tbl(i)
						 WHERE resource_assignment_id = l_res_assignment_id_tbl(i);
					END IF;
	        --End Bug 8223977

                   --IPM Arch Enhancement Bug 4865563 Start
                   PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                   (P_BUDGET_VERSION_ID              => p_budget_version_id,
                    X_FP_COLS_REC                    => l_fp_cols_rec,
                    X_RETURN_STATUS                  => l_return_status,
                    X_MSG_COUNT                      => l_msg_count,
                    X_MSG_DATA                       => l_msg_data);

                    IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                        IF P_PA_debug_mode = 'Y' THEN
                           pa_debug.g_err_stage:= 'Error in TARGET PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DETAILS';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
                        END IF;
                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                    END IF;


                /* calling the maintenance api to insert data into the new planning transaction level table */
                if (p_calling_module = 'UPDATE_PLAN_TRANSACTION') then  /* janani */
                pa_res_asg_currency_pub.maintain_data(
				p_fp_cols_rec                  => l_fp_cols_rec,
				p_calling_module               => p_calling_module,
				p_delete_flag                  => 'N',
				p_copy_flag                    => 'N',
				p_src_version_id               => NULL,
				p_copy_mode                    => NULL,
				p_rollup_flag                  => 'Y',
				p_version_level_flag           => 'N',
				p_called_mode                  => 'SELF_SERVICE',
				x_return_status                => l_return_status,
				x_msg_count                    => l_msg_count,
				x_msg_data                     => l_msg_data
				);
	     else

	     		PA_RES_ASG_CURRENCY_PUB.maintain_data
                           (p_fp_cols_rec          => l_fp_cols_rec,
                            p_calling_module       => p_calling_module,
                            p_version_level_flag   => 'N',     --Calling in temp table mode
                            x_return_status        => l_return_status,
                            x_msg_count            => l_msg_count,
                            x_msg_data             => l_msg_data);
              END IF; /* janani */

                     IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                        THEN
                           IF p_pa_debug_mode = 'Y' THEN
                               pa_debug.write_file('Failed due to error in PA_RES_ASG_CURRENCY_PUB.maintain_data',5);
                           END IF;
                           raise PA_FP_CONSTANTS_PKG.INVALID_ARG_EXC;
                     END IF;
           --IPM Arch Enhancement Bug 4865563 End


       END IF; -- if there is ra_id to be inserted
       IF p_pa_debug_mode = 'Y' THEN
           pa_debug.reset_err_stack;
       END IF;

   EXCEPTION
       WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           IF def_plan_txn_to_ins_csr%ISOPEN THEN
               CLOSE def_plan_txn_to_ins_csr;
           END IF;
           l_msg_count := FND_MSG_PUB.count_msg;
           IF l_msg_count = 1 THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                      ( p_encoded        => FND_API.G_TRUE
                       ,p_msg_index      => 1
                       ,p_msg_count      => l_msg_count
                       ,p_msg_data       => l_msg_data
                       ,p_data           => l_data
                       ,p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
                x_msg_count := l_msg_count;
           ELSE
               x_msg_count := l_msg_count;
               x_msg_data := l_msg_data;
           END IF;
           IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Invalid Arguments Passed';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.write_file('create_default_plan_txn_rec ' || x_msg_data,5);
           END IF;

           x_return_status:= FND_API.G_RET_STS_ERROR;
           IF p_pa_debug_mode = 'Y' THEN
               pa_debug.reset_err_stack;
           END IF;
           RAISE;

      WHEN Others THEN

           IF def_plan_txn_to_ins_csr%ISOPEN THEN
               CLOSE def_plan_txn_to_ins_csr;
           END IF;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count     := 1;
           x_msg_data      := SQLERRM;
           FND_MSG_PUB.add_exc_msg( p_pkg_name => 'PA_FIN_PLAN_PUB'
                            ,p_procedure_name  => 'create_default_plan_txn_rec');
           IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.write_file('create_default_plan_txn_rec '  || pa_debug.G_Err_Stack,5);
           END IF;
           IF p_pa_debug_mode = 'Y' THEN
               pa_debug.reset_err_stack;
           END IF;
           RAISE;
   END create_default_plan_txn_rec;

END pa_fin_plan_pub;

/
