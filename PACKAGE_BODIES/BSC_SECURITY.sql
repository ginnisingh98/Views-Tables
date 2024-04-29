--------------------------------------------------------
--  DDL for Package Body BSC_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SECURITY" AS
/* $Header: BSCSSECB.pls 120.3 2006/01/24 16:10:11 calaw noship $ */

-- Global Variables
--
-- User_Info_Type
--
Type User_Info_Rec_Type Is Record (
        sid        NUMBER,
    user_id    NUMBER(15),
    user_name  VARCHAR2(100),
    user_pwd   VARCHAR2(100),
    user_type  NUMBER(1),
    obsc_un    VARCHAR2(100),
    obsc_pwd   VARCHAR2(100),
    ubsc_un    VARCHAR2(100),
    ubsc_pwd   VARCHAR2(100)
);

c_src_db_link       CONSTANT VARCHAR2(15) := 'BSC_SRC_DBLINK';


-- Public Functions and Procedures
--
-- Return the Bsc_user Table name, It is to keep the backward compatibility
-- It is called from OBSCPUB scheme, The tables are synonyms.
FUNCTION user_table_name RETURN VARCHAR IS
   h_table_name varchar2(30);
   CURSOR c_tables IS
        SELECT OBJECT_NAME
        FROM USER_OBJECTS
            WHERE OBJECT_NAME='BSC_USER';
BEGIN
    OPEN c_tables;
    FETCH c_tables INTO h_table_name;
   -- TEMPORAL
   IF c_tables%FOUND THEN
    h_table_name :='BSC_USER';
   ELSE
    h_table_name :='BSC_USERS';
   END IF;
   CLOSE c_tables;
   RETURN h_table_name;
END user_table_name;


--
-- Name
--   get_user_info
-- Purpose
--   Gets user_pwd, user_type and scheme un/pwd for OBSC and UBSC users.
--
-- Arguments
--   x_user_name
--   x_debug_flag
--   x_calling_fn
--
-- Overloaded procedure for VB code, since VB cannot read from PL/SQL
-- parameters.

PROCEDURE get_user_info(
                x_sid        IN VARCHAR2,
                x_user_name  IN VARCHAR2,
                x_debug_flag IN VARCHAR2 := 'NO',
                x_calling_fn IN VARCHAR2) IS

   h_current_fn VARCHAR2(128) := 'bsc_security.get_user_info';

   user_info    User_Info_Rec_Type;
   h_message    VARCHAR2(200);
   h_st_dt_chk  NUMBER(10);
   h_end_dt_chk NUMBER(10);

   h_undefined_user      EXCEPTION;
   h_login_expired       EXCEPTION;
   h_undefined_obsc_user EXCEPTION;
   h_undefined_ubsc_user EXCEPTION;

   l_sql_stmt       VARCHAR2(1024);
   l_curr           INTEGER;
   l_val            INTEGER;
BEGIN

   -- Enable dbms output

   IF (x_debug_flag = 'YES') THEN
      bsc_utility.enable_debug;
   END IF;

   user_info.sid       := TO_NUMBER(x_sid);
   user_info.user_name := UPPER(x_user_name);

--
-- Verify if the login user_name is correct
--

 BEGIN
   l_sql_stmt :='SELECT encrypted_user_password,';
   l_sql_stmt :=l_sql_stmt||'user_id, ';
   l_sql_stmt :=l_sql_stmt||'user_type, ';
   l_sql_stmt :=l_sql_stmt||' sysdate - start_date,';
   l_sql_stmt :=l_sql_stmt||' sysdate - end_date ';
   l_sql_stmt :=l_sql_stmt||' FROM '||user_table_name;
   l_sql_stmt :=l_sql_stmt||' WHERE ';
   l_sql_stmt :=l_sql_stmt||' user_name = :1';      --  fix for literals bug#3075851
   l_sql_stmt :=l_sql_stmt||' AND user_type <> :2'; --    "


   l_curr := dbms_sql.open_cursor;
   dbms_sql.parse(l_curr, l_sql_stmt, dbms_sql.native);
   dbms_sql.define_column(l_curr,1,user_info.user_pwd,100);
   dbms_sql.define_column(l_curr,2,user_info.user_id);
   dbms_sql.define_column(l_curr,3,user_info.user_type);
   dbms_sql.define_column(l_curr,4,h_st_dt_chk);
   dbms_sql.define_column(l_curr,5,h_end_dt_chk);
   dbms_sql.bind_variable(l_curr,':1',user_info.user_name); -- fix for literals bug#3075851
   dbms_sql.bind_variable(l_curr,':2',BSC_SECURITY.DB_USER_TYPE); --  "

   l_val := dbms_sql.execute(l_curr);
   IF dbms_sql.fetch_rows(l_curr)> 0 THEN
       dbms_sql.column_value(l_curr,1,user_info.user_pwd);
       dbms_sql.column_value(l_curr,2,user_info.user_id);
       dbms_sql.column_value(l_curr,3,user_info.user_type);
       dbms_sql.column_value(l_curr,4,h_st_dt_chk);
       dbms_sql.column_value(l_curr,5,h_end_dt_chk);
   END IF;
    dbms_sql.close_cursor(l_curr);
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      h_message := bsc_apps.get_message('BSC_INV_USER_NAME');
      RAISE h_undefined_user;
 END;

   IF (h_st_dt_chk < 0  OR h_end_dt_chk > 0) THEN
      h_message := bsc_apps.get_message('BSC_LOGIN_EXPIRED');
      RAISE h_login_expired;

   END IF;

   -- If valid user_name, get required info for OBSC application connection.
   -- Get OBSC username and encrypted password

 BEGIN

   l_sql_stmt :='SELECT ';
   l_sql_stmt :=l_sql_stmt||'user_name,';
   l_sql_stmt :=l_sql_stmt||'encrypted_user_password';
   l_sql_stmt :=l_sql_stmt||' FROM '||user_table_name;
   l_sql_stmt :=l_sql_stmt||' WHERE ';
   l_sql_stmt :=l_sql_stmt||' user_name LIKE ''OBSC%''';
   l_sql_stmt :=l_sql_stmt||' AND user_type = :1'; --||DB_USER_TYPE;
   l_curr := dbms_sql.open_cursor;
   dbms_sql.parse(l_curr, l_sql_stmt, dbms_sql.native);
   dbms_sql.define_column(l_curr,1,user_info.obsc_un,100);
   dbms_sql.define_column(l_curr,2,user_info.obsc_pwd,100);

   dbms_sql.bind_variable(l_curr,':1',DB_USER_TYPE); -- literals fix
   l_val := dbms_sql.execute(l_curr);

   IF dbms_sql.fetch_rows(l_curr)> 0 THEN
       dbms_sql.column_value(l_curr,1,user_info.obsc_un);
       dbms_sql.column_value(l_curr,2,user_info.obsc_pwd);
   ELSE
    user_info.obsc_un :=' ';
    user_info.obsc_pwd :=' ';
   END IF;
   dbms_sql.close_cursor(l_curr);
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      h_message := bsc_apps.get_message('BSC_INV_OBSC');
      RAISE h_undefined_obsc_user;
 END;

   -- Get UBSC username and encrypted password

 BEGIN

   l_sql_stmt := 'SELECT ';
   l_sql_stmt :=l_sql_stmt||'user_name,';
   l_sql_stmt :=l_sql_stmt||'encrypted_user_password';
   l_sql_stmt :=l_sql_stmt||' FROM '||user_table_name;
   l_sql_stmt :=l_sql_stmt||' WHERE ';
   l_sql_stmt :=l_sql_stmt||' user_name LIKE ''UBSC%''';
   l_sql_stmt :=l_sql_stmt||' AND user_type = :1'; --||DB_USER_TYPE;

   l_curr := dbms_sql.open_cursor;
   dbms_sql.parse(l_curr, l_sql_stmt, dbms_sql.native);
   dbms_sql.define_column(l_curr,1,user_info.ubsc_un,100);
   dbms_sql.define_column(l_curr,2,user_info.ubsc_pwd,100);

   dbms_sql.bind_variable(l_curr,':1',DB_USER_TYPE); -- literals fix
   l_val := dbms_sql.execute(l_curr);
   IF dbms_sql.fetch_rows(l_curr)> 0 THEN
       dbms_sql.column_value(l_curr,1,user_info.ubsc_un);
       dbms_sql.column_value(l_curr,2,user_info.ubsc_pwd);
   ELSE
    user_info.ubsc_un :=' ';
    user_info.ubsc_pwd :=' ';
   END IF;
   dbms_sql.close_cursor(l_curr);
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      h_message := bsc_apps.get_message('BSC_INV_UBSC');
      RAISE h_undefined_ubsc_user;
 END;
   INSERT INTO bsc_user_info(
    SID,
    USER_ID,
    USER_NAME,
    USER_PWD,
    USER_TYPE,
    OBSC_UN,
    OBSC_PWD,
    UBSC_UN,
    UBSC_PWD
   )
   (
      SELECT
        user_info.sid,
        user_info.user_id,
        user_info.user_name,
        user_info.user_pwd,
        user_info.user_type,
        user_info.obsc_un,
        user_info.obsc_pwd,
        user_info.ubsc_un,
        user_info.ubsc_pwd
      FROM
        dual
   );
