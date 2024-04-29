--------------------------------------------------------
--  DDL for Package Body PA_FP_GEN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_GEN_PUB" as
/* $Header: PAFPGNPB.pls 120.6.12010000.2 2009/06/25 11:01:43 rthumma ship $ */
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE UPDATE_RES_DEFAULTS
       (P_PROJECT_ID                     IN            pa_projects_all.PROJECT_ID%TYPE,
        P_BUDGET_VERSION_ID 	         IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
        P_CALLED_MODE                    IN            VARCHAR2,
        P_COMMIT_FLAG                    IN            VARCHAR2,
        P_INIT_MSG_FLAG                  IN            VARCHAR2,
        X_RETURN_STATUS                  OUT  NOCOPY   VARCHAR2,
        X_MSG_COUNT                      OUT  NOCOPY   NUMBER,
        X_MSG_DATA	                 OUT  NOCOPY   VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_PUB.UPDATE_RES_DEFAULTS';

l_last_updated_by           NUMBER := FND_GLOBAL.user_id;
l_last_update_login         NUMBER := FND_GLOBAL.login_id;
l_sysdate                   DATE   := SYSDATE;
l_ret_status                VARCHAR2(100);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_data                      VARCHAR2(2000);
l_msg_index_out             NUMBER:=0;

--Bug 4895793 : Local Variables for calling get_resource_defaults API with DISTINCT rlm_ids.
l_resource_list_members_tab             SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
l_resource_class_flag_tab               SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
l_resource_class_code_tab               SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_resource_class_id_tab                 SYSTEM.PA_NUM_TBL_TYPE;
l_res_type_code_tab                     SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_person_id_tab                         SYSTEM.PA_NUM_TBL_TYPE;
l_job_id_tab                            SYSTEM.PA_NUM_TBL_TYPE;
l_person_type_code_tab                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_named_role_tab                        SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
l_bom_resource_id_tab                   SYSTEM.PA_NUM_TBL_TYPE;
l_non_labor_resource_tab                SYSTEM.PA_VARCHAR2_20_TBL_TYPE;
l_inventory_item_id_tab                 SYSTEM.PA_NUM_TBL_TYPE;
l_item_category_id_tab                  SYSTEM.PA_NUM_TBL_TYPE;
l_project_role_id_tab                   SYSTEM.PA_NUM_TBL_TYPE;
l_organization_id_tab                   SYSTEM.PA_NUM_TBL_TYPE;
l_fc_res_type_code_tab                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_expenditure_type_tab                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_expenditure_category_tab              SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_event_type_tab                        SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_revenue_category_code_tab             SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_supplier_id_tab                       SYSTEM.PA_NUM_TBL_TYPE;
l_spread_curve_id_tab                   SYSTEM.PA_NUM_TBL_TYPE;
l_etc_method_code_tab                   SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_mfc_cost_type_id_tab                  SYSTEM.PA_NUM_TBL_TYPE;
l_incurred_by_res_flag_tab              SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
l_incur_by_res_cls_code_tab             SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_incur_by_role_id_tab                  SYSTEM.PA_NUM_TBL_TYPE;
l_unit_of_measure_tab                   SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_org_id_tab                            SYSTEM.PA_NUM_TBL_TYPE;
l_rate_based_flag_tab                   SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
l_rate_expenditure_type_tab             SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_rate_func_curr_code_tab               SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
--l_rat_incured_by_org_id_tab           SYSTEM.PA_NUM_TBL_TYPE;
l_incur_by_res_type_tab                 SYSTEM.PA_VARCHAR2_30_TBL_TYPE;

-- Maps rlm_ids to indexes for l_resource_list_members_tab
l_rlmid_index_map                          PA_PLSQL_DATATYPES.IdTabTyp;
l_index                                    NUMBER;
l_dummy                                    NUMBER;

--Local Variables for storing default attribute to be used in UPDATE.
l_da_ra_id_tab                             PA_PLSQL_DATATYPES.IdTabTyp; -- NEW
l_da_resource_list_members_tab             PA_PLSQL_DATATYPES.IdTabTyp;
l_da_resource_class_flag_tab	           PA_PLSQL_DATATYPES.Char1TabTyp;
l_da_resource_class_code_tab	           PA_PLSQL_DATATYPES.Char30TabTyp;
l_da_resource_class_id_tab		   PA_PLSQL_DATATYPES.IdTabTyp;
l_da_res_type_code_tab		           PA_PLSQL_DATATYPES.Char30TabTyp;
l_da_person_id_tab			   PA_PLSQL_DATATYPES.IdTabTyp;
l_da_job_id_tab				   PA_PLSQL_DATATYPES.IdTabTyp;
l_da_person_type_code_tab		   PA_PLSQL_DATATYPES.Char30TabTyp;
l_da_named_role_tab			   PA_PLSQL_DATATYPES.Char80TabTyp;
l_da_bom_resource_id_tab		   PA_PLSQL_DATATYPES.IdTabTyp;
l_da_non_labor_resource_tab		   PA_PLSQL_DATATYPES.Char20TabTyp;
l_da_inventory_item_id_tab		   PA_PLSQL_DATATYPES.IdTabTyp;
l_da_item_category_id_tab		   PA_PLSQL_DATATYPES.IdTabTyp;
l_da_project_role_id_tab		   PA_PLSQL_DATATYPES.IdTabTyp;
l_da_organization_id_tab		   PA_PLSQL_DATATYPES.IdTabTyp;
l_da_fc_res_type_code_tab		   PA_PLSQL_DATATYPES.Char30TabTyp;
l_da_expenditure_type_tab		   PA_PLSQL_DATATYPES.Char30TabTyp;
l_da_expenditure_category_tab	           PA_PLSQL_DATATYPES.Char30TabTyp;
l_da_event_type_tab			   PA_PLSQL_DATATYPES.Char30TabTyp;
l_da_revenue_category_code_tab	           PA_PLSQL_DATATYPES.Char30TabTyp;
l_da_supplier_id_tab			   PA_PLSQL_DATATYPES.IdTabTyp;
l_da_spread_curve_id_tab		   PA_PLSQL_DATATYPES.IdTabTyp;
l_da_etc_method_code_tab		   PA_PLSQL_DATATYPES.Char30TabTyp;
l_da_mfc_cost_type_id_tab		   PA_PLSQL_DATATYPES.IdTabTyp;
l_da_incurred_by_res_flag_tab	           PA_PLSQL_DATATYPES.Char1TabTyp;
l_da_incur_by_res_cls_code_tab	           PA_PLSQL_DATATYPES.Char30TabTyp;
l_da_incur_by_role_id_tab		   PA_PLSQL_DATATYPES.IdTabTyp;
l_da_unit_of_measure_tab		   PA_PLSQL_DATATYPES.Char30TabTyp;
l_da_org_id_tab				   PA_PLSQL_DATATYPES.IdTabTyp;
l_da_rate_based_flag_tab		   PA_PLSQL_DATATYPES.Char1TabTyp;
l_da_rate_expenditure_type_tab	           PA_PLSQL_DATATYPES.Char30TabTyp;
l_da_rate_func_curr_code_tab	           PA_PLSQL_DATATYPES.Char30TabTyp;
--l_da_rat_incured_by_org_id_tab	           PA_PLSQL_DATATYPES.IdTabTyp;
l_da_incur_by_res_type_tab		   PA_PLSQL_DATATYPES.Char30TabTyp;

l_fp_cols_rec                  PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
l_etc_start_date               DATE;
BEGIN
  --Setting initial values
  IF p_init_msg_flag = 'Y' THEN
       FND_MSG_PUB.initialize;
  END IF;

  X_MSG_COUNT := 0;
  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

   IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
      PA_DEBUG.init_err_stack('PA_FP_GEN_PUB.UPDATE_RES_DEFAULTS');
   ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            pa_debug.set_curr_function( p_function     => 'UPDATE_RES_DEFAULTS'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
   END IF;

   -- 1. Bug 4895793: Get all target resources and their rlm_ids.
   SELECT  resource_assignment_id,
           resource_list_member_id
   BULK    COLLECT
   INTO    l_da_ra_id_tab,
           l_da_resource_list_members_tab
   FROM    pa_resource_assignments
   WHERE   budget_version_id = p_budget_version_id;

   IF l_da_resource_list_members_tab.count = 0 then
       IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
           PA_DEBUG.reset_err_stack;
       ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
           PA_DEBUG.Reset_Curr_Function;
       END IF;
       RETURN;
   END IF;

   -- 2. Bug 4895793: Find the distinct rlm_ids from l_da_resource_list_members_tab
   -- and store them in l_resource_list_members_tab. The l_rlmid_index_map
   -- table stores (rlm_id, l_resource_list_members_tab index value) pairs.
   -- The l_rlmid_index_map is used to determine if rlm_ids are distinct.

   FOR i IN 1..l_da_resource_list_members_tab.count LOOP
      -- If the current rlm_id is distinct, then add it to the
      -- l_rlmid_index_map and l_resource_list_members_tab tables.
      IF NOT l_rlmid_index_map.EXISTS(l_da_resource_list_members_tab(i)) THEN
         l_rlmid_index_map(l_da_resource_list_members_tab(i)) :=
             l_resource_list_members_tab.count + 1;
         l_resource_list_members_tab.EXTEND;
         l_resource_list_members_tab(l_resource_list_members_tab.count) :=
            l_da_resource_list_members_tab(i);
      END IF;
   END LOOP;

    -- 3. Bug 4895793: Get default attribute values for the distinct rlm_ids and store
    --    them in the pl/sql tables prefixed by "l_" instead of by "l_da_".

    --Calling resource defualt API
          IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                   (p_msg         => 'Before calling
                    pa_planning_resource_utils.get_resource_defaults',
                    p_module_name => l_module_name,
                    p_log_level   => 5);
         END IF;

    -- dbms_output.put_line('Value of x_msg_count, before calling get_res_def api: '||x_msg_count);
     PA_PLANNING_RESOURCE_UTILS.get_resource_defaults (
     P_resource_list_members      => l_resource_list_members_tab,
     P_project_id		  => p_project_id,
     X_resource_class_flag	  => l_resource_class_flag_tab,
     X_resource_class_code	  => l_resource_class_code_tab,
     X_resource_class_id	  => l_resource_class_id_tab,
     X_res_type_code		  => l_res_type_code_tab,
     X_incur_by_res_type          => l_incur_by_res_type_tab,
     X_person_id	          => l_person_id_tab,
     X_job_id			  => l_job_id_tab,
     X_person_type_code	          => l_person_type_code_tab,
     X_named_role		  => l_named_role_tab,
     X_bom_resource_id		  => l_bom_resource_id_tab,
     X_non_labor_resource         => l_non_labor_resource_tab,
     X_inventory_item_id	  => l_inventory_item_id_tab,
     X_item_category_id	          => l_item_category_id_tab,
     X_project_role_id		  => l_project_role_id_tab,
     X_organization_id		  => l_organization_id_tab,
     X_fc_res_type_code	          => l_fc_res_type_code_tab,
     X_expenditure_type	          => l_expenditure_type_tab,
     X_expenditure_category	  => l_expenditure_category_tab,
     X_event_type		  => l_event_type_tab,
     X_revenue_category_code	  => l_revenue_category_code_tab,
     X_supplier_id		  => l_supplier_id_tab,
     X_spread_curve_id		  => l_spread_curve_id_tab,
     X_etc_method_code		  => l_etc_method_code_tab,
     X_mfc_cost_type_id	          => l_mfc_cost_type_id_tab,
     X_incurred_by_res_flag	  => l_incurred_by_res_flag_tab,
     X_incur_by_res_class_code    => l_incur_by_res_cls_code_tab,
     X_incur_by_role_id	          => l_incur_by_role_id_tab,
     X_unit_of_measure		  => l_unit_of_measure_tab,
     X_org_id			  => l_org_id_tab,
     X_rate_based_flag		  => l_rate_based_flag_tab,
     X_rate_expenditure_type	  => l_rate_expenditure_type_tab,
     X_rate_func_curr_code	  => l_rate_func_curr_code_tab,
     --X_rate_incurred_by_org_id    => l_rat_incured_by_org_id_tab,
     X_msg_data			  => X_MSG_DATA,
     X_msg_count	          => X_MSG_COUNT,
     X_return_status		  => X_RETURN_STATUS);
     --dbms_output.put_line('Value of x_msg_count, after calling get_res_def api: '||x_msg_count);


     IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;
     IF p_pa_debug_mode = 'Y' THEN
          pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Status after calling
                 pa_planning_resource_utils.get_resource_defaults'
                                          ||x_return_status,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
       END IF;

    -- 4. Bug 4895793: Populate the "l_" default attribute value tables to be used by the
    --    UPDATE statement. The l_rlmid_index_map takes an rlm_id value and
    --    returns the index for that rlm_id's default attributes in the "l_da_"
    --    tables.

    FOR i IN 1..l_da_ra_id_tab.count LOOP
        IF NOT l_rlmid_index_map.EXISTS(l_da_resource_list_members_tab(i)) THEN
            -- Error handling code goes here. This should never happen.
            l_dummy := 1;
        END IF;

        l_index := l_rlmid_index_map(l_da_resource_list_members_tab(i));

l_da_resource_class_flag_tab(i) := l_resource_class_flag_tab(l_index);
l_da_resource_class_code_tab(i) := l_resource_class_code_tab(l_index);
l_da_resource_class_id_tab(i) := l_resource_class_id_tab(l_index);
l_da_res_type_code_tab(i) := l_res_type_code_tab(l_index);
l_da_person_id_tab(i) := l_person_id_tab(l_index);
l_da_job_id_tab(i) := l_job_id_tab(l_index);
l_da_person_type_code_tab(i) := l_person_type_code_tab(l_index);
l_da_named_role_tab(i) := l_named_role_tab(l_index);
l_da_bom_resource_id_tab(i) := l_bom_resource_id_tab(l_index);
l_da_non_labor_resource_tab(i) := l_non_labor_resource_tab(l_index);
l_da_inventory_item_id_tab(i) := l_inventory_item_id_tab(l_index);
l_da_item_category_id_tab(i) := l_item_category_id_tab(l_index);
l_da_project_role_id_tab(i) := l_project_role_id_tab(l_index);
l_da_organization_id_tab(i) := l_organization_id_tab(l_index);
l_da_fc_res_type_code_tab(i) := l_fc_res_type_code_tab(l_index);
l_da_expenditure_type_tab(i) := l_expenditure_type_tab(l_index);
l_da_expenditure_category_tab(i) := l_expenditure_category_tab(l_index);
l_da_event_type_tab(i) := l_event_type_tab(l_index);
l_da_revenue_category_code_tab(i) := l_revenue_category_code_tab(l_index);
l_da_supplier_id_tab(i) := l_supplier_id_tab(l_index);
l_da_spread_curve_id_tab(i) := l_spread_curve_id_tab(l_index);
l_da_etc_method_code_tab(i) := l_etc_method_code_tab(l_index);
l_da_mfc_cost_type_id_tab(i) := l_mfc_cost_type_id_tab(l_index);
l_da_incurred_by_res_flag_tab(i) := l_incurred_by_res_flag_tab(l_index);
l_da_incur_by_res_cls_code_tab(i) := l_incur_by_res_cls_code_tab(l_index);
l_da_incur_by_role_id_tab(i) := l_incur_by_role_id_tab(l_index);
l_da_unit_of_measure_tab(i) := l_unit_of_measure_tab(l_index);
l_da_org_id_tab(i) := l_org_id_tab(l_index);
l_da_rate_based_flag_tab(i) := l_rate_based_flag_tab(l_index);
l_da_rate_expenditure_type_tab(i) := l_rate_expenditure_type_tab(l_index);
l_da_rate_func_curr_code_tab(i) := l_rate_func_curr_code_tab(l_index);
--l_da_rat_incured_by_org_id_tab(i) := l_rat_incured_by_org_id_tab(l_index);
l_da_incur_by_res_type_tab(i) := l_incur_by_res_type_tab(l_index);

   END LOOP;


     -- Bug 4143869: Added call to GET_PLAN_VERSION_DTLS to get the value of the
     -- Retain Maually Added Lines flag. Also, added manual lines logic to the
     -- UPDATE statement for pa_resource_assignments.

    IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
             P_CALLED_MODE           => P_CALLED_MODE,
             P_MSG                   => 'Before calling PA_FP_GEN_AMOUNT_UTILS.'||
                                        'GET_PLAN_VERSION_DTL',
             P_MODULE_NAME           => l_module_name);
     END IF;
     PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS(
             P_PROJECT_ID            => p_project_id,
             P_BUDGET_VERSION_ID     => p_budget_version_id,
             X_FP_COLS_REC           => l_fp_cols_rec,
             X_RETURN_STATUS         => x_return_status,
             X_MSG_COUNT             => x_msg_count,
             X_MSG_DATA              => x_msg_data);
     IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
             P_CALLED_MODE           => P_CALLED_MODE,
             P_MSG                   => 'After calling PA_FP_GEN_AMOUNT_UTILS.'||
                                        'GET_PLAN_VERSION_DTL:'||x_return_status,
             P_MODULE_NAME           => l_module_name);
     END IF;
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

      /* 5. Bug 4895793 : Update resource attributes by resource_assignment_id
        instead of by (budget_version_id, resource_list_member_id).*/

     -- IPM: At the time of resource creation, the resource_rate_based_flag
     -- should be set based on the default rate_based_flag for the resource.
     -- Modified the Update statements below to set resource_rate_based_flag.
     -- Note that this API is used exclusively by the Forecast Generation
     -- process and is called by CREATE_RES_ASG in PAFPCAPB.pls.

     IF l_fp_cols_rec.X_GEN_RET_MANUAL_LINE_FLAG = 'N' THEN
         FORALL i IN 1 .. l_da_ra_id_tab.count --l_da_resource_list_members_tab.count Bug 4895793
            UPDATE PA_RESOURCE_ASSIGNMENTS RA
            SET    RESOURCE_CLASS_FLAG         = l_da_resource_class_flag_tab(i),
                   RESOURCE_CLASS_CODE         = l_da_resource_class_code_tab(i),
                   RES_TYPE_CODE               = l_da_res_type_code_tab(i),
                   PERSON_ID                   = l_da_person_id_tab(i),
                   JOB_ID                      = l_da_job_id_tab(i),
                   PERSON_TYPE_CODE            = l_da_person_type_code_tab(i),
                   NAMED_ROLE                  = l_da_named_role_tab(i),
                   BOM_RESOURCE_ID             = l_da_bom_resource_id_tab(i),
                   NON_LABOR_RESOURCE          = l_da_non_labor_resource_tab(i),
                   INVENTORY_ITEM_ID           = l_da_inventory_item_id_tab(i),
                   ITEM_CATEGORY_ID            = l_da_item_category_id_tab(i),
                   PROJECT_ROLE_ID             = l_da_project_role_id_tab(i),
                   ORGANIZATION_ID             = l_da_organization_id_tab(i),
                   FC_RES_TYPE_CODE            = l_da_fc_res_type_code_tab(i),
                   EXPENDITURE_TYPE            = l_da_expenditure_type_tab(i),
                   EXPENDITURE_CATEGORY        = l_da_expenditure_category_tab(i),
                   EVENT_TYPE                  = l_da_event_type_tab(i),
                   REVENUE_CATEGORY_CODE       = l_da_revenue_category_code_tab(i),
                   SUPPLIER_ID                 = l_da_supplier_id_tab(i),
                   SPREAD_CURVE_ID             = l_da_spread_curve_id_tab(i),
                   ETC_METHOD_CODE             = l_da_etc_method_code_tab(i),
                   MFC_COST_TYPE_ID            = l_da_mfc_cost_type_id_tab(i),
                   INCURRED_BY_RES_FLAG        = l_da_incurred_by_res_flag_tab(i),
                   INCUR_BY_RES_CLASS_CODE     = l_da_incur_by_res_cls_code_tab(i),
                   INCUR_BY_ROLE_ID            = l_da_incur_by_role_id_tab(i),
                   UNIT_OF_MEASURE             = l_da_unit_of_measure_tab(i),
                   RATE_BASED_FLAG             = l_da_rate_based_flag_tab(i),
                   RESOURCE_RATE_BASED_FLAG    = l_da_rate_based_flag_tab(i), -- Added for IPM ER
                   RATE_EXPENDITURE_TYPE       = l_da_rate_expenditure_type_tab(i),
                   RATE_EXP_FUNC_CURR_CODE     = l_da_rate_func_curr_code_tab(i),
                   --RATE_INCURRED_BY_ORGANZ_ID  = l_da_rat_incured_by_org_id_tab(i),
                   LAST_UPDATE_DATE            = l_sysdate,
                   LAST_UPDATED_BY             = l_last_updated_by,
                   CREATION_DATE               = l_sysdate,
                   CREATED_BY                  = l_last_updated_by,
                   LAST_UPDATE_LOGIN           = l_last_update_login,
                   PROJECT_ASSIGNMENT_ID       = -1,
                   RATE_EXPENDITURE_ORG_ID     = l_da_org_id_tab(i)
            WHERE  resource_assignment_id      = l_da_ra_id_tab(i);
            --budget_version_id           = p_budget_version_id
            --AND    RESOURCE_LIST_MEMBER_ID     = l_da_resource_list_members_tab(i);
     ELSIF l_fp_cols_rec.X_GEN_RET_MANUAL_LINE_FLAG = 'Y' THEN
         IF l_fp_cols_rec.x_plan_class_code = 'FORECAST' THEN
             l_etc_start_date :=
                 PA_FP_GEN_AMOUNT_UTILS.GET_ETC_START_DATE(p_budget_version_id);
         END IF;
         FORALL i IN 1 .. l_da_ra_id_tab.count --l_da_resource_list_members_tab.count Bug 4895793.
            UPDATE PA_RESOURCE_ASSIGNMENTS RA
            SET    RESOURCE_CLASS_FLAG         = l_da_resource_class_flag_tab(i),
                   RESOURCE_CLASS_CODE         = l_da_resource_class_code_tab(i),
                   RES_TYPE_CODE               = l_da_res_type_code_tab(i),
                   PERSON_ID                   = l_da_person_id_tab(i),
                   JOB_ID                      = l_da_job_id_tab(i),
                   PERSON_TYPE_CODE            = l_da_person_type_code_tab(i),
                   NAMED_ROLE                  = l_da_named_role_tab(i),
                   BOM_RESOURCE_ID             = l_da_bom_resource_id_tab(i),
                   NON_LABOR_RESOURCE          = l_da_non_labor_resource_tab(i),
                   INVENTORY_ITEM_ID           = l_da_inventory_item_id_tab(i),
                   ITEM_CATEGORY_ID            = l_da_item_category_id_tab(i),
                   PROJECT_ROLE_ID             = l_da_project_role_id_tab(i),
                   ORGANIZATION_ID             = l_da_organization_id_tab(i),
                   FC_RES_TYPE_CODE            = l_da_fc_res_type_code_tab(i),
                   EXPENDITURE_TYPE            = l_da_expenditure_type_tab(i),
                   EXPENDITURE_CATEGORY        = l_da_expenditure_category_tab(i),
                   EVENT_TYPE                  = l_da_event_type_tab(i),
                   REVENUE_CATEGORY_CODE       = l_da_revenue_category_code_tab(i),
                   SUPPLIER_ID                 = l_da_supplier_id_tab(i),
                   SPREAD_CURVE_ID             = l_da_spread_curve_id_tab(i),
                   ETC_METHOD_CODE             = l_da_etc_method_code_tab(i),
                   MFC_COST_TYPE_ID            = l_da_mfc_cost_type_id_tab(i),
                   INCURRED_BY_RES_FLAG        = l_da_incurred_by_res_flag_tab(i),
                   INCUR_BY_RES_CLASS_CODE     = l_da_incur_by_res_cls_code_tab(i),
                   INCUR_BY_ROLE_ID            = l_da_incur_by_role_id_tab(i),
                   UNIT_OF_MEASURE             = l_da_unit_of_measure_tab(i),
                   RATE_BASED_FLAG             = l_da_rate_based_flag_tab(i),
                   RESOURCE_RATE_BASED_FLAG    = l_da_rate_based_flag_tab(i), -- Added for IPM ER
                   RATE_EXPENDITURE_TYPE       = l_da_rate_expenditure_type_tab(i),
                   RATE_EXP_FUNC_CURR_CODE     = l_da_rate_func_curr_code_tab(i),
                   --RATE_INCURRED_BY_ORGANZ_ID  = l_da_rat_incured_by_org_id_tab(i),
                   LAST_UPDATE_DATE            = l_sysdate,
                   LAST_UPDATED_BY             = l_last_updated_by,
                   CREATION_DATE               = l_sysdate,
                   CREATED_BY                  = l_last_updated_by,
                   LAST_UPDATE_LOGIN           = l_last_update_login,
                   PROJECT_ASSIGNMENT_ID       = -1,
                   RATE_EXPENDITURE_ORG_ID     = l_da_org_id_tab(i)
            WHERE  resource_assignment_id      = l_da_ra_id_tab(i)
            --budget_version_id           = p_budget_version_id
            --AND    RESOURCE_LIST_MEMBER_ID     = l_da_resource_list_members_tab(i)
            AND    ( ra.transaction_source_code IS NOT NULL
                     OR ( ra.transaction_source_code IS NULL
                          AND NOT EXISTS ( SELECT 1
                                           FROM   pa_budget_lines bl
                                           WHERE  bl.resource_assignment_id =
                                                  ra.resource_assignment_id
                                           AND    bl.start_date >=
                                                  DECODE(l_fp_cols_rec.x_plan_class_code,
                                                         'FORECAST', l_etc_start_date,
                                                         bl.start_date)
                                           AND    rownum = 1 )));
     END IF;

  IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
      PA_DEBUG.reset_err_stack;
  ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
      PA_DEBUG.Reset_Curr_Function;
  END IF;
  RETURN;

 EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
      /* MRC Elimination changes: PA_MRC_FINPLAN.G_CALLING_MODULE := Null; **/
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
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
          PA_DEBUG.reset_err_stack;
      ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
          PA_DEBUG.Reset_Curr_Function;
      END IF;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
      -- dbms_output.put_line('inside excep create res asg');
      -- dbms_output.put_line(SUBSTR(SQLERRM,1,240));
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_PUB'
              ,p_procedure_name => 'UPDATE_RES_DEFAULTS');

     IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
         PA_DEBUG.reset_err_stack;
     ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPDATE_RES_DEFAULTS;

