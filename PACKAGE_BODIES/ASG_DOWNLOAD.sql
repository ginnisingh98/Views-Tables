--------------------------------------------------------
--  DDL for Package Body ASG_DOWNLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_DOWNLOAD" AS
/* $Header: asgdwldb.pls 120.5.12010000.5 2010/04/08 07:03:08 saradhak ship $*/

  /** CONSTANTS */
  CONS_SCHEMA      CONSTANT VARCHAR2(30) := ASG_BASE.G_OLITE_SCHEMA;
  OLITE_SEQUENCE   CONSTANT VARCHAR2(30) := 'C$ALL_SEQUENCE_PARTITIONS';
  LOG_LEVEL        CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;


  /** Global Variables */
  g_clientid                   VARCHAR2(30);
  g_last_tranid                NUMBER;
  g_log_table                  VARCHAR2(30);
  g_complete_ref_pub_items     VARCHAR2(32767) := NULL;
  g_pub_items_list             VARCHAR2(32767) := NULL;

  g_purge_log_enabled		VARCHAR2(1) := NULL;

  function get_pk(pi_name varchar2,p_qid number)
  return varchar2
  is
    l_pk varchar2(128);
    l_pk_ct number;
    l_ret boolean;
    l_pkstr varchar2(128);
    l_qry varchar2(512);
    l_res varchar2(128);
  begin
    l_pkstr := null;
    l_ret := getPrimaryKeys(pi_name,l_pk,l_pk_ct);
    --dbms_output.put_line('NUM OF PK: '||pk_ct);
    --dbms_output.put_line('PK: '||pk);
    for i in 1..l_pk_ct
    loop
      if l_pkstr is null
      then
       l_pkstr := 'ATTRIBUTE'||i||'';
      else
       l_pkstr := l_pkstr||'||'||''',''||'||'ATTRIBUTE'||i||'';
      end if;
    end loop;
    --dbms_output.put_line('str: '||l_pkstr);
    l_qry := 'select '||l_pkstr||' from asg_delete_queue where qid = :1';
    execute immediate l_qry into l_res using p_qid;
    --dbms_output.put_line('ret PK: '||l_res);
    return l_res;
  end get_pk;

  function raise_data_downloaded
  return boolean
  is
    l_qry varchar2(4000);
    l_ctx  dbms_xmlquery.ctxType;
    l_clob clob;
    l_ct number;
    l_seq number;
  begin
    log('Start raise_data_downloaded');
    l_qry := 'select client_id,pub_item,access_id,dml_type, '||
             ' transaction_id,null pk_val,sysdate synch_time '||
             ' from asg_system_dirty_queue '||
             ' where download_flag=''Y'' and client_id=asg_base.get_user_name'||
             ' and transaction_id = asg_base.get_current_tranid '||
             ' and dml_type <> 0 '||
             ' and pub_item in ( select item_id from asg_pub_item '||
             ' where nvl(enable_download_events,''N'') = ''Y''  )'||
             ' UNION ALL '||
             ' select client_id,pub_item,access_id,dml_type, '||
             ' transaction_id , asg_download.get_pk(pub_item,sdq.qid) pk_val, '||
             ' sysdate synch_time '||
             ' from asg_system_dirty_queue sdq,asg_delete_queue dq '||
             ' where download_flag=''Y'' and client_id=asg_base.get_user_name'||
             ' and transaction_id = asg_base.get_current_tranid '||
             ' and dml_type = 0 '||
             ' and pub_item in ( select item_id from asg_pub_item '||
             ' where nvl(enable_download_events,''N'') = ''Y''  ) '||
             ' and sdq.qid=dq.qid ';
    select count(*) into l_ct
    from asg_system_dirty_queue
    where download_flag='Y'
    and client_id = asg_base.get_user_name
    and transaction_id = asg_base.get_current_tranid
    and pub_item in
    ( select item_id from asg_pub_item
      where nvl(enable_download_events,'N') = 'Y');

    if(l_ct <> 0 )
    then
      log('Query :'||l_qry);
      l_ctx := dbms_xmlquery.newContext(l_qry);
      dbms_lob.createtemporary(l_clob,true,dbms_lob.session);
      l_clob := dbms_xmlquery.getXml(l_ctx);
      log('Finished building clob. Num of records :'||l_ct);
      log('Raising event oracle.apps.asg.download.datasynched');
      select asg_events_s.nextval into l_seq from dual;
      wf_event.raise(p_event_name=>'oracle.apps.asg.download.datasynched',
                     p_event_key=>l_seq,p_parameters=>null,
                     p_event_data=>l_clob,p_send_date=>null);
      log('Successfully raised event oracle.apps.asg.download.datasynched');
    else
      log('No data to raise the event oracle.apps.asg.download.datasynched');
    end if;
    log('End raise_data_downloaded');
    return true;
  exception
  when others then
    log('Error raising event oracle.apps.asg.download.datasynched');
    return false;
  end raise_data_downloaded;


  function raise_data_download_confirmed
  return boolean
  is
    l_seq number;
    l_qry varchar2(4000);
    l_ctx  dbms_xmlquery.ctxType;
    l_clob clob;
    l_ct number;
  begin
    log('Start raise_data_download_confirmed');
    l_qry := 'select client_id,pub_item,access_id,dml_type, '||
             ' transaction_id last_tran_id,asg_base.get_current_tranid '||
             ' curr_tran_id ,null pk_val,sysdate synch_time '||
             ' from asg_system_dirty_queue '||
             ' where download_flag=''Y'' and client_id=asg_base.get_user_name'||
             ' and transaction_id <= asg_base.get_last_tranid '||
             ' and dml_type <> 0 '||
             ' and pub_item in ( select item_id from asg_pub_item '||
             ' where nvl(enable_download_events,''N'') = ''Y''  )'||
             ' UNION ALL '||
             ' select client_id,pub_item,access_id,dml_type, '||
             ' transaction_id last_tran_id,asg_base.get_current_tranid '||
             ' curr_tran_id, asg_download.get_pk(pub_item,sdq.qid) pk_val, '||
             ' sysdate synch_time '||
             ' from asg_system_dirty_queue sdq,asg_delete_queue dq '||
             ' where download_flag=''Y'' and client_id=asg_base.get_user_name'||
             ' and transaction_id <= asg_base.get_last_tranid '||
             ' and dml_type = 0 '||
             ' and pub_item in ( select item_id from asg_pub_item '||
             ' where nvl(enable_download_events,''N'') = ''Y''  )'||
             ' and sdq.qid=dq.qid ';
    select count(*) into l_ct
    from asg_system_dirty_queue
    where download_flag='Y'
    and client_id = asg_base.get_user_name
    and transaction_id <= asg_base.get_last_tranid
    and pub_item in
    ( select item_id from asg_pub_item
      where nvl(enable_download_events,'N') = 'Y');

    if(l_ct <> 0)
    then
      log('Query :'||l_qry);
      l_ctx := dbms_xmlquery.newContext(l_qry);
      dbms_lob.createtemporary(l_clob,true,dbms_lob.session);
      l_clob := dbms_xmlquery.getXml(l_ctx);
      log('Finished building clob. Num of records :'||l_ct);
      log('Raising event oracle.apps.asg.download.datasynchconfirmed');
      select asg_events_s.nextval into l_seq from dual;
      wf_event.raise(p_event_name=>'oracle.apps.asg.download.datasynchconfirmed',
                     p_event_key=>l_seq,p_parameters=>null,
                     p_event_data=>l_clob,p_send_date=>null);
      log('Successfully raised event oracle.apps.asg.download.datasynchconfirmed');
    else
      log('No data to raise the event oracle.apps.asg.download.datasynchconfirmed');
    end if;
    log('End raise_data_download_confirmed');
    return true;
  exception
  when others then
    log('Error raising event oracle.apps.asg.download.datasynchconfirmed');
    return false;
  end raise_data_download_confirmed;


  /*
    Given a comma seperated char literals, this routine returns
    a char list
    The input can also have literals enclosed in single quotes.
  */
  FUNCTION get_listfrom_string (p_string1 IN varchar2)
           RETURN pk_list
  IS
   l_temp1 NUMBER;
   l_temp2 NUMBER;
   l_temp3 NUMBER;
   str VARCHAR2(30);
   len NUMBER;
   ind number;
   l_list  pk_list;
   l_string varchar2(32767);
  BEGIN
    l_temp1:=1;
    l_temp2:=1;
    l_temp3:=1;
    ind := 1;
    l_string := replace(p_string1,'''','');
    len:=nvl(length(l_string),-1);
    IF (len = -1) THEN
      return l_list;
    END IF;
    LOOP
      l_temp2:=instr(l_string,',',1,l_temp1);
      IF( l_temp2=0 ) THEN
        l_list(ind):=rtrim(ltrim(substr(l_string,l_temp3,len)));
        --dbms_output.put_line(l_list(ind));
        ind := ind+1;
        EXIT;
      END IF;
      l_list(ind):=rtrim(ltrim(substr(l_string,l_temp3,l_temp2-l_temp3)));
      --dbms_output.put_line(l_list(ind));
      ind:=ind+1;
      l_temp3:=l_temp2+1;
      l_temp1:=l_temp1+1;
    END LOOP;
    RETURN l_list;
  END get_listfrom_string;

  FUNCTION get_predicate_clause(p_predicate_list IN VARCHAR2)
           RETURN VARCHAR2 IS
  l_predicate_clause VARCHAR2(512) := NULL;
  l_predicate_list   VARCHAR2(150);
  BEGIN
    /* We support three predicate clauses
       -- resource_id, user_id, language */
    l_predicate_list := upper(p_predicate_list);
    IF (instr(l_predicate_list, 'RESOURCE_ID') <> 0) THEN
      l_predicate_clause := ' resource_id = asg_base.get_resource_id() ';
    END IF;
    IF (instr(l_predicate_list, 'USER_ID') <> 0) THEN
      IF(l_predicate_clause IS NOT NULL) THEN
        l_predicate_clause := l_predicate_clause || ' AND ' ||
                              ' user_id = asg_base.get_user_id() ';
      ELSE
        l_predicate_clause := ' user_id = asg_base.get_user_id() ';
      END IF;
    END IF;
    IF (instr(l_predicate_list, 'LANGUAGE') <> 0) THEN
      IF(l_predicate_clause IS NOT NULL) THEN
        l_predicate_clause := l_predicate_clause || ' AND ' ||
                              ' language = asg_base.get_language() ';
      ELSE
        l_predicate_clause := ' language = asg_base.get_language() ';
      END IF;
    END IF;

    return l_predicate_clause;
  END get_predicate_clause;

  PROCEDURE reset_all_globals
            IS
  BEGIN

    g_clientid := NULL;
    g_last_tranid := NULL;
    g_log_table := NULL;
    g_complete_ref_pub_items  := NULL;
    g_pub_items_list  := NULL;

  END reset_all_globals;


  /** Function to tell if it's a 1st Sync */
  FUNCTION isFirstSync RETURN BOOLEAN IS
    l_query VARCHAR2 (300);
    l_cnt   NUMBER := 0;
  BEGIN
    l_query := 'SELECT COUNT(*) FROM '||CONS_SCHEMA||'.'||'c$pub_list_q '
               ||' WHERE comp_ref <> ''Y''';
    EXECUTE IMMEDIATE l_query INTO l_cnt;

    IF (l_cnt = 0) THEN
       log('First Sync');
	  RETURN TRUE;
    ELSE
       log('Subsequent Sync');
	  RETURN FALSE;
    END IF;
  END isFirstSync;


  /** Function to Capture the PK of a Deleted Record
   *  in asg_delete_queue */
  FUNCTION storeDeletedPK ( p_pub_item     IN VARCHAR2,
                            p_accessList   IN access_list,
                            p_qidList      IN qid_list
                           ) RETURN BOOLEAN IS

    l_pk_list       VARCHAR2(500);
    l_pos           NUMBER := 1;
    l_pk_cnt        NUMBER := 0;
    l_att_col_list  VARCHAR2(500);
    l_rc            BOOLEAN;
    l_dml           VARCHAR2(2000);
    l_base_owner    asg_pub_item.base_owner%TYPE;
    l_base_object   asg_pub_item.base_object_name%TYPE;
    l_access_owner  asg_pub_item.access_owner%TYPE;
    l_access_name   asg_pub_item.access_name%TYPE;
    l_accessList    dbms_sql.Number_table;
    l_qidList       dbms_sql.Number_table;
    l_cur_id        NUMBER;
    l_cur_rc        NUMBER;

  BEGIN

    log ('Function storeDeletedPK');

    -- Get PK Columns
    l_rc := getPrimaryKeys (p_pub_item, l_pk_list, l_pk_cnt);

    -- Attribute Col List
    FOR i IN 1..l_pk_cnt
    LOOP
      l_att_col_list := l_att_col_list || ', attribute'||i;
    END LOOP;

    -- Copy Values to DBMS_SQL Table Structure
    FOR i IN 1..p_accessList.COUNT
    LOOP
      l_accessList (i) := p_accessList(i);
      l_qidList (i)    := p_qidList(i);
    END LOOP;

    -- Get the Base Table to Select From
    l_dml := 'SELECT base_owner, base_object_name, access_owner, access_name '||
             ' FROM asg_pub_item WHERE name=:1';
    EXECUTE IMMEDIATE l_dml INTO l_base_owner, l_base_object, l_access_owner,
                                 l_access_name USING p_pub_item;

    l_cur_id := DBMS_SQL.OPEN_CURSOR;

    IF ( (l_access_owner IS NULL) AND (l_access_name IS NULL) ) THEN
      DBMS_SQL.PARSE (l_cur_id, 'INSERT INTO asg_delete_queue '
                                || '(qid, creation_date, created_by, '
                                || 'last_update_date, last_updated_by '
                                || l_att_col_list
                                || ') SELECT :1, sysdate, '
                                || '1, sysdate, 1, '||l_pk_list
                                || ' FROM '||l_base_owner||'.'||l_base_object
                                || ' WHERE access_id = :2', DBMS_SQL.v7);
    ELSE
      DBMS_SQL.PARSE (l_cur_id, 'INSERT INTO asg_delete_queue '
                                || ' (qid, creation_date, '
                                || 'created_by, last_update_date, '
                                || 'last_updated_by '||l_att_col_list
                                || ') SELECT :1, sysdate, '
                                || '1, sysdate, 1, '||l_pk_list
                                || ' FROM '||l_access_owner||'.'||l_access_name
                                || ' WHERE access_id = :2', DBMS_SQL.v7);
    END IF;

    DBMS_SQL.BIND_ARRAY (l_cur_id, ':1', l_qidList, 1, l_qidList.COUNT);
    DBMS_SQL.BIND_ARRAY (l_cur_id, ':2', l_accessList, 1, l_accessList.COUNT);

    l_cur_rc := DBMS_SQL.EXECUTE ( l_cur_id );
    DBMS_SQL.CLOSE_CURSOR (l_cur_id);

    log ('END Function storeDeletedPK');

    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE;
  END storeDeletedPK;


  /** Function to Capture the PK of a Deleted Record
   *  in asg_delete_queue given the PK List */
  FUNCTION storeDeletedPK ( p_pub_item     IN VARCHAR2,
                            p_qid          IN NUMBER,
                            p_pkvalList    IN pk_list
                           ) RETURN BOOLEAN IS

    l_att_col_list  VARCHAR2(500);
    l_pk_val_list   VARCHAR2(4000);
    l_rc            BOOLEAN;
    l_dml           VARCHAR2(4000);

  BEGIN

    log ('Function storeDeletedPK - with PK Values Given');

    IF (p_pkvalList.COUNT > 0 ) THEN

      log ('PK Values Given');
      FOR i IN 1..p_pkvalList.COUNT
      LOOP
        l_att_col_list := l_att_col_list || ', attribute'||i;
        l_pk_val_list  := l_pk_val_list || ',''' || p_pkvalList(i) || '''';
      END LOOP;

      l_dml := 'INSERT INTO asg_delete_queue (qid, creation_date, '
               || 'created_by, last_update_date, last_updated_by '
               || l_att_col_list || ') VALUES '
               || ' ( ' || p_qid || ', sysdate, 1, sysdate, 1 '||l_pk_val_list
               || ')';

      EXECUTE IMMEDIATE l_dml;

    END IF;
    log ('END Function storeDeletedPK - with PK Values Given');

    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE;
  END storeDeletedPK;


  /** Function to store the PK of a Deleted Record
   *  in asg_delete_queue - For Reject Record */
  FUNCTION storeDeletedPK ( p_pub_item     IN VARCHAR2,
                            p_client_name  IN VARCHAR2,
                            p_tran_id      IN NUMBER,
                            p_seq_no       IN NUMBER,
                            p_qid          IN NUMBER
                           ) RETURN BOOLEAN IS

    l_pk_list       VARCHAR2(500);
    l_pos           NUMBER := 1;
    l_pk_cnt        NUMBER := 0;
    l_att_col_list  VARCHAR2(500);
    l_rc            BOOLEAN;
    l_dml           VARCHAR2(4000);
    l_inq_owner     asg_pub_item.inq_owner%TYPE;
    l_inq_name      asg_pub_item.inq_name%TYPE;

  BEGIN

    log ('Function storeDeletedPK - Reject Record');

    -- Get PK Columns
    l_rc := getPrimaryKeys (p_pub_item, l_pk_list, l_pk_cnt);

    -- Attribute Col List
    FOR i IN 1..l_pk_cnt
    LOOP
      l_att_col_list := l_att_col_list || ', attribute'||i;
    END LOOP;

    l_dml := 'SELECT inq_owner, inq_name FROM asg_pub_item '||
             ' WHERE name=:1';
    EXECUTE IMMEDIATE l_dml INTO l_inq_owner, l_inq_name USING p_pub_item;

    IF (l_inq_owner IS NULL) THEN
      l_inq_owner := CONS_SCHEMA;
    END IF;

    IF (l_inq_name IS NULL) THEN
      l_inq_name := 'CFM$'||p_pub_item;
    END IF;
    log ('Inqueue is '||l_inq_owner||'.'||l_inq_name);

    l_dml := 'INSERT INTO asg_delete_queue (qid, creation_date, '
            || 'created_by, last_update_date, last_updated_by '||l_att_col_list
            || ') SELECT :1, sysdate, '
            || '1, sysdate, 1, '||l_pk_list
            || ' FROM '||l_inq_owner||'.'||l_inq_name
            || ' WHERE clid$$cs = :2 AND TRANID$$ = :3 AND seqno$$ = :4';
    EXECUTE IMMEDIATE l_dml USING p_qid, p_client_name, p_tran_id, p_seq_no;

    log ('END Function storeDeletedPK - Reject Record');

    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE;
  END storeDeletedPK;


  /** Mark Dirty a Publication Item
   *   Support for Reject Record */
  --ver 1
  FUNCTION markDirty ( p_pub_item     IN VARCHAR2,
                       p_user_name    IN VARCHAR2,
                       p_tran_id      IN NUMBER,
                       p_seq_no       IN NUMBER ) RETURN BOOLEAN IS

    l_mobile_user   VARCHAR2(30);
    l_dml           VARCHAR2(2000);
    l_rc            BOOLEAN;
    l_qid           NUMBER;
  BEGIN

    log ('Function markDirty - Reject Record ');

    -- Mark Publication Item Dirty
    IF (insert_sdq(p_pub_item,p_user_name) AND
        is_exists(p_user_name,p_pub_item,p_seq_no,'D'))
    THEN
      INSERT INTO asg_system_dirty_queue (
        qid, creation_date, created_by, last_update_date, last_updated_by,
        pub_item, access_id, client_id, transaction_id
        , dml_type, download_flag,ha_parent_payload_id)
      VALUES (
        asg_system_dirty_queue_s.nextval, SYSDATE, 1, SYSDATE, 1,
        p_pub_item, p_seq_no, p_user_name, NULL , 0, NULL,
		DECODE(CSM_HA_SERVICE_PUB.GET_HA_STATUS,'HA_RECORD',CSM_HA_EVENT_PKG.G_CURRENT_PAYLOAD_ID))
      RETURNING qid INTO l_qid;

      l_rc := storeDeletedPK(p_pub_item, p_user_name, p_tran_id,
                           p_seq_no, l_qid);
    END if;
    log ('END Function markDirty');

    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE;
  END markDirty;


  /** Mark dirty a Publication Item
   *   Given a access_id, user_id and DML Type (internal)*/
  --ver 2 internal
  FUNCTION mark_dirty_internal ( p_pub_item     IN VARCHAR2,
                                 p_accessid     IN NUMBER,
                                 p_username     IN VARCHAR2,
                                 p_dml          IN CHAR,
                                 p_timestamp    IN DATE ) RETURN BOOLEAN IS
    l_mobile_user   VARCHAR2(30);
    l_dml           VARCHAR2(2000);
    l_rc            BOOLEAN;
    l_accesslist    access_list;
    l_qidlist       qid_list;
    l_qid           NUMBER;
  BEGIN
    log ('Function mark_dirty_internal - Reject Record ');
    --l_mobile_user := asg_base.get_user_name;   ---modify this logic
    --select user_name into l_mobile_user from asg_user where user_id=p_userid;
    -- Mark Publication Item Dirty
    IF (insert_sdq(p_pub_item,p_username) AND
        is_exists(p_username,p_pub_item,p_accessid,p_dml))
    THEN
      INSERT INTO asg_system_dirty_queue (
        qid, creation_date, created_by, last_update_date, last_updated_by,
        pub_item, access_id, client_id, transaction_id
        , dml_type, download_flag,ha_parent_payload_id)
      VALUES (
        asg_system_dirty_queue_s.nextval, SYSDATE, 1, SYSDATE, 1,
        p_pub_item, p_accessid, p_username, NULL ,
        DECODE(p_dml,'D',0,'I',1,'U',2), NULL,
		DECODE(CSM_HA_SERVICE_PUB.GET_HA_STATUS,'HA_RECORD',CSM_HA_EVENT_PKG.G_CURRENT_PAYLOAD_ID))
      RETURNING qid INTO l_qid;

      IF (p_dml = 'D') THEN
        l_accesslist(1) := p_accessid;
        l_qidlist(1) := l_qid;
        l_rc := storeDeletedPK(p_pub_item, l_accesslist, l_qidlist);
      END IF;
    END IF;
    log ('END Function mark_dirty_internal');

    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE;
  END mark_dirty_internal;


  /** Mark Dirty a Publication Item
   *   Given a access_id, resource_id and DML Type */
  --ver 2
  FUNCTION markDirty ( p_pub_item     IN VARCHAR2,
                       p_accessid     IN NUMBER,
                       p_resourceid   IN NUMBER,
                       p_dml          IN CHAR,
                       p_timestamp    IN DATE ) RETURN BOOLEAN IS


    l_mobile_user   VARCHAR2(30);
    l_retval        BOOLEAN;
  BEGIN
    log ('Function markDirty - single row');
    l_mobile_user := asg_base.get_user_name(p_resourceid);
    if(l_mobile_user is null) then
      log('Invalid mobile user with resource ID : '||p_resourceid||' ');
      return FAIL;
    end if;
    l_retval:=mark_dirty_internal(p_pub_item,p_accessid,l_mobile_user,p_dml,
                                  p_timestamp);
    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
	  RAISE;
  END markDirty;


  /** Mark Dirty a Publication Item
   *   Given a access_id, user_id and DML Type (internal)*/
  --ver 3 internal
  FUNCTION mark_dirty_internal ( p_pub_item     IN VARCHAR2,
                                 p_accessid     IN NUMBER,
                                 p_username     IN VARCHAR2,
                                 p_dml          IN CHAR,
                                 p_timestamp    IN DATE,
                                 p_pkvalues     IN pk_list ) RETURN BOOLEAN IS
    l_dml           VARCHAR2(2000);
    l_rc            BOOLEAN;
    l_accesslist    access_list;
    l_qidlist       qid_list;
    l_qid           NUMBER;
  BEGIN
    -- Mark Publication Item Dirty
    IF (insert_sdq(p_pub_item,p_username) AND
        is_exists(p_username,p_pub_item,p_accessid,p_dml))
    THEN
      INSERT INTO asg_system_dirty_queue (
        qid, creation_date, created_by, last_update_date, last_updated_by,
        pub_item, access_id, client_id, transaction_id
        , dml_type, download_flag,ha_parent_payload_id)
      VALUES (
        asg_system_dirty_queue_s.nextval, SYSDATE, 1, SYSDATE, 1,
        p_pub_item, p_accessid, p_username, NULL ,
        DECODE(p_dml,'D',0,'I',1,'U',2), NULL,
		DECODE(CSM_HA_SERVICE_PUB.GET_HA_STATUS,'HA_RECORD',CSM_HA_EVENT_PKG.G_CURRENT_PAYLOAD_ID))
      RETURNING qid INTO l_qid;
      IF (p_dml = 'D') THEN
        /* l_accesslist(1) := p_accessid;
        l_qidlist(1) := l_qid; */
        l_rc := storeDeletedPK(p_pub_item, l_qid, p_pkvalues);
      END IF;
    END IF;
    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE;
  END mark_dirty_internal;


  /** Mark Dirty a Publication Item
   *   Given a access_id, resource_id and DML Type */
  --ver 3
  FUNCTION markDirty ( p_pub_item     IN VARCHAR2,
                       p_accessid     IN NUMBER,
                       p_resourceid   IN NUMBER,
                       p_dml          IN CHAR,
                       p_timestamp    IN DATE,
                       p_pkvalues     IN pk_list ) RETURN BOOLEAN IS

    l_mobile_user   VARCHAR2(30);
    l_retval BOOLEAN;
  BEGIN
    log ('Function markDirty - single row with PK Values given');
    l_mobile_user := asg_base.get_user_name(p_resourceid);
    if(l_mobile_user is null) then
      log('Invalid mobile user with resource ID : '||p_resourceid||' ');
      return FAIL;
    end if;
    l_retval:=mark_dirty_internal(p_pub_item, p_accessid, l_mobile_user, p_dml,
                                  p_timestamp,p_pkvalues);
    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE;
  END markDirty;


  /** Mark Dirty for a Publication Item
   *   Given a List of access_id, resource_id and dml_types */
  --ver 4 internal
  FUNCTION mark_dirty_internal ( p_pub_item      IN VARCHAR2,
                                 p_accessList    IN access_list,
                                 p_username_list IN username_list,
                                 p_dmlList       IN dml_list,
                                 p_timestamp     IN DATE) RETURN BOOLEAN IS

    l_qid_comp_list     qid_list;
    l_qid_pruned_list   qid_list;
    l_accesslist        access_list;
    l_rc                BOOLEAN;
    l_tab_ind           NUMBER := 0;

    l_tmp_access_list	access_list;
    l_tmp_username_list	username_list;
    l_tmp_dml_list	dml_list;
    l_ctr		NUMBER;
  BEGIN
    IF ( (p_accessList.count <> p_username_list.count ) OR
         (p_accessList.count <> p_dmlList.count)  ) THEN
      RAISE PARAMETER_COUNT_MISMATCH;
    END IF;
    l_ctr := 1;

    --compares each element in the list with asg_purge_sdq ,asg_complete_Refresh
    -- and SDQ and constructs a new list.. which is used for further processing.
    FOR i IN p_accessList.FIRST..p_accessList.LAST
    LOOP
      IF (insert_sdq(p_pub_item,p_username_list(i))
          AND is_exists(p_username_list(i),p_pub_item,
	                p_accessList(i),p_dmlList(i)))
      THEN
        l_tmp_access_list(l_ctr) := p_accessList(i);
	l_tmp_username_list(l_ctr) := p_username_list(i);
	l_tmp_dml_list(l_ctr) := p_dmlList(i);
	l_ctr := l_ctr + 1;
      END IF ;
    END LOOP;

    log ('Function markdirty internal - Accessid-Resourceid-DML 1-1-1');
    -- Mark Records Dirty for a Mobile User
    IF( nvl(l_tmp_access_list.COUNT,0) <> 0 )
    THEN
      FORALL i IN l_tmp_access_list.FIRST..l_tmp_access_list.LAST
        INSERT INTO asg_system_dirty_queue (
         qid, creation_date, created_by, last_update_date, last_updated_by,
         pub_item, access_id, client_id, transaction_id
         , dml_type, download_flag,ha_parent_payload_id)
        VALUES (
         asg_system_dirty_queue_s.nextval, SYSDATE, 1, SYSDATE, 1,
         p_pub_item, l_tmp_access_list(i), l_tmp_username_list(i),
         NULL , DECODE(l_tmp_dml_list(i),'D',0,'I',1,'U',2), NULL,
		DECODE(CSM_HA_SERVICE_PUB.GET_HA_STATUS,'HA_RECORD',CSM_HA_EVENT_PKG.G_CURRENT_PAYLOAD_ID))
        RETURNING qid BULK COLLECT INTO l_qid_comp_list;

    -- Get the access_id and qid's for records with Delete operation
    FOR i IN 1..l_qid_comp_list.COUNT LOOP
      IF (l_tmp_dml_list(i) = 'D') THEN
        l_tab_ind := l_tab_ind + 1;
        l_qid_pruned_list(l_tab_ind) := l_qid_comp_list(i);
        l_accesslist(l_tab_ind) := l_tmp_access_list(i);
      END IF;
    END LOOP;

    IF (NOT (l_qid_pruned_list IS NULL) ) AND
       (l_tab_ind > 0) THEN
      l_rc := storeDeletedPK(p_pub_item, l_accesslist, l_qid_pruned_list);
    END IF;
   END IF;

    log ('END Function markDirty - Accessid-Resourceid-DML 1-1-1');
    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE;
  END mark_dirty_internal;


  /** Mark Dirty for a Publication Item
   *   Given a List of access_id, resource_id and dml_types */
 --ver 4
  FUNCTION markDirty ( p_pub_item     IN VARCHAR2,
                       p_accessList   IN access_list,
                       p_resourceList IN user_list,
                       p_dmlList      IN dml_list,
                       p_timestamp    IN DATE) RETURN BOOLEAN IS

  l_username_list username_list;
  l_retval BOOLEAN;
  l_temp_ptr number;
  l_invalid_reslist varchar2(3900);
  l_ctr number;
  l_flag number;
  l_user_name varchar2(30);
  l_accessList access_list;
  l_dmlList dml_list;
  l_sri_count NUMBER;
  BEGIN
    l_ctr := 1;
    l_flag := 0;
    IF ( (p_accessList.count <> p_resourceList.count ) OR
         (p_accessList.count <> p_dmlList.count)  ) THEN
      RAISE PARAMETER_COUNT_MISMATCH;
    END IF;

    FOR i in 1..p_resourceList.count
    LOOP
      l_user_name := asg_base.get_user_name(p_resourceList(i));
      if(l_user_name is null) then
        if(l_flag = 0 ) then
          l_invalid_reslist := ''''||p_resourceList(i)||'''';
          l_flag := 1;
        else
          l_invalid_reslist := l_invalid_reslist||','''||p_resourceList(i)||'''';
        end if;
      else
        l_username_list(l_ctr) := l_user_name;
        l_accessList(l_ctr) := p_accessList(i);
        l_dmlList(l_ctr) := p_dmlList(i);
        l_ctr := l_ctr + 1;
      end if;
      l_user_name := null;
    END LOOP;
    l_retval:=mark_dirty_internal(p_pub_item, l_accessList, l_username_list,
                                  l_dmlList,p_timestamp);
    if(l_flag = 1 ) then
      log('Invalid mobile user(s) with resource ID(s) : '
            ||l_invalid_reslist);
      return FAIL;
    end if;
    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE;
  END markDirty;


  /** Mark Dirty for a Publication Item
   *   Given a List of access_id and resource_id with a Single DML Type */
   --ver 5 internal
  FUNCTION mark_dirty_internal ( p_pub_item      IN VARCHAR2,
                                 p_accessList    IN access_list,
                                 p_username_list IN username_list,
                                 p_dml_type      IN CHAR,
                                 p_timestamp     IN DATE) RETURN BOOLEAN IS

    l_qid_list		qid_list;
    l_rc		BOOLEAN;

    l_tmp_access_list	access_list;
    l_tmp_username_list	username_list;
    l_tmp_dml_list	dml_list;
    l_ctr		NUMBER;
  BEGIN
    log ('Function mark dirty internal - Accessid-Resourceid - ' ||
         '1-1 - Single DML');
    IF  (p_accessList.count <> p_username_list.count ) THEN
      RAISE PARAMETER_COUNT_MISMATCH;
    END IF;

    l_ctr := 1;
    FOR i IN p_accessList.FIRST..p_accessList.LAST
    LOOP
      IF ( insert_sdq(p_pub_item,p_username_list(i)) AND
           is_exists(p_username_list(i),p_pub_item,p_accessList(i),p_dml_type))
      THEN
        l_tmp_access_list(l_ctr) := p_accessList(i);
	l_tmp_username_list(l_ctr) := p_username_list(i);
	l_ctr := l_ctr + 1;
      END IF ;
    END LOOP;

    -- Mark Records Dirty for a Mobile User
    IF( nvl(l_tmp_access_list.COUNT,0) <> 0 )
    THEN
      FORALL i IN l_tmp_access_list.FIRST..l_tmp_access_list.LAST
        INSERT INTO asg_system_dirty_queue (
         qid, creation_date, created_by, last_update_date, last_updated_by,
         pub_item, access_id, client_id, transaction_id
         , dml_type, download_flag,ha_parent_payload_id)
        VALUES (
         asg_system_dirty_queue_s.nextval, SYSDATE, 1, SYSDATE, 1,
         p_pub_item, l_tmp_access_list(i), l_tmp_username_list(i),
         NULL , DECODE(p_dml_type,'D',0,'I',1,'U',2), NULL,
		DECODE(CSM_HA_SERVICE_PUB.GET_HA_STATUS,'HA_RECORD',CSM_HA_EVENT_PKG.G_CURRENT_PAYLOAD_ID))
        RETURNING qid BULK COLLECT INTO l_qid_list;
      IF (p_dml_type = 'D') THEN
        l_rc := storeDeletedPK(p_pub_item, l_tmp_access_list, l_qid_list);
      END IF;
    END IF;

    log ('END Function mark dirty internal- Accessid-Resourceid - ' ||
         '1-1 - Single DML');

    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE ;
   END mark_dirty_internal;


  /** Mark Dirty for a Publication Item
   *   Given a List of access_id and resource_id with a Single DML Type */
   --ver 5
  FUNCTION markDirty ( p_pub_item     IN VARCHAR2,
                       p_accessList   IN access_list,
                       p_resourceList IN user_list,
                       p_dml_type     IN CHAR,
                       p_timestamp    IN DATE) RETURN BOOLEAN IS

    l_username_list username_list;
    l_retval BOOLEAN;
    l_invalid_reslist varchar2(3900);
    l_ctr number;
    l_flag number;
    l_user_name varchar2(30);
    l_accessList access_list;
  BEGIN
    log ('Function markDirty - Accessid-Resourceid - 1-1 - Single DML');
    l_ctr := 1;
    l_flag := 0;
    IF  (p_accessList.count <> p_resourceList.count ) THEN
      RAISE PARAMETER_COUNT_MISMATCH;
    END IF;
    FOR i in 1..p_resourceList.count
    LOOP
      l_user_name := asg_base.get_user_name(p_resourceList(i));
      if(l_user_name is null) then
        if(l_flag = 0 ) then
          l_invalid_reslist := ''''||p_resourceList(i)||'''';
          l_flag := 1;
        else
          l_invalid_reslist := l_invalid_reslist||','''||p_resourceList(i)||'''';
        end if;
      else
        l_username_list(l_ctr) := l_user_name;
        l_accessList(l_ctr) := p_accessList(i);
        l_ctr := l_ctr + 1;
      end if;
      l_user_name := null;
    END LOOP;
    l_retval:=mark_dirty_internal(p_pub_item, l_accessList, l_username_list,
                                  p_dml_type,p_timestamp);
    if(l_flag = 1 ) then
      log('Invalid mobile user(s) with resource ID(s) : '||l_invalid_reslist);
      return FAIL;
    end if;
    log ('END Function markDirty- Accessid-Resourceid - 1-1 - Single DML');
    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE ;
  END markDirty;


  /** Mark Dirty for a Publication Item
   *   Given a List of access_id and resource_id with a Single DML Type */
   --ver 6 internal
  FUNCTION mark_dirty_internal ( p_pub_item      IN VARCHAR2,
                                 p_accessList    IN access_list,
                                 p_username_list IN username_list,
                                 p_dml_type      IN CHAR,
                                 p_timestamp     IN DATE,
                                 p_bulk_flag     IN BOOLEAN) RETURN BOOLEAN IS

    l_mobile_user VARCHAR2(30);
    l_qid_list    qid_list;
    l_rc          BOOLEAN;

    l_tmp_access_list	access_list;
    l_empty_access_list	access_list;
    l_empty_qid_list	qid_list;
    l_ctr		NUMBER;
  BEGIN
    IF (p_bulk_flag = true)
    THEN
      log ('Function mark dirty internal - Accessid-Resourceid - Many-Many ');
      FOR i IN 1..p_username_list.COUNT
      LOOP
--        l_mobile_user := asg_base.get_user_name(p_resourceList(i));
        l_mobile_user:=p_username_list(i);
	l_ctr := 1;
	l_tmp_access_list := l_empty_access_list;
	l_qid_list := l_empty_qid_list;

	--prune the access ID list for each user and prepare a temp list
	FOR k IN p_accessList.FIRST..p_accessList.LAST
 	LOOP
	  IF( insert_sdq(p_pub_item,l_mobile_user) AND
	      is_exists(l_mobile_user,p_pub_item,p_accessList(k),p_dml_type))
	  THEN
	    l_tmp_access_list(l_ctr) := p_accessList(k);
	    l_ctr := l_ctr + 1;
	  END IF;
	END LOOP;

        --FORALL j IN l_tmp_access_list.FIRST..l_tmp_access_list.LAST
    IF( nvl(l_tmp_access_list.COUNT,0) <> 0 )
    THEN
	FORALL j IN 1..l_tmp_access_list.COUNT
          -- Mark Publication Item Dirty
          INSERT INTO asg_system_dirty_queue (
            qid, creation_date, created_by, last_update_date, last_updated_by,
            pub_item, access_id, client_id, transaction_id
            , dml_type, download_flag,ha_parent_payload_id)
          VALUES (
            asg_system_dirty_queue_s.nextval, SYSDATE, 1, SYSDATE, 1,
            p_pub_item, l_tmp_access_list(j), l_mobile_user, NULL ,
            DECODE(p_dml_type,'D',0,'I',1,'U',2), NULL,
		    DECODE(CSM_HA_SERVICE_PUB.GET_HA_STATUS,'HA_RECORD',CSM_HA_EVENT_PKG.G_CURRENT_PAYLOAD_ID))
          RETURNING qid BULK COLLECT INTO l_qid_list;
        IF (p_dml_type = 'D') THEN
          l_rc := storeDeletedPK(p_pub_item, l_tmp_access_list, l_qid_list);
        END IF;
    END IF;
   END LOOP;

    ELSE
--      l_rc := markDirty (p_pub_item, p_accessList, p_resourceList,
--               p_dml_type, p_timestamp);
        l_rc := mark_dirty_internal(p_pub_item, p_accessList, p_username_list,
                 p_dml_type, p_timestamp);

    END IF;

    log ('END Function mark dirty internal - Accessid-Resourceid - Many-Many ');

    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE ;
  END mark_dirty_internal;

  /* Mark Dirty for a Publication Item
   *   Given a List of access_id and resource_id with a Single DML Type */
   --ver 6
  FUNCTION markDirty ( p_pub_item     IN VARCHAR2,
                       p_accessList   IN access_list,
                       p_resourceList IN user_list,
                       p_dml_type     IN CHAR,
                       p_timestamp    IN DATE,
                       p_bulk_flag    IN BOOLEAN) RETURN BOOLEAN IS

    l_username_list username_list;
    l_retval BOOLEAN;
    l_invalid_reslist varchar2(3900);
    l_ctr number;
    l_flag number;
    l_user_name varchar2(30);
   -- l_accessList access_list;
  BEGIN
    log ('Function markDirty - Accessid-Resourceid - Many-Many ');
    l_ctr := 1;
    l_flag := 0;
    FOR i in 1..p_resourceList.count
    LOOP
      l_user_name := asg_base.get_user_name(p_resourceList(i));
      if(l_user_name is null) then
        if(l_flag = 0 ) then
          l_invalid_reslist := ''''||p_resourceList(i)||'''';
          l_flag := 1;
        else
          l_invalid_reslist := l_invalid_reslist||','''||p_resourceList(i)||'''';
        end if;
      else
        l_username_list(l_ctr) := l_user_name;
    --    l_accessList(l_ctr) := p_accessList(i);
        l_ctr := l_ctr + 1;
      end if;
      l_user_name := null;
    END LOOP;
    l_retval:=mark_dirty_internal(p_pub_item,p_accessList,l_username_list,
                                  p_dml_type,p_timestamp,p_bulk_flag);
    if(l_flag = 1 ) then
      log('Invalid mobile user(s) with resource ID(s) : '||l_invalid_reslist);
      return fail;
    end if;
    log ('END Function markDirty - Accessid-Resourceid - Many-Many ');
    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE ;
  END markDirty;


  /* Function to get Primary Key columns and their Data Types
   *  for a Publication Item */

   FUNCTION getPrimaryKeys ( p_pub_item IN VARCHAR2,
                            x_pk_list  OUT NOCOPY VARCHAR2,
                            x_pk_cnt   OUT NOCOPY NUMBER) RETURN BOOLEAN IS

   l_pk_list          VARCHAR2(4000);
   l_base_owner       VARCHAR2(30);
   l_base_object_name VARCHAR2(30);
   l_dml              VARCHAR2(4000);
   l_col_name         VARCHAR2(30);
   l_col_data_type    VARCHAR2(106);
   l_rc               NUMBER;
   l_pos_1            NUMBER := 0;
   l_pos_2            NUMBER := 0;
   l_repl_str         VARCHAR2(32);
   orig_list	      VARCHAR2(4000);
   col_list	      pk_list;
  BEGIN

    log('Function getPrimaryKeys ');
    EXECUTE IMMEDIATE 'SELECT primary_key_column, base_owner, base_object_name '
                      || ' FROM ASG_PUB_ITEM WHERE name = :pi '
                      INTO l_pk_list, l_base_owner, l_base_object_name
                      USING upper(p_pub_item);

    x_pk_cnt := 0;
    orig_list:=l_pk_list;
    l_pk_list := ''''||replace(l_pk_list, ',', ''',''')||'''';

    l_dml := 'SELECT column_name, data_type FROM all_tab_columns '
             || ' WHERE owner = :1 AND table_name = :2  '
             || ' AND COLUMN_NAME = :3';

    col_list := get_listfrom_string(orig_list);

    FOR i IN 1..col_list.COUNT
    LOOP
      EXECUTE IMMEDIATE l_dml into l_col_name,l_col_data_type
      USING l_base_owner,l_base_object_name,col_list(i) ;
      x_pk_cnt := x_pk_cnt + 1;
      IF (l_col_data_type = 'NUMBER') THEN
        IF (x_pk_list IS NULL) THEN
          x_pk_list := 'to_char('||l_col_name||')';
        ELSE
          x_pk_list := x_pk_list || ',' || 'to_char('||l_col_name||')';
        END IF;

      ELSIF (l_col_data_type = 'DATE') THEN
        IF (x_pk_list IS NULL) THEN
          x_pk_list := 'to_char('||l_col_name||',''dd-mon-yyyy hh24:mi:ss'')';
        ELSE
          x_pk_list := x_pk_list || ',' ||
                       'to_char('||l_col_name||',''dd-mon-yyyy hh24:mi:ss'')';
        END IF;

      ELSIF (l_col_data_type = 'CHAR' OR l_col_data_type = 'VARCHAR2') THEN
        IF (x_pk_list IS NULL) THEN
          x_pk_list := l_col_name;
        ELSE
          x_pk_list := x_pk_list || ',' || l_col_name;
        END IF;
      END IF;
    END LOOP;
    log('END Function getPrimaryKeys ');
    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RETURN FAIL;
  END getPrimaryKeys;

  PROCEDURE find_pubitem_lists (p_online_item_list IN OUT NOCOPY VARCHAR2,
                                p_complete_ref_pub_items IN OUT NOCOPY VARCHAR2,
                                p_incr_ref_pub_items IN OUT NOCOPY VARCHAR2,
                                p_compref_list IN OUT NOCOPY pk_list)
            IS
  l_cursor_id                  NUMBER;
  l_dml                        VARCHAR2(32767);
  l_pub_item                   VARCHAR2(30);
  l_comp_ref_flag              CHAR(1);
  l_online_query_flag          CHAR(1);
  l_rc                         NUMBER;
  l_ctr                        NUMBER;
  BEGIN

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;

    l_dml := 'SELECT a.name, a.comp_ref, b.online_query ' ||
             'FROM ' || CONS_SCHEMA || '.c$pub_list_q a, asg_pub_item b ' ||
             'WHERE a.name = b.name ' ||
             'ORDER by online_query desc, comp_ref desc';

    DBMS_SQL.PARSE (l_cursor_id, l_dml, DBMS_SQL.v7);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 1, l_pub_item, 30);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 2, l_comp_ref_flag, 1);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 3, l_online_query_flag, 1);
    l_rc := DBMS_SQL.EXECUTE (l_cursor_id);
    l_ctr := 1;

    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0 )
    LOOP

      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 1, l_pub_item);
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 2, l_comp_ref_flag);
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 3, l_online_query_flag);

      /* All Pub Items List */
      IF (g_pub_items_list IS NULL) THEN
        g_pub_items_list := ''''||l_pub_item;
      ELSE
        g_pub_items_list := g_pub_items_list||''','''
                            ||l_pub_item;
      END IF;
      IF(l_online_query_flag = 'Y') THEN
        IF (p_online_item_list IS NULL) THEN
          p_online_item_list := ''''||l_pub_item;
        ELSE
          p_online_item_list := p_online_item_list||''','''
                                ||l_pub_item;
        END IF;
        log ('  Online Pub Item: ' || l_pub_item);
      ELSE
        /* Remembering Complete Refresh Pub Items */
        IF (l_comp_ref_flag = 'Y') THEN
          IF (p_complete_ref_pub_items IS NULL) THEN
            p_complete_ref_pub_items := ''''||l_pub_item;
          ELSE
            p_complete_ref_pub_items := p_complete_ref_pub_items||''','''
                                        ||l_pub_item;
          END IF;
          p_compref_list(l_ctr) := l_pub_item;
          l_ctr := l_ctr + 1;
          log ('  Complete Refresh Pub Item: ' || l_pub_item);
        ELSE
        /* Remembering incremental refresh Pub Items */
          IF (p_incr_ref_pub_items IS NULL) THEN
            p_incr_ref_pub_items := ''''||l_pub_item;
          ELSE
            p_incr_ref_pub_items := p_incr_ref_pub_items||''','''
                                    ||l_pub_item;
          END IF;
          log ('  Incremental Refresh Pub Item: ' || l_pub_item);
        END IF;
      END IF;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

  END find_pubitem_lists;


    /** Function to Prepare the Out Queue Data */
  FUNCTION processSdq ( p_clientid IN VARCHAR2,
                        p_last_tranid IN NUMBER,
                        p_curr_tranid IN NUMBER,
                        p_high_prty IN VARCHAR2,
			x_ret_msg OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
    l_cursor_id                  NUMBER;
    l_dml                        VARCHAR2(32767);
    l_pub_item                   VARCHAR2(30);
    l_base_owner                 VARCHAR2(30);
    l_base_object                VARCHAR2(30);
    l_query_access               VARCHAR2(1);
    l_predicate_list             VARCHAR2(150);
    l_access_owner               VARCHAR2(30);
    l_access_name                VARCHAR2(30);
    l_predicate_clause           VARCHAR2(512);
    l_complete_ref_pub_items     VARCHAR2(32767) := NULL;
    l_incr_ref_pub_items         VARCHAR2(32767) := NULL;
    l_changed_pub_items          VARCHAR2(32767) := NULL;
    l_webtogo_list               VARCHAR2(32767) := NULL;
    l_online_item_list           VARCHAR2(32767) := NULL;
    l_compref_list               pk_list;
    l_user_name                  asg_system_dirty_queue.client_id%TYPE;
    l_c_client_id                asg_system_dirty_queue.client_id%TYPE;
    l_c_pub_item                 asg_system_dirty_queue.pub_item%TYPE;
    l_c_access_id                asg_system_dirty_queue.access_id%TYPE;
    l_c_dml_type                 asg_system_dirty_queue.dml_type%TYPE;
    l_cur_rc                     NUMBER;
    l_rc                         NUMBER;
    l_qid_tmp_list               DBMS_SQL.NUMBER_TABLE;
    l_tmpqry                     VARCHAR2(32767);
    l_qid_list                   NUMBER_TABLE;
    l_cur                        NUMBER;
    l_qid			 NUMBER;
    l_curid			 NUMBER;
    l_counter			 NUMBER;

    l_complete_ref_pub_items_lst pk_list;
    l_changed_pub_items_lst	pk_list;
  BEGIN

    log ('BEGIN Function processSDQ '||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));
    reset_all_globals();
    x_ret_msg := null;
    g_last_tranid := p_last_tranid;
    g_clientid    := p_clientid;
    l_webtogo_list := ''''|| OLITE_SEQUENCE ||'''';

    log ('Processing for '||p_clientid);

    /* Determine the pub-item list for this synch */
    find_pubitem_lists(l_online_item_list, l_complete_ref_pub_items,
                       l_incr_ref_pub_items, l_compref_list);

    IF(g_pub_items_list IS NULL) THEN
      -- No pub-items to process!
      x_ret_msg := 'Synch disallowed. User not configured to synch from this '||
                   'device. Please contact your administrator.';
      RETURN FAIL;
    ELSE
      g_pub_items_list := g_pub_items_list || '''';
    END IF;

    IF ( l_online_item_list IS NOT NULL ) THEN
      l_online_item_list := ',' || l_online_item_list || '''';
      l_webtogo_list := l_webtogo_list || l_online_item_list;
    END IF;

    -- Complete Refresh Pub Items List
    -- Remove all the entries in sdq for complete refresh pub-items
    IF ( l_complete_ref_pub_items IS NOT NULL ) THEN
      l_complete_ref_pub_items := l_complete_ref_pub_items || '''';
      IF ( l_webtogo_list IS NOT NULL ) THEN
        l_webtogo_list := l_webtogo_list||','||l_complete_ref_pub_items;
      ELSE
        l_webtogo_list := l_complete_ref_pub_items;
      END IF;
      g_complete_ref_pub_items := l_complete_ref_pub_items;

      --Fix For Bug 3075299
      l_counter:=1;
      /*
      l_tmpqry := 'select qid from asg_system_dirty_queue where client_id='''||
                   p_clientid|| ''' and  dml_type=0 and ' ||
                 ' pub_item in ('||l_complete_ref_pub_items||')';
      */
      l_tmpqry := 'select qid from asg_system_dirty_queue where '||
                  'client_id = :1 and  dml_type=0 and ' ||
                 ' pub_item in ('||l_complete_ref_pub_items||')';
      l_curid := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(l_curid,l_tmpqry, DBMS_SQL.v7);
      DBMS_SQL.bind_variable(l_curid,':1',p_clientid);
      DBMS_SQL.DEFINE_COLUMN (l_curid, 1, l_qid);
      l_rc :=DBMS_SQL.EXECUTE ( l_curid );
      WHILE ( DBMS_SQL.FETCH_ROWS(l_curid) > 0 ) LOOP
	    DBMS_SQL.COLUMN_VALUE (l_curid, 1, l_qid);
	    l_qid_tmp_list(l_counter) := l_qid;
	    l_counter := l_counter+1;
      END LOOP;

      /*
      l_tmpqry := 'delete from asg_system_dirty_queue where client_id= :1 ' ||
                  ' and pub_item in ('||l_complete_ref_pub_items||')';
      EXECUTE IMMEDIATE l_tmpqry
      USING p_clientid;
      */
      l_complete_ref_pub_items_lst := get_listfrom_string(
					l_complete_ref_pub_items);
      forall i in 1..l_complete_ref_pub_items_lst.count
        delete from asg_system_dirty_queue
	where client_id = p_clientid
	and pub_item = l_complete_ref_pub_items_lst(i);



      log(' After Delete SDQ : '||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));
      IF (l_qid_tmp_list.COUNT > 0) THEN
        l_cur := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE (l_cur, 'DELETE FROM asg_delete_queue '
                             || ' WHERE qid in (:2)', DBMS_SQL.v7);
        DBMS_SQL.BIND_ARRAY (l_cur, ':2', l_qid_tmp_list, 1,
                             l_qid_tmp_list.COUNT);
        l_cur_rc := DBMS_SQL.EXECUTE ( l_cur );
        DBMS_SQL.CLOSE_CURSOR (l_cur);
      END IF;

      log(' After Delete delQ : '||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));
    END IF;


    -- Set up the rows to be downloaded for incremental refresh
    IF(l_incr_ref_pub_items IS NOT NULL) THEN
      l_incr_ref_pub_items := l_incr_ref_pub_items || '''';
      /* Determine pub items dirty since last Sync */
      log ('  Changed Pub Items List ');

      l_cursor_id := DBMS_SQL.OPEN_CURSOR;
      /*
      l_dml := 'SELECT DISTINCT pub_item FROM asg_system_dirty_queue '
               || ' WHERE client_id='''||p_clientid
               ||''' AND (transaction_id IS NULL '
               || ' OR transaction_id > '||p_last_tranid
               ||') AND pub_item IN ('||l_incr_ref_pub_items||')';
      */
      l_dml := 'SELECT DISTINCT pub_item FROM asg_system_dirty_queue '
               || ' WHERE client_id= :1 AND (transaction_id IS NULL '
               || ' OR transaction_id > :2 ) '
	       || ' AND pub_item IN ('||l_incr_ref_pub_items||')';

      DBMS_SQL.PARSE (l_cursor_id, l_dml, DBMS_SQL.v7);
      dbms_sql.bind_variable(l_cursor_id,':1',p_clientid);
      dbms_sql.bind_variable(l_cursor_id,':2',p_last_tranid);
      DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 1, l_pub_item, 30);
      l_rc := DBMS_SQL.EXECUTE (l_cursor_id);

      WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0 )
      LOOP

        DBMS_SQL.COLUMN_VALUE (l_cursor_id, 1, l_pub_item);
        log ('    '||l_pub_item);
        IF ((l_complete_ref_pub_items IS NULL) OR
            (INSTR(l_complete_ref_pub_items, l_pub_item) = 0)) THEN
          IF ( l_changed_pub_items IS NULL ) THEN
            l_changed_pub_items := ''''||l_pub_item;
          ELSE
            l_changed_pub_items := l_changed_pub_items || ''','''
                                   || l_pub_item;
          END IF;
        END IF;
      END LOOP;
      DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

      -- Changed/Dirty Pub Items List
      IF ( l_changed_pub_items IS NOT NULL ) THEN
        l_changed_pub_items := l_changed_pub_items || '''';
        IF ( l_webtogo_list IS NOT NULL ) THEN
          l_webtogo_list := l_webtogo_list || ',' || l_changed_pub_items;
        ELSE
          l_webtogo_list := l_changed_pub_items;
        END IF;

        /** Mark ALL records modified since last Successful Sync of Client
         * with Curr Tran ID */
        log ('  Before marking records with Tran id  '||p_curr_tranid
             ||' '||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));
        /*
	l_dml := 'UPDATE asg_system_dirty_queue SET '
                 || ' transaction_id = :1, download_flag=NULL, '
                 || ' last_update_date = sysdate '
                 || ' WHERE client_id = :2 AND ( transaction_id IS NULL '
                 || ' OR transaction_id > :3 ) AND '
                 || ' pub_item IN ( :4 )';
        EXECUTE IMMEDIATE l_dml
        USING p_curr_tranid, p_clientid, p_last_tranid,
              replace(l_changed_pub_items, '''', '');
	      */
	l_changed_pub_items_lst := get_listfrom_string(l_changed_pub_items);
	forall j in 1..l_changed_pub_items_lst.count
	  update asg_system_dirty_queue
	  set transaction_id = p_curr_tranid,
	  download_flag = null,
	  last_update_date = sysdate
	  where client_id = p_clientid
	  and ( transaction_id is null or transaction_id > p_last_tranid )
	  and pub_item = l_changed_pub_items_lst(j);



        log ('  After marking record with Tran id  '||p_curr_tranid
             ||' '||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

        /** Mark RECORDS with the right DML Operation to Send to client */
        log ('  Before setting download_flag '
             ||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));
        UPDATE ASG_SYSTEM_DIRTY_QUEUE
        SET download_flag = 'Y'
        WHERE qid IN (select qid from ASG_SDQ_UPDATE_V );
        log ('  After setting download_flag '
             ||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));
      END IF;

    END IF;  /* End for IF (l_incr_ref_pub_items IS NOT NULL)  */

    /** Insert the complete refresh pubitems into the dirty queue */
    IF ( l_compref_list.COUNT > 0 ) THEN
      log('    Before Complete Refresh Insert: '||
          to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));
      FOR i IN 1..l_compref_list.COUNT
      LOOP
        SELECT base_owner, base_object_name,
               NVL(QUERY_ACCESS_TABLE, 'N'), ACCESS_TABLE_PREDICATE_LIST,
               access_owner, access_name
        INTO l_base_owner, l_base_object, l_query_access, l_predicate_list,
             l_access_owner, l_access_name
        FROM asg_pub_item WHERE name=l_compref_list(i);
        /* The second condition actually implies an error in seed data but we
           tolerate it  */
        IF ((l_query_access = 'N') OR
            (l_access_owner IS NULL OR l_access_name IS NULL)) THEN
          l_dml := 'INSERT INTO asg_system_dirty_queue ( ' ||
                   'qid, creation_date, created_by, last_update_date,' ||
                   'last_updated_by, pub_item, access_id, client_id, ' ||
                   'transaction_id, dml_type, download_flag) '||
                   ' SELECT asg_system_dirty_queue_s.nextval, SYSDATE, 1, ' ||
                   ' SYSDATE, 1, :1, ' ||
                   ' uniqpiv.access_id, ' ||
                   ' :2, :3, ' ||
                   ' 1, ''Y'' FROM (SELECT DISTINCT ACCESS_ID FROM ' ||
                   l_base_owner ||'.' ||l_base_object ||
                   ' ) uniqpiv';

         ELSE
          l_predicate_clause := get_predicate_clause(l_predicate_list);
          l_dml := 'INSERT INTO asg_system_dirty_queue ( ' ||
                   'qid, creation_date, created_by, last_update_date,' ||
                   'last_updated_by, pub_item, access_id, client_id, ' ||
                   'transaction_id, dml_type, download_flag) '||
                   ' SELECT asg_system_dirty_queue_s.nextval, SYSDATE, 1, ' ||
                   ' SYSDATE, 1, :1, ' ||
                   ' uniqacc.access_id, ' ||
                   ' :2, :3, ' ||
                   ' 1, ''Y'' FROM (SELECT DISTINCT ACCESS_ID FROM ' ||
                   l_access_owner || '.' || l_access_name;
          -- Null l_predicate_clause means no where condition on access table
          IF (l_predicate_clause IS NOT NULL) THEN
            l_dml := l_dml || ' WHERE ' || l_predicate_clause ||
                  ' ) uniqacc';
          ELSE
            l_dml := l_dml || ' ) uniqacc';
          END IF;
         END IF;

        EXECUTE IMMEDIATE l_dml
        USING l_compref_list(i), p_clientid, p_curr_tranid;

      END LOOP;
      log('    After Complete Refresh Insert: '||
          to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));
    END IF;

    /** Delete pub items which are not in l_changed_pub_items
      * , l_complete_ref_pub_items AND l_online_item_list */
    IF ( l_webtogo_list IS NULL ) THEN

      l_dml := 'DELETE FROM '||CONS_SCHEMA||'.c$pub_list_q ' ||

               'WHERE name in (select name from asg_pub_item)';

    ELSE

      l_dml := 'DELETE FROM '||CONS_SCHEMA||'.c$pub_list_q '

               || ' WHERE name NOT IN (' || l_webtogo_list || ') AND ' ||

               ' name in (select name from asg_pub_item)';

    END IF;
    EXECUTE IMMEDIATE l_dml;

    log ('  Processing completed for '||p_clientid);
    log ('END Function processSDQ '||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));
    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      IF ( l_cursor_id <> 0 ) THEN
        DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
      END IF;
      log(sqlerrm);
      RAISE;
  END processSdq;

    /** Function to Purge the Out Queue Data */
  FUNCTION purgeSdq RETURN BOOLEAN IS
    l_ret boolean;
    l_prof_value varchar2(5);
  BEGIN

    log('PurgeSDQ for '||g_clientid||' with '||g_last_tranid ||' : '
         || to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

    /* Clean the System Dirty Queue */
    IF (isFirstSync) THEN
      /*First synch. So no need to raise events*/
      DELETE FROM asg_system_dirty_queue
      WHERE client_id = g_clientid AND
            transaction_id IS NOT NULL;
    ELSE
      select nvl(fnd_profile.value_specific('ASG_ENABLE_DELIVERY_EVENTS'),'N')
      into l_prof_value from dual;
      /*Raise delivery events only if the profile is set to 'Y'*/
      if(l_prof_value = 'Y')
      then
        log('Raising data download event');
        /* raise data downloaded event for records downloaed during current
        synch*/
        l_ret := raise_data_downloaded();
        log('Raising data downloaded confirmed event');
        /*raise download confirmed for records that were successfully downloaded
        in the previous synch*/
        l_ret := raise_data_download_confirmed();
      else
        log('Not raising download events since  the profile '
            ||' ASG_ENABLE_DELIVERY_EVENTS is not set to ''Y''');
      end if;
      /* Clean the Delete Queue */
      DELETE FROM asg_delete_queue
      WHERE qid IN (SELECT qid
                    FROM asg_system_dirty_queue
                    WHERE client_id =  g_clientid AND
                    transaction_id <= g_last_tranid );

      DELETE FROM asg_system_dirty_queue
      WHERE client_id = g_clientid  AND
            transaction_id <= g_last_tranid;
    END IF;

    log('PurgeSDQ done for '||g_clientid || ' : '
        || to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

    RETURN OK;
  EXCEPTION
     WHEN OTHERS THEN
       log(sqlerrm);
       RAISE;
  END purgeSdq;


  /** Function to Purge the Out Queue Data for a User */
  FUNCTION purgeSdq (p_clientid VARCHAR2) RETURN BOOLEAN IS
  BEGIN

     /* Clean the Delete Queue */
     log('PurgeSDQ for '||p_clientid);
     DELETE FROM asg_delete_queue
     WHERE qid IN (SELECT qid
                   FROM asg_system_dirty_queue
                   WHERE client_id = p_clientid);

     /* Clean the System Dirty Queue */
     DELETE FROM asg_system_dirty_queue
     WHERE client_id = p_clientid;

     log('PurgeSDQ done for '||p_clientid);

     RETURN OK;
  EXCEPTION
     WHEN OTHERS THEN
       log(sqlerrm);
       RAISE;
  END purgeSdq;


  /* Log Routine */
  PROCEDURE log (p_mesg VARCHAR2 ) IS
  BEGIN
    IF(asg_helper.check_is_log_enabled(LOG_LEVEL))
    THEN
      asg_helper.log(p_mesg, 'asg_download', FND_LOG.LEVEL_STATEMENT);
    END IF;
  END log;



  -- to be replaced with asg_base.get_user_name(user_id)
  FUNCTION get_username_from_userid ( p_userid IN NUMBER )
           RETURN VARCHAR2 IS
    CURSOR C_USER_NAME(p_userid NUMBER) IS
      SELECT  user_name
      FROM    asg_user
      WHERE   user_id = p_userid
      AND     ENABLED ='Y';
    l_user_name  asg_user.user_name%type;
  BEGIN
    OPEN C_USER_NAME(p_userid);
    FETCH C_USER_NAME into l_user_name;
    CLOSE C_USER_NAME;
    return l_user_name;
  END get_username_from_userid;


--ver 4 mark_dirty
  FUNCTION mark_dirty ( p_pub_item         IN VARCHAR2,
                        p_accessList       IN access_list,
                        p_userid_list      IN user_list,
                        p_dmlList          IN dml_list,
                        p_timestamp        IN DATE) RETURN BOOLEAN IS

   l_username_list  username_list;
   l_accessList     access_list;
   l_retval         BOOLEAN;
   l_user_name      asg_user.user_name%type;
   l_dmlList        dml_list;
   l_ctr            NUMBER;
  BEGIN
    IF ( (p_accessList.count <> p_userid_list.count ) OR
         (p_accessList.count <> p_dmlList.count)  ) THEN
      RAISE PARAMETER_COUNT_MISMATCH;
    END IF;
    l_ctr := 1;
    FOR i in 1..p_userid_list.count
    LOOP
      l_user_name := get_username_from_userid(p_userid_list(i));
      IF l_user_name IS NOT NULL THEN
       l_username_list(l_ctr) := l_user_name;
       l_accessList(l_ctr)    := p_accessList(i);
       l_dmlList(l_ctr)       := p_dmlList(i);
       l_ctr                  := l_ctr + 1;  --increment counter for the new list
      END IF;
      l_user_name := NULL;
    END LOOP;
    --only if valid rows are present do call mark dirty internal
    IF  l_accessList.COUNT > 0 THEN
      l_retval:=mark_dirty_internal(p_pub_item,l_accessList,l_username_list,
                                  l_dmlList,p_timestamp);
    END IF;

    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE;
  END mark_dirty;

--ver 5   mark_dirty
  FUNCTION mark_dirty ( p_pub_item         IN VARCHAR2,
                        p_accessList       IN access_list,
                        p_userid_list      IN user_list,
                        p_dml_type         IN CHAR,
                        p_timestamp        IN DATE) RETURN BOOLEAN IS
    l_username_list username_list;
    l_retval BOOLEAN;
    l_accessList     access_list;
    l_user_name      asg_user.user_name%type;
    l_ctr            NUMBER;
  BEGIN
    log ('Function markDirty - Accessid-Resourceid - 1-1 - Single DML');
    IF  (p_accessList.count <> p_userid_list.count ) THEN
      RAISE PARAMETER_COUNT_MISMATCH;
    END IF;
    l_ctr := 1;
    FOR i in 1..p_userid_list.count
    LOOP
      l_user_name := get_username_from_userid(p_userid_list(i));

      IF l_user_name IS NOT NULL THEN
       l_username_list(l_ctr) := l_user_name;
       l_accessList(l_ctr)    := p_accessList(i);
       l_ctr                  := l_ctr + 1;  --increment counter for the new list
      END IF;
      l_user_name := NULL;
    END LOOP;
        --only if valid rows are present do call mark dirty internal
    IF  l_accessList.COUNT > 0 THEN
      l_retval:=mark_dirty_internal(p_pub_item,l_accessList,l_username_list,
                                  p_dml_type,p_timestamp);
    END IF;
    log ('END Function markDirty- Accessid-Resourceid - 1-1 - Single DML');
    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE ;
  END mark_dirty;

--ver 2  mark_dirty
  FUNCTION mark_dirty ( p_pub_item         IN VARCHAR2,
                        p_accessid         IN NUMBER,
                        p_userid           IN NUMBER,
                        p_dml              IN CHAR,
                        p_timestamp        IN DATE )RETURN BOOLEAN IS

    l_mobile_user   VARCHAR2(30);
    l_retval        BOOLEAN;
  BEGIN
    log ('Function markDirty - single row');
    l_mobile_user := get_username_from_userid(p_userid);
    --Do markdirty only if valid username is present
    IF l_mobile_user IS NOT NULL THEN
      l_retval:=mark_dirty_internal(p_pub_item,p_accessid,l_mobile_user,
                                      p_dml,p_timestamp);
    END IF;

    RETURN OK;
  EXCEPTION
      WHEN OTHERS THEN
        log(sqlerrm);
	RAISE;
  END mark_dirty;


--ver  3 mark_dirty
  FUNCTION mark_dirty ( p_pub_item         IN VARCHAR2,
                        p_accessid         IN NUMBER,
                        p_userid           IN NUMBER,
                        p_dml              IN CHAR,
                        p_timestamp        IN DATE,
                        p_pkvalues         IN pk_list ) RETURN BOOLEAN IS
    l_mobile_user   VARCHAR2(30);
    l_retval BOOLEAN;
  BEGIN
    log ('Function markDirty - single row with PK Values given');
    l_mobile_user := get_username_from_userid(p_userid);
    --Do markdirty only if valid username is present
    IF l_mobile_user IS NOT NULL THEN
      l_retval:=mark_dirty_internal(p_pub_item,p_accessid,l_mobile_user,
                                  p_dml,p_timestamp,p_pkvalues);
    END IF;

    RETURN OK;
  EXCEPTION
      WHEN OTHERS THEN
        log(sqlerrm);
        RAISE;
  END mark_dirty;

-- ver 6 mark_dirty
  FUNCTION mark_dirty ( p_pub_item         IN VARCHAR2,
                        p_accessList       IN access_list,
                        p_userid_list      IN user_list,
                        p_dml_type         IN CHAR,
                        p_timestamp        IN DATE,
                        p_bulk_flag        IN BOOLEAN) RETURN BOOLEAN IS
    l_username_list username_list;
    l_retval BOOLEAN;
    l_user_name      asg_user.user_name%type;
    l_ctr            NUMBER;

  BEGIN
    log ('Function markDirty - Accessid-Resourceid - Many-Many ');
    l_ctr :=1;
    FOR i in 1..p_userid_list.count
    LOOP
      l_user_name := get_username_from_userid(p_userid_list(i));

      IF l_user_name IS NOT NULL THEN
       l_username_list(l_ctr) := l_user_name;
       l_ctr                  := l_ctr + 1;  --increment counter for the new list
      END IF;
      l_user_name := NULL;

    END LOOP;
    --only if valid rows are present do call mark dirty internal
    IF  p_accessList.COUNT > 0 THEN
        l_retval:=mark_dirty_internal(p_pub_item,p_accessList,l_username_list,
                                    p_dml_type,p_timestamp,p_bulk_flag);
    END IF;
    log ('END Function markDirty - Accessid-Resourceid - Many-Many ');
    RETURN OK;
  EXCEPTION
    WHEN OTHERS THEN
      log(sqlerrm);
      RAISE ;
  END mark_dirty;

  PROCEDURE log_concprogram(l_msg VARCHAR2 ,l_mod varchar2,l_level number)
  is
  begin
    asg_helper.log(l_msg, l_mod,l_level);
       IF(g_purge_log_enabled IS null)
       then
         begin
	   SELECT nvl(value,'N') INTO g_purge_log_enabled
	   FROM asg_config WHERE name='ENABLE_PURGE_LOGGING';
	 exception
	 when no_data_found
	 then
	   g_purge_log_enabled := 'N';
	 end;
       END IF;
    IF(g_purge_log_enabled = 'Y')
    THEN
      fnd_file.put_line(fnd_file.log,l_msg);
    END IF;
  END log_concprogram;

  /*
  takes a user name and deletes all duplicate records for that user
  from SDQ and DQ
  */
  PROCEDURE delete_duplicate_records(l_user_name varchar2)
  is
  l_dml		VARCHAR2(1000);
  l_count	NUMBER;
  PRAGMA AUTONOMOUS_TRANSACTION;
  begin
    -- delete from asg_delete_queue
    l_dml := 'Delete /*+ INDEX(asg_delete_queue ASG_DELETE_QUEUE_U1) */ from '||
             ' asg_delete_queue where qid in '||
             ' ( Select qid from  '||
	     '   ( select qid, pub_item, access_id, dml_type, '||
	     '     count(*) over (partition by pub_item, access_id, dml_type)'||
	     '     as total_rows, '||
	     '     min(qid) over (partition by pub_item, access_id, dml_type)'||
	     '     as min_qid '||
	     '     from asg_system_dirty_queue  where client_id = :1  AND '||
	     '     TRANSACTION_ID IS NULL and download_flag is null '||
	     '   ) '||
	     ' where qid <> min_qid and total_rows >1 )';
    EXECUTE IMMEDIATE l_dml USING l_user_name;
    l_count := SQL%ROWCOUNT;
   /* log_concprogram('Removed '||l_count||' duplicate rows from Delete queue '||
                    ' for user : '||l_user_name,
		    'asg_download',
		    FND_LOG.LEVEL_STATEMENT);*/
    -- delete from asg_system_dirty_queue
    l_dml := 'Delete /*+ INDEX(asg_system_dirty_queue ASG_SYSTEM_DIRTY_QUEUE_U1) */ from asg_system_dirty_queue where qid in '||
             ' ( Select qid from  '||
	     '   ( select qid, pub_item, access_id, dml_type, '||
	     '     count(*) over (partition by pub_item, access_id, dml_type)'||
	     '     as total_rows, '||
	     '     min(qid) over (partition by pub_item, access_id, dml_type)'||
	     '     as min_qid '||
	     '     from asg_system_dirty_queue  where client_id = :1  AND '||
	     '     TRANSACTION_ID IS NULL and download_flag is null '||
	     '   ) '||
	     ' where qid <> min_qid and total_rows >1 )';
    EXECUTE IMMEDIATE l_dml USING l_user_name;
    l_count := SQL%ROWCOUNT;
    /*log_concprogram('Removed '||l_count||' duplicate rows from Dirty queue '||
                    ' for user : '||l_user_name,
		    'asg_download',
		    FND_LOG.LEVEL_STATEMENT);*/
    commit;
  EXCEPTION
  WHEN OTHERS THEN
    /*log_concprogram('Error deleting duplicate record from SDQ for '||
                    l_user_name||' : '||SQLERRM,
		    'asg_download',FND_LOG.LEVEL_UNEXPECTED);*/
    rollback;
--    raise;
  END delete_duplicate_records;

  /*
  takes a user name and inserts records for each publication subscribed
  by the user into asg_purge_sdq
  */
  PROCEDURE set_user_first_synch(l_user_name varchar2)
  is
  PRAGMA autonomous_transaction;
  BEGIN
    log_concprogram('Setting user '||l_user_name ||' to first synch '||
                    l_user_name,'asg_download',
		    FND_LOG.LEVEL_STATEMENT);

    INSERT INTO asg_purge_sdq(user_name,pub_name,creation_date,created_by,
    last_update_date,last_updated_by )
    ( SELECT user_name,pub_name ,sysdate,1,sysdate,1
      FROM asg_user_pub_resps
      WHERE user_name = l_user_name
      AND pub_name IN
      (select name  from asg_pub  where nvl(custom,'N') =  'N' )
     );
    commit;
    log_concprogram('Done setting user '||l_user_name ||' to first synch '||
                    l_user_name,'asg_download',
		    FND_LOG.LEVEL_STATEMENT);
  EXCEPTION
  WHEN OTHERS then
    log_concprogram('Error setting user '||l_user_name||' to first synch: '||
                    SQLERRM,'asg_download',
		    FND_LOG.LEVEL_UNEXPECTED);
    rollback;
    raise;
  END set_user_first_synch;

  /*
  takes a user name and inserts records for each publication subscribed
  by the user into asg_purge_sdq
  */
  PROCEDURE set_user_first_synch_pub(l_user_name varchar2,l_pub_name varchar2)
  is
  PRAGMA autonomous_transaction;
  l_count NUMBER;
  BEGIN
    /*log_concprogram('Setting user '||l_user_name ||' to first synch '||
                    l_user_name,'asg_download',
		    FND_LOG.LEVEL_STATEMENT);*/
    SELECT COUNT(*) INTO l_count
    FROM asg_purge_sdq
    WHERE user_name = l_user_name
    AND   pub_name  = l_pub_name;

    IF l_count =0 THEN
      INSERT INTO asg_purge_sdq(user_name,pub_name,creation_date,created_by,
      last_update_date,last_updated_by)
      VALUES (l_user_name,l_pub_name,sysdate,1,sysdate,1);
      commit;
   END IF;
    /*log_concprogram('Done setting user '||l_user_name ||' to first synch '||
                    l_user_name,'asg_download',
		    FND_LOG.LEVEL_STATEMENT);*/
  EXCEPTION
  WHEN OTHERS THEN
    /*log_concprogram('Error setting user '||l_user_name||' to first synch: '||
                    SQLERRM,'asg_download',
		    FND_LOG.LEVEL_UNEXPECTED);*/
    ROLLBACK;
    --raise;
  END set_user_first_synch_pub;


-- to be used by the JTM master concurrent program.
-- Deletes the rows in asg_system_dirty_queue for all the dormant users.
-- Forces these users to do a complete refresh.
  PROCEDURE delete_Sdq( P_status OUT NOCOPY VARCHAR2,
			P_message OUT NOCOPY VARCHAR2)
  IS

    l_user_id		NUMBER;
    l_user_name		VARCHAR2(30);
    l_days		NUMBER;
    l_temp		NUMBER;
    l_profileValue	NUMBER;

    CURSOR c_dormant_users(l_dormancy_period NUMBER,
  			   l_last_processed VARCHAR2,l_max_num NUMBER,
			   l_last_user varchar2)
    IS
       SELECT user_name,pub_name
       FROM asg_user_pub_resps
       WHERE trunc( sysdate - NVL(synch_date,to_date('1', 'J')) )
       > l_dormancy_period
       AND pub_name IN ( SELECT NAME FROM asg_pub WHERE nvl(custom,'N') = 'N' )
       and user_name > l_last_processed
       and user_name <=l_last_user
       ORDER BY user_name;

    l_dormant_rec c_dormant_users%ROWTYPE;

    CURSOR c_last_processed_user
    IS
       SELECT value FROM asg_config
       WHERE name='ASG_SDQ_PURGE_LAST_USER';

    CURSOR c_last_processed_dupdel_user
    IS
       SELECT value FROM asg_config
       WHERE NAME='ASG_SDQ_PURGE_LAST_DUPDEL';

    CURSOR c_all_users(l_last_processed VARCHAR2,l_max_num NUMBER)
    IS
       SELECT user_name FROM
       (
        SELECT user_name FROM asg_user
        WHERE user_name > l_last_processed
	and user_name not in
	( select distinct user_name
	  from asg_purge_sdq where TRANSACTION_ID IS  NULL )
	ORDER BY user_name
        ) WHERE ROWNUM <= l_max_num;

    CURSOR c_get_last_user(l_dormancy_period NUMBER,
  			   l_last_processed VARCHAR2,l_num_users number)
    IS
      SELECT user_name FROM (
      SELECT ROWNUM pos,user_name FROM
      (
        SELECT DISTINCT user_name
	FROM asg_user_pub_resps
	WHERE  user_name > l_last_processed
	AND TRUNC( SYSDATE - NVL(synch_date,TO_DATE('1', 'J')) )
	> l_dormancy_period
	ORDER BY user_name
      )
      ) WHERE pos = l_num_users;

    CURSOR c_get_count(l_dormancy_period NUMBER,
  			   l_last_processed VARCHAR2)
    IS
    SELECT COUNT(*) FROM (
      SELECT ROWNUM pos,user_name FROM
      (
        SELECT DISTINCT user_name
	FROM asg_user_pub_resps
	WHERE  user_name > l_last_processed
	AND TRUNC( SYSDATE - NVL(synch_date,TO_DATE('1', 'J')) )
	> l_dormancy_period
	ORDER BY user_name
      ) );


    l_last_processed_user	VARCHAR2(30);
    l_dormancy_period	NUMBER;
    l_max_users		NUMBER;
    l_tmp_user		VARCHAR2(30);
    l_summary		VARCHAR2(4000);
    l_dml		VARCHAR2(1000);
    l_last_user		VARCHAR2(30);
    l_last_dupdel_user	VARCHAR2(30);
    l_final_user	VARCHAR2(30);
    l_pub_name		VARCHAR2(30);
    l_purge_conf_interval NUMBER := 30;
    l_date		date;
    l_total		NUMBER;
  BEGIN
    log_concprogram('Start SDQ purge ','asg_download',
                    FND_LOG.LEVEL_STATEMENT);
    l_final_user := null;

    -- Fix to 3536657
    -- Later, allow customer to specify the interval via a separate
    -- profile option
    l_dormancy_period := fnd_profile.VALUE('ASG_SDQ_PURGE_DAYS');
    if(l_dormancy_period is not null) then
      l_purge_conf_interval := l_dormancy_period;
    end if;
    delete from asg_conf_info
    where (sysdate-creation_date) >l_purge_conf_interval;
    commit;

    l_max_users :=
       fnd_profile.VALUE('ASG_SDQ_PURGE_USER_COUNT');
    if(l_max_users is null )
    then
      log_concprogram('Profile ASG: Purge User Count is set to null. Exiting',
                      'asg_download',FND_LOG.LEVEL_STATEMENT);
      log_concprogram('Please set the profile ASG: Purge User Count to a '||
                      'non-null value and resubmit the concurrent program',
		      'asg_download',FND_LOG.LEVEL_STATEMENT);
      P_status := 'Warning';
      p_message := 'Profile ASG: Purge User Count is set to null';
      return;
    end if;
    log_concprogram('Number of users to be processed : '||l_max_users,
		   'asg_download',FND_LOG.LEVEL_STATEMENT);

    if(l_dormancy_period is null )
    then
      log_concprogram('Profile ASG: Dormancy Period is set to null. Exiting',
                      'asg_download',FND_LOG.LEVEL_STATEMENT);
      log_concprogram('Please set the profile ASG: Dormancy Period to a '||
                      'non-null value and resubmit the concurrent program',
		      'asg_download',FND_LOG.LEVEL_STATEMENT);
      P_status := 'Warning';
      p_message := 'Profile ASG: Dormancy Period is set to null';
      return;
    end if;
    log_concprogram('Dormancy period : '||l_dormancy_period,
		     'asg_download',FND_LOG.LEVEL_STATEMENT);


    OPEN c_last_processed_dupdel_user;
    FETCH c_last_processed_dupdel_user INTO l_last_dupdel_user;
    CLOSE c_last_processed_dupdel_user;

     IF( l_last_dupdel_user IS NULL )
     THEN
      l_last_dupdel_user := to_char(0);
     ELSE
      --chk whether the last user is hit
      OPEN c_all_users(l_last_dupdel_user,l_max_users);
      FETCH c_all_users INTO l_user_name;
      IF(c_all_users%NOTFOUND) --we have hit last user.so reset to to_char(0);
      THEN
         l_last_dupdel_user :=  to_char(0);
         log_concprogram('Last user hit for deleting duplicates..'||
	                 'starting from first user',
			 'asg_download',FND_LOG.LEVEL_STATEMENT);

      END if;
      CLOSE c_all_users;
    END IF;
    --delete duplicate records to start off...
    --loop thru all users in asg_user and delete duplicate records.
   l_last_user := null;
   SELECT SYSDATE INTO l_date FROM dual;
   log_concprogram('Starting to delete duplicate records : '||
                   to_char(l_date,'dd-mon-yyyy hh24:mi:ss'),
		   'asg_download',FND_LOG.LEVEL_STATEMENT);
   OPEN c_all_users(l_last_dupdel_user,l_max_users);
    LOOP
      FETCH c_all_users INTO l_user_name;
      EXIT WHEN c_all_users%NOTFOUND;
      l_last_user := l_user_name;
      SELECT SYSDATE INTO l_date FROM dual;
      log_concprogram('Deleting duplicate records for '||l_user_name||' : '||
                      to_char(l_date,'dd-mon-yyyy hh24:mi:ss'),
		      'asg_download',FND_LOG.LEVEL_STATEMENT);
      delete_duplicate_records(l_user_name);
    END loop;
    CLOSE c_all_users;

   UPDATE asg_config SET value=nvl(l_last_user,value)
   WHERE NAME='ASG_SDQ_PURGE_LAST_DUPDEL';
   COMMIT;

   SELECT SYSDATE INTO l_date FROM dual;
   log_concprogram('End of deleting duplicate records'||' : '||
                   to_char(l_date,'dd-mon-yyyy hh24:mi:ss'),
		   'asg_download',FND_LOG.LEVEL_STATEMENT);

   OPEN c_last_processed_user();
   FETCH c_last_processed_user INTO l_last_processed_user;
   CLOSE c_last_processed_user;

   IF(l_last_processed_user = NULL )
   THEN
     l_last_processed_user := to_char(0);
   ELSE
     --check whether there are any more users to be processed
     --after l_last_processed_user ...
     --if no reset value of asg_config parameter to null
     --set l_last_processed_user to to_char(0)
     OPEN c_get_last_user(l_dormancy_period,l_last_processed_user,1);
     FETCH c_get_last_user INTO l_tmp_user;
     IF(c_get_last_user%NOTFOUND) --we have hit last user.so reset to to_char(0)
     THEN
        l_last_processed_user :=  to_char(0);
        log_concprogram('Last user hit..starting from first user',
		   'asg_download',FND_LOG.LEVEL_STATEMENT);

     END if;
     CLOSE c_get_last_user;
   END IF;

   log_concprogram('Last User to be processed in previous run : '||
                   l_last_processed_user,
		   'asg_download',FND_LOG.LEVEL_STATEMENT);

   -- get last user
   OPEN c_get_last_user(l_dormancy_period,l_last_processed_user,l_max_users);
   FETCH c_get_last_user INTO l_final_user;
   IF(c_get_last_user%NOTFOUND)
   THEN
     l_final_user := to_char(0);
   END IF;
   CLOSE c_get_last_user;

   IF(l_final_user = to_char(0) )
   THEN
     OPEN c_get_count(l_dormancy_period,l_last_processed_user);
     FETCH c_get_count INTO l_total;
     CLOSE c_get_count;
     log_concprogram('Processing : '||l_total||' users',
		   'asg_download',FND_LOG.LEVEL_STATEMENT);

     OPEN c_get_last_user(l_dormancy_period,l_last_processed_user,l_total);
     FETCH c_get_last_user INTO l_final_user;
     CLOSE c_get_last_user;
   END IF;

   log_concprogram('Final user processed in this run : '||l_final_user,
		   'asg_download',FND_LOG.LEVEL_STATEMENT);

   l_tmp_user := null;
   l_last_user := null;
   OPEN c_dormant_users(l_dormancy_period,l_last_processed_user,
                        l_max_users,l_final_user);
   LOOP
     FETCH c_dormant_users INTO l_dormant_rec;
     EXIT WHEN c_dormant_users%NOTFOUND;
     l_last_user := l_dormant_rec.user_name;
     log_concprogram('Purging SDQ for dormant user : '||
                     l_dormant_rec.user_name||' and publication :'||
		     l_dormant_rec.pub_name,
		     'asg_download',FND_LOG.LEVEL_STATEMENT);
     BEGIN
        DELETE /*+ INDEX(asg_delete_queue ASG_DELETE_QUEUE_U1) */ FROM
	asg_delete_queue
	WHERE qid IN
	( SELECT qid
	  FROM asg_system_dirty_queue
	  WHERE client_id = l_dormant_rec.user_name
	  AND pub_item in
	  (SELECT item_id FROM asg_pub_item
	   WHERE pub_name=l_dormant_rec.pub_name));

       log_concprogram('Done deleting DQ for '||l_tmp_user||' '||
                       SQL%ROWCOUNT||' rows',
		       'asg_download',FND_LOG.LEVEL_STATEMENT);


	DELETE FROM asg_system_dirty_queue
	WHERE client_id = l_dormant_rec.user_name
	AND pub_item in
	(SELECT item_id FROM asg_pub_item
	 WHERE pub_name=l_dormant_rec.pub_name);
       log_concprogram('Done deleting SDQ for '||l_tmp_user||' '||
                      SQL%ROWCOUNT||' rows',
		      'asg_download',FND_LOG.LEVEL_STATEMENT);

	DELETE FROM asg_complete_refresh
	WHERE user_name = l_dormant_rec.user_name
	AND publication_item IN
	(SELECT item_id FROM asg_pub_item
	 WHERE pub_name = l_dormant_rec.pub_name);

	DELETE FROM asg_purge_sdq
	WHERE user_name = l_dormant_rec.user_name
	AND pub_name = l_dormant_rec.pub_name;
	commit;
	/* change this .. has to insert for current publicatino..*/
	set_user_first_synch_pub(l_dormant_rec.user_name,
	                         l_dormant_rec.pub_name);
      END;
      -- delete SDQ and DQ , asg_complete_refresh , asg_purge_sdq and commit.
      -- set to complete ref in asg_purge_sdq..
    END LOOP;
    CLOSE c_dormant_users;

    log_concprogram('Last user to be processed in this run : '||l_last_user,
		   'asg_download',FND_LOG.LEVEL_STATEMENT);

    UPDATE asg_config
    SET value = nvl(l_last_user,value)
    WHERE NAME ='ASG_SDQ_PURGE_LAST_USER';
    commit;

    UPDATE jtm_con_request_data
    SET last_run_date = SYSDATE
    WHERE package_name = 'ASG_DOWNLOAD'
    AND procedure_name = 'DELETE_SDQ';
    COMMIT;

    log_concprogram('End SDQ purge ','asg_download',
                    FND_LOG.LEVEL_STATEMENT);
     p_status := 'Fine';
     p_message := 'Purging asg_system_dirty_queue and asg_delete_queue completed successfully.';

    EXCEPTION
    WHEN OTHERS THEN
      p_status := 'Error';
      p_message := 'Exception in purge :'||SQLERRM;
      log_concprogram('Exception in purge :'||SQLERRM,
		     'asg_download',FND_LOG.LEVEL_UNEXPECTED);
  END delete_Sdq;

  /*
  function to verify whether record shd be inserted into SDQ or not
  return values :
  If it returns "false" then the record need not be inserted into SDQ ..
  it may be that:
	1. records for the pub item or the corresponding publication
	   exists in asg_complete_refresh or asg_purge_sdq
  If the return value is "true" then record is inserted.
  --
  */

  FUNCTION insert_sdq(p_pub_item varchar2,p_user_name varchar2) RETURN boolean
  IS
    CURSOR c_pub_name(l_pub_item varchar2)
    IS
      SELECT pub_name FROM asg_pub_item WHERE item_id = p_pub_item;
    CURSOR c_exists_compref(l_pi varchar2,l_un varchar2)
    IS
      SELECT user_name FROM asg_complete_refresh
      WHERE user_name = l_un AND publication_item = l_pi
      AND synch_completed = 'N';
    CURSOR c_exists_purge(l_pub varchar2,l_un varchar2)
    IS
      SELECT user_name FROM asg_purge_Sdq
      WHERE user_name = l_un
      AND pub_name = l_pub
      AND transaction_id IS null;
    l_pub_name	varchar2(30);
    l_tmp	varchar(30);

  BEGIN
    OPEN c_exists_compref(p_pub_item,p_user_name);
    FETCH c_exists_compref INTO l_tmp;
    IF(c_exists_compref%FOUND)
    THEN
      CLOSE c_exists_compref;
      RETURN false;
    END IF;
    CLOSE c_exists_compref;

    OPEN c_pub_name(p_pub_item);
    FETCH c_pub_name INTO l_pub_name;
    CLOSE c_pub_name;

    OPEN c_exists_purge(l_pub_name,p_user_name);
    FETCH c_exists_purge INTO l_tmp;
    IF(c_exists_purge%FOUND)
    THEN
      CLOSE c_exists_purge;
      RETURN false;
    END IF;
    CLOSE c_exists_purge;
    -- we have reached here.. so record can be inserted into SDQ
    RETURN TRUE;
  END insert_sdq;


  /*
  checks whether the record exists in SDQ
  return value:
  if record exists then "false" - so need not be inserted again
  if record doesn't exist then "true" - insert into SDQ
  */
  FUNCTION is_exists(p_clientid varchar2, p_pub_item varchar2,
		     p_access_id number,p_dml_type char)
		     RETURN boolean
  IS
   CURSOR c_is_exists_in_sdq(p_clientid varchar2, p_pub_item varchar2,
			     p_access_id number,p_dml_type varchar2)
   IS
     SELECT client_id FROM asg_system_dirty_queue
     WHERE client_id = p_clientid AND pub_item = p_pub_item
     AND access_id = p_access_id
     AND dml_type = DECODE(p_dml_type,'D',0,'I',1,'U',2)
     AND transaction_id IS NULL AND download_flag IS null;
   l_tmp_user varchar2(30);
  BEGIN
    OPEN c_is_exists_in_sdq(p_clientid,p_pub_item,p_access_id,p_dml_type);
    FETCH c_is_exists_in_sdq INTO l_tmp_user;
    if(c_is_exists_in_sdq%FOUND)
    THEN
      CLOSE c_is_exists_in_sdq;
      RETURN false;
    END IF;
    CLOSE c_is_exists_in_sdq;
    RETURN true;
  END is_exists;


  PROCEDURE delete_synch_history( P_status OUT NOCOPY VARCHAR2,
				  P_message OUT NOCOPY VARCHAR2)
  IS
    l_purge_interval NUMBER ;
    l_qry varchar2(4000);
    l_row_count number;
    l_purge_session_data   session_id_list;
    c_hist                 c_purge_session;
  BEGIN
    log_concprogram('Starting to purge synch history data',
		    'asg_download',
		    FND_LOG.LEVEL_STATEMENT);
    l_purge_interval := fnd_profile.VALUE('ASG_SYNCH_HIST_PURGE_PERIOD');
    if( l_purge_interval is null )
    then
      log_concprogram('Synch history purge interval is set to NULL ',
		      'asg_download',
    		      FND_LOG.LEVEL_STATEMENT);
      log_concprogram('Please set profile ASG:Synch Histoy Purge Period to '||
                      'a non-null value and resubmit the concurrent program',
		      'asg_download',
    		      FND_LOG.LEVEL_STATEMENT);
      P_status := 'Warning';
      p_message := 'Profile ASG:Synch Histoy Purge Period is set to null';
      return;
    else
      log_concprogram('Synch history purge interval : '||l_purge_interval,
		      'asg_download',
		      FND_LOG.LEVEL_STATEMENT);

      /*l_qry := 'delete from '||CONS_SCHEMA||'.'||'c$sync_history where '
	       ||' (sysdate-start_time) > '||l_purge_interval||' ';
      log_concprogram('Query : '||l_qry,
		      'asg_download',
		      FND_LOG.LEVEL_STATEMENT);
      EXECUTE IMMEDIATE l_qry;
      l_row_count := SQL%ROWCOUNT;
      log_concprogram('Deleted '||l_row_count||' row(s)',
		      'asg_download',
		      FND_LOG.LEVEL_STATEMENT);
      COMMIT;
      */

      l_row_count := 0;
      l_qry := 'SELECT session_id ' ||
             'FROM ' || CONS_SCHEMA || '.' || 'c$sync_history ' ||
             'WHERE start_time < (trunc(sysdate) - ' || l_purge_interval || ')';
      open c_hist for l_qry;
      LOOP

          if (l_purge_session_data.count > 0 ) then
            l_purge_session_data.delete;
          end if;

          fetch c_hist BULK COLLECT INTO l_purge_session_data LIMIT 100;
          exit when l_purge_session_data.count = 0;

          IF l_purge_session_data.COUNT > 0 THEN
            l_row_count := l_row_count + l_purge_session_data.count;
            begin
             l_qry := 'delete from '||CONS_SCHEMA||'.'||'c$sync_history where ' || ' session_id = :1 ';
             FORALL i IN 1 .. l_purge_session_data.count SAVE EXCEPTIONS
                EXECUTE IMMEDIATE l_qry using l_purge_session_data(i);
            EXCEPTION
            WHEN others THEN
                log_concprogram
                  ('Error occured when deleting from sync history table: '  ||SQLERRM ,
                    'asg_download',
                   FND_LOG.LEVEL_STATEMENT);
            end;
            commit;
          END IF;
      END LOOP;
      close c_hist;

      log_concprogram('Deleted '||l_row_count||' row(s)',
		           'asg_download',
                   FND_LOG.LEVEL_STATEMENT);

      log_concprogram('Done purging synch history data',
		      'asg_download',
		      FND_LOG.LEVEL_STATEMENT);
      UPDATE jtm_con_request_data
      SET last_run_date = SYSDATE
      WHERE package_name = 'ASG_DOWNLOAD'
      AND procedure_name = 'DELETE_SYNCH_HISTORY';
      COMMIT;

      p_status := 'Fine';
      p_message := 'Purging synch history tables completed successfully';
    end if;
    exception
    when others then
      p_status := 'Error';
      p_message := 'Error purging synch history data '||SQLERRM;
      log_concprogram('Error purging synch history data '||SQLERRM,
		    'asg_download',
		    FND_LOG.LEVEL_STATEMENT);
  END delete_synch_history;


  procedure user_incompatibility_test(P_status OUT NOCOPY VARCHAR2,
                                      P_message OUT NOCOPY VARCHAR2)
  is
    cursor c_all_asg_user
    is
      select user_name,user_id,resource_id from asg_user where
      enabled='Y' and nvl(DISABLE_USER_SYNCH,'N') = 'N';
    l_asg_user_rec c_all_asg_user%rowtype;
    cursor c_chk_fnd_user_id(p_user_id number)
    is
      select user_name from fnd_user where user_id = p_user_id;
    l_user_name varchar2(30);
    l_user_id number;
    l_err_msg varchar2(2000);
    cursor c_chk_fnd_user_name(p_user_name varchar2)
    is
      select user_id from fnd_user where user_name = p_user_name;
    cursor c_chk_jtf_resource(p_res_id number)
    is
      select user_name from jtf_rs_resource_extns
      where resource_id = p_res_id
      and  ( trunc(END_DATE_ACTIVE) is null
      or trunc(END_DATE_ACTIVE) > trunc(sysdate) );
  begin
    log('Starting to identify user incompatibility information');
    open c_all_asg_user;
    loop
      fetch c_all_asg_user into l_asg_user_rec;
      exit when c_all_asg_user%notfound;
      log('Processing user name : '||l_asg_user_rec.user_name);
      open c_chk_fnd_user_id(l_asg_user_rec.user_id);
      fetch c_chk_fnd_user_id into l_user_name;
      if (l_user_name is null) then
        /*check if user_id in asg_user exists in fnd_user table */
        l_err_msg := 'The user ID : '||l_asg_user_rec.user_id||
                     ' in asg_user does not exist in fnd_user';
        log(l_err_msg);
        update asg_user
        set DISABLE_USER_SYNCH='Y',DISABLE_SYNCH_ERROR = l_err_msg
        where user_name = l_asg_user_rec.user_name;
      elsif(l_user_name <> l_asg_user_rec.user_name ) then
        /*Check for the user_id in asg_user, the user_name in asg_user
          and fnd_user match*/
        l_err_msg := 'For the user ID : '||l_asg_user_rec.user_id||
                     ' the user names'||
                     ' in asg_user and fnd_user do not match';
        log(l_err_msg);
        update asg_user
        set DISABLE_USER_SYNCH='Y',DISABLE_SYNCH_ERROR = l_err_msg
        where user_name = l_asg_user_rec.user_name;
      else
        /*Check for the user_name in asg_user, the user_id in fnd_user matches*/
        open c_chk_fnd_user_name(l_asg_user_rec.user_name);
        fetch c_chk_fnd_user_name into l_user_id;
        close c_chk_fnd_user_name;
        if(l_user_id <> l_asg_user_rec.user_id ) then
          l_err_msg := 'For the user name : '||l_asg_user_rec.user_name||
                       ' the '||' user ID''s do not match in '||
                       'asg_user and fnd_user ';
          log(l_err_msg);
          update asg_user set DISABLE_USER_SYNCH='Y',DISABLE_SYNCH_ERROR = l_err_msg
          where user_name = l_asg_user_rec.user_name;
        end if;
      end if;
      close c_chk_fnd_user_id;

      l_user_name := NULL;
      open c_chk_jtf_resource(l_asg_user_rec.resource_id);
      fetch c_chk_jtf_resource into l_user_name;
      if(l_user_name is null) then
        /* Check if a record exists in jtf_rs_res* table with the
           same resource_id as asg_user.resource_id*/
        l_err_msg := 'For the resource ID '||l_asg_user_rec.resource_id||' no'||
                     ' record exists in jtf_rs_resource_extns ';
        log(l_err_msg);
        update asg_user
        set DISABLE_USER_SYNCH='Y',DISABLE_SYNCH_ERROR = l_err_msg
        where user_name = l_asg_user_rec.user_name;
      elsif( l_user_name <> l_asg_user_rec.user_name ) then
        /*Check if the resource-name matches asg_user.user_name.*/
        l_err_msg := 'For the resource ID '||l_asg_user_rec.resource_id||
                     ' the user names in asg_user and resource name do not match';
        log(l_err_msg);
        update asg_user
        set DISABLE_USER_SYNCH='Y',DISABLE_SYNCH_ERROR = l_err_msg
        where user_name = l_asg_user_rec.user_name;
      end if;
    close c_chk_jtf_resource;
    end loop;
    close c_all_asg_user;
    commit;
    log('Done identifying user incompatibility information');

    p_status := 'Fine';
    p_message := 'Successfully identified user incompatibility information';
  exception
  when others then
    p_status := 'Error';
    p_message := 'Error identifying user incompatibility information '||SQLERRM;
    log('Error identifying user incompatibility information'||SQLERRM);

  end user_incompatibility_test;

END asg_download;

/
