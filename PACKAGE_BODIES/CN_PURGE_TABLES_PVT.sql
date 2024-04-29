--------------------------------------------------------
--  DDL for Package Body CN_PURGE_TABLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PURGE_TABLES_PVT" AS
  /* $Header: CNVTPRGB.pls 120.0.12010000.4 2010/06/17 05:00:33 sseshaiy noship $*/

  G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CN_PURGE_TABLES_PVT';
  G_FILE_NAME CONSTANT VARCHAR2(12) := 'CNVTPRGB.pls';
  g_cn_debug  VARCHAR2(1)           := fnd_profile.value('CN_DEBUG');
  g_error_msg VARCHAR2(100)         := ' is a required field. Please enter the value for it.';
  g_script_name CONSTANT VARCHAR2(30)  := 'CNVTPRGBT4.0';

-- API name  : insert_archive
-- Type : private
-- Pre-reqs :
PROCEDURE insert_archive
  (
    table_id   NUMBER,
    seq_num    NUMBER,
    table_name VARCHAR2,
    row_count  NUMBER,
    any_rows_to_process varchar2)
IS
  pragma autonomous_transaction;

BEGIN
   INSERT
     INTO cn_arc_audit_desc_all
     (TABLE_ID,ARCHIVE_PURGE_ID,TABLES_NAME,TABLE_AP_ROWS,ARCHIVE_PURGE_DATE,ANY_ROWS_TO_PROCESS_FLAG,ATTRIBUTE1,
      ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
      VALUES
    (
      table_id           ,
      seq_num            ,
      table_name         ,
      row_count          ,
      sysdate            ,
      any_rows_to_process,
      NULL               ,
      NULL               ,
      NULL               ,
      NULL               ,
      NULL               ,
      fnd_global.user_id ,
      sysdate            ,
      fnd_global.user_id ,
      sysdate            ,
      fnd_global.user_id
    );
  COMMIT;
END;

PROCEDURE debugmsg
  (
    msg VARCHAR2
  )
IS
BEGIN
  --g_cn_debug   := 'Y';
  IF g_cn_debug = 'Y' THEN
    cn_message_pkg.debug
    (
      SUBSTR(msg,1,254)
    )
    ;
    fnd_file.put_line
    (
      fnd_file.Log, msg
    )
    ; -- Bug fix 5125980
  END IF;
  -- comment out dbms_output before checking in file
  -- dbms_output.put_line(substr(msg,1,254));
END debugmsg;

-- API name  : delete_table
-- Type : private
-- Pre-reqs :
PROCEDURE delete_table
  (
    p_start_period_id     IN NUMBER,
    p_end_period_id       IN NUMBER,
    x_start_date          IN DATE,
    x_end_date            IN DATE,
    p_worker_id           IN NUMBER,
    p_no_of_workers       IN NUMBER,
    p_batch_size          IN NUMBER,
    p_table_owner         IN VARCHAR2,
    p_table_name          IN VARCHAR2,
    p_script_name         IN VARCHAR2,
    p_addnl_para          IN VARCHAR2,
    x_row_to_process_flag OUT nocopy VARCHAR2,
    x_return_status       OUT nocopy VARCHAR2
  )
IS
  l_start_rowid rowid;
  l_end_rowid rowid;
  l_rows_processed NUMBER;
  l_time           VARCHAR2(20);
  l_sql varchar2(1000);
  l_any_rows_to_process BOOLEAN;
BEGIN
  x_return_status := 'S';
  debugmsg
  (
    'CN_PURGE_TABLES_PVT.delete_table:Start   '
  )
  ;
  debugmsg
  (
    'CN_PURGE_TABLES_PVT.delete_table:p_table_name   ' || p_table_name
  )
  ;
  debugmsg
  (
    'CN_PURGE_TABLES_PVT.delete_table:p_table_owner   ' || p_table_owner
  )
  ;
  debugmsg
  (
    'CN_PURGE_TABLES_PVT.delete_table:p_script_name   ' || p_script_name
  )
  ;
  debugmsg
  (
    'CN_PURGE_TABLES_PVT.delete_table:p_worker_id   ' || p_worker_id
  )
  ;
  debugmsg
  (
    'CN_PURGE_TABLES_PVT.delete_table:p_no_of_workers   ' || p_no_of_workers
  )
  ;
  debugmsg
  (
    'CN_PURGE_TABLES_PVT.delete_table:p_batch_size   ' || p_batch_size
  )
  ;
   SELECT TO_CHAR(sysdate,'dd-mm-rr:hh:mi:ss') INTO l_time FROM dual;

  debugmsg('CN_PURGE_TABLES_PVT.delete_table: delete start l_time    ' || l_time );

  ad_parallel_updates_pkg.initialize_rowid_range( ad_parallel_updates_pkg.ROWID_RANGE, p_table_owner, p_table_name, p_script_name, p_worker_id, p_no_of_workers, p_batch_size, 0);

  debugmsg('CN_PURGE_TABLES_PVT.delete_table:after  ad_parallel_updates_pkg.initialize_rowid_range  ' );

  ad_parallel_updates_pkg.get_rowid_range( l_start_rowid, l_END_rowid, l_any_rows_to_process, p_batch_size, TRUE);

  debugmsg('CN_PURGE_TABLES_PVT.delete_table:after ad_parallel_updates_pkg.get_rowid_range l_any_rows_to_process ' );

   IF (l_any_rows_to_process) THEN
    --dbms_output.put_line('ROWS Still LEFT For Processing');
    x_row_to_process_flag := 'Y';
    debugmsg('CN_PURGE_TABLES_PVT.delete_table: before loop l_any_rows_to_process is true   ' );
    ELSE
    --dbms_output.put_line('NO ROWS LEFT For Processing');
    x_row_to_process_flag := 'N';
    debugmsg('CN_PURGE_TABLES_PVT.delete_table: before loop l_any_rows_to_process is false   ' );
   END IF;


  WHILE (l_any_rows_to_process = TRUE)
  LOOP
    --dbms_output.put_line('start rowid '||l_start_rowid||' end_rowid '||l_end_rowid||' batch_size '||l_batch_size);
    -- debugmsg('CN_PURGE_TABLES_PVT.delete_table:after ad_parallel_updates_pkg.get_rowid_range l_any_rows_to_process True' );
    BEGIN
      IF (p_table_name = 'CN_PAYMENT_API_ALL') THEN
         DELETE
          /*+ ROWID (cnh) */
           FROM CN_PAYMENT_API_ALL cnh
          WHERE period_id BETWEEN p_start_period_id AND p_end_period_id
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_POSTING_DETAILS_ALL') THEN
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_posting_details_all cnh
          WHERE pay_period_id BETWEEN p_start_period_id AND p_end_period_id
        AND paid_flag = 'Y'
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_PAYMENT_TRANSACTIONS_ALL') THEN
        --debugmsg('CN_PURGE_TABLES_PVT.delete_table:before deleting cn_payment_transactions_all   ' );
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_payment_transactions_all cnh
          WHERE pay_period_id BETWEEN p_start_period_id AND p_end_period_id
        AND paid_flag = 'Y'
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_COMMISSION_LINES_ALL') THEN
        --debugmsg('CN_PURGE_TABLES_PVT.delete_table:before deleting cn_commission_lines_all   ' );
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_commission_lines_all cnh
          WHERE processed_period_id BETWEEN p_start_period_id AND p_end_period_id
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
        -- DELETE FROM cn_commission_lines_all
         -- WHERE processed_period_id BETWEEN p_start_period_id AND p_end_period_id;
      elsif (p_table_name = 'CN_COMMISSION_HEADERS_ALL') THEN
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_commission_headers_all cnh
          WHERE processed_period_id BETWEEN p_start_period_id AND p_end_period_id
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_TRX_SALES_LINES_ALL') THEN
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_trx_sales_lines_all cnh
          WHERE processed_date BETWEEN x_start_date AND x_end_date
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_TRX_LINES_ALL') THEN
         DELETE
          /*+ ROWID (t1) */
           FROM cn_trx_lines_all tl
          WHERE tl.TRX_ID IN
          (SELECT DISTINCT t.TRX_ID
             FROM cn_trx_all t
            WHERE TRUNC(t.processed_date) BETWEEN x_start_date AND x_end_date
          );
      elsif (p_table_name = 'CN_TRX_ALL') THEN
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_trx_all cnh
          WHERE processed_date BETWEEN x_start_date AND x_end_date
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_NOT_TRX_ALL') THEN
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_not_trx_all cnh
          WHERE processed_date BETWEEN x_start_date AND x_end_date
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_INVOICE_CHANGES_ALL') THEN
         DELETE
          /*+ ROWID (i) */
           FROM cn_invoice_changes_all i
          WHERE i.comm_lines_api_id IN
          (SELECT DISTINCT c.comm_lines_api_id
             FROM cn_comm_lines_api_all c
            WHERE c.processed_period_id BETWEEN p_start_period_id AND p_end_period_id
          )
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_IMP_HEADERS') THEN
         l_sql := 'DELETE
           /*+ ROWID (ih) */
           FROM cn_imp_headers ih
          WHERE ih.imp_header_id IN ' || p_addnl_para ||
        ' AND rowid BETWEEN ' ||  l_start_rowid || ' AND ' || l_end_rowid;
        EXECUTE IMMEDIATE l_sql;
      elsif (p_table_name = 'CN_IMP_LINES') THEN
         l_sql := 'DELETE
          /*+ ROWID (cnh) */
           FROM cn_imp_lines cnh
          WHERE import_type_code = ''TRXAPI''
        AND imp_header_id IN ' || p_addnl_para ||
        ' AND rowid BETWEEN ' || l_start_rowid || ' AND ' || l_end_rowid;
         EXECUTE IMMEDIATE l_sql;
      elsif (p_table_name = 'CN_COMM_LINES_API_ALL') THEN
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_comm_lines_api_all cnh
          WHERE processed_period_id BETWEEN p_start_period_id AND p_end_period_id
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_SRP_QUOTA_ASSIGNS_ALL') THEN
         DELETE
          /*+ ROWID (qa) */
           FROM cn_srp_quota_assigns_all qa
          WHERE qa.srp_plan_assign_id IN
          (SELECT DISTINCT pl.srp_plan_assign_id
             FROM cn_srp_plan_assigns_all pl
            WHERE ((pl.start_date BETWEEN x_start_date AND x_end_date)
          AND (pl.end_date BETWEEN x_start_date AND x_end_date))
          )
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_SRP_RATE_ASSIGNS_ALL') THEN
         DELETE
          /*+ ROWID (ra) */
           FROM cn_srp_rate_assigns_all ra
          WHERE ra.srp_plan_assign_id IN
          (SELECT DISTINCT pl.srp_plan_assign_id
             FROM cn_srp_plan_assigns_all pl
            WHERE ((pl.start_date BETWEEN x_start_date AND x_end_date)
          AND (pl.end_date BETWEEN x_start_date AND x_end_date))
          )
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_SRP_RULE_UPLIFTS_ALL') THEN
         DELETE
          /*+ ROWID (ru) */
           FROM cn_srp_rule_uplifts_all ru
          WHERE ru.srp_quota_rule_id IN
          (SELECT DISTINCT qr.srp_quota_rule_id
             FROM cn_srp_quota_rules_all qr
            WHERE qr.srp_plan_assign_id IN
            (SELECT DISTINCT pl.srp_plan_assign_id
               FROM cn_srp_plan_assigns_all pl
              WHERE ((pl.start_date BETWEEN x_start_date AND x_end_date)
            AND (pl.end_date BETWEEN x_start_date AND x_end_date))
            )
          )
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_SRP_QUOTA_RULES_ALL') THEN
         DELETE
          /*+ ROWID (ra) */
           FROM cn_srp_quota_rules_all ra
          WHERE ra.srp_plan_assign_id IN
          (SELECT DISTINCT pl.srp_plan_assign_id
             FROM cn_srp_plan_assigns_all pl
            WHERE ((pl.start_date BETWEEN x_start_date AND x_end_date)
          AND (pl.end_date BETWEEN x_start_date AND x_end_date))
          )
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_SRP_PLAN_ASSIGNS_ALL') THEN
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_srp_plan_assigns_all cnh
          WHERE ((start_date BETWEEN x_start_date AND x_end_date)
        AND (end_date BETWEEN x_start_date AND x_end_date))
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_SRP_PERIOD_QUOTAS_EXT_ALL') THEN
         DELETE
          /*+ ROWID (qe) */
           FROM cn_srp_period_quotas_ext_all qe
          WHERE qe.srp_period_quota_id IN
          (SELECT DISTINCT qa.srp_period_quota_id
             FROM cn_srp_period_quotas_all qa
            WHERE qa.period_id BETWEEN p_start_period_id AND p_end_period_id
          )
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_SRP_PER_QUOTA_RC_ALL') THEN
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_srp_per_quota_rc_all cnh
          WHERE period_id BETWEEN p_start_period_id AND p_end_period_id
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_SRP_PERIOD_QUOTAS_ALL') THEN
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_srp_period_quotas_all cnh
          WHERE period_id BETWEEN p_start_period_id AND p_end_period_id
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_PAY_APPROVAL_FLOW_ALL') THEN
         DELETE
          /*+ ROWID (af) */
           FROM cn_pay_approval_flow_all af
          WHERE af.payrun_id IN
          (SELECT DISTINCT pa.payrun_id
             FROM cn_payruns_all pa
            WHERE pa.PAY_PERIOD_ID BETWEEN p_start_period_id AND p_end_period_id
          )
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_WORKSHEET_QG_DTLS_ALL') THEN
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_worksheet_qg_dtls_all cnh
          WHERE period_id BETWEEN p_start_period_id AND p_end_period_id
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_PAYMENT_WORKSHEETS_ALL') THEN
         DELETE
          /*+ ROWID (pw) */
           FROM cn_payment_worksheets_all pw
          WHERE pw.payrun_id IN
          (SELECT DISTINCT pa.payrun_id
             FROM cn_payruns_all pa
            WHERE pa.PAY_PERIOD_ID BETWEEN p_start_period_id AND p_end_period_id
          )
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_LEDGER_JOURNAL_ENTRIES_ALL') THEN
         DELETE
          /*+ ROWID (je) */
           FROM cn_ledger_journal_entries_all je
          WHERE je.srp_period_id IN
          (SELECT DISTINCT sp.srp_period_id
             FROM cn_srp_periods_all sp
            WHERE sp.period_id BETWEEN p_start_period_id AND p_end_period_id
          )
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_POSTING_DETAILS_SUM_ALL') THEN
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_posting_details_sum_all cnh
          WHERE pay_period_id BETWEEN p_start_period_id AND p_end_period_id
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_WORKSHEET_BONUSES_ALL') THEN
         DELETE
          /*+ ROWID (wb) */
           FROM cn_worksheet_bonuses_all wb
          WHERE wb.payrun_id IN
          (SELECT DISTINCT pa.payrun_id
             FROM cn_payruns_all pa
            WHERE pa.PAY_PERIOD_ID BETWEEN p_start_period_id AND p_end_period_id
          )
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_PAYMENT_WORKSHEETS_ALL') THEN
         DELETE
          /*+ ROWID (pw) */
           FROM cn_payment_worksheets_all pw
          WHERE pw.payrun_id IN
          (SELECT DISTINCT pa.payrun_id
             FROM cn_payruns_all pa
            WHERE pa.PAY_PERIOD_ID BETWEEN p_start_period_id AND p_end_period_id
          )
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_PAYRUNS_ALL') THEN
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_payruns_all cnh
          WHERE pay_period_id BETWEEN p_start_period_id AND p_end_period_id
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_SRP_PERIODS_ALL') THEN
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_srp_periods_all cnh
          WHERE period_id BETWEEN p_start_period_id AND p_end_period_id
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_PROCESS_AUDITS_ALL') THEN
        --debugmsg('CN_PURGE_TABLES_PVT.delete_table:before deleting CN_PROCESS_AUDITS_ALL   ' );
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_process_audits_all cnh
          WHERE rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_PROCESS_AUDIT_LINES_ALL') THEN
        --debugmsg('CN_PURGE_TABLES_PVT.delete_table:before deleting CN_PROCESS_AUDIT_LINES_ALL   ' );
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_process_audit_lines_all cnh
          WHERE rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_PROCESS_BATCHES_ALL') THEN
        --debugmsg('CN_PURGE_TABLES_PVT.delete_table:before deleting CN_PROCESS_BATCHES_ALL   ' );
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_process_batches_all cnh
          WHERE period_id BETWEEN p_start_period_id AND p_end_period_id
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      elsif (p_table_name = 'CN_SRP_INTEL_PERIODS_ALL') THEN
        --debugmsg('CN_PURGE_TABLES_PVT.delete_table:before deleting cn_srp_intel_periods_all   ' );
         DELETE
          /*+ ROWID (cnh) */
           FROM cn_srp_intel_periods_all cnh
          WHERE period_id BETWEEN p_start_period_id AND p_end_period_id
        AND rowid BETWEEN l_start_rowid AND l_end_rowid;
      END IF;
      l_rows_processed := SQL%ROWCOUNT;
    EXCEPTION
    WHEN value_error THEN
      x_return_status := 'F';
      debugmsg('Before ad_parallel_updates_pkg.processed_rowid_range value_error - ' || sqlerrm);
    WHEN OTHERS THEN
      x_return_status := 'F';
      debugmsg('Before ad_parallel_updates_pkg.processed_rowid_range error - ' || sqlerrm);
    END;
    --debugmsg('Before  ad_parallel_updates_pkg : rollback before processed_rowid_range - ');
    --rollback;
    ad_parallel_updates_pkg.processed_rowid_range( l_rows_processed, l_END_rowid);

    --
    -- get new range of rowids
    --
    ad_parallel_updates_pkg.get_rowid_range( l_start_rowid, l_end_rowid, l_any_rows_to_process, p_batch_size, FALSE);

  END LOOP;

  SELECT TO_CHAR(sysdate,'dd-mm-rr:hh:mi:ss') INTO l_time FROM dual;
  debugmsg('CN_PURGE_TABLES_PVT.delete_table: delete end l_time    ' || l_time );
  debugmsg('CN_PURGE_TABLES_PVT.delete_table:end  final   ' );
EXCEPTION
WHEN OTHERS THEN

  --
  x_return_status := 'F';
  debugmsg('Exception After get rowid range');
  FND_MESSAGE.SET_NAME('CN','CN_PURGE_ERROR');
  FND_MESSAGE.SET_TOKEN('ERRORMSG', SQLERRM);
  FND_MSG_PUB.Add;
END delete_table;

-- API name  : purge_cn_tables_transactions
-- Type : private.
-- Pre-reqs :
PROCEDURE purge_cn_tables_transactions
  (
    p_start_period_id  IN NUMBER,
    p_end_period_id    IN NUMBER,
    x_start_date       IN DATE,
    x_end_date         IN DATE,
    p_cn_archive_all_s IN NUMBER,
    p_tot_rows_count   IN OUT nocopy NUMBER,
    p_worker_id        IN NUMBER,
    p_no_of_workers    IN NUMBER,
    p_batch_size       IN NUMBER,
    x_msg_count        IN OUT nocopy NUMBER,
    x_msg_data         IN OUT nocopy VARCHAR2,
    x_return_status OUT nocopy       VARCHAR2 )
IS
  CURSOR c_overlaping_header_records
  IS
  SELECT DISTINCT h.imp_header_id
       FROM cn_imp_headers h
      WHERE exists (select distinct l.imp_header_id from cn_imp_lines l where h.imp_header_id = l.imp_header_id
      and to_date(l.col3, 'dd-mm-rr') between  x_start_date AND x_end_date
      and h.imp_header_id not in (select distinct l2.imp_header_id from cn_imp_lines l2 where
      to_date(l2.col3, 'dd-mm-rr')  not between  x_start_date AND x_end_date
      ));

  l_imp_header_id number := 0;
  l_imp_header_id_list varchar2(2000) := '';
  l_imp_header_id_count NUMBER := 0;
  l_row_count            NUMBER;
  l_table_name           VARCHAR2(30);
  l_table_owner          VARCHAR2(30);
  l_any_rows_to_process  varchar2(1);
  l_sql                  varchar2(1000);

BEGIN
  debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables_transactions:Start  ' );
  x_return_status := 'S';
  l_table_owner   := 'CN';

  l_table_name := 'cn_payment_api_all';
  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  l_table_name := 'cn_posting_details_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  l_table_name := 'cn_payment_transactions_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

   l_table_name := 'cn_commission_lines_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

 l_table_name := 'cn_commission_headers_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );


  l_table_name := 'cn_trx_sales_lines_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );


  l_table_name := 'cn_trx_lines_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );


  l_table_name := 'cn_trx_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  l_table_name := 'cn_not_trx_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  l_table_name := 'cn_invoice_changes_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  BEGIN

  OPEN c_overlaping_header_records;
   LOOP
    FETCH c_overlaping_header_records INTO l_imp_header_id;
    EXIT WHEN c_overlaping_header_records%NOTFOUND;
    if(l_imp_header_id_count = 0) THEN
     l_imp_header_id_list := l_imp_header_id_list || l_imp_header_id;
    else
      l_imp_header_id_list := l_imp_header_id_list || l_imp_header_id || ',';
    end if;
    l_imp_header_id_count := l_imp_header_id_count + 1;

   END LOOP;
  CLOSE c_overlaping_header_records;

  debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables_transactions:11.2  l_imp_header_id_count  ' || l_imp_header_id_count);

    if(l_imp_header_id_count > 1 ) Then
     l_imp_header_id_list := '(' || l_imp_header_id_list || '-999' || ')';
    elsif(l_imp_header_id_count = 0 ) Then
      l_imp_header_id_list :=  '(-999)';
    else
     l_imp_header_id_list := '(' || l_imp_header_id_list || ')';
    end if;
      debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables_transactions:11.4  l_imp_header_id_list  ' || l_imp_header_id_list);
     l_table_name := 'cn_imp_lines';

      delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => l_imp_header_id_list,
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

      l_table_name            := 'cn_imp_headers';

      delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => l_imp_header_id_list,
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );


  EXCEPTION
  WHEN OTHERS THEN
      --x_return_status := 'F';
    debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables_transactions Error (possible error may be cn_imp_lines for col3 date format iisue - ' || sqlerrm);

  END;

  l_table_name := 'cn_comm_lines_api_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'F';
  debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables_transactions:exception others: ' || SQLERRM(SQLCODE()) );
  -- DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  RAISE	FND_API.G_EXC_ERROR;
END purge_cn_tables_transactions;

-- API name  : audit_purge_cn_transactions
-- Type : private.
-- Pre-reqs :
PROCEDURE audit_purge_cn_transactions
  (
    p_start_period_id  IN NUMBER,
    p_end_period_id    IN NUMBER,
    x_start_date       IN DATE,
    x_end_date         IN DATE,
    p_cn_archive_all_s IN NUMBER,
    p_tot_rows_count   IN OUT nocopy NUMBER,
    p_worker_id        IN NUMBER,
    p_no_of_workers    IN NUMBER,
    p_batch_size       IN NUMBER,
    x_msg_count        IN OUT nocopy NUMBER,
    x_msg_data         IN OUT nocopy VARCHAR2,
    x_return_status OUT nocopy       VARCHAR2 )
IS
  CURSOR c_overlaping_header_records
  IS
  SELECT DISTINCT h.imp_header_id
       FROM cn_imp_headers h
      WHERE exists (select distinct l.imp_header_id from cn_imp_lines l where h.imp_header_id = l.imp_header_id
      and to_date(l.col3, 'dd-mm-rr') between  x_start_date AND x_end_date
      and h.imp_header_id not in (select distinct l2.imp_header_id from cn_imp_lines l2 where
      to_date(l2.col3, 'dd-mm-rr')  not between  x_start_date AND x_end_date
      ));

  l_imp_header_id number := 0;
  l_imp_header_id_list varchar2(2000) := '';
  l_imp_header_id_count NUMBER := 0;
  l_row_count            NUMBER;
  l_table_name           VARCHAR2(30);
  l_table_owner          VARCHAR2(30);
  l_any_rows_to_process  varchar2(1);
  l_sql                  varchar2(1000);

BEGIN
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:Start  ' );
  x_return_status := 'S';
  l_table_owner   := 'CN';
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:1  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_payment_api_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_payment_api_all
    WHERE period_id BETWEEN p_start_period_id AND p_end_period_id;
  x_msg_data                      := x_msg_data || 'cn_payment_api_all count ' || l_row_count || ' : ';
  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_payment_api_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:2  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_posting_details_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_posting_details_all
    WHERE pay_period_id BETWEEN p_start_period_id AND p_end_period_id
  AND paid_flag = 'Y';
  x_msg_data                      := x_msg_data || 'cn_posting_details_all count ' || l_row_count || ' : ';
  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_posting_details_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:3  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_payment_transactions_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_payment_transactions_all
    WHERE pay_period_id BETWEEN p_start_period_id AND p_end_period_id
  AND paid_flag = 'Y';
  x_msg_data                      := x_msg_data || 'cn_payment_transactions_all count ' || l_row_count || ' : ';
  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_payment_transactions_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:4  x_msg_data  ' || x_msg_data);

   l_table_name := 'cn_commission_lines_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_commission_lines_all
    WHERE processed_period_id BETWEEN p_start_period_id AND p_end_period_id;

  x_msg_data                      := x_msg_data || 'cn_commission_lines_all count ' || l_row_count || ' : ';
  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_commission_lines_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:5  x_msg_data  ' || x_msg_data);

 l_table_name := 'cn_commission_headers_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_commission_headers_all
    WHERE processed_period_id BETWEEN p_start_period_id AND p_end_period_id;

  x_msg_data                      := x_msg_data || 'cn_commission_headers_all count ' || l_row_count || ' : ';
  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_commission_headers_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:6  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_trx_sales_lines_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_trx_sales_lines_all
    WHERE TRUNC(processed_date) BETWEEN x_start_date AND x_end_date;

  x_msg_data                      := x_msg_data || 'cn_trx_sales_lines_all count ' || l_row_count || ' : ';
  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_trx_sales_lines_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:7  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_trx_lines_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_trx_lines_all tl
    WHERE tl.TRX_ID IN
    (SELECT DISTINCT t.TRX_ID
       FROM cn_trx_all t
      WHERE TRUNC(t.processed_date) BETWEEN x_start_date AND x_end_date
    );

  x_msg_data                      := x_msg_data || 'cn_trx_lines_all count ' || l_row_count || ' : ';
  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_trx_lines_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:8  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_trx_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_trx_all
    WHERE TRUNC(processed_date) BETWEEN x_start_date AND x_end_date;

  x_msg_data                      := x_msg_data || 'cn_trx_all count ' || l_row_count || ' : ';
  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_trx_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:9  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_not_trx_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_not_trx_all
    WHERE TRUNC(processed_date) BETWEEN x_start_date AND x_end_date;

  x_msg_data                      := x_msg_data || 'cn_not_trx_all count ' || l_row_count || ' : ';
  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_not_trx_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:10  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_invoice_changes_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_invoice_changes_all i
    WHERE i.comm_lines_api_id IN
    (SELECT DISTINCT c.comm_lines_api_id
       FROM cn_comm_lines_api_all c
      WHERE c.processed_period_id BETWEEN p_start_period_id AND p_end_period_id
    );

  x_msg_data                      := x_msg_data || 'cn_invoice_changes_all count ' || l_row_count || ' : ';
  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_invoice_changes_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:11  x_msg_data  ' || x_msg_data);

  BEGIN

  OPEN c_overlaping_header_records;
   LOOP
    FETCH c_overlaping_header_records INTO l_imp_header_id;
    EXIT WHEN c_overlaping_header_records%NOTFOUND;
    if(l_imp_header_id_count = 0) THEN
     l_imp_header_id_list := l_imp_header_id_list || l_imp_header_id;
    else
      l_imp_header_id_list := l_imp_header_id_list || l_imp_header_id || ',';
    end if;
    l_imp_header_id_count := l_imp_header_id_count + 1;

   END LOOP;
  CLOSE c_overlaping_header_records;

  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:11.2  l_imp_header_id_count  ' || l_imp_header_id_count);

    if(l_imp_header_id_count > 1 ) Then
     l_imp_header_id_list := '(' || l_imp_header_id_list || '-999' || ')';
    elsif(l_imp_header_id_count = 0 ) Then
      l_imp_header_id_list :=  '(-999)';
    else
     l_imp_header_id_list := '(' || l_imp_header_id_list || ')';
    end if;
      debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:11.4  l_imp_header_id_list  ' || l_imp_header_id_list);
     l_table_name := 'cn_imp_lines';
     l_sql := 'SELECT COUNT(*) FROM cn_imp_lines WHERE import_type_code = ''TRXAPI'' AND imp_header_id in ' || l_imp_header_id_list;

     EXECUTE IMMEDIATE l_sql INTO l_row_count;

      x_msg_data                      := x_msg_data || 'cn_imp_lines count ' || l_row_count || ' : ';
      x_msg_count                     := x_msg_count      + 1;
      p_tot_rows_count                := p_tot_rows_count + l_row_count;
      insert_archive(cn_imp_lines_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
      debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:13  x_msg_data  ' || x_msg_data);


      l_table_name            := 'cn_imp_headers';
      l_sql := 'SELECT COUNT(*) FROM cn_imp_headers ih WHERE ih.imp_header_id IN ' || l_imp_header_id_list;

      EXECUTE IMMEDIATE l_sql INTO l_row_count;

      x_msg_data                      := x_msg_data || 'cn_imp_headers count ' || l_row_count || ' : ';
      x_msg_count                     := x_msg_count      + 1;
      p_tot_rows_count                := p_tot_rows_count + l_row_count;
      insert_archive(cn_imp_headers_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
      debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:12  x_msg_data  ' || x_msg_data);


  EXCEPTION
  WHEN OTHERS THEN
      --x_return_status := 'F';
    debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions Error (possible error may be cn_imp_lines for col3 date format iisue - ' || sqlerrm);

  END;

  l_table_name := 'cn_comm_lines_api_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_comm_lines_api_all
    WHERE processed_period_id BETWEEN p_start_period_id AND p_end_period_id;

  x_msg_data                      := x_msg_data || 'cn_comm_lines_api_all count ' || l_row_count || ' : ';
  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_comm_lines_api_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:14  x_msg_data  ' || x_msg_data);

EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'F';
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_transactions:exception others: ' || SQLERRM(SQLCODE()) );
  -- DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  RAISE	FND_API.G_EXC_ERROR;
END audit_purge_cn_transactions;

-- API name  : audit_purge_cn_subledgers
-- Type : Private.
-- Pre-reqs :
PROCEDURE purge_cn_tables_subledgers
  (
    p_start_period_id  IN NUMBER,
    p_end_period_id    IN NUMBER,
    x_start_date       IN DATE,
    x_end_date         IN DATE,
    p_cn_archive_all_s IN NUMBER,
    p_tot_rows_count   IN OUT nocopy NUMBER,
    p_worker_id        IN NUMBER,
    p_no_of_workers    IN NUMBER,
    p_batch_size       IN NUMBER,
    x_msg_count        IN OUT nocopy NUMBER,
    x_msg_data         IN OUT nocopy VARCHAR2,
    x_return_status OUT nocopy       VARCHAR2 )
IS
  l_row_count   NUMBER;
  l_table_name  VARCHAR2(30);
  l_table_owner VARCHAR2(30);
  l_any_rows_to_process  varchar2(1);

BEGIN
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_subledgers:  start  ');
  x_return_status := 'S';
  l_table_owner   := 'CN';

   l_table_name := 'cn_srp_period_quotas_ext_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );


 l_table_name := 'cn_srp_per_quota_rc_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  l_table_name := 'cn_srp_period_quotas_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );


   l_table_name := 'cn_pay_approval_flow_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

 l_table_name := 'cn_worksheet_qg_dtls_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  l_table_name := 'cn_payment_worksheets_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );


  l_table_name := 'cn_ledger_journal_entries_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  l_table_name := 'cn_posting_details_sum_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  l_table_name := 'cn_worksheet_bonuses_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  l_table_name := 'cn_payruns_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  l_table_name := 'cn_srp_periods_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'F';
  debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables_subledgers:exception others: ' || SQLERRM(SQLCODE()) );
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  -- DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
  RAISE	FND_API.G_EXC_ERROR;
END purge_cn_tables_subledgers;

-- API name  : audit_purge_cn_subledgers
-- Type : Private.
-- Pre-reqs :
PROCEDURE audit_purge_cn_subledgers
  (
    p_start_period_id  IN NUMBER,
    p_end_period_id    IN NUMBER,
    x_start_date       IN DATE,
    x_end_date         IN DATE,
    p_cn_archive_all_s IN NUMBER,
    p_tot_rows_count   IN OUT nocopy NUMBER,
    p_worker_id        IN NUMBER,
    p_no_of_workers    IN NUMBER,
    p_batch_size       IN NUMBER,
    x_msg_count        IN OUT nocopy NUMBER,
    x_msg_data         IN OUT nocopy VARCHAR2,
    x_return_status OUT nocopy       VARCHAR2 )
IS
  l_row_count   NUMBER;
  l_table_name  VARCHAR2(30);
  l_table_owner VARCHAR2(30);
  l_any_rows_to_process  varchar2(1);

BEGIN
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_subledgers:  start  ');
  x_return_status := 'S';
  l_table_owner   := 'CN';
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_subledgers:0  x_msg_data  ' || x_msg_data);

   l_table_name := 'cn_srp_period_quotas_ext_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_period_quotas_ext_all qe
    WHERE qe.srp_period_quota_id IN
    (SELECT DISTINCT qa.srp_period_quota_id
       FROM cn_srp_period_quotas_all qa
      WHERE qa.period_id BETWEEN p_start_period_id AND p_end_period_id
    );

  x_msg_data                      := x_msg_data || 'cn_srp_period_quotas_ext_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_period_quotas_ext_all_i,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_subledgers:1  x_msg_data  ' || x_msg_data);

 l_table_name := 'cn_srp_per_quota_rc_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_per_quota_rc_all
    WHERE period_id BETWEEN p_start_period_id AND p_end_period_id;

  x_msg_data                      := x_msg_data || 'cn_srp_per_quota_rc_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_per_quota_rc_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_subledgers:2  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_srp_period_quotas_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_period_quotas_all
    WHERE period_id BETWEEN p_start_period_id AND p_end_period_id;

  x_msg_data                      := x_msg_data || 'cn_srp_period_quotas_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_period_quotas_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_subledgers:3  x_msg_data  ' || x_msg_data);

   l_table_name := 'cn_pay_approval_flow_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_pay_approval_flow_all af
    WHERE af.payrun_id IN
    (SELECT DISTINCT pa.payrun_id
       FROM cn_payruns_all pa
      WHERE pa.PAY_PERIOD_ID BETWEEN p_start_period_id AND p_end_period_id
    );

  x_msg_data                      := x_msg_data || 'cn_pay_approval_flow_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_pay_approval_flow_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_subledgers:4  x_msg_data  ' || x_msg_data);

 l_table_name := 'cn_worksheet_qg_dtls_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_worksheet_qg_dtls_all
    WHERE period_id BETWEEN p_start_period_id AND p_end_period_id;

  x_msg_data                      := x_msg_data || 'cn_worksheet_qg_dtls_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_worksheet_qg_dtls_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_subledgers:5  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_payment_worksheets_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_payment_worksheets_all pw
    WHERE pw.payrun_id IN
    (SELECT DISTINCT pa.payrun_id
       FROM cn_payruns_all pa
      WHERE pa.PAY_PERIOD_ID BETWEEN p_start_period_id AND p_end_period_id
    );

  x_msg_data                      := x_msg_data || 'cn_payment_worksheets_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_payment_worksheets_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_subledgers:6  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_ledger_journal_entries_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_ledger_journal_entries_all je
    WHERE je.srp_period_id IN
    (SELECT DISTINCT sp.srp_period_id
       FROM cn_srp_periods_all sp
      WHERE sp.period_id BETWEEN p_start_period_id AND p_end_period_id
    );

  x_msg_data                      := x_msg_data || 'cn_ledger_journal_entries_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_ledger_journal_entries_alli,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_subledgers:7  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_posting_details_sum_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_posting_details_sum_all
    WHERE pay_period_id BETWEEN p_start_period_id AND p_end_period_id;

  x_msg_data                      := x_msg_data || 'cn_posting_details_sum_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_posting_details_sum_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_subledgers:8  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_worksheet_bonuses_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_worksheet_bonuses_all wb
    WHERE wb.payrun_id IN
    (SELECT DISTINCT pa.payrun_id
       FROM cn_payruns_all pa
      WHERE pa.PAY_PERIOD_ID BETWEEN p_start_period_id AND p_end_period_id
    );

  x_msg_data                      := x_msg_data || 'cn_worksheet_bonuses_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_worksheet_bonuses_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_subledgers:9  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_payruns_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_payruns_all
    WHERE PAY_PERIOD_ID BETWEEN p_start_period_id AND p_end_period_id;

  x_msg_data                      := x_msg_data || 'cn_payruns_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_payruns_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_subledgers:10  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_srp_periods_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_periods_all
    WHERE period_id BETWEEN p_start_period_id AND p_end_period_id;

  x_msg_data                      := x_msg_data || 'cn_srp_periods_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_periods_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_subledgers:11  x_msg_data  ' || x_msg_data);

EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'F';
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_subledgers:exception others: ' || SQLERRM(SQLCODE()) );
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  -- DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
  RAISE	FND_API.G_EXC_ERROR;
END audit_purge_cn_subledgers;

-- API name  : purge_cn_tables_refrences
-- Type : private.
-- Pre-reqs :
PROCEDURE purge_cn_tables_refrences
  (
    p_start_period_id  IN NUMBER,
    p_end_period_id    IN NUMBER,
    x_start_date       IN DATE,
    x_end_date         IN DATE,
    p_cn_archive_all_s IN NUMBER,
    p_tot_rows_count   IN OUT nocopy NUMBER,
    p_worker_id        IN NUMBER,
    p_no_of_workers    IN NUMBER,
    p_batch_size       IN NUMBER,
    x_msg_count        IN OUT nocopy NUMBER,
    x_msg_data         IN OUT nocopy VARCHAR2,
    x_return_status OUT nocopy       VARCHAR2 )
IS
  l_row_count   NUMBER;
  l_table_name  VARCHAR2(30);
  l_table_owner VARCHAR2(30);
   l_any_rows_to_process  varchar2(1);

BEGIN
  debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables_refrences: start  ');
  x_return_status := 'S';
  l_table_owner   := 'CN';

  l_table_name := 'cn_srp_payee_assigns_all';
  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );


  l_table_name := 'cn_srp_quota_assigns_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  l_table_name := 'cn_srp_rate_assigns_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  l_table_name := 'cn_srp_rule_uplifts_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );


  l_table_name := 'cn_srp_quota_rules_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  l_table_name := 'cn_srp_plan_assigns_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );


EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'F';
  debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables_transactions:exception others: ' || SQLERRM(SQLCODE()) );
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  -- DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
  RAISE	FND_API.G_EXC_ERROR;
END purge_cn_tables_refrences;

-- API name  : purge_cn_tables_refrences
-- Type : private.
-- Pre-reqs :
PROCEDURE audit_purge_cn_refrences
  (
    p_start_period_id  IN NUMBER,
    p_end_period_id    IN NUMBER,
    x_start_date       IN DATE,
    x_end_date         IN DATE,
    p_cn_archive_all_s IN NUMBER,
    p_tot_rows_count   IN OUT nocopy NUMBER,
    p_worker_id        IN NUMBER,
    p_no_of_workers    IN NUMBER,
    p_batch_size       IN NUMBER,
    x_msg_count        IN OUT nocopy NUMBER,
    x_msg_data         IN OUT nocopy VARCHAR2,
    x_return_status OUT nocopy       VARCHAR2 )
IS
  l_row_count   NUMBER;
  l_table_name  VARCHAR2(30);
  l_table_owner VARCHAR2(30);
   l_any_rows_to_process  varchar2(1);

BEGIN
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_refrences: start  ');
  x_return_status := 'S';
  l_table_owner   := 'CN';
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_refrences:0  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_srp_payee_assigns_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_payee_assigns_all pa
    WHERE pa.srp_quota_assign_id IN
    (SELECT DISTINCT qa.srp_quota_assign_id
       FROM cn_srp_period_quotas_all qa
      WHERE qa.srp_plan_assign_id IN
      (SELECT DISTINCT pl.srp_plan_assign_id
         FROM cn_srp_plan_assigns_all pl
        WHERE ((pl.start_date BETWEEN x_start_date AND x_end_date)
      AND (pl.end_date BETWEEN x_start_date AND x_end_date))
      )
    );

  x_msg_data                      := x_msg_data || 'cn_srp_payee_assigns_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_payee_assigns_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_refrences:1  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_srp_quota_assigns_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_quota_assigns_all qa
    WHERE qa.srp_plan_assign_id IN
    (SELECT DISTINCT pl.srp_plan_assign_id
       FROM cn_srp_plan_assigns_all pl
      WHERE ((pl.start_date BETWEEN x_start_date AND x_end_date)
    AND (pl.end_date BETWEEN x_start_date AND x_end_date))
    );

  x_msg_data                      := x_msg_data || 'cn_srp_quota_assigns_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_quota_assigns_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_refrences:2  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_srp_rate_assigns_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_rate_assigns_all ra
    WHERE ra.srp_plan_assign_id IN
    (SELECT DISTINCT pl.srp_plan_assign_id
       FROM cn_srp_plan_assigns_all pl
      WHERE ((pl.start_date BETWEEN x_start_date AND x_end_date)
    AND pl.end_date BETWEEN x_start_date AND x_end_date)
    );

  x_msg_data                      := x_msg_data || 'cn_srp_rate_assigns_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_rate_assigns_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_refrences:3  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_srp_rule_uplifts_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_rule_uplifts_all ru
    WHERE ru.srp_quota_rule_id IN
    (SELECT DISTINCT qr.srp_quota_rule_id
       FROM cn_srp_quota_rules_all qr
      WHERE qr.srp_plan_assign_id IN
      (SELECT DISTINCT pl.srp_plan_assign_id
         FROM cn_srp_plan_assigns_all pl
        WHERE ((pl.start_date BETWEEN x_start_date AND x_end_date)
      AND (pl.end_date BETWEEN x_start_date AND x_end_date))
      )
    );

  x_msg_data                      := x_msg_data || 'cn_srp_rule_uplifts_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_rule_uplifts_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_refrences:4  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_srp_quota_rules_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_quota_rules_all ra
    WHERE ra.srp_plan_assign_id IN
    (SELECT DISTINCT pl.srp_plan_assign_id
       FROM cn_srp_plan_assigns_all pl
      WHERE ((pl.start_date BETWEEN x_start_date AND x_end_date)
    AND (pl.end_date BETWEEN x_start_date AND x_end_date))
    );

  x_msg_data                      := x_msg_data || 'cn_srp_quota_rules_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_quota_rules_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_refrences:5  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_srp_plan_assigns_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_plan_assigns_all
    WHERE ((start_date BETWEEN x_start_date AND x_end_date)
  AND (end_date BETWEEN x_start_date AND x_end_date));

  x_msg_data                      := x_msg_data || 'cn_srp_plan_assigns_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_plan_assigns_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_refrences:6  x_msg_data  ' || x_msg_data);

EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'F';
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_refrences:exception others: ' || SQLERRM(SQLCODE()) );
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  -- DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
  RAISE	FND_API.G_EXC_ERROR;
END audit_purge_cn_refrences;

-- API name  : purge_cn_tables_processing
-- Type : private.
-- Pre-reqs :
PROCEDURE purge_cn_tables_processing
  (
    p_start_period_id  IN NUMBER,
    p_end_period_id    IN NUMBER,
    x_start_date       IN DATE,
    x_end_date         IN DATE,
    p_cn_archive_all_s IN NUMBER,
    p_tot_rows_count   IN OUT nocopy NUMBER,
    p_worker_id        IN NUMBER,
    p_no_of_workers    IN NUMBER,
    p_batch_size       IN NUMBER,
    x_msg_count        IN OUT nocopy NUMBER,
    x_msg_data         IN OUT nocopy VARCHAR2,
    x_return_status OUT nocopy       VARCHAR2 )
IS
  l_row_count   NUMBER;
  l_table_name  VARCHAR2(30);
  l_table_owner VARCHAR2(30);
   l_any_rows_to_process  varchar2(1);
BEGIN
  debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables_processing:  start  ' );
  x_return_status := 'S';
  l_table_owner   := 'CN';

  l_table_name := 'cn_process_audit_lines_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );


  l_table_name := 'cn_process_audits_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  l_table_name := 'cn_process_batches_all';

 delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  l_table_name := 'cn_srp_intel_periods_all';

  delete_table ( p_start_period_id => p_start_period_id,
                p_end_period_id => p_end_period_id,
                x_start_date => x_start_date,
                x_end_date => x_end_date,
                p_worker_id => p_worker_id,
                p_no_of_workers => p_no_of_workers,
                p_batch_size => p_batch_size,
                p_table_owner => l_table_owner,
                p_table_name => upper(l_table_name),
                p_script_name => g_script_name || '_' || p_cn_archive_all_s,
                p_addnl_para => '',
                x_row_to_process_flag => l_any_rows_to_process,
                x_return_status => x_return_status );

  x_return_status := 'S';
EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'F';
  debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables_transactions:exception others: ' || SQLERRM(SQLCODE()) );
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  -- DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
  RAISE	FND_API.G_EXC_ERROR;
END purge_cn_tables_processing;

-- API name  : purge_cn_tables_processing
-- Type : private.
-- Pre-reqs :
PROCEDURE audit_purge_cn_processing
  (
    p_start_period_id  IN NUMBER,
    p_end_period_id    IN NUMBER,
    x_start_date       IN DATE,
    x_end_date         IN DATE,
    p_cn_archive_all_s IN NUMBER,
    p_tot_rows_count   IN OUT nocopy NUMBER,
    p_worker_id        IN NUMBER,
    p_no_of_workers    IN NUMBER,
    p_batch_size       IN NUMBER,
    x_msg_count        IN OUT nocopy NUMBER,
    x_msg_data         IN OUT nocopy VARCHAR2,
    x_return_status OUT nocopy       VARCHAR2 )
IS
  l_row_count   NUMBER;
  l_table_name  VARCHAR2(30);
  l_table_owner VARCHAR2(30);
   l_any_rows_to_process  varchar2(1);
BEGIN
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_processing:  start  ' );
  x_return_status := 'S';
  l_table_owner   := 'CN';
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_processing:1  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_process_audit_lines_all';
   SELECT COUNT(*) INTO l_row_count FROM cn_process_audit_lines_all;

  x_msg_data                      := x_msg_data || 'cn_process_audit_lines_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_process_audit_lines_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_processing:2  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_process_audits_all';
   SELECT COUNT(*) INTO l_row_count FROM cn_process_audits_all;

  x_msg_data                      := x_msg_data || 'cn_process_audits_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_process_audits_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_processing:3  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_process_batches_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_process_batches_all
    WHERE period_id BETWEEN p_start_period_id AND p_end_period_id;

  x_msg_data                      := x_msg_data || 'cn_process_batches_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_process_batches_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_processing:4  x_msg_data  ' || x_msg_data);

  l_table_name := 'cn_srp_intel_periods_all';
   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_intel_periods_all
    WHERE period_id BETWEEN p_start_period_id AND p_end_period_id;

  x_msg_data                      := x_msg_data || 'cn_srp_intel_periods_all count ' || l_row_count || ' : ';

  x_msg_count                     := x_msg_count      + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_intel_periods_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_processing:5  x_msg_data  ' || x_msg_data);
  x_return_status := 'S';
EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'F';
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_processing:exception others: ' || SQLERRM(SQLCODE()) );
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  -- DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
  RAISE	FND_API.G_EXC_ERROR;
END audit_purge_cn_processing;


