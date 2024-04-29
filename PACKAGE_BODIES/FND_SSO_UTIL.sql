--------------------------------------------------------
--  DDL for Package Body FND_SSO_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SSO_UTIL" AS
  /* $Header: AFSCOSTB.pls 120.0.12010000.8 2018/04/13 17:50:15 ctilley noship $ */
  -- Start of Package Globals
  G_MODULE_SOURCE CONSTANT VARCHAR2(80) := 'fnd.plsql.oid.fnd_sso_util.';


 /*  Public procedure to enable LDAP integration.  This does not register the instance.
 *   The procedure sets the new preference to indicate that the LDAP  integration is
 *   enabled.  When disabled provisioning will not occur.
 */
procedure enableLDAPIntegration is
 l_module_source varchar2(256);

 begin
  l_module_source := G_MODULE_SOURCE || 'enableLDAPIntegration';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  fnd_vault.put('FND','APPS_SSO_LDAP_INTEGRATION',FND_SSO_UTIL.G_ENABLED);

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  exception when others then
    IF(fnd_log.level_error >= fnd_log.g_current_runtime_level)
    THEN
         fnd_log.string(fnd_log.level_error, l_module_source, sqlerrm);
    END IF;

    raise;

end enableLDAPIntegration;


/*  Public procedure to disable LDAP integration.
 *  This does not deregister the instance.
 *  This sets the new preference to indicate the LDAP integration is disabled.
 *  This will disable LDAP provisioning.
 */
procedure disableLDAPIntegration is
 l_module_source varchar2(256);

 begin
  l_module_source := G_MODULE_SOURCE || 'disableLDAPIntegration';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  fnd_vault.put('FND','APPS_SSO_LDAP_INTEGRATION',FND_SSO_UTIL.G_DISABLED);

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  exception when others then
    IF(fnd_log.level_error >= fnd_log.g_current_runtime_level)
    THEN
         fnd_log.string(fnd_log.level_error, l_module_source, sqlerrm);
    END IF;

    raise;
end disableLDAPIntegration;

/*  Public procedure to delete current LDAP integration setting.
 *  This does not deregister the instance.
 */
procedure deleteLDAPIntegration is
 l_module_source varchar2(256);

 begin
  l_module_source := G_MODULE_SOURCE || 'deleteLDAPIntegration';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  fnd_vault.del('FND','APPS_SSO_LDAP_INTEGRATION');

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  exception when others then
    IF(fnd_log.level_error >= fnd_log.g_current_runtime_level)
    THEN
         fnd_log.string(fnd_log.level_error, l_module_source, sqlerrm);
    END IF;

    raise;

end deleteLDAPIntegration;


/*  Public procedure to set a user or group of user's password to be externally
 * managed.  This API will only update linked users.
 *
 * Linked users designated as Local will not be changed by default.
 *
 * p_user_name_patt IN parameter designating the user_name or pattern of users
 * to update.  Example:  '%mail.com'
 *
 * p_upd_local_user IN parameter to force the change of LOCAL linked users
 *
 */
procedure setPasswordExternal(p_user_name_patt in varchar2, p_upd_local_user in varchar2) is
l_module_source varchar2(256);
l_user_id fnd_user.user_id%type;
l_user_name fnd_user.user_name%type;
l_user_guid fnd_user.user_guid%type;
l_result pls_integer;
l_local_login varchar2(10);
l_profile_defined boolean;

cursor ebiz_linked_users is
    select user_name, user_id, user_guid
    from fnd_user
    where user_name like upper(p_user_name_patt)
    and user_id > 100
    and user_guid is not null
    and (ENCRYPTED_USER_PASSWORD <> 'EXTERNAL'
         OR ENCRYPTED_FOUNDATION_PASSWORD <> 'EXTERNAL') ;

begin

  l_module_source := G_MODULE_SOURCE||'setPasswordExternal';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  if (p_user_name_patt is not null) then

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User name was passed - get linked users');
       end if;

      open ebiz_linked_users;

   LOOP

      fetch ebiz_linked_users into l_user_name, l_user_id, l_user_guid;
      exit when ebiz_linked_users%NOTFOUND;

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Found linked user: '||l_user_name);
      end if;

       fnd_profile.get_specific(
                name_z  => 'APPS_SSO_LOCAL_LOGIN',
                user_id_z => l_user_id,
                val_z  => l_local_login,
                defined_z => l_profile_defined);

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Got local login profile for this user: '||l_local_login);
      end if;


     if (l_local_login <> 'LOCAL' or (l_local_login = 'LOCAL' and p_upd_local_user = 'Y')) then

       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User password is being set to externally managed');
      end if;

       update fnd_user
       set ENCRYPTED_USER_PASSWORD  = 'EXTERNAL',
           ENCRYPTED_FOUNDATION_PASSWORD = 'EXTERNAL'
       where user_name = l_user_name and user_guid = l_user_guid;
    else
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User is local so not setting to externally managed password.');
      end if;
    end if;

    END LOOP;
       close ebiz_linked_users;

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'All users processed...');
      end if;

 END IF;

 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
 then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
 end if;

