--------------------------------------------------------
--  DDL for Package ICX_CAT_POPULATE_REQTMPL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_POPULATE_REQTMPL_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVPPRS.pls 120.3 2006/06/21 19:13:41 sbgeorge noship $*/

g_special_metadata_tbl          ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
g_regular_nontl_metadata_tbl    ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
g_regular_tl_metadata_tbl       ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
g_all_ctx_sql_tbl               ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
g_special_ctx_sql_tbl           ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
g_regular_ctx_sql_tbl           ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
g_metadataTblFormed             BOOLEAN         := FALSE;
g_CtxSqlForPODocsFormed         BOOLEAN         := FALSE;

PROCEDURE populateReqTemplates
(       p_reqTemplate_csr       IN              ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type       ,
        p_current_mode          IN              VARCHAR2
);

PROCEDURE upgradeR12ReqTemplates
(       p_upgrade_last_run_date IN      DATE    ,
        p_start_rowid           IN      ROWID   ,
        p_end_rowid             IN      ROWID
);

PROCEDURE populateOnlineReqTemplates
(       p_key                   IN              NUMBER
);

PROCEDURE buildCtxSqlForRTs
(       p_special_ctx_sql_tbl   IN OUT NOCOPY   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type    ,
        p_regular_ctx_sql_tbl   IN OUT NOCOPY   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type
);

END ICX_CAT_POPULATE_REQTMPL_PVT;

 

/
