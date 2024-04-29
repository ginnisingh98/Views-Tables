--------------------------------------------------------
--  DDL for Package Body FUN_XML_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_XML_REPORT_PKG" AS
/* $Header: FUNXRPTB.pls 120.4.12010000.13 2010/03/29 13:50:46 abhaktha ship $ */

   G_PKG_NAME          CONSTANT VARCHAR2(30) := 'FUN_XML_REPORT_PKG';
   G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
   G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
   G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
   G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
   G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
   G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
   G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

   G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
   G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
   G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
   G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
   G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
   G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
   G_MODULE_NAME           CONSTANT VARCHAR2(80) := 'FUN_XML_REPORT_PKG';



PROCEDURE clob_to_file
        (p_xml_clob           IN CLOB) IS

l_clob_size                NUMBER;
l_offset                   NUMBER;
l_chunk_size               INTEGER;
l_chunk                    VARCHAR2(32767);
l_log_module               VARCHAR2(240);

BEGIN


   l_clob_size := dbms_lob.getlength(p_xml_clob);

   IF (l_clob_size = 0) THEN
      RETURN;
   END IF;

   l_offset     := 1;
   l_chunk_size := 3000;

   WHILE (l_clob_size > 0) LOOP
      l_chunk := dbms_lob.substr (p_xml_clob, l_chunk_size, l_offset);
      fnd_file.put
         (which     => fnd_file.output
         ,buff      => l_chunk);

      l_clob_size := l_clob_size - l_chunk_size;
      l_offset := l_offset + l_chunk_size;
   END LOOP;

   fnd_file.new_line(fnd_file.output,1);

EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;

END clob_to_file;


PROCEDURE put_starttag(tag_name         IN VARCHAR2) IS
BEGIN

  fnd_file.put_line(fnd_file.output, '<'||tag_name||'>');
  --fnd_file.new_line(fnd_file.output,1);

EXCEPTION

    WHEN OTHERS then
      APP_EXCEPTION.RAISE_EXCEPTION;

END;

PROCEDURE put_endtag(tag_name   IN VARCHAR2) IS
BEGIN

  fnd_file.put_line(fnd_file.output, '</'||tag_name||'>');
  --fnd_file.new_line(fnd_file.output,1);

EXCEPTION

    WHEN OTHERS then
      APP_EXCEPTION.RAISE_EXCEPTION;

END;

PROCEDURE put_element(tag_name  IN VARCHAR2,
                      value     IN VARCHAR2) IS
BEGIN

  fnd_file.put(fnd_file.output, '<'||tag_name||'>');
  fnd_file.put(fnd_file.output, '<![CDATA[');
  fnd_file.put(fnd_file.output, value);
  fnd_file.put(fnd_file.output, ']]>');
  fnd_file.put_line(fnd_file.output, '</'||tag_name||'>');

EXCEPTION

    WHEN OTHERS then
      APP_EXCEPTION.RAISE_EXCEPTION;

END;



PROCEDURE proposed_netting_report(
                        errbuf             OUT NOCOPY VARCHAR2,
                        retcode            OUT NOCOPY NUMBER,
                        p_batch_id         IN         VARCHAR2 ) IS

l_qryCtx                   DBMS_XMLGEN.ctxHandle;
l_result_clob              CLOB;
l_current_calling_sequence varchar2(2000);
l_debug_info               varchar2(200);

l_report_name   varchar2(80) := 'Proposed Netting Report';

l_batch_count	number;
l_invoice_count	number;
l_trx_count	number;
l_temp_invoice_count	number;
l_temp_trx_count	number;
l_encoding   VARCHAR2(20);
l_allow_disc_flag VARCHAR2(3); -- Bug: 8342465
l_net_currency_rule_code varchar(100);

