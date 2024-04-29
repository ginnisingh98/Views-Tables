--------------------------------------------------------
--  DDL for Package Body FND_LDAP_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LDAP_WRAPPER" as
/* $Header: AFSCOLWB.pls 120.43.12010000.17 2017/06/16 18:18:21 rsantis ship $ */
--
-- Start of Package Globals

  G_MODULE_SOURCE  constant varchar2(80) := 'fnd.plsql.oid.fnd_ldap_wrapper.';

-- End of Package Globals
--
-------------------------------------------------------------------------------
  initreg boolean := false;
  init boolean := false;
  ssoenabled boolean := false;
  registered boolean := false;
  ldapenabled boolean := false;
  registration pls_integer := G_NO_REGISTRATION;
  function trim_attribute(p_attr in varchar2) return varchar2;
--
-------------------------------------------------------------------------------

function CanSync( p_userid in pls_integer, p_user_name in varchar2)  return pls_integer
is
l_res pls_integer;
begin
   execute immediate
       ' declare r pls_integer:=0; BEGIN if ( FND_LDAP_USER.CanSync(null,:1) ) then r:=1; END IF ; :2 := r; END;'
        using in p_user_name, out l_res;
   if (l_res=1) then
     return G_SUCCESS;
   else
     return G_FAILURE;
   end if;

   exception when others then
      return G_FAILURE;
end CanSync;

--
-------------------------------------------------------------------------------
function get_ldap_user_name(p_user_name in fnd_user.user_name%type) return varchar2 is

l_module_source   varchar2(256);
l_result varchar2(4000);
l_user_guid fnd_user.user_guid%type;
l_found boolean;

l_apps_sso	    varchar2(50);

l_profile_defined   boolean;
l_orclappname	    varchar2(256);
l_obj_name	    varchar2(256);
plsql_block	    varchar2(500);
sso_registration_failure exception;
l_sso_version	    varchar2(10);
l_allow_sync	      varchar2(1);

 cursor cur_fnd_users is
    select user_guid
      from fnd_user
     where user_name = upper(p_user_name);
begin
		l_module_source := G_MODULE_SOURCE || 'get_ldap_user_name ';
		if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
			then
				fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
		end if;

/* We should not need LDAP sync enabled.  If the user is linked we should be able to retrieve the username.
   fnd_profile.get_specific(name_z => 'APPS_SSO_LDAP_SYNC',
			   USER_ID_Z	       => -1,
			   RESPONSIBILITY_ID_Z => -1,
			   APPLICATION_ID_Z    => -1,
			   ORG_ID_Z	       => -1,
			   val_z => l_allow_sync,
			   defined_z => l_profile_defined);

  if (l_profile_defined and l_allow_sync = 'Y') then

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'APPS_SSO_LDAP_SYNC enabled.');
    end if;
*/

   if (fnd_ldap_util.isLdAPIntegrationEnabled) then
      ldapenabled := true;
   else
      ldapenabled := false;
   end if;


		if (ldapenabled) then
			if (not init) then
				init := true;

	      if (fnd_ldap_util.isLDAPAccessible) then
			    	registered := true;
  			end if;
	  end if;


			if (registered) then
	        l_found := false;
					open cur_fnd_users;
				  fetch cur_fnd_users into l_user_guid;
	        l_found := cur_fnd_users%found;

						if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
							then
								fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source,
									 'L_user_guid: '||l_user_guid);
						end if;

	  			if (l_found)
					then
						plsql_block :=
								'begin :result := fnd_oid_util.get_oid_nickname(:1); end;';
									execute immediate plsql_block using out l_result, l_user_guid;
					else
						if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
							then
								fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source,
									 'no such user in FND_USER: '||p_user_name);
						end if;
						l_result := null;
					end if;
				  close cur_fnd_users;

		  else -- if (!registered)
				  if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
							then
								fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'LDAP not registered');
					end if;
					l_result := null;
			end if;

		else -- if (!ldapenabled), simply return null
			if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
				then
					fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
					      'LDAP Integration is not enabled, returning true w/o changing the user name');
			end if;
			l_result := null;
		end if;

/*  LDAP SYNC should not be checked.
  else -- APPS_SSO_LDAP_SYNC not enabled.

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'APPS_SSO_LDAP_SYNC not enabled.');
    end if;

    l_result := null;

  end if;
*/
		if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
			then
				fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
		end if;
    return l_result;
exception
 when sso_registration_failure then
	if (cur_fnd_users%isopen)
    then
      close cur_fnd_users;
  end if;
	if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
  	l_result := null;
		fnd_message.set_name ('FND', 'FND_SSO_OID_REG_ERROR');
		return l_result;
 when others then
	if (cur_fnd_users%isopen)
    then
      close cur_fnd_users;
  end if;
	if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
	l_result := null;
	return l_result;
end get_ldap_user_name;
--
-------------------------------------------------------------------------------
procedure change_user_name(p_user_guid in raw,
			  p_old_user_name in varchar2,
			  p_new_user_name in varchar2,
			  x_result out nocopy pls_integer) is

  l_module_source   varchar2(256);
  plsql_block	      varchar2(500);
  l_fnd_user	     pls_integer;
  l_oid 	     pls_integer;
  l_attribute	    varchar2(4000);
  l_realm varchar2(4000);

begin
  l_module_source := G_MODULE_SOURCE || 'change_user_name: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  l_attribute := 'user_name';
   l_realm :=get_realm_dn(p_user_guid=>p_user_guid);
  is_operation_allowed(p_realm=> l_realm, p_direction => G_EBIZ_TO_OID,
		       p_entity => G_IDENTITY,
		       p_operation => G_MODIFY,
		       x_attribute => l_attribute,
		       x_fnd_user => l_fnd_user,
		       x_oid => l_oid);

  if (l_oid = G_SUCCESS) then

    plsql_block :=
      'begin fnd_ldap_user.change_user_name(:1, :2, :3, :4); end;';
    execute immediate plsql_block using p_user_guid, p_old_user_name, p_new_user_name, out x_result;

  else -- l_oid = G_FAILURE

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_oid is false');
    end if;
    x_result := l_fnd_user;

  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
  when registration_failure_exception then
    fnd_message.set_name ('FND', 'FND_SSO_OID_REG_ERROR');
    x_result := G_FAILURE;
  when others then
    fnd_message.set_name ('FND', 'FND_SSO_UNEXP_ERROR');
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    x_result := G_FAILURE;

