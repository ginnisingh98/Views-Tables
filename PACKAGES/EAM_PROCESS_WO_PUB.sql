--------------------------------------------------------
--  DDL for Package EAM_PROCESS_WO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PROCESS_WO_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPWOPS.pls 120.10.12010000.15 2012/06/27 14:40:39 rsandepo ship $ */
/*#
 * This package is used for creation of asset maintenance work order (Single/Multiple)
 * @rep:scope public
 * @rep:product EAM
 * @rep:displayname Asset Maintenance Work Order Creation
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY EAM_WORK_ORDER
 */

/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMPWOPS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_PROCESS_WO_PUB
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

        g_debug_flag            VARCHAR2(1) := 'N';

-- Copied over the following 4 global variables from the eam_process_wo_pvt package.
    G_OPR_SYNC          CONSTANT    NUMBER := 0;
    G_OPR_CREATE        CONSTANT    NUMBER := 1;
    G_OPR_UPDATE        CONSTANT    NUMBER := 2;
    G_OPR_DELETE        CONSTANT    NUMBER := 3;
    G_OPR_COMPLETE      CONSTANT    NUMBER := 4;
    G_OPR_UNCOMPLETE    CONSTANT    NUMBER := 5;


Type eam_wo_relations_rec_type is record
        ( BATCH_ID                      NUMBER          :=null,
          WO_RELATIONSHIP_ID            NUMBER          :=null,
          PARENT_OBJECT_ID              NUMBER          :=null,
          PARENT_OBJECT_TYPE_ID         NUMBER          :=null,
          PARENT_HEADER_ID              NUMBER          :=null,
          CHILD_OBJECT_ID               NUMBER          :=null,
          CHILD_OBJECT_TYPE_ID          NUMBER          :=null,
          CHILD_HEADER_ID               NUMBER          :=null,
          PARENT_RELATIONSHIP_TYPE      NUMBER          :=null,
          RELATIONSHIP_STATUS           NUMBER          :=null,
          TOP_LEVEL_OBJECT_ID           NUMBER          :=null,
          TOP_LEVEL_OBJECT_TYPE_ID      NUMBER          :=null,
          TOP_LEVEL_HEADER_ID           NUMBER          :=null,
          ADJUST_PARENT                 VARCHAR2(1)     :=null,
          RETURN_STATUS                 VARCHAR2(1)     :=null,
          TRANSACTION_TYPE              NUMBER          :=null,
          ROW_ID                        NUMBER          :=null
        );

Type header_id_rec_type is record
        ( HEADER_ID                     NUMBER          :=null
        );

	failure_entry_record_typ_null  eam_process_failure_entry_pub.eam_failure_entry_record_typ;
	/* Failure Entry Project */



Type eam_wo_rec_type is record
        ( HEADER_ID                     NUMBER          :=null,
          BATCH_ID                      NUMBER          :=null,
          ROW_ID                        NUMBER          :=null,
          WIP_ENTITY_NAME               VARCHAR2(240)   :=null,
          WIP_ENTITY_ID                 NUMBER          :=null,
          ORGANIZATION_ID               NUMBER          :=null,
          DESCRIPTION                   VARCHAR2(240)   :=null,
          ASSET_NUMBER                  VARCHAR2(30)    :=null,
          ASSET_GROUP_ID                NUMBER          :=null,
          REBUILD_ITEM_ID               NUMBER          :=null,
          REBUILD_SERIAL_NUMBER         VARCHAR2(30)    :=null,
          MAINTENANCE_OBJECT_ID         NUMBER          :=null,
          MAINTENANCE_OBJECT_TYPE       NUMBER          :=null,
          MAINTENANCE_OBJECT_SOURCE     NUMBER          :=null,
          EAM_LINEAR_LOCATION_ID        NUMBER          :=null,
          CLASS_CODE                    VARCHAR2(10)    :=null,
          ASSET_ACTIVITY_ID             NUMBER          :=null,
          ACTIVITY_TYPE                 VARCHAR2(30)    :=null,
          ACTIVITY_CAUSE                VARCHAR2(30)    :=null,
          ACTIVITY_SOURCE               VARCHAR2(30)    :=null,
          WORK_ORDER_TYPE               VARCHAR2(30)    :=null,
          STATUS_TYPE                   NUMBER          :=null,
          JOB_QUANTITY                  NUMBER          :=null,
          DATE_RELEASED                 DATE            :=null,
          OWNING_DEPARTMENT             NUMBER          :=null,
          PRIORITY                      NUMBER          :=null,
          REQUESTED_START_DATE          DATE            :=null,
          DUE_DATE                      DATE            :=null,
          SHUTDOWN_TYPE                 VARCHAR2(30)    :=null,
          FIRM_PLANNED_FLAG             NUMBER          :=null,
          NOTIFICATION_REQUIRED         VARCHAR2(1)     :=null,
          TAGOUT_REQUIRED               VARCHAR2(1)     :=null,
          PLAN_MAINTENANCE              VARCHAR2(1)     :=null,
          PROJECT_ID                    NUMBER          :=null,
          TASK_ID                       NUMBER          :=null,
          --PROJECT_COSTED                NUMBER          :=null,
          END_ITEM_UNIT_NUMBER          VARCHAR2(30)    :=null,
          SCHEDULE_GROUP_ID             NUMBER          :=null,
          BOM_REVISION_DATE             DATE            :=null,
          ROUTING_REVISION_DATE         DATE            :=null,
          ALTERNATE_ROUTING_DESIGNATOR  VARCHAR2(10)    :=null,
          ALTERNATE_BOM_DESIGNATOR      VARCHAR2(10)    :=null,
          ROUTING_REVISION              VARCHAR2(3)     :=null,
          BOM_REVISION                  VARCHAR2(3)     :=null,
          PARENT_WIP_ENTITY_ID          NUMBER          :=null,
          MANUAL_REBUILD_FLAG           VARCHAR2(1)     :=null,
          PM_SCHEDULE_ID                NUMBER          :=null,
          WIP_SUPPLY_TYPE               NUMBER          :=null,
          MATERIAL_ACCOUNT              NUMBER          :=null,
          MATERIAL_OVERHEAD_ACCOUNT     NUMBER          :=null,
          RESOURCE_ACCOUNT              NUMBER          :=null,
          OUTSIDE_PROCESSING_ACCOUNT    NUMBER          :=null,
          MATERIAL_VARIANCE_ACCOUNT     NUMBER          :=null,
          RESOURCE_VARIANCE_ACCOUNT     NUMBER          :=null,
          OUTSIDE_PROC_VARIANCE_ACCOUNT NUMBER          :=null,
          STD_COST_ADJUSTMENT_ACCOUNT   NUMBER          :=null,
          OVERHEAD_ACCOUNT              NUMBER          :=null,
          OVERHEAD_VARIANCE_ACCOUNT     NUMBER          :=null,
          SCHEDULED_START_DATE          DATE            :=null,
          SCHEDULED_COMPLETION_DATE     DATE            :=null,
          PM_SUGGESTED_START_DATE       DATE            :=null,
          PM_SUGGESTED_END_DATE         DATE            :=null,
          PM_BASE_METER_READING         NUMBER          :=null,
          PM_BASE_METER                 NUMBER          :=null,
          COMMON_BOM_SEQUENCE_ID        NUMBER          :=null,
          COMMON_ROUTING_SEQUENCE_ID    NUMBER          :=null,
          PO_CREATION_TIME              NUMBER          :=null,
          GEN_OBJECT_ID                 NUMBER          :=null,
	  USER_DEFINED_STATUS_ID	NUMBER          :=null,
	  PENDING_FLAG			VARCHAR2(1)     :=null,
	  MATERIAL_SHORTAGE_CHECK_DATE	DATE            :=null,
	  MATERIAL_SHORTAGE_FLAG	NUMBER          :=null,
	  WORKFLOW_TYPE			NUMBER          :=null,
	  WARRANTY_CLAIM_STATUS		NUMBER          :=null,
	  CYCLE_ID			NUMBER          :=null,
	  SEQ_ID			NUMBER          :=null,
	  DS_SCHEDULED_FLAG		VARCHAR2(1)     :=null,
	  WARRANTY_ACTIVE		NUMBER		:=null,
	  ASSIGNMENT_COMPLETE		VARCHAR2(1)     :=null,
          ATTRIBUTE_CATEGORY            VARCHAR2(30)    :=null,
          ATTRIBUTE1                    VARCHAR2(150)   :=null,
          ATTRIBUTE2                    VARCHAR2(150)   :=null,
          ATTRIBUTE3                    VARCHAR2(150)   :=null,
          ATTRIBUTE4                    VARCHAR2(150)   :=null,
          ATTRIBUTE5                    VARCHAR2(150)   :=null,
          ATTRIBUTE6                    VARCHAR2(150)   :=null,
          ATTRIBUTE7                    VARCHAR2(150)   :=null,
          ATTRIBUTE8                    VARCHAR2(150)   :=null,
          ATTRIBUTE9                    VARCHAR2(150)   :=null,
          ATTRIBUTE10                   VARCHAR2(150)   :=null,
          ATTRIBUTE11                   VARCHAR2(150)   :=null,
          ATTRIBUTE12                   VARCHAR2(150)   :=null,
          ATTRIBUTE13                   VARCHAR2(150)   :=null,
          ATTRIBUTE14                   VARCHAR2(150)   :=null,
          ATTRIBUTE15                   VARCHAR2(150)   :=null,
          MATERIAL_ISSUE_BY_MO          VARCHAR2(1)     :=null,
          ISSUE_ZERO_COST_FLAG          VARCHAR2(1)     :=null,
	  REPORT_TYPE             NUMBER        :=  null,
          ACTUAL_CLOSE_DATE       DATE     := null,
          SUBMISSION_DATE             DATE     := null,
          USER_ID                       NUMBER          :=null,
          RESPONSIBILITY_ID             NUMBER          :=null,
          REQUEST_ID                    NUMBER          :=null,
          PROGRAM_ID                    NUMBER          :=null,
          PROGRAM_APPLICATION_ID        NUMBER          :=null,
          SOURCE_LINE_ID                NUMBER          :=null,
          SOURCE_CODE                   VARCHAR2(30)    :=null,
	  VALIDATE_STRUCTURE		VARCHAR2(1)	:='N', -- added for bug# 3544860
          RETURN_STATUS                 VARCHAR2(1)     :=null,
          TRANSACTION_TYPE              NUMBER          :=null,
	  FAILURE_CODE_REQUIRED         VARCHAR2(1)     :=null,
          eam_failure_entry_record      eam_process_failure_entry_pub.eam_failure_entry_record_typ,
          eam_failure_codes_tbl         eam_process_failure_entry_pub.eam_failure_codes_tbl_typ
        );


