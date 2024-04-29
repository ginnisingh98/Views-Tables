--------------------------------------------------------
--  DDL for Package Body PA_BILL_REV_XLA_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILL_REV_XLA_UPGRADE" AS
/* $Header: PAXBRU1B.pls 120.33.12000000.2 2007/09/18 07:08:46 pvishnoi ship $ */

PROCEDURE GL_IMP_UPG_AD_PAR( p_table_owner   IN         VARCHAR2,
                             p_table_name    IN         VARCHAR2,
                             p_script_name   IN         VARCHAR2,
                             p_num_workers   IN         NUMBER,
                             p_worker_id     IN         NUMBER,
                             p_batch_size    IN         NUMBER,
			     p_min_header_id IN         NUMBER,
			     p_max_header_id IN         NUMBER,
			     p_batch_id      IN         NUMBER)
IS

l_start_jeid         NUMBER(15);
l_end_jeid           NUMBER(15);

l_any_rows_to_process BOOLEAN;
l_rows_processed      NUMBER;
l_sql_stmt           VARCHAR2(2000);
BEGIN

 l_sql_stmt  := 'select je_header_id id_value ' ||
               ' FROM gl_je_headers hd, ' ||
               ' PA_PRIM_REP_LEGER_tmp per ' ||
               ' where hd.LEDGER_ID     = per.denorm_ledger_id ' ||
               ' and  hd.PERIOD_NAME    = per.PERIOD_NAME ' ||
               ' and  hd.je_source      = ''Project Accounting'' ' ||
               ' and per.batch_id       = ' || p_batch_id ;

  ad_parallel_updates_pkg.initialize_id_range(
           ad_parallel_updates_pkg.ID_RANGE_SCAN_EQUI_ROWSETS,
           p_table_owner,
           p_table_name,
           p_script_name,
           'JE_HEADER_ID',
           p_worker_id,
           p_num_workers,
           p_batch_size,
           0,
           l_sql_stmt,
           null,
           null);

   ------ Get rowid ranges ------
  ad_parallel_updates_pkg.get_id_range(
           l_start_jeid,
           l_end_jeid,
           l_any_rows_to_process,
           p_batch_size,
           TRUE);

   -------------------------------------------------------------------
   -- Run the transaction transformation for unposted items.
   -- Relies on AD rerunnability
   -------------------------------------------------------------------


     WHILE ( l_any_rows_to_process = TRUE )
       LOOP

  /*Bug 4943551 Changed the logic by using a new table PA_PRIM_REP_LEGER_tmp */

             UPDATE GL_IMPORT_REFERENCES gl
	        SET gl.gl_sl_link_id  = xla_gl_sl_link_id_s.nextval,
		    gl.gl_sl_link_table = 'XLAJEL'
              WHERE gl.gl_sl_link_id is NULL
                AND gl.je_header_id >= l_start_jeid
                AND gl.je_header_id <= l_end_jeid
		and EXISTS ( select 'X'
		               from  gl_je_headers hd,
			             PA_PRIM_REP_LEGER_tmp per
                              where  hd.je_header_id >= l_start_jeid
			        and  hd.je_header_id <= l_end_jeid
			        and  hd.LEDGER_ID    = per.denorm_ledger_id
				and  hd.PERIOD_NAME  = per.PERIOD_NAME
				and  per.batch_id    = p_batch_id
				and  hd.je_source    = 'Project Accounting'
				and  hd.JE_HEADER_ID = gl.JE_HEADER_ID);

             l_rows_processed := SQL%ROWCOUNT;

             ad_parallel_updates_pkg.processed_id_range(
                       l_rows_processed,
                       l_end_jeid);

             COMMIT;

             ad_parallel_updates_pkg.get_id_range(
                       l_start_jeid,
                       l_end_jeid,
                       l_any_rows_to_process,
                       p_batch_size,
                       FALSE);

    END LOOP ; /* end of WHILE loop */

COMMIT;

EXCEPTION
WHEN OTHERS THEN
   RAISE;
END;

PROCEDURE REV_UPG_AD_PAR( p_table_owner  IN         VARCHAR2,
                          p_table_name   IN         VARCHAR2,
                          p_script_name  IN         VARCHAR2,
                          p_num_workers  IN         NUMBER,
                          p_worker_id    IN         NUMBER,
                          p_batch_size   IN         NUMBER,
                          p_batch_id     IN         NUMBER)
IS

l_start_rowid         ROWID;
l_end_rowid           ROWID;

l_any_rows_to_process BOOLEAN;
l_rows_processed      NUMBER;
BEGIN

  ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           p_table_owner,
           p_table_name,
           p_script_name,
           p_worker_id,
           p_num_workers,
           p_batch_size, 0);

   ------ Get rowid ranges ------
  ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           p_batch_size,
           TRUE);

     WHILE ( l_any_rows_to_process = TRUE )
       LOOP

             PA_BILL_REV_XLA_UPGRADE.UPGRADE_TRANSACTIONS(
                                                p_start_rowid  => l_start_rowid,
                                                p_end_rowid    => l_end_rowid,
                                                p_batch_id     => p_batch_id,
                                                p_rows_process => l_rows_processed);

             ad_parallel_updates_pkg.processed_rowid_range(
                       l_rows_processed,
                       l_end_rowid);

             COMMIT;

             ad_parallel_updates_pkg.get_rowid_range(
                       l_start_rowid,
                       l_end_rowid,
                       l_any_rows_to_process,
                       p_batch_size,
                       FALSE);

    END LOOP ; /* end of WHILE loop */

EXCEPTION
WHEN OTHERS THEN
   RAISE;
END;

PROCEDURE UPGRADE_TRANSACTIONS(p_start_rowid  IN         ROWID,
                               p_end_rowid    IN         ROWID,
			       p_batch_id     IN         NUMBER,
			       p_rows_process OUT NOCOPY NUMBER)
IS


l_creation_date     date :=sysdate;
l_created_by        number(15) := 2; --Bug 6319424: Commented '-2005'
l_last_update_date  date := sysdate;
l_last_updated_by   number(15) := 2; --Bug 6319424: Commented '-2005'
l_last_update_login number(15):= 2; --Bug 6319424: Commented '-2005'


