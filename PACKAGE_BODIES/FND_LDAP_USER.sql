--------------------------------------------------------
--  DDL for Package Body FND_LDAP_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LDAP_USER" as
/* $Header: AFSCOLUB.pls 120.43.12010000.19 2010/02/26 19:01:34 stadepal ship $ */
--
-------------------------------------------------------------------------------
-- Start of Package Globals

  G_CREATE             constant  pls_integer := 1;
  G_UPDATE             constant  pls_integer := 2;
  G_MODULE_SOURCE  constant varchar2(80) := 'fnd.plsql.oid.fnd_ldap_user.';

-- End of Package Globals
--
-------------------------------------------------------------------------------

function delete_user_nodes(p_ldap_session in dbms_ldap.session, p_orclguid in fnd_user.user_guid%type) return pls_integer;
function delete_user_subscription(p_ldap_session in dbms_ldap.session, guid raw) return pls_integer;
function delete_uniquemember(p_ldap_session in dbms_ldap.session, p_orclguid in fnd_user.user_guid%type) return pls_integer;
procedure ProcessLoadedLpadUserRecord (p_ldap_user  IN OUT nocopy fnd_ldap_user.ldap_user_type ,realmDN in varchar2 ,dn_z in varchar2 );
--function CanSync ( p_user_id in pls_integer, p_user_name in varchar2 ) return boolean;
function get_user_guid(p_ldap_session in dbms_ldap.session, p_user_name in varchar2, dn out nocopy varchar2) return raw ;
function isValueOf( u ldap_user_type, fld in varchar2, val in varchar2 ) return boolean;
function get_user_guid( p_user_name in varchar2) return raw ;
function CanUpdate( attr in varchar2 , user_name in varchar2 , realm in varchar2,x_user_creation in boolean default FALSE) return boolean;
function CanPopulate( attr in varchar2 , user_name in varchar2 , realm in varchar2) return boolean;
-- Bug 9271995 : internal signature
procedure update_user(p_user_guid in raw,
                     p_user_name in varchar2,
                     p_password in varchar2 default null,
                     p_start_date in date default null,
                     p_end_date in date default null,
                     p_description in varchar2 default null,
                     p_email_address in varchar2 default null,
                     p_fax in varchar2 default null,
                     p_expire_password in pls_integer,
                     x_password out nocopy varchar2,
                     x_result out nocopy pls_integer,
		     x_user_creation in boolean default FALSE ) ;

--
-- Type to hold preferences
TYPE update_record IS record (
  att varchar2(200),
  op  varchar2(10),
  val varchar2(4000)
);

TYPE update_list IS table OF update_record INDEX BY pls_integer;

PROCEDURE ProcessUpdateRec(ldap in dbms_ldap.session, dn in varchar2, upd in update_list);

--
-- LOCAL EXCEPTIONS
 CANNOT_CREATE_EXCEPTION EXCEPTION;

 duplicate_dn_EXCEPTION EXCEPTION;
 duplicate_username_EXCEPTION EXCEPTION;
 link_create_failed_EXCEPTION EXCEPTION;


   cache_user_name   varchar2(200) := null;
   cache_nna         varchar2(200) := null;
   cache_default_nna varchar2(200) := null;

--
-------------------------------------------------------------------------------
--- REMOVED
-- function add_uniquemember(p_ldap_user in fnd_ldap_util.ldap_user_type) return pls_integer is
-- translate_ldap_error: Internal
-- Will attempt to translate the sqlerrms from an dbms_ldap operation into a FND message

-------------------------------------------------------------------------------
function translate_ldap_error( errm in varchar2) return varchar2
is
begin

 if (instr(errm,':9000')>0 ) then return 'FND_SSO_PASSWORD_EXPIRED'; end if;
 if (instr(errm,':9001')>0 ) then return 'FND_SSO_LOCKED'; end if;
 if (instr(errm,':9002')>0 ) then return 'FND_SSO_PASSWORD_EXPIRED'; end if;
 if (instr(errm,':9003')>0 ) then return 'FND_SSO_PASSWORD_POLICY_ERR'; end if;
 if (instr(errm,':9004')>0 ) then return 'FND_SSO_PASSWORD_POLICY_ERR'; end if;
 if (instr(errm,':9005')>0 ) then return 'FND_SSO_PASSWORD_POLICY_ERR'; end if;
 if (instr(errm,':9006')>0 ) then return 'FND_SSO_PASSWORD_POLICY_ERR'; end if;
 if (instr(errm,':9007')>0 ) then return 'FND_SSO_PASSWORD_POLICY_ERR'; end if;
 if (instr(errm,':9008')>0 ) then return 'FND_SSO_UNEXP_ERROR'; end if;
 if (instr(errm,':9009')>0 ) then return 'FND_SSO_UNEXP_ERROR'; end if;
 if (instr(errm,':9010')>0 ) then return 'FND_SSO_UNEXP_ERROR'; end if;
 if (instr(errm,':9011')>0 ) then return 'FND_SSO_CL_IP_LOCK'; end if;
 if (instr(errm,':9050')>0 ) then return 'FND_SSO_USER_DISABLED'; end if;
 if (instr(errm,':9051')>0 ) then return 'FND_SSO_LOCKED'; end if;
 if (instr(errm,':9052')>0 ) then return 'FND_SSO_USER_DISABLED'; end if;
 if (instr(errm,':9053')>0 ) then return 'FND_SSO_USER_DISABLED'; end if;
 return 'FND_SSO_UNEXP_ERROR';


end translate_ldap_error;

--
-------------------------------------------------------------------------------
PROCEDURE delete_user(ldapSession in dbms_ldap.session, p_user_guid in  fnd_user.user_guid%type ,
                     x_result out nocopy pls_integer,
                     p_forced in boolean default false) is


  l_module_source   varchar2(256) := G_MODULE_SOURCE || 'delete_user: ';
  l_orclappname       varchar2(256);
  l_user_name          varchar2(256);
  subsNode            varchar2(1000);
  --ldapSession         dbms_ldap.session;
  l_message dbms_ldap.message := null;
  l_entry dbms_ldap.message := null;
  l_attrs dbms_ldap.string_collection;
  l_attrs_vals dbms_ldap.string_collection;
  l_isenabled         varchar2(100);
  l_creatorname       varchar2(1000);
  searchNodes dbms_ldap.string_collection;
  l_filter varchar2(256);-- := 'cn=' || p_user_name; Commented out by scheruku to use orclguid instead
  l_base varchar2(1000);
  l_guid raw(256);
  l_fnd_op pls_integer;
  l_oid_op pls_integer;
  sso_registration_failure exception;
--  l_apps_user_key_type fnd_oid_util.apps_user_key_type;
  l_orclguid fnd_user.user_guid%type;
begin

  -- initializing
  l_module_source := G_MODULE_SOURCE || 'delete_user: ';
  x_result := fnd_ldap_util.G_SUCCESS;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

--scheruku :: Added logic to get orclguid from fnd_user
-- l_apps_user_key_type := fnd_oid_util.get_fnd_user(p_user_name => p_user_name);
-- l_orclguid := l_apps_user_key_type.user_guid;
   l_orclguid :=  p_user_guid;

 if(l_orclguid IS NULL)
 then
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
             'NULL guid in FND_USER');
  end if;
    x_result := fnd_ldap_util.G_FAILURE;
 else
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
             'FND_USER GUID::'||l_orclguid);
  end if;
  l_filter := 'orclguid='||l_orclguid;
  --ldapSession := fnd_ldap_util.get_oid_session;
  --searchNodes := fnd_ldap_util.get_search_nodes;
  l_base := ''; -- don't need any more for guid search
  l_attrs(0) := 'orclisenabled';
  l_attrs(1) := 'creatorsname';
  l_attrs(2) := 'orclguid';

    -- search and delete the user only if the creator is the current apps instance and if the user is disabled.

   --for i in 0..searchNodes.count-1 loop
      --l_base := searchNodes(i);
      x_result := dbms_ldap.search_s(ld => ldapSession, base => l_base,
      scope => dbms_ldap.SCOPE_SUBTREE, filter => l_filter, attrs => l_attrs, attronly => 0, res => l_message);
      if (x_result is not NULL) then

        l_entry := dbms_ldap.first_entry(ldapSession, l_message);
        if l_entry is not null then

          -- get the first entry
          l_entry := dbms_ldap.first_entry(ldapSession, l_message);

          l_attrs_vals := dbms_ldap.get_values(ldapSession, l_entry, 'creatorsname');
          l_creatorname := l_attrs_vals(0);
          l_attrs_vals := dbms_ldap.get_values(ldapSession, l_entry, 'orclisenabled');
          if l_attrs_vals is not NULL and l_attrs_vals.count > 0 then
            l_isenabled := l_attrs_vals(0);
          end if;
          l_attrs_vals := dbms_ldap.get_values(ldapSession, l_entry, 'orclguid');
          l_guid := l_attrs_vals(0);

          if (p_forced OR (upper(l_creatorname) = upper(fnd_ldap_util.get_orclappname)
              and l_isenabled is not NULL
              and (upper(l_isenabled) = 'INACTIVE' or upper(l_isenabled) = 'DISABLED')
                ) ) then
            x_result := delete_user_subscription(ldapSession, l_guid);
--            x_result := delete_uniquemember(ldapSession, p_user_name);
--            x_result := delete_user_nodes(ldapSession, p_user_name);

--scheruku: Calling the APIS which use the GUID instead
            x_result := delete_uniquemember(ldapSession, l_orclguid);
            x_result := delete_user_nodes(ldapSession, l_orclguid);


          --end if;
        --end if;
      --end if;
   --end loop;
   --x_result := fnd_ldap_util.unbind(ldapSession);

          ELSE

                if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
                then
                  if (upper(l_creatorname) = upper(fnd_ldap_util.get_orclappname)) THEN
                         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'NOT DELETED BECAUSE  was created  by '||l_creatorname);
                   END IF;

                  if NOT (l_isenabled is not NULL and (upper(l_isenabled) = 'INACTIVE' or upper(l_isenabled) = 'DISABLED'))
                    THEN
                         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'NOT DELETED BECAUSE  is still enabled '||l_isenabled);
                   END IF;
                end if;
          end if;
        end if;
      end if;

   if (x_result = dbms_ldap.SUCCESS) then
        x_result := fnd_ldap_util.G_SUCCESS;
   end if;
  end if;-- fnd_user guid null check if block ends here

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when others then
    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
    end if;
    x_result := fnd_ldap_util.G_FAILURE;

end delete_user;

procedure delete_user(p_user_guid in  fnd_user.user_guid%type ,
                     x_result out nocopy pls_integer,
                     p_forced in boolean ) is

ldapSession  dbms_ldap.session;
dummy pls_integer;
BEGIN
  ldapSession := fnd_ldap_util.c_get_oid_session(dummy);
  delete_user(ldapSession,p_user_guid,x_result,p_forced);
  fnd_ldap_util.c_unbind(ldapSession,dummy);
end delete_user;
procedure delete_user(p_user_guid in  fnd_user.user_guid%type ,
                     x_result out nocopy pls_integer ) is

ldapSession  dbms_ldap.session;
dummy pls_integer;
BEGIN

  delete_user(p_user_guid,x_result,false);

end delete_user;


--

-------------------------------------------------------------------------------
--** INTERNAL SIGNATURE
-- The external siganture can only call change_password for updates
-- Only from this package we can call change_password for creation phase
--
procedure change_password(p_user_guid in raw,
                          p_user_name in varchar2,
                          p_new_pwd in varchar2,
                          p_expire_password in pls_integer,
                          x_password out nocopy varchar2,
                          x_result out nocopy pls_integer,
                          p_user_creation in boolean default FALSE ) is
  no_such_user_exp    exception;
  PRAGMA EXCEPTION_INIT (no_such_user_exp, -20001);
  l_module_source   varchar2(256):= G_MODULE_SOURCE || 'change_password: ';

