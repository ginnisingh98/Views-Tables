--------------------------------------------------------
--  DDL for Package Body FND_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DRT_PKG" as
/* $Header: AFSCDRTB.pls 120.0.12010000.12 2019/02/27 22:24:01 rarmaly noship $ */


/* Logging variable */
l_package varchar2(33) DEFAULT 'fnd.plsql.FND_DRT_PKG.';

----------------------------------------------------------------------------
--
-- write_stmt_log (PRIVATE)
--
-- Write entry in FND_LOG when STATEMENT logging level is enabled.
--
-- Input:
-- name_api	name of calling api
-- message 	message
--
PROCEDURE write_stmt_log(name_api IN varchar2, message IN varchar2) IS
BEGIN
    IF (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                   name_api,
                   message);
    END IF;
END write_stmt_log;

----------------------------------------------------------------------------
-- 27942514 consume foreign key interface of fnd_user_pkg.user_synch
-- as a private procedure
----------------------------------------------------------------------------
--
-- UpdateUserNameChildren (private)
--
-- Called by user_synch to cascade user_name update to
-- fnd dictionary object foreign key children
--
-- Input:
-- OLD_USER_NAME Old FND User name
-- USER_NAME	  Current FND User name to be synched
--
procedure UpdateUserNameChildren(old_name in varchar2,
                                 new_name in varchar2) is
  colnames fnd_dictionary_pkg.NameArrayTyp;
  colold fnd_dictionary_pkg.NameArrayTyp;
  colnew fnd_dictionary_pkg.NameArrayTyp;
  l_api_name  VARCHAR2(100) := l_package || 'UpdateUsernameChildren';
  tmpbuf varchar2(240);
  reason varchar2(2000);
  ret boolean;
begin
  -- need to call pk update to do cascade foreign key children update
  colnames(0) := 'USER_NAME';
  colnames(1) := '';
  colold(0) := old_name;
  colold(1) := '';
  colnew(0) := new_name;
  colnew(1) := '';

  tmpbuf := 'Start calling fnd_dictionary_pkg.updatepkcolumns('||
             old_name||','||new_name||')';
  write_stmt_log(l_api_name, tmpbuf);

  ret := fnd_dictionary_pkg.updatepkcolumns('FND', 'FND_USER', colnames, colold,
                                       colnew);
  tmpbuf := 'Finished fnd_dictionary_pkg.updatepkcolumns';
  write_stmt_log(l_api_name, tmpbuf);

exception
  when others then
    reason := fnd_message.get;
    fnd_message.set_name('FND', 'FND_FAILED_UPDATE_UNAME_CHILD');
    fnd_message.set_token('OLD_NAME', old_name);
    fnd_message.set_token('NEW_NAME', new_name);
    fnd_message.set_token('REASON', reason);
    app_exception.raise_exception;
end UpdateUserNameChildren;

----------------------------------------------------------------------------
-- 27942514 consume workflow interface of fnd_user_pkg.user_synch
-- to consolidate parameters and calls to wf_local_synch
----------------------------------------------------------------------------
--
-- user_synch (PUBLIC)
--
-- The centralized routine for communicating FND user name changes
-- with workflow and entity mgr.
--
-- Input:
-- OLD_USER_NAME Old FND User name
-- USER_NAME	  Current FND User name to be synched
--
PROCEDURE user_synch(x_old_name in varchar2,
	x_user_name in varchar2)