Type eam_op_rec_type is record
        ( HEADER_ID                     NUMBER          :=null,
          BATCH_ID                      NUMBER          :=null,
          ROW_ID                        NUMBER          :=null,
          WIP_ENTITY_ID                 NUMBER          :=null,
          ORGANIZATION_ID               NUMBER          :=null,
          OPERATION_SEQ_NUM             NUMBER          :=null,
          STANDARD_OPERATION_ID         NUMBER          :=null,
          DEPARTMENT_ID                 NUMBER          :=null,
          OPERATION_SEQUENCE_ID         NUMBER          :=null,
          DESCRIPTION                   VARCHAR2(240)   :=null,
          MINIMUM_TRANSFER_QUANTITY     NUMBER          :=null,
          COUNT_POINT_TYPE              NUMBER          :=null,
          BACKFLUSH_FLAG                NUMBER          :=null,
          SHUTDOWN_TYPE                 VARCHAR2(30)    :=null,
          START_DATE                    DATE            :=null,
          COMPLETION_DATE               DATE            :=null,
          ATTRIBUTE_CATEGORY            VARCHAR2(30)    :=null,
          ATTRIBUTE1                    VARCHAR2(150)   :=null,
          ATTRIBUTE2                    VARCHAR2(150)   :=null,
          ATTRIBUTE3                    VARCHAR2(150)   :=null,
          ATTRIBUTE4                    VARCHAR2(150)   :=null,
          ATTRIBUTE5                    VARCHAR2(150)   :=null,
          ATTRIBUTE6                    VARCHAR2(150)   :=null,
          ATTRIBUTE7                    VARCHAR2(150)   :=null,
          ATTRIBUTE8                    VARCHAR2(150)   :=null,
          ATTRIBUTE9                    VARCHAR2(150)   :=null,
          ATTRIBUTE10                   VARCHAR2(150)   :=null,
          ATTRIBUTE11                   VARCHAR2(150)   :=null,
          ATTRIBUTE12                   VARCHAR2(150)   :=null,
          ATTRIBUTE13                   VARCHAR2(150)   :=null,
          ATTRIBUTE14                   VARCHAR2(150)   :=null,
          ATTRIBUTE15                   VARCHAR2(150)   :=null,
          LONG_DESCRIPTION              VARCHAR2(4000)  :=null,
          REQUEST_ID                    NUMBER          :=null,
          PROGRAM_APPLICATION_ID        NUMBER          :=null,
          PROGRAM_ID                    NUMBER          :=null,
          RETURN_STATUS                 VARCHAR2(1)     :=null,
          TRANSACTION_TYPE              NUMBER          :=null ,
	  X_POS                         NUMBER          :=null,   	 --Added X_POS and Y_POS for bug#4615678
 	  Y_POS                         NUMBER          :=null
          );


Type eam_op_network_rec_type is record
        ( HEADER_ID                     NUMBER          :=null,
          BATCH_ID                      NUMBER          :=null,
          ROW_ID                        NUMBER          :=null,
          WIP_ENTITY_ID                 NUMBER          :=null,
          ORGANIZATION_ID               NUMBER          :=null,
          PRIOR_OPERATION               NUMBER          :=null,
          NEXT_OPERATION                NUMBER          :=null,
          ATTRIBUTE_CATEGORY            VARCHAR2(30)    :=null,
          ATTRIBUTE1                    VARCHAR2(150)   :=null,
          ATTRIBUTE2                    VARCHAR2(150)   :=null,
          ATTRIBUTE3                    VARCHAR2(150)   :=null,
          ATTRIBUTE4                    VARCHAR2(150)   :=null,
          ATTRIBUTE5                    VARCHAR2(150)   :=null,
          ATTRIBUTE6                    VARCHAR2(150)   :=null,
          ATTRIBUTE7                    VARCHAR2(150)   :=null,
          ATTRIBUTE8                    VARCHAR2(150)   :=null,
          ATTRIBUTE9                    VARCHAR2(150)   :=null,
          ATTRIBUTE10                   VARCHAR2(150)   :=null,
          ATTRIBUTE11                   VARCHAR2(150)   :=null,
          ATTRIBUTE12                   VARCHAR2(150)   :=null,
          ATTRIBUTE13                   VARCHAR2(150)   :=null,
          ATTRIBUTE14                   VARCHAR2(150)   :=null,
          ATTRIBUTE15                   VARCHAR2(150)   :=null,
          RETURN_STATUS                 VARCHAR2(1)     :=null,
          TRANSACTION_TYPE              NUMBER          :=null
          );


Type eam_res_rec_type is record
        ( HEADER_ID                     NUMBER          :=null,
          BATCH_ID                      NUMBER          :=null,
          ROW_ID                        NUMBER          :=null,
          WIP_ENTITY_ID                 NUMBER          :=null,
          ORGANIZATION_ID               NUMBER          :=null,
          OPERATION_SEQ_NUM             NUMBER          :=null,
          RESOURCE_SEQ_NUM              NUMBER          :=null,
          RESOURCE_ID                   NUMBER          :=null,
          UOM_CODE                      VARCHAR2(3)     :=null,
          BASIS_TYPE                    NUMBER          :=null,
          USAGE_RATE_OR_AMOUNT          NUMBER          :=null,
          ACTIVITY_ID                   NUMBER          :=null,
          SCHEDULED_FLAG                NUMBER          :=null,
	  FIRM_FLAG			NUMBER          :=null,
          ASSIGNED_UNITS                NUMBER          :=null,
	  MAXIMUM_ASSIGNED_UNITS        NUMBER          :=null,
          AUTOCHARGE_TYPE               NUMBER          :=null,
          STANDARD_RATE_FLAG            NUMBER          :=null,
          APPLIED_RESOURCE_UNITS        NUMBER          :=null,
          APPLIED_RESOURCE_VALUE        NUMBER          :=null,
          START_DATE                    DATE            :=null,
          COMPLETION_DATE               DATE            :=null,
          SCHEDULE_SEQ_NUM              NUMBER          :=null,
          SUBSTITUTE_GROUP_NUM          NUMBER          :=null,
          REPLACEMENT_GROUP_NUM         NUMBER          :=null,
          ATTRIBUTE_CATEGORY            VARCHAR2(30)    :=null,
          ATTRIBUTE1                    VARCHAR2(150)   :=null,
          ATTRIBUTE2                    VARCHAR2(150)   :=null,
          ATTRIBUTE3                    VARCHAR2(150)   :=null,
          ATTRIBUTE4                    VARCHAR2(150)   :=null,
          ATTRIBUTE5                    VARCHAR2(150)   :=null,
          ATTRIBUTE6                    VARCHAR2(150)   :=null,
          ATTRIBUTE7                    VARCHAR2(150)   :=null,
          ATTRIBUTE8                    VARCHAR2(150)   :=null,
          ATTRIBUTE9                    VARCHAR2(150)   :=null,
          ATTRIBUTE10                   VARCHAR2(150)   :=null,
          ATTRIBUTE11                   VARCHAR2(150)   :=null,
          ATTRIBUTE12                   VARCHAR2(150)   :=null,
          ATTRIBUTE13                   VARCHAR2(150)   :=null,
          ATTRIBUTE14                   VARCHAR2(150)   :=null,
          ATTRIBUTE15                   VARCHAR2(150)   :=null,
          DEPARTMENT_ID                 NUMBER          :=null,
          REQUEST_ID                    NUMBER          :=null,
          PROGRAM_APPLICATION_ID        NUMBER          :=null,
          PROGRAM_ID                    NUMBER          :=null,
          PROGRAM_UPDATE_DATE           DATE            :=null,
          RETURN_STATUS                 VARCHAR2(1)     :=null,
          TRANSACTION_TYPE              NUMBER          :=null
          );

