--------------------------------------------------------
--  DDL for Package Body PA_RLMI_RBS_MAP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RLMI_RBS_MAP_PUB" AS
/* $Header: PAFPUT3B.pls 120.4.12000000.2 2008/11/13 06:53:14 rthumma ship $ */

g_debug_flag  Varchar2(1) := NULL;
g_calling_context Varchar2(100) := Null;
g_commit_flag  Varchar2(1) := NULL;
g_project_id  Number := Null;
g_budget_version_id  Number := Null;
g_resource_list_id   Number := Null;
--This variable indicates whether to call the resource list mapping API or not.
g_call_res_list_mapping_api  VARCHAR2(1);
g_rbs_version_id     Number := Null;
g_res_numRecInserted     Number := Null;
g_rbs_numRecInserted     Number := Null;
G_DEBUG_CONTEXT      Varchar2(100) ;
 /* declaration of plsql tables  for populating resmap tmp */
g_txn_Id_sqltab            PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab ;
g_TXN_SOURCE_ID_sqlTab         PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab ;
g_TXN_SOURCE_TYPE_CODE_sqltab  PA_PLSQL_DATATYPES.Char30TabTyp := PA_PLSQL_DATATYPES.EmptyChar30Tab ;
g_PERSON_ID_sqltab             PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_JOB_ID_sqltab                PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_ORGANIZATION_ID_sqltab       PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_VENDOR_ID_sqltab             PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_EXPENDITURE_TYPE_sqltab      PA_PLSQL_DATATYPES.Char30TabTyp := PA_PLSQL_DATATYPES.EmptyChar30Tab;
g_EVENT_TYPE_sqltab            PA_PLSQL_DATATYPES.Char30TabTyp := PA_PLSQL_DATATYPES.EmptyChar30Tab;
g_NON_LABOR_RESOURCE_sqltab    PA_PLSQL_DATATYPES.Char20TabTyp := PA_PLSQL_DATATYPES.EmptyChar20Tab;
g_EXPENDITURE_CATEGORY_sqltab  PA_PLSQL_DATATYPES.Char30TabTyp := PA_PLSQL_DATATYPES.EmptyChar30Tab;
g_EXP_CATEGORY_ID_sqltab       PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_REVENUE_CATEGORY_CODE_sqltab PA_PLSQL_DATATYPES.Char30TabTyp := PA_PLSQL_DATATYPES.EmptyChar30Tab;
g_NLR_ORGANIZATION_ID_sqltab   PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_EVENT_CLASSIFICATION_sqltab  PA_PLSQL_DATATYPES.Char30TabTyp := PA_PLSQL_DATATYPES.EmptyChar30Tab;
g_SYS_LINK_FUNCTION_sqltab     PA_PLSQL_DATATYPES.Char30TabTyp := PA_PLSQL_DATATYPES.EmptyChar30Tab;
g_PROJECT_ROLE_ID_sqltab       PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_RESOURCE_CLASS_CODE_sqltab   PA_PLSQL_DATATYPES.Char30TabTyp := PA_PLSQL_DATATYPES.EmptyChar30Tab;
g_MFC_COST_TYPE_ID_sqltab      PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_RESOURCE_CLASS_FLAG_sqltab   PA_PLSQL_DATATYPES.Char1TabTyp  := PA_PLSQL_DATATYPES.EmptyChar1Tab;
g_FC_RES_TYPE_CODE_sqltab      PA_PLSQL_DATATYPES.Char30TabTyp := PA_PLSQL_DATATYPES.EmptyChar30Tab;
g_INVENTORY_ITEM_ID_sqltab     PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_ITEM_CATEGORY_ID_sqltab      PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_PERSON_TYPE_CODE_sqltab      PA_PLSQL_DATATYPES.Char30TabTyp := PA_PLSQL_DATATYPES.EmptyChar30Tab;
g_BOM_RESOURCE_ID_sqltab       PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_NAMED_ROLE_sqltab            PA_PLSQL_DATATYPES.Char80TabTyp:= PA_PLSQL_DATATYPES.EmptyChar80Tab;
g_INCURRED_BY_RES_FLAG_sqltab  PA_PLSQL_DATATYPES.Char1TabTyp  := PA_PLSQL_DATATYPES.EmptyChar1Tab;
g_RATE_BASED_FLAG_sqltab       PA_PLSQL_DATATYPES.Char1TabTyp  := PA_PLSQL_DATATYPES.EmptyChar1Tab;
g_TXN_TASK_ID_sqltab           PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_TXN_WBS_ELE_VER_ID_sqltab    PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_TXN_RBS_ELEMENT_ID_sqltab    PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_TXN_PLAN_START_DATE_sqltab   PA_PLSQL_DATATYPES.DateTabTyp   := PA_PLSQL_DATATYPES.EmptyDateTab ;
g_TXN_PLAN_END_DATE_sqltab     PA_PLSQL_DATATYPES.DateTabTyp   := PA_PLSQL_DATATYPES.EmptyDateTab;
    /* declatioin of System Tables */
g_txn_Id_systab            system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_TXN_SOURCE_ID_systab         system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_TXN_SOURCE_TYPE_CODE_systab  system.PA_VARCHAR2_30_TBL_TYPE  := system.PA_VARCHAR2_30_TBL_TYPE();
g_PERSON_ID_systab             system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_JOB_ID_systab                system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_ORGANIZATION_ID_systab       system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_VENDOR_ID_systab             system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_EXPENDITURE_TYPE_systab      system.PA_VARCHAR2_30_TBL_TYPE  := system.PA_VARCHAR2_30_TBL_TYPE();
g_EVENT_TYPE_systab            system.PA_VARCHAR2_30_TBL_TYPE  := system.PA_VARCHAR2_30_TBL_TYPE();
g_NON_LABOR_RESOURCE_systab    system.PA_VARCHAR2_20_TBL_TYPE  := system.PA_VARCHAR2_20_TBL_TYPE();
g_EXPENDITURE_CATEGORY_systab  system.PA_VARCHAR2_30_TBL_TYPE  := system.PA_VARCHAR2_30_TBL_TYPE();
g_EXP_CATEGORY_ID_systab       system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_REVENUE_CATEGORY_CODE_systab system.PA_VARCHAR2_30_TBL_TYPE  := system.PA_VARCHAR2_30_TBL_TYPE();
g_NLR_ORGANIZATION_ID_systab   system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_EVENT_CLASSIFICATION_systab  system.PA_VARCHAR2_30_TBL_TYPE  := system.PA_VARCHAR2_30_TBL_TYPE();
g_SYS_LINK_FUNCTION_systab     system.PA_VARCHAR2_30_TBL_TYPE  := system.PA_VARCHAR2_30_TBL_TYPE();
g_PROJECT_ROLE_ID_systab       system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_RESOURCE_CLASS_CODE_systab   system.PA_VARCHAR2_30_TBL_TYPE  := system.PA_VARCHAR2_30_TBL_TYPE();
g_MFC_COST_TYPE_ID_systab      system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_RESOURCE_CLASS_FLAG_systab   system.PA_VARCHAR2_1_TBL_TYPE   := system.PA_VARCHAR2_1_TBL_TYPE();
g_FC_RES_TYPE_CODE_systab      system.PA_VARCHAR2_30_TBL_TYPE  := system.PA_VARCHAR2_30_TBL_TYPE();
g_INVENTORY_ITEM_ID_systab     system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_ITEM_CATEGORY_ID_systab      system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_PERSON_TYPE_CODE_systab      system.PA_VARCHAR2_30_TBL_TYPE  := system.PA_VARCHAR2_30_TBL_TYPE();
g_BOM_RESOURCE_ID_systab       system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_NAMED_ROLE_systab            system.PA_VARCHAR2_80_TBL_TYPE := system.PA_VARCHAR2_80_TBL_TYPE();
g_INCURRED_BY_RES_FLAG_systab  system.PA_VARCHAR2_1_TBL_TYPE   := system.PA_VARCHAR2_1_TBL_TYPE();
g_RATE_BASED_FLAG_systab       system.PA_VARCHAR2_1_TBL_TYPE   := system.PA_VARCHAR2_1_TBL_TYPE();
g_TXN_TASK_ID_systab           system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_TXN_WBS_ELE_VER_ID_systab    system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_TXN_RBS_ELEMENT_ID_systab    system.PA_NUM_TBL_TYPE          := system.PA_NUM_TBL_TYPE();
g_TXN_PLAN_START_DATE_systab   system.PA_DATE_TBL_TYPE         := system.PA_DATE_TBL_TYPE();
g_TXN_PLAN_END_DATE_systab     system.PA_DATE_TBL_TYPE         := system.PA_DATE_TBL_TYPE();
    /*  OUT Plsql Variables */
gx_txn_source_id_sqltab     PA_PLSQL_DATATYPES.IdTabTyp       := PA_PLSQL_DATATYPES.EmptyIdTab;
g_res_map_reject_code_sqltab      PA_PLSQL_DATATYPES.Char30TabTyp := PA_PLSQL_DATATYPES.EmptyChar30Tab;
g_rbs_map_reject_code_sqltab      PA_PLSQL_DATATYPES.Char30TabTyp := PA_PLSQL_DATATYPES.EmptyChar30Tab;
g_res_list_member_id_sqltab       PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_rbs_element_id_sqltab           PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
g_txn_accum_header_id_sqltab      PA_PLSQL_DATATYPES.IdTabTyp     := PA_PLSQL_DATATYPES.EmptyIdTab;
    /* OUT System Variables */
gx_txn_source_id_systab     system.PA_NUM_TBL_TYPE      := system.PA_NUM_TBL_TYPE();
g_res_map_reject_code_systab   system.PA_VARCHAR2_30_TBL_TYPE   := system.PA_VARCHAR2_30_TBL_TYPE();
g_rbs_map_reject_code_systab   system.PA_VARCHAR2_30_TBL_TYPE   := system.PA_VARCHAR2_30_TBL_TYPE();
g_res_list_member_id_systab    system.PA_NUM_TBL_TYPE       := system.PA_NUM_TBL_TYPE();
g_rbs_element_id_systab        system.PA_NUM_TBL_TYPE       := system.PA_NUM_TBL_TYPE();
g_txn_accum_header_id_systab   system.PA_NUM_TBL_TYPE       := system.PA_NUM_TBL_TYPE();

/**
procedure calc_log(p_msg  varchar2) IS

        pragma autonomous_transaction ;
BEGIN
        --dbms_output.put_line(p_msg);
        --IF P_PA_DEBUG_MODE = 'Y' Then
            NULL;
            INSERT INTO PA_FP_CALCULATE_LOG
                (SESSIONID
                ,SEQ_NUMBER
                ,LOG_MESSAGE)
            VALUES
                (userenv('sessionid')
                ,HR.PAY_US_GARN_FEE_RULES_S.nextval
                ,substr(P_MSG,1,240)
                );
        --END IF;
        COMMIT;

end calc_log;
**/
PROCEDURE print_msg(p_debug_flag   varchar2
                   ,p_msg          varchar2
		   ,p_proc_name    varchar2 default NULL ) IS

    l_module varchar2(100) := 'PA_RLMI_RBS_MAP_PUB';
BEGIN
	--calc_log(p_msg);
	/* Bug fix:4403327 Enclose the Push_RBS_Version calls inside the debug flag */
        If p_debug_flag = 'Y' Then
        	PA_DEBUG.WRITE(x_module      => 'PA_RLMI_RBS_MAP_PUB.map_rlmi_rbs'
                              ,x_msg         => p_msg
                              ,x_log_level   => 3 );

	        If p_proc_name = 'Push_RBS_Version' Then
			PA_DEBUG.write_file('LOG',p_msg);
			PA_DEBUG.log_message(p_msg);
		End If;
	End If;
END print_msg;

/* This API initializes the required variables into global variables */
PROCEDURE Init_ReqdVariables(
        p_process_code    IN  varchar2
        ,p_project_id     IN  Number
        ,p_resource_list_id IN Number
        ,p_rbs_version_id   IN Number
        ,p_budget_version_id IN NUmber ) IS

    l_stage  varchar2(1000);
BEGIN
    l_stage := 'Begin Init_ReqdVariables';
    print_msg(g_debug_flag,l_stage);
    IF ((p_process_code = 'RES_MAP' and ( p_resource_list_id is NULL OR p_project_id is NULL) )
           OR
       (p_process_code = 'RBS_MAP' and p_rbs_version_id is NULL )
       OR
       (p_process_code in ('RES_RBS_MAP')
            and (p_resource_list_id is NULL OR p_rbs_version_id is NULL OR p_project_id is NULL ))
           ) Then
           If p_budget_version_id is NOT NULL Then
        l_stage := 'Fetch the res and Rbs Details for the given budget version';
        print_msg(g_debug_flag,l_stage);
                Select NVL(p_resource_list_id,bv.resource_list_id)
                      ,NVL(p_rbs_version_id,fp.rbs_version_id)
                      ,NVL(p_project_id,bv.project_id)
              ,bv.budget_version_id
                Into  g_resource_list_id
                     ,g_rbs_version_id
                     ,g_project_id
             ,g_budget_version_id
                From pa_budget_versions bv
            ,pa_proj_fp_options fp
                Where bv.budget_version_id = p_budget_version_id
        And   fp.fin_plan_version_id (+) = bv.budget_version_id
        and   rownum = 1;
          End If;

    Else
        l_stage := 'Fetch the project Details for the given budget version';
        print_msg(g_debug_flag,l_stage);
        If p_budget_version_id is NOT NULL and p_project_id is NULL Then
            Select NVL(p_project_id,project_id)
            Into g_project_id
            From pa_budget_versions
            Where budget_version_id = p_budget_version_id;
        Else
            g_project_id := p_project_id;
        End If;

        g_resource_list_id := p_resource_list_id;
        g_rbs_version_id := p_rbs_version_id;
        g_budget_version_id := p_budget_version_id;


    End If;
    l_stage := 'End Of Init_ReqdVariables';
    print_msg(g_debug_flag,l_stage);
EXCEPTION
    WHEN OTHERS THEN
        print_msg(g_debug_flag,l_stage||':'||SQLCODE||SQLERRM);
        RAISE;

END Init_ReqdVariables;

/* This API inserts records into RBS mapping tmp tables
 * the records will be inserted Based on calling mode
 */
PROCEDURE populate_rbsmap_tmp
        (p_budget_version_id    IN Number
        ,p_calling_mode         IN varchar2
        ,x_return_status        OUT NOCOPY  varchar2 ) IS

    l_stage  varchar2(1000);