end change_user_name;
--
-------------------------------------------------------------------------------
procedure synch_user_from_LDAP(p_user_name in fnd_user.user_name%type
			      , p_result out nocopy pls_integer) is
  l_module_source   varchar2(256);
  l_apps_sso	      varchar2(50);
  l_profile_defined   boolean;
  l_orclappname       varchar2(256);
  l_obj_name	      varchar2(256);
  plsql_block	      varchar2(500);
  l_sso_version	      varchar2(10);
  l_allow_sync		varchar2(1);

begin
  l_module_source := G_MODULE_SOURCE || 'synch_user_from_LDAP';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

-- Should user level be checked?
fnd_profile.get_specific(name_z => 'APPS_SSO_LDAP_SYNC',
			   USER_ID_Z	       => -1,
			   RESPONSIBILITY_ID_Z => -1,
			   APPLICATION_ID_Z    => -1,
			   ORG_ID_Z	       => -1,
			   val_z => l_allow_sync,
			   defined_z => l_profile_defined);

  if (l_profile_defined and l_allow_sync = 'Y') then

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'APPS_SSO_LDAP_SYNC enabled.');
    end if;

/*  Bug 21882506 - decouple LDAP sync from authentication - part of External/Internal auth support
 fnd_profile.get_specific(
    name_z	=> 'APPS_SSO',
    val_z      => l_apps_sso,
    defined_z	 => l_profile_defined);

  if (l_apps_sso = 'PORTAL') OR (l_apps_sso = 'SSWA') then
    ssoenabled := false;
  else
    ssoenabled := true;
  end if;


  if (ssoenabled) then
  */

   if (fnd_ldap_util.isLdAPIntegrationEnabled) then
      ldapenabled := true;
   else
      ldapenabled := false;
   end if;

  if (ldapenabled) then
    if (not init) then
      init := true;

     /* Move this to a central API
      select object_name into l_obj_name from all_objects
      where object_name = 'DBMS_LDAP' and object_type = 'PACKAGE BODY'
      and status = 'VALID' and owner = 'SYS';
      l_orclappname := get_orclappname;
      -- no exception => everything is ok
      registered := true;
    end if;
    */

    if (fnd_ldap_util.isLDAPAccessible) then
        registered := true;
    end if;
  end if;

    if (registered) then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP Integration is enabled and is registered.');
      end if;

      plsql_block := 'begin fnd_oid_util.synch_user_from_LDAP(:1, :2); end;';
      execute immediate plsql_block using in p_user_name, out p_result;
    else
      p_result := G_FAILURE;
    end if;
  else -- if (!ldapenabled), simply return success without updating TCA
    p_result := G_SUCCESS;
  end if;

  else -- APPS_SSO_LDAP_SYNC not enabled.

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'APPS_SSO_LDAP_SYNC not enabled.');
    end if;

    p_result := G_SUCCESS;

  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
  when others then
    fnd_message.set_name ('FND', 'OID');
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    p_result := G_FAILURE;
end synch_user_from_LDAP;
--
-------------------------------------------------------------------------------
procedure create_user(p_user_name in varchar2,
		     p_password in varchar2,
		     p_start_date in date default sysdate,
		     p_end_date in date default null,
		     p_description in varchar2 default null,
		     p_email_address in varchar2 default null,
		     p_fax in varchar2 default null,
		     p_expire_password in pls_integer,
		     x_user_guid out nocopy raw,
		     x_password out nocopy varchar2,
		     x_result out nocopy pls_integer) is

  l_module_source   varchar2(256);
  plsql_block	    varchar2(500);
  l_fnd_user	    pls_integer;
  l_oid 	    pls_integer;
  l_attribute	    varchar2(4000);
  l_allowed	    boolean;
  l_password	    varchar2(400);
  l_start_date	    date;
  l_end_date	    date;
  l_description     varchar2(400);
  l_email_address   varchar2(256);
  l_fax 	    varchar2(50);
 l_realm varchar2(4000);
  l_err_code varchar2(200);
  l_tmp_str varchar2(4000);

begin

  l_module_source := G_MODULE_SOURCE || 'create_user: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

/*
* Removed userpassword
*/
  l_attribute := 'orclactivestartdate,orclactiveenddate,description,mail,facsimiletelephonenumber';
/* Not sure about this.
* Some times the realm cannot be determined until the user is actually created.
*
*/
    /*  Check if LDAP integration is enabled and the instance is registered */
     if (fnd_ldap_util.isLDAPIntegrationEnabled) then
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP Integration is enabled');
        end if;

        ldapenabled := true;

        if (fnd_ldap_util.isLDAPAccessible) then
            if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
                fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP is registered');
            end if;
            registered := true;
        else
            if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
                fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP is not registered correctly');
            end if;
            registered := false;
        end if;

     else
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP Integration is disabled');
        end if;
        ldapenabled := false;
     end if;

  if  (registered) then

  l_realm := get_realm_dn(p_user_name=>p_user_name);

  is_operation_allowed(p_realm=>l_realm,p_direction => G_EBIZ_TO_OID,
		       p_entity => G_IDENTITY,
		       p_operation => G_ADD,
		       x_attribute => l_attribute,
		       x_fnd_user => l_fnd_user,
		       x_oid => l_oid);

  if (l_oid = G_SUCCESS) then
  /* don't handle userpassword now
     l_allowed := is_present(p_attribute => 'userpassword', p_template_attr_list => l_attribute);
     if (l_allowed and p_password<>FND_WEB_SEC.EXTERNAL_PWD and p_password<>'EXTERNAL' ) then
       l_password := p_password;
     else
       l_password := null;
     end if;
 */
     l_password := p_password;

     l_allowed := is_present(p_attribute => 'orclactivestartdate', p_template_attr_list => l_attribute);
     if (l_allowed) then
       l_start_date := p_start_date;
     else
       l_start_date := null;
     end if;

     l_allowed := is_present(p_attribute => 'orclactiveenddate', p_template_attr_list => l_attribute);
     if (l_allowed) then
       l_end_date := p_end_date;
     else
       l_end_date := null;
     end if;

     l_allowed := is_present(p_attribute => 'description', p_template_attr_list => l_attribute);
     if (l_allowed) then
       l_description := p_description;
     else
       l_description := null;
     end if;

     l_allowed := is_present(p_attribute => 'mail', p_template_attr_list => l_attribute);
     if (l_allowed) then
       l_email_address := p_email_address;
     else
       l_email_address := null;
     end if;

     l_allowed := is_present(p_attribute => 'facsimiletelephonenumber', p_template_attr_list => l_attribute);
     if (l_allowed) then
       l_fax := p_fax;
     else
       l_fax := null;
     end if;

     plsql_block :=
       'begin fnd_ldap_user.create_user(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11,:12); end;';
     execute immediate plsql_block using in out  l_realm, p_user_name,	l_password,
     l_start_date, l_end_date, l_description, l_email_address, l_fax, p_expire_password,
     out x_user_guid, out x_password, out x_result;

  else -- l_oid is G_FAILURE

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_oid is false');
    end if;
    x_result := l_fnd_user;

  end if; -- l_oid

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Not registered or LDAP Integration is disabled');
  end if;
