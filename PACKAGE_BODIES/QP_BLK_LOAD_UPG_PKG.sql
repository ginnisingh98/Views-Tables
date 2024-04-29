--------------------------------------------------------
--  DDL for Package Body QP_BLK_LOAD_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_BLK_LOAD_UPG_PKG" AS
/* $Header: QPXBLKUB.pls 120.6 2007/04/09 15:42:15 rassharm ship $ */
   --Primary concurrent manager for upgrade of orig_sys_ref columns
   PROCEDURE Blk_Load_Upg_Hdr_MGR(
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Num_Workers in number
                  )
   IS
   BEGIN
        --
        -- Manager processing
        --
        AD_CONC_UTILS_PKG.submit_subrequests(
               X_errbuf=>X_errbuf,
               X_retcode=>X_retcode,
               X_WorkerConc_app_shortname=>'QP',
               X_WorkerConc_progname=>'QP_BLK_LOAD_UPG_HDR_WKR',
               X_batch_size=>X_batch_size,
               X_Num_Workers=>X_Num_Workers
               );

   END Blk_Load_Upg_Hdr_MGR;

   --Secondary concurrent manager for upgrade of orig_sys_ref columns
   PROCEDURE Blk_Load_Upg_Hdr_WKR(
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  X_batch_size  in number,
                  X_Worker_Id   in number,
                  X_Num_Workers in number
                  )
   IS
      --Variable for QP_LIST_HEADERS_B updation
      l_worker_id_hdr  number;
      l_product_hdr     varchar2(30) := 'QP';
      l_table_name_hdr  varchar2(30) := 'QP_LIST_HEADERS_B';
