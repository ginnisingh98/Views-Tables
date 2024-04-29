--------------------------------------------------------
--  DDL for Package ICX_CAT_POPULATE_MI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_POPULATE_MI_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVPPMS.pls 120.2.12010000.2 2010/09/14 09:15:42 rojain ship $*/

g_special_metadata_tbl          ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
g_regular_nontl_metadata_tbl    ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
g_regular_tl_metadata_tbl       ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
g_all_ctx_sql_tbl               ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
g_special_ctx_sql_tbl           ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
g_regular_ctx_sql_tbl           ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
g_metadataTblFormed             BOOLEAN         := FALSE;
g_CtxSqlForMIsFormed            BOOLEAN         := FALSE;
type Varchar4_Table is table of varchar2(4000) index by binary_integer;

PROCEDURE populateMIs
(       p_masterItem_csr        IN      ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type       ,
        p_current_mode          IN      VARCHAR2
);

PROCEDURE upgradeR12MIs
(       p_upgrade_last_run_date IN      DATE    ,
        p_start_rowid           IN      ROWID   ,
        p_end_rowid             IN      ROWID
);

PROCEDURE populateItemChange
(       P_INVENTORY_ITEM_ID             IN      NUMBER                                  ,
        P_ORGANIZATION_ID               IN      NUMBER                                  ,
        P_REQUEST_ID                    IN      NUMBER                                  ,
        P_ENTITY_TYPE                   IN      VARCHAR2
);

PROCEDURE populateItemDelete
(       P_INVENTORY_ITEM_ID             IN      NUMBER                                  ,
        P_ORGANIZATION_ID               IN      NUMBER
);

PROCEDURE populateItemCatgChange
(       P_INVENTORY_ITEM_ID             IN      NUMBER                                  ,
        P_ORGANIZATION_ID               IN      NUMBER                                  ,
        P_CATEGORY_ID                   IN      NUMBER                                  ,
        P_REQUEST_ID                    IN      NUMBER                                  ,
        P_ENTITY_TYPE                   IN      VARCHAR2
);

PROCEDURE populateItemCatgDelete
(       P_INVENTORY_ITEM_ID             IN      NUMBER                                  ,
        P_ORGANIZATION_ID               IN      NUMBER
);

PROCEDURE populateCategoryItems
(       P_MTL_CATEGORY_ID_TBL           IN      DBMS_SQL.NUMBER_TABLE
);

PROCEDURE buildCtxSqlForMIs
(       p_special_ctx_sql_tbl           IN OUT NOCOPY   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type,
        p_regular_ctx_sql_tbl           IN OUT NOCOPY   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type
);

END ICX_CAT_POPULATE_MI_PVT;

/
