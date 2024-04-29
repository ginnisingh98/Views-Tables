--------------------------------------------------------
--  DDL for Package Body PA_CI_SUPPLIER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_SUPPLIER_PKG" as
-- $Header: PACISIIB.pls 120.0.12010000.16 2010/04/13 15:48:41 gboomina ship $
PROCEDURE print_msg(p_msg  varchar2) IS
BEGIN
      --dbms_output.put_line('Log:'||p_msg);
      --r_debug.r_msg('Log:'||p_msg);
	PA_DEBUG.g_err_stage := p_msg;
        PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);
	null;
END print_msg;

PROCEDURE insert_row (
	x_rowid                        IN OUT NOCOPY VARCHAR2
	,x_CI_TRANSACTION_ID           IN OUT NOCOPY NUMBER
 	,p_CI_TYPE_ID                  IN   NUMBER
 	,p_CI_ID                       IN   NUMBER
 	,p_CI_IMPACT_ID                IN   NUMBER
 	,p_VENDOR_ID                   IN   NUMBER
 	,p_PO_HEADER_ID                IN   NUMBER
 	,p_PO_LINE_ID                  IN   NUMBER
 	,p_ADJUSTED_TRANSACTION_ID     IN   NUMBER
 	,p_CURRENCY_CODE               IN   VARCHAR2
 	,p_CHANGE_AMOUNT               IN   NUMBER
 	,p_CHANGE_TYPE                 IN   VARCHAR2
 	,p_CHANGE_DESCRIPTION          IN   VARCHAR2
    ,p_CREATED_BY                  IN   NUMBER
    ,p_CREATION_DATE               IN   DATE
    ,p_LAST_UPDATED_BY             IN   NUMBER
    ,p_LAST_UPDATE_DATE            IN   DATE
    ,p_LAST_UPDATE_LOGIN           IN   NUMBER
    ,p_Task_Id                     IN NUMBER
	,p_Resource_List_Mem_Id        IN NUMBER
	,p_From_Date                   IN varchar2
	,p_To_Date                     IN varchar2
	,p_Estimated_Cost              IN NUMBER
	,p_Quoted_Cost                 IN NUMBER
	,p_Negotiated_Cost             IN NUMBER
	,p_Burdened_cost               IN NUMBER
	,p_Revenue                     IN NUMBER default NULl
	,p_revenue_override_rate       in number
    ,p_audit_history_number        in number
    ,p_current_audit_flag          in varchar2
    ,p_Original_supp_trans_id      in number
    ,p_Source_supp_trans_id        in number
	,p_Sup_ref_no                  in number default null
	,p_version_type                in varchar2 default 'ALL'
	,p_ci_status            	   IN   VARCHAR2
 -- gboomina modified for supplier cost 12.1.3 requirement - start
 ,p_expenditure_type            in varchar2  default null
 ,p_expenditure_org_id          in number  default null
 ,p_change_reason_code          in varchar2  default null
 ,p_quote_negotiation_reference in varchar2  default null
 ,p_need_by_date                in varchar2  default null
 -- gboomina modified for supplier cost 12.1.3 requirement - end
	,x_return_status               OUT NOCOPY  VARCHAR2
	,x_error_msg_code              OUT NOCOPY  VARCHAR2
                      )IS
  cursor return_rowid is
   select rowid
   from pa_ci_supplier_details
   where ci_transaction_id = x_CI_TRANSACTION_ID;

  cursor get_itemid is
	   select pa_ci_supplier_details_s.nextval
   from sys.dual;

   cursor get_budget_data(bvId number) is
   select prac.total_projfunc_burdened_cost , prac.total_projfunc_revenue, prac.txn_average_bill_rate
   from pa_resource_assignments pra, pa_resource_asgn_curr prac
   where
      pra.budget_version_id = bvId and pra.task_id = p_task_id and
	  pra.resource_list_member_id = p_Resource_List_Mem_Id and
	  prac.resource_assignment_id = pra.resource_assignment_id;

   cursor get_ciTypeId is
      select ci_type_id
	  from pa_control_items
	  where ci_id = p_ci_id;

   cursor get_res_asgn_id is
	   select pa_resource_assignments_s.nextval
   from sys.dual;

   cursor get_burdened_cost(ci_trans_id number) is
   select final_cost from pa_ci_supplier_details
   where ci_transaction_id = ci_trans_id;

   cursor get_budget_version_id is
      select budget_version_id
	  from pa_budget_versions
	  where ci_id = p_ci_id;

    cursor get_budget_cost_version_id(proj_id number) is
      SELECT budget_version_id FROM pa_budget_versions
	  WHERE ci_id = p_ci_id and
	  budget_version_id in (select fin_plan_version_id from pa_proj_fp_options where project_id = proj_id and fin_plan_preference_code = 'COST_ONLY');

	  cursor get_budget_rev_version_id(proj_id number) is
      SELECT budget_version_id FROM pa_budget_versions
	  WHERE ci_id = p_ci_id and
	  budget_version_id in (select fin_plan_version_id from pa_proj_fp_options where project_id = proj_id and fin_plan_preference_code = 'REVENUE_ONLY');

	cursor get_project_id is
      select project_id
	  from pa_control_items
	  where ci_id = p_ci_id;

	cursor get_elem_ver_id (proj_id number) is
      select pev.element_version_id,parent_structure_version_id
	  from pa_proj_element_versions pev,pa_proj_elem_ver_structure pevs
	  where pev.project_id=proj_id and pev.project_id=pevs.project_id
	  and pev.proj_element_id=p_task_id and pev.parent_structure_version_id=pevs.element_version_id
	  and pevs.CURRENT_FLAG='Y';

	cursor get_elem_ver_all_id (proj_id number) is
      select pev.element_version_id,parent_structure_version_id
	  from pa_proj_element_versions pev,pa_proj_elem_ver_structure pevs
	  where pev.project_id=proj_id and pev.project_id=pevs.project_id
	  and pev.proj_element_id=p_task_id and pev.parent_structure_version_id=pevs.element_version_id
	  and pevs.CURRENT_WORKING_FLAG='Y';



	cursor get_resource_assignment_id(bv_Id number) is
       select resource_assignment_id,
              unit_of_measure,
              project_assignment_id,
			  organization_id,
			  supplier_id,
			  spread_curve_id,
			  etc_method_code,
			  mfc_cost_type_id,
			  procure_resource_flag,
			  decode(use_task_schedule_flag,'Y','Y','N') as use_task_schedule_flag,
			  planning_start_date,
			  planning_end_date,
			  schedule_start_date,
			  schedule_end_date,
			  sp_fixed_date,
			  named_role
       from pa_resource_assignments
       where budget_version_id = bv_Id
	     and task_id = p_Task_Id
         and resource_list_member_id = p_Resource_List_Mem_Id;

	cursor get_resource_details is
      select ORGANIZATION_ID
         	 ,SPREAD_CURVE_ID
			 ,ETC_METHOD_CODE
             ,RESOURCE_CLASS_CODE
			 ,RESOURCE_CLASS_FLAG
			 ,RECORD_VERSION_NUMBER
             ,INCURRED_BY_RES_FLAG
			 ,UNIT_OF_MEASURE
			 ,RESOURCE_TYPE_CODE
      from pa_resource_list_members where RESOURCE_LIST_MEMBER_ID = p_Resource_List_Mem_Id;

   cursor get_cost_rate_id is
   SELECT
		ppfo.use_planning_rates_flag,
		ppfo.RES_CLASS_RAW_COST_SCH_ID,
		ppfo.COST_RES_CLASS_RATE_SCH_ID,
		ppfo.RES_CLASS_BILL_RATE_SCH_ID,
		ppfo.REV_RES_CLASS_RATE_SCH_ID
	FROM pa_proj_fp_options ppfo,
	     pa_control_items pci
	WHERE pci.ci_id = p_ci_id and
	      pci.project_id = ppfo.project_id and
          NVL(ppfo.Approved_Cost_Plan_Type_Flag ,'N') = 'Y' and
          ppfo.Fin_Plan_Option_Level_Code = 'PLAN_TYPE';

	cursor get_cost_markup(p_rate_sch_id number) is
	select rate from PA_BILL_RATES_ALL
	WHERE bill_rate_sch_id = p_rate_sch_id AND
	resource_class_code = 'FINANCIAL_ELEMENTS' and
	trunc(Nvl(to_date(null,'YYYY.MM.DD'),start_date_active)) between trunc(start_date_active)
                        and trunc(nvl(end_date_active,Nvl(to_date(null,'YYYY.MM.DD'),start_date_active)));

   res_info get_resource_details%rowtype;
   l_audit_history_number number := p_audit_history_number;
   l_return_status        varchar2(100) := 'S';
   l_error_msg_code       varchar2(100) := NULL;
   l_msg_count  number := 0;
   l_debug_mode           varchar2(1) := 'N';
   l_CHANGE_DESCRIPTION varchar2(100);
   l_CI_TRANSACTION_ID NUMBER;
   l_original_supp_id number := p_Original_supp_trans_id;
   l_source_supp_id number := p_Source_supp_trans_id;
   l_markup_cost number := 0;
    l_res_rate_sch_id number :=0;
	l_use_planning_rates_flag varchar2(1) :='N';
	l_cost_rate_sch_id number :=0;
	l_cost_rate number := 0;
    l_res_bill_sch_id number := 0;
	l_rev_rate_sch_id number := 0;
	l_revenue_rate number :=0;
	l_revenue number :=0;
	l_burdened_cost number := 0;
	l_bvId number := 0;
	l_res_asgn_Id number := 0;
	l_project_id number := 0;
	l_CI_TYPE_ID number := 0;
	l_elem_ver_id number := 0;
	L_BUR_COST number := 0;

	--defining the table type variables for insert into budget operation
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
  l_expenditure_type_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();

    --defining the table type variables for update into budget operation