Type eam_res_inst_rec_type is record
        ( HEADER_ID                     NUMBER          :=null,
          BATCH_ID                      NUMBER          :=null,
          ROW_ID                        NUMBER          :=null,
          WIP_ENTITY_ID                 NUMBER          :=null,
          ORGANIZATION_ID               NUMBER          :=null,
          OPERATION_SEQ_NUM             NUMBER          :=null,
          RESOURCE_SEQ_NUM              NUMBER          :=null,
          INSTANCE_ID                   NUMBER          :=null,
          SERIAL_NUMBER                 VARCHAR2(30)    :=null,
          START_DATE                    DATE            :=null,
          COMPLETION_DATE               DATE            :=null,
          TOP_LEVEL_BATCH_ID            NUMBER          :=null,
          RETURN_STATUS                 VARCHAR2(1)     :=null,
          TRANSACTION_TYPE              NUMBER          :=null
          );


Type eam_sub_res_rec_type is record
        ( HEADER_ID                     NUMBER          :=null,
          BATCH_ID                      NUMBER          :=null,
          ROW_ID                        NUMBER          :=null,
          WIP_ENTITY_ID                 NUMBER          :=null,
          ORGANIZATION_ID               NUMBER          :=null,
          OPERATION_SEQ_NUM             NUMBER          :=null,
          RESOURCE_SEQ_NUM              NUMBER          :=null,
          RESOURCE_ID                   NUMBER          :=null,
          UOM_CODE                      VARCHAR2(3)     :=null,
          BASIS_TYPE                    NUMBER          :=null,
          USAGE_RATE_OR_AMOUNT          NUMBER          :=null,
          ACTIVITY_ID                   NUMBER          :=null,
          SCHEDULED_FLAG                NUMBER          :=null,
          ASSIGNED_UNITS                NUMBER          :=null,
          AUTOCHARGE_TYPE               NUMBER          :=null,
          STANDARD_RATE_FLAG            NUMBER          :=null,
          APPLIED_RESOURCE_UNITS        NUMBER          :=null,
          APPLIED_RESOURCE_VALUE        NUMBER          :=null,
          START_DATE                    DATE            :=null,
          COMPLETION_DATE               DATE            :=null,
          SCHEDULE_SEQ_NUM              NUMBER          :=null,
          SUBSTITUTE_GROUP_NUM          NUMBER          :=null,
          REPLACEMENT_GROUP_NUM         NUMBER          :=null,
          ATTRIBUTE_CATEGORY            VARCHAR2(30)    :=null,
          ATTRIBUTE1                    VARCHAR2(150)   :=null,
          ATTRIBUTE2                    VARCHAR2(150)   :=null,
          ATTRIBUTE3                    VARCHAR2(150)   :=null,
          ATTRIBUTE4                    VARCHAR2(150)   :=null,
          ATTRIBUTE5                    VARCHAR2(150)   :=null,
          ATTRIBUTE6                    VARCHAR2(150)   :=null,
          ATTRIBUTE7                    VARCHAR2(150)   :=null,
          ATTRIBUTE8                    VARCHAR2(150)   :=null,
          ATTRIBUTE9                    VARCHAR2(150)   :=null,
          ATTRIBUTE10                   VARCHAR2(150)   :=null,
          ATTRIBUTE11                   VARCHAR2(150)   :=null,
          ATTRIBUTE12                   VARCHAR2(150)   :=null,
          ATTRIBUTE13                   VARCHAR2(150)   :=null,
          ATTRIBUTE14                   VARCHAR2(150)   :=null,
          ATTRIBUTE15                   VARCHAR2(150)   :=null,
          DEPARTMENT_ID                 NUMBER          :=null,
          REQUEST_ID                    NUMBER          :=null,
          PROGRAM_APPLICATION_ID        NUMBER          :=null,
          PROGRAM_ID                    NUMBER          :=null,
          PROGRAM_UPDATE_DATE           DATE            :=null,
          RETURN_STATUS                 VARCHAR2(1)     :=null,
          TRANSACTION_TYPE              NUMBER          :=null
          );

Type eam_res_usage_rec_type is record
        ( HEADER_ID                     NUMBER          :=null,
          BATCH_ID                      NUMBER          :=null,
          ROW_ID                        NUMBER          :=null,
          WIP_ENTITY_ID                 NUMBER          :=null,
          OPERATION_SEQ_NUM             NUMBER          :=null,
          RESOURCE_SEQ_NUM              NUMBER          :=null,
          ORGANIZATION_ID               NUMBER          :=null,
          START_DATE                    DATE            :=null,
          COMPLETION_DATE               DATE            :=null,
	  OLD_START_DATE                DATE            :=null,
	  OLD_COMPLETION_DATE           DATE            :=null,
          ASSIGNED_UNITS                NUMBER          :=null,
          REQUEST_ID                    NUMBER          :=null,
          PROGRAM_APPLICATION_ID        NUMBER          :=null,
          PROGRAM_ID                    NUMBER          :=null,
          PROGRAM_UPDATE_DATE           DATE            :=null,
          INSTANCE_ID                   NUMBER          :=null,
          SERIAL_NUMBER                 VARCHAR2(30)    :=null,
          RETURN_STATUS                 VARCHAR2(1)     :=null,
          TRANSACTION_TYPE              NUMBER          :=null
          );


Type eam_mat_req_rec_type is record
        ( HEADER_ID                     NUMBER          :=null,
          BATCH_ID                      NUMBER          :=null,
          ROW_ID                        NUMBER          :=null,
          WIP_ENTITY_ID                 NUMBER          :=null,
          ORGANIZATION_ID               NUMBER          :=null,
          OPERATION_SEQ_NUM             NUMBER          :=null,
          INVENTORY_ITEM_ID             NUMBER          :=null,
          QUANTITY_PER_ASSEMBLY         NUMBER          :=null,
          DEPARTMENT_ID                 NUMBER          :=null,
          WIP_SUPPLY_TYPE               NUMBER          :=null,
          DATE_REQUIRED                 DATE            :=null,
          REQUIRED_QUANTITY             NUMBER          :=null,
	  --fix for 3550864.added the following column
             REQUESTED_QUANTITY            NUMBER          :=null,
	   --fix for 3572280
	   RELEASED_QUANTITY             NUMBER         := null,
          QUANTITY_ISSUED               NUMBER          :=null,
          SUPPLY_SUBINVENTORY           VARCHAR2(10)    :=null,
          SUPPLY_LOCATOR_ID             NUMBER          :=null,
          MRP_NET_FLAG                  NUMBER          :=null,
          MPS_REQUIRED_QUANTITY         NUMBER          :=null,
          MPS_DATE_REQUIRED             DATE            :=null,
          COMPONENT_SEQUENCE_ID         NUMBER          :=null,
          COMMENTS                      VARCHAR2(240)   :=null,
          ATTRIBUTE_CATEGORY            VARCHAR2(30)    :=null,
          ATTRIBUTE1                    VARCHAR2(150)   :=null,
          ATTRIBUTE2                    VARCHAR2(150)   :=null,
          ATTRIBUTE3                    VARCHAR2(150)   :=null,
          ATTRIBUTE4                    VARCHAR2(150)   :=null,
          ATTRIBUTE5                    VARCHAR2(150)   :=null,
          ATTRIBUTE6                    VARCHAR2(150)   :=null,
          ATTRIBUTE7                    VARCHAR2(150)   :=null,
          ATTRIBUTE8                    VARCHAR2(150)   :=null,
          ATTRIBUTE9                    VARCHAR2(150)   :=null,
          ATTRIBUTE10                   VARCHAR2(150)   :=null,
          ATTRIBUTE11                   VARCHAR2(150)   :=null,
          ATTRIBUTE12                   VARCHAR2(150)   :=null,
          ATTRIBUTE13                   VARCHAR2(150)   :=null,
          ATTRIBUTE14                   VARCHAR2(150)   :=null,
          ATTRIBUTE15                   VARCHAR2(150)   :=null,
          AUTO_REQUEST_MATERIAL         VARCHAR2(1)     :=null,
          SUGGESTED_VENDOR_NAME         VARCHAR2(240)   :=null,
          VENDOR_ID                     NUMBER          :=null,
          UNIT_PRICE                    NUMBER          :=null,
          REQUEST_ID                    NUMBER          :=null,
          PROGRAM_APPLICATION_ID        NUMBER          :=null,
          PROGRAM_ID                    NUMBER          :=null,
          PROGRAM_UPDATE_DATE           DATE            :=null,
          RETURN_STATUS                 VARCHAR2(1)     :=null,
          TRANSACTION_TYPE              NUMBER          :=null,
		  INVOKE_ALLOCATIONS_API        VARCHAR2(1)     := null
          );



