--------------------------------------------------------
--  DDL for Package Body ASG_CONS_QPKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_CONS_QPKG" AS
/*$Header: asgconqb.pls 120.4.12010000.3 2009/08/17 06:00:25 saradhak ship $*/

-- DESCRIPTION
--  This package contains callbacks registered with Oracle Lite
--
--
-- HISTORY
--   12-aug-2009 saradhak   Process Synchronous Mobile queries in upload_complete
--   15-May-2008 saradhak   12.1- Auto Sync
--   01-jun-2004 ssabesan   Fix bug 3666810
--   01-jun-2004 ssabesan   Merge 115.24.1158.29 to main line(11.5.9.6)
--                          Change literal to bind variables.
--   26-mar-2004 rsripada   Fix bug 3536657
--   19-mar-2004 ssabesan   Fix bug 3518589
--   04-jan-2004 ssabesan   changed the method process_compref_table
--   27-jan-2004 ssabesan   Comment off the code in populate_q_rec_count
--   01-oct-2003 ssabesan   Purge SDQ changes (bug 3170790)
--   12-jun-2003 rsripada   Added support to store device type
--   10-apr-2003 ssabesan   use last_wireless_contact_date for error logging
--   31-mar-2003 rsripada   Fix Online-query bug: 2878674
--   28-mar-2003 rsripada   Store synctime end in asg_user table
--   25-mar-2003 ssabesan   update synch_errors column with synch time errors
--   25-feb-2003 rsripada   Added validate_login method
--   24-feb-2003 rsripada   update hwm_tranid so that it can handle
--                          exceptions in download
--   19-feb-2003 pkanukol   Support for processing asg_purge_sdq at synch time
--   11-feb-2003 rsripada   Support for conflict detection
--   10-feb-2003 rsripada   change asg_disable_custom
--                          to asg_disable_custom_synch
--   06-jan-2003 ssabesan   Added NOCOPY in function definition
--   06-jan-2003 ssabesan   Check whether logging is enabled before invoking
--                          logging procedure.
--   12-dec-2002 rsripada   Added support to disable download of custom pis
--   11-nov-2002 ssabesan   added code for pub items upgrade
--   04-oct-2002 ssabesan   commented out logging in download size estimate
--                          procedures
--   09-sep-2002 rsripada   Raise exception if an user synch is disabled
--   06-sep-2002 ssabesan   added code for determining num of rows downloaded
--   17-jul-2002 rsripada   Raise exception in upload for any errors
--   27-jun-2002 rsripada   Added support for UI to track synch errors
--   26-jun-2002 rsripada   Remove Olite dependencies
--   29-may-2002 rsripada   Logging Support
--   24-may-2002 rsripada   Added sequence processing during upload
--   15-may-2002 rsripada   Modified download_init
--   14-may-2002 vekrishn   Increased the mesg in LOG to 4000
--   25-apr-2002 rsripada   Added final api for download_init
--   16-apr-2002 rsripada   Created

  g_stmt_level            NUMBER      := FND_LOG.LEVEL_STATEMENT;
  g_err_level             NUMBER      := FND_LOG.LEVEL_ERROR;

  g_first_synch           BOOLEAN     := FALSE;
  g_auto_synch            CHAR        := 'N';
  g_last_synch_successful VARCHAR2(1) := FND_API.G_TRUE;
  g_device_type           VARCHAR2(30):= NULL;

  PROCEDURE get_pubitem_list(p_pubitem_tbl IN OUT NOCOPY asg_base.pub_item_tbl_type)
            IS
  counter                 PLS_INTEGER;
  l_cursor_id             NUMBER;
  l_cursor_ret            NUMBER;
  l_select_pi_sqlstring   VARCHAR2(4000);
  l_pubitem_name          VARCHAR2(30);
  l_comp_ref              VARCHAR2(1);
  BEGIN
    --set the pub item table to empty
    p_pubitem_tbl:=asg_base.g_empty_pub_item_tbl;
    l_select_pi_sqlstring :=
                    'SELECT name, comp_ref ' ||
                    'FROM ' || asg_base.G_OLITE_SCHEMA ||'.' ||'c$pub_list_q';

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id, l_select_pi_sqlstring, DBMS_SQL.v7);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 1, l_pubitem_name, 30);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 2, l_comp_ref, 1);

    l_cursor_ret := DBMS_SQL.EXECUTE (l_cursor_id);
    counter := 1;
    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0 ) LOOP
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 1, l_pubitem_name);
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 2, l_comp_ref);
      p_pubitem_tbl(counter).name     := l_pubitem_name;
      p_pubitem_tbl(counter).comp_ref := l_comp_ref;
      counter := counter +1;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

  END get_pubitem_list;

  FUNCTION is_previous_synch_successful(p_user_name IN VARCHAR2,
                                        p_last_tranid IN NUMBER)
           RETURN VARCHAR2 IS
  l_stored_last_tranid NUMBER;
  BEGIN
    SELECT nvl(last_tranid, 0) into l_stored_last_tranid
    FROM asg_user
    WHERE user_name = p_user_name;

    IF (p_last_tranid > l_stored_last_tranid) THEN
      return FND_API.G_TRUE;
    ELSE
      return FND_API.G_FALSE;
    END IF;

  END is_previous_synch_successful;


--12.1
  PROCEDURE insert_auto_sync_tranids(p_user_name IN VARCHAR2,
                                    p_upload_tranid IN NUMBER)
  IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
      insert into asg_auto_sync_tranids
      (user_name, upload_tranid, sync_id,
       creation_date, created_by, last_update_date, last_updated_by )
      values
      (p_user_name, p_upload_tranid, NULL, sysdate,1, sysdate,1);
    COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
  END insert_auto_sync_tranids;

--12.1
  FUNCTION set_sync_id (p_user_name IN VARCHAR2,
                        p_upload_tranid IN NUMBER)
  RETURN NUMBER
  IS  --PRAGMA AUTONOMOUS_TRANSACTION;
   CURSOR c_sync_id(b_user_name VARCHAR2)
   IS
   SELECT MAX(upload_tranid)
   FROM asg_auto_sync_tranids
   WHERE USER_NAME=b_user_name
   AND SYNC_ID IS NULL;

  l_sync_id NUMBER;

  BEGIN

    IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
      asg_helper.log('Entering set_sync_id:  Clientid: ' ||
                     p_user_name || ' tranid: ' || p_upload_tranid,
                     'asg_cons_qpkg',g_stmt_level);
    END IF;

    IF p_upload_tranid IS NULL THEN
     OPEN c_sync_id(p_user_name);
     FETCH c_sync_id INTO l_sync_id;
     CLOSE c_sync_id;
    ELSE
     l_sync_id:=p_upload_tranid;
    END IF;

    UPDATE asg_auto_sync_tranids SET SYNC_ID= l_sync_id
    WHERE USER_NAME=p_user_name
	AND SYNC_ID IS NULL;
--    COMMIT;

    RETURN l_sync_id;
  EXCEPTION
  WHEN OTHERS THEN
