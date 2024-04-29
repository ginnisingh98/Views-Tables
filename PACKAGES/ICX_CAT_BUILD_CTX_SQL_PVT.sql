--------------------------------------------------------
--  DDL for Package ICX_CAT_BUILD_CTX_SQL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_BUILD_CTX_SQL_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVBCSS.pls 120.1.12010000.2 2013/07/11 13:43:09 bpulivar ship $*/

-----------------------------------------------------------
                  -- Global variables --
-----------------------------------------------------------

TYPE g_metadata_rec_type IS RECORD
(
  attribute_id          NUMBER,
  key                   icx_cat_attributes_tl.key%TYPE,
  type                  NUMBER,
  section_tag           NUMBER,
  attribute_length      NUMBER,
  stored_in_table       icx_cat_attributes_tl.stored_in_table%TYPE,
  stored_in_column      icx_cat_attributes_tl.stored_in_column%TYPE
);

TYPE g_metadata_tbl_type IS TABLE OF g_metadata_rec_type
  INDEX BY BINARY_INTEGER;

TYPE g_ctx_sql_rec_type IS RECORD
(
  ctx_sql_string        VARCHAR2(32000),
  bind_sequence         NUMBER
);

TYPE g_ctx_sql_tbl_type IS TABLE OF g_ctx_sql_rec_type
  INDEX BY BINARY_INTEGER;

------------ Hard coded sequences for searchable attributes ----------
g_seqMandatoryBaseRow           NUMBER  := 1;
g_seqForSupplierRow             NUMBER  := 2;
g_seqForInternalItemNumRow      NUMBER  := 3;
g_seqForSourceRow               NUMBER  := 4;
g_seqForItemRevisionRow         NUMBER  := 5;
g_seqForShoppingCategoryRow     NUMBER  := 6;

-- 17076597 changes
g_seqForUnNumberRow             NUMBER  := 7;
g_seqForHazardClassRow          NUMBER  := 8;

g_seqStartReqularBaseRow        NUMBER  := 100;
g_seqEndReqularBaseRow          NUMBER  := 5000;
g_seqStartRegularCatgRow        NUMBER  := 5000;
g_seqEndRegularCatgRow          NUMBER  := 9999;
g_seqForPurchasingOrgIdRow      NUMBER  := 15001;

PROCEDURE checkIfAttributeIsSrchble(p_attribute_key     IN VARCHAR2,
                                    p_searchable        OUT NOCOPY NUMBER,
                                    p_section_tag       OUT NOCOPY NUMBER);

PROCEDURE buildMetadataInfo(p_category_id                       IN              NUMBER,
                            p_special_metadata_tbl              IN OUT NOCOPY   g_metadata_tbl_type,
                            p_regular_nontl_metadata_tbl        IN OUT NOCOPY   g_metadata_tbl_type,
                            p_regular_tl_metadata_tbl           IN OUT NOCOPY   g_metadata_tbl_type);

PROCEDURE getAttributeDetails(p_special_metadata_tbl    IN              g_metadata_tbl_type,
                              p_attribute_key           IN              VARCHAR2,
                              p_attribute_searchable    IN OUT NOCOPY   VARCHAR2,
                              p_metadata_rec            IN OUT NOCOPY   g_metadata_rec_type);

PROCEDURE buildCtxSql(p_category_id                     IN              NUMBER,
                      p_doc_source                      IN              VARCHAR2,
                      p_where_clause                    IN              VARCHAR2 DEFAULT 'ROWID',
                      p_special_metadata_tbl            IN              g_metadata_tbl_type,
                      p_regular_nontl_metadata_tbl      IN              g_metadata_tbl_type,
                      p_regular_tl_metadata_tbl         IN              g_metadata_tbl_type,
                      p_all_ctx_sql_tbl                 IN OUT NOCOPY   g_ctx_sql_tbl_type,
                      p_special_ctx_sql_tbl             IN OUT NOCOPY   g_ctx_sql_tbl_type,
                      p_regular_ctx_sql_tbl             IN OUT NOCOPY   g_ctx_sql_tbl_type);

END ICX_CAT_BUILD_CTX_SQL_PVT;

/