exception when others then
     if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'Failed to update password to external');
          fnd_log.string(fnd_log.LEVEL_EXCEPTION,   l_module_source,   sqlerrm);
      end if;

end setPasswordExternal;



/*  Public procedure to set a user or group of user's APPS_SSO_LOCAL_LOGIN
 * profile to the specified value:
 *
 * p_user_name_patt IN parameter designating the user_name or pattern of users
 *                     to update.  Example:  '%mail.com'
 *
 * p_profile_value IN value to set profile APPS_SSO_LOCAL_LOGIN
 *                    SSO - Access given through SSO login only
 *                    Both - Access given trhough both Local and SSO login
 *                    Local - Access only given through Local login; password must exist unless linked
 *                    *NULL* - Removes the current value
 */
procedure setUserLocalLoginProfile(p_user_name_patt in varchar2, p_profile_value in varchar2) is

l_module_source varchar2(256);
l_user_id fnd_user.user_id%type;
l_user_name fnd_user.user_name%type;
l_user_guid fnd_user.user_guid%type;
l_local_login varchar2(10);
l_profile_defined boolean;
l_result pls_integer;

l_prof_set boolean;

cursor ebiz_users is
    select user_name, user_id, user_guid
    from fnd_user
    where user_name like upper(p_user_name_patt)
    and user_id > 100;

begin

  l_module_source := G_MODULE_SOURCE||'setUserLocalLoginProfile';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  -- Verify profile value is valid
  if (upper(p_profile_value) in ('SSO','LOCAL','BOTH','*NULL*')) then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Profile value is valid');
       end if;
  else
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Profile value is invalid');
       end if;

  end if;

  if (p_user_name_patt is not null) then

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Setting users: '||p_user_name_patt||' to have APPS_SSO_LOCAL_LOGIN: '||p_profile_value);
      end if;

      open ebiz_users;

   LOOP

      fetch ebiz_users into l_user_name, l_user_id, l_user_guid;
      exit when ebiz_users%NOTFOUND;

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Found user: '||l_user_name);
      end if;

      if (upper(p_profile_value) = 'SSO' and l_user_guid is null) then
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
           then
             fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User: '||l_user_name||' is not linked.  Do not set to SSO');
          end if;
          continue;
      end if;

       fnd_profile.get_specific(
                name_z  => 'APPS_SSO_LOCAL_LOGIN',
                user_id_z => l_user_id,
                val_z  => l_local_login,
                defined_z => l_profile_defined);

        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Current local login profile '||l_local_login);
        end if;

    -- Possible security issue to change an existing LOCAL user to anything else.  Only updating non-Local for now
     if (l_local_login <> 'LOCAL') then

        if (upper(p_profile_value) in ('SSO', 'BOTH', 'LOCAL')) then
            l_prof_set := fnd_profile.save(x_name => 'APPS_SSO_LOCAL_LOGIN',
                                           x_value => p_profile_value,
                                           x_level_name => 'USER',
                                           x_level_value => l_user_id);

           if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
           then
               fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Set APPS_SSO_LOCAL_LOGIN user level profile to '||p_profile_value);
           end if;
        elsif (upper(p_profile_value) = '*NULL*') then
            l_prof_set := fnd_profile.delete(x_name => 'APPS_SSO_LOCAL_LOGIN',
                                             x_level_name => 'USER',
                                             x_level_value => l_user_id);

            if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
               fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Removed user level APPS_SSO_LOCAL_LOGIN profile');
            end if;

        end if;
     else
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
               fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User is local - do nothing');
        end if;
     end if;

    END LOOP;
       close ebiz_users;

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Done processing users');
      end if;
      commit;
 END IF;

 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
 then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
 end if;

exception when others then
     if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'Failed to set user profile');
      end if;

end setUserLocalLoginProfile;

/*  Public procedure to set a user or group of user's APPS_SSO_LDAP_SYNC
 * profile to the specified value:
 *
 * p_user_name_patt IN parameter designating the user_name or pattern of users
 *                     to update.  Example:  '%mail.com'
 *
 * p_profile_value IN Value to set APPS_SSO_LDAP_SYNC at User level
 *
 * p_profile_value IN  'Y' - Enabled
 *                     'N' - Disabled
 *                     '*NULL*' - Other levels will take affect
 */