BEGIN
   update_user(p_user_guid =>p_user_guid,
                     p_user_name=>p_user_name,
                     p_password => p_new_pwd,
                     p_expire_password =>p_expire_password,
                     x_password=>x_password,
                     x_result => x_result,
		     x_user_creation=>p_user_creation) ;
  exception
    when no_such_user_exp then
      fnd_message.set_name ('FND', 'FND_SSO_USER_NOT_FOUND');
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
      end if;
      x_result := fnd_ldap_util.G_FAILURE;
    when others then
      fnd_message.set_name ('FND', 'FND_SSO_UNEXP_ERROR');
      if (fnd_log.LEVEL_EXCEPTION>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
      end if;
    --x_result := fnd_ldap_util.G_FAILURE;
    -- bug 4573677
    raise;

end change_password;
procedure change_password(p_user_guid in raw,
                          p_user_name in varchar2,
                          p_new_pwd in varchar2,
                          p_expire_password in pls_integer,
                          x_password out nocopy varchar2,
                          x_result out nocopy pls_integer ) is
BEGIN
   change_password(p_user_guid,p_user_name,p_new_pwd,p_expire_password,x_password,x_result,FALSE);
END change_password;
--
-------------------------------------------------------------------------------
function user_exists_by_guid( guid in raw ) return pls_integer
is
  dn varchar2(2000);
  result pls_integer;
begin

      dn := fnd_ldap_util.get_dn_for_guid(guid);
     if (dn is not null) then
         result := FND_LDAP_UTIL.G_SUCCESS;
     else
         result := FND_LDAP_UTIL.G_FAILURE;
     end if;
     return result;

  EXCEPTION WHEN OTHERS THEN
      IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(fnd_log.LEVEL_EXCEPTION, G_MODULE_SOURCE || 'user_exists_by_guid:', sqlerrm);
     END IF;
     raise;



end user_exists_by_guid;
--
-------------------------------------------------------------------------------
procedure change_user_name(p_user_guid in raw,
                          p_old_user_name in varchar2,
                          p_new_user_name in varchar2,
                          x_result out nocopy pls_integer) is
  l_module_source VARCHAR2(256);
  l_user_id fnd_user.user_id%type;
  l_to_synch BOOLEAN;
  ldap dbms_ldap.session;
  flag pls_integer;
  user_rec FND_LDAP_USER.ldap_user_type;
  invalid_new_user_exp EXCEPTION;
  no_such_user_exp     EXCEPTION;
  dn VARCHAR2(4000);
  val varchar2(4000);
  nna varchar2(200);
  handle pls_integer;
  upd update_list;
  target dbms_ldap.string_collection;
  fld VARCHAR2(200);
  i pls_integer;
  ma dbms_ldap.mod_array;
  found boolean;
  PRAGMA EXCEPTION_INIT (no_such_user_exp, -20001);
  x_fnd pls_integer;
  x_oid pls_integer;

begin
  l_module_source             := G_MODULE_SOURCE || 'change_user_name: ';
  IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  END IF;
  IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'guid:'||p_user_guid||' old='||p_old_user_name||' new='||p_new_user_name);
  END IF;
  -- Check the obivious: No change (ignore case)
  IF (upper(p_old_user_name)     =upper(p_new_user_name))THEN
    IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END-> SAME NAMES, no changes!');
    END IF;
    x_result:=fnd_ldap_util.G_SUCCESS;
    RETURN;
  END IF;
  -- look for the user_id.
  -- this procedure asumes that name was already changed on FND_USER (not commit maybe)
  BEGIN
     SELECT user_id
       INTO l_user_id
       FROM FND_USER
      WHERE user_guid=p_user_guid
    AND user_name    =p_old_user_name;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_UNEXPECTED , l_module_source, 'Cannot locate user_name[new]='||p_new_user_name||' guid='|| p_user_guid||':'||sqlerrm);
    END IF;
    x_result:=fnd_ldap_util.G_FAILURE;
    RETURN;
  END;
  /** to do - what if there are multiple linked users ? **/
	if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'USER id:: '||l_user_id);
  end if;
  l_to_synch := CanSync(l_user_id,p_old_user_name);
  IF (l_to_synch) THEN
    IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'SYNC user '||p_new_user_name);
    END IF;
    ldap := fnd_ldap_util.c_get_oid_session(flag);
    IF FND_LDAP_UTIL.loadLdapRecord( ldap, user_rec.user_data, dn , p_user_guid, fnd_ldap_util.G_GUID_KEY) THEN
      user_rec.dn                 :=dn;
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Updating dn:'||dn);
      END IF;
      ProcessLoadedLpadUserRecord(user_rec,NULL,dn);
      nna := user_rec.NickName_ATT_NAME;

      FND_SSO_REGISTRATION.is_operation_allowed (
         p_direction => FND_LDAP_WRAPPER.G_EBIZ_TO_OID,
         p_entity => FND_LDAP_WRAPPER.G_IDENTITY,
         p_operation => FND_LDAP_WRAPPER.G_MODIFY,
         p_attribute => nna,
         x_fnd_user => x_fnd,
         x_oid => x_oid,
         p_user_name => user_rec.user_name,
         p_realm_dn => user_rec.realmDN);

      if (x_oid = FND_LDAP_WRAPPER.G_SUCCESS ) THEN
          i := user_rec.user_data(nna).first;
          found := false;
          target.delete;
          IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Verifiying that Nickname atrribute does contain  username in '||nna);
          END IF;

          while i is not null loop
              if  (user_rec.user_data(nna)(i)=p_old_user_name) THEN
                  found := true;
                  target(target.count) := p_new_user_name;
                  IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'It does');
                  END IF;

              ELSE
                  IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'may need to keep '||user_rec.user_data(nna)(i));
                  END IF;

                 target(target.count) := user_rec.user_data(nna)(i);
              END IF;
              i:= user_rec.user_data(nna).next(i);
          end loop;
          IF found THEN
                  IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Updating LDAP ');
                  END IF;
             ma := dbms_ldap.create_mod_array(num=> 1);
             dbms_ldap.populate_mod_array(modptr => ma,
                     mod_op => DBMS_LDAP.MOD_REPLACE,
                     mod_type => nna,
                     modval => target);
             x_result:= dbms_ldap.modify_s(ldap,user_rec.dn, ma);
            if (x_result = dbms_ldap.SUCCESS) then
                       x_result := fnd_ldap_util.G_SUCCESS;
                  IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Updating succedd ');
                  END IF;
            end if;
            dbms_ldap.free_mod_array(modptr => ma);
        ELSE
          IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Cannot update nickname attribute');
          END IF;
        END IF;
      ELSE

              IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'NickName att does not contain username, no changes ');
              END IF;
      END IF;
    ELSE
      IF (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_UNEXPECTED , l_module_source, 'Cannot locate user_name[new]='||p_new_user_name||' guid='|| p_user_guid||':'||sqlerrm);
      END IF;
      raise no_such_user_exp;
    END IF;
    fnd_ldap_util.c_unbind(ldap,flag);
  ELSE
    x_result                    := fnd_ldap_util.G_SUCCESS;
    IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User is a local user or Synch profile is disabled.');
    END IF;
  END IF;



  IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    IF (x_result               = fnd_ldap_util.G_SUCCESS ) THEN
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End-> fnd_ldap_util.G_SUCCESS ');
    ELSE
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End-> fnd_ldap_util.G_FAIL ');
    END IF;
  END IF;



exception
  when invalid_new_user_exp then
      fnd_ldap_util.c_unbind(ldap,flag);
      fnd_message.set_name ('FND', 'FND_SSO_INVALID_NEW_USER_NAME');
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
      end if;
      x_result := fnd_ldap_util.G_FAILURE;
  when no_such_user_exp then
      fnd_ldap_util.c_unbind(ldap,flag);
      fnd_message.set_name ('FND', 'FND_SSO_USER_NOT_FOUND');
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
      end if;
      x_result := fnd_ldap_util.G_FAILURE;
  when others then
      fnd_message.set_name ('FND', 'FND_SSO_UNEXP_ERROR');
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
      end if;
      x_result := fnd_ldap_util.G_FAILURE;
end change_user_name;
--
-------------------------------------------------------------------------------
--
-- 1) Fills an usertype fnd_ldap_util.ldap_user_type and call create_user(fnd_ldap_util.ldap_user_type)
--    if it returns failure put a FND_SSO_USER_EXIST on the errors tack
--
-- 2) Retreive its guid
-- 3) Loook at the APPS_SSO_LOCAL_LOGIN ( user=-1 level, which may or may not be site)
--      If its SSO set the FND_USER password to external
-- Any EXCEPTION will be logged and passed up


FUNCTION create_ldap_user (
    p_ldap_session IN dbms_ldap.session,
    p_ldap_user    IN OUT nocopy ldap_user_type)
  RETURN pls_integer
IS
  l_module_source VARCHAR2(256);
  retval pls_integer;
  ldap_result pls_integer;
  modArray dbms_ldap.mod_array;
  atName VARCHAR2(4000);
  atVal  VARCHAR2(4000);
  handler pls_integer;
  myid INTEGER;
  l_dn VARCHAR2(4000);
  list1 dbms_ldap.string_collection;
  n pls_integer;
  i pls_integer;
  some_data boolean := false;
BEGIN
  l_module_source := G_MODULE_SOURCE || 'create_ldap_user: ';
  retval := fnd_ldap_util.G_FAILURE;

  IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');

    -- LOG THE ATTEMPTED CHANGES
    IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      BEGIN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'username:'||p_ldap_user.user_name||'  DN :'||l_dn);
        myid:= sys_context('USERENV', 'SESSIONID');
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Attempt to create LDAP user ['||p_ldap_user.user_name||'] ['||myid||']');
        IF firstValue(p_ldap_user, atname, atval, handler) THEN
          WHILE (atName IS NOT NULL)
          LOOP
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, '['||myid||'] '||atName||':'||atVal);
            IF (NOT NextValue(p_ldap_user,atName,atVal,handler) )THEN
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, '['||myid||'] END ');
              atName:=NULL;
            END IF;
          END LOOP;
        END IF;
      EXCEPTION WHEN OTHERS THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Error during log operation '||sqlerrm);
      END;
    END IF;
  END IF;

  IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Populate modarray : count='|| p_ldap_user.user_data.count);
  END IF;

  -- Now we need to figure out the DN and the realm
  FND_OID_PLUG.completeforcreate(p_ldap_session,p_ldap_user);


  FND_OID_PLUG.fixupLDAPUser(p_ldap_user,FND_OID_PLUG.G_CREATE_USER);

  modArray := dbms_ldap.create_mod_array(num=> p_ldap_user.user_data.count);
  atName := p_ldap_user.user_data.first ;

  WHILE atName IS NOT NULL
  LOOP
            -- Login current data
        IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, '  adding '|| atName);
            FOR i IN p_ldap_user.user_data(atName).first .. p_ldap_user.user_data(atName).last
            LOOP
                IF (p_ldap_user.user_data(atName).exists(i) ) THEN
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, '        '||p_ldap_user.user_data(atName)(i) );
                ELSE
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, '        missing element '||i );
                END IF;
            END LOOP;
        END IF;

        list1.delete();
        n:=0;
        i:=p_ldap_user.user_data(atName).first;

        if lower(atName)='objectclass' or
         CanPopulate(atName,p_ldap_user.user_name,p_ldap_user.realmDN) THEN
            LOOP
              list1(n):= p_ldap_user.user_data(atName)(i);
              n := n+1;
              i := p_ldap_user.user_data(atName).next(i);
              EXIT WHEN i IS NULL;
            END LOOP;
            dbms_ldap.populate_mod_array(modptr => modArray, mod_op => DBMS_LDAP.MOD_ADD, mod_type => atName, modval => list1);
            some_data := true;
        ELSE
          IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Populate modarray : count='|| p_ldap_user.user_data.count);
          END IF;
        END IF;
        atName := p_ldap_user.user_data.next(atName);
  END LOOP;

  if (some_data) THEN
       ldap_result := dbms_ldap.add_s(ld => p_ldap_session, entrydn => p_ldap_user.dn , modptr =>modArray);
  ELSE
       IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'add_s no data to load');
       END IF;
  END IF;
  dbms_ldap.free_mod_array(modArray);
  IF ldap_result = dbms_ldap.SUCCESS THEN

       retval := fnd_ldap_util.G_SUCCESS;
       IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'created user:' || p_ldap_user.user_name);
       END IF;

        -- get the guid
       p_ldap_user.user_guid := FND_LDAP_UTIL.get_guid_for_dn(p_ldap_session,p_ldap_user.dn );
       IF (p_ldap_user.user_guid IS NULL) THEN
          IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Unoticed falure to create created DN [' || p_ldap_user.dn||']');
          END IF;
          retval:= fnd_ldap_util.G_FAILURE;
       ELSE
          retval := fnd_ldap_util.G_SUCCESS;
          IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'new user:' || p_ldap_user.user_name || ' dn:' || p_ldap_user.dn );
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'new user:' || p_ldap_user.user_name || ' guid:' || p_ldap_user.user_guid );
          END IF;
       END IF;
      ELSE
        retval := fnd_ldap_util.G_FAILURE;
        IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Falied to create ['||p_ldap_user.dn||'] user:'||p_ldap_user.user_name);
        END IF;

  END IF;
  IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END->'||retval);
  END IF;
  RETURN retval;


exception
  when others then
    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
    end if;
  raise;

END create_ldap_user;
--
-------------------------------------------------------------------------------
/*
  get_ACCOUNT_dn: returns where to store subscription information at OiD.
                Now is simple, in the future may change for multiples realms.
*/
function get_ACCOUNT_dn(p_guid in raw) return varchar2 is
begin
   return 'cn=ACCOUNTS,cn=subscription_data,cn=subscriptions,' || fnd_ldap_util.get_orclappname;
end get_ACCOUNT_dn;
--
-------------------------------------------------------------------------------
function create_user_subscription(ldapSession in dbms_ldap.session, p_user_dn in varchar2 , p_guid in raw)
return pls_integer is

l_module_source   varchar2(256);
subsNode varchar2(4000);
acctNode varchar2(4000);
--userDN varchar2(4000):= p_user_dn;
result pls_integer;
retval pls_integer;
--ldapSession dbms_ldap.session;
modArray  dbms_ldap.mod_array;
modmultivalues dbms_ldap.string_collection;
i number;
flag pls_integer;
err varchar2(1000);  --bug 8618800
begin
  l_module_source := G_MODULE_SOURCE || 'create_user_subscription: ';
  -- set default value to failure. change to success when user created successfully
  retval := fnd_ldap_util.G_FAILURE;
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin guid='||p_guid);
  end if;

  -- ldapSession := fnd_ldap_util.c_get_oid_session(flag);

  -- userDN := fnd_ldap_util.get_dn_for_guid(p_guid);

  acctNode := get_ACCOUNT_dn(p_guid);
--  num_attributes := process_attributes(p_ldap_user, x_atts => l_atts,
  --                                       x_att_values => l_att_values);

  modArray := dbms_ldap.create_mod_array(num => 2);

  modmultivalues(0) := 'orclServiceSubscriptionDetail';
  dbms_ldap.populate_mod_array(modptr => modArray, mod_op => dbms_ldap.mod_add, mod_type => 'objectclass', modval => modmultivalues);

  modmultivalues(0) := p_user_dn;
  dbms_ldap.populate_mod_array(modptr => modArray, mod_op => dbms_ldap.mod_add, mod_type => 'seeAlso', modval => modmultivalues);

  subsNode := 'orclOwnerGUID=' || p_guid|| ',' || acctNode;
  retval := dbms_ldap.add_s(ld => ldapSession, entrydn => subsNode, modptr => modArray);

  if (retval = dbms_ldap.SUCCESS) then
    --retval := add_uniquemember(p_ldap_user);
    fnd_ldap_util.add_attribute_M(ldapSession,acctNode,'uniqueMember',p_user_dn);
    retval:= fnd_ldap_util.G_SUCCESS;
  else
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Failed! retval='||retval||' subsNode:'||subsNode);
     end if;
  end if;

  dbms_ldap.free_mod_array(modptr => modArray);
  --fnd_ldap_util.c_unbind(ldapSession,flag);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return retval;

exception
when others then
    err := sqlerrm;  --bug 8618800

    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
       fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
    end if;
  -- Bug 8618800 if already exists continue
    if (instr(err,'Already exists. Object already exists') > 0) then
    	if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)	 then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User already subscribed');
        end if;
 	retval :=  fnd_ldap_util.G_SUCCESS;
	return retval;
    else
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)	 then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Failed! retval='||retval||' subsNode:'||subsNode);
       end if;
       raise;
    end if;


end create_user_subscription;
--
-------------------------------------------------------------------------------
procedure decode_dates(p_user_name in varchar2, p_start_date in date, p_end_date in date, x_orclisEnabled out nocopy varchar2, x_user_id out nocopy fnd_user.user_id%type) is

  cursor fnd_dates is
    select user_id, decode(p_start_date, fnd_user_pkg.null_date, null,
                                null, start_date,
                                p_start_date) l_start_date,
           decode(p_end_date, fnd_user_pkg.null_date, null,
                                null, end_date,
                                p_end_date) l_end_date
           from fnd_user
           where user_name = p_user_name;

  l_rec             fnd_dates%rowtype;
  l_found           boolean;
  l_user_id fnd_user.user_id%type;
  l_start_date date;
  l_end_date date;
  l_module_source   varchar2(256);
  no_such_user_exp  exception;

