--------------------------------------------------------
--  DDL for Package CSI_ITEM_INSTANCE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ITEM_INSTANCE_GRP" AUTHID CURRENT_USER as
/* $Header: csigiis.pls 120.8.12010000.1 2008/07/25 08:08:12 appldev ship $ */


TYPE T_DATE  is TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE T_NUM   is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE T_V1    is TABLE OF VARCHAR(01) INDEX BY BINARY_INTEGER;
TYPE T_V3    is TABLE OF VARCHAR(03) INDEX BY BINARY_INTEGER;
TYPE T_V10   is TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
TYPE T_V15   is TABLE OF VARCHAR(15) INDEX BY BINARY_INTEGER;
TYPE T_V20   is TABLE OF VARCHAR(20) INDEX BY BINARY_INTEGER;
TYPE T_V25   is TABLE OF VARCHAR(25) INDEX BY BINARY_INTEGER;
TYPE T_V30   is TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
TYPE T_V35   is TABLE OF VARCHAR(35) INDEX BY BINARY_INTEGER;
TYPE T_V40   is TABLE OF VARCHAR(40) INDEX BY BINARY_INTEGER;
TYPE T_V50   is TABLE OF VARCHAR(50) INDEX BY BINARY_INTEGER;
TYPE T_V60   is TABLE OF VARCHAR(60) INDEX BY BINARY_INTEGER;
TYPE T_V80   is TABLE OF VARCHAR(80) INDEX BY BINARY_INTEGER;
TYPE T_V85   is TABLE OF VARCHAR(85) INDEX BY BINARY_INTEGER;
TYPE T_V150  is TABLE OF VARCHAR(150) INDEX BY BINARY_INTEGER;
TYPE T_V240  is TABLE OF VARCHAR(240) INDEX BY BINARY_INTEGER;
TYPE T_V360  is TABLE OF VARCHAR(360) INDEX BY BINARY_INTEGER;
TYPE T_V1000 is TABLE OF VARCHAR(1000) INDEX BY BINARY_INTEGER;
TYPE T_V2000 is TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;

--
TYPE INSTANCE_REC_TAB IS RECORD
   (
      INSTANCE_ID                  T_NUM
     ,INSTANCE_NUMBER              T_V30
     ,EXTERNAL_REFERENCE           T_V30
     ,INVENTORY_ITEM_ID            T_NUM
     ,VLD_ORGANIZATION_ID          T_NUM
     ,INVENTORY_REVISION           T_V3
     ,INV_MASTER_ORGANIZATION_ID   T_NUM
     ,SERIAL_NUMBER                T_V30
     ,MFG_SERIAL_NUMBER_FLAG       T_V1
     ,LOT_NUMBER                   T_V80
     ,QUANTITY                     T_NUM
     ,UNIT_OF_MEASURE              T_V3
     ,ACCOUNTING_CLASS_CODE        T_V10
     ,INSTANCE_CONDITION_ID        T_NUM
     ,INSTANCE_STATUS_ID           T_NUM
     ,CUSTOMER_VIEW_FLAG           T_V1
     ,MERCHANT_VIEW_FLAG           T_V1
     ,SELLABLE_FLAG                T_V1
     ,SYSTEM_ID                    T_NUM
     ,INSTANCE_TYPE_CODE           T_V30
     ,ACTIVE_START_DATE            T_DATE
     ,ACTIVE_END_DATE              T_DATE
     ,LOCATION_TYPE_CODE           T_V30
     ,LOCATION_ID                  T_NUM
     ,INV_ORGANIZATION_ID          T_NUM
     ,INV_SUBINVENTORY_NAME        T_V10
     ,INV_LOCATOR_ID               T_NUM
     ,PA_PROJECT_ID                T_NUM
     ,PA_PROJECT_TASK_ID           T_NUM
     ,IN_TRANSIT_ORDER_LINE_ID     T_NUM
     ,WIP_JOB_ID                   T_NUM
     ,PO_ORDER_LINE_ID             T_NUM
     ,LAST_OE_ORDER_LINE_ID        T_NUM
     ,LAST_OE_RMA_LINE_ID          T_NUM
     ,LAST_PO_PO_LINE_ID           T_NUM
     ,LAST_OE_PO_NUMBER            T_V50
     ,LAST_WIP_JOB_ID              T_NUM
     ,LAST_PA_PROJECT_ID           T_NUM
     ,LAST_PA_TASK_ID              T_NUM
     ,LAST_OE_AGREEMENT_ID         T_NUM
     ,INSTALL_DATE                 T_DATE
     ,MANUALLY_CREATED_FLAG        T_V1
     ,RETURN_BY_DATE               T_DATE
     ,ACTUAL_RETURN_DATE           T_DATE
     ,CREATION_COMPLETE_FLAG       T_V1
     ,COMPLETENESS_FLAG            T_V1
     ,VERSION_LABEL                T_V240
     ,VERSION_LABEL_DESCRIPTION    T_V240
     ,CONTEXT                      T_V30
     ,ATTRIBUTE1                   T_V240
     ,ATTRIBUTE2                   T_V240
     ,ATTRIBUTE3                   T_V240
     ,ATTRIBUTE4                   T_V240
     ,ATTRIBUTE5                   T_V240
     ,ATTRIBUTE6                   T_V240
     ,ATTRIBUTE7                   T_V240
     ,ATTRIBUTE8                   T_V240
     ,ATTRIBUTE9                   T_V240
     ,ATTRIBUTE10                  T_V240
     ,ATTRIBUTE11                  T_V240
     ,ATTRIBUTE12                  T_V240
     ,ATTRIBUTE13                  T_V240
     ,ATTRIBUTE14                  T_V240
     ,ATTRIBUTE15                  T_V240
     ,OBJECT_VERSION_NUMBER        T_NUM
     ,LAST_TXN_LINE_DETAIL_ID      T_NUM
     ,INSTALL_LOCATION_TYPE_CODE   T_V30
     ,INSTALL_LOCATION_ID          T_NUM
     ,INSTANCE_USAGE_CODE          T_V30
     ,CHECK_FOR_INSTANCE_EXPIRY    T_V1
     ,CALL_CONTRACTS               T_V1
     ,GRP_CALL_CONTRACTS           T_V1
     ,CONFIG_INST_HDR_ID           T_NUM
     ,CONFIG_INST_REV_NUM          T_NUM
     ,CONFIG_INST_ITEM_ID          T_NUM
     ,CONFIG_VALID_STATUS          T_V30
     ,INSTANCE_DESCRIPTION         T_V240
     ,NETWORK_ASSET_FLAG           T_V1
     ,MAINTAINABLE_FLAG            T_V1
     ,ASSET_CRITICALITY_CODE       T_V30
     ,CATEGORY_ID                  T_NUM
     ,EQUIPMENT_GEN_OBJECT_ID      T_NUM
     ,INSTANTIATION_FLAG           T_V1
     ,OPERATIONAL_LOG_FLAG         T_V1
     ,SUPPLIER_WARRANTY_EXP_DATE   T_DATE
     ,ATTRIBUTE16                  T_V240
     ,ATTRIBUTE17                  T_V240
     ,ATTRIBUTE18                  T_V240
     ,ATTRIBUTE19                  T_V240
     ,ATTRIBUTE20                  T_V240
     ,ATTRIBUTE21                  T_V240
     ,ATTRIBUTE22                  T_V240
     ,ATTRIBUTE23                  T_V240
     ,ATTRIBUTE24                  T_V240
     ,ATTRIBUTE25                  T_V240
     ,ATTRIBUTE26                  T_V240
     ,ATTRIBUTE27                  T_V240
     ,ATTRIBUTE28                  T_V240
     ,ATTRIBUTE29                  T_V240
     ,ATTRIBUTE30                  T_V240
     ,PURCHASE_UNIT_PRICE          T_NUM
     ,PURCHASE_CURRENCY_CODE       T_V15
     ,PAYABLES_UNIT_PRICE          T_NUM
     ,PAYABLES_CURRENCY_CODE       T_V15
     ,SALES_UNIT_PRICE             T_NUM
     ,SALES_CURRENCY_CODE          T_V15
     ,OPERATIONAL_STATUS_CODE      T_V30
   );