Type eam_direct_items_rec_type is record
(
          HEADER_ID                     NUMBER          :=null,
          BATCH_ID                      NUMBER          :=null,
          ROW_ID                        NUMBER          :=null,
          DESCRIPTION                   VARCHAR2(240)   :=null,
          PURCHASING_CATEGORY_ID        NUMBER          :=null,
          DIRECT_ITEM_SEQUENCE_ID       NUMBER          :=null,
          OPERATION_SEQ_NUM             NUMBER          :=null,
          DEPARTMENT_ID                 NUMBER          :=null,
          WIP_ENTITY_ID                 NUMBER          :=null,
          ORGANIZATION_ID               NUMBER          :=null,
          SUGGESTED_VENDOR_NAME	        VARCHAR2(240)   :=null,
          SUGGESTED_VENDOR_ID           NUMBER          :=null,
          SUGGESTED_VENDOR_SITE	        VARCHAR2(15)    :=null,
          SUGGESTED_VENDOR_SITE_ID      NUMBER          :=null,
          SUGGESTED_VENDOR_CONTACT      VARCHAR2(80)    :=null,
          SUGGESTED_VENDOR_CONTACT_ID   NUMBER          :=null,
          SUGGESTED_VENDOR_PHONE        VARCHAR2(20)    :=null,
          SUGGESTED_VENDOR_ITEM_NUM     VARCHAR2(25)    :=null,
          UNIT_PRICE                    NUMBER          :=null,
          AUTO_REQUEST_MATERIAL	        VARCHAR2(1)     :=null,
          REQUIRED_QUANTITY             NUMBER          :=null,
	  --fix for 3550864.added the following column
             REQUESTED_QUANTITY            NUMBER          :=null,
          UOM                           VARCHAR2(3)     :=null,
          NEED_BY_DATE                  DATE            :=null,
          ATTRIBUTE_CATEGORY            VARCHAR2(30)    :=null,
          ATTRIBUTE1                    VARCHAR2(150)   :=null,
          ATTRIBUTE2                    VARCHAR2(150)   :=null,
          ATTRIBUTE3                    VARCHAR2(150)   :=null,
          ATTRIBUTE4                    VARCHAR2(150)   :=null,
          ATTRIBUTE5                    VARCHAR2(150)   :=null,
          ATTRIBUTE6                    VARCHAR2(150)   :=null,
          ATTRIBUTE7                    VARCHAR2(150)   :=null,
          ATTRIBUTE8                    VARCHAR2(150)   :=null,
          ATTRIBUTE9                    VARCHAR2(150)   :=null,
          ATTRIBUTE10                   VARCHAR2(150)   :=null,
          ATTRIBUTE11                   VARCHAR2(150)   :=null,
          ATTRIBUTE12                   VARCHAR2(150)   :=null,
          ATTRIBUTE13                   VARCHAR2(150)   :=null,
          ATTRIBUTE14                   VARCHAR2(150)   :=null,
          ATTRIBUTE15                   VARCHAR2(150)   :=null,
          PROGRAM_APPLICATION_ID        NUMBER          :=null,
          PROGRAM_ID                    NUMBER          :=null,
          PROGRAM_UPDATE_DATE           DATE            :=null,
          REQUEST_ID                    NUMBER          :=null,
          RETURN_STATUS                 VARCHAR2(1)     :=null,
          TRANSACTION_TYPE              NUMBER          :=null
);

Type eam_wo_comp_rec_type is record
(
	HEADER_ID    			NUMBER         :=null,
	BATCH_ID                    	NUMBER         :=null,
	ROW_ID                       	NUMBER         :=null,
	TRANSACTION_ID 			NUMBER         :=null,
	TRANSACTION_DATE 		DATE           :=null,
	WIP_ENTITY_ID		    	NUMBER         :=null,
	USER_STATUS_ID			NUMBER	       :=null,
	WIP_ENTITY_NAME                 VARCHAR2(240)  :=null,
	ORGANIZATION_ID			NUMBER         :=null,
	PARENT_WIP_ENTITY_ID  		NUMBER         :=null,
	REFERENCE			VARCHAR2(240)  :=null,
	RECONCILIATION_CODE		VARCHAR2(30)   :=null,
	ACCT_PERIOD_ID			NUMBER         :=null,
	QA_COLLECTION_ID		NUMBER         :=null,
	ACTUAL_START_DATE		DATE           :=null,
	ACTUAL_END_DATE			DATE           :=null,
	ACTUAL_DURATION			NUMBER         :=null,
	PRIMARY_ITEM_ID			NUMBER         :=null,
	ASSET_GROUP_ID			NUMBER         :=null,
	REBUILD_ITEM_ID			NUMBER         :=null,
	ASSET_NUMBER			VARCHAR2(30)   :=null,
	REBUILD_SERIAL_NUMBER		VARCHAR2(30)   :=null,
	MANUAL_REBUILD_FLAG		VARCHAR2(1)   :=null,
	REBUILD_JOB                   	VARCHAR2(1)    :=null,
	COMPLETION_SUBINVENTORY		VARCHAR2(10)   :=null,
	COMPLETION_LOCATOR_ID		NUMBER         :=null,
	LOT_NUMBER			VARCHAR2(80)   :=null,
	SHUTDOWN_START_DATE           	DATE           :=null,
	SHUTDOWN_END_DATE            	DATE           :=null,
	ATTRIBUTE_CATEGORY        	VARCHAR2(30)   :=null,
	ATTRIBUTE1			VARCHAR2(150)  :=null,
	ATTRIBUTE2		        VARCHAR2(150)  :=null,
	ATTRIBUTE3			VARCHAR2(150)  :=null,
	ATTRIBUTE4                   	VARCHAR2(150)  :=null,
	ATTRIBUTE5			VARCHAR2(150)  :=null,
	ATTRIBUTE6			VARCHAR2(150)  :=null,
	ATTRIBUTE7                	VARCHAR2(150)  :=null,
	ATTRIBUTE8			VARCHAR2(150)  :=null,
	ATTRIBUTE9			VARCHAR2(150)  :=null,
	ATTRIBUTE10			VARCHAR2(150)  :=null,
	ATTRIBUTE11                	VARCHAR2(150)  :=null,
	ATTRIBUTE12			VARCHAR2(150)  :=null,
	ATTRIBUTE13                	VARCHAR2(150)  :=null,
	ATTRIBUTE14			VARCHAR2(150)  :=null,
	ATTRIBUTE15			VARCHAR2(150)  :=null,
	REQUEST_ID                 	NUMBER	       :=null,
	PROGRAM_UPDATE_DATE  		DATE	       :=null,
	PROGRAM_APPLICATION_ID	  	NUMBER	       :=null,
	PROGRAM_ID                  	NUMBER	       :=null,
	RETURN_STATUS         		VARCHAR2(1)    :=null,
	TRANSACTION_TYPE		NUMBER	       :=null,
        eam_failure_entry_record      eam_process_failure_entry_pub.eam_failure_entry_record_typ,
        eam_failure_codes_tbl         eam_process_failure_entry_pub.eam_failure_codes_tbl_typ

);