end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
  when registration_failure_exception then
    fnd_message.set_name ('FND', fnd_ldap_errm.FND_SSO_OID_REG_ERROR);
    x_result := G_FAILURE;
  when others then

    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;

    l_tmp_str := sqlerrm;
    l_err_code := fnd_ldap_errm.translate_ldap_errors(l_tmp_str);
    fnd_message.set_name ('FND', l_err_code);

    if l_err_code = fnd_ldap_errm.FND_SSO_LDAP_APPSDN_PWD_EXPIRD then
        fnd_message.set_token('USER', l_tmp_str);
        app_exception.raise_exception;
    elsif l_err_code = fnd_ldap_errm.FND_SSO_LDAP_PWD_POLICY_ERR then
        l_tmp_str := replace(l_tmp_str, 'Your', p_user_name);
        fnd_message.set_token('REASON', l_tmp_str);
        app_exception.raise_exception;
    else
        fnd_message.set_name ('FND', fnd_ldap_errm.FND_SSO_UNEXP_ERROR);
        x_result := G_FAILURE;
    end if;

    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'l_err_code :' || l_err_code ||', l_tmp_str :' || l_tmp_str);
    end if;

end create_user;
--
-------------------------------------------------------------------------------
procedure change_password(p_user_guid in raw,
			 p_user_name in varchar2,
			 p_new_pwd in varchar2,
			 p_expire_password in pls_integer,
	 		 x_password out nocopy varchar2,
			 x_result out nocopy pls_integer) is

  l_module_source   varchar2(256);
  plsql_block	      varchar2(500);
  l_fnd_user	     pls_integer;
  l_oid 	     pls_integer;
  l_attribute	    varchar2(4000);
  l_new_pwd varchar2(4000);
 l_realm varchar2(4000);

begin
  l_module_source := G_MODULE_SOURCE || 'change_password: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  l_attribute := 'userpassword';
  l_realm := get_realm_dn(p_user_guid=>p_user_guid,p_user_name=>p_user_name);

  is_operation_allowed(p_realm=>l_realm,p_direction => G_EBIZ_TO_OID,
		       p_entity => G_IDENTITY,
		       p_operation => G_MODIFY,
		       x_attribute => l_attribute,
		       x_fnd_user => l_fnd_user,
		       x_oid => l_oid);

  if (l_oid = G_SUCCESS) then
     if (p_new_pwd<>FND_WEB_SEC.EXTERNAL_PWD and p_new_pwd<>'EXTERNAL' ) then
       l_new_pwd := p_new_pwd;
     else
       l_new_pwd := null;
     end if;

    plsql_block :=
      'begin fnd_ldap_user.change_password(:1, :2, :3, :4, :5, :6); end;';
    execute immediate plsql_block using p_user_guid, p_user_name, l_new_pwd, p_expire_password, out x_password, out x_result;

  else -- l_oid = G_FAILURE

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Password Sync Not Allowed');
    end if;
    x_result := l_fnd_user;

  end if; -- l_oid

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
  when registration_failure_exception then
    fnd_message.set_name ('FND', 'FND_SSO_OID_REG_ERROR');
    x_result := G_FAILURE;
  when others then
    fnd_message.set_name ('FND', 'FND_SSO_UNEXP_ERROR');
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    x_result := G_FAILURE;

end change_password;
--
-------------------------------------------------------------------------------
procedure delete_user(p_user_guid in fnd_user.user_guid%type,
		     x_result out nocopy pls_integer) is

  l_module_source   varchar2(256);
  plsql_block	      varchar2(500);
  l_fnd_user	     pls_integer;
  l_oid 	     pls_integer;
  l_attribute	    varchar2(4000);
 l_realm varchar2(4000);

begin
  l_module_source := G_MODULE_SOURCE || 'delete_user: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;
  l_realm := get_realm_dn(p_user_guid=>p_user_guid);

  is_operation_allowed(p_realm=>l_realm,p_direction => G_EBIZ_TO_OID,
		       p_entity => G_IDENTITY,
		       p_operation => G_DELETE,
		       x_attribute => l_attribute,
		       x_fnd_user => l_fnd_user,
		       x_oid => l_oid);

  if (l_oid = G_SUCCESS) then

    plsql_block :=
      'begin fnd_ldap_user.delete_user(:1, :2); end;';
    execute immediate plsql_block using p_user_guid, out x_result;

  else -- l_oid = G_FAILURE

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_oid is false');
    end if;
    x_result := l_fnd_user;

  end if; -- l_oid

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
  when registration_failure_exception then
    fnd_message.set_name ('FND', 'FND_SSO_OID_REG_ERROR');
    x_result := G_FAILURE;
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    x_result := G_FAILURE;

end delete_user;
--
-------------------------------------------------------------------------------
procedure link_user(p_user_name in varchar2,
		     x_user_guid out nocopy raw,
		     x_password out nocopy varchar2,
		     x_result out nocopy pls_integer) is

  l_module_source   varchar2(256);
  plsql_block	      varchar2(500);
  l_fnd_user	     pls_integer;
  l_oid 	     pls_integer;
  l_attribute	    varchar2(4000);
 l_realm varchar2(4000);