BEGIN
    l_stage := 'Start of populate_rbsmap_tmp';
    print_msg(g_debug_flag,l_stage);
    /* Initialize the IN and OUT tmp tables */
    DELETE FROM pa_rbs_plans_in_tmp ;
    DELETE FROM pa_rbs_plans_out_tmp;
    If p_calling_mode = 'BUDGET_VERSION' Then
        l_stage := 'Inserting recrods into pa_rbs_plans_in_tmp for the budget version';
        print_msg(g_debug_flag,l_stage);
        INSERT INTO pa_rbs_plans_in_tmp
            (source_id
            ,person_id
            ,Job_id
            ,organization_id
            ,Supplier_id
            --,Expenditure_type_id
            --,Event_type_id
            --,Expenditure_category_id
            --,Non_labor_resource_id
            --,Resource_class_id
            ,Revenue_category_code
            ,Inventory_item_id
            ,Item_category_id
            ,Bom_labor_id
            ,Bom_equipment_id
            ,Role_id
            ,Person_type_code
            )
                SELECT ra.resource_assignment_id
            ,ra.person_id
            ,ra.job_id
            ,ra.organization_id
            ,ra.supplier_id
            --,et.expenditure_type_id
                        --,ev.event_type_id
                        --,ec.expenditure_category_id
            --,nlr.non_labor_resource_id
            --,rc.resource_class_id
            ,ra.revenue_category_code
            ,ra.inventory_item_id
            ,ra.item_category_id
            ,decode(ra.bom_resource_id,NULL,NULL,
                    decode(nvl(ra.incur_by_res_class_code,ra.resource_class_code),'PEOPLE',ra.bom_resource_id,NULL))
            ,decode(ra.bom_resource_id,NULL,NULL,
                    decode(nvl(ra.incur_by_res_class_code,ra.resource_class_code),'EQUIPMENT',ra.bom_resource_id,NULL))
                        ,nvl(ra.incur_by_role_id,ra.project_role_id)
            ,ra.person_type_code
                FROM pa_resource_assignments ra
                    --,pa_budget_versions bv
                    --,pa_proj_fp_options fp
            --,pa_expenditure_types et
            --,pa_non_labor_resources nlr
            --,pa_expenditure_categories ec
            --,pa_event_types ev
            --,pa_resource_classes_b rc
                WHERE ra.budget_version_id = p_budget_version_id
                --AND   ra.budget_version_id = bv.budget_version_id (+)
                --ANd   bv.budget_version_id = fp.fin_plan_version_id(+)
        --and   ra.expenditure_type = et.expenditure_type (+)
        --and   ra.non_labor_resource = nlr.non_labor_resource (+)
        --and   ra.expenditure_category = ec.expenditure_category (+)
        --and   ra.event_type = ev.event_type (+)
        --and   ra.resource_class_code = rc.resource_class_code (+)
        ;
        g_rbs_numRecInserted := sql%Rowcount ;
        l_stage := 'Num Of Records Inserted ['||g_rbs_numRecInserted||']';
        print_msg(g_debug_flag,l_stage);
        /* bug fix: 3678165 added this update commented out the outer join from insert */
        If g_rbs_numRecInserted > 0 Then
            l_stage := 'Update the tmp table with exp,event,cate,Ids';
            UPDATE pa_rbs_plans_in_tmp tmp
            SET tmp.expenditure_type_id = (select et.expenditure_type_id
                            from pa_expenditure_types et
                                ,pa_resource_assignments ra
                            where et.expenditure_type = ra.expenditure_type
                            and ra.resource_assignment_id = tmp.source_id
                            and rownum =1 )
            ,tmp.non_labor_resource_id = (select nlr.non_labor_resource_id
                            from pa_non_labor_resources nlr
                                ,pa_resource_assignments ra
                            where nlr.non_labor_resource = ra.non_labor_resource
                            and ra.resource_assignment_id = tmp.source_id
                            and rownum = 1)
            ,tmp.expenditure_category_id = (select ec.expenditure_category_id
                            from pa_expenditure_categories ec
                                ,pa_resource_assignments ra
                                                        where ec.expenditure_category = ra.expenditure_category
                                                        and ra.resource_assignment_id = tmp.source_id
                                                        and rownum = 1)
            ,tmp.event_type_id  = (select ev.event_type_id
                        from pa_event_types ev
                            ,pa_resource_assignments ra
                                                where ra.event_type = ev.event_type
                                                and ra.resource_assignment_id = tmp.source_id
                                                and rownum = 1)
            ,tmp.resource_class_id  = (select rc.resource_class_id
                                                from pa_resource_classes_b rc
                                                    ,pa_resource_assignments ra
                                                where nvl(ra.incur_by_res_class_code,ra.resource_class_code) = rc.resource_class_code
                                                and ra.resource_assignment_id = tmp.source_id
                                                and rownum = 1) ;

                 print_msg(g_debug_flag,'Number of rows updated on pa_rbs_plans_in_tmp['||sql%Rowcount||']');
        End IF;
    Elsif p_calling_mode = 'PLSQL_TABLE' Then
        l_stage := 'Inserting recrods into pa_rbs_plans_in_tmp from PLSQL tables';
        print_msg(g_debug_flag,l_stage);
        FORALL i IN g_txn_source_id_sqltab.FIRST .. g_txn_source_id_sqltab.LAST
                INSERT INTO pa_rbs_plans_in_tmp
                        (source_id
                        ,person_id
                        ,Job_id
                        ,organization_id
                        ,Supplier_id
                        ,Expenditure_type_id
                        ,Event_type_id
                        ,Expenditure_category_id
                        ,Revenue_category_code
                        ,Inventory_item_id
                        ,Item_category_id
                        ,Bom_labor_id
                        ,Bom_equipment_id
                        ,Non_labor_resource_id
                        ,Role_id
                        ,Person_type_code
                        ,Resource_class_id
                        )
                SELECT g_txn_source_id_sqltab(i)
            ,g_person_id_sqltab(i)
            ,g_job_id_sqltab(i)
            ,g_organization_id_sqltab(i)
            ,g_vendor_id_sqltab(i)
            ,NULL   --et.expenditure_type_id
                        ,NULL   --ev.event_type_id
                        ,NULL   --ec.expenditure_category_id
            ,g_revenue_category_code_sqltab(i)
            ,g_inventory_item_id_sqltab(i)
            ,g_item_category_id_sqltab(i)
            ,decode(g_bom_resource_id_sqltab(i),NULL,NULL,
                    decode(g_resource_class_code_sqltab(i),'PEOPLE',g_bom_resource_id_sqltab(i),NULL))
            ,decode(g_bom_resource_id_sqltab(i),NULL,NULL,
                    decode(g_resource_class_code_sqltab(i),'EQUIPMENT',g_bom_resource_id_sqltab(i),NULL))
            ,NULL   --nlr.non_labor_resource_id
                        ,g_project_role_id_sqltab(i)
            ,g_person_type_code_sqltab(i)
            ,NULL   --rc.resource_class_id
                FROM Dual ;

        g_rbs_numRecInserted := g_txn_source_id_sqltab.Count ;
        l_stage := 'Num Of Records Inserted ['||g_rbs_numRecInserted||']';
        print_msg(g_debug_flag,l_stage);
        FORALL i IN g_txn_source_id_sqltab.FIRST .. g_txn_source_id_sqltab.LAST
            UPDATE pa_rbs_plans_in_tmp tmp
            SET tmp.expenditure_type_id = (select et.expenditure_type_id
                            from pa_expenditure_types et
                            where et.expenditure_type = g_expenditure_type_sqltab(i))
            , tmp.non_labor_resource_id = (select nlr.non_labor_resource_id
                               from pa_non_labor_resources nlr
                            where nlr.non_labor_resource = g_non_labor_resource_sqltab(i))
            ,tmp.resource_class_id = (select rc.resource_class_id
                         from pa_resource_classes_b rc
                         where rc.resource_class_code = g_resource_class_code_sqltab(i) )
            ,tmp.expenditure_category_id = (select ec.expenditure_category_id
                            from pa_expenditure_categories ec
                            where ec.expenditure_category = g_expenditure_category_sqltab(i))
	    /* Bug fix: 3999186 populating event type */
	    ,tmp.event_type_id = (select evt.event_type_id
				from pa_event_types evt
				where evt.event_type = g_event_type_sqltab(i))
            WHERE tmp.source_id = g_txn_source_id_sqltab(i);

    Elsif p_calling_mode = 'SYSTEM_TABLE' Then
        l_stage := 'Inserting recrods into pa_rbs_plans_in_tmp from SYSTEM tables';
        print_msg(g_debug_flag,l_stage);
        FORALL i IN g_txn_source_id_systab.FIRST .. g_txn_source_id_systab.LAST
                INSERT INTO pa_rbs_plans_in_tmp
                        (source_id
                        ,person_id
                        ,Job_id
                        ,organization_id
                        ,Supplier_id
                        ,Expenditure_type_id
                        ,Event_type_id
                        ,Expenditure_category_id
                        ,Revenue_category_code
                        ,Inventory_item_id
                        ,Item_category_id
                        ,Bom_labor_id
                        ,Bom_equipment_id
                        ,Non_labor_resource_id
                        ,Role_id
                        ,Person_type_code
                        ,Resource_class_id
                        )
                SELECT g_txn_source_id_systab(i)
            ,g_person_id_systab(i)
            ,g_job_id_systab(i)
            ,g_organization_id_systab(i)
            ,g_vendor_id_systab(i)
            ,NULL   --et.expenditure_type_id
                        ,NULL   --ev.event_type_id
                        ,NULL   --ec.expenditure_category_id
            ,g_revenue_category_code_systab(i)
            ,g_inventory_item_id_systab(i)
            ,g_item_category_id_systab(i)
            ,decode(g_bom_resource_id_systab(i),NULL,NULL,
                    decode(g_resource_class_code_systab(i),'PEOPLE',g_bom_resource_id_systab(i),NULL))
            ,decode(g_bom_resource_id_systab(i),NULL,NULL,
                    decode(g_resource_class_code_systab(i),'EQUIPMENT',g_bom_resource_id_systab(i),NULL))
            ,NULL   --nlr.non_labor_resource_id
                        ,g_project_role_id_systab(i)
            ,g_person_type_code_systab(i)
            ,NULL   --rc.resource_class_id
                FROM Dual ;

        g_rbs_numRecInserted := g_txn_source_id_systab.count;
        l_stage := 'Num Of Records Inserted ['||g_rbs_numRecInserted||']';
        print_msg(g_debug_flag,l_stage);
        FORALL i IN g_txn_source_id_systab.FIRST .. g_txn_source_id_systab.LAST
            UPDATE pa_rbs_plans_in_tmp
            SET expenditure_type_id = (select et.expenditure_type_id
                            from pa_expenditure_types et
                            where et.expenditure_type = g_expenditure_type_systab(i))
            , non_labor_resource_id = (select nlr.non_labor_resource_id
                               from pa_non_labor_resources nlr
                            where nlr.non_labor_resource = g_non_labor_resource_systab(i))
            ,resource_class_id = (select rc.resource_class_id
                         from pa_resource_classes_b rc
                         where rc.resource_class_code = g_resource_class_code_systab(i) )
            ,expenditure_category_id = (select ec.expenditure_category_id
                            from pa_expenditure_categories ec
                            where ec.expenditure_category = g_expenditure_category_systab(i))
	    /* Bug fix: 3999186 populating event type */
            ,event_type_id = (select evt.event_type_id
                                from pa_event_types evt
                                where evt.event_type = g_event_type_systab(i))
            WHERE source_id = g_txn_source_id_systab(i);
    End If;

    /* Bug fix: 3698579 */
    -- update exp category id if null
        UPDATE pa_rbs_plans_in_tmp tmp
    SET tmp.expenditure_category_id = (select etc.expenditure_category_id
                                           from pa_expenditure_types et
                        ,pa_expenditure_categories etc
                                           where et.expenditure_type_id = tmp.expenditure_type_id
                       and et.expenditure_category = etc.expenditure_category
                                          )
        WHERE tmp.expenditure_category_id is NULL
    AND   tmp.expenditure_type_id is NOT NULL ;


	/* Bug fix: 3999186 populate revenue category based on event types */
    -- update revenue category if its null based on event types
        UPDATE pa_rbs_plans_in_tmp tmp
        SET tmp.Revenue_category_code  = (select et.Revenue_category_code
                                           from pa_event_types et
                                           where et.event_type_id = tmp.event_type_id
                                          )
        WHERE tmp.Revenue_category_code is NULL
        AND   tmp.event_type_id is NOT NULL ;
	/* end of Bug fix: 3999186 */

    -- update revenue category if its null based on expendiure types
        UPDATE pa_rbs_plans_in_tmp tmp
        SET tmp.Revenue_category_code  = (select et.Revenue_category_code
                                           from pa_expenditure_types et
                                           where et.expenditure_type_id = tmp.expenditure_type_id
                                          )
        WHERE tmp.Revenue_category_code is NULL
        AND   tmp.expenditure_type_id is NOT NULL ;

    -- update the default item category
    UPDATE pa_rbs_plans_in_tmp tmp
    SET tmp.item_category_id = ( SELECT cat.CATEGORY_ID
                    FROM PA_RESOURCE_CLASSES_B classes
                        ,PA_PLAN_RES_DEFAULTS  cls
                        ,MTL_ITEM_CATEGORIES  cat
                    WHERE classes.RESOURCE_CLASS_CODE = 'MATERIAL_ITEMS'
                    AND cls.RESOURCE_CLASS_ID      = classes.RESOURCE_CLASS_ID
                    AND cls.ITEM_CATEGORY_SET_ID    = cat.CATEGORY_SET_ID
                    AND cat.ORGANIZATION_ID = tmp.organization_id
                    AND cat.INVENTORY_ITEM_ID = tmp.inventory_item_id
                    AND rownum = 1
                   )
    WHERE tmp.item_category_id is NULL
    AND   tmp.inventory_item_id is NOT NULL;
    /* End of bug fix:3698579 */

    l_stage := 'End Of populate_rbsmap_tmp API';
    print_msg(g_debug_flag,l_stage);

EXCEPTION
    WHEN OTHERS THEN
        print_msg(g_debug_flag,l_stage||':'||SQLCODE||SQLERRM);
        RAISE;

END populate_rbsmap_tmp;

/* This API inserts records into Resource mapping tmp tables
 * the records will be inserted Based on calling mode
 */
PROCEDURE populate_resmap_tmp
    (p_budget_version_id    IN Number
    ,p_calling_mode         IN varchar2
    ,x_return_status    OUT NOCOPY varchar2 ) IS

    l_NumRecInserted         Number := 0;
    l_stage                  Varchar2(1000);
        l_struct_ver_id          pa_budget_versions.project_structure_version_id%TYPE;

    CURSOR Cur_projStrVer IS
        SELECT decode(nvl(wp_version_flag,'N'),
                  'N',PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID( project_id ),
                  project_structure_version_id)
        FROM   pa_budget_versions
        WHERE  budget_version_id = p_budget_version_id;
   l_uncategorized_flag             VARCHAR2(1);
   l_financial_res_class_rlm_id     pa_resource_list_members.resource_list_member_id%TYPE;
