--------------------------------------------------------
--  DDL for Package JAI_RCV_JOURNAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RCV_JOURNAL_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rcv_jrnl.pls 120.1 2005/07/20 12:59:07 avallabh ship $ */

PROCEDURE insert_row(
  P_ORGANIZATION_ID               IN  NUMBER,
  P_ORGANIZATION_CODE             IN  JAI_RCV_JOURNAL_ENTRIES.organization_code%TYPE,
  P_RECEIPT_NUM                   IN  JAI_RCV_JOURNAL_ENTRIES.receipt_num%TYPE,
  P_TRANSACTION_ID                IN  JAI_RCV_JOURNAL_ENTRIES.transaction_id%TYPE,
  P_TRANSACTION_DATE              IN  JAI_RCV_JOURNAL_ENTRIES.transaction_date%TYPE,
  P_SHIPMENT_LINE_ID              IN  JAI_RCV_JOURNAL_ENTRIES.shipment_line_id%TYPE,
  P_ACCT_TYPE                     IN  JAI_RCV_JOURNAL_ENTRIES.acct_type%TYPE,
  P_ACCT_NATURE                   IN  JAI_RCV_JOURNAL_ENTRIES.acct_nature%TYPE,
  P_SOURCE_NAME                   IN  JAI_RCV_JOURNAL_ENTRIES.source_name%TYPE,
  P_CATEGORY_NAME                 IN  JAI_RCV_JOURNAL_ENTRIES.category_name%TYPE,
  P_CODE_COMBINATION_ID           IN  JAI_RCV_JOURNAL_ENTRIES.code_combination_id%TYPE,
  P_ENTERED_DR                    IN  JAI_RCV_JOURNAL_ENTRIES.entered_dr%TYPE,
  P_ENTERED_CR                    IN  JAI_RCV_JOURNAL_ENTRIES.entered_cr%TYPE,
  P_TRANSACTION_TYPE              IN  JAI_RCV_JOURNAL_ENTRIES.transaction_type%TYPE,
  P_PERIOD_NAME                   IN  JAI_RCV_JOURNAL_ENTRIES.period_name%TYPE,
  P_CURRENCY_CODE                 IN  JAI_RCV_JOURNAL_ENTRIES.currency_code%TYPE,
  P_CURRENCY_CONVERSION_TYPE      IN  JAI_RCV_JOURNAL_ENTRIES.currency_conversion_type%TYPE,
  P_CURRENCY_CONVERSION_DATE      IN  JAI_RCV_JOURNAL_ENTRIES.currency_conversion_date%TYPE,
  P_CURRENCY_CONVERSION_RATE      IN  JAI_RCV_JOURNAL_ENTRIES.currency_conversion_rate%TYPE,
  P_SIMULATE_FLAG                 IN  VARCHAR2, --File.Sql.35 Cbabu   DEFAULT 'N',
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2,
  /* two parameters added by Vijay Shankar for Bug#4250236(4245089). VAT Implementation */
  p_reference_name              in        varchar2 ,
  p_reference_id                in        number
);

PROCEDURE update_row(
  P_ORGANIZATION_CODE             IN  JAI_RCV_JOURNAL_ENTRIES.organization_code%TYPE                        DEFAULT NULL,
  P_RECEIPT_NUM                   IN  JAI_RCV_JOURNAL_ENTRIES.receipt_num%TYPE                              DEFAULT NULL,
  P_TRANSACTION_ID                IN  JAI_RCV_JOURNAL_ENTRIES.transaction_id%TYPE                           DEFAULT NULL,
  P_CREATION_DATE                 IN  JAI_RCV_JOURNAL_ENTRIES.creation_date%TYPE                            DEFAULT NULL,
  P_TRANSACTION_DATE              IN  JAI_RCV_JOURNAL_ENTRIES.transaction_date%TYPE                         DEFAULT NULL,
  P_SHIPMENT_LINE_ID              IN  JAI_RCV_JOURNAL_ENTRIES.shipment_line_id%TYPE                         DEFAULT NULL,
  P_ACCT_TYPE                     IN  JAI_RCV_JOURNAL_ENTRIES.acct_type%TYPE                                DEFAULT NULL,
  P_ACCT_NATURE                   IN  JAI_RCV_JOURNAL_ENTRIES.acct_nature%TYPE                              DEFAULT NULL,
  P_SOURCE_NAME                   IN  JAI_RCV_JOURNAL_ENTRIES.source_name%TYPE                              DEFAULT NULL,
  P_CATEGORY_NAME                 IN  JAI_RCV_JOURNAL_ENTRIES.category_name%TYPE                            DEFAULT NULL,
  P_CODE_COMBINATION_ID           IN  JAI_RCV_JOURNAL_ENTRIES.code_combination_id%TYPE                      DEFAULT NULL,
  P_ENTERED_DR                    IN  JAI_RCV_JOURNAL_ENTRIES.entered_dr%TYPE                               DEFAULT NULL,
  P_ENTERED_CR                    IN  JAI_RCV_JOURNAL_ENTRIES.entered_cr%TYPE                               DEFAULT NULL,
  P_TRANSACTION_TYPE              IN  JAI_RCV_JOURNAL_ENTRIES.transaction_type%TYPE                         DEFAULT NULL,
  P_PERIOD_NAME                   IN  JAI_RCV_JOURNAL_ENTRIES.period_name%TYPE                              DEFAULT NULL,
  P_CREATED_BY                    IN  JAI_RCV_JOURNAL_ENTRIES.created_by%TYPE                               DEFAULT NULL,
  P_CURRENCY_CODE                 IN  JAI_RCV_JOURNAL_ENTRIES.currency_code%TYPE                            DEFAULT NULL,
  P_CURRENCY_CONVERSION_TYPE      IN  JAI_RCV_JOURNAL_ENTRIES.currency_conversion_type%TYPE                 DEFAULT NULL,
  P_CURRENCY_CONVERSION_DATE      IN  JAI_RCV_JOURNAL_ENTRIES.currency_conversion_date%TYPE                 DEFAULT NULL,
  P_CURRENCY_CONVERSION_RATE      IN  JAI_RCV_JOURNAL_ENTRIES.currency_conversion_rate%TYPE                 DEFAULT NULL
);

PROCEDURE create_subledger_entry
(
  p_transaction_id number,
  p_organization_id number,
  p_currency_code varchar2,
  p_credit_amount number,
  p_debit_amount number,
  p_cc_id number,
  p_created_by number,
  p_accounting_date date default null,
  p_currency_conversion_date date default null,
  p_currency_conversion_type varchar2 default null,
  p_currency_conversion_rate number default null
 );

END jai_rcv_journal_pkg;
 

/