-- API name  : archive_cn_tables_transactions
-- Type : private.
-- Pre-reqs :
PROCEDURE archive_cn_tables_transactions
  (
    p_start_period_id IN NUMBER,
    p_end_period_id   IN NUMBER,
    x_start_date      IN DATE,
    x_end_date        IN DATE,
    p_table_space     IN VARCHAR2,
    p_cn_archive_all_s IN NUMBER,
    p_tot_rows_count   IN OUT nocopy NUMBER,
    x_msg_count       IN OUT nocopy NUMBER,
    x_msg_data        IN OUT nocopy VARCHAR2,
    x_return_status OUT nocopy      VARCHAR2 )
IS
  CURSOR c_overlaping_header_records
  IS
  SELECT DISTINCT h.imp_header_id
       FROM cn_imp_headers h
      WHERE exists (select distinct l.imp_header_id from cn_imp_lines l where h.imp_header_id = l.imp_header_id
      and to_date(l.col3, 'dd-mm-rr') between  x_start_date AND x_end_date
      and h.imp_header_id not in (select distinct l2.imp_header_id from cn_imp_lines l2 where
      to_date(l2.col3, 'dd-mm-rr')  not between  x_start_date AND x_end_date
      ));

  l_imp_header_id number := 0;
  l_imp_header_id_list varchar2(2000) := '';
  l_imp_header_id_count NUMBER := 0;

  l_sql                  VARCHAR2(1500);
  l_row_count            NUMBER;
  l_table_name           VARCHAR2(30);
  l_any_rows_to_process  varchar2(1);
BEGIN
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:  start  ');
  x_return_status := 'S';
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:1  x_msg_data  ' || x_msg_data);
  l_any_rows_to_process := 'N';
  l_table_name := 'CN_PAYMENT_API' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select *  from CN_PAYMENT_API_ALL where period_id  between ' || p_start_period_id || ' and ' || p_end_period_id;
  EXECUTE immediate l_sql;

    SELECT COUNT(*)
     INTO l_row_count
     FROM cn_payment_api_all
    WHERE period_id BETWEEN p_start_period_id AND p_end_period_id;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_payment_api_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:2  x_msg_data  ' || x_msg_data);
  l_table_name := 'cn_post_details' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  --l_sql := 'Create table cn_posting_details_arc ';
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select *  from cn_posting_details_all where pay_period_id  between ' || p_start_period_id || ' and ' || p_end_period_id || ' and paid_flag = ''Y''';
  EXECUTE immediate l_sql;

   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_posting_details_all
    WHERE pay_period_id BETWEEN p_start_period_id AND p_end_period_id;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_posting_details_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:3  x_msg_data  ' || x_msg_data);
  l_table_name := 'cn_payment_tran' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select *  from cn_payment_transactions_all where pay_period_id  between ' || p_start_period_id || ' and ' || p_end_period_id || ' and paid_flag = ''Y''';
  EXECUTE immediate l_sql;

   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_payment_transactions_all
    WHERE pay_period_id BETWEEN p_start_period_id AND p_end_period_id
  AND paid_flag = 'Y';
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_payment_transactions_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:4  x_msg_data  ' || x_msg_data);
  l_table_name := 'cn_commsn_lines' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select *  from  cn_commission_lines_all  where processed_period_id  between   ' || p_start_period_id || ' and ' || p_end_period_id;
  EXECUTE immediate l_sql;

  SELECT COUNT(*)
     INTO l_row_count
     FROM cn_commission_lines_all
    WHERE processed_period_id BETWEEN p_start_period_id AND p_end_period_id;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_commission_lines_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:5  x_msg_data  ' || x_msg_data);
  l_table_name := 'cn_comsn_header' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select *  from cn_commission_headers_all  where processed_period_id  between  ' || p_start_period_id || ' and ' || p_end_period_id;
  EXECUTE immediate l_sql;

 SELECT COUNT(*)
     INTO l_row_count
     FROM cn_commission_headers_all
    WHERE processed_period_id BETWEEN p_start_period_id AND p_end_period_id;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_commission_headers_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:6  x_msg_data  ' || x_msg_data);
  l_table_name := 'cn_trx_sale_lin' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select *  from cn_trx_sales_lines_all where TRUNC(processed_date)  between ''' || x_start_date ||'''' || ' and ''' || x_end_date ||'''';
  EXECUTE immediate l_sql;

    SELECT COUNT(*)
     INTO l_row_count
     FROM cn_trx_sales_lines_all
    WHERE TRUNC(processed_date) BETWEEN x_start_date AND x_end_date;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_trx_sales_lines_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:6.5  x_msg_data  ' || x_msg_data);
  l_table_name := 'cn_trx_lines' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select *  from cn_trx_lines_all tl where tl.TRX_ID in (Select distinct t.TRX_ID from cn_trx_all t where TRUNC(t.processed_date)  between ''' || x_start_date ||'''' || ' and ''' || x_end_date ||'''' || ' ) ';
  EXECUTE immediate l_sql;

   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_trx_lines_all tl
    WHERE tl.TRX_ID IN
    (SELECT DISTINCT t.TRX_ID
       FROM cn_trx_all t
      WHERE TRUNC(t.processed_date) BETWEEN x_start_date AND x_end_date
    );
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_trx_lines_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:7  x_msg_data  ' || x_msg_data);
  l_table_name := 'cn_trx' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select *  from cn_trx_all where TRUNC(processed_date)  between ''' || x_start_date ||'''' || ' and ''' || x_end_date ||'''';
  EXECUTE immediate l_sql;

    SELECT COUNT(*)
     INTO l_row_count
     FROM cn_trx_all
    WHERE TRUNC(processed_date) BETWEEN x_start_date AND x_end_date;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_trx_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:8  x_msg_data  ' || x_msg_data);
  l_table_name := 'cn_not_trx' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select *  from cn_not_trx_all where TRUNC(processed_date)  between ''' || x_start_date ||'''' || ' and ''' || x_end_date ||'''';
  EXECUTE immediate l_sql;

  SELECT COUNT(*)
     INTO l_row_count
     FROM cn_not_trx_all
    WHERE TRUNC(processed_date) BETWEEN x_start_date AND x_end_date;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_not_trx_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:9  x_msg_data  ' || x_msg_data);
  l_table_name := 'cn_invoice_chng' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select *  from  cn_invoice_changes_all i  where i.comm_lines_api_id in ' ||
           ' (select distinct c.comm_lines_api_id from cn_comm_lines_api_all c where c.processed_period_id  between  ' ||
           p_start_period_id || ' and ' || p_end_period_id || ' ) ';
  EXECUTE immediate l_sql;

 SELECT COUNT(*)
     INTO l_row_count
     FROM cn_invoice_changes_all i
    WHERE i.comm_lines_api_id IN
    (SELECT DISTINCT c.comm_lines_api_id
       FROM cn_comm_lines_api_all c
      WHERE c.processed_period_id BETWEEN p_start_period_id AND p_end_period_id );
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_invoice_changes_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:10  x_msg_data  ' || x_msg_data);

  BEGIN

  OPEN c_overlaping_header_records;
   LOOP
    FETCH c_overlaping_header_records INTO l_imp_header_id;
    EXIT WHEN c_overlaping_header_records%NOTFOUND;
    if(l_imp_header_id_count = 0) THEN
     l_imp_header_id_list := l_imp_header_id_list || l_imp_header_id;
    else
      l_imp_header_id_list := l_imp_header_id_list || l_imp_header_id || ',';
    end if;
    l_imp_header_id_count := l_imp_header_id_count + 1;

   END LOOP;
  CLOSE c_overlaping_header_records;

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:10.2  l_imp_header_id_count  ' || l_imp_header_id_count);



      if(l_imp_header_id_count > 1 ) Then
       l_imp_header_id_list := '(' || l_imp_header_id_list || '-999' || ')';
      elsif(l_imp_header_id_count = 0) Then
       l_imp_header_id_list :=  '(-999)';
      else
       l_imp_header_id_list := '(' || l_imp_header_id_list || ')';
      end if;

      debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:10.4  l_imp_header_id_list  ' || l_imp_header_id_list);
      l_table_name := 'cn_imp_lines' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
      l_sql := 'Create table ' || l_table_name ;
      if(p_table_space is not null) Then
        l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
      end if;
      l_sql := l_sql || ' as select *  from cn_imp_lines il  where il.import_type_code = ''TRXAPI'' and  il.imp_header_id in '
        || l_imp_header_id_list;

     debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:10.6  l_sql for cn_imp_lines :  ' || l_sql);

      EXECUTE immediate l_sql;
      debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:10.7');
      l_sql := 'SELECT COUNT(*) FROM cn_imp_lines WHERE import_type_code = ''TRXAPI'' AND imp_header_id in ' || l_imp_header_id_list;
      EXECUTE immediate l_sql INTO l_row_count;
      x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
      x_msg_count := x_msg_count + 1;
      p_tot_rows_count := p_tot_rows_count + l_row_count;
      debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:10.9 x_msg_data  ' || x_msg_data);

      insert_archive(cn_imp_lines_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);

       debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:11  x_msg_data  ' || x_msg_data);

      l_table_name := 'cn_imp_headers' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
      l_sql := 'Create table ' || l_table_name ;
      if(p_table_space is not null) Then
       l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
      end if;
        l_sql := l_sql || ' as select *  from cn_imp_headers ih where ih.imp_header_id  in '
        || l_imp_header_id_list;

      EXECUTE immediate l_sql;

      l_sql := 'SELECT COUNT(*) FROM cn_imp_headers ih WHERE ih.imp_header_id IN ' || l_imp_header_id_list;

      EXECUTE IMMEDIATE l_sql INTO l_row_count;
      x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
      x_msg_count := x_msg_count + 1;
      p_tot_rows_count := p_tot_rows_count + l_row_count;
      insert_archive(cn_imp_headers_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);

      debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:12  x_msg_data  ' || x_msg_data);


  EXCEPTION
  WHEN OTHERS THEN
   -- x_return_status := 'F';
    debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions Error in cn_imp_lines (possible reason may be col3 date format issue) - ' || sqlerrm);
  END;

  l_table_name := 'cn_comm_lin_api' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select *  from  cn_comm_lines_api_all where processed_period_id  between  ' || p_start_period_id || ' and ' || p_end_period_id;
  EXECUTE immediate l_sql;

   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_comm_lines_api_all
    WHERE processed_period_id BETWEEN p_start_period_id AND p_end_period_id;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_comm_lines_api_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:13  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:14  x_return_status  ' || x_return_status);
EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'F';
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_transactions:exception others: ' || SQLERRM(SQLCODE()) );
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  --DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
  RAISE	FND_API.G_EXC_ERROR;
END archive_cn_tables_transactions;

-- API name  : archive_cn_tables_subledgers
-- Type : private.
-- Pre-reqs :
PROCEDURE archive_cn_tables_subledgers
  (
    p_start_period_id IN NUMBER,
    p_end_period_id   IN NUMBER,
    x_start_date      IN DATE,
    x_end_date        IN DATE,
    p_table_space     IN VARCHAR2,
    p_cn_archive_all_s IN NUMBER,
    p_tot_rows_count   IN OUT nocopy NUMBER,
    x_msg_count       IN OUT nocopy NUMBER,
    x_msg_data        IN OUT nocopy VARCHAR2,
    x_return_status OUT nocopy      VARCHAR2 )
IS
  l_sql         VARCHAR2(1500);
  l_row_count            NUMBER;
  l_table_name           VARCHAR2(30);
  l_any_rows_to_process  varchar2(1);

