--------------------------------------------------------
--  DDL for Package ZX_PO_REC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_PO_REC_PKG" AUTHID CURRENT_USER AS
/* $Header: zxpotrxpoprecs.pls 120.4 2006/10/06 20:15:52 hongliu ship $ */



 PROCEDURE INSERT_REC_INFO;

 PROCEDURE INIT_REC_GT_TABLES;

 PROCEDURE get_rec_info(
   p_start_rowid      IN         ROWID,
   p_end_rowid        IN         ROWID);

 -- bug 5584964: add two more procedures for on-the-fly migration
 --
 PROCEDURE get_rec_info(
   p_upg_trx_info_rec IN         ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2);

 PROCEDURE get_rec_info(
   x_return_status    OUT NOCOPY  VARCHAR2);

 TYPE tax_code_id_tbl IS TABLE OF NUMBER                                                              INDEX BY BINARY_INTEGER;
 TYPE trx_date_tbl IS TABLE OF PO_HEADERS_ALL.LAST_UPDATE_DATE%TYPE                                   INDEX BY BINARY_INTEGER;
 TYPE code_combination_id_tbl IS TABLE OF PO_DISTRIBUTIONS_ALL.CODE_COMBINATION_ID%TYPE               INDEX BY BINARY_INTEGER;
 TYPE vendor_id_tbl IS TABLE OF PO_VENDORS.VENDOR_ID%TYPE                                             INDEX BY BINARY_INTEGER;
 TYPE tax_recovery_override_flag_tbl IS TABLE OF PO_DISTRIBUTIONS_ALL.tax_recovery_override_flag%TYPE INDEX BY BINARY_INTEGER;
 TYPE tax_recovery_rate_tbl IS TABLE OF PO_DISTRIBUTIONS_ALL.RECOVERY_RATE%TYPE                       INDEX BY BINARY_INTEGER;
 TYPE vendor_site_id_tbl IS TABLE OF PO_VENDOR_SITES_ALL.VENDOR_SITE_ID%TYPE                          INDEX BY BINARY_INTEGER;
 TYPE inv_org_id_tbl IS TABLE OF FINANCIALS_SYSTEM_PARAMS_ALL.inventory_organization_id%TYPE          INDEX BY BINARY_INTEGER;
 TYPE item_id_tbl IS TABLE OF PO_LINES_ALL.ITEM_ID%TYPE                                               INDEX BY BINARY_INTEGER;
 TYPE get_rec_rate_tbl IS TABLE OF PO_DISTRIBUTIONS_ALL.RECOVERY_RATE%TYPE                            INDEX BY BINARY_INTEGER;
 TYPE chart_of_accounts_id_tbl IS TABLE OF gl_ledgers.chart_of_accounts_id%TYPE                       INDEX BY BINARY_INTEGER;
 TYPE tc_tax_recovery_rule_id_tbl IS TABLE OF ap_tax_codes_all.tax_recovery_rule_id%TYPE              INDEX BY BINARY_INTEGER;
 TYPE tc_tax_recovery_rate_tbl IS TABLE OF ap_tax_codes_all.tax_recovery_rate%TYPE                    INDEX BY BINARY_INTEGER;
 TYPE vendor_type_lookup_code_tbl IS TABLE OF po_vendors.vendor_type_lookup_code%TYPE                 INDEX BY BINARY_INTEGER;

 TYPE po_header_id_tbl IS TABLE OF PO_HEADERS_ALL.PO_HEADER_ID%TYPE                                   INDEX BY BINARY_INTEGER;
 TYPE po_line_id_tbl IS TABLE OF PO_LINE_LOCATIONS_ALL.LINE_LOCATION_ID%TYPE                          INDEX BY BINARY_INTEGER;
 TYPE po_dist_id_tbl IS TABLE OF PO_DISTRIBUTIONS_ALL.PO_DISTRIBUTION_ID%TYPE                         INDEX BY BINARY_INTEGER;

 pg_get_tax_recovery_rate_tab         get_rec_rate_tbl;

end ZX_PO_REC_PKG;

 

/
