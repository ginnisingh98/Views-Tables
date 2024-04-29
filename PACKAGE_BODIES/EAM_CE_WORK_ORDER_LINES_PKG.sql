--------------------------------------------------------
--  DDL for Package Body EAM_CE_WORK_ORDER_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_CE_WORK_ORDER_LINES_PKG" AS
/* $Header: EAMTCWOB.pls 120.0.12010000.3 2009/01/03 00:11:08 devijay noship $ */
-- Start of Comments
-- Package name     : EAM_CE_WORK_ORDER_LINES_PKG
-- Purpose          : Base Package to Insert/Delete/Update EAM_CE_WORK_ORDER_LINES
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'EAM_CE_WORK_ORDER_LINES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'EAMTCWOB.pls';

PROCEDURE INSERT_ROW
(
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

)
IS
  l_wo_line_id_seq NUMBER;
BEGIN
  IF (p_estimate_id IS NOT NULL) OR (p_estimate_id <> FND_API.G_MISS_NUM) THEN

 IF p_estimate_work_order_line_id IS NULL THEN
   SELECT EAM_CE_WORK_ORDER_LINES_S.NEXTVAL INTO l_wo_line_id_seq FROM DUAL;



  ELSE
    l_wo_line_id_seq := p_estimate_work_order_line_id;
  END IF;

 INSERT INTO EAM_CE_WORK_ORDER_LINES(
   ESTIMATE_WORK_ORDER_LINE_ID,
  ESTIMATE_WORK_ORDER_ID
  ,SRC_CU_ID
  ,SRC_ACTIVITY_ID
  ,SRC_ACTIVITY_QTY
  ,SRC_OP_SEQ_NUM
  ,SRC_ACCT_CLASS_CODE
  ,SRC_DIFFICULTY_ID
  ,DIFFICULTY_QTY
  ,ESTIMATE_ID
  ,ORGANIZATION_ID
  ,WORK_ORDER_SEQ_NUM
  ,WORK_ORDER_NUMBER
  ,WORK_ORDER_DESCRIPTION
  ,REF_WIP_ENTITY_ID
  ,PRIMARY_ITEM_ID
  ,STATUS_TYPE
  ,ACCT_CLASS_CODE
  ,SCHEDULED_START_DATE
  ,SCHEDULED_COMPLETION_DATE
  ,PROJECT_ID
  ,TASK_ID
  ,MAINTENANCE_OBJECT_ID
  ,MAINTENANCE_OBJECT_TYPE
  ,MAINTENANCE_OBJECT_SOURCE
  ,OWNING_DEPARTMENT_ID
  ,USER_DEFINED_STATUS_ID
  ,OP_SEQ_NUM
  ,OP_DESCRIPTION
  ,STANDARD_OPERATION_ID
  ,OP_DEPARTMENT_ID
  ,OP_LONG_DESCRIPTION
  ,RES_SEQ_NUM
  ,RES_ID
  ,RES_UOM
  ,RES_BASIS_TYPE
  ,RES_USAGE_RATE_OR_AMOUNT
  ,RES_REQUIRED_UNITS
  ,RES_ASSIGNED_UNITS
  ,ITEM_TYPE
  ,REQUIRED_QUANTITY
  ,UNIT_PRICE
  ,UOM
  ,BASIS_TYPE
  ,SUGGESTED_VENDOR_NAME
  ,SUGGESTED_VENDOR_ID
  ,SUGGESTED_VENDOR_SITE
  ,SUGGESTED_VENDOR_SITE_ID
  ,MAT_INVENTORY_ITEM_ID
  ,MAT_COMPONENT_SEQ_NUM
  ,MAT_SUPPLY_SUBINVENTORY
  ,MAT_SUPPLY_LOCATOR_ID
  ,DI_AMOUNT
  ,DI_ORDER_TYPE_LOOKUP_CODE
  ,DI_DESCRIPTION
  ,DI_PURCHASE_CATEGORY_ID
  ,DI_AUTO_REQUEST_MATERIAL
  ,DI_NEED_BY_DATE
  ,WO_LINE_PER_UNIT_COST
  ,CREATION_DATE
  ,CREATED_BY
  ,LAST_UPDATE_DATE
  ,LAST_UPDATED_BY
  ,LAST_UPDATE_LOGIN
  ,WORK_ORDER_TYPE
  ,ACTIVITY_TYPE
  ,ACTIVITY_CAUSE
  ,ACTIVITY_SOURCE
  ,AVAILABLE_QUANTITY
  ,ITEM_COMMENTS
  ,CU_QTY
  ,RES_SCHEDULED_FLAG
)
VALUES
(
  l_wo_line_id_seq,
  decode(p_estimate_work_order_id      ,FND_API.G_MISS_NUM,NULL,p_estimate_work_order_id                   ),
  decode(p_src_cu_id                   ,FND_API.G_MISS_NUM,NULL,p_src_cu_id                   ),
  decode(p_src_activity_id             ,FND_API.G_MISS_NUM,NULL,p_src_activity_id             ),
  decode(p_src_activity_qty            ,FND_API.G_MISS_NUM,NULL,p_src_activity_qty            ),
  decode(p_src_op_seq_num              ,FND_API.G_MISS_NUM,NULL,p_src_op_seq_num              ),
  decode(p_src_acct_class_code         ,FND_API.G_MISS_CHAR,NULL,p_src_acct_class_code        ),
  decode(p_src_diff_id                 ,FND_API.G_MISS_NUM,NULL,p_src_diff_id        ),
  decode(p_diff_qty                ,FND_API.G_MISS_NUM,NULL,p_diff_qty        ),
  p_estimate_id,
  decode(p_organization_id             ,FND_API.G_MISS_NUM,NULL,p_organization_id             ),
  decode(p_work_order_seq_num          ,FND_API.G_MISS_NUM,NULL,p_work_order_seq_num          ),
  decode(p_work_order_number           ,FND_API.G_MISS_CHAR,NULL,p_work_order_number          ),
  decode(p_work_order_description      ,FND_API.G_MISS_CHAR,NULL,p_work_order_description     ),
  decode(p_ref_wip_entity_id           ,FND_API.G_MISS_NUM,NULL,p_ref_wip_entity_id           ),
  decode(p_primary_item_id             ,FND_API.G_MISS_NUM,NULL,p_primary_item_id             ),
  decode(p_status_type                 ,FND_API.G_MISS_NUM,NULL,p_status_type                 ),
  decode(p_acct_class_code             ,FND_API.G_MISS_CHAR,NULL,p_acct_class_code            ),
  decode(p_scheduled_start_date        ,FND_API.G_MISS_DATE,sysdate,sysdate             ),
  decode(p_scheduled_completion_date   ,FND_API.G_MISS_DATE,TO_DATE(NULL),p_scheduled_completion_date   ),
  decode(p_project_id                  ,FND_API.G_MISS_NUM,NULL,p_project_id                  ),
  decode(p_task_id                     ,FND_API.G_MISS_NUM,NULL,p_task_id                     ),
  decode(p_maintenance_object_id       ,FND_API.G_MISS_NUM,NULL,p_maintenance_object_id       ),
  decode(p_maintenance_object_type     ,FND_API.G_MISS_NUM,NULL,p_maintenance_object_type     ),
  decode(p_maintenance_object_source   ,FND_API.G_MISS_NUM,NULL,p_maintenance_object_source   ),
  decode(p_owning_department_id        ,FND_API.G_MISS_NUM,NULL,p_owning_department_id        ),
  decode(p_user_defined_status_id      ,FND_API.G_MISS_NUM,NULL,p_user_defined_status_id      ),
  decode(p_op_seq_num                  ,FND_API.G_MISS_NUM,NULL,p_op_seq_num                  ),
  decode(p_op_description              ,FND_API.G_MISS_CHAR,NULL,p_op_description             ),
  decode(p_standard_operation_id       ,FND_API.G_MISS_NUM,NULL,p_standard_operation_id       ),
  decode(p_op_department_id            ,FND_API.G_MISS_NUM,NULL,p_op_department_id            ),
  decode(p_op_long_description         ,FND_API.G_MISS_CHAR,NULL,p_op_long_description        ),
  decode(p_res_seq_num                 ,FND_API.G_MISS_NUM,NULL,p_res_seq_num                 ),
  decode(p_res_id                      ,FND_API.G_MISS_NUM,NULL,p_res_id                      ),
  decode(p_res_uom                     ,FND_API.G_MISS_CHAR,NULL,p_res_uom                    ),
  decode(p_res_basis_type              ,FND_API.G_MISS_NUM,NULL,p_res_basis_type              ),
  decode(p_res_usage_rate_or_amount    ,FND_API.G_MISS_NUM,NULL,p_res_usage_rate_or_amount    ),
  decode(p_res_required_units          ,FND_API.G_MISS_NUM,NULL,p_res_required_units          ),
  decode(p_res_assigned_units          ,FND_API.G_MISS_NUM,NULL,p_res_assigned_units          ),
  decode(p_item_type                   ,FND_API.G_MISS_NUM,NULL,p_item_type                   ),
  decode(p_required_quantity           ,FND_API.G_MISS_NUM,NULL,p_required_quantity           ),
  decode(p_unit_price                  ,FND_API.G_MISS_NUM,NULL,p_unit_price                  ),
  decode(p_uom                         ,FND_API.G_MISS_CHAR,NULL,p_uom                        ),
  decode(p_basis_type                  ,FND_API.G_MISS_NUM,NULL,p_basis_type                  ),
  decode(p_suggested_vendor_name       ,FND_API.G_MISS_CHAR,NULL,p_suggested_vendor_name      ),
  decode(p_suggested_vendor_id         ,FND_API.G_MISS_NUM,NULL,p_suggested_vendor_id         ),
  decode(p_suggested_vendor_site       ,FND_API.G_MISS_CHAR,NULL,p_suggested_vendor_site      ),
  decode(p_suggested_vendor_site_id    ,FND_API.G_MISS_NUM,NULL,p_suggested_vendor_site_id    ),
  decode(p_mat_inventory_item_id       ,FND_API.G_MISS_NUM,NULL,p_mat_inventory_item_id       ),
  decode(p_mat_component_seq_num       ,FND_API.G_MISS_NUM,NULL,p_mat_component_seq_num       ),
  decode(p_mat_supply_subinventory     ,FND_API.G_MISS_CHAR,NULL,p_mat_supply_subinventory    ),
  decode(p_mat_supply_locator_id       ,FND_API.G_MISS_NUM,NULL,p_mat_supply_locator_id       ),
  decode(p_di_amount                   ,FND_API.G_MISS_NUM,NULL,p_di_amount                   ),
  decode(p_di_order_type_lookup_code   ,FND_API.G_MISS_CHAR,NULL,p_di_order_type_lookup_code  ),
  decode(p_di_description              ,FND_API.G_MISS_CHAR,NULL,p_di_description              ),
  decode(p_di_purchase_category_id     ,FND_API.G_MISS_NUM,NULL,p_di_purchase_category_id     ),
  decode(p_di_auto_request_material    ,FND_API.G_MISS_CHAR,NULL,p_di_auto_request_material   ),
  decode(p_di_need_by_date             ,FND_API.G_MISS_DATE,TO_DATE(NULL),p_di_need_by_date   ),
  decode(p_work_order_line_cost        ,FND_API.G_MISS_NUM,NULL,p_work_order_line_cost        ),
  decode(p_creation_date               ,FND_API.G_MISS_DATE,sysdate,sysdate     ),
  decode(p_created_by                  ,FND_API.G_MISS_NUM,NULL,p_created_by                  ),
  decode(p_last_update_date            ,FND_API.G_MISS_DATE,sysdate,sysdate  ),
  decode(p_last_updated_by             ,FND_API.G_MISS_NUM,NULL,p_last_updated_by             ),
  decode(p_last_update_login  	       ,FND_API.G_MISS_NUM,NULL,p_last_update_login           ),
  decode(p_work_order_type  	       ,FND_API.G_MISS_NUM,NULL,p_work_order_type           ),
  decode(p_activity_type  	       ,FND_API.G_MISS_NUM,NULL,p_activity_type           ),
  decode(p_activity_cause  	       ,FND_API.G_MISS_NUM,NULL,p_activity_cause           ),
  decode(p_activity_source  	       ,FND_API.G_MISS_NUM,NULL,p_activity_source           ),
  decode(p_available_qty  	       ,FND_API.G_MISS_NUM,NULL,p_available_qty           ),
  decode(p_item_comments  	       ,FND_API.G_MISS_CHAR,NULL,p_item_comments           ),
  decode(p_cu_qty  	       ,FND_API.G_MISS_NUM,NULL,p_cu_qty           ),
  decode(p_res_sch_flag  	       ,FND_API.G_MISS_NUM,NULL,p_res_sch_flag           )
);

 END IF; -- (p_estimate_id IS NOT NULL) OR (p_estimate_id <> FND_API.G_MISS_NUM)

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END INSERT_ROW;