BEGIN

  l_current_calling_sequence := 'FUN_XML_REPORT_PKG.proposed_netting_report';
  l_debug_info := 'Select Batch Info...';

  l_batch_count	:= 0;
  l_invoice_count := 0;
  l_trx_count := 0;

   -- Bug: 8342465
  SELECT FNA.ALLOW_DISC_FLAG, fna.net_currency_rule_code
  INTO l_allow_disc_flag, l_net_currency_rule_code
  FROM FUN_NET_BATCHES_ALL FNB,
  FUN_NET_AGREEMENTS_ALL FNA
  WHERE FNA.AGREEMENT_ID = FNB.AGREEMENT_ID
  AND FNB.BATCH_ID = p_batch_id;

  select tag INTO l_encoding from fnd_lookup_values
  where lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
  and lookup_code = ( select value from v$nls_parameters where parameter='NLS_CHARACTERSET')
  and language='US' ;

  put_starttag('?xml version="1.0" encoding="'||l_encoding||'"?');
  put_starttag('NETTING_REPORT');

  l_qryCtx := DBMS_XMLGEN.newContext(
  'SELECT  HOU.NAME AS OPERATING_UNIT,
           FNA.AGREEMENT_NAME,
           FNA.AGREEMENT_START_DATE,
           FNA.AGREEMENT_END_DATE,
           FNA.PARTNER_REFERENCE,
           CBA.BANK_ACCOUNT_NAME,
           DECODE(FNA.SEL_REC_PAST_DUE_TXNS_FLAG, ''Y'', ''Yes'', ''N'', ''No'') AS SELECT_REC_PAST_DUE_TXNS,
           FNA.DAYS_PAST_DUE,
           FLC1.MEANING AS NETTING_ORDER_RULE,
           FLC2.MEANING AS NETTING_BALANCE_RULE,
           FLC3.MEANING AS NETTING_CURRENCY_RULE,
           FNA.NET_CURRENCY_CODE,
           GLC.USER_CONVERSION_TYPE AS EXCHANGE_RATE_TYPE,
           FNB.EXCHANGE_RATE AS EXCHANGE_RATE,
           FNB.BATCH_NUMBER,
           FNB.BATCH_NAME,
           FNB.BATCH_CURRENCY,
           FNB.SETTLEMENT_DATE,
           FNB.TRANSACTION_DUE_DATE,
           FNB.RESPONSE_DATE,
           FNB.TOTAL_NETTED_AMT AS TOTAL_NETTED_AMT
   FROM    FUN_NET_BATCHES_ALL FNB,
           FUN_NET_AGREEMENTS_ALL FNA,
           HR_OPERATING_UNITS HOU,
           CE_BANK_ACCOUNTS CBA,
           FUN_LOOKUPS FLC1,
           FUN_LOOKUPS FLC2,
           FUN_LOOKUPS FLC3,
           gl_daily_conversion_types glc
   WHERE   FNA.AGREEMENT_ID = FNB.AGREEMENT_ID
   AND    GLC.CONVERSION_TYPE = FNB.EXCHANGE_RATE_TYPE
   AND    HOU.ORGANIZATION_ID = FNB.ORG_ID
   AND    CBA.BANK_ACCOUNT_ID = FNA.BANK_ACCOUNT_ID
   AND    FLC1.LOOKUP_TYPE = ''FUN_NET_ORDER_RULE''
   AND    FLC1.LOOKUP_CODE = FNA.NET_ORDER_RULE_CODE
   AND    FLC2.LOOKUP_TYPE = ''FUN_NET_BALANCE_RULE''
   AND    FLC2.LOOKUP_CODE = FNA.NET_BALANCE_RULE_CODE
   AND    FLC3.LOOKUP_TYPE = ''FUN_NET_CURRENCY_RULE''
   AND    FLC3.LOOKUP_CODE = FNA.NET_CURRENCY_RULE_CODE
   AND    FNB.BATCH_ID = :BATCH_ID');


  DBMS_XMLGEN.setRowSetTag(l_qryCtx,'BATCH_DETAILS_SET');
  DBMS_XMLGEN.setRowTag(l_qryCtx, 'BATCH_DETAILS');
  DBMS_XMLGEN.setBindValue(l_qryCtx,'BATCH_ID', p_batch_id);
  l_result_clob :=DBMS_XMLGEN.GETXML(l_qryCtx);
  l_result_clob := substr(l_result_clob,instr(l_result_clob,'>')+1);

  l_batch_count := DBMS_XMLGEN.getNumRowsProcessed(l_qryCtx);
  DBMS_XMLGEN.closeContext(l_qryCtx);
  clob_to_file(l_result_clob);


  l_debug_info := 'Select AP invoices...';

  put_starttag('SUPPLIER_SET');

  for rec in (
    SELECT  distinct
            PV.VENDOR_ID AS SUPPLIER_ID,
            PVS.VENDOR_SITE_ID AS SITE_ID,
            PV.VENDOR_NAME AS SUPPLIER_NAME,
            PV.SEGMENT1 AS SUPPLIER_NUM,
            PVS.VENDOR_SITE_CODE AS SITE,
            PV.NUM_1099 AS SUPPLIER_TAXPAYER_ID,
            PV.VAT_REGISTRATION_NUM AS SUPPLIER_TAX_REGN_NUM
    FROM  FUN_NET_AP_INVS_ALL FNAP,
          FUN_NET_BATCHES_ALL FNB,
          AP_INVOICES_ALL API,
          AP_LOOKUP_CODES ALC,
          PO_VENDORS PV,
          PO_VENDOR_SITES_ALL PVS
    WHERE  FNAP.BATCH_ID = p_batch_id
    AND    FNAP.BATCH_ID = FNB.BATCH_ID
    AND    FNAP.INVOICE_ID = API.INVOICE_ID
    AND    ALC.LOOKUP_CODE = API.INVOICE_TYPE_LOOKUP_CODE
    AND    ALC.LOOKUP_TYPE = 'INVOICE TYPE'
    AND    PV.VENDOR_ID = API.VENDOR_ID
    AND    PVS.VENDOR_SITE_ID = API.VENDOR_SITE_ID
    ORDER BY PV.VENDOR_NAME,
             PVS.VENDOR_SITE_CODE
                                        ) loop

    put_starttag('SUPPLIER_RECORD');
    put_element('INV_ALLOW_DISC_FLAG',l_allow_disc_flag);
    put_element('SUPPLIER_ID',rec.SUPPLIER_ID);
    put_element('SITE_ID',rec.SITE_ID);
    put_element('SUPPLIER_NAME',rec.SUPPLIER_NAME);
    put_element('SUPPLIER_NUM',rec.SUPPLIER_NUM);
    put_element('SITE',rec.SITE);
    put_element('SUPPLIER_TAXPAYER_ID',rec.SUPPLIER_TAXPAYER_ID);
    put_element('SUPPLIER_TAX_REGN_NUM',rec.SUPPLIER_TAX_REGN_NUM);


    l_qryCtx := DBMS_XMLGEN.newContext(
    'SELECT
            API.INVOICE_NUM,
            ALC.DISPLAYED_FIELD AS INVOICE_TYPE,
            API.INVOICE_DATE AS INVOICE_DATE,
            LTRIM(TO_CHAR(API.INVOICE_AMOUNT,''999999999999999999999.999999999999'')) AS INVOICE_AMOUNT,
            LTRIM(TO_CHAR(FNAP.INV_CURR_OPEN_AMT,''999999999999999999999.999999999999''))  AS INVOICE_CURRENCY_OPEN_AMOUNT,
            LTRIM(TO_CHAR(decode(FNAP.APPLIED_DISC,0,null,decode('''||l_net_currency_rule_code||''', ''ACCOUNTING_CURRENCY'',
	    FUN_NET_ARAP_PKG.Derive_Conv_Amt(FNB.batch_id, API.invoice_id, FNAP.APPLIED_DISC, ''AP''), FNAP.APPLIED_DISC)),''999999999999999999999.999999999999''))  AS INV_APPLIED_DISC_AMOUNT,
            LTRIM(TO_CHAR(decode(FNAP.NETTED_AMT, 0,null, decode('''||l_net_currency_rule_code||''', ''ACCOUNTING_CURRENCY'',
	    FUN_NET_ARAP_PKG.Derive_Conv_Amt(FNB.batch_id, API.invoice_id, FNAP.NETTED_AMT, ''AP''), FNAP.NETTED_AMT)),''999999999999999999999.999999999999''))  AS NETTED_AMT_INV_CURR,
            API.INVOICE_CURRENCY_CODE AS INVOICE_CURRENCY,
            LTRIM(TO_CHAR(FNAP.OPEN_AMT,''999999999999999999999.999999999999''))  AS INV_RECKONING_OPEN_AMOUNT,
            FNB.BATCH_CURRENCY AS RECKONING_CURRENCY,
            MIN(APS.DUE_DATE) AS DUE_DATE,
            LTRIM(TO_CHAR(SUM(nvl(vat.vat_amount,0)),''999999999999999999999.999999999999''))  AS VAT_AMOUNT
     FROM  FUN_NET_AP_INVS_ALL FNAP,
           FUN_NET_BATCHES_ALL FNB,
           AP_INVOICES_ALL API,
           ap_invoice_lines_all ail,
           AP_LOOKUP_CODES ALC,
           AP_PAYMENT_SCHEDULES_ALL APS,
           PO_VENDORS PV,
           PO_VENDOR_SITES_ALL PVS,
           (select ail2.invoice_id
                  ,sum(ail2.amount) vat_amount
            from ap_invoices_all ai2
                ,ap_invoice_lines_all ail2
                ,ap_tax_codes_all atc
            where ai2.vendor_id = :SUPPLIER_ID
              and ai2.vendor_site_id = :SITE_ID
              and ail2.invoice_id = ai2.invoice_id
              and ail2.line_type_lookup_code = ''TAX''
              and atc.name = ail2.tax_classification_code
              and atc.tax_type = ''SALES''
              and atc.org_id = ail2.org_id
            group by ail2.invoice_id
           ) vat
     WHERE  FNAP.INVOICE_ID = API.INVOICE_ID
     AND    FNAP.BATCH_ID = FNB.BATCH_ID
     AND    ALC.LOOKUP_CODE = API.INVOICE_TYPE_LOOKUP_CODE
     AND    ALC.LOOKUP_TYPE = ''INVOICE TYPE''
     AND    APS.INVOICE_ID = API.INVOICE_ID
     AND    PV.VENDOR_ID = API.VENDOR_ID
     AND    PVS.VENDOR_SITE_ID = API.VENDOR_SITE_ID
     AND    FNAP.BATCH_ID = :BATCH_ID
     AND    PV.VENDOR_ID = :SUPPLIER_ID
     AND    PVS.VENDOR_SITE_ID = :SITE_ID
     and    vat.invoice_id(+) = API.INVOICE_ID
     GROUP BY
            API.INVOICE_NUM,
            ALC.DISPLAYED_FIELD,
            API.INVOICE_DATE,
            API.INVOICE_AMOUNT,
            FNAP.INV_CURR_OPEN_AMT,
	    API.INVOICE_CURRENCY_CODE,
            FNAP.OPEN_AMT,
            FNB.BATCH_CURRENCY,
	    FNB.batch_id, API.invoice_id, FNAP.APPLIED_DISC,FNAP.NETTED_AMT
    ORDER BY
                 API.INVOICE_NUM');


    DBMS_XMLGEN.setRowSetTag(l_qryCtx,'INVOICE_SET');
    DBMS_XMLGEN.setRowTag(l_qryCtx, 'INVOICE_RECORD');
    DBMS_XMLGEN.setBindValue(l_qryCtx,'BATCH_ID', p_batch_id);
    DBMS_XMLGEN.setBindValue(l_qryCtx,'SUPPLIER_ID', rec.supplier_id);
    DBMS_XMLGEN.setBindValue(l_qryCtx,'SITE_ID', rec.site_id);
    l_result_clob :=DBMS_XMLGEN.GETXML(l_qryCtx);
    l_result_clob := substr(l_result_clob,instr(l_result_clob,'>')+1);
    l_temp_invoice_count := DBMS_XMLGEN.getNumRowsProcessed(l_qryCtx);
    l_invoice_count := l_invoice_count + l_temp_invoice_count;
    DBMS_XMLGEN.closeContext(l_qryCtx);
    clob_to_file(l_result_clob);

    put_endtag('SUPPLIER_RECORD');

  end loop;

  put_endtag('SUPPLIER_SET');



  l_debug_info := 'Select AR transactions...';

  put_starttag('CUSTOMER_SET');

  for rec in (
    SELECT  distinct
            HP.PARTY_NAME AS CUSTOMER,
            HCA.CUST_ACCOUNT_ID AS CUST_ACCOUNT_ID,
            HCA.ACCOUNT_NUMBER AS CUSTOMER_NUMBER,
            HCSU.LOCATION,
            HCSU.SITE_USE_ID AS SITE_USE_ID,
            HP.JGZZ_FISCAL_CODE AS CUST_TAXPAYER_ID,
            HP.TAX_REFERENCE AS CUST_TAX_REGN_NUM
    FROM  FUN_NET_AR_TXNS_ALL FNAR,
          FUN_NET_BATCHES_ALL FNB,
          RA_CUSTOMER_TRX_ALL RCT,
          RA_CUST_TRX_TYPES_ALL RCTT,
          HZ_CUST_ACCOUNTS_ALL HCA,
          HZ_PARTIES HP,
          HZ_CUST_SITE_USES_ALL HCSU
    WHERE  FNAR.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
    AND    FNAR.BATCH_ID = FNB.BATCH_ID
    AND    RCTT.CUST_TRX_TYPE_ID = RCT.CUST_TRX_TYPE_ID
    AND    RCT.ORG_ID = RCTT.ORG_ID
    AND    HCA.CUST_ACCOUNT_ID = RCT.BILL_TO_CUSTOMER_ID
    AND    HP.PARTY_ID = HCA.PARTY_ID
    AND    HCSU.SITE_USE_ID = RCT.BILL_TO_SITE_USE_ID
    AND    FNAR.BATCH_ID = p_batch_id
    ORDER BY HP.PARTY_NAME,
             HCSU.LOCATION
                                        ) loop

    put_starttag('CUSTOMER_RECORD');
    put_element('TRX_ALLOW_DISC_FLAG',l_allow_disc_flag);
    put_element('CUST_ACCOUNT_ID',rec.CUST_ACCOUNT_ID);
    put_element('SITE_USE_ID',rec.SITE_USE_ID);
    put_element('CUSTOMER',rec.CUSTOMER);
    put_element('CUSTOMER_NUMBER',rec.CUSTOMER_NUMBER);
    put_element('LOCATION',rec.LOCATION);
    put_element('CUST_TAXPAYER_ID',rec.CUST_TAXPAYER_ID);
    put_element('CUST_TAX_REGN_NUM',rec.CUST_TAX_REGN_NUM);

    l_qryCtx := DBMS_XMLGEN.newContext(
     'SELECT
              RCT.TRX_NUMBER,
              RCTT.NAME AS TRX_TYPE,
              RCT.TRX_DATE,
              LTRIM(TO_CHAR(FNAR.TXN_CURR_OPEN_AMT,''999999999999999999999.999999999999''))  AS TRX_AMOUNT,
              APS.INVOICE_CURRENCY_CODE AS TRX_CURRENCY,
              LTRIM(TO_CHAR(FNAR.TXN_CURR_OPEN_AMT,''999999999999999999999.999999999999''))  AS TXN_CURR_OPEN_AMOUNT,
	      LTRIM(TO_CHAR(decode(FNAR.APPLIED_DISC,0,null,decode('''||l_net_currency_rule_code||''', ''ACCOUNTING_CURRENCY'',
	      FUN_NET_ARAP_PKG.Derive_Conv_Amt(FNB.batch_id, RCT.CUSTOMER_TRX_ID, FNAR.APPLIED_DISC, ''AR''), FNAR.APPLIED_DISC)),''999999999999999999999.999999999999''))  AS TRX_APPLIED_DISC_AMOUNT,
	      LTRIM(TO_CHAR(decode(FNAR.NETTED_AMT,0,null,decode('''||l_net_currency_rule_code||''', ''ACCOUNTING_CURRENCY'',
	      FUN_NET_ARAP_PKG.Derive_Conv_Amt(FNB.batch_id, RCT.CUSTOMER_TRX_ID, FNAR.NETTED_AMT, ''AR''), FNAR.NETTED_AMT)),''999999999999999999999.999999999999''))  AS NETTED_AMT_TRX_CURR,
              FNB.BATCH_CURRENCY AS RECKONING_CURRENCY,
              LTRIM(TO_CHAR(FNAR.OPEN_AMT,''999999999999999999999.999999999999''))  AS TRX_RECKONING_OPEN_AMOUNT,
              MIN(APS.DUE_DATE) AS DUE_DATE,
              LTRIM(TO_CHAR(sum(nvl(vat_amount,0)),''999999999999999999999.999999999999''))  AS VAT_AMOUNT -- Russian Requirement
      FROM  FUN_NET_AR_TXNS_ALL FNAR,
            FUN_NET_BATCHES_ALL FNB,
            RA_CUSTOMER_TRX_ALL RCT,
            RA_CUST_TRX_TYPES_ALL RCTT,
            AR_PAYMENT_SCHEDULES_ALL APS,
            HZ_CUST_ACCOUNTS_ALL HCA,
            HZ_PARTIES HP,
            HZ_CUST_SITE_USES_ALL HCSU,
            -- Russian Requirement
            (select
                    rctl2.customer_trx_id
                   ,sum(rctl2.extended_amount) AS VAT_AMOUNT
             from
                  ra_customer_trx_all rct2
                 ,ra_customer_trx_lines_all rctl2
                 ,ar_vat_tax_all_b avt
             where
                   rct2.bill_to_customer_id=:CUST_ACCOUNT_ID
               and rct2.bill_to_site_use_id=:SITE_USE_ID
               and rctl2.customer_trx_id=rct2.customer_trx_id
               and rctl2.line_type = ''TAX''
               and avt.vat_tax_id = rctl2.vat_tax_id
               and avt.tax_type = ''VAT''
             group by rctl2.customer_trx_id
            ) rctl3
      WHERE  FNAR.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
      AND    FNAR.BATCH_ID = FNB.BATCH_ID
      AND    RCTT.CUST_TRX_TYPE_ID = RCT.CUST_TRX_TYPE_ID
      AND    RCT.ORG_ID = RCTT.ORG_ID
      AND    APS.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
      AND    HCA.CUST_ACCOUNT_ID = RCT.BILL_TO_CUSTOMER_ID
      AND    HP.PARTY_ID = HCA.PARTY_ID
      AND    HCSU.SITE_USE_ID = RCT.BILL_TO_SITE_USE_ID
      AND    FNAR.BATCH_ID = :BATCH_ID
      -- Detail mode
      AND    RCT.BILL_TO_CUSTOMER_ID = :CUST_ACCOUNT_ID
      AND    RCT.BILL_TO_SITE_USE_ID = :SITE_USE_ID
      -- Russian Requirement
      and    rctl3.customer_trx_id(+) = rct.customer_trx_id
      GROUP BY
               RCT.TRX_NUMBER,
               RCTT.NAME,
               RCT.TRX_DATE,
               APS.INVOICE_CURRENCY_CODE,
               FNAR.TXN_CURR_OPEN_AMT,
	       FNB.BATCH_CURRENCY,
               FNAR.OPEN_AMT,FNB.batch_id, RCT.CUSTOMER_TRX_ID, FNAR.APPLIED_DISC,FNAR.NETTED_AMT
      ORDER BY
               RCT.TRX_NUMBER');

    DBMS_XMLGEN.setRowSetTag(l_qryCtx,'TRANSACTION_SET');
    DBMS_XMLGEN.setRowTag(l_qryCtx, 'TRANSACTION_RECORD');
    DBMS_XMLGEN.setBindValue(l_qryCtx,'BATCH_ID', p_batch_id);
    DBMS_XMLGEN.setBindValue(l_qryCtx,'CUST_ACCOUNT_ID', rec.CUST_ACCOUNT_ID);
    DBMS_XMLGEN.setBindValue(l_qryCtx,'SITE_USE_ID', rec.SITE_USE_ID);
    l_result_clob :=DBMS_XMLGEN.GETXML(l_qryCtx);
    l_result_clob := substr(l_result_clob,instr(l_result_clob,'>')+1);
    l_temp_trx_count := DBMS_XMLGEN.getNumRowsProcessed(l_qryCtx);
    l_trx_count := l_trx_count + l_temp_trx_count;
    DBMS_XMLGEN.closeContext(l_qryCtx);
    clob_to_file(l_result_clob);

    put_endtag('CUSTOMER_RECORD');

  end loop;

  put_endtag('CUSTOMER_SET');


  put_starttag('SETUP');
  put_element('REPORT_NAME',l_report_name);
  put_element('BATCH_ID',p_batch_id);
  put_element('BATCH_COUNT',l_batch_count);
  put_element('INVOICE_COUNT',l_invoice_count);
  put_element('TRX_COUNT',l_trx_count);
  put_endtag('SETUP');


  put_endtag('NETTING_REPORT');


EXCEPTION

    WHEN OTHERS then
      FUN_UTIL.log_conc_unexp(l_current_calling_sequence, SQLERRM);
      APP_EXCEPTION.RAISE_EXCEPTION;

END proposed_netting_report;



PROCEDURE final_netting_report(
                        errbuf             OUT NOCOPY VARCHAR2,
                        retcode            OUT NOCOPY NUMBER,
                        p_batch_id         IN         VARCHAR2 ) IS

l_qryCtx                   DBMS_XMLGEN.ctxHandle;
l_result_clob              CLOB;
l_current_calling_sequence varchar2(2000);
l_debug_info               varchar2(200);

l_report_name   varchar2(80) := 'Final Netting Report';

l_batch_count	number;
l_invoice_count	number;
l_trx_count	number;
l_temp_invoice_count	number;
l_temp_trx_count	number;
l_encoding   VARCHAR2(20);
l_allow_disc_flag VARCHAR2(3); -- Bug: 8342465
l_net_currency_rule_code varchar2(100);

BEGIN

  l_current_calling_sequence := 'FUN_XML_REPORT_PKG.final_netting_report';
  l_debug_info := 'Select Batch Info...';

  l_batch_count	:= 0;
  l_invoice_count := 0;
  l_trx_count := 0;

  -- Bug: 8342465
  SELECT FNA.ALLOW_DISC_FLAG, fna.net_currency_rule_code
  INTO l_allow_disc_flag, l_net_currency_rule_code
  FROM FUN_NET_BATCHES_ALL FNB,
  FUN_NET_AGREEMENTS_ALL FNA
  WHERE FNA.AGREEMENT_ID = FNB.AGREEMENT_ID
  AND FNB.BATCH_ID = p_batch_id;

  select tag INTO l_encoding from fnd_lookup_values
  where lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
  and lookup_code = ( select value from v$nls_parameters where parameter='NLS_CHARACTERSET')
  and language='US' ;

  put_starttag('?xml version="1.0" encoding="'||l_encoding||'"?');
  put_starttag('NETTING_REPORT');

  l_qryCtx := DBMS_XMLGEN.newContext(
       'SELECT  HOU.NAME AS OPERATING_UNIT,
                FNA.AGREEMENT_NAME,
                FNA.AGREEMENT_START_DATE,
                FNA.AGREEMENT_END_DATE,
                FNA.PARTNER_REFERENCE,
                CBA.BANK_ACCOUNT_NAME,
                -- Dropped; DECODE(FNA.APPLY_EARNED_DISCOUNT
                DECODE(FNA.SEL_REC_PAST_DUE_TXNS_FLAG, ''Y'', ''Yes'', ''N'', ''No'') AS SELECT_REC_PAST_DUE_TXNS,
        	FNA.DAYS_PAST_DUE,
                FLC1.MEANING AS NETTING_ORDER_RULE,
                FLC2.MEANING AS NETTING_BALANCE_RULE,
                FLC3.MEANING AS NETTING_CURRENCY_RULE,
                FNA.NET_CURRENCY_CODE,
        	GLC.USER_CONVERSION_TYPE AS EXCHANGE_RATE_TYPE,
        	FNB.EXCHANGE_RATE AS EXCHANGE_RATE,
                FNB.BATCH_NUMBER,
                FNB.BATCH_NAME,
                FNB.BATCH_CURRENCY,
                FNB.SETTLEMENT_DATE,
                FNB.TRANSACTION_DUE_DATE,
                FNB.RESPONSE_DATE,
                FNB.TOTAL_NETTED_AMT AS TOTAL_NETTED_AMT
        FROM    FUN_NET_BATCHES_ALL FNB,
                FUN_NET_AGREEMENTS_ALL FNA,
                HR_OPERATING_UNITS HOU,
                CE_BANK_ACCOUNTS CBA,
        	FUN_LOOKUPS FLC1,
        	FUN_LOOKUPS FLC2,
        	FUN_LOOKUPS FLC3,
                gl_daily_conversion_types GLC
	WHERE   FNA.AGREEMENT_ID = FNB.AGREEMENT_ID
        AND     GLC.CONVERSION_TYPE = FNB.EXCHANGE_RATE_TYPE
        AND     HOU.ORGANIZATION_ID = FNB.ORG_ID
        AND     CBA.BANK_ACCOUNT_ID = FNA.BANK_ACCOUNT_ID
        AND     FLC1.LOOKUP_TYPE = ''FUN_NET_ORDER_RULE''
        AND     FLC1.LOOKUP_CODE = FNA.NET_ORDER_RULE_CODE
        AND     FLC2.LOOKUP_TYPE = ''FUN_NET_BALANCE_RULE''
        AND     FLC2.LOOKUP_CODE = FNA.NET_BALANCE_RULE_CODE
        AND     FLC3.LOOKUP_TYPE = ''FUN_NET_CURRENCY_RULE''
        AND     FLC3.LOOKUP_CODE = FNA.NET_CURRENCY_RULE_CODE
        AND	FNB.BATCH_ID = :BATCH_ID');


  DBMS_XMLGEN.setRowSetTag(l_qryCtx,'BATCH_DETAILS_SET');
  DBMS_XMLGEN.setRowTag(l_qryCtx, 'BATCH_DETAILS');
  DBMS_XMLGEN.setBindValue(l_qryCtx,'BATCH_ID', p_batch_id);
  l_result_clob :=DBMS_XMLGEN.GETXML(l_qryCtx);
  l_result_clob := substr(l_result_clob,instr(l_result_clob,'>')+1);

  l_batch_count := DBMS_XMLGEN.getNumRowsProcessed(l_qryCtx);
  DBMS_XMLGEN.closeContext(l_qryCtx);
  clob_to_file(l_result_clob);


  l_debug_info := 'Select AP invoices...';

  put_starttag('SUPPLIER_SET');

  for rec in (
        SELECT  distinct
                PV.VENDOR_ID AS SUPPLIER_ID,
                PVS.VENDOR_SITE_ID AS SITE_ID,
                PV.VENDOR_NAME AS SUPPLIER_NAME,
                PV.SEGMENT1 AS SUPPLIER_NUM,
                PVS.VENDOR_SITE_CODE AS SITE,
                PV.NUM_1099 AS SUPPLIER_TAXPAYER_ID,
                PV.VAT_REGISTRATION_NUM AS SUPPLIER_TAX_REGN_NUM,
                PVS.ADDRESS_LINE1 AS SUPPLIER_ADDRESS1,
		PVS.ADDRESS_LINE2 AS SUPPLIER_ADDRESS2,
		PVS.ADDRESS_LINE3 AS SUPPLIER_ADDRESS3,
		PVS.CITY AS SUPPLIER_CITY,
		PVS.STATE AS SUPPLIER_STATE,
		PVS.ZIP AS SUPPLIER_ZIP,
                PVC.FIRST_NAME||' '||PVC.LAST_NAME AS CONTACT_FIRST_LAST_NAME
        FROM    FUN_NET_AP_INVS_ALL FNAP,
                FUN_NET_BATCHES_ALL FNB,
                AP_INVOICES_ALL API,
                AP_LOOKUP_CODES ALC,
                PO_VENDORS PV,
                PO_VENDOR_SITES_ALL PVS,
		PO_VENDOR_CONTACTS PVC
        WHERE   FNAP.BATCH_ID = p_batch_id
        AND     FNAP.BATCH_ID = FNB.BATCH_ID
        AND     FNAP.INVOICE_ID = API.INVOICE_ID
        AND     ALC.LOOKUP_CODE = API.INVOICE_TYPE_LOOKUP_CODE
        AND     ALC.LOOKUP_TYPE = 'INVOICE TYPE'
        AND     PV.VENDOR_ID = API.VENDOR_ID
        AND     PVS.VENDOR_SITE_ID = API.VENDOR_SITE_ID
	AND     PVS.VENDOR_SITE_ID      = PVC.VENDOR_SITE_ID (+)
        AND     NVL(TRUNC(PVC.INACTIVE_DATE (+) ), SYSDATE + 1) > SYSDATE
        AND     NVL(PVC.VENDOR_CONTACT_ID , -9999) = (
                        SELECT  VENDOR_CONTACT_ID
                        FROM    PO_VENDOR_CONTACTS
                        WHERE   VENDOR_SITE_ID  = PVC.VENDOR_SITE_ID
                        AND     NVL(TRUNC(INACTIVE_DATE), SYSDATE  + 1)
                                        > SYSDATE
                        AND     ROWNUM                  = 1
                        UNION
                        SELECT  -9999
                        FROM    DUAL
                        WHERE   PVC.VENDOR_CONTACT_ID IS NULL)

        ORDER BY PV.VENDOR_NAME,
                 PVS.VENDOR_SITE_CODE

                                        ) loop

    put_starttag('SUPPLIER_RECORD');
    put_element('INV_ALLOW_DISC_FLAG',l_allow_disc_flag);
    put_element('SUPPLIER_ID',rec.SUPPLIER_ID);
    put_element('SITE_ID',rec.SITE_ID);
    put_element('SUPPLIER_NAME',rec.SUPPLIER_NAME);
    put_element('SUPPLIER_NUM',rec.SUPPLIER_NUM);
    put_element('SITE',rec.SITE);
    put_element('SUPPLIER_TAXPAYER_ID',rec.SUPPLIER_TAXPAYER_ID);
    put_element('SUPPLIER_TAX_REGN_NUM',rec.SUPPLIER_TAX_REGN_NUM);
    put_element('SUPPLIER_ADDRESS1',rec.SUPPLIER_ADDRESS1);
    put_element('SUPPLIER_ADDRESS2',rec.SUPPLIER_ADDRESS2);
    put_element('SUPPLIER_ADDRESS3',rec.SUPPLIER_ADDRESS3);
    put_element('SUPPLIER_CITY',rec.SUPPLIER_CITY);
    put_element('SUPPLIER_STATE',rec.SUPPLIER_STATE);
    put_element('SUPPLIER_ZIP',rec.SUPPLIER_ZIP);
    put_element('CONTACT_FIRST_LAST_NAME',rec.CONTACT_FIRST_LAST_NAME);


    l_qryCtx := DBMS_XMLGEN.newContext(
       'SELECT
                API.INVOICE_NUM,
                ALC.DISPLAYED_FIELD AS INVOICE_TYPE,
                API.INVOICE_DATE AS INVOICE_DATE,
                LTRIM(TO_CHAR(API.INVOICE_AMOUNT,''999999999999999999999.999999999999''))  AS INVOICE_AMOUNT,
		LTRIM(TO_CHAR(decode(FNAP.APPLIED_DISC, 0,null, decode('''||l_net_currency_rule_code||''', ''ACCOUNTING_CURRENCY'',
		FUN_NET_ARAP_PKG.Derive_Conv_Amt(FNB.batch_id, API.invoice_id, FNAP.APPLIED_DISC, ''AP''), FNAP.APPLIED_DISC)),''999999999999999999999.999999999999''))  AS INV_APPLIED_DISC_AMOUNT,
                LTRIM(TO_CHAR(decode(FNAP.INV_CURR_NET_AMT, 0, null, FNAP.INV_CURR_NET_AMT),''999999999999999999999.999999999999''))  AS NETTED_AMT_INV_CURR,
                API.INVOICE_CURRENCY_CODE AS INVOICE_CURRENCY,
                LTRIM(TO_CHAR(decode(FNAP.NETTED_AMT,0,null,FNAP.NETTED_AMT),''999999999999999999999.999999999999''))  AS NETTED_AMT_BATCH_CURR,
                FNB.BATCH_CURRENCY AS RECKONING_CURRENCY,
                AC.CHECK_NUMBER AS PAYMENT_NUMBER,
                LTRIM(TO_CHAR(SUM(nvl(vat.vat_amount,0)),''999999999999999999999.999999999999''))  AS VAT_AMOUNT
        FROM    FUN_NET_AP_INVS_ALL FNAP,
                FUN_NET_BATCHES_ALL FNB,
                AP_INVOICES_ALL API,
                AP_LOOKUP_CODES ALC,
                PO_VENDORS PV,
                PO_VENDOR_SITES_ALL PVS,
                AP_CHECKS_ALL AC,
           (select ail2.invoice_id
                  ,sum(ail2.amount) vat_amount
            from ap_invoices_all ai2
                ,ap_invoice_lines_all ail2
                ,ap_tax_codes_all atc
            where ai2.vendor_id = :SUPPLIER_ID
              and ai2.vendor_site_id = :SITE_ID
              and ail2.invoice_id = ai2.invoice_id
              and ail2.line_type_lookup_code = ''TAX''
              and atc.name = ail2.tax_classification_code
              and atc.tax_type = ''SALES''
              and atc.org_id = ail2.org_id
            group by ail2.invoice_id
           ) vat
        WHERE   FNAP.INVOICE_ID = API.INVOICE_ID
        AND     FNAP.BATCH_ID = FNB.BATCH_ID
        AND     ALC.LOOKUP_CODE = API.INVOICE_TYPE_LOOKUP_CODE
        AND     ALC.LOOKUP_TYPE = ''INVOICE TYPE''
        AND     PV.VENDOR_ID = API.VENDOR_ID
        AND     PVS.VENDOR_SITE_ID = API.VENDOR_SITE_ID
        AND     AC.CHECK_ID = FNAP.CHECK_ID(+)
        AND     FNAP.BATCH_ID = :BATCH_ID
        AND     PV.VENDOR_ID = :SUPPLIER_ID
        AND     PVS.VENDOR_SITE_ID = :SITE_ID
        and    vat.invoice_id(+) = API.INVOICE_ID
        GROUP BY
            API.INVOICE_NUM,
            ALC.DISPLAYED_FIELD,
            API.INVOICE_DATE,
            API.INVOICE_AMOUNT,
	    FNAP.INV_CURR_NET_AMT,
            API.INVOICE_CURRENCY_CODE,
            FNAP.NETTED_AMT,
            FNB.BATCH_CURRENCY,
            AC.CHECK_NUMBER,FNB.batch_id, API.invoice_id, FNAP.APPLIED_DISC
        ORDER BY
                 API.INVOICE_NUM');


    DBMS_XMLGEN.setRowSetTag(l_qryCtx,'INVOICE_SET');
    DBMS_XMLGEN.setRowTag(l_qryCtx, 'INVOICE_RECORD');
    DBMS_XMLGEN.setBindValue(l_qryCtx,'BATCH_ID', p_batch_id);
    DBMS_XMLGEN.setBindValue(l_qryCtx,'SUPPLIER_ID', rec.SUPPLIER_ID);
    DBMS_XMLGEN.setBindValue(l_qryCtx,'SITE_ID', rec.SITE_ID);
    l_result_clob :=DBMS_XMLGEN.GETXML(l_qryCtx);
    l_result_clob := substr(l_result_clob,instr(l_result_clob,'>')+1);
    l_temp_invoice_count := DBMS_XMLGEN.getNumRowsProcessed(l_qryCtx);
    l_invoice_count := l_invoice_count + l_temp_invoice_count;
    DBMS_XMLGEN.closeContext(l_qryCtx);
    clob_to_file(l_result_clob);

    put_endtag('SUPPLIER_RECORD');

  end loop;

  put_endtag('SUPPLIER_SET');


  l_debug_info := 'Select AR transactions...';

  put_starttag('CUSTOMER_SET');

  for rec in (
        SELECT DISTINCT HP.PARTY_NAME AS CUSTOMER,
  HCA.CUST_ACCOUNT_ID AS CUST_ACCOUNT_ID,
  HCA.ACCOUNT_NUMBER CUSTOMER_NUMBER,
  HCSU.LOCATION,
  HCSU.SITE_USE_ID AS SITE_USE_ID,
  HP.JGZZ_FISCAL_CODE AS CUST_TAXPAYER_ID,
  HP.TAX_REFERENCE AS CUST_TAX_REGN_NUM,
  HZL.ADDRESS1 AS CUSTOMER_ADDRESS1,
  HZL.ADDRESS2 AS CUSTOMER_ADDRESS2,
  HZL.ADDRESS3 AS CUSTOMER_ADDRESS3,
  HZL.CITY AS CUSTOMER_CITY,
  HZL.STATE AS CUSTOMER_STATE,
  HZL.POSTAL_CODE AS CUSTOMER_POSTAL_CODE
FROM FUN_NET_AR_TXNS_ALL FNAR,
  FUN_NET_BATCHES_ALL FNB,
  RA_CUSTOMER_TRX_ALL RCT,
  RA_CUSTOMER_TRX_LINES_ALL RCTL,
  RA_CUST_TRX_TYPES_ALL RCTT,
  HZ_CUST_ACCOUNTS_ALL HCA,
  HZ_PARTIES HP,
  HZ_CUST_SITE_USES_ALL HCSU,
  AR_CASH_RECEIPTS_ALL ACR,
  HZ_CUST_ACCT_SITES_ALL HCAS,
  HZ_PARTY_SITES HPS,
  HZ_LOCATIONS HZL
WHERE FNAR.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
 AND RCT.CUSTOMER_TRX_ID = RCTL.CUSTOMER_TRX_ID
 AND RCTT.CUST_TRX_TYPE_ID = RCT.CUST_TRX_TYPE_ID
 AND RCT.ORG_ID = RCTT.ORG_ID
 AND HCA.CUST_ACCOUNT_ID = RCT.BILL_TO_CUSTOMER_ID
 AND HP.PARTY_ID = HCA.PARTY_ID
 AND HCSU.SITE_USE_ID = RCT.BILL_TO_SITE_USE_ID
 AND ACR.CASH_RECEIPT_ID = FNAR.CASH_RECEIPT_ID
 AND FNB.BATCH_ID = FNAR.BATCH_ID
 AND FNAR.BATCH_ID = p_batch_id
 AND HCSU.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID
 AND HPS.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
 AND HZL.LOCATION_ID = HPS.LOCATION_ID
 ORDER BY HP.PARTY_NAME,
  HCSU.LOCATION               ) loop


    put_starttag('CUSTOMER_RECORD');
    put_element('TRX_ALLOW_DISC_FLAG',l_allow_disc_flag);
    put_element('CUST_ACCOUNT_ID',rec.CUST_ACCOUNT_ID);
    put_element('SITE_USE_ID',rec.SITE_USE_ID);
    put_element('CUSTOMER',rec.CUSTOMER);
    put_element('CUSTOMER_NUMBER',rec.CUSTOMER_NUMBER);
    put_element('LOCATION',rec.LOCATION);
    put_element('CUST_TAXPAYER_ID',rec.CUST_TAXPAYER_ID);
    put_element('CUST_TAX_REGN_NUM',rec.CUST_TAX_REGN_NUM);
    put_element('CUSTOMER_ADDRESS1',rec.CUSTOMER_ADDRESS1);
    put_element('CUSTOMER_ADDRESS2',rec.CUSTOMER_ADDRESS2);
    put_element('CUSTOMER_ADDRESS3',rec.CUSTOMER_ADDRESS3);
    put_element('CUSTOMER_CITY',rec.CUSTOMER_CITY);
    put_element('CUSTOMER_STATE',rec.CUSTOMER_STATE);
    put_element('CUSTOMER_POSTAL_CODE',rec.CUSTOMER_POSTAL_CODE);
    --put_element('CONTACT_CUSTOMER_NAME',rec.CONTACT_CUSTOMER_NAME);  /8787753

    l_qryCtx := DBMS_XMLGEN.newContext(
       'SELECT
                RCT.TRX_NUMBER,
                RCTT.NAME AS TRX_TYPE,
                RCT.TRX_DATE,
                SUM(RCTL.EXTENDED_AMOUNT)  AS TRX_AMOUNT,
		LTRIM(TO_CHAR(decode(FNAR.APPLIED_DISC,0,null, decode('''||l_net_currency_rule_code||''', ''ACCOUNTING_CURRENCY'',
		FUN_NET_ARAP_PKG.Derive_Conv_Amt(FNB.batch_id, RCT.CUSTOMER_TRX_ID, FNAR.APPLIED_DISC, ''AR''), FNAR.APPLIED_DISC)),''999999999999999999999.999999999999''))  AS TRX_APPLIED_DISC_AMOUNT,
                decode(FNAR.TXN_CURR_NET_AMT,0,null,FNAR.TXN_CURR_NET_AMT) AS NETTED_AMT_TRX_CURR,
                RCT.INVOICE_CURRENCY_CODE AS TRX_CURRENCY,
                LTRIM(TO_CHAR(decode(FNAR.NETTED_AMT, 0, null, FNAR.NETTED_AMT),''999999999999999999999.999999999999''))  AS NETTED_AMT_RECKONING_CURR,
                FNB.BATCH_CURRENCY AS RECKONING_CURRENCY,
                ACR.RECEIPT_NUMBER,
                LTRIM(TO_CHAR(sum(nvl(vat_amount,0)),''999999999999999999999.999999999999'')) AS VAT_AMOUNT -- Russian Requirement
        FROM    FUN_NET_AR_TXNS_ALL FNAR,
                RA_CUSTOMER_TRX_ALL RCT,
                RA_CUSTOMER_TRX_LINES_ALL RCTL,
                RA_CUST_TRX_TYPES_ALL RCTT,
                HZ_CUST_ACCOUNTS_ALL HCA,
                HZ_PARTIES HP,
                HZ_CUST_SITE_USES_ALL HCSU,
                AR_CASH_RECEIPTS_ALL ACR,
                FUN_NET_BATCHES_ALL FNB,
                -- Russian Requirement
            (select
                    rctl2.customer_trx_id
                   ,sum(rctl2.extended_amount) AS VAT_AMOUNT
             from
                  ra_customer_trx_all rct2
                 ,ra_customer_trx_lines_all rctl2
                 ,ar_vat_tax_all_b avt
             where
                   rct2.bill_to_customer_id=:CUST_ACCOUNT_ID
               and rct2.bill_to_site_use_id=:SITE_USE_ID
               and rctl2.customer_trx_id=rct2.customer_trx_id
               and rctl2.line_type = ''TAX''
               and avt.vat_tax_id = rctl2.vat_tax_id
               and avt.tax_type = ''VAT''
             group by rctl2.customer_trx_id
            ) rctl3
        WHERE   FNAR.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
        AND     RCT.CUSTOMER_TRX_ID = RCTL.CUSTOMER_TRX_ID
        AND     RCTT.CUST_TRX_TYPE_ID = RCT.CUST_TRX_TYPE_ID
        AND     RCT.ORG_ID = RCTT.ORG_ID
        AND     HCA.CUST_ACCOUNT_ID = RCT.BILL_TO_CUSTOMER_ID
        AND     HP.PARTY_ID = HCA.PARTY_ID
        AND     HCSU.SITE_USE_ID = RCT.BILL_TO_SITE_USE_ID
        AND     ACR.CASH_RECEIPT_ID = FNAR.CASH_RECEIPT_ID
        AND     FNB.BATCH_ID = FNAR.BATCH_ID
        AND     FNAR.BATCH_ID = :BATCH_ID
        -- Detail mode
        AND     RCT.BILL_TO_CUSTOMER_ID = :CUST_ACCOUNT_ID
        AND     RCT.BILL_TO_SITE_USE_ID = :SITE_USE_ID
        -- Russian Requirement
        and    rctl3.customer_trx_id(+) = rct.customer_trx_id
        GROUP BY
                RCT.TRX_NUMBER,
                RCTT.NAME,
                RCT.TRX_DATE,
		FNAR.TXN_CURR_NET_AMT,
                RCT.INVOICE_CURRENCY_CODE,
                FNAR.NETTED_AMT,
                FNB.BATCH_CURRENCY,
                ACR.RECEIPT_NUMBER,
		FNB.batch_id,
		RCT.CUSTOMER_TRX_ID,
		FNAR.APPLIED_DISC
        ORDER BY
                 RCT.TRX_NUMBER');


    DBMS_XMLGEN.setRowSetTag(l_qryCtx,'TRANSACTION_SET');
    DBMS_XMLGEN.setRowTag(l_qryCtx, 'TRANSACTION_RECORD');
    DBMS_XMLGEN.setBindValue(l_qryCtx,'BATCH_ID', p_batch_id);
    DBMS_XMLGEN.setBindValue(l_qryCtx,'CUST_ACCOUNT_ID', rec.CUST_ACCOUNT_ID);
    DBMS_XMLGEN.setBindValue(l_qryCtx,'SITE_USE_ID', rec.SITE_USE_ID);
    l_result_clob :=DBMS_XMLGEN.GETXML(l_qryCtx);
    l_result_clob := substr(l_result_clob,instr(l_result_clob,'>')+1);
    l_temp_trx_count := DBMS_XMLGEN.getNumRowsProcessed(l_qryCtx);
    l_trx_count := l_trx_count + l_temp_trx_count;
    DBMS_XMLGEN.closeContext(l_qryCtx);
    clob_to_file(l_result_clob);

    put_endtag('CUSTOMER_RECORD');

  end loop;

  put_endtag('CUSTOMER_SET');


  put_starttag('SETUP');
  put_element('REPORT_NAME',l_report_name);
  put_element('BATCH_ID',p_batch_id);
  put_element('BATCH_COUNT',l_batch_count);
  put_element('INVOICE_COUNT',l_invoice_count);
  put_element('TRX_COUNT',l_trx_count);
  put_endtag('SETUP');


  put_endtag('NETTING_REPORT');

EXCEPTION

    WHEN OTHERS then
      FUN_UTIL.log_conc_unexp(l_current_calling_sequence, SQLERRM);
      APP_EXCEPTION.RAISE_EXCEPTION;

END final_netting_report;


END FUN_XML_REPORT_PKG;

/