--
TYPE INSTANCE_HISTORY_REC_TAB IS RECORD
  (
       instance_id                         T_NUM
      ,old_instance_number                 T_V30
      ,new_instance_number                 T_V30
      ,old_external_reference              T_V30
      ,new_external_reference              T_V30
      ,old_inventory_item_id               T_NUM
      ,new_inventory_item_id               T_NUM
      ,old_inventory_revision              T_V3
      ,new_inventory_revision              T_V3
      ,old_inv_master_org_id               T_NUM
      ,new_inv_master_org_id               T_NUM
      ,old_serial_number                   T_V30
      ,new_serial_number                   T_V30
      ,old_mfg_serial_number_flag          T_V1
      ,new_mfg_serial_number_flag          T_V1
      ,old_lot_number                      T_V80
      ,new_lot_number                      T_V80
      ,old_quantity                        T_NUM
      ,new_quantity                        T_NUM
      ,old_unit_of_measure_name            T_V30
      ,new_unit_of_measure_name            T_V30
      ,old_unit_of_measure                 T_V3
      ,new_unit_of_measure                 T_V3
      ,old_accounting_class                T_V30
      ,new_accounting_class                T_V30
      ,old_accounting_class_code           T_V10
      ,new_accounting_class_code           T_V10
      ,old_instance_condition              T_V80
      ,new_instance_condition              T_V80
      ,old_instance_condition_id           T_NUM
      ,new_instance_condition_id           T_NUM
      ,old_instance_status                 T_V50
      ,new_instance_status                 T_V50
      ,old_instance_status_id              T_NUM
      ,new_instance_status_id              T_NUM
      ,old_customer_view_flag              T_V1
      ,new_customer_view_flag              T_V1
      ,old_merchant_view_flag              T_V1
      ,new_merchant_view_flag              T_V1
      ,old_sellable_flag                   T_V1
      ,new_sellable_flag                   T_V1
      ,old_system_id                       T_NUM
      ,new_system_id                       T_NUM
      ,old_system_name                     T_V30
      ,new_system_name                     T_V30
      ,old_instance_type_code              T_V30
      ,new_instance_type_code              T_V30
      ,old_instance_type_name              T_V240
      ,new_instance_type_name              T_V240
      ,old_active_start_date               T_DATE
      ,new_active_start_date               T_DATE
      ,old_active_end_date                 T_DATE
      ,new_active_end_date                 T_DATE
      ,old_location_type_code              T_V30
      ,new_location_type_code              T_V30
      ,old_location_id                     T_NUM
      ,new_location_id                     T_NUM
      ,old_inv_organization_id             T_NUM
      ,new_inv_organization_id             T_NUM
      ,old_inv_organization_name           T_V60
      ,new_inv_organization_name           T_V60
      ,old_inv_subinventory_name           T_V10
      ,new_inv_subinventory_name           T_V10
      ,old_inv_locator_id                  T_NUM
      ,new_inv_locator_id                  T_NUM
      ,old_pa_project_id                   T_NUM
      ,new_pa_project_id                   T_NUM
      ,old_pa_project_task_id              T_NUM
      ,new_pa_project_task_id              T_NUM
      ,old_pa_project_name                 T_V30
      ,new_pa_project_name                 T_V30
      ,old_pa_project_number               T_V25
      ,new_pa_project_number               T_V25
      ,old_pa_task_name                    T_V20
      ,new_pa_task_name                    T_V20
      ,old_pa_task_number                  T_V25
      ,new_pa_task_number                  T_V25
      ,old_in_transit_order_line_id        T_NUM
      ,new_in_transit_order_line_id        T_NUM
      ,old_in_transit_order_line_num       T_NUM
      ,new_in_transit_order_line_num       T_NUM
      ,old_in_transit_order_number         T_NUM
      ,new_in_transit_order_number         T_NUM
      ,old_wip_job_id                      T_NUM
      ,new_wip_job_id                      T_NUM
      ,old_wip_entity_name                 T_V240
      ,new_wip_entity_name                 T_V240
      ,old_po_order_line_id                T_NUM
      ,new_po_order_line_id                T_NUM
      ,old_last_oe_order_line_id           T_NUM
      ,new_last_oe_order_line_id           T_NUM
      ,old_last_oe_rma_line_id             T_NUM
      ,new_last_oe_rma_line_id             T_NUM
      ,old_last_po_po_line_id              T_NUM
      ,new_last_po_po_line_id              T_NUM
      ,old_last_oe_po_number               T_V50
      ,new_last_oe_po_number               T_V50
      ,old_last_wip_job_id                 T_NUM
      ,new_last_wip_job_id                 T_NUM
      ,old_last_pa_project_id              T_NUM
      ,new_last_pa_project_id              T_NUM
      ,old_last_pa_task_id                 T_NUM
      ,new_last_pa_task_id                 T_NUM
      ,old_last_oe_agreement_id            T_NUM
      ,new_last_oe_agreement_id            T_NUM
      ,old_install_date                    T_DATE
      ,new_install_date                    T_DATE
      ,old_manually_created_flag           T_V1
      ,new_manually_created_flag           T_V1
      ,old_return_by_date                  T_DATE
      ,new_return_by_date                  T_DATE
      ,old_actual_return_date              T_DATE
      ,new_actual_return_date              T_DATE
      ,old_creation_complete_flag          T_V1
      ,new_creation_complete_flag          T_V1
      ,old_completeness_flag               T_V1
      ,new_completeness_flag               T_V1
      ,old_context                         T_V30
      ,new_context                         T_V30
      ,old_attribute1                      T_V240
      ,new_attribute1                      T_V240
      ,old_attribute2                      T_V240
      ,new_attribute2                      T_V240
      ,old_attribute3                      T_V240
      ,new_attribute3                      T_V240
      ,old_attribute4                      T_V240
      ,new_attribute4                      T_V240
      ,old_attribute5                      T_V240
      ,new_attribute5                      T_V240
      ,old_attribute6                      T_V240
      ,new_attribute6                      T_V240
      ,old_attribute7                      T_V240
      ,new_attribute7                      T_V240
      ,old_attribute8                      T_V240
      ,new_attribute8                      T_V240
      ,old_attribute9                      T_V240
      ,new_attribute9                      T_V240
      ,old_attribute10                     T_V240
      ,new_attribute10                     T_V240
      ,old_attribute11                     T_V240
      ,new_attribute11                     T_V240
      ,old_attribute12                     T_V240
      ,new_attribute12                     T_V240
      ,old_attribute13                     T_V240
      ,new_attribute13                     T_V240
      ,old_attribute14                     T_V240
      ,new_attribute14                     T_V240
      ,old_attribute15                     T_V240
      ,new_attribute15                     T_V240
      ,old_last_txn_line_detail_id         T_NUM
      ,new_last_txn_line_detail_id         T_NUM
      ,old_install_location_type_code      T_V30
      ,new_install_location_type_code      T_V30
      ,old_install_location_id             T_NUM
      ,new_install_location_id             T_NUM
      ,old_instance_usage_code             T_V30
      ,new_instance_usage_code             T_V30
      ,old_current_loc_address1            T_V240
      ,new_current_loc_address1            T_V240
      ,old_current_loc_address2            T_V240
      ,new_current_loc_address2            T_V240
      ,old_current_loc_address3            T_V240
      ,new_current_loc_address3            T_V240
      ,old_current_loc_address4            T_V240
      ,new_current_loc_address4            T_V240
      ,old_current_loc_city                T_V60
      ,new_current_loc_city                T_V60
      ,old_current_loc_postal_code         T_V60
      ,new_current_loc_postal_code         T_V60
      ,old_current_loc_country             T_V60
      ,new_current_loc_country             T_V60
      ,old_sales_order_number              T_NUM
      ,new_sales_order_number              T_NUM
      ,old_sales_order_line_number         T_NUM
      ,new_sales_order_line_number         T_NUM
      ,old_sales_order_date                T_DATE
      ,new_sales_order_date                T_DATE
      ,old_purchase_order_number           T_V50
      ,new_purchase_order_number           T_V50
      ,old_instance_usage_name             T_V80
      ,new_instance_usage_name             T_V80
      ,old_current_loc_state               T_V60
      ,new_current_loc_state               T_V60
      ,old_install_loc_address1            T_V240
      ,new_install_loc_address1            T_V240
      ,old_install_loc_address2            T_V240
      ,new_install_loc_address2            T_V240
      ,old_install_loc_address3            T_V240
      ,new_install_loc_address3            T_V240
      ,old_install_loc_address4            T_V240
      ,new_install_loc_address4            T_V240
      ,old_install_loc_city                T_V60
      ,new_install_loc_city                T_V60
      ,old_install_loc_state               T_V60
      ,new_install_loc_state               T_V60
      ,old_install_loc_postal_code         T_V60
      ,new_install_loc_postal_code         T_V60
      ,old_install_loc_country             T_V60
      ,new_install_loc_country             T_V60
      ,old_config_inst_rev_num             T_NUM
      ,new_config_inst_rev_num             T_NUM
      ,old_config_valid_status             T_V30
      ,new_config_valid_status             T_V30
      ,old_instance_description            T_V240
      ,new_instance_description            T_V240
      ,instance_history_id                 T_NUM
      ,transaction_id                      T_NUM
      ,old_last_vld_organization_id        T_NUM
      ,new_last_vld_organization_id        T_NUM
      ,old_network_asset_flag              T_V1
      ,new_network_asset_flag              T_V1
      ,old_maintainable_flag               T_V1
      ,new_maintainable_flag               T_V1
      ,old_pn_location_id		   T_NUM
      ,new_pn_location_id		   T_NUM
      ,old_asset_criticality_code          T_V30
      ,new_asset_criticality_code          T_V30
      ,old_category_id                     T_NUM
      ,new_category_id                     T_NUM
      ,old_equipment_gen_object_id         T_NUM
      ,new_equipment_gen_object_id         T_NUM
      ,old_instantiation_flag              T_V1
      ,new_instantiation_flag              T_V1
      ,old_linear_location_id		   T_NUM
      ,new_linear_location_id		   T_NUM
      ,old_operational_log_flag            T_V1
      ,new_operational_log_flag            T_V1
      ,old_checkin_status                  T_NUM
      ,new_checkin_status                  T_NUM
      ,old_supplier_warranty_exp_date      T_DATE
      ,new_supplier_warranty_exp_date      T_DATE
      ,old_attribute16                     T_V240
      ,new_attribute16                     T_V240
      ,old_attribute17                     T_V240
      ,new_attribute17                     T_V240
      ,old_attribute18                     T_V240
      ,new_attribute18                     T_V240
      ,old_attribute19                     T_V240
      ,new_attribute19                     T_V240
      ,old_attribute20                     T_V240
      ,new_attribute20                     T_V240
      ,old_attribute21                     T_V240
      ,new_attribute21                     T_V240
      ,old_attribute22                     T_V240
      ,new_attribute22                     T_V240
      ,old_attribute23                     T_V240
      ,new_attribute23                     T_V240
      ,old_attribute24                     T_V240
      ,new_attribute24                     T_V240
      ,old_attribute25                     T_V240
      ,new_attribute25                     T_V240
      ,old_attribute26                     T_V240
      ,new_attribute26                     T_V240
      ,old_attribute27                     T_V240
      ,new_attribute27                     T_V240
      ,old_attribute28                     T_V240
      ,new_attribute28                     T_V240
      ,old_attribute29                     T_V240
      ,new_attribute29                     T_V240
      ,old_attribute30                     T_V240
      ,new_attribute30                     T_V240
      ,old_payables_currency_code          T_V15
      ,new_payables_currency_code          T_V15
      ,old_purchase_unit_price             T_NUM
      ,new_purchase_unit_price             T_NUM
      ,old_purchase_currency_code          T_V15
      ,new_purchase_currency_code          T_V15
      ,old_payables_unit_price             T_NUM
      ,new_payables_unit_price             T_NUM
      ,old_sales_unit_price                T_NUM
      ,new_sales_unit_price                T_NUM
      ,old_sales_currency_code             T_V15
      ,new_sales_currency_code             T_V15
      ,old_operational_status_code         T_V30
      ,new_operational_status_code         T_V30
      ,full_dump_flag                      T_V30
      );
