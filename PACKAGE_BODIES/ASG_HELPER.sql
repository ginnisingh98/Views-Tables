--------------------------------------------------------
--  DDL for Package Body ASG_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_HELPER" AS
/*$Header: asghlpb.pls 120.7.12010000.4 2009/08/18 09:03:36 saradhak ship $*/

-- DESCRIPTION
--  This package is used for miscellaneous chores
--
-- HISTORY
--   24-jul-2009 saradhak   Added raise_sync_error_event api
--   29-sep-2004 ssabesan   Removed method truncate_sdq
--   08-sep-2004 ssabesan   remove code in recreate_synonyms() from 115.43
--   24-jun-2004 rsripada   Fix bug 3720692
--   23-jun-2004 ssabesan   Fix bug 3713556
--   01-jun-2004 ssabesan   Change literals to bind variables.
--   14-may-2004 ssabesan   Fix GSCC warning - Standard File.Sql.6
--   16-apr-2004 rsripada   Provide additional privs to inq table
--   05-apr-2004 rsripada   Add enable_olite_privs
--   01-apr-2004 ssabesan   Added en/decrypt, set_profile_to_null routines
--   13-jan-2004 ssabesan   Added method recreate_synonyms() for use during
--                          user creation.
--   30-dec-2003 rsripada   Added procedures for creating/dropping olite
--                          synonyms
--   11-nov-2003 ssabesan   modified set_synch_errmsg to write into
--			                asg_user_pub_resps.synch_date
--   22-oct-2003 ssabesan   Merge 115.23.1158.15 into mainline
--   01-oct-2003 ssabesan   Purge SDQ changes (bug 3170790)
--   12-jun-2003 rsripada   Added proc to determine last synch device type
--   10-apr-2003 ssabesan   for logging user_setup and synch errors use
--                          last_wireless_contact_date column.
--   26-mar-2003 rsripada   Removed default values in log procedure
--   25-mar-2003 ssabesan   Added API for updating user_sertup_errors and
--                          synch_errors column in asg_user
--   12-feb-2003 ssabesan   Added API for updating hwm_tranid in asg_user
--   10-jan-2003 ssabesan   Added a wrapper around check_is_log_enabled()
--			                for use from java program.
--   06-jan-2003 ssabesan   PL/SQL API changes. Added method for checking
--			                whether logging is enabled.
--   02-jan-2003 rsripada   Bug fix 2731476
--   12-dec-2002 rsripada   Do not populate access records for custom pub
--   19-nov-2002 rsripada   Added routines for disabling user synch
--   10-nov-2002 ssabesan   added routine for specifying a pub-item
--		                    to be completely refreshed
--   09-sep-2002 rsripada   Added routines to enable/disable synch
--   15-aug-2002 rsripada   Fixed 2504496
--   17-jul-2002 rsripada   Catch exception in callouts and added logging
--   18-jun-2002 rsripada   Modified log to allow easier debug
--   04-jun-2002 rsripada   Initialized logging
--   28-may-2002 rsripada   Created

  g_initialize_log BOOLEAN := FALSE;
  g_stmt_level NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_err_level NUMBER := FND_LOG.LEVEL_ERROR;
  g_svc       VARCHAR2(30) := 'ASG_OLITE';


  FUNCTION check_is_log_enabled(log_level IN NUMBER)
  RETURN BOOLEAN
            IS
  l_userid NUMBER;
  l_respid NUMBER;
  l_appid  NUMBER;
  BEGIN
    IF(g_initialize_log = TRUE )
    THEN
      IF(log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        RETURN true;
      ELSE
        RETURN false;
      END IF;
    ELSE
      l_userid := fnd_global.user_id();
      l_respid := fnd_global.resp_id();
      l_appid  := fnd_global.resp_appl_id();
      IF l_userid IS NULL or l_userid = -1 THEN
        l_userid := 5;
      END IF;
      IF l_respid IS NULL or l_respid = -1 THEN
        l_respid := 20420;
      END IF;
      IF l_appid IS NULL or l_appid = -1 THEN
        l_appid := 1;
      END IF;
      fnd_global.apps_initialize(l_userid,
                                 l_respid,
                                 l_appid);
      fnd_log_repository.init();
      g_initialize_log := TRUE;
      IF(log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        RETURN true;
      ELSE
        RETURN false;
      END IF;
    END IF;
   END check_is_log_enabled;

   --wrapper around check_is_log_enabled(log_level IN NUMBER)
   --for use from java programs.
   FUNCTION check_log_enabled(log_level IN NUMBER)
   RETURN VARCHAR2
          IS
   l_retval varchar2(1);
   BEGIN
     IF(check_is_log_enabled(log_level))
     THEN
       l_retval := 'Y';  -- log is enabled
     ELSE
       l_retval := 'N'; -- log is disabled
     END IF;
     RETURN l_retval;
   END check_log_enabled;

  -- Invokes the callback to populate all the user's acc tables
  PROCEDURE populate_access(p_user_name IN VARCHAR2,
                            p_pub_name IN VARCHAR2)
            IS
  CURSOR c_wrapper_name(p_pub_name VARCHAR2) IS
    SELECT wrapper_name
    FROM asg_pub
    WHERE name = p_pub_name;
  CURSOR c_custom_pub(p_pub_name VARCHAR2) IS
    SELECT nvl(custom, 'N')
    FROM asg_pub
    WHERE name = p_pub_name;
  l_custom_pub VARCHAR2(1);
  l_callback_string VARCHAR2(512);
  l_user_id NUMBER;
  l_wrapper_name asg_pub.wrapper_name%type;
  BEGIN

    IF(p_pub_name = 'ALL') THEN
      return;
    END IF;

    -- Check if the publication is custom and return if it is
    OPEN c_custom_pub(p_pub_name);
    FETCH c_custom_pub into l_custom_pub;
    CLOSE c_custom_pub ;
    IF (l_custom_pub = 'Y') THEN
      return;
    END IF;
    IF(check_is_log_enabled(g_stmt_level))
    THEN
      log('Calling populate_access_records for user: ' || p_user_name ||
          ' and publication: ' || p_pub_name,'asg_helper',g_stmt_level);
    END IF;

    OPEN c_wrapper_name(p_pub_name);
    FETCH c_wrapper_name into l_wrapper_name;
    CLOSE c_wrapper_name;
    IF l_wrapper_name IS NULL THEN
      IF(check_is_log_enabled(g_err_level))
      THEN
        log('Wrapper for publication: ' || p_pub_name || ' is null',
            'asg_helper',g_err_level);
      END IF;
      RAISE_APPLICATION_ERROR(-20989, 'Callback package missing for ' ||
                              'publication: ' || p_pub_name);
    END IF;
    l_user_id := asg_base.get_user_id(p_user_name);

    BEGIN
      l_callback_string := 'BEGIN ' || l_wrapper_name ||
                           '.populate_access_records( :1 ); END;';
      IF(check_is_log_enabled(g_stmt_level))
      THEN
        log('Callback SQLCommand: ' || l_callback_string,
	    'asg_helper',g_stmt_level);
      END IF;
      EXECUTE IMMEDIATE l_callback_string
      USING l_user_id;
    EXCEPTION
    WHEN OTHERS THEN
      IF(check_is_log_enabled(g_err_level))
      THEN
        log('Exception in call to populate access records: ' ||
            SQLERRM, 'asg_helper',g_err_level);
      END IF;
      RAISE;
    END;

  END populate_access;

  -- Invokes the callback to remove all acc table records
  PROCEDURE delete_access(p_user_name IN VARCHAR2,
                          p_pub_name IN VARCHAR2)
            IS
  CURSOR c_wrapper_name(p_pub_name VARCHAR2) IS
    SELECT wrapper_name
    FROM asg_pub
    WHERE name = p_pub_name;
  CURSOR c_custom_pub(p_pub_name VARCHAR2) IS
    SELECT nvl(custom, 'N')
    FROM asg_pub
    WHERE name = p_pub_name;
  l_custom_pub VARCHAR2(1);
  l_callback_string VARCHAR2(512);
  l_user_id NUMBER;
  l_wrapper_name asg_pub.wrapper_name%type;
  BEGIN

    IF(p_pub_name = 'ALL') THEN
      return;
    END IF;

    -- Check if the publication is custom and return if it is
    OPEN c_custom_pub(p_pub_name);
    FETCH c_custom_pub into l_custom_pub;
    CLOSE c_custom_pub ;
    IF (l_custom_pub = 'Y') THEN
      return;
    END IF;
    IF(check_is_log_enabled(g_stmt_level))
    THEN
      log('Calling delete_access_records for user: ' || p_user_name ||
          ' and publication: ' || p_pub_name,'asg_helper',g_stmt_level);
    END IF;
    OPEN c_wrapper_name(p_pub_name);
    FETCH c_wrapper_name into l_wrapper_name;
    CLOSE c_wrapper_name;
    IF l_wrapper_name IS NULL THEN
      IF(check_is_log_enabled(g_err_level))
      THEN
        log('Wrapper for publication: ' || p_pub_name || ' is null',
            'asg_helper',g_err_level);
      END IF;
      RAISE_APPLICATION_ERROR(-20989, 'Callback package missing for ' ||
                              'publication: ' || p_pub_name);
    END IF;
    l_user_id := asg_base.get_user_id(p_user_name);

    BEGIN
      l_callback_string := 'BEGIN ' || l_wrapper_name ||
                           '.delete_access_records(:2); END;';
      IF(check_is_log_enabled(g_stmt_level))
      THEN
        log('Callback SQLCommand: ' || l_callback_string,
	    'asg_helper',g_stmt_level);
      END IF;
      EXECUTE IMMEDIATE l_callback_string
      USING l_user_id;
    EXCEPTION
    WHEN OTHERS THEN
      IF(check_is_log_enabled(g_err_level))
      THEN
        log('Exception in call to delete access records: ' ||
            SQLERRM, 'asg_helper',g_err_level);
      END IF;
      RAISE;
    END;

  END delete_access;

  -- Creates a sequence partitions
  PROCEDURE create_seq_partition(p_user_name IN VARCHAR2,
                                 p_seq_name  IN VARCHAR2,
                                 p_start_value IN VARCHAR2,
                                 p_next_value IN VARCHAR2)
            IS
  BEGIN
    -- Delete the row before inserting
    -- #$% Can remove delete after debug/qa
    DELETE FROM asg_sequence_partitions
    WHERE clientid = p_user_name AND name = p_seq_name;

    INSERT INTO asg_sequence_partitions (
      CLIENTID,
      NAME,
      CURR_VAL,
      INCR,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY)
    values
      (p_user_name,
       p_seq_name,
       to_number(p_start_value),
       to_number(p_next_value),
       sysdate,
       1,
       sysdate,
       1);
    COMMIT;
    IF(check_is_log_enabled(g_stmt_level))
    THEN
      log('Created Sequence Partition for user: ' || p_user_name ||
          ' and sequence: ' || p_seq_name || ' with start value: ' ||
          p_start_value || ' and next value: ' || p_next_value,
	  'asg_helper',g_stmt_level);
    END IF;

  END create_seq_partition;

  -- Drop the sequence partition
  PROCEDURE drop_seq_partition(p_user_name IN VARCHAR2,
                               p_seq_name IN VARCHAR2)
            IS
  BEGIN

    DELETE FROM asg_sequence_partitions
    WHERE clientid = p_user_name AND name = p_seq_name;

    COMMIT;
    IF(check_is_log_enabled(g_stmt_level))
    THEN
      log('Dropped Sequence Partition for user: ' || p_user_name ||
          ' and sequence: ' || p_seq_name,'asg_helper',g_stmt_level);
    END IF;
  END drop_seq_partition;

  -- insert pub responsibilities
  PROCEDURE insert_user_pub_resp(p_user_name IN VARCHAR2,
                                 p_pub_name IN VARCHAR2,
                                 p_resp_id IN NUMBER,
                                 p_app_id IN NUMBER)
            IS
  BEGIN
    DELETE FROM asg_user_pub_resps
    WHERE user_name = p_user_name AND
          pub_name = p_pub_name AND
          responsibility_id = p_resp_id AND
          app_id = p_app_id;

    INSERT INTO asg_user_pub_resps (
      USER_NAME,
      PUB_NAME,
      SYNCH_DISABLED,
      RESPONSIBILITY_ID,
      APP_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY)
    VALUES
      (p_user_name,
       p_pub_name,
       'N',
       p_resp_id,
       p_app_id,
       sysdate,
       1,
       sysdate,
       1);
    COMMIT;
    IF(check_is_log_enabled(g_stmt_level))
    THEN
      log('Created user pub responsibility record for user: ' || p_user_name ||
          ' and publication: ' || p_pub_name || ' and responsibility id: ' ||
          p_resp_id || ' and app id: ' || p_app_id,'asg_helper',g_stmt_level);
    END IF;

  END insert_user_pub_resp;

 --delete user-pub
 PROCEDURE delete_user_pub(p_user_name IN VARCHAR2,
                                 p_pub_name IN VARCHAR2)
   	   IS
  BEGIN

    DELETE FROM asg_user_pub_resps
    WHERE user_name = p_user_name AND
          pub_name = p_pub_name;

    DELETE FROM asg_purge_sdq
    WHERE user_name = p_user_name AND
	  pub_name = p_pub_name;

    DELETE FROM asg_complete_refresh
    WHERE user_name = p_user_name AND
	  publication_item IN
	  ( SELECT item_id FROM asg_pub_item
	    WHERE pub_name = p_pub_name);

    COMMIT;
    IF(check_is_log_enabled(g_stmt_level))
    THEN
      log('Deleted user pub record for user: ' || p_user_name ||
          ' and publication: ' || p_pub_name,'asg_helper',g_stmt_level);
    END IF;
  END delete_user_pub;


  -- delete pub responsibilites
  PROCEDURE delete_user_pub_resp(p_user_name IN VARCHAR2,
                                 p_pub_name IN VARCHAR2,
                                 p_resp_id IN NUMBER)
            IS
  BEGIN

    DELETE FROM asg_user_pub_resps
    WHERE user_name = p_user_name AND
          pub_name = p_pub_name AND
          responsibility_id = p_resp_id;

    COMMIT;
    IF(check_is_log_enabled(g_stmt_level))
    THEN
      log('Deleted user pub responsibility record for user: ' || p_user_name ||
          ' and publication: ' || p_pub_name || ' and responsibility id: ' ||
          p_resp_id,'asg_helper',g_stmt_level);
    END IF;
  END delete_user_pub_resp;

  -- wrapper on fnd_log
  PROCEDURE log(message IN VARCHAR2,
                module IN VARCHAR2,
                log_level IN NUMBER)
            IS
  l_userid NUMBER;
  l_respid NUMBER;
  l_appid  NUMBER;
  l_message VARCHAR2(4000);
  l_start_string VARCHAR2(64);
  BEGIN
    l_start_string := asg_base.get_user_name() ||
                      ',' || asg_base.get_current_tranid() || ': ';
    IF asg_base.get_user_name() IS NULL THEN
      l_message := message;
    ELSE
      l_message := l_start_string || message;
    END IF;
    IF (log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(log_level, module, l_message);
    ELSE
      l_userid := fnd_global.user_id();
      l_respid := fnd_global.resp_id();
      l_appid  := fnd_global.resp_appl_id();
      IF l_userid IS NULL or l_userid = -1 THEN
        l_userid := 5;
      END IF;
      IF l_respid IS NULL or l_respid = -1 THEN
        l_respid := 20420;
      END IF;
      IF l_appid IS NULL or l_appid = -1 THEN
        l_appid := 1;
      END IF;
      fnd_global.apps_initialize(l_userid,
                                 l_respid,
                                 l_appid);
      fnd_log_repository.init();
      g_initialize_log := TRUE;
      IF (log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    fnd_log.string(log_level, module, l_message);
      end if;
    END IF;
  END log;


  -- Used to clean up metadata associated with an user
  PROCEDURE drop_user(p_user_name IN VARCHAR2)
            IS
  l_user_name VARCHAR2(30);
  l_bool_ret  BOOLEAN;
  CURSOR c_user_pubs(p_user_name VARCHAR2) IS
    SELECT pub_name
    FROM asg_user_pub_resps
    WHERE user_name = p_user_name;
  BEGIN
    l_user_name := upper(p_user_name);

    -- Call delete access for all the publications the user
    -- is subscribed to
    FOR cups in c_user_pubs(l_user_name) LOOP
      delete_access(l_user_name, cups.pub_name);
    END LOOP;

    DELETE FROM asg_user_pub_resps
    WHERE user_name = p_user_name;

    DELETE FROM ASG_USERS_INQARCHIVE
    WHERE device_user_name = l_user_name;

    -- Before drop is called we check to see if there are any
    -- unprocessed inq transactions. So, at this point all of them
    -- should have been processed.
    DELETE FROM ASG_DEFERRED_TRANINFO
    WHERE device_user_name = l_user_name;

    DELETE FROM ASG_USERS_INQINFO
    WHERE device_user_name = l_user_name;

--12.1
    DELETE FROM asg_auto_sync_tranids
    WHERE user_name = l_user_name;

    BEGIN
      l_bool_ret := asg_download.purgesdq(l_user_name);
    EXCEPTION
    WHEN OTHERS THEN
      IF(check_is_log_enabled(g_err_level))
      THEN
        log('Exception in purgesdq during drop_user: ' || l_user_name,
	    'asg_helper',g_err_level);
      END IF;
    END;

    --delete from asg_purge_sdq and asg_complete_refresh

    DELETE FROM asg_purge_sdq
    WHERE user_name = l_user_name;

    DELETE FROM asg_complete_refresh
    WHERE user_name = l_user_name;

    DELETE FROM asg_sequence_partitions
    WHERE clientid = p_user_name;

    DELETE FROM ASG_USER
    WHERE user_name = l_user_name;

    COMMIT;
    IF(check_is_log_enabled(g_stmt_level))
    THEN
     log('Done cleaning up user meta data during drop user: ' || p_user_name,
         'asg_helper',g_stmt_level);
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    IF(check_is_log_enabled(g_err_level))
    THEN
      log('Exception in drop_user ' || SQLERRM,
          'asg_helper',g_err_level);
    END IF;
    RAISE;
  END drop_user;

  -- Used to update a parameter in asg_config
  PROCEDURE set_config_param(p_param_name IN VARCHAR2,
                             p_param_value IN VARCHAR2,
                             p_param_description IN VARCHAR2 := NULL)
            IS
  BEGIN

    asg_config_pkg.load_row(p_param_name, p_param_value,
                            p_param_description,
                            sysdate, 1,
                            sysdate, 1,
                            FND_API.G_MISS_CHAR);
    COMMIT;

  END set_config_param;

  -- Returns the value column in asg_config table based on the
  -- specified parameter name
  FUNCTION get_param_value(p_param_name IN VARCHAR2)
           return VARCHAR2 IS
  CURSOR C_PARAM_VALUE(p_param_name varchar2) IS
    SELECT value
    FROM asg_config
    WHERE name = p_param_name;
  l_param_value VARCHAR2(2000);
  BEGIN

    OPEN C_PARAM_VALUE(p_param_name);
    FETCH C_PARAM_VALUE into l_param_value;
    CLOSE C_PARAM_VALUE;
    return l_param_value;

  END get_param_value;

  -- Used to enable synch for all publications
  PROCEDURE enable_synch
            IS
  BEGIN

    UPDATE asg_pub
    SET enable_synch = 'Y';
    COMMIT;

  END enable_synch;


  -- Used to enable synch for the specified publication
  PROCEDURE enable_pub_synch(p_pub_name IN VARCHAR2)
            IS
  BEGIN

    UPDATE asg_pub
    SET enable_synch = 'Y'
    WHERE name = upper(p_pub_name);
    COMMIT;

  END enable_pub_synch;

  -- Used to disable synch for all publications
  PROCEDURE disable_synch
            IS
  BEGIN

    UPDATE asg_pub
    SET enable_synch = 'N';
    COMMIT;

  END disable_synch;

  -- Used to disable synch for the specified publication
  PROCEDURE disable_pub_synch(p_pub_name IN VARCHAR2)
            IS
  BEGIN

    UPDATE asg_pub
    SET enable_synch = 'N'
    WHERE name = upper(p_pub_name);
    COMMIT;

  END disable_pub_synch;

  -- Returns FND_API.G_TRUE if the user synch is enabled
  FUNCTION is_user_synch_enabled(p_user_name IN VARCHAR2,
           p_disabled_synch_message OUT NOCOPY VARCHAR2)
           return VARCHAR2 IS
  l_synch_enabled VARCHAR2(1) := FND_API.G_TRUE;
  l_disabled_user PLS_INTEGER;
  l_disabled_pubs PLS_INTEGER;
  l_query_string VARCHAR2(2000);
  BEGIN

    -- First, check if the user was created properly
    SELECT count(*) into l_disabled_user
    FROM asg_user
    WHERE user_name = p_user_name AND
          enabled = 'N';

    IF l_disabled_user > 0 THEN
      l_synch_enabled := FND_API.G_FALSE;
      p_disabled_synch_message := asg_helper.get_param_value(
                                'DISABLED_SYNCH_MESSAGE_UC');
      return l_synch_enabled;
    END IF;

    -- Check if access table population has been completed for this user
    l_query_string := 'SELECT count(*) ' ||
                      'FROM asg_user_pub_resps aup, asg_pub ap ' ||
                      'WHERE aup.user_name = :1 AND ' ||
                      '      aup.pub_name = ap.name AND ' ||
                      '      aup.synch_disabled =  ''Y'' AND ' ||
                      '      ap.name in ' ||
                      '      (SELECT distinct pub_name ' ||
                      '       FROM asg_pub_item api, ' ||
                      asg_base.G_OLITE_SCHEMA || '.c$pub_list_q cpq ' ||
                      '       where api.name = cpq.name)';

    EXECUTE IMMEDIATE l_query_string
      INTO l_disabled_pubs
      USING p_user_name;

    IF (l_disabled_pubs >0) THEN
      l_synch_enabled := FND_API.G_FALSE;
      p_disabled_synch_message := asg_helper.get_param_value(
                                'DISABLED_SYNCH_MESSAGE_ACC');
      return l_synch_enabled;
    END IF;

    -- Check if synchronization is disabled for any of the
    -- publications the user is subscribed to
    -- and downloading as part of current synch due to patching
    l_query_string := 'SELECT count(*) ' ||
                      'FROM asg_user_pub_resps aup, asg_pub ap ' ||
                      'WHERE aup.user_name = :1 AND ' ||
                      '      aup.pub_name = ap.name AND ' ||
                      '      ap.enable_synch = ''N'' AND ' ||
                      '      ap.name in ' ||
                      '      (SELECT distinct pub_name ' ||
                      '       FROM asg_pub_item api, ' ||
                      asg_base.G_OLITE_SCHEMA || '.c$pub_list_q cpq ' ||
                      '       where api.name = cpq.name)';

    EXECUTE IMMEDIATE l_query_string
      INTO l_disabled_pubs
      USING p_user_name;

    IF (l_disabled_pubs >0) THEN
      l_synch_enabled := FND_API.G_FALSE;
      p_disabled_synch_message := asg_helper.get_param_value(
                                'DISABLED_SYNCH_MESSAGE_PATCH');
    END IF;

    return l_synch_enabled;

  END is_user_synch_enabled;

  --routine for setting complete_refresh for a pub-item for all users
  --subscribed to that Pub-Item.
  PROCEDURE set_complete_refresh(p_pub_item VARCHAR2)
	        IS
  CURSOR c_all_users(pi_name VARCHAR2) IS
    SELECT user_name
    FROM asg_user_pub_resps aup, asg_pub_item api
    WHERE api.name = upper(pi_name) AND
          api.pub_name = aup.pub_name;
  CURSOR c_row_exists(pi_name VARCHAR2) IS
    SELECT count(*)
    FROM asg_complete_refresh
    WHERE publication_item=pi_name;
  CURSOR c_new_users(pi_name VARCHAR2) IS
    SELECT user_name
    FROM asg_user_pub_resps aup, asg_pub_item api
    WHERE api.name = upper(pi_name) AND
          aup.pub_name = api.pub_name AND
          user_name NOT IN
            ( SELECT user_name
              FROM asg_complete_refresh
              WHERE publication_item = pi_name );
  l_pub_item VARCHAR2(30);
  l_cnt      NUMBER :=0;
  l_uname c_all_users%ROWTYPE;
  l_recf1 c_new_users%ROWTYPE;
  BEGIN

    IF ((p_pub_item = FND_API.G_MISS_CHAR) OR (p_pub_item IS NULL)) THEN
      return;
    END IF;

    l_pub_item := upper(p_pub_item);

    -- Check if there already some records for this publication item
    OPEN c_row_exists(l_pub_item);
    FETCH c_row_exists INTO l_cnt;
    -- Records exist
    IF(l_cnt > 0) THEN
      -- Reset all the records so that they will be completely refreshed
      UPDATE asg_complete_refresh
	  SET last_update_date=sysdate,synch_completed='N'
	  WHERE publication_item=l_pub_item;

	  OPEN c_new_users(l_pub_item);
	  LOOP
	    FETCH c_new_users INTO l_recf1;
	    EXIT WHEN c_new_users%NOTFOUND;
          INSERT INTO asg_complete_refresh(
            USER_NAME,
            PUBLICATION_ITEM,
            SYNCH_COMPLETED,
 	        CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
	        LAST_UPDATED_BY)
	      VALUES(
            l_recf1.user_name,
            l_pub_item,
            'N',
            sysdate,
            1,
            sysdate,
            1);
	  END LOOP;
      CLOSE c_new_users;
      CLOSE c_row_exists;
      COMMIT;
      RETURN;
    END IF;
    CLOSE c_row_exists;

    OPEN c_all_users(l_pub_item);
      LOOP
        FETCH c_all_users INTO l_uname;
        EXIT WHEN c_all_users%NOTFOUND;
        INSERT INTO asg_complete_refresh(
          USER_NAME,
          PUBLICATION_ITEM,
          SYNCH_COMPLETED,
 	      CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
	      LAST_UPDATED_BY)
	    VALUES(
          l_uname.user_name,
          l_pub_item,
          'N',
          sysdate,
          1,
          sysdate,
          1);
      END LOOP;
    CLOSE c_all_users;
    COMMIT;
  END set_complete_refresh;

  -- Disables synch for specified user/publication
  PROCEDURE disable_user_pub_synch(p_user_id   IN NUMBER,
                                   p_pub_name  IN VARCHAR2)
            IS
  CURSOR C_USER_NAME(p_user_id NUMBER) IS
    SELECT user_name
    FROM asg_user
    WHERE user_id = p_user_id;
  l_user_name VARCHAR2(30);
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF ((p_user_id = FND_API.G_MISS_NUM) OR (p_user_id IS NULL)) OR
       ((p_pub_name = FND_API.G_MISS_CHAR) OR (p_pub_name IS NULL)) THEN
      return;
    END IF;

    OPEN C_USER_NAME(p_user_id);
    FETCH C_USER_NAME into l_user_name;
    CLOSE C_USER_NAME;

    UPDATE asg_user_pub_resps
    SET SYNCH_DISABLED = 'Y'
    WHERE user_name = l_user_name AND
          pub_name = p_pub_name;
    COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  END disable_user_pub_synch;

  -- Enables synch for specified user/publication
  PROCEDURE enable_user_pub_synch(p_user_id   IN NUMBER,
                                  p_pub_name  IN VARCHAR2)
            IS
  CURSOR C_USER_NAME(p_user_id NUMBER) IS
    SELECT user_name
    FROM asg_user
    WHERE user_id = p_user_id;
  l_user_name VARCHAR2(30);
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF ((p_user_id = FND_API.G_MISS_NUM) OR (p_user_id IS NULL)) OR
       ((p_pub_name = FND_API.G_MISS_CHAR) OR (p_pub_name IS NULL)) THEN
      return;
    END IF;

    OPEN C_USER_NAME(p_user_id);
    FETCH C_USER_NAME into l_user_name;
    CLOSE C_USER_NAME;

    UPDATE asg_user_pub_resps
    SET SYNCH_DISABLED = 'N'
    WHERE user_name = l_user_name AND
          pub_name = p_pub_name;
    COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  END enable_user_pub_synch;

  -- Enables all users access to public group
  PROCEDURE set_group_access(p_group_name IN VARCHAR2)
            IS
  l_grp_name VARCHAR2(256);
  l_grp_id NUMBER;
  l_query_string VARCHAR2(2000);
  BEGIN

    IF (p_group_name IS NULL) OR (p_group_name = FND_API.G_MISS_CHAR) THEN
      return;
    END IF;
    l_grp_name := upper(p_group_name);

    -- Get the group id first
    l_query_string := 'SELECT id ' ||
                      'FROM ' || asg_base.G_OLITE_SCHEMA || '.groups grp ' ||
                      'WHERE grp.name = :group_name';

    EXECUTE IMMEDIATE l_query_string
    INTO l_grp_id
    USING l_grp_name;

    IF (l_grp_id IS NULL) THEN
      return;
    END IF;

    -- Insert into usr_grp all users who do not have access to
    -- this group
    l_query_string :=
      'INSERT INTO ' ||
      asg_base.G_OLITE_SCHEMA || '.usr_grp ' ||
      '(entity_id, entity_type, grp_id) ' ||
      'SELECT usr.id, 0, :group_id ' ||
      'FROM ' || asg_base.G_OLITE_SCHEMA || '.users usr ' ||
      'WHERE usr.id not in ' ||
      '                  (SELECT usr2.id ' ||
      '                   FROM ' || asg_base.G_OLITE_SCHEMA || '.users usr2,' ||
                               asg_base.G_OLITE_SCHEMA || '.usr_grp ugrp ' ||
      '                   WHERE ugrp.grp_id = :group_id AND ' ||
      '                         usr2.id = ugrp.entity_id) AND ' ||
      '      usr.name in ' ||
      '                 (SELECT user_name ' ||
      '                  FROM asg_user)';

    EXECUTE IMMEDIATE l_query_string
    USING l_grp_id,l_grp_id;

  END set_group_access;

  --API for updating hwm_tranid column in asg_user table
  PROCEDURE update_hwm_tranid(p_user_name IN VARCHAR2,p_tranid IN NUMBER)
    IS
  BEGIN
    UPDATE asg_user
    SET hwm_tranid=p_tranid
    WHERE user_name=UPPER(p_user_name);
  END update_hwm_tranid;

  --API for autonomous update of USER_SETUP_ERRORS column in asg_user table
  PROCEDURE update_user_setup_errors(p_user_name IN VARCHAR2,p_mesg IN VARCHAR2)
    IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE asg_user
    SET user_setup_errors = p_mesg
    WHERE user_name = p_user_name;
    COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  END update_user_setup_errors;

  --API for synching info between asg_user_pub_resps and asg_user tables
  --after adding/dropping subscription
  PROCEDURE update_user_resps(p_user_name IN VARCHAR2)
    IS
  l_resp_id          NUMBER;
  l_app_id           NUMBER;
  BEGIN

    BEGIN
      SELECT responsibility_id, app_id INTO l_resp_id, l_app_id
      FROM asg_user_pub_resps
      WHERE user_name = p_user_name AND
            pub_name = 'SERVICEP';
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;

    /* Check SERVICEL if no item exists for SERVICEP */
    IF (l_resp_id IS NULL) or (l_app_id IS NULL) THEN
      BEGIN
        SELECT responsibility_id, app_id INTO l_resp_id, l_app_id
        FROM asg_user_pub_resps
        WHERE user_name = p_user_name AND
              pub_name = 'SERVICEL';
      EXCEPTION
      WHEN OTHERS THEN
        NULL;
      END;
    END IF;

    IF (l_resp_id IS NOT NULL) AND (l_app_id IS NOT NULL) THEN
      UPDATE asg_user
      SET responsibility_id = l_resp_id, app_id = l_app_id
      WHERE user_name = p_user_name AND
            responsibility_id <> l_resp_id AND
            app_id <> l_app_id;
      COMMIT;
    END IF;
  END update_user_resps;

  --API for updating SYNCH_ERRORS column in asg_user table
  --not used currently
  PROCEDURE update_synch_errors(p_user_name IN VARCHAR2,p_mesg IN VARCHAR2)
    IS
  BEGIN
    UPDATE asg_user
    SET synch_errors = p_mesg,
        last_wireless_contact_date = sysdate
    WHERE user_name = p_user_name;
  END update_synch_errors;

--api to raise sync error event oracle.apps.asg.sync.failure
  PROCEDURE raise_sync_error_event(p_user_name IN VARCHAR2,p_message IN VARCHAR2)
  IS
   l_wf_param wf_event_t;
   l_sql VARCHAR2(400);
   l_device_type VARCHAR2(20);
   l_session_id NUMBER;
   l_sync_date DATE;
   l_sqlerrno VARCHAR2(20);
   l_sqlerrmsg VARCHAR2(2000);
  BEGIN

	l_sql:='select session_id,start_time,DEVICE_TYPE
	       from (select session_id,start_time,DECODE(DEVICE_PLATFORM,''WCE'',''WINCE'',''LAPTOP'') as DEVICE_TYPE
		   from '||asg_base.G_OLITE_SCHEMA||'.c$sync_history where client_id=:1 order by start_time desc) where rownum<2';

	EXECUTE IMMEDIATE l_sql INTO l_session_id,l_sync_date,l_device_type using p_user_name;

    wf_event_t.initialize(l_wf_param);
    l_wf_param.AddParameterToList('SESSION_ID',to_char(l_session_id));
	l_wf_param.AddParameterToList('TRAN_ID',asg_base.get_current_tranid);
	l_wf_param.AddParameterToList('CLIENT_ID',p_user_name);
	l_wf_param.AddParameterToList('ERROR_MSG',p_message);
	l_wf_param.AddParameterToList('DEVICE_TYPE',l_device_type);
	l_wf_param.AddParameterToList('SYNC_DATE',to_char(l_sync_date,'DD-MM-RRRR HH24:MI:SS'));
    wf_event.raise(p_event_name=>'oracle.apps.asg.sync.failure',
                   p_event_key=>to_char(l_session_id),p_parameters=>l_wf_param.getParameterList,
                   p_event_data=>null,p_send_date=>null);

   log('Raised event oracle.apps.asg.sync.failure','asg_helper.raise_sync_error_event',g_stmt_level);

  EXCEPTION
  WHEN others THEN
      l_sqlerrno := to_char(SQLCODE);
      l_sqlerrmsg := substr(SQLERRM, 1,2000);
      log('Failed raising event oracle.apps.asg.sync.failure - '||l_sqlerrno||':'||l_sqlerrmsg,'asg_helper.raise_sync_error_event',g_err_level);
  END raise_sync_error_event;

  --API for autonomous update of hwm_tranid and synch_errors.
  --if p_tranid is null the hwm_tranid col is not changed.
  PROCEDURE set_synch_errmsg(p_user_name IN VARCHAR2, p_tranid IN NUMBER,
			                 p_device_type IN VARCHAR2, p_mesg IN VARCHAR2)
    IS
    l_curid NUMBER;
    l_dml VARCHAR2(2000);
    l_ret NUMBER;
    l_pub_name varchar2(30);
    CURSOR get_pub(l_device_type varchar2) IS
      SELECT NAME FROM asg_pub WHERE device_type=l_device_type;

  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE asg_user
    SET synch_errors = p_mesg,
        cookie = nvl(p_device_type,cookie),
        hwm_tranid = nvl(p_tranid,hwm_tranid),
	    last_wireless_contact_date = sysdate
    WHERE user_name = p_user_name;
    -- update asg_user_pub_resp.synch_date
   OPEN get_pub(p_device_type);
    LOOP
      FETCH get_pub INTO l_pub_name;
      EXIT WHEN get_pub%NOTFOUND;
      log('Setting synch time for pub_name: '||l_pub_name,'asg_helper',g_stmt_level);
      UPDATE asg_user_pub_resps
      SET synch_date = sysdate
      WHERE user_name = p_user_name
      AND pub_name = l_pub_name;
    END LOOP;
    CLOSE get_pub;

--12.1.2
   IF(p_mesg IS NOT NULL) THEN
	raise_sync_error_event(p_user_name,p_mesg);
   END IF;

   COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  END set_synch_errmsg;

  -- Procedure to set the last synch device type
  PROCEDURE set_last_synch_device_type
    IS
  CURSOR c_users IS
    SELECT user_name
    FROM asg_user
    WHERE cookie is null;
  CURSOR c_user_devices (p_user_name VARCHAR2) IS
  SELECT distinct ap.device_type
  FROM asg_user_pub_resps aupr, asg_pub ap
  WHERE aupr.pub_name = ap.name and
        aupr.user_name = p_user_name and
        ap.device_type is not null;
  l_current_user          VARCHAR2(30);
  l_counter               NUMBER;
  l_user_synched          NUMBER;
  l_device_type           VARCHAR2(30);
  l_found_device_type     BOOLEAN;
  l_device_type_stored    NUMBER;
  l_sql_string            VARCHAR2(512);
  BEGIN

    -- Update users whose last synch device type is not yet set.
    -- Find the device type from asg_user_pub_resps and asg_pub
    -- For users with multiple devices query Oracle Lite tables
    -- If device type for last synch is not knowable, do not update asg_user
    FOR cu in c_users LOOP
      l_current_user := cu.user_name;
      l_counter := 0;
      l_found_device_type := FALSE;
      OPEN c_user_devices (l_current_user);
      LOOP
        FETCH c_user_devices INTO l_device_type;
        EXIT WHEN c_user_devices%NOTFOUND;
        l_counter := l_counter +1 ;
      END LOOP;
      CLOSE c_user_devices;

      -- If only one device type is found for this user
      -- Update the device type to the one we found
      IF (l_counter = 1) THEN
        UPDATE asg_user
        SET cookie = l_device_type
        WHERE user_name = l_current_user;
        l_found_device_type := TRUE;
      END IF;

      -- ok, multiple devices assigned to this user
      IF l_found_device_type = FALSE THEN
        l_sql_string := 'SELECT count(ws.os_name) ' ||
			'FROM ' ||
                          asg_base.G_OLITE_SCHEMA || '.wtg_sites ws, ' ||
                          asg_base.G_OLITE_SCHEMA || '.users usr, ' ||
                          asg_base.G_OLITE_SCHEMA || '.c$all_clients cac ' ||
		        'where cac.synctime_start is not null ' ||
			'and cac.clientid = usr.name and usr.id = ws.usr_id ' ||
			'and abs(cac.synctime_start-ws.last_sync) <= 1/24 ' ||
			'and ws.os_name is not null ' ||
                        'and usr.name = :1';

        EXECUTE IMMEDIATE l_sql_string
        INTO l_device_type_stored
        USING l_current_user;

        -- Users who synched from web-to-go (laptop) are remembered in wtg_sites
        -- So, if a record exists in this table, it means user synched from wtg
        IF l_device_type_stored > 0 THEN
          UPDATE asg_user
          SET cookie = 'LAPTOP'
          WHERE user_name = l_current_user;
        ELSE
          -- No device type found from last synch.
          -- Find out if the user ever synched
          l_sql_string := 'SELECT COUNT(*) ' ||
			  'FROM ' ||
                            asg_base.G_OLITE_SCHEMA || '.c$all_clients ' ||
                          'WHERE synctime_start is not null and ' ||
                                 'clientid = :1';
          EXECUTE IMMEDIATE l_sql_string
          INTO l_user_synched
          USING l_current_user;
          IF l_user_synched = 1 THEN
            UPDATE asg_user
            SET cookie = 'PALM'
            WHERE user_name = l_current_user;
          END IF;
        END IF;
      END IF;
    END LOOP;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  END set_last_synch_device_type;


  --Routine that sets up a user for complete refresh for a publication
  PROCEDURE set_first_synch(p_clientid in varchar2,p_pub in varchar2)
  is
    CURSOR c_custom_pub(l_pub_name VARCHAR2) IS
    SELECT nvl(custom, 'N')
    FROM asg_pub
    WHERE name = l_pub_name;
    l_custom_pub varchar2(2);
  PRAGMA autonomous_transaction;
  BEGIN
    IF(p_pub = 'ALL')
    THEN
      RETURN;
    END IF;

    OPEN c_custom_pub(p_pub);
    FETCH c_custom_pub INTO l_custom_pub;
    CLOSE c_custom_pub;
    if(l_custom_pub = 'Y')
    THEN
      RETURN;
    END IF;

    -- neither ALL nor custom publication..
	INSERT INTO
	asg_purge_sdq(user_name,pub_name,transaction_id,CREATION_DATE,CREATED_BY,
	LAST_UPDATE_DATE,LAST_UPDATED_BY)
	values(p_clientid,p_pub,null,sysdate,1,sysdate,1);
	commit;

	EXCEPTION
		WHEN DUP_VAL_ON_INDEX then
		UPDATE asg_purge_sdq
		SET transaction_id = null,last_update_date = SYSDATE
		WHERE user_name = p_clientid AND pub_name = p_pub;
		commit;
  END set_first_synch;


PROCEDURE set_sso_profile(p_userId in VARCHAR2)
       IS
       l_ret boolean;
       BEGIN
         l_ret:=fnd_profile.save('APPS_SSO_LOCAL_LOGIN','BOTH','USER',p_userId);
        commit;
        EXCEPTION
       WHEN OTHERS then
       rollback;
       END set_sso_profile;

  -- Routine for creating public synonyms
  PROCEDURE create_olite_synonyms
            IS
  CURSOR c_olite_objects IS
  SELECT object_name
  FROM dba_objects
  WHERE owner = 'MOBILEADMIN' AND
        object_type in ('TABLE', 'VIEW') AND
        object_name not like 'C__$%'
  UNION
  SELECT object_name
  FROM dba_objects
  WHERE owner = 'MOBILEADMIN' AND
        object_type in ('SEQUENCE') AND
        object_name not like 'M$%';
  l_sql_string VARCHAR2(512);
  BEGIN
    FOR cob IN c_olite_objects LOOP
      BEGIN
        l_sql_string := 'CREATE SYNONYM ' || cob.object_name ||
                        ' FOR MOBILEADMIN.' || cob.object_name;
        EXECUTE IMMEDIATE l_sql_string;
      EXCEPTION
      WHEN OTHERS THEN
        NULL; -- Ignore
      END;
    END LOOP;

  END create_olite_synonyms;

  -- Routine for dropping public synonyms
  PROCEDURE drop_olite_synonyms
            IS
  CURSOR c_olite_objects IS
  SELECT object_name
  FROM dba_objects
  WHERE owner = 'MOBILEADMIN' AND
        object_type in ('TABLE', 'VIEW') AND
        object_name not like 'C__$%'
  UNION
  SELECT object_name
  FROM dba_objects
  WHERE owner = 'MOBILEADMIN' AND
        object_type in ('SEQUENCE') AND
        object_name not like 'M$%';
  l_sql_string VARCHAR2(512);
  BEGIN
    FOR cob IN c_olite_objects LOOP
      BEGIN
        l_sql_string := 'DROP SYNONYM ' || cob.object_name;
        EXECUTE IMMEDIATE l_sql_string;
      EXCEPTION
      WHEN OTHERS THEN
        NULL; -- Ignore
      END;
    END LOOP;

  END drop_olite_synonyms;

  PROCEDURE recreate_synonyms(p_dt IN DATE)
  is
  BEGIN
    null;
  END recreate_synonyms;

  --This function taken a input String and a 8 byte key and encrypts the input
  --If the key is less than 8 bytes, then the error
  --"ORA-28234: key length too short" is thrown
  function encrypt(p_input_string varchar2,p_key varchar2)
  return varchar2
  is
  l_encrypted_string varchar2(1024);
  l_in_str varchar2(1024);
  l_pad_len NUMBER;
  begin
    l_in_str := p_input_string;
    -- If the string length is not a mutliple of 8
    if(mod(lengthb(p_input_string),8) <> 0) then
      -- Find the num of bytes to add to make it a multiple of 8
      l_pad_len := 8 - mod(lengthb(p_input_string),8);
      l_in_str := l_in_str || rpad(' ', l_pad_len, ' ');
    end if;

    DBMS_OBFUSCATION_toolkit.DES3Encrypt(input_string => l_in_str,
		key_string => p_key,encrypted_string => l_encrypted_string,
		which => 0);
    return l_encrypted_string;
  end encrypt;


  --This procedure encrypts p_input_string using the key p_key.
  --It then updates the asg_config param p_param_name
  procedure encrypt_and_copy(p_param_name varchar2,p_input_string varchar2,
                p_key varchar2,p_param_desc varchar2)
  is
  begin
    fnd_vault.put(g_svc, p_param_name, p_input_string);
  end encrypt_and_copy;

  procedure encrypt_old(p_param_name varchar2,p_input_string varchar2,
                p_key varchar2,p_param_desc varchar2)
  is
  l_encrypted_string varchar2(1024);
  l_in_str varchar2(1024);
  l_pad_len NUMBER;
  begin
    l_in_str := p_input_string;
    -- If the string length is not a mutliple of 8
    if(mod(lengthb(p_input_string),8) <> 0) then
      -- Find the num of bytes to add to make it a multiple of 8
      l_pad_len := 8 - mod(lengthb(p_input_string),8);
      l_in_str := l_in_str || rpad(' ', l_pad_len, ' ');
    end if;

    DBMS_OBFUSCATION_toolkit.DES3Encrypt(input_string => l_in_str,
        key_string => p_key,encrypted_string => l_encrypted_string,
        which => 0);
    set_config_param(p_param_name,l_encrypted_string,p_param_desc);
  end encrypt_old;

  --This function taken a input String and a 8 byte key and decrypts the input
  --If the key is less than 8 bytes, then the error
  --"ORA-28234: key length too short" is thrown
  function decrypt(p_input_string varchar2,p_key varchar2)
  return varchar2
  is
  l_decrypted_string varchar2(1024);
  begin
    DBMS_OBFUSCATION_toolkit.DES3Decrypt(input_string => p_input_string,
		key_string => p_key,decrypted_string => l_decrypted_string,
		which => 0);
    return l_decrypted_string;
  end decrypt;

  --This function reads the value of the asg_config param p_param_name
  --The value is decrypted using p_key and the decrypted string is returned.
  function decrypt_and_return(p_param_name varchar2,p_key varchar2)
  return varchar2
  is
  l_decrypted_string varchar2(1024);
  begin
    l_decrypted_string := fnd_vault.get(g_svc, p_param_name);
    return l_decrypted_string;
  end decrypt_and_return;

  function decrypt_old(p_param_name varchar2,p_key varchar2)
       return varchar2
  is
  l_decrypted_string varchar2(1024):= null;
  l_dec_str varchar2(1024);
  begin
    select value into l_dec_str from asg_config
    where name = p_param_name;

    DBMS_OBFUSCATION_toolkit.DES3Decrypt(input_string => l_dec_str,
        key_string => p_key,decrypted_string => l_decrypted_string,
        which => 0);
    return l_decrypted_string;
  exception
  when others then
    return l_decrypted_string;
  end decrypt_old;

  function get_key
       return varchar2
  is
  l_key         varchar2(128);
  l_schema_name varchar2(128);
  l_ASG_APP_ID  number := 689;
  begin
    select oracle_username into l_schema_name
    from fnd_oracle_userid
    where oracle_id = l_ASG_APP_ID;

    l_key := l_schema_name;
    l_key := rpad(l_key, 16, l_schema_name);
    return l_key;

  end get_key;


  --Sets a given profile value to null at all levels.
  procedure set_profile_to_null(p_profile_name varchar2)
  is
    cursor c_get_profile_option_id(l_profile_name varchar2)
    is
      select profile_option_id, application_id
      from fnd_profile_options
      where ( END_dATE_ACTIVE IS NULL OR END_dATE_ACTIVE > SYSDATE )
      AND profile_option_name =  l_profile_name;

   cursor c_profile_reset(l_app_id number, l_profile_id number,l_level_id number)
   is
     select profile_option_value,level_value,level_id
     from fnd_profile_option_values
     where  application_id = l_app_id and
            profile_option_id = l_profile_id and
            level_id = l_level_id ;

    l_profile_var c_profile_reset%rowtype;
    l_ret boolean;
    l_prof_id number;
    l_app_id number;
   begin
     --Get the profile option ID for the given profile option
     open c_get_profile_option_id(p_profile_name);
     fetch c_get_profile_option_id into l_prof_id, l_app_id;
     close c_get_profile_option_id;

     if(l_prof_id is not null)
     then
       --set to null at site level : 10001
       open c_profile_reset(l_app_id, l_prof_id,10001);
       loop
         fetch c_profile_reset into l_profile_var;
	 exit when c_profile_reset%NOTFOUND;
	 l_ret := fnd_profile.save(p_profile_name,null,'SITE');
       end loop;
       close c_profile_reset;

       --set to null  at application  level : 10002
       open c_profile_reset(l_app_id, l_prof_id,10002);
       loop
         fetch c_profile_reset into l_profile_var;
	 exit when c_profile_reset%NOTFOUND;
	 l_ret :=fnd_profile.save(p_profile_name,null,'APPL',
				  l_profile_var.level_value);
       end loop;
       close c_profile_reset;

       --set to null  at resp  level : 10003
       open c_profile_reset(l_app_id,l_prof_id,10003);
       loop
         fetch c_profile_reset into l_profile_var;
	 exit when c_profile_reset%NOTFOUND;
	 l_ret := fnd_profile.save(p_profile_name,null,'RESP',
			l_profile_var.level_value,l_app_id);
       end loop;
       close c_profile_reset;

       --set to null  at user  level : 10004
       open c_profile_reset(l_app_id, l_prof_id,10004);
       loop
         fetch c_profile_reset into l_profile_var;
	 exit when c_profile_reset%NOTFOUND;
	 l_ret := fnd_profile.save(p_profile_name,null,'USER',
				  l_profile_var.level_value);
       end loop;
       close c_profile_reset;
     end if;
     commit;
  end set_profile_to_null ;

  -- Just execute the grant string and dont raise any exceptions
  PROCEDURE grant_db_privilege (p_grant_string IN VARCHAR2)
            IS
  BEGIN
    EXECUTE IMMEDIATE p_grant_string;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END grant_db_privilege;

  -- Grants necessary select, insert privileges to mobile table/views to
  -- Olite db schema
  PROCEDURE enable_olite_privs
            IS
  CURSOR c_inq_outq_objects
         IS
    SELECT base_object_name, inq_name
    FROM asg_pub_item
    WHERE enabled = 'Y';
  l_olite_schema VARCHAR2(30);
  l_sql_string   VARCHAR2(4096);
  BEGIN
    l_olite_schema := asg_base.G_OLITE_SCHEMA;

    l_sql_string := 'GRANT SELECT ON ASG_SYSTEM_DIRTY_QUEUE TO '||
                    l_olite_schema;
    grant_db_privilege(l_sql_string);

    l_sql_string := 'GRANT SELECT ON ASG_DELETE_QUEUE TO '||
                    l_olite_schema;
    grant_db_privilege(l_sql_string);

    l_sql_string := 'GRANT SELECT ON ASG_SEQUENCE_PARTITIONS_V TO '||
                    l_olite_schema;
    grant_db_privilege(l_sql_string);

    l_sql_string := 'GRANT SELECT ON ASG_TEMP_LOB TO '||
                    l_olite_schema;
    grant_db_privilege(l_sql_string);


    /* Loop through all the pub-items and grant appropriate privileges */
    FOR c_ioq IN c_inq_outq_objects LOOP
      l_sql_string := 'GRANT SELECT ON '|| c_ioq.base_object_name ||
                      ' TO ' || l_olite_schema;
      grant_db_privilege(l_sql_string);

      l_sql_string := 'GRANT SELECT ON ' || c_ioq.inq_name ||
                      ' TO ' || l_olite_schema;
      grant_db_privilege(l_sql_string);
      l_sql_string := 'GRANT INSERT ON ' || c_ioq.inq_name ||
                      ' TO ' || l_olite_schema;
      grant_db_privilege(l_sql_string);
      l_sql_string := 'GRANT UPDATE ON ' || c_ioq.inq_name ||
                      ' TO ' || l_olite_schema;
      grant_db_privilege(l_sql_string);
      l_sql_string := 'GRANT DELETE ON ' || c_ioq.inq_name ||
                      ' TO ' || l_olite_schema;
      grant_db_privilege(l_sql_string);
    END LOOP;

  END enable_olite_privs;



END asg_helper;

/
