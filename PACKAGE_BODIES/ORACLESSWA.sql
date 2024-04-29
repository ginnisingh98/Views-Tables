--------------------------------------------------------
--  DDL for Package Body ORACLESSWA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ORACLESSWA" as
/* $Header: ICXSSWAB.pls 120.1.12010000.7 2013/06/05 17:57:38 fskinner ship $ */

    procedure bookmarkthis (icxtoken in varchar2,
                            p        in varchar2) is

    l_session_id number;
    l_text varchar2(2000);
    l_parameters    icx_on_utilities.v80_table;
    l_resp_appl_id number;
    l_responsibility_id number;
    l_security_group_id number;
    l_function_id number;
    l_url varchar2(4000);

/*
    l_function_type varchar2(30);
    l_menu_id number;
l_validate          boolean;
l_error_message varchar2(2000);
err_mesg varchar2(240);
err_num number;
l_user_id               number;
l_org_id                number;
l_multi_org_flag        varchar2(30);
l_profile_defined       boolean;
e_session_invalid       exception;
*/

    begin

      l_session_id := icx_portlet.validateSessionPart1;

      l_text := icx_call.decrypt4(icxtoken, l_session_id);

      icx_on_utilities.unpack_parameters(l_text,l_parameters);

      l_resp_appl_id := nvl(l_parameters(1),178);
      l_responsibility_id := l_parameters(2);
      l_security_group_id := l_parameters(3);
      l_function_id := l_parameters(4);

      if P is null
      then
        l_text := null;
      else
        l_text := icx_call.decrypt4(P,l_session_id);
      end if;

  -- 2802333 nlbarlow
  l_url := icx_portlet.createExecLink(p_application_id => l_resp_appl_id,
                       p_responsibility_id => l_responsibility_id,
                       p_security_group_id => l_security_group_id,
                       p_function_id => l_function_id,
                       p_parameters => P,
                       p_url_only => 'Y');

  owa_util.mime_header('text/html', FALSE);

  owa_util.redirect_url(l_url);

  owa_util.http_header_close;

/*
      select TYPE
      into   l_function_type
      from   FND_FORM_FUNCTIONS
      where  FUNCTION_ID = l_function_id;

      l_menu_id := l_parameters(5);

      select multi_org_flag
      into   l_multi_org_flag
      from   fnd_product_groups
      where  rownum < 2;

      if l_multi_org_flag = 'Y'
      then
          fnd_profile.get_specific(
              name_z                  => 'ORG_ID',
              responsibility_id_z     => l_responsibility_id,
              application_id_z        => l_resp_appl_id,
              val_z                   => l_org_id,
              defined_z               => l_profile_defined);
      end if;

      update ICX_SESSIONS
      set    RESPONSIBILITY_APPLICATION_ID = l_resp_appl_id,
             RESPONSIBILITY_ID = l_responsibility_id,
             SECURITY_GROUP_ID = l_security_group_id,
             ORG_ID = l_org_id,
             FUNCTION_ID = l_function_id,
             FUNCTION_TYPE = l_function_type,
             MENU_ID = l_menu_id
      where SESSION_ID = l_session_id;

      commit;

      l_validate := icx_sec.validateSessionPrivate
                            (c_session_id => l_session_id,
                             c_resp_appl_id => l_resp_appl_id,
                             c_security_group_id => l_security_group_id,
                             c_responsibility_id => l_responsibility_id,
                             c_function_id => l_function_id,
                             c_update => FALSE);

      icx_sec.g_validateSession_flag := false;

      OracleApps.runFunction
                 (c_function_id => l_function_id,
                  n_session_id => l_session_id,
                  c_parameters => l_text,
                  p_resp_appl_id => l_resp_appl_id,
                  p_responsibility_id => l_responsibility_id,
                  p_security_group_id => l_security_group_id,
                  p_menu_id => l_menu_id,
                  p_function_type => l_function_type);

      icx_sec.g_validateSession_flag := true;
*/

    exception
    when others then
      icx_sec.g_validateSession_flag := true;
      htp.p('User does not have access to this function');
      htp.nl;
      --NEED TO DO!::
      --if this is portal/sso, send to oraclesswa.convertsession
      --if this is php, send to oracleapps.convertsession with encrypted param string
--      htp.p(SQLERRM);
        htp.p(dbms_utility.format_error_stack);

    end;

    -- OA Framework version of bookmarkthis which can do some really
    -- neat stuff for the current responsibility portlet - blow away
    -- every cached version for the current user!

    procedure FwkBookmarkThis (icxtoken in varchar2,
                               p        in varchar2)
    is

        l_session_id        number;
        l_text              varchar2(2000);
        l_parameters        icx_on_utilities.v80_table;
        l_resp_appl_id      number;
        l_responsibility_id number;
        l_security_group_id number;
        l_user_id           number;

    begin
        -- Get the responsibility information for the bookmark being
        -- launched
        l_session_id := icx_portlet.validateSessionPart1;
        l_text := icx_call.decrypt4(icxtoken, l_session_id);
        icx_on_utilities.unpack_parameters(l_text,l_parameters);
        l_resp_appl_id := nvl(l_parameters(1),178);
        l_responsibility_id := l_parameters(2);
        l_security_group_id := l_parameters(3);

        -- Get the current user's user_id
        select user_id
        into l_user_id
        from icx_sessions
        where session_id = l_session_id;

        -- Update the caching key for every 'Current responsibility
        -- pages' portlet belonging to the current user
        update icx_portlet_customizations
        set responsibility_id = l_responsibility_id,
            application_id    = l_resp_appl_id,
            security_group_id = l_security_group_id,
            caching_key       = caching_key + 1
        where plug_id in (select function_id
                          from fnd_form_functions
                          where function_name = 'FND_NAVIGATE_SCTX_PORTLET')
        and user_id = l_user_id;

        -- Do whatever the BookmarkThis
        OracleSSWA.BookmarkThis(icxtoken, p);
    end;


    procedure switchpage (pagename in varchar2) is

    l_url varchar2(2000);
    l_end number;

    begin

      fnd_profile.get(name => 'APPS_PORTAL',
                      val => l_url);

      if l_url IS NULL Then
        htp.p ('Please contact System Administrator. ');
        htp.p ('Profile - APPS_PORTAL is null') ;
      end If ;

      l_end := instrb(l_url,'/',-1,1);
      l_url := substrb(l_url,1,l_end);
      l_url := l_url||'url/page/'||pagename;

      owa_util.redirect_url(l_url);

    exception
      when others then
