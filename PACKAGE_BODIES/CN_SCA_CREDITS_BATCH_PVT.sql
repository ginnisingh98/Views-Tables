--------------------------------------------------------
--  DDL for Package Body CN_SCA_CREDITS_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SCA_CREDITS_BATCH_PVT" AS
-- $Header: cnvscapb.pls 120.3 2005/11/17 04:44:17 raramasa noship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   CN_SCA_CREDITS_BATCH_PVT
-- Purpose
--   Package Body to process the Sales Credit Allocations
--   Add the flow diagram here.
-- History
--   11/10/03   Rao.Chenna         Created
   G_PKG_NAME		CONSTANT VARCHAR2(30) := 'CN_SCA_CREDITS_BATCH_PVT';
   G_FILE_NAME          CONSTANT VARCHAR2(12) := 'cnvscapb.pls';
   no_trx               EXCEPTION;
   conc_fail            EXCEPTION;
   api_call_failed      EXCEPTION;
   g_cn_debug           VARCHAR2(1) := fnd_profile.value('CN_DEBUG');
--
PROCEDURE debugmsg(msg VARCHAR2) IS
BEGIN

    IF g_cn_debug = 'Y' THEN
        cn_message_pkg.debug(SUBSTR(msg,1,254));
    END IF;
END debugmsg;
--
--
PROCEDURE process_batch_rules(
	errbuf			OUT NOCOPY	VARCHAR2,
	retcode			OUT NOCOPY	VARCHAR2,
    	p_parent_proc_audit_id  IN 	NUMBER,
	p_physical_batch_id 	IN	NUMBER,
        p_transaction_source    IN      VARCHAR2,
	p_start_date		IN	DATE,
	p_end_date		IN	DATE	:= NULL,
	p_org_id		IN	NUMBER) IS
--+
--+ Variable Declaration
--+

   l_request_id		 	NUMBER(15) := NULL;
   l_process_audit_id     	NUMBER(15);
   l_msg_count     		NUMBER;
   l_msg_data      		VARCHAR2(2000);
   l_return_status 		VARCHAR2(30);
   l_start_id    		cn_sca_process_batches.start_id%TYPE;
   l_end_id      		cn_sca_process_batches.end_id%TYPE;
   l_org_id                	INTEGER;
   l_package_name               VARCHAR2(100);
   l_stmt                       VARCHAR2(1000);
   l_winners_sql		VARCHAR2(4000);
   l_not_allocated_sql		VARCHAR2(4000);
   l_output_sql		        VARCHAR2(4000);
   l_rec_count			NUMBER;
   l_user_id  			NUMBER(15) := fnd_global.user_id;
   l_login_id 			NUMBER(15) := fnd_global.login_id;
   l_date		        DATE := SYSDATE;

   index_ex			EXCEPTION;

--+
--+ PL/SQL Tables and Records
--+

   TYPE interface_id_tbl_type
   IS TABLE OF cn_sca_headers_interface.sca_headers_interface_id%TYPE;

   TYPE credit_rule_id_tbl_type
   IS TABLE OF cn_sca_credit_rules.sca_credit_rule_id%TYPE;

   TYPE process_status_tbl_type
   IS TABLE OF cn_sca_headers_interface.process_status%TYPE;

   TYPE rounding_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   TYPE lines_output_id_tbl_type
   IS TABLE OF cn_sca_lines_output.sca_lines_output_id%TYPE;

   TYPE sca_winners_tbl_rec_type IS RECORD (
   	interface_id_tbl	    	   interface_id_tbl_type,
	credit_rule_id_tbl		   credit_rule_id_tbl_type,
	process_status_tbl		   process_status_tbl_type);

   l_sca_winners_tbl_rec		   sca_winners_tbl_rec_type;

   TYPE rounding_tbl_rec_type IS RECORD (
        rounding_tbl		   	   rounding_tbl_type,
	lines_output_id_tbl		   lines_output_id_tbl_type,
   	interface_id_tbl	    	   interface_id_tbl_type);

   l_rounding_tbl_rec			   rounding_tbl_rec_type;

