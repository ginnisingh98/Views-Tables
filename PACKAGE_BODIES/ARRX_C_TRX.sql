--------------------------------------------------------
--  DDL for Package Body ARRX_C_TRX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_C_TRX" as
/* $Header: ARRXCTXB.pls 120.7 2005/10/30 03:56:55 appldev ship $ */

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
   argument9                in   varchar2,                -- account_low
   argument10               in   varchar2,                -- account_high
   argument11               in   varchar2,                -- currency_code_low
   argument12               in   varchar2,                -- currency_code_high
   argument13               in   varchar2,                -- batch_source
   argument14               in   varchar2,                -- trx_type_low
   argument15               in   varchar2,                -- trx_type_high
   argument16               in   varchar2,                -- invoice_class
   argument17               in   varchar2,                -- trx_date_low
   argument18               in   varchar2,                -- trx_date_high
   argument19               in   varchar2,                 -- doc seq name
   argument20               in   varchar2,  		  -- doc seq num low
   argument21               in   varchar2, 		  -- doc seq num high
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
   argument100              in   varchar2  default  null)
is
   -- bug3940958 modified
   l_reporting_id		 number;
   l_reporting_level             VARCHAR2(50);
   l_reporting_entity_id         NUMBER;
   l_request_id                  number;
   l_set_of_books_id             number;
   l_chart_of_accounts_id        number;
   l_company_segment_low         varchar2(25);
   l_company_segment_high        varchar2(25);
   l_gl_date_low                 date;
   l_gl_date_high                date;
   l_account_low                 VARCHAR2(240);
   l_account_high                VARCHAR2(240);
   l_currency_code_low           varchar2(15);
   l_currency_code_high          varchar2(15);
   l_batch_source_name           varchar2(50);
   l_transaction_type_low        varchar2(20);
   l_transaction_type_high       varchar2(20);
   l_invoice_class               varchar2(20);
   l_transaction_date_low        date;
   l_transaction_date_high       date;
   l_doc_sequence_name           varchar2(30);
   l_doc_sequence_num_from       varchar2(15);
   l_doc_sequence_num_to         varchar2(15);
   l_profile_rsob_id NUMBER := NULL;
   l_client_info_rsob_id NUMBER := NULL;
   l_sob_type  varchar2(1) := 'P';


begin
  --
  -- SQL Trace switches and debug flags are optional
  -- but highly recommended.
  -- ATG mandate remove sql code trace
  -- if upper(substrb(argument25, 1, 1)) = 'Y' then
  --    fa_rx_util_pkg.enable_trace;
  -- end if;

   if upper(substrb(argument22, 1, 1)) = 'Y' then
      fa_rx_util_pkg.enable_debug;
   end if;

  --
  -- Assign parameters doing any necessary mappings
  -- e.g. date/number conversion

  -- bug3940958 modified
   l_request_id               := fnd_global.conc_request_id;
   l_reporting_level          := argument1;
   l_reporting_entity_id      := FND_NUMBER.CANONICAL_TO_NUMBER(argument2);
   l_set_of_books_id          := FND_NUMBER.CANONICAL_TO_NUMBER(argument3);
   l_chart_of_accounts_id     := FND_NUMBER.CANONICAL_TO_NUMBER(argument4);
   l_company_segment_low      := argument5;
   l_company_segment_high     := argument6;
   l_gl_date_low              := FND_DATE.CANONICAL_TO_DATE(argument7);
   l_gl_date_high             := FND_DATE.CANONICAL_TO_DATE(argument8);
   l_account_low              := argument9;
   l_account_high             := argument10;
   l_currency_code_low        := argument11;
   l_currency_code_high       := argument12;
   l_batch_source_name        := argument13;
   l_transaction_type_low     := argument14;
   l_transaction_type_high    := argument15;
   l_invoice_class            := argument16;
   l_transaction_date_low     := FND_DATE.CANONICAL_TO_DATE(argument17);
   l_transaction_date_high    := FND_DATE.CANONICAL_TO_DATE(argument18);
   l_doc_sequence_name        := argument19;
   l_doc_sequence_num_from    := argument20;
   l_doc_sequence_num_to      := argument21;