PROCEDURE UPDATE_ROW(
  p_estimate_work_order_line_id    	NUMBER,
  p_estimate_work_order_id      NUMBER,
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
        )
IS
BEGIN
  UPDATE EAM_CE_WORK_ORDER_LINES
  SET    ESTIMATE_WORK_ORDER_ID	        = decode(p_estimate_work_order_id, FND_API.G_MISS_NUM, ESTIMATE_WORK_ORDER_ID, p_estimate_work_order_id),
         SRC_CU_ID	                    = decode(p_src_cu_id, FND_API.G_MISS_NUM, SRC_CU_ID, p_src_cu_id),
         SRC_ACTIVITY_ID                = decode(p_src_activity_id, FND_API.G_MISS_NUM, SRC_ACTIVITY_ID, p_src_activity_id),
         SRC_ACTIVITY_QTY               = decode(p_src_activity_qty, FND_API.G_MISS_NUM, SRC_ACTIVITY_QTY, p_src_activity_qty),
         SRC_OP_SEQ_NUM                 = decode(p_src_op_seq_num, FND_API.G_MISS_NUM, SRC_OP_SEQ_NUM, p_src_op_seq_num),
         SRC_ACCT_CLASS_CODE            = decode(p_src_acct_class_code, FND_API.G_MISS_CHAR, SRC_ACCT_CLASS_CODE, p_src_acct_class_code),
         SRC_DIFFICULTY_ID              = decode(p_src_diff_id ,FND_API.G_MISS_NUM,SRC_DIFFICULTY_ID,p_src_diff_id),
         DIFFICULTY_QTY                 = decode(p_diff_qty,FND_API.G_MISS_NUM,DIFFICULTY_QTY,p_diff_qty),
         ESTIMATE_ID                    = decode(p_estimate_id, FND_API.G_MISS_NUM, ESTIMATE_ID, p_estimate_id),
         ORGANIZATION_ID                = decode(p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
         WORK_ORDER_SEQ_NUM             = decode(p_work_order_seq_num, FND_API.G_MISS_NUM, WORK_ORDER_SEQ_NUM, p_work_order_seq_num),
         WORK_ORDER_NUMBER              = decode(p_work_order_number, FND_API.G_MISS_CHAR, WORK_ORDER_NUMBER, p_work_order_number),
         WORK_ORDER_DESCRIPTION         = decode(p_work_order_description, FND_API.G_MISS_CHAR, WORK_ORDER_DESCRIPTION, p_work_order_description),
         REF_WIP_ENTITY_ID              = decode(p_ref_wip_entity_id, FND_API.G_MISS_NUM, REF_WIP_ENTITY_ID, p_ref_wip_entity_id),
         PRIMARY_ITEM_ID                = decode(p_primary_item_id, FND_API.G_MISS_NUM, PRIMARY_ITEM_ID, p_primary_item_id),
         STATUS_TYPE                    = decode(p_status_type, FND_API.G_MISS_NUM, STATUS_TYPE, p_status_type),
         ACCT_CLASS_CODE                = decode(p_acct_class_code, FND_API.G_MISS_CHAR, ACCT_CLASS_CODE, p_acct_class_code),
         SCHEDULED_START_DATE           = decode(p_scheduled_start_date, FND_API.G_MISS_DATE, SCHEDULED_START_DATE, NULL, SCHEDULED_START_DATE, p_scheduled_start_date),
         SCHEDULED_COMPLETION_DATE      = decode(p_scheduled_completion_date, FND_API.G_MISS_DATE, SCHEDULED_COMPLETION_DATE, p_scheduled_completion_date),
         PROJECT_ID                     = decode(p_project_id, FND_API.G_MISS_NUM, PROJECT_ID, p_project_id),
         TASK_ID                        = decode(p_task_id, FND_API.G_MISS_NUM, TASK_ID, p_task_id),
         MAINTENANCE_OBJECT_ID          = decode(p_maintenance_object_id, FND_API.G_MISS_NUM, MAINTENANCE_OBJECT_ID, p_maintenance_object_id),
         MAINTENANCE_OBJECT_TYPE        = decode(p_maintenance_object_type, FND_API.G_MISS_NUM, MAINTENANCE_OBJECT_TYPE, p_maintenance_object_type),
         MAINTENANCE_OBJECT_SOURCE      = decode(p_maintenance_object_source, FND_API.G_MISS_NUM, MAINTENANCE_OBJECT_SOURCE, p_maintenance_object_source),
         OWNING_DEPARTMENT_ID           = decode(p_owning_department_id, FND_API.G_MISS_NUM, OWNING_DEPARTMENT_ID, p_owning_department_id),
         USER_DEFINED_STATUS_ID         = decode(p_user_defined_status_id, FND_API.G_MISS_NUM, USER_DEFINED_STATUS_ID, p_user_defined_status_id),
         OP_SEQ_NUM                     = decode(p_op_seq_num, FND_API.G_MISS_NUM, OP_SEQ_NUM, p_op_seq_num),
         OP_DESCRIPTION                 = decode(p_op_description, FND_API.G_MISS_CHAR, OP_DESCRIPTION, p_op_description),
         STANDARD_OPERATION_ID          = decode(p_standard_operation_id, FND_API.G_MISS_NUM, STANDARD_OPERATION_ID, p_standard_operation_id),
         OP_DEPARTMENT_ID               = decode(p_op_department_id, FND_API.G_MISS_NUM, OP_DEPARTMENT_ID, p_op_department_id),
         OP_LONG_DESCRIPTION            = decode(p_op_long_description, FND_API.G_MISS_CHAR, OP_LONG_DESCRIPTION, p_op_long_description),
         RES_SEQ_NUM                    = decode(p_res_seq_num, FND_API.G_MISS_NUM, RES_SEQ_NUM, p_res_seq_num),
         RES_ID                         = decode(p_res_id, FND_API.G_MISS_NUM, RES_ID, p_res_id),
         RES_UOM                        = decode(p_res_uom, FND_API.G_MISS_CHAR, RES_UOM, p_res_uom),
         RES_BASIS_TYPE                 = decode(p_res_basis_type, FND_API.G_MISS_NUM, RES_BASIS_TYPE, p_res_basis_type),
         RES_USAGE_RATE_OR_AMOUNT       = decode(p_res_usage_rate_or_amount, FND_API.G_MISS_NUM, RES_USAGE_RATE_OR_AMOUNT, p_res_usage_rate_or_amount),
         RES_REQUIRED_UNITS             = decode(p_res_required_units, FND_API.G_MISS_NUM, RES_REQUIRED_UNITS, p_res_required_units),
         RES_ASSIGNED_UNITS             = decode(p_res_assigned_units, FND_API.G_MISS_NUM, RES_ASSIGNED_UNITS, p_res_assigned_units),
         ITEM_TYPE	                = decode(p_item_type, FND_API.G_MISS_NUM, ITEM_TYPE, p_item_type),
         REQUIRED_QUANTITY              = decode(p_required_quantity, FND_API.G_MISS_NUM, REQUIRED_QUANTITY, p_required_quantity),
         UNIT_PRICE	                = decode(p_unit_price, FND_API.G_MISS_NUM, UNIT_PRICE, p_unit_price),
         UOM	                        = decode(p_uom, FND_API.G_MISS_CHAR, UOM, p_uom),
         BASIS_TYPE	                = decode(p_basis_type, FND_API.G_MISS_NUM, BASIS_TYPE, p_basis_type),
         SUGGESTED_VENDOR_NAME	        = decode(p_suggested_vendor_name, FND_API.G_MISS_CHAR, SUGGESTED_VENDOR_NAME, p_suggested_vendor_name),
         SUGGESTED_VENDOR_ID	        = decode(p_suggested_vendor_id, FND_API.G_MISS_NUM, SUGGESTED_VENDOR_ID, p_suggested_vendor_id),
         SUGGESTED_VENDOR_SITE	        = decode(p_suggested_vendor_site, FND_API.G_MISS_CHAR, SUGGESTED_VENDOR_SITE, p_suggested_vendor_site),
         SUGGESTED_VENDOR_SITE_ID	= decode(p_suggested_vendor_site_id, FND_API.G_MISS_NUM, SUGGESTED_VENDOR_SITE_ID, p_suggested_vendor_site_id),
         MAT_INVENTORY_ITEM_ID	        = decode(p_mat_inventory_item_id, FND_API.G_MISS_NUM, MAT_INVENTORY_ITEM_ID, p_mat_inventory_item_id),
         MAT_COMPONENT_SEQ_NUM	        = decode(p_mat_component_seq_num, FND_API.G_MISS_NUM, MAT_COMPONENT_SEQ_NUM, p_mat_component_seq_num),
         MAT_SUPPLY_SUBINVENTORY	= decode(p_mat_supply_subinventory, FND_API.G_MISS_CHAR, MAT_SUPPLY_SUBINVENTORY, p_mat_supply_subinventory),
         MAT_SUPPLY_LOCATOR_ID	        = decode(p_mat_supply_locator_id, FND_API.G_MISS_NUM, MAT_SUPPLY_LOCATOR_ID, p_mat_supply_locator_id),
         DI_AMOUNT 	                = decode(p_di_amount, FND_API.G_MISS_NUM, DI_AMOUNT, p_di_amount),
         DI_ORDER_TYPE_LOOKUP_CODE  	= decode(p_di_order_type_lookup_code, FND_API.G_MISS_CHAR, DI_ORDER_TYPE_LOOKUP_CODE, p_di_order_type_lookup_code),
         DI_DESCRIPTION	                = decode(p_di_description, FND_API.G_MISS_CHAR, DI_DESCRIPTION, p_di_description),
         DI_PURCHASE_CATEGORY_ID	= decode(p_di_purchase_category_id, FND_API.G_MISS_NUM, DI_PURCHASE_CATEGORY_ID, p_di_purchase_category_id),
         DI_AUTO_REQUEST_MATERIAL	= decode(p_di_auto_request_material, FND_API.G_MISS_CHAR, DI_AUTO_REQUEST_MATERIAL, p_di_auto_request_material),
         DI_NEED_BY_DATE	        = decode(p_di_need_by_date, FND_API.G_MISS_DATE, DI_NEED_BY_DATE, p_di_need_by_date),
         WO_LINE_PER_UNIT_COST           = decode(p_work_order_line_cost, FND_API.G_MISS_NUM, WO_LINE_PER_UNIT_COST, p_work_order_line_cost),
         CREATION_DATE                  = decode(p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
         CREATED_BY                     = decode(p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
         LAST_UPDATE_DATE               = decode(p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
         LAST_UPDATED_BY                = decode(p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
         LAST_UPDATE_LOGIN              = decode(p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
         WORK_ORDER_TYPE              = decode(p_work_order_type, FND_API.G_MISS_NUM, WORK_ORDER_TYPE, p_work_order_type),
         ACTIVITY_TYPE              = decode(p_activity_type, FND_API.G_MISS_NUM, ACTIVITY_TYPE, p_activity_type),
         ACTIVITY_CAUSE              = decode(p_activity_cause, FND_API.G_MISS_NUM, ACTIVITY_CAUSE, p_activity_cause),
         ACTIVITY_SOURCE              = decode(p_activity_source, FND_API.G_MISS_NUM, ACTIVITY_SOURCE, p_activity_source),
         AVAILABLE_QUANTITY              = decode(p_available_qty, FND_API.G_MISS_NUM, AVAILABLE_QUANTITY, p_available_qty),
         ITEM_COMMENTS              = decode(p_item_comments, FND_API.G_MISS_CHAR, ITEM_COMMENTS, p_item_comments),
         CU_QTY              = decode(p_cu_qty, FND_API.G_MISS_NUM, CU_QTY, p_cu_qty ),
         RES_SCHEDULED_FLAG              = decode(p_res_sch_flag, FND_API.G_MISS_NUM, RES_SCHEDULED_FLAG, p_res_sch_flag)
  WHERE ESTIMATE_WORK_ORDER_LINE_ID = p_estimate_work_order_line_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END UPDATE_ROW;

PROCEDURE DELETE_ALL_WITH_ESTIMATE_ID
(
  p_estimate_id         IN  NUMBER
)
IS
BEGIN
  DELETE FROM EAM_CE_WORK_ORDER_LINES
  WHERE ESTIMATE_ID = p_estimate_id;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END DELETE_ALL_WITH_ESTIMATE_ID;

PROCEDURE DELETE_ROW(
  p_work_order_line_id           IN  NUMBER
)
IS
BEGIN

DELETE FROM EAM_CE_WORK_ORDER_LINES
  WHERE ESTIMATE_WORK_ORDER_LINE_ID = p_work_order_line_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

END EAM_CE_WORK_ORDER_LINES_PKG;

/