l_task_name_tbl                SYSTEM.PA_VARCHAR2_240_TBL_TYPE    := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
l_task_number_tbl              SYSTEM.PA_VARCHAR2_100_TBL_TYPE    := SYSTEM.PA_VARCHAR2_100_TBL_TYPE();
l_in_start_date_tbl            SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
l_in_end_date_tbl              SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
l_planned_people_effort_tbl    SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_resource_assignment_id_tbl   SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_assignment_description_tbl   SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
l_project_assignment_id_tbl    SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_planning_resource_alias_tbl  SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
l_resource_class_flag_tbl      SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_resource_class_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_resource_class_id_tbl        SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_res_type_code_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_resource_code_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_resource_name                SYSTEM.PA_VARCHAR2_240_TBL_TYPE    := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
l_project_role_id_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_project_role_name_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_organization_id_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_organization_name_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE    := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
l_fc_res_type_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_financial_category_code_tbl  SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_supplier_id_tbl              SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_unit_of_measure_tbl          SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_spread_curve_id_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_etc_method_code_tbl          SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_mfc_cost_type_id_tbl         SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_procure_resource_flag_tbl    SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_incurred_by_res_flag_tbl     SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_incur_by_resource_name_tbl   SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
l_Incur_by_resource_code_tbl   SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_use_task_schedule_flag_tbl   SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_planning_start_date_tbl      SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
l_planning_end_date_tbl        SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
l_schedule_start_date_tbl      SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
l_schedule_end_date_tbl        SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
l_total_quantity_tbl           SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_override_currency_code_tbl   SYSTEM.PA_VARCHAR2_15_TBL_TYPE    := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
l_total_raw_cost_tbl           SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_raw_cost_rate_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_bill_rate_override_tbl       SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_billable_percent_tbl         SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_cost_rate_override_tbl       SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_burdened_rate_override_tbl   SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_sp_fixed_date_tbl            SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
l_named_role_tbl               SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
l_financial_category_name_tbl  SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
l_supplier_name_tbl            SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
l_attribute_category_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_attribute1_tbl               SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_scheduled_delay              SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_direct_expenditure_type_tbl  SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_struct_elem_version_id Pa_proj_element_versions.element_version_id%TYPE := -1;



 BEGIN
   fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   l_debug_mode := NVL(l_debug_mode, 'N');
   pa_debug.set_process('PLSQL','LOG',l_debug_mode);

  IF l_debug_mode = 'Y' THEN
	print_msg('Inside pa_ci_supplier_pkg table handler..');
  End IF;

    open get_itemid;
    fetch get_itemid into x_ci_transaction_id;
    close get_itemid;

   if (p_CI_TYPE_ID is null) then
    open get_ciTypeId;
    fetch get_ciTypeId into l_CI_TYPE_ID;
    close get_ciTypeId;
   else
    l_CI_TYPE_ID := p_CI_TYPE_ID;
  end if;


  IF l_debug_mode = 'Y' THEN
	print_msg('Info transacton id ..'||x_ci_transaction_id);
  End IF;
  l_CHANGE_DESCRIPTION := '';

  if (p_Original_supp_trans_id is null OR p_Original_supp_trans_id = 0) THEN
    l_original_supp_id := x_ci_transaction_id;
  end if;

   if (p_Source_supp_trans_id is null OR p_Source_supp_trans_id = 0) THEN
    l_source_supp_id := x_ci_transaction_id;
  end if;

  if (p_audit_history_number is null OR p_audit_history_number = -99) THEN
     l_audit_history_number := 1;
  end if;

  open get_cost_rate_id;
  fetch get_cost_rate_id into l_use_planning_rates_flag, l_res_rate_sch_id,l_cost_rate_sch_id,l_res_bill_sch_id,l_rev_rate_sch_id;
  close get_cost_rate_id;

  if l_use_planning_rates_flag = 'Y' THEN
     open get_cost_markup(l_cost_rate_sch_id);
	 fetch get_cost_markup into l_cost_rate;
	 close get_cost_markup;
	 open get_cost_markup(l_res_bill_sch_id);
	 fetch get_cost_markup into l_revenue_rate;
	 close get_cost_markup;
   else
      open get_cost_markup(l_res_rate_sch_id);
	 fetch get_cost_markup into l_cost_rate;
	 close get_cost_markup;
	 open get_cost_markup(l_rev_rate_sch_id);
	 fetch get_cost_markup into l_revenue_rate;
	 close get_cost_markup;
     end if;

	 if p_revenue_override_rate is not null then
	   if p_CHANGE_AMOUNT is not null then
	    l_revenue := (p_CHANGE_AMOUNT*l_cost_rate)*p_revenue_override_rate;
		end if;
	else
	   if p_CHANGE_AMOUNT is not null then
	    l_revenue := (p_CHANGE_AMOUNT*l_cost_rate)*l_revenue_rate;
		end if;
	end if;

  INSERT into pa_ci_supplier_details
	(  CI_TRANSACTION_ID
 	  ,CI_TYPE_ID
 	  ,CI_ID
 	  ,CI_IMPACT_ID
 	  ,VENDOR_ID
 	  ,PO_HEADER_ID
 	  ,PO_LINE_ID
 	  ,ADJUSTED_CI_TRANSACTION_ID
 	  ,CURRENCY_CODE
 	  ,CHANGE_AMOUNT
 	  ,CHANGE_TYPE
 	  ,CHANGE_DESCRIPTION
 	  ,CREATED_BY
 	  ,CREATION_DATE
 	  ,LAST_UPDATED_BY
 	  ,LAST_UPDATE_DATE
 	  ,LAST_UPDATE_LOGIN
	  ,TASK_ID
	  ,RESOURCE_LIST_MEMBER_ID
	  ,FROM_CHANGE_DATE
	  ,TO_CHANGE_DATE
	  ,ESTIMATED_COST
	  ,QUOTED_COST
	  ,NEGOTIATED_COST
	  ,FINAL_COST
	  ,RAW_COST
	  ,BURDENED_COST
	  ,revenue_rate
	  ,revenue_override_rate
	  ,revenue
	  ,total_revenue
 	  ,CURRENT_AUDIT_FLAG
      ,STATUS
      ,audit_history_number
      ,original_supp_trans_id
      ,source_supp_trans_id
	  ,sup_quote_ref_no
   -- gboomina modified for supplier cost 12.1.3 requirement - start
   ,expenditure_type
   ,expenditure_org_id
   ,change_reason_code
   ,quote_negotiation_reference
   ,need_by_date
   -- gboomina modified for supplier cost 12.1.3 requirement - end
	) VALUES
        ( x_CI_TRANSACTION_ID
          ,l_CI_TYPE_ID
          ,p_CI_ID
          ,p_CI_IMPACT_ID
          ,p_VENDOR_ID
          ,p_PO_HEADER_ID
          ,p_PO_LINE_ID
          ,p_ADJUSTED_TRANSACTION_ID
          ,p_CURRENCY_CODE
          ,pa_currency.round_trans_currency_amt
                     (decode(p_CHANGE_AMOUNT,null,0,p_CHANGE_AMOUNT),p_CURRENCY_CODE)
          ,p_CHANGE_TYPE
          ,NVL(p_CHANGE_DESCRIPTION,l_CHANGE_DESCRIPTION)
          ,p_CREATED_BY
          ,p_CREATION_DATE
          ,p_LAST_UPDATE_LOGIN
          ,p_LAST_UPDATE_DATE
          ,p_LAST_UPDATE_LOGIN
		  ,p_Task_Id
		  ,p_Resource_List_Mem_Id
		  ,to_date(p_From_Date)
		  ,to_date(p_To_Date)
		  ,pa_currency.round_trans_currency_amt
                     (decode(p_Estimated_Cost,null,0,p_Estimated_Cost),p_CURRENCY_CODE)
		  ,pa_currency.round_trans_currency_amt
                     (decode(p_Quoted_Cost,null,0,p_Quoted_Cost),p_CURRENCY_CODE)
		  ,pa_currency.round_trans_currency_amt
                     (decode(p_Negotiated_Cost,null,0,p_Negotiated_Cost),p_CURRENCY_CODE)
		  ,pa_currency.round_trans_currency_amt
                     (decode(p_Burdened_cost,null,(p_CHANGE_AMOUNT+(p_CHANGE_AMOUNT*0.1)),p_Burdened_cost),p_CURRENCY_CODE)
          ,pa_currency.round_trans_currency_amt
                     (decode(p_CHANGE_AMOUNT,null,0,p_CHANGE_AMOUNT),p_CURRENCY_CODE)
		  ,pa_currency.round_trans_currency_amt
                     (decode(p_Burdened_cost,null,(p_CHANGE_AMOUNT+(p_CHANGE_AMOUNT*0.1)),p_Burdened_cost),p_CURRENCY_CODE)
          ,l_revenue_rate
		  ,p_revenue_override_rate
		  ,pa_currency.round_trans_currency_amt
                     (decode(l_revenue,null,0,l_revenue),p_CURRENCY_CODE)
		  ,pa_currency.round_trans_currency_amt
                     (decode(l_revenue,null,0,l_revenue),p_CURRENCY_CODE)
		  ,'Y'
          ,p_version_type
          ,l_audit_history_number
          ,l_original_supp_id
          ,l_source_supp_id
		  ,p_Sup_ref_no
         -- gboomina modified for supplier cost 12.1.3 requirement - start
         ,p_expenditure_type
         ,p_expenditure_org_id
         ,p_change_reason_code
         ,p_quote_negotiation_reference
         ,to_date(p_need_by_date)
         -- gboomina modified for supplier cost 12.1.3 requirement - end
        );
		IF (l_audit_history_number > 1) then
		   update pa_ci_supplier_details set CURRENT_AUDIT_FLAG = 'N' where ci_transaction_id = l_source_supp_id;
		end if;