/*
 * Bug 2498344 - MRC Reporting project
 *   Fetch book type for the sob_id passed.  IF it is run for
 *   reporting book, set the reporting sob context.
 */

   BEGIN
     select mrc_sob_type_code
     into l_sob_type
     from gl_sets_of_books
     where set_of_books_id = l_set_of_books_id;
   EXCEPTION
     WHEN OTHERS THEN
       l_sob_type := 'P';
   END;

   IF l_sob_type = 'R'
   THEN
     fnd_client_info.set_currency_context(l_set_of_books_id);
   END IF;


  --
  -- Run report
  --
  -- bug39409581 added new parameters
   arrx_tx.artx_rep(
    null,
    null,
    l_gl_date_low,
    l_gl_date_high,
    l_transaction_date_low,
    l_transaction_date_high,
    l_transaction_type_low,
    l_transaction_type_high,
    null,
    null,
    l_company_segment_low,
    l_company_segment_high,
    null,
    null,
    l_currency_code_low,
    l_currency_code_high,
    null,
    l_doc_sequence_name,
    l_doc_sequence_num_from,
    l_doc_sequence_num_to,
    null,
    null,
    l_reporting_level,
    l_reporting_entity_id,
    l_account_low,
    l_account_high,
    l_batch_source_name,
    l_invoice_class,
    l_request_id,
    retcode,
    errbuf);

   commit;
EXCEPTION
    WHEN OTHERS THEN
       fa_rx_util_pkg.debug('AR_SHARED_SERVER_ERROR');
       fa_rx_util_pkg.debug(sqlcode);
       fa_rx_util_pkg.debug(sqlerrm);
       retcode := 2;
END TRANSACTION_REGISTER;

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
   argument23               in   varchar2  default  'N', -- debug flag
   argument24               in   varchar2  default  'N', -- sql trace
   argument25               in   varchar2  default  NULL,
   argument26               in   varchar2  default  NULL,
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
   argument100              in   varchar2  default  null)
is
   l_request_id                  number;
   l_set_of_books_id             number;
   l_chart_of_accounts_id        number;
   l_completed_flag              varchar2(1);
   l_posted_flag                 varchar2(1);
   l_gl_date_low                 date;
   l_gl_date_high                date;
   l_transaction_date_low        date;
   l_transaction_date_high       date;
   l_transaction_type_low        varchar2(20);
   l_transaction_type_high       varchar2(20);
   l_currency_code_low           varchar2(15);
   l_currency_code_high          varchar2(15);
   l_company_segment_low         varchar2(25);
   l_company_segment_high        varchar2(25);
   l_invoice_class_low           varchar2(20);
   l_invoice_class_high          varchar2(20);
   l_customer_name_low           varchar2(50);
   l_customer_name_high          varchar2(50);
   l_payment_method              varchar2(30);
   l_start_update_date           date;
   l_end_update_date             date;
   l_last_updated_by             number;
begin
  --
  -- SQL Trace switches and debug flags are optional
  -- but highly recommended.
  -- ATG mandate remove sql trace code
  -- if upper(substrb(argument24, 1, 1)) = 'Y' then
  --    fa_rx_util_pkg.enable_trace;
  -- end if;

   if upper(substrb(argument23, 1, 1)) = 'Y' then
      fa_rx_util_pkg.enable_debug;
   end if;

  --
  -- Assign parameters doing any necessary mappings
  -- e.g. date/number conversion
   l_request_id               := fnd_global.conc_request_id;
   l_set_of_books_id          := FND_NUMBER.CANONICAL_TO_NUMBER(argument1);
   l_chart_of_accounts_id     := FND_NUMBER.CANONICAL_TO_NUMBER(argument2);
   l_completed_flag           := argument3;
   l_posted_flag              := argument4;
   l_gl_date_low              := FND_DATE.CANONICAL_TO_DATE(argument5);
   l_gl_date_high             := FND_DATE.CANONICAL_TO_DATE(argument6);
   l_transaction_date_low     := FND_DATE.CANONICAL_TO_DATE(argument7);
   l_transaction_date_high    := FND_DATE.CANONICAL_TO_DATE(argument8);
   l_transaction_type_low     := argument9;
   l_transaction_type_high    := argument10;
   l_currency_code_low        := argument11;
   l_currency_code_high       := argument12;
   l_company_segment_low      := argument13;
   l_company_segment_high     := argument14;
   l_invoice_class_low        := argument15;
   l_invoice_class_high       := argument16;
   l_customer_name_low        := argument17;
   l_customer_name_high       := argument18;
   l_payment_method           := argument19;

  --
  -- Plug In Parameter
  --
   l_start_update_date        := FND_DATE.CANONICAL_TO_DATE(argument20);
   l_end_update_date          := FND_DATE.CANONICAL_TO_DATE(argument21);
   IF argument22 is not null THEN
      select user_id
      into l_last_updated_by
      from fnd_user
      where user_name = argument22;
   END IF;

  --
  -- Run report
   arrx_tx.artx_rep_check(
    l_completed_flag,
    l_posted_flag,
    l_gl_date_low,
    l_gl_date_high,
    l_transaction_date_low,
    l_transaction_date_high,
    l_transaction_type_low,
    l_transaction_type_high,
    l_invoice_class_low,
    l_invoice_class_high,
    l_company_segment_low,
    l_company_segment_high,
    l_customer_name_low,
    l_customer_name_high,
    l_currency_code_low,
    l_currency_code_high,
    l_payment_method,
    l_start_update_date,
    l_end_update_date,
    l_last_updated_by,
    l_request_id,
    retcode,
    errbuf);

   commit;
