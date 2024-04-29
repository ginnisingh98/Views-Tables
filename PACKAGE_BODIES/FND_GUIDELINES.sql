--------------------------------------------------------
--  DDL for Package Body FND_GUIDELINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_GUIDELINES" AS
 /* $Header: AFSCGDLB.pls 120.0.12010000.12 2021/04/07 04:30:33 dgooty noship $ */
  NEWLINE CONSTANT VARCHAR2(2) := fnd_global.local_chr(13)  || fnd_global.local_chr(10);
  status_not_found       CONSTANT VARCHAR2(2) := 'NF';
  status_not_compiled    CONSTANT VARCHAR2(2) := 'NC';
  status_passed          CONSTANT VARCHAR2(2) := 'P';
  status_failed          CONSTANT VARCHAR2(2) := 'F';
  status_suppressed      CONSTANT VARCHAR2(2) := 'SP';
  status_error           CONSTANT VARCHAR2(2) := 'ER';
  status_not_fixable CONSTANT VARCHAR2(2) := 'NX';

  detailed_response BOOLEAN := false;


PROCEDURE set_detailed_response(p_status IN VARCHAR2) is
BEGIN
  if p_status = 'Y' then
    DETAILED_RESPONSE := TRUE;
  ELSE
    DETAILED_RESPONSE := FALSE;
  end if;
end set_detailed_response;

PROCEDURE add_detailed_response(p_message IN CLOB,
                                p_response IN OUT NOCOPY CLOB) is
begin
  if detailed_response = true then
    p_response := p_response || newline;
    p_response := p_response || p_message;
  END IF;
end add_detailed_response;

FUNCTION bool_to_char(p_bool in boolean)
RETURN varchar2
IS
  l_chr  varchar2(6) := null;
BEGIN
    l_chr := (CASE p_bool when true then 'TRUE' ELSE 'FALSE' END);
    RETURN(L_CHR);
END bool_to_char;

FUNCTION is_profile_active(p_profile_name IN VARCHAR2)
RETURN boolean
IS
l_profile_name varchar2(80);
BEGIN
	SELECT profile_option_name
	INTO l_profile_name
	FROM fnd_profile_options
	WHERE profile_option_name = p_profile_name
	AND ( end_date_active is null
		OR end_date_active > SYSDATE);

	IF l_profile_name = p_profile_name THEN
		return true;
	ELSE
		return false;
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		return false;
END is_profile_active;

-- checks the GL Status table
FUNCTION check_status_table( p_code IN VARCHAR2)
  RETURN VARCHAR2
IS
  l_status VARCHAR2(2) := 'F';
  l_count     NUMBER;
BEGIN
  SELECT status
  INTO   l_status
  FROM   fnd_sec_guidelines_status
  WHERE  code = p_code;

  RETURN l_status;
EXCEPTION
WHEN no_data_found THEN
  SELECT count(*)
  INTO   l_count
  FROM   fnd_sec_guidelines
  WHERE  code=p_code;

  IF l_count>0 THEN
    RETURN status_not_compiled;
  ELSE
    RETURN status_not_found;
  END IF;
WHEN OTHERS THEN
  RETURN status_error;
END check_status_table;

-- Updates the GL status table with status and details message if passed
PROCEDURE update_status_table( p_code   IN VARCHAR2,
                                 p_status  IN VARCHAR2,
                                 p_details IN VARCHAR2)
IS
BEGIN
  UPDATE fnd_sec_guidelines_status
  SET    status = p_status,
         DETAILS = P_DETAILS,
         last_updated_by = 0,
         last_update_date = SYSDATE
  WHERE  code = p_code;

  IF SQL%rowcount = 0 THEN
    INSERT INTO fnd_sec_guidelines_status
                (
                            code,
                            STATUS,
                            DETAILS,
                            last_updated_by,
                            last_update_date
                )
                VALUES
                (
                            p_code,
                            p_status,
                            P_DETAILS,
                            0,
                            SYSDATE
                );

  END IF;
  commit;
END update_status_table;

-- Deletes the specified profile at all levels except the one passed
PROCEDURE delete_profile_except_level( p_profile_name     IN VARCHAR2,
                                      p_except_level_name IN VARCHAR2)
IS
  CURSOR prof_cursor(p_profile_name VARCHAR2)
  IS
    SELECT   p.profile_option_name PROFILE_NAME,
             decode(v.level_id,
                    10001, 'SITE',
                    10002, 'APPL',
                    10003, 'RESP',
                    10004, 'USER',
                    10005, 'SERVER',
                    10007, 'SERVRESP',
                    'UnDef')              PROFILE_LEVEL,
             v.level_value                LEVEL_VALUE,
             v.level_value2               LEVEL_VALUE2,
             v.level_value_application_id LEVEL_VALUE_APPL_ID,
             v.profile_option_value       PROFILE_VALUE
    FROM     fnd_profile_options p,
             fnd_profile_option_values v,
             fnd_profile_options_tl n,
             fnd_user usr,
             fnd_application app,
             fnd_responsibility rsp,
             fnd_nodes svr,
             hr_operating_units org
    WHERE    p.profile_option_id = v.profile_option_id (+)
    AND      p.profile_option_name = n.profile_option_name
    AND      n.LANGUAGE = 'US'
    AND      p.profile_option_name = p_profile_name
    AND      usr.user_id (+) = v.level_value
    AND      rsp.application_id (+) = v.level_value_application_id
    AND      rsp.responsibility_id (+) = v.level_value
    AND      app.application_id (+) = v.level_value
    AND      svr.node_id (+) = v.level_value
    AND      org.organization_id (+) = v.level_value
    ORDER BY p.profile_option_name,
             profile_level;

prof_cursor_out prof_cursor%ROWTYPE;
l_delete_status BOOLEAN;
BEGIN
  OPEN prof_cursor(p_profile_name);
  LOOP
    FETCH prof_cursor
    INTO  prof_cursor_out;

    EXIT WHEN prof_cursor%NOTFOUND;
    IF prof_cursor_out.profile_level <> p_except_level_name THEN
      l_delete_status := fnd_profile.DELETE(p_profile_name, prof_cursor_out.profile_level, prof_cursor_out.level_value, prof_cursor_out.level_value_appl_id, prof_cursor_out.level_value2);
      --TODO: If save status is false, possible error -> do something about it.
      --TODO: Should be logging all the changes made by the fix script.
    END IF;
  END LOOP;
  CLOSE prof_cursor;
END delete_profile_except_level;


-- Set the specified profile at all levels except the one passed
PROCEDURE set_profile_except_level( p_profile_name     IN VARCHAR2,
                                    p_profile_value IN VARCHAR2,
                                      p_except_level_name IN VARCHAR2)
IS
  CURSOR prof_cursor(p_profile_name VARCHAR2)
  IS
    SELECT   p.profile_option_name PROFILE_NAME,
             decode(v.level_id,
                    10001, 'SITE',
                    10002, 'APPL',
                    10003, 'RESP',
                    10004, 'USER',
                    10005, 'SERVER',
                    10007, 'SERVRESP',
                    'UnDef')              PROFILE_LEVEL,
             v.level_value                LEVEL_VALUE,
             v.level_value2               LEVEL_VALUE2,
             v.level_value_application_id LEVEL_VALUE_APPL_ID,
             v.profile_option_value       PROFILE_VALUE
    FROM     fnd_profile_options p,
             fnd_profile_option_values v,
             fnd_profile_options_tl n,
             fnd_user usr,
             fnd_application app,
             fnd_responsibility rsp,
             fnd_nodes svr,
             hr_operating_units org
    WHERE    p.profile_option_id = v.profile_option_id (+)
    AND      p.profile_option_name = n.profile_option_name
    AND      n.LANGUAGE = 'US'
    AND      p.profile_option_name = p_profile_name
    AND      usr.user_id (+) = v.level_value
    AND      rsp.application_id (+) = v.level_value_application_id
    AND      rsp.responsibility_id (+) = v.level_value
    AND      app.application_id (+) = v.level_value
    AND      svr.node_id (+) = v.level_value
    AND      org.organization_id (+) = v.level_value
    ORDER BY p.profile_option_name,
             profile_level;

prof_cursor_out prof_cursor%ROWTYPE;
l_save_status BOOLEAN;
BEGIN
  OPEN prof_cursor(p_profile_name);
  LOOP
    FETCH prof_cursor
    INTO  prof_cursor_out;

    EXIT WHEN prof_cursor%NOTFOUND;
    IF prof_cursor_out.profile_level <> p_except_level_name THEN
      l_save_status := fnd_profile.SAVE(p_profile_name, p_profile_value, prof_cursor_out.profile_level, prof_cursor_out.level_value, prof_cursor_out.level_value_appl_id, prof_cursor_out.level_value2);
      --TODO: If save status is false, possible error -> do something about it.
      --TODO: Should be logging all the changes made by the fix script.
    END IF;
  END LOOP;
  CLOSE prof_cursor;
END set_profile_except_level;

-- sets profile to given value at all levels found to be set
PROCEDURE set_profile_all_levels(p_profile_name IN VARCHAR2,
								 p_profile_value IN VARCHAR2,
								 p_details IN OUT NOCOPY CLOB)
IS
  CURSOR prof_cursor(p_profile_name VARCHAR2)
  IS
    SELECT   p.profile_option_name PROFILE_NAME,
             decode(v.level_id,
                    10001, 'SITE',
                    10002, 'APPL',
                    10003, 'RESP',
                    10004, 'USER',
                    10005, 'SERVER',
                    10007, 'SERVRESP',
                    'UnDef')              PROFILE_LEVEL,
             decode(to_char(v.level_id),
               '10001', 'N/A',
               '10002', (SELECT application_name
                         FROM fnd_application_vl
                         WHERE application_id = v.level_value),
               '10003', (SELECT responsibility_name
                         FROM fnd_responsibility_vl
                         WHERE responsibility_id = v.level_value
                         AND application_id = v.level_value_application_id),
               '10005', (SELECT node_name
                         FROM fnd_nodes
                         WHERE node_id = v.level_value),
               '10006', (SELECT name
                         FROM hr_operating_units
                         WHERE organization_id = v.level_value),
               '10004', (SELECT user_name
                         FROM fnd_user
                         WHERE user_id = v.level_value),
               '10007', decode(v.level_value,
                               -1, (SELECT node_name
                                    FROM fnd_nodes
                                    WHERE node_id = v.level_value2),
                               decode(v.level_value2,
                                       -1, (SELECT responsibility_name
                                            FROM fnd_responsibility_vl
                                            WHERE responsibility_id =
                                               v.level_value
                                            AND application_id =
                                               v.level_value_application_id),
                                       (SELECT node_name
                                        FROM fnd_nodes
                                        WHERE node_id = v.level_value2) ||'+'||
                                       (SELECT responsibility_name
                                        FROM fnd_responsibility_vl
                                        WHERE responsibility_id =
                                             v.level_value
                                        AND application_id =
                                             v.level_value_application_id))
                        )) LEVEL_VALUE_DISP,
			 v.level_value                LEVEL_VALUE,
             v.level_value2               LEVEL_VALUE2,
             v.level_value_application_id LEVEL_VALUE_APPL_ID,
             v.profile_option_value       PROFILE_VALUE
    FROM     fnd_profile_options p,
             fnd_profile_option_values v,
             fnd_profile_options_tl n,
             fnd_user usr,
             fnd_application app,
             fnd_responsibility rsp,
             fnd_nodes svr,
             hr_operating_units org
    WHERE    p.profile_option_id = v.profile_option_id (+)
    AND      p.profile_option_name = n.profile_option_name
    AND      n.LANGUAGE = 'US'
    AND      p.profile_option_name = p_profile_name
    AND      usr.user_id (+) = v.level_value
    AND      rsp.application_id (+) = v.level_value_application_id
    AND      rsp.responsibility_id (+) = v.level_value
    AND      app.application_id (+) = v.level_value
    AND      svr.node_id (+) = v.level_value
    AND      org.organization_id (+) = v.level_value
    ORDER BY p.profile_option_name,
             profile_level;

prof_cursor_out prof_cursor%ROWTYPE;
l_save_status BOOLEAN;
BEGIN
  OPEN prof_cursor(p_profile_name);
  LOOP
    FETCH prof_cursor
    INTO  prof_cursor_out;

    EXIT WHEN prof_cursor%NOTFOUND;
    l_save_status := fnd_profile.SAVE(p_profile_name, p_profile_value, prof_cursor_out.profile_level, prof_cursor_out.level_value, prof_cursor_out.level_value_appl_id, prof_cursor_out.level_value2);
      P_DETAILS := P_DETAILS || NEWLINE ;
	  P_DETAILS := P_DETAILS || 'Set profile ' ||PROF_CURSOR_OUT.PROFILE_NAME ||' at ';
	  P_DETAILS := P_DETAILS || PROF_CURSOR_OUT.PROFILE_LEVEL ||' level, for ' || PROF_CURSOR_OUT.LEVEL_VALUE_DISP || ' to  ';
	  P_DETAILS := P_DETAILS || p_profile_value ||'. [Save status:';
	  P_DETAILS := P_DETAILS ||bool_to_char(L_SAVE_STATUS) || ']';
  END LOOP;
  CLOSE prof_cursor;
END set_profile_all_levels;

-- executes all 'PLSQL' type checks
PROCEDURE check_all
IS
CURSOR cur_all_gls IS
SELECT code
FROM fnd_sec_guidelines;
l_status_code VARCHAR2(2);
BEGIN
  FOR l_gl IN cur_all_gls
  LOOP
    check_guideline(l_gl.code, l_status_code);
    --TODO: Error handling
    commit;
  END LOOP;
END check_all;

-- overloaded flavor of check_guideline if you don't care about the response
PROCEDURE check_guideline( p_code IN VARCHAR2,
                   p_status_code OUT NOCOPY VARCHAR2)
IS
  l_message_ignore VARCHAR2(2000);
  l_details_ignore CLOB;
