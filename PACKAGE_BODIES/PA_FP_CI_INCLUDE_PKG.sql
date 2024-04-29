--------------------------------------------------------
--  DDL for Package Body PA_FP_CI_INCLUDE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_CI_INCLUDE_PKG" AS
/* $Header: PAFPINCB.pls 120.1 2005/08/19 16:26:49 mwasowic noship $ */




PROCEDURE FP_CI_COPY_CONTROL_ITEMS
(
  p_project_id          IN pa_budget_versions.project_id%TYPE,
  p_source_ci_id_tbl    IN PA_PLSQL_DATATYPES.IdTabTyp,
  p_target_ci_id        IN pa_budget_versions.ci_id%TYPE,
  p_merge_unmerge_mode  IN VARCHAR2 ,
  p_commit_flag         IN VARCHAR2 ,
  p_init_msg_list       IN VARCHAR2 ,
  p_calling_context     IN VARCHAR2,
  x_warning_flag        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_data            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
 IS
       --Defining amount variables
       l_approved_cost_flag pa_budget_versions.approved_cost_plan_type_flag%TYPE;
       l_approved_rev_flag  pa_budget_versions.approved_rev_plan_type_flag%TYPE;
       l_ci_id              pa_budget_versions.ci_id%TYPE;
       l_second_bv_id       pa_budget_versions.budget_version_id%TYPE;

       --Defining PL/SQL local variables
       l_s_fp_version_id_tbl    PA_PLSQL_DATATYPES.IdTabTyp;
       l_t_fp_version_id_tbl    PA_PLSQL_DATATYPES.IdTabTyp;

       l_s_fp_ci_id_tbl     PA_PLSQL_DATATYPES.IdTabTyp;
       l_t_fp_ci_id_tbl     PA_PLSQL_DATATYPES.IdTabTyp;

       l_s_fp_ci_id     pa_budget_versions.ci_id%TYPE;
       l_t_fp_ci_id     pa_budget_versions.ci_id%TYPE;

       l_source_version_id  pa_budget_versions.budget_version_id%TYPE;
       l_target_version_id  pa_budget_versions.budget_version_id%TYPE;

       l_s_fin_plan_pref_code   pa_proj_fp_options. fin_plan_preference_code%TYPE;
       l_s_multi_curr_flag      pa_proj_fp_options. plan_in_multi_curr_flag%TYPE;
       l_s_time_phased_code     pa_proj_fp_options. all_time_phased_code%TYPE;
       l_s_resource_list_id     pa_proj_fp_options.all_resource_list_id%TYPE;
       l_s_fin_plan_level_code  pa_proj_fp_options.all_fin_plan_level_code%TYPE;
       l_s_uncategorized_flag   pa_resource_lists_all_bg.uncategorized_flag %TYPE;
       l_s_group_res_type_id    pa_resource_lists_all_bg.group_resource_type_id%TYPE;
       l_s_version_type         pa_budget_versions.version_type%TYPE;
       l_s_ci_id                pa_budget_versions.ci_id%TYPE;

       l_copy_version_flag  VARCHAR2(1);
       l_copy_possible_flag VARCHAR2(1);
       l_debug_mode         VARCHAR2(30);
       l_bulk_fetch_count   NUMBER := 0;
       l_index              NUMBER := 1;
       l_count              NUMBER := 0;
       l_count_versions     NUMBER := 0;
       l_count_projects     NUMBER := 0;
       l_target_plan_types_cnt  NUMBER := 0;
       l_merged_count       NUMBER := 0;
       l_source_project_id  pa_control_items.project_id%TYPE;

 BEGIN
    savepoint before_copy_control_items;
        pa_debug.init_err_stack('PAFPINCB.FP_CI_COPY_CONTROL_ITEMS');
        IF NVL(p_init_msg_list,'N') = 'Y' THEN
        FND_MSG_PUB.initialize;
        END IF;
        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'Y');
        pa_debug.set_process('PLSQL','LOG',l_debug_mode);
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;

        IF (p_calling_context = 'COPY') THEN
            --A change document is being copied to another change document
            --This means only one source change order and one target change order exists

            For i in p_source_ci_id_tbl.FIRST.. p_source_ci_id_tbl.LAST
            LOOP
                --Getting the lone source ci_id from the PlSql Table
                l_s_fp_ci_id := p_source_ci_id_tbl(i);
            END LOOP;

            --Getting the target ci_id from the parameter
            l_t_fp_ci_id := p_target_ci_id;

            --DBMS_OUTPUT.PUT_LINE('l_s_fp_ci_id : ' || l_s_fp_ci_id);
            --DBMS_OUTPUT.PUT_LINE('l_t_fp_ci_id : ' || l_t_fp_ci_id);

            --Checking if control item id is null
            IF l_s_fp_ci_id IS NULL THEN
                PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                               p_msg_name => 'PA_FP_CI_NULL_CI_ID'
                             );
                x_warning_flag := 'Y';
                RETURN;
            END IF;
                IF l_t_fp_ci_id IS NULL THEN
                PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                               p_msg_name => 'PA_FP_CI_NULL_CI_ID'
                             );
                x_warning_flag := 'Y';
                RETURN;
            END IF;
            IF p_project_id IS NULL THEN
                PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                               p_msg_name => 'PA_FP_CI_NULL_PARAM_PASSED'
                             );
                x_warning_flag := 'Y';
                RETURN;
            END IF;

            --Check if the source control item id belongs
            --to the same project or not as the target control item id

            SELECT bv.project_id
            INTO l_source_project_id
            FROM pa_control_items bv
            WHERE
            bv.ci_id = l_s_fp_ci_id;

            --DBMS_OUTPUT.PUT_LINE('l_source_project_id : ' || l_source_project_id);

            IF (l_source_project_id <> p_project_id) THEN
                PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CI_INV_PROJECT_MATCH'
                    );
                x_warning_flag := 'Y';
                RETURN;
            END IF;

            -- Bug 3677924 Raja 02-Jul-04  Create impact records for the target ci
            populate_ci_fin_impact_records
                 (
                  p_project_id         => p_project_id
                  ,p_source_ci_id      => l_s_fp_ci_id
                  ,p_target_ci_id      => l_t_fp_ci_id
                  ,p_calling_context   => 'COPY'
                  ,x_return_status     => x_return_status
                  ,x_msg_count         => x_msg_count
                  ,x_msg_data          => x_msg_data
                 );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                ----DBMS_OUTPUT.PUT_LINE('FP_CI_COPY_CONTROL_ITEMS - 9');
                x_warning_flag := 'Y';
                ROLLBACK TO before_copy_control_items;
                RETURN;
            END IF;

            --If the source belongs to the same project
            --as the target then go ahead with processing

            Pa_Fp_Ci_Merge.FP_CI_MERGE_CI_ITEMS
               (
                p_project_id            => p_project_id,
                p_s_fp_ci_id            => l_s_fp_ci_id,
                p_t_fp_ci_id            => l_t_fp_ci_id,
                p_merge_unmerge_mode    => p_merge_unmerge_mode,
                p_commit_flag           => 'N',
                p_init_msg_list         => 'N',
                p_calling_context       => 'COPY',
                x_warning_flag          => x_warning_flag,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data
               );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                ----DBMS_OUTPUT.PUT_LINE('FP_CI_COPY_CONTROL_ITEMS - 9');
                x_warning_flag := 'Y';
                RETURN;
            END IF;
            IF x_warning_flag = 'Y' THEN
                ----DBMS_OUTPUT.PUT_LINE('FP_CI_COPY_CONTROL_ITEMS - 10');
                ROLLBACK TO before_copy_control_items;
                PA_UTILS.ADD_MESSAGE
                    ( p_app_short_name => 'PA',
                      p_msg_name       => 'PA_FP_CI_NO_COPY_POSSIBLE'
                    );
                    x_return_status := FND_API.G_RET_STS_ERROR;
                RETURN;
            END IF;
        ELSIF (p_calling_context = 'INCLUDE') THEN
            --One or more change documents are being copied to another change document
            --This means only one source change order and one target change order exists

            For i in p_source_ci_id_tbl.FIRST.. p_source_ci_id_tbl.LAST
            LOOP
                BEGIN
                    --Getting the source ci_id from the PlSql Table
                    l_s_fp_ci_id := p_source_ci_id_tbl(i);

                    --Getting the target ci_id from the parameter
                    l_t_fp_ci_id := p_target_ci_id;

                    --DBMS_OUTPUT.PUT_LINE('l_s_fp_ci_id : ' || l_s_fp_ci_id);
                    --DBMS_OUTPUT.PUT_LINE('l_t_fp_ci_id : ' || l_t_fp_ci_id);

                    --Checking if control item id is null
                    IF l_s_fp_ci_id IS NULL THEN
                        PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                                       p_msg_name => 'PA_FP_CI_NULL_CI_ID'
                                     );
                        raise RAISE_COPY_CI_ERROR;
                    END IF;
                    IF l_t_fp_ci_id IS NULL THEN
                        PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                                       p_msg_name => 'PA_FP_CI_NULL_CI_ID'
                                     );
                        raise RAISE_COPY_CI_ERROR;
                    END IF;
                    IF p_project_id IS NULL THEN
                        PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                                       p_msg_name => 'PA_FP_CI_NULL_PARAM_PASSED'
                                     );
                        raise RAISE_COPY_CI_ERROR;
                    END IF;

                    --Check if the source control item id belongs
                    --to the same project or not as the target control item id
                    SELECT bv.project_id
                    INTO l_source_project_id
                    FROM pa_control_items bv
                    WHERE
                    bv.ci_id = l_s_fp_ci_id;

                    --DBMS_OUTPUT.PUT_LINE('l_source_project_id : ' || l_source_project_id);

                    IF (l_source_project_id <> p_project_id) THEN
                        PA_UTILS.ADD_MESSAGE
                            ( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_CI_INV_PROJECT_MATCH'
                            );
                        raise RAISE_COPY_CI_ERROR;
                    END IF;

                    -- Bug 3677924 Raja 02-Jul-04  Create impact records for the target ci
                    populate_ci_fin_impact_records
                         (
                          p_project_id         => p_project_id
                          ,p_source_ci_id      => l_s_fp_ci_id
                          ,p_target_ci_id      => l_t_fp_ci_id
                          ,p_calling_context   => 'COPY'
                          ,x_return_status     => x_return_status
                          ,x_msg_count         => x_msg_count
                          ,x_msg_data          => x_msg_data
                         );
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        ----DBMS_OUTPUT.PUT_LINE('FP_CI_COPY_CONTROL_ITEMS - 9');
                        x_warning_flag := 'Y';
                        ROLLBACK TO before_copy_control_items;
                        RETURN;
                    END IF;

                    --If the source belongs to the same project
                    --as the target then go ahead with processing

                    Pa_Fp_Ci_Merge.FP_CI_MERGE_CI_ITEMS
                       (
                        p_project_id            => p_project_id,
                        p_s_fp_ci_id            => l_s_fp_ci_id,
                        p_t_fp_ci_id            => l_t_fp_ci_id,
                        p_merge_unmerge_mode    => p_merge_unmerge_mode,
                        p_commit_flag           => 'N',
                        p_init_msg_list         => 'N',
                        p_calling_context       => 'COPY',
                        x_warning_flag          => x_warning_flag,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data
                       );
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        ----DBMS_OUTPUT.PUT_LINE('FP_CI_COPY_CONTROL_ITEMS - 9');
                        x_warning_flag := 'Y';
                        RETURN;
                    END IF;
                    IF x_warning_flag = 'Y' THEN
                        raise RAISE_COPY_CI_ERROR;
                        ----DBMS_OUTPUT.PUT_LINE('FP_CI_COPY_CONTROL_ITEMS - 10');
                    END IF;
                EXCEPTION
                    WHEN RAISE_COPY_CI_ERROR THEN
                        x_warning_flag := 'Y';
                        x_return_status := FND_API.G_RET_STS_ERROR;
                END;
            END LOOP;
            IF x_warning_flag = 'Y' THEN
            ----DBMS_OUTPUT.PUT_LINE('FP_CI_COPY_CONTROL_ITEMS - 10');
            ROLLBACK TO before_copy_control_items;
            PA_UTILS.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name       => 'PA_FP_CI_NO_COPY_POSSIBLE'
                );
            END IF;
        END IF;
        IF NVL(p_commit_flag,'N') = 'Y' THEN
             COMMIT;
        END IF;
 EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO before_copy_control_items;
        FND_MSG_PUB.add_exc_msg
               ( p_pkg_name       => 'pa_fp_ci_include_pkg.' ||
                'FP_CI_COPY_CONTROL_ITEMS'
                ,p_procedure_name => PA_DEBUG.G_Err_Stack);
        PA_DEBUG.g_err_stage := 'Unexpected error in FP_CI_COPY_CONTROL_ITEMS';
        PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        ----DBMS_OUTPUT.PUT_LINE('FP_CI_COPY_CONTROL_ITEMS - 11*****');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        PA_DEBUG.Reset_Curr_Function;
        RAISE;

 END FP_CI_COPY_CONTROL_ITEMS;
