--------------------------------------------------------
--  DDL for Package JAI_AP_RPT_PRRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_RPT_PRRG_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ap_rpt_prrg.pls 120.2 2008/01/21 11:24:31 ssumaith ship $ */
  PROCEDURE process_report
  (
  p_invoice_date_from             IN  date,
  p_invoice_date_to               IN  date,
  p_vendor_id                     IN  number,
  p_vendor_site_id                IN  number,
  p_org_id                    	IN  NUMBER,
  p_run_no OUT NOCOPY number,
  p_error_message OUT NOCOPY varchar2
  );
END jai_ap_rpt_prrg_pkg;

/
