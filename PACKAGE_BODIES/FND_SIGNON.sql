--------------------------------------------------------
--  DDL for Package Body FND_SIGNON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SIGNON" as
/* $Header: AFSCSGNB.pls 120.8.12010000.10 2015/02/25 04:48:15 absandhw ship $ */


--
-- GENERIC_ERROR (Internal)
--
-- Set error message and raise exception for unexpected sql errors.
--
procedure GENERIC_ERROR(routine in varchar2,
                        errcode in number,
                        errmsg in varchar2) is
begin
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', errmsg);
    app_exception.raise_exception;
end;

--
-- AUDIT_FORM_END (Internal) - Signon audit mark form endtimes
--
-- Stamp end_time of current record in soa forms table.
-- BUG:6076369, modified signature to include date argument so that
-- FNDDLTMP.sql/ICXDLTMP.sql can pass in LAST_CONNECT value to AUDIT_USER_END.
--
procedure AUDIT_FORM_END(login_id in number, pend_time in date default SYSDATE) is
pragma AUTONOMOUS_TRANSACTION;
begin
    if login_id is null then
	return;
    end if;

    -- Stamp end time on any current form for this login in FLRF
    UPDATE FND_LOGIN_RESP_FORMS FLRF
    SET END_TIME = pend_time
    WHERE FLRF.LOGIN_ID = audit_form_end.login_id
    AND FLRF.END_TIME is NULL;

    COMMIT;
exception
when no_data_found then
    null;
end AUDIT_FORM_END;

--
-- AUDIT_RESPONSIBILITY_END (Internal) - Signon audit mark resp endtimes
--
-- Stamp end_time of current record in soa resps table.
--
-- Bug:6076369, modified signature to include a date argument so that
-- ICXDLTMP.sql/FNDDLTNP.sql can pass in LAST_CONNECT value to AUDIT_USER_END.
--
procedure AUDIT_RESPONSIBILITY_END(login_id in number,pend_time in date default
SYSDATE) is
pragma AUTONOMOUS_TRANSACTION;
begin
    if login_id is null then
	return;
    end if;

    -- Stamp end time on any current resp for this login in FLR
    UPDATE FND_LOGIN_RESPONSIBILITIES FLR
    SET END_TIME = pend_time
    WHERE FLR.LOGIN_ID = audit_responsibility_end.login_id
    AND FLR.END_TIME is NULL;

    -- End any open forms
    AUDIT_FORM_END(login_id,pend_time);
    COMMIT;
exception
when no_data_found then
    null;
end AUDIT_RESPONSIBILITY_END;

--
-- AUTH_LOGOUT_UPD (added for bug 18903648)
--
--
procedure AUTH_LOGOUT_UPD(p_pid number,
                          p_pend_time date) is

   TYPE Ty_rowid IS TABLE OF ROWID
   INDEX BY BINARY_INTEGER;

   L_ROWID Ty_rowid;

   cursor get_upd_rowid is
      select c_log.rowid
      from fnd_logins c_log
      where c_log.spid = p_pid
      and end_time is null
      FOR UPDATE SKIP LOCKED;

begin

   open get_upd_rowid;

   LOOP
      FETCH get_upd_rowid BULK COLLECT
      INTO L_Rowid LIMIT 1000;

      IF L_Rowid.COUNT > 0 THEN

         FORALL I IN L_Rowid.FIRST .. L_rowid.LAST
            UPDATE /*+ rowid(FL) */ FND_LOGINS FL
            SET FL.END_TIME = p_pend_time
            WHERE FL.ROWID = L_Rowid(i);

            COMMIT;
      END IF;

      EXIT WHEN get_upd_rowid%NOTFOUND;

   END LOOP;

   CLOSE get_upd_rowid;

end auth_logout_upd;

--
-- AUDIT_USER_END (Internal) - Signon audit mark user endtimes
--
-- Set end_time or current record in soa logins table.
--
-- BUG:6076369, modified signature to include date argument so that
-- FNDDLTMP.sql/ICXDLTMP.sql can pass in LAST_CONNECT value to AUDIT_USER_END.
--
procedure AUDIT_USER_END(login_id in number, pend_time in date default SYSDATE) is
pragma AUTONOMOUS_TRANSACTION;
l_spid varchar2(30);
begin

    if login_id is null then
	return;
    else
      -- Get the processes for this login_id as the same SPID will be associated
      -- with different login_ids
      select spid into l_spid from fnd_logins
      where login_id = audit_user_end.login_id;
    end if;

    -- Stamp end time on current login in FL

    UPDATE FND_LOGINS FL
    SET END_TIME = pend_time
    WHERE FL.LOGIN_ID = audit_user_end.login_id
    AND END_TIME IS NULL;

    -- End any open resps
    AUDIT_RESPONSIBILITY_END(login_id, pend_time);

    -- Bug 11904176: end date the associated SPIDs
    -- Bug 18903648, performance fix for multiple users
    if (l_spid is not null) then
       -- Call an AUTONOMOUS_TRANSACTION to do the udpate
       auth_logout_upd (l_spid , pend_time);
    end if;


    COMMIT;