BEGIN

   p_rows_process := 0;

   INSERT ALL  /*+ rowid(dr) leading(dr) */
   WHEN (unbilled_receivable_dr <> 0
         and unbilled_code_combination_id is not null
	 and currency_code is not null)THEN /*5455002*/
    INTO PA_XLA_LINES_TMP
    (  project_id,
       draft_revenue_num,
       ae_header_id,
       xla_event_id,
       code_combination_id,
       amount_cr,
       amount_dr,
       currency_code,
       gl_batch_name,
       gl_category,
       ledger_id,
       accounting_date,
       position,
       adjusted_flag)
   values
     (  project_id,
        draft_revenue_num,
        xla_ae_headers_s.nextval,
        xla_events_s.nextval,
        unbilled_code_combination_id,
        decode(sign(unbilled_receivable_dr),
                     -1, abs(unbilled_receivable_dr), ''),
        decode(sign(unbilled_receivable_dr),
                      1, abs(unbilled_receivable_dr), ''),
        currency_code,
        unbilled_batch_name,
        'Revenue - UBR',
	set_of_books_id,
	gl_date,
         3,
	adjusted_flag
      )
   WHEN (unearned_revenue_cr <> 0
         and unearned_code_combination_id is not null
	 and currency_code is not null) THEN /*5455002*/
    INTO PA_XLA_LINES_TMP
    (  project_id,
       draft_revenue_num,
       ae_header_id,
       xla_event_id,
       code_combination_id,
       amount_cr,
       amount_dr ,
       currency_code,
       gl_batch_name,
       gl_category,
       ledger_id,
       accounting_date,
       position,
       adjusted_flag)
   values
     (  project_id,
        draft_revenue_num,
        xla_ae_headers_s.nextval,
        xla_events_s.nextval,
        unearned_code_combination_id,
        decode(sign(unearned_revenue_cr),
                      1, abs(unearned_revenue_cr), ''),
        decode(sign(unearned_revenue_cr),
                     -1, abs(unearned_revenue_cr), ''),
        currency_code,
        unearned_batch_name,
        'Revenue - UER',
	set_of_books_id,
	gl_date,
         4,
	adjusted_flag
      )
   WHEN (realized_gains_amount <> 0
     and realized_gains_ccid is not null
     and currency_code is not null) THEN /*5455002*/
    INTO PA_XLA_LINES_TMP
    (  project_id,
       draft_revenue_num,
       ae_header_id,
       xla_event_id,
       code_combination_id,
       amount_cr,
       amount_dr ,
       currency_code,
       gl_batch_name,
       gl_category,
       ledger_id,
       accounting_date,
       position,
       adjusted_flag)
   values
     (  project_id,
        draft_revenue_num,
        xla_ae_headers_s.nextval,
        xla_events_s.nextval,
        realized_gains_ccid,
        decode(sign(realized_gains_amount),
                      1, abs(realized_gains_amount),''),
        decode(sign(realized_gains_amount),
                     -1, abs(realized_gains_amount), ''),
        currency_code,
        realized_gains_batch_name,
        'Revenue - Realized Gains',
	set_of_books_id,
	gl_date,
         5,
        adjusted_flag
      )
   WHEN (realized_losses_amount <> 0
         and realized_losses_ccid is not null
	 and currency_code is not null) THEN/*5455002*/
    INTO PA_XLA_LINES_TMP
    (  project_id,
       draft_revenue_num,
       ae_header_id,
       xla_event_id,
       code_combination_id,
       amount_cr,
       amount_dr ,
       currency_code,
       gl_batch_name,
       gl_category,
       ledger_id,
       accounting_date,
       position,
       adjusted_Flag)
   values
     (  project_id,
        draft_revenue_num,
        xla_ae_headers_s.nextval,
        xla_events_s.nextval,
        realized_losses_ccid,
        decode(sign(realized_losses_amount),
                      1, abs(realized_losses_amount), ''),
        decode(sign(realized_losses_amount),
                     -1, abs(realized_losses_amount),''),
        currency_code,
        realized_losses_batch_name,
        'Revenue - Realized Losses',
	set_of_books_id,
	gl_date,
         6,
        adjusted_flag
      )
    WHEN 1= 1 THEN
    INTO PA_XLA_DRAFT_REV_TMP
    (REV_ROWID,
     PROJECT_ID,
     DRAFT_REVENUE_NUM,
     AE_HEADER_ID,
     XLA_EVENT_ID,
     LEDGER_ID,
     ACCOUNTING_DATE,
     CURRENCY_CODE,
     ADJUSTED_FLAG)
     values
     (REV_ROWID,
      PROJECT_ID,
      DRAFT_REVENUE_NUM,
      xla_ae_headers_s.nextval,
      xla_events_s.nextval,
      set_of_books_id,
      gl_date,
      currency_code,
      adjusted_flag)
    INTO XLA_TRANSACTION_ENTITIES_UPG
     (upg_batch_id,
      upg_source_application_id,
      application_id,
      ledger_id,
      legal_entity_id,
      entity_code,
      source_id_int_1,
      source_id_int_2,
      security_id_int_1,
      security_id_char_1,
      source_application_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      entity_id,
      upg_valid_flag,
      transaction_number)
    VALUES
      (    batch_id ,
           upg_source_app_id,
           app_id,
           set_of_books_id,
           legal_entity_id,
           'REVENUE',
           project_id,
           draft_revenue_num,
           org_id ,
           null,
           '275',
           l_creation_date,
           l_created_by,
           l_last_update_date,
           l_last_updated_by,
           l_last_update_login,
           XLA_TRANSACTION_ENTITIES_S.nextval,
           '' ,
	   transaction_number)
   INTO XLA_EVENTS
      (upg_batch_id,
       upg_source_application_id,
       application_id,
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
       upg_source_app_id,
       app_id,
       decode(adjusted_flag,'Y','REVENUE_ADJ','REVENUE'),
       xla_events_s.nextval,
       'P',
       'P',
       'N',
       gl_date,
       l_creation_date,
       l_created_by,
       l_last_update_date,
       l_last_updated_by,
       l_last_update_login,
       l_creation_date,
       -2005,
       275,
       '',
       XLA_TRANSACTION_ENTITIES_S.nextval,
       xla_events_s.nextval,
       'Y',
       gl_date
      )
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
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      program_update_date,
      program_id,
      program_application_id,
      request_id,
      upg_valid_flag)
     VALUES
     (batch_id,
      upg_source_app_id,
      app_id,
     'DEFAULT',
      XLA_TRANSACTION_ENTITIES_S.nextval,
      xla_events_s.nextval,
      decode(adjusted_flag,'Y','REVENUE_ADJ','REVENUE'),
      xla_ae_headers_s.nextval,
      set_of_books_id,
      gl_date,
      gl_period_name,
      '',
      'A',
      'Revenue',
      'Y',
      trans_date,
      'F',
      'STANDARD',
      l_creation_date,
      l_created_by,
      l_last_update_date,
      l_last_updated_by,
      l_last_update_login,
      l_creation_date,
      -2005,
      275,
       '',
      'Y'
      ) select /*+ rowid(dr) leading(dr) */
              dr.rowid  rev_rowid,
              p_batch_id batch_id,
              275 upg_source_app_id,
              275 app_id,
              imp.set_of_books_id set_of_books_id,
              hr.org_information2 legal_entity_id,
              dr.project_id project_id,  --src id int start
              dr.draft_revenue_num draft_revenue_num,
              dr.org_id org_id,
              dr.gl_date gl_date,
              dr.gl_period_name gl_period_name,
              NULL trx_number,
              dr.transferred_date trans_date,
              dr.unbilled_receivable_dr unbilled_receivable_dr,
              dr.unearned_revenue_cr unearned_revenue_cr,
              dr.unbilled_code_combination_id unbilled_code_combination_id,
              dr.unearned_code_combination_id unearned_code_combination_id,
              dr.unbilled_batch_name unbilled_batch_name,
              dr.unearned_batch_name unearned_batch_name,
              dr.realized_gains_amount realized_gains_amount,
              dr.realized_losses_amount realized_losses_amount,
              dr.realized_gains_ccid realized_gains_ccid,
              dr.realized_losses_ccid realized_losses_ccid,
              dr.realized_gains_batch_name realized_gains_batch_name,
              dr.realized_losses_batch_name realized_losses_batch_name,
	      pa.projfunc_currency_code currency_code,
	      decode(dr.draft_revenue_num_credited,null,'N','Y') adjusted_flag,
	      pa.segment1||'-'||to_char(dr.draft_revenue_num) transaction_number
          from pa_draft_revenues_all dr,
               pa_implementations_all imp,
	       pa_xla_upg_ctrl gl,
	       pa_projects_all pa,
	       hr_organization_information hr/*Added for 4920063 */
         where dr.rowid >= p_start_rowid
           and dr.rowid <= p_end_rowid
           and dr.TRANSFER_STATUS_CODE ='A'
           and dr.event_id is null
           and dr.org_id = imp.org_id
	   and gl.status ='P'
	   and gl.reference = 'GL_PERIOD_STATUSES'
	   and gl.batch_id  = p_batch_id
	   and gl.ledger_id = imp.set_of_books_id
	   and dr.gl_date between to_date(gl.min_value,'J') and to_date(gl.max_value,'J')
	   and pa.project_id = dr.project_id
	   and hr.organization_id = imp.org_id
	   and hr.org_information_context = 'Operating Unit Information';

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO PA_REV_AE_LINES_TMP
      (ae_header_id,
       ae_line_num,
       gl_batch_name,
       code_combination_id,
       dist_type)
    values
       (
        ae_header_id,
        line_num,
        gl_batch_name,
        code_combination_id,
        gl_category
       )
   INTO XLA_AE_LINES
      (upg_batch_id,
       ae_header_id,
       ae_line_num,
       application_id,
       code_combination_id,
       gl_transfer_mode_code,
       accounted_dr,
       unrounded_accounted_dr,
       accounted_cr,
       unrounded_accounted_cr,
       currency_code,
       entered_dr,
       unrounded_entered_dr,
       entered_cr,
       unrounded_entered_cr,
       description,
       accounting_class_code,
       gl_sl_link_id,
       gl_sl_link_table,
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
       ledger_id,
       business_class_code
      )
  VALUES
   (   batch_id,
       ae_header_id,
       line_num,
       275,
       code_combination_id,
       'S',
       amount_dr,
       amount_dr,
       amount_cr,
       amount_cr,
       currency_code,
       amount_dr,
       amount_dr,
       amount_cr,
       amount_cr,
       'Project Revenue',
       account_class,
       gl_sl_link_id,
       'XLAJEL',
       l_creation_date,
       l_created_by,
       l_last_update_date,
       l_last_updated_by,
       l_last_update_login,
       l_creation_date,
       -2005,
       275,
       '',
       gain_or_loss_flag,
       accounting_date,
       ledger_id,
       'PA_REV_ADJ')
   INTO XLA_DISTRIBUTION_LINKS
      (APPLICATION_ID,
       EVENT_ID,
       AE_HEADER_ID,
       AE_LINE_NUM,
       SOURCE_DISTRIBUTION_TYPE,
       SOURCE_DISTRIBUTION_ID_NUM_1,
       SOURCE_DISTRIBUTION_ID_NUM_2,
       MERGE_DUPLICATE_CODE,
       EVENT_TYPE_CODE,
       EVENT_CLASS_CODE,
       UPG_BATCH_ID,
       REF_AE_HEADER_ID,
       LINE_DEFINITION_CODE,
       temp_line_num,
       unrounded_accounted_dr,
       unrounded_accounted_cr,
       unrounded_entered_dr,
       unrounded_entered_cr,
       rounding_class_code)
    VALUES
      (275,
       event_id,
       ae_header_id,
       line_num,
       gl_category,
       source_num1,
       source_num2,
       'N',
       event_type_code,
       event_class_code,
       batch_id,
       ae_header_id,
       'PA_ACCRUAL_ACCOUNTING',
       line_num,
       amount_dr,
       amount_cr,
       amount_dr,
       amount_cr,
       account_class
       )
   select
       p_batch_id AS batch_id,
       ae_header_id AS ae_header_id,
       event_id AS event_id,
       account_class AS account_class,
       code_combination_id AS code_combination_id,
       amount_dr AS amount_dr,
       amount_cr AS amount_cr,
       currency_code AS currency_code,
       gain_or_loss_flag AS gain_or_loss_flag,
       event_type_code AS event_type_code,
       event_class_code AS event_class_code,
       source_num1,
       source_num2,
       gl_sl_link_id,
       gl_batch_name,
       gl_category,
       accounting_date,
       ledger_id,
       RANK() OVER (PARTITION BY ae_header_id
                    ORDER BY position,row_num) AS line_num