--+
--+ Cursors Section
--+

CURSOR ps_cur IS
   SELECT MAX(w.sca_headers_interface_id) sca_headers_interface_id,
          MAX(w.sca_credit_rule_id) sca_credit_rule_id,
          DECODE(SUM(NVL(l.allocation_percentage,0)),100,'ALLOCATED','REV NOT 100')
          process_status
     FROM cn_sca_winners w,
          cn_sca_lines_output l
    WHERE w.sca_headers_interface_id = l.sca_headers_interface_id
      AND w.sca_headers_interface_id BETWEEN l_start_id AND l_end_id
      AND w.role_id = l.role_id
      AND l.revenue_type = 'REVENUE'
      AND w.org_id = l.org_id
      and w.org_id = p_org_id
    GROUP BY w.sca_headers_interface_id,w.sca_credit_rule_id;

BEGIN
   --
   l_request_id 	  := fnd_global.conc_request_id;

   cn_message_pkg.begin_batch(
	x_process_type         	=> 'Batch Mode SCA',
	x_parent_proc_audit_id 	=> p_parent_proc_audit_id,
	x_process_audit_id	=> l_process_audit_id,
	x_request_id	   	=> l_request_id,
	p_org_id		=> p_org_id);

   debugmsg('Process Batch Rules: Batch Mode SCA Start');
   --dbms_output.put_line('Process Batch Rules: l_process_audit_id : '||l_process_audit_id);

   BEGIN
      SELECT start_id, end_id
        INTO l_start_id, l_end_id
        FROM cn_sca_process_batches
       WHERE sca_process_batch_id = p_physical_batch_id;
   EXCEPTION
      WHEN OTHERS THEN
         debugmsg('Process Batch Rules: Invalid Physical Batch ID');
	 RAISE;
   END;

   debugmsg('Process Batch Rules: l_start_id - '||l_start_id);
   debugmsg('Process Batch Rules: l_end_id - '||l_end_id);

   ----+
   -- Execute the dynamic package and insert data into cn_sca_matches table.
   ----+