BEGIN
  check_guideline(p_code, p_status_code, l_message_ignore, l_details_ignore);
END check_guideline;

-- Entry point for check calls
PROCEDURE check_guideline( p_code IN VARCHAR2,
                   p_status_code OUT NOCOPY VARCHAR2,
                   p_message OUT NOCOPY VARCHAR2,
                   p_details OUT NOCOPY CLOB)
IS
  l_status_table VARCHAR2(2);
  l_status       VARCHAR2(2);
  l_check_script varchar2(200);
  l_check_script_command varchar2(300);
  l_details CLOB;
  l_message  VARCHAR2(4000) := '';
  l_module VARCHAR2(200) := 'fnd.plsql.FND_GUIDELINES.check_guideline';
  buffer_too_small exception;
  PRAGMA EXCEPTION_INIT(buffer_too_small, -06502);
BEGIN
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Begin');
  end if;

  l_status_table := check_status_table(p_code);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'checked status table.  status is: '||l_status_table);
  end if;

/* Bug 	25269912:  Regardless of status...the check should be run
  IF l_status_table = STATUS_NOT_FOUND THEN
    p_status_code := status_not_found;
    p_message := fnd_message.get_string('FND', 'SEC_CONFIG_NO_GL_ERR');
    RETURN;
  END IF;
*/

  select CHECK_SCRIPT into l_check_script from FND_SEC_GUIDELINES where CODE = p_code;

  l_check_script_command := 'BEGIN '||l_check_script||'(:status, :message, :details); END;';

  EXECUTE IMMEDIATE l_check_script_command USING OUT l_status, OUT l_message, OUT l_details;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Check script complete - status is: '||l_status);
  end if;

  p_status_code := l_status;
  IF l_status = STATUS_PASSED THEN
    l_message := fnd_message.get_string('FND', 'SEC_CONFIG_PASS') ||' '|| L_MESSAGE;
  ELSIF l_status = STATUS_FAILED THEN
    l_message := fnd_message.get_string('FND', 'SEC_CONFIG_FAIL') ||' '|| L_MESSAGE;
  END IF;

  p_message := l_message;
  p_details := l_details;

  -- update status and message in table
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'updated status table is: '||p_status_code);
  end if;

  update_status_table(p_code, p_status_code, p_message);

  EXCEPTION
		WHEN buffer_too_small THEN
			l_message := 'ERROR - Buffer too small for logging the response';
			update_status_table(p_code, p_status_code, l_message);
		WHEN others THEN
			l_message := SQLERRM;
			update_status_table(p_code, STATUS_ERROR, l_message);

END check_guideline;


-- Entry point for fix calls
PROCEDURE fix_guideline( p_code IN VARCHAR2,
                 p_status_code OUT NOCOPY VARCHAR2,
                 p_message OUT NOCOPY VARCHAR2,
                 p_details OUT NOCOPY CLOB)
IS
  l_status_table VARCHAR2(2);
  l_status       VARCHAR2(2);
  l_fixable      VARCHAR2(2);
  l_message      VARCHAR2(4000) := '';
  l_details      CLOB := '';
  l_fix_script VARCHAR2(200);
  l_fix_script_command VARCHAR2(300);
  buffer_too_small exception;
  PRAGMA EXCEPTION_INIT(buffer_too_small, -06502);
  l_module varchar2(80);
BEGIN
  l_module := 'fnd.plsql.FND_GUIDELINES.fix_guideline';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Begin ');
  end if;

  l_status_table := check_status_table(p_code);

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'status table has: '||l_status_table);
  end if;

  IF l_status_table = STATUS_NOT_FOUND THEN
    p_status_code := STATUS_NOT_FOUND;
    p_message := fnd_message.get_string('FND', 'SEC_CONFIG_NO_GL_ERR');
    RETURN;
  END IF;

  IF l_status_table = STATUS_NOT_COMPILED THEN
    p_status_code := STATUS_NOT_COMPILED;
    p_message := 'Cannot fix a guideline that has not been compiled.';
    RETURN;
  END IF;

  -- Is this GL fixable?
  SELECT autofixable
  INTO   l_fixable
  FROM   fnd_sec_guidelines
  WHERE  code = p_code;

  IF l_fixable <> 'Y' THEN
    p_status_code := STATUS_NOT_FIXABLE;
    p_message := 'Specified security guideline is not auto-fixable';
    RETURN;
  END IF;


  select FIX_SCRIPT into l_fix_script from FND_SEC_GUIDELINES where CODE = p_code;

  l_fix_script_command := 'BEGIN '||l_fix_script||'(:status, :message, :details); END;';

  EXECUTE IMMEDIATE l_fix_script_command USING OUT l_status, OUT l_message, OUT l_details;


  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'fix script executed...check  status is: '||l_status);
  end if;
   p_status_code := l_status;
  IF l_status = STATUS_PASSED THEN
    l_message := fnd_message.get_string('FND', 'SEC_CONFIG_PASS') ||' '|| L_MESSAGE;
  ELSIF l_status = STATUS_FAILED THEN
    l_message := fnd_message.get_string('FND', 'SEC_CONFIG_FAIL') ||' '|| L_MESSAGE;
  END IF;

  p_message := l_message;
  p_details := l_details;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'try to update status table is: '||p_status_code||' message: '||p_message);
  end if;


  update_status_table(p_code, p_status_code, p_message);

  EXCEPTION
		WHEN buffer_too_small THEN
			l_message := 'ERROR - Buffer too small for logging the response';
			update_status_table(p_code, p_status_code, l_message);
		WHEN others THEN
			l_message := SQLERRM;
			update_status_table(p_code, STATUS_ERROR, l_message);

END fix_guideline;


-- fnd_apps_def_pswd: Check Apps users with default passwords
PROCEDURE check_FND_APPS_DEF_PSWD( P_STATUS OUT NOCOPY VARCHAR2,
                                     P_MESSAGE OUT NOCOPY VARCHAR2,
                                     P_DETAILS OUT NOCOPY CLOB)
IS
TYPE username_password_map
IS
  TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);
TYPE usernames
IS
  varray(100) OF VARCHAR2(100);
  userlist USERNAME_PASSWORD_MAP;
  l_username VARCHAR2(100);
  l_vul_users USERNAMES;
  l_vu_index PLS_INTEGER := 1;
  l_validate_login VARCHAR2(2);
  l_status         VARCHAR2(2) := status_passed;
  l_vu_flag        BOOLEAN := FALSE;
BEGIN
  l_vul_users := usernames();
  -- Populate username list
  userlist('AME_INVALID_APPROVER') := 'WELCOME';
  userlist('ANONYMOUS') := 'welcome';
  userlist('APPSMGR') := 'C';
  userlist('ASGADM') := 'ASGADM';
  userlist('ASGADM') := 'welcome';
  userlist('ASGUEST') := 'welcome';
  userlist('AUTOINSTALL') := 'DATAMERGE';
  --userlist('GUEST') := 'ORACLE'; -- Bug 24744399: Do not check GUEST password
  userlist('IBEGUEST') := 'IBEGUEST2000';
  userlist('IBE_ADMIN') := 'MANAGER';
  userlist('IBE_GUEST') := 'WELCOME';
  userlist('IEXADMIN') := 'COLLECTIONS';
  userlist('IRC_EMP_GUEST') := 'WELCOME';
  userlist('IRC_EXT_GUEST') := 'WELCOME';
  userlist('MOBADM') := 'C';
  userlist('MOBDEV') := 'C';
  userlist('MOBILEADM') := 'MOBILEADM';
  userlist('MOBILEADM') := 'welcome';
  userlist('OP_CUST_CARE_ADMIN') := 'OP_CUST_CARE_ADMIN';
  userlist('OP_SYSADMIN') := 'OP_SYSADMIN';
  userlist('PORTAL30') := 'PORTAL30';
  userlist('PORTAL30') := 'portal30_new';
  userlist('PORTAL30_SSO') := 'portal30_sso_new';
  userlist('SYSADMIN') := 'SYSADMIN';
  userlist('WIZARD') := '????UE:?H0UA}?K';
  userlist('XML_USER') := 'WELCOME';

  l_username := userlist.first;
  WHILE l_username IS NOT NULL
  LOOP
    SELECT fnd_web_sec.validate_login(l_username, userlist(l_username))
    INTO   l_validate_login
    FROM   dual;

    IF l_validate_login ='Y' THEN
      l_vu_flag := TRUE;
    END IF;
    SELECT fnd_web_sec.validate_login(l_username, lower(userlist(l_username)))
    INTO   l_validate_login
    FROM   dual;

    IF l_validate_login='Y' THEN
      l_vu_flag := TRUE;
    END IF;
    SELECT fnd_web_sec.validate_login(l_username, upper(userlist(l_username)))
    INTO   l_validate_login
    FROM   dual;

    IF l_validate_login='Y' THEN
      l_vu_flag := TRUE;
    END IF;
    IF l_vu_flag=TRUE THEN
      -- add to vulnerable user list
      l_vul_users.extend;
      l_vul_users(l_vu_index) := l_username;
      -- increase the index
      l_vu_index := l_vu_index + 1;
      -- set gl status as false
      l_status := status_failed;
    END IF;
    -- move to the next username
    l_username := userlist.NEXT(l_username);
    l_vu_flag := FALSE;
  END LOOP;
  P_STATUS := L_STATUS;
  if P_STATUS = STATUS_FAILED then
    P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_DEF_APPS_FAIL');
  else
    P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_DEF_APPS_PASS');
  end if;

  P_DETAILS := 'Apps users with default passwords :'||newline;
  FOR i IN 1..l_vu_index-1
  LOOP
    p_details := p_details|| l_vul_users(i)|| ', ';
  END LOOP;

  p_details := substr(p_details, 1, length(p_details) - 2);
END check_fnd_apps_def_pswd;


-- fnd_db_def_pswd: Check DB users with default passwords
PROCEDURE check_FND_DB_DEF_PSWD( P_STATUS OUT NOCOPY VARCHAR2,
                                   P_MESSAGE OUT NOCOPY VARCHAR2,
                                   p_details OUT NOCOPY CLOB)
IS
  l_status        VARCHAR2(100);
  l_name          VARCHAR2(100);
  l_username      VARCHAR2(100);
  L_ACCOUNTSTATUS VARCHAR2(100);
  CURSOR db_defpwd_users_cur IS
    SELECT username,
           account_status
    FROM   dba_users
    WHERE  username IN
           (
                  SELECT username
                  FROM   dba_users_with_defpwd )
AND    username <> 'XS$NULL';

BEGIN
  BEGIN

    -- Check if DBA_USERS_WITH_DEFPWD exists
    SELECT 'view exists'
    INTO   l_status
    FROM   all_views
    WHERE  view_name='DBA_USERS_WITH_DEFPWD'
	AND owner = 'SYS';

  EXCEPTION
  WHEN no_data_found THEN --view doesn't exist
    p_message := fnd_message.get_string('FND', 'SEC_CONFIG_DEF_DB_ERR');
    p_status := status_error;
  WHEN OTHERS THEN
    p_message := fnd_message.get_string('FND', 'SEC_CONFIG_UNEXP_ERR')||SQLERRM;
    p_status := status_error;
  END;

  IF p_status=status_error THEN
    RETURN;
  END IF;

  p_message := '';
  OPEN db_defpwd_users_cur;
  LOOP
    FETCH db_defpwd_users_cur
    INTO  l_username,
          l_accountstatus;
    EXIT WHEN db_defpwd_users_cur%NOTFOUND;
    P_DETAILS := P_DETAILS||L_USERNAME|| '['||L_ACCOUNTSTATUS||']';
    p_details := p_details||', ';
  END LOOP;

  IF DB_DEFPWD_USERS_CUR%ROWCOUNT > 0 THEN
    P_STATUS := STATUS_FAILED;
    p_message := fnd_message.get_string('FND', 'SEC_CONFIG_DEF_DB_FAIL');
    P_DETAILS := 'Database users with default passwords (format: username[account status]) - '||NEWLINE||P_DETAILS;
    P_DETAILS := SUBSTR(P_details, 1, LENGTH(P_details) - 1);
    P_DETAILS := P_DETAILS||NEWLINE;
  ELSE
    P_STATUS := STATUS_PASSED;
    P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_DEF_DB_PASS');
    p_details := 'No DB users with default passwords found';
 end if;

  CLOSE db_defpwd_users_cur;
END check_fnd_db_def_pswd;

-- FND_APPLSYSPUB: Check unneccesary privileges in APPLSYSPUB schema
-- Criticality ?
-- AutoFix feasible.
PROCEDURE check_FND_APPLSYSPUB( P_STATUS OUT NOCOPY VARCHAR2,
                                   P_MESSAGE OUT NOCOPY VARCHAR2,
                                   p_details OUT NOCOPY CLOB)
IS
L_COUNT NUMBER;
cursor L_PRIV_CUR IS
select GRANTOR, PRIVILEGE, TABLE_NAME
  from  DBA_TAB_PRIVS
 where  grantee = 'APPLSYSPUB'
 and owner in (select oracle_username
from fnd_oracle_userid
where read_only_flag in ('U', 'E'))
	and  privilege in ('SELECT','INSERT','EXECUTE','DELETE')
   and  privilege in ('SELECT','INSERT','EXECUTE','DELETE')
   and  Rtrim(privilege) || ' ON ' || table_name NOT IN
