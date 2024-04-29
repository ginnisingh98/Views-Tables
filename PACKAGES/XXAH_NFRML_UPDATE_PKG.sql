--------------------------------------------------------
--  DDL for Package XXAH_NFRML_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_NFRML_UPDATE_PKG" 
AS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_NFRML_UPDATE_PKG
   * DESCRIPTION       : PACKAGE TO  Update NFR Supplier Match level
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 25-AUG-2017        1.0       Menaka      Supplier name update for Match level update
   ****************************************************************************/
     
      PROCEDURE P_MAIN ( errbuf  OUT VARCHAR2,
                  retcode OUT NUMBER) ;
      PROCEDURE P_UPDATE_NFRML(p_row_id IN VARCHAR2,
                                      p_vendor_num IN NUMBER
                                    );
   
   
PROCEDURE p_write_log (p_row_id VARCHAR2, p_message IN VARCHAR2);

PROCEDURE p_report;
END XXAH_NFRML_UPDATE_PKG;

/
