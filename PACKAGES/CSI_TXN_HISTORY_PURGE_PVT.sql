--------------------------------------------------------
--  DDL for Package CSI_TXN_HISTORY_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_TXN_HISTORY_PURGE_PVT" AUTHID CURRENT_USER AS
/* $Header: csivthps.pls 120.3 2005/06/17 17:37:54 appldev  $ */
--
G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSI_TXN_HISTORY_PURGE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csivthps.pls';
--
TYPE T_DATE  is TABLE OF DATE          INDEX BY BINARY_INTEGER;
TYPE T_NUM   is TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE T_V1    is TABLE OF VARCHAR(01)   INDEX BY BINARY_INTEGER;
TYPE T_V3    is TABLE OF VARCHAR(03)   INDEX BY BINARY_INTEGER;
TYPE T_V6    is TABLE OF VARCHAR(06)   INDEX BY BINARY_INTEGER;
TYPE T_V10   is TABLE OF VARCHAR(10)   INDEX BY BINARY_INTEGER;
TYPE T_V15   is TABLE OF VARCHAR(15)   INDEX BY BINARY_INTEGER;
TYPE T_V20   is TABLE OF VARCHAR(20)   INDEX BY BINARY_INTEGER;
TYPE T_V25   is TABLE OF VARCHAR(25)   INDEX BY BINARY_INTEGER;
TYPE T_V30   is TABLE OF VARCHAR(30)   INDEX BY BINARY_INTEGER;
TYPE T_V35   is TABLE OF VARCHAR(35)   INDEX BY BINARY_INTEGER;
TYPE T_V40   is TABLE OF VARCHAR(40)   INDEX BY BINARY_INTEGER;
TYPE T_V50   is TABLE OF VARCHAR(50)   INDEX BY BINARY_INTEGER;
TYPE T_V60   is TABLE OF VARCHAR(60)   INDEX BY BINARY_INTEGER;
TYPE T_V80   is TABLE OF VARCHAR(80)   INDEX BY BINARY_INTEGER;
TYPE T_V85   is TABLE OF VARCHAR(85)   INDEX BY BINARY_INTEGER;
TYPE T_V150  is TABLE OF VARCHAR(150)  INDEX BY BINARY_INTEGER;
TYPE T_V240  is TABLE OF VARCHAR(240)  INDEX BY BINARY_INTEGER;
TYPE T_V360  is TABLE OF VARCHAR(360)  INDEX BY BINARY_INTEGER;
TYPE T_V1000 is TABLE OF VARCHAR(1000) INDEX BY BINARY_INTEGER;
TYPE T_V2000 is TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;
--
--
TYPE INSTANCE_HISTORY_REC_TAB IS RECORD
  (
       INSTANCE_ID                         T_NUM
      ,OLD_INSTANCE_NUMBER                 T_V30
      ,NEW_INSTANCE_NUMBER                 T_V30
      ,OLD_EXTERNAL_REFERENCE              T_V30
      ,NEW_EXTERNAL_REFERENCE              T_V30
      ,OLD_INVENTORY_ITEM_ID               T_NUM
      ,NEW_INVENTORY_ITEM_ID               T_NUM
      ,OLD_INVENTORY_REVISION              T_V3
      ,NEW_INVENTORY_REVISION              T_V3
      ,OLD_INV_MASTER_ORG_ID               T_NUM
      ,NEW_INV_MASTER_ORG_ID               T_NUM
      ,OLD_SERIAL_NUMBER                   T_V30
      ,NEW_SERIAL_NUMBER                   T_V30
      ,OLD_MFG_SERIAL_NUMBER_FLAG          T_V1
      ,NEW_MFG_SERIAL_NUMBER_FLAG          T_V1
      ,OLD_LOT_NUMBER                      T_V80
      ,NEW_LOT_NUMBER                      T_V80
      ,OLD_QUANTITY                        T_NUM
      ,NEW_QUANTITY                        T_NUM
      ,OLD_UNIT_OF_MEASURE_NAME            T_V30
      ,NEW_UNIT_OF_MEASURE_NAME            T_V30
      ,OLD_UNIT_OF_MEASURE                 T_V3
      ,NEW_UNIT_OF_MEASURE                 T_V3
      ,OLD_ACCOUNTING_CLASS                T_V30
      ,NEW_ACCOUNTING_CLASS                T_V30
      ,OLD_ACCOUNTING_CLASS_CODE           T_V10
      ,NEW_ACCOUNTING_CLASS_CODE           T_V10
      ,OLD_INSTANCE_CONDITION              T_V80
      ,NEW_INSTANCE_CONDITION              T_V80
      ,OLD_INSTANCE_CONDITION_ID           T_NUM
      ,NEW_INSTANCE_CONDITION_ID           T_NUM
      ,OLD_INSTANCE_STATUS                 T_V50
      ,NEW_INSTANCE_STATUS                 T_V50
      ,OLD_INSTANCE_STATUS_ID              T_NUM
      ,NEW_INSTANCE_STATUS_ID              T_NUM
      ,OLD_CUSTOMER_VIEW_FLAG              T_V1
      ,NEW_CUSTOMER_VIEW_FLAG              T_V1
      ,OLD_MERCHANT_VIEW_FLAG              T_V1
      ,NEW_MERCHANT_VIEW_FLAG              T_V1
      ,OLD_SELLABLE_FLAG                   T_V1
      ,NEW_SELLABLE_FLAG                   T_V1
      ,OLD_SYSTEM_ID                       T_NUM
      ,NEW_SYSTEM_ID                       T_NUM
      ,OLD_SYSTEM_NAME                     T_V30
      ,NEW_SYSTEM_NAME                     T_V30
      ,OLD_INSTANCE_TYPE_CODE              T_V30
      ,NEW_INSTANCE_TYPE_CODE              T_V30
      ,OLD_INSTANCE_TYPE_NAME              T_V240
      ,NEW_INSTANCE_TYPE_NAME              T_V240
      ,OLD_ACTIVE_START_DATE               T_DATE
      ,NEW_ACTIVE_START_DATE               T_DATE
      ,OLD_ACTIVE_END_DATE                 T_DATE
      ,NEW_ACTIVE_END_DATE                 T_DATE
      ,OLD_LOCATION_TYPE_CODE              T_V30
      ,NEW_LOCATION_TYPE_CODE              T_V30
      ,OLD_LOCATION_ID                     T_NUM
      ,NEW_LOCATION_ID                     T_NUM
      ,OLD_INV_ORGANIZATION_ID             T_NUM
      ,NEW_INV_ORGANIZATION_ID             T_NUM
      ,OLD_INV_ORGANIZATION_NAME           T_V60
      ,NEW_INV_ORGANIZATION_NAME           T_V60
      ,OLD_INV_SUBINVENTORY_NAME           T_V10
      ,NEW_INV_SUBINVENTORY_NAME           T_V10
      ,OLD_INV_LOCATOR_ID                  T_NUM
      ,NEW_INV_LOCATOR_ID                  T_NUM
      ,OLD_PA_PROJECT_ID                   T_NUM
      ,NEW_PA_PROJECT_ID                   T_NUM
      ,OLD_PA_PROJECT_TASK_ID              T_NUM
      ,NEW_PA_PROJECT_TASK_ID              T_NUM
      ,OLD_PA_PROJECT_NAME                 T_V30
      ,NEW_PA_PROJECT_NAME                 T_V30
      ,OLD_PA_PROJECT_NUMBER               T_V25
      ,NEW_PA_PROJECT_NUMBER               T_V25
      ,OLD_PA_TASK_NAME                    T_V20
      ,NEW_PA_TASK_NAME                    T_V20
      ,OLD_PA_TASK_NUMBER                  T_V25
      ,NEW_PA_TASK_NUMBER                  T_V25
      ,OLD_IN_TRANSIT_ORDER_LINE_ID        T_NUM
      ,NEW_IN_TRANSIT_ORDER_LINE_ID        T_NUM
      ,OLD_IN_TRANSIT_ORDER_LINE_NUM       T_NUM
      ,NEW_IN_TRANSIT_ORDER_LINE_NUM       T_NUM
      ,OLD_IN_TRANSIT_ORDER_NUMBER         T_NUM
      ,NEW_IN_TRANSIT_ORDER_NUMBER         T_NUM
      ,OLD_WIP_JOB_ID                      T_NUM
      ,NEW_WIP_JOB_ID                      T_NUM
      ,OLD_WIP_ENTITY_NAME                 T_V240
      ,NEW_WIP_ENTITY_NAME                 T_V240
      ,OLD_PO_ORDER_LINE_ID                T_NUM
      ,NEW_PO_ORDER_LINE_ID                T_NUM
      ,OLD_LAST_OE_ORDER_LINE_ID           T_NUM
      ,NEW_LAST_OE_ORDER_LINE_ID           T_NUM
      ,OLD_LAST_OE_RMA_LINE_ID             T_NUM
      ,NEW_LAST_OE_RMA_LINE_ID             T_NUM
      ,OLD_LAST_PO_PO_LINE_ID              T_NUM
      ,NEW_LAST_PO_PO_LINE_ID              T_NUM
      ,OLD_LAST_OE_PO_NUMBER               T_V50
      ,NEW_LAST_OE_PO_NUMBER               T_V50
      ,OLD_LAST_WIP_JOB_ID                 T_NUM
      ,NEW_LAST_WIP_JOB_ID                 T_NUM
      ,OLD_LAST_PA_PROJECT_ID              T_NUM
      ,NEW_LAST_PA_PROJECT_ID              T_NUM
      ,OLD_LAST_PA_TASK_ID                 T_NUM
      ,NEW_LAST_PA_TASK_ID                 T_NUM
      ,OLD_LAST_OE_AGREEMENT_ID            T_NUM
      ,NEW_LAST_OE_AGREEMENT_ID            T_NUM
      ,OLD_INSTALL_DATE                    T_DATE
      ,NEW_INSTALL_DATE                    T_DATE
      ,OLD_MANUALLY_CREATED_FLAG           T_V1
      ,NEW_MANUALLY_CREATED_FLAG           T_V1
      ,OLD_RETURN_BY_DATE                  T_DATE
      ,NEW_RETURN_BY_DATE                  T_DATE
      ,OLD_ACTUAL_RETURN_DATE              T_DATE
      ,NEW_ACTUAL_RETURN_DATE              T_DATE
      ,OLD_CREATION_COMPLETE_FLAG          T_V1
      ,NEW_CREATION_COMPLETE_FLAG          T_V1
      ,OLD_COMPLETENESS_FLAG               T_V1
      ,NEW_COMPLETENESS_FLAG               T_V1
      ,OLD_INST_CONTEXT                    T_V30
      ,NEW_INST_CONTEXT                    T_V30
      ,OLD_INST_ATTRIBUTE1                 T_V240
      ,NEW_INST_ATTRIBUTE1                 T_V240
      ,OLD_INST_ATTRIBUTE2                 T_V240
      ,NEW_INST_ATTRIBUTE2                 T_V240
      ,OLD_INST_ATTRIBUTE3                 T_V240
      ,NEW_INST_ATTRIBUTE3                 T_V240
      ,OLD_INST_ATTRIBUTE4                 T_V240
      ,NEW_INST_ATTRIBUTE4                 T_V240
      ,OLD_INST_ATTRIBUTE5                 T_V240
      ,NEW_INST_ATTRIBUTE5                 T_V240
      ,OLD_INST_ATTRIBUTE6                 T_V240
      ,NEW_INST_ATTRIBUTE6                 T_V240
      ,OLD_INST_ATTRIBUTE7                 T_V240
      ,NEW_INST_ATTRIBUTE7                 T_V240
      ,OLD_INST_ATTRIBUTE8                 T_V240
      ,NEW_INST_ATTRIBUTE8                 T_V240
      ,OLD_INST_ATTRIBUTE9                 T_V240
      ,NEW_INST_ATTRIBUTE9                 T_V240
      ,OLD_INST_ATTRIBUTE10                T_V240
      ,NEW_INST_ATTRIBUTE10                T_V240
      ,OLD_INST_ATTRIBUTE11                T_V240
      ,NEW_INST_ATTRIBUTE11                T_V240
      ,OLD_INST_ATTRIBUTE12                T_V240
      ,NEW_INST_ATTRIBUTE12                T_V240
      ,OLD_INST_ATTRIBUTE13                T_V240
      ,NEW_INST_ATTRIBUTE13                T_V240
      ,OLD_INST_ATTRIBUTE14                T_V240
      ,NEW_INST_ATTRIBUTE14                T_V240
      ,OLD_INST_ATTRIBUTE15                T_V240
      ,NEW_INST_ATTRIBUTE15                T_V240
      ,OLD_LAST_TXN_LINE_DETAIL_ID         T_NUM
      ,NEW_LAST_TXN_LINE_DETAIL_ID         T_NUM
      ,OLD_INSTALL_LOCATION_TYPE_CODE      T_V30
      ,NEW_INSTALL_LOCATION_TYPE_CODE      T_V30
      ,OLD_INSTALL_LOCATION_ID             T_NUM
      ,NEW_INSTALL_LOCATION_ID             T_NUM
      ,OLD_INSTANCE_USAGE_CODE             T_V30
      ,NEW_INSTANCE_USAGE_CODE             T_V30
      ,OLD_CONFIG_INST_REV_NUM             T_NUM
      ,NEW_CONFIG_INST_REV_NUM             T_NUM
      ,OLD_CONFIG_VALID_STATUS             T_V30
      ,NEW_CONFIG_VALID_STATUS             T_V30
      ,OLD_INSTANCE_DESCRIPTION            T_V240
      ,NEW_INSTANCE_DESCRIPTION            T_V240
      ,INSTANCE_HISTORY_ID                 T_NUM
      ,TRANSACTION_ID                      T_NUM
      ,OLD_LAST_VLD_ORGANIZATION_ID        T_NUM
      ,NEW_LAST_VLD_ORGANIZATION_ID        T_NUM
      ,INST_FULL_DUMP_FLAG                 T_V1
      ,INST_CREATED_BY                     T_NUM
      ,INST_CREATION_DATE                  T_DATE
      ,INST_LAST_UPDATED_BY                T_NUM
      ,INST_LAST_UPDATE_DATE               T_DATE
      ,INST_LAST_UPDATE_LOGIN              T_NUM
      ,INST_OBJECT_VERSION_NUMBER          T_NUM
      ,INST_SECURITY_GROUP_ID              T_NUM
      ,INST_MIGRATED_FLAG                  T_V1
      -- Added for the following as new columns were added to csi_item_instances
      -- and csi_item_instances_h tables
      ,OLD_NETWORK_ASSET_FLAG              T_V1
      ,NEW_NETWORK_ASSET_FLAG              T_V1
      ,OLD_MAINTAINABLE_FLAG               T_V1
      ,NEW_MAINTAINABLE_FLAG               T_V1
      ,OLD_PN_LOCATION_ID                  T_NUM
      ,NEW_PN_LOCATION_ID                  T_NUM
      ,OLD_ASSET_CRITICALITY_CODE          T_V30
      ,NEW_ASSET_CRITICALITY_CODE          T_V30
      ,OLD_CATEGORY_ID                     T_NUM
      ,NEW_CATEGORY_ID                     T_NUM
      ,OLD_EQUIPMENT_GEN_OBJECT_ID         T_NUM
      ,NEW_EQUIPMENT_GEN_OBJECT_ID         T_NUM
      ,OLD_INSTANTIATION_FLAG              T_V1
      ,NEW_INSTANTIATION_FLAG              T_V1
      ,OLD_LINEAR_LOCATION_ID              T_NUM
      ,NEW_LINEAR_LOCATION_ID              T_NUM
      ,OLD_OPERATIONAL_LOG_FLAG            T_V1
      ,NEW_OPERATIONAL_LOG_FLAG            T_V1
      ,OLD_CHECKIN_STATUS                  T_NUM
      ,NEW_CHECKIN_STATUS                  T_NUM
      ,OLD_SUPPLIER_WARRANTY_EXP_DATE      T_DATE
      ,NEW_SUPPLIER_WARRANTY_EXP_DATE      T_DATE
      ,OLD_INST_ATTRIBUTE16                T_V240
      ,NEW_INST_ATTRIBUTE16                T_V240
      ,OLD_INST_ATTRIBUTE17                T_V240
      ,NEW_INST_ATTRIBUTE17                T_V240
      ,OLD_INST_ATTRIBUTE18                T_V240
      ,NEW_INST_ATTRIBUTE18                T_V240
      ,OLD_INST_ATTRIBUTE19                T_V240
      ,NEW_INST_ATTRIBUTE19                T_V240
      ,OLD_INST_ATTRIBUTE20                T_V240
      ,NEW_INST_ATTRIBUTE20                T_V240
      ,OLD_INST_ATTRIBUTE21                T_V240
      ,NEW_INST_ATTRIBUTE21                T_V240
      ,OLD_INST_ATTRIBUTE22                T_V240
      ,NEW_INST_ATTRIBUTE22                T_V240
      ,OLD_INST_ATTRIBUTE23                T_V240
      ,NEW_INST_ATTRIBUTE23                T_V240
      ,OLD_INST_ATTRIBUTE24                T_V240
      ,NEW_INST_ATTRIBUTE24                T_V240
      ,OLD_INST_ATTRIBUTE25                T_V240
      ,NEW_INST_ATTRIBUTE25                T_V240
      ,OLD_INST_ATTRIBUTE26                T_V240
      ,NEW_INST_ATTRIBUTE26                T_V240
      ,OLD_INST_ATTRIBUTE27                T_V240
      ,NEW_INST_ATTRIBUTE27                T_V240
      ,OLD_INST_ATTRIBUTE28                T_V240
      ,NEW_INST_ATTRIBUTE28                T_V240
      ,OLD_INST_ATTRIBUTE29                T_V240
      ,NEW_INST_ATTRIBUTE29                T_V240
      ,OLD_INST_ATTRIBUTE30                T_V240
      ,NEW_INST_ATTRIBUTE30                T_V240
   );