PROCEDURE INCLUDE_CHANGE_DOCUMENT_WRP
          (P_FP_COLS_REC                    IN              PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           X_RETURN_STATUS                  OUT   NOCOPY    VARCHAR2,
           X_MSG_COUNT                      OUT   NOCOPY    NUMBER,
           X_MSG_DATA	                    OUT   NOCOPY    VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_PUB.INCLUDE_CHANGE_DOCUMENT_WRP';

 l_ci_id_tbl                    SYSTEM.pa_num_tbl_type:=SYSTEM.PA_NUM_TBL_TYPE();
 l_translated_msgs_tbl          SYSTEM.pa_varchar2_2000_tbl_type;
 l_translated_err_msg_count     NUMBER;
 l_translated_err_msg_level_tbl SYSTEM.pa_varchar2_30_tbl_type;
 l_budget_version_id_tbl        SYSTEM.pa_num_tbl_type:=SYSTEM.PA_NUM_TBL_TYPE();
 l_impl_cost_flag_tbl           SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
 l_impl_rev_flag_tbl            SYSTEM.pa_varchar2_1_tbl_type:=SYSTEM.pa_varchar2_1_tbl_type();
 l_msg_count number(15);
 l_msg_index_out number(15);
 l_msg_data varchar2(1000);
 l_data varchar2(1000);
 l_calling_context  varchar2(30);

 l_raTxn_rollup_api_call_flag      VARCHAR2(1) := 'N'; -- Added for IPM new entity ER
BEGIN
    --hr_utility.trace_on(null,'Sharmila');
  /* Setting initial values */
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'INCLUDE_CHANGE_DOCUMENT_WRP'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    -- Bug 5845142
    IF Pa_Fp_Control_Items_Utils.check_valid_combo
      ( p_project_id         => p_fp_cols_rec.x_project_id
       ,p_targ_app_cost_flag => 'N'
       ,p_targ_app_rev_flag  => 'N') = 'N' THEN

      IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
      END IF;
      RETURN;

    END IF;

    -- Modified Select statement for adding distinct clause - Bug 3749556
    SELECT /* pfc.ci_type_name as cd_type
           ,pfc.cd_number as cd_number
           ,pfc.summary as summary
           ,pfc.task_no as task_no
           ,pfc.project_status_name as project_status_name
           ,pal.meaning as project_system_status
           ,pfc.people_effort as people_effort
           ,pfc.equipment_effort as equipment_effort
           ,PA_FP_CONTROL_ITEMS_UTILS.get_cost
            (CI_VERSION_TYPE,p_fp_cols_rec.x_budget_version_id,
             CI_VERSION_ID,RAW_COST,BURDENED_COST) as cost
           ,PA_FP_CONTROL_ITEMS_UTILS.get_revenue_partial
            (CI_VERSION_TYPE,p_fp_cols_rec.x_budget_version_id,
             CI_VERSION_ID,REVENUE) as revenue
           ,'0' as margin
           ,'0' as margin_percent */
            distinct pfc.ci_id as ci_id
           /* ,pci.ci_type_class_code as ci_type_class_code */
     BULK   COLLECT
     INTO   l_ci_id_tbl
     FROM   pa_fp_eligible_ci_v pfc,
            pa_lookups pal
--            ,pa_ci_types_vl pci
     WHERE  pfc.project_id = p_fp_cols_rec.x_project_id
     AND    pfc.fin_plan_type_id = p_fp_cols_rec.x_fin_plan_type_id
     AND    CI_VERSION_TYPE <> decode(p_fp_cols_rec.x_version_type,
                                      'COST','REVENUE',
                                      'REVENUE','COST',
                                      'ALL','-99')
     AND    decode (CI_VERSION_TYPE,
                    'ALL',PT_CT_VERSION_TYPE,
                    CI_VERSION_TYPE) = PT_CT_VERSION_TYPE
     AND    (pfc.REV_PARTIALLY_IMPL_FLAG='Y'
         OR (pfc.ci_version_type='ALL' AND
             decode(p_fp_cols_rec.x_version_type,'ALL',2,1) >
             (SELECT COUNT(*)
	      FROM   pa_fp_merged_ctrl_items merge
	      WHERE  merge.ci_plan_version_id = pfc.ci_version_id
	      AND    merge.plan_version_id = p_fp_cols_rec.x_budget_version_id))
         OR (pfc.ci_version_type <> 'ALL' AND
             NOT EXISTS (SELECT 'X'
                         FROM pa_fp_merged_ctrl_items merge
                         WHERE merge.ci_plan_version_id = pfc.ci_version_id
                         AND merge.plan_version_id = p_fp_cols_rec.x_budget_version_id
                         AND merge.version_type = pfc.ci_version_type)))
     AND  pfc.project_system_status_code = pal.lookup_code
     AND  pal.lookup_type = 'CONTROL_ITEM_SYSTEM_STATUS';
--     AND  pfc.ci_type_id = pci.ci_type_id;

     IF l_ci_id_tbl.count = 0 THEN
        IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
             (p_msg => 'No CIs to implement. no rows returned from the view.Returning',
              p_module_name => l_module_name,
              p_log_level   => 5);
        END IF;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
     END IF;
     l_budget_version_id_tbl.extend;
     l_budget_version_id_tbl(1) := P_FP_COLS_REC.X_BUDGET_VERSION_ID;

     IF  p_fp_cols_rec.x_plan_class_code = 'BUDGET' THEN
         l_calling_context := 'BUDGET_GENERATION';
     ELSIF p_fp_cols_rec.x_plan_class_code = 'FORECAST' THEN
         l_calling_context := 'FORECAST_GENERATION';
     END IF;

/* Added PA_FP_MULTI_CURRENCY_PKG.CONVERT_TXN_CURRENCY and PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION APIs
   to include change orders. Bug 3985706 */

     IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Before calling PA_FP_MULTI_CURRENCY_PKG.CONVERT_TXN_CURRENCY',
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;
    PA_FP_MULTI_CURRENCY_PKG.CONVERT_TXN_CURRENCY
                (p_budget_version_id          => P_FP_COLS_REC.X_BUDGET_VERSION_ID,
                 p_entire_version             => 'Y',
                 p_calling_module              => 'BUDGET_GENERATION', -- Added for Bug#5395732
                 X_RETURN_STATUS              => X_RETURN_STATUS,
                 X_MSG_COUNT                  => X_MSG_COUNT,
                 X_MSG_DATA                   => X_MSG_DATA);
    IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'After calling PA_FP_MULTI_CURRENCY_PKG.CONVERT_TXN_CURRENCY,
                            ret status: '||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;
    --dbms_output.put_line('After calling convert_txn_currency api: '||x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

   IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Before calling PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION',
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;
    PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION
               (p_budget_version_id          => P_FP_COLS_REC.X_BUDGET_VERSION_ID,
                p_entire_version             =>  'Y',
                X_RETURN_STATUS              => X_RETURN_STATUS,
                X_MSG_COUNT                  => X_MSG_COUNT,
                X_MSG_DATA                   => X_MSG_DATA);
    IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'After calling PA_FP_ROLLUP_PKG.ROLLUP_BUDGET_VERSION,
                            ret status: '||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;


     IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                               pa_fp_ci_merge.implement_change_document',
              p_module_name => l_module_name,
              p_log_level   => 5);
     END IF;
     PA_FP_CI_MERGE.implement_change_document
      (p_context                      =>
       'INCLUDE',
       p_calling_context              =>
       l_calling_context,
       p_ci_id_tbl                    =>
       l_ci_id_tbl,
       p_budget_version_id_tbl        =>
       l_budget_version_id_tbl,
       p_impl_cost_flag_tbl           =>
       l_impl_cost_flag_tbl,
       p_impl_rev_flag_tbl            =>
       l_impl_rev_flag_tbl,
       p_raTxn_rollup_api_call_flag   =>
       l_raTxn_rollup_api_call_flag,       --Added for IPM new entity ER
       x_translated_msgs_tbl          =>
       l_translated_msgs_tbl,
       x_translated_err_msg_count     =>
       l_translated_err_msg_count,
       x_translated_err_msg_level_tbl =>
       l_translated_err_msg_level_tbl,
       x_return_status                =>
       x_return_status,
       x_msg_count                    =>
       x_msg_count,
       x_msg_data                     =>
       x_msg_data);
     IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg => 'Status after calling pa_fp_ci_merge.implement_change_document'
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
     END IF;

     IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

     IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.Reset_Curr_Function;
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
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
      END IF;
    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_PUB'
              ,p_procedure_name => 'INCLUDE_CHANGE_DOCUMENT_WRP');
     IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END INCLUDE_CHANGE_DOCUMENT_WRP;

