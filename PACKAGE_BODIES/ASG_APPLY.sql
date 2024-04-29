--------------------------------------------------------
--  DDL for Package Body ASG_APPLY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_APPLY" AS
/*$Header: asgaplyb.pls 120.7.12010000.12 2010/05/10 05:45:43 trajasek ship $*/

-- DESCRIPTION
--   This package is used to process records changed by the mobile
--   client. During synch, these records are placed in Olite's INQ.
--   We process the inq meta data to construct a consistent, necessary set
--   of information for application teams to process and apply these
--   records into the apps tables.
--
--   The main function process_upload is called by a concurrent program.
--   It processes all the changes for all clients. For every client,
--   a call back <asg_pub.wrapper_name>.apply_client_changes(...,...) is
--   called to process changes for a specific <client, tranid> which
--   are passed as parameters to that procedure. Applications
--   can also use the other APIs in this package to aid in their
--   processing. At the end of the call, all the client's records
--   for that publication and tranid should either be applied to the
--   applications table or deferred. We will defer any records remaining
--   in the INQ.
--
--
-- HISTORY
--   23-oct-2009 saradhak   Bug 9018969 - updated process_sequences api
--   12-aug-2009 saradhak   Added process_mobile_queries api
--   15-May-2008 saradhak   12.1- Auto Sync
--   15-sep-2004 ssabesan   Changes for delivery notification
--   01-jun-2004 ssabesan   Merge 115.33.1158.10 to main line(11.5.9.6)
--                          Add logging level in call to log() method.
--   01-jun-2004 ssabesan   Added table alias in purge_pubitems method
--   18-feb-2003 ssabesan   Modifed get_first_tranid and get_next_tranid to
--			    return values <= asg_user.hwm_tranid
--   24-jan-2003 ssabesan   Fix bug # 2737613 ( Upload performance tuning)
--   06-jan-2003 ssabesan   Added NOCOPY in function definition
--   06-jan-2003 ssabesan   Check whether logging is enabled before invoking
--                          logging procedure.
--   10-dec-2002 rsripada   Added support for not processing custom PIs
--   14-aug-2002 rsripada   Fixed 2508703
--   26-jun-2002 rsripada   Removed build dependencies on Olite schema
--   25-jun-2002 rsripada   Fixed bug 2432320
--   05-jun-2002 rsripada   Pubitems are returned based on weight
--   04-jun-2002 rsripada   Changed logging to use asg_helper.log
--   29-may-2002 rsripada   Streamlined some of the procedures
--   24-may-2002 rsripada   Added sequence processing support
--   25-apr-2002 rsripada   Added deferred transaction support etc
--   03-mar-2002 rsripada   Use wrapper_name for call backs
--   19-feb-2002 rsripada   Created

  g_stmt_level NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_err_level NUMBER := FND_LOG.LEVEL_ERROR;
  g_conc_start_time date;
  g_is_conc_program varchar2(1) := 'N';

  -- Logging procedure
  PROCEDURE log(debug_msg IN VARCHAR2,
                log_level IN NUMBER)
            IS
  sql_string   VARCHAR2(4000);
  log_msg      VARCHAR2(3900);
  start_string VARCHAR2(128);
  log_msg_length PLS_INTEGER;
  BEGIN
    IF(asg_helper.check_is_log_enabled(log_level))
    THEN
      IF(g_user_name IS NOT NULL) THEN
        start_string := 'upload_' || g_user_name || ': ';
      ELSE
        start_string := 'upload_log: ';
      END IF;
      log_msg := start_string || debug_msg;
      asg_helper.log(log_msg, 'asg_apply', log_level);
    END IF;
  END log;

  PROCEDURE print_string(p_string IN VARCHAR2)
            IS
  l_multiple         PLS_INTEGER;
  l_line_length      PLS_INTEGER := 4000;
  l_string_length    PLS_INTEGER;
  start_pos          PLS_INTEGER;
  BEGIN
    IF p_string IS NULL THEN
      return;
    END IF;

    IF (asg_helper.check_is_log_enabled(g_stmt_level)) THEN
      l_string_length := length(p_string);
      l_multiple := l_string_length/l_line_length+1 ;

      IF l_multiple = 1 THEN
        log(p_string,g_stmt_level);
      ELSE
        FOR curr_iter in 1..l_multiple LOOP
          start_pos := (curr_iter-1)*l_line_length + 1;
          log(substr(p_string, start_pos, l_line_length),g_stmt_level);
        END LOOP;
      END IF;
    END IF;
  END print_string;


  function raise_row_deferred(p_start_time date)
  return boolean
  is
    l_ctx  dbms_xmlquery.ctxType;
    l_clob clob;
    l_seq number;
    l_qry varchar2(2048);
  begin
    log('Begin raise_row_deferred',g_stmt_level);
    l_qry := 'select DEVICE_USER_NAME user_name,DEFERRED_TRAN_ID tran_id ,'
             ||'ERROR_DESCRIPTION ,OBJECT_NAME pub_item,SEQUENCE '
             ||'from asg_deferred_traninfo where CREATION_DATE >= to_date('''
             ||to_char(p_start_time,'mm-dd-yyyy hh24:mi:ss')
             ||''',''mm-dd-yyyy hh24:mi:ss'') ';
    log('Query :'||l_qry,g_stmt_level);
    l_ctx := dbms_xmlquery.newContext(l_qry);
    dbms_lob.createtemporary(l_clob,true,dbms_lob.session);
    l_clob := dbms_xmlquery.getXml(l_ctx);
    log('Raising event oracle.apps.asg.upload.datadeferred',g_stmt_level);
    select asg_events_s.nextval into l_seq from dual;
    wf_event.raise(p_event_name=>'oracle.apps.asg.upload.datadeferred',
                   p_event_key=>l_seq,p_parameters=>null,
                   p_event_data=>l_clob,p_send_date=>null);
    log('Successfully raised event oracle.apps.asg.upload.datadeferred',g_stmt_level);
    return true;
  exception
  when others then
    log('Error raising oracle.apps.asg.upload.datadeferred :'||SQLERRM,g_err_level);
    return false;
  end raise_row_deferred;

  -- Sort the publication item list by weight stored in
  -- asg_pub_item table
  PROCEDURE sort_by_weight(p_pub_name IN VARCHAR2,
                           x_pub_items_tbl IN OUT NOCOPY vc2_tbl_type)
            IS
  l_pub_items_tbl vc2_tbl_type;
  l_all_pub_items vc2_tbl_type;
  counter PLS_INTEGER;
  CURSOR c_pub_items(p_pub_name IN VARCHAR2) IS
    SELECT /*+ index (asg_pub_item, asg_pub_item_n1) */ name
    FROM asg_pub_item
    WHERE pub_name = p_pub_name
    ORDER BY nvl(table_weight, 0);
  BEGIN

    IF(x_pub_items_tbl IS NULL) OR
      (x_pub_items_tbl.count = 0) THEN
      return;
    END IF;

    -- Make a copy of pubitem list
    FOR curr_index in 1..x_pub_items_tbl.count LOOP
      l_pub_items_tbl(curr_index) := x_pub_items_tbl(curr_index);
    END LOOP;

    -- Get the ordered list of pub items from the asg_pub_item table
    counter := 1;
    FOR cpi in c_pub_items(p_pub_name) LOOP
      l_all_pub_items(counter) := cpi.name;
      counter := counter +1;
    END LOOP;

    -- For each pub item, check if it is part of the initial list
    -- At the end of this iteration, x_pub_items_tbl will contain
    -- the ordered list
    counter :=1;
    FOR curr_index in 1..l_all_pub_items.count LOOP
      FOR curr_index2 in 1..l_pub_items_tbl.count LOOP
        IF (l_all_pub_items(curr_index) = l_pub_items_tbl(curr_index2)) THEN
          x_pub_items_tbl(counter) := l_all_pub_items(curr_index);
          counter := counter +1;
        END IF;
      END LOOP;
   END LOOP;

  END sort_by_weight;

  PROCEDURE get_sync_state(p_user_name   IN  VARCHAR2,
                           p_sync_tables OUT NOCOPY NUMBER)
            IS
  l_select_sync_sqlstring VARCHAR2(512);
  BEGIN
    l_select_sync_sqlstring :=
      'SELECT count(distinct clid$$cs) ' ||
      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq ' ||
      'WHERE clid$$cs = :1 AND ' ||
      'tranid$$ NOT IN ' ||
      '(SELECT tranid  ' ||
      ' FROM asg_users_inqinfo ' ||
      ' WHERE device_user_name = :2)';
    EXECUTE IMMEDIATE l_select_sync_sqlstring
      INTO p_sync_tables
      USING p_user_name, p_user_name;
  END get_sync_state;

--12.1
  PROCEDURE compact_cinq(p_user_name      IN VARCHAR2,
                         p_start_tranid   IN NUMBER,
                         p_end_tranid     IN NUMBER,
                         p_compact_tranid IN NUMBER)
    IS
  l_sql VARCHAR2(1024);
  l_cinq_table   VARCHAR2(60);
  BEGIN
    log('compact_cinq: Compacting c$inq for User: ' || p_user_name ||
        ' Start TranID: ' || p_start_tranid ||
        ' End TranID: ' || p_end_tranid ||
        ' Compact TranID: ' || p_compact_tranid);

    l_cinq_table := asg_base.G_OLITE_SCHEMA || '.c$inq ';
    l_sql := 'UPDATE ' || l_cinq_table ||
             'SET tranid$$ = :1 ' ||
             'WHERE clid$$cs = :2  AND ' ||
             '      tranid$$ >= :3 AND ' ||
             '      tranid$$ <= :4';
    log('compact_cinq: SQL Command: ' || l_sql);
    EXECUTE IMMEDIATE l_sql
    USING p_compact_tranid, p_user_name, p_start_tranid, p_end_tranid;
    log('compact_cinq: No of Records Updated : ' || SQL%ROWCOUNT);

    -- Remove duplicate entries
    l_sql := 'DELETE FROM ' ||  l_cinq_table || ' a ' ||
             'WHERE a.clid$$cs = :1 AND ' ||
             '      a.tranid$$ = :2 AND ' ||
             '      rowid > (select min(rowid)  ' ||
             '               from ' || l_cinq_table || ' b ' ||
             '               where b.clid$$cs = a.clid$$cs AND ' ||
             '                     b.tranid$$ = a.tranid$$ AND ' ||
             '                     b.store = a.store)';
    log('compact_cinq: SQL Command: ' || l_sql);
    EXECUTE IMMEDIATE l_sql
    USING p_user_name, p_compact_tranid;
    log('compact_cinq: No of Records Deleted: ' || SQL%ROWCOUNT);

  END compact_cinq;

--12.1
  PROCEDURE compact_asginq(p_user_name      IN VARCHAR2,
                           p_start_tranid   IN NUMBER,
                           p_end_tranid     IN NUMBER,
                           p_compact_tranid IN NUMBER)
    IS
  counter NUMBER;
  counter2 NUMBER;
  l_cursor_id1             NUMBER;
  l_cursor_ret1            NUMBER;
  l_store                  VARCHAR2(30);
  l_select_store_sqlstring VARCHAR2(512);
  l_pubitems_tbl vc2_tbl_type;
  curr_pubitem VARCHAR2(30);
  curr_pubitem_length NUMBER;
  l_pubitems_max_length NUMBER:= 4000;
  l_pubitems_1 VARCHAR2(4000);
  l_pubitems_2 VARCHAR2(4000);
  BEGIN

    log('compact_asginq: Compacting asg inq info tables for User: ' || p_user_name ||
        ' Start TranID: ' || p_start_tranid ||
        ' End TranID: ' || p_end_tranid ||
        ' Compact TranID: ' || p_compact_tranid);

    -- Remove all records except compact tranID
    DELETE FROM asg_users_inqinfo
    WHERE device_user_name = p_user_name AND
          tranid >= p_start_tranid AND
          tranid <= p_end_tranid AND
          tranid <> p_compact_tranid;

    -- Update asg_users_inqarchive also

      --  Get the list of pub-items for this tranid
      --  This is the list of all publication items uploaded for that tranid
      l_pubitems_1 := null;
      l_pubitems_2 := null;
      counter := 1;
      counter2:= 1;
      curr_pubitem_length := 0;
      l_select_store_sqlstring :=
        'SELECT store ' ||
        'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq '||
        'WHERE clid$$cs = :1 AND ' ||
        '      tranid$$ = :2 ' ||
        ' ORDER BY store';

      l_cursor_id1 := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE (l_cursor_id1, l_select_store_sqlstring, DBMS_SQL.v7);
      DBMS_SQL.DEFINE_COLUMN (l_cursor_id1, 1, l_store, 30);
      DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':1', p_user_name);
      DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':2', p_compact_tranid);
      l_cursor_ret1 := DBMS_SQL.EXECUTE (l_cursor_id1);

      counter := 1;
      WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id1) > 0 ) LOOP
        DBMS_SQL.COLUMN_VALUE (l_cursor_id1, 1, l_store);
        l_pubitems_tbl(counter) := l_store;
        counter := counter +1;
      END LOOP;

      DBMS_SQL.CLOSE_CURSOR(l_cursor_id1);

      counter := 1;
      counter2:= 1;
      FOR curr_index2 IN 1..l_pubitems_tbl.count LOOP
        curr_pubitem := l_pubitems_tbl(curr_index2);
        curr_pubitem_length := curr_pubitem_length + length(curr_pubitem);
        IF curr_pubitem_length >= 8000 THEN
          EXIT;
        END IF;
        IF curr_pubitem_length < 4000 THEN
          IF counter >1 THEN
            l_pubitems_1 := l_pubitems_1 || ',';
            curr_pubitem_length := curr_pubitem_length + 1; -- length of ','
          END IF;
          l_pubitems_1 := l_pubitems_1 || curr_pubitem;
          counter := counter +1;
        ELSE
          IF counter2 >1 THEN
            l_pubitems_2 := l_pubitems_2 || ',';
            curr_pubitem_length := curr_pubitem_length + 1; -- length of ','
          END IF;
          l_pubitems_2 := l_pubitems_2 || curr_pubitem;
          counter2 := counter2 +1;
        END IF;
      END LOOP;

     log('compact_asginq: Pub-Items to be processed during this auto sync: ' ||
         l_pubitems_1 || l_pubitems_2);
     UPDATE asg_users_inqarchive
     SET pub_items1 = l_pubitems_1, pub_items2 = l_pubitems_2
     WHERE device_user_name = p_user_name AND
           tranid = p_compact_tranid;

    -- Remove all records except compact tranID
    DELETE FROM asg_users_inqarchive
    WHERE device_user_name = p_user_name AND
          tranid >= p_start_tranid AND
          tranid <= p_end_tranid AND
          tranid <> p_compact_tranid;

  END compact_asginq;

--12.1
  PROCEDURE compact_curr_inqtable(p_user_name      IN VARCHAR2,
                                  p_start_tranid   IN NUMBER,
                                  p_end_tranid     IN NUMBER,
                                  p_compact_tranid IN NUMBER,
                                  p_curr_pubitem   IN VARCHAR2)
    IS
  l_inq_table    VARCHAR2(60);
  l_pk_columns   VARCHAR2(2000);
  l_pk_list      asg_download.pk_list;
  l_sql          VARCHAR2(1024);
  l_pk_clause    VARCHAR2(1024) := NULL;
  l_sql_count NUMBER;
  BEGIN
    l_inq_table := asg_base.G_OLITE_SCHEMA || '.cfm$' || p_curr_pubitem || ' ' ;
    log('compact_curr_inqtable: Compacting inq table for User: ' || p_user_name ||
        ' Start TranID: ' || p_start_tranid ||
        ' End TranID: ' || p_end_tranid ||
        ' Compact TranID: ' || p_compact_tranid ||
        ' Pub-Item: ' || p_curr_pubitem);

    -- Update the inq table to make (clid$$cs, seqno$$) a PK
    -- Assuming not more than 1,000,000 records per pub-item per sync.
    l_sql := 'UPDATE ' || l_inq_table ||
             'SET seqno$$ = tranid$$*1000000 + seqno$$ ' ||
             'WHERE clid$$cs  = :1 AND ' ||
             '      tranid$$ >= :2 AND ' ||
             '      tranid$$ <= :3';
    log('compact_curr_inqtable: SQL Command: ' || l_sql);
    EXECUTE IMMEDIATE l_sql
    USING p_user_name, p_start_tranid, p_end_tranid;
    log('compact_curr_inqtable: No of Records Updated : ' || SQL%ROWCOUNT);

    -- Update the inq table to the same tranid$$
    l_sql := 'UPDATE ' || l_inq_table ||
             'SET tranid$$ = :1 ' ||
             'WHERE clid$$cs  = :2 AND ' ||
             '      tranid$$ >= :3 AND ' ||
             '      tranid$$ <= :4';
    log('compact_curr_inqtable: SQL Command: ' || l_sql);
    EXECUTE IMMEDIATE l_sql
    USING p_compact_tranid, p_user_name, p_start_tranid, p_end_tranid;
    log('compact_curr_inqtable: No of Records Updated : ' || SQL%ROWCOUNT);

    -- OK, all inq records to be processed have the same tranid$$
    -- We need to update dmltype$$ now
    SELECT primary_key_column INTO l_pk_columns
    FROM asg_pub_item
    WHERE name = p_curr_pubitem;

    l_pk_list := asg_download.get_listfrom_string(l_pk_columns);
    FOR curr_index IN 1..l_pk_list.count LOOP
      IF(curr_index >1) THEN
        l_pk_clause := l_pk_clause || ' AND ';
      END IF;
      l_pk_clause := l_pk_clause || ' b.' || l_pk_list(curr_index) || ' = ' ||
                                    ' a.' || l_pk_list(curr_index) || '  ';
    END LOOP;
    log('compact_curr_inqtable: PK Clause: ' || l_pk_clause);

/*to remove records that have dml types Insert and Deletes and/or Updates in INQ in one sync*/
 l_sql :=
          'DELETE FROM '||l_inq_table ||' WHERE ('||l_pk_columns||',clid$$cs,tranid$$) IN(' ||
          'SELECT '||l_pk_columns||',clid$$cs,tranid$$ FROM '||l_inq_table ||' a '||
          'WHERE clid$$cs = :1
           AND   tranid$$ = :2
		   AND   dmltype$$=''D''
		   AND   EXISTS( select 1' ||
             '           from ' || l_inq_table || ' b ' ||
             '           where b.dmltype$$ =''I'' and
			                   b.clid$$cs = a.clid$$cs and ' ||
             '                 b.tranid$$ = a.tranid$$ and ' ||
                                     l_pk_clause || ' ))';

     log('compact_curr_inqtable: SQL Command: ' || l_sql);
     EXECUTE IMMEDIATE l_sql USING p_user_name, p_compact_tranid;
     l_sql_count:=SQL%ROWCOUNT;
     log('compact_curr_inqtable: No of Records Deleted : ' || l_sql_count);

     IF (l_sql_count > 0) THEN
        /*remove C_inq record if INQ table curr_tranid records are purged by above query */
      l_sql := 'DELETE FROM '||asg_base.G_OLITE_SCHEMA||'.c$inq a '||
               'WHERE STORE= '||''''||p_curr_pubitem||''' '||
		       'AND  tranid$$=:1 '||
     		   'AND NOT EXISTS (SELECT 1 FROM '||l_inq_table||' b WHERE a.tranid$$=b.tranid$$)' ;

       log('compact_curr_inqtable: SQL Command: ' || l_sql);
       EXECUTE IMMEDIATE l_sql USING p_compact_tranid;
       l_sql_count:=SQL%ROWCOUNT;
       log('compact_curr_inqtable: No of Records Deleted IN C$INQ : ' || l_sql_count);

	   IF l_sql_count>0 THEN
	      BEGIN
   	        l_sql:='UPDATE ASG_USERS_INQARCHIVE '||
			       'SET PUB_ITEMS1=replace(PUB_ITEMS1,'''||p_curr_pubitem||''',''*'||p_curr_pubitem||'''),
                        PUB_ITEMS2=replace(PUB_ITEMS2,'''||p_curr_pubitem||''',''*'||p_curr_pubitem||''') '||
 	               'WHERE DEVICE_USER_NAME=:2 AND TRANID=:3';
            log('compact_curr_inqtable: SQL Command: ' || l_sql);
            EXECUTE IMMEDIATE l_sql USING p_user_name,p_compact_tranid;
            log('compact_curr_inqtable: No of Records Updated in INQARCHIVE : ' || SQL%ROWCOUNT);
          EXCEPTION
          WHEN Others THEN
            l_sql:=sqlerrm;
            log('compact_curr_inqtable:Ignoring Exception while Updating INQARCHIVE -'||l_sql);
          END;
	   END IF;
     END IF;


    -- Update the inq with the correct dmltype$$
    l_sql := 'UPDATE ' || l_inq_table || ' a ' ||
             'SET dmltype$$ = (select min(dmltype$$) ' ||
             '                 from ' || l_inq_table || ' b ' ||
             '                 where b.clid$$cs = a.clid$$cs and ' ||
             '                       b.tranid$$ = a.tranid$$ and ' ||
                                     l_pk_clause || ' ) '||
             'WHERE clid$$cs = :1 AND tranid$$ = :2';

     log('compact_curr_inqtable: SQL Command: ' || l_sql);
     EXECUTE IMMEDIATE l_sql USING p_user_name, p_compact_tranid;
     log('compact_curr_inqtable: No of Records Updated : ' || SQL%ROWCOUNT);

     -- Remove duplicate records
     l_sql := 'DELETE FROM ' || l_inq_table || ' a ' ||
              'WHERE seqno$$ < (select max(seqno$$) ' ||
             '                 from ' || l_inq_table || ' b ' ||
             '                 where b.clid$$cs = a.clid$$cs and ' ||
             '                       b.tranid$$ = a.tranid$$ and ' ||
                                     l_pk_clause || ' ) '||
             'AND clid$$cs = :1 AND tranid$$ = :2';

     log('compact_curr_inqtable: SQL Command: ' || l_sql);
     EXECUTE IMMEDIATE l_sql USING p_user_name, p_compact_tranid;
     log('compact_curr_inqtable: No of Records Deleted: ' || SQL%ROWCOUNT);


  END compact_curr_inqtable;