('INSERT ON FND_SESSIONS',
'INSERT ON FND_UNSUCCESSFUL_LOGINS',
'EXECUTE ON FND_DISCONNECTED',
'EXECUTE ON FND_MESSAGE',
'EXECUTE ON FND_PUB_MESSAGE',
'EXECUTE ON FND_SECURITY_PKG',
'EXECUTE ON FND_SIGNON',
'EXECUTE ON FND_WEBFILEPUB',
'SELECT ON FND_APPLICATION',
'SELECT ON FND_APPLICATION_TL',
'SELECT ON FND_APPLICATION_VL',
'SELECT ON FND_LANGUAGES_TL',
'SELECT ON FND_LANGUAGES_VL',
'SELECT ON FND_LOOKUPS',
'SELECT ON FND_PRODUCT_GROUPS',
'SELECT ON FND_PRODUCT_INSTALLATIONS',
'SELECT ON FND_NEW_MESSAGES',
'INSERT ON FND_SESSIONS#',
'INSERT ON FND_UNSUCCESSFUL_LOGINS#',
'SELECT ON FND_APPLICATION#',
'SELECT ON FND_APPLICATION_TL#',
'SELECT ON FND_PRODUCT_GROUPS#',
'SELECT ON FND_PRODUCT_INSTALLATIONS#',
'SELECT ON FND_LANGUAGES_TL#',
'SELECT ON FND_NEW_MESSAGES#');

l_priv_cur_out l_priv_cur%rowtype;
BEGIN
OPEN L_PRIV_CUR;
LOOP
  FETCH L_PRIV_CUR INTO L_PRIV_CUR_OUT;
  EXIT WHEN L_PRIV_CUR%NOTFOUND;

  P_DETAILS := L_PRIV_CUR_OUT.PRIVILEGE ||' granted on '||L_PRIV_CUR_OUT.TABLE_NAME||' by '||L_PRIV_CUR_OUT.GRANTOR;
  P_DETAILS := P_DETAILS || NEWLINE;
END LOOP;

if l_priv_cur%rowcount > 0 then
    P_STATUS := STATUS_FAILED;
    P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_APPLSYS_FAIL');
else
  P_STATUS := STATUS_PASSED;
  P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_APPLSYS_FIX');
  p_details := 'No unneccesary privileges found.';
END IF;
close l_priv_cur;
END check_fnd_applsyspub;


PROCEDURE fix_fnd_applsyspub(p_status OUT NOCOPY VARCHAR2,
                                P_MESSAGE OUT NOCOPY VARCHAR2,
                                p_details OUT NOCOPY CLOB)
IS
CURSOR cur_priv IS
select GRANTOR,PRIVILEGE, TABLE_NAME
  from  DBA_TAB_PRIVS
 where  grantee = 'APPLSYSPUB'
 and owner in (select oracle_username
from fnd_oracle_userid
where read_only_flag in ('U', 'E'))
	and  privilege in ('SELECT','INSERT','EXECUTE','DELETE')
   and  Rtrim(privilege) || ' ON ' || table_name NOT IN
('INSERT ON FND_SESSIONS',
'INSERT ON FND_UNSUCCESSFUL_LOGINS',
'EXECUTE ON FND_DISCONNECTED',
'EXECUTE ON FND_MESSAGE',
'EXECUTE ON FND_PUB_MESSAGE',
'EXECUTE ON FND_SECURITY_PKG',
'EXECUTE ON FND_SIGNON',
'EXECUTE ON FND_WEBFILEPUB',
'SELECT ON FND_APPLICATION',
'SELECT ON FND_APPLICATION_TL',
'SELECT ON FND_APPLICATION_VL',
'SELECT ON FND_LANGUAGES_TL',
'SELECT ON FND_LANGUAGES_VL',
'SELECT ON FND_LOOKUPS',
'SELECT ON FND_PRODUCT_GROUPS',
'SELECT ON FND_PRODUCT_INSTALLATIONS',
'SELECT ON FND_NEW_MESSAGES',
'INSERT ON FND_SESSIONS#',
'INSERT ON FND_UNSUCCESSFUL_LOGINS#',
'SELECT ON FND_APPLICATION#',
'SELECT ON FND_APPLICATION_TL#',
'SELECT ON FND_PRODUCT_GROUPS#',
'SELECT ON FND_PRODUCT_INSTALLATIONS#',
'SELECT ON FND_LANGUAGES_TL#',
'SELECT ON FND_NEW_MESSAGES#');

cur_priv_out cur_priv%rowtype;
l_status VARCHAR2(2);
l_message VARCHAR2(30);
l_revoke_command VARCHAR2(100);
L_TABLE_NAME VARCHAR2(30);
l_detailed_message CLOB;
BEGIN
  OPEN cur_priv;
  LOOP
    FETCH cur_priv into cur_priv_out;
    EXIT WHEN cur_priv%notfound;

    l_table_name := cur_priv_out.TABLE_NAME;
    if substr(l_table_name,length(l_table_name),1) ='#' then
      l_table_name := substr(l_table_name, 0, length(l_table_name)-1);
    end if;
    L_REVOKE_COMMAND := 'REVOKE '|| CUR_PRIV_OUT.PRIVILEGE ||' ON '|| L_TABLE_NAME ||' FROM APPLSYSPUB';
    P_DETAILS := P_DETAILS || NEWLINE;
    p_details := p_details || 'Executed... ' || l_revoke_command;
    EXECUTE IMMEDIATE l_revoke_command;
  END LOOP;
  CLOSE cur_priv;

  check_fnd_applsyspub(p_status, p_message, l_detailed_message);
  if p_status = status_passed then
    p_message := fnd_message.get_string('FND', 'SEC_CONFIG_APPLSYS_FIX');
  else
    p_message := fnd_message.get_string('FND', 'SEC_CONFIG_UNEXP_ERR');
  end if;

END fix_fnd_applsyspub;


-- FND_COOKIE_DOM: Check the value of ICX Cookie Domain
PROCEDURE check_fnd_cookie_dom( p_status OUT NOCOPY VARCHAR2,
                                   P_MESSAGE OUT NOCOPY VARCHAR2,
                                   p_details OUT NOCOPY CLOB)
IS
l_cookie_dom varchar2(30);
BEGIN
  l_cookie_dom := fnd_profile.value('ICX_SESSION_COOKIE_DOMAIN');
  IF l_cookie_dom <> 'HOST' THEN
    P_STATUS := STATUS_FAILED;
    P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_COOKIE_DOM_FAIL');
    p_details := 'ICX_SESSION_COOKIE_DOMAIN profile option is set to '||l_cookie_dom||'. Recommend value is HOST.';
  ELSE
    P_STATUS := STATUS_PASSED;
    P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_COOKIE_DOM_PASS');
    p_details := 'ICX_SESSION_COOKIE_DOMAIN = '|| l_cookie_dom;
  END IF;
END check_fnd_cookie_dom;

PROCEDURE fix_FND_COOKIE_DOM( P_STATUS OUT NOCOPY VARCHAR2,
                                 P_MESSAGE OUT NOCOPY VARCHAR2,
                                 p_details OUT NOCOPY CLOB)
IS
L_SAVE_STATUS BOOLEAN;
L_DETAILS_CHECK CLOB;
L_APPS_SSO VARCHAR2(240);
BEGIN
  L_APPS_SSO := FND_PROFILE.VALUE('APPS_SSO');
  IF L_APPS_SSO = 'SSWA_SSO' THEN
	P_STATUS := STATUS_FAILED;
	P_MESSAGE := 'Instance is SSO integrated. Host scoping of the Session cookie is not certified for SSO integrated instances. ';
	P_DETAILS := 'Cannot auto-fix. Instance is SSO integrated. Host scoping of the Session cookie is not certified for SSO integrated instances. ';
	P_DETAILS := P_DETAILS || NEWLINE;
	P_DETAILS := P_DETAILS || 'If you have evaluated your instance configuration and still want to set domain of the session cookie to HOST, ';
	P_DETAILS := P_DETAILS || 'please set the Oracle Applications Session Cookie Domain (ICX_SESSIONS_COOKIE_DOMAIN) profile to HOST manually.';

	RETURN;
  END IF;

  L_SAVE_STATUS := FND_PROFILE.SAVE('ICX_SESSION_COOKIE_DOMAIN', 'HOST', 'SITE');
  P_DETAILS := P_DETAILS || NEWLINE || 'Set profile ICX_SESSION_COOKIE_DOMAIN at SITE to HOST : '||BOOL_TO_CHAR(L_SAVE_STATUS);
  COMMIT;

  check_FND_COOKIE_DOM(P_STATUS, P_MESSAGE, L_DETAILS_CHECK);

end fix_fnd_cookie_dom;





-- FND_PROF_ERRORS: Check profile errors
PROCEDURE check_FND_PROF_ERRORS( P_STATUS OUT NOCOPY VARCHAR2,
                                 P_MESSAGE OUT NOCOPY VARCHAR2,
                                 p_details OUT NOCOPY CLOB)
IS
  CURSOR prof_cursor IS
    SELECT   p.profile_option_name PROFILE_NAME,
			 n.user_profile_option_name USER_PROFILE_NAME,
             decode(v.level_id,
                    10001, 'Site',
                    10002, 'Application',
                    10003, 'Responsibility',
                    10004, 'User',
                    10005, 'Server',
                    10007, 'SERVRESP',
                    'UnDef') PROFILE_LEVEL,
             decode(to_char(v.level_id),
                    '10001', '',
                    '10002', app.application_short_name,
                    '10003', rsp.responsibility_key,
                    '10005', svr.node_name,
                    '10006', org.name,
                    '10004', usr.user_name,
                    '10007', 'Serv/resp',
                    'UnDef')        PROFILE_CONTEXT,
             v.profile_option_value PROFILE_VALUE
    FROM     fnd_profile_options p,
             fnd_profile_option_values v,
             fnd_profile_options_tl n,
             fnd_user usr,
             fnd_application app,
             fnd_responsibility rsp,
             fnd_nodes svr,
             hr_operating_units org
    WHERE    p.profile_option_id = v.profile_option_id (+)
    AND      p.profile_option_name = n.profile_option_name
    AND      n.LANGUAGE = 'US'
    AND      ((p.profile_option_name in ('FND_DIAGNOSTICS','DIAGNOSTICS','FND_CUSTOM_OA_DEFINTION') and v.level_id <> 10004 and v.profile_option_value <> 'N') -- Diagnostics should only ever be on at user level
      or (p.profile_option_name like 'F%_VALIDATION_LEVEL' and v.profile_option_value <> 'ERROR') -- Validation profiles should be set to ERROR
      or (p.profile_option_name = 'FND_SECURITY_FILETYPE_RESTRICT_DFLT' and v.profile_option_value not in ('N','Y'))  -- Blacklist behavior (Y) is default and should be on
      or (p.profile_option_name = 'FND_DISABLE_ANTISAMY_FILTER' and v.profile_option_value <> 'N') -- Antisamy checks should be enabled (N)
      or (p.profile_option_name = 'FND_RESTRICT_INPUT' and v.profile_option_value <> 'Y') -- Tag scanner should be enabled
      or (p.profile_option_name = 'BNE_ALLOW_NO_SECURITY_RULE' and v.profile_option_value <> 'N') -- Access to global integrators (integrators without a security rule) should be disabled (N)
             AND      v.level_id <> 10004
             AND      v.profile_option_value <> 'N') -- Diagnostics should only ever be on at user level
    AND      usr.user_id (+) = v.level_value
    AND      rsp.application_id (+) = v.level_value_application_id
    AND      rsp.responsibility_id (+) = v.level_value
    AND      app.application_id (+) = v.level_value
    AND      svr.node_id (+) = v.level_value
    AND      org.organization_id (+) = v.level_value
    ORDER BY p.profile_option_name,
             profile_level;

l_cursor_out prof_cursor%ROWTYPE;
BEGIN
  p_status := status_passed;
  P_DETAILS := 'Profiles with incorrect values set (format: Profile Name(Profile Code) | Level | Context | Value) - ';
  OPEN prof_cursor;
  LOOP
    FETCH prof_cursor
    INTO  l_cursor_out;

    EXIT WHEN prof_cursor%NOTFOUND;
    -- Any one record found? status will be failed.
    IF prof_cursor%FOUND THEN
      p_status := status_failed;
      -- Add information to the message
      p_details := p_details || newline;
      P_DETAILS := P_details || L_CURSOR_OUT.USER_PROFILE_NAME || '(' ||L_CURSOR_OUT.PROFILE_NAME || ') | ' || L_CURSOR_OUT.PROFILE_LEVEL || ' | ' || L_CURSOR_OUT.PROFILE_CONTEXT || ' | ' || L_CURSOR_OUT.PROFILE_VALUE;
      p_details := p_details || ',';
    END IF;
  END LOOP;
  P_DETAILS := SUBSTR(P_details, 1, LENGTH(P_details) - 1);
  P_DETAILS := P_DETAILS || NEWLINE;

  IF P_STATUS = STATUS_FAILED THEN
    P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_PROF_ERRS_FAIL');
  ELSE
    P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_PROF_ERRS_PASS');
    P_DETAILS := 'All profile options set as per recommendation.';
  end if;

  CLOSE prof_cursor;
END check_FND_PROF_ERRORS;


-- AUTO FIX: FND_PROF_ERRORS
-- Set all the recommended profile options profiles errors check
PROCEDURE fix_FND_PROF_ERRORS( p_status OUT NOCOPY VARCHAR2,
                               P_MESSAGE OUT NOCOPY VARCHAR2,
                               p_details OUT NOCOPY CLOB)
