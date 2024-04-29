--------------------------------------------------------
--  DDL for Package CSI_DATASTRUCTURES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_DATASTRUCTURES_PUB" AUTHID CURRENT_USER AS
/* $Header: csipdss.pls 120.19.12010000.6 2009/04/07 18:32:26 hyonlee ship $ */

-- Added by sguthiva for att enhancements
-- The following 2 tables will be used during the batch validation
TYPE parameter_name IS TABLE OF VARCHAR2(30)
INDEX BY BINARY_INTEGER;
TYPE parameter_value IS TABLE OF VARCHAR2(200)
INDEX BY BINARY_INTEGER;
-- End addition by sguthiva for att enhancements

--      Name           : party_account_query_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold information to query a party-account relationship.

TYPE party_account_query_rec IS RECORD
 (
     ip_account_id                    NUMBER         :=  FND_API.G_MISS_NUM,
     instance_party_id                NUMBER         :=  FND_API.G_MISS_NUM,
     party_account_id                 NUMBER         :=  FND_API.G_MISS_NUM,
     relationship_type_code           VARCHAR2(30)   :=  FND_API.G_MISS_CHAR
 );

 TYPE install_param_rec IS RECORD
 ( INTERNAL_PARTY_ID            NUMBER
  ,PROJECT_LOCATION_ID          NUMBER
  ,WIP_LOCATION_ID              NUMBER
  ,IN_TRANSIT_LOCATION_ID       NUMBER
  ,PO_LOCATION_ID               NUMBER
  ,CATEGORY_SET_ID              NUMBER
  ,HISTORY_FULL_DUMP_FREQUENCY  NUMBER
  ,FREEZE_FLAG                  VARCHAR2(1)
  ,FREEZE_DATE                  DATE
  ,SHOW_ALL_PARTY_LOCATION      VARCHAR2(1)
  ,OWNERSHIP_OVERRIDE_AT_TXN    VARCHAR2(1)
  ,SFM_QUEUE_BYPASS_FLAG        VARCHAR2(1)
  ,AUTO_ALLOCATE_COMP_AT_WIP    VARCHAR2(1)
  ,TXN_SEQ_START_DATE           DATE
  ,OWNERSHIP_CASCADE_AT_TXN     VARCHAR2(1)
  ,FETCH_FLAG                   VARCHAR2(1)
  ,FA_CREATION_GROUP_BY         VARCHAR2(30)
 );

 G_INSTALL_PARAM_REC    INSTALL_PARAM_REC;

--      Name           : party_account_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    :  record to hold information about a party-account relationship.


TYPE party_account_rec IS RECORD
 (
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
     object_version_number            NUMBER         :=  FND_API.G_MISS_NUM ,
     call_contracts                   VARCHAR2(1)    :=  FND_API.G_TRUE,
     vld_organization_id              NUMBER         :=  FND_API.G_MISS_NUM,
     expire_flag                      VARCHAR2(1)    :=  FND_API.G_FALSE, --Added by sguthiva for bug 2307804
     grp_call_contracts               VARCHAR2(1)    :=  FND_API.G_FALSE, -- Should be turned on only by GRP API. For internal use only.
     REQUEST_ID                       NUMBER         :=  FND_API.G_MISS_NUM,
     PROGRAM_APPLICATION_ID           NUMBER         :=  FND_API.G_MISS_NUM,
     PROGRAM_ID                       NUMBER         :=  FND_API.G_MISS_NUM,
     PROGRAM_UPDATE_DATE              DATE           :=  FND_API.G_MISS_DATE,
     SYSTEM_ID                        NUMBER         :=  FND_API.G_MISS_NUM, -- OKS Enhancement only
     CASCADE_OWNERSHIP_FLAG           VARCHAR2(1)    :=  FND_API.G_MISS_CHAR ---- Added for bug 2972082
);

TYPE party_account_tbl IS TABLE OF party_account_rec INDEX BY BINARY_INTEGER;


--      Name           : party_query_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold information to query an instance-party relationship.


TYPE party_query_rec IS RECORD
 (
     instance_party_id                NUMBER         :=  FND_API.G_MISS_NUM,
     instance_id                      NUMBER         :=  FND_API.G_MISS_NUM,
     party_id                         NUMBER         :=  FND_API.G_MISS_NUM,
     relationship_type_code           VARCHAR2(30)   :=  FND_API.G_MISS_CHAR
  );



--      Name           : party_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold information about an instance-party relationship.


TYPE party_rec IS RECORD
 (
     instance_party_id                NUMBER         :=  FND_API.G_MISS_NUM,
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
     object_version_number            NUMBER         :=  FND_API.G_MISS_NUM,
     primary_flag                     VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     preferred_flag                   VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     parent_tbl_index                 NUMBER         :=  FND_API.G_MISS_NUM,
     call_contracts                   VARCHAR2(1)    :=  FND_API.G_TRUE,
     interface_id                     NUMBER         :=  FND_API.G_MISS_NUM,
     contact_parent_tbl_index         NUMBER         :=  FND_API.G_MISS_NUM,
     cascade_ownership_flag           VARCHAR2(1)    :=  FND_API.G_MISS_CHAR ---- Added for bug 2972082
);

-- cascade_ownership_flag is strictly for internal use only.
TYPE party_tbl IS TABLE OF party_rec INDEX BY BINARY_INTEGER;



--      Name           : party_header_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold header information about an instance-party relationship.


TYPE party_header_rec IS RECORD
 (
     instance_party_id                NUMBER         :=  FND_API.G_MISS_NUM,
     instance_id                      NUMBER         :=  FND_API.G_MISS_NUM,
     party_source_table               VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     party_id                         NUMBER         :=  FND_API.G_MISS_NUM,
     relationship_type_code           VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     contact_flag                     VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     contact_ip_id                    NUMBER         :=  FND_API.G_MISS_NUM,
     party_number                     VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     party_name                       VARCHAR2(360)  :=  FND_API.G_MISS_CHAR,
     party_type                       VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
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
     object_version_number            NUMBER         :=  FND_API.G_MISS_NUM,
     address1                         VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
     address2                         VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
     address3                         VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
     address4                         VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
     city                             VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
     state                            VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
     postal_code                      VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
     country                          VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
     work_phone_number                VARCHAR2(85)   :=  FND_API.G_MISS_CHAR,
     email_address                    VARCHAR2(2000) :=  FND_API.G_MISS_CHAR,
     primary_flag                     VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     preferred_flag                   VARCHAR2(1)    :=  FND_API.G_MISS_CHAR
);

TYPE party_header_tbl IS TABLE OF party_header_rec INDEX BY BINARY_INTEGER;


--      Name           : version_label_query_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold the information for querying the version label of an item instance.

TYPE version_label_query_rec IS RECORD
 (
     version_label_id                 NUMBER         :=  FND_API.G_MISS_NUM,
     instance_id                      NUMBER         :=  FND_API.G_MISS_NUM,
     version_label                    VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
     date_time_stamp                  DATE           :=  FND_API.G_MISS_DATE
  );


--      Name           : version_label_rec
--      Package name   : csi_datastructures_pub
--      Type           :   type definition, public
--      Description    :   record to hold the version label information for an item instance.

