--------------------------------------------------------
--  DDL for Package EGO_ITEM_ASSOCIATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_ASSOCIATIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOPIASS.pls 120.6.12010000.2 2011/07/14 13:07:06 nendrapu ship $ */

  G_ITEM_LEVEL                   CONSTANT NUMBER       := 43101;
  G_ITEM_SUPPLIER_LEVEL          CONSTANT NUMBER       := 43103;
  G_ITEM_SUPPLIERSITE_LEVEL      CONSTANT NUMBER       := 43104;
  G_ITEM_SUPPLIERSITE_ORG_LEVEL  CONSTANT NUMBER       := 43105;

  G_ITEM_LEVEL_NAME              CONSTANT VARCHAR2(20) := 'ITEM_LEVEL';
  G_ITEM_SUP_LEVEL_NAME          CONSTANT VARCHAR2(20) := 'ITEM_SUP';
  G_ITEM_SUP_SITE_LEVEL_NAME     CONSTANT VARCHAR2(20) := 'ITEM_SUP_SITE';
  G_ITEM_SUP_SITE_ORG_LEVEL_NAME CONSTANT VARCHAR2(20) := 'ITEM_SUP_SITE_ORG';

  G_ASSIGN_PACK_SUPPLIER         CONSTANT VARCHAR2(50) := 'EGO_ASSIGN_PACK_SUPPLIER';
  G_ASSIGN_PACK_SUP_SITE         CONSTANT VARCHAR2(50) := 'EGO_ASSIGN_PACK_SUP_SITE';
  G_ASSIGN_PACK_SS_ORG           CONSTANT VARCHAR2(50) := 'EGO_ASSIGN_PACK_SS_ORG';
  G_ASSIGN_STYLE_SUP_SUPSITE     CONSTANT VARCHAR2(50) := 'EGO_DEFAULT_STYLE_SUP_AND_SUP_SITE';
  --G_ASSIGN_STYLE_SUP_SITE        CONSTANT VARCHAR2(50) := 'EGO_DEFAULT_STYLE_SUP_SITE';
  G_ASSIGN_STYLE_SS_ORG          CONSTANT VARCHAR2(50) := 'EGO_DEFAULT_STYLE_SUP_SITE_ORG';

  G_ACTIVE                       CONSTANT NUMBER       := 1;

  G_RET_STS_WARNING              CONSTANT VARCHAR2(1)  := 'W';

  G_VALID_LEVEL_INPUT            CONSTANT NUMBER       := 70; -- Input Validation + Business Validation
  G_VALID_LEVEL_BUSINESS         CONSTANT NUMBER       := 50; -- Business Validation
  G_DEFAULT_STATUS_CODE          CONSTANT NUMBER       := 1; -- Active
  G_DEFAULT_PRIMARY_FLAG         CONSTANT VARCHAR2(1)  := 'N'; -- Not a Primary
  G_PRIMARY                      CONSTANT VARCHAR2(1)  := 'Y';


  G_CREATE                       CONSTANT VARCHAR2(10) := 'CREATE';
  G_UPDATE                       CONSTANT VARCHAR2(10) := 'UPDATE';
  G_DELETE                       CONSTANT VARCHAR2(10) := 'DELETE';
  G_SYNC                         CONSTANT VARCHAR2(10) := 'SYNC';

  G_VALID_LEVEL_INPUT            CONSTANT NUMBER       := 70; -- Input Validation + Business Validation
  G_VALID_LEVEL_BUSINESS         CONSTANT NUMBER       := 50; -- Business Validation
  G_SUPPLIER_OBJ_NAME            CONSTANT VARCHAR2(20) := 'PO_VENDORS';
  G_SUPPLIER_SITE_OBJ_NAME       CONSTANT VARCHAR2(20) := 'PO_VENDOR_SITES_ALL';
  G_PACK_STR_NAME                CONSTANT VARCHAR2(10) := 'PIM_PBOM_S';


  -- Standard Process Flags
  G_REC_BEFORE_MATCH             CONSTANT NUMBER       := 0;
  G_REC_TO_BE_PROCESSED          CONSTANT NUMBER       := 1;
  G_REC_IN_PROCESS               CONSTANT NUMBER       := 2;
  G_REC_ERROR                    CONSTANT NUMBER       := 3;
  G_REC_VAL_ID_CONVERTED         CONSTANT NUMBER       := 4;
  G_REC_SUCCESS                  CONSTANT NUMBER       := 7;

  -- Error Process Flags

  G_REC_UNEXPECTED_ERROR         CONSTANT NUMBER       := 999;
  G_REC_MISSING_REQ_VALUE        CONSTANT NUMBER       := 1001;
  G_REC_INVALID_TRAN_TYPE        CONSTANT NUMBER       := 1002;
  G_REC_INVALID_ORG              CONSTANT NUMBER       := 1003;
  G_REC_INVALID_MASTER_ORG       CONSTANT NUMBER       := 1004;
  G_REC_INVALID_ITEM             CONSTANT NUMBER       := 1005;
  G_REC_INVALID_PK1_VALUE        CONSTANT NUMBER       := 1006;
  G_REC_INVALID_PK2_VALUE        CONSTANT NUMBER       := 1007;
  G_REC_INVALID_ASSOC_TYPE       CONSTANT NUMBER       := 1008;
  G_REC_INVALID_STATUS           CONSTANT NUMBER       := 1009;
  G_REC_INVALID_PRIMARY          CONSTANT NUMBER       := 1010;
  G_REC_ORG_NO_ACCESS            CONSTANT NUMBER       := 1101;
  G_REC_ASSOCIATION_NOT_EXISTS   CONSTANT NUMBER       := 1102;
  G_REC_ALREADY_ASSIGNED         CONSTANT NUMBER       := 1103;
  G_REC_ASSOC_SITE_NOT_EXISTS    CONSTANT NUMBER       := 1104;
  G_REC_ASSOC_ITEM_NOT_IN_ORG    CONSTANT NUMBER       := 1105;
  G_REC_PARENT_NOT_ASSIGNED      CONSTANT NUMBER       := 1106;
  G_REC_PRIMARY_NOT_ACTIVE       CONSTANT NUMBER       := 1107;
  G_REC_DUPLICATE                CONSTANT NUMBER       := 1108;
  G_REC_NO_CREATE_ASSOC_PRIV     CONSTANT NUMBER       := 1109;
  G_REC_NO_EDIT_ASSOC_PRIV       CONSTANT NUMBER       := 1110;
  G_REC_NO_SUPPL_ACCESS_PRIV     CONSTANT NUMBER       := 1111;
  G_REC_SUPPLIER_NOT_ASSIGNED    CONSTANT NUMBER       := 1112;
  G_REC_SITE_NOT_ASSIGNED        CONSTANT NUMBER       := 1113;
  G_REC_DUPLICATE_PRIMARY        CONSTANT NUMBER       := 1114;
  G_REC_PARENT_NOT_ACTIVE        CONSTANT NUMBER       := 1115;
  G_REC_NO_EDIT_ITEM_ORG_PRIV    CONSTANT NUMBER       := 1116;

  -- Warning Process Flag

  G_REC_STATUS_PROPAGATED        CONSTANT NUMBER       := 2001;

  -- Table of Numbers (For Organizations and Items) - Used in Private

  TYPE VARCHAR2_TBL_TYPE IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;

  -- Start of comments
  --  API name    : pre_process
  --  Type        : Private.
  --  Function    :
  --  Pre-reqs    : None
  --  Parameters  :
  --  IN          : p_api_version       IN NUMBER Required
  --                p_batch_id          IN NUMBER Required
  --  OUT         : x_return_status     OUT NOCOPY VARCHAR2(1)
  --                x_msg_data          OUT NOCOPY VARCHAR2(2000)
  --  Version     : Initial version     1.0
  --  Notes       : Converts the processing independent values to Ids
  --                 a) Master Org Code and Master Org Id for ITEM_SUP and ITEM_SUP_SITE
  --                 b) Org Code and Org Id for ITEM_SUP_SITE_ORG
  --                 c) Convert Pk1_Name and Pk2_Name
  --                 d) Convert existing item numbers to item ids and vice versa
  --                 e) Convert transaction type SYNC to CREATE/UPDATE
  -- End of comments
  PROCEDURE pre_process
  (
    p_api_version       IN NUMBER
    ,p_batch_id         IN NUMBER
    ,x_return_status    OUT NOCOPY VARCHAR2
    ,x_msg_count        OUT NOCOPY NUMBER
    ,x_msg_data         OUT NOCOPY VARCHAR2
  );

  -- Start of comments
  --  API name    : import_item_associations
  --  Type        : Public.
  --  Function    : Imports the item associations into the systems.
  --  Pre-reqs    :
  --                 i) Rows needs to be populated in EGO.EGO_ITEM_ASSOCIATIONS_INTF if the data is not from temp tables.
  --                ii) Errors will be grouped based on concurrent program's request id.
  --  Parameters  :
  --  IN          : p_api_version       IN NUMBER Required
  --  IN OUT      : x_batch_id          IN OUT NOCOPY Optional
  --  OUT         : x_return_status     OUT NOCOPY VARCHAR2(1)
  --                x_msg_count         OUT NOCOPY NUMBER
  --                x_msg_data          OUT NOCOPY VARCHAR2(2000)
  --  Version     : Current version   1.0
  --                Initial version   1.0
  --  Notes       :
  --                x_batch_id          IN OUT NOCOPY Optional if p_data_from_temp_table is not set
  --                                    Returns batch_id of the batch if its not passed.
  --                x_return_status     OUT NOCOPY VARCHAR2 Return status of the program
  --                                    S - Success, E - Error, U - Unexpected Error
  --                x_msg_data          OUT NOCOPY VARCHAR2 Error Message Data if the message stack has one message else null.
  -- End of comments
  PROCEDURE import_item_associations
  (
      p_api_version    IN   NUMBER
      ,x_batch_id      IN OUT NOCOPY VARCHAR2
      ,x_return_status OUT NOCOPY VARCHAR2
      ,x_msg_count     OUT NOCOPY NUMBER
      ,x_msg_data      OUT NOCOPY VARCHAR2
  );

  -- Start of comments
  --  API name    : import_item_associations
  --  Type        : private.
  --  Function    : Imports the item associations in the excel import flow.
  --  Pre-reqs    :
  --                 i) Rows needs to be populated in EGO.EGO_ITEM_ASSOCIATIONS_INTF if the data is not from temp tables.
  --                ii) Errors will be grouped based on concurrent program's request id.
  --  Parameters  :
  --  IN          : p_api_version       IN NUMBER Required
  --  IN OUT      : x_batch_id          IN OUT NOCOPY Optional
  --  OUT         : x_errbuf            OUT NOCOPY VARCHAR2
  --                x_retcode           OUT NOCOPY VARCHAR2
  --  Version     : Current version   1.0
  --                Initial version   1.0
  --  Notes       :
  --                x_errbuf          Returns the single error message if it is else null.
  --                x_retcode         0 - Success, 1 - Warning, 2 - Error
  -- End of comments
  PROCEDURE import_item_associations
  (
      p_api_version    IN   NUMBER
      ,x_batch_id      IN OUT NOCOPY VARCHAR2
      ,x_errbuf        OUT NOCOPY VARCHAR2
      ,x_retcode       OUT NOCOPY VARCHAR2
  );


  -- Start of comments
  --  API name    : copy_associations_to_items
  --  Type        : Private.
  --  Function    : Insert interface rows for associations of the items
  --                for which the copy_item_id is src_item_id.
  --  Pre-reqs    : None
  --  Parameters  :
  --  IN          : p_api_version       IN NUMBER Required
  --                p_batch_id          IN NUMBER Required
  --                p_src_item_id       IN NUMBER Required
  --                p_data_level_names  IN VARCHAR2_TBL_TYPE Required
  --  OUT         : x_return_status     OUT NOCOPY VARCHAR2(1)
  --                x_msg_count         OUT NOCOPY NUMBER
  --                x_msg_data          OUT NOCOPY VARCHAR2(2000)
  --  Version     : Initial version     1.0
  --  Notes       : Note text
  --
  -- End of comments
  PROCEDURE copy_associations_to_items
  (
    p_api_version       IN NUMBER
    ,p_batch_id         IN NUMBER
    ,p_src_item_id      IN NUMBER
    ,p_data_level_names IN VARCHAR2_TBL_TYPE
    ,x_return_status    OUT NOCOPY VARCHAR2
    ,x_msg_count        OUT NOCOPY NUMBER
    ,x_msg_data         OUT NOCOPY VARCHAR2
  );

  -- Start of comments
  --  API name    : copy_from_style_to_SKUs
  --  Type        : Private.
  --  Function    : Insert interface rows for associations of the style items
  --                to the corresponding SKUs.
  --  Pre-reqs    : None
  --  Parameters  :
  --  IN          : p_api_version       IN NUMBER Required
  --                p_batch_id          IN NUMBER Required
  --  OUT         : x_return_status     OUT NOCOPY VARCHAR2(1)
  --                x_msg_count         OUT NOCOPY NUMBER
  --                x_msg_data          OUT NOCOPY VARCHAR2(2000)
  --  Version     : Initial version     1.0
  --  Notes       : Note text
  --
  -- End of comments
  PROCEDURE copy_from_style_to_SKUs
  (
    p_api_version       IN NUMBER
    ,p_batch_id         IN NUMBER
    ,x_return_status    OUT NOCOPY VARCHAR2
    ,x_msg_count        OUT NOCOPY NUMBER
    ,x_msg_data         OUT NOCOPY VARCHAR2
    ,p_msii_miri_process_flag  IN  NUMBER DEFAULT 1   -- Bug 12635842
  );

  -- Start of comments
  --  API name    : copy_to_packs
  --  Type        : Private.
  --  Function    : Insert interface rows for associations of the pack items
  --                to the corresponding pack hierarchy.
  --  Pre-reqs    : None
  --  Parameters  :
  --  IN          : p_api_version       IN NUMBER Required
  --                p_batch_id          IN NUMBER Required
  --  OUT         : x_return_status     OUT NOCOPY VARCHAR2(1)
  --                x_msg_count         OUT NOCOPY NUMBER
  --                x_msg_data          OUT NOCOPY VARCHAR2(2000)
  --  Version     : Initial version     1.0
  --  Notes       : Note text
  --
  -- End of comments
  PROCEDURE copy_to_packs
  (
    p_api_version       IN NUMBER
    ,p_batch_id         IN NUMBER
    ,x_return_status    OUT NOCOPY VARCHAR2
    ,x_msg_count        OUT NOCOPY NUMBER
    ,x_msg_data         OUT NOCOPY VARCHAR2
  );


END ego_item_associations_pub;

/
