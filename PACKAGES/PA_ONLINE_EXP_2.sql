--------------------------------------------------------
--  DDL for Package PA_ONLINE_EXP_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ONLINE_EXP_2" AUTHID CURRENT_USER AS
/* $Header: PAXTRONS.pls 120.1 2005/08/17 12:57:15 ramurthy noship $ */

    PROCEDURE SUBMIT_EXP( X_exp_id IN NUMBER,
		          X_incurred_by_person_id IN NUMBER,
		          X_exp_status IN VARCHAR,
		          x_user_id IN NUMBER,
		          x_route_to_person_id IN NUMBER,
		          x_routing_comment IN VARCHAR2);

    PROCEDURE UPDATE_ROUTING_REC (x_exp_id IN NUMBER,
				  x_user_id IN NUMBER,
				  x_last_update_login IN NUMBER);

    PROCEDURE DEL_EXP_REC ( x_exp_id IN NUMBER);

    PROCEDURE DEL_ITEM_COMMENTS(x_exp_id IN NUMBER);

    PROCEDURE DEL_ITEMS(x_exp_id IN NUMBER);

    PROCEDURE DEL_ROUTING_RECS(x_exp_id IN NUMBER);

    PROCEDURE DEL_DENORM_RECS(x_exp_id IN NUMBER);

    PROCEDURE CHECK_DFF_REQUIRED(DFF_NAME IN VARCHAR2,
				 DFF_REQUIRED OUT NOCOPY VARCHAR2);

    PROCEDURE SET_DENORM_NET_ZERO_FLAG(x_denorm_id IN NUMBER,
			               x_ei_id IN NUMBER,
			               x_outcome OUT NOCOPY VARCHAR2);

    PROCEDURE ADJUST_COST_IN_DENORM(x_denorm_id IN NUMBER,
				    x_ei_id IN NUMBER,
				    x_cost_rate IN NUMBER,
				    x_raw_cost IN NUMBER,
				    x_outcome OUT NOCOPY VARCHAR2);

    PROCEDURE UPDATE_DATA_IN_EXP_ITEMS (X_exp_id IN NUMBER,
                                    X_user IN NUMBER,
                                    x_status IN OUT NOCOPY VARCHAR2);

    PROCEDURE UPDATE_EXP_ITEM (   x_exp_id IN NUMBER,
                              x_denorm_id IN NUMBER,
                              x_person_id IN NUMBER,
                              x_project_id IN NUMBER,
                              x_task_id IN NUMBER,
                              x_billable_flag IN VARCHAR2,
                              x_exp_type IN VARCHAR2,
                              x_sys_link_function IN VARCHAR2,
                              x_exp_item_id IN NUMBER,
                              x_exp_item_date IN DATE,
                              x_qty IN NUMBER,
                              x_attrib_cat IN VARCHAR2,
                              x_attrib1 IN VARCHAR2,
                              x_attrib2 IN VARCHAR2,
                              x_attrib3 IN VARCHAR2,
                              x_attrib4 IN VARCHAR2,
                              x_attrib5 IN VARCHAR2,
                              x_attrib6 IN VARCHAR2,
                              x_attrib7 IN VARCHAR2,
                              x_attrib8 IN VARCHAR2,
                              x_attrib9 IN VARCHAR2,
                              x_attrib10 IN VARCHAR2,
                              x_orig_trans_ref IN VARCHAR2,
                              x_adj_exp_item_id IN NUMBER,
                              x_net_zero_adj_flag IN VARCHAR2,
                              x_item_comment IN VARCHAR2,
			      x_job_id IN NUMBER,
                              X_user IN NUMBER,
                              X_status IN OUT NOCOPY VARCHAR2);

    PROCEDURE INSERT_EXP_ITEM (   x_exp_id IN NUMBER,
                              x_denorm_id IN NUMBER,
                              x_person_id IN NUMBER,
                              x_project_id IN NUMBER,
                              x_task_id IN NUMBER,
                              x_billable_flag IN VARCHAR2,
                              x_exp_type IN VARCHAR2,
                              x_sys_link_function IN VARCHAR2,
                              x_exp_item_id IN NUMBER,
                              x_item_date IN DATE,
                              x_qty IN NUMBER,
                              x_attrib_cat IN VARCHAR2,
                              x_attrib1 IN VARCHAR2,
                              x_attrib2 IN VARCHAR2,
                              x_attrib3 IN VARCHAR2,
                              x_attrib4 IN VARCHAR2,
                              x_attrib5 IN VARCHAR2,
                              x_attrib6 IN VARCHAR2,
                              x_attrib7 IN VARCHAR2,
                              x_attrib8 IN VARCHAR2,
                              x_attrib9 IN VARCHAR2,
                              x_attrib10 IN VARCHAR2,
                              x_orig_trans_ref IN VARCHAR2,
                              x_adj_exp_item_id IN NUMBER,
                              x_net_zero_adj_flag IN VARCHAR2,
                              x_item_comment IN VARCHAR2,
			      x_job_id IN NUMBER,
                              X_user IN NUMBER,
                              X_status IN OUT NOCOPY VARCHAR2);

   PROCEDURE Summary_Validation(X_exp_id IN NUMBER,
			        X_inc_by_person_id NUMBER,
			        X_ending_Date IN DATE,
			        X_exp_class_code IN VARCHAR2,
			        x_exp_status IN OUT NOCOPY VARCHAR2,
			        x_comment OUT NOCOPY VARCHAR2);

   PROCEDURE ClearReversedItem(x_adjusted_exp_item_id IN NUMBER);

   PROCEDURE ClearDenormReversedItems(x_denorm_id IN NUMBER,
				      x_qty_1 IN NUMBER,
				      x_qty_2 IN NUMBER,
				      x_qty_3 IN NUMBER,
				      x_qty_4 IN NUMBER,
				      x_qty_5 IN NUMBER,
				      x_qty_6 IN NUMBER,
				      x_qty_7 IN NUMBER,
				      x_adj_ei_id_1 IN NUMBER,
				      x_adj_ei_id_2 IN NUMBER,
				      x_adj_ei_id_3 IN NUMBER,
				      x_adj_ei_id_4 IN NUMBER,
				      x_adj_ei_id_5 IN NUMBER,
				      x_adj_ei_id_6 IN NUMBER,
				      x_adj_ei_id_7 IN NUMBER);

   PROCEDURE InsertExp ( x_row_id IN OUT NOCOPY VARCHAR2,
			 x_exp_id IN NUMBER,
   		         x_update_date IN DATE,
		         x_last_updated_by IN NUMBER,
		         x_creation_date IN DATE,
		         x_created_by IN NUMBER,
		         x_status_code IN VARCHAR2,
			 x_ending_date IN DATE,
		         x_class_code IN VARCHAR2,
		         x_inc_by_person_id IN NUMBER,
		         x_inc_by_org_id IN NUMBER,
		         x_entered_by_person_id NUMBER,
		         x_desc IN VARCHAR2,
		         x_last_login IN NUMBER,
		         x_attrib_cat IN VARCHAR2,
		         x_attrib1 IN VARCHAR2,
		         x_attrib2 IN VARCHAR2,
		         x_attrib3 IN VARCHAR2,
		         x_attrib4 IN VARCHAR2,
		         x_attrib5 IN VARCHAR2,
		         x_attrib6 IN VARCHAR2,
		         x_attrib7 IN VARCHAR2,
		         x_attrib8 IN VARCHAR2,
		         x_attrib9 IN VARCHAR2,
		         x_attrib10 IN VARCHAR2,
               -- Trx_import enhancement:
               -- These new parameters are needed to populate
               -- PA_EXPENDITURES_ALL table's new columns
               x_orig_exp_txn_reference1 IN VARCHAR2 DEFAULT NULL,
               x_orig_user_exp_txn_reference IN VARCHAR2 DEFAULT NULL,
               x_vendor_id IN NUMBER DEFAULT NULL,
               x_orig_exp_txn_reference2 IN VARCHAR2 DEFAULT NULL,
               x_orig_exp_txn_reference3 IN VARCHAR2 DEFAULT NULL);

  FUNCTION eis_exist(x_exp_id IN NUMBER) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES ( eis_exist, WNDS, WNPS ) ;

  PROCEDURE DeleteDenormEIs(x_denorm_id IN NUMBER);

  PROCEDURE ReworkExpRemoveEIs(x_exp_id IN NUMBER);

  PROCEDURE   CommentChange( X_exp_item_id  IN NUMBER
                           , X_new_comment  IN VARCHAR2
                           , X_user         IN NUMBER
                           , X_login        IN NUMBER
                           , X_status       OUT NOCOPY NUMBER );

END pa_online_exp_2;

 

/
