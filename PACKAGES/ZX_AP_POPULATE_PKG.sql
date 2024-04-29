--------------------------------------------------------
--  DDL for Package ZX_AP_POPULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_AP_POPULATE_PKG" AUTHID CURRENT_USER AS
/* $Header: zxrippopulatpvts.pls 120.2.12010000.2 2009/08/05 11:16:37 msakalab ship $ */
  TYPE party_info_ap_rec IS RECORD
       (
        BILLING_TP_NUMBER        zx_rep_trx_detail_t.BILLING_TP_NUMBER%TYPE,
        BILLING_TP_TAXPAYER_ID   zx_rep_trx_detail_t.BILLING_TP_TAXPAYER_ID%TYPE,
        BILLING_TP_NAME          zx_rep_trx_detail_t.BILLING_TP_NAME%TYPE,
        BILLING_TP_NAME_ALT      zx_rep_trx_detail_t.BILLING_TP_NAME_ALT%TYPE,
        BILLING_TP_SIC_CODE      zx_rep_trx_detail_t.BILLING_TP_SIC_CODE%TYPE,
        BILL_FROM_PARTY_ID      zx_rep_trx_detail_t.BILL_FROM_PARTY_ID%TYPE);

    TYPE party_info_ap_tbl IS TABLE OF party_info_ap_rec
    INDEX BY BINARY_INTEGER;

    g_party_info_ap_tbl     party_info_ap_tbl;


 TYPE party_site_info_ap_rec IS RECORD
       (

        BILLING_TP_CITY          zx_rep_trx_detail_t.BILLING_TP_CITY%TYPE,
        BILLING_TP_COUNTY        zx_rep_trx_detail_t.BILLING_TP_COUNTY%TYPE,
        BILLING_TP_STATE         zx_rep_trx_detail_t.BILLING_TP_STATE%TYPE,
        BILLING_TP_PROVINCE      zx_rep_trx_detail_t.BILLING_TP_PROVINCE%TYPE,
        BILLING_TP_ADDRESS1      zx_rep_trx_detail_t.BILLING_TP_ADDRESS1%TYPE,
        BILLING_TP_ADDRESS2      zx_rep_trx_detail_t.BILLING_TP_ADDRESS2%TYPE,
        BILLING_TP_ADDRESS3      zx_rep_trx_detail_t.BILLING_TP_ADDRESS3%TYPE,
        BILLING_TP_ADDR_LINES_ALT zx_rep_trx_detail_t.BILLING_TP_ADDRESS_LINES_ALT%TYPE,
        BILLING_TP_COUNTRY       zx_rep_trx_detail_t.BILLING_TP_COUNTRY%TYPE,
        BILLING_TP_POSTAL_CODE   zx_rep_trx_detail_t.BILLING_TP_POSTAL_CODE%TYPE,
        GDF_PO_VENDOR_SITE_ATT17    zx_rep_trx_detail_t.GDF_PO_VENDOR_SITE_ATT17%TYPE,
        BILLING_TP_SITE_NAME_ALT zx_rep_trx_detail_t.BILLING_TP_SITE_NAME_ALT%TYPE,
        BILLING_TP_SITE_NAME     zx_rep_trx_detail_t.BILLING_TP_SITE_NAME%TYPE,
        BILL_FROM_PARTY_SITE_ID      zx_rep_trx_detail_t.BILL_FROM_PARTY_SITE_ID%TYPE);

    TYPE party_site_info_ap_tbl IS TABLE OF party_site_info_ap_rec
    INDEX BY BINARY_INTEGER;

    g_party_site_tbl     party_site_info_ap_tbl;



  TYPE lookup_info_rec IS RECORD
       (
        lookup_meaning               FND_LOOKUPS.MEANING%TYPE,
        lookup_description            FND_LOOKUPS.DESCRIPTION%TYPE);

    TYPE lookup_info_tbl IS TABLE OF lookup_info_rec
    INDEX BY BINARY_INTEGER;

    g_lookup_info_tbl             lookup_info_tbl;


PROCEDURE update_additional_info(
          P_TRL_GLOBAL_VARIABLES_REC  IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE);

PROCEDURE lookup_desc_meaning(
           p_lookup_type IN  VARCHAR2,
           p_lookup_code IN  VARCHAR2,
           p_meaning     OUT NOCOPY VARCHAR2,
           p_description OUT NOCOPY VARCHAR2);

END ZX_AP_POPULATE_PKG;

/
