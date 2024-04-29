--------------------------------------------------------
--  DDL for Package Body AP_WEB_UPGRADE_REPORT_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_UPGRADE_REPORT_DIST_PKG" AS
/* $Header: apwuprdb.pls 120.3 2006/09/01 17:43:12 dtong noship $ */

PROCEDURE put_line(p_buff IN VARCHAR2) IS
BEGIN
  fnd_file.put_line(fnd_file.log, p_buff);
END put_line;

------------------------------------------------------------------------
PROCEDURE Upgrade(errbuf                OUT NOCOPY VARCHAR2,
                  retcode               OUT NOCOPY NUMBER,
		  p_batch_size		IN VARCHAR2,
		  p_worker_id		IN NUMBER,
  		  p_num_workers		IN NUMBER) IS
------------------------------------------------------------------------
  l_request_id              NUMBER;
  l_request_status          VARCHAR2(30);
  l_any_rows_to_process     boolean;
  l_table_name      	    VARCHAR2(30) := 'AP_EXPENSE_REPORT_HEADERS_ALL';
  l_script_name     	    VARCHAR2(30) := 'apwuprdb.pls';
  l_product                 VARCHAR2(30) := 'SQLAP';
  l_table_owner             VARCHAR2(30);

  l_start_rowid     	    ROWID;
  l_end_rowid       	    ROWID;
  l_rows_processed  	    NUMBER;

  l_debug_info              VARCHAR2(1000);
  l_status     	            VARCHAR2(30);
  l_industry                VARCHAR2(30);
  l_retstatus               BOOLEAN;

  -- Product specific variables
  l_bug_number             constant NUMBER := -5345450;

BEGIN
  g_debug_switch      := 'Y';
  g_last_updated_by   := to_number(FND_GLOBAL.USER_ID);
  g_last_update_login := to_number(FND_GLOBAL.LOGIN_ID);

  l_request_id := FND_GLOBAL.CONC_REQUEST_ID;

  IF g_debug_switch = 'Y' THEN

    put_line('------------------------------------------------------------');
    put_line('--           P  A  R  A  M  E  T  E  R  S                 --');
    put_line('------------------------------------------------------------');

    put_line('Debug = ' || g_debug_switch);
    put_line('Last Updated By = ' || g_last_updated_by);
    put_line('Last Update Login = ' || g_last_update_login);
    put_line('Request Id = ' || l_request_id);

    put_line('Batch Size = ' || p_batch_size);
    put_line('Worker Id = ' || p_worker_id);
    put_line('Number of Workers = ' || p_num_workers);
  END IF;

  put_line('------------------------------------------------------------');
  put_line('--                     B E G I N                          --');
  put_line('------------------------------------------------------------');

  --
  -- get schema name of the table for ROWID range processing
  --
  l_retstatus := fnd_installation.get_app_info(
                        l_product, l_status, l_industry, l_table_owner);

  IF ((l_retstatus = FALSE) OR (l_table_owner is null)) THEN
        raise_application_error(-20001, 'Cannot get schema name for product : '||l_product);
  END IF;


  put_line('--       Getting ROWID Range                              --');

  ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_script_name,
           p_worker_id,
           p_num_workers,
           p_batch_size, 0);

  ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           p_batch_size,
           TRUE);
  while (l_any_rows_to_process = TRUE)
  loop

    -- Reset rows processed for this batch
    l_rows_processed := 0;

    -----------------------------------------------------
    --
    -- product specific processing here
    --
    --
    -- Merge into distributions
    l_debug_info := 'Merge line data into distributions';
    put_line('--       Merge line data into distributions               --');

    MERGE INTO ap_exp_report_dists_all rd using (
      SELECT  /*+ rowid(xh) leading(xh) cardinality(10) no_merge */
        xl.report_header_id,
        xl.report_line_id,
        xl.org_id,
        xl.set_of_books_id,
        gs.chart_of_accounts_id,
        xl.flex_concatenated,
        xl.code_combination_id,
        xl.amount,
        xl.project_id,
        xl.task_id,
        xl.award_id,
        xl.expenditure_organization_id
      FROM ap_expense_report_lines_all xl,
	   ap_expense_report_headers_all xh,
           gl_sets_of_books gs
      WHERE xh.rowid BETWEEN l_start_rowid AND l_end_rowid
        --Derive chart of accounts ID from set of books ID
       AND gs.set_of_books_id = xl.set_of_books_id
       AND xl.report_header_id = xh.report_header_id
       AND xh.vouchno <> 0
       AND xl.code_combination_id is not null
       AND (xl.itemization_parent_id is null
       OR xl.itemization_parent_id <> -1)) xl
    ON (rd.report_header_id = xl.report_header_id
        and rd.report_line_id = xl.report_line_id)
    WHEN MATCHED THEN UPDATE SET
        rd.last_updated_by = l_bug_number,
        rd.last_update_date = sysdate,
        rd.amount = xl.amount,
        rd.project_id = xl.project_id,
        rd.task_id = xl.task_id,
        rd.award_id = xl.award_id,
        rd.expenditure_organization_id = xl.expenditure_organization_id,
        rd.cost_center = nvl(ap_web_acctg_pkg.getcostcenter(
                xl.code_combination_id, xl.chart_of_accounts_id), xl.flex_concatenated)
    WHEN NOT MATCHED THEN INSERT (
        rd.report_distribution_id,
        rd.report_line_id,
        rd.report_header_id,
        rd.org_id,
        rd.sequence_num,
        rd.last_updated_by,
        rd.last_update_date,
        rd.created_by,
        rd.creation_date,
        rd.amount,
        rd.project_id,
        rd.task_id,
        rd.award_id,
        rd.expenditure_organization_id,
        rd.code_combination_id,
        rd.cost_center)
      VALUES (
        ap_exp_report_dists_s.nextval, -- use sequence
        xl.report_line_id,
        xl.report_header_id,
        xl.org_id,
        to_number(0), -- sequence_num=0 for 1-1 relationship
        l_bug_number, -- last_updated_by
        sysdate,      -- last_update_date
        l_bug_number, -- created_by
        sysdate,      -- creation_date
        xl.amount,
        xl.project_id,
        xl.task_id,
        xl.award_id,
        xl.expenditure_organization_id,
        xl.code_combination_id,
        nvl(ap_web_acctg_pkg.getcostcenter(
            xl.code_combination_id, xl.chart_of_accounts_id), xl.flex_concatenated));

    l_debug_info := 'Null out obsolete columns from lines table.';
    put_line('--       Null out obsolete columns from lines table       --');

    UPDATE AP_EXPENSE_REPORT_LINES_ALL XL
        SET    XL.flex_concatenated = null,
               XL.code_combination_id = null,
               XL.project_id = null,
               XL.project_number = null,
               XL.project_name = null,
               XL.task_id = null,
               XL.task_number = null,
               XL.task_name = null,
               XL.award_id = null,
               XL.award_number = null,
               XL.expenditure_organization_id = null
    WHERE XL.code_combination_id IS NOT NULL
      AND (XL.itemization_parent_id IS NULL
	      OR XL.itemization_parent_id <> -1)
      AND EXISTS (select /*+ unnest rowid(xh) */ null
		  from AP_EXPENSE_REPORT_HEADERS_ALL xh
		  where xh.rowid between l_start_rowid and l_end_rowid
		    and xh.vouchno <> 0
		    and xh.report_header_id = xl.report_header_id);

    ------------------------------------------------------

    l_rows_processed := SQL%ROWCOUNT;

    ad_parallel_updates_pkg.processed_rowid_range(
          l_rows_processed,
          l_end_rowid);

    --
    -- commit transaction here
    --
    commit;

    --
    -- get new range of rowids
    --

    ad_parallel_updates_pkg.get_rowid_range(
         l_start_rowid,
         l_end_rowid,
         l_any_rows_to_process,
         p_batch_size,
         FALSE);

  END LOOP;

  put_line('------------------------------------------------------------');
  put_line('--                      E N D                             --');
  put_line('------------------------------------------------------------');

