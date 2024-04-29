--------------------------------------------------------
--  DDL for Package Body PA_PROCESS_CI_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROCESS_CI_LINES_PKG" AS
/* $Header: PAPPCILB.pls 120.0.12010000.10 2010/06/02 11:53:31 racheruv noship $*/

--
-- Procedure update_planning_transaction():
-- This API is called from the process_planning_lines() API.
-- The API accepts rolled up planning lines and calls the
-- update_planning_transactions() API to update resource assignments.
--
-- History:
-- Date     Update By    Comment
--          racheruv     Created
--

procedure update_planning_transaction(p_api_version         IN NUMBER,
                                      p_init_msg_list       IN VARCHAR2,
                                      x_return_status       OUT NOCOPY VARCHAR2,
                                      x_msg_count           OUT NOCOPY NUMBER,
                                      x_msg_data            OUT NOCOPY VARCHAR2,
                                      p_bvid                IN   NUMBER,
                                      p_project_id          in   NUMBER,
                                      p_task_id_tbl         in SYSTEM.PA_NUM_TBL_TYPE,
				                      p_effective_from_tbl  in SYSTEM.PA_DATE_TBL_TYPE,
				                      p_effective_to_tbl    in SYSTEM.PA_DATE_TBL_TYPE,
				                      p_rlmi_id_tbl         IN SYSTEM.PA_NUM_TBL_TYPE,
				                      p_quantity_tbl        IN SYSTEM.PA_NUM_TBL_TYPE,
				                      p_raw_cost_tbl        IN SYSTEM.PA_NUM_TBL_TYPE,
				                      p_currency_code_tbl   IN SYSTEM.PA_VARCHAR2_15_TBL_TYPE
									  ) IS


l_task_name_tbl                SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
l_task_number_tbl              SYSTEM.PA_VARCHAR2_100_TBL_TYPE   := SYSTEM.PA_VARCHAR2_100_TBL_TYPE();
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
l_resource_name                SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
l_project_role_id_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_project_role_name_tbl        SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
l_organization_id_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_organization_name_tbl        SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
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
l_person_id_tbl                SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_job_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_person_type_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();

l_burdened_cost_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_revenue_tbl                  SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_bill_rate_tbl                SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_burdened_rate_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_task_elem_version_id_tbl     SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();

l_bom_resource_id_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_non_labor_resource_tbl       SYSTEM.PA_VARCHAR2_20_TBL_TYPE    := SYSTEM.PA_VARCHAR2_20_TBL_TYPE();
l_inventory_item_id_tbl        SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
l_item_category_id_tbl         SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();

l_expenditure_type_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_expenditure_category_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_event_type_tbl               SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_revenue_category_code_tbl    SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();

l_incur_by_res_class_code_tbl  SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_incur_by_role_id_tbl         SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();

l_struct_elem_version_id Pa_proj_element_versions.parent_structure_version_id%TYPE := -1;
l_elem_ver_id            Pa_proj_element_versions.element_version_id%TYPE := -1;

l_apply_progress_flag          VARCHAR2(1) := 'N';
l_pji_rollup_required          VARCHAR2(1) := 'Y';
l_upd_cost_amts_too_for_ta_flg VARCHAR2(1) := 'N';


	cursor get_elem_ver_id (c_project_id number, c_task_id number) is
        select pev.element_version_id,parent_structure_version_id
	  from pa_proj_element_versions pev,pa_proj_elem_ver_structure pevs
	 where pev.project_id = c_project_id
	   and pev.project_id = pevs.project_id
	   and pev.proj_element_id = c_task_id
	   and pev.parent_structure_version_id = pevs.element_version_id
	   --and pevs.CURRENT_WORKING_FLAG = 'Y';
    -- gboomina modified for bug 9714622 to fetch correct element version id
	   and pevs.element_version_id=PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(c_project_id);

   cursor get_task_details(c_project_id number, c_task_id number) is
   select task_number
     from pa_tasks
    where project_id = c_project_id
	  and task_id = c_task_id;

   cursor get_resource_assignment_id(c_bv_Id NUMBER,
                                      c_task_id NUMBER,
                                      c_rlmi_id number,
                                      c_currency_code varchar2) is
       select pra.resource_assignment_id,
              pra.unit_of_measure,
              pra.project_assignment_id,
              pra.organization_id,
              pra.supplier_id,
              pra.spread_curve_id,
              pra.etc_method_code,
              pra.mfc_cost_type_id,
              pra.procure_resource_flag,
              decode(pra.use_task_schedule_flag,'Y','Y','N') as use_task_schedule_flag,
              pra.planning_start_date,
              pra.planning_end_date,
              pra.schedule_start_date,
              pra.schedule_end_date,
              pra.sp_fixed_date,
              pra.named_role
         from pa_resource_assignments pra, pa_resource_asgn_curr prc
        where pra.budget_version_id = c_bv_Id
          and pra.task_id = c_Task_Id
          and pra.resource_list_member_id = c_rlmi_id
          and pra.resource_assignment_id = prc.resource_assignment_id
          and prc.txn_currency_code = c_currency_code;

    cursor get_resource_details(p_rlmi_id number) is
	select alias resource_alias,
	       resource_class_flag,
		   resource_class_code,
		   --resource_class_id,
		   res_type_code,
		   fc_res_type_code
      from pa_resource_list_members
     where resource_list_member_id = p_rlmi_id;

    cursor get_dc_burden_cost_rate(c_task_id number,
                                   c_rlmi_id number,
                                   c_currency_code varchar2) IS
    select distinct burden_cost_rate
      from pa_ci_direct_cost_details
     where task_id                 = c_task_id
       and resource_list_member_id = c_rlmi_id
       and currency_code           = c_currency_code
	   and ci_id  = (select ci_id from pa_budget_versions where budget_version_id = p_bvid)
	   and burden_cost_rate is not null;

    cursor get_sc_burden_cost_rate(c_task_id number,
                                   c_rlmi_id number,
                                   c_currency_code varchar2) IS
    select distinct burden_cost_rate
      from pa_ci_direct_cost_details
     where task_id                 = c_task_id
       and resource_list_member_id = c_rlmi_id
       and currency_code           = c_currency_code
	   and ci_id  = (select ci_id from pa_budget_versions where budget_version_id = p_bvid)
	   and burden_cost_rate is not null;

 l_burden_cost_rate     number;

 l_api_name            CONSTANT varchar2(30) := 'CI.update_planning_trx';
 l_return_status        varchar2(1);
 l_msg_count            number;
 l_msg_data             varchar2(2000);

