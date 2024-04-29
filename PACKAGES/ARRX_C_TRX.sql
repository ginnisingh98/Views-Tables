--------------------------------------------------------
--  DDL for Package ARRX_C_TRX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARRX_C_TRX" AUTHID CURRENT_USER as
/* $Header: ARRXCTXS.pls 120.3 2005/10/30 03:56:56 appldev ship $ */

PROCEDURE TRANSACTION_REGISTER (
   errbuf                   out NOCOPY  varchar2,
   retcode                  out NOCOPY  varchar2,
   argument1                in   varchar2,                -- reporting_level
   argument2                in   varchar2,                -- reporting_entity_id
   argument3                in   varchar2,                -- set_of_books_id
   argument4                in   varchar2,                -- chart_of_accounts_id
   argument5                in   varchar2,                -- company_seg_low
   argument6                in   varchar2,                -- company_seg_high
   argument7                in   varchar2,                -- gl_date_low
   argument8                in   varchar2,                -- gl_date_high
   argument9                in   varchar2,                -- account_seg_low
   argument10               in   varchar2,                -- account_seg_high
   argument11               in   varchar2,                -- currency_code_low
   argument12               in   varchar2,                -- currency_code_high
   argument13               in   varchar2,                -- batch_source_id
   argument14               in   varchar2,                -- trx_type_low
   argument15               in   varchar2,                -- trx_type_high
   argument16               in   varchar2,                -- invoice_class
   argument17               in   varchar2,                -- trx_date_low
   argument18               in   varchar2,                -- trx_date_high
   argument19               in   varchar2,                 -- doc seq name
   argument20               in   varchar2,                -- doc seq num low
   argument21               in   varchar2,                -- doc seq num high
   argument22               in   varchar2  default  'N',  -- debug flag
   argument23               in   varchar2  default  'N',  -- sql trace
   argument24               in   varchar2  default  null,
   argument25               in   varchar2  default  null,
   argument26               in   varchar2  default  null,
   argument27               in   varchar2  default  null,
   argument28               in   varchar2  default  null,
   argument29               in   varchar2  default  null,
   argument30               in   varchar2  default  null,
   argument31               in   varchar2  default  null,
   argument32               in   varchar2  default  null,
   argument33               in   varchar2  default  null,
   argument34               in   varchar2  default  null,
   argument35               in   varchar2  default  null,
   argument36               in   varchar2  default  null,
   argument37               in   varchar2  default  null,
   argument38               in   varchar2  default  null,
   argument39               in   varchar2  default  null,
   argument40               in   varchar2  default  null,
   argument41               in   varchar2  default  null,
   argument42               in   varchar2  default  null,
   argument43               in   varchar2  default  null,
   argument44               in   varchar2  default  null,
   argument45               in   varchar2  default  null,
   argument46               in   varchar2  default  null,
   argument47               in   varchar2  default  null,
   argument48               in   varchar2  default  null,
   argument49               in   varchar2  default  null,
   argument50               in   varchar2  default  null,
   argument51               in   varchar2  default  null,
   argument52               in   varchar2  default  null,
   argument53               in   varchar2  default  null,
   argument54               in   varchar2  default  null,
   argument55               in   varchar2  default  null,
   argument56               in   varchar2  default  null,
   argument57               in   varchar2  default  null,
   argument58               in   varchar2  default  null,
   argument59               in   varchar2  default  null,
   argument60               in   varchar2  default  null,
   argument61               in   varchar2  default  null,
   argument62               in   varchar2  default  null,
   argument63               in   varchar2  default  null,
   argument64               in   varchar2  default  null,
   argument65               in   varchar2  default  null,
   argument66               in   varchar2  default  null,
   argument67               in   varchar2  default  null,
   argument68               in   varchar2  default  null,
   argument69               in   varchar2  default  null,
   argument70               in   varchar2  default  null,
   argument71               in   varchar2  default  null,
   argument72               in   varchar2  default  null,
   argument73               in   varchar2  default  null,
   argument74               in   varchar2  default  null,
   argument75               in   varchar2  default  null,
   argument76               in   varchar2  default  null,
   argument77               in   varchar2  default  null,
   argument78               in   varchar2  default  null,
   argument79               in   varchar2  default  null,
   argument80               in   varchar2  default  null,
   argument81               in   varchar2  default  null,
   argument82               in   varchar2  default  null,
   argument83               in   varchar2  default  null,
   argument84               in   varchar2  default  null,
   argument85               in   varchar2  default  null,
   argument86               in   varchar2  default  null,
   argument87               in   varchar2  default  null,
   argument88               in   varchar2  default  null,
   argument89               in   varchar2  default  null,
   argument90               in   varchar2  default  null,
   argument91               in   varchar2  default  null,
   argument92               in   varchar2  default  null,
   argument93               in   varchar2  default  null,
   argument94               in   varchar2  default  null,
   argument95               in   varchar2  default  null,
   argument96               in   varchar2  default  null,
   argument97               in   varchar2  default  null,
   argument98               in   varchar2  default  null,
   argument99               in   varchar2  default  null,
   argument100              in   varchar2  default  null);

