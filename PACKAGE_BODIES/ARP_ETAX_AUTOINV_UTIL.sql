--------------------------------------------------------
--  DDL for Package Body ARP_ETAX_AUTOINV_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ETAX_AUTOINV_UTIL" AS
/* $Header: AREBTAIB.pls 120.31.12010000.20 2009/11/30 09:16:03 amitshuk ship $ */

/*=======================================================================+
 |  Package Globals
 +=======================================================================*/
   g_inv_manual_tax             BOOLEAN := FALSE;
   g_cm_manual_tax              BOOLEAN := FALSE;
   g_tax_detected               BOOLEAN := FALSE;
   g_latin_tax                  BOOLEAN := FALSE;
   g_ebt_gt_populated           BOOLEAN := FALSE; -- 7329586
   g_headers_inserted           NUMBER;
   g_lines_inserted             NUMBER;
   g_tax_lines_inserted         NUMBER;
   g_tax_line_links_inserted    NUMBER;
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
    fnd_file.put_line(FND_FILE.LOG, text);
    -- arp_standard.debug(text);
END;

/* Private Procedure - Inserts headers into ZX_TRX_HEADERS_GT

   11-MAR-2009  MRAYMOND    8274204   Added document_sub_type,
                                      default_taxation_country,
                                      tax_invoice_date, and
                                      tax_invoice_number
*/
PROCEDURE insert_headers(
                 p_request_id IN  NUMBER,
                 p_phase      IN  VARCHAR2) IS

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_autoinv_util.insert_headers()+');
   END IF;

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
     trx_currency_code,
     precision,
     minimum_accountable_unit,
     currency_conversion_date,
     currency_conversion_rate,
     currency_conversion_type,
     rounding_bill_to_party_id,
     rndg_bill_to_party_site_id,
     bill_third_pty_acct_id,
     bill_to_cust_acct_site_use_id,
     bill_third_pty_acct_site_id,
     application_doc_status,
     related_doc_application_id,
     related_doc_entity_code,
     related_doc_event_class_code,
     related_doc_trx_id,
     related_doc_number,
     related_doc_date
   )
   SELECT
     AR.org_id,
     HR.location_id,
     T.legal_entity_id,
     222,
     AR.set_of_books_id,
     'TRANSACTIONS',
     DECODE(TT.type, 'INV', 'INVOICE',
                     'DM',  'DEBIT_MEMO',
                     'CM',  'CREDIT_MEMO'), -- event_class
     DECODE(TT.type, 'INV', 'INV_CREATE',
                     'DM',  'DM_CREATE',
                     'CM',  'CM_CREATE'),   -- event_type
     'Y',
     T.customer_trx_id,
     T.trx_number,
     SUBSTRB(T.comments,1,240),
     T.doc_sequence_id,
     SEQ.name,      -- 6806843
     T.doc_sequence_value,
     T.batch_source_id,
     TB.name,
     T.cust_trx_type_id,
     TT.description,
     T.trx_date,
     T.printing_original_date,
     T.term_due_date,
     T.invoice_currency_code,
     C.precision,
     C.minimum_accountable_unit,
     T.exchange_date,
     T.exchange_rate,
     T.exchange_rate_type,
     BTCA.party_id,
     BTPS.party_site_id,
     T.bill_to_customer_id,
     T.bill_to_site_use_id,
     BTPS.cust_acct_site_id,
     DECODE(T.status_trx,'VD','VD',NULL), -- VOID
     DECODE(REL_T.customer_trx_id, NULL, NULL, 222),
     DECODE(REL_T.customer_trx_id, NULL, NULL, 'TRANSACTIONS'),
     DECODE(REL_T.customer_trx_id, NULL, NULL,
         DECODE(REL_TT.type, 'INV', 'INVOICE',
                             'DM',  'DEBIT_MEMO',
                             'CM',  'CREDIT_MEMO')),
     DECODE(REL_TT.TYPE,'DEP' , NULL, REL_T.customer_trx_id), /* Bug 9117334 */
     DECODE(REL_T.customer_trx_id, NULL, NULL, REL_T.trx_number),
     DECODE(REL_T.customer_trx_id, NULL, NULL, REL_T.trx_date)
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
   AND   NVL(T.previous_customer_trx_id, -99) =
         DECODE(p_phase, 'INV', -99, T.previous_customer_trx_id)
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
   /* also set tax_reporting_flag when necessary */
   UPDATE ZX_TRX_HEADERS_GT HGT
   SET    (document_sub_type, default_taxation_country,
           tax_reporting_flag,
           tax_invoice_date,
           tax_invoice_number) =
       (SELECT MAX(document_sub_type),
               MAX(default_taxation_country),
               MAX(decode(IL.taxed_upstream_flag,'Y','N','Y')),
               MAX(IL.tax_invoice_date),
               MAX(IL.tax_invoice_number)
        FROM   RA_INTERFACE_LINES IL
        WHERE  HGT.trx_id = IL.customer_trx_id
        GROUP BY IL.customer_trx_id);

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_autoinv_util.insert_headers()-');
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
     debug('arp_etax_autoinv_util.insert_headers()-  No transaction headers to process.');
     RETURN;
   WHEN OTHERS
   THEN
     debug('EXCEPTION: ARP_ETAX_AUTOINV_UTIL.insert_headers()-');
     RAISE;

