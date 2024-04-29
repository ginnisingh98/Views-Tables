--------------------------------------------------------
--  DDL for Package Body ARP_ETAX_INVAPI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ETAX_INVAPI_UTIL" AS
/* $Header: AREBTIAB.pls 120.27.12010000.9 2009/05/20 20:34:19 mraymond ship $ */

/*=======================================================================+
 |  Package Globals
 +=======================================================================*/
   g_inv_manual_tax             BOOLEAN := FALSE;
   g_tax_detected               BOOLEAN := FALSE;
   g_headers_inserted           NUMBER;
   g_lines_inserted             NUMBER;
   g_tax_lines_inserted         NUMBER;
   g_tax_line_links_inserted    NUMBER;
   g_ebt_schema                 VARCHAR2(30); -- stores ZX schema name
   l_status                     VARCHAR2(1);  -- junk variable
   l_industry                   VARCHAR2(1);  -- junk variable

/*========================================================================
 | Prototype Declarations Procedures
 *=======================================================================*/

   PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*========================================================================
 | Prototype Declarations Functions
 *=======================================================================*/

PROCEDURE debug(text IN VARCHAR2) IS
BEGIN
    -- fnd_file.put_line(FND_FILE.LOG, text);
    arp_standard.debug(text);
END;

/* Private Procedure - Inserts headers into ZX_TRX_HEADERS_GT

   15-MAY-07  MRAYMOND    6033706   Added document_sub_type and
                                    default_taxation_country
*/
PROCEDURE insert_headers(
                 p_request_id IN  NUMBER) IS

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_invapi_util.insert_headers()+');
   END IF;

   /* 4666566 added ship_to columns.  Note that invoice API
      only supports ship_to at header level at this time
   */

   INSERT INTO ZX_TRX_HEADERS_GT
   (
     internal_organization_id,
     internal_org_location_id,
     legal_entity_id,
     application_id,
     ledger_id,
     entity_code,
     event_class_code,
     event_type_code,
     tax_reporting_flag,
     trx_id,
     trx_number,
     trx_description,
     doc_seq_id,
     doc_seq_name,
     doc_seq_value,
     batch_source_id,
     batch_source_name,
     receivables_trx_type_id,
     trx_type_description,
     trx_date,
     trx_communicated_date,
     trx_due_date,
     bill_to_cust_acct_site_use_id,
     trx_currency_code,
     precision,
     minimum_accountable_unit,
     currency_conversion_date,
     currency_conversion_rate,
     currency_conversion_type,
     rounding_bill_to_party_id,
     rndg_bill_to_party_site_id,
     application_doc_status,
     related_doc_application_id,
     related_doc_entity_code,
     related_doc_event_class_code,
     related_doc_trx_id,
     related_doc_number,
     related_doc_date,
     bill_third_pty_acct_id,
     bill_third_pty_acct_site_id
   )
   SELECT
     AR.org_id,
     HR.location_id,
     T.legal_entity_id,
     222,
     AR.set_of_books_id,
     'TRANSACTIONS',
     /* 7166862 */
      DECODE(TT.type, 'INV', 'INVOICE',
                     'DM',  'DEBIT_MEMO',
                      'CM',  'CREDIT_MEMO'), -- event_class
      DECODE(TT.type, 'INV', 'INV_CREATE',
                       'DM',  'DM_CREATE',
                       'CM',  'CM_CREATE'), -- event_type
     'Y',
     T.customer_trx_id,
     T.trx_number,
     SUBSTRB(T.comments,1,240),
     T.doc_sequence_id,
     -- bug 6806843
     --TT.name,
     SEQ.name,
     T.doc_sequence_value,
     T.batch_source_id,
     TB.name,
     T.cust_trx_type_id,
     TT.description,
     T.trx_date,
     T.printing_original_date,
     T.term_due_date,
     T.bill_to_site_use_id,
     T.invoice_currency_code,
     C.precision,
     C.minimum_accountable_unit,
     T.exchange_date,
     T.exchange_rate,
     T.exchange_rate_type,
     BTCA.party_id,
     BTPS.party_site_id,
     DECODE(T.status_trx,'VD','VD',NULL), -- void
     DECODE(REL_T.customer_trx_id, NULL, NULL, 222),
     DECODE(REL_T.customer_trx_id, NULL, NULL, 'TRANSACTIONS'),
     DECODE(REL_T.customer_trx_id, NULL, NULL,
         DECODE(REL_TT.type, 'INV', 'INVOICE',
                             'DM',  'DEBIT_MEMO',
                             'CM',  'CREDIT_MEMO')),
     DECODE(REL_T.customer_trx_id, NULL, NULL, REL_T.customer_trx_id),
     DECODE(REL_T.customer_trx_id, NULL, NULL, REL_T.trx_number),
     DECODE(REL_T.customer_trx_id, NULL, NULL, REL_T.trx_date),
     T.bill_to_customer_id,  -- bill_third_pty_acct_id
     BTPS.cust_acct_site_id  -- bill_third_pty_acct_site_id
   FROM  RA_CUSTOMER_TRX      T,
         RA_CUST_TRX_TYPES    TT,
         RA_BATCH_SOURCES     TB,
         FND_CURRENCIES       C,
	 FND_DOCUMENT_SEQUENCES SEQ,
         AR_SYSTEM_PARAMETERS AR,
         HZ_CUST_ACCOUNTS     BTCA,
         HZ_CUST_SITE_USES    BTCSU,
         HZ_CUST_ACCT_SITES   BTPS,
         HR_ORGANIZATION_UNITS HR,
         RA_CUSTOMER_TRX      REL_T,
         RA_CUST_TRX_TYPES    REL_TT
   WHERE T.request_id = p_request_id
   AND   T.invoice_currency_code = C.currency_code
   AND   T.org_id = AR.org_id
   AND   T.cust_trx_type_id = TT.cust_trx_type_id
   AND   T.doc_sequence_id = SEQ.doc_sequence_id (+)
   AND   T.batch_source_id = TB.batch_source_id
   AND   T.bill_to_customer_id = BTCA.cust_account_id
   AND   T.bill_to_site_use_id = BTCSU.site_use_id
   AND   BTCSU.cust_acct_site_id = BTPS.cust_acct_site_id
   AND   HR.organization_id = T.org_id
   AND   T.legal_entity_id is NOT NULL
   AND   T.related_customer_trx_id = REL_T.customer_trx_id (+)
   AND   REL_T.cust_trx_type_id = REL_TT.cust_trx_type_id (+);

   /* Store total for output in debug log */
   g_headers_inserted := SQL%ROWCOUNT;

   /* 6033706 - set document_sub_type and default_taxaction_country */
   /* also set tax_reporting_flag */
   UPDATE ZX_TRX_HEADERS_GT HGT
   SET    (document_sub_type, default_taxation_country,
           tax_reporting_flag) =
       (SELECT MAX(document_sub_type),
               MAX(default_taxation_country),
               MAX(decode(taxed_upstream_flag,'Y','N','Y'))
        FROM   AR_TRX_HEADER_GT IL
        WHERE  HGT.trx_id = IL.customer_trx_id
        GROUP BY IL.customer_trx_id);

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_invapi_util.insert_headers()-');
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
     debug('arp_etax_invapi_util.insert_headers()-  No transaction headers to process.');
     RETURN;
   WHEN OTHERS
   THEN
     debug('EXCEPTION: ARP_ETAX_INVAPI_UTIL.insert_headers()-');
     RAISE;