EXCEPTION
   WHEN h_undefined_user THEN
        bsc_message.add('ERROR-', x_calling_fn, APP_ERR_MSG, 'I');
        bsc_message.add(h_message, h_current_fn, APP_ERR_MSG, 'I');

   WHEN h_login_expired THEN
        bsc_message.add('ERROR-', x_calling_fn, APP_ERR_MSG, 'I');
        bsc_message.add(h_message, h_current_fn, APP_ERR_MSG, 'I');

   WHEN h_undefined_obsc_user THEN
        bsc_message.add('ERROR-', x_calling_fn, APP_ERR_MSG, 'I');
        bsc_message.add(h_message, h_current_fn, APP_ERR_MSG, 'I');

   WHEN h_undefined_ubsc_user THEN
        bsc_message.add('ERROR-', x_calling_fn, APP_ERR_MSG, 'I');
        bsc_message.add(h_message, h_current_fn, APP_ERR_MSG, 'I');

   WHEN OTHERS THEN
        bsc_message.add('ERROR-', x_calling_fn, DB_ERR_MSG, 'I');
        bsc_message.add(SQLERRM, h_current_fn, DB_ERR_MSG, 'I');

END get_user_info;

--
-- Name
--   get_user_info
-- Purpose
--   Gets user_pwd, user_type and scheme un/pwd for OBSC and UBSC users.
--
-- Arguments
--   x_user_name
--   x_user_pwd
--   x_user_id
--   x_user_type
--   x_obsc_un
--   x_obsc_pwd
--   x_ubsc_un
--   x_ubsc_pwd
--   x_debug_flag
--   x_status
--   x_calling_fn
--

PROCEDURE get_user_info(
        x_user_name  IN     VARCHAR2,
        x_user_pwd   IN OUT NOCOPY VARCHAR2,
        x_user_id    IN OUT NOCOPY NUMBER,
        x_user_type  IN OUT NOCOPY NUMBER,
        x_obsc_un    IN OUT NOCOPY VARCHAR2,
        x_obsc_pwd   IN OUT NOCOPY VARCHAR2,
        x_ubsc_un    IN OUT NOCOPY VARCHAR2,
        x_ubsc_pwd   IN OUT NOCOPY VARCHAR2,
        x_debug_flag IN     VARCHAR2 := 'NO',
        x_status     IN OUT NOCOPY BOOLEAN,
        x_calling_fn IN     VARCHAR2) IS

   h_current_fn VARCHAR2(128) := 'bsc_security.get_user_info';

   h_count      NUMBER;
   h_session_id NUMBER;
   l_sql_stmt       VARCHAR2(1024);
   l_curr           INTEGER;
   l_val            INTEGER;


