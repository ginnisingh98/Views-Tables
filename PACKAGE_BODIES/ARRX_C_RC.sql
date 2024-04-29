--------------------------------------------------------
--  DDL for Package Body ARRX_C_RC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_C_RC" as
/* $Header: ARRXCRCB.pls 120.10.12010000.1 2008/07/24 16:53:21 appldev ship $ */

-------------------
-- Receipt Register
-------------------
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
   argument100              in   varchar2  default  null)
is
   l_request_id                  number;
   l_reporting_level             VARCHAR2(50);
   l_reporting_entity_id         NUMBER;
   l_sob_id                      NUMBER;
   l_coa_id                      NUMBER;
   l_co_seg_low                  VARCHAR2(25);
   l_co_seg_high                 VARCHAR2(25);
   l_batch_name_low              varchar2(20);
   l_batch_name_high             varchar2(20);
   l_customer_name_low           varchar2(240);
   l_customer_name_high          varchar2(240);
   l_deposit_date_low            date;
   l_deposit_date_high           date;
   l_receipt_status_low          varchar2(30);
   l_receipt_status_high         varchar2(30);
   l_receipt_number_low          varchar2(30);
   l_receipt_number_high         varchar2(30);
   l_invoice_number_low          varchar2(30)    := NULL; --Bug 1579930
   l_invoice_number_high         varchar2(30)    := NULL; --Bug 1579930
   l_receipt_date_low            date;
   l_receipt_date_high           date;
   l_gl_date_low                 date;
   l_gl_date_high                date;
   l_currency_code               varchar2(15);
   l_bank_account_name           varchar2(80);
   l_payment_method              varchar2(30);
   l_confirmed_flag              varchar2(1);
   l_doc_sequence_name		 varchar2(30);
   l_doc_sequence_number_from	 number;
   l_doc_sequence_number_to	 number;


