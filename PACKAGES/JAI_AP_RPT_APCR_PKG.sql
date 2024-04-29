--------------------------------------------------------
--  DDL for Package JAI_AP_RPT_APCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_RPT_APCR_PKG" 
/* $Header: jai_ap_rpt_apcr.pls 120.1.12010000.2 2009/05/28 10:18:41 vumaasha ship $ */
AUTHID CURRENT_USER AS
FUNCTION compute_credit_balance
(
p_bal_date            DATE,
p_vendor_id           NUMBER,
p_set_of_books_id     NUMBER,
p_vendor_site_code    VARCHAR2,
p_org_id              NUMBER, -- added by Aparajita on 26-sep-2002 for bug # 2574262
p_currency_code       VARCHAR2 DEFAULT NULL, /* added by vumaasha for bug 8310720 */
p_accts               ap_invoices_all.accts_pay_code_combination_id%TYPE DEFAULT NULL
) RETURN NUMBER;
FUNCTION compute_debit_balance
(
p_bal_date            DATE,
p_vendor_id           NUMBER,
p_set_of_books_id     NUMBER,
p_vendor_site_code    VARCHAR2,
p_org_id              NUMBER, -- added by Aparajita on 26-sep-2002 for bug # 2574262
p_currency_code       VARCHAR2 DEFAULT NULL,  /* added by vumaasha for bug 8310720 */
p_accts               ap_invoices_all.accts_pay_code_combination_id%TYPE DEFAULT NULL
) RETURN NUMBER;

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


END jai_ap_rpt_apcr_pkg;

/