PROCEDURE UNSPENT_AMOUNT
          (P_BUDGET_VERSION_ID              IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_APP_COST_BDGT_VER_ID           IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC                    IN            PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_UNSPENT_AMT_PERIOD             IN            VARCHAR2,
           X_RETURN_STATUS                  OUT   NOCOPY  VARCHAR2,
           X_MSG_COUNT                      OUT   NOCOPY  NUMBER,
           X_MSG_DATA                       OUT   NOCOPY  VARCHAR2) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.PA_FP_GEN_PUB.UNSPENT_AMOUNT';

l_fp_cols_rec_app_cost         PA_FP_GEN_AMOUNT_UTILS.FP_COLS;

l_res_asg_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
l_task_id_tab                  PA_PLSQL_DATATYPES.IdTabTyp;
l_rate_based_flag_tab          PA_PLSQL_DATATYPES.Char1TabTyp;
l_res_list_mem_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
l_planning_start_date_tab      PA_PLSQL_DATATYPES.DateTabTyp;
l_planning_end_date_tab        PA_PLSQL_DATATYPES.DateTabTyp;

l_etc_start_date               PA_BUDGET_VERSIONS.ETC_START_DATE%TYPE;
l_time_phase                   PA_PROJ_FP_OPTIONS.COST_TIME_PHASED_CODE%TYPE;
l_start_date                   PA_BUDGET_LINES.START_DATE%TYPE;
l_end_date                     PA_BUDGET_LINES.END_DATE%TYPE;
l_period_name                  PA_BUDGET_LINES.PERIOD_NAME%TYPE;
l_pc_currency_code             PA_PROJECTS_ALL.PROJECT_CURRENCY_CODE%TYPE;
l_pfc_currency_code            PA_PROJECTS_ALL.PROJFUNC_CURRENCY_CODE%TYPE;

/* Plan amount pl/sql tables */
l_plan_ra_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
l_plan_txn_cur_code_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
l_plan_qty_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
l_plan_pc_raw_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;
l_plan_txn_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_plan_pc_burd_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_plan_txn_burd_cost_tab       PA_PLSQL_DATATYPES.NumTabTyp;

/* Actual amount pl/sql tables */
l_init_ra_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
l_init_txn_cur_code_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
l_init_qty_tab                 PA_PLSQL_DATATYPES.NumTabTyp;
l_init_pc_raw_cost_tab         PA_PLSQL_DATATYPES.NumTabTyp;
l_init_txn_raw_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_init_pc_burd_cost_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_init_txn_burd_cost_tab       PA_PLSQL_DATATYPES.NumTabTyp;

/* Indices for Plan and Actual pl/sql tables */
p_index                        NUMBER;
i_index                        NUMBER;
l_prev_i_index                 NUMBER;
l_actuals_exist_flag           VARCHAR2(1);

l_curr_ra_id                   PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE;

/* Scalar variables for summing Plan amounts per ra_id */
l_plan_qty                     PA_BUDGET_LINES.QUANTITY%TYPE;
l_plan_pc_raw_cost             PA_BUDGET_LINES.PROJECT_RAW_COST%TYPE;
l_plan_txn_raw_cost            PA_BUDGET_LINES.TXN_RAW_COST%TYPE;
l_plan_pc_burd_cost            PA_BUDGET_LINES.PROJECT_BURDENED_COST%TYPE;
l_plan_txn_burd_cost           PA_BUDGET_LINES.TXN_BURDENED_COST%TYPE;
l_plan_currency_tab            PA_PLSQL_DATATYPES.Char30TabTyp;

/* Scalar variables for summing Actual amounts per ra_id */
l_init_qty                     PA_BUDGET_LINES.QUANTITY%TYPE;
l_init_pc_raw_cost             PA_BUDGET_LINES.PROJECT_RAW_COST%TYPE;
l_init_txn_raw_cost            PA_BUDGET_LINES.TXN_RAW_COST%TYPE;
l_init_pc_burd_cost            PA_BUDGET_LINES.PROJECT_BURDENED_COST%TYPE;
l_init_txn_burd_cost           PA_BUDGET_LINES.TXN_BURDENED_COST%TYPE;
l_init_currency_tab            PA_PLSQL_DATATYPES.Char30TabTyp;