begin
  --
  -- SQL Trace switches and debug flags are optional
  -- but highly recommended.
  --ATG mandate remove sql trace code from files
  -- if upper(substrb(argument29, 1, 1)) = 'Y' then
  --    fa_rx_util_pkg.enable_trace;
  -- end if;

  if upper(substrb(argument28, 1, 1)) = 'Y' then
     fa_rx_util_pkg.enable_debug;
  end if;

   fa_rx_util_pkg.debug('RECEIPT_REGISTER called with parameters
                         Reporting Level        :   '||argument1||'
                         Reporting Entity ID    :   '||argument2||'
                         Set of Books ID        :   '||argument3||'
                         Chart of Accounts ID   :   '||argument4||'
                         Company Segment Low    :   '||argument5||'
                         Company Segment High   :   '||argument6||'
                         GL Date From           :   '||argument7||'
                         GL Date To             :   '||argument8||'
                         Entered Currency       :   '||argument9||'
                         Batch Name Low         :   '||argument10||'
                         Batch Name High        :   '||argument11||'
                         Customer Name Low      :   '||argument12||'
                         Customer Name High     :   '||argument13||'
                         Deposit Date Low       :   '||argument14||'
                         Deposit Date High      :   '||argument15||'
                         Receipt Status Low     :   '||argument16||'
                         Receipt Status High    :   '||argument17||'
                         Receipt Number Low     :   '||argument18||'
                         Receipt Number High    :   '||argument19||'
                         Receipt Date Low       :   '||argument20||'
                         Receipt Date High      :   '||argument21);
  --
  -- Assign parameters doing any necessary mappings
  -- e.g. date/number conversion
   l_request_id               := fnd_global.conc_request_id;
   l_reporting_level          := argument1;
   l_reporting_entity_id      := argument2;
   l_sob_id                   := argument3;
   l_coa_id                   := argument4;
   l_co_seg_low               := argument5;
   l_co_seg_high              := argument6;
   l_gl_date_low              := FND_DATE.CANONICAL_TO_DATE(argument7);
   l_gl_date_high             := FND_DATE.CANONICAL_TO_DATE(argument8);
   l_currency_code            := argument9;
   l_batch_name_low           := argument10;
   l_batch_name_high          := argument11;
   l_customer_name_low        := argument12;
   l_customer_name_high       := argument13;
   l_deposit_date_low         := FND_DATE.CANONICAL_TO_DATE(argument14);
   l_deposit_date_high        := FND_DATE.CANONICAL_TO_DATE(argument15);
   l_receipt_status_low       := argument16;
   l_receipt_status_high      := argument17;
   l_receipt_number_low       := argument18;
   l_receipt_number_high      := argument19;
   l_receipt_date_low         := FND_DATE.CANONICAL_TO_DATE(argument20);
   l_receipt_date_high        := FND_DATE.CANONICAL_TO_DATE(argument21);
   l_bank_account_name        := argument22;
   l_payment_method           := argument23;
   l_confirmed_flag           := argument24;
   l_doc_sequence_name	      := argument25;
   l_doc_sequence_number_from := argument26;
   l_doc_sequence_number_to   := argument27;
  --
  -- Run report
   arrx_rc.arrc_rep (
    l_reporting_level,
    l_reporting_entity_id,
    l_sob_id,
    l_coa_id,
    l_co_seg_low,
    l_co_seg_high,
    l_gl_date_low,
    l_gl_date_high,
    l_currency_code,
    l_batch_name_low,
    l_batch_name_high,
    l_customer_name_low,
    l_customer_name_high,
    l_deposit_date_low,
    l_deposit_date_high,
    l_receipt_status_low,
    l_receipt_status_high,
    l_receipt_number_low,
    l_receipt_number_high,
    l_invoice_number_low,  --Bug 1579930
    l_invoice_number_high, --Bug 1579930
    l_receipt_date_low,
    l_receipt_date_high,
    l_bank_account_name,
    l_payment_method,
    l_confirmed_flag,
    l_doc_sequence_name,
    l_doc_sequence_number_from,
    l_doc_sequence_number_to,
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
END RECEIPT_REGISTER;

----------------------------
-- Actual Receipts Register
----------------------------
PROCEDURE ACTUAL_RECEIPT(
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
   argument100              in   varchar2  default  null)
is
   l_request_id                  number;
   l_reporting_level             VARCHAR2(50);
   l_reporting_entity_id         NUMBER;
   l_sob_id                      NUMBER;
   l_coa_id                      NUMBER;
   l_batch_name_low              varchar2(20);
   l_batch_name_high             varchar2(20);
   l_customer_name_low           varchar2(240);
   l_customer_name_high          varchar2(240);
   l_deposit_date_low            date;
   l_deposit_date_high           date;
   l_receipt_status_low          varchar2(30);
   l_receipt_status_high         varchar2(30);
   l_receipt_number_low          varchar2(30);
   l_receipt_number_high         varchar2(30);
   l_receipt_date_low            date;
   l_receipt_date_high           date;
   l_gl_date_low                 date;
   l_gl_date_high                date;
   l_currency_code               varchar2(15);
   l_bank_account_name           varchar2(80);
   l_payment_method              varchar2(30);
   l_confirmed_flag              varchar2(1);

begin
  --
  -- SQL Trace switches and debug flags are optional
  -- but highly recommended.
  --ATG mandate remove sql trace code from files
  -- if upper(substrb(argument20, 1, 1)) = 'Y' then
  --    fa_rx_util_pkg.enable_trace;
  -- end if;

    if upper(substrb(argument23, 1, 1)) = 'Y' then
      fa_rx_util_pkg.enable_debug;
    end if;

  --
  -- Assign parameters doing any necessary mappings
  -- e.g. date/number conversion
   l_request_id               := fnd_global.conc_request_id;
   l_reporting_level          := argument1;
   l_reporting_entity_id      := argument2;
   l_sob_id                   := argument3;
   l_coa_id                   := argument4;
   l_batch_name_low           := argument5;
   l_batch_name_high          := argument6;
   l_customer_name_low        := argument7;
   l_customer_name_high       := argument8;
   l_deposit_date_low         := FND_DATE.CANONICAL_TO_DATE(argument9);
   l_deposit_date_high        := FND_DATE.CANONICAL_TO_DATE(argument10);
   l_receipt_status_low       := argument11;
   l_receipt_status_high      := argument12;
   l_receipt_number_low       := argument13;
   l_receipt_number_high      := argument14;
   l_receipt_date_low         := FND_DATE.CANONICAL_TO_DATE(argument15);
   l_receipt_date_high        := FND_DATE.CANONICAL_TO_DATE(argument16);
   l_gl_date_low              := FND_DATE.CANONICAL_TO_DATE(argument17);
   l_gl_date_high             := FND_DATE.CANONICAL_TO_DATE(argument18);
   l_currency_code            := argument19;
   l_bank_account_name        := argument20;
   l_payment_method           := argument21;
   l_confirmed_flag           := argument22;
  --
  -- Run report
   arrx_rc.arrc_rep_actual (
    l_reporting_level,
    l_reporting_entity_id,
    l_sob_id,
    l_coa_id,
    l_batch_name_low,
    l_batch_name_high,
    l_customer_name_low,
    l_customer_name_high,
    l_deposit_date_low,
    l_deposit_date_high,
    l_receipt_status_low,
    l_receipt_status_high,
    l_receipt_number_low,
    l_receipt_number_high,
    l_receipt_date_low,
    l_receipt_date_high,
    l_gl_date_low,
    l_gl_date_high,
    l_currency_code,
    l_bank_account_name,
    l_payment_method,
    l_confirmed_flag,
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
END ACTUAL_RECEIPT;

-----------------------------
-- Applied Receipts Register
-----------------------------
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
   argument100              in   varchar2  default  null)


is

   l_request_id                  number;
   l_reporting_level             VARCHAR2(50);
   l_reporting_entity_id         NUMBER;
   l_set_of_books_id             number;
   l_coa_id                      NUMBER;
   l_co_seg_low                  VARCHAR2(25);
   l_co_seg_high                 VARCHAR2(25);
   l_gl_date_low                 date;
   l_gl_date_high                date;
   l_currency_code               varchar2(15);
   l_batch_name_low              varchar2(20);
   l_batch_name_high             varchar2(20);
   l_customer_name_low           varchar2(240);
   l_customer_name_high          varchar2(240);
   l_customer_number_low	 varchar2(30);
   l_customer_number_high	 varchar2(30);
   l_apply_date_low              date;
   l_apply_date_high             date;
   l_receipt_number_low          varchar2(30);
   l_receipt_number_high         varchar2(30);
   l_invoice_number_low		 varchar2(30);
   l_invoice_number_high	 varchar2(30);
   l_invoice_type_low		 varchar2(30);
   l_invoice_type_high		 varchar2(30);
   l_profile_rsob_id             NUMBER;
   l_client_info_rsob_id         NUMBER;
   l_sob_type                    varchar2(1);

begin

  l_profile_rsob_id     := NULL;
  l_client_info_rsob_id := NULL;
  l_sob_type            := 'P';

   IF upper(argument24) LIKE 'Y%' then
     fa_rx_util_pkg.enable_debug;
   END IF;

  --ATG mandate remove sql trace from code
  --IF Upper(argument22) LIKE 'Y%' then
  --   fa_rx_util_pkg.enable_trace;

  --END IF;

  --
  -- Assign parameters doing any necessary mappings
  -- e.g. date/number conversion

   l_request_id               := fnd_global.conc_request_id;
   l_reporting_level          := argument1;
   l_reporting_entity_id      := argument2;
   l_set_of_books_id          := argument3;
   l_coa_id		      := argument4;
   l_co_seg_low               := argument5;
   l_co_seg_high              := argument6;
   l_gl_date_low              := FND_DATE.CANONICAL_TO_DATE(argument7);
   l_gl_date_high             := FND_DATE.CANONICAL_TO_DATE(argument8);
   l_currency_code            := argument9;
   l_batch_name_low           := argument10;
   l_batch_name_high          := argument11;
   l_customer_name_low        := argument12;
   l_customer_name_high       := argument13;
   l_customer_number_low      := argument14;
   l_customer_number_high     := argument15;
   l_apply_date_low           := FND_DATE.CANONICAL_TO_DATE(argument16);
   l_apply_date_high          := FND_DATE.CANONICAL_TO_DATE(argument17);
   l_receipt_number_low       := argument18;
   l_receipt_number_high      := argument19;
   l_invoice_number_low       := argument20;
   l_invoice_number_high      := argument21;
   l_invoice_type_low         := argument22;
   l_invoice_type_high	      := argument23;

/*
 * Bug 2498344 - MRC Reporting project
 *   Fetch book type for the sob_id passed.  IF it is run for
 *   reporting book, set the reporting sob context.


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
*/

  if l_reporting_level= 1000 then
    l_set_of_books_id := l_reporting_entity_id;
  elsif l_reporting_level = 3000 then
	  select set_of_books_id into l_set_of_books_id
	  from ar_system_parameters_all
	   where org_id = l_reporting_entity_id;
  end if;

  l_sob_type:='P';

  --
  -- Run report
   arrx_rc.arar_rep (
    l_reporting_level,
    l_reporting_entity_id,
    l_set_of_books_id,
    l_coa_id,
    l_co_seg_low,
    l_co_seg_high,
    l_gl_date_low,
    l_gl_date_high,
    l_currency_code,
    l_batch_name_low,
    l_batch_name_high,
    l_customer_name_low,
    l_customer_name_high,
    l_customer_number_low,
    l_customer_number_high,
    l_apply_date_low,
    l_apply_date_high,
    l_receipt_number_low,
    l_receipt_number_high,
    l_invoice_number_low,
    l_invoice_number_high,
    l_invoice_type_low,
    l_invoice_type_high,
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
END AR_APPL_REC_REGISTER;

---------------------------------------
-- Miscellaneous Receipts Register
---------------------------------------
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
   argument100              in   varchar2  default  null)
is

   l_request_id                  number;
   l_reporting_level             VARCHAR2(50);
   l_reporting_entity_id         NUMBER;
   l_set_of_books_id             number;
   l_coa_id                      NUMBER;
   l_co_seg_low                  VARCHAR2(25);
   l_co_seg_high                 VARCHAR2(25);
   l_gl_date_low                 date;
   l_gl_date_high                date;
   l_currency_code               varchar2(15);
   l_batch_name_low              varchar2(20);
   l_batch_name_high             varchar2(20);
   l_deposit_date_low            date;
   l_deposit_date_high           date;
   l_receipt_number_low          varchar2(30);
   l_receipt_number_high         varchar2(30);
   l_doc_sequence_name           varchar2(30);
   l_doc_sequence_number_from    number(15);
   l_doc_sequence_number_to      number(15);

begin


  -- SQL Trace switches and debug flags are optional
  -- but highly recommended.
  --ATG mandate remove sql trace logic from files
  -- if upper(substrb(argument13, 1, 1)) = 'Y' then
  --    fa_rx_util_pkg.enable_trace;
  -- end if;

   if upper(substrb(argument19, 1, 1)) = 'Y' then
      fa_rx_util_pkg.enable_debug;
   end if;

   fa_rx_util_pkg.debug('AR_MISC_TRX_REGISTER called with parameters
                         Reporting Level        :   '||argument1||'
                         Reporting Entity ID    :   '||argument2||'
                         Set of Books ID        :   '||argument3||'
                         Chart of Accounts ID   :   '||argument4||'
                         Company Segment Low    :   '||argument5||'
                         Company Segment High   :   '||argument6||'
                         GL Date From           :   '||argument7||'
                         GL Date To             :   '||argument8||'
                         Entered Currency       :   '||argument9||'
                         Batch Name Low         :   '||argument10||'
                         Batch Name High        :   '||argument11||'
                         Deposit Date Low       :   '||argument12||'
                         Deposit Date High      :   '||argument13||'
                         Receipt Number Low     :   '||argument14||'
                         Receipt Number High    :   '||argument15);
  --
  -- Assign parameters doing any necessary mappings
  -- e.g. date/number conversion
   l_request_id                  := fnd_global.conc_request_id;
   l_reporting_level             := argument1;
   l_reporting_entity_id         := argument2;
   l_set_of_books_id             := argument3;
   l_coa_id                      := argument4;
   l_co_seg_low                  := argument5;
   l_co_seg_high                 := argument6;
   l_gl_date_low                 := FND_DATE.CANONICAL_TO_DATE(argument7);
   l_gl_date_high                := FND_DATE.CANONICAL_TO_DATE(argument8);
   l_currency_code               := argument9;
   l_batch_name_low              := argument10;
   l_batch_name_high             := argument11;
   l_deposit_date_low            := FND_DATE.CANONICAL_TO_DATE(argument12);
   l_deposit_date_high           := FND_DATE.CANONICAL_TO_DATE(argument13);
   l_receipt_number_low          := argument14;
   l_receipt_number_high         := argument15;
   l_doc_sequence_name           := argument17;
   l_doc_sequence_number_from    := argument17;
   l_doc_sequence_number_to      := argument18;


  --
  -- Run report
   arrx_rc.armtr_rep (
    l_reporting_level,
    l_reporting_entity_id,
    l_set_of_books_id,
    l_coa_id,
    l_co_seg_low,
    l_co_seg_high,
    l_gl_date_low,
    l_gl_date_high,
    l_currency_code,
    l_batch_name_low,
    l_batch_name_high,
    l_deposit_date_low,
    l_deposit_date_high,
    l_receipt_number_low,
    l_receipt_number_high,
    l_doc_sequence_name,
    l_doc_sequence_number_from,
    l_doc_sequence_number_to,
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

END AR_MISC_TRX_REGISTER;







END ARRX_C_RC;

/
