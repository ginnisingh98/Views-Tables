--------------------------------------------------------
--  DDL for Package ARRX_OTH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARRX_OTH" AUTHID CURRENT_USER as
/* $Header: ARRXOTHS.pls 120.0 2005/01/26 21:27:40 vcrisost noship $  */

procedure oth_rec_app (
   request_id                 in   number,
   p_reporting_level          in   number,
   p_reporting_entity         in   number,
   p_sob_id                   in   number,
   p_coa_id		      in   number,
   p_co_seg_low               in   varchar2,
   p_co_seg_high              in   varchar2,
   p_gl_date_low              in   date,
   p_gl_date_high             in   date,
   p_currency_code            in   varchar2,
   p_customer_name_low        in   varchar2,
   p_customer_name_high       in   varchar2,
   p_customer_number_low      in   varchar2,
   p_customer_number_high     in   varchar2,
   p_receipt_date_low         in   date,
   p_receipt_date_high        in   date,
   p_apply_date_low           in   date,
   p_apply_date_high          in   date,
   p_remit_batch_low          in   varchar2,
   p_remit_batch_high         in   varchar2,
   p_receipt_batch_low        in   varchar2,
   p_receipt_batch_high       in   varchar2,
   p_receipt_number_low       in   varchar2,
   p_receipt_number_high      in   varchar2,
   p_app_type                 in   varchar2,
   retcode                    out NOCOPY  number,
   errbuf                     out NOCOPY  varchar2);

procedure before_report;
procedure bind(c in integer);
procedure after_fetch;

type var_t is record (
        request_id                      number,
        books_id                        number,
        chart_of_accounts_id            number,
        currency_code                   varchar2(15),
        org_name                        varchar2(50),
        p_reporting_level               VARCHAR2(30),
        p_reporting_entity_id           NUMBER,
        p_sob_id                        NUMBER,
        p_coa_id			number,
        p_co_seg_low                    varchar2(30),
        p_co_seg_high                   varchar2(30),
        p_gl_date_low                   date,
        p_gl_date_high                  date,
        p_currency_code                 varchar2(15),
        p_customer_name_low             varchar2(50),
        p_customer_name_high            varchar2(50),
        p_customer_number_low           varchar2(50),
        p_customer_number_high          varchar2(50),
        p_receipt_date_low              date,
        p_receipt_date_high             date,
        p_apply_date_low                date,
        p_apply_date_high               date,
        p_remit_batch_low               varchar2(20),
        p_remit_batch_high              varchar2(20),
        p_receipt_batch_low             varchar2(20),
        p_receipt_batch_high            varchar2(20),
        p_receipt_number_low            varchar2(30),
        p_receipt_number_high           varchar2(30),
        p_app_type                      varchar2(50),
        organization_name               varchar2(50),
        functional_currency_code        varchar2(15),
        accounting_flexfield            varchar2(4000),
        code_combination_id             number,
        bank_account_number             varchar2(30),
        acctd_amount_applied_from       number,
        acctd_amount_applied_to         number,
        activity_name                   varchar2(50),
        amount_applied                  number,
        application_ref_num             varchar2(30),
        application_ref_type            varchar2(80),
        application_status              varchar2(20),
        apply_date                      date,
        batch_id                        number,
        batch_name                      varchar2(20),
        batch_source                    varchar2(50),
        cash_receipt_id                 number,
        customer_name                   varchar2(50),
        customer_number                 varchar2(30),
        debit_balancing                 varchar2(240),
        format_currency_code            varchar2(15),
        gl_date                         date,
        receipt_currency_code           varchar2(15),
        receipt_date                    date,
        receipt_number                  varchar2(30),
        receipt_status                  varchar2(40),
        receipt_type                    varchar2(30),
        receipt_amount                  number,
        remit_batch_name                varchar2(20),
        ca_sob_type                     varchar2(1),
        ca_sob_id                       number

);

var var_t;

END ARRX_OTH;

 

/