BEGIN

    l_NumRecInserted := 0;
    l_stage := 'Start of populate_resmap_tmp ';
    print_msg(g_debug_flag,l_stage);
    /* Initialize the IN and OUT tmp tables */
    DELETE FROM pa_res_list_map_tmp1;
    DELETE FROM pa_res_list_map_tmp4;


    IF p_budget_version_id is NOT NULL Then
        print_msg(g_debug_flag, 'Getting project structure version Id for ResMap');
            OPEN Cur_projStrVer;
        FETCH Cur_projStrVer INTO l_struct_ver_id;
        IF Cur_projStrVer%NOTFOUND Then
            l_struct_ver_id := NULL;
        End IF;
        CLOSE Cur_projStrVer;
    End If;

    SELECT nvl(uncategorized_flag,'N')
    INTO   l_uncategorized_flag
    FROM   pa_resource_lists_all_bg
    WHERE  resource_list_id=g_resource_list_id;

    g_call_res_list_mapping_api := 'Y';
    IF l_uncategorized_flag = 'Y' THEN

        l_financial_res_class_rlm_id := PA_FP_GEN_AMOUNT_UTILS.GET_RLM_ID
                                                               (p_project_id          => g_project_id,
                                                                p_resource_list_id    => g_resource_list_id,
                                                                p_resource_class_code => 'FINANCIAL_ELEMENTS' );
        g_call_res_list_mapping_api := 'N';

    END IF;

    --If the target is an uncategorized resource list then all the source resource list members would be mapped
    --to financial class resource list member in the target. In this case resource list mapping API will not be
    --called and tmp4 table will be populated directly

    l_stage := 'l_uncategorized_flag IS '||l_uncategorized_flag;
    print_msg(g_debug_flag,l_stage);

    IF p_calling_mode = 'BUDGET_VERSION' Then
           l_stage := 'Inserting recrods into pa_res_list_map_tmp1 for the given budget version';
           print_msg(g_debug_flag,l_stage);
           IF l_uncategorized_flag = 'Y' THEN

               INSERT INTO pa_res_list_map_tmp4
                    (TXN_SOURCE_ID
                    ,TXN_SOURCE_TYPE_CODE
                    ,PERSON_ID
                    ,JOB_ID
                    ,ORGANIZATION_ID
                    ,VENDOR_ID
                    ,EXPENDITURE_TYPE
                    --,EXPENDITURE_TYPE_ID
                    ,EVENT_TYPE
                    --,EVENT_TYPE_ID
                    ,NON_LABOR_RESOURCE
                    --,NON_LABOR_RESOURCE_ID
                    ,EXPENDITURE_CATEGORY
                    --,EXPENDITURE_CATEGORY_ID
                    ,REVENUE_CATEGORY
                    ,NON_LABOR_RESOURCE_ORG_ID
                    ,EVENT_TYPE_CLASSIFICATION
                    ,SYSTEM_LINKAGE_FUNCTION
                    ,PROJECT_ROLE_ID
                    ,RESOURCE_CLASS_CODE
                    ,MFC_COST_TYPE_ID
                    ,RESOURCE_CLASS_FLAG
                    ,FC_RES_TYPE_CODE
                    ,INVENTORY_ITEM_ID
                    ,ITEM_CATEGORY_ID
                    ,PERSON_TYPE_CODE
                    ,BOM_RESOURCE_ID
                    ,BOM_LABOR_RESOURCE_ID
                    ,BOM_EQUIP_RESOURCE_ID
                    ,NAMED_ROLE
                    --,NAMED_ROLE_ID
                    ,INCURRED_BY_RES_FLAG
                    ,TXN_RATE_BASED_FLAG
                    ,TXN_TASK_ID
                    ,TXN_WBS_ELEMENT_VERSION_ID
                    ,TXN_RBS_ELEMENT_ID
                    ,TXN_PLANNING_START_DATE
                    ,TXN_PLANNING_END_DATE
                    ,TXN_PROJECT_ID
                    ,TXN_BUDGET_VERSION_ID
                    ,resource_list_member_id)
                SELECT ra.resource_assignment_id
                    ,'RES_ASSIGNMENT'
                    ,PERSON_ID
                    ,JOB_ID
                    ,ORGANIZATION_ID
                    ,SUPPLIER_ID    VENDOR_ID
                    -- bug fix: 3698197 ,NVL(EXPENDITURE_TYPE,RATE_EXPENDITURE_TYPE)
                    ,EXPENDITURE_TYPE
                    --,Null         EXPENDITURE_TYPE_ID
                    ,EVENT_TYPE
                    --,Null         EVENT_TYPE_ID
                    ,NON_LABOR_RESOURCE
                    --,Null     NON_LABOR_RESOURCE_ID
                    ,EXPENDITURE_CATEGORY
                    --,Null     EXPENDITURE_CATEGORY_ID
                    ,REVENUE_CATEGORY_CODE
                    ,Null       NLR_ORGANIZATION_ID
                    ,Null       EVENT_CLASSIFICATION
                    ,Null       SYS_LINK_FUNCTION
                    ,NVL(incur_by_role_id,PROJECT_ROLE_ID)
                    ,NVL(incur_by_res_class_code,RESOURCE_CLASS_CODE)
                    ,MFC_COST_TYPE_ID
                    ,RESOURCE_CLASS_FLAG
                    ,FC_RES_TYPE_CODE
                    ,INVENTORY_ITEM_ID
                    ,ITEM_CATEGORY_ID
                    ,PERSON_TYPE_CODE
                    ,BOM_RESOURCE_ID
                    ,decode(bom_resource_id,NULL,NULL,
                        decode(nvl(incur_by_res_class_code,RESOURCE_CLASS_CODE),'PEOPLE',BOM_RESOURCE_ID,NULL))
                    ,decode(bom_resource_id,NULL,NULL,
                        decode(nvl(incur_by_res_class_code,RESOURCE_CLASS_CODE),'EQUIPMENT',BOM_RESOURCE_ID,NULL))
                    ,NAMED_ROLE
                    --,Null         NAMED_ROLE_ID
                    ,INCURRED_BY_RES_FLAG
                    ,RATE_BASED_FLAG
                    ,TASK_ID
                    ,NULL --pelm.element_version_id
                    ,RBS_ELEMENT_ID
                    ,PLANNING_START_DATE
                    ,PLANNING_END_DATE
                    ,ra.project_id
                    ,ra.budget_version_id
                    ,l_financial_res_class_rlm_id
            FROM pa_resource_assignments ra
            WHERE ra.budget_version_id = p_budget_version_id;

           ELSE

               INSERT INTO pa_res_list_map_tmp1
                    (TXN_SOURCE_ID
                    ,TXN_SOURCE_TYPE_CODE
                    ,PERSON_ID
                    ,JOB_ID
                    ,ORGANIZATION_ID
                    ,VENDOR_ID
                    ,EXPENDITURE_TYPE
                    --,EXPENDITURE_TYPE_ID
                    ,EVENT_TYPE
                    --,EVENT_TYPE_ID
                    ,NON_LABOR_RESOURCE
                    --,NON_LABOR_RESOURCE_ID
                    ,EXPENDITURE_CATEGORY
                    --,EXPENDITURE_CATEGORY_ID
                    ,REVENUE_CATEGORY
                    ,NON_LABOR_RESOURCE_ORG_ID
                    ,EVENT_TYPE_CLASSIFICATION
                    ,SYSTEM_LINKAGE_FUNCTION
                    ,PROJECT_ROLE_ID
                    ,RESOURCE_CLASS_CODE
                    ,MFC_COST_TYPE_ID
                    ,RESOURCE_CLASS_FLAG
                    ,FC_RES_TYPE_CODE
                    ,INVENTORY_ITEM_ID
                    ,ITEM_CATEGORY_ID
                    ,PERSON_TYPE_CODE
                    ,BOM_RESOURCE_ID
                    ,BOM_LABOR_RESOURCE_ID
                    ,BOM_EQUIP_RESOURCE_ID
                    ,NAMED_ROLE
                    --,NAMED_ROLE_ID
                    ,INCURRED_BY_RES_FLAG
                    ,TXN_RATE_BASED_FLAG
                    ,TXN_TASK_ID
                    ,TXN_WBS_ELEMENT_VERSION_ID
                    ,TXN_RBS_ELEMENT_ID
                    ,TXN_PLANNING_START_DATE
                    ,TXN_PLANNING_END_DATE
                    ,TXN_PROJECT_ID
                    ,TXN_BUDGET_VERSION_ID )
            SELECT ra.resource_assignment_id
                    ,'RES_ASSIGNMENT'
                    ,PERSON_ID
                    ,JOB_ID
                    ,ORGANIZATION_ID
                    ,SUPPLIER_ID    VENDOR_ID
                    -- bug fix: 3698197 ,NVL(EXPENDITURE_TYPE,RATE_EXPENDITURE_TYPE)
                    ,EXPENDITURE_TYPE
                    --,Null         EXPENDITURE_TYPE_ID
                    ,EVENT_TYPE
                    --,Null         EVENT_TYPE_ID
                    ,NON_LABOR_RESOURCE
                    --,Null     NON_LABOR_RESOURCE_ID
                    ,EXPENDITURE_CATEGORY
                    --,Null     EXPENDITURE_CATEGORY_ID
                    ,REVENUE_CATEGORY_CODE
                    ,Null       NLR_ORGANIZATION_ID
                    ,Null       EVENT_CLASSIFICATION
                    ,Null       SYS_LINK_FUNCTION
                    ,NVL(incur_by_role_id,PROJECT_ROLE_ID)
                    ,NVL(incur_by_res_class_code,RESOURCE_CLASS_CODE)
                    ,MFC_COST_TYPE_ID
                    ,RESOURCE_CLASS_FLAG
                    ,FC_RES_TYPE_CODE
                    ,INVENTORY_ITEM_ID
                    ,ITEM_CATEGORY_ID
                    ,PERSON_TYPE_CODE
                    ,BOM_RESOURCE_ID
                    ,decode(bom_resource_id,NULL,NULL,
                        decode(nvl(incur_by_res_class_code,RESOURCE_CLASS_CODE),'PEOPLE',BOM_RESOURCE_ID,NULL))
                    ,decode(bom_resource_id,NULL,NULL,
                        decode(nvl(incur_by_res_class_code,RESOURCE_CLASS_CODE),'EQUIPMENT',BOM_RESOURCE_ID,NULL))
                    ,NAMED_ROLE
                    --,Null         NAMED_ROLE_ID
                    ,INCURRED_BY_RES_FLAG
                    ,RATE_BASED_FLAG
                    ,TASK_ID
                    ,NULL --pelm.element_version_id
                    ,RBS_ELEMENT_ID
                    ,PLANNING_START_DATE
                    ,PLANNING_END_DATE
                    ,ra.project_id
                    ,ra.budget_version_id
            FROM pa_resource_assignments ra
            WHERE ra.budget_version_id = p_budget_version_id;

        END IF;

        l_NumRecInserted := sql%Rowcount;
        g_res_numRecInserted := l_NumRecInserted ;
        l_stage := 'Num of Records inserted ['||g_res_numRecInserted||']';
        print_msg(g_debug_flag,l_stage);
    Elsif p_calling_mode = 'PLSQL_TABLE' Then

        /* Insert these plsql tables into ResMap Temp Tables*/
        If g_TXN_SOURCE_ID_sqltab.COUNT > 0 Then

            IF l_uncategorized_flag = 'Y' THEN
                l_stage := 'Inserting records into pa_res_list_map_tmp4 from PLSQL tables';
                print_msg(g_debug_flag,l_stage);
                FORALL i IN g_TXN_SOURCE_ID_sqltab.FIRST .. g_TXN_SOURCE_ID_sqltab.LAST
                    INSERT INTO pa_res_list_map_tmp4
                        (TXN_SOURCE_ID
                        ,TXN_SOURCE_TYPE_CODE
                        ,PERSON_ID
                        ,JOB_ID
                        ,ORGANIZATION_ID
                        ,VENDOR_ID
                        ,EXPENDITURE_TYPE
                        --,EXPENDITURE_TYPE_ID
                        ,EVENT_TYPE
                        --,EVENT_TYPE_ID
                        ,NON_LABOR_RESOURCE
                        --,NON_LABOR_RESOURCE_ID
                        ,EXPENDITURE_CATEGORY
                        --,EXPENDITURE_CATEGORY_ID
                        ,REVENUE_CATEGORY
                        ,NON_LABOR_RESOURCE_ORG_ID
                        ,EVENT_TYPE_CLASSIFICATION
                        ,SYSTEM_LINKAGE_FUNCTION
                        ,PROJECT_ROLE_ID
                        ,RESOURCE_CLASS_CODE
                        ,MFC_COST_TYPE_ID
                        ,RESOURCE_CLASS_FLAG
                        ,FC_RES_TYPE_CODE
                        ,INVENTORY_ITEM_ID
                        ,ITEM_CATEGORY_ID
                        ,PERSON_TYPE_CODE
                        ,BOM_RESOURCE_ID
                        ,BOM_LABOR_RESOURCE_ID
                        ,BOM_EQUIP_RESOURCE_ID
                        ,NAMED_ROLE
                        --,NAMED_ROLE_ID
                        ,INCURRED_BY_RES_FLAG
                        ,TXN_RATE_BASED_FLAG
                        ,TXN_TASK_ID
                        ,TXN_WBS_ELEMENT_VERSION_ID
                        ,TXN_RBS_ELEMENT_ID
                        ,TXN_PLANNING_START_DATE
                        ,TXN_PLANNING_END_DATE
                        ,TXN_PROJECT_ID
                        ,TXN_BUDGET_VERSION_ID
                        ,resource_list_member_id)
                      SELECT g_TXN_SOURCE_ID_sqltab(i)
                        ,g_TXN_SOURCE_TYPE_CODE_sqltab(i)
                        ,g_PERSON_ID_sqltab(i)
                        ,g_JOB_ID_sqltab(i)
                        ,g_ORGANIZATION_ID_sqltab(i)
                        ,g_VENDOR_ID_sqltab(i)
                        ,g_EXPENDITURE_TYPE_sqltab(i)
                        --,g_EXPENDITURE_TYPE_ID_sqltab(i)
                        ,g_EVENT_TYPE_sqltab(i)
                        --,g_EVENT_TYPE_ID_sqltab(i)
                        ,g_NON_LABOR_RESOURCE_sqltab(i)
                        --,g_NON_LABOR_RESOURCE_ID_sqltab(i)
                        ,g_EXPENDITURE_CATEGORY_sqltab(i)
                        --,g_EXP_CATEGORY_ID_sqltab(i)
                        ,g_REVENUE_CATEGORY_CODE_sqltab(i)
                        ,g_NLR_ORGANIZATION_ID_sqltab(i)
                        ,g_EVENT_CLASSIFICATION_sqltab(i)
                        ,g_SYS_LINK_FUNCTION_sqltab(i)
                        ,g_PROJECT_ROLE_ID_sqltab(i)
                        ,g_RESOURCE_CLASS_CODE_sqltab(i)
                        ,g_MFC_COST_TYPE_ID_sqltab(i)
                        ,g_RESOURCE_CLASS_FLAG_sqltab(i)
                        ,g_FC_RES_TYPE_CODE_sqltab(i)
                        ,g_INVENTORY_ITEM_ID_sqltab(i)
                        ,g_ITEM_CATEGORY_ID_sqltab(i)
                        ,g_PERSON_TYPE_CODE_sqltab(i)
                        ,g_BOM_RESOURCE_ID_sqltab(i)
                        ,decode(g_BOM_RESOURCE_ID_sqltab(i),NULL,NULL,
                            decode(g_RESOURCE_CLASS_CODE_sqltab(i),'PEOPLE',g_BOM_RESOURCE_ID_sqltab(i),NULL))
                         ,decode(g_BOM_RESOURCE_ID_sqltab(i),NULL,NULL,
                            decode(g_RESOURCE_CLASS_CODE_sqltab(i),'EQUIPMENT',g_BOM_RESOURCE_ID_sqltab(i),NULL))
                        ,g_NAMED_ROLE_sqltab(i)
                        --,g_NAMED_ROLE_ID_sqltab(i)
                        ,g_INCURRED_BY_RES_FLAG_sqltab(i)
                        ,g_RATE_BASED_FLAG_sqltab(i)
                        ,g_TXN_TASK_ID_sqltab(i)
                        ,g_TXN_WBS_ELE_VER_ID_sqltab(i)
                        ,g_TXN_RBS_ELEMENT_ID_sqltab(i)
                        ,g_TXN_PLAN_START_DATE_sqltab(i)
                        ,g_TXN_PLAN_END_DATE_sqltab (i)
                        ,g_PROJECT_ID
                        ,g_BUDGET_VERSION_ID
                        ,l_financial_res_class_rlm_id
                       FROM DUAL;

            ELSE --    IF l_uncategorized_flag = 'Y' THEN
                l_stage := 'Inserting records into pa_res_list_map_tmp1 from PLSQL tables';
                print_msg(g_debug_flag,l_stage);
                FORALL i IN g_TXN_SOURCE_ID_sqltab.FIRST .. g_TXN_SOURCE_ID_sqltab.LAST
                    INSERT INTO pa_res_list_map_tmp1
                        (TXN_SOURCE_ID
                        ,TXN_SOURCE_TYPE_CODE
                        ,PERSON_ID
                        ,JOB_ID
                        ,ORGANIZATION_ID
                        ,VENDOR_ID
                        ,EXPENDITURE_TYPE
                        --,EXPENDITURE_TYPE_ID
                        ,EVENT_TYPE
                        --,EVENT_TYPE_ID
                        ,NON_LABOR_RESOURCE
                        --,NON_LABOR_RESOURCE_ID
                        ,EXPENDITURE_CATEGORY
                        --,EXPENDITURE_CATEGORY_ID
                        ,REVENUE_CATEGORY
                        ,NON_LABOR_RESOURCE_ORG_ID
                        ,EVENT_TYPE_CLASSIFICATION
                        ,SYSTEM_LINKAGE_FUNCTION
                        ,PROJECT_ROLE_ID
                        ,RESOURCE_CLASS_CODE
                        ,MFC_COST_TYPE_ID
                        ,RESOURCE_CLASS_FLAG
                        ,FC_RES_TYPE_CODE
                        ,INVENTORY_ITEM_ID
                        ,ITEM_CATEGORY_ID
                        ,PERSON_TYPE_CODE
                        ,BOM_RESOURCE_ID
                        ,BOM_LABOR_RESOURCE_ID
                        ,BOM_EQUIP_RESOURCE_ID
                        ,NAMED_ROLE
                        --,NAMED_ROLE_ID
                        ,INCURRED_BY_RES_FLAG
                        ,TXN_RATE_BASED_FLAG
                        ,TXN_TASK_ID
                        ,TXN_WBS_ELEMENT_VERSION_ID
                        ,TXN_RBS_ELEMENT_ID
                        ,TXN_PLANNING_START_DATE
                        ,TXN_PLANNING_END_DATE
                        ,TXN_PROJECT_ID
                        ,TXN_BUDGET_VERSION_ID )
                      SELECT g_TXN_SOURCE_ID_sqltab(i)
                        ,g_TXN_SOURCE_TYPE_CODE_sqltab(i)
                        ,g_PERSON_ID_sqltab(i)
                        ,g_JOB_ID_sqltab(i)
                        ,g_ORGANIZATION_ID_sqltab(i)
                        ,g_VENDOR_ID_sqltab(i)
                        ,g_EXPENDITURE_TYPE_sqltab(i)
                        --,g_EXPENDITURE_TYPE_ID_sqltab(i)
                        ,g_EVENT_TYPE_sqltab(i)
                        --,g_EVENT_TYPE_ID_sqltab(i)
                        ,g_NON_LABOR_RESOURCE_sqltab(i)
                        --,g_NON_LABOR_RESOURCE_ID_sqltab(i)
                        ,g_EXPENDITURE_CATEGORY_sqltab(i)
                        --,g_EXP_CATEGORY_ID_sqltab(i)
                        ,g_REVENUE_CATEGORY_CODE_sqltab(i)
                        ,g_NLR_ORGANIZATION_ID_sqltab(i)
                        ,g_EVENT_CLASSIFICATION_sqltab(i)
                        ,g_SYS_LINK_FUNCTION_sqltab(i)
                        ,g_PROJECT_ROLE_ID_sqltab(i)
                        ,g_RESOURCE_CLASS_CODE_sqltab(i)
                        ,g_MFC_COST_TYPE_ID_sqltab(i)
                        ,g_RESOURCE_CLASS_FLAG_sqltab(i)
                        ,g_FC_RES_TYPE_CODE_sqltab(i)
                        ,g_INVENTORY_ITEM_ID_sqltab(i)
                        ,g_ITEM_CATEGORY_ID_sqltab(i)
                        ,g_PERSON_TYPE_CODE_sqltab(i)
                        ,g_BOM_RESOURCE_ID_sqltab(i)
                        ,decode(g_BOM_RESOURCE_ID_sqltab(i),NULL,NULL,
                            decode(g_RESOURCE_CLASS_CODE_sqltab(i),'PEOPLE',g_BOM_RESOURCE_ID_sqltab(i),NULL))
                        ,decode(g_BOM_RESOURCE_ID_sqltab(i),NULL,NULL,
                            decode(g_RESOURCE_CLASS_CODE_sqltab(i),'EQUIPMENT',g_BOM_RESOURCE_ID_sqltab(i),NULL))
                        ,g_NAMED_ROLE_sqltab(i)
                        --,g_NAMED_ROLE_ID_sqltab(i)
                        ,g_INCURRED_BY_RES_FLAG_sqltab(i)
                        ,g_RATE_BASED_FLAG_sqltab(i)
                        ,g_TXN_TASK_ID_sqltab(i)
                        ,g_TXN_WBS_ELE_VER_ID_sqltab(i)
                        ,g_TXN_RBS_ELEMENT_ID_sqltab(i)
                        ,g_TXN_PLAN_START_DATE_sqltab(i)
                        ,g_TXN_PLAN_END_DATE_sqltab (i)
                        ,g_PROJECT_ID
                        ,g_BUDGET_VERSION_ID
                       FROM DUAL;
            END IF;    --    IF l_uncategorized_flag = 'Y' THEN
            l_NumRecInserted := sql%Rowcount;
            g_res_numRecInserted := l_NumRecInserted;

            l_stage := 'Num of Records inserted ['||g_res_numRecInserted||']';
            print_msg(g_debug_flag,l_stage);
        End If;--If g_TXN_SOURCE_ID_sqltab.COUNT > 0 Then

    Elsif p_calling_mode = 'SYSTEM_TABLE' Then
        /* Insert these system.tab into ResMap Temp Tables*/
        If g_TXN_SOURCE_ID_systab.COUNT > 0 Then
            IF l_uncategorized_flag = 'Y' THEN

                 l_stage := 'Inserting records into pa_res_list_map_tmp4  from SYSTEM tables';
                 print_msg(g_debug_flag,l_stage);
                 FORALL i IN g_TXN_SOURCE_ID_systab.FIRST .. g_TXN_SOURCE_ID_systab.LAST
                     INSERT INTO pa_res_list_map_tmp4
                        (TXN_SOURCE_ID
                        ,TXN_SOURCE_TYPE_CODE
                        ,PERSON_ID
                        ,JOB_ID
                        ,ORGANIZATION_ID
                        ,VENDOR_ID
                        ,EXPENDITURE_TYPE
                        --,EXPENDITURE_TYPE_ID
                        ,EVENT_TYPE
                        --,EVENT_TYPE_ID
                        ,NON_LABOR_RESOURCE
                        --,NON_LABOR_RESOURCE_ID
                        ,EXPENDITURE_CATEGORY
                        --,EXPENDITURE_CATEGORY_ID
                        ,REVENUE_CATEGORY
                        ,NON_LABOR_RESOURCE_ORG_ID
                        ,EVENT_TYPE_CLASSIFICATION
                        ,SYSTEM_LINKAGE_FUNCTION
                        ,PROJECT_ROLE_ID
                        ,RESOURCE_CLASS_CODE
                        ,MFC_COST_TYPE_ID
                        ,RESOURCE_CLASS_FLAG
                        ,FC_RES_TYPE_CODE
                        ,INVENTORY_ITEM_ID
                        ,ITEM_CATEGORY_ID
                        ,PERSON_TYPE_CODE
                        ,BOM_RESOURCE_ID
                        ,BOM_LABOR_RESOURCE_ID
                        ,BOM_EQUIP_RESOURCE_ID
                        ,NAMED_ROLE
                        --,NAMED_ROLE_ID
                        ,INCURRED_BY_RES_FLAG
                        ,TXN_RATE_BASED_FLAG
                        ,TXN_TASK_ID
                        ,TXN_WBS_ELEMENT_VERSION_ID
                        ,TXN_RBS_ELEMENT_ID
                        ,TXN_PLANNING_START_DATE
                        ,TXN_PLANNING_END_DATE
                        ,TXN_PROJECT_ID
                        ,TXN_BUDGET_VERSION_ID
                        ,resource_list_member_id)
                     SELECT g_TXN_SOURCE_ID_systab(i)
                        ,g_TXN_SOURCE_TYPE_CODE_systab(i)
                        ,g_PERSON_ID_systab(i)
                        ,g_JOB_ID_systab(i)
                        ,g_ORGANIZATION_ID_systab(i)
                        ,g_VENDOR_ID_systab(i)
                        ,g_EXPENDITURE_TYPE_systab(i)
                        --,g_EXPENDITURE_TYPE_ID_systab(i)
                        ,g_EVENT_TYPE_systab(i)
                        --,g_EVENT_TYPE_ID_systab(i)
                        ,g_NON_LABOR_RESOURCE_systab(i)
                        --,g_NON_LABOR_RESOURCE_ID_systab(i)
                        ,g_EXPENDITURE_CATEGORY_systab(i)
                        --,g_EXP_CATEGORY_ID_systab(i)
                        ,g_REVENUE_CATEGORY_CODE_systab(i)
                        ,g_NLR_ORGANIZATION_ID_systab(i)
                        ,g_EVENT_CLASSIFICATION_systab(i)
                        ,g_SYS_LINK_FUNCTION_systab(i)
                        ,g_PROJECT_ROLE_ID_systab(i)
                        ,g_RESOURCE_CLASS_CODE_systab(i)
                        ,g_MFC_COST_TYPE_ID_systab(i)
                        ,g_RESOURCE_CLASS_FLAG_systab(i)
                        ,g_FC_RES_TYPE_CODE_systab(i)
                        ,g_INVENTORY_ITEM_ID_systab(i)
                        ,g_ITEM_CATEGORY_ID_systab(i)
                        ,g_PERSON_TYPE_CODE_systab(i)
                        ,g_BOM_RESOURCE_ID_systab(i)
                        ,decode(g_BOM_RESOURCE_ID_systab(i),NULL,NULL,
                            decode(g_RESOURCE_CLASS_CODE_systab(i),'PEOPLE',g_BOM_RESOURCE_ID_systab(i),NULL))
                        ,decode(g_BOM_RESOURCE_ID_systab(i),NULL,NULL,
                            decode(g_RESOURCE_CLASS_CODE_systab(i),'EQUIPMENT',g_BOM_RESOURCE_ID_systab(i),NULL))
                        ,g_NAMED_ROLE_systab(i)
                        --,g_NAMED_ROLE_ID_systab(i)
                        ,g_INCURRED_BY_RES_FLAG_systab(i)
                        ,g_RATE_BASED_FLAG_systab(i)
                        ,g_TXN_TASK_ID_systab(i)
                        ,g_TXN_WBS_ELE_VER_ID_systab(i)
                        ,g_TXN_RBS_ELEMENT_ID_systab(i)
                        ,g_TXN_PLAN_START_DATE_systab(i)
                        ,g_TXN_PLAN_END_DATE_systab (i)
                        ,g_PROJECT_ID
                        ,g_BUDGET_VERSION_ID
                        ,l_financial_res_class_rlm_id
                     FROM DUAL;

            ELSE--IF l_uncategorized_flag = 'Y' THEN

                 l_stage := 'Inserting records into pa_res_list_map_tmp1  from SYSTEM tables';
                 print_msg(g_debug_flag,l_stage);
                 FORALL i IN g_TXN_SOURCE_ID_systab.FIRST .. g_TXN_SOURCE_ID_systab.LAST
                     INSERT INTO pa_res_list_map_tmp1
                        (TXN_SOURCE_ID
                        ,TXN_SOURCE_TYPE_CODE
                        ,PERSON_ID
                        ,JOB_ID
                        ,ORGANIZATION_ID
                        ,VENDOR_ID
                        ,EXPENDITURE_TYPE
                        --,EXPENDITURE_TYPE_ID
                        ,EVENT_TYPE
                        --,EVENT_TYPE_ID
                        ,NON_LABOR_RESOURCE
                        --,NON_LABOR_RESOURCE_ID
                        ,EXPENDITURE_CATEGORY
                        --,EXPENDITURE_CATEGORY_ID
                        ,REVENUE_CATEGORY
                        ,NON_LABOR_RESOURCE_ORG_ID
                        ,EVENT_TYPE_CLASSIFICATION
                        ,SYSTEM_LINKAGE_FUNCTION
                        ,PROJECT_ROLE_ID
                        ,RESOURCE_CLASS_CODE
                        ,MFC_COST_TYPE_ID
                        ,RESOURCE_CLASS_FLAG
                        ,FC_RES_TYPE_CODE
                        ,INVENTORY_ITEM_ID
                        ,ITEM_CATEGORY_ID
                        ,PERSON_TYPE_CODE
                        ,BOM_RESOURCE_ID
                        ,BOM_LABOR_RESOURCE_ID
                        ,BOM_EQUIP_RESOURCE_ID
                        ,NAMED_ROLE
                        --,NAMED_ROLE_ID
                        ,INCURRED_BY_RES_FLAG
                        ,TXN_RATE_BASED_FLAG
                        ,TXN_TASK_ID
                        ,TXN_WBS_ELEMENT_VERSION_ID
                        ,TXN_RBS_ELEMENT_ID
                        ,TXN_PLANNING_START_DATE
                        ,TXN_PLANNING_END_DATE
                        ,TXN_PROJECT_ID
                        ,TXN_BUDGET_VERSION_ID )
                     SELECT g_TXN_SOURCE_ID_systab(i)
                        ,g_TXN_SOURCE_TYPE_CODE_systab(i)
                        ,g_PERSON_ID_systab(i)
                        ,g_JOB_ID_systab(i)
                        ,g_ORGANIZATION_ID_systab(i)
                        ,g_VENDOR_ID_systab(i)
                        ,g_EXPENDITURE_TYPE_systab(i)
                        --,g_EXPENDITURE_TYPE_ID_systab(i)
                        ,g_EVENT_TYPE_systab(i)
                        --,g_EVENT_TYPE_ID_systab(i)
                        ,g_NON_LABOR_RESOURCE_systab(i)
                        --,g_NON_LABOR_RESOURCE_ID_systab(i)
                        ,g_EXPENDITURE_CATEGORY_systab(i)
                        --,g_EXP_CATEGORY_ID_systab(i)
                        ,g_REVENUE_CATEGORY_CODE_systab(i)
                        ,g_NLR_ORGANIZATION_ID_systab(i)
                        ,g_EVENT_CLASSIFICATION_systab(i)
                        ,g_SYS_LINK_FUNCTION_systab(i)
                        ,g_PROJECT_ROLE_ID_systab(i)
                        ,g_RESOURCE_CLASS_CODE_systab(i)
                        ,g_MFC_COST_TYPE_ID_systab(i)
                        ,g_RESOURCE_CLASS_FLAG_systab(i)
                        ,g_FC_RES_TYPE_CODE_systab(i)
                        ,g_INVENTORY_ITEM_ID_systab(i)
                        ,g_ITEM_CATEGORY_ID_systab(i)
                        ,g_PERSON_TYPE_CODE_systab(i)
                        ,g_BOM_RESOURCE_ID_systab(i)
                        ,decode(g_BOM_RESOURCE_ID_systab(i),NULL,NULL,
                            decode(g_RESOURCE_CLASS_CODE_systab(i),'PEOPLE',g_BOM_RESOURCE_ID_systab(i),NULL))
                        ,decode(g_BOM_RESOURCE_ID_systab(i),NULL,NULL,
                            decode(g_RESOURCE_CLASS_CODE_systab(i),'EQUIPMENT',g_BOM_RESOURCE_ID_systab(i),NULL))
                        ,g_NAMED_ROLE_systab(i)
                        --,g_NAMED_ROLE_ID_systab(i)
                        ,g_INCURRED_BY_RES_FLAG_systab(i)
                        ,g_RATE_BASED_FLAG_systab(i)
                        ,g_TXN_TASK_ID_systab(i)
                        ,g_TXN_WBS_ELE_VER_ID_systab(i)
                        ,g_TXN_RBS_ELEMENT_ID_systab(i)
                        ,g_TXN_PLAN_START_DATE_systab(i)
                        ,g_TXN_PLAN_END_DATE_systab (i)
                        ,g_PROJECT_ID
                        ,g_BUDGET_VERSION_ID
                     FROM DUAL;

            END IF;--IF l_uncategorized_flag = 'Y' THEN
            l_NumRecInserted := sql%Rowcount;
            g_res_numRecInserted := l_NumRecInserted;
            l_stage := 'Num of Records inserted ['||g_res_numRecInserted||']';
            print_msg(g_debug_flag,l_stage);

          End If;-- If g_TXN_SOURCE_ID_systab.COUNT > 0 Then

    End If;--If p_calling_mode =

    --Some of the attributes that are required for resource list mapping are derived below. If the
    --target is an uncategorized resource list then the resource list mapping would not be called and all the
    --source resource list members would be mapped to financial class resource list member in the target. Hence
    --the below code need not be executed for uncategorzied resource lists.
    IF l_NumRecInserted > 0  AND
       l_uncategorized_flag = 'N' THEN

        /* update the resource class id for the inseted rows*/
        --FORALL i IN g_txn_id_sqltab.FIRST .. g_txn_id_sqltab.LAST
            UPDATE pa_res_list_map_tmp1 tmp
        SET tmp.resource_class_id = (select rc.resource_class_id
                         from pa_resource_classes_b rc
                         where rc.resource_class_code = tmp.resource_class_code)
        WHERE tmp.resource_class_code is NOT NULL
        ;

                /* Bug fix: 3698579 */
                -- update exp category id if null
                UPDATE pa_res_list_map_tmp1 tmp
                SET tmp.expenditure_category = (select etc.expenditure_category
                                           from pa_expenditure_types et
                                                ,pa_expenditure_categories etc
                                           where et.expenditure_type = tmp.expenditure_type
                                           and et.expenditure_category = etc.expenditure_category
                       and rownum = 1
                                          )
                WHERE tmp.expenditure_category is NULL
                AND   tmp.expenditure_type is NOT NULL ;

                -- update revenue category based on event type if its null
        UPDATE  pa_res_list_map_tmp1 tmp
            SET tmp.revenue_category = (SELECT evt.revenue_category_code
                                          FROM pa_event_types evt
                                         WHERE evt.event_type=tmp.event_type)
            WHERE tmp.revenue_category IS NULL
            AND tmp.event_type IS NOT NULL;

                -- update revenue category based on exp type if its null
                UPDATE pa_res_list_map_tmp1 tmp
                SET tmp.Revenue_category  = (select et.Revenue_category_code
                                           from pa_expenditure_types et
                                           where et.expenditure_type = tmp.expenditure_type
                       and rownum = 1
                                          )
                WHERE tmp.Revenue_category is NULL
                AND   tmp.expenditure_type is NOT NULL ;

        -- update default item category id if the resource is a inventory item
            UPDATE pa_res_list_map_tmp1 tmp
            SET tmp.item_category_id = ( SELECT cat.CATEGORY_ID
                                        FROM PA_RESOURCE_CLASSES_B classes
                                                ,PA_PLAN_RES_DEFAULTS  cls
                                                ,MTL_ITEM_CATEGORIES  cat
                                        WHERE classes.RESOURCE_CLASS_CODE = 'MATERIAL_ITEMS'
                                        AND cls.RESOURCE_CLASS_ID      = classes.RESOURCE_CLASS_ID
                                        AND cls.ITEM_CATEGORY_SET_ID    = cat.CATEGORY_SET_ID
                                        AND cat.ORGANIZATION_ID = tmp.organization_id
                                        AND cat.INVENTORY_ITEM_ID = tmp.inventory_item_id
                    AND rownum = 1
                                   )
            WHERE tmp.item_category_id is NULL
            AND   tmp.inventory_item_id is NOT NULL;

        /* bug fix:3843815 ,3841480 if p_budget_version_id is not passed in plsql_table mode then
         * the sql to derive l_struct_ver_id causes no data found . so added if condition and
         * moved the select to cursor */
        IF l_struct_ver_id is NOT NULL Then
            UPDATE pa_res_list_map_tmp1 tmp
                    SET tmp.TXN_WBS_ELEMENT_VERSION_ID = (Select pelm.element_version_id
                              From pa_proj_element_versions pelm
                              WHERE pelm.parent_structure_version_id = l_struct_ver_id
                              AND pelm.proj_element_id = tmp.txn_task_id
                              AND rownum = 1
                                   )
                    WHERE tmp.TXN_WBS_ELEMENT_VERSION_ID is NULL
                    AND   tmp.txn_task_id is NOT NULL;
        End If;
                /* End of bug fix:3698579 */

        /* added this update for bug fix:3854817 */
         UPDATE pa_res_list_map_tmp1 tmp
         SET tmp.fc_res_type_code = DECODE(tmp.EXPENDITURE_TYPE,null
                        ,DECODE(tmp.EVENT_TYPE,null
                            ,DECODE(tmp.EXPENDITURE_CATEGORY,null
                                ,DECODE(tmp.REVENUE_CATEGORY,null,NULL,'REVENUE_CATEGORY')
                            ,'EXPENDITURE_CATEGORY')
                        ,'EVENT_TYPE')
                         ,'EXPENDITURE_TYPE')
         WHERE tmp.fc_res_type_code is NULL;

    End If;
    l_stage := 'End of populate_resmap_tmp api';
    print_msg(g_debug_flag,l_stage);