IS

  -- DRT 28045630 cursor to query installed languages
  cursor langs_c is
    select language_code from fnd_languages
    where installed_flag in ('B','I');

  l_api_name VARCHAR2(100) := l_package || 'user_synch';
  l_old_name FND_USER.USER_NAME%TYPE := UPPER(x_old_name);

  my_userid FND_USER.USER_ID%TYPE;
  my_email  FND_USER.EMAIL_ADDRESS%TYPE;
  my_desc   FND_USER.DESCRIPTION%TYPE;
  my_fax    FND_USER.FAX%TYPE;
  my_empid  FND_USER.EMPLOYEE_ID%TYPE;
  my_partyid FND_USER.PERSON_PARTY_ID%TYPE;
  my_exp    FND_USER.END_DATE%TYPE;
  my_start  FND_USER.START_DATE%TYPE;
  my_guid   FND_USER.USER_GUID%TYPE;
  mylist    wf_parameter_list_t;
  ch_exp    varchar2(20);
  ch_start  varchar2(20);
  --<rwunderl:3203225>
  l_defined_z BOOLEAN;
  myLang      VARCHAR2(240);
  myTerr      VARCHAR2(240);
  l_userNTFPref   VARCHAR2(8); -- bug 3280951
  l_party_type    varchar2(30);
  --</rwunderl:3203225>
  dummy     number(1);
  -- <bug 2850261 (enhancement request) >
  ptyName varchar2(360);
  --</bug 2852061>

BEGIN

  ---------------------------------------------
  -- Notations regarding older bugs are from
  -- original source: fnd_user_pkg.user_synch
  ---------------------------------------------

  -- fetch info for synch --

  write_stmt_log(l_api_name, 'Start user_synch');
  write_stmt_log(l_api_name, 'x_user_name = '||x_user_name);
  select user_id, email_address, description, fax, employee_id,
         person_party_id,
         start_date, end_date, user_guid,
         to_char(start_date, 'YYYYMMDDHH24MISS'),
         to_char(end_date, 'YYYYMMDDHH24MISS')
  into   my_userid, my_email, my_desc, my_fax, my_empid, my_partyid,
         my_start, my_exp, my_guid, ch_start, ch_exp
  from   fnd_user
  where  user_name = upper(x_user_name);

  -- construct attribute list for wf synch --
  wf_event.AddParameterToList('MAIL', my_email, mylist);
  wf_event.AddParameterToList('DESCRIPTION', my_desc, mylist);
-- remove this print line after test verification
write_stmt_log(l_api_name, 'TEST ONLY VERIFICATION wf attr DESCRIPTION: '||my_desc|| ':is null??');
  wf_event.AddParameterToList('FACSIMILETELEPHONENUMBER', my_fax, mylist);
  wf_event.AddParameterToList('USER_NAME', upper(x_user_name), mylist);
  wf_event.AddParameterToList('CN', upper(x_user_name), mylist);
  wf_event.AddParameterToList('SN', upper(x_user_name), mylist);
  wf_event.AddParameterToList('ORCLACTIVESTARTDATE', ch_start, mylist);
  if ((my_exp is null) OR
     (trunc(sysdate) between my_start and my_exp)) then
    wf_event.AddParameterToList('ORCLISENABLED', 'ACTIVE', mylist);
  else
    wf_event.AddParameterToList('ORCLISENABLED', 'INACTIVE', mylist);
  end if;
  wf_event.AddParameterToList('ORCLACTIVEENDDATE', ch_exp, mylist);
  wf_event.AddParameterToList('ORCLGUID', my_guid, mylist);
  -- bug 4318754

  wf_event.AddParameterToList('OLD_ORCLGUID', my_guid, mylist);
  -- end bug 4318754

  -- security bug 18161850 remove unused parameter

  wf_event.AddParameterToList('PER_PERSON_ID',
                  fnd_number.number_to_canonical(my_empid), mylist);
  wf_event.AddParameterToList('PERSON_PARTY_ID',
                  fnd_number.number_to_canonical(my_partyid), mylist);
  -- bug 4318754
  wf_event.AddParameterToList('OLD_PERSON_PARTY_ID',
                 fnd_number.number_to_canonical(my_partyid), mylist);
  -- end bug 4318754

  -- set up WF attributes based on removal

  -- WF process to expire/end-date the masked user
  wf_event.AddParameterToList('DISPLAYNAME', upper(x_user_name), mylist);

-----------------------------------------------------------------------
-- OLD_USER_NAME is needed for UPDATE WF_LOCAL_ROLES
-- and WF_MAINTENANCE.PropagateChangedName(OLDNAME, NEWNAME);
-- should drt skip this code?...
------------------------------------------------
  -- begin bug 2504562

  wf_event.AddParameterToList('OLD_USER_NAME', l_old_name, mylist);