/*
     OPEN return_rowid;
     FETCH return_rowid into x_rowid;
     IF  (return_rowid%notfound) then
	l_return_status := 'E';
	l_error_msg_code := 'NO_DATA_FOUND';
	IF l_debug_mode = 'Y' THEN
		print_msg('rowid not found raise insert failed');
	End If;
        raise NO_DATA_FOUND;  -- should we return something else?
     Else
	IF l_debug_mode = 'Y' THEN
		print_msg('Insert success');
	End If;
	l_return_status := 'S';
	l_error_msg_code := NULL;
     End if;
     CLOSE return_rowid;

	IF (p_task_id is not null AND p_Resource_List_Mem_Id is not null) then
	     open get_project_id;
         fetch get_project_id into l_project_id;
         close get_project_id;
	   --checking for budget version id
	   if (p_version_type = 'ALL') then
	      OPEN get_budget_version_id;
	      FETCH get_budget_version_id INTO l_bvId;
	      If get_budget_version_id%NOTFOUND then
	        If l_debug_mode = 'Y' Then
	    		print_msg('row not found return');
		    End If;
		    return;
	     End If;
	     CLOSE get_budget_version_id;
	   elsif (p_version_type = 'COST') then
	      OPEN get_budget_cost_version_id(l_project_id);
	      FETCH get_budget_cost_version_id INTO l_bvId;
	      If get_budget_cost_version_id%NOTFOUND then
	        If l_debug_mode = 'Y' Then
	    		print_msg('row not found return');
		    End If;
		    return;
	     End If;
	   CLOSE get_budget_cost_version_id;
	   else
         OPEN get_budget_rev_version_id(l_project_id);
	      FETCH get_budget_rev_version_id INTO l_bvId;
	      If get_budget_rev_version_id%NOTFOUND then
	        If l_debug_mode = 'Y' Then
	    		print_msg('row not found return');
		    End If;
		    return;
	     End If;
	   CLOSE get_budget_rev_version_id;
	   end if;

	   --budget version id not null
	  IF l_bvId is not null then
	    IF (l_audit_history_number = 1) then
	     --task_element_version_id

		 l_task_elem_version_id_tbl.extend(1);
		 if (p_version_type = 'ALL') then
		    open get_elem_ver_all_id(l_project_id);
            fetch get_elem_ver_all_id into l_task_elem_version_id_tbl(1), l_struct_elem_version_id;
            close get_elem_ver_all_id;
		 else
		 open get_elem_ver_id(l_project_id);
         fetch get_elem_ver_id into l_task_elem_version_id_tbl(1), l_struct_elem_version_id;
         close get_elem_ver_id;
		 end if;
		 --l_task_elem_version_id_tbl(1) := p_task_id;
		 --resource list member id
		 l_resource_list_member_id_tbl.extend(1);
		 l_resource_list_member_id_tbl(1) := p_Resource_List_Mem_Id;

		 --quantity
		 l_quantity_tbl.extend(1);
		 l_quantity_tbl(1) := NULL;

		 --currency code
		 l_currency_code_tbl.extend(1);
		 l_currency_code_tbl(1) := p_CURRENCY_CODE;

		 --burdened cost
		 l_burdened_cost_tbl.extend(1);
		 l_burdened_cost_tbl(1) := p_Burdened_cost;

		 --raw cost
		 l_raw_cost_tbl.extend(1);
		 l_raw_cost_tbl(1) := NVL(p_CHANGE_AMOUNT,0);

		 --revenue
		 l_revenue_tbl.extend(1);
		 l_revenue_tbl(1) := p_Revenue;

		 --cost rate
		 l_cost_rate_tbl.extend(1);
		 l_cost_rate_tbl(1) := NULL;

		 --bill rate
		 l_bill_rate_tbl.extend(1);
		 l_bill_rate_tbl(1) := p_revenue_override_rate;

		 --burdened rate
		 l_burdened_rate_tbl.extend(1);
		 l_burdened_rate_tbl(1) := NULL;

		 --unplanned flag
		 l_unplanned_flag_tbl.extend(1);
		 l_unplanned_flag_tbl(1) := NULL;

		 --expenditure type
		 l_expenditure_type_tbl.extend(1);
		 l_expenditure_type_tbl(1) := '';

         --call pa_planning_element_utils.add_new_resource_assignments to add the resource assignment
		 pa_planning_element_utils.add_new_resource_assignments(
            p_context                      => 'BUDGET',
            p_project_id                   => l_project_id,
            p_budget_version_id            => l_bvId,
            p_task_elem_version_id_tbl     => l_task_elem_version_id_tbl,
            p_resource_list_member_id_tbl  => l_resource_list_member_id_tbl,
            p_quantity_tbl                 => l_quantity_tbl,
            p_currency_code_tbl            => l_currency_code_tbl,
            p_burdened_cost_tbl            => l_burdened_cost_tbl,
            p_raw_cost_tbl                 => l_raw_cost_tbl,
            p_revenue_tbl                  => l_revenue_tbl,
            p_cost_rate_tbl                => l_cost_rate_tbl,
            p_bill_rate_tbl                => l_bill_rate_tbl,
            p_burdened_rate_tbl            => l_burdened_rate_tbl,
            p_unplanned_flag_tbl           => l_unplanned_flag_tbl,
            p_expenditure_type_tbl         => l_expenditure_type_tbl,
            x_return_status                => l_return_status,
            x_msg_count                    => l_error_msg_code,
            x_msg_data                     => l_msg_count);

			If l_return_status = 'S' then
			    --fetch burdened_cost, revenue_rate, revenue from budget tables
				open get_budget_data(l_bvId);
                fetch get_budget_data into l_burdened_cost, l_revenue, l_revenue_rate;
                close get_budget_data;
		 		--updating the pa_ci_supplier_details table information

				update pa_ci_supplier_details
				set burdened_cost = l_burdened_cost,
				    revenue_rate = l_revenue_rate,
					revenue_override_rate = '',
					revenue = l_revenue,
					total_revenue = l_revenue
			    where
				   ci_transaction_id = x_CI_TRANSACTION_ID;

			End if;
     	else -- audit number is not 1
		    --call update api
			--p_struct_elem_version_id  and   p_task_elem_version_id_tbl
			open get_elem_ver_id(l_project_id);
            fetch get_elem_ver_id into l_elem_ver_id, l_struct_elem_version_id;
            close get_elem_ver_id;
		    l_task_elem_version_id_tbl.extend(1);
		    l_task_elem_version_id_tbl(1) := l_elem_ver_id;
			--p_task_name_tbl
			l_task_name_tbl.extend(1);
			l_task_name_tbl(1) := '';
			--p_task_number_tbl
			l_task_number_tbl.extend(1);
			l_task_number_tbl(1) := '';
			--p_start_date_tbl
			l_in_start_date_tbl.extend(1);
			l_in_start_date_tbl(1) := to_date(p_From_Date,'YYYY/MM/DD');
			--p_end_date_tbl
			l_in_end_date_tbl.extend(1);
			l_in_end_date_tbl(1) := to_date(p_To_Date,'YYYY/MM/DD');
			--p_planned_people_effort_tbl
			l_planned_people_effort_tbl.extend(1);
			l_planned_people_effort_tbl(1) := '';
			--p_resource_assignment_id_tbl
			--p_unit_of_measure_tbl
			--p_project_assignment_id_tbl
            --p_supplier_id_tbl
			--p_spread_curve_id_tbl
			--p_etc_method_code_tbl
			--p_mfc_cost_type_id_tbl

			--p_use_task_schedule_flag_tbl
			--p_planning_start_date_tbl
            --p_planning_end_date_tbl

			 --p_sp_fixed_date_tbl
			l_resource_assignment_id_tbl.extend(1);
			l_project_assignment_id_tbl.extend(1);
			l_unit_of_measure_tbl.extend(1);
			l_organization_id_tbl.extend(1);
			l_supplier_id_tbl.extend(1);
			l_spread_curve_id_tbl.extend(1);
			l_etc_method_code_tbl.extend(1);
			l_mfc_cost_type_id_tbl.extend(1);
			l_procure_resource_flag_tbl.extend(1);
			l_use_task_schedule_flag_tbl.extend(1);
			l_planning_start_date_tbl.extend(1);
			l_planning_end_date_tbl.extend(1);
			l_schedule_start_date_tbl.extend(1);
			l_schedule_end_date_tbl.extend(1);
			l_sp_fixed_date_tbl.extend(1);
			l_named_role_tbl.extend(1);
			open get_resource_assignment_id(l_bvId);
			fetch get_resource_assignment_id into
			l_resource_assignment_id_tbl(1),l_unit_of_measure_tbl(1),l_project_assignment_id_tbl(1),
			l_organization_id_tbl(1),l_supplier_id_tbl(1),l_spread_curve_id_tbl(1),
			l_etc_method_code_tbl(1),l_mfc_cost_type_id_tbl(1),l_procure_resource_flag_tbl(1),
			l_use_task_schedule_flag_tbl(1),l_planning_start_date_tbl(1),l_planning_end_date_tbl(1),
			l_schedule_start_date_tbl(1),l_schedule_end_date_tbl(1),l_sp_fixed_date_tbl(1),
			l_named_role_tbl(1);
			close get_resource_assignment_id;
			--p_resource_list_member_id_tbl
			l_resource_list_member_id_tbl.extend(1);
			l_resource_list_member_id_tbl(1) := p_Resource_List_Mem_Id;
			--p_assignment_description_tbl
			l_assignment_description_tbl.extend(1);
			l_assignment_description_tbl(1) := '';
			--p_resource_alias_tbl
			l_planning_resource_alias_tbl.extend(1);
			l_planning_resource_alias_tbl(1) := '';
			--p_resource_class_flag_tbl
			l_resource_class_flag_tbl.extend(1);
			l_resource_class_flag_tbl(1) := '';
			--p_resource_class_code_tbl
			l_resource_class_code_tbl.extend(1);
			l_resource_class_code_tbl(1) := '';
			--p_resource_class_id_tbl
			l_resource_class_id_tbl.extend(1);
			l_resource_class_id_tbl(1) := '';
			--p_res_type_code_tbl
			l_res_type_code_tbl.extend(1);
			l_res_type_code_tbl(1) := '';
            --p_resource_code_tbl
			l_resource_code_tbl.extend(1);
			l_resource_code_tbl(1) := '';
            --p_resource_name
			l_resource_name.extend(1);
			l_resource_name(1) := '';
            --p_project_role_id_tbl
			l_project_role_id_tbl.extend(1);
			l_project_role_id_tbl(1) := '';
            --p_project_role_name_tbl
			l_project_role_name_tbl.extend(1);
			l_project_role_name_tbl(1) := '';
            --p_organization_name_tbl
			l_organization_name_tbl.extend(1);
			l_organization_name_tbl(1) := '';
            --p_fc_res_type_code_tbl
			l_fc_res_type_code_tbl.extend(1);
			l_fc_res_type_code_tbl(1) := '';
            --p_financial_category_code_tbl
			l_financial_category_code_tbl.extend(1);
			l_financial_category_code_tbl(1) := '';
			--p_incur_by_resource_code_tbl   =>
			l_Incur_by_resource_code_tbl.extend(1);
			l_Incur_by_resource_code_tbl(1) := '';
            --p_incur_by_resource_name_tbl
			l_incur_by_resource_name_tbl.extend(1);
			l_incur_by_resource_name_tbl(1) := '';

            --p_quantity_tbl
			l_total_quantity_tbl.extend(1);
			l_total_quantity_tbl(1) := NULL;
            --p_currency_code_tbl
			l_currency_code_tbl.extend(1);
			l_currency_code_tbl(1) := p_CURRENCY_CODE;
            --p_txn_currency_override_tbl
			l_override_currency_code_tbl.extend(1);
			l_override_currency_code_tbl(1) := '';
            --p_raw_cost_tbl
			l_total_raw_cost_tbl.extend(1);
			l_total_raw_cost_tbl(1) := p_CHANGE_AMOUNT;
            --p_burdened_cost_tbl
			l_burdened_cost_tbl.extend(1);
			open get_burdened_cost(x_CI_TRANSACTION_ID);
			fetch get_burdened_cost into l_bur_cost;
			close get_burdened_cost;
			if l_bur_cost = p_Burdened_cost then
			  l_burdened_cost_tbl(1) := NULL;
			else
              l_burdened_cost_tbl(1) := p_Burdened_cost;
            end if;
            --p_revenue_tbl
			l_revenue_tbl.extend(1);
			l_revenue_tbl(1) := p_Revenue;
            --p_cost_rate_tbl
			l_raw_cost_rate_tbl.extend(1);
			l_raw_cost_rate_tbl(1) := NULL;
            --p_bill_rate_tbl
			l_bill_rate_tbl.extend(1);
			l_bill_rate_tbl(1) := NULL;
            --p_bill_rate_override_tbl
			l_bill_rate_override_tbl.extend(1);
			l_bill_rate_override_tbl(1) := p_revenue_override_rate;
            --p_billable_percent_tbl
			l_billable_percent_tbl.extend(1);
			l_billable_percent_tbl(1) := p_revenue_override_rate;
            --p_cost_rate_override_tbl
			l_cost_rate_override_tbl.extend(1);
			l_cost_rate_override_tbl(1) := NULL;
            --p_burdened_rate_tbl
			l_burdened_rate_tbl.extend(1);
			l_burdened_rate_tbl(1) := NULL;
            --p_burdened_rate_override_tbl
			l_burdened_rate_override_tbl.extend(1);
			l_burdened_rate_override_tbl(1) := '';

            --p_financial_category_name_tbl
			l_financial_category_name_tbl.extend(1);
			l_financial_category_name_tbl(1) := '';
            --p_supplier_name_tbl
			l_supplier_name_tbl.extend(1);
			l_supplier_name_tbl(1) := '';
            --p_attribute_category_tbl    1 --> 30
			l_attribute_category_tbl.extend(1);
			l_attribute1_tbl.extend(1);
			l_attribute_category_tbl(1) := '';
			l_attribute1_tbl(1) := '';
			--p_scheduled_delay
			l_scheduled_delay := null;
			--p_direct_expenditure_type_tbl
			l_direct_expenditure_type_tbl.extend(1);
			l_direct_expenditure_type_tbl(1) := '';
		    --calling api

			pa_fp_planning_transaction_pub.update_planning_transactions(
            p_context                      => 'BUDGET',
            p_struct_elem_version_id       => l_struct_elem_version_id,
            p_budget_version_id            => l_bvId,
            p_task_elem_version_id_tbl     => l_task_elem_version_id_tbl,
            p_task_name_tbl                => l_task_name_tbl,
            p_task_number_tbl              => l_task_number_tbl,
            p_start_date_tbl               => l_in_start_date_tbl,
            p_end_date_tbl                 => l_in_end_date_tbl,
            p_planned_people_effort_tbl    => l_planned_people_effort_tbl,
            p_resource_assignment_id_tbl   => l_resource_assignment_id_tbl,
            p_resource_list_member_id_tbl  => l_resource_list_member_id_tbl,
            p_assignment_description_tbl   => l_assignment_description_tbl,
            p_project_assignment_id_tbl    => l_project_assignment_id_tbl,
            p_resource_alias_tbl           => l_planning_resource_alias_tbl,
            p_resource_class_flag_tbl      => l_resource_class_flag_tbl,
            p_resource_class_code_tbl      => l_resource_class_code_tbl,
            p_resource_class_id_tbl        => l_resource_class_id_tbl,
            p_res_type_code_tbl            => l_res_type_code_tbl,
            p_resource_code_tbl            => l_resource_code_tbl,
            p_resource_name                => l_resource_name,
            p_project_role_id_tbl          => l_project_role_id_tbl,
            p_project_role_name_tbl        => l_project_role_name_tbl,
            p_organization_id_tbl          => l_organization_id_tbl,
            p_organization_name_tbl        => l_organization_name_tbl,
            p_fc_res_type_code_tbl         => l_fc_res_type_code_tbl,
            p_financial_category_code_tbl  => l_financial_category_code_tbl,
            p_supplier_id_tbl              => l_supplier_id_tbl,
            p_unit_of_measure_tbl          => l_unit_of_measure_tbl,
            p_spread_curve_id_tbl          => l_spread_curve_id_tbl,
            p_etc_method_code_tbl          => l_etc_method_code_tbl,
            p_mfc_cost_type_id_tbl         => l_mfc_cost_type_id_tbl,
            p_procure_resource_flag_tbl    => l_procure_resource_flag_tbl,
            p_incur_by_resource_code_tbl   => l_Incur_by_resource_code_tbl,
            p_incur_by_resource_name_tbl   => l_incur_by_resource_name_tbl,
            p_use_task_schedule_flag_tbl   => l_use_task_schedule_flag_tbl,
            p_planning_start_date_tbl      => l_planning_start_date_tbl,
            p_planning_end_date_tbl        => l_planning_end_date_tbl,
            p_schedule_start_date_tbl      => l_schedule_start_date_tbl,
            p_schedule_end_date_tbl        => l_schedule_end_date_tbl,
            p_quantity_tbl                 => l_total_quantity_tbl,
            p_currency_code_tbl            => l_currency_code_tbl,
            p_txn_currency_override_tbl    => l_override_currency_code_tbl,
            p_raw_cost_tbl                 => l_total_raw_cost_tbl,
            p_burdened_cost_tbl            => l_burdened_cost_tbl,
            p_revenue_tbl                  => l_revenue_tbl,
            p_cost_rate_tbl                => l_raw_cost_rate_tbl,
            p_bill_rate_tbl                => l_bill_rate_tbl,
            p_bill_rate_override_tbl       => l_bill_rate_override_tbl,
            p_billable_percent_tbl         => l_billable_percent_tbl,
            p_cost_rate_override_tbl       => l_cost_rate_override_tbl,
            p_burdened_rate_tbl            => l_burdened_rate_tbl,
            p_burdened_rate_override_tbl   => l_burdened_rate_override_tbl,
            p_sp_fixed_date_tbl            => l_sp_fixed_date_tbl,
            p_named_role_tbl               => l_named_role_tbl,
            p_financial_category_name_tbl  => l_financial_category_name_tbl,
            p_supplier_name_tbl            => l_supplier_name_tbl,
            p_attribute_category_tbl       => l_attribute_category_tbl,
            p_attribute1_tbl               => l_attribute1_tbl,
            p_attribute2_tbl               => l_attribute1_tbl,
            p_attribute3_tbl               => l_attribute1_tbl,
            p_attribute4_tbl               => l_attribute1_tbl,
            p_attribute5_tbl               => l_attribute1_tbl,
            p_attribute6_tbl               => l_attribute1_tbl,
            p_attribute7_tbl               => l_attribute1_tbl,
            p_attribute8_tbl               => l_attribute1_tbl,
            p_attribute9_tbl               => l_attribute1_tbl,
            p_attribute10_tbl              => l_attribute1_tbl,
            p_attribute11_tbl              => l_attribute1_tbl,
            p_attribute12_tbl              => l_attribute1_tbl,
            p_attribute13_tbl              => l_attribute1_tbl,
            p_attribute14_tbl              => l_attribute1_tbl,
            p_attribute15_tbl              => l_attribute1_tbl,
            p_attribute16_tbl              => l_attribute1_tbl,
            p_attribute17_tbl              => l_attribute1_tbl,
            p_attribute18_tbl              => l_attribute1_tbl,
            p_attribute19_tbl              => l_attribute1_tbl,
            p_attribute20_tbl              => l_attribute1_tbl,
            p_attribute21_tbl              => l_attribute1_tbl,
            p_attribute22_tbl              => l_attribute1_tbl,
            p_attribute23_tbl              => l_attribute1_tbl,
            p_attribute24_tbl              => l_attribute1_tbl,
            p_attribute25_tbl              => l_attribute1_tbl,
            p_attribute26_tbl              => l_attribute1_tbl,
            p_attribute27_tbl              => l_attribute1_tbl,
            p_attribute28_tbl              => l_attribute1_tbl,
            p_attribute29_tbl              => l_attribute1_tbl,
            p_attribute30_tbl              => l_attribute1_tbl,
            p_scheduled_delay              => l_scheduled_delay,
            p_distrib_amts                 => 'Y',
            p_direct_expenditure_type_tbl  => l_direct_expenditure_type_tbl,
            x_return_status                => l_return_status,
            x_msg_count                    => l_error_msg_code,
            x_msg_data                     => l_msg_count);

			If l_return_status = 'S' then
			    --fetch burdened_cost, revenue_rate, revenue from budget tables

				open get_budget_data(l_bvId);
                fetch get_budget_data into l_burdened_cost, l_revenue, l_revenue_rate;
                close get_budget_data;
		 		--updating the pa_ci_supplier_details table information

				update pa_ci_supplier_details
				set change_amount = p_CHANGE_AMOUNT,
				    burdened_cost = l_burdened_cost,
				    revenue_rate = l_revenue_rate,
					revenue_override_rate = '',
					revenue = l_revenue,
					total_revenue = l_revenue
			    where
				   ci_transaction_id = x_CI_TRANSACTION_ID;

			End if;


		end if; --audit number is 1
	  end if; --budget version id not null
	 end if; -- task_id not null
*/


	x_return_status := l_return_status;
	x_error_msg_code := l_error_msg_code;
 EXCEPTION
	when others then
	    x_error_msg_code := sqlcode||sqlerrm;
	    IF l_debug_mode = 'Y' THEN
	    	print_msg('x_err_msg_code exception:'||x_error_msg_code);
	    End If;
	    Raise;

 END insert_row;

 PROCEDURE update_row
        (p_rowid                       	IN   VARCHAR2
        ,p_ci_transaction_id         	IN   NUMBER
        ,p_CI_TYPE_ID           	IN   NUMBER
        ,p_CI_ID                	IN   NUMBER
        ,p_CI_IMPACT_ID                IN   NUMBER
        ,p_VENDOR_ID                   IN   NUMBER
        ,p_PO_HEADER_ID                IN   NUMBER
        ,p_PO_LINE_ID                  IN   NUMBER
        ,p_ADJUSTED_TRANSACTION_ID     IN   NUMBER
        ,p_CURRENCY_CODE               IN   VARCHAR2
        ,p_CHANGE_AMOUNT               IN   NUMBER
        ,p_CHANGE_TYPE                 IN   VARCHAR2
        ,p_CHANGE_DESCRIPTION          IN   VARCHAR2
        ,p_LAST_UPDATED_BY             IN   NUMBER
        ,p_LAST_UPDATE_DATE            IN   DATE
        ,p_LAST_UPDATE_LOGIN           IN   NUMBER
		,p_Task_Id                     IN NUMBER
		,p_Resource_List_Mem_Id        IN NUMBER
		,p_From_Date                   IN varchar2
		,p_To_Date                     IN varchar2
		,p_Estimated_Cost              IN NUMBER
		,p_Quoted_Cost                 IN NUMBER
		,p_Negotiated_Cost             IN NUMBER
		,p_Burdened_cost             IN NUMBER
		,p_Revenue                   IN NUMBER default NULL
		,p_revenue_override_rate     in number
        ,p_audit_history_number        in number
        ,p_current_audit_flag          in varchar2
        ,p_Original_supp_trans_id              in number
        ,p_Source_supp_trans_id                in number
	,p_Sup_ref_no                  in number default null
	,p_version_type                in varchar2 default 'ALL'
	,p_ci_status            	   IN   VARCHAR2 default null
        -- gboomina modified for supplier cost 12.1.3 requirement - start
        ,p_expenditure_type            in varchar2  default null
        ,p_expenditure_org_id          in number  default null
        ,p_change_reason_code          in varchar2  default null
        ,p_quote_negotiation_reference in varchar2  default null
        ,p_need_by_date                in varchar2   default null
        -- gboomina modified for supplier cost 12.1.3 requirement - end
        ,x_return_status               OUT NOCOPY  VARCHAR2
        ,x_error_msg_code              OUT NOCOPY  VARCHAR2
                      )IS