begin

    l_return_status := PA_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;

   if p_task_id_tbl.count > 0 then
     for i in p_task_id_tbl.first..p_task_id_tbl.last loop
	 open get_elem_ver_id(p_project_id, p_task_id_tbl(i));
         fetch get_elem_ver_id into l_elem_ver_id, l_struct_elem_version_id;
         close get_elem_ver_id;

	 l_task_elem_version_id_tbl.extend(1);
	 l_task_elem_version_id_tbl(i) := l_elem_ver_id;

	 --p_task_name_tbl
	 l_task_name_tbl.extend(1);
	 l_task_name_tbl(i) := '';

	 --p_task_number_tbl
	 l_task_number_tbl.extend(1);
	 l_task_number_tbl(i) := '';

	 open get_task_details(p_project_id, p_task_id_tbl(i));
     fetch get_task_details into l_task_number_tbl(i);
	 close get_task_details;


	 --p_start_date_tbl
	 l_in_start_date_tbl.extend(1);
	 --l_in_start_date_tbl(i) := to_date(p_effective_from_tbl(i),'YYYY/MM/DD');
	 l_in_start_date_tbl(i) := to_date(null);
	 --p_end_date_tbl
	 l_in_end_date_tbl.extend(1);
	 --l_in_end_date_tbl(i) := to_date(p_effective_to_tbl(i),'YYYY/MM/DD');
	 l_in_end_date_tbl(i) := to_date(null);



	 --p_planned_people_effort_tbl
	 l_planned_people_effort_tbl.extend(1);
	 l_planned_people_effort_tbl(i) := '';

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

	 open get_resource_assignment_id(p_bvId, p_task_id_tbl(i), p_rlmi_id_tbl(i), p_currency_code_tbl(i));

	 fetch get_resource_assignment_id into
			l_resource_assignment_id_tbl(i),l_unit_of_measure_tbl(i),l_project_assignment_id_tbl(i),
			l_organization_id_tbl(i),l_supplier_id_tbl(i),l_spread_curve_id_tbl(i),
			l_etc_method_code_tbl(i),l_mfc_cost_type_id_tbl(i),l_procure_resource_flag_tbl(i),
			l_use_task_schedule_flag_tbl(i),l_planning_start_date_tbl(i),l_planning_end_date_tbl(i),
			l_schedule_start_date_tbl(i),l_schedule_end_date_tbl(i),l_sp_fixed_date_tbl(i),
			l_named_role_tbl(i);

	 close get_resource_assignment_id;

			-- planning start date
            l_planning_start_date_tbl(i) := p_effective_from_tbl(i);

			-- planning end date
            l_planning_end_date_tbl(i) := p_effective_to_tbl(i);

			--p_assignment_description_tbl
			l_assignment_description_tbl.extend(1);
			l_assignment_description_tbl(i) := '';

			--p_resource_alias_tbl
			l_planning_resource_alias_tbl.extend(1);
			l_planning_resource_alias_tbl(i) := '';

			--p_resource_class_flag_tbl
			l_resource_class_flag_tbl.extend(1);
			l_resource_class_flag_tbl(i) := '';

			--p_resource_class_code_tbl
			l_resource_class_code_tbl.extend(1);
			l_resource_class_code_tbl(i) := '';

			--p_resource_class_id_tbl
			l_resource_class_id_tbl.extend(1);
			l_resource_class_id_tbl(i) := '';

			--p_res_type_code_tbl
			l_res_type_code_tbl.extend(1);
			l_res_type_code_tbl(i) := '';

            --p_resource_code_tbl
			l_resource_code_tbl.extend(1);
			l_resource_code_tbl(i) := '';


            --p_fc_res_type_code_tbl
			l_fc_res_type_code_tbl.extend(1);
			l_fc_res_type_code_tbl(i) := '';

			open get_resource_details(p_rlmi_id_tbl(i));
			fetch get_resource_details into l_planning_resource_alias_tbl(i),
                  l_resource_class_flag_tbl(i), l_resource_class_code_tbl(i),
				  l_res_type_code_tbl(i), l_fc_res_type_code_tbl(i);

            close get_resource_details;

            --p_resource_name
			l_resource_name.extend(1);
			l_resource_name(i) := l_planning_resource_alias_tbl(i);

            --p_project_role_id_tbl
			l_project_role_id_tbl.extend(1);
			l_project_role_id_tbl(i) := '';

            --p_project_role_name_tbl
			l_project_role_name_tbl.extend(1);
			l_project_role_name_tbl(i) := '';

            --p_organization_name_tbl
			l_organization_name_tbl.extend(1);
			l_organization_name_tbl(i) := '';

            --p_financial_category_code_tbl
			l_financial_category_code_tbl.extend(1);
			l_financial_category_code_tbl(i) := '';

	    --p_incur_by_resource_code_tbl
			l_Incur_by_resource_code_tbl.extend(1);
			l_Incur_by_resource_code_tbl(i) := '';

            --p_incur_by_resource_name_tbl
			l_incur_by_resource_name_tbl.extend(1);
			l_incur_by_resource_name_tbl(i) := '';


            --p_txn_currency_override_tbl
			l_override_currency_code_tbl.extend(1);
			l_override_currency_code_tbl(i) := '';


		    --p_burdened_cost_tbl
		    l_burdened_cost_tbl.extend(1);
		    l_burdened_cost_tbl(i) := NULL;

            --p_revenue_tbl
			l_revenue_tbl.extend(1);
			l_revenue_tbl(i) := null;
            --p_cost_rate_tbl
			l_raw_cost_rate_tbl.extend(1);
			l_raw_cost_rate_tbl(i) := NULL;
            --p_bill_rate_tbl
			l_bill_rate_tbl.extend(1);
			l_bill_rate_tbl(i) := NULL;
            --p_bill_rate_override_tbl
			l_bill_rate_override_tbl.extend(1);
			l_bill_rate_override_tbl(i) := FND_API.G_MISS_NUM;
            --p_billable_percent_tbl
			l_billable_percent_tbl.extend(1);
			l_billable_percent_tbl(i) := NULL;
            --p_cost_rate_override_tbl
			l_cost_rate_override_tbl.extend(1);
			l_cost_rate_override_tbl(i) := FND_API.G_MISS_NUM;
            --p_burdened_rate_tbl
			l_burdened_rate_tbl.extend(1);
			l_burdened_rate_tbl(i) := NULL;
            --p_burdened_rate_override_tbl
			l_burdened_rate_override_tbl.extend(1);
			l_burdened_rate_override_tbl(i) := FND_API.G_MISS_NUM;

            --p_financial_category_name_tbl
			l_financial_category_name_tbl.extend(1);
			l_financial_category_name_tbl(i) := '';
            --p_supplier_name_tbl
			l_supplier_name_tbl.extend(1);
			l_supplier_name_tbl(i) := '';

            --p_attribute_category_tbl    1 --> 30
			l_attribute_category_tbl.extend(1);
			l_attribute1_tbl.extend(i);
			l_attribute_category_tbl(i) := '';
			l_attribute1_tbl(i) := '';

	    --p_scheduled_delay
			l_scheduled_delay.extend(1);
			l_scheduled_delay(i) := null;

	    --p_direct_expenditure_type_tbl
			l_direct_expenditure_type_tbl.extend(1);
			l_direct_expenditure_type_tbl(i) := '';

			l_person_id_tbl.extend(1);
			l_person_id_tbl(i) := NULL;

			l_job_id_tbl.extend(1);
			l_job_id_tbl(i) := null;

			l_person_type_code_tbl.extend(1);
			l_person_type_code_tbl(i) := null;

			l_bom_resource_id_tbl.extend(1);
			l_bom_resource_id_tbl(i) := null;

            l_non_labor_resource_tbl.extend(1);
            l_non_labor_resource_tbl(i) := null;

            l_inventory_item_id_tbl.extend(1);
            l_inventory_item_id_tbl(i) := null;

            l_item_category_id_tbl.extend(1);
            l_item_category_id_tbl(i) := null;

            l_expenditure_type_tbl.extend(1);
            l_expenditure_type_tbl(i) := null;
            l_expenditure_category_tbl.extend(1);
            l_expenditure_category_tbl(i) := null;
            l_event_type_tbl.extend(1);
            l_event_type_tbl(i) := null;
            l_revenue_category_code_tbl.extend(1);
            l_revenue_category_code_tbl(i) := null;
            l_incurred_by_res_flag_tbl.extend(1);
            l_incurred_by_res_flag_tbl(i) := null;
            l_incur_by_res_class_code_tbl.extend(1);
            l_incur_by_res_class_code_tbl(i) := null;
            l_incur_by_role_id_tbl.extend(1);
            l_incur_by_role_id_tbl(i) := null;
            l_total_quantity_tbl.extend(1);
            l_total_raw_cost_tbl.extend(1);


            if p_quantity_tbl.exists(i) then
               l_total_quantity_tbl(i) := p_quantity_tbl(i);
            else
               l_total_quantity_tbl(i) := NULL;
            end if;

            if p_raw_cost_tbl.exists(i) then
              l_total_raw_cost_tbl(i) := p_raw_cost_tbl(i);

              -- bug 9696864: provide the new burden cost to remove override.
              l_burden_cost_rate := null;
              open get_dc_burden_cost_rate(p_task_id_tbl(i), p_rlmi_id_tbl(i),
                                           p_currency_code_tbl(i));
              fetch get_dc_burden_cost_rate into l_burden_cost_rate;
              close get_dc_burden_cost_rate;

              if l_burden_cost_rate is null then
                open get_sc_burden_cost_rate(p_task_id_tbl(i), p_rlmi_id_tbl(i),
                                             p_currency_code_tbl(i));
                fetch get_sc_burden_cost_rate into l_burden_cost_rate;
                close get_sc_burden_cost_rate;
              end if;

              l_burdened_cost_tbl(i) := p_raw_cost_tbl(i) * l_burden_cost_rate;
              -- bug 9696864: end change
            else
              l_total_raw_cost_tbl(i) := NULL;
            end if;

     end loop;
   end if;

		    --calling api

	pa_fp_planning_transaction_pub.update_planning_transactions(
       p_context                      => 'BUDGET'
      ,p_calling_context              => NULL
      ,p_struct_elem_version_id       => l_struct_elem_version_id
      ,p_budget_version_id            => p_bvid
      ,p_task_elem_version_id_tbl     => l_task_elem_version_id_tbl
      ,p_task_name_tbl                => l_task_name_tbl
      ,p_task_number_tbl              => l_task_number_tbl
      ,p_start_date_tbl               => l_in_start_date_tbl
      ,p_end_date_tbl                 => l_in_end_date_tbl
      ,p_planned_people_effort_tbl    => l_planned_people_effort_tbl
      ,p_resource_assignment_id_tbl   => l_resource_assignment_id_tbl
      ,p_resource_list_member_id_tbl  => p_rlmi_id_tbl
      ,p_assignment_description_tbl   => l_assignment_description_tbl
      ,p_project_assignment_id_tbl    => l_project_assignment_id_tbl
      ,p_resource_alias_tbl           => l_planning_resource_alias_tbl
      ,p_resource_class_flag_tbl      => l_resource_class_flag_tbl
      ,p_resource_class_code_tbl      => l_resource_class_code_tbl
      ,p_resource_class_id_tbl        => l_resource_class_id_tbl
      ,p_res_type_code_tbl            => l_res_type_code_tbl
      ,p_resource_code_tbl            => l_resource_code_tbl
      ,p_resource_name                => l_resource_name
      ,p_person_id_tbl                => l_person_id_tbl
      ,p_job_id_tbl                   => l_job_id_tbl
      ,p_person_type_code             => l_person_type_code_tbl
      ,p_bom_resource_id_tbl          => l_bom_resource_id_tbl
      ,p_non_labor_resource_tbl       => l_non_labor_resource_tbl
      ,p_inventory_item_id_tbl        => l_inventory_item_id_tbl
      ,p_item_category_id_tbl         => l_item_category_id_tbl
      ,p_project_role_id_tbl          => l_project_role_id_tbl
      ,p_project_role_name_tbl        => l_project_role_name_tbl
      ,p_organization_id_tbl          => l_organization_id_tbl
      ,p_organization_name_tbl        => l_organization_name_tbl
      ,p_fc_res_type_code_tbl         => l_fc_res_type_code_tbl
      ,p_financial_category_code_tbl  => l_financial_category_code_tbl
      ,p_expenditure_type_tbl         => l_expenditure_type_tbl
      ,p_expenditure_category_tbl     => l_expenditure_category_tbl
      ,p_event_type_tbl               => l_event_type_tbl
      ,p_revenue_category_code_tbl    => l_revenue_category_code_tbl
      ,p_incurred_by_res_flag_tbl     => l_incurred_by_res_flag_tbl
      ,p_incur_by_res_class_code_tbl  => l_incur_by_res_class_code_tbl
      ,p_incur_by_role_id_tbl         => l_incur_by_role_id_tbl
      ,p_supplier_id_tbl              => l_supplier_id_tbl
      ,p_unit_of_measure_tbl          => l_unit_of_measure_tbl,
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
       p_currency_code_tbl            => p_currency_code_tbl,
       p_txn_currency_override_tbl    => l_override_currency_code_tbl,
       p_raw_cost_tbl                 => l_total_raw_cost_tbl,
       p_burdened_cost_tbl            => l_burdened_cost_tbl,
       p_revenue_tbl                  => l_revenue_tbl,
       p_cost_rate_tbl                => l_raw_cost_rate_tbl,
       p_cost_rate_override_tbl       => l_cost_rate_override_tbl,
       p_burdened_rate_tbl            => l_burdened_rate_tbl,
       p_burdened_rate_override_tbl   => l_burdened_rate_override_tbl,
       p_bill_rate_tbl                => l_bill_rate_tbl,
       p_bill_rate_override_tbl       => l_bill_rate_override_tbl,
       p_billable_percent_tbl         => l_billable_percent_tbl,
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
       p_attribute30_tbl              => l_attribute1_tbl
      ,p_apply_progress_flag          => 'N'
      ,p_scheduled_delay              => l_scheduled_delay
      ,p_pji_rollup_required          => 'Y'
      ,p_upd_cost_amts_too_for_ta_flg => 'N'
      ,p_distrib_amts                 => 'Y'
      ,p_direct_expenditure_type_tbl  => l_direct_expenditure_type_tbl,
       x_return_status                => l_return_status,
       x_msg_count                    => l_msg_count,
       x_msg_data                     => l_msg_data);

      IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_ERROR;
      END IF;

  PA_API.END_ACTIVITY(l_msg_count, l_msg_data);
  x_return_status := PA_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
