--------------------------------------------------------
--  DDL for Package XXAH_SUPP_STATUS_UPD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_SUPP_STATUS_UPD_PKG" 
AS
   /***************************************************************************
     *                           IDENTIFICATION
     *                           ==============
     * NAME              : XXAH_SUPP_UPDATE_PKG
     * DESCRIPTION       : PACKAGE TO Inactivate Supplier Mass Update Conversion
     ****************************************************************************
     *                           CHANGE HISTORY
     *                           ==============
     * DATE             VERSION     DONE BY
     * 17-June-2018     1.0       Menaka Kumar     Initial
     * 18-Aug-2018      2.0       Menaka Kumar     Added Supplier Site
     ****************************************************************************/
 --  PROCEDURE P_UPDATE_VENDOR (p_rownum IN VARCHAR2,errbuf OUT VARCHAR2, retcode OUT NUMBER);
 PROCEDURE P_MAIN (errbuf  OUT VARCHAR2,
                  retcode OUT NUMBER) ;
   PROCEDURE P_UPDATE_VENDOR(p_row_id IN VARCHAR2,
                        p_vendor_num IN NUMBER
                      );

                      PROCEDURE P_UPDATE_SUPPLIER_SITE(p_row_id VARCHAR2,
    p_vendor_site_id            IN NUMBER
    );

     PROCEDURE  P_UPDATE_SUPPLIER_ADDRESS(p_row_id VARCHAR2,p_vendor_id in number,p_vendor_site_id in Number);


 PROCEDURE p_write_log (p_row_id VARCHAR2, p_message IN VARCHAR2);

PROCEDURE p_report ;
END XXAH_SUPP_STATUS_UPD_PKG;

/