--
TYPE VERSION_LABEL_REC_TAB IS RECORD
   (
      version_label_id            T_NUM
     ,instance_id                 T_NUM
     ,version_label               T_V240
     ,description                 T_V240
     ,date_time_stamp             T_DATE
     ,active_start_date           T_DATE
     ,active_end_date             T_DATE
     ,context                     T_V30
     ,attribute1                  T_V150
     ,attribute2                  T_V150
     ,attribute3                  T_V150
     ,attribute4                  T_V150
     ,attribute5                  T_V150
     ,attribute6                  T_V150
     ,attribute7                  T_V150
     ,attribute8                  T_V150
     ,attribute9                  T_V150
     ,attribute10                 T_V150
     ,attribute11                 T_V150
     ,attribute12                 T_V150
     ,attribute13                 T_V150
     ,attribute14                 T_V150
     ,attribute15                 T_V150
     ,object_version_number       T_NUM
     ,parent_tbl_index            T_NUM
   );
--
TYPE VER_LABEL_HISTORY_REC_TAB IS RECORD
   (
      VERSION_LABEL_HISTORY_ID           T_NUM
     ,VERSION_LABEL_ID                   T_NUM
     ,TRANSACTION_ID                     T_NUM
     ,OLD_VERSION_LABEL                  T_V30
     ,NEW_VERSION_LABEL                  T_V30
     ,OLD_DESCRIPTION                    T_V240
     ,NEW_DESCRIPTION                    T_V240
     ,OLD_DATE_TIME_STAMP                T_DATE
     ,NEW_DATE_TIME_STAMP                T_DATE
     ,OLD_ACTIVE_START_DATE              T_DATE
     ,NEW_ACTIVE_START_DATE              T_DATE
     ,OLD_ACTIVE_END_DATE                T_DATE
     ,NEW_ACTIVE_END_DATE                T_DATE
     ,OLD_CONTEXT                        T_V30
     ,NEW_CONTEXT                        T_V30
     ,OLD_ATTRIBUTE1                     T_V150
     ,NEW_ATTRIBUTE1                     T_V150
     ,OLD_ATTRIBUTE2                     T_V150
     ,NEW_ATTRIBUTE2                     T_V150
     ,OLD_ATTRIBUTE3                     T_V150
     ,NEW_ATTRIBUTE3                     T_V150
     ,OLD_ATTRIBUTE4                     T_V150
     ,NEW_ATTRIBUTE4                     T_V150
     ,OLD_ATTRIBUTE5                     T_V150
     ,NEW_ATTRIBUTE5                     T_V150
     ,OLD_ATTRIBUTE6                     T_V150
     ,NEW_ATTRIBUTE6                     T_V150
     ,OLD_ATTRIBUTE7                     T_V150
     ,NEW_ATTRIBUTE7                     T_V150
     ,OLD_ATTRIBUTE8                     T_V150
     ,NEW_ATTRIBUTE8                     T_V150
     ,OLD_ATTRIBUTE9                     T_V150
     ,NEW_ATTRIBUTE9                     T_V150
     ,OLD_ATTRIBUTE10                    T_V150
     ,NEW_ATTRIBUTE10                    T_V150
     ,OLD_ATTRIBUTE11                    T_V150
     ,NEW_ATTRIBUTE11                    T_V150
     ,OLD_ATTRIBUTE12                    T_V150
     ,NEW_ATTRIBUTE12                    T_V150
     ,OLD_ATTRIBUTE13                    T_V150
     ,NEW_ATTRIBUTE13                    T_V150
     ,OLD_ATTRIBUTE14                    T_V150
     ,NEW_ATTRIBUTE14                    T_V150
     ,OLD_ATTRIBUTE15                    T_V150
     ,NEW_ATTRIBUTE15                    T_V150
     ,FULL_DUMP_FLAG                     T_V1
     ,OBJECT_VERSION_NUMBER              T_NUM
     ,INSTANCE_ID                        T_NUM
   );
--
TYPE PARTY_REC_TAB IS RECORD
   (
      instance_party_id                      T_NUM
      ,instance_id                           T_NUM
      ,party_source_table                    T_V30
      ,party_id                              T_NUM
      ,relationship_type_code                T_V30
      ,contact_flag                          T_V1
      ,contact_ip_id                         T_NUM
      ,active_start_date                     T_DATE
      ,active_end_date                       T_DATE
      ,context                               T_V30
      ,attribute1                            T_V150
      ,attribute2                            T_V150
      ,attribute3                            T_V150
      ,attribute4                            T_V150
      ,attribute5                            T_V150
      ,attribute6                            T_V150
      ,attribute7                            T_V150
      ,attribute8                            T_V150
      ,attribute9                            T_V150
      ,attribute10                           T_V150
      ,attribute11                           T_V150
      ,attribute12                           T_V150
      ,attribute13                           T_V150
      ,attribute14                           T_V150
      ,attribute15                           T_V150
      ,object_version_number                 T_NUM
      ,primary_flag                          T_V1
      ,preferred_flag                        T_V1
      ,parent_tbl_index                      T_NUM
      ,call_contracts                        T_V1
      ,contact_parent_tbl_index              T_NUM
   );