--
TYPE VER_LABEL_HISTORY_REC_TAB IS RECORD
   (
      VERSION_LABEL_HISTORY_ID             T_NUM
     ,VERSION_LABEL_ID                     T_NUM
     ,TRANSACTION_ID                       T_NUM
     ,OLD_VERSION_LABEL                    T_V30
     ,NEW_VERSION_LABEL                    T_V30
     ,OLD_VER_DESCRIPTION                  T_V240
     ,NEW_VER_DESCRIPTION                  T_V240
     ,OLD_DATE_TIME_STAMP                  T_DATE
     ,NEW_DATE_TIME_STAMP                  T_DATE
     ,OLD_VER_ACTIVE_START_DATE            T_DATE
     ,NEW_VER_ACTIVE_START_DATE            T_DATE
     ,OLD_VER_ACTIVE_END_DATE              T_DATE
     ,NEW_VER_ACTIVE_END_DATE              T_DATE
     ,OLD_VER_CONTEXT                      T_V30
     ,NEW_VER_CONTEXT                      T_V30
     ,OLD_VER_ATTRIBUTE1                   T_V150
     ,NEW_VER_ATTRIBUTE1                   T_V150
     ,OLD_VER_ATTRIBUTE2                   T_V150
     ,NEW_VER_ATTRIBUTE2                   T_V150
     ,OLD_VER_ATTRIBUTE3                   T_V150
     ,NEW_VER_ATTRIBUTE3                   T_V150
     ,OLD_VER_ATTRIBUTE4                   T_V150
     ,NEW_VER_ATTRIBUTE4                   T_V150
     ,OLD_VER_ATTRIBUTE5                   T_V150
     ,NEW_VER_ATTRIBUTE5                   T_V150
     ,OLD_VER_ATTRIBUTE6                   T_V150
     ,NEW_VER_ATTRIBUTE6                   T_V150
     ,OLD_VER_ATTRIBUTE7                   T_V150
     ,NEW_VER_ATTRIBUTE7                   T_V150
     ,OLD_VER_ATTRIBUTE8                   T_V150
     ,NEW_VER_ATTRIBUTE8                   T_V150
     ,OLD_VER_ATTRIBUTE9                   T_V150
     ,NEW_VER_ATTRIBUTE9                   T_V150
     ,OLD_VER_ATTRIBUTE10                  T_V150
     ,NEW_VER_ATTRIBUTE10                  T_V150
     ,OLD_VER_ATTRIBUTE11                  T_V150
     ,NEW_VER_ATTRIBUTE11                  T_V150
     ,OLD_VER_ATTRIBUTE12                  T_V150
     ,NEW_VER_ATTRIBUTE12                  T_V150
     ,OLD_VER_ATTRIBUTE13                  T_V150
     ,NEW_VER_ATTRIBUTE13                  T_V150
     ,OLD_VER_ATTRIBUTE14                  T_V150
     ,NEW_VER_ATTRIBUTE14                  T_V150
     ,OLD_VER_ATTRIBUTE15                  T_V150
     ,NEW_VER_ATTRIBUTE15                  T_V150
     ,VER_FULL_DUMP_FLAG                   T_V1
     ,VER_CREATED_BY                       T_NUM
     ,VER_CREATION_DATE                    T_DATE
     ,VER_LAST_UPDATED_BY                  T_NUM
     ,VER_LAST_UPDATE_DATE                 T_DATE
     ,VER_LAST_UPDATE_LOGIN                T_NUM
     ,VER_OBJECT_VERSION_NUMBER            T_NUM
     ,VER_SECURITY_GROUP_ID                T_NUM
     ,VER_MIGRATED_FLAG                    T_V1

   );