FROM
(    SELECT  1                                position,
            dr.ae_header_id                   ae_header_id,
            decode(dr.adjusted_flag,'N','REVENUE','REVENUE_ADJ') account_class,
            crdl.code_combination_id          code_combination_id,
            decode(sign(crdl.amount),
                      1, abs(crdl.amount),
                      '')                     amount_cr,
            decode(sign(crdl.amount),
                     -1, abs(crdl.amount),
                       '')                    amount_dr,
            nvl(crdl.revproc_currency_code,crdl.projfunc_currency_code) currency_code,
            dr.xla_event_id                   event_id,
            'REVENUE_ALL'                     event_type_code,
            decode(dr.adjusted_flag,'N','REVENUE','REVENUE_ADJ') event_class_code,
            'N'                               gain_or_loss_flag,
            dr.project_id                     project_id,
            dr.draft_revenue_num              dr_num,
            crdl.DRAFT_REVENUE_ITEM_LINE_NUM  dr_line_num,
            crdl.expenditure_item_id          source_num1,
            crdl.line_num                     source_num2,
	    null                              gl_sl_link_id,
            crdl.BATCH_NAME                   gl_batch_name,
            'Revenue - Normal Revenue'        gl_category,
	    rownum                            row_num,
	    dr.accounting_date                accounting_date,
	    dr.ledger_id                      ledger_id
     FROM   PA_CUST_REV_DIST_LINES_ALL CRDL,
            PA_XLA_DRAFT_REV_TMP DR
     WHERE  DR.DRAFT_REVENUE_NUM = CRDL.DRAFT_REVENUE_NUM
       AND  DR.PROJECT_ID        = CRDL.PROJECT_ID
       AND  NVL(CRDL.AMOUNT, 0) <> 0
       AND  crdl.code_combination_id is not null /*Bug 5455002*/
       AND  nvl(crdl.revproc_currency_code,crdl.projfunc_currency_code) is not null /*5441521*/
  UNION ALL
   SELECT  /*+ USE_NL(DR,ERDL,EV)*/
           2                                 position,
           dr.ae_header_id                   ae_header_id,
           DECODE(et.event_type_classification,
	                        'WRITE OFF','EVENT_WO_REVENUE',
				decode(dr.adjusted_flag,'N','REVENUE',
				                            'REVENUE_ADJ'))account_class,
           erdl.code_combination_id          code_combination_id,
           decode(sign(erdl.amount),
                      1, abs(erdl.amount),
                      '')                    amount_cr,
           decode(sign(erdl.amount),
                     -1, abs(erdl.amount),
                       '')                   amount_dr,
           nvl(erdl.revproc_currency_code,erdl.projfunc_currency_code) currency_code,
           dr.xla_event_id                   event_id,
           'REVENUE_ALL'                     event_type_code,
           decode(dr.adjusted_flag,'N','REVENUE','REVENUE_ADJ') event_class_code,
           'N'                               gain_or_loss_flag,
           dr.project_id                     project_id,
           erdl.draft_revenue_num            dr_num,
           erdl.draft_revenue_item_line_num  dr_line_num,
           ev.event_id                       source_num1,
           1                                 source_num2,
	   null                              gl_sl_link_id,
           erdl.BATCH_NAME                   gl_batch_name,
           'Revenue - Event Revenue'         gl_category,
	   rownum                            row_num,
	   dr.accounting_date                accounting_date,
	   dr.ledger_id                      ledger_id
     FROM   PA_CUST_EVENT_RDL_ALL ERDL,
            PA_XLA_DRAFT_REV_TMP DR,
	    PA_EVENTS ev,
	    PA_EVENT_TYPES et
     WHERE  DR.DRAFT_REVENUE_NUM = ERDL.DRAFT_REVENUE_NUM
       AND  DR.PROJECT_ID        = ERDL.PROJECT_ID
       AND  NVL(ERDL.AMOUNT, 0)  <> 0
       AND  erdl.project_id = ev.project_id
       AND  nvl(erdl.task_id,-99) = nvl(ev.task_id,-99)
       AND  erdl.event_num  = ev.event_num
       AND  ev.event_type   = et.event_type
       AND  erdl.code_combination_id is not null /*Bug 5455002*/
       AND  nvl(erdl.revproc_currency_code,erdl.projfunc_currency_code) is not null /*5441521*/
   UNION ALL
   select position,
          dr.ae_header_id                  ae_header_id,
          Decode(position,3,'UNBILL',
	                  4,'UNEARNED_REVENUE',
			  5,'REALIZED_GAINS',
			  6,'REALIZED_LOSS')  account_class,
          code_combination_id,
          amount_cr,
          amount_dr,
          dr.currency_code                  currency_code,
          dr.xla_event_id                   event_id,
          'REVENUE_ALL'                     event_type_code,
          decode(dr.adjusted_flag,'N','REVENUE','REVENUE_ADJ') event_class_code,
          'N'                               gain_or_loss_flag,
          dr.project_id                     project_id,
          dr.draft_revenue_num              dr_num,
          1                                 dr_line_num,
          dr.project_id                     source_num1,
          dr.draft_revenue_num              source_num2,
	  null                              gl_sl_link_id,
          gl_batch_name,
          gl_category,
	  rownum                            row_num,
	  accounting_date,
	  ledger_id
      FROM   PA_XLA_LINES_TMP DR);


     UPDATE PA_DRAFT_REVENUES_ALL dr
      SET dr.event_id = ( select tmp.xla_event_id
                         from  PA_XLA_DRAFT_REV_TMP tmp
                         WHERE  dr.rowid = tmp.rev_rowid),
          dr.created_by =-99999
     WHERE  dr.rowid >= p_start_rowid
       AND  dr.rowid <= p_end_rowid
       AND  dr.event_id is null
       AND  dr.transfer_Status_code='A'
       AND  EXISTS (SELECT 'X'
                      FROM PA_XLA_DRAFT_REV_TMP tmp
                         WHERE  dr.rowid = tmp.rev_rowid);

   p_rows_process := p_rows_process + SQL%ROWCOUNT;

       UPDATE XLA_AE_LINES lin
          SET lin.gl_sl_link_id = (SELECT gl_sl_link_id
                                    FROM  GL_IMPORT_REFERENCES imp,
                                          PA_REV_AE_LINES_TMP tmp
                                    WHERE imp.reference_6 = tmp.gl_batch_name
                                      AND imp.reference_2 = tmp.code_combination_id
                                      AND imp.reference_3 = tmp.dist_type
                                      AND lin.ae_header_id = tmp.ae_header_id
                                      AND lin.ae_line_num  = tmp.ae_line_num
				      AND imp.gl_sl_link_id is not null /*Bug 5168431*/
				      AND rownum =1)
        WHERE EXISTS ( SELECT 1
	                 FROM  PA_REV_AE_LINES_TMP tmp1
			WHERE  lin.ae_header_id   = tmp1.ae_header_id
			  AND  lin.ae_line_num    = tmp1.ae_line_num)
	  AND lin.application_id = 275
	  AND lin.gl_sl_link_id is null
	  AND lin.upg_batch_id   = p_batch_id;



EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_rows_process :=0;
    RAISE;

  WHEN OTHERS THEN
    p_rows_process :=0;
    RAISE;

END UPGRADE_TRANSACTIONS;


PROCEDURE REV_UPG_MC_AD_PAR( p_table_owner  IN         VARCHAR2,
                             p_table_name   IN         VARCHAR2,
                             p_script_name  IN         VARCHAR2,
                             p_num_workers  IN         NUMBER,
                             p_worker_id    IN         NUMBER,
                             p_batch_size   IN         NUMBER,
                             p_batch_id     IN         NUMBER)
IS

l_start_rowid         ROWID;
l_end_rowid           ROWID;

l_any_rows_to_process BOOLEAN;
l_rows_processed      NUMBER;
BEGIN

  ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           p_table_owner,
           p_table_name,
           p_script_name,
           p_worker_id,
           p_num_workers,
           p_batch_size, 0);

   ------ Get rowid ranges ------
  ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           p_batch_size,
           TRUE);

     WHILE ( l_any_rows_to_process = TRUE )
       LOOP

             PA_BILL_REV_XLA_UPGRADE.UPGRADE_MC_TRANSACTIONS(
                                                p_start_rowid  => l_start_rowid,
                                                p_end_rowid    => l_end_rowid,
                                                p_batch_id     => p_batch_id,
                                                p_rows_process => l_rows_processed);

             ad_parallel_updates_pkg.processed_rowid_range(
                       l_rows_processed,
                       l_end_rowid);

             COMMIT;

             ad_parallel_updates_pkg.get_rowid_range(
                       l_start_rowid,
                       l_end_rowid,
                       l_any_rows_to_process,
                       p_batch_size,
                       FALSE);

    END LOOP ; /* end of WHILE loop */

