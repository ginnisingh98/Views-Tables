--------------------------------------------------------
--  DDL for Package Body PA_ONLINE_COPY_EXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ONLINE_COPY_EXP" AS
/* $Header: PAXTRCPB.pls 120.1 2005/08/17 12:57:03 ramurthy noship $ */

  dummy                  NUMBER;
  org_id                 NUMBER(15);
  G_module               VARCHAR2(30);
  outcome                VARCHAR2(30);
  G_exp_class_code       VARCHAR2(2);
  G_user                 NUMBER;
  G_new_org_id           NUMBER;
  G_copy_exp_type_flag   VARCHAR2(1);
  G_copy_qty_flag        VARCHAR2(1);
  G_copy_cmt_flag        VARCHAR2(1);
  G_copy_dff_flag        VARCHAR2(1);
  G_entered_by_person_id NUMBER;
  G_inc_by_person_id     NUMBER;

  PROCEDURE  ValidateEmp ( X_ei_date          IN DATE
			 , x_job_id           IN OUT NOCOPY NUMBER
                         , X_status           IN OUT NOCOPY VARCHAR2)
  IS
  l_job_id NUMBER;
  l_status VARCHAR2(1000);
  BEGIN
  l_status := x_status; -- store passed in values
  l_job_id := x_job_id;

	X_status := NULL;
    	org_id   := NULL;
    	dummy    := NULL;

    	org_id := pa_utils.GetEmpOrgId ( G_inc_by_person_id, X_ei_date );

    	IF ( org_id IS NULL ) THEN
      		X_status := 'PA_EX_NO_ORG_ASSGN';
      		RETURN;
    	ELSE
		IF G_new_org_id <> org_id THEN
			x_status := 'PA_TR_DIFFERENT_ORG';
			RETURN;
		END IF;
    	END IF;

    	dummy := NULL;
    	dummy := pa_utils.GetEmpJobId ( G_inc_by_person_id, X_ei_date );

        x_job_id := dummy;

    	IF ( dummy IS NULL ) THEN
      		X_status := 'PA_EX_NO_ASSGN';
      		RETURN;
    	END IF;

  -- R12 NOCOPY mandate -- copy back passed in values.
  EXCEPTION WHEN OTHERS THEN
     x_status := l_status;
     x_job_id := l_job_id;
     RAISE;
  END  ValidateEmp;

  PROCEDURE  CopyItems ( X_orig_exp_id      IN NUMBER
                      ,  X_new_exp_id       IN NUMBER
                      ,  X_days_diff        IN NUMBER
		            ,  x_total_exp_copied IN OUT NOCOPY NUMBER)
  IS
       temp_outcome       VARCHAR2(30) DEFAULT NULL;
       temp_status        NUMBER DEFAULT NULL;
       x_outcome          VARCHAR2(30);
       i                  BINARY_INTEGER DEFAULT 0;
       l_dummy            NUMBER; -- used to populate the all null number columns
       l_dummy_date       DATE;   -- used to populate all the null date columns


       CURSOR  getEIdenorm  IS
         SELECT
	        x_new_exp_id expenditure_id,
                pa_ei_denorm_s.nextval denorm_id,
                G_inc_by_person_id person_id,
                project_id,
                task_id,
                billable_flag,
                decode(G_copy_exp_type_flag,'Y',expenditure_type,NULL) expenditure_type,
		decode(G_copy_exp_type_flag,'Y',default_sys_link_func,NULL) default_sys_link_func,
                decode(G_copy_exp_type_flag,'Y',unit_of_measure_code,NULL) unit_of_measure_code,
                decode(G_copy_exp_type_flag,'Y',unit_of_measure,NULL) unit_of_measure,
                l_dummy expenditure_item_id_1,
                decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
				decode(G_copy_qty_flag,'Y',
					trunc(nvl(expenditure_item_date_1,sysdate) + x_days_diff),
						l_dummy_date),l_dummy_date),l_dummy_date) expenditure_item_date_1,
                decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
				decode(G_copy_qty_flag,'Y',quantity_1,
					l_dummy),l_dummy),l_dummy) quantity_1,
		decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',system_linkage_function_1,
					NULL),NULL),NULL) system_linkage_function_1,
                null non_labor_resource_1,
                l_dummy organization_id_1,
                l_dummy override_to_organization_id_1,
                l_dummy raw_cost_1,
                l_dummy raw_cost_rate_1,
		decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute_category_1,
						NULL),NULL),NULL),NULL) attribute_category_1,
                decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute1_1,
						NULL),NULL),NULL),NULL) attribute1_1,
                decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute1_2,
						NULL),NULL),NULL),NULL) attribute1_2,
                decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute1_3,
						NULL),NULL),NULL),NULL) attribute1_3,
                decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute1_4,
						NULL),NULL),NULL),NULL) attribute1_4,
                decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute1_5,
						NULL),NULL),NULL),NULL) attribute1_5,
                decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute1_6,
						NULL),NULL),NULL),NULL) attribute1_6,
                decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute1_7,
						NULL),NULL),NULL),NULL) attribute1_7,
                decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute1_8,
						NULL),NULL),NULL),NULL) attribute1_8,
                decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute1_9,
						NULL),NULL),NULL),NULL) attribute1_9,
                decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute1_10,
						NULL),NULL),NULL),NULL) attribute1_10,
                null orig_transaction_reference_1,
                l_dummy adjusted_expenditure_item_id_1,
                net_zero_adjustment_flag_1,
                decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_cmt_flag,'Y',expenditure_comment_1,
						NULL),NULL),NULL),NULL) expenditure_comment_1,
                l_dummy expenditure_item_id_2,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			trunc(nvl(expenditure_item_date_2, sysdate) + x_days_diff),
						l_dummy_date),l_dummy_date),l_dummy_date) expenditure_item_date_2,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',quantity_2,
					l_dummy),l_dummy),l_dummy) quantity_2,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
                	decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',system_linkage_function_2,
					NULL),NULL),NULL) system_linkage_function_2,
                null non_labor_resource_2,
                l_dummy organization_id_2,
                l_dummy override_to_organization_id_2,
                l_dummy raw_cost_2,
                l_dummy raw_cost_rate_2,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute_category_2,
						NULL),NULL),NULL),NULL) attribute_category_2,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute2_1,
						NULL),NULL),NULL),NULL) attribute2_1,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute2_2,
                                        	NULL),NULL),NULL),NULL) attribute2_2,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute2_3,
                                        	NULL),NULL),NULL),NULL) attribute2_3,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute2_4,
                                        	NULL),NULL),NULL),NULL) attribute2_4,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute2_5,
                                        	NULL),NULL),NULL),NULL) attribute2_5,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute2_6,
                                        	NULL),NULL),NULL),NULL) attribute2_6,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute2_7,
                                        	NULL),NULL),NULL),NULL) attribute2_7,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute2_8,
                                        	NULL),NULL),NULL),NULL) attribute2_8,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute2_9,
                                        	NULL),NULL),NULL),NULL) attribute2_9,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute2_10,
                                        	NULL),NULL),NULL),NULL) attribute2_10,
                null orig_transaction_reference_2,
                l_dummy adjusted_expenditure_item_id_2,
                net_zero_adjustment_flag_2,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
			decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			decode(G_copy_cmt_flag,'Y',expenditure_comment_2,
						NULL),NULL),NULL),NULL) expenditure_comment_2,
                l_dummy expenditure_item_id_3,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',
                			trunc(nvl(expenditure_item_date_3,sysdate) + x_days_diff),
						l_dummy_date),l_dummy_date),l_dummy_date) expenditure_item_date_3,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                        	decode(G_copy_qty_flag,'Y',quantity_3,
					l_dummy),l_dummy),l_dummy) quantity_3,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                	decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y', system_linkage_function_3,
					NULL),NULL),NULL) system_linkage_function_3,
                non_labor_resource_3,
                l_dummy organization_id_3,
                l_dummy override_to_organization_id_3,
                l_dummy raw_cost_3,
                l_dummy raw_cost_rate_3,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute_category_3,
						NULL),NULL),NULL),NULL) attribute_category_3,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute3_1,
						NULL),NULL),NULL),NULL) attribute3_1,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute3_2,
						NULL),NULL),NULL),NULL) attribute3_2,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute3_3,
						NULL),NULL),NULL),NULL) attribute3_3,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute3_4,
						NULL),NULL),NULL),NULL) attribute3_4,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute3_5,
						NULL),NULL),NULL),NULL) attribute3_5,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute3_6,
						NULL),NULL),NULL),NULL) attribute3_6,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute3_7,
						NULL),NULL),NULL),NULL) attribute3_7,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute3_8,
						NULL),NULL),NULL),NULL) attribute3_8,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute3_9,
						NULL),NULL),NULL),NULL) attribute3_9,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute3_10,
						NULL),NULL),NULL),NULL) attribute3_10,
                null orig_transaction_reference_3,
                l_dummy adjusted_expenditure_item_id_3,
                net_zero_adjustment_flag_3,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_cmt_flag,'Y',expenditure_comment_3,
						NULL),NULL),NULL),NULL) expenditure_comment_3,
                l_dummy expenditure_item_id_4,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			trunc(nvl(expenditure_item_date_4,sysdate) + x_days_diff),
						l_dummy_date),l_dummy_date),l_dummy_date) expenditure_item_date_4,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',quantity_4,
					l_dummy),l_dummy),l_dummy) quantity_4,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',system_linkage_function_4,
					NULL),NULL),NULL) system_linkage_function_4,
                null non_labor_resource_4,
                l_dummy organization_id_4,
                l_dummy override_to_organization_id_4,
                l_dummy raw_cost_4,
                l_dummy raw_cost_rate_4,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute_category_4,
						NULL),NULL),NULL),NULL) attribute_category_4,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute4_1,
						NULL),NULL),NULL),NULL) attribute4_1,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute4_2,
						NULL),NULL),NULL),NULL) attribute4_2,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute4_3,
						NULL),NULL),NULL),NULL) attribute4_3,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute4_4,
						NULL),NULL),NULL),NULL) attribute4_4,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute4_5,
						NULL),NULL),NULL),NULL) attribute4_5,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute4_6,
						NULL),NULL),NULL),NULL) attribute4_6,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute4_7,
						NULL),NULL),NULL),NULL) attribute4_7,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute4_8,
						NULL),NULL),NULL),NULL) attribute4_8,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute4_9,
						NULL),NULL),NULL),NULL) attribute4_9,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute4_10,
						NULL),NULL),NULL),NULL) attribute4_10,
                null orig_transaction_reference_4,
                l_dummy adjusted_expenditure_item_id_4,
                null net_zero_adjustment_flag_4,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_cmt_flag,'Y',expenditure_comment_4,
						NULL),NULL),NULL),NULL) expenditure_comment_4,
                l_dummy expenditure_item_id_5,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			trunc(nvl(expenditure_item_date_5,sysdate) + x_days_diff),
						l_dummy_date),l_dummy_date),l_dummy_date) expenditure_item_date_5,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',quantity_5,
					l_dummy),l_dummy),l_dummy) quantity_5,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',system_linkage_function_5,
					NULL),NULL),NULL) system_linkage_function_5,
                null non_labor_resource_5,
                l_dummy organization_id_5,
                l_dummy override_to_organization_id_5,
                l_dummy raw_cost_5,
                l_dummy raw_cost_rate_5,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute_category_5,
						NULL),NULL),NULL),NULL) attribute_category_5,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute5_1,
						NULL),NULL),NULL),NULL) attribute5_1,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
					decode(G_copy_dff_flag,'Y',attribute5_2,
						NULL),NULL),NULL),NULL) attribute5_2,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute5_3,
						NULL),NULL),NULL),NULL) attribute5_3,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute5_4,
						NULL),NULL),NULL),NULL) attribute5_4,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute5_5,
						NULL),NULL),NULL),NULL) attribute5_5,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute5_6,
						NULL),NULL),NULL),NULL) attribute5_6,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute5_7,
						NULL),NULL),NULL),NULL) attribute5_7,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute5_8,
						NULL),NULL),NULL),NULL) attribute5_8,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute5_9,
						NULL),NULL),NULL),NULL) attribute5_9,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute5_10,
						NULL),NULL),NULL),NULL) attribute5_10,
                null orig_transaction_reference_5,
                l_dummy adjusted_expenditure_item_id_5,
                net_zero_adjustment_flag_5,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_cmt_flag,'Y',expenditure_comment_5,
						NULL),NULL),NULL),NULL) expenditure_comment_5,
                l_dummy expenditure_item_id_6,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			trunc(nvl(expenditure_item_date_6,sysdate) + x_days_diff),
						l_dummy_date),l_dummy_date),l_dummy_date) expenditure_item_date_6,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',quantity_6,
					l_dummy),l_dummy),l_dummy) quantity_6,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',system_linkage_function_6,
					NULL),NULL),NULL) system_linkage_function_6,
                null non_labor_resource_6,
                l_dummy organization_id_6,
                l_dummy override_to_organization_id_6,
                l_dummy raw_cost_6,
                l_dummy raw_cost_rate_6,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute_category_6,
						NULL),NULL),NULL),NULL) attribute_category_6,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
					decode(G_copy_dff_flag,'Y',attribute6_1,
						NULL),NULL),NULL),NULL) attribute6_1,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute6_2,
						NULL),NULL),NULL),NULL) attribute6_2,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute6_3,
						NULL),NULL),NULL),NULL) attribute6_3,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute6_4,
						NULL),NULL),NULL),NULL) attribute6_4,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute6_5,
						NULL),NULL),NULL),NULL) attribute6_5,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute6_6,
						NULL),NULL),NULL),NULL) attribute6_6,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute6_7,
						NULL),NULL),NULL),NULL) attribute6_7,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute6_8,
						NULL),NULL),NULL),NULL) attribute6_8,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute6_9,
						NULL),NULL),NULL),NULL) attribute6_9,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute6_10,
						NULL),NULL),NULL),NULL) attribute6_10,
                null orig_transaction_reference_6,
                l_dummy adjusted_expenditure_item_id_6,
                net_zero_adjustment_flag_6,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_cmt_flag,'Y',expenditure_comment_6,
						NULL),NULL),NULL),NULL) expenditure_comment_6,
                l_dummy expenditure_item_id_7,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			trunc(nvl(expenditure_item_date_7,sysdate) + x_days_diff),
						l_dummy_date),l_dummy_date),l_dummy_date) expenditure_item_date_7,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',quantity_7,
					l_dummy),l_dummy),l_dummy) quantity_7,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',system_linkage_function_7,
					NULL),NULL),NULL) system_linkage_function_7,
                null non_labor_resource_7,
                l_dummy organization_id_7,
                l_dummy override_to_organization_id_7,
                l_dummy raw_cost_7,
                l_dummy raw_cost_rate_7,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute_category_7,
						NULL),NULL),NULL),NULL) attribute_category_7,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute7_1,
						NULL),NULL),NULL),NULL) attribute7_1,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute7_2,
						NULL),NULL),NULL),NULL) attribute7_2,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute7_3,
						NULL),NULL),NULL),NULL) attribute7_3,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute7_4,
						NULL),NULL),NULL),NULL) attribute7_4,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute7_5,
						NULL),NULL),NULL),NULL) attribute7_5,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute7_6,
						NULL),NULL),NULL),NULL) attribute7_6,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute7_7,
						NULL),NULL),NULL),NULL) attribute7_7,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute7_8,
						NULL),NULL),NULL),NULL) attribute7_8,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute7_9,
						NULL),NULL),NULL),NULL) attribute7_9,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_dff_flag,'Y',attribute7_10,
						NULL),NULL),NULL),NULL) attribute7_10,
                null orig_transaction_reference_7,
                l_dummy adjusted_expenditure_item_id_7,
                net_zero_adjustment_flag_7,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',
                			decode(G_copy_cmt_flag,'Y',expenditure_comment_7,
						NULL),NULL),NULL),NULL) expenditure_comment_7,
                0 denorm_total_qty,
                0 denorm_total_amount,
                G_user created_by,
                trunc(sysdate) creation_date,
                trunc(sysdate) last_update_date,
                G_user last_updated_by,
                FND_PROFILE.VALUE('LOGIN_ID') last_update_login,
                decode(nvl(net_zero_adjustment_flag_1,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',job_id_1,
                                                l_dummy),l_dummy),l_dummy) job_id_1,
                decode(nvl(net_zero_adjustment_flag_2,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',job_id_2,
                                                l_dummy),l_dummy),l_dummy) job_id_2,
                decode(nvl(net_zero_adjustment_flag_3,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',job_id_3,
                                                l_dummy),l_dummy),l_dummy) job_id_3,
                decode(nvl(net_zero_adjustment_flag_4,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',job_id_4,
                                                l_dummy),l_dummy),l_dummy) job_id_4,
                decode(nvl(net_zero_adjustment_flag_5,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',job_id_5,
                                                l_dummy),l_dummy),l_dummy) job_id_5,
                decode(nvl(net_zero_adjustment_flag_6,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',job_id_6,
                                                l_dummy),l_dummy),l_dummy) job_id_6,
                decode(nvl(net_zero_adjustment_flag_7,'N'),'N',
                        decode(G_copy_exp_type_flag,'Y',
                                decode(G_copy_qty_flag,'Y',job_id_7,
                                                l_dummy),l_dummy),l_dummy) job_id_7
	  FROM
                pa_ei_denorm
          WHERE expenditure_id = x_orig_exp_id;

          ei_denorm              getEIdenorm%ROWTYPE;

  BEGIN
        OPEN getEIdenorm;
	   x_total_exp_copied := 0;
        LOOP

                FETCH getEIdenorm INTO ei_denorm;
                EXIT WHEN getEIdenorm%NOTFOUND;

		IF ei_denorm.quantity_1 IS NOT NULL THEN
                        PA_ONLINE_COPY_EXP.validate_item(ei_denorm.project_id,
                                                         ei_denorm.task_id,
                                                         ei_denorm.expenditure_item_date_1,
                                                         ei_denorm.expenditure_type,
							 ei_denorm.system_linkage_function_1,
                                                         ei_denorm.quantity_1,
                                                         ei_denorm.attribute_category_1,
                                                         ei_denorm.attribute1_1,
                                                         ei_denorm.attribute1_2,
                                                         ei_denorm.attribute1_3,
                                                         ei_denorm.attribute1_4,
                                                         ei_denorm.attribute1_5,
                                                         ei_denorm.attribute1_6,
                                                         ei_denorm.attribute1_7,
                                                         ei_denorm.attribute1_8,
                                                         ei_denorm.attribute1_9,
                                                         ei_denorm.attribute1_10,
							 ei_denorm.billable_flag,
							 ei_denorm.job_id_1,
                                                         x_outcome);
			IF x_outcome IS NOT NULL THEN
				ei_denorm.quantity_1 := NULL;
				ei_denorm.expenditure_item_date_1 := NULL;
				ei_denorm.system_linkage_function_1 := NULL;
				ei_denorm.attribute_category_1 := NULL;
				ei_denorm.attribute1_1 := NULL;
                                ei_denorm.attribute1_2 := NULL;
                                ei_denorm.attribute1_3 := NULL;
                                ei_denorm.attribute1_4 := NULL;
                                ei_denorm.attribute1_5 := NULL;
                                ei_denorm.attribute1_6 := NULL;
                                ei_denorm.attribute1_7 := NULL;
                                ei_denorm.attribute1_8 := NULL;
                                ei_denorm.attribute1_9 := NULL;
                                ei_denorm.attribute1_10 := NULL;
				ei_denorm.expenditure_comment_1 := NULL;
                                ei_denorm.job_id_1 := NULL;
			ELSE
      				IF ( G_exp_class_code = 'OE' ) THEN
        				ei_denorm.raw_cost_rate_1 := pa_utils.GetExpTypeCostRate( ei_denorm.expenditure_type
                                      					   			, ei_denorm.expenditure_item_date_1 );
        				ei_denorm.raw_cost_1 := PA_CURRENCY.ROUND_CURRENCY_AMT(
								( ei_denorm.quantity_1 * ei_denorm.raw_cost_rate_1 ) );
				ELSE
					ei_denorm.raw_cost_rate_1 := null;
					ei_denorm.raw_cost_1 := null;
      				END IF;
			END IF;

          ELSE
          	ei_denorm.quantity_1 := NULL;
		ei_denorm.expenditure_item_date_1 := NULL;
		ei_denorm.system_linkage_function_1 := NULL;
		ei_denorm.attribute_category_1 := NULL;
		ei_denorm.attribute1_1 := NULL;
                ei_denorm.attribute1_2 := NULL;
                ei_denorm.attribute1_3 := NULL;
                ei_denorm.attribute1_4 := NULL;
                ei_denorm.attribute1_5 := NULL;
                ei_denorm.attribute1_6 := NULL;
                ei_denorm.attribute1_7 := NULL;
                ei_denorm.attribute1_8 := NULL;
                ei_denorm.attribute1_9 := NULL;
                ei_denorm.attribute1_10 := NULL;
	        ei_denorm.expenditure_comment_1 := NULL;
                ei_denorm.job_id_1 := NULL;

	  END IF;

	  IF ei_denorm.quantity_2 IS NOT NULL THEN
                        PA_ONLINE_COPY_EXP.validate_item(ei_denorm.project_id,
                                                         ei_denorm.task_id,
                                                         ei_denorm.expenditure_item_date_2,
                                                         ei_denorm.expenditure_type,
							 ei_denorm.system_linkage_function_2,
                                                         ei_denorm.quantity_2,
                                                         ei_denorm.attribute_category_2,
                                                         ei_denorm.attribute2_1,
                                                         ei_denorm.attribute2_2,
                                                         ei_denorm.attribute2_3,
                                                         ei_denorm.attribute2_4,
                                                         ei_denorm.attribute2_5,
                                                         ei_denorm.attribute2_6,
                                                         ei_denorm.attribute2_7,
                                                         ei_denorm.attribute2_8,
                                                         ei_denorm.attribute2_9,
                                                         ei_denorm.attribute2_10,
							 ei_denorm.billable_flag,
                                                         ei_denorm.job_id_2,
                                                         x_outcome);

                        IF x_outcome IS NOT NULL THEN
                                ei_denorm.quantity_2 := NULL;
                                ei_denorm.expenditure_item_date_2 := NULL;
                                ei_denorm.system_linkage_function_2 := NULL;
                                ei_denorm.attribute_category_2 := NULL;
                                ei_denorm.attribute2_1 := NULL;
                                ei_denorm.attribute2_2 := NULL;
                                ei_denorm.attribute2_3 := NULL;
                                ei_denorm.attribute2_4 := NULL;
                                ei_denorm.attribute2_5 := NULL;
                                ei_denorm.attribute2_6 := NULL;
                                ei_denorm.attribute2_7 := NULL;
                                ei_denorm.attribute2_8 := NULL;
                                ei_denorm.attribute2_9 := NULL;
                                ei_denorm.attribute2_10 := NULL;
                                ei_denorm.expenditure_comment_2 := NULL;
                                ei_denorm.job_id_2 := NULL;
                        ELSE
                                IF ( G_exp_class_code = 'OE' ) THEN
                                        ei_denorm.raw_cost_rate_2 := pa_utils.GetExpTypeCostRate( ei_denorm.expenditure_type
                                                                           			, ei_denorm.expenditure_item_date_2 );
                                        ei_denorm.raw_cost_2 := PA_CURRENCY.ROUND_CURRENCY_AMT(
                                                                ( ei_denorm.quantity_2 * ei_denorm.raw_cost_rate_2 ) );
                                ELSE
                                        ei_denorm.raw_cost_rate_2 := null;
                                        ei_denorm.raw_cost_2 := null;
                                END IF;
                        END IF;
          ELSE
          	ei_denorm.quantity_2 := NULL;
		ei_denorm.expenditure_item_date_2 := NULL;
		ei_denorm.system_linkage_function_2 := NULL;
		ei_denorm.attribute_category_2 := NULL;
		ei_denorm.attribute2_1 := NULL;
                ei_denorm.attribute2_2 := NULL;
                ei_denorm.attribute2_3 := NULL;
                ei_denorm.attribute2_4 := NULL;
                ei_denorm.attribute2_5 := NULL;
                ei_denorm.attribute2_6 := NULL;
                ei_denorm.attribute2_7 := NULL;
                ei_denorm.attribute2_8 := NULL;
                ei_denorm.attribute2_9 := NULL;
                ei_denorm.attribute2_10 := NULL;
		ei_denorm.expenditure_comment_2 := NULL;
                ei_denorm.job_id_2 := NULL;
	  END IF;

          IF ei_denorm.quantity_3 IS NOT NULL THEN
                        PA_ONLINE_COPY_EXP.validate_item(ei_denorm.project_id,
                                                         ei_denorm.task_id,
                                                         ei_denorm.expenditure_item_date_3,
                                                         ei_denorm.expenditure_type,
							 ei_denorm.system_linkage_function_3,
                                                         ei_denorm.quantity_3,
                                                         ei_denorm.attribute_category_3,
                                                         ei_denorm.attribute3_1,
                                                         ei_denorm.attribute3_2,
                                                         ei_denorm.attribute3_3,
                                                         ei_denorm.attribute3_4,
                                                         ei_denorm.attribute3_5,
                                                         ei_denorm.attribute3_6,
                                                         ei_denorm.attribute3_7,
                                                         ei_denorm.attribute3_8,
                                                         ei_denorm.attribute3_9,
                                                         ei_denorm.attribute3_10,
							 ei_denorm.billable_flag,
                                                         ei_denorm.job_id_3,
                                                         x_outcome);

                        IF x_outcome IS NOT NULL THEN
                                ei_denorm.quantity_3 := NULL;
                                ei_denorm.expenditure_item_date_3 := NULL;
                                ei_denorm.system_linkage_function_3 := NULL;
                                ei_denorm.attribute_category_3 := NULL;
                                ei_denorm.attribute3_1 := NULL;
                                ei_denorm.attribute3_2 := NULL;
                                ei_denorm.attribute3_3 := NULL;
                                ei_denorm.attribute3_4 := NULL;
                                ei_denorm.attribute3_5 := NULL;
                                ei_denorm.attribute3_6 := NULL;
                                ei_denorm.attribute3_7 := NULL;
                                ei_denorm.attribute3_8 := NULL;
                                ei_denorm.attribute3_9 := NULL;
                                ei_denorm.attribute3_10 := NULL;
                                ei_denorm.expenditure_comment_3 := NULL;
                                ei_denorm.job_id_3 := NULL;
                        ELSE
                                IF ( G_exp_class_code = 'OE' ) THEN
                                        ei_denorm.raw_cost_rate_3 := pa_utils.GetExpTypeCostRate( ei_denorm.expenditure_type
                                                                           			, ei_denorm.expenditure_item_date_3 );
                                        ei_denorm.raw_cost_3 := PA_CURRENCY.ROUND_CURRENCY_AMT(
                                                                ( ei_denorm.quantity_3 * ei_denorm.raw_cost_rate_3 ) );
                                ELSE
                                        ei_denorm.raw_cost_rate_3 := null;
                                        ei_denorm.raw_cost_3 := null;
                                END IF;
                        END IF;
                ELSE
          		ei_denorm.quantity_3 := NULL;
			ei_denorm.expenditure_item_date_3 := NULL;
			ei_denorm.system_linkage_function_3 := NULL;
			ei_denorm.attribute_category_3 := NULL;
			ei_denorm.attribute3_1 := NULL;
                        ei_denorm.attribute3_2 := NULL;
                        ei_denorm.attribute3_3 := NULL;
                        ei_denorm.attribute3_4 := NULL;
                        ei_denorm.attribute3_5 := NULL;
                        ei_denorm.attribute3_6 := NULL;
                        ei_denorm.attribute3_7 := NULL;
                        ei_denorm.attribute3_8 := NULL;
                        ei_denorm.attribute3_9 := NULL;
                        ei_denorm.attribute3_10 := NULL;
			ei_denorm.expenditure_comment_3 := NULL;
                        ei_denorm.job_id_3 := NULL;
                END IF;

                IF ei_denorm.quantity_4 IS NOT NULL THEN

                        PA_ONLINE_COPY_EXP.validate_item(ei_denorm.project_id,
                                                         ei_denorm.task_id,
                                                         ei_denorm.expenditure_item_date_4,
                                                         ei_denorm.expenditure_type,
							 ei_denorm.system_linkage_function_4,
                                                         ei_denorm.quantity_4,
                                                         ei_denorm.attribute_category_4,
                                                         ei_denorm.attribute4_1,
                                                         ei_denorm.attribute4_2,
                                                         ei_denorm.attribute4_3,
                                                         ei_denorm.attribute4_4,
                                                         ei_denorm.attribute4_5,
                                                         ei_denorm.attribute4_6,
                                                         ei_denorm.attribute4_7,
                                                         ei_denorm.attribute4_8,
                                                         ei_denorm.attribute4_9,
                                                         ei_denorm.attribute4_10,
							 ei_denorm.billable_flag,
                                                         ei_denorm.job_id_4,
                                                         x_outcome);

                        IF x_outcome IS NOT NULL THEN
                                ei_denorm.quantity_4 := NULL;
                                ei_denorm.expenditure_item_date_4 := NULL;
                                ei_denorm.system_linkage_function_4 := NULL;
                                ei_denorm.attribute_category_4 := NULL;
                                ei_denorm.attribute4_1 := NULL;
                                ei_denorm.attribute4_2 := NULL;
                                ei_denorm.attribute4_3 := NULL;
                                ei_denorm.attribute4_4 := NULL;
                                ei_denorm.attribute4_5 := NULL;
                                ei_denorm.attribute4_6 := NULL;
                                ei_denorm.attribute4_7 := NULL;
                                ei_denorm.attribute4_8 := NULL;
                                ei_denorm.attribute4_9 := NULL;
                                ei_denorm.attribute4_10 := NULL;
                                ei_denorm.expenditure_comment_4 := NULL;
                                ei_denorm.job_id_4 := NULL;
                        ELSE
                                IF ( G_exp_class_code = 'OE' ) THEN
                                        ei_denorm.raw_cost_rate_4 := pa_utils.GetExpTypeCostRate( ei_denorm.expenditure_type
                                                                           			, ei_denorm.expenditure_item_date_4 );
                                        ei_denorm.raw_cost_4 := PA_CURRENCY.ROUND_CURRENCY_AMT(
                                                                ( ei_denorm.quantity_4 * ei_denorm.raw_cost_rate_4 ) );
                                ELSE
                                        ei_denorm.raw_cost_rate_4 := null;
                                        ei_denorm.raw_cost_4 := null;
                                END IF;
                        END IF;
                ELSE
          		ei_denorm.quantity_4 := NULL;
			ei_denorm.expenditure_item_date_4 := NULL;
			ei_denorm.system_linkage_function_4 := NULL;
			ei_denorm.attribute_category_4 := NULL;
			ei_denorm.attribute4_1 := NULL;
                        ei_denorm.attribute4_2 := NULL;
                        ei_denorm.attribute4_3 := NULL;
                        ei_denorm.attribute4_4 := NULL;
                        ei_denorm.attribute4_5 := NULL;
                        ei_denorm.attribute4_6 := NULL;
                        ei_denorm.attribute4_7 := NULL;
                        ei_denorm.attribute4_8 := NULL;
                        ei_denorm.attribute4_9 := NULL;
                        ei_denorm.attribute4_10 := NULL;
			ei_denorm.expenditure_comment_4 := NULL;
                        ei_denorm.job_id_4 := NULL;
                END IF;

                IF ei_denorm.quantity_5 IS NOT NULL THEN

                        PA_ONLINE_COPY_EXP.validate_item(ei_denorm.project_id,
                                                         ei_denorm.task_id,
                                                         ei_denorm.expenditure_item_date_5,
                                                         ei_denorm.expenditure_type,
							 ei_denorm.system_linkage_function_5,
                                                         ei_denorm.quantity_5,
                                                         ei_denorm.attribute_category_5,
                                                         ei_denorm.attribute5_1,
                                                         ei_denorm.attribute5_2,
                                                         ei_denorm.attribute5_3,
                                                         ei_denorm.attribute5_4,
                                                         ei_denorm.attribute5_5,
                                                         ei_denorm.attribute5_6,
                                                         ei_denorm.attribute5_7,
                                                         ei_denorm.attribute5_8,
                                                         ei_denorm.attribute5_9,
                                                         ei_denorm.attribute5_10,
							 ei_denorm.billable_flag,
                                                         ei_denorm.job_id_5,
                                                         x_outcome);

                        IF x_outcome IS NOT NULL THEN
                                ei_denorm.quantity_5 := NULL;
                                ei_denorm.expenditure_item_date_5 := NULL;
                                ei_denorm.system_linkage_function_5 := NULL;
                                ei_denorm.attribute_category_5 := NULL;
                                ei_denorm.attribute5_1 := NULL;
                                ei_denorm.attribute5_2 := NULL;
                                ei_denorm.attribute5_3 := NULL;
                                ei_denorm.attribute5_4 := NULL;
                                ei_denorm.attribute5_5 := NULL;
                                ei_denorm.attribute5_6 := NULL;
                                ei_denorm.attribute5_7 := NULL;
                                ei_denorm.attribute5_8 := NULL;
                                ei_denorm.attribute5_9 := NULL;
                                ei_denorm.attribute5_10 := NULL;
                                ei_denorm.expenditure_comment_5 := NULL;
                                ei_denorm.job_id_5 := NULL;
                        ELSE
                                IF ( G_exp_class_code = 'OE' ) THEN
                                        ei_denorm.raw_cost_rate_5 := pa_utils.GetExpTypeCostRate( ei_denorm.expenditure_type
                                                                           			, ei_denorm.expenditure_item_date_5 );
                                        ei_denorm.raw_cost_5 := PA_CURRENCY.ROUND_CURRENCY_AMT(
                                                                ( ei_denorm.quantity_5 * ei_denorm.raw_cost_rate_5 ) );
                                ELSE
                                        ei_denorm.raw_cost_rate_5 := null;
                                        ei_denorm.raw_cost_5 := null;
                                END IF;
                        END IF;
                ELSE
          		ei_denorm.quantity_5 := NULL;
			ei_denorm.expenditure_item_date_5 := NULL;
			ei_denorm.system_linkage_function_5 := NULL;
			ei_denorm.attribute_category_5 := NULL;
			ei_denorm.attribute5_1 := NULL;
                        ei_denorm.attribute5_2 := NULL;
                        ei_denorm.attribute5_3 := NULL;
                        ei_denorm.attribute5_4 := NULL;
                        ei_denorm.attribute5_5 := NULL;
                        ei_denorm.attribute5_6 := NULL;
                        ei_denorm.attribute5_7 := NULL;
                        ei_denorm.attribute5_8 := NULL;
                        ei_denorm.attribute5_9 := NULL;
                        ei_denorm.attribute5_10 := NULL;
			ei_denorm.expenditure_comment_5 := NULL;
                        ei_denorm.job_id_5 := NULL;
                END IF;

                IF ei_denorm.quantity_6 IS NOT NULL THEN

                        PA_ONLINE_COPY_EXP.validate_item(ei_denorm.project_id,
                                                         ei_denorm.task_id,
                                                         ei_denorm.expenditure_item_date_6,
                                                         ei_denorm.expenditure_type,
							 ei_denorm.system_linkage_function_6,
                                                         ei_denorm.quantity_6,
                                                         ei_denorm.attribute_category_6,
                                                         ei_denorm.attribute6_1,
                                                         ei_denorm.attribute6_2,
                                                         ei_denorm.attribute6_3,
                                                         ei_denorm.attribute6_4,
                                                         ei_denorm.attribute6_5,
                                                         ei_denorm.attribute6_6,
                                                         ei_denorm.attribute6_7,
                                                         ei_denorm.attribute6_8,
                                                         ei_denorm.attribute6_9,
                                                         ei_denorm.attribute6_10,
							 ei_denorm.billable_flag,
                                                         ei_denorm.job_id_6,
                                                         x_outcome);

                        IF x_outcome IS NOT NULL THEN
                                ei_denorm.quantity_6 := NULL;
                                ei_denorm.expenditure_item_date_6 := NULL;
                                ei_denorm.system_linkage_function_6 := NULL;
                                ei_denorm.attribute_category_6 := NULL;
                                ei_denorm.attribute6_1 := NULL;
                                ei_denorm.attribute6_2 := NULL;
                                ei_denorm.attribute6_3 := NULL;
                                ei_denorm.attribute6_4 := NULL;
                                ei_denorm.attribute6_5 := NULL;
                                ei_denorm.attribute6_6 := NULL;
                                ei_denorm.attribute6_7 := NULL;
                                ei_denorm.attribute6_8 := NULL;
                                ei_denorm.attribute6_9 := NULL;
                                ei_denorm.attribute6_10 := NULL;
                                ei_denorm.expenditure_comment_6 := NULL;
                                ei_denorm.job_id_6 := NULL;
                        ELSE
                                IF ( G_exp_class_code = 'OE' ) THEN
                                        ei_denorm.raw_cost_rate_6 := pa_utils.GetExpTypeCostRate( ei_denorm.expenditure_type
                                                                           			, ei_denorm.expenditure_item_date_6 );
                                        ei_denorm.raw_cost_6 := PA_CURRENCY.ROUND_CURRENCY_AMT(
                                                                ( ei_denorm.quantity_6 * ei_denorm.raw_cost_rate_6 ) );
                                ELSE
                                        ei_denorm.raw_cost_rate_6 := null;
                                        ei_denorm.raw_cost_6 := null;
                                END IF;
                        END IF;
                ELSE
          		ei_denorm.quantity_6 := NULL;
			ei_denorm.expenditure_item_date_6 := NULL;
			ei_denorm.system_linkage_function_6 := NULL;
			ei_denorm.attribute_category_6 := NULL;
			ei_denorm.attribute6_1 := NULL;
                        ei_denorm.attribute6_2 := NULL;
                        ei_denorm.attribute6_3 := NULL;
                        ei_denorm.attribute6_4 := NULL;
                        ei_denorm.attribute6_5 := NULL;
                        ei_denorm.attribute6_6 := NULL;
                        ei_denorm.attribute6_7 := NULL;
                        ei_denorm.attribute6_8 := NULL;
                        ei_denorm.attribute6_9 := NULL;
                        ei_denorm.attribute6_10 := NULL;
			ei_denorm.expenditure_comment_6 := NULL;
                        ei_denorm.job_id_6 := NULL;
                END IF;

                IF ei_denorm.quantity_7 IS NOT NULL THEN

                        PA_ONLINE_COPY_EXP.validate_item(ei_denorm.project_id,
							 ei_denorm.task_id,
                                                         ei_denorm.expenditure_item_date_7,
                                                         ei_denorm.expenditure_type,
							 ei_denorm.system_linkage_function_7,
							 ei_denorm.quantity_7,
							 ei_denorm.attribute_category_7,
							 ei_denorm.attribute7_1,
                                                         ei_denorm.attribute7_2,
                                                         ei_denorm.attribute7_3,
                                                         ei_denorm.attribute7_4,
                                                         ei_denorm.attribute7_5,
                                                         ei_denorm.attribute7_6,
                                                         ei_denorm.attribute7_7,
                                                         ei_denorm.attribute7_8,
                                                         ei_denorm.attribute7_9,
                                                         ei_denorm.attribute7_10,
							 ei_denorm.billable_flag,
                                                         ei_denorm.job_id_7,
                                                         x_outcome);

                        IF x_outcome IS NOT NULL THEN
                                ei_denorm.quantity_7 := NULL;
                                ei_denorm.expenditure_item_date_7 := NULL;
                                ei_denorm.system_linkage_function_7 := NULL;
                                ei_denorm.attribute_category_7 := NULL;
                                ei_denorm.attribute7_1 := NULL;
                                ei_denorm.attribute7_2 := NULL;
                                ei_denorm.attribute7_3 := NULL;
                                ei_denorm.attribute7_4 := NULL;
                                ei_denorm.attribute7_5 := NULL;
                                ei_denorm.attribute7_6 := NULL;
                                ei_denorm.attribute7_7 := NULL;
                                ei_denorm.attribute7_8 := NULL;
                                ei_denorm.attribute7_9 := NULL;
                                ei_denorm.attribute7_10 := NULL;
                                ei_denorm.expenditure_comment_7 := NULL;
				ei_denorm.job_id_7 := NULL;
                        ELSE
                                IF ( G_exp_class_code = 'OE' ) THEN
                                        ei_denorm.raw_cost_rate_7 := pa_utils.GetExpTypeCostRate( ei_denorm.expenditure_type
                                                                           			, ei_denorm.expenditure_item_date_7 );
                                        ei_denorm.raw_cost_7 := PA_CURRENCY.ROUND_CURRENCY_AMT(
                                                                ( ei_denorm.quantity_7 * ei_denorm.raw_cost_rate_7 ) );
                                ELSE
                                        ei_denorm.raw_cost_rate_7 := null;
                                        ei_denorm.raw_cost_7 := null;
                                END IF;
                        END IF;
                ELSE
          		ei_denorm.quantity_7 := NULL;
			ei_denorm.expenditure_item_date_7 := NULL;
			ei_denorm.system_linkage_function_7 := NULL;
			ei_denorm.attribute_category_7 := NULL;
			ei_denorm.attribute7_1 := NULL;
                        ei_denorm.attribute7_2 := NULL;
                        ei_denorm.attribute7_3 := NULL;
                        ei_denorm.attribute7_4 := NULL;
                        ei_denorm.attribute7_5 := NULL;
                        ei_denorm.attribute7_6 := NULL;
                        ei_denorm.attribute7_7 := NULL;
                        ei_denorm.attribute7_8 := NULL;
                        ei_denorm.attribute7_9 := NULL;
                        ei_denorm.attribute7_10 := NULL;
			ei_denorm.expenditure_comment_7 := NULL;
                        ei_denorm.job_id_7 := NULL;
                END IF;

                ei_denorm.net_zero_adjustment_flag_1 := NULL;
                ei_denorm.net_zero_adjustment_flag_2 := NULL;
                ei_denorm.net_zero_adjustment_flag_3 := NULL;
                ei_denorm.net_zero_adjustment_flag_4 := NULL;
                ei_denorm.net_zero_adjustment_flag_5 := NULL;
                ei_denorm.net_zero_adjustment_flag_6 := NULL;
                ei_denorm.net_zero_adjustment_flag_7 := NULL;
		ei_denorm.denorm_total_qty := nvl(ei_denorm.quantity_1,0) + nvl(ei_denorm.quantity_2,0) +
			                      nvl(ei_denorm.quantity_3,0) + nvl(ei_denorm.quantity_4,0) +
					      nvl(ei_denorm.quantity_5,0) + nvl(ei_denorm.quantity_6,0) +
					      nvl(ei_denorm.quantity_7,0);
		IF G_exp_class_code = 'OE' THEN
			ei_denorm.denorm_total_amount := nvl(ei_denorm.raw_cost_1,0) + nvl(ei_denorm.raw_cost_2,0) +
						         nvl(ei_denorm.raw_cost_3,0) + nvl(ei_denorm.raw_cost_4,0) +
						         nvl(ei_denorm.raw_cost_5,0) + nvl(ei_denorm.raw_cost_6,0) +
						         nvl(ei_denorm.raw_cost_7,0);
			x_total_exp_copied := x_total_exp_copied + nvl(ei_denorm.denorm_total_amount,0);
		ELSE
			ei_denorm.denorm_total_amount := null;
			x_total_exp_copied := x_total_exp_copied + nvl(ei_denorm.denorm_total_qty,0);
		END IF;

		-- Insert denorm record into pa_ei_denorm regards if any quantities got thru or not.
		pa_online_exp.insert_pa_ei_denorm_rec(
                				ei_denorm.expenditure_id,
	        				ei_denorm.denorm_id,
	        				ei_denorm.person_id,
						ei_denorm.project_id,
						ei_denorm.task_id,
						ei_denorm.billable_flag,
                				ei_denorm.expenditure_type,
						ei_denorm.default_sys_link_func,
						ei_denorm.unit_of_measure_code,
						ei_denorm.unit_of_measure,
	 					ei_denorm.expenditure_item_id_1,
						ei_denorm.expenditure_item_date_1,
						ei_denorm.quantity_1,
						ei_denorm.system_linkage_function_1,
						ei_denorm.non_labor_resource_1,
						ei_denorm.organization_id_1,
	        				ei_denorm.override_to_organization_id_1,
						ei_denorm.raw_cost_1,
						ei_denorm.raw_cost_rate_1,
	 					ei_denorm.attribute_category_1,
	 					ei_denorm.attribute1_1,
	 					ei_denorm.attribute1_2,
	 					ei_denorm.attribute1_3,
	 					ei_denorm.attribute1_4,
	 					ei_denorm.attribute1_5,
	 					ei_denorm.attribute1_6,
	 					ei_denorm.attribute1_7,
	 					ei_denorm.attribute1_8,
	 					ei_denorm.attribute1_9,
	 					ei_denorm.attribute1_10,
	 					ei_denorm.orig_transaction_reference_1,
 						ei_denorm.adjusted_expenditure_item_id_1,
						ei_denorm.net_zero_adjustment_flag_1,
						ei_denorm.expenditure_comment_1,
	 					ei_denorm.expenditure_item_id_2,
 						ei_denorm.expenditure_item_date_2,
	 					ei_denorm.quantity_2,
	        				ei_denorm.system_linkage_function_2,
        					ei_denorm.non_labor_resource_2,
	        				ei_denorm.organization_id_2,
	        				ei_denorm.override_to_organization_id_2,
	 					ei_denorm.raw_cost_2,
	 					ei_denorm.raw_cost_rate_2,
	 					ei_denorm.attribute_category_2,
	 					ei_denorm.attribute2_1,
	 					ei_denorm.attribute2_2,
	 					ei_denorm.attribute2_3,
 						ei_denorm.attribute2_4,
	 					ei_denorm.attribute2_5,
	 					ei_denorm.attribute2_6,
	 					ei_denorm.attribute2_7,
	 					ei_denorm.attribute2_8,
						ei_denorm.attribute2_9,
	 					ei_denorm.attribute2_10,
	 					ei_denorm.orig_transaction_reference_2,
        					ei_denorm.adjusted_expenditure_item_id_2,
	        				ei_denorm.net_zero_adjustment_flag_2,
	        				ei_denorm.expenditure_comment_2,
	 					ei_denorm.expenditure_item_id_3,
	 					ei_denorm.expenditure_item_date_3,
	 					ei_denorm.quantity_3,
	        				ei_denorm.system_linkage_function_3,
	        				ei_denorm.non_labor_resource_3,
	        				ei_denorm.organization_id_3,
	        				ei_denorm.override_to_organization_id_3,
	 					ei_denorm.raw_cost_3,
	 					ei_denorm.raw_cost_rate_3,
	 					ei_denorm.attribute_category_3,
	 					ei_denorm.attribute3_1,
	 					ei_denorm.attribute3_2,
	 					ei_denorm.attribute3_3,
	 					ei_denorm.attribute3_4,
	 					ei_denorm.attribute3_5,
	 					ei_denorm.attribute3_6,
	 					ei_denorm.attribute3_7,
	 					ei_denorm.attribute3_8,
	 					ei_denorm.attribute3_9,
	 					ei_denorm.attribute3_10,
	 					ei_denorm.orig_transaction_reference_3,
	        				ei_denorm.adjusted_expenditure_item_id_3,
	        				ei_denorm.net_zero_adjustment_flag_3,
	        				ei_denorm.expenditure_comment_3,
	 					ei_denorm.expenditure_item_id_4,
	 					ei_denorm.expenditure_item_date_4,
	 					ei_denorm.quantity_4,
	        				ei_denorm.system_linkage_function_4,
	        				ei_denorm.non_labor_resource_4,
	        				ei_denorm.organization_id_4,
	        				ei_denorm.override_to_organization_id_4,
	 					ei_denorm.raw_cost_4,
	 					ei_denorm.raw_cost_rate_4,
	 					ei_denorm.attribute_category_4,
	 					ei_denorm.attribute4_1,
	 					ei_denorm.attribute4_2,
	 					ei_denorm.attribute4_3,
	 					ei_denorm.attribute4_4,
	 					ei_denorm.attribute4_5,
	 					ei_denorm.attribute4_6,
	 					ei_denorm.attribute4_7,
	 					ei_denorm.attribute4_8,
	 					ei_denorm.attribute4_9,
	 					ei_denorm.attribute4_10,
	 					ei_denorm.orig_transaction_reference_4,
	        				ei_denorm.adjusted_expenditure_item_id_4,
	        				ei_denorm.net_zero_adjustment_flag_4,
	        				ei_denorm.expenditure_comment_4,
	 					ei_denorm.expenditure_item_id_5,
	 					ei_denorm.expenditure_item_date_5,
	 					ei_denorm.quantity_5,
	        				ei_denorm.system_linkage_function_5,
	        				ei_denorm.non_labor_resource_5,
	        				ei_denorm.organization_id_5,
	        				ei_denorm.override_to_organization_id_5,
						ei_denorm.raw_cost_5,
	 					ei_denorm.raw_cost_rate_5,
	 					ei_denorm.attribute_category_5,
	 					ei_denorm.attribute5_1,
	 					ei_denorm.attribute5_2,
	 					ei_denorm.attribute5_3,
	 					ei_denorm.attribute5_4,
	 					ei_denorm.attribute5_5,
	 					ei_denorm.attribute5_6,
	 					ei_denorm.attribute5_7,
	 					ei_denorm.attribute5_8,
	 					ei_denorm.attribute5_9,
	 					ei_denorm.attribute5_10,
	 					ei_denorm.orig_transaction_reference_5,
	        				ei_denorm.adjusted_expenditure_item_id_5,
	        				ei_denorm.net_zero_adjustment_flag_5,
	        				ei_denorm.expenditure_comment_5,
	 					ei_denorm.expenditure_item_id_6,
	 					ei_denorm.expenditure_item_date_6,
	 					ei_denorm.quantity_6,
	        				ei_denorm.system_linkage_function_6,
	        				ei_denorm.non_labor_resource_6,
	        				ei_denorm.organization_id_6,
	        				ei_denorm.override_to_organization_id_6,
	 					ei_denorm.raw_cost_6,
	 					ei_denorm.raw_cost_rate_6,
	 					ei_denorm.attribute_category_6,
	 					ei_denorm.attribute6_1,
	 					ei_denorm.attribute6_2,
	 					ei_denorm.attribute6_3,
	 					ei_denorm.attribute6_4,
	 					ei_denorm.attribute6_5,
	 					ei_denorm.attribute6_6,
	 					ei_denorm.attribute6_7,
	 					ei_denorm.attribute6_8,
	 					ei_denorm.attribute6_9,
	 					ei_denorm.attribute6_10,
	 					ei_denorm.orig_transaction_reference_6,
	        				ei_denorm.adjusted_expenditure_item_id_6,
	        				ei_denorm.net_zero_adjustment_flag_6,
	        				ei_denorm.expenditure_comment_6,
	 					ei_denorm.expenditure_item_id_7,
	 					ei_denorm.expenditure_item_date_7,
	 					ei_denorm.quantity_7,
	        				ei_denorm.system_linkage_function_7,
	        				ei_denorm.non_labor_resource_7,
	        				ei_denorm.organization_id_7,
	        				ei_denorm.override_to_organization_id_7,
	 					ei_denorm.raw_cost_7,
	 					ei_denorm.raw_cost_rate_7,
	 					ei_denorm.attribute_category_7,
	 					ei_denorm.attribute7_1,
	 					ei_denorm.attribute7_2,
	 					ei_denorm.attribute7_3,
	 					ei_denorm.attribute7_4,
	 					ei_denorm.attribute7_5,
	 					ei_denorm.attribute7_6,
	 					ei_denorm.attribute7_7,
	 					ei_denorm.attribute7_8,
	 					ei_denorm.attribute7_9,
	 					ei_denorm.attribute7_10,
	 					ei_denorm.orig_transaction_reference_7,
	        				ei_denorm.adjusted_expenditure_item_id_7,
	        				ei_denorm.net_zero_adjustment_flag_7,
	        				ei_denorm.expenditure_comment_7,
						ei_denorm.denorm_total_qty,
						ei_denorm.denorm_total_amount,
						ei_denorm.created_by,
						ei_denorm.creation_date,
						ei_denorm.last_update_date,
						ei_denorm.last_updated_by,
						ei_denorm.last_update_login,
						ei_denorm.job_id_1,
                				ei_denorm.job_id_2,
                				ei_denorm.job_id_3,
                				ei_denorm.job_id_4,
                				ei_denorm.job_id_5,
                				ei_denorm.job_id_6,
                				ei_denorm.job_id_7);


	END LOOP;
	CLOSE getEIdenorm;

  EXCEPTION
     WHEN OTHERS THEN
              RAISE;

  END  CopyItems;

  PROCEDURE Validate_item (x_project_id IN NUMBER,
			   x_task_id IN NUMBER,
			   x_expenditure_item_date IN DATE,
			   x_expenditure_type IN VARCHAR2,
			   x_sys_link_func IN VARCHAR2,
			   x_quantity IN NUMBER,
			   x_attribute_category IN VARCHAR2,
			   x_attribute1 IN VARCHAR2,
                           x_attribute2 IN VARCHAR2,
                           x_attribute3 IN VARCHAR2,
                           x_attribute4 IN VARCHAR2,
                           x_attribute5 IN VARCHAR2,
                           x_attribute6 IN VARCHAR2,
                           x_attribute7 IN VARCHAR2,
                           x_attribute8 IN VARCHAR2,
                           x_attribute9 IN VARCHAR2,
                           x_attribute10 IN VARCHAR2,
			   x_billable_flag IN OUT NOCOPY VARCHAR2,
			   x_job_id IN OUT NOCOPY NUMBER,
			   temp_outcome IN OUT NOCOPY VARCHAR2)
  IS

     x_task_billable_flag VARCHAR2(1);
     -- adding the temp variables transaction control
     -- extension chnages. This is only a temporary change
     -- because this function is not supported in 11.5.

     temp_outcome_type VARCHAR2(1);
     temp_msg_application VARCHAR2(50);
     temp_msg_token1   VARCHAR2(240);
     temp_msg_token2   VARCHAR2(240);
     temp_msg_token3   VARCHAR2(240);
     temp_msg_count    NUMBER;

     l_billable_flag VARCHAR2(1);
     l_job_id        NUMBER;
     l_temp_outcome  VARCHAR2(1000);
  BEGIN

      l_billable_flag := x_billable_flag; -- Store passed in values
      l_job_id        := x_job_id;
      l_temp_outcome  := temp_outcome;

      temp_outcome := NULL;

      IF pa_utils.CheckExpTypeActive(x_expenditure_type,x_expenditure_item_date) = FALSE THEN
		temp_outcome := 'NOT ACTIVE EXP TYPE';
		RETURN;
      END IF;

      IF pa_utils2.CheckSysLinkFuncActive(x_expenditure_type, x_expenditure_item_date, x_sys_link_func) = FALSE THEN
		temp_outcome := 'NOT ACTIVE SYS LINK FUNC';
		RETURN;
      END IF;

      ValidateEmp ( x_expenditure_item_date,
		    x_job_id,
                    temp_outcome );

      IF temp_outcome IS NULL THEN
        --
        -- replaced patc.get_status with pa_transactions_pub.
        -- validate_transaction.  This is a temporary change,
        -- because this function will not be supported in 11.5
        --
	     pa_transactions_pub.validate_transaction(
               X_project_id => X_project_id
            ,  X_task_id => X_task_id
            ,  X_ei_date => X_expenditure_item_date
            ,  X_expenditure_type  => X_expenditure_type
            ,  X_non_labor_resource => NULL
            ,  X_person_id  => G_inc_by_person_id
            ,  X_quantity => X_quantity
            ,  X_denom_currency_code => NULL
            ,  X_acct_currency_code => NULL
            ,  X_denom_raw_cost  => NULL
            ,  X_acct_raw_cost => NULL
            ,  X_acct_rate_type => NULL
            ,  X_acct_rate_date => NULL
            ,  X_acct_exchange_rate => NULL
            ,  X_transfer_ei => NULL
            ,  X_incurred_by_org_id => G_new_org_id
            ,  X_nl_resource_org_id => NULL
            ,  X_transaction_source => NULL
            ,  X_calling_module => G_module
       		,  X_vendor_id => NULL
            ,  X_entered_by_user_id => G_entered_by_person_id
            ,  X_attribute_category => X_attribute_category
 				,  X_attribute1 => X_attribute1
            ,  X_attribute2 => X_attribute2
            ,  X_attribute3 => X_attribute3
            ,  X_attribute4 => X_attribute4
            ,  X_attribute5 => X_attribute5
            ,  X_attribute6 => X_attribute6
            ,  X_attribute7 => X_attribute7
            ,  X_attribute8 => X_attribute8
            ,  X_attribute9 => X_attribute9
            ,  X_attribute10 => X_attribute10
       		,  X_attribute11 => NULL
            ,  X_attribute12 => NULL
            ,  X_attribute13 => NULL
            ,  X_attribute14 => NULL
            ,  X_attribute15 => NULL
            ,  X_msg_application => temp_msg_application
            ,  X_msg_type => temp_outcome_type
            ,  X_msg_token1 => temp_msg_token1
            ,  X_msg_token2 => temp_msg_token2
            ,  X_msg_token3 => temp_msg_token3
            ,  X_msg_count => temp_msg_count
            ,  X_msg_data => temp_outcome
            ,  X_billable_flag=> x_task_billable_flag
	    ,  P_sys_link_function => x_sys_link_func );

              IF x_task_billable_flag IS NOT NULL THEN
                    x_billable_flag := x_task_billable_flag;
              END IF;

      END IF;

  -- R12 NOCOPY Mandate - copy back passed in values
  EXCEPTION WHEN OTHERS THEN
      x_billable_flag := l_billable_flag;
      x_job_id        := l_job_id;
      temp_outcome    := l_temp_outcome;

  END Validate_Item;


  PROCEDURE  Copy_exp ( orig_exp_id            IN NUMBER
                      , old_exp_ending_date    IN DATE
                      , new_exp_id             IN NUMBER
                      , new_exp_ending_date    IN DATE
		      , incurred_by_org_id     IN NUMBER
		      , expenditure_class_code IN VARCHAR2
		      , x_exp_status_code      IN VARCHAR2
		      , x_exp_source_code      IN VARCHAR2
                      , x_copy_exp_type_flag   IN VARCHAR2
                      , x_copy_qty_flag        IN VARCHAR2
                      , x_copy_cmt_flag        IN VARCHAR2
                      , x_copy_dff_flag        IN VARCHAR2
		      , x_copy_attachment_flag IN VARCHAR2
                      , X_inc_by_person        IN NUMBER
		      , X_entered_by_person_id IN NUMBER
                      , userid                 IN NUMBER
		      , x_total_exp_copied     IN OUT NOCOPY NUMBER)
  IS
	days_diff NUMBER;

  BEGIN
    	G_user            := userid;
    	G_exp_class_code  := expenditure_class_code;
    	G_new_org_id      := incurred_by_org_id;
    	G_module := 'PAXTRONE';
    	G_copy_exp_type_flag := x_copy_exp_type_flag;
    	G_copy_qty_flag := x_copy_qty_flag;
    	G_copy_cmt_flag := x_copy_cmt_flag;
    	G_copy_dff_flag := x_copy_dff_flag;
    	G_entered_by_person_id := X_entered_by_person_id;
    	G_inc_by_person_id := x_inc_by_person;

    	IF EXP_EXISTS_IN_DENORM(orig_exp_id) = 'N' THEN
		pa_online_exp.build_denorm_table(orig_exp_id,
						 expenditure_class_code,
						 x_exp_status_code,
						 x_exp_source_code,
						 x_inc_by_person);
    	END IF;

    	days_diff := trunc(new_exp_ending_date) - trunc(old_exp_ending_date);

    	CopyItems ( orig_exp_id
              	  , new_exp_id
	      	  , days_diff
		  , x_total_exp_copied);

	IF x_copy_attachment_flag = 'Y' THEN

        	fnd_attached_documents2_pkg.copy_attachments('PA_EXPENDITURES',
               	                                      	     orig_exp_id,
                                                             null,
                                                             null,
                                                             null,
                                                             null,
                                                             'PA_EXPENDITURES',
                                                             new_exp_id,
                                                             null,
                                                             null,
                                                             null,
                                                             null,
                                                             G_user,
                                                             FND_GLOBAL.LOGIN_ID,
                                                             null,
							     null,
							     null);

	END IF;

  EXCEPTION
    	WHEN OTHERS THEN
		RAISE;

  END copy_exp;


  FUNCTION EXP_EXISTS_IN_DENORM(x_orig_exp_id IN NUMBER) RETURN VARCHAR2
  IS
	x_return VARCHAR2(1) DEFAULT 'N';

  BEGIN

	SELECT 'Y'
	INTO x_return
	FROM SYS.DUAL
	WHERE EXISTS (SELECT 'x'
		      FROM PA_EI_DENORM
		      WHERE EXPENDITURE_ID = x_orig_exp_id);

	RETURN ( x_return ) ;

  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN ( x_return );
	WHEN OTHERS THEN
		RAISE;

  END EXP_EXISTS_IN_DENORM;

END  PA_ONLINE_COPY_EXP;

/