begin

  l_module_source := G_MODULE_SOURCE || 'link_user: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;
  l_realm := get_realm_dn(p_user_name=>p_user_name);

  is_operation_allowed(p_realm=>l_realm,p_direction => G_EBIZ_TO_OID,
		       p_entity => G_SUBSCRIPTION,
		       p_operation => G_ADD,
		       x_attribute => l_attribute,
		       x_fnd_user => l_fnd_user,
		       x_oid => l_oid);

  if (l_oid = G_SUCCESS) then

    plsql_block :=
      'begin fnd_ldap_user.link_user(:1, :2, :3, :4); end;';
    execute immediate plsql_block using p_user_name,
    out x_user_guid, out x_password, out x_result;

  else -- l_oid is G_FAILURE

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_oid id false');
    end if;
    x_result := l_fnd_user;

  end if; -- l_oid

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
  when registration_failure_exception then
    fnd_message.set_name ('FND', 'FND_SSO_OID_REG_ERROR');
    x_result := G_FAILURE;
  when others then
    fnd_message.set_name ('FND', 'FND_SSO_UNEXP_ERROR');
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    x_result := G_FAILURE;

end link_user;
--
-------------------------------------------------------------------------------
procedure unlink_user(p_user_guid in fnd_user.user_guid%type,
		      p_user_name in varchar2,
		      x_result out nocopy pls_integer) is

  l_module_source   varchar2(256);
  plsql_block	      varchar2(500);
  l_fnd_user	     pls_integer;
  l_oid 	     pls_integer;
  l_attribute	    varchar2(4000);
 l_realm varchar2(4000);

begin

  l_module_source := G_MODULE_SOURCE || 'unlink_user: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;
  l_realm := get_realm_dn(p_user_guid=>p_user_guid,p_user_name=>p_user_name);

  is_operation_allowed(p_realm=>l_realm,p_direction => G_EBIZ_TO_OID,
		       p_entity => G_SUBSCRIPTION,
		       p_operation => G_DELETE,
		       x_attribute => l_attribute,
		       x_fnd_user => l_fnd_user,
		       x_oid => l_oid);

  if (l_oid = G_SUCCESS) then

    plsql_block :=
      'begin fnd_ldap_user.unlink_user(:1, :2, :3); end;';
    execute immediate plsql_block using p_user_guid, p_user_name,
    out x_result;

  else -- l_oid is G_FAILURE

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_oid is false');
    end if;
    x_result := l_fnd_user;

  end if; -- l_oid

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
  when registration_failure_exception then
    fnd_message.set_name ('FND', 'FND_SSO_OID_REG_ERROR');
    x_result := G_FAILURE;
  when others then
    fnd_message.set_name ('FND', 'FND_SSO_UNEXP_ERROR');
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    x_result := G_FAILURE;

end unlink_user;
--
-------------------------------------------------------------------------------
function user_exists(p_user_name in varchar2) return pls_integer is

  l_module_source   varchar2(256);
  l_apps_sso	      varchar2(50);
  l_profile_defined   boolean;
  l_orclappname       varchar2(256);
  l_obj_name	      varchar2(256);
  plsql_block	      varchar2(500);
  retval	      pls_integer;
  sso_registration_failure exception;
  l_sso_version	      varchar2(10);
  l_allow_sync		varchar2(1);

begin
  l_module_source := G_MODULE_SOURCE || 'user_exists: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

 /*  LDAP SYNC should not be checked.  If the user is linked and instance is integrated with LDAP and the integration
     enabled then the user should be accessible
   fnd_profile.get_specific(name_z => 'APPS_SSO_LDAP_SYNC',
			   USER_ID_Z	       => -1,
			   RESPONSIBILITY_ID_Z => -1,
			   APPLICATION_ID_Z    => -1,
			   ORG_ID_Z	       => -1,
			   val_z => l_allow_sync,
			   defined_z => l_profile_defined);

  if (l_profile_defined and l_allow_sync = 'Y') then

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'APPS_SSO_LDAP_SYNC enabled.');
    end if;

  Bug 21882506 - decouple LDAP sync from authentication - part of External/Internal auth support
  fnd_profile.get_specific(
    name_z	=> 'APPS_SSO',
    val_z      => l_apps_sso,
    defined_z	 => l_profile_defined);

  if (l_apps_sso = 'PORTAL') OR (l_apps_sso = 'SSWA') then
    ssoenabled := false;
  else
    ssoenabled := true;
  end if;

  if (ssoenabled) then
 */

   if (fnd_ldap_util.isLdAPIntegrationEnabled) then
      ldapenabled := true;
   else
      ldapenabled := false;
   end if;

  if (ldapenabled) then

    if (not init) then
      init := true;

  /*  Move to central API
      select object_name into l_obj_name from all_objects
      where object_name = 'DBMS_LDAP' and object_type = 'PACKAGE BODY'
      and status = 'VALID' and owner = 'SYS';
      l_orclappname := get_orclappname;
      -- no exception => everything is ok
   */

        if (fnd_ldap_util.isLDAPAccessible) then
            registered := true;
        end if;
   end if;

    if (registered) then
      plsql_block :=
      'begin :result := fnd_ldap_user.user_exists(:1); end;';
      execute immediate plsql_block using out retval, p_user_name;
    else
      raise sso_registration_failure;
    end if;
  else -- if (!ssoenabled), simply return failure
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
	fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP not enabled, returning false w/o querying OID user');
    end if;
    retval := G_FAILURE;
    fnd_message.set_name ('FND', 'FND_SSO_NOT_ENABLED');
  end if;

/*  LDAP SYNC should not be checked.
  else -- APPS_SSO_LDAP_SYNC not enabled.

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'APPS_SSO_LDAP_SYNC not enabled.');
    end if;

    retval := G_FAILURE;
    fnd_message.set_name ('FND', 'FND_SSO_NOT_ENABLED');

  end if;
*/

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return retval;

