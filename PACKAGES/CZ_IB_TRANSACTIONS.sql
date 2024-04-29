--------------------------------------------------------
--  DDL for Package CZ_IB_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_IB_TRANSACTIONS" AUTHID CURRENT_USER AS
/*  $Header: czibtxs.pls 120.0.12010000.2 2008/11/10 07:14:15 kksriram ship $	*/

 -----------------------------------------------------------------------
 ------------------ stubs for CSI structures ---------------------------
 -----------------------------------------------------------------------

  -- Name        : txn_system_rec
  -- Description : record to hold the values of systems.

  TYPE txn_system_rec IS RECORD(
    TRANSACTION_SYSTEM_ID         NUMBER        ,
    TRANSACTION_LINE_ID           NUMBER        ,
    SYSTEM_NAME                   VARCHAR2(50)  ,
    DESCRIPTION                   VARCHAR2(240) ,
    SYSTEM_TYPE_CODE              VARCHAR2(30)  ,
    SYSTEM_NUMBER                 VARCHAR2(30)  ,
    CUSTOMER_ID                   NUMBER        ,
    BILL_TO_CONTACT_ID            NUMBER        ,
    SHIP_TO_CONTACT_ID            NUMBER        ,
    TECHNICAL_CONTACT_ID          NUMBER        ,
    SERVICE_ADMIN_CONTACT_ID      NUMBER        ,
    SHIP_TO_SITE_USE_ID           NUMBER        ,
    BILL_TO_SITE_USE_ID           NUMBER        ,
    INSTALL_SITE_USE_ID           NUMBER        ,
    COTERMINATE_DAY_MONTH         VARCHAR2(6)   ,
    CONFIG_SYSTEM_TYPE            VARCHAR2(30)  ,
    START_DATE_ACTIVE             DATE          ,
    END_DATE_ACTIVE               DATE          ,
    CONTEXT VARCHAR2(30)  ,
    ATTRIBUTE1                    VARCHAR2(150) ,
    ATTRIBUTE2                    VARCHAR2(150) ,
    ATTRIBUTE3                    VARCHAR2(150) ,
    ATTRIBUTE4                    VARCHAR2(150) ,
    ATTRIBUTE5                    VARCHAR2(150) ,
    ATTRIBUTE6                    VARCHAR2(150) ,
    ATTRIBUTE7                    VARCHAR2(150) ,
    ATTRIBUTE8                    VARCHAR2(150) ,
    ATTRIBUTE9                    VARCHAR2(150) ,
    ATTRIBUTE10                   VARCHAR2(150) ,
    ATTRIBUTE11                   VARCHAR2(150) ,
    ATTRIBUTE12                   VARCHAR2(150) ,
    ATTRIBUTE13                   VARCHAR2(150) ,
    ATTRIBUTE14                   VARCHAR2(150) ,
    ATTRIBUTE15                   VARCHAR2(150) ,
    OBJECT_VERSION_NUMBER         NUMBER        );

  TYPE  txn_systems_tbl IS TABLE OF txn_system_rec INDEX BY BINARY_INTEGER;

  -- Name         : txn_line_rec
  -- Type         : type definition, group
  -- Description  : record to hold the attributes of the source
  --                transaction identifiers.

  TYPE txn_line_rec IS RECORD (
    TRANSACTION_LINE_ID         NUMBER         ,
    SOURCE_TRANSACTION_TYPE_ID  NUMBER         ,
    SOURCE_TRANSACTION_ID       NUMBER         ,
---Added (Start) for m-to-m enhancements
    SOURCE_TXN_HEADER_ID        NUMBER         ,
---Added (End) for m-to-m enhancements
    SOURCE_TRANSACTION_TABLE    VARCHAR2(30)   ,
-- Added for CZ Integration (Begin)
    CONFIG_SESSION_HDR_ID	NUMBER	       ,
    CONFIG_SESSION_REV_NUM      NUMBER         ,
    CONFIG_SESSION_ITEM_ID      NUMBER         ,
    CONFIG_VALID_STATUS         VARCHAR2(30)   ,
    SOURCE_TRANSACTION_STATUS   VARCHAR2(30)   ,
    API_CALLER_IDENTITY         VARCHAR2(15)   ,
-- Added for CZ Integration (End)
    INV_MATERIAL_TXN_FLAG       VARCHAR2(1)    ,
    ERROR_CODE                  VARCHAR2(240)  ,
    ERROR_EXPLANATION           VARCHAR2(240)  ,
    PROCESSING_STATUS           VARCHAR2(30)   ,
    CONTEXT                     VARCHAR2(30)   ,
    ATTRIBUTE1                  VARCHAR2(150)  ,
    ATTRIBUTE2                  VARCHAR2(150)  ,
    ATTRIBUTE3                  VARCHAR2(150)  ,
    ATTRIBUTE4                  VARCHAR2(150)  ,
    ATTRIBUTE5                  VARCHAR2(150)  ,
    ATTRIBUTE6                  VARCHAR2(150)  ,
    ATTRIBUTE7                  VARCHAR2(150)  ,
    ATTRIBUTE8                  VARCHAR2(150)  ,
    ATTRIBUTE9                  VARCHAR2(150)  ,
    ATTRIBUTE10                 VARCHAR2(150)  ,
    ATTRIBUTE11                 VARCHAR2(150)  ,
    ATTRIBUTE12                 VARCHAR2(150)  ,
    ATTRIBUTE13                 VARCHAR2(150)  ,
    ATTRIBUTE14                 VARCHAR2(150)  ,
    ATTRIBUTE15                 VARCHAR2(150)  ,
    OBJECT_VERSION_NUMBER       NUMBER         );

  -- Name         : txn_line_detail_rec
  -- Type         : type definition, group
  -- Description  : record to hold the attributes of the txn line detail.

  TYPE txn_line_detail_rec IS RECORD (
    TXN_LINE_DETAIL_ID          NUMBER         ,
    TRANSACTION_LINE_ID         NUMBER         ,
    SUB_TYPE_ID                 NUMBER         ,
    INSTANCE_EXISTS_FLAG        VARCHAR2(1)    ,
    SOURCE_TRANSACTION_FLAG     VARCHAR2(1)    ,
    INSTANCE_ID                 NUMBER         ,
    CHANGED_INSTANCE_ID         NUMBER         ,
    CSI_SYSTEM_ID               NUMBER         ,
    INVENTORY_ITEM_ID           NUMBER         ,
    INVENTORY_REVISION          VARCHAR2(3)    ,
    INV_ORGANIZATION_ID         NUMBER         ,
    ITEM_CONDITION_ID           NUMBER         ,
    INSTANCE_TYPE_CODE          VARCHAR2(30)   ,
    QUANTITY                    NUMBER         ,
    UNIT_OF_MEASURE             VARCHAR2(3)    ,
    QTY_REMAINING               NUMBER         ,
    SERIAL_NUMBER               VARCHAR2(30)   ,
    MFG_SERIAL_NUMBER_FLAG      VARCHAR2(1)    ,
    LOT_NUMBER                  VARCHAR2(30)   ,
    LOCATION_TYPE_CODE          VARCHAR2(30)   ,
    LOCATION_ID                 NUMBER         ,
    INSTALLATION_DATE           DATE           ,
    IN_SERVICE_DATE             DATE           ,
    EXTERNAL_REFERENCE          VARCHAR2(30)   ,
    TRANSACTION_SYSTEM_ID       NUMBER         ,
    SELLABLE_FLAG               VARCHAR2(1)    ,
    VERSION_LABEL               VARCHAR2(240)  ,
    RETURN_BY_DATE              DATE           ,
    ACTIVE_START_DATE           DATE           ,
    ACTIVE_END_DATE             DATE           ,
    PRESERVE_DETAIL_FLAG        VARCHAR2(1)    ,
    REFERENCE_SOURCE_ID         NUMBER         ,
    REFERENCE_SOURCE_DATE       DATE           ,
    CSI_TRANSACTION_ID          NUMBER         ,
    SOURCE_TXN_LINE_DETAIL_ID   NUMBER         ,
    INV_MTL_TRANSACTION_ID      NUMBER         ,
    PROCESSING_STATUS           VARCHAR2(30)   ,
    ERROR_CODE                  VARCHAR2(240)  ,
    ERROR_EXPLANATION           VARCHAR2(240)  ,
    TXN_SYSTEMS_INDEX           NUMBER         ,
-- Added for CZ Integration (Begin)
    CONFIG_INST_HDR_ID           NUMBER        ,
    CONFIG_INST_REV_NUM          NUMBER        ,
    CONFIG_INST_ITEM_ID          NUMBER        ,
    CONFIG_INST_BASELINE_REV_NUM NUMBER        ,
    TARGET_COMMITMENT_DATE       DATE          ,
    INSTANCE_DESCRIPTION         VARCHAR2(240) ,
    API_CALLER_IDENTITY          VARCHAR2(15)  ,
-- Added for CZ Integration (End)
    CONTEXT                     VARCHAR2(30)   ,
    ATTRIBUTE1                  VARCHAR2(150)  ,
    ATTRIBUTE2                  VARCHAR2(150)  ,
    ATTRIBUTE3                  VARCHAR2(150)  ,
    ATTRIBUTE4                  VARCHAR2(150)  ,
    ATTRIBUTE5                  VARCHAR2(150)  ,
    ATTRIBUTE6                  VARCHAR2(150)  ,
    ATTRIBUTE7                  VARCHAR2(150)  ,
    ATTRIBUTE8                  VARCHAR2(150)  ,
    ATTRIBUTE9                  VARCHAR2(150)  ,
    ATTRIBUTE10                 VARCHAR2(150)  ,
    ATTRIBUTE11                 VARCHAR2(150)  ,
    ATTRIBUTE12                 VARCHAR2(150)  ,
    ATTRIBUTE13                 VARCHAR2(150)  ,
    ATTRIBUTE14                 VARCHAR2(150)  ,
    ATTRIBUTE15                 VARCHAR2(150)  ,
    OBJECT_VERSION_NUMBER       NUMBER         );

  TYPE txn_line_detail_tbl IS TABLE OF txn_line_detail_rec INDEX BY BINARY_INTEGER;


  -- Name         : txn_party_detail_rec
  -- Type         : type definition, group
  -- Description  : record to hold information about an transaction
  --                detail-party relationship.

  TYPE txn_party_detail_rec IS RECORD (
     TXN_PARTY_DETAIL_ID          NUMBER         ,
     TXN_LINE_DETAIL_ID           NUMBER         ,
     INSTANCE_PARTY_ID            NUMBER         ,
     PARTY_SOURCE_TABLE           VARCHAR2(30)   ,
     PARTY_SOURCE_ID              NUMBER         ,
     RELATIONSHIP_TYPE_CODE       VARCHAR2(30)   ,
     CONTACT_FLAG                 VARCHAR2(1)    ,
     CONTACT_PARTY_ID             NUMBER         ,
     ACTIVE_START_DATE            DATE           ,
     ACTIVE_END_DATE              DATE           ,
     PRESERVE_DETAIL_FLAG         VARCHAR2(1)    ,
     CONTEXT                      VARCHAR2(30)   ,
     ATTRIBUTE1                   VARCHAR2(150)  ,
     ATTRIBUTE2                   VARCHAR2(150)  ,
     ATTRIBUTE3                   VARCHAR2(150)  ,
     ATTRIBUTE4                   VARCHAR2(150)  ,
     ATTRIBUTE5                   VARCHAR2(150)  ,
     ATTRIBUTE6                   VARCHAR2(150)  ,
     ATTRIBUTE7                   VARCHAR2(150)  ,
     ATTRIBUTE8                   VARCHAR2(150)  ,
     ATTRIBUTE9                   VARCHAR2(150)  ,
     ATTRIBUTE10                  VARCHAR2(150)  ,
     ATTRIBUTE11                  VARCHAR2(150)  ,
     ATTRIBUTE12                  VARCHAR2(150)  ,
     ATTRIBUTE13                  VARCHAR2(150)  ,
     ATTRIBUTE14                  VARCHAR2(150)  ,
     ATTRIBUTE15                  VARCHAR2(150)  ,
     TXN_LINE_DETAILS_INDEX       NUMBER         ,
     OBJECT_VERSION_NUMBER        NUMBER         );

  TYPE txn_party_detail_tbl IS TABLE OF txn_party_detail_rec INDEX BY BINARY_INTEGER;


  -- Name         : txn_pty_acct_detail_rec
  -- Type         : type definition, group
  -- Description  : record to hold information about an transaction
  --                party detail-account relationship.

  TYPE txn_pty_acct_detail_rec IS RECORD (
     TXN_ACCOUNT_DETAIL_ID        NUMBER         ,
     TXN_PARTY_DETAIL_ID          NUMBER         ,
     IP_ACCOUNT_ID                NUMBER         ,
     ACCOUNT_ID                   NUMBER         ,
     RELATIONSHIP_TYPE_CODE       VARCHAR2(30)   ,
     BILL_TO_ADDRESS_ID           NUMBER         ,
     SHIP_TO_ADDRESS_ID           NUMBER         ,
     ACTIVE_START_DATE            DATE           ,
     ACTIVE_END_DATE              DATE           ,
     PRESERVE_DETAIL_FLAG         VARCHAR2(1)    ,
     CONTEXT                      VARCHAR2(30)   ,
     ATTRIBUTE1                   VARCHAR2(150)  ,
     ATTRIBUTE2                   VARCHAR2(150)  ,
     ATTRIBUTE3                   VARCHAR2(150)  ,
     ATTRIBUTE4                   VARCHAR2(150)  ,
     ATTRIBUTE5                   VARCHAR2(150)  ,
     ATTRIBUTE6                   VARCHAR2(150)  ,
     ATTRIBUTE7                   VARCHAR2(150)  ,
     ATTRIBUTE8                   VARCHAR2(150)  ,
     ATTRIBUTE9                   VARCHAR2(150)  ,
     ATTRIBUTE10                  VARCHAR2(150)  ,
     ATTRIBUTE11                  VARCHAR2(150)  ,
     ATTRIBUTE12                  VARCHAR2(150)  ,
     ATTRIBUTE13                  VARCHAR2(150)  ,
     ATTRIBUTE14                  VARCHAR2(150)  ,
     ATTRIBUTE15                  VARCHAR2(150)  ,
     TXN_PARTY_DETAILS_INDEX      NUMBER         ,
     OBJECT_VERSION_NUMBER        NUMBER         );

  TYPE txn_pty_acct_detail_tbl IS TABLE OF txn_pty_acct_detail_rec INDEX BY BINARY_INTEGER;


  -- Name         : txn_ii_rltns_rec
  -- Type         : type definition, group
  -- Description  : record to hold information about an transaction
  --                detail-configuration details.

  TYPE txn_ii_rltns_rec IS RECORD (
     TXN_RELATIONSHIP_ID          NUMBER         ,
     TRANSACTION_LINE_ID          NUMBER         ,
     CSI_INST_RELATIONSHIP_ID     NUMBER         ,
     SUBJECT_ID                   NUMBER         ,
---Added (Start) for m-to-m enhancements
     SUBJECT_INDEX_FLAG           VARCHAR2(1)    ,
     SUBJECT_TYPE                 VARCHAR2(30)   :=  'T' ,
---Added (End) for m-to-m enhancements
     OBJECT_ID                    NUMBER         ,
---Added (Start) for m-to-m enhancements
     OBJECT_INDEX_FLAG            VARCHAR2(1)    ,
     OBJECT_TYPE                  VARCHAR2(30)   :=  'T' ,
---Added (End) for m-to-m enhancements
-- Added for CZ Integration (Begin)
     SUB_CONFIG_INST_HDR_ID	  NUMBER         ,
     SUB_CONFIG_INST_REV_NUM      NUMBER         ,
     SUB_CONFIG_INST_ITEM_ID      NUMBER         ,
     OBJ_CONFIG_INST_HDR_ID       NUMBER         ,
     OBJ_CONFIG_INST_REV_NUM      NUMBER         ,
     OBJ_CONFIG_INST_ITEM_ID      NUMBER         ,
     TARGET_COMMITMENT_DATE	  DATE           ,
     API_CALLER_IDENTITY          VARCHAR2(15)  ,
-- Added for CZ Integration (End)
     RELATIONSHIP_TYPE_CODE       VARCHAR2(30)   ,
     DISPLAY_ORDER                NUMBER         ,
     POSITION_REFERENCE           VARCHAR2(30)   ,
     MANDATORY_FLAG               VARCHAR2(1)    ,
     ACTIVE_START_DATE            DATE           ,
     ACTIVE_END_DATE              DATE           ,
     CONTEXT                      VARCHAR2(30)   ,
     ATTRIBUTE1                   VARCHAR2(150)  ,
     ATTRIBUTE2                   VARCHAR2(150)  ,
     ATTRIBUTE3                   VARCHAR2(150)  ,
     ATTRIBUTE4                   VARCHAR2(150)  ,
     ATTRIBUTE5                   VARCHAR2(150)  ,
     ATTRIBUTE6                   VARCHAR2(150)  ,
     ATTRIBUTE7                   VARCHAR2(150)  ,
     ATTRIBUTE8                   VARCHAR2(150)  ,
     ATTRIBUTE9                   VARCHAR2(150)  ,
     ATTRIBUTE10                  VARCHAR2(150)  ,
     ATTRIBUTE11                  VARCHAR2(150)  ,
     ATTRIBUTE12                  VARCHAR2(150)  ,
     ATTRIBUTE13                  VARCHAR2(150)  ,
     ATTRIBUTE14                  VARCHAR2(150)  ,
     ATTRIBUTE15                  VARCHAR2(150)  ,
     OBJECT_VERSION_NUMBER        NUMBER         );

  TYPE txn_ii_rltns_tbl IS TABLE OF txn_ii_rltns_rec  INDEX BY BINARY_INTEGER;


  -- Name         : txn_org_assgn_rec
  -- Type         : type definition, group
  -- Description  : record to hold information about an transaction
  --                details-org association.

  TYPE txn_org_assgn_rec IS RECORD (
     TXN_OPERATING_UNIT_ID        NUMBER         ,
     TXN_LINE_DETAIL_ID           NUMBER         ,
     INSTANCE_OU_ID               NUMBER         ,
     OPERATING_UNIT_ID            NUMBER         ,
     RELATIONSHIP_TYPE_CODE       VARCHAR2(30)   ,
     ACTIVE_START_DATE            DATE           ,
     ACTIVE_END_DATE              DATE           ,
     PRESERVE_DETAIL_FLAG         VARCHAR2(1)    ,
     CONTEXT                      VARCHAR2(30)   ,
     ATTRIBUTE1                   VARCHAR2(150)  ,
     ATTRIBUTE2                   VARCHAR2(150)  ,
     ATTRIBUTE3                   VARCHAR2(150)  ,
     ATTRIBUTE4                   VARCHAR2(150)  ,
     ATTRIBUTE5                   VARCHAR2(150)  ,
     ATTRIBUTE6                   VARCHAR2(150)  ,
     ATTRIBUTE7                   VARCHAR2(150)  ,
     ATTRIBUTE8                   VARCHAR2(150)  ,
     ATTRIBUTE9                   VARCHAR2(150)  ,
     ATTRIBUTE10                  VARCHAR2(150)  ,
     ATTRIBUTE11                  VARCHAR2(150)  ,
     ATTRIBUTE12                  VARCHAR2(150)  ,
     ATTRIBUTE13                  VARCHAR2(150)  ,
     ATTRIBUTE14                  VARCHAR2(150)  ,
     ATTRIBUTE15                  VARCHAR2(150)  ,
     TXN_LINE_DETAILS_INDEX       NUMBER         ,
     OBJECT_VERSION_NUMBER        NUMBER         );

  TYPE txn_org_assgn_tbl IS TABLE OF txn_org_assgn_rec INDEX BY BINARY_INTEGER;


  -- Name         : txn_ext_attrib_vals_rec
  -- Type         : type definition, group
  -- Description  : record to hold the values of a transaction detail's
  --                extended attributes.

  TYPE txn_ext_attrib_vals_rec IS RECORD(
    TXN_ATTRIB_DETAIL_ID         NUMBER         ,
    TXN_LINE_DETAIL_ID           NUMBER         ,
    ATTRIB_SOURCE_TABLE          VARCHAR2(30)   ,
    ATTRIBUTE_SOURCE_ID          NUMBER         ,
    ATTRIBUTE_VALUE              VARCHAR2(240)  ,
-- Added for CZ Integration (Begin)
    ATTRIBUTE_CODE               VARCHAR2(30)   ,
    ATTRIBUTE_LEVEL              VARCHAR2(15)   ,
    API_CALLER_IDENTITY          VARCHAR2(15)   ,
-- Added for CZ Integration (End)
    PROCESS_FLAG                 VARCHAR2(30)   ,
    ACTIVE_START_DATE            DATE           ,
    ACTIVE_END_DATE              DATE           ,
    PRESERVE_DETAIL_FLAG         VARCHAR2(1)    ,
    CONTEXT                      VARCHAR2(30)   ,
    ATTRIBUTE1                   VARCHAR2(150)  ,
    ATTRIBUTE2                   VARCHAR2(150)  ,
    ATTRIBUTE3                   VARCHAR2(150)  ,
    ATTRIBUTE4                   VARCHAR2(150)  ,
    ATTRIBUTE5                   VARCHAR2(150)  ,
    ATTRIBUTE6                   VARCHAR2(150)  ,
    ATTRIBUTE7                   VARCHAR2(150)  ,
    ATTRIBUTE8                   VARCHAR2(150)  ,
    ATTRIBUTE9                   VARCHAR2(150)  ,
    ATTRIBUTE10                  VARCHAR2(150)  ,
    ATTRIBUTE11                  VARCHAR2(150)  ,
    ATTRIBUTE12                  VARCHAR2(150)  ,
    ATTRIBUTE13                  VARCHAR2(150)  ,
    ATTRIBUTE14                  VARCHAR2(150)  ,
    ATTRIBUTE15                  VARCHAR2(150)  ,
    TXN_LINE_DETAILS_INDEX       NUMBER         ,
    OBJECT_VERSION_NUMBER        NUMBER         );


  TYPE txn_ext_attrib_vals_tbl IS TABLE OF txn_ext_attrib_vals_rec  INDEX BY BINARY_INTEGER;

  -- Name         : csi_ext_attribs_rec
  -- Type         : type definition, group
  -- Description  : record to hold the item's extended attributes as defined
  --                in the core installed base (csi_i_extend_attribs)

  TYPE csi_ext_attribs_rec IS RECORD(
    ATTRIBUTE_ID              NUMBER        ,
    ATTRIBUTE_LEVEL           VARCHAR2(15)  ,
    MASTER_ORGANIZATION_ID    NUMBER        ,
    INVENTORY_ITEM_ID         NUMBER        ,
    ITEM_CATEGORY_ID          NUMBER        ,
    INSTANCE_ID               NUMBER        ,
    ATTRIBUTE_CODE            VARCHAR2(30)  ,
    ATTRIBUTE_NAME            VARCHAR2(50)  ,
    ATTRIBUTE_CATEGORY        VARCHAR2(30)  ,
    DESCRIPTION               VARCHAR2(240) ,
    ACTIVE_START_DATE         DATE          ,
    ACTIVE_END_DATE           DATE          ,
    CONTEXT                   VARCHAR2(30)  ,
    ATTRIBUTE1                VARCHAR2(150) ,
    ATTRIBUTE2                VARCHAR2(150) ,
    ATTRIBUTE3                VARCHAR2(150) ,
    ATTRIBUTE4                VARCHAR2(150) ,
    ATTRIBUTE5                VARCHAR2(150) ,
    ATTRIBUTE6                VARCHAR2(150) ,
    ATTRIBUTE7                VARCHAR2(150) ,
    ATTRIBUTE8                VARCHAR2(150) ,
    ATTRIBUTE9                VARCHAR2(150) ,
    ATTRIBUTE10               VARCHAR2(150) ,
    ATTRIBUTE11               VARCHAR2(150) ,
    ATTRIBUTE12               VARCHAR2(150) ,
    ATTRIBUTE13               VARCHAR2(150) ,
    ATTRIBUTE14               VARCHAR2(150) ,
    ATTRIBUTE15               VARCHAR2(150) ,
    OBJECT_VERSION_NUMBER     NUMBER        );

  TYPE csi_ext_attribs_tbl IS TABLE OF csi_ext_attribs_rec  INDEX BY BINARY_INTEGER;


  -- Name        : csi_ext_attrib_vals_rec
  -- Description : record to hold the values of an item instances
  --               extended attribute values.

  TYPE csi_ext_attrib_vals_rec IS RECORD(
    ATTRIBUTE_VALUE_ID      NUMBER         ,
    INSTANCE_ID             NUMBER         ,
    ATTRIBUTE_ID            NUMBER         ,
    ATTRIBUTE_VALUE         VARCHAR2(240)  ,
    ACTIVE_START_DATE       DATE           ,
    ACTIVE_END_DATE         DATE           ,
    CONTEXT                 VARCHAR2(30)   ,
    ATTRIBUTE1              VARCHAR2(150)  ,
    ATTRIBUTE2              VARCHAR2(150)  ,
    ATTRIBUTE3              VARCHAR2(150)  ,
    ATTRIBUTE4              VARCHAR2(150)  ,
    ATTRIBUTE5              VARCHAR2(150)  ,
    ATTRIBUTE6              VARCHAR2(150)  ,
    ATTRIBUTE7              VARCHAR2(150)  ,
    ATTRIBUTE8              VARCHAR2(150)  ,
    ATTRIBUTE9              VARCHAR2(150)  ,
    ATTRIBUTE10             VARCHAR2(150)  ,
    ATTRIBUTE11             VARCHAR2(150)  ,
    ATTRIBUTE12             VARCHAR2(150)  ,
    ATTRIBUTE13             VARCHAR2(150)  ,
    ATTRIBUTE14             VARCHAR2(150)  ,
    ATTRIBUTE15             VARCHAR2(150)  ,
    OBJECT_VERSION_NUMBER   NUMBER         );

  TYPE csi_ext_attrib_vals_tbl IS TABLE OF csi_ext_attrib_vals_rec  INDEX BY BINARY_INTEGER;


  -- Name         : txn_line_detail_ids_rec
  -- Type         : type definition, group
  -- Description  : record to hold internal id values of the txn line details

  TYPE txn_line_detail_ids_rec IS RECORD
  (
     TRANSACTION_LINE_ID          NUMBER         ,
     TXN_LINE_DETAIL_ID           NUMBER
  );

  TYPE txn_line_detail_ids_tbl IS TABLE OF txn_line_detail_ids_rec INDEX BY BINARY_INTEGER;

  -- Name         : txn_party_ids_rec
  -- Type         : type definition, group
  -- Description  : record to hold internal id values of the instance
  --                party relationship

  TYPE txn_party_ids_rec IS RECORD
  (
     TXN_PARTY_DETAIL_ID          NUMBER         ,
     TXN_LINE_DETAIL_ID           NUMBER
  );

  TYPE txn_party_ids_tbl IS TABLE OF txn_party_ids_rec INDEX BY BINARY_INTEGER;


  -- Name         : txn_pty_acct_ids_rec
  -- Type         : type definition, group
  -- Description  : record to hold internal id values of the instance
  --                accounts

  TYPE txn_pty_acct_ids_rec IS RECORD
  (
     TXN_ACCOUNT_DETAIL_ID        NUMBER         ,
     TXN_PARTY_DETAIL_ID          NUMBER         ,
     TXN_LINE_DETAIL_ID           NUMBER
  );

  TYPE txn_pty_acct_ids_tbl IS TABLE OF txn_pty_acct_ids_rec INDEX BY BINARY_INTEGER;


  -- Name         : txn_ii_rltns_ids_rec
  -- Type         : type definition, group
  -- Description  : record to hold internal id values of the
  --                instance-instance relationships

  TYPE txn_ii_rltns_ids_rec IS RECORD
  (
     TXN_RELATIONSHIP_ID         NUMBER         ,
     TRANSACTION_LINE_ID         NUMBER
  );

  TYPE txn_ii_rltns_ids_tbl IS TABLE OF txn_ii_rltns_ids_rec  INDEX BY BINARY_INTEGER;


  -- Name         : txn_org_assgn_ids_rec
  -- Type         : type definition, group
  -- Description  : record to hold internal id values of the instance
  --                org assignments

  TYPE txn_org_assgn_ids_rec IS RECORD
  (
     TXN_OPERATING_UNIT_ID        NUMBER         ,
     TXN_LINE_DETAIL_ID           NUMBER
  );

  TYPE txn_org_assgn_ids_tbl IS TABLE OF txn_org_assgn_ids_rec  INDEX BY BINARY_INTEGER;


  -- Name         : txn_ext_attrib_ids_rec
  -- Type         : type definition, group
  -- Description  : record to hold internal id values of the extended
  --                attributes

  TYPE txn_ext_attrib_ids_rec IS RECORD
  (
     TXN_ATTRIB_DETAIL_ID         NUMBER         ,
     TXN_LINE_DETAIL_ID           NUMBER
  );

  TYPE txn_ext_attrib_ids_tbl IS TABLE OF txn_ext_attrib_ids_rec INDEX BY BINARY_INTEGER;

  -- Name         : txn_line_query_rec
  -- Description  : This record structure holds the possible query criteria
  --                for transaction line

  TYPE txn_line_query_rec IS RECORD(
    TRANSACTION_LINE_ID         NUMBER        ,
---Added (Start) for m-to-m enhancements
    SOURCE_TRANSACTION_TYPE_ID  NUMBER        ,
    SOURCE_TXN_HEADER_ID        NUMBER        ,
---Added (End) for m-to-m enhancements
    SOURCE_TRANSACTION_ID       NUMBER        ,
    SOURCE_TRANSACTION_TABLE    VARCHAR2(30)  ,
-- Added for CZ Integration (Begin)
    CONFIG_SESSION_HDR_ID       NUMBER         ,
    CONFIG_SESSION_REV_NUM      NUMBER         ,
    CONFIG_SESSION_ITEM_ID      NUMBER         ,
    API_CALLER_IDENTITY         VARCHAR2(15)   ,
-- Added for CZ Integration (End)
    PROCESSING_STATUS           VARCHAR2(30)  ,
    ERROR_CODE                  VARCHAR2(240) ,
    ERROR_EXPLANATION           VARCHAR2(240) );


  -- Name         : txn_line_detail_query_rec
  -- Description  : This record structure holds the possible query criteria
  --                for transaction line detail

  TYPE txn_line_detail_query_rec IS RECORD(
    TRANSACTION_LINE_ID         NUMBER        ,
    TXN_LINE_DETAIL_ID          NUMBER        ,
    SUB_TYPE_ID                 NUMBER        ,
    CSI_TRANSACTION_ID          NUMBER        ,
    SOURCE_TRANSACTION_FLAG     VARCHAR2(1)   ,
    INSTANCE_ID                 NUMBER        ,
    INSTANCE_EXISTS_FLAG        VARCHAR2(1)   ,
    CSI_SYSTEM_ID               NUMBER        ,
    TRANSACTION_SYSTEM_ID       NUMBER        ,
    INV_ORGANIZATION_ID         NUMBER        ,
    INVENTORY_ITEM_ID           NUMBER        ,
    INVENTORY_REVISION          VARCHAR2(3)   ,
    SERIAL_NUMBER               VARCHAR2(30)  ,
    MFG_SERIAL_NUMBER_FLAG      VARCHAR2(1)   ,
    LOT_NUMBER                  VARCHAR2(30)  ,
    LOCATION_TYPE_CODE          VARCHAR2(30)  ,
    EXTERNAL_REFERENCE          VARCHAR2(30)  ,
    RETURN_BY_DATE              DATE          ,
    REFERENCE_SOURCE_ID         NUMBER        ,
    PROCESSING_STATUS           VARCHAR2(30)  ,
    ERROR_CODE                  VARCHAR2(240) ,
    ERROR_EXPLANATION           VARCHAR2(240) );

 -----------------------------------------------------------------------
 -----------------------------------------------------------------------

 TYPE config_query_record IS RECORD(
    config_header_id         NUMBER ,
    config_revision_number   NUMBER );

 TYPE config_query_table IS TABLE OF config_query_record INDEX BY BINARY_INTEGER;

 TYPE config_rec IS RECORD
 (
    source_application_id  NUMBER,
    source_txn_header_ref  VARCHAR2(30),
    source_txn_line_ref1   VARCHAR2(30),
    source_txn_line_ref2   VARCHAR2(30),
    source_txn_line_ref3   VARCHAR2(30),
    instance_id            NUMBER,
    lock_id                NUMBER,
    lock_status            NUMBER,
    config_inst_hdr_id     NUMBER,
    config_inst_item_id    NUMBER,
    config_inst_rev_num    NUMBER
 );

 m_config_rec config_rec;

 TYPE config_pair_record IS RECORD(
    subject_header_id        number ,
    subject_revision_number  number ,
    subject_item_id          number ,
    object_header_id         number ,
    object_revision_number   number ,
    object_item_id           number ,
    root_header_id           number ,
    root_revision_number     number ,
    root_item_id             number ,
    source_application_id    number ,
    source_txn_header_ref    varchar2(30),
    source_txn_line_ref1     varchar2(30),
    source_txn_line_ref2     varchar2(30),
    source_txn_line_ref3     varchar2(30),
    lock_id                  number ,
    lock_status              number);

  TYPE config_pair_table IS TABLE OF config_pair_record INDEX BY BINARY_INTEGER;

  -- used for outputing in generate_config_trees and add_to_config_tree procedures
  TYPE config_model_rec_type IS RECORD
  (
    inventory_item_id  NUMBER,
    organization_id    NUMBER,
    config_hdr_id      NUMBER,
    config_rev_nbr     NUMBER,
    config_item_id     NUMBER
  );
  TYPE config_model_tbl_type IS TABLE OF config_model_rec_type INDEX BY BINARY_INTEGER;

 -----------------------------------------------------------------------
 -----------------------------------------------------------------------

  m_txn_line_rec                txn_line_rec;
  m_txn_line_detail_tbl         txn_line_detail_tbl;
  m_txn_ext_attrib_vals_tbl     txn_ext_attrib_vals_tbl;
  m_txn_ii_rltns_tbl            txn_ii_rltns_tbl;

  m_config_query_table          config_query_table;
  m_config_pair_table           config_pair_table;
  m_config_rev_number           NUMBER;

  m_msg_count                   NUMBER;
  m_msg_data                    VARCHAR2(2000);
  m_return_status               VARCHAR2(255);
  m_return_message              VARCHAR2(2000);

  DEBUG_OUTPUT  CONSTANT VARCHAR2(255):='OUTPUT';
  DEBUG_DB      CONSTANT VARCHAR2(255):='DATABASE';

  DEBUG_MODE    VARCHAR2(255):=DEBUG_OUTPUT;
  ERROR_CODE    VARCHAR2(50):='0000';


  TYPE int_array_tbl_type       IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE int_array_tbl_type_idx_vc2 IS TABLE OF NUMBER INDEX BY VARCHAR2(15);--  Bug 6892148;
  TYPE char_array_tbl_type      IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  TYPE char_array_tbl_type_idx_vc2 IS TABLE OF VARCHAR2(2000) INDEX BY VARCHAR2(15);--  Bug 6892148;
  TYPE long_char_array_tbl_type IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  TYPE date_array_tbl_type      IS TABLE OF DATE INDEX BY BINARY_INTEGER;

  m_config_hdr_tbl           int_array_tbl_type;
  m_config_rev_nbr_tbl       int_array_tbl_type;
  m_config_item_tbl          int_array_tbl_type;
  m_attribute_category_tbl   long_char_array_tbl_type;
  m_attribute_name_tbl       long_char_array_tbl_type;
  m_attribute_value_tbl      long_char_array_tbl_type;
  m_location_id_tbl          int_array_tbl_type;
  m_instance_description_tbl long_char_array_tbl_type;
  m_csi_rev_nbr_tbl          int_array_tbl_type_idx_vc2;--  Bug 6892148;

  m_COUNTER  NUMBER;

  --
  -- define transaction type for CZ/IB transactions
  -- value has been suggested by IB team
  --
  CZ_TRANSACTION_TYPE_ID     CONSTANT INTEGER      := 401;

  INCOMPLETE_CONFIG_STATUS   CONSTANT VARCHAR2(50) := '1';
  COMPLETE_CONFIG_STATUS     CONSTANT VARCHAR2(50) := '2';

  --
  -- define types of relationships for using in IB
  --
  CONNECTED_TO_RELATIONSHIP    CONSTANT VARCHAR2(50) := 'CONNECTED-TO';
  COMPONENT_OF_RELATIONSHIP    CONSTANT VARCHAR2(50) := 'COMPONENT-OF';
  --
  -- define source transaction table or subschema
  -- for CZ/IB transactions
  --
  CZ_IB_TRANSACTION_TABLE    CONSTANT VARCHAR2(50) := 'CONFIGURATOR';
  DISCONTINUE_ACTION_TYPE    CONSTANT NUMBER:=4;

  YES_FLAG                   CONSTANT VARCHAR2(1)  := '1';
  NO_FLAG                    CONSTANT VARCHAR2(1)  := '0';

  --
  -- global variable ( session level ) that stores value of p_Effective_Date parameter
  --
  m_EFFECTIVE_DATE    DATE;

  --
  -- global variable to store a value from APPS profile "CZ_IB_AUTO_EXPIRATION"
  --
  m_CZ_IB_AUTO_EXPIRATION VARCHAR2(255):='Y';

  --
  --  CZ_DB_LOGS.run_id
  --
  m_RUN_ID            NUMBER;


  --
  -- delete IB data
  --
  PROCEDURE remove_IB_Config
  (
  p_session_config_hdr_id  IN  NUMBER DEFAULT NULL,
  p_session_config_rev_nbr IN  NUMBER DEFAULT NULL,
  p_instance_hdr_id        IN  NUMBER DEFAULT NULL,
  p_instance_rev_nbr       IN  NUMBER DEFAULT NULL,
  p_instance_item_id       IN  NUMBER DEFAULT NULL,
  x_run_id                 OUT NOCOPY NUMBER
  );


  --
  -- INSERT/UPDATE data IN IB Repository based ON the changes  OF  configuration items IN CZ --
  --
  PROCEDURE Update_Instances
  (
  p_config_instance_tbl    IN   SYSTEM.cz_config_instance_tbl_type,
  p_effective_date         IN   DATE,
  p_txn_type_id            IN   NUMBER,
  x_run_id                 OUT NOCOPY  NUMBER
  );

  /**
    * The method will UPDATE the status OF the IB instance
    * <=> CSI_T_TRANSACTION_LINES. CONFIG_VALID_STATUS / CSI_ITEM_INSTANCES. CONFIG_VALID_STATUS TO be INVALID
    * IF either the CZ_CONFIG_HDRS.config_status field IS SET TO INCOMPLETE OR
    * the CZ_CONFIG_HDRS.has_failures field IS SET TO TRUE, otherwise, it will be SET TO VALID
    */

  PROCEDURE Update_Instances_Status
  (
  p_config_instance_tbl   IN   SYSTEM.cz_config_instance_tbl_type,
  x_run_id                 OUT NOCOPY  NUMBER
  );

  /**
    * RETURN ARRAY OF attributes OF config items FROM subtree that starts WITH
    * config item  (p_config_hdr_id,p_config_rev_nbr,p_config_item_id)
   */
  PROCEDURE  Synchronize_Attributes
  (
  p_config_hdr_id            IN  NUMBER,
  p_config_rev_nbr           IN  NUMBER,
  p_install_rev_nbr          IN  NUMBER,
  p_config_item_id           IN  NUMBER,
  x_config_attribute_tbl     OUT NOCOPY SYSTEM.cz_config_attribute_tbl_type,
  x_txn_params_tbl           OUT NOCOPY SYSTEM.cz_txn_params_tbl_type,
  x_run_id   	           OUT NOCOPY INTEGER
  );

  /**
    * check_CZIB_Item PROCEDURE sets x_in_txn TO '1' IF config item
    * (p_config_hdr_id, p_config_rev_nbr, p_config_item_id)
    * EXISTS IN IB Transactions subschema
    * AND sets x_in_inst TO '1' IF config item
    * (p_config_hdr_id, p_config_rev_nbr, p_config_item_id)
    * EXISTS IN IB Instances subschema,
    * otherwise x_in_txn='0' AND   x_in_inst='0'
    */

  PROCEDURE check_CZIB_Item
  (
  p_config_hdr_id   IN  NUMBER,
  p_config_rev_nbr  IN  NUMBER,
  p_config_item_id  IN  NUMBER,
  x_in_txn          OUT NOCOPY VARCHAR2,
  x_in_inst         OUT NOCOPY VARCHAR2
  );

  /**
    * wrapper FOR CZ_IB_WRAPPERS.Get_Configuration_Revision() PROCEDURE
    *
    * 1.	IF LEVEL IS "Installed", retrieve the "Revision Number" FROM CSI_Item_Instances
    *     FOR the Config_Header_Id passed.
    * 2.	IF LEVEL IS NULL OR "PENDING", THEN
    *     a.	Retrive the "Revision Number" FROM Csi_Item_Instances FOR the given Config_Header_Id.
    *     b.	CHECK IN Transcation Details, IF there IS a revision ON TRANSACTION details
    *         FOR the config_Header_ID, which IS NOT a base revision ON ANY other line IN TRANSACTION details.
    *     c.	IF a revision IS FOUND THEN RETURN Revision AND the LEVEL AS PENDING,
    *         otherwise RETURN the revision FROM the Csi_Item_Instances AND LEVEL AS INSTALLED.
    */
  PROCEDURE Get_Configuration_Revision
  (
  p_Config_Header_Id	    IN      NUMBER,
  p_target_commitment_date  IN      DATE,
  px_Instance_Level         IN OUT NOCOPY  VARCHAR2,
  x_config_rec              OUT NOCOPY     SYSTEM.CZ_CONFIG_REC,
  x_run_id                  OUT NOCOPY     NUMBER
  );

  /**
    * wrapper FOR CSI_CZ_INT.Get_Connected_Configurations() PROCEDURE
    */
  PROCEDURE Get_Connected_Configurations
  (
  p_Config_Query_Table 	IN  SYSTEM.cz_config_query_table,
  p_Instance_Level	IN  VARCHAR2,
  x_Config_Pair_Table	OUT  NOCOPY SYSTEM.cz_config_pair_table,
  x_run_id              OUT NOCOPY NUMBER
  );

  /**
    * this PROCEDURE IS used IN order TO CREATE IB data FOR
    * the copied model
    */
  PROCEDURE clone_IB_Data
  (
  p_config_hdr_id  IN  NUMBER,
  p_config_rev_nbr IN  NUMBER,
  x_run_id         OUT NOCOPY NUMBER
  );

  /**
    * test Update_Instances() PROCEDURE
    */
  PROCEDURE Test_Update_Instances
  (
  p_instance_hdr_id  NUMBER,
  p_config_item_id   NUMBER,
  p_old_rev_nbr      NUMBER,
  p_new_rev_nbr      NUMBER
  );

  PROCEDURE Test_Connected_Configurations;

  PROCEDURE Test_Configuration_Revision
  (
  p_config_hdr_id IN NUMBER
  );

  PROCEDURE LOG_REPORT
  (p_run_id        IN VARCHAR2,
   p_error_message IN VARCHAR2,
   p_count         IN NUMBER);

END CZ_IB_TRANSACTIONS;

/
