--------------------------------------------------------
--  DDL for Package Body ARRX_C_OTH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_C_OTH" as
/* $Header: ARRXCOTB.pls 120.0 2005/01/26 21:26:36 vcrisost noship $ */

PROCEDURE AR_OTH_REC_APP (
   errbuf                   out NOCOPY  varchar2,
   retcode                  out NOCOPY  varchar2,
   argument1                in   varchar2,               -- reporting level
   argument2                in   varchar2,               -- reporting context
   argument3                in   varchar2,               -- sob_id
   argument4                in   varchar2,               -- coa_id
   argument5                in   varchar2,               -- co_seg_low
   argument6                in   varchar2,               -- co_seg_high
   argument7                in   varchar2,               -- application_gl_date_from
   argument8                in   varchar2,               -- application_gl_date_to
   argument9                in   varchar2,               -- entered_currency
   argument10               in   varchar2,               -- customer_name_low
   argument11               in   varchar2,               -- customer_name_high
   argument12               in   varchar2,               -- customer_number_low
   argument13               in   varchar2,               -- customer_number_high
   argument14               in   varchar2,               -- receipt_date_from
   argument15               in   varchar2,               -- receipt_date_to
   argument16               in   varchar2,               -- apply_date_from
   argument17               in   varchar2,               -- apply_date_to
   argument18               in   varchar2,               -- remittance_batch_name_low
   argument19               in   varchar2,               -- remittance_batch_name_high
   argument20               in   varchar2,               -- receipt batch name low
   argument21               in   varchar2,               -- receipt batch name high
   argument22               in   varchar2,               -- receipt number low
   argument23               in   varchar2,               -- receipt number high
   argument24               in   varchar2,               -- application type
   argument25               in   varchar2  default  'N', -- debug flag
   argument26               in   varchar2  default  'N', -- sql trace
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
   l_co_seg_low                  varchar2(30);
   l_co_seg_high                 varchar2(30);
   l_gl_date_low                 date;
   l_gl_date_high                date;
   l_currency_code               varchar2(15);
   l_customer_name_low           VARCHAR2(50);
   l_customer_name_high          VARCHAR2(50);
   l_customer_number_low         VARCHAR2(30);
   l_customer_number_high        VARCHAR2(30);
   l_rct_date_low                date;
   l_rct_date_high               date;
   l_apply_date_low              date;
   l_apply_date_high             date;
   l_remit_batch_low             varchar2(20);
   l_remit_batch_high            varchar2(20);
   l_rct_batch_low               varchar2(20);
   l_rct_batch_high              varchar2(20);
   l_rct_num_low		 varchar2(15);
   l_rct_num_high		 varchar2(15);
   l_app_type                    varchar2(30);

begin
  --
  -- SQL Trace switches and debug flags are optional
  -- but highly recommended.

   if upper(substrb(argument25, 1, 1)) = 'Y' then
      fa_rx_util_pkg.enable_debug;
   end if;

   fa_rx_util_pkg.debug('OTHER RECEIPT APPLICATIONS  with parameters
                         Reporting Level        :   '||argument1||'
                         Reporting Entity ID    :   '||argument2||'
                         Set of Books ID        :   '||argument3||'
                         Chart of Accounts ID   :   '||argument4||'
                         Company Segment Low    :   '||argument5||'
                         Company Segment High   :   '||argument6||'
                         Appl GL Date From      :   '||argument7||'
                         Appl GL Date To        :   '||argument8||'
                         Entered Currency       :   '||argument9||'
                         Customer Name Low      :   '||argument10||'
                         Customer Name High     :   '||argument11||'
                         Customer Number Low    :   '||argument12||'
                         Customer Number High   :   '||argument13||'
                         Receipt Date From      :   '||argument14||'
                         Receipt Date To        :   '||argument15||'
                         Apply Date From        :   '||argument16||'
                         Apply Date To          :   '||argument17||'
                         Remit Batch Name Low   :   '||argument18||'
                         Remit Batch Name High  :   '||argument19||'
                         Receipt Batch Name Low :   '||argument20||'
                         Receipt Batch Name High:   '||argument21||'
                         Receipt Number Low     :   '||argument22||'
                         Receipt Number high    :   '||argument23||'
                         Application Type       :   '||argument24);

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
   l_customer_name_low        := argument10;
   l_customer_name_high       := argument11;
   l_customer_number_low      := argument12;
   l_customer_number_high     := argument13;
   l_rct_date_low             := FND_DATE.CANONICAL_TO_DATE(argument14);
   l_rct_date_high            := FND_DATE.CANONICAL_TO_DATE(argument15);
   l_apply_date_low           := FND_DATE.CANONICAL_TO_DATE(argument16);
   l_apply_date_high          := FND_DATE.CANONICAL_TO_DATE(argument17);
   l_remit_batch_low          := argument18;
   l_remit_batch_high         := argument19;
   l_rct_batch_low            := argument20;
   l_rct_batch_high           := argument21;
   l_rct_num_low              := argument22;
   l_rct_num_high             := argument23;
   l_app_type                 := argument24;

  --
  -- Run report
   arrx_oth.oth_rec_app (
   l_request_id,
   l_reporting_level,
   l_reporting_entity_id,
   l_sob_id,
   l_coa_id,
   l_co_seg_low,
   l_co_seg_high,
   l_gl_date_low,
   l_gl_date_high,
   l_currency_code,
   l_customer_name_low,
   l_customer_name_high,
   l_customer_number_low,
   l_customer_number_high,
   l_rct_date_low,
   l_rct_date_high,
   l_apply_date_low,
   l_apply_date_high,
   l_remit_batch_low,
   l_remit_batch_high,
   l_rct_batch_low,
   l_rct_batch_high,
   l_rct_num_low,
   l_rct_num_high,
   l_app_type,
   retcode,
   errbuf);

   commit;
EXCEPTION
    WHEN OTHERS THEN
       fa_rx_util_pkg.debug('AR_SHARED_SERVER_ERROR');
       fa_rx_util_pkg.debug(sqlcode);
       fa_rx_util_pkg.debug(sqlerrm);
       retcode := 2;
END AR_OTH_REC_APP;

END ARRX_C_OTH;

/