/* Variables for unspent amounts per ra_id */
l_unspent_amt_currency         PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE;
l_unspent_qty                  PA_BUDGET_LINES.QUANTITY%TYPE;
l_unspent_txn_raw_cost         PA_BUDGET_LINES.TXN_RAW_COST%TYPE;
l_unspent_txn_burd_cost        PA_BUDGET_LINES.TXN_BURDENED_COST%TYPE;

l_txn_raw_cost_rate            NUMBER;
l_txn_burd_cost_rate           NUMBER;

/* Variables for insert/update of Unspent Amount budget lines */
l_insert_flag                  VARCHAR2(1);
l_update_flag                  VARCHAR2(1);
l_upd_bl_id                    PA_BUDGET_LINES.BUDGET_LINE_ID%TYPE;
l_index                        NUMBER;

/* Variables for amounts of budget lines to be updated */
l_quantity                     PA_BUDGET_LINES.QUANTITY%TYPE;
l_txn_raw_cost                 PA_BUDGET_LINES.TXN_RAW_COST%TYPE;
l_txn_burdened_cost            PA_BUDGET_LINES.TXN_BURDENED_COST%TYPE;

l_last_updated_by              PA_BUDGET_LINES.LAST_UPDATED_BY%TYPE := FND_GLOBAL.user_id;
l_last_update_login            PA_BUDGET_LINES.LAST_UPDATE_LOGIN%TYPE := FND_GLOBAL.login_id;
l_sysdate                      DATE   := SYSDATE;

/* Tables for budget line Insert */
l_ins_ra_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
l_ins_start_date_tab           PA_PLSQL_DATATYPES.DateTabTyp;
l_ins_end_date_tab             PA_PLSQL_DATATYPES.DateTabTyp;
l_ins_txn_curr_code_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
l_ins_quantity_tab             PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_raw_cost_tab             PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_burd_cost_tab            PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_raw_cost_rate_tab        PA_PLSQL_DATATYPES.NumTabTyp;
l_ins_burd_cost_rate_tab       PA_PLSQL_DATATYPES.NumTabTyp;

/* Tables for budget line Update */
l_upd_bl_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
l_upd_quantity_tab             PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_raw_cost_tab             PA_PLSQL_DATATYPES.NumTabTyp;
l_upd_burd_cost_tab            PA_PLSQL_DATATYPES.NumTabTyp;

/* Variables for Fixed Dates spread curve logic */
lc_fixed_date_code             VARCHAR2(30) := 'FIXED_DATE';
l_fixed_date_curve_id          PA_RESOURCE_ASSIGNMENTS.SPREAD_CURVE_ID%TYPE;
l_fixed_date_ra_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;

l_count                        NUMBER;
l_msg_count                    NUMBER;
l_data                         VARCHAR2(1000);
l_msg_data                     VARCHAR2(1000);
l_msg_index_out                NUMBER;
BEGIN

  /* Setting initial values */
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'UNSPENT_AMOUNT'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;

    --dbms_output.put_line('p_app_cost_bdgt_ver_id = ' || p_app_cost_bdgt_ver_id);

     /* Calling  the get_plan_version_dtls api
        for the given app_cost_bdgt_ver_id*/
      IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             pa_fp_gen_amount_utils.get_plan_version_dtls',
              p_module_name => l_module_name,
              p_log_level   => 5);
     END IF;
     PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
             (P_PROJECT_ID         => p_fp_cols_rec.x_project_id,
              P_BUDGET_VERSION_ID  => p_app_cost_bdgt_ver_id,
              X_FP_COLS_REC        => l_fp_cols_rec_app_cost,
              X_RETURN_STATUS      => X_RETURN_STATUS,
              X_MSG_COUNT          => X_MSG_COUNT,
              X_MSG_DATA	   => X_MSG_DATA);
     IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;
     IF p_pa_debug_mode = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
                              pa_fp_gen_amount_utils.get_plan_version_dtls'
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;

/* We are mapping the approved cost budget version
   planning attributes to target budget version
   resource list and the amounts will be
   populated in the pa_fp_calc_amt_tmp3 table only
   for the periods till the actual thru period */

   IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             pa_fp_map_bv_pub.gen_map_bv_to_target_rl',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    PA_FP_MAP_BV_PUB.GEN_MAP_BV_TO_TARGET_RL
         (P_SOURCE_BV_ID            => p_app_cost_bdgt_ver_id,
          P_TARGET_FP_COLS_REC      => p_fp_cols_rec,
          P_ETC_FP_COLS_REC         => p_fp_cols_rec,
          P_CB_FP_COLS_REC          => l_fp_cols_rec_app_cost,
          X_RETURN_STATUS           => x_return_status,
          X_MSG_COUNT               => x_msg_count,
          X_MSG_DATA                => x_msg_data);
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
                              pa_fp_map_bv_pub.gen_map_bv_to_target_rl'
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;

    /* Insert the distinct target task_id and rlm_id values from tmp3 into tmp4.
     * These are the only resources that have planned amounts in the baselined
     * approved cost budget and are therefore the only resources that can possibly
     * have unspent amounts. */
    DELETE PA_RES_LIST_MAP_TMP4;
    INSERT INTO PA_RES_LIST_MAP_TMP4
         ( txn_task_id,
           txn_resource_list_member_id )
    SELECT /*+ INDEX(PA_FP_CALC_AMT_TMP3,PA_FP_CALC_AMT_TMP3_N1)*/
           DISTINCT
           task_id,
           res_list_member_id
    FROM   PA_FP_CALC_AMT_TMP3
    WHERE  plan_version_id = p_app_cost_bdgt_ver_id;

    select count(*) into l_count from pa_res_list_map_tmp4 where rownum=1;
    --dbms_output.put_line('Number of records inserted into tmp4 from tmp3 = ' || l_count);

    IF l_count = 0 THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;

    l_etc_start_date :=
        PA_FP_GEN_AMOUNT_UTILS.GET_ETC_START_DATE(p_budget_version_id);

    /* Get target resource assignment ids. */
    IF p_fp_cols_rec.X_GEN_RET_MANUAL_LINE_FLAG = 'N' THEN
        SELECT   /*+ INDEX(tmp4,PA_RES_LIST_MAP_TMP4_N1)*/
                 ra.resource_assignment_id,
                 ra.task_id,
                 ra.resource_list_member_id,
                 ra.rate_based_flag,
                 ra.planning_start_date,
                 ra.planning_end_date
        BULK     COLLECT
        INTO     l_res_asg_id_tab,
                 l_task_id_tab,
                 l_res_list_mem_id_tab,
                 l_rate_based_flag_tab,
                 l_planning_start_date_tab,
                 l_planning_end_date_tab
        FROM     pa_resource_assignments ra,
                 pa_res_list_map_tmp4 tmp4
        WHERE    ra.budget_version_id = p_budget_version_id
        AND      ra.task_id = tmp4.txn_task_id
        AND      ra.resource_list_member_id = tmp4.txn_resource_list_member_id
        ORDER BY ra.resource_assignment_id ASC;
    ELSIF p_fp_cols_rec.X_GEN_RET_MANUAL_LINE_FLAG = 'Y' THEN
        SELECT   /*+ INDEX(tmp4,PA_RES_LIST_MAP_TMP4_N1)*/
                 ra.resource_assignment_id,
                 ra.task_id,
                 ra.resource_list_member_id,
                 ra.rate_based_flag,
                 ra.planning_start_date,
                 ra.planning_end_date
        BULK     COLLECT
        INTO     l_res_asg_id_tab,
                 l_task_id_tab,
                 l_res_list_mem_id_tab,
                 l_rate_based_flag_tab,
                 l_planning_start_date_tab,
                 l_planning_end_date_tab
        FROM     pa_resource_assignments ra,
                 pa_res_list_map_tmp4 tmp4
        WHERE    ra.budget_version_id = p_budget_version_id
        AND      ra.task_id = tmp4.txn_task_id
        AND      ra.resource_list_member_id = tmp4.txn_resource_list_member_id
        AND    ( ra.transaction_source_code IS NOT NULL
                 OR ( ra.transaction_source_code IS NULL
                      AND NOT EXISTS ( SELECT 1
                                       FROM   pa_budget_lines bl
                                       WHERE  bl.resource_assignment_id =
                                              ra.resource_assignment_id
                                       AND    bl.start_date >= l_etc_start_date
                                       AND    rownum = 1 )))
        ORDER BY ra.resource_assignment_id ASC;
    END IF;

    /* Add target task_id, rlm_id, and ra_id values from pl/sql tables into tmp4.
     * We delete tmp4 and insert new lines instead of updating the existing ones
     * to simplify the manually added plan lines logic. */
    DELETE PA_RES_LIST_MAP_TMP4;
    FORALL i IN 1..l_res_asg_id_tab.count
        INSERT INTO PA_RES_LIST_MAP_TMP4
             ( txn_task_id,
               txn_resource_list_member_id,
               txn_resource_assignment_id )
        VALUES
             ( l_task_id_tab(i),
               l_res_list_mem_id_tab(i),
               l_res_asg_id_tab(i) );

    select count(*) into l_count from pa_res_list_map_tmp4 where rownum=1;
    --dbms_output.put_line('Number of target resources in tmp4 to be processed = ' || l_count);

    IF l_count = 0 THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;

    /* Bulk collect plan amounts, ordered by ascending ra_id. */
    SELECT   /*+ INDEX(tmp4,PA_RES_LIST_MAP_TMP4_N1) INDEX(bl,PA_FP_CALC_AMT_TMP3_N1)*/
             tmp4.txn_resource_assignment_id,
             bl.txn_currency_code,
             nvl(sum(nvl(bl.quantity,0)),0),
             nvl(sum(nvl(bl.pc_raw_cost,0)),0),
             nvl(sum(nvl(bl.txn_raw_cost,0)),0),
             nvl(sum(nvl(bl.pc_burdened_cost,0)),0),
             nvl(sum(nvl(bl.txn_burdened_cost,0)),0)
    BULK COLLECT
    INTO     l_plan_ra_id_tab,
             l_plan_txn_cur_code_tab,
             l_plan_qty_tab,
             l_plan_pc_raw_cost_tab,
             l_plan_txn_raw_cost_tab,
             l_plan_pc_burd_cost_tab,
             l_plan_txn_burd_cost_tab
    FROM     pa_fp_calc_amt_tmp3 bl,
             pa_res_list_map_tmp4 tmp4
    WHERE    bl.plan_version_id    = p_app_cost_bdgt_ver_id
    AND      bl.task_id            = tmp4.txn_task_id
    AND      bl.res_list_member_id = tmp4.txn_resource_list_member_id
    GROUP BY tmp4.txn_resource_assignment_id,
             bl.txn_currency_code
    ORDER BY tmp4.txn_resource_assignment_id ASC;

    /* Bulk collect actuals amounts, ordered by ascending ra_id. */
    -- SQL Repository Bug 4884824; SQL ID 14902142
    -- Fixed Full Index Scan violation by replacing
    -- existing hint with leading hint.
    SELECT   /*+ LEADING(tmp4) */
             tmp4.txn_resource_assignment_id,
             bl.txn_currency_code,
             nvl(sum(nvl(bl.init_quantity,0)),0),
             nvl(sum(nvl(bl.project_init_raw_cost,0)),0),
             nvl(sum(nvl(bl.txn_init_raw_cost,0)),0),
             nvl(sum(nvl(bl.project_init_burdened_cost,0)),0),
             nvl(sum(nvl(bl.txn_init_burdened_cost,0)),0)
    BULK COLLECT
    INTO     l_init_ra_id_tab,
             l_init_txn_cur_code_tab,
             l_init_qty_tab,
             l_init_pc_raw_cost_tab,
             l_init_txn_raw_cost_tab,
             l_init_pc_burd_cost_tab,
             l_init_txn_burd_cost_tab
    FROM     pa_budget_lines bl,
             pa_res_list_map_tmp4 tmp4
    WHERE    bl.resource_assignment_id = tmp4.txn_resource_assignment_id
    AND      bl.start_date < l_etc_start_date
    GROUP BY tmp4.txn_resource_assignment_id,
             bl.txn_currency_code
    ORDER BY tmp4.txn_resource_assignment_id ASC;

    /* Initialize local currency code variables. */
    l_pc_currency_code  := p_fp_cols_rec.X_PROJECT_CURRENCY_CODE;
    l_pfc_currency_code := p_fp_cols_rec.X_PROJFUNC_CURRENCY_CODE;

