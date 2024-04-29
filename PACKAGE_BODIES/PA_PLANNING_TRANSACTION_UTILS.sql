--------------------------------------------------------
--  DDL for Package Body PA_PLANNING_TRANSACTION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PLANNING_TRANSACTION_UTILS" AS
/* $Header: PAFPPTUB.pls 120.5.12010000.4 2009/10/09 06:39:27 rrambati ship $ */

 -----------------------------------------------
 -- Declaring global datatypes and variables
 -----------------------------------------------
 g_module_name   VARCHAR2(100) := 'pa.plsql.PA_PLANNING_TRANSACTION_UTILS';

--This record type will contain key and a value. A pl/sql tbl of this record type can be declared and it can be
--used for different purposes. One such case is : if its required to get the start date for a task id at many
--places in the code then instead of firing a select each time we can fetch it and store in this record. The key
--will be the task id and the value will be top task id.
--Created for bug 3678314
TYPE key_value_rec IS RECORD
(key                          NUMBER
,value                        DATE);

TYPE key_value_rec_tbl_type IS TABLE OF key_value_rec
      INDEX BY BINARY_INTEGER;

 /*=====================================================================
 Function Name:       GET_WP_BUDGET_VERSION_ID

 Purpose:             This is a public API in the package. This function
                      will return the budget_version_id for the passed
                      project_structure_version_id.
                      This is called by/from
                      - Add/Update Planning Transactions API.

 Note:               This api is called only for workplan.

 Parameters:
 IN                   1) p_struct_elem_version_id
                                          - project_structure_version_id
 =======================================================================*/

 FUNCTION Get_Wp_Budget_Version_Id (
         p_struct_elem_version_id IN pa_budget_versions.project_structure_version_id%TYPE
         )
 RETURN  NUMBER
 IS
 l_budget_version_id NUMBER;

 BEGIN
 --------------------------------------------------------------------
 --   Parameter Validations -
 --   return null if p_struct_elem_version_id is passed as NULL
 --------------------------------------------------------------------
  IF p_struct_elem_version_id IS NULL THEN
     return NULL;
  END IF;

 --------------------------------------------------------------------
 --   Fetching budget_version_id.
 --   Please note that this API is only called for getting the
 --   WorkPlan Budget Version Id for the Structure Version Id passed.
 --------------------------------------------------------------------
  BEGIN
        SELECT budget_version_id
        INTO l_budget_version_id
        FROM pa_budget_versions
        WHERE project_structure_version_id = p_struct_elem_version_id
         AND nvl(wp_version_flag,'N') = 'Y';

        RETURN l_budget_version_id;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
        RETURN NULL;
  END;

 END Get_Wp_Budget_Version_Id;


/*=====================================================================
Procedure Name:      GET_RES_CLASS_RLM_IDS

Purpose:             This is a public api in the package. This procedure
                     will return the rlm ids of the resource class rlm
                     ids given the resoure list id.
                     This program is called by/from:
                       - Add/Update Planning Transactions API

=======================================================================*/
PROCEDURE Get_Res_Class_Rlm_Ids
    (p_project_id                   IN     pa_projects_all.project_id%TYPE,
     p_resource_list_id             IN     pa_resource_lists_all_bg.resource_list_id%TYPE,
     x_people_res_class_rlm_id      OUT    NOCOPY pa_resource_list_members.resource_list_member_id%TYPE, --File.Sql.39 bug 4440895
     x_equip_res_class_rlm_id       OUT    NOCOPY pa_resource_list_members.resource_list_member_id%TYPE, --File.Sql.39 bug 4440895
     x_fin_res_class_rlm_id         OUT    NOCOPY pa_resource_list_members.resource_list_member_id%TYPE, --File.Sql.39 bug 4440895
     x_mat_res_class_rlm_id         OUT    NOCOPY pa_resource_list_members.resource_list_member_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status                OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                     OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
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

     CURSOR c_rlm_ids IS
         SELECT resource_list_member_id, resource_class_code
         FROM   pa_resource_list_members,
               (SELECT  control_flag
                FROM    pa_resource_lists_all_bg
                WHERE   resource_list_id = p_resource_list_id) rl_control_flag
         WHERE  resource_list_id = p_resource_list_id
         AND   ((rl_control_flag.control_flag = 'N' AND
                 object_type = 'PROJECT' AND
                 object_id = p_project_id)
                 OR
                (rl_control_flag.control_flag = 'Y' AND
                 object_type = 'RESOURCE_LIST' AND
                 object_id = p_resource_list_id))
         AND    nvl(resource_class_flag,'N') = 'Y';

 BEGIN


    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'N');
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
IF l_debug_mode = 'Y' THEN
    PA_DEBUG.Set_Curr_Function( p_function   => 'PA_PLAN_TXN_UTILS.Get_Res_Class_Rlm_Ids',
                                p_debug_mode => l_debug_mode );
