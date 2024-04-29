--------------------------------------------------------
--  DDL for Package XXAH_CUST_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_CUST_INTERFACE_PKG" 
IS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_CUST_INTERFACE_PKG
   * DESCRIPTION       : PACKAGE TO Customer Interface
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 17-JAN-2022        1.0       Karthick B    Initial
   ****************************************************************************/

PROCEDURE P_MAIN(p_retcode   OUT NUMBER,
				p_errbuff   OUT VARCHAR2);

PROCEDURE P_ARCHIVE_DATA;
PROCEDURE XXAH_CUST_INTF_PARAMETERS(l_req_id IN NUMBER);
   --PROCEDURE P_REPORT(l_con_req_id IN NUMBER);

END XXAH_CUST_INTERFACE_PKG;

/
