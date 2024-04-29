--------------------------------------------------------
--  DDL for Package JAI_AP_TDS_TAX_DEFAULTATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_TDS_TAX_DEFAULTATION" AUTHID CURRENT_USER AS
/* $Header: jai_ap_tds_dflt.pls 120.3.12010000.2 2009/08/04 09:25:32 bgowrava ship $ */

/* ----------------------------------------------------------------------------
 FILENAME      : jai_ap_tds_tax_defaultation_pkg_s.sql

 Created By    : Aparajita

 Created Date  : 24-dec-2004

 Bug           :

 Purpose       : Implementation of tax defaultation functionality on AP invoice.

 Called from   : Trigger ja_in_ap_aia_after_trg
                 Trigger ja_in_ap_aida_after_trg

 CHANGE HISTORY:
 -------------------------------------------------------------------------------
 S.No      Date         Author and Details
 -------------------------------------------------------------------------------
 1.        24/12/2004   Aparajita for bug#4088186. version#115.0. TDS Clean Up.

                        Created this package for implementing the TDS tax defaultation
                        functionality onto AP invoice.

2.   08-Jun-2005  Version 116.1 jai_ap_tds_dflt -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

3.   21-Dec-2007  Sanjikum for Bug#6708042, Version 120.3
                  Obsoleted the changes done for verion 120.2 and rechecked in the version 120.1 as 120.3

4.  07/Jul/2009  Bgowrava for Bug#5911913  File version 120.1.12000000.4
 	                  Added two parameters
 	                  (1) p_old_input_dff_value_wct
 	                  (2) p_old_input_dff_value_essi
 	                  in procedure processs_invoice.

---------------------------------------------------------------------------- */

  procedure process_invoice
 (
   p_invoice_id                         in                 number,
   p_invoice_line_number                in                 number    default   null,
   p_invoice_distribution_id            in                 number    default   null,
   p_line_type_lookup_code              in                 varchar2,
   p_distribution_line_number           in                 number,
   p_parent_reversal_id                 in                 number,
   p_reversal_flag                      in                 varchar2,
   p_amount                             in                 number,
   p_invoice_currency_code              in                 varchar2,
   p_exchange_rate                      in                 number,
   p_set_of_books_id                    in                 number,
   p_po_distribution_id                 in                 number    default   null,
   p_rcv_transaction_id                 in                 number    default   null,
   p_vendor_id                          in                 number,
   p_vendor_site_id                     in                 number,
   p_input_dff_value_tds                in                 varchar2,
   p_input_dff_value_wct                in                 varchar2,
   p_old_input_dff_value_wct            in                 varchar2,  --Added by Bgowrava for Bug#5911913
   p_input_dff_value_essi               in                 varchar2,
   p_old_input_dff_value_essi           in                 varchar2,  --Added by Bgowrava for Bug#5911913
   p_org_id                             in                 number,
   p_accounting_date                    in                 date,
   p_call_from                          in                 varchar2,
   p_final_tds_tax_id                   out      nocopy    number,
   p_process_flag                       out      nocopy    varchar2,
   p_process_message                    out      nocopy    varchar2,
   p_codepath                           in out   nocopy    varchar2
  );


  procedure validate_status_for_default
  (
    p_invoice_id                         in                 number,
    p_invoice_line_number                in                 number    default   null,
    p_invoice_distribution_id            in                 number    default   null,
    p_line_type_lookup_code              in                 varchar2,
    p_process_flag                       out      nocopy    varchar2,
    p_process_message                    out      nocopy    varchar2,
    p_codepath                           in out   nocopy    varchar2
  );


  procedure default_tds_from_receipt
  (
    p_invoice_id                        in                  number,
    p_invoice_line_number               in                  number    default   null,
    p_invoice_distribution_id           in                  number    default   null,
    p_line_type_lookup_code             in                  varchar2,
    p_distribution_line_number          in                  number    default   null, /* AP lines uptake */
    p_rcv_transaction_id                in                  number,
    p_tds_section_code                  out       nocopy    varchar2,
    p_tds_tax_id                        out       nocopy    number,
    p_default_from                      out       nocopy    varchar2,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  );


  procedure default_tds_from_po
  (
    p_invoice_id                        in                  number,
    p_invoice_line_number               in                  number    default   null,
    p_invoice_distribution_id           in                  number    default   null,
    p_line_type_lookup_code             in                  varchar2,
    p_distribution_line_number          in                  number    default   null, /* AP lines uptake */
    p_po_distribution_id                in                  number,
    p_tds_section_code                  out       nocopy    varchar2,
    p_tds_tax_id                        out       nocopy    number,
    p_default_from                      out       nocopy    varchar2,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  );


  procedure default_tds_from_setup
  (
    p_vendor_id                         in                  number,
    p_vendor_site_id                    in                  number,
    p_default_type                      out       nocopy    varchar2,
    p_tds_section_code                  out       nocopy    varchar2,
    p_tds_tax_id                        out       nocopy    number,
    p_default_from                      out       nocopy    varchar2,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  );


  procedure validate_default_tds
  (
    p_vendor_id                         in                  number,
    p_vendor_site_id                    in                  number,
    p_tds_section_code                  in                  varchar2,
    p_tds_tax_id                        in                  number,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  );


 procedure populate_localization_inv_tax
  (
    p_invoice_id                        in                  number,
    p_invoice_line_number               in                  number           default   null, /* AP lines uptake */
    p_invoice_distribution_id           in                  number           default   null, /* AP lines uptake */
    P_distribution_line_number          in                  number           default   null, /* AP lines uptake */
    p_amount                            in                  number,
    p_exchange_rate                     in                  number,
    p_section_type                      in                  varchar2,
    p_default_type                      in                  varchar2,
    p_default_section_code              in                  varchar2,
    p_default_tax_id                    in                  number,
    p_input_dff_value                   in                  varchar2,
    p_default_from                      in                  varchar2,
    p_vendor_id                         in                  number,
    p_vendor_site_id                    in                  number,
    p_org_id                            in                  number,
    p_accounting_date                   in                  date,
    p_final_tds_tax_id                  out       nocopy    number,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  );

  procedure get_default_tax_from_section
  (
    p_invoice_id                        in                  number,
    p_invoice_line_number               in                  number           default   null, /* AP lines uptake */
    p_invoice_distribution_id           in                  number           default   null, /* AP lines uptake */
    p_vendor_id                         in                  number,
    p_vendor_site_id                    in                  number,
    p_amount                            in                  number,
    p_exchange_rate                     in                  number,
    p_tds_section_code                  in                  varchar2,
    p_org_id                            in                  number,
    p_accounting_date                   in                  date,
    p_tds_tax_id                        out       nocopy    number,
    p_threshold_grp_id                  out       nocopy    number,
    p_cumulative_threshold_slab_id      out       nocopy    number,
    p_cumulative_threshold_stage        out       nocopy    varchar2,
    p_single_threshold_slab_id          out       nocopy    number,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  );

  procedure process_input_dff_tds
  (
    p_invoice_id                        in                  number,
    p_invoice_line_number               in                  number           default   null, /* AP lines uptake */
    p_invoice_distribution_id           in                  number           default   null, /* AP lines uptake */
    p_input_tds_dff_value               in                  varchar2,
    p_output_tds_dff_value              out       nocopy    varchar2,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  );


  procedure process_delete
  (
    p_invoice_id                        in                  number,
    p_invoice_line_number               in                  number           default   null, /* AP lines uptake */
    p_invoice_distribution_id           in                  number           default   null,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2
  );


  procedure check_old_transaction
  (
    p_invoice_id                        in                  number  default null,
    p_invoice_distribution_id           in                  number  default null,
    p_new_transaction                   out       nocopy    varchar2
  );

END jai_ap_tds_tax_defaultation;

/