end update_planning_transaction;
--
-- Procedure delete_planning_transaction():
-- This API is called from the process_planning_lines() API.
-- The API accepts rolled up planning lines and calls the
-- delete_planning_transactions() API to delete resource assignments.
--
-- History:
-- Date     Update By    Comment
--          racheruv     Created
--
procedure delete_planning_transaction(p_api_version  IN NUMBER,
                                      p_init_msg_list  IN VARCHAR2,
                                      x_return_status  OUT NOCOPY VARCHAR2,
                                      x_msg_count      OUT NOCOPY NUMBER,
                                      x_msg_data       OUT NOCOPY VARCHAR2,
                                      p_bvid           IN number,
                                      p_project_id     IN number,
                                      p_task_tbl       IN SYSTEM.PA_NUM_TBL_TYPE,
                                      p_currency_tbl   IN SYSTEM.PA_VARCHAR2_15_TBL_TYPE,
                                      p_rlmi_tbl       IN SYSTEM.PA_NUM_TBL_TYPE
                                      ) IS

	cursor get_assignment_details(c_bvId number,
                                  c_task_id number,
                                  c_rlmi_id number,
                                  c_currency_code varchar2) is
	  select pra.RESOURCE_ASSIGNMENT_ID, ppe.ELEMENT_NUMBER, ppe.NAME
	  from pa_resource_assignments pra, pa_proj_elements ppe, pa_tasks pt,
	       pa_resource_asgn_curr prc
	  WHERE pra.budget_version_id = c_bvId
	  and pra.task_id = c_task_id
	  and pra.RESOURCE_LIST_MEMBER_ID = c_rlmi_id
	  and pra.resource_assignment_id = prc.resource_assignment_id
	  and prc.txn_currency_code = c_currency_code
	  and pt.task_id = ppe.proj_element_id;

	cursor get_elem_ver_id (c_proj_id number, c_task_id number) is
      select pev.element_version_id
	    from pa_proj_element_versions pev, pa_proj_elem_ver_structure pevs
	   where pev.project_id = c_proj_id and pev.project_id=pevs.project_id
	     and pev.proj_element_id=c_task_id
		 and pev.parent_structure_version_id=pevs.element_version_id
    --and pevs.CURRENT_WORKING_FLAG='Y';
    -- gboomina modified for bug 9714622 to fetch correct element version id
	   and pevs.element_version_id=PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(c_proj_id);


  l_task_elem_version_id_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  l_task_number_tbl             SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
  l_task_name_tbl               SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
  l_res_assgn_tbl               SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

  l_resource_assignment_id      number;
  l_task_number                 varchar2(30);
  l_task_name                   varchar2(30);
  l_task_elem_version_id        number;

  l_rbs_element_id_tbl          SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
  l_rate_based_flag_tbl         SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM.pa_varchar2_1_tbl_type();
  l_resource_class_code_tbl     SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();

  l_api_name                    CONSTANT VARCHAR2(30) := 'CI.delete_planning_trx';
  l_return_status               varchar2(1);
  l_msg_data                    varchar2(2000);
  l_msg_count                   number;