/*
    SELECT org_id
      INTO l_org_id
      FROM cn_repositories; */

    --+
    --+ Construct the name of the dynamic package to be called to get the
    --+ the winning rule
    --+

   debugmsg('Process Batch Rules: Begin Dynamic Package Call');

   l_package_name := 'cn_sca_batch_'||LOWER(p_transaction_source)||'_'||
                       ABS(p_org_id)||'_pkg';

   l_stmt := 'BEGIN ' ||l_package_name||'.populate_matches(:p_start_date,'||
              ':p_end_date,:p_start_id,:p_end_id,:p_physical_batch_id,'||
	      ':p_transaction_source,:p_org_id,:x_return_status,:x_msg_count,'||
	      ':x_msg_data);  END;';

   BEGIN
       EXECUTE IMMEDIATE l_stmt
                USING IN p_start_date,
		      IN p_end_date,
		      IN l_start_id,
		      IN l_end_id,
		      IN p_physical_batch_id,
		      IN p_transaction_source,
		      IN p_org_id,
		      OUT l_return_status,
		      OUT l_msg_count,
		      OUT l_msg_data;

      debugmsg('Process Batch Rules: End Executing dynamic Package Call');
      debugmsg('Process Batch Rules: Records in cn_sca_matches :'||SQL%ROWCOUNT);

      COMMIT WORK;

   EXCEPTION
      WHEN OTHERS THEN
         debugmsg('Process Batch Rules: Error while executing Dynamic Package :'||SQLERRM);
         RAISE;
   END;

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
   END IF;

   ----+
   -- Populate the data from cn_sca_matches to cn_sca_winners. During this
   -- process, eliminate duplicate records and identify the unique transaction
   -- and rule combination. Get the resources, roles and allocation
   -- for this credit rule.
   ----+

   l_winners_sql :=
   'INSERT /*+ APPEND */ INTO cn_sca_winners( '||
   '   sca_credit_rule_id, '||
   '   sca_headers_interface_id, '||
   '   process_date, '||
   '   rank, '||
   '   calculated_rank, '||
   '   role_id, '||
   '   role_count, '||
   '   rev_split_pct, '||
   '   adj_rev_split_pct, '||
   '   nonrev_split_pct, '||
   '   adj_nonrev_split_pct, '||
   '   nrev_credit_split, '||
   '   created_by, '||
   '   creation_date, '||
   '   last_updated_by, '||
   '   last_update_date, '||
   '   last_update_login, '||
   '   org_id) '||
   'SELECT '||
   '   m.sca_credit_rule_id, '||
   '   l.sca_headers_interface_id, '||
   '   m.process_date, '||
   '   m.rank, '||
   '   m.calculated_rank, '||
   '   l.role_id, '||
   '   l.role_count, '||
   '   a.rev_split_pct, '||
   '   ROUND(NVL(a.rev_split_pct,0)/NVL(l.role_count,1),4) rev_net_split, '||
   '   a.nonrev_split_pct, '||
   '   DECODE(NVL(a.nrev_credit_split,''N''),''Y'', '||
   '          ROUND(NVL(a.nonrev_split_pct,0)/NVL(l.role_count,1),4), '||
   '          a.nonrev_split_pct) nrev_net_split, '||
   '   a.nrev_credit_split, :l_user_id, :l_created_date, :l_user_id, '||
   '   :l_last_update_date, :l_login_id, m.org_id '||
   ' FROM '||
   '  (SELECT sca_headers_interface_id, '||
   '          role_id, org_id, '|| -- added org_id here by raramasa
   '          count(1) role_count '||
   '     FROM cn_sca_lines_interface a '||
   '    WHERE a.org_id = :p_org_id and '||
   '          a.sca_headers_interface_id BETWEEN :l_start_id AND :l_end_id '||
   '    GROUP BY sca_headers_interface_id,role_id,org_id) l, '|| -- added org_id here
   '  (SELECT sca_headers_interface_id,process_date,sca_credit_rule_id, '||
   '          rank,calculated_rank, '||
   '	      rule_rank,org_id '||
   '     FROM '||
   '         (SELECT sca_headers_interface_id, '||
   '	             process_date, '||
   '                 sca_credit_rule_id, '||
   '                 calculated_rank, '||
   '                 rank, org_id, '|| -- added org_id here
   '                 rank() over(partition by sca_headers_interface_id '||
   '                             order by calculated_rank desc, '||
   '                             sca_credit_rule_id desc) as rule_rank '||
   '            FROM cn_sca_matches '||
   '	       WHERE org_id = :p_org_id and '||  -- added org_id here
   '                 sca_headers_interface_id BETWEEN :l_start_id AND :l_end_id) '||
   '    WHERE rule_rank = 1 '||
   '	) m, '||
   '  (SELECT a.sca_credit_rule_id,b.role_id, '||
   '          b.rev_split_pct,b.nonrev_split_pct, '||
   '          b.nrev_credit_split, '||
   '	      a.start_date,a.end_date '||
   '     FROM cn_sca_allocations a, '||
   '          cn_sca_alloc_details b '||
   '   WHERE a.org_id = :p_org_id and '||  -- added org_id here by raramasa
   '         a.sca_allocation_id = b.sca_allocation_id) a '||
   'WHERE l.sca_headers_interface_id = m.sca_headers_interface_id '||
   '  AND m.sca_credit_rule_id = a.sca_credit_rule_id '||
   '  AND l.role_id = a.role_id '||
   '  AND m.process_date BETWEEN a.start_date AND NVL(a.end_date,m.process_date) ';

   BEGIN

       EXECUTE IMMEDIATE l_winners_sql   -- added org_id here by raramasa
                USING IN l_user_id,
		      IN SYSDATE,
		      IN l_user_id,
		      IN SYSDATE,
		      IN l_login_id,
		      IN p_org_id,
		      IN l_start_id,
		      IN l_end_id,
		      IN p_org_id,
		      IN l_start_id,
		      IN l_end_id,
              IN p_org_id;

      debugmsg('Process Batch Rules: Executing Winners SQL ');
      debugmsg('Process Batch Rules: Records in cn_sca_winners :'||SQL%ROWCOUNT);

      COMMIT WORK;

   EXCEPTION
      WHEN OTHERS THEN
         debugmsg('Process Batch Rules: Executing Winners SQL :'||SQLERRM);
         RAISE;
   END;

   --+
   --+ Before populating records into cn_sca_lines_output table check whether
   --+ transactions exists with same header_id and delete them.
   --+

   DELETE cn_sca_lines_output a
    WHERE a.sca_headers_interface_id BETWEEN l_start_id AND l_end_id;

   debugmsg('Process Batch Rules: Trx deleted from cn_sca_lines_output :'||SQL%ROWCOUNT);

   COMMIT WORK;

   --+
   --+ Populate the data into cn_sca_lines_output table based on the rev and
   --+ non-revenue type.
   --+

   debugmsg('Process Batch Rules: Inserting Records Into cn_sca_lines_output');

   l_output_sql :=
      'INSERT /*+ APPEND */ INTO cn_sca_lines_output( '||
      '       sca_lines_output_id, '||
      '       sca_headers_interface_id, '||
      '       source_trx_id, '||
      '       resource_id, '||
      '       role_id, '||
      '       revenue_type, '||
      '       allocation_percentage, '||
      '       object_version_number, '||
      '       created_by, '||
      '       creation_date, '||
      '       last_updated_by, '||
      '       last_update_date, '||
      '       last_update_login, '||
      '       org_id) '||
      'SELECT cn_sca_lines_output_s.NEXTVAL, '||
      '       sca_headers_interface_id,  '||
      '       source_trx_id,  '||
      '	      resource_id,  '||
      '	      role_id, '||
      '       revenue_type,  '||
      '       DECODE(revenue_type,''REVENUE'', '||
      '	            (alloc_pct - '||
      '		     LAG(alloc_pct, 1, 0) OVER ( '||
      '	                PARTITION BY sca_headers_interface_id, role_id, revenue_type '||
      '	                    ORDER BY rn)), '||
      '		     ''NONREVENUE'', '||
      '              DECODE(nrev_credit_split,''Y'', '||
      '             (alloc_pct -  '||
      '		     LAG(alloc_pct, 1, 0) OVER (  '||
      '	                PARTITION BY sca_headers_interface_id, role_id, revenue_type '||
      '	                   ORDER BY rn)),alloc_pct)) allocation_percentage, '||
      '	      1, :l_user_id, :l_created_date, :l_user_id, :l_last_updated_date, :l_login_id, '||
      '       org_id '||
      ' FROM (SELECT a.sca_headers_interface_id,  '||
      '              b.source_trx_id,  '||
      '		     b.resource_id, '||
      '              b.role_id,  '||
      '		     c.revenue_type,  '||
      '              a.nrev_credit_split, '||
      '              DECODE(c.revenue_type,''REVENUE'', '||
      '                     ROUND(a.rev_split_pct *  '||
      '                     CUME_DIST() OVER (  '||
      '		               PARTITION BY a.sca_headers_interface_id, b.role_id, '||
      '		                            c.revenue_type   '||
      '	                           ORDER BY b.resource_id), 4), '||
      '                     ''NONREVENUE'', '||
      '                     DECODE(a.nrev_credit_split,''Y'', '||
      '                            ROUND(a.nonrev_split_pct *  '||
      '                            CUME_DIST() OVER (  '||
      '		                      PARTITION BY a.sca_headers_interface_id, b.role_id, '||
      '		                                   c.revenue_type '||
      '	                                  ORDER BY b.resource_id), 4), '||
      '	 			   ''N'',a.nonrev_split_pct)) alloc_pct, '||
      '		     ROW_NUMBER() OVER ( '||
      '		     PARTITION BY a.sca_headers_interface_id, b.role_id,  '||
      '		                  c.revenue_type  '||
      '		         ORDER BY b.resource_id) rn,   '||
      '          a.ORG_ID '||
      '          FROM cn_sca_winners a, '||
      '               cn_sca_lines_interface b, '||
      ' 	      (SELECT ''REVENUE'' revenue_type FROM dual '||
      '		       UNION ALL '||
      '		       SELECT ''NONREVENUE'' revenue_type FROM dual)c '||
      '		WHERE a.org_id = :p_org_id and a.org_id = b.org_id AND '||
      '           a.sca_headers_interface_id = b.sca_headers_interface_id '||
      '		  AND a.sca_headers_interface_id BETWEEN :l_start_id AND :l_end_id '||
      '           AND a.role_id = b.role_id ) result '||
      '         WHERE result.alloc_pct > 0 ';

   BEGIN
       EXECUTE IMMEDIATE l_output_sql
                USING IN l_user_id,
		      IN SYSDATE,
		      IN l_user_id,
		      IN SYSDATE,
		      IN l_login_id,
		      IN p_org_id,
		      IN l_start_id,
		      IN l_end_id;

      debugmsg('Process Batch Rules: Executed cn_sca_lines_output dynamic SQL');
      debugmsg('Process Batch Rules: Records in cn_sca_lines_output :'||SQL%ROWCOUNT);

      COMMIT WORK;

   EXCEPTION
      WHEN OTHERS THEN
         debugmsg('Process Batch Rules: Error while inserting into cn_sca_lines_output'||SQLERRM);
	 RAISE;
   END;

   --+
   --+ Update STATUS flag in the cn_sca_headers_interface table. First update
   --+ 'ALLOCATED' and 'REV NOT 100' Flags.
   --+

   debugmsg('Process Batch Rules: Updating ALLOCATED and REV NOT 100 flag');

   OPEN ps_cur;
   FETCH ps_cur
   BULK COLLECT INTO l_sca_winners_tbl_rec.interface_id_tbl,
   		     l_sca_winners_tbl_rec.credit_rule_id_tbl,
		     l_sca_winners_tbl_rec.process_status_tbl;
   CLOSE ps_cur;

   IF (l_sca_winners_tbl_rec.interface_id_tbl.COUNT > 0) THEN
      FORALL indx IN l_sca_winners_tbl_rec.interface_id_tbl.FIRST .. l_sca_winners_tbl_rec.interface_id_tbl.LAST
         UPDATE cn_sca_headers_interface h
            SET credit_rule_id = l_sca_winners_tbl_rec.credit_rule_id_tbl(indx),
	        process_status = l_sca_winners_tbl_rec.process_status_tbl(indx)
          WHERE h.sca_headers_interface_id = l_sca_winners_tbl_rec.interface_id_tbl(indx);

      debugmsg('Process Batch Rules: ALLOCATED and REV NOT 100 records :'||
                l_sca_winners_tbl_rec.interface_id_tbl.COUNT);
   END IF;

   COMMIT WORK;

   --+
   --+ Update STATUS flag to 'NOT ALLOCATED' if record is available in
   --+ CN_SCA_MATCHES table but not availble in CN_SCA_WINNERS table. We need
   --+ to use dynamic SQL since PL/SQL does not support RANK() function in
   --+ 8.1.7
   --+

   l_not_allocated_sql :=
      'UPDATE cn_sca_headers_interface h '||
      '   SET (credit_rule_id,process_status) = ( '||
      '       SELECT b.sca_credit_rule_id, '||
      '              ''NOT ALLOCATED'' '||
      '         FROM (SELECT sca_headers_interface_id,sca_credit_rule_id, '||
      '                     rank, '||
      '			    calculated_rank, '||
      '	                    rule_rank '||
      '                FROM (SELECT sca_headers_interface_id, '||
      '                             sca_credit_rule_id, '||
      '                             calculated_rank, '||
      '                             rank, '||
      '                             rank() over(partition by sca_headers_interface_id '||
      '                                         order by calculated_rank desc, '||
      '                                         sca_credit_rule_id desc) as rule_rank '||
      '                        FROM cn_sca_matches '||
      '                       WHERE org_id = :p_org_id AND '||  -- added org_id here
      '                        sca_headers_interface_id BETWEEN :l_start_id AND :l_end_id) '||
      '               WHERE rule_rank = 1 '||
      '	           ) b '||
      '       WHERE h.sca_headers_interface_id = b.sca_headers_interface_id '||
      '         AND NOT EXISTS ( '||
      '             SELECT ''X'' '||
      '               FROM cn_sca_winners c '||
      '              WHERE h.sca_headers_interface_id = c.sca_headers_interface_id)) '||
      ' WHERE h.credit_rule_id IS NULL '||
      '   AND h.process_status = ''SCA_UNPROCESSED'' '||
      '   AND h.org_id = :p_org_id AND '||  -- added org_id here
      '       h.sca_headers_interface_id BETWEEN :l_start_id AND :l_end_id '||
          -- Perf: Do I need to add this condition
      '   AND h.processed_date BETWEEN :p_start_date AND NVL(:p_end_date,h.processed_date) ';
   BEGIN
      EXECUTE IMMEDIATE l_not_allocated_sql
                  USING IN p_org_id,
                  IN l_start_id,
		        IN l_end_id,
		        IN p_org_id,
		        IN l_start_id,
		        IN l_end_id,
			IN p_start_date,
			IN p_end_date;
   EXCEPTION
      WHEN OTHERS THEN
         debugmsg('SCA Batch: Error While Updating Process_Status');
	 RAISE;
   END;

   COMMIT WORK;
   --
   UPDATE cn_sca_headers_interface h
      SET process_status = 'NO RULE'
    WHERE h.credit_rule_id IS NULL
      AND h.process_status IS NULL
      AND h.org_id = p_org_id -- added org_id here
      AND h.sca_headers_interface_id BETWEEN l_start_id AND l_end_id
      AND h.processed_date BETWEEN p_start_date AND NVL(p_end_date,h.processed_date);

   COMMIT WORK;
   --+
   --+ Call workflow to process REV NOT 100
   --+

   BEGIN

      cn_sca_wf_pkg.start_process(
   	   p_start_header_id 	=> l_start_id,
           p_end_header_id 	=> l_end_id,
           p_trx_source 	=> p_transaction_source,
           p_wf_process 	=> 'CN_SCA_REV_DIST_PR',
           p_wf_item_type 	=> 'CNSCARPR');

   EXCEPTION
      WHEN OTHERS THEN
         debugmsg('Process Batch Rules: Error occured during in REV NOT 100 workflow');
	 RAISE;
   END;

   --+
   --+ Delete the records corresponding to each physical batch from
   --+ cn_sca_matches table and cn_sca_winners table.
   --+

   debugmsg('Completed for the physical batch : ' || p_physical_batch_id);

   cn_message_pkg.set_name('CN','ALL_PROCESS_DONE_OK');
   cn_message_pkg.end_batch(l_process_audit_id);

   retcode := 0;
   errbuf := 'Program completed successfully';
   debugmsg('Batch Mode SCA End');

EXCEPTION
   WHEN others THEN
      ROLLBACK;
      retcode := 2;
      errbuf := 'Failed';
      debugmsg('Batch Mode SCA End with errors');
      cn_message_pkg.end_batch(l_process_audit_id);
END;
--
END;

/
