--------------------------------------------------------
--  DDL for Package XXAH_AP_SUPPL_APPROVAL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_AP_SUPPL_APPROVAL_RPT_PKG" 
AS

/***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_AP_SUPPL_APPROVAL_RPT_PKG
   * DESCRIPTION       : PACKAGE for Supplier Approval Workflow Reports
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY           COMMENTS
   * 03-MAR-2020        1.0       Anish Hussain     Initial Package
   * 06-MAR-2020        1.1       Anish Hussain     Added Procedure for Audit history report
   ****************************************************************************/
   PROCEDURE pending_suppl_approval_report(errbuf OUT VARCHAR2
                                          ,retcode OUT VARCHAR2
                                          );
   PROCEDURE supp_appr_audit_history_report(errbuf OUT VARCHAR2
                                           ,retcode OUT VARCHAR2
                                           ,p_vendor_name IN ap_suppliers.vendor_name%TYPE
                                           ,p_approval_from IN VARCHAR2
                                           ,p_approval_to IN VARCHAR2
                                           );
END XXAH_AP_SUPPL_APPROVAL_RPT_PKG;

/