--(
begin

    l_return_status := PA_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;

  if p_task_tbl.count > 0 then
    for i in p_task_tbl.first..p_task_tbl.last loop
      open get_assignment_details(p_bvId, p_task_tbl(i),
                                  p_rlmi_tbl(i), p_currency_tbl(i));
      fetch get_assignment_details into l_resource_assignment_id,
            l_task_number, l_task_name;

            l_task_number_tbl.extend(1);
            l_task_name_tbl.extend(1);
            l_res_assgn_tbl.extend(1);

            l_res_assgn_tbl(i)    := l_resource_assignment_id;
            l_task_number_tbl(i)  := l_task_number;
            l_task_name_tbl(i)    := l_task_name;

      close get_assignment_details;

      open get_elem_ver_id(p_project_id, p_task_tbl(i));
      fetch get_elem_ver_id into l_task_elem_version_id;

      l_task_elem_version_id_tbl.extend(1);
      l_task_elem_version_id_tbl(i) := l_task_elem_version_id;


       l_rbs_element_id_tbl.extend(1);
	   l_rbs_element_id_tbl(i) := null;

       l_rate_based_flag_tbl.extend(1);
	   l_rate_based_flag_tbl(i) := null;

       l_resource_class_code_tbl.extend(1);
	   l_resource_class_code_tbl(i) := null;

      close get_elem_ver_id;
    end loop;
  end if;

		pa_fp_planning_transaction_pub.delete_planning_transactions(
            p_context                      => 'BUDGET'
            ,p_calling_context              => NULL
            ,p_task_or_res                  => 'ASSIGNMENT'
            ,p_element_version_id_tbl       => l_task_elem_version_id_tbl
            ,p_task_number_tbl              => l_task_number_tbl
            ,p_task_name_tbl                => l_task_name_tbl
            ,p_resource_assignment_tbl      => l_res_assgn_tbl
            ,p_validate_delete_flag         => 'N'
            ,p_currency_code_tbl            => p_currency_tbl
            ,p_calling_module               => NULL
            ,p_task_id_tbl                  => p_task_tbl
            ,p_rbs_element_id_tbl           => l_rbs_element_id_tbl
            ,p_rate_based_flag_tbl          => l_rate_based_flag_tbl
            ,p_resource_class_code_tbl      => l_resource_class_code_tbl
            ,p_rollup_required_flag         => 'Y'
            ,p_pji_rollup_required          => 'Y'
            ,x_return_status                => l_return_status
            ,x_msg_count                    => l_msg_count
            ,x_msg_data                     => l_msg_data);

       IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_ERROR;
      END IF;

  PA_API.END_ACTIVITY(l_msg_count, l_msg_data);
  x_return_status := PA_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
end delete_planning_transaction;

--
-- Procedure insert_planning_transaction():
-- This API is called from the process_planning_lines() API.
-- The API accepts rolled up planning lines and calls the
-- add_new_resource_assignments() API to create a new resource assignment.
--
-- History:
-- Date     Update By    Comment
--          racheruv     Created
--

procedure insert_planning_transaction(p_api_version        IN NUMBER,
                                      p_init_msg_list      IN VARCHAR2,
                                      x_return_status      OUT NOCOPY VARCHAR2,
                                      x_msg_count          OUT NOCOPY NUMBER,
                                      x_msg_data           OUT NOCOPY VARCHAR2,
                                      P_BVID               IN  NUMBER,
                                      P_PROJECT_ID         IN  NUMBER,
				                      P_TASK_ID_TBL        IN  SYSTEM.pa_num_tbl_type,
                                      P_RLMI_ID_TBL        IN SYSTEM.pa_num_tbl_type,
				                      P_CURRENCY_CODE_TBL  IN  SYSTEM.PA_VARCHAR2_15_TBL_TYPE,
				                      P_QUANTITY_TBL       IN  SYSTEM.pa_num_tbl_type,
				                      P_RAW_COST_TBL       IN  SYSTEM.pa_num_tbl_type
				                      ) IS
--{
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


  cursor get_elem_ver_id (c_proj_id number, c_task_id number) is
    select pev.element_version_id
      from pa_proj_element_versions pev, pa_proj_elem_ver_structure pevs
     where pev.project_id = c_proj_id
	   and pev.project_id=pevs.project_id
       and pev.proj_element_id=c_task_id
	   and pev.parent_structure_version_id=pevs.element_version_id
    -- and pevs.CURRENT_WORKING_FLAG='Y';
    -- gboomina modified for bug 9714622 to fetch correct element version id
	   and pevs.element_version_id=PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(c_proj_id);



 l_api_name                     CONSTANT varchar2(30) := 'CI.insert_planning_trx';
 l_return_status                varchar2(1);
 l_msg_data                     varchar2(2000);
 l_msg_count                    number;

begin

    l_return_status := PA_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);

    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;

   if p_bvId is not null then
     if p_task_id_tbl.count > 0 then
        for i in p_task_id_tbl.first..p_task_id_tbl.last loop

	 --task_element_version_id
	 l_task_elem_version_id_tbl.extend(1);
	 open get_elem_ver_id(p_project_id, p_task_id_tbl(i));
         fetch get_elem_ver_id into l_task_elem_version_id_tbl(i);
         close get_elem_ver_id;


	 --burdened cost
	 l_burdened_cost_tbl.extend(1);
	 l_burdened_cost_tbl(i) := NULL;

	 --revenue
	 l_revenue_tbl.extend(1);
	 l_revenue_tbl(i) := null;

	 --cost rate
	 l_cost_rate_tbl.extend(1);
	 l_cost_rate_tbl(i) := NULL;

	 --bill rate
	 l_bill_rate_tbl.extend(1);
	 l_bill_rate_tbl(i) := null;

	 --burdened rate
	 l_burdened_rate_tbl.extend(1);
	 l_burdened_rate_tbl(i) := NULL;

	 --unplanned flag
	 l_unplanned_flag_tbl.extend(1);
	 l_unplanned_flag_tbl(i) := NULL;

	 --expenditure type
	 l_expenditure_type_tbl.extend(1);
	 l_expenditure_type_tbl(i) := NULL;


        end loop;
     end if;


	 --call pa_planning_element_utils.add_new_resource_assignments
     -- to add the resource assignment
		 pa_planning_element_utils.add_new_resource_assignments(
                            p_context                      => 'BUDGET',
                            p_project_id                   => p_project_id,
                            p_budget_version_id            => p_bvId,
                            p_task_elem_version_id_tbl     => l_task_elem_version_id_tbl,
                            p_resource_list_member_id_tbl  => p_rlmi_id_tbl,
                            p_quantity_tbl                 => p_quantity_tbl,
                            p_currency_code_tbl            => p_currency_code_tbl,
                            p_raw_cost_tbl                 => p_raw_cost_tbl,
                            p_burdened_cost_tbl            => l_burdened_cost_tbl,
                            p_revenue_tbl                  => l_revenue_tbl,
                            p_cost_rate_tbl                => l_cost_rate_tbl,
                            p_bill_rate_tbl                => l_bill_rate_tbl,
                            p_burdened_rate_tbl            => l_burdened_rate_tbl,
                            p_unplanned_flag_tbl           => l_unplanned_flag_tbl,
                            p_expenditure_type_tbl         => l_expenditure_type_tbl,
                            x_return_status                => l_return_status,
                            x_msg_count                    => l_msg_count,
                            x_msg_data                     => l_msg_data);

      IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_ERROR;
      END IF;
  end if; -- if p_bvid is not null
--}

  PA_API.END_ACTIVITY(l_msg_count, l_msg_data);
  x_return_status := PA_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
