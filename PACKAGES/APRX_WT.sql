--------------------------------------------------------
--  DDL for Package APRX_WT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."APRX_WT" AUTHID CURRENT_USER AS
/* $Header: aprxwts.pls 120.1.12010000.2 2008/08/08 03:51:16 sparames ship $ */

--
-- Main Core Report
PROCEDURE GET_WITHOLDING_TAX(
        request_id       in number,
        section_name     in varchar2,
        retcode out NOCOPY     number,
        errbuf  out NOCOPY     varchar2);

-- (AP Witholding Tax/Report ), which is a plug-in
    PROCEDURE ap_wht_tax_report  (
        p_date_from	          in varchar2,
        p_date_to                 in varchar2,
        p_supplier_from           in varchar2,
        p_supplier_to             in varchar2,
        p_supplier_type           in varchar2,
        request_id       in number,
        retcode out NOCOPY     number,
        errbuf  out NOCOPY     varchar2);

--
-- All event trigger procedures must be defined as public procedures
-- Procedure written for the Main/Core Report.
  procedure before_report;
--procedure after_fetch;

-- Procedures written for the plug-in --( AP Witholding Tax/Letter) Report.
   procedure awt_before_report;
   procedure awt_bind(c in integer);

--
-- This is the structre to hold the placeholder values

type var_t is record(
 BOOKS_ID 				  NUMBER,
 ORGANIZATION_NAME                        VARCHAR2(240),
 FUNCTIONAL_CURRENCY_CODE		  VARCHAR2(15),
 ADDRESS_LINE1                            VARCHAR2(240),
 ADDRESS_LINE2                            VARCHAR2(240),
 ADDRESS_LINE3                            VARCHAR2(240),
 CITY                                     AP_SUPPLIER_SITES_ALL.city%type, --6708281
 ZIP                                      AP_SUPPLIER_SITES_ALL.zip%type, --6708281
 PROVINCE                                 VARCHAR2(30),
 STATE                                    VARCHAR2(150),
 COUNTRY                                  AP_SUPPLIER_SITES_ALL.country%type, --6708281
 TAX_AUTHORITY				  VARCHAR2(80),
 SUPPLIER_TYPE                            VARCHAR2(25),
 SET_OF_BOOKS_ID                          NUMBER,
 SUPPLIER_NAME                            VARCHAR2(240),
 TAXPAYER_ID				  VARCHAR2(30),
 SUPPLIER_NUMBER                          VARCHAR2(30),
 VAT_REGISTRATION_NUMBER                  VARCHAR2(20),
 SUPPLIER_ADDRESS_LINE1                   VARCHAR2(240),
 SUPPLIER_ADDRESS_LINE2                   VARCHAR2(240),
 SUPPLIER_ADDRESS_LINE3                   VARCHAR2(240),
 SUPPLIER_CITY                            AP_SUPPLIER_SITES_ALL.city%type, --6708281
 SUPPLIER_STATE                           VARCHAR2(150),
 SUPPLIER_ZIP                             AP_SUPPLIER_SITES_ALL.zip%type, --6708281
 SUPPLIER_PROVINCE                        VARCHAR2(150),
 SUPPLIER_COUNTRY                         AP_SUPPLIER_SITES_ALL.country%type, --6708281
 SUPPLIER_SITE_CODE                       VARCHAR2(15),
 INVOICE_NUM                              VARCHAR2(50),
 INVOICE_AMOUNT                           NUMBER,
 INVOICE_CURRENCY_CODE                    VARCHAR2(15),
 INVOICE_DATE                             DATE,
 INV_GLOBAL_ATTRIBUTE1                    VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE2                    VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE3                    VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE4                    VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE5                    VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE6                    VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE7                    VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE8                    VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE9                    VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE10                   VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE11                   VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE12                   VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE13                   VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE14                   VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE15                   VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE16                   VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE17                   VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE18                   VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE19                   VARCHAR2(150),
 INV_GLOBAL_ATTRIBUTE20                   VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE1                     VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE2                     VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE3                     VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE4                     VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE5                     VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE6                     VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE7                     VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE8                     VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE9                     VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE10                    VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE11                    VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE12                    VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE13                    VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE14                    VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE15                    VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE16                    VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE17                    VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE18                    VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE19                    VARCHAR2(150),
 PV_GLOBAL_ATTRIBUTE20                    VARCHAR2(150),
 AWT_CODE                                 VARCHAR2(15),
 AWT_RATE                                 NUMBER,
 AWT_AMOUNT                               NUMBER,
 AWT_BASE_AMOUNT			  NUMBER,
 AWT_GROUP_NAME                           VARCHAR2(25),
 AWT_GL_DATE                              DATE,
 AWT_GROSS_AMOUNT                         NUMBER
);

var var_t;

END APRX_WT;

/