EXCEPTION
        WHEN OTHERS THEN
                print_msg(g_debug_flag,l_stage||':'||SQLCODE||SQLERRM);
                RAISE;
END populate_resmap_tmp;

/* This API reads the output records from  Resource and RBS mapping tmp tables and
 * populates the output plsql and system tables
 */
PROCEDURE populate_resrbsmap_outTbls
          (p_process_code                 IN Varchar2
      ,p_calling_mode                 IN Varchar2
      ,p_resource_list_id             IN Number
      ,p_budget_version_id        IN Number
          ,x_return_status                OUT NOCOPY varchar2
          ) IS

    CURSOR cur_resmapRejections IS
    SELECT rsmap.txn_source_id
        ,rsmap.resource_list_member_id
        ,null -- rsmap.res_map_rejection_code
        ,rsmap.txn_source_id
                ,rsmap.resource_list_member_id
                ,null  --rsmap.res_map_rejection_code
        ,null
        ,null
        ,null
        ,null
        ,null
        ,null
    FROM pa_res_list_map_tmp4 rsmap;

    CURSOR cur_rbsmapRejections IS
        SELECT rsmap.source_id
                ,rsmap.rbs_element_id
        ,rsmap.txn_accum_header_id
                ,null -- rsmap.rbs_map_rejection_code
        ,rsmap.source_id
                ,rsmap.rbs_element_id
                ,rsmap.txn_accum_header_id
                ,null -- rsmap.rbs_map_rejection_code
        ,null
        ,null
        ,null
        ,null
        FROM pa_rbs_plans_out_tmp rsmap;

    CURSOR cur_resrbsmapRejections IS
        SELECT resmap.txn_source_id
                ,resmap.resource_list_member_id
                ,null -- resmap.res_map_rejection_code
                ,resmap.txn_source_id
                ,resmap.resource_list_member_id
                ,null  --resmap.res_map_rejection_code
                ,rbsmap.rbs_element_id
                ,rbsmap.txn_accum_header_id
                ,null -- rbsmap.rbs_map_rejection_code
                ,rbsmap.rbs_element_id
                ,rbsmap.txn_accum_header_id
                ,null -- rbsmap.rbs_map_rejection_code
        FROM pa_res_list_map_tmp4 resmap
        ,pa_rbs_plans_out_tmp rbsmap
    WHERE resmap.txn_source_id = rbsmap.source_id ;

    l_stage  varchar2(1000);

    l_count  Number := 0;
BEGIN

      /* Initiazlize the global plsql tables Out variables */
      l_stage := 'Start of populate_resrbsmap_outTbls Initializing the OUT global plsql tables';
      print_msg(g_debug_flag,l_stage);
      x_return_status := 'S';
          g_res_map_reject_code_sqltab.delete;
          g_res_map_reject_code_systab := system.pa_varchar2_30_tbl_type ();
          g_res_list_member_id_sqltab.delete;
          g_res_list_member_id_systab  := system.pa_num_tbl_type();
          g_txn_source_id_sqltab.delete;
          g_txn_source_id_systab := system.pa_num_tbl_type();
          g_rbs_map_reject_code_sqltab.delete;
          g_rbs_map_reject_code_systab   := system.PA_VARCHAR2_30_TBL_TYPE();
          g_rbs_element_id_sqltab.delete;
          g_rbs_element_id_systab        := system.PA_NUM_TBL_TYPE();
          g_txn_accum_header_id_sqltab.delete;
          g_txn_accum_header_id_systab  := system.PA_NUM_TBL_TYPE();

      If p_process_code = 'RES_MAP' Then
	  If NVL(g_debug_flag,'N') = 'Y' Then     /* Bug No. 4419245 */
                select count(*)
                into l_count
                from pa_res_list_map_tmp4;
             print_msg(g_debug_flag,'For Debug purpose counting Number of records from mapping temp table is ['||l_count||']');
          end if;     /* Bug No. 4419245 */
        l_stage := 'Opening Resource Mapping rejection cursor';
        print_msg(g_debug_flag,l_stage);
        OPEN cur_resmapRejections;
        FETCH cur_resmapRejections BULK COLLECT INTO
            g_txn_source_id_sqltab
            ,g_res_list_member_id_sqltab
            ,g_res_map_reject_code_sqltab
            ,g_txn_source_id_systab
            ,g_res_list_member_id_systab
            ,g_res_map_reject_code_systab
            ,g_rbs_element_id_sqltab
            ,g_txn_accum_header_id_sqltab
                        ,g_rbs_map_reject_code_sqltab
                        ,g_rbs_element_id_systab
                        ,g_txn_accum_header_id_systab
                        ,g_rbs_map_reject_code_systab;
        CLOSE cur_resmapRejections;
        l_stage := 'Num of records fetched into global tables ['||g_txn_source_id_sqltab.count||']';
        print_msg(g_debug_flag,l_stage);
    Elsif p_process_code = 'RBS_MAP' Then
	If NVL(g_debug_flag,'N') = 'Y' Then     /* Bug No. 4419245 */
                select count(*)
                into l_count
                from pa_rbs_plans_out_tmp;
                print_msg(g_debug_flag,'For Debug purpose counting Number of records from mapping temp table is ['||l_count||']');
        /* just for debug purpose priting the values of all the reocrds*/
        FOR i IN ( select * from pa_rbs_plans_out_tmp ) LOOP
        print_msg(g_debug_flag,'Value from rbs outtmp SourceId['||i.source_id||']RbsEleId['||i.rbs_element_id||']TxnAccum['||i.txn_accum_header_id||']');
        END LOOP;
        End if;    /* Bug No. 4419245 */
        l_stage := 'Opening RBS map rejections cursor';
        print_msg(g_debug_flag,l_stage);
            OPEN cur_rbsmapRejections ;
        FETCH cur_rbsmapRejections BULK COLLECT INTO
                g_txn_source_id_sqltab
                    ,g_rbs_element_id_sqltab
                    ,g_txn_accum_header_id_sqltab
                    ,g_rbs_map_reject_code_sqltab
                    ,g_txn_source_id_systab
                    ,g_rbs_element_id_systab
                    ,g_txn_accum_header_id_systab
                    ,g_rbs_map_reject_code_systab
                        ,g_res_list_member_id_sqltab
                        ,g_res_map_reject_code_sqltab
                        ,g_res_list_member_id_systab
                        ,g_res_map_reject_code_systab;
        CLOSE  cur_rbsmapRejections;
        l_stage := 'Num of records fetched into global tables ['||g_txn_source_id_sqltab.count||']';
        print_msg(g_debug_flag,l_stage);
    Elsif p_process_code = 'RES_RBS_MAP' Then
	If NVL(g_debug_flag,'N') = 'Y' Then     /* Bug No. 4419245 */
                select count(*)
                into l_count
                from pa_res_list_map_tmp4;
                print_msg(g_debug_flag,'For Debug purpose counting Number of records from RESmapping temp table is ['||l_count||']');
                select count(*)
                into l_count
                from pa_rbs_plans_out_tmp;
                print_msg(g_debug_flag,'For Debug purpose counting Number of records from RBSmapping temp table is ['||l_count||']');
        End if; /* Bug No. 4419245 */
        l_stage := 'Opening ResRBS map rejections cursor';
        print_msg(g_debug_flag,l_stage);
        OPEN cur_resrbsmapRejections;
        FETCH cur_resrbsmapRejections BULK COLLECT INTO
                        g_txn_source_id_sqltab
                        ,g_res_list_member_id_sqltab
                        ,g_res_map_reject_code_sqltab
                        ,g_txn_source_id_systab
                        ,g_res_list_member_id_systab
                        ,g_res_map_reject_code_systab
                        ,g_rbs_element_id_sqltab
                        ,g_txn_accum_header_id_sqltab
                        ,g_rbs_map_reject_code_sqltab
                        ,g_rbs_element_id_systab
                        ,g_txn_accum_header_id_systab
                        ,g_rbs_map_reject_code_systab ;
        CLOSE cur_resrbsmapRejections;
        l_stage := 'Num of records fetched into global tables ['||g_txn_source_id_sqltab.count||']';
        print_msg(g_debug_flag,l_stage);
    End If;
    l_stage := 'End of populate_resrbsmap_outTbl ';
    print_msg(g_debug_flag,l_stage);
EXCEPTION
    WHEN OTHERS THEN
        print_msg(g_debug_flag,l_stage||':'||SQLCODE||SQLERRM);
        x_return_status := 'U';
        RAISE;

END populate_resrbsmap_outTbls;

/* This API derives the Resource list member id and RBS element Id for the
 * given resource list Id / RBS version Id. This procedure calls resource mapping and rbs mapping API
 * depending the parameter p_process_code
 * If p_process_code = 'RES_MAP' then RLMI will be derived by calling resource mapping api
 * If p_process_code = 'RBS_MAP' then RBS element Id will be derived by caling RBS mapping api
 * The following are the possible values for these IN params
 * p_calling_process  IN   varchar2
 *                values  'BUDGET_GENERATION' , 'RBS_REFRESH' , 'COPY_PROJECT'
 * p_process_code     IN   varchar2
 *                values  'RES_MAP', 'RBS_MAP'
 * p_calling_context  IN   varchar2
 *                values  'PLSQL' , 'SELF_SERVICE'
 * p_calling_mode     IN   varchar2
 *                values   'PLSQL_TABLE', 'BUDGET_VERSION'
 *
 * NOTES
 * 1.p_txn_source_id_tab  must be populated with UNIQUE value
 * 2.If the p_calling_mode is 'BUDGET_VERSION' then values passed in plsql and system table params
 *   will be ignored
 * 3.If the p_calling_context is 'SELF_SERVICE' then debug msg will write to PA_DEBUG.WRITE_LOG();
 * 4.If the p_calling_context is 'PLSQL'  then debug msg will write to PA_DEBUG.WRITE_FILE();
 */