end insert_planning_transaction;

--
-- Procedure process_planning_lines():
-- This API is called from the process API of the direct cost and the
-- supplier cost regions. This is the entry API to this package.
-- The API rolls up the input data to Task/Planning Resource/Currency and
-- verifies if a resource assignment is present for that combination.
-- Based on the existence of the resource assignment and the action type,
-- insert/update/delete API is called to affect the resource assignment.
--
-- p_calling_context: valid values: 'DIRECT_COST'/'SUPPLIER_COST'
-- p_action_type: valid values are: 'INSERT'/'UPDATE'/'DELETE'
--
-- History:
-- Date     Update By    Comment
--          racheruv     Created

procedure process_planning_lines(p_api_version      IN NUMBER,
                                 p_init_msg_list      IN VARCHAR2,
                                 x_return_status      OUT NOCOPY VARCHAR2,
                                 x_msg_count          OUT NOCOPY NUMBER,
                                 x_msg_data           OUT NOCOPY VARCHAR2,
                                 p_calling_context    IN VARCHAR2,
				                 p_action_type        IN VARCHAR2,
				                 p_bvid               IN NUMBER,
				                 p_ci_id              IN NUMBER,
				                 p_line_id_tbl        IN SYSTEM.PA_NUM_TBL_TYPE,
				                 p_project_id         IN NUMBER,
				                 p_task_id_tbl        IN SYSTEM.PA_NUM_TBL_TYPE,
				                 p_currency_code_tbl  IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
				                 p_rlmi_id_tbl        IN SYSTEM.PA_NUM_TBL_TYPE,
				                 p_res_assgn_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE,
				                 p_quantity_tbl       IN SYSTEM.PA_NUM_TBL_TYPE
								 DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
				                 p_raw_cost_tbl       IN SYSTEM.PA_NUM_TBL_TYPE
								 DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
								 ) IS


  cursor dc_csr (p_ci_id number, p_project_id number,
                 p_task_id number,
                 p_resource_list_member_id number,
                 p_currency_code varchar2) is
  select min(effective_from),
         max(effective_to),
         sum(quantity),
         sum(raw_cost),
         count(*)
    from pa_ci_direct_cost_details
   where ci_id = p_ci_id
     and task_id = p_task_id
     and resource_list_member_id = p_resource_list_member_id
     and currency_code = p_currency_code;

  cursor sup_csr(p_ci_id number, p_project_id number,
                 p_task_id number,
                 p_resource_list_member_id number,
                 p_currency_code varchar2) is
  select min(from_change_date) effective_from,
         max(to_change_date) effective_to,
         sum(NULL) quantity,
         sum(raw_cost),
         count(*)
    from pa_ci_supplier_details
   where ci_id = p_ci_id
     and task_id = p_task_id
     and resource_list_member_id = p_resource_list_member_id
     and currency_code = p_currency_code;

   j    number := 0;
   TYPE varchar1_tbl IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

   rollup_project_tbl        SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   rollup_task_tbl           SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   rollup_rlmi_tbl           SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   rollup_raw_cost_tbl       SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   rollup_quantity_tbl       SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   rollup_res_assgn_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   rollup_effective_from     SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
   rollup_effective_to       SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
   db_raw_cost_tbl           SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   db_quantity_tbl           SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   db_res_assgn_tbl          SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();

   rollup_currency_tbl       SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
   rollup_rate_based         varchar1_tbl;
   rollup_ra_exists          varchar1_tbl;
   rolled_up                 varchar1_tbl;

   upd_task_tbl              SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   upd_effective_from        SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
   upd_effective_to          SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
   upd_rlmi_tbl              SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   upd_quantity_tbl          SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   upd_raw_cost_tbl          SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   upd_currency_tbl          SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();

   ins_task_tbl              SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   ins_rlmi_tbl              SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   ins_quantity_tbl          SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   ins_raw_cost_tbl          SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   ins_currency_tbl          SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();

   del_task_tbl              SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   del_rlmi_tbl              SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   del_currency_tbl          SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();

   ip_task_id_tbl            SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();

   qty_from_tbl              SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();
   amt_from_tbl              SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.pa_num_tbl_type();

   TYPE num_tbl is table of number index by binary_integer;
   rollup_count              NUM_TBL;

   TYPE curr_tbl IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;

   fc_currency_tbl           curr_tbl;

   cursor does_ra_exist(c_bvid          number,
                        c_task_id       number,
                        c_rlmi_id       number,
                        c_currency_code varchar2) is
   select 'Y', pra.resource_assignment_id,
          total_quantity,
          total_txn_raw_cost
     from pa_resource_assignments pra, pa_resource_asgn_curr prac
    where pra.budget_version_id = c_bvid and pra.task_id = c_task_id
      and pra.resource_list_member_id = c_rlmi_id
      and prac.txn_currency_code = c_currency_code
      and prac.resource_assignment_id = pra.resource_assignment_id;

      cursor get_resource_asgn_csr(c_bvid number,
                                   c_task_id number,
                                   c_rlmi_id number) is
      select txn_currency_code
         from pa_resource_assignments pra, pa_resource_asgn_curr prc
      where pra.resource_assignment_id = prc.resource_assignment_id
           and pra.budget_version_id   = c_bvid
           and pra.task_id             = c_task_id
           and pra.resource_list_member_id = c_rlmi_id
           and prc.total_quantity is not null;
           --and prc.total_txn_raw_cost is not null;

   l_rate_based_res_curr       varchar2(15);

