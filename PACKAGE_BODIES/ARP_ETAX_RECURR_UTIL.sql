--------------------------------------------------------
--  DDL for Package Body ARP_ETAX_RECURR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ETAX_RECURR_UTIL" AS
/* $Header: AREBTICB.pls 120.20.12010000.8 2009/05/18 19:28:15 mraymond ship $ */

/*=======================================================================+
 |  Package Globals
 +=======================================================================*/
   g_headers_inserted           NUMBER;
   g_lines_inserted             NUMBER;
   g_tax_lines_inserted         NUMBER;
   l_status                     VARCHAR2(1);  -- junk variable
   l_industry                   VARCHAR2(1);  -- junk variable
   g_default_country            VARCHAR2(50);
   g_legal_entity_id            NUMBER;

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

/* Private Procedure - Inserts headers into ZX_TRX_HEADERS_GT */
PROCEDURE insert_header(p_customer_trx_id IN NUMBER) IS

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_recurr_util.insert_header()+');
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
     bill_to_cust_acct_site_use_id,
     trx_currency_code,
     precision,
     minimum_accountable_unit,
     currency_conversion_date,
     currency_conversion_rate,
     currency_conversion_type,
     rounding_bill_to_party_id,
     rndg_bill_to_party_site_id,
     bill_third_pty_acct_id,
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
     'INVOICE',      -- event_class
     'INV_CREATE',   -- event_type
     'Y',
     T.customer_trx_id,
     T.trx_number,
     SUBSTRB(T.comments,1,240),
     T.doc_sequence_id,
     -- bug 6806843
     -- TT.name,
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
     T.bill_to_customer_id,
     BTPS.cust_acct_site_id,
     DECODE(T.status_trx, 'VD','VD',NULL), -- void
     DECODE(REL_T.customer_trx_id, NULL, NULL, 222),
     DECODE(REL_T.customer_trx_id, NULL, NULL, 'TRANSACTIONS'),
     DECODE(REL_T.customer_trx_id, NULL, NULL,
         DECODE(REL_TT.type, 'INV', 'INVOICE',
                             'DM',  'DEBIT_MEMO',
                             'CM',  'CREDIT_MEMO')),
     DECODE(REL_T.customer_trx_id, NULL, NULL, REL_T.customer_trx_id),
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
   WHERE T.customer_trx_id = p_customer_trx_id
   AND   T.invoice_currency_code = C.currency_code
   AND   T.org_id = AR.org_id
   AND   T.cust_trx_type_id = TT.cust_trx_type_id
   AND   T.doc_sequence_id = SEQ.doc_sequence_id (+)
   AND   T.batch_source_id = TB.batch_source_id
   AND   T.bill_to_customer_id = BTCA.cust_account_id
   AND   T.bill_to_site_use_id = BTCSU.site_use_id
   AND   BTCSU.cust_acct_site_id = BTPS.cust_acct_site_id
   AND   HR.organization_id = T.org_id
   AND   T.related_customer_trx_id = REL_T.customer_trx_id (+)
   AND   REL_T.cust_trx_type_id = REL_TT.cust_trx_type_id (+);

   /* Store total for output in debug log */
   g_headers_inserted := SQL%ROWCOUNT;

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('  headers inserted : ' || g_headers_inserted);
      debug('arp_etax_recurr_util.insert_header()-');
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
     debug('arp_etax_recurr_util.insert_header()-  No transaction headers to process.');
     RETURN;
   WHEN OTHERS
   THEN
     debug('EXCEPTION: ARP_ETAX_RECURR_UTIL.insert_header()-');
     RAISE;

END insert_header;