exception
  when sso_registration_failure then
    fnd_message.set_name ('FND', 'FND_SSO_OID_REG_ERROR');
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    raise;
  when no_data_found then
    fnd_message.set_name ('FND', 'FND_SSO_OID_REG_ERROR');
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    raise;
  when others then
    fnd_message.set_name ('FND', 'FND_SSO_UNEXP_ERROR');
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    raise;

end user_exists;
--
-------------------------------------------------------------------------------
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
		     x_result out nocopy pls_integer) is

  l_module_source   varchar2(256);
  plsql_block	      varchar2(500);
  l_fnd_user	     pls_integer;
  l_oid 	     pls_integer;
  l_attribute	    varchar2(4000);
  l_allowed	    boolean;
  l_password	    varchar2(400);
  l_start_date	    date;
  l_end_date	    date;
  l_description     varchar2(400);
  l_email_address   varchar2(256);
  l_fax 	    varchar2(50);
 --l_realm varchar2(4000);
 l_err_code varchar2(200);
 l_tmp_str varchar2(4000);

begin
  l_module_source := G_MODULE_SOURCE || 'update_user: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  l_attribute := 'userpassword,orclactivestartdate,orclactiveenddate,description,mail,facsimiletelephonenumber';
  --l_realm := get_realm_dn(p_user_guid=>p_user_guid,p_user_name=>p_user_name);

  -- Bug  8926610
  l_oid := CanSync(null,p_user_name);

  if (l_oid = G_SUCCESS) then

     l_allowed := is_present(p_attribute => 'userpassword', p_template_attr_list => l_attribute);
     if (l_allowed and p_password<>FND_WEB_SEC.EXTERNAL_PWD and p_password<>'EXTERNAL' )  then
       l_password := p_password;
     else
       l_password := null;
     end if;

     l_allowed := is_present(p_attribute => 'orclactivestartdate', p_template_attr_list => l_attribute);
     if (l_allowed) then
       l_start_date := p_start_date;
     else
       l_start_date := null;
     end if;

     l_allowed := is_present(p_attribute => 'orclactiveenddate', p_template_attr_list => l_attribute);
     if (l_allowed) then
       l_end_date := p_end_date;
     else
       l_start_date := null;
     end if;

     l_allowed := is_present(p_attribute => 'description', p_template_attr_list => l_attribute);
     if (l_allowed) then
       l_description := p_description;
     else
       l_description := null;
     end if;

     l_allowed := is_present(p_attribute => 'mail', p_template_attr_list => l_attribute);
     if (l_allowed) then
       l_email_address := p_email_address;
     else
       l_email_address := null;
     end if;

     l_allowed := is_present(p_attribute => 'facsimiletelephonenumber', p_template_attr_list => l_attribute);
     if (l_allowed) then
       l_fax := p_fax;
     else
       l_fax := null;
     end if;

    plsql_block :=
      'begin fnd_ldap_user.update_user(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11); end;';
    execute immediate plsql_block using p_user_guid, p_user_name, l_password, l_start_date, l_end_date, l_description, l_email_address, l_fax, p_expire_password, out x_password, out x_result;

  else -- l_oid is G_FAILURE

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_oid is false');
    end if;
    x_result := l_fnd_user;

  end if; -- l_oid

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
  when registration_failure_exception then
    fnd_message.set_name ('FND', fnd_ldap_errm.FND_SSO_OID_REG_ERROR);
    x_result := G_FAILURE;
  when others then

    l_tmp_str := sqlerrm;
    l_err_code := fnd_ldap_errm.translate_ldap_errors(l_tmp_str);
    fnd_message.set_name ('FND', l_err_code);

    if l_err_code = fnd_ldap_errm.FND_SSO_LDAP_APPSDN_PWD_EXPIRD then
        fnd_message.set_token('USER', l_tmp_str);
        app_exception.raise_exception;
    elsif l_err_code = fnd_ldap_errm.FND_SSO_LDAP_PWD_POLICY_ERR then
        l_tmp_str := replace(l_tmp_str, 'Your', p_user_name);
        fnd_message.set_token('REASON', l_tmp_str);
        app_exception.raise_exception;
    else
        fnd_message.set_name ('FND', fnd_ldap_errm.FND_SSO_UNEXP_ERROR);
        x_result := G_FAILURE;
    end if;

    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'l_err_code :' || l_err_code ||', l_tmp_str :' || l_tmp_str);
    end if;

end update_user;
--
-------------------------------------------------------------------------------
function validate_login(p_user_name in varchar2, p_password in varchar2) return boolean is

  l_module_source   varchar2(256);
  l_apps_sso	      varchar2(50);
  l_profile_defined   boolean;
  l_orclappname       varchar2(256);
  l_obj_name	      varchar2(256);
  plsql_block	      varchar2(500);
  retval	      boolean;
  sso_registration_failure exception;
  result	      pls_integer;
  l_sso_version	      varchar2(10);
  l_allow_sync		varchar2(1);

begin
  l_module_source := G_MODULE_SOURCE || 'validate_login: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

 /*  LDAP SYNC should not be checked.
   fnd_profile.get_specific(name_z => 'APPS_SSO_LDAP_SYNC',
			   USER_ID_Z	       => -1,
			   RESPONSIBILITY_ID_Z => -1,
			   APPLICATION_ID_Z    => -1,
			   ORG_ID_Z	       => -1,
			   val_z => l_allow_sync,
			   defined_z => l_profile_defined);

  if (l_profile_defined and l_allow_sync = 'Y') then

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'APPS_SSO_LDAP_SYNC enabled.');
    end if;


  Bug 21882506 - decouple LDAP sync from authentication - part of External/Internal auth support
   fnd_profile.get_specific(
    name_z	=> 'APPS_SSO',
    val_z      => l_apps_sso,
    defined_z	 => l_profile_defined);

  if (l_apps_sso = 'PORTAL') OR (l_apps_sso = 'SSWA') then
    ssoenabled := false;
  else
    ssoenabled := true;
  end if;

  if (ssoenabled) then
 */

  if (fnd_ldap_util.isLdAPIntegrationEnabled) then
     ldapenabled := true;
  else
     ldapenabled := false;
  end if;

	if (ldapenabled) then
    if (not init) then
      init := true;

  /*  Move to central API
      select object_name into l_obj_name from all_objects
      where object_name = 'DBMS_LDAP' and object_type = 'PACKAGE BODY'
      and status = 'VALID' and owner = 'SYS';
      l_orclappname := get_orclappname;
      -- no exception => everything is ok
  */

    if (fnd_ldap_util.isLDAPAccessible) then
      registered := true;
    end if;
   end if;

    if (registered) then
      plsql_block :=
	'begin :result := fnd_ldap_user.validate_login(:1, :2); end;';
	execute immediate plsql_block using out result, p_user_name, p_password;
	if (result = G_SUCCESS) then
	  retval := true;
	else
	  retval := false;
	end if;
    else
      raise sso_registration_failure;
    end if;
  else -- if (!ldapenabled), simply return false
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP not enabled, returning false');
    end if;
      retval := false;
      fnd_message.set_name ('FND', 'FND_SSO_NOT_ENABLED');
  end if;