--        htp.p(SQLERRM);
     htp.p(dbms_utility.format_error_stack);
    end;

    function listener_token return varchar2 is

    l_listener_token      VARCHAR2(240);
    l_profile_defined     boolean;
    l_server              VARCHAR2(240);

    begin

     fnd_profile.get_specific(
        name_z                  => 'APPS_SSO_LISTENER_TOKEN',
        val_z                   => l_listener_token,
        defined_z               => l_profile_defined);

     if l_listener_token is null

    then

      -- bug 2712473
      fnd_profile.get_specific(
        name_z                  => 'APPS_DATABASE_ID',
        val_z                   => l_listener_token,
        defined_z               => l_profile_defined);
      if l_listener_token is null
      then
        l_listener_token := FND_WEB_CONFIG.DATABASE_ID;
      end if;

  end if;

      return l_listener_token;

    end;

    procedure sign_on (urlc in varchar2) is

    l_listener_token      VARCHAR2(240);
    l_sso_user_name       VARCHAR2(1000);
    l_ip_address          VARCHAR2(1000);
    l_sso_time_remaining  VARCHAR2(1000);
    l_site_time_stamp     VARCHAR2(1000);
    l_url_requested       VARCHAR2(32000);
    l_unused_param        VARCHAR2(1000);
    u                     fnd_user%rowtype;
    l_user_id             number;
    l_session_id          number;
    l_return              VARCHAR2(240);
    l_session_status      VARCHAR2(10);
    c_user_id             NUMBER;
    l_anon_id             NUMBER;
    l_anon_name           VARCHAR2(350);
    l_return              VARCHAR2(240);
    l_procedure_call      varchar2(32000);
    l_call                integer;
    l_dummy               integer;
    l_apps_sso            VARCHAR2(30);
    l_profile_defined     BOOLEAN;
    l_mode                VARCHAR2(10);
    l_language              varchar2(80);
    l_language_code         varchar2(30);
    l_date_format           varchar2(150);
    l_date_language         varchar2(30);
    l_numeric_characters    varchar2(30);
    l_nls_sort              varchar2(30);
    l_nls_territory         varchar2(30);
    l_limit_time            number;
    l_limit_connects        number;
    l_org_id                varchar2(50);
    portalUrl               VARCHAR2(4000);
    portalUrlBase           VARCHAR2(4000);
    l_exception             VARCHAR2(30);
    l_timeout		    NUMBER;

    l_new_xsid              varchar2(32);

    begin

      icx_sec.ServerLevel;

      l_listener_token := OracleSSWA.listener_token;
        fnd_profile.get_specific(
                name_z                  => 'APPS_SSO',
                user_id_z               => l_user_id,
                val_z                   => l_apps_sso,
                defined_z               => l_profile_defined);

-- Wait SSO

      IF (nvl(l_apps_sso,'SSWA')='SSO_SDK') OR
         (nvl(l_apps_sso,'SSWA')='SSWA_SSO') THEN

      l_call := dbms_sql.open_cursor;

      l_procedure_call := 'wwsec_sso_enabler.parse_url_cookie'||
                        '(p_lsnr_token => :l_listener_token'||
                        ',p_enc_url_cookie => :urlc'||
                        ',p_sso_username => :l_sso_user_name'||
                        ',p_ipaddr => :l_ip_address'||
                        ',p_sso_timeremaining => :l_sso_time_remaining'||
                        ',p_site_timestamp => :l_site_time_stamp'||
                        ',p_url_requested => :l_url_requested)';

      icx_sec.g_window_cookie_name := 'Y';

      dbms_sql.parse(l_call,'begin '||l_procedure_call||'; exception when wwsec_sso_enabler.COOKIE_EXPIRED_EXCEPTION then icx_sec.g_window_cookie_name := ''X''; raise; when others then raise; end;' ,dbms_sql.native);

      l_sso_user_name := '1234567890123456789012345678901234567890';
      l_ip_address := '123.456.678.901';
      l_sso_time_remaining := 1234567890;
      l_site_time_stamp := sysdate;
      l_url_requested := '';

      for i in 1..100 loop -- set l_url_requested to 2000 characters
        l_url_requested := l_url_requested||'12345678901234567890';
      end loop;

      dbms_sql.bind_variable(l_call,'l_listener_token',l_listener_token);
      dbms_sql.bind_variable(l_call,'urlc',urlc);
      dbms_sql.bind_variable(l_call,'l_sso_user_name',l_sso_user_name);
      dbms_sql.bind_variable(l_call,'l_ip_address',l_ip_address);
      dbms_sql.bind_variable(l_call,'l_sso_time_remaining',l_sso_time_remaining);
      dbms_sql.bind_variable(l_call,'l_site_time_stamp',l_site_time_stamp);
      dbms_sql.bind_variable(l_call,'l_url_requested',l_url_requested);

      l_dummy := dbms_sql.execute(l_call);

      dbms_sql.variable_value(l_call,'l_sso_user_name',l_sso_user_name);
      dbms_sql.variable_value(l_call,'l_url_requested',l_url_requested);

      dbms_sql.close_cursor(l_call);

   END IF;--apps_sso profile option

