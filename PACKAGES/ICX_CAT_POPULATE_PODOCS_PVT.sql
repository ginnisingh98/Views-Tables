--------------------------------------------------------
--  DDL for Package ICX_CAT_POPULATE_PODOCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_POPULATE_PODOCS_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVPPDS.pls 120.3 2006/06/21 19:14:12 sbgeorge noship $*/

g_special_metadata_tbl          ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
g_regular_nontl_metadata_tbl    ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
g_regular_tl_metadata_tbl       ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
g_all_ctx_sql_tbl               ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
g_special_ctx_sql_tbl           ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
g_regular_ctx_sql_tbl           ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
g_metadataTblFormed             BOOLEAN         := FALSE;
g_CtxSqlForPODocsFormed         BOOLEAN         := FALSE;

PROCEDURE populateBPAs
(       p_podocs_csr            IN              ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type       ,
        p_current_mode          IN              VARCHAR2
);

PROCEDURE populateGBPAs
(       p_podocs_csr            IN              ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type       ,
        p_current_mode          IN              VARCHAR2
);

PROCEDURE populateOnlineBlankets
(       p_key                   IN              NUMBER
);

PROCEDURE populateOnlineOrgAssgnmnts
(       p_key                   IN              NUMBER
);

PROCEDURE populateBPAandQuotes
(       p_podocs_csr            IN              ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type       ,
        p_current_mode          IN              VARCHAR2
);

PROCEDURE upgradeR12PODocs
(       p_upgrade_last_run_date IN      DATE    ,
        p_start_rowid           IN      ROWID   ,
        p_end_rowid             IN      ROWID
);

PROCEDURE populateQuotes
(       p_podocs_csr            IN              ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type       ,
        p_current_mode          IN              VARCHAR2
);

PROCEDURE populateOnlineQuotes
(       p_key                   IN              NUMBER
);

PROCEDURE buildCtxSqlForPODocs
(       p_special_ctx_sql_tbl   IN OUT NOCOPY   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type    ,
        p_regular_ctx_sql_tbl   IN OUT NOCOPY   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type
);

END ICX_CAT_POPULATE_PODOCS_PVT;

 

/