EXCEPTION
    WHEN OTHERS THEN
       fa_rx_util_pkg.debug('AR_SHARED_SERVER_ERROR');
       fa_rx_util_pkg.debug(sqlcode);
       fa_rx_util_pkg.debug(sqlerrm);
       retcode := 2;
END TRANSACTION_CHECK;

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
   argument100              in   varchar2  default  null)
is
   l_request_id                  number;
   l_set_of_books_id             number;
   l_chart_of_accounts_id        number;
   l_completed_flag              varchar2(1);
   l_posted_flag                 varchar2(1);
   l_gl_date_low                 date;
   l_gl_date_high                date;
   l_transaction_date_low        date;
   l_transaction_date_high       date;
   l_transaction_type_low        varchar2(20);
   l_transaction_type_high       varchar2(20);
   l_currency_code_low           varchar2(15);
   l_currency_code_high          varchar2(15);
   l_company_segment_low         varchar2(25);
   l_company_segment_high        varchar2(25);
   l_invoice_class_low           varchar2(20);
   l_invoice_class_high          varchar2(20);
   l_customer_name_low           varchar2(50);
   l_customer_name_high          varchar2(50);
   l_payment_method              varchar2(30);
   l_start_due_date              date;
   l_end_due_date                date;
begin
  --
  -- SQL Trace switches and debug flags are optional
  -- but highly recommended.
  --ATG mandate remove sql trace code
  -- if upper(substrb(argument26, 1, 1)) = 'Y' then
  --    fa_rx_util_pkg.enable_trace;
  -- end if;

   if upper(substrb(argument25, 1, 1)) = 'Y' then
      fa_rx_util_pkg.enable_debug;
   end if;

  --
  -- Assign parameters doing any necessary mappings
  -- e.g. date/number conversion
   l_request_id               := fnd_global.conc_request_id;
   l_set_of_books_id          := FND_NUMBER.CANONICAL_TO_NUMBER(argument1);
   l_chart_of_accounts_id     := FND_NUMBER.CANONICAL_TO_NUMBER(argument2);
   l_completed_flag           := argument3;
   l_posted_flag              := argument4;
   l_gl_date_low              := FND_DATE.CANONICAL_TO_DATE(argument5);
   l_gl_date_high             := FND_DATE.CANONICAL_TO_DATE(argument6);
   l_transaction_date_low     := FND_DATE.CANONICAL_TO_DATE(argument7);
   l_transaction_date_high    := FND_DATE.CANONICAL_TO_DATE(argument8);
   l_transaction_type_low     := argument9;
   l_transaction_type_high    := argument10;
   l_currency_code_low        := argument11;
   l_currency_code_high       := argument12;
   l_company_segment_low      := argument13;
   l_company_segment_high     := argument14;
   l_invoice_class_low        := argument15;
   l_invoice_class_high       := argument16;
   l_customer_name_low        := argument17;
   l_customer_name_high       := argument18;
   l_payment_method           := argument19;

  --
  -- Plug In Parameter
  --
   l_start_due_date           := FND_DATE.CANONICAL_TO_DATE(argument23);
   l_end_due_date             := FND_DATE.CANONICAL_TO_DATE(argument24);

  --
  -- Run report
   arrx_tx.artx_rep_forecast(
    l_completed_flag,
    l_posted_flag,
    l_gl_date_low,
    l_gl_date_high,
    l_transaction_date_low,
    l_transaction_date_high,
    l_transaction_type_low,
    l_transaction_type_high,
    l_invoice_class_low,
    l_invoice_class_high,
    l_company_segment_low,
    l_company_segment_high,
    l_customer_name_low,
    l_customer_name_high,
    l_currency_code_low,
    l_currency_code_high,
    l_payment_method,
    l_start_due_date,
    l_end_due_date,
    l_request_id,
    retcode,
    errbuf);

   commit;