/*  LDAP SYNC should not be checked.
  else -- APPS_SSO_LDAP_SYNC not enabled.

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'APPS_SSO_LDAP_SYNC not enabled.');
    end if;

      retval := false;
      fnd_message.set_name ('FND', 'FND_SSO_NOT_ENABLED');

  end if;
*/

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return retval;

exception
  when sso_registration_failure then
    fnd_message.set_name ('FND', 'FND_SSO_OID_REG_ERROR');
    raise;
  when no_data_found then
    fnd_message.set_name ('FND', 'FND_SSO_OID_REG_ERROR');
    raise;

end validate_login;
--
-------------------------------------------------------------------------------
function get_orclappname return varchar2 is

l_module_source   varchar2(256);
orclAppName varchar2(256);
sso_registration_failure exception;

begin
  l_module_source := G_MODULE_SOURCE || 'get_orclappname: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  select fnd_preference.get('#INTERNAL','LDAP_SYNCH', 'USERNAME')
  into orclAppName
  from dual;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return orclAppName;

exception
  when no_data_found then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
  raise;
end get_orclappname;
--
-------------------------------------------------------------------------------
procedure is_operation_allowed(p_realm in varchar2,p_direction in pls_integer default G_EBIZ_TO_OID,
			       p_entity in pls_integer,
			       p_operation in pls_integer,
                               p_user_name in varchar2,
                               p_user_id in number,
			       x_attribute in out nocopy varchar2,
			       x_fnd_user out nocopy pls_integer,
			       x_oid out nocopy pls_integer) is

l_module_source		varchar2(256);
l_apps_sso		varchar2(50);
l_profile_defined	boolean;
l_orclappname		varchar2(256);
l_obj_name		varchar2(256);
plsql_block		varchar2(500);
sso_registration_failure	exception;
l_registration		pls_integer;
l_sso_version		varchar2(10);
l_allow_sync	      varchar2(1);

-- Bug 9405673 - added for user_id and user_name args to get APPS_SSO_LDAP_SYNC
-- at user level.  Default to site if both are null
l_user_id  FND_USER.user_ID%TYPE := -1;


begin
  l_module_source := G_MODULE_SOURCE || 'is_operation_allowed: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  x_fnd_user := G_SUCCESS;
  x_oid := G_FAILURE;

  if (p_user_id is not null) then

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'user_id: '||to_char(p_user_id));
    end if;

      l_user_id := p_user_id;
  elsif (p_user_id is null and p_user_name is not null) then

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'user_name: '||p_user_name||' now get userid');
    end if;

    begin
      select user_id into l_user_id
      from fnd_user
      where user_name = p_user_name;
    exception when others then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'User not found..use site');
      end if;
           null;
    end;
  end if;

fnd_profile.get_specific(name_z => 'APPS_SSO_LDAP_SYNC',
			   USER_ID_Z	       => l_user_id,
			   RESPONSIBILITY_ID_Z => -1,
			   APPLICATION_ID_Z    => -1,
			   ORG_ID_Z	       => -1,
			   val_z => l_allow_sync,
			   defined_z => l_profile_defined);

  if (l_profile_defined and l_allow_sync = 'Y') then

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'APPS_SSO_LDAP_SYNC enabled.');
    end if;

    get_registration(x_registration => l_registration);
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
	      ,		'Registration :: '||l_registration);
    end if;

    if (l_registration = FND_LDAP_WRAPPER.G_VALID_REGISTRATION) then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
	fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
		      ,'Valid registration');
      end if;
      plsql_block :=
      'begin fnd_sso_registration.is_operation_allowed(:1, :2, :3, :4, :5, :6,null,:7); end;';
      execute immediate plsql_block using p_direction, p_entity, p_operation, in out x_attribute, out x_fnd_user, out x_oid,in p_realm;

    elsif(l_registration = FND_LDAP_WRAPPER.G_INVALID_REGISTRATION) then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
		fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
		      ,'Invalid registration');
      end if;
      raise registration_failure_exception;
    elsif(l_registration = FND_LDAP_WRAPPER.G_NO_REGISTRATION) then
	if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
		fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
		      ,'No registration');
	end if;
	x_fnd_user := G_SUCCESS;
	x_oid := G_FAILURE;
    end if;

  else -- APPS_SSO_LDAP_SYNC not enabled.

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'APPS_SSO_LDAP_SYNC not enabled.');
    end if;

  end if;

if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
     'out values x_fnd_user: '||x_fnd_user||' x_oid: '||x_oid);
  end if;


  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
	 then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when registration_failure_exception then
    fnd_message.set_name ('FND', 'FND_SSO_OID_REG_ERROR');
    x_fnd_user := G_FAILURE;
    x_oid := G_FAILURE;
    raise registration_failure_exception;
  when no_data_found then
    fnd_message.set_name ('FND', 'FND_SSO_OID_REG_ERROR');
    x_fnd_user := G_FAILURE;
    x_oid := G_FAILURE;
    raise registration_failure_exception;
  when others then
    fnd_message.set_name ('FND', 'FND_SSO_UNEXP_ERROR');
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    raise;
end is_operation_allowed;
--
-------------------------------------------------------------------------------
procedure is_operation_allowed(p_realm in varchar2,p_operation in pls_integer,
			       x_fnd_user out nocopy pls_integer,
			       x_oid out nocopy pls_integer) is

