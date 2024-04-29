--------------------------------------------------------
--  DDL for Package Body PA_BASELINE_FUNDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BASELINE_FUNDING_PKG" AS
--$Header: PAXBBFPB.pls 120.3.12010000.2 2009/07/28 13:07:17 nkapling ship $

/*----------------------------------------------------------------------------------------+
|   Procedure  :   create_draft                                                           |
|   Purpose    :                                                                          |
|                                                                                         |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                             Mode    Description                                |
|     ==================================================================================  |
|     x_multi_currency_billing_flag    OUT     Indicates multi_currency_billing_flag      |
|                                              is allowed for this OU                     |
|     x_share_bill_rates_across_ou     OUT     Indicates sharing Bill rates schedules     |
|                                              across OU is allowed for this OU           |
|     x_allow_funding_across_ou        OUT     Indicates funding across OU is allowed for |
|                                              this OU                                    |
|     x_default_exchange_rate_type     OUT     Default value for rate type                |
|     x_functional_currency            OUT     Functional currency of OU                  |
|     x_return_status                  OUT     Return status of this procedure            |
|     x_msg_count                      OUT     Error message count                        |
|     x_msg_data                       OUT     Error message                              |
|     ==================================================================================  |
+----------------------------------------------------------------------------------------*/

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
g_module_name VARCHAR2(100) := 'pa.plsql.PA_BASELINE_FUNDING_PKG';

    PROCEDURE create_draft (
           p_project_id         IN         NUMBER,
           p_start_date         IN         DATE,
           p_end_date           IN         DATE,
           p_resource_list_id   IN         NUMBER,
           x_budget_version_id  IN OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
           x_err_code           OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
           x_status             OUT        NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

    IS


         CURSOR budget_version IS
                SELECT max(budget_version_id)
                FROM   pa_budget_versions
                WHERE project_id = p_project_id
                AND   budget_type_code = 'AR'
                AND   budget_status_code = 'W'
                AND   version_number = 1;



         l_budget_version_id    NUMBER;
         l_err_code             NUMBER;
         l_err_stage            VARCHAR2(120);
         l_funding_level        VARCHAR2(1);
         l_budget_entry_method_code   VARCHAR2(30);
         l_err_stack                  VARCHAR2(250);

         lx_budget_version_id    NUMBER;


    BEGIN


        /* ATG Changes */
           lx_budget_version_id   :=  x_budget_version_id;


         x_err_code := 0;
         IF p_pa_debug_mode = 'Y' THEN
                 pa_debug.set_err_stack('PA_BASELINE_FUNDING_PKG.CREATE_DRAFT');
                 pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
         END IF;

	IF P_PA_DEBUG_MODE = 'Y' THEN
   	   pa_debug.g_err_stage:= 'Calling check_funding_level';
	   pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;

         pa_billing_core.check_funding_level (
                x_project_id  => p_project_id,
                x_funding_level => l_funding_level,
                x_err_code      => l_err_code,
                x_err_stage     => l_err_stage,
                x_err_stack     => l_err_stack);

	IF P_PA_DEBUG_MODE = 'Y' THEN
   	   pa_debug.g_err_stage:= 'After check_funding_level, funding level - '||l_funding_level;
	   pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
   	   pa_debug.g_err_stage:= 'error code - '||l_err_code;
	   pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
   	   pa_debug.g_err_stage:= 'error stage - '||l_err_stage;
	   pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;

         IF l_err_code <> 0 then
               x_err_code := l_err_code;
               x_status := l_err_stage;
         END IF;


         IF x_err_code = 0 then

            IF l_funding_level = 'P' then
               l_budget_entry_method_code := 'PA_PROJLVL_BASELINE';
            ELSIF l_funding_level = 'T' then
               l_budget_entry_method_code := 'PA_TASKLVL_BASELINE';
            END IF;

            IF P_PA_DEBUG_MODE = 'Y' THEN
   	       pa_debug.g_err_stage:= 'Calling budget_utils create_draft';
	       pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;

            pa_budget_utils.create_draft
              (x_project_id                   => p_project_id
                ,x_budget_type_code             => 'AR'
               ,x_version_name                 => 'Revenue Budget 1'
               ,x_description                  => 'Default Created by Projects'
               ,x_resource_list_id             => p_resource_list_id
               ,x_change_reason_code           => null
               ,x_budget_entry_method_code     => l_budget_entry_method_code
               ,x_attribute_category           => null
               ,x_attribute1                   => null
               ,x_attribute2                   => null
               ,x_attribute3                   => null
               ,x_attribute4                   => null
               ,x_attribute5                   => null
               ,x_attribute6                   => null
               ,x_attribute7                   => null
               ,x_attribute8                   => null
               ,x_attribute9                   => null
               ,x_attribute10                  => null
               ,x_attribute11                  => null
               ,x_attribute12                  => null
               ,x_attribute13                  => null
               ,x_attribute14                  => null
               ,x_attribute15                  => null
               ,x_budget_version_id            => l_budget_version_id
               ,x_err_code                     => l_err_code
               ,x_err_stage                    => l_err_stage
               ,x_err_stack                    => l_err_stack);

            x_err_code := l_err_code;

            IF P_PA_DEBUG_MODE = 'Y' THEN
   	       pa_debug.g_err_stage:= 'After create_draft , budget version id - '||l_budget_version_id;
	       pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
   	       pa_debug.g_err_stage:= 'error code is -'||l_err_code;
	       pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
   	       pa_debug.g_err_stage:= 'error code is -'||l_err_stage;
	       pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;

            IF x_err_code <> 0 THEN

               x_status := l_err_stage;

            END IF;

         END IF ;

         IF x_err_code = 0 then

            IF P_PA_DEBUG_MODE = 'Y' THEN
   	       pa_debug.g_err_stage:= 'Error Code is 0';
	       pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;

            OPEN budget_version;
            FETCH budget_version into l_budget_version_id;
            CLOSE budget_version;

            IF P_PA_DEBUG_MODE = 'Y' THEN
   	       pa_debug.g_err_stage:= 'Budget version ID in the table - '||l_budget_version_id;
	       pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;
            x_budget_version_id := l_budget_version_id;

         END IF;

         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:= 'x_budget_version_id = '||x_budget_version_id;
	    pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         END IF;

         pa_debug.reset_err_stack;

    EXCEPTION

        WHEN OTHERS THEN

             x_err_code := SQLCODE;
             x_status := substr(SQLERRM,1,50);


            /* ATG Changes */

             x_budget_version_id := lx_budget_version_id;

             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:= 'Exception in create_draft, error - '||x_status;
	        pa_debug.write('create_draft: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             END IF;
             pa_debug.reset_err_stack;
    END create_draft;


    PROCEDURE create_line (
           p_project_id                IN         NUMBER,
           p_start_date                IN         DATE,
           p_end_date                  IN         DATE,
           p_resource_list_member_id   IN         NUMBER,
           p_budget_version_id         IN         NUMBER,
           x_err_code                  OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
           x_status                    OUT        NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

    IS

       CURSOR funding_amount (x_funding_level varchar)  is
              SELECT task_id, sum(nvl(projfunc_allocated_amount,0)) fund_amt
              FROM  pa_project_fundings
              WHERE project_id = p_project_id
              AND ( (budget_type_code IN ('DRAFT', 'BASELINE') AND PA_FUND_REVAL_PVT.G_REVAL_FLAG ='N')
               OR   (PA_FUND_REVAL_PVT.G_REVAL_FLAG ='Y' AND (
					       ( (budget_type_code ='BASELINE') OR
						 (budget_type_code ='DRAFT' AND funding_category=
						'REVALUATION') ))))
              AND ((x_funding_level = 'T' and task_id is not null)
		   or (x_funding_level = 'P' and task_id is  null))
              group by task_id;/*Bug 8718600*/

       l_start_date   DATE;
       l_end_date     DATE;
       l_resource_assignment_id NUMBER;
       l_err_stack              VARCHAR2(250);
       l_err_code             NUMBER;
       l_err_stage            VARCHAR2(120);

       l_quantity            NUMBER;
       l_raw_cost            NUMBER;
       l_burdened_cost       NUMBER;
       l_task_id             NUMBER;

       l_funding_level        VARCHAR2(1);/*Bug 8718600*/

    BEGIN

	pa_billing_core.check_funding_level (
			x_project_id    => p_project_id,
			x_funding_level => l_funding_level,
			x_err_code      => l_err_code,
			x_err_stage     => l_err_stage,
			x_err_stack     => l_err_stack);/*Bug 8718600*/



         x_err_code := 0;
         IF p_pa_debug_mode = 'Y' THEN
                 pa_debug.set_err_stack('PA_BASELINE_FUNDING_PKG.CREATE_LINE');
                 pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
         END IF;

         FOR f1_rec in funding_amount (l_funding_level) loop /*Bug 8718600*/

            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:= 'In the loop of funding_amount';
               pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL1);
            END IF;

             if f1_rec.task_id is not null then

                select start_date, completion_date
                into   l_start_date, l_end_date
                from   pa_tasks
                where  task_id = f1_rec.task_id
                and    project_id = p_project_id;

                if  l_start_date is null then

                    l_start_date := p_start_date;

                end if;

                if  l_end_date is null then

                    l_end_date := p_end_date;

                end if;
                l_task_id := f1_rec.task_id;

             else

                l_start_date := p_start_date;
                l_end_date := p_end_date;
                l_task_id := 0;

             end if;

            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:= 'start date - '||l_start_date;
               pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL1);
               pa_debug.g_err_stage:= 'end date - '||l_end_date;
               pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL1);
               pa_debug.g_err_stage:= 'task id - '||l_task_id;
               pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL1);
            END IF;

             --dbms_output.put_line ('call util crt line');
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:= 'Calling budget_utils create_line';
                pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL1);
             END IF;
             pa_budget_utils.create_line
                (x_budget_version_id            => p_budget_version_id
                ,x_project_id                   => p_project_id
                ,x_task_id                      => l_task_id
                ,x_resource_list_member_id      => p_resource_list_member_id
                ,x_description                  => 'Default created by projects'
                ,x_start_date                   => l_start_date
                ,x_end_date                     => l_end_date
                ,x_period_name                  => null
                ,x_quantity                     => l_quantity
                ,x_unit_of_measure              => null
                ,x_track_as_labor_flag          => 'N'
                ,x_raw_cost                     => l_raw_cost
                ,x_burdened_cost                => l_burdened_cost
                ,x_revenue                      => f1_rec.fund_amt
                ,x_change_reason_code           => NULL
                ,x_attribute_category           => null
                ,x_attribute1                   => null
                ,x_attribute2                   => null
                ,x_attribute3                   => null
                ,x_attribute4                   => null
                ,x_attribute5                   => null
                ,x_attribute6                   => null
                ,x_attribute7                   => null
                ,x_attribute8                   => null
                ,x_attribute9                   => null
                ,x_attribute10                  => null
                ,x_attribute11                  => null
                ,x_attribute12                  => null
                ,x_attribute13                  => null
                ,x_attribute14                  => null
                ,x_attribute15                  => null
                -- Bug Fix: 4569365. Removed MRC code.
                -- ,x_mrc_flag                     => 'Y' /* FPB2 */
                ,x_resource_assignment_id       => l_resource_assignment_id
                ,x_err_code                     => l_err_code
                ,x_err_stage                    => l_err_stage
                ,x_err_stack                    => l_err_stack);

               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage:= 'After budget_utils create_line';
                  pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL1);
                  pa_debug.g_err_stage:= 'error code - '||l_err_code;
                  pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL1);
                  pa_debug.g_err_stage:= 'error stage - '||l_err_stage;
                  pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL1);
               END IF;


                if l_err_code <> 0 then

                   x_err_code := l_err_code;
                   x_status   := l_err_stage;

                   exit;

                end if;

         END LOOP;

         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:= 'End of create_line procedure';
            pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         END IF;

         pa_debug.reset_err_stack;

    EXCEPTION
        WHEN OTHERS THEN

             x_err_code := SQLCODE;
             x_status := substr(SQLERRM,1,50);

             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:= 'In exception of create_line - '||x_status;
                pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             END IF;
             pa_debug.reset_err_stack;
    END create_line;



    PROCEDURE create_budget_baseline (
           p_project_id         IN         NUMBER,
           x_err_code           OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
           x_status             OUT        NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

    IS


   -- 09-JUN-04, FP.M Resource List Data Model Changes, jwhite  --------------------------------

/*
   -- Original Logic

         CURSOR res_info IS
                SELECT R1.resource_list_id resource_list_id,
                       M.resource_list_member_id resource_list_member_id
                FROM   pa_resource_lists R1, pa_implementations I,
                       pa_resource_list_members M
                WHERE  R1.uncategorized_flag = 'Y'
                AND    R1.business_group_id = I.business_group_id
                AND    R1.resource_list_id = M.resource_list_id;
*/

   -- FP.M Logic for Fetching Uncategorized Resoure List Member

        CURSOR res_info IS
                SELECT R1.resource_list_id resource_list_id,
                       M.resource_list_member_id resource_list_member_id
                FROM   pa_resource_lists R1, pa_implementations I,
                       pa_resource_list_members M
                WHERE  R1.uncategorized_flag = 'Y'
                AND    R1.business_group_id = I.business_group_id
                AND    R1.resource_list_id = M.resource_list_id
                and    m.resource_class_code = 'FINANCIAL_ELEMENTS';



   -- ENd: 09-JUN-04, FP.M Resource List Data Model Changes -------------------------------------



         CURSOR proj_dates IS
                SELECT start_date, completion_date
                FROM pa_projects_all
                WHERE project_id = p_project_id;
/* Added for fp */
         CURSOR funding_amount (x_funding_level varchar) is
                SELECT task_id, sum(nvl(projfunc_allocated_amount,0)) pf_fund_amt,
                sum(nvl(project_allocated_amount,0)) proj_fund_amt
                FROM  pa_project_fundings
                WHERE project_id = p_project_id
                AND ((budget_type_code IN ('DRAFT', 'BASELINE')
                      AND PA_FUND_REVAL_PVT.G_REVAL_FLAG ='N')
                        OR   (PA_FUND_REVAL_PVT.G_REVAL_FLAG ='Y'
                              AND (((budget_type_code ='BASELINE')
                                     OR (budget_type_code ='DRAFT'
                                         AND funding_category= 'REVALUATION')))))
                AND ((x_funding_level = 'T' and task_id is not null)
		     or (x_funding_level = 'P' and task_id is  null))
		AND nvl(PA_Funding_Core.G_FUND_BASELINE_FLAG,'N') ='N'
		-- FP_M changes: Added UNION clause for Change Management enhancements
		-- This cursor is modified to fetch only from the selected
		-- funding lines that needs to be baselined ONLY when
		-- a global value PA_Funding_Core.G_FUND_BASELINE_FLAG is enabled
		group by task_id
		UNION
		SELECT task_id,
		       sum(nvl(projfunc_allocated_amount,0)) pf_fund_amt,
		       sum(nvl(project_allocated_amount,0)) proj_fund_amt
		FROM  pa_project_fundings
		WHERE project_id = p_project_id
		AND   PA_Funding_Core.G_FUND_BASELINE_FLAG = 'Y'
		AND   (NVL(Submit_Baseline_Flag,'N') = 'Y' OR
		       budget_type_code = 'BASELINE' )
                AND ((x_funding_level = 'T' and task_id is not null)
		     or ( x_funding_level = 'P' and task_id is  null))
                group by task_id;/*Bug 8718600*/


         res_info_rec     res_info%ROWTYPE;
         proj_dates_rec   proj_dates%ROWTYPE;

         l_budget_version_id    NUMBER;
         l_err_code             NUMBER;
         l_err_stage            VARCHAR2(120);
         l_status               VARCHAR2(120);
         l_msg_count            NUMBER;
         l_err_stack            VARCHAR2(250);

         l_return_status        VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
/* Added for FP */
         l_plan_type_id         pa_proj_fp_options.fin_plan_type_id%TYPE;
         l_msg_data             VARCHAR2(2000);
         l_funding_bl_tab       pa_fp_auto_baseline_pkg.funding_bl_tab;
         i                      NUMBER := 0;
         l_funding_level        VARCHAR2(1);
/* FP.K.B3 - Funding level to be passed to FPautobseline api. This variable is not used
         l_fp_level_code        pa_proj_fp_options.cost_fin_plan_level_code%TYPE;
*/
         l_start_date           DATE;
         l_end_date             DATE;
         l_task_id              NUMBER;
	 l_project_id           NUMBER;

    BEGIN

         savepoint temp_pt;
         x_err_code := 0;

         IF p_pa_debug_mode = 'Y' THEN
                 pa_debug.set_err_stack('PA_BASELINE_FUNDING_PKG.CREATE_BUDGET_BASELINE');
                 pa_debug.set_process('PLSQL','LOG',p_pa_debug_mode);
         END IF;

         OPEN res_info;
         FETCH res_info INTO res_info_rec;
         CLOSE res_info;


         OPEN proj_dates;
         FETCH proj_dates INTO proj_dates_rec;
         CLOSE proj_dates;

         --dbms_output.put_line ('start date - ' || proj_dates_rec.start_date);
         --dbms_output.put_line ('end date - ' || proj_dates_rec.completion_date);

         --dbms_output.put_line ('reslisid - ' || res_info_rec.resource_list_id);
         --dbms_output.put_line ('resmemid - ' || res_info_rec.resource_list_member_id);

      /* Fix for bug#4000821 code moved from the form to package as we can't release
         the exlicit lock in form by rollback if the baseline fails due to validation
	 as done  in the bug 3739353 starts here */
	BEGIN
		SELECT	project_id
		INTO	l_project_id
		FROM	pa_projects_all
		WHERE	project_id = p_project_id
		FOR UPDATE NOWAIT;

	EXCEPTION
		WHEN OTHERS THEN
                 x_err_code := 20;
                x_status := 'PA_PROJECT_LOCK_TRY_LATER';
              PA_UTILS.Add_Message
              ( p_app_short_name        => 'PA'
                , p_msg_name    => x_status
               );
	END;

/* Fix for bug#4000821 ends here */


         IF proj_dates_rec.completion_date is null then
            x_err_code := 30;
            x_status := 'PA_BU_NO_PROJ_END_DATE';
              PA_UTILS.Add_Message
              ( p_app_short_name        => 'PA'
                , p_msg_name    => x_status
               );

            --dbms_output.put_line ('stat 1 - ' || x_status);
         END IF;

         IF x_err_code = 0 then
/* Added for fp - start*/
            pa_fin_plan_utils.Get_Appr_Rev_Plan_Type_Info (
                                          p_project_id    =>p_project_id,
                                          x_plan_type_id  => l_plan_type_id,
                                          x_return_status => l_return_status,
                                          x_msg_count     => l_msg_count,
                                          x_msg_data      => l_msg_data
                                        );

            IF l_plan_type_id is NULL THEN
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:= 'No Plan type ID';
                pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
             END IF;

/* Added for fp - end*/
		    --dbms_output.put_line ('calling create_draft ' );
		    create_draft (
			  p_project_id        => p_project_id,
			  p_start_date        => proj_dates_rec.start_date,
			  p_end_date          => proj_dates_rec.completion_date,
			  p_resource_list_id  => res_info_rec.resource_list_id,
			  x_budget_version_id => l_budget_version_id,
			  x_err_code          => l_err_code,
			  x_status            => l_status );

		     x_err_code := l_err_code;
		     x_status   := l_status;
		    --dbms_output.put_line ('after calling create_draft -' || x_err_code);
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage:= 'After create_draft, budget version id is - '||l_budget_version_id;
                        pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                        pa_debug.g_err_stage:= 'error code - '||l_err_code;
                        pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                        pa_debug.g_err_stage:= 'error status - '||l_status;
                        pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     END IF;

		 /*  END IF;  */

		   IF x_err_code = 0 then

		    --dbms_output.put_line ('calling create_line ' );
		    create_line (
			  p_project_id        => p_project_id,
			  p_start_date        => proj_dates_rec.start_date,
			  p_end_date          => proj_dates_rec.completion_date,
			  p_resource_list_member_id  => res_info_rec.resource_list_member_id,
			  p_budget_version_id => l_budget_version_id,
			  x_err_code          => l_err_code,
			  x_status            => l_status );

		     x_err_code := l_err_code;
		     x_status   := l_status;

                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage:= 'After create_line';
                        pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                        pa_debug.g_err_stage:= 'error code - '||l_err_code;
                        pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                        pa_debug.g_err_stage:= 'error status - '||l_status;
                        pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     END IF;
	/*
		 ELSE
		    x_status   := l_status;
	*/
		    --dbms_output.put_line ('err  2 - ' || x_err_code);
		    --dbms_output.put_line ('stat 2 - ' || x_status);
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage:= 'After create_line - 1';
                        pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                        pa_debug.g_err_stage:= 'error code - '||l_err_code;
                        pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                        pa_debug.g_err_stage:= 'error status - '||l_status;
                        pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     END IF;

		  END IF;
/* Added for fp */
            ELSE  /* plan type is null */

		 pa_billing_core.check_funding_level (
			x_project_id    => p_project_id,
			x_funding_level => l_funding_level,
			x_err_code      => l_err_code,
			x_err_stage     => l_err_stage,
			x_err_stack     => l_err_stack);

		 IF l_err_code <> 0 then
		       x_err_code := l_err_code;
		       x_status := l_err_stage;
		 END IF;

                 IF x_err_code = 0 THEN

/* FP.K.B3 - PA_FP_AUTO_BASELINE_PKG.CREATE_BASELINED_VERSION - Expects funding level only
			 IF l_funding_level = 'P' THEN
			    l_fp_level_code := 'P';
			 ELSIF l_funding_level = 'T' THEN
			    l_fp_level_code := 'T';
			 END IF;
*/
			 FOR fp_rec IN funding_amount (l_funding_level) /*Bug 8718600*/
			 LOOP

                            l_start_date := NULL;
                            l_end_date := NULL;

			    IF fp_rec.task_id is not null
			    THEN
				select start_date, completion_date
				into   l_start_date, l_end_date
				from   pa_tasks
				where  task_id = fp_rec.task_id
				and    project_id = p_project_id;

				if  l_start_date is null then
				    l_start_date := proj_dates_rec.start_date;
				end if;

				if  l_end_date is null then
				    l_end_date := proj_dates_rec.completion_date;
				end if;

				l_task_id := fp_rec.task_id;

			   ELSE

				l_start_date := proj_dates_rec.start_date;
				l_end_date := proj_dates_rec.completion_date;
				l_task_id := 0;

			   END IF;

                           i := i + 1;

			   l_funding_bl_tab(i).task_id := l_task_id;
			   l_funding_bl_tab(i).description := 'Default Created by Projects';
			   l_funding_bl_tab(i).start_date := l_start_date;
			   l_funding_bl_tab(i).end_date := l_end_date;
			   l_funding_bl_tab(i).projfunc_revenue := fp_rec.pf_fund_amt;
			   l_funding_bl_tab(i).project_revenue := fp_rec.proj_fund_amt;

			END LOOP;
/* FP.K.B3 - The name of the procedure is CREATE_BASELINED_VERSION
			 PA_FP_AUTO_BASELINE_PKG.CREATE_AUTO_BASELINE_VERSION (
*/
			 PA_FP_AUTO_BASELINE_PKG.CREATE_BASELINED_VERSION (
				   p_project_id          => p_project_id,
				   p_fin_plan_type_id    => l_plan_type_id,
/* 				   p_funding_level_code  => l_fp_level_code, FP.K.B3 - Parameter name changed */
				   p_funding_level_code  => l_funding_level,  /* FP.K.B3 - Funding level to be passed */
				   p_version_name        => 'Revenue Budget 1',
				   p_description         => 'Default Created by Projects',
				   p_funding_bl_tab      => l_funding_bl_tab,
				   x_budget_version_id   => l_budget_version_id,
				   x_return_status       => l_return_status,
				   x_msg_count           => l_msg_count,
				   x_msg_data            => l_msg_data );

                 END IF; /* x_err_code */

            END IF; /* plan type is null */

         END IF; /* x_err_code 1 */
/* Added for fp - end*/

         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:= 'After the Fin Plan Type check';
            pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            pa_debug.g_err_stage:= 'error code is - '||x_err_code;
            pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            pa_debug.g_err_stage:= 'return status is -'||l_return_status;
            pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         END IF;

         IF x_err_code = 0 and l_return_status = FND_API.G_RET_STS_SUCCESS then
          IF l_plan_type_id is NULL THEN  /* For bug 4198840*/
            --dbms_output.put_line ('calling summerize ' );
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:= 'Calling budget_utils summarize_project_totals';
               pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;

            pa_budget_utils.summerize_project_totals (
                  x_budget_version_id => l_budget_version_id,
                  x_err_code          => l_err_code,
                  x_err_stage         => l_err_stage,
                  x_err_stack         => l_err_stack);

            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:= 'After summerize, error code - '||l_err_code;
               pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
               pa_debug.g_err_stage:= 'After summerize, error stage - '||l_err_stage;
               pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;
            x_err_code := l_err_code;
            x_status   := l_err_stage;
/*
         ELSE
            x_status   := l_status;
*/
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:= 'Error status  - '||l_status;
               pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;
            --dbms_output.put_line ('err  3 - ' || x_err_code);
            --dbms_output.put_line ('stat 3 - ' || x_status);
          END IF; --For bug 4198840
         END IF;


         IF x_err_code = 0 and l_plan_type_id IS NULL then
            --dbms_output.put_line ('calling baseline ' );
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:= 'Calling budget_core.baseline';
               pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;
            pa_budget_core.baseline(
                  x_draft_version_id => l_budget_version_id,
                  x_mark_as_original  => 'Y',
                  x_verify_budget_rules => 'Y',
                  x_err_code          => l_err_code,
                  x_err_stage         => l_err_stage,
                  x_err_stack         => l_err_stack);

            x_err_code := l_err_code;
            x_status   := l_err_stage;
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:= 'After baseline, error code - '||l_err_code;
               pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
               pa_debug.g_err_stage:= 'error stage - '||l_err_stage;
               pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;
/*

         ELSE
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:= 'error stage - '||l_err_stage;
               pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;
            x_status   := l_err_stage;
*/
            --dbms_output.put_line ('stat 4 - ' || x_status);

         END IF;

         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:= 'x_err_code - '||x_err_code;
            pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            pa_debug.g_err_stage:= 'return status - '||l_return_status;
            pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         END IF;
         if x_err_code <> 0 or l_return_status <> FND_API.G_RET_STS_SUCCESS then
            rollback to temp_pt;
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage:= 'Rolling back';
            pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
         END IF;
            --dbms_output.put_line ('stat 5 - ' || x_status);
         end if;
         pa_debug.reset_err_stack;

    EXCEPTION
        WHEN OTHERS THEN

             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:= 'In exception of create_budget_baseline';
                pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             END IF;
             x_err_code := SQLCODE;
             x_status := substr(SQLERRM,1,50);
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.g_err_stage:= 'error code - '||x_err_code;
                pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'status - '||x_status;
                pa_debug.write('create_line: ' || g_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
             END IF;

    END  create_budget_baseline;

-- FP_M changes:
-- Following APIs Proj_Agreement_Baseline and Change_Management_Baseline
-- are created from FP_M onwards

-- This API is for baselining only required Project's agreement's
-- funding lines
Procedure Proj_Agreement_Baseline (
  P_Project_ID		IN    NUMBER,
  P_Agreement_ID	IN    NUMBER,
  X_Err_Code		OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_Status		OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
BEGIN

  -- Set the global value
  PA_Funding_Core.G_FUND_BASELINE_FLAG := 'Y';

  -- First update the submit_Baseline_Flag as 'Y' and then proceed for
  -- further baselining of the funding lines
  Update PA_Project_Fundings
  SET    Submit_Baseline_Flag = 'Y'
  Where  Project_ID = P_Project_ID
  AND    Agreement_ID = P_Agreement_ID
  AND    CI_ID is null
  AND    Budget_Type_Code = 'DRAFT'
  AND    NVL(Submit_Baseline_Flag,'N') <> 'Y';

  -- Now call the regular baselining API Create_Budget_Baseline
  create_budget_baseline (
      p_project_id => P_Project_ID,
      x_err_code   => X_Err_Code,
      x_status     => X_Status
  );

  -- Unset the global value back to 'N'
  PA_Funding_Core.G_FUND_BASELINE_FLAG := 'N';

END Proj_Agreement_Baseline;

-- FP_M changes:
-- This API is for baselining only required Project's agreement's
-- funding lines that are created thru change order management page
Procedure Change_Management_Baseline (
  P_Project_ID		IN    NUMBER,
  P_CI_ID_Tab		IN    PA_PLSQL_DATATYPES.IdTabTyp,
  X_Err_Code		OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
  X_Status		OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
BEGIN

  -- Set the global value
  PA_Funding_Core.G_FUND_BASELINE_FLAG := 'Y';

  -- First update the submit_Baseline_Flag as 'Y' and then proceed for
  -- further baselining of the funding lines
  FORALL ci_rec in P_CI_ID_Tab.FIRST..P_CI_ID_Tab.LAST
  Update PA_Project_Fundings
  SET    Submit_Baseline_Flag = 'Y'
  Where  Project_ID = P_Project_ID
  AND    CI_ID = P_CI_ID_Tab(ci_rec)
  AND    Budget_Type_Code = 'DRAFT'
  AND    NVL(Submit_Baseline_Flag,'N') <> 'Y';

  -- Now call the regular baselining API Create_Budget_Baseline
  create_budget_baseline (
      p_project_id => P_Project_ID,
      x_err_code   => X_Err_Code,
      x_status     => X_Status
  );

  -- Unset the global value back to 'N'
  PA_Funding_Core.G_FUND_BASELINE_FLAG := 'N';

END Change_Management_Baseline;

END PA_BASELINE_FUNDING_PKG;

/