EXCEPTION
    WHEN OTHERS THEN
       fa_rx_util_pkg.debug('AR_SHARED_SERVER_ERROR');
       fa_rx_util_pkg.debug(sqlcode);
       fa_rx_util_pkg.debug(sqlerrm);
       retcode := 2;
END RECEIPT_FORECAST;

PROCEDURE SALES_REGISTER (
   errbuf                   out NOCOPY  varchar2,
   retcode                  out NOCOPY  varchar2,
   argument1                in   varchar2,                -- set_of_books_id
   argument2                in   varchar2,                -- chart_of_accounts_id
   argument3                in   varchar2  default 'Y',   -- completed_flag
   argument4                in   varchar2  default null,  -- gl_start_date
   argument5                in   varchar2  default null,  -- gl_end_date
   argument6                in   varchar2  default 'BOTH',  -- poste_flag
   argument7                in   varchar2  default null,  -- transaction_type
   argument8                in   varchar2  default null,  -- line_invoice
   argument9                in   varchar2  default null,  -- start_invoice_num
   argument10               in   varchar2  default null,  -- end_invoice_num
   argument11               in   varchar2  default null,  -- doc_sequence_name
   argument12               in   varchar2  default null,  -- start_doc_sequence_value
   argument13               in   varchar2  default null,  -- end_doc_sequence_value
   argument14               in   varchar2  default null,  -- start_company_segment
   argument15               in   varchar2  default null,  -- end_company_segment
   argument16               in   varchar2  default null,  -- start_rec_nat_acct
   argument17               in   varchar2  default null,  -- end_rec_nat_acct
   argument18               in   varchar2  default null,  -- start_account
   argument19               in   varchar2  default null,  -- end_account
   argument20               in   varchar2  default null,  -- start_currency
   argument21               in   varchar2  default null,  -- end_currency
   argument22               in   varchar2  default null,  -- start_amount
   argument23               in   varchar2  default null, -- end_amount
   argument24               in   varchar2  default null, -- start_customer_name
   argument25               in   varchar2  default  NULL, -- end_customer_name
   argument26               in   varchar2  default  null, -- start_customer_number
   argument27               in   varchar2  default  null, -- end_customer_number
   argument28               in   varchar2  default  null, -- trace_switch
   argument29               in   varchar2  default  null, -- debug_switch
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
   argument100              in   varchar2  default  null)
is
   l_request_id                  number;
   l_set_of_books_id             number;
   l_chart_of_accounts_id        number;
   l_completed_flag              varchar2(1);
   l_posted_flag                 varchar2(1);
   l_transaction_type            varchar2(20);
   l_line_invoice                varchar2(7);
   l_start_invoice_num           varchar2(20);
   l_end_invoice_num             varchar2(20);
   l_doc_sequence_name           varchar2(30);
   l_start_doc_sequence_value    number;
   l_end_doc_sequence_value      number;
   l_start_gl_date               date;
   l_end_gl_date                 date;
   l_start_company_segment       varchar2(240);
   l_end_company_segment         varchar2(240);
   l_start_rec_nat_acct          varchar2(240);
   l_end_rec_nat_acct            varchar2(240);
   l_start_account               varchar2(240);
   l_end_account                 varchar2(240);
   l_start_currency              varchar2(25);
   l_end_currency                varchar2(25);
   l_start_amount                number;
   l_end_amount                  number;
   l_start_customer_name         varchar2(50);
   l_end_customer_name           varchar2(50);
   l_start_customer_number       varchar2(30);
   l_end_customer_number         varchar2(30);

