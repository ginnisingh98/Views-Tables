--------------------------------------------------------
--  DDL for Package XXAH_SUPPNAME_UPD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_SUPPNAME_UPD_PKG" 
AS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_NFR_SUPPNAME_PKG
   * DESCRIPTION       : PACKAGE TO  Update  Supplier name to remove BQN (RFC 65)
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 25-APR-2019        1.0       Menaka      Supplier name update for NFR Suppliers
   ****************************************************************************/

   PROCEDURE P_MAIN (errbuf          OUT VARCHAR2,
                     retcode         OUT NUMBER);

   PROCEDURE P_UPD_VENDOR_NAME (p_row_id      IN VARCHAR2,
                                p_new_supp_name    IN VARCHAR2,
                                p_supp_num    IN NUMBER);

   PROCEDURE p_report;

   PROCEDURE p_write_log (p_supp_num  VARCHAR2, p_message IN VARCHAR2);
END XXAH_SUPPNAME_UPD_PKG;

/