EXCEPTION
WHEN OTHERS THEN
   RAISE;
END;



PROCEDURE UPGRADE_MC_TRANSACTIONS( p_start_rowid IN ROWID,
                                   p_end_rowid   IN ROWID,
				   p_batch_id    IN NUMBER,
				   p_rows_process OUT NOCOPY NUMBER) IS

l_creation_date     date :=sysdate;
l_created_by        number(15) := 2; --Bug 6319424: Commented '-2005'
l_last_update_date  date := sysdate;
l_last_updated_by   number(15) := 2; --Bug 6319424: Commented '-2005'
l_last_update_login number(15):= 2; --Bug 6319424: Commented '-2005'
l_rows_processed NUMBER :=0;
BEGIN

   l_rows_processed := 0;

   INSERT ALL /*+ rowid(mc) leading(mc) */
   WHEN (mc_unbilled_receivable_dr <> 0
        and unbilled_code_combination_id is not null
	and currency_code is not null)THEN /*5455002*/
    INTO PA_XLA_LINES_TMP
    (  project_id,
       draft_revenue_num,
       ae_header_id,
       xla_event_id,
       code_combination_id,
       amount_cr,
       amount_dr ,
       currency_code,
       entered_cr,
       entered_dr,
       gl_batch_name,
       gl_category,
       position,
       accounting_date,
       ledger_id,
       conversion_date,
       adjusted_flag)
   values
     (  project_id,
        draft_revenue_num,
        xla_ae_headers_s.nextval,
        xla_events_s.nextval,
        unbilled_code_combination_id,
        decode(sign(mc_unbilled_receivable_dr),
                     -1, abs(mc_unbilled_receivable_dr), ''),
        decode(sign(mc_unbilled_receivable_dr),
                      1, abs(mc_unbilled_receivable_dr), ''),
        currency_code,
        decode(sign(unbilled_receivable_dr),
                     -1, abs(unbilled_receivable_dr), ''),
        decode(sign(unbilled_receivable_dr),
                      1, abs(unbilled_receivable_dr), ''),
        unbilled_batch_name,
        'Revenue - UBR',
         3,
	 gl_date,
	 rep_set_of_books_id,
	 gl_date,
	 adjusted_flag
      )
   WHEN (mc_unearned_revenue_cr <> 0
        and unearned_code_combination_id is not null
	and currency_code is not null) THEN /*5455002*/
    INTO PA_XLA_LINES_TMP
    (  project_id,
       draft_revenue_num,
       ae_header_id,
       xla_event_id,
       code_combination_id,
       amount_cr,
       amount_dr ,
       currency_code,
       entered_cr,
       entered_dr,
       gl_batch_name,
       gl_category,
       position,
       accounting_date,
       ledger_id,
       conversion_date,
       adjusted_flag)
   values
     (  project_id,
        draft_revenue_num,
        xla_ae_headers_s.nextval,
        xla_events_s.nextval,
        unearned_code_combination_id,
        decode(sign(mc_unearned_revenue_cr),
                      1, abs(mc_unearned_revenue_cr), ''),
        decode(sign(mc_unearned_revenue_cr),
                     -1, abs(mc_unearned_revenue_cr), ''),
        currency_code,
        decode(sign(unearned_revenue_cr),
                      1, abs(unearned_revenue_cr), ''),
        decode(sign(unearned_revenue_cr),
                     -1, abs(unearned_revenue_cr), ''),
        unearned_batch_name,
        'Revenue - UER',
         4,
	 gl_date,
	 rep_set_of_books_id,
	 gl_date,
	 adjusted_flag
      )
   WHEN (mc_realized_gains_amount <> 0
        and realized_gains_ccid is not null
	and currency_code is not null) THEN /*5455002*/
    INTO PA_XLA_LINES_TMP
    (  project_id,
       draft_revenue_num,
       ae_header_id,
       xla_event_id,
       code_combination_id,
       amount_cr,
       amount_dr ,
       currency_code,
       entered_cr,
       entered_dr,
       gl_batch_name,
       gl_category,
       position,
       accounting_date,
       ledger_id,
       conversion_date,
       adjusted_flag)
   values
     (  project_id,
        draft_revenue_num,
        xla_ae_headers_s.nextval,
        xla_events_s.nextval,
        realized_gains_ccid,
        decode(sign(mc_realized_gains_amount),
                      1, abs(mc_realized_gains_amount),''),
        decode(sign(mc_realized_gains_amount),
                     -1, abs(mc_realized_gains_amount), ''),
        currency_code,
        decode(sign(realized_gains_amount),
                      1, abs(realized_gains_amount),''),
        decode(sign(realized_gains_amount),
                     -1, abs(realized_gains_amount), ''),
        realized_gains_batch_name,
        'Revenue - Realized Gains',
         5,
	 gl_date,
	 rep_set_of_books_id,
	 gl_date,
	 adjusted_Flag
      )
   WHEN (mc_realized_losses_amount <> 0
         and realized_losses_ccid is not null
	 and currency_code is not null)THEN /*5455002*/
    INTO PA_XLA_LINES_TMP
    (  project_id,
       draft_revenue_num,
       ae_header_id,
       xla_event_id,
       code_combination_id,
       amount_cr,
       amount_dr ,
       currency_code,
       entered_cr,
       entered_dr,
       gl_batch_name,
       gl_category,
       position,
       accounting_date,
       ledger_id,
       conversion_date,
       adjusted_flag)
   values
     (  project_id,
        draft_revenue_num,
        xla_ae_headers_s.nextval,
        xla_events_s.nextval,
        realized_losses_ccid,
        decode(sign(mc_realized_losses_amount),
                      1, abs(mc_realized_losses_amount), ''),
        decode(sign(mc_realized_losses_amount),
                     -1, abs(mc_realized_losses_amount),''),
        currency_code,
        decode(sign(realized_losses_amount),
                      1, abs(realized_losses_amount), ''),
        decode(sign(realized_losses_amount),
                     -1, abs(realized_losses_amount),''),
        realized_losses_batch_name,
        'Revenue - Realized Losses',
         6,
	 gl_date,
	 rep_set_of_books_id,
	 gl_date,
	 adjusted_flag
      )
   WHEN 1 = 1 THEN
    INTO PA_XLA_DRAFT_REV_TMP
    (REV_ROWID,
     PROJECT_ID,
     DRAFT_REVENUE_NUM,
     AE_HEADER_ID,
     XLA_EVENT_ID,
     CURRENCY_CODE,
     ACCOUNTING_DATE,
     LEDGER_ID,
     REP_SET_OF_BOOKS_ID,
     adjusted_flag)
     values
     (rev_rowid,
     PROJECT_ID,
     DRAFT_REVENUE_NUM,
     xla_ae_headers_s.nextval,
     event_id,
     currency_code,
     gl_date,
     ledger_id,
     rep_set_of_books_id,
     adjusted_flag)

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
      balance_type_code,
      je_category_name,
      gl_transfer_status_code,
      gl_transfer_date,
      accounting_entry_status_code,
      accounting_entry_type_code,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      program_update_date,
      program_id,
      program_application_id,
      upg_valid_flag)
     VALUES
     (batch_id,
      upg_source_app_id,
      app_id,
     'DEFAULT',
      entity_id,
      event_id,
      decode(adjusted_flag,'Y','REVENUE_ADJ','REVENUE'),
      xla_ae_headers_s.nextval,
      rep_set_of_books_id,
      gl_date,
      gl_period_name,
      'A',
      'Revenue',
      decode(trans_status_code,'A','Y','N'),
      decode(trans_status_code,'A',trans_date,NULL),
      'F',
      'STANDARD',
      l_creation_date,
      l_created_by,
      l_last_update_date,
      l_last_updated_by,
      l_last_update_login,
      l_creation_date,
      -2005,
      275,
      'Y'
      )select /*+ rowid(mc) leading(mc) */
              mc.rowid                        rev_rowid,
              p_batch_id                      batch_id,
              275                             upg_source_app_id,
              275                             app_id,
              mc.set_of_books_id              rep_set_of_books_id,
              hr.org_information2             legal_entity_id,
              dr.gl_date                      gl_date,
              dr.gl_period_name               gl_period_name,
              evt.event_id                    event_id,
	      evt.entity_id                   entity_id,
	      mc.project_id                   project_id,
	      mc.draft_revenue_num	      draft_revenue_num,
              mc.transferred_date             trans_date,
              dr.unbilled_receivable_dr       unbilled_receivable_dr,
              dr.unearned_revenue_cr          unearned_revenue_cr,
              mc.unbilled_receivable_dr       mc_unbilled_receivable_dr,
              mc.unearned_revenue_cr          mc_unearned_revenue_cr,
              dr.unbilled_code_combination_id unbilled_code_combination_id,
              dr.unearned_code_combination_id unearned_code_combination_id,
              mc.unbilled_batch_name          unbilled_batch_name,
              mc.unearned_batch_name          unearned_batch_name,
              dr.realized_gains_amount        realized_gains_amount,
              dr.realized_losses_amount       realized_losses_amount,
              mc.realized_gains_amount        mc_realized_gains_amount,
              mc.realized_losses_amount       mc_realized_losses_amount,
              dr.realized_gains_ccid          realized_gains_ccid,
              dr.realized_losses_ccid         realized_losses_ccid,
              mc.realized_gains_batch_name    realized_gains_batch_name,
              mc.realized_losses_batch_name   realized_losses_batch_name,
              pa.projfunc_currency_code       currency_code,
	      mc.transfer_status_code         trans_status_code,
	      imp.set_of_books_id             ledger_id,
	      decode(dr.draft_revenue_num_credited,null,'N','Y') adjusted_flag
         from pa_draft_revenues_all dr,
              pa_implementations_all imp,
              pa_mc_draft_revs_all mc,
	      XLA_EVENTS evt,
	      pa_xla_upg_ctrl gl,
              pa_projects_all pa,
	      hr_organization_information hr
         where mc.rowid >= p_start_rowid
           and mc.rowid <= p_end_rowid
           and dr.project_id = mc.project_id
           and dr.draft_revenue_num = mc.draft_revenue_num
	   and nvl(mc.xla_migrated_flag,'N') ='N'
	 --  and mc.transfer_status_code  = 'A'
           and gl.status                = 'P'
           and gl.reference             = 'GL_PERIOD_STATUSES'
           and gl.batch_id              = p_batch_id
           and gl.ledger_id             = imp.set_of_books_id
           and dr.gl_date between to_date(gl.min_value,'J') and to_date(gl.max_value,'J')
           and dr.org_id                = imp.org_id
	   and dr.event_id              = evt.event_id
           and pa.project_id            = mc.project_id
	   and hr.organization_id       = imp.org_id
	   and hr.org_information_context = 'Operating Unit Information';

    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

   INSERT ALL
   WHEN 1 = 1 THEN
   INTO PA_REV_AE_LINES_TMP
      (ae_header_id,
       ae_line_num,
       gl_batch_name,
       code_combination_id,
       dist_type)
    values
       (
        ae_header_id,
        line_num,
        gl_batch_name,
        code_combination_id,
        gl_category
       )
   INTO XLA_AE_LINES
      (upg_batch_id,
       ae_header_id,
       ae_line_num,
       application_id,
       code_combination_id,
       gl_transfer_mode_code,
       accounted_dr,
       unrounded_accounted_dr,
       accounted_cr,
       unrounded_accounted_cr,
       currency_code,
       entered_dr,
       unrounded_entered_dr,
       entered_cr,
       unrounded_entered_cr,
       currency_conversion_date,
       currency_conversion_rate,
       currency_conversion_type,
       description,
       accounting_class_code,
       gl_sl_link_id,
       gl_sl_link_table,
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
       ledger_id,
       business_class_code
      )
  VALUES
   (   batch_id,
       ae_header_id,
       line_num,
       275,
       code_combination_id,
       'S',
       amount_dr,
       amount_dr,
       amount_cr,
       amount_cr,
       currency_code,
       entered_dr,
       entered_dr,
       entered_cr,
       entered_cr,
       conversion_date,
       exchange_rate,
       rate_type,
       'Project Revenue',
       account_class,
       gl_sl_link_id,
       'XLAJEL',
       l_creation_date,
       l_created_by,
       l_last_update_date,
       l_last_updated_by,
       l_last_update_login,
       l_creation_date,
       -2005,
       275,
       '',
       gain_or_loss_flag,
       accounting_date,
       ledger_id,
       'PA_REV_ADJ')
   INTO XLA_DISTRIBUTION_LINKS
      (APPLICATION_ID,
       EVENT_ID,
       AE_HEADER_ID,
       AE_LINE_NUM,
       SOURCE_DISTRIBUTION_TYPE,
       SOURCE_DISTRIBUTION_ID_NUM_1,
       SOURCE_DISTRIBUTION_ID_NUM_2,
       MERGE_DUPLICATE_CODE,
       EVENT_TYPE_CODE,
       EVENT_CLASS_CODE,
       UPG_BATCH_ID,
       REF_AE_HEADER_ID,
       LINE_DEFINITION_CODE,
       temp_line_num,
       unrounded_accounted_dr,
       unrounded_accounted_cr,
       unrounded_entered_dr,
       unrounded_entered_cr,
       rounding_class_code)
    VALUES
      (275,
       event_id,
       ae_header_id,
       line_num,
       gl_category,
       source_num1,
       source_num2,
       'N',
       event_type_code,
       event_class_code,
       batch_id,
       ae_header_id,
       'PA_ACCRUAL_ACCOUNTING',
       line_num,
       amount_dr,
       amount_cr,
       entered_dr,
       entered_cr,
       account_class
       )
   select
       p_batch_id AS batch_id,
       ae_header_id AS ae_header_id,
       event_id AS event_id,
       account_class AS account_class,
       code_combination_id AS code_combination_id,
       amount_dr AS amount_dr,
       amount_cr AS amount_cr,
       entered_dr AS entered_dr,
       entered_cr AS entered_cr,
       currency_code AS currency_code,
       conversion_date AS conversion_date,
       exchange_rate AS exchange_rate,
       rate_type     AS rate_type,
       gain_or_loss_flag AS gain_or_loss_flag,
       event_type_code AS event_type_code,
       event_class_code AS event_class_code,
       source_num1,
       source_num2,
       gl_sl_link_id,
       gl_batch_name,
       gl_category,
       accounting_date,
       ledger_id,
       RANK() OVER (PARTITION BY ae_header_id
                    ORDER BY position,row_num) AS line_num
