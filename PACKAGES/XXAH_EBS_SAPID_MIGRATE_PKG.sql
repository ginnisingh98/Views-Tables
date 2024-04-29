--------------------------------------------------------
--  DDL for Package XXAH_EBS_SAPID_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_EBS_SAPID_MIGRATE_PKG" 
AS
   /***************************************************************************
     *                           IDENTIFICATION
     *                           ==============
     * NAME              : XXAH_EBS_SAPID_MIGRATE_PKG
     * DESCRIPTION       : PACKAGE TO SAP Id Migration
     ****************************************************************************
     *                           CHANGE HISTORY
     *                           ==============
     * DATE             VERSION     DONE BY
     * 18-MAR-2019       1.0       Menaka    Initial
     ****************************************************************************/
PROCEDURE P_MAIN (errbuf  OUT VARCHAR2,
                  retcode OUT NUMBER) ;

PROCEDURE P_UPDATE_SUPPLIER_SITE(
  p_vendor_site_id IN NUMBER,
    p_sap_number   IN VARCHAR2
    );

PROCEDURE p_write_log ( p_row_id VARCHAR2, p_message IN VARCHAR2 );
PROCEDURE p_report;
END XXAH_EBS_SAPID_MIGRATE_PKG;

/
