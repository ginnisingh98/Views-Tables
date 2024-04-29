--------------------------------------------------------
--  DDL for Package XXAH_AP_SUPPLIER_PSNO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_AP_SUPPLIER_PSNO_PKG" AUTHID CURRENT_USER
AS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_AP_SUPPLIER_PSNO_PKG
   * DESCRIPTION       : PACKAGE TO Supplier
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 24-OCT-2016        1.0       Sunil Thamke    Initial
   * 21-Dec-2016        1.2          Sunil Thamke        Added SS with same address of other OU
   ****************************************************************************/
   PROCEDURE p_main (errbuf OUT VARCHAR2, retcode OUT NUMBER);

PROCEDURE P_CREATE_SUPPLIER(p_row_id IN VARCHAR2, p_supp_name IN VARCHAR2, p_vendor_id OUT NUMBER, p_error_flag OUT VARCHAR2, p_error_msg OUT VARCHAR2);

PROCEDURE P_SUPPLIER_SITE(p_vendor_id IN NUMBER,
p_supplier_site_name IN VARCHAR2,
p_operating_unit_id IN NUMBER,
p_ad_line1 IN VARCHAR2,
p_ad_line2 IN VARCHAR2,
p_ad_line3 IN VARCHAR2,
p_ad_line4 IN VARCHAR2,
p_city IN VARCHAR2,
p_zip_code IN VARCHAR2,
p_country IN VARCHAR2,
p_county IN VARCHAR2,
p_vendor_site_id OUT NUMBER,
p_err_flag OUT VARCHAR2,
p_err_msg OUT VARCHAR2
);

--<1.2>--
PROCEDURE P_SUPPLIER_SITE_AHN(
p_vendor_id IN NUMBER, 
p_vendor_site_id IN NUMBER,
p_errflag OUT VARCHAR2,
p_errmsg OUT VARCHAR2 ,
p_new_vend_site_id OUT NUMBER);

PROCEDURE P_UPDATE_DFF(l_vendor_site_id IN NUMBER,
                       p_attribute9     IN VARCHAR2,
                       l_ret_status OUT VARCHAR2
                       );

   PROCEDURE P_REPORT(l_con_req_id IN NUMBER);
    END XXAH_AP_SUPPLIER_PSNO_PKG; 

/