cursor cur_audit is
select nvl(audit_history_number,0),original_supp_trans_id
from pa_ci_supplier_details
where ci_transaction_id = p_ci_transaction_id;

cursor get_res_asgn_id is
	   select pa_resource_assignments_s.nextval
   from sys.dual;

	CURSOR cur_row is
	SELECT CI_TYPE_ID
          ,CI_ID
          ,CI_IMPACT_ID
          ,VENDOR_ID
          ,PO_HEADER_ID
          ,PO_LINE_ID
          ,ADJUSTED_CI_TRANSACTION_ID
          ,CURRENCY_CODE
          ,CHANGE_AMOUNT
          ,CHANGE_TYPE
          ,CHANGE_DESCRIPTION
		  ,TASK_ID
		  ,RESOURCE_LIST_MEMBER_ID
		  ,FROM_CHANGE_DATE
		  ,TO_CHANGE_DATE
		  ,ESTIMATED_COST
		  ,QUOTED_COST
		  ,NEGOTIATED_COST
		  ,Burdened_cost
		  ,revenue
		  ,audit_history_number
		  ,ORIGINAL_SUPP_TRANS_ID
		  ,SOURCE_SUPP_TRANS_ID
		  ,SUP_QUOTE_REF_NO
		  ,status
    -- gboomina modified for supplier cost 12.1.3 requirement - start
    ,expenditure_type
    ,expenditure_org_id
    ,change_reason_code
    ,quote_negotiation_reference
    ,need_by_date
    -- gboomina modified for supplier cost 12.1.3 requirement - end
          FROM pa_ci_supplier_details
	WHERE ci_transaction_id = p_ci_transaction_id
	FOR UPDATE OF ci_transaction_id NOWAIT;

	cursor get_budget_version_id is
      select budget_version_id
	  from pa_budget_versions
	  where ci_id = p_ci_id;

	cursor get_project_id is
      select project_id
	  from pa_control_items
	  where ci_id = p_ci_id;

	cursor get_resource_assignment_id(bv_Id number) is
       select resource_assignment_id
       from pa_resource_assignments
       where budget_version_id = bv_Id
	     and task_id = p_Task_Id
         and resource_list_member_id = p_Resource_List_Mem_Id;

		cursor get_resource_details is
      select ORGANIZATION_ID
         	 ,SPREAD_CURVE_ID
			 ,ETC_METHOD_CODE
             ,RESOURCE_CLASS_CODE
			 ,RESOURCE_CLASS_FLAG
			 ,RECORD_VERSION_NUMBER
             ,INCURRED_BY_RES_FLAG
			 ,UNIT_OF_MEASURE
			 ,RESOURCE_TYPE_CODE
      from pa_resource_list_members where RESOURCE_LIST_MEMBER_ID = p_Resource_List_Mem_Id;

	cursor get_cost_rate_id is
   SELECT
		ppfo.use_planning_rates_flag,
		ppfo.RES_CLASS_RAW_COST_SCH_ID,
		ppfo.COST_RES_CLASS_RATE_SCH_ID,
		ppfo.RES_CLASS_BILL_RATE_SCH_ID,
		ppfo.REV_RES_CLASS_RATE_SCH_ID
	FROM pa_proj_fp_options ppfo,
	     pa_control_items pci
	WHERE pci.ci_id = p_ci_id and
	      pci.project_id = ppfo.project_id and
          NVL(ppfo.Approved_Cost_Plan_Type_Flag ,'N') = 'Y' and
          ppfo.Fin_Plan_Option_Level_Code = 'PLAN_TYPE';

	cursor get_cost_markup(p_rate_sch_id number) is
	select markup_percentage from PA_BILL_RATES_ALL
	WHERE bill_rate_sch_id = p_rate_sch_id AND
	resource_class_code = 'FINANCIAL_ELEMENTS' and
	trunc(to_date(p_From_Date)) between trunc(start_date_active)
                        and trunc(nvl(end_date_active,to_date(p_From_Date)));

	res_info get_resource_details%rowtype;
	recinfo cur_row%rowtype;
   	l_debug_mode           varchar2(1) := 'N';
   	l_change_amount        number;
   	l_audit_version_number number;
   	l_return_status      varchar2(1) :=  'S';
   	l_msg_count  number := 0;
	l_error_msg_code     varchar2(1000);
	l_status varchar2(10) := 'New';
	l_rowid              varchar2(100) := p_rowid;
	l_Original_supp_trans_id number;
    l_res_rate_sch_id number :=0;
	l_use_planning_rates_flag varchar2(1) :='N';
	l_cost_rate_sch_id number :=0;
	l_cost_rate number := 0;
    l_res_bill_sch_id number := 0;
	l_rev_rate_sch_id number := 0;
	l_revenue_rate number :=0;
	l_revenue number :=0;
	l_burdened_cost number :=0;
	l_margin number :=0;
	l_bvId number :=0;
	l_res_asgn_Id number := 0;
	l_project_id number := 0;
	l_ci_transaction_id number := p_ci_transaction_id;
	l_source_ci_trans_id number;
	l_original_ci_trans_id number;

 BEGIN

   	fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   	l_debug_mode := NVL(l_debug_mode, 'N');

   	pa_debug.set_process('PLSQL','LOG',l_debug_mode);

	/** set the return status to success **/
	x_return_status := 'S';
	x_error_msg_code := NULL;

	If l_debug_mode = 'Y' Then
		print_msg('Inside update row.');
	End If;



	OPEN cur_row;
	FETCH cur_row INTO recinfo;
	If cur_row%NOTFOUND then
		If l_debug_mode = 'Y' Then
			print_msg('row not found return');
		End If;
		return;
	End If;
	CLOSE cur_row;


	open get_cost_rate_id;
  fetch get_cost_rate_id into l_use_planning_rates_flag, l_res_rate_sch_id,l_cost_rate_sch_id,l_res_bill_sch_id,l_rev_rate_sch_id;
  close get_cost_rate_id;

  if l_use_planning_rates_flag = 'Y' THEN
     open get_cost_markup(l_cost_rate_sch_id);
	 fetch get_cost_markup into l_cost_rate;
	 close get_cost_markup;
	 open get_cost_markup(l_rev_rate_sch_id);
	 fetch get_cost_markup into l_revenue_rate;
	 close get_cost_markup;
   else
     open get_cost_markup(l_res_rate_sch_id);
	 fetch get_cost_markup into l_cost_rate;
	 close get_cost_markup;
	 open get_cost_markup(l_res_bill_sch_id);
	 fetch get_cost_markup into l_revenue_rate;
	 close get_cost_markup;
   end if;



	/** check if any of the attributes changed then update else donot **/