--

TYPE PARTY_HISTORY_REC_TAB IS RECORD
   (
      INSTANCE_PARTY_HISTORY_ID            T_NUM
     ,INSTANCE_PARTY_ID                    T_NUM
     ,TRANSACTION_ID                       T_NUM
     ,OLD_PARTY_SOURCE_TABLE               T_V30
     ,NEW_PARTY_SOURCE_TABLE               T_V30
     ,OLD_PARTY_ID                         T_NUM
     ,NEW_PARTY_ID                         T_NUM
     ,OLD_RELATIONSHIP_TYPE_CODE           T_V30
     ,NEW_RELATIONSHIP_TYPE_CODE           T_V30
     ,OLD_CONTACT_FLAG                     T_V1
     ,NEW_CONTACT_FLAG                     T_V1
     ,OLD_CONTACT_IP_ID                    T_NUM
     ,NEW_CONTACT_IP_ID                    T_NUM
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
     ,OLD_PREFERRED_FLAG                   T_V1
     ,NEW_PREFERRED_FLAG                   T_V1
     ,OLD_PRIMARY_FLAG                     T_V1
     ,NEW_PRIMARY_FLAG                     T_V1
     ,PTY_FULL_DUMP_FLAG                   T_V1
     ,PTY_CREATED_BY                       T_NUM
     ,PTY_CREATION_DATE                    T_DATE
     ,PTY_LAST_UPDATED_BY                  T_NUM
     ,PTY_LAST_UPDATE_DATE                 T_DATE
     ,PTY_LAST_UPDATE_LOGIN                T_NUM
     ,PTY_OBJECT_VERSION_NUMBER            T_NUM
     ,PTY_SECURITY_GROUP_ID                T_NUM
     ,PTY_MIGRATED_FLAG                    T_V1

   );