--12.1
  PROCEDURE compact_inqtables(p_user_name      IN VARCHAR2,
                              p_start_tranid   IN NUMBER,
                              p_end_tranid     IN NUMBER,
                              p_compact_tranid IN NUMBER)
    IS
  counter                    NUMBER;
  l_cursor_id1               NUMBER;
  l_cursor_ret1              NUMBER;
  l_store                    VARCHAR2(30);
  l_select_store_sqlstring   VARCHAR2(512);
  l_pubitems_tbl             vc2_tbl_type;
  curr_pubitem               VARCHAR2(30);
  BEGIN

    log('compact_inqtables: Compacting inq tables for User: ' || p_user_name ||
        ' Start TranID: ' || p_start_tranid ||
        ' End TranID: ' || p_end_tranid ||
        ' Compact TranID: ' || p_compact_tranid);

    counter := 1;
    l_select_store_sqlstring :=
      'SELECT store ' ||
      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq '||
      'WHERE clid$$cs = :1 AND ' ||
      '      tranid$$ = :2 AND ' ||
      '      store in (select item_id from asg_pub_item) ' ||
      ' ORDER BY store';

    l_cursor_id1 := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id1, l_select_store_sqlstring, DBMS_SQL.v7);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id1, 1, l_store, 30);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':1', p_user_name);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':2', p_compact_tranid);
    l_cursor_ret1 := DBMS_SQL.EXECUTE (l_cursor_id1);

    counter := 1;
    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id1) > 0 ) LOOP
      DBMS_SQL.COLUMN_VALUE (l_cursor_id1, 1, l_store);
      l_pubitems_tbl(counter) := l_store;
      counter := counter +1;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id1);

    FOR curr_index IN 1..l_pubitems_tbl.count LOOP
      curr_pubitem := l_pubitems_tbl(curr_index);
      compact_curr_inqtable(p_user_name, p_start_tranid, p_end_tranid,
                            p_compact_tranid, curr_pubitem);
    END LOOP;

  END compact_inqtables;

  /* Procedure to retrieve transactions that are not yet added */
  /* to asg_users_inqinfo table */
  PROCEDURE get_new_tranids(p_user_name   IN  VARCHAR2,
                            l_tranids_tbl OUT NOCOPY num_tbl_type)
            IS
  counter                    PLS_INTEGER;
  l_cursor_id                NUMBER;
  l_cursor_ret               NUMBER;
  l_select_tranid_sqlstring  VARCHAR2(512);
  l_tranid                   NUMBER;
  BEGIN
    l_select_tranid_sqlstring :=
      'SELECT distinct tranid$$ ' ||
      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq ' ||
      'WHERE clid$$cs = :user_name AND '||
      'tranid$$ NOT IN ' ||
      '(SELECT tranid ' ||
      ' FROM asg_users_inqinfo ' ||
      ' WHERE device_user_name = :user_name)';
    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id, l_select_tranid_sqlstring, DBMS_SQL.v7);
    DBMS_SQL.BIND_VARIABLE (l_cursor_id, ':user_name', p_user_name );
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 1, l_tranid);
    l_cursor_ret := DBMS_SQL.EXECUTE (l_cursor_id);

    counter := 1;
    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0 ) LOOP
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 1, l_tranid);
      l_tranids_tbl(counter) := l_tranid;
      counter := counter +1;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
  END get_new_tranids;

  -- Returns the list of all clients with the specified inq record types
  -- dirty for unprocessed new records
  -- deferred for processed but deferred records.
  -- x_return_status should be FND_API.G_RET_STS_SUCCESS for the client's
  -- to be processed.
  PROCEDURE get_all_clients(p_dirty IN VARCHAR2,
                            p_deferred IN VARCHAR2,
                            x_clients_tbl OUT NOCOPY vc2_tbl_type,
                            x_return_status OUT NOCOPY VARCHAR2)
            IS
  counter PLS_INTEGER;
  CURSOR c_clients_yy IS
    SELECT DISTINCT a.user_name user_name
    FROM asg_user a, asg_users_inqinfo b
    WHERE a.user_name = b.device_user_name AND
          b.processed in ('I', 'N') AND
          a.enabled = 'Y'
    ORDER BY a.user_name;
  CURSOR c_clients_yn IS
    SELECT DISTINCT a.user_name user_name
    FROM asg_user a, asg_users_inqinfo b
    WHERE a.user_name = b.device_user_name AND
          b.deferred = 'N' AND b.processed <> 'Y' AND
          a.enabled = 'Y'
    ORDER BY a.user_name;
  CURSOR c_clients_ny IS
    SELECT DISTINCT a.user_name user_name
    FROM asg_user a, asg_users_inqinfo b
    WHERE a.user_name = b.device_user_name AND
          b.deferred <> 'N' and b.processed <> 'Y'
    ORDER BY a.user_name;
  BEGIN

    -- Trivial case
    IF ((p_dirty = FND_API.G_MISS_CHAR) OR (p_dirty IS NULL)) AND
       ((p_deferred = FND_API.G_MISS_CHAR) OR  (p_deferred IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    IF ( (p_dirty NOT IN ('Y', 'N')) OR (p_deferred NOT IN ('Y', 'N')) ) OR
       ( (p_dirty = 'N') AND (p_deferred = 'N') ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    counter :=1;
    IF (p_dirty = 'Y') THEN
      IF(p_deferred = 'Y') THEN
        FOR cclnt_yy IN c_clients_yy LOOP
          x_clients_tbl(counter) := cclnt_yy.user_name;
          counter := counter+1;
        END LOOP;
      ELSE
        log('get_all_clients: Getting all users with ' ||
                             'dirty tranids',g_stmt_level);
        FOR cclnt_yn IN c_clients_yn LOOP
          x_clients_tbl(counter) := cclnt_yn.user_name;
          counter  := counter+1;
        END LOOP;
      END IF;
    ELSIF (p_dirty = 'N') THEN
        FOR cclnt_ny IN c_clients_ny LOOP
          x_clients_tbl(counter) := cclnt_ny.user_name;
          counter  := counter+1;
        END LOOP;
    END IF;

  END get_all_clients;

  PROCEDURE get_all_tranids(p_user_name IN VARCHAR2,
                            x_tranids_tbl OUT NOCOPY num_tbl_type,
                            x_return_status OUT NOCOPY VARCHAR2)
            IS
  counter PLS_INTEGER;
  CURSOR c_all_tran (p_user_name VARCHAR2) IS
    SELECT tranid
    FROM asg_users_inqinfo a
    WHERE a.device_user_name = p_user_name
    ORDER BY tranid;
  BEGIN
    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL))THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    counter :=1;
    FOR cat IN c_all_tran(p_user_name) LOOP
      x_tranids_tbl(counter) := cat.tranid;
      counter := counter +1;
    END LOOP;

  END get_all_tranids;

  -- get the names of all publication items that have
  -- records for the specified tran_id
  PROCEDURE get_all_pub_items(p_user_name IN VARCHAR2,
                              p_tranid   IN NUMBER,
                              x_pubitems_tbl OUT NOCOPY vc2_tbl_type,
                              x_return_status OUT NOCOPY VARCHAR2)
            IS
  counter                  PLS_INTEGER;
  l_cursor_id              NUMBER;
  l_cursor_ret             NUMBER;
  l_cursor_id1             NUMBER;
  l_cursor_ret1            NUMBER;
  l_store                  VARCHAR2(30);
  l_select_store_sqlstring VARCHAR2(512);
  l_select_obj_sqlstring   VARCHAR2(4000);
  l_obj_name               VARCHAR2(30);
  BEGIN
    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_select_store_sqlstring :=
      'SELECT store ' ||
      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq '||
      'WHERE clid$$cs = :1 AND ' ||
      '      tranid$$ = :2 AND '||
      '      store in (select item_id from asg_pub_item) ' ||
      ' ORDER BY store';

    l_cursor_id1 := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id1, l_select_store_sqlstring, DBMS_SQL.v7);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id1, 1, l_store, 30);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':1', p_user_name);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':2', p_tranid);
    l_cursor_ret1 := DBMS_SQL.EXECUTE (l_cursor_id1);

    counter := 1;
    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id1) > 0 ) LOOP
      DBMS_SQL.COLUMN_VALUE (l_cursor_id1, 1, l_store);
      x_pubitems_tbl(counter) := l_store;
      counter := counter +1;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id1);

    IF (x_pubitems_tbl IS NULL) THEN
      counter :=1;
    ELSE
      counter := x_pubitems_tbl.count +1;
    END IF;

    l_select_obj_sqlstring :=
      'SELECT object_name ' ||
      'FROM asg_deferred_traninfo ' ||
      'WHERE device_user_name = :user_name AND ' ||
      '      deferred_tran_id = :tranid AND ' ||
      '      object_name not in ' ||
      '      (SELECT store ' ||
      '       FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq ' ||
      '       WHERE clid$$cs = :user_name AND ' ||
      '       tranid$$ = :tranid) ' ||
      ' ORDER BY object_name';

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id, l_select_obj_sqlstring, DBMS_SQL.v7);
    DBMS_SQL.BIND_VARIABLE (l_cursor_id, ':user_name', p_user_name );
    DBMS_SQL.BIND_VARIABLE (l_cursor_id, ':tranid', p_tranid );

    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 1, l_obj_name, 30);
    l_cursor_ret := DBMS_SQL.EXECUTE (l_cursor_id);

    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0 ) LOOP
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 1, l_obj_name);
       x_pubitems_tbl(counter) := l_obj_name;
      counter := counter +1;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

  END get_all_pub_items;

  -- get the names of all publication items that have
  -- records for the specified tran_id
  PROCEDURE get_all_pub_items(p_user_name IN VARCHAR2,
                              p_tranid   IN NUMBER,
                              p_pubname IN VARCHAR2,
                              x_pubitems_tbl OUT NOCOPY vc2_tbl_type,
                              x_return_status OUT NOCOPY VARCHAR2)
            IS
  counter                  PLS_INTEGER;
  l_cursor_id              NUMBER;
  l_cursor_ret             NUMBER;
  l_cursor_id1             NUMBER;
  l_cursor_ret1            NUMBER;
  l_store                  VARCHAR2(30);
  l_select_store_sqlstring VARCHAR2(512);
  l_select_obj_sqlstring   VARCHAR2(4000);
  l_obj_name               VARCHAR2(30);
  BEGIN
    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) OR
       ((p_pubname = FND_API.G_MISS_CHAR) OR (p_pubname IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_select_store_sqlstring :=
      'SELECT store ' ||
      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq '||
      'WHERE clid$$cs = :1 AND ' ||
      '      tranid$$ = :2 AND ' ||
      '      store in ' ||
      '      (SELECT name ' ||
      '       FROM asg_pub_item ' ||
      '       WHERE pub_name = :3) ' ||
      ' ORDER BY store';

    l_cursor_id1 := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id1, l_select_store_sqlstring, DBMS_SQL.v7);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id1, 1, l_store, 30);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':1', p_user_name);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':2', p_tranid);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':3', p_pubname);
    l_cursor_ret1 := DBMS_SQL.EXECUTE (l_cursor_id1);

    counter := 1;
    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id1) > 0 ) LOOP
      DBMS_SQL.COLUMN_VALUE (l_cursor_id1, 1, l_store);
      x_pubitems_tbl(counter) := l_store;
      counter := counter +1;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id1);

    IF (x_pubitems_tbl IS NULL) THEN
      counter :=1;
    ELSE
      counter := x_pubitems_tbl.count +1;
    END IF;

    l_select_obj_sqlstring :=
      'SELECT object_name ' ||
      'FROM asg_deferred_traninfo ' ||
      'WHERE device_user_name = :user_name AND ' ||
      '      deferred_tran_id = :tranid AND ' ||
      '      object_name IN ' ||
      '      (SELECT name ' ||
      '       FROM asg_pub_item ' ||
      '       WHERE pub_name = :pubname) AND ' ||
      '      object_name not in ' ||
      '      (SELECT store ' ||
      '       FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq ' ||
      '       WHERE clid$$cs = :user_name AND ' ||
      '       tranid$$ = :tranid) ' ||
      ' ORDER BY object_name';

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id, l_select_obj_sqlstring, DBMS_SQL.v7);
    DBMS_SQL.BIND_VARIABLE (l_cursor_id, ':user_name', p_user_name );
    DBMS_SQL.BIND_VARIABLE (l_cursor_id, ':tranid', p_tranid );
    DBMS_SQL.BIND_VARIABLE (l_cursor_id, ':pubname', p_pubname );

    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 1, l_obj_name, 30);
    l_cursor_ret := DBMS_SQL.EXECUTE (l_cursor_id);

    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0 ) LOOP
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 1, l_obj_name);
       x_pubitems_tbl(counter) := l_obj_name;
      counter := counter +1;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

    sort_by_weight(p_pubname, x_pubitems_tbl);

  END get_all_pub_items;

  -- get the names of all publication items that have dirty
  -- records for the specified tran_id
  PROCEDURE get_all_dirty_pub_items(p_user_name IN VARCHAR2,
                                    p_tranid   IN NUMBER,
                                    p_pubname IN VARCHAR2,
                                    x_pubitems_tbl OUT NOCOPY vc2_tbl_type,
                                    x_return_status OUT NOCOPY VARCHAR2)
            IS
  counter                  PLS_INTEGER;
  l_cursor_id1             NUMBER;
  l_cursor_ret1            NUMBER;
  l_store                  VARCHAR2(30);
  l_select_store_sqlstring VARCHAR2(512);
  BEGIN
    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) OR
       ((p_pubname = FND_API.G_MISS_CHAR) OR (p_pubname IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_select_store_sqlstring :=
      'SELECT store ' ||
      'FROM ' || asg_base.G_OLITE_SCHEMA ||'.c$inq '||
      'WHERE clid$$cs = :1 AND ' ||
      '      tranid$$ = :2 AND ' ||
      '      store not in ' ||
      '      (SELECT object_name ' ||
      '       FROM asg_deferred_traninfo  ' ||
      '       WHERE device_user_name = :3 AND ' ||
      '             deferred_tran_id = :4) AND ' ||
      '      store in ' ||
      '      (SELECT name ' ||
      '       FROM asg_pub_item ' ||
      '       WHERE pub_name = :5) ' ||
      ' ORDER BY store';

    l_cursor_id1 := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id1, l_select_store_sqlstring, DBMS_SQL.v7);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id1, 1, l_store, 30);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':1', p_user_name);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':2', p_tranid);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':3', p_user_name);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':4', p_tranid);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':5', p_pubname);
    l_cursor_ret1 := DBMS_SQL.EXECUTE (l_cursor_id1);

    counter := 1;
    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id1) > 0 ) LOOP
      DBMS_SQL.COLUMN_VALUE (l_cursor_id1, 1, l_store);
      x_pubitems_tbl(counter) := l_store;
      counter := counter +1;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id1);

    sort_by_weight(p_pubname, x_pubitems_tbl);

  END get_all_dirty_pub_items;

  -- Will set x_return_status to FND_API.G_RET_STS_ERROR if no tranid exists
  -- Returns both dirty and deferred tranids
  PROCEDURE get_first_tranid(p_user_name IN VARCHAR2,
                             x_tranid OUT NOCOPY NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2)
            IS
  CURSOR c_first_tran (p_user_name VARCHAR2) IS
    SELECT min(tranid) tran_id
    FROM asg_users_inqinfo a
    WHERE a.device_user_name = p_user_name AND
    a.deferred='N'
    AND a.tranid <=
    (SELECT  nvl(hwm_tranid,1000000000000)
     FROM asg_user
     WHERE user_name=p_user_name);
  l_compacted_tranid NUMBER;
  BEGIN
    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL))THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