PROCEDURE Map_Rlmi_Rbs
( p_budget_version_id       IN  Number
,p_project_id                   IN      Number          Default NULL
,p_resource_list_id     IN  Number      Default NULL
,p_rbs_version_id       IN  Number      Default NULL
,p_calling_process      IN  Varchar2
,p_calling_context      IN  varchar2    Default 'PLSQL'
,p_process_code         IN  varchar2    Default 'RES_MAP'
,p_calling_mode         IN  Varchar2    Default 'PLSQL_TABLE'
,p_init_msg_list_flag       IN  Varchar2    Default 'Y'
,p_commit_flag          IN  Varchar2    Default 'N'
,p_TXN_SOURCE_ID_tab            IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_TXN_SOURCE_TYPE_CODE_tab     IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_PERSON_ID_tab                IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_JOB_ID_tab                   IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_ORGANIZATION_ID_tab          IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_VENDOR_ID_tab                IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_EXPENDITURE_TYPE_tab         IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_EVENT_TYPE_tab               IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_NON_LABOR_RESOURCE_tab       IN  PA_PLSQL_DATATYPES.Char20TabTyp Default PA_PLSQL_DATATYPES.EmptyChar20Tab
,p_EXPENDITURE_CATEGORY_tab     IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_REVENUE_CATEGORY_CODE_tab    IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_NLR_ORGANIZATION_ID_tab      IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_EVENT_CLASSIFICATION_tab     IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_SYS_LINK_FUNCTION_tab        IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_PROJECT_ROLE_ID_tab          IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_RESOURCE_CLASS_CODE_tab      IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_MFC_COST_TYPE_ID_tab         IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_RESOURCE_CLASS_FLAG_tab      IN  PA_PLSQL_DATATYPES.Char1TabTyp  Default PA_PLSQL_DATATYPES.EmptyChar1Tab
,p_FC_RES_TYPE_CODE_tab         IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_INVENTORY_ITEM_ID_tab        IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_ITEM_CATEGORY_ID_tab         IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_PERSON_TYPE_CODE_tab         IN  PA_PLSQL_DATATYPES.Char30TabTyp Default PA_PLSQL_DATATYPES.EmptyChar30Tab
,p_BOM_RESOURCE_ID_tab          IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_NAMED_ROLE_tab               IN  PA_PLSQL_DATATYPES.Char80TabTyp Default PA_PLSQL_DATATYPES.EmptyChar80Tab
,p_INCURRED_BY_RES_FLAG_tab     IN  PA_PLSQL_DATATYPES.Char1TabTyp  Default PA_PLSQL_DATATYPES.EmptyChar1Tab
,p_RATE_BASED_FLAG_tab          IN  PA_PLSQL_DATATYPES.Char1TabTyp  Default PA_PLSQL_DATATYPES.EmptyChar1Tab
,p_TXN_TASK_ID_tab              IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_TXN_WBS_ELEMENT_VER_ID_tab   IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_TXN_RBS_ELEMENT_ID_tab       IN  PA_PLSQL_DATATYPES.IdTabTyp     Default PA_PLSQL_DATATYPES.EmptyIdTab
,p_TXN_PLAN_START_DATE_tab      IN  PA_PLSQL_DATATYPES.DateTabTyp   Default PA_PLSQL_DATATYPES.EmptyDateTab
,p_TXN_PLAN_END_DATE_tab        IN  PA_PLSQL_DATATYPES.DateTabTyp   Default PA_PLSQL_DATATYPES.EmptyDateTab
,x_txn_source_id_tab        OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp
,x_res_list_member_id_tab       OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp
,x_rbs_element_id_tab           OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp
,x_txn_accum_header_id_tab      OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp
,x_return_status        OUT NOCOPY Varchar2
,x_msg_count            OUT NOCOPY Number
,x_msg_data         OUT NOCOPY Varchar2
)  IS
    l_resource_list_id      Number;
    l_rbs_version_id        Number;
    l_calling_mode                  Varchar2(100);
    l_return_status         varchar2(10) := 'S';
    l_msg_count         Number := 0;
    l_msg_data          Varchar2(1000);
    l_stage             Varchar2(1000);
    l_tab_count                     Number := 0;
        l_resmap_return_status          varchar2(10) := 'S';
        l_rbsmap_return_status          varchar2(10) := 'S';

BEGIN
    /* INitizalize the out variables*/
    x_return_status := 'S';
    x_msg_data  := Null;
    x_msg_count := Null;
    --x_res_map_reject_code_tab.delete;
    --x_rbs_map_reject_code_tab.delete;
    g_debug_context := p_calling_context;

        --- Initialize the error statck
        PA_DEBUG.init_err_stack ('PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs');

        fnd_profile.get('PA_DEBUG_MODE',g_debug_flag);
        g_debug_flag := NVL(g_debug_flag, 'N');

	/* Bug fix: 4345057 */
	If NVL(g_debug_flag,'N') = 'Y' Then
           PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => g_debug_flag
                          );
	End If;

    l_stage := 'Begin of PLSQL.Map_Rlmi_Rbs IN Params:BdgtVer['||p_budget_version_id||']ReslistId['||p_resource_list_id||
        ']RbsVers['||p_rbs_version_id||']CallingProcess['||p_calling_process||']CallContext['||p_calling_context||
        ']ProcessCode['||p_process_code||']CallingMode['||p_calling_mode||']InitMsg['||p_init_msg_list_flag||
        ']CommitFlag['||p_commit_flag||']ProjectId['||p_project_Id||']' ;
    Print_msg(g_debug_flag,l_stage);

    /* Initialize the Variables with IN params*/
    l_stage := 'Calling Init_ReqdVariables api';
    print_msg(g_debug_flag,l_stage);
    Init_ReqdVariables(
                p_process_code       => p_process_code
        ,p_project_id        => p_project_id
                ,p_resource_list_id  => p_resource_list_id
                ,p_rbs_version_id    => p_rbs_version_id
                ,p_budget_version_id => p_budget_version_id
            );
    l_stage := 'GlobalVariables:BdgtVer['||g_budget_version_id||']ProjId['||g_project_id||']ReslistId['||g_resource_list_id||
        ']RbsVersion['||g_rbs_version_id||']';
    print_msg(g_debug_flag,l_stage);

    /* based on the calling mode Assign the INparam to Global varaibles */
    IF p_calling_mode = 'PLSQL_TABLE' Then
                l_tab_count := p_TXN_SOURCE_ID_Tab.count;
        l_stage := 'Begin Assigning In PLSQL tables to Global Plsql Tables plsqlTabCount['||l_tab_count||']';
        print_msg(g_debug_flag,l_stage);

        g_TXN_SOURCE_ID_sqlTab         := p_TXN_SOURCE_ID_Tab;
        g_TXN_SOURCE_TYPE_CODE_sqltab  := p_TXN_SOURCE_TYPE_CODE_tab;
        g_PERSON_ID_sqltab             := p_PERSON_ID_tab;
        g_JOB_ID_sqltab                := p_JOB_ID_tab;
        g_ORGANIZATION_ID_sqltab       := p_ORGANIZATION_ID_tab;
        g_VENDOR_ID_sqltab             := p_vendor_id_tab;
        g_EXPENDITURE_TYPE_sqltab      := p_expenditure_type_tab;
        g_EVENT_TYPE_sqltab            := p_event_type_tab;
        g_NON_LABOR_RESOURCE_sqltab    := p_non_labor_resource_tab;
        g_EXPENDITURE_CATEGORY_sqltab  := p_expenditure_category_tab;
        g_REVENUE_CATEGORY_CODE_sqltab := p_revenue_category_code_tab;
        g_NLR_ORGANIZATION_ID_sqltab   := p_NLR_organization_id_tab;
        g_EVENT_CLASSIFICATION_sqltab  := p_event_classification_tab;
        g_SYS_LINK_FUNCTION_sqltab     := p_sys_link_function_tab;
        g_PROJECT_ROLE_ID_sqltab       := p_project_role_id_tab;
        g_RESOURCE_CLASS_CODE_sqltab   := p_resource_class_code_tab;
        g_MFC_COST_TYPE_ID_sqltab      := p_mfc_cost_type_id_tab;
        g_RESOURCE_CLASS_FLAG_sqltab   := p_resource_class_flag_tab;
        g_FC_RES_TYPE_CODE_sqltab      := p_fc_res_type_code_tab;
        g_INVENTORY_ITEM_ID_sqltab     := p_inventory_item_id_tab;
        g_ITEM_CATEGORY_ID_sqltab      := p_item_category_id_tab;
        g_PERSON_TYPE_CODE_sqltab      := p_person_type_code_tab;
        g_BOM_RESOURCE_ID_sqltab       := p_bom_resource_id_tab;
        g_NAMED_ROLE_sqltab            := p_named_role_tab;
        g_INCURRED_BY_RES_FLAG_sqltab  := p_incurred_by_res_flag_tab;
        g_RATE_BASED_FLAG_sqltab       := p_rate_based_flag_tab;
        g_TXN_TASK_ID_sqltab           := p_txn_task_id_tab;
        g_TXN_WBS_ELE_VER_ID_sqltab    := p_txn_wbs_element_ver_id_tab;
        g_TXN_RBS_ELEMENT_ID_sqltab    := p_txn_rbs_element_id_tab;
        g_TXN_PLAN_START_DATE_sqltab   := p_txn_plan_start_date_tab;
        g_TXN_PLAN_END_DATE_sqltab     := p_txn_plan_end_date_tab;
                l_stage := 'End of Assigning plsql tables to Global Plsql Tables';
                print_msg(g_debug_flag,l_stage);
        /* End of Assigning plsql tables */
        IF l_tab_count =  0 THEN
                --No records to process. Return
            l_stage := 'The Source Id tab is Null. No record to process Return';
            print_msg(g_debug_flag,l_stage);
                PA_DEBUG.reset_err_stack;
                RETURN;
        ELSIF l_tab_count > 0 Then
           l_stage := ' Loop through plsql tables and check any of the index not exists';
           print_msg(g_debug_flag,l_stage);
                   FOR i IN g_TXN_SOURCE_ID_sqlTab.FIRST .. g_TXN_SOURCE_ID_sqlTab.LAST LOOP
            If NOT g_TXN_SOURCE_TYPE_CODE_sqltab.EXISTS(i) Then
                        g_TXN_SOURCE_TYPE_CODE_sqltab(i)  := null;
            Else
             IF g_TXN_SOURCE_TYPE_CODE_sqltab(i) = fnd_api.g_miss_char Then
                g_TXN_SOURCE_TYPE_CODE_sqltab(i) := null;
                 End If;
            End If;
            If NOT g_PERSON_ID_sqltab.EXISTS(i) Then
                        g_PERSON_ID_sqltab(i)   := null;
            Else
             IF g_PERSON_ID_sqltab(i) = fnd_api.g_miss_num Then
                g_PERSON_ID_sqltab(i)   := null;
             End If;
            End If;
            If NOT g_JOB_ID_sqltab.EXISTS(i) Then
                        g_JOB_ID_sqltab(i)  := null;
            Else
              IF g_JOB_ID_sqltab(i) = fnd_api.g_miss_num Then
                g_JOB_ID_sqltab(i)  := null;
              End If;
            End If;
            If NOT g_ORGANIZATION_ID_sqltab.EXISTS(i) Then
                        g_ORGANIZATION_ID_sqltab(i) := null;
            Else
              If g_ORGANIZATION_ID_sqltab(i) = fnd_api.g_miss_num Then
                g_ORGANIZATION_ID_sqltab(i) := null;
              End If;
            End If;
            If NOT g_VENDOR_ID_sqltab.EXISTS(i) Then
                        g_VENDOR_ID_sqltab(i)  := null;
            Else
             IF g_VENDOR_ID_sqltab(i) = fnd_api.g_miss_num Then
                g_VENDOR_ID_sqltab(i)  := null;
             End If;
            End If;
            If NOT g_EXPENDITURE_TYPE_sqltab.EXISTS(i) Then
                        g_EXPENDITURE_TYPE_sqltab(i)  := null;
            Else
              If g_EXPENDITURE_TYPE_sqltab(i) = fnd_api.g_miss_char Then
                g_EXPENDITURE_TYPE_sqltab(i)  := null;
              End If;
            End If;
            If NOT g_EVENT_TYPE_sqltab.EXISTS(i) Then
                        g_EVENT_TYPE_sqltab(i) := null;
            Else
              If g_EVENT_TYPE_sqltab(i) = fnd_api.g_miss_char Then
                g_EVENT_TYPE_sqltab(i) := null;
              End If;
            End If;
            If NOT g_NON_LABOR_RESOURCE_sqltab.EXISTS(i) Then
                        g_NON_LABOR_RESOURCE_sqltab(i)  := null;
            Else
             IF g_NON_LABOR_RESOURCE_sqltab(i) =  fnd_api.g_miss_char Then
                g_NON_LABOR_RESOURCE_sqltab(i)  := null;
             End If;
            End If;
            If NOT g_EXPENDITURE_CATEGORY_sqltab.EXISTS(i) Then
                        g_EXPENDITURE_CATEGORY_sqltab(i)  := null;
            Else
             IF  g_EXPENDITURE_CATEGORY_sqltab(i) = fnd_api.g_miss_char Then
                g_EXPENDITURE_CATEGORY_sqltab(i) := null;
             End If;
            End If;
            If NOT g_REVENUE_CATEGORY_CODE_sqltab.EXISTS(i) Then
                        g_REVENUE_CATEGORY_CODE_sqltab(i) := null;
            Else
              IF g_REVENUE_CATEGORY_CODE_sqltab(i) = fnd_api.g_miss_char Then
                g_REVENUE_CATEGORY_CODE_sqltab(i) := null;
              End If;
            End If;
            If NOT g_NLR_ORGANIZATION_ID_sqltab.EXISTS(i) Then
                        g_NLR_ORGANIZATION_ID_sqltab(i)   := null;
            Else
              If g_NLR_ORGANIZATION_ID_sqltab(i) = fnd_api.g_miss_num Then
                g_NLR_ORGANIZATION_ID_sqltab(i)   := null;
              End If;
            End If;
            If NOT g_EVENT_CLASSIFICATION_sqltab.EXISTS(i) Then
                        g_EVENT_CLASSIFICATION_sqltab(i)  := null;
            Else
              IF g_EVENT_CLASSIFICATION_sqltab(i) = fnd_api.g_miss_char Then
                g_EVENT_CLASSIFICATION_sqltab(i)  := null;
              End If;
            End If;
            If NOT g_SYS_LINK_FUNCTION_sqltab.EXISTS(i) Then
                        g_SYS_LINK_FUNCTION_sqltab(i)  := null;
            Else
             IF g_SYS_LINK_FUNCTION_sqltab(i) = fnd_api.g_miss_char Then
                g_SYS_LINK_FUNCTION_sqltab(i)  := null;
             End If;
            End If;
            If NOT g_PROJECT_ROLE_ID_sqltab.EXISTS(i) Then
                        g_PROJECT_ROLE_ID_sqltab(i) := null;
            Else
              IF g_PROJECT_ROLE_ID_sqltab(i) = fnd_api.g_miss_num Then
                g_PROJECT_ROLE_ID_sqltab(i) := null;
              End If;
            End If;
            If NOT g_RESOURCE_CLASS_CODE_sqltab.EXISTS(i) Then
                        g_RESOURCE_CLASS_CODE_sqltab(i)   := null;
            Else
              IF g_RESOURCE_CLASS_CODE_sqltab(i) = fnd_api.g_miss_char Then
                g_RESOURCE_CLASS_CODE_sqltab(i)   := null;
              End If;
            End If;
            IF NOT g_MFC_COST_TYPE_ID_sqltab.EXISTS(i) Then
                        g_MFC_COST_TYPE_ID_sqltab(i)   := null;
            Else
              IF g_MFC_COST_TYPE_ID_sqltab(i) = fnd_api.g_miss_num Then
                g_MFC_COST_TYPE_ID_sqltab(i)   := null;
              End If;
            End If;
            If NOT g_RESOURCE_CLASS_FLAG_sqltab.EXISTS(i) Then
                        g_RESOURCE_CLASS_FLAG_sqltab(i)  := null;
            Else
              If g_RESOURCE_CLASS_FLAG_sqltab(i) = fnd_api.g_miss_char Then
                g_RESOURCE_CLASS_FLAG_sqltab(i)  := null;
              End If;
            End If;
            If NOT g_FC_RES_TYPE_CODE_sqltab.EXISTS(i) Then
                        g_FC_RES_TYPE_CODE_sqltab(i) := null;
            Else
             IF g_FC_RES_TYPE_CODE_sqltab(i) =  fnd_api.g_miss_char Then
                g_FC_RES_TYPE_CODE_sqltab(i) := null;
             End If;
            End If;
            If NOT g_INVENTORY_ITEM_ID_sqltab.EXISTS(i) Then
                        g_INVENTORY_ITEM_ID_sqltab(i)  := null;
            Else
              IF g_INVENTORY_ITEM_ID_sqltab(i) = fnd_api.g_miss_num Then
                g_INVENTORY_ITEM_ID_sqltab(i)  := null;
              End If;
            End If;
            IF NOT g_ITEM_CATEGORY_ID_sqltab.EXISTS(i) Then
                        g_ITEM_CATEGORY_ID_sqltab(i)      := null;
            Else
              IF g_ITEM_CATEGORY_ID_sqltab(i) = fnd_api.g_miss_num Then
                g_ITEM_CATEGORY_ID_sqltab(i)      := null;
              End If;
            End If;
            IF NOT g_PERSON_TYPE_CODE_sqltab.EXISTS(i) Then
                        g_PERSON_TYPE_CODE_sqltab(i)  := null;
            Else
             IF g_PERSON_TYPE_CODE_sqltab(i) = fnd_api.g_miss_char Then
                g_PERSON_TYPE_CODE_sqltab(i)  := null;
             End if;
            End If;
            IF NOT g_BOM_RESOURCE_ID_sqltab.EXISTS(i) Then
                        g_BOM_RESOURCE_ID_sqltab(i) := null;
            Else
             IF g_BOM_RESOURCE_ID_sqltab(i) = fnd_api.g_miss_num Then
                 g_BOM_RESOURCE_ID_sqltab(i) := null;
             End IF;
            End IF;
            IF NOT g_NAMED_ROLE_sqltab.EXISTS(i) Then
                        g_NAMED_ROLE_sqltab(i) := null;
            Else
             IF g_NAMED_ROLE_sqltab(i) = fnd_api.g_miss_char Then
                g_NAMED_ROLE_sqltab(i) := null;
             End IF;
            End If;
            IF NOT g_INCURRED_BY_RES_FLAG_sqltab.EXISTS(i) Then
                        g_INCURRED_BY_RES_FLAG_sqltab(i) := null;
            Else
             IF g_INCURRED_BY_RES_FLAG_sqltab(i) =  fnd_api.g_miss_char Then
                g_INCURRED_BY_RES_FLAG_sqltab(i) := null;
                         End IF;
            End If;
            IF NOT g_RATE_BASED_FLAG_sqltab.EXISTS(i) Then
                        g_RATE_BASED_FLAG_sqltab(i) :=  null;
            Else
             IF g_RATE_BASED_FLAG_sqltab(i) = fnd_api.g_miss_char Then
                g_RATE_BASED_FLAG_sqltab(i) :=  null;
             End IF;
            End IF;
            If NOT g_TXN_TASK_ID_sqltab.EXISTS(i) Then
                        g_TXN_TASK_ID_sqltab(i) := null;
            Else
             IF g_TXN_TASK_ID_sqltab(i) = fnd_api.g_miss_num Then
                g_TXN_TASK_ID_sqltab(i) := null;
             End IF;
            end if;
            If NOT g_TXN_WBS_ELE_VER_ID_sqltab.EXISTS(i) Then
                g_TXN_WBS_ELE_VER_ID_sqltab(i) := null;
            Else
             IF g_TXN_WBS_ELE_VER_ID_sqltab(i) = fnd_api.g_miss_num Then
                g_TXN_WBS_ELE_VER_ID_sqltab(i) := null;
             End IF;
            End IF;
            IF NOT g_TXN_RBS_ELEMENT_ID_sqltab.EXISTS(i) Then
                        g_TXN_RBS_ELEMENT_ID_sqltab(i) := null;
            Else
             IF g_TXN_RBS_ELEMENT_ID_sqltab(i) = fnd_api.g_miss_num Then
                g_TXN_RBS_ELEMENT_ID_sqltab(i) := null;
             End IF;
            End IF;
            If NOT g_TXN_PLAN_START_DATE_sqltab.EXISTS(i) Then
                        g_TXN_PLAN_START_DATE_sqltab(i) := null;
            Else
             IF g_TXN_PLAN_START_DATE_sqltab(i) =  fnd_api.g_miss_date Then
                g_TXN_PLAN_START_DATE_sqltab(i) := null;
             End IF;
            End IF;
            If NOT g_TXN_PLAN_END_DATE_sqltab.EXISTS(i) Then
                        g_TXN_PLAN_END_DATE_sqltab(i) := null;
            Else
             IF g_TXN_PLAN_END_DATE_sqltab(i) = fnd_api.g_miss_date Then
                g_TXN_PLAN_END_DATE_sqltab(i) := null;
             End If;
            End If;
                   END LOOP;
                   l_stage := ' End of Loop plsql tables and check any of the index not exists';
                   print_msg(g_debug_flag,l_stage);
                END If;
    End If;

    IF p_calling_mode = 'BUDGET_VERSION' Then
        l_calling_mode := 'BUDGET_VERSION';
    Elsif p_calling_mode = 'PLSQL_TABLE' Then
        l_calling_mode := 'PLSQL_TABLE';
    End IF;

    /* populate the resource mapping temp tables */
    If p_process_code in ('RES_MAP','RES_RBS_MAP') Then
        If g_resource_list_id is NOT NULL Then
        l_stage := 'Calling Populate populate_resmap_tmp api for Resource List ';
                print_msg(g_debug_flag,l_stage);
        populate_resmap_tmp
            (p_budget_version_id    => g_budget_version_id
            ,p_calling_mode         => l_calling_mode
            ,x_return_status        => l_return_status
        );
                l_stage := 'End of Populate populate_resmap_tmp api NumOfRecsInserted['||g_res_numRecInserted||']';
                print_msg(g_debug_flag,l_stage);

        /* call resource mapping api */
        l_resmap_return_status := 'S';
        If g_res_numRecInserted > 0
           AND g_call_res_list_mapping_api ='Y' Then
                    l_stage := 'Calling pa_resource_mapping.map_resource_list api';
                    print_msg(g_debug_flag,l_stage);

            pa_resource_mapping.map_resource_list
            (p_resource_list_id     => g_resource_list_id
            ,p_project_id           => g_project_id
            ,x_return_status    => l_resmap_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data     => l_msg_data
            );

                    l_stage := 'End of pa_resource_mapping.map_resource_list api retSts['||l_resmap_return_status||']';
                    print_msg(g_debug_flag,l_stage);
        End If;
        End If;
    End If;

        /* populate the rbs mapping temp tables */
        If p_process_code in ('RBS_MAP','RES_RBS_MAP') Then
       If g_rbs_version_id is NOT NULL Then
                l_stage := 'Calling populate_rbsmap_tmp api for RBS ';
                print_msg(g_debug_flag,l_stage);
                populate_rbsmap_tmp
                (p_budget_version_id    => g_budget_version_id
                ,p_calling_mode         => l_calling_mode
                ,x_return_status        => l_return_status
                );
                l_stage := 'End of populate_rbsmap_tmp api for RBS NumOfRecsInserted['||g_rbs_numRecInserted||']';
                print_msg(g_debug_flag,l_stage);

                /* call rbs mapping api */
        l_rbsmap_return_status := 'S';
        If g_rbs_numRecInserted > 0 Then
            /** bug fix 3658113  is reverted
            l_stage := 'Calling pa_rbs_mapping.create_mapping_rules api';
            print_msg(g_debug_flag,l_stage);
            pa_rbs_mapping.create_mapping_rules
            (
            p_rbs_version_id   => g_rbs_version_id
            ,x_return_status    => l_rbsmap_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data
            );
            l_stage := 'End Ofcreate_mapping_rules api RetSts['||l_rbsmap_return_status||']msgData['||l_msg_data||']';
            print_msg(g_debug_flag,l_stage);
            ***/
            If NVL(l_rbsmap_return_status,'S') = 'S' Then
                        l_stage := 'Calling pa_rbs_mapping.map_rbs_plans api';
                        print_msg(g_debug_flag,l_stage);
                        pa_rbs_mapping.map_rbs_plans
                        (p_rbs_version_id       => g_rbs_version_id
                        ,x_return_status        => l_rbsmap_return_status
                        ,x_msg_count            => l_msg_count
                        ,x_msg_data             => l_msg_data
                        );
                        l_stage := 'End Of pa_rbs_mapping.map_rbs_plans api RetSts['||l_rbsmap_return_status||']';
                        print_msg(g_debug_flag,l_stage);
            End If;
        End If;
       End If;
    End If;


    If ( g_res_numRecInserted > 0  OR g_rbs_numRecInserted > 0 ) Then
        /* After resource mapping read the values from out tmp tables and
        * populate the plsqltables */
        l_stage := 'Calling populate_resrbsmap_outTbls API';
        print_msg(g_debug_flag,l_stage);
        populate_resrbsmap_outTbls
        (p_process_code                 => p_process_code
        ,p_calling_mode                 => l_calling_mode
        ,p_resource_list_id     => g_resource_list_id
        ,p_budget_version_id        => g_budget_version_id
        ,x_return_status                => l_return_status
        );
        l_stage := 'Calling populate_resrbsmap_outTbls API NumofOutRecs['||g_txn_source_id_sqltab.count||']';
                print_msg(g_debug_flag,l_stage);

        /* Assign the output to plsqltabls */
            l_stage := 'Assigning values to OUT Plsql Tabs';
            print_msg(g_debug_flag,l_stage);
        If p_TXN_SOURCE_ID_tab.COUNT > 0 Then
               FOR i IN 1..p_TXN_SOURCE_ID_tab.COUNT LOOP
                    IF(p_TXN_SOURCE_ID_tab(i) <> g_txn_source_id_sqltab(i)) THEN
                            FOR j IN 1..g_txn_source_id_sqltab.COUNT LOOP
                                    IF(g_txn_source_id_sqltab(j) = p_TXN_SOURCE_ID_tab(i) )  THEN
                                        x_txn_source_id_tab(i) := g_txn_source_id_sqltab(j);
                                        x_res_list_member_id_tab(i) := g_res_list_member_id_sqltab(j);
                                        x_rbs_element_id_tab(i) := g_rbs_element_id_sqltab(j);
                                        x_txn_accum_header_id_tab(i) := g_txn_accum_header_id_sqltab(j);
                        EXIT;
                                    END IF;
                            END LOOP;

                    ELSE
                            x_txn_source_id_tab(i) := g_txn_source_id_sqltab(i);
                            x_res_list_member_id_tab(i) := g_res_list_member_id_sqltab(i);
                            x_rbs_element_id_tab(i) := g_rbs_element_id_sqltab(i);
                            x_txn_accum_header_id_tab(i) := g_txn_accum_header_id_sqltab(i);
                    END IF;

              END LOOP;
          Elsif p_calling_mode = 'BUDGET_VERSION' Then
                       x_txn_source_id_tab := g_txn_source_id_sqltab;
                       x_res_list_member_id_tab := g_res_list_member_id_sqltab;
                       x_rbs_element_id_tab := g_rbs_element_id_sqltab;
                       x_txn_accum_header_id_tab := g_txn_accum_header_id_sqltab;
          End If;
    End If;

    /* Set the return status of based on the res and rbs mapping api */
    l_stage := 'Setting Return sts based on Res/Rbs mapping ResMapSts['||l_resmap_return_status||
        ']RbsMapSts['||l_rbsmap_return_status||']';
    print_msg(g_debug_flag,l_stage);
    If l_resmap_return_status <> 'S' Then
        l_return_status := l_resmap_return_status;
    Else
                If l_rbsmap_return_status <> 'S' Then
                        l_return_status := l_rbsmap_return_status;
                End if;
    End If;

    /* Assign the out put variables */
    x_return_status := l_return_status;
    x_msg_count := l_msg_count;
    x_msg_data      := l_msg_data;

        l_stage := 'End Of PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs API';
        print_msg(g_debug_flag,l_stage);
    /* Reset the error Stack */
    PA_DEBUG.reset_err_stack;