Type eam_op_comp_rec_type is record
(
	HEADER_ID    			NUMBER	       :=null,
	BATCH_ID                    	NUMBER	       :=null,
	ROW_ID                       	NUMBER	       :=null,
	TRANSACTION_ID 			NUMBER	       :=null,
	TRANSACTION_DATE 		DATE	       :=null,
	WIP_ENTITY_ID			NUMBER	       :=null,
	ORGANIZATION_ID			NUMBER	       :=null,
	OPERATION_SEQ_NUM   		NUMBER	       :=null,
	DEPARTMENT_ID 			NUMBER	       :=null,
	REFERENCE			VARCHAR2(240)  :=null,
	RECONCILIATION_CODE		VARCHAR2(30)   :=null,
	ACCT_PERIOD_ID			NUMBER	       :=null,
	QA_COLLECTION_ID		NUMBER	       :=null,
	ACTUAL_START_DATE		DATE	       :=null,
	ACTUAL_END_DATE			DATE 	       :=null,
	ACTUAL_DURATION			NUMBER	       :=null,
	SHUTDOWN_START_DATE		DATE	       :=null,
	SHUTDOWN_END_DATE		DATE	       :=null,
	HANDOVER_OPERATION_SEQ_NUM	NUMBER	       :=null,
	REASON_ID			NUMBER	       :=null,
	VENDOR_CONTACT_ID		NUMBER	       :=null,
	VENDOR_ID			NUMBER	       :=null,
	VENDOR_SITE_ID			NUMBER	       :=null,
	TRANSACTION_REFERENCE		VARCHAR2(240)  :=null,
	ATTRIBUTE_CATEGORY        	VARCHAR2(30)   :=null,
	ATTRIBUTE1			VARCHAR2(150)  :=null,
	ATTRIBUTE2		     	VARCHAR2(150)  :=null,
	ATTRIBUTE3			VARCHAR2(150)  :=null,
	ATTRIBUTE4			VARCHAR2(150)  :=null,
	ATTRIBUTE5		 	VARCHAR2(150)  :=null,
	ATTRIBUTE6			VARCHAR2(150)  :=null,
	ATTRIBUTE7			VARCHAR2(150)  :=null,
	ATTRIBUTE8		  	VARCHAR2(150)  :=null,
	ATTRIBUTE9		 	VARCHAR2(150)  :=null,
	ATTRIBUTE10		        VARCHAR2(150)  :=null,
	ATTRIBUTE11			VARCHAR2(150)  :=null,
	ATTRIBUTE12			VARCHAR2(150)  :=null,
	ATTRIBUTE13			VARCHAR2(150)  :=null,
	ATTRIBUTE14			VARCHAR2(150)  :=null,
	ATTRIBUTE15			VARCHAR2(150)  :=null,
	REQUEST_ID			NUMBER         :=null,
	PROGRAM_UPDATE_DATE		DATE           :=null,
	PROGRAM_APPLICATION_ID		NUMBER         :=null,
	PROGRAM_ID			NUMBER         :=null,
	RETURN_STATUS			VARCHAR2(1)    :=null,
	TRANSACTION_TYPE		NUMBER         :=null
);

Type eam_wo_quality_rec_type is record
(
	HEADER_ID    			NUMBER         :=null,
	BATCH_ID                    	NUMBER         :=null,
	ROW_ID                       	NUMBER         :=null,
	WIP_ENTITY_ID			NUMBER         :=null,
	ORGANIZATION_ID			NUMBER         :=null,
	OPERATION_SEQ_NUMBER		NUMBER         :=null,
	PLAN_ID 			NUMBER         :=null,
	SPEC_ID 		 	NUMBER         :=null,
	P_ENABLE_FLAG			NUMBER         :=null,
	ELEMENT_ID			NUMBER         :=null,
	ELEMENT_VALUE			VARCHAR2(2000) :=null,
	ELEMENT_VALIDATION_FLAG         VARCHAR2(100)  :=null,
	TRANSACTION_NUMBER		NUMBER         :=null,
	COLLECTION_ID			NUMBER         :=null,
	OCCURRENCE 			NUMBER         :=null,
	RETURN_STATUS         		VARCHAR2(1)    :=null,
	TRANSACTION_TYPE		NUMBER         :=null
 );

Type eam_meter_reading_rec_type is record
(
	HEADER_ID         		NUMBER         :=null,
	BATCH_ID          		NUMBER         :=null,
	ROW_ID           		NUMBER         :=null,
	WIP_ENTITY_ID    	 	NUMBER         :=null,
--	WIP_ENTITY_NAME  		VARCHAR2(240)  :=null, ??
--	METER_NAME    			VARCHAR2(50)   :=null, ??
	METER_ID           		NUMBER         :=null,
	METER_READING_ID 		NUMBER         :=null,
	CURRENT_READING  		NUMBER         :=null,
	current_reading_date	        DATE	       :=null,
--	LIFE_TO_DATE_READING     	DATE           :=null,   -- ??
	WO_END_DATE           		DATE           :=null,   -- ??
	RESET_FLAG         		VARCHAR2(1)    :=null,
	VALUE_BEFORE_RESET     		NUMBER         :=null,
	IGNORE_METER_WARNINGS 		VARCHAR2(1)    :=null,
	ATTRIBUTE_CATEGORY           	VARCHAR2(30)   :=null,
	ATTRIBUTE1               	VARCHAR2(150)  :=null,
	ATTRIBUTE2                    	VARCHAR2(150)  :=null,
	ATTRIBUTE3                    	VARCHAR2(150)  :=null,
	ATTRIBUTE4                    	VARCHAR2(150)  :=null,
	ATTRIBUTE5                    	VARCHAR2(150)  :=null,
	ATTRIBUTE6                 	VARCHAR2(150)  :=null,
	ATTRIBUTE7                    	VARCHAR2(150)  :=null,
	ATTRIBUTE8                   	VARCHAR2(150)  :=null,
	ATTRIBUTE9                    	VARCHAR2(150)  :=null,
	ATTRIBUTE10                   	VARCHAR2(150)  :=null,
	ATTRIBUTE11                   	VARCHAR2(150)  :=null,
	ATTRIBUTE12                   	VARCHAR2(150)  :=null,
	ATTRIBUTE13                   	VARCHAR2(150)  :=null,
	ATTRIBUTE14                  	VARCHAR2(150)  :=null,
	ATTRIBUTE15                   	VARCHAR2(150)  :=null,
	ATTRIBUTE16               	VARCHAR2(150)  :=null,
	ATTRIBUTE17                    	VARCHAR2(150)  :=null,
	ATTRIBUTE18                    	VARCHAR2(150)  :=null,
	ATTRIBUTE19                    	VARCHAR2(150)  :=null,
	ATTRIBUTE20                    	VARCHAR2(150)  :=null,
	ATTRIBUTE21                 	VARCHAR2(150)  :=null,
	ATTRIBUTE22                    	VARCHAR2(150)  :=null,
	ATTRIBUTE23                   	VARCHAR2(150)  :=null,
	ATTRIBUTE24                    	VARCHAR2(150)  :=null,
	ATTRIBUTE25                   	VARCHAR2(150)  :=null,
	ATTRIBUTE26                   	VARCHAR2(150)  :=null,
	ATTRIBUTE27                   	VARCHAR2(150)  :=null,
	ATTRIBUTE28                   	VARCHAR2(150)  :=null,
	ATTRIBUTE29                  	VARCHAR2(150)  :=null,
	ATTRIBUTE30                   	VARCHAR2(150)  :=null,

	SOURCE_LINE_ID                  NUMBER         :=null,
	SOURCE_CODE                     VARCHAR2(30)   :=null,
	WO_ENTRY_FAKE_FLAG		VARCHAR2(1)    :=null,
	RETURN_STATUS                   VARCHAR2(1)    :=null,
	TRANSACTION_TYPE                NUMBER         :=null
 );

Type eam_counter_prop_rec_type is record
(
	HEADER_ID         		NUMBER         :=null,
	BATCH_ID          		NUMBER         :=null,
	ROW_ID           		NUMBER         :=null,
	WIP_ENTITY_ID    	 	NUMBER         :=null,
	COUNTER_ID    			NUMBER         :=null,
	PROPERTY_ID			NUMBER	       :=null,
	PROPERTY_VALUE			VARCHAR2(240)  :=null,
	VALUE_TIMESTAMP			DATE	       :=null,
--??
	MIGRATED_FLAG			VARCHAR2(1)    :=null,
	ATTRIBUTE_CATEGORY           	VARCHAR2(30)   :=null,
	ATTRIBUTE1               	VARCHAR2(150)  :=null,
	ATTRIBUTE2                    	VARCHAR2(150)  :=null,
	ATTRIBUTE3                    	VARCHAR2(150)  :=null,
	ATTRIBUTE4                    	VARCHAR2(150)  :=null,
	ATTRIBUTE5                    	VARCHAR2(150)  :=null,
	ATTRIBUTE6                 	VARCHAR2(150)  :=null,
	ATTRIBUTE7                    	VARCHAR2(150)  :=null,
	ATTRIBUTE8                   	VARCHAR2(150)  :=null,
	ATTRIBUTE9                    	VARCHAR2(150)  :=null,
	ATTRIBUTE10                   	VARCHAR2(150)  :=null,
	ATTRIBUTE11                   	VARCHAR2(150)  :=null,
	ATTRIBUTE12                   	VARCHAR2(150)  :=null,
	ATTRIBUTE13                   	VARCHAR2(150)  :=null,
	ATTRIBUTE14                  	VARCHAR2(150)  :=null,
	ATTRIBUTE15                   	VARCHAR2(150)  :=null,
	RETURN_STATUS                   VARCHAR2(1)    :=null,
	TRANSACTION_TYPE                NUMBER         :=null
 );

