--------------------------------------------------------
--  DDL for Package CSI_T_DATASTRUCTURES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_DATASTRUCTURES_GRP" AUTHID CURRENT_USER AS
/* $Header: csigtdss.pls 120.4 2006/01/04 17:47:34 shegde noship $ */

  -- Name        : txn_system_rec
  -- Description : record to hold the values of systems.

  TYPE txn_system_rec IS RECORD(
    TRANSACTION_SYSTEM_ID         NUMBER        :=  FND_API.G_MISS_NUM,
    TRANSACTION_LINE_ID           NUMBER        :=  FND_API.G_MISS_NUM,
    SYSTEM_NAME                   VARCHAR2(50)  :=  FND_API.G_MISS_CHAR,
    DESCRIPTION                   VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
    SYSTEM_TYPE_CODE              VARCHAR2(30)  :=  FND_API.G_MISS_CHAR,
    SYSTEM_NUMBER                 VARCHAR2(30)  :=  FND_API.G_MISS_CHAR,
    CUSTOMER_ID                   NUMBER        :=  FND_API.G_MISS_NUM,
    BILL_TO_CONTACT_ID            NUMBER        :=  FND_API.G_MISS_NUM,
    SHIP_TO_CONTACT_ID            NUMBER        :=  FND_API.G_MISS_NUM,
    TECHNICAL_CONTACT_ID          NUMBER        :=  FND_API.G_MISS_NUM,
    SERVICE_ADMIN_CONTACT_ID      NUMBER        :=  FND_API.G_MISS_NUM,
    SHIP_TO_SITE_USE_ID           NUMBER        :=  FND_API.G_MISS_NUM,
    BILL_TO_SITE_USE_ID           NUMBER        :=  FND_API.G_MISS_NUM,
    INSTALL_SITE_USE_ID           NUMBER        :=  FND_API.G_MISS_NUM,
    COTERMINATE_DAY_MONTH         VARCHAR2(6)   :=  FND_API.G_MISS_CHAR,
    CONFIG_SYSTEM_TYPE            VARCHAR2(30)  :=  FND_API.G_MISS_CHAR,
    START_DATE_ACTIVE             DATE          :=  FND_API.G_MISS_DATE,
    END_DATE_ACTIVE               DATE          :=  FND_API.G_MISS_DATE,
    CONTEXT                       VARCHAR2(30)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE1                    VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE2                    VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE3                    VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE4                    VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE5                    VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE6                    VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE7                    VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE8                    VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE9                    VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE10                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE11                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE12                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE13                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE14                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE15                   VARCHAR2(150) :=  FND_API.G_MISS_CHAR,
    OBJECT_VERSION_NUMBER         NUMBER        :=  FND_API.G_MISS_NUM);

  TYPE  txn_systems_tbl IS TABLE OF txn_system_rec INDEX BY BINARY_INTEGER;

  -- Name         : txn_line_rec
  -- Package name : csi_t_datastructures_grp
  -- Type         : type definition, group
  -- Description  : record to hold the attributes of the source
  --                transaction identifiers.

  TYPE txn_line_rec is RECORD (
    TRANSACTION_LINE_ID         NUMBER         :=  FND_API.G_MISS_NUM,
    SOURCE_TRANSACTION_TYPE_ID  NUMBER         :=  FND_API.G_MISS_NUM,
    SOURCE_TRANSACTION_ID       NUMBER         :=  FND_API.G_MISS_NUM,
---Added (Start) for m-to-m enhancements
    SOURCE_TXN_HEADER_ID        NUMBER         :=  FND_API.G_MISS_NUM,
---Added (End) for m-to-m enhancements
    SOURCE_TRANSACTION_TABLE    VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
-- Added for CZ Integration (Begin)
    CONFIG_SESSION_HDR_ID	NUMBER	       :=  FND_API.G_MISS_NUM,
    CONFIG_SESSION_REV_NUM      NUMBER         :=  FND_API.G_MISS_NUM,
    CONFIG_SESSION_ITEM_ID      NUMBER         :=  FND_API.G_MISS_NUM,
    CONFIG_VALID_STATUS         VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    SOURCE_TRANSACTION_STATUS   VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    API_CALLER_IDENTITY         VARCHAR2(15)   :=  'OTHER',
-- Added for CZ Integration (End)
    INV_MATERIAL_TXN_FLAG       VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    ERROR_CODE                  VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
    ERROR_EXPLANATION           VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
    PROCESSING_STATUS           VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    CONTEXT                     VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE1                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE2                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE3                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE4                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE5                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE6                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE7                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE8                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE9                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE10                 VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE11                 VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE12                 VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE13                 VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE14                 VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE15                 VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    OBJECT_VERSION_NUMBER       NUMBER         :=  FND_API.G_MISS_NUM);

  -- Name         : txn_line_detail_rec
  -- Package name : csi_t_datastructures_grp
  -- Type         : type definition, group
  -- Description  : record to hold the attributes of the txn line detail.

  TYPE txn_line_detail_rec is RECORD (
    TXN_LINE_DETAIL_ID          NUMBER         :=  FND_API.G_MISS_NUM,
    TRANSACTION_LINE_ID         NUMBER         :=  FND_API.G_MISS_NUM,
    SUB_TYPE_ID                 NUMBER         :=  FND_API.G_MISS_NUM,
    INSTANCE_EXISTS_FLAG        VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    SOURCE_TRANSACTION_FLAG     VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    INSTANCE_ID                 NUMBER         :=  FND_API.G_MISS_NUM,
    CHANGED_INSTANCE_ID         NUMBER         :=  FND_API.G_MISS_NUM,
    CSI_SYSTEM_ID               NUMBER         :=  FND_API.G_MISS_NUM,
    INVENTORY_ITEM_ID           NUMBER         :=  FND_API.G_MISS_NUM,
    INVENTORY_REVISION          VARCHAR2(3)    :=  FND_API.G_MISS_CHAR,
    INV_ORGANIZATION_ID         NUMBER         :=  FND_API.G_MISS_NUM,
    ITEM_CONDITION_ID           NUMBER         :=  FND_API.G_MISS_NUM,
    INSTANCE_TYPE_CODE          VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    QUANTITY                    NUMBER         :=  FND_API.G_MISS_NUM,
    UNIT_OF_MEASURE             VARCHAR2(3)    :=  FND_API.G_MISS_CHAR,
    QTY_REMAINING               NUMBER         :=  FND_API.G_MISS_NUM,
    SERIAL_NUMBER               VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    MFG_SERIAL_NUMBER_FLAG      VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    LOT_NUMBER                  VARCHAR2(80)   :=  FND_API.G_MISS_CHAR,
    LOCATION_TYPE_CODE          VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    LOCATION_ID                 NUMBER         :=  FND_API.G_MISS_NUM,
    INSTALLATION_DATE           DATE           :=  FND_API.G_MISS_DATE,
    IN_SERVICE_DATE             DATE           :=  FND_API.G_MISS_DATE,
    EXTERNAL_REFERENCE          VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    TRANSACTION_SYSTEM_ID       NUMBER         :=  FND_API.G_MISS_NUM,
    SELLABLE_FLAG               VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    VERSION_LABEL               VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
    RETURN_BY_DATE              DATE           :=  FND_API.G_MISS_DATE,
    ACTIVE_START_DATE           DATE           :=  FND_API.G_MISS_DATE,
    ACTIVE_END_DATE             DATE           :=  FND_API.G_MISS_DATE,
    PRESERVE_DETAIL_FLAG        VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    REFERENCE_SOURCE_ID         NUMBER         :=  FND_API.G_MISS_NUM,
    REFERENCE_SOURCE_LINE_ID    NUMBER         :=  FND_API.G_MISS_NUM,-- RMA fulfillment 11.5.9 ER
    REFERENCE_SOURCE_DATE       DATE           :=  FND_API.G_MISS_DATE,
    CSI_TRANSACTION_ID          NUMBER         :=  FND_API.G_MISS_NUM,
    SOURCE_TXN_LINE_DETAIL_ID   NUMBER         :=  FND_API.G_MISS_NUM,
    INV_MTL_TRANSACTION_ID      NUMBER         :=  FND_API.G_MISS_NUM,
    PROCESSING_STATUS           VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    ERROR_CODE                  VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
    ERROR_EXPLANATION           VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
    TXN_SYSTEMS_INDEX           NUMBER         :=  FND_API.G_MISS_NUM,
-- Added for CZ Integration (Begin)
    CONFIG_INST_HDR_ID           NUMBER        := FND_API.G_MISS_NUM,
    CONFIG_INST_REV_NUM          NUMBER        := FND_API.G_MISS_NUM,
    CONFIG_INST_ITEM_ID          NUMBER        := FND_API.G_MISS_NUM,
    CONFIG_INST_BASELINE_REV_NUM NUMBER        := FND_API.G_MISS_NUM,
    TARGET_COMMITMENT_DATE       DATE          := FND_API.G_MISS_DATE,
    INSTANCE_DESCRIPTION         VARCHAR2(240) := FND_API.G_MISS_CHAR,
    API_CALLER_IDENTITY          VARCHAR2(15)  := 'OTHER',
-- Added for CZ Integration (End)
-- Added for Partner Ordering (Begin)
    INSTALL_LOCATION_TYPE_CODE  VARCHAR2(60)   :=  FND_API.G_MISS_CHAR,
    INSTALL_LOCATION_ID         NUMBER         :=  FND_API.G_MISS_NUM,
-- Added for Partner Ordering (End)
    CASCADE_OWNER_FLAG          VARCHAR2(1)    :=  FND_API.G_MISS_CHAR, -- bug 2972082
    CONTEXT                     VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE1                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE2                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE3                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE4                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE5                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE6                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE7                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE8                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE9                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE10                 VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE11                 VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE12                 VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE13                 VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE14                 VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE15                 VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    OBJECT_VERSION_NUMBER       NUMBER         :=  FND_API.G_MISS_NUM,
    PARENT_INSTANCE_ID          NUMBER         :=  FND_API.G_MISS_NUM, -- bug 3479880
    ASSC_TXN_LINE_DETAIL_ID     NUMBER         :=  FND_API.G_MISS_NUM, -- bug 3600950
    OVERRIDING_CSI_TXN_ID       NUMBER         :=  FND_API.G_MISS_NUM, -- added for TSO with Equipment R12
    INSTANCE_STATUS_ID          NUMBER         :=  FND_API.G_MISS_NUM); -- added for Mass Update R12

  TYPE txn_line_detail_tbl is TABLE OF txn_line_detail_rec
  INDEX BY BINARY_INTEGER;


  -- Name         : txn_party_detail_rec
  -- Package name : csi_t_datastructures_grp
  -- Type         : type definition, group
  -- Description  : record to hold information about an transaction
  --                detail-party relationship.

  TYPE txn_party_detail_rec IS RECORD (
     TXN_PARTY_DETAIL_ID          NUMBER         :=  FND_API.G_MISS_NUM,
     TXN_LINE_DETAIL_ID           NUMBER         :=  FND_API.G_MISS_NUM,
     INSTANCE_PARTY_ID            NUMBER         :=  FND_API.G_MISS_NUM,
     PARTY_SOURCE_TABLE           VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     PARTY_SOURCE_ID              NUMBER         :=  FND_API.G_MISS_NUM,
     RELATIONSHIP_TYPE_CODE       VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     CONTACT_FLAG                 VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     CONTACT_PARTY_ID             NUMBER         :=  FND_API.G_MISS_NUM,
     ACTIVE_START_DATE            DATE           :=  FND_API.G_MISS_DATE,
     ACTIVE_END_DATE              DATE           :=  FND_API.G_MISS_DATE,
     PRESERVE_DETAIL_FLAG         VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     CONTEXT                      VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE1                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE2                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE3                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE4                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE5                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE6                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE7                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE8                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE9                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE10                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE11                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE12                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE13                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE14                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE15                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     TXN_LINE_DETAILS_INDEX       NUMBER         :=  FND_API.G_MISS_NUM,
     OBJECT_VERSION_NUMBER        NUMBER         :=  FND_API.G_MISS_NUM,
     PRIMARY_FLAG                 VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     PREFERRED_FLAG               VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     TXN_CONTACT_PARTY_INDEX      NUMBER         :=  FND_API.G_MISS_NUM);--added for R12 Mass update tech. requirement

  TYPE txn_party_detail_tbl IS TABLE OF txn_party_detail_rec
  INDEX BY BINARY_INTEGER;


  -- Name         : txn_pty_acct_detail_rec
  -- Package name : csi_t_datastructures_grp
  -- Type         : type definition, group
  -- Description  : record to hold information about an transaction
  --                party detail-account relationship.

  TYPE txn_pty_acct_detail_rec IS RECORD (
     TXN_ACCOUNT_DETAIL_ID        NUMBER         :=  FND_API.G_MISS_NUM,
     TXN_PARTY_DETAIL_ID          NUMBER         :=  FND_API.G_MISS_NUM,
     IP_ACCOUNT_ID                NUMBER         :=  FND_API.G_MISS_NUM,
     ACCOUNT_ID                   NUMBER         :=  FND_API.G_MISS_NUM,
     RELATIONSHIP_TYPE_CODE       VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     BILL_TO_ADDRESS_ID           NUMBER         :=  FND_API.G_MISS_NUM,
     SHIP_TO_ADDRESS_ID           NUMBER         :=  FND_API.G_MISS_NUM,
     ACTIVE_START_DATE            DATE           :=  FND_API.G_MISS_DATE,
     ACTIVE_END_DATE              DATE           :=  FND_API.G_MISS_DATE,
     PRESERVE_DETAIL_FLAG         VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     CONTEXT                      VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE1                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE2                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE3                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE4                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE5                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE6                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE7                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE8                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE9                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE10                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE11                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE12                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE13                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE14                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE15                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     TXN_PARTY_DETAILS_INDEX      NUMBER         :=  FND_API.G_MISS_NUM,
     OBJECT_VERSION_NUMBER        NUMBER         :=  FND_API.G_MISS_NUM);

  TYPE txn_pty_acct_detail_tbl IS TABLE OF txn_pty_acct_detail_rec
  INDEX BY BINARY_INTEGER;


  -- Name         : txn_ii_rltns_rec
  -- Package name : csi_t_datastructures_grp
  -- Type         : type definition, group
  -- Description  : record to hold information about an transaction
  --                detail-configuration details.

  TYPE txn_ii_rltns_rec IS RECORD (
     TXN_RELATIONSHIP_ID          NUMBER         :=  FND_API.G_MISS_NUM,
     TRANSACTION_LINE_ID          NUMBER         :=  FND_API.G_MISS_NUM,
     CSI_INST_RELATIONSHIP_ID     NUMBER         :=  FND_API.G_MISS_NUM,
     SUBJECT_ID                   NUMBER         :=  FND_API.G_MISS_NUM,
---Added (Start) for m-to-m enhancements
     SUBJECT_INDEX_FLAG           VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     SUBJECT_TYPE                 VARCHAR2(30)   :=  'T' ,
---Added (End) for m-to-m enhancements
     OBJECT_ID                    NUMBER         :=  FND_API.G_MISS_NUM,
---Added (Start) for m-to-m enhancements
     OBJECT_INDEX_FLAG            VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     OBJECT_TYPE                  VARCHAR2(30)   :=  'T' ,
---Added (End) for m-to-m enhancements
-- Added for CZ Integration (Begin)
     SUB_CONFIG_INST_HDR_ID	  NUMBER         :=  FND_API.G_MISS_NUM,
     SUB_CONFIG_INST_REV_NUM      NUMBER         :=  FND_API.G_MISS_NUM,
     SUB_CONFIG_INST_ITEM_ID      NUMBER         :=  FND_API.G_MISS_NUM,
     OBJ_CONFIG_INST_HDR_ID       NUMBER         :=  FND_API.G_MISS_NUM,
     OBJ_CONFIG_INST_REV_NUM      NUMBER         :=  FND_API.G_MISS_NUM,
     OBJ_CONFIG_INST_ITEM_ID      NUMBER         :=  FND_API.G_MISS_NUM,
     TARGET_COMMITMENT_DATE	  DATE           :=  FND_API.G_MISS_DATE,
     API_CALLER_IDENTITY          VARCHAR2(15)   := 'OTHER',
-- Added for CZ Integration (End)
     RELATIONSHIP_TYPE_CODE       VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     DISPLAY_ORDER                NUMBER         :=  FND_API.G_MISS_NUM,
     POSITION_REFERENCE           VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     MANDATORY_FLAG               VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     ACTIVE_START_DATE            DATE           :=  FND_API.G_MISS_DATE,
     ACTIVE_END_DATE              DATE           :=  FND_API.G_MISS_DATE,
     CONTEXT                      VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE1                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE2                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE3                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE4                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE5                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE6                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE7                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE8                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE9                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE10                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE11                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE12                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE13                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE14                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE15                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     OBJECT_VERSION_NUMBER        NUMBER         :=  FND_API.G_MISS_NUM,
     TRANSFER_COMPONENTS_FLAG     VARCHAR2(1)    :=  FND_API.G_MISS_CHAR);

  TYPE txn_ii_rltns_tbl IS TABLE OF txn_ii_rltns_rec
  INDEX BY BINARY_INTEGER;


  -- Name         : txn_org_assgn_rec
  -- Package name : csi_t_datastructures_grp
  -- Type         : type definition, group
  -- Description  : record to hold information about an transaction
  --                details-org association.

  TYPE txn_org_assgn_rec IS RECORD (
     TXN_OPERATING_UNIT_ID        NUMBER         :=  FND_API.G_MISS_NUM,
     TXN_LINE_DETAIL_ID           NUMBER         :=  FND_API.G_MISS_NUM,
     INSTANCE_OU_ID               NUMBER         :=  FND_API.G_MISS_NUM,
     OPERATING_UNIT_ID            NUMBER         :=  FND_API.G_MISS_NUM,
     RELATIONSHIP_TYPE_CODE       VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     ACTIVE_START_DATE            DATE           :=  FND_API.G_MISS_DATE,
     ACTIVE_END_DATE              DATE           :=  FND_API.G_MISS_DATE,
     PRESERVE_DETAIL_FLAG         VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
     CONTEXT                      VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE1                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE2                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE3                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE4                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE5                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE6                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE7                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE8                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE9                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE10                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE11                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE12                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE13                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE14                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     ATTRIBUTE15                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
     TXN_LINE_DETAILS_INDEX       NUMBER         :=  FND_API.G_MISS_NUM,
     OBJECT_VERSION_NUMBER        NUMBER         :=  FND_API.G_MISS_NUM);

  TYPE txn_org_assgn_tbl IS TABLE OF txn_org_assgn_rec
  INDEX BY BINARY_INTEGER;


  -- Name         : txn_ext_attrib_vals_rec
  -- Package name : csi_t_datastructures_grp
  -- Type         : type definition, group
  -- Description  : record to hold the values of a transaction detail's
  --                extended attributes.

  TYPE txn_ext_attrib_vals_rec IS RECORD(
    TXN_ATTRIB_DETAIL_ID         NUMBER         :=  FND_API.G_MISS_NUM,
    TXN_LINE_DETAIL_ID           NUMBER         :=  FND_API.G_MISS_NUM,
    ATTRIB_SOURCE_TABLE          VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE_SOURCE_ID          NUMBER         :=  FND_API.G_MISS_NUM,
    ATTRIBUTE_VALUE              VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
-- Added for CZ Integration (Begin)
    ATTRIBUTE_CODE               VARCHAR2(30)   :=  FND_API.g_miss_char,
    ATTRIBUTE_LEVEL              VARCHAR2(15)   :=  FND_API.g_miss_char,
    API_CALLER_IDENTITY          VARCHAR2(15)   :=  'OTHER',
-- Added for CZ Integration (End)
    PROCESS_FLAG                 VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    ACTIVE_START_DATE            DATE           :=  FND_API.G_MISS_DATE,
    ACTIVE_END_DATE              DATE           :=  FND_API.G_MISS_DATE,
    PRESERVE_DETAIL_FLAG         VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    CONTEXT                      VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE1                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE2                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE3                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE4                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE5                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE6                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE7                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE8                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE9                   VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE10                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE11                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE12                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE13                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE14                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE15                  VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    TXN_LINE_DETAILS_INDEX       NUMBER         :=  FND_API.G_MISS_NUM,
    OBJECT_VERSION_NUMBER        NUMBER         :=  FND_API.G_MISS_NUM);


  TYPE txn_ext_attrib_vals_tbl IS table of txn_ext_attrib_vals_rec
  INDEX BY BINARY_INTEGER;

  -- Name         : csi_ext_attribs_rec
  -- Package name : csi_t_datastructures_grp
  -- Type         : type definition, group
  -- Description  : record to hold the item's extended attributes as defined
  --                in the core installed base (csi_i_extend_attribs)

  TYPE csi_ext_attribs_rec IS RECORD(
    ATTRIBUTE_ID              NUMBER        := FND_API.g_miss_num,
    ATTRIBUTE_LEVEL           VARCHAR2(15)  := FND_API.g_miss_char,
    MASTER_ORGANIZATION_ID    NUMBER        := FND_API.g_miss_num,
    INVENTORY_ITEM_ID         NUMBER        := FND_API.g_miss_num,
    ITEM_CATEGORY_ID          NUMBER        := FND_API.g_miss_num,
    INSTANCE_ID               NUMBER        := FND_API.g_miss_num,
    ATTRIBUTE_CODE            VARCHAR2(30)  := FND_API.g_miss_char,
    ATTRIBUTE_NAME            VARCHAR2(50)  := FND_API.g_miss_char,
    ATTRIBUTE_CATEGORY        VARCHAR2(30)  := FND_API.g_miss_char,
    DESCRIPTION               VARCHAR2(240) := FND_API.g_miss_char,
    ACTIVE_START_DATE         DATE          := FND_API.g_miss_date,
    ACTIVE_END_DATE           DATE          := FND_API.g_miss_date,
    CONTEXT                   VARCHAR2(30)  := FND_API.g_miss_char,
    ATTRIBUTE1                VARCHAR2(150) := FND_API.g_miss_char,
    ATTRIBUTE2                VARCHAR2(150) := FND_API.g_miss_char,
    ATTRIBUTE3                VARCHAR2(150) := FND_API.g_miss_char,
    ATTRIBUTE4                VARCHAR2(150) := FND_API.g_miss_char,
    ATTRIBUTE5                VARCHAR2(150) := FND_API.g_miss_char,
    ATTRIBUTE6                VARCHAR2(150) := FND_API.g_miss_char,
    ATTRIBUTE7                VARCHAR2(150) := FND_API.g_miss_char,
    ATTRIBUTE8                VARCHAR2(150) := FND_API.g_miss_char,
    ATTRIBUTE9                VARCHAR2(150) := FND_API.g_miss_char,
    ATTRIBUTE10               VARCHAR2(150) := FND_API.g_miss_char,
    ATTRIBUTE11               VARCHAR2(150) := FND_API.g_miss_char,
    ATTRIBUTE12               VARCHAR2(150) := FND_API.g_miss_char,
    ATTRIBUTE13               VARCHAR2(150) := FND_API.g_miss_char,
    ATTRIBUTE14               VARCHAR2(150) := FND_API.g_miss_char,
    ATTRIBUTE15               VARCHAR2(150) := FND_API.g_miss_char,
    OBJECT_VERSION_NUMBER     NUMBER        := FND_API.g_miss_num);

  TYPE csi_ext_attribs_tbl IS table of csi_ext_attribs_rec
  INDEX BY BINARY_INTEGER;


  -- Name        : csi_ext_attrib_vals_rec
  -- Description : record to hold the values of an item instances
  --               extended attribute values.

  TYPE csi_ext_attrib_vals_rec IS RECORD(
    ATTRIBUTE_VALUE_ID      NUMBER         :=  FND_API.G_MISS_NUM,
    INSTANCE_ID             NUMBER         :=  FND_API.G_MISS_NUM,
    ATTRIBUTE_ID            NUMBER         :=  FND_API.G_MISS_NUM,
    ATTRIBUTE_VALUE         VARCHAR2(240)  :=  FND_API.G_MISS_CHAR,
    ACTIVE_START_DATE       DATE           :=  FND_API.G_MISS_DATE,
    ACTIVE_END_DATE         DATE           :=  FND_API.G_MISS_DATE,
    CONTEXT                 VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE1              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE2              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE3              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE4              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE5              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE6              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE7              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE8              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE9              VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE10             VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE11             VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE12             VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE13             VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE14             VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    ATTRIBUTE15             VARCHAR2(150)  :=  FND_API.G_MISS_CHAR,
    OBJECT_VERSION_NUMBER   NUMBER         :=  FND_API.G_MISS_NUM);

  TYPE csi_ext_attrib_vals_tbl IS TABLE OF csi_ext_attrib_vals_rec
  INDEX BY BINARY_INTEGER;


  -- Name         : txn_line_detail_ids_rec
  -- Package name : csi_t_datastructures_grp
  -- Type         : type definition, group
  -- Description  : record to hold internal id values of the txn line details

  TYPE txn_line_detail_ids_rec IS RECORD
  (
     TRANSACTION_LINE_ID          NUMBER         :=  FND_API.G_MISS_NUM,
     TXN_LINE_DETAIL_ID           NUMBER         :=  FND_API.G_MISS_NUM
  );

  TYPE txn_line_detail_ids_tbl IS TABLE OF txn_line_detail_ids_rec
  INDEX BY BINARY_INTEGER;

  -- Name         : txn_party_ids_rec
  -- Package name : csi_t_datastructures_grp
  -- Type         : type definition, group
  -- Description  : record to hold internal id values of the instance
  --                party relationship

  TYPE txn_party_ids_rec IS RECORD
  (
     TXN_PARTY_DETAIL_ID          NUMBER         :=  FND_API.G_MISS_NUM,
     TXN_LINE_DETAIL_ID           NUMBER         :=  FND_API.G_MISS_NUM
  );

  TYPE txn_party_ids_tbl IS TABLE OF txn_party_ids_rec
  INDEX BY BINARY_INTEGER;


  -- Name         : txn_pty_acct_ids_rec
  -- Package name : csi_t_datastructures_grp
  -- Type         : type definition, group
  -- Description  : record to hold internal id values of the instance
  --                accounts

  TYPE txn_pty_acct_ids_rec IS RECORD
  (
     TXN_ACCOUNT_DETAIL_ID        NUMBER         :=  FND_API.G_MISS_NUM,
     TXN_PARTY_DETAIL_ID          NUMBER         :=  FND_API.G_MISS_NUM,
     TXN_LINE_DETAIL_ID           NUMBER         :=  FND_API.G_MISS_NUM
  );

  TYPE txn_pty_acct_ids_tbl IS TABLE OF txn_pty_acct_ids_rec
  INDEX BY BINARY_INTEGER;


  -- Name         : txn_ii_rltns_ids_rec
  -- Package name : csi_t_datastructures_grp
  -- Type         : type definition, group
  -- Description  : record to hold internal id values of the
  --                instance-instance relationships

  TYPE txn_ii_rltns_ids_rec IS RECORD
  (
     TXN_RELATIONSHIP_ID         NUMBER         :=  FND_API.G_MISS_NUM,
     TRANSACTION_LINE_ID         NUMBER         :=  FND_API.G_MISS_NUM
  );

  TYPE txn_ii_rltns_ids_tbl IS TABLE OF txn_ii_rltns_ids_rec
  INDEX BY BINARY_INTEGER;


  -- Name         : txn_org_assgn_ids_rec
  -- Package name : csi_t_datastructures_grp
  -- Type         : type definition, group
  -- Description  : record to hold internal id values of the instance
  --                org assignments

  TYPE txn_org_assgn_ids_rec IS RECORD
  (
     TXN_OPERATING_UNIT_ID        NUMBER         :=  FND_API.G_MISS_NUM,
     TXN_LINE_DETAIL_ID           NUMBER         :=  FND_API.G_MISS_NUM
  );

  TYPE txn_org_assgn_ids_tbl IS TABLE OF txn_org_assgn_ids_rec
  INDEX BY BINARY_INTEGER;


  -- Name         : txn_ext_attrib_ids_rec
  -- Package name : csi_t_datastructures_grp
  -- Type         : type definition, group
  -- Description  : record to hold internal id values of the extended
  --                attributes

  TYPE txn_ext_attrib_ids_rec IS RECORD
  (
     TXN_ATTRIB_DETAIL_ID         NUMBER         :=  FND_API.G_MISS_NUM,
     TXN_LINE_DETAIL_ID           NUMBER         :=  FND_API.G_MISS_NUM
  );

  TYPE txn_ext_attrib_ids_tbl IS TABLE OF txn_ext_attrib_ids_rec
  INDEX BY BINARY_INTEGER;

  -- Name         : txn_line_query_rec
  -- Description  : This record structure holds the possible query criteria
  --                for transaction line

  TYPE txn_line_query_rec is RECORD(
    TRANSACTION_LINE_ID         NUMBER        :=  FND_API.G_MISS_NUM,
---Added (Start) for m-to-m enhancements
    SOURCE_TRANSACTION_TYPE_ID  NUMBER        :=  FND_API.G_MISS_NUM,
    SOURCE_TXN_HEADER_ID        NUMBER        :=  FND_API.G_MISS_NUM,
---Added (End) for m-to-m enhancements
    SOURCE_TRANSACTION_ID       NUMBER        :=  FND_API.G_MISS_NUM,
    SOURCE_TRANSACTION_TABLE    VARCHAR2(30)  :=  FND_API.G_MISS_CHAR,
-- Added for CZ Integration (Begin)
    CONFIG_SESSION_HDR_ID       NUMBER         :=  FND_API.G_MISS_NUM,
    CONFIG_SESSION_REV_NUM      NUMBER         :=  FND_API.G_MISS_NUM,
    CONFIG_SESSION_ITEM_ID      NUMBER         :=  FND_API.G_MISS_NUM,
    API_CALLER_IDENTITY         VARCHAR2(15)   :=  'OTHER',
-- Added for CZ Integration (End)
    PROCESSING_STATUS           VARCHAR2(30)  :=  FND_API.G_MISS_CHAR,
    ERROR_CODE                  VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
    ERROR_EXPLANATION           VARCHAR2(240) :=  FND_API.G_MISS_CHAR);


  -- Name         : txn_line_detail_query_rec
  -- Description  : This record structure holds the possible query criteria
  --                for transaction line detail

  TYPE txn_line_detail_query_rec is RECORD(
    TRANSACTION_LINE_ID         NUMBER        :=  FND_API.G_MISS_NUM,
    TXN_LINE_DETAIL_ID          NUMBER        :=  FND_API.G_MISS_NUM,
    SUB_TYPE_ID                 NUMBER        :=  FND_API.G_MISS_NUM,
    CSI_TRANSACTION_ID          NUMBER        :=  FND_API.G_MISS_NUM,
    SOURCE_TRANSACTION_FLAG     VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
    INSTANCE_ID                 NUMBER        :=  FND_API.G_MISS_NUM,
    INSTANCE_EXISTS_FLAG        VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
    CSI_SYSTEM_ID               NUMBER        :=  FND_API.G_MISS_NUM,
    TRANSACTION_SYSTEM_ID       NUMBER        :=  FND_API.G_MISS_NUM,
    INV_ORGANIZATION_ID         NUMBER        :=  FND_API.G_MISS_NUM,
    INVENTORY_ITEM_ID           NUMBER        :=  FND_API.G_MISS_NUM,
    INVENTORY_REVISION          VARCHAR2(3)   :=  FND_API.G_MISS_CHAR,
    SERIAL_NUMBER               VARCHAR2(30)  :=  FND_API.G_MISS_CHAR,
    MFG_SERIAL_NUMBER_FLAG      VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
    LOT_NUMBER                  VARCHAR2(80)  :=  FND_API.G_MISS_CHAR,
    LOCATION_TYPE_CODE          VARCHAR2(30)  :=  FND_API.G_MISS_CHAR,
    EXTERNAL_REFERENCE          VARCHAR2(30)  :=  FND_API.G_MISS_CHAR,
    RETURN_BY_DATE              DATE          :=  FND_API.G_MISS_DATE,
    REFERENCE_SOURCE_ID         NUMBER        :=  FND_API.G_MISS_NUM,
    PROCESSING_STATUS           VARCHAR2(30)  :=  FND_API.G_MISS_CHAR,
    ERROR_CODE                  VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
    ERROR_EXPLANATION           VARCHAR2(240) :=  FND_API.G_MISS_CHAR);

END csi_t_datastructures_grp;

 

/