--
TYPE PARTY_HISTORY_REC_TAB IS RECORD
   (
     INSTANCE_PARTY_HISTORY_ID               T_NUM
     ,INSTANCE_PARTY_ID                      T_NUM
     ,TRANSACTION_ID                         T_NUM
     ,OLD_PARTY_SOURCE_TABLE                 T_V30
     ,NEW_PARTY_SOURCE_TABLE                 T_V30
     ,OLD_PARTY_ID                           T_NUM
     ,NEW_PARTY_ID                           T_NUM
     ,OLD_RELATIONSHIP_TYPE_CODE             T_V30
     ,NEW_RELATIONSHIP_TYPE_CODE             T_V30
     ,OLD_CONTACT_FLAG                       T_V1
     ,NEW_CONTACT_FLAG                       T_V1
     ,OLD_CONTACT_IP_ID                      T_NUM
     ,NEW_CONTACT_IP_ID                      T_NUM
     ,OLD_ACTIVE_START_DATE                  T_DATE
     ,NEW_ACTIVE_START_DATE                  T_DATE
     ,OLD_ACTIVE_END_DATE                    T_DATE
     ,NEW_ACTIVE_END_DATE                    T_DATE
     ,OLD_CONTEXT                            T_V30
     ,NEW_CONTEXT                            T_V30
     ,OLD_ATTRIBUTE1                         T_V150
     ,NEW_ATTRIBUTE1                         T_V150
     ,OLD_ATTRIBUTE2                         T_V150
     ,NEW_ATTRIBUTE2                         T_V150
     ,OLD_ATTRIBUTE3                         T_V150
     ,NEW_ATTRIBUTE3                         T_V150
     ,OLD_ATTRIBUTE4                         T_V150
     ,NEW_ATTRIBUTE4                         T_V150
     ,OLD_ATTRIBUTE5                         T_V150
     ,NEW_ATTRIBUTE5                         T_V150
     ,OLD_ATTRIBUTE6                         T_V150
     ,NEW_ATTRIBUTE6                         T_V150
     ,OLD_ATTRIBUTE7                         T_V150
     ,NEW_ATTRIBUTE7                         T_V150
     ,OLD_ATTRIBUTE8                         T_V150
     ,NEW_ATTRIBUTE8                         T_V150
     ,OLD_ATTRIBUTE9                         T_V150
     ,NEW_ATTRIBUTE9                         T_V150
     ,OLD_ATTRIBUTE10                        T_V150
     ,NEW_ATTRIBUTE10                        T_V150
     ,OLD_ATTRIBUTE11                        T_V150
     ,NEW_ATTRIBUTE11                        T_V150
     ,OLD_ATTRIBUTE12                        T_V150
     ,NEW_ATTRIBUTE12                        T_V150
     ,OLD_ATTRIBUTE13                        T_V150
     ,NEW_ATTRIBUTE13                        T_V150
     ,OLD_ATTRIBUTE14                        T_V150
     ,NEW_ATTRIBUTE14                        T_V150
     ,OLD_ATTRIBUTE15                        T_V150
     ,NEW_ATTRIBUTE15                        T_V150
     ,FULL_DUMP_FLAG                         T_V1
     ,OBJECT_VERSION_NUMBER                  T_NUM
     ,OLD_PREFERRED_FLAG                     T_V1
     ,NEW_PREFERRED_FLAG                     T_V1
     ,OLD_PRIMARY_FLAG                       T_V1
     ,NEW_PRIMARY_FLAG                       T_V1
     ,old_party_number                       T_V30
     ,old_party_name                         T_V360
     ,old_party_type                         T_V30
     ,old_contact_party_number               T_V30
     ,old_contact_party_name                 T_V360
     ,old_contact_party_type                 T_V30
     ,old_contact_address1                   T_V240
     ,old_contact_address2                   T_V240
     ,old_contact_address3                   T_V240
     ,old_contact_address4                   T_V240
     ,old_contact_city                       T_V60
     ,old_contact_state                      T_V60
     ,old_contact_postal_code                T_V60
     ,old_contact_country                    T_V60
     ,old_contact_work_phone_num             T_V85
     ,old_contact_email_address              T_V2000
     ,new_party_number                       T_V30
     ,new_party_name                         T_V360
     ,new_party_type                         T_V30
     ,new_contact_party_number               T_V30
     ,new_contact_party_name                 T_V360
     ,new_contact_party_type                 T_V30
     ,new_contact_address1                   T_V240
     ,new_contact_address2                   T_V240
     ,new_contact_address3                   T_V240
     ,new_contact_address4                   T_V240
     ,new_contact_city                       T_V60
     ,new_contact_state                      T_V60
     ,new_contact_postal_code                T_V60
     ,new_contact_country                    T_V60
     ,new_contact_work_phone_num             T_V85
     ,new_contact_email_address              T_V2000
     ,INSTANCE_ID                            T_NUM
   );
--
TYPE ACCOUNT_REC_TAB IS RECORD
   (
      ip_account_id                 T_NUM
     ,parent_tbl_index              T_NUM
     ,instance_party_id             T_NUM
     ,party_account_id              T_NUM
     ,relationship_type_code        T_V30
     ,bill_to_address               T_NUM
     ,ship_to_address               T_NUM
     ,active_start_date             T_DATE
     ,active_end_date               T_DATE
     ,context                       T_V30
     ,attribute1                    T_V150
     ,attribute2                    T_V150
     ,attribute3                    T_V150
     ,attribute4                    T_V150
     ,attribute5                    T_V150
     ,attribute6                    T_V150
     ,attribute7                    T_V150
     ,attribute8                    T_V150
     ,attribute9                    T_V150
     ,attribute10                   T_V150
     ,attribute11                   T_V150
     ,attribute12                   T_V150
     ,attribute13                   T_V150
     ,attribute14                   T_V150
     ,attribute15                   T_V150
     ,object_version_number         T_NUM
     ,call_contracts                T_V1
     ,vld_organization_id           T_NUM
     ,expire_flag                   T_V1
     ,grp_call_contracts            T_V1
   );
--
TYPE ACCOUNT_HISTORY_REC_TAB IS RECORD
   (
     IP_ACCOUNT_HISTORY_ID             T_NUM
    ,IP_ACCOUNT_ID                     T_NUM
    ,TRANSACTION_ID                    T_NUM
    ,OLD_PARTY_ACCOUNT_ID              T_NUM
    ,NEW_PARTY_ACCOUNT_ID              T_NUM
    ,OLD_RELATIONSHIP_TYPE_CODE        T_V30
    ,NEW_RELATIONSHIP_TYPE_CODE        T_V30
    ,OLD_ACTIVE_START_DATE             T_DATE
    ,NEW_ACTIVE_START_DATE             T_DATE
    ,OLD_ACTIVE_END_DATE               T_DATE
    ,NEW_ACTIVE_END_DATE               T_DATE
    ,OLD_CONTEXT                       T_V30
    ,NEW_CONTEXT                       T_V30
    ,OLD_ATTRIBUTE1                    T_V150
    ,NEW_ATTRIBUTE1                    T_V150
    ,OLD_ATTRIBUTE2                    T_V150
    ,NEW_ATTRIBUTE2                    T_V150
    ,OLD_ATTRIBUTE3                    T_V150
    ,NEW_ATTRIBUTE3                    T_V150
    ,OLD_ATTRIBUTE4                    T_V150
    ,NEW_ATTRIBUTE4                    T_V150
    ,OLD_ATTRIBUTE5                    T_V150
    ,NEW_ATTRIBUTE5                    T_V150
    ,OLD_ATTRIBUTE6                    T_V150
    ,NEW_ATTRIBUTE6                    T_V150
    ,OLD_ATTRIBUTE7                    T_V150
    ,NEW_ATTRIBUTE7                    T_V150
    ,OLD_ATTRIBUTE8                    T_V150
    ,NEW_ATTRIBUTE8                    T_V150
    ,OLD_ATTRIBUTE9                    T_V150
    ,NEW_ATTRIBUTE9                    T_V150
    ,OLD_ATTRIBUTE10                   T_V150
    ,NEW_ATTRIBUTE10                   T_V150
    ,OLD_ATTRIBUTE11                   T_V150
    ,NEW_ATTRIBUTE11                   T_V150
    ,OLD_ATTRIBUTE12                   T_V150
    ,NEW_ATTRIBUTE12                   T_V150
    ,OLD_ATTRIBUTE13                   T_V150
    ,NEW_ATTRIBUTE13                   T_V150
    ,OLD_ATTRIBUTE14                   T_V150
    ,NEW_ATTRIBUTE14                   T_V150
    ,OLD_ATTRIBUTE15                   T_V150
    ,NEW_ATTRIBUTE15                   T_V150
    ,FULL_DUMP_FLAG                    T_V1
    ,OBJECT_VERSION_NUMBER             T_NUM
    ,OLD_BILL_TO_ADDRESS               T_NUM
    ,NEW_BILL_TO_ADDRESS               T_NUM
    ,OLD_SHIP_TO_ADDRESS               T_NUM
    ,NEW_SHIP_TO_ADDRESS               T_NUM
    ,old_party_account_number          T_V30
    ,old_party_account_name            T_V240
    ,old_bill_to_location              T_V40
    ,old_ship_to_location              T_V40
    ,new_party_account_number          T_V30
    ,new_party_account_name            T_V240
    ,new_bill_to_location              T_V40
    ,new_ship_to_location              T_V40
    ,INSTANCE_ID                       T_NUM
   );
--
TYPE TRANSACTION_REC_TAB IS RECORD
   (
      TRANSACTION_ID                   T_NUM,
      TRANSACTION_DATE                 T_DATE,
      SOURCE_TRANSACTION_DATE          T_DATE,
      TRANSACTION_TYPE_ID              T_NUM,
      TXN_SUB_TYPE_ID                  T_NUM,
      SOURCE_GROUP_REF_ID              T_NUM,
      SOURCE_GROUP_REF                 T_V50,
      SOURCE_HEADER_REF_ID             T_NUM,
      SOURCE_HEADER_REF                T_V50,
      SOURCE_LINE_REF_ID               T_NUM,
      SOURCE_LINE_REF                  T_V50,
      SOURCE_DIST_REF_ID1              T_NUM,
      SOURCE_DIST_REF_ID2              T_NUM,
      INV_MATERIAL_TRANSACTION_ID      T_NUM,
      TRANSACTION_QUANTITY             T_NUM,
      TRANSACTION_UOM_CODE             T_V3,
      TRANSACTED_BY                    T_NUM,
      TRANSACTION_STATUS_CODE          T_V30,
      TRANSACTION_ACTION_CODE          T_V30,
      MESSAGE_ID                       T_NUM,
      CONTEXT                          T_V30,
      ATTRIBUTE1                       T_V150,
      ATTRIBUTE2                       T_V150,
      ATTRIBUTE3                       T_V150,
      ATTRIBUTE4                       T_V150,
      ATTRIBUTE5                       T_V150,
      ATTRIBUTE6                       T_V150,
      ATTRIBUTE7                       T_V150,
      ATTRIBUTE8                       T_V150,
      ATTRIBUTE9                       T_V150,
      ATTRIBUTE10                      T_V150,
      ATTRIBUTE11                      T_V150,
      ATTRIBUTE12                      T_V150,
      ATTRIBUTE13                      T_V150,
      ATTRIBUTE14                      T_V150,
      ATTRIBUTE15                      T_V150,
      OBJECT_VERSION_NUMBER            T_NUM,
      SPLIT_REASON_CODE                T_V30,
      GL_INTERFACE_STATUS_CODE         T_NUM
   );
