--------------------------------------------------------
--  DDL for Package ZX_AR_ACTG_POPULATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_AR_ACTG_POPULATE_PKG" AUTHID CURRENT_USER AS
/* $Header: zxriractgpoppvts.pls 120.1.12010000.2 2008/11/12 12:48:48 spasala ship $ */

PROCEDURE UPDATE_ADDITIONAL_INFO (P_TRL_GLOBAL_VARIABLES_REC IN OUT
				  ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
                                  P_MRC_SOB_TYPE IN VARCHAR2);

TYPE cust_bill_ar_rec IS RECORD(
     BILLING_TP_NUMBER          zx_rep_trx_detail_t.BILLING_TP_NUMBER%TYPE,
     GDF_RA_CUST_BILL_ATT10      zx_rep_trx_detail_t.GDF_RA_CUST_BILL_ATT10%TYPE,
     GDF_RA_CUST_BILL_ATT12      zx_rep_trx_detail_t.GDF_RA_CUST_BILL_ATT12%TYPE,
     GDF_RA_ADDRESSES_BILL_ATT8  zx_rep_trx_detail_t.GDF_RA_ADDRESSES_BILL_ATT8%TYPE,
     GDF_RA_ADDRESSES_BILL_ATT9  zx_rep_trx_detail_t.GDF_RA_ADDRESSES_BILL_ATT9%TYPE,
     BILLING_TP_SITE_NAME       zx_rep_trx_detail_t.BILLING_TP_SITE_NAME%TYPE,
     BILLING_TP_TAX_REG_NUM     zx_rep_trx_detail_t.BILLING_TP_TAX_REG_NUM%TYPE);


TYPE cust_bill_ar_tbl IS TABLE OF cust_bill_ar_rec
    INDEX BY BINARY_INTEGER;

    g_cust_bill_ar_tbl     cust_bill_ar_tbl;


TYPE party_bill_ar_rec IS RECORD(
 BILLING_TP_NAME               zx_rep_trx_detail_t.BILLING_TP_NAME%TYPE,
      BILLING_TP_NAME_ALT      zx_rep_trx_detail_t.BILLING_TP_NAME_ALT%TYPE,
      BILLING_TP_SIC_CODE      zx_rep_trx_detail_t.BILLING_TP_SIC_CODE%TYPE,
      BILLING_TP_NUMBER        zx_rep_trx_detail_t.BILLING_TP_NUMBER%TYPE,
      BILLING_TP_TAXPAYER_ID       zx_rep_trx_detail_t.BILLING_TP_TAXPAYER_ID%TYPE,
      BILLING_TP_TAX_REG_NUM     zx_rep_trx_detail_t.BILLING_TP_TAX_REG_NUM%TYPE);


TYPE party_bill_ar_tbl IS TABLE OF party_bill_ar_rec
    INDEX BY BINARY_INTEGER;

    g_party_bill_ar_tbl     party_bill_ar_tbl;


 TYPE site_bill_ar_rec IS RECORD(
      BILLING_TP_CITY          zx_rep_trx_detail_t.BILLING_TP_CITY%TYPE,
      BILLING_TP_COUNTY        zx_rep_trx_detail_t.BILLING_TP_COUNTY%TYPE,
      BILLING_TP_STATE         zx_rep_trx_detail_t.BILLING_TP_STATE%TYPE,
      BILLING_TP_PROVINCE      zx_rep_trx_detail_t.BILLING_TP_PROVINCE%TYPE,
      BILLING_TP_ADDRESS1      zx_rep_trx_detail_t.BILLING_TP_ADDRESS1%TYPE,
      BILLING_TP_ADDRESS2      zx_rep_trx_detail_t.BILLING_TP_ADDRESS2%TYPE,
      BILLING_TP_ADDRESS3      zx_rep_trx_detail_t.BILLING_TP_ADDRESS3%TYPE,
      BILLING_TP_ADDR_LINES_ALT      zx_rep_trx_detail_t.BILLING_TP_ADDRESS_LINES_ALT%TYPE,
      BILLING_TP_COUNTRY      zx_rep_trx_detail_t.BILLING_TP_COUNTRY%TYPE,
      BILLING_TP_POSTAL_CODE  zx_rep_trx_detail_t.BILLING_TP_POSTAL_CODE%TYPE);


 TYPE site_bill_ar_tbl IS TABLE OF site_bill_ar_rec
    INDEX BY BINARY_INTEGER;

    g_site_bill_ar_tbl     site_bill_ar_tbl;