--
TYPE ACCOUNT_HISTORY_REC_TAB IS RECORD
   (
      IP_ACCOUNT_HISTORY_ID                T_NUM
     ,IP_ACCOUNT_ID                        T_NUM
     ,TRANSACTION_ID                       T_NUM
     ,OLD_PARTY_ACCOUNT_ID                 T_NUM
     ,NEW_PARTY_ACCOUNT_ID                 T_NUM
     ,OLD_RELATIONSHIP_TYPE_CODE           T_V30
     ,NEW_RELATIONSHIP_TYPE_CODE           T_V30
     ,OLD_BILL_TO_ADDRESS                  T_NUM
     ,NEW_BILL_TO_ADDRESS                  T_NUM
     ,OLD_SHIP_TO_ADDRESS                  T_NUM
     ,NEW_SHIP_TO_ADDRESS                  T_NUM
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
     ,ACCT_FULL_DUMP_FLAG                  T_V1
     ,ACCT_CREATED_BY                      T_NUM
     ,ACCT_CREATION_DATE                   T_DATE
     ,ACCT_LAST_UPDATED_BY                 T_NUM
     ,ACCT_LAST_UPDATE_DATE                T_DATE
     ,ACCT_LAST_UPDATE_LOGIN               T_NUM
     ,ACCT_OBJECT_VERSION_NUMBER           T_NUM
     ,ACCT_SECURITY_GROUP_ID               T_NUM
     ,ACCT_MIGRATED_FLAG                   T_V1
     ,OLD_INSTANCE_PARTY_ID                T_NUM
     ,NEW_INSTANCE_PARTY_ID                T_NUM
    );