END insert_headers;

/* Private Procedure - Inserts lines (not tax) into ZX_TRANSACTION_LINES_GT

   Dev Note:

    1) Added outer joins to REC/gldist because the dists don't exist (yet) for
       CMs.  This was preventing insertion of CM lines for tax calculation.

    2) Added support for tax-only type memo lines

    3) Populated poo and poa party and location values

    4) Populated bill_from_location_id (same as poa_location_id)


    15-MAY-07  MRAYMOND  6033706   Added 6 additional etax columns

    23-DEC-08  MRAYMOND  7602206   Modified trx_line_quantity for
      regular credit memos
*/
PROCEDURE insert_lines(
                 p_request_id IN  NUMBER,
                 p_phase      IN  VARCHAR2) IS

  l_return_status VARCHAR2(50);
  l_so_org_id     VARCHAR2(20);
  l_lines_updated NUMBER;
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_autoinv_util.insert_lines()+');
   END IF;

   l_so_org_id := oe_profile.value('SO_ORGANIZATION_ID',
                       arp_global.sysparam.org_id);

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
     product_org_id,
     uom_code,
     fob_point,
     ship_from_party_id,     -- warehouse_id
     ship_from_location_id,  -- warehouse location
     ship_to_party_id,
     ship_to_party_site_id,
     bill_to_party_id,
     bill_to_party_site_id,
     adjusted_doc_application_id,
     adjusted_doc_entity_code,
     adjusted_doc_event_class_code,
     adjusted_doc_trx_id,
     adjusted_doc_line_id,
     adjusted_doc_trx_level_type,
     adjusted_doc_number,
     adjusted_doc_date,
     source_application_id,
     source_entity_code,
     source_event_class_code,
     source_trx_id,
     source_line_id,
     source_trx_level_type,
     source_tax_line_id, -- 6470486
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
     'RA_INTERFACE_LINES',
     TL.customer_trx_line_id,
     TL.customer_trx_id,
     'LINE',
     TL.customer_trx_line_id,
     ZTH.event_class_code,    --7833172
	DECODE(TL.line_type,'CHARGES','RECORD_WITH_NO_TAX',
	DECODE(NVL(ITL.taxable_flag, TL.taxable_flag), 'N', 'RECORD_WITH_NO_TAX',
        DECODE(ML.line_type,'TAX','LINE_INFO_TAX_ONLY',
                 'CREATE'))),
     NVL(TL.sales_order_date,T.ship_date_actual),
     DECODE(TL.inventory_item_id, NULL, 'MISC', 'ITEM'),
     NULL,
     DECODE(TL.amount_includes_tax_flag,'Y','A','N','N','S'),
     TL.extended_amount,
     DECODE(ZTH.event_class_code, 'CREDIT_MEMO', NVL(TL.quantity_credited,TL.quantity_invoiced),
        TL.quantity_invoiced),
     TL.unit_selling_price,
     TL.tax_exempt_number,
     TL.tax_exempt_reason_code,
     TL.tax_exempt_flag,
     NVL(TL.inventory_item_id, TL.memo_line_id), -- product_id
     DECODE(TL.memo_line_id, NULL,
         NVL(TL.warehouse_id,to_number(l_so_org_id)), NULL), -- product_org_id
     TL.uom_code,
     T.fob_point,
     TL.warehouse_id,  -- ship_from_party_id
     HR.location_id,   -- ship_from_location_id
     STCA.party_id,    -- ship to party
     STPS.party_site_id,  -- ship to site
     ZTH.rounding_bill_to_party_id,   -- bill to party
     ZTH.rndg_bill_to_party_site_id,  -- bill to site
     DECODE(TL.previous_customer_trx_line_id, NULL, NULL, 222),
     DECODE(TL.previous_customer_trx_line_id, NULL, NULL, 'TRANSACTIONS'),
     /* bug6769106 vavenugo
      modified the line below to pass the correct value for adjusted_doc_event_class_code based on the type of the document */
     DECODE(TL.previous_customer_trx_line_id, NULL, NULL, DECODE(ITT.TYPE,'DM','DEBIT_MEMO','INVOICE')),
     DECODE(TL.previous_customer_trx_line_id, NULL, NULL,
                 T.previous_customer_trx_id),
     DECODE(TL.previous_customer_trx_line_id, NULL, NULL,
                 TL.previous_customer_trx_line_id),
     DECODE(TL.previous_customer_trx_line_id, NULL, NULL, 'LINE'),
     DECODE(T.previous_customer_trx_id, NULL, NULL, IT.trx_number),
     DECODE(T.previous_customer_trx_id, NULL, NULL, IT.trx_date),
     RIL.source_application_id,
     RIL.source_entity_code,
     RIL.source_event_class_code,
     RIL.source_trx_id,
     RIL.source_trx_line_id,
     RIL.source_trx_line_type,
     RIL.source_trx_detail_tax_line_id, -- 6470486
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
     TL.ship_to_customer_id,
     STPS.cust_acct_site_id,       -- ship_third_pty_acct_site_id
     STCSU.site_use_id,
     ZTH.internal_organization_id, -- poa_party_id
     ZTH.internal_org_location_id, -- poa_location_id
     ZTH.internal_organization_id, -- poo_party_id (default value)
     ZTH.internal_org_location_id, -- poo_location_id (default value)
     TL.extended_amount * arp_etax_util.get_discount_rate(T.customer_trx_id),
     ZTH.internal_org_location_id, -- bill_from_location_id
     RIL.trx_business_category,    -- 6033706
     RIL.product_fisc_classification, -- 6033706
     NVL(RIL.product_category,ML.tax_product_category),
     RIL.product_type,             -- 6033706
     RIL.line_intended_use,        -- 6033706
     RIL.assessable_value,         -- 6033706
     RIL.user_defined_fisc_class,   -- 6033706
     ( SELECT Decode( p_phase,'CM',null,code_combination_id)
       FROM   ra_cust_trx_line_gl_dist gld
       WHERE  rownum = 1
       AND    gld.customer_trx_line_id = TL.customer_trx_line_id
       AND    gld.account_class = 'REV'
       AND    gld.request_id = tl.request_id) account_ccid,
      TL.description
   FROM
     RA_CUSTOMER_TRX_LINES    TL,
     RA_CUSTOMER_TRX          T,
     RA_INTERFACE_LINES       RIL,
     ZX_TRX_HEADERS_GT        ZTH,
     HZ_CUST_ACCOUNTS         STCA,
     HZ_CUST_ACCT_SITES       STPS,
     HZ_CUST_SITE_USES        STCSU,
     RA_CUSTOMER_TRX          IT,
     RA_CUST_TRX_TYPES        ITT,
     RA_CUSTOMER_TRX_LINES    ITL,
     RA_CUST_TRX_LINE_GL_DIST REC,
     HZ_PARTY_SITES           STPSU,
     HZ_PARTY_SITES           BTPSU,
     HR_ALL_ORGANIZATION_UNITS HR,
     AR_MEMO_LINES_B           ML
   WHERE
         TL.request_id = p_request_id
   AND   TL.line_type in ('LINE','CHARGES')
   AND   TL.customer_trx_id = T.customer_trx_id
   AND   TL.customer_trx_line_id = RIL.interface_line_id (+)
   AND   TL.customer_trx_id = ZTH.trx_id
   AND   NVL(T.previous_customer_trx_id, -99) =
         DECODE(p_phase, 'INV', -99, T.previous_customer_trx_id)
   AND   TL.ship_to_customer_id =
            STCA.cust_account_id (+)
   AND   TL.ship_to_site_use_id =
            STCSU.site_use_id (+)
   AND   STCSU.cust_acct_site_id = STPS.cust_acct_site_id (+)
   AND   STPS.party_site_id = STPSU.party_site_id (+)
   AND   ZTH.rndg_bill_to_party_site_id = BTPSU.party_site_id
   AND   T.previous_customer_trx_id =
            IT.customer_trx_id (+)
   AND   IT.cust_trx_type_id =
            ITT.cust_trx_type_id (+)
   AND   TL.previous_customer_trx_line_id =
            ITL.customer_trx_line_id (+)
   AND   REC.customer_trx_id (+) = T.customer_trx_id
   AND   REC.account_class (+) = 'REC'
   AND   REC.latest_rec_flag (+) = 'Y'
   AND   TL.warehouse_id = HR.organization_id (+)
   AND   TL.memo_line_id = ML.memo_line_id (+)
   AND   TL.org_id = ML.org_id (+);

   g_lines_inserted := SQL%ROWCOUNT;

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('lines inserted = ' || g_lines_inserted);
   END IF;

   /* 6874006 - removed salesrep/person logic from main insert
       and shifted it to a separate UPDATE */
  update zx_transaction_lines_gt ZXL
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
   END IF;