END IF;
   ---------------------------------------------------------------
   -- validating input parameter p_resource_list_id.
   -- p_resource_list_id cannot be passed as null.
   ---------------------------------------------------------------

     IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Validating input parameters';
       pa_debug.write('PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Ids: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

     IF (p_resource_list_id IS NULL) THEN

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='p_resource_list_id is null';
             pa_debug.write('PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Id: ' || g_module_name,pa_debug.g_err_stage,5);
          END IF;
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;


    -------------------------------------------------------------------
    -- Fetching rlm ids from the cursor c_rlm_ids defined above
    -- For Class Code              Fetch Into
    -- --------------              -----------------
    -- EQUIPMENT                   x_equip_res_class_rlm_id
    -- FINANCIAL_ELEMENT           x_fin_res_class_rlm_id
    -- MATERIAL                    x_mat_res_class_rlm_id
    -- PEOPLE                      x_people_res_class_rlm_id
    -------------------------------------------------------------------


     IF l_debug_mode = 'Y' THEN
       pa_debug.g_err_stage:='Fetching rlm ids';
       pa_debug.write('PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Ids: ' || g_module_name,pa_debug.g_err_stage,3);
     END IF;

    FOR c1 IN c_rlm_ids LOOP -- LoopA starts

      IF c1.resource_class_code = PA_FP_CONSTANTS_PKG.G_RESOURCE_CLASS_CODE_EQUIP THEN
         x_equip_res_class_rlm_id := c1.resource_list_member_id;

      ELSIF c1.resource_class_code = PA_FP_CONSTANTS_PKG.G_RESOURCE_CLASS_CODE_FIN THEN
         x_fin_res_class_rlm_id := c1.resource_list_member_id;

      ELSIF c1.resource_class_code = PA_FP_CONSTANTS_PKG.G_RESOURCE_CLASS_CODE_MAT THEN
         x_mat_res_class_rlm_id := c1.resource_list_member_id;

      ELSIF c1.resource_class_code = PA_FP_CONSTANTS_PKG.G_RESOURCE_CLASS_CODE_PPL THEN
         x_people_res_class_rlm_id := c1.resource_list_member_id;

      END IF;
    END LOOP; -- LoopA Ends
   IF l_debug_mode = 'Y' THEN
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
              pa_debug.write('PA_PLANNING_TRANSACTION_UTILS.Get_Res_Class_Rlm_Ids : ' || g_module_name,pa_debug.g_err_stage,5);
              pa_debug.reset_curr_function;
          END IF;
       WHEN Others THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_PLANNING_TRANSACTION_UTILS'
                                  ,p_procedure_name  => 'PA_PLANNING_TRANSACTION_UTILS.Get_res_class_rlm_ids');

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write('PA_PLANNING_TRANSACTION_UTILS.Get_res_class_rlm_ids: ' || g_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_curr_function;
          END IF;
          RAISE;


 END Get_Res_Class_Rlm_Ids;

-- This API will return the default planning start and end dates based on the element version
-- Depending on the existence either the txn, actual, estimated or scheduled dates of the task in the priority of
-- the order mentioned will be returned.If none of the them are there then the dates of the parent structure
-- version id will be passed. If the dates are not there for the parent version also then sysdate will be returned

-- The output tables x_planning_start_date_tbl and x_planning_end_date_tbl will have the same no of records as
-- in the table p_element_version_id_tbl. Duplicates are allowed in input and the derivation will be done for the duplicate
-- tasks also

-- Included p_project_id as parameter. For elem vers id as 0, project start and end dates are used.

-- Added New I/p params p_planning_start_date_tbl and x_planning_end_date_tbl -- 3793623
-- Dates will not be defaulted if they are passed to the API at a particular index.

PROCEDURE get_default_planning_dates
(  p_project_id                      IN    pa_projects_all.project_id%TYPE
  ,p_element_version_id_tbl          IN    SYSTEM.pa_num_tbl_type
  ,p_project_structure_version_id    IN    pa_budget_versions.project_structure_version_id%TYPE
  ,p_planning_start_date_tbl         IN    SYSTEM.pa_date_tbl_type  DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
  ,p_planning_end_date_tbl           IN    SYSTEM.pa_date_tbl_type  DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
  ,x_planning_start_date_tbl         OUT   NOCOPY SYSTEM.pa_date_tbl_type --File.Sql.39 bug 4440895
  ,x_planning_end_date_tbl           OUT   NOCOPY SYSTEM.pa_date_tbl_type --File.Sql.39 bug 4440895
  ,x_msg_data                        OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                       OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                   OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

    l_msg_count                            NUMBER :=0;
    l_data                                 VARCHAR2(2000);
    l_msg_data                             VARCHAR2(2000);
    l_error_msg_code                       VARCHAR2(30);
    l_msg_index_out                        NUMBER;
    l_return_status                        VARCHAR2(2000);
    l_debug_mode                           VARCHAR2(30);
    l_module_name                          VARCHAR2(100):='pafpptub.get_def_planning_dates';

    --These pl/sql tables will store the already derived st and end dates for the tasks so that
    --the process of fetching st and end dates can be avoided if duplicate tasks exist in the input
    --Changed the type of tbls for bug 3678314
    l_cached_elem_ver_st_dt_tbl            key_value_rec_tbl_type;
    l_cached_elem_ver_end_dt_tbl           key_value_rec_tbl_type;
    l_temp                                 NUMBER;

    --Variables for the start and end dates of parent structure version id
    l_parent_struct_st_dt                  DATE ;
    l_parent_struct_end_dt                 DATE ;
BEGIN

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
IF l_debug_mode = 'Y' THEN
    PA_DEBUG.Set_Curr_Function( p_function   => 'PA_FP_PLAN_TXN_UTILS.get_def_planning_dates',
                                p_debug_mode => l_debug_mode );
END IF;
    --If no records are found in the input element version id table then return
    IF p_element_version_id_tbl.COUNT=0 THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_element_version_id_tbl is empty. Returning';
            pa_debug.write(l_module_name ,pa_debug.g_err_stage,3);
            pa_debug.reset_curr_function;
        END IF;
        RETURN;

    END IF;

    IF p_project_structure_version_id IS NULL OR p_project_id IS NULL THEN

        PA_UTILS.ADD_MESSAGE
           (p_app_short_name => 'PA',
            p_msg_name       => 'PA_FP_INV_PARAM_PASSED');

        IF l_debug_mode = 'Y' THEN

            pa_debug.g_err_stage:= 'p_project_structure_version_id passed is '||p_project_structure_version_id;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);

            pa_debug.g_err_stage:= 'p_project_id passed is '|| p_project_id;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);

        END IF;

        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;


    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Looping thru the element version id tbl to derive the dates';
        pa_debug.write(l_module_name ,pa_debug.g_err_stage,3);
    END IF;

    x_planning_start_date_tbl := SYSTEM.pa_date_tbl_type();
    x_planning_end_date_tbl   := SYSTEM.pa_date_tbl_type();
    x_planning_start_date_tbl.extend(p_element_version_id_tbl.LAST);
    x_planning_end_date_tbl.extend(p_element_version_id_tbl.LAST);
    --Loop thru the input table and derive the start and end dates
    FOR i IN p_element_version_id_tbl.FIRST..p_element_version_id_tbl.LAST LOOP
        -- Validations for p_planning_start_date_tbl and p_planning_end_date_tbl
        -- Bug 3793623
        -- 1. If Start Date is passed End Date Also has to be passed.
        -- 2. It Start Date is passed as NOT NULL, End Date will also have to be passed Not Null and vice-versa.
        IF   (((p_planning_start_date_tbl.EXISTS(i) AND p_planning_start_date_tbl(i) IS NOT NULL) AND
               (p_planning_end_date_tbl.EXISTS(i) AND p_planning_end_date_tbl(i) IS NULL))
           OR ((p_planning_start_date_tbl.EXISTS(i) AND p_planning_start_date_tbl(i) IS NULL) AND
               (p_planning_end_date_tbl.EXISTS(i) AND p_planning_end_date_tbl(i) IS NOT NULL))
           OR ((p_planning_start_date_tbl.EXISTS(i)) AND NOT(p_planning_end_date_tbl.EXISTS(i)))
           OR (NOT(p_planning_start_date_tbl.EXISTS(i)) AND (p_planning_end_date_tbl.EXISTS(i)))) THEN

               IF l_debug_mode = 'Y' THEN
                   IF NOT(p_planning_start_date_tbl.EXISTS(i)) THEN
                      pa_debug.g_err_stage:='p_planning_start_date_tbl NOT Exists :'||i;
                      pa_debug.write('PA_FP_PLANNING_TRANSACTION_UTILS.get_default_planning_dates: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   IF NOT(p_planning_end_date_tbl.EXISTS(i)) THEN
                      pa_debug.g_err_stage:='p_planning_end_date_tbl NOT Exists :'||i;
                      pa_debug.write('PA_FP_PLANNING_TRANSACTION_UTILS.get_default_planning_dates: ' || l_module_name,pa_debug.g_err_stage,3);
                   END IF;
                   pa_debug.g_err_stage:='InCorrect Dates Passed p_planning_start_date_tbl :'||p_planning_start_date_tbl(i);
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_UTILS.get_default_planning_dates: ' || l_module_name,pa_debug.g_err_stage,3);

                   pa_debug.g_err_stage:='InCorrect Dates Passed p_planning_end_date_tbl :'||p_planning_end_date_tbl(i);
                   pa_debug.write('PA_FP_PLANNING_TRANSACTION_UTILS.get_default_planning_dates: ' || l_module_name,pa_debug.g_err_stage,3);
               END IF;
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                                    p_token1         => 'PROCEDURENAME',
                                    p_value1         => 'PAFPPTUB.get_default_planning_dates',
                                    p_token2         => 'STAGE',
                                    p_value2         => 'InCorrect Dates Passed');
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

        -- Bug 3793623
        -- If Both Start Date and End Dates are passed, the Input Values are honoured and
        -- No Data Fetch has to occur for Defaulting start and End dates.
        ELSIF ((p_planning_start_date_tbl.EXISTS(i) AND p_planning_start_date_tbl(i) IS NOT NULL) AND
               (p_planning_end_date_tbl.EXISTS(i) AND p_planning_end_date_tbl(i) IS NOT NULL)) THEN

                x_planning_start_date_tbl(i):= p_planning_start_date_tbl(i);
                x_planning_end_date_tbl(i)  := p_planning_end_date_tbl(i);

        ELSE
            --Check if the start date of the task is already retrieved and cached. Bug 3678314
            l_temp:=NULL;
            --For bug 3938549 changed from tbl.last to tbl.count
            FOR kk IN 1..l_cached_elem_ver_st_dt_tbl.COUNT LOOP

                IF l_cached_elem_ver_st_dt_tbl(kk).key = p_element_version_id_tbl(i) THEN

                    l_temp:=kk;
                    EXIT;

                END IF;

            END LOOP;

            IF l_temp IS NOT NULL THEN

                x_planning_start_date_tbl(i):= l_cached_elem_ver_st_dt_tbl(l_temp).value;
                x_planning_end_date_tbl(i)  := l_cached_elem_ver_end_dt_tbl(l_temp).value;

            ELSE
                --The element version id will be 0 for the project level record. The Dates for this ID will be derived
                --in the next select.
                IF p_element_version_id_tbl(i) <>0 THEN

                    --Bug 6449970 skkoppul - Added to_date conditions to all the null values in the decode
                    --statement. Null value will force the date become char. By default the nls
                    --session will have the date format as DD/MMM/RR format. So the year in the
                    --format will loose the first 2 digits. But it will converted back to date because it
                    -- selected into the date variable. So any date greater than 2050 will be wrapped
                    -- to date between 1950 and 2049.
                    SELECT nvl(pt.transaction_start_date, nvl(pt.actual_start_date, nvl(pt.estimated_start_date, pt.start_date))),
                           decode(pt.transaction_start_date,
                                  to_date(null),decode(pt.actual_start_date,
                                              to_date(null),decode(pt.estimated_start_date,
                                                          to_date(null),decode(pt.start_date,
                                                                      to_date(null),to_date(null),
                                                                      pt.completion_date),
                                                          pt.estimated_finish_date),
                                              pt.actual_finish_date),
                                  pt.transaction_completion_date)
                    INTO   x_planning_start_date_tbl(i)
                          ,x_planning_end_date_tbl(i)
                    FROM   pa_struct_task_wbs_v pt
                    WHERE  pt.element_Version_id=p_element_version_id_tbl(i)
                    AND pt.parent_structure_version_id=p_project_structure_version_id;

                END IF;

                IF x_planning_start_date_tbl(i) IS NULL AND
                   x_planning_end_date_tbl(i) IS NULL THEN

                    IF l_parent_struct_st_dt IS NULL THEN

                        --Derive the st and end dates for the parent version
    /*  After the mails from Sakthi, looks like there wouldnt be a record in the
     *  below table if the project is enabled only for Financial...
     *  Since the below select is returning no data found, fixingit to read the
     *  project start and end date and commenting the below
                        SELECT nvl(pelm.actual_start_date, nvl(pelm.estimated_start_date, pelm.scheduled_start_date)),
                               decode(pelm.actual_start_date,
                                      null,decode(pelm.estimated_start_date,
                                                  null,decode(pelm.scheduled_start_date,
                                                              null,null,
                                                              pelm.scheduled_finish_date),
                                                  pelm.estimated_finish_date),
                                      pelm.actual_finish_date)
                        INTO   l_parent_struct_st_dt
                              ,l_parent_struct_end_dt
                        FROM  pa_proj_elem_ver_schedule pelm
                        WHERE pelm.element_version_id=p_project_structure_version_id;

    */
                        SELECT start_date,decode(start_date, null, to_Date(null), completion_date)
                        INTO   l_parent_struct_st_dt ,l_parent_struct_end_dt
                        FROM   pa_projects_all
                        where  project_id = p_project_id;

                        IF l_parent_struct_st_dt IS NULL AND l_parent_struct_end_dt IS NULL THEN

                            l_parent_Struct_st_dt := trunc(sysdate);
                            l_parent_Struct_end_dt := trunc(sysdate);

                        ELSIF  l_parent_struct_end_dt IS NULL THEN

                            l_parent_Struct_end_dt := l_parent_Struct_st_dt;

                        END IF;

                    END IF;

                    x_planning_start_date_tbl(i):=l_parent_struct_st_dt;
                    x_planning_end_date_tbl(i):=l_parent_struct_end_dt;

                ELSIF x_planning_end_date_tbl(i) IS NULL THEN

                    x_planning_end_date_tbl(i):= x_planning_start_date_tbl(i);

                END IF;

                l_temp := l_cached_elem_ver_st_dt_tbl.COUNT +1;
                l_cached_elem_ver_st_dt_tbl(l_temp).key:= p_element_version_id_tbl(i);
                l_cached_elem_ver_st_dt_tbl(l_temp).value:= x_planning_start_date_tbl(i);
                l_cached_elem_ver_end_dt_tbl(l_temp).key:= p_element_version_id_tbl(i);
                l_cached_elem_ver_end_dt_tbl(l_temp).value:= x_planning_end_date_tbl(i);

            END IF;
        END IF;
    END LOOP;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Leaving get_default_planning_dates';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
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
           pa_debug.reset_curr_function;
      END IF;
     WHEN OTHERS THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_PLANNING_TRANSACTION_UTILS'
                                  ,p_procedure_name  => 'get_default_planning_dates');

           IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_curr_function;
          END IF;
          RAISE;