portalUrl := fnd_profile.value('APPS_PORTAL');
portalUrlBase := substr(portalUrl, 0, length(portalUrl) - 4);

if (l_url_requested = 'APPSHOMEPAGE') then
    if(fnd_profile.value('APPS_SSO') = 'SSO_SDK') then
     l_url_requested :=
portalUrlBase||'wwsec_app_priv.login?p_requested_url='||wfa_html.conv_special_url_chars(portalUrl)||'&p_cancel_url='||wfa_html.conv_special_url_chars(portalUrl);
    else
     l_url_requested := FND_WEB_CONFIG.PLSQL_AGENT||'OracleMyPage.Home';
    end if;
end if;

      l_sso_user_name := upper(l_sso_user_name);

      -- Set application cookie
-- Bug 3801219
--  Bug 4151179 : remove those extra parentesis
      select user_id
      into   l_user_id
      from   fnd_user
      where  user_name = l_sso_user_name
      and (END_DATE is NULL or END_DATE > sysdate);


      --begin code for preservation of session_id when switching from anonymous user to authenticated user.
      l_session_id := icx_sec.getsessioncookie; -- get the cookie if there is one.
      l_session_status := icx_sec.check_session(l_session_id); -- check to see if cookie is for valid session
      BEGIN
        SELECT user_id, xsid                  -- Bug 13487530 added xsid
               INTO c_user_id, l_new_xsid
               FROM icx_sessions
               WHERE session_id=l_session_id; -- use cookie value to get user_id, defaults to -999 if bogus cookie/user_id.
      EXCEPTION
         WHEN no_data_found THEN
         c_user_id := -999;
      END;
        -- fnd_profile.get(name    => 'GUEST_USER_PWD',
                        -- val     => l_anon_name);
        -- Using new api to retrieve GUEST credentials.
        l_anon_name := fnd_web_sec.get_guest_username_pwd;

        IF l_anon_name IS NOT NULL THEN
          l_anon_name  := SUBSTR(l_anon_name, 1, INSTR(l_anon_name, '/') -1); -- profile is stored as user/passwd
          BEGIN
           SELECT user_id
             INTO l_anon_id
             FROM fnd_user
             WHERE user_name=l_anon_name;
          EXCEPTION
           WHEN OTHERS THEN
            l_anon_id := -999;
          END;
        ELSE
         l_anon_id := -999;
        --END;
        END IF;

      --test to see if we are switching from an anonymous session to authenticated session
      -- if it is a valid session, and the users are difference, and the original user is the anonymous user then
      IF l_session_status <> 'INVALID' and l_user_id <> l_anon_id and c_user_id = l_user_id THEN
        -- Reuse expired session

        -- Bug 13487530 - if session hijacking functionality is supported then
        -- use the NewXSID.
        if (fnd_session_management.is_hijack_session) then
           -- Session Hijacking. Reset xsid whenever session is reset
           l_new_xsid := fnd_session_management.NewXSID;
        end if;

        UPDATE icx_sessions
        SET last_connect  = sysdate,
            first_connect = SYSDATE,
            counter = 1,
            xsid = l_new_xsid
        WHERE session_id = l_session_id;
        owa_util.mime_header('text/html', FALSE);

        -- Bug 13487530 - if session hijacking functionality is supported then
        -- send the new XSID
        if (fnd_session_management.is_hijack_session) then
           icx_sec.sendsessioncookie(l_session_id);
        end if;

        owa_util.redirect_url(l_url_requested);
        owa_util.http_header_close;
      ELSIF ((l_session_status<>'INVALID') AND (c_user_id = l_anon_id) AND (l_anon_id <> -999) AND (c_user_id <> l_user_id)) THEN

      icx_sec.setUserNLS
              (l_user_id,
               l_language,
               l_language_code,
               l_date_format,
               l_date_language,
               l_numeric_characters,
               l_nls_sort,
               l_nls_territory,
               l_limit_time,
               l_limit_connects,
               l_org_id,
               l_timeout);

      --preserve the existing session during switch from anon user.

        -- Bug 13487530 - if session hijacking functionality is supported then
        -- use NewXSID.
        if (fnd_session_management.is_hijack_session) then
           -- Session Hijacking. Reset xsid whenever session is upgraded from
           -- GUEST to user
           l_new_xsid := fnd_session_management.NewXSID;
        end if;

        UPDATE icx_sessions
            SET user_id = l_user_id,
                nls_language = l_language,
                language_code = l_language_code,
                date_format_mask = l_date_format,
                nls_date_language = l_date_language,
                nls_numeric_characters = l_numeric_characters,
                nls_sort = l_nls_sort,
                nls_territory = l_nls_territory,
                limit_time = l_limit_time,
                limit_connects = l_limit_connects,
                org_id = l_org_id,
                last_connect  = sysdate,
                first_connect = SYSDATE,
                counter = 1,
                xsid = l_new_xsid
            WHERE session_id = l_session_id;
        owa_util.mime_header('text/html', FALSE);

        -- Bug 13487530 - if session hijacking functionality is supported then
        -- send the new XSID
        if (fnd_session_management.is_hijack_session) then
          icx_sec.sendsessioncookie(l_session_id);
        end if;

        owa_util.redirect_url(l_url_requested);
        owa_util.http_header_close;
        --end code for preservation of session_id when switching from anonymous user to authenticated user
      ELSE

        --this is not an anonymous session conversion.. create a new session and send a new cookie!
        --Need to check apps_sso profile and determine if we are Portal or PHP and set mode accordingly
        IF (nvl(l_apps_sso,'SSWA')='SSWA')
        THEN
           l_mode := '115P';
        ELSIF l_apps_sso='SSWA_SSO'
        THEN
           l_mode := '115J';
        ELSE
           l_mode := '115X';
        END IF;
        l_session_id :=  icx_sec.createSession
                         (p_user_id     => l_user_id,
                          c_mode_code   => l_mode);
        owa_util.mime_header('text/html', FALSE);
        owa_cookie.send(name=>'DEBUG_COOKIE', value=>'-1', expires=>'', path=>'/');
        owa_cookie.send(name=>'WF_WORKLIST_MODE', value=>'-1', expires=>'', path=>'/');-- mputman added for 1903545
        icx_sec.sendsessioncookie(l_session_id);
        owa_util.redirect_url(l_url_requested);
        owa_util.http_header_close;

      END IF;

    exception
      when others then
        IF ((nvl(l_apps_sso,'SSWA')='SSO_SDK') OR
           (nvl(l_apps_sso,'SSWA')='SSWA_SSO')) AND
           (icx_sec.g_window_cookie_name = 'X')
        THEN
          l_url_requested := fnd_sso_manager.getLoginUrl;
          owa_util.mime_header('text/html', FALSE);
          owa_util.redirect_url(l_url_requested);
          owa_util.http_header_close;
        ELSE
          raise;
        END IF;
    end sign_on;

