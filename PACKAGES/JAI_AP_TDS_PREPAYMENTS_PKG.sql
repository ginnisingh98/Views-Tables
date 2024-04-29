--------------------------------------------------------
--  DDL for Package JAI_AP_TDS_PREPAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_TDS_PREPAYMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ap_tds_ppay.pls 120.2.12010000.2 2010/01/29 08:22:45 mbremkum ship $ */

/* ----------------------------------------------------------------------------
 FILENAME      : jai_ap_tds_prepayemnts_pkg_s.sql

 Created By    : Aparajita

 Created Date  : 03-mar-2005

 Bug           :

 Purpose       : Implementation of prepayment functionality for TDS.

 Called from   : Trigger ja_in_ap_aia_after_trg
                 Trigger ja_in_ap_aida_after_trg

 CHANGE HISTORY:
 -------------------------------------------------------------------------------
 S.No      Date         Author and Details
 -------------------------------------------------------------------------------
 1.        03/03/2005   Aparajita for bug#4088186. version#115.0. TDS Clean Up.

                        Created this package for implementing the TDS prepayment
                        functionality onto AP invoice.
2. 08-Jun-2005  Version 116.1 jai_ap_tds_ppay -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

3.        03/05/2007   Bug 5722028. Added by csahoo 120.2
												Forward porting to R12.
                        Added parameter p_creation_date for the follownig procedures
												Process_prepayment
												process_unapply
												process_tds_invoices

												Depedencies:
												=============
												jai_ap_tds_gen.pls - 120.5
												jai_ap_tds_gen.plb - 120.19
												jai_ap_tds_ppay.pls - 120.2
												jai_ap_tds_ppay.plb - 120.5
												jai_ap_tds_can.plb - 120.6

---------------------------------------------------------------------------- */

  procedure process_prepayment
  (
    p_event                              in                 varchar2 default null,    --Added for Bug 8431516
    p_invoice_id                         in                 number,
    p_invoice_distribution_id            in                 number,
    p_prepay_distribution_id             in                 number,
    p_parent_reversal_id                 in                 number,
    p_prepay_amount                      in                 number,
    p_vendor_id                          in                 number,
    p_vendor_site_id                     in                 number,
    p_accounting_date                    in                 date,
    p_invoice_currency_code              in                 varchar2,
    p_exchange_rate                      in                 number,
    p_set_of_books_id                    in                 number,
    p_org_id                             in                 number,
    -- Bug 5722028. Added by CSahoo
    p_creation_date                      in                 date,
    p_process_flag                       out     nocopy     varchar2,
    p_process_message                    out     nocopy     varchar2,
    p_codepath                           in out  nocopy     varchar2
  );


  procedure process_unapply
  (
    p_event                              in                 varchar2,   --Added for Bug 8431516
    p_invoice_id                         in                 number,
    p_invoice_distribution_id            in                 number, /* PREPAY UNAPPLY distribution */
    p_parent_distribution_id             in                 number, /* parent PREPAY APPLY distribution */
    p_prepay_distribution_id             in                 number, /* Distribution id of prepay line - Bug 5751783*/
    p_prepay_amount                      in                 number,
    p_vendor_id                          in                 number,
    p_vendor_site_id                     in                 number,
    p_accounting_date                    in                 date,
    p_invoice_currency_code              in                 varchar2,
    p_exchange_rate                      in                 number,
    p_set_of_books_id                    in                 number,
    p_org_id                             in                 number,
    -- Bug 5722028. Added by CSahoo
    p_creation_date                      in                 date,
    p_process_flag                       out     nocopy     varchar2,
    p_process_message                    out     nocopy     varchar2,
    p_codepath                           in out  nocopy     varchar2
  );


  procedure allocate_prepayment
  (
    p_invoice_id                         in                     number,
    p_invoice_distribution_id            in                     number, /* Of the PREPAY line */
    p_prepay_amount                      in                     number,
    p_process_flag                       out     nocopy         varchar2,
    p_process_message                    out     nocopy         varchar2,
    p_codepath                           in out  nocopy         varchar2
  );

  procedure populate_section_tax
  (
    p_invoice_id                         in                 number,
    p_invoice_distribution_id            in                 number, /* Of the PREPAY line in the SI*/
    p_prepay_distribution_id             in                 number, /*Distribution id of the PP invoice */
    p_process_flag                       out     nocopy     varchar2,
    p_process_message                    out     nocopy     varchar2,
    p_codepath                           in out  nocopy     varchar2
  );

  procedure process_tds_invoices
  (
    p_event                              in                     varchar2,     --Added for Bug 8431516
    p_invoice_id                         in                     number,
    p_invoice_distribution_id            in                     number,
    p_prepay_distribution_id             in                     number,
    p_prepay_amount                      in                     number,
    p_vendor_id                          in                     number,
    p_vendor_site_id                     in                     number,
    p_accounting_date                    in                     date,
    p_invoice_currency_code              in                     varchar2,
    p_exchange_rate                      in                     number,
    p_set_of_books_id                    in                     number,
    p_org_id                             in                     number,
    -- Bug 5722028. Added by CSahoo
    p_creation_date                      in                 date,
    p_process_flag                       out     nocopy         varchar2,
    p_process_message                    out     nocopy         varchar2,
    p_codepath                           in out  nocopy         varchar2
  );

  procedure process_old_transaction
  (
    p_invoice_id                          in                  number,
    p_invoice_distribution_id             in                  number,
    p_prepay_distribution_id              in                  number,
    p_amount                              in                  number,
    p_last_updated_by                     in                  number,
    p_last_update_date                    in                  date,
    p_created_by                          in                  number,
    p_creation_date                       in                  date,
    p_org_id                              in                  number,
    p_process_flag                        out   nocopy         varchar2,
    p_process_message                     out   nocopy         varchar2
  );

END jai_ap_tds_prepayments_pkg;

/