--
TYPE ORG_UNITS_HISTORY_REC_TAB IS RECORD
  (
      INSTANCE_OU_HISTORY_ID               T_NUM
     ,INSTANCE_OU_ID                       T_NUM
     ,TRANSACTION_ID                       T_NUM
     ,OLD_OPERATING_UNIT_ID                T_NUM
     ,NEW_OPERATING_UNIT_ID                T_NUM
     ,OLD_OU_RELNSHIP_TYPE_CODE            T_V30
     ,NEW_OU_RELNSHIP_TYPE_CODE            T_V30
     ,OLD_OU_ACTIVE_START_DATE             T_DATE
     ,NEW_OU_ACTIVE_START_DATE             T_DATE
     ,OLD_OU_ACTIVE_END_DATE               T_DATE
     ,NEW_OU_ACTIVE_END_DATE               T_DATE
     ,OLD_OU_CONTEXT                       T_V30
     ,NEW_OU_CONTEXT                       T_V30
     ,OLD_OU_ATTRIBUTE1                    T_V150
     ,NEW_OU_ATTRIBUTE1                    T_V150
     ,OLD_OU_ATTRIBUTE2                    T_V150
     ,NEW_OU_ATTRIBUTE2                    T_V150
     ,OLD_OU_ATTRIBUTE3                    T_V150
     ,NEW_OU_ATTRIBUTE3                    T_V150
     ,OLD_OU_ATTRIBUTE4                    T_V150
     ,NEW_OU_ATTRIBUTE4                    T_V150
     ,OLD_OU_ATTRIBUTE5                    T_V150
     ,NEW_OU_ATTRIBUTE5                    T_V150
     ,OLD_OU_ATTRIBUTE6                    T_V150
     ,NEW_OU_ATTRIBUTE6                    T_V150
     ,OLD_OU_ATTRIBUTE7                    T_V150
     ,NEW_OU_ATTRIBUTE7                    T_V150
     ,OLD_OU_ATTRIBUTE8                    T_V150
     ,NEW_OU_ATTRIBUTE8                    T_V150
     ,OLD_OU_ATTRIBUTE9                    T_V150
     ,NEW_OU_ATTRIBUTE9                    T_V150
     ,OLD_OU_ATTRIBUTE10                   T_V150
     ,NEW_OU_ATTRIBUTE10                   T_V150
     ,OLD_OU_ATTRIBUTE11                   T_V150
     ,NEW_OU_ATTRIBUTE11                   T_V150
     ,OLD_OU_ATTRIBUTE12                   T_V150
     ,NEW_OU_ATTRIBUTE12                   T_V150
     ,OLD_OU_ATTRIBUTE13                   T_V150
     ,NEW_OU_ATTRIBUTE13                   T_V150
     ,OLD_OU_ATTRIBUTE14                   T_V150
     ,NEW_OU_ATTRIBUTE14                   T_V150
     ,OLD_OU_ATTRIBUTE15                   T_V150
     ,NEW_OU_ATTRIBUTE15                   T_V150
     ,OU_FULL_DUMP_FLAG                    T_V1
     ,OU_CREATED_BY                        T_NUM
     ,OU_CREATION_DATE                     T_DATE
     ,OU_LAST_UPDATED_BY                   T_NUM
     ,OU_LAST_UPDATE_DATE                  T_DATE
     ,OU_LAST_UPDATE_LOGIN                 T_NUM
     ,OU_OBJECT_VERSION_NUMBER             T_NUM
     ,OU_SECURITY_GROUP_ID                 T_NUM
     ,OU_MIGRATED_FLAG                     T_V1

  );
--
TYPE EXT_ATTRIB_HISTORY_REC_TAB IS RECORD
  (
      ATTRIBUTE_VALUE_HISTORY_ID           T_NUM
     ,ATTRIBUTE_VALUE_ID                   T_NUM
     ,TRANSACTION_ID                       T_NUM
     ,OLD_ATTRIBUTE_VALUE                  T_V240
     ,NEW_ATTRIBUTE_VALUE                  T_V240
     ,OLD_EXT_ACTIVE_START_DATE            T_DATE
     ,NEW_EXT_ACTIVE_START_DATE            T_DATE
     ,OLD_EXT_ACTIVE_END_DATE              T_DATE
     ,NEW_EXT_ACTIVE_END_DATE              T_DATE
     ,OLD_EXT_CONTEXT                      T_V30
     ,NEW_EXT_CONTEXT                      T_V30
     ,OLD_EXT_ATTRIBUTE1                   T_V150
     ,NEW_EXT_ATTRIBUTE1                   T_V150
     ,OLD_EXT_ATTRIBUTE2                   T_V150
     ,NEW_EXT_ATTRIBUTE2                   T_V150
     ,OLD_EXT_ATTRIBUTE3                   T_V150
     ,NEW_EXT_ATTRIBUTE3                   T_V150
     ,OLD_EXT_ATTRIBUTE4                   T_V150
     ,NEW_EXT_ATTRIBUTE4                   T_V150
     ,OLD_EXT_ATTRIBUTE5                   T_V150
     ,NEW_EXT_ATTRIBUTE5                   T_V150
     ,OLD_EXT_ATTRIBUTE6                   T_V150
     ,NEW_EXT_ATTRIBUTE6                   T_V150
     ,OLD_EXT_ATTRIBUTE7                   T_V150
     ,NEW_EXT_ATTRIBUTE7                   T_V150
     ,OLD_EXT_ATTRIBUTE8                   T_V150
     ,NEW_EXT_ATTRIBUTE8                   T_V150
     ,OLD_EXT_ATTRIBUTE9                   T_V150
     ,NEW_EXT_ATTRIBUTE9                   T_V150
     ,OLD_EXT_ATTRIBUTE10                  T_V150
     ,NEW_EXT_ATTRIBUTE10                  T_V150
     ,OLD_EXT_ATTRIBUTE11                  T_V150
     ,NEW_EXT_ATTRIBUTE11                  T_V150
     ,OLD_EXT_ATTRIBUTE12                  T_V150
     ,NEW_EXT_ATTRIBUTE12                  T_V150
     ,OLD_EXT_ATTRIBUTE13                  T_V150
     ,NEW_EXT_ATTRIBUTE13                  T_V150
     ,OLD_EXT_ATTRIBUTE14                  T_V150
     ,NEW_EXT_ATTRIBUTE14                  T_V150
     ,OLD_EXT_ATTRIBUTE15                  T_V150
     ,NEW_EXT_ATTRIBUTE15                  T_V150
     ,EXT_FULL_DUMP_FLAG                   T_V1
     ,EXT_CREATED_BY                       T_NUM
     ,EXT_CREATION_DATE                    T_DATE
     ,EXT_LAST_UPDATED_BY                  T_NUM
     ,EXT_LAST_UPDATE_DATE                 T_DATE
     ,EXT_LAST_UPDATE_LOGIN                T_NUM
     ,EXT_OBJECT_VERSION_NUMBER            T_NUM
     ,EXT_SECURITY_GROUP_ID                T_NUM
     ,EXT_MIGRATED_FLAG                    T_V1
  );