TYPE cust_ship_ar_rec IS RECORD(
     SHIPPING_TP_NUMBER          zx_rep_trx_detail_t.SHIPPING_TP_NUMBER%TYPE,
     GDF_RA_CUST_SHIP_ATT10      zx_rep_trx_detail_t.GDF_RA_CUST_SHIP_ATT10%TYPE,
     GDF_RA_CUST_SHIP_ATT12      zx_rep_trx_detail_t.GDF_RA_CUST_SHIP_ATT12%TYPE,
     GDF_RA_ADDRESSES_SHIP_ATT8  zx_rep_trx_detail_t.GDF_RA_ADDRESSES_SHIP_ATT8%TYPE,
     GDF_RA_ADDRESSES_SHIP_ATT9  zx_rep_trx_detail_t.GDF_RA_ADDRESSES_SHIP_ATT9%TYPE,
     SHIPPING_TP_SITE_NAME       zx_rep_trx_detail_t.SHIPPING_TP_SITE_NAME%TYPE,
     SHIPPING_TP_TAX_REG_NUM     zx_rep_trx_detail_t.SHIPPING_TP_TAX_REG_NUM%TYPE);


TYPE cust_ship_ar_tbl IS TABLE OF cust_ship_ar_rec
    INDEX BY BINARY_INTEGER;

    g_cust_ship_ar_tbl     cust_ship_ar_tbl;


TYPE party_ship_ar_rec IS RECORD(
 SHIPPING_TP_NAME               zx_rep_trx_detail_t.SHIPPING_TP_NAME%TYPE,
      SHIPPING_TP_NAME_ALT      zx_rep_trx_detail_t.SHIPPING_TP_NAME_ALT%TYPE,
      SHIPPING_TP_SIC_CODE      zx_rep_trx_detail_t.SHIPPING_TP_SIC_CODE%TYPE,
      SHIPPING_TP_NUMBER        zx_rep_trx_detail_t.SHIPPING_TP_NUMBER%TYPE,
      SHIPPING_TP_TAXPAYER_ID     zx_rep_trx_detail_t.SHIPPING_TP_TAXPAYER_ID%TYPE,
      SHIPPING_TP_TAX_REG_NUM    zx_rep_trx_detail_t.SHIPPING_TP_TAX_REG_NUM%TYPE);


TYPE party_ship_ar_tbl IS TABLE OF party_ship_ar_rec
    INDEX BY BINARY_INTEGER;

    g_party_ship_ar_tbl     party_ship_ar_tbl;


 TYPE site_ship_ar_rec IS RECORD(
      SHIPPING_TP_CITY          zx_rep_trx_detail_t.SHIPPING_TP_CITY%TYPE,
      SHIPPING_TP_COUNTY        zx_rep_trx_detail_t.SHIPPING_TP_COUNTY%TYPE,
      SHIPPING_TP_STATE         zx_rep_trx_detail_t.SHIPPING_TP_STATE%TYPE,
      SHIPPING_TP_PROVINCE      zx_rep_trx_detail_t.SHIPPING_TP_PROVINCE%TYPE,
      SHIPPING_TP_ADDRESS1      zx_rep_trx_detail_t.SHIPPING_TP_ADDRESS1%TYPE,
      SHIPPING_TP_ADDRESS2      zx_rep_trx_detail_t.SHIPPING_TP_ADDRESS2%TYPE,
      SHIPPING_TP_ADDRESS3      zx_rep_trx_detail_t.SHIPPING_TP_ADDRESS3%TYPE,
      SHIPPING_TP_ADDR_LINES_ALT      zx_rep_trx_detail_t.SHIPPING_TP_ADDRESS_LINES_ALT%TYPE,
      SHIPPING_TP_COUNTRY      zx_rep_trx_detail_t.SHIPPING_TP_COUNTRY%TYPE,
      SHIPPING_TP_POSTAL_CODE  zx_rep_trx_detail_t.SHIPPING_TP_POSTAL_CODE%TYPE);


 TYPE site_ship_ar_tbl IS TABLE OF site_ship_ar_rec
    INDEX BY BINARY_INTEGER;

    g_site_ship_ar_tbl     site_ship_ar_tbl;
END ZX_AR_ACTG_POPULATE_PKG;

/
