--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_ATTR_UPGR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_ATTR_UPGR_PKG" AS
/* $Header: PABDGATB.pls 120.0 2005/05/30 11:28:12 appldev noship $ */

procedure BUDGET_ATTR_UPGRD(
  P_PROJECT_ID                  IN   pa_projects_all.project_id%type
  , p_budget_version_id         IN   pa_budget_versions.budget_version_id%type
  , X_RETURN_STATUS             OUT  NOCOPY VARCHAR2
  , X_MSG_COUNT                 OUT  NOCOPY NUMBER
  , X_MSG_DATA                  OUT  NOCOPY VARCHAR2) IS

    --Bug 4185180.Given a budget version id as parameter the cursor should bring the PLAN_VERSION, PLAN_TYPE  level records for that
    -- project and budget version.
	cursor get_fin_plan_ver_csr(c_project_id pa_projects_all.project_id%type
                                      , c_budget_version_id pa_budget_versions.budget_version_id%type) is
	select proj_fp_options_id,fin_plan_version_id,pfo.project_id,
        fin_plan_option_level_code,cost_time_phased_code,fin_plan_preference_code preference_code,
        revenue_time_phased_code,all_time_phased_code,cost_period_mask_id,
        rev_period_mask_id,all_period_mask_id,decode(revenue_time_phased_code,'G',1,'P',2,
        decode(cost_time_phased_code,'G',1,'P',2,
        decode(all_time_phased_code,'G',1,'P',2,null))) time_phased_code,
        decode(all_resource_list_id,null,decode(cost_resource_list_id,null,revenue_resource_list_id,cost_resource_list_id),all_resource_list_id) resource_list_id
	from pa_proj_fp_options pfo
         ,pa_budget_versions pbv
        where pfo.project_id = c_project_id
        and   pbv.budget_version_id=c_budget_version_id
        and   (fin_plan_version_id = c_budget_version_id OR
               (pfo.project_id = p_project_id AND
               fin_plan_option_level_code <> 'PLAN_VERSION' AND
               nvl(pfo.fin_plan_type_id,-99)=nvl(pbv.fin_plan_type_id,-99))); /* So that the fetch/update is not done if project/plan type level record is already upgraded */

        cursor get_rbs_ver_csr(c_resource_list_id pa_resource_lists_all_bg.resource_list_id%TYPE)  is
        select migrated_rbs_version_id,uncategorized_flag from
        pa_resource_lists_all_bg
        where resource_list_id = c_resource_list_id;


        cursor get_per_mask_id_csr is
        select period_mask_id,decode(time_phase_code,'G',1,'P',2)time_phase_code
        from pa_period_masks_b where pre_defined_flag='Y';


        -- Bug 3800485, 28-JUL-04, jwhite -----------------------------------------------

        cursor get_rbs_header_csr (c_rbs_version_id pa_resource_lists_all_bg.migrated_rbs_version_id%type)
        is
        SELECT RBS_HEADER_ID
        FROM   pa_rbs_versions_b
        WHERE  RBS_VERSION_ID = c_rbs_version_id;

        -- End Bug 3800485 ---------------------------------------------------------------


        TYPE get_per_mask_tbl is table of number
        index by binary_integer;
        l_get_per_mask_tbl get_per_mask_tbl;

        TYPE get_rbs_ver_tbl is table of pa_resource_lists_all_bg.migrated_rbs_version_id%type
        index by binary_integer;
   	   l_get_rbs_ver_tbl get_rbs_ver_tbl;

        l_period_mask_id    pa_period_masks_b.period_mask_id%type;
        l_curr_plan_period  pa_budget_versions.current_planning_period%type;
        l_curr_plan_period_b  pa_budget_versions.current_planning_period%type;
        l_rbs_version_id  pa_resource_lists_all_bg.migrated_rbs_version_id%type;
        l_cost_current_planning_period pa_proj_fp_options.cost_current_planning_period%type;
        l_cost_period_mask_id pa_proj_fp_options.cost_period_mask_id%type;
        l_rev_current_planning_period pa_proj_fp_options.rev_current_planning_period%type;
        l_rev_period_mask_id pa_proj_fp_options.rev_period_mask_id%type;
        l_all_current_planning_period pa_proj_fp_options.all_current_planning_period%type;
        l_all_period_mask_id pa_proj_fp_options.all_period_mask_id%type;
        l_stage                 VARCHAR2(240) :='';
        l_debug_mode varchar2(30);
        l_module_name VARCHAR2(100):= 'pa.plsql.pa_budget_attr_upgr_pkg';
        l_msg_count                     NUMBER :=0;
        l_msg_data                      VARCHAR2(2000);
        l_msg_index_out                 NUMBER;
        l_data                          VARCHAR2(2000);


        -- Bug 3800485, 28-JUL-04, jwhite -----------------------------------------------

        l_rbs_header_id   pa_rbs_versions_b.RBS_HEADER_ID%TYPE := NULL;

        l_return_status    VARCHAR2(1)    := NULL;

        -- End Bug 3800485 --------------------------------------------------------------


        -- Bug 3804286, 12-AUG-04, jwhite -----------------------------------------------

        l_project_start_date    pa_projects_all.start_date%TYPE := NULL;
        l_org_id                pa_projects_all.org_id%TYPE := NULL;
        l_PA_period_type        pa_implementations_all.pa_period_type%TYPE := NULL;
        l_GL_period_type        gl_sets_of_books.accounted_period_type%TYPE := NULL;

        -- End Bug 3804286, 12-AUG-04, jwhite --------------------------------------------

        l_uncategorized_flag    pa_resource_lists_all_bg.uncategorized_flag%TYPE; -- Bug 3935863

        --Bug 3977417.These variables will be used for cost and rev separate options. They will  have the
        --Current Planning Period(cpp) for GL/PA time phasing.
        l_cpp_for_gl_time_phase pa_proj_fp_options.cost_time_phased_code%TYPE;
        l_cpp_for_pa_time_phase pa_proj_fp_options.cost_time_phased_code%TYPE;