--BUG 6798210 combined the CCID update in above select

   /* 4705358 - If LTE is enabled then call etax routine to set
       specific columns for LTE processing */
   /* 5924521 - Modified 'LATIN' to 'LTE' */
   IF arp_global.sysparam.tax_method = 'LTE'
   THEN
      IF PG_DEBUG in ('Y', 'C')
      THEN
         debug('  calling zx_product_integration_pkg.copy_lte_gdfs...');
      END IF;

      zx_product_integration_pkg.copy_lte_gdfs(l_return_status);

   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_autoinv_util.insert_lines()-');
   END IF;

EXCEPTION
   WHEN OTHERS
   THEN
     debug('EXCEPTION: ARP_ETAX_AUTOINV_UTIL.insert_lines()- ' ||
            SQLERRM);
     RAISE;
END insert_lines;

/* Inserts manual tax lines into IMPORT_GT table when
   then are present in ra_interface_lines

DEV NOTE:

   1) Jury is still out on how to link the manual tax lines to
       the invoice lines.  Harsh is following up with the
       other etax people about why no ID column was added
       to the LINK_GT table.

      RESP:  Harsh responded 3/28 in IM stating that we won't need to
      use link table anymore.  They are gonna provide a link column
      in the manual tax lines.
*/

PROCEDURE insert_tax_lines(
                p_request_id IN NUMBER,
                p_phase      IN VARCHAR2) IS

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_autoinv_util.insert_tax_lines()+');
   END IF;

   /* Note that this code does not directly use p_phase
      However, it does join to ZX_TRX_HEADERS_GT which
      would implicitly restrict the appearance of
      INV rows in CM phase. */

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
     'RA_INTERFACE_LINES',
     RIL.interface_line_id, -- tax line
     ZTH.trx_id,
     RIL.link_to_line_id,
     RIL.tax_regime_code,
     RIL.tax,
     RIL.tax_status_code,
     RIL.tax_rate_code,
     RIL.tax_rate,
     RIL.amount,
     RIL.tax_jurisdiction_code,
     DECODE(RIL.amount_includes_tax_flag,'Y','Y','N'),
     RIL.exception_id,
     RIL.exemption_id,
     RIL.tax_exempt_reason_code,
     RIL.tax_exempt_number,
     'N',  -- no rows in zx_trx_tax_link_gt
     RIL.interface_line_id       -- 4698302
   FROM
     RA_INTERFACE_LINES    RIL,  -- tax lines
     ZX_TRX_HEADERS_GT     ZTH
   WHERE
           RIL.line_type = 'TAX'
     AND   RIL.request_id = p_request_id
     AND   RIL.customer_trx_id = ZTH.trx_id;

   g_tax_lines_inserted := SQL%ROWCOUNT;

   /* If we processed manual tax lines, we need to change
      the line-level action to CREATE_WITH_TAX */
   IF g_tax_lines_inserted > 0
   THEN
     /* set line level action */
     UPDATE zx_transaction_lines_gt line
     SET    line_level_action = 'CREATE_WITH_TAX'
     WHERE EXISTS
       (SELECT 'manual tax line'
        FROM   ZX_IMPORT_TAX_LINES_GT tax
        WHERE  tax.trx_line_id = line.trx_line_id);
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_autoinv_util.insert_tax_lines()-');
   END IF;