PROCEDURE TRANSACTION_CHECK (
   errbuf                   out NOCOPY  varchar2,
   retcode                  out NOCOPY  varchar2,
   argument1                in   varchar2,                -- set_of_books_id
   argument2                in   varchar2,                -- chart_of_accounts_id
   argument3                in   varchar2,                -- completed_flag
   argument4                in   varchar2,                -- posted_flag
   argument5                in   varchar2,                -- gl_date_low
   argument6                in   varchar2,                -- gl_date_high
   argument7                in   varchar2,                -- transaction_date_low
   argument8                in   varchar2,                -- transaction_date_high
   argument9                in   varchar2,                -- transaction_type_low
   argument10               in   varchar2,                -- transaction_type_high
   argument11               in   varchar2,                -- currency_code_low
   argument12               in   varchar2,                -- currency_code_high
   argument13               in   varchar2,                -- company_segment_low
   argument14               in   varchar2,                -- company_segment_high
   argument15               in   varchar2,                -- invoice_class_low
   argument16               in   varchar2,                -- invoice_class_high
   argument17               in   varchar2,                -- customer_name_low
   argument18               in   varchar2,                -- customer_name_high
   argument19               in   varchar2,                -- payment_method
   argument20               in   varchar2,                -- start_update_date
   argument21               in   varchar2,                -- end_update_date
   argument22               in   varchar2,                -- last_updated_by
   argument23               in   varchar2  default  'N',  -- debug flag
   argument24               in   varchar2  default  'N',  -- sql trace
   argument25               in   varchar2  default  null,
   argument26               in   varchar2  default  null,
   argument27               in   varchar2  default  null,
   argument28               in   varchar2  default  null,
   argument29               in   varchar2  default  null,
   argument30               in   varchar2  default  null,
   argument31               in   varchar2  default  null,
   argument32               in   varchar2  default  null,
   argument33               in   varchar2  default  null,
   argument34               in   varchar2  default  null,
   argument35               in   varchar2  default  null,
   argument36               in   varchar2  default  null,
   argument37               in   varchar2  default  null,
   argument38               in   varchar2  default  null,
   argument39               in   varchar2  default  null,
   argument40               in   varchar2  default  null,
   argument41               in   varchar2  default  null,
   argument42               in   varchar2  default  null,
   argument43               in   varchar2  default  null,
   argument44               in   varchar2  default  null,
   argument45               in   varchar2  default  null,
   argument46               in   varchar2  default  null,
   argument47               in   varchar2  default  null,
   argument48               in   varchar2  default  null,
   argument49               in   varchar2  default  null,
   argument50               in   varchar2  default  null,
   argument51               in   varchar2  default  null,
   argument52               in   varchar2  default  null,
   argument53               in   varchar2  default  null,
   argument54               in   varchar2  default  null,
   argument55               in   varchar2  default  null,
   argument56               in   varchar2  default  null,
   argument57               in   varchar2  default  null,
   argument58               in   varchar2  default  null,
   argument59               in   varchar2  default  null,
   argument60               in   varchar2  default  null,
   argument61               in   varchar2  default  null,
   argument62               in   varchar2  default  null,
   argument63               in   varchar2  default  null,
   argument64               in   varchar2  default  null,
   argument65               in   varchar2  default  null,
   argument66               in   varchar2  default  null,
   argument67               in   varchar2  default  null,
   argument68               in   varchar2  default  null,
   argument69               in   varchar2  default  null,
   argument70               in   varchar2  default  null,
   argument71               in   varchar2  default  null,
   argument72               in   varchar2  default  null,
   argument73               in   varchar2  default  null,
   argument74               in   varchar2  default  null,
   argument75               in   varchar2  default  null,
   argument76               in   varchar2  default  null,
   argument77               in   varchar2  default  null,
   argument78               in   varchar2  default  null,
   argument79               in   varchar2  default  null,
   argument80               in   varchar2  default  null,
   argument81               in   varchar2  default  null,
   argument82               in   varchar2  default  null,
   argument83               in   varchar2  default  null,
   argument84               in   varchar2  default  null,
   argument85               in   varchar2  default  null,
   argument86               in   varchar2  default  null,
   argument87               in   varchar2  default  null,
   argument88               in   varchar2  default  null,
   argument89               in   varchar2  default  null,
   argument90               in   varchar2  default  null,
   argument91               in   varchar2  default  null,
   argument92               in   varchar2  default  null,
   argument93               in   varchar2  default  null,
   argument94               in   varchar2  default  null,
   argument95               in   varchar2  default  null,
   argument96               in   varchar2  default  null,
   argument97               in   varchar2  default  null,
   argument98               in   varchar2  default  null,
   argument99               in   varchar2  default  null,
   argument100              in   varchar2  default  null);

