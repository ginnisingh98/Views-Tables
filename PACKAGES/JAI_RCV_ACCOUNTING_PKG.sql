--------------------------------------------------------
--  DDL for Package JAI_RCV_ACCOUNTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RCV_ACCOUNTING_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rcv_accnt.pls 120.1 2005/07/20 12:59:01 avallabh ship $ */

	/* Cursor Definitions */
	cursor c_trx(cp_transaction_id in number) IS
	select *
	from JAI_RCV_TRANSACTIONS
	where transaction_id = cp_transaction_id;

	cursor c_base_trx(cp_transaction_id in number) IS
	select *
	from   rcv_transactions
	where  transaction_id = cp_transaction_id;

  PROCEDURE process_transaction
  (
      p_transaction_id              in        number,
      p_acct_type                   in        varchar2,
      p_acct_nature                 in        varchar2,
      p_source_name                 in        varchar2,
      p_category_name               in        varchar2,
      p_code_combination_id         in        number,
      p_entered_dr                  in        number,
      p_entered_cr                  in        number,
      p_currency_code               in        varchar2,
      p_accounting_date             in        date,
      p_reference_10                in        varchar2,
      p_reference_23                in        varchar2,
      p_reference_24                in        varchar2,
      p_reference_25                in        varchar2,
      p_reference_26                in        varchar2,
      p_destination                 in        varchar2,
      p_simulate_flag               in        varchar2,
      p_codepath                    in OUT NOCOPY varchar2,
      p_process_message OUT NOCOPY varchar2,
      p_process_status OUT NOCOPY varchar2,
      /* two parameters added by Vijay Shankar for Bug#4250236(4245089). VAT Implementation */
      p_reference_name              in        varchar2 DEFAULT NULL,
      p_reference_id                in        number   DEFAULT NULL
  );

  PROCEDURE gl_entry
  (
      p_organization_id                in         number,
      p_organization_code              in         varchar2,
      p_set_of_books_id                in         number,
      p_credit_amount                  in         number,
      p_debit_amount                   in         number,
      p_cc_id                          in         number,
      p_je_source_name                 in         varchar2,
      p_je_category_name               in         varchar2,
      p_created_by                     in         number,
      p_accounting_date                in         date           default null,
      p_currency_code                  in         varchar2,
      p_currency_conversion_date       in         date           default null,
      p_currency_conversion_type       in         varchar2       default null,
      p_currency_conversion_rate       in         number         default null,
      p_reference_10                   in         varchar2       default null,
      p_reference_23                   in         varchar2       default null,
      p_reference_24                   in         varchar2       default null,
      p_reference_25                   in         varchar2       default null,
      p_reference_26                   in         varchar2       default null ,
      p_process_message OUT NOCOPY varchar2,
      p_process_status OUT NOCOPY varchar2,
      p_codepath                       in OUT NOCOPY varchar2
  );

  PROCEDURE average_costing
  (
      p_receiving_account_id          in         number,
      p_new_cost                      in         number,
      p_organization_id               in         number,
      p_item_id                       in         number,
      p_shipment_line_id              in         number,
      p_transaction_uom               in         varchar2,
      p_transaction_date              in         date,
      p_subinventory                  in         varchar2,
      p_func_currency                 in         varchar2,
      p_transaction_id                in         number          default null,
      p_process_message OUT NOCOPY varchar2,
      p_process_status OUT NOCOPY varchar2,
      p_codepath                      in OUT NOCOPY varchar2
  );

  PROCEDURE rcv_receiving_sub_ledger_entry
  (
       p_transaction_id              in          number,
       p_organization_id             in          number,
       p_set_of_books_id             in          number,
       p_currency_code               in          varchar2,
       p_credit_amount               in          number,
       p_debit_amount                in          number,
       p_cc_id                       in          number,
       p_shipment_line_id            in          number,
       p_item_id                     in          number,
       p_source_document_code        in          varchar2,
       p_po_line_location_id         in          number,
       p_requisition_line_id         in          number,
       p_accounting_date             in          date           default null,
       p_currency_conversion_date    in          date           default null,
       p_currency_conversion_type    in          varchar2       default null,
       p_currency_conversion_rate    in          number         default null,
       p_process_message OUT NOCOPY varchar2,
       p_process_status OUT NOCOPY varchar2,
       p_codepath                    in OUT NOCOPY varchar2
  );

  PROCEDURE mta_entry
  (
      p_transaction_id               in          number,
      p_reference_account            in          number,
      p_debit_credit_flag            in          varchar2,
      p_tax_amount                   in          number,
      p_transaction_date             in          date            default null,
      p_currency_code                in          varchar2        default null,
      p_currency_conversion_date     in          date            default null,
      p_currency_conversion_type     in          varchar2        default null,
      p_currency_conversion_rate     in          number          default null,
      p_source_name                 in        varchar2           default null,  /*rchandan for bug#4473022 start*/
      p_category_name               in        VARCHAR2           default null,
      p_accounting_date             in        DATE               default null,
      p_reference_23                in        varchar2           default null,
      p_reference_24                in        varchar2           default null,
      p_reference_26                in        varchar2           default null,/*rchandan for bug#4473022 end*/
      p_process_message OUT NOCOPY varchar2,
      p_process_status OUT NOCOPY varchar2,
      p_codepath                     in OUT NOCOPY varchar2
  );

  PROCEDURE rcv_transactions_update
  (
      p_transaction_id               in          number,
      p_costing_amount               in          number,
      p_process_message OUT NOCOPY varchar2,
      p_process_status OUT NOCOPY varchar2,
      p_codepath                     in OUT NOCOPY varchar2
  );

end jai_rcv_accounting_pkg;
 

/
