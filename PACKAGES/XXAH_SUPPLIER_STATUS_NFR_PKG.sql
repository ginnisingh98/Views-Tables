--------------------------------------------------------
--  DDL for Package XXAH_SUPPLIER_STATUS_NFR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_SUPPLIER_STATUS_NFR_PKG" 
AS
   /***************************************************************************
     *                           IDENTIFICATION
     *                           ==============
     * NAME              : XXAH_SUPP_UPDATE_PKG
     * DESCRIPTION       : PACKAGE TO Supplier Update Conversion
     ****************************************************************************
     *                           CHANGE HISTORY
     *                           ==============
     * DATE             VERSION     DONE BY
     * 25-Jan-2019       1.0       Menaka Kumar     Initial
     ****************************************************************************/
  

PROCEDURE P_MAIN (errbuf  OUT VARCHAR2,
                  retcode OUT NUMBER) ;

 PROCEDURE  P_UPDATE_SUPPLIER(p_row_id IN VARCHAR2,p_vendor_number IN NUMBER);

 PROCEDURE p_write_log (p_row_id VARCHAR2, p_message IN VARCHAR2);

 PROCEDURE p_report;
END  XXAH_SUPPLIER_STATUS_NFR_PKG;

/