/*	IF Nvl(recinfo.vendor_id,0) <> nvl(p_vendor_id,0) OR
           Nvl(recinfo.po_header_id,0) <> nvl(p_po_header_id,0) OR
	   Nvl(recinfo.po_line_id,0) <> nvl(p_po_line_id,0) OR
	   Nvl(recinfo.currency_code,'X') <> nvl(p_currency_code,'X') OR
	   nvl(recinfo.change_type,'X') <> nvl(p_change_type,'X') OR
	   Nvl(recinfo.change_description,'X') <> nvl(p_change_description,'X') OR
	   NVL(recinfo.SUP_QUOTE_REF_NO,0) <> NVL(p_ci_status,0)
	  THEN
*/
		If l_debug_mode = 'Y' Then
			print_msg('firing update query');
		End If;

		UPDATE  pa_ci_supplier_details SET
          	VENDOR_ID               = p_vendor_id
          	,PO_HEADER_ID            = p_po_header_id
          	,PO_LINE_ID              = p_po_line_id
          	,ADJUSTED_CI_TRANSACTION_ID = p_adjusted_transaction_id
          	,CURRENCY_CODE           = p_currency_code
          	,CHANGE_AMOUNT           = pa_currency.round_trans_currency_amt
                                           (decode(p_CHANGE_AMOUNT,null,0,p_CHANGE_AMOUNT),p_CURRENCY_CODE)
          	,CHANGE_TYPE             = p_change_type
          	,CHANGE_DESCRIPTION      = p_change_description
          	,LAST_UPDATED_BY         = p_last_updated_by
          	,LAST_UPDATE_DATE        = p_last_update_date
          	,LAST_UPDATE_LOGIN	      = p_last_update_login
         		,SUP_QUOTE_REF_NO        = p_Sup_ref_no
           -- gboomina added for supplier cost 12.1.3 - start
           ,change_reason_code      = p_change_reason_code
           ,quote_negotiation_reference = p_quote_negotiation_reference
           ,FROM_CHANGE_DATE        = to_date(p_From_Date)
           ,TO_CHANGE_DATE          = to_date(p_To_Date)
           ,expenditure_org_id      = p_expenditure_org_id
           ,need_by_date            = to_date(p_need_by_date)
           -- gboomina added for supplier cost 12.1.3 - end
          WHERE ci_transaction_id  = p_ci_transaction_id;

        	If sql%found then
                	x_return_status := 'S';
        	Else
                	x_return_status := 'E';
                	x_error_msg_code := 'NO_DATA_FOUND';
			If l_debug_mode = 'Y' Then
				print_msg('Update failure:'||x_error_msg_code);
			End If;
                	raise NO_DATA_FOUND;
        	End If;

