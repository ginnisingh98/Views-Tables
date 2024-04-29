--------------------------------------------------------
--  DDL for Package Body ARP_XLA_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_XLA_UPGRADE" AS
/* $Header: ARXLAUPB.pls 120.34.12010000.7 2009/08/18 09:15:29 aghoraka ship $ */

PROCEDURE UPGRADE_TRANSACTIONS(
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

-------------------------------------------------------------------
-- Create the transaction entities
-- Created by ar120ent.sql
-------------------------------------------------------------------

-------------------------------------------------------------------
-- Create the Journal Entry Events and Headers for transactions
-- category definitions can be found in argper.lpc function arguje
-------------------------------------------------------------------
IF NVL(l_entity_type,'E') = 'E' THEN

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO XLA_EVENTS
      (upg_batch_id,
       upg_source_application_id,
       application_id,
       reference_num_1,
       reference_num_2,
       event_type_code,
       event_number,
       event_status_code,
       process_status_code,
       on_hold_flag,
       event_date,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_update_date,
       program_id,
       program_application_id,
       request_id,
       entity_id,
       event_id,
       upg_valid_flag,
       transaction_date)
      VALUES
      (batch_id,
       222,
       222,
      pst_id,            --reference num 1
      trx_id,            --reference num 2
      override_event,    --event type
      line_num,
      trx_status,        --event status code I, U, N, P
      pstd_flg,           --process status
      'N',
      gl_date,      --event date
      sysdate,      --creation_date
      0,        --created_by
      sysdate,  --last_update_date
      0,        --last_updated_by
      0,        --last_updated_login
      sysdate,
      0,        --program_id
      222,
      '',
      entity_id,
      xla_events_s.nextval,
      'Y',                 --upgrade flag
      trx_date
      )
   WHEN PST_ID <> -3 THEN
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
    encumbrance_type_id,
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
   )
   VALUES
   (batch_id,
    222,
    222,
   'DEFAULT',               --amb context code
   entity_id,
   xla_events_s.nextval,
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
   '',                      --encumbrance type id
   '',                      --completed date
  doc_seq_id,
  doc_seq_val,
  cat_code,
  '',                       --packet id
  '',                       --group id
  sysdate,                  --row who creation date
  0,                    --created_by
  sysdate,
  0,
  0,
  sysdate,
  0,                    --program id
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
 select /*+ use_nl(lgr,map) */
       l_batch_id AS BATCH_ID,
       decode(trx_type,
       'CM', 'Credit Memos',
       'DM', 'Debit Memos',
       'CB', 'Chargebacks',
       'Sales Invoices')  AS CATEGORY,
       ev.TRX_ID          AS TRX_ID,
       ev.TRX_DATE        AS TRX_DATE,
       ev.SOB_ID          AS SOB_ID,
       ev.CAT_CODE        AS CAT_CODE,
       ev.TRX_TYPE        AS TRX_TYPE,
       ev.TRX_STATUS      AS TRX_STATUS,
       ev.OVERRIDE_EVENT  AS OVERRIDE_EVENT,
       ev.PSTD_FLG        AS PSTD_FLG,
       ev.PST_ID          AS PST_ID,
       ev.GL_DATE         AS GL_DATE,
       max(ev.GL_POSTED_DATE)  AS GL_POSTED_DATE,
       ev.DOC_SEQ_ID      AS DOC_SEQ_ID,
       ev.DOC_SEQ_VAL     AS DOC_SEQ_VAL,
       ev.ENTITY_ID       AS ENTITY_ID,
       map.PERIOD_NAME    AS PERIOD_NAME,
       decode(l_action_flag,'D',0,
        (select nvl(max(in_ev.event_number),0)
         from xla_events in_ev                       /*bug 5867069*/
         where in_ev.entity_id = ev.entity_id and in_ev.application_id=222)) + RANK() OVER (PARTITION BY ev.ENTITY_ID
                    ORDER BY decode(ev.OVERRIDE_EVENT,
                                    ev.TRX_TYPE||'_CREATE',1,
                                    ev.TRX_TYPE||'_UPDATE',2,
                                    3), ev.GL_DATE, decode(EV.PST_ID,
                                                           -3, 2,
                                                            1), EV.PST_ID) AS LINE_NUM
FROM
(select /*+ ordered rowid(ct) use_nl(ctlgd,ctlgd1,te) use_hash(gps) swap_join_inputs(gps) use_hash(sys,tty) swap_join_inputs(tty) swap_join_inputs(sys) INDEX(te xla_transaction_entities_N1) */
        ct.customer_trx_id                                                  TRX_ID         ,
        ct.trx_date                                                         TRX_DATE       ,
        ct.set_of_books_id                                                  SOB_ID         ,
        tty.type                                                            TRX_TYPE       ,
        decode(sys.accounting_method,
               'CASH', 'N',
               decode(tty.post_to_gl,
                      'N', 'N',
                      decode(ct.complete_flag,
                             'Y',decode(ctlgd.posting_control_id,
                                        -3, 'U',
                                        'P'),
                             'I')))                                         TRX_STATUS     ,
        decode(nvl(trunc(ctlgd.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
               nvl(trunc(ctlgd1.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                  decode(ctlgd.posting_control_id,
                         ctlgd1.posting_control_id,  tty.type || '_CREATE',
                         tty.type || '_UPDATE'),
               tty.type || '_UPDATE')                                       OVERRIDE_EVENT ,
        decode(ctlgd.posting_control_id,
               -3, 'U',
               'P')                                                         PSTD_FLG       ,
        ctlgd.posting_control_id                                            PST_ID         ,
        nvl(trunc(ctlgd.gl_date),to_date('01-01-1900','DD-MM-YYYY'))        GL_DATE        ,
        nvl(trunc(max(ctlgd.gl_posted_date)),to_date('01-01-1900','DD-MM-YYYY')) GL_POSTED_DATE ,
        ct.doc_sequence_id                                                  DOC_SEQ_ID     ,
        ct.doc_sequence_value                                               DOC_SEQ_VAL    ,
        tty.name                                                            CAT_CODE       ,
        te.entity_id                                                        ENTITY_ID
       FROM
            ra_customer_trx_all          ct,
            ra_cust_trx_line_gl_dist_all ctlgd,
            xla_upgrade_dates   gps,
            ar_system_parameters_all     sys,
       	    ra_cust_trx_types_all        tty,
            ra_cust_trx_line_gl_dist_all ctlgd1,
            xla_transaction_entities_upg te
       WHERE  ct.rowid >= l_start_rowid
        AND   ct.rowid <= l_end_rowid
        AND   NVL(ct.ax_accounted_flag,'N') = 'N'
        AND   ctlgd.customer_trx_id = ct.customer_trx_id
        and   ctlgd.event_id is null
        AND decode(ctlgd.account_class,
                     'REC',ctlgd.latest_rec_flag,
                     'Y')              = 'Y'
        AND DECODE(ctlgd.account_set_flag,
                   'N','N',
                   'Y', decode(ctlgd.account_class,
                               'REC','N',
                               'Y')
                  ) = 'N'
        and   trunc(ctlgd.gl_date) between gps.start_date and gps.end_date
        and   gps.ledger_id  = ct.set_of_books_id
        and   decode(ctlgd.posting_control_id,
                     -3, decode(l_action_flag,
                                'D','P',
                                l_action_flag),
                                'P') = 'P'
        AND   sys.org_id = ct.org_id
        AND   ct.cust_trx_type_id   = tty.cust_trx_type_id
        AND   tty.org_id = ct.org_id
        AND   ctlgd1.customer_trx_id = ct.customer_trx_id
        AND   ctlgd1.latest_rec_flag = 'Y'
        AND   ctlgd1.account_class  = 'REC'
        AND   te.application_id = 222
        AND   te.ledger_id = ct.set_of_books_id
        AND   te.entity_code = 'TRANSACTIONS'
        AND   nvl(te.source_id_int_1,-99) = ct.customer_trx_id
        --AND   te.upg_batch_id = l_batch_id
       GROUP BY
          ct.customer_trx_id,
          ct.trx_date,
          ct.set_of_books_id,
          te.entity_id,
          tty.type,
          decode(sys.accounting_method,
                 'CASH', 'N',
                 decode(tty.post_to_gl,
                      'N', 'N',
                      decode(ct.complete_flag,
                             'Y',decode(ctlgd.posting_control_id,
                                        -3, 'U',
                                        'P'),
                             'I'))),
          ct.org_id,
          decode(nvl(trunc(ctlgd.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                 nvl(trunc(ctlgd1.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                    decode(ctlgd.posting_control_id,
                           ctlgd1.posting_control_id,  tty.type || '_CREATE',
                           tty.type || '_UPDATE'),
                 tty.type || '_UPDATE') ,
          ctlgd.posting_control_id,
          nvl(trunc(ctlgd.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
          ct.doc_sequence_id,
          ct.doc_sequence_value,
          tty.name
    UNION
        select /*+ ordered rowid(ct) use_nl(app,ctlgd,te) use_hash(gps) swap_join_inputs(gps) use_hash(sys,tty) swap_join_inputs(tty) swap_join_inputs(sys) INDEX(te xla_transaction_entities_N1) */
                ct.customer_trx_id                                          TRX_ID         ,
                ct.trx_date                                                 TRX_DATE       ,
                ct.set_of_books_id                                          SOB_ID         ,
        tty.type                                                            TRX_TYPE       ,
        decode(sys.accounting_method,
               'CASH', decode(ct.previous_customer_trx_id,
                              '', decode(ct.complete_flag,
                                         'Y',decode(app.posting_control_id,
                                                    -3, 'U',
                                                    'P'),
                                         'I'),
                              'N'),
               decode(tty.post_to_gl,
                      'N', 'N',
                      decode(ct.complete_flag,
                           'Y',decode(app.posting_control_id,
                                      -3, 'U',
                                      'P'),
                           'I')))                                           TRX_STATUS     ,
        decode(nvl(trunc(app.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
               nvl(trunc(ctlgd.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
               decode(sys.accounting_method,
                      'CASH', 'CM_UPDATE',
                      decode(app.posting_control_id,
                             ctlgd.posting_control_id, 'CM_CREATE',
                             'CM_UPDATE')),
               'CM_UPDATE')                                                  OVERRIDE_EVENT ,
        decode(app.posting_control_id,
               -3, 'U',
               'P')                                                          PSTD_FLG       ,
        app.posting_control_id                                               PST_ID         ,
        nvl(trunc(app.gl_date),to_date('01-01-1900','DD-MM-YYYY'))           GL_DATE        ,
        nvl(trunc(max(app.gl_posted_date)),to_date('01-01-1900','DD-MM-YYYY'))    GL_POSTED_DATE ,
        ct.doc_sequence_id                                                   DOC_SEQ_ID     ,
        ct.doc_sequence_value                                                DOC_SEQ_VAL    ,
        tty.name                                                             CAT_CODE       ,
        te.entity_id                                                         ENTITY_ID
       FROM ra_customer_trx_all            ct,
       	    ar_receivable_applications_all app,
            xla_upgrade_dates     gps,
            ar_system_parameters_all       sys,
            ra_cust_trx_types_all          tty,
            ra_cust_trx_line_gl_dist_all   ctlgd,
            xla_transaction_entities_upg   te
       WHERE ct.rowid >= l_start_rowid
         AND ct.rowid <= l_end_rowid
         AND NVL(ct.ax_accounted_flag,'N') = 'N'
         AND app.application_type = 'CM'
         AND app.status = 'APP'
         AND app.customer_trx_id = ct.customer_trx_id
         and app.event_id is null
         and trunc(app.gl_date) between gps.start_date and gps.end_date
         and gps.ledger_id  = ct.set_of_books_id
         and decode(app.posting_control_id,
                     -3, decode(l_action_flag,
                                'D','P',
                                l_action_flag),
                                'P') = 'P'
         AND sys.org_id = ct.org_id
         AND ct.cust_trx_type_id   = tty.cust_trx_type_id
         AND tty.org_id = ct.org_id
         AND ctlgd.customer_trx_id = ct.customer_trx_id
         AND ctlgd.latest_rec_flag = 'Y'
         AND ctlgd.account_class  = 'REC'
         AND te.application_id = 222
         AND te.ledger_id = ct.set_of_books_id
         AND te.entity_code = 'TRANSACTIONS'
         AND nvl(te.source_id_int_1,-99) = ct.customer_trx_id
         --AND te.upg_batch_id = l_batch_id
       GROUP BY
          ct.customer_trx_id,
          ct.trx_date,
          ct.set_of_books_id,
          te.entity_id,
          tty.type,
        decode(sys.accounting_method,
               'CASH', decode(ct.previous_customer_trx_id,
                              '', decode(ct.complete_flag,
                                         'Y',decode(app.posting_control_id,
                                                    -3, 'U',
                                                    'P'),
                                         'I'),
                              'N'),
               decode(tty.post_to_gl,
                      'N', 'N',
                      decode(ct.complete_flag,
                           'Y',decode(app.posting_control_id,
                                      -3, 'U',
                                      'P'),
                           'I'))),
          ct.org_id,
          decode(nvl(trunc(app.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                 nvl(trunc(ctlgd.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                 decode(sys.accounting_method,
                        'CASH', 'CM_UPDATE',
                        decode(app.posting_control_id,
                               ctlgd.posting_control_id, 'CM_CREATE',
                               'CM_UPDATE')),
                 'CM_UPDATE'),
          app.posting_control_id,
          nvl(trunc(app.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
          ct.doc_sequence_id,
          ct.doc_sequence_value,
          tty.name) ev,
          gl_ledgers lgr,
          gl_date_period_map map
  where ev.sob_id = lgr.ledger_id
  and   map.period_set_name = lgr.period_set_name
  and   map.period_type = lgr.accounted_period_type
  and   map.accounting_date = ev.gl_date
  --AND per.adjustment_period_flag = 'N'
  group by decode(trx_type,
       'CM', 'Credit Memos',
       'DM', 'Debit Memos',
       'CB', 'Chargebacks',
       'Sales Invoices')  ,
       ev.TRX_ID          ,
       ev.TRX_DATE        ,
       ev.SOB_ID          ,
       ev.CAT_CODE        ,
       ev.TRX_TYPE        ,
       ev.TRX_STATUS      ,
       ev.OVERRIDE_EVENT  ,
       ev.PSTD_FLG        ,
       ev.PST_ID          ,
       ev.GL_DATE         ,
       ev.DOC_SEQ_ID      ,
       ev.DOC_SEQ_VAL     ,
       ev.ENTITY_ID       ,
       map.PERIOD_NAME     ;

    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

END IF; --create events

-------------------------------------------------------------------
-- Create the Journal Entry Lines
-- gl_transfer_mode_code is a flag indicating whether distributions
-- from AR to subledger tables are in detail or summary. This is
-- different from the standard post to GL summary or detail. So
--from an upgrade perspective for AR this is in detail always
--as AR stores in detailed accounting for historical data.
-------------------------------------------------------------------
IF NVL(l_entity_type,'L') = 'L' THEN

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
       DECODE(third_party_id, NULL, NULL,'C'), --party type code
       third_party_id,                 --party id
       third_party_sub_id,             --third party site
       '',                             --statistical amount
       '',                             --ussgl trx code
       '',                             --jgzz recon ref
       '',                             --control balance flag
       '',                             --analytical balance
       sysdate,                        --row who columns
       0,
       sysdate,
       0,
       0,
       sysdate,
       0,                           --program id
       222,
       '',                              --request id
       gain_or_loss_flag,
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
       line_num,
       account_class,
       'C',  --accounting line code customer
       ae_header_id, --reference header id
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
       l_batch_id AS batch_id,
       ae_header_id AS ae_header_id,
       line_id AS line_id,
       event_id AS event_id,
       account_class AS account_class,
       source_table AS source_table,
       code_combination_id AS code_combination_id,
       amount_dr AS amount_dr,
       amount_cr AS amount_cr,
       acctd_amount_dr AS acctd_amount_dr,
       acctd_amount_cr AS acctd_amount_cr,
       nvl(currency_code,'XXX') AS currency_code,
       third_party_id AS third_party_id,
       third_party_sub_id AS third_party_sub_id,
       exchange_date AS exchange_date,
       exchange_rate AS exchange_rate,
       exchange_type AS exchange_type,
       tax_line_id AS tax_line_id,
       gain_or_loss_flag AS gain_or_loss_flag,
       event_type_code AS event_type_code,
       event_class_code AS event_class_code,
       accounting_date AS accounting_date,
       ledger_id AS ledger_id,
       RANK() OVER (PARTITION BY event_id, ae_header_id
                    ORDER BY line_id, ln_order) AS line_num
FROM
(select /*+ ordered rowid(ct) use_nl(ctlgd,ent,ev,hdr,ctl) use_hash(gps) swap_join_inputs(gps) INDEX(ent xla_transaction_entities_N1) INDEX(ev XLA_EVENTS_U2) INDEX(hdr XLA_AE_HEADERS_N2)  */
         hdr.ae_header_id                                      ae_header_id,
         decode(account_class, 'REC',    'RECEIVABLE',
                               'REV',    'REVENUE',
                               'UNEARN', 'UNEARNED_REVENUE',
                               'ROUND',  'ROUNDING',
                               ctlgd.account_class)            account_class,
         'RA_CUST_TRX_LINE_GL_DIST_ALL'                        source_table,
         ctlgd.code_combination_id                             code_combination_id,
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
         ct.invoice_currency_code                              currency_code,
         ct.bill_to_customer_id                                third_party_id,
         ct.bill_to_site_use_id                                third_party_sub_id,
         ct.exchange_date                                      exchange_date,
         ct.exchange_rate                                      exchange_rate,
         ct.exchange_rate_type                                 exchange_type,
         ctlgd.cust_trx_line_gl_dist_id                        line_id,
         ev.event_id                                           event_id,
         ev.event_type_code                                    event_type_code,
         decode(ev.event_type_code,
                'INV_CREATE', 'INVOICE',
                'INV_UPDATE', 'INVOICE',
                'CM_CREATE' , 'CREDIT_MEMO',
                'CM_UPDATE' , 'CREDIT_MEMO',
                'DM_CREATE' , 'DEBIT_MEMO',
                'DM_UPDATE' , 'DEBIT_MEMO',
                'CB_CREATE' , 'CHARGEBACK',
                'DEP_CREATE', 'DEPOSIT',
                'DEP_UPDATE', 'DEPOSIT',
                'GUAR_CREATE','GUARANTEE',
                'GUAR_UPDATE','GUARANTEE',
                'UNKNOWN')                                     event_class_code,
         ctl.tax_line_id                                       tax_line_id,
         'N'                                                   gain_or_loss_flag,
         hdr.accounting_date                                   accounting_date,
         hdr.ledger_id                                         ledger_id,
         1                                                     ln_order
   from
        ra_customer_trx_all ct,
        ra_cust_trx_line_gl_dist_all ctlgd,
        xla_upgrade_dates gps,
        xla_transaction_entities_upg ent,
        xla_events ev,
        xla_ae_headers hdr,
        ra_customer_trx_lines_all ctl
   where ct.rowid >= l_start_rowid
   and ct.rowid <= l_end_rowid
   and NVL(ct.ax_accounted_flag,'N') = 'N'
   and ct.customer_trx_id = ctlgd.customer_trx_id
   and ctlgd.account_set_flag = 'N'
   and trunc(ctlgd.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = ct.set_of_books_id
   and ent.application_id = 222
   and ent.ledger_id = ct.set_of_books_id
   and ent.entity_code = 'TRANSACTIONS'
   and nvl(ent.source_id_int_1,-99) = ct.customer_trx_id
   and ent.entity_id = ev.entity_id
   and ev.application_id = 222
   and ev.upg_batch_id = l_batch_id
   and ctlgd.posting_control_id = ev.reference_num_1
   and nvl(trunc(ctlgd.gl_date), to_date('01-01-1900','DD-MM-YYYY')) = ev.event_date
   and hdr.application_id = 222
   and hdr.event_id = ev.event_id
   and ct.set_of_books_id = hdr.ledger_id
   and ctlgd.customer_trx_line_id = ctl.customer_trx_line_id (+)
   UNION ALL  /* CM applications */
   select /*+ ordered rowid(ct) use_nl(app,ent,ev,hdr,ard) use_hash(gps) swap_join_inputs(gps) INDEX(ent xla_transaction_entities_N1) INDEX(ev XLA_EVENTS_U2) INDEX(hdr XLA_AE_HEADERS_N2)  */
        hdr.ae_header_id                                      ae_header_id,
        DECODE(ard.source_type, 'REC','RECEIVABLE',
            ard.source_type)                                  account_class,
        'AR_DISTRIBUTIONS_ALL'                                source_table,
        ard.code_combination_id                               code_combination_id,
        ard.amount_dr                                         amount_dr,
        ard.amount_cr                                         amount_cr,
        ard.acctd_amount_dr                                   acctd_amount_dr,
        ard.acctd_amount_cr                                   acctd_amount_cr,
        ard.currency_code                                     currency_code,
        ard.third_party_id                                    third_party_id,
        ard.third_party_sub_id                                third_party_sub_id,
        ard.currency_conversion_date                          exchange_date,
        ard.currency_conversion_rate                          exchange_rate,
        ard.currency_conversion_type                          exchange_type,
        ard.line_id                                           line_id,
        ev.event_id                                           event_id,
        ev.event_type_code                                    event_type_code,
        'CREDIT_MEMO'                                         event_class_code,
        null                                                  tax_line_id,
        decode(ard.source_type,
               'EXCH_GAIN','Y',
               'EXCH_LOSS','Y',
               'N')                                           gain_or_loss_flag,
        hdr.accounting_date                                   accounting_date,
        hdr.ledger_id                                         ledger_id,
        2                                                     ln_order
   from ra_customer_trx_all ct,
        ar_receivable_applications_all app,
        xla_upgrade_dates gps,
        xla_transaction_entities_upg ent,
        xla_events ev,
        xla_ae_headers hdr,
        ar_distributions_all ard
   where ct.rowid >= l_start_rowid
   and ct.rowid <= l_end_rowid
   and NVL(ct.ax_accounted_flag,'N') = 'N'
   and ct.customer_trx_id = app.customer_trx_id
   and trunc(app.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = ct.set_of_books_id
   and ent.application_id = 222
   and ent.ledger_id = ct.set_of_books_id
   and ent.entity_code = 'TRANSACTIONS'
   and nvl(ent.source_id_int_1,-99) = ct.customer_trx_id
   and ent.entity_id = ev.entity_id
   and ev.application_id = 222
   and ev.upg_batch_id = l_batch_id
   and app.posting_control_id = ev.reference_num_1
   and nvl(trunc(app.gl_date), to_date('01-01-1900','DD-MM-YYYY')) = ev.event_date
   and hdr.application_id = 222
   and ct.set_of_books_id = hdr.ledger_id
   and hdr.event_id = ev.event_id
   and ard.source_id = app.receivable_application_id
   and ard.source_table = 'RA');
   --order by entity_id,  ae_header_id, line_num;

   l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

END IF; --create lines

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
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: ARP_XLA_UPGRADE.upgrade_transactions');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: ARP_XLA_UPGRADE.upgrade_transactions');
    RAISE;

END UPGRADE_TRANSACTIONS;

PROCEDURE UPGRADE_BILLS_RECEIVABLE(
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

-------------------------------------------------------------------
-- Create the br entities
-- Created by ar120ent.sql
-------------------------------------------------------------------

/*------------------------------------------------------------------------------+
 | Create the BR events                                                         |
 +------------------------------------------------------------------------------*/
IF NVL(l_entity_type,'E') = 'E' THEN

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO XLA_EVENTS
      (upg_batch_id,
       upg_source_application_id,
       application_id,
       reference_num_1,
       reference_num_2,
       event_type_code,
       event_number,
       event_status_code,
       process_status_code,
       on_hold_flag,
       event_date,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_update_date,
       program_id,
       program_application_id,
       request_id,
       entity_id,
       event_id,
       upg_valid_flag,
       transaction_date)
      VALUES
      (batch_id,
       222,
       222,
      pst_id,            --reference num 1
      trx_id,            --reference num 2
      override_event,    --event type
      line_num,
      trx_status,        --event status code I, U, N, P
      pstd_flg,           --process status
      'N',
      gl_date,      --event date
      sysdate,
      0,
      sysdate,
      0,
      0,
      sysdate,
      0,
      222,
      '',
      entity_id,
      xla_events_s.nextval,
      'Y',                 --upgrade flag
      trx_date
      )
   WHEN PST_ID <> -3 THEN
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
    encumbrance_type_id,
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
   )
   VALUES
   (batch_id,
    222,
    222,
   'DEFAULT',               --amb context code
   entity_id,
   xla_events_s.nextval,
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
   '',                      --encumbrance type id
   '',                      --completed date
  doc_seq_id,
  doc_seq_val,
  cat_code,
  '',                       --packet id
  '',                       --group id
  sysdate,                  --row who creation date
  0,
  sysdate,
  0,
  0,
  sysdate,
  0,                    --program id
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
 select /*+ use_nl(lgr,map) */
       l_batch_id AS BATCH_ID,
       decode(trx_type,
       'CM', 'Credit Memos',
       'DM', 'Debit Memos',
       'CB', 'Chargebacks',
       'Sales Invoices')  AS CATEGORY,
       ev.TRX_ID          AS TRX_ID,
       ev.TRX_DATE        AS TRX_DATE,
       ev.SOB_ID          AS SOB_ID,
       ev.CAT_CODE        AS CAT_CODE,
       ev.TRX_TYPE        AS TRX_TYPE,
       ev.TRX_STATUS      AS TRX_STATUS,
       ev.OVERRIDE_EVENT  AS OVERRIDE_EVENT,
       ev.PSTD_FLG        AS PSTD_FLG,
       ev.PST_ID          AS PST_ID,
       ev.GL_DATE         AS GL_DATE,
       max(ev.GL_POSTED_DATE)  AS GL_POSTED_DATE,
       ev.DOC_SEQ_ID      AS DOC_SEQ_ID,
       ev.DOC_SEQ_VAL     AS DOC_SEQ_VAL,
       ev.ENTITY_ID       AS ENTITY_ID,
       map.PERIOD_NAME     AS PERIOD_NAME,
       decode(l_action_flag,'D',0,
       (select nvl(max(in_ev.event_number),0)
         from xla_events in_ev           /*bug 5867069*/
         where in_ev.entity_id = ev.entity_id and in_ev.application_id=222)) + RANK() OVER (PARTITION BY ev.ENTITY_ID
                    ORDER BY decode(ev.OVERRIDE_EVENT,
                                    ev.TRX_TYPE||'_CREATE',1,
                                    ev.TRX_TYPE||'_UPDATE',2,
                                    3), ev.GL_DATE, decode(EV.PST_ID,
                                                           -3, 2,
                                                            1), EV.PST_ID) AS LINE_NUM
FROM
(select  /*+ ordered rowid(ct) use_nl(trh,trh1,te) use_hash(gps) swap_join_inputs(gps) use_hash(sys,tty) swap_join_inputs(tty) swap_join_inputs(sys) INDEX(te xla_transaction_entities_N1) */
        ct.customer_trx_id                                                  TRX_ID         ,
        ct.trx_date                                                         TRX_DATE       ,
        ct.set_of_books_id                                                  SOB_ID         ,
        tty.type                                                            TRX_TYPE       ,
        decode(sys.accounting_method,
               'CASH', 'N',
               decode(tty.post_to_gl,
                     'N', 'N',
                     decode(ct.complete_flag,
                            'Y',decode(trh.posting_control_id,
                                       -3,decode(trh.status,
                                                 'INCOMPLETE', 'I',
                                                 'PENDING_ACCEPTANCE','I',
                                                 'U'),
                                       'P'),
                            'I')))                                          TRX_STATUS    ,
        decode(trh.event,
               'INCOMPLETE'  , 'BILL_CREATE',
               'ACCEPTED'    , 'BILL_CREATE',
               'COMPLETED'    , decode(trh.status,
                                        'PENDING_ACCEPTANCE', 'BILL_CREATE',
                                        'PENDING_REMITTANCE', 'BILL_CREATE',
                                        'NO_EVENT'),
               'CANCELLED'   , 'BILL_REVERSE',
               decode(trh1.first_posted_record_flag,
                      '', 'BILL_CREATE',
                      decode(nvl(trunc(trh.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                             nvl(trunc(trh1.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                                 decode(trh.posting_control_id,
                                        trh1.posting_control_id, 'BILL_CREATE',
                                        'BILL_UPDATE'),
                             'BILL_UPDATE')))                               OVERRIDE_EVENT,
        decode(trh.posting_control_id,
               -3, 'U',
               'P')                                                         PSTD_FLG       ,
        trh.posting_control_id                                              PST_ID         ,
        nvl(trunc(trh.gl_date),to_date('01-01-1900','DD-MM-YYYY'))          GL_DATE        ,
        nvl(trunc(max(trh.gl_posted_date)),to_date('01-01-1900','DD-MM-YYYY'))   GL_POSTED_DATE ,
        ct.doc_sequence_id                                                  DOC_SEQ_ID     ,
        ct.doc_sequence_value                                               DOC_SEQ_VAL    ,
        tty.name                                                            CAT_CODE       ,
        te.entity_id                                                        ENTITY_ID
       FROM ra_customer_trx_all ct,
            ar_transaction_history_all trh,
            xla_upgrade_dates gps,
            ar_transaction_history_all trh1,
            ar_system_parameters_all sys,
            ra_cust_trx_types_all tty,
            xla_transaction_entities_upg te
       WHERE ct.rowid >= l_start_rowid
       AND ct.rowid <= l_end_rowid
       AND NVL(ct.ax_accounted_flag,'N') = 'N'
       AND ct.customer_trx_id = trh.customer_trx_id
       and trh.event_id is null
       and trunc(trh.gl_date) between gps.start_date and gps.end_date
       and gps.ledger_id  = ct.set_of_books_id
       and decode(trh.posting_control_id,
                  -3, decode(l_action_flag,
                             'D','P',
                             l_action_flag),
                             'P') = 'P'
       AND ct.customer_trx_id = trh1.customer_trx_id (+)
       AND 'Y' = trh1.first_posted_record_flag (+)
       AND decode(trh.event,
                  'INCOMPLETE', decode(trh1.first_posted_record_flag,'','Y',
                                       'N'),
                  'COMPLETED',  decode(trh.status,
                                       'PENDING_ACCEPTANCE',
                                           decode(trh1.first_posted_record_flag,
                                                  '','Y',
                                                  'N'),
                                       trh.postable_flag),
                  trh.postable_flag) = 'Y'
       AND sys.org_id = ct.org_id
       AND ct.cust_trx_type_id = tty.cust_trx_type_id
       AND ct.org_id = tty.org_id
       AND te.application_id = 222
       AND te.ledger_id = ct.set_of_books_id
       AND te.entity_code = 'BILLS_RECEIVABLE'
       AND nvl(te.source_id_int_1,-99) = ct.customer_trx_id
       --AND te.upg_batch_id = l_batch_id
       GROUP BY
          ct.customer_trx_id,
          ct.trx_date,
          ct.set_of_books_id,
          te.entity_id,
          tty.type,
          decode(sys.accounting_method,
                 'CASH', 'N',
                 decode(tty.post_to_gl,
                        'N', 'N',
                        decode(ct.complete_flag,
                               'Y',decode(trh.posting_control_id,
                                          -3,decode(trh.status,
                                                    'INCOMPLETE', 'I',
                                                    'PENDING_ACCEPTANCE','I',
                                                    'U'),
                                          'P'),
                               'I'))) ,
          ct.org_id,
          decode(trh.event,
               'INCOMPLETE'  , 'BILL_CREATE',
               'ACCEPTED'    , 'BILL_CREATE',
               'COMPLETED'    , decode(trh.status,
                                        'PENDING_ACCEPTANCE', 'BILL_CREATE',
                                        'PENDING_REMITTANCE', 'BILL_CREATE',
                                        'NO_EVENT'),
               'CANCELLED'   , 'BILL_REVERSE',
               decode(trh1.first_posted_record_flag,
                      '', 'BILL_CREATE',
                      decode(nvl(trunc(trh.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                             nvl(trunc(trh1.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                                 decode(trh.posting_control_id,
                                        trh1.posting_control_id, 'BILL_CREATE',
                                        'BILL_UPDATE'),
                             'BILL_UPDATE'))),
          trh.posting_control_id,
          nvl(trunc(trh.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
          ct.doc_sequence_id,
          ct.doc_sequence_value,
          tty.name) ev,
          gl_ledgers lgr,
          gl_date_period_map map
  where ev.sob_id = lgr.ledger_id
  and   map.period_set_name = lgr.period_set_name
  and   map.period_type = lgr.accounted_period_type
  and   map.accounting_date = ev.gl_date
  --AND per.adjustment_period_flag = 'N'
  group by decode(trx_type,
       'CM', 'Credit Memos',
       'DM', 'Debit Memos',
       'CB', 'Chargebacks',
       'Sales Invoices')  ,
       ev.TRX_ID          ,
       ev.TRX_DATE        ,
       ev.SOB_ID          ,
       ev.CAT_CODE        ,
       ev.TRX_TYPE        ,
       ev.TRX_STATUS      ,
       ev.OVERRIDE_EVENT  ,
       ev.PSTD_FLG        ,
       ev.PST_ID          ,
       ev.GL_DATE         ,
       ev.DOC_SEQ_ID      ,
       ev.DOC_SEQ_VAL     ,
       ev.ENTITY_ID       ,
       map.PERIOD_NAME     ;

   l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

END IF; --create events

/*--------------------------------------------------------------------------+
 | Insert the BR lines                                                      |
 +--------------------------------------------------------------------------*/
IF NVL(l_entity_type,'L') = 'L' THEN

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
       DECODE(third_party_id, NULL, NULL,'C'),   --party type code
       third_party_id,                 --party id
       third_party_sub_id,             --third party site
       '',                             --statistical amount
       '',                             --ussgl trx code
       '',                             --jgzz recon ref
       '',                             --control balance flag
       '',                             --analytical balance
       sysdate,                        --row who columns
       0,
       sysdate,
       0,
       0,
       sysdate,
       0,                           --program id
       222,
       '',                              --request id
       gain_or_loss_flag,
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
       line_num,
       account_class,
       'C',  --accounting line code customer
       ae_header_id, --reference header id
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
       l_batch_id AS batch_id,
       ae_header_id AS ae_header_id,
       line_id AS line_id,
       event_id AS event_id,
       account_class AS account_class,
       source_table AS source_table,
       code_combination_id AS code_combination_id,
       amount_dr AS amount_dr,
       amount_cr AS amount_cr,
       acctd_amount_dr AS acctd_amount_dr,
       acctd_amount_cr AS acctd_amount_cr,
       nvl(currency_code,'XXX') AS currency_code,
       third_party_id AS third_party_id,
       third_party_sub_id AS third_party_sub_id,
       exchange_date AS exchange_date,
       exchange_rate AS exchange_rate,
       exchange_type AS exchange_type,
       tax_line_id AS tax_line_id,
       gain_or_loss_flag AS gain_or_loss_flag,
       event_type_code AS event_type_code,
       event_class_code AS event_class_code,
       accounting_date AS accounting_date,
       ledger_id AS ledger_id,
       RANK() OVER (PARTITION BY event_id, ae_header_id
                    ORDER BY line_id, ln_order) AS line_num
FROM
(  select /*+ ordered rowid(ct) use_nl(trh,ent,ev,hdr,ard) use_hash(gps) swap_join_inputs(gps) INDEX(ent xla_transaction_entities_N1) INDEX(ev XLA_EVENTS_U2) INDEX(hdr XLA_AE_HEADERS_N2)  */
           hdr.ae_header_id                                      ae_header_id,
           decode(ard.source_type, 'FACTOR',    'FAC_BR',
                                   'REMITTANCE','REM_BR',
                                   'REC',       'BILL_REC',
                                   'UNPAIDREC', 'UNPAID_BR',
                                    ard.source_type)             account_class,
           'AR_DISTRIBUTIONS_ALL'                                source_table,
           ard.code_combination_id                               code_combination_id,
           ard.amount_dr                                         amount_dr,
           ard.amount_cr                                         amount_cr,
           ard.acctd_amount_dr                                   acctd_amount_dr,
           ard.acctd_amount_cr                                   acctd_amount_cr,
           ard.currency_code                                     currency_code,
           ard.third_party_id                                    third_party_id,
           ard.third_party_sub_id                                third_party_sub_id,
           ard.currency_conversion_date                          exchange_date,
           ard.currency_conversion_rate                          exchange_rate,
           ard.currency_conversion_type                          exchange_type,
           ard.line_id                                           line_id,
           hdr.event_id                                          event_id,
           ev.event_type_code                                    event_type_code,
           'BILL'                                                event_class_code,
           null                                                  tax_line_id,
           'N'                                                   gain_or_loss_flag,
           hdr.accounting_date                                   accounting_date,
           hdr.ledger_id                                         ledger_id,
           1                                                     ln_order
   from ra_customer_trx_all ct,
        ar_transaction_history_all trh,
        xla_upgrade_dates gps,
        xla_transaction_entities_upg ent,
        xla_events ev,
        xla_ae_headers hdr,
        ar_distributions_all ard
   where ct.rowid >= l_start_rowid
   and ct.rowid <= l_end_rowid
   and NVL(ct.ax_accounted_flag,'N') = 'N'
   and ct.customer_trx_id = trh.customer_trx_id
   and trunc(trh.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = ct.set_of_books_id
   and ent.application_id = 222
   and ent.ledger_id = ct.set_of_books_id
   and ent.entity_code = 'BILLS_RECEIVABLE'
   and nvl(ent.source_id_int_1,-99) = ct.customer_trx_id
   and ent.entity_id = ev.entity_id
   and ev.application_id = 222
   and ev.upg_batch_id = l_batch_id
   and trh.posting_control_id = ev.reference_num_1
   and nvl(trunc(trh.gl_date), to_date('01-01-1900','DD-MM-YYYY')) = ev.event_date
   AND decode(trh.event,
              'INCOMPLETE', 'Y',
              'COMPLETED', decode(trh.status,
                                  'PENDING_ACCEPTANCE','Y',
                                  trh.postable_flag),
              trh.postable_flag) = 'Y'
   AND decode(trh.event,
              'CANCELLED', 'BILL_REVERSE',
                  ev.event_type_code) = ev.event_type_code
   and hdr.application_id = 222
   and ct.set_of_books_id = hdr.ledger_id
   and hdr.event_id = ev.event_id
   and ard.source_id = trh.transaction_history_id
   and ard.source_table = 'TH');
   --order by entity_id,  ae_header_id, line_num;

   l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

END IF; --create lines

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
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: ARP_XLA_UPGRADE.upgrade_bills_receivable');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: ARP_XLA_UPGRADE.upgrade_bills_receivable');
    RAISE;

END UPGRADE_BILLS_RECEIVABLE;


PROCEDURE UPGRADE_RECEIPTS(
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

-------------------------------------------------------------------
-- Create the Entities
-- Created by ar120recent.sql
-------------------------------------------------------------------

-------------------------------------------------------------------
-- Create the Journal Entry Events and Headers
-- category definitions can be found in argper.lpc function arguje
-------------------------------------------------------------------
IF NVL(l_entity_type,'E') = 'E' THEN

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO XLA_EVENTS
      (upg_batch_id,
       upg_source_application_id,
       application_id,
       reference_num_1,
       reference_num_2,
       event_type_code,
       event_number,
       event_status_code,
       process_status_code,
       on_hold_flag,
       event_date,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_update_date,
       program_id,
       program_application_id,
       request_id,
       entity_id,
       event_id,
       upg_valid_flag,
       transaction_date)
      VALUES
      (batch_id,
       222,
       222,
      pst_id,            --reference num 1
      trx_id,            --reference num 2
      override_event,    --event type
      line_num,
      trx_status,        --event status code I, U, N, P
      pstd_flg,           --process status
      'N',
      gl_date,      --event date
      sysdate,
      0,
      sysdate,
      0,
      0,
      sysdate,
      0,
      222,
      '',
      entity_id,
      xla_events_s.nextval,
      'Y',                  --upgrade flag
      trx_date
      )
   WHEN PST_ID <> -3 THEN
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
    encumbrance_type_id,
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
   )
   VALUES
   (batch_id,
    222,
    222,
   'DEFAULT',               --amb context code
   entity_id,
   xla_events_s.nextval,
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
   '',                      --encumbrance type id
   '',                      --completed date
  doc_seq_id,
  doc_seq_val,
  cat_code,
  '',                       --packet id
  '',                       --group id
  sysdate,                  --row who creation date
  0,
  sysdate,
  0,
  0,
  sysdate,
  0,                    --program id
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
 select /*+ use_nl(lgr,map) */
       l_batch_id     AS BATCH_ID,
       decode(trx_type,
              'CASH'       , 'Trade Receipts',
              --'CROSS_CURR' , 'Cross Currency',
              'MISC'       , 'Misc Receipts',
              'RATE_ADJUST', 'Rate Adjustments',
              trx_type)   AS CATEGORY,
       ev.TRX_ID          AS TRX_ID,
       ev.TRX_DATE        AS TRX_DATE,
       ev.SOB_ID          AS SOB_ID,
       ev.CAT_CODE        AS CAT_CODE,
       ev.TRX_TYPE        AS TRX_TYPE,
       ev.TRX_STATUS      AS TRX_STATUS,
       ev.OVERRIDE_EVENT  AS OVERRIDE_EVENT,
       ev.PSTD_FLG        AS PSTD_FLG,
       ev.PST_ID          AS PST_ID,
       ev.GL_DATE         AS GL_DATE,
       max(ev.GL_POSTED_DATE)  AS GL_POSTED_DATE,
       ev.DOC_SEQ_ID      AS DOC_SEQ_ID,
       ev.DOC_SEQ_VAL     AS DOC_SEQ_VAL,
       ev.ENTITY_ID       AS ENTITY_ID,
       map.PERIOD_NAME    AS PERIOD_NAME,
       decode(l_action_flag,'D',0,
        (select nvl(max(in_ev.event_number),0)
         from xla_events in_ev                      /*bug5867069*/
         where in_ev.entity_id = ev.entity_id and in_ev.application_id=222)) + RANK() OVER (PARTITION BY ev.ENTITY_ID
                    ORDER BY decode(ev.OVERRIDE_EVENT,
                                    'RECP_CREATE'          ,1,
                                    'RECP_UPDATE'          ,2,
                                    'RECP_RATE_ADJUST'     ,3,
                                    'RECP_REVERSE'         ,6,
                                    'MISC_RECP_CREATE'     ,7,
                                    'MISC_RECP_UPDATE'     ,8,
                                    'MISC_RECP_RATE_ADJUST',9,
                                    'MISC_RECP_REVERSE'    ,12,
                                    13), EV.GL_DATE, decode(EV.PST_ID,
                                                            -3, 2,
                                                            1), EV.PST_ID) LINE_NUM
FROM
(select /*+ ordered rowid(cr) use_nl(crh,rmth,crh1,te) use_hash(gps) swap_join_inputs(gps) INDEX(te xla_transaction_entities_N1) INDEX_SS(crh1 ar_cash_receipt_history_n1) */
        cr.cash_receipt_id                            TRX_ID        ,
        cr.receipt_date                               TRX_DATE      ,
        cr.set_of_books_id                            SOB_ID        ,

        decode(crh.created_from,
               'RATE ADJUSTMENT TRIGGER', 'RATE_ADJUST',
               cr.type)                               TRX_TYPE      ,
        decode(crh.status,
               'APPROVED', 'I',
               decode(crh.posting_control_id,
                      -3, 'U',
                      'P'))                           TRX_STATUS    ,
        decode(cr.type,
               'MISC', 'MISC_',
               '') ||
        decode(crh.created_from,
               'RATE ADJUSTMENT TRIGGER', 'RECP_RATE_ADJUST',
               decode(crh.status,
                      'REVERSED','RECP_REVERSE',
                      decode(crh1.first_posted_record_flag,
                             '', 'RECP_CREATE',
                             decode(decode(crh.postable_flag,
                                           'N', to_date('01-01-1900','DD-MM-YYYY'),
                                           nvl(trunc(crh.gl_date),to_date('01-01-1900','DD-MM-YYYY'))),
                                    nvl(trunc(crh1.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                                    decode(crh.posting_control_id,
                                           crh1.posting_control_id, 'RECP_CREATE',
                                           'RECP_UPDATE'),
                                    'RECP_UPDATE')))) OVERRIDE_EVENT,
        decode(crh.posting_control_id,
               -3, 'U',
               'P')                                   PSTD_FLG       ,
        crh.posting_control_id                        PST_ID          ,
        nvl(trunc(crh.gl_date),to_date('01-01-1900','DD-MM-YYYY')) GL_DATE,
        nvl(trunc(max(crh.gl_posted_date)),to_date('01-01-1900','DD-MM-YYYY'))  GL_POSTED_DATE ,
        cr.doc_sequence_id                            DOC_SEQ_ID     ,
        cr.doc_sequence_value                         DOC_SEQ_VAL    ,
        rmth.name                                     CAT_CODE       ,
        te.entity_id                                  ENTITY_ID
 FROM ar_cash_receipts_all cr,
      --ar_system_parameters_all sys,
      ar_cash_receipt_history_all crh,
      xla_upgrade_dates gps,
      ar_receipt_methods rmth,
      ar_cash_receipt_history_all crh1,
      xla_transaction_entities_upg te
 WHERE cr.rowid >= l_start_rowid
 AND cr.rowid <= l_end_rowid
 AND NVL(cr.ax_accounted_flag,'N') = 'N'
 AND crh.cash_receipt_id = cr.cash_receipt_id
 and crh.event_id is null
 and trunc(crh.gl_date) between gps.start_date and gps.end_date
 and gps.ledger_id  = cr.set_of_books_id
 and decode(crh.posting_control_id,
            -3, decode(l_action_flag,
                       'D','P',
                       l_action_flag),
                       'P') = 'P'
 AND cr.receipt_method_id = rmth.receipt_method_id
 AND cr.cash_receipt_id = crh1.cash_receipt_id (+)
 AND 'Y' = crh1.first_posted_record_flag (+)
 AND te.application_id = 222
 AND te.ledger_id = cr.set_of_books_id
 AND te.entity_code = 'RECEIPTS'
 AND nvl(te.source_id_int_1,-99) = cr.cash_receipt_id
 AND decode(crh.postable_flag, 'Y','Y',
            decode(crh.status, 'APPROVED',
                   decode(crh1.first_posted_record_flag, '','Y',
                          'N'),
                   'N')) = 'Y'
 --AND te.upg_batch_id = l_batch_id
 --AND nvl(sys.org_id,-9999) = nvl(ct.org_id, -9999)
 --AND sys.accounting_method = 'ACCRUAL'
 GROUP BY cr.cash_receipt_id,
          cr.receipt_date,
          cr.set_of_books_id,
          te.entity_id,
          crh.postable_flag,
          decode(crh.created_from,
                 'RATE ADJUSTMENT TRIGGER', 'RATE_ADJUST',
                 cr.type),
          decode(crh.status,
                 'APPROVED', 'I',
                 decode(crh.posting_control_id,
                        -3, 'U',
                        'P')),
          cr.org_id,
          decode(cr.type,
                 'MISC', 'MISC_',
                 '') || decode(crh.created_from,
              'RATE ADJUSTMENT TRIGGER', 'RECP_RATE_ADJUST',
               decode(crh.status,
                      'REVERSED','RECP_REVERSE',
                      decode(crh1.first_posted_record_flag,
                             '', 'RECP_CREATE',
                             decode(decode(crh.postable_flag,
                                           'N', to_date('01-01-1900','DD-MM-YYYY'),
                                           nvl(trunc(crh.gl_date),to_date('01-01-1900','DD-MM-YYYY'))),
                                    nvl(trunc(crh1.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                                    decode(crh.posting_control_id,
                                           crh1.posting_control_id, 'RECP_CREATE',
                                           'RECP_UPDATE'),
                                    'RECP_UPDATE')))),
          decode(crh.posting_control_id,
                 -3, 'U',
                 'P')                                   ,
          crh.posting_control_id,
          nvl(trunc(crh.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
          cr.doc_sequence_id,
          cr.doc_sequence_value,
          rmth.name
UNION
  select /*+ ordered rowid(cr) use_nl(mcd,rmth,crh,te) use_hash(gps) swap_join_inputs(gps) INDEX(te xla_transaction_entities_N1) INDEX_SS(crh ar_cash_receipt_history_n1) */
        mcd.cash_receipt_id                           TRX_ID         ,
        cr.receipt_date                               TRX_DATE       ,
        cr.set_of_books_id                            SOB_ID         ,
        decode(mcd.created_from,
               'RATE ADJUSTMENT TRIGGER', 'RATE_ADJUST',
               cr.type)                               TRX_TYPE      ,
        decode(mcd.posting_control_id,
               -3, 'U',
               'P')                                   TRX_STATUS     ,
        decode(mcd.created_from,
               'RATE ADJUSTMENT TRIGGER', 'MISC_RECP_RATE_ADJUST',
               decode(SUBSTRB(mcd.created_from,1,19),
                      'ARP_REVERSE_RECEIPT','MISC_RECP_REVERSE',
                      decode(nvl(trunc(crh.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                             nvl(trunc(mcd.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                             decode(crh.posting_control_id,
                                    mcd.posting_control_id, 'MISC_RECP_CREATE',
                                    'MISC_RECP_UPDATE'),
                             'MISC_RECP_UPDATE')))  OVERRIDE_EVENT,
        decode(mcd.posting_control_id,
               -3, 'U',
               'P')                                   PSTD_FLG       ,
        mcd.posting_control_id                        PST_ID          ,
        nvl(trunc(mcd.gl_date),to_date('01-01-1900','DD-MM-YYYY'))   GL_DATE,
        nvl(trunc(max(mcd.gl_posted_date)),to_date('01-01-1900','DD-MM-YYYY'))  GL_POSTED_DATE ,
        cr.doc_sequence_id                            DOC_SEQ_ID     ,
        cr.doc_sequence_value                         DOC_SEQ_VAL    ,
        rmth.name                                     CAT_CODE       ,
        te.entity_id                                  ENTITY_ID
  FROM ar_cash_receipts_all cr,
       --ar_system_parameters_all sys,
       ar_misc_cash_distributions_all mcd,
       xla_upgrade_dates gps,
       ar_receipt_methods rmth,
       ar_cash_receipt_history_all crh,
       xla_transaction_entities_upg te
  WHERE cr.rowid >= l_start_rowid
  AND cr.rowid <= l_end_rowid
  AND NVL(cr.ax_accounted_flag,'N') = 'N'
  AND cr.type='MISC'
  AND mcd.cash_receipt_id = cr.cash_receipt_id
  and trunc(mcd.gl_date) between gps.start_date and gps.end_date
  and mcd.event_id is null
  and gps.ledger_id  = cr.set_of_books_id
  and decode(mcd.posting_control_id,
            -3, decode(l_action_flag,
		       'D','P',
		       l_action_flag),
            'P') = 'P'
  AND cr.receipt_method_id = rmth.receipt_method_id
  AND cr.cash_receipt_id = crh.cash_receipt_id
  AND crh.first_posted_record_flag = 'Y'
  AND te.application_id = 222
  AND te.ledger_id = cr.set_of_books_id
  AND te.entity_code = 'RECEIPTS'
  AND nvl(te.source_id_int_1,-99) = cr.cash_receipt_id
  --AND te.upg_batch_id = l_batch_id
  --AND nvl(sys.org_id,-9999) = nvl(cr.org_id, -9999)
  --AND sys.accounting_method = 'ACCRUAL'
 GROUP BY mcd.cash_receipt_id,
          cr.receipt_date,
          cr.set_of_books_id,
          te.entity_id,
          'Y',
          decode(mcd.created_from,
                 'RATE ADJUSTMENT TRIGGER', 'RATE_ADJUST',
                 cr.type),
          decode(mcd.posting_control_id,
                 -3, 'U',
                 'P'),
          mcd.org_id,
          decode(mcd.created_from,
               'RATE ADJUSTMENT TRIGGER', 'MISC_RECP_RATE_ADJUST',
               decode(SUBSTRB(mcd.created_from,1,19),
                      'ARP_REVERSE_RECEIPT','MISC_RECP_REVERSE',
                      decode(nvl(trunc(crh.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                             nvl(trunc(mcd.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                             decode(crh.posting_control_id,
                                    mcd.posting_control_id, 'MISC_RECP_CREATE',
                                    'MISC_RECP_UPDATE'),
                             'MISC_RECP_UPDATE'))),
         decode(mcd.posting_control_id,
                -3, 'U',
                'P')                                   ,
         mcd.posting_control_id,
         nvl(trunc(mcd.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
         cr.doc_sequence_id,
         cr.doc_sequence_value,
         rmth.name
UNION
select /*+ ordered rowid(cr) use_nl(app,crh,crh1,rmth,te) use_hash(gps) swap_join_inputs(gps) INDEX(te xla_transaction_entities_N1)  INDEX_SS(crh1 ar_cash_receipt_history_n1) */
        cr.cash_receipt_id                            TRX_ID         ,
        cr.receipt_date                               TRX_DATE       ,
        cr.set_of_books_id                            SOB_ID         ,
        decode(crh.created_from,
               'RATE ADJUSTMENT TRIGGER', 'RATE_ADJUST',
               cr.type)                               TRX_TYPE      ,
        decode(NVL(app.confirmed_flag,'Y'),
               'Y', decode(app.posting_control_id,
                           -3, 'U',
                           'P'),
               'I')                                   TRX_STATUS     ,
        decode(crh.created_from,
               'RATE ADJUSTMENT TRIGGER', 'RECP_RATE_ADJUST',
               decode(crh.status,
                      'REVERSED','RECP_REVERSE',
                      decode(crh1.first_posted_record_flag,
                             '', 'RECP_CREATE',
                             decode(nvl(trunc(app.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                                    nvl(trunc(crh1.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                                    decode(app.posting_control_id,
                                           crh1.posting_control_id, 'RECP_CREATE',
                                           'RECP_UPDATE'),
                                    'RECP_UPDATE')))) OVERRIDE_EVENT,
        decode(app.posting_control_id,
               -3, 'U',
               'P')                                   PSTD_FLG       ,
        app.posting_control_id                        PST_ID          ,
        nvl(trunc(app.gl_date),to_date('01-01-1900','DD-MM-YYYY')) GL_DATE,
        max(decode(crh.created_from,
               'RATE ADJUSTMENT TRIGGER',
                   nvl(trunc((crh.gl_posted_date)),to_date('01-01-1900','DD-MM-YYYY')),
               decode(crh.status,
                  'REVERSED', nvl(trunc((crh.gl_posted_date)),to_date('01-01-1900','DD-MM-YYYY')),
                  nvl(trunc((app.gl_posted_date)),to_date('01-01-1900','DD-MM-YYYY'))))) GL_POSTED_DATE ,
        cr.doc_sequence_id                            DOC_SEQ_ID     ,
        cr.doc_sequence_value                         DOC_SEQ_VAL    ,
        rmth.name                                     CAT_CODE       ,
        te.entity_id                                  ENTITY_ID
FROM ar_cash_receipts_all cr,
     --ar_system_parameters_all sys,
     ar_receivable_applications_all app,
     xla_upgrade_dates gps,
     ar_cash_receipt_history_all crh,
     ar_cash_receipt_history_all crh1,
     ar_receipt_methods rmth,
     xla_transaction_entities_upg te
WHERE cr.rowid >= l_start_rowid
AND cr.rowid <= l_end_rowid
AND NVL(cr.ax_accounted_flag,'N') = 'N'
AND app.cash_receipt_id = cr.cash_receipt_id
AND app.application_type = 'CASH'
and app.event_id is null
and trunc(app.gl_date) between gps.start_date and gps.end_date
and gps.ledger_id  = cr.set_of_books_id
and decode(app.posting_control_id,
            -3, decode(l_action_flag,
                       'D','P',
                       l_action_flag),
                       'P') = 'P'
AND app.cash_receipt_history_id = crh.cash_receipt_history_id
AND cr.cash_receipt_id = crh1.cash_receipt_id (+)
AND 'Y' = crh1.first_posted_record_flag (+)
AND decode(crh.postable_flag, 'Y','Y',
            decode(crh.status, 'APPROVED',
                   decode(crh1.first_posted_record_flag, '','Y',
                          'N'),
                   'N')) = 'Y'
AND cr.receipt_method_id = rmth.receipt_method_id
AND te.application_id = 222
AND te.ledger_id = cr.set_of_books_id
AND te.entity_code = 'RECEIPTS'
AND nvl(te.source_id_int_1,-99) = cr.cash_receipt_id
--AND te.upg_batch_id = l_batch_id
--AND nvl(sys.org_id,-9999) = nvl(cr.org_id, -9999)
--AND sys.accounting_method = 'ACCRUAL'
GROUP BY cr.cash_receipt_id,
        cr.receipt_date,
        cr.set_of_books_id,
        te.entity_id,
        decode(NVL(app.confirmed_flag,'Y'),
               'Y', decode(app.posting_control_id,
                           -3, 'U',
                           'P'),
               'I'),
         decode(crh.created_from,
               'RATE ADJUSTMENT TRIGGER', 'RATE_ADJUST',
                cr.type),
         cr.org_id,
         decode(crh.created_from,
               'RATE ADJUSTMENT TRIGGER', 'RECP_RATE_ADJUST',
               decode(crh.status,
                      'REVERSED','RECP_REVERSE',
                      decode(crh1.first_posted_record_flag,
                             '', 'RECP_CREATE',
                             decode(nvl(trunc(app.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                                    nvl(trunc(crh1.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                                    decode(app.posting_control_id,
                                           crh1.posting_control_id, 'RECP_CREATE',
                                           'RECP_UPDATE'),
                                    'RECP_UPDATE')))),
         decode(app.posting_control_id,
                -3, 'U',
                'P')                                   ,
         app.posting_control_id                             ,
         nvl(trunc(app.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
         cr.doc_sequence_id,
         cr.doc_sequence_value,
         rmth.name) ev,
         gl_ledgers lgr,
         gl_date_period_map map
  where ev.sob_id = lgr.ledger_id
  and   map.period_set_name = lgr.period_set_name
  and   map.period_type = lgr.accounted_period_type
  and   map.accounting_date = ev.gl_date
  group by
       decode(trx_type,
              'CASH'       , 'Trade Receipts',
              --'CROSS_CURR' , 'Cross Currency',
              'MISC'       , 'Misc Receipts',
              'RATE_ADJUST', 'Rate Adjustments',
              trx_type)   ,
       ev.TRX_ID          ,
       ev.TRX_DATE        ,
       ev.SOB_ID          ,
       ev.CAT_CODE        ,
       ev.TRX_TYPE        ,
       ev.TRX_STATUS      ,
       ev.OVERRIDE_EVENT  ,
       ev.PSTD_FLG        ,
       ev.PST_ID          ,
       ev.GL_DATE         ,
       ev.DOC_SEQ_ID      ,
       ev.DOC_SEQ_VAL     ,
       ev.ENTITY_ID       ,
       map.PERIOD_NAME      ;

  l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

END IF; --create events

-------------------------------------------------------------------
-- Create the Journal Entry Lines
-- gl_transfer_mode_code is a flag indicating whether distributions
-- from AR to subledger tables are in detail or summary. This is
-- different from the standard post to GL summary or detail. So
--from an upgrade perspective for AR this is in detail always
--as AR stores in detailed accounting for historical data.
-------------------------------------------------------------------
IF NVL(l_entity_type,'L') = 'L' THEN

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
       DECODE(third_party_id, NULL, NULL,'C'),   --party type code
       third_party_id,                 --party id
       third_party_sub_id,             --third party site
       '',                             --statistical amount
       '',                             --ussgl trx code
       '',                             --jgzz recon ref
       '',                             --control balance flag
       '',                             --analytical balance
       sysdate,                        --row who columns
       0,
       sysdate,
       0,
       0,
       sysdate,
       0,                           --program id
       222,
       '',                              --request id
       gain_or_loss_flag,
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
       line_num,
       account_class,
       'C',  --accounting line code customer
       ae_header_id, --reference header id
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
       'N',        --merge dup code
       '',         --tax_line_ref_id
       '',         --tax_summary_line_ref_id
       '',         --tax_rec_nrec_dist_ref_id
       '',         --statistical amount
       line_num,   --temp_line_num
       event_type_code, --event_type_code
       event_class_code, --event class code
       '',         --ref_event_id,
       batch_id)   --upgrade batch id
   select
       l_batch_id AS batch_id,
       ae_header_id AS ae_header_id,
       line_id AS line_id,
       event_id AS event_id,
       account_class AS account_class,
       gain_or_loss_flag AS gain_or_loss_flag,
       source_table AS source_table,
       code_combination_id AS code_combination_id,
       amount_dr AS amount_dr,
       amount_cr AS amount_cr,
       acctd_amount_dr AS acctd_amount_dr,
       acctd_amount_cr AS acctd_amount_cr,
       nvl(currency_code,'XXX') AS currency_code,
       third_party_id AS third_party_id,
       third_party_sub_id AS third_party_sub_id,
       exchange_date AS exchange_date,
       exchange_rate AS exchange_rate,
       exchange_type AS exchange_type,
       event_type_code AS event_type_code,
       event_class_code AS event_class_code,
       accounting_date AS accounting_date,
       ledger_id AS ledger_id,
       RANK() OVER (PARTITION BY event_id, ae_header_id
                    ORDER BY line_id, ln_order) AS line_num
FROM
( select /*+ ordered rowid(cr) use_nl(crh,crh1,ent,ev,hdr,ard) use_hash(gps) swap_join_inputs(gps) INDEX(ent xla_transaction_entities_N1) INDEX(ev XLA_EVENTS_U2) INDEX(hdr XLA_AE_HEADERS_N2) INDEX_SS(crh1 ar_cash_receipt_history_n1)  */
        hdr.ae_header_id                                      ae_header_id,
        decode(ard.source_type, 'BANK_CHARGES', 'BANK_CHG',
                ard.source_type)                              account_class,
        'AR_DISTRIBUTIONS_ALL'                                source_table,
        ard.code_combination_id                               code_combination_id,
        ard.amount_dr                                         amount_dr,
        ard.amount_cr                                         amount_cr,
        ard.acctd_amount_dr                                   acctd_amount_dr,
        ard.acctd_amount_cr                                   acctd_amount_cr,
        ard.currency_code                                     currency_code,
        ard.third_party_id                                    third_party_id,
        ard.third_party_sub_id                                third_party_sub_id,
        ard.currency_conversion_date                          exchange_date,
        ard.currency_conversion_rate                          exchange_rate,
        ard.currency_conversion_type                          exchange_type,
        ard.line_id                                           line_id,
        ev.event_id                                           event_id,
        ev.event_type_code                                    event_type_code,
        decode(cr.type,
               'CASH','RECEIPT',
               'MISC','MISC_RECEIPT',
               'RECEIPT')                                     event_class_code,
        'N'                                                   gain_or_loss_flag,
        hdr.accounting_date                                   accounting_date,
        hdr.ledger_id                                         ledger_id,
        1                                                     ln_order
   from ar_cash_receipts_all cr,
        ar_cash_receipt_history_all crh,
        xla_upgrade_dates gps,
        ar_cash_receipt_history_all crh1,
        xla_transaction_entities_upg ent,
        xla_events ev,
        xla_ae_headers hdr,
        ar_distributions_all ard
   where cr.rowid >= l_start_rowid
   and cr.rowid <= l_end_rowid
   and nvl(cr.ax_accounted_flag,'N') = 'N'
   and cr.cash_receipt_id = crh.cash_receipt_id
   and trunc(crh.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = cr.set_of_books_id
   and cr.cash_receipt_id = crh1.cash_receipt_id (+)
   and 'Y' = crh1.first_posted_record_flag (+)
   and ent.application_id = 222
   and ent.ledger_id = cr.set_of_books_id
   and ent.entity_code = 'RECEIPTS'
   and nvl(ent.source_id_int_1,-99) = cr.cash_receipt_id
   and ent.entity_id = ev.entity_id
   and ev.application_id = 222
   and ev.upg_batch_id = l_batch_id
   and crh.posting_control_id = ev.reference_num_1
   and nvl(trunc(crh.gl_date), to_date('01-01-1900','DD-MM-YYYY')) = ev.event_date
   and decode(cr.type,
              'MISC','MISC_',
              '') ||
       decode(crh.created_from,
               'RATE ADJUSTMENT TRIGGER', 'RECP_RATE_ADJUST',
               decode(crh.status,
                      'REVERSED','RECP_REVERSE',
                      decode(crh1.first_posted_record_flag,
                             '', 'RECP_CREATE',
                             decode(decode(crh.postable_flag,
                                           'N', to_date('01-01-1900','DD-MM-YYYY'),
                                           nvl(trunc(crh.gl_date),to_date('01-01-1900','DD-MM-YYYY'))),
                                    nvl(trunc(crh1.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                                    decode(crh.posting_control_id,
                                           crh1.posting_control_id, 'RECP_CREATE',
                                           'RECP_UPDATE'),
                                    'RECP_UPDATE')))) = ev.event_type_code
   and decode(crh.postable_flag, 'Y','Y',
              decode(crh.status, 'APPROVED',
                     decode(crh1.first_posted_record_flag, '','Y',
                            'N'),
                     'N')) = 'Y'
   and hdr.application_id = 222
   and cr.set_of_books_id = hdr.ledger_id
   and hdr.event_id = ev.event_id
   and ard.source_id = crh.cash_receipt_history_id
   and ard.source_table = 'CRH'
   UNION ALL  /* Receipt applications */
   select /*+ ordered rowid(cr) use_nl(sys,app,ent,crh,crh1,ev,hdr,ard) use_hash(gps) swap_join_inputs(gps) INDEX(ent xla_transaction_entities_N1) INDEX(ev XLA_EVENTS_U2) INDEX(hdr XLA_AE_HEADERS_N2) INDEX_SS(crh1 ar_cash_receipt_history_n1) */
        hdr.ae_header_id                                      ae_header_id,
        DECODE(ard.source_type, 'REC',        'RECEIVABLE',
                                'CURR_ROUND', 'ROUNDING',
                                'EXCH_GAIN',  'GAIN',
                                'EXCH_LOSS',  'LOSS',
                                'OTHER ACC',
                   DECODE(app.applied_payment_schedule_id,
                              -1,'ACC',
                              -2,'SHORT_TERM_DEBT',
                              -3,'WRITE_OFF',
                              -4,'CLAIM',
                              -5,'CHARGEBACK',
                              -6,'REFUND',
                              -7,'PREPAY',
                              -8,'REFUND',
                              -9,'CHARGEBACK',
                              ard.source_type),
                            ard.source_type)                  account_class,
        'AR_DISTRIBUTIONS_ALL'                                source_table,
        ard.code_combination_id                               code_combination_id,
        ard.amount_dr                                         amount_dr,
        ard.amount_cr                                         amount_cr,
        ard.acctd_amount_dr                                   acctd_amount_dr,
        ard.acctd_amount_cr                                   acctd_amount_cr,
        ard.currency_code                                     currency_code,
        ard.third_party_id                                    third_party_id,
        ard.third_party_sub_id                                third_party_sub_id,
        ard.currency_conversion_date                          exchange_date,
        ard.currency_conversion_rate                          exchange_rate,
        ard.currency_conversion_type                          exchange_type,
        ard.line_id                                           line_id,
        ev.event_id                                           event_id,
        ev.event_type_code                                    event_type_code,
        'RECEIPT'                                             event_class_code,
        decode(ard.source_type,
               'EXCH_GAIN','Y',
               'EXCH_LOSS','Y',
               'N')                                           gain_or_loss_flag,
        hdr.accounting_date                                   accounting_date,
        hdr.ledger_id                                         ledger_id,
        2                                                     ln_order
   from ar_cash_receipts_all cr,
        ar_system_parameters_all sys,
        ar_receivable_applications_all app,
        xla_upgrade_dates gps,
        xla_transaction_entities_upg ent,
        ar_cash_receipt_history_all crh,
        ar_cash_receipt_history_all crh1,
        xla_events ev,
        xla_ae_headers hdr,
        ar_distributions_all ard
   where cr.rowid >= l_start_rowid
   and cr.rowid <= l_end_rowid
   and nvl(cr.ax_accounted_flag,'N') = 'N'
   and nvl(sys.org_id,-9999) = nvl(cr.org_id, -9999)
   and sys.accounting_method = 'ACCRUAL'
   and cr.cash_receipt_id = app.cash_receipt_id
   and app.application_type = 'CASH'
   and trunc(app.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = cr.set_of_books_id
   and app.cash_receipt_history_id = crh.cash_receipt_history_id
   and cr.cash_receipt_id = crh1.cash_receipt_id (+)
   and 'Y' = crh1.first_posted_record_flag (+)
   and ent.application_id = 222
   and ent.ledger_id = cr.set_of_books_id
   and ent.entity_code = 'RECEIPTS'
   and nvl(ent.source_id_int_1,-99) = cr.cash_receipt_id
   and ev.upg_batch_id = l_batch_id
   and ent.entity_id = ev.entity_id
   and ev.application_id = 222
   and app.posting_control_id = ev.reference_num_1
   and nvl(trunc(app.gl_date), to_date('01-01-1900','DD-MM-YYYY')) = ev.event_date
   and decode(crh.created_from,
              'RATE ADJUSTMENT TRIGGER', 'RECP_RATE_ADJUST',
              decode(crh.status,
                      'REVERSED','RECP_REVERSE',
                      decode(crh1.first_posted_record_flag,
                             '', 'RECP_CREATE',
                             decode(nvl(trunc(app.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                                    nvl(trunc(crh1.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                                    decode(app.posting_control_id,
                                           crh1.posting_control_id, 'RECP_CREATE',
                                           'RECP_UPDATE'),
                                    'RECP_UPDATE')))) = ev.event_type_code
   and decode(crh.postable_flag, 'Y','Y',
            decode(crh.status, 'APPROVED',
                   decode(crh1.first_posted_record_flag, '','Y',
                          'N'),
                   'N')) = 'Y'
   and cr.set_of_books_id = hdr.ledger_id
   and hdr.event_id = ev.event_id
   and hdr.application_id = 222
   and ard.source_id = app.receivable_application_id
   and ard.source_table = 'RA'
  UNION ALL  /* Misc Cash Dist */
  select /*+ ordered rowid(cr) use_nl(mcd,crh,ent,ev,hdr,ard) use_hash(gps) swap_join_inputs(gps) INDEX(ent xla_transaction_entities_N1) INDEX(ev XLA_EVENTS_U2) INDEX(hdr XLA_AE_HEADERS_N2) INDEX_SS(crh ar_cash_receipt_history_n1)  */
           hdr.ae_header_id                                      ae_header_id,
           DECODE(ard.source_type, 'MISCCASH', 'MISC_CASH',
                  ard.source_type)                               account_class,
           'AR_DISTRIBUTIONS_ALL'                                source_table,
           ard.code_combination_id                               code_combination_id,
           ard.amount_dr                                         amount_dr,
           ard.amount_cr                                         amount_cr,
           ard.acctd_amount_dr                                   acctd_amount_dr,
           ard.acctd_amount_cr                                   acctd_amount_cr,
           ard.currency_code                                     currency_code,
           ard.third_party_id                                    third_party_id,
           ard.third_party_sub_id                                third_party_sub_id,
           ard.currency_conversion_date                          exchange_date,
           ard.currency_conversion_rate                          exchange_rate,
           ard.currency_conversion_type                          exchange_type,
           ard.line_id                                           line_id,
           ev.event_id                                           event_id,
           ev.event_type_code                                    event_type_code,
           'MISC_RECEIPT'                                        event_class_code,
           'N'                                                   gain_or_loss_flag,
           hdr.accounting_date                                   accounting_date,
           hdr.ledger_id                                         ledger_id,
           1                                                     ln_order
   from ar_cash_receipts_all cr,
        ar_misc_cash_distributions_all mcd,
        xla_upgrade_dates gps,
        ar_cash_receipt_history_all crh,
        xla_transaction_entities_upg ent,
        xla_events ev,
        xla_ae_headers hdr,
        ar_distributions_all ard
   where cr.rowid >= l_start_rowid
   and cr.rowid <= l_end_rowid
   and nvl(cr.ax_accounted_flag,'N') = 'N'
   and cr.cash_receipt_id = mcd.cash_receipt_id
   and trunc(mcd.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = cr.set_of_books_id
   and cr.cash_receipt_id = crh.cash_receipt_id
   and crh.first_posted_record_flag = 'Y'
   and ent.application_id = 222
   and ent.ledger_id = cr.set_of_books_id
   and ent.entity_code = 'RECEIPTS'
   and nvl(ent.source_id_int_1,-99) = cr.cash_receipt_id
   and ent.entity_id = ev.entity_id
   and ev.application_id = 222
   and ev.upg_batch_id = l_batch_id
   and mcd.posting_control_id = ev.reference_num_1
   and nvl(trunc(mcd.gl_date), to_date('01-01-1900','DD-MM-YYYY')) = ev.event_date
   and  decode(mcd.created_from,
               'RATE ADJUSTMENT TRIGGER', 'MISC_RECP_RATE_ADJUST',
               decode(SUBSTRB(mcd.created_from,1,19),
                      'ARP_REVERSE_RECEIPT','MISC_RECP_REVERSE',
                      decode(nvl(trunc(crh.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                             nvl(trunc(mcd.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                             decode(crh.posting_control_id,
                                    mcd.posting_control_id, 'MISC_RECP_CREATE',
                                    'MISC_RECP_UPDATE'),
                             'MISC_RECP_UPDATE'))) = ev.event_type_code
   and cr.set_of_books_id = hdr.ledger_id
   and hdr.event_id = ev.event_id
   and hdr.application_id = 222
   and ard.source_id = mcd.misc_cash_distribution_id
   and ard.source_table = 'MCD');
   --order by entity_id,  ae_header_id, line_num;

   l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

END IF; --create lines

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
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: ARP_XLA_UPGRADE.upgrade_receipts');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: ARP_XLA_UPGRADE.upgrade_receipts');
    RAISE;

END UPGRADE_RECEIPTS;

PROCEDURE UPGRADE_ADJUSTMENTS(
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

-------------------------------------------------------------------
-- Create the Event Entities
-- Created by ar120adjent.sql
-------------------------------------------------------------------

-------------------------------------------------------------------
-- Create the Event Types and Journal Entry Headers
-- category definitions can be found in argper.lpc function arguje
-------------------------------------------------------------------
IF NVL(l_entity_type,'E') = 'E' THEN

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO XLA_EVENTS
      (upg_batch_id,
       upg_source_application_id,
       application_id,
       reference_num_1,
       reference_num_2,
       event_type_code,
       event_number,
       event_status_code,
       process_status_code,
       on_hold_flag,
       event_date,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       program_update_date,
       program_id,
       program_application_id,
       request_id,
       entity_id,
       event_id,
       upg_valid_flag,
       transaction_date)
      VALUES
      (batch_id,
       222,
       222,
      pst_id,            --reference num 1
      trx_id,            --reference num 2
      override_event,    --event type
      line_num,
      trx_status,        --event status code I, U, N, P
      pstd_flg,           --process status
      'N',
      gl_date,      --event date
      sysdate,
      0,
      sysdate,
      0,
      0,
      sysdate,
      0,
      222,
      '',
      entity_id,
      xla_events_s.nextval,
      'Y',                 --upgrade flag
      trx_date
      )
   WHEN PST_ID <> -3 THEN
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
    encumbrance_type_id,
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
   xla_events_s.nextval,
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
   '',                      --encumbrance type id
   '',                      --completed date
  doc_seq_id,
  doc_seq_val,
  cat_code,
  '',                       --packet id
  '',                       --group id
  sysdate,                  --row who creation date
  0,
  sysdate,
  0,
  0,
  sysdate,
  0,                    --program id
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
 select /*+ use_nl(lgr,map) */
       l_batch_id     AS BATCH_ID,
       'Adjustment'      AS CATEGORY,
       ev.TRX_ID          AS TRX_ID,
       ev.TRX_DATE        AS TRX_DATE,
       ev.SOB_ID          AS SOB_ID,
       ev.CAT_CODE        AS CAT_CODE,
       ev.TRX_TYPE        AS TRX_TYPE,
       ev.TRX_STATUS      AS TRX_STATUS,
       ev.OVERRIDE_EVENT  AS OVERRIDE_EVENT,
       ev.PSTD_FLG        AS PSTD_FLG,
       ev.PST_ID          AS PST_ID,
       ev.GL_DATE         AS GL_DATE,
       ev.GL_POSTED_DATE  AS GL_POSTED_DATE,
       ev.DOC_SEQ_ID      AS DOC_SEQ_ID,
       ev.DOC_SEQ_VAL     AS DOC_SEQ_VAL,
       ev.ENTITY_ID       AS ENTITY_ID,
       map.PERIOD_NAME    AS PERIOD_NAME,
       1                  AS LINE_NUM
FROM
(select /*+ ordered rowid(adj) use_nl(ct,te) use_hash(sys,tty) use_hash(gps) swap_join_inputs(gps) swap_join_inputs(tty) swap_join_inputs(sys) INDEX(te xla_transaction_entities_N1)  */
        adj.adjustment_id                             TRX_ID        ,
        ct.trx_date                                   TRX_DATE      ,
        adj.set_of_books_id                           SOB_ID        ,
        'ADJ'                                         TRX_TYPE      ,
        decode(sys.accounting_method,
               'CASH', 'N',
               decode(adj.status,
                      'A', decode(adj.posting_control_id,
                                         -3, 'U',
                                        'P'),
                      'I'))                           TRX_STATUS     ,
        'ADJ_CREATE'                                  OVERRIDE_EVENT ,
        decode(adj.posting_control_id,
               -3, 'U',
               'P')                                   PSTD_FLG       ,
        adj.posting_control_id                        PST_ID         ,
        nvl(trunc(adj.gl_date),to_date('01-01-1900','DD-MM-YYYY')) GL_DATE,
        nvl(trunc(max(adj.gl_posted_date)),to_date('01-01-1900','DD-MM-YYYY'))  GL_POSTED_DATE ,
        adj.doc_sequence_id                           DOC_SEQ_ID     ,
        adj.doc_sequence_value                        DOC_SEQ_VAL    ,
        tty.name                                      CAT_CODE       ,
        te.entity_id                                  ENTITY_ID
 FROM ar_adjustments_all adj,
      xla_upgrade_dates gps,
      ar_system_parameters_all sys,
      ra_customer_trx_all ct,
      ra_cust_trx_types_all tty,
      xla_transaction_entities_upg te
 WHERE adj.rowid >= l_start_rowid
 AND adj.rowid <= l_end_rowid
 AND NVL(adj.ax_accounted_flag,'N') = 'N'
 AND adj.customer_trx_id = ct.customer_trx_id
 and adj.event_id is null
 and trunc(adj.gl_date) between gps.start_date and gps.end_date
 and gps.ledger_id  = adj.set_of_books_id
 and decode(adj.posting_control_id,
            -3, decode(l_action_flag,
                       'D','P',
                       l_action_flag),
                       'P') = 'P'
 AND sys.org_id = adj.org_id
 AND ct.cust_trx_type_id   = tty.cust_trx_type_id
 AND tty.org_id = ct.org_id
 AND te.application_id = 222
 AND te.ledger_id = adj.set_of_books_id
 AND te.entity_code = 'ADJUSTMENTS'
 AND nvl(te.source_id_int_1,-99) = adj.adjustment_id
 --AND te.upg_batch_id = l_batch_id
 GROUP BY adj.adjustment_id,
          ct.trx_date,
          adj.set_of_books_id,
          te.entity_id,
          decode(sys.accounting_method,
                 'CASH', 'N',
                 decode(adj.status,
                        'A', decode(adj.posting_control_id,
                                           -3, 'U',
                                          'P'),
                        'I')),
          adj.org_id,
          decode(adj.posting_control_id,
                 -3, 'U',
                 'P')                                   ,
          adj.posting_control_id,
          nvl(trunc(adj.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
          adj.doc_sequence_id,
          adj.doc_sequence_value,
          tty.name) ev,
          gl_ledgers lgr,
          gl_date_period_map map
  where ev.sob_id = lgr.ledger_id
  and   map.period_set_name = lgr.period_set_name
  and   map.period_type = lgr.accounted_period_type
  and   map.accounting_date = ev.gl_date;
  --ORDER BY TRX_ID, line_num;

  l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

END IF; --create events

-------------------------------------------------------------------
-- Create the Journal Entry Lines
-- gl_transfer_mode_code is a flag indicating whether distributions
-- from AR to subledger tables are in detail or summary. This is
-- different from the standard post to GL summary or detail. So
--from an upgrade perspective for AR this is in detail always
--as AR stores in detailed accounting for historical data.
-------------------------------------------------------------------
IF NVL(l_entity_type,'L') = 'L' THEN

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
       nvl(account_class,'XXXX'),                  --accounting class code
       xla_gl_sl_link_id_s.nextval,    --gl sl link id
       'XLAJEL',                       --gl sl link table
       DECODE(third_party_id, NULL, NULL,'C'),  --party type code
       third_party_id,                 --party id
       third_party_sub_id,             --third party site
       '',                             --statistical amount
       '',                             --ussgl trx code
       '',                             --jgzz recon ref
       '',                             --control balance flag
       '',                             --analytical balance
       sysdate,                        --row who columns
       0,
       sysdate,
       0,
       0,
       sysdate,
       0,                           --program id
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
       line_num,
       account_class,
       'C',  --accounting line code customer
       ae_header_id, --reference header id
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
       'N',        --merge dup code
       '',         --tax_line_ref_id
       '',         --tax_summary_line_ref_id
       '',         --tax_rec_nrec_dist_ref_id
       '',         --statistical amount
       line_num,   --temp_line_num
       event_type_code, --event_type_code
       event_class_code, --event class code
       '',         --ref_event_id,
       batch_id)   --upgrade batch id
   select
       l_batch_id AS batch_id,
       ae_header_id AS ae_header_id,
       line_id AS line_id,
       event_id AS event_id,
       account_class AS account_class,
       source_table AS source_table,
       code_combination_id AS code_combination_id,
       amount_dr AS amount_dr,
       amount_cr AS amount_cr,
       acctd_amount_dr AS acctd_amount_dr,
       acctd_amount_cr AS acctd_amount_cr,
       nvl(currency_code,'XXX') AS currency_code,
       third_party_id AS third_party_id,
       third_party_sub_id AS third_party_sub_id,
       exchange_date AS exchange_date,
       exchange_rate AS exchange_rate,
       exchange_type AS exchange_type,
       event_type_code AS event_type_code,
       event_class_code AS event_class_code,
       accounting_date AS accounting_date,
       ledger_id AS ledger_id,
       RANK() OVER (PARTITION BY event_id, ae_header_id
                    ORDER BY line_id) AS line_num
FROM
( select /*+ ordered rowid(adj) use_nl(ent,ev,hdr,ard) use_hash(gps) swap_join_inputs(gps) INDEX(ent xla_transaction_entities_N1) INDEX(ev XLA_EVENTS_U2) INDEX(hdr XLA_AE_HEADERS_N2)  */
        hdr.ae_header_id                                      ae_header_id,
        DECODE(ard.source_type,'REC','RECEIVABLE',
               ard.source_type)                               account_class,
        'AR_DISTRIBUTIONS_ALL'                                source_table,
        ard.code_combination_id                               code_combination_id,
        ard.amount_dr                                         amount_dr,
        ard.amount_cr                                         amount_cr,
        ard.acctd_amount_dr                                   acctd_amount_dr,
        ard.acctd_amount_cr                                   acctd_amount_cr,
        ard.currency_code                                     currency_code,
        ard.third_party_id                                    third_party_id,
        ard.third_party_sub_id                                third_party_sub_id,
        ard.currency_conversion_date                          exchange_date,
        ard.currency_conversion_rate                          exchange_rate,
        ard.currency_conversion_type                          exchange_type,
        ard.line_id                                           line_id,
        ev.event_id                                           event_id,
        ev.event_type_code                                    event_type_code,
        'ADJUSTMENT'                                          event_class_code,
        hdr.accounting_date                                   accounting_date,
        hdr.ledger_id                                         ledger_id,
        1                                                     ln_order
   from ar_adjustments_all adj,
        xla_upgrade_dates gps,
        xla_transaction_entities_upg ent,
        xla_events ev,
        xla_ae_headers hdr,
        ar_distributions_all ard
   where adj.rowid >= l_start_rowid
   and adj.rowid <= l_end_rowid
   and nvl(adj.ax_accounted_flag,'N') = 'N'
   and trunc(adj.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = adj.set_of_books_id
   and ent.application_id = 222
   and adj.set_of_books_id = ent.ledger_id
   and ent.entity_code = 'ADJUSTMENTS'
   and nvl(ent.source_id_int_1,-99) = adj.adjustment_id
   and ent.entity_id = ev.entity_id
   and ev.application_id = 222
   and ev.upg_batch_id = l_batch_id
   and adj.set_of_books_id = hdr.ledger_id
   and hdr.application_id = 222
   and hdr.event_id = ev.event_id
   and adj.posting_control_id = ev.reference_num_1
   and nvl(trunc(adj.gl_date), to_date('01-01-1900','DD-MM-YYYY')) = ev.event_date
   and ard.source_id = adj.adjustment_id
   and ard.source_table = 'ADJ');

   l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

END IF; --create lines

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
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: ARP_XLA_UPGRADE.upgrade_adjustments');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: ARP_XLA_UPGRADE.upgrade_adjustments');
    RAISE;

END UPGRADE_ADJUSTMENTS;

--{BUG#4748251 - Update gl_import_references gl_sl_link_id, gl_sl_link_table
PROCEDURE update_gl_sla_link(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2) IS

l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

l_rowid_tab         DBMS_SQL.VARCHAR2_TABLE;
l_sl_id_tab         DBMS_SQL.NUMBER_TABLE;
g_bulk_fetch_rows   NUMBER   := 10000;
l_last_fetch        BOOLEAN  := FALSE;

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

--  Added for bug 6673937 ( pref. issue)

	BEGIN
		insert into ar120gir_periods(period_name)
		select
			distinct period_name
		from    gl_periods p
		where   start_date >= (select min(start_date) from XLA_UPGRADE_DATES)
		and     end_date   <= (select max(end_date)   from XLA_UPGRADE_DATES);
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		-- arp_standard.debug('NO_DATA_FOUND EXCEPTION: ARP_XLA_UPGRADE.update_gl_sla_link');
		-- arp_standard.debug('NO_DATA_FOUND EXCEPTION: Insert into ar120gir_periods');
		RAISE;

		WHEN OTHERS THEN
		-- arp_standard.debug('OTHERS EXCEPTION: ARP_XLA_UPGRADE.update_gl_sla_link');
		-- arp_standard.debug('NO_DATA_FOUND EXCEPTION: Insert into ar120gir_periods');
		RAISE;
	END;


  WHILE ( l_any_rows_to_process = TRUE )
  LOOP

   l_rows_processed := 0;

-------------------------------------------------------------------
-- Create the transaction entities
-- Created by arglslalink.sql
-------------------------------------------------------------------

-- Added for bug 6673937 ( pref. issue)
-- Combined the bulk select and update under single go

UPDATE /*+ rowid(gimp) */
GL_IMPORT_REFERENCES GIMP
SET
        (gl_sl_link_id,
         gl_sl_link_table) =
(SELECT /*+
        NO_EXPAND leading(ghd,periods,gld,gps,lnk,ln)
        use_nl(ghd,gld,gps)
        USE_NL_WITH_INDEX(ln XLA_AE_LINES_U1)
        USE_NL_WITH_INDEX(lnk XLA_DISTRIBUTION_LINKS_N1)
        */
        LN.GL_SL_LINK_ID, 'XLAJEL'
FROM    GL_JE_HEADERS GHD,
        GL_JE_LINES GLD,
        XLA_UPGRADE_DATES GPS,
        XLA_DISTRIBUTION_LINKS LNK,
        XLA_AE_LINES LN
WHERE   EXISTS
        (select /*+ PUSH_SUBQ */ null
         from   ar120gir_periods periods
         where  periods.period_name =  GHD.period_name
        )
AND GIMP.JE_HEADER_ID = GHD.JE_HEADER_ID
AND GHD.JE_SOURCE = 'Receivables'
AND GHD.JE_CATEGORY IN ('Adjustment','Chargebacks','Credit Memo Applications',
                        'Credit Memos','Debit Memos','Misc Receipts',
                        'Rate Adjustments', 'Sales Invoices','Trade Receipts',
			'Cross Currency', 'Bills Receivable')
AND GHD.JE_HEADER_ID = GLD.JE_HEADER_ID
AND GLD.EFFECTIVE_DATE BETWEEN GPS.START_DATE AND GPS.END_DATE
AND GLD.LEDGER_ID = GPS.LEDGER_ID
AND GLD.JE_HEADER_ID = GIMP.JE_HEADER_ID
AND GLD.JE_LINE_NUM = GIMP.JE_LINE_NUM
AND LNK.APPLICATION_ID = 222
AND LNK.SOURCE_DISTRIBUTION_ID_NUM_1 = GIMP.REFERENCE_3
AND LNK.SOURCE_DISTRIBUTION_TYPE =
        (CASE   WHEN GIMP.REFERENCE_10 = 'RA_CUST_TRX_LINE_GL_DIST'
                THEN 'RA_CUST_TRX_LINE_GL_DIST_ALL'
                WHEN GIMP.REFERENCE_10 IN
  		     ('AR_TRANSACTION_HISTORY','AR_ADJUSTMENTS',
		      'AR_MISC_CASH_DISTRIBUTIONS',
                      'AR_RECEIVABLE_APPLICATIONS', 'AR_CASH_RECEIPT_HISTORY')
                THEN 'AR_DISTRIBUTIONS_ALL'
                ELSE NULL
        END )
AND LN.APPLICATION_ID = 222
AND LNK.AE_HEADER_ID = LN.AE_HEADER_ID
AND LNK.AE_LINE_NUM = LN.AE_LINE_NUM
AND LN.LEDGER_ID      = GLD.LEDGER_ID   -- bug 8351855
)
WHERE ROWID BETWEEN l_start_rowid and l_end_rowid
AND GIMP.REFERENCE_10 IN
    ('AR_TRANSACTION_HISTORY','AR_ADJUSTMENTS','AR_MISC_CASH_DISTRIBUTIONS',
     'AR_RECEIVABLE_APPLICATIONS','AR_CASH_RECEIPT_HISTORY','RA_CUST_TRX_LINE_GL_DIST')
AND GIMP.GL_SL_LINK_ID IS NULL;


l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

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
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: ARP_XLA_UPGRADE.update_gl_sla_link');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: ARP_XLA_UPGRADE.update_gl_sla_link');
    RAISE;

END update_gl_sla_link;
--}

PROCEDURE UPGRADE_CASH_DIST(
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

-------------------------------------------------------------------
-- Create the Journal Entry Lines
-- gl_transfer_mode_code is a flag indicating whether distributions
-- from AR to subledger tables are in detail or summary. This is
-- different from the standard post to GL summary or detail. So
--from an upgrade perspective for AR this is in detail always
--as AR stores in detailed accounting for historical data.
-------------------------------------------------------------------
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
       account_class,                  --accounting class code
       xla_gl_sl_link_id_s.nextval,       --gl sl link id
       'XLAJEL',                       --gl sl link table
       DECODE(third_party_id, NULL, NULL,'C'),  --party type code
       third_party_id,                 --party id
       third_party_sub_id,             --third party site
       '',                             --statistical amount
       '',                             --ussgl trx code
       '',                             --jgzz recon ref
       '',                             --control balance flag
       '',                             --analytical balance
       sysdate,                        --row who columns
       0,
       sysdate,
       0,
       0,
       sysdate,
       0,                           --program id
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
       line_num,
       account_class,
       'C',  --accounting line code customer
       ae_header_id, --reference header id
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
       event_type_code, --event type
       'RECEIPT', --event class code
       '',         --ref_event_id,
       batch_id)   --upgrade batch id
   select
       l_batch_id AS batch_id,
       ae_header_id AS ae_header_id,
       line_id AS line_id,
       event_id AS event_id,
       event_type_code AS event_type_code,
       account_class AS account_class,
       source_table AS source_table,
       code_combination_id AS code_combination_id,
       amount_dr AS amount_dr,
       amount_cr AS amount_cr,
       acctd_amount_dr AS acctd_amount_dr,
       acctd_amount_cr AS acctd_amount_cr,
       nvl(currency_code,'XXXX') AS currency_code,
       third_party_id AS third_party_id,
       third_party_sub_id AS third_party_sub_id,
       exchange_date AS exchange_date,
       exchange_rate AS exchange_rate,
       exchange_type AS exchange_type,
       tax_line_id AS tax_line_id,
       accounting_date AS accounting_date,
       ledger_id AS ledger_id,
       RANK() OVER (PARTITION BY event_id, ae_header_id
                    ORDER BY line_id, ln_order) + 1000 AS line_num
FROM
( /* On Account CM and receipt applications */
   select /*+ ordered rowid(app) use_nl(ctcm,crh1,crh,cr,ent,ev,hdr,cbs,ctlgd) use_hash(gps) swap_join_inputs(gps) INDEX(ent XLA_TRANSACTION_ENTITIES_N1) INDEX(ev XLA_EVENTS_U2) INDEX(hdr XLA_AE_HEADERS_N2) INDEX_SS(crh1 ar_cash_receipt_history_n1) */
        hdr.ae_header_id                                      ae_header_id,
        decode(cbs.source,
               'GL', ctlgd.account_class,
               'ADJ', 'ADJ',
               'UNA', 'UNA',
               cbs.type)                                      account_class,
        'AR_CASH_BASIS_DISTRIBUTIONS'                         source_table,
        cbs.code_combination_id                               code_combination_id,
        decode(sign(cbs.amount),
               -1, abs(cbs.amount),
               '')                                            amount_dr,
        decode(sign(cbs.amount),
               1,abs(cbs.amount),
               0,abs(cbs.amount),
               '')                                            amount_cr,
        decode(sign(cbs.acctd_amount),
               -1, abs(cbs.acctd_amount),
               '')                                            acctd_amount_dr,
        decode(sign(cbs.acctd_amount),
               1,abs(cbs.acctd_amount),
               0,abs(cbs.acctd_amount),
               '')                                            acctd_amount_cr,
        cbs.currency_code                                     currency_code,
        decode(app.application_type,
               'CM', ctcm.bill_to_customer_id,
               cr.pay_from_customer)                          third_party_id,
        decode(app.application_type,
               'CM', ctcm.bill_to_site_use_id,
               cr.customer_site_use_id)                       third_party_sub_id,
        decode(app.application_type,
               'CM', ctcm.exchange_date,
               crh.exchange_date)                             exchange_date,
        decode(app.application_type,
               'CM', NVL(ctcm.exchange_rate,1),
               NVL(crh.exchange_rate,1) *
                      NVL(app.trans_to_receipt_rate, 1))      exchange_rate,
        decode(app.application_type,
               'CM', NVL(ctcm.exchange_rate_type,1),
               NVL(crh.exchange_rate_type,1))                 exchange_type,
        cbs.cash_basis_distribution_id                        line_id,
        ev.event_id                                           event_id,
        ev.event_type_code                                    event_type_code,
        null                                                  tax_line_id,
        hdr.accounting_date                                   accounting_date,
        hdr.ledger_id AS                                      ledger_id,
        1                                                     ln_order
   from ar_receivable_applications_all app,
        xla_upgrade_dates gps,
        xla_transaction_entities_upg ent,
        ra_customer_trx_all ctcm,
        ar_cash_receipt_history_all crh1,
        ar_cash_receipt_history_all crh,
        ar_cash_receipts_all cr,
        xla_events ev,
        xla_ae_headers hdr,
        ar_cash_basis_dists_all cbs,
        ra_cust_trx_line_gl_dist_all ctlgd
   where app.rowid >= l_start_rowid
   and app.rowid <= l_end_rowid
   and nvl(app.postable,'Y')       = 'Y'
   and nvl(app.confirmed_flag,'Y') = 'Y'
   and app.status = 'APP'
   and trunc(app.gl_date) between gps.start_date and gps.end_date
   and gps.ledger_id  = app.set_of_books_id
   and app.customer_trx_id = ctcm.customer_trx_id (+)
   and app.cash_receipt_id = cr.cash_receipt_id (+)
   and app.cash_receipt_id = crh1.cash_receipt_id (+)
   and 'Y' = crh1.first_posted_record_flag (+)
   and app.cash_receipt_history_id = crh.cash_receipt_history_id (+)
   AND app.posting_control_id    <> -3
   and ent.application_id = 222
   and ent.ledger_id = app.set_of_books_id
   and ent.entity_code = decode(app.customer_trx_id,
                                '', 'RECEIPTS',
                                'TRANSACTIONS')
   and nvl(ent.source_id_int_1,-99) = nvl(app.customer_trx_id, app.cash_receipt_id)
   and ent.entity_id = ev.entity_id
   and ev.upg_batch_id = l_batch_id
   and hdr.application_id = 222
   and app.set_of_books_id = hdr.ledger_id
   and hdr.event_id = ev.event_id
   and app.posting_control_id = ev.reference_num_1
   and nvl(trunc(app.gl_date), to_date('01-01-1900','DD-MM-YYYY')) = ev.event_date
   and decode(app.customer_trx_id,
              '', decode(crh.created_from,
                  'RATE ADJUSTMENT TRIGGER', 'RECP_RATE_ADJUST',
                   decode(crh.status,
                           'REVERSED','RECP_REVERSE',
                           decode(crh1.first_posted_record_flag,
                                  '', 'RECP_CREATE',
                                  decode(nvl(trunc(app.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                                         nvl(trunc(crh1.gl_date),to_date('01-01-1900','DD-MM-YYYY')),
                                         decode(app.posting_control_id,
                                                crh1.posting_control_id, 'RECP_CREATE',
                                                'RECP_UPDATE'),
                                         'RECP_UPDATE')))),
              ev.event_type_code) = ev.event_type_code
   and decode(app.customer_trx_id,
              '', decode(crh.postable_flag, 'Y','Y',
                         decode(crh.status, 'APPROVED',
                                decode(crh1.first_posted_record_flag, '','Y',
                                       'N'),
                                'N')),
              decode(ctcm.previous_customer_trx_id,
                     '','Y',
                     'N')) = 'Y'
   and cbs.receivable_application_id = app.receivable_application_id
   and cbs.source_id = ctlgd.cust_trx_line_gl_dist_id (+));
   --order by entity_id,  ae_header_id, line_num;

   l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

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
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: ARP_XLA_UPGRADE.upgrade_cash_dist');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: ARP_XLA_UPGRADE.upgrade_cash_dist');
    RAISE;

END UPGRADE_CASH_DIST;


END ARP_XLA_UPGRADE;

/
