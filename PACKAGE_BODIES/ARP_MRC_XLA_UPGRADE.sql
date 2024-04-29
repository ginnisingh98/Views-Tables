--------------------------------------------------------
--  DDL for Package Body ARP_MRC_XLA_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_MRC_XLA_UPGRADE" AS
/* $Header: ARMXLAUB.pls 120.14 2006/12/16 00:27:15 jvarkey noship $ */

PROCEDURE UPGRADE_MC_GAIN_LOSS(
                       l_start_rowid  IN ROWID,
		       l_end_rowid    IN ROWID,
                       l_table_name   IN VARCHAR2,
                       l_batch_id     IN NUMBER);

/*========================================================================
 | PUBLIC PROCEDURE UPGRADE_MC_TRANSACTIONS
 |
 | DESCRIPTION
 |     Will create the records in XLA_AE_HEADERS, XLA_AE_LINES and
 |     XLA_DISTRIBUTION_LINKS for records related to transactions.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS
 |     UPGRADE_MC_GAIN_LOSS
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 03-JUL-2005           JVARKEY           Created
 | 30-AUG-2005		 JVARKEY           Modified the flow
 | 20-SEP-2005           JVARKEY           Detached the insert into
 |                                         xla_ae_headers into seperate
 |                                         insert statement
 | 27-APR-2006           MRAYMOND          5167049 - Populate accounting_date
 |                                         and ledger_id in ae_lines
*=======================================================================*/

PROCEDURE UPGRADE_MC_TRANSACTIONS(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2,
                       l_entity_type  IN VARCHAR2 DEFAULT NULL) IS

l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

BEGIN

  /* ------ Initialize the rowid ranges ------ */
  ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_script_name,
           l_worker_id,
           l_num_workers,
           l_batch_size, 0);

  /* ------ Get rowid ranges ------ */
  ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           l_batch_size,
           TRUE);

  WHILE ( l_any_rows_to_process = TRUE )
  LOOP

   l_rows_processed := 0;

  IF NVL(l_entity_type,'H') = 'H' THEN
-----------------------
-- Inserting headers --
-----------------------

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO XLA_AE_HEADERS
   (upg_batch_id,
    upg_source_application_id,
    application_id,
    amb_context_code,
    entity_id,
    event_id,
    event_type_code,
    ae_header_id,
    ledger_id,
    accounting_date,
    period_name,
    reference_date,
    balance_type_code,
    je_category_name,
    gl_transfer_status_code,
    gl_transfer_date,
    accounting_entry_status_code,
    accounting_entry_type_code,
    description,
    budget_version_id,
    funds_status_code,
--    encumbrance_type_id,
    completed_date,
    doc_sequence_id,
    doc_sequence_value,
    doc_category_code,
    packet_id,
    group_id,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    program_update_date,
    program_id,
    program_application_id,
    request_id,
    close_acct_seq_assign_id,
    close_acct_seq_version_id,
    close_acct_seq_value,
    completion_acct_seq_assign_id,
    completion_acct_seq_version_id,
    completion_acct_seq_value,
    upg_valid_flag
    --upg_worker_id
   )
   VALUES
   (batch_id,
    222,
    222,
   'DEFAULT',               --amb context code
   entity_id,
   event_id,
   override_event,
   xla_ae_headers_s.nextval,
   sob_id,
   gl_date,
   period_name,
   '',                      --reference date global acct eng
   'A',                     --balance type Actual
   category,                --category
   'Y',                     --gl transfer status
   gl_posted_date,          --gl transfer date
   'F',                     --acct entry status code final
   'STANDARD',              --acct entry type code
   '',                      --description TBD
   '',                      --budget version id
   '',                      --funds status code
--   '',                      --encumbrance type id
   '',                      --completed date
  doc_seq_id,
  doc_seq_value,
  cat_code,
  '',                       --packet id
  '',                       --group id
  sysdate,                  --row who creation date
  -2005,
  sysdate,
  -2005,
  -2005,
  sysdate,
  -2005,                    --program id
  222,
  '',                       --request id
  '',                       --AX columns start
  '',
  '',
  '',
  '',
  '',
  ''                        --upg valid flag
  --''
  )

   select
       l_batch_id                   AS batch_id,
       event_id                     AS event_id,
       entity_id                    AS entity_id,
       override_event               AS override_event,
       sob_id                       AS sob_id,
       gl_date                      AS gl_date,
       period_name                  AS period_name,
       category                     AS category,
       gl_posted_date               AS gl_posted_date,
       doc_seq_id                   AS doc_seq_id,
       doc_seq_value                AS doc_seq_value,
       cat_code                     AS cat_code
