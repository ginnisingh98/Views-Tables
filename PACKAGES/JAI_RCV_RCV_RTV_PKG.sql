--------------------------------------------------------
--  DDL for Package JAI_RCV_RCV_RTV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RCV_RCV_RTV_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rcv_rcv_rtv.pls 120.5 2007/04/24 06:35:00 bduvarag ship $ */
/*Bug 5527885 Start*/
TYPE journal_line IS RECORD(
    line_num          number(15),
    acct_type         varchar2(10),
    acct_nature       varchar2(30),
    source_name       varchar2(25),
    category_name     varchar2(25),
    ccid              number(15),
    entered_dr        number,
    entered_cr        number,
    currency_code     varchar2(15),
    accounting_date   date,
    reference_10      varchar2(240),
    reference_23      varchar2(240),
    reference_24      varchar2(240),
    reference_25      varchar2(240),
    reference_26      varchar2(240),
    destination       varchar2(15),
    reference_name    varchar2(30),
    reference_id      number(15),

    non_rnd_entered_dr  number,
    non_rnd_entered_cr  number,
    account_name      varchar2(30), /*this should be used to know which account is being hit */
    summary_jv_flag   varchar2(1)
  );

  TYPE JOURNAL_LINES IS TABLE OF journal_line INDEX BY BINARY_INTEGER;