begin
       -- FND_MSG_PUB.initialize;  /* Bug 3800485 */
       x_msg_count := 0;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       pa_debug.init_err_stack('PA_BUDGET_ATTR_UPGR_PKG.Budget_Attr_Upgrd');
       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       l_debug_mode := NVL(l_debug_mode, 'Y');
       pa_debug.set_process('PLSQL','LOG',l_debug_mode);
       IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Entered Budget Attribute Upgrade';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

         pa_debug.g_err_stage := 'Checking for valid parameters';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;


      if (nvl(p_project_id,0) = 0) then
         IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'p_project_id='||to_char(p_project_id);
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;
          PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                               p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      end if;

      -- bug 3673111, 07-JUN-04, jwhite ------------------------------------

      if (nvl(p_budget_version_id,0) = 0) then
         IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'p_budget_version_id='||to_char(p_budget_version_id);
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;
          PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                               p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      end if;


      -- End Bug 3673111 ----------------------------------------------------

       -- Loop for storing period mask id for each time phase code
       for l_get_per_mask_id_csr in get_per_mask_id_csr
       loop
       	   l_get_per_mask_tbl(l_get_per_mask_id_csr.time_phase_code) := l_get_per_mask_id_csr.period_mask_id;
       end loop;


   -- bug 3673111, 07-JUN-04, jwhite ---------------------------------------
   -- 1) added p_budget_verion_id to loop cursor parameter list.

   -- Loop for each fin plan version