--    ROLLBACK;
    RETURN l_sync_id;
  END set_sync_id;


  -- Notifies that inq has a new transaction
  PROCEDURE upload_complete(p_clientid IN VARCHAR2,
  	                    p_tranid IN NUMBER)
            IS
  l_return_status          VARCHAR2(1);
  l_sqlerror_message VARCHAR2(512);
  l_disabled_synch_message VARCHAR2(2000);
  synch_disabled EXCEPTION;
  BEGIN
    -- This call will be made after all the uploaded data is committed.
    -- Since during apply processing we account for the case when sync
    -- fails after commit and before this call completed, we do not need
    -- to do any processing.
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('Upload complete called for client: ' ||
                     p_clientid || ' tranid: ' || p_tranid,
                     'asg_cons_qpkg',g_stmt_level);
    END IF;

    BEGIN
      -- Check if user's synch is disabled
      IF asg_helper.is_user_synch_enabled(p_clientid,l_disabled_synch_message)
                     = FND_API.G_FALSE THEN
        raise synch_disabled;
      END IF;
      asg_base.set_upload_tranid(p_tranid);
      --set hwm_tranid  to tranid-1 and make synch_errors null
      -- Moved to download_init Because we shouldn't process uploads when it is in auto sync
      -- asg_helper.set_synch_errmsg(p_clientid,(p_tranid-1),null,null);

      asg_apply.process_sequences(p_clientid, p_tranid, l_return_status);

	  asg_apply.process_mobile_queries(p_clientid, p_tranid, l_return_status);

      asg_apply.setup_inq_info(p_clientid, p_tranid, l_return_status);
--12.1
      insert_auto_sync_tranids(p_clientid, p_tranid);
      COMMIT;
    EXCEPTION
    WHEN synch_disabled THEN
      IF(asg_helper.check_is_log_enabled(g_err_level))
      THEN
        asg_helper.log('User Synch Error: ' || p_clientid || ' ' ||
                       to_char(sysdate, 'yyyy-mm-dd') ||
                       ' Synch is not enabled.',
		       'asg_cons_qpkg',g_err_level);
      END IF;
      IF l_disabled_synch_message IS NULL THEN
        l_disabled_synch_message := 'Synch is not enabled.';
      END IF;
      asg_helper.set_synch_errmsg(p_clientid,null,g_device_type,
				  'User Synch Error: '||l_disabled_synch_message);
      RAISE_APPLICATION_ERROR(-20994, l_disabled_synch_message);
    WHEN OTHERS THEN
      l_sqlerror_message := SQLERRM;
      IF(asg_helper.check_is_log_enabled(g_err_level))
      THEN
        asg_helper.log(
           'User Synch Error: ' || p_clientid || ' ' ||
           to_char(sysdate, 'yyyy-mm-dd') ||
           ' Exception in upload_complete. ' || l_sqlerror_message,
           'asg_cons_qpkg', g_err_level);
      END IF;
      asg_helper.set_synch_errmsg(p_clientid,null,g_device_type,
                                  'User Synch Error: ' ||
                                  ' Exception in upload_complete. ' ||
				  l_sqlerror_message);
      RAISE_APPLICATION_ERROR(-20995, 'Exception during upload ' ||
                              l_sqlerror_message);
    END;
  END upload_complete;

  -- Initialize data for download
  -- Final API
  PROCEDURE download_init(p_clientid IN VARCHAR2,
                          p_last_tranid IN NUMBER,
                          p_curr_tranid IN NUMBER,
                          p_high_prty IN VARCHAR2)
            IS
  l_upload_tranid NUMBER;
  l_last_synch_date          DATE;
  l_first_synch              BOOLEAN;
  l_disabled_synch_message VARCHAR2(2000);
  l_sqlerror_message VARCHAR2(512);
  synch_disabled   EXCEPTION;
  password_expired EXCEPTION;
  l_pub_item_tbl asg_base.pub_item_tbl_type;
  l_bool_ret BOOLEAN;
  l_ret_msg varchar2(512);
  l_pwd_expired VARCHAR2(1);
  l_is_auto_sync   VARCHAR2(1);
  l_is_download_only_sync VARCHAR2(1);
  l_sync_id NUMBER;
  BEGIN
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('Start Download ' || p_clientid ||
                     ' last tranid: ' || p_last_tranid ||
		     ' current tranid: ' || p_curr_tranid,
		     'asg_cons_qpkg',g_stmt_level);
    END IF;
    BEGIN
      l_upload_tranid := asg_base.get_upload_tranid();

      -- Set Sync Id only if sync is NORMAL
      -- or not a download only sync
      l_is_auto_sync := asg_base.is_auto_sync();
      l_is_download_only_sync := asg_base.is_download_only_sync(p_clientid, p_curr_tranid);

      asg_helper.log('Auto Sync: ' || l_is_auto_sync || ' and Download only sync: ' || l_is_download_only_sync
		,'asg_cons_qpkg',g_stmt_level);

      IF (l_is_auto_sync = 'N'
	OR l_is_download_only_sync = 'N') THEN
      	l_sync_id:=set_sync_id(p_clientid, l_upload_tranid);
      END IF;

      -- This is relevant only for first synch
      -- Raise error if password has expired.
      -- Subsequent synchs raise error during authentication itself.
      SELECT nvl(password_expired, 'N') into l_pwd_expired
      FROM asg_user
      WHERE user_name = p_clientid;
      IF l_pwd_expired = 'Y' THEN
        raise password_expired;
      END IF;
      -- Check if user's synch is disabled
      IF asg_helper.is_user_synch_enabled(p_clientid,l_disabled_synch_message)
                                         = FND_API.G_FALSE THEN
        raise synch_disabled;
      END IF;
      -- Initialize all the session information except the list of pubitems
      -- to be downloaded
      g_first_synch := asg_download.isFirstSync();
      g_auto_synch := asg_base.is_auto_sync();
      l_last_synch_date := find_last_synch_date(p_clientid,
                                                p_last_tranid);
      g_device_type := find_device_type(p_clientid);
      asg_base.init(p_clientid, p_last_tranid, p_curr_tranid,
                    l_last_synch_date, asg_base.g_empty_pub_item_tbl);

      -- check out if this user needs complete
      -- refresh since he's been a dormant user.
      asg_helper.log('Checking if user: '
		     || p_clientid || ' needs complete refresh.',
		     'asg_cons_qpkg',g_stmt_level);
      process_purge_Sdq(p_clientid, p_last_tranid, p_curr_tranid);

      IF(g_first_synch) THEN
        set_synch_completed(p_clientid);
        delete_row(p_clientid);
        IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
	    asg_helper.log('First synch..deleted all rows from asg_complete_refresh'
	                   ,'asg_cons_qpkg',g_stmt_level);
        END IF;
      ELSE
	process_compref_table(p_clientid,p_last_tranid);
        set_complete_refresh;
      END IF;

      -- Check if customization is disabled
      process_custom_pub_items(p_clientid);

      l_bool_ret := asg_download.processsdq(p_clientid, p_last_tranid,
                                            p_curr_tranid, p_high_prty,
					    l_ret_msg);
      IF l_bool_ret = FALSE THEN
         if l_ret_msg is null
  	     then
           l_sqlerror_message := SQLERRM;
	     else
	       l_sqlerror_message := l_ret_msg;
	     end if;
         IF(asg_helper.check_is_log_enabled(g_err_level))
         THEN
           asg_helper.log('processsdq returned FALSE', 'asg_cons_qpkg',
                          g_err_level);
         END IF;
 	    asg_helper.set_synch_errmsg(p_clientid, null, g_device_type,'Error during download in asg_download.processsdq: '||
			l_sqlerror_message);

        RAISE_APPLICATION_ERROR(-20999, 'Error during download in ' ||
                                'asg_download.processsdq ' ||
                                l_sqlerror_message);
      END IF;

      -- Check for conflicts
      process_conflicts(p_clientid);