BEGIN

   select USERENV('SESSIONID')
   into   h_session_id
   from   dual;

   get_user_info(h_session_id,
         x_user_name,
         x_debug_flag,
         h_current_fn);

   SELECT COUNT(*)
   INTO   h_count
   FROM   bsc_message_logs
   WHERE
          type              IN (DB_ERR_MSG, APP_ERR_MSG)
   AND    source            = h_current_fn
   AND    Last_Update_Login = h_session_id;

   IF (h_count > 0) THEN
      x_status := FALSE;
   ELSE
      SELECT
                user_id,
                user_pwd,
                user_type,
                obsc_un,
                obsc_pwd,
                ubsc_un,
                ubsc_pwd
      INTO
                x_user_id,
                x_user_pwd,
                x_user_type,
                x_obsc_un,
                x_obsc_pwd,
                x_ubsc_un,
                x_ubsc_pwd
      FROM
                bsc_user_info
      WHERE
                sid = h_session_id;

      x_status := TRUE;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_status := FALSE;
      bsc_message.add('ERROR-', x_calling_fn, DB_ERR_MSG, 'I');
      bsc_message.add(SQLERRM, h_current_fn, DB_ERR_MSG, 'I');

END get_user_info;


--
-- Name
--   Check_System_Lock
-- Purpose
--   Enforce system locking for all OBSC models
--
-- Parameter:
--   x_program_id - program identifier, has the following value
--                   a. Loader                              =  -100
--                   b. Metadata Optimizer                  =  -200
--                   c. Security Wizard                     =  -300
--                   d. KPI Designer                        =  -400
--                   e. BSC Builder                         =  -500
--                   f. iViewer or VB Viewer (in user mode) =  -600
--                   g. Migration Backend Target            =  -800   added amitgupt 3013894
--                   h. Migration UI                        =  -801   added amitgupt 3013894
--                   i. Migration Backend Source            =  -802   added calaw 4648979
--   x_debug_flag  - debug flag
--   x_user_id     - Session Management, passed by OA Fwk for user name
--   x_icx_session_id - Session Management, passed by OA Fwk from IBuilder only
--                      Other OBSC clients will the first 3 parms.

Procedure Check_System_Lock(
        x_program_id            IN      Number,
        x_debug_flag            IN      Varchar2 := 'NO',
        x_user_id               IN      Number  :=NULL,
        x_icx_session_id        IN      Number  :=NULL
) Is

    l_calling_fn    Varchar2(80);
    l_message       Varchar2(2000);
    l_lock_msg          Varchar2(2000) := NULL;
    l_obsc_count    Number   := 0;

    BSC_Lock_Error  Exception;

    h_session_id    NUMBER;
    h_user_id       NUMBER;

    h_time_out      NUMBER := 1200; -- (1200segs = 20 minutes)

    CURSOR c_ksessions IS
        Select
            s.audsid,
            s.sid,
            s.serial#
        From
            v$session s,
            v$session_wait w,
            bsc_current_sessions c
        Where
            s.audsid = c.session_id And
            s.sid = w.sid And
            c.program_id = -600 And
            w.seconds_in_wait > h_time_out;

    h_ksession      c_ksessions%ROWTYPE;

    h_sql       VARCHAR2(2000);
    h_cursor        INTEGER;
    h_ret       INTEGER;
    h_program_id    NUMBER;
    h_username      VARCHAR2(100);
    h_machine       VARCHAR2(100);
    h_machine2      VARCHAR2(100);
    h_terminal      VARCHAR2(100);

    TYPE t_array_of_varchar2 IS TABLE OF VARCHAR2(500)
      INDEX BY BINARY_INTEGER;

    h_components    t_array_of_varchar2;

    l_count         NUMBER;