/* Private Procedure - Inserts lines (not tax) into ZX_TRANSACTION_LINES_GT.
    NOTE:  In order for tax to work properly for copied invoices, we
    must populate the source columns for the copied lines with the
    data from the original (AR) lines.

   DEV NOTE:  Questions...

   1) How do I insert manual tax lines in invoice copy?  What fields are
      required?

   RESP:  Harsh says that I do not insert anything into the ZX_TAX_LINES
   table.  Rather, I populate the SOURCE columns on the copied invoice
   lines (in ZX table) with the line info from the original invoice
   line.

*/
PROCEDURE insert_line(
                 p_orig_line_id IN  NUMBER,
                 p_new_line_id  IN  NUMBER) IS

    l_so_org_id      VARCHAR2(20);
    l_lines_updated  NUMBER;
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_recurr_util.insert_line()+');
   END IF;

   l_so_org_id := oe_profile.value('SO_ORGANIZATION_ID',
                       arp_global.sysparam.org_id);

   /* 4666566 - added support for ship_to and product_org_id to
       line-level insert.  Invoice copy automatically copies ship to
       to line-level to make it more like autoinvoice.  */

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
     line_amt_includes_tax_flag,
     line_amt,
     trx_line_quantity,
     unit_price,
     exempt_certificate_number,
     exempt_reason_code,
     exemption_control_flag,
     product_id, -- inventory item or memo line
     product_org_id,  -- warehouse_id
     uom_code,
     fob_point,
     ship_from_party_id,     -- warehouse_id
     ship_from_location_id,  -- warehouse location
     ship_to_party_id,
     ship_to_party_site_id,
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
     poa_party_id,
     poa_location_id,
     poo_party_id,
     poo_location_id,
     cash_discount,
     bill_from_location_id,
     account_ccid,
     trx_line_description,
     product_category -- 7661349
   )
   SELECT
     222,
     ZTH.entity_code,
     ZTH.event_class_code,
     NULL,
     NULL,
     TL.customer_trx_id,
     'LINE',
     TL.customer_trx_line_id,
     'INVOICE',
     'COPY_AND_CREATE',
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
     NVL(TL.inventory_item_id, TL.memo_line_id),        -- product_id
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
 --  null,  account_ccid (set in subsequent update)
     222,
     ZTH.entity_code,
     ZTH.event_class_code,
     TL_ORIG.customer_trx_id,
     TL_ORIG.customer_trx_line_id,
     'LINE',
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
     STPS.cust_acct_site_id,       -- ship_third_pty_site_id
     STCSU.site_use_id,
     ZTH.internal_organization_id, -- poa_party_id
     ZTH.internal_org_location_id, -- poa_location_id
     ZTH.internal_organization_id, -- poo_party_id (default val)
     ZTH.internal_org_location_id, -- poo_location_id (default val)
     TL.extended_amount * arp_etax_util.get_discount_rate(T.customer_trx_id),
     ZTH.internal_org_location_id, -- bill_from_location_id
     ( SELECT max(code_combination_id)
       FROM   ra_cust_trx_line_gl_dist gld
       WHERE  gld.customer_trx_line_id = TL.customer_trx_line_id
       AND    gld.account_class = 'REV') account_ccid,
     TL.description,
     ML.tax_product_category -- 7661349
   FROM
     RA_CUSTOMER_TRX_LINES    TL,
     RA_CUSTOMER_TRX_LINES    TL_ORIG,
     RA_CUSTOMER_TRX          T,
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
         TL.customer_trx_line_id = p_new_line_id
   AND   TL.line_type = 'LINE'
   AND   TL.customer_trx_id = T.customer_trx_id
   AND   TL.customer_trx_id = ZTH.trx_id
   AND   TL_ORIG.customer_trx_line_id = p_orig_line_id
   AND   TL.ship_to_customer_id =
         STCA.cust_account_id (+)
   AND   TL.ship_to_site_use_id =
         STCSU.site_use_id (+)
   AND   STCSU.cust_acct_site_id = STPS.cust_acct_site_id (+)
   AND   STPS.party_site_id = STPSU.party_site_id (+)
   AND   ZTH.rndg_bill_to_party_site_id = BTPSU.party_site_id
   AND   REC.customer_trx_id (+) = T.customer_trx_id
   AND   REC.account_class (+) = 'REC'
   AND   REC.latest_rec_flag (+) = 'Y'
   AND   TL.warehouse_id = HR.organization_id (+)
   AND   TL.memo_line_id = ML.memo_line_id (+)
   AND   TL.org_id = ML.org_id (+);

   g_lines_inserted := SQL%ROWCOUNT;

   IF PG_DEBUG in ('Y','C') THEN
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
      debug('arp_etax_recurr_util.insert_line()-');
   END IF;


EXCEPTION
   WHEN OTHERS
   THEN
     debug('EXCEPTION: ARP_ETAX_RECURR_UTIL.insert_line()- ' ||
            SQLERRM);
     RAISE;
END insert_line;

/* Inserts manual tax lines into IMPORT_GT table when
   then are present in ra_customer_trx_lines (on original invoice)
   with autotax flag set to 'N'

DEV NOTE:

  1) What happens to legacy tax lines?  By that I mean tax lines that
     are autotax=N and predate etax.  Are they converted?  Can I assume
     that the fab-five columns in zx_lines will be populated?

     sent email 04/06/05 to harsh/isaac
     RESP: Harsh says legacy lines are converted too.  Yes, those columns
     will be populated.

     To extend that, I need to populate the SOURCE columns on the copied
     lines (new ones) with info from the original invoice lines.  I do not
     need to populate teh tax lines using this routine.
*/