IS
  CURSOR prof_cursor(p_profile_name VARCHAR2)
  IS
    SELECT   p.profile_option_name PROFILE_NAME,
             decode(v.level_id,
                    10001, 'SITE',
                    10002, 'APPL',
                    10003, 'RESP',
                    10004, 'USER',
                    10005, 'SERVER',
                    10007, 'SERVRESP',
                    'UnDef')              PROFILE_LEVEL,
             decode(to_char(v.level_id),
               '10001', 'N/A',
               '10002', (SELECT application_name
                         FROM fnd_application_vl
                         WHERE application_id = v.level_value),
               '10003', (SELECT responsibility_name
                         FROM fnd_responsibility_vl
                         WHERE responsibility_id = v.level_value
                         AND application_id = v.level_value_application_id),
               '10005', (SELECT node_name
                         FROM fnd_nodes
                         WHERE node_id = v.level_value),
               '10006', (SELECT name
                         FROM hr_operating_units
                         WHERE organization_id = v.level_value),
               '10004', (SELECT user_name
                         FROM fnd_user
                         WHERE user_id = v.level_value),
               '10007', decode(v.level_value,
                               -1, (SELECT node_name
                                    FROM fnd_nodes
                                    WHERE node_id = v.level_value2),
                               decode(v.level_value2,
                                       -1, (SELECT responsibility_name
                                            FROM fnd_responsibility_vl
                                            WHERE responsibility_id =
                                               v.level_value
                                            AND application_id =
                                               v.level_value_application_id),
                                       (SELECT node_name
                                        FROM fnd_nodes
                                        WHERE node_id = v.level_value2) ||'+'||
                                       (SELECT responsibility_name
                                        FROM fnd_responsibility_vl
                                        WHERE responsibility_id =
                                             v.level_value
                                        AND application_id =
                                             v.level_value_application_id))
                        )) LEVEL_VALUE_DISP,
			 v.level_value                LEVEL_VALUE,
             v.level_value2               LEVEL_VALUE2,
             v.level_value_application_id LEVEL_VALUE_APPL_ID,
             v.profile_option_value       PROFILE_VALUE
    FROM     fnd_profile_options p,
             fnd_profile_option_values v,
             fnd_profile_options_tl n,
             fnd_user usr,
             fnd_application app,
             fnd_responsibility rsp,
             fnd_nodes svr,
             hr_operating_units org
    WHERE    p.profile_option_id = v.profile_option_id (+)
    AND      p.profile_option_name = n.profile_option_name
    AND      n.LANGUAGE = 'US'
    AND      p.profile_option_name = p_profile_name
    AND      usr.user_id (+) = v.level_value
    AND      rsp.application_id (+) = v.level_value_application_id
    AND      rsp.responsibility_id (+) = v.level_value
    AND      app.application_id (+) = v.level_value
    AND      svr.node_id (+) = v.level_value
    AND      org.organization_id (+) = v.level_value
    ORDER BY p.profile_option_name,
             profile_level;

prof_cursor_out prof_cursor%ROWTYPE;
L_SAVE_STATUS BOOLEAN;
l_detailed_message CLOB;
BEGIN

  p_details := '*** Fixing Diagnostic Profiles ***' || NEWLINE;
  -- FND_DIAGNOSTICS
  OPEN prof_cursor('FND_DIAGNOSTICS');
  LOOP
    FETCH prof_cursor
    INTO  prof_cursor_out;

    EXIT WHEN prof_cursor%NOTFOUND;
    IF prof_cursor_out.profile_level <> 'USER'
      AND
      prof_cursor_out.profile_value='Y' THEN
      L_SAVE_STATUS := FND_PROFILE.SAVE('FND_DIAGNOSTICS', 'N', PROF_CURSOR_OUT.PROFILE_LEVEL, PROF_CURSOR_OUT.LEVEL_VALUE, PROF_CURSOR_OUT.LEVEL_VALUE_APPL_ID, PROF_CURSOR_OUT.LEVEL_VALUE2);
      P_DETAILS := P_DETAILS || 'Set profile FND_DIAGNOSTICS at ';
	  P_DETAILS := P_DETAILS || PROF_CURSOR_OUT.PROFILE_LEVEL ||' level, for ' || PROF_CURSOR_OUT.LEVEL_VALUE_DISP || ' to  N. [Save status:';
	  P_DETAILS := P_DETAILS ||bool_to_char(L_SAVE_STATUS) || ']';
	  P_DETAILS := P_DETAILS || NEWLINE;
    END IF;
  END LOOP;
  CLOSE prof_cursor;

  -- DIAGNOSTICS
  OPEN prof_cursor('DIAGNOSTICS');
  LOOP
    FETCH prof_cursor
    INTO  prof_cursor_out;

    EXIT  WHEN prof_cursor%NOTFOUND;
    IF prof_cursor_out.profile_level <> 'USER'
      AND
      prof_cursor_out.profile_value='Y' THEN
      L_SAVE_STATUS := FND_PROFILE.SAVE('DIAGNOSTICS', 'N', PROF_CURSOR_OUT.PROFILE_LEVEL, PROF_CURSOR_OUT.LEVEL_VALUE, PROF_CURSOR_OUT.LEVEL_VALUE_APPL_ID, PROF_CURSOR_OUT.LEVEL_VALUE2);
	  P_DETAILS := P_DETAILS || 'Set profile DIAGNOSTICS at ';
	  P_DETAILS := P_DETAILS || PROF_CURSOR_OUT.PROFILE_LEVEL ||' level, for ' || PROF_CURSOR_OUT.LEVEL_VALUE_DISP || ' to  N. [Save status:';
	  P_DETAILS := P_DETAILS ||bool_to_char(L_SAVE_STATUS) || ']';
	  P_DETAILS := P_DETAILS || NEWLINE ;
    END IF;
  END LOOP;
  CLOSE prof_cursor;

  -- FND_CUSTOM_OA_DEFINTION
  OPEN prof_cursor('FND_CUSTOM_OA_DEFINTION');
  LOOP
    FETCH prof_cursor
    INTO  prof_cursor_out;

    EXIT WHEN prof_cursor%NOTFOUND;
    IF prof_cursor_out.profile_level <> 'USER'
      AND
      PROF_CURSOR_OUT.PROFILE_VALUE='Y' THEN
      L_SAVE_STATUS := FND_PROFILE.SAVE('FND_CUSTOM_OA_DEFINTION', 'N', PROF_CURSOR_OUT.PROFILE_LEVEL, PROF_CURSOR_OUT.LEVEL_VALUE, PROF_CURSOR_OUT.LEVEL_VALUE_APPL_ID, PROF_CURSOR_OUT.LEVEL_VALUE2);
	  P_DETAILS := P_DETAILS || 'Set profile FND_CUSTOM_OA_DEFINTION at ';
	  P_DETAILS := P_DETAILS || PROF_CURSOR_OUT.PROFILE_LEVEL ||' level, for ' || PROF_CURSOR_OUT.LEVEL_VALUE_DISP || ' to  N. [Save status:';
	  P_DETAILS := P_DETAILS ||bool_to_char(L_SAVE_STATUS) || ']';
	  P_DETAILS := P_DETAILS || NEWLINE ;
    END IF;
  END LOOP;
  CLOSE prof_cursor;

  -- VALIDATION PROFILES
  p_details := p_details || newline || '*** Fixing Validation Level Profiles ***' || newline;

  -- These validation profiles supposed to be end dated!!!
  IF is_profile_active('FND_FUNCTION_VALIDATION_LEVEL') THEN
	set_profile_all_levels('FND_FUNCTION_VALIDATION_LEVEL', 'ERROR', p_details);

	-- Also set at Site level to be safe
	l_save_status := FND_PROFILE.SAVE('FND_FUNCTION_VALIDATION_LEVEL', 'ERROR', 'SITE');
	IF l_save_status = false THEN
	p_details := p_details || NEWLINE || '[ERROR] Error while attempting to set profile FND_FUNCTION_VALIDATION_LEVEL at SITE level !';
	END IF;
  END IF;

  IF is_profile_active('FND_VALIDATION_LEVEL') THEN
	  set_profile_all_levels('FND_VALIDATION_LEVEL', 'ERROR', p_details);

	  -- Also set at Site level to be safe
	  l_save_status := FND_PROFILE.SAVE('FND_VALIDATION_LEVEL', 'ERROR', 'SITE');
	  IF l_save_status = false THEN
		p_details := p_details || NEWLINE || '[ERROR] Error while attempting to set profile FND_VALIDATION_LEVEL at SITE level !';
	  END IF;
  END IF;


  IF is_profile_active('FRAMEWORK_VALIDATION_LEVEL') THEN
	  set_profile_all_levels('FRAMEWORK_VALIDATION_LEVEL', 'ERROR', p_details);

	  -- Also set at Site level to be safe
	  l_save_status := FND_PROFILE.SAVE('FRAMEWORK_VALIDATION_LEVEL', 'ERROR', 'SITE');
	  IF l_save_status = false THEN
		p_details := p_details || NEWLINE || '[ERROR] Error while attempting to set profile FRAMEWORK_VALIDATION_LEVEL at SITE level !';
	  END IF;
  END IF;

  -- FND_SECURITY_FILETYPE_RESTRICT_DFLT
  p_details := p_details || NEWLINE || '*** Fixing Security Filetype Restrictions ***' || NEWLINE;
    OPEN prof_cursor('FND_SECURITY_FILETYPE_RESTRICT_DFLT');
  LOOP
    FETCH prof_cursor
    INTO  prof_cursor_out;

    EXIT WHEN prof_cursor%NOTFOUND;
    IF prof_cursor_out.profile_value NOT IN ('Y', 'N') THEN
      L_SAVE_STATUS := FND_PROFILE.SAVE('FND_SECURITY_FILETYPE_RESTRICT_DFLT', 'Y', PROF_CURSOR_OUT.PROFILE_LEVEL, PROF_CURSOR_OUT.LEVEL_VALUE, PROF_CURSOR_OUT.LEVEL_VALUE_APPL_ID, PROF_CURSOR_OUT.LEVEL_VALUE2);
      P_DETAILS := P_DETAILS || NEWLINE ;
	  P_DETAILS := P_DETAILS || 'Set profile FND_SECURITY_FILETYPE_RESTRICT_DFLT at ';
	  P_DETAILS := P_DETAILS || PROF_CURSOR_OUT.PROFILE_LEVEL ||' level, for ' || PROF_CURSOR_OUT.LEVEL_VALUE_DISP || ' to  N. [Save status:';
	  P_DETAILS := P_DETAILS ||bool_to_char(L_SAVE_STATUS) || ']';
    END IF;
  END LOOP;
  CLOSE prof_cursor;


  -- Antisamy Filter
  p_details := p_details || newline || '*** Fixing Anti-Samy filter configuration ***' || newline;

  set_profile_all_levels('FND_DISABLE_ANTISAMY_FILTER', 'N', p_details);
  -- Also set at Site level to be safe
  l_save_status := FND_PROFILE.SAVE('FND_DISABLE_ANTISAMY_FILTER', 'N', 'SITE');
  IF l_save_status = false THEN
	p_details := p_details || NEWLINE || 'Error while attempting to set profile FND_DISABLE_ANTISAMY_FILTER at SITE level !';
  END IF;

  -- Tag Scanner (Restrict Text Input)
  p_details := p_details || newline || '*** Fixing Restricted Text Input (Tag Scanner) profile ***' || newline;

  set_profile_all_levels('FND_RESTRICT_INPUT', 'Y', p_details);
  -- Also set at Site level to be safe
  l_save_status := FND_PROFILE.SAVE('FND_RESTRICT_INPUT', 'Y', 'SITE');
  IF l_save_status = false THEN
 	p_details := p_details || NEWLINE || 'Error while attempting to set profile FND_RESTRICT_INPUT at SITE level !';
  END IF;

  -- Access to global integrators(BNE_ALLOW_NO_SECURITY_RULE)
  p_details := p_details || newline || '*** Fixing Access to global integrators ***' || newline;
  set_profile_all_levels('BNE_ALLOW_NO_SECURITY_RULE', 'N', p_details);

  -- Also set at Site level to be safe
  l_save_status := FND_PROFILE.SAVE('BNE_ALLOW_NO_SECURITY_RULE', 'N', 'SITE');
  IF l_save_status = false THEN
  	p_details := p_details || NEWLINE || 'Error while attempting to set profile at SITE level !';
  END IF;

  check_fnd_prof_errors(p_status, p_message,l_detailed_message);
  if p_status = status_passed then
    p_message := fnd_message.get_string('FND', 'SEC_CONFIG_PROF_ERRS_FIX');
  else
    p_message := fnd_message.get_string('FND', 'SEC_CONFIG_FIX_UNEXP_ERR');
  end if;

  commit;

END fix_FND_PROF_ERRORS;


PROCEDURE check_FND_UNREST_REDIR (P_STATUS OUT NOCOPY VARCHAR2,
                                 P_MESSAGE OUT NOCOPY VARCHAR2,
                                 p_details OUT NOCOPY CLOB) IS
L_PROF_VALUE VARCHAR2(2);
  CURSOR prof_cursor(p_profile_name VARCHAR2)
  IS
    SELECT   p.profile_option_name PROFILE_NAME,
             decode(v.level_id,
                    10001, 'SITE',
                    10002, 'APPL',
                    10003, 'RESP',
                    10004, 'USER',
                    10005, 'SERVER',
                    10007, 'SERVRESP',
                    'UnDef')              PROFILE_LEVEL,
             decode(to_char(v.level_id),
               '10001', 'N/A',
               '10002', (SELECT application_name
                         FROM fnd_application_vl
                         WHERE application_id = v.level_value),
               '10003', (SELECT responsibility_name
                         FROM fnd_responsibility_vl
                         WHERE responsibility_id = v.level_value
                         AND application_id = v.level_value_application_id),
               '10005', (SELECT node_name
                         FROM fnd_nodes
                         WHERE node_id = v.level_value),
               '10006', (SELECT name
                         FROM hr_operating_units
                         WHERE organization_id = v.level_value),
               '10004', (SELECT user_name
                         FROM fnd_user
                         WHERE user_id = v.level_value),
               '10007', decode(v.level_value,
                               -1, (SELECT node_name
                                    FROM fnd_nodes
                                    WHERE node_id = v.level_value2),
                               decode(v.level_value2,
                                       -1, (SELECT responsibility_name
                                            FROM fnd_responsibility_vl
                                            WHERE responsibility_id =
                                               v.level_value
                                            AND application_id =
                                               v.level_value_application_id),
                                       (SELECT node_name
                                        FROM fnd_nodes
                                        WHERE node_id = v.level_value2) ||'+'||
                                       (SELECT responsibility_name
                                        FROM fnd_responsibility_vl
                                        WHERE responsibility_id =
                                             v.level_value
                                        AND application_id =
                                             v.level_value_application_id))
                        )) LEVEL_VALUE_DISP,
			 v.level_value                LEVEL_VALUE,
             v.level_value2               LEVEL_VALUE2,
             v.level_value_application_id LEVEL_VALUE_APPL_ID,
             v.profile_option_value       PROFILE_VALUE
    FROM     fnd_profile_options p,
             fnd_profile_option_values v,
             fnd_profile_options_tl n,
             fnd_user usr,
             fnd_application app,
             fnd_responsibility rsp,
             fnd_nodes svr,
             hr_operating_units org
    WHERE    p.profile_option_id = v.profile_option_id (+)
    AND      p.profile_option_name = n.profile_option_name
    AND      n.LANGUAGE = 'US'
    AND      p.profile_option_name = p_profile_name
    AND      usr.user_id (+) = v.level_value
    AND      rsp.application_id (+) = v.level_value_application_id
    AND      rsp.responsibility_id (+) = v.level_value
    AND      app.application_id (+) = v.level_value
    AND      svr.node_id (+) = v.level_value
    AND      org.organization_id (+) = v.level_value
    ORDER BY p.profile_option_name,
             profile_level;