END insert_headers;

/* Private Procedure - Inserts lines (not tax) into ZX_TRANSACTION_LINES_GT */

/* Dev Note:
   1) Invoice API does not directly support line-level ship to info
      at this time.

   2) Coded for tax-only memo lines

   3) Populated poo and poa party and location values

   4) set cash_discount

   5) set bill_from_location_id

   15-MAY-07  MRAYMOND   6033706  Added 6 additional etax columns
*/
PROCEDURE insert_lines(
                 p_request_id IN  NUMBER) IS
  l_so_org_id     VARCHAR2(20);
  l_lines_updated NUMBER;
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_invapi_util.insert_lines()+');
   END IF;

   l_so_org_id := oe_profile.value('SO_ORGANIZATION_ID',
                       arp_global.sysparam.org_id);

   /* 4666566 added ship_to columns to line-level.  Note that
      API currently only supports header level ship to so I
      am copying them down to line to make uptake of line-level
      easier later */

   INSERT INTO ZX_TRANSACTION_LINES_GT
   (
     application_id,
     entity_code,
     event_class_code,
     interface_entity_code,
     interface_line_id,
     trx_id,
     trx_level_type,
     trx_line_id,
     line_class,
     line_level_action,
     trx_shipping_date,
     trx_line_type,
     trx_line_date,
     line_amt_includes_tax_flag, -- decode of interface column
     line_amt,
     trx_line_quantity,
     unit_price,
     exempt_certificate_number,
     exempt_reason_code,
     exemption_control_flag,
     product_id, -- inventory item or memo line
     product_org_id, -- warehouse_Id
     uom_code,
     fob_point,
     ship_from_party_id,    -- warehouse_id
     ship_from_location_id, -- warehouse location
     bill_to_party_id,
     bill_to_party_site_id,
     source_application_id,
     source_entity_code,
     source_event_class_code,
     source_trx_id,
     source_line_id,
     source_trx_level_type,
     output_tax_classification_code,
     trx_line_number,
     historical_flag,
     ctrl_hdr_tx_appl_flag,  -- 'N'
     trx_line_gl_date,
     ship_to_location_id,
     bill_to_location_id,
     trx_line_currency_code,
     trx_line_precision,
     trx_line_mau,
     ship_third_pty_acct_id,
     ship_third_pty_acct_site_id,
     ship_to_cust_acct_site_use_id,
     ship_to_party_id,
     ship_to_party_site_id,
     poa_party_id,
     poa_location_id,
     poo_party_id,
     poo_location_id,
     cash_discount,
     bill_from_location_id,
     trx_business_category,
     product_fisc_classification,
     product_category,
     product_type,
     line_intended_use,
     assessable_value,
     user_defined_fisc_class,
     account_ccid,
     trx_line_description
   )
   SELECT
     222,
     ZTH.entity_code,
     ZTH.event_class_code,
     'AR_TRX_LINES_GT', -- interface_entity_code
     TLG.trx_line_id,   -- interface_entity_line_id
     TL.customer_trx_id,
     'LINE',
     TL.customer_trx_line_id,
     /* 7166862 */
     ZTH.EVENT_CLASS_CODE,
     DECODE(TL.taxable_flag, 'N', 'RECORD_WITH_NO_TAX',
     DECODE(ML.line_type,'TAX','LINE_INFO_TAX_ONLY',
                 'CREATE')),
     NVL(TL.sales_order_date,T.ship_date_actual),
     DECODE(TL.inventory_item_id, NULL, 'MISC', 'ITEM'),
     NULL,
     DECODE(TL.amount_includes_tax_flag,'Y','A','N','N','S'),
     TL.extended_amount,
     TL.quantity_invoiced,
     TL.unit_selling_price,
     TL.tax_exempt_number,
     TL.tax_exempt_reason_code,
     TL.tax_exempt_flag,
     NVL(TL.inventory_item_id, TL.memo_line_id),            -- product_id
     DECODE(TL.memo_line_id, NULL,
          NVL(TL.warehouse_id,to_number(l_so_org_id)), NULL),-- product_org_id
     TL.uom_code,
     T.fob_point,
     TL.warehouse_id,  -- ship_from_party_id
     HR.location_id,   -- ship_from_location_id
     ZTH.rounding_bill_to_party_id,   -- bill to party
     ZTH.rndg_bill_to_party_site_id,  -- bill to site
  -- null,  account_ccid (set in subsequent update)
     TLG.source_application_id,
     TLG.source_entity_code,
     TLG.source_event_class_code,
     TLG.source_trx_id,
     TLG.source_trx_line_id,
     TLG.source_trx_line_type,
     TL.tax_classification_code,
     TL.line_number,
     TL.historical_flag,
     'N',
     NVL(REC.gl_date, TRUNC(sysdate)),
     STPSU.location_id,
     BTPSU.location_id,
     ZTH.trx_currency_code,
     ZTH.precision,
     ZTH.minimum_accountable_unit,
     T.ship_to_customer_id,
     STPS.cust_acct_site_id,
     STCSU.site_use_id,
     STCA.party_id,       -- ship to party
     STPS.party_site_id,  -- ship to site
     ZTH.internal_organization_id, -- poa_party_id
     ZTH.internal_org_location_id, -- poa_location_id
     ZTH.internal_organization_id, -- poo_party_id (default value)
     ZTH.internal_org_location_id, -- poo_location_id (default value)
     TL.extended_amount * arp_etax_util.get_discount_rate(T.customer_trx_id),
     ZTH.internal_org_location_id, -- bill_from_location_id
     TLG.trx_business_category,    -- 6033706
     TLG.product_fisc_classification, -- 6033706
     NVL(TLG.product_category,ML.tax_product_category),
     TLG.product_type,             -- 6033706
     TLG.line_intended_use,        -- 6033706
     TLG.assessable_value,         -- 6033706
     TLG.user_defined_fisc_class,   -- 6033706
     ( SELECT max(code_combination_id)
       FROM   ra_cust_trx_line_gl_dist gld
       WHERE  gld.customer_trx_line_id = TL.customer_trx_line_id
       AND    gld.account_class = 'REV') account_ccid,
     TL.description
   FROM
     RA_CUSTOMER_TRX_LINES    TL,
     RA_CUSTOMER_TRX          T,
     AR_TRX_LINES_GT          TLG,
     ZX_TRX_HEADERS_GT        ZTH,
     HZ_CUST_ACCOUNTS         STCA,
     HZ_CUST_ACCT_SITES       STPS,
     HZ_CUST_SITE_USES        STCSU,
     RA_CUST_TRX_LINE_GL_DIST REC,
     HZ_PARTY_SITES           STPSU,
     HZ_PARTY_SITES           BTPSU,
     HR_ALL_ORGANIZATION_UNITS HR,
     AR_MEMO_LINES_B           ML
   WHERE
         TL.request_id = p_request_id
   AND   TL.line_type = 'LINE'
   AND   TL.customer_trx_id = T.customer_trx_id
   AND   TL.customer_trx_line_id = TLG.customer_trx_line_id
   AND   TL.customer_trx_id = ZTH.trx_id
   AND   T.ship_to_customer_id =
            STCA.cust_account_id (+)
   AND   T.ship_to_site_use_id =
            STCSU.site_use_id (+)
   AND   STCSU.cust_acct_site_id = STPS.cust_acct_site_id (+)
   AND   STPS.party_site_id = STPSU.party_site_id (+)
   AND   ZTH.rndg_bill_to_party_site_id = BTPSU.party_site_id
   AND   REC.customer_trx_id = T.customer_trx_id
   AND   REC.account_class = 'REC'
   AND   REC.latest_rec_flag = 'Y'
   AND   TL.warehouse_id = HR.organization_id (+)
   AND   TL.memo_line_id = ML.memo_line_id (+)
   AND   TL.org_id = ML.org_id (+);

   g_lines_inserted := SQL%ROWCOUNT;

   IF PG_DEBUG IN ('Y','C') THEN
      debug('lines inserted = ' || g_lines_inserted);
   END IF;

   /* 6874006 - removed salesrep/person logic from main insert
       and shifted it to a separate UPDATE */
  update zx_transaction_lines ZXL
  set    (poo_party_id, poo_location_id) =
     (select SR_PER.organization_id,      -- poo_party_id
             SR_HRL.location_id           -- poo_location_id
      from   RA_CUSTOMER_TRX           TRX,
             JTF_RS_SALESREPS          SR,
             PER_ALL_ASSIGNMENTS_F     SR_PER,
             HR_ORGANIZATION_UNITS     SR_HRL
      where  TRX.customer_trx_id = ZXL.trx_id
      and    TRX.primary_salesrep_id IS NOT NULL
      and    TRX.primary_salesrep_id = SR.salesrep_id
      and    TRX.org_id = SR.org_id
      and    SR.person_id = SR_PER.person_id
      and    TRX.trx_date BETWEEN nvl(SR_PER.effective_start_date, TRX.trx_date)
                              AND nvl(SR_PER.effective_end_date, TRX.trx_date)
      and    NVL(SR_PER.primary_flag, 'Y') = 'Y'
      and    SR_PER.assignment_type = 'E'
      and    SR_PER.organization_id = SR_HRL.organization_id);

   IF PG_DEBUG in ('Y', 'C') THEN
      l_lines_updated := SQL%ROWCOUNT;
      debug('lines update (poo columns) = ' || l_lines_updated);
      debug('arp_etax_invapi_util.insert_lines()-');
   END IF;