-- remove this print line after test verification
write_stmt_log(l_api_name, 'TEST ONLY VERIFICATION wf attr OLD_USER_NAME: '||l_old_name|| ':should drt skip??');

  -- end bug 2504562

  -- <rwunderl:3203225>
  -- Added calls for the lang/territory and notification preference.
  fnd_profile.get_specific(name_z=>'ICX_LANGUAGE', user_id_z=>my_userid,
                           val_z=>myLang, defined_z=>l_defined_z);
  wf_event.AddParameterToList('PREFERREDLANGUAGE', myLang, mylist);

  fnd_profile.get_specific(name_z=>'ICX_TERRITORY', user_id_z=>my_userid,
                           val_z=>myTerr, defined_z=>l_defined_z);

  wf_event.AddParameterToList('ORCLNLSTERRITORY', myTerr, mylist);

  -- Notification Preference is disabled for removal
  wf_event.AddParameterToList('ORCLWORKFLOWNOTIFICATIONPREF',
                              'DISABLED',
                              mylist);

  --Bug 3277794
  --Add the over-write parameter to the attribute list
  wf_event.AddParameterToList('WFSYNCH_OVERWRITE','TRUE',mylist);

  -- </rwunderl:3203225>

  -- 27973495 - use to_date() to add EXPIRATIONDATE wf_event parameter
  -- to correct the Responsibility relationship end date
  wf_event.AddParameterToList('EXPIRATIONDATE',
                              to_date(SYSDATE - 1,'DD-MM-RRRR HH24:MI:SS'),
                              mylist);

  wf_event.AddParameterToList('RAISEERRORS', 'TRUE', mylist);

  BEGIN

    ------------------------------------------------
    -- try to keep fnd_logging similar...
    ------------------------------------------------

    write_stmt_log(l_api_name, 'Calling wf_local_synch.propagate_user');

    write_stmt_log(l_api_name, 'ORCLGUID = '|| my_guid);

    write_stmt_log(l_api_name, 'PER_PERSON_ID = '|| my_empid);

    write_stmt_log(l_api_name, 'PERSON_PARTY_ID = '|| my_partyid);

    write_stmt_log(l_api_name, 'DISPLAY_NAME(PARTY_NAME) = '|| ptyName);

    write_stmt_log(l_api_name, 'OLD_USER_NAME = '|| l_old_name);



    wf_local_synch.propagate_user(p_orig_system    => 'FND_USR',
                                  p_orig_system_id => my_userid,
                                  p_attributes     => mylist,
                                  p_start_date     => my_start,
                                  p_expiration_date => my_exp);

    write_stmt_log(l_api_name, 'Finished wf_local_synch.propagate_user');

    EXCEPTION
      WHEN OTHERS THEN
        write_stmt_log(l_api_name, '.wfprop error userid= ' || my_userid);
    END;

    BEGIN

    -- DRT 28045630 loop through installed languages
    for langs in langs_c loop

    -- Add a delay between making consecutive calls to WF propagate_user
    -- since the WF-process needs at a minimum 1 second between executions
    -- to release the same transaction from the cache,
    -- when reusing same username in consecutives calls
    dbms_lock.sleep(1);

    -- add/overwrite SOURCE_LANG parameter
    -- wf param list will still contain common attributes
    -- containing PII data and expiration
    -- then make call to WF for each lang

    write_stmt_log(l_api_name, '.Add source_lang '|| langs.language_code ||' for WF_LOCAL_ROLES_TL');
    wf_event.AddParameterToList('SOURCE_LANG', langs.language_code, mylist);

    wf_local_synch.propagate_user(p_orig_system     => 'FND_USR',
                                  p_orig_system_id  => my_userid,
                                  p_attributes      => mylist,
                                  p_start_date      => my_start,
                                  p_expiration_date => my_exp);

    end loop;
    write_stmt_log(l_api_name, 'Finished wf_local_synch.propagate_user for each lang');

    EXCEPTION
    WHEN OTHERS THEN
      write_stmt_log(l_api_name, '.wfprop lang error userid= ' || my_userid);
    END;



  -- Added for bug 3804617
  -- If a user_name is changed, we need to update all foreign key children.
  if (l_old_name is not null) then
    UpdateUsernameChildren(l_old_name, x_user_name);
  end if;
  write_stmt_log(l_api_name, 'End user_synch');