txn_quantity_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
txn_raw_cost_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

subtype PaCiDirCostTblType is pa_ci_dir_cost_pvt.PaCiDirectCostDetailsTblType;
DeleteDCTblRecs     PaCiDirCostTblType;

l_api_version        number := 1;
l_api_name           constant varchar2(30) := 'CI.process_planning_lines';
l_return_status      varchar2(1);
l_msg_count          number;
l_msg_data           varchar2(2000);

k                    number := 0;
tbl_count            number := 0;
l_found              number := 0;
l_delete             varchar2(1) := 'N';
l_update             varchar2(1) := 'N';
l_count              number := 0;
upd_count            number := 0;
fc_count             number := 0;
fc_quantity          number := 0;

l_effective_from     date;
l_effective_to       date;
l_quantity           number;
l_raw_cost           number;

begin

    l_return_status := PA_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PUB',
                                              x_return_status);

    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;

-- Step 1: rollup the input tables to P/T/R/C
  if p_task_id_tbl.count > 0 then
    for i in p_task_id_tbl.first..p_task_id_tbl.last loop

      ip_task_id_tbl.extend(1);
      ip_task_id_tbl(i) := p_task_id_tbl(i);
      rolled_up(i) := 'N';

	  qty_from_tbl.extend(1);
	  amt_from_tbl.extend(1);
    end loop;
  end if;

  if ip_task_id_tbl.count > 0 then
    j := 0;

        rollup_task_tbl.extend(1);
        rollup_rlmi_tbl.extend(1);
        rollup_currency_tbl.extend(1);
        rollup_raw_cost_tbl.extend(1);
        rollup_quantity_tbl.extend(1);

 k := 1;

for i in ip_task_id_tbl.first..ip_task_id_tbl.last loop

    if rolled_up(i) = 'Y' then
      goto null_processing;
    else
      if k <> 1 then
        rollup_task_tbl.extend(1);
        rollup_rlmi_tbl.extend(1);
        rollup_currency_tbl.extend(1);
        rollup_raw_cost_tbl.extend(1);
        rollup_quantity_tbl.extend(1);
      end if;
    end if;

    rollup_task_tbl(k)     := ip_task_id_tbl(i);
    rollup_rlmi_tbl(k)     := p_rlmi_id_tbl(i);
    rollup_currency_tbl(k) := p_currency_code_tbl(i);


    rolled_up(i) := 'Y';
    if nvl(pa_planning_resource_utils.get_rate_based_flag(p_rlmi_id_tbl(i)), 'N') = 'Y' then
      rollup_rate_based(k) := 'Y';
    else
      rollup_rate_based(k) := 'N';
    end if;


  if i = ip_task_id_tbl.last then
    exit;
  end if;

  for j in i+1..ip_task_id_tbl.count loop

    if (rollup_task_tbl(k) = ip_task_id_tbl(j) and
        rollup_rlmi_tbl(k) = p_rlmi_id_tbl(j) and
        rollup_currency_tbl(k) = p_currency_code_tbl(j)) then
        rolled_up(j) := 'Y';
    end if;
  end loop;

  k := k + 1;

  <<NULL_PROCESSING>>
    if i = ip_task_id_tbl.last then
      exit;
    end if;
end loop;
end if; -- p_task_id_tbl.count

-- Step 2: rollup the db data to P/T/R/C .. based on the table above
  if rollup_task_tbl.count > 0 then

    for i in rollup_task_tbl.first..rollup_task_tbl.last loop
      rollup_effective_from.extend(1);
      rollup_effective_to.extend(1);
      db_quantity_tbl.extend(1);
      db_raw_cost_tbl.extend(1);
      rollup_res_assgn_tbl.extend(1);
  	  txn_quantity_tbl.extend(1);
	    txn_raw_cost_tbl.extend(1);
      rollup_count(i) := null;
    end loop;

    for i in rollup_task_tbl.first..rollup_task_tbl.last loop -- loop 1

    --elsif p_calling_context = 'DIRECT_COST' then
      open dc_csr(p_ci_id, p_project_id, rollup_task_tbl(i),
                   rollup_rlmi_tbl(i), rollup_currency_tbl(i));

      fetch dc_csr into l_effective_from, l_effective_to,
                         l_quantity, l_raw_cost,
                         l_count;
      if nvl(l_count, 0) > 0 then
         rollup_effective_from(i) := l_effective_from;
		 rollup_effective_to(i)   := l_effective_to;
		 db_quantity_tbl(i)       := l_quantity;
		 db_raw_cost_tbl(i)       := l_raw_cost;
		 rollup_count(i)          := l_count;
	  end if;
   close dc_csr;

    --if p_calling_context = 'SUPPLIER_COST' then

      open sup_csr(p_ci_id, p_project_id, rollup_task_tbl(i),
                   rollup_rlmi_tbl(i), rollup_currency_tbl(i));

      fetch sup_csr into l_effective_from, l_effective_to,
                         l_quantity, l_raw_cost,
                         l_count;
      if nvl(l_count, 0) > 0 then
         rollup_effective_from(i) := least(l_effective_from, nvl(rollup_effective_from(i),
		                                                         l_effective_from));

         rollup_effective_to(i)   := greatest(l_effective_to, nvl(rollup_effective_to(i),
		                                                          l_effective_to));

		 db_quantity_tbl(i)       := nvl(db_quantity_tbl(i), 0) + l_quantity;
		 db_raw_cost_tbl(i)       := nvl(db_raw_cost_tbl(i), 0) + l_raw_cost;
		 rollup_count(i)          := nvl(rollup_count(i), 0) + l_count;
	  end if;
      close sup_csr;

      if rollup_count(i) is null then
         rollup_count(i) := 0;
      end if;


      if rollup_rate_based(i) = 'Y' then
        db_raw_cost_tbl(i) := NULL;
      else
        db_quantity_tbl(i) := NULL;
      end if;
    --end if;