begin
  l_module_source := G_MODULE_SOURCE || 'decode_dates: ';
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  open fnd_dates;
  fetch fnd_dates into l_rec;
  l_found := fnd_dates%found;
  close fnd_dates;

  if (not l_found)
  then
    raise no_such_user_exp;
  end if;


-- Fetching the user_id also in order to fetch user level profiles after call to this procedure.
   x_user_id := l_rec.user_id;

   if ((l_rec.l_start_date is not null and l_rec.l_start_date > sysdate)
    or
      (l_rec.l_end_date is not null and l_rec.l_end_date <= sysdate))
  then
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User is disabled');
       end if;
       x_orclisEnabled := fnd_oid_util.G_DISABLED;

  else
    x_orclisEnabled := fnd_oid_util.G_ENABLED;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
when others then
  if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
  end if;
  raise_application_error(-20001, 'FND_SSO_USER_NOT_FOUND');

end decode_dates;
--
-------------------------------------------------------------------------------
--
--Added by scheruku for Nickname changes
-------------------------------------------------------------------------------
function delete_user_nodes(p_ldap_session in dbms_ldap.session,
                     p_orclguid in fnd_user.user_guid%type) return pls_integer is

l_module_source   varchar2(256);
usersNode varchar2(1000);
usersNodes dbms_ldap.string_collection;
l_result pls_integer;

begin
  l_module_source := G_MODULE_SOURCE || 'delete_user_nodes: ';
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;



  usersNode := fnd_ldap_util.get_dn_for_guid(p_orclguid => p_orclguid);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'DN for user with GUID::'
         ||p_orclguid||' DN::'||usersNode);
   end if;

  l_result := dbms_ldap.delete_s(ld => p_ldap_session, entrydn => usersNode);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;
  return l_result;

  EXCEPTION WHEN OTHERS THEN
      IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
     END IF;
     raise;

end delete_user_nodes;
--
------------------------------------------------------------------------------
function delete_user_subscription(p_ldap_session in dbms_ldap.session, guid in raw)
return pls_integer is

l_module_source   varchar2(256);
subsNode varchar2(1000);
l_user_guid raw(256) := guid;
l_attrs dbms_ldap.string_collection;
l_message dbms_ldap.message := null;
l_result pls_integer;
l_entry dbms_ldap.message := null;

begin
  l_module_source := G_MODULE_SOURCE || 'delete_user_subscription ';
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  -- delete subcriptions with orclOwnerGUID
  subsNode := 'cn=ACCOUNTS,cn=subscription_data,cn=subscriptions,' || fnd_ldap_util.get_orclappname;
  l_result := dbms_ldap.search_s(ld => p_ldap_session, base => subsNode,
    scope => dbms_ldap.SCOPE_SUBTREE, filter => 'orclOwnerGUID=' || l_user_guid, attrs => l_attrs, attronly => 0, res => l_message);
  if (l_result is not NULL) then
        l_entry := dbms_ldap.first_entry(p_ldap_session, l_message);
        if l_entry is not null then
           l_result := dbms_ldap.delete_s(ld => p_ldap_session, entrydn => 'orclOwnerGUID=' || l_user_guid||','||subsNode);
        end if;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;
  return l_result;

  EXCEPTION WHEN OTHERS THEN
      IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
     END IF;
     raise;

end delete_user_subscription;
--
-------------------------------------------------------------------------------
function delete_uniquemember(p_ldap_session in dbms_ldap.session,
                      p_orclguid in fnd_user.user_guid%type) return pls_integer is

l_module_source   varchar2(256);
subsNode varchar2(1000);
usersNode varchar2(1000);
usersNodes dbms_ldap.string_collection;
result pls_integer;
retval pls_integer;
modArray  dbms_ldap.mod_array;
modmultivalues dbms_ldap.string_collection;
i number;

begin
  l_module_source := G_MODULE_SOURCE || 'delete_uniquemember: ';
  -- set default value to failure. change to success when added successfully
  retval := fnd_ldap_util.G_FAILURE;
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  subsNode := 'cn=ACCOUNTS,cn=subscription_data,cn=subscriptions,' || fnd_ldap_util.get_orclappname;

  modArray := dbms_ldap.create_mod_array(num => 1);

  modmultivalues(0) := fnd_ldap_util.get_dn_for_guid(p_orclguid);

  dbms_ldap.populate_mod_array(modptr => modArray, mod_op => dbms_ldap.mod_delete, mod_type => 'uniquemember', modval => modmultivalues);

  retval := dbms_ldap.modify_s(ld => p_ldap_Session, entrydn => subsNode, modptr => modArray);


  if (retval = dbms_ldap.SUCCESS) then
    retval := fnd_ldap_util.G_SUCCESS;
  end if;

  dbms_ldap.free_mod_array(modptr => modArray);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return retval;

exception
when others then
  if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
  end if;
     raise;

end delete_uniquemember;
--
-------------------------------------------------------------------------------
procedure disable_user(p_user_guid in raw,
                       p_user_name in varchar2,
                       x_result out nocopy pls_integer) is

  usertype fnd_ldap_util.ldap_user_type;
  l_module_source   varchar2(256);
  no_such_user_exp    exception;
  l_user_id fnd_user.user_id%type;
  l_local_login         varchar2(30);
  l_allow_sync          varchar2(1);
  l_profile_defined     boolean;
  l_to_synch boolean;
  x_password pls_integer;

  PRAGMA EXCEPTION_INIT (no_such_user_exp, -20001);

begin
  l_module_source := G_MODULE_SOURCE || 'disable_user: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;
  -- there is no need to do something more specific
  -- Note that this only update sOID with DISABLE
  update_user(p_user_guid =>p_user_guid,p_user_name =>p_user_name,
                     p_end_date =>sysdate-100,
                     p_expire_password => 0,x_password => x_password,x_result => x_result , x_user_creation=>FALSE);

  if x_result <> fnd_ldap_util.G_SUCCESS then
    raise no_such_user_exp;
  end if;
exception
  when no_such_user_exp then
    fnd_message.set_name ('FND', 'FND_SSO_USER_NOT_FOUND');
    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
    end if;
    x_result := fnd_ldap_util.G_FAILURE;
  when others then
    fnd_message.set_name ('FND', 'FND_SSO_UNEXP_ERROR');
    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
    end if;
    x_result := fnd_ldap_util.G_FAILURE;

end disable_user;
--
--
--  Return the first GUID found for this username
--     also return in n the number of entryes found
--
--

FUNCTION get_user_guid_and_count
  (
    p_user_name IN VARCHAR2,
    n OUT nocopy pls_integer)
  RETURN VARCHAR2
IS
  l_module_source VARCHAR2(256);
  orclguid        VARCHAR2(1000);
BEGIN
  l_module_source             := G_MODULE_SOURCE || 'get_user_guid_and_count: ';
  IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin p_username='||p_user_name);
  END IF;
  orclguid    := get_user_guid(p_user_name);
  IF orclguid IS NULL THEN
    n         :=0;
  ELSE
    n:=1;
  END IF;
  IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, '  END orclguid='||orclguid||' n='||n);
  END IF;
  RETURN orclguid;
EXCEPTION
WHEN OTHERS THEN
  IF (fnd_log.LEVEL_EXCEPTION>= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
  END IF;
  raise;
END get_user_guid_and_count;

-----------------------------------------
--
-------------------------------------------------------------------------------
function get_user_guid(p_ldap_session in dbms_ldap.session, p_user_name in varchar2, dn out nocopy varchar2)
return raw is

l_module_source   varchar2(256);
result pls_integer;
l_user_guid raw(256);
l_message dbms_ldap.message := null;
l_entry dbms_ldap.message := null;
l_attrs dbms_ldap.string_collection;
searchBase varchar2(1000);
searchFilter varchar2(1000);
orclguid varchar2(1000);
ldapSession dbms_ldap.session;
dummy dbms_ldap.session;

realmList dbms_ldap.string_collection;
ridx pls_integer;
sbase dbms_ldap.string_collection;
begin
  l_module_source := G_MODULE_SOURCE || 'get_user_guid: ';
--  retval := fnd_ldap_util.G_FAILURE;
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  ldapSession := p_ldap_session;
  l_attrs(0) := 'orclguid';
  realmList := fnd_oid_plug.getRealmList();
  for r in realmList.first .. realmList.last loop
    if (orclguid is null ) THEN
      ridx := fnd_sso_registration.find_realm_index(realmList(r));
      sbase := fnd_sso_registration.getrealmsearchbaselist(ridx);
      searchFilter := fnd_sso_registration.get_realm_attribute(ridx,'orclcommonnicknameattribute')
                  ||'='||p_user_name ;

      for s in sbase.first .. sbase.last loop
                 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
                  then
                    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'realm:'||r||' base:'||sbase(s)||' filter:'||searchFilter);
                  end if;
             result := dbms_ldap.search_s(ld => ldapSession,
                  base => sbase(s),
                  scope => dbms_ldap.SCOPE_SUBTREE,
                  filter => searchFilter,
                  attrs => l_attrs, attronly => 0,
                  res => l_message);
             l_entry := dbms_ldap.first_entry(ldapSession, l_message);
             if (l_entry is not null) then
                        l_attrs := dbms_ldap.get_values(ldapSession, l_entry, 'orclguid');
                        dn := dbms_ldap.get_dn(ldapSession,l_entry);
                        orclguid := l_attrs(0);
                        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
                          then
                              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'FOUND under base='||sbase(s)||
                               ' dn:'|| dn ||' guid='||orclguid);
                        end if;
             END IF;
      end loop;
    END IF;
  end loop;


  l_user_guid := orclguid;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    if (l_user_guid is not null) then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'GUID found = ' || l_user_guid);
    ELSE
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User '||p_user_name||' not found');
    END IF;
  end if;

  --result := fnd_ldap_util.unbind(ldapSession);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;
  return l_user_guid;

exception
  when others then
    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
     -- print stack just for 7306960
  	--result:= -99;
        --dummy := fnd_ldap_util.c_get_oid_session(result);
    end if;
    raise;

end get_user_guid;

function get_user_guid(p_ldap_session in dbms_ldap.session, p_user_name in varchar2)
return raw is
dn varchar2(4000);
begin
   return get_user_guid(p_ldap_session,p_user_name,dn);
end;

function get_user_guid( p_user_name in varchar2)
return raw is
  l_ldap dbms_ldap.session;
ret fnd_user.user_guid%type;
dummy pls_integer;
BEGIN
  l_ldap := fnd_ldap_util.c_get_oid_session(dummy);
  ret := get_user_guid(l_ldap,p_user_name);
  fnd_ldap_util.C_unbind(l_ldap,dummy);
  return ret;
EXCEPTION
WHEN OTHERS THEN
  fnd_ldap_util.c_unbind(l_ldap,dummy);
  IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, G_MODULE_SOURCE || 'get_user_guid: ', sqlerrm);
  END IF;
  raise;
END get_user_guid;
--
----------------------------------------



--
-------------------------------------------------------------------------------

--
-------------------------------------------------------------------------------
procedure link_user(p_user_name in varchar2,
                    x_user_guid out nocopy raw,
                    x_password out nocopy varchar2,
                    x_result out nocopy pls_integer) is

l_module_source   varchar2(256);
l_user_exists pls_integer;
l_result pls_integer;
l_orclguid fnd_user.user_guid%type;
l_local_login varchar2(100);
l_profile_defined boolean;
l_nickname varchar2(256);

begin
  l_module_source := G_MODULE_SOURCE || 'link_user: ';
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;


   l_orclguid := get_user_guid(p_user_name);
  -- only proceed if user exists

  if (l_orclguid is not null ) then


    fnd_oid_util.add_user_to_OID_sub_list(p_orclguid => l_orclguid, x_result => l_result);

    x_result := l_result;

    if (l_result = fnd_ldap_util.G_SUCCESS) then
      x_user_guid := l_orclguid;

      fnd_profile.get_specific(
        name_z      => 'APPS_SSO_LOCAL_LOGIN',
        user_id_z => -1,
        val_z      => l_local_login,
        defined_z    => l_profile_defined);

      if (l_local_login = 'SSO') then
        x_password := fnd_web_sec.EXTERNAL_PWD;
      end if;

    end if;

  -- user does not exist in OID
  else
    fnd_message.set_name('FND', 'FND_SSO_USER_NOT_FOUND');
    x_result := fnd_ldap_util.G_FAILURE;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
when others then
  if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
  end if;
  raise;

end link_user;
--
-------------------------------------------------------------------------------
function process_attributes(p_ldap_user in fnd_ldap_util.ldap_user_type,
                            p_operation_type in pls_integer default G_CREATE,
                            x_atts out nocopy dbms_ldap.string_collection,
                            x_att_values out nocopy dbms_ldap.string_collection)
                            return number is

l_module_source   varchar2(256);
num_attributes     number;