--
TYPE INS_ASSET_HISTORY_REC_TAB IS RECORD
 (
      INSTANCE_ASSET_HISTORY_ID            T_NUM
     ,TRANSACTION_ID                       T_NUM
     ,INSTANCE_ASSET_ID                    T_NUM
     ,OLD_INSTANCE_ID                      T_NUM
     ,NEW_INSTANCE_ID                      T_NUM
     ,OLD_FA_ASSET_ID                      T_NUM
     ,NEW_FA_ASSET_ID                      T_NUM
     ,OLD_FA_BOOK_TYPE_CODE                T_V15
     ,NEW_FA_BOOK_TYPE_CODE                T_V15
     ,OLD_FA_LOCATION_ID                   T_NUM
     ,NEW_FA_LOCATION_ID                   T_NUM
     ,OLD_ASSET_QUANTITY                   T_NUM
     ,NEW_ASSET_QUANTITY                   T_NUM
     ,OLD_UPDATE_STATUS                    T_V30
     ,NEW_UPDATE_STATUS                    T_V30
     ,OLD_AST_ACTIVE_START_DATE            T_DATE
     ,NEW_AST_ACTIVE_START_DATE            T_DATE
     ,OLD_AST_ACTIVE_END_DATE              T_DATE
     ,NEW_AST_ACTIVE_END_DATE              T_DATE
     ,AST_FULL_DUMP_FLAG                   T_V1
     ,AST_CREATED_BY                       T_NUM
     ,AST_CREATION_DATE                    T_DATE
     ,AST_LAST_UPDATED_BY                  T_NUM
     ,AST_LAST_UPDATE_DATE                 T_DATE
     ,AST_LAST_UPDATE_LOGIN                T_NUM
     ,AST_OBJECT_VERSION_NUMBER            T_NUM
     ,AST_SECURITY_GROUP_ID                T_NUM
     ,AST_MIGRATED_FLAG                    T_V1
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
     ,OLD_PRICING_ATTRIBUTE25              T_V150
     ,NEW_PRICING_ATTRIBUTE25              T_V150
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
     ,OLD_PRI_ACTIVE_START_DATE            T_DATE
     ,NEW_PRI_ACTIVE_START_DATE            T_DATE
     ,OLD_PRI_ACTIVE_END_DATE              T_DATE
     ,NEW_PRI_ACTIVE_END_DATE              T_DATE
     ,OLD_PRI_CONTEXT                      T_V30
     ,NEW_PRI_CONTEXT                      T_V30
     ,OLD_PRI_ATTRIBUTE1                   T_V150
     ,NEW_PRI_ATTRIBUTE1                   T_V150
     ,OLD_PRI_ATTRIBUTE2                   T_V150
     ,NEW_PRI_ATTRIBUTE2                   T_V150
     ,OLD_PRI_ATTRIBUTE3                   T_V150
     ,NEW_PRI_ATTRIBUTE3                   T_V150
     ,OLD_PRI_ATTRIBUTE4                   T_V150
     ,NEW_PRI_ATTRIBUTE4                   T_V150
     ,OLD_PRI_ATTRIBUTE5                   T_V150
     ,NEW_PRI_ATTRIBUTE5                   T_V150
     ,OLD_PRI_ATTRIBUTE6                   T_V150
     ,NEW_PRI_ATTRIBUTE6                   T_V150
     ,OLD_PRI_ATTRIBUTE7                   T_V150
     ,NEW_PRI_ATTRIBUTE7                   T_V150
     ,OLD_PRI_ATTRIBUTE8                   T_V150
     ,NEW_PRI_ATTRIBUTE8                   T_V150
     ,OLD_PRI_ATTRIBUTE9                   T_V150
     ,NEW_PRI_ATTRIBUTE9                   T_V150
     ,OLD_PRI_ATTRIBUTE10                  T_V150
     ,NEW_PRI_ATTRIBUTE10                  T_V150
     ,OLD_PRI_ATTRIBUTE11                  T_V150
     ,NEW_PRI_ATTRIBUTE11                  T_V150
     ,OLD_PRI_ATTRIBUTE12                  T_V150
     ,NEW_PRI_ATTRIBUTE12                  T_V150
     ,OLD_PRI_ATTRIBUTE13                  T_V150
     ,NEW_PRI_ATTRIBUTE13                  T_V150
     ,OLD_PRI_ATTRIBUTE14                  T_V150
     ,NEW_PRI_ATTRIBUTE14                  T_V150
     ,OLD_PRI_ATTRIBUTE15                  T_V150
     ,NEW_PRI_ATTRIBUTE15                  T_V150
     ,PRI_FULL_DUMP_FLAG                   T_V1
     ,PRI_CREATED_BY                       T_NUM
     ,PRI_CREATION_DATE                    T_DATE
     ,PRI_LAST_UPDATED_BY                  T_NUM
     ,PRI_LAST_UPDATE_DATE                 T_DATE
     ,PRI_LAST_UPDATE_LOGIN                T_NUM
     ,PRI_OBJECT_VERSION_NUMBER            T_NUM
     ,PRI_SECURITY_GROUP_ID                T_NUM
     ,PRI_MIGRATED_FLAG                    T_V1
   );
--