--12.1
      -- Start processing uploads when synchronized manually(i.e,not auto sync)
	  -- and when download is successful
        IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
	    asg_helper.log('Set ASG_USER hwm_tranid to '||l_sync_id||' for Process Upload to pick it up.','asg_cons_qpkg',g_stmt_level);
        END IF;
        asg_helper.set_synch_errmsg(p_clientid,l_sync_id,g_device_type, null);
    EXCEPTION

    WHEN synch_disabled THEN
      asg_helper.set_synch_errmsg(
			p_clientid,null,g_device_type,
			'User Synch Error: '||
			nvl(l_disabled_synch_message,'Synch is not enabled.'));

      IF(asg_helper.check_is_log_enabled(g_err_level)) THEN
        asg_helper.log('User Synch Error: ' || p_clientid || ' ' ||
                       to_char(sysdate, 'yyyy-mm-dd') ||
                       ' Synch is not enabled.',
		       'asg_cons_qpkg',g_err_level);
      END IF;
      IF l_disabled_synch_message IS NULL THEN
        l_disabled_synch_message := 'Synch is not enabled.';
      END IF;
      RAISE_APPLICATION_ERROR(-20994, l_disabled_synch_message);
    WHEN password_expired THEN
      asg_helper.set_synch_errmsg(
            p_clientid,null,g_device_type,
            'User Synch Error: User Password Expired.');
      IF(asg_helper.check_is_log_enabled(g_err_level)) THEN
        asg_helper.log('User Synch Error: ' || p_clientid || ' ' ||
                       to_char(sysdate, 'yyyy-mm-dd') ||
                       ' User Password Expired.',
		       'asg_cons_qpkg',g_err_level);
      END IF;
      RAISE_APPLICATION_ERROR(-20993, 'Your password has expired. ' ||
            'Please contact your System Administrator to reset the password.');
    WHEN OTHERS THEN
      l_sqlerror_message := SQLERRM;
      asg_helper.set_synch_errmsg(
			p_clientid,null,g_device_type,
			'User Synch Error: Exception in processsdq '||
			l_sqlerror_message);
      IF(asg_helper.check_is_log_enabled(g_err_level))
      THEN
        asg_helper.log('User Synch Error: ' ||p_clientid || ' ' ||
                       to_char(sysdate, 'yyyy-mm-dd') ||
                       ' transaction-id: ' || p_curr_tranid ||
                       ' Exception in processsdq ' || l_sqlerror_message,
		       'asg_cons_qpkg',g_err_level);
      END IF;
      RAISE_APPLICATION_ERROR(-20998, 'Exception during download ' ||
                              l_sqlerror_message);
    END;

    -- The final pub items list should be in l_pub_item_tbl
    get_pubitem_list(l_pub_item_tbl);

    -- Store the list of pubitems to be refreshed
    asg_base.set_pub_items(l_pub_item_tbl);

    -- Write to log all the session information for this user
    asg_base.print_all_globals();
    asg_helper.log('download_init', 'asg_consq_pkg',g_err_level);
  END download_init;

  -- Notifies when all the client's data is sent
  PROCEDURE download_complete(p_clientid IN VARCHAR2)
            IS
  l_bool_ret BOOLEAN;
  l_last_tranid NUMBER;
  l_sqlerror_message VARCHAR2(512);
  BEGIN
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('Download complete called for client: ' || p_clientid,
                     'asg_cons_qpkg',g_stmt_level);
    END IF;
    --new code
    set_synch_completed(p_clientid);

    BEGIN
      l_bool_ret := asg_download.purgesdq();
      IF l_bool_ret = FALSE THEN
         l_sqlerror_message := SQLERRM;
         IF(asg_helper.check_is_log_enabled(g_err_level))
         THEN
           asg_helper.log('purgesdq returned FALSE',
	                  'asg_cons_qpkg',g_err_level);
         END IF;
        RAISE_APPLICATION_ERROR(-20997, 'Error during download in ' ||
                               'asg_download.purgesdq ' || l_sqlerror_message);
      END IF;

      -- Update the synctime end in asg_user table
      l_last_tranid := asg_base.get_last_tranid();
      IF ((l_last_tranid <= -1) OR
          (g_first_synch = TRUE)) THEN
        UPDATE asg_user
        SET last_tranid = l_last_tranid,
            last_synch_date_end = sysdate,
            prior_synch_date_end = null
        WHERE user_name = p_clientid;
      ELSE
        IF(g_last_synch_successful = FND_API.G_TRUE) THEN
          UPDATE asg_user
          SET last_tranid = l_last_tranid,
              prior_synch_date_end = asg_base.get_last_synch_date(),
              last_synch_date_end = sysdate
          WHERE user_name = p_clientid;
        ELSE
          UPDATE asg_user
          SET last_tranid = l_last_tranid,
              last_synch_date_end = sysdate
          WHERE user_name = p_clientid;
        END IF;
      END IF;
      -- Reset all session information
      asg_base.reset_all_globals();

	IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('Download complete DONE for client: ' || p_clientid,
                     'asg_cons_qpkg',g_stmt_level);
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
      l_sqlerror_message := SQLERRM;
      asg_helper.set_synch_errmsg(
			p_clientid,null,g_device_type,
			'User Synch Error: Exception in purgesdq '||
			l_sqlerror_message);

      IF(asg_helper.check_is_log_enabled(g_err_level))
      THEN
        asg_helper.log('User Synch Error: ' ||p_clientid || ' ' ||
                       to_char(sysdate, 'yyyy-mm-dd') ||
                       ' transaction-id: ' || asg_base.get_current_tranid ||
                       ' Exception in purgesdq ' || l_sqlerror_message,
		       'asg_cons_qpkg',g_err_level);
      END IF;
      -- Reset all session information
      asg_base.reset_all_globals();
      RAISE_APPLICATION_ERROR(-20996, 'Exception during download ' ||
                              l_sqlerror_message);
    END ;
    /**/
    EXCEPTION
    WHEN OTHERS THEN
      l_sqlerror_message := SQLERRM;
      asg_helper.set_synch_errmsg(
			p_clientid,null,g_device_type,
			'User Synch Error: Exception in download_complete '||
			l_sqlerror_message);

      IF(asg_helper.check_is_log_enabled(g_err_level))
      THEN
        asg_helper.log('User Synch Error: ' ||p_clientid || ' ' ||
                       to_char(sysdate, 'yyyy-mm-dd') ||
                       ' transaction-id: ' || asg_base.get_current_tranid ||
                       ' Exception in download_complete ' || l_sqlerror_message,
		       'asg_cons_qpkg',g_err_level);
      END IF;
      -- Reset all session information
      asg_base.reset_all_globals();
      RAISE_APPLICATION_ERROR(-20996, 'Exception during download ' ||
                              l_sqlerror_message);
  END download_complete;

--PROCEDURE FOR FINDING WHETHER FIRST SYNCH OR NOT

  PROCEDURE is_first_synch(p_is_first_synch OUT NOCOPY VARCHAR2)
  IS
  l_rec_count1 NUMBER;
  l_rec_count2 NUMBER;
  l_qry_string1 VARCHAR2(512);
  BEGIN
    l_qry_string1:='select count(*) from '||asg_base.G_OLITE_SCHEMA
                   ||'.c$pub_list_q';
    EXECUTE IMMEDIATE l_qry_string1 into l_rec_count1;
    l_qry_string1:='select count(*) from '||asg_base.G_OLITE_SCHEMA
                   ||'.c$pub_list_q where comp_ref=''Y''';
    EXECUTE IMMEDIATE l_qry_string1 into l_rec_count2;
    IF(l_rec_count1 = l_rec_count2) THEN
      p_is_first_synch:='Y';
    ELSE
      p_is_first_synch:='N';
    END IF;
  END is_first_synch;


