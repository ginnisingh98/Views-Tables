--------------------------------------------------------
--  DDL for Package ARRX_TX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARRX_TX" AUTHID CURRENT_USER as
/* $Header: ARRXTXS.pls 120.6 2005/12/15 07:19:22 srivasud ship $ */

procedure artx_rep (
   completed_flag              in   varchar2,
   posted_flag                 in   varchar2,
   start_gl_date               in   date,
   end_gl_date                 in   date,
   start_transaction_date      in   date,
   end_transaction_date        in   date,
   start_transaction_type      in   varchar2,
   end_transaction_type        in   varchar2,
   start_transaction_class     in   varchar2,
   end_transaction_class       in   varchar2,
   start_balancing_segment     in   varchar2,
   end_balancing_segment       in   varchar2,
   start_bill_to_customer_name in   varchar2,
   end_bill_to_customer_name   in   varchar2,
   start_currency              in   varchar2,
   end_currency                in   varchar2,
   payment_method              in   varchar2,
   doc_sequence_name           in   varchar2,
   doc_sequence_number_from    in   number,
   doc_sequence_number_to      in   number,
   start_bill_to_customer_number in   varchar2,
   end_bill_to_customer_number   in   varchar2,
   reporting_level             IN   VARCHAR2,
   reporting_entity_id         IN   NUMBER,
   start_account               in   varchar2,
   end_account                 in   varchar2,
   batch_source_name           in   VARCHAR2,
   transaction_class           in   varchar2,
   request_id                  in   number,
   retcode                     out NOCOPY  number,
   errbuf                      out NOCOPY  varchar2);

procedure before_report;
procedure bind(c in integer);
procedure after_fetch;

procedure artx_rep_check (
   completed_flag              in   varchar2,
   posted_flag                 in   varchar2,
   start_gl_date               in   date,
   end_gl_date                 in   date,
   start_transaction_date      in   date,
   end_transaction_date        in   date,
   start_transaction_type      in   varchar2,
   end_transaction_type        in   varchar2,
   start_transaction_class     in   varchar2,
   end_transaction_class       in   varchar2,
   start_balancing_segment     in   varchar2,
   end_balancing_segment       in   varchar2,
   start_bill_to_customer_name in   varchar2,
   end_bill_to_customer_name   in   varchar2,
   start_currency              in   varchar2,
   end_currency                in   varchar2,
   payment_method              in   varchar2,
   start_update_date           in   date,
   end_update_date             in   date,
   last_updated_by             in   number,
   request_id                  in   number,
   retcode                     out NOCOPY  number,
   errbuf                      out NOCOPY  varchar2);

procedure check_before_report;
procedure check_bind(c in integer);
procedure check_after_fetch;

procedure artx_rep_forecast(
   completed_flag              in   varchar2,
   posted_flag                 in   varchar2,
   start_gl_date               in   date,
   end_gl_date                 in   date,
   start_transaction_date      in   date,
   end_transaction_date        in   date,
   start_transaction_type      in   varchar2,
   end_transaction_type        in   varchar2,
   start_transaction_class     in   varchar2,
   end_transaction_class       in   varchar2,
   start_balancing_segment     in   varchar2,
   end_balancing_segment       in   varchar2,
   start_bill_to_customer_name in   varchar2,
   end_bill_to_customer_name   in   varchar2,
   start_currency              in   varchar2,
   end_currency                in   varchar2,
   payment_method              in   varchar2,
   start_due_date              in   date,
   end_due_date                in   date,
   request_id                  in   number,
   retcode                     out NOCOPY  number,
   errbuf                      out NOCOPY  varchar2);

procedure forecast_before_report;
procedure forecast_bind(c in integer);

procedure artx_sales_rep (
   completed_flag              in   varchar2,
   posted_flag                 in   varchar2,
   transaction_type            in   varchar2,
   line_invoice                in   varchar2,
   start_invoice_num           in   varchar2,
   end_invoice_num             in   varchar2,
   doc_sequence_name           in   varchar2,
   start_doc_sequence_value    in   number,
   end_doc_sequence_value      in   number,
   start_gl_date               in   date,
   end_gl_date                 in   date,
   start_company_segment       in   varchar2,
   end_company_segment         in   varchar2,
   start_rec_nat_acct          in   varchar2,
   end_rec_nat_acct            in   varchar2,
   start_account               in   varchar2,
   end_account                 in   varchar2,
   start_currency              in   varchar2,
   end_currency                in   varchar2,
   start_amount                in   number,
   end_amount                  in   number,
   start_customer_name         in   varchar2,
   end_customer_name           in   varchar2,
   start_customer_number       in   varchar2,
   end_customer_number         in   varchar2,
   request_id                  in   number,
   retcode                     out NOCOPY  number,
   errbuf                      out NOCOPY  varchar2);