EXCEPTION
--  Bug 3617474: This NO_DATA_FOUND exception handler was placed in the event
--  that fnd_user_pkg.user_synch() was passed an invalid or null user_name,
--  i.e a user_name that does not exist in fnd_user.
    when NO_DATA_FOUND then
        null;

END user_synch;

----------------------------------------------------------------------------
-- 27942514 consume fnd_user.change_user_name()
-- clarify functionality by updating procedure name to remove_user_name
-- skip call to validate_user_name
-- include the update of fnd_user for proper nullification
----------------------------------------------------------------------------
--
-- remove_user_name (PUBLIC)
--   This api changes username, synchronizes changes with LDAP and WF
--   and updates foreign keys that were using the old username.
--
-- Input:
-- OLD_USER_NAME Old FND User name
-- NEW_USER_NAME New FND User name
--
procedure remove_user_name(x_old_user_name            in varchar2,
                           x_new_user_name            in varchar2) is
  newpass varchar2(100);
  dummy number(1);
  ret boolean;
  l_user_id   FND_USER.USER_ID%TYPE;
  l_api_name  VARCHAR2(100) := l_package || 'remove_user_name';
  tmpbuf varchar2(240);
  reason varchar2(240);
  encpwd varchar2(100);
  l_parameter_list wf_parameter_list_t;  -- bug 8227171 WF event parameter list