BEGIN
   debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:  start  ');
  x_return_status := 'S';
  l_any_rows_to_process := 'N';

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:1  x_msg_data  ' || x_msg_data);
  l_table_name := 'cn_srp_prd_qt_e' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_srp_period_quotas_ext_all qe where ' ||
         ' qe.srp_period_quota_id in (Select distinct qa.srp_period_quota_id  from cn_srp_period_quotas_all qa  where qa.period_id between ' ||
         p_start_period_id || ' and ' || p_end_period_id || ' ) ';
  EXECUTE immediate l_sql;

   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_period_quotas_ext_all qe
    WHERE qe.srp_period_quota_id IN
    (SELECT DISTINCT qa.srp_period_quota_id
       FROM cn_srp_period_quotas_all qa
      WHERE qa.period_id BETWEEN p_start_period_id AND p_end_period_id
    );
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_period_quotas_ext_all_i,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:2  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:2  x_return_status  ' || x_return_status);

 debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:2  x_msg_data  ' || x_msg_data);
  l_table_name := 'cn_srp_pe_qt_rc' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_srp_per_quota_rc_all  where period_id  between  ' || p_start_period_id || ' and ' || p_end_period_id ;
  EXECUTE immediate l_sql;

  SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_per_quota_rc_all
    WHERE period_id BETWEEN p_start_period_id AND p_end_period_id;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_per_quota_rc_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:3  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:3  x_return_status  ' || x_return_status);

  l_table_name := 'cn_srp_prd_quta' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_srp_period_quotas_all  where period_id  between  ' || p_start_period_id || ' and ' || p_end_period_id;
  EXECUTE immediate l_sql;

   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_period_quotas_all
    WHERE period_id BETWEEN p_start_period_id AND p_end_period_id;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_period_quotas_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:4  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:4  x_return_status  ' || x_return_status);

  l_table_name := 'cn_pay_aprv_flw' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_pay_approval_flow_all af where af.payrun_id in (Select distinct pa.payrun_id from cn_payruns_all pa  where pa.PAY_PERIOD_ID  between  ' || p_start_period_id || ' and ' || p_end_period_id || ' ) ';
  EXECUTE immediate l_sql;

   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_pay_approval_flow_all af
    WHERE af.payrun_id IN
    (SELECT DISTINCT pa.payrun_id
       FROM cn_payruns_all pa
      WHERE pa.PAY_PERIOD_ID BETWEEN p_start_period_id AND p_end_period_id
    );
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_pay_approval_flow_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:5  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:5  x_return_status  ' || x_return_status);

  l_table_name := 'cn_wksht_qg_dtl' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_worksheet_qg_dtls_all where period_id  between  ' || p_start_period_id || ' and ' || p_end_period_id;
  EXECUTE immediate l_sql;

  SELECT COUNT(*)
     INTO l_row_count
     FROM cn_worksheet_qg_dtls_all
    WHERE period_id BETWEEN p_start_period_id AND p_end_period_id;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_worksheet_qg_dtls_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:6  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:6  x_return_status  ' || x_return_status);

  l_table_name := 'cn_pymnt_wkshts' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_payment_worksheets_all pw where pw.payrun_id in (Select distinct pa.payrun_id from cn_payruns_all pa  where pa.PAY_PERIOD_ID  between  ' || p_start_period_id || ' and ' || p_end_period_id || ' ) ';
  EXECUTE immediate l_sql;

  SELECT COUNT(*)
     INTO l_row_count
     FROM cn_payment_worksheets_all pw
    WHERE pw.payrun_id IN
    (SELECT DISTINCT pa.payrun_id
       FROM cn_payruns_all pa
      WHERE pa.PAY_PERIOD_ID BETWEEN p_start_period_id AND p_end_period_id
    );
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_payment_worksheets_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:7  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:7  x_return_status  ' || x_return_status);

  l_table_name := 'cn_ldgr_jrnl_en' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_ledger_journal_entries_all je where je.srp_period_id in (Select distinct sp.srp_period_id from cn_srp_periods_all sp where sp.period_id  between  ' || p_start_period_id || ' and ' || p_end_period_id || ' ) ';
  EXECUTE immediate l_sql;

   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_ledger_journal_entries_all je
    WHERE je.srp_period_id IN
    (SELECT DISTINCT sp.srp_period_id
       FROM cn_srp_periods_all sp
      WHERE sp.period_id BETWEEN p_start_period_id AND p_end_period_id
    );
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_ledger_journal_entries_alli,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:8  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:8  x_return_status  ' || x_return_status);

  l_table_name := 'cn_post_dtl_sum' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_posting_details_sum_all where pay_period_id  between  ' || p_start_period_id || ' and ' || p_end_period_id;
  EXECUTE immediate l_sql;

    SELECT COUNT(*)
     INTO l_row_count
     FROM cn_posting_details_sum_all
    WHERE pay_period_id BETWEEN p_start_period_id AND p_end_period_id;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_posting_details_sum_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:9  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:9  x_return_status  ' || x_return_status);

  l_table_name := 'cn_wksht_bonuse' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_worksheet_bonuses_all wb where wb.payrun_id in (Select distinct pa.payrun_id from cn_payruns_all pa where pa.PAY_PERIOD_ID  between  ' || p_start_period_id || ' and ' || p_end_period_id || ' ) ';
  EXECUTE immediate l_sql;

  SELECT COUNT(*)
     INTO l_row_count
     FROM cn_worksheet_bonuses_all wb
    WHERE wb.payrun_id IN
    (SELECT DISTINCT pa.payrun_id
       FROM cn_payruns_all pa
      WHERE pa.PAY_PERIOD_ID BETWEEN p_start_period_id AND p_end_period_id
    );
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_worksheet_bonuses_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:10  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:10  x_return_status  ' || x_return_status);

  l_table_name := 'cn_payruns' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_payruns_all where PAY_PERIOD_ID  between  ' || p_start_period_id || ' and ' || p_end_period_id;
  EXECUTE immediate l_sql;

   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_payruns_all
    WHERE PAY_PERIOD_ID BETWEEN p_start_period_id AND p_end_period_id;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_payruns_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:11  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:11  x_return_status  ' || x_return_status);

  l_table_name := 'cn_srp_periods' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_srp_periods_all where period_id  between  ' || p_start_period_id || ' and ' || p_end_period_id;
  EXECUTE immediate l_sql;

   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_periods_all
    WHERE period_id BETWEEN p_start_period_id AND p_end_period_id;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_periods_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:12  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:12  x_return_status  ' || x_return_status);

EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'F';
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_subledgers:exception others: ' || SQLERRM(SQLCODE()) );
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  --DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
  RAISE	FND_API.G_EXC_ERROR;
END archive_cn_tables_subledgers;

-- API name  : archive_cn_tables_references
-- Type : private.
-- Pre-reqs :
PROCEDURE archive_cn_tables_references
  (
    p_start_period_id IN NUMBER,
    p_end_period_id   IN NUMBER,
    x_start_date      IN DATE,
    x_end_date        IN DATE,
    p_table_space     IN VARCHAR2,
    p_cn_archive_all_s IN NUMBER,
    p_tot_rows_count   IN OUT nocopy NUMBER,
    x_msg_count       IN OUT nocopy NUMBER,
    x_msg_data        IN OUT nocopy VARCHAR2,
    x_return_status OUT nocopy      VARCHAR2 )
IS
  l_sql         VARCHAR2(1500);
  l_row_count            NUMBER;
  l_table_name           VARCHAR2(30);
  l_any_rows_to_process  varchar2(1);

