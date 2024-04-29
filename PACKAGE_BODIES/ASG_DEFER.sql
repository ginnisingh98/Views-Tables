--------------------------------------------------------
--  DDL for Package Body ASG_DEFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_DEFER" AS
/*$Header: asgdfrb.pls 120.2.12010000.4 2009/08/03 10:50:54 saradhak ship $*/

-- DESCRIPTION
--  This package supports deferred transactions.
--
--
-- HISTORY
--   13-jul-2009 saradhak   added commit flag to reapply_txn & discard_txn apis
--   29-Jan-2009 trajasek   Change delete logic in delete deferred
--   15-sep-2004 ssabesan   Changes for delivery notification
--   01-jun-2004 ssabesan   Merge 115.20.1158.4 into main line(11.5.9.6)
--                          Change literal to bind variables.
--   06-jan-2003 ssabesan   Check whether logging is enabled before invoking
--                          logging procedure.
--   23-jul-2002 rsripada   Do not remove deferred rows during reject_row
--   26-jun-2002 rsripada   Remove Olite dependencies
--   31-may-2002 rsripada   Added logging support
--   24-may-2002 rsripada   Implemented reject row
--   17-may-2002 rsripada   Modified defer_row
--   19-feb-2002 rsripada   Created

  -- Defers a row. Returns FND_API.G_RET_STS_SUCCESS if the row was
  -- successfully deferred. FND_API.G_RET_STS_ERROR otherwise. Will
  -- commit any work done as part of this proceduer using autonomous
  -- transaction. sequence is a column in the inq that together with
  -- the user_name, tran_id, pub_item can uniquely identify a record
  -- in the inq.

  g_stmt_level NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_err_level NUMBER := FND_LOG.LEVEL_ERROR;
  g_apply_start_time date;

  function raise_row_deferred(p_user_name VARCHAR2,
                              p_tranid  NUMBER,
                              p_pubitem VARCHAR2,
                              p_sequence  NUMBER,
                              p_error_msg VARCHAR2)
  return boolean
  is
    l_ctx  dbms_xmlquery.ctxType;
    l_clob clob;
    l_seq number;
    l_qry varchar2(2048);
  begin
    if(asg_helper.check_is_log_enabled(g_stmt_level))
    then
      asg_helper.log('Begin raise_row_deferred','asg_defer',g_stmt_level);
    end if;
    l_qry := 'select '''||p_user_name||''' user_name,'''||to_char(p_tranid)
             ||''' tran_id, '''||p_error_msg||''' ERROR_DESCRIPTION ,'
             ||''''||p_pubitem||''' pub_item ,'''||p_sequence||''' SEQUENCE '
             ||' from dual';
    /*l_qry := 'select DEVICE_USER_NAME user_name,DEFERRED_TRAN_ID tran_id ,'
             ||'ERROR_DESCRIPTION ,OBJECT_NAME pub_item,SEQUENCE '
             ||'from asg_deferred_traninfo where CREATION_DATE >= to_date('''
             ||to_char(p_start_time,'mm-dd-yyyy hh24:mi:ss')
             ||''',''mm-dd-yyyy hh24:mi:ss'') ';*/
    if(asg_helper.check_is_log_enabled(g_stmt_level))
    then
      asg_helper.log('Query :'||l_qry,'asg_defer',g_stmt_level);
    end if;
    l_ctx := dbms_xmlquery.newContext(l_qry);
    dbms_lob.createtemporary(l_clob,true,dbms_lob.session);
    l_clob := dbms_xmlquery.getXml(l_ctx);
    if(asg_helper.check_is_log_enabled(g_stmt_level))
    then
      asg_helper.log('Raising event oracle.apps.asg.upload.datadeferred',
                     'asg_defer',g_stmt_level);
    end if;
    select asg_events_s.nextval into l_seq from dual;
    wf_event.raise(p_event_name=>'oracle.apps.asg.upload.datadeferred',
                   p_event_key=>l_seq,p_parameters=>null,
                   p_event_data=>l_clob,p_send_date=>null);
    if(asg_helper.check_is_log_enabled(g_stmt_level))
    then
      asg_helper.log('Successfully raised event oracle.apps.asg.upload.data'
                     ||'deferred','asg_defer',g_stmt_level);
    end if;
    return true;
  exception
  when others then
    asg_helper.log('Error raising oracle.apps.asg.upload.datadeferred :'||SQLERRM,'asg_defer',g_err_level);
    return false;
  end raise_row_deferred;

  PROCEDURE defer_row(p_user_name IN VARCHAR2,
                      p_tranid   IN NUMBER,
                      p_pubitem  IN VARCHAR2,
                      p_sequence  IN NUMBER,
                      p_error_msg IN VARCHAR2,
                      x_return_status OUT NOCOPY VARCHAR2)
            IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_resource_id NUMBER;
  CURSOR c_resource_id (p_user_name VARCHAR2) IS
    SELECT resource_id
    FROM asg_user
    WHERE user_name = p_user_name;
  l_error_msg VARCHAR2(4000);
  l_msg_data  VARCHAR2(2000);
  l_msg_dummy NUMBER;
  l_msg_length PLS_INTEGER;
  l_errmsg_length PLS_INTEGER;
  l_prof_value varchar2(4);
  l_bool_ret boolean;
  l_cp_run varchar2(1);
  BEGIN
   l_cp_run := 'N';
    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) OR
       ((p_pubitem = FND_API.G_MISS_CHAR) OR (p_pubitem IS NULL)) OR
       ((p_sequence = FND_API.G_MISS_NUM) OR (p_sequence IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Construct the error message if it is not passed in
    IF (p_error_msg = FND_API.G_MISS_CHAR) OR
       (p_error_msg IS NULL) THEN
      l_error_msg := 'Error Msg: ';

      FOR j in 1 .. fnd_msg_pub.count_msg LOOP
        fnd_msg_pub.get(j, FND_API.G_FALSE, l_msg_data, l_msg_dummy);
        l_errmsg_length := length(l_error_msg);
        l_msg_length :=  l_errmsg_length + length(l_msg_data);
        IF l_msg_length < 4000 THEN
          l_error_msg := l_error_msg || l_msg_data;
        ELSE
          l_error_msg := l_error_msg ||
                         substr(l_msg_data, 1, 4000-length(l_errmsg_length));
          EXIT;
        END IF;
      END LOOP;

    ELSE
      l_error_msg := p_error_msg;
    END IF;
    select nvl(fnd_profile.value_specific('ASG_ENABLE_UPLOAD_EVENTS'),'N')
    into l_prof_value from dual;
    l_cp_run := asg_apply.is_conc_program_running;

    if(l_prof_value = 'Y')
    then
      if(l_cp_run = 'N' )
      then
        if(asg_helper.check_is_log_enabled(g_stmt_level))
        then
          asg_helper.log('Raising oracle.apps.asg.upload.datadeferred',
                         'asg_defer',g_stmt_level);
        end if;
        l_bool_ret:=raise_row_deferred(p_user_name,p_tranid,p_pubitem,
                                       p_sequence,l_error_msg);
        if(asg_helper.check_is_log_enabled(g_stmt_level))
        then
          asg_helper.log('Done raising oracle.apps.asg.upload.datadeferred',
                         'asg_defer',g_stmt_level);
        end if;
      else
        if(asg_helper.check_is_log_enabled(g_stmt_level))
        then
          asg_helper.log('Not Raising oracle.apps.asg.upload.datadeferred '
                         ||'since call is made from CP','asg_defer',
                         g_stmt_level);
        end if;
      end if;
    else
      if(asg_helper.check_is_log_enabled(g_stmt_level))
      then
        asg_helper.log('Not raising oracle.apps.asg.upload.datadeferred since '
                       ||' the profile '||' ASG_ENABLE_UPLOAD_EVENTS is not '
                       ||'set to ''Y''','asg_defer',g_stmt_level);
       end if;
    end if;
    -- First try to update if that fails, insert.
    -- #$% Should use table handler
    UPDATE asg_deferred_traninfo
    SET failures = failures +1, error_description = l_error_msg,
        last_update_date = SYSDATE
    WHERE device_user_name = p_user_name AND
          deferred_tran_id = p_tranid AND
          object_name = p_pubitem AND
          sequence = p_sequence;
    IF (SQL%ROWCOUNT = 0) THEN
      OPEN c_resource_id(p_user_name);
      FETCH c_resource_id INTO l_resource_id;
      IF c_resource_id%NOTFOUND THEN
        CLOSE c_resource_id;
        x_return_status := FND_API.G_RET_STS_ERROR;
        return;
      END IF;
      CLOSE c_resource_id;
      INSERT INTO asg_deferred_traninfo (DEVICE_USER_NAME,
                                         RESOURCE_ID,
                                         DEFERRED_TRAN_ID,
                                         MOBILE_ERROR_ID,
                                         ERROR_DESCRIPTION,
                                         OBJECT_NAME,
                                         SEQUENCE,
                                         STATUS,
                                         SYNC_TIME,
                                         FAILURES,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATED_BY,
                                         CREATION_DATE,
                                         CREATED_BY)
            VALUES (p_user_name,
                    l_resource_id,
                    p_tranid,
                    NULL,
                    l_error_msg,
                    p_pubitem,
                    p_sequence,
                    1,
                    NULL,
                    1,
                    SYSDATE,
                    1,
                    SYSDATE,
                    1);
      UPDATE asg_users_inqinfo
      SET deferred = 'Y', processed = 'I',
        last_update_date = SYSDATE, last_updated_by = 1
      WHERE device_user_name = p_user_name AND
        tranid = p_tranid;
    END IF;
    COMMIT;
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('defer_row: Deferred a row for user: '|| p_user_name ||
                     ' tranid: ' || p_tranid || ' publication item: ' ||
                     p_pubitem || ' and sequence: ' || p_sequence,
                     'asg_defer',g_stmt_level);
    END IF;

  END defer_row;

  -- Removes the deferred row from inq and removes references
  -- to it as a deferred row.
  PROCEDURE purge_deferred_rows(p_user_name IN VARCHAR2,
                                p_tranid   IN NUMBER,
                                p_pubitem  IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2)
            IS
  inq_tbl_name VARCHAR2(30);
  sql_string VARCHAR2(512);
  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    inq_tbl_name := 'CFM$' || p_pubitem;
    sql_string :=  'DELETE FROM '|| asg_base.G_OLITE_SCHEMA ||
                   '.' || inq_tbl_name ||
                   ' WHERE clid$$cs = :1 AND ' ||
                   ' tranid$$ =:2';
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('purge_deferred_rows: SQL Command: ' || sql_string,
                     'asg_defer',g_stmt_level);
    END IF;
    BEGIN
      EXECUTE IMMEDIATE sql_string
      USING p_user_name, p_tranid;
    EXCEPTION
    WHEN OTHERS THEN
      -- Ignore exceptions
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF(asg_helper.check_is_log_enabled(g_err_level))
      THEN
        asg_helper.log('purge_deferred_rows: Exception: ',
                       'asg_defer', g_err_level);
      END IF;
    END;

    -- Delete any reference in asg_deferred_traninfo
    -- #$% Should use table handler
    -- Should also optimize based on whether tranid is deferred or not
    BEGIN
      DELETE FROM asg_deferred_traninfo
      WHERE device_user_name = p_user_name AND
        deferred_tran_id = p_tranid AND
        object_name = p_pubitem;
    EXCEPTION
    WHEN OTHERS THEN
      -- Ignore exceptions
      IF(asg_helper.check_is_log_enabled(g_err_level))
      THEN
        asg_helper.log('purge_deferred_rows: Exception: ' || SQLERRM,
                       'asg_defer', g_err_level);
      END IF;
    END;
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('purge_deferred_rows: ' ||
                     'Deleted deferred rows for user: '||
                     p_user_name ||
                     ' tranid: ' || p_tranid || ' publication item: ' ||
                     p_pubitem,
                     'asg_defer',g_stmt_level);
    END IF;
  END purge_deferred_rows;


  -- Removes the deferred row from inq and removes references
  -- to it as a deferred row.
  PROCEDURE delete_deferred_row_internal(p_user_name IN VARCHAR2,
                                p_tranid   IN NUMBER,
                                p_pubitem  IN VARCHAR2,
                                p_sequence  IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2)
            IS
  inq_tbl_name VARCHAR2(30);
  sql_string VARCHAR2(512);
  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    inq_tbl_name := 'CFM$' || p_pubitem;
    sql_string :=  'DELETE FROM ' || asg_base.G_OLITE_SCHEMA ||
                   '.' || inq_tbl_name ||
                   ' WHERE clid$$cs = :1 AND ' ||
                   ' tranid$$ = :2 AND ' ||
                   ' seqno$$ = :3';
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('delete_deferred_row_internal: SQL Command: ' || sql_string,
                     'asg_defer',g_stmt_level);
    END IF;
    BEGIN
      EXECUTE IMMEDIATE sql_string
      USING p_user_name, p_tranid, p_sequence;
    EXCEPTION
    WHEN OTHERS THEN
      -- Ignore exceptions
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF(asg_helper.check_is_log_enabled(g_err_level))
      THEN
        asg_helper.log('delete_deferred_row_internal: Exception: ',
                       'asg_defer', g_err_level);
      END IF;
    END;

    -- Delete any reference in asg_deferred_traninfo
    -- #$% Should use table handler
    -- Should also optimize based on whether tranid is deferred or not
    BEGIN
      DELETE FROM asg_deferred_traninfo
      WHERE device_user_name = p_user_name AND
        deferred_tran_id = p_tranid AND
        object_name = p_pubitem AND
        sequence = p_sequence;
    EXCEPTION
    WHEN OTHERS THEN
      -- Ignore exceptions
      IF(asg_helper.check_is_log_enabled(g_err_level))
      THEN
        asg_helper.log('delete_deferred_row_internal: Exception: ' || SQLERRM,
                       'asg_defer', g_err_level);
      END IF;
    END;
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('delete_deferred_row_internal: ' ||
                     'Deleted a deferred row for user: '||
                     p_user_name ||
                     ' tranid: ' || p_tranid || ' publication item: ' ||
                     p_pubitem || ' and sequence: ' || p_sequence,
                     'asg_defer',g_stmt_level);
    END IF;

  END delete_deferred_row_internal;

  -- Removes the deferred row from inq and removes references
  -- to it as a deferred row.
  PROCEDURE delete_deferred_row(p_user_name IN VARCHAR2,
                                p_tranid   IN NUMBER,
                                p_pubitem  IN VARCHAR2,
                                p_sequence  IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2)
            IS
  l_deferred_row VARCHAR2(1);
  BEGIN
    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) OR
       ((p_pubitem = FND_API.G_MISS_CHAR) OR (p_pubitem IS NULL)) OR
       ((p_sequence = FND_API.G_MISS_NUM) OR (p_sequence IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    l_deferred_row := asg_defer.is_deferred(p_user_name, p_tranid,
                                            p_pubitem, p_sequence);
    -- Row is not deferred do not delete.
    IF l_deferred_row = FND_API.G_FALSE THEN
      IF(asg_helper.check_is_log_enabled(g_err_level))
      THEN
        asg_helper.log('delete_deferred_row: Row is not deferred. Returning...',
                       'asg_defer',g_err_level);
      END IF;
      return;
    END IF;

    delete_deferred_row_internal(p_user_name, p_tranid, p_pubitem,
                                 p_sequence, x_return_status);

  END delete_deferred_row;

  -- Marks this records for delete in the client's Olite database.
  PROCEDURE reject_row(p_user_name IN VARCHAR2,
                       p_tranid   IN NUMBER,
                       p_pubitem  IN VARCHAR2,
                       p_sequence  IN NUMBER,
                       p_error_msg IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2)
            IS
  l_ret_status BOOLEAN;
  l_def_trans  VARCHAR2(1);
  BEGIN
    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) OR
       ((p_pubitem = FND_API.G_MISS_CHAR) OR (p_pubitem IS NULL)) OR
       ((p_sequence = FND_API.G_MISS_NUM) OR (p_sequence IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_ret_status := asg_download.markdirty(p_pubitem, p_user_name,
                      p_tranid, p_sequence);
    IF (l_ret_status = FALSE) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF(asg_helper.check_is_log_enabled(g_err_level))
      THEN
        asg_helper.log('reject_row: Error in call to markdirty',
                        'asg_defer', g_err_level);
      END IF;
      RETURN;
    END IF;

    -- Check if this transaction is deferred
    l_def_trans := is_deferred(p_user_name, p_tranid, p_pubitem, p_sequence);
    IF l_def_trans = FND_API.G_FALSE THEN
      -- Delete the row from inq
      asg_apply.delete_row(p_user_name, p_tranid, p_pubitem, p_sequence,
                           x_return_status);
    END IF;
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('reject_row: rejected a row for user: '|| p_user_name ||
                     ' tranid: ' || p_tranid || ' publication item: ' ||
                     p_pubitem || ' and sequence: ' || p_sequence,
                     'asg_defer',g_stmt_level);
    END IF;
  END reject_row;

  -- Returns FND_API.G_TRUE if the transaction is deferred
  FUNCTION is_deferred(p_user_name IN VARCHAR2,
                       p_tranid   IN NUMBER)
           RETURN VARCHAR2 IS
  l_retcode VARCHAR2(1);
  l_user_name VARCHAR2(30);
  CURSOR c_isdeferred(p_user_name VARCHAR2, p_tranid NUMBER) IS
    SELECT device_user_name
    FROM asg_users_inqinfo
    WHERE device_user_name = p_user_name AND
      tranid = p_tranid AND
      deferred <> 'N';
  BEGIN

    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) THEN
      return FND_API.G_FALSE;
    END IF;

    l_retcode := FND_API.G_TRUE;
    OPEN c_isdeferred(p_user_name, p_tranid);
    FETCH c_isdeferred INTO l_user_name;
    IF c_isdeferred%NOTFOUND THEN
      l_retcode := FND_API.G_FALSE;
    END IF;
    CLOSE c_isdeferred;
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('is_deferred: ' || p_user_name || ' transaction: ' ||
                     p_tranid || ' is deferred: ' || l_retcode,
                     'asg_defer',g_stmt_level);
    END IF;
    return l_retcode;

  END is_deferred;

  -- Returns FND_API.G_TRUE if the record is deferred
  FUNCTION is_deferred(p_user_name IN VARCHAR2,
                       p_tranid   IN NUMBER,
                       p_pubitem  IN VARCHAR2,
                       p_sequence  IN NUMBER)
          RETURN VARCHAR2 IS
  l_retcode VARCHAR2(1);
  l_user_name VARCHAR2(30);
  CURSOR c_isdeferred(p_user_name VARCHAR2, p_tranid NUMBER,
                      p_pubitem VARCHAR2, p_sequence NUMBER) IS
    SELECT device_user_name
    FROM asg_deferred_traninfo
    WHERE device_user_name = p_user_name AND
      deferred_tran_id = p_tranid AND
      object_name = p_pubitem AND
      sequence = p_sequence;
  BEGIN

    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) OR
       ((p_pubitem = FND_API.G_MISS_CHAR) OR (p_pubitem IS NULL)) OR
       ((p_sequence = FND_API.G_MISS_NUM) OR (p_sequence IS NULL)) THEN
      return FND_API.G_FALSE;
    END IF;

    l_retcode := FND_API.G_TRUE;
    OPEN c_isdeferred(p_user_name, p_tranid, p_pubitem, p_sequence);
    FETCH c_isdeferred INTO l_user_name;
    IF c_isdeferred%NOTFOUND THEN
      l_retcode := FND_API.G_FALSE;
    END IF;
    CLOSE c_isdeferred;
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('is_deferred: ' || p_user_name || ' transaction: ' ||
                     p_tranid || ' and for publication item: ' || p_pubitem ||
                     ' and sequence: ' || p_sequence ||
                     ' is deferred: ' || l_retcode,
                     'asg_defer',g_stmt_level);
    END IF;

    return l_retcode;
  END is_deferred;

  -- Set transaction status to discarded
  PROCEDURE discard_transaction(p_user_name IN VARCHAR2,
                                p_tranid   IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2)
            IS
  BEGIN

    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    UPDATE asg_users_inqinfo
    SET deferred = 'D'
    WHERE device_user_name = p_user_name AND
          tranid = p_tranid;
    COMMIT;
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('discard_transaction: Setting user: '||p_user_name ||
                     ' transaction: ' || p_tranid || ' to discarded status.',
                     'asg_defer',g_stmt_level);
    END IF;
  END discard_transaction;

  -- Discard the specified deferred row
  PROCEDURE discard_transaction(p_user_name IN VARCHAR2,
                                p_tranid   IN NUMBER,
                                p_pubitem  IN VARCHAR2,
                                p_sequence  IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                p_commit_flag IN BOOLEAN)
            IS
  l_def_count PLS_INTEGER;
  CURSOR c_deferred_discarded (p_user_name VARCHAR2, p_tranid NUMBER) IS
    SELECT count(*) count
    FROM asg_deferred_traninfo
    WHERE device_user_name = p_user_name AND
          deferred_tran_id = p_tranid;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    delete_deferred_row(p_user_name, p_tranid, p_pubitem,
                        p_sequence, x_return_status);

    OPEN c_deferred_discarded(p_user_name, p_tranid);
    FETCH c_deferred_discarded INTO l_def_count;
    CLOSE c_deferred_discarded;

    -- If All the deferred records are discarded
    -- then set the state to discarded
    IF l_def_count = 0 THEN
      UPDATE asg_users_inqinfo
      SET deferred = 'D'
      WHERE device_user_name = p_user_name AND
            tranid = p_tranid;
    END IF;

    IF p_commit_flag THEN
     COMMIT;
    END IF;
  END discard_transaction;

  -- Reapply the given transaction
  PROCEDURE reapply_transaction(p_user_name IN VARCHAR2,
                                p_tranid IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                p_commit_flag IN BOOLEAN)
            IS
  counter PLS_INTEGER;
  sql_string VARCHAR2(4000);
  l_pub_handler asg_pub.wrapper_name%type;
  l_pubname VARCHAR2(30);
  l_pubitems_tbl asg_apply.vc2_tbl_type;
  l_def_trans VARCHAR2(1);
  l_return_status VARCHAR2(1);
  l_pubs_tbl asg_apply.vc2_tbl_type;
  l_pubhandlers_tbl asg_apply.vc2_tbl_type;
  l_def_count NUMBER;
  l_user_id   NUMBER;
  l_resp_id   NUMBER;
  l_app_id    NUMBER;
  l_orig_user_id NUMBER;
  l_orig_resp_id NUMBER;
  l_orig_app_id  NUMBER;
  CURSOR c_pub_wrapper(p_user_name VARCHAR2, p_tranid NUMBER) IS
    SELECT distinct a.wrapper_name, a.name
    FROM asg_pub a, asg_pub_item b, asg_deferred_traninfo c
    WHERE device_user_name = p_user_name AND
          deferred_tran_id = p_tranid AND
          c.object_name = b.name AND
          b.pub_name = a.name
    ORDER BY a.name;
  CURSOR c_deferred_processed (p_user_name VARCHAR2, p_tranid NUMBER) IS
    SELECT count(*) count
    FROM asg_deferred_traninfo
    WHERE device_user_name = p_user_name AND
          deferred_tran_id = p_tranid AND
          status <> 0;
  BEGIN
    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    -- Check if this transaction is deferred
    l_def_trans := is_deferred(p_user_name, p_tranid);
    IF l_def_trans = FND_API.G_FALSE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get all the publications that have deferred pub items
    counter :=1;
    FOR cpw in c_pub_wrapper(p_user_name, p_tranid) LOOP
      l_pubhandlers_tbl(counter) := cpw.wrapper_name;
      l_pubs_tbl(counter) := cpw.name;
      counter := counter +1;
    END LOOP;

    IF counter >1 THEN
      FOR curr_index in 1..l_pubs_tbl.count LOOP

        l_pubname := l_pubs_tbl(curr_index);
        l_pub_handler := l_pubhandlers_tbl(curr_index);
        IF(asg_helper.check_is_log_enabled(g_stmt_level))
        THEN
          asg_helper.log('reapply_transaction: user: ' || p_user_name ||
                         ' transaction id: ' || p_tranid ||
                         ' current pub : ' || l_pubname ||
                         ' current pub handler: ' || l_pub_handler,
                         'asg_defer',g_stmt_level);
        END IF;
        l_pubitems_tbl := asg_apply.g_empty_vc2_tbl;
        asg_apply.get_all_pub_items(p_user_name, p_tranid, l_pubname,
                       l_pubitems_tbl, l_return_status);
        -- Check if there is any data for this publication
        IF (l_return_status = FND_API.G_RET_STS_SUCCESS) AND
           (l_pubitems_tbl.count >0) THEN
	   IF(asg_helper.check_is_log_enabled(g_stmt_level))
           THEN
             asg_helper.log('reapply_transaction: Calling handler package',
                            'asg_defer',g_stmt_level);
           END IF;
          sql_string := 'begin ' ||
                     l_pub_handler || '.apply_client_changes( ''' ||
                     p_user_name || ''',' || p_tranid || '); ' ||
                    'end;';
          BEGIN
            l_orig_user_id := fnd_global.user_id();
            l_orig_resp_id := fnd_global.resp_id();
            l_orig_app_id  := fnd_global.resp_appl_id();

            SELECT user_id INTO l_user_id
            FROM asg_user
            WHERE user_name = p_user_name;

            SELECT responsibility_id, app_id INTO  l_resp_id, l_app_id
            FROM asg_user_pub_resps
            WHERE user_name = p_user_name AND
                  pub_name = l_pubname;

            fnd_global.apps_initialize(l_user_id, l_resp_id, l_app_id);
            EXECUTE IMMEDIATE sql_string;
            fnd_global.apps_initialize(l_orig_user_id, l_orig_resp_id,
                                       l_orig_app_id);
          EXCEPTION
          WHEN OTHERS THEN
            IF(asg_helper.check_is_log_enabled(g_err_level))
            THEN
              asg_helper.log('reapply_transaction: Exception in ' ||
                             'wrapper call. Check if valid wrapper exists',
                             'asg_defer',g_err_level);
            END IF;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            fnd_global.apps_initialize(l_orig_user_id, l_orig_resp_id,
                                       l_orig_app_id);
            return;
          END;
        ELSE
          IF(asg_helper.check_is_log_enabled(g_stmt_level))
          THEN
	    asg_helper.log('No pubitems from publication: ' ||
                           l_pubname || ' to process',
			   'asg_defer',g_stmt_level);
         END IF;
        END IF;
      END LOOP;
    END IF;

    OPEN c_deferred_processed(p_user_name, p_tranid);
    FETCH c_deferred_processed INTO l_def_count;
    CLOSE c_deferred_processed;
    -- All the deferred records are processed
    IF l_def_count = 0 THEN
      UPDATE asg_users_inqinfo
      SET deferred = 'S'
      WHERE device_user_name = p_user_name AND
            tranid = p_tranid;
    END IF;

    IF p_commit_flag THEN
     COMMIT;
    END IF;
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('reapply_transaction: Done reapplying the transaction',
                     'asg_defer',g_stmt_level);
    END IF;
  END reapply_transaction;

  -- Purge all the inq entries
  PROCEDURE purge_transaction(p_user_name IN VARCHAR2,
                              p_tranid IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2)
            IS
  l_def_trans VARCHAR2(1);
  l_curr_pubitem VARCHAR2(30);
  l_pubitems_tbl asg_apply.vc2_tbl_type;
  l_return_status VARCHAR2(1);
  BEGIN
    IF ((p_user_name = FND_API.G_MISS_CHAR) OR (p_user_name IS NULL)) OR
       ((p_tranid = FND_API.G_MISS_NUM) OR (p_tranid IS NULL)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

    -- Check if this transaction is deferred
    l_def_trans := is_deferred(p_user_name, p_tranid);
    IF l_def_trans = FND_API.G_FALSE THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('purge_transaction: Purging user: ' || p_user_name ||
                     ' transaction: ' || p_tranid,
		     'asg_defer',g_stmt_level);
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    asg_apply.get_all_pub_items(p_user_name, p_tranid,
                      l_pubitems_tbl, l_return_status);
    -- Check if there is any data for this publication
    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) AND
       (l_pubitems_tbl.count >0) THEN
      FOR curr_index in 1..l_pubitems_tbl.count LOOP
        l_curr_pubitem := l_pubitems_tbl(curr_index);
	IF(asg_helper.check_is_log_enabled(g_stmt_level))
        THEN
          asg_helper.log('purge_transaction: Purging pub item : '||
                         l_curr_pubitem || ' entries',
			 'asg_defer',g_stmt_level);
        END IF;
        purge_deferred_rows(p_user_name, p_tranid,
                            l_curr_pubitem, l_return_status);
      END LOOP;
   END IF;

   UPDATE asg_users_inqarchive
   SET processed = 'Y', deferred = 'Y',
       last_update_date = SYSDATE, last_updated_by = 1
   WHERE device_user_name = p_user_name AND
         tranid = p_tranid;

   DELETE FROM asg_users_inqinfo
   WHERE device_user_name = p_user_name AND tranid = p_tranid;
   COMMIT;
   IF(asg_helper.check_is_log_enabled(g_stmt_level))
   THEN
     asg_helper.log('purge_transaction: Done purging all items in this transaction',
                    'asg_defer',g_stmt_level);
   END IF;
  END purge_transaction;

  -- Delete rows in asg_deferred_traninfo/asg_users_inqinfo with no data in INQ.
  PROCEDURE delete_deferred(p_status OUT NOCOPY VARCHAR2,
                            p_message OUT NOCOPY VARCHAR2)
    IS
  CURSOR c_deferred_lines
    IS
    select distinct def.object_name,pub.enabled
    from asg_deferred_traninfo def,
         asg_pub_item pub
    where pub.item_id = def.object_name;

  l_sql             VARCHAR2(512);
  l_row_count       NUMBER;
  l_inq_table_name  VARCHAR2(128);
  BEGIN


    IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
       asg_helper.log('delete_deferred: Entering asg_defer.delete_deferred.',
                      'asg_defer',g_stmt_level);
    END IF;

    FOR cdl in c_deferred_lines LOOP

      IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
         asg_helper.log('delete_deferred: Processing object: ' || cdl.object_name,
                        'asg_defer',g_stmt_level);
      END IF;
      IF cdl.enabled = 'Y' THEN
        l_inq_table_name := asg_base.G_OLITE_SCHEMA || '.CFM$' || cdl.object_name;
        l_sql := 'DELETE FROM asg_deferred_traninfo ' ||
                 'WHERE object_name = :1  AND ' ||
                 '(device_user_name, deferred_tran_id, sequence) NOT IN ' ||
                 '   (SELECT clid$$cs, tranid$$, seqno$$ ' ||
                 '    FROM ' || l_inq_table_name || ' )';

        IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
           asg_helper.log('delete_deferred: SQL Command:  ' || l_sql,
                        'asg_defer',g_stmt_level);
        END IF;

        EXECUTE IMMEDIATE l_sql USING cdl.object_name;
        l_row_count := SQL%ROWCOUNT;

      ELSE --For disable pub items blindly delete from asg deferred traninfo table
        DELETE FROM asg_deferred_traninfo WHERE object_name = cdl.object_name;
        l_row_count := SQL%ROWCOUNT;

        IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
           asg_helper.log('delete_deferred: for the PIV  that is disabled ' || cdl.object_name,
                        'asg_defer',g_stmt_level);
        END IF;

      END IF;

      IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
         asg_helper.log('delete_deferred: : Deleted ' || l_row_count || ' row(s)',
                        'asg_defer',g_stmt_level);
      END IF;

      -- Commit after each object.
      COMMIT;

    END LOOP;

    -- Delete any deferred headers
    DELETE FROM asg_users_inqinfo
    WHERE (device_user_name, tranid) NOT IN
          (SELECT device_user_name, deferred_tran_id
           FROM asg_deferred_traninfo);

    COMMIT;

    p_status := 'Fine';
    p_message := 'Purging deferred transaction metadata completed successfully.';
    IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
       asg_helper.log('delete_deferred: Exiting asg_defer.delete_deferred.',
                      'asg_defer',g_stmt_level);
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    p_status := 'Error';
    p_message := 'Error deleting deferred transaction metadata.';
    IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
       asg_helper.log('delete_deferred: Error Message: ' || SQLERRM,
                      'asg_defer',g_stmt_level);
    END IF;

  END delete_deferred;

END asg_defer;

/
