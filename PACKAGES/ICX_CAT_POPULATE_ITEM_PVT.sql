--------------------------------------------------------
--  DDL for Package ICX_CAT_POPULATE_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_POPULATE_ITEM_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVPPIS.pls 120.6.12010000.3 2013/07/11 13:45:41 bpulivar ship $*/

TYPE g_item_csr_type    IS REF CURSOR;

TYPE g_ctx_item_rec_type IS RECORD
(
  inventory_item_id             NUMBER,
  po_line_id                    NUMBER,
  req_template_name             icx_cat_items_ctx_hdrs_tlp.req_template_name%TYPE,
  req_template_line_num         NUMBER,
  org_id                        NUMBER,
  language                      icx_cat_items_ctx_hdrs_tlp.language%TYPE,
  source_type                   icx_cat_items_ctx_hdrs_tlp.source_type%TYPE,
  item_type			icx_cat_items_ctx_hdrs_tlp.item_type%TYPE,
  purchasing_org_id             NUMBER,
  owning_org_id                 NUMBER,
  po_category_id                NUMBER,
  supplier_id                   NUMBER,
  supplier_part_num             icx_cat_items_ctx_hdrs_tlp.supplier_part_num%TYPE,
  supplier_part_auxid           icx_cat_items_ctx_hdrs_tlp.supplier_part_auxid%TYPE,
  supplier_site_id              NUMBER,
  status                        NUMBER,
  ip_category_id                NUMBER,
  ip_category_name              icx_cat_categories_tl.category_name%TYPE,
  req_template_po_line_id       NUMBER,
  item_revision                 icx_cat_items_ctx_hdrs_tlp.item_revision%TYPE,
  po_header_id                  NUMBER,
  document_number               icx_cat_items_ctx_hdrs_tlp.document_number%TYPE,
  line_num                      NUMBER,
  allow_price_override_flag     icx_cat_items_ctx_hdrs_tlp.allow_price_override_flag%TYPE,
  not_to_exceed_price           NUMBER,
  line_type_id                  NUMBER,
  unit_meas_lookup_code         icx_cat_items_ctx_hdrs_tlp.unit_meas_lookup_code%TYPE,
  suggested_quantity            NUMBER,
  unit_price                    NUMBER,
  amount                        NUMBER,
  currency_code                 icx_cat_items_ctx_hdrs_tlp.currency_code%TYPE,
  rate_type                     icx_cat_items_ctx_hdrs_tlp.rate_type%TYPE,
  rate_date                     DATE,
  rate	                        NUMBER,
  buyer_id                      NUMBER,
  supplier_contact_id           NUMBER,
  rfq_required_flag             icx_cat_items_ctx_hdrs_tlp.rfq_required_flag%TYPE,
  negotiated_by_preparer_flag   icx_cat_items_ctx_hdrs_tlp.negotiated_by_preparer_flag%TYPE,
  description                   icx_cat_items_ctx_hdrs_tlp.description%TYPE,
  long_description              po_attribute_values_tlp.long_description%TYPE,
  organization_id               NUMBER,
  master_organization_id        NUMBER,
  order_type_lookup_code	icx_cat_items_ctx_hdrs_tlp.order_type_lookup_code%TYPE,
  supplier                      icx_cat_items_ctx_hdrs_tlp.supplier%TYPE,
  global_agreement_flag         icx_cat_items_ctx_hdrs_tlp.global_agreement_flag%TYPE,
  merged_source_type            icx_cat_items_ctx_hdrs_tlp.merged_source_type%TYPE,
  ctx_inventory_item_id         NUMBER,
  ctx_source_type               icx_cat_items_ctx_hdrs_tlp.source_type%TYPE,
  ctx_item_type			icx_cat_items_ctx_hdrs_tlp.item_type%TYPE,
  ctx_purchasing_org_id         NUMBER,
  ctx_supplier_id               NUMBER,
  ctx_supplier_site_id          NUMBER,
  ctx_supplier_part_num         icx_cat_items_ctx_hdrs_tlp.supplier_part_num%TYPE,
  ctx_supplier_part_auxid       icx_cat_items_ctx_hdrs_tlp.supplier_part_auxid%TYPE,
  ctx_ip_category_id            NUMBER,
  ctx_po_category_id            NUMBER,
  ctx_item_revision             icx_cat_items_ctx_hdrs_tlp.item_revision%TYPE,

  -- 17076597 changes starts
  ctx_un_number                 icx_cat_items_ctx_hdrs_tlp.un_number%TYPE,
  un_number                     icx_cat_items_ctx_hdrs_tlp.un_number%TYPE,
  ctx_hazard_class              icx_cat_items_ctx_hdrs_tlp.hazard_class%TYPE,
  hazard_class                  icx_cat_items_ctx_hdrs_tlp.hazard_class%TYPE,
  -- 17076597 changes ends
  ctx_rowid                     VARCHAR2(50)
);