Type eam_wo_comp_rebuild_rec_type is record
(
	  HEADER_ID                     NUMBER         :=null,
          BATCH_ID                      NUMBER         :=null,
          ROW_ID                        NUMBER         :=null,
          WIP_ENTITY_ID                 NUMBER         :=null,
	  REBUILD_WIP_ENTITY_ID         NUMBER         :=null,
          ORGANIZATION_ID               NUMBER         :=null,
--	  SERIAL_NO_ISSUED		VARCHAR2(30)   :=null,
	  ITEM_REMOVED		        NUMBER	       :=null,
--	  SERIAL_INST_REMOVED		VARCHAR2(30)   :=null,
	  INSTANCE_ID_REMOVED		NUMBER	       :=null,
	  UNINST_SERIAL_REMOVED		VARCHAR2(30)   :=null,
	  ACTIVITY_ID			NUMBER	       :=null,
	  RETURN_STATUS                 VARCHAR2(1)    :=null,
          TRANSACTION_TYPE              NUMBER         :=null
);

Type eam_wo_comp_mr_read_rec_type is record
(
	  HEADER_ID                     NUMBER        :=null,
          BATCH_ID                      NUMBER        :=null,
          ROW_ID                        NUMBER        :=null,
          WIP_ENTITY_ID                 NUMBER        :=null,
          ORGANIZATION_ID               NUMBER        :=null,
	  INSTANCE_ID_ISSUED		VARCHAR2(30)  :=null,
--	  SERIAL_ITEM_REMOVED		NUMBER	      :=null,
--	  SERIAL_NO_REMOVED		VARCHAR2(30)  :=null,
	  METER_ISSUED_SERIAL		NUMBER	      :=null,
	  SOURCE_METER			NUMBER	      :=null,
	  RETURN_STATUS                 VARCHAR2(1)   :=null,
          TRANSACTION_TYPE              NUMBER        :=null
);

Type eam_request_rec_type is record
(
          HEADER_ID                 	NUMBER		:=null,
          BATCH_ID                    	NUMBER		:=null,
          ROW_ID                        NUMBER		:=null,
          WIP_ENTITY_ID                	NUMBER		:=null,
          WIP_ENTITY_NAME      		VARCHAR2(240)   :=null,
          ORGANIZATION_ID           	NUMBER		:=null,
          ORGANIZATION_CODE     	VARCHAR2(3)	:=null,
          REQUEST_TYPE                	NUMBER		:=null,
          REQUEST_ID               	NUMBER		:=null,
          REQUEST_NUMBER           	VARCHAR2(240)	:=null,    -- for bug#14210569
          ATTRIBUTE_CATEGORY   	        VARCHAR2(30)    :=null,
          ATTRIBUTE1                    VARCHAR2(150)   :=null,
          ATTRIBUTE2		        VARCHAR2(150)   :=null,
          ATTRIBUTE3		        VARCHAR2(150)   :=null,
          ATTRIBUTE4		        VARCHAR2(150)   :=null,
          ATTRIBUTE5			VARCHAR2(150)   :=null,
          ATTRIBUTE6			VARCHAR2(150)   :=null,
          ATTRIBUTE7			VARCHAR2(150)   :=null,
          ATTRIBUTE8			VARCHAR2(150)   :=null,
          ATTRIBUTE9			VARCHAR2(150)   :=null,
          ATTRIBUTE10			VARCHAR2(150)   :=null,
          ATTRIBUTE11			VARCHAR2(150)   :=null,
          ATTRIBUTE12			VARCHAR2(150)   :=null,
          ATTRIBUTE13          		VARCHAR2(150)   :=null,
          ATTRIBUTE14          		VARCHAR2(150)   :=null,
          ATTRIBUTE15                   VARCHAR2(150)   :=null,
          PROGRAM_ID                	NUMBER		:=null,
          PROGRAM_REQUEST_ID            NUMBER		:=null,
          PROGRAM_UPDATE_DATE           DATE		:=null,
          PROGRAM_APPLICATION_ID        NUMBER		:=null,
          WORK_REQUEST_STATUS_ID   	NUMBER		:=null,
          SERVICE_ASSOC_ID              NUMBER		:=null,
          RETURN_STATUS                 VARCHAR2(1)	:=null,
          TRANSACTION_TYPE              NUMBER          :=null
 );

Type eam_wo_relations_tbl_type is table of eam_wo_relations_rec_type
          INDEX BY BINARY_INTEGER;

Type header_id_tbl_type is table of header_id_rec_type
          INDEX BY BINARY_INTEGER;

Type eam_wo_tbl_type is table of eam_wo_rec_type
          INDEX BY BINARY_INTEGER;

Type eam_op_tbl_type is table of eam_op_rec_type
          INDEX BY BINARY_INTEGER;

Type eam_op_network_tbl_type is table of eam_op_network_rec_type
          INDEX BY BINARY_INTEGER;

Type eam_res_tbl_type is table of eam_res_rec_type
          INDEX BY BINARY_INTEGER;

Type eam_res_inst_tbl_type is table of eam_res_inst_rec_type
          INDEX BY BINARY_INTEGER;

Type eam_sub_res_tbl_type is table of eam_sub_res_rec_type
          INDEX BY BINARY_INTEGER;

Type eam_res_usage_tbl_type is table of eam_res_usage_rec_type
          INDEX BY BINARY_INTEGER;

Type eam_mat_req_tbl_type is table of eam_mat_req_rec_type
          INDEX BY BINARY_INTEGER;

Type eam_direct_items_tbl_type is table of eam_direct_items_rec_type
          INDEX BY BINARY_INTEGER;

Type eam_wo_comp_tbl_type is table of eam_wo_comp_rec_type
            INDEX BY BINARY_INTEGER;

Type eam_op_comp_tbl_type is table of eam_op_comp_rec_type
          INDEX BY BINARY_INTEGER;

Type eam_meter_reading_tbl_type is table of eam_meter_reading_rec_type
	  INDEX BY BINARY_INTEGER;

Type eam_counter_prop_tbl_type is table of eam_counter_prop_rec_type
	  INDEX BY BINARY_INTEGER;

Type eam_wo_quality_tbl_type is table of eam_wo_quality_rec_type
          INDEX BY BINARY_INTEGER;

Type eam_wo_comp_rebuild_tbl_type is table of eam_wo_comp_rebuild_rec_type
          INDEX BY BINARY_INTEGER;

Type eam_wo_comp_mr_read_tbl_type is table of eam_wo_comp_mr_read_rec_type
          INDEX BY BINARY_INTEGER;

Type eam_request_tbl_type is table of eam_request_rec_type
          INDEX BY BINARY_INTEGER;