exception
when no_data_found then
    null;
end AUDIT_USER_END;

--
-- AUDIT_FORM - Signon audit form begin | end
--
-- If END_FORM
--   Stamp end time on current form record.
-- If BEGIN_FORM
--   Insert new soa record for form level auditing.
--
procedure AUDIT_FORM(login_id in number,
                     login_resp_id in number,
                     form_application in varchar2,
                     form_name in varchar2,
                     audit_level in varchar2 DEFAULT 'D',
                     begin_flag in number DEFAULT 0) is
pragma AUTONOMOUS_TRANSACTION;
begin
    if (begin_flag = 0) then
        --
        -- END_FORM call
        -- Stamp end time on current form record.
	--
        begin
        -- JWSMITH bug 1879642 - added FLRF.END_TIME is null
            UPDATE FND_LOGIN_RESP_FORMS FLRF
            SET END_TIME = SYSDATE
            WHERE FLRF.LOGIN_ID = audit_form.login_id
            AND FLRF.LOGIN_RESP_ID = audit_form.login_resp_id
            AND FLRF.END_TIME IS NULL
	    AND (FLRF.FORM_ID, FLRF.FORM_APPL_ID) =
		(SELECT F.FORM_ID, F.APPLICATION_ID
		 FROM FND_FORM F, FND_APPLICATION A
                 WHERE F.FORM_NAME = audit_form.form_name
		 AND F.APPLICATION_ID = A.APPLICATION_ID
	         AND A.APPLICATION_SHORT_NAME = audit_form.form_application);
        exception
        when no_data_found then
            null;
        end;
    else
        --
        -- BEGIN_FORM call
        -- If form level auditing insert new form record.
	--
        if (audit_level = 'D') then
            INSERT INTO FND_LOGIN_RESP_FORMS
            (LOGIN_ID, LOGIN_RESP_ID, FORM_APPL_ID, FORM_ID, START_TIME,
             AUDSID)
                SELECT audit_form.login_id, audit_form.login_resp_id,
                       A.APPLICATION_ID, F.FORM_ID, SYSDATE,
                       userenv('SESSIONID')
                FROM FND_FORM F, FND_APPLICATION A
                WHERE F.FORM_NAME = audit_form.form_name
                AND F.APPLICATION_ID = A.APPLICATION_ID
                AND A.APPLICATION_SHORT_NAME = audit_form.form_application;
        end if;
    end if;
    COMMIT;
exception
when others then
    rollback;
    generic_error('FND_SIGNON.AUDIT_FORM', SQLCODE, SQLERRM);
end AUDIT_FORM;

--
-- AUDIT_RESPONSIBILITY - Signon audit responsibility
--
-- Insert new soa record for responsibility,
-- update pid in soa logins table.
--
procedure AUDIT_RESPONSIBILITY(audit_level	in varchar2,
                               login_id		in number,
                               login_resp_id	in out nocopy number,
                               resp_appl_id	in number,
                               resp_id			in number,
                               terminal_id	in varchar2,
                               spid				in varchar2) is
pragma AUTONOMOUS_TRANSACTION;
    l_pid number;
    l_serial number;
    l_spid varchar2(30);
begin
    -- Endstamp any previous resp record in this login.
    -- This must be done regardless of level in case level was changed
    -- during login.
    AUDIT_RESPONSIBILITY_END(login_id);

    --
    -- Change pid in logins table to reflect pid of current process.
    -- This must be done when resp changes because a reconnect may
    -- have caused pid to change.
    --
    SELECT P.PID, P.SERIAL#, P.SPID
               INTO l_pid, l_serial, l_spid
	       FROM V$PROCESS P, V$SESSION S
	       WHERE S.AUDSID = USERENV('SESSIONID')
               AND S.PADDR = P.ADDR;

    UPDATE FND_LOGINS FL
    SET PID = l_pid,
        SERIAL# = l_serial,
        PROCESS_SPID = l_spid
    WHERE FL.LOGIN_ID = audit_responsibility.login_id;

    -- If resp/form level auditing insert record for new resp
    if (audit_level in ('C', 'D')) then
        --
        -- Bug 3457883: The unique index FND_LOGIN_RESPONSIBILITIES_U1 is being violated when a
        -- responsibility is relaunched within an existing ICX session.  This was brought about
        -- by the changes in bug 3043856 wherein the login_id obtained by ICX is not used throughout
        -- the session.  A new sequence, FND_LOGIN_RESPONSIBILITIES_S, is created to generate unique
        -- values for login_resp_id and will be used when inserting records into
        -- FND_LOGIN_RESPONSIBILITIES.  The login_resp_id generated will be passed back to the API
        -- calling fnd_signon.audit_responsibility().
        --
		  -- If login_resp_id is null, then generate one.
		  if (login_resp_id is null) then
		      select FND_LOGIN_RESPONSIBILITIES_S.nextval into login_resp_id from dual;
		  end if;

        INSERT INTO FND_LOGIN_RESPONSIBILITIES
        (LOGIN_ID, LOGIN_RESP_ID, RESP_APPL_ID, RESPONSIBILITY_ID, START_TIME,
         AUDSID)
        VALUES (audit_responsibility.login_id,
                audit_responsibility.login_resp_id,
                audit_responsibility.resp_appl_id,
                audit_responsibility.resp_id, SYSDATE,
                userenv('SESSIONID'));

	-- If auditing at form level add a new record for the signon
	-- form under the new responsibility.
	if (audit_level = 'D') then
            AUDIT_FORM(login_id, login_resp_id, 'FND', 'FNDSCSGN',
		       audit_level, 1);
	end if;
    end if;
    COMMIT;