EXCEPTION
    WHEN OTHERS THEN
        print_msg(g_debug_flag,l_stage||':'||SQLCODE||SQLERRM);
        If g_debug_context = 'PLSQL' Then
            PA_DEBUG.WRITE_FILE('LOG',l_stage);
            PA_DEBUG.WRITE_FILE('LOG','SQLERROR:'||SQLCODE||SQLERRM);
        Elsif  g_debug_context = 'SELF_SERVICE' Then
                        PA_DEBUG.WRITE_LOG(x_module      => 'pa.plsql.pa_rlmi_rbs_pub.map_rlmi_rbs'
                      ,x_msg         => l_stage||':'||SQLCODE||SQLERRM
                                  ,x_log_level   => 5 );
        End If;
                FND_MSG_PUB.add_exc_msg
                           ( p_pkg_name       => 'PA_RLMI_RBS_MAP_PUB'
                            ,p_procedure_name => 'Map_Rlmi_Rbs');
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                PA_DEBUG.reset_err_stack;
        RAISE;

END Map_Rlmi_Rbs;

/* This API will be called from Self-Service and Java pages */
PROCEDURE Map_Rlmi_Rbs
( p_budget_version_id       IN  Number
,p_project_id                   IN      Number          Default NULL
,p_resource_list_id     IN  Number      Default NULL
,p_rbs_version_id       IN  Number      Default NULL
,p_calling_process      IN  Varchar2
,p_calling_context      IN  varchar2    Default 'PLSQL'
,p_process_code         IN  varchar2    Default 'RES_MAP'
,p_calling_mode         IN  Varchar2    Default 'PLSQL_TABLE'
,p_init_msg_list_flag       IN  Varchar2    Default 'N'
,p_commit_flag          IN  Varchar2    Default 'N'
,p_TXN_SOURCE_ID_tab            IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_TXN_SOURCE_TYPE_CODE_tab     IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_PERSON_ID_tab                IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_JOB_ID_tab                   IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_ORGANIZATION_ID_tab          IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_VENDOR_ID_tab                IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_EXPENDITURE_TYPE_tab         IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_EVENT_TYPE_tab               IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_NON_LABOR_RESOURCE_tab       IN  system.PA_VARCHAR2_20_TBL_TYPE  Default system.PA_VARCHAR2_20_TBL_TYPE()
,p_EXPENDITURE_CATEGORY_tab     IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_REVENUE_CATEGORY_CODE_tab    IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_NLR_ORGANIZATION_ID_tab      IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_EVENT_CLASSIFICATION_tab     IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_SYS_LINK_FUNCTION_tab        IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_PROJECT_ROLE_ID_tab          IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_RESOURCE_CLASS_CODE_tab      IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_MFC_COST_TYPE_ID_tab         IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_RESOURCE_CLASS_FLAG_tab      IN  system.PA_VARCHAR2_1_TBL_TYPE   Default system.PA_VARCHAR2_1_TBL_TYPE()
,p_FC_RES_TYPE_CODE_tab         IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_INVENTORY_ITEM_ID_tab        IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_ITEM_CATEGORY_ID_tab         IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_PERSON_TYPE_CODE_tab         IN  system.PA_VARCHAR2_30_TBL_TYPE  Default system.PA_VARCHAR2_30_TBL_TYPE()
,p_BOM_RESOURCE_ID_tab          IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_NAMED_ROLE_tab               IN  system.PA_VARCHAR2_80_TBL_TYPE  Default system.PA_VARCHAR2_80_TBL_TYPE()
,p_INCURRED_BY_RES_FLAG_tab     IN  system.PA_VARCHAR2_1_TBL_TYPE   Default system.PA_VARCHAR2_1_TBL_TYPE()
,p_RATE_BASED_FLAG_tab          IN  system.PA_VARCHAR2_1_TBL_TYPE   Default system.PA_VARCHAR2_1_TBL_TYPE()
,p_TXN_TASK_ID_tab              IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_TXN_WBS_ELEMENT_VER_ID_tab   IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_TXN_RBS_ELEMENT_ID_tab       IN  system.PA_NUM_TBL_TYPE          Default system.PA_NUM_TBL_TYPE()
,p_TXN_PLAN_START_DATE_tab      IN  system.PA_DATE_TBL_TYPE         Default system.PA_DATE_TBL_TYPE()
,p_TXN_PLAN_END_DATE_tab        IN  system.PA_DATE_TBL_TYPE         Default system.PA_DATE_TBL_TYPE()
,x_txn_source_id_tab        OUT NOCOPY system.PA_NUM_TBL_TYPE
,x_res_list_member_id_tab       OUT NOCOPY system.PA_NUM_TBL_TYPE
,x_rbs_element_id_tab           OUT NOCOPY system.PA_NUM_TBL_TYPE
,x_txn_accum_header_id_tab      OUT NOCOPY system.PA_NUM_TBL_TYPE
,x_return_status        OUT NOCOPY Varchar2
,x_msg_count            OUT NOCOPY Number
,x_msg_data         OUT NOCOPY Varchar2
)  IS
        l_resource_list_id              Number;
        l_rbs_version_id                Number;
        l_calling_mode                  Varchar2(100);
        l_return_status                 varchar2(10) := 'S';
        l_resmap_return_status          varchar2(10) := 'S';
        l_rbsmap_return_status          varchar2(10) := 'S';
        l_msg_count                     Number := 0;
        l_msg_data                      Varchar2(1000);
        l_stage                         Varchar2(1000);
       l_tab_count                     Number := 0;