begin
  l_module_source := G_MODULE_SOURCE || 'process_attributes: ';
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  num_attributes := 0;

  if (p_ldap_user.sn is not null) then
    x_atts(num_attributes) := 'sn';
    x_att_values(num_attributes) := p_ldap_user.sn;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.cn is not null) then
    x_atts(num_attributes) := 'cn';
    x_att_values(num_attributes) := p_ldap_user.cn;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.uid is not null) then
    x_atts(num_attributes) := 'uid';
    x_att_values(num_attributes) := p_ldap_user.uid;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.userPassword is not null) then
    x_atts(num_attributes) := 'userPassword';
    x_att_values(num_attributes) := p_ldap_user.userPassword;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.telephoneNumber is not null) then
    x_atts(num_attributes) := 'telephoneNumber';
    x_att_values(num_attributes) := p_ldap_user.telephoneNumber;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.street is not null) then
    x_atts(num_attributes) := 'street';
    x_att_values(num_attributes) := p_ldap_user.street;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.postalCode is not null) then
    x_atts(num_attributes) := 'postalCode';
    x_att_values(num_attributes) := p_ldap_user.postalCode;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.physicalDeliveryOfficeName is not null) then
    x_atts(num_attributes) := 'physicalDeliveryOfficeName';
    x_att_values(num_attributes) := p_ldap_user.physicalDeliveryOfficeName;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.st is not null) then
    x_atts(num_attributes) := 'st';
    x_att_values(num_attributes) := p_ldap_user.st;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.l is not null) then
    x_atts(num_attributes) := 'l';
    x_att_values(num_attributes) := p_ldap_user.l;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.displayName is not null) then
    x_atts(num_attributes) := 'displayName';
    x_att_values(num_attributes) := p_ldap_user.displayName;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.givenName is not null) then
    x_atts(num_attributes) := 'givenName';
    x_att_values(num_attributes) := p_ldap_user.givenName;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.homePhone is not null) then
    x_atts(num_attributes) := 'homePhone';
    x_att_values(num_attributes) := p_ldap_user.homePhone;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.mail is not null) then
    x_atts(num_attributes) := 'mail';
    x_att_values(num_attributes) := p_ldap_user.mail;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.c is not null) then
    x_atts(num_attributes) := 'c';
    x_att_values(num_attributes) := p_ldap_user.c;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.facsimileTelephoneNumber is not null) then
    x_atts(num_attributes) := 'facsimileTelephoneNumber';
    x_att_values(num_attributes) := p_ldap_user.facsimileTelephoneNumber;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.description is not null) then
    x_atts(num_attributes) := 'description';
    x_att_values(num_attributes) := p_ldap_user.description;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.orclisEnabled is not null) then
    x_atts(num_attributes) := 'orclisEnabled';
    x_att_values(num_attributes) := p_ldap_user.orclisEnabled;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.orclActiveStartDate is not null) then
    x_atts(num_attributes) := 'orclActiveStartDate';
    x_att_values(num_attributes) := p_ldap_user.orclActiveStartDate;
    num_attributes := num_attributes + 1;
  end if;
  if (p_ldap_user.orclActiveEndDate is not null) then
    x_atts(num_attributes) := 'orclActiveEndDate';
    x_att_values(num_attributes) := p_ldap_user.orclActiveEndDate;
    num_attributes := num_attributes + 1;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return num_attributes;

exception
when others then
  if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
  end if;
  raise;

end process_attributes;
--
-------------------------------------------------------------------------------
procedure unlink_user(p_user_guid in fnd_user.user_guid%type,
                      p_user_name in varchar2,
                      x_result out nocopy pls_integer) is

cursor linked_users is
  select user_name
  from fnd_user
  where user_guid = p_user_guid
  and user_name <> p_user_name;

l_rec             linked_users%rowtype;
l_found           boolean;
l_module_source   varchar2(256);
l_local_login varchar2(100);
l_profile_defined boolean;
l_ldap_session dbms_ldap.session :=null;
l_user_exists pls_integer;
dn varchar2(2000);
dummy pls_integer;

begin
  l_module_source := G_MODULE_SOURCE || 'unlink_user: ';
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  open linked_users;
  fetch linked_users into l_rec;
  l_found := linked_users%found;
  close linked_users;

  -- no other user linked
  if (not l_found)
  then

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'No other FND users linked to this OID User');
  end if;
    l_user_exists :=   user_exists_by_guid( p_user_guid);

    if (l_user_exists = fnd_ldap_util.G_SUCCESS) then

      l_ldap_session := fnd_ldap_util.c_get_oid_session(dummy);

      x_result := delete_user_subscription(l_ldap_session, p_user_guid);
      x_result := delete_uniquemember(l_ldap_session, p_user_guid);

    -- user does not exist in OID
    else
      fnd_message.set_name('FND', 'FND_SSO_USER_NOT_FOUND');
      x_result := fnd_ldap_util.G_FAILURE;
    end if;

  -- other users linked
  else

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Other FND users linked to this OID User');
    end if;

    x_result := fnd_ldap_util.G_FAILURE;
    fnd_message.set_name ('FND', 'FND_SSO_USER_MULT_LINKED');

  end if;
  if ( l_ldap_session is not null) then
     fnd_ldap_util.c_unbind(l_ldap_session,dummy);
  end if ;
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
when others then
   fnd_ldap_util.c_unbind(l_ldap_session,dummy);
  if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
  end if;
        raise;

end unlink_user;
--
-------------------------------------------------------------------------------

-- INTERNAL SIGNATURE
--  x_user_creation can only be true when is called from this package
-- calling public signature only permits x_user_creation=false
--
procedure update_user(p_user_guid in raw,
                     p_user_name in varchar2,
                     p_password in varchar2 default null,
                     p_start_date in date default null,
                     p_end_date in date default null,
                     p_description in varchar2 default null,
                     p_email_address in varchar2 default null,
                     p_fax in varchar2 default null,
                     p_expire_password in pls_integer,
                     x_password out nocopy varchar2,
                     x_result out nocopy pls_integer,
		     x_user_creation in boolean default FALSE ) is


  l_orclisEnabled varchar2(256);
 -- usertype fnd_ldap_util.ldap_user_type;
  ldap_user fnd_ldap_user.ldap_user_type;
  l_module_source   varchar2(256);
  no_such_user_exp    exception;
  l_nickname varchar2(256);

  l_user_id fnd_user.user_id%type;
  l_local_login         varchar2(30);
  l_allow_sync          varchar2(1);
  l_profile_defined     boolean;
  l_to_synch boolean;

  l_guid FND_USER.user_guid%type:= p_user_guid;
  ldap dbms_ldap.session;
  flag pls_integer;
  dn varchar2(4000);
  realm varchar2(4000);
    upd update_list;
    i pls_integer;
    x_name_change pls_integer;
    ldap_result pls_integer;
    l_use_proxy pls_integer := 0;
 PRAGMA EXCEPTION_INIT (no_such_user_exp, -20001);

begin

  l_module_source := G_MODULE_SOURCE || 'update_user[proc]: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;


   -- figure out the user_id
   BEGIN
      select user_id into l_user_id from fnd_user
      where user_name=p_user_name and user_guid=p_user_guid;
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'user_id:'||l_user_id);
      end if;

      l_to_synch := CanSync(l_user_id,p_user_name);

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          if (l_to_synch) then
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' synch');
           else
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' NOT synch username:'
                   ||p_user_name||' userid:'||l_user_id||'  userGuid:'||p_user_guid);
           end if;
       END IF;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_to_synch:= true;
        -- THIS IS UNEXPECTED !!
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Sinc, No ebzlinked user found:'||p_user_name||' guid:'||p_user_guid);
     end if;
   END;


  if (l_to_synch) then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' synch');
       END IF;
        l_use_proxy := 0;
        if (p_password is not null) THEN
           if (p_expire_password is not null and p_expire_password <> fnd_ldap_util.G_TRUE) THEN
               l_use_proxy :=2;
               --  Bug 9271995
	       --    During user_creation  if password is not in IDENTITY_ADD
	       --             expiration will be forced disregarding what was requested
	       IF (x_user_creation AND  not canPopulate('userpassword',ldap_user.user_name, ldap_user.realmDN) )THEN
	       		-- always expire the password
                       l_use_proxy :=1;
	       END IF;
           ELSE
               l_use_proxy :=1;
           END IF;
        ELSE
          l_use_proxy := 1;
        END IF;
        if ( l_use_proxy=2) then
             if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
             then
                    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Getting a proxied connection to avoid password forced change: NEW LDAP connection required');
              END IF;
            fnd_ldap_util.proxy_as_user(p_orclguid => p_user_guid,x_ldap_session => ldap);
        else
           ldap := FND_LDAP_UTIL.c_get_oid_session(flag);
           l_use_proxy :=1;
        end if;

       l_guid := p_user_guid;
       IF  FND_LDAP_UTIL.loadLdapRecord( ldap , ldap_user.user_data,dn,l_guid,FND_LDAP_UTIL.G_GUID_KEY)
       THEN
               ldap_user.dn                 :=dn;
               IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Updating dn:'||dn);
               END IF;
               ProcessLoadedLpadUserRecord(ldap_user,NULL,dn);
               --  Bug 9271995
               --       x_user_creation=TRUE we always update the password
               --       x_user_creation=FALSE we check IDENTITY_MODIFY provisioning profile
	       --
               IF (p_password is not null and
		       (
			      x_user_creation  -- we set the password anyway, although it will be expired
			      OR canUpdate('userpassword',ldap_user.user_name, ldap_user.realmDN,x_user_creation)
		       )
		   ) THEN
                        i:= upd.count;
                        upd(i).att := 'userpassword';
                        upd(i).val := p_password;
                        upd(i).op := DBMS_LDAP.MOD_REPLACE;
               END IF;
               IF (p_description is not null and NOT isValueOf(ldap_user,'description',p_description)
                     and  canUpdate('description',ldap_user.user_name, ldap_user.realmDN,x_user_creation) ) THEN
                        i:= upd.count;
                        upd(i).att := 'description';
                        upd(i).val := p_description;
                        upd(i).op := DBMS_LDAP.MOD_REPLACE;
               END IF;

               IF (p_email_address is not null and NOT isValueOf(ldap_user,'mail',p_email_address)
                   and  canUpdate('mail',ldap_user.user_name, ldap_user.realmDN,x_user_creation) ) THEN
                        i:= upd.count;
                        upd(i).att := 'mail';
                        upd(i).val := p_email_address;
                        upd(i).op := DBMS_LDAP.MOD_REPLACE;
               END IF;
               IF (p_fax is not null and NOT isValueOf(ldap_user,'facsimileTelephoneNumber',p_fax)
                     and canUpdate('facsimileTelephoneNumber',ldap_user.user_name, ldap_user.realmDN,x_user_creation)
                  ) THEN
                        i:= upd.count;
                        upd(i).att := 'facsimileTelephoneNumber';
                        upd(i).val := p_fax;
                        upd(i).op := DBMS_LDAP.MOD_REPLACE;
               END IF;
                decode_dates(p_user_name, p_start_date, p_end_date,
                             x_orclisEnabled => l_orclisEnabled,
                             x_user_id => l_user_id);
               IF (l_orclIsEnabled is not null and NOT isValueOf(ldap_user,'orclIsEnabled',l_orclIsEnabled)
                       and  canUpdate('orclisenabled',ldap_user.user_name, ldap_user.realmDN)
                       and l_orclIsEnabled = fnd_oid_util.G_ENABLED) THEN
                        i:= upd.count;
                        upd(i).att := 'orclIsEnabled';
                        upd(i).val := l_orclIsEnabled;
                        upd(i).op := DBMS_LDAP.MOD_REPLACE;
               END IF;
               if (upd.count>0) THEN
                   ProcessUpdateRec(ldap,ldap_user.dn,upd);
               END IF;
               x_result :=   fnd_ldap_util.G_SUCCESS;
/*
   CANNOT CHANGE USERNAME
      Unless the old is known, and that is not possible because already was changed on FND_USER...
               IF (x_result=FND_LDAP_UTIl.G_SUCCESS AND p_user_name is not null and isValueOf(ldap_user,ldap_user.nickname_att_name,   p_user_name) ) THEN
                   change_user_name(p_user_guid,ldap_user.user_name,p_user_name,x_name_change);
                   x_result :=x_name_change;
               END IF;
               */
        ELSE
            if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
            then
                fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'USER  '||ldap_user.user_name||' hasn an invalid guid:'||p_user_guid);
            end if;
            raise no_such_user_exp;
        END IF;
        if ( l_use_proxy=2 ) then
                 ldap_result  := fnd_ldap_util.unbind(ldap);
        elsif l_use_proxy=1 then
             FND_LDAP_UTIL.c_unbind(ldap,flag);
        end if;
        l_use_proxy:=0;

--        ldap:=null;

  else
    x_result := fnd_ldap_util.G_SUCCESS;
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
                 'User is a local user or synch is disabled for this user.');
    end if;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    if ( x_result = fnd_ldap_util.G_SUCCESS) THEN
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End->SUCCESS');
    ELSE
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End->FAIL');
     END IF;
  end if;

  if x_result <> fnd_ldap_util.G_SUCCESS then
    raise no_such_user_exp;
  else
    fnd_profile.get_specific(
      name_z      => 'APPS_SSO_LOCAL_LOGIN',
      user_id_z => l_user_id,
      val_z      => l_local_login,
      defined_z    => l_profile_defined);

    if (l_local_login = 'SSO') then
      x_password := fnd_web_sec.EXTERNAL_PWD;
    end if;
  end if;

exception
  when no_such_user_exp then
          if ( l_use_proxy=2 ) then
                 ldap_result  := fnd_ldap_util.unbind(ldap);
        elsif l_use_proxy=1 then
             FND_LDAP_UTIL.c_unbind(ldap,flag);
        end if;
        l_use_proxy:=0;
    fnd_message.set_name ('FND', 'FND_SSO_USER_NOT_FOUND');
    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
    end if;
    x_result := fnd_ldap_util.G_FAILURE;
  when others then
        if ( l_use_proxy=2 ) then
                 ldap_result  := fnd_ldap_util.unbind(ldap);
        elsif l_use_proxy=1 then
             FND_LDAP_UTIL.c_unbind(ldap,flag);
        end if;
        l_use_proxy:=0;

    fnd_message.set_name ('FND', 'FND_SSO_UNEXP_ERROR');
    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
    end if;
--  x_result := fnd_ldap_util.G_FAILURE;
    raise;

end update_user;

--
-----------------------------------
-- PUBLIC SIGNATURE
--
procedure update_user(p_user_guid in raw,
                     p_user_name in varchar2,
                     p_password in varchar2 default null,
                     p_start_date in date default null,
                     p_end_date in date default null,
                     p_description in varchar2 default null,
                     p_email_address in varchar2 default null,
                     p_fax in varchar2 default null,
                     p_expire_password in pls_integer,
                     x_password out nocopy varchar2,
                     x_result out nocopy pls_integer ) is
BEGIN
   update_user(p_user_guid,p_user_name,p_password,p_start_date,p_end_date,p_description,p_email_address,p_fax,p_expire_password,x_password,x_result,FALSE);
END update_user;
--
-------------------------------------------------------------------------------
PROCEDURE ConverToNew(n in out nocopy fnd_ldap_user.ldap_user_type,
                      o in out nocopy fnd_ldap_util.ldap_user_type )
