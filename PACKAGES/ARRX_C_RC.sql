--------------------------------------------------------
--  DDL for Package ARRX_C_RC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARRX_C_RC" AUTHID CURRENT_USER as
/* $Header: ARRXCRCS.pls 120.6.12010000.1 2008/07/24 16:53:22 appldev ship $ */

--------------------
-- Receipt Register
--------------------
PROCEDURE RECEIPT_REGISTER (
   errbuf                   out NOCOPY  varchar2,
   retcode                  out NOCOPY  varchar2,
   argument1                in   varchar2,                -- reporting_level
   argument2                in   varchar2,                -- reporting_entity_id
   argument3                in   varchar2,                -- set_of_books_id
   argument4                in   varchar2,                -- coaid
   argument5                in   varchar2,                -- company_segment_low
   argument6                in   varchar2,                -- company_segment_high
   argument7                in   varchar2,                -- gl_date_low
   argument8                in   varchar2,                -- gl_date_high
   argument9                in   varchar2,                -- currency_code
   argument10               in   varchar2,                -- batch_name_low
   argument11               in   varchar2,                -- batch_name_high
   argument12               in   varchar2,                -- customer_name_low
   argument13               in   varchar2,                -- customer_name_high
   argument14               in   varchar2,                -- deposit_date_low
   argument15               in   varchar2,                -- deposit_date_high
   argument16               in   varchar2,                -- receipt_status_low
   argument17               in   varchar2,                -- receipt_status_high
   argument18               in   varchar2,                -- receipt_number_low
   argument19               in   varchar2,                -- receipt_number_high
   argument20               in   varchar2,                -- receipt_date_low
   argument21               in   varchar2,                -- receipt_date_high
   argument22               in   varchar2,                -- bank_account_name
   argument23               in   varchar2,                -- payment_method
   argument24               in   varchar2,                -- confirmed_flag
   argument25               in   varchar2,                -- doc_sequence_name
   argument26               in   varchar2,                -- doc_sequence_number_from
   argument27               in   varchar2,                -- doc_sequence_number_to
   argument28               in   varchar2  default  'N',  -- debug flag
   argument29               in   varchar2  default  'N',  -- sql trace
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

---------------------------
-- Actual Receipts Register
---------------------------
PROCEDURE ACTUAL_RECEIPT (
   errbuf                   out NOCOPY  varchar2,
   retcode                  out NOCOPY  varchar2,
   argument1                in   varchar2,                -- reporting_level
   argument2                in   varchar2,                -- reporting_entity_id
   argument3                in   varchar2,                -- set_of_books_id
   argument4                in   varchar2,                -- coaid
   argument5                in   varchar2,                -- batch_name_low
   argument6                in   varchar2,                -- batch_name_high
   argument7                in   varchar2,                -- customer_name_low
   argument8                in   varchar2,                -- customer_name_high
   argument9                in   varchar2,                -- deposit_date_low
   argument10               in   varchar2,                -- deposit_date_high
   argument11               in   varchar2,                -- receipt_status_low
   argument12               in   varchar2,                -- receipt_status_high
   argument13               in   varchar2,                -- receipt_number_low
   argument14               in   varchar2,                -- receipt_number_high
   argument15               in   varchar2,                -- receipt_date_low
   argument16               in   varchar2,                -- receipt_date_high
   argument17               in   varchar2,                -- gl_date_low
   argument18               in   varchar2,                -- gl_date_high
   argument19               in   varchar2,                -- currency_code
   argument20               in   varchar2,                -- bank_account_name
   argument21               in   varchar2,                -- payment_method
   argument22               in   varchar2,                -- confirmed_flag
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

--------------------------------
-- Applied Receipt Register
--------------------------------
PROCEDURE AR_APPL_REC_REGISTER (
   errbuf                   out NOCOPY  varchar2,
   retcode                  out NOCOPY  varchar2,
   argument1                in   varchar2,                -- reporting_level
   argument2                in   varchar2,                -- reporting_entity_id
   argument3                in   varchar2,                -- set_of_books_id
   argument4                in   varchar2,                -- coaid
   argument5                in   varchar2,                -- company_segment_low
   argument6                in   varchar2,                -- company_segment_high
   argument7                in   varchar2,                -- gl_date_low
   argument8                in   varchar2,                -- gl_date_high
   argument9                in   varchar2,                -- currency_code
   argument10               in   varchar2,                -- batch_name_low
   argument11               in   varchar2,                -- batch_name_high
   argument12               in   varchar2,                -- customer_name_low
   argument13               in   varchar2,                -- customer_name_high
   argument14               in   varchar2,                -- customer number low
   argument15               in   varchar2,                -- customer number high
   argument16               in   varchar2,                -- apply date low
   argument17               in   varchar2,                -- apply date high
   argument18               in   varchar2,                -- receipt_number_low
   argument19               in   varchar2,                -- receipt_number_high
   argument20               in   varchar2,                -- invoice number low
   argument21               in   varchar2,                -- invoice number high
   argument22               in   varchar2,                -- invoice type low
   argument23               in   varchar2,                -- invoice type high
   argument24               in   varchar2  default  'N',  -- debug flag
   argument25               in   varchar2  default  'N',  -- sql trace
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

-----------------------------------
-- Miscellaneuos Receipts Register
-----------------------------------
PROCEDURE AR_MISC_TRX_REGISTER (
   errbuf                   out NOCOPY  varchar2,
   retcode                  out NOCOPY  varchar2,
   argument1                in   varchar2,                -- reporting_level
   argument2                in   varchar2,                -- reporting_entity_id
   argument3                in   varchar2,                -- set_of_books_id
   argument4                in   varchar2,                -- coaid
   argument5                in   varchar2,                -- company_segment_low
   argument6                in   varchar2,                -- company_segment_high
   argument7                in   varchar2,                -- gl_date_low
   argument8                in   varchar2,                -- gl_date_high
   argument9                in   varchar2,                -- currency_code
   argument10               in   varchar2,                -- batch_name_low
   argument11               in   varchar2,                -- batch_name_high
   argument12               in   varchar2,                -- deposit_date_low
   argument13               in   varchar2,                -- deposit_date_high
   argument14               in   varchar2,                -- receipt_number_low
   argument15               in   varchar2,                -- receipt_number_high
   argument16               in   varchar2,                -- doc_sequence_name
   argument17               in   varchar2,                -- doc_sequence_number_from
   argument18               in   varchar2,                -- doc_sequence_number_to
   argument19               in   varchar2  default  'N',  -- debug flag
   argument20               in   varchar2  default  'N',  -- sql trace
   argument21               in   varchar2  default  null,
   argument22               in   varchar2  default  null,
   argument23               in   varchar2  default  null,
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

END ARRX_C_RC;

/