-- Step 3: verify if there exists a resource_assignment data for the rollup
    open does_ra_exist(p_bvid, rollup_task_tbl(i),
                       rollup_rlmi_tbl(i),
                       rollup_currency_tbl(i));
    fetch does_ra_exist into rollup_ra_exists(i), rollup_res_assgn_tbl(i),
	                   txn_quantity_tbl(i), txn_raw_cost_tbl(i);

          if does_ra_exist%NOTFOUND then
             rollup_ra_exists(i) := 'N';
          end if;
    close does_ra_exist;

    end loop; -- loop 1
  end if;     -- rollup_task_tbl.count > 0

-- Step 4: based on the existence of the resource assignment and the
-- action_type, call the appropriate api
  k := 0;
  j := 0;
  if p_action_type = 'DELETE' then
    for i in rollup_task_tbl.first..rollup_task_tbl.last loop -- delete loop
      l_delete := 'N';
      l_update := 'N';

      if rollup_count(i) = 0 then
         l_delete := 'Y';
      else
         l_update := 'Y';
      end if;
      if l_delete = 'Y' then
        del_task_tbl.extend(1);
        del_currency_tbl.extend(1);
        del_rlmi_tbl.extend(1);

        j := j + 1;
        del_task_tbl(j)     := rollup_task_tbl(i);
        del_currency_tbl(j) := rollup_currency_tbl(i);
        del_rlmi_tbl(j)     := rollup_rlmi_tbl(i);
      end if;


      if l_update = 'Y' then
         k  := k + 1;
         upd_task_tbl.extend(1);
         upd_effective_from.extend(1);
         upd_effective_to.extend(1);
         upd_rlmi_tbl.extend(1);
         upd_quantity_tbl.extend(1);
         upd_raw_cost_tbl.extend(1);
         upd_currency_tbl.extend(1);

         upd_task_tbl(k)       := rollup_task_tbl(i);
         upd_effective_from(k) := rollup_effective_from(i);
         upd_effective_to(k)   := rollup_effective_to(i);
         upd_rlmi_tbl(k)       := rollup_rlmi_tbl(i);
         upd_quantity_tbl(k)   := db_quantity_tbl(i);
         upd_raw_cost_tbl(k)   := db_raw_cost_tbl(i);
         upd_currency_tbl(k)   := rollup_currency_tbl(i);
      end if;
    end loop; -- delete loop

    if del_task_tbl.count > 0 then
        delete_planning_transaction(p_api_version     => l_api_version,
                                      p_init_msg_list => FND_API.G_FALSE,
                                      x_return_status => l_return_status,
                                      x_msg_count     => l_msg_count,
                                      x_msg_data      => l_msg_data,
                                      p_bvid          => p_bvid,
                                      p_project_id    => p_project_id,
                                      p_task_tbl      => del_task_tbl,
                                      p_currency_tbl  => del_currency_tbl,
                                      p_rlmi_tbl      => del_rlmi_tbl);

        IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
          RAISE PA_API.G_EXCEPTION_ERROR;
        END IF;

    end if; -- del_task_tbl.count > 0

    if upd_task_tbl.count > 0 then
         update_planning_transaction(p_api_version         => l_api_version,
                                     p_init_msg_list       => p_init_msg_list,
                                     x_return_status       => l_return_status,
                                     x_msg_count           => l_msg_count,
                                     x_msg_data            => l_msg_data,
                                     p_bvid                => p_bvid,
                                     p_project_id          => p_project_id,
                                     p_task_id_tbl         => upd_task_tbl,
                                     p_effective_from_tbl  => upd_effective_from,
                                     p_effective_to_tbl    => upd_effective_to,
                                     p_rlmi_id_tbl         => upd_rlmi_tbl,
                                     p_quantity_tbl        => upd_quantity_tbl,
                                     p_raw_cost_tbl        => upd_raw_cost_tbl,
                                     p_currency_code_tbl   => upd_currency_tbl
                                     );

        IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
          RAISE PA_API.G_EXCEPTION_ERROR;
        END IF;

    end if; -- upd_task_tbl.count > 0
 end if; -- if pa_action_type = 'DELETE'

  k  := 0;
  j  := 0;
  -- for action types of insert/update.
  if p_action_type in ('UPDATE', 'INSERT') then
     if rollup_task_tbl.count > 0 then
       for i in rollup_task_tbl.first..rollup_task_tbl.last loop
         if rollup_ra_exists(i) = 'Y' then
		    upd_task_tbl.extend(1);
		    upd_effective_from.extend(1);
		    upd_effective_to.extend(1);
		    upd_rlmi_tbl.extend(1);
		    upd_quantity_tbl.extend(1);
		    upd_raw_cost_tbl.extend(1);
		    upd_currency_tbl.extend(1);

		   j := j + 1;
		   upd_task_tbl(j)       := rollup_task_tbl(i);
		   upd_effective_from(j) := rollup_effective_from(i);
		   upd_effective_to(j)   := rollup_effective_to(i);
		   upd_rlmi_tbl(j)       := rollup_rlmi_tbl(i);
		   upd_quantity_tbl(j)   := db_quantity_tbl(i);
		   upd_raw_cost_tbl(j)   := db_raw_cost_tbl(i);
		   upd_currency_tbl(j)   := rollup_currency_tbl(i);

         elsif (rollup_ra_exists(i) is null or rollup_ra_exists(i) = 'N') then
		   ins_task_tbl.extend(1);
		   ins_rlmi_tbl.extend(1);
		   ins_quantity_tbl.extend(1);
		   ins_raw_cost_tbl.extend(1);
		   ins_currency_tbl.extend(1);

                   k                     := k + 1;
		   ins_task_tbl(k)       := rollup_task_tbl(i);
		   ins_rlmi_tbl(k)       := rollup_rlmi_tbl(i);
		   ins_quantity_tbl(k)   := db_quantity_tbl(i);
		   ins_raw_cost_tbl(k)   := db_raw_cost_tbl(i);
		   ins_currency_tbl(k)   := rollup_currency_tbl(i);
	     end if;
       end loop;

       if upd_task_tbl.count > 0 then
            update_planning_transaction(p_api_version      => l_api_version,
                                     p_init_msg_list       => p_init_msg_list,
                                     x_return_status       => l_return_status,
                                     x_msg_count           => l_msg_count,
                                     x_msg_data            => l_msg_data,
                                     p_bvid                => p_bvid,
                                     p_project_id          => p_project_id,
                                     p_task_id_tbl         => upd_task_tbl,
				                     p_effective_from_tbl  => upd_effective_from,
				                     p_effective_to_tbl    => upd_effective_to,
				                     p_rlmi_id_tbl         => upd_rlmi_tbl,
				                     p_quantity_tbl        => upd_quantity_tbl,
				                     p_raw_cost_tbl        => upd_raw_cost_tbl,
				                     p_currency_code_tbl   => upd_currency_tbl
                                     );

        IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
          RAISE PA_API.G_EXCEPTION_ERROR;
        END IF;

	   end if;

       if ins_task_tbl.count > 0 then

           insert_planning_transaction(p_api_version       => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => l_return_status,
                                      x_msg_count          => l_msg_count,
                                      x_msg_data           => l_msg_data,
                                      P_BVID               => p_bvid,
                                      P_PROJECT_ID         => p_project_id,
                                      P_TASK_ID_TBL        => ins_task_tbl,
                                      P_RLMI_ID_TBL        => ins_rlmi_tbl,
				                      P_CURRENCY_CODE_TBL  => ins_currency_tbl,
				                      P_QUANTITY_TBL       => ins_quantity_tbl,
				                      P_RAW_COST_TBL       => ins_raw_cost_tbl
				                      );

          IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
            RAISE PA_API.G_EXCEPTION_ERROR;
          END IF;
          end if;

          l_count := 0;

          for i in rollup_task_tbl.first..rollup_task_tbl.last loop
            if (db_quantity_tbl.exists(i) and
                db_quantity_tbl(i) is not null and
                db_quantity_tbl(i) <> FND_API.G_MISS_NUM )then
                   open get_resource_asgn_csr(p_bvid, rollup_task_tbl(i),rollup_rlmi_tbl(i));
                   fetch get_resource_asgn_csr into l_rate_based_res_curr;
                   close get_resource_asgn_csr;

                   l_found := 0;
                   l_count := 0;

                   if l_rate_based_res_curr <> rollup_currency_tbl(i) then
                        for j in p_line_id_tbl.first..p_line_id_tbl.last loop
                             if p_task_id_tbl(j) = rollup_task_tbl(i) and
                                p_rlmi_id_tbl(j) = rollup_rlmi_tbl(i) and
                                p_currency_code_tbl(j) = rollup_currency_tbl(i) and
                                p_currency_code_tbl(j) <> l_rate_based_res_curr and
                                p_quantity_tbl(j) is not null then

                                begin
                                   insert into pa_ci_direct_cost_details(
                                        dc_line_id
                                        ,ci_id
                                        ,project_id
                                        ,task_id
                                        ,expenditure_type
                                        ,resource_list_member_id
                                        ,unit_of_measure
                                        ,currency_code
                                        ,quantity
                                        ,planning_resource_rate
                                        ,raw_cost
                                        ,burdened_cost
                                        ,burden_cost_rate
                                        ,resource_assignment_id
                                        ,effective_from
                                        ,effective_to
                                        ,change_reason_code
                                        ,change_description
                                        ,created_by
                                        ,creation_date
                                        ,last_update_by
                                        ,last_update_date
                                        ,last_update_login)
                                    select pa_ci_dir_cost_details_s.nextval
                                          ,pc.ci_id
                                          ,pc.project_id
                                          ,pc.task_id
                                          ,pc.expenditure_type
                                          ,pc.resource_list_member_id
                                          ,pc.unit_of_measure
                                          ,prc.txn_currency_code
                                          ,pc.quantity
                                          ,prc.txn_average_raw_cost_rate
                                          ,prc.txn_average_raw_cost_rate * pc.quantity
                                          ,prc.txn_average_burden_cost_rate * pc.quantity
                                          ,prc.txn_average_burden_cost_rate
                                          ,prc.resource_assignment_id
                                          ,pra.planning_start_date
                                          ,pra.planning_end_date
                                          ,pc.change_reason_code
                                          ,pc.change_description
                                          ,pc.created_by
                                          ,pc.creation_date
                                          ,pc.last_update_by
                                          ,pc.last_update_date
                                          ,pc.last_update_login
                                      from pa_ci_direct_cost_details pc,
                                           pa_resource_assignments pra,
                                           pa_resource_asgn_curr prc
                                     where pc.ci_id       = p_ci_id
                                       and pc.dc_line_id  = p_line_id_tbl(j)
                                       and pc.resource_assignment_id is null
                                       and pra.task_id     = pc.task_id
                                       and pra.resource_list_member_id = pc.resource_list_member_id
                                       and pra.resource_assignment_id = prc.resource_assignment_id
                                       and prc.txn_currency_code = l_rate_based_res_curr
                                       and pra.budget_version_id = p_bvid;

                                    update pa_ci_direct_cost_details a
                                       set quantity = NULL
                                     where a.ci_id = p_ci_id
                                       and dc_line_id = p_line_id_tbl(j);

                                  exception
                                  when dup_val_on_index then
                                     update pa_ci_direct_cost_details a
                                        set (quantity, raw_cost, burdened_cost) =
                                                       (select sum(quantity) + a.quantity,
                                                              (sum(quantity) + a.quantity) * a.planning_resource_rate,
                                                              (sum(quantity) + a.quantity) * a.burden_cost_rate
                                                          from pa_ci_direct_cost_details b
                                                         where b.ci_id         = p_ci_id
                                                           and b.dc_line_id    = p_line_id_tbl(j))
                                      where a.ci_id = p_ci_id
                                        and currency_code = l_rate_based_res_curr
                                        and task_id = rollup_task_tbl(i)
                                        and resource_list_member_id = rollup_rlmi_tbl(i)
                                        and expenditure_type = (select expenditure_type
                                                                  from pa_ci_direct_cost_details
                                                                 where dc_line_id = p_line_id_tbl(j));

                                    update pa_ci_direct_cost_details a
                                       set quantity = NULL
                                     where a.ci_id = p_ci_id
                                       and dc_line_id = p_line_id_tbl(j);

                                end;

                             end if;
                        end loop;
                      end if;

            end if;
          end loop;

     end if; -- if rollup_task_tbl.count > 0
  end if;  -- if p_action_type

  PA_API.END_ACTIVITY(l_msg_count, l_msg_data);
  x_return_status := PA_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'PA_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := PA_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
end process_planning_lines;

end pa_process_ci_lines_pkg;

/