BEGIN
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:  start  ');
  x_return_status := 'S';
  l_any_rows_to_process := 'N';

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:1  x_msg_data  ' || x_msg_data);
  l_table_name := 'cn_srp_paye_asn' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_srp_payee_assigns_all pa where pa.srp_quota_assign_id in (Select distinct qa.srp_quota_assign_id from cn_srp_period_quotas_all qa  where qa.srp_plan_assign_id in (Select distinct pl.srp_plan_assign_id
    from cn_srp_plan_assigns_all pl where ((pl.start_date  between ''' || x_start_date ||'''' || ' and ''' || x_end_date ||''''
    || ' ) and (pl.end_date  between ''' || x_start_date ||'''' || ' and ''' || x_end_date ||'''' || '))))';
  EXECUTE immediate l_sql;

   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_payee_assigns_all pa
    WHERE pa.srp_quota_assign_id IN
    (SELECT DISTINCT qa.srp_quota_assign_id
       FROM cn_srp_period_quotas_all qa
      WHERE qa.srp_plan_assign_id IN
      (SELECT DISTINCT pl.srp_plan_assign_id
         FROM cn_srp_plan_assigns_all pl
        WHERE ((pl.start_date BETWEEN x_start_date AND x_end_date)
      AND (pl.end_date BETWEEN x_start_date AND x_end_date))
      )
    );
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_payee_assigns_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:2  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:2  x_return_status  ' || x_return_status);

  l_table_name := 'cn_srp_quta_asn' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:2  l_sql  ' || l_sql);
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_srp_quota_assigns_all qa  where qa.srp_plan_assign_id in (Select distinct pl.srp_plan_assign_id from cn_srp_plan_assigns_all pl
          where ((pl.start_date  between  ''' || x_start_date ||'''' || ' and ''' || x_end_date ||''''
          || ' )  and (pl.end_date  between ''' || x_start_date ||'''' || ' and ''' || x_end_date ||'''' || ')))';
  EXECUTE immediate l_sql;

   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_quota_assigns_all qa
    WHERE qa.srp_plan_assign_id IN
    (SELECT DISTINCT pl.srp_plan_assign_id
       FROM cn_srp_plan_assigns_all pl
      WHERE ((pl.start_date BETWEEN x_start_date AND x_end_date)
    AND (pl.end_date BETWEEN x_start_date AND x_end_date))
    );
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_quota_assigns_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:2  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:2  x_return_status  ' || x_return_status);

  l_table_name := 'cn_srp_rate_asn' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_srp_rate_assigns_all ra  where ra.srp_plan_assign_id in (Select distinct pl.srp_plan_assign_id from cn_srp_plan_assigns_all pl
           where ((pl.start_date  between  ''' || x_start_date ||'''' || ' and ''' || x_end_date ||''''
           || ' )  and pl.end_date  between ''' || x_start_date ||'''' || ' and ''' || x_end_date ||'''' || '))';
  EXECUTE immediate l_sql;

   SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_rate_assigns_all ra
    WHERE ra.srp_plan_assign_id IN
    (SELECT DISTINCT pl.srp_plan_assign_id
       FROM cn_srp_plan_assigns_all pl
      WHERE ((pl.start_date BETWEEN x_start_date AND x_end_date)
    AND pl.end_date BETWEEN x_start_date AND x_end_date)
    );
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_rate_assigns_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:3  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:3  x_return_status  ' || x_return_status);

  l_table_name := 'cn_srp_rl_uplft' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_srp_rule_uplifts_all ru  ' ||
           ' where ru.srp_quota_rule_id in (Select distinct qr.srp_quota_rule_id from cn_srp_quota_rules_all qr ' ||
           ' where qr.srp_plan_assign_id in (Select distinct pl.srp_plan_assign_id from cn_srp_plan_assigns_all pl ' ||
           ' where ((pl.start_date  between  ''' || x_start_date ||'''' || ' and ''' || x_end_date ||''''
           || ' )  and (pl.end_date  between ''' || x_start_date ||'''' || ' and ''' || x_end_date ||'''' || '))))';
  EXECUTE immediate l_sql;

  SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_rule_uplifts_all ru
    WHERE ru.srp_quota_rule_id IN
    (SELECT DISTINCT qr.srp_quota_rule_id
       FROM cn_srp_quota_rules_all qr
      WHERE qr.srp_plan_assign_id IN
      (SELECT DISTINCT pl.srp_plan_assign_id
         FROM cn_srp_plan_assigns_all pl
        WHERE ((pl.start_date BETWEEN x_start_date AND x_end_date)
      AND (pl.end_date BETWEEN x_start_date AND x_end_date))
      )
    );
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_rule_uplifts_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:4  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:4  x_return_status  ' || x_return_status);

  l_table_name := 'cn_srp_quota_rl' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_srp_quota_rules_all ra where ra.srp_plan_assign_id in (Select distinct pl.srp_plan_assign_id from cn_srp_plan_assigns_all pl
         where ((pl.start_date  between ''' || x_start_date ||'''' || ' and ''' || x_end_date ||''''
         || ' )  and (pl.end_date  between ''' || x_start_date ||'''' || ' and ''' || x_end_date ||'''' || ')))';
  EXECUTE immediate l_sql;

  SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_quota_rules_all ra
    WHERE ra.srp_plan_assign_id IN
    (SELECT DISTINCT pl.srp_plan_assign_id
       FROM cn_srp_plan_assigns_all pl
      WHERE ((pl.start_date BETWEEN x_start_date AND x_end_date)
    AND (pl.end_date BETWEEN x_start_date AND x_end_date))
    );
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_quota_rules_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:5  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:5  x_return_status  ' || x_return_status);

  l_table_name := 'cn_srp_plan_asn' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_srp_plan_assigns_all where ((start_date  between ''' || x_start_date ||'''' || ' and ''' || x_end_date ||'''' || ') and (end_date  between ''' || x_start_date ||'''' || ' and ''' || x_end_date ||'''' || ' ))';
  EXECUTE immediate l_sql;

  SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_plan_assigns_all
    WHERE ((start_date BETWEEN x_start_date AND x_end_date)
  AND (end_date BETWEEN x_start_date AND x_end_date));
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_plan_assigns_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:6  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:6  x_return_status  ' || x_return_status);

EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'F';
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_references:exception others: ' || SQLERRM(SQLCODE()) );
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  -- DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
  RAISE	FND_API.G_EXC_ERROR;
END archive_cn_tables_references;

-- API name  : archive_cn_tables_processing
-- Type : private.
-- Pre-reqs :
PROCEDURE archive_cn_tables_processing
  (
    p_start_period_id IN NUMBER,
    p_end_period_id   IN NUMBER,
    x_start_date      IN DATE,
    x_end_date        IN DATE,
    p_table_space     IN VARCHAR2,
    p_cn_archive_all_s IN NUMBER,
    p_tot_rows_count   IN OUT nocopy NUMBER,
    x_msg_count       IN OUT nocopy NUMBER,
    x_msg_data        IN OUT nocopy VARCHAR2,
    x_return_status OUT nocopy      VARCHAR2 )
IS
  l_sql         VARCHAR2(1500);
  l_row_count            NUMBER;
  l_table_name           VARCHAR2(30);
  l_any_rows_to_process  varchar2(1);

BEGIN
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_processing:  start  ');
  x_return_status := 'S';
  l_any_rows_to_process := 'N';

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_processing:1  x_msg_data  ' || x_msg_data);
  l_table_name := 'cn_proces_batch' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_process_batches_all  where period_id  between ' || p_start_period_id || ' and ' || p_end_period_id;
  EXECUTE immediate l_sql;

 SELECT COUNT(*)
     INTO l_row_count
     FROM cn_process_batches_all
    WHERE period_id BETWEEN p_start_period_id AND p_end_period_id;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count                := p_tot_rows_count + l_row_count;
  insert_archive(cn_process_batches_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_processing:2  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_processing:2  x_return_status  ' || x_return_status);

  l_table_name := 'cn_srp_intl_prd' || '_' || to_char(sysdate, 'DDMMYYYYHH24MI');
  l_sql := 'Create table ' || l_table_name ;
  if(p_table_space is not null) Then
   l_sql := l_sql || ' TABLESPACE "' || p_table_space || '"';
  end if;
  l_sql := l_sql || ' as select * from cn_srp_intel_periods_all  where period_id  between  ' || p_start_period_id || ' and ' || p_end_period_id;
  EXECUTE immediate l_sql;

 SELECT COUNT(*)
     INTO l_row_count
     FROM cn_srp_intel_periods_all
    WHERE period_id BETWEEN p_start_period_id AND p_end_period_id;
  x_msg_data  := x_msg_data || l_table_name || ' count ' || l_row_count || ' : ';
  x_msg_count := x_msg_count + 1;
  p_tot_rows_count := p_tot_rows_count + l_row_count;
  insert_archive(cn_srp_intel_periods_all_id,p_cn_archive_all_s,upper(l_table_name),l_row_count,l_any_rows_to_process);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_processing:3  x_msg_data  ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_processing:3  x_return_status  ' || x_return_status);

EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'F';
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables_processing:exception others: ' || SQLERRM(SQLCODE()) );
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  --DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
  RAISE	FND_API.G_EXC_ERROR;
END archive_cn_tables_processing;

-- API name  : archive_cn_tables
-- Type : private.
-- Pre-reqs :
PROCEDURE archive_cn_tables
  (
    p_run_mode          IN VARCHAR2,
    p_start_period_id IN NUMBER,
    p_end_period_id   IN NUMBER,
    x_start_date      IN DATE,
    x_end_date        IN DATE,
    p_table_space     IN VARCHAR2,
    p_org_id          IN NUMBER,
    x_msg_count       IN OUT nocopy NUMBER,
    x_msg_data        IN OUT nocopy VARCHAR2,
    x_return_status OUT nocopy      VARCHAR2 )
IS
l_cn_archive_all_s NUMBER;
l_tot_rows_count   NUMBER;
l_run_mode         varchar2(15);

BEGIN
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables:  start  ');
    l_tot_rows_count := 0;
    x_msg_count      := 0;

  if(p_run_mode = 'A') Then
    l_run_mode      := 'ARCHIVE';
  elsif (p_run_mode = 'P') Then
    l_run_mode      := 'PURGE';
  end if;

  SELECT CN_ARC_AUDIT_ALL_S.nextval INTO l_cn_archive_all_s FROM dual;
  debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables: l_cn_archive_all_s : ' || l_cn_archive_all_s);
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables before archive_cn_tables_transactions  ');

  archive_cn_tables_transactions ( p_start_period_id => p_start_period_id,
                                    p_end_period_id => p_end_period_id,
                                    x_start_date => x_start_date,
                                    x_end_date => x_end_date,
                                    p_table_space => p_table_space,
                                    p_cn_archive_all_s => l_cn_archive_all_s,
                                    p_tot_rows_count => l_tot_rows_count,
                                    x_msg_count => x_msg_count,
                                    x_msg_data => x_msg_data,
                                    x_return_status => x_return_status );
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables after archive_cn_tables_transactions x_return_status ' || x_return_status);
  IF(x_return_status <> 'S') THEN
    ROLLBACK;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables before archive_cn_tables_references  ');
  archive_cn_tables_references (  p_start_period_id => p_start_period_id,
                                    p_end_period_id => p_end_period_id,
                                    x_start_date => x_start_date,
                                    x_end_date => x_end_date,
                                    p_table_space => p_table_space,
                                    p_cn_archive_all_s => l_cn_archive_all_s,
                                    p_tot_rows_count => l_tot_rows_count,
                                    x_msg_count => x_msg_count,
                                    x_msg_data => x_msg_data,
                                    x_return_status => x_return_status );
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables after archive_cn_tables_references x_return_status ' || x_return_status);
  IF(x_return_status <> 'S') THEN
    ROLLBACK;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables before archive_cn_tables_subledgers  ');
  archive_cn_tables_subledgers (  p_start_period_id => p_start_period_id,
                                    p_end_period_id => p_end_period_id,
                                    x_start_date => x_start_date,
                                    x_end_date => x_end_date,
                                    p_table_space => p_table_space,
                                    p_cn_archive_all_s => l_cn_archive_all_s,
                                    p_tot_rows_count => l_tot_rows_count,
                                    x_msg_count => x_msg_count,
                                    x_msg_data => x_msg_data,
                                    x_return_status => x_return_status );
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables after archive_cn_tables_subledgers x_return_status ' || x_return_status);
  IF(x_return_status <> 'S') THEN
    ROLLBACK;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables before archive_cn_tables_processing  ');
  archive_cn_tables_processing (  p_start_period_id => p_start_period_id,
                                    p_end_period_id => p_end_period_id,
                                    x_start_date => x_start_date,
                                    x_end_date => x_end_date,
                                    p_table_space => p_table_space,
                                    p_cn_archive_all_s => l_cn_archive_all_s,
                                    p_tot_rows_count => l_tot_rows_count,
                                    x_msg_count => x_msg_count,
                                    x_msg_data => x_msg_data,
                                    x_return_status => x_return_status );
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables after archive_cn_tables_processing x_return_status ' || x_return_status);
  IF(x_return_status <> 'S') THEN
    ROLLBACK;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


   INSERT
     INTO cn_arc_audit_all
     (ARCHIVE_PURGE_ID,TOT_AP_TABLES_COUNT,TOT_AP_ROWS,ARCHIVE_PURGE_DATE,START_PERIOD_ID,END_PERIOD_ID,ORG_ID,RUN_MODE,
     ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
     VALUES
    (
      l_cn_archive_all_s,
      x_msg_count       ,
      l_tot_rows_count  ,
      sysdate           ,
      p_start_period_id ,
      p_end_period_id   ,
      p_org_id          ,
      l_run_mode        ,
      NULL              ,
      NULL              ,
      NULL              ,
      NULL              ,
      NULL              ,
      fnd_global.user_id,
      sysdate           ,
      fnd_global.user_id,
      sysdate           ,
      fnd_global.user_id
    );
  COMMIT;
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables: end : ');

  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables x_return_status ' || x_return_status);
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := 'F';
  debugmsg('CN_PURGE_TABLES_PVT.archive_cn_tables:exception others: ' || SQLERRM(SQLCODE()) );
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  --DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
  RAISE	FND_API.G_EXC_ERROR;
END archive_cn_tables;

-- API name  : purge_cn_tables
-- Type : private.
-- Pre-reqs :
PROCEDURE purge_cn_tables
  (
    p_run_mode          IN VARCHAR2,
    p_start_period_id IN NUMBER,
    p_end_period_id   IN NUMBER,
    x_start_date      IN DATE,
    x_end_date        IN DATE,
    p_org_id          IN NUMBER,
    p_worker_id       IN NUMBER,
    p_no_of_workers   IN NUMBER,
    p_batch_size      IN NUMBER,
    x_msg_count OUT nocopy     NUMBER,
    x_msg_data OUT nocopy      VARCHAR2,
    x_return_status OUT nocopy VARCHAR2 )
IS
  l_tot_rows_count   NUMBER;
  l_cn_archive_all_s NUMBER;
  l_run_mode         varchar2(15);
BEGIN
  debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables: start: ');
  l_tot_rows_count := 0;
  x_msg_count      := 0;

  if(p_run_mode = 'A') Then
    l_run_mode      := 'ARCHIVE';
  elsif (p_run_mode = 'P') Then
    l_run_mode      := 'PURGE';
  end if;

   SELECT CN_ARC_AUDIT_ALL_S.nextval INTO l_cn_archive_all_s FROM dual;

  debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables: l_cn_archive_all_s : ' || l_cn_archive_all_s);


  purge_cn_tables_transactions ( p_start_period_id => p_start_period_id,
                                  p_end_period_id => p_end_period_id,
                                  x_start_date => x_start_date,
                                  x_end_date => x_end_date,
                                  p_cn_archive_all_s => l_cn_archive_all_s,
                                  p_tot_rows_count => l_tot_rows_count,
                                  p_worker_id => p_worker_id,
                                  p_no_of_workers => p_no_of_workers,
                                  p_batch_size => p_batch_size,
                                  x_msg_count => x_msg_count,
                                  x_msg_data => x_msg_data,
                                  x_return_status => x_return_status);
  debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables: after purge_cn_tables_transactions x_return_status : ' || x_return_status);
  IF(x_return_status <> 'S') THEN
    ROLLBACK;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  purge_cn_tables_refrences ( p_start_period_id => p_start_period_id,
                                  p_end_period_id => p_end_period_id,
                                  x_start_date => x_start_date,
                                  x_end_date => x_end_date,
                                  p_cn_archive_all_s => l_cn_archive_all_s,
                                  p_tot_rows_count => l_tot_rows_count,
                                  p_worker_id => p_worker_id,
                                  p_no_of_workers => p_no_of_workers,
                                  p_batch_size => p_batch_size,
                                  x_msg_count => x_msg_count,
                                  x_msg_data => x_msg_data,
                                  x_return_status => x_return_status);
 debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables: after purge_cn_tables_refrences x_return_status : ' || x_return_status);
  IF(x_return_status                           <> 'S') THEN
    ROLLBACK;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  audit_purge_cn_subledgers ( p_start_period_id => p_start_period_id,
                                  p_end_period_id => p_end_period_id,
                                  x_start_date => x_start_date,
                                  x_end_date => x_end_date,
                                  p_cn_archive_all_s => l_cn_archive_all_s,
                                  p_tot_rows_count => l_tot_rows_count,
                                  p_worker_id => p_worker_id,
                                  p_no_of_workers => p_no_of_workers,
                                  p_batch_size => p_batch_size,
                                  x_msg_count => x_msg_count,
                                  x_msg_data => x_msg_data,
                                  x_return_status => x_return_status);
debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables: after purge_cn_tables_refrences x_return_status : ' || x_return_status);
  IF(x_return_status                            <> 'S') THEN
    ROLLBACK;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  purge_cn_tables_processing ( p_start_period_id => p_start_period_id,
                                  p_end_period_id => p_end_period_id,
                                  x_start_date => x_start_date,
                                  x_end_date => x_end_date,
                                  p_cn_archive_all_s => l_cn_archive_all_s,
                                  p_tot_rows_count => l_tot_rows_count,
                                  p_worker_id => p_worker_id,
                                  p_no_of_workers => p_no_of_workers,
                                  p_batch_size => p_batch_size,
                                  x_msg_count => x_msg_count,
                                  x_msg_data => x_msg_data,
                                  x_return_status => x_return_status);
debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables: after purge_cn_tables_refrences x_return_status : ' || x_return_status);
  IF(x_return_status                            <> 'S') THEN
    ROLLBACK;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables: x_return_status : ' || x_return_status);


  COMMIT;
  debugmsg('CN_PURGE_TABLES_PVT.purge_cn_tables: end : ');

EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := 'F';
  debugmsg
  (
    'CN_PURGE_TABLES_PVT.purge_cn_tables:exception others: ' || SQLERRM(SQLCODE())
  )
  ;
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  RAISE	FND_API.G_EXC_ERROR;
  --DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
END purge_cn_tables;

-- API name  : purge_cn_tables
-- Type : private.
-- Pre-reqs :
PROCEDURE audit_purge_cn_tables
  (
    p_run_mode          IN VARCHAR2,
    p_start_period_id IN NUMBER,
    p_end_period_id   IN NUMBER,
    p_org_id          IN NUMBER,
    p_worker_id       IN NUMBER,
    p_no_of_workers   IN NUMBER,
    p_batch_size      IN NUMBER,
    x_msg_count OUT nocopy     NUMBER,
    x_msg_data OUT nocopy      VARCHAR2,
    x_return_status OUT nocopy VARCHAR2 )
IS
  l_tot_rows_count   NUMBER;
  l_cn_archive_all_s NUMBER;
  l_run_mode         varchar2(15);
  x_start_date      DATE;
  x_end_date        DATE;
BEGIN
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_tables: start: ');
  l_tot_rows_count := 0;
  x_msg_count      := 0;

  if(p_run_mode = 'A') Then
    l_run_mode      := 'ARCHIVE';
  elsif (p_run_mode = 'P') Then
    l_run_mode      := 'PURGE';
  end if;

  cn_periods_api.set_dates(p_start_period_id, p_end_period_id, p_org_id, x_start_date, x_end_date);

      debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_tables: x_start_date: ' || x_start_date);
      debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_tables: x_end_date: ' || x_end_date);

   SELECT CN_ARC_AUDIT_ALL_S.nextval INTO l_cn_archive_all_s FROM dual;

  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_tables: l_cn_archive_all_s : ' || l_cn_archive_all_s);


  audit_purge_cn_transactions ( p_start_period_id => p_start_period_id,
                                  p_end_period_id => p_end_period_id,
                                  x_start_date => x_start_date,
                                  x_end_date => x_end_date,
                                  p_cn_archive_all_s => l_cn_archive_all_s,
                                  p_tot_rows_count => l_tot_rows_count,
                                  p_worker_id => p_worker_id,
                                  p_no_of_workers => p_no_of_workers,
                                  p_batch_size => p_batch_size,
                                  x_msg_count => x_msg_count,
                                  x_msg_data => x_msg_data,
                                  x_return_status => x_return_status);
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_tables: after purge_cn_tables_transactions x_return_status : ' || x_return_status);
  IF(x_return_status <> 'S') THEN
    ROLLBACK;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  audit_purge_cn_refrences ( p_start_period_id => p_start_period_id,
                                  p_end_period_id => p_end_period_id,
                                  x_start_date => x_start_date,
                                  x_end_date => x_end_date,
                                  p_cn_archive_all_s => l_cn_archive_all_s,
                                  p_tot_rows_count => l_tot_rows_count,
                                  p_worker_id => p_worker_id,
                                  p_no_of_workers => p_no_of_workers,
                                  p_batch_size => p_batch_size,
                                  x_msg_count => x_msg_count,
                                  x_msg_data => x_msg_data,
                                  x_return_status => x_return_status);
 debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_tables: after purge_cn_tables_refrences x_return_status : ' || x_return_status);
  IF(x_return_status                           <> 'S') THEN
    ROLLBACK;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  audit_purge_cn_subledgers ( p_start_period_id => p_start_period_id,
                                  p_end_period_id => p_end_period_id,
                                  x_start_date => x_start_date,
                                  x_end_date => x_end_date,
                                  p_cn_archive_all_s => l_cn_archive_all_s,
                                  p_tot_rows_count => l_tot_rows_count,
                                  p_worker_id => p_worker_id,
                                  p_no_of_workers => p_no_of_workers,
                                  p_batch_size => p_batch_size,
                                  x_msg_count => x_msg_count,
                                  x_msg_data => x_msg_data,
                                  x_return_status => x_return_status);
debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_tables: after purge_cn_tables_refrences x_return_status : ' || x_return_status);
  IF(x_return_status                            <> 'S') THEN
    ROLLBACK;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  audit_purge_cn_processing ( p_start_period_id => p_start_period_id,
                                  p_end_period_id => p_end_period_id,
                                  x_start_date => x_start_date,
                                  x_end_date => x_end_date,
                                  p_cn_archive_all_s => l_cn_archive_all_s,
                                  p_tot_rows_count => l_tot_rows_count,
                                  p_worker_id => p_worker_id,
                                  p_no_of_workers => p_no_of_workers,
                                  p_batch_size => p_batch_size,
                                  x_msg_count => x_msg_count,
                                  x_msg_data => x_msg_data,
                                  x_return_status => x_return_status);
debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_tables: after purge_cn_tables_refrences x_return_status : ' || x_return_status);
  IF(x_return_status                            <> 'S') THEN
    ROLLBACK;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_tables: x_return_status : ' || x_return_status);


   INSERT
     INTO cn_arc_audit_all
      (ARCHIVE_PURGE_ID,TOT_AP_TABLES_COUNT,TOT_AP_ROWS,ARCHIVE_PURGE_DATE,START_PERIOD_ID,END_PERIOD_ID,ORG_ID,RUN_MODE,
     ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
     VALUES
    (
      l_cn_archive_all_s,
      x_msg_count       ,
      l_tot_rows_count  ,
      sysdate           ,
      p_start_period_id ,
      p_end_period_id   ,
      p_org_id          ,
      l_run_mode        ,
      NULL              ,
      NULL              ,
      NULL              ,
      NULL              ,
      NULL              ,
      fnd_global.user_id,
      sysdate           ,
      fnd_global.user_id,
      sysdate           ,
      fnd_global.user_id
    );
  COMMIT;
  debugmsg('CN_PURGE_TABLES_PVT.audit_purge_cn_tables: end : ');

EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := 'F';
  debugmsg
  (
    'CN_PURGE_TABLES_PVT.audit_purge_cn_tables:exception others: ' || SQLERRM(SQLCODE())
  )
  ;
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  RAISE	FND_API.G_EXC_ERROR;
  --DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
END audit_purge_cn_tables;

-- API name  : archive_purge_cn_tables
-- Type : public.
-- Pre-reqs :
PROCEDURE archive_purge_cn_tables
  (
    errbuf OUT NOCOPY  VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_run_mode          IN VARCHAR2,
    p_start_period_id   IN NUMBER,
    p_end_period_id     IN NUMBER,
    p_no_of_workers     IN NUMBER,
    p_org_id            IN NUMBER,
    p_table_space       IN VARCHAR2,
    p_worker_id         IN NUMBER,
    p_batch_size        IN NUMBER,
    p_request_id        IN NUMBER
    )
IS

  x_start_date DATE;
  x_end_date DATE;
  x_msg_count       NUMBER;
  x_msg_data        VARCHAR2(2000);
  x_return_status   VARCHAR2(1);
  l_time          VARCHAR2(20);

BEGIN
  x_msg_count     := 0;
  x_msg_data      := ':';
  x_return_status := 'S';

  debugmsg('CN_PURGE_TABLES_PVT.archive_purge_cn_tables: x_org_id: ' || p_org_id);
  debugmsg('CN_PURGE_TABLES_PVT.archive_purge_cn_tables: x_start_period_name: ' || p_start_period_id);
  debugmsg('CN_PURGE_TABLES_PVT.archive_purge_cn_tables: x_end_period_name: ' || p_end_period_id);
  debugmsg('CN_PURGE_TABLES_PVT.archive_purge_cn_tables: p_run_mode: ' || p_run_mode);
  debugmsg('CN_PURGE_TABLES_PVT.archive_purge_cn_tables: p_no_of_workers: ' || p_no_of_workers);
  debugmsg('CN_PURGE_TABLES_PVT.archive_purge_cn_tables: p_worker_id: ' || p_worker_id);
  debugmsg('CN_PURGE_TABLES_PVT.archive_purge_cn_tables: p_batch_size: ' || p_batch_size);
  debugmsg('CN_PURGE_TABLES_PVT.archive_purge_cn_tables: p_table_space: ' || p_table_space);
  debugmsg('CN_PURGE_TABLES_PVT.archive_purge_cn_tables: g_cn_debug: ' || g_cn_debug);


  cn_periods_api.set_dates(p_start_period_id, p_end_period_id, p_org_id, x_start_date, x_end_date);

  debugmsg('CN_PURGE_TABLES_PVT.archive_purge_cn_tables: x_start_date: ' || x_start_date);
  debugmsg('CN_PURGE_TABLES_PVT.archive_purge_cn_tables: x_end_date: ' || x_end_date);

  IF(p_run_mode = 'A') THEN
    archive_cn_tables ( p_run_mode => p_run_mode,
                      p_start_period_id => p_start_period_id,
                      p_end_period_id => p_end_period_id,
                      x_start_date => x_start_date,
                      x_end_date => x_end_date,
                      p_table_space => p_table_space,
                      p_org_id => p_org_id,
                      x_msg_count => x_msg_count,
                      x_msg_data => x_msg_data,
                      x_return_status => x_return_status );
    elsif (p_run_mode = 'P' ) THEN
      purge_cn_tables ( p_run_mode => p_run_mode,
                      p_start_period_id => p_start_period_id,
                      p_end_period_id => p_end_period_id,
                      x_start_date => x_start_date,
                      x_end_date => x_end_date,
                      p_org_id => p_org_id,
                      p_worker_id => p_worker_id,
                      p_no_of_workers => p_no_of_workers,
                      p_batch_size => p_batch_size,
                      x_msg_count => x_msg_count,
                      x_msg_data => x_msg_data,
                      x_return_status => x_return_status );
    end if;
    debugmsg('CN_PURGE_TABLES_PVT.archive_purge_cn_tables: x_msg_count: ' || x_msg_count);
    debugmsg('CN_PURGE_TABLES_PVT.archive_purge_cn_tables: x_msg_data: ' || x_msg_data);
    debugmsg('CN_PURGE_TABLES_PVT.archive_purge_cn_tables: x_return_status: ' || x_return_status);

    IF(x_return_status <> 'S') THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  x_return_status := 'F';
  debugmsg('CN_PURGE_TABLES_PVT.archive_purge_cn_tables:exception others: ' || SQLERRM(SQLCODE()) );
  x_msg_data   := x_msg_data || ' : ' || SQLERRM(SQLCODE());
  retcode  := 2;
  errbuf   := 'Unexpected Error : ' || SQLERRM(SQLCODE());
  RAISE	FND_API.G_EXC_ERROR;
END archive_purge_cn_tables;

END CN_PURGE_TABLES_PVT;

/