l_module_source						varchar2(256);
l_apps_sso								varchar2(50);
l_profile_defined					boolean;
l_orclappname							varchar2(256);
l_obj_name								varchar2(256);
plsql_block								varchar2(500);
sso_registration_failure	exception;

begin
  l_module_source := G_MODULE_SOURCE || 'is_operation_allowed: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  x_fnd_user := G_SUCCESS;
  x_oid := G_FAILURE;

  /* Bug 21882506 - decouple LDAP sync from authentication - part of External/Internal auth support
    fnd_profile.get_specific(
    name_z	=> 'APPS_SSO',
    val_z      => l_apps_sso,
    defined_z	 => l_profile_defined);

  if (l_apps_sso = 'PORTAL') OR (l_apps_sso = 'SSWA') then
    ssoenabled := false;
  else
    ssoenabled := true;
  end if;

  if (ssoenabled) then
*/

  if (fnd_ldap_util.isLdAPIntegrationEnabled) then
      ldapenabled := true;
  else
      ldapenabled := false;
  end if;

	if (ldapenabled) then

		if (not init) then
      init := true;

  /*  Move to central API
      select object_name into l_obj_name from all_objects
      where object_name = 'DBMS_LDAP' and object_type = 'PACKAGE BODY'
      and status = 'VALID' and owner = 'SYS';
      l_orclappname := get_orclappname;
      -- no exception => everything is ok
   */

    if (fnd_ldap_util.isLDAPAccessible) then
      registered := true;
    end if;
  end if;

    if (registered) then
      plsql_block :=
	 'begin fnd_sso_registration.is_operation_allowed(:1, :2, :3,null,:4); end;';
	execute immediate plsql_block using p_operation, out x_fnd_user, out x_oid,in p_realm;
	  else
			if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
				then
					fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP is enabled but improper regitration');
			end if;
	-- In this case the OID operation should be allowed so that it fail
				-- subsequently causing the FND operation also fail
			raise sso_registration_failure;
		end if;

	else -- if (!ldapenabled), simply return false
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'SSO not enabled, returning false');
    end if;
      x_fnd_user := G_SUCCESS;
      x_oid := G_FAILURE;
      fnd_message.set_name ('FND', 'FND_SSO_NOT_ENABLED');
  end if;

 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
     'out values x_fnd_user: '||x_fnd_user||' x_oid: '||x_oid);
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
	 then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when sso_registration_failure then
    fnd_message.set_name ('FND', 'FND_SSO_OID_REG_ERROR');
    x_fnd_user := G_SUCCESS;
    x_oid := G_SUCCESS;
  when no_data_found then
    fnd_message.set_name ('FND', 'FND_SSO_OID_REG_ERROR');
    x_fnd_user := G_SUCCESS;
    x_oid := G_SUCCESS;
  when others then
    fnd_message.set_name ('FND', 'FND_SSO_UNEXP_ERROR');
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
		raise;
end is_operation_allowed;
--
-------------------------------------------------------------------------------
procedure get_registration(x_registration out nocopy pls_integer) is

	l_module_source			varchar2(256);
	l_apps_sso	    varchar2(50);
	l_profile_defined   boolean;
	l_return_value			pls_integer;
	l_sso_enabled				boolean;

	l_orclappname	    varchar2(256);
	l_obj_name	    varchar2(256);
	plsql_block	    varchar2(500);
	l_ldapenabled   boolean;

begin
  l_module_source := G_MODULE_SOURCE || 'get_registration ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

 /* Bug 21882506 - decouple LDAP sync from authentication - part of External/Internal auth support
  fnd_profile.get_specific(
    name_z	=> 'APPS_SSO',
    val_z      => l_apps_sso,
    defined_z	 => l_profile_defined);

  if (l_apps_sso = 'PORTAL') OR (l_apps_sso = 'SSWA')
		then
			l_sso_enabled := false;
  else
		  l_sso_enabled := true;
  end if;
  */

  if (fnd_ldap_util.isLdAPIntegrationEnabled) then
      l_ldapenabled := true;
   else
      l_ldapenabled := false;
   end if;



  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'SSO enabled ::');
  end if;


  if (l_ldapenabled) then
  	if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)	then
  		fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP profile is enabled');
  	end if;

	if (not initreg) then
		initreg := true;

          /* Bug 26264283:  No need to check this after Bug 21882506 .
	  * select object_name into l_obj_name from all_objects
	  * where object_name = 'DBMS_LDAP' and object_type = 'PACKAGE BODY'
	  * and status = 'VALID' and owner = 'SYS';
           */

		l_orclappname := get_orclappname;
		if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
			fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_orclappname :: '||l_orclappname);
		end if;

		if(l_orclappname IS NULL) then
			registration := G_INVALID_REGISTRATION;
		else
			registration := G_VALID_REGISTRATION;
		end if;

				  -- no exception => everything is ok
		x_registration := registration;
	else
		if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)	then
			fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Already initialized');
		end if;

		x_registration := registration;
	end if;
  else
	if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
		fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'SSO profile not set');
	end if;

	x_registration := G_NO_REGISTRATION;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)	then
	fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
	when no_data_found then
		registration := G_INVALID_REGISTRATION;
		x_registration := registration;

	when others then
		fnd_message.set_name ('FND', 'FND_SSO_UNEXP_ERROR');
	    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
	      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
	    end if;
	    raise;
end get_registration;

function is_present(p_attribute in varchar2, p_template_attr_list  in varchar2) return boolean is

is_present boolean := false;
l_module_source   varchar2(256);
num pls_integer := 0;
st pls_integer := 0;
en pls_integer := 0;
l_str varchar2(4000) := '';
l_tmp  varchar2(4000);
l_tmp2 varchar2(4000);
l_template_attr_list varchar2(4000);

