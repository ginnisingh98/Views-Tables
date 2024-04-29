--------------------------------------------------------
--  DDL for Package Body PA_ONLINE_EXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ONLINE_EXP" AS
/* $Header: PAXONTEB.pls 120.2 2005/08/09 04:31:32 avajain ship $ */

  PROCEDURE BUILD_DENORM_TABLE (X_exp_id IN NUMBER,
				X_exp_class_code IN VARCHAR2,
				X_exp_status_code IN VARCHAR2,
				X_exp_source_code IN VARCHAR2,
				X_person_id IN NUMBER)
  IS


   BEGIN

	Null;

  END BUILD_DENORM_TABLE;

  PROCEDURE SET_DAY

  IS

  BEGIN

	Null;

  END SET_DAY;

  FUNCTION GET_DAY(X_matrix_column IN NUMBER) return varchar2
  IS

  BEGIN

        RETURN(NULL) ;

  END GET_DAY;

  PROCEDURE GET_NUM_DAYOFWEEK ( X_name_dayof_week IN VARCHAR2,
                                X_num_dayof_week OUT NOCOPY VARCHAR2)
  IS

  BEGIN

	Null;

  END GET_NUM_DAYOFWEEK;

  PROCEDURE FIND_DELETE_EXP_ITEMS(x_denorm_id IN NUMBER,
                                  X_COLUMN IN NUMBER,
                                  X_status OUT NOCOPY NUMBER)

  IS

  BEGIN

	Null;

  END FIND_DELETE_EXP_ITEMS;


  FUNCTION GET_LAST_RTE_COMMENT (X_exp_id IN NUMBER) RETURN VARCHAR2
  IS

  BEGIN

       RETURN ( Null );

  END GET_LAST_RTE_COMMENT;

  FUNCTION GET_EXP_TOTAL_HOURS( X_exp_id IN NUMBER,
			        X_exp_class_code IN VARCHAR2) RETURN NUMBER

  IS

  BEGIN

	Return ( 0 );

  END GET_EXP_TOTAL_HOURS;

  FUNCTION GET_EI_TOTAL_HOURS(X_exp_id IN NUMBER,
			       X_exp_class_code IN VARCHAR2) RETURN NUMBER
  IS

  BEGIN

	RETURN( 0 ) ;

  END GET_EI_TOTAL_HOURS;

  FUNCTION GET_DENORM_TOTAL_HOURS (x_exp_id IN NUMBER,
                                   x_exp_class_code IN VARCHAR2) RETURN NUMBER

  IS

  BEGIN

	RETURN( 0 );

  END GET_DENORM_TOTAL_HOURS;

  FUNCTION GET_EXP_TOTAL_COST( X_exp_id IN NUMBER,
                               X_exp_class_code IN VARCHAR2) RETURN NUMBER
  IS

  BEGIN

	RETURN ( 0 );

  END GET_EXP_TOTAL_COST;

  FUNCTION GET_EI_TOTAL_COST(X_exp_id IN NUMBER,
                             X_exp_class_code IN VARCHAR2) RETURN NUMBER
  IS

  BEGIN

        RETURN( 0 ) ;

  END GET_EI_TOTAL_COST;

  FUNCTION GET_DENORM_TOTAL_COST (x_exp_id IN NUMBER,
                                  x_exp_class_code IN VARCHAR2) RETURN NUMBER

  IS

  BEGIN

        RETURN( 0 );

  END GET_DENORM_TOTAL_COST;

  FUNCTION GET_EXP_TRANS ( X_exp_class_code IN VARCHAR2) RETURN VARCHAR2

  IS

  BEGIN

    RETURN ( NULL ) ;

  END GET_EXP_TRANS;

  FUNCTION GET_EXP_SRC (X_exp_class_code IN VARCHAR2,
			X_exp_group      IN VARCHAR2,
			X_pte_ref        IN NUMBER) RETURN VARCHAR2
  IS

  BEGIN

     RETURN ( NULL );

  END GET_EXP_SRC;

  FUNCTION GET_EXP_SRC_CODE (X_exp_class_code IN VARCHAR2,
			     X_exp_group      IN VARCHAR2,
			     X_pte_ref        IN NUMBER) RETURN VARCHAR2
  IS

  BEGIN

     RETURN ( NULL );

  END GET_EXP_SRC_CODE;


  PROCEDURE STORE_REVERSE_ITEMS (X_exp_item_id IN NUMBER)
  IS

  BEGIN

	Null;

  END STORE_REVERSE_ITEMS;

  PROCEDURE PROCESS_REVERSE_ITEMS (X_Exp_id IN NUMBER,
		                   X_entered_by_person_id IN NUMBER,
				   X_user_id IN NUMBER,
				   X_new_exp_id in NUMBER,
				   X_status OUT NOCOPY VARCHAR2)
  IS

  BEGIN

	Null;

  END PROCESS_REVERSE_ITEMS;

  FUNCTION GET_OLD_EI_COMMENT(x_exp_item_id IN NUMBER) RETURN VARCHAR2
  IS

  BEGIN

	RETURN ( NULL );

  END GET_OLD_EI_COMMENT;

  FUNCTION GET_EXPREP_PAID_AMT  (X_exp_id IN NUMBER) RETURN NUMBER

  IS

  BEGIN

      	RETURN(0);

  END GET_EXPREP_PAID_AMT;

  PROCEDURE SET_ADMIN_PERSON_ID (X_person_id IN NUMBER)
  IS

  BEGIN

	Null;

  END SET_ADMIN_PERSON_ID;

  FUNCTION GetAdminPersonId RETURN NUMBER
  IS

  BEGIN

     RETURN (Null);

  END GetAdminPersonId;

  FUNCTION Get_wte_reference (X_exp_group IN VARCHAR2,
                              X_exp_class_code IN VARCHAR2 )RETURN VARCHAR2

  IS

  BEGIN

	RETURN ( NULL );

  END Get_Wte_Reference;

  PROCEDURE INSERT_PA_EI_DENORM_REC (
			x_exp_id IN NUMBER,
       		        x_denorm_id IN NUMBER,
			x_person_id IN NUMBER,
       		        x_project_id IN NUMBER,
			x_task_id IN NUMBER,
			x_billable_flag IN VARCHAR2,
       		        x_expenditure_type IN VARCHAR2,
			x_default_sys_link_func IN VARCHAR2,
			x_unit_of_measure_code IN VARCHAR2,
			x_unit_of_measure IN VARCHAR2,
       		        x_expenditure_item_id_1 IN NUMBER,
       		        x_expenditure_item_date_1 IN DATE,
       		        x_quantity_1 IN NUMBER,
                        x_system_linkage_function_1 IN VARCHAR2,
                        x_non_labor_resource_1 IN VARCHAR2,
                        x_organization_id_1 IN NUMBER,
			x_override_to_org_id_1 IN  NUMBER,
        	        x_raw_cost_1 IN NUMBER,
       		        x_raw_cost_rate_1 IN NUMBER,
        	        x_attribute_category_1 IN VARCHAR2,
        	        x_attribute1_1 IN VARCHAR2,
        	        x_attribute1_2 IN VARCHAR2,
        	        x_attribute1_3 IN VARCHAR2,
        	        x_attribute1_4 IN VARCHAR2,
        	        x_attribute1_5 IN VARCHAR2,
        	        x_attribute1_6 IN VARCHAR2,
        	        x_attribute1_7 IN VARCHAR2,
        	        x_attribute1_8 IN VARCHAR2,
        	        x_attribute1_9 IN VARCHAR2,
        	        x_attribute1_10 IN VARCHAR2,
        	        x_orig_transaction_reference_1 IN VARCHAR2,
                        x_adj_expenditure_item_id_1 IN NUMBER,
                        x_net_zero_adjustment_flag_1 IN VARCHAR2,
        	        x_expenditure_comment_1 IN VARCHAR2,
                        x_expenditure_item_id_2 IN NUMBER,
                        x_expenditure_item_date_2 IN DATE,
                        x_quantity_2 IN NUMBER,
                        x_system_linkage_function_2 IN VARCHAR2,
                        x_non_labor_resource_2 IN VARCHAR2,
                        x_organization_id_2 IN NUMBER,
                        x_override_to_org_id_2 IN NUMBER,
                        x_raw_cost_2 IN NUMBER,
                        x_raw_cost_rate_2 IN NUMBER,
                        x_attribute_category_2 IN VARCHAR2,
                        x_attribute2_1 IN VARCHAR2,
                        x_attribute2_2 IN VARCHAR2,
                        x_attribute2_3 IN VARCHAR2,
                        x_attribute2_4 IN VARCHAR2,
                        x_attribute2_5 IN VARCHAR2,
                        x_attribute2_6 IN VARCHAR2,
                        x_attribute2_7 IN VARCHAR2,
                        x_attribute2_8 IN VARCHAR2,
                        x_attribute2_9 IN VARCHAR2,
                        x_attribute2_10 IN VARCHAR2,
                        x_orig_transaction_reference_2 IN VARCHAR2,
                        x_adj_expenditure_item_id_2 IN NUMBER,
                        x_net_zero_adjustment_flag_2 IN VARCHAR2,
                        x_expenditure_comment_2 IN VARCHAR2,
                        x_expenditure_item_id_3 IN NUMBER,
                        x_expenditure_item_date_3 IN DATE,
                        x_quantity_3 IN NUMBER,
                        x_system_linkage_function_3 IN VARCHAR2,
                        x_non_labor_resource_3 IN VARCHAR2,
                        x_organization_id_3 IN NUMBER,
                        x_override_to_org_id_3 IN NUMBER,
                        x_raw_cost_3 IN NUMBER,
                        x_raw_cost_rate_3 IN NUMBER,
                        x_attribute_category_3 IN VARCHAR2,
                        x_attribute3_1 IN VARCHAR2,
                        x_attribute3_2 IN VARCHAR2,
                        x_attribute3_3 IN VARCHAR2,
                        x_attribute3_4 IN VARCHAR2,
                        x_attribute3_5 IN VARCHAR2,
                        x_attribute3_6 IN VARCHAR2,
                        x_attribute3_7 IN VARCHAR2,
                        x_attribute3_8 IN VARCHAR2,
                        x_attribute3_9 IN VARCHAR2,
                        x_attribute3_10 IN VARCHAR2,
                        x_orig_transaction_reference_3 IN VARCHAR2,
                        x_adj_expenditure_item_id_3 IN NUMBER,
                        x_net_zero_adjustment_flag_3 IN VARCHAR2,
                        x_expenditure_comment_3 IN VARCHAR2,
                        x_expenditure_item_id_4 IN NUMBER,
                        x_expenditure_item_date_4 IN DATE,
                        x_quantity_4 IN NUMBER,
                        x_system_linkage_function_4 IN VARCHAR2,
                        x_non_labor_resource_4 IN VARCHAR2,
                        x_organization_id_4 IN NUMBER,
                        x_override_to_org_id_4 IN NUMBER,
                        x_raw_cost_4 IN NUMBER,
                        x_raw_cost_rate_4 IN NUMBER,
                        x_attribute_category_4 IN VARCHAR2,
                        x_attribute4_1 IN VARCHAR2,
                        x_attribute4_2 IN VARCHAR2,
                        x_attribute4_3 IN VARCHAR2,
                        x_attribute4_4 IN VARCHAR2,
                        x_attribute4_5 IN VARCHAR2,
                        x_attribute4_6 IN VARCHAR2,
                        x_attribute4_7 IN VARCHAR2,
                        x_attribute4_8 IN VARCHAR2,
                        x_attribute4_9 IN VARCHAR2,
                        x_attribute4_10 IN VARCHAR2,
                        x_orig_transaction_reference_4 IN VARCHAR2,
                        x_adj_expenditure_item_id_4 IN NUMBER,
                        x_net_zero_adjustment_flag_4 IN VARCHAR2,
                        x_expenditure_comment_4 IN VARCHAR2,
                        x_expenditure_item_id_5 IN NUMBER,
                        x_expenditure_item_date_5 IN DATE,
                        x_quantity_5 IN NUMBER,
                        x_system_linkage_function_5 IN VARCHAR2,
                        x_non_labor_resource_5 IN VARCHAR2,
                        x_organization_id_5 IN NUMBER,
                        x_override_to_org_id_5 IN NUMBER,
                        x_raw_cost_5 IN NUMBER,
                        x_raw_cost_rate_5 IN NUMBER,
                        x_attribute_category_5 IN VARCHAR2,
                        x_attribute5_1 IN VARCHAR2,
                        x_attribute5_2 IN VARCHAR2,
                        x_attribute5_3 IN VARCHAR2,
                        x_attribute5_4 IN VARCHAR2,
                        x_attribute5_5 IN VARCHAR2,
                        x_attribute5_6 IN VARCHAR2,
                        x_attribute5_7 IN VARCHAR2,
                        x_attribute5_8 IN VARCHAR2,
                        x_attribute5_9 IN VARCHAR2,
                        x_attribute5_10 IN VARCHAR2,
                        x_orig_transaction_reference_5 IN VARCHAR2,
                        x_adj_expenditure_item_id_5 IN NUMBER,
                        x_net_zero_adjustment_flag_5 IN VARCHAR2,
                        x_expenditure_comment_5 IN VARCHAR2,
                        x_expenditure_item_id_6 IN NUMBER,
                        x_expenditure_item_date_6 IN DATE,
                        x_quantity_6 IN NUMBER,
                        x_system_linkage_function_6 IN VARCHAR2,
                        x_non_labor_resource_6 IN VARCHAR2,
                        x_organization_id_6 IN NUMBER,
                        x_override_to_org_id_6 IN NUMBER,
                        x_raw_cost_6 IN NUMBER,
                        x_raw_cost_rate_6 IN NUMBER,
                        x_attribute_category_6 IN VARCHAR2,
                        x_attribute6_1 IN VARCHAR2,
                        x_attribute6_2 IN VARCHAR2,
                        x_attribute6_3 IN VARCHAR2,
                        x_attribute6_4 IN VARCHAR2,
                        x_attribute6_5 IN VARCHAR2,
                        x_attribute6_6 IN VARCHAR2,
                        x_attribute6_7 IN VARCHAR2,
                        x_attribute6_8 IN VARCHAR2,
                        x_attribute6_9 IN VARCHAR2,
                        x_attribute6_10 IN VARCHAR2,
                        x_orig_transaction_reference_6 IN VARCHAR2,
                        x_adj_expenditure_item_id_6 IN NUMBER,
                        x_net_zero_adjustment_flag_6 IN VARCHAR2,
                        x_expenditure_comment_6 IN VARCHAR2,
                        x_expenditure_item_id_7 IN NUMBER,
                        x_expenditure_item_date_7 IN DATE,
                        x_quantity_7 IN NUMBER,
                        x_system_linkage_function_7 IN VARCHAR2,
                        x_non_labor_resource_7 IN VARCHAR2,
                        x_organization_id_7 IN NUMBER,
                        x_override_to_org_id_7 IN NUMBER,
                        x_raw_cost_7 IN NUMBER,
                        x_raw_cost_rate_7 IN NUMBER,
                        x_attribute_category_7 IN VARCHAR2,
                        x_attribute7_1 IN VARCHAR2,
                        x_attribute7_2 IN VARCHAR2,
                        x_attribute7_3 IN VARCHAR2,
                        x_attribute7_4 IN VARCHAR2,
                        x_attribute7_5 IN VARCHAR2,
                        x_attribute7_6 IN VARCHAR2,
                        x_attribute7_7 IN VARCHAR2,
                        x_attribute7_8 IN VARCHAR2,
                        x_attribute7_9 IN VARCHAR2,
                        x_attribute7_10 IN VARCHAR2,
                        x_orig_transaction_reference_7 IN VARCHAR2,
                        x_adj_expenditure_item_id_7 IN NUMBER,
                        x_net_zero_adjustment_flag_7 IN VARCHAR2,
                        x_expenditure_comment_7 IN VARCHAR2,
			x_total_qty IN NUMBER,
			x_total_amount IN NUMBER,
			x_created_by IN NUMBER,
			x_creation_date IN DATE,
			x_last_update_date IN DATE,
			x_last_updated_by IN NUMBER,
			x_last_update_login IN NUMBER,
                        x_job_id_1 IN NUMBER,
                        x_job_id_2 IN NUMBER,
                        x_job_id_3 IN NUMBER,
                        x_job_id_4 IN NUMBER,
                        x_job_id_5 IN NUMBER,
                        x_job_id_6 IN NUMBER,
                        x_job_id_7 IN NUMBER)

  IS

  BEGIN

	NULL;

  END INSERT_PA_EI_DENORM_REC;



END PA_ONLINE_EXP;

/