--      l_update_name_hdr varchar2(30) := 'UPDATE LIST HEADERS';
       l_update_name_hdr varchar2(30) := 'HDR::'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SS'); -- modified by rassharm for unique name
      l_status_hdr      varchar2(30);
      l_industry_hdr    varchar2(30);
      l_retstatus_hdr   boolean;
      l_table_owner_hdr          varchar2(30);
      l_any_rows_to_process_hdr  boolean;
      l_start_rowid_hdr     rowid;
      l_end_rowid_hdr       rowid;
      l_rows_processed_hdr  number;



      --Variable for QP_LIST_LINES updation
      l_worker_id_line  number;
      l_product_line     varchar2(30) := 'QP';
      l_table_name_line  varchar2(30) := 'QP_LIST_LINES';
    --  l_update_name_line varchar2(30) := 'UPDATE LIST LINES';
       l_update_name_line varchar2(30) := 'LINE::'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SS');  -- modified by rassharm for unique name
      l_status_line      varchar2(30);
      l_industry_line    varchar2(30);
      l_retstatus_line   boolean;
      l_table_owner_line          varchar2(30);
      l_any_rows_to_process_line  boolean;
      l_start_rowid_line     rowid;
      l_end_rowid_line       rowid;
      l_rows_processed_line  number;



      --Variable for QP_PRICING_ATTRIBUTES updation
      l_worker_id_pa  number;
      l_product_pa     varchar2(30) := 'QP';
      l_table_name_pa  varchar2(30) := 'QP_PRICING_ATTRIBUTES';
      --l_update_name_pa varchar2(30) := 'UPDATE PRICING ATTRIBUTES';
       l_update_name_pa varchar2(30) := 'ATTR::'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SS');   -- modified by rassharm for unique name
      l_status_pa      varchar2(30);
      l_industry_pa    varchar2(30);
      l_retstatus_pa   boolean;
      l_table_owner_pa          varchar2(30);
      l_any_rows_to_process_pa  boolean;
      l_start_rowid_pa     rowid;
      l_end_rowid_pa       rowid;
      l_rows_processed_pa  number;



      --Variable for QP_QUALIFIERS updation
      l_worker_id_qual  number;
      l_product_qual     varchar2(30) := 'QP';
      l_table_name_qual  varchar2(30) := 'QP_QUALIFIERS';
      l_update_name_qual varchar2(30) := 'QUAL::'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SS');  -- modified by rassharm for unique name
      l_status_qual      varchar2(30);
      l_industry_qual    varchar2(30);
      l_retstatus_qual   boolean;
      l_table_owner_qual          varchar2(30);
      l_any_rows_to_process_qual  boolean;
      l_start_rowid_qual     rowid;
      l_end_rowid_qual       rowid;
      l_rows_processed_qual  number;

   BEGIN
     --Prepare for Header update
     l_retstatus_hdr := fnd_installation.get_app_info(
                        l_product_hdr, l_status_hdr, l_industry_hdr, l_table_owner_hdr);
     if ((l_retstatus_hdr = FALSE)
         OR
         (l_table_owner_hdr is null))
     then
        raise_application_error(-20001,
           'Cannot get schema name for product : '||l_product_hdr);
     end if;



     --Prepare for Line update
     l_retstatus_line := fnd_installation.get_app_info(
                        l_product_line, l_status_line, l_industry_line, l_table_owner_line);
     if ((l_retstatus_line = FALSE)
         OR
         (l_table_owner_line is null))
     then
        raise_application_error(-20001,
           'Cannot get schema name for product : '||l_product_line);
     end if;



     --Prepare for Pricing Attribute update
     l_retstatus_pa := fnd_installation.get_app_info(
                        l_product_pa, l_status_pa, l_industry_pa, l_table_owner_pa);
     if ((l_retstatus_pa = FALSE)
         OR
         (l_table_owner_pa is null))
     then
        raise_application_error(-20001,
           'Cannot get schema name for product : '||l_product_pa);
     end if;



     --Prepare for Qualifier update
     l_retstatus_qual := fnd_installation.get_app_info(
                        l_product_qual, l_status_qual, l_industry_qual, l_table_owner_qual);
     if ((l_retstatus_qual = FALSE)
         OR
         (l_table_owner_qual is null))
     then
        raise_application_error(-20001,
           'Cannot get schema name for product : '||l_product_qual);
     end if;

     fnd_file.put_line(FND_FILE.LOG, '  X_Worker_Id : '||X_Worker_Id);
     fnd_file.put_line(FND_FILE.LOG, 'X_Num_Workers : '||X_Num_Workers);

     BEGIN
           --Initialize Header Update
           ad_parallel_updates_pkg.initialize_rowid_range(
                    ad_parallel_updates_pkg.ROWID_RANGE,
                    l_table_owner_hdr,
                    l_table_name_hdr,
                    l_update_name_hdr,
                    X_worker_id,
                    X_num_workers,
                    X_batch_size, 0);
           ad_parallel_updates_pkg.get_rowid_range(
                    l_start_rowid_hdr,
                    l_end_rowid_hdr,
                    l_any_rows_to_process_hdr,
                    X_batch_size,
                    TRUE);
           --Update The Header
           while (l_any_rows_to_process_hdr = TRUE)
           loop
              Update qp_list_headers_b qplh1
              Set qplh1.orig_system_header_ref = 'INT'||to_char(qplh1.list_header_id)
              where qplh1.orig_system_header_ref is null
              and qplh1.rowid between l_start_rowid_hdr and l_end_rowid_hdr;
              l_rows_processed_hdr := SQL%ROWCOUNT;
              ad_parallel_updates_pkg.processed_rowid_range(
                  l_rows_processed_hdr,
                  l_end_rowid_hdr);
              commit;
              ad_parallel_updates_pkg.get_rowid_range(
                 l_start_rowid_hdr,
                 l_end_rowid_hdr,
                 l_any_rows_to_process_hdr,
                 X_batch_size,
                 FALSE);
           end loop;
           X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;



           --Initialize Line Update
           ad_parallel_updates_pkg.initialize_rowid_range(
                    ad_parallel_updates_pkg.ROWID_RANGE,
                    l_table_owner_line,
                    l_table_name_line,
                    l_update_name_line,
                    X_worker_id,
                    X_num_workers,
                    X_batch_size, 0);
           ad_parallel_updates_pkg.get_rowid_range(
                    l_start_rowid_line,
                    l_end_rowid_line,
                    l_any_rows_to_process_line,
                    X_batch_size,
                    TRUE);
           --Update The Line
           while (l_any_rows_to_process_line = TRUE)
           loop
	      update qp_list_lines l
      	      set   l.orig_sys_line_ref=to_char(l.list_line_id),
	            l.orig_sys_header_ref=
	            (
	             select nvl(h.orig_system_header_ref,'INT'||to_char(h.list_header_id))
                 from qp_list_headers_b h
	             where h.list_header_id = l.list_header_id
	            )
	      where l.orig_sys_line_ref is null
	      and l.rowid between l_start_rowid_line and l_end_rowid_line;
              l_rows_processed_line := SQL%ROWCOUNT;
              ad_parallel_updates_pkg.processed_rowid_range(
                  l_rows_processed_line,
                  l_end_rowid_line);
              commit;
              ad_parallel_updates_pkg.get_rowid_range(
                 l_start_rowid_line,
                 l_end_rowid_line,
                 l_any_rows_to_process_line,
                 X_batch_size,
                 FALSE);
           end loop;
           X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;



           --Initialize Pricing Attribute Update
           ad_parallel_updates_pkg.initialize_rowid_range(
                    ad_parallel_updates_pkg.ROWID_RANGE,
                    l_table_owner_pa,
                    l_table_name_pa,
                    l_update_name_pa,
                    X_worker_id,
                    X_num_workers,
                    X_batch_size, 0);
           ad_parallel_updates_pkg.get_rowid_range(
                    l_start_rowid_pa,
                    l_end_rowid_pa,
                    l_any_rows_to_process_pa,
                    X_batch_size,
                    TRUE);
           --Update The Pricing Attribute
           while (l_any_rows_to_process_pa = TRUE)
           loop
	      update qp_pricing_attributes p
	      set p.ORIG_SYS_PRICING_ATTR_REF=to_char(p.PRICING_ATTRIBUTE_ID),
	          p.orig_sys_header_ref=
	          (
	           select nvl(h.orig_system_header_ref,'INT'||to_char(h.list_header_id))
               from qp_list_headers_b h
	           where h.list_header_id = p.list_header_id
	          ),
	          p.orig_sys_line_ref=
	          (
	           select nvl(l.orig_sys_line_ref,l.list_line_id)
               from qp_list_lines l
	           where l.list_line_id = p.list_line_id
	          )
	      where p.ORIG_SYS_PRICING_ATTR_REF is null
	      and p.rowid between l_start_rowid_pa and l_end_rowid_pa;
              l_rows_processed_pa := SQL%ROWCOUNT;
              ad_parallel_updates_pkg.processed_rowid_range(
                  l_rows_processed_pa,
                  l_end_rowid_pa);
              commit;
              ad_parallel_updates_pkg.get_rowid_range(
                 l_start_rowid_pa,
                 l_end_rowid_pa,
                 l_any_rows_to_process_pa,
                 X_batch_size,
                 FALSE);
           end loop;
           X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;



           --Initialize Qualifier Update
           ad_parallel_updates_pkg.initialize_rowid_range(
                    ad_parallel_updates_pkg.ROWID_RANGE,
                    l_table_owner_qual,
                    l_table_name_qual,
                    l_update_name_qual,
                    X_worker_id,
                    X_num_workers,
                    X_batch_size, 0);
           ad_parallel_updates_pkg.get_rowid_range(
                    l_start_rowid_qual,
                    l_end_rowid_qual,
                    l_any_rows_to_process_qual,
                    X_batch_size,
                    TRUE);
           --Update The Qualifier
           while (l_any_rows_to_process_qual = TRUE)
           loop
	      update qp_qualifiers q
	      set q.orig_sys_qualifier_ref=to_char(q.qualifier_id),
	          q.orig_sys_header_ref=
	          (
	           select nvl(h.orig_system_header_ref,'INT'||to_char(h.list_header_id))
               from qp_list_headers_b h
	           where h.list_header_id = q.list_header_id
	          )
	      where q.orig_sys_qualifier_ref is null
	      and q.list_header_id is not null
	      and q.rowid between l_start_rowid_qual and l_end_rowid_qual;
              l_rows_processed_qual := SQL%ROWCOUNT;
              ad_parallel_updates_pkg.processed_rowid_range(
                  l_rows_processed_qual,
                  l_end_rowid_qual);
              commit;
              ad_parallel_updates_pkg.get_rowid_range(
                 l_start_rowid_qual,
                 l_end_rowid_qual,
                 l_any_rows_to_process_qual,
                 X_batch_size,
                 FALSE);
           end loop;
           X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

     EXCEPTION
          WHEN OTHERS THEN
            X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
            raise;
     END;

   END Blk_Load_Upg_Hdr_WKR;

END QP_BLK_LOAD_UPG_PKG;

/