PROF_CURSOR_OUT PROF_CURSOR%ROWTYPE;
BEGIN
 IF (FND_PROFILE.DEFINED('FND_SEC_ALLOW_UNRESTRICTED_REDIRECT')) THEN
   P_STATUS := STATUS_PASSED;
   P_DETAILS := 'Found Allow unrestricted redirects(FND_SEC_ALLOW_UNRESTRICTED_REDIRECT) profile enabled at the following levels -  ';
   OPEN PROF_CURSOR('FND_SEC_ALLOW_UNRESTRICTED_REDIRECT');
   LOOP
     FETCH PROF_CURSOR INTO PROF_CURSOR_OUT;
     EXIT WHEN PROF_CURSOR%NOTFOUND;

     IF PROF_CURSOR_OUT.PROFILE_VALUE <> 'N' THEN
       P_STATUS := STATUS_FAILED;
       P_DETAILS := P_DETAILS || NEWLINE;
	   P_DETAILS := P_DETAILS || 'Level: ' || PROF_CURSOR_OUT.PROFILE_LEVEL;
	   P_DETAILS := P_DETAILS || ' for '||PROF_CURSOR_OUT.LEVEL_VALUE_DISP;
	   P_DETAILS := P_DETAILS || ', Value: '||PROF_CURSOR_OUT.PROFILE_VALUE;
     END IF;
   END LOOP;

   close prof_cursor;

 ELSE
   P_STATUS := STATUS_FAILED;
   P_DETAILS := 'Allowed Redirects feature itself is missing on this instance ';

 END IF;

 IF P_STATUS = STATUS_FAILED THEN
   P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_UNREST_REDIR_FAIL');
 end if;

 IF P_STATUS = STATUS_PASSED  THEN
   P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_UNREST_REDIR_PASS');
	 P_DETAILS := '';
 end if;
end check_FND_UNREST_REDIR;

PROCEDURE fix_FND_UNREST_REDIR (P_STATUS OUT NOCOPY VARCHAR2,
                                   P_MESSAGE OUT NOCOPY VARCHAR2,
                                   p_details OUT NOCOPY CLOB) IS
L_SAVE_STATUS BOOLEAN;
l_details_check CLOB;
l_details_fix CLOB;
BEGIN

 IF (FND_PROFILE.DEFINED('FND_SEC_ALLOW_UNRESTRICTED_REDIRECT')) THEN
   P_DETAILS := 'Setting Allow Unrestricted Redirects Profile to N at all levels...';
   set_profile_all_levels('FND_SEC_ALLOW_UNRESTRICTED_REDIRECT','N', l_details_fix);

   P_DETAILS := P_DETAILS || NEWLINE || l_details_fix;
   -- Set value to 'N' at SITE level
   L_SAVE_STATUS := FND_PROFILE.SAVE('FND_SEC_ALLOW_UNRESTRICTED_REDIRECT', 'N', 'SITE');
   P_DETAILS := P_DETAILS || NEWLINE || 'Set profile FND_SEC_ALLOW_UNRESTRICTED_REDIRECT at SITE Level to N [Save status:'||BOOL_TO_CHAR(L_SAVE_STATUS)||']';
   commit;

 ELSE
   P_DETAILS := 'Allowed Redirects feature itself is missing on this instance. Please apply OCT 2020 CPU anually. Hence this configuration cannot be auto fixed.' || NEWLINE;
 END IF;
  check_FND_UNREST_REDIR(P_STATUS, P_MESSAGE, L_DETAILS_CHECK);

END fix_FND_UNREST_REDIR;

-- fnd_pswd_hash: Check is password hashing is enabled
-- AutoFix not feasible as of now (long executin time).
PROCEDURE check_FND_PSWD_HASH( p_status OUT NOCOPY VARCHAR2,
                                P_MESSAGE OUT NOCOPY VARCHAR2,
                                p_details OUT NOCOPY CLOB)
IS
l_hash_pswd_status varchar2(2);
BEGIN
  select decode(FND_WEB_SEC.GET_PWD_ENC_MODE,
		null,	STATUS_FAILED, STATUS_PASSED) into l_hash_pswd_status from dual;

	p_status := l_hash_pswd_status;
	if l_hash_pswd_status = STATUS_PASSED then
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_PSWD_HASH_PASS');
	elsif l_hash_pswd_status = STATUS_FAILED then
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_PSWD_HASH_FAIL');
	end if;
	p_details := p_message;
EXCEPTION
WHEN OTHERS THEN
  p_status := status_error;
  P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_FIX_UNEXP_ERR');
  p_details := SQLERRM;
END check_FND_PSWD_HASH;

-- fnd_server_sec: Check if server security is enabled
-- Autofix not feasible as of now
PROCEDURE check_FND_SERVER_SEC( p_status OUT NOCOPY VARCHAR2,
                                P_MESSAGE OUT NOCOPY VARCHAR2,
                                p_details OUT NOCOPY CLOB)
IS
l_srv_sec_status varchar2(2);
BEGIN
	select 'Y'
	into l_srv_sec_status
	from FND_NODES
	where server_address = '*'
	and server_id='SECURE';

	if l_srv_sec_status = 'Y' then
		p_status := status_passed;
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_SERV_SEC_PASS');
	else
		p_status := status_failed;
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_SERV_SEC_FAIL');
	end if;
	p_details := p_message;
EXCEPTION
WHEN NO_DATA_FOUND THEN
	p_status := status_failed;
	p_message := fnd_message.get_string('FND', 'SEC_CONFIG_SERV_SEC_FAIL');
	p_details := p_message;
WHEN OTHERS THEN
  p_status := status_error;
  P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_FIX_UNEXP_ERR');
  p_details := SQLERRM;
END check_FND_SERVER_SEC;

--fnd_miss_prof: Check for critical missing security profiles
-- Autofix (?)
PROCEDURE check_FND_MISS_PROF( p_status OUT NOCOPY VARCHAR2,
                                P_MESSAGE OUT NOCOPY VARCHAR2,
                                p_details OUT NOCOPY CLOB)
IS
CURSOR miss_prof_cursor
	IS select rp.profile_name
		from fnd_profile_options p,
		(select 'FND_SERVER_SEC' profile_name from dual union
		select 'FND_SERVER_IP_SEC' profile_name from dual
		) rp
		where rp.profile_name = p.profile_option_name (+)
		and p.profile_option_name is null;

l_prof_name varchar2(100);
BEGIN
	p_status := status_passed;
	OPEN miss_prof_cursor;
	LOOP
		FETCH miss_prof_cursor INTO  l_prof_name;
		EXIT WHEN miss_prof_cursor%NOTFOUND;

		IF miss_prof_cursor%FOUND THEN
			p_status := status_failed;
			p_details := p_details || l_prof_name || NEWLINE;
		END IF;
	END LOOP;

	IF p_status = status_failed THEN
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_MISS_SERV_FAIL');
	ELSE
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_MISS_SERV_PASS');
	END IF;

	EXCEPTION
		WHEN OTHERS THEN
			p_status := status_error;
			p_message := fnd_message.get_string('FND', 'SEC_CONFIG_FIX_UNEXP_ERR');
			p_details := SQLERRM;
END check_FND_MISS_PROF;

PROCEDURE check_FND_MISS_ATT_PROF( p_status OUT NOCOPY VARCHAR2,
                                P_MESSAGE OUT NOCOPY VARCHAR2,
                                p_details OUT NOCOPY CLOB)
IS
CURSOR miss_prof_cursor
	IS select rp.profile_name
		from fnd_profile_options p,
		(select 'UPLOAD_FILE_SIZE_LIMIT' profile_name from dual
		) rp
		where rp.profile_name = p.profile_option_name (+)
		and p.profile_option_name is null;

l_prof_name varchar2(100);
BEGIN
	p_status := status_passed;
	OPEN miss_prof_cursor;
	LOOP
		FETCH miss_prof_cursor INTO  l_prof_name;
		EXIT WHEN miss_prof_cursor%NOTFOUND;

		IF miss_prof_cursor%FOUND THEN
			p_status := status_failed;
			p_details := p_details || l_prof_name || NEWLINE;
		END IF;
	END LOOP;

	IF p_status = status_failed THEN
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_MISS_ATT_FAIL');
	ELSE
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_MISS_ATT_PASS');
	END IF;

	EXCEPTION
		WHEN OTHERS THEN
			p_status := status_error;
			p_message := fnd_message.get_string('FND', 'SEC_CONFIG_FIX_UNEXP_ERR');
			p_details := SQLERRM;
END check_FND_MISS_ATT_PROF;

-- fnd_ssl_enableb: Check if SSL is enabled
-- Autofix NOT feasible
PROCEDURE check_FND_SSL_ENABLED( p_status OUT NOCOPY VARCHAR2,
                                P_MESSAGE OUT NOCOPY VARCHAR2,
                                p_details OUT NOCOPY CLOB)
IS
l_protocol varchar2(10);
BEGIN
	select FND_WEB_CONFIG.PROTOCOL into l_protocol from dual;

	IF UPPER(SUBSTR(l_protocol,1,5)) = 'HTTPS' THEN
		p_status := status_passed;
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_SSL_PASS');
		p_details := 'SSL/TLS enabled. Web Config Protocol: '||l_protocol;
	ELSE
		p_status := status_failed;
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_SSL_FAIL');
		p_details := 'SSL/TLS is NOT enabled. Web Config Protocol: '||l_protocol;
	END IF;

	EXCEPTION
		WHEN OTHERS THEN
			p_status := status_error;
			p_message := fnd_message.get_string('FND', 'SEC_CONFIG_UNEXP_ERR');
			p_details := SQLERRM;
END check_FND_SSL_ENABLED;

-- fnd_restrict_input: Check if restricted text input has been enabled.
-- AutoFix possbile. (?)
PROCEDURE check_FND_JSP_UNREST_ACC( P_STATUS OUT NOCOPY VARCHAR2,
                                P_MESSAGE OUT NOCOPY VARCHAR2,
                                p_details OUT NOCOPY CLOB)
IS
    CURSOR check_ares_prof_cursor IS
    SELECT   p.profile_option_name PROFILE_NAME,
             decode(v.level_id,
                    10001, 'SITE',
                    10002, 'APPL',
                    10003, 'RESP',
                    10004, 'USER',
                    10005, 'SERVER',
                    10007, 'SERVRESP',
                    'UnDef') PROFILE_LEVEL,
             decode(to_char(v.level_id),
                    '10001', '',
                    '10002', app.application_short_name,
                    '10003', rsp.responsibility_key,
                    '10005', svr.node_name,
                    '10006', org.name,
                    '10004', usr.user_name,
                    '10007', 'Serv/resp',
                    'UnDef')        PROFILE_CONTEXT,
             v.profile_option_value PROFILE_VALUE
    FROM     fnd_profile_options p,
             fnd_profile_option_values v,
             fnd_profile_options_tl n,
             fnd_user usr,
             fnd_application app,
             fnd_responsibility rsp,
             fnd_nodes svr,
             hr_operating_units org
    WHERE    p.profile_option_id = v.profile_option_id (+)
    AND      p.profile_option_name = n.profile_option_name
    AND      n.LANGUAGE = 'US'
    AND      ((
                               p.profile_option_name = 'FND_SEC_ALLOWED_RESOURCES'
                      AND      v.profile_option_value <> 'CONFIG') -- -- Recommend turning on resource restriction (see Security Admin Guide)
             )
    AND      usr.user_id (+) = v.level_value
    AND      rsp.application_id (+) = v.level_value_application_id
    AND      rsp.responsibility_id (+) = v.level_value
    AND      app.application_id (+) = v.level_value
    AND      svr.node_id (+) = v.level_value
    AND      org.organization_id (+) = v.level_value
    ORDER BY p.profile_option_name,
             profile_level;

    CURSOR check_ajsp_prof_cursor IS
    SELECT   p.profile_option_name PROFILE_NAME,
             decode(v.level_id,
                    10001, 'SITE',
                    10002, 'APPL',
                    10003, 'RESP',
                    10004, 'USER',
                    10005, 'SERVER',
                    10007, 'SERVRESP',
                    'UnDef') PROFILE_LEVEL,
             decode(to_char(v.level_id),
                    '10001', '',
                    '10002', app.application_short_name,
                    '10003', rsp.responsibility_key,
                    '10005', svr.node_name,
                    '10006', org.name,
                    '10004', usr.user_name,
                    '10007', 'Serv/resp',
                    'UnDef')        PROFILE_CONTEXT,
             v.profile_option_value PROFILE_VALUE
    FROM     fnd_profile_options p,
             fnd_profile_option_values v,
             fnd_profile_options_tl n,
             fnd_user usr,
             fnd_application app,
             fnd_responsibility rsp,
             fnd_nodes svr,
             hr_operating_units org
    WHERE    p.profile_option_id = v.profile_option_id (+)
    AND      p.profile_option_name = n.profile_option_name
    AND      n.LANGUAGE = 'US'
    AND      ((
                               p.profile_option_name = 'FND_SEC_ALLOW_JSP_UNRESTRICTED_ACCESS'
                      AND      v.profile_option_value <> 'N')  -- Recommend turning off allowed JSPs (see Security Admin Guide)
             )
    AND      usr.user_id (+) = v.level_value
    AND      rsp.application_id (+) = v.level_value_application_id
    AND      rsp.responsibility_id (+) = v.level_value
    AND      app.application_id (+) = v.level_value
    AND      svr.node_id (+) = v.level_value
    AND      org.organization_id (+) = v.level_value
    ORDER BY p.profile_option_name,
             profile_level;