EXCEPTION
   WHEN OTHERS
   THEN
     debug('EXCEPTION: ARP_ETAX_INVAPI_UTIL.insert_lines()- ' ||
            SQLERRM);
     RAISE;
END insert_lines;

/* Inserts manual tax lines into IMPORT_GT table when
   they are present in ZX_TRX_LINES_GT

DEV NOTE:

*/

PROCEDURE insert_tax_lines IS

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_invapi_util.insert_tax_lines()+');
   END IF;


   INSERT INTO ZX_IMPORT_TAX_LINES_GT
   (
     internal_organization_id,
     application_id,
     entity_code,
     event_class_code,
     interface_entity_code,
     interface_tax_line_id,
     trx_id,
     trx_line_id,
     tax_regime_code,
     tax,
     tax_status_code,
     tax_rate_code,
     tax_rate,
     tax_amt,
     tax_jurisdiction_code,
     tax_amt_included_flag,
     tax_exception_id,
     tax_exemption_id,
     exempt_reason_code,
     exempt_certificate_number,
     tax_line_allocation_flag,
     summary_tax_line_number -- 4698302
   )
   SELECT
     ZTH.internal_organization_id,
     222,
     ZTH.entity_code,
     ZTH.event_class_code,
     'AR_TRX_LINES_GT',
     GTL.trx_line_id,     -- tax line in AR_GT table
     ZTH.trx_id,
     GTL.link_to_cust_trx_line_id,
     GTL.tax_regime_code,
     GTL.tax,
     GTL.tax_status_code,
     GTL.tax_rate_code,
     GTL.tax_rate,
     GTL.extended_amount,
     GTL.tax_jurisdiction_code,
     GTL.amount_includes_tax_flag,
     GTL.item_exception_rate_id,
     GTL.tax_exemption_id,
     GTL.tax_exempt_reason_code,
     GTL.tax_exempt_number,
     'N', -- no lines in LINK table
     GTL.trx_line_id -- 4698302
   FROM
     AR_TRX_LINES_GT       GTL,  -- tax lines
     ZX_TRX_HEADERS_GT     ZTH
   WHERE
           GTL.line_type = 'TAX'
     AND   GTL.customer_trx_id = ZTH.trx_id;

   g_tax_lines_inserted := SQL%ROWCOUNT;

   /* If we processed manual tax lines, we need to change
      the line-level action to CREATE_WITH_TAX */
   IF g_tax_lines_inserted > 0
   THEN
     /* set line level action */
     UPDATE ZX_TRANSACTION_LINES_GT line
     SET    line_level_action = 'CREATE_WITH_TAX'
     WHERE EXISTS
       (SELECT 'manual tax line'
        FROM   ZX_IMPORT_TAX_LINES_GT tax
        WHERE  tax.trx_line_id = line.trx_line_id);
   END IF;


   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_invapi_util.insert_tax_lines()-');
   END IF;