--PROCEDURE FOR PERFORMING BATCH UPDATES ON MOBILEADMIN.C$PUB_LIST_Q

  PROCEDURE update_rec_count(p_pubitem_tbl IN asg_base.pub_item_tbl_type,
  			     p_clientid IN VARCHAR2)
  IS
  l_loopvar NUMBER;
  l_qry_string VARCHAR2(1024);
  BEGIN
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('Performing batch update for: '||p_clientid,
       		     'asg_cons_qpkg',g_stmt_level);
    END IF;
    FOR l_loopvar IN 1..p_pubitem_tbl.count
    LOOP
      IF(p_pubitem_tbl(l_loopvar).rec_count is not null OR
         p_pubitem_tbl(l_loopvar).name not like 'C$%')
      THEN
         l_qry_string:='update '||asg_base.G_OLITE_SCHEMA||'.c$pub_list_q '||
	               ' set rec_count= :1 ' ||
	               ' where name = :2';
         EXECUTE IMMEDIATE l_qry_string
         USING p_pubitem_tbl(l_loopvar).rec_count, p_pubitem_tbl(l_loopvar).name;
/*	 asg_helper.log('Update:  '||p_pubitem_tbl(l_loopvar).name||' count: '
	 	        ||p_pubitem_tbl(l_loopvar).rec_count,
			'asg.asg_cons_qpkg');
*/
      END IF;
    END LOOP;
  END update_rec_count;


--PROCEDURE FOR POPULATING rec_count MOBILEADMIN.C$PUB_LIST_Q FOR FIRST TIME SYNCH

  PROCEDURE process_first_synch(p_pubitem_tbl IN asg_base.pub_item_tbl_type,
  			        p_clientid IN VARCHAR2)
  IS
  l_curr_pubitem  VARCHAR2(128);
  l_loopvar NUMBER;
  l_view_name VARCHAR2(128);
  l_owner_name VARCHAR2(128);
  l_total NUMBER;
  l_rec_count1 NUMBER;
  l_qry_string1 VARCHAR2(1024);
  l_qry_string2 VARCHAR2(1024);
  l_pubitem_tbl asg_base.pub_item_tbl_type;

  BEGIN
    l_total:=0;
    l_pubitem_tbl := p_pubitem_tbl;
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('Inside process_first_synch for :'||p_clientid,
		     'asg_cons_qpkg',g_stmt_level);
    END IF;
       asg_base.init(p_clientid,-1,0,null,p_pubitem_tbl);

    FOR l_loopvar in 1..l_pubitem_tbl.count
    LOOP
      l_curr_pubitem:=l_pubitem_tbl(l_loopvar).name;
      IF(l_curr_pubitem like 'C$%')
      THEN
        IF(asg_helper.check_is_log_enabled(g_stmt_level))
        THEN
          asg_helper.log('Ignoring : '||l_curr_pubitem,
			 'asg_cons_qpkg',g_stmt_level);
        END IF;
      ELSE
	select base_object_name,base_owner into l_view_name,l_owner_name
	from asg_pub_item where item_id=l_curr_pubitem;
 	l_curr_pubitem:=l_pubitem_tbl(l_loopvar).name;
        l_qry_string2:='select count(*) from '||l_owner_name||'.'||l_view_name;
        EXECUTE IMMEDIATE l_qry_string2 into l_rec_count1;
	l_total:=l_total+l_rec_count1;
	l_pubitem_tbl(l_loopvar).rec_count:=l_rec_count1;
      END IF;
