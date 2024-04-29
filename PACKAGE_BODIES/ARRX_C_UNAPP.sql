--------------------------------------------------------
--  DDL for Package Body ARRX_C_UNAPP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_C_UNAPP" AS
/* $Header: ARRXCUNB.pls 120.2 2006/06/24 06:06:35 ggadhams noship $ */

PROCEDURE AR_UNAPP_REC_REGISTER (
   errbuf                   out NOCOPY  varchar2,
   retcode                  out NOCOPY  varchar2,
   argument1                in   varchar2,                -- reporting_level
   argument2                in   varchar2,                -- reporting_entity_id
   argument3                in   varchar2,                -- set_of_books_id
   argument4                in   varchar2,                -- coaid
   argument5                in   varchar2,                -- company_segment_low
   argument6                in   varchar2,                -- company_segment_high
   argument7                in   varchar2,                -- gl_date_from
   argument8                in   varchar2,                -- gl_date_to
   argument9                in   varchar2,                -- entered_currency
   argument10               in   varchar2,                -- batch_name_low
   argument11               in   varchar2,                -- batch_name_high
   argument12               in   varchar2,                -- batch_source_name_low
   argument13               in   varchar2,                -- batch_source_name_high
   argument14               in   varchar2,                -- customer_name_low
   argument15               in   varchar2,                -- customer_name_high
   argument16               in   varchar2,                -- customer_number_low
   argument17               in   varchar2,                -- customer_number_high
   argument18               in   varchar2,                -- receipt_number_low
   argument19               in   varchar2,                -- receipt_number_high
   argument20               in   varchar2  default  'N',  -- debug flag
   argument21               in   varchar2  default  'N',  -- sql trace
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
   argument100              in   varchar2  default  null) IS

   l_request_id             NUMBER;
   l_reporting_level        VARCHAR2(50);
   l_reporting_entity_id    NUMBER;
   l_sob_id                 NUMBER;
   l_coa_id                 NUMBER;
   l_co_seg_low             VARCHAR2(25);
   l_co_seg_high            VARCHAR2(25);
   l_gl_date_from           DATE;
   l_gl_date_to             DATE;
   l_entered_currency       VARCHAR2(15);
   l_batch_name_low         VARCHAR2(20);
   l_batch_name_high        VARCHAR2(20);
   l_batch_src_low          VARCHAR2(50);
   l_batch_src_high         VARCHAR2(50);
   l_customer_name_low      VARCHAR2(50);
   l_customer_name_high     VARCHAR2(50);
   l_customer_number_low    VARCHAR2(30);
   l_customer_number_high   VARCHAR2(30);
   l_receipt_number_low     VARCHAR2(30);
   l_receipt_number_high    VARCHAR2(30);
   l_sob_type               VARCHAR2(1) := 'P';

BEGIN

   /* Enable debug based on the input */
  IF upper(substr(argument20,1,1)) = 'Y' THEN
     fa_rx_util_pkg.enable_debug;
   END IF;

   fa_rx_util_pkg.debug('AR_UNAPP_REC_REGISTER called with parameters
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
                         Batch Source Name Low  :   '||argument12||'
                         Batch Source Name High :   '||argument13||'
                         Customer Name Low      :   '||argument14||'
                         Customer Name High     :   '||argument15||'
                         Customer Number Low    :   '||argument16||'
                         Customer Number High   :   '||argument17||'
                         Receipt Number Low     :   '||argument18||'
                         Receipt Number High    :   '||argument19);

  /* Get the request id */
  l_request_id := fnd_global.conc_request_id;

  /* Assign the parameters to the local variables */
  l_reporting_level      :=   argument1;
  l_reporting_entity_id  :=   argument2;
  l_sob_id               :=   argument3;
  l_coa_id               :=   argument4;
  l_co_seg_low           :=   argument5;
  l_co_seg_high          :=   argument6;
  l_gl_date_from         :=   fnd_date.canonical_to_date(argument7);
  l_gl_date_to           :=   fnd_date.canonical_to_date(argument8);
  l_entered_currency     :=   argument9;
  l_batch_name_low       :=   argument10;
  l_batch_name_high      :=   argument11;
  l_batch_src_low        :=   argument12;
  l_batch_src_high       :=   argument13;
  l_customer_name_low    :=   argument14;
  l_customer_name_high   :=   argument15;
  l_customer_number_low  :=   argument16;
  l_customer_number_high :=   argument17;
  l_receipt_number_low   :=   argument18;
  l_receipt_number_high  :=   argument19;

  /* If the report is run for RSOB, set the set of books context
   BEGIN
     select mrc_sob_type_code
     into l_sob_type
     from gl_sets_of_books
     where set_of_books_id = l_sob_id;
   EXCEPTION
     WHEN OTHERS THEN
       l_sob_type := 'P';
   END;

   IF l_sob_type = 'R'
   THEN
     fnd_client_info.set_currency_context(l_sob_id);
   END IF; */

/* Bug 5244326Selecting the SOB based on the Reporting context*/

   IF l_reporting_level = 1000 then
	l_sob_id := l_reporting_entity_id;
        mo_global.init('AR');
	mo_global.set_policy_context('M',null);
   ELSIF l_reporting_level = 3000 then
     select set_of_books_id
	into l_sob_id
	from ar_system_parameters_all
     where org_id = l_reporting_entity_id;
     mo_global.init('AR');
     mo_global.set_policy_context('S',l_reporting_entity_id);
   END IF;



   l_sob_type := 'P';


  /* Run the report by calling the inner procedure */
  arrx_rc_unapp.ar_unapp_reg(
         l_request_id,
         l_reporting_level,
         l_reporting_entity_id,
         l_sob_id,
         l_coa_id,
         l_co_seg_low,
         l_co_seg_high,
         l_gl_date_from,
         l_gl_date_to,
         l_entered_currency,
         l_batch_name_low,
         l_batch_name_high,
         l_batch_src_low,
         l_batch_src_high,
         l_customer_name_low,
         l_customer_name_high,
         l_customer_number_low,
         l_customer_number_high,
         l_receipt_number_low,
         l_receipt_number_high,
         retcode,
         errbuf);

  fa_rx_util_pkg.debug('Completed AR_UNAPP_REC_REGISTER successfully');

  commit;

EXCEPTION
    WHEN OTHERS THEN
       fa_rx_util_pkg.debug('AR_UNAPP_REC_REGISTER EXCEPTION');
       fa_rx_util_pkg.debug(sqlcode);
       fa_rx_util_pkg.debug(sqlerrm);
       retcode := 2;
END AR_UNAPP_REC_REGISTER;

END ARRX_C_UNAPP;

/