Begin
  -- Initialize BSC/APPS global variables
  BSC_APPS.Init_Bsc_Apps;

  BSC_MESSAGE.Init(X_Debug_Flag => x_debug_flag);

  l_calling_fn := 'BSC_SECURITY.CHECK_SYSTEM_LOCK';
  l_lock_msg := bsc_apps.get_message('BSC_SEC_LOCKED_SYSTEM');
  h_components(-100) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'BSC_LOADER'); -- Loader UI
  h_components(-101) := h_components(-100); -- Loader concurrent program
  h_components(-200) := bsc_apps.get_lookup_value('BSC_UI_COMMON', 'METADATA_OPTIMIZER');
  h_components(-201) := h_components(-200); --Generate documentation
  h_components(-202) := h_components(-200); --Rename input tables
  h_components(-300) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'BSC_ADMINISTRATOR');
  h_components(-400) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'KPI_DESIGNER');
  h_components(-500) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'BSC_BUILDER');
  h_components(-600) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'OBSC_VIEWER');
  h_components(-700) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'UPGRADE');
  h_components(-800) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'SYSTEM_MIGRATION'); -- Migration Backend Target
  h_components(-801) := h_components(-800); -- Migration UI
  h_components(-802) := h_components(-800); -- Migration Backend Source

  -- Ref: bug#3482442 In corner cases this query can return more than one
  -- row and it will fail. AUDSID is not PK. After meeting with
  -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
  h_session_id := USERENV('SESSIONID');
  h_user_id := BSC_APPS.fnd_global_user_id;

  -- Clean BSC_MESSAGE_LOGS for the current session
  DELETE bsc_message_logs
  WHERE last_update_login = h_session_id;
  commit;

  BSC_SECURITY.Refresh_System_Lock(x_program_id);
  -- Clean BSC_CURRENT_SESSIONS to leave only current sessions
  --Delete bsc_current_sessions
  --Where  session_id Not In (Select vs.audsid From V$Session vs);
  --commit;
  --
  -- Clean BSC_CURRENT_SESSIONS for ibuilder when users click "logout" button
  -- Added for BIS Application ID (191), so that loader session is not removed.
  -- Fix locking issue with icx sessions:
  -- We have found that we can call the api FND_SESSION_MANAGEMENT.Check_Session,
  -- passing the icx session id and it will return any 'VALID', 'INVALID' or 'EXPIRED'.
  -- This function does the validations to see if the icx session is valid or not and
  -- also if it has exprired. This is based on the values of TIME_OUT, TIME_LIMIT, GUEST,
  -- DISABLED, etc for the icx session.
  -- The value for TIME_LIMIT and TIME_OUT are from profiles at user level.
  -- TIME_LIMIT is always populated with a default value of 4 (4 hours).
  -- We need use the same logic FND is using to throw time out exception to the OA pages.
  -- If we do something different, we would need to modify all our OA pages to implement a new
  -- logic which has a big impact.
  --
  -- The icx session id is not re-used by FND, so we can take off the second condition:
  --    or (responsibility_application_id not in (271, 191))
  --
  --Delete bsc_current_sessions
  --Where  icx_session_id In (
  --    Select session_id
  --    From icx_sessions
  --    Where (fnd_session_management.check_session(session_id, null, null, 'N') <> 'VALID')
  --  );
  --commit;
  --
  --metadata optimizer , loader are conc requests.if the conc request is not running anymore
  --we can remove it from bsc_current_session
  --phase code of C means complete. the other phases are pending, running
  --Delete bsc_current_sessions
  --Where session_id in --(select nvl(oracle_session_id,-1) from fnd_concurrent_requests where phase_code='C'); --bug 3396460, optimized query
  --(select oracle_session_id from fnd_concurrent_requests f ,bsc_current_sessions  b where b.session_id = f.oracle_session_id and phase_code='C');
  --
  -- Kill IViewer Sessions that have been INACTIVE more than 20 minutes
  -- This is implemented only in APPS mode.
  -- Note: Only Architect can do it.
  --
  -- Bug#2145306: Since the IViewer sessions are returned to the pool after
  -- user exists and another application can use the same session, we cannot
  -- kill the session for any reason. What we can do is to delete the record
  -- from BSC_CURRENT_SESSIONS table.
  --
  --IF x_program_id <> -600 THEN
  --    IF BSC_APPS.APPS_ENV THEN
  --        OPEN c_ksessions;
  --        FETCH c_ksessions INTO h_ksession;
  --        WHILE c_ksessions%FOUND LOOP
  --            DELETE BSC_CURRENT_SESSIONS
  --            WHERE SESSION_ID = h_ksession.audsid;
  --            FETCH c_ksessions INTO h_ksession;
  --        END LOOP;
  --        CLOSE c_ksessions;
  --    END IF;
  --END IF;
  --
  -- Delete KILLED sessions from bsc_current_sesions
  -- Even tough we do not kill session, we can try this.
  --Delete bsc_current_sessions
  --Where  session_id In (Select vs.audsid From V$Session vs Where vs.status = 'KILLED');
  --commit;

  -- Make the query to validate if the application can run or not.
  IF x_program_id = -600 then
      -- iViewer.
      -- Several instances of iViewer can run at the same time.
      -- iViewer can run at the same time with Designer, Builder, Security, Loader and
      -- Metadata Optimizer.(Bug 3731337)
      -- iViewer cannot run at the same time with Migration, Upgrade

      -- fixed the following SQLS for the literals bug

      h_sql := 'SELECT c.program_id, u.user_name, s.machine, s.terminal'||
               ' FROM bsc_current_sessions c, v$session s, bsc_apps_users_v u'||
               ' WHERE c.session_id = s.audsid'||
               ' AND c.program_id in (-700, -800)'||
               ' AND c.session_id <> :1 '||
               ' AND c.user_id = u.user_id (+)';

  ELSIF x_program_id = -300 THEN
      -- Security
      -- Several instances can run at the same time.
      -- It can run at the same time with iViewer, Metadata Optimizer(Generate Documentation or Rename input tables)
      -- They cannot run at the same time with Loader or Metadata(Configure Indicators), Upgrade or Migration.
      h_sql := 'SELECT c.program_id, u.user_name, s.machine, s.terminal'||
               ' FROM bsc_current_sessions c, v$session s, bsc_apps_users_v u'||
               ' WHERE c.session_id = s.audsid'||
               ' AND c.program_id in (-100, -101, -200, -700, -800, -802)'||
               ' AND c.session_id <> :1 '||
               ' AND c.user_id = u.user_id (+)';

  ELSIF x_program_id IN (-400, -500) THEN
      -- Builder or Designer
      -- Several instances can run at the same time.
      -- They can run at the same time with iViewer, Security and Metadata Optimizer (Rename input tables)
      -- They cannot run at the same time with Loader, Metadata(Configure Indicators),
      -- Metadata Optmizer(Generate documention), Upgrade or Migration.
      h_sql := 'SELECT c.program_id, u.user_name, s.machine, s.terminal'||
               ' FROM bsc_current_sessions c, v$session s, bsc_apps_users_v u'||
               ' WHERE c.session_id = s.audsid'||
               ' AND c.program_id in (-100, -101, -200, -201, -700, -800, -802)'||
               ' AND c.session_id <> :1 '||
               ' AND c.user_id = u.user_id (+)';

  ELSIF x_program_id = -100 THEN
      -- Loader UI
      -- Only one instance at the same time.
      -- It cannot run at the same time with any other tool but IViewer and Metadata Optmizer(Generate documentation).
      h_sql := 'SELECT c.program_id, u.user_name, s.machine, s.terminal'||
               ' FROM bsc_current_sessions c, v$session s, bsc_apps_users_v u'||
               ' WHERE c.session_id = s.audsid'||
               ' AND c.program_id in (-100, -101, -200, -202, -300, -400, -500, -700, -800, -802)'||
               ' AND c.session_id <> :1'||
               ' AND c.user_id = u.user_id (+)';

  ELSIF x_program_id = -101 THEN
      -- Loader (Concurrent program)
      -- Only one instance at the same time.
      -- It cannot run at the same time with any other tool but IViewer and Metadata Optmizer(Generate documentation).
      -- It cannot run with other Loader Concurrent program but It can run with a Loader UI.
      h_sql := 'SELECT c.program_id, u.user_name, s.machine, s.terminal'||
               ' FROM bsc_current_sessions c, v$session s, bsc_apps_users_v u'||
               ' WHERE c.session_id = s.audsid'||
               ' AND c.program_id in (-101, -200, -202, -300, -400, -500, -700, -800, -802)'||
               ' AND c.session_id <> :1'||
               ' AND c.user_id = u.user_id (+)';


  ELSIF x_program_id = -200 THEN
      -- Metadata(Configure indicators)
      -- Only one instance at the same time.
      -- It can run at the same time with: IViewer (Bug 3731337)
      -- It cannot run at the same time with any other tool.
      h_sql := 'SELECT c.program_id, u.user_name, s.machine, s.terminal'||
               ' FROM bsc_current_sessions c, v$session s, bsc_apps_users_v u'||
               ' WHERE c.session_id = s.audsid'||
               ' AND c.program_id in (-100, -101, -200, -201, -202, -300, -400, -500, -700, -800, -802)'||
               ' AND c.session_id <> :1 '||
               ' AND c.user_id = u.user_id (+)';


  ELSIF x_program_id = -201 THEN
      -- Metadata Optimizer - Generate Documention
      -- Several instances can run at the same time.
      -- It can run at the same time with: Loader, Security and Viewer
      -- It cannot run at the same time with: Metadata Optimizer(Configure Indicators or Rename input tables),
      -- Builder, Designer, Upgrade or Migration
      h_sql := 'SELECT c.program_id, u.user_name, s.machine, s.terminal'||
               ' FROM bsc_current_sessions c, v$session s, bsc_apps_users_v u'||
               ' WHERE c.session_id = s.audsid'||
               ' AND c.program_id in (-200, -202, -400, -500, -700, -800, -802)'||
               ' AND c.session_id <> :1 '||
               ' AND c.user_id = u.user_id (+)';

  ELSIF x_program_id = -202 THEN
      -- Metadata Optimizer - Rename Input Tables
      -- It can run at the same time with: Security, Designer, Builder and Viewer
      -- It cannot run at the same time with: Metadata Optimizer(Configure Indicators or Rename input tables
      -- or Generate Documentation), Loader, Upgrade or Migration
      h_sql := 'SELECT c.program_id, u.user_name, s.machine, s.terminal'||
               ' FROM bsc_current_sessions c, v$session s, bsc_apps_users_v u'||
               ' WHERE c.session_id = s.audsid'||
               ' AND c.program_id in (-100, -101, -200, -201, -202, -700, -800, -802)'||
               ' AND c.session_id <> :1 '||
               ' AND c.user_id = u.user_id (+)';

  ELSIF x_program_id = -801 THEN
      -- Migration ui
      -- It cannot run if there is any other user in migration UI or migration CON req is running
      h_sql := 'SELECT c.program_id, u.user_name, s.machine, s.terminal'||
               ' FROM bsc_current_sessions c, v$session s, bsc_apps_users_v u'||
               ' WHERE c.session_id = s.audsid'||
               ' AND c.program_id in (-700, -800, -801, -802)'||
               ' AND c.session_id <> :1 '||
               ' AND c.user_id = u.user_id (+)';

  ELSIF x_program_id = -802 THEN
      -- Migration backend (source)
      -- iViewer can run with Migration backend (source)
      h_sql := 'SELECT c.program_id, u.user_name, s.machine, s.terminal'||
               ' FROM bsc_current_sessions c, v$session s, bsc_apps_users_v u'||
               ' WHERE c.session_id = s.audsid'||
               ' AND c.program_id in (-100, -101, -200, -201, -202, -300, -400, -500, -700, -800, -801)'||
               ' AND c.session_id <> :1 '||
               ' AND c.user_id = u.user_id (+)';

  ELSE
      -- Upgrade or Migration
      -- Only one instance at the same time.
      -- It cannot run at the same time with any other tool.
      -- code -801 added for migration UI. migration process can not run if any user is there in UI
      h_sql := 'SELECT c.program_id, u.user_name, s.machine, s.terminal'||
               ' FROM bsc_current_sessions c, v$session s, bsc_apps_users_v u'||
               ' WHERE c.session_id = s.audsid'||
               ' AND c.program_id in (-100, -101, -200, -201, -202, -300, -400, -500, -600, -700, -800, -801, -802)'||
               ' AND c.session_id <> :1 '||
               ' AND c.user_id = u.user_id (+)';
  END IF;

  h_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(h_cursor, h_sql, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN(h_cursor, 1, h_program_id);
  DBMS_SQL.DEFINE_COLUMN(h_cursor, 2, h_username, 100);
  DBMS_SQL.DEFINE_COLUMN(h_cursor, 3, h_machine, 100);
  DBMS_SQL.DEFINE_COLUMN(h_cursor, 4, h_terminal, 100);

  DBMS_SQL.BIND_VARIABLE(h_cursor,':1', h_session_id); -- fix for literals bug#3075851
  h_ret := DBMS_SQL.EXECUTE(h_cursor);

  IF DBMS_SQL.FETCH_ROWS(h_cursor) > 0 THEN
     DBMS_SQL.COLUMN_VALUE(h_cursor, 1, h_program_id);
     DBMS_SQL.COLUMN_VALUE(h_cursor, 2, h_username);
     DBMS_SQL.COLUMN_VALUE(h_cursor, 3, h_machine);
     DBMS_SQL.COLUMN_VALUE(h_cursor, 4, h_terminal);

     l_message := l_lock_msg;
     l_message := bsc_apps.replace_token(l_message, 'COMPONENT', h_components(h_program_id));
     l_message := bsc_apps.replace_token(l_message, 'USERNAME', h_username);

     --------------------------------------------------------------
     -- Jui Wang Apr/05/2001
     -- Delete the invisible char, trailing CHR(0), from h_machine
     -- Also close the cursor before raise BSC_Lock_Error
     --------------------------------------------------------------
     h_machine2 := REPLACE(h_machine, CHR(0));
     l_message := bsc_apps.replace_token(l_message, 'MACHINE', h_machine2);
     l_message := bsc_apps.replace_token(l_message, 'TERMINAL', h_terminal);
     DBMS_SQL.CLOSE_CURSOR(h_cursor);
     raise BSC_Lock_Error;
  END IF;
  DBMS_SQL.CLOSE_CURSOR(h_cursor);

  -- register the process in bsc_current_sessions
  -- 08/29/02 COMENT OUT NOCOPY USER_ID until this column is approved; Approved USER_ID column on 09/09/02
  -- 03/18/03 Approved ICX_SESSOIN_ID column on 03/18/03, fix bug#2728234


  -- added for Enh#2983050
  select count(session_id)
  into l_count
  from bsc_current_sessions
  where (session_id = h_session_id) and (icx_session_id = x_icx_session_id) and (program_id = x_program_id);

  if (l_count = 0) then -- Entry for the same session and program exists
       Insert Into bsc_current_sessions
         (SESSION_ID,PROGRAM_ID,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,USER_ID, ICX_SESSION_ID)
       Values (h_session_id, x_program_id, h_user_id, SYSDATE, h_user_id, SYSDATE, h_session_id,x_user_id, x_icx_session_id);
  end if;

  COMMIT;

Exception
    WHEN BSC_Lock_Error THEN
      BSC_MESSAGE.Add(
                X_Message => l_message,
                X_Source  => l_calling_fn,
                X_Mode    => 'I');

    WHEN Others THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source  => l_calling_fn,
                X_Mode    => 'I');