--
TYPE org_units_rec_tab IS RECORD
   (
      instance_ou_id                 T_NUM
     ,instance_id                    T_NUM
     ,operating_unit_id              T_NUM
     ,relationship_type_code         T_V30
     ,active_start_date              T_DATE
     ,active_end_date                T_DATE
     ,context                        T_V30
     ,attribute1                     T_V150
     ,attribute2                     T_V150
     ,attribute3                     T_V150
     ,attribute4                     T_V150
     ,attribute5                     T_V150
     ,attribute6                     T_V150
     ,attribute7                     T_V150
     ,attribute8                     T_V150
     ,attribute9                     T_V150
     ,attribute10                    T_V150
     ,attribute11                    T_V150
     ,attribute12                    T_V150
     ,attribute13                    T_V150
     ,attribute14                    T_V150
     ,attribute15                    T_V150
     ,object_version_number          T_NUM
     ,parent_tbl_index               T_NUM
   );
--
TYPE ORG_UNITS_HISTORY_REC_TAB IS RECORD
  (
    INSTANCE_OU_HISTORY_ID     T_NUM
   ,INSTANCE_OU_ID             T_NUM
   ,TRANSACTION_ID             T_NUM
   ,OLD_OPERATING_UNIT_ID      T_NUM
   ,NEW_OPERATING_UNIT_ID      T_NUM
   ,OLD_RELATIONSHIP_TYPE_CODE T_V30
   ,NEW_RELATIONSHIP_TYPE_CODE T_V30
   ,OLD_ACTIVE_START_DATE      T_DATE
   ,NEW_ACTIVE_START_DATE      T_DATE
   ,OLD_ACTIVE_END_DATE        T_DATE
   ,NEW_ACTIVE_END_DATE        T_DATE
   ,OLD_CONTEXT                T_V30
   ,NEW_CONTEXT                T_V30
   ,OLD_ATTRIBUTE1             T_V150
   ,NEW_ATTRIBUTE1             T_V150
   ,OLD_ATTRIBUTE2             T_V150
   ,NEW_ATTRIBUTE2             T_V150
   ,OLD_ATTRIBUTE3             T_V150
   ,NEW_ATTRIBUTE3             T_V150
   ,OLD_ATTRIBUTE4             T_V150
   ,NEW_ATTRIBUTE4             T_V150
   ,OLD_ATTRIBUTE5             T_V150
   ,NEW_ATTRIBUTE5             T_V150
   ,OLD_ATTRIBUTE6             T_V150
   ,NEW_ATTRIBUTE6             T_V150
   ,OLD_ATTRIBUTE7             T_V150
   ,NEW_ATTRIBUTE7             T_V150
   ,OLD_ATTRIBUTE8             T_V150
   ,NEW_ATTRIBUTE8             T_V150
   ,OLD_ATTRIBUTE9             T_V150
   ,NEW_ATTRIBUTE9             T_V150
   ,OLD_ATTRIBUTE10            T_V150
   ,NEW_ATTRIBUTE10            T_V150
   ,OLD_ATTRIBUTE11            T_V150
   ,NEW_ATTRIBUTE11            T_V150
   ,OLD_ATTRIBUTE12            T_V150
   ,NEW_ATTRIBUTE12            T_V150
   ,OLD_ATTRIBUTE13            T_V150
   ,NEW_ATTRIBUTE13            T_V150
   ,OLD_ATTRIBUTE14            T_V150
   ,NEW_ATTRIBUTE14            T_V150
   ,OLD_ATTRIBUTE15            T_V150
   ,NEW_ATTRIBUTE15            T_V150
   ,FULL_DUMP_FLAG             T_V1
   ,OBJECT_VERSION_NUMBER      T_NUM
   ,NEW_OPERATING_UNIT_NAME    T_V60
   ,OLD_OPERATING_UNIT_NAME    T_V60
   ,INSTANCE_ID                T_NUM
  );