begin
  -- 7311525 do not allow the username of GUEST to be changed
  if (upper(x_old_user_name) = 'GUEST') then
     fnd_message.set_name('FND', 'SECURITY-GUEST USERNAME');
     app_exception.raise_exception;
  end if;


  begin
    -- 27942514 for DRT,
    --   No need to check if new user_name already exists
    --   Will skip new user_name validation
    --   No need to check x_change_source as done in fnd_user_pkg

    -- Start bug 4625235
    -- Move ldap_wrapper synch call to here before we do FND user update
    begin
      tmpbuf := 'Calling ldap_wrapper_change_user_name to change '||
                 x_old_user_name|| ' to '|| x_new_user_name;
      write_stmt_log(l_api_name, tmpbuf);

      -- 27942514 DRT pkg will call PUBLIC version without guid parameter guid
      fnd_user_pkg.ldap_wrapper_change_user_name(upper(x_old_user_name), upper(x_new_user_name));

    exception
      when others then
        app_exception.raise_exception;
      end;
    -- end bug 4625235

    -- 27942514 DRT pkg
    --No need to capture old_user_name in package variable g_old_user_name
    -- when removing user
    -- get user id for fnd_user update
    -- and later Function Security Cache Invalidation
    select user_id
    into l_user_id
    from fnd_user
    where user_name = upper(x_old_user_name);

    tmpbuf := 'updating fnd_user for new user_name '||x_new_user_name;
    write_stmt_log(l_api_name, tmpbuf);


    -- update FND_USER to be end-dated and NULLIFIED
    UPDATE fnd_user
       SET LAST_UPDATE_DATE              = to_date(SYSDATE,
                                                  'DD-MM-RRRR HH24:MI:SS'),
           LAST_UPDATED_BY               = l_user_id,
           USER_NAME                     = upper(x_new_user_name),

           -- bug 27893019 created_by and creation_date should remain unchanged
           -- CREATION_DATE                 = to_date(SYSDATE,
           --                                        'DD-MM-RRRR HH24:MI:SS'),
           -- CREATED_BY                    = l_user_id,
           LAST_UPDATE_LOGIN             = NULL,
           ENCRYPTED_FOUNDATION_PASSWORD = 'INVALID',
           ENCRYPTED_USER_PASSWORD       = 'INVALID',
           SESSION_NUMBER                = 0,
           START_DATE                    = to_date(SYSDATE - 1,
                                                   'DD-MM-RRRR HH24:MI:SS'),
           END_DATE                      = to_date(SYSDATE,
                                                   'DD-MM-RRRR HH24:MI:SS'),
           DESCRIPTION                   = NULL,
           LAST_LOGON_DATE               = NULL,
           PASSWORD_DATE                 = NULL,
           PASSWORD_ACCESSES_LEFT        = NULL,
           PASSWORD_LIFESPAN_ACCESSES    = NULL,
           PASSWORD_LIFESPAN_DAYS        = NULL,
           EMAIL_ADDRESS                 = 'first.last@example.invalid',
           FAX                           = NULL,
           WEB_PASSWORD                  = NULL,

           GCN_CODE_COMBINATION_ID       = NULL

           -- bug 27959153 maintain foreign keys
           -- to HR person and TCA parties in columns:
           -- EMPLOYEE_ID
           -- PERSON_PARTY_ID, CUSTOMER_ID, SUPPLIER_ID
       WHERE USER_ID = l_user_id;

    tmpbuf := 'updating fnd_user to be end-dated and NULLIFIED ';
    write_stmt_log(l_api_name, tmpbuf);

    -- 27942514 DRT pkg, no need to encrypt new password

    -- Function Security Cache Invalidation
    fnd_function_security_cache.update_user(l_user_id);

    -- propagate username change to WF and entity mgr
    tmpbuf := 'Start calling user_synch('||x_new_user_name||')';
    write_stmt_log(l_api_name, tmpbuf);

    begin
      user_synch(x_old_user_name, upper(x_new_user_name));

    exception
      when others then
        reason := fnd_message.get;
        fnd_message.set_name('FND', 'FND_FAILED_WF_USER_SYNCH');
        fnd_message.set_token('OLD_NAME', x_old_user_name);
        fnd_message.set_token('NEW_NAME', x_new_user_name);
        fnd_message.set_token('REASON', reason);
        app_exception.raise_exception;
    end;

      -- Added for bug 4676568
      -- A temp fix to update fnd_grants.grantee_key
      -- No need to check SQL%NOTFOUND because if there is no data to be
      -- updated in fnd_grants.grantee_key, that is perfectly fine.
      update fnd_grants
      set grantee_key = x_new_user_name
      where grantee_key = x_old_user_name
      and grantee_type = 'USER';

    tmpbuf := 'Finished user_synch';
    write_stmt_log(l_api_name, tmpbuf);

      -- bug 8227171 change_user_name
      -- Raise the WF event oracle.apps.fnd.post.username.change
      begin
        wf_event.AddParameterToList('OLD_USERNAME', x_old_user_name,
                                    l_parameter_list);
        wf_event.raise3(p_event_name =>'oracle.apps.fnd.post.username.change',
                  p_event_key => x_new_user_name,
                  p_event_data => NULL,
                  p_parameter_list => l_parameter_list,
                  p_send_date => Sysdate);

      exception
        when others then
          reason := fnd_message.get_encoded;
          if (reason is not null) then
            fnd_message.set_encoded(reason);
          else
            fnd_message.set_name('FND', 'FND_RAISE_EVENT_FAILED');
          end if;
          app_exception.raise_exception;
      end;
  end;

exception
  when no_data_found then
    -- old username does not exist in fnd_user
    fnd_message.set_name('FND', 'FND_CHANGE_USER_FAILED');
    fnd_message.set_token('USER_NAME', x_old_user_name);
    app_exception.raise_exception;

end remove_user_name;