--	  End IF;

	  IF NVL(recinfo.ESTIMATED_COST,0) <> NVL(p_Estimated_Cost,0) OR
	    NVL(recinfo.QUOTED_COST,0) <> NVL(p_Quoted_Cost,0) OR
	    NVL(recinfo.NEGOTIATED_COST,0) <> NVL(p_Negotiated_Cost,0) OR
	    Nvl(recinfo.change_amount,0) <> nvl(p_change_amount,0)	OR
        nvl(to_char(recinfo.FROM_CHANGE_DATE,'YYYY-MM-DD'),'X') <> NVL(p_From_date,'X') or
		NVL(to_char(recinfo.FROM_CHANGE_DATE,'YYYY-MM-DD'),'X') <> NVL(p_To_date,'X') or
		NVL(recinfo.Burdened_cost,0) <> NVL(p_Burdened_cost,0) or
		NVL(recinfo.revenue,0) <> NVL(p_Revenue,0) or
		NVL(p_revenue_override_rate,-99) = -99
	  THEN

	     If l_debug_mode = 'Y' Then
			print_msg('firing update  query');
		 End If;
		l_source_ci_trans_id := recinfo.SOURCE_SUPP_TRANS_ID;
		l_original_ci_trans_id := recinfo.ORIGINAL_SUPP_TRANS_ID;
		l_audit_version_number := recinfo.audit_history_number + 1;

		insert_row (
        			x_rowid                   => l_rowid
        			,x_ci_transaction_id      => l_ci_transaction_id
        			,p_CI_TYPE_ID             => p_ci_type_id
        			,p_CI_ID           	      => p_CI_ID
        			,p_CI_IMPACT_ID           => recinfo.CI_IMPACT_ID
        			,p_VENDOR_ID              => p_vendor_id
        			,p_PO_HEADER_ID           => p_po_header_id
        			,p_PO_LINE_ID             => p_po_line_id
        			,p_ADJUSTED_TRANSACTION_ID => p_ADJUSTED_TRANSACTION_ID
        			,p_CURRENCY_CODE           => p_CURRENCY_CODE
        			,p_CHANGE_AMOUNT           => p_CHANGE_AMOUNT
        			,p_CHANGE_TYPE             => p_CHANGE_TYPE
        			,p_CHANGE_DESCRIPTION      => p_CHANGE_DESCRIPTION
        			,p_CREATED_BY              => FND_GLOBAL.login_id
        			,p_CREATION_DATE           => trunc(sysdate)
        			,p_LAST_UPDATED_BY         => FND_GLOBAL.login_id
        			,p_LAST_UPDATE_DATE        => trunc(sysdate)
        			,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.login_id
					,p_Task_Id                 => p_Task_Id
		            ,p_Resource_List_Mem_Id    => p_Resource_List_Mem_Id
		            ,p_From_Date               => p_From_Date
		            ,p_To_Date                 => p_To_Date
		            ,p_Estimated_Cost          => p_Estimated_Cost
		            ,p_Quoted_Cost             => p_Quoted_Cost
		            ,p_Negotiated_Cost         => p_Negotiated_Cost
					,p_Burdened_cost           => p_Burdened_cost
					,p_Revenue                 => p_Revenue
					,p_revenue_override_rate   => p_revenue_override_rate
                    ,p_audit_history_number    => l_audit_version_number
                    ,p_current_audit_flag      => p_current_audit_flag
                    ,p_Original_supp_trans_id  => l_original_ci_trans_id
                    ,p_Source_supp_trans_id    => l_ci_transaction_id
					,p_Sup_ref_no               => p_Sup_ref_no
					,p_version_type            => recinfo.status
     -- gboomina modified for supplier cost 12.1.3 requirement - start
     ,p_expenditure_type         => p_expenditure_type
     ,p_expenditure_org_id          => p_expenditure_org_id
     ,p_change_reason_code          => p_change_reason_code
     ,p_quote_negotiation_reference => p_quote_negotiation_reference
     ,p_need_by_date                => p_need_by_date
     -- gboomina modified for supplier cost 12.1.3 requirement - end
					,p_ci_status               => ''
        			,x_return_status           => l_return_status
        			,x_error_msg_code          => l_error_msg_code  );



		END If;