begin
  l_module_source := G_MODULE_SOURCE || 'is_present: ';
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;
  l_template_attr_list :=trim_attribute(p_template_attr_list);
  st := 1;
  en := INSTR(l_template_attr_list,',', st, 1);


   if(en <= 0)
    then
	  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
	   then
	    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Only one attribute en = '||en);
	  end if;
	  l_tmp := l_template_attr_list;
	  if(upper(p_attribute) = upper(l_tmp) ) then
		is_present := true;
	  end if;
   else

	  WHILE (en > 0)
	  LOOP
		l_tmp := SUBSTR(l_template_attr_list, st, en-st);
		l_tmp := trim(l_tmp);
		if(upper(p_attribute) = upper(l_tmp) ) then
			is_present := true;
		end if;
		st := en+1;
		en := INSTR(l_template_attr_list,',', st, 1);
		num := num+1;
		if(en = 0) then
			l_tmp := SUBSTR(l_template_attr_list, st, length(l_template_attr_list)-st+1);
			l_tmp := trim(l_tmp);
			if(upper(p_attribute) = upper(l_tmp) ) then
				is_present := true;
			end if;
		end if;

	  END LOOP;
   end if;

  return is_present;

end is_present;

function trim_attribute(p_attr in varchar2) return varchar2 is

l_tmp  varchar2(4000);
begin

    l_tmp := trim(p_attr);
    l_tmp := ltrim(l_tmp, '(');
    l_tmp := rtrim(l_tmp, ')');
    l_tmp := trim(l_tmp);

    return l_tmp;

end trim_attribute;

/*
* Bug 6249845
* Wrapper for FND_OID_PLUG.get_realm_dn
*/
function get_realm_dn( p_user_guid in raw default null, p_user_name in varchar2 default null)
   return varchar2
is
  l_module_source varchar2(4000);
  l_result varchar2(4000);
  plsql_block varchar2(100);
BEGIN
     l_module_source := G_MODULE_SOURCE || 'get_realm_dn';
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
		fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
     end if;
     if (oid_synchronization_enabled) then
	 plsql_block := 'begin :1 := fnd_oid_plug.get_realm_dn(:2, :3); end;';
	execute immediate plsql_block using out l_result, p_user_guid,p_user_name;
     else
	l_result := null;
     end if;
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
		fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'END->'||l_result);
     end if;
     return l_result;



END get_realm_dn;

function oid_synchronization_enabled return boolean
is
  l_module_source varchar2(4000);
  l_result boolean;
  l_profile_defined   boolean;
  l_allow_sync		varchar2(1);
  registration pls_integer;

begin
     l_module_source := G_MODULE_SOURCE || 'oid_synchronization_enabled ';
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
		fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
     end if;
     get_registration(registration);

     if ( registration=G_VALID_REGISTRATION) then

	   fnd_profile.get_specific(name_z => 'APPS_SSO_LDAP_SYNC',
				 USER_ID_Z	       => -1,
				 RESPONSIBILITY_ID_Z => -1,
				 APPLICATION_ID_Z    => -1,
				 ORG_ID_Z	     => -1,
 				val_z => l_allow_sync,
 				defined_z => l_profile_defined);

	    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
		 if (l_profile_defined) then
		    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source ,'SITE APPS_SSO_LDAP_SYNC='||l_allow_sync );
		 else
		    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source ,'APPS_SSO_LDAP_SYNC not defined' );
		 end if;
	    end if;
	    l_result := l_profile_defined and l_allow_sync = 'Y';
     else
	   l_result := false;
	   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
		if(registration = FND_LDAP_WRAPPER.G_INVALID_REGISTRATION) then
		    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source ,'Invalid registration');
		elsif(registration = FND_LDAP_WRAPPER.G_NO_REGISTRATION) then
		    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source ,'No registration');
		else
		    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source ,'Unknown returning status:'||registration);
		end if;
	   end if;
     end if;


       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
	    if (l_result) then
		fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'END-> TRUE');
	    else
		fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'END-> FALSE');
	    end if;
       end if;
       return l_result;
       exception when others then
	   if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
		 fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source ,'Unexpected exception '||sqlerrm);
		 raise;
	   end if;

end oid_synchronization_enabled;

procedure unlink_ebiz_user(p_user_name in varchar2) is

l_module_source varchar2(256);
l_user_id fnd_user.user_id%type;
l_user_name fnd_user.user_name%type;
l_user_guid fnd_user.user_guid%type;
l_local_login varchar2(10);
l_profile_defined boolean;
l_result pls_integer;

l_del_prof boolean;

cursor ebiz_users is
    select user_name, user_id, user_guid
    from fnd_user
    where user_name like upper(p_user_name)
    and user_guid is not null;

begin

  l_module_source := G_MODULE_SOURCE||'unlink_ebiz_user';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  if (p_user_name is not null) then

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User name was passed - get linked users');
       end if;

      open ebiz_users;

   LOOP
      fetch ebiz_users into l_user_name, l_user_id, l_user_guid;
      exit when ebiz_users%NOTFOUND;

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Unlink user '||l_user_name);
      end if;

       update fnd_user
       set user_guid = null
       where user_name = l_user_name and user_guid is not null;

       fnd_profile.get_specific(
         name_z  => 'APPS_SSO_LOCAL_LOGIN',
         user_id_z => l_user_id,
         val_z  => l_local_login,
         defined_z => l_profile_defined);

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Got local login profile '||l_local_login);
      end if;

       if (l_local_login = 'SSO' or  l_local_login = 'BOTH') then
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
          then
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Local login is SSO - delete user level profile');
          end if;

          l_del_prof := fnd_profile.delete(
            x_name => 'APPS_SSO_LOCAL_LOGIN',
            x_level_name => 'USER',
            x_level_value => l_user_id);
       end if;

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Delete APPS_SSO_LDAP_SYNC user level profile');
      end if;

       l_del_prof := fnd_profile.delete(
            x_name => 'APPS_SSO_LDAP_SYNC',
            x_level_name => 'USER',
            x_level_value => l_user_id);

      -- Attempt to unlink the user in OID
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Attempt to unlink user in OID');
      end if;

       begin
          unlink_user(l_user_guid,l_user_name,l_result);
       exception when others then
            null;
       end;

       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User has been unlinked - flush the wf_attribute_cache for user_name: '||l_user_name);
      end if;

       wf_entity_mgr.flush_cache('USER', l_user_name);

    END LOOP;
       close ebiz_users;

       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Done unlinking FND users');
      end if;

 END IF;

 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
      end if;

exception when others then
     if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'Failed to unlink user');
      end if;
end unlink_ebiz_user;

end fnd_ldap_wrapper;


/