-- should InvalidArgException be thrown when period not found?

    l_time_phase := p_fp_cols_rec.x_time_phased_code;
    /* Initialize start/end dates and l_period for p_unspent_amt_period. */
    l_period_name := p_unspent_amt_period;
    IF l_time_phase = 'P' THEN
        BEGIN
            SELECT pap.start_date,
                   pap.end_date
            INTO   l_start_date,
                   l_end_date
            FROM   pa_periods_all pap
            WHERE  pap.period_name = p_unspent_amt_period
            AND    pap.org_id = p_fp_cols_rec.x_org_id;
        EXCEPTION
            WHEN OTHERS THEN RAISE;
        END;
    ELSIF l_time_phase = 'G' THEN
        BEGIN
            SELECT glp.start_date,
                   glp.end_date
            INTO   l_start_date,
                   l_end_date
            FROM   gl_period_statuses glp
            WHERE  glp.period_name = p_unspent_amt_period
            AND    glp.application_id   = pa_period_process_pkg.application_id
            AND    glp.set_of_books_id  = p_fp_cols_rec.x_set_of_books_id
            AND    glp.adjustment_period_flag = 'N';
        EXCEPTION
            WHEN OTHERS THEN RAISE;
        END;
    ELSIF l_time_phase = 'N' THEN
        l_period_name := NULL;
        l_start_date := NULL;
        l_end_date := NULL;
    END IF;

    --dbms_output.put_line('l_start_date = ' || l_start_date || ', l_end_date = ' || l_end_date);

    /* Initialize indices for traversal of plan/init pl/sql tables. */
    p_index := 1;
    i_index := 1;

    --dbms_output.put_line('Entering ra_id processing loop [count = ' || l_res_asg_id_tab.count || ']');

    FOR i IN 1..l_res_asg_id_tab.count LOOP
    FOR wrapper_loop_iterator IN 1..1 LOOP
        l_curr_ra_id := l_res_asg_id_tab(i);

        /* Sum plan quantity and pc amounts. */
        l_plan_qty := 0;
        l_plan_pc_raw_cost := 0;
        l_plan_txn_raw_cost := 0;
        l_plan_pc_burd_cost := 0;
        l_plan_txn_burd_cost := 0;
        l_plan_currency_tab.delete;
        WHILE ( p_index <= l_plan_ra_id_tab.count AND
                l_plan_ra_id_tab(p_index) <= l_curr_ra_id ) LOOP
            IF l_plan_ra_id_tab(p_index) = l_curr_ra_id THEN
                l_plan_currency_tab(l_plan_currency_tab.count+1)
                    := l_plan_txn_cur_code_tab(p_index);
                l_plan_qty := l_plan_qty + l_plan_qty_tab(p_index);
                l_plan_pc_raw_cost := l_plan_pc_raw_cost + l_plan_pc_raw_cost_tab(p_index);
                l_plan_txn_raw_cost := l_plan_txn_raw_cost + l_plan_txn_raw_cost_tab(p_index);
                l_plan_pc_burd_cost := l_plan_pc_burd_cost + l_plan_pc_burd_cost_tab(p_index);
                l_plan_txn_burd_cost := l_plan_txn_burd_cost + l_plan_txn_burd_cost_tab(p_index);
            END IF;
            p_index := p_index + 1;
        END LOOP; -- plan

        --dbms_output.put_line('ra_id = ' || l_curr_ra_id || ', l_plan_qty = ' || l_plan_qty);

        /* Skip to the next target resource if planned quantity is 0. */
        IF l_plan_qty = 0 THEN
            EXIT;
        END IF;

        /* Sum actual quantity and pc amounts */
        l_init_qty := 0;
        l_init_pc_raw_cost := 0;
        l_init_txn_raw_cost := 0;
        l_init_pc_burd_cost := 0;
        l_init_txn_burd_cost := 0;
        l_init_currency_tab.delete;
        l_actuals_exist_flag := 'Y';
        l_prev_i_index := i_index;
        WHILE ( i_index <= l_init_ra_id_tab.count AND
                l_init_ra_id_tab(i_index) <= l_curr_ra_id ) LOOP
            IF l_init_ra_id_tab(i_index) = l_curr_ra_id THEN
                l_init_currency_tab(l_init_currency_tab.count+1)
                    := l_init_txn_cur_code_tab(i_index);
                l_init_qty := l_init_qty + l_init_qty_tab(i_index);
                l_init_pc_raw_cost := l_init_pc_raw_cost + l_init_pc_raw_cost_tab(i_index);
                l_init_txn_raw_cost := l_init_txn_raw_cost + l_init_txn_raw_cost_tab(i_index);
                l_init_pc_burd_cost := l_init_pc_burd_cost + l_init_pc_burd_cost_tab(i_index);
                l_init_txn_burd_cost := l_init_txn_burd_cost + l_init_txn_burd_cost_tab(i_index);
            END IF;
            i_index := i_index + 1;
        END LOOP; -- actuals
        IF i_index = l_prev_i_index THEN
            l_actuals_exist_flag := 'N';
        END IF;

	--dbms_output.put_line('l_init_qty = ' || l_init_qty);
	--dbms_output.put_line('l_rate_based_flag_tab(i) = ' || l_rate_based_flag_tab(i));
	--dbms_output.put_line('l_plan_pc_raw_cost = ' || l_plan_pc_raw_cost);
	--dbms_output.put_line('l_init_pc_raw_cost = ' || l_init_pc_raw_cost);

        IF l_rate_based_flag_tab(i) = 'N' THEN
            IF l_unspent_amt_currency = l_pc_currency_code THEN
                l_plan_qty := l_plan_pc_raw_cost;
                l_init_qty := l_init_pc_raw_cost;
            ELSE
                l_plan_qty := l_plan_txn_raw_cost;
                l_init_qty := l_init_txn_raw_cost;
            END IF;
        END IF;

        /* Compute unspent quantity. */
        l_unspent_qty := l_plan_qty - l_init_qty;

        --dbms_output.put_line('l_unspent_qty = ' || l_unspent_qty);

        /* Skip to the next target resource if planned quantity is 0. */
        IF l_unspent_qty = 0 THEN
            EXIT;
        END IF;

        /* Determine txn currency for unspent amounts. */
        IF p_fp_cols_rec.x_plan_in_multi_curr_flag = 'N' THEN
            l_unspent_amt_currency := l_pc_currency_code;
        /* If planned amounts are in a single currency and either there
         * are no actuals or actuals are planned all in the same currency,
         * then the unspent amount should be in the txn currency of
         * the planned amounts. */
	ELSIF ( l_actuals_exist_flag = 'N' AND
	        l_plan_currency_tab.count = 1 ) OR
	      ( l_plan_currency_tab.count = 1 AND
	        l_init_currency_tab.count = 1 AND
	        l_plan_currency_tab(1) = l_init_currency_tab(1) ) THEN
	    l_unspent_amt_currency := l_plan_currency_tab(1);
        ELSE
            l_unspent_amt_currency := l_pc_currency_code;
        END IF;

        --dbms_output.put_line('l_unspent_amt_currency = ' || l_unspent_amt_currency);

        /* Derive rates based on actual amounts. */
        IF l_actuals_exist_flag = 'Y' AND l_init_qty <> 0 THEN
            IF l_unspent_amt_currency = l_pc_currency_code THEN
                l_txn_raw_cost_rate  := l_init_pc_raw_cost  / l_init_qty;
                l_txn_burd_cost_rate := l_init_pc_burd_cost / l_init_qty;
            ELSE
                l_txn_raw_cost_rate  := l_init_txn_raw_cost  / l_init_qty;
                l_txn_burd_cost_rate := l_init_txn_burd_cost / l_init_qty;
            END IF;
        /* If no actuals exist, then derive rates based on planned amounts. */
        ELSIF l_actuals_exist_flag = 'N' AND l_plan_qty <> 0 THEN
            IF l_unspent_amt_currency = l_pc_currency_code THEN
                l_txn_raw_cost_rate  := l_plan_pc_raw_cost  / l_plan_qty;
                l_txn_burd_cost_rate := l_plan_pc_burd_cost / l_plan_qty;
            ELSE
                l_txn_raw_cost_rate  := l_plan_txn_raw_cost  / l_plan_qty;
                l_txn_burd_cost_rate := l_plan_txn_burd_cost / l_plan_qty;
            END IF;
        ELSE
            -- Add additional Error Handling logic here if desired.
            -- For now, if rates cannot be derivced, skip this resource.
            EXIT;
        END IF;

	--dbms_output.put_line('l_txn_raw_cost_rate = ' || l_txn_raw_cost_rate);
	--dbms_output.put_line('l_txn_burd_cost_rate = ' || l_txn_burd_cost_rate);

        /* Compute unspent amounts. */
        l_unspent_txn_raw_cost  := l_unspent_qty * l_txn_raw_cost_rate;
        l_unspent_txn_burd_cost := l_unspent_qty * l_txn_burd_cost_rate;

        /* Check if we should insert a new budget line or update an existing one
         * with the unspent amounts. Store data in corresponding pl/sql tables. */
        l_update_flag := 'Y';
        l_insert_flag := 'N';
        BEGIN
            SELECT    budget_line_id,
                      quantity,
                      txn_raw_cost,
                      txn_burdened_cost
            INTO      l_upd_bl_id,
                      l_quantity,
                      l_txn_raw_cost,
                      l_txn_burdened_cost
            FROM      pa_budget_lines
            WHERE     resource_assignment_id = l_curr_ra_id
            AND       txn_currency_code = l_unspent_amt_currency
            AND       start_date = DECODE(l_time_phase, 'N', start_date, l_start_date);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_insert_flag := 'Y';
                l_update_flag := 'N';
        END;

        IF l_insert_flag = 'Y' THEN
            l_index := l_ins_ra_id_tab.count+1;
	    l_ins_ra_id_tab(l_index) := l_curr_ra_id;
	    l_ins_start_date_tab(l_index) := l_planning_start_date_tab(i);
	    l_ins_end_date_tab(l_index) := l_planning_end_date_tab(i);
	    l_ins_txn_curr_code_tab(l_index) := l_unspent_amt_currency;
	    l_ins_quantity_tab(l_index) := l_unspent_qty;
	    l_ins_raw_cost_tab(l_index) := l_unspent_txn_raw_cost;
	    l_ins_burd_cost_tab(l_index) := l_unspent_txn_burd_cost;
	    l_ins_raw_cost_rate_tab(l_index) := l_txn_raw_cost_rate;
	    l_ins_burd_cost_rate_tab(l_index) := l_txn_burd_cost_rate;
        END IF;
        IF l_update_flag = 'Y' THEN
            l_index := l_upd_bl_id_tab.count+1;
	    l_upd_bl_id_tab(l_index) := l_upd_bl_id;
	    l_upd_quantity_tab(l_index) := l_unspent_qty;
	    l_upd_raw_cost_tab(l_index) := l_unspent_txn_raw_cost;
	    l_upd_burd_cost_tab(l_index) := l_unspent_txn_burd_cost;
        END IF;

    END LOOP; -- wrapper
    END LOOP; -- target ra_id processing

    --dbms_output.put_line('l_ins_ra_id_tab.count = ' || l_ins_ra_id_tab.count);

    IF  l_ins_ra_id_tab.count > 0 THEN

        FORALL i IN 1..l_ins_ra_id_tab.count
            INSERT INTO PA_BUDGET_LINES (
                BUDGET_LINE_ID,
                BUDGET_VERSION_ID,
                RESOURCE_ASSIGNMENT_ID,
                START_DATE,
                TXN_CURRENCY_CODE,
                END_DATE,
                PERIOD_NAME,
                QUANTITY,
                TXN_RAW_COST,
                TXN_BURDENED_COST,
                TXN_COST_RATE_OVERRIDE,
                BURDEN_COST_RATE_OVERRIDE,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                PROJECT_CURRENCY_CODE,
                PROJFUNC_CURRENCY_CODE)
            VALUES (
                pa_budget_lines_s.nextval,
                p_budget_version_id,
                l_ins_ra_id_tab(i),
                NVL(l_start_date,l_ins_start_date_tab(i)),
                l_ins_txn_curr_code_tab(i),
                NVL(l_end_date,l_ins_end_date_tab(i)),
                l_period_name,
                l_ins_quantity_tab(i),
                l_ins_raw_cost_tab(i),
                l_ins_burd_cost_tab(i),
                l_ins_raw_cost_rate_tab(i),
                l_ins_burd_cost_rate_tab(i),
                l_sysdate,
                l_last_updated_by,
                l_sysdate,
                l_last_updated_by,
                l_last_update_login,
                l_pc_currency_code,
                l_pfc_currency_code );

        /* If the resource uses Fixed Date spread and the fixed date is not in the
         * unspent amounts period, then NULL out the spread curve and fixed date. */

        DELETE PA_RES_LIST_MAP_TMP4;
        FORALL i IN 1..l_ins_ra_id_tab.count
            INSERT INTO PA_RES_LIST_MAP_TMP4
                   ( txn_resource_assignment_id )
            VALUES ( l_ins_ra_id_tab(i) );

	SELECT spread_curve_id
	INTO   l_fixed_date_curve_id
	FROM   pa_spread_curves_b
	WHERE  spread_curve_code = lc_fixed_date_code;

        -- SQL Repository Bug 4884824; SQL ID 14902330
        -- Fixed Full Index Scan violation by replacing
        -- existing hint with leading hint.
        SELECT /*+ LEADING(tmp4) */
               ra.resource_assignment_id
	BULK COLLECT
	INTO  l_fixed_date_ra_id_tab
	FROM  pa_resource_assignments ra,
	      pa_res_list_map_tmp4 tmp4
	WHERE ra.resource_assignment_id = tmp4.txn_resource_assignment_id
	AND   ra.spread_curve_id = l_fixed_date_curve_id
	AND   NOT ( ra.sp_fixed_date BETWEEN l_start_date AND l_end_date );

        FORALL i IN 1..l_fixed_date_ra_id_tab.count
            UPDATE pa_resource_assignments
            SET    spread_curve_id = NULL,
                   sp_fixed_date = NULL,
                   last_update_date = l_sysdate,
                   last_updated_by = l_last_updated_by,
                   last_update_login = l_last_update_login,
                   record_version_number = NVL(record_version_number,0)+1
            WHERE  resource_assignment_id = l_fixed_date_ra_id_tab(i);
    END IF; -- budget line insertion

    --dbms_output.put_line('l_upd_bl_id_tab.count = ' || l_upd_bl_id_tab.count);

    IF l_upd_bl_id_tab.count > 0 THEN
         FORALL i IN 1..l_upd_bl_id_tab.count
             UPDATE PA_BUDGET_LINES
             SET    LAST_UPDATE_DATE             = l_sysdate
             ,      LAST_UPDATED_BY              = l_last_updated_by
             ,      LAST_UPDATE_LOGIN            = l_last_update_login
             ,      QUANTITY                     = nvl(quantity,0) + nvl(l_upd_quantity_tab(i),0)
             ,      TXN_RAW_COST                 = nvl(txn_raw_cost,0) + nvl(l_upd_raw_cost_tab(i),0)
             ,      TXN_BURDENED_COST            = nvl(txn_burdened_cost,0) + nvl(l_upd_burd_cost_tab(i),0)
             ,      TXN_COST_RATE_OVERRIDE       = (nvl(txn_raw_cost,0) + nvl(l_upd_raw_cost_tab(i),0)) /
                                                   (nvl(quantity,0) + nvl(l_upd_quantity_tab(i),0))
             ,      BURDEN_COST_RATE_OVERRIDE    = (nvl(txn_burdened_cost,0) + nvl(l_upd_burd_cost_tab(i),0)) /
                                                   (nvl(quantity,0) + nvl(l_upd_quantity_tab(i),0))
             WHERE  BUDGET_LINE_ID               = l_upd_bl_id_tab(i);
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
          pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Before calling
                               pa_fp_maintain_actual_pub.sync_up_planning_dates',
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;
    PA_FP_MAINTAIN_ACTUAL_PUB.SYNC_UP_PLANNING_DATES
          (P_BUDGET_VERSION_ID => p_budget_version_id,
           P_CALLING_CONTEXT   => 'SYNC_VERSION_LEVEL',
           X_RETURN_STATUS     => x_return_Status,
           X_MSG_COUNT         => x_msg_count,
           X_MSG_DATA          => x_msg_data );
    IF p_pa_debug_mode = 'Y' THEN
          pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Status after calling
                               pa_fp_maintain_actual_pub.sync_up_planning_dates'
                               ||x_return_status,
             p_module_name => l_module_name,
             p_log_level   => 5);
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;

EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.GET_MESSAGES
                ( p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out );
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
        END IF;

        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF p_pa_debug_mode = 'Y' THEN
           PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Invalid Arguments Passed',
              p_module_name => l_module_name,
              p_log_level   => 5 );
	    PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        FND_MSG_PUB.ADD_EXC_MSG
            ( p_pkg_name        => 'PA_FP_GEN_PUB',
              p_procedure_name  => 'UNSPENT_AMOUNT',
              p_error_text      => substr(sqlerrm,1,240) );

	IF p_pa_debug_mode = 'Y' THEN
           PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
              p_module_name => l_module_name,
              p_log_level   => 5 );
   	    PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UNSPENT_AMOUNT;

--Please note that wbs_element_version id will be NULL for budgets and forecasts. If this API is called
--for a B/F version then nothing will happen. The API  just return without doing any processing
PROCEDURE UPD_WBS_ELEMENT_VERSION_ID
          (P_BUDGET_VERSION_ID              IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_STRUCTURE_VERSION_ID           IN            NUMBER,
           X_RETURN_STATUS                  OUT   NOCOPY  VARCHAR2,
           X_MSG_COUNT                      OUT   NOCOPY  NUMBER,
           X_MSG_DATA                       OUT   NOCOPY  VARCHAR2) IS

   l_task_id_tab              PA_PLSQL_DATATYPES.IdTabTyp;
   l_wbs_element_ver_id_tab   PA_PLSQL_DATATYPES.IdTabTyp;
   l_structure_version_id     NUMBER;
   l_wp_version_flag          pa_budget_versions.wp_version_flag%TYPE;

BEGIN

  /* Setting initial values */
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'UPD_WBS_ELEMENT_VERSION_ID'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;



    SELECT NVL(P_STRUCTURE_VERSION_ID,project_structure_version_id),
           NVL(wp_version_flag,'N')
    INTO   l_structure_version_id,
           l_wp_version_flag
    FROM   pa_budget_versions
    WHERE  budget_version_id = p_budget_version_id;

    IF l_wp_version_flag = 'N' THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;


     SELECT  ra.task_id,
             pa_proj_elements_utils.get_task_version_id(
                 l_structure_version_id,ra.task_id)
     BULK    COLLECT
     INTO    l_task_id_tab,
             l_wbs_element_ver_id_tab
     FROM    pa_resource_assignments ra
     WHERE   ra.budget_version_id           = p_budget_version_id
     AND     nvl(ra.task_id,0)              > 0;

     IF   l_task_id_tab.count = 0 THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RETURN;
     END IF;

     FORALL i in 1..l_task_id_tab.count
        UPDATE pa_resource_assignments
        SET    wbs_element_version_id = l_wbs_element_ver_id_tab(i)
        WHERE  budget_version_id     = p_budget_version_id
        AND    task_id               = l_task_id_tab(i);

     IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
     END IF;

EXCEPTION
    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_PUB'
              ,p_procedure_name => 'UPD_WBS_ELEMENT_VERSION_ID');
     IF P_PA_DEBUG_MODE = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPD_WBS_ELEMENT_VERSION_ID;

/*  Procedure Name: PRORATE_UNALIGNED_PERIOD_AMOUNTS
    Created: 10/15/2004
    Summary: This procedure is called when generating forecast amounts for a particular planning
             element.  When the source version and target version periods do not align (ie. one is PA,
             and the other is GL), then amounts from the less granular period must be pro-rated when
             copied over to the more granular period.
*/
PROCEDURE PRORATE_UNALIGNED_PERIOD_AMTS
    (P_SRC_RES_ASG_ID_TAB	IN   PA_PLSQL_DATATYPES.IdTabTyp,
     P_TARGET_RES_ASG_ID    	IN   PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE,
     P_CURRENCY_CODE		IN   PA_BUDGET_LINES.TXN_CURRENCY_CODE%TYPE,
     P_CURRENCY_CODE_FLAG	IN   VARCHAR2,
     P_ACTUAL_THRU_DATE		IN   PA_PERIODS_ALL.END_DATE%TYPE,
     X_QUANTITY		        OUT  NOCOPY PA_BUDGET_LINES.QUANTITY%TYPE,
     X_TXN_RAW_COST		OUT  NOCOPY PA_BUDGET_LINES.TXN_RAW_COST%TYPE,
     X_TXN_BURDENED_COST	OUT  NOCOPY PA_BUDGET_LINES.TXN_BURDENED_COST%TYPE,
     X_TXN_REVENUE		OUT  NOCOPY PA_BUDGET_LINES.TXN_REVENUE%TYPE,
     X_PROJ_RAW_COST		OUT  NOCOPY PA_BUDGET_LINES.PROJECT_RAW_COST%TYPE,
     X_PROJ_BURDENED_COST	OUT  NOCOPY PA_BUDGET_LINES.PROJECT_BURDENED_COST%TYPE,
     X_PROJ_REVENUE		OUT  NOCOPY  PA_BUDGET_LINES.PROJECT_REVENUE%TYPE,
     X_RETURN_STATUS		OUT  NOCOPY  VARCHAR2,
     X_MSG_COUNT		OUT  NOCOPY  NUMBER,
     X_MSG_DATA			OUT  NOCOPY  VARCHAR2) IS

l_project_currency_code         pa_projects_all.project_currency_code%TYPE;
l_org_id			pa_projects_all.org_id%TYPE;
l_target_ver_period_type        pa_proj_fp_options.cost_time_phased_code%TYPE;
l_target_set_of_books_id        pa_implementations_all.set_of_books_id%TYPE;
l_target_period_name		pa_budget_lines.period_name%TYPE;
l_target_start_date		pa_budget_lines.start_date%TYPE;
l_target_end_date		pa_budget_lines.end_date%TYPE;
l_source_ver_period_type        pa_proj_fp_options.cost_time_phased_code%TYPE;
l_source_set_of_books_id        pa_implementations_all.set_of_books_id%TYPE;
l_source_period_name		pa_budget_lines.period_name%TYPE;
l_source_start_date		pa_budget_lines.start_date%TYPE;
l_source_end_date		pa_budget_lines.end_date%TYPE;

l_prorated_multiplier   NUMBER;
l_quantity		NUMBER;
l_txn_raw_cost		NUMBER;
l_txn_burdened_cost	NUMBER;
l_txn_revenue		NUMBER;
l_pc_raw_cost		NUMBER;
l_pc_burdened_cost	NUMBER;
l_pc_revenue		NUMBER;

  --Cursor used to select the PA period that contains the amts_thru_date and later
  CURSOR  pa_period_csr(c_amt_thru PA_PERIODS_ALL.END_DATE%TYPE,
                        c_org_id   PA_PROJECTS_ALL.ORG_ID%TYPE) IS
  SELECT  period_name, start_date, end_date
  FROM    pa_periods_all
  WHERE   org_id = c_org_id and -- R12 MOAC 4447573: nvl(org_id,-99) = nvl(c_org_id,-99)
          c_amt_thru between start_date and end_date;
  pa_period_rec pa_period_csr%ROWTYPE;

  --Cursor used to select the GL period that contains the amts_thru_date and later
  CURSOR  gl_period_csr(c_amt_thru PA_PERIODS_ALL.END_DATE%TYPE,
                        c_set_of_books PA_IMPLEMENTATIONS_ALL.SET_OF_BOOKS_ID%TYPE) IS
  SELECT  period_name, start_date , end_date
  FROM    gl_period_statuses
  WHERE   application_id = PA_PERIOD_PROCESS_PKG.Application_id and
          set_of_books_id = c_set_of_books and
          adjustment_period_flag = 'N' and
          c_amt_thru between start_date and end_date;
  gl_period_rec gl_period_csr%ROWTYPE;

  l_source_bv_id       pa_budget_lines.budget_version_id%TYPE;