End Check_System_Lock;


--
-- Name
--   Refresh_System_Lock
-- Purpose
--   Cleanup BSC_CURRENT_SESSIONS table before acquiring locks
--   Called by BSC_SECURITY.CHECK_SYSTEM_LOCK and BSC_LOCKS_PUB.GET_SYSTEM_LOCK
--   1) Delete all orphan the sessions
--   2) Delete all the session not being reused by FND
--   3) Delete all sessions, which have their concurrent programs in invalid or hang status
--   4) Kill IViewer Sessions that have been INACTIVE more than 20 minutes
--   5) Delete all the Killed Sessions

Procedure Refresh_System_Lock(
    p_program_id      IN      Number
) IS
    CURSOR c_sessions IS
    SELECT session_id
    FROM   bsc_current_sessions
    WHERE  program_id IN (-100,-101,-200,-201,-202,-800,-802);

    l_session_ids       VARCHAR2(8000);
    l_sql               VARCHAR2(8000);

BEGIN
    --Delete all orphan the sessions
    DELETE BSC_CURRENT_SESSIONS
    WHERE  SESSION_ID NOT IN
           (SELECT VS.AUDSID
            FROM V$SESSION VS);

    --Delete all the session not being reused by FND
    DELETE BSC_CURRENT_SESSIONS
    WHERE  ICX_SESSION_ID IN (
            SELECT SESSION_ID
            FROM ICX_SESSIONS
            WHERE (FND_SESSION_MANAGEMENT.CHECK_SESSION(SESSION_ID,NULL,NULL,'N') <> 'VALID'));

    --Delete all sessions, which have their concurrent programs in invalid or hang status
    FOR cd IN c_sessions LOOP
      IF(l_session_ids IS NULL ) THEN
         l_session_ids := cd.session_id;
      ELSE
         l_session_ids := l_session_ids ||','||cd.session_id;
      END IF;
    END LOOP;
    IF(l_session_ids IS NOT NULL) THEN
       l_sql  := ' DELETE bsc_current_sessions'||
                 ' WHERE session_id IN ('||
                   ' SELECT oracle_session_id '||
                   ' FROM   fnd_concurrent_requests  '||
                   ' WHERE  program_application_id = 271 '||
                   ' AND    oracle_session_id IN ('||l_session_ids ||' )'||
                   ' AND    phase_code=''C'')';
       EXECUTE IMMEDIATE l_sql ;
    END IF;
    --DELETE BSC_CURRENT_SESSIONS
    --WHERE SESSION_ID IN (
    --        SELECT NVL(ORACLE_SESSION_ID, -1)
    --        FROM  FND_CONCURRENT_REQUESTS
    --        WHERE PHASE_CODE = 'C');

    -- Kill IViewer Sessions that have been INACTIVE more than 20 minutes
    IF p_program_id <> -600 THEN
        IF BSC_APPS.APPS_ENV THEN
            DELETE BSC_CURRENT_SESSIONS
            WHERE  PROGRAM_ID = -600
            AND    SESSION_ID IN (
                       SELECT s.audsid
                       FROM   v$session s, v$session_wait w
                       WHERE  s.sid = w.sid
                       AND    w.seconds_in_wait > 1200);
        END IF;
    END IF;

    --Delete all the Killed Sessions
    DELETE BSC_CURRENT_SESSIONS
    WHERE  SESSION_ID IN (
           SELECT VS.AUDSID
           FROM V$SESSION VS
           WHERE VS.STATUS = 'KILLED');
    COMMIT;