procedure navigate is

l_function_id number;
l_session_id  number;

begin

select FUNCTION_ID
into   l_function_id
from   FND_FORM_FUNCTIONS
where  FUNCTION_NAME = 'FND_NAVIGATE_PAGE';

if icx_sec.validateSession
then
  l_session_id := icx_sec.getID(icx_sec.pv_session_id);

  OracleApps.runFunction(c_function_id => l_function_id,
                         n_session_id  => l_session_id);
end if;

end;

PROCEDURE convertSession
  IS
--this should only be called from VSP when validate_only='N'


l_gen_redirect_url      varchar2(32000);
l_urlrequested          varchar2(32000);
l_urlcancel             varchar2(32000);
l_procedure_call        varchar2(32000);
l_call                  integer;
l_dummy                 integer;
l_defined               boolean;
l_listener_token        VARCHAR2(240);
l_apps_sso              VARCHAR2(30);


begin
--lower(owa_util.get_cgi_env('REQUEST_PROTOCOL'))||'://'||
    l_urlrequested :=
      FND_WEB_CONFIG.PROTOCOL||'//'||
      owa_util.get_cgi_env('SERVER_NAME')||':'||
      owa_util.get_cgi_env('SERVER_PORT')||
      owa_util.get_cgi_env('SCRIPT_NAME')||
      owa_util.get_cgi_env('PATH_INFO')||'?'||
      owa_util.get_cgi_env('QUERY_STRING');

        fnd_profile.get(name    => 'APPS_SSO',
                        val     => l_apps_sso);
-- Wait SSO
      IF ((nvl(l_apps_sso,'SSWA')='SSO_SDK') OR (nvl(l_apps_sso,'SSWA')='SSWA_SSO')) THEN

    l_listener_token := OracleSSWA.listener_token;

    l_call := dbms_sql.open_cursor;
  --  l_gen_redirect_url:= wwsec_sso_enabler.generate_redirect(p_lsnr_token => l_listener_token,
  --                                                           p_url_requested => l_urlrequested,
  --                                                           p_url_cancel  => l_urlcancel);
    l_procedure_call := ':l_gen_redirect_url := wwsec_sso_enabler.generate_redirect'||
                        '(p_lsnr_token => :l_listener_token'||
                        ',p_url_requested => :l_urlrequested'||
                        ',p_url_cancel  => :l_urlcancel)';

    dbms_sql.parse(l_call,'declare l_gen_redirect_url varchar2(32000); begin '||l_procedure_call||'; end;',dbms_sql.native);

    l_gen_redirect_url := '';
    for i in 1..100 loop -- set l_gen_redirect_url to 2000 characters
      l_gen_redirect_url := l_gen_redirect_url||'12345678901234567890';
    end loop;

    dbms_sql.bind_variable(l_call,'l_gen_redirect_url',l_gen_redirect_url);
    dbms_sql.bind_variable(l_call,'l_listener_token',l_listener_token);
    dbms_sql.bind_variable(l_call,'l_urlrequested',l_urlrequested);
    dbms_sql.bind_variable(l_call,'l_urlcancel',l_urlcancel);

    l_dummy := dbms_sql.execute(l_call);

    dbms_sql.variable_value(l_call,'l_gen_redirect_url',l_gen_redirect_url);

    dbms_sql.close_cursor(l_call);

      END IF;--apps_sso profile
    owa_util.redirect_url(l_gen_redirect_url);

exception
  when others then
--    htp.p(SQLERRM);
      htp.p(dbms_utility.format_error_stack);

end;

procedure execute (F IN VARCHAR2,
                   E in VARCHAR2,
                   P IN VARCHAR2,
                   L IN VARCHAR2) is

                   --f = function_name                --mutually exclusive
                   --e = encrypted parameter string   --mutually exclusive
                   --p = parameters (encrypted)
                   --l = lanaguage code

    l_session_id            number;
    l_text                  varchar2(2000);
    l_parameters            icx_on_utilities.v80_table;
    l_resp_appl_id          number;
    l_responsibility_id     number;
    l_security_group_id     number;
    l_function_id           number;
    l_function_type         varchar2(30);
    l_menu_id               number;
    l_validate              boolean;
    l_error_message         varchar2(2000);
    err_mesg                varchar2(240);
    err_num                 number;
    l_user_id               number;
    l_user_name             varchar2(100);
    l_org_id                number;
    l_multi_org_flag        varchar2(30);
    l_profile_defined       boolean;
    e_session_invalid       exception;
    e_invalid_function      exception;
    e_refresh_4_cookie       EXCEPTION;
    l_guest_profile_value   varchar2(80);
    l_guest_name            varchar2(80);
    l_guest_pwd             varchar2(80);
    c_anchor                varchar2(2000);
    l_url                   varchar2(2000);
    l_apps_agent            varchar2(2000);
    new_encrypted_string    varchar2(2000);
    l_apps_sso            VARCHAR2(100);
    l_params                VARCHAR2(2000);
    C_LOGIN_MSG             VARCHAR2(400);
    C_ERROR_MSG             VARCHAR2(400);
    l_exeurl                VARCHAR2(2000);
    l_mode                VARCHAR2(10);
    l_language             varchar2(30);
    l_lang_code            varchar2(30);
    f_type                 VARCHAR2(30);
    l_servlet_agent        VARCHAR2(800);
    l_dbc                  VARCHAR2(70);
    nls_base_lang          varchar2(30);
    l_apps_web_agent       VARCHAR2(2000);
    l_recreate_code        varchar2(240);