procedure setUserLDAPSyncProfile(p_user_name_patt in varchar2, p_profile_value in varchar2) is

l_module_source varchar2(256);
l_user_id fnd_user.user_id%type;
l_user_name fnd_user.user_name%type;
l_user_guid fnd_user.user_guid%type;
l_local_login varchar2(10);
l_profile_defined boolean;
l_result pls_integer;

l_prof_set boolean;

cursor ebiz_users is
    select user_name, user_id, user_guid
    from fnd_user
    where user_name like upper(p_user_name_patt)
    and user_id > 100;

begin

  l_module_source := G_MODULE_SOURCE||'setUserLDAPSyncProfile';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  -- Verify profile value is valid
  if (upper(p_profile_value) in ('Y','N','*NULL*')) then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Profile value is valid');
       end if;
  else
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Profile value is invalid');
       end if;

  end if;

  if (p_user_name_patt is not null) then

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Setting users: '||p_user_name_patt||' to have APPS_SSO_LDAP_SYNC: '||p_profile_value);
       end if;

      open ebiz_users;

   LOOP

      fetch ebiz_users into l_user_name, l_user_id, l_user_guid;
      exit when ebiz_users%NOTFOUND;


      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Found user:  '||l_user_name);
      end if;

      -- Do we care if we update non-linked or local user to Y?

        if (upper(p_profile_value) in ('Y', 'N')) then
            l_prof_set := fnd_profile.save(x_name => 'APPS_SSO_LDAP_SYNC',
                                           x_value => p_profile_value,
                                           x_level_name => 'USER',
                                           x_level_value => l_user_id);

           if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
           then
               fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Set APPS_SSO_LDAP_SYNC user level profile to '||p_profile_value);
           end if;

       elsif (upper(p_profile_value) = '*NULL*') then
            l_prof_set := fnd_profile.delete(x_name => 'APPS_SSO_LDAP_SYNC',
                                             x_level_name => 'USER',
                                             x_level_value => l_user_id);

            if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
               fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Removed user level APPS_SSO_LDAP_SYNC profile');
           end if;

       end if;


    END LOOP;
       close ebiz_users;

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Done processing users');
      end if;
      commit;
 END IF;

 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
 then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
 end if;

exception when others then
     if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'Failed to set user profile');
      end if;

end setUserLDAPSyncProfile;


/*  Public procedure to unlink a user or group of user's
 *
 *  p_user_name_patt - parameter designating the user_name or pattern of users
 *                     to unlink.  Example:  '%mail.com'
 *
 */
procedure unlink_user(p_user_name_patt in varchar2) is

l_module_source varchar2(256);

begin

l_module_source := G_MODULE_SOURCE||'unlink_user';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

   fnd_ldap_wrapper.unlink_ebiz_user(p_user_name_patt);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  --Bug 27818425 Remove the commit as DRT requires the ability to rollback
  --commit;
exception when others then
     if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'Failed to to unlink user');
         fnd_log.string(fnd_log.LEVEL_EXCEPTION,   l_module_source,   sqlerrm);
     end if;

end unlink_user;


/* To Do:  Add register/deregister APIs  */


--  TYPE userCursor IS REF CURSOR RETURN fnd_user%rowtype;
PROCEDURE link_batch( cuser IN userCursor )
IS
  l_module_source VARCHAR2(256):= G_MODULE_SOURCE || 'link_batch';
  l_session dbms_ldap.session;
  user_rec fnd_user%rowtype;
  p_guid raw(16)          :=NULL ;
  p_discard VARCHAR2(100) := NULL;
  p_result binary_integer := 0;
  flag pls_integer        := 0;
  possible   VARCHAR2(100);
  n          INTEGER;
  user_count INTEGER :=0;
  link_count INTEGER :=0;