BEGIN
    /* INitizalize the out variables*/
    x_return_status := 'S';
    x_msg_data  := Null;
    x_msg_count := Null;
        --- Initialize the error statck
    PA_DEBUG.init_err_stack ('PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs');

    fnd_profile.get('PA_DEBUG_MODE',g_debug_flag);
    g_debug_flag := NVL(g_debug_flag, 'N');

    /* Bug fix: 4345057 */
    If NVL(g_debug_flag,'N') = 'Y' Then
        PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                  ,x_write_file     => 'LOG'
                  ,x_debug_mode      => g_debug_flag
                      );
    End If;
    g_debug_context := p_calling_context;
    x_txn_source_id_tab            := system.PA_NUM_TBL_TYPE();
    --x_res_map_reject_code_tab      := system.PA_VARCHAR2_30_TBL_TYPE();
    --x_rbs_map_reject_code_tab      := system.PA_VARCHAR2_30_TBL_TYPE();
    x_res_list_member_id_tab       := system.PA_NUM_TBL_TYPE();
    x_rbs_element_id_tab           := system.PA_NUM_TBL_TYPE();
    x_txn_accum_header_id_tab      := system.PA_NUM_TBL_TYPE();

    l_stage := 'Begin of SYSTEM.Map_Rlmi_Rbs IN Params:BdgtVer['||p_budget_version_id||']ReslistId['||p_resource_list_id||
        ']RbsVers['||p_rbs_version_id||']CallingProcess['||p_calling_process||']CallContext['||p_calling_context||
        ']ProcessCode['||p_process_code||']CallingMode['||p_calling_mode||']InitMsg['||p_init_msg_list_flag||
        ']CommitFlag['||p_commit_flag||']ProjectId['||p_project_Id||']' ;
    Print_msg(g_debug_flag,l_stage);

    /* Initialize the Variables with IN params*/
    l_stage := 'Calling Init_ReqdVariables api';
    print_msg(g_debug_flag,l_stage);
    Init_ReqdVariables(
                p_process_code       => p_process_code
        ,p_project_id        => p_project_id
                ,p_resource_list_id  => p_resource_list_id
                ,p_rbs_version_id    => p_rbs_version_id
                ,p_budget_version_id => p_budget_version_id
            );
    l_stage := 'GlobalVariables:BdgtVer['||g_budget_version_id||']ProjId['||g_project_id||']ReslistId['||g_resource_list_id||
        ']RbsVersion['||g_rbs_version_id||']';
    print_msg(g_debug_flag,l_stage);

    /* based on the calling mode Assign the INparam to Global varaibles */
    IF p_calling_mode = 'PLSQL_TABLE' Then
        l_tab_count  := p_TXN_SOURCE_ID_Tab.Count;
        l_stage := 'Begin Assigning In system tables to Global Plsql Tables plsqlTabCount['||l_tab_count||']';
        print_msg(g_debug_flag,l_stage);
        g_TXN_SOURCE_ID_sysTab         := p_TXN_SOURCE_ID_Tab;
        g_TXN_SOURCE_TYPE_CODE_systab  := p_TXN_SOURCE_TYPE_CODE_tab;
        g_PERSON_ID_systab             := p_PERSON_ID_tab;
        g_JOB_ID_systab                := p_JOB_ID_tab;
        g_ORGANIZATION_ID_systab       := p_ORGANIZATION_ID_tab;
        g_VENDOR_ID_systab             := p_vendor_id_tab;
        g_EXPENDITURE_TYPE_systab      := p_expenditure_type_tab;
        g_EVENT_TYPE_systab            := p_event_type_tab;
        g_NON_LABOR_RESOURCE_systab    := p_non_labor_resource_tab;
        g_EXPENDITURE_CATEGORY_systab  := p_expenditure_category_tab;
        g_REVENUE_CATEGORY_CODE_systab := p_revenue_category_code_tab;
        g_NLR_ORGANIZATION_ID_systab   := p_NLR_organization_id_tab;
        g_EVENT_CLASSIFICATION_systab  := p_event_classification_tab;
        g_SYS_LINK_FUNCTION_systab     := p_sys_link_function_tab;
        g_PROJECT_ROLE_ID_systab       := p_project_role_id_tab;
        g_RESOURCE_CLASS_CODE_systab   := p_resource_class_code_tab;
        g_MFC_COST_TYPE_ID_systab      := p_mfc_cost_type_id_tab;
        g_RESOURCE_CLASS_FLAG_systab   := p_resource_class_flag_tab;
        g_FC_RES_TYPE_CODE_systab      := p_fc_res_type_code_tab;
        g_INVENTORY_ITEM_ID_systab     := p_inventory_item_id_tab;
        g_ITEM_CATEGORY_ID_systab      := p_item_category_id_tab;
        g_PERSON_TYPE_CODE_systab      := p_person_type_code_tab;
        g_BOM_RESOURCE_ID_systab       := p_bom_resource_id_tab;
        g_NAMED_ROLE_systab            := p_named_role_tab;
        g_INCURRED_BY_RES_FLAG_systab  := p_incurred_by_res_flag_tab;
        g_RATE_BASED_FLAG_systab       := p_rate_based_flag_tab;
        g_TXN_TASK_ID_systab           := p_txn_task_id_tab;
        g_TXN_WBS_ELE_VER_ID_systab    := p_txn_wbs_element_ver_id_tab;
        g_TXN_RBS_ELEMENT_ID_systab    := p_txn_rbs_element_id_tab;
        g_TXN_PLAN_START_DATE_systab   := p_txn_plan_start_date_tab;
        g_TXN_PLAN_END_DATE_systab     := p_txn_plan_end_date_tab;
                l_stage := 'End of Assigning system tables to Global system Tables';
                print_msg(g_debug_flag,l_stage);
        /* End of Assigning plsql tables */
        IF l_tab_count =  0 THEN
                --No records to process. Return
            l_stage := 'The Source Id tab is Null. No record to process so Return';
            print_msg(g_debug_flag,l_stage);
                PA_DEBUG.reset_err_stack;
                RETURN;
        ELSIF l_tab_count > 0 Then
           l_stage := 'Checking the Table count and Extending the elements if not found';
           print_msg(g_debug_flag,l_stage);
                   FOR i IN g_TXN_SOURCE_ID_sysTab.FIRST .. g_TXN_SOURCE_ID_sysTab.LAST LOOP
            If NOT g_TXN_SOURCE_TYPE_CODE_systab.EXISTS(i) Then
                g_TXN_SOURCE_TYPE_CODE_systab.Extend;
                        g_TXN_SOURCE_TYPE_CODE_systab(i)  := null;
            Else
              If g_TXN_SOURCE_TYPE_CODE_systab(i) = fnd_api.g_miss_char Then
                g_TXN_SOURCE_TYPE_CODE_systab(i)  := null;
              End If;
            End If;
            If NOT g_PERSON_ID_systab.EXISTS(i) Then
                g_PERSON_ID_systab.Extend;
                        g_PERSON_ID_systab(i)   := null;
            Else
              IF g_PERSON_ID_systab(i) = fnd_api.g_miss_num Then
                g_PERSON_ID_systab(i)   := null;
              End IF;
            End If;
            If NOT g_JOB_ID_systab.EXISTS(i) Then
                g_JOB_ID_systab.Extend;
                        g_JOB_ID_systab(i)  := null;
            Else
              If g_JOB_ID_systab(i) = fnd_api.g_miss_num Then
                g_JOB_ID_systab(i)  := null;
              End if;
            End If;
            If NOT g_ORGANIZATION_ID_systab.EXISTS(i) Then
                g_ORGANIZATION_ID_systab.Extend;
                        g_ORGANIZATION_ID_systab(i) := null;
            Else
              If g_ORGANIZATION_ID_systab(i) = fnd_api.g_miss_num Then
                g_ORGANIZATION_ID_systab(i) := null;
              End IF;
            End If;
            If NOT g_VENDOR_ID_systab.EXISTS(i) Then
                g_VENDOR_ID_systab.Extend;
                        g_VENDOR_ID_systab(i)  := null;
            Else
              If g_VENDOR_ID_systab(i) = fnd_api.g_miss_num Then
                g_VENDOR_ID_systab(i)  := null;
              End if;
            End If;
            If NOT g_EXPENDITURE_TYPE_systab.EXISTS(i) Then
                g_EXPENDITURE_TYPE_systab.Extend;
                        g_EXPENDITURE_TYPE_systab(i)  := null;
            Else
              If g_EXPENDITURE_TYPE_systab(i) = fnd_api.g_miss_char Then
                g_EXPENDITURE_TYPE_systab(i)  := null;
              End IF;
            End If;
            If NOT g_EVENT_TYPE_systab.EXISTS(i) Then
                g_EVENT_TYPE_systab.Extend;
                        g_EVENT_TYPE_systab(i) := null;
            Else
             If g_EVENT_TYPE_systab(i) = fnd_api.g_miss_char Then
                g_EVENT_TYPE_systab(i) := null;
             End IF;
            End If;
            If NOT g_NON_LABOR_RESOURCE_systab.EXISTS(i) Then
                g_NON_LABOR_RESOURCE_systab.Extend;
                        g_NON_LABOR_RESOURCE_systab(i)  := null;
            Else
             IF g_NON_LABOR_RESOURCE_systab(i) = fnd_api.g_miss_char Then
                g_NON_LABOR_RESOURCE_systab(i)  := null;
             End If;
            End If;
            If NOT g_EXPENDITURE_CATEGORY_systab.EXISTS(i) Then
                g_EXPENDITURE_CATEGORY_systab.Extend;
                        g_EXPENDITURE_CATEGORY_systab(i)  := null;
            Else
             If g_EXPENDITURE_CATEGORY_systab(i) = fnd_api.g_miss_char Then
                g_EXPENDITURE_CATEGORY_systab(i)  := null;
             End if;

            End If;
            If NOT g_REVENUE_CATEGORY_CODE_systab.EXISTS(i) Then
                g_REVENUE_CATEGORY_CODE_systab.Extend;
                        g_REVENUE_CATEGORY_CODE_systab(i) := null;

            Else
             IF g_REVENUE_CATEGORY_CODE_systab(i) = fnd_api.g_miss_char Then
                g_REVENUE_CATEGORY_CODE_systab(i) := null;
             End IF;
            End If;
            If NOT g_NLR_ORGANIZATION_ID_systab.EXISTS(i) Then
                g_NLR_ORGANIZATION_ID_systab.Extend;
                        g_NLR_ORGANIZATION_ID_systab(i)   := null;
            Else
             IF g_NLR_ORGANIZATION_ID_systab(i) = fnd_api.g_miss_num Then
                g_NLR_ORGANIZATION_ID_systab(i)   := null;
                         End IF;
            End If;
            If NOT g_EVENT_CLASSIFICATION_systab.EXISTS(i) Then
                g_EVENT_CLASSIFICATION_systab.Extend;
                        g_EVENT_CLASSIFICATION_systab(i)  := null;
            Else
             If g_EVENT_CLASSIFICATION_systab(i) = fnd_api.g_miss_char Then
                g_EVENT_CLASSIFICATION_systab(i)  := null;
             End IF;
            End If;
            If NOT g_SYS_LINK_FUNCTION_systab.EXISTS(i) Then
                g_SYS_LINK_FUNCTION_systab.Extend;
                        g_SYS_LINK_FUNCTION_systab(i)  := null;
            Else
             If g_SYS_LINK_FUNCTION_systab(i) = fnd_api.g_miss_char Then
                g_SYS_LINK_FUNCTION_systab(i)  := null;
             End IF;
            End If;
            If NOT g_PROJECT_ROLE_ID_systab.EXISTS(i) Then
                g_PROJECT_ROLE_ID_systab.Extend;
                        g_PROJECT_ROLE_ID_systab(i) := null;
            Else
             IF g_PROJECT_ROLE_ID_systab(i) = fnd_api.g_miss_num Then
                g_PROJECT_ROLE_ID_systab(i) := null;
             End If;
            End If;
            If NOT g_RESOURCE_CLASS_CODE_systab.EXISTS(i) Then
                g_RESOURCE_CLASS_CODE_systab.Extend;
                        g_RESOURCE_CLASS_CODE_systab(i)   := null;
            Else
             IF g_RESOURCE_CLASS_CODE_systab(i) = fnd_api.g_miss_char Then
                g_RESOURCE_CLASS_CODE_systab(i)   := null;
             End IF;
            End If;
            IF NOT g_MFC_COST_TYPE_ID_systab.EXISTS(i) Then
                g_MFC_COST_TYPE_ID_systab.Extend;
                        g_MFC_COST_TYPE_ID_systab(i)   := null;
            Else
             IF g_MFC_COST_TYPE_ID_systab(i) = fnd_api.g_miss_num Then
                g_MFC_COST_TYPE_ID_systab(i)   := null;
             End IF;
            End If;
            If NOT g_RESOURCE_CLASS_FLAG_systab.EXISTS(i) Then
                g_RESOURCE_CLASS_FLAG_systab.Extend;
                        g_RESOURCE_CLASS_FLAG_systab(i)  := null;
            Else
             IF g_RESOURCE_CLASS_FLAG_systab(i) = fnd_api.g_miss_char Then
                g_RESOURCE_CLASS_FLAG_systab(i)  := null;
             End IF;
            End If;
            If NOT g_FC_RES_TYPE_CODE_systab.EXISTS(i) Then
                g_FC_RES_TYPE_CODE_systab.Extend;
                        g_FC_RES_TYPE_CODE_systab(i) := null;
            Else
             IF g_FC_RES_TYPE_CODE_systab(i) = fnd_api.g_miss_char Then
                g_FC_RES_TYPE_CODE_systab(i) := null;
             End If;
            End If;
            If NOT g_INVENTORY_ITEM_ID_systab.EXISTS(i) Then
                g_INVENTORY_ITEM_ID_systab.Extend;
                        g_INVENTORY_ITEM_ID_systab(i)  := null;
            Else
             IF g_INVENTORY_ITEM_ID_systab(i) = fnd_api.g_miss_num Then
                g_INVENTORY_ITEM_ID_systab(i)  := null;
             End IF;
            End If;
            IF NOT g_ITEM_CATEGORY_ID_systab.EXISTS(i) Then
                g_ITEM_CATEGORY_ID_systab.Extend;
                        g_ITEM_CATEGORY_ID_systab(i)      := null;
            Else
             If g_ITEM_CATEGORY_ID_systab(i) = fnd_api.g_miss_num Then
                g_ITEM_CATEGORY_ID_systab(i)      := null;
             End IF;
            End If;
            IF NOT g_PERSON_TYPE_CODE_systab.EXISTS(i) Then
                g_PERSON_TYPE_CODE_systab.Extend;
                        g_PERSON_TYPE_CODE_systab(i)  := null;
            Else
             IF g_PERSON_TYPE_CODE_systab(i) = fnd_api.g_miss_char Then
                g_PERSON_TYPE_CODE_systab(i)  := null;
             End IF;
            End If;
            IF NOT g_BOM_RESOURCE_ID_systab.EXISTS(i) Then
                g_BOM_RESOURCE_ID_systab.Extend;
                        g_BOM_RESOURCE_ID_systab(i) := null;
            Else
             IF g_BOM_RESOURCE_ID_systab(i) = fnd_api.g_miss_num Then
                g_BOM_RESOURCE_ID_systab(i) := null;
             End IF;
            End IF;
            IF NOT g_NAMED_ROLE_systab.EXISTS(i) Then
                g_NAMED_ROLE_systab.Extend;
                        g_NAMED_ROLE_systab(i) := null;
            Else
             IF g_NAMED_ROLE_systab(i) = fnd_api.g_miss_char Then
                g_NAMED_ROLE_systab(i) := null;
             End IF;
            End If;
            IF NOT g_INCURRED_BY_RES_FLAG_systab.EXISTS(i) Then
                g_INCURRED_BY_RES_FLAG_systab.Extend;
                        g_INCURRED_BY_RES_FLAG_systab(i) := null;
            Else
             IF g_INCURRED_BY_RES_FLAG_systab(i) = fnd_api.g_miss_char Then
                                g_INCURRED_BY_RES_FLAG_systab(i) := null;
             End IF;
            End If;
            IF NOT g_RATE_BASED_FLAG_systab.EXISTS(i) Then
                g_RATE_BASED_FLAG_systab.Extend;
                        g_RATE_BASED_FLAG_systab(i) :=  null;
            Else
             IF g_RATE_BASED_FLAG_systab(i) = fnd_api.g_miss_char Then
                g_RATE_BASED_FLAG_systab(i) :=  null;
                         End IF;
            End IF;
            If NOT g_TXN_TASK_ID_systab.EXISTS(i) Then
                g_TXN_TASK_ID_systab.Extend;
                        g_TXN_TASK_ID_systab(i) := null;
            Else
             IF g_TXN_TASK_ID_systab(i) = fnd_api.g_miss_num Then
                g_TXN_TASK_ID_systab(i) := null;
             End IF;
            end if;
            If NOT g_TXN_WBS_ELE_VER_ID_systab.EXISTS(i) Then
                g_TXN_WBS_ELE_VER_ID_systab.Extend;
                g_TXN_WBS_ELE_VER_ID_systab(i) := null;
            Else
             IF g_TXN_WBS_ELE_VER_ID_systab(i) = fnd_api.g_miss_num Then
                g_TXN_WBS_ELE_VER_ID_systab(i) := null;
             End if;
            End IF;
            IF NOT g_TXN_RBS_ELEMENT_ID_systab.EXISTS(i) Then
                g_TXN_RBS_ELEMENT_ID_systab.Extend;
                        g_TXN_RBS_ELEMENT_ID_systab(i) := null;
            Else
             IF g_TXN_RBS_ELEMENT_ID_systab(i) = fnd_api.g_miss_num Then
                g_TXN_RBS_ELEMENT_ID_systab(i) := null;
             End IF;
            End IF;
            If NOT g_TXN_PLAN_START_DATE_systab.EXISTS(i) Then
                g_TXN_PLAN_START_DATE_systab.Extend;
                        g_TXN_PLAN_START_DATE_systab(i) := null;
            Else
             IF g_TXN_PLAN_START_DATE_systab(i) = fnd_api.g_miss_date Then
                g_TXN_PLAN_START_DATE_systab(i) := null;
             End IF;
            End IF;
            If NOT g_TXN_PLAN_END_DATE_systab.EXISTS(i) Then
                g_TXN_PLAN_END_DATE_systab.Extend;
                        g_TXN_PLAN_END_DATE_systab(i) := null;
            Else
             IF g_TXN_PLAN_END_DATE_systab(i) = fnd_api.g_miss_date Then
                g_TXN_PLAN_END_DATE_systab(i) := null;
             End IF;
            End If;
                   END LOOP;
                   l_stage := ' End of Loop check any of the index not exists';
                   print_msg(g_debug_flag,l_stage);
                END If;
    End If;

    IF p_calling_mode = 'BUDGET_VERSION' Then
        l_calling_mode := 'BUDGET_VERSION';
    Elsif p_calling_mode = 'PLSQL_TABLE' Then
        l_calling_mode := 'SYSTEM_TABLE';
    End IF;

    /* populate the resource mapping temp tables */
    If p_process_code in ('RES_MAP','RES_RBS_MAP') Then
        If g_resource_list_id is NOT NULL Then
        l_stage := 'Calling Populate populate_resmap_tmp api for Resource List ';
                print_msg(g_debug_flag,l_stage);

        populate_resmap_tmp
            (p_budget_version_id    => g_budget_version_id
            ,p_calling_mode         => l_calling_mode
            ,x_return_status        => l_return_status
        );
                l_stage := 'End of Populate populate_resmap_tmp api NumOfRecsInserted['||g_res_numRecInserted||']';
                print_msg(g_debug_flag,l_stage);

        l_resmap_return_status := 'S';
        If g_res_numRecInserted > 0 AND
           g_call_res_list_mapping_api = 'Y' Then
            /* call resource mapping api */
                    l_stage := 'Calling pa_resource_mapping.map_resource_list api';
                    print_msg(g_debug_flag,l_stage);

            pa_resource_mapping.map_resource_list
            (p_resource_list_id     => g_resource_list_id
            ,p_project_id           => g_project_id
            ,x_return_status    => l_resmap_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data     => l_msg_data
            );

                    l_stage := 'End of pa_resource_mapping.map_resource_list api Resmap RetSts['
                ||l_resmap_return_status||']';
                    print_msg(g_debug_flag,l_stage);
        End If;
        End If;
    End If;

        /* populate the resource mapping temp tables */
        If p_process_code in ('RBS_MAP','RES_RBS_MAP') Then
       If g_rbs_version_id is NOT NULL Then
                l_stage := 'Calling populate_rbsmap_tmp api for RBS ';
                print_msg(g_debug_flag,l_stage);
                populate_rbsmap_tmp
                (p_budget_version_id    => g_budget_version_id
                ,p_calling_mode         => l_calling_mode
                ,x_return_status        => l_return_status
                );
                l_stage := 'End of populate_rbsmap_tmp api for RBS NumOfRecsInserted['||g_rbs_numRecInserted||']';
                print_msg(g_debug_flag,l_stage);
        l_rbsmap_return_status := 'S';
        If g_rbs_numRecInserted > 0 Then
            /** bug fix3658113  is reverted
                        l_stage := 'Calling pa_rbs_mapping.create_mapping_rules api';
                        print_msg(g_debug_flag,l_stage);
                        pa_rbs_mapping.create_mapping_rules
                        (
                        p_rbs_version_id   => g_rbs_version_id
                        ,x_return_status    => l_rbsmap_return_status
                        ,x_msg_count        => l_msg_count
                        ,x_msg_data         => l_msg_data
                        );
                        l_stage := 'End Ofcreate_mapping_rules api RetSts['||l_rbsmap_return_status||']msgData['||l_msg_data||']';
                        print_msg(g_debug_flag,l_stage);
            **/

                        If NVL(l_rbsmap_return_status,'S') = 'S' Then
                                l_stage := 'Calling pa_rbs_mapping.map_rbs_plans api';
                                print_msg(g_debug_flag,l_stage);
                                pa_rbs_mapping.map_rbs_plans
                                (p_rbs_version_id       => g_rbs_version_id
                                ,x_return_status        => l_rbsmap_return_status
                                ,x_msg_count            => l_msg_count
                                ,x_msg_data             => l_msg_data
                                );
                                l_stage := 'End Of pa_rbs_mapping.map_rbs_plans api RetSts['||l_rbsmap_return_status||']';
                                print_msg(g_debug_flag,l_stage);
                        End If;
        End If;
       End If;
    End If;

    If ( g_res_numRecInserted > 0 OR g_rbs_numRecInserted > 0 )Then
        /* After resource mapping read the values from out tmp tables and
        * populate the plsqltables */
        l_stage := 'Calling populate_resrbsmap_outTbls API';
        print_msg(g_debug_flag,l_stage);
        populate_resrbsmap_outTbls
        (p_process_code                 => p_process_code
        ,p_calling_mode                 => l_calling_mode
        ,p_resource_list_id     => g_resource_list_id
        ,p_budget_version_id        => g_budget_version_id
        ,x_return_status                => l_return_status
        );
        l_stage := 'Calling populate_resrbsmap_outTbls API NumofOutRecs['||g_txn_source_id_sqltab.count||
            ']retSts['||l_return_status||']';
                print_msg(g_debug_flag,l_stage);
        /* Assign the output to plsqltabls */
                l_stage := 'Assigning values to OUT Plsql Tabs';
                print_msg(g_debug_flag,l_stage);

        IF p_TXN_SOURCE_ID_tab.count > 0 Then
                FOR i IN 1..p_TXN_SOURCE_ID_tab.COUNT LOOP
                    x_txn_source_id_tab.extend(1);
                    x_res_list_member_id_tab.extend(1);
                    x_rbs_element_id_tab.extend(1);
                    x_txn_accum_header_id_tab.extend(1);
                    IF(p_TXN_SOURCE_ID_tab(i) <> g_txn_source_id_systab(i)) THEN
                            FOR j IN 1..g_txn_source_id_systab.COUNT LOOP
                                IF(g_txn_source_id_systab(j) = p_TXN_SOURCE_ID_tab(i) )  THEN
                                        x_txn_source_id_tab(i) := g_txn_source_id_systab(j);
                                        x_res_list_member_id_tab(i) := g_res_list_member_id_systab(j);
                                        x_rbs_element_id_tab(i) := g_rbs_element_id_systab(j);
                                        x_txn_accum_header_id_tab(i) := g_txn_accum_header_id_systab(j);
                                        EXIT;
                                    END IF;
                            END LOOP;
                    ELSE
                            x_txn_source_id_tab(i) := g_txn_source_id_systab(i);
                            x_res_list_member_id_tab(i) := g_res_list_member_id_systab(i);
                            x_rbs_element_id_tab(i) := g_rbs_element_id_systab(i);
                            x_txn_accum_header_id_tab(i) := g_txn_accum_header_id_systab(i);

                    END IF;
                END LOOP;
            Elsif p_calling_mode = 'BUDGET_VERSION' Then
                       x_txn_source_id_tab := g_txn_source_id_systab;
                       x_res_list_member_id_tab := g_res_list_member_id_systab;
                       x_rbs_element_id_tab := g_rbs_element_id_systab;
                       x_txn_accum_header_id_tab := g_txn_accum_header_id_systab;
                End If;

     End If;

        /* Set the return status of based on the res and rbs mapping api */
        l_stage := 'Setting Return sts based on Res/Rbs mapping ResMapSts['||l_resmap_return_status||
                ']RbsMapSts['||l_rbsmap_return_status||']';
        print_msg(g_debug_flag,l_stage);

    l_stage := 'Out params TabCounts:TxnSrcTab['||x_txn_source_id_tab.count||']RlmiTabCt['||x_res_list_member_id_tab.Count||']';
    l_stage := l_stage||'RbsTab['||x_rbs_element_id_tab.count||']TxnAccTab['||x_txn_accum_header_id_tab.count||']';
        print_msg(g_debug_flag,l_stage);

        If l_resmap_return_status <> 'S' Then
                l_return_status := l_resmap_return_status;
        Else
                If l_rbsmap_return_status <> 'S' Then
                        l_return_status := l_rbsmap_return_status;
                End if;
        End If;

    /* Assign the out put variables */
    x_return_status := l_return_status;
    x_msg_count := l_msg_count;
    x_msg_data      := l_msg_data;

        l_stage := 'End Of PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs API';
        print_msg(g_debug_flag,l_stage);
    /* Reset the error Stack */
    PA_DEBUG.reset_err_stack;