EXCEPTION
   WHEN OTHERS
   THEN
     debug('EXCEPTION: ARP_ETAX_INVAPI_UTIL.insert_tax_lines()-');
     RAISE;

END insert_tax_lines;


/*========================================================================
 | PUBLIC PROCEDURE populate_ebt_gt
 |
 | DESCRIPTION
 |    Procedure inserts data into ebt GT tables for processing.
 |    This code was designed specifically for use with invoice api.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_request_id  IN NUMBER    request_id used for invoice api batch
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-APR-2005           MRAYMOND          Created
 |
 *=======================================================================*/
PROCEDURE populate_ebt_gt(p_request_id IN NUMBER) IS

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_invapi_util.populate_ebt_gt()+');
   END IF;

   /* Insert lines into ZX_TRX_HEADERS_GT */
   insert_headers(p_request_id);

   /* Insert lines into ZX_TRANSACTION_LINES_GT */
   insert_lines(p_request_id);

   /* Insert manual tax lines */
   insert_tax_lines;

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('headers inserted   : ' || g_headers_inserted);
      debug('lines inserted     : ' || g_lines_inserted);
      debug('tax lines inserted : ' || g_tax_lines_inserted);
      debug('arp_etax_invapi_util.populate_ebt_gt()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        debug('EXCEPTION: ARP_ETAX_INVAPI_UTIL.populate_ebt_gt()');
     END IF;
     RAISE;

END populate_ebt_gt;

/* Procedure to retrieve TAX lines from ZX and populate
   RA_CUSTOMER_TRX_LINES accordingly */
PROCEDURE build_ar_tax_lines(p_request_id IN NUMBER) IS

  l_rows1 NUMBER;
  l_rows2 NUMBER;
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_invapi_util.build_ar_tax_lines()+');
   END IF;

   /* Dev Notes:
    1) swapped zx_detail_tax_lines_gt to zx_lines per svaze in IM
        conv on 25-MAY

   End Dev Notes */

   /* Insert rows into RA_CUSTOMER_TRX_LINES for the
      new TAX lines */
/*4410461 Breaking the insert into two for Manual and Automatic Tax lines*/

   INSERT INTO RA_CUSTOMER_TRX_LINES
   (
      CUSTOMER_TRX_LINE_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID,
      CUSTOMER_TRX_ID,
      LINE_NUMBER,
      SET_OF_BOOKS_ID,
      LINE_TYPE,                -- TAX
      LINK_TO_CUST_TRX_LINE_ID, -- parent line
      DEFAULT_USSGL_TRANSACTION_CODE,
      REQUEST_ID,
      EXTENDED_AMOUNT,
      TAX_RATE,
      AUTOTAX,
      AMOUNT_INCLUDES_TAX_FLAG,
      TAXABLE_AMOUNT,
      VAT_TAX_ID,
      TAX_LINE_ID,               -- ID in ZX_ table
      INTERFACE_LINE_CONTEXT,
      INTERFACE_LINE_ATTRIBUTE1,
      INTERFACE_LINE_ATTRIBUTE2,
      INTERFACE_LINE_ATTRIBUTE3,
      INTERFACE_LINE_ATTRIBUTE4,
      INTERFACE_LINE_ATTRIBUTE5,
      INTERFACE_LINE_ATTRIBUTE6,
      INTERFACE_LINE_ATTRIBUTE7,
      INTERFACE_LINE_ATTRIBUTE8,
      INTERFACE_LINE_ATTRIBUTE9,
      INTERFACE_LINE_ATTRIBUTE10,
      INTERFACE_LINE_ATTRIBUTE11,
      INTERFACE_LINE_ATTRIBUTE12,
      INTERFACE_LINE_ATTRIBUTE13,
      INTERFACE_LINE_ATTRIBUTE14,
      INTERFACE_LINE_ATTRIBUTE15,
      ORG_ID
   )
   SELECT
      mtax.customer_trx_line_id,
      sysdate,
      arp_standard.profile.user_id,
      sysdate,
      arp_standard.profile.user_id,
      arp_standard.profile.user_id,
      arp_standard.profile.program_id,
      arp_standard.application_id,
      zxt.trx_id,
      zxt.tax_line_number,
      arp_standard.sysparm.set_of_books_id,
      'TAX',
      zxt.trx_line_id,
      plin.default_ussgl_transaction_code,
      plin.request_id,
      zxt.tax_amt,
      zxt.tax_rate,
      DECODE(NVL(zxt.manually_entered_flag, 'N'), 'Y', NULL, 'Y'),
      zxt.tax_amt_included_flag,
      zxt.taxable_amt,
      zxt.tax_rate_id,
      zxt.tax_line_id,
      mtax.interface_line_context,
      mtax.interface_line_attribute1,
      mtax.interface_line_attribute2,
      mtax.interface_line_attribute3,
      mtax.interface_line_attribute4,
      mtax.interface_line_attribute5,
      mtax.interface_line_attribute6,
      mtax.interface_line_attribute7,
      mtax.interface_line_attribute8,
      mtax.interface_line_attribute9,
      mtax.interface_line_attribute10,
      mtax.interface_line_attribute11,
      mtax.interface_line_attribute12,
      mtax.interface_line_attribute13,
      mtax.interface_line_attribute14,
      mtax.interface_line_attribute15,
      plin.org_id
   FROM   ZX_LINES zxt,
          RA_CUSTOMER_TRX_LINES  plin,
          AR_TRX_LINES_GT        mtax
   WHERE  plin.request_id = p_request_id
     AND  zxt.application_id = 222
     AND  zxt.entity_code = 'TRANSACTIONS'
    /* 7166862 */
     AND  zxt.event_class_code IN( 'INVOICE','CREDIT_MEMO','DEBIT_MEMO')
     AND  zxt.trx_id = plin.customer_trx_id
     AND  zxt.trx_level_type = 'LINE'
     AND  zxt.trx_line_id = plin.customer_trx_line_id
     AND  NVL(zxt.manually_entered_flag, 'N') = 'Y'
     AND  zxt.interface_tax_line_id = mtax.trx_line_id (+);

   l_rows1 := SQL%ROWCOUNT;

   INSERT INTO RA_CUSTOMER_TRX_LINES
   (
      CUSTOMER_TRX_LINE_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID,
      CUSTOMER_TRX_ID,
      LINE_NUMBER,
      SET_OF_BOOKS_ID,
      LINE_TYPE,                -- TAX
      LINK_TO_CUST_TRX_LINE_ID, -- parent line
      DEFAULT_USSGL_TRANSACTION_CODE,
      REQUEST_ID,
      EXTENDED_AMOUNT,
      TAX_RATE,
      AUTOTAX,
      AMOUNT_INCLUDES_TAX_FLAG,
      TAXABLE_AMOUNT,
      VAT_TAX_ID,
      TAX_LINE_ID,               -- ID in ZX_ table
      INTERFACE_LINE_CONTEXT,
      INTERFACE_LINE_ATTRIBUTE1,
      INTERFACE_LINE_ATTRIBUTE2,
      INTERFACE_LINE_ATTRIBUTE3,
      INTERFACE_LINE_ATTRIBUTE4,
      INTERFACE_LINE_ATTRIBUTE5,
      INTERFACE_LINE_ATTRIBUTE6,
      INTERFACE_LINE_ATTRIBUTE7,
      INTERFACE_LINE_ATTRIBUTE8,
      INTERFACE_LINE_ATTRIBUTE9,
      INTERFACE_LINE_ATTRIBUTE10,
      INTERFACE_LINE_ATTRIBUTE11,
      INTERFACE_LINE_ATTRIBUTE12,
      INTERFACE_LINE_ATTRIBUTE13,
      INTERFACE_LINE_ATTRIBUTE14,
      INTERFACE_LINE_ATTRIBUTE15,
      ORG_ID
   )
   SELECT
      ra_customer_trx_lines_s.nextval,
      sysdate,
      arp_standard.profile.user_id,
      sysdate,
      arp_standard.profile.user_id,
      arp_standard.profile.user_id,
      arp_standard.profile.program_id,
      arp_standard.application_id,
      zxt.trx_id,
      zxt.tax_line_number,
      arp_standard.sysparm.set_of_books_id,
      'TAX',
      zxt.trx_line_id,
      plin.default_ussgl_transaction_code,
      plin.request_id,
      zxt.tax_amt,
      zxt.tax_rate,
      DECODE(NVL(zxt.manually_entered_flag, 'N'), 'Y', NULL, 'Y'),
      zxt.tax_amt_included_flag,
      zxt.taxable_amt,
      zxt.tax_rate_id,
      zxt.tax_line_id,
      mtax.interface_line_context,
      mtax.interface_line_attribute1,
      mtax.interface_line_attribute2,
      mtax.interface_line_attribute3,
      mtax.interface_line_attribute4,
      mtax.interface_line_attribute5,
      mtax.interface_line_attribute6,
      mtax.interface_line_attribute7,
      mtax.interface_line_attribute8,
      mtax.interface_line_attribute9,
      mtax.interface_line_attribute10,
      mtax.interface_line_attribute11,
      mtax.interface_line_attribute12,
      mtax.interface_line_attribute13,
      mtax.interface_line_attribute14,
      mtax.interface_line_attribute15,
      plin.org_id
   FROM   ZX_LINES zxt,
          RA_CUSTOMER_TRX_LINES  plin,
          AR_TRX_LINES_GT        mtax
   WHERE  plin.request_id = p_request_id
     AND  zxt.application_id = 222
     AND  zxt.entity_code = 'TRANSACTIONS'
     /* 7166862 */
     AND  zxt.event_class_code in( 'INVOICE','CREDIT_MEMO','DEBIT_MEMO')
     AND  zxt.trx_id = plin.customer_trx_id
     AND  zxt.trx_level_type = 'LINE'
     AND  zxt.trx_line_id = plin.customer_trx_line_id
     AND  NVL(zxt.manually_entered_flag, 'N') = 'N'
     AND  zxt.interface_tax_line_id = mtax.trx_line_id (+);

     l_rows2 := SQL%ROWCOUNT;

   IF (l_rows1+l_rows2) > 0
   THEN
      /* Stamp transaction lines with tax_classification
          from ZX_LINES_DET_FACTORS */
      arp_etax_util.set_default_tax_classification(p_request_id);

      /* adjust for inclusive tax */
      arp_etax_util.adjust_for_inclusive_tax(null, p_request_id, 'INV');
   END IF;

   /* Set line_recoverable and tax_recoverable */
   arp_etax_util.set_recoverable(null, p_request_id, 'INV');

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('  Number of tax lines retrieved autotax lines  = ' || l_rows2);
      debug('  Number of tax lines retrieved manualtax lines  = ' || l_rows1);
      debug('arp_etax_invapi_util.build_ar_tax_lines()-');
   END IF;
END build_ar_tax_lines;

/* Procedure to extract error/validation messages from ZX
   and insert them into RA_INTERFACE_ERRORS */
PROCEDURE retrieve_tax_validation_errors(p_error_count IN OUT NOCOPY NUMBER) IS

   l_trx_errors      NUMBER       := 0;
   l_trx_validation_errors NUMBER := 0;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_invapi_util.retrieve_tax_validation_errors()+');
   END IF;

   /* Dev Notes:
        When an error is returned on any transaction line, the API
        will automatically reject the entire transaction.  We'll insert
        at least one row in ar_trx_errors_gt for each transaction
        that fails in etax.  Code in the API will then selectively
        roll back data for each transaction with one or more failures.
   */

   /* Line level errors */
   INSERT INTO AR_TRX_ERRORS_GT
    (
       trx_header_id,
       trx_line_id,
       error_message
    )
   SELECT
      il.trx_header_id,
      il.trx_line_id,
      zxe.message_text
   FROM      ZX_VALIDATION_ERRORS_GT zxe,
             AR_TRX_LINES_GT         il
   WHERE  nvl(zxe.interface_tax_line_id, zxe.interface_line_id) =
             il.trx_line_id;

   l_trx_validation_errors := SQL%ROWCOUNT;

   INSERT INTO AR_TRX_ERRORS_GT
    (
       trx_header_id,
       trx_line_id,
       error_message
    )
   SELECT
      it.trx_header_id,
      il.trx_line_id,
      zxe.message_text
   FROM      ZX_ERRORS_GT      zxe,
             AR_TRX_HEADER_GT  it,
             AR_TRX_LINES_GT   il
   WHERE  zxe.trx_id = it.customer_trx_id
   AND    NVL(zxe.trx_line_id, -99) =
            il.customer_trx_line_id (+);

   l_trx_errors := SQL%ROWCOUNT;

   p_error_count := l_trx_errors + l_trx_validation_errors;

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('Validation errors:  ' || l_trx_validation_errors);
      debug('Calculation errors: ' || l_trx_errors);
      debug('arp_etax_invapi_util.retrieve_tax_validation_errors()-');
   END IF;

END retrieve_tax_validation_errors;

/* External public call designed for invoice api.  This will
   populate the ZX tables, validate the data, calculate the tax,
   and insert resulting tax lines back into AR */
PROCEDURE calculate_tax(p_request_id IN NUMBER,
                        p_error_count IN OUT NOCOPY NUMBER,
                        p_return_status  OUT NOCOPY NUMBER) IS
   l_return_status NUMBER := 0;
BEGIN
   IF PG_DEBUG in ('Y', 'C')
   THEN
      debug('arp_etax_invapi_util.calculate_tax()+');
   END IF;

   /* Insert data into ebt tables */
   populate_ebt_gt(p_request_id);

   /* Only call etax if there is something to process */
   IF g_headers_inserted > 0 AND
     (g_lines_inserted > 0 OR g_tax_lines_inserted > 0)
   THEN
      /* Call validate_and_default_tax_attr */
      arp_etax_util.validate_tax_int(l_return_status);
         p_return_status := l_return_status;

      IF l_return_status = 0
      THEN
      /* Call import_document_with_tax */
      arp_etax_util.calculate_tax_int(l_return_status);
         p_return_status := l_return_status;
      END IF;

      IF l_return_status = 0
      THEN
         /* retrieve validation errors and populate RA_INTERFACE_ERRORS */
         retrieve_tax_validation_errors(p_error_count);

         /* Pull resulting tax lines and populate RA_CUSTOMER_TRX_LINES */
         build_ar_tax_lines(p_request_id);
      END IF;

      /* 4904679 - removed logic to detect missing tax lines */

   ELSE
      IF PG_DEBUG in ('Y', 'C')
      THEN
         debug('   no lines inserted for processing, skipping etax call');
      END IF;
   END IF;

   IF PG_DEBUG in ('Y', 'C')
   THEN
      debug('arp_etax_invapi_util.calculate_tax()-');
   END IF;
END calculate_tax;

PROCEDURE cleanup_tax(p_trx_id IN NUMBER) IS

BEGIN

     /* Now call the API to synchronize the repository */
     ARP_ETAX_UTIL.global_document_update(p_trx_id,
                                          NULL,
                                          'DELETE');

END cleanup_tax;

/*

/*========================================================================
 | INITIALIZATION SECTION
 |
 | DESCRIPTION
 |    Initialized global variables for controlling program flow
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-FEB-2005           MRAYMOND          Created
 *=======================================================================*/

BEGIN
  /* Get eTax schema name for TRUNCATE calls */
  IF FND_INSTALLATION.get_app_info('ZX', l_status, l_industry, g_ebt_schema)
  THEN

     IF PG_DEBUG in ('Y', 'C') THEN
         debug('Retrieved schema for ZX   : ' || g_ebt_schema);
     END IF;
  ELSE
     IF PG_DEBUG in ('Y', 'C') THEN
         debug('Problem retrieving ZX schema name from fnd_installation');
     END IF;
     debug('EXCEPTION: ARP_ETAX_AUTOINV_UTIL.INITIALIZE()');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     debug('EXCEPTION: ARP_ETAX_INVAPI_UTIL.INITIALIZE()');
     RAISE;

END ARP_ETAX_INVAPI_UTIL;

/