----------------------------------------------------------------------------
--
-- mask_pii_user (PUBLIC)
--
-- Permanently masks or removes FND-PII (personal identifiable information)
-- of data linked to the USER_NAME in the FND_USER table and the USER_NAME
-- will become available for reuse.  The masked user name is propagated
-- to fnd dictionary objects with FND_USER.USER_NAME foreign key
-- The USER_ID will be end-dated and not be reusable,
-- and FND_GRANTS are end-dated for the FND User.
-- The OID user name linked to the EBS user will be masked.
-- Business events associated with FND user update are raised.
--
-- Input:
-- p_name		FND Username
--
-- Return codes:
-- PIISUCC CONSTANT number := 0; /* Everything completed successfully */
-- PIINOUSR CONSTANT number := -1; /* The USER didn't exist on FND_USER */
-- REMOVED PIIWFPED CONSTANT number := -2; /* The USER has pending workflow  */
-- PIIWFPROP CONSTANT number := -3; /* Error at wf_local_synch.propagate_user */
-- PIIUERR CONSTANT number := -4; /* Unexpected Error */
--
  FUNCTION mask_pii_user(x_user_name VARCHAR2) RETURN number IS

    -- 27942514 lang loop moved to user_synch

    l_api_name     VARCHAR2(100) := l_package || 'mask_pii_user';
    l_rtn          NUMBER;
    l_mask_uname   VARCHAR2(100);
    exists_flag    VARCHAR2(1) := 'N';
    p_userid       FND_USER.USER_ID%TYPE;
    p_user_guid    FND_USER.USER_GUID%TYPE;
    paramList      wf_parameter_list_t;

  BEGIN

    write_stmt_log(l_api_name, '.before_chkuser');

    BEGIN
      SELECT 'Y', u.user_id, u.user_guid
        INTO exists_flag, p_userid, p_user_guid
        FROM fnd_user u
       WHERE u.user_name = upper(x_user_name);
    EXCEPTION
      WHEN no_data_found THEN
        exists_flag := 'N';
    END;

    IF exists_flag = 'Y' THEN

      -- Bug 27929693 - For DRT flows, skip check_wfnt and
      -- let wf_drt_pkg.wf_fnd_drc check the workflow constraints


          -- check for OID synchronization
		write_stmt_log(l_api_name, '.before_OIDcheck');

          IF (p_user_guid is not null) THEN
		  -- let SSO unlink the user, clean up related data, nullify the guid
		  -- and determine action for propagation to OID
		  fnd_sso_util.remove_pii(p_userid);

          END IF;

          -- end date grants associated with FND user
		write_stmt_log(l_api_name, '.before_enddate_grants_user');

          -- Process to End-date FND_GRANTS by user
          UPDATE fnd_grants gu
             SET gu.end_date = to_date(SYSDATE, 'DD-MM-RRRR HH24:MI:SS')
           WHERE EXISTS
           (SELECT 1
                    FROM fnd_user u, fnd_grants g
                   WHERE u.user_id = P_USERID
                     AND g.grantee_type = 'USER'
                     AND EXISTS (SELECT 1
                            FROM wf_user_roles wur
                           WHERE wur.user_name = u.user_name
                             AND wur.role_name = g.grantee_key)
                     AND g.rowid = gu.rowid);

          -- Generate UNIQUE NEW user_name to be use for masking
          -- bug 27959153 maintain some consistency with masked HR person/TCA party names
          l_mask_uname := 'R-' || dbms_random.string ('a',length (trim (x_user_name)));

          -- write_stmt_log(l_api_name, '.before_UMX_remove_pii');

          -- bug 27992173 Remove UMX PII data from WF tables
          -- umx_pub.remove_pii(p_userid, x_user_name, l_mask_uname);

          write_stmt_log(l_api_name, '.before_nullified');

    -- 27942514 move nullification of fnd_user into remove_user_name


          -- propagate masked username and PII changes as username change that will
          -- raise business events associated with FND user update and
          -- propagate masked user name to fnd dictionary objects using as foreign key
          write_stmt_log(l_api_name, '.before_remove_user_name');

          -- Bug 27942514 - consume fnd_user_pkg.change_user_name
		-- to skip the call to validate_user_name and
          -- consolidate calls/parameter to wf_local_synch inside user_synch
          -- clarify functionality by calling procedure remove_user_name
          remove_user_name(x_user_name, l_mask_uname);


          -- Bug 27942514 lang loop moved to user_synch




          -- EXIT with SUCCESS = 0
          l_rtn := PIISUCC;

    ELSE
      -- ERROR The USER is not found on FND_USER = -1
      l_rtn := PIINOUSR;

    END IF; -- end check for exist_flag

    RETURN l_rtn;

  EXCEPTION
    WHEN OTHERS THEN
      /*
      ||  ERROR HANDLING
      */

      -- write the error into the FND_LOG
      write_stmt_log(l_api_name, '.report_error userid= ' || p_userid ||
                       ' Err-code:[' || SQLCODE || ' ] - ' ||
                       ' Err-msg:[ ' || SQLERRM || ' ]');

      -- write the error into the PLSQL-error stack
      fnd_message.set_name('FND', 'SQL-GENERIC ERROR');
      fnd_message.set_token('ERRNO', SQLCODE, FALSE);
      fnd_message.set_token('ROUTINE', 'mask_pii_user', FALSE);
      fnd_message.set_token('REASON', SQLERRM, FALSE);
      fnd_message.set_token('ERRFILE', 'AFSCDRTB.pls', FALSE);
      app_exception.raise_exception;

      -- return Unknown Error = -4
      RETURN PIIUERR;

  END mask_pii_user;

