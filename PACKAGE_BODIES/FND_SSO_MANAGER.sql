--------------------------------------------------------
--  DDL for Package Body FND_SSO_MANAGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SSO_MANAGER" as
/* $Header: fndssob.pls 120.5.12010000.5 2010/03/19 15:59:35 ctilley ship $ */

G_MODULE_SOURCE  constant varchar2(80) := 'fnd.plsql.sso.fnd_sso_manager.';

-- The parameters errCode and errText can
-- be manually added to the Login url for additional processing.
--
-- we no longer use this method. Please refer bug 4043786
-- Instead we use the function with 3 parameters */
--function getLoginUrl(requestUrl    in      varchar2 ,
--               cancelUrl     in      varchar2 )
--return varchar2 is
-- l_requestUrl          varchar2(2024);
-- l_cancelUrl          varchar2(2024);
-- cs_anchor                varchar2(2000);
-- cj_anchor                varchar2(2000);
--begin
--
--	fnd_profile.get(name => 'APPS_SERVLET_AGENT',
--                     val => cs_anchor);
--	fnd_profile.get(name => 'APPS_FRAMEWORK_AGENT',
--                     val => cj_anchor);
--	l_requestUrl := requestUrl;
--	l_cancelUrl := cancelUrl;
--
--	if l_requestUrl is NULL then
--		l_requestUrl := 'APPSHOMEPAGE';
--	end if;
--
--	if l_cancelUrl is NULL then
--		l_cancelUrl := FND_WEB_CONFIG.trail_slash(cs_anchor)|| 'oracle.apps.fnd.sso.AppsLogin' ;
--	end if;
--
--	return FND_WEB_CONFIG.trail_slash(cs_anchor)|| 'oracle.apps.fnd.sso.AppsLogin?requestUrl=' || wfa_html.conv_special_url_chars(l_requestUrl) || '&' || 'cancelUrl=' || wfa_html.conv_special_url_chars(l_cancelUrl);
--
--end;

procedure synch_user_from_LDAP(p_user_name in fnd_user.user_name%type) is
  l_module_source   varchar2(256);
  l_result  pls_integer;
  l_user_name fnd_user.user_name%type;
begin
  l_module_source := G_MODULE_SOURCE || 'synch_user_from_LDAP';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  l_user_name  := p_user_name;
  fnd_ldap_wrapper.synch_user_from_LDAP(p_user_name => l_user_name,
                                       p_result => l_result);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_result: '||l_result);
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
 when others then
 raise;
 if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
 then
  fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
end if;
end synch_user_from_LDAP;

/*
 API returns true if profile APPS_SSO_USER_CREATE_UPDATE is ENABLED
*/
function isUserCreateUpdateAllowed
  return boolean is

  l_apps_sso_user_create_update  varchar2(10);
  l_module_source   varchar2(256);
  l_returnVal boolean;

begin
  l_returnVal := false;
  l_module_source := G_MODULE_SOURCE || 'isUserCreateUpdateAllowed: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  fnd_profile.get(name => 'APPS_SSO_USER_CREATE_UPDATE',
                   val => l_apps_sso_user_create_update);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
           'APPS_SSO_USER_CREATE_UPDATE: ' || l_apps_sso_user_create_update);
  end if;

 if (l_apps_sso_user_create_update = 'N')
  then
    l_returnVal := FALSE;
  else
    l_returnVal := TRUE;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return l_returnVal;

exception
  when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
    return false;
end;

/*
 Overloaded getLoginUrl function with an additional parameter
 of langCode
 */
function getLoginUrl(requestUrl    in      varchar2 ,
               cancelUrl     in      varchar2,
	       langCode in varchar2)
return varchar2 is
 l_requestUrl          varchar2(2024);
 l_cancelUrl          varchar2(2024);
 l_langCode          varchar2(2024);
 cs_anchor                varchar2(2000);
 cj_anchor                varchar2(2000);
begin

	fnd_profile.get(name => 'APPS_SERVLET_AGENT',
                     val => cs_anchor);
	fnd_profile.get(name => 'APPS_FRAMEWORK_AGENT',
                     val => cj_anchor);
	l_requestUrl := requestUrl;
	l_cancelUrl := cancelUrl;
	l_langCode := langCode;

	if l_requestUrl is NULL then
		l_requestUrl := 'APPSHOMEPAGE';
	end if;

	if l_cancelUrl is NULL then
		-- Bug 5369045: user servlet name
		l_cancelUrl := FND_WEB_CONFIG.trail_slash(cs_anchor)|| 'AppsLogin' ;
	end if;

	if l_langCode is NOT NULL then
		-- Bug 5369045: user servlet name
		return FND_WEB_CONFIG.trail_slash(cs_anchor)|| 'AppsLogin?requestUrl=' || wfa_html.conv_special_url_chars(l_requestUrl) || '&' || 'cancelUrl=' || wfa_html.conv_special_url_chars(l_cancelUrl) ||
		'&' || 'langCode=' || wfa_html.conv_special_url_chars(l_langCode);
	end if;

		-- Bug 5369045: user servlet name
	return FND_WEB_CONFIG.trail_slash(cs_anchor)|| 'AppsLogin?requestUrl=' || wfa_html.conv_special_url_chars(l_requestUrl) || '&' || 'cancelUrl=' || wfa_html.conv_special_url_chars(l_cancelUrl);

end;