TYPE g_bpa_online_flag_rec_type IS RECORD
(
  line_chngd_flg                VARCHAR2(1),
  attr_val_chngd_flg            VARCHAR2(1),
  attr_val_tlp_chngd_flg        VARCHAR2(1),
  gbpa_enabled_field_chngd_flg  VARCHAR2(1),
  gbpa_other_flds_chngd_flg     VARCHAR2(1)
);

PROCEDURE deleteItemCtxHdrsTLP
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type
);

PROCEDURE deleteItemCtxDtlsTLP
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type
);

PROCEDURE processCurrentCtxItemRow
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type             ,
        p_current_cursor        IN      VARCHAR2                        ,
        p_mode                  IN      VARCHAR2
);

PROCEDURE populateItemCtxTables
(       p_mode                  IN      VARCHAR2                        ,
        p_current_cursor        IN      VARCHAR2
);

PROCEDURE populateVendorNameChanges
(       p_vendor_party_id             IN              NUMBER                  ,
        p_vendor_name           IN              VARCHAR2
);

PROCEDURE populateVendorMerge
(       p_from_vendor_id        IN              NUMBER                  ,
        p_from_site_id          IN              NUMBER                  ,
        p_to_vendor_id          IN              NUMBER                  ,
        p_to_site_id            IN              NUMBER
);

PROCEDURE purgeInvalidBlanketLines;

-- Start of comments
--      API name        : purgeInvalidItems
-- *    Type            : Private
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of purging the intermedia index for ip catalog search.
--			  Purges the inactive blankets, global_blankets,
--			  inactive and deleted quote lines,
--			  inactive and deleted requisition template lines and
--			  master items belonging to inactive purchasing categories
--                        This procedure is called from the Concurrent program:
--                        'Purge Catalog interMedia Index'
-- *    Parameters      :
--      IN              :       none
--      OUT             :       x_errbuf                OUT NOCOPY      VARCHAR2
--                              x_retcode               OUT NOCOPY      NUMBER
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE purgeInvalidItems
(       x_errbuf                OUT NOCOPY      VARCHAR2                ,
        x_retcode               OUT NOCOPY      NUMBER
);

-- Start of comments
--      API name        : rebuildIPIntermediaIndex
-- *    Type            : Private
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of re-building the intermedia index for ip catalog search.
--                        This procedure is called from the Concurrent program:
--                        'Rebuild Catalog interMedia Index'
-- *    Parameters      :
--      IN              :       none
--      OUT             :       x_errbuf		OUT NOCOPY	VARCHAR2
--                              x_retcode		OUT NOCOPY      NUMBER
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE rebuildIPIntermediaIndex
(       x_errbuf                OUT NOCOPY      VARCHAR2                ,
        x_retcode               OUT NOCOPY      NUMBER
);

END ICX_CAT_POPULATE_ITEM_PVT;

/