FROM
( SELECT  1                                position,
          mc.ae_header_id                  ae_header_id,
         decode(mc.adjusted_flag,'N','REVENUE','REVENUE_ADJ') account_class,
         crdl.code_combination_id          code_combination_id,
         decode(sign(mcrdl.amount),
                      1, abs(mcrdl.amount),
                      '')                  amount_cr,
         decode(sign(mcrdl.amount),
                     -1, abs(mcrdl.amount),
                       '')                 amount_dr,
         decode(sign(crdl.amount),
                      1, abs(crdl.amount),
                      '')                  entered_cr,
         decode(sign(crdl.amount),
                     -1, abs(crdl.amount),
                       '')                 entered_dr,
         nvL(crdl.revproc_currency_code,crdl.projfunc_currency_code) currency_code,
         mcrdl.conversion_date AS conversion_date,
         mcrdl.exchange_rate AS exchange_rate,
         mcrdl.rate_type     AS rate_type,
         mc.xla_event_id                   event_id,
         'REVENUE_ALL'                     event_type_code,
         decode(mc.adjusted_flag,'N','REVENUE','REVENUE_ADJ') event_class_code,
         'N'                               gain_or_loss_flag,
         mc.project_id                     project_id,
         mc.draft_revenue_num              dr_num,
         mcrdl.DRAFT_REVENUE_ITEM_LINE_NUM  dr_line_num,
         mcrdl.expenditure_item_id          source_num1,
         mcrdl.line_num                     source_num2,
         null                               gl_sl_link_id,
         mcrdl.BATCH_NAME                   gl_batch_name,
         'Revenue - Normal Revenue'         gl_category,
	 rownum                             row_num,
	 mc.accounting_date                 accounting_date,
	 mc.REP_SET_OF_BOOKS_ID             ledger_id
     FROM   PA_CUST_REV_DIST_LINES_ALL CRDL,
            PA_MC_CUST_RDL_ALL mcrdl,
            PA_XLA_DRAFT_REV_TMP MC
     WHERE  mc.project_id             = mcrdl.project_id
       AND  mc.draft_revenue_num      = mcrdl.draft_revenue_num
       AND  mc.rep_set_of_books_id    = mcrdl.set_of_books_id
       AND  mcrdl.expenditure_item_id = crdl.expenditure_item_id
       AND  mcrdl.line_num            = crdl.line_num
       AND  NVL(mcrdl.amount, 0) <> 0
       AND  crdl.code_combination_id is not null /*Bug 5455002*/
       AND  nvl(crdl.revproc_currency_code,crdl.projfunc_currency_code) is not null /*5441521*/
  UNION ALL
   SELECT  /*+ /*+ USE_NL(MC,MCERDL,EV)*/
           2 position,
           mc.ae_header_id                   ae_header_id,
           DECODE(et.event_type_classification,
                       'WRITE OFF','EVENT_WO_REVENUE',
			decode(mc.adjusted_flag,'N','REVENUE',
			                            'REVENUE_ADJ')) account_class,
           erdl.code_combination_id          code_combination_id,
           decode(sign(mcerdl.amount),
                      1, abs(mcerdl.amount),
                      '')                    amount_cr,
           decode(sign(mcerdl.amount),
                     -1, abs(mcerdl.amount),
                       '')                   amount_dr,
           decode(sign(erdl.amount),
                      1, abs(erdl.amount),
                      '')                    entered_cr,
           decode(sign(erdl.amount),
                     -1, abs(erdl.amount),
                       '')                   entered_dr,
           nvl(erdl.revproc_currency_code,erdl.projfunc_currency_code) currency_code,
           mcerdl.conversion_date AS conversion_date,
           mcerdl.exchange_rate AS exchange_rate,
           mcerdl.rate_type     AS rate_type,
           mc.xla_event_id                   event_id,
           'REVENUE_ALL'                     event_type_code,
           decode(mc.adjusted_flag,'N','REVENUE','REVENUE_ADJ') event_class_code,
           'N'                               gain_or_loss_flag,
           mc.project_id                     project_id,
           erdl.draft_revenue_num            dr_num,
           erdl.draft_revenue_item_line_num  dr_line_num,
           ev.event_id                       source_num1,
           1                                 source_num2,
           null                              gl_sl_link_id,
           mcerdl.BATCH_NAME                 gl_batch_name,
           'Revenue - Event Revenue'         gl_category,
	   rownum                            row_num,
	   mc.accounting_date                accounting_date,
	   mc.REP_SET_OF_BOOKS_ID            ledger_id
     FROM   PA_CUST_EVENT_RDL_ALL erdl,
            PA_MC_CUST_EVENT_RDL_ALL mcerdl,
            PA_EVENTS ev,
            PA_XLA_DRAFT_REV_TMP MC,
	    PA_EVENT_TYPES et
     WHERE  mc.project_id            = mcerdl.project_id
       AND  mc.draft_revenue_num     = mcerdl.draft_revenue_num
       AND  mc.rep_set_of_books_id   = mcerdl.set_of_books_id
       AND  NVL(mcerdl.amount, 0)    <> 0
       AND  mcerdl.project_id        = erdl.project_id
       AND  nvl(mcerdl.task_id,-99)  = nvl(erdl.task_id,-99)
       AND  mcerdl.event_num         = erdl.event_num
       AND  mcerdl.project_id        = ev.project_id
       AND  nvl(mcerdl.task_id,-99)  = nvl(ev.task_id,-99)
       AND  mcerdl.event_num         = ev.event_num
       AND  ev.event_type            = et.event_type
       AND  erdl.code_combination_id is not null /*Bug 5455002*/
       AND  nvl(erdl.revproc_currency_code,erdl.projfunc_currency_code) is not null /*5441521*/
   UNION ALL
   select position,
          mc.ae_header_id                  ae_header_id,
          Decode(position,3,'UNBILL',
	                  4,'UNEARNED_REVENUE',
			  5,'REALIZED_GAINS',
			  6,'REALIZED_LOSS') account_class,
          code_combination_id,
          amount_cr,
          amount_dr,
          entered_cr,
          entered_dr,
          mc.currency_code                  currency_code,
          mc.conversion_date             AS conversion_date,
          amount_cr/entered_cr           AS exchange_rate,
          'User'                         AS rate_type,
          mc.xla_event_id                   event_id,
          'REVENUE_ALL'                     event_type_code,
          decode(mc.adjusted_flag,'N','REVENUE','REVENUE_ADJ') event_class_code,
          'N'                               gain_or_loss_flag,
          mc.project_id                     project_id,
          mc.draft_revenue_num              dr_num,
          1                                 dr_line_num,
          mc.project_id                     source_num1,
          mc.draft_revenue_num              source_num2,
          null                              gl_sl_link_id,
          gl_batch_name,
          gl_category,
	  rownum                            row_num,
	  accounting_date,
	  ledger_id
     FROM   PA_XLA_LINES_TMP MC );

     UPDATE PA_MC_DRAFT_REVS_ALL mc
      SET   mc.xla_migrated_flag = 'Y'
     WHERE  mc.rowid >= p_start_rowid
       AND  mc.rowid <= p_end_rowid
       AND  nvl(xla_migrated_flag,'N') = 'N'
       AND  EXISTS (SELECT 'X'
                      FROM PA_XLA_DRAFT_REV_TMP tmp
                       WHERE mc.rowid = tmp.rev_rowid);

   p_rows_process := p_rows_process + SQL%ROWCOUNT;

     UPDATE XLA_AE_LINES lin
      SET lin.gl_sl_link_id = (select gl_sl_link_id
                                FROM  GL_IMPORT_REFERENCES imp,
                                      PA_REV_AE_LINES_TMP tmp
                               WHERE imp.reference_6 = tmp.gl_batch_name
                                 AND imp.reference_2 = tmp.code_combination_id
                                 AND imp.reference_3 = tmp.dist_type
                                 AND lin.ae_header_id = tmp.ae_header_id
                                 AND lin.ae_line_num  = tmp.ae_line_num
				 AND imp.gl_sl_link_id is not null /*Bug 5168431*/
				 AND rownum=1)
     WHERE EXISTS ( SELECT 1
                      FROM  PA_REV_AE_LINES_TMP tmp1
                     WHERE  lin.ae_header_id   = tmp1.ae_header_id
                       AND  lin.ae_line_num    = tmp1.ae_line_num)
       AND lin.application_id = 275
       AND lin.gl_sl_link_id is null
       AND lin.upg_batch_id       = p_batch_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE;

  WHEN OTHERS THEN
    RAISE;