procedure sales_before_report;
procedure sales_bind(c in integer);
procedure sales_after_fetch;


function GET_CONS_BILL_NUMBER(P_CUSTOMER_TRX_ID in number) RETURN VARCHAR2;
function LAST_UPDATED_BY(P_CUSTOMER_TRX_ID in number) return number;
function LAST_UPDATE_DATE(P_CUSTOMER_TRX_ID in number) return date;
function WHERE_LAST_UPDATE(P_CUSTOMER_TRX_ID in number, P_LAST_UPDATED_BY in number, P_START_UPDATE_DATE in date, P_END_UPDATE_DATE in date) return varchar2;

type var_t is record (
        request_id                      number,
        organization_name               varchar2(30),
        functional_currency_code        varchar2(15),
        customer_trx_id                 number,
        trx_number                      varchar2(20),
        cons_bill_number                varchar2(30),
        rec_cust_trx_line_gl_dist_id    number,
        rec_account                     varchar2(2000), /*4653230*/
        rec_account_desc                varchar2(240),
        rec_balance                     varchar2(2000), /*4653230*/
        rec_balance_desc                varchar2(240),
        rec_natacct                     varchar2(2000), /*4653230*/
        rec_natacct_desc                varchar2(240),
        rec_postable_flag               varchar2(10),
        trx_last_updated_by             number,
        trx_last_update_date            date,
        customer_trx_line_id            number,
        link_to_cust_trx_line_id        number,
        inventory_item                  varchar2(240),
        cust_trx_line_gl_dist_id        number,
        account                         varchar2(240),
        account_desc                    varchar2(240),
        balance                         varchar2(240),
        balance_desc                    varchar2(240),
        natacct                         varchar2(240),
        natacct_desc                    varchar2(240),
        trx_payment_schedule_id         number,
        completed_flag                  varchar2(1),
        posted_flag                     varchar2(1),
        start_gl_date                   date,
        end_gl_date                     date,
        start_transaction_date          date,
        end_transaction_date            date,
        start_transaction_type          varchar2(20),
        end_transaction_type            varchar2(20),
        start_transaction_class         varchar2(20),
        end_transaction_class           varchar2(20),
        start_balancing_segment         varchar2(25),
        end_balancing_segment           varchar2(25),
        start_bill_to_customer_name     varchar2(50),
        end_bill_to_customer_name       varchar2(50),
        start_currency                  varchar2(15),
        end_currency                    varchar2(15),
        payment_method                  varchar2(30),
        doc_sequence_name               varchar2(30),
        doc_sequence_number_from        number,
        doc_sequence_number_to          number,
        start_update_date               date,
        end_update_date                 date,
        last_updated_by                 number,
        start_due_date                  date,
        end_due_date                    date,
        ccid                            number,
        ccid2                           number,
        books_id                        number,
        chart_of_accounts_id            number,
        bill_flag                       varchar2(1),
        so_id_flex_code                 varchar2(240),
        so_organization_id              number,
        ctid                            number := -1,
        user_id                         number,
        update_date                     date,
        item_description		varchar2(240),
        line_invoice			varchar2(7),
	start_invoice_num		varchar2(20),
	end_invoice_num			varchar2(20),
        start_rec_nat_acct		varchar2(240),
	end_rec_nat_acct		varchar2(240),
 	start_account			varchar2(2000), /*4653230*/
	end_account			varchar2(2000), /*4653230*/
	start_amount			number,
	end_amount			number,
        start_bill_to_customer_number   varchar2(30),
        end_bill_to_customer_number     varchar2(30),
	trx_date			date,
	trx_currency			varchar2(15),
	exchange_rate			number,
	exchange_date			date,
	exchange_type			varchar2(30),
	receivables_gl_date		date,
	trx_due_date			date,
	tax_header_level_flag		varchar2(1),
	doc_sequence_value		number,
	trx_amount			number,
	trx_acctd_amount		number,
	ship_to_customer_id		number(15),
	ship_to_site_use_id		number(15),
	bill_to_customer_id		number(15),
	bill_to_site_use_id		number(15),
	cust_trx_type_id		number(15),
	term_id				number(15),
	doc_sequence_id			number(15),
	receipt_method_id		number(15),
	org_id				number(15),
        ca_sob_type                     varchar2(1),
        ca_sob_id                       number,
        batch_id                        number,
        batch_source_id                 number,
        batch_source_name               Varchar2(50),
        reporting_level                 varchar2(50),
        reporting_entity_id             number,
	transaction_class		varchar2(50)
);
var var_t;

END ARRX_TX;

 

/