EXCEPTION
        WHEN OTHERS THEN
        print_msg(g_debug_flag,l_stage||':'||SQLCODE||SQLERRM);
                If g_debug_context = 'PLSQL' Then
                        PA_DEBUG.WRITE_FILE('LOG',l_stage);
                        PA_DEBUG.WRITE_FILE('LOG','SQLERROR:'||SQLCODE||SQLERRM);
                Elsif  g_debug_context = 'SELF_SERVICE' Then
                        PA_DEBUG.WRITE_LOG(x_module      => 'pa.plsql.pa_rlmi_rbs_pub.map_rlmi_rbs'
                                          ,x_msg         => l_stage||':'||SQLCODE||SQLERRM
                                          ,x_log_level   => 5 );
                End If;
                FND_MSG_PUB.add_exc_msg
                           ( p_pkg_name       => 'PA_RLMI_RBS_MAP_PUB'
                            ,p_procedure_name => 'Map_Rlmi_Rbs');
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                PA_DEBUG.reset_err_stack;
                RAISE;
END Map_Rlmi_Rbs;

/* This API updates the new frozen RBS version on all affected projects.
 * Befare Calling this API, user has to populate the following global temp Table
 * with all the affected project Ids : pji_pjp_proj_batch_map
 * The out param x_return_status will be 'S' in case of Success, 'E'- Error , 'U' - Unexpected Errors
 */
PROCEDURE Push_RBS_Version
        (p_old_rbs_version_id    IN NUMBER
        ,p_new_rbs_version_id    IN NUMBER
        ,x_return_status     OUT NOCOPY  VARCHAR2
        ,x_msg_count             OUT NOCOPY Number
        ,x_msg_data              OUT NOCOPY Varchar2 ) IS

    CURSOR cur_rbsVersions(p_worker_id Number,p_rbs_header_id NUMBER) IS -- Modified for Bug 6450168
    SELECT fp.project_id		 project_id
	  ,fp.fin_plan_option_level_code finplan_option_level
          ,fp.fin_plan_version_id        budget_version_id
          ,fp.Rbs_version_id
	  ,fp.proj_fp_options_id
	  ,pp.segment1  		 project_name
	  ,bv.version_name		 version_name
	  ,fptyp.name                    plan_type_name
    FROM pa_budget_versions bv
          ,pa_proj_fp_options fp
          ,pji_pjp_proj_batch_map rbs
	  ,pa_projects_all pp
	  ,pa_fin_plan_types_tl fptyp
          ,pa_rbs_versions_b rvb -- Added for Bug 6450168
    WHERE bv.budget_version_id (+) = fp.fin_plan_version_id
    AND   nvl(bv.project_id,fp.project_id) = fp.project_id
    ANd   fp.project_id = rbs.project_id
    AND   fp.project_id = pp.project_id
    AND   fp.rbs_version_id = rvb.rbs_version_id -- Added for Bug 6450168
    AND   rvb.rbs_header_id = p_rbs_header_id    -- Added for Bug 6450168
--    AND   rbs.PROJECT_ACTIVE_FLAG = 'Y'  --commented for bug 4579741
    AND   rbs.WORKER_ID = p_worker_id
    AND   fp.fin_plan_type_id = fptyp.fin_plan_type_id (+)
    AND   NVL(fptyp.language,userenv('LANG')) = userenv('LANG')
    ORDER BY fp.project_id,bv.budget_version_id
    FOR UPDATE OF fp.proj_fp_options_id,bv.budget_version_id ;

	CURSOR check_ResAsgn_Exists(p_budget_version_id  Number) IS
	SELECT 'Y'
	FROM dual
	WHERE EXISTS (select null
		      from pa_resource_assignments ra
		      where ra.budget_version_id = p_budget_version_id);

	CURSOR rbs_name IS
	SELECT rbs1.name old_rbs_name
       		,rbs2.name new_rbs_name
	FROM pa_rbs_versions_v rbs1
    	    ,pa_rbs_versions_v rbs2
	WHERE rbs1.rbs_version_id = p_old_rbs_version_id
	AND rbs2.rbs_version_id = p_new_rbs_version_id;

	rbsnameRec  rbs_name%rowtype;

        l_txn_source_id_tab             PA_PLSQL_DATATYPES.IdTabTyp := PA_PLSQL_DATATYPES.EmptyIdTab;
        l_res_list_member_id_tab        PA_PLSQL_DATATYPES.IdTabTyp := PA_PLSQL_DATATYPES.EmptyIdTab;
        l_rbs_element_id_tab            PA_PLSQL_DATATYPES.IdTabTyp := PA_PLSQL_DATATYPES.EmptyIdTab;
        l_txn_accum_header_id_tab       PA_PLSQL_DATATYPES.IdTabTyp := PA_PLSQL_DATATYPES.EmptyIdTab;
    	l_calling_mode              Varchar2(100);
    	l_calling_context           Varchar2(100);
    	l_prev_project_id       Number;
    	l_return_status         Varchar2(100);
        l_msg_count             Number;
        l_msg_data          Varchar2(1000);
    	l_stage             Varchar2(1000);
    	l_worker_id                     Number;
	l_resAsgnExistsFlag      Varchar2(10) := 'N';
	l_proc_name       varchar2(100) := 'Push_RBS_Version';
	l_msg_index_out   Number;
	INVALID_PARAMS    EXCEPTION;
        l_process         varchar2(30); -- Added for Bug 6450168
        l_rbs_header_id   Number;       -- Added for Bug 6450168

BEGIN
        /* INitizalize the out variables*/
        x_return_status := 'S';
        l_return_status := 'S';
        x_msg_data      := Null;
        x_msg_count     := Null;

        --- Initialize the error statck
        PA_DEBUG.init_err_stack ('PA_RLMI_RBS_MAP_PUB.Push_RBS_Version');

        fnd_profile.get('PA_DEBUG_MODE',g_debug_flag);
        g_debug_flag := NVL(g_debug_flag, 'N');

	/* Initialize the msg stack */
        FND_MSG_PUB.initialize;

	/* Bug fix: 4345057 */
        If NVL(g_debug_flag,'N') = 'Y' Then
           PA_DEBUG.SET_PROCESS( x_process => 'PLSQL'
                      ,x_write_file     => 'LOG'
                      ,x_debug_mode      => g_debug_flag
                          );
	End If;

        l_stage := 'Begin of RBS_PUSH API: IN Param OldRbsVer['||p_old_rbs_version_id||']NewRbsVer['||p_new_rbs_version_id||']';
        Print_msg(g_debug_flag,l_stage,l_proc_name);

        /* this initializes the tmp table */
        l_worker_id := PJI_PJP_EXTRACTION_UTILS.GET_WORKER_ID;

/* Added for Bug 6450168 - START */
  l_process := PJI_PJP_SUM_MAIN.g_process || to_char(l_worker_id);
  l_rbs_header_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,'RBS_HEADER_ID');
/* Added for Bug 6450168 - END */

	If p_old_rbs_version_id is NULL OR p_new_rbs_version_id is NULL OR l_worker_id is NULL Then
		print_msg(g_debug_flag,'Invalid Params',l_proc_name);
                Raise Invalid_params;
        END If;

	OPEN rbs_name;
	FETCH rbs_name INTO rbsnameRec;
	CLOSE rbs_name;

    	/* For Each budget version Id call the RBS mapping api and update the
         * the rbs_element_id from the tmp table on proj_fp_options, budget versions, and resource assignments
         * table
         */
    	l_prev_project_id := NULL;
        FOR i IN cur_rbsVersions(l_worker_id,l_rbs_header_id) LOOP  --{
        	l_stage := 'Inside loop For Finplanlevel['||i.finplan_option_level||']Project['||i.project_id||']Bdgt['||i.budget_version_id||']';
        	Print_msg(g_debug_flag,l_stage,l_proc_name);
		l_return_status := 'S';
        	l_msg_count := Null;
        	l_msg_data  := Null;

	    /* Bug fix: 3977666 As discussed with Vijay Ranganathan, The proj fp options must be updated first and then
             * to call the RBS mapping api. So moving the code of updating pa_proj_fp_options at end to first */
             /* once all the mapping is done for the project update the fp options at plan Type and project level and version level
             */
             l_stage := 'Update pa proj fp options with RBS details: FpOptionId['||i.proj_fp_options_id||']BdgtVer['||i.budget_version_id||']';
             Print_msg(g_debug_flag,l_stage,l_proc_name);
             UPDATE pa_proj_fp_options fp
             SET fp.rbs_version_id = p_new_rbs_version_id
                   ,fp.record_version_number = nvl(fp.record_version_number,0) +1
             WHERE fp.project_id = i.Project_id
             --AND  fp.rbs_version_id = p_old_rbs_version_id -- Commented for Bug 6450168
             AND  fp.proj_fp_options_id = i.proj_fp_options_id;
             print_msg(g_debug_flag,'NumberOfRowsUpdated['||sql%rowcount||']',l_proc_name);

	    /* Call rbs mapping at plan version level */
	    IF i.budget_version_id is NOT NULL Then  --{
        	/* Initialize the plsql tables*/
        	l_txn_source_id_tab.delete;
        	l_res_list_member_id_tab.delete;
        	l_rbs_element_id_tab.delete;
        	l_txn_accum_header_id_tab.delete;

		l_resAsgnExistsFlag := 'N';
		OPEN check_ResAsgn_Exists(i.budget_version_id);
		FETCH check_ResAsgn_Exists INTO l_resAsgnExistsFlag;
		IF check_ResAsgn_Exists%NOTFOUND THEN
			l_resAsgnExistsFlag := 'N';
		END IF;
		CLOSE check_ResAsgn_Exists;

		IF nvl(l_resAsgnExistsFlag,'N') = 'Y' Then
			print_msg(g_debug_flag,'Calling PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs API l_resAsgnExistsFlag['||l_resAsgnExistsFlag||']',l_proc_name);
			l_return_status := 'S';
        		PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs
        		( p_budget_version_id           => i.budget_version_id
        		,p_resource_list_id             => Null
        		,p_rbs_version_id               => p_new_rbs_version_id
        		,p_calling_process              => 'RBS_PUSH'
        		,p_calling_context              => 'PLSQL'
        		,p_process_code                 => 'RBS_MAP'
        		,p_calling_mode                 => 'BUDGET_VERSION'
        		,p_init_msg_list_flag           => 'N'
        		,p_commit_flag                  => 'N'
        		,x_txn_source_id_tab            => l_txn_source_id_tab
        		,x_res_list_member_id_tab       => l_res_list_member_id_tab
        		,x_rbs_element_id_tab           => l_rbs_element_id_tab
        		,x_txn_accum_header_id_tab      => l_txn_accum_header_id_tab
        		,x_return_status                => l_return_status
        		,x_msg_count                    => l_msg_count
        		,x_msg_data                     => l_msg_data
        		);
                      l_stage := 'End of Map_Rlmi_Rbs RetSts['||l_return_status||']MsgData['||l_msg_data||']txnSrcTabCount['||l_txn_source_id_tab.count||']';
        	      l_stage := l_stage||'RlmiTabCount['||l_res_list_member_id_tab.count||']RbsEleTabCount['||l_rbs_element_id_tab.count||']';
        	      l_stage := l_stage||'TxnAccHeadCount['||l_txn_accum_header_id_tab.count||']';
        	      Print_msg(g_debug_flag,l_stage,l_proc_name);
		      pa_debug.write_file('LOG',l_stage);

		      IF NVL(l_return_status,'E') <> 'S' Then
				l_stage := 'PA_FP_RBS_PUSH_ERROR: '||'OLD_RBS_VERSION['||rbsnameRec.old_rbs_name||']NEW_RBS_VERSION['||rbsnameRec.new_rbs_name;
				l_stage := substr(l_stage||']PROJECT_NAME['||i.project_name||']PLAN_VERSION_NAME['||i.version_name,1,1000);
			        l_stage := substr(l_stage||']PLAN_TYPE['||i.plan_type_name||']',1,1000);
				l_stage := substr(l_stage,1,1000);
				print_msg(g_debug_flag,l_stage,l_proc_name);

        			pa_utils.add_message
            			( p_app_short_name => 'PA'
              			,p_msg_name       => 'PA_FP_RBS_PUSH_ERROR'
                		,p_token1       => 'OLD_RBS_VERSION'
                		,p_value1       => rbsnameRec.old_rbs_name
                		,p_token2       => 'NEW_RBS_VERSION'
                		,p_value2       => rbsnameRec.new_rbs_name
                		,p_token3       => 'PROJECT_NAME'
                		,p_value3       => i.project_name
                		,p_token4       => 'PLAN_VERSION_NAME'
                		,p_value4       => i.version_name
                		,p_token5       => 'PLAN_TYPE'
                		,p_value5       => i.plan_type_name
            			);
		     END IF;

        	      /* update the resource assignment table with the new rbs details */
        	      If l_txn_source_id_tab.count > 0  AND l_return_status = 'S' Then
            		l_stage := 'Update Resource assignments with new RBS details';
            		Print_msg(g_debug_flag,l_stage,l_proc_name);
            		FORALL j IN l_txn_source_id_tab.FIRST ..l_txn_source_id_tab.LAST
            			UPDATE pa_resource_assignments ra
            			SET ra.rbs_element_id = NVL(l_rbs_element_id_tab(j),ra.rbs_element_id)
               			   ,ra.txn_accum_header_id = NVL(l_txn_accum_header_id_tab(j),ra.txn_accum_header_id)
            			WHERE ra.budget_version_id = i.budget_version_id
            			AND   ra.project_id = i.project_id
            			AND   ra.resource_assignment_id = l_txn_source_id_tab(j) ;
		      End If;

		End If;  --end of l_resAsgnExistsFlag =Y

		If l_return_status = 'S' Then
            		/* update the budget version recod version nubmer, so that any changes in the rbs version related to
            		* old budget version should be in synch with these changes
            		*/
                	l_stage := 'Update pa_budget_versions with recordVerNum:BdgtVer['||i.budget_version_id||']';
                	Print_msg(g_debug_flag,l_stage);
                	UPDATE pa_budget_versions bv
                	SET bv.record_version_number = nvl(bv.record_version_number,0) +1
                	WHERE bv.budget_version_id = i.budget_version_id;

		End If;
            End if;  --}

    	END LOOP;  --}

    	x_return_status := l_return_status;
    	x_msg_data      := l_msg_data;
    	x_msg_count     := l_msg_count;

	x_msg_count := fnd_msg_pub.count_msg;
	If x_msg_count is NULL then x_msg_count := 0; End if;
        IF x_msg_count = 1 THEN
               pa_interface_utils_pub.get_messages
               ( p_encoded       => FND_API.G_TRUE
               ,p_msg_index     => 1
               ,p_data          => x_msg_data
               ,p_msg_index_out => l_msg_index_out
               );
		x_return_status := 'E';
        ELSIF x_msg_count > 1 THEN
               x_msg_count := x_msg_count;
               x_msg_data := null;
	       x_return_status := 'E';
        END IF;

    	l_stage := 'End Push_RBS_Version API: RtrnSts['||x_return_status||']x_msg_count['||x_msg_count||']';
    	Print_msg(g_debug_flag,l_stage,l_proc_name);

        /* Reset the error Stack */
        PA_DEBUG.reset_err_stack;

EXCEPTION

	WHEN INVALID_PARAMS THEN

		print_msg(g_debug_flag,l_stage||':'||'INVALID_PARAMS',l_proc_name);
                PA_DEBUG.WRITE_FILE('LOG',l_stage);
                PA_DEBUG.WRITE_FILE('LOG','SQLERROR:'||SQLCODE||SQLERRM);
                FND_MSG_PUB.add_exc_msg
                           ( p_pkg_name       => 'PA_RLMI_RBS_MAP_PUB'
                            ,p_procedure_name => 'Push_RBS_Version');
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		x_msg_data := 'INVALID_PARAMS';
                PA_DEBUG.reset_err_stack;
        WHEN OTHERS THEN
                print_msg(g_debug_flag,l_stage||':'||SQLCODE||SQLERRM,l_proc_name);
                PA_DEBUG.WRITE_FILE('LOG',l_stage);
                PA_DEBUG.WRITE_FILE('LOG','SQLERROR:'||SQLCODE||SQLERRM);
                FND_MSG_PUB.add_exc_msg
                           ( p_pkg_name       => 'PA_RLMI_RBS_MAP_PUB'
                            ,p_procedure_name => 'Push_RBS_Version');
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                PA_DEBUG.reset_err_stack;
                RAISE;

END Push_RBS_Version;


END PA_RLMI_RBS_MAP_PUB ;

/