check_prof_cursor_out check_ajsp_prof_cursor%ROWTYPE;
l_pass_msg varchar2(30);
l_fail_msg varchar2(30);
l_module varchar2(80);
BEGIN
  p_status := status_passed;
  l_module := 'fnd.plsql.FND_GUIDELINES.check_FND_JSP_UNREST_ACC';
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Begin - p_status is passed by default!');
    end if;



  if (allowed_resources_prof_exist) then
         if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'allowed resource prof exists...ref ALLOWED RESOURCEs');
    end if;

       l_pass_msg := 'SEC_CONFIG_ALLOW_RES_PASS';
       l_fail_msg := 'SEC_CONFIG_ALLOW_RES_FAIL';

       OPEN check_ares_prof_cursor;
       LOOP
         FETCH check_ares_prof_cursor
         INTO  check_prof_cursor_out;
         EXIT  WHEN check_ares_prof_cursor%NOTFOUND;

      IF check_ares_prof_cursor%FOUND THEN
      	p_status := status_failed;
      	p_details := p_details || NEWLINE;
      	p_details := p_details || check_prof_cursor_out.profile_name || ' has been set to '|| check_prof_cursor_out.profile_value ||' at level: ' ||  check_prof_cursor_out.profile_level || ' for ' || check_prof_cursor_out.profile_context;
      END IF;

       END LOOP;
       CLOSE check_ares_prof_cursor;

  elsif (allowed_jsps_prof_exist) then
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'allowed resource prof DOES NOT exist...ref ALLOWED JSPs');
        end if;

       l_pass_msg := 'SEC_CONFIG_ALLOW_JSP_PASS';
       l_fail_msg := 'SEC_CONFIG_ALLOW_JSP_FAIL';


       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'set pass and fail msg');
       end if;

       OPEN check_ajsp_prof_cursor;
       LOOP
         if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'looping through values for allowed jsp profile');
         end if;

         FETCH check_ajsp_prof_cursor
         INTO  check_prof_cursor_out;
         EXIT  WHEN check_ajsp_prof_cursor%NOTFOUND;

      IF check_ajsp_prof_cursor%FOUND THEN
         if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'JSP profile found to set to non recommended value....set status failed');
        end if;

      	p_status := status_failed;
      	p_details := p_details || NEWLINE;
      	p_details := p_details || check_prof_cursor_out.profile_name || ' has been set to '|| check_prof_cursor_out.profile_value ||' at level: ' ||  check_prof_cursor_out.profile_level || ' for ' || check_prof_cursor_out.profile_context;
      END IF;

       END LOOP;
       CLOSE check_ajsp_prof_cursor;

  else
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Neither Allowed Resources Not JSP profile found....set status failed');
        end if;

      	p_status := status_failed;
      	p_details := p_details || NEWLINE;
      	p_details := p_details || ' Neither Allowed Resources Nor Allowed JSPs feature is available on this instance. Please apply OCT 2020 CPU to get Allowed Resources feature';

  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Done verifying profiles...status is....:'||p_status);
  end if;

  IF p_status = status_failed THEN
	p_message := fnd_message.get_string('FND', l_fail_msg);
  ELSE
	p_message :=  fnd_message.get_string('FND', l_pass_msg);
  END IF;
EXCEPTION
WHEN OTHERS THEN
 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'in exception');
  end if;

  p_status := status_error;
  P_MESSAGE := 'Unexpected error occurred.';
  p_details := SQLERRM;
END check_FND_JSP_UNREST_ACC;

PROCEDURE fix_FND_JSP_UNREST_ACC (P_STATUS OUT NOCOPY VARCHAR2,
                                   P_MESSAGE OUT NOCOPY VARCHAR2,
                                   p_details OUT NOCOPY CLOB) IS
L_SAVE_STATUS BOOLEAN;
l_details_check CLOB;
l_details_fix CLOB;
l_message_check varchar2(4000);
l_pass_msg varchar2(80);


BEGIN

  if (allowed_resources_prof_exist) then
	    p_details := 'Setting Allowed Resources to Configured at all levels...' || NEWLINE;
	    set_profile_all_levels('FND_SEC_ALLOWED_RESOURCES', 'CONFIG',l_details_fix);

	   -- Also set at Site level to be safe
   	  l_save_status := FND_PROFILE.SAVE('FND_SEC_ALLOWED_RESOURCES', 'CONFIG', 'SITE');
  	  IF l_save_status = false THEN
	   	   p_details := p_details || NEWLINE || 'Error while attempting to set profile FND_SEC_ALLOWED_RESOURCES at SITE level !';
	    END IF;

      l_pass_msg := 'SEC_CONFIG_ALLOW_RES_FIX';

   elsif (allowed_jsps_prof_exist) then
           p_details := 'Setting Allow JSP Unrestricted Access to N at all levels...' || NEWLINE;
	    set_profile_all_levels('FND_SEC_ALLOW_JSP_UNRESTRICTED_ACCESS', 'N',l_details_fix);

	   -- Also set at Site level to be safe
   	  l_save_status := FND_PROFILE.SAVE('FND_SEC_ALLOW_JSP_UNRESTRICTED_ACCESS', 'N', 'SITE');
  	  IF l_save_status = false THEN
	   	   p_details := p_details || NEWLINE || 'Error while attempting to set profile FND_SEC_ALLOW_JSP_UNRESTRICTED_ACCESS at SITE level !';
	    END IF;

      l_pass_msg := 'SEC_CONFIG_ALLOW_JSP_FIX';

   else
           p_details := 'Neither Allowed Resources Nor Allowed JSPs feature is available on this instance. Please apply OCT 2020 CPU manually. This configuration can NOT be auto fixed...' || NEWLINE;

  end if;


	check_FND_JSP_UNREST_ACC(p_status, l_message_check, l_details_check);
	IF p_status = status_passed THEN
		p_message := fnd_message.get_string('FND', l_pass_msg);
	ELSIF p_status = status_failed THEN
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_FIX_FAIL');
	ELSE
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_FIX_UNEXP_ERR');
	END IF;

	p_details := p_details || NEWLINE || l_details_check;

EXCEPTION
	WHEN OTHERS THEN
		p_status := status_error;
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_FIX_UNEXP_ERR');
		p_details := SQLERRM;
END fix_FND_JSP_UNREST_ACC;


PROCEDURE check_FND_AUDIT_PROF( P_STATUS OUT NOCOPY VARCHAR2,
                                P_MESSAGE OUT NOCOPY VARCHAR2,
                                p_details OUT NOCOPY CLOB) IS
l_aflog_enabled_site varchar2(240);
l_aflog_level_site varchar2(240);
l_signon_audit_site varchar2(240);
l_audit_trail varchar2(240);
l_audit_sys_op varchar2(240);
BEGIN
p_status := STATUS_PASSED;
p_details := '';
p_message := '';

-- (1) FND Debug logging should be enabled at Site for atleast Unexpected level: Check AFLOG_ENABLED and AFLOG_LEVEL
l_aflog_enabled_site := FND_PROFILE.value_specific('AFLOG_ENABLED', -1, -1, -1, -1, -1);
l_aflog_level_site := FND_PROFILE.value_specific('AFLOG_LEVEL', -1, -1, -1, -1, -1);
if l_aflog_enabled_site = 'Y' then
	if l_aflog_level_site > 6 then
		p_status := STATUS_FAILED;
		p_details := p_details || 'AFLOG_LEVEL Profile is set at a logging level higher than the recommended logging level. ';
		p_details := p_details || 'FND Debug Log Level should set to at least Unexpected at Site level.';
		p_details := p_details || NEWLINE;
	end if;
else
	p_status := STATUS_FAILED;
	p_details := p_details || 'AFLOG_ENABLED Profile is set to N at the Site level. ';
	p_details := p_details || 'FND Debug Log Enabled should be set to Yes at Site level.';
	p_details := p_details || NEWLINE;
end if;

-- (2) Sign-on Auditing should be set at Site level for Forms
l_signon_audit_site := FND_PROFILE.value_specific('SIGNONAUDIT:LEVEL', -1, -1, -1, -1, -1);
if l_signon_audit_site <> 'D' then
	p_status := STATUS_FAILED;
	p_details := p_details || 'SIGNONAUDIT:LEVEL Profile is set to '||l_signon_audit_site||' at Site level. ';
	p_details := p_details || 'Signon Audit should be set to Forms at Site Level';
	p_details := p_details || NEWLINE;
end if;

if p_status = STATUS_PASSED then
	p_message := fnd_message.get_string('FND', 'SEC_CONFIG_AUDIT_PROF_PASS');
else
	p_message := fnd_message.get_string('FND', 'SEC_CONFIG_AUDIT_PROF_FAIL');
end if;

EXCEPTION
WHEN OTHERS THEN
  p_status := status_error;
  p_message := 'Unexpected error occurred.';
  p_details := SQLERRM;

END check_FND_AUDIT_PROF;


PROCEDURE fix_FND_AUDIT_PROF (P_STATUS OUT NOCOPY VARCHAR2,
                                   P_MESSAGE OUT NOCOPY VARCHAR2,
                                   p_details OUT NOCOPY CLOB) IS
L_SAVE_STATUS BOOLEAN;
l_details_check CLOB;
l_details_fix CLOB;
l_message_check varchar2(4000);
l_aflog_level_site varchar2(240);
l_aflog_enabled_site varchar2(240);
l_signon_audit_site varchar2(240);
BEGIN
-- (1) FND Debug logging should be enabled at Site for atleast Unexpected level: Check AFLOG_ENABLED and AFLOG_LEVEL
p_details := '';

l_aflog_enabled_site := FND_PROFILE.value_specific('AFLOG_ENABLED', -1, -1, -1, -1, -1);
if l_aflog_enabled_site <> 'Y' then
	l_save_status := FND_PROFILE.save('AFLOG_ENABLED', 'Y', 'SITE');
	p_details := p_details || 'Found AFLOG_ENABLED set at SITE level to value: '||l_aflog_enabled_site;
	p_details := p_details || NEWLINE;
	p_details := p_details || 'Setting profile AFLOG_ENABLED at SITE level to Y [Save Status: '||BOOL_TO_CHAR(L_SAVE_STATUS)||']';
	p_details := p_details || NEWLINE;
end if;

l_aflog_level_site := FND_PROFILE.value_specific('AFLOG_LEVEL', -1, -1, -1, -1, -1);
if l_aflog_level_site > 6 then
	l_save_status := FND_PROFILE.save('AFLOG_LEVEL', '6', 'SITE');
	p_details := p_details || 'Found AFLOG_LEVEL set at SITE level to value: '||l_aflog_enabled_site;
	p_details := p_details || NEWLINE;
	p_details := p_details || 'Setting profile AFLOG_LEVEL at SITE level to 6 [Save Status: '||BOOL_TO_CHAR(L_SAVE_STATUS)||']';
	p_details := p_details || NEWLINE;
end if;

-- (2) Sign-on Auditing should be set at Site level for Forms
l_signon_audit_site := FND_PROFILE.value_specific('SIGNONAUDIT:LEVEL', -1, -1, -1, -1, -1);
if l_signon_audit_site <> 'D' then
	l_save_status := FND_PROFILE.save('SIGNONAUDIT:LEVEL', 'D', 'SITE');
	p_details := p_details || 'Found SIGNONAUDIT:LEVEL set at SITE level to value: '||l_signon_audit_site;
	p_details := p_details || NEWLINE;
	p_details := p_details || 'Setting profile SIGNONAUDIT:LEVEL at SITE level to D [Save Status: '||BOOL_TO_CHAR(L_SAVE_STATUS)||']';
	p_details := p_details || NEWLINE;
end if;

check_FND_AUDIT_PROF(p_status, l_message_check, l_details_check);
	IF p_status = status_passed THEN
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_AUDIT_FIX');
	ELSIF p_status = status_failed THEN
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_FIX_FAIL');
	ELSE
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_FIX_UNEXP_ERR');
	END IF;

	p_details := p_details || NEWLINE || l_details_check;

END fix_FND_AUDIT_PROF;

-- fnd_apps_ind_public: Check the Index privilege is not granted to PUBLIC
PROCEDURE check_FND_APPS_IND_PUBLIC( P_STATUS OUT NOCOPY VARCHAR2,
                                     P_MESSAGE OUT NOCOPY VARCHAR2,
                                     P_DETAILS OUT NOCOPY CLOB)
IS
  l_grantee        VARCHAR2(100);
  l_owner          VARCHAR2(100);
  l_tablename     VARCHAR2(100);

  CURSOR dba_ind_public_cur IS
	SELECT  grantee
		,owner
		,table_name
	FROM    dba_tab_privs
	WHERE   privilege = 'INDEX'
	AND     grantee = 'PUBLIC';

