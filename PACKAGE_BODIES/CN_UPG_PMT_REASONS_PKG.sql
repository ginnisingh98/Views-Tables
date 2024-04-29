--------------------------------------------------------
--  DDL for Package Body CN_UPG_PMT_REASONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_UPG_PMT_REASONS_PKG" AS
-- $Header: cnvupnob.pls 120.3 2006/06/13 23:40:38 sbadami noship $

   PROCEDURE Notes_Mgr(
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Num_Workers in number)
   IS
   BEGIN
	  --
	  -- Manager processing
	  --
	  AD_CONC_UTILS_PKG.submit_subrequests(
		 X_errbuf=>X_errbuf,
		 X_retcode=>X_retcode,
		 X_WorkerConc_app_shortname=>'CN',
		 X_WorkerConc_progname=>'CNUPGPMTREASONSWKR',
		 X_batch_size=>X_batch_size,
		 X_Num_Workers=>X_Num_Workers);
   END Notes_Mgr;

   PROCEDURE Notes_Worker(
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Worker_Id   in number,
                  X_Num_Workers in number) IS

      l_worker_id  number;
      l_product     varchar2(30) := 'CN';
      l_table_name  varchar2(30) := 'CN_REASONS_ALL';
      l_update_name varchar2(30) := 'cnupreas.sql';
      l_status      varchar2(30);
      l_industry    varchar2(30);
      l_retstatus   boolean;

      l_table_owner          varchar2(30);
      l_any_rows_to_process  boolean;

      l_start_rowid     rowid;
      l_end_rowid       rowid;
      l_rows_processed  number;


      cursor get_reasons is
      select /*+ ROWID(r) */ r.upd_table_id,
             r.updated_table,
             decode(r.lookup_type, 'ANALYST_NOTE_REASON', dbms_lob.substr(r.reason),
                    l.meaning) note,
             decode(r.lookup_type, 'ANALYST_NOTE_REASON',
                    decode(r.reason_code, 'USER_DEFINED', 'CN_USER', 'CN_SYSGEN'),
                    'CN_SYSGEN') note_type,
             r.reason_id, r.created_by, r.creation_date, 0 id, r.rowid rowid1
       from cn_reasons_all r, cn_lookups l
       where r.rowid between l_start_rowid and l_end_rowid
         and r.attribute1 is null
         and l.lookup_type (+) = r.lookup_type
         and l.lookup_code (+) = r.reason_code;

         x_return_status varchar2(1);
         x_msg_count     number;
         x_msg_data      varchar2(240);

         type num_tbl  is table of number;
         type var_tbl  is table of varchar2(30);
         type long_tbl is table of varchar2(4000);
         type dat_tbl  is table of date;
         type rowid_tbl_type is table of rowid;

         l_upd_id_tbl    num_tbl;
         l_upd_tbl       var_tbl;
         l_note_tbl      long_tbl;
         l_note_type_tbl var_tbl;
         l_reas_id_tbl   num_tbl;
         l_cre_by_tbl    num_tbl;
         l_cre_date_tbl  dat_tbl;
         x_note_id_tbl   num_tbl;
         l_rowid_tbl     rowid_tbl_type;


   BEGIN

     --
     -- get schema name of the table for ROWID range processing
     --
     l_retstatus := fnd_installation.get_app_info(
                        l_product, l_status, l_industry, l_table_owner);

     if ((l_retstatus = FALSE)
         OR
         (l_table_owner is null))
     then
        raise_application_error(-20001,
           'Cannot get schema name for product : '||l_product);
     end if;

     fnd_file.put_line(FND_FILE.LOG, 'X_Worker_Id : '||X_Worker_Id);
     fnd_file.put_line(FND_FILE.LOG, 'X_Num_Workers : '||X_Num_Workers);

     --
     -- Worker processing
     --

     --
     -- The following could be coded to use EXECUTE IMMEDIATE inorder to remove build time
     -- dependencies as the processing could potentially reference some tables that could
     -- be obsoleted in the current release
     --
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

           while (l_any_rows_to_process = TRUE)
           loop
              -----------------------------------------------------
              --
              -- product specific processing here
              --
              --
              -----------------------------------------------------

              --
              -- Code your update logic here
              --
	      -- clean out dangling junk records
	      fnd_file.put_line(FND_FILE.LOG, 'About to clean out dangling junk records');
	      delete /*+ ROWID(r) */ from cn_reasons_all r
		where rowid between l_start_rowid and l_end_rowid
		  and (updated_table = 'CN_PAYMENT_WORKSHEETS' and not exists
		(select 1 from cn_payment_worksheets_all
		  where payment_worksheet_id = upd_table_id)
		or updated_table = 'CN_PAYRUNS' and not exists
		(select 1 from cn_payruns_all
		  where payrun_id = upd_table_id));

	      -- collect data to upgrade
	      fnd_file.put_line(FND_FILE.LOG, 'About to collect data to upgrade');
	      open  get_reasons;
	      fetch get_reasons bulk collect into
		l_upd_id_tbl, l_upd_tbl, l_note_tbl, l_note_type_tbl, l_reas_id_tbl,
		l_cre_by_tbl, l_cre_date_tbl, x_note_id_tbl,l_rowid_tbl;
	      close get_reasons;
              fnd_file.put_line(FND_FILE.LOG, 'Finished collecting data to upgrade');

	      -- if any records to process
	      if l_upd_id_tbl.count > 0 then
	         fnd_file.put_line(FND_FILE.LOG, 'About to create notes ' || l_upd_id_tbl.count);
		 for c in l_upd_id_tbl.first..l_upd_id_tbl.last loop
		    -- create JTF note
		    jtf_notes_pub.create_note
		      (p_api_version           => 1.0,
		       x_return_status         => x_return_status,
		       x_msg_count             => x_msg_count,
		       x_msg_data              => x_msg_data,
		       p_source_object_id      => l_upd_id_tbl(c),
		       p_source_object_code    => l_upd_tbl(c),
		       p_notes                 => l_note_tbl(c),
		       p_notes_detail          => l_note_tbl(c),
		       p_entered_by            => l_cre_by_tbl(c),
		       p_entered_date          => l_cre_date_tbl(c),
		       x_jtf_note_id           => x_note_id_tbl(c),
		       p_note_type             => l_note_type_tbl(c));
		 end loop;

		 -- set flag on old data (attribute1 was never used before)
		 forall c in l_upd_id_tbl.first..l_upd_id_tbl.last
		   update cn_reasons_all
		      set attribute1 = x_note_id_tbl(c)
		    where reason_id = l_reas_id_tbl(c)
		    and rowid = l_rowid_tbl(c);

	      end if;

              l_rows_processed := SQL%ROWCOUNT;

              ad_parallel_updates_pkg.processed_rowid_range(
                  l_rows_processed,
                  l_end_rowid);

              commit;

              ad_parallel_updates_pkg.get_rowid_range(
                 l_start_rowid,
                 l_end_rowid,
                 l_any_rows_to_process,
                 X_batch_size,
                 FALSE);

           end loop;

           X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

     EXCEPTION
          WHEN OTHERS THEN
            X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
            raise;
     END;
   END Notes_Worker;

END CN_UPG_PMT_REASONS_PKG;

/