IS
BEGIN

     o.object_name := n.user_name;



     o.uid :=getAttribute(n,'uid');
     o.sn :=getAttribute(n,'sn');
     o.cn :=getAttribute(n,'cn');
     o.userPassword :=getAttribute(n,'userPassword');
     o.telephoneNumber :=getAttribute(n,'telephoneNumber');
     o.street :=getAttribute(n,'street');
     o.postalCode :=getAttribute(n,'postalCode');
     o.physicalDeliveryOfficeName :=getAttribute(n,'physicalDeliveryOfficeName');
     o.st :=getAttribute(n,'st');
     o.l :=getAttribute(n,'l');
     o.displayName :=getAttribute(n,'displayName');
     o.givenName :=getAttribute(n,'givenName');
     o.homePhone :=getAttribute(n,'homePhone');
     o.mail :=getAttribute(n,'mail');
     o.c :=getAttribute(n,'c');
     o.facsimileTelephoneNumber :=getAttribute(n,'facsimileTelephoneNumber');
     o.description :=getAttribute(n,'description');
     o.orclisEnabled :=getAttribute(n,'orclisEnabled');
     o.orclActiveStartDate :=getAttribute(n,'orclActiveStartDate');
     o.orclActiveEndDate :=getAttribute(n,'orclActiveEndDate');
     o.orclGUID :=n.user_guid;

     if o.uid is null then o.uid:=n.user_name; END IF;
     if o.sn is null then o.sn:=n.user_name; END IF;
     if o.cn is null then o.cn:=n.user_name; END IF;

END ConverToNew;

-------------------------------------------------------------------------------
function update_user_nodes(p_ldap_session in dbms_ldap.session, p_mod_array in dbms_ldap.mod_array, p_orclguid in raw)
return pls_integer is

l_module_source   varchar2(256);
usersNode varchar2(1000);
retval pls_integer;
l_message varchar2(200);

begin
  l_module_source := G_MODULE_SOURCE || 'update_user_nodes: ';
  -- set default value to failure. change to success when user created successfully
  retval := fnd_ldap_util.G_FAILURE;
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  usersNode := fnd_ldap_util.get_dn_for_guid(p_orclguid, p_ldap_session);
--  dbms_ldap.use_exception := true;

  retval := dbms_ldap.modify_s(ld => p_ldap_session, entrydn => usersNode, modptr => p_mod_array);

  if (retval = dbms_ldap.SUCCESS) then
    retval := fnd_ldap_util.G_SUCCESS;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;
  return retval;

exception
  -- bug 4573677
  when dbms_ldap.general_error then
    l_message := translate_ldap_error(sqlerrm);
    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'error '||l_message||':'||sqlerrm);
    end if;
    fnd_message.set_name('FND',l_message);
    if (l_message='FND_SSO_PASSWORD_POLICY_ERR')
    then
       fnd_message.set_token('SQLMSG',sqlerrm);
    elsif  (l_message='FND_SSO_UNEXP_ERROR') then
              fnd_message.set_token('SQLMSG',sqlerrm);
    end if;
    return fnd_ldap_util.G_FAILURE;
  when others then
    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
    end if;
    raise;

end update_user_nodes;

function user_exists(p_user_name in varchar2)
return pls_integer is
ldap dbms_ldap.session;
  ret pls_integer;
  ret2 pls_integer;
  flag pls_integer;
begin
    ldap := fnd_ldap_util.c_get_oid_session(flag);
    ret := user_exists(ldap,p_user_name);
   fnd_ldap_util.c_unbind(ldap,flag);
    return ret;
EXCEPTION
WHEN OTHERS THEN
  fnd_ldap_util.c_unbind(ldap,flag);
  IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, G_MODULE_SOURCE || 'user_exists: ', sqlerrm);
  END IF;
  raise;
end user_exists;
--
-------------------------------------------------------------------------------
function user_exists(ldap in dbms_ldap.session,p_user_name in varchar2)
return pls_integer is

l_module_source   varchar2(256);
--result pls_integer;
  retval pls_integer;
--l_nickname varchar2(256);


  guid raw(16);

begin
  l_module_source := G_MODULE_SOURCE || 'user_exists: ';
  retval := fnd_ldap_util.G_FAILURE;
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  guid := get_user_guid(p_user_name);
  if (guid is not null ) then
       retval := fnd_ldap_util.G_SUCCESS;
  else
       retval  :=fnd_ldap_util.G_FAILURE;
   end if;


  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'retval=' || retval);
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return retval;

exception
when others then
  if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
  end if;
  raise;

end user_exists;
--
-------------------------------------------------------------------------------
-- REMOVED
-- function user_exists_with_filter(p_attr_name in varchar2, p_attr_value in varchar2) return pls_integer is

--
-------------------------------------------------------------------------------
/**
* FUNCTION comparePassword: Internal
*   Returns true if the password is the same as the stored at OiD for the given DN
* If Not, or any exceptions occurs, returns false
*   It can be used repeteadly since this comparision does not count as failed attempts.
*     Parameters:
*               ldapSession: OiD connection to use
*		user_dn: user DN
*		p_password: password
**/

function comparePassword(ldapSession in dbms_ldap.session, user_dn in varchar2 , p_password in varchar2) return boolean is
l_result pls_integer;
result boolean;
l_module_source   varchar2(256);
begin
  l_module_source := G_MODULE_SOURCE || 'comparePassword: ';
 if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'BEGIN DN:'||user_dn);
  end if;
  l_result :=  dbms_ldap.compare_s(ld => ldapSession, dn => user_dn, attr => 'userpassword', value => p_password);
  result :=  l_result= dbms_ldap.COMPARE_TRUE;
 if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    if (result)  then
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END: Yes');
    else
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END: NO');

    end if;
  end if;

  return result;
  exception when others then
     if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'Exception: '||sqlcode||' - '||sqlerrm);
    end if;
    return false;

end comparePassword;
--
-------------------------------------------------------------------------------
function validate_login(p_user_name in varchar2, p_password in varchar2) return pls_integer is

l_module_source   varchar2(256);
l_host            varchar2(256);
l_port            varchar2(256);

result            pls_integer;
retval            pls_integer;
l_user_guid       raw(256);
l_user_name       fnd_user.user_name%type;
l_enabled         boolean;
l_ldap_attr_list  ldap_attr_list;
ldapSession       dbms_ldap.session;
l_retval          pls_integer;
user_dn           varchar2(4000);
l_ldap_auth       varchar2(256);
l_db_wlt_url      varchar2(256);
l_db_wlt_pwd      varchar2(256);
l_message         varchar2(2000);

begin
  l_module_source := G_MODULE_SOURCE || 'validate_login: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;


  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Username: '||p_user_name);
  end if;

  if (p_user_name is null or p_password is null ) then
     fnd_message.set_name('FND','FND_SSO_USER_PASSWD_EMPTY');
      if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'END: refusing to validate empty username and/or password');
      end if;
      return fnd_ldap_util.G_FAILURE;
  end if;

  -- Find the DN of the linked guid
  begin
      select user_guid into l_user_guid from fnd_user where user_name=p_user_name;
      if (l_user_guid is null ) then
          if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
          then
            fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'END: Null guid in FND_USER for: '||p_user_name);
          end if;
          fnd_message.set_name('FND','FND_SSO_NOT_LINKED');
          return fnd_ldap_util.G_FAILURE;
      end if;
      exception when no_data_found then
          if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
          then
            fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END: user not found');
          end if;
          fnd_message.set_name('FND','FND_SSO_LOGIN_FAILED'); -- do no disclusre the real causeL
          return fnd_ldap_util.G_FAILURE;
       when others then
          if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
          then
            fnd_log.string(fnd_log.LEVEL_UNEXPECTED ,l_module_source, 'END with exception: '||sqlcode||'-'||sqlerrm);
          end if;
          fnd_message.set_name('FND','FND-9914'); -- unexpected error
         return fnd_ldap_util.G_FAILURE;
  end;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'GUID:'||l_user_guid);
  end if;


 -- Obtain the user DN using the GUID
   begin
    user_dn := fnd_Ldap_util.get_dn_for_guid(l_user_guid); -- may raise no data found for invalid guids
   exception when no_data_found then
          if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
          then
            fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'Guid['||l_user_guid||'] for '||p_user_name||' is not a valid guid');
          end if;
          fnd_message.set_name('FND','FND_SSO_USER_NOT_FOUND'); -- Carefull, this is INVALID GUID message, wrong acronym though
          return fnd_ldap_util.G_FAILURE;
   end;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'DN:'||user_dn);
  end if;



  l_host := fnd_preference.get(FND_LDAP_UTIL.G_INTERNAL, FND_LDAP_UTIL.G_LDAP_SYNCH, FND_LDAP_UTIL.G_HOST);
  l_port := fnd_preference.get(FND_LDAP_UTIL.G_INTERNAL, FND_LDAP_UTIL.G_LDAP_SYNCH, FND_LDAP_UTIL.G_PORT);

  if (l_host is null or l_port is null) then
          if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
          then
            fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'Invalid OiD Setup: host:'||l_host||' port:'||l_port);
          end if;

      fnd_message.set_name('FND','FND-9903'); -- OID setup is incomplete
      return fnd_ldap_util.G_FAILURE;
  end if;

    l_ldap_auth := fnd_preference.get(FND_LDAP_UTIL.G_INTERNAL, FND_LDAP_UTIL.G_LDAP_SYNCH, FND_LDAP_UTIL.G_DBLDAPAUTHLEVEL);

    if (l_ldap_auth>0) then
           l_db_wlt_url := fnd_preference.get(FND_LDAP_UTIL.G_INTERNAL, FND_LDAP_UTIL.G_LDAP_SYNCH, FND_LDAP_UTIL.G_DBWALLETDIR);
           l_db_wlt_pwd := fnd_preference.eget(FND_LDAP_UTIL.G_INTERNAL, FND_LDAP_UTIL.G_LDAP_SYNCH, FND_LDAP_UTIL.G_DBWALLETPASS, FND_LDAP_UTIL.G_LDAP_PWD);
           if (l_db_wlt_url is null or l_db_wlt_pwd is null) then
               if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
               then
                fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'Invalid Wallet Setup: authLEvel:'
                                  ||l_ldap_auth||' url:'||l_db_wlt_url||' pwd:'||l_db_wlt_url);
               end if;

               fnd_message.set_name('FND','FND-9903'); -- OID setup is incomplete
               return fnd_ldap_util.G_FAILURE;
           end if;
    else
          if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
          then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'WARNING: NON-SSL connection to OiD, check that the Net is secure');
          end if;
    end if;

   dbms_ldap.use_exception := TRUE;

  begin
    begin
       ldapSession := DBMS_LDAP.init(l_host, l_port);
       exception when dbms_ldap.init_failed then
            if (fnd_log.LEVEL_UNEXPECTED>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
            then
              fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'Cannot contact OID (init failed) at '||l_host||':'||l_port||':'||sqlcode||'-'||sqlerrm);
            end if;
            fnd_message.set_name('FND','FND_SSO_SYSTEM_NOT_AVAIL');
            return fnd_ldap_util.G_FAILURE;
          when others then
             raise;
    end;

    if (l_ldap_auth>0) then

      begin
          l_retval := dbms_ldap.open_ssl(ldapSession, 'file:'||l_db_wlt_url, l_db_wlt_pwd, l_ldap_auth);
      exception when others then
            if (fnd_log.LEVEL_UNEXPECTED>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
            then
              fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source,' Cannot establish SSL channel to OiD: '||sqlcode||'-'||sqlerrm);
            end if;

        fnd_message.set_name('FND','FND_SSO_INV_AUTH_MODE'); -- Invalid SSL authcode... it is enouggh description
        return fnd_ldap_util.G_FAILURE;
      end;

      if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Excellent!! Using SSL to contact OiD');
      end if;
    end if;


    l_retval := dbms_ldap.simple_bind_s(ldapSession, user_dn , p_password);

    -- we do analyze in extense the possible DBMS_LDAP exceptions to return accurate messages


   exception
    when dbms_ldap.general_error then
        -- here comes the explanation
        l_message := sqlerrm;
        -- first we check if the password is real,

        if (instr(l_message,':9000:')>0 )then
           fnd_message.set_name('FND','FND_SSO_PASSWORD_EXPIRED'); --Your account is locked
            if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
            then
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'OiD account password expired ');
            end if;
        elsif (instr(l_message,':9001:')>0 )then
           fnd_message.set_name('FND','FND_SSO_LOCKED'); --Your account is locked
            if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
            then
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'OiD account locked');
            end if;

        else
           if (comparePassword(ldapSession, user_dn , p_password) )then
              if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
              then
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'OiD password match but ..');
              end if;
              if (instr(l_message,':9050:')>0) then
                 if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
                 then
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'OiD account is disabled');
                 end if;
                fnd_message.set_name('FND','FND_SSO_USER_DISABLED'); --Your account is disabled
              elsif (instr(l_message,':9053:')>0) then
                if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
                 then
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'OiD account is not active: today is out of [start,end] dates ');
                 end if;
                fnd_message.set_name('FND','FND_SSO_NOT_ACTIVE'); --Your account not active. Either past end_date or future start_date
              else  --unknown reason
                  if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
                  then
                     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'cannot bind because:'||l_message);
                  end if;
                  -- maybe is not the reason, but it is enough for return , I guess
                  fnd_message.set_name('FND','FND_APPL_LOGIN_FAILED'); -- invalid username password
              end if;

           else
              if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
              then
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'OiD password did not match');
              end if;
               -- maybe is not the reason, but it is enough for return , I guess
               fnd_message.set_name('FND','FND_APPL_LOGIN_FAILED'); -- invalid username password
           end if;
        end if;
         if (fnd_log.LEVEL_PROCEDURE>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
         then
              fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END: bind error: '||l_message);
          end if;
        return fnd_ldap_util.G_FAILURE;
    when others then
         if (fnd_log.LEVEL_UNEXPECTED>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
         then
              fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'END: unexpected'||l_message);
          end if;
          return fnd_ldap_util.G_FAILURE;
   end;


   l_retval:= dbms_ldap.unbind_s(ldapSession);
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
         fnd_log.string(fnd_log.LEVEL_PROCEDURE , l_module_source, 'END: Valid Username/password');
    end if;
      return fnd_ldap_util.G_SUCCESS;

  exception when others then
         if (fnd_log.LEVEL_UNEXPECTED>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
         then
              fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'END: unexpected '||sqlcode||' - '||sqlerrm);
          end if;
           fnd_message.set_name('FND','FND-9914'); -- unexpected error
          return fnd_ldap_util.G_FAILURE;
end validate_login;


function get_user_name_from_data( dn in varchar2, data in FND_LDAP_UTIL.ldap_record_values )
  return varchar2 is
  l_realm_idx pls_integer;
  nna varchar2(2000);
  ret varchar2(4000);
BEGIN
    ret := null;
    l_realm_idx := FND_SSO_REGISTRATION.getUserRealmIndex(dn);
    if (l_realm_idx >=0 ) THEN
           nna:=fnd_sso_registration.get_realm_attribute(l_realm_idx, 'orclcommonnameattribute');
           if (data.exists(nna)) THEN
               ret := data(nna)(0);
            end if;
    END IF;
    return ret;
END get_user_name_from_data;

function get_username_from_guid(p_guid in fnd_user.user_guid%type)
    return varchar2
is
  ldapSession dbms_ldap.session;
  flag pls_integer;
  ret varchar2(4000);
  l_dn varchar2(4000);
  l_user_data FND_LDAP_UTIL.ldap_record_type;
  l_realm_idx pls_integer;
    nna varchar2(2000);

BEGIN
    ldapSession := fnd_ldap_util.c_get_oid_session(flag);

    l_dn := FND_LDAP_UTIL.get_dn_for_guid(p_guid);
    l_realm_idx := FND_SSO_REGISTRATION.getUserRealmIndex(l_dn);
    ret:= null;
    if (l_realm_idx >=0 ) THEN
           nna:=fnd_sso_registration.get_realm_attribute(l_realm_idx, 'orclcommonnicknameattribute');
          if ( FND_LDAP_UTIL.LoadLdapRecord(ldapsession, l_user_data ,p_guid,FND_LDAP_UTIL.G_GUID_KEY)) THEN
             if (l_user_data.data.exists(nna)) THEN
               ret := l_user_data.data(nna)(0);
              end if;
          end if;
    END IF;

    fnd_ldap_util.c_unbind(ldapSession,flag);
    return ret;

  EXCEPTION WHEN OTHERS THEN
        fnd_ldap_util.c_unbind(ldapSession,flag);
         if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
           fnd_log.string(fnd_log.LEVEL_EXCEPTION, G_MODULE_SOURCE||'.get_username_from_guid: ', sqlerrm);
        end if;
        raise;

END;

--
-- Search either by user_name or dn
-- Fills the record with relevant information
---
---   FUTURE: it is possible to cache , seems that the user is looked up several times in some flows.

FUNCTION SearchUser (ldap in out nocopy dbms_ldap.session ,
    p_ldap_user IN OUT nocopy fnd_ldap_user.ldap_user_type ,
    username_z in varchar2 default null,
    dn_z in varchar2 default null)  return boolean
IS

 guid varchar2(4000);
 realmDN varchar2(4000);
 dn varchar2(4000);
 l_module_source varchar2(256);
BEGIN
  l_module_source := G_MODULE_SOURCE || 'SearchUser: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' isername:'||username_z||' dn:'||dn_z);
  end if;


  if (dn_z is null and username_z is null) THEN
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END-> false ,Must suply either dn or username ');
    end if;

    return false;
  END IF;

  IF (dn_z is not null) THEN

     iF (username_z is not null) THEN
        if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
         fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END-> false , choose  dn or username, do not use both ');
        end if;
         raise TOO_MANY_ROWS  ;
     END IF;


     realmDN := FND_OID_PLUG.get_realm_from_user_dn(ldap,dn_z);

     if (realmDN is not null ) THEN
         if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
          then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' Realm->:'||realmDN);
          end if;
            IF FND_LDAP_UTIL.loadldaprecord(ldap,p_ldap_user.user_data,p_ldap_user.dn,dn_z,FND_LDAP_UTIL.G_DN_KEY) THEN
              if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
               then
                 fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' Complete the record ' );
               end if;
               ProcessLoadedLpadUserRecord(p_ldap_user,realmDN,dn_z);

              if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
              then
               fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END-> true ');
              end if;
               return true; -- loaded from dn_z
           ELSE
              return false;
           END IF;
      ELSE
         if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
          then
            fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, ' END-> Dn does not belong to any realm');
          end if;
        return false; -- no a valid user dn
      END IF;
  ELSE
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' lookup by username');
     end if;
     guid := get_user_guid(ldap,username_z,dn);
     if (guid is not null) THEN
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' Found guid:'||guid);
         end if;
         IF FND_LDAP_UTIL.loadldaprecord(ldap,p_ldap_user.user_data,p_ldap_user.dn,dn,FND_LDAP_UTIL.G_DN_KEY) THEN
               ProcessLoadedLpadUserRecord(p_ldap_user,realmDN,dn);
              if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
              then
                fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, ' END-> FOUND');
              end if;

               return true; -- loaded from username search
           ELSE
              if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
              then
                fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, ' END-> FAIL');
              end if;

              return false;
        END IF;
     else
               if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
              then
                fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, ' END-> NOT FOUND');
              end if;

      return null;
     END IF;
  END IF;


  EXCEPTION WHEN OTHERS THEN
         if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
           fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source , sqlerrm);
        end if;
        raise;