BEGIN

    IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_curr_function( p_function   => 'PRORATE_UNALIGNED_PERIOD_AMTS',
                                    p_debug_mode => p_pa_debug_mode );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    /* Business Rules check */
    -- Check for null P_TARGET_RES_ASG_ID

    /* Begin processing */

    -- Initialize output parameters; currently, we do not use the proj_ params
    x_quantity := 0;
    x_txn_raw_cost := 0;
    x_txn_burdened_cost := 0;
    x_txn_revenue := 0;
    x_proj_raw_cost := NULL;
    x_proj_burdened_cost := NULL;
    x_proj_revenue := NULL;

    IF p_src_res_asg_id_tab.count = 0 THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;

    -- get necessary source budget version info
    select nvl(p.org_id,-99),
           DECODE(po.fin_plan_preference_code,
                  'COST_ONLY', po.cost_time_phased_code,
                  'REVENUE_ONLY', po.revenue_time_phased_code,
                  po.all_time_phased_code),
           pia.set_of_books_id,
           ra.budget_version_id
      into l_org_id,
           l_source_ver_period_type,
           l_source_set_of_books_id,
           l_source_bv_id
      from pa_resource_assignments ra,
           pa_projects_all p,
           pa_proj_fp_options po,
           pa_implementations_all pia
      where ra.resource_assignment_id = p_src_res_asg_id_tab(1) and
            ra.project_id = p.project_id and
            ra.budget_version_id = po.fin_plan_version_id and
            po.fin_plan_option_level_code = 'PLAN_VERSION' and
            p.org_id = pia.org_id;
            -- R12 MOAC 4447573: nvl(p.org_id, -99) = nvl(pia.org_id, -99)

    IF l_source_ver_period_type = 'P' THEN
        -- Open PA Cursor using TARGET Actuals Thru Date
        OPEN  pa_period_csr(p_actual_thru_date, l_org_id);
        FETCH pa_period_csr
        INTO  l_source_period_name,
              l_source_start_date,
              l_source_end_date;
        CLOSE pa_period_csr;
    ELSIF l_source_ver_period_type = 'G' THEN
        OPEN  gl_period_csr(p_actual_thru_date, l_source_set_of_books_id);
        FETCH gl_period_csr
        INTO  l_source_period_name,
              l_source_start_date,
              l_source_end_date;
        CLOSE gl_period_csr;
    ELSE
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;

    l_prorated_multiplier := (l_source_end_date - p_actual_thru_date) /
                             (l_source_end_date - l_source_start_date + 1);

    IF l_prorated_multiplier = 0 THEN
        IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;

    /* Use temporary table to Bulk process resources.
     * We use the target_res_asg_id column instead of source_res_asg_id
     * so that we can make use of the index on the temp table. */
    DELETE pa_fp_gen_rate_tmp;
    FORALL i IN 1..p_src_res_asg_id_tab.count
        INSERT INTO pa_fp_gen_rate_tmp
               ( target_res_asg_id )
        VALUES ( p_src_res_asg_id_tab(i) );

    -- SQL Repository Bug 4884824; SQL ID 14902567
    -- Fixed Full Index Scan violation by replacing
    -- existing hint with leading hint.
    SELECT /*+ LEADING(tmp) */
           nvl(sum(sbl.quantity),0),
           nvl(sum(decode(p_currency_code_flag,
                      'Y', sbl.txn_raw_cost,
                      'N', sbl.project_raw_cost,
                      'A', sbl.raw_cost)),0),
           nvl(sum(decode(p_currency_code_flag,
                      'Y', sbl.txn_burdened_cost,
                      'N', sbl.project_burdened_cost,
                      'A', sbl.burdened_cost)),0),
           nvl(sum(decode(p_currency_code_flag,
                      'Y', sbl.txn_revenue,
                      'N', sbl.project_revenue,
                      'A', sbl.revenue)),0)
    INTO l_quantity,
         l_txn_raw_cost,
         l_txn_burdened_cost,
         l_txn_revenue
    FROM pa_fp_gen_rate_tmp tmp,
         pa_budget_lines sbl
    WHERE tmp.target_res_asg_id = sbl.resource_assignment_id
          and sbl.budget_version_id = l_source_bv_id
          and sbl.period_name = l_source_period_name
          and sbl.txn_currency_code = decode(p_currency_code_flag,
                                             'Y', p_currency_code,
                                             'N', sbl.txn_currency_code,
                                             'A', sbl.txn_currency_code)
          and sbl.cost_rejection_code is null
          and sbl.revenue_rejection_code is null
          and sbl.burden_rejection_code is null
          and sbl.other_rejection_code is null
          and sbl.pc_cur_conv_rejection_code is null
          and sbl.pfc_cur_conv_rejection_code is null;

     x_quantity := l_quantity * l_prorated_multiplier;
     x_txn_raw_cost := l_txn_raw_cost * l_prorated_multiplier;
     x_txn_burdened_cost := l_txn_burdened_cost * l_prorated_multiplier;
     x_txn_revenue := l_txn_revenue * l_prorated_multiplier;
EXCEPTION
    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_PUB'
              ,p_procedure_name => 'PRORATE_UNALIGNED_PERIOD_AMTS');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END PRORATE_UNALIGNED_PERIOD_AMTS;


/**
 * This procedure updates the fixed date spread curve fields in the
 * pa_resource_assignments table for all resource assignments belonging
 * to the given budget version as necessary.
 * More specifically, for each resource assignment of interest, we null
 * out the spread_curve_id and sp_fixed_date pa_resource_assignments
 * table values if there exists a budget line for which the resource
 * assignment's sp_fixed_date is not in the budget line's start and end
 * date range.
 * Additionally, for resources not having Fixed Date spread curves, we
 * ensure that sp_fixed_date is Nulled out to address Bug 4229963.
 *
 * Note: This API currently updates the PA_RESOURCE_ASSIGNMENTS table
 *       multiple times. In the future, we revisit this as a Performance
 *       issue and modify the logic so that we only update once.
 *
 * Note that the p_fp_col_rec parameter is currently not used.
 */
PROCEDURE MAINTAIN_FIXED_DATE_SP
   (P_BUDGET_VERSION_ID            IN            PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
    P_FP_COLS_REC                  IN            PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
    X_RETURN_STATUS                OUT  NOCOPY   VARCHAR2,
    X_MSG_COUNT                    OUT  NOCOPY   NUMBER,
    X_MSG_DATA                     OUT  NOCOPY   VARCHAR2)
IS
    l_module_name VARCHAR2(100) := 'pa.plsql.PA_FP_GEN_PUB.MAINTAIN_FIXED_DATE_SP';

    /* String constant for the fixed date spread curve code */
    lc_FixedDate          CONSTANT PA_SPREAD_CURVES_B.SPREAD_CURVE_CODE%TYPE := 'FIXED_DATE';

    /* This cursor picks up resource assignment id's for resource assignments
     * having a fixed date spread curve and at least two budget lines for some
     * transaction currency code. */
    CURSOR multi_bl_fixed_date_ra_cur IS
    SELECT DISTINCT(bl.resource_assignment_id)
      FROM pa_resource_assignments ra,
           pa_spread_curves_b sp,
           pa_budget_lines bl
     WHERE ra.budget_version_id = p_budget_version_id
       AND sp.spread_curve_id = ra.spread_curve_id
       AND sp.spread_curve_code = lc_FixedDate
       AND bl.resource_assignment_id = ra.resource_assignment_id
     GROUP BY bl.resource_assignment_id,
              bl.txn_currency_code
    HAVING count(*) > 1;

    /* This cursor picks up resource assignment id's for resource assignments
     * having a fixed date spread curve and a budget line whose start and end
     * dates do not contain the resource assignment's sp_fixed_date.
     * Note that by first processing resource assignments returned by the
     * the multi_bl_fixed_date_ra_cur cursor, we can reduce the amount of
     * processing required by this cursor. */
    CURSOR one_bl_fixed_date_ra_cur IS
    SELECT DISTINCT(bl.resource_assignment_id)
      FROM pa_resource_assignments ra,
           pa_spread_curves_b sp,
           pa_budget_lines bl
     WHERE ra.budget_version_id = p_budget_version_id
       AND sp.spread_curve_id = ra.spread_curve_id
       AND sp.spread_curve_code = lc_FixedDate
       AND bl.resource_assignment_id = ra.resource_assignment_id
       AND ra.sp_fixed_date NOT BETWEEN bl.start_date AND bl.end_date;

    /* PL/SQL table variable for the cursors */
    l_res_asg_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;

    l_count                        NUMBER;
    l_msg_count                    NUMBER;
    l_data                         VARCHAR2(1000);
    l_msg_data                     VARCHAR2(1000);
    l_msg_index_out                NUMBER;

    l_fixed_date_id                PA_SPREAD_CURVES_B.SPREAD_CURVE_ID%TYPE;

    l_last_updated_by              NUMBER := FND_GLOBAL.user_id;
    l_last_update_login            NUMBER := FND_GLOBAL.login_id;
    l_sysdate                      DATE   := SYSDATE;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    IF p_pa_debug_mode = 'Y' THEN
	PA_DEBUG.SET_CURR_FUNCTION
            ( p_function   => 'MAINTAIN_FIXED_DATE_SP',
              p_debug_mode => p_pa_debug_mode );
    END IF;

    /* Check the input parameter(s) */
    IF p_budget_version_id IS NULL THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /* Get the spread curve id for Fixed Date */
    SELECT spread_curve_id INTO l_fixed_date_id
      FROM pa_spread_curves_b
     WHERE spread_curve_code = lc_FixedDate;

    /* Fetch resource assignment id's for resource assignments having
     * a fixed date spread curve and multiple budget lines for some
     * transaction currency code. */
    OPEN multi_bl_fixed_date_ra_cur;
    FETCH multi_bl_fixed_date_ra_cur
    BULK COLLECT
    INTO l_res_asg_id_tab;
    CLOSE multi_bl_fixed_date_ra_cur;

    /* Null out the sp_fixed_date and spread_curve_id in the
     * pa_resource_assignments table for the collected resource
     * assignment id's */
    FORALL i in 1..l_res_asg_id_tab.count
        UPDATE pa_resource_assignments
           SET sp_fixed_date = NULL,
               spread_curve_id = NULL,
               last_update_date = l_sysdate,
               last_updated_by = l_last_updated_by,
               last_update_login = l_last_update_login,
               record_version_number = NVL(record_version_number,0) + 1
         WHERE resource_assignment_id = l_res_asg_id_tab(i);

    /* Of the remaining fixed date resource assignments for the given
     * budget version (each of which should now have at most 1 budget
     * line), fetch the id's for resource assignments having a budget
     * line whose start and end dates do not contain the resource
     * assignment's sp_fixed_date. */
    OPEN one_bl_fixed_date_ra_cur;
    FETCH one_bl_fixed_date_ra_cur
    BULK COLLECT
    INTO l_res_asg_id_tab;
    CLOSE one_bl_fixed_date_ra_cur;

    /* Null out the sp_fixed_date and spread_curve_id in the
     * pa_resource_assignments table for the collected resource
     * assignment id's */
    FORALL i in 1..l_res_asg_id_tab.count
        UPDATE pa_resource_assignments
           SET sp_fixed_date = NULL,
               spread_curve_id = NULL,
               last_update_date = l_sysdate,
               last_updated_by = l_last_updated_by,
               last_update_login = l_last_update_login,
               record_version_number = NVL(record_version_number,0) + 1
         WHERE resource_assignment_id = l_res_asg_id_tab(i);

    -- Bug 4229963: Ensure sp_fixed_date is NULL when spread is not Fixed Date.
    UPDATE pa_resource_assignments
       SET sp_fixed_date = NULL,
           last_update_date = l_sysdate,
           last_updated_by = l_last_updated_by,
           last_update_login = l_last_update_login,
           record_version_number = NVL(record_version_number,0) + 1
     WHERE budget_version_id = p_budget_version_id
       AND spread_curve_id <> l_fixed_date_id
       AND sp_fixed_date IS NOT NULL;

    IF p_pa_debug_mode = 'Y' THEN
      	PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;
EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.GET_MESSAGES
                ( p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out );
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
        END IF;

        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF p_pa_debug_mode = 'Y' THEN
           PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Invalid Arguments Passed',
              p_module_name => l_module_name,
              p_log_level   => 5 );
	    PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        FND_MSG_PUB.ADD_EXC_MSG
            ( p_pkg_name        => 'PA_FP_GEN_PUB',
              p_procedure_name  => 'MAINTAIN_FIXED_DATE_SP',
              p_error_text      => substr(sqlerrm,1,240) );

	IF p_pa_debug_mode = 'Y' THEN
           PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
              p_module_name => l_module_name,
              p_log_level   => 5 );
   	    PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END MAINTAIN_FIXED_DATE_SP;

/**
 * This procedure copies source attributes to target resources with the
 * intended context as Forecast Generation. Attributes will only be copied
 * when the following Source/Target conditions are met:
 *    1. Planning Level must be same.
 *    2. Resource List must be same.
 *    3. Structure should be a fully shared structure.
 * The only exception to the above is that planning attributes are not
 * carried over when the generation FP/WP source is None time-phased and
 * the target forecast version is time phased.
 *
 * Before calling this API, the TXN_RESOURCE_ASSIGNMENT_ID column of the
 * PA_RES_LIST_MAP_TMP1 table should be populated with resources to be
 * processed. Furthermore, the PA_FP_CALC_AMT_TMP1 table should contain
 * the resource mapping and ETC source code information for said resources.
 *
 * An Invalid Argument Exception will be raised if the p_fp_cols_rec
 * parameter is NULL or has NULL values for either the project id or the
 * budget version id.
 */
PROCEDURE COPY_SRC_ATTRS_TO_TARGET_FCST
    (P_FP_COLS_REC                  IN            PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
     X_RETURN_STATUS                OUT  NOCOPY   VARCHAR2,
     X_MSG_COUNT                    OUT  NOCOPY   NUMBER,
     X_MSG_DATA                     OUT  NOCOPY   VARCHAR2)