TYPE version_label_rec IS RECORD
 (
     version_label_id                 NUMBER         :=  FND_API.G_MISS_NUM,
     instance_id                      NUMBER         :=  FND_API.G_MISS_NUM,
     version_label                    VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
     description                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
     date_time_stamp                  DATE           :=  FND_API.G_MISS_DATE,
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


TYPE version_label_tbl IS TABLE OF version_label_rec INDEX BY BINARY_INTEGER;


TYPE id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


TYPE instance_asset_location_rec IS RECORD
(
   ASSET_LOCATION_ID             NUMBER       :=  FND_API.G_MISS_NUM ,
   FA_LOCATION_ID                NUMBER       :=  FND_API.G_MISS_NUM ,
   LOCATION_TABLE                VARCHAR2(100):=  FND_API.G_MISS_CHAR,
   LOCATION_ID                   NUMBER       :=  FND_API.G_MISS_NUM ,
   ACTIVE_START_DATE             DATE         :=  FND_API.G_MISS_DATE,
   ACTIVE_END_DATE               DATE         :=  FND_API.G_MISS_DATE,
   OBJECT_VERSION_NUMBER         NUMBER       :=  FND_API.G_MISS_NUM
);


TYPE instance_asset_location_tbl IS TABLE OF instance_asset_location_rec INDEX BY BINARY_INTEGER;


--      Name           : instance_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold the attributes of an item instance.


TYPE instance_rec is RECORD
  (      INSTANCE_ID                     NUMBER         :=  FND_API.G_MISS_NUM,
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
         ATTRIBUTE1                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE2                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE3                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE4                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE5                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE6                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE7                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE8                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE9                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE10                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE11                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE12                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE13                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE14                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE15                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         OBJECT_VERSION_NUMBER           NUMBER         :=  FND_API.G_MISS_NUM,
         LAST_TXN_LINE_DETAIL_ID         NUMBER         :=  FND_API.G_MISS_NUM,
         INSTALL_LOCATION_TYPE_CODE      VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
         INSTALL_LOCATION_ID             NUMBER         :=  FND_API.G_MISS_NUM,
         INSTANCE_USAGE_CODE             VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
         CHECK_FOR_INSTANCE_EXPIRY       VARCHAR2(1)    :=  FND_API.G_TRUE,
         PROCESSED_FLAG                  VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
         CALL_CONTRACTS                  VARCHAR2(1)    :=  FND_API.G_TRUE,
         INTERFACE_ID                    NUMBER         :=  FND_API.G_MISS_NUM,
         GRP_CALL_CONTRACTS              VARCHAR2(1)    :=  FND_API.G_FALSE, -- Should be turned on only from Group API. For internal use only.
         CONFIG_INST_HDR_ID              NUMBER         :=  FND_API.G_MISS_NUM,
         CONFIG_INST_REV_NUM             NUMBER         :=  FND_API.G_MISS_NUM,
         CONFIG_INST_ITEM_ID             NUMBER         :=  FND_API.G_MISS_NUM,
         CONFIG_VALID_STATUS             VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
         INSTANCE_DESCRIPTION            VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         CALL_BATCH_VALIDATION           VARCHAR2(1)    :=  FND_API.G_TRUE,
         REQUEST_ID                      NUMBER         :=  FND_API.G_MISS_NUM,
         PROGRAM_APPLICATION_ID          NUMBER         :=  FND_API.G_MISS_NUM,
         PROGRAM_ID                      NUMBER         :=  FND_API.G_MISS_NUM,
         PROGRAM_UPDATE_DATE             DATE           :=  FND_API.G_MISS_DATE,
         CASCADE_OWNERSHIP_FLAG          VARCHAR2(1)    :=  FND_API.G_MISS_CHAR, ---- Added for bug 2972082
         -- Start addition of columns for EAM integration
         NETWORK_ASSET_FLAG              VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
         MAINTAINABLE_FLAG               VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
         PN_LOCATION_ID                  NUMBER         :=  FND_API.G_MISS_NUM,
         ASSET_CRITICALITY_CODE          VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
         CATEGORY_ID                     NUMBER         :=  FND_API.G_MISS_NUM,
         EQUIPMENT_GEN_OBJECT_ID         NUMBER         :=  FND_API.G_MISS_NUM,
         INSTANTIATION_FLAG              VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
         LINEAR_LOCATION_ID              NUMBER         :=  FND_API.G_MISS_NUM,
         OPERATIONAL_LOG_FLAG            VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
         CHECKIN_STATUS                  NUMBER         :=  FND_API.G_MISS_NUM,
         SUPPLIER_WARRANTY_EXP_DATE      DATE           :=  FND_API.G_MISS_DATE,
         ATTRIBUTE16                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE17                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE18                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE19                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE20                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE21                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE22                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE23                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE24                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE25                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE26                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE27                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE28                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE29                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
         ATTRIBUTE30                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
   -- End addition of columns for EAM integration
   -- Addition of columns for FA Integration
         PURCHASE_UNIT_PRICE             NUMBER         :=  FND_API.G_MISS_NUM,
         PURCHASE_CURRENCY_CODE          VARCHAR2(15)   :=  FND_API.G_MISS_CHAR,
         PAYABLES_UNIT_PRICE             NUMBER         :=  FND_API.G_MISS_NUM,
         PAYABLES_CURRENCY_CODE          VARCHAR2(15)   :=  FND_API.G_MISS_CHAR,
         SALES_UNIT_PRICE                NUMBER         :=  FND_API.G_MISS_NUM,
         SALES_CURRENCY_CODE             VARCHAR2(15)   :=  FND_API.G_MISS_CHAR,
         OPERATIONAL_STATUS_CODE         VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    -- End addition of columns for FA Integration
    -- Added the following columns for bug 4632441
         DEPARTMENT_ID                   NUMBER         := fnd_api.g_miss_num,
         WIP_ACCOUNTING_CLASS            VARCHAR2(10)   := fnd_api.g_miss_char,
         AREA_ID                         NUMBER         := fnd_api.g_miss_num,
    -- End addition of columns for bug 4632441
         OWNER_PARTY_ID                  NUMBER         := fnd_api.g_miss_num,
         SOURCE_CODE                     VARCHAR2(10)   := FND_API.G_MISS_CHAR -- Added Code for Siebel Genesis Project
  );

-- cascade_ownership_flag is strictly for internal use only.

TYPE instance_tbl is TABLE OF instance_rec INDEX BY BINARY_INTEGER;



--      Name           : instance_query_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold the attributes to query an item instance.


TYPE instance_query_rec is RECORD
  (
      INSTANCE_ID                     NUMBER         :=  FND_API.G_MISS_NUM,
      INVENTORY_ITEM_ID               NUMBER         :=  FND_API.G_MISS_NUM,
      INVENTORY_REVISION              VARCHAR2(3)    :=  FND_API.G_MISS_CHAR,
      INV_MASTER_ORGANIZATION_ID      NUMBER         :=  FND_API.G_MISS_NUM,
      SERIAL_NUMBER                   VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      LOT_NUMBER                      VARCHAR2(80)   :=  FND_API.G_MISS_CHAR,
      UNIT_OF_MEASURE                 VARCHAR2(3)    :=  FND_API.G_MISS_CHAR,
      INSTANCE_CONDITION_ID           NUMBER         :=  FND_API.G_MISS_NUM,
      INSTANCE_STATUS_ID              NUMBER         :=  FND_API.G_MISS_NUM,
      SYSTEM_ID                       NUMBER         :=  FND_API.G_MISS_NUM,
      INSTANCE_TYPE_CODE              VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
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
      INSTANCE_USAGE_CODE             VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      QUERY_UNITS_ONLY                VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
      CONTRACT_NUMBER                 VARCHAR2(120)  :=  FND_API.G_MISS_CHAR,  -- Added
      CONFIG_INST_HDR_ID              NUMBER         :=  FND_API.G_MISS_NUM,
      CONFIG_INST_REV_NUM             NUMBER         :=  FND_API.G_MISS_NUM,
      CONFIG_INST_ITEM_ID             NUMBER         :=  FND_API.G_MISS_NUM,
      INSTANCE_DESCRIPTION            VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      OPERATIONAL_STATUS_CODE         VARCHAR2(30)   :=  FND_API.G_MISS_CHAR
);



--      Name           : instance_header_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold the header attributes of an item instance.

TYPE instance_header_rec is RECORD
  (

      INSTANCE_ID                     NUMBER         :=  FND_API.G_MISS_NUM,
      INSTANCE_NUMBER                 VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      EXTERNAL_REFERENCE              VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      INVENTORY_ITEM_ID               NUMBER         :=  FND_API.G_MISS_NUM,
      INVENTORY_REVISION              VARCHAR2(3)    :=  FND_API.G_MISS_CHAR,
      INV_MASTER_ORGANIZATION_ID      NUMBER         :=  FND_API.G_MISS_NUM,
      SERIAL_NUMBER                   VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      MFG_SERIAL_NUMBER_FLAG          VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
      LOT_NUMBER                      VARCHAR2(80)   :=  FND_API.G_MISS_CHAR,
      QUANTITY                        NUMBER         :=  FND_API.G_MISS_NUM,
      UNIT_OF_MEASURE_NAME            VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      UNIT_OF_MEASURE                 VARCHAR2(3)    :=  FND_API.G_MISS_CHAR,
      ACCOUNTING_CLASS                VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      ACCOUNTING_CLASS_CODE           VARCHAR2(10)   :=  FND_API.G_MISS_CHAR,
      INSTANCE_CONDITION              VARCHAR2(80)   :=  FND_API.G_MISS_CHAR,
      INSTANCE_CONDITION_ID           NUMBER         :=  FND_API.G_MISS_NUM,
      INSTANCE_STATUS                 VARCHAR2(50)   :=  FND_API.G_MISS_CHAR,
      INSTANCE_STATUS_ID              NUMBER         :=  FND_API.G_MISS_NUM,
      CUSTOMER_VIEW_FLAG              VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
      MERCHANT_VIEW_FLAG              VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
      SELLABLE_FLAG                   VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
      SYSTEM_ID                       NUMBER         :=  FND_API.G_MISS_NUM,
      SYSTEM_NAME                     VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      INSTANCE_TYPE_CODE              VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      INSTANCE_TYPE_NAME              VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ACTIVE_START_DATE               DATE           :=  FND_API.G_MISS_DATE,
      ACTIVE_END_DATE                 DATE           :=  FND_API.G_MISS_DATE,
      LOCATION_TYPE_CODE              VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      LOCATION_ID                     NUMBER         :=  FND_API.G_MISS_NUM,
      INV_ORGANIZATION_ID             NUMBER         :=  FND_API.G_MISS_NUM,
      INV_ORGANIZATION_NAME           VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      INV_SUBINVENTORY_NAME           VARCHAR2(10)   :=  FND_API.G_MISS_CHAR,
      INV_LOCATOR_ID                  NUMBER         :=  FND_API.G_MISS_NUM,
      PA_PROJECT_ID                   NUMBER         :=  FND_API.G_MISS_NUM,
      PA_PROJECT_TASK_ID              NUMBER         :=  FND_API.G_MISS_NUM,
      PA_PROJECT_NAME                 VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      PA_PROJECT_NUMBER               VARCHAR2(25)   :=  FND_API.G_MISS_CHAR,
      PA_TASK_NAME                    VARCHAR2(20)   :=  FND_API.G_MISS_CHAR,
      PA_TASK_NUMBER                  VARCHAR2(25)   :=  FND_API.G_MISS_CHAR,
      IN_TRANSIT_ORDER_LINE_ID        NUMBER         :=  FND_API.G_MISS_NUM,
      IN_TRANSIT_ORDER_LINE_NUMBER    NUMBER         :=  FND_API.G_MISS_NUM,
      IN_TRANSIT_ORDER_NUMBER         NUMBER         :=  FND_API.G_MISS_NUM,
      WIP_JOB_ID                      NUMBER         :=  FND_API.G_MISS_NUM,
      WIP_ENTITY_NAME                 VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
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
      CONTEXT                         VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE1                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE2                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE3                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE4                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE5                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE6                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE7                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE8                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE9                      VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE10                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE11                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE12                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE13                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE14                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE15                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      OBJECT_VERSION_NUMBER           NUMBER         :=  FND_API.G_MISS_NUM,
      LAST_TXN_LINE_DETAIL_ID         NUMBER         :=  FND_API.G_MISS_NUM,
      INSTALL_LOCATION_TYPE_CODE      VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      INSTALL_LOCATION_ID             NUMBER         :=  FND_API.G_MISS_NUM,
      INSTANCE_USAGE_CODE             VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      CURRENT_LOC_ADDRESS1            VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      CURRENT_LOC_ADDRESS2            VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      CURRENT_LOC_ADDRESS3            VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      CURRENT_LOC_ADDRESS4            VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      CURRENT_LOC_CITY                VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      CURRENT_LOC_STATE               VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
      CURRENT_LOC_POSTAL_CODE         VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      CURRENT_LOC_COUNTRY             VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      SALES_ORDER_NUMBER              NUMBER         :=  FND_API.G_MISS_NUM,
      SALES_ORDER_LINE_NUMBER         NUMBER         :=  FND_API.G_MISS_NUM,
      SALES_ORDER_DATE                DATE           :=  FND_API.G_MISS_DATE,
      PURCHASE_ORDER_NUMBER           VARCHAR2(50)   :=  FND_API.G_MISS_CHAR,
      INSTANCE_USAGE_NAME             VARCHAR2(80)   :=  FND_API.G_MISS_CHAR,
      INSTALL_LOC_ADDRESS1            VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      INSTALL_LOC_ADDRESS2            VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      INSTALL_LOC_ADDRESS3            VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      INSTALL_LOC_ADDRESS4            VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      INSTALL_LOC_CITY                VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      INSTALL_LOC_STATE               VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
      INSTALL_LOC_POSTAL_CODE         VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      INSTALL_LOC_COUNTRY             VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      VLD_ORGANIZATION_ID             NUMBER         :=  FND_API.G_MISS_NUM,
      CURRENT_LOC_NUMBER              VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      INSTALL_LOC_NUMBER              VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      CURRENT_PARTY_NAME              VARCHAR2(360)  :=  FND_API.G_MISS_CHAR,
      CURRENT_PARTY_NUMBER            VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      INSTALL_PARTY_NAME              VARCHAR2(360)  :=  FND_API.G_MISS_CHAR,
      INSTALL_PARTY_NUMBER            VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      CONFIG_INST_HDR_ID              NUMBER         :=  FND_API.G_MISS_NUM,
      CONFIG_INST_REV_NUM             NUMBER         :=  FND_API.G_MISS_NUM,
      CONFIG_INST_ITEM_ID             NUMBER         :=  FND_API.G_MISS_NUM,
      CONFIG_VALID_STATUS             VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      INSTANCE_DESCRIPTION            VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      START_LOC_ADDRESS1              VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      START_LOC_ADDRESS2              VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      START_LOC_ADDRESS3              VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      START_LOC_ADDRESS4              VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      START_LOC_CITY                  VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      START_LOC_STATE                 VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      START_LOC_POSTAL_CODE           VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      START_LOC_COUNTRY               VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      END_LOC_ADDRESS1                VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      END_LOC_ADDRESS2                VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      END_LOC_ADDRESS3                VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      END_LOC_ADDRESS4                VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      END_LOC_CITY                    VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      END_LOC_STATE                   VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      END_LOC_POSTAL_CODE             VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      END_LOC_COUNTRY                 VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      VLD_ORGANIZATION_NAME           VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      LAST_OE_AGREEMENT_NAME          VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      INV_LOCATOR_NAME                VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
            -- Start addition of columns for EAM integration
      NETWORK_ASSET_FLAG              VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
      MAINTAINABLE_FLAG               VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
      PN_LOCATION_ID                  NUMBER         :=  FND_API.G_MISS_NUM,
      ASSET_CRITICALITY_CODE          VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      CATEGORY_ID                     NUMBER         :=  FND_API.G_MISS_NUM,
      EQUIPMENT_GEN_OBJECT_ID         NUMBER         :=  FND_API.G_MISS_NUM,
      INSTANTIATION_FLAG              VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
      LINEAR_LOCATION_ID              NUMBER         :=  FND_API.G_MISS_NUM,
      OPERATIONAL_LOG_FLAG            VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
      CHECKIN_STATUS                  NUMBER         :=  FND_API.G_MISS_NUM,
      SUPPLIER_WARRANTY_EXP_DATE      DATE           :=  FND_API.G_MISS_DATE,
      ATTRIBUTE16                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE17                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE18                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE19                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE20                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE21                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE22                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE23                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE24                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE25                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE26                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE27                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE28                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE29                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      ATTRIBUTE30                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
   -- End addition of columns for EAM integration
   -- Addition of columns for FA Integration
      PURCHASE_UNIT_PRICE             NUMBER         :=  FND_API.G_MISS_NUM,
      PURCHASE_CURRENCY_CODE          VARCHAR2(15)   :=  FND_API.G_MISS_CHAR,
      PAYABLES_UNIT_PRICE             NUMBER         :=  FND_API.G_MISS_NUM,
      PAYABLES_CURRENCY_CODE          VARCHAR2(15)   :=  FND_API.G_MISS_CHAR,
      SALES_UNIT_PRICE                NUMBER         :=  FND_API.G_MISS_NUM,
      SALES_CURRENCY_CODE             VARCHAR2(15)   :=  FND_API.G_MISS_CHAR,
      OPERATIONAL_STATUS_CODE         VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      OPERATIONAL_STATUS_NAME         VARCHAR2(80)   :=  FND_API.G_MISS_CHAR,
    -- End addition of columns for FA Integration
    -- Addition of columns to resolve ids for eam
      MAINTENANCE_ORGANIZATION        VARCHAR2(3)    :=  FND_API.G_MISS_CHAR,
      DEPARTMENT                      VARCHAR2(10)   :=  FND_API.G_MISS_CHAR,
      AREA                            VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      WIP_ACCOUNTING_CLASS            VARCHAR2(10)   :=  FND_API.G_MISS_CHAR,
      PARENT_ASSET_GROUP              VARCHAR2(40)   :=  FND_API.G_MISS_CHAR,
      CRITICALITY                     VARCHAR2(80)   :=  FND_API.G_MISS_CHAR,
      CATEGORY_NAME                   VARCHAR2(163)  :=  FND_API.G_MISS_CHAR,
      PARENT_ASSET_NUMBER             VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      MAINTAINABLE		      VARCHAR2(5)    :=  FND_API.G_MISS_CHAR, --for bug 5211068
    -- End addition of columns to resolve ids for eam
      VERSION_LABEL                   VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
      VERSION_LABEL_MEANING           VARCHAR2(80)   :=  FND_API.G_MISS_CHAR,
      INVENTORY_ITEM_NAME             VARCHAR2(240)  :=  FND_API.G_MISS_CHAR  --Bug 7292862
     );



TYPE instance_header_tbl is TABLE OF instance_header_rec INDEX BY BINARY_INTEGER;

TYPE transaction_query_rec IS RECORD
(
       TRANSACTION_ID                  NUMBER           := FND_API.G_MISS_NUM,
       TRANSACTION_TYPE_ID             NUMBER           := FND_API.G_MISS_NUM,
       TXN_SUB_TYPE_ID                 NUMBER           := FND_API.G_MISS_NUM,
       SOURCE_GROUP_REF_ID             NUMBER           := FND_API.G_MISS_NUM,
       SOURCE_GROUP_REF                VARCHAR2(50)     := FND_API.G_MISS_CHAR,
       SOURCE_HEADER_REF_ID            NUMBER           := FND_API.G_MISS_NUM,
       SOURCE_HEADER_REF               VARCHAR2(50)     := FND_API.G_MISS_CHAR,
       SOURCE_LINE_REF_ID              NUMBER           := FND_API.G_MISS_NUM,
       SOURCE_LINE_REF                 VARCHAR2(50)     := FND_API.G_MISS_CHAR,
       SOURCE_TRANSACTION_DATE         DATE             := FND_API.G_MISS_DATE,
       INV_MATERIAL_TRANSACTION_ID     NUMBER           := FND_API.G_MISS_NUM,
       MESSAGE_ID                      NUMBER           := FND_API.G_MISS_NUM,
       TRANSACTION_START_DATE          DATE             := FND_API.G_MISS_DATE,
       TRANSACTION_END_DATE            DATE             := FND_API.G_MISS_DATE,
       INSTANCE_ID                     NUMBER           := FND_API.G_MISS_NUM,
       TRANSACTION_STATUS_CODE         VARCHAR2(30)     := FND_API.G_MISS_CHAR

);

TYPE  transactions_query_tbl        IS TABLE OF transaction_query_rec
                                     INDEX BY BINARY_INTEGER;


TYPE transaction_sort_rec IS RECORD
(
      TRANSACTION_DATE                  VARCHAR2(1) := 'N',
      TRANSACTION_TYPE_ID               VARCHAR2(1) := 'N'
);


--      Name           : transaction_rec_type
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold the attributes of an Installed Base  transaction.


TYPE transaction_rec IS RECORD
(
       TRANSACTION_ID                  NUMBER        := FND_API.G_MISS_NUM ,
       TRANSACTION_DATE                DATE          := FND_API.G_MISS_DATE,
       SOURCE_TRANSACTION_DATE         DATE          := FND_API.G_MISS_DATE,
       TRANSACTION_TYPE_ID             NUMBER        := FND_API.G_MISS_NUM ,
       TXN_SUB_TYPE_ID                 NUMBER        := FND_API.G_MISS_NUM ,
       SOURCE_GROUP_REF_ID             NUMBER        := FND_API.G_MISS_NUM ,
       SOURCE_GROUP_REF                VARCHAR2(50),
       SOURCE_HEADER_REF_ID            NUMBER        := FND_API.G_MISS_NUM ,
       SOURCE_HEADER_REF               VARCHAR2(50),
       SOURCE_LINE_REF_ID              NUMBER        := FND_API.G_MISS_NUM ,
       SOURCE_LINE_REF                 VARCHAR2(50),
       SOURCE_DIST_REF_ID1             NUMBER        := FND_API.G_MISS_NUM ,
       SOURCE_DIST_REF_ID2             NUMBER        := FND_API.G_MISS_NUM ,
       INV_MATERIAL_TRANSACTION_ID     NUMBER        := FND_API.G_MISS_NUM ,
       TRANSACTION_QUANTITY            NUMBER        := FND_API.G_MISS_NUM ,
       TRANSACTION_UOM_CODE            VARCHAR2(3)   := FND_API.G_MISS_CHAR,
       TRANSACTED_BY                   NUMBER        := FND_API.G_MISS_NUM ,
       TRANSACTION_STATUS_CODE         VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       TRANSACTION_ACTION_CODE         VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       MESSAGE_ID                      NUMBER        := FND_API.G_MISS_NUM ,
       CONTEXT                         VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER           NUMBER        := FND_API.G_MISS_NUM ,
       SPLIT_REASON_CODE               VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       SRC_TXN_CREATION_DATE           DATE          := FND_API.G_MISS_DATE, --Internal Use Only Bug #3804960
       GL_INTERFACE_STATUS_CODE        NUMBER        := FND_API.G_MISS_NUM
);

TYPE  transaction_tbl IS TABLE OF transaction_rec INDEX BY BINARY_INTEGER;


TYPE transaction_error_rec IS RECORD
(
       TRANSACTION_ERROR_ID            NUMBER           := FND_API.G_MISS_NUM ,
       TRANSACTION_ID                  NUMBER           := FND_API.G_MISS_NUM ,
       MESSAGE_ID                      NUMBER           := FND_API.G_MISS_NUM ,
       ERROR_TEXT                      VARCHAR2(2000)   := FND_API.G_MISS_CHAR,
       SOURCE_TYPE                     VARCHAR2(240)    := FND_API.G_MISS_CHAR,
       SOURCE_ID                       NUMBER           := FND_API.G_MISS_NUM ,
       PROCESSED_FLAG                  VARCHAR2(1)      := FND_API.G_MISS_CHAR,
       CREATED_BY                      NUMBER           := FND_API.G_MISS_NUM ,
       CREATION_DATE                   DATE             := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER           := FND_API.G_MISS_NUM ,
       LAST_UPDATE_DATE                DATE             := FND_API.G_MISS_DATE,
       LAST_UPDATE_LOGIN               NUMBER           := FND_API.G_MISS_NUM ,
       OBJECT_VERSION_NUMBER           NUMBER           := FND_API.G_MISS_NUM ,
       TRANSACTION_TYPE_ID             NUMBER           := FND_API.G_MISS_NUM ,
       SOURCE_GROUP_REF                VARCHAR2(50)     := FND_API.G_MISS_CHAR,
       SOURCE_GROUP_REF_ID             NUMBER           := FND_API.G_MISS_NUM ,
       SOURCE_HEADER_REF               VARCHAR2(50)     := FND_API.G_MISS_CHAR,
       SOURCE_HEADER_REF_ID            NUMBER           := FND_API.G_MISS_NUM ,
       SOURCE_LINE_REF                 VARCHAR2(50)     := FND_API.G_MISS_CHAR,
       SOURCE_LINE_REF_ID              NUMBER           := FND_API.G_MISS_NUM ,
       SOURCE_DIST_REF_ID1             NUMBER           := FND_API.G_MISS_NUM ,
       SOURCE_DIST_REF_ID2             NUMBER           := FND_API.G_MISS_NUM ,
       INV_MATERIAL_TRANSACTION_ID     NUMBER           := FND_API.G_MISS_NUM ,
       ERROR_STAGE                     VARCHAR2(30)     := FND_API.G_MISS_CHAR,
       MESSAGE_STRING                  VARCHAR2(4000)   := FND_API.G_MISS_CHAR,
       INSTANCE_ID                     NUMBER           := FND_API.G_MISS_NUM ,
       INVENTORY_ITEM_ID               NUMBER           := FND_API.G_MISS_NUM ,
       SERIAL_NUMBER                   VARCHAR2(30)     := FND_API.G_MISS_CHAR,
       LOT_NUMBER                      VARCHAR2(80)     := FND_API.G_MISS_CHAR,
       TRANSACTION_ERROR_DATE          DATE             := FND_API.G_MISS_DATE,
       SRC_SERIAL_NUM_CTRL_CODE        NUMBER           := FND_API.G_MISS_NUM ,
       SRC_LOCATION_CTRL_CODE          NUMBER           := FND_API.G_MISS_NUM ,
       SRC_LOT_CTRL_CODE               NUMBER           := FND_API.G_MISS_NUM ,
       SRC_REV_QTY_CTRL_CODE           NUMBER           := FND_API.G_MISS_NUM ,
       DST_SERIAL_NUM_CTRL_CODE        NUMBER           := FND_API.G_MISS_NUM ,
       DST_LOCATION_CTRL_CODE          NUMBER           := FND_API.G_MISS_NUM ,
       DST_LOT_CTRL_CODE               NUMBER           := FND_API.G_MISS_NUM ,
       DST_REV_QTY_CTRL_CODE           NUMBER           := FND_API.G_MISS_NUM ,
       COMMS_NL_TRACKABLE_FLAG         VARCHAR2(1)      := FND_API.G_MISS_CHAR
);

TYPE  transactions_error_tbl      IS TABLE OF transaction_error_rec
                                    INDEX BY BINARY_INTEGER;



--      Name           : relationship_query_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold the attributes for querying an item instance relationship.


TYPE relationship_query_rec IS RECORD
 (
     relationship_id                  NUMBER        :=  FND_API.G_MISS_NUM
    ,relationship_type_code           VARCHAR2(30)  :=  FND_API.G_MISS_CHAR
    ,object_id                        NUMBER        :=  FND_API.G_MISS_NUM
    ,subject_id                       NUMBER        :=  FND_API.G_MISS_NUM
  );


--      Name           : ii_relationship_rec_type
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold the attributes of an item instance relationship.

TYPE ii_relationship_rec IS RECORD
(
       RELATIONSHIP_ID                 NUMBER           := FND_API.G_MISS_NUM,
       RELATIONSHIP_TYPE_CODE          VARCHAR2(30)     := FND_API.G_MISS_CHAR,
       OBJECT_ID                       NUMBER           := FND_API.G_MISS_NUM,
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
       OBJECT_VERSION_NUMBER           NUMBER           := FND_API.G_MISS_NUM,
       PARENT_TBL_INDEX                NUMBER           := FND_API.G_MISS_NUM,
       PROCESSED_FLAG                  VARCHAR2(1)      := FND_API.G_MISS_CHAR,
       INTERFACE_ID                    NUMBER           := FND_API.G_MISS_NUM,
       CASCADE_OWNERSHIP_FLAG          VARCHAR2(1)      := FND_API.G_MISS_CHAR -- Added for bug 2972082
);

-- cascade_ownership_flag is strictly for internal use only.

TYPE  ii_relationship_tbl      IS TABLE OF ii_relationship_rec
                                    INDEX BY BINARY_INTEGER;
/*-----------------------------------------------------*/
/* record to maintain the information we store in the  */
/* relationship history table                          */
/*-----------------------------------------------------*/


TYPE relationship_history_rec IS RECORD
(
   RELATIONSHIP_HISTORY_ID           NUMBER        :=FND_API.G_MISS_NUM,
   RELATIONSHIP_ID                   NUMBER        :=FND_API.G_MISS_NUM,
   TRANSACTION_ID                    NUMBER        :=FND_API.G_MISS_NUM,
   OLD_SUBJECT_ID                    NUMBER        :=FND_API.G_MISS_NUM,
   NEW_SUBJECT_ID                    NUMBER        :=FND_API.G_MISS_NUM,
   OLD_POSITION_REFERENCE            VARCHAR2(30)  :=FND_API.G_MISS_CHAR,
   NEW_POSITION_REFERENCE            VARCHAR2(30)  :=FND_API.G_MISS_CHAR,
   OLD_ACTIVE_START_DATE             DATE          :=FND_API.G_MISS_DATE,
   NEW_ACTIVE_START_DATE             DATE          :=FND_API.G_MISS_DATE,
   OLD_ACTIVE_END_DATE               DATE          :=FND_API.G_MISS_DATE,
   NEW_ACTIVE_END_DATE               DATE          :=FND_API.G_MISS_DATE,
   OLD_MANDATORY_FLAG                VARCHAR2(1)   :=FND_API.G_MISS_CHAR,
   NEW_MANDATORY_FLAG                VARCHAR2(1)   :=FND_API.G_MISS_CHAR,
   OLD_CONTEXT                       VARCHAR2(30)  :=FND_API.G_MISS_CHAR,
   NEW_CONTEXT                       VARCHAR2(30)  :=FND_API.G_MISS_CHAR,
   OLD_ATTRIBUTE1                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   NEW_ATTRIBUTE1                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   OLD_ATTRIBUTE2                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   NEW_ATTRIBUTE2                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   OLD_ATTRIBUTE3                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   NEW_ATTRIBUTE3                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   OLD_ATTRIBUTE4                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   NEW_ATTRIBUTE4                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   OLD_ATTRIBUTE5                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   NEW_ATTRIBUTE5                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   OLD_ATTRIBUTE6                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   NEW_ATTRIBUTE6                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   OLD_ATTRIBUTE7                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   NEW_ATTRIBUTE7                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   OLD_ATTRIBUTE8                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   NEW_ATTRIBUTE8                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   OLD_ATTRIBUTE9                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   NEW_ATTRIBUTE9                    VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   OLD_ATTRIBUTE10                   VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   NEW_ATTRIBUTE10                   VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   OLD_ATTRIBUTE11                   VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   NEW_ATTRIBUTE11                   VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   OLD_ATTRIBUTE12                   VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   NEW_ATTRIBUTE12                   VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   OLD_ATTRIBUTE13                   VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   NEW_ATTRIBUTE13                   VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   OLD_ATTRIBUTE14                   VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   NEW_ATTRIBUTE14                   VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   OLD_ATTRIBUTE15                   VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   NEW_ATTRIBUTE15                   VARCHAR2(150) :=FND_API.G_MISS_CHAR,
   FULL_DUMP_FLAG                    VARCHAR2(1)   :=FND_API.G_MISS_CHAR,
   OBJECT_VERSION_NUMBER             NUMBER        :=FND_API.G_MISS_NUM,
   CREATION_DATE                     DATE          :=FND_API.G_MISS_DATE,
   INSTANCE_ID                       NUMBER        :=FND_API.G_MISS_NUM,
   OBJECT_ID                         NUMBER        :=FND_API.G_MISS_NUM,
   RELATIONSHIP_TYPE_CODE            VARCHAR2(30)  :=FND_API.G_MISS_CHAR,
   RELATIONSHIP_TYPE                 VARCHAR2(80)  :=FND_API.G_MISS_CHAR,
   OLD_SUBJECT_NUMBER                VARCHAR2(30)  :=FND_API.G_MISS_CHAR,
   NEW_SUBJECT_NUMBER                VARCHAR2(30)  :=FND_API.G_MISS_CHAR
);

TYPE  relationship_history_tbl IS TABLE OF relationship_history_rec INDEX BY BINARY_INTEGER;


TYPE system_rec IS RECORD
(
       SYSTEM_ID                       NUMBER        := FND_API.G_MISS_NUM  ,
       CUSTOMER_ID                     NUMBER        := FND_API.G_MISS_NUM  ,
       SYSTEM_TYPE_CODE                VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       SYSTEM_NUMBER                   VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       PARENT_SYSTEM_ID                NUMBER        := FND_API.G_MISS_NUM  ,
       SHIP_TO_CONTACT_ID              NUMBER        := FND_API.G_MISS_NUM  ,
       BILL_TO_CONTACT_ID              NUMBER        := FND_API.G_MISS_NUM  ,
       TECHNICAL_CONTACT_ID            NUMBER        := FND_API.G_MISS_NUM  ,
       SERVICE_ADMIN_CONTACT_ID        NUMBER        := FND_API.G_MISS_NUM  ,
       SHIP_TO_SITE_USE_ID             NUMBER        := FND_API.G_MISS_NUM  ,
       BILL_TO_SITE_USE_ID             NUMBER        := FND_API.G_MISS_NUM  ,
       INSTALL_SITE_USE_ID             NUMBER        := FND_API.G_MISS_NUM  ,
       COTERMINATE_DAY_MONTH           VARCHAR2(6)   := FND_API.G_MISS_CHAR ,
       AUTOCREATED_FROM_SYSTEM_ID      NUMBER        := FND_API.G_MISS_NUM  ,
       CONFIG_SYSTEM_TYPE              VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       START_DATE_ACTIVE               DATE          := FND_API.G_MISS_DATE ,
       END_DATE_ACTIVE                 DATE          := FND_API.G_MISS_DATE ,
       CONTEXT                         VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       ATTRIBUTE1                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE2                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE3                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE4                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE5                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE6                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE7                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE8                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE9                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE10                     VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE11                     VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE12                     VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE13                     VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE14                     VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE15                     VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       OBJECT_VERSION_NUMBER           NUMBER        := FND_API.G_MISS_NUM  ,
       NAME                            VARCHAR2(50)  := FND_API.G_MISS_CHAR ,
       DESCRIPTION                     VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       TECH_CONT_CHANGE_FLAG           VARCHAR2(1)   := FND_API.G_MISS_CHAR ,
       BILL_TO_CONT_CHANGE_FLAG        VARCHAR2(1)   := FND_API.G_MISS_CHAR ,
       SHIP_TO_CONT_CHANGE_FLAG        VARCHAR2(1)   := FND_API.G_MISS_CHAR ,
       SERV_ADMIN_CONT_CHANGE_FLAG     VARCHAR2(1)   := FND_API.G_MISS_CHAR ,
       BILL_TO_SITE_CHANGE_FLAG        VARCHAR2(1)   := FND_API.G_MISS_CHAR ,
       SHIP_TO_SITE_CHANGE_FLAG        VARCHAR2(1)   := FND_API.G_MISS_CHAR ,
       INSTALL_TO_SITE_CHANGE_FLAG     VARCHAR2(1)   := FND_API.G_MISS_CHAR ,
       CASCADE_CUST_TO_INS_FLAG        VARCHAR2(1)   := FND_API.G_MISS_CHAR ,
       OPERATING_UNIT_ID               NUMBER        := FND_API.G_MISS_NUM  ,
       REQUEST_ID                      NUMBER        := FND_API.G_MISS_NUM  ,
       PROGRAM_APPLICATION_ID          NUMBER        := FND_API.G_MISS_NUM  ,
       PROGRAM_ID                      NUMBER        := FND_API.G_MISS_NUM  ,
       PROGRAM_UPDATE_DATE             DATE          :=  FND_API.G_MISS_DATE
        );

TYPE  systems_tbl      IS TABLE OF system_rec
                              INDEX BY BINARY_INTEGER;


TYPE system_history_rec IS RECORD
(
          SYSTEM_HISTORY_ID               NUMBER           :=FND_API.G_MISS_NUM ,
          SYSTEM_ID                       NUMBER           :=FND_API.G_MISS_NUM ,
          TRANSACTION_ID                  NUMBER           :=FND_API.G_MISS_NUM ,
          OLD_CUSTOMER_ID                 NUMBER           :=FND_API.G_MISS_NUM ,
          NEW_CUSTOMER_ID                 NUMBER           :=FND_API.G_MISS_NUM ,
          OLD_SYSTEM_TYPE_CODE            VARCHAR2(30)     :=FND_API.G_MISS_CHAR,
          NEW_SYSTEM_TYPE_CODE            VARCHAR2(30)     :=FND_API.G_MISS_CHAR,
          OLD_SYSTEM_NUMBER               VARCHAR2(30)     :=FND_API.G_MISS_CHAR,
          NEW_SYSTEM_NUMBER               VARCHAR2(30)     :=FND_API.G_MISS_CHAR,
          OLD_PARENT_SYSTEM_ID            NUMBER           :=FND_API.G_MISS_NUM ,
          NEW_PARENT_SYSTEM_ID            NUMBER           :=FND_API.G_MISS_NUM ,
          OLD_SHIP_TO_CONTACT_ID          NUMBER           :=FND_API.G_MISS_NUM ,
          NEW_SHIP_TO_CONTACT_ID          NUMBER           :=FND_API.G_MISS_NUM ,
          OLD_BILL_TO_CONTACT_ID          NUMBER           :=FND_API.G_MISS_NUM ,
          NEW_BILL_TO_CONTACT_ID          NUMBER           :=FND_API.G_MISS_NUM ,
          OLD_TECHNICAL_CONTACT_ID        NUMBER           :=FND_API.G_MISS_NUM ,
          NEW_TECHNICAL_CONTACT_ID        NUMBER           :=FND_API.G_MISS_NUM ,
          OLD_SERVICE_ADMIN_CONTACT_ID    NUMBER           :=FND_API.G_MISS_NUM ,
          NEW_SERVICE_ADMIN_CONTACT_ID    NUMBER           :=FND_API.G_MISS_NUM ,
          OLD_SHIP_TO_SITE_USE_ID         NUMBER           :=FND_API.G_MISS_NUM ,
          NEW_SHIP_TO_SITE_USE_ID         NUMBER           :=FND_API.G_MISS_NUM ,
          OLD_INSTALL_SITE_USE_ID         NUMBER           :=FND_API.G_MISS_NUM ,
          NEW_INSTALL_SITE_USE_ID         NUMBER           :=FND_API.G_MISS_NUM ,
          OLD_BILL_TO_SITE_USE_ID         NUMBER           :=FND_API.G_MISS_NUM ,
          NEW_BILL_TO_SITE_USE_ID         NUMBER           :=FND_API.G_MISS_NUM ,
          OLD_COTERMINATE_DAY_MONTH       VARCHAR2(6)      :=FND_API.G_MISS_CHAR,
          NEW_COTERMINATE_DAY_MONTH       VARCHAR2(6)      :=FND_API.G_MISS_CHAR,
          OLD_START_DATE_ACTIVE           DATE             :=FND_API.G_MISS_DATE,
          NEW_START_DATE_ACTIVE           DATE             :=FND_API.G_MISS_DATE,
          OLD_END_DATE_ACTIVE             DATE             :=FND_API.G_MISS_DATE,
          NEW_END_DATE_ACTIVE             DATE             :=FND_API.G_MISS_DATE,
          OLD_AUTOCREATED_FROM_SYSTEM     NUMBER           :=FND_API.G_MISS_NUM ,
          NEW_AUTOCREATED_FROM_SYSTEM     NUMBER           :=FND_API.G_MISS_NUM ,
          OLD_CONFIG_SYSTEM_TYPE          VARCHAR2(30)     :=FND_API.G_MISS_CHAR,
          NEW_CONFIG_SYSTEM_TYPE          VARCHAR2(30)     :=FND_API.G_MISS_CHAR,
          OLD_CONTEXT                     VARCHAR2(30)     :=FND_API.G_MISS_CHAR,
          NEW_CONTEXT                     VARCHAR2(30)     :=FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE1                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE1                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE2                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE2                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE3                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE3                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE4                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE4                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE5                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE5                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE6                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE6                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE7                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE7                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE8                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE8                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE9                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE9                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE10                 VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE10                 VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE11                 VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE11                 VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE12                 VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE12                 VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE13                 VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE13                 VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE14                 VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE14                 VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE15                 VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE15                 VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          FULL_DUMP_FLAG                  VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          OBJECT_VERSION_NUMBER           NUMBER           :=FND_API.G_MISS_NUM ,
          OLD_NAME                        VARCHAR2(50)     :=FND_API.G_MISS_CHAR,
          NEW_NAME                        VARCHAR2(50)     :=FND_API.G_MISS_CHAR,
          OLD_DESCRIPTION                 VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
          NEW_DESCRIPTION                 VARCHAR2(240)    :=FND_API.G_MISS_CHAR,
	  OLD_OPERATING_UNIT_ID           NUMBER           :=FND_API.G_MISS_NUM,
	  NEW_OPERATING_UNIT_ID           NUMBER           :=FND_API.G_MISS_NUM,
          OLD_SYSTEM_TYPE                 VARCHAR2(30)     := FND_API.G_MISS_CHAR , --check from csi_lookups
          NEW_SYSTEM_TYPE                 VARCHAR2(30)     := FND_API.G_MISS_CHAR , --check from csi_lookups
          OLD_PARENT_NAME                 VARCHAR2(50)     := FND_API.G_MISS_CHAR ,
          NEW_PARENT_NAME                 VARCHAR2(50)     := FND_API.G_MISS_CHAR ,
          OLD_SHIP_TO_ADDRESS1            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          OLD_SHIP_TO_ADDRESS2            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          OLD_SHIP_TO_ADDRESS3            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          OLD_SHIP_TO_ADDRESS4            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          OLD_SHIP_TO_LOCATION            VARCHAR2(40)     := FND_API.G_MISS_CHAR ,
          OLD_SHIP_STATE                  VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          OLD_SHIP_POSTAL_CODE            VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          OLD_SHIP_COUNTRY                VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          OLD_SHIP_TO_CUSTOMER            VARCHAR2(360)    := FND_API.G_MISS_CHAR ,
          OLD_SHIP_TO_CUSTOMER_NUMBER     VARCHAR2(30)     := FND_API.G_MISS_CHAR ,
          NEW_SHIP_TO_ADDRESS1            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          NEW_SHIP_TO_ADDRESS2            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          NEW_SHIP_TO_ADDRESS3            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          NEW_SHIP_TO_ADDRESS4            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          NEW_SHIP_TO_LOCATION            VARCHAR2(40)     := FND_API.G_MISS_CHAR ,
          NEW_SHIP_STATE                  VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          NEW_SHIP_POSTAL_CODE            VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          NEW_SHIP_COUNTRY                VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          NEW_SHIP_TO_CUSTOMER            VARCHAR2(360)    := FND_API.G_MISS_CHAR ,
          NEW_SHIP_TO_CUSTOMER_NUMBER     VARCHAR2(30)     := FND_API.G_MISS_CHAR ,
          OLD_INSTALL_ADDRESS1            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          OLD_INSTALL_ADDRESS2            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          OLD_INSTALL_ADDRESS3            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          OLD_INSTALL_ADDRESS4            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          OLD_INSTALL_LOCATION            VARCHAR2(40)     := FND_API.G_MISS_CHAR ,
          OLD_INSTALL_STATE               VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          OLD_INSTALL_POSTAL_CODE         VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          OLD_INSTALL_COUNTRY             VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          OLD_INSTALL_CUSTOMER_NUMBER     VARCHAR2(30)     := FND_API.G_MISS_CHAR ,
          OLD_INSTALL_CUSTOMER            VARCHAR2(360)    := FND_API.G_MISS_CHAR ,
          NEW_INSTALL_ADDRESS1            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          NEW_INSTALL_ADDRESS2            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          NEW_INSTALL_ADDRESS3            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          NEW_INSTALL_ADDRESS4            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          NEW_INSTALL_LOCATION            VARCHAR2(40)     := FND_API.G_MISS_CHAR ,
          NEW_INSTALL_STATE               VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          NEW_INSTALL_POSTAL_CODE         VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          NEW_INSTALL_COUNTRY             VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          NEW_INSTALL_CUSTOMER_NUMBER     VARCHAR2(30)     := FND_API.G_MISS_CHAR ,
          NEW_INSTALL_CUSTOMER            VARCHAR2(360)    := FND_API.G_MISS_CHAR ,
          OLD_BILL_TO_ADDRESS1            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          OLD_BILL_TO_ADDRESS2            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          OLD_BILL_TO_ADDRESS3            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          OLD_BILL_TO_ADDRESS4            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          OLD_BILL_TO_LOCATION            VARCHAR2(40)     := FND_API.G_MISS_CHAR ,
          OLD_BILL_STATE                  VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          OLD_BILL_POSTAL_CODE            VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          OLD_BILL_COUNTRY                VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          OLD_BILL_TO_CUSTOMER_NUMBER     VARCHAR2(30)     := FND_API.G_MISS_CHAR ,
          OLD_BILL_TO_CUSTOMER            VARCHAR2(360)    := FND_API.G_MISS_CHAR ,
          NEW_BILL_TO_ADDRESS1            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          NEW_BILL_TO_ADDRESS2            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          NEW_BILL_TO_ADDRESS3            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          NEW_BILL_TO_ADDRESS4            VARCHAR2(240)    := FND_API.G_MISS_CHAR ,
          NEW_BILL_TO_LOCATION            VARCHAR2(40)     := FND_API.G_MISS_CHAR ,
          NEW_BILL_STATE                  VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          NEW_BILL_POSTAL_CODE            VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          NEW_BILL_COUNTRY                VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          NEW_BILL_TO_CUSTOMER_NUMBER     VARCHAR2(30)     := FND_API.G_MISS_CHAR ,
          NEW_BILL_TO_CUSTOMER            VARCHAR2(360)    := FND_API.G_MISS_CHAR ,
          OLD_SHIP_TO_CONTACT_NUMBER      VARCHAR2(30)     := FND_API.G_MISS_CHAR ,
          OLD_SHIP_TO_CONTACT             VARCHAR2(360)    := FND_API.G_MISS_CHAR ,
          NEW_SHIP_TO_CONTACT_NUMBER      VARCHAR2(30)     := FND_API.G_MISS_CHAR ,
          NEW_SHIP_TO_CONTACT             VARCHAR2(360)    := FND_API.G_MISS_CHAR ,
          OLD_BILL_TO_CONTACT_NUMBER      VARCHAR2(30)     := FND_API.G_MISS_CHAR ,
          OLD_BILL_TO_CONTACT             VARCHAR2(360)    := FND_API.G_MISS_CHAR ,
          NEW_BILL_TO_CONTACT_NUMBER      VARCHAR2(30)     := FND_API.G_MISS_CHAR ,
          NEW_BILL_TO_CONTACT             VARCHAR2(360)    := FND_API.G_MISS_CHAR ,
          OLD_TECHNICAL_CONTACT_NUMBER    VARCHAR2(30)     := FND_API.G_MISS_CHAR ,
          OLD_TECHNICAL_CONTACT           VARCHAR2(360)    := FND_API.G_MISS_CHAR ,
          NEW_TECHNICAL_CONTACT_NUMBER    VARCHAR2(30)     := FND_API.G_MISS_CHAR ,
          NEW_TECHNICAL_CONTACT           VARCHAR2(360)    := FND_API.G_MISS_CHAR ,
          OLD_SERV_ADMIN_CONTACT_NUMBER   VARCHAR2(30)     := FND_API.G_MISS_CHAR ,
          OLD_SERV_ADMIN_CONTACT          VARCHAR2(360)    := FND_API.G_MISS_CHAR ,
          NEW_SERV_ADMIN_CONTACT_NUMBER   VARCHAR2(30)     := FND_API.G_MISS_CHAR ,
          NEW_SERV_ADMIN_CONTACT          VARCHAR2(360)    := FND_API.G_MISS_CHAR ,
          OLD_OPERATING_UNIT_NAME         VARCHAR2(60)     := FND_API.G_MISS_CHAR ,
          NEW_OPERATING_UNIT_NAME         VARCHAR2(60)     := FND_API.G_MISS_CHAR
         );



TYPE  systems_history_tbl      IS TABLE OF system_history_rec
                                    INDEX BY BINARY_INTEGER;

TYPE system_query_rec IS RECORD
 (
     system_id                        NUMBER        :=  FND_API.G_MISS_NUM
    ,system_type_code                 VARCHAR2(30)  :=  FND_API.G_MISS_CHAR
    ,system_number                    VARCHAR2(30)  :=  FND_API.G_MISS_CHAR
  );

--      Name           : ext_attrib_rec
--      Description    : ext_attrib_rec record to hold information about extended attributes

TYPE ext_attrib_rec IS RECORD
    (
       attribute_id                    NUMBER        := fnd_api.g_miss_num  ,
       attribute_level                 VARCHAR2(15)  := fnd_api.g_miss_char ,
       master_organization_id          NUMBER        := fnd_api.g_miss_num  ,
       inventory_item_id               NUMBER        := fnd_api.g_miss_num  ,
       item_category_id                NUMBER        := fnd_api.g_miss_num  ,
       instance_id                     NUMBER        := fnd_api.g_miss_num  ,
       attribute_code                  VARCHAR2(30)  := fnd_api.g_miss_char ,
       attribute_name                  VARCHAR2(50)  := fnd_api.g_miss_char ,
       attribute_category              VARCHAR2(30)  := fnd_api.g_miss_char ,
       description                     VARCHAR2(240) := fnd_api.g_miss_char ,
       active_start_date               DATE          := fnd_api.g_miss_date ,
       active_end_date                 DATE          := fnd_api.g_miss_date ,
       context                         VARCHAR2(30)  := fnd_api.g_miss_char ,
       attribute1                      VARCHAR2(150) := fnd_api.g_miss_char ,
       attribute2                      VARCHAR2(150) := fnd_api.g_miss_char ,
       attribute3                      VARCHAR2(150) := fnd_api.g_miss_char ,
       attribute4                      VARCHAR2(150) := fnd_api.g_miss_char ,
       attribute5                      VARCHAR2(150) := fnd_api.g_miss_char ,
       attribute6                      VARCHAR2(150) := fnd_api.g_miss_char ,
       attribute7                      VARCHAR2(150) := fnd_api.g_miss_char ,
       attribute8                      VARCHAR2(150) := fnd_api.g_miss_char ,
       attribute9                      VARCHAR2(150) := fnd_api.g_miss_char ,
       attribute10                     VARCHAR2(150) := fnd_api.g_miss_char ,
       attribute11                     VARCHAR2(150) := fnd_api.g_miss_char ,
       attribute12                     VARCHAR2(150) := fnd_api.g_miss_char ,
       attribute13                     VARCHAR2(150) := fnd_api.g_miss_char ,
       attribute14                     VARCHAR2(150) := fnd_api.g_miss_char ,
       attribute15                     VARCHAR2(150) := fnd_api.g_miss_char ,
       object_version_number           NUMBER        := fnd_api.g_miss_num
    );

TYPE extend_attrib_tbl  IS TABLE OF ext_attrib_rec
                        INDEX BY BINARY_INTEGER;

--      Name           : extend_attrib_values_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold the values of an item instances extended attributes.


TYPE extend_attrib_values_rec IS RECORD
 (
     attribute_value_id      NUMBER         :=  FND_API.G_MISS_NUM,
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
     object_version_number   NUMBER         :=  FND_API.G_MISS_NUM,
     parent_tbl_index        NUMBER         :=  FND_API.G_MISS_NUM
);


TYPE extend_attrib_values_tbl IS table of extend_attrib_values_rec INDEX BY
BINARY_INTEGER;



--      Name           : extend_attrib_query_rec
--      Package name   : csi_datastructures_pub
--      Type           :   type definition, public
--      Description    :  record to hold the information for querying the values of an item instances extended
--                        attributes.


TYPE extend_attrib_query_rec IS RECORD
 (
     attribute_value_id  NUMBER         :=  FND_API.G_MISS_NUM,
     instance_id         NUMBER         :=  FND_API.G_MISS_NUM,
     attribute_id        NUMBER         :=  FND_API.G_MISS_NUM
 );



--      Name           : pricing_attributes_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold the pricing attributes of an item instance.


TYPE pricing_attribs_rec IS RECORD
 (
     pricing_attribute_id             NUMBER         :=  FND_API.G_MISS_NUM,
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
     pricing_attribute20              VARCHAR2(240)  :=  FND_API.G_MISS_CHAR, --modified for bug #5980271
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
     object_version_number            NUMBER         :=  FND_API.G_MISS_NUM,
     parent_tbl_index                 NUMBER         :=  FND_API.G_MISS_NUM
);

TYPE pricing_attribs_tbl IS TABLE OF pricing_attribs_rec INDEX BY BINARY_INTEGER;


--      Name           : pricing_attributes_query_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold the query columns for pricing attributes of an item instance.

TYPE pricing_attribs_query_rec IS RECORD
 (
     pricing_attribute_id             NUMBER         :=  FND_API.G_MISS_NUM,
     instance_id                      NUMBER         :=  FND_API.G_MISS_NUM
 );


--      Name           : organization_unit_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold information about an instance-org association.


TYPE organization_units_rec IS RECORD
 (
     instance_ou_id                   NUMBER         :=  FND_API.G_MISS_NUM,
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
     object_version_number            NUMBER         :=  FND_API.G_MISS_NUM,
     parent_tbl_index                 NUMBER         :=  FND_API.G_MISS_NUM
);

TYPE organization_units_tbl IS TABLE OF organization_units_rec INDEX BY BINARY_INTEGER;




--      Name           : organization_unit_query_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold information to query an instance-org association.


TYPE organization_unit_query_rec IS RECORD
 (
     instance_ou_id                   NUMBER         :=  FND_API.G_MISS_NUM,
     instance_id                      NUMBER         :=  FND_API.G_MISS_NUM,
     operating_unit_id                NUMBER         :=  FND_API.G_MISS_NUM,
     relationship_type_code           VARCHAR2(30)   :=  FND_API.G_MISS_CHAR
 );


--      Name           : instance_asset_rec
--      Package name   : csi_datastructures_pub
--      Type           :   type definition, public
--      Description    :  record to hold information about instance-asset association.


TYPE instance_asset_rec IS RECORD
 (
     instance_asset_id          NUMBER          := FND_API.G_MISS_NUM,
     instance_id                NUMBER          := FND_API.G_MISS_NUM,
     fa_asset_id                NUMBER          := FND_API.G_MISS_NUM,
     fa_book_type_code          VARCHAR2(15)    := FND_API.G_MISS_CHAR,
     fa_location_id             NUMBER          := FND_API.G_MISS_NUM,
     asset_quantity             NUMBER          := FND_API.G_MISS_NUM,
     update_status              VARCHAR2(30)    := FND_API.G_MISS_CHAR,
     active_start_date          DATE            := FND_API.G_MISS_DATE,
     active_end_date            DATE            := FND_API.G_MISS_DATE,
     object_version_number      NUMBER          := FND_API.G_MISS_NUM,
     check_for_instance_expiry  VARCHAR2(1)     := FND_API.G_TRUE,
     parent_tbl_index           NUMBER          := FND_API.G_MISS_NUM,
     fa_sync_flag               VARCHAR2(1)     := FND_API.G_MISS_CHAR,
     fa_mass_addition_id        NUMBER          := FND_API.G_MISS_NUM,
     creation_complete_flag     VARCHAR2(1)     := FND_API.G_MISS_CHAR,
     fa_sync_validation_reqd    VARCHAR2(1)     := FND_API.G_FALSE
);

TYPE instance_asset_tbl IS TABLE OF instance_asset_rec INDEX BY BINARY_INTEGER;



--      Name           : instance_asset_query_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold query columns for an instance-asset association.


TYPE instance_asset_query_rec IS RECORD
 (
     instance_asset_id          NUMBER          :=  FND_API.G_MISS_NUM,
     instance_id                NUMBER          :=  FND_API.G_MISS_NUM,
     fa_asset_id                NUMBER          :=  FND_API.G_MISS_NUM,
     fa_book_type_code          VARCHAR2(15)    :=  FND_API.G_MISS_CHAR,
     fa_location_id             NUMBER          :=  FND_API.G_MISS_NUM,
     update_status              VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
     fa_mass_addition_id        NUMBER          :=  FND_API.G_MISS_NUM
);

--      Name           : party_account_header_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold information about a party-account relationship.

TYPE party_account_header_rec IS RECORD
 (
     ip_account_id                    NUMBER         :=  FND_API.G_MISS_NUM,
     instance_party_id                NUMBER         :=  FND_API.G_MISS_NUM,
     party_account_id                 NUMBER         :=  FND_API.G_MISS_NUM,
     party_account_number             VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     party_account_name               VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
     relationship_type_code           VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     bill_to_address                  NUMBER         :=  FND_API.G_MISS_NUM,
     bill_to_location                 VARCHAR2(40)   :=  FND_API.G_MISS_CHAR,
     ship_to_address                  NUMBER         :=  FND_API.G_MISS_NUM,
     ship_to_location                 VARCHAR2(40)   :=  FND_API.G_MISS_CHAR,
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
     object_version_number            NUMBER         :=  FND_API.G_MISS_NUM,
     bill_to_address1                 VARCHAR2(240)  :=  FND_API.G_MISS_CHAR, -- Added for bug 2670371
     bill_to_address2                 VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
     bill_to_address3                 VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
     bill_to_address4                 VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
     bill_to_city                     VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
     bill_to_state                    VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
     bill_to_postal_code              VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
     bill_to_country                  VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
     ship_to_address1                 VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
     ship_to_address2                 VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
     ship_to_address3                 VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
     ship_to_address4                 VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
     ship_to_city                     VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
     ship_to_state                    VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
     ship_to_postal_code              VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
     ship_to_country                  VARCHAR2(60)   :=  FND_API.G_MISS_CHAR
);

TYPE party_account_header_tbl IS TABLE OF party_account_header_rec INDEX BY
BINARY_INTEGER;

--      Name           : org_unit_header_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold information about an instance-org association.


TYPE org_units_header_rec IS RECORD
 (
     instance_ou_id                   NUMBER         :=  FND_API.G_MISS_NUM,
     instance_id                      NUMBER         :=  FND_API.G_MISS_NUM,
     operating_unit_id                NUMBER         :=  FND_API.G_MISS_NUM,
     operating_unit_name              VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
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
     object_version_number            NUMBER         :=  FND_API.G_MISS_NUM,
     relationship_type_name           VARCHAR2(80)   :=  FND_API.G_MISS_CHAR
);

TYPE org_units_header_tbl IS TABLE OF org_units_header_rec INDEX BY BINARY_INTEGER;


--      Name           : instance_asset_header_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold query columns for an instance-asset association.

TYPE instance_asset_header_rec IS RECORD
 (
     instance_asset_id          NUMBER          :=  FND_API.G_MISS_NUM,
     instance_id                NUMBER          :=  FND_API.G_MISS_NUM,
     fa_asset_id                NUMBER          :=  FND_API.G_MISS_NUM,
     fa_book_type_code          VARCHAR2(15)    :=  FND_API.G_MISS_CHAR,
     fa_location_id             NUMBER          :=  FND_API.G_MISS_NUM,
     asset_quantity             NUMBER          :=  FND_API.G_MISS_NUM,
     update_status              VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
     active_start_date          DATE            :=  FND_API.G_MISS_DATE,
     active_end_date            DATE            :=  FND_API.G_MISS_DATE,
     object_version_number      NUMBER          :=  FND_API.G_MISS_NUM,
     asset_number               VARCHAR2(15)    :=  FND_API.G_MISS_CHAR,
     serial_number              VARCHAR2(35)    :=  FND_API.G_MISS_CHAR,
     tag_number                 VARCHAR2(15)    :=  FND_API.G_MISS_CHAR,
     category                   VARCHAR2(60)    :=  FND_API.G_MISS_CHAR,
     fa_location_segment1       VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
     fa_location_segment2       VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
     fa_location_segment3       VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
     fa_location_segment4       VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
     fa_location_segment5       VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
     fa_location_segment6       VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
     fa_location_segment7       VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
     date_placed_in_service     DATE            :=  FND_API.G_MISS_DATE,
     description                VARCHAR2(80)    :=  FND_API.G_MISS_CHAR,
     employee_name              VARCHAR2(240)   :=  FND_API.G_MISS_CHAR,
     expense_account_number     VARCHAR2(25)    :=  FND_API.G_MISS_CHAR,
     fa_mass_addition_id        NUMBER          :=  FND_API.G_MISS_NUM,
     creation_complete_flag     VARCHAR2(1)     :=  FND_API.G_MISS_CHAR
 );

TYPE instance_asset_header_tbl IS TABLE of instance_asset_header_rec INDEX BY BINARY_INTEGER;


/*--------------------------------------------------*/
/* Record  instance_history_rec                     */
/* is used in retreiving history for a              */
/* given transaction                                */
/*--------------------------------------------------*/

TYPE instance_history_rec IS RECORD
  (
       instance_id                         NUMBER
      ,old_instance_number                 VARCHAR2(30)
      ,new_instance_number                 VARCHAR2(30)
      ,old_external_reference              VARCHAR2(30)
      ,new_external_reference              VARCHAR2(30)
      ,old_inventory_item_id               NUMBER
      ,new_inventory_item_id               NUMBER
      ,old_inventory_revision              VARCHAR2(3)
      ,new_inventory_revision              VARCHAR2(3)
      ,old_inv_master_org_id               NUMBER
      ,new_inv_master_org_id               NUMBER
      ,old_serial_number                   VARCHAR2(30)
      ,new_serial_number                   VARCHAR2(30)
      ,old_mfg_serial_number_flag          VARCHAR2(1)
      ,new_mfg_serial_number_flag          VARCHAR2(1)
      ,old_lot_number                      VARCHAR2(80)
      ,new_lot_number                      VARCHAR2(80)
      ,old_quantity                        NUMBER
      ,new_quantity                        NUMBER
      ,old_unit_of_measure_name            VARCHAR2(30)
      ,new_unit_of_measure_name            VARCHAR2(30)
      ,old_unit_of_measure                 VARCHAR2(3)
      ,new_unit_of_measure                 VARCHAR2(3)
      ,old_accounting_class                VARCHAR2(30)
      ,new_accounting_class                VARCHAR2(30)
      ,old_accounting_class_code           VARCHAR2(10)
      ,new_accounting_class_code           VARCHAR2(10)
      ,old_instance_condition              VARCHAR2(80)
      ,new_instance_condition              VARCHAR2(80)
      ,old_instance_condition_id           NUMBER
      ,new_instance_condition_id           NUMBER
      ,old_instance_status                 VARCHAR2(50)
      ,new_instance_status                 VARCHAR2(50)
      ,old_instance_status_id              NUMBER
      ,new_instance_status_id              NUMBER
      ,old_customer_view_flag              VARCHAR2(1)
      ,new_customer_view_flag              VARCHAR2(1)
      ,old_merchant_view_flag              VARCHAR2(1)
      ,new_merchant_view_flag              VARCHAR2(1)
      ,old_sellable_flag                   VARCHAR2(1)
      ,new_sellable_flag                   VARCHAR2(1)
      ,old_system_id                       NUMBER
      ,new_system_id                       NUMBER
      ,old_system_name                     VARCHAR2(30)
      ,new_system_name                     VARCHAR2(30)
      ,old_instance_type_code              VARCHAR2(30)
      ,new_instance_type_code              VARCHAR2(30)
      ,old_instance_type_name              VARCHAR2(240)
      ,new_instance_type_name              VARCHAR2(240)
      ,old_active_start_date               DATE
      ,new_active_start_date               DATE
      ,old_active_end_date                 DATE
      ,new_active_end_date                 DATE
      ,old_location_type_code              VARCHAR2(30)
      ,new_location_type_code              VARCHAR2(30)
      ,old_location_id                     NUMBER
      ,new_location_id                     NUMBER
      ,old_inv_organization_id             NUMBER
      ,new_inv_organization_id             NUMBER
      ,old_inv_organization_name           VARCHAR2(60)
      ,new_inv_organization_name           VARCHAR2(60)
      ,old_inv_subinventory_name           VARCHAR2(10)
      ,new_inv_subinventory_name           VARCHAR2(10)
      ,old_inv_locator_id                  NUMBER
      ,new_inv_locator_id                  NUMBER
      ,old_pa_project_id                   NUMBER
      ,new_pa_project_id                   NUMBER
      ,old_pa_project_task_id              NUMBER
      ,new_pa_project_task_id              NUMBER
      ,old_pa_project_name                 VARCHAR2(30)
      ,new_pa_project_name                 VARCHAR2(30)
      ,old_pa_project_number               VARCHAR2(25)
      ,new_pa_project_number               VARCHAR2(25)
      ,old_pa_task_name                    VARCHAR2(20)
      ,new_pa_task_name                    VARCHAR2(20)
      ,old_pa_task_number                  VARCHAR2(25)
      ,new_pa_task_number                  VARCHAR2(25)
      ,old_in_transit_order_line_id        NUMBER
      ,new_in_transit_order_line_id        NUMBER
      ,old_in_transit_order_line_num       NUMBER
      ,new_in_transit_order_line_num       NUMBER
      ,old_in_transit_order_number         NUMBER
      ,new_in_transit_order_number         NUMBER
      ,old_wip_job_id                      NUMBER
      ,new_wip_job_id                      NUMBER
      ,old_wip_entity_name                 VARCHAR2(240)
      ,new_wip_entity_name                 VARCHAR2(240)
      ,old_po_order_line_id                NUMBER
      ,new_po_order_line_id                NUMBER
      ,old_last_oe_order_line_id           NUMBER
      ,new_last_oe_order_line_id           NUMBER
      ,old_last_oe_rma_line_id             NUMBER
      ,new_last_oe_rma_line_id             NUMBER
      ,old_last_po_po_line_id              NUMBER
      ,new_last_po_po_line_id              NUMBER
      ,old_last_oe_po_number               VARCHAR2(50)
      ,new_last_oe_po_number               VARCHAR2(50)
      ,old_last_wip_job_id                 NUMBER
      ,new_last_wip_job_id                 NUMBER
      ,old_last_pa_project_id              NUMBER
      ,new_last_pa_project_id              NUMBER
      ,old_last_pa_task_id                 NUMBER
      ,new_last_pa_task_id                 NUMBER
      ,old_last_oe_agreement_id            NUMBER
      ,new_last_oe_agreement_id            NUMBER
      ,old_install_date                    DATE
      ,new_install_date                    DATE
      ,old_manually_created_flag           VARCHAR2(1)
      ,new_manually_created_flag           VARCHAR2(1)
      ,old_return_by_date                  DATE
      ,new_return_by_date                  DATE
      ,old_actual_return_date              DATE
      ,new_actual_return_date              DATE
      ,old_creation_complete_flag          VARCHAR2(1)
      ,new_creation_complete_flag          VARCHAR2(1)
      ,old_completeness_flag               VARCHAR2(1)
      ,new_completeness_flag               VARCHAR2(1)
      ,old_context                         VARCHAR2(30)
      ,new_context                         VARCHAR2(30)
      ,old_attribute1                      VARCHAR2(240)
      ,new_attribute1                      VARCHAR2(240)
      ,old_attribute2                      VARCHAR2(240)
      ,new_attribute2                      VARCHAR2(240)
      ,old_attribute3                      VARCHAR2(240)
      ,new_attribute3                      VARCHAR2(240)
      ,old_attribute4                      VARCHAR2(240)
      ,new_attribute4                      VARCHAR2(240)
      ,old_attribute5                      VARCHAR2(240)
      ,new_attribute5                      VARCHAR2(240)
      ,old_attribute6                      VARCHAR2(240)
      ,new_attribute6                      VARCHAR2(240)
      ,old_attribute7                      VARCHAR2(240)
      ,new_attribute7                      VARCHAR2(240)
      ,old_attribute8                      VARCHAR2(240)
      ,new_attribute8                      VARCHAR2(240)
      ,old_attribute9                      VARCHAR2(240)
      ,new_attribute9                      VARCHAR2(240)
      ,old_attribute10                     VARCHAR2(240)
      ,new_attribute10                     VARCHAR2(240)
      ,old_attribute11                     VARCHAR2(240)
      ,new_attribute11                     VARCHAR2(240)
      ,old_attribute12                     VARCHAR2(240)
      ,new_attribute12                     VARCHAR2(240)
      ,old_attribute13                     VARCHAR2(240)
      ,new_attribute13                     VARCHAR2(240)
      ,old_attribute14                     VARCHAR2(240)
      ,new_attribute14                     VARCHAR2(240)
      ,old_attribute15                     VARCHAR2(240)
      ,new_attribute15                     VARCHAR2(240)
      ,old_last_txn_line_detail_id         NUMBER
      ,new_last_txn_line_detail_id         NUMBER
      ,old_install_location_type_code      VARCHAR2(30)
      ,new_install_location_type_code      VARCHAR2(30)
      ,old_install_location_id             NUMBER
      ,new_install_location_id             NUMBER
      ,old_instance_usage_code             VARCHAR2(30)
      ,new_instance_usage_code             VARCHAR2(30)
      ,old_current_loc_address1            VARCHAR2(240)
      ,new_current_loc_address1            VARCHAR2(240)
      ,old_current_loc_address2            VARCHAR2(240)
      ,new_current_loc_address2            VARCHAR2(240)
      ,old_current_loc_address3            VARCHAR2(240)
      ,new_current_loc_address3            VARCHAR2(240)
      ,old_current_loc_address4            VARCHAR2(240)
      ,new_current_loc_address4            VARCHAR2(240)
      ,old_current_loc_city                VARCHAR2(60)
      ,new_current_loc_city                VARCHAR2(60)
      ,old_current_loc_postal_code         VARCHAR2(60)
      ,new_current_loc_postal_code         VARCHAR2(60)
      ,old_current_loc_country             VARCHAR2(60)
      ,new_current_loc_country             VARCHAR2(60)
      ,old_sales_order_number              NUMBER
      ,new_sales_order_number              NUMBER
      ,old_sales_order_line_number         NUMBER
      ,new_sales_order_line_number         NUMBER
      ,old_sales_order_date                DATE
      ,new_sales_order_date                DATE
      ,old_purchase_order_number           VARCHAR2(50)
      ,new_purchase_order_number           VARCHAR2(50)
      ,old_instance_usage_name             VARCHAR2(80)
      ,new_instance_usage_name             VARCHAR2(80)
      ,old_current_loc_state               VARCHAR2(60)
      ,new_current_loc_state               VARCHAR2(60)
      ,old_install_loc_address1            VARCHAR2(240)
      ,new_install_loc_address1            VARCHAR2(240)
      ,old_install_loc_address2            VARCHAR2(240)
      ,new_install_loc_address2            VARCHAR2(240)
      ,old_install_loc_address3            VARCHAR2(240)
      ,new_install_loc_address3            VARCHAR2(240)
      ,old_install_loc_address4            VARCHAR2(240)
      ,new_install_loc_address4            VARCHAR2(240)
      ,old_install_loc_city                VARCHAR2(60)
      ,new_install_loc_city                VARCHAR2(60)
      ,old_install_loc_state               VARCHAR2(60)
      ,new_install_loc_state               VARCHAR2(60)
      ,old_install_loc_postal_code         VARCHAR2(60)
      ,new_install_loc_postal_code         VARCHAR2(60)
      ,old_install_loc_country             VARCHAR2(60)
      ,new_install_loc_country             VARCHAR2(60)
      ,old_config_inst_rev_num             NUMBER
      ,new_config_inst_rev_num             NUMBER
      ,old_config_valid_status             VARCHAR2(30)
      ,new_config_valid_status             VARCHAR2(30)
      ,old_instance_description            VARCHAR2(240)
      ,new_instance_description            VARCHAR2(240)
      ,instance_history_id                 NUMBER
      ,transaction_id                      NUMBER
      ,old_last_vld_organization_id        NUMBER
      ,new_last_vld_organization_id        NUMBER
      ,old_oe_agreement_name               VARCHAR2(240)
      ,new_oe_agreement_name               VARCHAR2(240)
      ,old_inv_locator_name                VARCHAR2(240)
      ,new_inv_locator_name                VARCHAR2(240)
      ,old_current_location_number         VARCHAR2(30)
      ,new_current_location_number         VARCHAR2(30)
      ,old_install_location_number         VARCHAR2(30)
      ,new_install_location_number         VARCHAR2(30)
      -- Start addition of columns for EAM integration
      ,old_network_asset_flag              VARCHAR2(1)
      ,new_network_asset_flag              VARCHAR2(1)
      ,old_maintainable_flag               VARCHAR2(1)
      ,new_maintainable_flag               VARCHAR2(1)
      ,old_pn_location_id                  NUMBER
      ,new_pn_location_id                  NUMBER
      ,old_asset_criticality_code          VARCHAR2(30)
      ,new_asset_criticality_code          VARCHAR2(30)
       --start bug  4754569--
      ,old_criticality                     VARCHAR2(80)
      ,new_criticality                     VARCHAR2(80)
       --end bug  4754569--
      ,old_category_id                     NUMBER
      ,new_category_id                     NUMBER
       --start bug  4754569--
      ,old_category_name                   VARCHAR2(163)
      ,new_category_name                   VARCHAR2(163)
       --end bug  4754569--
      ,old_maintainable			   VARCHAR2(5) --for bug 5211068
      ,new_maintainable            	   VARCHAR2(5)
      ,old_equipment_gen_object_id         NUMBER
      ,new_equipment_gen_object_id         NUMBER
      ,old_instantiation_flag              VARCHAR2(1)
      ,new_instantiation_flag              VARCHAR2(1)
      ,old_linear_location_id              NUMBER
      ,new_linear_location_id              NUMBER
      ,old_operational_log_flag            VARCHAR2(1)
      ,new_operational_log_flag            VARCHAR2(1)
      ,old_checkin_status                  NUMBER
      ,new_checkin_status                  NUMBER
      ,old_supplier_warranty_exp_date      DATE
      ,new_supplier_warranty_exp_date      DATE
      ,old_attribute16                     VARCHAR2(240)
      ,new_attribute16                     VARCHAR2(240)
      ,old_attribute17                     VARCHAR2(240)
      ,new_attribute17                     VARCHAR2(240)
      ,old_attribute18                     VARCHAR2(240)
      ,new_attribute18                     VARCHAR2(240)
      ,old_attribute19                     VARCHAR2(240)
      ,new_attribute19                     VARCHAR2(240)
      ,old_attribute20                     VARCHAR2(240)
      ,new_attribute20                     VARCHAR2(240)
      ,old_attribute21                     VARCHAR2(240)
      ,new_attribute21                     VARCHAR2(240)
      ,old_attribute22                     VARCHAR2(240)
      ,new_attribute22                     VARCHAR2(240)
      ,old_attribute23                     VARCHAR2(240)
      ,new_attribute23                     VARCHAR2(240)
      ,old_attribute24                     VARCHAR2(240)
      ,new_attribute24                     VARCHAR2(240)
      ,old_attribute25                     VARCHAR2(240)
      ,new_attribute25                     VARCHAR2(240)
      ,old_attribute26                     VARCHAR2(240)
      ,new_attribute26                     VARCHAR2(240)
      ,old_attribute27                     VARCHAR2(240)
      ,new_attribute27                     VARCHAR2(240)
      ,old_attribute28                     VARCHAR2(240)
      ,new_attribute28                     VARCHAR2(240)
      ,old_attribute29                     VARCHAR2(240)
      ,new_attribute29                     VARCHAR2(240)
      ,old_attribute30                     VARCHAR2(240)
      ,new_attribute30                     VARCHAR2(240)
      -- End addition of columns for EAM integration
   -- Addition of columns for FA Integration
      ,old_payables_currency_code          VARCHAR2(15)
      ,new_payables_currency_code          VARCHAR2(15)
      ,old_purchase_unit_price             NUMBER
      ,new_purchase_unit_price             NUMBER
      ,old_purchase_currency_code          VARCHAR2(15)
      ,new_purchase_currency_code          VARCHAR2(15)
      ,old_payables_unit_price             NUMBER
      ,new_payables_unit_price             NUMBER
      ,old_sales_unit_price                NUMBER
      ,new_sales_unit_price                NUMBER
      ,old_sales_currency_code             VARCHAR2(15)
      ,new_sales_currency_code             VARCHAR2(15)
      ,old_operational_status_code         VARCHAR2(30)
      ,new_operational_status_code         VARCHAR2(30)
    -- End addition of columns for FA Integration
      ,full_dump_flag                      VARCHAR2(30) --Added for bug 5615169
      ,old_inventory_item_name             VARCHAR2(240)  --Bug 7292862
      ,new_inventory_item_name             VARCHAR2(240)  --Bug 7292862
      -- Begin Add Code for Siebel Genesis Project
      ,old_source_code                     VARCHAR2(10)
      ,new_source_code                     VARCHAR2(10)
      -- End Add Code for Siebel Genesis Project
  );

TYPE instance_history_tbl IS TABLE OF instance_history_rec INDEX BY BINARY_INTEGER;


-- ins_asset_history_rec record used to retreive asset history
 -- for a particular transaction.
TYPE ins_asset_history_rec IS RECORD
 (
      instance_asset_id                    NUMBER
     ,old_instance_id                      NUMBER
     ,new_instance_id                      NUMBER
     ,old_fa_asset_id                      NUMBER
     ,new_fa_asset_id                      NUMBER
     ,old_fa_book_type_code                VARCHAR2(15)
     ,new_fa_book_type_code                VARCHAR2(15)
     ,old_fa_location_id                   NUMBER
     ,new_fa_location_id                   NUMBER
     ,old_asset_quantity                   NUMBER
     ,new_asset_quantity                   NUMBER
     ,old_update_status                    VARCHAR2(30)
     ,new_update_status                    VARCHAR2(30)
     ,old_active_start_date                DATE
     ,new_active_start_date                DATE
     ,old_active_end_date                  DATE
     ,new_active_end_date                  DATE
     ,old_asset_number                     VARCHAR2(15)
     ,new_asset_number                     VARCHAR2(15)
     ,old_serial_number                    VARCHAR2(35)
     ,new_serial_number                    VARCHAR2(35)
     ,old_tag_number                       VARCHAR2(15)
     ,new_tag_number                       VARCHAR2(15)
     ,old_category                         VARCHAR2(60)
     ,new_category                         VARCHAR2(60)
     ,old_fa_location_segment1             VARCHAR2(30)
     ,new_fa_location_segment1             VARCHAR2(30)
     ,old_fa_location_segment2             VARCHAR2(30)
     ,new_fa_location_segment2             VARCHAR2(30)
     ,old_fa_location_segment3             VARCHAR2(30)
     ,new_fa_location_segment3             VARCHAR2(30)
     ,old_fa_location_segment4             VARCHAR2(30)
     ,new_fa_location_segment4             VARCHAR2(30)
     ,old_fa_location_segment5             VARCHAR2(30)
     ,new_fa_location_segment5             VARCHAR2(30)
     ,old_fa_location_segment6             VARCHAR2(30)
     ,new_fa_location_segment6             VARCHAR2(30)
     ,old_fa_location_segment7             VARCHAR2(30)
     ,new_fa_location_segment7             VARCHAR2(30)
     ,old_date_placed_in_service           DATE
     ,new_date_placed_in_service           DATE
     ,old_description                      VARCHAR2(80)
     ,new_description                      VARCHAR2(80)
     ,old_employee_name                    VARCHAR2(240)
     ,new_employee_name                    VARCHAR2(240)
     ,old_expense_account_number           VARCHAR2(25)
     ,new_expense_account_number           VARCHAR2(25)
     ,instance_id                          NUMBER
     ,instance_asset_history_id            NUMBER
     ,transaction_id                       NUMBER
     ,old_fa_sync_flag                     VARCHAR2(1)
     ,new_fa_sync_flag                     VARCHAR2(1)
     ,old_fa_mass_addition_id              NUMBER
     ,new_fa_mass_addition_id              NUMBER
     ,old_creation_complete_flag           VARCHAR2(1)
     ,new_creation_complete_flag           VARCHAR2(1)
 );

TYPE ins_asset_history_tbl IS TABLE OF ins_asset_history_rec INDEX BY BINARY_INTEGER;

/*--------------------------------------------------*/
/* Record  ext_attrib_val_history_rec               */
/* is used in retreiving history for a              */
/* given transaction                                */
/*--------------------------------------------------*/

TYPE ext_attrib_val_history_rec IS RECORD
  (
       attribute_value_id                  NUMBER
      ,transaction_id                      NUMBER
      ,old_attribute_value                 VARCHAR2(240)
      ,new_attribute_value                 VARCHAR2(240)
      ,old_active_start_date               DATE
      ,new_active_start_date               DATE
      ,old_active_end_date                 DATE
      ,new_active_end_date                 DATE
      ,old_context                         VARCHAR2(30)
      ,new_context                         VARCHAR2(30)
      ,old_attribute1                      VARCHAR2(150)
      ,new_attribute1                      VARCHAR2(150)
      ,old_attribute2                      VARCHAR2(150)
      ,new_attribute2                      VARCHAR2(150)
      ,old_attribute3                      VARCHAR2(150)
      ,new_attribute3                      VARCHAR2(150)
      ,old_attribute4                      VARCHAR2(150)
      ,new_attribute4                      VARCHAR2(150)
      ,old_attribute5                      VARCHAR2(150)
      ,new_attribute5                      VARCHAR2(150)
      ,old_attribute6                      VARCHAR2(150)
      ,new_attribute6                      VARCHAR2(150)
      ,old_attribute7                      VARCHAR2(150)
      ,new_attribute7                      VARCHAR2(150)
      ,old_attribute8                      VARCHAR2(150)
      ,new_attribute8                      VARCHAR2(150)
      ,old_attribute9                      VARCHAR2(150)
      ,new_attribute9                      VARCHAR2(150)
      ,old_attribute10                     VARCHAR2(150)
      ,new_attribute10                     VARCHAR2(150)
      ,old_attribute11                     VARCHAR2(150)
      ,new_attribute11                     VARCHAR2(150)
      ,old_attribute12                     VARCHAR2(150)
      ,new_attribute12                     VARCHAR2(150)
      ,old_attribute13                     VARCHAR2(150)
      ,new_attribute13                     VARCHAR2(150)
      ,old_attribute14                     VARCHAR2(150)
      ,new_attribute14                     VARCHAR2(150)
      ,old_attribute15                     VARCHAR2(150)
      ,new_attribute15                     VARCHAR2(150)
      ,instance_id                         NUMBER
      ,attribute_code                      VARCHAR2(30)
      ,attribute_value_history_id          NUMBER );

TYPE ext_attrib_val_history_tbl IS TABLE OF ext_attrib_val_history_rec INDEX BY BINARY_INTEGER;


/*---------------------------------------------------------*/
/* Record name: party_history_rec                          */
/* Description :  Party history information                */
/*                                                         */
/*---------------------------------------------------------*/



TYPE party_history_rec IS RECORD
 (
INSTANCE_PARTY_HISTORY_ID         NUMBER  :=  FND_API.G_MISS_NUM,
INSTANCE_PARTY_ID                 NUMBER  :=  FND_API.G_MISS_NUM,
TRANSACTION_ID                    NUMBER  :=  FND_API.G_MISS_NUM,
OLD_PARTY_SOURCE_TABLE            VARCHAR2(30) :=  FND_API.G_MISS_CHAR,
NEW_PARTY_SOURCE_TABLE            VARCHAR2(30) :=  FND_API.G_MISS_CHAR,
OLD_PARTY_ID                      NUMBER       :=  FND_API.G_MISS_NUM,
NEW_PARTY_ID                      NUMBER       :=  FND_API.G_MISS_NUM,
OLD_RELATIONSHIP_TYPE_CODE        VARCHAR2(30) :=  FND_API.G_MISS_CHAR,
NEW_RELATIONSHIP_TYPE_CODE        VARCHAR2(30) :=  FND_API.G_MISS_CHAR,
OLD_CONTACT_FLAG                  VARCHAR2(1)  :=  FND_API.G_MISS_CHAR,
NEW_CONTACT_FLAG                  VARCHAR2(1)  :=  FND_API.G_MISS_CHAR,
OLD_CONTACT_IP_ID                 NUMBER       :=  FND_API.G_MISS_NUM,
NEW_CONTACT_IP_ID                 NUMBER       :=  FND_API.G_MISS_NUM,
OLD_ACTIVE_START_DATE             DATE         :=  FND_API.G_MISS_DATE,
NEW_ACTIVE_START_DATE             DATE         :=  FND_API.G_MISS_DATE,
OLD_ACTIVE_END_DATE               DATE         :=  FND_API.G_MISS_DATE,
NEW_ACTIVE_END_DATE               DATE         :=  FND_API.G_MISS_DATE,
OLD_CONTEXT                       VARCHAR2(30) :=  FND_API.G_MISS_CHAR,
 NEW_CONTEXT                      VARCHAR2(30) :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE1                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE1                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE2                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE2                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE3                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE3                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE4                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE4                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE5                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE5                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE6                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE6                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE7                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE7                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE8                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE8                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE9                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE9                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE10                  VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE10                  VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE11                  VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE11                  VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE12                  VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE12                  VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE13                  VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE13                  VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE14                  VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE14                  VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE15                  VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE15                  VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
 FULL_DUMP_FLAG                   VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
 OBJECT_VERSION_NUMBER            NUMBER        :=  FND_API.G_MISS_NUM,
 OLD_PREFERRED_FLAG               VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
 NEW_PREFERRED_FLAG               VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
 OLD_PRIMARY_FLAG                 VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
 NEW_PRIMARY_FLAG                 VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
 old_party_number                 VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
 old_party_name                   VARCHAR2(360)  :=  FND_API.G_MISS_CHAR,
 old_party_type                   VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
 old_contact_party_number                 VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
 old_contact_party_name                   VARCHAR2(360)  :=  FND_API.G_MISS_CHAR,
 old_contact_party_type                   VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
 old_contact_address1                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
 old_contact_address2                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
 old_contact_address3                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
 old_contact_address4                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
 old_contact_city                         VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
 old_contact_state                        VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
 old_contact_postal_code                  VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
 old_contact_country                      VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
 old_contact_work_phone_num               VARCHAR2(85)   :=  FND_API.G_MISS_CHAR,
 old_contact_email_address                VARCHAR2(2000) :=  FND_API.G_MISS_CHAR,
 new_party_number                         VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
 new_party_name                           VARCHAR2(360)  :=  FND_API.G_MISS_CHAR,
 new_party_type                           VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
 new_contact_party_number                 VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
 new_contact_party_name                   VARCHAR2(360)  :=  FND_API.G_MISS_CHAR,
 new_contact_party_type                   VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
 new_contact_address1                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
 new_contact_address2                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
 new_contact_address3                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
 new_contact_address4                     VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
 new_contact_city                         VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
 new_contact_state                        VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
 new_contact_postal_code                  VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
 new_contact_country                      VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
 new_contact_work_phone_num               VARCHAR2(85)   :=  FND_API.G_MISS_CHAR,
 new_contact_email_address                VARCHAR2(2000) :=  FND_API.G_MISS_CHAR,
 INSTANCE_ID                              NUMBER          :=  FND_API.G_MISS_NUM);

TYPE party_history_tbl IS table of party_history_rec INDEX BY
BINARY_INTEGER;


/*---------------------------------------------------------*/
/* Record name: account_history_rec                        */
/* Description :  Account history information              */
/*                                                         */
/*---------------------------------------------------------*/

TYPE account_history_rec IS RECORD
 (
IP_ACCOUNT_HISTORY_ID                  NUMBER :=  FND_API.G_MISS_NUM,
IP_ACCOUNT_ID                          NUMBER :=  FND_API.G_MISS_NUM,
TRANSACTION_ID                         NUMBER :=  FND_API.G_MISS_NUM,
OLD_PARTY_ACCOUNT_ID                   NUMBER :=  FND_API.G_MISS_NUM,
NEW_PARTY_ACCOUNT_ID                   NUMBER :=  FND_API.G_MISS_NUM,
OLD_RELATIONSHIP_TYPE_CODE             VARCHAR2(30) :=  FND_API.G_MISS_CHAR,
NEW_RELATIONSHIP_TYPE_CODE             VARCHAR2(30) :=  FND_API.G_MISS_CHAR,
OLD_ACTIVE_START_DATE                  DATE :=  FND_API.G_MISS_DATE,
NEW_ACTIVE_START_DATE                  DATE :=  FND_API.G_MISS_DATE,
OLD_ACTIVE_END_DATE                    DATE :=  FND_API.G_MISS_DATE,
NEW_ACTIVE_END_DATE                    DATE :=  FND_API.G_MISS_DATE,
OLD_CONTEXT                            VARCHAR2(30) :=  FND_API.G_MISS_CHAR,
NEW_CONTEXT                            VARCHAR2(30) :=  FND_API.G_MISS_CHAR,
OLD_ATTRIBUTE1                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
NEW_ATTRIBUTE1                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
OLD_ATTRIBUTE2                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
NEW_ATTRIBUTE2                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
OLD_ATTRIBUTE3                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
NEW_ATTRIBUTE3                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
OLD_ATTRIBUTE4                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
NEW_ATTRIBUTE4                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
OLD_ATTRIBUTE5                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
NEW_ATTRIBUTE5                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
OLD_ATTRIBUTE6                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
NEW_ATTRIBUTE6                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
OLD_ATTRIBUTE7                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
NEW_ATTRIBUTE7                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
OLD_ATTRIBUTE8                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
NEW_ATTRIBUTE8                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
OLD_ATTRIBUTE9                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
NEW_ATTRIBUTE9                         VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
OLD_ATTRIBUTE10                        VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
NEW_ATTRIBUTE10                        VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
OLD_ATTRIBUTE11                        VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
NEW_ATTRIBUTE11                        VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
OLD_ATTRIBUTE12                        VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
NEW_ATTRIBUTE12                        VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
OLD_ATTRIBUTE13                        VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
NEW_ATTRIBUTE13                        VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
OLD_ATTRIBUTE14                        VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
NEW_ATTRIBUTE14                        VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
OLD_ATTRIBUTE15                        VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
NEW_ATTRIBUTE15                        VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
FULL_DUMP_FLAG                         VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
OBJECT_VERSION_NUMBER                  NUMBER :=  FND_API.G_MISS_NUM,
OLD_BILL_TO_ADDRESS                    NUMBER :=  FND_API.G_MISS_NUM,
NEW_BILL_TO_ADDRESS                    NUMBER :=  FND_API.G_MISS_NUM,
OLD_SHIP_TO_ADDRESS                    NUMBER :=  FND_API.G_MISS_NUM,
NEW_SHIP_TO_ADDRESS                    NUMBER :=  FND_API.G_MISS_NUM,
old_party_account_number             VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
old_party_account_name               VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
old_bill_to_location                 VARCHAR2(40)   :=  FND_API.G_MISS_CHAR,
old_ship_to_location                 VARCHAR2(40)   :=  FND_API.G_MISS_CHAR,
new_party_account_number             VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
new_party_account_name               VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
new_bill_to_location                 VARCHAR2(40)   :=  FND_API.G_MISS_CHAR,
new_ship_to_location                 VARCHAR2(40)   :=  FND_API.G_MISS_CHAR,
INSTANCE_ID                            NUMBER          :=  FND_API.G_MISS_NUM,
old_bill_to_address1                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR, --added for bug 2670371
new_bill_to_address1                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
old_bill_to_address2                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
new_bill_to_address2                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
old_bill_to_address3                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
new_bill_to_address3                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
old_bill_to_address4                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
new_bill_to_address4                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
old_bill_to_city                       VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,
new_bill_to_city                       VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,
old_bill_to_state                      VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,
new_bill_to_state                      VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,
old_bill_to_postal_code                VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,
new_bill_to_postal_code                VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,
old_bill_to_country                    VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,
new_bill_to_country                    VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,
old_ship_to_address1                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
new_ship_to_address1                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
old_ship_to_address2                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
new_ship_to_address2                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
old_ship_to_address3                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
new_ship_to_address3                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
old_ship_to_address4                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
new_ship_to_address4                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
old_ship_to_city                       VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,
new_ship_to_city                       VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,
old_ship_to_state                      VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,
new_ship_to_state                      VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,
old_ship_to_postal_code                VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,
new_ship_to_postal_code                VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,
old_ship_to_country                    VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,
new_ship_to_country                    VARCHAR2(60)  :=  FND_API.G_MISS_CHAR,  --added for bug 2670371
old_instance_party_id                  NUMBER        :=  FND_API.G_MISS_NUM,   --Added on 04-04-03
new_instance_party_id                  NUMBER        :=  FND_API.G_MISS_NUM    --Added
);
TYPE account_history_tbl IS table of account_history_rec INDEX BY
BINARY_INTEGER;





TYPE org_units_history_rec IS RECORD
 (
 INSTANCE_OU_HISTORY_ID                    NUMBER     :=  FND_API.G_MISS_NUM,
 INSTANCE_OU_ID                            NUMBER      :=  FND_API.G_MISS_NUM,
 TRANSACTION_ID                            NUMBER      :=  FND_API.G_MISS_NUM,
 OLD_OPERATING_UNIT_ID                     NUMBER       :=  FND_API.G_MISS_NUM,
 NEW_OPERATING_UNIT_ID                     NUMBER        :=  FND_API.G_MISS_NUM,
 OLD_RELATIONSHIP_TYPE_CODE                VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
  NEW_RELATIONSHIP_TYPE_CODE               VARCHAR2(30)  :=  FND_API.G_MISS_CHAR,
 OLD_ACTIVE_START_DATE                     DATE           :=  FND_API.G_MISS_DATE,
 NEW_ACTIVE_START_DATE                     DATE           :=  FND_API.G_MISS_DATE,
 OLD_ACTIVE_END_DATE                       DATE           :=  FND_API.G_MISS_DATE,
 NEW_ACTIVE_END_DATE                       DATE           :=  FND_API.G_MISS_DATE,
 OLD_CONTEXT                               VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
 NEW_CONTEXT                               VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE1                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE1                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE2                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE2                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE3                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE3                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE4                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE4                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE5                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE5                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE6                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE6                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE7                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE7                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE8                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE8                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE9                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE9                            VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE10                           VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE10                           VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE11                           VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE11                           VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE12                           VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE12                           VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE13                           VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE13                           VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE14                           VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE14                           VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE15                           VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE15                           VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
 FULL_DUMP_FLAG                            VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
 OBJECT_VERSION_NUMBER                     NUMBER         :=  FND_API.G_MISS_NUM,
 new_operating_unit_name                   VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
 old_operating_unit_name                   VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
 INSTANCE_ID                               NUMBER          :=  FND_API.G_MISS_NUM);

TYPE org_units_history_tbl IS TABLE OF org_units_history_rec INDEX BY BINARY_INTEGER;

TYPE version_label_history_rec IS  RECORD
(
 VERSION_LABEL_HISTORY_ID               NUMBER          :=  FND_API.G_MISS_NUM,
 VERSION_LABEL_ID                       NUMBER          :=  FND_API.G_MISS_NUM,
 TRANSACTION_ID                         NUMBER          :=  FND_API.G_MISS_NUM,
 OLD_VERSION_LABEL                      VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
 NEW_VERSION_LABEL                      VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
 OLD_DESCRIPTION                        VARCHAR2(240)   :=  FND_API.G_MISS_CHAR,
 NEW_DESCRIPTION                        VARCHAR2(240)   :=  FND_API.G_MISS_CHAR,
 OLD_DATE_TIME_STAMP                    DATE            :=  FND_API.G_MISS_DATE,
 NEW_DATE_TIME_STAMP                    DATE            :=  FND_API.G_MISS_DATE,
 OLD_ACTIVE_START_DATE                  DATE            :=  FND_API.G_MISS_DATE,
 NEW_ACTIVE_START_DATE                  DATE            :=  FND_API.G_MISS_DATE,
 OLD_ACTIVE_END_DATE                    DATE            :=  FND_API.G_MISS_DATE,
 NEW_ACTIVE_END_DATE                    DATE            :=  FND_API.G_MISS_DATE,
 OLD_CONTEXT                            VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
 NEW_CONTEXT                            VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE1                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE1                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE2                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE2                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE3                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE3                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE4                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE4                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE5                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE5                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE6                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE6                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE7                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE7                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE8                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE8                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE9                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE9                         VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE10                        VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE10                        VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE11                        VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE11                        VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE12                        VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE12                        VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE13                        VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE13                        VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE14                        VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE14                        VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 OLD_ATTRIBUTE15                        VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 NEW_ATTRIBUTE15                        VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
 FULL_DUMP_FLAG                         VARCHAR2(1)     :=  FND_API.G_MISS_CHAR,
 OBJECT_VERSION_NUMBER                  NUMBER          :=  FND_API.G_MISS_NUM,
 INSTANCE_ID                            NUMBER          :=  FND_API.G_MISS_NUM);


TYPE version_label_history_tbl IS TABLE OF version_label_history_rec  INDEX BY BINARY_INTEGER;

--      Name           : transaction_header_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold the attributes of an Installed Base  transaction.

TYPE transaction_header_rec IS RECORD
(
       TRANSACTION_ID                  NUMBER        := FND_API.G_MISS_NUM ,
       TRANSACTION_DATE                DATE          := FND_API.G_MISS_DATE,
       SOURCE_TRANSACTION_DATE         DATE          := FND_API.G_MISS_DATE,
       TRANSACTION_TYPE_ID             NUMBER        := FND_API.G_MISS_NUM ,
       TXN_SUB_TYPE_ID                 NUMBER        := FND_API.G_MISS_NUM ,
       SOURCE_GROUP_REF_ID             NUMBER        := FND_API.G_MISS_NUM ,
       SOURCE_GROUP_REF                VARCHAR2(50),
       SOURCE_HEADER_REF_ID            NUMBER        := FND_API.G_MISS_NUM ,
       SOURCE_HEADER_REF               VARCHAR2(50),
       SOURCE_LINE_REF_ID              NUMBER        := FND_API.G_MISS_NUM ,
       SOURCE_LINE_REF                 VARCHAR2(50),
       SOURCE_DIST_REF_ID1             NUMBER        := FND_API.G_MISS_NUM ,
       SOURCE_DIST_REF_ID2             NUMBER        := FND_API.G_MISS_NUM ,
       INV_MATERIAL_TRANSACTION_ID     NUMBER        := FND_API.G_MISS_NUM ,
       TRANSACTION_QUANTITY            NUMBER        := FND_API.G_MISS_NUM ,
       TRANSACTION_UOM_CODE            VARCHAR2(3)   := FND_API.G_MISS_CHAR,
       TRANSACTED_BY                   NUMBER        := FND_API.G_MISS_NUM ,
       TRANSACTION_STATUS_CODE         VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       TRANSACTION_ACTION_CODE         VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       MESSAGE_ID                      NUMBER        := FND_API.G_MISS_NUM ,
       CONTEXT                         VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER           NUMBER        := FND_API.G_MISS_NUM,
       SPLIT_REASON_CODE               VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       TXN_USER_ID                     NUMBER        := FND_API.G_MISS_NUM,
       TXN_USER_NAME                   VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       TRANSACTION_TYPE_NAME           VARCHAR2(50)  := FND_API.G_MISS_CHAR,
       TXN_SUB_TYPE_NAME               VARCHAR2(80)  := FND_API.G_MISS_CHAR,
       SOURCE_APPLICATION_NAME         VARCHAR2(240) := FND_API.G_MISS_CHAR,
       TRANSACTION_STATUS_NAME         VARCHAR2(80)  := FND_API.G_MISS_CHAR
);

TYPE  transaction_header_tbl IS TABLE OF transaction_header_rec INDEX BY BINARY_INTEGER;


--      Name           : Grp_Error_Rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold the status of the Interfaced record

TYPE Grp_Error_Rec IS RECORD
(
       Group_Inst_Num                  NUMBER         := FND_API.G_MISS_NUM,
       Process_Status                  VARCHAR2(1)    := FND_API.G_MISS_CHAR,
       Error_Message                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
);


TYPE  Grp_Error_Tbl IS TABLE OF Grp_Error_Rec INDEX BY BINARY_INTEGER;

--      Name           : Grp_Upd_Error_Rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold the status of the Updated Interfaced record

TYPE Grp_Upd_Error_Rec IS RECORD
(
       Instance_id                     NUMBER         := FND_API.G_MISS_NUM,
       Entity_Name                     VARCHAR2(30)   := FND_API.G_MISS_CHAR,
       Error_Message                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
);

TYPE Grp_Upd_Error_Tbl IS TABLE OF Grp_Upd_Error_Rec INDEX BY BINARY_INTEGER;

TYPE system_header_rec IS RECORD
(
       SYSTEM_ID                       NUMBER        := FND_API.G_MISS_NUM  ,
       OPERATING_UNIT_ID               NUMBER        := FND_API.G_MISS_NUM  ,
       CUSTOMER_ID                     NUMBER        := FND_API.G_MISS_NUM  ,
       CUSTOMER_NAME                   VARCHAR2(360) := FND_API.G_MISS_CHAR ,
       CUSTOMER_PARTY_NUMBER           VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       CUSTOMER_NUMBER                 VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       SYSTEM_TYPE_CODE                VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       SYSTEM_TYPE                     VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       SYSTEM_NUMBER                   VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       PARENT_SYSTEM_ID                NUMBER        := FND_API.G_MISS_NUM  ,
       TECHNICAL_CONTACT_ID            NUMBER        := FND_API.G_MISS_NUM  ,
       SERVICE_ADMIN_CONTACT_ID        NUMBER        := FND_API.G_MISS_NUM  ,
       INSTALL_SITE_USE_ID             NUMBER        := FND_API.G_MISS_NUM  ,
       BILL_TO_CONTACT_ID              NUMBER        := FND_API.G_MISS_NUM  ,
       BILL_TO_SITE_USE_ID             NUMBER        := FND_API.G_MISS_NUM  ,
       SHIP_TO_SITE_USE_ID             NUMBER        := FND_API.G_MISS_NUM  ,
       SHIP_TO_CONTACT_ID              NUMBER        := FND_API.G_MISS_NUM  ,
       COTERMINATE_DAY_MONTH           VARCHAR2(6)   := FND_API.G_MISS_CHAR ,
       START_DATE_ACTIVE               DATE          := FND_API.G_MISS_DATE ,
       END_DATE_ACTIVE                 DATE          := FND_API.G_MISS_DATE ,
       AUTOCREATED_FROM_SYSTEM_ID      NUMBER        := FND_API.G_MISS_NUM  ,
       ATTRIBUTE1                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE2                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE3                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE4                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE5                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE6                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE7                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE8                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE9                      VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE10                     VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE11                     VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE12                     VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE13                     VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE14                     VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       ATTRIBUTE15                     VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       CONTEXT                         VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       CONFIG_SYSTEM_TYPE              VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       NAME                            VARCHAR2(50)  := FND_API.G_MISS_CHAR ,
       DESCRIPTION                     VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       OBJECT_VERSION_NUMBER           NUMBER        := FND_API.G_MISS_NUM  ,
       SHIP_TO_CUSTOMER_ID             NUMBER        := FND_API.G_MISS_NUM  ,
       SHIP_TO_CUSTOMER                VARCHAR2(360) := FND_API.G_MISS_CHAR ,
       SHIP_TO_CUSTOMER_NUMBER         VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       SHIP_PARTY_TYPE                 VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       SHIP_TO_SITE_NUMBER             VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       SHIP_TO_LOCATION_ID             NUMBER        := FND_API.G_MISS_NUM  ,
       SHIP_DESCRIPTION                VARCHAR2(2000) := FND_API.G_MISS_CHAR ,
       SHIP_TO_ADDRESS1                VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       SHIP_TO_ADDRESS2                VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       SHIP_TO_ADDRESS3                VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       SHIP_TO_ADDRESS4                VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       SHIP_TO_LOCATION                VARCHAR2(40)  := FND_API.G_MISS_CHAR ,
       SHIP_STATE                      VARCHAR2(60)  := FND_API.G_MISS_CHAR ,
       SHIP_POSTAL_CODE                VARCHAR2(60)  := FND_API.G_MISS_CHAR ,
       SHIP_COUNTRY                    VARCHAR2(60)  := FND_API.G_MISS_CHAR ,
       INSTALL_CUSTOMER_ID             NUMBER        := FND_API.G_MISS_NUM  ,
       INSTALL_CUSTOMER_NUMBER         VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       INSTALL_CUSTOMER                VARCHAR2(360) := FND_API.G_MISS_CHAR ,
       INSTALL_PARTY_TYPE              VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       INSTALL_SITE_NUMBER             VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       INSTALL_LOCATION_ID             NUMBER        := FND_API.G_MISS_NUM  ,
       INSTALL_DESCRIPTION             VARCHAR2(2000) := FND_API.G_MISS_CHAR ,
       INSTALL_ADDRESS1                VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       INSTALL_ADDRESS2                VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       INSTALL_ADDRESS3                VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       INSTALL_ADDRESS4                VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       INSTALL_LOCATION                VARCHAR2(40)  := FND_API.G_MISS_CHAR ,
       INSTALL_STATE                   VARCHAR2(60)  := FND_API.G_MISS_CHAR ,
       INSTALL_POSTAL_CODE             VARCHAR2(60)  := FND_API.G_MISS_CHAR ,
       INSTALL_COUNTRY                 VARCHAR2(60)  := FND_API.G_MISS_CHAR ,
       BILL_TO_CUSTOMER_ID             NUMBER        := FND_API.G_MISS_NUM  ,
       BILL_TO_CUSTOMER_NUMBER         VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       BILL_TO_CUSTOMER                VARCHAR2(360) := FND_API.G_MISS_CHAR ,
       BILL_PARTY_TYPE                 VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       BILL_TO_SITE_NUMBER             VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       BILL_TO_LOCATION_ID             NUMBER        := FND_API.G_MISS_NUM  ,
       BILL_DESCRIPTION                VARCHAR2(2000) := FND_API.G_MISS_CHAR ,
       BILL_TO_ADDRESS1                VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       BILL_TO_ADDRESS2                VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       BILL_TO_ADDRESS3                VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       BILL_TO_ADDRESS4                VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       BILL_TO_LOCATION                VARCHAR2(40)  := FND_API.G_MISS_CHAR ,
       BILL_STATE                      VARCHAR2(60)  := FND_API.G_MISS_CHAR ,
       BILL_POSTAL_CODE                VARCHAR2(60)  := FND_API.G_MISS_CHAR ,
       BILL_COUNTRY                    VARCHAR2(60)  := FND_API.G_MISS_CHAR ,
       TECHNICAL_CONTACT_NUMBER        VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       TECHNICAL_CONTACT               VARCHAR2(360) := FND_API.G_MISS_CHAR ,
       SERVICE_ADMIN_CONTACT_NUMBER    VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       SERVICE_ADMIN_CONTACT           VARCHAR2(360) := FND_API.G_MISS_CHAR ,
       SHIP_TO_CONTACT_NUMBER          VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       SHIP_TO_CONTACT                 VARCHAR2(360) := FND_API.G_MISS_CHAR ,
       BILL_TO_CONTACT_NUMBER          VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       BILL_TO_CONTACT                 VARCHAR2(360) := FND_API.G_MISS_CHAR ,
       PARTY_ID                        NUMBER        := FND_API.G_MISS_NUM  ,
       PARTY_NAME                      VARCHAR2(360) := FND_API.G_MISS_CHAR ,
       PARENT_NAME                     VARCHAR2(50)  := FND_API.G_MISS_CHAR ,
       PARENT_DESCRIPTION              VARCHAR2(240) := FND_API.G_MISS_CHAR ,
       PARENT_NUMBER                   VARCHAR2(30)  := FND_API.G_MISS_CHAR ,
       OPERATING_UNIT_NAME             VARCHAR2(60)  := FND_API.G_MISS_CHAR
);

TYPE  system_header_tbl IS TABLE OF system_header_rec INDEX BY BINARY_INTEGER;
--
TYPE pricing_history_rec IS RECORD
 (
          PRICE_ATTRIB_HISTORY_ID    NUMBER          :=  FND_API.G_MISS_NUM,
          PRICING_ATTRIBUTE_ID       NUMBER          :=  FND_API.G_MISS_NUM,
          TRANSACTION_ID             NUMBER          :=  FND_API.G_MISS_NUM,
          OLD_PRICING_CONTEXT        VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_CONTEXT        VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE1     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE1     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE2     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE2     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE3     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE3     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE4     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE4     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE5     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE5     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE6     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE6     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE7     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE7     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE8     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE8     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE9     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE9     VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE10    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE10    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE11    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE11    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE12    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE12    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE13    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE13    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE14    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE14    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE15    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE15    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE16    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE16    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE17    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE17    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE18    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE18    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE19    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE19    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE20    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE20    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE21    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE21    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE22    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE22    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE23    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE23    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE24    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE24    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE25    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE25    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE26    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE26    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE27    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE27    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE28    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE28    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE29    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE29    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE30    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE30    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE31    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE31    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE32    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE32    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE33    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE33    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE34    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE34    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE35    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE35    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE36    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE36    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE37    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE37    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE38    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE38    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE39    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE39    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE40    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE40    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE41    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE41    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE42    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE42    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE43    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE43    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE44    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE44    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE45    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE45    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE46    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE46    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE47    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE47    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE48    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE48    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE49    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE49    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE50    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE50    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE51    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE51    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE52    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE52    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE53    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE53    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE54    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE54    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE55    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE55    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE56    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE56    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE57    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE57    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE58    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE58    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE59    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE59    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE60    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE60    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE61    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE61    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE62    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE62    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE63    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE63    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE64    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE64    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE65    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE65    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE66    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE66    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE67    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE67    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE68    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE68    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE69    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE69    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE70    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE70    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE71    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE71    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE72    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE72    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE73    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE73    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE74    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE74    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE75    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE75    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE76    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE76    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE77    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE77    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE78    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE78    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE79    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE79    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE80    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE80    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE81    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE81    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE82    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE82    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE83    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE83    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE84    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE84    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE85    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE85    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE86    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE86    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE87    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE87    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE88    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE88    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE89    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE89    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE90    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE90    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE91    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE91    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE92    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE92    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE93    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE93    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE94    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE94    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE95    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE95    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE96    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE96    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE97    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE97    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE98    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE98    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE99    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE99    VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_PRICING_ATTRIBUTE100   VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_PRICING_ATTRIBUTE100   VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_ACTIVE_START_DATE      DATE            :=  FND_API.G_MISS_DATE,
          NEW_ACTIVE_START_DATE      DATE            :=  FND_API.G_MISS_DATE,
          OLD_ACTIVE_END_DATE        DATE            :=  FND_API.G_MISS_DATE,
          NEW_ACTIVE_END_DATE        DATE            :=  FND_API.G_MISS_DATE,
          OLD_CONTEXT                VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
          NEW_CONTEXT                VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE1             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE1             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE2             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE2             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE3             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE3             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE4             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE4             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE5             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE5             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE6             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE6             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE7             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE7             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE8             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE8             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE9             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE9             VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE10            VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE10            VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE11            VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE11            VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE12            VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE12            VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE13            VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE13            VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE14            VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE14            VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          OLD_ATTRIBUTE15            VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          NEW_ATTRIBUTE15            VARCHAR2(150)   :=  FND_API.G_MISS_CHAR,
          FULL_DUMP_FLAG             VARCHAR2(1)     :=  FND_API.G_MISS_CHAR
  );

TYPE  pricing_history_tbl IS TABLE OF pricing_history_rec INDEX BY BINARY_INTEGER;

--      Name           : instance_link_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to hold the Start and End Loc. addresses for network linked instances.

TYPE instance_link_rec is RECORD
  (
      INSTANCE_ID                     NUMBER         :=  FND_API.G_MISS_NUM,
      START_LOC_ADDRESS1              VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      START_LOC_ADDRESS2              VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      START_LOC_ADDRESS3              VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      START_LOC_ADDRESS4              VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      START_LOC_CITY                  VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      START_LOC_STATE                 VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      START_LOC_POSTAL_CODE           VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      START_LOC_COUNTRY               VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      END_LOC_ADDRESS1                VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      END_LOC_ADDRESS2                VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      END_LOC_ADDRESS3                VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      END_LOC_ADDRESS4                VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
      END_LOC_CITY                    VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      END_LOC_STATE                   VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      END_LOC_POSTAL_CODE             VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
      END_LOC_COUNTRY                 VARCHAR2(60)   :=  FND_API.G_MISS_CHAR
  );

TYPE instance_link_tbl is TABLE OF instance_link_rec INDEX BY BINARY_INTEGER;

/* Modified Instance rec type to add the 5 columns at the end , Added ext_attrib_values_rec - Bug ref 4352732 */
--      Name           : instance_cz_rec
--      Package name   : csi_datastructures_pub
--      Type           : table and rec type definition, public
--      Description    : This holds the data that is selected from both the
--                       Install Base Contact Center Tab as well as the
--                       Item instance Query UI.

TYPE instance_cz_rec IS RECORD
 (
     ITEM_INSTANCE_ID               NUMBER         :=  NULL,
     CONFIG_INSTANCE_HDR_ID         NUMBER         :=  NULL,
     CONFIG_INSTANCE_REV_NUMBER     NUMBER         :=  NULL,
     CONFIG_INSTANCE_ITEM_ID        NUMBER         :=  NULL,
     BILL_TO_SITE_USE_ID            NUMBER         :=  NULL,
     SHIP_TO_SITE_USE_ID            NUMBER         :=  NULL,
     SOLD_TO_ORG_ID                 NUMBER         :=  NULL,
     INSTANCE_NAME                  VARCHAR2(240)  :=  NULL,
     INSTANCE_SEQUENCE              NUMBER         :=  NULL,
     BILL_TO_CONTACT_ID             NUMBER         :=  NULL,
     SHIP_TO_CONTACT_ID             NUMBER         :=  NULL,
     IB_OWNER                       VARCHAR2(60)   :=  NULL,
     ACTION                         VARCHAR2(30)   :=  NULL
 );

 TYPE instance_cz_tbl IS TABLE OF instance_cz_rec INDEX BY BINARY_INTEGER;

--      Name           : ext_attrib_values_rec
--      Description    : Extended attribute Name,Value pair records
--      Package name   : csi_datastructures_pub
--      Type           : table and rec type definition, public
--      Description    : This holds the data that is passed on to Configurator
--                       from the Install base Contact Center Tab page

TYPE ext_attrib_values_rec IS RECORD
    (
       attribute_level         VARCHAR2(15)  := NULL,
       attribute_code          VARCHAR2(30)  := NULL,
       attribute_value         VARCHAR2(240) := NULL,
       attribute_sequence      NUMBER        :=  NULL,
       parent_tbl_index        NUMBER        := NULL
    );

 TYPE ext_attrib_values_tbl IS TABLE OF ext_attrib_values_rec INDEX BY BINARY_INTEGER;

/*-----------------------------------------------------------*/
/* Record Name :  contact_details_rec                        */
/* Description : This record holds the details about a party */
/*               contact.                                    */
/*-----------------------------------------------------------*/

TYPE contact_details_rec IS RECORD
(
  contact_party_id             NUMBER,
  party_name                   VARCHAR2(360),
  address1                     VARCHAR2(500),
  address2                     VARCHAR2(500),
  address3                     VARCHAR2(500),
  address4                     VARCHAR2(500),
  city                         VARCHAR2(500),
  state                        VARCHAR2(500),
  postal_code                  VARCHAR2(500),
  country                      VARCHAR2(100),
  email                        VARCHAR2(2000),
  fax                          VARCHAR2(80),
  mobile                       VARCHAR2(80),
  page                         VARCHAR2(80),
  officephone                  VARCHAR2(80),
  homephone                    VARCHAR2(80)
);

TYPE mtl_txn_rec IS RECORD(
	transaction_id              number,
	transaction_date            date,
	creation_date               date,
	inventory_item_id           number,
	organization_id             number,
	lot_number                  varchar2(30) ,
	transaction_quantity        number,
	transaction_uom             varchar2(3),
	primary_quantity            number,
	primary_uom                 varchar2(3),
	transaction_type_id         number,
	transaction_action_id       number,
	transaction_source_type_id  number,
	transfer_transaction_id     number,
	serial_control_code         number,
	lot_control_code            number,
	trx_source_line_id          number,
	transaction_source_id       number
);

TYPE mtl_txn_tbl IS TABLE of mtl_txn_rec INDEX BY binary_integer;

--      Name           : mu_system_rec
--      Package name   : csi_datastructures_pub
--      Type           : type definition, public
--      Description    : record to holds the system ids and flag to indicate whether they
--                       qualify for mass update

TYPE mu_system_rec is RECORD
  (
      SYSTEM_ID                       NUMBER        := FND_API.G_MISS_NUM
  );

TYPE  mu_systems_tbl IS TABLE OF mu_system_rec INDEX BY BINARY_INTEGER;



END csi_datastructures_pub;

/