END Refresh_System_Lock;


--
-- Name
--   Check_Source_System_Lock
-- Purpose
--   Enforce system locking for all OBSC models in the source system
--   This is issued by Migration (-800)
--
-- Parameter:
--   x_debug_flag  - debug flag

Procedure Check_Source_System_Lock(
        x_debug_flag            IN      Varchar2 := 'NO'
) Is

    l_calling_fn    Varchar2(80);
    l_message       Varchar2(2000);
    l_lock_msg          Varchar2(2000) := NULL;
    l_obsc_count    Number   := 0;

    BSC_Lock_Error  Exception;

    h_session_id    NUMBER;
    h_user_id       NUMBER;
    h_src_session_id    NUMBER;
    h_src_user_id   NUMBER;

    h_sql       VARCHAR2(2000);
    h_cursor        INTEGER;
    h_ret       INTEGER;
    h_program_id    NUMBER;
    h_username      VARCHAR2(100);
    h_machine       VARCHAR2(100);
    h_terminal      VARCHAR2(100);

    TYPE t_array_of_varchar2 IS TABLE OF VARCHAR2(500)
      INDEX BY BINARY_INTEGER;

    h_components    t_array_of_varchar2;

Begin
  -- Initialize BSC/APPS global variables
  BSC_APPS.Init_Bsc_Apps;

  BSC_MESSAGE.Init(X_Debug_Flag => X_Debug_Flag);

  l_calling_fn := 'BSC_SECURITY.CHECK_SOURCE_SYSTEM_LOCK';
  l_lock_msg := bsc_apps.get_message('BSC_SEC_LOCKED_SRC_SYSTEM');
  h_components(-100) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'BSC_LOADER'); -- Loader UI
  h_components(-101) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'BSC_LOADER'); -- Loader Concurrent program
  h_components(-200) := bsc_apps.get_lookup_value('BSC_UI_COMMON', 'METADATA_OPTIMIZER');
  h_components(-201) := bsc_apps.get_lookup_value('BSC_UI_COMMON', 'METADATA_OPTIMIZER'); -- Generate documentation
  h_components(-202) := bsc_apps.get_lookup_value('BSC_UI_COMMON', 'METADATA_OPTIMIZER'); -- Rename input tables
  h_components(-300) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'BSC_ADMINISTRATOR');
  h_components(-400) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'KPI_DESIGNER');
  h_components(-500) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'BSC_BUILDER');
  h_components(-600) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'OBSC_VIEWER');
  h_components(-700) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'UPGRADE');
  h_components(-800) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'SYSTEM_MIGRATION');

  -- Get the session id in the source system
