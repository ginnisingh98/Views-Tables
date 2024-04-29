--------------------------------------------------------
--  DDL for Package Body CN_UPG_PMT_TRXNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_UPG_PMT_TRXNS_PKG" AS
-- $Header: cnvuptrxb.pls 120.9 2006/09/21 22:09:57 rnagired noship $

   PROCEDURE CommLines_Upgrade_Mgr (
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Num_Workers in number)
   IS
   BEGIN
      fnd_file.put_line(FND_FILE.LOG, 'Before CNUPGPMTCLWRKER ');
      --
      -- Manager processing for commission
      --
      AD_CONC_UTILS_PKG.submit_subrequests(
         X_errbuf=>X_errbuf,
         X_retcode=>X_retcode,
         X_WorkerConc_app_shortname=>'CN',
         X_WorkerConc_progname=>     'CNUPGPMTCLWRKER' ,
         X_batch_size=>X_batch_size,
         X_Num_Workers=>X_Num_Workers);

      fnd_file.put_line(FND_FILE.LOG, 'Completed CNUPGPMTCLWRKER ');

   END CommLines_Upgrade_Mgr;


   PROCEDURE PmtTrxns_Upgrade_Mgr (
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Num_Workers in number)
   IS
   BEGIN
      fnd_file.put_line(FND_FILE.LOG, 'Before CNUPGPMTRXWRKER ');
      --
      -- Manager processing for transactions
      --
      AD_CONC_UTILS_PKG.submit_subrequests(
         X_errbuf=>X_errbuf,
         X_retcode=>X_retcode,
         X_WorkerConc_app_shortname=>'CN',
         X_WorkerConc_progname=>     'CNUPGPMTRXWRKER' ,
         X_batch_size=>X_batch_size,
         X_Num_Workers=>X_Num_Workers);

     fnd_file.put_line(FND_FILE.LOG, 'Completed CNUPGPMTRXWRKER ');

   END PmtTrxns_Upgrade_Mgr ;


   --=======================================================================
   -- The Update_Commlines_WRK worker populates all null rows to UNPOSTED
   --=======================================================================
   PROCEDURE Update_Commlines_WRK (
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Worker_Id   in number,
                  X_Num_Workers in number)
   IS

      l_worker_id  number;
      l_product     varchar2(30) := 'CN';
      l_table_name  varchar2(30) := 'CN_COMMISSION_LINES_ALL';
      l_update_name varchar2(30) := 'CNUPMTCL.5';
      l_status      varchar2(30);
      l_industry    varchar2(30);
      l_retstatus   boolean;

      l_table_owner          varchar2(30);
      l_any_rows_to_process  boolean;

      l_start_rowid     rowid;
      l_end_rowid       rowid;
      l_rows_processed  number;


      x_return_status varchar2(1);
      x_msg_count     number;
      x_msg_data      varchar2(240);

   BEGIN

     --
     -- get schema name of the table for ROWID range processing
     --
     fnd_file.put_line(FND_FILE.LOG, 'Entering Update_Commlines_WRK ');
     l_retstatus := fnd_installation.get_app_info(l_product, l_status, l_industry, l_table_owner);

     if ((l_retstatus = FALSE) OR  (l_table_owner is null))
     then
        raise_application_error(-20001, 'Cannot get schema name for product : '||l_product);
     end if;

     fnd_file.put_line(FND_FILE.LOG, 'X_Worker_Id : '||X_Worker_Id);
     fnd_file.put_line(FND_FILE.LOG, 'X_Num_Workers : '||X_Num_Workers);

     --=========================
     -- Worker processing
     --=========================
     -- The following could be coded to use EXECUTE IMMEDIATE inorder to remove build time
     -- dependencies as the processing could potentially reference some tables that could
     -- be obsoleted in the current release

     BEGIN

           ad_parallel_updates_pkg.initialize_rowid_range(
                    ad_parallel_updates_pkg.ROWID_RANGE,
                    l_table_owner,
                    l_table_name,
                    l_update_name,
                    X_worker_id,
                    X_num_workers,
                    X_batch_size, 0);

           ad_parallel_updates_pkg.get_rowid_range(
                    l_start_rowid,
                    l_end_rowid,
                    l_any_rows_to_process,
                    X_batch_size,
                    TRUE);

           WHILE (L_ANY_ROWS_TO_PROCESS = TRUE)
           LOOP
              -----------------------------------------------------
              -- product specific processing here
              -----------------------------------------------------

              -- Code your update logic here
              fnd_file.put_line(FND_FILE.LOG, 'updating commission lines posting column to UNPOSTED ');

              update /*+ rowid(CL) */  cn_commission_lines_all cl
              set posting_status = 'UNPOSTED',
                  last_update_date = sysdate
              where posting_status is NULL
              and cl.rowid between l_start_rowid and l_end_rowid;

              l_rows_processed := SQL%ROWCOUNT;

              ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed, l_end_rowid);

              fnd_file.put_line(FND_FILE.LOG, 'Finished updating upgrade data until rowend = '||l_end_rowid);

              COMMIT;

              ad_parallel_updates_pkg.get_rowid_range(
                    l_start_rowid,
                    l_end_rowid,
                    l_any_rows_to_process,
                    X_batch_size,
                    FALSE);

          END LOOP;

        X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

     EXCEPTION
          WHEN OTHERS THEN
            X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
            raise;
     END;
   END Update_Commlines_WRK;



   --=======================================================================
   --The Update_Pmt_Trxns_WRK worker migrats processed date to trxns
   --=======================================================================
   PROCEDURE Update_Pmt_Trxns_WRK (
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Worker_Id   in number,
                  X_Num_Workers in number)
   IS
      l_worker_id  number;
      l_product     varchar2(30) := 'CN';
      l_table_name  varchar2(30) := 'CN_PAYMENT_TRANSACTIONS_ALL';
      l_update_name varchar2(30) := 'CNUPPMTRX.102';
      l_status      varchar2(30);
      l_industry    varchar2(30);
      l_retstatus   boolean;

      l_table_owner          varchar2(30);
      l_any_rows_to_process  boolean;

      l_start_rowid     rowid;
      l_end_rowid       rowid;
      l_rows_processed  number;
      l_row_count_headers number;
      l_row_count_plans  number;
      l_row_count_rest   number ;

      x_return_status varchar2(1);
      x_msg_count     number;
      x_msg_data      varchar2(240);

   BEGIN

     fnd_file.put_line(FND_FILE.LOG, 'Entering Update_Pmt_Trxns_WRK  ');
     -- get schema name of the table for ROWID range processing
     l_retstatus := fnd_installation.get_app_info(l_product, l_status, l_industry, l_table_owner);

     if ((l_retstatus = FALSE) OR  (l_table_owner is null))
     then
        raise_application_error(-20001, 'Cannot get schema name for product : '||l_product);
     end if;

     fnd_file.put_line(FND_FILE.LOG, 'X_Worker_Id : '||X_Worker_Id);
     fnd_file.put_line(FND_FILE.LOG, 'X_Num_Workers : '||X_Num_Workers);

     --=========================
     -- Worker processing
     --=========================
     -- The following could be coded to use EXECUTE IMMEDIATE inorder to remove build time
     -- dependencies as the processing could potentially reference some tables that could
     -- be obsoleted in the current release
     BEGIN

           ad_parallel_updates_pkg.initialize_rowid_range(
                    ad_parallel_updates_pkg.ROWID_RANGE,
                    l_table_owner,
                    l_table_name,
                    l_update_name,
                    X_worker_id,
                    X_num_workers,
                    X_batch_size, 0);

           ad_parallel_updates_pkg.get_rowid_range(
                    l_start_rowid,
                    l_end_rowid,
                    l_any_rows_to_process,
                    X_batch_size,
                    TRUE);

           WHILE (L_ANY_ROWS_TO_PROCESS = TRUE)
           LOOP
                  -----------------------------------------------------
                  -- product specific processing here
                  -----------------------------------------------------



      -- update the processed date with a value from either
      -- 1) commission header 2) end of compplan 3) period_id

      UPDATE
      (
        SELECT /*+ rowid(pmt) use_nl(ch) */
            pmt.processed_date,
            pmt.last_update_login,
            pmt.last_update_date,
            CASE
            WHEN  (ch.commission_header_id IS NOT NULL) THEN ch.processed_date
            ELSE  (
                  select nvl(greatest(least(p.end_date,
                                              nvl(
                                                 (select -- return value if date is in period
                                                    case
                                                    when pln.end_date between p.start_date and p.end_date then pln.end_date
                                                    else null
                                                    end
                                                    from cn_srp_plan_assigns_all pln
                                                    where srp_plan_assign_id =
                                                      (select srp_plan_assign_id
                                                         from cn_srp_period_quotas_all
                                                        where salesrep_id = pmt.credited_salesrep_id
                                                          and period_id   = pmt.pay_period_id
                                                          and quota_id    = pmt.quota_id
                                                          and org_id      = pmt.org_id
                                                          and rownum=1)
                                                   )
                                               ,p.start_date),
                                              nvl(q.end_date,p.end_date)
                                             ),
                                           p.start_date
                                     ), p.start_date
                           )
                  from  cn_period_statuses_all p, cn_quotas_all q
                  where p.period_id   = pmt.pay_period_id
                    and q.quota_id(+) = pmt.quota_id
                    and q.org_id(+)   = p.org_id
                    and p.org_id      = pmt.org_id
              )
        END   AS new_processed_date
        FROM  cn_payment_transactions_all pmt, cn_commission_headers_all ch
        WHERE pmt.rowid BETWEEN l_start_rowid and l_end_rowid
        AND   pmt.commission_header_id = ch.commission_header_id (+)
        AND   pmt.org_id  = ch.org_id (+)
      ) SET   processed_date    = new_processed_date,
              last_update_login = -98989898,
              last_update_date  = sysdate;




    l_rows_processed := SQL%ROWCOUNT;
    fnd_file.put_line(FND_FILE.LOG, 'Rows with plans ending : '|| l_rows_processed );
    ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,l_end_rowid);
    COMMIT;
    fnd_file.put_line(FND_FILE.LOG, 'Finished updating upgrade data until rowend = '||l_end_rowid);
    ad_parallel_updates_pkg.get_rowid_range(
        l_start_rowid,
        l_end_rowid,
        l_any_rows_to_process,
        X_batch_size,
        FALSE);

          END LOOP;

        X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

     EXCEPTION
          WHEN OTHERS THEN
            X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
            raise;
     END;
   END Update_Pmt_Trxns_WRK;


END CN_UPG_PMT_TRXNS_PKG;

/