begin
  --
  -- SQL Trace switches and debug flags are optional
  -- but highly recommended.
  --ATG mandate remove sql trace logic from files
  -- if upper(substrb(argument28, 1, 1)) = 'Y' then
  --    fa_rx_util_pkg.enable_trace;
  -- end if;

   if upper(substrb(argument29, 1, 1)) = 'Y' then
      fa_rx_util_pkg.enable_debug;
   end if;

  --
  -- Assign parameters doing any necessary mappings
  -- e.g. date/number conversion
   l_request_id               := fnd_global.conc_request_id;
   l_set_of_books_id          := FND_NUMBER.CANONICAL_TO_NUMBER(argument1);
   l_chart_of_accounts_id     := FND_NUMBER.CANONICAL_TO_NUMBER(argument2);
   l_completed_flag           := argument3;
   if argument6 = 'BOTH' then
   	l_posted_flag           := null;
   elsif argument6 = 'POSTED' then
	l_posted_flag		:= 'Y';
   elsif argument6 = 'UNPOSTED' then
	l_posted_flag		:= 'N';
   else
	l_posted_flag		:= argument6;
   end if;
   l_transaction_type         := argument7;
   l_line_invoice   	      := argument8;
   l_start_invoice_num        := argument9;
   l_end_invoice_num          := argument10;
   l_doc_sequence_name        := argument11;
   l_start_doc_sequence_value := FND_NUMBER.CANONICAL_TO_NUMBER(argument12);
   l_end_doc_sequence_value   := FND_NUMBER.CANONICAL_TO_NUMBER(argument13);
   l_start_gl_date            := FND_DATE.CANONICAL_TO_DATE(argument4);
   l_end_gl_date  	      := FND_DATE.CANONICAL_TO_DATE(argument5);
   l_start_company_segment    := argument14;
   l_end_company_segment      := argument15;
   l_start_rec_nat_acct       := argument16;
   l_end_rec_nat_acct         := argument17;
   l_start_account            := argument18;
   l_end_account              := argument19;
   l_start_currency           := argument20;
   l_end_currency             := argument21;
   l_start_amount             := FND_NUMBER.CANONICAL_TO_NUMBER(argument22);
   l_end_amount               := FND_NUMBER.CANONICAL_TO_NUMBER(argument23);
   l_start_customer_name      := argument24;
   l_end_customer_name        := argument25;
   l_start_customer_number    := argument26;
   l_end_customer_number      := argument27;

-- For end currency code
    if l_end_currency is null then
	l_end_currency := l_start_currency;
    end if;

  --
  -- Run report
   arrx_tx.artx_sales_rep(
    l_completed_flag,
    l_posted_flag,
    l_transaction_type,
    l_line_invoice,
    l_start_invoice_num,
    l_end_invoice_num,
    l_doc_sequence_name,
    l_start_doc_sequence_value,
    l_end_doc_sequence_value,
    l_start_gl_date,
    l_end_gl_date,
    l_start_company_segment,
    l_end_company_segment,
    l_start_rec_nat_acct,
    l_end_rec_nat_acct,
    l_start_account,
    l_end_account,
    l_start_currency,
    l_end_currency,
    l_start_amount,
    l_end_amount,
    l_start_customer_name,
    l_end_customer_name,
    l_start_customer_number,
    l_end_customer_number,
    l_request_id,
    retcode,
    errbuf);

   commit;
EXCEPTION
    WHEN OTHERS THEN
       fa_rx_util_pkg.debug('AR_SHARED_SERVER_ERROR');
       fa_rx_util_pkg.debug(sqlcode);
       fa_rx_util_pkg.debug(sqlerrm);
       retcode := 2;
END SALES_REGISTER;

-- Bug 2008925.  Adding new procedure for Purge API
PROCEDURE PURGE_TRANSACTION_DATA(
   p_request_id             in   number,
   p_rows_affected          out NOCOPY  number)
is
   l_request_id             number;
begin
   l_request_id := p_request_id;

   delete from ar_transactions_rep_itf
   where request_id = l_request_id;
   p_rows_affected := SQL%ROWCOUNT;

EXCEPTION
   WHEN OTHERS THEN
      p_rows_affected := 0;
      fa_rx_util_pkg.log(sqlcode);
      fa_rx_util_pkg.log(sqlerrm);
END PURGE_TRANSACTION_DATA;

END ARRX_C_TRX;

/