/*  changed to fixed bug 2669465
  h_sql := 'select s.user#, s.audsid'||
           ' from v$session@'||c_src_db_link||' s'||
           ' where s.process = ('||
           ' select vs.process'||
           ' from v$session vs'||
           ' where vs.audsid = userenv(''SESSIONID'')'||
           ' )';   */
  h_sql := 'select s.user#, s.audsid from bsc_session_v@'||c_src_db_link||' s';

  h_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(h_cursor, h_sql, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN(h_cursor, 1, h_src_user_id);
  DBMS_SQL.DEFINE_COLUMN(h_cursor, 2, h_src_session_id);
  h_ret := DBMS_SQL.EXECUTE(h_cursor);

  IF DBMS_SQL.FETCH_ROWS(h_cursor) > 0 THEN
    DBMS_SQL.COLUMN_VALUE(h_cursor, 1, h_src_user_id);
    DBMS_SQL.COLUMN_VALUE(h_cursor, 2, h_src_session_id);
  END IF;
  DBMS_SQL.CLOSE_CURSOR(h_cursor);


  -- Get the session id in the current(target) system
  -- Ref: bug#3482442 In corner cases this query can return more than one
  -- row and it will fail. AUDSID is not PK. After meeting with
  -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
  h_session_id := USERENV('SESSIONID');
  h_user_id := BSC_APPS.fnd_global_user_id;

  -- Clean BSC_MESSAGE_LOGS for the current session
  DELETE bsc_message_logs
  WHERE last_update_login = h_session_id;
  commit;

  -- Clean BSC_CURRENT_SESSIONS in the source system to leave only current sessions
  h_sql := 'Delete bsc_current_sessions@'||c_src_db_link||
           ' Where session_id Not In (Select audsid From V$Session@'||c_src_db_link||')';
  BSC_APPS.Execute_Immediate(h_sql);

  commit;

  -- Delete KILLED sessions from bsc_current_sessions
  h_sql := 'Delete bsc_current_sessions@'||c_src_db_link||
           ' Where  session_id In (Select audsid From V$Session@'||c_src_db_link||
           ' Where status = ''KILLED'')';
  BSC_APPS.Execute_Immediate(h_sql);

  commit;

  -- Make the query to validate if the application can run or not.
  -- This procedure is called by MIgration (-800)
  -- Only one instance at the same time.
  -- It cannot run at the same time with any other tool.
  h_sql := 'SELECT c.program_id, s.username, s.machine, s.terminal'||
           ' FROM bsc_current_sessions@'||c_src_db_link||' c, v$session@'||c_src_db_link||' s'||
           ' WHERE c.session_id = s.audsid'||
           ' AND c.program_id in (-100, -101, -200, -201, -202, -300, -400, -500, -600, -700, -800)'||
           ' AND c.session_id <> :1 ';

  h_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(h_cursor, h_sql, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN(h_cursor, 1, h_program_id);
  DBMS_SQL.DEFINE_COLUMN(h_cursor, 2, h_username, 100);
  DBMS_SQL.DEFINE_COLUMN(h_cursor, 3, h_machine, 100);
  DBMS_SQL.DEFINE_COLUMN(h_cursor, 4, h_terminal, 100);

  DBMS_SQL.BIND_VARIABLE(h_cursor,':1', h_src_session_id); -- fixed for literals bug
  h_ret := DBMS_SQL.EXECUTE(h_cursor);

  IF DBMS_SQL.FETCH_ROWS(h_cursor) > 0 THEN
     DBMS_SQL.COLUMN_VALUE(h_cursor, 1, h_program_id);
     DBMS_SQL.COLUMN_VALUE(h_cursor, 2, h_username);
     DBMS_SQL.COLUMN_VALUE(h_cursor, 3, h_machine);
     DBMS_SQL.COLUMN_VALUE(h_cursor, 4, h_terminal);

     l_message := l_lock_msg;
     l_message := bsc_apps.replace_token(l_message, 'COMPONENT', h_components(h_program_id));
     l_message := bsc_apps.replace_token(l_message, 'USERNAME', h_username);
     l_message := bsc_apps.replace_token(l_message, 'MACHINE', h_machine);
     l_message := bsc_apps.replace_token(l_message, 'TERMINAL', h_terminal);

     raise BSC_Lock_Error;
  END IF;
  DBMS_SQL.CLOSE_CURSOR(h_cursor);

  -- register the process in bsc_current_sessions
  h_sql := 'Insert Into bsc_current_sessions@'||c_src_db_link||
       ' (SESSION_ID,PROGRAM_ID,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)'||
           ' Values ('||h_src_session_id||', -800, '||h_src_user_id||', SYSDATE, '||
           h_src_user_id||', SYSDATE, '||h_src_session_id||')';
  BSC_APPS.Execute_Immediate(h_sql);

  COMMIT;

Exception
    WHEN BSC_Lock_Error THEN
      BSC_MESSAGE.Add(
                X_Message => l_message,
                X_Source  => l_calling_fn,
                X_Mode    => 'I');

    WHEN Others THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source  => l_calling_fn,
                X_Mode    => 'I');

End Check_Source_System_Lock;


/*
   ADRAO 18-JUL-03 Modified for Global Button Enhancement.

   Added Exception Block.
*/


PROCEDURE Delete_Bsc_Session IS

    l_calling_fn    Varchar2(80);
    l_message       Varchar2(2000);

    BSC_Lock_Error  Exception;

BEGIN
    l_calling_fn := 'BSC_SECURITY.DELETE_BSC_SESSION';

    DELETE BSC_CURRENT_SESSIONS
    WHERE SESSION_ID = USERENV('SESSIONID');
    COMMIT;

Exception
    WHEN BSC_Lock_Error THEN
      BSC_MESSAGE.Add(
                X_Message => l_message,
                X_Source  => l_calling_fn,
                X_Mode    => 'I');

    WHEN Others THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source  => l_calling_fn,
                X_Mode    => 'I');

END Delete_Bsc_Session;