END get_default_planning_dates;
--This procedure populates the tmp table PJI_FM_EXTR_PLAN_LINES  and calls the API
--PJI_FM_XBS_ACCUM_MAINT.PLAN_UPDATE . The valid values for p_source are
-- 1. PA_RBS_PLANS_OUT_TMP (This is the tmp table which contains the mapped rbs elemend ids ). The PJI API will
--    be called for the rbs element ids availabe in the PA_RBS_PLANS_OUT_TMP, if the new rbs element id is different
--    from the already existing rbs element id in pa_resource_assignments. If the rbs element id is different then
---------1.Reporting lines API will be called with negative amounts for the budget lines with
--        start_date <= etc_start_date with old rbs element id. The same API will be called for the same set of
--        budget lines with +ve amounts and new rbs element id again.
---------2.Reporting lines API will NOT be called for the budget lines with start_date > etc_start_date. The
--	     calling API should take care of these budget lines ( Calling this API with context 'DEL_FLAG_Y'
--	     delete the reporting lines for budget lines with start_Date > etc_start_date)
-- 2. PA_FP_RA_MAP_TMP (This is the global temporary table which contains the resouce assignments in the source that
--    should copied. This is used for copying a version fully or some of the assignments in it ). This table is used
--    as the reference for deciding the budget lines for which reporting lines should be created
-- 3. PL-SQL : The source will be pl/sql if the pl/sql tables are populated. These pl/sql tables will be used in
--    populated the tmp table for calling the PJI Update API. This will be used in delete_planning_transactions
-- 4. DEL_FLAG_Y : This context is used in update_planning_transactions API. The API will be called with this
--      context when the the budget lines for a resource assignment should be deleted. This will delete all the
--	budget lines for a RA with start_date > etc_start_date of the version.
-- 5. PROCESS_RES_CHG_DERV_CALC_PRMS: Combination of 1 and 4.
--6   POPULATE_PJI_TABLE - This has been introduced for the bug 4543744 . This is called when we have to insert negative and
--      positive amounts in the pji table , called during the change in RBS the negative amounts are of the old rbs version id
--    existing in the pji tables and the positive amounts are of the new rbs version that is changed.