for l_get_fin_plan_ver_csr in get_fin_plan_ver_csr(p_project_id, p_budget_version_id)
loop
        l_period_mask_id   := NULL;
        l_curr_plan_period := NULL;
        l_curr_plan_period_b := NULL;
        l_rbs_version_id   := NULL;
        l_cost_current_planning_period := NULL;
        l_cost_period_mask_id := NULL;
        l_rev_current_planning_period := NULL;
        l_rev_period_mask_id := NULL;
        l_all_current_planning_period := NULL;
        l_all_period_mask_id := NULL;
        l_rbs_header_id       := NULL;
        l_uncategorized_flag  := NULL;
        -- Bug 3804286, 12-AUG-04, jwhite -----------------------------------------------

        l_project_start_date := NULL;
        l_org_id             := NULL;
        l_PA_period_type     := NULL;
        l_GL_period_type     := NULL;

        -- End Bug 3804286, 12-AUG-04, jwhite -------------------------------------------


        -- To obtain period mask id for the time phase code.
        --Bug 3977417.For Cost and Rev Sep Options, cost/rev period mask ids should be separately derived based on
        --cost/rev time phasings
        if (l_get_fin_plan_ver_csr.preference_code='COST_AND_REV_SEP') then

            if l_get_fin_plan_ver_csr.cost_time_phased_code='G' then
                l_cost_period_mask_id := l_get_per_mask_tbl(1);
            elsif l_get_fin_plan_ver_csr.cost_time_phased_code='P' then
                l_cost_period_mask_id := l_get_per_mask_tbl(2);
            else
                l_cost_period_mask_id := NULL;
            end if;

            if l_get_fin_plan_ver_csr.revenue_time_phased_code='G' then
                l_rev_period_mask_id := l_get_per_mask_tbl(1);
            elsif l_get_fin_plan_ver_csr.revenue_time_phased_code='P' then
                l_rev_period_mask_id := l_get_per_mask_tbl(2);
            else
                l_rev_period_mask_id := NULL;
            end if;

        elsif (l_get_per_mask_tbl.exists(l_get_fin_plan_ver_csr.time_phased_code)) then
            l_period_mask_id := l_get_per_mask_tbl(l_get_fin_plan_ver_csr.time_phased_code);
        end if;

        -- To obtain RBS version for the given resource list id.
        OPEN get_rbs_ver_csr(l_get_fin_plan_ver_csr.resource_list_id);
        FETCH get_rbs_ver_csr
        INTO l_rbs_version_id,l_uncategorized_flag;
        CLOSE get_rbs_ver_csr;



        -- Bug 3804286, 12-AUG-04, jwhite ---------------------------------------------

        -- For Periodic Budget Versions, Get the Start Date for
        -- Subseqeunt Derivation of the Current Planning Period Name.

        --Bug 3977417
        l_cpp_for_pa_time_phase := NULL;
        l_cpp_for_gl_time_phase := NULL;

        IF  ( l_get_fin_plan_ver_csr.time_phased_code IN (1,2)  OR
              (l_get_fin_plan_ver_csr.preference_code='COST_AND_REV_SEP' AND--In this case too, l_get_fin_plan_ver_csr.time_phased_code
               (l_get_fin_plan_ver_csr.cost_time_phased_code IN ('P','G') OR--would be either P or G. But Added condition since
                l_get_fin_plan_ver_csr.revenue_time_phased_code IN ('P','G')-- l_get_fin_plan_ver_csr.time_phased_code should
               )                                                            --not be used for cost_and_rev_sep plan types.Bug 3977417
              )
            ) THEN
          -- GL or PA Periodic Data

             begin

               -- Find Project Start Date and Org_id.
               -- The Project Record MUST Exist. RAISE error if not found.
               SELECT start_date, nvl(org_id,-99)
               INTO   l_project_start_date, l_org_id
               FROM   pa_projects_all
               WHERE  project_id = l_get_fin_plan_ver_csr.project_id;

               exception
                 WHEN NO_DATA_FOUND THEN
                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

             end;


             -- If Project Start is Still NUll,
             --   then Find Minimum Budget Line Start Date, If Any.
             IF ( l_project_start_date IS NULL)
               THEN

                 begin

                   IF l_get_fin_plan_ver_csr.fin_plan_version_id IS NOT NULL THEN

                       SELECT min(start_date)
                       INTO   l_project_start_date
                       FROM   pa_budget_lines
                       WHERE  budget_version_id = l_get_fin_plan_ver_csr.fin_plan_version_id;

                   END IF;

                   /* Following "if" takes care of case when there no budget lines for the budget verison
                      or
                      the record that is processed is a project/plan type level record. */

                   IF l_project_start_date IS NULL THEN
                        select trunc(sysdate) into l_project_start_date from dual;
                   END IF;
                 end;

             END IF; -- l_project_start_date IS NULL)


             -- IF Start Date FOUND,
             --    THEN Derive GL/PA Period Name to Populate the Current Planning Period

             IF ( l_project_start_date IS NULL)
               THEN

                l_curr_plan_period := NULL;

               ELSE

                 IF ( l_get_fin_plan_ver_csr.time_phased_code = 1 OR
                     (l_get_fin_plan_ver_csr.preference_code='COST_AND_REV_SEP' AND
                      (l_get_fin_plan_ver_csr.cost_time_phased_code = 'G' OR
                       l_get_fin_plan_ver_csr.revenue_time_phased_code = 'G'
                      )
                     )
                    ) THEN
                    -- Get GL Period Name

                    begin

                      SELECT sob.accounted_period_type
                      INTO   l_GL_period_type
                      FROM   pa_implementations_all I
                             , gl_sets_of_books sob
                      WHERE  nvl(i.org_id,-99) = l_org_id
                      AND    sob.set_of_books_id = i.set_of_books_id;

                      SELECT gl.PERIOD_NAME
                      INTO   l_curr_plan_period
                      FROM   gl_periods gl
                             , pa_implementations_all i
                             , gl_sets_of_books sob
                      WHERE  nvl(i.org_id,-99) = l_org_id
                      AND    gl.period_type = l_GL_period_type
                      and    l_project_start_date between gl.START_DATE and gl.END_DATE
                      AND    sob.set_of_books_id = i.set_of_books_id
                      AND    gl.period_set_name = sob.period_set_name
                      AND    gl.ADJUSTMENT_PERIOD_FLAG = 'N';

                      exception
                        WHEN NO_DATA_FOUND THEN
                          l_curr_plan_period := NULL;

                    end;
                    l_cpp_for_gl_time_phase:=l_curr_plan_period;

                 End IF; -- GL Period Type

                 IF ( l_get_fin_plan_ver_csr.time_phased_code = 2 OR
                     (l_get_fin_plan_ver_csr.preference_code='COST_AND_REV_SEP' AND
                      (l_get_fin_plan_ver_csr.cost_time_phased_code = 'P' OR
                       l_get_fin_plan_ver_csr.revenue_time_phased_code = 'P'
                      )
                     )
                    ) THEN
                    -- Get PA Period Name

                    begin

                      SELECT i.pa_period_type
                      INTO   l_PA_period_type
                      FROM   pa_implementations_all i
                      WHERE  nvl(i.org_id,-99) = l_org_id;

                      exception
                        WHEN OTHERS THEN
                          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;  -- pa_implementations must exist for org_id.

                    end;

                    begin

                      SELECT gl.PERIOD_NAME
                      INTO   l_curr_plan_period
                      FROM   gl_periods gl
                             , pa_implementations_all i
                             , gl_sets_of_books sob
                      WHERE  nvl(i.org_id,-99) = l_org_id
                      AND    gl.period_type = l_PA_period_type
                      and    l_project_start_date between gl.START_DATE and gl.END_DATE
                      AND    sob.set_of_books_id = i.set_of_books_id
                      AND    gl.period_set_name = sob.period_set_name
                      AND    gl.ADJUSTMENT_PERIOD_FLAG = 'N';

                      exception
                        WHEN NO_DATA_FOUND THEN
                          l_curr_plan_period := NULL;

                    end;
                    l_cpp_for_pa_time_phase:=l_curr_plan_period;
                 End IF; -- PA Period Type

             End IF; -- Start Date Processing

        END IF;  -- GL or PA periodic Data Processing

        if (l_get_fin_plan_ver_csr.preference_code = 'COST_ONLY') then
            l_cost_current_planning_period := l_curr_plan_period;
            l_cost_period_mask_id := l_period_mask_id;
        elsif (l_get_fin_plan_ver_csr.preference_code = 'REVENUE_ONLY') then
            l_rev_current_planning_period := l_curr_plan_period;
            l_rev_period_mask_id := l_period_mask_id;
        elsif (l_get_fin_plan_ver_csr.preference_code = 'COST_AND_REV_SEP') then
            --Bug 3977417
            if l_get_fin_plan_ver_csr.cost_time_phased_code='G' then
                l_cost_current_planning_period := l_cpp_for_gl_time_phase;
            elsif l_get_fin_plan_ver_csr.cost_time_phased_code='P' then
                l_cost_current_planning_period := l_cpp_for_pa_time_phase;
            else
                l_cost_current_planning_period := NULL;
            end if;

            if l_get_fin_plan_ver_csr.revenue_time_phased_code='G' then
                l_rev_current_planning_period := l_cpp_for_gl_time_phase;
            elsif l_get_fin_plan_ver_csr.revenue_time_phased_code='P' then
                l_rev_current_planning_period := l_cpp_for_pa_time_phase;
            else
                l_rev_current_planning_period := NULL;
            end if;

        else
            l_all_current_planning_period := l_curr_plan_period;
            l_all_period_mask_id := l_period_mask_id;
        end if;

       IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Update Pa_proj_fp_options Table.';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       end if;

	update pa_proj_fp_options
        SET cost_current_planning_period = l_cost_current_planning_period,
           cost_period_mask_id = l_cost_period_mask_id,
           rev_current_planning_period = l_rev_current_planning_period,
           rev_period_mask_id = l_rev_period_mask_id,
           all_current_planning_period = l_all_current_planning_period ,
           all_period_mask_id = l_all_period_mask_id,
           rbs_version_id = l_rbs_version_id, /* Rbs upgrade happens based on cost resource list id in case of cost and rev sep pref code */
           all_FIN_PLAN_LEVEL_CODE = decode(all_FIN_PLAN_LEVEL_CODE, 'M', 'L', all_FIN_PLAN_LEVEL_CODE),             /* bug 3820552 */
           cost_FIN_PLAN_LEVEL_CODE = decode(cost_FIN_PLAN_LEVEL_CODE, 'M', 'L', cost_FIN_PLAN_LEVEL_CODE),          /* bug 3820552 */
           revenue_FIN_PLAN_LEVEL_CODE = decode(revenue_FIN_PLAN_LEVEL_CODE, 'M', 'L', revenue_FIN_PLAN_LEVEL_CODE), /* bug 3820552 */
           use_planning_rates_flag = 'N'
           where proj_fp_options_id = l_get_fin_plan_ver_csr.proj_fp_options_id;


       IF l_get_fin_plan_ver_csr.fin_plan_option_level_code = 'PLAN_VERSION' THEN

       -- Update budget version table with the above values
       IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Update Pa_Budget_versions Table.';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       end if;

       update pa_budget_versions
       set project_structure_version_id =     NULL,
       object_type_code                 =    'PROJECT',
       object_id                        =     l_get_fin_plan_ver_csr.project_id,
       pji_summarized_flag              =     'N',
       current_planning_period          =     l_curr_plan_period,
       period_mask_id                   =     l_period_mask_id,
       wp_version_flag                  =     'N'   /* Bug 3799921: added this column */
       where budget_version_id          =     l_get_fin_plan_ver_csr.fin_plan_version_id;

       END IF;

       /* Bug 3935863: RBS migration does not happen for uncategorized resource lists.
          So, PA_RBS_ASGMT_PUB.Create_RBS_Assignment should not be called for such resource lists. */
       IF (l_uncategorized_flag <> 'Y') THEN
            -- Bug 3800485, 28-JUL-04, jwhite -----------------------------------------------

                Open get_rbs_header_csr(l_rbs_version_id);
                Fetch get_rbs_header_csr INTO l_rbs_header_id;
                Close get_rbs_header_csr;



               PA_RBS_ASGMT_PUB.Create_RBS_Assignment
                 (  p_commit                 => FND_API.G_FALSE
                    , p_init_msg_list        => FND_API.G_FALSE
                    , p_rbs_header_id        => l_rbs_header_id
                    , p_rbs_version_id       => l_rbs_version_id
                    , p_project_id           => p_project_id
                    , p_fp_usage_flag        => 'Y'
                    , x_return_status        => l_return_status
                    , x_msg_count            => l_msg_count
                    , x_error_msg_data       => l_msg_data
                  );


               IF ( l_return_status <> 'S')
                 THEN
                    IF l_debug_mode = 'Y' THEN
                       pa_debug.g_err_stage := 'p_budget_version_id='||to_char(p_budget_version_id);
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                    END IF;
                    PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                            p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
               END IF;

            -- End bug 3800485 --------------------------------------------------------------
          END IF; --l_uncategorized_flag <> 'Y'