BEGIN

  p_message := '';
  OPEN dba_ind_public_cur;
  LOOP
    FETCH dba_ind_public_cur
    INTO  l_grantee,
          l_owner,
		  l_tablename;
    EXIT WHEN dba_ind_public_cur%NOTFOUND;
    P_DETAILS := P_DETAILS||L_TABLENAME|| '['||L_OWNER||']';
    p_details := p_details||', ';
  END LOOP;

  IF DBA_IND_PUBLIC_CUR%ROWCOUNT > 0 THEN
    P_STATUS := STATUS_FAILED;
    p_message := fnd_message.get_string('FND', 'SEC_CONFIG_CREATE_INDEX_FAIL');
    P_DETAILS := 'Object which is granted INDEX privilege to PUBLIC (format: Table name[Owner]) - '||NEWLINE||P_DETAILS;
    P_DETAILS := SUBSTR(P_details, 1, LENGTH(P_details) - 1);
    P_DETAILS := P_DETAILS||NEWLINE;
  ELSE
    P_STATUS := STATUS_PASSED;
    P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_CREATE_INDEX_PASS');
    p_details := 'No Object which is granted INDEX privilege to PUBLIC is found';
 end if;

  CLOSE dba_ind_public_cur;
END check_FND_APPS_IND_PUBLIC;

-- wf_admin_not_public: Check whether Oracle Workflow Admin access is restricted
PROCEDURE check_WF_ADMIN_NOT_PUBLIC( p_status OUT NOCOPY VARCHAR2,
                                P_MESSAGE OUT NOCOPY VARCHAR2,
                                p_details OUT NOCOPY CLOB)
IS
l_count number(10);
BEGIN
	select count(*) into l_count from WF_RESOURCES where NAME = 'WF_ADMIN_ROLE' and TEXT = '*';

	IF l_count = 0 THEN
		p_status := status_passed;
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_WF_ADMIN_PASS');
		p_details := p_message;
	ELSE
		p_status := status_failed;
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_WF_ADMIN_FAIL');
		p_details := p_message;
	END IF;

	EXCEPTION
		WHEN OTHERS THEN
			p_status := status_error;
			p_message := fnd_message.get_string('FND', 'SEC_CONFIG_UNEXP_ERR');
			p_details := SQLERRM;
END check_WF_ADMIN_NOT_PUBLIC;

-- fnd_init_ora: Check whether secure configuration recommended database initialization parameters have been set.
PROCEDURE check_FND_INIT_ORA_PARAMS( p_status OUT NOCOPY VARCHAR2,
                                P_MESSAGE OUT NOCOPY VARCHAR2,
                                p_details OUT NOCOPY CLOB)
IS
l_count1 number(10);
l_count2 number(10);
l_count3 number(10);
l_count4 number(10);
l_count5 number(10);
BEGIN

p_status := STATUS_PASSED;
p_details := '';
p_message := '';

select count(*) into l_count1 from V$PARAMETER where NAME='remote_os_authent' and VALUE='FALSE';
select count(*) into l_count2 from V$PARAMETER where NAME='remote_os_roles' and VALUE='FALSE';
select count(*) into l_count3 from V$PARAMETER where NAME='_trace_files_public' and VALUE='TRUE';
select count(*) into l_count4 from V$PARAMETER where NAME='utl_file_dir' and VALUE='*';
select count(*) into l_count5 from V$PARAMETER where NAME='O7_DICTIONARY_ACCESSIBILITY' and VALUE='TRUE';

	IF l_count1 = 0 THEN
		p_status := STATUS_FAILED;
		p_details := p_details || 'Remove operating system trusted remote logon. ';
		p_details := p_details || 'Database initialization parameter remote_os_authent not set according to recommended security values.';
		p_details := p_details || NEWLINE;
	END IF;

	IF l_count2 = 0 THEN
		p_status := STATUS_FAILED;
		p_details := p_details || 'Remove operating system trusted remote roles. ';
		p_details := p_details || 'Database initialization parameter remote_os_roles not set according to recommended security values.';
		p_details := p_details || NEWLINE;
	END IF;

	IF l_count3 = 1 THEN
		p_status := STATUS_FAILED;
		p_details := p_details || 'Restrict access to SQL trace files. ';
		p_details := p_details || 'Database initialization parameter _trace_files_public not set according to recommended security values.';
		p_details := p_details || NEWLINE;
	END IF;

	IF l_count4 = 1 THEN
		p_status := STATUS_FAILED;
		p_details := p_details || 'Limit file system access within PL/SQL. ';
		p_details := p_details || 'Database initialization parameter utl_file_dir not set according to recommended security values.';
		p_details := p_details || NEWLINE;
	END IF;

	IF l_count5 = 1 THEN
		p_status := STATUS_FAILED;
		p_details := p_details || 'Limit dictionary access. ';
		p_details := p_details || 'Database initialization parameter O7_DICTIONARY_ACCESSIBILITY not set according to recommended security values.';
		p_details := p_details || NEWLINE;
	END IF;

	if p_status = STATUS_PASSED then
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_ORA_PARAMS_PASS');
	else
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_ORA_PARAMS_FAIL');
	end if;

	EXCEPTION
		WHEN OTHERS THEN
			p_status := status_error;
			p_message := fnd_message.get_string('FND', 'SEC_CONFIG_UNEXP_ERR');
			p_details := SQLERRM;
END check_FND_INIT_ORA_PARAMS;

function allowed_resources_prof_exist return boolean is
   l_prof varchar2(80);
   l_defined boolean;
   l_module varchar2(256);
begin
   l_module := 'fnd.plsql.FND_GUIDELINES.allowed_resources_prof_exist';

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Begin');
    end if;

   fnd_profile.get_specific(name_z => 'FND_SEC_ALLOWED_RESOURCES',val_z => l_prof, defined_z => l_defined);

   if (l_prof is null or not l_defined) then
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'FND_SEC_ALLOWED_RESOURCES does not exist - use FND_SEC_ALLOW_JSP_UNRESTRICTED_ACCESS');
       end if;
      return false;
   else
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'FND_SEC_ALLOWED_RESOURCES does exist - do not use FND_SEC_ALLOW_JSP_UNRESTRICTED_ACCESS');
       end if;
      return true;
   end if;

end;

function allowed_jsps_prof_exist return boolean is
   l_prof varchar2(80);
   l_defined boolean;
   l_module varchar2(256);
begin
   l_module := 'fnd.plsql.FND_GUIDELINES.allowed_jsps_prof_exist';

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Begin');
    end if;

   fnd_profile.get_specific(name_z => 'FND_SEC_ALLOW_JSP_UNRESTRICTED_ACCESS',val_z => l_prof, defined_z => l_defined);

   if (l_prof is null or not l_defined) then
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'FND_SEC_ALLOW_JSP_UNRESTRICTED_ACCESS does not exist - apply OCT 2020 CPU');
       end if;
      return false;
   else
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'FND_SEC_ALLOW_JSP_UNRESTRICTED_ACCESS does exist ');
       end if;
      return true;
   end if;

end;

-- wf_email_login: Ensure login is required from Workflow embedded URL in email
procedure check_WF_EMAIL_LOGIN( P_STATUS OUT NOCOPY VARCHAR2,
                                     P_MESSAGE OUT NOCOPY VARCHAR2,
                                     P_DETAILS OUT NOCOPY CLOB)
is
	cursor wf_ntf_access_cur is
		select
			p.profile_option_name "INTERNAL_NAME",
			n.user_profile_option_name "DISPLAY_NAME",
			decode(v.level_id,
			10001, 'Site',
			10002, 'Application',
			10003, 'Responsibility',
			10004, 'User',
			10005, 'Server',
			10007, 'SERVRESP',
			'UnDef') "LEVEL",
			nvl(decode(to_char(v.level_id),
			'10001', '',
			'10002', app.application_short_name,
			'10003', rsp.responsibility_key,
			'10005', svr.node_name,
			'10006', org.name,
			'10004', usr.user_name,
			'10007', 'Serv/resp',
			'UnDef'), 'N/A') "CONTEXT",
			v.profile_option_value "VALUE"
		from fnd_profile_options p,
			fnd_profile_option_values v,
			fnd_profile_options_tl n,
			fnd_user usr,
			fnd_application app,
			fnd_responsibility rsp,
			fnd_nodes svr,
			hr_operating_units org
		where p.profile_option_id = v.profile_option_id (+)
			and p.profile_option_name = n.profile_option_name
			and n.language = 'US'
			and (
				  (p.profile_option_name = 'WF_VALIDATE_NTF_ACCESS' and v.profile_option_value <> 'N') -- GUEST Access should be Off
				)
			and usr.user_id (+) = v.level_value
			and rsp.application_id (+) = v.level_value_application_id
			and rsp.responsibility_id (+) = v.level_value
			and app.application_id (+) = v.level_value
			and svr.node_id (+) = v.level_value
			and org.organization_id (+) = v.level_value
			order by p.profile_option_name, "LEVEL";

	wf_ntf_access_cur_out wf_ntf_access_cur%ROWTYPE;
begin
	p_status := STATUS_PASSED;
	p_message := '';
	p_details := '';

	open wf_ntf_access_cur;
	loop
		fetch wf_ntf_access_cur into wf_ntf_access_cur_out;
		exit when wf_ntf_access_cur%NOTFOUND;

		if (p_status = STATUS_PASSED) then
			p_status := STATUS_FAILED;
		end if;

		if(wf_ntf_access_cur_out.LEVEL='Site') then
			p_details := p_details || 'Profile Option '||wf_ntf_access_cur_out.DISPLAY_NAME||'['||wf_ntf_access_cur_out.INTERNAL_NAME;
			p_details := p_details ||'] set to value:'||wf_ntf_access_cur_out.VALUE||' at level:'||wf_ntf_access_cur_out.LEVEL;
		else
			p_details := p_details || 'Profile Option '||wf_ntf_access_cur_out.DISPLAY_NAME||'['||wf_ntf_access_cur_out.INTERNAL_NAME;
			p_details := p_details ||'] set to value:'||wf_ntf_access_cur_out.VALUE||' at level:'||wf_ntf_access_cur_out.LEVEL;
			p_details := p_details || ' for context: '||wf_ntf_access_cur_out.CONTEXT;
		end if;

		p_details := p_details || NEWLINE;
	end loop;
	close wf_ntf_access_cur;

	if (p_status = STATUS_PASSED) then
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_WFEMAIL_PASS');
		p_details := p_message;
	else
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_WFEMAIL_FAIL');
		p_details := p_details;
	end if;

exception
	when others then
		p_status := STATUS_ERROR;
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_UNEXP_ERR');
		p_details := SQLERRM;
end check_WF_EMAIL_LOGIN;


-- sec_db_pswd_prof: Implement two profiles for password management
procedure check_SEC_DB_PSWD_PROF( P_STATUS OUT NOCOPY VARCHAR2,
                                     P_MESSAGE OUT NOCOPY VARCHAR2,
                                     P_DETAILS OUT NOCOPY CLOB)
is
	cursor check_dba_user_cur is
		select USERNAME
		from DBA_USERS
		where PROFILE='DEFAULT'
		and USERNAME in (  select ORACLE_USERNAME from FND_ORACLE_USERID where READ_ONLY_FLAG<>'X');

	check_dba_user_cur_out check_dba_user_cur%ROWTYPE;
begin
	p_status := STATUS_PASSED;
	p_message := '';
	p_details := '';

	open check_dba_user_cur;
	loop
		fetch check_dba_user_cur into check_dba_user_cur_out;
		exit when check_dba_user_cur%NOTFOUND;

		if (p_status = STATUS_PASSED) then
			p_status := STATUS_FAILED;
			p_details := p_details || 'DBA_USERS.PROFILE found set to DEFAULT for the following users: '||NEWLINE;
		end if;

		p_details := p_details || check_dba_user_cur_out.USERNAME;
		p_details := p_details || NEWLINE;
	end loop;
	close check_dba_user_cur;

	if (p_status = STATUS_PASSED) then
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_SEC_DBPSWD_PASS');
		p_details := p_message;
	else
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_SEC_DBPSWD_FAIL');
		p_details := p_details;
	end if;

exception
	when others then
		p_status := STATUS_ERROR;
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_UNEXP_ERR');
		p_details := SQLERRM;
end check_SEC_DB_PSWD_PROF;

-- irec_file_upload: Set other security related profile options - IRC
procedure check_IREC_FILE_UPLOAD( P_STATUS OUT NOCOPY VARCHAR2,
                                     P_MESSAGE OUT NOCOPY VARCHAR2,
                                     P_DETAILS OUT NOCOPY CLOB)
is
	CURSOR irec_prof_cur IS
    SELECT   p.profile_option_name "INTERNAL_NAME",
			 n.user_profile_option_name "DISPLAY_NAME",
             decode(v.level_id,
                    10001, 'Site',
                    10002, 'Application',
                    10003, 'Responsibility',
                    10004, 'User',
                    10005, 'Server',
                    10007, 'SERVRESP',
                    'UnDef') "LEVEL",
             decode(to_char(v.level_id),
                    '10001', '',
                    '10002', app.application_short_name,
                    '10003', rsp.responsibility_key,
                    '10005', svr.node_name,
                    '10006', org.name,
                    '10004', usr.user_name,
                    '10007', 'Serv/resp',
                    'UnDef') "CONTEXT",
             nvl(v.profile_option_value, 'NULL') "VALUE"
    FROM     fnd_profile_options p,
             fnd_profile_option_values v,
             fnd_profile_options_tl n,
             fnd_user usr,
             fnd_application app,
             fnd_responsibility rsp,
             fnd_nodes svr,
             hr_operating_units org
    WHERE    p.profile_option_id = v.profile_option_id (+)
    AND      p.profile_option_name = n.profile_option_name
    AND      n.LANGUAGE = 'US'
    AND      (p.profile_option_name = 'IRC_XSS_FILTER' and (v.profile_option_value is NULL or  v.profile_option_value <> 'E') )
    AND      usr.user_id (+) = v.level_value
    AND      rsp.application_id (+) = v.level_value_application_id
    AND      rsp.responsibility_id (+) = v.level_value
    AND      app.application_id (+) = v.level_value
    AND      svr.node_id (+) = v.level_value
    AND      org.organization_id (+) = v.level_value
    ORDER BY p.profile_option_name,
             "LEVEL";

