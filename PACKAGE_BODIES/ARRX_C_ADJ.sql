--------------------------------------------------------
--  DDL for Package Body ARRX_C_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_C_ADJ" as
/* $Header: ARRXCADB.pls 120.5 2005/10/30 04:25:19 appldev ship $   */


PROCEDURE ADJUSTMENT_REGISTER (
   errbuf                   out NOCOPY  varchar2,
   retcode                  out NOCOPY  varchar2,
   argument1                in   varchar2,               -- reporting level
   argument2                in   varchar2,               -- reporting context
   argument3                in   varchar2,               -- sob_id
   argument4                in   varchar2,               -- coa_id
   argument5                in   varchar2,               -- co_seg_low
   argument6                in   varchar2,               -- co_seg_high
   argument7                in   varchar2,               -- gl_date_from
   argument8                in   varchar2,               -- gl_date_to
   argument9                in   varchar2,               -- currency_type_low
   argument10               in   varchar2,               -- currency_type_high
   argument11               in   varchar2,               -- adj date_low
   argument12               in   varchar2,               -- adj date_high
   argument13               in   varchar2,               -- trx due_date_low
   argument14               in   varchar2,               -- trx due_date_high
   argument15               in   varchar2,               -- trx_type_low
   argument16               in   varchar2,               -- trx_type_high
   argument17               in   varchar2,               -- adj_type_low
   argument18               in   varchar2,               -- adj_type_high
   argument19               in   varchar2,               -- doc seq name
   argument20               in   varchar2,               -- doc seq low
   argument21               in   varchar2,               -- doc seq high
   argument22               in   varchar2  default  'N', -- debug flag
   argument23               in   varchar2  default  'N', -- sql trace
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
   l_sob_id                      NUMBER;
   l_coa_id			 number;
   l_gl_date_low                 date;
   l_gl_date_high                date;
   l_trx_date_low                date;
   l_trx_date_high               date;
   l_due_date_low                date;
   l_due_date_high               date;
   l_invoice_type_low            varchar2(50);
   l_invoice_type_high           varchar2(50);
   l_adj_type_low                varchar2(30);
   l_adj_type_high               varchar2(30);
   l_currency_code_low           varchar2(15);
   l_currency_code_high          varchar2(15);
   l_co_seg_low                  varchar2(30);
   l_co_seg_high                 varchar2(30);
   l_doc_seq_name		 varchar2(30);
   l_doc_seq_low		 number;
   l_doc_seq_high		 number;

begin
  --
  -- SQL Trace switches and debug flags are optional
  -- but highly recommended.

  --ATG mandate remove code for sql trace
  -- if upper(substrb(argument23, 1, 1)) = 'Y' then
  --    fa_rx_util_pkg.enable_trace;
  -- end if;

   if upper(substrb(argument22, 1, 1)) = 'Y' then
      fa_rx_util_pkg.enable_debug;
   end if;

   fa_rx_util_pkg.debug('ADJUSTMENT_REGISTER called with parameters
                         Reporting Level        :   '||argument1||'
                         Reporting Entity ID    :   '||argument2||'
                         Set of Books ID        :   '||argument3||'
                         Chart of Accounts ID   :   '||argument4||'
                         Company Segment Low    :   '||argument5||'
                         Company Segment High   :   '||argument6||'
                         GL Date From           :   '||argument7||'
                         GL Date To             :   '||argument8||'
                         Entered Currency Low   :   '||argument9||'
                         Entered Currency High  :   '||argument10||'
                         Adjustment Date From   :   '||argument11||'
                         Adjustment Date To     :   '||argument12||'
                         Trx Due Date From      :   '||argument13||'
                         Trx Due Date To        :   '||argument14||'
                         Trx Type Low           :   '||argument15||'
                         Trx Type High          :   '||argument16||'
                         Adjustment Type Low    :   '||argument17||'
                         Adjustment Type High   :   '||argument18||'
                         Doc Sequence Name      :   '||argument19||'
                         Doc Sequence Num Low   :   '||argument20||'
                         Doc Sequence Num High  :   '||argument21);
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
   l_gl_date_low	      := FND_DATE.CANONICAL_TO_DATE(argument7);
   l_gl_date_high             := FND_DATE.CANONICAL_TO_DATE(argument8);
   l_currency_code_low        := argument9;
   l_currency_code_high       := argument10;
   l_trx_date_low             := FND_DATE.CANONICAL_TO_DATE(argument11);
   l_trx_date_high            := FND_DATE.CANONICAL_TO_DATE(argument12);
   l_due_date_low             := FND_DATE.CANONICAL_TO_DATE(argument13);
   l_due_date_high            := FND_DATE.CANONICAL_TO_DATE(argument14);
   l_invoice_type_low         := argument15;
   l_invoice_type_high        := argument16;
   l_adj_type_low             := argument17;
   l_adj_type_high            := argument18;
   l_doc_seq_name             := argument19;
   l_doc_seq_low              := argument20;
   l_doc_seq_high             := argument21;

  --
  -- Run report
   arrx_adj.aradj_rep (
   l_request_id,
   l_reporting_level,
   l_reporting_entity_id,
   l_sob_id,
   l_coa_id,
   l_co_seg_low,
   l_co_seg_high,
   l_gl_date_low,
   l_gl_date_high,
   l_currency_code_low,
   l_currency_code_high,
   l_trx_date_low,
   l_trx_date_high,
   l_due_date_low,
   l_due_date_high,
   l_invoice_type_low,
   l_invoice_type_high,
   l_adj_type_low,
   l_adj_type_high,
   l_doc_seq_name,
   l_doc_seq_low,
   l_doc_seq_high,
   retcode,
   errbuf);

   commit;
EXCEPTION
    WHEN OTHERS THEN
       fa_rx_util_pkg.debug('AR_SHARED_SERVER_ERROR');
       fa_rx_util_pkg.debug(sqlcode);
       fa_rx_util_pkg.debug(sqlerrm);
       retcode := 2;
END ADJUSTMENT_REGISTER;



END ARRX_C_ADJ;

/