BEGIN
  IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'BEGIN');
  END IF;

  l_session := fnd_ldap_util.c_get_oid_session(flag);


  LOOP

      FETCH cuser INTO user_rec;
      EXIT WHEN cuser%NOTFOUND ;

      user_count := user_count+1;

      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Processing user:'||user_rec.user_name||'userid:'||user_rec.user_id||' guid'||user_rec.user_guid);
      END IF;


      -- Process only link non linked users, non marked users and regular FND accounts
      IF (user_rec.user_guid IS NULL AND user_rec.user_id>100 ) THEN
        BEGIN
          -- same API used by autolink: it will take care of the subscription list
          FND_LDAP_USER.link_user(user_rec.user_name, p_guid,p_discard,p_result);

          IF (p_result = fnd_ldap_util.G_SUCCESS ) THEN
            -- must update FND_USER now
            UPDATE fnd_user SET user_guid = p_guid WHERE user_name = user_rec.user_name;
            link_count := link_count+1;

            IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Linked '||user_rec.user_name||':'||p_guid||' to '||FND_LDAP_UTIL.get_dn_for_guid(p_guid));
            END IF;
          ELSE
            -- falied without exception probably means couldn't find the user at OiD
            IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
              -- check again to generate complete log, just in case, but expected resutls are possible=null and n=0
              possible := FND_LDAP_USER.get_user_guid_and_count(user_rec.user_name,n);
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Not Linked '||user_rec.user_name||' actual OiD matches found:'||n||' '||possible);
            END IF;
          END IF;

        EXCEPTION
            WHEN fnd_oid_util.user_subs_data_corrupt_exp THEN
              -- the subscription contains SOME if the information, will require oidsubprotool or ldapcommands to fix
              UPDATE fnd_user
                   SET user_guid                = CORRUPTEDSUB_GUID_MARK
                   WHERE user_name              = user_rec.user_name;
              IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Not Linked '||user_rec.user_name||' corrupted/incomplete subscription. Check FND Debug logs STATEMENT for details');
              END IF;
            -- unexpected
            WHEN OTHERS THEN
              -- we don't know why this user failed, but we need to prevent the user
              -- is processed again without manually checking the causes first
              UPDATE fnd_user
                  SET user_guid  = UNKNOWN_FAILURE_GUID_MARK
                  WHERE user_name               = user_rec.user_name;

              IF (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'Error while  linking  '||user_rec.user_name||' '||
                         SQLCODE||':'||SQLERRM||' Will ignore and try to continue');
              END IF;
        END;

        IF (p_result <> FND_LDAP_WRAPPER.G_SUCCESS ) THEN
          UPDATE fnd_user
          SET user_guid                = OIDUSER_NOTFOUND_GUID_MARK
          WHERE user_name              = user_rec.user_name;
          IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'setting user_guid=OIDUSER_NOTFOUND_GUID_MARK for  '||user_rec.user_name);
          END IF;
        END IF;

        -- commit after each user may compromise performance for a single processes
        -- but will help with contention if there are many processes collaborating in the task
        COMMIT;
      ELSE
        IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Refuse the attempt to link '||user_rec.user_name);
        END IF;
      END IF;
  END LOOP;
  fnd_ldap_util.c_unbind(l_session,flag);
  IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END linked:'||link_count||' users:'||user_count);
  END IF;
EXCEPTION
WHEN OTHERS THEN
   IF (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      -- no need for datils, the exception will be raised again
      fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'Error while  linking  users');
  END IF;
  BEGIN fnd_ldap_util.c_unbind(l_session,flag); EXCEPTION WHEN OTHERS THEN NULL;END;
  raise;
END link_batch;

/*
rest_failure: reset failure guid marks.
It will commit the connection.
*/
PROCEDURE reset_failures
IS
  l_module_source VARCHAR2(256):= G_MODULE_SOURCE||'reset_failures';
BEGIN
  UPDATE fnd_user
  SET user_guid    = NULL
  WHERE user_guid IN ( OIDUSER_NOTFOUND_GUID_MARK,CORRUPTEDSUB_GUID_MARK,UNKNOWN_FAILURE_GUID_MARK);
  COMMIT;
END reset_failures;

/*
  Procedure called from DRT
  -- Unlinks EBIZ user from OID
  -- Assumes the user_guid is valid/correct
  -- Multiple linked users will be handled when unlink ocurs in fnd_ldap_user call
  -- Only removes user from the subscription list if EBS to OID operation is allowed
*/
PROCEDURE remove_pii(p_user_id in number)
IS
l_user_name fnd_user.user_name%type;
l_user_guid fnd_user.user_guid%type;
l_module_source varchar2(256) := G_MODULE_SOURCE||'remove_pii';

begin

 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
 end if;

  select user_name, user_guid into l_user_name, l_user_guid
  from fnd_user
  where user_id = p_user_id
  and user_guid is not null;



  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Linked user found - attempt to unlink');
  end if;


     unlink_user(l_user_name);

 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Done unlinking: End');
 end if;


exception
  when no_data_found then
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User is not linked - do nothing');
     end if;
  when others then
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Others exception');
     end if;

END remove_pii;


END fnd_sso_util;

/
