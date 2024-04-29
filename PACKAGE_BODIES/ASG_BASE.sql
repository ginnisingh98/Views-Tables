--------------------------------------------------------
--  DDL for Package Body ASG_BASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_BASE" AS
/*$Header: asgbaseb.pls 120.5.12010000.5 2009/09/03 08:49:46 ravir ship $*/

-- DESCRIPTION
--  Contains functions to retrieve information during a synch session.
--
--
-- HISTORY
--   02-sep-2005 rsripada   Multiple Responsibility Support
--   23-dec-2004 rsripada   Fix Bug 4086602
--   12-aug-2004 ssabesan   Added device switch changes ( bug 3824280 )
--   02-jun-2004 rsripada   Add function to download attachments
--   12-may-2004 ssabesan   Fix GSCC warning - Standard File.Sql.6
--   17-mar-2004 rsripada   Modified reset_all_globals
--   27-may-2003 ssabesan   Merged the branch line with main line
--   09-may-2003 rsripada   Added get_last_synch_date(p_user_id) API
--   31-mar-2003 rsripada   Modify init method to pass last_synch_date
--   28-mar-2003 rsripada   Get last synch date from asg_user
--   11-feb-2003 rsripada   Added get_upload_tranid, set_upload_tranid
--   09-feb-2003 rsripada   Modify find_pub_item to always return a value
--   06-jan-2003 ssabesan   checking whether logging is enabled before invoking
--			                the logging procedure.
--   12-sep-2002 vekrishn   Fix for bug 2565884
--   10-jul-2002 vekrishn   Commented out logging in get_current_tran_id and
--                          get_last_synch_date
--   28-jun-2002 vekrishn   Added logging for GET_CURRENT_TRANID and
--                          get_last_synch_date
--   25-jun-2002 rsripada   Remove dependencies on Olite schema
--   29-may-2002 rsripada   Added logging support
--   15-may-2002 rsripada   Added procedures to set pub items
--   25-apr-2002 rsripada   Added functions for debug logging
--   18-apr-2002 rsripada   Added functions for online queries etc.
--   29-mar-2002 rsripada   Created


  /* Global Variables
       glsd - get_last_synch_date
       ifs  - is_first_synch
       gdt  - get_dml_type
  */

  g_last_pub_item_name_glsd   VARCHAR2(30);
  g_pub_item_last_synch_date  DATE;
  g_last_pub_item_name_ifs    VARCHAR2(30);
  g_comp_ref_ifs              CHAR(1);
  g_last_pub_item_name_gdt    VARCHAR2(30);
  g_dml_type_gdt              VARCHAR2(1);

  g_stmt_level NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_err_level NUMBER := FND_LOG.LEVEL_ERROR;


  g_max_allowed_size          NUMBER  := NULL;
  g_current_size              NUMBER  := 0;
  g_atmt_size_exceeded        BOOLEAN := FALSE;

  g_olite_version             VARCHAR2(30) := NULL;

  FUNCTION find_pub_item(p_pub_item_name IN VARCHAR2)
    return PLS_INTEGER IS
  l_item_index PLS_INTEGER := -1;
  BEGIN
    FOR curr_index in 1..g_pub_item_tbl.count LOOP
      IF(g_pub_item_tbl(curr_index).name = p_pub_item_name) THEN
        return curr_index;
      END IF;
    END LOOP;
    return l_item_index;
  END find_pub_item;


  /* Useful for debugging */
  /* Logs all session information */
  PROCEDURE print_all_globals
            IS
  TYPE vc256_tbl_type is table of varchar2(256) index by binary_integer;
  sql_string_tbl vc256_tbl_type;
  BEGIN
   sql_string_tbl(1) := '****             Session Variables for this '
                        || 'Synch '||
                        '            ****';
   sql_string_tbl(2) := 'Current User is    : ' || get_user_name;
   sql_string_tbl(3) := '  Resource ID      : ' || get_resource_id;
   sql_string_tbl(4) := '  User ID          : ' || get_user_id;
   sql_string_tbl(5) := '  Language         : ' || get_language;
   sql_string_tbl(6) := '  Current Tran id  : ' || get_current_tranid;
   sql_string_tbl(7) := '  Last Tran id     : ' || get_last_tranid;
   sql_string_tbl(8) := '  Last Synch Date  : ' ||
                    to_char(get_last_synch_date, 'DD-MON-YYYY HH24:MI:SS');

   FOR curr_index in 1..g_pub_item_tbl.count LOOP
     IF (curr_index = 1) THEN
       sql_string_tbl(9)   := 'Publication Items that will be downloaded:';
     END IF;
     sql_string_tbl(9+curr_index) :=
        '  Publication Item: ' || g_pub_item_tbl(curr_index).name ||
        ' Complete Refresh: ' || g_pub_item_tbl(curr_index).comp_ref;
   END LOOP;

   BEGIN
     FOR curr_index in 1..sql_string_tbl.count LOOP
       IF(asg_helper.check_is_log_enabled(g_stmt_level))
       THEN
         asg_helper.log(sql_string_tbl(curr_index),
	                    'asg_base',g_stmt_level);
       END IF;
     END LOOP;
   EXCEPTION
   WHEN OTHERS THEN
     NULL;
   END;

  END print_all_globals;

  /* get user name for the specified resource_id */
  FUNCTION get_user_name(p_resource_id IN NUMBER)
           return VARCHAR2 IS
  CURSOR C_USER_NAME(p_resource_id NUMBER) IS
    SELECT user_name
    FROM asg_user
    WHERE resource_id = p_resource_id;
  l_user_name  asg_user.user_name%type;
  BEGIN

    OPEN C_USER_NAME(p_resource_id);
    FETCH C_USER_NAME into l_user_name;
    CLOSE C_USER_NAME;
    return l_user_name;

  END get_user_name;

  /* get resource_id for user_name */
  FUNCTION get_resource_id(p_user_name VARCHAR2)
    return NUMBER IS
  CURSOR C_RESOURCE(p_user_name varchar2) IS
    SELECT resource_id
    FROM asg_user
    WHERE user_name = p_user_name;
  l_resource_id number;
  BEGIN

    OPEN C_RESOURCE(p_user_name);
    FETCH C_RESOURCE into l_resource_id;
    CLOSE C_RESOURCE;
    return l_resource_id;

  END get_resource_id;

  /* get user_id for user_name */
  FUNCTION get_user_id(p_user_name VARCHAR2)
    return NUMBER IS
  CURSOR C_USER(p_user_name varchar2) IS
    SELECT user_id
    FROM asg_user
    WHERE user_name = p_user_name;
  l_user_id number;
  BEGIN

    OPEN C_USER(p_user_name);
    FETCH C_USER into l_user_id;
    CLOSE C_USER;
    return l_user_id;

  END get_user_id;

 /* get mobile responsibility for user_name */
  FUNCTION get_resp_id(p_user_name VARCHAR2)
    return NUMBER IS
  CURSOR C_RESP(p_user_name varchar2) IS
    SELECT responsibility_id
    FROM asg_user
    WHERE user_name = p_user_name;
  l_resp_id number;
  BEGIN

    OPEN C_RESP(p_user_name);
    FETCH C_RESP into l_resp_id;
    CLOSE C_RESP;
    return l_resp_id;

  END get_resp_id;

  /* get language for user */
  FUNCTION get_language(p_user_name VARCHAR2)
    return VARCHAR2 IS
  CURSOR C_LANGUAGE(p_user_name varchar2) IS
    SELECT language
    FROM asg_user
    WHERE user_name = p_user_name;
  l_language VARCHAR2(4);
  BEGIN

    OPEN C_LANGUAGE(p_user_name);
    FETCH C_LANGUAGE into l_language;
    CLOSE C_LANGUAGE;
    return l_language;

  END get_language;

  /* get application_id for user */
  FUNCTION get_application_id(p_user_name VARCHAR2)
    return NUMBER IS
  CURSOR C_APP(p_user_name varchar2) IS
    SELECT app_id
    FROM asg_user
    WHERE user_name = p_user_name;
  l_app_id number;
  BEGIN
    OPEN C_APP(p_user_name);
    FETCH C_APP INTO l_app_id;
    CLOSE C_APP;
    return l_app_id;
  END get_application_id;

  /* get last successful synch date */
  /* Internal function for use only by this package */
  FUNCTION get_last_synch_date_internal(p_user_name VARCHAR2)
    return DATE IS
  l_last_synch_date       DATE;
  BEGIN

    SELECT last_synch_date_end into l_last_synch_date
    FROM asg_user
    WHERE user_name = p_user_name;

    return l_last_synch_date;

  END get_last_synch_date_internal;

  /* get resource_id */
  FUNCTION get_resource_id
    return NUMBER IS
  BEGIN
    return g_resource_id;
  END get_resource_id;

  /* get user_id */
  FUNCTION get_user_id
    return NUMBER IS
  BEGIN
    return g_user_id;
  END get_user_id;

  /* get responsibility_id */
  FUNCTION get_resp_id
    return NUMBER IS
  BEGIN
    return g_resp_id;
  END get_resp_id;

  /* get language */
  FUNCTION get_language
    return VARCHAR2 IS
  BEGIN
    return g_language;
  END get_language;

  /* get application_id */
  FUNCTION get_application_id
    return NUMBER IS
  BEGIN
    return g_application_id;
  END get_application_id;

  /* get user name */
  FUNCTION get_user_name
    return VARCHAR2 IS
  BEGIN
    return g_user_name;
  END get_user_name;

  /* get last successful synch date */
  FUNCTION get_last_synch_date
    return DATE IS
  BEGIN
    return g_last_synch_date;
  END get_last_synch_date;

  /* Checks if the passed in publication item is going to be completely refreshed   */
  /* ands returns G_OLD_DATE. Otherwise, gets last successful synch date */
  FUNCTION get_last_synch_date(p_pub_item_name IN VARCHAR2)
    return DATE IS
  BEGIN

    IF (p_pub_item_name = g_last_pub_item_name_glsd) THEN
      RETURN g_pub_item_last_synch_date;
    ELSE
      g_last_pub_item_name_glsd := p_pub_item_name;
      IF(is_first_synch(p_pub_item_name) = G_YES) THEN
        g_pub_item_last_synch_date := G_OLD_DATE;
      ELSE
        g_pub_item_last_synch_date := g_last_synch_date;
      END IF;
      RETURN g_pub_item_last_synch_date;
    END IF;

  END get_last_synch_date;

  /* Get current download tran id */
  FUNCTION get_current_tranid
    return NUMBER IS
  BEGIN
    return g_download_tranid;
  END get_current_tranid;

  /* Get current download tran id */
  FUNCTION get_current_tranid (p_pub_item_name IN VARCHAR2)
    return NUMBER IS
  BEGIN
    return g_download_tranid;
  END get_current_tranid;

  /* Get last download tran id */
  FUNCTION get_last_tranid
    return NUMBER IS
  BEGIN
    return g_last_tranid;
  END get_last_tranid;

  /* Sets the upload tranid */
  FUNCTION get_upload_tranid
    return NUMBER IS
  BEGIN
    return g_upload_tranid;
  END get_upload_tranid;


  /* get dml type based on creation_date, update_date and */
  /* last_synch_date. Will return either G_INS or G_UPD */
  FUNCTION get_dml_type(p_creation_date IN DATE)
    return VARCHAR2 IS
  BEGIN
    -- g_last_synch_date IS NULL means no synch completed successfully
    -- or the user has never synched.
    IF ((g_last_synch_date IS NULL) OR
        (p_creation_date > g_last_synch_date)) THEN
      return G_INS;
    ELSE
      return G_UPD;
    END IF;
  END get_dml_type;

  /* get dml type based on update date and publication name */
  /* For publications that will be completely refreshed the */
  /* DML type will be insert (G_INS)                        */
  FUNCTION get_dml_type(p_pub_item_name IN VARCHAR2,
                        p_creation_date IN DATE)
    return VARCHAR2 IS
  BEGIN
    -- g_last_synch_date IS NULL means no synch completed successfully
    -- or the user has never synched.
    -- Skip check for complete_refresh if p_creation_date is
    -- greater than last_synch_date

    IF (p_pub_item_name = g_last_pub_item_name_gdt) THEN
      RETURN g_dml_type_gdt;
    ELSE
      g_last_pub_item_name_gdt := p_pub_item_name;
      IF ((g_last_synch_date IS NULL) OR
          (p_creation_date > g_last_synch_date) OR
          (is_first_synch(p_pub_item_name) = G_YES)) THEN
        g_dml_type_gdt := G_INS;
      ELSE
        g_dml_type_gdt := G_UPD;
      END IF;
      RETURN g_dml_type_gdt;
    END IF;
  END get_dml_type;

  /* returns 'Y' if the publication item will be completely */
  /* refreshed */
  FUNCTION is_first_synch(p_pub_item_name IN VARCHAR2)
    return VARCHAR2 IS
  l_pub_index PLS_INTEGER := 0;
  BEGIN

    IF (p_pub_item_name = g_last_pub_item_name_ifs) THEN
      RETURN g_comp_ref_ifs;
    ELSE
      g_last_pub_item_name_ifs := p_pub_item_name;
      l_pub_index := find_pub_item(p_pub_item_name);
      -- If publication item is not found return complete refresh
      IF (l_pub_index <> -1) THEN
        g_comp_ref_ifs := g_pub_item_tbl(l_pub_index).comp_ref;
      ELSE
        g_comp_ref_ifs := G_YES;
      END IF;
      RETURN g_comp_ref_ifs;
    END IF;

  END is_first_synch;

  /* Initializes the global variables during synch session */
  PROCEDURE init(p_user_name IN VARCHAR2, p_last_tranid IN NUMBER,
                 p_curr_tranid IN NUMBER,
                 p_last_synch_date IN DATE,
                 p_pub_items pub_item_tbl_type)
            IS
  BEGIN
    g_user_name := p_user_name;
    g_last_tranid := p_last_tranid;
    g_download_tranid := p_curr_tranid;
    g_language := get_language(p_user_name);
    g_resource_id := get_resource_id(p_user_name);
    g_user_id := get_user_id(p_user_name);
    g_resp_id := get_resp_id(p_user_name);
    g_application_id := get_application_id(p_user_name);
    if(p_last_synch_date IS NOT NULL) THEN
      g_last_synch_date := p_last_synch_date;
    ELSE
      g_last_synch_date := get_last_synch_date_internal(p_user_name);
    END IF;

    IF (p_pub_items IS NOT NULL) AND (p_pub_items.count > 0) THEN
      g_pub_item_tbl := g_empty_pub_item_tbl;
      FOR curr_index in 1..p_pub_items.count LOOP
        g_pub_item_tbl(curr_index).name     := p_pub_items(curr_index).name;
        g_pub_item_tbl(curr_index).comp_ref := p_pub_items(curr_index).comp_ref;
      END LOOP;
    END IF;

   END init;


  /* Initializes the global pubitem table with specified items */
  PROCEDURE set_pub_items(p_pub_items pub_item_tbl_type)
            IS
  BEGIN
    IF (p_pub_items IS NOT NULL) THEN
      g_pub_item_tbl := g_empty_pub_item_tbl;
      FOR curr_index in 1..p_pub_items.count LOOP
        g_pub_item_tbl(curr_index).name     :=p_pub_items(curr_index).name;
        g_pub_item_tbl(curr_index).comp_ref :=p_pub_items(curr_index).comp_ref;
      END LOOP;
    ELSE
      -- Set the pub item to empty
      g_pub_item_tbl := g_empty_pub_item_tbl;
    END IF;

  END set_pub_items;

  /* Sets the specified pub item for complete refresh */
  PROCEDURE set_complete_refresh(p_pub_item_name VARCHAR2)
            IS
  l_item_index PLS_INTEGER;
  BEGIN
    -- Return if the pub item table is not setup
    IF (g_pub_item_tbl IS NULL) OR
       (g_pub_item_tbl.count = 0) THEN
      return;
    END IF;
    l_item_index := find_pub_item(p_pub_item_name);

    -- If the item was found
    IF (l_item_index <> -1) THEN
      g_pub_item_tbl(l_item_index).comp_ref := G_YES;
    END IF;

  END set_complete_refresh;

  /* Sets the upload tranid */
  PROCEDURE set_upload_tranid(p_upload_tranid IN NUMBER)
    IS
  BEGIN
    g_upload_tranid := p_upload_tranid;
  END set_upload_tranid;

  /* Initializes the global variables with specified values.
     Use for debug only                                       */
  PROCEDURE init_debug(p_user_name IN VARCHAR2, p_language IN VARCHAR2,
                       p_resource_id IN NUMBER, p_user_id IN NUMBER,
                       p_resp_id IN NUMBER,
                       p_application_id IN NUMBER, p_last_synch_date IN DATE)
    IS
  BEGIN

    g_user_name := p_user_name;
    g_language := p_language;
    g_resource_id := p_resource_id;
    g_user_id := p_user_id;
    g_resp_id := p_resp_id;
    g_application_id := p_application_id;
    g_last_synch_date := p_last_synch_date;

  END init_debug;

  /* Resets all global variables to null */
  PROCEDURE reset_all_globals
    IS
  BEGIN
    g_user_name := null;
    g_language := null;
    g_resource_id := null;
    g_user_id := null;
    g_resp_id := null;
    g_application_id := null;
    g_last_synch_date := null;
    g_download_tranid := null;
    g_upload_tranid := null;
    g_last_tranid := null;
    g_pub_item_tbl := g_empty_pub_item_tbl;

    g_last_pub_item_name_glsd    := null;
    g_pub_item_last_synch_date   := null;
    g_last_pub_item_name_ifs     := null;
    g_comp_ref_ifs               := null;
    g_last_pub_item_name_gdt     := null;
    g_dml_type_gdt               := null;
    g_is_auto_sync 		 := null;
  END reset_all_globals;

  /*get the last synch date of a user*/
  FUNCTION get_last_synch_date(p_user_id IN NUMBER)
    RETURN DATE IS
  l_date DATE;
  BEGIN
    SELECT last_synch_date_end  INTO l_date
    FROM asg_user WHERE user_id = p_user_id;
    RETURN l_date;
  END get_last_synch_date;

  /* Allow download of attachment based on size */
  FUNCTION allow_att_download(p_row_num IN NUMBER,
                              p_blob    IN BLOB)
    RETURN VARCHAR2 IS
  l_max_size_str          VARCHAR2(100);
  l_csm_app_id            NUMBER := 883;
  l_ret_value             VARCHAR2(1) := 'N';
  BEGIN

    /* Very first row, find profile option value once per synch. */
    IF (p_row_num = 1) THEN
      g_max_allowed_size := NULL;
      g_atmt_size_exceeded := FALSE;
      g_current_size := 0;
      l_max_size_str := fnd_profile.VALUE_SPECIFIC(
                                    name => 'CSM_MAX_ATTACHMENT_SIZE',
                                    user_id => g_user_id,
                                    responsibility_id => null,
                                    application_id => l_csm_app_id);

      IF (l_max_size_str IS NOT NULL) THEN
        BEGIN
          g_max_allowed_size := to_number(l_max_size_str);
          /* Convert MB to bytes */
          g_max_allowed_size := g_max_allowed_size*1024*1024;
        EXCEPTION
        WHEN OTHERS THEN
          /* Implies the profile value is not a purely numeric value */
          g_max_allowed_size := NULL;
          return l_ret_value;
        END;
      END IF;
    END IF;

    IF (g_max_allowed_size IS NOT NULL AND
        g_atmt_size_exceeded = FALSE) THEN
      /* Length is returned in bytes */
      g_current_size := g_current_size + dbms_lob.getlength(p_blob);
      IF (g_current_size <= g_max_allowed_size) THEN
        l_ret_value := 'Y';
      ELSE
        g_atmt_size_exceeded := TRUE;
      END IF;
    END IF;

    return l_ret_value;

  END allow_att_download;

  /* Allow download of attachment based on size */
  FUNCTION allow_attachment_download(p_row_num IN NUMBER,
                                     p_blob    IN BLOB)
    RETURN VARCHAR2 IS
  BEGIN
    return 'Y';
  END allow_attachment_download;

  --Function to return the current device type as a number.
  --returns 200 for laptop synch, 100 for PPC and 0 for others
  FUNCTION get_device_type
    RETURN NUMBER is
  l_dev_name varchar2(30);
  l_str varchar2(1024);
  BEGIN
    l_str := 'select '||G_OLITE_SCHEMA||'.CONS_EXT.GET_CURR_DEVICE from dual';
    execute immediate l_str into l_dev_name;
    if l_dev_name = 'WTG' THEN
      return 200;
    elsif l_dev_name = 'WCE' THEN
      return 100;
    else
      RETURN 0;
    end if;
  END get_device_type;

  --Function to return the current device type.
  FUNCTION get_device_type_name
    RETURN varchar2 is
  l_dev_name varchar2(30);
  l_str varchar2(1024);

  BEGIN
    l_str := 'select '||G_OLITE_SCHEMA||'.CONS_EXT.GET_CURR_DEVICE from dual';
    execute immediate l_str into l_dev_name;
    g_is_auto_sync := is_auto_sync();
    if ((l_dev_name = 'WTG') OR (l_dev_name = 'WIN32') ) THEN
      return 'LAPTOP';
    elsif l_dev_name = 'WCE' THEN
      return 'WINCE';
    else
      RETURN 'UNKNOWNDEVICE';
    end if;
  END get_device_type_name;

  procedure detect_device_switch(p_user_name IN varchar2,
                                 p_device_type OUT NOCOPY varchar2)
    is
  l_curr_dev_type varchar2(30);
  l_prev_dev_type varchar2(30);
  l_qry_string varchar2(512);
  cursor c_get_dev_type(l_user_name varchar2) is
    select current_device from asg_user where user_name = l_user_name;
  l_version NUMBER;
  l_param VARCHAR2(30) := 'VERSION';
  begin
    IF (g_olite_version IS NULL) THEN
      l_qry_string := 'SELECT value ' ||
                      'FROM ' || asg_base.G_OLITE_SCHEMA || '.c$all_config ' ||
                      'WHERE param = :1';
      EXECUTE IMMEDIATE l_qry_string
      INTO g_olite_version
      USING l_param;
    END IF;
    l_version := to_number(substr(g_olite_version,1,instr(g_olite_version,'.')-1));
    asg_helper.log('Olite version : '||g_olite_version,'asg_base',g_stmt_level);
    if(l_version < 10) then
      asg_helper.log('Not checking for device switch since Olite version is '||
                     'less than 10.0.0.0.0','asg_base',g_stmt_level);
    else
      asg_helper.log('Checking for device switch','asg_base',g_stmt_level);
      open c_get_dev_type(p_user_name);
      fetch c_get_dev_type into l_prev_dev_type;
      close c_get_dev_type;

      l_curr_dev_type := get_device_type_name;
      p_device_type := l_curr_dev_type;
      asg_helper.log('Previous device : '||l_prev_dev_type,'asg_base',g_stmt_level);
      asg_helper.log('Current device : '||l_curr_dev_type,'asg_base',g_stmt_level);

      if (l_prev_dev_type is null) then
        /*First time synch*/
	-- commented for Deadlock issue
        -- update asg_user set current_device = l_curr_dev_type
        -- where user_name = p_user_name;
	asg_helper.log('First Time Synch.Device type is set only now',
                      'asg_base',g_stmt_level);
      elsif(l_prev_dev_type <> l_curr_dev_type ) then
        /*device switch detected .Set to complete refresh*/
        l_qry_string := 'update '||asg_base.G_OLITE_SCHEMA||'.c$pub_list_q '
                        ||'set comp_ref = ''Y'' '||' where name IN '
                        ||' ( select item_id from asg_pub_item)' ;
        execute immediate l_qry_string;
	-- commented for Deadlock issue
        -- update asg_user set current_device = l_curr_dev_type
        -- where user_name = p_user_name;
        asg_helper.log('Device switch detected. Doing complete refresh',
                      'asg_base',g_stmt_level);
      else
        /*Device type is same.Do nothing*/
        null;
      end if;
    end if;
    exception
    when others then
      asg_helper.log('Exception in detect_device_switch',
                     'asg_base',g_stmt_level);
  end detect_device_switch;

  -- Returns G_YES if the user is a valid MFS user
  FUNCTION is_mobile_user(p_user_id IN NUMBER)
    RETURN VARCHAR2 IS
  l_ret_value VARCHAR2(1) := G_NO;
  l_cnt       NUMBER := 0;
  BEGIN
    SELECT count(*) into l_cnt
    FROM asg_user
    WHERE user_id = p_user_id AND enabled = 'Y';
    IF (l_cnt = 1) THEN
      l_ret_value := G_YES;
    END  IF;
    return l_ret_value;
  END is_mobile_user;

  -- Returns a list of all valid mobile users
  FUNCTION get_mobile_users(p_device_type IN VARCHAR2)
    RETURN mobile_user_list_type IS
  CURSOR c_user_list
    IS
  SELECT user_id
  FROM asg_user
  WHERE enabled = 'Y';
  l_user_list mobile_user_list_type;
  BEGIN
    IF (p_device_type <> G_ALL_DEVICES AND
        p_device_type <> G_POCKETPC    AND
        p_device_type <> G_LAPTOP ) THEN
      -- return empty user_list
      return l_user_list;
    END IF;
    IF (p_device_type = G_ALL_DEVICES) THEN
      OPEN c_user_list;
      FETCH c_user_list BULK COLLECT INTO l_user_list;
      CLOSE c_user_list;
      return l_user_list;
    END IF;

  END get_mobile_users;

  -- Returns the appid/respid used when creating this user
  PROCEDURE get_user_app_responsibility(p_user_id IN NUMBER,
                                        p_app_id  OUT NOCOPY NUMBER,
                                        p_resp_id OUT NOCOPY NUMBER)
    IS
  BEGIN
    p_app_id := NULL;
    p_resp_id := NULL;

    SELECT app_id, responsibility_id into p_app_id, p_resp_id
    FROM asg_user
    WHERE user_id = p_user_id and enabled = 'Y';

  END get_user_app_responsibility;

  /** Function to tell if it's a auto Sync */
  FUNCTION is_auto_sync RETURN VARCHAR2 IS
    l_str VARCHAR2 (300);
    l_autosync   VARCHAR2(1);
  BEGIN
    l_str := 'select '||G_OLITE_SCHEMA||'.CONS_EXT.IS_AUTO_SYNC from dual';

    BEGIN
      EXECUTE IMMEDIATE l_str INTO l_autosync;

      EXCEPTION
      WHEN OTHERS THEN
        /* When exception a normal sync*/
        l_autosync := 'N';
	IF(asg_helper.check_is_log_enabled(g_err_level))
        THEN
         asg_helper.log('Exception in is_auto_sync: ' || sqlerrm ,
                            'asg_base',g_stmt_level);
        END IF;
     END;

      IF(asg_helper.check_is_log_enabled(g_stmt_level))
       THEN
         asg_helper.log('is_auto_sync: Auto Sync is: '|| l_autosync ,
                            'asg_base',g_stmt_level);
       END IF;

       RETURN l_autosync;

  END is_auto_sync;

  /** Function to tell if it's a download only Sync */
  FUNCTION is_download_only_sync (p_client_id IN VARCHAR2,
				  p_tran_id IN NUMBER )RETURN VARCHAR2 IS
    l_download_only     VARCHAR2(1);
    l_dml		VARCHAR2(4000);
    l_cursor_id         NUMBER;
    l_rc                         NUMBER;

  BEGIN
	l_download_only := 'N';
	l_cursor_id := DBMS_SQL.OPEN_CURSOR;

	l_dml :=  'SELECT nvl(download_only,''N'')  FROM csm_auto_sync_inq '
                || ' WHERE clid$$cs = :1  AND tranid$$ = :2 ';

      	DBMS_SQL.PARSE (l_cursor_id, l_dml, DBMS_SQL.v7);
      	DBMS_SQL.BIND_VARIABLE(l_cursor_id ,':1',p_client_id);
      	DBMS_SQL.BIND_VARIABLE(l_cursor_id ,':2',p_tran_id);
      	DBMS_SQL.DEFINE_COLUMN (l_cursor_id, 1,l_download_only,1);

      	l_rc := DBMS_SQL.EXECUTE (l_cursor_id);

      	IF ( DBMS_SQL.FETCH_ROWS(l_cursor_id) > 0 ) THEN
            DBMS_SQL.COLUMN_VALUE (l_cursor_id, 1, l_download_only);
	ELSE
	    l_download_only := 'N';
      	END IF;

	DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

        IF(asg_helper.check_is_log_enabled(g_stmt_level)) THEN
            asg_helper.log('is_download_only_sync: is: '|| l_download_only ,
                            'asg_base',g_stmt_level);
        END IF;

        RETURN l_download_only;

  END is_download_only_sync;

END asg_base;

/