END UPGRADE_MC_TRANSACTIONS;


/* Called from concurrent program*/
PROCEDURE CON_UPGRADE_TRANSACTIONS
IS

l_batch_id    number;
l_start_rowid rowid;
l_end_rowid   rowid;
l_rows_processed number :=0;
BEGIN

SELECT XLA_UPG_BATCHES_S.nextval
         INTO l_batch_id
         FROM DUAL;

SELECT MIN(ROWID), MAX(ROWID)
  INTO l_start_rowid, l_end_rowid
  FROM PA_DRAFT_REVENUES_ALL;


UPGRADE_TRANSACTIONS(p_batch_id     => l_batch_id,
                     p_start_rowid  => l_start_rowid,
                     p_end_rowid    => l_end_rowid,
                     p_rows_process => l_rows_processed);

COMMIT;


SELECT MIN(ROWID), MAX(ROWID)
  INTO l_start_rowid, l_end_rowid
  FROM PA_MC_DRAFT_REVS_ALL;


UPGRADE_MC_TRANSACTIONS(p_batch_id     => l_batch_id,
                     p_start_rowid  => l_start_rowid,
                     p_end_rowid    => l_end_rowid,
                     p_rows_process => l_rows_processed);

COMMIT;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE;

  WHEN OTHERS THEN
    RAISE;

END CON_UPGRADE_TRANSACTIONS;

END PA_BILL_REV_XLA_UPGRADE;

/
