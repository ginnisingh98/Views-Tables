--------------------------------------------------------
--  DDL for Package JAI_PA_COSTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PA_COSTING_PKG" AUTHID CURRENT_USER as
/*$Header: jai_pa_costing.pls 120.0.12000000.1 2007/10/24 18:20:30 rallamse noship $*/
/*------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY
  ------------------------------------------------------------------------------------------------------------
  Sl.No.          Date          Developer   BugNo       Version        Remarks
  ------------------------------------------------------------------------------------------------------------
  1.              17/JAN/2007    brathod    5765161     115.0         Created the initial version

  1.              24-APR-2007    cbabu      6012567     120.0         Forward ported to R12 from R11i taking 115.0 version

--------------------------------------------------------------------------------------------------------------*/

  gv_src_oracle_purchasing  constant varchar2(30) := 'ORACLE_PURCHASING';
  gv_line_type_requisition  constant varchar2(30) := 'R';
  gv_line_type_purchasing   constant varchar2(30) := 'P';
  gv_line_type_po_receipt   constant varchar2(30) := 'PO_RECEIPT';

  gv_src_oracle_payables    constant varchar2(30) := 'ORACLE_PAYABLES';
  gv_line_type_invoice      constant varchar2(30) := 'I';
  gv_functional_currency    constant varchar2(30) := 'FUNCTIONAL_CURR';
  gv_transaction_currency   constant varchar2(30) := 'TRANSACTION_CURR';


  function get_func_curr_indicator  return varchar2;
  function get_trx_curr_indicator   return varchar2;

  function get_nonrec_tax_amount(
    pv_transaction_source         in  varchar2,
    pv_line_type                  in  varchar2,
    pn_transaction_header_id      in  number,
    pn_transaction_dist_id        in  number,                 /* One of PO_REQ_DISTRIBUTIONS_ALL.distribution_id, PO_DISTRIBUTIONS_ALL.po_distribution_id, RCV_TRANSACTIONS.transaction_id, AP_INVOICE_DISTRIBUTIONS_ALL.invoice_distribution_id */
    pv_currency_of_return_tax_amt in  varchar2  default null, /* no value is passed, then tax amount in transaction currency is returned */
    pv_transaction_uom            in  varchar2  default null, /* if not given, then conversion of UOM w.r.to main transaction will not be performed */
    pn_transaction_qty            in  number    default null,
    pn_currency_conv_rate         in  number    default null

  ) return number;

  procedure pre_process
            ( p_transaction_source    in  varchar2,
              p_batch                 in  varchar2,
              p_xface_id              in  number,
              p_user_id               in  number
            );

  procedure update_interface_costs
            ( p_transaction_source    in          varchar2
            , p_batch                 in          varchar2
            , p_xface_id              in          varchar2
            , p_process_flag          out nocopy  varchar2
            , p_process_message       out nocopy  varchar2
            );

end JAI_PA_COSTING_PKG;
 

/