EXCEPTION
    WHEN OTHERS THEN
      put_line(sqlerrm);
      rollback;
      raise;
END Upgrade;

/*----------------------------------------------------------------------------*
 | Procedure
 |      Parent
 |
 | DESCRIPTION
 |      This procedure is designed to be called by an upgrade script.
 |      This is a PL/SQL concurrent program which will submit a sub-request.
 |      When a sub-request is submitted, the parent exists to the Running/Paused
 |      state, so that it does not consume any resouces while waiting for the child
 |      request to complete.Whe nthe child completes the parent is restarted.
 |
 |
 | PARAMETERS
 |      errbuf                OUT VARCHAR2
 |      retcode               OUT NUMBER
 |      p_batch_size	      IN VARCHAR2
 |      p_worker_id	      IN NUMBER
 |      p_num_workers	      IN NUMBER
 *----------------------------------------------------------------------------*/
PROCEDURE Parent(errbuf                 OUT NOCOPY VARCHAR2,
                 retcode                OUT NOCOPY NUMBER,
		 p_batch_size		IN VARCHAR2,
 		 p_worker_id		IN NUMBER,
   		 p_num_workers		IN NUMBER) IS
---------------------------------------------------------------
	l_ret number;
BEGIN
	l_ret := fnd_request.submit_request(application => 'SQLAP',
					    program     => 'APWUPRD',
					    description => null,
					    start_time  => null,
					    sub_request => FALSE,
					    argument1   => p_batch_size,
     					    argument2   => p_worker_id,
					    argument3   => p_num_workers);

	if l_ret = 0 then
	  --
	  -- If request submission failed, exit with error.
 	  --
	  errbuf := fnd_message.get;
	  retcode := 2;
	else
	  --
	  -- Here we set the globals to put the program into the
	  -- PAUSED status on exit.
	  --
	  fnd_conc_global.set_req_globals(conc_status => 'PAUSED');
	  errbuf := 'Sub-Request '||l_ret||' submitted!';
	  retcode := 0;
	end if;

	return;

END Parent;



END AP_WEB_UPGRADE_REPORT_DIST_PKG;

/
