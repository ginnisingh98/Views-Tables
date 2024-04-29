--------------------------------------------------------
--  DDL for Package XXAH_AP_SUPPL_EMAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_AP_SUPPL_EMAIL_PKG" AUTHID CURRENT_USER
IS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_AP_SUPPL_EMAIL_PKG
   * DESCRIPTION       : PACKAGE TO Supplier Email
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 30-Nov-2015        1.0       Sunil Thamke     Initial
   ****************************************************************************/
   PROCEDURE p_main (errbuf OUT VARCHAR2, retcode OUT NUMBER);

END    XXAH_AP_SUPPL_EMAIL_PKG;

/
