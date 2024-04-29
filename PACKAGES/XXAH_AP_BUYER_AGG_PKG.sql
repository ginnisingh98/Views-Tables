--------------------------------------------------------
--  DDL for Package XXAH_AP_BUYER_AGG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_AP_BUYER_AGG_PKG" 
authid current_user
IS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_AP_BUYER_AGG_PKG
   * DESCRIPTION       : PACKAGE TO Supplier Interface
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 30-APR-2015        1.0       Sunil Thamke     Initial
   ****************************************************************************/

PROCEDURE P_MAIN(p_retcode   OUT NUMBER,
				p_errbuff   OUT VARCHAR2);

PROCEDURE P_ARCHIVE_DATA;
PROCEDURE P_EBS_PARAMETERS(l_req_id IN NUMBER);
   PROCEDURE P_REPORT(l_con_req_id IN NUMBER);

END XXAH_AP_BUYER_AGG_PKG;

/