PROCEDURE call_update_rep_lines_api
(
   p_source                         IN    VARCHAR2
  ,p_budget_version_id              IN    pa_budget_versions.budget_Version_id%TYPE
  ,p_resource_assignment_id_tbl     IN    SYSTEM.pa_num_tbl_type
  ,p_period_name_tbl                IN    SYSTEM.pa_varchar2_30_tbl_type
  ,p_start_date_tbl                 IN    SYSTEM.pa_date_tbl_type
  ,p_end_date_tbl                   IN    SYSTEM.pa_date_tbl_type
  ,p_txn_currency_code_tbl          IN    SYSTEM.pa_varchar2_15_tbl_type
  ,p_txn_raw_cost_tbl               IN    SYSTEM.pa_num_tbl_type
  ,p_txn_burdened_cost_tbl          IN    SYSTEM.pa_num_tbl_type
  ,p_txn_revenue_tbl                IN    SYSTEM.pa_num_tbl_type
  ,p_project_raw_cost_tbl           IN    SYSTEM.pa_num_tbl_type
  ,p_project_burdened_cost_tbl      IN    SYSTEM.pa_num_tbl_type
  ,p_project_revenue_tbl            IN    SYSTEM.pa_num_tbl_type
  ,p_raw_cost_tbl                   IN    SYSTEM.pa_num_tbl_type
  ,p_burdened_cost_tbl              IN    SYSTEM.pa_num_tbl_type
  ,p_revenue_tbl                    IN    SYSTEM.pa_num_tbl_type
  ,p_cost_rejection_code_tbl        IN    SYSTEM.pa_varchar2_30_tbl_type
  ,p_revenue_rejection_code_tbl     IN    SYSTEM.pa_varchar2_30_tbl_type
  ,p_burden_rejection_code_tbl      IN    SYSTEM.pa_varchar2_30_tbl_type
  ,p_other_rejection_code           IN    SYSTEM.pa_varchar2_30_tbl_type
  ,p_pc_cur_conv_rej_code_tbl       IN    SYSTEM.pa_varchar2_30_tbl_type
  ,p_pfc_cur_conv_rej_code_tbl      IN    SYSTEM.pa_varchar2_30_tbl_type
  ,p_quantity_tbl                   IN    SYSTEM.pa_num_tbl_type
  ,p_rbs_element_id_tbl             IN    SYSTEM.pa_num_tbl_type
  ,p_task_id_tbl                    IN    SYSTEM.pa_num_tbl_type
  ,p_res_class_code_tbl             IN    SYSTEM.pa_varchar2_30_tbl_type
  ,p_rate_based_flag_tbl            IN    SYSTEM.pa_varchar2_1_tbl_type
  ,p_qty_sign                       IN    NUMBER  -- for bug 4543744
  ,x_return_status                  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                      OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                       OUT   NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
    --Start of variables used for debugging
    l_msg_count          NUMBER :=0;
    l_data               VARCHAR2(2000);
    l_msg_data           VARCHAR2(2000);
    l_error_msg_code     VARCHAR2(30);
    l_msg_index_out      NUMBER;
    l_return_status      VARCHAR2(2000);
    l_debug_mode         VARCHAR2(30);
    l_module_name        VARCHAR2(100):='PAFPPTUB.call_update_rep_lines_api';
    --End of variables used for debugging
    l_rows_inserted      NUMBER:=0;
    l_msg_code           VARCHAR2(2000);

    l_project_id           pa_budget_versions.project_id%TYPE;
    l_fin_structure_ver_id pa_budget_versions.project_structure_version_id%Type;
BEGIN
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'N');
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF l_debug_mode = 'Y' THEN
    PA_DEBUG.Set_Curr_Function( p_function   => 'pafpptub.call_update_rep_lines_api',
                                p_debug_mode => l_debug_mode );
        pa_debug.g_err_stage:='Validating input parameters';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;

    IF p_source IS NULL THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_source   is '||p_source;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                             p_token1         => 'PROCEDURENAME',
                             p_value1         => l_module_name );
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    IF p_budget_version_id IS NULL THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='p_budget_version_id   is '||p_budget_version_id;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
        END IF;
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED',
                             p_token1         => 'PROCEDURENAME',
                             p_value1         => l_module_name );
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

    END IF;

    IF p_source ='PL-SQL' AND
       p_resource_assignment_id_tbl.COUNT = 0 THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Resource assignment id table is empty. Returning';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
            pa_debug.reset_curr_function;
        END IF;
        RETURN;

    END IF;


    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Emptying the PJI_FM_EXTR_PLAN_LINES ';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;

    --Getting the project id to call the function PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID
    SELECT project_id INTO l_project_id
    FROM pa_budget_versions
    WHERE budget_version_id=p_budget_version_id;

    l_fin_structure_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(l_project_id);



    IF p_source = 'PA_RBS_PLANS_OUT_TMP' OR
       p_source = 'PROCESS_RES_CHG_DERV_CALC_PRMS'THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Source is PJI_FM_EXTR_PLAN_LINES. Populating the tmp table';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;

        INSERT INTO PJI_FM_EXTR_PLAN_LINES
        ( PROJECT_ID
         ,PROJECT_ORG_ID
         ,PROJECT_ELEMENT_ID
         ,STRUCT_VER_ID
         ,PERIOD_NAME
         ,CALENDAR_TYPE
         ,START_DATE
         ,END_DATE
         ,RBS_ELEMENT_ID
         ,RBS_VERSION_ID
         ,PLAN_VERSION_ID
         ,PLAN_TYPE_ID
         ,WP_VERSION_FLAG
         ,ROLLUP_TYPE
         ,TXN_CURRENCY_CODE
         ,TXN_RAW_COST
         ,TXN_BURDENED_COST
         ,TXN_REVENUE
         ,PRJ_CURRENCY_CODE
         ,PRJ_RAW_COST
         ,PRJ_BURDENED_COST
         ,PRJ_REVENUE
         ,PFC_CURRENCY_CODE
         ,PFC_RAW_COST
         ,PFC_BURDENED_COST
         ,PFC_REVENUE
         ,QUANTITY
         ,RESOURCE_CLASS_CODE
         ,RATE_BASED_FLAG)
         SELECT
          p.project_id
         ,p.org_id
         ,pra.task_id
         ,decode(pbv.wp_version_flag,'Y',pbv.project_structure_version_id,l_fin_structure_ver_id)
         ,pbl.period_name
         ,nvl(pfo.cost_time_phased_code,nvl(revenue_time_phased_code,all_time_phased_code))
         ,pbl.start_date
         ,pbl.end_date
         ,DECODE(rbs_dummy.rbs_elem_id, 'OLD' , pra.rbs_element_id, 'NEW', tmp.rbs_element_id)
         ,pfo.rbs_version_id
         ,pbv.budget_version_id
         ,pfo.fin_plan_type_id
         ,pbv.wp_version_flag
         ,'W'
         ,pbl.txn_currency_code
         ,DECODE(rbs_dummy.rbs_elem_id, 'OLD' , 0-pbl.txn_raw_cost, 'NEW', pbl.txn_raw_cost)
         ,DECODE(rbs_dummy.rbs_elem_id, 'OLD' , 0-pbl.txn_burdened_cost, 'NEW', pbl.txn_burdened_cost)
         ,DECODE(rbs_dummy.rbs_elem_id, 'OLD' , 0-pbl.txn_revenue, 'NEW', pbl.txn_revenue)
         ,p.project_currency_code
         ,DECODE(rbs_dummy.rbs_elem_id, 'OLD' , 0-pbl.project_raw_cost, 'NEW', pbl.project_raw_cost)
         ,DECODE(rbs_dummy.rbs_elem_id, 'OLD' , 0-pbl.project_burdened_cost, 'NEW', pbl.project_burdened_cost)
         ,DECODE(rbs_dummy.rbs_elem_id, 'OLD' , 0-pbl.project_revenue, 'NEW', pbl.project_revenue)
         ,p.projfunc_currency_code
         ,DECODE(rbs_dummy.rbs_elem_id, 'OLD' , 0-pbl.raw_cost, 'NEW', pbl.raw_cost)
         ,DECODE(rbs_dummy.rbs_elem_id, 'OLD' , 0-pbl.burdened_cost, 'NEW', pbl.burdened_cost)
         ,DECODE(rbs_dummy.rbs_elem_id, 'OLD' , 0-pbl.revenue, 'NEW', pbl.revenue)
         ,DECODE(rbs_dummy.rbs_elem_id, 'OLD' , 0-pbl.quantity, 'NEW', pbl.quantity)
         ,pra.resource_class_code
         ,pra.rate_based_flag
         FROM  pa_projects_all p
              ,pa_resource_assignments pra
              ,pa_budget_versions pbv
              ,pa_proj_fp_options pfo
              ,pa_rbs_plans_out_tmp tmp
              ,pa_budget_lines pbl
		  ,(SELECT 'OLD' as rbs_elem_id
		    FROM    DUAL
 		    UNION ALL
		    SELECT 'NEW' as rbs_elem_id
		    FROM    DUAL) rbs_dummy
         WHERE p.project_id=pbv.project_id
         AND   pbv.budget_version_id=p_budget_Version_id
         AND   pra.resource_assignment_id=tmp.source_id
         AND   pbv.budget_version_id=pra.budget_version_id
         AND   pfo.fin_plan_version_id=pbv.budget_Version_id
         AND   pra.rbs_element_id <> tmp.rbs_element_id
         AND   pbl.resource_assignment_id=pra.resource_assignment_id
         AND   pbl.cost_rejection_code    IS  NULL
         AND   pbl.revenue_rejection_code IS  NULL
         AND   pbl.burden_rejection_code  IS  NULL
         AND   pbl.other_rejection_code   IS  NULL
         AND   pbl.pc_cur_conv_rejection_code IS  NULL
         AND   pbl.pfc_cur_conv_rejection_code IS  NULL
	   AND   pbl.start_date <= nvl(pbv.etc_start_date, pbl.start_date+1);

        l_rows_inserted := SQL%ROWCOUNT;
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='No of rows inserted = '||l_rows_inserted;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;

    END IF;

    IF p_source ='PA_FP_RA_MAP_TMP' THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Selectiong from PA_FP_RA_MAP_TMP ';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;

        INSERT INTO PJI_FM_EXTR_PLAN_LINES
        ( PROJECT_ID
         ,PROJECT_ORG_ID
         ,PROJECT_ELEMENT_ID
         ,STRUCT_VER_ID
         ,PERIOD_NAME
         ,CALENDAR_TYPE
         ,START_DATE
         ,END_DATE
         ,RBS_ELEMENT_ID
         ,RBS_VERSION_ID
         ,PLAN_VERSION_ID
         ,PLAN_TYPE_ID
         ,WP_VERSION_FLAG
         ,ROLLUP_TYPE
         ,TXN_CURRENCY_CODE
         ,TXN_RAW_COST
         ,TXN_BURDENED_COST
         ,TXN_REVENUE
         ,PRJ_CURRENCY_CODE
         ,PRJ_RAW_COST
         ,PRJ_BURDENED_COST
         ,PRJ_REVENUE
         ,PFC_CURRENCY_CODE
         ,PFC_RAW_COST
         ,PFC_BURDENED_COST
         ,PFC_REVENUE
         ,QUANTITY
         ,RESOURCE_CLASS_CODE
         ,RATE_BASED_FLAG)
         SELECT
          p.project_id
         ,p.org_id
         ,pra.task_id
         ,decode(pbv.wp_version_flag,'Y',pbv.project_structure_version_id,l_fin_structure_ver_id)
         ,pbl.period_name
         ,nvl(pfo.cost_time_phased_code,nvl(revenue_time_phased_code,all_time_phased_code))
         ,pbl.start_date
         ,pbl.end_date
         ,pra.rbs_element_id
         ,pfo.rbs_version_id
         ,pbv.budget_version_id
         ,pfo.fin_plan_type_id
         ,pbv.wp_version_flag
         ,'W'
         ,pbl.txn_currency_code
         ,pbl.txn_raw_cost
         ,pbl.txn_burdened_cost
         ,pbl.txn_revenue
         ,p.project_currency_code
         ,pbl.project_raw_cost
         ,pbl.project_burdened_cost
         ,pbl.project_revenue
         ,p.projfunc_currency_code
         ,pbl.raw_cost
         ,pbl.burdened_cost
         ,pbl.revenue
         ,pbl.quantity
         ,pra.resource_class_code
         ,pra.rate_based_flag
         FROM  pa_projects_all p
              ,pa_resource_assignments pra
              ,pa_budget_versions pbv
              ,pa_proj_fp_options pfo
              ,pa_fp_ra_map_tmp tmp
              ,pa_budget_lines pbl
         WHERE p.project_id=pbv.project_id
         AND   pbv.budget_version_id=p_budget_version_id
         AND   pra.resource_assignment_id=tmp.target_res_assignment_id
         AND   pbv.budget_version_id=pra.budget_version_id
         AND   pfo.fin_plan_version_id=pbv.budget_Version_id
         AND   pbl.resource_assignment_id=pra.resource_assignment_id
         AND   pbl.cost_rejection_code    IS  NULL
         AND   pbl.revenue_rejection_code IS  NULL
         AND   pbl.burden_rejection_code  IS  NULL
         AND   pbl.other_rejection_code   IS  NULL
         AND   pbl.pc_cur_conv_rejection_code IS  NULL
         AND   pbl.pfc_cur_conv_rejection_code IS  NULL   ;

        l_rows_inserted := SQL%ROWCOUNT;
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='No of rows inserted = '||l_rows_inserted;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;

    END IF;

    IF p_source ='PL-SQL' THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Selectiong from PL-SQL ';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;

        FORALL i IN p_resource_assignment_id_tbl.FIRST..p_resource_assignment_id_tbl.LAST
            INSERT INTO PJI_FM_EXTR_PLAN_LINES
             ( PROJECT_ID
             ,PROJECT_ORG_ID
             ,PROJECT_ELEMENT_ID
             ,STRUCT_VER_ID
             ,PERIOD_NAME
             ,CALENDAR_TYPE
             ,START_DATE
             ,END_DATE
             ,RBS_ELEMENT_ID
             ,RBS_VERSION_ID
             ,PLAN_VERSION_ID
             ,PLAN_TYPE_ID
             ,WP_VERSION_FLAG
             ,ROLLUP_TYPE
             ,TXN_CURRENCY_CODE
             ,TXN_RAW_COST
             ,TXN_BURDENED_COST
             ,TXN_REVENUE
             ,PRJ_CURRENCY_CODE
             ,PRJ_RAW_COST
             ,PRJ_BURDENED_COST
             ,PRJ_REVENUE
             ,PFC_CURRENCY_CODE
             ,PFC_RAW_COST
             ,PFC_BURDENED_COST
             ,PFC_REVENUE
             ,QUANTITY
             ,RESOURCE_CLASS_CODE
             ,RATE_BASED_FLAG)
             SELECT
                  p.project_id
                 ,p.org_id
                 ,p_task_id_tbl(i)
                 ,decode(pbv.wp_version_flag,'Y',pbv.project_structure_version_id,l_fin_structure_ver_id)
                 ,p_period_name_tbl(i)
                 ,nvl(pfo.cost_time_phased_code,nvl(revenue_time_phased_code,all_time_phased_code))
                 ,p_start_date_tbl(i)
                 ,p_end_date_tbl(i)
                 ,p_rbs_element_id_tbl(i)
                 ,pfo.rbs_version_id
                 ,pbv.budget_version_id
                 ,pfo.fin_plan_type_id
                 ,pbv.wp_version_flag
                 ,'W'
                 ,p_txn_currency_code_tbl(i)
                 ,p_txn_raw_cost_tbl(i)
                 ,p_txn_burdened_cost_tbl(i)
                 ,p_txn_revenue_tbl(i)
                 ,p.project_currency_code
                 ,p_project_raw_cost_tbl(i)
                 ,p_project_burdened_cost_tbl(i)
                 ,p_project_revenue_tbl(i)
                 ,p.projfunc_currency_code
                 ,p_raw_cost_tbl(i)
                 ,p_burdened_cost_tbl(i)
                 ,p_revenue_tbl(i)
                 ,p_quantity_tbl(i)
                 ,p_res_class_code_tbl(i)
                 ,p_rate_based_flag_tbl(i)
             FROM pa_projects_all p,
                  pa_proj_fp_options pfo,
                  pa_budget_versions pbv
             WHERE p.project_id=pbv.project_id
             AND   pbv.budget_version_id=p_budget_version_id
             AND   pfo.fin_plan_version_id=p_budget_version_id
             AND   p_cost_rejection_code_tbl(i)  IS NULL
             AND   p_revenue_rejection_code_tbl(i)  IS NULL
             AND   p_burden_rejection_code_tbl(i)  IS NULL
             AND   p_other_rejection_code(i)  IS NULL
             AND   p_pc_cur_conv_rej_code_tbl(i)  IS NULL
             AND   p_pfc_cur_conv_rej_code_tbl(i)  IS NULL ;

        l_rows_inserted := SQL%ROWCOUNT;
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='No of rows inserted = '||l_rows_inserted;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;

    END IF;

    IF p_source = 'REFRESH_WP_SETTINGS' THEN  --Bug 5073350. Changed the source from POPULATE_PJI_TABLE to REFRESH_WP_SETTINGS.

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='In If p_source = POPULATE_PJI_TAB  ';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            pa_debug.g_err_stage:='p_budget_version is  ' || p_budget_version_id;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;

            INSERT INTO PJI_FM_EXTR_PLAN_LINES
             ( PROJECT_ID
             ,PROJECT_ORG_ID
             ,PROJECT_ELEMENT_ID
             ,STRUCT_VER_ID
             ,PERIOD_NAME
             ,CALENDAR_TYPE
             ,START_DATE
             ,END_DATE
             ,RBS_ELEMENT_ID
             ,RBS_VERSION_ID
             ,PLAN_VERSION_ID
             ,PLAN_TYPE_ID
             ,WP_VERSION_FLAG
             ,ROLLUP_TYPE
             ,TXN_CURRENCY_CODE
             ,TXN_RAW_COST
             ,TXN_BURDENED_COST
             ,TXN_REVENUE
             ,PRJ_CURRENCY_CODE
             ,PRJ_RAW_COST
             ,PRJ_BURDENED_COST
             ,PRJ_REVENUE
             ,PFC_CURRENCY_CODE
             ,PFC_RAW_COST
             ,PFC_BURDENED_COST
             ,PFC_REVENUE
             ,QUANTITY
             ,RESOURCE_CLASS_CODE
             ,RATE_BASED_FLAG)
             SELECT
                  p.project_id
                 ,p.org_id
                 ,pra.task_id
                 ,decode(pbv.wp_version_flag,'Y',pbv.project_structure_version_id,l_fin_structure_ver_id)
                 ,pbl.period_name
                 ,nvl(pfo.cost_time_phased_code,nvl(revenue_time_phased_code,all_time_phased_code))
                 ,pbl.start_date
                 ,pbl.end_date
                 ,pra.rbs_element_id
                 ,pfo.rbs_version_id
                 ,pbv.budget_version_id
                 ,pfo.fin_plan_type_id
                 ,pbv.wp_version_flag
                 ,'W'
                 ,pbl.txn_currency_code
                 ,pbl.txn_raw_cost * p_qty_sign
                 ,pbl.txn_burdened_cost * p_qty_sign
                 ,pbl.txn_revenue * p_qty_sign
                 ,p.project_currency_code
                 ,pbl.project_raw_cost * p_qty_sign
                 ,pbl.project_burdened_cost * p_qty_sign
                 ,pbl.project_revenue * p_qty_sign
                 ,p.projfunc_currency_code
                 ,pbl.raw_cost * p_qty_sign
                 ,pbl.burdened_cost * p_qty_sign
                 ,pbl.revenue * p_qty_sign
                 ,pbl.quantity * p_qty_sign
                 ,pra.resource_class_code
                 ,pra.rate_based_flag
             FROM pa_projects_all p,
                  pa_proj_fp_options pfo,
                  pa_budget_versions pbv,
                  pa_budget_lines pbl,
                  pa_resource_assignments pra
             WHERE p.project_id=pbv.project_id
             AND   pbv.budget_version_id=p_budget_version_id
             AND   pfo.fin_plan_version_id=p_budget_version_id
             AND   pbl.resource_assignment_id= pra.resource_assignment_id
             AND   pbv.budget_version_id= pra.budget_version_id
             AND   pbl.cost_rejection_code     IS NULL
             AND   pbl.revenue_rejection_code  IS NULL
             AND   pbl.burden_rejection_code   IS NULL
             AND   pbl.other_rejection_code    IS NULL
             AND   pbl.pc_cur_conv_rejection_code       IS NULL
             AND   pbl.pfc_cur_conv_rejection_code      IS NULL ;

        l_rows_inserted :=  SQL%ROWCOUNT;

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='No of rows inserted = '||l_rows_inserted;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
        END IF;

    END IF;

    IF nvl(l_rows_inserted,0) >0 THEN

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:='Calling the PJI  API';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
            pa_debug.write('xxxxxxx','x_return_status before plan update '||x_return_status,5);

         END IF;

         /*Bug 5073350. Commented out this IF condition as the plan_update api
          has to be called for each plan version.*/
        --IF p_source <> 'POPULATE_PJI_TABLE' THEN

            PJI_FM_XBS_ACCUM_MAINT.PLAN_UPDATE
            (p_plan_version_id =>  p_budget_version_id   -- Added for bug 4218331
            ,x_msg_code      =>l_msg_code
            ,x_return_status  =>x_return_status);

           IF l_debug_mode = 'Y' THEN
            pa_debug.write('xxxxxxx','x_return_status from plan update '||x_return_status,5);
           END IF;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:='Called API PJI_FM_XBS_ACCUM_MAINT.PLAN_UPDATE returned error';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage, 5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            END IF;
       -- END IF;

    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:='Leaving call_update_rep_lines_api';
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
                x_msg_data := l_data;
                x_msg_count := l_msg_count;
             ELSE
                x_msg_count := l_msg_count;
             END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
      IF l_debug_mode = 'Y' THEN
           pa_debug.reset_curr_function;
      END IF;
     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_PLANNING_TRANSACTION_UTILS'
                                  ,p_procedure_name  => 'call_update_rep_lines_api');

           IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write( l_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_curr_function;
          END IF;
          RAISE;

END call_update_rep_lines_api;

END PA_PLANNING_TRANSACTION_UTILS;

/