--
TYPE extend_attrib_values_rec_tab IS RECORD
 (
     attribute_value_id      T_NUM,
     instance_id             T_NUM,
     attribute_id            T_NUM,
     attribute_code          T_V30,
     attribute_value         T_V240,
     active_start_date       T_DATE,
     active_end_date         T_DATE,
     context                 T_V30,
     attribute1              T_V150,
     attribute2              T_V150,
     attribute3              T_V150,
     attribute4              T_V150,
     attribute5              T_V150,
     attribute6              T_V150,
     attribute7              T_V150,
     attribute8              T_V150,
     attribute9              T_V150,
     attribute10             T_V150,
     attribute11             T_V150,
     attribute12             T_V150,
     attribute13             T_V150,
     attribute14             T_V150,
     attribute15             T_V150,
     object_version_number   T_NUM,
     parent_tbl_index        T_NUM
);
--
TYPE ext_attrib_val_hist_rec_tab IS RECORD
  (
      attribute_value_history_id          T_NUM,
      attribute_value_id                  T_NUM,
      transaction_id                      T_NUM,
      old_attribute_value                 T_V240,
      new_attribute_value                 T_V240,
      old_active_start_date               T_DATE,
      new_active_start_date               T_DATE,
      old_active_end_date                 T_DATE,
      new_active_end_date                 T_DATE,
      old_context                         T_V30,
      new_context                         T_V30,
      old_attribute1                      T_V150,
      new_attribute1                      T_V150,
      old_attribute2                      T_V150,
      new_attribute2                      T_V150,
      old_attribute3                      T_V150,
      new_attribute3                      T_V150,
      old_attribute4                      T_V150,
      new_attribute4                      T_V150,
      old_attribute5                      T_V150,
      new_attribute5                      T_V150,
      old_attribute6                      T_V150,
      new_attribute6                      T_V150,
      old_attribute7                      T_V150,
      new_attribute7                      T_V150,
      old_attribute8                      T_V150,
      new_attribute8                      T_V150,
      old_attribute9                      T_V150,
      new_attribute9                      T_V150,
      old_attribute10                     T_V150,
      new_attribute10                     T_V150,
      old_attribute11                     T_V150,
      new_attribute11                     T_V150,
      old_attribute12                     T_V150,
      new_attribute12                     T_V150,
      old_attribute13                     T_V150,
      new_attribute13                     T_V150,
      old_attribute14                     T_V150,
      new_attribute14                     T_V150,
      old_attribute15                     T_V150,
      new_attribute15                     T_V150,
      attribute_code                      T_V30,
      instance_id                         T_NUM
);
--
TYPE instance_asset_rec_tab IS RECORD
 (
     instance_asset_id          T_NUM,
     instance_id                T_NUM,
     fa_asset_id                T_NUM,
     fa_book_type_code          T_V15,
     fa_location_id             T_NUM,
     asset_quantity             T_NUM,
     update_status              T_V30,
     active_start_date          T_DATE,
     active_end_date            T_DATE,
     object_version_number      T_NUM,
     check_for_instance_expiry  T_V1,
     parent_tbl_index           T_NUM,
     fa_sync_flag               T_V1
);
--
TYPE ins_asset_history_rec_tab IS RECORD
 (
     instance_asset_history_id            T_NUM,
     transaction_id                       T_NUM,
     instance_asset_id                    T_NUM,
     old_instance_id                      T_NUM,
     new_instance_id                      T_NUM,
     old_fa_asset_id                      T_NUM,
     new_fa_asset_id                      T_NUM,
     old_fa_book_type_code                T_V15,
     new_fa_book_type_code                T_V15,
     old_fa_location_id                   T_NUM,
     new_fa_location_id                   T_NUM,
     old_asset_quantity                   T_NUM,
     new_asset_quantity                   T_NUM,
     old_update_status                    T_V30,
     new_update_status                    T_V30,
     old_active_start_date                T_DATE,
     new_active_start_date                T_DATE,
     old_active_end_date                  T_DATE,
     new_active_end_date                  T_DATE,
     old_asset_number                     T_V15,
     new_asset_number                     T_V15,
     old_serial_number                    T_V35,
     new_serial_number                    T_V35,
     old_tag_number                       T_V15,
     new_tag_number                       T_V15,
     old_category                         T_V60,
     new_category                         T_V60,
     old_fa_location_segment1             T_V30,
     new_fa_location_segment1             T_V30,
     old_fa_location_segment2             T_V30,
     new_fa_location_segment2             T_V30,
     old_fa_location_segment3             T_V30,
     new_fa_location_segment3             T_V30,
     old_fa_location_segment4             T_V30,
     new_fa_location_segment4             T_V30,
     old_fa_location_segment5             T_V30,
     new_fa_location_segment5             T_V30,
     old_fa_location_segment6             T_V30,
     new_fa_location_segment6             T_V30,
     old_fa_location_segment7             T_V30,
     new_fa_location_segment7             T_V30,
     old_date_placed_in_service           T_DATE,
     new_date_placed_in_service           T_DATE,
     old_description                      T_V80,
     new_description                      T_V80,
     old_employee_name                    T_V240,
     new_employee_name                    T_V240,
     old_expense_account_number           T_V25,
     new_expense_account_number           T_V25,
     instance_id                          T_NUM,
     old_fa_sync_flag                     T_V1,
     new_fa_sync_flag                     T_V1
);
--
TYPE PRICING_ATTRIBS_REC_TAB IS RECORD
(
  pricing_attribute_id            T_NUM
 ,instance_id                     T_NUM
 ,active_start_date               T_DATE
 ,active_end_date                 T_DATE
 ,pricing_context                 T_V30
 ,pricing_attribute1              T_V150
 ,pricing_attribute2              T_V150
 ,pricing_attribute3              T_V150
 ,pricing_attribute4              T_V150
 ,pricing_attribute5              T_V150
 ,pricing_attribute6              T_V150
 ,pricing_attribute7              T_V150
 ,pricing_attribute8              T_V150
 ,pricing_attribute9              T_V150
 ,pricing_attribute10              T_V150
 ,pricing_attribute11              T_V150
 ,pricing_attribute12              T_V150
 ,pricing_attribute13              T_V150
 ,pricing_attribute14              T_V150
 ,pricing_attribute15              T_V150
 ,pricing_attribute16              T_V150
 ,pricing_attribute17              T_V150
 ,pricing_attribute18              T_V150
 ,pricing_attribute19              T_V150
 ,pricing_attribute20              T_V150
 ,pricing_attribute21              T_V150
 ,pricing_attribute22              T_V150
 ,pricing_attribute23              T_V150
 ,pricing_attribute24              T_V150
 ,pricing_attribute25              T_V150
 ,pricing_attribute26              T_V150
 ,pricing_attribute27              T_V150
 ,pricing_attribute28              T_V150
 ,pricing_attribute29              T_V150
 ,pricing_attribute30              T_V150
 ,pricing_attribute31              T_V150
 ,pricing_attribute32              T_V150
 ,pricing_attribute33              T_V150
 ,pricing_attribute34              T_V150
 ,pricing_attribute35              T_V150
 ,pricing_attribute36              T_V150
 ,pricing_attribute37              T_V150
 ,pricing_attribute38              T_V150
 ,pricing_attribute39              T_V150
 ,pricing_attribute40              T_V150
 ,pricing_attribute41              T_V150
 ,pricing_attribute42              T_V150
 ,pricing_attribute43              T_V150
 ,pricing_attribute44              T_V150
 ,pricing_attribute45              T_V150
 ,pricing_attribute46              T_V150
 ,pricing_attribute47              T_V150
 ,pricing_attribute48              T_V150
 ,pricing_attribute49              T_V150
 ,pricing_attribute50              T_V150
 ,pricing_attribute51              T_V150
 ,pricing_attribute52              T_V150
 ,pricing_attribute53              T_V150
 ,pricing_attribute54              T_V150
 ,pricing_attribute55              T_V150
 ,pricing_attribute56              T_V150
 ,pricing_attribute57              T_V150
 ,pricing_attribute58              T_V150
 ,pricing_attribute59              T_V150
 ,pricing_attribute60              T_V150
 ,pricing_attribute61              T_V150
 ,pricing_attribute62              T_V150
 ,pricing_attribute63              T_V150
 ,pricing_attribute64              T_V150
 ,pricing_attribute65              T_V150
 ,pricing_attribute66              T_V150
 ,pricing_attribute67              T_V150
 ,pricing_attribute68              T_V150
 ,pricing_attribute69              T_V150
 ,pricing_attribute70              T_V150
 ,pricing_attribute71              T_V150
 ,pricing_attribute72              T_V150
 ,pricing_attribute73              T_V150
 ,pricing_attribute74              T_V150
 ,pricing_attribute75              T_V150
 ,pricing_attribute76              T_V150
 ,pricing_attribute77              T_V150
 ,pricing_attribute78              T_V150
 ,pricing_attribute79              T_V150
 ,pricing_attribute80              T_V150
 ,pricing_attribute81              T_V150
 ,pricing_attribute82              T_V150
 ,pricing_attribute83              T_V150
 ,pricing_attribute84              T_V150
 ,pricing_attribute85              T_V150
 ,pricing_attribute86              T_V150
 ,pricing_attribute87              T_V150
 ,pricing_attribute88              T_V150
 ,pricing_attribute89              T_V150
 ,pricing_attribute90              T_V150
 ,pricing_attribute91              T_V150
 ,pricing_attribute92              T_V150
 ,pricing_attribute93              T_V150
 ,pricing_attribute94              T_V150
 ,pricing_attribute95              T_V150
 ,pricing_attribute96              T_V150
 ,pricing_attribute97              T_V150
 ,pricing_attribute98              T_V150
 ,pricing_attribute99              T_V150
 ,pricing_attribute100              T_V150
 ,context                          T_V30
 ,attribute1                       T_V150
 ,attribute2                       T_V150
 ,attribute3                       T_V150
 ,attribute4                       T_V150
 ,attribute5                       T_V150
 ,attribute6                       T_V150
 ,attribute7                       T_V150
 ,attribute8                       T_V150
 ,attribute9                       T_V150
 ,attribute10                      T_V150
 ,attribute11                      T_V150
 ,attribute12                      T_V150
 ,attribute13                      T_V150
 ,attribute14                      T_V150
 ,attribute15                      T_V150
 ,object_version_number            T_NUM
 ,parent_tbl_index                 T_NUM
);
--
TYPE PRICING_ATTRIBS_HIST_REC_TAB IS RECORD
(
  PRICE_ATTRIB_HISTORY_ID              T_NUM
  ,PRICING_ATTRIBUTE_ID                 T_NUM
  ,TRANSACTION_ID                       T_NUM
  ,OLD_PRICING_CONTEXT                  T_V30
  ,NEW_PRICING_CONTEXT                  T_V30
  ,OLD_PRICING_ATTRIBUTE1               T_V150
  ,NEW_PRICING_ATTRIBUTE1               T_V150
  ,OLD_PRICING_ATTRIBUTE2               T_V150
  ,NEW_PRICING_ATTRIBUTE2               T_V150
  ,OLD_PRICING_ATTRIBUTE3               T_V150
  ,NEW_PRICING_ATTRIBUTE3               T_V150
  ,OLD_PRICING_ATTRIBUTE4               T_V150
  ,NEW_PRICING_ATTRIBUTE4               T_V150
  ,OLD_PRICING_ATTRIBUTE5               T_V150
  ,NEW_PRICING_ATTRIBUTE5               T_V150
  ,OLD_PRICING_ATTRIBUTE6               T_V150
  ,NEW_PRICING_ATTRIBUTE6               T_V150
  ,OLD_PRICING_ATTRIBUTE7               T_V150
  ,NEW_PRICING_ATTRIBUTE7               T_V150
  ,OLD_PRICING_ATTRIBUTE8               T_V150
  ,NEW_PRICING_ATTRIBUTE8               T_V150
  ,OLD_PRICING_ATTRIBUTE9               T_V150
  ,NEW_PRICING_ATTRIBUTE9               T_V150
  ,OLD_PRICING_ATTRIBUTE10              T_V150
  ,NEW_PRICING_ATTRIBUTE10              T_V150
  ,OLD_PRICING_ATTRIBUTE11              T_V150
  ,NEW_PRICING_ATTRIBUTE11              T_V150
  ,OLD_PRICING_ATTRIBUTE12              T_V150
  ,NEW_PRICING_ATTRIBUTE12              T_V150
  ,OLD_PRICING_ATTRIBUTE13              T_V150
  ,NEW_PRICING_ATTRIBUTE13              T_V150
  ,OLD_PRICING_ATTRIBUTE14              T_V150
  ,NEW_PRICING_ATTRIBUTE14              T_V150
  ,OLD_PRICING_ATTRIBUTE15              T_V150
  ,NEW_PRICING_ATTRIBUTE15              T_V150
  ,OLD_PRICING_ATTRIBUTE16              T_V150
  ,NEW_PRICING_ATTRIBUTE16              T_V150
  ,OLD_PRICING_ATTRIBUTE17              T_V150
  ,NEW_PRICING_ATTRIBUTE17              T_V150
  ,OLD_PRICING_ATTRIBUTE18              T_V150
  ,NEW_PRICING_ATTRIBUTE18              T_V150
  ,OLD_PRICING_ATTRIBUTE19              T_V150
  ,NEW_PRICING_ATTRIBUTE19              T_V150
  ,OLD_PRICING_ATTRIBUTE20              T_V150
  ,NEW_PRICING_ATTRIBUTE20              T_V150
  ,OLD_PRICING_ATTRIBUTE21              T_V150
  ,NEW_PRICING_ATTRIBUTE21              T_V150
  ,OLD_PRICING_ATTRIBUTE22              T_V150
  ,NEW_PRICING_ATTRIBUTE22              T_V150
  ,OLD_PRICING_ATTRIBUTE23              T_V150
  ,NEW_PRICING_ATTRIBUTE23              T_V150
  ,OLD_PRICING_ATTRIBUTE24              T_V150
  ,NEW_PRICING_ATTRIBUTE24              T_V150
  ,NEW_PRICING_ATTRIBUTE25              T_V150
  ,OLD_PRICING_ATTRIBUTE25              T_V150
  ,OLD_PRICING_ATTRIBUTE26              T_V150
  ,NEW_PRICING_ATTRIBUTE26              T_V150
  ,OLD_PRICING_ATTRIBUTE27              T_V150
  ,NEW_PRICING_ATTRIBUTE27              T_V150
  ,OLD_PRICING_ATTRIBUTE28              T_V150
  ,NEW_PRICING_ATTRIBUTE28              T_V150
  ,OLD_PRICING_ATTRIBUTE29              T_V150
  ,NEW_PRICING_ATTRIBUTE29              T_V150
  ,OLD_PRICING_ATTRIBUTE30              T_V150
  ,NEW_PRICING_ATTRIBUTE30              T_V150
  ,OLD_PRICING_ATTRIBUTE31              T_V150
  ,NEW_PRICING_ATTRIBUTE31              T_V150
  ,OLD_PRICING_ATTRIBUTE32              T_V150
  ,NEW_PRICING_ATTRIBUTE32              T_V150
  ,OLD_PRICING_ATTRIBUTE33              T_V150
  ,NEW_PRICING_ATTRIBUTE33              T_V150
  ,OLD_PRICING_ATTRIBUTE34              T_V150
  ,NEW_PRICING_ATTRIBUTE34              T_V150
  ,OLD_PRICING_ATTRIBUTE35              T_V150
  ,NEW_PRICING_ATTRIBUTE35              T_V150
  ,OLD_PRICING_ATTRIBUTE36              T_V150
  ,NEW_PRICING_ATTRIBUTE36              T_V150
  ,OLD_PRICING_ATTRIBUTE37              T_V150
  ,NEW_PRICING_ATTRIBUTE37              T_V150
  ,OLD_PRICING_ATTRIBUTE38              T_V150
  ,NEW_PRICING_ATTRIBUTE38              T_V150
  ,OLD_PRICING_ATTRIBUTE39              T_V150
  ,NEW_PRICING_ATTRIBUTE39              T_V150
  ,OLD_PRICING_ATTRIBUTE40              T_V150
  ,NEW_PRICING_ATTRIBUTE40              T_V150
  ,OLD_PRICING_ATTRIBUTE41              T_V150
  ,NEW_PRICING_ATTRIBUTE41              T_V150
  ,OLD_PRICING_ATTRIBUTE42              T_V150
  ,NEW_PRICING_ATTRIBUTE42              T_V150
  ,OLD_PRICING_ATTRIBUTE43              T_V150
  ,NEW_PRICING_ATTRIBUTE43              T_V150
  ,OLD_PRICING_ATTRIBUTE44              T_V150
  ,NEW_PRICING_ATTRIBUTE44              T_V150
  ,OLD_PRICING_ATTRIBUTE45              T_V150
  ,NEW_PRICING_ATTRIBUTE45              T_V150
  ,OLD_PRICING_ATTRIBUTE46              T_V150
  ,NEW_PRICING_ATTRIBUTE46              T_V150
  ,OLD_PRICING_ATTRIBUTE47              T_V150
  ,NEW_PRICING_ATTRIBUTE47              T_V150
  ,OLD_PRICING_ATTRIBUTE48              T_V150
  ,NEW_PRICING_ATTRIBUTE48              T_V150
  ,OLD_PRICING_ATTRIBUTE49              T_V150
  ,NEW_PRICING_ATTRIBUTE49              T_V150
  ,OLD_PRICING_ATTRIBUTE50              T_V150
  ,NEW_PRICING_ATTRIBUTE50              T_V150
  ,OLD_PRICING_ATTRIBUTE51              T_V150
  ,NEW_PRICING_ATTRIBUTE51              T_V150
  ,OLD_PRICING_ATTRIBUTE52              T_V150
  ,NEW_PRICING_ATTRIBUTE52              T_V150
  ,OLD_PRICING_ATTRIBUTE53              T_V150
  ,NEW_PRICING_ATTRIBUTE53              T_V150
  ,OLD_PRICING_ATTRIBUTE54              T_V150
  ,NEW_PRICING_ATTRIBUTE54              T_V150
  ,OLD_PRICING_ATTRIBUTE55              T_V150
  ,NEW_PRICING_ATTRIBUTE55              T_V150
  ,OLD_PRICING_ATTRIBUTE56              T_V150
  ,NEW_PRICING_ATTRIBUTE56              T_V150
  ,OLD_PRICING_ATTRIBUTE57              T_V150
  ,NEW_PRICING_ATTRIBUTE57              T_V150
  ,OLD_PRICING_ATTRIBUTE58              T_V150
  ,NEW_PRICING_ATTRIBUTE58              T_V150
  ,OLD_PRICING_ATTRIBUTE59              T_V150
  ,NEW_PRICING_ATTRIBUTE59              T_V150
  ,OLD_PRICING_ATTRIBUTE60              T_V150
  ,NEW_PRICING_ATTRIBUTE60              T_V150
  ,OLD_PRICING_ATTRIBUTE61              T_V150
  ,NEW_PRICING_ATTRIBUTE61              T_V150
  ,OLD_PRICING_ATTRIBUTE62              T_V150
  ,NEW_PRICING_ATTRIBUTE62              T_V150
  ,OLD_PRICING_ATTRIBUTE63              T_V150
  ,NEW_PRICING_ATTRIBUTE63              T_V150
  ,OLD_PRICING_ATTRIBUTE64              T_V150
  ,NEW_PRICING_ATTRIBUTE64              T_V150
  ,OLD_PRICING_ATTRIBUTE65              T_V150
  ,NEW_PRICING_ATTRIBUTE65              T_V150
  ,OLD_PRICING_ATTRIBUTE66              T_V150
  ,NEW_PRICING_ATTRIBUTE66              T_V150
  ,OLD_PRICING_ATTRIBUTE67              T_V150
  ,NEW_PRICING_ATTRIBUTE67              T_V150
  ,OLD_PRICING_ATTRIBUTE68              T_V150
  ,NEW_PRICING_ATTRIBUTE68              T_V150
  ,OLD_PRICING_ATTRIBUTE69              T_V150
  ,NEW_PRICING_ATTRIBUTE69              T_V150
  ,OLD_PRICING_ATTRIBUTE70              T_V150
  ,NEW_PRICING_ATTRIBUTE70              T_V150
  ,OLD_PRICING_ATTRIBUTE71              T_V150
  ,NEW_PRICING_ATTRIBUTE71              T_V150
  ,OLD_PRICING_ATTRIBUTE72              T_V150
  ,NEW_PRICING_ATTRIBUTE72              T_V150
  ,OLD_PRICING_ATTRIBUTE73              T_V150
  ,NEW_PRICING_ATTRIBUTE73              T_V150
  ,OLD_PRICING_ATTRIBUTE74              T_V150
  ,NEW_PRICING_ATTRIBUTE74              T_V150
  ,OLD_PRICING_ATTRIBUTE75              T_V150
  ,NEW_PRICING_ATTRIBUTE75              T_V150
  ,OLD_PRICING_ATTRIBUTE76              T_V150
  ,NEW_PRICING_ATTRIBUTE76              T_V150
  ,OLD_PRICING_ATTRIBUTE77              T_V150
  ,NEW_PRICING_ATTRIBUTE77              T_V150
  ,OLD_PRICING_ATTRIBUTE78              T_V150
  ,NEW_PRICING_ATTRIBUTE78              T_V150
  ,OLD_PRICING_ATTRIBUTE79              T_V150
  ,NEW_PRICING_ATTRIBUTE79              T_V150
  ,OLD_PRICING_ATTRIBUTE80              T_V150
  ,NEW_PRICING_ATTRIBUTE80              T_V150
  ,OLD_PRICING_ATTRIBUTE81              T_V150
  ,NEW_PRICING_ATTRIBUTE81              T_V150
  ,OLD_PRICING_ATTRIBUTE82              T_V150
  ,NEW_PRICING_ATTRIBUTE82              T_V150
  ,OLD_PRICING_ATTRIBUTE83              T_V150
  ,NEW_PRICING_ATTRIBUTE83              T_V150
  ,OLD_PRICING_ATTRIBUTE84              T_V150
  ,NEW_PRICING_ATTRIBUTE84              T_V150
  ,OLD_PRICING_ATTRIBUTE85              T_V150
  ,NEW_PRICING_ATTRIBUTE85              T_V150
  ,OLD_PRICING_ATTRIBUTE86              T_V150
  ,NEW_PRICING_ATTRIBUTE86              T_V150
  ,OLD_PRICING_ATTRIBUTE87              T_V150
  ,NEW_PRICING_ATTRIBUTE87              T_V150
  ,OLD_PRICING_ATTRIBUTE88              T_V150
  ,NEW_PRICING_ATTRIBUTE88              T_V150
  ,OLD_PRICING_ATTRIBUTE89              T_V150
  ,NEW_PRICING_ATTRIBUTE89              T_V150
  ,OLD_PRICING_ATTRIBUTE90              T_V150
  ,NEW_PRICING_ATTRIBUTE90              T_V150
  ,OLD_PRICING_ATTRIBUTE91              T_V150
  ,NEW_PRICING_ATTRIBUTE91              T_V150
  ,OLD_PRICING_ATTRIBUTE92              T_V150
  ,NEW_PRICING_ATTRIBUTE92              T_V150
  ,OLD_PRICING_ATTRIBUTE93              T_V150
  ,NEW_PRICING_ATTRIBUTE93              T_V150
  ,OLD_PRICING_ATTRIBUTE94              T_V150
  ,NEW_PRICING_ATTRIBUTE94              T_V150
  ,OLD_PRICING_ATTRIBUTE95              T_V150
  ,NEW_PRICING_ATTRIBUTE95              T_V150
  ,OLD_PRICING_ATTRIBUTE96              T_V150
  ,NEW_PRICING_ATTRIBUTE96              T_V150
  ,OLD_PRICING_ATTRIBUTE97              T_V150
  ,NEW_PRICING_ATTRIBUTE97              T_V150
  ,OLD_PRICING_ATTRIBUTE98              T_V150
  ,NEW_PRICING_ATTRIBUTE98              T_V150
  ,OLD_PRICING_ATTRIBUTE99              T_V150
  ,NEW_PRICING_ATTRIBUTE99              T_V150
  ,OLD_PRICING_ATTRIBUTE100             T_V150
  ,NEW_PRICING_ATTRIBUTE100             T_V150
  ,OLD_ACTIVE_START_DATE                T_DATE
  ,NEW_ACTIVE_START_DATE                T_DATE
  ,OLD_ACTIVE_END_DATE                  T_DATE
  ,NEW_ACTIVE_END_DATE                  T_DATE
  ,OLD_CONTEXT                          T_V30
  ,NEW_CONTEXT                          T_V30
  ,OLD_ATTRIBUTE1                       T_V150
  ,NEW_ATTRIBUTE1                       T_V150
  ,OLD_ATTRIBUTE2                       T_V150
  ,NEW_ATTRIBUTE2                       T_V150
  ,OLD_ATTRIBUTE3                       T_V150
  ,NEW_ATTRIBUTE3                       T_V150
  ,OLD_ATTRIBUTE4                       T_V150
  ,NEW_ATTRIBUTE4                       T_V150
  ,OLD_ATTRIBUTE5                       T_V150
  ,NEW_ATTRIBUTE5                       T_V150
  ,OLD_ATTRIBUTE6                       T_V150
  ,NEW_ATTRIBUTE6                       T_V150
  ,OLD_ATTRIBUTE7                       T_V150
  ,NEW_ATTRIBUTE7                       T_V150
  ,OLD_ATTRIBUTE8                       T_V150
  ,NEW_ATTRIBUTE8                       T_V150
  ,OLD_ATTRIBUTE9                       T_V150
  ,NEW_ATTRIBUTE9                       T_V150
  ,OLD_ATTRIBUTE10                      T_V150
  ,NEW_ATTRIBUTE10                      T_V150
  ,OLD_ATTRIBUTE11                      T_V150
  ,NEW_ATTRIBUTE11                      T_V150
  ,OLD_ATTRIBUTE12                      T_V150
  ,NEW_ATTRIBUTE12                      T_V150
  ,OLD_ATTRIBUTE13                      T_V150
  ,NEW_ATTRIBUTE13                      T_V150
  ,OLD_ATTRIBUTE14                      T_V150
  ,NEW_ATTRIBUTE14                      T_V150
  ,OLD_ATTRIBUTE15                      T_V150
  ,NEW_ATTRIBUTE15                      T_V150
  ,FULL_DUMP_FLAG                       T_V1
);
--