/*
   ADRAO 18-JUL-03 Added for Global Button Enhancement.

   Added Exception Block.
*/


PROCEDURE Delete_Bsc_Session_ICX(
        p_icx_session_id        IN              NUMBER
) IS

    BSC_Lock_Error  Exception;

    l_calling_fn    Varchar2(80);
    l_message       Varchar2(2000);

BEGIN

    l_calling_fn := 'BSC_SECURITY.DELETE_BSC_SESSION_ICX';

    IF (p_icx_session_id IS NOT NULL) THEN
        DELETE BSC_CURRENT_SESSIONS
        WHERE ICX_SESSION_ID = p_icx_session_id;

        COMMIT;
    END IF;

EXCEPTION
    WHEN BSC_Lock_Error THEN
      BSC_MESSAGE.Add(
                X_Message => l_message,
                X_Source  => l_calling_fn,
                X_Mode    => 'I');

    WHEN Others THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source  => l_calling_fn,
                X_Mode    => 'I');

END Delete_Bsc_Session_ICX;

--
-- Name
--   user_has_lock
-- Purpose
--   Return Y if user holds locks
--       else return N
-- Parameter:
--   x_SID - Sessuib ID that user currently belongs

FUNCTION user_has_lock (
  X_SID in NUMBER
) RETURN VARCHAR2 is

  l_count number;
  yes_no varchar2(1);
  h_sql VARCHAR2(2000);
  TYPE t_cursor IS REF CURSOR;
  h_cursor t_cursor;

begin

     return user_has_lock(X_SID,BSC_APPS.get_user_schema);
     /*yes_no :='N';
     -- bug fix 3008243

     h_sql :='SELECT count(*) FROM dba_objects A, v$locked_object B'||
             ' WHERE A.OBJECT_ID = B.OBJECT_ID AND A.OWNER = BSC_APPS.get_user_schema AND OBJECT_NAME LIKE ''BSC%'' AND SESSION_ID = :1';

     OPEN h_cursor FOR h_sql USING X_SID;
     FETCH h_cursor INTO l_count;
    IF h_cursor%NOTFOUND  THEN
       yes_no := 'N';
       l_count := 0;
    END IF;
     CLOSE h_cursor;

     if l_count > 0 then
        yes_no :='Y';
    end if;

    RETURN yes_no;*/
end user_has_lock;
--
-- Name
--   user_has_lock
-- Purpose
--   Return Y if user holds locks
--       else return N
-- Parameter:
--   x_SID - Sessuib ID that user currently belongs
--   x_Schema - BSC schema name performance improvement

FUNCTION user_has_lock (
  X_SID in NUMBER,
  X_SCHEMA IN VARCHAR2
) RETURN VARCHAR2 is

  l_count number;
  yes_no varchar2(1);
  h_sql VARCHAR2(2000);
  TYPE t_cursor IS REF CURSOR;
  h_cursor t_cursor;

begin

     yes_no :='N';
     -- bug fix 3008243

     h_sql :='SELECT count(B.OBJECT_ID) FROM all_objects A, v$locked_object B'||
             ' WHERE  B.OBJECT_ID = A.OBJECT_ID AND A.OWNER = :1 AND OBJECT_NAME LIKE ''BSC%'' AND  SESSION_ID = :2';

     OPEN h_cursor FOR h_sql USING X_SCHEMA, X_SID;
     FETCH h_cursor INTO l_count;
     IF h_cursor%NOTFOUND  THEN
       yes_no := 'N';
       l_count := 0;
     END IF;
     CLOSE h_cursor;

     if l_count > 0 then
        yes_no :='Y';
     end if;

    RETURN yes_no;
end user_has_lock;

--
-- Name
--   can_meta_run
-- Purpose
--   Return Y if no user holds any locks and Meta Optimizer can start running
--       else return N
--

FUNCTION can_meta_run
RETURN VARCHAR2 is

  l_count number;
  yes_no varchar2(1);
  h_sql VARCHAR2(2000);
  TYPE t_cursor IS REF CURSOR;
  h_cursor t_cursor;

begin

     yes_no :='Y';
      -- bug fix 3008243

     h_sql :='SELECT count(*) FROM dba_objects A, v$locked_object B'||
              ' WHERE A.OBJECT_ID = B.OBJECT_ID AND A.OWNER = BSC_APPS.get_user_schema AND OBJECT_NAME LIKE ''BSC%''';

     OPEN h_cursor FOR h_sql;
     FETCH h_cursor INTO l_count;
    IF h_cursor%NOTFOUND  THEN
       yes_no := 'Y';
       l_count := 0;
    END IF;
     CLOSE h_cursor;

     if l_count > 0 then
        yes_no :='N';
    end if;

    RETURN yes_no;
end can_meta_run;

--
-- Name
--   is_meta_inside
-- Purpose
--   Return Y if Meta Optimizer is inside the system
--       else return N

FUNCTION is_meta_inside
RETURN VARCHAR2 is

  l_count number;
  yes_no varchar2(1);
  h_sql VARCHAR2(2000);
  TYPE t_cursor IS REF CURSOR;
  h_cursor t_cursor;

begin

     h_sql :='SELECT COUNT(*) FROM BSC_CURRENT_SESSIONS C, V$SESSION S, V$SESSION_WAIT W, BSC_APPS_USERS_V U ';
     h_sql :=  h_sql || 'WHERE C.SESSION_ID = S.AUDSID AND S.SID = W.SID AND S.STATUS <> ''KILLED'' AND U.USER_ID = C.USER_ID AND C.PROGRAM_ID = -200';

     yes_no :='N';
     -- bug fix 3008243

     h_sql :='SELECT count(*) FROM dba_objects A, v$locked_object B'||
             ' WHERE A.OBJECT_ID = B.OBJECT_ID AND A.OWNER = BSC_APPS.get_user_schema AND OBJECT_NAME LIKE ''BSC%''';

     OPEN h_cursor FOR h_sql;
     FETCH h_cursor INTO l_count;
    IF h_cursor%NOTFOUND  THEN
       yes_no := 'N';
       l_count := 0;
    END IF;
     CLOSE h_cursor;

     if l_count > 0 then
        yes_no :='Y';
    end if;

    RETURN yes_no;
end is_meta_inside;


END bsc_security;

/