PROCEDURE RECEIPT_FORECAST (
   errbuf                   out NOCOPY  varchar2,
   retcode                  out NOCOPY  varchar2,
   argument1                in   varchar2,                -- set_of_books_id
   argument2                in   varchar2,                -- chart_of_accounts_id
   argument3                in   varchar2,                -- completed_flag
   argument4                in   varchar2,                -- posted_flag
   argument5                in   varchar2,                -- gl_date_low
   argument6                in   varchar2,                -- gl_date_high
   argument7                in   varchar2,                -- transaction_date_low
   argument8                in   varchar2,                -- transaction_date_high
   argument9                in   varchar2,                -- transaction_type_low
   argument10               in   varchar2,                -- transaction_type_high
   argument11               in   varchar2,                -- currency_code_low
   argument12               in   varchar2,                -- currency_code_high
   argument13               in   varchar2,                -- company_segment_low
   argument14               in   varchar2,                -- company_segment_high
   argument15               in   varchar2,                -- invoice_class_low
   argument16               in   varchar2,                -- invoice_class_high
   argument17               in   varchar2,                -- customer_name_low
   argument18               in   varchar2,                -- customer_name_high
   argument19               in   varchar2,                -- payment_method
   argument20               in   varchar2  default  null,
   argument21               in   varchar2  default  null,
   argument22               in   varchar2  default  null,
   argument23               in   varchar2,                -- start_due_date
   argument24               in   varchar2,                -- end_due_date
   argument25               in   varchar2  default  'N',  -- debug flag
   argument26               in   varchar2  default  'N',  -- sql trace
   argument27               in   varchar2  default  null,
   argument28               in   varchar2  default  null,
   argument29               in   varchar2  default  null,
   argument30               in   varchar2  default  null,
   argument31               in   varchar2  default  null,
   argument32               in   varchar2  default  null,
   argument33               in   varchar2  default  null,
   argument34               in   varchar2  default  null,
   argument35               in   varchar2  default  null,
   argument36               in   varchar2  default  null,
   argument37               in   varchar2  default  null,
   argument38               in   varchar2  default  null,
   argument39               in   varchar2  default  null,
   argument40               in   varchar2  default  null,
   argument41               in   varchar2  default  null,
   argument42               in   varchar2  default  null,
   argument43               in   varchar2  default  null,
   argument44               in   varchar2  default  null,
   argument45               in   varchar2  default  null,
   argument46               in   varchar2  default  null,
   argument47               in   varchar2  default  null,
   argument48               in   varchar2  default  null,
   argument49               in   varchar2  default  null,
   argument50               in   varchar2  default  null,
   argument51               in   varchar2  default  null,
   argument52               in   varchar2  default  null,
   argument53               in   varchar2  default  null,
   argument54               in   varchar2  default  null,
   argument55               in   varchar2  default  null,
   argument56               in   varchar2  default  null,
   argument57               in   varchar2  default  null,
   argument58               in   varchar2  default  null,
   argument59               in   varchar2  default  null,
   argument60               in   varchar2  default  null,
   argument61               in   varchar2  default  null,
   argument62               in   varchar2  default  null,
   argument63               in   varchar2  default  null,
   argument64               in   varchar2  default  null,
   argument65               in   varchar2  default  null,
   argument66               in   varchar2  default  null,
   argument67               in   varchar2  default  null,
   argument68               in   varchar2  default  null,
   argument69               in   varchar2  default  null,
   argument70               in   varchar2  default  null,
   argument71               in   varchar2  default  null,
   argument72               in   varchar2  default  null,
   argument73               in   varchar2  default  null,
   argument74               in   varchar2  default  null,
   argument75               in   varchar2  default  null,
   argument76               in   varchar2  default  null,
   argument77               in   varchar2  default  null,
   argument78               in   varchar2  default  null,
   argument79               in   varchar2  default  null,
   argument80               in   varchar2  default  null,
   argument81               in   varchar2  default  null,
   argument82               in   varchar2  default  null,
   argument83               in   varchar2  default  null,
   argument84               in   varchar2  default  null,
   argument85               in   varchar2  default  null,
   argument86               in   varchar2  default  null,
   argument87               in   varchar2  default  null,
   argument88               in   varchar2  default  null,
   argument89               in   varchar2  default  null,
   argument90               in   varchar2  default  null,
   argument91               in   varchar2  default  null,
   argument92               in   varchar2  default  null,
   argument93               in   varchar2  default  null,
   argument94               in   varchar2  default  null,
   argument95               in   varchar2  default  null,
   argument96               in   varchar2  default  null,
   argument97               in   varchar2  default  null,
   argument98               in   varchar2  default  null,
   argument99               in   varchar2  default  null,
   argument100              in   varchar2  default  null);