--
 TYPE child_inst_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE lock_item_instances
 (
     p_api_version           IN   NUMBER
    ,p_commit                IN   VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN   VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN   NUMBER := fnd_api.g_valid_level_full
    ,px_config_tbl           IN   OUT NOCOPY csi_cz_int.config_tbl
  --  ,p_txn_rec               IN   OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
 );

PROCEDURE unlock_item_instances
 (
     p_api_version           IN   NUMBER
    ,p_commit                IN   VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN   VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN   NUMBER := fnd_api.g_valid_level_full
    ,p_config_tbl            IN   csi_cz_int.config_tbl
   -- ,p_txn_rec               IN   OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
 );

FUNCTION check_item_instance_lock
(    p_instance_id         IN  NUMBER :=fnd_api.g_miss_num,
     p_config_inst_hdr_id  IN  NUMBER :=fnd_api.g_miss_num,
     p_config_inst_item_id IN  NUMBER :=fnd_api.g_miss_num,
     p_config_inst_rev_num IN  NUMBER :=fnd_api.g_miss_num
) RETURN BOOLEAN;

--
/*----------------------------------------------------*/
/* procedure name: create_item_instance_grp           */
/* description :   procedure used to                  */
/*                 create item instances              */
/*----------------------------------------------------*/

PROCEDURE create_item_instance
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
    ,p_instance_tbl          IN OUT NOCOPY csi_datastructures_pub.instance_tbl
    ,p_ext_attrib_values_tbl IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN OUT NOCOPY csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN OUT NOCOPY csi_datastructures_pub.party_account_tbl
    ,p_pricing_attrib_tbl    IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl
    ,p_org_assignments_tbl   IN OUT NOCOPY csi_datastructures_pub.organization_units_tbl
    ,p_asset_assignment_tbl  IN OUT NOCOPY csi_datastructures_pub.instance_asset_tbl
    ,p_txn_tbl               IN OUT NOCOPY csi_datastructures_pub.transaction_tbl
    ,p_call_from_bom_expl    IN     VARCHAR2 DEFAULT fnd_api.g_false
    ,p_grp_error_tbl         OUT NOCOPY    csi_datastructures_pub.grp_error_tbl
    ,x_return_status         OUT NOCOPY    VARCHAR2
    ,x_msg_count             OUT NOCOPY    NUMBER
    ,x_msg_data              OUT NOCOPY    VARCHAR2
 );

