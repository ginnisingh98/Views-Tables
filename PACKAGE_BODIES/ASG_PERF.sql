--------------------------------------------------------
--  DDL for Package Body ASG_PERF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_PERF" AS
/*$Header: asgperfb.pls 120.1 2005/08/12 02:50:59 saradhak noship $*/

-- DESCRIPTION
--  Contains functions to report synch performance
--
--
-- HISTORY
--   02-jun-2004 ssabesan   Merge 115.3.1158.4 into main line (11.5.9.6)
--                          Change literal to bind variables.
--   20-Dec-2002 rsripada   Fix Invalid Number error
--   19-Nov-2002 rsripada   Use FND Logging.
--   07-Nov-2002 rsripada   Created

  -- 8 space double tab
  g_dtab VARCHAR2(128) := '        ';
  g_user_name VARCHAR2(30);
  g_first_synch VARCHAR2(1);
  g_pub_item VARCHAR2(30);
  g_log_enabled VARCHAR2(1) := 'N';
  g_last_tran_id NUMBER;
  g_curr_tran_id NUMBER;

  PROCEDURE log(p_mesg IN VARCHAR2)
            IS
  BEGIN
    /*
    IF (g_log_enabled = 'N') THEN
      dbms_output.enable(100000);
      g_log_enabled := 'Y';
    END IF;
    dbms_output.put_line(p_mesg);
    */
    asg_helper.log(p_mesg, 'asg_perf', FND_LOG.LEVEL_EVENT);
  END log;

  PROCEDURE log_newline
            IS
  BEGIN
    /*
    IF (g_log_enabled = 'N') THEN
      dbms_output.enable(100000);
      g_log_enabled := 'Y';
    END IF;
    -- Trick dbms_output to write a blank line
    dbms_output.put(CHR(10));
    */
    asg_helper.log('    ', 'asg_perf', FND_LOG.LEVEL_EVENT);
  END log_newline;

  PROCEDURE print_header
            IS
  l_db_instance VARCHAR2(30);
  BEGIN

    select instance_name into l_db_instance
    from v$instance;

    log('Synch Query Performance Report');
    log_newline();
    log('User: ' || g_user_name);
    log('Database: ' || l_db_instance);

    IF (g_first_synch = asg_base.G_YES) THEN
      log('Type of Synch: COMPLETE REFRESH');
    ELSE
      log('Type of Synch: INCREMENTAL REFRESH');
    END IF;

    IF g_pub_item IS NOT NULL THEN
      log('Publication Item: ' || g_pub_item);
    END IF;

    log_newline();
    log_newline();

  END print_header;

  PROCEDURE print_summary
            IS
  BEGIN
    log_newline();
    log_newline();
    log('Summary: ');
    log('Total Num of rows: ' || g_total_rows);
    log('Time in download_init (sec):       ' || g_dtab ||
                       g_dtab || g_dtab || to_char(g_download_init_time));
    log('Total query time (sec) :   '  || g_dtab || g_dtab || g_dtab ||
                       g_dtab || to_char(g_total_elapsed_query_time));
    log('Total Time (sec) : ' || g_dtab || g_dtab || g_dtab ||
                       g_dtab || g_dtab ||  to_char(g_total_elapsed_time));
  END print_summary;

  PROCEDURE setup_pub_item_download(p_user_name  IN VARCHAR2,
                                    p_pub_item   IN VARCHAR2,
                                    p_first_synch IN VARCHAR2)
          IS
  l_begin_date DATE;
  l_end_date DATE;
  l_comp_ref VARCHAR2(1);
  l_query_string VARCHAR2(512);
  BEGIN

    IF(p_first_synch = asg_base.G_YES) THEN
      l_comp_ref := 'Y';
    ELSE
      l_comp_ref := 'N';
    END IF;

    l_query_string := 'insert into ' || asg_base.G_OLITE_SCHEMA ||
                                   '.c$pub_list_q(name, comp_ref) ' ||
                      ' values (:1, :2)';
    EXECUTE IMMEDIATE l_query_string
    USING p_pub_item, l_comp_ref;

    IF p_first_synch = asg_base.G_YES THEN
      g_last_tran_id := -1;
      g_curr_tran_id := 1;
    ELSE
      SELECT max(transaction_id) into g_last_tran_id
      FROM asg_system_dirty_queue
      WHERE client_id  = p_user_name;
      IF g_last_tran_id IS NULL THEN
        g_last_tran_id := 1;
      END IF;
      g_curr_tran_id := g_last_tran_id +1;
    END IF;

    log('Download Init:');

    select sysdate into l_begin_date from dual;
    log('Begin time: ' ||
                       to_char(l_begin_date, 'DD-MON-YYYY HH24:MI:SS'));
    apps.asg_cons_qpkg.download_init(p_user_name, g_last_tran_id,
                                     g_curr_tran_id, 'N');
    select sysdate into l_end_date from dual;
    log('End time: ' ||
                       to_char(l_end_date, 'DD-MON-YYYY HH24:MI:SS'));

    g_elapsed_time_in_days := l_end_date-l_begin_date;
    -- Convert the elapsed time in seconds
    g_elapsed_time := g_elapsed_time_in_days*60*60*24;
    g_download_init_time := g_elapsed_time;
    log('Time in download_init (sec): ' || g_dtab || g_dtab ||
                       g_dtab || g_dtab || to_char(g_download_init_time));
    log_newline();

  END setup_pub_item_download;

  PROCEDURE compute_pub_item_time(p_pub_item IN VARCHAR2)
            IS
  l_begin_date DATE;
  l_end_date DATE;
  l_query_string VARCHAR2 (512);
  begin
    select sysdate into l_begin_date from dual;
    log('Begin time: ' ||
        to_char(l_begin_date, 'DD-MON-YYYY HH24:MI:SS'));
    l_query_string := 'SELECT count(*) ' ||
                      ' FROM mobileadmin.ctm$' ||p_pub_item ||
                      ' WHERE clid$$cs = :1 AND ' ||
                      '      tranid$$ > :2';

    EXECUTE IMMEDIATE l_query_string INTO g_num_rows
    USING g_user_name, g_last_tran_id;
    select sysdate into l_end_date from dual;
    log('End time: ' ||
        to_char(l_end_date, 'DD-MON-YYYY HH24:MI:SS'));
    log('Num of rows: ' || g_num_rows);
    g_elapsed_time_in_days := l_end_date-l_begin_date;
    -- Convert the elapsed time in seconds
    g_elapsed_time := g_elapsed_time_in_days*60*60*24;
    log('Query Time (sec): ' || g_dtab || g_dtab || g_dtab ||
        g_dtab || g_dtab ||  to_char(g_elapsed_time));
  END compute_pub_item_time;

  PROCEDURE setup_download(p_user_name  IN VARCHAR2,
                           p_first_synch IN VARCHAR2)
          IS
  l_begin_date DATE;
  l_end_date DATE;
  l_comp_ref VARCHAR2(1);
  l_query_string VARCHAR2(512);
  BEGIN

    IF(p_first_synch = asg_base.G_YES) THEN
      l_comp_ref := 'Y';
    ELSE
      l_comp_ref := 'N';
    END IF;

    l_query_string := 'insert into ' || asg_base.G_OLITE_SCHEMA ||
                                   '.c$pub_list_q(name, comp_ref) ' ||
                      ' select publication_item, ''' || l_comp_ref || '''' ||
                      ' from ' || asg_base.G_OLITE_SCHEMA ||
                      '.c$all_client_items ' ||
                      ' where clientid = :1 ' ||
                      ' and publication_item in ' ||
                      '     (select name from asg_pub_item)';
    EXECUTE IMMEDIATE l_query_string
    USING p_user_name;

    IF p_first_synch = asg_base.G_YES THEN
      g_last_tran_id := -1;
      g_curr_tran_id := 1;
    ELSE
      SELECT max(transaction_id) into g_last_tran_id
      FROM asg_system_dirty_queue
      WHERE client_id  = p_user_name;
      IF g_last_tran_id IS NULL THEN
        g_last_tran_id := 1;
      END IF;
      g_curr_tran_id := g_last_tran_id +1;
    END IF;

    log('Download Init:');
    --log('Last tranid: ' || g_last_tran_id ||
    --    ' Current tranid: ' || g_curr_tran_id);

    select sysdate into l_begin_date from dual;
    log('Begin time: ' ||
                       to_char(l_begin_date, 'DD-MON-YYYY HH24:MI:SS'));
    apps.asg_cons_qpkg.download_init(p_user_name, g_last_tran_id,
                                     g_curr_tran_id, 'N');
    select sysdate into l_end_date from dual;
    log('End time: ' ||
                       to_char(l_end_date, 'DD-MON-YYYY HH24:MI:SS'));

    g_elapsed_time_in_days := l_end_date-l_begin_date;
    -- Convert the elapsed time in seconds
    g_elapsed_time := g_elapsed_time_in_days*60*60*24;
    g_download_init_time := g_elapsed_time;
    log('Time in download_init (sec): ' || g_dtab || g_dtab ||
                       g_dtab || g_dtab || to_char(g_download_init_time));
    log_newline();

  END setup_download;

  PROCEDURE compute_download_time
            IS
  l_cursor_id             NUMBER;
  l_cursor_ret            NUMBER;
  l_select_pi_sqlstring   VARCHAR2(4000);
  l_curr_pub_item VARCHAR2(30);
  begin

    l_select_pi_sqlstring :=
                  'SELECT name ' ||
                  'FROM ' || asg_base.G_OLITE_SCHEMA ||'.' ||'c$pub_list_q';

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id, l_select_pi_sqlstring, DBMS_SQL.v7);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 1, l_curr_pub_item, 30);

    l_cursor_ret := DBMS_SQL.EXECUTE (l_cursor_id);
    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0 ) LOOP
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 1, l_curr_pub_item);
      log(l_curr_pub_item);
      compute_pub_item_time(l_curr_pub_item);
      g_total_rows := g_total_rows + g_num_rows;
      g_total_elapsed_query_time := g_total_elapsed_query_time + g_elapsed_time;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

    g_total_elapsed_time := g_download_init_time + g_total_elapsed_query_time;

  END compute_download_time;

  PROCEDURE  cleanup_setup
             IS
  l_query_string VARCHAR2(512);
  BEGIN
    l_query_string := 'DELETE FROM ' || asg_base.G_OLITE_SCHEMA ||
                      '.c$pub_list_q';
    EXECUTE IMMEDIATE l_query_string;
    asg_base.reset_all_globals();
    asg_download.reset_all_globals();
    rollback;
  END cleanup_setup;


  -- Procedure to report the download init and query time statistics
  -- for the specified user's first synch
  PROCEDURE get_first_synch_report(p_user_name IN VARCHAR2)
            IS
  BEGIN
    g_user_name := upper(p_user_name);
    g_first_synch := asg_base.G_YES;
    g_pub_item := null;

    print_header();
    setup_download(g_user_name, g_first_synch);
    compute_download_time();
    print_summary();
    cleanup_setup;

  END get_first_synch_report;

  -- Procedure to report the download init and query time statistics
  -- for the specified user's incremental synch
  PROCEDURE get_incremental_synch_report(p_user_name IN VARCHAR2)
            IS
  BEGIN
    g_user_name := upper(p_user_name);
    g_first_synch := asg_base.G_NO;
    g_pub_item := null;

    print_header();
    setup_download(g_user_name, g_first_synch);
    compute_download_time();
    print_summary();
    cleanup_setup;

  END get_incremental_synch_report;

  -- Procedure to report the download init and query time statistics
  -- for the specified user and publication-item's first synch
  PROCEDURE get_first_synch_report(p_user_name IN VARCHAR2,
                                   p_pub_item  IN VARCHAR2)
            IS
  BEGIN
    g_user_name := upper(p_user_name);
    g_first_synch := asg_base.G_YES;
    g_pub_item := upper(p_pub_item);

    print_header();
    setup_pub_item_download(g_user_name, g_pub_item, g_first_synch);
    compute_pub_item_time(g_pub_item);
    print_summary();
    cleanup_setup;

  END get_first_synch_report;

  -- Procedure to report the download init and query time statistics
  -- for the specified user and publication item's incremental synch
  PROCEDURE get_incremental_synch_report(p_user_name IN VARCHAR2,
                                         p_pub_item  IN VARCHAR2)
            IS
  BEGIN
    g_user_name := upper(p_user_name);
    g_first_synch := asg_base.G_NO;
    g_pub_item := upper(p_pub_item);

    print_header();
    setup_pub_item_download(g_user_name, g_pub_item, g_first_synch);
    compute_pub_item_time(g_pub_item);
    print_summary();
    cleanup_setup;

  END get_incremental_synch_report;

end;

/