/*Bug 5527885 End*/
  procedure process_transaction
  (
    p_transaction_id                          in                 number,
    p_simulation                              in                 varchar2,  -- default 'N', File.Sql.35
    p_debug                                   in                 varchar2,  -- default 'Y',  File.Sql.35
    p_process_flag                            out      nocopy    varchar2,
    p_process_message                         out      nocopy    varchar2,
    p_codepath                                in out   nocopy    varchar2
  );

  procedure get_accounts
  (
    p_organization_id                         in                  number,
    p_location_id                             in                  number,
    p_receipt_source_code                     in                  varchar2,
    p_from_organization_id                    in                  number,
    p_to_organization_id                      in                  number,
    p_po_distribution_id                      in                  number,
    p_po_line_location_id                     in                  number,
    p_debug                                   in                  varchar2,  -- default 'N', File.Sql.35
    p_boe_account_id                          out                 nocopy number,
    p_rtv_expense_account_id                  out     nocopy      number,
    p_excise_expense_account                  out     nocopy      number,
    p_excise_rcvble_account                   out     nocopy      number,
    p_receiving_account_id                    out     nocopy      number,
    p_ap_accrual_account                      out     nocopy      number,
    p_po_accrual_account_id                   out     nocopy      number,
    p_interorg_payables_account               out     nocopy      number,
    p_intransit_inv_account                   out     nocopy      number,
    p_interorg_receivables_account            out     nocopy      number,
    p_intransit_type                          out     nocopy      number,
    p_fob_point                               out     nocopy      number,
    p_trading_to_trading_iso                  out     nocopy      varchar2, /* Bug#4171469 */
    p_process_flag                            out     nocopy      varchar2,
    p_process_message                         out     nocopy      varchar2,
    p_codepath                                in out  nocopy      varchar2
  );


  procedure get_tax_breakup
  (
    p_transaction_id                          in                  number,
    p_shipment_line_id                        in                  number,
    p_currency_conversion_rate                in                  number,
    p_po_vendor_id                            in                  number,
    p_debug                                   in                  varchar2,  -- default 'N', File.Sql.35
    p_all_taxes                               out     nocopy      number,
    p_tds_taxes                               out     nocopy      number,
    p_modvat_recovery_taxes                   out     nocopy      number,
    p_cvd_taxes                               out     nocopy      number,
    p_add_cvd_taxes                           out     nocopy      number,/*5228046 Additional cvd Enhancement*/
    p_customs_taxes                           out     nocopy      number,
    p_third_party_taxes                       out     nocopy      number,
    p_excise_tax                              out     nocopy      number,
    p_service_recoverable                     out     nocopy      number, /* service */
    p_service_not_recoverable                 out     nocopy      number, /* service */
    /* following two parameters added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
    p_vat_recoverable                         out     nocopy      number,
    p_vat_not_recoverable                     out     nocopy      number,
    p_excise_edu_cess                         out     nocopy      number, /* educational cess */
    p_excise_sh_edu_cess                      out     nocopy      number, /*Bug 5989740 bduvarag*/
    p_cvd_edu_cess                            out     nocopy      number, /* educational cess */
    p_cvd_sh_edu_cess                         out     nocopy      number, /*Bug 5989740 bduvarag*/
    p_customs_edu_cess                        out     nocopy      number, /* educational cess */
    p_customs_sh_edu_cess                     out     nocopy      number, /*Bug 5989740 bduvarag*/
    p_process_flag                            out     nocopy      varchar2,
    p_process_message                         out     nocopy      varchar2,
    p_codepath                                in      out nocopy  varchar2
  );


  procedure validate_transaction_tax_accnt
  (
    p_transaction_type                        in                  varchar2,
    p_parent_transaction_type                 in                  varchar2,
    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_attribute_category                      in                  varchar2,
    p_receipt_source_code                     in                  varchar2,
    p_boe_account_id                          in                  number,
    p_rtv_expense_account_id                  in                  number,
    p_excise_expense_account                  in                  number,
    p_excise_rcvble_account                   in                  number,
    p_receiving_account_id                    in out  nocopy      number,
    p_ap_accrual_account                      in out  nocopy      number,
    p_po_accrual_account_id                   in                  number,
    p_interorg_payables_account               in                  number,
    p_intransit_inv_account                   in                  number,
    p_interorg_receivables_account            in                  number,
    p_intransit_type                          in                  number,
    p_fob_point                               in                  number,
    p_cvd_taxes                               in                  number,
    p_add_cvd_taxes                           in                  number,/*5228046 Additional cvd Enhancement*/
    p_customs_taxes                           in                  number,
    p_third_party_taxes                       in                  number,
    p_excise_tax                              in                  number,
    p_trading_to_trading_iso                  in                  varchar2, /* Bug#4171469 */
    p_debug                                   in                  varchar2,   -- default 'N', File.Sql.35
    p_process_flag                            out      nocopy     varchar2,
    p_process_message                         out      nocopy     varchar2,
    p_codepath                                in out   nocopy     varchar2
  );

  procedure apply_relieve_boe
  (
    p_transaction_id                           in                 number,
    p_transaction_type                         in                 varchar2,
    p_parent_transaction_id                    in                 number,
    p_parent_transaction_type                  in                 varchar2,
    p_shipment_line_id                         in                 number,
    p_shipment_header_id                       in                 number,
    p_organization_id                          in                 number,
    p_inventory_item_id                        in                 number,
    p_cvd_taxes                                in                 number,
    p_add_cvd_taxes                            in                 number,/*5228046 Additional cvd Enhancement*/
    p_customs_taxes                            in                 number,
    p_cvd_edu_cess                             in                 number, /* Educational Cess */
    p_cvd_sh_edu_cess                          in                 number,/*Bug 5989740 bduvarag*/
    p_customs_edu_cess                         in                 number, /* Educational Cess */
    p_customs_sh_edu_cess                      in                 number,/*Bug 5989740 bduvarag*/
    p_simulation                               in                 varchar2,
    p_debug                                    in                 varchar2,  -- default 'N', File.Sql.35
    p_process_flag                             out     nocopy     varchar2,
    p_process_message                          out     nocopy     varchar2,
    p_codepath                                 in out  nocopy     varchar2
  ) ;


  procedure relieve_boe
  (
    p_shipment_header_id                       in                 number,
    p_shipment_line_id                         in                 number,
    p_transaction_id                           in                 number,
    p_parent_transaction_id                    in                 number,
    p_boe_tax                                  in                 number,
    p_simulation                               in                 varchar2,
    p_debug                                    in                 varchar2 , -- default 'N', File.Sql.35
    p_process_flag                             out     nocopy     varchar2,
    p_process_message                          out     nocopy     varchar2,
    p_codepath                                 in out  nocopy     varchar2
  );


  procedure apply_boe
  (
    p_shipment_header_id                       in                 number,
    p_shipment_line_id                         in                 number,
    p_transaction_id                           in                 number,
    p_organization_id                          in                 number,
    p_inventory_item_id                        in                 number,
    p_boe_tax                                  in                 number,
    p_simulation                               in                 varchar2,
    p_debug                                    in                 varchar2,  -- default 'N', File.Sql.35
    p_process_flag                             out     nocopy     varchar2,
    p_process_message                          out     nocopy     varchar2,
    p_codepath                                 in out  nocopy     varchar2
  );


  procedure post_entries
  (
    p_transaction_id                            in                number,
    p_transaction_type                          in                varchar2,
    p_parent_transaction_type                   in                varchar2,
    -- Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. p_attribute_category                        in                varchar2,
    p_receipt_source_code                       in                varchar2,
    p_transaction_date                          in                date,
    p_receipt_num                               in                varchar2,
    p_receiving_account_id                      in                number,
    p_ap_accrual_account                        in                number,
    p_boe_account_id                            in                number,
    p_rtv_expense_account_id                    in                number,
    p_intransit_type                            in                number,
    p_fob_point                                 in                number,
    p_intransit_inv_account                     in                number,
    p_interorg_receivables_account              in                number,
    p_all_taxes                                 in                number,
    p_tds_taxes                                 in                number,
    p_modvat_recovery_taxes                     in                number,
    p_cvd_taxes                                 in                number,
    p_add_cvd_taxes                             in                number,    /*5228046 Additional cvd Enhancement*/
    p_customs_taxes                             in                number,
    p_third_party_taxes                         in                number,
    p_excise_tax                                in                number,
    p_service_recoverable                       in                number, /* Service */
    p_service_not_recoverable                   in                number, /* Service */
    /* following two variable added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
    p_account_service_interim                   in                boolean,
    p_vat_recoverable                           in                number,
    p_vat_not_recoverable                       in                number, /* Service */
    p_excise_edu_cess                           in                number, /* Educational Cess */
    p_excise_sh_edu_cess                        in                number,/*Bug 5989740 bduvarag*/
    p_cvd_edu_cess                              in                number, /* Educational Cess */
    p_cvd_sh_edu_cess                           in                number,/*Bug 5989740 bduvarag*/
    p_customs_edu_cess                          in                number, /* Educational Cess */
    p_customs_sh_edu_cess                       in                number,/*Bug 5989740 bduvarag*/
    p_trading_to_trading_iso                    in                varchar2, /* Bug#4171469 */
    ptr_jv                                      in OUT NOCOPY JOURNAL_LINES,  /* 5527885 */
    p_simulation                                in                varchar2,
    p_debug                                     in                varchar2,  -- default 'N', File.Sql.35
    p_process_flag                              out     nocopy    varchar2,
    p_process_message                           out     nocopy    varchar2,
    p_codepath                                  in out  nocopy    varchar2
  );


  procedure regime_tax_accounting_interim
  (
    p_transaction_id                            in                number,
    p_shipment_line_id                          in                number,
    p_organization_id                           in                number,
    p_location_id                               in                number,
    p_transaction_type                          in                varchar2,
    p_currency_conversion_rate                  in                number,
    p_parent_transaction_type                   in                varchar2,
    -- p_attribute_category                        in                varchar2,
    p_receipt_source_code                       in                varchar2,
    p_transaction_date                          in                date,
    p_receipt_num                               in                varchar2,
    p_regime_code                               in                varchar2,
    ptr_jv                                      in OUT NOCOPY JOURNAL_LINES,  /* 5527885 */
    p_simulation                                in                varchar2,
    p_debug                                     in                varchar2,  -- default 'N', File.Sql.35
    p_process_flag                              out     nocopy    varchar2,
    p_process_message                           out     nocopy    varchar2,
    p_codepath                                  in out  nocopy    varchar2
  );

end jai_rcv_rcv_rtv_pkg;

/