FROM
(select /*+ ordered rowid(ct) use_nl(trx,gld,ctlgd,dl,hdr) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(HDR,XLA_AE_HEADERS_U1) */
         hdr.ae_header_id                                      ae_header_id,
	 hdr.entity_id                                         entity_id,
         hdr.event_id                                          event_id,
         hdr.event_type_code                                   override_event,
         hdr.accounting_date                                   gl_date,
         hdr.period_name                                       period_name,
         hdr.je_category_name                                  category,
         hdr.gl_transfer_date                                  gl_posted_date,
         hdr.doc_sequence_id                                   doc_seq_id,
         hdr.doc_sequence_value                                doc_seq_value,
         hdr.doc_category_code                                 cat_code,
         ctlgd.set_of_books_id                                 sob_id
   --
   from ra_mc_customer_trx ct,
        ra_customer_trx_all trx,
	ra_cust_trx_line_gl_dist_all gld,
	xla_upgrade_dates gps,
        ra_mc_trx_line_gl_dist ctlgd,
	xla_distribution_links dl,
        xla_ae_headers hdr
   --
   where ct.rowid >= l_start_rowid
   and ct.rowid <= l_end_rowid
   --
   and trx.customer_trx_id = ct.customer_trx_id
   and NVL(trx.ax_accounted_flag,'N') = 'N'
   --
   and gld.customer_trx_id = trx.customer_trx_id
   and gld.account_set_flag = 'N'
   --
   and trunc(gld.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = ct.set_of_books_id
   --
   and ctlgd.cust_trx_line_gl_dist_id = gld.cust_trx_line_gl_dist_id
   and ctlgd.customer_trx_id = ct.customer_trx_id
   and ctlgd.posting_control_id <> -3
   and ctlgd.set_of_books_id = ct.set_of_books_id
   --
   and dl.source_distribution_id_num_1 = ctlgd.cust_trx_line_gl_dist_id
   and dl.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
   and dl.application_id = 222
   and dl.upg_batch_id = l_batch_id
   --
   and hdr.ae_header_id = dl.ae_header_id
   and hdr.application_id = 222
   and hdr.upg_batch_id = l_batch_id
   and hdr.ledger_id = trx.set_of_books_id
   --
   group by
         hdr.ae_header_id,
	 hdr.entity_id,
         hdr.event_id,
         hdr.event_type_code,
         hdr.accounting_date,
         hdr.period_name,
         hdr.je_category_name,
         hdr.gl_transfer_date,
         hdr.doc_sequence_id,
         hdr.doc_sequence_value,
         hdr.doc_category_code,
         ctlgd.set_of_books_id

   UNION   /* CM applications */
   select /*+ ordered rowid(ct) use_nl(trx,ra,app,dist,dl,hdr) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(HDR,XLA_AE_HEADERS_U1) */
        hdr.ae_header_id                                      ae_header_id,
	hdr.entity_id                                         entity_id,
        hdr.event_id                                          event_id,
        hdr.event_type_code                                   override_event,
        hdr.accounting_date                                   gl_date,
        hdr.period_name                                       period_name,
        hdr.je_category_name                                  category,
        hdr.gl_transfer_date                                  gl_posted_date,
        hdr.doc_sequence_id                                   doc_seq_id,
        hdr.doc_sequence_value                                doc_seq_value,
        hdr.doc_category_code                                 cat_code,
        dist.set_of_books_id                                   sob_id
   --
   from ra_mc_customer_trx ct,
        ra_customer_trx_all trx,
	ar_receivable_applications_all ra,
	xla_upgrade_dates gps,
	ar_mc_receivable_apps app,
	ar_mc_distributions_all dist,
	xla_distribution_links dl,
        xla_ae_headers hdr

   --
   where ct.rowid >= l_start_rowid
   and ct.rowid <= l_end_rowid
   --
   and trx.customer_trx_id = ct.customer_trx_id
   and NVL(trx.ax_accounted_flag,'N') = 'N'
   --
   and ra.customer_trx_id = trx.customer_trx_id
   --
   and trunc(ra.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = ct.set_of_books_id
   --
   and app.receivable_application_id = ra.receivable_application_id
   and app.posting_control_id <> -3
   and app.set_of_books_id = ct.set_of_books_id
   --
   and dist.source_id = app.receivable_application_id
   and dist.set_of_books_id = app.set_of_books_id
   and dist.source_table = 'RA'
   --
   and dl.source_distribution_id_num_1 = dist.line_id
   and dl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
   and dl.application_id = 222
   and dl.upg_batch_id = l_batch_id
   --
   and hdr.ae_header_id = dl.ae_header_id
   and hdr.application_id = 222
   and hdr.upg_batch_id = l_batch_id
   and hdr.ledger_id = trx.set_of_books_id
   --
   group by
         hdr.ae_header_id,
	 hdr.entity_id,
         hdr.event_id,
         hdr.event_type_code,
         hdr.accounting_date,
         hdr.period_name,
         hdr.je_category_name,
         hdr.gl_transfer_date,
         hdr.doc_sequence_id,
         hdr.doc_sequence_value,
         hdr.doc_category_code,
         dist.set_of_books_id

   UNION   /* Bills Receivable */
   select /*+ ordered rowid(ct) use_nl(trx,th,trh,dist,dl,hdr) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(HDR,XLA_AE_HEADERS_U1) */
           hdr.ae_header_id                                      ae_header_id,
	   hdr.entity_id                                         entity_id,
           hdr.event_id                                          event_id,
           hdr.event_type_code                                   override_event,
           hdr.accounting_date                                   gl_date,
           hdr.period_name                                       period_name,
           hdr.je_category_name                                  category,
           hdr.gl_transfer_date                                  gl_posted_date,
           hdr.doc_sequence_id                                   doc_seq_id,
           hdr.doc_sequence_value                                doc_seq_value,
           hdr.doc_category_code                                 cat_code,
           dist.set_of_books_id                                   sob_id
   --
   from ra_mc_customer_trx ct,
        ra_customer_trx_all trx,
	ar_transaction_history_all th,
	xla_upgrade_dates gps,
	ar_mc_transaction_history trh,
	ar_mc_distributions_all dist,
	xla_distribution_links dl,
        xla_ae_headers hdr
   --
   where ct.rowid >= l_start_rowid
   and ct.rowid <= l_end_rowid
   --
   and trx.customer_trx_id = ct.customer_trx_id
   and NVL(trx.ax_accounted_flag,'N') = 'N'
   --
   and th.customer_trx_id = trx.customer_trx_id
   and th.postable_flag = 'Y'
   --
   and trunc(th.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = ct.set_of_books_id
   --
   and trh.transaction_history_id = th.transaction_history_id
   and trh.posting_control_id <> -3
   and trh.set_of_books_id = ct.set_of_books_id
   --
   and dist.source_id = trh.transaction_history_id
   and dist.source_table = 'TH'
   and dist.set_of_books_id = trh.set_of_books_id
   --
   and dl.source_distribution_id_num_1 = dist.line_id
   and dl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
   and dl.application_id = 222
   and dl.upg_batch_id = l_batch_id
   --
   and hdr.ae_header_id = dl.ae_header_id
   and hdr.application_id = 222
   and hdr.upg_batch_id = l_batch_id
   and hdr.ledger_id = trx.set_of_books_id
   --
   group by
         hdr.ae_header_id,
	 hdr.entity_id,
         hdr.event_id,
         hdr.event_type_code,
         hdr.accounting_date,
         hdr.period_name,
         hdr.je_category_name,
         hdr.gl_transfer_date,
         hdr.doc_sequence_id,
         hdr.doc_sequence_value,
         hdr.doc_category_code,
         dist.set_of_books_id
  );

  l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  END IF; --NVL(l_entity_type,'H') = 'H'

  IF NVL(l_entity_type,'L') = 'L' THEN
--------------------------------------------
-- Inserting lines and distribution links --
--------------------------------------------

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO XLA_AE_LINES
      (upg_batch_id,
       ae_header_id,
       ae_line_num,
       application_id,
       code_combination_id,
       gl_transfer_mode_code,
       accounted_dr,
       accounted_cr,
       currency_code,
       currency_conversion_date,
       currency_conversion_rate,
       currency_conversion_type,
       entered_dr,
       entered_cr,
       description,
       accounting_class_code,
       gl_sl_link_id,
       gl_sl_link_table,
       party_type_code,
       party_id,
       party_site_id,
       statistical_amount,
       ussgl_transaction_code,
       jgzz_recon_ref,
       control_balance_flag,
       analytical_balance_flag,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_update_date,
       program_id,
       program_application_id,
       request_id,
       gain_or_loss_flag,
       accounting_date,
       ledger_id
      )
  VALUES
   (   batch_id,
       header_id,
       line_num,
       222,
       code_combination_id,
       'D',                             --gl transfer mode Summary or detail
       acctd_amount_dr,
       acctd_amount_cr,
       currency_code,
       exchange_date,
       exchange_rate,
       exchange_type,
       amount_dr,
       amount_cr,
       '',                             --description TBD
       nvl(account_class,'XXXX'),      --accounting class code
       xla_gl_sl_link_id_s.nextval,    --gl sl link id
       'XLAJEL',                       --gl sl link table
       decode(third_party_id, NULL, NULL, 'C'), --party type code
       third_party_id,                 --party id
       third_party_sub_id,             --third party site
       '',                             --statistical amount
       '',                             --ussgl trx code
       '',                             --jgzz recon ref
       '',                             --control balance flag
       '',                             --analytical balance
       sysdate,                        --row who columns
       -2005,
       sysdate,
       -2005,
       -2005,
       sysdate,
       -2005,                           --program id
       222,
       '',                              --request id
       gain_loss_flag,
       accounting_date,
       ledger_id)
   WHEN 1 = 1 THEN
   INTO XLA_DISTRIBUTION_LINKS
      (APPLICATION_ID,
       EVENT_ID,
       AE_HEADER_ID,
       AE_LINE_NUM,
       ACCOUNTING_LINE_CODE,
       ACCOUNTING_LINE_TYPE_CODE,
       REF_AE_HEADER_ID,
--       REF_AE_LINE_NUM,
       SOURCE_DISTRIBUTION_TYPE,
       SOURCE_DISTRIBUTION_ID_CHAR_1,
       SOURCE_DISTRIBUTION_ID_CHAR_2,
       SOURCE_DISTRIBUTION_ID_CHAR_3,
       SOURCE_DISTRIBUTION_ID_CHAR_4,
       SOURCE_DISTRIBUTION_ID_CHAR_5,
       SOURCE_DISTRIBUTION_ID_NUM_1,
       SOURCE_DISTRIBUTION_ID_NUM_2,
       SOURCE_DISTRIBUTION_ID_NUM_3,
       SOURCE_DISTRIBUTION_ID_NUM_4,
       SOURCE_DISTRIBUTION_ID_NUM_5,
       UNROUNDED_ENTERED_DR,
       UNROUNDED_ENTERED_CR,
       UNROUNDED_ACCOUNTED_DR,
       UNROUNDED_ACCOUNTED_CR,
       MERGE_DUPLICATE_CODE,
       TAX_LINE_REF_ID,
       TAX_SUMMARY_LINE_REF_ID,
       TAX_REC_NREC_DIST_REF_ID,
       STATISTICAL_AMOUNT,
       TEMP_LINE_NUM,
       EVENT_TYPE_CODE,
       EVENT_CLASS_CODE,
       REF_EVENT_ID,
       UPG_BATCH_ID)
    VALUES
      (222,
       event_id,
       header_id,
       line_num,
       account_class,
       'C',  --accounting line code customer
       ae_header_id, --reference header id
--       '', --reference line number
       source_table,
       '', --src dist id char
       '',
       '',
       '',
       '',
       line_id, --src dist id num
       '',
       '',
       '',
       '',
       amount_dr,
       amount_cr,
       acctd_amount_dr,
       acctd_amount_cr,
       'N',         --merge dup code
       tax_line_id, --tax_line_ref_id
       '',         --tax_summary_line_ref_id
       '',         --tax_rec_nrec_dist_ref_id
       '',         --statistical amount
       line_num,   --temp_line_num
       event_type_code, --event_type_code
       event_class_code, --event class code
       '',         --ref_event_id,
       batch_id)   --upgrade batch id
   select
       l_batch_id                   AS batch_id,
       header_id                    AS header_id,
       ae_header_id                 AS ae_header_id,
       line_id                      AS line_id,
       event_id                     AS event_id,
       account_class                AS account_class,
       source_table                 AS source_table,
       code_combination_id          AS code_combination_id,
       amount_dr                    AS amount_dr,
       amount_cr                    AS amount_cr,
       acctd_amount_dr              AS acctd_amount_dr,
       acctd_amount_cr              AS acctd_amount_cr,
       nvl(currency_code,'XXXX')    AS currency_code,
       third_party_id               AS third_party_id,
       third_party_sub_id           AS third_party_sub_id,
       exchange_date                AS exchange_date,
       exchange_rate                AS exchange_rate,
       exchange_type                AS exchange_type,
       tax_line_id                  AS tax_line_id,
       gain_loss_flag		    AS gain_loss_flag,
       event_type_code              AS event_type_code,
       event_class_code             AS event_class_code,
       accounting_date              AS accounting_date,
       ledger_id                    AS ledger_id,
       sob_id                       AS sob_id,
       RANK() OVER (PARTITION BY event_id, ae_header_id, sob_id
                    ORDER BY line_id, ln_order) AS line_num
FROM
(select /*+ ordered rowid(ct) use_nl(trx,gld,ctlgd,dl,hdr,hdr1) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(HDR,XLA_AE_HEADERS_U1) index(HDR1,XLA_AE_HEADERS_N2) */
         hdr.ae_header_id                                      ae_header_id,
	 hdr1.ae_header_id                                     header_id,
         hdr.event_id                                          event_id,
         ctlgd.set_of_books_id                                 sob_id,
         ctlgd.account_class                                   account_class,
         'RA_CUST_TRX_LINE_GL_DIST_ALL'                        source_table,
         gld.code_combination_id                               code_combination_id,
         decode(ctlgd.account_class,
                'REC', decode(sign(ctlgd.amount),
                              1, abs(ctlgd.amount),
                              0, abs(ctlgd.amount),
                              ''),
                decode(sign(ctlgd.amount),
                       -1, abs(ctlgd.amount),
                       ''))                                    amount_dr,
         decode(ctlgd.account_class,
                'REC', decode(sign(ctlgd.amount),
                              -1, abs(ctlgd.amount),
                              ''),
                decode(sign(ctlgd.amount),
                       1, abs(ctlgd.amount),
                       0, abs(ctlgd.amount),
                       ''))                                    amount_cr,
         decode(ctlgd.account_class,
                'REC', decode(sign(ctlgd.acctd_amount),
                              1, abs(ctlgd.acctd_amount),
                              0, abs(ctlgd.acctd_amount),
                              ''),
                decode(sign(ctlgd.acctd_amount),
                       -1, abs(ctlgd.acctd_amount),
                       ''))                                    acctd_amount_dr,
         decode(ctlgd.account_class,
                'REC', decode(sign(ctlgd.acctd_amount),
                              -1, abs(ctlgd.acctd_amount),
                              ''),
                decode(sign(ctlgd.acctd_amount),
                       1, abs(ctlgd.acctd_amount),
                       0, abs(ctlgd.acctd_amount),
                       ''))                                    acctd_amount_cr,
         trx.invoice_currency_code                              currency_code,
         trx.bill_to_customer_id                                third_party_id,
         trx.bill_to_site_use_id                                third_party_sub_id,
         ct.exchange_date                                      exchange_date,
         ct.exchange_rate                                      exchange_rate,
         ct.exchange_rate_type                                 exchange_type,
         ctlgd.cust_trx_line_gl_dist_id                        line_id,
         dl.tax_line_ref_id                                    tax_line_id,
	 'N'						       gain_loss_flag,
	 dl.event_type_code                                    event_type_code,
         dl.event_class_code                                   event_class_code,
         hdr.accounting_date                                   accounting_date,
         hdr1.ledger_id                                        ledger_id,
         1                                                     ln_order
   --
   from ra_mc_customer_trx ct,
        ra_customer_trx_all trx,
	ra_cust_trx_line_gl_dist_all gld,
	xla_upgrade_dates gps,
        ra_mc_trx_line_gl_dist ctlgd,
	xla_distribution_links dl,
        xla_ae_headers hdr,
	xla_ae_headers hdr1
   --
   where ct.rowid >= l_start_rowid
   and ct.rowid <= l_end_rowid
   --
   and trx.customer_trx_id = ct.customer_trx_id
   and NVL(trx.ax_accounted_flag,'N') = 'N'
   --
   and gld.customer_trx_id = ct.customer_trx_id
   and gld.account_set_flag = 'N'
   --
   and trunc(gld.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = ct.set_of_books_id
   --
   and ctlgd.cust_trx_line_gl_dist_id = gld.cust_trx_line_gl_dist_id
   and ctlgd.customer_trx_id = trx.customer_trx_id
   and ctlgd.posting_control_id <> -3
   and ctlgd.set_of_books_id = ct.set_of_books_id
   --
   and dl.source_distribution_id_num_1 = ctlgd.cust_trx_line_gl_dist_id
   and dl.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
   and dl.application_id = 222
   and dl.upg_batch_id = l_batch_id
   --
   and hdr.ae_header_id = dl.ae_header_id
   and hdr.application_id = 222
   and hdr.upg_batch_id = l_batch_id
   and hdr.ledger_id = trx.set_of_books_id
   --
   and hdr1.application_id = 222
   and hdr1.upg_batch_id = l_batch_id
   and hdr1.ae_header_id <> hdr.ae_header_id
   and hdr1.ledger_id = ctlgd.set_of_books_id
   and hdr1.entity_id = hdr.entity_id
   and hdr1.event_id = hdr.event_id
   and hdr1.event_type_code = hdr.event_type_code
   and hdr1.accounting_date = hdr.accounting_date
   and hdr1.period_name = hdr.period_name
   and hdr1.je_category_name = hdr.je_category_name
   and hdr1.gl_transfer_date = hdr.gl_transfer_date
--   and hdr1.doc_sequence_id =  hdr.doc_sequence_id
--   and hdr1.doc_sequence_value =  hdr.doc_sequence_value
--   and hdr1.doc_category_code =  hdr.doc_category_code


   UNION   /* CM applications */
   select /*+ ordered rowid(ct) use_nl(trx,ra,app,dist,dl,hdr,hdr1) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(HDR,XLA_AE_HEADERS_U1) index(HDR1,XLA_AE_HEADERS_N2) */
        hdr.ae_header_id                                      ae_header_id,
        hdr1.ae_header_id                                     header_id,
        hdr.event_id                                          event_id,
        dist.set_of_books_id                                   sob_id,
        dist.source_type                                       account_class,
        'AR_DISTRIBUTIONS_ALL'                                source_table,
        dist.code_combination_id                               code_combination_id,
        dist.amount_dr                                         amount_dr,
        dist.amount_cr                                         amount_cr,
        dist.acctd_amount_dr                                   acctd_amount_dr,
        dist.acctd_amount_cr                                   acctd_amount_cr,
        dist.currency_code                                     currency_code,
        dist.third_party_id                                    third_party_id,
        dist.third_party_sub_id                                third_party_sub_id,
        dist.currency_conversion_date                          exchange_date,
        dist.currency_conversion_rate                          exchange_rate,
        dist.currency_conversion_type                          exchange_type,
        dist.line_id                                           line_id,
        null                                                  tax_line_id,
	decode(dist.source_type,
               'EXCH_GAIN','Y',
               'EXCH_LOSS','Y',
	       'CURR_ROUND','Y',
               'N')                                           gain_loss_flag,
	dl.event_type_code                                    event_type_code,
        dl.event_class_code                                   event_class_code,
        hdr.accounting_date                                   accounting_date,
        hdr1.ledger_id                                        ledger_id,
        2                                                     ln_order
   --
   from ra_mc_customer_trx ct,
        ra_customer_trx_all trx,
	ar_receivable_applications_all ra,
	xla_upgrade_dates gps,
	ar_mc_receivable_apps app,
	ar_mc_distributions_all dist,
	xla_distribution_links dl,
        xla_ae_headers hdr,
	xla_ae_headers hdr1

   --
   where ct.rowid >= l_start_rowid
   and ct.rowid <= l_end_rowid
   --
   and trx.customer_trx_id = ct.customer_trx_id
   and NVL(trx.ax_accounted_flag,'N') = 'N'
   --
   and ra.customer_trx_id = ct.customer_trx_id
   --
   and trunc(ra.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = ct.set_of_books_id
   --
   and app.receivable_application_id = ra.receivable_application_id
   and app.posting_control_id <> -3
   and app.set_of_books_id = ct.set_of_books_id
   --
   and dist.source_id = app.receivable_application_id
   and dist.set_of_books_id = app.set_of_books_id
   and dist.source_table = 'RA'
   --
   and dl.source_distribution_id_num_1 = dist.line_id
   and dl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
   and dl.application_id = 222
   and dl.upg_batch_id = l_batch_id
   --
   and hdr.ae_header_id = dl.ae_header_id
   and hdr.application_id = 222
   and hdr.upg_batch_id = l_batch_id
   and hdr.ledger_id = trx.set_of_books_id
   --
   and hdr1.application_id = 222
   and hdr1.upg_batch_id = l_batch_id
   and hdr1.ae_header_id <> hdr.ae_header_id
   and hdr1.ledger_id = dist.set_of_books_id
   and hdr1.entity_id = hdr.entity_id
   and hdr1.event_id = hdr.event_id
   and hdr1.event_type_code = hdr.event_type_code
   and hdr1.accounting_date = hdr.accounting_date
   and hdr1.period_name = hdr.period_name
   and hdr1.je_category_name = hdr.je_category_name
   and hdr1.gl_transfer_date = hdr.gl_transfer_date
--   and hdr1.doc_sequence_id =  hdr.doc_sequence_id
--   and hdr1.doc_sequence_value =  hdr.doc_sequence_value
--   and hdr1.doc_category_code =  hdr.doc_category_code

   UNION   /* Bills Receivable */
   select /*+ ordered rowid(ct) use_nl(trx,th,trh,dist,dl,hdr,hdr1) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(HDR,XLA_AE_HEADERS_U1) index(HDR1,XLA_AE_HEADERS_N2) */
           hdr.ae_header_id                                      ae_header_id,
           hdr1.ae_header_id                                     header_id,
           hdr.event_id                                          event_id,
           dist.set_of_books_id                                   sob_id,
           dist.source_type                                       account_class,
           'AR_DISTRIBUTIONS_ALL'                                source_table,
           dist.code_combination_id                               code_combination_id,
           dist.amount_dr                                         amount_dr,
           dist.amount_cr                                         amount_cr,
           dist.acctd_amount_dr                                   acctd_amount_dr,
           dist.acctd_amount_cr                                   acctd_amount_cr,
           dist.currency_code                                     currency_code,
           dist.third_party_id                                    third_party_id,
           dist.third_party_sub_id                                third_party_sub_id,
           dist.currency_conversion_date                          exchange_date,
           dist.currency_conversion_rate                          exchange_rate,
           dist.currency_conversion_type                          exchange_type,
           dist.line_id                                           line_id,
           null                                                  tax_line_id,
	   'N'							 gain_loss_flag,
	   dl.event_type_code                                    event_type_code,
           dl.event_class_code                                   event_class_code,
           hdr.accounting_date                                   accounting_date,
           hdr1.ledger_id                                        ledger_id,
           3                                                     ln_order
   --
   from ra_mc_customer_trx ct,
        ra_customer_trx_all trx,
	ar_transaction_history_all th,
	xla_upgrade_dates gps,
	ar_mc_transaction_history trh,
	ar_mc_distributions_all dist,
	xla_distribution_links dl,
        xla_ae_headers hdr,
	xla_ae_headers hdr1
   --
   where ct.rowid >= l_start_rowid
   and ct.rowid <= l_end_rowid
   --
   and trx.customer_trx_id = ct.customer_trx_id
   and NVL(trx.ax_accounted_flag,'N') = 'N'
   --
   and th.customer_trx_id = ct.customer_trx_id
   and th.postable_flag = 'Y'
   --
   and trunc(th.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = ct.set_of_books_id
   --
   and trh.transaction_history_id = th.transaction_history_id
   and trh.posting_control_id <> -3
   and trh.set_of_books_id = ct.set_of_books_id
   --
   and dist.source_id = trh.transaction_history_id
   and dist.source_table = 'TH'
   and dist.set_of_books_id = trh.set_of_books_id
   --
   and dl.source_distribution_id_num_1 = dist.line_id
   and dl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
   and dl.application_id = 222
   and dl.upg_batch_id = l_batch_id
   --
   and hdr.ae_header_id = dl.ae_header_id
   and hdr.application_id = 222
   and hdr.upg_batch_id = l_batch_id
   and hdr.ledger_id = trx.set_of_books_id
   --
   and hdr1.application_id = 222
   and hdr1.upg_batch_id = l_batch_id
   and hdr1.ae_header_id <> hdr.ae_header_id
   and hdr1.ledger_id = dist.set_of_books_id
   and hdr1.entity_id = hdr.entity_id
   and hdr1.event_id = hdr.event_id
   and hdr1.event_type_code = hdr.event_type_code
   and hdr1.accounting_date = hdr.accounting_date
   and hdr1.period_name = hdr.period_name
   and hdr1.je_category_name = hdr.je_category_name
   and hdr1.gl_transfer_date = hdr.gl_transfer_date
--   and hdr1.doc_sequence_id =  hdr.doc_sequence_id
--   and hdr1.doc_sequence_value =  hdr.doc_sequence_value
--   and hdr1.doc_category_code =  hdr.doc_category_code
  );

  l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

   UPGRADE_MC_GAIN_LOSS(
                       l_start_rowid,
		       l_end_rowid,
                       l_table_name,
                       l_batch_id);

  END IF; --NVL(l_entity_type,'L') = 'L'

   ad_parallel_updates_pkg.processed_rowid_range(
                       l_rows_processed,
                       l_end_rowid);

   commit;

   ad_parallel_updates_pkg.get_rowid_range(
                       l_start_rowid,
                       l_end_rowid,
                       l_any_rows_to_process,
                       l_batch_size,
                       FALSE);

   l_rows_processed := 0 ;

 END LOOP ; /* end of WHILE loop */

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: ARP_MRC_XLA_UPGRADE.upgrade_mc_transactions');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: ARP_MRC_XLA_UPGRADE.upgrade_mc_transactions');
    RAISE;

END UPGRADE_MC_TRANSACTIONS;

/*========================================================================
 | PUBLIC PROCEDURE UPGRADE_MC_RECEIPTS
 |
 | DESCRIPTION
 |     Will create the records in XLA_AE_HEADERS, XLA_AE_LINES and
 |     XLA_DISTRIBUTION_LINKS for records related to receipts.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS
 |     UPGRADE_MC_GAIN_LOSS
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 03-JUL-2005           JVARKEY           Created
 | 30-AUG-2005		 JVARKEY           Modified the flow
 | 20-SEP-2005           JVARKEY           Detached the insert into
 |                                         xla_ae_headers into seperate
 |                                         insert statement
 *=======================================================================*/

PROCEDURE UPGRADE_MC_RECEIPTS(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2,
                       l_entity_type  IN VARCHAR2 DEFAULT NULL) IS

l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

BEGIN

  /* ------ Initialize the rowid ranges ------ */
  ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_script_name,
           l_worker_id,
           l_num_workers,
           l_batch_size, 0);

  /* ------ Get rowid ranges ------ */
  ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           l_batch_size,
           TRUE);

  WHILE ( l_any_rows_to_process = TRUE )
  LOOP

   l_rows_processed := 0;

  IF NVL(l_entity_type,'H') = 'H' THEN
-----------------------
-- Inserting headers --
-----------------------

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO XLA_AE_HEADERS
   (upg_batch_id,
    upg_source_application_id,
    application_id,
    amb_context_code,
    entity_id,
    event_id,
    event_type_code,
    ae_header_id,
    ledger_id,
    accounting_date,
    period_name,
    reference_date,
    balance_type_code,
    je_category_name,
    gl_transfer_status_code,
    gl_transfer_date,
    accounting_entry_status_code,
    accounting_entry_type_code,
    description,
    budget_version_id,
    funds_status_code,
--    encumbrance_type_id,
    completed_date,
    doc_sequence_id,
    doc_sequence_value,
    doc_category_code,
    packet_id,
    group_id,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    program_update_date,
    program_id,
    program_application_id,
    request_id,
    close_acct_seq_assign_id,
    close_acct_seq_version_id,
    close_acct_seq_value,
    completion_acct_seq_assign_id,
    completion_acct_seq_version_id,
    completion_acct_seq_value,
    upg_valid_flag
    --upg_worker_id
   )
   VALUES
   (batch_id,
    222,
    222,
   'DEFAULT',               --amb context code
   entity_id,
   event_id,
   override_event,
   xla_ae_headers_s.nextval,
   sob_id,
   gl_date,
   period_name,
   '',                      --reference date global acct eng
   'A',                     --balance type Actual
   category,                --category
   'Y',                     --gl transfer status
   gl_posted_date,          --gl transfer date
   'F',                     --acct entry status code final
   'STANDARD',              --acct entry type code
   '',                      --description TBD
   '',                      --budget version id
   '',                      --funds status code
--   '',                      --encumbrance type id
   '',                      --completed date
  doc_seq_id,
  doc_seq_value,
  cat_code,
  '',                       --packet id
  '',                       --group id
  sysdate,                  --row who creation date
  -2005,
  sysdate,
  -2005,
  -2005,
  sysdate,
  -2005,                    --program id
  222,
  '',                       --request id
  '',                       --AX columns start
  '',
  '',
  '',
  '',
  '',
  ''                        --upg valid flag
  --''
  )
   select
       l_batch_id                   AS batch_id,
       event_id                     AS event_id,
       entity_id                    AS entity_id,
       override_event               AS override_event,
       sob_id                       AS sob_id,
       gl_date                      AS gl_date,
       period_name                  AS period_name,
       category                     AS category,
       gl_posted_date               AS gl_posted_date,
       doc_seq_id                   AS doc_seq_id,
       doc_seq_value                AS doc_seq_value,
       cat_code                     AS cat_code

FROM
(select /*+ ordered rowid(cr) use_nl(rec,crh,mccrh,dist,dl,hdr) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(HDR,XLA_AE_HEADERS_U1) */
        hdr.ae_header_id                                      ae_header_id,
	hdr.entity_id                                         entity_id,
        hdr.event_id                                          event_id,
        hdr.event_type_code                                   override_event,
        hdr.accounting_date                                   gl_date,
        hdr.period_name                                       period_name,
        hdr.je_category_name                                  category,
        hdr.gl_transfer_date                                  gl_posted_date,
        hdr.doc_sequence_id                                   doc_seq_id,
        hdr.doc_sequence_value                                doc_seq_value,
        hdr.doc_category_code                                 cat_code,
        dist.set_of_books_id                                   sob_id
   --
   from ar_mc_cash_receipts cr,
        ar_cash_receipts_all rec,
	ar_cash_receipt_history_all crh,
	xla_upgrade_dates gps,
	ar_mc_cash_receipt_hist mccrh,
	ar_mc_distributions_all dist,
	xla_distribution_links dl,
        xla_ae_headers hdr
   --
   where cr.rowid >= l_start_rowid
   and cr.rowid <= l_end_rowid
   --
   and rec.cash_receipt_id = cr.cash_receipt_id
   and NVL(rec.ax_accounted_flag,'N') = 'N'
   --
   and crh.cash_receipt_id = cr.cash_receipt_id
   and crh.postable_flag = 'Y'
   --
   and trunc(crh.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = cr.set_of_books_id
   --
   and mccrh.cash_receipt_history_id = crh.cash_receipt_history_id
   and mccrh.posting_control_id <> -3
   and mccrh.set_of_books_id = cr.set_of_books_id
   --
   and dist.source_id = crh.cash_receipt_history_id
   and dist.source_table = 'CRH'
   and dist.set_of_books_id = mccrh.set_of_books_id
   --
   and dl.source_distribution_id_num_1 = dist.line_id
   and dl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
   and dl.application_id = 222
   and dl.upg_batch_id = l_batch_id
   --
   and hdr.ae_header_id = dl.ae_header_id
   and hdr.application_id = 222
   and hdr.upg_batch_id = l_batch_id
   and hdr.ledger_id = rec.set_of_books_id
   --
   group by
         hdr.ae_header_id,
	 hdr.entity_id,
         hdr.event_id,
         hdr.event_type_code,
         hdr.accounting_date,
         hdr.period_name,
         hdr.je_category_name,
         hdr.gl_transfer_date,
         hdr.doc_sequence_id,
         hdr.doc_sequence_value,
         hdr.doc_category_code,
         dist.set_of_books_id

   UNION   /* Receipt applications */
   select /*+ ordered rowid(cr) use_nl(rec,ra,app,dist,dl,hdr) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(HDR,XLA_AE_HEADERS_U1) */
        hdr.ae_header_id                                      ae_header_id,
	hdr.entity_id                                         entity_id,
        hdr.event_id                                          event_id,
        hdr.event_type_code                                   override_event,
        hdr.accounting_date                                   gl_date,
        hdr.period_name                                       period_name,
        hdr.je_category_name                                  category,
        hdr.gl_transfer_date                                  gl_posted_date,
        hdr.doc_sequence_id                                   doc_seq_id,
        hdr.doc_sequence_value                                doc_seq_value,
        hdr.doc_category_code                                 cat_code,
        dist.set_of_books_id                                   sob_id
   --
   from ar_mc_cash_receipts cr,
	ar_cash_receipts_all rec,
	ar_receivable_applications_all ra,
	xla_upgrade_dates gps,
	ar_mc_receivable_apps app,
	ar_mc_distributions_all dist,
	xla_distribution_links dl,
        xla_ae_headers hdr
   --
   where cr.rowid >= l_start_rowid
   and cr.rowid <= l_end_rowid
   --
   and rec.cash_receipt_id = cr.cash_receipt_id
   and NVL(rec.ax_accounted_flag,'N') = 'N'
   --
   and ra.cash_receipt_id = cr.cash_receipt_id
   --
   and trunc(ra.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = cr.set_of_books_id
   --
   and app.receivable_application_id = ra.receivable_application_id
   and app.posting_control_id <> -3
   and app.set_of_books_id = cr.set_of_books_id
   --
   and dist.source_id = ra.receivable_application_id
   and dist.source_table = 'RA'
   and dist.set_of_books_id = app.set_of_books_id
   --
   and dl.source_distribution_id_num_1 = dist.line_id
   and dl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
   and dl.application_id = 222
   and dl.upg_batch_id = l_batch_id
   --
   and hdr.ae_header_id = dl.ae_header_id
   and hdr.application_id = 222
   and hdr.upg_batch_id = l_batch_id
   and hdr.ledger_id = rec.set_of_books_id
   --
   group by
         hdr.ae_header_id,
	 hdr.entity_id,
         hdr.event_id,
         hdr.event_type_code,
         hdr.accounting_date,
         hdr.period_name,
         hdr.je_category_name,
         hdr.gl_transfer_date,
         hdr.doc_sequence_id,
         hdr.doc_sequence_value,
         hdr.doc_category_code,
         dist.set_of_books_id

   UNION   /* Misc Receipt */
   select /*+ ordered rowid(cr) use_nl(rec,mcd,mcmcd,dist,dl,hdr) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(HDR,XLA_AE_HEADERS_U1) */
           hdr.ae_header_id                                      ae_header_id,
	   hdr.entity_id                                         entity_id,
           hdr.event_id                                          event_id,
           hdr.event_type_code                                   override_event,
           hdr.accounting_date                                   gl_date,
           hdr.period_name                                       period_name,
           hdr.je_category_name                                  category,
           hdr.gl_transfer_date                                  gl_posted_date,
           hdr.doc_sequence_id                                   doc_seq_id,
           hdr.doc_sequence_value                                doc_seq_value,
           hdr.doc_category_code                                 cat_code,
           dist.set_of_books_id                                   sob_id
   --
   from ar_mc_cash_receipts cr,
	ar_cash_receipts_all rec,
	ar_misc_cash_distributions_all mcd,
	xla_upgrade_dates gps,
	ar_mc_misc_cash_dists mcmcd,
	ar_mc_distributions_all dist,
	xla_distribution_links dl,
        xla_ae_headers hdr
   --
   where cr.rowid >= l_start_rowid
   and cr.rowid <= l_end_rowid
   --
   and rec.cash_receipt_id = cr.cash_receipt_id
   and NVL(rec.ax_accounted_flag,'N') = 'N'
   --
   and mcd.cash_receipt_id = cr.cash_receipt_id
   --
   and trunc(mcd.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = cr.set_of_books_id
   --
   and mcmcd.misc_cash_distribution_id = mcd.misc_cash_distribution_id
   and mcmcd.posting_control_id <> -3
   and mcmcd.set_of_books_id = cr.set_of_books_id
   --
   and dist.source_id = mcd.misc_cash_distribution_id
   and dist.source_table = 'MCD'
   and dist.set_of_books_id = mcmcd.set_of_books_id
   --
   and dl.source_distribution_id_num_1 = dist.line_id
   and dl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
   and dl.application_id = 222
   and dl.upg_batch_id = l_batch_id
   --
   and hdr.ae_header_id = dl.ae_header_id
   and hdr.application_id = 222
   and hdr.upg_batch_id = l_batch_id
   and hdr.ledger_id = rec.set_of_books_id
   --
   group by
         hdr.ae_header_id,
	 hdr.entity_id,
         hdr.event_id,
         hdr.event_type_code,
         hdr.accounting_date,
         hdr.period_name,
         hdr.je_category_name,
         hdr.gl_transfer_date,
         hdr.doc_sequence_id,
         hdr.doc_sequence_value,
         hdr.doc_category_code,
         dist.set_of_books_id
   );
  l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  END IF; --NVL(l_entity_type,'H') = 'H'

  IF NVL(l_entity_type,'L') = 'L' THEN
--------------------------------------------
-- Inserting lines and distribution links --
--------------------------------------------

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO XLA_AE_LINES
      (upg_batch_id,
       ae_header_id,
       ae_line_num,
       application_id,
       code_combination_id,
       gl_transfer_mode_code,
       accounted_dr,
       accounted_cr,
       currency_code,
       currency_conversion_date,
       currency_conversion_rate,
       currency_conversion_type,
       entered_dr,
       entered_cr,
       description,
       accounting_class_code,
       gl_sl_link_id,
       gl_sl_link_table,
       party_type_code,
       party_id,
       party_site_id,
       statistical_amount,
       ussgl_transaction_code,
       jgzz_recon_ref,
       control_balance_flag,
       analytical_balance_flag,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_update_date,
       program_id,
       program_application_id,
       request_id,
       gain_or_loss_flag,
       accounting_date,
       ledger_id
      )
  VALUES
   (   batch_id,
       header_id,
       line_num,
       222,
       code_combination_id,
       'D',                             --gl transfer mode Summary or detail
       acctd_amount_dr,
       acctd_amount_cr,
       currency_code,
       exchange_date,
       exchange_rate,
       exchange_type,
       amount_dr,
       amount_cr,
       '',                             --description TBD
       nvl(account_class,'XXXX'),      --accounting class code
       xla_gl_sl_link_id_s.nextval,    --gl sl link id
       'XLAJEL',                       --gl sl link table
       DECODE(third_party_id, NULL, NULL, 'C'),  --party type code
       third_party_id,                 --party id
       third_party_sub_id,             --third party site
       '',                             --statistical amount
       '',                             --ussgl trx code
       '',                             --jgzz recon ref
       '',                             --control balance flag
       '',                             --analytical balance
       sysdate,                        --row who columns
       -2005,
       sysdate,
       -2005,
       -2005,
       sysdate,
       -2005,                           --program id
       222,
       '',                              --request id
       gain_loss_flag,
       accounting_date,
       ledger_id)
   WHEN 1 = 1 THEN
   INTO XLA_DISTRIBUTION_LINKS
      (APPLICATION_ID,
       EVENT_ID,
       AE_HEADER_ID,
       AE_LINE_NUM,
       ACCOUNTING_LINE_CODE,
       ACCOUNTING_LINE_TYPE_CODE,
       REF_AE_HEADER_ID,
--       REF_AE_LINE_NUM,
       SOURCE_DISTRIBUTION_TYPE,
       SOURCE_DISTRIBUTION_ID_CHAR_1,
       SOURCE_DISTRIBUTION_ID_CHAR_2,
       SOURCE_DISTRIBUTION_ID_CHAR_3,
       SOURCE_DISTRIBUTION_ID_CHAR_4,
       SOURCE_DISTRIBUTION_ID_CHAR_5,
       SOURCE_DISTRIBUTION_ID_NUM_1,
       SOURCE_DISTRIBUTION_ID_NUM_2,
       SOURCE_DISTRIBUTION_ID_NUM_3,
       SOURCE_DISTRIBUTION_ID_NUM_4,
       SOURCE_DISTRIBUTION_ID_NUM_5,
       UNROUNDED_ENTERED_DR,
       UNROUNDED_ENTERED_CR,
       UNROUNDED_ACCOUNTED_DR,
       UNROUNDED_ACCOUNTED_CR,
       MERGE_DUPLICATE_CODE,
       TAX_LINE_REF_ID,
       TAX_SUMMARY_LINE_REF_ID,
       TAX_REC_NREC_DIST_REF_ID,
       STATISTICAL_AMOUNT,
       TEMP_LINE_NUM,
       EVENT_TYPE_CODE,
       EVENT_CLASS_CODE,
       REF_EVENT_ID,
       UPG_BATCH_ID)
    VALUES
      (222,
       event_id,
       header_id,
       line_num,
       account_class,
       'C',  --accounting line code customer
       ae_header_id, --reference header id
--       '', --reference line number
       source_table,
       '', --src dist id char
       '',
       '',
       '',
       '',
       line_id, --src dist id num
       '',
       '',
       '',
       '',
       amount_dr,
       amount_cr,
       acctd_amount_dr,
       acctd_amount_cr,
       'N',         --merge dup code
       tax_line_id, --tax_line_ref_id
       '',         --tax_summary_line_ref_id
       '',         --tax_rec_nrec_dist_ref_id
       '',         --statistical amount
       line_num,   --temp_line_num
       event_type_code, --event_type_code
       event_class_code, --event class code
       '',         --ref_event_id,
       batch_id)   --upgrade batch id
   select
       l_batch_id                   AS batch_id,
       header_id                    AS header_id,
       ae_header_id                 AS ae_header_id,
       line_id                      AS line_id,
       event_id                     AS event_id,
       account_class                AS account_class,
       source_table                 AS source_table,
       code_combination_id          AS code_combination_id,
       amount_dr                    AS amount_dr,
       amount_cr                    AS amount_cr,
       acctd_amount_dr              AS acctd_amount_dr,
       acctd_amount_cr              AS acctd_amount_cr,
       nvl(currency_code,'XXXX')    AS currency_code,
       third_party_id               AS third_party_id,
       third_party_sub_id           AS third_party_sub_id,
       exchange_date                AS exchange_date,
       exchange_rate                AS exchange_rate,
       exchange_type                AS exchange_type,
       tax_line_id                  AS tax_line_id,
       sob_id                       AS sob_id,
       gain_loss_flag		    AS gain_loss_flag,
       event_type_code              AS event_type_code,
       event_class_code             AS event_class_code,
       accounting_date              AS accounting_date,
       ledger_id                    AS ledger_id,
       RANK() OVER (PARTITION BY event_id, ae_header_id, sob_id
                    ORDER BY line_id, ln_order) AS line_num
FROM
(select /*+ ordered rowid(cr) use_nl(rec,crh,mccrh,dist,dl,hdr,hdr1) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(HDR,XLA_AE_HEADERS_U1) index(HDR1,XLA_AE_HEADERS_N2) */
        hdr.ae_header_id                                      ae_header_id,
	hdr1.ae_header_id                                     header_id,
        hdr.event_id                                          event_id,
        dist.set_of_books_id                                   sob_id,
        dist.source_type                                       account_class,
        'AR_DISTRIBUTIONS_ALL'                                source_table,
        dist.code_combination_id                               code_combination_id,
        dist.amount_dr                                         amount_dr,
        dist.amount_cr                                         amount_cr,
        dist.acctd_amount_dr                                   acctd_amount_dr,
        dist.acctd_amount_cr                                   acctd_amount_cr,
        dist.currency_code                                     currency_code,
        dist.third_party_id                                    third_party_id,
        dist.third_party_sub_id                                third_party_sub_id,
        dist.currency_conversion_date                          exchange_date,
        dist.currency_conversion_rate                          exchange_rate,
        dist.currency_conversion_type                          exchange_type,
        dist.line_id                                           line_id,
        null                                                  tax_line_id,
	'N'						      gain_loss_flag,
	dl.event_type_code                                    event_type_code,
        dl.event_class_code                                   event_class_code,
        hdr.accounting_date                                   accounting_date,
        hdr1.ledger_id                                        ledger_id,
        1                                                     ln_order
   --
   from ar_mc_cash_receipts cr,
	ar_cash_receipts_all rec,
	ar_cash_receipt_history_all crh,
	xla_upgrade_dates gps,
	ar_mc_cash_receipt_hist mccrh,
	ar_mc_distributions_all dist,
	xla_distribution_links dl,
        xla_ae_headers hdr,
	xla_ae_headers hdr1
   --
   where cr.rowid >= l_start_rowid
   and cr.rowid <= l_end_rowid
   --
   and rec.cash_receipt_id = cr.cash_receipt_id
   and NVL(rec.ax_accounted_flag,'N') = 'N'
   --
   and crh.cash_receipt_id = cr.cash_receipt_id
   and crh.postable_flag = 'Y'
   --
   and trunc(crh.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = cr.set_of_books_id
   --
   and mccrh.cash_receipt_history_id = crh.cash_receipt_history_id
   and mccrh.posting_control_id <> -3
   and mccrh.set_of_books_id = cr.set_of_books_id
   --
   and dist.source_id = crh.cash_receipt_history_id
   and dist.source_table = 'CRH'
   and dist.set_of_books_id = mccrh.set_of_books_id
   --
   and dl.source_distribution_id_num_1 = dist.line_id
   and dl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
   and dl.application_id = 222
   and dl.upg_batch_id = l_batch_id
   --
   and hdr.ae_header_id = dl.ae_header_id
   and hdr.application_id = 222
   and hdr.upg_batch_id = l_batch_id
   and hdr.ledger_id = rec.set_of_books_id
   --
   and hdr1.application_id = 222
   and hdr1.upg_batch_id = l_batch_id
   and hdr1.ae_header_id <> hdr.ae_header_id
   and hdr1.ledger_id = dist.set_of_books_id
   and hdr1.entity_id = hdr.entity_id
   and hdr1.event_id = hdr.event_id
   and hdr1.event_type_code = hdr.event_type_code
   and hdr1.accounting_date = hdr.accounting_date
   and hdr1.period_name = hdr.period_name
   and hdr1.je_category_name = hdr.je_category_name
   and hdr1.gl_transfer_date = hdr.gl_transfer_date
--   and hdr1.doc_sequence_id =  hdr.doc_sequence_id
--   and hdr1.doc_sequence_value =  hdr.doc_sequence_value
--   and hdr1.doc_category_code =  hdr.doc_category_code

   UNION   /* Receipt applications */
   select /*+ ordered rowid(cr) use_nl(rec,ra,app,dist,dl,hdr,hdr1) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(HDR,XLA_AE_HEADERS_U1) index(HDR1,XLA_AE_HEADERS_N2) */
        hdr.ae_header_id                                      ae_header_id,
	hdr1.ae_header_id                                     header_id,
        hdr.event_id                                          event_id,
        dist.set_of_books_id                                   sob_id,
        dist.source_type                                       account_class,
        'AR_DISTRIBUTIONS_ALL'                                source_table,
        dist.code_combination_id                               code_combination_id,
        dist.amount_dr                                         amount_dr,
        dist.amount_cr                                         amount_cr,
        dist.acctd_amount_dr                                   acctd_amount_dr,
        dist.acctd_amount_cr                                   acctd_amount_cr,
        dist.currency_code                                     currency_code,
        dist.third_party_id                                    third_party_id,
        dist.third_party_sub_id                                third_party_sub_id,
        dist.currency_conversion_date                          exchange_date,
        dist.currency_conversion_rate                          exchange_rate,
        dist.currency_conversion_type                          exchange_type,
        dist.line_id                                           line_id,
        null                                                  tax_line_id,
	decode(dist.source_type,
               'EXCH_GAIN','Y',
               'EXCH_LOSS','Y',
	       'CURR_ROUND','Y',
               'N')                                           gain_loss_flag,
	dl.event_type_code                                    event_type_code,
        dl.event_class_code                                   event_class_code,
        hdr.accounting_date                                   accounting_date,
        hdr1.ledger_id                                        ledger_id,
        2                                                     ln_order
   --
   from ar_mc_cash_receipts cr,
        ar_cash_receipts_all rec,
	ar_receivable_applications_all ra,
	xla_upgrade_dates gps,
	ar_mc_receivable_apps app,
	ar_mc_distributions_all dist,
	xla_distribution_links dl,
        xla_ae_headers hdr,
	xla_ae_headers hdr1
   --
   where cr.rowid >= l_start_rowid
   and cr.rowid <= l_end_rowid
   --
   and rec.cash_receipt_id = cr.cash_receipt_id
   and NVL(rec.ax_accounted_flag,'N') = 'N'
   --
   and ra.cash_receipt_id = cr.cash_receipt_id
   --
   and trunc(ra.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = cr.set_of_books_id
   --
   and app.receivable_application_id = ra.receivable_application_id
   and app.posting_control_id <> -3
   and app.set_of_books_id = cr.set_of_books_id
   --
   and dist.source_id = ra.receivable_application_id
   and dist.source_table = 'RA'
   and dist.set_of_books_id = app.set_of_books_id
   --
   and dl.source_distribution_id_num_1 = dist.line_id
   and dl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
   and dl.application_id = 222
   and dl.upg_batch_id = l_batch_id
   --
   and hdr.ae_header_id = dl.ae_header_id
   and hdr.application_id = 222
   and hdr.upg_batch_id = l_batch_id
   and hdr.ledger_id = rec.set_of_books_id
   --
   and hdr1.application_id = 222
   and hdr1.upg_batch_id = l_batch_id
   and hdr1.ae_header_id <> hdr.ae_header_id
   and hdr1.ledger_id = dist.set_of_books_id
   and hdr1.entity_id = hdr.entity_id
   and hdr1.event_id = hdr.event_id
   and hdr1.event_type_code = hdr.event_type_code
   and hdr1.accounting_date = hdr.accounting_date
   and hdr1.period_name = hdr.period_name
   and hdr1.je_category_name = hdr.je_category_name
   and hdr1.gl_transfer_date = hdr.gl_transfer_date
--   and hdr1.doc_sequence_id =  hdr.doc_sequence_id
--   and hdr1.doc_sequence_value =  hdr.doc_sequence_value
--   and hdr1.doc_category_code =  hdr.doc_category_code

   UNION   /* Misc Receipt */
   select /*+ ordered rowid(cr) use_nl(rec,mcd,mcmcd,dist,dl,hdr,hdr1) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(HDR,XLA_AE_HEADERS_U1) index(HDR1,XLA_AE_HEADERS_N2) */
           hdr.ae_header_id                                      ae_header_id,
	   hdr1.ae_header_id                                     header_id,
	   hdr.event_id                                          event_id,
           dist.set_of_books_id                                   sob_id,
           dist.source_type                                       account_class,
           'AR_DISTRIBUTIONS_ALL'                                source_table,
           dist.code_combination_id                               code_combination_id,
           dist.amount_dr                                         amount_dr,
           dist.amount_cr                                         amount_cr,
           dist.acctd_amount_dr                                   acctd_amount_dr,
           dist.acctd_amount_cr                                   acctd_amount_cr,
           dist.currency_code                                     currency_code,
           dist.third_party_id                                    third_party_id,
           dist.third_party_sub_id                                third_party_sub_id,
           dist.currency_conversion_date                          exchange_date,
           dist.currency_conversion_rate                          exchange_rate,
           dist.currency_conversion_type                          exchange_type,
           dist.line_id                                           line_id,
           null                                                  tax_line_id,
           'N'					 	         gain_loss_flag,
	   dl.event_type_code                                    event_type_code,
           dl.event_class_code                                   event_class_code,
           hdr.accounting_date                                   accounting_date,
           hdr.ledger_id                                         ledger_id,
           3                                                     ln_order
   --
   from ar_mc_cash_receipts cr,
	ar_cash_receipts_all rec,
	ar_misc_cash_distributions_all mcd,
	xla_upgrade_dates gps,
	ar_mc_misc_cash_dists mcmcd,
	ar_mc_distributions_all dist,
	xla_distribution_links dl,
        xla_ae_headers hdr,
	xla_ae_headers hdr1
   --
   where cr.rowid >= l_start_rowid
   and cr.rowid <= l_end_rowid
   --
   and rec.cash_receipt_id = cr.cash_receipt_id
   and NVL(rec.ax_accounted_flag,'N') = 'N'
   --
   and mcd.cash_receipt_id = cr.cash_receipt_id
   --
   and trunc(mcd.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = cr.set_of_books_id
   --
   and mcmcd.misc_cash_distribution_id = mcd.misc_cash_distribution_id
   and mcmcd.posting_control_id <> -3
   and mcmcd.set_of_books_id = cr.set_of_books_id
   --
   and dist.source_id = mcd.misc_cash_distribution_id
   and dist.source_table = 'MCD'
   and dist.set_of_books_id = mcmcd.set_of_books_id
   --
   and dl.source_distribution_id_num_1 = dist.line_id
   and dl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
   and dl.application_id = 222
   and dl.upg_batch_id = l_batch_id
   --
   and hdr.ae_header_id = dl.ae_header_id
   and hdr.application_id = 222
   and hdr.upg_batch_id = l_batch_id
   and hdr.ledger_id = rec.set_of_books_id
   --
   and hdr1.application_id = 222
   and hdr1.upg_batch_id = l_batch_id
   and hdr1.ae_header_id <> hdr.ae_header_id
   and hdr1.ledger_id = dist.set_of_books_id
   and hdr1.entity_id = hdr.entity_id
   and hdr1.event_id = hdr.event_id
   and hdr1.event_type_code = hdr.event_type_code
   and hdr1.accounting_date = hdr.accounting_date
   and hdr1.period_name = hdr.period_name
   and hdr1.je_category_name = hdr.je_category_name
   and hdr1.gl_transfer_date = hdr.gl_transfer_date
--   and hdr1.doc_sequence_id =  hdr.doc_sequence_id
--   and hdr1.doc_sequence_value =  hdr.doc_sequence_value
--   and hdr1.doc_category_code =  hdr.doc_category_code
   );

   l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

   UPGRADE_MC_GAIN_LOSS(
                       l_start_rowid,
		       l_end_rowid,
                       l_table_name,
                       l_batch_id);

  END IF; --NVL(l_entity_type,'L') = 'L'

   ad_parallel_updates_pkg.processed_rowid_range(
                       l_rows_processed,
                       l_end_rowid);

   commit;

   ad_parallel_updates_pkg.get_rowid_range(
                       l_start_rowid,
                       l_end_rowid,
                       l_any_rows_to_process,
                       l_batch_size,
                       FALSE);

   l_rows_processed := 0 ;

 END LOOP ; /* end of WHILE loop */

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: ARP_MRC_XLA_UPGRADE.upgrade_mc_receipts');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: ARP_MRC_XLA_UPGRADE.upgrade_mc_receipts');
    RAISE;

END UPGRADE_MC_RECEIPTS;

/*========================================================================
 | PUBLIC PROCEDURE UPGRADE_MC_ADJUSTMENTS
 |
 | DESCRIPTION
 |     Will create the records in XLA_AE_HEADERS, XLA_AE_LINES and
 |     XLA_DISTRIBUTION_LINKS for records related to adjustments.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 03-JUL-2005           JVARKEY           Created
 | 30-AUG-2005		 JVARKEY           Modified the flow
 | 20-SEP-2005           JVARKEY           Detached the insert into
 |                                         xla_ae_headers into seperate
 |                                         insert statement
 *=======================================================================*/

PROCEDURE UPGRADE_MC_ADJUSTMENTS(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2,
                       l_entity_type  IN VARCHAR2 DEFAULT NULL) IS

l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

BEGIN

  /* ------ Initialize the rowid ranges ------ */
  ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_script_name,
           l_worker_id,
           l_num_workers,
           l_batch_size, 0);

  /* ------ Get rowid ranges ------ */
  ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           l_batch_size,
           TRUE);

  WHILE ( l_any_rows_to_process = TRUE )
  LOOP

   l_rows_processed := 0;

  IF NVL(l_entity_type,'H') = 'H' THEN
-----------------------
-- Inserting headers --
-----------------------

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO XLA_AE_HEADERS
   (upg_batch_id,
    upg_source_application_id,
    application_id,
    amb_context_code,
    entity_id,
    event_id,
    event_type_code,
    ae_header_id,
    ledger_id,
    accounting_date,
    period_name,
    reference_date,
    balance_type_code,
    je_category_name,
    gl_transfer_status_code,
    gl_transfer_date,
    accounting_entry_status_code,
    accounting_entry_type_code,
    description,
    budget_version_id,
    funds_status_code,
--    encumbrance_type_id,
    completed_date,
    doc_sequence_id,
    doc_sequence_value,
    doc_category_code,
    packet_id,
    group_id,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    program_update_date,
    program_id,
    program_application_id,
    request_id,
    close_acct_seq_assign_id,
    close_acct_seq_version_id,
    close_acct_seq_value,
    completion_acct_seq_assign_id,
    completion_acct_seq_version_id,
    completion_acct_seq_value,
    upg_valid_flag
    --upg_worker_id
   )
   VALUES
   (batch_id,
    222,
    222,
   'DEFAULT',               --amb context code
   entity_id,
   event_id,
   override_event,
   xla_ae_headers_s.nextval,
   sob_id,
   gl_date,
   period_name,
   '',                      --reference date global acct eng
   'A',                     --balance type Actual
   category,                --category
   'Y',                     --gl transfer status
   gl_posted_date,          --gl transfer date
   'F',                     --acct entry status code final
   'STANDARD',              --acct entry type code
   '',                      --description TBD
   '',                      --budget version id
   '',                      --funds status code
--   '',                      --encumbrance type id
   '',                      --completed date
  doc_seq_id,
  doc_seq_value,
  cat_code,
  '',                       --packet id
  '',                       --group id
  sysdate,                  --row who creation date
  -2005,
  sysdate,
  -2005,
  -2005,
  sysdate,
  -2005,                    --program id
  222,
  '',                       --request id
  '',                       --AX columns start
  '',
  '',
  '',
  '',
  '',
  ''                        --upg valid flag
  --''
  )
   select
       l_batch_id                   AS batch_id,
       event_id                     AS event_id,
       entity_id                    AS entity_id,
       override_event               AS override_event,
       sob_id                       AS sob_id,
       gl_date                      AS gl_date,
       period_name                  AS period_name,
       category                     AS category,
       gl_posted_date               AS gl_posted_date,
       doc_seq_id                   AS doc_seq_id,
       doc_seq_value                AS doc_seq_value,
       cat_code                     AS cat_code
FROM
(select /*+ ordered rowid(adj) use_nl(adjt,dist,dl,hdr) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(HDR,XLA_AE_HEADERS_U1) */
        hdr.ae_header_id                                      ae_header_id,
	hdr.entity_id                                         entity_id,
        hdr.event_id                                          event_id,
        hdr.event_type_code                                   override_event,
        hdr.accounting_date                                   gl_date,
        hdr.period_name                                       period_name,
        hdr.je_category_name                                  category,
        hdr.gl_transfer_date                                  gl_posted_date,
        hdr.doc_sequence_id                                   doc_seq_id,
        hdr.doc_sequence_value                                doc_seq_value,
        hdr.doc_category_code                                 cat_code,
        dist.set_of_books_id                                   sob_id
   --
   from ar_mc_adjustments adj,
	ar_adjustments_all adjt,
	xla_upgrade_dates gps,
	ar_mc_distributions_all dist,
	xla_distribution_links dl,
        xla_ae_headers hdr
   --
   where adj.rowid >= l_start_rowid
   and adj.rowid <= l_end_rowid
   and adj.posting_control_id <> -3
   --
   and adjt.adjustment_id = adj.adjustment_id
   and NVL(adjt.ax_accounted_flag,'N') = 'N'
   --
   and trunc(adjt.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = adj.set_of_books_id
   --
   and dist.source_id = adjt.adjustment_id
   and dist.source_table = 'ADJ'
   and dist.set_of_books_id = adj.set_of_books_id
   --
   and dl.source_distribution_id_num_1 = dist.line_id
   and dl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
   and dl.application_id = 222
   and dl.upg_batch_id = l_batch_id
   --
   and hdr.ae_header_id = dl.ae_header_id
   and hdr.application_id = 222
   and hdr.upg_batch_id = l_batch_id
   and hdr.ledger_id = adjt.set_of_books_id
   --
   group by
         hdr.ae_header_id,
	 hdr.entity_id,
         hdr.event_id,
         hdr.event_type_code,
         hdr.accounting_date,
         hdr.period_name,
         hdr.je_category_name,
         hdr.gl_transfer_date,
         hdr.doc_sequence_id,
         hdr.doc_sequence_value,
         hdr.doc_category_code,
         dist.set_of_books_id
   );
  l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  END IF; --NVL(l_entity_type,'H') = 'H'

  IF NVL(l_entity_type,'L') = 'L' THEN
--------------------------------------------
-- Inserting lines and distribution links --
--------------------------------------------

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO XLA_AE_LINES
      (upg_batch_id,
       ae_header_id,
       ae_line_num,
       application_id,
       code_combination_id,
       gl_transfer_mode_code,
       accounted_dr,
       accounted_cr,
       currency_code,
       currency_conversion_date,
       currency_conversion_rate,
       currency_conversion_type,
       entered_dr,
       entered_cr,
       description,
       accounting_class_code,
       gl_sl_link_id,
       gl_sl_link_table,
       party_type_code,
       party_id,
       party_site_id,
       statistical_amount,
       ussgl_transaction_code,
       jgzz_recon_ref,
       control_balance_flag,
       analytical_balance_flag,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_update_date,
       program_id,
       program_application_id,
       request_id,
       gain_or_loss_flag,
       accounting_date,
       ledger_id
      )
  VALUES
   (   batch_id,
       header_id,
       line_num,
       222,
       code_combination_id,
       'D',                             --gl transfer mode Summary or detail
       acctd_amount_dr,
       acctd_amount_cr,
       currency_code,
       exchange_date,
       exchange_rate,
       exchange_type,
       amount_dr,
       amount_cr,
       '',                             --description TBD
       nvl(account_class,'XXXX'),      --accounting class code
       xla_gl_sl_link_id_s.nextval,    --gl sl link id
       'XLAJEL',                       --gl sl link table
       DECODE(third_party_id, NULL, NULL, 'C'),  --party type code
       third_party_id,                 --party id
       third_party_sub_id,             --third party site
       '',                             --statistical amount
       '',                             --ussgl trx code
       '',                             --jgzz recon ref
       '',                             --control balance flag
       '',                             --analytical balance
       sysdate,                        --row who columns
       -2005,
       sysdate,
       -2005,
       -2005,
       sysdate,
       -2005,                           --program id
       222,
       '',                              --request id
       'N',
       accounting_date,
       ledger_id)
   WHEN 1 = 1 THEN
   INTO XLA_DISTRIBUTION_LINKS
      (APPLICATION_ID,
       EVENT_ID,
       AE_HEADER_ID,
       AE_LINE_NUM,
       ACCOUNTING_LINE_CODE,
       ACCOUNTING_LINE_TYPE_CODE,
       REF_AE_HEADER_ID,
--       REF_AE_LINE_NUM,
       SOURCE_DISTRIBUTION_TYPE,
       SOURCE_DISTRIBUTION_ID_CHAR_1,
       SOURCE_DISTRIBUTION_ID_CHAR_2,
       SOURCE_DISTRIBUTION_ID_CHAR_3,
       SOURCE_DISTRIBUTION_ID_CHAR_4,
       SOURCE_DISTRIBUTION_ID_CHAR_5,
       SOURCE_DISTRIBUTION_ID_NUM_1,
       SOURCE_DISTRIBUTION_ID_NUM_2,
       SOURCE_DISTRIBUTION_ID_NUM_3,
       SOURCE_DISTRIBUTION_ID_NUM_4,
       SOURCE_DISTRIBUTION_ID_NUM_5,
       UNROUNDED_ENTERED_DR,
       UNROUNDED_ENTERED_CR,
       UNROUNDED_ACCOUNTED_DR,
       UNROUNDED_ACCOUNTED_CR,
       MERGE_DUPLICATE_CODE,
       TAX_LINE_REF_ID,
       TAX_SUMMARY_LINE_REF_ID,
       TAX_REC_NREC_DIST_REF_ID,
       STATISTICAL_AMOUNT,
       TEMP_LINE_NUM,
       EVENT_TYPE_CODE,
       EVENT_CLASS_CODE,
       REF_EVENT_ID,
       UPG_BATCH_ID)
    VALUES
      (222,
       event_id,
       header_id,
       line_num,
       account_class,
       'C',  --accounting line code customer
       ae_header_id, --reference header id
--       '', --reference line number
       source_table,
       '', --src dist id char
       '',
       '',
       '',
       '',
       line_id, --src dist id num
       '',
       '',
       '',
       '',
       amount_dr,
       amount_cr,
       acctd_amount_dr,
       acctd_amount_cr,
       'N',         --merge dup code
       tax_line_id, --tax_line_ref_id
       '',         --tax_summary_line_ref_id
       '',         --tax_rec_nrec_dist_ref_id
       '',         --statistical amount
       line_num,   --temp_line_num
       event_type_code, --event_type_code
       event_class_code, --event class code
       '',         --ref_event_id,
       batch_id)   --upgrade batch id
   select
       l_batch_id                   AS batch_id,
       header_id                    AS header_id,
       ae_header_id                 AS ae_header_id,
       line_id                      AS line_id,
       event_id                     AS event_id,
       account_class                AS account_class,
       source_table                 AS source_table,
       code_combination_id          AS code_combination_id,
       amount_dr                    AS amount_dr,
       amount_cr                    AS amount_cr,
       acctd_amount_dr              AS acctd_amount_dr,
       acctd_amount_cr              AS acctd_amount_cr,
       nvl(currency_code,'XXXX')    AS currency_code,
       third_party_id               AS third_party_id,
       third_party_sub_id           AS third_party_sub_id,
       exchange_date                AS exchange_date,
       exchange_rate                AS exchange_rate,
       exchange_type                AS exchange_type,
       tax_line_id                  AS tax_line_id,
       sob_id                       AS sob_id,
       event_type_code              AS event_type_code,
       event_class_code             AS event_class_code,
       accounting_date              AS accounting_date,
       ledger_id                    AS ledger_id,
       RANK() OVER (PARTITION BY event_id, ae_header_id, sob_id
                    ORDER BY line_id, ln_order) AS line_num
FROM
(select /*+ ordered rowid(adj) use_nl(adjt,dist,dl,hdr,hdr1) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(HDR,XLA_AE_HEADERS_U1) index(HDR1,XLA_AE_HEADERS_N2) */
        hdr.ae_header_id                                      ae_header_id,
	hdr1.ae_header_id                                     header_id,
        hdr.event_id                                          event_id,
        dist.set_of_books_id                                   sob_id,
        dist.source_type                                       account_class,
        'AR_DISTRIBUTIONS_ALL'                                source_table,
        dist.code_combination_id                               code_combination_id,
        dist.amount_dr                                         amount_dr,
        dist.amount_cr                                         amount_cr,
        dist.acctd_amount_dr                                   acctd_amount_dr,
        dist.acctd_amount_cr                                   acctd_amount_cr,
        dist.currency_code                                     currency_code,
        dist.third_party_id                                    third_party_id,
        dist.third_party_sub_id                                third_party_sub_id,
        dist.currency_conversion_date                          exchange_date,
        dist.currency_conversion_rate                          exchange_rate,
        dist.currency_conversion_type                          exchange_type,
        dist.line_id                                           line_id,
        null                                                  tax_line_id,
	dl.event_type_code                                    event_type_code,
        dl.event_class_code                                   event_class_code,
        hdr.accounting_date                                   accounting_date,
        hdr1.ledger_id                                        ledger_id,
        1                                                     ln_order
   --
   from ar_mc_adjustments adj,
        ar_adjustments_all adjt,
	xla_upgrade_dates gps,
	ar_mc_distributions_all dist,
	xla_distribution_links dl,
        xla_ae_headers hdr,
	xla_ae_headers hdr1
   --
   where adj.rowid >= l_start_rowid
   and adj.rowid <= l_end_rowid
   and adj.posting_control_id <> -3
   --
   and adjt.adjustment_id = adj.adjustment_id
   and NVL(adjt.ax_accounted_flag,'N') = 'N'
   --
   and trunc(adjt.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = adj.set_of_books_id
   --
   and dist.source_id = adjt.adjustment_id
   and dist.source_table = 'ADJ'
   and dist.set_of_books_id = adj.set_of_books_id
   --
   and dl.source_distribution_id_num_1 = dist.line_id
   and dl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
   and dl.application_id = 222
   and dl.upg_batch_id = l_batch_id
   --
   and hdr.ae_header_id = dl.ae_header_id
   and hdr.application_id = 222
   and hdr.upg_batch_id = l_batch_id
   and hdr.ledger_id = adjt.set_of_books_id
   --
   and hdr1.application_id = 222
   and hdr1.upg_batch_id = l_batch_id
   and hdr1.ae_header_id <> hdr.ae_header_id
   and hdr1.ledger_id = dist.set_of_books_id
   and hdr1.entity_id = hdr.entity_id
   and hdr1.event_id = hdr.event_id
   and hdr1.event_type_code = hdr.event_type_code
   and hdr1.accounting_date = hdr.accounting_date
   and hdr1.period_name = hdr.period_name
   and hdr1.je_category_name = hdr.je_category_name
   and hdr1.gl_transfer_date = hdr.gl_transfer_date
--   and hdr1.doc_sequence_id =  hdr.doc_sequence_id
--   and hdr1.doc_sequence_value =  hdr.doc_sequence_value
--   and hdr1.doc_category_code =  hdr.doc_category_code
   );

  l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  END IF; --NVL(l_entity_type,'L') = 'L'

   ad_parallel_updates_pkg.processed_rowid_range(
                       l_rows_processed,
                       l_end_rowid);

   commit;

   ad_parallel_updates_pkg.get_rowid_range(
                       l_start_rowid,
                       l_end_rowid,
                       l_any_rows_to_process,
                       l_batch_size,
                       FALSE);

   l_rows_processed := 0 ;

 END LOOP ; /* end of WHILE loop */

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: ARP_MRC_XLA_UPGRADE.upgrade_mc_adjustments');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: ARP_MRC_XLA_UPGRADE.upgrade_mc_adjustments');
    RAISE;

END UPGRADE_MC_ADJUSTMENTS;

/*========================================================================
 | PRIVATE PROCEDURE UPGRADE_MC_GAIN_LOSS
 |
 | DESCRIPTION
 |     Will create the records in XLA_AE_HEADERS, XLA_AE_LINES and
 |     XLA_DISTRIBUTION_LINKS for records related to exchange_gain/loss
 |     which doesnt have any parent record in AR and exist in MRC.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |     UPGRADE_MC_TRANSACTIONS
 |     UPGRADE_MC_RECEIPTS
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author          Description of Changes
 | 01-SEP-2005		 JVARKEY         Created
 | 08-SEP-2005           JVARKEY         Changed the query for mass insert
 *=======================================================================*/

PROCEDURE UPGRADE_MC_GAIN_LOSS(
                       l_start_rowid  IN ROWID,
		       l_end_rowid    IN ROWID,
                       l_table_name   IN VARCHAR2,
                       l_batch_id     IN NUMBER) IS

l_rows_processed      number := 0;

BEGIN

l_rows_processed  := 0;

IF (l_table_name = 'AR_MC_CASH_RECEIPTS') THEN

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO XLA_AE_LINES
      (upg_batch_id,
       ae_header_id,
       ae_line_num,
       application_id,
       code_combination_id,
       gl_transfer_mode_code,
       accounted_dr,
       accounted_cr,
       currency_code,
       currency_conversion_date,
       currency_conversion_rate,
       currency_conversion_type,
       entered_dr,
       entered_cr,
       description,
       accounting_class_code,
       gl_sl_link_id,
       gl_sl_link_table,
       party_type_code,
       party_id,
       party_site_id,
       statistical_amount,
       ussgl_transaction_code,
       jgzz_recon_ref,
       control_balance_flag,
       analytical_balance_flag,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_update_date,
       program_id,
       program_application_id,
       request_id,
       gain_or_loss_flag,
       accounting_date,
       ledger_id
      )
  VALUES
   (   batch_id,
       ae_header_id,
       line_num+max_line_num,
       222,
       code_combination_id,
       'D',                             --gl transfer mode Summary or detail
       acctd_amount_dr,
       acctd_amount_cr,
       currency_code,
       exchange_date,
       exchange_rate,
       exchange_type,
       amount_dr,
       amount_cr,
       '',                             --description TBD
       nvl(account_class,'XXXX'),      --accounting class code
       sl_link_id,    --gl sl link id
       'XLAJEL',                       --gl sl link table
       DECODE(third_party_id, NULL, NULL, 'C'), --party type code
       third_party_id,                 --party id
       third_party_sub_id,             --third party site
       '',                             --statistical amount
       '',                             --ussgl trx code
       '',                             --jgzz recon ref
       '',                             --control balance flag
       '',                             --analytical balance
       sysdate,                        --row who columns
       -2005,
       sysdate,
       -2005,
       -2005,
       sysdate,
       -2005,                           --program id
       222,
       '',                              --request id
       'Y',
       accounting_date,
       ledger_id)
   WHEN 1 = 1 THEN
   INTO XLA_DISTRIBUTION_LINKS
      (APPLICATION_ID,
       EVENT_ID,
       AE_HEADER_ID,
       AE_LINE_NUM,
       ACCOUNTING_LINE_CODE,
       ACCOUNTING_LINE_TYPE_CODE,
       REF_AE_HEADER_ID,
--       REF_AE_LINE_NUM,
       SOURCE_DISTRIBUTION_TYPE,
       SOURCE_DISTRIBUTION_ID_CHAR_1,
       SOURCE_DISTRIBUTION_ID_CHAR_2,
       SOURCE_DISTRIBUTION_ID_CHAR_3,
       SOURCE_DISTRIBUTION_ID_CHAR_4,
       SOURCE_DISTRIBUTION_ID_CHAR_5,
       SOURCE_DISTRIBUTION_ID_NUM_1,
       SOURCE_DISTRIBUTION_ID_NUM_2,
       SOURCE_DISTRIBUTION_ID_NUM_3,
       SOURCE_DISTRIBUTION_ID_NUM_4,
       SOURCE_DISTRIBUTION_ID_NUM_5,
       UNROUNDED_ENTERED_DR,
       UNROUNDED_ENTERED_CR,
       UNROUNDED_ACCOUNTED_DR,
       UNROUNDED_ACCOUNTED_CR,
       MERGE_DUPLICATE_CODE,
       TAX_LINE_REF_ID,
       TAX_SUMMARY_LINE_REF_ID,
       TAX_REC_NREC_DIST_REF_ID,
       STATISTICAL_AMOUNT,
       TEMP_LINE_NUM,
       EVENT_TYPE_CODE,
       EVENT_CLASS_CODE,
       REF_EVENT_ID,
       UPG_BATCH_ID)
    VALUES
      (222,
       event_id,
       ae_header_id,
       line_num+max_line_num,
       account_class,
       'C',  --accounting line code customer
       ref_header_id, --reference header id
--       '', --reference line number
       source_table,
       '', --src dist id char
       '',
       '',
       '',
       '',
       line_id, --src dist id num
       '',
       '',
       '',
       '',
       amount_dr,
       amount_cr,
       acctd_amount_dr,
       acctd_amount_cr,
       'N',         --merge dup code
       tax_line_id, --tax_line_ref_id
       '',         --tax_summary_line_ref_id
       '',         --tax_rec_nrec_dist_ref_id
       '',         --statistical amount
       line_num+max_line_num,   --temp_line_num
       event_type_code, --event_type_code
       event_class_code, --event class code
       '',         --ref_event_id,
       batch_id)   --upgrade batch id
   select
       l_batch_id                   AS batch_id,
       ae_header_id                 AS ae_header_id,
       line_id                      AS line_id,
       event_id                     AS event_id,
       account_class                AS account_class,
       source_table                 AS source_table,
       code_combination_id          AS code_combination_id,
       amount_dr                    AS amount_dr,
       amount_cr                    AS amount_cr,
       acctd_amount_dr              AS acctd_amount_dr,
       acctd_amount_cr              AS acctd_amount_cr,
       nvl(currency_code,'XXXX')    AS currency_code,
       third_party_id               AS third_party_id,
       third_party_sub_id           AS third_party_sub_id,
       exchange_date                AS exchange_date,
       exchange_rate                AS exchange_rate,
       exchange_type                AS exchange_type,
       tax_line_id                  AS tax_line_id,
       sob_id                       AS sob_id,
       event_type_code              AS event_type_code,
       event_class_code             AS event_class_code,
       sl_link_id                   AS sl_link_id,
       ref_header_id                AS ref_header_id,
       max_line_num                 AS max_line_num,
       accounting_date              AS accounting_date,
       ledger_id                    AS ledger_id,
       RANK() OVER (PARTITION BY event_id, ae_header_id, sob_id
                    ORDER BY line_id, ln_order) AS line_num
FROM
(select /*+ ordered rowid(cr) use_nl(rec,app,ra,dist,dist1,dl,lin,lin1,hdr) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(LIN,XLA_AE_LINES_U1) index(LIN1,XLA_AE_LINES_U1) index(HDR,XLA_AE_HEADERS_U1) */
        hdr.ae_header_id                                      ae_header_id,
        hdr.event_id                                          event_id,
        dist.set_of_books_id                                  sob_id,
        dist.source_type                                      account_class,
        'AR_DISTRIBUTIONS_ALL'                                source_table,
        dist.code_combination_id                              code_combination_id,
        dist.amount_dr                                        amount_dr,
        dist.amount_cr                                        amount_cr,
        dist.acctd_amount_dr                                  acctd_amount_dr,
        dist.acctd_amount_cr                                  acctd_amount_cr,
        dist.currency_code                                    currency_code,
        dist.third_party_id                                   third_party_id,
        dist.third_party_sub_id                               third_party_sub_id,
        dist.currency_conversion_date                         exchange_date,
        dist.currency_conversion_rate                         exchange_rate,
        dist.currency_conversion_type                         exchange_type,
        dist.line_id                                          line_id,
        null                                                  tax_line_id,
	dl.event_type_code                                    event_type_code,
        dl.event_class_code                                   event_class_code,
	lin.gl_sl_link_id                                     sl_link_id,
	dl.ref_ae_header_id                                   ref_header_id,
	lin1.ae_line_num                                      max_line_num,
        hdr.accounting_date                                   accounting_date,
        hdr.ledger_id                                         ledger_id,
        1                                                     ln_order
--
from ar_mc_cash_receipts cr,
     ar_cash_receipts_all rec,
     ar_receivable_applications_all app,
     xla_upgrade_dates gps,
     ar_mc_receivable_apps ra,
     ar_mc_distributions_all dist,
     ar_mc_distributions_all dist1,
     xla_distribution_links dl,
     xla_ae_lines lin,
     xla_ae_lines lin1,
     xla_ae_headers hdr
--
where cr.rowid >= l_start_rowid
and cr.rowid <= l_end_rowid
--
and rec.cash_receipt_id = cr.cash_receipt_id
and NVL(rec.ax_accounted_flag,'N') = 'N'
--
and app.cash_receipt_id = cr.cash_receipt_id
and app.application_type = 'CASH'
and app.status = 'APP'
--
and trunc(app.gl_date) between gps.start_date and gps.end_date
and gps.ledger_id  = cr.set_of_books_id
--
and ra.receivable_application_id = app.receivable_application_id
and ra.posting_control_id <> -3
and ra.set_of_books_id = cr.set_of_books_id
--
and dist.source_id = ra.receivable_application_id
and dist.set_of_books_id = ra.set_of_books_id
and dist.source_table = 'RA'
and dist.source_type in ('EXCH_GAIN','EXCH_LOSS','CURR_ROUND')
and not exists (select  'X'
                  from ar_distributions_all
		  where source_id = dist.source_id
		  and source_table = 'RA'
		  and source_type = dist.source_type)
--
and dist1.source_id = dist.source_id
and dist1.set_of_books_id = dist.set_of_books_id
and dist1.source_table = 'RA'
and dist1.source_type = 'REC'
--
and dl.source_distribution_id_num_1 = dist1.line_id
and dl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
and dl.application_id = 222
and dl.upg_batch_id = l_batch_id
and dl.accounting_line_code = 'REC'
--
and lin.ae_header_id = dl.ae_header_id
and lin.ae_line_num = dl.ae_line_num
and lin.application_id = 222
and lin.upg_batch_id = l_batch_id
--
and lin1.ae_header_id = lin.ae_header_id
and lin1.ae_line_num = (select max(ae_line_num)
                       from xla_ae_lines
                       where ae_header_id = lin1.ae_header_id
                       and application_id = 222
                       and upg_batch_id = l_batch_id)
and lin1.application_id = 222
and lin1.upg_batch_id = l_batch_id
--
and hdr.ae_header_id = lin.ae_header_id
and hdr.application_id = 222
and hdr.upg_batch_id = l_batch_id
and hdr.ledger_id = dist.set_of_books_id
);

l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

ELSIF (l_table_name = 'RA_MC_CUSTOMER_TRX') THEN

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO XLA_AE_LINES
      (upg_batch_id,
       ae_header_id,
       ae_line_num,
       application_id,
       code_combination_id,
       gl_transfer_mode_code,
       accounted_dr,
       accounted_cr,
       currency_code,
       currency_conversion_date,
       currency_conversion_rate,
       currency_conversion_type,
       entered_dr,
       entered_cr,
       description,
       accounting_class_code,
       gl_sl_link_id,
       gl_sl_link_table,
       party_type_code,
       party_id,
       party_site_id,
       statistical_amount,
       ussgl_transaction_code,
       jgzz_recon_ref,
       control_balance_flag,
       analytical_balance_flag,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_update_date,
       program_id,
       program_application_id,
       request_id,
       gain_or_loss_flag,
       accounting_date,
       ledger_id
      )
  VALUES
   (   batch_id,
       ae_header_id,
       line_num+max_line_num,
       222,
       code_combination_id,
       'D',                             --gl transfer mode Summary or detail
       acctd_amount_dr,
       acctd_amount_cr,
       currency_code,
       exchange_date,
       exchange_rate,
       exchange_type,
       amount_dr,
       amount_cr,
       '',                             --description TBD
       nvl(account_class,'XXXX'),      --accounting class code
       sl_link_id,    --gl sl link id
       'XLAJEL',                       --gl sl link table
       DECODE(third_party_id, NULL, NULL, 'C'), --party type code
       third_party_id,                 --party id
       third_party_sub_id,             --third party site
       '',                             --statistical amount
       '',                             --ussgl trx code
       '',                             --jgzz recon ref
       '',                             --control balance flag
       '',                             --analytical balance
       sysdate,                        --row who columns
       -2005,
       sysdate,
       -2005,
       -2005,
       sysdate,
       -2005,                           --program id
       222,
       '',                              --request id
       'Y',
       accounting_date,
       ledger_id)
   WHEN 1 = 1 THEN
   INTO XLA_DISTRIBUTION_LINKS
      (APPLICATION_ID,
       EVENT_ID,
       AE_HEADER_ID,
       AE_LINE_NUM,
       ACCOUNTING_LINE_CODE,
       ACCOUNTING_LINE_TYPE_CODE,
       REF_AE_HEADER_ID,
--       REF_AE_LINE_NUM,
       SOURCE_DISTRIBUTION_TYPE,
       SOURCE_DISTRIBUTION_ID_CHAR_1,
       SOURCE_DISTRIBUTION_ID_CHAR_2,
       SOURCE_DISTRIBUTION_ID_CHAR_3,
       SOURCE_DISTRIBUTION_ID_CHAR_4,
       SOURCE_DISTRIBUTION_ID_CHAR_5,
       SOURCE_DISTRIBUTION_ID_NUM_1,
       SOURCE_DISTRIBUTION_ID_NUM_2,
       SOURCE_DISTRIBUTION_ID_NUM_3,
       SOURCE_DISTRIBUTION_ID_NUM_4,
       SOURCE_DISTRIBUTION_ID_NUM_5,
       UNROUNDED_ENTERED_DR,
       UNROUNDED_ENTERED_CR,
       UNROUNDED_ACCOUNTED_DR,
       UNROUNDED_ACCOUNTED_CR,
       MERGE_DUPLICATE_CODE,
       TAX_LINE_REF_ID,
       TAX_SUMMARY_LINE_REF_ID,
       TAX_REC_NREC_DIST_REF_ID,
       STATISTICAL_AMOUNT,
       TEMP_LINE_NUM,
       EVENT_TYPE_CODE,
       EVENT_CLASS_CODE,
       REF_EVENT_ID,
       UPG_BATCH_ID)
    VALUES
      (222,
       event_id,
       ae_header_id,
       line_num+max_line_num,
       account_class,
       'C',  --accounting line code customer
       ref_header_id, --reference header id
--       '', --reference line number
       source_table,
       '', --src dist id char
       '',
       '',
       '',
       '',
       line_id, --src dist id num
       '',
       '',
       '',
       '',
       amount_dr,
       amount_cr,
       acctd_amount_dr,
       acctd_amount_cr,
       'N',         --merge dup code
       tax_line_id, --tax_line_ref_id
       '',         --tax_summary_line_ref_id
       '',         --tax_rec_nrec_dist_ref_id
       '',         --statistical amount
       line_num+max_line_num,   --temp_line_num
       event_type_code, --event_type_code
       event_class_code, --event class code
       '',         --ref_event_id,
       batch_id)   --upgrade batch id
   select
       l_batch_id                   AS batch_id,
       ae_header_id                 AS ae_header_id,
       line_id                      AS line_id,
       event_id                     AS event_id,
       account_class                AS account_class,
       source_table                 AS source_table,
       code_combination_id          AS code_combination_id,
       amount_dr                    AS amount_dr,
       amount_cr                    AS amount_cr,
       acctd_amount_dr              AS acctd_amount_dr,
       acctd_amount_cr              AS acctd_amount_cr,
       nvl(currency_code,'XXXX')    AS currency_code,
       third_party_id               AS third_party_id,
       third_party_sub_id           AS third_party_sub_id,
       exchange_date                AS exchange_date,
       exchange_rate                AS exchange_rate,
       exchange_type                AS exchange_type,
       tax_line_id                  AS tax_line_id,
       sob_id                       AS sob_id,
       event_type_code              AS event_type_code,
       event_class_code             AS event_class_code,
       sl_link_id                   AS sl_link_id,
       ref_header_id                AS ref_header_id,
       max_line_num                 AS max_line_num,
       accounting_date              AS accounting_date,
       ledger_id                    AS ledger_id,
       RANK() OVER (PARTITION BY event_id, ae_header_id, sob_id
                    ORDER BY line_id, ln_order) AS line_num
FROM
(select /*+ ordered rowid(ct) use_nl(trx,app,ra,dist,dist1,dl,lin,lin1,hdr) use_hash(gps) swap_join_inputs(gps)
            index(DL,XLA_DISTRIBUTION_LINKS_N1) index(LIN,XLA_AE_LINES_U1) index(LIN1,XLA_AE_LINES_U1) index(HDR,XLA_AE_HEADERS_U1) */
        hdr.ae_header_id                                      ae_header_id,
        hdr.event_id                                          event_id,
        dist.set_of_books_id                                  sob_id,
        dist.source_type                                      account_class,
        'AR_DISTRIBUTIONS_ALL'                                source_table,
        dist.code_combination_id                              code_combination_id,
        dist.amount_dr                                        amount_dr,
        dist.amount_cr                                        amount_cr,
        dist.acctd_amount_dr                                  acctd_amount_dr,
        dist.acctd_amount_cr                                  acctd_amount_cr,
        dist.currency_code                                    currency_code,
        dist.third_party_id                                   third_party_id,
        dist.third_party_sub_id                               third_party_sub_id,
        dist.currency_conversion_date                         exchange_date,
        dist.currency_conversion_rate                         exchange_rate,
        dist.currency_conversion_type                         exchange_type,
        dist.line_id                                          line_id,
        null                                                  tax_line_id,
	dl.event_type_code                                    event_type_code,
        dl.event_class_code                                   event_class_code,
	lin.gl_sl_link_id                                     sl_link_id,
	dl.ref_ae_header_id                                   ref_header_id,
	lin1.ae_line_num                                      max_line_num,
        hdr.accounting_date                                   accounting_date,
        hdr.ledger_id                                         ledger_id,
        1                                                     ln_order
--
from ra_mc_customer_trx ct,
     ra_customer_trx_all trx,
     ar_receivable_applications_all app,
     xla_upgrade_dates gps,
     ar_mc_receivable_apps ra,
     ar_mc_distributions_all dist,
     ar_mc_distributions_all dist1,
     xla_distribution_links dl,
     xla_ae_lines lin,
     xla_ae_lines lin1,
     xla_ae_headers hdr
--
where ct.rowid >= l_start_rowid
and ct.rowid <= l_end_rowid
--
and trx.customer_trx_id = ct.customer_trx_id
and NVL(trx.ax_accounted_flag,'N') = 'N'
--
and app.customer_trx_id = ct.customer_trx_id
and app.application_type = 'CM'
and app.status = 'APP'
--
and trunc(app.gl_date) between gps.start_date and gps.end_date
and gps.ledger_id  = ct.set_of_books_id
--
and ra.receivable_application_id = app.receivable_application_id
and ra.posting_control_id <> -3
and ra.set_of_books_id = ct.set_of_books_id
--
and dist.source_id = ra.receivable_application_id
and dist.set_of_books_id = ra.set_of_books_id
and dist.source_table = 'RA'
and dist.source_type in ('EXCH_GAIN','EXCH_LOSS','CURR_ROUND')
and not exists (select  'X'
                  from ar_distributions_all
		  where source_id = dist.source_id
		  and source_table = 'RA'
		  and source_type = dist.source_type)
--
and dist1.source_id = dist.source_id
and dist1.set_of_books_id = dist.set_of_books_id
and dist1.source_table = 'RA'
and dist1.source_type = 'REC'
and dist1.amount_dr is null
--
and dl.source_distribution_id_num_1 = dist1.line_id
and dl.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
and dl.application_id = 222
and dl.upg_batch_id = l_batch_id
and dl.accounting_line_code = 'REC'
--
and lin.ae_header_id = dl.ae_header_id
and lin.ae_line_num = dl.ae_line_num
and lin.application_id = 222
and lin.upg_batch_id = l_batch_id
--
and lin1.ae_header_id = lin.ae_header_id
and lin1.ae_line_num = (select max(ae_line_num)
                       from xla_ae_lines
                       where ae_header_id = lin1.ae_header_id
                       and application_id = 222
                       and upg_batch_id = l_batch_id)
and lin1.application_id = 222
and lin1.upg_batch_id = l_batch_id
--
and hdr.ae_header_id = lin.ae_header_id
and hdr.application_id = 222
and hdr.upg_batch_id = l_batch_id
and hdr.ledger_id = dist.set_of_books_id
);

l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

commit;

END IF;  /* If l_table */

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: ARP_MRC_XLA_UPGRADE.upgrade_mc_gain_loss');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: ARP_MRC_XLA_UPGRADE.upgrade_mc_gain_loss');
    RAISE;

END UPGRADE_MC_GAIN_LOSS;

END ARP_MRC_XLA_UPGRADE;

/