TYPE RELATIONSHIP_HISTORY_REC_TAB IS RECORD
(
      RELATIONSHIP_HISTORY_ID              T_NUM
     ,RELATIONSHIP_ID                      T_NUM
     ,TRANSACTION_ID                       T_NUM
     ,OLD_SUBJECT_ID                       T_NUM
     ,NEW_SUBJECT_ID                       T_NUM
     ,OLD_POSITION_REFERENCE               T_V30
     ,NEW_POSITION_REFERENCE               T_V30
     ,OLD_REL_ACTIVE_START_DATE            T_DATE
     ,NEW_REL_ACTIVE_START_DATE            T_DATE
     ,OLD_REL_ACTIVE_END_DATE              T_DATE
     ,NEW_REL_ACTIVE_END_DATE              T_DATE
     ,OLD_MANDATORY_FLAG                   T_V1
     ,NEW_MANDATORY_FLAG                   T_V1
     ,OLD_REL_CONTEXT                      T_V30
     ,NEW_REL_CONTEXT                      T_V30
     ,OLD_REL_ATTRIBUTE1                   T_V150
     ,NEW_REL_ATTRIBUTE1                   T_V150
     ,OLD_REL_ATTRIBUTE2                   T_V150
     ,NEW_REL_ATTRIBUTE2                   T_V150
     ,OLD_REL_ATTRIBUTE3                   T_V150
     ,NEW_REL_ATTRIBUTE3                   T_V150
     ,OLD_REL_ATTRIBUTE4                   T_V150
     ,NEW_REL_ATTRIBUTE4                   T_V150
     ,OLD_REL_ATTRIBUTE5                   T_V150
     ,NEW_REL_ATTRIBUTE5                   T_V150
     ,OLD_REL_ATTRIBUTE6                   T_V150
     ,NEW_REL_ATTRIBUTE6                   T_V150
     ,OLD_REL_ATTRIBUTE7                   T_V150
     ,NEW_REL_ATTRIBUTE7                   T_V150
     ,OLD_REL_ATTRIBUTE8                   T_V150
     ,NEW_REL_ATTRIBUTE8                   T_V150
     ,OLD_REL_ATTRIBUTE9                   T_V150
     ,NEW_REL_ATTRIBUTE9                   T_V150
     ,OLD_REL_ATTRIBUTE10                  T_V150
     ,NEW_REL_ATTRIBUTE10                  T_V150
     ,OLD_REL_ATTRIBUTE11                  T_V150
     ,NEW_REL_ATTRIBUTE11                  T_V150
     ,OLD_REL_ATTRIBUTE12                  T_V150
     ,NEW_REL_ATTRIBUTE12                  T_V150
     ,OLD_REL_ATTRIBUTE13                  T_V150
     ,NEW_REL_ATTRIBUTE13                  T_V150
     ,OLD_REL_ATTRIBUTE14                  T_V150
     ,NEW_REL_ATTRIBUTE14                  T_V150
     ,OLD_REL_ATTRIBUTE15                  T_V150
     ,NEW_REL_ATTRIBUTE15                  T_V150
     ,REL_FULL_DUMP_FLAG                   T_V1
     ,REL_CREATED_BY                       T_NUM
     ,REL_CREATION_DATE                    T_DATE
     ,REL_LAST_UPDATED_BY                  T_NUM
     ,REL_LAST_UPDATE_DATE                 T_DATE
     ,REL_LAST_UPDATE_LOGIN                T_NUM
     ,REL_OBJECT_VERSION_NUMBER            T_NUM
     ,REL_SECURITY_GROUP_ID                T_NUM
     ,REL_MIGRATED_FLAG                    T_V1
   );
--
TYPE SYSTEM_HISTORY_REC_TAB IS RECORD
(
      TRANSACTION_ID                       T_NUM
     ,SYSTEM_HISTORY_ID                    T_NUM
     ,SYSTEM_ID                            T_NUM
     ,OLD_CUSTOMER_ID                      T_NUM
     ,NEW_CUSTOMER_ID                      T_NUM
     ,OLD_SYSTEM_TYPE_CODE                 T_V30
     ,NEW_SYSTEM_TYPE_CODE                 T_V30
     ,OLD_SYSTEM_NUMBER                    T_V30
     ,NEW_SYSTEM_NUMBER                    T_V30
     ,OLD_PARENT_SYSTEM_ID                 T_NUM
     ,NEW_PARENT_SYSTEM_ID                 T_NUM
     ,OLD_BILL_TO_CONTACT_ID               T_NUM
     ,NEW_BILL_TO_CONTACT_ID               T_NUM
     ,OLD_SHIP_TO_CONTACT_ID               T_NUM
     ,NEW_SHIP_TO_CONTACT_ID               T_NUM
     ,OLD_TECHNICAL_CONTACT_ID             T_NUM
     ,NEW_TECHNICAL_CONTACT_ID             T_NUM
     ,OLD_SERVICE_ADMIN_CONTACT_ID         T_NUM
     ,NEW_SERVICE_ADMIN_CONTACT_ID         T_NUM
     ,OLD_SHIP_TO_SITE_USE_ID              T_NUM
     ,NEW_SHIP_TO_SITE_USE_ID              T_NUM
     ,OLD_INSTALL_SITE_USE_ID              T_NUM
     ,NEW_INSTALL_SITE_USE_ID              T_NUM
     ,OLD_BILL_TO_SITE_USE_ID              T_NUM
     ,NEW_BILL_TO_SITE_USE_ID              T_NUM
     ,OLD_COTERMINATE_DAY_MONTH            T_V6
     ,NEW_COTERMINATE_DAY_MONTH            T_V6
     ,OLD_SYS_ACTIVE_START_DATE            T_DATE
     ,NEW_SYS_ACTIVE_START_DATE            T_DATE
     ,OLD_SYS_ACTIVE_END_DATE              T_DATE
     ,NEW_SYS_ACTIVE_END_DATE              T_DATE
     ,OLD_AUTOCREATED_FROM_SYSTEM          T_NUM
     ,NEW_AUTOCREATED_FROM_SYSTEM          T_NUM
     ,OLD_CONFIG_SYSTEM_TYPE               T_V30
     ,NEW_CONFIG_SYSTEM_TYPE               T_V30
     ,OLD_NAME                             T_V50
     ,NEW_NAME                             T_V50
     ,OLD_SYS_DESCRIPTION                  T_V240
     ,NEW_SYS_DESCRIPTION                  T_V240
     ,OLD_SYS_CONTEXT                      T_V30
     ,NEW_SYS_CONTEXT                      T_V30
     ,OLD_SYS_ATTRIBUTE1                   T_V240
     ,NEW_SYS_ATTRIBUTE1                   T_V240
     ,OLD_SYS_ATTRIBUTE2                   T_V240
     ,NEW_SYS_ATTRIBUTE2                   T_V240
     ,OLD_SYS_ATTRIBUTE3                   T_V240
     ,NEW_SYS_ATTRIBUTE3                   T_V240
     ,OLD_SYS_ATTRIBUTE4                   T_V240
     ,NEW_SYS_ATTRIBUTE4                   T_V240
     ,OLD_SYS_ATTRIBUTE5                   T_V240
     ,NEW_SYS_ATTRIBUTE5                   T_V240
     ,OLD_SYS_ATTRIBUTE6                   T_V240
     ,NEW_SYS_ATTRIBUTE6                   T_V240
     ,OLD_SYS_ATTRIBUTE7                   T_V240
     ,NEW_SYS_ATTRIBUTE7                   T_V240
     ,OLD_SYS_ATTRIBUTE8                   T_V240
     ,NEW_SYS_ATTRIBUTE8                   T_V240
     ,OLD_SYS_ATTRIBUTE9                   T_V240
     ,NEW_SYS_ATTRIBUTE9                   T_V240
     ,OLD_SYS_ATTRIBUTE10                  T_V240
     ,NEW_SYS_ATTRIBUTE10                  T_V240
     ,OLD_SYS_ATTRIBUTE11                  T_V240
     ,NEW_SYS_ATTRIBUTE11                  T_V240
     ,OLD_SYS_ATTRIBUTE12                  T_V240
     ,NEW_SYS_ATTRIBUTE12                  T_V240
     ,OLD_SYS_ATTRIBUTE13                  T_V240
     ,NEW_SYS_ATTRIBUTE13                  T_V240
     ,OLD_SYS_ATTRIBUTE14                  T_V240
     ,NEW_SYS_ATTRIBUTE14                  T_V240
     ,OLD_SYS_ATTRIBUTE15                  T_V240
     ,NEW_SYS_ATTRIBUTE15                  T_V240
     ,SYS_FULL_DUMP_FLAG                   T_V1
     ,SYS_CREATED_BY                       T_NUM
     ,SYS_CREATION_DATE                    T_DATE
     ,SYS_LAST_UPDATED_BY                  T_NUM
     ,SYS_LAST_UPDATE_DATE                 T_DATE
     ,SYS_LAST_UPDATE_LOGIN                T_NUM
     ,SYS_OBJECT_VERSION_NUMBER            T_NUM
     ,SYS_SECURITY_GROUP_ID                T_NUM
     ,SYS_MIGRATED_FLAG                    T_V1
     ,OLD_SYS_OPERATING_UNIT_ID            T_NUM
     ,NEW_SYS_OPERATING_UNIT_ID            T_NUM
 );