begin

  icx_sec.ServerLevel;

--add parameter for sgid and init it here.

IF e IS NOT NULL THEN
  l_text := icx_call.decrypt(E);
  icx_on_utilities.unpack_parameters(l_text,l_parameters);
       l_resp_appl_id := nvl(l_parameters(1),178);
       l_responsibility_id := l_parameters(2);
       l_security_group_id := l_parameters(3);
       l_function_id := l_parameters(4);
       --verify that this is all we need to call to get the selects to work in hosted env.
       fnd_global.SET_SECURITY_GROUP_ID_CONTEXT(l_security_group_id);
ELSIF f IS NOT NULL THEN
    --We dont have a secgrpid set here!!!!!

    --get function_id.
    BEGIN
    SELECT function_id
      INTO l_function_id
      FROM fnd_form_functions
      WHERE function_name = F;
       l_resp_appl_id := NULL;
       l_responsibility_id :=NULL;
       l_security_group_id := NULL;

      EXCEPTION
       WHEN OTHERS THEN
       RAISE e_invalid_function;
    END;
ELSIF ((E IS NULL) AND (F IS NULL)) THEN
   raise e_invalid_function;

END IF;--e is null
-- function identified
        fnd_profile.get_specific(
                name_z                  => 'APPS_SSO',
                user_id_z               => l_user_id,
                val_z                   => l_apps_sso,
                defined_z               => l_profile_defined);



   --Bug 2545562/2667712
   select nls_language into nls_base_lang from fnd_languages_vl
   where installed_flag = 'B';

BEGIN

    	if L is not null
	then
 	 select nls_language into l_language from fnd_languages_vl
	where LANGUAGE_CODE = L and installed_flag in ('B', 'I');
        end if;
         exception
		 when NO_DATA_FOUND
    			then
       		          l_language := nls_base_lang;

END;

 FND_GLOBAL.set_nls_context(
      p_nls_language => l_language);
--     p_nls_territory =>'AMERICA');
--     l_language := L;

  l_session_id := icx_sec.getsessioncookie;

--IF (icx_sec.validatesession(c_validate_only=>'Y')) THEN  --there is a session cookie

IF (l_session_id >0 AND l_session_id IS NOT NULL) THEN  --there is a session cookie

  select multi_org_flag
  into   l_multi_org_flag
  from   fnd_product_groups
  where  rownum < 2;

  if l_multi_org_flag = 'Y'
  then
      fnd_profile.get_specific(
          name_z                  => 'ORG_ID',
          responsibility_id_z     => l_responsibility_id,
          application_id_z        => l_resp_appl_id,
          val_z                   => l_org_id,
          defined_z               => l_profile_defined);
  end if;


-- 2646577, nvl(l_language,NLS_LANGUAGE)

  update ICX_SESSIONS
  set 	 RESPONSIBILITY_APPLICATION_ID = l_resp_appl_id,
         RESPONSIBILITY_ID = l_responsibility_id,
         SECURITY_GROUP_ID = l_security_group_id,
         ORG_ID = l_org_id,
         FUNCTION_ID = l_function_id,
         FUNCTION_TYPE = l_function_type,
         MENU_ID = l_menu_id,
         NLS_LANGUAGE = nvl(l_language,NLS_LANGUAGE),
         LANGUAGE_CODE = nvl(L,LANGUAGE_CODE)
         where	SESSION_ID = l_session_id;
  --where	SESSION_ID = icx_sec.getsessioncookie;

  commit;

ELSE
     --get anonymous user info
     -- fnd_profile.get(name    => 'GUEST_USER_PWD',
                -- val     => l_guest_profile_value);
     -- Using new api to retrieve GUEST credentials.
     l_guest_profile_value := fnd_web_sec.get_guest_username_pwd;
     l_guest_name  := SUBSTR(l_guest_profile_value, 1, INSTR(l_guest_profile_value, '/') -1);
     --l_guest_pwd := SUBSTR(l_guest_profile_value, INSTR(l_guest_profile_value, '/') + 1);
     l_guest_name := upper(l_guest_name);
     SELECT user_id
       into l_user_id
       from  fnd_user
       where user_name = l_guest_name;

       --create anonymous session

        --Need to check apps_sso profile and determine if we are Portal or PHP and set mode accordingly
        IF (nvl(l_apps_sso,'SSWA')='SSWA')
        THEN
           l_mode := '115P';
        ELSIF l_apps_sso='SSWA_SSO'
        THEN
           l_mode := '115J';
        ELSE
           l_mode := '115X';
        END IF;
       l_session_id:=icx_sec.CREATESession(l_user_id, l_mode);
/*
       fnd_profile.get_specific(
          name_z                  => 'APPS_WEB_AGENT',
          responsibility_id_z     => l_responsibility_id,
          application_id_z        => l_resp_appl_id,
          val_z                   => l_apps_web_agent,
          defined_z               => l_profile_defined);
*/
       fnd_profile.get(name  => 'APPS_WEB_AGENT',
                       val    => l_apps_web_agent);

       l_url := FND_WEB_CONFIG.TRAIL_SLASH(l_apps_web_agent);

       --c_anchor := 'OracleSSWA.Execute?E='||wfa_html.conv_special_url_chars(icx_call.encrypt(l_resp_appl_id||'*'||l_responsibility_id||'*'||l_security_group_id||'*'||l_function_id||'*'||'**]'));