PROCEDURE insert_tax_lines(
                p_original_line_id IN NUMBER,
                p_new_customer_trx_id IN NUMBER,
                p_new_line_id         IN NUMBER,
                p_request_id IN NUMBER) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_recurr_util.insert_tax_lines()+');
   END IF;

   /* NOTE:  We are passing the line_id of the original tax line
      into this table.  That means that we can get that same line
      ID back out when inserting the shadow tax lines into
      RA_CUSTOMER_TRX_LINES.  At this point, I'm not sure
      we need this, but I thought it was worth noting in case
      we need to copy DFF values, etc. */

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
     tax_jurisdiction_code,
     tax_amt,
     tax_amt_included_flag,
     tax_exception_id,
     tax_exemption_id,
     exempt_reason_code,
     exempt_certificate_number,
     tax_line_allocation_flag,
     summary_tax_line_number -- 4698302
   )
   SELECT
     orig_line.org_id,
     222,
     'TRANSACTIONS',
     'INVOICE',
     'RA_CUSTOMER_TRX',   -- interface_entity
     p_original_line_id,  -- interface_line_id
     p_new_customer_trx_id,
     p_new_line_id,
     orig_etax.tax_regime_code,
     orig_etax.tax,
     orig_etax.tax_status_code,
     orig_etax.tax_rate_code,
     orig_etax.tax_rate,
     orig_etax.tax_jurisdiction_code,
     orig_tax.extended_amount,
     orig_tax.amount_includes_tax_flag,
     orig_etax.tax_exception_id,
     orig_etax.tax_exemption_id,
     orig_etax.exempt_reason_code,
     orig_etax.exempt_certificate_number,
     'N',  -- no rows in LINK table
     0     -- 4698302
   FROM
     RA_CUSTOMER_TRX_LINES orig_line,
     RA_CUSTOMER_TRX_LINES orig_tax,
     ZX_LINES              orig_etax
   WHERE
         orig_line.customer_trx_line_id = p_original_line_id
     AND orig_line.customer_trx_line_id = orig_tax.link_to_cust_trx_line_id
     AND orig_tax.line_type = 'TAX'
     AND NVL(orig_tax.autotax, 'N') = 'N'
     AND orig_tax.tax_line_id = orig_etax.tax_line_id (+);

   g_tax_lines_inserted := SQL%ROWCOUNT;

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_recurr_util.insert_tax_lines()-');
   END IF;

EXCEPTION
   WHEN OTHERS
   THEN
     debug('EXCEPTION: ARP_ETAX_RECURR_UTIL.insert_tax_lines()-');
     RAISE;

END insert_tax_lines;


/* Procedure to retrieve TAX lines from ZX and populate
   RA_CUSTOMER_TRX_LINES accordingly */
PROCEDURE build_ar_tax_lines(
                 p_request_id IN  NUMBER) IS

  l_rows NUMBER;

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_recurr_util.build_ar_tax_lines()+');
   END IF;

   /* Dev Notes:

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
      TAX_LINE_ID,            -- ID in ZX_ table
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
      p_request_id,
      zxt.tax_amt,
      zxt.tax_rate,
      DECODE(NVL(zxt.manually_entered_flag, 'N'), 'Y', NULL, 'Y'),
      zxt.tax_amt_included_flag,
      zxt.taxable_amt,
      tax_rate_id,
      zxt.tax_line_id,
      plin.org_id
   FROM   ZX_LINES zxt,
          RA_CUSTOMER_TRX_LINES  plin
   WHERE  plin.request_id = p_request_id
     AND  zxt.application_id = 222
     AND  zxt.entity_code = 'TRANSACTIONS'
     AND  zxt.event_class_code in ('INVOICE','DEBIT_MEMO')
     AND  zxt.trx_id = plin.customer_trx_id
     AND  zxt.trx_level_type = 'LINE'
     AND  zxt.trx_line_id = plin.customer_trx_line_id;

   l_rows := SQL%ROWCOUNT;

   IF l_rows > 0
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
      debug('  Number of tax lines retrieved = ' || l_rows);
      debug('arp_etax_recurr_util.build_ar_tax_lines()-');
   END IF;
END build_ar_tax_lines;

/* Procedure to extract error/validation messages from ZX
   and insert them into RA_INTERFACE_ERRORS */