end loop;
-- Loop for each fin plan version ends here.

 EXCEPTION
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc then
      l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded         => FND_API.G_TRUE
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

        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;
        x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.write_file('BUDGET_ATTR_UPGRD_ATTR : Upgrade has failed for the project: '||p_project_id,5);
        pa_debug.write_file('BUDGET_ATTR_UPGRD : Failure Reason:'||x_msg_data,5);
        pa_debug.reset_err_stack;
        --ROLLBACK;  /* Should Not have Rollback in this package. Only main API rollback should be active */
        RAISE;
      WHEN OTHERS THEN

        if get_fin_plan_ver_csr%ISOPEN then
           close get_fin_plan_ver_csr;
        end if;
        if get_rbs_ver_csr%ISOPEN then
           close get_rbs_ver_csr;
        end if;
        if get_per_mask_id_csr%ISOPEN then
           close get_per_mask_id_csr;
        end if;
        if get_rbs_header_csr%ISOPEN then
           close get_rbs_header_csr;
        end if;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_BUDGET_ATTR_UPGR_PKG',p_procedure_name  => 'BUDGET_ATTR_UPGRD');
        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;

        pa_debug.write_file('BUDGET_ATTR_UPGRD : Upgrade has failed for the project'||p_project_id,5);
        pa_debug.write_file('BUDGET_ATTR_UPGRD : Failure Reason:'||pa_debug.G_Err_Stack,5);
        pa_debug.reset_err_stack;
        --ROLLBACK; /* Should Not have Rollback in this package. Only main API rollback should be active */
        RAISE;
end BUDGET_ATTR_UPGRD;
end PA_BUDGET_ATTR_UPGR_PKG;

/