/*	  asg_helper.log('Pub Name '||l_curr_pubitem||' Count: '||l_rec_count1,
	  		 'asg.asg_cons_qpkg');
*/
    END LOOP;
    update_rec_count(l_pubitem_tbl,p_clientid);
    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('Total num of rows(First time synch): '||l_total,
    		     'asg_cons_qpkg',g_stmt_level);
    END IF;
  END process_first_synch;

  -- Populates the number of records for each publication item downloaded

  PROCEDURE populate_q_rec_count(p_clientid IN VARCHAR2)
  IS
  BEGIN
    null;
  END populate_q_rec_count;


  --routine that sets PI's in c$pub_list_q that have
  --synch_completed (in asg_complete_refresh) set to 'N' for complete refresh
  PROCEDURE set_complete_refresh
    IS
  l_user_name VARCHAR2(30);
  l_qry_string VARCHAR2(1024);
  BEGIN
    l_user_name := asg_base.get_user_name;
    l_qry_string := 'update '||asg_base.G_OLITE_SCHEMA||'.c$pub_list_q '
	    	    ||'set comp_ref = ''Y'' '||' where name IN ('
		    ||'SELECT publication_item FROM asg_complete_refresh '
                    ||' WHERE synch_completed=''N'' AND user_name = :1 '
		    ||' AND publication_item IN '
		    ||' ( SELECT name FROM '||asg_base.G_OLITE_SCHEMA
		    ||'.c$pub_list_q ))' ;
    EXECUTE IMMEDIATE l_qry_string
    USING l_user_name;
  END set_complete_refresh;



  --sets synch_completed flag in asg_complete_refresh to 'Y' for
  --a particular pub_item and user_name
  PROCEDURE set_synch_completed(p_user_name VARCHAR2,p_pub_item VARCHAR2)
    IS
  BEGIN
    UPDATE asg_complete_refresh
    SET synch_completed='Y' , last_update_date = sysdate
    WHERE user_name=p_user_name
    AND publication_item=p_pub_item;
  END set_synch_completed;

  --sets synch_completed flag in asg_complete_refresh to 'Y' for
  --pub_item for a given user_name
  PROCEDURE set_synch_completed(p_user_name VARCHAR2)
    IS
  l_qry_string VARCHAR2(1024);
  BEGIN
    l_qry_string := ' UPDATE asg_complete_refresh SET ' ||
                    ' synch_completed=''Y'',last_update_date=sysdate ' ||
                    ' WHERE user_name= :1 ' ||
		    ' AND ' ||
                    ' publication_item IN ' ||
                    ' (SELECT name FROM '||asg_base.G_OLITE_SCHEMA||
		    '.c$pub_list_q)';
    EXECUTE IMMEDIATE l_qry_string
    USING p_user_name;

  END set_synch_completed;

  --removes the row corresponding to a user_name and pub_item
  --from asg_complete_refresh
  PROCEDURE delete_row(p_user_name VARCHAR2,p_pub_item VARCHAR2)
    IS
  BEGIN
    DELETE FROM asg_complete_refresh
    WHERE user_name = p_user_name AND
    publication_item = p_pub_item;
  END delete_row;

  --removes all rows for user_name from asg_complete_refresh
  --for the current publication items with synch_completed='Y'.
  PROCEDURE delete_row(p_user_name VARCHAR2)
    IS
    l_qry_string VARCHAR2(1024);
  BEGIN
    l_qry_string:= ' DELETE FROM asg_complete_refresh '||
                   ' WHERE user_name = :1 ' ||
		   ' AND synch_completed = ''Y'' AND '||
                   ' publication_item IN ' ||
                   '(SELECT name FROM '||asg_base.G_OLITE_SCHEMA||
		   '.c$pub_list_q)';
    EXECUTE IMMEDIATE l_qry_string
    USING p_user_name;
  END delete_row;



  --ROUTINE FOR REMOVING RECORDS FROM asg_complete_refresh
  -- if the previous synch was successful
  PROCEDURE process_compref_table(p_user_name VARCHAR2,p_last_tranid NUMBER)
    IS
  l_tranid NUMBER;
  l_str VARCHAR2(1024);
  l_ret varchar2(2);
  BEGIN
    l_ret := is_previous_synch_successful(p_user_name,p_last_tranid);
    IF( l_ret = FND_API.G_TRUE ) THEN
      --previous synch was successful
      IF(asg_helper.check_is_log_enabled(g_stmt_level))
      THEN
   	asg_helper.log('Prev synch successful ',
	               'asg_cons_qpkg',g_stmt_level);
      END IF;
      delete_row(p_user_name);
    ELSE
    --previous synch was not successful
    --so set all PI's of the current user to complete_synch
       l_str:= 'UPDATE asg_complete_refresh SET synch_completed=''N'' , '
               ||' last_update_date = sysdate WHERE user_name = :1 '
	       ||'  AND publication_item in '
	       ||'(SELECT name FROM '||asg_base.G_OLITE_SCHEMA
	       ||'.c$pub_list_q)';
       EXECUTE IMMEDIATE l_str
       USING p_user_name;
     END IF;

  END process_compref_table;

  -- Routine for removing records from c$pub_list_q
  -- If customization is disabled
  PROCEDURE process_custom_pub_items (p_user_name IN VARCHAR2)
            IS
  l_customProfValue  VARCHAR2(2);
  l_dml              VARCHAR2(512);
  l_user_id          NUMBER;
  BEGIN
    -- If custom publication item download is disabled
    -- then remove all custom entries from c$pub_list_q
    l_user_id := asg_base.get_user_id(p_user_name);
    l_customProfValue := fnd_profile.VALUE_SPECIFIC(
                           name => 'ASG_DISABLE_CUSTOM_SYNCH',
                           user_id => l_user_id,
                           responsibility_id => null,
                           application_id => 689);

    IF (l_customProfValue = 'Y') THEN
       IF(asg_helper.check_is_log_enabled(g_stmt_level))
       THEN
         asg_helper.log('Disabling download of custom pub items ',
                        'asg_cons_qpkg', g_stmt_level);
       END IF;
      l_dml := 'DELETE FROM '||asg_base.G_OLITE_SCHEMA||'.c$pub_list_q ' ||
               ' WHERE name IN ' ||
               '       (select a.name from asg_pub_item a,asg_pub b' ||
               '        where a.pub_name=b.name and b.custom=''Y'')';
      EXECUTE IMMEDIATE l_dml;
    END IF;

  END process_custom_pub_items;


  -- Routine for processing conflicts
  PROCEDURE process_conflicts(p_user_name IN VARCHAR2)
    IS
  l_upload_tranid     NUMBER;
  l_detect_conflict   VARCHAR2(1);
  l_pubitem           VARCHAR2(30);
  l_pubitem_tbl       asg_base.pub_item_tbl_type;
  l_counter           NUMBER;
  BEGIN

    l_upload_tranid := asg_base.get_upload_tranid();

    -- Check if conflict detection is needed other wise return
    IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
      asg_helper.log('Checking if conflicts should be detected.',
                     'asg_cons_qpkg',g_stmt_level);
    END IF;
    is_conflict_detection_needed (p_user_name,
                                  l_upload_tranid,
                                  l_detect_conflict,
                                  l_pubitem_tbl);

    IF (l_detect_conflict = FND_API.G_FALSE) THEN
      IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
        asg_helper.log('No need to check for conflicts.',
                       'asg_cons_qpkg',g_stmt_level);
      END IF;
      return;
    END IF;

    -- Ok, conflicts need to be detected, process one pubitem at a time
    FOR curr_index in 1..l_pubitem_tbl.count LOOP
      l_pubitem := l_pubitem_tbl(curr_index).name;
      IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
        asg_helper.log('Processing ' ||l_pubitem || ' for conflicts.',
                       'asg_cons_qpkg',g_stmt_level);
      END IF;
      process_pubitem_conflicts(p_user_name, l_upload_tranid, l_pubitem);
      IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
        asg_helper.log('Done processing ' ||l_pubitem || ' for conflicts.',
                       'asg_cons_qpkg',g_stmt_level);
      END IF;
    END LOOP;

    IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
      asg_helper.log('Done processing all conflicts.',
                     'asg_cons_qpkg',g_stmt_level);
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
      asg_helper.log('Exception when processing for conflicts. ' || sqlerrm,
                     'asg_cons_qpkg',g_stmt_level);
    END IF;
  END process_conflicts;

  -- Routine to determine if conflicts should be detected
  PROCEDURE is_conflict_detection_needed(
              p_user_name IN VARCHAR2,
              p_upload_tranid IN NUMBER,
              p_detect_conflict IN OUT NOCOPY VARCHAR2,
              p_pubitem_tbl IN OUT NOCOPY asg_base.pub_item_tbl_type)
    IS
  l_conf_pis_exist        VARCHAR2(1);
  l_query_string          VARCHAR2(512);
  l_query_string2         VARCHAR2(512);
  l_counter               PLS_INTEGER;
  l_cursor_id             NUMBER;
  l_cursor_id2            NUMBER;
  l_cursor_ret            NUMBER;
  l_cursor_ret2           NUMBER;
  l_pub_name              VARCHAR2(30);
  l_pub_callback          VARCHAR2(100);
  l_pub_detect_conflict   VARCHAR2(1);
  l_conf_pubs             VARCHAR2(2000) := NULL;
  BEGIN

   p_detect_conflict := FND_API.G_FALSE;
   l_conf_pis_exist := conflict_pub_items_exist(p_user_name,
                                                p_upload_tranid);
   IF (l_conf_pis_exist = asg_base.G_NO) THEN
     return;
   END IF;

    -- Ok, some pub items are uploaded which need conflict detection
    -- Call the publication level wrapper.