END SearchUser;

FUNCTION getEmptyLU return ldap_user_type
IS
    ret ldap_user_type;
BEGIN
   ret.user_name :=null;
   return ret;
END getEmptyLU;


--
-- Wrapper to suply an ldapSession
---
FUNCTION SearchUser (  username_z in varchar2,
    p_ldap_user IN OUT nocopy fnd_ldap_user.ldap_user_type)  return boolean
IS
ret boolean;
ldapSession dbms_ldap.session;
flag pls_integer;
l_module varchar2(200) := G_MODULE_SOURCE||'.SearchUser[public]';
BEGIN
    ldapSession := fnd_ldap_util.c_get_oid_session(flag);
    ret:= false;
    ret := SearchUser(ldapSession, p_ldap_user , username_z);

    fnd_ldap_util.c_unbind(ldapSession,flag);
    return ret;

  EXCEPTION WHEN OTHERS THEN
        fnd_ldap_util.c_unbind(ldapSession,flag);
         if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
           fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module, sqlerrm);
        end if;
        raise;
END SearchUser;

FUNCTION new_Ldap_user( user_name in FND_USER.USER_NAME%TYPE) return ldap_user_type
is
  ret ldap_user_type := getEmptyLU();
BEGIN
  ret.user_name := user_name;
  select user_id,user_name,user_guid into ret.user_id,ret.user_name, ret.user_guid
    from FND_USER WHERE
    FND_USER.USER_NAME= ret.user_name;
  return ret;
  EXCEPTION WHEN NO_DATA_FOUND then
     ret.user_id:=null;
     ret.user_guid:=null;
     return ret;
END new_Ldap_user; -- user_name

PROCEDURE TrimPermited(
    p_entity pls_integer,
    p_operation pls_integer,
    l_user IN OUT nocopy fnd_ldap_user.ldap_user_type)
IS
 attr varchar2(200);
 l_attr varchar2(200);
 x_oid pls_integer;
 x_fnd pls_integer;
 l_module_source varchar2(200) := G_MODULE_SOURCE||'.TrimPermited';

BEGIN
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin:'|| p_entity||' '|| p_operation);
  end if;
  attr := l_user.user_data.first;
  WHILE attr is not null LOOP
      l_attr := attr;
    if (p_operation = FND_LDAP_WRAPPER.G_ADD and attr='userpassword') THEN
        null;
        --BUG 9271995:" do not trim password during creation
    ELSE
    FND_SSO_REGISTRATION.is_operation_allowed(FND_LDAP_WRAPPER.G_EBIZ_TO_OID,
         p_entity,p_operation,
          l_attr,x_fnd,x_oid,l_user.user_name,l_user.realmDN);
       if (x_oid <> FND_LDAP_WRAPPER.G_SUCCESS) THEN
            if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)then
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Discard '||attr);
            end if;
            l_user.user_data.delete(attr);
       END IF;
      END IF;
      attr := l_user.user_data.next(attr);
  END LOOP;
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END');
  end if;

END TrimPermited;

FUNCTION pvt_create_user
  (p_ldap_user IN OUT nocopy fnd_ldap_user.ldap_user_type)
  RETURN pls_integer
IS
  l_module_source VARCHAR2(256);
  retval pls_integer;
  result pls_integer;
  ldapSession dbms_ldap.session;
  flag pls_integer;
  l_userDN          VARCHAR2(4000);
  l_user_guid       VARCHAR2(4000);
  l_oid_username    VARCHAR2(4000);
  l_counter         INTEGER;
  l_guid            VARCHAR2(100);
  l_link            VARCHAR2(10);
  l_profile_defined BOOLEAN;
  l_user_exists     BOOLEAN;
  l_dn_exists       BOOLEAN;
  l_username_exists BOOLEAN;
  l_rollback_ldap   BOOLEAN;
  l_uname varchar2(4000);
  l_dn varchar2(4000);
  v varchar2(4000);
  l_multi_sso  varchar2(10) := 'Y';
  l_user_linked varchar2(1) := 'N';
  l_session_flag boolean := false;
BEGIN
  l_module_source := G_MODULE_SOURCE || 'create_user: ';
  -- set default value to failure. change to success when user created successfully
  retval                      := fnd_ldap_util.G_FAILURE;
  IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  END IF;
  ldapSession := fnd_ldap_util.c_get_oid_session(flag);

  l_session_flag := true;  /* fix for bug 8271359 */

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag = true ' );
  end if;

  l_uname := p_ldap_user.user_name;
  IF SearchUser(ldapSession,p_ldap_user, username_z => l_uname) THEN
    IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User exists , checkin APPS_SSO_LINK_SAME_NAMES');
    END IF;

    -- Bug 8618800
    -- Link same names should only apply if the LDAP user is not already linked to an EBS user on this instance
    -- and APPS_SSO_ALLOW_MULTIPLE_ACCOUNTS is Disabled.  Get Site level only.
    fnd_profile.get_specific(name_z => 'APPS_SSO_ALLOW_MULTIPLE_ACCOUNTS',
                            USER_ID_Z          =>  -1,
                            RESPONSIBILITY_ID_Z => -1,
                            APPLICATION_ID_Z    => -1,
                            ORG_ID_Z            => -1,
                            val_z => l_multi_sso,
                            defined_z => l_profile_defined);

    IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Checking APPS_SSO_ALLOW_MULTIPLE_ACCOUNTS '||l_multi_sso);
    END IF;

    FND_SSO_REGISTRATION.get_user_or_site_profile(
             profile_name=>'APPS_SSO_LINK_SAME_NAMES' ,
             user_name_z => p_ldap_user.user_name ,
             val_z =>l_link,
             defined_z => l_profile_defined );

    IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Checking APPS_SSO_LINK_SAME_NAMES '||l_link);
    END IF;

    -- Get guid of LDAP User.
    l_user_guid := get_user_guid(ldapSession,l_uname,l_dn);

     if (l_user_guid is not null) then
        IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User guid found...check if already linked to an EBS user');
        END IF;

        begin
           select 'Y' into l_user_linked from fnd_user
           where user_guid = l_user_guid
           and rownum = 1;

          IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Is this OID user already linked? '||l_user_linked);
          END IF;

        exception when no_data_found then
            IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'This OID is not linked ');
            END IF;
            null;
        end;
     end if;

    IF (l_multi_sso = 'N' and l_user_linked = 'Y') then
         if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source,
                   'STOP - Allow Multiple accounts is disabled and this LDAP user is already linked to an EBS user(s)');
         end if;
        raise link_create_failed_EXCEPTION;
    END IF;

    IF l_link = 'Y' THEN
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User exists but APPS_SSO_LINK_SAME_NAMES is Enabled, adding user to subscription list');
      end if;

      retval := create_user_subscription(ldapSession, p_ldap_user.dn , p_ldap_user.user_guid);

      IF (retval <> fnd_ldap_util.G_SUCCESS) THEN
        if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source,
                   'Failed to create subscription for create_user("'||p_ldap_user.user_name
                     ||'"), user existed and  (APPS_SSO_LINK_SAME_NAMES=Enabled)');
        end if;
        raise link_create_failed_EXCEPTION;

      ELSE
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Subscription created at OiD');
          end if;

       -- Bug 8661715 Potential ldap leak
        if (l_session_flag = true) then
            if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
                fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP SESSION closing ' );
            end if;
            fnd_ldap_util.c_unbind(ldapSession,flag);
            l_session_flag := false;
        end if;
        -- Bug 8618800 - User already exists and Link Same Names is enabled - simply link the users
        return retval;

      END IF;
    ELSE -- AUTOLINK DISABLED
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'FAILED: User exists [username='||p_ldap_user.user_name||']');
      END IF;
      raise duplicate_username_EXCEPTION;
    END IF;
  ELSE
    FND_OID_PLUG.completeForCreate(ldapSession, p_ldap_user);
    l_oid_username := p_ldap_user.user_name;
    l_dn := p_ldap_user.dn ;
    IF SearchUser(ldapSession,p_ldap_user,dn_z => l_dn ) THEN
      IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'DN collsion, trying to create "'||l_oid_username||'" on dn:' || p_ldap_user.dn );
      END IF;
      raise duplicate_dn_EXCEPTION;
    END IF;
  END IF;

  --Time to verify is operation allowed for given attributes
  TrimPermited(fnd_ldap_wrapper.G_IDENTITY,fnd_ldap_wrapper.G_ADD,p_ldap_user);

  BEGIN
      v := p_ldap_user.user_data(p_ldap_user.NickName_ATT_NAME)(0);
      EXCEPTION WHEN OTHERS THEN
      v := NULL;
  END;
  if (v is null) THEN
      IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'NicknameAtrtribute not preosente in the record , Cannot create. Check configuration (prov Profiles)');
      END IF;
     raise CANNOT_CREATE_EXCEPTION;
  END IF;


  IF NOT ( attributePresent(p_ldap_user,'sn') AND attributePresent(p_ldap_user,'cn')) THEN
    IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Not all attrirbutes are present ' || ' cn='||getAttribute(p_ldap_user,'cn') || ' sn='||getAttribute(p_ldap_user,'sn') );
    END IF;
    IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END -> failed');
    END IF;
     -- Bug 8661715 Potential ldap leak
      if (l_session_flag = true) then
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP SESSION closing ' );
          end if;
          l_session_flag := false;
          fnd_ldap_util.c_unbind(ldapSession,flag);
      end if;
     RETURN fnd_ldap_util.G_FAILURE;
  END IF;

  setAttribute(p_ldap_user,'objectClass','top',true);
  setAttribute(p_ldap_user,'objectClass','inetorgperson',false);
  setAttribute(p_ldap_user,'objectClass','orcluserv2',false);

  retval := create_ldap_user(ldapSession, p_ldap_user);

  IF (retval <> fnd_ldap_util.G_SUCCESS) THEN
    if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'User creation failed');
    end if;
  ELSE
    IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP user created, now creating susbscriptions');
    END IF;
    retval := create_user_subscription(ldapSession, p_ldap_user.dn, p_ldap_user.user_guid);
    IF (retval <> fnd_ldap_util.G_SUCCESS) THEN
      IF (fnd_log.LEVEL_UNEXPECTED>= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_UNEXPECTED ,l_module_source, 'Subscription creation failed for a new user,  removing user');
      END IF;
      delete_user(ldapSession, p_ldap_user.user_guid,result);
      IF (result <>fnd_ldap_util.G_SUCCESS) THEN
        if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, ' unable to remove user ');
        end if;
      END IF;
      raise link_create_failed_EXCEPTION;
    ELSIF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Subscription creation succeeded');
    END IF;

    fnd_ldap_util.c_unbind(ldapSession,flag);
    l_session_flag := false;

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag : = false ' );
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP SESSION CLOSED NORMALLY : ' );
      end if;

    IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      IF (retval = fnd_ldap_util.G_SUCCESS) THEN
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End ->fnd_ldap_util.G_SUCCESS');
      ELSE
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End ->fnd_ldap_util.G_FAILURE');
      END IF ;
    END IF;
  END IF;
  RETURN retval;