EXCEPTION
   WHEN OTHERS
   THEN
     debug('EXCEPTION: ARP_ETAX_AUTOINV_UTIL.insert_tax_lines()-');
     RAISE;

END insert_tax_lines;


/* Detects manual tax lines for both INV and CM and
   records findings in global package variables */

/* 7329586 - almost don't need this anymore.  The reason for it
   was that the insert for manual tax lines would likely do a FTS
   on zx_trx_header_gt (could take some time).  But with the recent
   bugs, I'm included to just obsolete this routine and always
   do the insert.  */
PROCEDURE detect_manual_tax(
                p_request_id IN NUMBER) IS

  l_ret_val NUMBER := 0;

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_autoinv_util.detect_manual_tax()+');
   END IF;

   /* This routine detects presence of at least one
      manual tax line for invoices and credits separately.
      The idea behind this is that this routine will get
      called twice (potentially) but only execute the
      search for each phase on the first call.

      Part of the criteria for determining if the line is
      a credit is based on l.reference_line_id.  This column
      can be populated for credits and invs against commitments
      but invoices against commitments will not have reference_line_id
      populated on their tax lines.  The second part of the criteria
      restricts the test to only TAX lines. */

   IF (g_tax_detected = FALSE)
   THEN


     BEGIN

      SELECT 1
      INTO   l_ret_val
      FROM   ra_interface_lines
      WHERE  request_id = p_request_id
      AND    line_type = 'TAX'
      AND    reference_line_id is NULL
      AND    rownum = 1;

      IF l_ret_val = 1
      THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           debug('Manual tax for invoices detected');
        END IF;
        g_inv_manual_tax := TRUE;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        g_inv_manual_tax := FALSE;
    END;


    BEGIN
      SELECT 2
      INTO   l_ret_val
      FROM   ra_interface_lines
      WHERE  request_id = p_request_id
      AND    line_type = 'TAX'
      AND    reference_line_id is not NULL
      AND    rownum = 1;

      IF l_ret_val = 2
      THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           debug('Manual tax for credits detected');
        END IF;
        g_cm_manual_tax := TRUE;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         g_cm_manual_tax := FALSE;
    END;

      /* prevent this from getting called again in this session */
      g_tax_detected := TRUE;
   ELSE
      /* Tax already detected, just note the call and leave */
      IF PG_DEBUG in ('Y', 'C') THEN
         debug('tax detect not necesary this time...');
      END IF;

   END IF;


   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_autoinv_util.detect_manual_tax()-');
   END IF;