IS
    l_module_name VARCHAR2(100) := 'pa.plsql.PA_FP_GEN_PUB.' ||
                                   'COPY_SRC_ATTRS_TO_TARGET_FCST';
    l_log_level                    CONSTANT PLS_INTEGER := 5;

    l_stru_sharing_code            PA_PROJECTS_ALL.STRUCTURE_SHARING_CODE%TYPE;

    l_src_version_id_tab           PA_PLSQL_DATATYPES.IdTabTyp;
    l_gen_etc_src_code_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
    l_src_version_id               PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
    l_gen_etc_src_code             PA_PROJ_FP_OPTIONS.GEN_COST_ETC_SRC_CODE%TYPE;
    l_fp_cols_rec_src              PA_FP_GEN_AMOUNT_UTILS.FP_COLS;

    l_tgt_res_asg_id_tab           PA_PLSQL_DATATYPES.IdTabTyp;

    /* PL/SQL tables for copying source resource assignment attributes */
    l_resource_class_flag_tab      PA_PLSQL_DATATYPES.Char15TabTyp;
    l_resource_class_code_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
    l_res_type_code_tab            PA_PLSQL_DATATYPES.Char30TabTyp;
    l_person_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
    l_job_id_tab                   PA_PLSQL_DATATYPES.IdTabTyp;
    l_person_type_code_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
    l_named_role_tab               PA_PLSQL_DATATYPES.Char80TabTyp;
    l_bom_resource_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
    l_non_labor_resource_tab       PA_PLSQL_DATATYPES.Char20TabTyp;
    l_inventory_item_id_tab        PA_PLSQL_DATATYPES.IdTabTyp;
    l_item_category_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
    l_project_role_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
    l_organization_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
    l_fc_res_type_code_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
    l_expenditure_type_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
    l_expenditure_category_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
    l_event_type_tab               PA_PLSQL_DATATYPES.Char30TabTyp;
    l_revenue_category_code_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
    l_supplier_id_tab              PA_PLSQL_DATATYPES.IdTabTyp;
    l_spread_curve_id_tab          PA_PLSQL_DATATYPES.IdTabTyp;
    l_sp_fixed_date_tab            PA_PLSQL_DATATYPES.DateTabTyp;
    l_mfc_cost_type_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
    l_incurred_by_res_flag_tab     PA_PLSQL_DATATYPES.Char15TabTyp;
    l_incur_by_res_cls_code_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
    l_incur_by_role_id_tab         PA_PLSQL_DATATYPES.IdTabTyp;
    l_rate_expenditure_type_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
    l_rate_func_curr_code_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
    l_org_id_tab                   PA_PLSQL_DATATYPES.IdTabTyp;
    -- IPM: Added table for copying source resource_rate_based_flag values.
    l_res_rate_based_flag_tab      PA_PLSQL_DATATYPES.Char15TabTyp;

    l_sysdate                      DATE;
    l_last_updated_by              PA_RESOURCE_ASSIGNMENTS.LAST_UPDATED_BY%TYPE
				       := FND_GLOBAL.user_id;
    l_last_update_login            PA_RESOURCE_ASSIGNMENTS.LAST_UPDATE_LOGIN%TYPE
				       := FND_GLOBAL.login_id;

    l_count                        NUMBER;
    l_msg_count                    NUMBER;
    l_data                         VARCHAR2(1000);
    l_msg_data                     VARCHAR2(1000);
    l_msg_index_out                NUMBER;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    IF p_pa_debug_mode = 'Y' THEN
	PA_DEBUG.SET_CURR_FUNCTION
            ( p_function   => 'COPY_SRC_ATTRS_TO_TARGET_FCST',
              p_debug_mode => p_pa_debug_mode );
    END IF;

    /* Enforce that p_fp_cols_rec has valid id values. */
    IF p_fp_cols_rec.x_project_id IS NULL OR
       p_fp_cols_rec.x_budget_version_id IS NULL THEN
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INV_PARAM_PASSED' );
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /* Check that the project has Fully Shared WBS and a non-null source id */
    l_stru_sharing_code :=
        PA_PROJECT_STRUCTURE_UTILS.GET_STRUCTURE_SHARING_CODE
            ( p_project_id => p_fp_cols_rec.x_project_id );
    IF l_stru_sharing_code <> 'SHARE_FULL' OR
       ( p_fp_cols_rec.x_gen_src_wp_version_id IS NULL AND
         p_fp_cols_rec.x_gen_src_plan_version_id IS NULL ) THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RETURN;
    END IF;

    /* Initialize l_src_version_id_tab and l_gen_etc_src_code_tab */
    l_src_version_id_tab(1) := p_fp_cols_rec.x_gen_src_wp_version_id;
    l_src_version_id_tab(2) := p_fp_cols_rec.x_gen_src_plan_version_id;
    l_gen_etc_src_code_tab(1) := 'WORKPLAN_RESOURCES';
    l_gen_etc_src_code_tab(2) := 'FINANCIAL_PLAN';

    FOR i IN 1..l_src_version_id_tab.count LOOP
        l_src_version_id := l_src_version_id_tab(i);
        IF l_src_version_id IS NOT NULL THEN
            --dbms_output.put_line('l_src_version_id = ' || l_src_version_id);
            /* CAll API to get Source data into l_fp_cols_rec_src */
	    IF p_pa_debug_mode = 'Y' THEN
	        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
	            ( p_msg         => 'Before calling PA_FP_GEN_AMOUNT_UTILS.' ||
                                       'GET_PLAN_VERSION_DTLS',
	              p_module_name => l_module_name,
	              p_log_level   => l_log_level );
	    END IF;
	    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                ( p_project_id        => p_fp_cols_rec.x_project_id,
		  p_budget_version_id => l_src_version_id,
		  x_fp_cols_rec       => l_fp_cols_rec_src,
		  x_return_status     => x_return_status,
		  x_msg_count         => x_msg_count,
		  x_msg_data          => x_msg_data );
	    IF p_pa_debug_mode = 'Y' THEN
	        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
	            ( p_msg         => 'Status after calling PA_FP_GEN_AMOUNT_UTILS.' ||
	                               'GET_PLAN_VERSION_DTLS: ' ||
	                               x_return_status,
	              p_module_name => l_module_name,
	              p_log_level   => l_log_level );
	    END IF;
	    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
	    END IF;

            IF ( p_fp_cols_rec.x_resource_list_id =
                 l_fp_cols_rec_src.x_resource_list_id ) AND
               ( p_fp_cols_rec.x_fin_plan_level_code =
                 l_fp_cols_rec_src.x_fin_plan_level_code ) AND
               NOT ( p_fp_cols_rec.x_time_phased_code <> 'N' AND
                     l_fp_cols_rec_src.x_time_phased_code = 'N' ) THEN

                l_gen_etc_src_code := l_gen_etc_src_code_tab(i);
                --dbms_output.put_line('l_gen_etc_src_code = ' || l_gen_etc_src_code);
                /* Pick up the source resource assignment attributes. */
                SELECT /*+ INDEX(map,PA_FP_CALC_AMT_TMP1_N1)*/
                       TMP1.TXN_RESOURCE_ASSIGNMENT_ID,
                       RA.RESOURCE_CLASS_FLAG,
                       RA.RESOURCE_CLASS_CODE,
                       RA.RES_TYPE_CODE,
                       RA.PERSON_ID,
                       RA.JOB_ID,
                       RA.PERSON_TYPE_CODE,
                       RA.NAMED_ROLE,
                       RA.BOM_RESOURCE_ID,
                       RA.NON_LABOR_RESOURCE,
                       RA.INVENTORY_ITEM_ID,
                       RA.ITEM_CATEGORY_ID,
                       RA.PROJECT_ROLE_ID,
                       RA.ORGANIZATION_ID,
                       RA.FC_RES_TYPE_CODE,
                       RA.EXPENDITURE_TYPE,
                       RA.EXPENDITURE_CATEGORY,
                       RA.EVENT_TYPE,
                       RA.REVENUE_CATEGORY_CODE,
                       RA.SUPPLIER_ID,
                       RA.SPREAD_CURVE_ID,
                       RA.SP_FIXED_DATE,
                       RA.MFC_COST_TYPE_ID,
                       RA.INCURRED_BY_RES_FLAG,
                       RA.INCUR_BY_RES_CLASS_CODE,
                       RA.INCUR_BY_ROLE_ID,
                       RA.RATE_EXPENDITURE_TYPE,
                       RA.RATE_EXP_FUNC_CURR_CODE,
                       RA.RATE_EXPENDITURE_ORG_ID,
                       RA.RESOURCE_RATE_BASED_FLAG  -- Added for IPM ER
        	BULK COLLECT
                INTO   l_tgt_res_asg_id_tab,
                       l_resource_class_flag_tab,
                       l_resource_class_code_tab,
                       l_res_type_code_tab,
                       l_person_id_tab,
                       l_job_id_tab,
                       l_person_type_code_tab,
                       l_named_role_tab,
                       l_bom_resource_id_tab,
                       l_non_labor_resource_tab,
                       l_inventory_item_id_tab,
                       l_item_category_id_tab,
                       l_project_role_id_tab,
                       l_organization_id_tab,
                       l_fc_res_type_code_tab,
                       l_expenditure_type_tab,
                       l_expenditure_category_tab,
                       l_event_type_tab,
                       l_revenue_category_code_tab,
                       l_supplier_id_tab,
                       l_spread_curve_id_tab,
                       l_sp_fixed_date_tab,
                       l_mfc_cost_type_id_tab,
                       l_incurred_by_res_flag_tab,
                       l_incur_by_res_cls_code_tab,
                       l_incur_by_role_id_tab,
                       l_rate_expenditure_type_tab,
                       l_rate_func_curr_code_tab,
                       l_org_id_tab,
                       l_res_rate_based_flag_tab  -- Added for IPM ER
                FROM   PA_RESOURCE_ASSIGNMENTS RA,
                       PA_RES_LIST_MAP_TMP1 tmp1,
                       PA_FP_CALC_AMT_TMP1 map
                WHERE  RA.budget_version_id = l_src_version_id
                AND    RA.resource_assignment_id = map.resource_assignment_id
                AND    map.target_res_asg_id = tmp1.txn_resource_assignment_id
                AND    map.transaction_source_code = l_gen_etc_src_code;

                --dbms_output.put_line('l_tgt_res_asg_id_tab.count = ' || l_tgt_res_asg_id_tab.count);
                l_sysdate := SYSDATE;

                FORALL j IN 1..l_tgt_res_asg_id_tab.count
                    UPDATE PA_RESOURCE_ASSIGNMENTS
                    SET    RESOURCE_CLASS_FLAG         = l_resource_class_flag_tab(j),
                           RESOURCE_CLASS_CODE         = l_resource_class_code_tab(j),
                           RES_TYPE_CODE               = l_res_type_code_tab(j),
                           PERSON_ID                   = l_person_id_tab(j),
                           JOB_ID                      = l_job_id_tab(j),
                           PERSON_TYPE_CODE            = l_person_type_code_tab(j),
                           NAMED_ROLE                  = l_named_role_tab(j),
                           BOM_RESOURCE_ID             = l_bom_resource_id_tab(j),
                           NON_LABOR_RESOURCE          = l_non_labor_resource_tab(j),
                           INVENTORY_ITEM_ID           = l_inventory_item_id_tab(j),
                           ITEM_CATEGORY_ID            = l_item_category_id_tab(j),
                           PROJECT_ROLE_ID             = l_project_role_id_tab(j),
                           ORGANIZATION_ID             = l_organization_id_tab(j),
                           FC_RES_TYPE_CODE            = l_fc_res_type_code_tab(j),
                           EXPENDITURE_TYPE            = l_expenditure_type_tab(j),
                           EXPENDITURE_CATEGORY        = l_expenditure_category_tab(j),
                           EVENT_TYPE                  = l_event_type_tab(j),
                           REVENUE_CATEGORY_CODE       = l_revenue_category_code_tab(j),
                           SUPPLIER_ID                 = l_supplier_id_tab(j),
                           SPREAD_CURVE_ID             = l_spread_curve_id_tab(j),
                           SP_FIXED_DATE               = l_sp_fixed_date_tab(j),
                           MFC_COST_TYPE_ID            = l_mfc_cost_type_id_tab(j),
                           INCURRED_BY_RES_FLAG        = l_incurred_by_res_flag_tab(j),
                           INCUR_BY_RES_CLASS_CODE     = l_incur_by_res_cls_code_tab(j),
                           INCUR_BY_ROLE_ID            = l_incur_by_role_id_tab(j),
                           RATE_EXPENDITURE_TYPE       = l_rate_expenditure_type_tab(j),
                           RATE_EXP_FUNC_CURR_CODE     = l_rate_func_curr_code_tab(j),
                           LAST_UPDATE_DATE            = l_sysdate,
                           LAST_UPDATED_BY             = l_last_updated_by,
                           LAST_UPDATE_LOGIN           = l_last_update_login,
                           RATE_EXPENDITURE_ORG_ID     = l_org_id_tab(j),
                           RESOURCE_RATE_BASED_FLAG    = l_res_rate_based_flag_tab(j) -- Added for IPM ER
                    WHERE  budget_version_id           = p_fp_cols_rec.x_budget_version_id
                    AND    resource_assignment_id      = l_tgt_res_asg_id_tab(j);

            END IF; -- copy attributes logic
        END IF; -- src id not null
    END LOOP;

    IF p_pa_debug_mode = 'Y' THEN
      	PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;
EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
            PA_INTERFACE_UTILS_PUB.GET_MESSAGES
                ( p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out );
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
        END IF;

        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF p_pa_debug_mode = 'Y' THEN
           PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Invalid Arguments Passed',
              p_module_name => l_module_name,
              p_log_level   => 5 );
	    PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(sqlerrm,1,240);
        FND_MSG_PUB.ADD_EXC_MSG
            ( p_pkg_name        => 'PA_FP_GEN_PUB',
              p_procedure_name  => 'COPY_SRC_ATTRS_TO_TARGET_FCST',
              p_error_text      => substr(sqlerrm,1,240) );

	IF p_pa_debug_mode = 'Y' THEN
           PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
            ( p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
              p_module_name => l_module_name,
              p_log_level   => 5 );
   	    PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END COPY_SRC_ATTRS_TO_TARGET_FCST;

END PA_FP_GEN_PUB;

/