EXCEPTION

WHEN CANNOT_CREATE_EXCEPTION THEN
  if l_session_flag = true then
       if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
           fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closing in CANNOT CREATE EXCEPTION BLOCK - START ' );
       end if;
     fnd_ldap_util.c_unbind(ldapSession,flag);

     if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closed in CANNOT CREATE EXCEPTION BLOCK - END ');
     end if;
  end if;

  IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'Error creating ldap user "' ||p_ldap_user.user_name||'" ' ||' Incorrect configuration' );
  END IF;
  fnd_message.set_name ('FND', 'FND-9903');
  RETURN fnd_ldap_util.G_FAILURE;

WHEN duplicate_dn_EXCEPTION THEN
  if l_session_flag = true then
       if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
           fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closing in Duplicate DN EXCEPTION BLOCK - START ' );
       end if;
     fnd_ldap_util.c_unbind(ldapSession,flag);

     if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closed in Duplicate DN EXCEPTION BLOCK - END ');
     end if;
  end if;

  IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'Error creating ldap user "' ||p_ldap_user.user_name||'" ' ||' DN  already exists [DN:'||p_ldap_user.dn ||']' );
  END IF;
  fnd_message.set_name ('FND', 'FND_SSO_USER_EXISTS');
  RETURN fnd_ldap_util.G_FAILURE;
WHEN duplicate_username_EXCEPTION THEN
  if l_session_flag = true then
       if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
           fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closing in Duplicate Username EXCEPTION BLOCK - START ' );
       end if;
     fnd_ldap_util.c_unbind(ldapSession,flag);

     if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closed in Duplicate username EXCEPTION BLOCK - END ');
     end if;
  end if;

  IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'Error creating ldap user "' ||p_ldap_user.user_name||'" ' ||' username  already exists [guid:'||p_ldap_user.user_guid||']' );
  END IF;
  fnd_message.set_name ('FND', 'FND_SSO_USER_EXISTS');
  RETURN fnd_ldap_util.G_FAILURE;
WHEN link_create_failed_EXCEPTION THEN
  if l_session_flag = true then
       if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
           fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closing in Link create failed EXCEPTION BLOCK - START ' );
       end if;
     fnd_ldap_util.c_unbind(ldapSession,flag);

     if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closed in Link create failed EXCEPTION BLOCK - END ');
     end if;
  end if;

  IF (fnd_log.LEVEL_EXCEPTION>= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'Error creating sunscriptions for "'||p_ldap_user.user_name||'"  guid:'||p_ldap_user.user_guid );
  END IF;
  fnd_message.set_name('FND','FND_SSO_LINK_USER_FAILED');
  RETURN fnd_ldap_util.G_FAILURE;
WHEN OTHERS THEN
  if l_session_flag = true then
       if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
           fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closing in WHEN OTHERS EXCEPTION BLOCK - START ' );
       end if;
     fnd_ldap_util.c_unbind(ldapSession,flag);

     if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closed in WHEN OTHERS EXCEPTION BLOCK - END ');
     end if;
  end if;

  IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
  END IF;
  raise;
END pvt_create_user;

PROCEDURE create_user
  (
    p_realm in out nocopy varchar2,
    p_user_name       IN VARCHAR2,
    p_password        IN VARCHAR2,
    p_start_date      IN DATE DEFAULT sysdate,
    p_end_date        IN DATE DEFAULT NULL,
    p_description     IN VARCHAR2 DEFAULT NULL,
    p_email_address   IN VARCHAR2 DEFAULT NULL,
    p_fax             IN VARCHAR2 DEFAULT NULL,
    p_expire_password IN pls_integer,
    x_user_guid OUT nocopy raw,
    x_password OUT nocopy VARCHAR2,
    x_result OUT nocopy pls_integer)
IS

  l_usr fnd_ldap_user.ldap_user_type;
  l_module_source VARCHAR2(256) := G_MODULE_SOURCE || 'create_user: ';
  l_start_date      VARCHAR2(256);
  l_end_date        VARCHAR2(656);
  l_local_login     VARCHAR2(100);
  l_profile_defined BOOLEAN;
  l_nickname        VARCHAR2(256);
  l_password        VARCHAR2(256);
  l_enabled         VARCHAR2(30);
  l_du_result pls_integer;
  l_cp_result pls_integer;
  user_name fnd_user.user_name%type;
  l_disabled_usr boolean;


BEGIN
  IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  END IF;
  if (p_realm is null) THEN
      p_realm := FND_OID_PLUG.get_realm_dn(p_user_name=>p_user_name);
  END IF;

  l_usr := new_Ldap_user(p_user_name);

  l_usr.realmDN := p_realm;

  l_enabled                := fnd_oid_util.G_ENABLED;
  IF ((p_start_date        IS NOT NULL AND p_start_date > sysdate) OR (p_end_date IS NOT NULL AND p_end_date <= sysdate)) THEN
    --usertype.orclisEnabled := fnd_oid_util.G_DISABLED;
     setAttribute(l_usr,'orclisEnabled',fnd_oid_util.G_DISABLED,true);
     l_disabled_usr := true;
  ELSE
    -- usertype.orclisEnabled := fnd_oid_util.G_ENABLED;
     setAttribute(l_usr,'orclisEnabled',fnd_oid_util.G_ENABLED,true);
     l_disabled_usr := false;
  END IF;

 /* Bug 9271995: Always create the user with the password
    By default it will remain expired
  IF (p_expire_password = fnd_ldap_util.G_TRUE) THEN
    l_password         := p_password;
  ELSE
    l_password := NULL;
  END IF;
  */
  l_password := p_password;
  /* If self service user and pending user, create the user as enabled user first and then change
  the flag to disabled after the password has been updated by proxying as that user. This is because
  we cannot proxy as a disabled user. */
  -- Bug 9398572.
  -- IF ( (l_password  IS NULL) AND l_disabled_usr ) THEN
  IF ( (p_expire_password = fnd_ldap_util.G_FALSE) AND (l_disabled_usr) ) THEN
    l_enabled              := fnd_oid_util.G_DISABLED;
    --usertype.orclisEnabled := fnd_oid_util.G_ENABLED;
    setAttribute(l_usr,'orclisEnabled',fnd_oid_util.G_ENABLED,true);
  END IF;
  -- first create user. If self service, then pass in a null password
  user_name             := p_user_name;
  --l_nickname            := fnd_ldap_util.get_orclcommonnicknameattr(user_name);
  l_nickname := FND_SSO_REGISTRATION.get_realm_attribute(p_realm,'orclCommonNickNameAttribute');
  -- usertype.uid          := p_user_name;
  -- usertype.sn           := p_user_name;
  -- usertype.cn           := p_user_name;
  -- usertype.userPassword := l_password;
  -- usertype.description  := p_description;
  setAttribute(l_usr,l_nickname,p_user_name,true);
  setAttribute(l_usr,'uid',p_user_name,true);
  setAttribute(l_usr,'sn',p_user_name,true);
  setAttribute(l_usr,'cn',p_user_name,true);
  setAttribute(l_usr,'description',p_description,true);

  -- Passing a null password fails - previously this check was done in
  -- process_attributes
  IF (l_password IS NOT NULL) then
    setAttribute(l_usr,'userPassword',l_password,true);
  END IF;

  IF (upper(l_nickname)  = fnd_ldap_util.G_MAIL) THEN
    --usertype.mail       := p_user_name;
    setAttribute(l_usr,'mail',p_user_name,true);
  ELSE
    --usertype.mail := p_email_address;
    setAttribute(l_usr,'mail',p_email_address,true);
  END IF;
  IF (upper(l_nickname)                = fnd_ldap_util.G_FACSIMILETELEPHONENUMBER) THEN
    --usertype.facsimileTelephoneNumber := p_user_name;
    setAttribute(l_usr,'facsimileTelephoneNumber',p_user_name,true);
  ELSE
    --usertype.facsimileTelephoneNumber := p_fax;
    setAttribute(l_usr,'facsimileTelephoneNumber',p_fax,true);
  END IF;
  x_result      := pvt_create_user(l_usr);
 IF (p_expire_password = fnd_ldap_util.G_TRUE) THEN
    l_password         := p_password;
  ELSE
    l_password := NULL;
  END IF;
  IF (x_result   = fnd_ldap_util.G_SUCCESS) THEN
    -- x_user_guid := get_user_guid(p_user_name);
    x_user_guid := l_usr.user_guid;
    fnd_profile.get_specific( name_z => 'APPS_SSO_LOCAL_LOGIN', user_id_z => -1, val_z => l_local_login, defined_z => l_profile_defined);
    IF (l_local_login = 'SSO') THEN
      x_password     := fnd_web_sec.EXTERNAL_PWD;
    END IF;
    -- if p_expire_psasword = false then update the user password (and password only)
    IF ( (x_result = fnd_ldap_util.G_SUCCESS) )THEN
      begin
      change_password(x_user_guid, p_user_name, p_password, p_expire_password, x_password, l_cp_result,TRUE);
      exception when others then
        delete_user(x_user_guid, x_result,true);
        raise;
      end;
      IF (l_enabled = fnd_oid_util.G_DISABLED) THEN
        disable_user(x_user_guid, p_user_name, l_du_result);
      END IF;
      IF ( (l_cp_result = fnd_ldap_util.G_FAILURE ) OR (l_du_result = fnd_ldap_util.G_FAILURE) ) THEN
        delete_user(x_user_guid, x_result);
      ELSE
        x_result := fnd_ldap_util.G_SUCCESS;
      END IF;
    END IF;
  ELSE
    fnd_message.set_name ('FND', 'FND_SSO_USER_EXISTS');
  END IF;
  IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  END IF;
EXCEPTION
WHEN OTHERS THEN
  IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
  END IF;
  raise;
END create_user;