/*
       IF (p_task_id is not null AND p_Resource_List_Mem_Id is not null) then
	 --knk resource assignment tables
	 --nag_test('UPDATE Before assignment tables');
	 OPEN get_budget_version_id;
	  FETCH get_budget_version_id INTO l_bvId;
	  If get_budget_version_id%NOTFOUND then
	  --nag_test('UPDATE NOt found');
		If l_debug_mode = 'Y' Then
			print_msg('Budget version doesnt exist');
		End If;
		return;
	  End If;
	  CLOSE get_budget_version_id;
	 --nag_test('UPDATE Budget version id is '||l_bvId);

     OPEN get_resource_assignment_id(l_bvId);
	  FETCH get_resource_assignment_id INTO l_res_asgn_Id;
	  If get_resource_assignment_id%NOTFOUND then
	    --nag_test('Create New');
		If l_debug_mode = 'Y' Then
			print_msg('New record needs to be inserted into resource assignments and asgn curr');
		End If;
		OPEN get_resource_details;
	    FETCH get_resource_details INTO res_info;
	    If get_resource_details%NOTFOUND then
		   If l_debug_mode = 'Y' Then
			  print_msg('Unable to retrieve resource details');
		    End If;
		  return;
	    End If;
	    CLOSE get_resource_details;
		 open get_res_asgn_id;
         fetch get_res_asgn_id into l_res_asgn_Id;
         close get_res_asgn_id;
		 open get_project_id;
         fetch get_project_id into l_project_id;
         close get_project_id;
		INSERT INTO PA_RESOURCE_ASSIGNMENTS(
		     RESOURCE_ASSIGNMENT_ID
			 ,BUDGET_VERSION_ID
			 ,PROJECT_ID
			 ,TASK_ID
			 ,RESOURCE_LIST_MEMBER_ID
             ,LAST_UPDATE_DATE
			 ,LAST_UPDATED_BY
			 ,CREATION_DATE
			 ,CREATED_BY
			 ,LAST_UPDATE_LOGIN
             ,UNIT_OF_MEASURE
			 ,TRACK_AS_LABOR_FLAG
			 ,PROJECT_ASSIGNMENT_ID
			 ,TOTAL_PLAN_REVENUE
             ,TOTAL_PLAN_RAW_COST
			 ,TOTAL_PLAN_QUANTITY
			 ,RESOURCE_ASSIGNMENT_TYPE
             ,TOTAL_PROJECT_RAW_COST
			 ,TOTAL_PROJECT_BURDENED_COST
			 ,TOTAL_PROJECT_REVENUE
             --RBS_ELEMENT_ID
			 ,PLANNING_START_DATE
			 ,PLANNING_END_DATE
             ,SPREAD_CURVE_ID
			 ,ETC_METHOD_CODE
			 ,RES_TYPE_CODE
			 ,RESOURCE_CLASS_CODE
			 ,ORGANIZATION_ID
             ,RECORD_VERSION_NUMBER
			 ,INCURRED_BY_RES_FLAG
			 ,RATE_BASED_FLAG
			 ,RATE_EXP_FUNC_CURR_CODE
             --,RATE_EXPENDITURE_ORG_ID
			 ,RESOURCE_CLASS_FLAG
			 ,RESOURCE_RATE_BASED_FLAG
		   )VALUES
		   ( l_res_asgn_Id
             ,l_bvId
             ,l_project_id
             ,p_Task_Id
		     ,p_Resource_List_Mem_Id
             ,sysdate
             ,1319
             ,sysdate
             ,1319
             ,p_LAST_UPDATE_LOGIN
             ,res_info.UNIT_OF_MEASURE
             ,'Y'
             ,-1
 			 ,l_revenue
			 ,decode(p_CHANGE_AMOUNT,null,0,p_CHANGE_AMOUNT)
			 ,decode(p_Burdened_cost,null,(p_CHANGE_AMOUNT+(p_CHANGE_AMOUNT*0.1)),p_Burdened_cost)
			 ,'USER_ENTERED'
			 ,decode(p_CHANGE_AMOUNT,null,0,p_CHANGE_AMOUNT)
			 ,decode(p_Burdened_cost,null,(p_CHANGE_AMOUNT+(p_CHANGE_AMOUNT*0.1)),p_Burdened_cost)
			 ,l_revenue
			 ,to_date(p_From_Date,'YYYY/MM/DD')
		     ,to_date(p_To_Date,'YYYY/MM/DD')
			 ,res_info.SPREAD_CURVE_ID
			 ,res_info.ETC_METHOD_CODE
			 ,res_info.RESOURCE_TYPE_CODE
			 ,res_info.RESOURCE_CLASS_CODE
			 ,res_info.ORGANIZATION_ID
			 ,res_info.RECORD_VERSION_NUMBER
			 ,res_info.INCURRED_BY_RES_FLAG
			 ,'N'
			 ,p_CURRENCY_CODE
			 ,res_info.RESOURCE_CLASS_FLAG
			 ,'Y'
		   );
	  else
	    --nag_test('UPDATE resource assignment id '||l_res_asgn_Id);
	    If l_debug_mode = 'Y' Then
			print_msg('Updating the existing resource assignment');
		End If;
		update PA_RESOURCE_ASSIGNMENTS SET
		   LAST_UPDATE_DATE = p_LAST_UPDATE_DATE
		   ,LAST_UPDATED_BY = 1319
		   ,LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN
		   ,TOTAL_PLAN_REVENUE = l_revenue
		   ,TOTAL_PLAN_RAW_COST = decode(p_CHANGE_AMOUNT,null,0,p_CHANGE_AMOUNT)
		   ,TOTAL_PLAN_BURDENED_COST = decode(p_Burdened_cost,null,(p_CHANGE_AMOUNT+(p_CHANGE_AMOUNT*0.1)),p_Burdened_cost)
		   ,TOTAL_PLAN_QUANTITY = decode(p_CHANGE_AMOUNT,null,0,p_CHANGE_AMOUNT)
           ,TOTAL_PROJECT_RAW_COST = decode(p_CHANGE_AMOUNT,null,0,p_CHANGE_AMOUNT)
		   ,TOTAL_PROJECT_BURDENED_COST = decode(p_Burdened_cost,null,(p_CHANGE_AMOUNT+(p_CHANGE_AMOUNT*0.1)),p_Burdened_cost)
		   ,TOTAL_PROJECT_REVENUE = l_revenue
           ,RATE_BASED_FLAG = 'N'
		   ,RESOURCE_RATE_BASED_FLAG = 'N'
		   WHERE RESOURCE_ASSIGNMENT_ID = l_res_asgn_Id;

		   --nag_test('Done with resource assignment insert');

		   UPDATE pa_resource_asgn_curr SET
		      TOTAL_QUANTITY = pa_currency.round_trans_currency_amt
                     (decode(p_CHANGE_AMOUNT,null,0,p_CHANGE_AMOUNT),p_CURRENCY_CODE)
			  ,TXN_AVERAGE_RAW_COST_RATE = 1
			  ,TXN_AVERAGE_BURDEN_COST_RATE = 0.1
              ,TXN_AVERAGE_BILL_RATE = l_revenue_rate
			  ,TOTAL_TXN_RAW_COST = pa_currency.round_trans_currency_amt
                     (decode(p_CHANGE_AMOUNT,null,0,p_CHANGE_AMOUNT),p_CURRENCY_CODE)
			  ,TOTAL_TXN_BURDENED_COST = decode(p_Burdened_cost,null,(p_CHANGE_AMOUNT+(p_CHANGE_AMOUNT*0.1)),p_Burdened_cost)
              ,TOTAL_TXN_REVENUE = l_revenue
			  ,TOTAL_PROJECT_RAW_COST = pa_currency.round_trans_currency_amt
                     (decode(p_CHANGE_AMOUNT,null,0,p_CHANGE_AMOUNT),p_CURRENCY_CODE)
			  ,TOTAL_PROJECT_BURDENED_COST = decode(p_Burdened_cost,null,(p_CHANGE_AMOUNT+(p_CHANGE_AMOUNT*0.1)),p_Burdened_cost)
              ,TOTAL_PROJECT_REVENUE = l_revenue
			  ,TOTAL_PROJFUNC_RAW_COST = pa_currency.round_trans_currency_amt
                     (decode(p_CHANGE_AMOUNT,null,0,p_CHANGE_AMOUNT),p_CURRENCY_CODE)
			  ,TOTAL_PROJFUNC_BURDENED_COST = decode(p_Burdened_cost,null,(p_CHANGE_AMOUNT+(p_CHANGE_AMOUNT*0.1)),p_Burdened_cost)
              ,TOTAL_PROJFUNC_REVENUE = l_revenue
			  ,LAST_UPDATE_DATE = p_LAST_UPDATE_DATE
			  ,LAST_UPDATED_BY = 1319
			  ,LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN
		   WHERE RESOURCE_ASSIGNMENT_ID = l_res_asgn_Id;
	   End If;
	  CLOSE get_resource_assignment_id;

	 end if; -- task_id not null
*/

 EXCEPTION
        when others then

            x_error_msg_code := sqlcode||sqlerrm;
	    If l_debug_mode = 'Y' Then
	    	print_msg('Exception :'||x_error_msg_code);
	    End if;
            Raise;

 END update_row;


 PROCEDURE  delete_row (p_ci_transaction_id in NUMBER)IS

    cursor fetch_details is
	select TASK_ID, RESOURCE_LIST_MEMBER_ID, ci_id
	from pa_ci_supplier_details
    where CI_TRANSACTION_ID = p_ci_transaction_id;

	cursor get_budget_version_id(p_ci_id number) is
	  select budget_version_id
	  from pa_budget_versions
	  where ci_id = p_ci_id;

	cursor get_assignment_details(p_bvId number, p_task_id number, p_res_id number) is
	  select pra.RESOURCE_ASSIGNMENT_ID, ppe.ELEMENT_NUMBER, ppe.NAME
	  from pa_resource_assignments pra, pa_proj_elements ppe, pa_tasks pt
	  WHERE pra.budget_version_id = p_bvId
	  and pra.task_id = p_task_id
	  and pra.RESOURCE_LIST_MEMBER_ID = p_res_id
	  and pt.task_id = ppe.proj_element_id;


 l_currency_code_tbl            SYSTEM.PA_VARCHAR2_15_TBL_TYPE  := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
 l_task_elem_version_id_tbl     SYSTEM.PA_NUM_TBL_TYPE          := SYSTEM.PA_NUM_TBL_TYPE();
 l_resource_assignment_id_tbl   SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
 l_task_name_tbl                SYSTEM.PA_VARCHAR2_240_TBL_TYPE    := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
 l_task_number_tbl              SYSTEM.PA_VARCHAR2_240_TBL_TYPE    := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();

 l_bvId number := 0;
 l_res_asgn_Id number := 0;
 l_return_status        varchar2(100) := 'S';
 l_error_msg_code       varchar2(100) := NULL;
 l_msg_count  number := 0;
 l_debug_mode           varchar2(1) := 'N';
 l_res_id number;
 l_task_id number;
 l_res_asg_id number;
 l_task_number varchar2(100);
 l_task_name varchar2(100);
 l_ci_id number;

 BEGIN

        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        l_debug_mode := NVL(l_debug_mode, 'N');

        pa_debug.set_process('PLSQL','LOG',l_debug_mode);
        open fetch_details;
		fetch fetch_details into l_task_id, l_res_id, l_ci_id;
		close fetch_details;

	DELETE FROM PA_CI_SUPPLIER_DETAILS
	WHERE CI_TRANSACTION_ID = P_CI_TRANSACTION_ID;
	if sql%found then
		If l_debug_mode = 'Y' Then
			print_msg('Delete Success');
		End iF;

		IF (l_task_id is not null AND l_res_id is not null) then
		--call delete planning element api
		open get_budget_version_id(l_ci_id);
		fetch get_budget_version_id into l_bvId;
		close get_budget_version_id;
		l_currency_code_tbl.extend(1);
		l_task_elem_version_id_tbl.extend(1);
		l_task_elem_version_id_tbl(1) := l_bvId;
        l_resource_assignment_id_tbl.extend(1);
        l_task_name_tbl.extend(1);
        l_task_number_tbl.extend(1);

		open get_assignment_details(l_bvId,l_task_id,l_res_id);
		fetch get_assignment_details into l_res_asg_id,l_task_number,l_task_name;
		close get_assignment_details;

		l_currency_code_tbl(1) := 'USD';
		l_resource_assignment_id_tbl(1) := l_res_asg_id;
        l_task_name_tbl(1) := l_task_name;
        l_task_number_tbl(1) := l_task_number;



		pa_fp_planning_transaction_pub.delete_planning_transactions(
            p_context                      => 'BUDGET'
            ,p_task_or_res                  => 'ASSIGNMENT'
            ,p_element_version_id_tbl       => l_task_elem_version_id_tbl
            ,p_task_number_tbl              => l_task_number_tbl
            ,p_task_name_tbl                => l_task_name_tbl
            ,p_resource_assignment_tbl      => l_resource_assignment_id_tbl
            ,p_currency_code_tbl            => l_currency_code_tbl
            ,x_return_status                => l_return_status
            ,x_msg_count                    => l_msg_count
            ,x_msg_data                     => l_error_msg_code);

		end if;

	Else
		If l_debug_mode = 'Y' Then
			print_msg('Delete Failure');
		End If;
	End if;

 END delete_row;

 PROCEDURE delete_row (x_rowid                  in VARCHAR2)IS

	cursor get_itemid is
	select ci_transaction_id
	from pa_ci_supplier_details
        where rowid = x_rowid;

	l_ci_transaction_id  Number;

 BEGIN
  	open get_itemid;
  	fetch get_itemid into l_ci_transaction_id;
	close get_itemid;

  	delete_row (l_ci_transaction_id);

 END delete_row;

 PROCEDURE lock_row (x_rowid    in VARCHAR2)IS
 BEGIN
  null;
 END lock_row;

END PA_CI_SUPPLIER_PKG;

/
