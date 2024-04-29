--------------------------------------------------------
--  DDL for Package CSI_PROCESS_TXN_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_PROCESS_TXN_GRP" AUTHID CURRENT_USER AS
/* $Header: csigptxs.pls 120.3 2006/07/24 11:42:04 aradhakr noship $ */

  -- global variable declarations
  g_pkg_name            CONSTANT VARCHAR2(30) := 'csi_process_txn_grp';
  g_user_id                      NUMBER       := fnd_global.user_id;
  g_login_id                     NUMBER       := fnd_global.login_id;
  g_sysdate                      DATE         := sysdate;

  -- Name         : txn_instance_rec
  -- Description  : record to hold the transacting instance attributes
  --                the table based on thisbelow will hold the source,
  --                non-source and parent instance details based on the
  --                definition of ib_txn_sub_type_id.

  TYPE txn_instance_rec is RECORD (
    IB_TXN_SEGMENT_FLAG             VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,-- S-Source,N-NonSource,P-Parent
    INSTANCE_ID                     NUMBER         :=  FND_API.G_MISS_NUM, -- Pass if caller has one
    NEW_INSTANCE_ID                 NUMBER         :=  FND_API.G_MISS_NUM, -- Will contain ID if IB creates new
    INSTANCE_NUMBER                 VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    EXTERNAL_REFERENCE              VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    INVENTORY_ITEM_ID               NUMBER         :=  FND_API.G_MISS_NUM,
    VLD_ORGANIZATION_ID             NUMBER         :=  FND_API.G_MISS_NUM,
    INVENTORY_REVISION              VARCHAR2(3)    :=  FND_API.G_MISS_CHAR,
    INV_MASTER_ORGANIZATION_ID      NUMBER         :=  FND_API.G_MISS_NUM,
    SERIAL_NUMBER                   VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    MFG_SERIAL_NUMBER_FLAG          VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    LOT_NUMBER                      VARCHAR2(80)   :=  FND_API.G_MISS_CHAR,
    QUANTITY                        NUMBER         :=  FND_API.G_MISS_NUM,
    UNIT_OF_MEASURE                 VARCHAR2(3)    :=  FND_API.G_MISS_CHAR,
    ACCOUNTING_CLASS_CODE           VARCHAR2(10)   :=  FND_API.G_MISS_CHAR,
    INSTANCE_CONDITION_ID           NUMBER         :=  FND_API.G_MISS_NUM,
    INSTANCE_STATUS_ID              NUMBER         :=  FND_API.G_MISS_NUM,
    CUSTOMER_VIEW_FLAG              VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    MERCHANT_VIEW_FLAG              VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    SELLABLE_FLAG                   VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    SYSTEM_ID                       NUMBER         :=  FND_API.G_MISS_NUM,
    INSTANCE_TYPE_CODE              VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    ACTIVE_START_DATE               DATE           :=  FND_API.G_MISS_DATE,
    ACTIVE_END_DATE                 DATE           :=  FND_API.G_MISS_DATE,
    LOCATION_TYPE_CODE              VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    LOCATION_ID                     NUMBER         :=  FND_API.G_MISS_NUM,
    INV_ORGANIZATION_ID             NUMBER         :=  FND_API.G_MISS_NUM,
    INV_SUBINVENTORY_NAME           VARCHAR2(10)   :=  FND_API.G_MISS_CHAR,
    INV_LOCATOR_ID                  NUMBER         :=  FND_API.G_MISS_NUM,
    PA_PROJECT_ID                   NUMBER         :=  FND_API.G_MISS_NUM,
    PA_PROJECT_TASK_ID              NUMBER         :=  FND_API.G_MISS_NUM,
    IN_TRANSIT_ORDER_LINE_ID        NUMBER         :=  FND_API.G_MISS_NUM,
    WIP_JOB_ID                      NUMBER         :=  FND_API.G_MISS_NUM,
    PO_ORDER_LINE_ID                NUMBER         :=  FND_API.G_MISS_NUM,
    LAST_OE_ORDER_LINE_ID           NUMBER         :=  FND_API.G_MISS_NUM,
    LAST_OE_RMA_LINE_ID             NUMBER         :=  FND_API.G_MISS_NUM,
    LAST_PO_PO_LINE_ID              NUMBER         :=  FND_API.G_MISS_NUM,
    LAST_OE_PO_NUMBER               VARCHAR2(50)   :=  FND_API.G_MISS_CHAR,
    LAST_WIP_JOB_ID                 NUMBER         :=  FND_API.G_MISS_NUM,
    LAST_PA_PROJECT_ID              NUMBER         :=  FND_API.G_MISS_NUM,
    LAST_PA_TASK_ID                 NUMBER         :=  FND_API.G_MISS_NUM,
    LAST_OE_AGREEMENT_ID            NUMBER         :=  FND_API.G_MISS_NUM,
    INSTALL_DATE                    DATE           :=  FND_API.G_MISS_DATE,
    MANUALLY_CREATED_FLAG           VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    RETURN_BY_DATE                  DATE           :=  FND_API.G_MISS_DATE,
    ACTUAL_RETURN_DATE              DATE           :=  FND_API.G_MISS_DATE,
    CREATION_COMPLETE_FLAG          VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    COMPLETENESS_FLAG               VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    VERSION_LABEL                   VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
    VERSION_LABEL_DESCRIPTION       VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
    CONTEXT                         VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE1                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE2                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE3                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE4                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE5                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE6                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE7                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE8                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE9                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE10                     VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE11                     VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE12                     VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE13                     VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE14                     VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE15                     VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    OBJECT_VERSION_NUMBER           NUMBER         :=  FND_API.G_MISS_NUM,
    LAST_TXN_LINE_DETAIL_ID         NUMBER         :=  FND_API.G_MISS_NUM,
    INSTALL_LOCATION_TYPE_CODE      VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    INSTALL_LOCATION_ID             NUMBER         :=  FND_API.G_MISS_NUM,
    INSTANCE_USAGE_CODE             VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    MTL_TXN_CREATION_DATE           DATE           :=  FND_API.G_MISS_DATE,  --bug 3804960
    CONFIG_INST_HDR_ID              NUMBER         :=  FND_API.G_MISS_NUM,
    CONFIG_INST_REV_NUM             NUMBER         :=  FND_API.G_MISS_NUM,
    CONFIG_INST_ITEM_ID             NUMBER         :=  FND_API.G_MISS_NUM,
    OPERATIONAL_STATUS_CODE         VARCHAR2(30)   :=  FND_API.G_MISS_CHAR);

  TYPE dest_location_rec IS RECORD (
    parent_tbl_index                NUMBER         := fnd_api.g_miss_num,
    location_type_code              VARCHAR2(30)   := FND_API.G_MISS_CHAR,
    location_id                     NUMBER         := FND_API.G_MISS_NUM,
    install_location_type_code      VARCHAR2(30)   := FND_API.G_MISS_CHAR,
    install_location_id             NUMBER         := FND_API.G_MISS_NUM,
    instance_usage_code             VARCHAR2(30)   := FND_API.G_MISS_CHAR,
    inv_organization_id             NUMBER         := FND_API.G_MISS_NUM,
    inv_subinventory_name           VARCHAR2(10)   := FND_API.G_MISS_CHAR,
    inv_locator_id                  NUMBER         := FND_API.G_MISS_NUM,
    pa_project_id                   NUMBER         := FND_API.G_MISS_NUM,
    pa_project_task_id              NUMBER         := FND_API.G_MISS_NUM,
    in_transit_order_line_id        NUMBER         := fnd_api.g_miss_num,
    wip_job_id                      NUMBER         := fnd_api.g_miss_num,
    last_wip_job_id                 number         := fnd_api.g_miss_num, --bug 5376024
    po_order_line_id                NUMBER         := fnd_api.g_miss_num,
    last_pa_project_id              NUMBER         := fnd_api.g_miss_num,
    last_pa_project_task_id         NUMBER         := fnd_api.g_miss_num,
    external_reference              VARCHAR2(30)   := fnd_api.g_miss_char,
    operational_status_code         VARCHAR2(30)   := fnd_api.g_miss_char);


  TYPE txn_instances_tbl is TABLE OF txn_instance_rec INDEX BY BINARY_INTEGER;

  -- Name           : txn_i_party_rec
  -- Description    : record to hold information about an instance-party relationship.

  TYPE txn_i_party_rec IS RECORD (
     instance_party_id                NUMBER         :=  FND_API.G_MISS_NUM,
     parent_tbl_index                 NUMBER         :=  FND_API.G_MISS_NUM,
     instance_id                      NUMBER         :=  FND_API.G_MISS_NUM,
     party_source_table               VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     party_id                         NUMBER         :=  FND_API.G_MISS_NUM,
     relationship_type_code           VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     contact_flag                     VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     contact_ip_id                    NUMBER         :=  FND_API.G_MISS_NUM,
     active_start_date                DATE           :=  FND_API.G_MISS_DATE,
     active_end_date                  DATE           :=  FND_API.G_MISS_DATE,
     context                          VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     attribute1                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute2                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute3                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute4                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute5                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute6                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute7                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute8                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute9                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute10                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute11                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute12                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute13                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute14                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute15                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     object_version_number            NUMBER         :=  FND_API.G_MISS_NUM
  );

  TYPE txn_i_parties_tbl IS TABLE OF txn_i_party_rec INDEX BY BINARY_INTEGER;

  -- Name           : txn_ip_account_rec
  -- Description    :  record to hold information about a party-account relationship.

  TYPE txn_ip_account_rec IS RECORD (
     ip_account_id                    NUMBER         :=  FND_API.G_MISS_NUM,
     parent_tbl_index                 NUMBER         :=  FND_API.G_MISS_NUM,
     instance_party_id                NUMBER         :=  FND_API.G_MISS_NUM,
     party_account_id                 NUMBER         :=  FND_API.G_MISS_NUM,
     relationship_type_code           VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     bill_to_address                  NUMBER         :=  FND_API.G_MISS_NUM,
     ship_to_address                  NUMBER         :=  FND_API.G_MISS_NUM,
     active_start_date                DATE           :=  FND_API.G_MISS_DATE,
     active_end_date                  DATE           :=  FND_API.G_MISS_DATE,
     context                          VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     attribute1                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute2                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute3                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute4                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute5                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute6                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute7                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute8                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute9                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute10                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute11                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute12                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute13                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute14                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute15                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     object_version_number            NUMBER         :=  FND_API.G_MISS_NUM
  );

  TYPE txn_ip_accounts_tbl IS TABLE OF txn_ip_account_rec INDEX BY BINARY_INTEGER;

  -- Name           : txn_ii_relationship_rec
  -- Description    : record to hold the attributes of an item instance relationship.

  TYPE txn_ii_relationship_rec IS RECORD (
    RELATIONSHIP_ID                 NUMBER           := FND_API.G_MISS_NUM,
    RELATIONSHIP_TYPE_CODE          VARCHAR2(30)     := FND_API.G_MISS_CHAR,
    OBJECT_INDEX                    NUMBER           := FND_API.G_MISS_NUM,
    OBJECT_ID                       NUMBER           := FND_API.G_MISS_NUM,
    SUBJECT_INDEX                   NUMBER           := FND_API.G_MISS_NUM,
    SUBJECT_ID                      NUMBER           := FND_API.G_MISS_NUM,
    SUBJECT_HAS_CHILD               VARCHAR2(1)      := FND_API.G_MISS_CHAR,
    POSITION_REFERENCE              VARCHAR2(30)     := FND_API.G_MISS_CHAR,
    ACTIVE_START_DATE               DATE             := FND_API.G_MISS_DATE,
    ACTIVE_END_DATE                 DATE             := FND_API.G_MISS_DATE,
    DISPLAY_ORDER                   NUMBER           := FND_API.G_MISS_NUM,
    MANDATORY_FLAG                  VARCHAR2(1)      := FND_API.G_MISS_CHAR,
    CONTEXT                         VARCHAR2(30)     := FND_API.G_MISS_CHAR,
    ATTRIBUTE1                      VARCHAR2(150)    := FND_API.G_MISS_CHAR,
    ATTRIBUTE2                      VARCHAR2(150)    := FND_API.G_MISS_CHAR,
    ATTRIBUTE3                      VARCHAR2(150)    := FND_API.G_MISS_CHAR,
    ATTRIBUTE4                      VARCHAR2(150)    := FND_API.G_MISS_CHAR,
    ATTRIBUTE5                      VARCHAR2(150)    := FND_API.G_MISS_CHAR,
    ATTRIBUTE6                      VARCHAR2(150)    := FND_API.G_MISS_CHAR,
    ATTRIBUTE7                      VARCHAR2(150)    := FND_API.G_MISS_CHAR,
    ATTRIBUTE8                      VARCHAR2(150)    := FND_API.G_MISS_CHAR,
    ATTRIBUTE9                      VARCHAR2(150)    := FND_API.G_MISS_CHAR,
    ATTRIBUTE10                     VARCHAR2(150)    := FND_API.G_MISS_CHAR,
    ATTRIBUTE11                     VARCHAR2(150)    := FND_API.G_MISS_CHAR,
    ATTRIBUTE12                     VARCHAR2(150)    := FND_API.G_MISS_CHAR,
    ATTRIBUTE13                     VARCHAR2(150)    := FND_API.G_MISS_CHAR,
    ATTRIBUTE14                     VARCHAR2(150)    := FND_API.G_MISS_CHAR,
    ATTRIBUTE15                     VARCHAR2(150)    := FND_API.G_MISS_CHAR,
    OBJECT_VERSION_NUMBER           NUMBER           := FND_API.G_MISS_NUM
  );

  TYPE  txn_ii_relationships_tbl IS TABLE OF txn_ii_relationship_rec INDEX BY BINARY_INTEGER;

  -- Name           : txn_ext_attrib_value_rec
  -- Description    : record to hold the values of an item instances extended attributes.

  TYPE txn_ext_attrib_value_rec IS RECORD (
    attribute_value_id      NUMBER         :=  FND_API.G_MISS_NUM,
    parent_tbl_index        NUMBER         :=  FND_API.G_MISS_NUM,
    instance_id             NUMBER         :=  FND_API.G_MISS_NUM,
    attribute_id            NUMBER         :=  FND_API.G_MISS_NUM,
    attribute_code          VARCHAR2(30)   :=  fnd_api.g_miss_char ,
    attribute_value         VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
    active_start_date       DATE           :=  FND_API.G_MISS_DATE,
    active_end_date         DATE           :=  FND_API.G_MISS_DATE,
    context                 VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    attribute1              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    attribute2              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    attribute3              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    attribute4              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    attribute5              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    attribute6              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    attribute7              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    attribute8              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    attribute9              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    attribute10             VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    attribute11             VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    attribute12             VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    attribute13             VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    attribute14             VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    attribute15             VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    object_version_number   NUMBER         :=  FND_API.G_MISS_NUM
  );


  TYPE txn_ext_attrib_values_tbl IS table of txn_ext_attrib_value_rec INDEX BY BINARY_INTEGER;

  -- Name           : txn_pricing_attrib_rec
  -- Description    : record to hold the pricing attributes of an item instance.


  TYPE txn_pricing_attrib_rec IS RECORD (
     pricing_attribute_id             NUMBER         :=  FND_API.G_MISS_NUM,
     parent_tbl_index                 NUMBER         :=  FND_API.G_MISS_NUM,
     instance_id                      NUMBER         :=  FND_API.G_MISS_NUM,
     active_start_date                DATE           :=  FND_API.G_MISS_DATE,
     active_end_date                  DATE           :=  FND_API.G_MISS_DATE,
     pricing_context                  VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     pricing_attribute1               VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute2               VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute3               VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute4               VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute5               VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute6               VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute7               VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute8               VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute9               VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute10              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute11              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute12              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute13              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute14              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute15              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute16              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute17              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute18              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute19              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute20              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute21              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute22              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute23              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute24              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute25              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute26              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute27              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute28              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute29              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute30              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute31              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute32              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute33              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute34              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute35              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute36              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute37              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute38              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute39              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute40              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute41              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute42              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute43              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute44              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute45              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute46              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute47              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute48              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute49              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute50              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute51              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute52              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute53              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute54              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute55              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute56              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute57              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute58              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute59              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute60              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute61              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute62              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute63              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute64              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute65              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute66              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute67              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute68              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute69              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute70              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute71              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute72              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute73              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute74              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute75              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute76              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute77              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute78              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute79              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute80              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute81              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute82              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute83              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute84              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute85              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute86              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute87              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute88              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute89              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute90              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute91              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute92              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute93              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute94              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute95              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute96              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute97              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute98              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute99              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     pricing_attribute100             VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     context                          VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     attribute1                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute2                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute3                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute4                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute5                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute6                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute7                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute8                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute9                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute10                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute11                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute12                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute13                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute14                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute15                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     object_version_number            NUMBER         :=  FND_API.G_MISS_NUM
  );

  TYPE txn_pricing_attribs_tbl IS TABLE OF txn_pricing_attrib_rec INDEX BY BINARY_INTEGER;

  -- Name           : txn_org_unit_rec
  -- Description    : record to hold information about an instance-org association.


  TYPE txn_org_unit_rec IS RECORD (
     instance_ou_id                   NUMBER         :=  FND_API.G_MISS_NUM,
     parent_tbl_index                 NUMBER         :=  FND_API.G_MISS_NUM,
     instance_id                      NUMBER         :=  FND_API.G_MISS_NUM,
     operating_unit_id                NUMBER         :=  FND_API.G_MISS_NUM,
     relationship_type_code           VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     active_start_date                DATE           :=  FND_API.G_MISS_DATE,
     active_end_date                  DATE           :=  FND_API.G_MISS_DATE,
     context                          VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     attribute1                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute2                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute3                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute4                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute5                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute6                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute7                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute8                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute9                       VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute10                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute11                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute12                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute13                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute14                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     attribute15                      VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     object_version_number            NUMBER         :=  FND_API.G_MISS_NUM
  );

  TYPE txn_org_units_tbl IS TABLE OF txn_org_unit_rec INDEX BY BINARY_INTEGER;

  -- Name           : txn_instance_asset_rec
  -- Description    : record to hold information about instance-asset association.

  TYPE txn_instance_asset_rec IS RECORD (
    instance_asset_id          NUMBER          :=  FND_API.G_MISS_NUM,
    parent_tbl_index           NUMBER          :=  FND_API.G_MISS_NUM,
    instance_id                NUMBER          :=  FND_API.G_MISS_NUM,
    fa_asset_id                NUMBER          :=  FND_API.G_MISS_NUM,
    fa_book_type_code          VARCHAR2(15)    :=  FND_API.G_MISS_CHAR,
    fa_location_id             NUMBER          :=  FND_API.G_MISS_NUM,
    asset_quantity             NUMBER          :=  FND_API.G_MISS_NUM,
    update_status              VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
    active_start_date          DATE            :=  FND_API.G_MISS_DATE,
    active_end_date            DATE            :=  FND_API.G_MISS_DATE,
    object_version_number      NUMBER          :=  FND_API.G_MISS_NUM);

  TYPE txn_instance_asset_tbl IS TABLE OF txn_instance_asset_rec INDEX BY BINARY_INTEGER;



  /*-------------------------------------------------------------------*/
  /* Group API used to process one source transaction line             */
  /* This api reads a set op pl/sql tables and converts them in to     */
  /* instances .If an instance reference is found then it updates the  */
  /* instance for the location and party attributes                    */
  /*-------------------------------------------------------------------*/

  PROCEDURE process_transaction (
    p_api_version             IN     NUMBER,
    p_commit                  IN     VARCHAR2 := fnd_api.g_false,
    p_init_msg_list           IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level        IN     NUMBER   := fnd_api.g_valid_level_full,
    p_validate_only_flag      IN     VARCHAR2 := fnd_api.g_false,
    p_in_out_flag             IN     VARCHAR2, -- valid values are 'IN', 'OUT'
    p_dest_location_rec       IN OUT NOCOPY dest_location_rec,
    p_txn_rec                 IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    p_instances_tbl           IN OUT NOCOPY txn_instances_tbl,
    p_i_parties_tbl           IN OUT NOCOPY txn_i_parties_tbl,
    p_ip_accounts_tbl         IN OUT NOCOPY txn_ip_accounts_tbl,
    p_org_units_tbl           IN OUT NOCOPY txn_org_units_tbl,
    p_ext_attrib_vlaues_tbl   IN OUT NOCOPY txn_ext_attrib_values_tbl,
    p_pricing_attribs_tbl     IN OUT NOCOPY txn_pricing_attribs_tbl,
    p_instance_asset_tbl      IN OUT NOCOPY txn_instance_asset_tbl,
    p_ii_relationships_tbl    IN OUT NOCOPY txn_ii_relationships_tbl,
    px_txn_error_rec          IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2 );

  /* overloading to supress the visibility of the signature change to field service */
  PROCEDURE process_transaction (
    p_api_version             IN     NUMBER,
    p_commit                  IN     VARCHAR2 := fnd_api.g_false,
    p_init_msg_list           IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level        IN     NUMBER   := fnd_api.g_valid_level_full,
    p_validate_only_flag      IN     VARCHAR2 := fnd_api.g_false,
    p_in_out_flag             IN     VARCHAR2, -- valid values are 'IN', 'OUT'
    p_dest_location_rec       IN OUT NOCOPY dest_location_rec,
    p_txn_rec                 IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    p_instances_tbl           IN OUT NOCOPY txn_instances_tbl,
    p_i_parties_tbl           IN OUT NOCOPY txn_i_parties_tbl,
    p_ip_accounts_tbl         IN OUT NOCOPY txn_ip_accounts_tbl,
    p_org_units_tbl           IN OUT NOCOPY txn_org_units_tbl,
    p_ext_attrib_vlaues_tbl   IN OUT NOCOPY txn_ext_attrib_values_tbl,
    p_pricing_attribs_tbl     IN OUT NOCOPY txn_pricing_attribs_tbl,
    p_instance_asset_tbl      IN OUT NOCOPY txn_instance_asset_tbl,
    p_ii_relationships_tbl    IN OUT NOCOPY txn_ii_relationships_tbl,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2 );

END csi_process_txn_grp;

 

/