irec_prof_cur_out irec_prof_cur%ROWTYPE;
begin
	p_status := STATUS_PASSED;
	p_message := '';
	p_details := '';

	open irec_prof_cur;
	loop
		fetch irec_prof_cur into irec_prof_cur_out;
		exit when irec_prof_cur%NOTFOUND;

		if(p_status = STATUS_PASSED) then
			p_status := STATUS_FAILED;
		end if;

		if(irec_prof_cur_out.LEVEL='Site') then
			p_details := p_details || 'Profile Option '||irec_prof_cur_out.DISPLAY_NAME||'['||irec_prof_cur_out.INTERNAL_NAME;
			if(irec_prof_cur_out.VALUE='NULL') then
				p_details := p_details ||'] is NOT SET at level:'||irec_prof_cur_out.LEVEL;
			else
				p_details := p_details ||'] set to value:'||irec_prof_cur_out.VALUE||' at level:'||irec_prof_cur_out.LEVEL;
			end if;
		else
			p_details := p_details || 'Profile Option '||irec_prof_cur_out.DISPLAY_NAME||'['||irec_prof_cur_out.INTERNAL_NAME;
			if(irec_prof_cur_out.VALUE='NULL' AND irec_prof_cur_out.LEVEL='UnDef') then
				p_details := p_details ||'] is NOT SET at any level.';
			else
				p_details := p_details ||'] set to value:'||irec_prof_cur_out.VALUE||' at level:'||irec_prof_cur_out.LEVEL;
				p_details := p_details || ' for context: '||irec_prof_cur_out.CONTEXT;
			end if;
		end if;
		p_details := p_details || NEWLINE;
	end loop;
	close irec_prof_cur;

	if (p_status = STATUS_PASSED) then
			p_message := fnd_message.get_string('FND', 'SEC_CONFIG_IREC_FILE_PASS');
			p_details := p_message;
		else
			p_message := fnd_message.get_string('FND', 'SEC_CONFIG_IREC_FILE_FAIL');
			p_details := p_details;
	end if;

exception
	when others then
		p_status := STATUS_ERROR;
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_UNEXP_ERR');
		p_details := SQLERRM;

end check_IREC_FILE_UPLOAD;


PROCEDURE fix_IREC_FILE_UPLOAD (P_STATUS OUT NOCOPY VARCHAR2,
                                   P_MESSAGE OUT NOCOPY VARCHAR2,
                                   p_details OUT NOCOPY CLOB) IS
L_SAVE_STATUS BOOLEAN;
l_details_check CLOB;
l_details_fix CLOB;
BEGIN

  -- As per IRC_XSS_FILTER profile definition, value can be set only at SITE level
  L_SAVE_STATUS := FND_PROFILE.SAVE('IRC_XSS_FILTER','E','SITE');

  P_DETAILS := P_DETAILS || NEWLINE || 'Set profile IRC_XSS_FILTER at SITE Level to E [Save status:'||BOOL_TO_CHAR(L_SAVE_STATUS)||']';
  commit;

  check_IREC_FILE_UPLOAD(P_STATUS, P_MESSAGE, L_DETAILS_CHECK);

END fix_IREC_FILE_UPLOAD;


--fnd_attch_file_prof: Attachments Configuration
procedure check_FND_ATTCH_FILE_PROF( P_STATUS OUT NOCOPY VARCHAR2,
                                     P_MESSAGE OUT NOCOPY VARCHAR2,
                                     P_DETAILS OUT NOCOPY CLOB)
is
	cursor attch_prof_cur is
		SELECT   p.profile_option_name "INTERNAL_NAME",
			 n.user_profile_option_name "DISPLAY_NAME",
             decode(v.level_id,
                    10001, 'Site',
                    10002, 'Application',
                    10003, 'Responsibility',
                    10004, 'User',
                    10005, 'Server',
                    10007, 'SERVRESP',
                    'UnDef') "LEVEL",
             decode(to_char(v.level_id),
                    '10001', '',
                    '10002', app.application_short_name,
                    '10003', rsp.responsibility_key,
                    '10005', svr.node_name,
                    '10006', org.name,
                    '10004', usr.user_name,
                    '10007', 'Serv/resp',
                    'UnDef') "CONTEXT",
             v.profile_option_value "VALUE"
    FROM     fnd_profile_options p,
             fnd_profile_option_values v,
             fnd_profile_options_tl n,
             fnd_user usr,
             fnd_application app,
             fnd_responsibility rsp,
             fnd_nodes svr,
             hr_operating_units org
    WHERE    p.profile_option_id = v.profile_option_id (+)
    AND      p.profile_option_name = n.profile_option_name
    AND      n.LANGUAGE = 'US'
    AND      ((p.profile_option_name = 'FND_SECURITY_FILETYPE_RESTRICT_DFLT' and (v.profile_option_value is null or v.profile_option_value not in ('N','Y')))  -- Blacklist behavior (Y) is default and should be on
					or (p.profile_option_name = 'UPLOAD_FILE_SIZE_LIMIT' and v.profile_option_value is null)) -- Upload file size limit should be set to a non-null value
    AND      usr.user_id (+) = v.level_value
    AND      rsp.application_id (+) = v.level_value_application_id
    AND      rsp.responsibility_id (+) = v.level_value
    AND      app.application_id (+) = v.level_value
    AND      svr.node_id (+) = v.level_value
    AND      org.organization_id (+) = v.level_value
    ORDER BY p.profile_option_name,
             "LEVEL";

	attch_prof_cur_out attch_prof_cur%ROWTYPE;
begin
	p_status := STATUS_PASSED;
	p_message := '';
	p_details := '';

	-- Bug 25887743 : First check if FND_MISS_ATT_PROF passes
	-- FND_MISS_ATT_PROF would assert the existence of
	-- profile UPLOAD_FILE_SIZE_LIMIT and set appropriate message/detail
	check_FND_MISS_ATT_PROF(p_status, p_message, p_details);
	if(p_status = STATUS_FAILED) then
		return;
	end if;

	open attch_prof_cur;
	loop
		fetch attch_prof_cur into  attch_prof_cur_out;
		exit when attch_prof_cur%NOTFOUND;

		if(p_status = STATUS_PASSED) then
			p_status := STATUS_FAILED;
		end if;

		if(attch_prof_cur_out.LEVEL='Site') then
			p_details := p_details || 'Profile Option '||attch_prof_cur_out.DISPLAY_NAME||'['||attch_prof_cur_out.INTERNAL_NAME;
			if(attch_prof_cur_out.VALUE is null) then
				p_details := p_details ||'] is NOT SET at ';
				if(attch_prof_cur_out.LEVEL = 'UnDef') then
					p_details := p_details || 'any level.';
				else
					p_details := p_details || 'level:'||attch_prof_cur_out.LEVEL;
				end if;
			else
				p_details := p_details ||'] set to value:'||attch_prof_cur_out.VALUE||' at level:'||attch_prof_cur_out.LEVEL;
			end if;
		else
			p_details := p_details || 'Profile Option '||attch_prof_cur_out.DISPLAY_NAME||'['||attch_prof_cur_out.INTERNAL_NAME;
			if(attch_prof_cur_out.VALUE is null) then
				p_details := p_details ||'] is NOT SET at level:'||attch_prof_cur_out.LEVEL;
			else
				p_details := p_details ||'] set to value:'||attch_prof_cur_out.VALUE||' at level:'||attch_prof_cur_out.LEVEL;
				p_details := p_details || ' for context: '||attch_prof_cur_out.CONTEXT;
			end if;
		end if;
		p_details := p_details || NEWLINE;
	  end loop;
	 close attch_prof_cur;

	  if p_status = STATUS_PASSED then
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_ATTCH_FILE_PASS');
		p_details := p_message;
	  else
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_ATTCH_FILE_FAIL');
		p_details := p_details;
	  end if;
exception
	when others then
		p_status := STATUS_ERROR;
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_UNEXP_ERR');
		p_details := SQLERRM;

end check_FND_ATTCH_FILE_PROF;

-- check into the secure config console to see if the Database Network Access Control Lists (ACL) is enabled or not.
procedure check_db_network_acl( P_STATUS OUT NOCOPY VARCHAR2,
                                     P_MESSAGE OUT NOCOPY VARCHAR2,
                                     P_DETAILS OUT NOCOPY CLOB)
IS
    CURSOR dba_priv_cursor
    IS
        select GRANTEE,GRANTED_ROLE
        from DBA_ROLE_PRIVS
        where GRANTED_ROLE='XDBADMIN' and GRANTEE='APPS';

dba_priv_cursor_out dba_priv_cursor%ROWTYPE;
begin
    p_status := STATUS_PASSED;
    open dba_priv_cursor;
	loop
		fetch dba_priv_cursor into dba_priv_cursor_out;
		exit when dba_priv_cursor%NOTFOUND;
        p_status := STATUS_FAILED;
    end loop;
	close dba_priv_cursor;

    if(p_status = STATUS_PASSED) then
        P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_ACL_PASS');
        P_DETAILS := 'Passed.' || P_MESSAGE;
    else
        P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_ACL_FAIL');
        P_DETAILS := 'Failed.' || P_MESSAGE;
    end if;
exception
	when others then
		p_status := STATUS_ERROR;
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_UNEXP_ERR');
		p_details := SQLERRM;

end check_db_network_acl;

-- check into the secure config console to see if FND Download Autorisation is turned on or not
procedure check_FNDGFM_authorization( P_STATUS OUT NOCOPY VARCHAR2,
                                     P_MESSAGE OUT NOCOPY VARCHAR2,
                                     P_DETAILS OUT NOCOPY CLOB)
IS
val varchar(1);
begin
    val := fnd_preference.get('#INTERNAL','FNDGFM','FILE_DOWNLOAD_AUTH');
    if val = 'Y' then
        P_STATUS := STATUS_PASSED;
        P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_GFM_AUTH_PASS');
    elsif val is not null then
        P_STATUS := STATUS_FAILED;
        P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_GFM_AUTH_FAIL');
    else
        P_STATUS := STATUS_PASSED;
        P_MESSAGE := fnd_message.get_string('FND', 'SEC_CONFIG_GFM_AUTH_PASS');
    end if;
end check_FNDGFM_authorization;

-- check into the secure config console to see if any unused resources for 400 days or more.
procedure check_unused_resources( P_STATUS OUT NOCOPY VARCHAR2,
                                     P_MESSAGE OUT NOCOPY VARCHAR2,
                                     P_DETAILS OUT NOCOPY CLOB)
IS
    CURSOR unused_resource_cursor
    IS
         WITH
            FND_WEB_COMPILED_RES_AUDIT AS
            (
                SELECT fwra.resource_name RESOURCE_NAME,
                        fwra.access_count ACCESS_COUNT,
                        fwra.first_accessed_date FIRST_ACCESSED_DATE,
                        fwra.last_accessed_date LAST_ACCESSED_DATE
                FROM fnd_web_resource_audit fwra
                UNION
                SELECT fwr.resource_name RESOURCE_NAME,
                        sum(fwra.access_count) ACCESS_COUNT,
                        min(fwra.FIRST_ACCESSED_DATE) FIRST_ACCESSED_DATE,
                        max(fwra.LAST_ACCESSED_DATE) LAST_ACCESSED_DATE
                FROM fnd_web_resource_audit fwra, fnd_web_resource fwr
                WHERE fwr.resource_type= 'SERVLET'
                AND fwra.resource_name like '%' || substr(fwr.resource_name, instr(fwr.resource_name,'/',-1))||'/%'
                GROUP BY fwr.resource_name
            )
            select 'N' as Selection, fwarv.resource_name,
                    LAST_ACCESSED_DATE,
                    (select MEANING from fnd_lookup_values
                     where LOOKUP_TYPE = 'FND_AR_RES_TYPE'
                     AND LOOKUP_CODE = fwarv.resource_type
                     AND LANGUAGE = userenv('LANG')) resource_type,
                    (select CREATION_DATE from fnd_web_resource
                     where RESOURCE_NAME = fwarv.resource_name
                     AND RESOURCE_TYPE = fwarv.resource_type ) creation_date,
                    fwarv.resource_type resource_type_code,
                    (Select nvl(fav.application_name, fwr.application_short_name)
                     from fnd_web_resource fwr, FND_APPLICATION_VL fav
                     Where fwr.resource_name = fwarv.resource_name
                     and fwr.resource_type = fwarv.resource_type
                     and fwr.application_short_name = fav.application_short_name(+)) product_name
            from fnd_web_allowed_resource_v fwarv, FND_WEB_COMPILED_RES_AUDIT fwcra
            where fwarv.resource_type <> 'EXTENSION'
            and fwarv.resource_name = fwcra.resource_name(+)
            and (sysdate - nvl(LAST_ACCESSED_DATE,(select LAST_UPDATE_DATE from fnd_web_resource
                    where RESOURCE_NAME = fwarv.resource_name
                    AND RESOURCE_TYPE = fwarv.resource_type )) > 400 ) order by fwarv.resource_name;

unused_resource_cursor_out unused_resource_cursor%ROWTYPE;
begin
    p_status := STATUS_PASSED;
    open unused_resource_cursor;
	loop
		fetch unused_resource_cursor into unused_resource_cursor_out;
		exit when unused_resource_cursor%NOTFOUND;
        p_status := STATUS_FAILED;
    end loop;
	close unused_resource_cursor;

    if(p_status = STATUS_PASSED) then
        P_MESSAGE := fnd_message.get_string('FND', 'SEC_UNUSED_RESOURCE_PASS');
        P_DETAILS := 'Passed.' || P_MESSAGE;
    else
        P_MESSAGE := fnd_message.get_string('FND', 'SEC_UNUSED_RESOURCE_FAIL');
        P_DETAILS := 'Failed.' || P_MESSAGE;
    end if;
exception
	when others then
		p_status := STATUS_ERROR;
		p_message := fnd_message.get_string('FND', 'SEC_CONFIG_UNEXP_ERR');
		p_details := SQLERRM;

end check_unused_resources;

END FND_GUIDELINES;

/
