--------------------------------------------------------
--  DDL for Package EAM_CE_WORK_ORDER_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_CE_WORK_ORDER_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: EAMTCWOS.pls 120.0.12010000.2 2009/01/03 00:11:42 devijay noship $ */
-- Start of Comments
-- Package name     : EAM_CE_WORK_ORDER_LINES_PKG
-- Purpose          : Base Package to Insert/Delete/Update EAM_CE_WORK_ORDER_LINES
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'EAM_CE_WORK_ORDER_LINES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'EAMTCWOS.pls';

PROCEDURE INSERT_ROW(
        p_estimate_work_order_line_id    	NUMBER,
        p_estimate_work_order_id          NUMBER,
	p_src_cu_id                        	NUMBER,
	p_src_activity_id                	NUMBER,
	p_src_activity_qty                 	NUMBER,
	p_src_op_seq_num                 	NUMBER,
	p_src_acct_class_code             	VARCHAR2,
  p_src_diff_id                     NUMBER,
  p_diff_qty                        NUMBER,
	p_estimate_id                    	NUMBER,
	p_organization_id                	NUMBER,
	p_work_order_seq_num             	NUMBER,
	p_work_order_number              	VARCHAR2,
	p_work_order_description         	VARCHAR2,
	p_ref_wip_entity_id              	NUMBER,
	p_primary_item_id                	NUMBER,
	p_status_type                    	NUMBER,
	p_acct_class_code                	VARCHAR2,
	p_scheduled_start_date           	DATE,
	p_scheduled_completion_date      	DATE,
	p_project_id                     	NUMBER,
	p_task_id                        	NUMBER,
	p_maintenance_object_id          	NUMBER,
	p_maintenance_object_type        	NUMBER,
	p_maintenance_object_source      	NUMBER,
	p_owning_department_id           	NUMBER,
	p_user_defined_status_id         	NUMBER,
	p_op_seq_num                     	NUMBER,
	p_op_description                 	VARCHAR2,
	p_standard_operation_id          	NUMBER,
	p_op_department_id               	NUMBER,
	p_op_long_description            	VARCHAR2,
	p_res_seq_num                    	NUMBER,
	p_res_id                         	NUMBER,
	p_res_uom                        	VARCHAR2,
	p_res_basis_type                 	NUMBER,
	p_res_usage_rate_or_amount       	NUMBER,
	p_res_required_units             	NUMBER,
	p_res_assigned_units             	NUMBER,
	p_item_type                        	NUMBER,
	p_required_quantity                	NUMBER,
	p_unit_price                            NUMBER,
	p_uom                                   VARCHAR2,
	p_basis_type                            NUMBER,
	p_suggested_vendor_name            	VARCHAR2,
	p_suggested_vendor_id                   NUMBER,
	p_suggested_vendor_site            	VARCHAR2,
	p_suggested_vendor_site_id        	NUMBER,
	p_mat_inventory_item_id            	NUMBER,
	p_mat_component_seq_num            	NUMBER,
	p_mat_supply_subinventory               VARCHAR2,
	p_mat_supply_locator_id            	NUMBER,
	p_di_amount                             NUMBER,
	p_di_order_type_lookup_code        	VARCHAR2,
	p_di_description                        VARCHAR2,
	p_di_purchase_category_id               NUMBER,
	p_di_auto_request_material        	VARCHAR2,
	p_di_need_by_date                       DATE,
	p_work_order_line_cost           	NUMBER,
	p_creation_date                  	DATE,
	p_created_by                     	NUMBER,
	p_last_update_date               	DATE,
	p_last_updated_by                	NUMBER,
	p_last_update_login  	                NUMBER,
  p_work_order_type           NUMBER,
  p_activity_type NUMBER,
  p_activity_source NUMBER,
  p_activity_cause NUMBER,
  p_available_qty NUMBER,
  p_item_comments VARCHAR2,
  p_cu_qty NUMBER,
  p_res_sch_flag NUMBER
        );

PROCEDURE UPDATE_ROW(
  p_estimate_work_order_line_id    	NUMBER,
  p_estimate_work_order_id          NUMBER,
	p_src_cu_id                        	NUMBER,
	p_src_activity_id                	NUMBER,
	p_src_activity_qty                 	NUMBER,
	p_src_op_seq_num                 	NUMBER,
	p_src_acct_class_code             	VARCHAR2,
  p_src_diff_id                     NUMBER,
  p_diff_qty                    NUMBER,
	p_estimate_id                    	NUMBER,
	p_organization_id                	NUMBER,
	p_work_order_seq_num             	NUMBER,
	p_work_order_number              	VARCHAR2,
	p_work_order_description         	VARCHAR2,
	p_ref_wip_entity_id              	NUMBER,
	p_primary_item_id                	NUMBER,
	p_status_type                    	NUMBER,
	p_acct_class_code                	VARCHAR2,
	p_scheduled_start_date           	DATE,
	p_scheduled_completion_date      	DATE,
	p_project_id                     	NUMBER,
	p_task_id                        	NUMBER,
	p_maintenance_object_id          	NUMBER,
	p_maintenance_object_type        	NUMBER,
	p_maintenance_object_source      	NUMBER,
	p_owning_department_id           	NUMBER,
	p_user_defined_status_id         	NUMBER,
	p_op_seq_num                     	NUMBER,
	p_op_description                 	VARCHAR2,
	p_standard_operation_id          	NUMBER,
	p_op_department_id               	NUMBER,
	p_op_long_description            	VARCHAR2,
	p_res_seq_num                    	NUMBER,
	p_res_id                         	NUMBER,
	p_res_uom                        	VARCHAR2,
	p_res_basis_type                 	NUMBER,
	p_res_usage_rate_or_amount       	NUMBER,
	p_res_required_units             	NUMBER,
	p_res_assigned_units             	NUMBER,
	p_item_type                        	NUMBER,
	p_required_quantity                	NUMBER,
	p_unit_price                            NUMBER,
	p_uom                                   VARCHAR2,
	p_basis_type                            NUMBER,
	p_suggested_vendor_name            	VARCHAR2,
	p_suggested_vendor_id                   NUMBER,
	p_suggested_vendor_site            	VARCHAR2,
	p_suggested_vendor_site_id        	NUMBER,
	p_mat_inventory_item_id            	NUMBER,
	p_mat_component_seq_num            	NUMBER,
	p_mat_supply_subinventory               VARCHAR2,
	p_mat_supply_locator_id            	NUMBER,
	p_di_amount                             NUMBER,
	p_di_order_type_lookup_code        	VARCHAR2,
	p_di_description                        VARCHAR2,
	p_di_purchase_category_id               NUMBER,
	p_di_auto_request_material        	VARCHAR2,
	p_di_need_by_date                       DATE,
	p_work_order_line_cost           	NUMBER,
	p_creation_date                  	DATE,
	p_created_by                     	NUMBER,
	p_last_update_date               	DATE,
	p_last_updated_by                	NUMBER,
	p_last_update_login  	                NUMBER,
  p_work_order_type           NUMBER,
  p_activity_type NUMBER,
  p_activity_source NUMBER,
  p_activity_cause NUMBER,
  p_available_qty NUMBER,
  p_item_comments VARCHAR2,
  p_cu_qty NUMBER,
  p_res_sch_flag NUMBER
        );

PROCEDURE DELETE_ALL_WITH_ESTIMATE_ID(
  p_estimate_id                           IN  NUMBER
);

PROCEDURE DELETE_ROW(
  p_work_order_line_id           IN  NUMBER
);

END EAM_CE_WORK_ORDER_LINES_PKG;

/