exception
when others then
    rollback;
    generic_error('FND_SIGNON.AUDIT_RESPONSIBILITY', SQLCODE, SQLERRM);
end AUDIT_RESPONSIBILITY;

--
-- AUDIT_USER - Begin user level signon auditing
--
-- Insert new soa record for login,
-- create new login_id for this signon.
--
procedure AUDIT_USER(login_id in out nocopy number,
                     audit_level in varchar2,
                     user_id in number,
                     terminal_id in varchar2,
                     login_name in varchar2,
                     spid in varchar2,
                     session_number in number,
		     p_loginfrom IN VARCHAR2 DEFAULT NULL) is
pragma AUTONOMOUS_TRANSACTION;
    local_pid  number;
    local_spid varchar2(30);
    local_serial# number;
    local_process_spid VARCHAR2(30);
    l_loginfrom varchar2(8) := nvl(p_loginfrom,'FORM');
begin
    -- Endstamp any previous login or resp record.
    -- This must be done regardless of level in case level was changed
    -- during login.
    AUDIT_USER_END(login_id);
    AUDIT_RESPONSIBILITY_END(login_id);

    -- Create a new login id
    SELECT FND_LOGINS_S.NEXTVAL INTO audit_user.login_id FROM SYS.DUAL;

    -- If auditing turned on insert record in FL for new login
    -- bug 7160418, skip auditing for guest user
    if (audit_level <> 'A') AND (user_id <> '6') then
	-- Get current oracle and system process ids
	begin
	    SELECT P.PID, S.PROCESS, P.SERIAL#, P.SPID
	    INTO local_pid, local_spid, local_serial#, local_process_spid
	    FROM V$PROCESS P, V$SESSION S
	    WHERE S.AUDSID = USERENV('SESSIONID')
	    AND S.PADDR = P.ADDR;
	exception
	when no_data_found then
	    local_pid := null;
	    local_spid := null;
	end;

	-- Insert record
        INSERT INTO FND_LOGINS
        (LOGIN_ID, USER_ID, START_TIME, TERMINAL_ID,
            LOGIN_NAME, PID, SPID, SESSION_NUMBER, SERIAL#,
            PROCESS_SPID, LOGIN_TYPE)
        VALUES(audit_user.login_id, audit_user.user_id, SYSDATE,
               audit_user.terminal_id, audit_user.login_name,
               local_pid, local_spid, audit_user.session_number,
               local_serial#, local_process_spid, l_loginfrom);
    end if;
    COMMIT;
exception
when others then
    rollback;
    generic_error('FND_SIGNON.AUDIT_USER', SQLCODE, SQLERRM);
end AUDIT_USER;

--
-- AUDIT_END - End signon audit
--
-- End stamp last user and resp record when exiting.
--
procedure AUDIT_END(login_id in number) is
pragma AUTONOMOUS_TRANSACTION;
begin
    -- Endstamp any previous signon audit records
    AUDIT_USER_END(login_id);
    COMMIT;
exception
when others then
    rollback;
    generic_error('FND_SIGNON.AUDIT_END', SQLCODE, SQLERRM);
end AUDIT_END;

--
-- NEW_SESSION - Misc signon things
--
-- Get new session number, check password expiration, etc
--
procedure NEW_SESSION(UID in  number,
                      SID out nocopy number,
                      EXPIRED out nocopy varchar2) is
    LSID number;
begin
    --
    -- Fetch and lock session number
    --
    -- Bug 7160418 skip guest user as we do not audit guest
    if (UID <> 6) then
       select SESSION_NUMBER
       into   LSID
       from   FND_USER
       where  USER_ID = UID
       for    update of SESSION_NUMBER, LAST_LOGON_DATE;
       LSID := LSID + 1;
       SID  := LSID;
       --
       -- Update session number, set logon date
       --
       update FND_USER
       set    LAST_LOGON_DATE = SYSDATE,
           SESSION_NUMBER = LSID
       where  USER_ID = UID;

      --
      -- Test for Expired password
      --
      begin
        select 'Y'
        into   EXPIRED
        from   FND_USER
        where  USER_ID = UID
        and    ENCRYPTED_USER_PASSWORD <> 'EXTERNAL'  -- Bug #2288977 --
        and    (PASSWORD_DATE is NULL or
                (PASSWORD_LIFESPAN_ACCESSES is not NULL and
                     nvl(PASSWORD_ACCESSES_LEFT, 0) < 1) or
                (PASSWORD_LIFESPAN_DAYS is not NULL and
                 SYSDATE >= PASSWORD_DATE + PASSWORD_LIFESPAN_DAYS));
      exception
        when no_data_found then
            EXPIRED := 'N';
      end;
      --
      -- Decrement password accesses left
      --
      begin
        update FND_USER
        set    PASSWORD_ACCESSES_LEFT = PASSWORD_ACCESSES_LEFT - 1
        where  USER_ID = UID
        and    PASSWORD_ACCESSES_LEFT > 0;
      exception
        when no_data_found then
            null;
      end;
    else
       -- Bug 7160418 skip guest user as we do not audit guest
       -- We will fall into this else for GUEST user uid=6.
       SID := -1;
       EXPIRED := 'N';
    end if;

    commit;
exception
when others then
    generic_error('FND_SIGNON.NEW_SESSION', SQLCODE, SQLERRM);
end NEW_SESSION;

--
-- Bug 3375261. new_icx_session(user_id,login_id,expired)
-- is called by Java APIs
-- SessionManager.validateLogin and WebAppsContext.createSession,
-- this causes the functions in new_icx_session to be executed
-- twice in a local login flow. The fix is to split the functionality
-- of new_icx_session into two new APIs:
-- (1) is_pwd_expired: performs password expiration related operations,
--     to be used when authenticating a user/pwd pair
-- (2) new_icx_session(UID,l_login_id): performs auditing and
--     session number related operation, to be used when a session
--     is created.
/* tests whether a password has expired or not, updates
 * expiration related bookkeeping data in fnd_user table if necessary.
 * update last_logon_date in fnd_user
 */
procedure is_pwd_expired(UID in  number,
                         EXPIRED out nocopy varchar2) is
pragma AUTONOMOUS_TRANSACTION;
begin
    --
    -- Test for Expired password
    --
    begin
        select 'Y'
        into   EXPIRED
        from   FND_USER
        where  USER_ID = UID
        and    ENCRYPTED_USER_PASSWORD <> 'EXTERNAL'  -- Bug #2288977 --
        and    (PASSWORD_DATE is NULL or
                (PASSWORD_LIFESPAN_ACCESSES is not NULL and
                     nvl(PASSWORD_ACCESSES_LEFT, 0) < 1) or
                (PASSWORD_LIFESPAN_DAYS is not NULL and
                 SYSDATE >= PASSWORD_DATE + PASSWORD_LIFESPAN_DAYS));
    exception
        when no_data_found then
            EXPIRED := 'N';
    end;
    --
    -- Decrement password accesses left
    --
    begin
        update FND_USER
        set    PASSWORD_ACCESSES_LEFT = PASSWORD_ACCESSES_LEFT - 1
        where  USER_ID = UID
        and    PASSWORD_ACCESSES_LEFT > 0;
    exception
        when no_data_found then
            null;
    end;

    update FND_USER
    set    LAST_LOGON_DATE = SYSDATE
    where  USER_ID = UID;

    commit;
exception
when others then
    rollback;
    generic_error('FND_SIGNON.is_pwd_expired', SQLCODE, SQLERRM);
end is_pwd_expired;

/*
 * updates session_number in fnd_user table.
 * generate auditing record
 */
procedure new_icx_session(UID   IN NUMBER,
                          login_id  OUT nocopy NUMBER) IS
begin
   new_proxy_icx_session(UID, null, login_id);
end new_icx_session;

/*
 * updates session_number in fnd_user table.
 * generate auditing record
 * Same as new_icx_session except a single change for handling SIGNONAUDIT:LEVEL
 * differently for Proxy Sessions.
 */
procedure new_proxy_icx_session(UID   IN NUMBER,
                          proxy_user IN NUMBER,
                          login_id  OUT nocopy NUMBER) IS
LSID			NUMBER;
l_login_id              NUMBER;
l_audit_level           VARCHAR2(1);
l_session_id            NUMBER;
l_proxy_user_id         NUMBER;
begin
    --
    -- Fetch and lock session number
    --
    -- Bug 7160418 skip guest user as we do not audit guest
    if (UID <> 6) then
       select SESSION_NUMBER
       into   LSID
       from   FND_USER
       where  USER_ID = UID
       for    update of SESSION_NUMBER, LAST_LOGON_DATE;
       LSID := LSID + 1;
       --
       -- Update session number, set logon date
       --
       update FND_USER
       set    LAST_LOGON_DATE = SYSDATE,
           SESSION_NUMBER = LSID
       where  USER_ID = UID;
    else
       -- Bug 7160418 , fall into this else for GUEST user, uid=6
       LSID := -1;
    end if;

     SELECT  userenv('SESSIONID')
     INTO    l_session_id
     FROM    dual;

    /*
     * Special handling of 'SIGNONAUDIT:LEVEL' for proxy sessions
     */
    /* Proxy info is already passed to this api
     * so no need to call Fnd_Session_Management.isProxySession
     */
     l_proxy_user_id := proxy_user;

     if ((l_proxy_user_id is not NULL) AND
         (l_proxy_user_id <> -1)) then
       l_audit_level := 'D';
     else
       if (FND_GLOBAL.USER_ID = -1) or (FND_GLOBAL.USER_ID = 6) then
         l_audit_level:=
	     fnd_profile.value_specific('SIGNONAUDIT:LEVEL', UID);
       else
         l_audit_level:= fnd_profile.value('SIGNONAUDIT:LEVEL');
       end if;
     end if;


     audit_user(l_login_id, l_audit_level, UID,
                NULL, NULL, NULL, LSID);

    -- Bug 7160418 skip guest user as we do not audit guest
    if (UID <> 6) then
     INSERT INTO
        fnd_appl_sessions(login_type, login_id, audsid, start_time)
     VALUES ('AOLJ', l_login_id, l_session_id, Sysdate);
    end if;

     login_id := l_login_id;
exception
when others then
    login_id := 0;
    generic_error('FND_SIGNON.NEW_PROXY_ICX_SESSION', SQLCODE, SQLERRM);
end new_proxy_icx_session;

--
-- Update_Desktop_Object (PRIVATE)
--   Update a function value on the desktop.
--
procedure Update_Desktop_Object(
  func_name in varchar2,
  func_sequence in number,
  user_id in number,
  resp_id in number,
  appl_id in number,
  login_id in number)
is
begin
  if (func_name is null) then
    -- Delete if value nulled out
    delete from FND_USER_DESKTOP_OBJECTS
    where USER_ID = update_desktop_object.user_id
    and APPLICATION_ID = update_desktop_object.appl_id
    and RESPONSIBILITY_ID = update_desktop_object.resp_id
    and TYPE = 'FUNCTION'
    and SEQUENCE = update_desktop_object.func_sequence;
  else
    -- Try for update
    update FND_USER_DESKTOP_OBJECTS set
      FUNCTION_NAME = update_desktop_object.func_name,
      LAST_UPDATE_DATE = sysdate,
      LAST_UPDATED_BY = update_desktop_object.user_id,
      LAST_UPDATE_LOGIN = update_desktop_object.login_id
    where USER_ID = update_desktop_object.user_id
    and APPLICATION_ID = update_desktop_object.appl_id
    and RESPONSIBILITY_ID = update_desktop_object.resp_id
    and TYPE = 'FUNCTION'
    and SEQUENCE = update_desktop_object.func_sequence;

    if (sql%rowcount = 0) then
      -- Insert new row if not found
      insert into FND_USER_DESKTOP_OBJECTS (
        DESKTOP_OBJECT_ID,
        USER_ID,
        APPLICATION_ID,
        RESPONSIBILITY_ID,
        OBJECT_NAME,
        FUNCTION_NAME,
        OBJECT_LABEL,
        PARAMETER_STRING,
        SEQUENCE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        TYPE)
      select
        FND_DESKTOP_OBJECT_ID_S.NEXTVAL,
        update_desktop_object.user_id,
        update_desktop_object.appl_id,
        update_desktop_object.resp_id,
        'FUNCTION',
        update_desktop_object.func_name,
        'FUNCTION',
        '',
        update_desktop_object.func_sequence,
        sysdate,
        update_desktop_object.user_id,
        sysdate,
        update_desktop_object.user_id,
	update_desktop_object.login_id,
        'FUNCTION'
      from sys.dual;
    end if;
  end if;
exception
  when others then
    generic_error('FND_SIGNON.UPDATE_DESKTOP_OBJECT', SQLCODE, SQLERRM);
end;

--
-- UPDATE_NAVIGATOR
--
-- Update navigator info for current user/resp.
--
procedure UPDATE_NAVIGATOR(
    USER_ID in number,
    RESP_ID in number,
    APPL_ID in number,
    LOGIN_ID in number,
    FUNCTION1 in varchar2,
    FUNCTION2 in varchar2,
    FUNCTION3 in varchar2,
    FUNCTION4 in varchar2,
    FUNCTION5 in varchar2,
    FUNCTION6 in varchar2,
    FUNCTION7 in varchar2,
    FUNCTION8 in varchar2,
    FUNCTION9 in varchar2,
    FUNCTION10 in varchar2,
    WINDOW_WIDTH in number,
    WINDOW_HEIGHT in number,
    WINDOW_XPOS in number,
    WINDOW_YPOS in number,
    NEW_WINDOW_FLAG in varchar2) is

begin
  -- Save Hotlist functions to desktop objects
  Fnd_Signon.Update_Desktop_Object(function1, 1,
      user_id, resp_id, appl_id, login_id);
  Fnd_Signon.Update_Desktop_Object(function2, 2,
      user_id, resp_id, appl_id, login_id);
  Fnd_Signon.Update_Desktop_Object(function3, 3,
      user_id, resp_id, appl_id, login_id);
  Fnd_Signon.Update_Desktop_Object(function4, 4,
      user_id, resp_id, appl_id, login_id);
  Fnd_Signon.Update_Desktop_Object(function5, 5,
      user_id, resp_id, appl_id, login_id);
  Fnd_Signon.Update_Desktop_Object(function6, 6,
      user_id, resp_id, appl_id, login_id);
  Fnd_Signon.Update_Desktop_Object(function7, 7,
      user_id, resp_id, appl_id, login_id);
  Fnd_Signon.Update_Desktop_Object(function8, 8,
      user_id, resp_id, appl_id, login_id);
  Fnd_Signon.Update_Desktop_Object(function9, 9,
      user_id, resp_id, appl_id, login_id);
  Fnd_Signon.Update_Desktop_Object(function10, 10,
      user_id, resp_id, appl_id, login_id);

  -- Save window position to preferences
  Fnd_Preference.Put(Fnd_Global.User_Name, 'FNDSCSGN',
                     'WINDOW_WIDTH',
                     fnd_number.number_to_canonical(window_width));
  Fnd_Preference.Put(Fnd_Global.User_Name, 'FNDSCSGN',
	             'WINDOW_HEIGHT',
                     fnd_number.number_to_canonical(window_height));
  Fnd_Preference.Put(Fnd_Global.User_Name, 'FNDSCSGN',
		     'WINDOW_XPOS',
		     fnd_number.number_to_canonical(window_xpos));
  Fnd_Preference.Put(Fnd_Global.User_Name, 'FNDSCSGN',
		     'WINDOW_YPOS',
		     fnd_number.number_to_canonical(window_ypos));
  Fnd_Preference.Put(Fnd_Global.User_Name, 'FNDSCSGN',
		     'NEW_WINDOW_FLAG', new_window_flag);
  commit;
exception
when others then
    generic_error('FND_SIGNON.UPDATE_NAVIGATOR', SQLCODE, SQLERRM);
end UPDATE_NAVIGATOR;

--
-- GET_NAVIGATOR_PREFERENCES
--   Get Navigator window sizing preferences.
--
procedure GET_NAVIGATOR_PREFERENCES(
    WINDOW_WIDTH out nocopy number,
    WINDOW_HEIGHT out nocopy number,
    WINDOW_XPOS out nocopy number,
    WINDOW_YPOS out nocopy number,
    NEW_WINDOW_FLAG out nocopy varchar2)
is
begin
  window_width := fnd_number.canonical_to_number(
		      Fnd_Preference.Get(Fnd_Global.User_Name,
                      'FNDSCSGN', 'WINDOW_WIDTH'));
  window_height := fnd_number.canonical_to_number(
                      Fnd_Preference.Get(Fnd_Global.User_Name,
                      'FNDSCSGN', 'WINDOW_HEIGHT'));
  window_xpos := fnd_number.canonical_to_number(
		      Fnd_Preference.Get(Fnd_Global.User_Name,
                      'FNDSCSGN', 'WINDOW_XPOS'));
  window_ypos := fnd_number.canonical_to_number(
                      Fnd_Preference.Get(Fnd_Global.User_Name,
                      'FNDSCSGN', 'WINDOW_YPOS'));
  new_window_flag := substrb(Fnd_Preference.Get(
                       Fnd_Global.User_Name,
                       'FNDSCSGN', 'NEW_WINDOW_FLAG'), 1, 1);
exception
  when others then
    generic_error('FND_SIGNON.GET_NAVIGATOR_PREFERENCES', SQLCODE, SQLERRM);
end GET_NAVIGATOR_PREFERENCES;

--
-- SET_SESSION
--   Store session date whenever new session is created.
-- To be called in pre-form of any form opened in a new session.
-- This is to maintain session dates for AOL forms running under
-- HR responsibilities.
--
procedure SET_SESSION(session_date in varchar2) is
    l_ses_date date;
    hmask varchar2(11) := 'DD-MON-YYYY';
begin
    l_ses_date := nvl(to_date(session_date, hmask),
		      trunc(sysdate));
    insert into FND_SESSIONS (
      SESSION_ID,
      EFFECTIVE_DATE)
    select
      userenv('SESSIONID'),
      l_ses_date
    from sys.dual
    where not exists
      (select null
      from FND_SESSIONS
      where SESSION_ID = userenv('SESSIONID'));

    commit;
exception
when others then
    generic_error('FND_SIGNON.SET_SESSION', SQLCODE, SQLERRM);
end SET_SESSION;

-- Misc signon things for an aol/j session.
-- For internal use only.


-- PRIVATE_NEW_SESSION - wrapper call to new_session() to isolate autonomous
-- transaction to just the new_session.  This is required for bug 1950030 and
-- comes from the original requirement for bug 1870328, where the call to
-- new_session() - which does a commit - caused the calling Java save points
-- to be lost and all transactions before this call to get committed.
--
-- 1870328 tried adding the AUTONOMOUS_TRANSACTION pragma to new_aolj_session()
-- and assumed that the commit in new_session() was sufficient for the pragma,
-- but the additional insert clause required a commit as well...  Rather than
-- dealing with the INSERT and EXCEPTION handling under the pragma and to keep
-- the commit structure as close to original coding i decided to just isolate
-- new_session().
--
-- For internal use only.

procedure PRIVATE_NEW_SESSION(pUID in  number,
                      pSID in out nocopy number,
                      pEXPIRED in out nocopy varchar2) is
pragma AUTONOMOUS_TRANSACTION;
begin
   new_session(pUID,pSID,pEXPIRED);
end PRIVATE_NEW_SESSION;


/*
 * NEW_AOLJ_SESSION
 *   Wrapper to new_icx_session as it was deemed redundant, i.e. it performed
 *   the same functionality as new_icx_session without the auditing.  All sessions
 *   created should be audited.
 *
 * IN
 *   user_id - User's ID
 * OUT
 *   p_loginID - Login ID of audit record (if successful)
 *   p_expired - Expiration flag to check whether user's password has expired.
 * RAISES
 *   Never raises exceptions, places a message on the
 *   message stack if an error is encountered.
 */
PROCEDURE new_aolj_session(user_id   IN NUMBER,
						   login_id OUT nocopy NUMBER,
                           expired  OUT nocopy VARCHAR2)
  IS
BEGIN

	new_icx_session(user_id, login_id, expired);

EXCEPTION
	WHEN OTHERS THEN
		login_id := 0;
		expired := 'N';
		generic_error('FND_SIGNON.NEW_AOLJ_SESSION', SQLCODE, SQLERRM);
end NEW_AOLJ_SESSION;


--AUDIT_WEB_RESPONSIBILITY created to audit visits to Responsibilities within ICX.
--Not as detailed as other resp audits.. but that is due to lack of reliable details within ICX.
procedure AUDIT_WEB_RESPONSIBILITY(login_id in number,
                                   login_resp_id in number,
                                   resp_appl_id in number,
                                   resp_id in number)
   IS
pragma AUTONOMOUS_TRANSACTION;
    audit_level VARCHAR2(1);
    rows_exist NUMBER := 0;
    l_audit_level VARCHAR2(1);
    l_proxy_user_id NUMBER;
    l_session_id NUMBER;

BEGIN

     select userenv('SESSIONID') into l_session_id from dual;
     l_proxy_user_id := fnd_session_management.isProxySession(null);


     if (l_proxy_user_id is not NULL) then
       l_audit_level := 'D';
     else
       l_audit_level:=fnd_profile.value('SIGNONAUDIT:LEVEL');
     end if;

    -- If resp/form level auditing insert record for new resp
    if (l_audit_level in ('C', 'D')) then

       --see if there is already a row
       SELECT count(*) INTO rows_exist
          FROM fnd_login_responsibilities
          WHERE login_id=audit_web_responsibility.login_id
          AND login_resp_id=audit_web_responsibility.login_resp_id;


       IF rows_exist=0 THEN

        INSERT INTO FND_LOGIN_RESPONSIBILITIES
        (LOGIN_ID, LOGIN_RESP_ID, RESP_APPL_ID, RESPONSIBILITY_ID, START_TIME,
         AUDSID)
        VALUES (audit_web_responsibility.login_id,
                audit_web_responsibility.login_resp_id,
                audit_web_responsibility.resp_appl_id,
                audit_web_responsibility.resp_id, SYSDATE,
                userenv('SESSIONID'));

        END IF; -- rows_exist

    end if; -- audit_level in ..
    COMMIT;
exception
when others then
    rollback;

    generic_error('FND_SIGNON.AUDIT_WEB_RESPONSIBILITY', SQLCODE, SQLERRM);
end AUDIT_WEB_RESPONSIBILITY;

/*
 * NEW_ICX_SESSION
 *   Creates a session and updates auditing tables for each session created.
 *
 * IN
 *   user_id - User's ID
 * OUT
 *   p_loginID - Login ID of audit record (if successful)
 *   p_expired - Expiration flag to check whether user's password has expired.
 * RAISES
 *   Never raises exceptions, places a message on the
 *   message stack if an error is encountered.
 */

PROCEDURE new_icx_session(user_id   IN NUMBER,
						  login_id OUT nocopy NUMBER,
						  expired  OUT nocopy VARCHAR2,
			  p_loginfrom IN VARCHAR2 DEFAULT NULL)
	IS
		l_session_number	NUMBER;
		l_login_id			NUMBER;
		l_expired			VARCHAR2(1);
		l_audit_level		VARCHAR2(1);
		l_session_id		NUMBER;
                l_proxy_user_id         NUMBER;
		l_loginfrom varchar2(8) := nvl(p_loginfrom,'AOLJ');
BEGIN

		PRIVATE_NEW_SESSION(user_id, l_session_number, l_expired);
		--
		-- Bug 3238722: The login_id generated by FND_LOGINS_S is not being recorded in
		-- FND_LOGINS when a user-level value for the profile option 'Sign-On Audit:Level' is set
		-- but a site-level value is not.  This happens when the audit level value returned by
		-- fnd_profile.value returns the site-level when the context is not set.  The code needs to
		-- check if the context is set by an FND_GLOBAL.USER_ID call.  If the return value is -1,
		-- then the context is not set.  If the context is not set, the code should call
		-- fnd_profile.value_specific and pass in the user_id to return an accurate value for
		-- the audit level.  Once an accurate value for the profile is returned, the login_id will
		-- be properly recorded in FND_LOGINS.
		--

		SELECT	userenv('SESSIONID')
		INTO	l_session_id
		FROM	dual;

    begin
      select session_id into l_session_id
      from ICX_SESSIONS
      where session_id= l_session_id;

		  l_proxy_user_id :=
			  fnd_session_management.isProxySession(l_session_id);
    exception
      when no_data_found then
       l_proxy_user_id := NULL;
    end;

		-- Proxy sessions are always audited at FORM level irrespective
		-- of SIGNONAUDIT:LEVEL profile option
		if (l_proxy_user_id is not NULL) then
		   l_audit_level := 'D';
		else
		   if (FND_GLOBAL.USER_ID = -1) OR (FND_GLOBAL.USER_ID = 6)  then
                     l_audit_level:= fnd_profile.value_specific('SIGNONAUDIT:LEVEL', user_id);
                   else
                      l_audit_level:= fnd_profile.value('SIGNONAUDIT:LEVEL');
		   end if;
		end if;


		audit_user(l_login_id, l_audit_level, user_id, NULL, NULL, NULL, l_session_number,p_loginfrom);

              -- Bug 7160418 skip guest user as we do not audit guest
              if (UID <> 6) then
		INSERT INTO fnd_appl_sessions(login_type, login_id, audsid, start_time)
		VALUES (l_loginfrom, l_login_id, l_session_id, Sysdate);
              end if;

		login_id := l_login_id;
		expired := l_expired;

EXCEPTION
		WHEN OTHERS THEN
			login_id := 0;
			expired := 'N';
			-- Changed FND_SIGNON.NEW_AOLJ_SESSION to FND_SIGNON.NEW_ICX_SESSION
			-- for consistency.
			generic_error('FND_SIGNON.NEW_ICX_SESSION', SQLCODE, SQLERRM);
end NEW_ICX_SESSION;

/* BUG:5052314: API to retrieve number of unsuccessful logins */
/* previous to current login */
FUNCTION get_invalid_logins(p_userID number) return NUMBER
 IS

   number_of_unsuccessful_logins NUMBER:= 0;
   l_user_id NUMBER;


BEGIN

   -- check user id exist.
   select  user_id
   into    l_user_id
   from    FND_USER
   where   user_id = p_userID;

 -- Bug 7169414 - rewrite - changed query to be the same used in the Forms login

   select  count(ul.USER_ID)
   into    number_of_unsuccessful_logins
   from    fnd_unsuccessful_logins ul,  fnd_user u
   where   u.user_id = l_user_id
   and     ul.user_id = u.user_id
   and     ul.attempt_time > nvl(u.last_logon_date, u.last_update_date);

   return number_of_unsuccessful_logins;

EXCEPTION when NO_DATA_FOUND then

-- raise no data found error.
fnd_message.set_name('FND','SQL_PLSQL_ERROR');
fnd_message.set_token('ROUTINE','FND_AOLJ_UTIL.get_invalid_logins()');
fnd_message.set_token('ERRNO',1403 );
fnd_message.set_token('REASON','Invalid User ID provided');
app_exception.raise_exception;

when OTHERS then

--raise generic error.
fnd_message.set_name('FND','SQL_PLSQL_ERROR');
fnd_message.set_token('ROUTINE','FND_AOLJ_UTIL.get_invalid_logins()');
fnd_message.set_token('ERRNO',SUBSTR(sqlerrm,5,5));
fnd_message.set_token('REASON', sqlerrm);
app_exception.raise_exception;


END get_invalid_logins;

end FND_SIGNON;

/