--bug 267712 added L parm to anchor
       c_anchor := 'OracleSSWA.Execute?F='||F||'&E='||E||'&P='||P||'&L='||L;

       owa_util.mime_header('text/html', FALSE);
       owa_cookie.send(name=>'WF_WORKLIST_MODE', value=>'-1', expires=>'', path=>'/');-- mputman added for 1903545
       icx_sec.sendSessionCookie(l_session_id);
       owa_util.http_header_close;

       RAISE e_refresh_4_cookie;

END IF;--cookie

   --need to do validate_only so if fails, we can still run if public
   --set a global to -999 to fnd_global will verify user-resp relationship
   icx_sec.g_prog_appl_id := -999;
  IF icx_sec.VALIDATESession(c_validate_only => 'Y') THEN
  icx_sec.g_prog_appl_id := -1;

--    IF (fnd_function.test_id(l_function_id))
--    THEN
        --either current user or anonymous user has access to this function.. run it.
        IF E IS NOT NULL and icx_sec.g_login_id is not null THEN
           fnd_signon.audit_web_responsibility(icx_sec.g_login_id,
                                               l_responsibility_id,
                                               l_resp_appl_id,
                                               l_responsibility_id); -- mputman added for 1941776
        END IF;

        SELECT TYPE
        INTO f_type
        FROM fnd_form_functions
        WHERE function_id = l_function_id;

        IF f_type = 'FORM' THEN

            /* 3220523 Replace hard coded RF.jsp
            fnd_profile.get_specific(
                name_z                  => 'APPS_SERVLET_AGENT',
                val_z                   => l_servlet_agent,
                defined_z               => l_profile_defined);
            l_servlet_agent:=FND_WEB_CONFIG.TRAIL_SLASH(replace(upper(l_servlet_agent),'OA_SERVLETS','OA_HTML'));

            fnd_profile.get(name => 'APPS_DATABASE_ID',
                            val => l_dbc);

            if l_dbc is null
              then
              l_dbc := FND_WEB_CONFIG.DATABASE_ID;
            end if;

            l_servlet_agent:=l_servlet_agent||'jsp/fnd/RF.jsp?dbc='||l_dbc||
                             '&function_id='|| l_function_id ||
                             '&resp_id=' || l_responsibility_id ||
                             '&resp_appl_id=' || l_resp_appl_id ||
                             '&security_group_id=' || nvl(l_security_group_id,'0');
            */

            l_servlet_agent:= FND_RUN_FUNCTION.GET_RUN_FUNCTION_URL
              (P_FUNCTION_ID => l_function_id,
               P_RESP_APPL_ID => l_resp_appl_id,
               P_RESP_ID => l_responsibility_id,
               P_SECURITY_GROUP_ID => nvl(l_security_group_id,'0'));

            owa_util.redirect_url(l_servlet_agent);

        ELSE
          IF p IS NOT NULL THEN
           l_params := icx_call.decrypt(P);
           --p_resp_appl_id,p_responsibility_id,p_security_group_id,
         --p_menu_id,c_function_id,p_function_type,p_page_id
           OracleApps.runfunction(p_resp_appl_id => l_resp_appl_id,
                                  p_responsibility_id => l_responsibility_id,
                                  p_security_group_id => nvl(l_security_group_id,'0'),
                                  p_function_type => f_type,
                                  c_function_id => l_function_id,
                                  n_session_id => icx_Sec.g_session_id,
                                  c_parameters => l_params);
          ELSE
            OracleApps.runfunction(p_resp_appl_id => l_resp_appl_id,
                                   p_responsibility_id => l_responsibility_id,
                                   p_security_group_id => nvl(l_security_group_id,'0'),
                                   p_function_type => f_type,
                                   c_function_id => l_function_id,
                                   n_session_id => icx_Sec.g_session_id);
          END IF;
        END IF;

    icx_sec.g_prog_appl_id := -1; --set global back to -1

  ELSIF icx_sec.check_session(p_session_id => l_session_id) = 'EXPIRED'
  THEN
  icx_sec.g_prog_appl_id := -1;

    select USER_NAME
    into   l_user_name
    from   FND_USER fu,
           ICX_SESSIONS i
    where  i.SESSION_ID = l_session_id
    and    i.USER_ID = fu.USER_ID;

    l_recreate_code := icx_call.encrypt(l_session_id||'*'||l_user_name||'**]');

    fnd_profile.get_specific(
          name_z                  => 'APPS_WEB_AGENT',
          responsibility_id_z     => l_responsibility_id,
          application_id_z        => l_resp_appl_id,
          val_z                   => l_apps_web_agent,
          defined_z               => l_profile_defined);
    l_url := FND_WEB_CONFIG.TRAIL_SLASH(l_apps_web_agent);
    l_url := l_url||'OracleSSWA.Execute?E='||icx_call.encrypt(l_resp_appl_id||'*'||l_responsibility_id||'*'||l_security_group_id||'*'||l_function_id||'*'||'**]')||'&'||'P='||P||'&'||'L='||L;

    OracleApps.displayLogin(i_direct => l_url,
                            recreate => l_recreate_code);

    --function available to current or anonymous with a valid session
  ELSIF (fnd_function.test_id(l_function_id)) -- OR (l_function_id=2594)
  THEN -- VS Failed.. if function is public, create session and go!
  icx_sec.g_prog_appl_id := -1;
     --get anonymous user info
     -- fnd_profile.get(name    => 'GUEST_USER_PWD',
                -- val     => l_guest_profile_value);
     -- Using new api to retrieve GUEST credentials.
     l_guest_profile_value := fnd_web_sec.get_guest_username_pwd;
     l_guest_name  := SUBSTR(l_guest_profile_value, 1, INSTR(l_guest_profile_value, '/') -1);
     --l_guest_pwd := SUBSTR(l_guest_profile_value, INSTR(l_guest_profile_value, '/') + 1);
     l_guest_name := upper(l_guest_name);
     SELECT user_id
       into l_user_id
       from  fnd_user
       where user_name = l_guest_name;

       --create anonymous session

        --Need to check apps_sso profile and determine if we are Portal or PHP and set mode accordingly
        IF (nvl(l_apps_sso,'SSWA')='SSWA')
        THEN
           l_mode := '115P';
        ELSIF l_apps_sso='SSWA_SSO'
        THEN
           l_mode := '115J';
        ELSE
           l_mode := '115X';
        END IF;
       l_session_id:=icx_sec.CREATESession(l_user_id, l_mode);
       fnd_profile.get_specific(
          name_z                  => 'APPS_WEB_AGENT',
          responsibility_id_z     => l_responsibility_id,
          application_id_z        => l_resp_appl_id,
          val_z                   => l_apps_web_agent,
          defined_z               => l_profile_defined);
       l_url := FND_WEB_CONFIG.TRAIL_SLASH(l_apps_web_agent);
       c_anchor := 'OracleSSWA.Execute?E='||wfa_html.conv_special_url_chars(icx_call.encrypt(l_resp_appl_id||'*'||l_responsibility_id||'*'||l_security_group_id||'*'||l_function_id||'*'||'**]'));

       owa_util.mime_header('text/html', FALSE);
       owa_cookie.send(name=>'WF_WORKLIST_MODE', value=>'-1', expires=>'', path=>'/');-- mputman added for 1903545
       icx_sec.sendSessionCookie(l_session_id);
       owa_util.http_header_close;

       select multi_org_flag
         into   l_multi_org_flag
         from   fnd_product_groups
         where  rownum < 2;
       if l_multi_org_flag = 'Y' THEN
       fnd_profile.get_specific(name_z                  => 'ORG_ID',
                                responsibility_id_z     => l_responsibility_id,
                                application_id_z        => l_resp_appl_id,
                                val_z                   => l_org_id,
                                defined_z               => l_profile_defined);
       end if;
       update ICX_SESSIONS
          set    RESPONSIBILITY_APPLICATION_ID = l_resp_appl_id,
                 RESPONSIBILITY_ID = l_responsibility_id,
                 SECURITY_GROUP_ID = l_security_group_id,
                 ORG_ID = l_org_id,
                 FUNCTION_ID = l_function_id,
                 FUNCTION_TYPE = l_function_type
          where SESSION_ID = l_session_id;
         commit;
         htp.p('<META HTTP-EQUIV=Refresh CONTENT="1; URL='||l_url||c_anchor||'">');

  ELSE
   icx_sec.g_prog_appl_id := -1;
         -- session not valid... or current user cannot access function
         -- function is not public... need to login.
         IF ((nvl(l_apps_sso,'SSWA')='SSO_SDK') OR
             (nvl(l_apps_sso,'SSWA')='SSWA_SSO'))THEN
             OracleSSWA.convertSession;
         ELSE

     --need a session for convertsession to work
     --get anonymous user info
     -- fnd_profile.get(name    => 'GUEST_USER_PWD',
                -- val     => l_guest_profile_value);
     -- Using new api to retrieve GUEST credentials.
     l_guest_profile_value := fnd_web_sec.get_guest_username_pwd;
     l_guest_name  := SUBSTR(l_guest_profile_value, 1, INSTR(l_guest_profile_value, '/') -1);
     --l_guest_pwd := SUBSTR(l_guest_profile_value, INSTR(l_guest_profile_value, '/') + 1);
     l_guest_name := upper(l_guest_name);
     SELECT user_id
       into l_user_id
       from  fnd_user
       where user_name = l_guest_name;
       ----
       l_session_id:=icx_sec.getsessioncookie;
       IF ((l_user_id <> icx_sec.g_user_id) OR (icx_sec.check_session(icx_sec.getsessioncookie) = 'INVALID')) THEN
       --create anonymous session

        --Need to check apps_sso profile and determine if we are Portal or PHP and set mode accordingly
        IF (nvl(l_apps_sso,'SSWA')='SSWA')
        THEN
           l_mode := '115P';
        ELSIF l_apps_sso='SSWA_SSO'
        THEN
           l_mode := '115J';
        ELSE
           l_mode := '115X';
        END IF;
       l_session_id:=icx_sec.CREATESession(l_user_id, l_mode);
  --     l_url := FND_WEB_CONFIG.TRAIL_SLASH(fnd_profile.value('APPS_WEB_AGENT'));
  --     c_anchor := 'OracleSSWA.Execute?E='||wfa_html.conv_special_url_chars(icx_call.encrypt(l_resp_appl_id||'*'||l_responsibility_id||'*'||l_security_group_id||'*'||l_function_id||'*'||'**]'));

       owa_util.mime_header('text/html', FALSE);
       owa_cookie.send(name=>'WF_WORKLIST_MODE', value=>'-1', expires=>'', path=>'/');-- mputman added for 1903545
       icx_sec.sendSessionCookie(l_session_id);
       owa_util.http_header_close;
       --- end create new session

       END IF;

       select multi_org_flag
         into   l_multi_org_flag
         from   fnd_product_groups
         where  rownum < 2;
       if l_multi_org_flag = 'Y' THEN
       fnd_profile.get_specific(name_z                  => 'ORG_ID',
                                responsibility_id_z     => l_responsibility_id,
                                application_id_z        => l_resp_appl_id,
                                val_z                   => l_org_id,
                                defined_z               => l_profile_defined);
       end if;
       update ICX_SESSIONS
          set    RESPONSIBILITY_APPLICATION_ID = l_resp_appl_id,
                 RESPONSIBILITY_ID = l_responsibility_id,
                 SECURITY_GROUP_ID = l_security_group_id,
                 ORG_ID = l_org_id,
                 FUNCTION_ID = l_function_id,
                 FUNCTION_TYPE = l_function_type
          where SESSION_ID = l_session_id;
         commit;


           new_encrypted_string := icx_call.encrypt(l_session_id||'*'||
                                                    l_resp_appl_id||'*'||
                                                    l_responsibility_id||'*'||
                                                    l_security_group_id||'*'||
                                                    l_function_id||'*'||
                                                    p||'**]');
           OracleApps.convertSession(new_encrypted_String);

         END IF;
  END IF;