/*----------------------------------------------------*/
/* Procedure name: update_item_instance               */
/* Description :   procedure used to update an Item   */
/*                 Instance                           */
/*----------------------------------------------------*/

PROCEDURE update_item_instance
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
    ,p_instance_tbl          IN OUT NOCOPY csi_datastructures_pub.instance_tbl
    ,p_ext_attrib_values_tbl IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN OUT NOCOPY csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN OUT NOCOPY csi_datastructures_pub.party_account_tbl
    ,p_pricing_attrib_tbl    IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl
    ,p_org_assignments_tbl   IN OUT NOCOPY csi_datastructures_pub.organization_units_tbl
    ,p_asset_assignment_tbl  IN OUT NOCOPY csi_datastructures_pub.instance_asset_tbl
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_instance_id_lst       OUT NOCOPY    csi_datastructures_pub.id_tbl
    ,p_grp_upd_error_tbl     OUT NOCOPY    csi_datastructures_pub.grp_upd_error_tbl
    ,x_return_status         OUT NOCOPY    VARCHAR2
    ,x_msg_count             OUT NOCOPY    NUMBER
    ,x_msg_data              OUT NOCOPY    VARCHAR2
 );

/*----------------------------------------------------*/
/* Procedure name: expire_item_instance               */
/* Description :   procedure for                      */
/*                 Expiring an Item Instance          */
/*----------------------------------------------------*/

PROCEDURE expire_item_instance
 (
      p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_tbl        IN      csi_datastructures_pub.instance_tbl
     ,p_expire_children     IN      VARCHAR2 := fnd_api.g_false
     ,p_txn_rec             IN OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,x_instance_id_lst     OUT NOCOPY     csi_datastructures_pub.id_tbl
     ,p_grp_error_tbl       OUT NOCOPY     csi_datastructures_pub.grp_error_tbl
     ,x_return_status       OUT NOCOPY     VARCHAR2
     ,x_msg_count           OUT NOCOPY     NUMBER
     ,x_msg_data            OUT NOCOPY     VARCHAR2
 );
 --
 PROCEDURE Get_All_Parents
   (
     p_api_version      IN  NUMBER,
     p_commit           IN  VARCHAR2,
     p_init_msg_list    IN  VARCHAR2,
     p_validation_level IN  NUMBER,
     p_subject_id       IN  NUMBER,
     x_rel_tbl          OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count        OUT NOCOPY NUMBER,
     x_msg_data         OUT NOCOPY VARCHAR2
   );

/*---------------------------------------------------------*/
/* Procedure name:  Explode_Bom                            */
/* Description :    This procudure explodes the BOM and    */
/*                  creates instances and relationships    */
/* Author      :    Srinivasan Ramakrishnan                */
/*---------------------------------------------------------*/
PROCEDURE Explode_Bom
 (
   p_api_version            IN     NUMBER
  ,p_commit                 IN     VARCHAR2
  ,p_init_msg_list          IN     VARCHAR2
  ,p_validation_level       IN     NUMBER
  ,p_source_instance_tbl    IN     csi_datastructures_pub.instance_tbl
  ,p_explosion_level        IN     NUMBER
  ,p_txn_rec                IN OUT NOCOPY csi_datastructures_pub.transaction_rec
  ,x_return_status          OUT    NOCOPY VARCHAR2
  ,x_msg_count              OUT    NOCOPY NUMBER
  ,x_msg_data               OUT    NOCOPY VARCHAR2
 );

END CSI_ITEM_INSTANCE_GRP;

/