function getLogoutUrl(returnUrl	in	varchar2 )
return varchar2 is
cs_anchor                varchar2(2000);
l_returnUrl		 varchar2(2000);
l_audit_level      VARCHAR2(1);
l_login_id        NUMBER;
l_session_id      NUMBER;
begin

 -- fix for bug 3241092
         l_session_id := icx_sec.getsessioncookie; ---get session_id from the cookie

         select login_id into l_login_id
         from  ICX_SESSIONS
         where  SESSION_ID = l_session_id;

         l_audit_level:=fnd_profile.value('SIGNONAUDIT:LEVEL');
         if (l_audit_level is not null) and ( l_login_id is not null)
         then
              fnd_signon.audit_end(l_login_id); -- end audit session and resps.
         end if;
 --
	l_returnUrl := returnUrl;
	fnd_profile.get(name => 'APPS_SERVLET_AGENT',
                     val => cs_anchor);
	if l_returnUrl is NULL then
		-- Bug 5369045: user servlet name
		return FND_WEB_CONFIG.trail_slash(cs_anchor)|| 'AppsLogout';
	end if;

		-- Bug 5369045: user servlet name
	return FND_WEB_CONFIG.trail_slash(cs_anchor)|| 'AppsLogout?returnUrl=' || wfa_html.conv_special_url_chars(l_returnUrl);

end;


function modplsql_currentURL return varchar2 is
l_urlrequested          varchar2(2024);
begin
      l_urlrequested :=
      lower(owa_util.get_cgi_env('REQUEST_PROTOCOL'))||'://'||
      owa_util.get_cgi_env('SERVER_NAME')||':'||
      owa_util.get_cgi_env('SERVER_PORT')||
      owa_util.get_cgi_env('SCRIPT_NAME')||
      owa_util.get_cgi_env('PATH_INFO');
      if owa_util.get_cgi_env('QUERY_STRING') is not null then
        l_urlrequested := l_urlrequested  ||'?'|| owa_util.get_cgi_env('QUERY_STRING');
      end if;

      return l_urlrequested;
end;

function isPasswordChangeable(username in varchar2) return boolean
is
pValue             varchar2(50);
l_user_id          number;
l_profile_defined  boolean;
l_pwd_changable    boolean;
l_attribute        varchar2(40);
l_fnd_user         pls_integer;
l_oid              pls_integer;
l_apps_sso         varchar2(50);
l_module_source    varchar2(256);
p_user_guid        raw(256);


-- userNotFound exception;  Bug4420380 Changed exception from local to global
begin

  -- Bug 7700617: Changed API to reflect changes made in 11i for bug 5651619.
  -- Added logging to API

  l_module_source := G_MODULE_SOURCE || 'isPasswordChangeable';


  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  begin
    select user_id, user_guid into l_user_id, p_user_guid
    from fnd_user where user_name = upper(username);
  exception when others then
     p_user_guid := null;
     l_user_id := -1;
   end;


    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Retrieved user_id and user_guid for user '||username);
    end if;

  if (p_user_guid is not null) then

        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User: '||username||' is linked' );
        end if;

	      FND_PROFILE.GET_SPECIFIC(name_z => 'APPS_SSO_LOCAL_LOGIN',
                                user_id_z => l_user_id,
                                responsibility_id_z => -1,
                                application_id_z => -1,
                                org_id_z => -1,
                                val_z => pValue,
                                defined_z => l_profile_defined);

        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'APPS_SSO_LOCAL_LOGIN for' ||username||' is '||pValue);
        end if;


        if (pValue is null or not l_profile_defined) then
            l_pwd_changable := true;
        elsif pvalue = 'LOCAL' then
            l_pwd_changable := true;
        elsif (pvalue = 'BOTH' or  pvalue = 'SSO') then
            l_attribute := 'userpassword';

            -- Bug 9405673 - passing user_id to ensure user level profile value
            -- for APPS_SSO_LDAP_SYNC is used if set; otherwise use Site
            fnd_ldap_wrapper.is_operation_allowed(p_realm=>fnd_oid_plug.getRealmDN(username),
                                             p_direction => fnd_ldap_wrapper.G_EBIZ_TO_OID,
	                                     p_entity => fnd_ldap_wrapper.G_IDENTITY,
	                                     p_operation => fnd_ldap_wrapper.G_MODIFY,
                                             p_user_id => l_user_id,
	                                     x_attribute => l_attribute,
	                                     x_fnd_user => l_fnd_user,
                                             x_oid => l_oid);

           if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
               fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User is an SSO user.  Verifying password can be synched');
           end if;

	         if (l_oid = fnd_ldap_wrapper.G_SUCCESS)
           then
              if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User is an SSO user and password can be synched');
              end if;

               l_pwd_changable := true;
           else
               if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
                   fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User is an SSO user but password cannot be synched');
               end if;

              l_pwd_changable := false;
           end if;

        end if;

  else
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'User is not linked - password can be changed');
        end if;

        l_pwd_changable := true;
  end if;

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
   end if;

	return l_pwd_changable;

	exception
    when no_data_found  THEN
	     	raise userNotFound;
    when others then
        if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
	          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END -EXCEPTION '||sqlerrm);
        end if;

        return false;

end;

function get_ldap_user_name(p_user_name in fnd_user.user_name%type)
return varchar2 is

 l_module_source   varchar2(256);
 l_result  varchar2(4000);
begin
 l_module_source := G_MODULE_SOURCE || 'get_ldap_user_name';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  l_result :=  fnd_ldap_wrapper.get_ldap_user_name(p_user_name => p_user_name);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_result: '||l_result);
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;
	return l_result;
end get_ldap_user_name;

end FND_SSO_MANAGER;

/