--end of FP_CI_COPY_CONTROL_ITEMS

/*=============================================================================
 This api is called to create financial realted impacts in pa_ci_impacts during
 change document inclusion or change document copy.

 02-Jul-2004   rravipat  Bug 3677924
                         Initial Creation
==============================================================================*/

PROCEDURE populate_ci_fin_impact_records(
          p_project_id           IN   pa_projects_all.project_id%TYPE
          ,p_source_ci_id        IN   pa_budget_versions.ci_id%TYPE
          ,p_target_ci_id        IN   pa_budget_versions.ci_id%TYPE
          ,p_calling_context     IN   VARCHAR2
          ,x_return_status       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count           OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data            OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

    --Start of variables used for debugging

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER := 0;
    l_msg_data           VARCHAR2(2000);
    l_data               VARCHAR2(2000);
    l_msg_index_out      NUMBER;
    l_debug_mode         VARCHAR2(30);
    l_module_name        VARCHAR2(30) := 'pa_fp_ci_include_pkg';

    --End of variables used for debugging

    l_appr_bdgt_pt_exists     VARCHAR2(1);
    l_allowed_impacts_count   NUMBER;

    l_impact_type_code VARCHAR2(30);
    l_desp VARCHAR2(4000);
    l_comment VARCHAR2(4000);
    l_ci_impact_id NUMBER;
    l_implementation_date DATE;
    l_implemented_by NUMBER;
    l_record_ver_number NUMBER;
    l_temp VARCHAR2(1);

    l_rowid VARCHAR(100);
    l_new_ci_impact_id NUMBER;
    l_task_id NUMBER;
    l_temp2 VARCHAR2(4000);


    -- get source CI impacts
    -- note FINPLAN record is not compulsory
    CURSOR get_source_ci_impacts
    IS
      SELECT  a.*
        FROM  pa_ci_impacts a
       WHERE  a.ci_id = p_source_ci_id
         AND  a.impact_type_code IN ('FINPLAN_COST','FINPLAN_REVENUE','FINPLAN')
         AND (a.impact_type_code = 'FINPLAN' OR
                EXISTS (SELECT 1
                          FROM pa_control_items targetCi,
                               pa_ci_impact_type_usage targetUsage
                         WHERE targetCi.ci_id = p_target_ci_id
                           AND targetCi.ci_type_id = targetUsage.ci_type_id
                           AND targetUsage.impact_type_code = a.impact_type_code));


    -- get the copy to CI impacts
    CURSOR get_orig_info
    IS
      SELECT ci_impact_id, description, implementation_comment,
             implementation_date, implemented_by, record_version_number,
             impacted_task_id
      FROM   pa_ci_impacts
      WHERE  ci_id = p_target_ci_id
      AND    impact_type_code = l_impact_type_code;

BEGIN

    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');

    -- Set curr function
    pa_debug.set_curr_function(
                p_function   =>'PAFPINCB.populate_ci_fin_impact_records'
               ,p_debug_mode => l_debug_mode );

    -- Check for business rules violations
    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write('populate_ci_fin_impact_records: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF (p_project_id IS NULL) OR
       (p_target_ci_id IS NULL) OR
       (p_source_ci_id IS NULL) OR
       (p_calling_context NOT IN ('INCLUDE','COPY'))
    THEN

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Project_id = '||p_project_id;
           pa_debug.write('populate_ci_fin_impact_records: ' || l_module_name,pa_debug.g_err_stage,5);

           pa_debug.g_err_stage:='p_target_ci_id = '||p_target_ci_id;
           pa_debug.write('populate_ci_fin_impact_records: ' || l_module_name,pa_debug.g_err_stage,5);

           pa_debug.g_err_stage:='p_source_ci_id = '||p_source_ci_id;
           pa_debug.write('populate_ci_fin_impact_records: ' || l_module_name,pa_debug.g_err_stage,5);

           pa_debug.g_err_stage:='p_calling_context = '||p_calling_context;
           pa_debug.write('populate_ci_fin_impact_records: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;

        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                              p_token1         => 'PROCEDURENAME',
                              p_value1         => 'FP_CI_COPY_CONTROL_ITEMS.populate_ci_fin_impact_records');

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    -- if target project has an approved budget meaning 'Cost and Rev Together' setup
    -- then for a change document to have financial impact the change document type
    -- should allow both cost impact and revenue impacts.
    Begin
        select 'Y'
        into   l_appr_bdgt_pt_exists
        from   dual
        where  exists
               (select 1 from pa_proj_fp_options
                where  project_id = p_project_id
                and    approved_cost_plan_type_flag = 'Y'
                and    approved_rev_plan_type_flag = 'Y'
                and    fin_plan_option_level_code = 'PLAN_TYPE'
                and    fin_plan_preference_code = 'COST_AND_REV_SAME');
    Exception
        When no_data_found then
            l_appr_bdgt_pt_exists := 'N';
    End;


    -- Check if change order type allows either of cost, revenue impacts
    SELECT count(*)
    INTO   l_allowed_impacts_count
    FROM   pa_control_items pci,
           pa_ci_impact_type_usage pcit
    WHERE  pci.ci_type_id = pcit.ci_type_id
    AND    pci.ci_id = p_target_ci_id
    AND    impact_type_code IN ('FINPLAN_COST','FINPLAN_REVENUE');

    IF l_allowed_impacts_count = 0 THEN
       -- target change order type does not allow financail impact
       pa_debug.reset_curr_function();
       return;
    ELSIF l_allowed_impacts_count = 1 THEN

        IF l_appr_bdgt_pt_exists = 'Y' THEN
           -- if its approved budget create impact records only if change
           -- type allows both cost and revenue impacts
           pa_debug.reset_curr_function();
           return;
        END IF;
    END IF;

    -- fetch all the financial impact records that are present in source change
    -- document, if a record already exists its updated else a new record is created
    FOR rec IN get_source_ci_impacts
    LOOP

        l_impact_type_code := rec.impact_type_code;

        OPEN get_orig_info;

        FETCH get_orig_info INTO l_ci_impact_id, l_desp, l_comment,
          l_implementation_date, l_implemented_by, l_record_ver_number, l_task_id;

        IF get_orig_info%notfound THEN
           -- insert a new record to the new impact
           pa_ci_impacts_pkg.insert_row(
                         l_rowid,
                         l_new_ci_impact_id,
                         p_target_ci_id,
                         rec.impact_type_code,
                         'CI_IMPACT_PENDING',
                         rec.description,
                         NULL,
                         NULL,
                         NULL,
                         rec.impacted_task_id,
                         sysdate,
                         fnd_global.user_id,
                         Sysdate,
                         fnd_global.user_id,
                         fnd_global.login_id
                        );
        ELSE
           l_temp2 := Substr(l_desp || ' ' || rec.description, 1, 4000);

           -- update the existing one
           pa_ci_impacts_pkg.update_row(
                         l_ci_impact_id,
                         p_target_ci_id,
                         l_impact_type_code,
                         NULL,
                         l_temp2,
                         l_implementation_date,
                         l_implemented_by,
                         l_comment,
                         Nvl(l_task_id, rec.impacted_task_id),
                         sysdate,
                         fnd_global.user_id,
                         fnd_global.login_id,
                         l_record_ver_number
                        );
        END IF;

        CLOSE get_orig_info;
    END LOOP;


    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Exiting populate_ci_fin_impact_records';
        pa_debug.write('populate_ci_fin_impact_records: ' || l_module_name,pa_debug.g_err_stage,3);
    END IF;

    -- reset curr function
    pa_debug.reset_curr_function();

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
           pa_debug.write('populate_ci_fin_impact_records: ' || l_module_name,pa_debug.g_err_stage,5);

       END IF;

       -- reset curr function
       pa_debug.reset_curr_function();

       RETURN;
   WHEN Others THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count     := 1;
       x_msg_data      := SQLERRM;

       FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'FP_CI_COPY_CONTROL_ITEMS'
                               ,p_procedure_name  => 'populate_ci_fin_impact_records');

       IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
           pa_debug.write('populate_ci_fin_impact_records: ' || l_module_name,pa_debug.g_err_stage,5);
       END IF;

       -- reset curr function
       pa_debug.Reset_Curr_Function();

       RAISE;
END populate_ci_fin_impact_records;



END pa_fp_ci_include_pkg;
--end of PACKAGE pa_fp_ci_include_pkg

/