--12.1
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    OPEN c_first_tran(p_user_name);
    FETCH c_first_tran into x_tranid;
    IF c_first_tran%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      CLOSE c_first_tran;
      RETURN;
    END IF;
    CLOSE c_first_tran;

    get_compacted_tranid(p_user_name, x_tranid,
                         l_compacted_tranid, x_return_status);
    x_tranid := l_compacted_tranid;
    log('get_first_tranid: Returning UserName: ' || p_user_name ||
        ' TranID: ' || x_tranid);

  END get_first_tranid;

  -- Will set x_return_status to FND_API.G_RET_STS_ERROR if no tranid exists
  -- Returns both dirty and deferred tranids
  PROCEDURE get_next_tranid(p_user_name IN VARCHAR2,
                            p_curr_tranid IN NUMBER,
                            x_tranid OUT NOCOPY NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2)
            IS
  CURSOR c_next_tran (p_user_name VARCHAR2, p_tranid VARCHAR2) IS
    SELECT min(tranid) tran_id
    FROM asg_users_inqinfo a
    WHERE tranid > p_tranid AND
          a.device_user_name = p_user_name AND
          a.deferred='N'
	  AND a.tranid <=
	  (SELECT nvl(hwm_tranid,1000000000000)
	   FROM asg_user
	   WHERE user_name=p_user_name);
  l_compacted_tranid NUMBER;
  BEGIN
    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
      ((p_curr_tranid = FND_API.G_MISS_NUM) OR (p_curr_tranid IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

--12.1
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    OPEN c_next_tran(p_user_name, p_curr_tranid);
    FETCH c_next_tran into x_tranid;
    IF x_tranid IS NULL THEN
      -- When the current tranid is the last one, set the next tranid
      -- also to the last one.
      x_tranid := p_curr_tranid;
      x_return_status := FND_API.G_RET_STS_ERROR;
      CLOSE c_next_tran;
      RETURN;
    END IF;
    CLOSE c_next_tran;

    get_compacted_tranid(p_user_name, x_tranid,
                         l_compacted_tranid, x_return_status);
    x_tranid := l_compacted_tranid;
    log('get_next_tranid: Returning UserName: ' || p_user_name ||
        ' Current TranID: ' || p_curr_tranid ||
        ' Next TranID: ' || x_tranid);

  END get_next_tranid;

--12.1
  -- Will set x_return_status to FND_API.G_RET_STS_ERROR if no tranid exists
  -- Returns both dirty and deferred tranids
  PROCEDURE get_compacted_tranid(p_user_name IN VARCHAR2,
                                 p_tranid IN NUMBER,
                                 x_compacted_tranid OUT NOCOPY NUMBER,
                                 x_return_status OUT NOCOPY VARCHAR2)
    IS
  CURSOR c_auto_sync_tranid(p_user_name VARCHAR2, p_tranid NUMBER) IS
  SELECT sync_id
  FROM asg_auto_sync_tranids
  WHERE user_name = p_user_name
  AND upload_tranid = p_tranid;
  l_sync_id NUMBER;

  BEGIN
    log('get_compacted_tranid: UserName: ' || p_user_name ||
        ' Current TranID: ' || p_tranid);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_auto_sync_tranid(p_user_name, p_tranid);
    FETCH c_auto_sync_tranid into l_sync_id;
    IF c_auto_sync_tranid%NOTFOUND OR l_sync_id is null THEN
      -- If there is no record in asg_auto_sync_tranids for a particular tranid
      -- assume it is NOT auto sync
      x_compacted_tranid := p_tranid;
      CLOSE c_auto_sync_tranid;
      -- Remove the asg_sync_info record
      DELETE FROM asg_auto_sync_tranids
      WHERE user_name = p_user_name
	  AND  upload_tranid <= x_compacted_tranid;
      return;
    END IF;
    CLOSE c_auto_sync_tranid;



    process_auto_sync(p_user_name, p_tranid,
                           x_compacted_tranid, x_return_status);
    log('get_compacted_tranid: UserName: ' || p_user_name ||
        ' Current TranID: ' || p_tranid ||
        ' Compacted TranID: ' || x_compacted_tranid ||
        ' Return Status: ' || x_return_status);

  END get_compacted_tranid;

--12.1
  -- Will set x_return_status to FND_API.G_RET_STS_ERROR if there is an error
  PROCEDURE process_auto_sync(p_user_name IN VARCHAR2,
                                   p_tranid IN NUMBER,
                                   x_compacted_tranid OUT NOCOPY NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2)
    IS
  CURSOR c_end_auto_sync(p_user_name VARCHAR2,
                         p_tranid NUMBER) IS
  SELECT sync_id
  FROM asg_auto_sync_tranids
  WHERE user_name = p_user_name
  AND  upload_tranid = p_tranid;

  l_end_tranid              NUMBER;
  l_compact_tranid          NUMBER;
  BEGIN
    log('process_auto_sync: UserName: ' || p_user_name ||
        ' Current TranID: ' || p_tranid);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_end_auto_sync(p_user_name, p_tranid);
    FETCH c_end_auto_sync into l_end_tranid;
    -- Shouldn't happen normally. Handle gracefully.
    IF l_end_tranid IS NULL THEN
      x_compacted_tranid := p_tranid;
      x_return_status := FND_API.G_RET_STS_ERROR;
      CLOSE c_end_auto_sync;
      RETURN;
    END IF;
    CLOSE c_end_auto_sync;

  l_compact_tranid := l_end_tranid;
  x_compacted_tranid := l_compact_tranid;

    log('process_auto_sync: UserName: ' || p_user_name ||
        ' Current TranID: ' || p_tranid ||
        ' End TranID: ' || l_end_tranid||
        ' Compacted TranID: ' || x_compacted_tranid);

   IF p_tranid<>l_end_tranid THEN
    -- OK, we now know the tranid to use for all synchs with start tranid of
    -- p_tranid and end_tranid of l_end_tranid. Start Compacting

    -- Process c$inq first
    log('process_auto_sync: Processing c$inq');
    compact_cinq(p_user_name, p_tranid, l_end_tranid, l_compact_tranid);

    -- Process asg_users_inqinfo/asg_users_inqarchive
    log('process_auto_sync: Processing asg inq info tables');
    compact_asginq(p_user_name, p_tranid, l_end_tranid, l_compact_tranid);

    -- Process inq tables
    log('process_auto_sync: Processing inq tables');
    compact_inqtables(p_user_name, p_tranid, l_end_tranid, l_compact_tranid);

  END IF;
    -- Delete from asg_auto_sync_tranids table.

    DELETE FROM asg_auto_sync_tranids
    WHERE user_name = p_user_name
	AND  upload_tranid <= l_end_tranid;

    log('process_auto_synch: Done Processing auto sync.');

  END process_auto_sync;


  -- Procedure to delete a row that is not deferred
  PROCEDURE delete_row(p_user_name IN VARCHAR2,
                       p_tranid IN NUMBER,
                       p_pubitem IN VARCHAR2,
                       p_sequence IN NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2)
            IS
  l_deferred_row VARCHAR2(1);
  inq_tbl_name VARCHAR2(30);
  sql_string VARCHAR2(512);
  BEGIN

    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) OR
       ((p_pubitem = FND_API.G_MISS_CHAR) OR (p_pubitem IS NULL)) OR
       ((p_sequence = FND_API.G_MISS_NUM) OR (p_sequence IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    inq_tbl_name := 'CFM$' || p_pubitem;
    sql_string :=  'DELETE FROM ' || asg_base.G_OLITE_SCHEMA ||
                   '.' || inq_tbl_name ||
                   ' WHERE clid$$cs = :1 AND ' ||
                   ' tranid$$ = :2 AND ' ||
                   ' seqno$$ = :3';
    print_string('delete_row: SQL Command: ' || sql_string);

    BEGIN
      EXECUTE IMMEDIATE sql_string
      USING p_user_name, p_tranid, p_sequence;
    EXCEPTION
    WHEN OTHERS THEN
      -- Ignore exceptions
      x_return_status := FND_API.G_RET_STS_ERROR;
      log('delete_row: Exception: ', g_err_level);
    END;

    l_deferred_row := asg_defer.is_deferred(p_user_name, p_tranid,
                                            p_pubitem, p_sequence);
    -- Update status to processed or passed
    IF l_deferred_row = FND_API.G_TRUE THEN
      BEGIN
        UPDATE asg_deferred_traninfo
        SET status = 0
        WHERE device_user_name = p_user_name AND
          deferred_tran_id = p_tranid AND
          object_name = p_pubitem AND
          sequence = p_sequence;
      EXCEPTION
      WHEN OTHERS THEN
        -- Ignore exceptions
        log('delete_row: Exception: tranid not deferred',g_err_level);
      END;
    END IF;

  END delete_row;


  -- Procedure to purge all the dirty INQ records for
  -- the specified user/transid/publication-item(s)
  PROCEDURE purge_pubitems_internal(p_user_name IN VARCHAR2,
                                    p_tranid   IN NUMBER,
                                    p_pubitems_tbl  IN vc2_tbl_type,
                                    x_return_status OUT NOCOPY VARCHAR2)
            IS
  num_pubitems PLS_INTEGER;
  counter PLS_INTEGER;
  curr_pubitem VARCHAR2(30);
  inq_tbl_name VARCHAR2(30);
  sql_string VARCHAR2(512);
  BEGIN
    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) OR
       (p_pubitems_tbl IS NULL) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    num_pubitems := p_pubitems_tbl.count;
    FOR curr_index in 1..num_pubitems LOOP
      curr_pubitem := p_pubitems_tbl(curr_index);
      inq_tbl_name := 'CFM$' || curr_pubitem;
      -- Should change this statement to use bind-variables
      sql_string := 'DELETE FROM  ' || asg_base.G_OLITE_SCHEMA ||
                    '.' || inq_tbl_name ||
                    ' WHERE clid$$cs = :1 AND ' ||
                    ' tranid$$ = :2 AND ' ||
                    ' seqno$$ NOT IN  ' ||
                    ' (SELECT sequence ' ||
                    '  FROM asg_deferred_traninfo ' ||
                    '  WHERE device_user_name = :3 AND '||
                    '  object_name = :4)';
      print_string('purge_pubitems_internal: SQL Command: ' || sql_string);
      EXECUTE IMMEDIATE sql_string
      USING p_user_name, p_tranid,
            p_user_name, curr_pubitem;

      sql_string := 'DELETE FROM ' || asg_base.G_OLITE_SCHEMA ||
                    '.' || 'c$inq ' ||
                    'WHERE clid$$cs = :1 AND ' ||
                    '      tranid$$ = :2 AND ' ||
                    '      store = :3';
      print_string('purge_pubitems_internal: SQLCommand: ' || sql_string);
      EXECUTE IMMEDIATE sql_string
      USING p_user_name, p_tranid, curr_pubitem;
    END LOOP;


  END purge_pubitems_internal;

  -- Procedure to purge all the dirty INQ records for
  -- the specified user/transid/publication-item(s)
  PROCEDURE purge_pubitems(p_user_name IN VARCHAR2,
                           p_tranid   IN NUMBER,
                           p_pubitems_tbl  IN vc2_tbl_type,
                           x_return_status OUT NOCOPY VARCHAR2)
            IS
  num_pubitems PLS_INTEGER;
  counter PLS_INTEGER;
  curr_pubitem VARCHAR2(30);
  inq_tbl_name VARCHAR2(30);
  sql_string VARCHAR2(1024);
  l_deferred_trans BOOLEAN := FALSE;
  l_resource_id NUMBER;
  CURSOR c_resource_id (p_user_name VARCHAR2) IS
    SELECT resource_id
    FROM asg_user
    WHERE user_name = p_user_name;
  BEGIN
    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) OR
       (p_pubitems_tbl IS NULL) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    num_pubitems := p_pubitems_tbl.count;
    FOR curr_index in 1..num_pubitems LOOP
      curr_pubitem := p_pubitems_tbl(curr_index);
      -- Change to <pubitem_name>_inq once that synonym exists
      inq_tbl_name := 'CFM$' || curr_pubitem;
      log('Deferring unprocessed records in publication item: ' || curr_pubitem,
          g_stmt_level);

      OPEN c_resource_id(p_user_name);
      FETCH c_resource_id INTO l_resource_id;
      IF c_resource_id%NOTFOUND THEN
        CLOSE c_resource_id;
        log('purge_pubitems: User: ' || p_user_name ||
               ' not found in asg_user table',g_err_level);
        x_return_status := FND_API.G_RET_STS_ERROR;
        return;
      END IF;
      CLOSE c_resource_id;

      -- Defer those records that were not already deferred or deleted during
      -- processing by wrapper
      sql_string := 'INSERT INTO asg_deferred_traninfo ('||
                                         'DEVICE_USER_NAME, ' ||
                                         'RESOURCE_ID, ' ||
                                         'DEFERRED_TRAN_ID, ' ||
                                         'MOBILE_ERROR_ID, ' ||
                                         'ERROR_DESCRIPTION, ' ||
                                         'OBJECT_NAME, ' ||
                                         'SEQUENCE, ' ||
                                         'STATUS, ' ||
                                         'SYNC_TIME, ' ||
                                         'FAILURES, ' ||
                                         'LAST_UPDATE_DATE, ' ||
                                         'LAST_UPDATED_BY, ' ||
                                         'CREATION_DATE, ' ||
                                         'CREATED_BY) ' ||
             'SELECT :1, :2, :3, ' ||
                    ' NULL,' ||
                    '''Row deferred because it was left unprocessed'',' ||
                    ' :4,' ||
                    'seqno$$, ' ||
                    '1,' ||
                    'NULL,' ||
                    '1,' ||
                    'SYSDATE,' ||
                    '1,' ||
                    'SYSDATE,'||
                    '1 ' ||
             'FROM ' || asg_base.G_OLITE_SCHEMA || '.' || inq_tbl_name ||
             ' b WHERE b.clid$$cs = :5 AND ' ||
             ' tranid$$ = :6 AND ' ||
             '  b.seqno$$ not in (SELECT sequence ' ||
                                 'FROM asg_deferred_traninfo ' ||
                                 'WHERE device_user_name = :7 AND ' ||
                                 '  deferred_tran_id = :8 '||
                                 ' AND object_name = :9)';
        --print_string('purge_pubitems: SQL Command: ' || sql_string);
        BEGIN
          EXECUTE IMMEDIATE sql_string
          USING p_user_name, l_resource_id, p_tranid,
                curr_pubitem, p_user_name,
                p_tranid, p_user_name, p_tranid, curr_pubitem;

          log('Number of rows deferred: ' || SQL%ROWCOUNT,g_stmt_level);
          IF SQL%ROWCOUNT  >0 THEN
            l_deferred_trans := TRUE;
          END IF;
        EXCEPTION
        WHEN OTHERS THEN
          log('purge_pubitems: Exception executing the SQL Command ' ||
               SQLERRM,g_err_level);
        END;

      sql_string := 'DELETE FROM ' || asg_base.G_OLITE_SCHEMA ||
                    '.' || 'c$inq ' ||
                    'WHERE clid$$cs = :1 AND ' ||
                    '      tranid$$ = :2 AND ' ||
                    '      store = :3';
      print_string('purge_pubitems: SQLCommand: ' || sql_string);
      EXECUTE IMMEDIATE sql_string
      USING p_user_name, p_tranid, curr_pubitem;

    END LOOP;

    IF (l_deferred_trans = TRUE) THEN
      UPDATE asg_users_inqinfo
      SET deferred = 'Y', processed = 'I',
        last_update_date = SYSDATE, last_updated_by = 1
      WHERE device_user_name = p_user_name AND
        tranid = p_tranid;
    END IF;

  END purge_pubitems;

  -- Procedure to purge all the dirty INQ records for
  -- the specified user/transid
  PROCEDURE purge_pubitems(p_user_name IN VARCHAR2,
                           p_tranid  IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2)
            IS
  counter                  PLS_INTEGER;
  l_cursor_id1             NUMBER;
  l_cursor_ret1            NUMBER;
  l_store                  VARCHAR2(30);
  l_select_store_sqlstring VARCHAR2(512);
  l_pubitems_tbl vc2_tbl_type;
  BEGIN

    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_select_store_sqlstring :=
      'SELECT store ' ||
      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq '||
      'WHERE clid$$cs = :1 AND ' ||
      '      tranid$$ = :2 AND ' ||
      '      store in (select item_id from asg_pub_item) ' ||
      ' ORDER BY store';

    l_cursor_id1 := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id1, l_select_store_sqlstring, DBMS_SQL.v7);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id1, 1, l_store, 30);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':1', p_user_name);
    DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':2', p_tranid);
    l_cursor_ret1 := DBMS_SQL.EXECUTE (l_cursor_id1);

    counter := 1;
    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id1) > 0 ) LOOP
      DBMS_SQL.COLUMN_VALUE (l_cursor_id1, 1, l_store);
      l_pubitems_tbl(counter) := l_store;
      counter := counter +1;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id1);

    -- Found some dirty pub-items for this <p_user_name, p_tranid>
    IF (l_pubitems_tbl IS NOT NULL) AND
       (l_pubitems_tbl.count > 0) THEN
      purge_pubitems(p_user_name, p_tranid, l_pubitems_tbl, x_return_status);
    END IF;

    -- If no deferred rows, set processed = 'Y'
    UPDATE asg_users_inqinfo
    SET processed = 'Y', last_update_date=SYSDATE, last_updated_by=1
    WHERE device_user_name = p_user_name AND
          tranid = p_tranid AND
          tranid not IN
          (SELECT distinct deferred_tran_id
           FROM asg_deferred_traninfo
           WHERE device_user_name = p_user_name AND
                 deferred_tran_id = p_tranid);

  END purge_pubitems;

  -- Procedure to purge all the dirty INQ records for
  -- the specified user
  PROCEDURE purge_pubitems(p_user_name IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2)
            IS

  counter PLS_INTEGER;
  curr_tranid NUMBER;
  l_tranid_tbl num_tbl_type;
  cursor c_tranids (p_user_name VARCHAR2, p_max_tranid NUMBER) IS
    SELECT tranid
    FROM asg_users_inqinfo
    WHERE device_user_name = p_user_name AND
          tranid <= p_max_tranid;
  BEGIN
    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    counter :=1;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get all the tranids for this user
    FOR cti in c_tranids(p_user_name, g_current_tranid) LOOP
      l_tranid_tbl(counter) := cti.tranid;
      counter := counter+1;
    END LOOP;

    -- Process one tranid at a time.
    IF counter >1 THEN
      FOR curr_index in 1..l_tranid_tbl.count LOOP
        curr_tranid := l_tranid_tbl(curr_index);
        log('purge_pubitems: Purging tranid: ' || curr_tranid,g_stmt_level);
        purge_pubitems(p_user_name, curr_tranid, x_return_status);
      END LOOP;
    END IF;

  END purge_pubitems;

  -- Signal the beginning of inq processing for an user
  -- returns FND_API.G_FALSE if no inq processing is necessary for this user
  PROCEDURE begin_client_apply(p_user_name IN VARCHAR2,
                               x_begin_client_apply OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2)
            IS
  l_sync_tables PLS_INTEGER;
  l_tranids_tbl num_tbl_type;
  curr_tranid NUMBER;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_begin_client_apply := FND_API.G_TRUE;

    -- Check if the c$inq and asg_users_inqinfo are in sync.
    get_sync_state(p_user_name, l_sync_tables);
    log('begin_client_apply: l_sync_tables: ' || l_sync_tables,g_stmt_level);

    IF l_sync_tables = 1 THEN
      -- Get all the tranids in c$inq that are not in asg_users_inqinfo
      get_new_tranids(p_user_name, l_tranids_tbl);

      FOR curr_index in 1..l_tranids_tbl.count LOOP
        curr_tranid := l_tranids_tbl(curr_index);
        setup_inq_info(p_user_name, curr_tranid, x_return_status);
      END LOOP;

    END IF;
    COMMIT;

  END begin_client_apply;

  -- Signal the end of inq processing for an user
  -- All dirty records processed in this session will be removed.
  PROCEDURE end_client_apply(p_user_name IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2)
            IS
  curr_tranid NUMBER;
  curr_tran_processed VARCHAR2(1);
  curr_tran_deferred  VARCHAR2(1);
  curr_tran_archive  VARCHAR2(1);
  CURSOR c_archive_asg_users(p_user_name VARCHAR2) IS
    SELECT tranid, processed, deferred, archive
    FROM asg_users_inqinfo
    WHERE device_user_name = p_user_name;
  BEGIN

    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    purge_pubitems(p_user_name, x_return_status);
    FOR caau in c_archive_asg_users(p_user_name) LOOP
      curr_tranid := caau.tranid;
      curr_tran_processed := caau.processed;
      curr_tran_deferred := caau.deferred;
      curr_tran_archive := caau.archive;
      IF (curr_tran_processed = 'Y') AND (curr_tran_archive = 'Y') THEN
        UPDATE asg_users_inqarchive
        SET processed = 'Y', deferred = curr_tran_deferred,
          last_update_date = SYSDATE, last_updated_by = 1
        WHERE device_user_name = p_user_name AND
          tranid = curr_tranid;
      END IF;
    END LOOP;

    DELETE FROM asg_users_inqinfo
    WHERE device_user_name = p_user_name AND processed = 'Y';
    COMMIT;

  END end_client_apply;

  -- Should be called before any user's transactions are processed
  -- returns FND_API.G_FALSE if no user has dirty/deferred data in inq.
  PROCEDURE begin_apply(x_begin_apply OUT NOCOPY VARCHAR2,
                        x_return_status OUT NOCOPY VARCHAR2)
            IS
  counter                  PLS_INTEGER;
  l_cursor_id              NUMBER;
  l_cursor_ret             NUMBER;
  l_select_users_sqlstring VARCHAR2(512);
  l_user_name              VARCHAR2(30);
  l_begin_client_apply VARCHAR2(1);
  l_return_status VARCHAR2(1);
  curr_user VARCHAR2(30);
  l_users_tbl vc2_tbl_type;
  sql_string VARCHAR2(30);
  l_def_count PLS_INTEGER;
  CURSOR c_deferred IS
    SELECT count(*) def_trans
    FROM asg_deferred_traninfo;
  BEGIN

    x_begin_apply := FND_API.G_TRUE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get the list of users with dirty data
    l_select_users_sqlstring :=
      'SELECT distinct clid$$cs clientid ' ||
      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq ' ||
      ' WHERE store in (select item_id from asg_pub_item) ';

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id, l_select_users_sqlstring, DBMS_SQL.v7);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 1, l_user_name, 30);
    l_cursor_ret := DBMS_SQL.EXECUTE (l_cursor_id);

    counter := 1;
    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0 ) LOOP
      IF counter =1 THEN
        log('begin_apply: Following users have uploaded new data',g_stmt_level);
      END IF;
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 1, l_user_name);
      l_users_tbl(counter) := l_user_name;
      log('begin_apply:     ' || l_users_tbl(counter),g_stmt_level);
      counter := counter +1;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

    IF counter = 1 THEN
      log('begin_apply: Did not find any user with dirty data',g_stmt_level);
      OPEN c_deferred;
      FETCH c_deferred into l_def_count;
      CLOSE c_deferred;
      IF l_def_count = 0 THEN
      -- No uploaded data, dirty or deferred
        x_begin_apply := FND_API.G_FALSE;
        g_only_deferred_trans := FND_API.G_FALSE;
      ELSE
        x_begin_apply := FND_API.G_TRUE;
        g_only_deferred_trans := FND_API.G_TRUE;
      END IF;
    ELSIF (counter >1) THEN
      g_only_deferred_trans := FND_API.G_FALSE;
      FOR curr_index IN 1..l_users_tbl.count LOOP
        curr_user := l_users_tbl(curr_index);
        begin_client_apply(curr_user, l_begin_client_apply, l_return_status);
      END LOOP;
    END IF;

  END begin_apply;

  -- Should be called at the end of the apply for all clients in that
  -- session. Always returns TRUE.
  PROCEDURE end_apply(x_return_status OUT NOCOPY VARCHAR2)
            IS
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END end_apply;

-- Procedure to process synchronous mobile queries from client
  PROCEDURE process_mobile_queries(p_user_name IN VARCHAR2,
                                   p_tranid IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2)
  IS
   l_sql VARCHAR2(1000);
   l_pi_name VARCHAR2(100) := 'CSM_QUERY_INSTANCES';
   l_exists NUMBER;
   l_sqlerrno VARCHAR2(20);
   l_sqlerrmsg VARCHAR2(2000);

  BEGIN

    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) THEN
      log('process_mobile_queries: Invalid user or tranid passed: ' ||
          'user: ' || p_user_name || ' tranid: ' || p_tranid,g_err_level);
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_sql := 'SELECT 1 FROM '|| asg_base.G_OLITE_SCHEMA
	                 ||'.C$INQ c_inq WHERE CLID$$CS=:1 AND TRANID$$=:2 AND STORE = :3'
                     ||' AND exists (select 1 from '||asg_base.G_OLITE_SCHEMA||'.cfm$'||l_pi_name||' inq, CSM_QUERY_B b '
                                  ||' WHERE tranid$$ = c_inq.tranid$$ '
					              ||' AND   clid$$cs = c_inq.clid$$cs '
					              ||' AND  inq.QUERY_ID=b.QUERY_ID '
					              ||' AND  b.EXECUTION_MODE=''SYNCHRONOUS'')';

    EXECUTE IMMEDIATE l_sql INTO l_exists USING p_user_name, p_tranid, l_pi_name;

	log('process_mobile_queries: Calling CSM api to process Synchronous Mobile Queries');

	l_sql := 'Begin CSM_QUERY_INSTANCE_PKG.APPLY_CLIENT_CHANGES(:1,:2,:3,:4,:5);  end;';

    EXECUTE IMMEDIATE l_sql USING p_user_name,p_tranid,g_stmt_level,'Y',in out x_return_status;

    log('process_mobile_queries: status returned by CSM api - '||x_return_status);

	IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

              l_sql := 'DELETE FROM ' || asg_base.G_OLITE_SCHEMA
	                 ||'.c$inq c_inq WHERE CLID$$CS = :1 AND TRANID$$ = :2 AND STORE = :3'
                     ||' AND not exists (select 1 from '||asg_base.G_OLITE_SCHEMA||'.cfm$'||l_pi_name||' inq '
                                  ||' WHERE tranid$$ = c_inq.tranid$$ '
					              ||' AND   clid$$cs = c_inq.clid$$cs )';

             EXECUTE IMMEDIATE l_sql USING p_user_name, p_tranid, l_pi_name;

              l_sql := 'DELETE FROM ' || asg_base.G_OLITE_SCHEMA
	                 ||'.c$inq c_inq WHERE CLID$$CS = :1 AND TRANID$$ = :2 AND STORE = :3'
                     ||' AND not exists (select 1 from '||asg_base.G_OLITE_SCHEMA||'.cfm$CSM_QUERY_VARIABLE_VALUES inq '
                                  ||' WHERE tranid$$ = c_inq.tranid$$ '
					              ||' AND   clid$$cs = c_inq.clid$$cs )';

             EXECUTE IMMEDIATE l_sql USING p_user_name, p_tranid, 'CSM_QUERY_VARIABLE_VALUES';

    END IF;

   -- if error in CSM api, let Process Upload report error
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
    NULL;
   WHEN Others THEN
      l_sqlerrno := to_char(SQLCODE);
      l_sqlerrmsg := substr(SQLERRM, 1,2000);
	  log('process_mobile_queries: Exception occured for : ' ||
          'user: ' || p_user_name || ' tranid: ' || p_tranid||' - '||l_sqlerrno||':'||l_sqlerrmsg,g_err_level);
  END process_mobile_queries;

-- Backward Compatibility: Procedure to process sequence updates from client on C$ALL_SEQUENCE_PARTITIONS
  PROCEDURE process_sequences_bc(p_user_name IN VARCHAR2,
                                 p_tranid IN NUMBER)
            IS
  counter                 PLS_INTEGER;
  l_cursor_id             NUMBER;
  l_cursor_ret            NUMBER;
  l_sequence              VARCHAR2(30) := 'C$ALL_SEQUENCE_PARTITIONS';
  l_select_seq_sqlstring  VARCHAR2(4000);
  l_update_seq_sqlstring  VARCHAR2(4000);
  l_delete_sqlstring      VARCHAR2(4000);
  l_seq_name              VARCHAR2(30);
  l_curr_val              NUMBER(38);
  l_client_num            NUMBER;
  BEGIN

    counter := 1;

    SELECT client_number INTO l_client_num
    FROM asg_user
    WHERE user_name = p_user_name;

    l_select_seq_sqlstring :=
                   'SELECT a.name name, a.curr_val curr_val '||
                   'FROM ' || asg_base.G_OLITE_SCHEMA ||
                   '.' || 'cfm$c$all_sequence_partitions a, ' ||
                   asg_base.G_OLITE_SCHEMA || '.' || 'c$inq b ' ||
                   'WHERE b.clid$$cs = :user_name AND ' ||
                   'b.tranid$$ = :tranid  AND ' ||
                   'b.store = :seq_name AND ' ||
                   'a.clid$$cs = b.clid$$cs AND ' ||
                   'a.tranid$$ = b.tranid$$';

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id, l_select_seq_sqlstring, DBMS_SQL.v7);
    DBMS_SQL.BIND_VARIABLE (l_cursor_id, ':user_name', p_user_name );
    DBMS_SQL.BIND_VARIABLE (l_cursor_id, ':tranid', p_tranid );
    DBMS_SQL.BIND_VARIABLE (l_cursor_id, ':seq_name', l_sequence );

    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 1, l_seq_name, 30);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 2, l_curr_val);
    l_cursor_ret := DBMS_SQL.EXECUTE (l_cursor_id);

    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0 ) LOOP
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 1, l_seq_name);
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 2, l_curr_val);

      IF(MOD(l_curr_val, 1000000) = l_client_num) THEN
        l_update_seq_sqlstring := 'UPDATE asg_sequence_partitions ' ||
                                  'SET curr_val = :1 ' ||
                                  'WHERE CLIENTID = :2 AND ' ||
                                  '  name = :3 AND ' ||
                                  '  curr_val < :4';
        EXECUTE IMMEDIATE l_update_seq_sqlstring
        USING l_curr_val, p_user_name, l_seq_name, l_curr_val;
        log ('process_sequences_bc: Updating sequence for user: ' || p_user_name ||
             ' sequence: ' || l_seq_name || ' Seq value: ' || l_curr_val);
      ELSE
        log('process_sequences_bc: Users sequence mismatch! Sequence Name: ' || l_seq_name ||
            ' Sequence Value: ' ||l_curr_val || ' Client_Number: ' ||
            l_client_num, FND_LOG.LEVEL_UNEXPECTED);
      END IF;

      counter := counter +1;
      log ('process_sequences_bc:Updating sequence for user: ' || p_user_name ||
           ' sequence: ' || l_seq_name);
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
    IF counter =1  THEN
     log('process_sequences_bc: No sequences need to be updated',g_stmt_level);
    END IF;

    IF counter >1 THEN
      -- Updated sequences
      l_delete_sqlstring := 'DELETE FROM ' || asg_base.G_OLITE_SCHEMA ||
                            '.' || 'c$inq ' ||
                            'WHERE CLID$$CS = :1 AND ' ||
                            'TRANID$$ = :2 AND ' ||
                            'STORE = :3';
      EXECUTE IMMEDIATE l_delete_sqlstring
      USING p_user_name, p_tranid, l_sequence;

      l_delete_sqlstring := 'DELETE FROM ' ||
                            asg_base.G_OLITE_SCHEMA ||
                            '.' ||'cfm$c$all_sequence_partitions ' ||
                            'WHERE CLID$$CS = :1 AND ' ||
                            '  TRANID$$ = :2';
      EXECUTE IMMEDIATE l_delete_sqlstring
      USING p_user_name, p_tranid;
    END IF;

 END process_sequences_bc;

  -- Procedure to process sequence updates from client
  PROCEDURE process_sequences(p_user_name IN VARCHAR2,
                              p_tranid IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2)
            IS
  counter                 PLS_INTEGER;
  l_cursor_id             NUMBER;
  l_cursor_ret            NUMBER;
  l_sequence              VARCHAR2(30) := 'CSM_SEQUENCES';
  l_select_seq_sqlstring  VARCHAR2(4000);
  l_update_seq_sqlstring  VARCHAR2(4000);
  l_delete_sqlstring      VARCHAR2(4000);
  l_seq_name              VARCHAR2(30);
  l_curr_val              NUMBER(38);
  l_client_num            NUMBER;
  BEGIN

    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      log('process_sequences: Invalid user or tranid passed: ' ||
          'user: ' || p_user_name || ' tranid: ' || p_tranid,g_err_level);
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    process_sequences_bc(p_user_name,p_tranid);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    counter := 1;

    SELECT client_number INTO l_client_num
    FROM asg_user
    WHERE user_name = p_user_name;

    l_select_seq_sqlstring :=
                   'SELECT a.name name, a.curr_val curr_val '||
                   'FROM ' || asg_base.G_OLITE_SCHEMA ||
                   '.' || 'cfm$CSM_SEQUENCES a, ' ||
                   asg_base.G_OLITE_SCHEMA || '.' || 'c$inq b ' ||
                   'WHERE b.clid$$cs = :user_name AND ' ||
                   'b.tranid$$ = :tranid  AND ' ||
                   'b.store = :seq_name AND ' ||
                   'a.clid$$cs = b.clid$$cs AND ' ||
                   'a.tranid$$ = b.tranid$$';

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id, l_select_seq_sqlstring, DBMS_SQL.v7);
    DBMS_SQL.BIND_VARIABLE (l_cursor_id, ':user_name', p_user_name );
    DBMS_SQL.BIND_VARIABLE (l_cursor_id, ':tranid', p_tranid );
    DBMS_SQL.BIND_VARIABLE (l_cursor_id, ':seq_name', l_sequence );

    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 1, l_seq_name, 30);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 2, l_curr_val);
    l_cursor_ret := DBMS_SQL.EXECUTE (l_cursor_id);

    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0 ) LOOP
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 1, l_seq_name);
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 2, l_curr_val);

      IF(MOD(l_curr_val, 1000000) = l_client_num) THEN
        l_update_seq_sqlstring := 'UPDATE asg_sequence_partitions ' ||
                                  'SET curr_val = :1 ' ||
                                  'WHERE CLIENTID = :2 AND ' ||
                                  '  name = :3 AND ' ||
                                  '  curr_val < :4';
        EXECUTE IMMEDIATE l_update_seq_sqlstring
        USING l_curr_val, p_user_name, l_seq_name, l_curr_val;
        log ('Updating sequence for user: ' || p_user_name ||
             ' sequence: ' || l_seq_name || ' Seq value: ' || l_curr_val);
      ELSE
        log('Users sequence mismatch! Sequence Name: ' || l_seq_name ||
            ' Sequence Value: ' ||l_curr_val || ' Client_Number: ' ||
            l_client_num, FND_LOG.LEVEL_UNEXPECTED);
      END IF;

      counter := counter +1;
      log ('Updating sequence for user: ' || p_user_name ||
           ' sequence: ' || l_seq_name);
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
    IF counter =1  THEN
     log('No sequences need to be updated',g_stmt_level);
    END IF;

    IF counter >1 THEN
      -- Updated sequences
      l_delete_sqlstring := 'DELETE FROM ' || asg_base.G_OLITE_SCHEMA ||
                            '.' || 'c$inq ' ||
                            'WHERE CLID$$CS = :1 AND ' ||
                            'TRANID$$ = :2 AND ' ||
                            'STORE = :3';
      EXECUTE IMMEDIATE l_delete_sqlstring
      USING p_user_name, p_tranid, l_sequence;

      l_delete_sqlstring := 'DELETE FROM ' ||
                            asg_base.G_OLITE_SCHEMA ||
                            '.' ||'cfm$CSM_SEQUENCES ' ||
                            'WHERE CLID$$CS = :1 AND ' ||
                            '  TRANID$$ = :2';
      EXECUTE IMMEDIATE l_delete_sqlstring
      USING p_user_name, p_tranid;
    END IF;

  END process_sequences;


  -- Procedure to update the upload information
  PROCEDURE setup_inq_info(p_user_name IN VARCHAR2,
                           p_tranid IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2)
            IS
  counter PLS_INTEGER;
  counter2 PLS_INTEGER;
  l_cursor_id1             NUMBER;
  l_cursor_ret1            NUMBER;
  l_store                  VARCHAR2(30);
  l_inq_count NUMBER;
  l_resource_id NUMBER;
  l_select_store_sqlstring VARCHAR2(512);
  l_select_inqcnt_sqlstring VARCHAR2(512);
  l_delete_inq_sqlstring VARCHAR2(512);
  l_pubitems_tbl vc2_tbl_type;
  curr_tranid NUMBER;
  curr_pubitem VARCHAR2(30);
  curr_pubitem_length PLS_INTEGER;
  l_pubitems_max_length PLS_INTEGER := 4000;
  l_pubitems_1 VARCHAR2(4000);
  l_pubitems_2 VARCHAR2(4000);
  CURSOR c_resource_id (p_user_name VARCHAR2) IS
    SELECT resource_id
    FROM asg_user
    WHERE user_name = p_user_name;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    curr_tranid := p_tranid;

    -- Remove any custom pub items from c$inq
    -- Custom pub items are processed directly by custom implementor.
    l_delete_inq_sqlstring :=
      'DELETE from ' || asg_base.G_OLITE_SCHEMA || '.c$inq ' ||
      'WHERE store in ' ||
      '  (SELECT api.name ' ||
      '   FROM asg_pub ap, asg_pub_item api ' ||
      '   WHERE ap.custom = ''Y'' AND ' ||
      '         ap.name = api.pub_name)';
    EXECUTE IMMEDIATE l_delete_inq_sqlstring;

    l_select_inqcnt_sqlstring :=
      'SELECT count(*) ' ||
      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq ci ' ||
      'WHERE clid$$cs = :1 AND ' ||
      '      tranid$$ = :2 AND ' ||
      '	     store in (select item_id from asg_pub_item) ' ||
      'AND NOT EXISTS (SELECT 1 FROM asg_users_inqinfo  ' ||
      ' WHERE device_user_name = ci.clid$$cs AND TRANID =ci.tranid$$) ' ;
    EXECUTE IMMEDIATE l_select_inqcnt_sqlstring
      INTO l_inq_count
      USING p_user_name, p_tranid;

    IF (l_inq_count > 0) THEN

      OPEN c_resource_id(p_user_name);
      FETCH c_resource_id into l_resource_id;
      CLOSE c_resource_id;
      IF l_resource_id IS NULL THEN
        log('setup_inq_info: Did not find the user: '
                           || p_user_name || ' in asg_user table',g_err_level);
        x_return_status := FND_API.G_RET_STS_ERROR;
        return;
      END IF;

      INSERT INTO asg_users_inqinfo (device_user_name,
                                     resource_id,
                                     tranid,
                                     sync_date,
                                     processed,
                                     deferred,
                                     archive,
                                     last_update_date,
                                     last_updated_by,
                                     creation_date,
                                     created_by)
              VALUES (p_user_name,
                      l_resource_id,
                      p_tranid,
                      sysdate,
                      'N',
                      'N',
                      'Y',
                      SYSDATE,
                      1,
                      SYSDATE,
                      1);

      --  Get the list of pub-items for this tranid
      --  This is the list of all publication items uploaded for that tranid
      l_pubitems_1 := null;
      l_pubitems_2 := null;
      counter := 1;
      counter2:= 1;
      curr_pubitem_length := 0;
      l_select_store_sqlstring :=
        'SELECT store ' ||
        'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq ci '||
        'WHERE clid$$cs = :1 AND ' ||
        '      tranid$$ = :2 AND ' ||
	'      store in (select item_id from asg_pub_item) '||
        ' AND NOT EXISTS (SELECT 1 FROM asg_users_inqarchive  ' ||
        ' WHERE device_user_name = ci.clid$$cs AND TRANID =ci.tranid$$) '||
        ' ORDER BY store';

      l_cursor_id1 := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE (l_cursor_id1, l_select_store_sqlstring, DBMS_SQL.v7);
      DBMS_SQL.DEFINE_COLUMN (l_cursor_id1, 1, l_store, 30);
      DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':1', p_user_name);
      DBMS_SQL.BIND_VARIABLE(l_cursor_id1, ':2', p_tranid);
      l_cursor_ret1 := DBMS_SQL.EXECUTE (l_cursor_id1);

      counter := 1;
      WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id1) > 0 ) LOOP
        DBMS_SQL.COLUMN_VALUE (l_cursor_id1, 1, l_store);
        l_pubitems_tbl(counter) := l_store;
        counter := counter +1;
      END LOOP;

      DBMS_SQL.CLOSE_CURSOR(l_cursor_id1);
--12.1
      counter := 1;
      counter2:= 1;
      FOR curr_index2 IN 1..l_pubitems_tbl.count LOOP
        curr_pubitem := l_pubitems_tbl(curr_index2);
        curr_pubitem_length := curr_pubitem_length + length(curr_pubitem);
        IF curr_pubitem_length >= 8000 THEN
          EXIT;
        END IF;
        IF curr_pubitem_length < 4000 THEN
          IF counter >1 THEN
            l_pubitems_1 := l_pubitems_1 || ',';
            curr_pubitem_length := curr_pubitem_length + 1; -- length of ','
          END IF;
          l_pubitems_1 := l_pubitems_1 || curr_pubitem;
          counter := counter +1;
        ELSE
          IF counter2 >1 THEN
            l_pubitems_2 := l_pubitems_2 || ',';
            curr_pubitem_length := curr_pubitem_length + 1; -- length of ','
          END IF;
          l_pubitems_2 := l_pubitems_2 || curr_pubitem;
          counter2 := counter2 +1;
        END IF;
      END LOOP;

      -- Replace with call to table-handler for asg_users_inqarchive
      INSERT INTO asg_users_inqarchive (device_user_name,
                                        resource_id,
                                        tranid,
                                        sync_date,
                                        processed,
                                        deferred,
                                        pub_items1,
                                        pub_items2,
                                        last_update_date,
                                        last_updated_by,
                                        creation_date,
                                        created_by)
               VALUES (p_user_name,
                       l_resource_id,
                       p_tranid,
                       sysdate,
                       'N',
                       'N',
                       l_pubitems_1,
                       l_pubitems_2,
                       SYSDATE,
                       1,
                       SYSDATE,
                       1);
    END IF;

  END setup_inq_info;

  PROCEDURE process_user(p_user_name IN VARCHAR2,
                         p_tranid   IN NUMBER,
                         x_return_status OUT NOCOPY VARCHAR2)
            IS
  counter PLS_INTEGER;
  l_def_trans VARCHAR2(1);
  l_cursor_id             NUMBER;
  l_cursor_ret            NUMBER;
  l_return_status VARCHAR2(1);
  curr_pub VARCHAR2(30);
  curr_pubhandler VARCHAR2(30);
  l_pub_name VARCHAR2(30);
  l_wrapper_name VARCHAR2(30);
  l_callback_sqlstring VARCHAR2(512);
  l_select_inqcnt_sqlstring VARCHAR2(512);
  l_select_pub_sqlstring VARCHAR2(512);
  l_userpub_tbl     vc2_tbl_type;
  l_pubitems_tbl    vc2_tbl_type;
  l_pubhandler_tbl  vc2_tbl_type;
  l_inq_count       NUMBER;

  l_respid NUMBER;
  l_appid NUMBER;
  l_select_resp_sqlstring VARCHAR2(512);
  l_select_userid_sqlstring VARCHAR2(512);
  l_userid NUMBER;

  BEGIN

    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- check if there are any entries in C$inq for this <user, tranid>
    -- If there aren't any then this means there was some error and we
    -- will mark this transaction as not to be processed further
    -- Users can later rectify/purge through the def txn UI.
    l_select_inqcnt_sqlstring :=
      'SELECT count(*) ' ||
      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq ' ||
      'WHERE clid$$cs = :1 AND ' ||
      '      tranid$$ = :2';
    EXECUTE IMMEDIATE l_select_inqcnt_sqlstring
      INTO l_inq_count
      USING p_user_name, p_tranid;

    IF (l_inq_count = 0) THEN
      log('process_user: Unknown exception. No inq records found for user: '
        || p_user_name || ' for tranid: ' || p_tranid, FND_LOG.LEVEL_ERROR);
      log('process_user: Possible cause: Olite was reinstalled while ' ||
        'there were unprocessed inq transactions',g_stmt_level);
      UPDATE asg_users_inqinfo
      SET processed = 'U', deferred = 'Y'
      WHERE device_user_name = p_user_name AND
            tranid = p_tranid;
      return ;
    END IF;

    l_select_pub_sqlstring :=
      'SELECT template, wrapper_name ' ||
      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$all_subscriptions a, ' ||
      '       asg_pub b ' ||
      'WHERE a.clientid = :user_name AND ' ||
      '      a.template = b.name';

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id, l_select_pub_sqlstring, DBMS_SQL.v7);
    DBMS_SQL.BIND_VARIABLE (l_cursor_id, ':user_name', p_user_name );

    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 1, l_pub_name, 30);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 2, l_wrapper_name, 30);
    l_cursor_ret := DBMS_SQL.EXECUTE (l_cursor_id);

    counter :=1;
    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0 ) LOOP
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 1, l_pub_name);
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 2, l_wrapper_name);
      l_userpub_tbl(counter) := l_pub_name;
      l_pubhandler_tbl(counter) := l_wrapper_name;
      counter := counter +1;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

    -- User is subscribed to atleast one publication we know of
    IF counter >1 THEN
      FOR curr_index IN 1..l_userpub_tbl.count LOOP
        curr_pub := l_userpub_tbl(curr_index);
        curr_pubhandler := l_pubhandler_tbl(curr_index);
        log('process_user: current pub : ' || curr_pub ||
            ' current pub handler: ' || curr_pubhandler,g_stmt_level);
        l_pubitems_tbl := g_empty_vc2_tbl;
        get_all_pub_items(p_user_name, p_tranid, curr_pub,
                          l_pubitems_tbl, l_return_status);
        -- Check if there is any data for this publication
        IF(l_return_status = FND_API.G_RET_STS_SUCCESS) AND
          (l_pubitems_tbl.count >0) THEN

	      -- For current user and current publication get the
          -- responsibility ID  and application ID.
          SELECT USER_ID into l_userid
          FROM asg_user
          WHERE user_name = p_user_name;

            SELECT pr.responsibility_id, pr.app_id
            INTO   l_respid, l_appid
            FROM asg_user_pub_resps pr
            WHERE  pr.user_name = upper(p_user_name) AND
                   pr.pub_name = upper(curr_pub) AND
                   ROWNUM =1;

    fnd_global.apps_initialize(l_userid, l_respid, l_appid);
    log('process_user: apps_initialize() invoked for responsibility :'
        || l_respid || 'and application :'||l_appid,g_stmt_level);


-- apps initialize is called.it has to be reset after wrapper call
-- USING p_user_name, p_tranid;


          log('process_user: Calling handler package for ' ||
                               'user: ' || p_user_name,g_stmt_level);
          l_callback_sqlstring := 'begin ' ||
                            curr_pubhandler ||
                            '.apply_client_changes( :1, :2); ' ||' end;';
          BEGIN
            log('process_user: SQL Command: ' || l_callback_sqlstring
	        ,g_stmt_level);
            EXECUTE IMMEDIATE l_callback_sqlstring
            USING p_user_name, p_tranid;
          EXCEPTION
          WHEN OTHERS THEN
            log('process_user: Exception in wrapper call. ' ||
                'Check if valid wrapper exists ' ||
                SQLERRM,g_err_level);
            x_return_status := FND_API.G_RET_STS_SUCCESS;
	    --reset
	    fnd_global.apps_initialize(g_conc_userid, g_conc_respid, g_conc_appid);
            return;
          END;
        ELSE
          log('No pubitems from publication: ' || curr_pub || ' to process',
	      g_stmt_level);
        END IF;
	    --reset
	    fnd_global.apps_initialize(g_conc_userid, g_conc_respid, g_conc_appid);
      END LOOP;
    END IF;
  END process_user;

  -- Main procedure to process all upload transactions
  PROCEDURE process_upload(errbuf OUT NOCOPY VARCHAR2,
                           RETCODE OUT NOCOPY VARCHAR2,
                           p_apply_ha IN VARCHAR2)
            IS
  counter           PLS_INTEGER;
  l_begin_apply     VARCHAR2(1);
  l_return_status   VARCHAR2(1);
  curr_user         VARCHAR2(30);
  curr_tranid       NUMBER;
  next_tranid       NUMBER;
  l_tranid_tbl      num_tbl_type;
  l_users_tbl       vc2_tbl_type;
  l_row_count       number;
  l_prof_value      varchar2(5);
  L_BOOL_RET        BOOLEAN;
  l_err_msg         VARCHAR2(4000);
 BEGIN

    g_user_name := null;
    g_is_conc_program := 'Y';
    retcode := FND_API.G_RET_STS_SUCCESS;
    /*remember the conc program start time*/
    g_conc_start_time:=null;
    select sysdate into g_conc_start_time from dual;

    -- Get the conc program's user id, respid and appid
    g_conc_userid := fnd_global.user_id();
    IF g_conc_userid IS NULL or g_conc_userid = -1 THEN
      g_conc_userid := 5;
    END IF;
    g_conc_respid := fnd_global.resp_id();
    IF g_conc_respid IS NULL  or g_conc_respid = -1 THEN
      g_conc_respid := 20420;
    END IF;
    g_conc_appid  := fnd_global.resp_appl_id();
    IF g_conc_appid IS NULL or g_conc_appid = -1 THEN
     g_conc_appid := 1;
    END IF;

  IF P_APPLY_HA = 'Y' THEN
      LOG('Processing HA records',
          G_STMT_LEVEL);
      CSM_HA_PROCESS_PKG.PROCESS_HA(X_RETURN_STATUS => L_RETURN_STATUS,
                     X_ERROR_MESSAGE => L_ERR_MSG);
      ERRBUF := L_ERR_MSG;
      RETCODE := L_RETURN_STATUS;
  ELSE
    begin_apply(l_begin_apply, l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      log('Error in begin_apply',g_err_level);
      retcode := l_return_status;
      return;
    END IF;
    IF (l_begin_apply = FND_API.G_FALSE) THEN
      -- No users to process
      log('No users with uploaded data',g_stmt_level);
      return;
    END IF;
    IF (g_only_deferred_trans = FND_API.G_TRUE) THEN
      log('Only deferred uploaded data is available for processing',
          g_stmt_level);
    ELSE
      log('Both dirty and deferred uploaded data is available for processing',
          g_stmt_level);
    END IF;

    -- Get the list of all users
    get_all_clients(p_dirty => 'Y',
                    p_deferred => 'N',
                    x_clients_tbl => l_users_tbl,
                    x_return_status => l_return_status);
    log('process_upload: Num of users to process: ' || l_users_tbl.count,
        g_stmt_level);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      return;
    END IF;

    -- Fill in the client's subscriptions and handlers
    FOR curr_index in 1..l_users_tbl.count LOOP
      curr_user := l_users_tbl(curr_index);
      g_user_name := curr_user;
      log('process_upload: applying changes for user: '
                           || curr_user,g_stmt_level);
      get_first_tranid(p_user_name => curr_user,
                       x_tranid => curr_tranid,
                       x_return_status =>  l_return_status);
      g_current_tranid := curr_tranid;
      WHILE l_return_status = FND_API.G_RET_STS_SUCCESS LOOP
        log('process_upload: Processing tranid: ' || curr_tranid,g_stmt_level);
        process_user(p_user_name => curr_user,
                     p_tranid => curr_tranid,
                     x_return_status => l_return_status);
        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- Make the call to get the next tranid
          -- This means if upload processing for one transaction failed
          -- upload processing for the rest of the transactions is stopped.
          get_next_tranid(p_user_name => curr_user,
                          p_curr_tranid => curr_tranid,
                          x_tranid => next_tranid,
                          x_return_status => l_return_status);
          curr_tranid :=  next_tranid;
          g_current_tranid := curr_tranid;
        END IF;
      END LOOP;
      end_client_apply(p_user_name => curr_user,
                       x_return_status => l_return_status);
      log('process_upload: Return status from end_client_apply: ' ||
                           l_return_status,g_stmt_level);
      log('process_upload: Finished applying changes for user: ' ||
                           curr_user,g_stmt_level);
    END LOOP;
    g_user_name := null;
    end_apply(l_return_status);

    /*Check profile value*/
    select nvl(fnd_profile.value_specific('ASG_ENABLE_UPLOAD_EVENTS'),'N')
    into l_prof_value from dual;
    /*Check if any rows were deferred in the current run*/
    select count(*) into l_row_count
    from asg_deferred_traninfo
    where creation_date >= g_conc_start_time;
    if(l_prof_value = 'Y')
    then
      if(l_row_count > 0 )
      then
        log('Raising oracle.apps.asg.upload.datadeferred');
        l_bool_ret := raise_row_deferred(g_conc_start_time);
      else
        log('No data to raise oracle.apps.asg.upload.datadeferred');
      end if;
    else
      log('Not raising oracle.apps.asg.upload.datadeferred since  the profile '
          ||' ASG_ENABLE_UPLOAD_EVENTS is not set to ''Y''',g_stmt_level);
    END IF;
  END IF;--Check for HA
  G_CONC_START_TIME := NULL;
  G_IS_CONC_PROGRAM := NULL;

END process_upload;

  function is_conc_program_running
    return varchar2
  is
  begin
    if(g_is_conc_program = 'Y')
    then
      return 'Y';
    else
      return 'N';
    end if;
  end is_conc_program_running;
END asg_apply;

/