PROCEDURE SALES_REGISTER (
   errbuf                   out NOCOPY  varchar2,
   retcode                  out NOCOPY  varchar2,
   argument1                in   varchar2,                 -- set_of_books_id
   argument2                in   varchar2,                 -- chart_of_accounts_id
   argument3                in   varchar2  default  'Y',  -- completed_flag
   argument4                in   varchar2  default  null,  -- GL_start_date
   argument5                in   varchar2  default  null,  -- GL_end_date
   argument6                in   varchar2  default  'BOTH',  -- posted_flag
   argument7                in   varchar2  default  null,  -- transaction_type
   argument8                in   varchar2  default  null,  -- line_invoice
   argument9                in   varchar2  default  null,  -- start_invoice_num
   argument10               in   varchar2  default  null,  -- end_invoice_num
   argument11               in   varchar2  default  null,  -- doc_dsequence_name
   argument12               in   varchar2  default  null,  -- start_doc_sequence_value
   argument13               in   varchar2  default  null,  -- end_doc_sequence_value
   argument14               in   varchar2  default  null,  -- start_company_segment
   argument15               in   varchar2  default  null,  -- end_company_segment
   argument16               in   varchar2  default  null,  -- start_rec_nat_acct
   argument17               in   varchar2  default  null,  -- end_rec_nat_acct
   argument18               in   varchar2  default  null,  -- start_account
   argument19               in   varchar2  default  null,  -- end_account
   argument20               in   varchar2  default  null,  -- start_currency
   argument21               in   varchar2  default  null,  -- end_currency
   argument22               in   varchar2  default  null,  -- start_amount
   argument23               in   varchar2  default  null,  -- end_amount
   argument24               in   varchar2  default  null,  -- start_customer_name
   argument25               in   varchar2  default  null,  -- end_customer_name
   argument26               in   varchar2  default  null,  -- start_customer_number
   argument27               in   varchar2  default  null,  -- end_customer_number
   argument28               in   varchar2  default  null,  -- debug_switch
   argument29               in   varchar2  default  null,  -- trace_switch
   argument30               in   varchar2  default  null,
   argument31               in   varchar2  default  null,
   argument32               in   varchar2  default  null,
   argument33               in   varchar2  default  null,
   argument34               in   varchar2  default  null,
   argument35               in   varchar2  default  null,
   argument36               in   varchar2  default  null,
   argument37               in   varchar2  default  null,
   argument38               in   varchar2  default  null,
   argument39               in   varchar2  default  null,
   argument40               in   varchar2  default  null,
   argument41               in   varchar2  default  null,
   argument42               in   varchar2  default  null,
   argument43               in   varchar2  default  null,
   argument44               in   varchar2  default  null,
   argument45               in   varchar2  default  null,
   argument46               in   varchar2  default  null,
   argument47               in   varchar2  default  null,
   argument48               in   varchar2  default  null,
   argument49               in   varchar2  default  null,
   argument50               in   varchar2  default  null,
   argument51               in   varchar2  default  null,
   argument52               in   varchar2  default  null,
   argument53               in   varchar2  default  null,
   argument54               in   varchar2  default  null,
   argument55               in   varchar2  default  null,
   argument56               in   varchar2  default  null,
   argument57               in   varchar2  default  null,
   argument58               in   varchar2  default  null,
   argument59               in   varchar2  default  null,
   argument60               in   varchar2  default  null,
   argument61               in   varchar2  default  null,
   argument62               in   varchar2  default  null,
   argument63               in   varchar2  default  null,
   argument64               in   varchar2  default  null,
   argument65               in   varchar2  default  null,
   argument66               in   varchar2  default  null,
   argument67               in   varchar2  default  null,
   argument68               in   varchar2  default  null,
   argument69               in   varchar2  default  null,
   argument70               in   varchar2  default  null,
   argument71               in   varchar2  default  null,
   argument72               in   varchar2  default  null,
   argument73               in   varchar2  default  null,
   argument74               in   varchar2  default  null,
   argument75               in   varchar2  default  null,
   argument76               in   varchar2  default  null,
   argument77               in   varchar2  default  null,
   argument78               in   varchar2  default  null,
   argument79               in   varchar2  default  null,
   argument80               in   varchar2  default  null,
   argument81               in   varchar2  default  null,
   argument82               in   varchar2  default  null,
   argument83               in   varchar2  default  null,
   argument84               in   varchar2  default  null,
   argument85               in   varchar2  default  null,
   argument86               in   varchar2  default  null,
   argument87               in   varchar2  default  null,
   argument88               in   varchar2  default  null,
   argument89               in   varchar2  default  null,
   argument90               in   varchar2  default  null,
   argument91               in   varchar2  default  null,
   argument92               in   varchar2  default  null,
   argument93               in   varchar2  default  null,
   argument94               in   varchar2  default  null,
   argument95               in   varchar2  default  null,
   argument96               in   varchar2  default  null,
   argument97               in   varchar2  default  null,
   argument98               in   varchar2  default  null,
   argument99               in   varchar2  default  null,
   argument100              in   varchar2  default  null);

-- Bug 2008925.  Adding new procedure for Purge API
PROCEDURE PURGE_TRANSACTION_DATA(
   p_request_id             in   number,
   p_rows_affected          out NOCOPY  number);

END ARRX_C_TRX;

 

/