----------------------------------------------------------------------------
--
-- fnd_user_drc (PUBLIC)
--
-- Data Removal Constraint API for person type : FND User
-- Determines impact of deleting a record associated with an FND User
--
-- Input:
-- USER_ID	ID for FND User to be removed
--
-- Output:
-- RESULT_TBL	Output result table on return from the procedure
--
PROCEDURE fnd_user_drc(
	p_user_id IN NUMBER,
	result_tbl OUT nocopy per_drt_pkg.result_tbl_type )
IS
    l_proc varchar2(72) := l_package || 'fnd_user_drc';
    l_user_id FND_USER.USER_ID%TYPE;

BEGIN

    per_drt_pkg.write_log ('Entering Stub:'|| l_proc,'10');
    l_user_id := p_user_id;
    per_drt_pkg.write_log ('user_id: '|| to_char(l_user_id),'20');


	per_drt_pkg.write_log ('Leaving Stub:'|| l_proc,'999');

END fnd_user_drc;

----------------------------------------------------------------------------
--
-- fnd_user_post (PUBLIC)
--
-- Data Removal Post Processing API for person type : FND User
-- Permanently removes FND-PII (personal identifiable information)
-- of historic data linked to the USER_NAME in the FND_USER table
-- and the USER_NAME will become available for reuse.
-- The USER_ID will be end-dated and not be reusable,
-- and FND_GRANTS are end-dated for the FND User.
--
-- Input:
-- USER_ID	ID for FND User to be removed
--
-- Caution
--   Although this is public procedure, it is not intended for public usage
--   outside of the DRT architecture. This procedure will remove the requested
--   FND user and should only be called following thorough checking of
--   removal contraints, as provided by the DRT engine.
--
PROCEDURE fnd_user_post(
	p_user_id IN NUMBER)
IS
    l_proc varchar2(72) := l_package || 'fnd_user_post';

    l_user_name FND_USER.USER_NAME%TYPE;
    l_retcode number;

	cursor usercur is
	select user_name
	from fnd_user
	where user_id = p_user_id;

BEGIN

    per_drt_pkg.write_log (l_proc, ' Enter user_id: '|| to_char(p_user_id));

	open usercur;
	fetch usercur into l_user_name;
	close usercur;

	-- mask PII data for the target user
	l_retcode := mask_pii_user( l_user_name );

	per_drt_pkg.write_log (l_proc,' mask_pii return code: '|| to_char(l_retcode));

	per_drt_pkg.write_log (l_proc,' Leave user_id: '|| to_char(p_user_id));

END fnd_user_post;

end FND_DRT_PKG;

/