EXCEPTION
   WHEN e_refresh_4_cookie THEN
         htp.p('<META HTTP-EQUIV=Refresh CONTENT="1; URL='||l_url||c_anchor||'">');

   WHEN e_invalid_function THEN

      fnd_message.set_name('ICX','ICX_INVALID_FUNCTION');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;
      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');

   WHEN OTHERS THEN
        icx_sec.g_prog_appl_id := -1;

--      fnd_message.set_name('ICX','ICX_SESSION_FAILED');
--      c_error_msg := fnd_message.get;
--      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
--      c_login_msg := fnd_message.get;

        fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
        c_error_msg := fnd_message.get;
        c_login_msg := dbms_utility.format_error_stack;

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
END;

FUNCTION SSORedirect (p_req_url IN VARCHAR2,
                      p_cancel_url IN VARCHAR2)
RETURN VARCHAR2
IS

  l_gen_redirect_url      varchar2(2024);
  l_urlrequested          varchar2(2024);
  l_urlcancel             varchar2(2024);
  l_listener_token        varchar2(240);
  l_procedure_call        varchar2(32000);
  l_call                  integer;
  l_dummy                 integer;
  l_defined               boolean;

BEGIN

    IF p_req_url IS NULL THEN
       fnd_profile.get_specific(name_z    => 'APPS_PORTAL',
                                val_z     => l_urlrequested,
                                defined_z => l_defined );
    ELSE
    l_urlrequested :=p_req_url;
    END IF;
    IF p_cancel_url IS NULL THEN
       fnd_profile.get_specific(name_z    => 'APPS_PORTAL',
                                val_z     => l_urlcancel,
                                defined_z => l_defined );
    ELSE
       l_urlcancel:=p_cancel_url;
    END IF;