END detect_manual_tax;

/*========================================================================
 | PUBLIC PROCEDURE populate_ebt_gt
 |
 | DESCRIPTION
 |    Procedure inserts data into ebt GT tables for processing.  At
 |    this time, the code is limited to use in autoinvoice and is
 |    designed to be called with either 'INV' or 'CM' as the mode
 |    which corresponds to the two autoinvoice phases.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_request_id    IN      RAXTRX request_id
 |      p_phase         IN      Either 'INV' or 'CM' indicating RAXTRX phase
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-FEB-2005           MRAYMOND          Created
 |
 *=======================================================================*/
PROCEDURE populate_ebt_gt(
                 p_request_id IN  NUMBER,
                 p_phase      IN  VARCHAR2) IS

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

/*-----------------------------------------------------------------------+
 | User defined exceptions                                               |
 +-----------------------------------------------------------------------*/

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_util.populate_ebt_gt()+');
      debug(' p_request_id :' || p_request_id);
      debug(' p_phase      :' || p_phase);
   END IF;

   /* 7329586 - clear ebt_gt tables if this is second
      or subsequent call within this session */
   IF g_ebt_gt_populated
   THEN
      arp_etax_util.clear_ebt_gt;
      g_ebt_gt_populated := FALSE;
      g_tax_detected := FALSE ;          -- Bug6731444 retest for manual tax
   END IF;

   /* Insert lines into ZX_TRX_HEADERS_GT */
   insert_headers(p_request_id, p_phase);

   /* Insert lines into ZX_TRANSACTION_LINES_GT */
   insert_lines(p_request_id, p_phase);

   /* Detect Manual Tax Lines and stores (caches) results
      in global variables. This will not do anything on subsequent
      calls.*/
   detect_manual_tax(p_request_id);

   /* If manual tax lines exist, populate ZX_IMPORT_TAX_LINES_GT
      and ZX_TRX_TAX_LINK_GT.  Also set line-level action
      on parent lines to CREATE_WITH_TAX accordingly */
      IF (p_phase = 'INV' and g_inv_manual_tax) OR
         (p_phase = 'CM'  and g_cm_manual_tax)
      THEN
        IF PG_DEBUG in ('Y', 'C')
        THEN
           debug('Processing manual tax lines...');
        END IF;

        insert_tax_lines(p_request_id, p_phase);

      ELSE
        IF PG_DEBUG in ('Y', 'C')
        THEN
           debug('No manual tax lines');
        END IF;
      END IF;

   /* 7329586 - set global so next call in this session
      will clear GT tables */
   IF NVL(g_headers_inserted,0) +
      NVL(g_lines_inserted,0) +
      NVL(g_tax_lines_inserted,0) > 0
   THEN
      g_ebt_gt_populated := TRUE;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('PHASE [' || p_phase || ']');
      debug('headers inserted   : ' || g_headers_inserted);
      debug('lines inserted     : ' || g_lines_inserted);
      debug('tax lines inserted : ' || g_tax_lines_inserted);
      debug('arp_etax_util.populate_ebt_gt()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        debug('EXCEPTION: ARP_ETAX_AUTOINV_UTIL.populate_ebt_gt()');
     END IF;
     RAISE;

END populate_ebt_gt;

/* Procedure to retrieve TAX lines from ZX and populate
   RA_CUSTOMER_TRX_LINES accordingly

   06-JAN-2006 M Raymond  4740826 - Added code to retrieve
                           tax classifications back
                           from etax and stamp them
                           on line records.

*/


PROCEDURE build_ar_tax_lines(
                 p_request_id IN  NUMBER,
                 p_phase      IN  VARCHAR2) IS

  l_rows NUMBER;

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_util.build_ar_tax_lines()+');
   END IF;

   /* Dev Notes:

   1) We set autotax flag as inverse of manaully_entered_flag
      coming from eTax

      RESP:  Ok.  That should be fine

   2) Does eTax generate autotax lines when manual ones for
      same inv/cm line are present?  If so, can we still rely
      upon manually_entered_flag to determine which is which?

      RESP:  That is soft-configurable.  So we can use
      manually_entered_flag to determine what value
      of autotax should be.

   3) Previous_customer_trx_line_id.. we need a way to set this
      for each CM tax line.  I communicated this to Santosh on
      3-MAR-05 along with my suggestion which was to have them add
      a 45th column for link_to_trx_line_id or perhaps applied_to_trx_line_id
      The idea for this is that they pass me the eTax line_id of the target
      tax line and I use that to fetch the customer_trx_line_id of the
      corresponding line in ra_customer_trx_lines.

      However, I'll probably need an index based on tax_line_id in
      RA_CUSTOMER_TRX_LINES table to make that search fast enough

      RESP:  They are now allowing me to pass the interface_line_id
      of the invoice lines and tax lines in -- and they pass them back
      out.  This should be enough to let me get what I need from
      ra_interface_lines

   4) changed zx_detail_tax_lines_gt to zx_lines at request of santosh
       during IM conv on 25-MAY.  Apparently, zx_detail_tax_lines_gt
       is only for quotes.

   5) Identified a loose end where we were not populating prev_cust_trx_line_id
       on tax lines.  corrected both here and ARP_ETAX_UTIL

   6) ORA-28115 raised because we were not setting org_id
   End Dev Notes */


   /* Insert rows into RA_CUSTOMER_TRX_LINES for the
      new TAX lines */
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
      PREVIOUS_CUSTOMER_TRX_ID,
      PREVIOUS_CUSTOMER_TRX_LINE_ID,
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
      NVL(mtax.interface_line_id,ra_customer_trx_lines_s.nextval),
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
      p_request_id,
      zxt.tax_amt,
      zxt.tax_rate,
      DECODE(NVL(zxt.manually_entered_flag, 'N'), 'Y', NULL, 'Y'),
      zxt.tax_amt_included_flag,  -- either Y or N from zx_lines
      zxt.taxable_amt,
      zxt.tax_rate_id,
      zxt.tax_line_id,
      inv_lin.customer_trx_id,  --Bug8468428
      inv_lin.customer_trx_line_id,
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
   FROM   ZX_LINES               zxt,
          RA_CUSTOMER_TRX_LINES  plin,
          RA_INTERFACE_LINES     mtax,
          ZX_LINES               inv_zxt,
          RA_CUSTOMER_TRX_LINES  inv_lin
   WHERE  plin.request_id = p_request_id
     AND  zxt.application_id = 222
     AND  zxt.entity_code = 'TRANSACTIONS'
     AND  zxt.event_class_code in ('INVOICE','DEBIT_MEMO','CREDIT_MEMO')
     AND  zxt.trx_id = plin.customer_trx_id
     AND  zxt.trx_level_type = 'LINE'
     AND  zxt.trx_line_id = plin.customer_trx_line_id
     AND  zxt.interface_tax_line_id = mtax.interface_line_id (+)
     AND  zxt.adjusted_doc_tax_line_id = inv_zxt.tax_line_id (+)
     AND  inv_zxt.trx_line_id = inv_lin.link_to_cust_trx_line_id (+)
     AND  inv_zxt.tax_line_id = inv_lin.tax_line_id (+)
     AND  decode(p_phase, 'CM', plin.previous_customer_trx_line_id,-99) =
          nvl(plin.previous_customer_trx_line_id, -99);

   l_rows := SQL%ROWCOUNT;

   IF l_rows > 0
   THEN
      /* Stamp transaction lines with tax_classification
          from ZX_LINES_DET_FACTORS */
      arp_etax_util.set_default_tax_classification(p_request_id, p_phase);

      /* adjust for inclusive tax */
      arp_etax_util.adjust_for_inclusive_tax(null, p_request_id, p_phase);
   END IF;

   /* Set line_recoverable and tax_recoverable here */
   arp_etax_util.set_recoverable(null, p_request_id, p_phase);

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('  Number of tax lines retrieved = ' || l_rows);
      debug('arp_etax_util.build_ar_tax_lines()-');
   END IF;
END build_ar_tax_lines;

/* Procedure to extract error/validation messages from ZX
   and insert them into RA_INTERFACE_ERRORS */
PROCEDURE retrieve_tax_validation_errors(p_error_count IN OUT NOCOPY NUMBER) IS

   l_trx_errors      NUMBER := 0;
   l_trx_line_errors NUMBER := 0;
   l_tax_line_errors NUMBER := 0;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_util.retrieve_tax_validation_errors()+');
   END IF;

   /* Dev Notes:

   */

   /* Line level errors */
--Bug8468428
   INSERT INTO RA_INTERFACE_ERRORS
    (
       interface_line_id,
       message_text,
       org_id
    )
    SELECT
       il.interface_line_id,
       zxe.message_text,
       il.org_id
    FROM      ZX_VALIDATION_ERRORS_GT zxe,
              ra_interface_lines      il
    WHERE     zxe.trx_id = il.customer_trx_id
    AND       NVL(zxe.interface_line_id, NVL(zxe.trx_line_id,
                  il.interface_line_id)) = il.interface_line_id
    AND       il.line_type <> 'TAX'
    AND       zxe.summary_tax_line_number is NULL;

   l_trx_line_errors := SQL%ROWCOUNT;

   /* Manual Tax Line errors */
   INSERT INTO RA_INTERFACE_ERRORS
   (
      interface_line_id,
      message_text,
      invalid_value,
      org_id
   )
   SELECT
      zxe.summary_tax_line_number,
      zxe.message_text,
      DECODE(zxe.message_name,
             'ZX_DEFAULT_RATE_CODE_NOT_EXIST', 'tax_regime = ' || it.tax_regime_code ||
                                               ' tax = ' || it.tax,
             'ZX_DEFAULT_JUR_CODE_NOT_EXIST',  'tax_regime = ' || it.tax_regime_code ||
                                               ' tax = ' || it.tax,
             'ZX_JUR_CODE_NOT_EFFECTIVE',        it.tax_jurisdiction_code,
             'ZX_JUR_CODE_NOT_EXIST',            it.tax_jurisdiction_code,
             'ZX_TAX_NOT_EXIST',                 it.tax,
             'ZX_TAX_NOT_LIVE',                  it.tax,
             'ZX_TAX_RECOV_OR_OFFSET',           it.tax,
             'ZX_TAX_STATUS_NOT_EFFECTIVE',      it.tax_status_code,
             'ZX_TAX_RATE_NOT_EXIST',            it.tax_rate_code,
             'ZX_TAX_RATE_NOT_EFFECTIVE',        it.tax_rate_code,
             'ZX_TAX_RATE_NOT_ACTIVE',           it.tax_rate_code,
                    NULL),
             it.org_id
   FROM      ZX_VALIDATION_ERRORS_GT zxe,
             ra_interface_lines      it
   WHERE     zxe.trx_id = it.customer_trx_id
   AND       zxe.interface_tax_line_id = it.interface_line_id
   AND       it.line_type = 'TAX';

   l_tax_line_errors := SQL%ROWCOUNT;

   INSERT INTO RA_INTERFACE_ERRORS
   (
      interface_line_id,
      message_text,
      invalid_value,
      org_id
   )
   SELECT
      it.interface_line_id,
      zxe.message_text,
                    NULL,
             it.org_id
   FROM      ZX_ERRORS_GT zxe,
             ra_interface_lines      it
   WHERE     zxe.trx_id = it.customer_trx_id;

   l_tax_line_errors := l_tax_line_errors + SQL%ROWCOUNT;
   debug('rows inserted through zx_errors_gt '||sql%rowcount);

   p_error_count := l_trx_errors + l_trx_line_errors + l_tax_line_errors;

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('Validation errors:  ' || l_trx_line_errors ||
                                            '+' || l_tax_line_errors ||
                                            '=' || p_error_count);
      debug('arp_etax_util.retrieve_tax_validation_errors()-');
   END IF;

END retrieve_tax_validation_errors;

/* External public call designed for autoinvoice.  This will
   populate the ZX tables, validate the data, calculate the tax,
   and insert resulting tax lines back into AR */
PROCEDURE calculate_tax(p_request_id  IN NUMBER,
                        p_phase       IN VARCHAR2,
                        p_error_count IN OUT NOCOPY NUMBER,
                        p_return_status  OUT NOCOPY NUMBER) IS

   l_return_status  NUMBER;

BEGIN
   IF PG_DEBUG in ('Y', 'C')
   THEN
      debug('arp_etax_autoinv_util.calculate_tax()+');
      debug('request_id = ' || p_request_id);
      debug('phase = ' || p_phase);
   END IF;

   /* Insert data into ebt tables */
   populate_ebt_gt(p_request_id, p_phase);

   /* Call validate_and_default_tax_attr */
   arp_etax_util.validate_tax_int(p_return_status => l_return_status,
                                  p_called_from_AI => 'Y');
      p_return_status := l_return_status;

   /* Only call these routines if the prior call returns successful.
        Otherwise, a rollback will occur once the call returns
        to raaebt (or invoice API) */
   IF l_return_status = 0
   THEN
      /* Call import_document_with_tax */
      arp_etax_util.calculate_tax_int(p_return_status => l_return_status,
                                      p_called_from_AI => 'Y');
      p_return_status := l_return_status;
   END IF;

   /* Only call these routines if the prior call returns successful.
        Otherwise, a rollback will occur once the call returns
        to raaebt (or invoice API) */
   IF l_return_status = 0
   THEN
      /* retrieve validation errors and populate RA_INTERFACE_ERRORS */
      retrieve_tax_validation_errors(p_error_count);

      /* Pull resulting tax lines and populate RA_CUSTOMER_TRX_LINES */
      build_ar_tax_lines(p_request_id, p_phase);
   END IF;

   IF PG_DEBUG in ('Y', 'C')
   THEN
      debug('arp_etax_autoinv_util.calculate_tax()-');
   END IF;
END calculate_tax;

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
   NULL;
END ARP_ETAX_AUTOINV_UTIL;

/