--
-- This is the main archive program which internally calls each of the entity
-- archive programs concurrently. It accepts a date timestamp as an parameter.
--
PROCEDURE Archive
 (
     errbuf           OUT NOCOPY  VARCHAR2
    ,retcode          OUT NOCOPY  NUMBER
    ,purge_to_date    IN  VARCHAR2 --DATE
 );
--
-- This program archives the Instance history for the
-- transaction range passed
--
PROCEDURE Instance_archive
 (
     errbuf       OUT NOCOPY VARCHAR2
    ,retcode      OUT NOCOPY NUMBER
    ,from_trans   IN  NUMBER
    ,to_trans     IN  NUMBER
    ,purge_to_date IN VARCHAR2
 );
--
-- This program archives the Party history for the
-- transaction range passed
--
PROCEDURE Party_archive
 (
     errbuf       OUT NOCOPY VARCHAR2
    ,retcode      OUT NOCOPY NUMBER
    ,from_trans   IN  NUMBER
    ,to_trans     IN  NUMBER
    ,purge_to_date IN VARCHAR2
 );
--
-- This program archives the Account history for the
-- transaction range passed
--
PROCEDURE Account_archive
 (
     errbuf       OUT NOCOPY VARCHAR2
    ,retcode      OUT NOCOPY NUMBER
    ,from_trans   IN  NUMBER
    ,to_trans     IN  NUMBER
    ,purge_to_date IN VARCHAR2
 );
--
-- This program archives the Operating unit history for the
-- transaction range passed
--
PROCEDURE Org_Units_archive
 (
     errbuf       OUT NOCOPY VARCHAR2
    ,retcode      OUT NOCOPY NUMBER
    ,from_trans   IN  NUMBER
    ,to_trans     IN  NUMBER
    ,purge_to_date IN VARCHAR2
 );
--
-- This program archives the Extended Attribs history for the
-- transaction range passed
--
PROCEDURE Ext_Attribs_archive
 (
     errbuf       OUT NOCOPY VARCHAR2
    ,retcode      OUT NOCOPY NUMBER
    ,from_trans   IN  NUMBER
    ,to_trans     IN  NUMBER
    ,purge_to_date IN VARCHAR2
 );
--
-- This program archives the Pricing Attribs history for the
-- transaction range passed
--
PROCEDURE Pricing_archive
 (
     errbuf       OUT NOCOPY VARCHAR2
    ,retcode      OUT NOCOPY NUMBER
    ,from_trans   IN  NUMBER
    ,to_trans     IN  NUMBER
    ,purge_to_date IN VARCHAR2
 );
--
-- This program archives the Instance Asset history for the
-- transaction range passed
--
PROCEDURE Assets_archive
 (
     errbuf       OUT NOCOPY VARCHAR2
    ,retcode      OUT NOCOPY NUMBER
    ,from_trans   IN  NUMBER
    ,to_trans     IN  NUMBER
    ,purge_to_date IN VARCHAR2
 );
--
-- This program archives the Version Label history for the
-- transaction range passed
--
PROCEDURE Ver_Labels_archive
 (
     errbuf       OUT NOCOPY VARCHAR2
    ,retcode      OUT NOCOPY NUMBER
    ,from_trans   IN  NUMBER
    ,to_trans     IN  NUMBER
    ,purge_to_date IN VARCHAR2
 );
--
-- This program archives the Instance Rel. history for the
-- transaction range passed
--
PROCEDURE Inst_Relnships_archive
 (
     errbuf       OUT NOCOPY VARCHAR2
    ,retcode      OUT NOCOPY NUMBER
    ,from_trans   IN  NUMBER
    ,to_trans     IN  NUMBER
    ,purge_to_date IN VARCHAR2
 );
--
-- This program archives the Systems history for the
-- transaction range passed
--
PROCEDURE Systems_archive
 (
     errbuf       OUT NOCOPY VARCHAR2
    ,retcode      OUT NOCOPY NUMBER
    ,from_trans   IN  NUMBER
    ,to_trans     IN  NUMBER
    ,purge_to_date IN VARCHAR2
 );
--

Procedure Record_count
 (
     From_trans   IN  NUMBER
    ,To_trans     IN  NUMBER
    ,purge_to_date IN VARCHAR2
    ,Recs_count   OUT NOCOPY NUMBER
 );

END CSI_TXN_HISTORY_PURGE_PVT;
--

 

/