TYPE wo_relationship_exc_tbl_type is TABLE OF varchar2(1000) INDEX BY BINARY_INTEGER;


        PROCEDURE PROCESS_WO
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_commit                  IN  VARCHAR2 := 'N'
         , p_eam_wo_rec              IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
 	 , p_eam_wo_comp_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
         , p_eam_wo_quality_tbl      IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
         , p_eam_meter_reading_tbl   IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
	 , p_eam_counter_prop_tbl    IN  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
         , p_eam_wo_comp_rebuild_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
         , p_eam_wo_comp_mr_read_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
         , p_eam_op_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	 , p_eam_request_tbl         IN  EAM_PROCESS_WO_PUB.eam_request_tbl_type
         , x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
 	 , x_eam_wo_comp_rec         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
         , x_eam_wo_quality_tbl      OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
         , x_eam_meter_reading_tbl   OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
 	 , x_eam_counter_prop_tbl    OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
         , x_eam_wo_comp_rebuild_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
         , x_eam_wo_comp_mr_read_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
         , x_eam_op_comp_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	 , x_eam_request_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_request_tbl_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'EAM_WO_DEBUG.log'
         , p_debug_file_mode         IN  VARCHAR2 := 'w'
         );

        PROCEDURE PROCESS_MASTER_CHILD_WO
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_eam_wo_relations_tbl    IN  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type
         , p_eam_wo_tbl              IN  EAM_PROCESS_WO_PUB.eam_wo_tbl_type
         , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
	 , p_eam_wo_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type
         , p_eam_wo_quality_tbl      IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
         , p_eam_meter_reading_tbl   IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
 	 , p_eam_counter_prop_tbl    IN  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
         , p_eam_wo_comp_rebuild_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
         , p_eam_wo_comp_mr_read_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
         , p_eam_op_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	 , p_eam_request_tbl         IN  EAM_PROCESS_WO_PUB.eam_request_tbl_type
         , x_eam_wo_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_tbl_type
         , x_eam_wo_relations_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_wo_comp_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type
         , x_eam_wo_quality_tbl      OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
         , x_eam_meter_reading_tbl   OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
  	 , x_eam_counter_prop_tbl    OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
         , x_eam_wo_comp_rebuild_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
         , x_eam_wo_comp_mr_read_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
         , x_eam_op_comp_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	 , x_eam_request_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_request_tbl_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_commit                  IN  VARCHAR2 := 'N'
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'EAM_WO_DEBUG.log'
         , p_debug_file_mode         IN  VARCHAR2 := 'w'
         );

       /*#
 * This procedure is used to create/update a single Maintenance Work Order.
 * It can also be used to create/update/delete the work order operations,operation networks ,materials,direct items, resources, resource usage and resource instances.
 * This procedure calls the required business processes such as scheduling the work order,material  allocation , requisition generation for Direct items and for OSP items,cost re-estimation of work order.
 * The API requires that you enter only the minimum necessary business information that defines your maintenance work order. The API will do the required defaulting for columns not filled in by users.
 * The user can optionally provide the activity BOM and the activity routing in order to use the explosion feature of the API
 * when you create Maintenance work order.
 * In case of error ,API reports detailed and translatable error messages.
 * @param p_bo_identifier Business Object Identifier
 * @param p_api_version_number API Version Number
 * @param p_init_msg_list 'TRUE' Clear the existing messages / 'FALSE' Retain the existing messages
 * @param p_commit 'Y' Commit the api / 'N' Do not commit the api
 * @param p_eam_wo_rec Maintenance Work order Record
 * @param p_eam_op_tbl pl/sql table of Work order Operations
 * @param p_eam_op_network_tbl pl/sql table of Work order Operation Network
 * @param p_eam_res_tbl pl/sql table of Work order Resources
 * @param p_eam_res_inst_tbl pl/sql table of Work order Resource Instances
 * @param p_eam_sub_res_tbl pl/sql table of Work order Substitute Resources
 * @param p_eam_res_usage_tbl pl/sql table of Work order Resource Usage
 * @param p_eam_mat_req_tbl pl/sql table of Work order Material Requirements
 * @param p_eam_direct_items_tbl pl/sql table of Work order Direct Items
 * @param x_eam_wo_rec Changed Maintenance Work order Record
 * @param x_eam_op_tbl Changed pl/sql table of Work order Operations
 * @param x_eam_op_network_tbl Changed pl/sql table of Work order Operation Network
 * @param x_eam_res_tbl Changed pl/sql table of Work order Resources
 * @param x_eam_res_inst_tbl Changed pl/sql table of Work order Resource Instances
 * @param x_eam_sub_res_tbl Changed pl/sql table of Work order Substitute Resources
 * @param x_eam_res_usage_tbl Changed pl/sql table of Work order Resource Usage
 * @param x_eam_mat_req_tbl Changed pl/sql table of Work order Material Requirements
 * @param x_eam_direct_items_tbl Changed pl/sql table of Work order Direct Items
 * @param x_return_status Return status of work order creation 'S' Success /'E' Error /'F' Fatal Error /'U' Unexpected Error
 * @param x_msg_count Error message count count=0 indicates no error
 * @param p_debug 'Y' Log debug messages / 'N' Do not log debug messages
 * @param p_output_dir Directory for the debug file
 * @param p_debug_filename Name of the debug file
 * @param p_debug_file_mode 'w' Write / 'a' Append
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Asset Maintenance Single Work Order Creation
 */




        PROCEDURE PROCESS_WO
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_commit                  IN  VARCHAR2 := 'N'
         , p_eam_wo_rec              IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'EAM_WO_DEBUG.log'
         , p_debug_file_mode         IN  VARCHAR2 := 'w'
         );


-- overloaded for safety permit project

PROCEDURE PROCESS_WO
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_commit                  IN  VARCHAR2 := 'N'
         , p_eam_wo_rec              IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
          , p_eam_wo_comp_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
         , p_eam_wo_quality_tbl      IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
         , p_eam_meter_reading_tbl   IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
          , p_eam_counter_prop_tbl    IN  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
         , p_eam_wo_comp_rebuild_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
         , p_eam_wo_comp_mr_read_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
         , p_eam_op_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
         , p_eam_request_tbl         IN  EAM_PROCESS_WO_PUB.eam_request_tbl_type
         , p_eam_permit_tbl               IN  EAM_PROCESS_PERMIT_PUB.eam_wp_tbl_type -- new param for safety permit
         , p_eam_permit_wo_assoc_tbl IN EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type -- new param for safety permit
         , x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
        , x_eam_wo_comp_rec         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
         , x_eam_wo_quality_tbl      OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
         , x_eam_meter_reading_tbl   OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
        , x_eam_counter_prop_tbl    OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
         , x_eam_wo_comp_rebuild_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
         , x_eam_wo_comp_mr_read_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
         , x_eam_op_comp_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
         , x_eam_request_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_request_tbl_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'EAM_WO_DEBUG.log'
         , p_debug_file_mode         IN  VARCHAR2 := 'w'
         );