PROCEDURE retrieve_tax_validation_errors(p_error_count IN OUT NOCOPY NUMBER) IS

   l_errors      NUMBER := 0;

   CURSOR zx_val_err IS
      SELECT trx_id, trx_line_id, message_text
      FROM   zx_validation_errors_gt
      UNION ALL
      SELECT trx_id, trx_line_id, message_text
      FROM   ZX_ERRORS_GT;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('arp_etax_recurr_util.retrieve_tax_validation_errors()+');
   END IF;

   /* Dev Notes:

      Just extracting messages directly to log file.  In ARXREC,
      there is no equivalent to ra_interface_errors.

   */

   FOR val_err IN zx_val_err LOOP

      l_errors := l_errors + 1;

      fnd_file.put_line(FND_FILE.LOG,
        'EBTax calculation failure:');
      fnd_file.put_line(FND_FILE.LOG,
        '   customer_trx_id      = ' || val_err.trx_id);
      fnd_file.put_line(FND_FILE.LOG,
        '   customer_trx_line_id = ' || val_err.trx_line_id);
      fnd_file.put_line(FND_FILE.LOG, val_err.message_text);

   END LOOP;

   p_error_count := l_errors;

   IF PG_DEBUG in ('Y', 'C') THEN
      debug('Validation errors:  ' || l_errors);
      debug('arp_etax_recurr_util.retrieve_tax_validation_errors()-');
   END IF;

END retrieve_tax_validation_errors;

/* Internal procedure - calculate_tax_for_copy */
/* wrapper for call to zx_api_pub.calculate_tax */

PROCEDURE calculate_tax_for_copy IS
  l_return_status VARCHAR2(50);
  l_message_count NUMBER;
  l_message_data  VARCHAR2(2000);
  l_msg           VARCHAR2(2000);
BEGIN
   ZX_API_PUB.calculate_tax(
     p_api_version      => 1.0,
     p_init_msg_list    => FND_API.G_FALSE,
     p_commit           => FND_API.G_FALSE,
     p_validation_level => FND_API.G_VALID_LEVEL_FULL,
     x_return_status    => l_return_status,
     x_msg_count        => l_message_count,
     x_msg_data         => l_message_data
   );

   IF l_return_status = FND_API.G_RET_STS_SUCCESS
   THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('calculate_tax returns successfully');
      END IF;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR
   THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('calculate_tax returns with validation errors');
      END IF;
   ELSE /* fatal error */
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('calculate_tax returns failure');
      END IF;

      /* Retrieve and log errors */
      IF l_message_count = 1
      THEN
         debug(l_message_data);
      ELSIF l_message_count > 1
      THEN
         LOOP
            l_msg := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,
                                               FND_API.G_FALSE);
            IF l_msg IS NULL
            THEN
               EXIT;
            ELSE
               debug(l_msg);
            END IF;
         END LOOP;
      END IF;
   END IF;

END calculate_tax_for_copy;

/* External public call designed for invoice copy.  This will
   calculate the tax,
   and insert resulting tax lines back into AR */
PROCEDURE calculate_tax(p_request_id  IN NUMBER,
                        p_error_count IN OUT NOCOPY NUMBER,
                        p_return_status  OUT NOCOPY NUMBER) IS
   l_return_status NUMBER := 0;
BEGIN
   IF PG_DEBUG in ('Y', 'C')
   THEN
      debug('arp_etax_recurr_util.calculate_tax()+');
      debug('request_id = ' || p_request_id);
   END IF;

   /* Call validate_and_default_tax_attr */
   arp_etax_util.validate_tax_int(p_return_status => l_return_status,p_called_from_AI => 'Y');
         p_return_status := l_return_status;

   IF l_return_status = 0
   THEN

      /* Call import_document_with_tax */
      calculate_tax_for_copy;

      /* retrieve validation errors and display them in log */
      retrieve_tax_validation_errors(p_error_count);

      /* Pull resulting tax lines and populate RA_CUSTOMER_TRX_LINES */
      build_ar_tax_lines(p_request_id);
   END IF;

   /* 4904679 - removed detect_missing_tax_lines */

   IF PG_DEBUG in ('Y', 'C')
   THEN
      debug('arp_etax_recurr_util.calculate_tax()-');
   END IF;
END calculate_tax;



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
   NULL;

EXCEPTION
  WHEN OTHERS THEN
     debug('EXCEPTION: ARP_ETAX_RECURR_UTIL.INITIALIZE()');
     RAISE;

END ARP_ETAX_RECURR_UTIL;

/