-- Wait SSO

    l_listener_token := OracleSSWA.listener_token;
    -- l_gen_redirect_url := wwsec_sso_enabler.generate_redirect(p_lsnr_token => l_listener_token,
    --                                                           p_url_requested => l_urlrequested,
    --                                                           p_url_cancel  => l_urlcancel);


    l_call := dbms_sql.open_cursor;

    l_procedure_call := ':l_gen_redirect_url := wwsec_sso_enabler.generate_redirect'||
                        '(p_lsnr_token => :l_listener_token'||
                        ',p_url_requested => :l_urlrequested'||
                        ',p_url_cancel  => :l_urlcancel)';

    dbms_sql.parse(l_call,'declare l_gen_redirect_url varchar2(32000); begin '||l_procedure_call||'; end;',dbms_sql.native);

    l_gen_redirect_url := '';
    for i in 1..100 loop -- set l_gen_redirect_url to 2000 characters
      l_gen_redirect_url := l_gen_redirect_url||'12345678901234567890';
    end loop;

    dbms_sql.bind_variable(l_call,'l_gen_redirect_url',l_gen_redirect_url);
    dbms_sql.bind_variable(l_call,'l_listener_token',l_listener_token);
    dbms_sql.bind_variable(l_call,'l_urlrequested',l_urlrequested);
    dbms_sql.bind_variable(l_call,'l_urlcancel',l_urlcancel);
    l_dummy := dbms_sql.execute(l_call);
    dbms_sql.variable_value(l_call,'l_gen_redirect_url',l_gen_redirect_url);

    dbms_sql.close_cursor(l_call);

   RETURN l_gen_redirect_url;
END;



PROCEDURE logout
  IS
--using static image from fwk UI media.
  -- hextoraw to store a value in a blob wont work in 8i
  -- cant use a raw bacause wpg_docload cant accept a raw.

--    l_img RAW(1000);
  BEGIN

--    l_img:= hextoraw('4749463839610D000D00B30F'||
--                     '000000008000000080008080'||
--                     '00000080800080008080C0C0'||
--                     'C0808080FF000000FF00FFFF'||
--                     '000000FFFF00FF00FFFFFFFF'||
--                     'FF21F9040100000F002C0000'||
--                     '00000D000D0040041FF0C949'||
--                     '2B618CD4C92AD65B2872DF73'||
--                     '4965088EEC8865CF4BAE64AA'||
--                     'D2ED1601003B');
      owa_util.mime_header('image/gif', FALSE);
    -- Reset cookie
     owa_cookie.send
      (
          name    => icx_sec.getsessioncookiename,
          value   => '-1',
          path    => '/',
          domain  => icx_sec.getsessioncookiedomain
      );
     --htp.p('Content-Length: ' || length(l_img));
     htp.p('Expires: Thu, 29 Oct 1970 17:04:19 GMT');
     htp.p('Pragma: no-cache');
     htp.p('Cache-Control: no-cache');
     owa_util.redirect_url('/OA_MEDIA/completeind_status.gif');
     owa_util.http_header_close;
     --wpg_docload.download_file(l_img);
  EXCEPTION
    WHEN OTHERS THEN
--     htp.p(sqlerrm);
   htp.p(dbms_utility.format_error_stack);
  END logout;

end OracleSSWA;

/