/*#
 * This procedure is used to create/update multiple Maintenance Work Orders.
 * User can create/update/delete the relationship between the work orders.
 * For all the work orders ,user can create /update /delete, the work order operations,operation networks ,materials,direct items, resources, resource usage and resource instances.
 * The API calls the required business processes such as scheduling the work order,material  allocation , requisition generation for Direct items and for OSP items,cost re-estimation of work order.
 * The API requires you to enter only the minimum necessary business information that defines your maintenance work order. The API will do the required defaulting for columns not filled in by users.
 * The user can optionally provide the activity BOM and the activity routing in order to use the explosion feature of the API
 * when you create Maintenance work order.
 * In case of error ,API reports detailed and translatable error messages .
 * @param p_bo_identifier  Business Object Identifier
 * @param p_api_version_number API Version Number
 * @param p_init_msg_list  'TRUE' Clear the existing messages / 'FALSE' Retain the existing messages
 * @param p_eam_wo_relations_tbl pl/sql table of Work order Relationships
 * @param p_eam_wo_tbl pl/sql table of Maintenance Work orders
 * @param p_eam_op_tbl pl/sql table of Work order Operations
 * @param p_eam_op_network_tbl pl/sql table of Work order Operation Network
 * @param p_eam_res_tbl pl/sql table of Work order Resources
 * @param p_eam_res_inst_tbl  pl/sql table of Work order Resource Instances
 * @param p_eam_sub_res_tbl pl/sql table of Work order Substitute Resources
 * @param p_eam_mat_req_tbl pl/sql table of Work order Material Requirements
 * @param p_eam_direct_items_tbl pl/sql table of Work order Direct Items
 * @param x_eam_wo_tbl Changed pl/sql table of Maintenance Work orders
 * @param x_eam_wo_relations_tbl Changed pl/sql table of Work order Relationships
 * @param x_eam_op_tbl Changed pl/sql table of Work order Operations
 * @param x_eam_op_network_tbl Changed pl/sql table of Work order Operation Network
 * @param x_eam_res_tbl Changed pl/sql table of Work order Resources
 * @param x_eam_res_inst_tbl Changed pl/sql table of Work order Resource Instances
 * @param x_eam_sub_res_tbl Changed pl/sql table of Work order Substitute Resources
 * @param x_eam_mat_req_tbl Changed pl/sql table of Work order Material Requirements
 * @param x_eam_direct_items_tbl Changed pl/sql table of Work order Direct Items
 * @param x_return_status Return status of work order creation 'S' Success /'E' Error /'F' Fatal Error /'U' Unexpected Error / 'N' Not Processed
 * @param x_msg_count Error message count count=0 indicates no error
 * @param p_commit 'Y' Commit the api / 'N' Do not commit the api
 * @param p_debug 'Y' Log debug messages / 'N' Do not log debug messages
 * @param p_output_dir Directory for the debug file
 * @param p_debug_filename Name of the debug file
 * @param p_debug_file_mode 'w' Write / 'a' Append
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Asset Maintenance Multiple Work Orders Creation
 */

        PROCEDURE PROCESS_MASTER_CHILD_WO
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_eam_wo_relations_tbl    IN  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type
         , p_eam_wo_tbl              IN  EAM_PROCESS_WO_PUB.eam_wo_tbl_type
         , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_eam_wo_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_tbl_type
         , x_eam_wo_relations_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_commit                  IN  VARCHAR2 := 'N'
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'EAM_WO_DEBUG.log'
         , p_debug_file_mode         IN  VARCHAR2 := 'w'
         );




         PROCEDURE DELETE_RELATIONSHIP
         ( p_api_version                   IN NUMBER
         , p_init_msg_list                 IN VARCHAR2 := FND_API.G_TRUE
         , p_commit                        IN VARCHAR2 := FND_API.G_FALSE
         , p_validation_level              IN NUMBER   := FND_API.G_VALID_LEVEL_FULL

         , p_parent_object_id              IN NUMBER
         , p_parent_object_type_id         IN NUMBER
         , p_child_object_id               IN NUMBER
         , p_child_object_type_id          IN NUMBER
         , p_new_parent_object_id          IN NUMBER
         , p_new_parent_object_type_id     IN NUMBER

         , x_return_status                 OUT NOCOPY  VARCHAR2
         , x_msg_count                     OUT NOCOPY  NUMBER
         , x_msg_data                      OUT NOCOPY  VARCHAR2
         );

        G_MISS_EAM_WO_REC               EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        G_MISS_EAM_OP_REC               EAM_PROCESS_WO_PUB.eam_op_rec_type;
        G_MISS_EAM_OP_TBL               EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        G_MISS_EAM_OP_NETWORK_REC       EAM_PROCESS_WO_PUB.eam_op_network_rec_type;
        G_MISS_EAM_OP_NETWORK_TBL       EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        G_MISS_EAM_RES_REC              EAM_PROCESS_WO_PUB.eam_res_rec_type;
        G_MISS_EAM_RES_TBL              EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        G_MISS_EAM_RES_INST_REC         EAM_PROCESS_WO_PUB.eam_res_inst_rec_type;
        G_MISS_EAM_RES_INST_TBL         EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        G_MISS_EAM_SUB_RES_REC          EAM_PROCESS_WO_PUB.eam_sub_res_rec_type;
        G_MISS_EAM_SUB_RES_TBL          EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        G_MISS_EAM_RES_USAGE_REC        EAM_PROCESS_WO_PUB.eam_res_usage_rec_type;
        G_MISS_EAM_RES_USAGE_TBL        EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        G_MISS_EAM_MAT_REQ_REC          EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
        G_MISS_EAM_MAT_REQ_TBL          EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        G_MISS_EAM_DIRECT_ITEMS_TBL     EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	G_MISS_EAM_WO_COMP_REC          EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	G_MISS_EAM_OP_COMP_REC		EAM_PROCESS_WO_PUB.eam_op_comp_rec_type;

	G_MISS_EAM_COMP_WO_REC            EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
        G_MISS_EAM_WO_QUALITY_TBL         EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
        G_MISS_EAM_METER_READING_TBL      EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
        G_MISS_EAM_COUNTER_PROP_TBL       EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	G_MISS_EAM_WO_COMP_REBUILD_TBL    EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	G_MISS_EAM_WO_COMP_MR_READ_TBL    EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
        G_MISS_EAM_OP_COMP_TBL            EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
        G_MISS_EAM_REQUEST_TBL            EAM_PROCESS_WO_PUB.eam_request_tbl_type;



        PROCEDURE EXPLODE_ACTIVITY
        (  p_api_version             IN  NUMBER   := 1.0
         , p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
         , p_commit                  IN  VARCHAR2 := fnd_api.g_false
         , p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
         , p_organization_id         IN  NUMBER
         , p_asset_activity_id       IN  NUMBER
         , p_wip_entity_id           IN  NUMBER
         , p_start_date              IN  DATE
         , p_completion_date         IN  DATE
         , p_rev_datetime            IN  DATE     := SYSDATE
         , p_entity_type             IN  NUMBER   := 6
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , x_msg_data                OUT NOCOPY VARCHAR2
         );


        PROCEDURE CHECK_BO_RECORD
        ( p_eam_wo_rec              IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
        , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
        , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
        , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
        , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
        , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
        , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
        , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
	, p_eam_wo_comp_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
        , p_eam_wo_quality_tbl      IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
        , p_eam_meter_reading_tbl   IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
        , p_eam_counter_prop_tbl    IN  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
        , p_eam_wo_comp_rebuild_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
        , p_eam_wo_comp_mr_read_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
        , p_eam_op_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	, p_eam_request_tbl         IN  EAM_PROCESS_WO_PUB.eam_request_tbl_type
        , x_return_status           OUT NOCOPY VARCHAR2
        );


        PROCEDURE CHECK_BO_NETWORK
        ( p_eam_wo_tbl              IN  EAM_PROCESS_WO_PUB.eam_wo_tbl_type
        , p_eam_wo_relations_tbl    IN  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type
        , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
        , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
        , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
        , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
        , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
        , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
        , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
	, p_eam_wo_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type
        , p_eam_wo_quality_tbl      IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
        , p_eam_meter_reading_tbl   IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
        , p_eam_counter_prop_tbl    IN  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
        , p_eam_wo_comp_rebuild_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
        , p_eam_wo_comp_mr_read_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
        , p_eam_op_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	, p_eam_request_tbl         IN  EAM_PROCESS_WO_PUB.eam_request_tbl_type
        , x_eam_wo_tbl              OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_tbl_type
        , x_eam_wo_relations_tbl    OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type
        , x_eam_op_tbl              OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_op_tbl_type
        , x_eam_op_network_tbl      OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
        , x_eam_res_tbl             OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_res_tbl_type
        , x_eam_res_inst_tbl        OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        , x_eam_sub_res_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
        , x_eam_mat_req_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
        , x_eam_direct_items_tbl    OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
        , x_eam_res_usage_tbl       OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
	, x_eam_wo_comp_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type
        , x_eam_wo_quality_tbl      OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
        , x_eam_meter_reading_tbl   OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
        , x_eam_counter_prop_tbl    OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
        , x_eam_wo_comp_rebuild_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
        , x_eam_wo_comp_mr_read_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
        , x_eam_op_comp_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	, x_eam_request_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_request_tbl_type
        , x_batch_id                OUT NOCOPY NUMBER
        , x_header_id_tbl           OUT NOCOPY EAM_PROCESS_WO_PUB.header_id_tbl_type
        , x_return_status           OUT NOCOPY VARCHAR2
        );

	 PROCEDURE COPY_WORKORDER
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
         , p_commit                  IN  VARCHAR2 := fnd_api.g_false
         , p_wip_entity_id           IN  NUMBER
         , p_organization_id         IN  NUMBER
         , x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         );

/* Added for bug#4563210 to add work order creation confirmation message,
 * while work order scheduling relationship creation fails */
Type eam_wo_list_type is table of varchar2(240) INDEX BY BINARY_INTEGER;
l_eam_wo_list eam_wo_list_type;


/* This procedure is used to make an entry in wip_eam_direct_items
when a Purchase Requisition/Purchase Order is created  for description direct items in
Purchasing using forms.
Bug 8450377
*/

PROCEDURE UPDATE_WO_ADD_DES_DIR_ITEM
        (  p_wip_entity_id                IN  NUMBER
         , p_operation_seq_num            IN  NUMBER
         , p_inventory_item_id            IN  NUMBER
         , p_description                  IN  VARCHAR2
         , p_organization_id              IN  NUMBER
         , p_purchasing_category_id       IN  NUMBER
         , p_suggested_vendor_name        IN  VARCHAR2 := NULL
         , p_suggested_vendor_id          IN  NUMBER   := NULL
         , p_suggested_vendor_site        IN  VARCHAR2 := NULL
         , p_suggested_vendor_site_id     IN  NUMBER   := NULL
         , p_suggested_vendor_contact     IN  VARCHAR2 := NULL
         , p_suggested_vendor_contact_id  IN  NUMBER   := NULL
         , p_suggested_vendor_phone       IN  VARCHAR2 := NULL
         , p_suggested_vendor_item_num    IN  VARCHAR2 := NULL
         , p_required_quantity            IN  NUMBER
         , p_unit_price                   IN  NUMBER
         , p_uom                          IN  VARCHAR2
         , p_need_by_date                 IN  DATE
         , p_amount                       IN  NUMBER
         , p_order_type_lookup_code       IN  VARCHAR2
         , x_direct_item_sequence_id      IN OUT NOCOPY NUMBER
         , x_return_status                OUT NOCOPY VARCHAR2
         );

END EAM_PROCESS_WO_PUB;

/
