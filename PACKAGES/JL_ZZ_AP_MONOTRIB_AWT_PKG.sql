--------------------------------------------------------
--  DDL for Package JL_ZZ_AP_MONOTRIB_AWT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AP_MONOTRIB_AWT_PKG" AUTHID CURRENT_USER AS
/* $Header: jlarmtbs.pls 120.0.12010000.3 2009/11/24 13:14:14 rahulkum noship $ */

P_SOB_ID          NUMBER;
P_ORG_ID          NUMBER;
P_REPORT_MODE     VARCHAR2(10);
P_SUPPLIER_NAME   VARCHAR2(240);
P_SUPPLIER_ID     NUMBER;
P_TAXPAYER_ID     VARCHAR2(30);
P_REPORT_DATE     DATE;
P_GOODS_SUPP_THLD NUMBER DEFAULT 0;
P_SERVICE_SUPP_THLD NUMBER DEFAULT 0;
P_DEBUG_LOG   VARCHAR2(1);
P_LEGAL_ENTITY_ID NUMBER;

FUNCTION BeforeReport
        RETURN BOOLEAN;

FUNCTION AfterReport
        RETURN BOOLEAN;

PROCEDURE Insert_temp_data(P_SUPPLIER_NAME             IN VARCHAR2,
                           P_SUPPLIER_ID               IN NUMBER,
                           P_TAXPAYER_ID               IN VARCHAR2,
                           P_SIMPLIF_REGIME_CONT_TYPE  IN VARCHAR2,
                           P_supp_monotrib_status      IN VARCHAR2,
                           P_supp_update_status        IN VARCHAR2,
                           P_threshold_amt             IN NUMBER,
                           P_INVOICE_ID                IN NUMBER,
                           P_INVOICE_NUM               IN VARCHAR2,
                           P_INVOICE_DATE              IN DATE,
                           P_INVOICE_STATUS            IN VARCHAR2,
                           P_DGI_TYPE                  IN VARCHAR2,
                           P_INV_AMOUNT                IN NUMBER,
                           P_INV_AMT_WOUT_TAX          IN NUMBER,
                           P_threshold_Met             IN VARCHAR2 );

PROCEDURE Update_Supplier_Applicability (P_Supplier_Id IN po_vendors.vendor_id%Type ,
                                         Applicability_Chngd_flag OUT NOCOPY Varchar2 );

PROCEDURE Update_Monotrib_Inv_Distrib_Wh (P_Invoice_Id IN ap_invoices_all.invoice_id%TYPE ,
                                          P_vendor_id  IN po_vendors.vendor_id%Type );

PROCEDURE Monotrib_Wh_Def_Line (  p_invoice_id    NUMBER,
                                  p_inv_dist_id   NUMBER,
                                  p_tax_payer_id  ap_invoice_distributions_all.global_attribute2%TYPE,
                                  p_ship_to_loc   VARCHAR2,
                                  p_line_type     VARCHAR2,
                                  p_vendor_id     NUMBER
								) ;

END JL_ZZ_AP_MONOTRIB_AWT_PKG;


/