/*    l_query_string := 'SELECT distinct api.pub_name ' ||
                      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq ci, ' ||
                      '     asg_pub_item api ' ||
                      'WHERE ci.clid$$cs = ''' || p_user_name || '''  AND ' ||
                      '      ci.tranid$$ = ' || p_upload_tranid || ' AND ' ||
                      '      ci.store = api.name';*/
    l_query_string := 'SELECT distinct api.pub_name ' ||
                      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq ci, ' ||
                      '     asg_pub_item api ' ||
                      'WHERE ci.clid$$cs = :1 AND ' ||
                      '      ci.tranid$$ = :2 AND ' ||
                      '      ci.store = api.name';

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id, l_query_string, DBMS_SQL.v7);
    DBMS_SQL.bind_variable(l_cursor_id,':1',p_user_name);
    DBMS_SQL.bind_variable(l_cursor_id,':2',p_upload_tranid);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 1, l_pub_name, 30);

    l_cursor_ret := DBMS_SQL.EXECUTE (l_cursor_id);
    l_counter := 1;

    -- Go through all the publications whose pis were uploaded
    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0 ) LOOP
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 1, l_pub_name);

      SELECT wrapper_name into l_pub_callback
      FROM asg_pub
      WHERE name = l_pub_name;

      -- Find the callback return value
      /*
      l_query_string2 :=
                   'begin ' ||
                   ' :1 := ' || l_pub_callback || '.detect_conflict(''' ||
                   p_user_name || '''); ' ||
                   ' end;';
      */
      l_query_string2 := 'SELECT ' || l_pub_callback ||
                         '.detect_conflict( :1 ) from dual';

      IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
        asg_helper.log('SQL Command: ' || replace(l_query_string2,'''',''''''),
                       'asg_cons_qpkg',g_stmt_level);
      END IF;
      BEGIN
        /*
        l_cursor_id2 := DBMS_SQL.OPEN_CuRSOR();
        DBMS_SQL.PARSE(l_cursor_id2, l_query_string2, DBMS_SQL.v7);
        DBMS_SQL.DEFINE_COLUMN(l_cursor_id2, 1, l_pub_detect_conflict, 1);
        l_cursor_ret2 := DBMS_SQL.EXECUTE(l_cursor_id2);
        DBMS_SQL.COLUMN_VALUE(l_cursor_id2, 1, l_pub_detect_conflict);
        DBMS_SQL.CLOSE_CURSOR(l_cursor_id2);
        */
        EXECUTE IMMEDIATE l_query_string2
        INTO l_pub_detect_conflict
        USING p_user_name;

        IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
          asg_helper.log('Publication callback returned: ' ||
                         l_pub_detect_conflict,
                         'asg_cons_qpkg',g_stmt_level);
        END IF;
        IF (l_pub_detect_conflict = asg_base.G_YES) THEN
          -- Conflicts should be detected for this publication
          -- Build a comma separated list for use later.
          IF (l_conf_pubs IS NULL) THEN
            l_conf_pubs := '''' || l_pub_name || '''';
          ELSE
            l_conf_pubs := l_conf_pubs || ',''' || l_pub_name || '''';
          END IF;
          l_counter := l_counter +1;
        END IF;
      EXCEPTION
      WHEN OTHERS THEN
        IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
          asg_helper.log('Exception in wrapper callback ' ||SQLERRM,
                       'asg_cons_qpkg',g_stmt_level);
        END IF;
      END;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

    -- Some pubs need conflict detection
    IF (l_counter > 1) THEN
      p_detect_conflict := FND_API.G_TRUE;
      IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
        asg_helper.log('Need to detect conflicts.',
                       'asg_cons_qpkg',g_stmt_level);
      END IF;
      get_conf_pub_items_list(p_user_name, p_upload_tranid,
                              l_conf_pubs, p_pubitem_tbl);
    END IF;

  END is_conflict_detection_needed;

  FUNCTION conflict_pub_items_exist(p_user_name IN VARCHAR2,
                                    p_upload_tran_id IN NUMBER)
    RETURN VARCHAR2
    IS
  l_query_string    VARCHAR2(512);
  l_conf_pi_count   NUMBER;
  l_conf_pis_exist  VARCHAR2(1) := asg_base.G_NO;
  BEGIN
    -- As an optimization, first check the inq to see if there are
    -- any pub items uploaded that have detect_conflict set to yes.
    -- and will not be complete refreshed
    l_query_string := 'SELECT count(*) ' ||
                      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq ci, ' ||
                         asg_base.G_OLITE_SCHEMA || '.c$pub_list_q cpq, ' ||
                      '     asg_pub_item api ' ||
                      'WHERE ci.clid$$cs = :1 AND ' ||
                      '      ci.tranid$$ = :2 AND ' ||
                      '      ci.store = api.name  AND ' ||
                      '      ci.store = cpq.name AND ' ||
                      '      cpq.comp_ref <> ''Y'' AND ' ||
                      '      api.detect_conflict = ''Y''';

    IF(asg_helper.check_is_log_enabled(g_stmt_level))
    THEN
      asg_helper.log('SQL Command: ' || replace(l_query_string,'''',''''''),
                     'asg_cons_qpkg',g_stmt_level);
    END IF;

    EXECUTE IMMEDIATE l_query_string
    INTO l_conf_pi_count
    USING p_user_name, p_upload_tran_id;
    IF (l_conf_pi_count > 0) THEN
      l_conf_pis_exist := asg_base.G_YES;
    END IF;
    return l_conf_pis_exist;

  END conflict_pub_items_exist;

  PROCEDURE get_conf_pub_items_list(
               p_user_name IN VARCHAR2,
               p_upload_tranid IN NUMBER,
               l_conf_pubs IN VARCHAR2,
               p_pubitem_tbl IN OUT NOCOPY asg_base.pub_item_tbl_type)
    IS
  l_query_string VARCHAR2(4000);
  l_pubitem      VARCHAR2(30);
  l_cursor_id    NUMBER;
  l_cursor_ret   NUMBER;
  l_counter      NUMBER;
  BEGIN
/*    l_query_string := 'SELECT ci.store ' ||
                      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq ci , ' ||
                                 asg_base.G_OLITE_SCHEMA || '.c$pub_list_q cpq, ' ||
                      '       asg_pub_item api ' ||
                      'WHERE ci.clid$$cs = ''' || p_user_name || ''' AND ' ||
                      '      ci.tranid$$ =  ' || p_upload_tranid || ' AND ' ||
                      '      ci.store = api.name AND ' ||
                      '      ci.store = cpq.name AND ' ||
                      '      cpq.comp_ref <> ''Y'' AND ' ||
                      '      api.detect_conflict = ''Y'' AND ' ||
                      '      api.pub_name in (' || l_conf_pubs || ')';*/
    l_query_string := 'SELECT ci.store ' ||
                      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$inq ci , ' ||
                                 asg_base.G_OLITE_SCHEMA || '.c$pub_list_q cpq, ' ||
                      '       asg_pub_item api ' ||
                      'WHERE ci.clid$$cs = :1 AND ' ||
                      '      ci.tranid$$ = :2 AND ' ||
                      '      ci.store = api.name AND ' ||
                      '      ci.store = cpq.name AND ' ||
                      '      cpq.comp_ref <> ''Y'' AND ' ||
                      '      api.detect_conflict = ''Y'' AND ' ||
                      '      api.pub_name in (' || l_conf_pubs || ')';

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE (l_cursor_id, l_query_string, DBMS_SQL.v7);
    DBMS_SQL.bind_variable(l_cursor_id,':1',p_user_name);
    DBMS_SQL.bind_variable(l_cursor_id,':2',p_upload_tranid);
    DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 1, l_pubitem, 30);

    l_cursor_ret := DBMS_SQL.EXECUTE (l_cursor_id);
    l_counter := 1;

    -- Go through all the publications whose pis were uploaded
    WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0 ) LOOP
      DBMS_SQL.COLUMN_VALUE (l_cursor_id, 1, l_pubitem);
      p_pubitem_tbl(l_counter).name     := l_pubitem;
      l_counter := l_counter +1;
      IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
        asg_helper.log('Pub item that will be checked for conflicts: ' ||
                       l_pubitem, 'asg_cons_qpkg',g_stmt_level);
      END IF;
    END LOOP;

  END get_conf_pub_items_list;


  --procedure for processing asg_purge_sdq at synch time
  PROCEDURE  process_purge_Sdq ( p_clientid IN VARCHAR2,
				p_last_tranid IN NUMBER,
				p_curr_tranid IN NUMBER)
    IS
  CURSOR c_purgeSdq(c_username varchar2,c_pub_name varchar2) is
    SELECT NVL(transaction_id,-100)
	FROM asg_purge_sdq
	WHERE user_name = c_username AND pub_name = c_pub_name;
  l_tran_id              NUMBER;
  l_dml                  VARCHAR2(255);
  l_qry_string		 varchar2(4000);
  l_qry_string1		 varchar2(4000);
  l_cursor_id		 NUMBER;
  l_pub_name		 varchar2(30);
  l_ret_val		 NUMBER;
  BEGIN
   asg_helper.log('Processing Purge SDQ','asg_cons_qpkg',g_stmt_level);

   l_qry_string := 'select distinct pub_name from asg_pub_item where item_id in '||
		   ' ( select name from '||asg_base.G_OLITE_SCHEMA||'.c$pub_list_q )';
   l_cursor_id := dbms_sql.open_cursor();
   DBMS_SQL.parse(l_cursor_id,l_qry_string,DBMS_SQL.v7);
   DBMS_SQL.define_column(l_cursor_id,1,l_pub_name,30);
   l_ret_val := DBMS_SQL.execute(l_cursor_id);

   WHILE ( DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0 )
   LOOP
     DBMS_SQL.COLUMN_VALUE (l_cursor_id, 1, l_pub_name);

     l_tran_id := -200;

     OPEN c_purgeSdq(p_clientid,l_pub_name);
     FETCH c_purgeSdq INTO l_tran_id;

     IF(c_purgeSDq%FOUND)
     THEN
       IF(l_tran_id = -100 )
       THEN
	   -- process first time .set publication to complete refresh
	   asg_helper.log('Setting user '||p_clientid||' to complete refresh for '||
                          ' publication '||l_pub_name,'asg_cons_qpkg',g_stmt_level);
	   l_qry_string1 := 'update '||asg_base.G_OLITE_SCHEMA||'.c$pub_list_q '||
			   ' set comp_ref = ''Y'' where name in '||
			   ' ( select item_id from asg_pub_item where '||
			   ' pub_name = :1 )';
           EXECUTE IMMEDIATE l_qry_string1
           USING l_pub_name;
           UPDATE asg_purge_sdq
	   SET transaction_id=p_curr_tranid,last_update_date=sysdate
	   WHERE user_name=p_clientid AND pub_name = l_pub_name;
       ELSIF ( p_last_tranid < l_tran_id )
       THEN
	   -- last synch failed. ..so again set to complete refresh .
	   asg_helper.log('Re-setting user '||p_clientid||' to complete refresh for '||
	                  ' publication '||l_pub_name,'asg_cons_qpkg',g_stmt_level);
	   l_qry_string1 := 'update '||asg_base.G_OLITE_SCHEMA||'.c$pub_list_q '||
	   		    ' set comp_ref = ''Y'' where name in '||
			    ' ( select item_id from asg_pub_item where '||
			    ' pub_name = :1 )';
	   EXECUTE IMMEDIATE l_qry_string1
           USING l_pub_name;
	   UPDATE asg_purge_sdq
	   SET transaction_id=p_curr_tranid,last_update_date=sysdate
	   WHERE user_name=p_clientid AND pub_name = l_pub_name;
       ELSE
           --previous synch succeded ..so delete from purge_sdq
           asg_helper.log('Deleting asg_purge_sdq for user '||p_clientid||' and '||
                          ' publication '||l_pub_name,'asg_cons_qpkg',g_stmt_level);
           DELETE FROM asg_purge_sdq
           WHERE user_name = p_clientid AND pub_name = l_pub_name;
       END IF;
     ELSE
       null;
     END if;
     CLOSE c_purgeSdq;
   END LOOP;

   dbms_sql.close_cursor(l_cursor_id);
  asg_helper.log('End processing purgeSDQ','asg_cons_qpkg',g_stmt_level);
  EXCEPTION
  WHEN OTHERS THEN
      asg_helper.log('Exception in process_purge_sdq: ' || sqlerrm,
                     'asg_cons_qpkg',g_err_level);
      RAISE;
  END process_purge_Sdq;

  FUNCTION get_pk_predicate(l_primary_key_columns IN VARCHAR2)
    RETURN VARCHAR2 IS
  l_start     NUMBER;
  l_end       NUMBER;
  l_curr_col  VARCHAR2(30);
  l_predicate VARCHAR2(2000);
  BEGIN
    IF( instr(l_primary_key_columns, ',') = 0 ) THEN
      -- single column primary key
      l_predicate := ' inq.' || l_primary_key_columns ||
                     ' = ' || 'piv.' || l_primary_key_columns || ' ';
    ELSE

      l_start := 1;
      l_end :=1;
      LOOP
        -- Find out if there is a comma delimiter
        l_end := instr(l_primary_key_columns, ',', l_start);
        -- Extract the string until the comma
        IF (l_end <> 0) THEN
          l_curr_col := substr(l_primary_key_columns, l_start, (l_end-l_start));
        ELSE
          l_curr_col := substr(l_primary_key_columns, l_start);
        END IF;

	l_curr_col := ltrim(rtrim(l_curr_col));
        IF (l_start = 1) THEN
          l_predicate := ' inq.' || l_curr_col ||
                       ' = ' || 'piv.' || l_curr_col || ' ';
        ELSE
          l_predicate := l_predicate || ' AND inq.' || l_curr_col ||
                       ' = ' || 'piv.' || l_curr_col || ' ';
        END IF;
        IF(l_end =0) THEN
          EXIT;
        END IF;
        l_start := l_end +1;

      END LOOP;
    END IF;
    return l_predicate;

  END get_pk_predicate;

  -- Routine for processing conflicts
  PROCEDURE process_pubitem_conflicts(p_user_name IN VARCHAR2,
                                      p_upload_tranid IN NUMBER,
                                      p_pubitem IN VARCHAR2)
    IS
  CURSOR c_conf_rows (p_user_name VARCHAR2,
                      p_upload_tranid NUMBER,
                      p_pubitem VARCHAR2) IS
    SELECT sequence
    FROM asg_conf_info
    WHERE user_name = p_user_name AND
          transaction_id = p_upload_tranid AND
          pub_item = p_pubitem AND
          sequence IS NOT NULL;
  l_client_wins         VARCHAR2(1);
  l_server_wins         VARCHAR2(1);
  l_conf_resolution     VARCHAR2(1);
  l_inqtable_name       VARCHAR2(60);
  l_piv                 VARCHAR2(30);
  l_conflict_callout    VARCHAR2(100);
  l_primary_key_columns VARCHAR2(2000);
  l_pk_predicate        VARCHAR2(2000);
  l_query_string        VARCHAR2(2000);
  l_sequence            NUMBER;
  l_download_tranid     NUMBER;
  l_client_update_count NUMBER;
  l_server_update_count NUMBER;
  BEGIN

    -- One more optimization before checking for conflicts
    -- Check if there any UPD DML from client
    -- and then check if there is any UPD DML from server
    l_inqtable_name := asg_base.G_OLITE_SCHEMA ||
                       '.' || 'cfm$' || p_pubitem || ' ';
    l_query_string := 'SELECT count(*) ' ||
                      'FROM ' || l_inqtable_name ||
                      'WHERE clid$$cs = :1 AND ' ||
                      '      tranid$$ = :2 AND ' ||
                      '      dmltype$$ = ''U''';
    IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
      asg_helper.log('SQL Command: ' || replace(l_query_string, '''', ''''''),
                     'asg_cons_qpkg',g_stmt_level);
    END IF;

    EXECUTE IMMEDIATE l_query_string
    INTO l_client_update_count
    USING p_user_name, p_upload_tranid;

    IF (l_client_update_count =0) THEN
      IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
        asg_helper.log('No conflicts exist.',
                       'asg_cons_qpkg',g_stmt_level);
      END IF;
      return;
    END IF;

    SELECT base_object_name, primary_key_column, conflict_callout
    INTO l_piv, l_primary_key_columns, l_conflict_callout
    FROM asg_pub_item
    WHERE name = p_pubitem;

    l_client_wins := asg_base.G_CLIENT_WINS;
    l_server_wins := asg_base.G_SERVER_WINS;
    l_download_tranid := asg_base.get_current_tranid();
    -- Get the access_id of updated DMLs
    insert into asg_conf_info (user_name,
                               pub_item,
                               transaction_id,
                               access_id,
                               resolution,
                               creation_date,
                               created_by,
                               last_update_date,
                               last_updated_by)
    SELECT p_user_name, p_pubitem, p_upload_tranid, access_id, l_client_wins,
           sysdate, 1, sysdate, 1
    FROM asg_system_dirty_queue
    WHERE client_id = p_user_name AND
          pub_item = p_pubitem AND
          transaction_id = l_download_tranid AND
          download_flag = 'Y' AND
          dml_type = 2;
    l_server_update_count := SQL%ROWCOUNT;

    IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
      asg_helper.log('Number of updates in server: ' || l_server_update_count,
                     'asg_cons_qpkg',g_stmt_level);
    END IF;

    -- No updates from server. Return. Only conflicts between updates from
    -- client and updates from server are detected.
    IF (l_server_update_count = 0) THEN
      IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
        asg_helper.log('No conflicts exist.',
                       'asg_cons_qpkg',g_stmt_level);
      END IF;
      return;
    END IF;

    -- Link the access-ids with sequence no in inq table
    l_pk_predicate := get_pk_predicate(l_primary_key_columns);
    l_query_string := 'UPDATE asg_conf_info ' ||
                      'SET (sequence, access_id) = ' ||
                      '(SELECT seqno$$, access_id ' ||
                      ' FROM ' || l_inqtable_name || ' inq, ' ||
                                  l_piv || ' piv ' ||
                      ' WHERE  inq.clid$$cs = :1 AND ' ||
                      '        inq.tranid$$ = :2 AND ' ||
                      '        inq.dmltype$$ = ''U'' AND ' ||
                               l_pk_predicate || ' AND ' ||
                      '        piv.access_id in ' ||
                                         '(SELECT access_id ' ||
                      '                    FROM asg_conf_info ' ||
                      '                    WHERE user_name = :3 AND ' ||
                      '                          transaction_id = :4 AND ' ||
                      '                          pub_item = :5)) ' ||
                      ' WHERE user_name = :6 AND ' ||
                      '       transaction_id = :7 AND ' ||
                      '       pub_item = :8';

    IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
      asg_helper.log('SQL Command: ' || replace(l_query_string,'''',''''''),
                     'asg_cons_qpkg',g_stmt_level);
    END IF;
    EXECUTE IMMEDIATE l_query_string
    USING p_user_name, p_upload_tranid,
          p_user_name, p_upload_tranid, p_pubitem,
          p_user_name, p_upload_tranid, p_pubitem;

    -- Ready to call the pubitem callback
    -- If conflict callout is not specified client wins
    IF (l_conflict_callout IS NOT NULL) THEN
      FOR ccr in c_conf_rows(p_user_name, p_upload_tranid, p_pubitem) LOOP
        l_sequence := ccr.sequence;
/*        l_query_string := 'SELECT ' || l_conflict_callout ||
                          '(''' || p_user_name || ''', ' || p_upload_tranid ||
                          ', ' || l_sequence || ') from dual';*/
        l_query_string := 'SELECT ' || l_conflict_callout ||
                          '(:1,:2,:3) from dual';
        IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
          asg_helper.log('SQL Command: ' || replace(l_query_string,'''',''''''),
                         'asg_cons_qpkg',g_stmt_level);
        END IF;
        BEGIN
          l_conf_resolution := l_client_wins;
          EXECUTE IMMEDIATE l_query_string
          INTO l_conf_resolution
	  USING p_user_name,p_upload_tranid,l_sequence ;
        EXCEPTION
        WHEN OTHERS THEN
          IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
            asg_helper.log('Exception in pub item level callback. ' || sqlerrm,
                           'asg_cons_qpkg',g_stmt_level);
          END IF;
        END;
        IF (l_conf_resolution = l_server_wins) THEN
          UPDATE asg_conf_info
          SET resolution = l_conf_resolution
          WHERE user_name = p_user_name AND
                transaction_id = p_upload_tranid AND
                pub_item = p_pubitem AND
                sequence = l_sequence;
        END IF;
      END LOOP;
    END IF;

    -- Ok, all the conflict rows are processed. We need to
    -- reset download flag for those rows where client wins applies
    UPDATE asg_system_dirty_queue
    SET download_flag = NULL
    WHERE client_id = p_user_name AND
          pub_item = p_pubitem AND
          transaction_id = l_download_tranid AND
          dml_type = 2 AND
          access_id in (select access_id
                        FROM asg_conf_info
                        WHERE user_name = p_user_name AND
                              transaction_id = p_upload_tranid AND
                              pub_item = p_pubitem AND
                              sequence IS NOT NULL AND
                              resolution = l_client_wins);


  END process_pubitem_conflicts;

  PROCEDURE set_user_hwm_tranid(p_user_name IN VARCHAR2,
                                p_upload_tranid IN NUMBER)
    IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    asg_helper.update_hwm_tranid(p_user_name, p_upload_tranid);
    commit;
  EXCEPTION
  WHEN OTHERS THEN
    rollback;
  END set_user_hwm_tranid;

  FUNCTION set_user_pwd_expired (p_user_name   IN VARCHAR2,
                                 p_pwd_expired IN VARCHAR2)
           RETURN NUMBER
            IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_first_synch NUMBER := 0;
  BEGIN
    UPDATE asg_user
    SET password_expired = p_pwd_expired
    WHERE user_name = p_user_name;

    -- Find out if this is the very first synch for this user.
    SELECT count(*) into l_first_synch
    FROM asg_user
    WHERE user_name = p_user_name AND
          hwm_tranid IS NULL AND
          NOT EXISTS (SELECT 1
                      FROM asg_purge_sdq
                      WHERE user_name = p_user_name and
                            transaction_id is NOT null);
    COMMIT;
    return l_first_synch;
  EXCEPTION
  WHEN OTHERS THEN
    rollback;
    return l_first_synch;
  END set_user_pwd_expired;

  -- Wrapper procedure on fnd_user_pkg
  FUNCTION validate_login(p_user_name IN VARCHAR2,
                          p_password  IN VARCHAR2)
    RETURN VARCHAR2 IS
  l_user_authenticated VARCHAR2(1);
  l_loginID  NUMBER;
  l_first_synch NUMBER;
  l_pwd_expired VARCHAR2(1);
  l_ret_status  VARCHAR2(1);
  BEGIN
    l_user_authenticated := 'N';
    l_ret_status := fnd_web_sec.validate_login(p_user     => p_user_name,
                                               p_pwd      => p_password,
                                               p_loginID  => l_loginID,
                                               p_expired  => l_pwd_expired);

    IF (l_ret_status = 'Y') THEN
      l_user_authenticated := 'Y';
      -- check if this is the user's very first synch
      -- Exception is raised in download_init incase of very first synch
      -- All other synchs, authentication is set to 'N' if
      -- password expired.
      l_first_synch := set_user_pwd_expired(p_user_name, l_pwd_expired);
      IF(l_first_synch = 0 AND l_pwd_expired = 'Y') THEN
        l_user_authenticated := 'N';
      END IF;
    END IF;
    return l_user_authenticated;

  END validate_login;


  FUNCTION find_last_synch_date(p_user_name IN VARCHAR2,
                                p_last_tranid IN NUMBER)
           RETURN DATE IS
  l_last_synch_date DATE;
  BEGIN
    IF ((p_last_tranid <= -1) OR
        (g_first_synch = TRUE)) THEN
      IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
        asg_helper.log('First Synch detected.',
                       'asg_cons_qpkg',g_stmt_level);
      END IF;
      return NULL;
    ELSE
      g_last_synch_successful := is_previous_synch_successful(p_user_name,
                                                              p_last_tranid);
      IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
        asg_helper.log('Last Synch Successful: ' || g_last_synch_successful,
                       'asg_cons_qpkg',g_stmt_level);
      END IF;
      IF (g_last_synch_successful = FND_API.G_TRUE) THEN
        SELECT last_synch_date_end into l_last_synch_date
        FROM asg_user
        WHERE user_name = p_user_name;
      ELSE
        SELECT prior_synch_date_end into l_last_synch_date
        FROM asg_user
        WHERE user_name = p_user_name;
      END IF;
      return l_last_synch_date;
    END IF;

  END find_last_synch_date;

  FUNCTION find_device_type(p_user_name VARCHAR2)
           RETURN VARCHAR2 IS
  l_device_type VARCHAR2(30) := null;
  BEGIN
     -- Find the device type and detect device switch as well
     asg_base.detect_device_switch(p_user_name, l_device_type);
     RETURN l_device_type;
  EXCEPTION
  WHEN OTHERS THEN
    return l_device_type;
  END find_device_type;


END asg_cons_qpkg;

/