FUNCTION getNickNameAttr( username_z in varchar2) return varchar2
IS
realm varchar2(4000);
user_rec ldap_user_type;
idx pls_integer;
l_module_source varchar2(256);
BEGIN
  l_module_source:=  G_MODULE_SOURCE ||'getNickNameAttr';
  IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
  END IF;

  if (username_z is null) THEN
    IF (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'No user given: use default');
    END IF;
     if (cache_default_nna is null) THEN
         cache_default_nna:= fnd_sso_registration.get_realm_attribute(
                         FND_SSO_REGISTRATION.getdefaultrealm,'orclCommonNickNameAttribute');
         IF (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Caching:'||cache_default_nna);
         END IF;
     END IF;
    IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END->'||cache_default_nna||' From cache');
    END IF;
     return cache_default_nna;
  END IF;


  if (cache_user_name is not null) THEN
      if (cache_user_name = username_z) THEN
         IF (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Asking again for '||cache_user_name||'?');
         END IF;
         IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END->'||cache_default_nna||' USER From cache');
         END IF;
         return cache_nna;
      ELSE
         IF (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'different user, not cached');
         END IF;
          cache_user_name:= null;
      END IF;
  END IF;
  -- ok, no options but search

  IF (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Need to locate the user at LDAP');
  END IF;
  IF (SearchUser(username_z=>username_z,p_ldap_user=>user_rec)) THEN

     IF (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User FOUND');
     END IF;
     cache_user_name := username_z;
     idx := FND_SSO_REGISTRATION.getuserrealmindex(user_rec.dn);
     cache_nna := Fnd_sso_registration.get_realm_attribute(
                         idx ,'orclCommonNickNameAttribute');
     IF (fnd_log.LEVEL_PROCEDURE>= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(fnd_log.LEVEL_PROCEDURE ,l_module_source, 'END->'||cache_nna);
     END IF;
      return cache_nna;
  ELSE
     IF (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User NOT FOUND, using default');
     END IF;
     IF (fnd_log.LEVEL_PROCEDURE>= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(fnd_log.LEVEL_PROCEDURE ,l_module_source, 'END->'||cache_default_nna);
     END IF;

     return cache_default_nna; -- do not  cache it, maybe it is about to change
  END IF;
EXCEPTION
WHEN OTHERS THEN
  IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
  END IF;
  raise;

END getNickNameAttr;


--
--
-------------------------------------------------------------------------------
/*


 API FOR LDAP_RECORD HANDLING

*/


FUNCTION locateIdx ( col in out nocopy DBMS_LDAP.STRING_COLLECTION , val in  varchar ) return pls_integer
is
  i pls_integer;
BEGIN
  if (col is null or val is null ) then
     return null;
  end if;
  i:= col.first;
  while i is not null loop
      if (VAL = col(i) ) then
            return i;
      END IF;
      i := col.next(i);
  END LOOP;
  return null;
END locateIdx;

PROCEDURE setAttribute( usr in out nocopy ldap_user_type,
       attName in varchar2,
       attVal in  varchar2,
       replaceIt in boolean default false )
IS
  old_idx pls_integer;
  lista DBMS_LDAP.STRING_COLLECTION ;
  l_name varchar2(4000) := lower(attName);
BEGIN
  if (replaceIt) then
        usr.user_data.delete(l_name);
  END IF;
  if (NOT usr.user_data.exists(l_name)  ) then
      usr.user_data(l_name)(0) := attVal;
  ELSE
     -- the attribute exists
     old_idx := locateIdx(usr.user_data(l_name),attVal);

     if (old_idx is null) THEN
       -- the value is not duplicated
       usr.user_data(l_name)(usr.user_data(l_name).count+1):= attVal;
     end if;
   END IF;
END setAttribute;

PROCEDURE deleteAttribute( usr in out nocopy ldap_user_type,
       attName in varchar2,
       attVal in varchar2 )
IS
 i pls_integer ;
  l_name varchar2(4000) := lower(attName);

BEGIN
   i := locateIdx( usr.user_data(l_name), attVal);
   while i is not null LOOP
           usr.user_data(attName).delete(i);
           -- make sure we don't left duplicates
           i := locateIdx( usr.user_data(l_name), attVal);
    end LOOP;
END deleteAttribute;


PROCEDURE deleteAttribute( usr in out nocopy ldap_user_type,
       attName in  varchar2)
is
  l_name varchar2(4000) := lower(attName);

BEGIN
  if (usr.user_data(l_name) is not null ) THEN
     usr.user_data(l_name).delete;
     usr.user_data.delete(l_name);
  END IF;
END deleteAttribute;

FUNCTION getAttribute( usr in out nocopy ldap_user_type,
       attName in varchar2,
       attValIdx in pls_integer default 0 ) return varchar2
is
BEGIN
   return usr.user_data(lower(attName))(attValIdx);
   EXCEPTION WHEN OTHERS THEN
      return null;
END getAttribute;





FUNCTION firstValue(usr in out nocopy ldap_user_type,
       attName in out nocopy varchar2,
       attValue in out nocopy varchar2,
       handle in out nocopy pls_integer ) return boolean -- false when record is empty
IS
BEGIN
  attName := null;
  attValue := null;
  handle := null;
  attName := usr.user_data.first;
  if (attName is not null) THEN
     handle := usr.user_data(attName).first;
  ELSE
     handle := -1;
     return false;
  END IF ;
  -- skip empty lists
  WHILE handle is null LOOP
    attName := usr.user_data.next(attName);
    if (attName is not null) THEN
         handle := usr.user_data(attName).first;
    ELSE
       handle := -1;
       return false;
    END IF;
  END LOOP;
  if  (handle is not null) THEN
      attValue := usr.user_data(attName)(handle);
  END IF;
  return handle is not null;
  EXCEPTION when others then
     handle:= -1;
     return false;
END firstValue;

FUNCTION nextValue(usr in out nocopy ldap_user_type,
       attName in out nocopy varchar2,
       attValue in out nocopy varchar2,
       handle in out nocopy pls_integer ) return boolean -- true if returned fields contains data
is
BEGIN
  if (handle = -1 or handle is null ) THEN
     attName := null;
     attValue :=null;
     handle := -1;
     return false;
  end if;
  handle := usr.user_data(attName).next(handle);
  WHILE handle is null LOOP
      attName := usr.user_data.next(attName);
      if (attName is null) then
           handle := -1;
           attValue := null;
           return false;
      END IF;
      handle := usr.user_data(attName).first;
  END LOOP;
  if (handle is not null) THEN
     attValue := usr.user_data(attName)(handle);
     return true;
  else
     return false;
  end if;

END nextValue;

FUNCTION attributePresent( usr in out nocopy ldap_user_type,
       attName in varchar2) return boolean
  is
  l_name varchar2(4000):= lower(attName);
BEGIN
 return usr.user_data.exists(l_name) and  usr.user_data(l_name).exists(0);

END attributePresent;

function CanSync ( p_user_id in pls_integer, p_user_name in varchar2 ) return boolean
is
  l_local_login         varchar2(30);
  l_profile_defined     boolean;
  l_to_synch boolean := false;
    l_allow_sync          varchar2(1);
   l_user_id FND_USER.user_ID%TYPE := p_user_id;
   l_user_name FND_USER.user_name%TYPE := p_user_name;
  l_module_source varchar2(200) := G_MODULE_SOURCE || 'CanSync:['||p_user_id||']';
BEGIN
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)then
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'BEGIN '||p_user_name||' userid:'||p_user_id);
  end if;
  if (l_user_id is null and l_user_name is null) THEN
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)then
              fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'END->False, try it manually ');
   end if;
    return false;
  ELSIF (l_user_id is null) THEN
     BEGIN
        select user_id into l_user_id from FND_USER where user_name =l_user_name;
        EXCEPTION WHEN OTHERS THEN
            if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)then
                fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'END->False, user not found ');
            end if;
            return false;
     END;
  ELSIF (l_user_name is null) THEN
     BEGIN
        select user_name  into l_user_name from FND_USER where user_id =l_user_id;
        EXCEPTION WHEN OTHERS THEN
           if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)then
                 fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'END->False, user not found ');
           end if;
           return false;
     END;

  ELSE
     null;
  END IF;
  fnd_profile.get_specific(
    name_z       => 'APPS_SSO_LOCAL_LOGIN',
    user_id_z    => l_user_id,
    val_z        => l_local_login,
    defined_z    => l_profile_defined);

     if (not l_profile_defined or l_local_login = fnd_oid_util.G_LOCAL)
     then
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
                    'value of APPS_SSO_LOCAL_LOGIN::  '|| l_local_login);
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
                    'Local user dont sych '|| l_user_name);
        end if;
             l_to_synch := FALSE;
     else
        fnd_profile.get_specific(name_z => 'APPS_SSO_LDAP_SYNC',
                  user_id_z => l_user_id,
                  val_z => l_allow_sync,
                  defined_z => l_profile_defined);

        if (not l_profile_defined or l_allow_sync = fnd_oid_util.G_N)
        then
             if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
             then
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
                       'value of APPS_SSO_LDAP_SYNC  '|| l_allow_sync);
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
                       'Synch profile is disabled for user ...dont sych '|| l_user_name);
             end if;
             l_to_synch := FALSE;
       else
             l_to_synch := TRUE;
        end if;
  end if;
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)then
        if (l_to_synch) THEN
             fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'END->True' );
        ELSE
              fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'END->False' );
        END IF;
  end if;

  return l_to_synch;


  EXCEPTION WHEN OTHERS THEN
      IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(fnd_log.LEVEL_EXCEPTION,  l_module_source , sqlerrm);
     END IF;
     raise;

END CanSync;

-------------------------------------------------------------------------------
PROCEDURE ProcessUpdateRec(ldap in dbms_ldap.session, dn in varchar2, upd in update_list)
IS
i pls_integer;
ma dbms_ldap.mod_array := null;
l dbms_ldap.string_collection;
m varchar2(100);
l_module_source varchar2(400);
BEGIN
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    l_module_source := G_MODULE_SOURCE || 'ProcessUpdateRec: ';
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  ma := dbms_ldap.create_mod_array(num=> upd.count);
  i:= upd.first;
  while i is not null LOOP
      l.delete;
      l(0) := upd(i).val;


     dbms_ldap.populate_mod_array(modptr => ma,
                 mod_op =>upd(i).op,
                 mod_type => upd(i).att,
                 modval => l);
      i:=upd.next(i);
  END LOOP;
  i := dbms_ldap.modify_s(ldap,dn,ma);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'END');
  end if;


  EXCEPTION WHEN OTHERS THEN
     if (ma is not null) then
         dbms_ldap.free_Mod_array(ma);
     END IF;
    IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(fnd_log.LEVEL_EXCEPTION,  l_module_source , sqlerrm);
     END IF;
     raise;
END ProcessUpdateRec;

FUNCTION isValueOf( u ldap_user_type, fld in varchar2, val in varchar2 ) return boolean
IS
i pls_integer;
n varchar2(200) := lower(fld);
l dbms_ldap.string_collection;
BEGIN
  if val is null THEN
     return false;
  END IF;
  IF u.user_data.exists(n) THEN
      L:= u.user_data(n);
      i:= l.first;
      while i is not null loop
          if (l(i) = val) THEN
              return true;
          END IF;
          i:= l.next(i);
      end loop;
  END IF;
  return false;
END isValueOf;

PROCEDURE ProcessLoadedLpadUserRecord (p_ldap_user  IN OUT nocopy fnd_ldap_user.ldap_user_type ,
    realmDN in varchar2 ,
    dn_z in varchar2 )
    IS
    realm pls_integer;
    exp1 dbms_ldap.string_collection;
    i pls_integer;
    l_module varchar2(4000):= G_MODULE_SOURCE || 'ProcessLoadedLpadUserRecord: ';
    shortest varchar2(4000);
    l_v varchar2(4000);
BEGIN

   IF (fnd_log.LEVEL_PROCEDURE>= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module, 'BEGIN');
   END IF;
   IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'in realm:'||realmDN||' dn:'||dn_z);
   END IF;
   if ( p_ldap_user.user_data.exists('orclguid') and p_ldap_user.user_data('orclguid').count>0 ) THEN
        p_ldap_user.user_guid := p_ldap_user.user_data('orclguid')(0);
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'guid(from record):'||p_ldap_user.user_guid );
      END IF;
    else
       p_ldap_user.user_guid:=null;
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'NULL Guid (?)');
      END IF;

    END IF;

   p_ldap_user.dn := dn_z;  -- no validation

      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'dn(parameter):'||dn_z);
      END IF;

   realm := FND_SSO_REGISTRATION.getUserRealmIndex(p_ldap_user.dn);
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'realmIdx(from dn)'||realm);
      END IF;

   p_ldap_user.NickName_ATT_NAME := lower(FND_SSO_REGISTRATION.get_realm_attribute(realm,'orclcommonnicknameattribute'));
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'NickNameAttribute(realm)'||p_ldap_user.NickName_ATT_NAME );
      END IF;

   p_ldap_user.realmDN := FND_SSO_REGISTRATION.find_realm(realm);
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'realmDN(resolving):'|| p_ldap_user.realmDN );
      END IF;

   exp1 := dbms_ldap.explode_dn(lower(dn_z),0);
   i :=  instr(exp1(0),'=');
   p_ldap_user.RDN_ATT_NAME:= substr(exp1(0),0,i-1) ;
   p_ldap_user.RDN_VALUE :=  substr(exp1(0),i+1) ;
   p_ldap_user.parent_DN := '';
   for i in 1 .. exp1.last -- skip the first
   LOOP
      p_ldap_user.parent_DN := p_ldap_user.parent_DN || ',' || exp1(i);
    END LOOP;
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'parentDN(from parameter dn)'||p_ldap_user.parent_DN);
      END IF;
   -- The username calculation:: Can by tricky
   -- case 0: No value
   IF ( p_ldap_user.user_data(p_ldap_user.NickName_ATT_NAME).count=0) THEN
       p_ldap_user.user_name := null;
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'nna has no value: username=NULL');
      END IF;
   -- case 1: only one value in the nickanme attribute
   ELSIF ( p_ldap_user.user_data(p_ldap_user.NickName_ATT_NAME).count=1) THEN
       p_ldap_user.user_name := p_ldap_user.user_data(p_ldap_user.NickName_ATT_NAME)(0);
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'user_name(unique nna in record):'||p_ldap_user.user_name);
      END IF;
   ELSE
    -- case 2: several values, let's lookup on FND_USER to see if there is a match
     i := p_ldap_user.user_data(p_ldap_user.NickName_ATT_NAME).first;
     p_ldap_user.user_id:= null;
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, ' several nna , lookinf for a best match');
      END IF;
     shortest := null;
     p_ldap_user.user_name :=null;
     while i is not null loop
        l_v:=p_ldap_user.user_data(p_ldap_user.NickName_ATT_NAME)(i);


        BEGIN
            IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                   fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, '  testing nna:'||l_v);
            END IF;

            select user_id into p_ldap_user.user_id from fnd_user where
                   user_name=l_v and user_guid=p_ldap_user.user_guid;

            IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, ' there it is user_uid:'||p_ldap_user.user_id);
            END IF;
            if (p_ldap_user.user_name is null) THEN
                  p_ldap_user.user_name := l_v;
                  IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, ' tyring with '||l_v);
                  END IF;
            ELSIF (length(p_ldap_user.user_name)>length(l_v)) THEN
                  p_ldap_user.user_name:= l_v;
                  IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, ' Better with shorter : '||l_v);
                  END IF;
            END IF;

            i:= p_ldap_user.user_data(p_ldap_user.NickName_ATT_NAME).next(i);

            --- multilink will be a disaster if a user with serveral nna matches several Ebz users
          EXCEPTION WHEN NO_DATA_FOUND THEN
                    i:= p_ldap_user.user_data(p_ldap_user.NickName_ATT_NAME).next(i);

        END;
     end loop;
     if (p_ldap_user.user_name is null) THEN
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, '  bad luck, using the first one then '||p_ldap_user.user_data(p_ldap_user.NickName_ATT_NAME)(0));
      END IF;

       p_ldap_user.user_name := p_ldap_user.user_data(p_ldap_user.NickName_ATT_NAME)(0);
     END IF;
   END IF;

  EXCEPTION WHEN OTHERS THEN
     IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(fnd_log.LEVEL_EXCEPTION,  l_module , sqlerrm);
     END IF;
     raise;

END ProcessLoadedLpadUserRecord;


function CanPopulate( attr in varchar2 , user_name in varchar2 , realm in varchar2) return boolean
IS
    x_fnd pls_integer;
    x_oid pls_integer;
    vAttr varchar2(200) := attr;
BEGIN

    FND_SSO_REGISTRATION.is_operation_allowed (
                  p_direction => FND_LDAP_WRAPPER.G_EBIZ_TO_OID,
                  p_entity => FND_LDAP_WRAPPER.G_IDENTITY,
                  p_operation => FND_LDAP_WRAPPER.G_ADD,
                  p_attribute => vAttr,
                  x_fnd_user => x_fnd,
                  x_oid => x_oid,
                  p_user_name => user_name,
                  p_realm_dn => realm);
    return x_oid=FND_LDAP_WRAPPER.G_SUCCESS;

END CanPopulate;

function CanUpdate( attr in varchar2 , user_name in varchar2 , realm in varchar2, x_user_creation in boolean default FALSE ) return boolean
IS
   x_fnd pls_integer;
   x_oid pls_integer;
   vAttr varchar2(200) := attr;
BEGIN
   IF (x_user_creation) THEN
	return CanPopulate(attr,user_name,realm);
   ELSE
   FND_SSO_REGISTRATION.is_operation_allowed (
                  p_direction => FND_LDAP_WRAPPER.G_EBIZ_TO_OID,
                  p_entity => FND_LDAP_WRAPPER.G_IDENTITY,
                  p_operation => FND_LDAP_WRAPPER.G_MODIFY,
                  p_attribute => vAttr,
                  x_fnd_user => x_fnd,
                  x_oid => x_oid,
                  p_user_name => user_name,
                  p_realm_dn => realm);
   return x_oid=FND_LDAP_WRAPPER.G_SUCCESS;
    END IF;

END CanUpdate;


end fnd_ldap_user;

/
