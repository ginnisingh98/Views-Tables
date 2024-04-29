--------------------------------------------------------
--  DDL for Package Body ORACLEAPPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ORACLEAPPS" as
/* $Header: ICXSEXB.pls 120.0.12010000.9 2013/06/05 17:49:16 fskinner ship $ */

/*
** Private procedures
*/
--  *******************************************
--     Procedure Display User (DU)
--  *******************************************
procedure DU is

c_error_message varchar2(2000);
err_mesg varchar2(240);
err_num number;
l_user_id number;

begin

if icx_sec.validateSession then

--- Added security for guest and function security for Preferences SSWA

   select user_id into l_user_id from icx_sessions
   where session_id = icx_sec.g_session_id;

  if l_user_id <> 6 and fnd_function.test('ICX_SSWA_USER_PREFERENCES')
  then

 displayWebUser;

 else


 fnd_message.set_name('FND','FND_APPSNAV_NO_AVAIL_APPS');
 c_error_message := fnd_message.get;

 icx_util.add_error(c_error_message);
 icx_admin_sig.error_screen(c_error_message);


end if;
 end if;

exception
    when others then

        err_num := SQLCODE;
        c_error_message := SQLERRM;
        select substr(c_error_message,12,512) into err_mesg from dual;
        icx_util.add_error(err_mesg);
        icx_admin_sig.error_screen(err_mesg);
end;

procedure NP is

c_error_message varchar2(2000);
err_mesg varchar2(240);
err_num number;

begin

displayNewPassword;

exception
    when others then
        err_num := SQLCODE;
        c_error_message := SQLERRM;
        select substr(c_error_message,12,512) into err_mesg from dual;
        icx_util.add_error(err_mesg);
        icx_admin_sig.error_screen(err_mesg);
end;

--  ***********************************************
--     Procedure Validate Login (VL) information
--  ***********************************************

procedure VL(i_1      in      VARCHAR2,
             i_2      in      VARCHAR2,
	          i_3	    in	   VARCHAR2,
	          home_url in      VARCHAR2)

is


--  i_1 - username
--  i_2 - password
--  i_3 - function_code/function_name

n_session_id    	number;
l_encrypted_session_id varchar2(150);
l_home_url		varchar2(240);
l_user_id		number;
l_profile_defined	boolean;
l_function_id		number;
l_message       	varchar2(80);
l_language		varchar2(30);
l_lang_code 		varchar2(4);
l_date_format		varchar2(100);
c_string		varchar2(150);
c_error_message varchar2(2000);
err_mesg varchar2(240);
err_num number;
l_timer number;
e_password_fail		exception;


begin

   l_message := icx_sec.validatePassword(i_1,i_2,n_session_id);



if l_message = '0'
then

   l_home_url := home_url;

   update ICX_SESSIONS
   set	  HOME_URL = l_home_url
   where  SESSION_ID = n_session_id;

   if i_3 is null
   then

	update ICX_SESSIONS
	set    HOME_URL = l_home_url
	where  SESSION_ID = n_session_id;

	displayResps(n_session_id);

   else

        update ICX_SESSIONS
        set    HOME_URL = l_home_url,
	       MODE_CODE = 'SLAVE'
        where  SESSION_ID = n_session_id;

        select function_id
        into l_function_id
        from fnd_form_functions
        where function_name = i_3;

        runFunction( l_function_id, n_session_id);
   end if;
end if;

exception
    when others then
        err_num := SQLCODE;
        c_error_message := SQLERRM;
        select substr(c_error_message,12,512) into err_mesg from dual;
        icx_util.add_error(err_mesg);
        icx_admin_sig.error_screen(err_mesg);
end;

--  ***********************************************
--      Procedure Display Main Menu (DMM)
--  ***********************************************
procedure DMM is

c_error_message varchar2(2000);
err_mesg varchar2(240);
err_num number;
l_lang_code	varchar2(30);
l_session_id	number;
l_menu_id	number;
l_encrypted_session_id varchar2(150);

begin

   if(icx_sec.validateSession) then
	l_session_id := icx_sec.g_session_id;

	select	MENU_ID
	into	l_menu_id
	from	ICX_SESSIONS
	where	SESSION_ID = l_session_id;

	if l_menu_id is null
	then
            displayResps(l_session_id);
	else
	    OracleApps.DSM_frame(l_menu_id);
	end if;

   end if;

exception
    when others then
        err_num := SQLCODE;
        c_error_message := SQLERRM;
        select substr(c_error_message,12,512) into err_mesg from dual;
        icx_util.add_error(err_mesg);
        icx_admin_sig.error_screen(err_mesg);
end;

--  ***********************************************
--      Procedure Display Root Menu (DRM)
--  ***********************************************
procedure DRM is

c_error_message varchar2(2000);
err_mesg varchar2(240);
err_num number;

begin

   if(icx_sec.validateSession) then
        displayResps(icx_sec.g_session_id);
   end if;

exception
    when others then
        err_num := SQLCODE;
        c_error_message := SQLERRM;
        select substr(c_error_message,12,512) into err_mesg from dual;
        icx_util.add_error(err_mesg);
        icx_admin_sig.error_screen(err_mesg);
end;

--  ***********************************************
--     Procedure Update Web User Information (UUI)
--  ***********************************************
procedure UUI(
                i_1     in      varchar2,
                i_2     in      varchar2,
                i_3     in      varchar2,
                i_4     in      varchar2,
                i_5     in      varchar2,
                i_6     in      varchar2,
                i_7     in      varchar2,
                i_8     in      VARCHAR2,
                i_9     in      varchar2,
                i_10    in      varchar2,
                i_11    IN      VARCHAR2,
                i_12    IN      VARCHAR2) is

c_error_message varchar2(2000);
err_mesg varchar2(240);
err_num number;

begin
    updateWebUser(i_1,i_2,i_3,i_4,i_5,i_6,i_7,i_8,i_9,i_10,i_11,i_12);

exception
    when others then
        err_num := SQLCODE;
        c_error_message := SQLERRM;
        select substr(c_error_message,12,512) into err_mesg from dual;
        icx_util.add_error(err_mesg);
        icx_admin_sig.error_screen(err_mesg);
end;


--  ***********************************************
--  function Login
--     This function creates a session cookie
--    for you, but will not take you to the
--    Welcome page.
--  ***********************************************

function Login(i_1    in      VARCHAR2,
               i_2    in      VARCHAR2,
	            i_3    out     nocopy number)
return BOOLEAN
is

--  i_1 - username
--  i_2 - password
--  i_3 - session_id

n_session_id    	number;
l_user_id               number;
l_profile_defined       boolean;
l_function_id		number;
l_message       	varchar2(80);
l_language		varchar2(30);
l_date_format		varchar2(100);
c_string		varchar2(150);
c_error_message		varchar2(2000);
err_mesg		varchar2(240);
err_num			number;

begin
   l_message := icx_sec.validatePassword(
				c_user_name	=> i_1,
				c_user_password	=> i_2,
				n_session_id	=> n_session_id,
				c_validate_only	=> 'Y');

if l_message = '0'
then

   --  *******************************************
   --  Here, we need to alter the DATABASE session
   --  We want the database to return data in the
   --  appropriate language for the user
   --  *******************************************

        -- The following should be set be Profiles

         select user_id
           into l_user_id
           from icx_sessions
          where session_id = n_session_id;

        fnd_profile.get_specific(
                name_z                  => 'ICX_LANGUAGE',
                user_id_z               => l_user_id,
                val_z                   => l_language,
                defined_z               => l_profile_defined);

        if l_language is null
        then
              /*
            select       upper(value)
            into         l_language
            from         v$nls_parameters
            where        parameter = 'NLS_LANGUAGE';
            */

           l_language:=icx_sec.getNLS_PARAMETER('NLS_LANGUAGE'); -- replaces above select mputman 1574527


        end if;

        fnd_profile.get_specific(
                name_z                  => 'ICX_DATE_FORMAT_MASK',
                user_id_z               => l_user_id,
                val_z                   => l_date_format,
                defined_z               => l_profile_defined);

        if l_date_format is null
        then
                 /*
            select       upper(value)
            into         l_date_format
            from         v$nls_parameters
            where        parameter = 'NLS_DATE_FORMAT';
               */
            l_date_format:=icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT'); -- replaces above select mputman 1574527


        end if;

        FND_GLOBAL.set_nls_context(
         p_nls_language => l_language,
         p_nls_territory =>'AMERICA');
  --next 4 lines removed in favor of above call -- mputman
  -- l_date_format  := ''''||l_date_format||'''';
  -- l_language := ''''||l_language||'''';

  -- dbms_session.set_nls('NLS_LANGUAGE'   , l_language);
  -- dbms_session.set_nls('NLS_TERRITORY'  , 'AMERICA');



--   dbms_session.set_nls('NLS_DATE_FORMAT', l_date_format);


   i_3 := n_session_id;

   return TRUE;
else
   return FALSE;

end if;

exception
    when others then
/*        err_num := SQLCODE;
        c_error_message := SQLERRM;
        select substr(c_error_message,12,512) into err_mesg from dual;
        icx_util.add_error(err_mesg);
        icx_admin_sig.error_screen(err_mesg);
*/
	return FALSE;
end;

--  ***********************************************
--     function Login
--  ***********************************************

function Login(i_1	in	VARCHAR2,
               i_2	in	VARCHAR2,
	            i_3	in	varchar2,
	            i_4	OUT nocopy number)
return BOOLEAN
is

--  i_1 - username
--  i_2 - password
--  i_3 - function_name
--  i_4 - session_id

n_session_id    	number;
l_user_id		number;
l_profile_defined       boolean;
l_function_id		number;
c_function_name		varchar2(80);
l_dummy			number;
l_message       	varchar2(80);
l_language		varchar2(30);
l_date_format		varchar2(100);
c_string		varchar2(150);
c_error_message		varchar2(2000);
err_mesg		varchar2(240);
err_num			number;

begin
   l_message := icx_sec.validatePassword(
				c_user_name	=> i_1,
				c_user_password	=> i_2,
				n_session_id	=> n_session_id,
				c_validate_only	=> 'Y');

if l_message = '0'
then

   --  *******************************************
   --  Here, we need to alter the DATABASE session
   --  We want the database to return data in the
   --  appropriate language for the user
   --  *******************************************

        -- The following should be set be Profiles

         select user_id
           into l_user_id
           from icx_sessions
          where session_id = n_session_id;

        fnd_profile.get_specific(
                name_z                  => 'ICX_LANGUAGE',
                user_id_z               => l_user_id,
                val_z                   => l_language,
                defined_z               => l_profile_defined);

        if l_language is null
        then
           /*
            select       upper(value)
            into         l_language
            from         v$nls_parameters
            where        parameter = 'NLS_LANGUAGE';
               */
            l_language:=icx_sec.getNLS_PARAMETER('NLS_LANGUAGE'); -- replaces above select mputman 1574527


        end if;

        fnd_profile.get_specific(
                name_z                  => 'ICX_DATE_FORMAT_MASK',
                user_id_z               => l_user_id,
                val_z                   => l_date_format,
                defined_z               => l_profile_defined);

        if l_date_format is null
        then
                 /*
            select       upper(value)
            into         l_date_format
            from         v$nls_parameters
            where        parameter = 'NLS_DATE_FORMAT';
               */
            l_date_format:=icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT'); -- replaces above select mputman 1574527


        end if;
        FND_GLOBAL.set_nls_context(
         p_nls_language => l_language,
         p_nls_territory =>'AMERICA');

   --next 4 lines removed in favor of above call. -- mputman
   --l_date_format  := ''''||l_date_format||'''';
   --l_language := ''''||l_language||'''';
   --dbms_session.set_nls('NLS_LANGUAGE'   , l_language);
   --dbms_session.set_nls('NLS_TERRITORY'  , 'AMERICA');


--   dbms_session.set_nls('NLS_DATE_FORMAT', l_date_format);

   i_4 := n_session_id;

   select fff.function_id
     into l_function_id
     from fnd_form_functions fff
    where fff.function_name = i_3;

   update icx_sessions
      set responsibility_id = NULL,
          function_id = l_function_id
    where session_id = n_session_id;

   return TRUE;
else
   return FALSE;

end if;

exception
    when NO_DATA_FOUND
    then
       return FALSE;
    when others then
	return FALSE;
end;

--  *******************************************
--     Procedure ForgotPwd
--  *******************************************
procedure ForgotPwd (c_user_name in varchar2) is

c_error_msg              VARCHAR2(2000);
c_login_msg              VARCHAR2(2000);
email_address            VARCHAR2(240);
seq                      NUMBER;
p_name varchar2(360)     := c_user_name;
p_password               VARCHAR2(30);
p_expire_days number     := 1;
rno                      VARCHAR2(30);
l_auth_mode              VARCHAR2(100);
l_user_id                NUMBER;
e_parameters             WF_PARAMETER_LIST_T;
display_name             varchar2(240);
notification_preference  varchar2(240);
language                 varchar2(30);
territory                varchar2(80);


BEGIN
       SELECT user_id
       into l_user_id
       from fnd_user
       where user_name = upper(c_user_name);

BEGIN
      SELECT 'LDAP'
      INTO l_auth_mode
      FROM fnd_user
      WHERE l_user_id = icx_sec.g_user_id
      AND upper(encrypted_user_password)='EXTERNAL';

      EXCEPTION
      WHEN no_data_found THEN
      l_auth_mode := 'FND';
END;

      IF l_auth_mode <> 'LDAP' THEN
     WF_DIRECTORY.GetRoleInfo(upper(c_user_name), display_name, email_address, notification_preference, language, territory);

      DBMS_RANDOM.initialize(12345);
--      p_password := to_char(dbms_random.random);
      rno := to_number(DBMS_RANDOM.random);
      p_password := 'P'||rno||'W';

      htp.img(curl => '/OA_MEDIA/FNDLOGOS.gif',
              cattributes => 'BORDER=0');
      htp.tableRowClose;
      htp.tableClose;
      htp.line;


  --Raise the event

 -- WF_LOG_PKG.wf_debug_flag := TRUE;

  select ICX_TEXT_S.Nextval into seq from dual;

  WF_EVENT.AddParameterToList('X_USER_NAME', upper(p_name), e_parameters);
  WF_EVENT.AddParameterToList('X_UNENCRYPTED_PASSWORD', p_password,
                                e_parameters);
  WF_EVENT.AddParameterToList('X_PASSWORD_LIFESPAN_DAYS', p_expire_days,
                               e_parameters);

  WF_EVENT.Raise(p_event_name=>'oracle.apps.fnd.user.password.reset_requested',
                 p_event_key=>seq, p_parameters=>e_parameters);

  DBMS_RANDOM.terminate;

  fnd_message.set_name('ICX','ICX_FORGOT_PASSWORD');
  c_error_msg := fnd_message.get;

  if email_address is null
  then

   fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
   c_login_msg := fnd_message.get;
   fnd_message.set_name('ICX','ICX_EMAIL_ADDRESS_NULL');
   c_error_msg := fnd_message.get;
   htp.p(c_login_msg||' '||c_error_msg);

  else
  htp.p(c_error_msg||' '||email_address);

end if;

  end if;

-- Second phase will allow re-direct to different site to change password
-- else if l_auth_mode = 'EXTERNAL'
-- then
-- get the value of the profile option FND_PASSWORD_EXTERNAL_SITE
-- create the link woth this url (redirection to the whatever the
-- profile options says. If null give them the standard error message below
-- owa_util.redirect_url(l_external_password_site);


   EXCEPTION
        when no_data_found then
        fnd_message.set_name('ICX','ICX_ACCT_EXPIRED');
        c_error_msg := fnd_message.get;
        fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
        c_login_msg := fnd_message.get;
        htp.img(curl => '/OA_MEDIA/FNDLOGOS.gif',
        cattributes => 'BORDER=0');
        htp.tableRowClose;
        htp.tableClose;
        htp.line;
        htp.p(c_error_msg||' '||c_login_msg);

 END;

--  ***********************************************
--     Procedure displayLogin
--  **********************************************
procedure displayLogin(c_message in varchar2,
		                 c_display in varchar2,
		                 c_logo    in varchar2,
                       i_direct  IN VARCHAR2,
                       i_mode    IN NUMBER,
                       recreate  IN VARCHAR2,
                       p_home_url IN VARCHAR2)
is
   l_url varchar2(2000);

   c_session_id            number;
   c_language_code		varchar2(30);
   c_title		 	varchar2(80);
   c_prompts		icx_util.g_prompts_table;
   l_host_instance varchar2(80);
   l_agent  varchar2(80);
   l_user_name VARCHAR2(100);
   l_parameters	icx_on_utilities.v80_table;
   l_text VARCHAR2(240);
   l_session_id            VARCHAR2(240);
   c_error_msg VARCHAR2(240);
   c_login_msg VARCHAR2(240);
   l_url2 VARCHAR2(800);
   l_home_url VARCHAR2(800);
   l_maint_mode VARCHAR2(80);
   l_maint_home_url VARCHAR2(800);
   l_nls_lang VARCHAR2(30);         --2214212
   c_nls_language VARCHAR2(40);     --2214212
   b_hosted BOOLEAN DEFAULT FALSE;
   l_hosted_profile VARCHAR2(50);
   l_apps_sso VARCHAR2(20);
   l_portal        BOOLEAN DEFAULT FALSE;
   l_portal_sso    BOOLEAN DEFAULT FALSE;
   l_SSWA          BOOLEAN DEFAULT FALSE;
   l_SSWA_SSO      BOOLEAN DEFAULT FALSE;
   l_use_portal    BOOLEAN DEFAULT FALSE;
   l_temp_id       NUMBER;


BEGIN


-- 2802333 nlbarlow
--bug Dale


 if fnd_profile.defined('APPLICATIONS_HOME_PAGE')
  then

l_url := fnd_sso_manager.getLoginUrl(requestUrl => i_direct);

 if recreate is not null
  then

 fnd_message.set_name('FND','FND_SESSION_ICX_EXPIRED');
 c_error_msg := fnd_message.get;
 fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
 c_login_msg := fnd_message.get;


  l_url := l_url||'&'||'errText='||wfa_html.conv_special_url_chars(c_error_msg)||wfa_html.conv_special_url_chars(c_login_msg);

  else

  l_url := l_url||'&'||'errText='||wfa_html.conv_special_url_chars(c_message);

  end if;


if p_home_url is not null
then
  l_url := l_url||'&'||'home_url='||wfa_html.conv_special_url_chars(p_home_url);
end if;

owa_util.mime_header('text/html', FALSE);

owa_util.redirect_url(l_url);

owa_util.http_header_close;

    else


   fnd_profile.get(name    => 'ENABLE_SECURITY_GROUPS',
                   val     => l_hosted_profile);

   IF (upper(l_hosted_profile)='HOSTED') THEN
      b_hosted:=TRUE;
   END IF;


   icx_sec.writeAudit;

   --add redirect code to send to portal and sso if portal agent profile is not null
   --check SSO_SDK, if null, then check apps_portal
        fnd_profile.get(name    => 'APPS_SSO',
                        val     => l_apps_sso);
        fnd_profile.get(name    => 'APPS_PORTAL',
                        val     => l_url);
        fnd_profile.get(name    => 'APPS_MAINTENANCE_MODE',
                        val     => l_maint_mode);-- check for MAINTENANCE mode
        l_maint_mode := nvl(l_maint_mode,'NORMAL');

        IF l_apps_sso = 'PORTAL' THEN
            l_portal:=TRUE;
        ELSIF l_apps_sso = 'SSO_SDK' THEN
            l_portal_sso:=TRUE;
        ELSIF l_apps_sso = 'SSWA' THEN
            l_SSWA:=TRUE;
        ELSIF l_apps_sso = 'SSWA_SSO' THEN
            l_SSWA_SSO:=TRUE;
        ELSIF l_apps_sso IS NULL THEN
            l_SSWA:=TRUE;
        END IF;
        IF l_portal OR l_portal_sso THEN
            l_use_portal:=TRUE;
            ELSE
            l_use_portal:=FALSE;
        END IF;

   --check to see if we are running in maintenance mode AND that we got here for other than expiry.
   IF (l_maint_mode <> 'NORMAL') AND (recreate IS NULL) THEN


      fnd_message.set_name('FND','FND_SESSION_ICX_EXPIRED');
      c_error_msg := fnd_message.get;
      SELECT home_url
         INTO l_home_url
         FROM icx_parameters;

      --l_home_url:= wfa_html.conv_special_url_chars(l_home_url);

      IF l_use_portal THEN --using portal and need to make sure we log out
         l_home_url:= wfa_html.conv_special_url_chars(l_home_url);
         l_url2 := wfa_html.conv_special_url_chars(l_url);
         l_maint_home_url := replace(l_url,'home','wwsec_app_priv.logout?p_done_url='||(nvl(l_home_url,l_url2)));

      ELSE --not using portal and just need to get to icx_sessions.home_url
         l_maint_home_url := l_home_url;
      END IF;

      owa_util.mime_header('text/html', TRUE);
      htp.p('<meta http-equiv="Expires" content="-1">');
      htp.htmlOpen;
      htp.p('<script>');
          --comment out these next 2 debug lines
          -- htp.p('alert("'||l_maint_home_url||'");');
          -- htp.p('alert("'||nvl(l_url,'NULL')||'");');
      htp.p('alert("'||c_error_msg||'");');
      htp.p('top.location="'||l_maint_home_url||'"');
      htp.p('</script>');
      htp.htmlClose;



   ELSE -- not in maintenance mode

      --begin 2214212 mputman -- try to get lang from icx_sessions when session_id is avail via recreate and set nls context.
      IF recreate IS NOT NULL THEN
      l_text := icx_call.decrypt(recreate);
      icx_on_utilities.unpack_parameters(l_text,l_parameters);
      l_user_name:=l_parameters(2);
      l_session_id:=l_parameters(1);
BEGIN
   SELECT nls_language
      INTO l_nls_lang
      FROM icx_sessions
      WHERE session_id=l_session_id;
   if  l_nls_lang is not null
   and nvl(icx_sec.g_language_c,'XXXXX') <> l_nls_lang
   then
      c_nls_language := l_nls_lang;
      --c_nls_language := ''''||l_nls_lang||'''';
      --dbms_session.set_nls('NLS_LANGUAGE'   , c_nls_language); --replaced with call to fnd_global
      icx_sec.g_language_c:=l_nls_lang;
      FND_GLOBAL.set_nls_context(p_nls_language =>c_nls_language);
   end if;



EXCEPTION
   WHEN OTHERS THEN
      NULL;

END;
   END IF;--recreate is not null
   --end 2214212 mputman
   IF (l_use_portal OR L_SSWA_SSO) THEN
      --get home_url for where to go after portal logout... if null go to apps_portal profile value
      SELECT home_url
         INTO l_home_url
         FROM icx_parameters;

              l_home_url:= wfa_html.conv_special_url_chars(l_home_url);
              l_url2 := wfa_html.conv_special_url_chars(l_url);
              IF l_portal_sso THEN
              l_url := replace(l_url,'home','wwsec_app_priv.logout?p_done_url='||
                                OracleSSWA.SSORedirect((nvl(i_direct,l_url)),(nvl(l_home_url,l_url2))));
              ELSIF l_sswa_sso THEN
              l_url := OracleSSWA.SSORedirect((nvl(i_direct,FND_WEB_CONFIG.PLSQL_AGENT||'OracleMyPage.home')),
                                             (nvl(l_home_url,l_home_url)));
              ELSE
              l_url := replace(l_url,'home','wwsec_app_priv.logout?p_done_url='||(nvl(l_home_url,l_url2)));
              END IF;
               -- nlbarlow, prevent URL caching, 1755317
               owa_util.mime_header('text/html', TRUE);
               htp.p('<meta http-equiv="Expires" content="-1">');
               htp.htmlOpen;
               htp.p('<script>');
               IF recreate IS NOT NULL THEN  --let the user know why they are going to a sign on screen
                  fnd_message.set_name('FND','FND_SESSION_ICX_EXPIRED');
                  c_error_msg := fnd_message.get;
               --   htp.p('<script>');
                  htp.p('alert("'||c_error_msg||'");');
               --   htp.p('</script>');
               ELSE
                  IF ((c_message IS NOT NULL) AND
                      (icx_sec.getsessioncookie <>-1)) THEN
                     htp.p('alert("'||c_message||'");');
                  END IF;
               END IF;
               htp.p('top.location="'||l_url||'"');
               htp.p('</script>');
               htp.htmlClose;

   ELSE --not using PORTAL
      IF recreate IS NOT NULL THEN  --let the user know why they are going to a sign on screen
         fnd_message.set_name('FND','FND_SESSION_ICX_EXPIRED');
         c_error_msg := fnd_message.get;
         htp.p('<script>');
         htp.p('alert("'||c_error_msg||'");');
         htp.p('</script>');
      END IF;


   icx_util.getPrompts(601,'ICX_LOGIN',c_title,c_prompts);
   IF recreate IS NOT NULL THEN

    --  fnd_message.set_name('FND','FND_SESSION_ICX_EXPIRED');
    --  c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;

      --mputman moved up for 2214212
--      l_text := icx_call.decrypt(recreate);
--      icx_on_utilities.unpack_parameters(l_text,l_parameters);
--      l_user_name:=l_parameters(2);
--      l_session_id:=l_parameters(1);
   ELSE
      icx_sec.RemoveCookie;
      END IF;

   --   htp.htmlOpen;
--   htp.headOpen;
   icx_util.copyright;
   htp.p('<META Http-Equiv="Pragma" Content="no-cache">');
   htp.title(c_title);

   htp.p('<SCRIPT LANGUAGE="JavaScript">');

   IF recreate IS NOT NULL THEN



     -- htp.p('if (opener != null) {
     --           alert("'||c_error_msg||'");
     --           }');
      --htp.p('alert("'||c_error_msg||'");');

       htp.p('function logon_submit()
        {


             if (document.Logon1.i_1.value.toUpperCase() == "'||l_user_name||'")
             {
             document.Logon3.i_1.value = document.Logon1.i_1.value;
             document.Logon3.i_2.value = document.Logon2.i_2.value;
             document.Logon3.submit();

             }else{
             window.name="";
             window.close();
             }
             }');

           --  document.Logon0.i_1.value = document.Logon1.i_1.value;
           --  document.Logon0.i_2.value = document.Logon2.i_2.value;
           --  document.Logon0.submit();
           --  }

           --	}');

   ELSE
   htp.p('function logon_submit()
        {
                document.Logon0.i_1.value = document.Logon1.i_1.value;
                document.Logon0.i_2.value = document.Logon2.i_2.value;');
         IF b_hosted THEN
         htp.p('document.Logon0.c_sec_grp_id.value = document.site.c_sec_grp_id.value;');
         END IF;
         htp.p('document.Logon0.submit();
	}');
   END IF;
   htp.p('</SCRIPT>');

   c_session_id := icx_sec.getsessioncookie;

   --****** if cookie exists, get session id ******--

    -- when we have corrected how icx_sec.RemoveCookie works,
    -- we can remove the check for -1 here

   if (c_session_id > 0)
   then

      begin
        select  b.language_code
        into    c_language_code
        from    fnd_languages b,
                icx_sessions a
        where   a.session_id = c_session_id
        and     b.nls_language = a.nls_language;

      exception
        when NO_DATA_FOUND then -- bug 643163, check session exists
          select        LANGUAGE_CODE
          into          c_language_code
          from          FND_LANGUAGES
          where         INSTALLED_FLAG = 'B';

      end;

      htp.p('<SCRIPT LANGUAGE="JavaScript">');
      htp.p('<!-- Hide from old Browsers');
      icx_admin_sig.help_win_script('/OA_DOC/'||c_language_code||'/aic/icxhlpl.htm', c_language_code);
      htp.p('// -->');
      htp.p('</SCRIPT>');

--      htp.headClose;

      if c_display = 'IC' and c_logo = 'Y'
      then
	icx_admin_sig.toolbar(language_code => c_language_code);
      else
         htp.bodyOpen(icx_admin_sig.background(c_language_code));
      end if;
   else


      -- When cookie does not exist (failed during signin) use background from the US directory

--      htp.headClose;
--      htp.bodyOpen('/OA_MEDIA/ICXBCKGR.jpg');

      if c_display = 'IC' and c_logo = 'Y'
      then
         htp.img(curl => '/OA_MEDIA/FNDLOGOS.gif',
                 cattributes => 'BORDER=0');

         htp.tableRowClose;
         htp.tableClose;
         htp.line;
      end if;
   end if;

        IF recreate IS NOT NULL THEN
           htp.p('<H2>'||c_error_msg||'</H2>');
           --htp.nl;
           htp.p('<H2>'||c_login_msg||'</H2>');
        ELSE
        htp.p(nvl(c_message,'<H2>'||c_title||'</H2>'));
        END IF;

    l_host_instance := FND_WEB_CONFIG.DATABASE_ID;

--    select      lower(host_name)||'_'||lower(instance_name)
--    into        l_host_instance
--    from        v$instance;

    l_agent := icx_plug_utilities.getPLSQLagent;

IF recreate IS NOT NULL THEN
htp.p('<FORM NAME=Logon3 ACTION="OracleApps.recreate_session" METHOD="POST" TARGET="_top">');
htp.formHidden('i_1','');
htp.formHidden('i_2','');
htp.formHidden('p_enc_session',icx_call.encrypt3(l_session_id));
--htp.formHidden('p_mode',i_mode);
htp.formClose;
END IF;

    IF i_direct IS NULL  THEN
htp.p('<FORM NAME=Logon0 ACTION="OracleMyPage.Home" METHOD="POST" TARGET="_top">');
htp.formHidden('i_1','');
htp.formHidden('i_2','');
htp.formHidden('rmode','2');
htp.formHidden('c_sec_grp_id','');
--htp.formHidden('i_direct',i_direct); --mputman 793404

    ELSE
htp.p('<FORM NAME=Logon0 ACTION="OracleMyPage.Home" METHOD="POST" TARGET="_top">');
htp.formHidden('i_1','');
htp.formHidden('i_2','');
--htp.formHidden('rmode','2'); --mputman 793404
htp.formHidden('i_direct',i_direct); --mputman 793404
htp.formHidden('rmode',i_mode); --mputman 793404
htp.formHidden('c_sec_grp_id','');


    END IF;


--htp.p('<FORM NAME=Logon0 ACTION="OracleMyPage.Home" METHOD="POST" TARGET="_top">');
----htp.formHidden('dbHost',l_host_instance);
----htp.formHidden('agent',l_agent);
--htp.formHidden('i_1','');
--htp.formHidden('i_2','');
--htp.formHidden('rmode','2');
--htp.formHidden('i_direct',i_direct); --mputman 793404


htp.formClose;

IF b_hosted THEN
htp.tableOpen;
   htp.tableRowOpen;                             -- SITE
        htp.tableData(c_prompts(5),'RIGHT');
        htp.p('<FORM NAME=site ACTION="javascript:document.Logon2.i_2.focus();" METHOD="POST">');
        htp.tableData(htf.formText('c_sec_grp_id',30));
        htp.formClose;
        htp.p('<td></td>');
   htp.tableRowClose;
END IF;

htp.tableOpen;
   htp.tableRowOpen;                             -- Username
        htp.tableData(c_prompts(1),'RIGHT');
        htp.p('<FORM NAME=Logon1 ACTION="javascript:document.Logon2.i_2.focus();" METHOD="POST">');
        htp.tableData(htf.formText('i_1',30));
        htp.formClose;
        htp.p('<td></td>');
   htp.tableRowClose;
   htp.tableRowOpen;                             -- Password
	htp.tableData(c_prompts(2),'RIGHT');
        htp.p('<FORM NAME=Logon2 ACTION="javascript:logon_submit();" METHOD="POST">');
	htp.tableData(htf.formPassword('i_2',30));
        htp.formClose;
        htp.p('<td>');
        icx_plug_utilities.buttonBoth(c_prompts(3),'javascript:logon_submit()','FNDJLFOK.gif'); --  Connect
        htp.p('</td>');
   htp.tableRowClose;
htp.tableClose;
   htp.formClose;

        htp.p('<SCRIPT LANGUAGE="JavaScript">');
        htp.p('<!-- Hide from old Browsers');
        IF recreate IS NOT NULL THEN
           htp.p('document.Logon1.i_1.value="'||l_user_name||'"');
           htp.p('document.Logon2.i_2.focus();');

           htp.p('// -->');

           htp.p('function onLoadFunc() {
                 document.Logon2.i_2.focus();
                 }');
           htp.p('</SCRIPT>');
           htp.p('<body onLoad="onLoadFunc()"></body>');
        ELSE
           htp.p('document.Logon1.i_1.focus();');

           htp.p('// -->');
           htp.p('</SCRIPT>');


           END IF;

        END IF;

   END IF;

end if;

        exception
	when others then
--htp.p(SQLERRM);
  htp.p(dbms_utility.format_error_stack);

end;


-- mbukhari Added this signature for API redirectURL to fix bug 2171975. 16-Jan-2002
-- We should keep the old signature for this API around for backward compatibility.

procedure redirectURL(i_1 in varchar2,
                      i_2 in varchar2,
                      URL in varchar2,
                      F   in varchar2,
                      A   in VARCHAR2,
                      R   in VARCHAR2,
                      S   in VARCHAR2) is

l_anchor                   varchar2(2000);
l_encrypted_session_id     varchar2(240);
l_encrypted_transaction_id varchar2(240);
l_dbc                      varchar2(240);
l_responsibility_id        number;
l_resp_appl_id             number;
l_security_group_id        number;
l_session_id               number;
l_function_id              number;
l_random_num               number;
l_message                  varchar2(80);
l_result                   varchar2(30);
l_username                 varchar2(30);
l_user_id                  number;
l_error_msg                varchar2(2000);
l_login_msg                varchar2(2000);
l_function_name            varchar2(2000);
l_transaction_id           number;

cursor getResp(p_user_id in varchar2) is
      select  fr.menu_id, furg.responsibility_id,
              furg.security_group_id, furg.responsibility_application_id
      from    fnd_responsibility fr,
              fnd_user_resp_groups furg,
              fnd_user fu
      where   fu.USER_ID = p_user_id
      and     fu.START_DATE <= sysdate
      and     (fu.END_DATE is null or fu.END_DATE > sysdate)
      and     furg.USER_ID = fu.USER_ID
      and     furg.START_DATE <= sysdate
      and     (furg.END_DATE is null or furg.END_DATE > sysdate)
      and     furg.RESPONSIBILITY_APPLICATION_ID = fr.APPLICATION_ID
      and     furg.RESPONSIBILITY_ID = fr.RESPONSIBILITY_ID
      and     fr.VERSION = 'W'
      and     fr.START_DATE <= sysdate
      and     (fr.END_DATE is null or fr.END_DATE > sysdate);


cursor getFunctionId(p_function_name in varchar2) is
      select function_id
      from   fnd_form_functions
      where  function_name = p_function_name;

begin

  l_anchor := URL;
  l_function_name := F;
  l_username := upper(i_1);

  l_result := fnd_web_sec.validate_login(l_username, i_2);

  if l_result = 'Y'
  then
    select USER_ID
    into   l_user_id
    from   FND_USER
    where  USER_NAME = l_username;

    if (F is not null)
    then
      open getFunctionId(l_function_name);
      fetch getFunctionId into l_function_id;
      close getFunctionId;

      for ri in getResp(l_user_id) loop

        if fnd_function.is_function_on_menu(ri.menu_id, l_function_id)
        then
          l_resp_appl_id := ri.responsibility_application_id;
          l_responsibility_id := ri.responsibility_id;
          l_security_group_id := ri.security_group_id;
          exit;
        end if;
      end loop;
    else
       if A is null
       then
	 l_resp_appl_id := '';
       else
	 l_resp_appl_id := icx_call.decrypt3(A);
       end if;

       if R is null
       then
	 l_responsibility_id := '';
       else
	 l_responsibility_id := icx_call.decrypt3(R);
       end if;

       if S is null
       then
	 l_security_group_id := '';
       else
	 l_security_group_id := icx_call.decrypt3(S);
       end if;

    end if;


    l_session_id := icx_sec.createSession(p_user_id => l_user_id,
                                          c_mode_code   => '115P') ;


    owa_util.mime_header('text/html', FALSE);

    icx_sec.sendsessioncookie(l_session_id);

    if (instr(l_anchor,'OA.jsp') > 0)
    then
      fnd_profile.get(name => 'APPS_DATABASE_ID',
                      val => l_dbc);

      if l_dbc is null
      then
        l_dbc := FND_WEB_CONFIG.DATABASE_ID;
      end if;

      l_encrypted_session_id := icx_call.encrypt3(l_session_id);

      l_transaction_id :=
        icx_sec.createTransaction(
        l_session_id,l_resp_appl_id,l_responsibility_id,l_security_group_id,
        '','','','');
      l_encrypted_transaction_id := icx_call.encrypt3(l_transaction_id);

      icx_sec.updateSessionContext(p_function_name     => l_function_name,
                                   p_function_id       => l_function_id,
                                   p_application_id    => l_resp_appl_id,
                                   p_responsibility_id => l_responsibility_id,
                                   p_security_group_id => l_security_group_id,
                                   p_session_id        => l_session_id,
                                   p_transaction_id    => l_transaction_id);

      l_anchor := l_anchor||
               '&'||'dbc='||l_dbc||
               '&'||'language_code='||icx_sec.g_language_code||
               '&'||'transactionid='||l_encrypted_transaction_id;
    end if;

    owa_util.redirect_url(l_anchor);
    owa_util.http_header_close;

  else
     fnd_message.set_name('ICX','ICX_SIGNIN_INVALID');
     l_error_msg := fnd_message.get;
     fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
     l_login_msg := fnd_message.get;

     OracleApps.displayLogin(l_error_msg||' '||l_login_msg,'IC','Y');
  end if;

exception
  when others then
--    htp.p(SQLERRM);
   htp.p(dbms_utility.format_error_stack);

end;

procedure redirectURL(i_1 in varchar2,
                      i_2 in varchar2,
                      URL in varchar2,
                      A   in VARCHAR2,
                      R   in VARCHAR2,
                      S   in VARCHAR2) is

l_anchor                   varchar2(2000);
l_encrypted_session_id     varchar2(240);
l_encrypted_transaction_id varchar2(240);
l_dbc                      varchar2(240);
l_responsibility_id        number;
l_resp_appl_id             number;
l_security_group_id        number;
l_session_id               number;
l_random_num               number;
l_message                  varchar2(80);
l_result                   varchar2(30);
l_username                 varchar2(30);
l_user_id                  number;
l_error_msg                varchar2(2000);
l_login_msg                varchar2(2000);

begin

  l_anchor := URL;

  if A is null
  then
    l_resp_appl_id := '';
  else
    l_resp_appl_id := icx_call.decrypt3(A);
  end if;

  if R is null
  then
    l_responsibility_id := '';
  else
    l_responsibility_id := icx_call.decrypt3(R);
  end if;

  if S is null
  then
    l_security_group_id := '';
  else
    l_security_group_id := icx_call.decrypt3(S);
  end if;

  l_username := upper(i_1);

  l_result := fnd_web_sec.validate_login(l_username, i_2);

  if l_result = 'Y'
  then
    select USER_ID
    into   l_user_id
    from   FND_USER
    where  USER_NAME = l_username;

    l_session_id := icx_sec.createSession(p_user_id => l_user_id,
                                          c_mode_code   => '115P') ;

    owa_util.mime_header('text/html', FALSE);

    icx_sec.sendsessioncookie(l_session_id);

    if (instr(l_anchor,'OA.jsp') > 0)
    then
      fnd_profile.get(name => 'APPS_DATABASE_ID',
                      val => l_dbc);

      if l_dbc is null
      then
        l_dbc := FND_WEB_CONFIG.DATABASE_ID;
      end if;

      l_encrypted_session_id := icx_call.encrypt3(l_session_id);
      l_encrypted_transaction_id :=
        icx_call.encrypt3(icx_sec.createTransaction(
        l_session_id,l_resp_appl_id,l_responsibility_id,l_security_group_id,
        '','','',''));

      l_anchor := l_anchor||
               '&'||'dbc='||l_dbc||
               '&'||'language_code='||icx_sec.g_language_code||
               '&'||'transactionid='||l_encrypted_transaction_id;
    end if;

    owa_util.redirect_url(l_anchor);

    owa_util.http_header_close;

  else
     fnd_message.set_name('ICX','ICX_SIGNIN_INVALID');
     l_error_msg := fnd_message.get;
     fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
     l_login_msg := fnd_message.get;

     OracleApps.displayLogin(l_error_msg||' '||l_login_msg,'IC','Y');
  end if;

exception
  when others then
--    htp.p(SQLERRM);
      htp.p(dbms_utility.format_error_stack);

end;


--  ***********************************************
--    Procedure displayResps
--  ***********************************************
procedure displayResps(nri       in VARCHAR2,
                       c_toolbar in VARCHAR2)
is
	-- *******************************
	-- nri - Not Required Input
	-- in this case, nri is the session_id
	-- *******************************

        c_menu_id	 	number;
	c_function_id	 	number;
        c_anchor        	varchar2(2000);
	l_url			varchar2(2000);
	n_error_num		number;
	c_display_error		varchar2(240);
	c_error_msg		varchar2(2000);
	c_login_msg		varchar2(2000);
        c_known_as      	varchar2(240);
	c_user_name		varchar2(100);
	c_user_id		number;
	l_profile_defined       boolean;
	a_counter		number default 0;
	r_counter		binary_integer default 0;
	f_counter		binary_integer default 0;
	c_display		varchar2(80) default 'IC';
	l_session_id		number;
	n_session_id		number;
	p_funcTable		icx_admin_sig.pp_table;
	p_funcEmpty		icx_admin_sig.pp_table;
	b_return		BOOLEAN default TRUE;
	c_title		 	varchar2(80);
	c_language_code		varchar2(30);
	c_prompts		icx_util.g_prompts_table;
	e_data_error		exception;
	n_encryption_passed	number := 1;
	c_encrypted_func	varchar2(2000);
	-- added for images
        i_counter               binary_integer default 0;

	v_color			varchar2(7);
	v_color_image 		varchar2(20);
	v_bullet_image 		varchar2(20);
	l_language 		varchar2(30);
	l_date_format 		varchar2(30);
        l_count			number;
	l_function_id		number;

	-- added to suport menu
	f			fnd_form_functions_vl%rowtype;
	l_menuItems		menuItemTable;
	l_level			number;
	l_encrypt_menu		varchar2(2000);
	l_user_menu_name	varchar2(80);
	l_prompt		varchar2(240);
	l_description		varchar2(240);

        cursor resps is
        select  b.RESPONSIBILITY_APPLICATION_ID,
                b.SECURITY_GROUP_ID,
                a.responsibility_id,
		a.responsibility_name,
		a.description,
		a.web_host_name,
		a.web_agent_name,
		a.version,
		a.menu_id
	from	fnd_responsibility_vl a,
                FND_USER_RESP_GROUPS b
        where   b.user_id = c_user_id
        and     a.responsibility_id = b.responsibility_id
	and	a.application_id = b.RESPONSIBILITY_application_id
	and     a.version = 'W'
	and	a.start_date <= sysdate
	and	(a.end_date is null or a.end_date > sysdate)
	and	b.start_date <= sysdate
	and	(b.end_date is null or b.end_date > sysdate)
        order by responsibility_name;

	-- menuItems is all the menuitems under certain menu
	cursor 	menuItems is
	select 	b.menu_id,
		b.entry_sequence,
		b.sub_menu_id,
		b.function_id,
		c.web_html_call,
		b.prompt,
		b.description,
		c.web_icon
	from 	fnd_form_functions c,
	     	fnd_menu_entries_vl b
	where 	b.menu_id = c_menu_id
	and	c.function_id(+) = b.function_id
        and     nvl(c.type,'WWW') in ('WWW','WWK', 'SERVLET','JSP', 'INTEROPJSP')
	order	by b.entry_sequence;

l_timer number;
begin

if (nri is not NULL)
then

   n_session_id := nri;

   select       nls_language,date_format_mask
   into         l_language,l_date_format
   from         icx_sessions
   where        session_id = n_session_id;

   l_session_id := n_session_id;
        FND_GLOBAL.set_nls_context(
         p_nls_language => l_language,
         p_nls_territory =>'AMERICA');
  --next 4 lines removed in favor of above call -- mputman
  -- l_date_format  := ''''||l_date_format||'''';
  -- l_language := ''''||l_language||'''';

  -- dbms_session.set_nls('NLS_LANGUAGE'   , l_language);
  -- dbms_session.set_nls('NLS_TERRITORY'  , 'AMERICA');


--    dbms_session.set_nls('NLS_DATE_FORMAT', l_date_format);

   -- if session is valid
elsif icx_sec.validateSession
then

   -- ************************************
   -- *** If session ID is not passed in,
   -- *** get the cookie for this session.
   -- ************************************

   n_session_id := icx_sec.getsessioncookie;

   if (n_session_id <= 0)
   then
      fnd_message.set_name('FND','FND_SESSION_ICX_EXPIRED');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
      b_return := FALSE;
   end if;
end if;

if (b_return)
then
   icx_sec.writeAudit;

   icx_util.getPrompts(601,'ICX_MAIN_MENU',c_title,c_prompts);

   if (l_session_id is not NULL)    -- This will happen during the login process
   then
      select b.language_code
      into   c_language_code
      from   fnd_languages b,
             icx_sessions a
      where  a.session_id = n_session_id
      and    b.nls_language = a.nls_language;
   else
      c_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
   end if;

   select  a.description, a.user_name, a.user_id
   into    c_known_as, c_user_name, c_user_id
   from    fnd_user a,
           icx_sessions b
   where   b.session_id = n_session_id
   and     b.user_id    = a.user_id;

   if c_toolbar = 'Y'
   then

   htp.htmlOpen;
   htp.headOpen;
   icx_util.copyright;
      js.scriptOpen;
      icx_admin_sig.help_win_script('/OA_DOC/'||c_language_code||'/aic/icxhlpw.htm');
      htp.p('function open_new_browser(url,x,y){
    attributes = "resizable=yes,scrollbars=yes,toolbar=yes,width="+x+",height="+y;
    new_browser = window.open(url, "new_browser", attributes);}');
      js.scriptClose;
      htp.title(c_title||'  '|| nvl(c_known_as,c_user_name));
   htp.headClose;

	--* use Oracle logo *--
   icx_admin_sig.toolbar(language_code => c_language_code,
		         disp_mainmenu => 'N');

   end if; -- c_toolbar = 'Y'

   if c_display = 'IC'
   then
      htp.p('<H2>'||c_title||'  '|| nvl(c_known_as,c_user_name)||'</H2>');
   else
      htp.p(c_title||'  '||htf.anchor('OracleApps.DU', nvl(c_known_as, c_user_name)));
   end if;

   htp.p('<TABLE WRAP>');

   for r in Resps loop

      c_menu_id := r.menu_id;

      r_counter := r_counter + 1;
      if (mod(r_counter,4) = 1) then
	v_color := G_PURPLE;
	v_color_image := 'FNDIPRBR.gif';
	v_bullet_image := 'FNDIPRBL.gif';
      elsif (mod(r_counter,4) = 2) then
	v_color := G_RED;
	v_color_image := 'FNDIRDBR.gif';
	v_bullet_image := 'FNDIRDBL.gif';
      elsif (mod(r_counter,4) = 3) then
	v_color := G_GREEN;
	v_color_image := 'FNDIGRBR.gif';
	v_bullet_image := 'FNDIGRBL.gif';
      elsif (mod(r_counter,4) = 0) then
	v_color := G_BROWN;
	v_color_image := 'FNDIBRBR.gif';
	v_bullet_image := 'FNDIBRBL.gif';
      end if;

    -- modified to display HR icons
    -- paint responsibility name and color stripe
    -- If only one entry with menu and function custom menu handler

    select  count(1)
    into    l_count
    from    fnd_menu_entries
    where   menu_id = c_menu_id
    and     function_id is not null
    and     sub_menu_id is not null;

    if l_count = 1
    then
      select  function_id
      into    l_function_id
      from    fnd_menu_entries
      where   menu_id = c_menu_id
      and     function_id is not null
      and     sub_menu_id is not null;

      htp.tableRowOpen;
      htp.tableData('<B><FONT COLOR=' || v_color || '>'||
      --mputman convert to execute effort
        --htf.anchor('OracleApps.RF?F='||icx_call.encrypt2(r.responsibility_application_id||'*'||r.responsibility_id||'*'||r.security_group_id||'*'||l_function_id||'**]',n_session_id),
        htf.anchor('OracleSSWA.Execute?E='||wfa_html.conv_special_url_chars(icx_call.encrypt(r.responsibility_application_id||'*'||r.responsibility_id||'*'||r.security_group_id||'*'||l_function_id||'**]')),
        r.responsibility_name,'','TARGET="_top", onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(r.description)||''';return true"')||
        '</B></FONT>','','','','','4','');
      htp.tableRowClose;
      htp.tableRowOpen;
      htp.tableData('<IMG SRC=/OA_MEDIA/'
                 || v_color_image || ' height=3 width=500></B>',
                '','','','','4','');
      htp.tableRowClose;

      htp.tableRowOpen;
      htp.tableRowClose;

      htp.tableRowOpen;
      htp.tableRowClose;

    else -- l_count <> 1

      htp.tableRowOpen;
      htp.tableData('<B><FONT COLOR=' || v_color || '>'||r.responsibility_name||'</B></FONT>','','','','','4','');
      htp.tableRowClose;
      htp.tableRowOpen;
      htp.tableData('<IMG SRC=/OA_MEDIA/'
                || v_color_image || ' height=3 width=500></B>',
                '','','','','4','');
      htp.tableRowClose;

      -- if HR responsibility, paint while looping through the functions
      -- if others, construct the table while looping, and paint at the end

      for mi in menuItems loop

	l_prompt := null;
	l_description := null;
	if mi.prompt is not null
        then
	    l_prompt := mi.prompt;
	    l_description := mi.description;
	elsif mi.description is not null
	then
	    l_prompt := mi.description;
	    l_description := mi.description;
	end if;

	if l_prompt is not null then

	if (mi.function_id is not NULL) then

            if (mi.sub_menu_id is NULL) then
		if substr(mi.web_html_call,1,10) = 'javascript'
		then
		    l_url := replace(mi.web_html_call,'"','''');
                    l_url := replace(l_url,'[RESPONSIBILITY_ID]',r.responsibility_id);
		else
                    --mputman convert to execute effort
                    --l_url := 'OracleApps.RF?F='||icx_call.encrypt2(r.responsibility_application_id||'*'||r.responsibility_id||'*'||r.security_group_id||'*'||mi.function_id||'***]', n_session_id);
                    l_url := 'OracleApps.RF?F='||icx_call.encrypt2(r.responsibility_application_id||'*'||r.responsibility_id||'*'||r.security_group_id||'*'||mi.function_id||'***]', n_session_id);
		end if;
            else
		l_level := 1;
                l_url := 'OracleApps.DSM?Q='||icx_call.encrypt2(l_level+1||'*'||v_color||'*'||v_color_image||'*'||v_bullet_image||'*'
	||r.responsibility_id||'*'||mi.menu_id||'*'||'OracleApps.DRM'||'*'||mi.sub_menu_id||'*'||'OracleApps.DSM'||'**]', n_session_id);
            end if;

	  	if mi.web_icon is not null
		then
		    if i_counter = 0 then
			htp.tableRowOpen;
		    end if;
		    i_counter := i_counter+1;

		    -- paint 4 icons on one line
		    if ((i_counter <> 1) AND (MOD(i_counter, 4) = 1))
		    then
			htp.tableRowClose;
			htp.tableRowOpen;
		    end if;

		    htp.p('<TD WRAP ALIGN="CENTER">');
                    htp.anchor(curl => l_url,
                            ctext =>
                                htf.img(curl => '/OA_MEDIA/'|| mi.web_icon,
                                        cattributes => 'BORDER=0',
                                        calt => l_prompt)||
                                        htf.br||
                                        l_prompt,
                            cattributes =>
                            'TARGET="_top", onMouseOver="window.status='''||
                            icx_util.replace_onMouseOver_quotes(l_description)||
			    ''';return true"');
		    htp.p('</TD>');

	 	else -- mi.web_icon is null

		    f_counter := f_counter+1;
                    p_funcTable(f_counter) := htf.anchor(l_url,l_prompt,'','TARGET="_top", onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_description)||''';return true"');

                end if; -- mi.web_icon


	elsif (mi.sub_menu_id is not NULL) then -- sub menu

	    f_counter := f_counter+1;

	    l_level := 1;
	    l_encrypt_menu := icx_call.encrypt2(l_level+1||'*'||v_color||'*'||v_color_image||'*'||v_bullet_image||'*'||r.responsibility_id||'*'||mi.menu_id||'*'||'OracleApps.DRM'||'*'||mi.sub_menu_id||'*'||'OracleApps.DSM'||'**]', n_session_id);
	    p_funcTable(f_counter) := htf.anchor('OracleApps.DSM?Q='||l_encrypt_menu, l_prompt, '','TARGET="_top", onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_description)||''';return true"');

	else
	    raise e_data_error;
	end if; -- function or menu
	end if; -- no prompts

      end loop; -- Menu items

      -- if there's image associated menu entries
      if  i_counter > 0
      then
	  htp.tableRowClose;
      end if;

      -- if there's text URL associated menu entries
      if f_counter > 0
      then
          icx_admin_sig.displayTable(p_funcTable,f_counter,2, c_language_code,v_bullet_image);
      end if;
    end if;  -- l_count = 1

      htp.tableRowOpen;
      htp.tableData('','','','','','4','');
      htp.tableRowClose;

      p_funcTable := p_funcEmpty;       -- reset pl/sql table
      f_counter := 0;
      i_counter := 0;

      htp.tableRowOpen;
      htp.tableRowClose;

   end loop; -- Responsiblities
   htp.tableClose;

   if c_toolbar = 'Y'
   then

   htp.bodyClose;
   htp.htmlClose;

   end if; -- c_toolbar = 'Y'

end if;

exception
   when e_data_error
   then
       fnd_message.set_name('ICX','ICX_DATA_INCORRECT');
       c_error_msg := fnd_message.get;
       Fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
       c_login_msg := fnd_message.get;

       OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
   when others
   then
      if n_encryption_passed = 1
      then
         -- *************************
         --  something else failed
         -- *************************
         fnd_message.set_name('ICX','ICX_SESSION_FAILED');
         c_error_msg := fnd_message.get;
         fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
         c_login_msg := fnd_message.get;

         OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
      else
         -- *************************
         -- encryption failed
         -- *************************

              n_error_num := SQLCODE;
              c_error_msg := SQLERRM;
              select substr(c_error_msg,12,512) into c_display_error from dual;
              icx_util.add_error(c_display_error);
              icx_admin_sig.error_screen(c_display_error);
      end if;
end;


procedure DSM(Q in      varchar2) is

c_title                         varchar2(80);
c_prompts                       icx_util.g_prompts_table;
p_lang_code			varchar2(30);

begin

    OracleApps.DSM_frame(Q);

end DSM;


--  ***********************************************
--     procedure displaySubmenu
--  ***********************************************

procedure DSM_frame(Q		in	varchar2) is

l_userMenuName		varchar2(80);
l_menuURL		varchar2(2000);
l_level			number;
l_menuItems             menuItemTable;
l_resp_appl_id          number;
l_responsibility_id	number;
l_security_group_id     number;
Y 			varchar2(2000);
params 			icx_on_utilities.v80_table;
pass_ons		varchar2(2000);
v_color			varchar2(7);
v_color_image           varchar2(20);
v_bullet_image          varchar2(20);
l_encrypt_string	varchar2(2000);
l_temp_name		varchar2(2000);
l_temp_string		varchar2(2000);
c_language_code		varchar2(30);
l_menu_id		number;
c_function_id           number;
c_encrypted_func        varchar2(2000);
l_encrypt_menu		varchar2(2000);
i_counter		binary_integer default 0;
f_counter		binary_integer default 0;
l_user_menu_name        varchar2(80);
n_session_id		number;
l_menu_name		varchar2(240);
l_menu_description	varchar2(240);

-- error handling
e_data_error		exception;
n_encryption_passed	number := 1;
c_error_msg             varchar2(2000);
c_login_msg             varchar2(2000);
c_display_error         varchar2(240);
n_error_num             number;

-- non scalar type
f                       fnd_form_functions_vl%rowtype;
p_funcTable             icx_admin_sig.pp_table;
p_funcEmpty             icx_admin_sig.pp_table;
l_prompt		varchar2(30);
l_description		varchar2(240);

cursor 	menuItems is
select 	a.menu_id,
	a.entry_sequence,
	a.sub_menu_id,
	a.function_id,
	b.web_html_call,
        a.prompt,
        a.description,
	b.web_icon
from 	fnd_form_functions b,
	fnd_menu_entries_vl a
where 	a.menu_id = l_menu_id
and	a.function_id = b.function_id(+)
order   by a.entry_sequence;

begin

if icx_sec.validateSession
then

if Q is not null
then
    c_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

    Y:=icx_call.decrypt2(Q);
    icx_on_utilities.unpack_parameters(Y, params);

-- DEBUG --
--    htp.p('Length of params = '||params.count);
--    htp.nl;

    l_level := to_number(params(1));
    v_color := params(2);
    v_color_image := params(3);
    v_bullet_image := params(4);
    l_resp_appl_id := to_number(params(5));
    l_responsibility_id := to_number(params(6));
    l_security_group_id := to_number(params(7));
/*
	8 = menu_id
	9 = menu handler
	10 = sub_menu_id
	11 - sunb menu handler
*/

/*
    htp.p('table size='||params.COUNT);
    htp.nl;
    htp.p('l_level='||l_level);
    htp.nl;
    htp.p('v_color='||v_color);
    htp.nl;
    htp.p('v_color_image='||v_color_image);
    htp.nl;
    htp.p('v_bullet_image='||v_bullet_image);
    htp.nl;
    htp.p('l_responsibility_id='||l_responsibility_id);
    htp.nl;

*/

    l_encrypt_string := params(1)||'*'||params(2)||'*'||params(3)||'*'||
			params(4)||'*'||params(5)||'*'||params(6)||'*'||
			params(7)||'*'||params(8)||'*'||params(9);

    -- initialize menu items table
    for i in 1..l_level loop
	l_menuItems(i).menuId := to_number(params(2*i+6));
	l_menuItems(i).menuURL := params(2*i+7);

	if i = 1
	then
	-- get responsibilty name if root menu
	    select RESPONSIBILITY_NAME, DESCRIPTION
	    into   l_menu_name, l_menu_description
	    from   fnd_responsibility_vl
	    where  RESPONSIBILITY_ID = l_responsibility_id;
	else
	-- get the user menu name for the given menu id
	    select PROMPT, DESCRIPTION
	    into   l_menu_name, l_menu_description
	    from   fnd_menu_entries_vl
	    where  MENU_ID = l_menuItems(i-1).menuId
	    and    SUB_MENU_ID = l_menuItems(i).menuId;
	end if;

	if l_menu_name is null
	then
	    l_menu_name := l_menu_description;
	end if;
	l_menuItems(i).userMenuName := l_menu_name;

	-- construct the temporary that contains 1..i-1
	-- concatenation of the menuId and menuURL pairs
	if i=1 then
	    l_temp_string := l_menuItems(i).menuId||'*'||l_menuItems(i).menuURL;
	else
	    l_temp_string := l_temp_string||'*'||l_menuItems(i).menuId||'*'||l_menuItems(i).menuURL;
	end if;

	l_encrypt_string := i||'*'||v_color||'*'||v_color_image||'*'||v_bullet_image||'*'||l_resp_appl_id||'*'||l_responsibility_id||'*'||l_security_group_id||'*'||l_temp_string;
	n_encryption_passed := 0;
	pass_ons := icx_call.encrypt2(l_encrypt_string||'**]');
	n_encryption_passed := 1;
	-- at most three levels of menu on one line
	if ((i <> 1) and (MOD(i,3) = 1)) then
	    l_temp_name := l_temp_name||'<BR>';
	end if;

	if i = 1 then
	    l_temp_name := htf.anchor(l_menuItems(i).menuURL, l_menuItems(i).userMenuName,'','onMouseOver= "window.status='''||l_menu_description||''';return true" TARGET="_top"');
	elsif i = l_level then
	    -- record the menu id for the current menu
	    l_menu_id := l_menuItems(i).menuId;
	    l_temp_name := l_temp_name||' : '||l_menuItems(i).userMenuName;
	else
	    l_temp_name := l_temp_name||' : '||htf.anchor(l_menuItems(i).menuURL||'?Q='||pass_ons, l_menuItems(i).userMenuName,'','onMouseOver= "window.status='''||l_menu_description||''';return true" TARGET="_top"');
	end if;
    end loop;

    htp.htmlOpen;
    htp.headOpen;
    icx_util.copyright;
	js.scriptOpen;
        icx_admin_sig.help_win_script('/OA_DOC/'||c_language_code||'/aic/icxhlpw.htm');
        js.scriptClose;
	js.scriptOpen;
	htp.p('function new_browser(url,x,y)
    {
    attributes = "resizable=yes,scrollbars=yes,toolbar=yes,width="+x+",height="+y;
    new_browser = window.open(url, "new_browser", attributes);
    };');
        js.scriptClose;
	htp.title(l_menu_name);
    htp.headClose;

    icx_admin_sig.toolbar(language_code => c_language_code,
			  disp_mainmenu => 'N');

    htp.tableOpen('','','','','');
    htp.tableRowOpen;
    htp.tableData('<B><FONT COLOR=' || v_color || '>'||l_temp_name||'</B></FONT>','','','','','4','');
    htp.tableRowClose;
    htp.tableRowOpen;
    htp.tableData('<IMG SRC=/OA_MEDIA/'
                || v_color_image || ' height=3 width=500></B>',
                '','','','','4','');
    htp.tableRowClose;

      for mi in menuItems loop

        l_prompt := null;
        l_description := null;
        if mi.prompt is not null
        then
            l_prompt := mi.prompt;
            l_description := mi.description;
        elsif mi.description is not null
        then
            l_prompt := mi.description;
            l_description := mi.description;
        end if;

	if l_prompt is not null then
         if ((mi.sub_menu_id is NULL) AND (mi.function_id is not NULL)) then

		n_encryption_passed := 0;

      c_encrypted_func := icx_call.encrypt2(l_resp_appl_id||'*'||l_responsibility_id||'*'||l_security_group_id||'*'||mi.function_id||'*'||Q||'**]');

		n_encryption_passed := 1;

		if mi.web_icon is not null
                then
                    if i_counter = 0 then
                        htp.tableRowOpen;
                    end if;
                    i_counter := i_counter+1;

                    -- paint 4 icons on one line
                    if ((i_counter <> 1) AND (MOD(i_counter, 4) = 1))
                    then
                        htp.tableRowClose;
                        htp.tableRowOpen;
                    end if;

		    htp.tabledata
                    (htf.anchor(curl => 'OracleApps.RF?F='||c_encrypted_func,
                            ctext =>
                                htf.img(curl => '/OA_MEDIA/'|| mi.web_icon,
                                        cattributes => 'BORDER=0',
                                        calt => l_prompt)||
                                        htf.br||
                                        l_prompt,
                            cattributes =>
                            'TARGET="_top", onMouseOver="window.status='''||
                            icx_util.replace_onMouseOver_quotes(l_description)||
                            ''';return true"'),
                            calign      => 'center');
                else -- if no image associated to function

                    f_counter := f_counter+1;
		    if substr(mi.web_html_call,1,10) = 'javascript'
		    then
                        p_funcTable(f_counter) := htf.anchor(replace(mi.web_html_call,'"',''''),l_prompt,'','TARGET="_top", onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_description)||''';return true"');
		    else
                        p_funcTable(f_counter) := htf.anchor('OracleApps.RF?F='||c_encrypted_func,l_prompt,'','TARGET="_top", onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_description)||''';return true"');
		    end if;

                end if; -- mi.web_icon is not null

         elsif ((mi.function_id is NULL) AND (mi.sub_menu_id is not NULL)) then
-- sub menu
	    -- menu info. for next level

	    f_counter := f_counter+1;

	    n_encryption_passed := 0;
	    l_encrypt_menu := icx_call.encrypt2(l_level+1||'*'||v_color||'*'||v_color_image||'*'||v_bullet_image||'*'||l_resp_appl_id||'*'||l_responsibility_id||'*'||l_security_group_id||'*'||l_temp_string||'*'||mi.sub_menu_id||'*'||'OracleApps.DSM'||'**]');
	    n_encryption_passed := 1;

            p_funcTable(f_counter) := htf.anchor('OracleApps.DSM?Q='||l_encrypt_menu, l_prompt, '','TARGET="_top", onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_description)||''';return true"');

        elsif ((mi.function_id is not NULL) AND (mi.sub_menu_id is not NULL)) then
-- sub menu with function (icon)

            -- menu info. for next level

            n_encryption_passed := 0;
            l_encrypt_menu := icx_call.encrypt2(l_level+1||'*'||v_color||'*'||v_color_image||'*'||v_bullet_image||'*'||l_resp_appl_id||'*'||
                              l_responsibility_id||'*'||l_security_group_id||'*'||l_temp_string||'*'||mi.sub_menu_id||'*'||'OracleApps.DSM'||'**]');
            n_encryption_passed := 1;

                if mi.web_icon is not null
                then
                    if i_counter = 0 then
                        htp.tableRowOpen;
                    end if;
                    i_counter := i_counter+1;

                    -- paint 4 icons on one line
                    if ((i_counter <> 1) AND (MOD(i_counter, 4) = 1))
                    then
                        htp.tableRowClose;
                        htp.tableRowOpen;
                    end if;

                    htp.tabledata
                    (htf.anchor(curl => 'OracleApps.DSM?Q='||l_encrypt_menu,
                            ctext =>
                                htf.img(curl => '/OA_MEDIA/'|| mi.web_icon,
                                        cattributes => 'BORDER=0',
                                        calt => l_prompt)||
                                        htf.br||
                                        l_prompt,
                            cattributes =>
                            'TARGET="_top", onMouseOver="window.status='''||
                            icx_util.replace_onMouseOver_quotes(l_description)||
                            ''';return true"'),
                            calign      => 'center');

                else -- mi.web_icon is null

		    f_counter := f_counter+1;
                    p_funcTable(f_counter) := htf.anchor('OracleApps.DSM?Q='||l_encrypt_menu, l_prompt, '','TARGET="_top", onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(l_description)||''';return true"');

                end if; -- mi.web_icon

         else
            raise e_data_error;
         end if;
	end if; -- No Prompt

      end loop; -- Menu Items

            -- if there's image associated menu entries
      if  i_counter > 0
      then
          htp.tableRowClose;
      end if;

      -- if there's text URL associated menu entries
      if f_counter > 0
      then
          icx_admin_sig.displayTable(p_funcTable,f_counter,2, c_language_code,v_bullet_image);
      end if;

      p_funcTable := p_funcEmpty;       -- reset pl/sql table
      f_counter := 0;
      i_counter := 0;

    htp.tableClose;
    htp.bodyClose;
    htp.htmlClose;

end if;
end if;

exception
   when e_data_error
   then
       fnd_message.set_name('ICX','ICX_DATA_INCORRECT');
       c_error_msg := fnd_message.get;
       Fnd_message.set_name('ICX','ICX_CONTACT_WEBMASTER');
       c_login_msg := fnd_message.get;

       OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
   when others
   then
      if n_encryption_passed = 1
      then
         -- *************************
         --  something else failed
         -- *************************
         fnd_message.set_name('ICX','ICX_SESSION_FAILED');
         c_error_msg := fnd_message.get;
         fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
         c_login_msg := fnd_message.get;

         OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
      else
         -- *************************
         -- encryption failed
         -- *************************

              n_error_num := SQLCODE;
              c_error_msg := SQLERRM;
              select substr(c_error_msg,12,512) into c_display_error from dual;
              icx_util.add_error(c_display_error);
              icx_admin_sig.error_screen(c_display_error);
      end if;

end DSM_frame;

procedure LF(F in      VARCHAR2,
             P in      VARCHAR2,
             E IN      VARCHAR2) is
   --mputman 1545083
   --F is old style launch from forms using encrypt
   --E is new style launch from forms using encrypt2

l_parameters	icx_on_utilities.v80_table;
l_text		varchar2(2000);
l_user_id	number;
l_session_id	number;
l_resp_appl_id	varchar2(30);
l_responsibility_id varchar2(30);
l_security_group_id varchar2(30);
l_function_id	varchar2(30);
l_ip_address            varchar2(50);
l_profile_defined	boolean;
l_encrypted_function varchar2(600);
l_URL           varchar2(2000);
err_mesg varchar2(240);

begin

IF E IS NOT NULL THEN
	-- mputman 1545083
	-- new call from forms using decrypt2
	-- session_id of -99 must be used from forms for decrypt2 to work
	l_text := icx_call.decrypt2(E,-99);
delete from icx_text where text_id=E;commit;     --mputman added 1545083
ELSE
	l_text := icx_call.decrypt(F);

END IF;

icx_on_utilities.unpack_parameters(l_text,l_parameters);

l_user_id :=  l_parameters(1);
l_resp_appl_id := l_parameters(2);
l_responsibility_id := l_parameters(3);
l_security_group_id := l_parameters(4);
l_function_id := l_parameters(5);

IF icx_sec.validatesession THEN

   l_session_id := icx_sec.getsessioncookie;
   --mputman convert to execute effort
   --l_encrypted_function := icx_call.encrypt2(l_resp_appl_id||'*'||l_responsibility_id||'*'||
	--                     	l_security_group_id||'*'||l_function_id||'***]',l_session_id);

   l_encrypted_function := wfa_html.conv_special_url_chars(icx_call.encrypt(l_resp_appl_id||'*'||l_responsibility_id||'*'||
	                     	l_security_group_id||'*'||l_function_id||'***]'));
   --mputman convert to execute effort
   --l_URL := 'OracleApps.RF?F='||l_encrypted_function;
   l_URL := 'OracleSSWA.Execute?E='||l_encrypted_function;
   if P is not null
      then
--      l_URL := l_URL||'&'||'P='||icx_call.encrypt2(icx_call.decrypt(P),l_session_id);
      l_URL := l_URL||'&'||'P='||P;
      end if;
      htp.bodyOpen(cattributes => 'onLoad="top.location='''||l_URL||'''"');
      htp.bodyClose;

ELSE

   --following code was removed as applications standard method for connection is via PHP or Portal
   -- per bug 2065286 mputman

    --to re-enable pseudo sessions, uncomment the following block of code
/*
  l_session_id := icx_sec.createSession(l_user_id);
  l_encrypted_function := icx_call.encrypt2(l_resp_appl_id||'*'||l_responsibility_id||'*'||
  l_security_group_id||'*'||l_function_id||'***]',l_session_id);
  owa_util.mime_header('text/html', FALSE);
  icx_sec.sendsessioncookie(l_session_id);
  owa_util.http_header_close;
  l_URL := 'OracleApps.RF?F='||l_encrypted_function;
  if P is not null
  then
    l_URL := l_URL||'&'||'P='||icx_call.encrypt2(icx_call.decrypt(P),l_session_id);
  end if;
  htp.bodyOpen(cattributes => 'onLoad="top.location='''||l_URL||'''"');
  htp.bodyClose;
*/
   NULL;
END IF;   -- if added to support timeout feature.. if there is a session, use it, else create pseudo. mputman



exception
when NO_DATA_FOUND then   --mputman added 1545083
        fnd_message.set_name('ICX','ICX_SESSION_FAILED');
        err_mesg := fnd_message.get;
        icx_util.add_error(err_mesg);
        icx_admin_sig.error_screen(err_mesg);

when others then
--htp.p(SQLERRM);
  htp.p(dbms_utility.format_error_stack);

end;

--  ***********************************************
--     function createRFLink
--  ***********************************************
function createRFLink(p_text                   varchar2,
                      p_application_id         number,
                      p_responsibility_id      number,
                      p_security_group_id      number,
                      p_function_id            number,
                      p_target                 VARCHAR2,
                      p_session_id             NUMBER)
                      return varchar2 is

PRAGMA AUTONOMOUS_TRANSACTION;

l_RFLink       varchar2(2000);

begin

  -- 2758891 nlbarlow
  l_RFLink := icx_portlet.createExecLink(p_application_id => p_application_id,
                       p_responsibility_id => p_responsibility_id,
                       p_security_group_id => p_security_group_id,
                       p_function_id => p_function_id,
                       p_parameters => '',
                       p_target => p_target,
                       p_link_name => p_text,
                       p_url_only => 'N');

  return l_RFlink;

end createRFLink;


--  ***********************************************
--     procedure RF
--  ***********************************************

procedure RF(F in      varchar2,
             P in      VARCHAR2) is

l_url varchar2(2000);
l_session_id number;
l_text varchar2(2000);
l_parameters    icx_on_utilities.v80_table;
l_resp_appl_id number;
l_responsibility_id number;
l_security_group_id number;
l_function_id number;

/*
l_text varchar2(2000);
l_parameters    icx_on_utilities.v80_table;
l_resp_appl_id number;
l_responsibility_id number;
l_security_group_id number;
l_function_id number;
l_function_type varchar2(30);
l_menu_id number;
l_session_id number;
l_validate          boolean;
l_error_message varchar2(2000);
err_mesg varchar2(240);
err_num number;
l_user_id               number;
l_org_id		number;
l_multi_org_flag	varchar2(30);
l_profile_defined	boolean;
e_session_invalid       exception;
*/

begin

  l_session_id := icx_sec.getID(icx_sec.pv_session_id);

  l_text := icx_call.decrypt2(F,l_session_id);

  icx_on_utilities.unpack_parameters(l_text,l_parameters);
  l_resp_appl_id := nvl(l_parameters(1),178);
  l_responsibility_id := l_parameters(2);
  l_security_group_id := l_parameters(3);
  l_function_id := l_parameters(4);

  if P is null
  then
    l_text := null;
  else
    l_text := icx_call.decrypt2(P,l_session_id);
  end if;

  -- 2802333 nlbarlow
  l_url := icx_portlet.createExecLink(p_application_id => l_resp_appl_id,
                       p_responsibility_id => l_responsibility_id,
                       p_security_group_id => l_security_group_id,
                       p_function_id => l_function_id,
                       p_parameters => l_text,
                       p_url_only => 'Y');

  owa_util.mime_header('text/html', FALSE);

  owa_util.redirect_url(l_url);

  owa_util.http_header_close;

/*
  if l_text = '-1' then
    raise e_session_invalid;
  end if;

  if l_function_id is null
  then
     l_function_type := '';
  else
    select TYPE
    into   l_function_type
    from   FND_FORM_FUNCTIONS
    where  FUNCTION_ID = l_function_id;
  end if;
  l_menu_id := l_parameters(5);


  --mputman moved to after multiorg code
  --  l_validate := icx_sec.validateSessionPrivate(c_session_id => l_session_id,
  --                           c_resp_appl_id => l_resp_appl_id,
  --                           c_security_group_id => l_security_group_id,
  --                           c_responsibility_id => l_responsibility_id,
  --                           c_function_id => l_function_id,
  --                           c_update => FALSE);

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
  set 	 RESPONSIBILITY_APPLICATION_ID = l_resp_appl_id,
         RESPONSIBILITY_ID = l_responsibility_id,
         SECURITY_GROUP_ID = l_security_group_id,
         ORG_ID = l_org_id,
         FUNCTION_ID = l_function_id,
         FUNCTION_TYPE = l_function_type,
         MENU_ID = l_menu_id
  where	SESSION_ID = l_session_id;

  commit;

  l_validate := icx_sec.validateSessionPrivate(c_session_id => l_session_id,
                           c_resp_appl_id => l_resp_appl_id,
                           c_security_group_id => l_security_group_id,
                           c_responsibility_id => l_responsibility_id,
                           c_function_id => l_function_id,
                           c_update => FALSE);

  fnd_signon.audit_web_responsibility(icx_sec.g_login_id,
                                     l_responsibility_id,
                                     l_resp_appl_id,
                                     l_responsibility_id); -- mputman added for 1941776

  IF l_validate THEN

  -- nlbarlow 1574527
  icx_sec.g_validateSession_flag := false;

  runFunction(l_function_id,l_session_id,l_text,
              l_resp_appl_id,l_responsibility_id,l_security_group_id,
              l_menu_id,l_function_type,icx_sec.g_page_id);

  icx_sec.g_validateSession_flag := true;
  END IF;
*/

exception
  when others then
    icx_sec.g_validateSession_flag := true;
    --htp.p(SQLERRM);
       htp.p(dbms_utility.format_error_stack);
end;

--  ***********************************************
--     procedure runFunction
--  ***********************************************
procedure runFunction(c_function_id       in number,
		                n_session_id        in number,
                      c_parameters        in VARCHAR2,
                      p_resp_appl_id      in NUMBER,
                      p_responsibility_id in NUMBER,
                      p_security_group_id in NUMBER,
                      p_menu_id           in NUMBER,
                      p_function_type     in VARCHAR2,
                      p_page_id           in NUMBER) is

     f				fnd_form_functions%rowtype;
     c_procedure_call		varchar2(2000);
     c_anchor			varchar2(2000);
     l_dbc                      varchar2(240);
     l_message                  varchar2(240);
     l_web_html_call            varchar2(240);
     l_parameters		varchar2(2000);
     l_table_count		number;
     l_names			l_v80_table;
     l_values			l_v2000_table;
     l_responsibility_id	number;
     l_profile_defined		boolean;
     l_resp_web_host		varchar2(2000) := NULL;
     l_resp_web_agent		varchar2(2000) := NULL;
     l_oa_html                  varchar2(30);
     c_call			integer;
     c_dummy			integer;
     l_package			varchar2(100);
     v_dot_location		number;
     v_count			number := 0;
     c_error_msg		varchar2(80);
     c_login_msg		varchar2(80);
     l_encrypted_session_id	varchar2(240);
     l_encrypted_transaction_id	varchar2(240);
     index1 number;
     index2 number;
     l_resp_appl_id NUMBER;

     cursor procFind(p_name varchar2) is
        SELECT 'exists'
        FROM   FND_ENABLED_PLSQL
        WHERE  PLSQL_TYPE = 'PROCEDURE'
        AND    PLSQL_NAME = p_name
        AND    ENABLED = 'Y';

     cursor packFind(p_pack varchar2, p_proc varchar2) is
        SELECT 'exists'
        FROM   FND_ENABLED_PLSQL
        WHERE  (PLSQL_TYPE = 'PACKAGE' AND PLSQL_NAME = p_pack
        OR     PLSQL_TYPE = 'PACKAGE.PROCEDURE' AND PLSQL_NAME = p_proc)
        AND    ENABLED = 'Y';

begin

select * into f
from	fnd_form_functions
where	function_id = c_function_id;

/* bug 1142377, f.PARAMETERS may contain spaces.
if f.PARAMETERS is not null and c_parameters is null
then
  l_parameters := replace(f.PARAMETERS,' ','&');
elsif f.PARAMETERS is not null and c_parameters is not null
then
  l_parameters := replace(f.PARAMETERS,' ','&')||'&'||replace(c_parameters,' ','
&');
elsif f.PARAMETERS is null and c_parameters is not null
then
  l_parameters := replace(c_parameters,' ','&');
else
  l_parameters := '';
end if;
*/

if f.PARAMETERS is not null
then
  if instrb(f.PARAMETERS,'&') > 0
  then
    l_parameters := f.PARAMETERS;
  else
    l_parameters := replace(f.PARAMETERS,' ','&');
  end if;
end if;

if l_parameters is not null and c_parameters is not null
then
  l_parameters := l_parameters||'&';
end if;

if c_parameters is not null
then
  if instrb(c_parameters,'&') > 0
  then
    l_parameters := l_parameters||c_parameters;
  else
    l_parameters := l_parameters||replace(c_parameters,' ','&');
  end if;
end if;

-- 1790825, support [MENU_ID]

l_parameters :=  replace(l_parameters,'[MENU_ID]',icx_sec.g_menu_id);

c_anchor := '';

if f.type not in ('SERVLET','JSP', 'INTEROPJSP')
then

  select responsibility_id, RESPONSIBILITY_APPLICATION_ID
  into   l_responsibility_id, l_resp_appl_id
  from   icx_sessions
  where  session_id = n_session_id;


  if ((l_responsibility_id is not NULL) AND (l_resp_appl_id is not null))
  then
    select	web_host_name, web_agent_name
    into	l_resp_web_host, l_resp_web_agent
    from	fnd_responsibility
    where	responsibility_id = nvl(p_responsibility_id,l_responsibility_id) -- Bug 2726022
    and         application_id = nvl(p_resp_appl_id,l_resp_appl_id); -- Bug 2160456
  else
    l_resp_web_host := '';
    l_resp_web_agent := '';
  end if;

  if f.web_host_name is not null
  then
   if (instr(f.web_host_name, '://') = 0) then
      c_anchor := FND_WEB_CONFIG.PROTOCOL||'//'||f.web_host_name;
   else
      c_anchor := f.web_host_name;
   end if;
  elsif l_resp_web_host is not null
  then
   if (instr(l_resp_web_host, '://') = 0) then
    c_anchor := FND_WEB_CONFIG.PROTOCOL||'//'||l_resp_web_host;
   else
      c_anchor := l_resp_web_host;
   end if;
  end if;

  if f.web_agent_name is not null
  then
    c_anchor := c_anchor||'/'||f.web_agent_name;
  elsif l_resp_web_agent is not null
  then
    c_anchor := c_anchor||'/'||l_resp_web_agent;
  end if;

end if; -- not in ('SERVLET','JSP')

/* Supposed to support MSOB
if c_anchor is null
then
        fnd_profile.get_specific(
                name_z                  => 'APPS_WEB_AGENT',
                responsibility_id_z     => l_responsibility_id,
                val_z                   => c_anchor,
                defined_z               => l_profile_defined);

	if not l_profile_defined
	then
	    c_anchor := '';
	end if;
end if;
*/

if c_anchor is not null
then
   if f.web_html_call is not null
   then
       c_anchor := c_anchor||'/'||f.web_html_call;
   end if;

   if l_parameters is not null
   then
       c_anchor := c_anchor||'?';
       if f.web_ENCRYPT_PARAMETERS = 'Y'
       then
           unpackParameters(l_parameters,l_names,l_values);
           l_table_count := l_names.COUNT;
   	   for i in 1..l_table_count loop
               if i > 1
               then
                   c_anchor := c_anchor||',';
               end if;
	       c_anchor := c_anchor||l_names(i)||'='||icx_call.encrypt2(l_values(i), n_session_id);
	   end loop;
      else
            c_anchor := c_anchor||l_parameters;
      end if;
   end if;

   owa_util.redirect_url(c_anchor);

elsif f.type = 'SERVLET' then

   l_encrypted_session_id := icx_call.encrypt3(n_session_id);

   fnd_profile.get(name => 'APPS_SERVLET_AGENT',
                    val => c_anchor);

   c_anchor := FND_WEB_CONFIG.trail_slash(c_anchor)||f.WEB_HTML_CALL||
               '?dbc='||FND_WEB_CONFIG.DATABASE_ID||
               '&'||'sessionid='||l_encrypted_session_id;

   if l_parameters is not null then
      c_anchor := c_anchor || '&' || l_parameters;
   end if;

   owa_util.redirect_url(c_anchor);

elsif f.type = 'JSP' or f.type = 'INTEROPJSP' then

   l_encrypted_session_id := icx_call.encrypt3(n_session_id);

   l_web_html_call := replace(f.WEB_HTML_CALL,'apps.jsp','OA.jsp');

   if (instr(l_web_html_call,'OA.jsp') > 0)
   then
     fnd_profile.get(name => 'APPS_FRAMEWORK_AGENT',
                     val => c_anchor);
     l_message := 'Applications Framework Agent';
   else
     fnd_profile.get(name => 'APPS_SERVLET_AGENT',
                     val => c_anchor);
     l_message := 'Applications Servlet Agent';
   end if;

   if(c_anchor is null) then
      htp.p(l_message||' not set, contact Administrator');
   else
     c_anchor := FND_WEB_CONFIG.TRAIL_SLASH(c_anchor);

     index1 := INSTRB(c_anchor, '//', 1) + 2;      /* skip 'http://' */

     index2 := INSTRB(c_anchor, '/', index1);  /* get to 'http://serv:port/' */

     if(index1 <> index2) AND (index1 <> 2) AND (index2 > 2)
           AND (index1 is not NULL) AND (index2 is not NULL) then
         c_anchor := FND_WEB_CONFIG.TRAIL_SLASH(SUBSTRB(c_anchor, 1, index2-1));
     else
         htp.p('Invalid '||l_message||', contact Administrator');
         c_anchor := '';
     end if;

     l_encrypted_transaction_id :=
       icx_call.encrypt3(icx_sec.createTransaction(
         n_session_id,p_resp_appl_id,p_responsibility_id,p_security_group_id,
         p_menu_id,c_function_id,p_function_type,p_page_id));

     c_anchor := FND_WEB_CONFIG.trail_slash(c_anchor)||
                 FND_WEB_CONFIG.trail_slash(icx_sec.g_OA_HTML)||
                 l_web_html_call;

     fnd_profile.get(name => 'APPS_DATABASE_ID',
                     val => l_dbc);

     if l_dbc is null
     then
       l_dbc := FND_WEB_CONFIG.DATABASE_ID;
     end if;

     if (instr(l_web_html_call,'?') > 0)
     then
       c_anchor := c_anchor||'&'||'dbc='||l_dbc;
     else
       c_anchor := c_anchor||'?dbc='||l_dbc;
     end if;

     c_anchor := c_anchor||'&'||'language_code='||icx_sec.g_language_code||
                 '&'||'transactionid='||l_encrypted_transaction_id;

     if (instr(c_anchor,'OA.jsp') = 0)
     then -- Other jsps still require sessionid
       c_anchor := c_anchor||'&'||'sessionid='||l_encrypted_session_id;
     end if;

     if l_parameters is not null then
        c_anchor := c_anchor || '&' || l_parameters;
     end if;
   end if;

   if c_anchor is not null
   then
      owa_util.redirect_url(c_anchor);
   end if;

else
   -- ********************
   -- c_anchor is null
   -- ********************

   c_procedure_call := upper(f.web_html_call);

   v_dot_location := instr(c_procedure_call, '.');
   if (v_dot_location = 0) then
      --no period so this is a procedure
      for prec in procFind(c_procedure_call) loop
          v_count := v_count + 1;
      end loop;
   else
      -- this is a package.procedure
      -- check if either the package is enabled or the package.procedure
      l_package := substr(c_procedure_call, 0, v_dot_location-1);
      for prec in packFind(l_package, c_procedure_call) loop
          v_count := v_count + 1;
      end loop;
   end if;

   if (v_count > 0)
   then

      if l_parameters is not null
      then
         unpackParameters(l_parameters,l_names,l_values);
         c_procedure_call := c_procedure_call||'(';
         l_table_count := l_names.COUNT;
         for i in 1..l_table_count loop
            if i > 1
	    then
	       c_procedure_call := c_procedure_call||',';
	    end if;
            if f.web_ENCRYPT_PARAMETERS = 'Y'
            then
               c_procedure_call := c_procedure_call||l_names(i)||' => '||icx_call.encrypt2(l_values(i), n_session_id);
            else
               c_procedure_call := c_procedure_call||l_names(i)||' => '''||l_values(i)||'''';
            end if;
         end loop;
         c_procedure_call := c_procedure_call||')';
      end if;

      c_call := dbms_sql.open_cursor;
      dbms_sql.parse(c_call,'begin '||c_procedure_call||'; end;',dbms_sql.native);
      c_dummy := dbms_sql.execute(c_call);
      dbms_sql.close_cursor(c_call);

   else
      fnd_message.set_name('ICX','ICX_INVALID_FUNCTION');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');

   end if;

end if;

end;

--  ***********************************************
--     procedure unpackParameters
--  ***********************************************

procedure unpackParameters(p_parameters in varchar2,
                           p_names      out nocopy l_v80_table,
                           p_values     out nocopy l_v2000_table) is
Y               varchar2(4000);
l_length        number(15);
c_param         number(15);
c_count         number(15);
c_char          varchar2(30);
c_word          varchar2(2000);
c_value         number(15);

begin

Y := p_parameters||'&]';
l_length := length(Y)-1;
c_param := 1;
c_count := 0;
c_char := '';
c_word := '';

while c_count <= l_length loop
        if c_char = '=' or c_char = '&'
        then
                if c_char = '='
                then
                        p_names(c_param) := c_word;
                else
                        p_values(c_param) := c_word;
                        c_param := c_param + 1;
                end if;
                c_count := c_count + 1;
                c_char := substr(Y,c_count,1);
                c_word := '';
        else
                c_word := c_word||c_char;
                c_count := c_count + 1;
                c_char := substr(Y,c_count,1);
        end if;
end loop;

end;

--  ***********************************************
--     procedure unpackParameters
--  ***********************************************

procedure unpackParameters(p_parameters in varchar2,
                           p_names      out nocopy l_v80_table,
                           p_values     out nocopy l_v240_table) is
Y 		varchar2(2000);
l_length	number(15);
c_param         number(15);
c_count         number(15);
c_char          varchar2(30);
c_word          varchar2(240);
c_value		number(15);

begin

Y := p_parameters||'&]';
l_length := length(Y)-1;
c_param := 1;
c_count := 0;
c_char := '';
c_word := '';

while c_count <= l_length loop
        if c_char = '=' or c_char = '&'
        then
		if c_char = '='
		then
			p_names(c_param) := c_word;
		else
                	p_values(c_param) := c_word;
                	c_param := c_param + 1;
		end if;
                c_count := c_count + 1;
                c_char := substr(Y,c_count,1);
                c_word := '';
	else
                c_word := c_word||c_char;
                c_count := c_count + 1;
                c_char := substr(Y,c_count,1);
        end if;
end loop;

end;

--  ***********************************************
--     function getFunctions
--  ***********************************************
function getFunctions
	return varchar2 is

	c_user_id		number;
	c_responsibility_id 	number;
	c_anchor		varchar2(2000);
	c_error_msg		varchar2(2000);
	c_login_msg		varchar2(2000);
	c_known_as		varchar2(80);
	c_string		varchar2(10000);
	n_session_id		number;

	cursor resps is
		select	a.responsibility_id,a.responsibility_name,
		web_HOST_NAME,web_AGENT_NAME
	from  	fnd_responsibility_vl a,
		FND_USER_RESP_GROUPS b,
		icx_sessions c
	where   n_session_id = c.session_id
	and	c.user_id = b.user_id
        and     a.version = 'W'
        and     a.start_date <= sysdate
        and     (a.end_date is null or a.end_date > sysdate)
        and     b.start_date <= sysdate
        and     (b.end_date is null or b.end_date > sysdate)
	order by responsibility_name;

	cursor functions is
        	select	user_function_name,description,
			web_HOST_NAME,web_AGENT_NAME,web_HTML_CALL,
			PARAMETERS
        	from	fnd_form_functions_vl c,
			fnd_resp_functions a
        	where	c_responsibility_id = a.responsibility_id
		and	a.action_id = c.function_id
		order by user_function_name;

begin

   /*** Get the cookie for this session.
	and find out other information from the db
    ***/

 n_session_id := icx_sec.getsessioncookie;

 if (n_session_id <= 0)
 then
      fnd_message.set_name('FND','FND_SESSION_ICX_EXPIRED');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
 else
   c_string := '';
   for i in Resps loop
        c_responsibility_id := i.responsibility_id;

	c_anchor := '';
	for r in functions loop

        c_anchor := r.web_html_call;

        if r.web_agent_name is not null
        then
                c_anchor := '/'||r.web_agent_name||'/'||c_anchor;
        end if;

        if r.web_host_name is not null
        then
	   if (instr(r.web_host_name, '://') = 0) then
	      c_anchor := FND_WEB_CONFIG.PROTOCOL||'//'||r.web_host_name||'/';
	   else
	      c_anchor := r.web_host_name||'/';
	   end if;

                c_anchor := FND_WEB_CONFIG.PROTOCOL||'//'||r.web_host_name||c_anchor;
        end if;

	if r.PARAMETERS is not null
	then
	    c_anchor := c_anchor||'?'||r.PARAMETERS;
	end if;

	  c_string := c_string||'nav_win.document.write('''||htf.anchor(c_anchor,r.user_function_name,'','TARGET=mainWindow.location')||''');'||htf.nl;

	end loop;
   end loop;
 end if;
return c_string;

end;

procedure displayWebUser is

l_title			varchar2(80);
l_helpmsg		varchar2(240);
l_helptitle		varchar2(240);
l_actions		icx_cabo.actionTable;
l_toolbar		icx_cabo.toolbar;
username		varchar2(30);
c_error_msg		varchar2(2000);
c_login_msg		varchar2(2000);
l_agent                 varchar2(240);
l_dbhost                varchar2(240);
l_tabicons              icx_cabo.tabiconTable;
l_prompts icx_util.g_prompts_table;--mputman added 1402459

BEGIN

   icx_util.getprompts(601, 'ICX_OBIS_TOOLBAR', l_title, l_prompts); --mputman added for bug 1402459
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);

    htp.headopen;
    htp.p('<SCRIPT>');

    icx_admin_sig.help_win_script('GENPREF', null, 'FND');

    htp.p('</SCRIPT>');
    htp.headclose;

  l_toolbar.title := wf_core.translate('ICX_PREFERENCES');
  l_toolbar.help_url := 'javascript:top.help_window()';
  fnd_message.set_name('ICX','ICX_HELP');
  l_toolbar.help_mouseover := FND_MESSAGE.GET;

  l_toolbar.menu_url :=owa_util.get_cgi_env('SCRIPT_NAME')||'/OracleNavigate.Responsibility'; --mputman added for bug 1402459
  l_toolbar.menu_mouseover := l_prompts(7); -- from region ICX_OBIS_TOOLBAR mputman added for bug 1402459

  IF (icx_sec.g_mode_code <> 'SLAVE') THEN
  --mputman isolated menubutton to exclude slave mode 1747045
  l_toolbar.custom_option1_url := icx_plug_utilities.getPLSQLagent ||
                                  'OracleMyPage.Home';
  l_toolbar.custom_option1_mouseover := wf_core.translate('RETURN_TO_HOME');
  l_toolbar.custom_option1_gif := '/OA_MEDIA/FNDHOME.gif';
  l_toolbar.custom_option1_mouseover_gif := '/OA_MEDIA/FNDHOME.gif';
  END IF;

  l_helpmsg := wf_core.translate('ICX_PREF_DESC');
  --l_helpmsg := '';
  l_helptitle := wf_core.translate('ICX_PREFERENCES');

  icx_cabo.container(p_toolbar => l_toolbar,
                     p_helpmsg => l_helpmsg,
                     p_helptitle => l_helptitle,
                     p_url => owa_util.get_cgi_env('SCRIPT_NAME')||'/oracleapps.displayWebUserlocal?p_message_flag=N',
                     p_action => TRUE);

exception
   when others then
      fnd_message.set_name('ICX','ICX_SESSION_FAILED');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
end;


--  ***********************************************
--     Procedure displayWebUserlocal
--  ***********************************************
procedure displayWebUserlocal(p_message_flag VARCHAR2) is

u			fnd_user%rowtype;
c_user_id 		varchar2(15);
c_lang_code		varchar2(30);
c_language_code		varchar2(30);
c_title 		varchar2(80);
c_prompts		icx_util.g_prompts_table;
l_message		varchar2(2000);
l_pwlen                 number;
c_error_msg		varchar2(2000);
c_login_msg		varchar2(2000);
c_nls_lang		varchar2(30);
c_iso_lang		varchar2(10);
c_iso_terr		varchar2(10);
l_date_format		varchar2(100);
l_mail_pref             varchar2(20);
l_curr_mail_pref         varchar2(20);
c_description		varchar2(255);
c_browser                varchar2(400):= owa_util.get_cgi_env('HTTP_USER_AGENT');
l_lookup_codes		icx_util.g_lookup_code_table;
l_lookup_meanings	icx_util.g_lookup_meaning_table;
l_enc_lookup_codes		icx_util.g_lookup_code_table;
l_enc_lookup_meanings	icx_util.g_lookup_meaning_table;
l_numeric_lookup_codes		icx_util.g_lookup_code_table;
l_numeric_lookup_meanings	icx_util.g_lookup_meaning_table;
username                varchar2(30);
dm_node_id              number;
dm_node_name            varchar2(240);
l_actions               icx_cabo.actionTable;
l_actiontext            varchar2(2000);
l_numeric_characters    varchar2(30);
l_territory             varchar2(30);
l_timezone              NUMBER;
l_timezone_code         VARCHAR2(200);
l_encoding              VARCHAR2(200);
l_profile_defined       boolean;
l_auth_mode             VARCHAR2(50);
l_tz_enabled            VARCHAR2(10);
l_counter               NUMBER;
   TYPE t_node_id IS TABLE OF fnd_dm_nodes.node_id%TYPE;
   TYPE t_node_name IS TABLE OF fnd_dm_nodes.node_name%TYPE;
   v_node_id t_node_id;
   v_node_name t_node_name;


  cursor get_lang is
        SELECT LANGUAGE_CODE,
               NLS_LANGUAGE,
               DESCRIPTION,
               ISO_LANGUAGE,
               ISO_TERRITORY
        FROM   FND_LANGUAGES_VL
        WHERE  INSTALLED_FLAG in ('I', 'B')
        ORDER BY DESCRIPTION;

  cursor get_mail is
        select NAME, TEXT
        from WF_RESOURCES
        where TYPE = 'WFTKN'
        and NAME LIKE 'WFPREF_MAILP%'
        and LANGUAGE = userenv('LANG')
        ORDER BY NAME;

  CURSOR get_dm is
   SELECT  node_id, node_name
   FROM   fnd_dm_nodes
   ORDER  BY node_name;

  cursor get_territory is
     select t.territory_short_name territory_name,
	    t.nls_territory
     from   fnd_territories_vl t,
	    v$nls_valid_values v
     where t.nls_territory = v.value
     and   v.parameter = 'TERRITORY'
     order by t.territory_short_name;

     CURSOR get_tz IS
     SELECT '(GMT ' ||
       rtrim(tz_offset(timezone_code),chr(0))
      || ') ' || name DISPLAYED_NAME
       , upgrade_tz_id PROFILE_VALUE
     FROM FND_TIMEZONES_VL
     WHERE enabled_flag = 'Y'
     ORDER BY gmt_offset, name;


begin

  if (icx_sec.validateSession) then

     select  * into u
     from    fnd_user
     where   user_id = icx_sec.g_user_id;

     c_language_code     := icx_sec.g_language_code;
     l_date_format       := icx_sec.g_date_format;
     l_date_format       := replace(upper(l_date_format), 'YYYY', 'RRRR');
     l_date_format       := replace(l_date_format, 'YY', 'RRRR');
     l_territory         := icx_sec.g_nls_territory;
     l_numeric_characters := icx_sec.g_numeric_characters;

     --get profile value for CLIENT_TIMEZONE_ID
     --decode into displayed_name
        fnd_profile.get_specific(
                name_z                  => 'CLIENT_TIMEZONE_ID',
                user_id_z               => icx_sec.g_user_id,
                val_z                   => l_timezone,
                defined_z               => l_profile_defined);

        fnd_profile.get_specific(
                name_z                  => 'FND_NATIVE_CLIENT_ENCODING',
                user_id_z               => icx_sec.g_user_id,
                val_z                   => l_encoding,
                defined_z               => l_profile_defined);


        fnd_profile.get_specific(
                name_z                  => 'ENABLE_TIMEZONE_CONVERSIONS',
                user_id_z               => icx_sec.g_user_id,
                val_z                   => l_tz_enabled,
                defined_z               => l_profile_defined);

        BEGIN
          SELECT 'LDAP'
          INTO l_auth_mode
          FROM fnd_user
          WHERE user_id = icx_sec.g_user_id
          AND upper(encrypted_user_password)='EXTERNAL';

          EXCEPTION
           WHEN no_data_found THEN
           l_auth_mode :='FND';
        END;

         --toggle this off if not using timezones
         IF l_tz_enabled = 'Y' THEN

        BEGIN
            SELECT '(GMT ' ||
              rtrim(tz_offset(timezone_code),chr(0))
             || ') ' || name DISPLAYED_NAME
            INTO
              l_timezone_code
            FROM FND_TIMEZONES_VL
            WHERE enabled_flag = 'Y'
            AND upgrade_tz_id=l_timezone;
            EXCEPTION WHEN no_data_found THEN
            NULL;--what do we do here?
        END;
     -- timezone
         END IF;


     if (instr(l_date_format, 'RR') > 0) then
	 if (instr(l_date_format, 'RRRR')  = 0) then
	     l_date_format := replace(l_date_format, 'RR', 'RRRR');
	 end if;
     end if;
     icx_util.getLookups('ICX_DATE_FORMATS',l_lookup_codes,l_lookup_meanings);
     icx_util.getLookups('FND_CLIENT_CHARACTER_SETS',l_enc_lookup_codes,l_enc_lookup_meanings);
     icx_util.getLookups('ICX_NUMERIC_CHARACTERS',l_numeric_lookup_codes,l_numeric_lookup_meanings);

     -- Check session and current user
     wfa_sec.GetSession(username);
     username := upper(username);
     l_curr_mail_pref := wf_pref.get_pref (username, 'MAILTYPE');
     -- get the document management home node information
     fnd_document_management.get_dm_home (username, dm_node_id, dm_node_name);

     htp.htmlOpen;
     htp.headOpen;
     icx_util.copyright;


     htp.p('<SCRIPT LANGUAGE="JavaScript">');
     htp.p('<!-- Hide from old Browsers');
     icx_admin_sig.help_win_script('/OA_DOC/'||c_language_code||'/aic/icxhlpmp.htm');

     IF icx_sec.g_mode_code = 'SLAVE' THEN
        --mputman added to close window when in slave mode 1747045
        htp.p('function cancelpref() {
              parent.window.name="";
               parent.window.close();
              }');
     else
     if icx_sec.g_mode_code in ( '115J', '115P', '115X') then
        htp.p('function cancelpref() {
               top.location.href = "'||owa_util.get_cgi_env('SCRIPT_NAME')||'/OracleNavigate.Responsibility";
              }'); -- mputman changed for bug 1402459

     else
        htp.p('function cancelpref() {
              top.location.href = "'||wfa_html.base_url ||'/OracleNavigate.Responsibility";
        }');
     end if;
     END IF;

     htp.p('function savepref() {
     var l_alert = false');

     l_pwlen := to_number(nvl(Fnd_Profile.Value('SIGNON_PASSWORD_LENGTH'), 5));
     fnd_message.set_name('FND','PASSWORD-LONGER');
     fnd_message.set_token('LENGTH',to_char(l_pwlen));
     l_message := icx_util.replace_quotes(fnd_message.get);
     htp.p('    var lpwd = document.userpref.i_5.value;
             if (lpwd.length <  '||to_char(l_pwlen)||' '||'&'||'&'||' document.userpref.i_4.value != "") {
                alert('''||l_message||''');
                document.userpref.i_5.focus();
                l_alert = true
                };');

     fnd_message.set_name('ICX','ICX_REQU_REPAS');
     l_message := icx_util.replace_quotes(fnd_message.get);
     htp.p('    if ((document.userpref.i_5.value != document.userpref.i_6.value)||(document.userpref.i_4.value == "" '||'&'||'&'||' document.userpref.i_5.value !="")) {
        alert('''||l_message||''');
        document.userpref.i_6.focus();
                l_alert = true
                };');

     htp.p('    if (l_alert==false) {
                   document.userpref.submit()
             };
	}');


     htp.p('// -->');
     htp.p('</SCRIPT>');
     htp.headClose;

     htp.p('<BODY bgcolor="#CCCCCC">');
     icx_util.getPrompts(601,'ICX_PREFERENCE',c_title,c_prompts);

     /* use Oracle logo */
--   icx_admin_sig.toolbar(language_code => c_language_code);
--   htp.title(c_title);
--   htp.p('<H2>'||c_title||'</H2>');

     htp.br;
     htp.formOpen('OracleApps.UUI','POST','','','NAME="userpref"');
         htp.tableOpen(calign=>'CENTER');
             htp.tableRowOpen;                                -- Known As
		 htp.tableData(c_prompts(1),'RIGHT');
		 htp.tableData(htf.formText('i_1','40','50',icx_util.replace_alt_quotes(u.description))); -- added call to replcae quotes 2637147
   	     htp.tableRowClose;

	     htp.tableRowOpen;                                -- Language
		 htp.tableData(c_prompts(2),'RIGHT');
		 htp.p('<TD ALGIN="LEFT">');
		 htp.p('<SELECT NAME="i_2" SIZE="1">');
		 for prec in get_lang loop
		     if (prec.LANGUAGE_CODE = c_language_code) then
			htp.p('<OPTION VALUE="' || prec.NLS_LANGUAGE ||
				       '" SELECTED> ' || prec.description );
		     else
			htp.p('<OPTION VALUE="' || prec.NLS_LANGUAGE ||
				       '"> ' || prec.description );
		     end if;
		 end loop;
		 htp.p('</SELECT>');
	         htp.p('</TD>');
             htp.tableRowClose;
    --toggle this off if not using timezones
         IF l_tz_enabled = 'Y' THEN

    --TZ
	     htp.tableRowOpen;                                -- Timezone
		 htp.tableData(c_prompts(11),'RIGHT');
		 htp.p('<TD ALGIN="LEFT">');
		 htp.p('<SELECT NAME="i_11" SIZE="1">');
		 htp.p('<OPTION VALUE="''"> ');
       for tz in get_tz loop
          --need if tz%ROWCOUNT>0 then ... here
		     if (tz.PROFILE_VALUE = l_timezone) then
			htp.p('<OPTION VALUE="' || tz.PROFILE_VALUE ||
				       '" SELECTED> ' || tz.DISPLAYED_NAME );
		     else
			htp.p('<OPTION VALUE="' || tz.PROFILE_VALUE ||
				       '"> ' || tz.DISPLAYED_NAME );
		     end if;
		 end loop;
		 htp.p('</SELECT>');
	         htp.p('</TD>');
             htp.tableRowClose;

    --end TZ
    ELSE
	     htp.formHidden('i_11',l_timezone);-- timezone hidden/disabled

         END IF;
           --FND CLIENT ENCODING
	     htp.tableRowOpen;
		 htp.tableData(c_prompts(12),'RIGHT');
		 htp.p('<TD ALGIN="LEFT">');
		 htp.p('<SELECT NAME="i_12" SIZE="1">');
			htp.p('<OPTION VALUE="''"> ');

		 for i in 1..l_enc_lookup_meanings.COUNT loop
		     if (l_encoding = l_enc_lookup_codes(i)) then
			htp.p('<OPTION VALUE="' || l_enc_lookup_codes(i) ||
				       '" SELECTED> ' || l_enc_lookup_meanings(i) );
		     else
			htp.p('<OPTION VALUE="' || l_enc_lookup_codes(i) ||
				       '"> ' || l_enc_lookup_meanings(i) );
		     end if;
		 end loop;
		 htp.p('</SELECT>');
	         htp.p('</TD>');
             htp.tableRowClose;


           --fce


             htp.tableRowOpen;                                -- date format
		 htp.tableData(c_prompts(3),'RIGHT');
		 fnd_message.set_name('ICX','ICX_RRRR');
		 l_message := fnd_message.get;
		 htp.p('<TD ALGIN="LEFT">');
		 htp.formSelectOpen('i_3');
		 for i in 1..l_lookup_meanings.COUNT loop
		     if l_date_format = l_lookup_codes(i)
		     then
			 htp.formSelectOption(to_char(to_date('31/12/2000','DD/MM/RRRR'),l_lookup_codes(i)),'SELECTED','VALUE="'||l_lookup_codes(i)||'"');
		     else
			 htp.formSelectOption(to_char(to_date('31/12/2000','DD/MM/RRRR'),l_lookup_codes(i)),'','VALUE="'||l_lookup_codes(i)||'"');
		     end if;
		 end loop;
		 htp.formSelectClose;
		 htp.p('</TD>');
   	     htp.tableRowClose;

	     htp.tableRowOpen;                          -- nls numeric characters
		  htp.tableData(c_prompts(9), 'RIGHT');
		  htp.p('<TD ALGIN="LEFT">');
		  htp.p('<SELECT NAME="i_9" SIZE="1">');
                  -- change to use lookup for icx_numeric_characters
                  FOR i IN 1..l_numeric_lookup_meanings.count LOOP
                    /*
                    if l_numeric_characters = ',.'
                    then
                       htp.p('<OPTION VALUE=".,"> ' || '10,000.00' );
                       htp.p('<OPTION SELECTED VALUE=",."> ' || '10.000,00' );
                    else
   	                 htp.p('<OPTION SELECTED VALUE=".,"> ' || '10,000.00' );
   	                 htp.p('<OPTION VALUE=",."> ' || '10.000,00' );
                    end if;
                    */
		              if (l_numeric_characters = l_numeric_lookup_codes(i)) then
			              htp.p('<OPTION VALUE="' || l_numeric_lookup_codes(i) ||
				                 '" SELECTED> ' || l_numeric_lookup_meanings(i) );
		              else
			              htp.p('<OPTION VALUE="' || l_numeric_lookup_codes(i) ||
				                 '"> ' || l_numeric_lookup_meanings(i) );
		              end if;
                  END LOOP;

		  htp.p('</SELECT>');
		  htp.p('</TD>');
	     htp.tableRowClose;

	     htp.tableRowOpen;                          -- nls territory
		  htp.tableData(c_prompts(10), 'RIGHT');
		  htp.p('<TD ALGIN="LEFT">');
		  htp.p('<SELECT NAME="i_10" SIZE="1">');

		  for trec in get_territory loop
		    if (trec.nls_territory = l_territory) then
 		       htp.p('<OPTION VALUE="' || trec.nls_territory || '" SELECTED> ' || trec.territory_name);
		    else
		       htp.p('<OPTION VALUE="' || trec.nls_territory || '"> ' || trec.territory_name );
	            end if;
		  end loop;

		  htp.p('</SELECT>');
		  htp.p('</TD>');
	     htp.tableRowClose;

             htp.tableRowOpen;                                -- Mail Preference
                 htp.tableData(wf_core.translate('WFPREF_SENDEMAIL_PROMPT'),'RIGHT');
	         htp.p('<TD ALGIN="LEFT">');
                 htp.p('<SELECT NAME="i_7" SIZE="1">');

	         /*
	         ** The get_mail cursor is used to fetch the codes and display names
	         ** used for the mail preference values.
	         ** I've named the prompts for the mail options appropriately so
	         ** they can be uniquely fetched in a list and dropped easily into
	         ** a poplist.  The codes for mail preferences are
	         ** MAILHTML, MAILATTH, MAILTEXT, etc. The corresponding prompts for
	         ** these options are  WFPREF_MAILP1-MAILHTML, WFPREF_MAILP2-MAILATTH,
	         ** WFPREF_MAILP3-MAILTEXT etc.  I drop  WFPREF_MAILP#- part and leave
	         ** the code that we'll save in the database for this preference.
	         ** The WFPREF_MAILP# portion allows me to sort these as I wish.
	         */
	         for mail in get_mail loop
	             l_mail_pref := SUBSTR(mail.name, INSTR(mail.name, '-') + 1);

	             if (l_mail_pref = l_curr_mail_pref) then
		        htp.p('<OPTION VALUE="' || l_mail_pref || '" SELECTED> ' || mail.text);
		     else
		       htp.p('<OPTION VALUE="' || l_mail_pref ||'"> ' || mail.text );
		     end if;
	         end loop;

	         htp.p('</SELECT>');
	         htp.p('</TD>');
   	     htp.tableRowClose;

           ---------
      OPEN get_dm;
      FETCH get_dm bulk collect INTO v_node_id, v_node_name;
      CLOSE get_dm;
      IF v_node_id.count > 0  THEN
         htp.tableRowOpen;                                -- DM Home Preference
         htp.tableData(wf_core.translate('WFPREF_DMHOME_PROMPT'),'RIGHT');
         htp.p('<TD ALGIN="LEFT">');
         htp.p('<SELECT NAME="i_8" SIZE="1">');
         FOR counter IN 1..v_node_id.count LOOP


               if (v_node_id(counter) = dm_node_id) then

                htp.p('<OPTION VALUE="' || v_node_id(counter) ||
                 '" SELECTED> ' || v_node_name(counter));

              else

                htp.p('<OPTION VALUE="' || v_node_id(counter) ||
                '"> ' || v_node_name(counter));

               end if;

            end loop;

            htp.p('</SELECT>');
            htp.p('</TD>');
            htp.tableRowClose;

      ELSE
         htp.formHidden('i_8','');-- DM Home
      END IF;
       /*
           ---------
	     htp.tableRowOpen;                                -- DM Home Preference
		  htp.tableData(wf_core.translate('WFPREF_DMHOME_PROMPT'),'RIGHT');
		  htp.p('<TD ALGIN="LEFT">');
		  htp.p('<SELECT NAME="i_8" SIZE="1">');

		  for dm in get_dm loop
           if (dm.node_id = dm_node_id) then

		      htp.p('<OPTION VALUE="' || dm.node_id ||
			    '" SELECTED> ' || dm.node_name);

		    else

		      htp.p('<OPTION VALUE="' || dm.node_id ||
			   '"> ' || dm.node_name );

		     end if;

		  end loop;

		  htp.p('</SELECT>');
		  htp.p('</TD>');
	     htp.tableRowClose;

     */
        IF l_auth_mode <>'LDAP' THEN

	     htp.tableRowOpen;                                -- Old Password
		 htp.tableData(c_prompts(4),'RIGHT');
		 htp.tableData(htf.formPassword('i_4','30','50'));
	     htp.tableRowClose;
	     htp.tableRowOpen;                                -- Password
		 htp.tableData(c_prompts(5),'RIGHT');
		 htp.tableData(htf.formPassword('i_5','30','50'));
	     htp.tableRowClose;
	     htp.tableRowOpen;                                -- Repeat Password
		 htp.tableData(c_prompts(6),'RIGHT');
		 htp.tableData(htf.formPassword('i_6','30','50'));
	     htp.tableRowClose;
        ELSE
	     htp.formHidden('i_4','');-- Old Password
        htp.formHidden('i_5','');-- Password
        htp.formHidden('i_6','');-- Repeat Password
        END IF;
         htp.tableClose;
         htp.nl;

        htp.formClose;   --userpref


     l_actions(0).name := 'Cancel';
     l_actions(0).text := wf_core.translate('CANCEL');
     l_actions(0).actiontype := 'function';
     l_actions(0).action := 'top.main.cancelpref()';  -- put your own commands here
     l_actions(0).targetframe := 'main';
     l_actions(0).enabled := 'b_enabled';
     l_actions(0).gap := 'b_narrow_gap';

     l_actions(1).name := 'Apply';
     l_actions(1).text := wf_core.translate('APPLY');
     l_actions(1).actiontype := 'function';
     l_actions(1).action := 'top.main.savepref()';  -- put your own commands here
     l_actions(1).targetframe := 'main';
     l_actions(1).enabled := 'b_enabled';
     l_actions(1).gap := 'b_narrow_gap';

     if p_message_flag = 'N' then
        icx_cabo.buttons(p_actions => l_actions);

     elsif p_message_flag = 'Y' then
        fnd_message.set_name('ICX','ICX_SUCCESS_CONFIRM');
        l_actiontext := fnd_message.get;
        icx_cabo.buttons(p_actions    => l_actions,
                         p_actiontext => l_actiontext);
     else
        -- retrieve the password change/validation error returned by fnd_user_pvt
        l_actiontext := p_message_flag;
        icx_cabo.buttons(p_actions    => l_actions,
                         p_actiontext => l_actiontext);
     end if;

     htp.bodyClose;
     htp.htmlClose;

  end if;  --validatesession

exception
   when others then
      fnd_message.set_name('ICX','ICX_SESSION_FAILED');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
end;

--  ***********************************************
--     Procedure displayNewPassword
--  ***********************************************
procedure displayNewPassword(i_1         in VARCHAR2,
                             c_url       in VARCHAR2,
                             c_mode_code in VARCHAR2) is

c_language_code         varchar2(30);
c_title                 varchar2(240);
c_prompts               icx_util.g_prompts_table;
l_message               varchar2(2000);
l_pwlen                 number;
c_error_msg             varchar2(2000);
c_login_msg             varchar2(2000);
c_error_message         varchar2(240);

begin
        if (i_1 is null) or (i_1 = 'GUEST')
     then

fnd_message.set_name('IBE','IBE_PRMT_UNAUTHORIZED');
c_error_message := fnd_message.get;
htp.p(c_error_message);
else

        c_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
        htp.htmlOpen;
        htp.headOpen;
        --icx_util.copyright;
        htp.p('<SCRIPT LANGUAGE="JavaScript">');
        icx_admin_sig.help_win_script('/OA_DOC/'||c_language_code||'/aic/icxhlpmp.htm');
        htp.p('function update_user(){
        var l_alert = false;');

    l_pwlen := to_number(nvl(Fnd_Profile.Value('SIGNON_PASSWORD_LENGTH'), 5));
    fnd_message.set_name('FND','PASSWORD-LONGER');
    fnd_message.set_token('LENGTH',to_char(l_pwlen));
    l_message := icx_util.replace_quotes(fnd_message.get);
    htp.p('    var lpwd = document.newpass.i_3.value;
             if (lpwd.length <  '||to_char(l_pwlen)||' '||'&'||'&'||' document.newpass.i_2.value != "") {
                alert('''||l_message||''');
                document.newpass.i_3.focus();
                l_alert = true
                };');
--start bug 2214425
    fnd_message.set_name('FND', 'PASSWORD-INVALID-NO-REUSE');
    l_message := icx_util.replace_quotes(fnd_message.get);
    htp.p('    if ((document.newpass.i_2.value == document.newpass.i_3.value)||(document.newpass.i_2.value == "" '||'&'||'&'||' document.newpass.i_3.value !="")) {
            alert('''||l_message||''');
 document.newpass.i_3.focus();
        l_alert = true
         };');
----- end


    fnd_message.set_name('ICX','ICX_REQU_REPAS');
    l_message := icx_util.replace_quotes(fnd_message.get);
    htp.p('    if ((document.newpass.i_3.value != document.newpass.i_4.value)||(document.newpass.i_2.value == "" '||'&'||'&'||' document.newpass.i_3.value !="")) {
        alert('''||l_message||''');
        document.newpass.i_4.focus();
                l_alert = true
                };');

        htp.p('    if (l_alert==false) {
document.newpass.submit()
             };
        }');

        htp.p('</SCRIPT>');
        htp.headClose;

        icx_util.getPrompts(601,'ICX_NEW_PASSWORD',c_title,c_prompts);

        /* use Oracle logo */
        icx_admin_sig.toolbar(language_code => c_language_code,
			      DISP_MAINMENU => 'N',
			      DISP_HELP => 'N',
			      DISP_EXIT => 'N');

	fnd_message.set_name('FND','PASSWORD-EXPIRED');
	c_title := fnd_message.get;

        htp.title(c_title);
        htp.p('<H2>'||c_title||'</H2>');

        --switched the following statments so correct URL is created in stateful environment MPUTMAN
        --htp.formOpen(icx_plug_utilities.getPLSQLagent || 'OracleApps.UNP','POST','','','NAME="newpass"');
        htp.formOpen('OracleApps.UNP','POST','','','NAME="newpass"');

        htp.formHidden('i_1', i_1);
        htp.formHidden('c_url', c_url);
        htp.formHidden('c_mode_code', c_mode_code);

htp.tableOpen;
   htp.tableRowOpen;                                -- Old Password
        htp.tableData(c_prompts(2),'RIGHT');
        htp.tableData(htf.formPassword('i_2','30','50'));
   htp.tableRowClose;
   htp.tableRowOpen;                                -- Password
        htp.tableData(c_prompts(3),'RIGHT');
        htp.tableData(htf.formPassword('i_3','30','50'));
   htp.tableRowClose;
   htp.tableRowOpen;                                -- Repeat Password
        htp.tableData(c_prompts(4),'RIGHT');
        htp.tableData(htf.formPassword('i_4','30','50'));
   htp.tableRowClose;
htp.tableClose;
        htp.nl;

icx_util.DynamicButton(P_ButtonText => c_prompts(5),
                       P_ImageFileName => 'FNDBSBMT',
                       P_OnMouseOverText => c_prompts(5),
                       P_HyperTextCall => 'javascript:update_user()',
                       P_LanguageCode => c_language_code,
                       P_JavaScriptFlag => FALSE);
        htp.formClose;
        htp.bodyClose;
        htp.p('<SCRIPT>');  --2330653
        htp.p('document.newpass.i_2.focus();'); --2330653
        htp.p('</SCRIPT>'); --2330653
        htp.htmlClose;

end if;

exception
   when others then
      fnd_message.set_name('ICX','ICX_SESSION_FAILED');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
end;



--  ***********************************************
--     Procedure updateWebUser
--  ***********************************************
procedure updateWebUser(c_KNOWN_AS    in VARCHAR2,
                        c_LANGUAGE    in VARCHAR2,
		                  c_DATE_FORMAT in VARCHAR2,
                        c_PASSWORD1   in VARCHAR2,
                        c_PASSWORD2   in VARCHAR2,
                        c_PASSWORD3   in VARCHAR2,
                        c_MAILPREF    in VARCHAR2,
                        c_DMPREF      in VARCHAR2,
                        c_NUMERIC_CHARACTERS in VARCHAR2,
                        c_TERRITORY   in VARCHAR2,
                        c_TIMEZONE    IN VARCHAR2,
                        c_ENCODING    IN VARCHAR2) is

l_server_name           varchar2(80);
l_server_port           varchar2(80);
l_password_updated	boolean;
l_date_format		varchar2(100);
n_date_format		varchar2(100);
l_user_id		varchar2(15);
n_session_id		number;
l_session_mode          varchar2(30);
c_language_code		varchar2(30);
c_encrypted_psswd	varchar2(1000);
c_error_msg		varchar2(2000);
c_login_msg		varchar2(2000);
b_return		BOOLEAN;
l_return_status		varchar2(5);
l_msg_count		number;
username                varchar2(30);
l_msg_data		varchar2(2000);
l_message		varchar2(2000);
p_lang_change  VARCHAR2(2000); --added mputman bug 1405228
l_url          VARCHAR2(2000); --added mputman bug 1405228
l_agent        VARCHAR2(2000); --added mputman bug 1405228
l_return_stat  BOOLEAN := TRUE;
prof_date_lang VARCHAR2(80);
prof_sort      VARCHAR2(80);
p_db_nls_language varchar2(80);
p_db_nls_date_format varchar2(30);
p_db_nls_date_language varchar2(80);
p_db_nls_numeric_characters varchar2(5);
p_db_nls_sort varchar2(30);
p_db_nls_territory varchar2(80);
p_db_nls_charset varchar2(80);
z_date_lang VARCHAR2(80);
z_sort VARCHAR2(80);


begin

 if icx_sec.validateSession
 then

   l_date_format := c_DATE_FORMAT;
   l_user_id := icx_sec.g_user_id;
   n_session_id := icx_sec.g_session_id;
   l_password_updated := TRUE;

   --put timezone profile value

               l_return_stat := FND_PROFILE.SAVE(X_NAME =>'FND_NATIVE_CLIENT_ENCODING',
                                                 X_VALUE         => c_ENCODING,
                                                 X_LEVEL_NAME    =>'USER',
                                                 X_LEVEL_VALUE   => l_user_id);

               l_return_stat := FND_PROFILE.SAVE(X_NAME =>'CLIENT_TIMEZONE_ID',
                                                 X_VALUE         => c_TIMEZONE,
                                                 X_LEVEL_NAME    =>'USER',
                                                 X_LEVEL_VALUE   => l_user_id);
           if l_return_stat = FALSE then

              fnd_message.set_name('FND','SQL-NO INSERT');
              fnd_message.set_token('TABLE','FND_USER');
              fnd_msg_pub.Add;
           END IF;


   -- put the mail preference
   wfa_sec.GetSession(username);
   username := upper(username);
   fnd_preference.put (username, 'WF', 'MAILTYPE', c_mailpref);
   -- put the dm home node preference
   fnd_document_management.set_dm_home (username, c_dmpref);

   if c_PASSWORD1 is not null or c_PASSWORD2 is not null or c_PASSWORD3 is not null
   then

      if c_PASSWORD2 = c_PASSWORD3
      then

	l_server_name := owa_util.get_cgi_env('SERVER_NAME');
	l_server_port := owa_util.get_cgi_env('SERVER_PORT');

           FND_USER_PVT.Update_User(p_api_version_number => 1.0,
                                    p_init_msg_list => 'T',
                                    p_commit => 'T',
				    p_host_port => l_server_name||':'||l_server_port,
				    p_old_password => c_PASSWORD1,
				    p_new_password => c_PASSWORD2,
                                    p_last_updated_by => l_user_id,
                                    p_last_update_date => sysdate,
                                    p_user_id => l_user_id,
                                    p_return_status => l_return_status,
                                    p_msg_count => l_msg_count,
                                    p_msg_data => l_msg_data);
	 if l_return_status = FND_API.G_RET_STS_ERROR
	 then
	     l_password_updated := FALSE;
         end if; -- update password
      else
	  l_password_updated := FALSE;
      end if; -- c_PASSWORD2 = c_PASSWORD3

      if not l_password_updated
      then

      c_error_msg := fnd_message.get;  -- get the password update error placed on the stack by fnd_user_pvt
      displaywebuserlocal(p_message_flag => c_error_msg);
/*
         c_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
	 fnd_message.set_encoded(l_msg_data);
--         fnd_message.set_name('ICX','ICX_PWD_CHG_INVALID');
         c_error_msg := fnd_message.get;

         htp.htmlOpen;
         htp.headOpen;
	 icx_util.copyright;

         htp.p('<SCRIPT LANGUAGE="JavaScript">');
	 htp.p('<!-- Hide from old Browsers');
         icx_admin_sig.help_win_script('/OA_DOC/'||c_language_code||'/aic/icxhlpmp.htm');
	 htp.p('// -->');
         htp.p('</SCRIPT>');
         htp.headClose;
         icx_admin_sig.Openheader( NULL, NULL, c_language_code);
         icx_admin_sig.Closeheader( c_language_code);
            htp.p(c_error_msg);
         htp.htmlClose;
*/

      end if;  -- not l_password_updated
    end if;

        l_date_format := replace(upper(l_date_format), 'YYYY', 'RRRR');
        l_date_format := replace(l_date_format, 'YY', 'RRRR');
        if (instr(l_date_format, 'RR') > 0) then
            if (instr(l_date_format, 'RRRR')  = 0) then
                l_date_format := replace(l_date_format, 'RR', 'RRRR');
            end if;
        end if;

    begin
	n_date_format := to_char(sysdate, nvl(l_date_format,'XXX'));
    exception
	when others then
	    fnd_message.set_name('ICX','ICX_USE_DATE_FORMAT');
	    fnd_message.set_token('FORMAT_MASK_TOKEN','DD/MM/RRRR');
	    l_message := fnd_message.get;
            icx_util.add_error(l_message);
            icx_admin_sig.error_screen(l_message);
	    l_password_updated := FALSE;
    end;

    if l_password_updated
    then

           FND_USER_PVT.Update_User(p_api_version_number => 1.0,
                                    p_init_msg_list => 'T',
                                    p_commit => 'T',
				    p_language => c_LANGUAGE,
				    p_date_format_mask => l_date_format,
                                    p_territory => c_TERRITORY,
                                    p_numeric_characters => c_NUMERIC_CHARACTERS,
                                    p_known_as => c_KNOWN_AS,
                                    p_last_updated_by => l_user_id,
                                    p_last_update_date => sysdate,
                                    p_user_id => l_user_id,
                                    p_return_status => l_return_status,
                                    p_msg_count => l_msg_count,
                                    p_msg_data => l_msg_data);


           -- select added mputman bug 1405228
           select  nls_language
              into    p_lang_change
              from    fnd_languages
              where   language_code = (SELECT language_code
                                       FROM icx_sessions
                                       WHERE session_id = n_session_id);

      select  language_code
      into    c_language_code
      from    fnd_languages
      where   nls_language = c_LANGUAGE;
      -- bug 2656698
      -- get prof option vals for date_lang and sort.
      -- call fnd_global.set_nls to get return vals for date_lang and sort.
      -- when the prof vals are null, use the returns from fnd_global in the update to icx_sessions.

   fnd_profile.get(name    => 'ICX_NLS_SORT',
                   val     => prof_sort);
   fnd_profile.get(name    => 'ICX_DATE_LANGUAGE',
                   val     => prof_date_lang);

      fnd_global.set_nls(
              p_nls_language => c_LANGUAGE,
              p_nls_date_format => l_date_format,
              p_nls_date_language => NULL,
              p_nls_numeric_characters => c_NUMERIC_CHARACTERS,
              p_nls_sort => NULL,
              p_nls_territory => c_TERRITORY,
              p_db_nls_language => p_db_nls_language,
              p_db_nls_date_format => p_db_nls_date_format,
              p_db_nls_date_language => p_db_nls_date_language,
              p_db_nls_numeric_characters => p_db_nls_numeric_characters,
              p_db_nls_sort => p_db_nls_sort,
              p_db_nls_territory => p_db_nls_territory,
              p_db_nls_charset => p_db_nls_charset);

      IF (prof_sort IS NULL) THEN
        z_sort :=p_db_nls_sort;    --profile is not null.. use profile value
      ELSE
        z_sort :=prof_sort;        --profile is null.. use value returned from fnd_global
      END IF;

      IF (prof_date_lang IS NULL) THEN
         z_date_lang :=p_db_nls_date_language; --profile is not null.. use profile value
      ELSE
        z_date_lang :=prof_date_lang;         --profile is null.. use value returned from fnd_global
      END IF;
      --added date_lang and sort to the update for 2656698
      update  icx_sessions
      set     nls_language = c_LANGUAGE,
              language_code = c_language_code,
	           date_format_mask = l_date_format,
              nls_territory  = c_TERRITORY,
              nls_numeric_characters = c_NUMERIC_CHARACTERS,
              nls_date_language = z_date_lang,
              nls_sort = z_sort
      where   session_id = n_session_id;

      --if added mputman bug 1405228
      IF p_lang_change=c_language THEN
         displaywebuserlocal;
      ELSE
         IF (substr(icx_plug_utilities.getPLSQLagent, 1, 1) = '/') then
            l_agent := FND_WEB_CONFIG.WEB_SERVER||substr(icx_plug_utilities.getPLSQLagent,2);

         ELSE
            l_agent := FND_WEB_CONFIG.WEB_SERVER||icx_plug_utilities.getPLSQLagent;

         end if;

         l_url:=l_agent||'OracleApps.displaywebuser';
         l_url:='"'||l_url||'"';

         htp.p('


               <script language="JavaScript">
               function menuBypass(url){
               top.location=url;
               }
               </script>

               <frameset cols="100%,*" frameborder=no border=0>

               <frame
                src=javascript:parent.menuBypass('||l_url||')
                name=hiddenFrame1
                marginwidth=0
                marginheight=0
                scrolling=no>


               </frameset>

               ');



         END IF;-- p_lang_change=c_language
    end if;

 end if;
exception
   when others then
--htp.p(SQLERRM);
  htp.p(dbms_utility.format_error_stack);

/*
      fnd_message.set_name('ICX','ICX_SESSION_FAILED');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;
      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
*/
end;

--  ***********************************************
--     Procedure Update New Password
--  ***********************************************
procedure UNP(
                i_1         in      varchar2,
                i_2         in      varchar2,
                i_3         in      varchar2,
                i_4         in      varchar2,
                c_mode_code in      varchar2,
                c_url       in      VARCHAR2) is

c_error_message varchar2(2000);
err_mesg varchar2(240);
err_num number;

begin

  if c_url is null then
     updateNewPassword(i_1,i_2,i_3,i_4);
  else
     updateNewFndPassword(i_1,i_2,i_3,i_4,c_mode_code,c_url);
  end if;

end;

--  ***********************************************
--     Procedure updateNewFndPassword
--  ***********************************************
procedure updateNewFndPassword(c_USERNAME  in VARCHAR2,
                               c_PASSWORD1 in VARCHAR2,
                               c_PASSWORD2 in VARCHAR2,
                               c_PASSWORD3 in VARCHAR2,
                               p_mode_code in varchar2,
                               c_url       in varchar2) is

l_user_id		number;
l_server                varchar2(240);
l_host_instance		varchar2(240);
l_password_updated      boolean;
c_language_code         varchar2(30);
c_error_msg             varchar2(2000);
c_login_msg             varchar2(2000);
l_username		varchar2(100);
l_password		varchar2(240);
l_web_password          varchar2(240);
v_encrypted_psswd       varchar2(1000);
v_encrypted_upper_psswd varchar2(1000);
l_url                   varchar2(2000);
l_result                varchar2(30);
b_return                BOOLEAN;
l_return_status         varchar2(5);
l_msg_count             number;
l_msg_data              varchar2(2000);
l_message               varchar2(2000);
l_session_id            number;
return_to_url           varchar2(2000);
l_ret_msg               varchar(256);

begin

   l_password_updated := TRUE;

   if c_PASSWORD1 is not null or c_PASSWORD2 is not null or c_PASSWORD3 is not null
   then

      if c_PASSWORD2 = c_PASSWORD3
      then
	l_username := UPPER(c_username);

        l_result := fnd_web_sec.change_password(l_username, c_PASSWORD1,
                                                    c_PASSWORD2, c_PASSWORD3);
	if l_result = 'N'
	then
	   l_password_updated := FALSE;
           l_ret_msg := fnd_message.get;    --bug 2766487
	end if; -- result
      else
	    l_password_updated := FALSE;
            l_ret_msg := fnd_message.get;    --bug 2766487
      end if; -- c_PASSWORD2 = c_PASSWORD3

      if not l_password_updated
      then
	 c_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
         fnd_message.set_name('ICX','ICX_PWD_CHG_INVALID');
	 c_error_msg := fnd_message.get;

         htp.htmlOpen;
         htp.headOpen;
         icx_util.copyright;

         htp.p('<SCRIPT LANGUAGE="JavaScript">');
         htp.p('<!-- Hide from old Browsers');
         icx_admin_sig.help_win_script('/OA_DOC/'||c_language_code||'/aic/icxhlpmp.htm');
         htp.p('// -->');
         htp.p('</SCRIPT>');
         htp.headClose;
         icx_admin_sig.Openheader( NULL, NULL, c_language_code);
         icx_admin_sig.Closeheader( c_language_code);
            htp.p(c_error_msg);
            htp.nl;
            htp.p(l_ret_msg);   --bug 2766487
         htp.htmlClose;
      else

        --l_server := rtrim(FND_WEB_CONFIG.WEB_SERVER,'/'); -- mputman removed 1574527
        --return_to_url := l_server || c_url;               -- mputman removed 1574527
          return_to_url := c_url;
        --insert into mbuk_url values (return_to_url);
        -- c_url is the url where the user should be returned after the
        -- password has been successfully changed.

        l_message := icx_sec.validatePassword(c_user_name     => c_USERNAME,
                                              c_user_password => c_PASSWORD2,
		 	                      n_session_id    => l_session_id,
                                              c_mode_code     => p_mode_code);
        htp.htmlOpen;
        htp.bodyOpen(cattributes => 'onLoad="top.location.href='''||return_to_url||'''"'); htp.nl;
        htp.bodyClose;
        htp.htmlClose;

      end if;  -- not l_password_updated
    end if;
exception
   when others then
--htp.p(SQLERRM);
  htp.p(dbms_utility.format_error_stack);
end;

--  ***********************************************
--     Procedure updateNewPassword
--  ***********************************************
procedure updateNewPassword(c_USERNAME  in VARCHAR2,
                            c_PASSWORD1 in VARCHAR2,
                            c_PASSWORD2 in VARCHAR2,
                            c_PASSWORD3 in VARCHAR2) is

l_user_id		number;
l_server_name           varchar2(240);
l_server_port           varchar2(80);
l_server                varchar2(240);
l_host_instance		varchar2(240);
l_password_updated      boolean;
c_language_code         varchar2(30);
c_error_msg             varchar2(2000);
c_login_msg             varchar2(2000);
l_username		varchar2(100);
l_password		varchar2(240);
l_web_password          varchar2(240);
v_encrypted_psswd       varchar2(1000);
v_encrypted_upper_psswd varchar2(1000);
l_url                   varchar2(2000);
l_result                varchar2(30);
b_return                BOOLEAN;
l_return_status varchar2(5);
l_msg_count number;
l_msg_data varchar2(2000);
l_message varchar2(2000);

begin

   l_password_updated := TRUE;

   if c_PASSWORD1 is not null or c_PASSWORD2 is not null or c_PASSWORD3 is not null
   then

      if c_PASSWORD2 = c_PASSWORD3
      then

	l_username := UPPER(c_username);
        v_encrypted_upper_psswd := to_char(icx_call.crchash(l_username,UPPER(c_PASSWORD1)));

        v_encrypted_psswd := to_char(icx_call.crchash(l_username,c_PASSWORD1));

        select user_id,web_password
        into   l_user_id,l_web_password
        from   fnd_user
        where  user_name = l_username;

	if l_web_password = v_encrypted_upper_psswd
	then
	    v_encrypted_psswd := v_encrypted_upper_psswd;
        elsif l_web_password = v_encrypted_psswd
	then
            v_encrypted_psswd := v_encrypted_psswd;
	else
	    v_encrypted_psswd := 'XXXXXXXXXXXXXXX';
	end if;

        l_result := fnd_web_sec.upgrade_web_password(l_username, v_encrypted_psswd,
                                                                   c_PASSWORD2);
        if l_result = 'N'
	then
            l_password_updated := FALSE;
	end if; -- result
      else
          l_password_updated := FALSE;
      end if; -- c_PASSWORD2 = c_PASSWORD3

      if not l_password_updated
      then
	 c_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
         fnd_message.set_name('ICX','ICX_PWD_CHG_INVALID');
	 c_error_msg := fnd_message.get;

         htp.htmlOpen;
         htp.headOpen;
         icx_util.copyright;

         htp.p('<SCRIPT LANGUAGE="JavaScript">');
         htp.p('<!-- Hide from old Browsers');
         icx_admin_sig.help_win_script('/OA_DOC/'||c_language_code||'/aic/icxhlpmp.htm');
         htp.p('// -->');
         htp.p('</SCRIPT>');
         htp.headClose;
         icx_admin_sig.Openheader( NULL, NULL, c_language_code);
         icx_admin_sig.Closeheader( c_language_code);
            htp.p(c_error_msg);
         htp.htmlClose;
      else

        commit; -- 2752387
	oraclemypage.home(rmode => 2,
                          i_1 => c_USERNAME,
                          i_2 => c_PASSWORD2);

      end if;  -- not l_password_updated
    end if;
exception
   when others then
--htp.p(SQLERRM);
  htp.p(dbms_utility.format_error_stack);
end;

procedure icxLogin (rmode in number,
                    i_1   in varchar2,
                    i_2   in varchar2) is

l_message     varchar2(80);
l_session_id  pls_integer;
l_mode_code   varchar2(30);

begin

   if rmode = 1 then
      l_mode_code := '115J';
   elsif rmode = 2 then
      l_mode_code := '115P';
   end if;

  l_message := icx_sec.validatePassword(c_user_name     => i_1,
                                        c_user_password => i_2,
	  	 	                               n_session_id    => l_session_id,
                                        c_mode_code     => l_mode_code);

exception
   when others then
--     htp.p(SQLERRM);
       htp.p(dbms_utility.format_error_stack);
end;

procedure DF(i_direct  IN VARCHAR2,
             i_mode    IN NUMBER)
   IS

BEGIN

   IF icx_sec.validatesession(c_validate_only=>'Y') THEN
      htp.p('<SCRIPT>');
      htp.p('this.location="'||i_direct||'"');
      htp.p('</SCRIPT>');
   ELSE
      htp.p('<SCRIPT>');
      htp.p('this.location="OracleApps.displayLogin?i_direct='||i_direct||'&i_mode='||i_mode||'"');
      htp.p('</SCRIPT>');

   END IF;

END; -- end DF

/* Bug 1673370 - wrapper function for forms to call to get one time use ticket.
We need this wrapper to encrypt2() since no commit can be done in forms - also
we do not want commits in normal ICX code - so we add this server side call to
isolate the commit to just the ticket insert */

function FormsLF_prep(c_string     varchar2,
			             c_session_id NUMBER)
         return varchar2 is
PRAGMA AUTONOMOUS_TRANSACTION;

encrypted_ids      varchar2(512);

begin

	encrypted_ids := icx_call.encrypt2( c_string, c_session_id);
	commit;
	return encrypted_ids;

end; -- FormsLF_prep

PROCEDURE recreate_session (i_1 IN VARCHAR2,
                           i_2 IN VARCHAR2,
                           p_enc_session IN VARCHAR2,
                           p_mode IN VARCHAR2)
   IS
   l_validated VARCHAR2(10);
   l_server_name VARCHAR2(200); --MPUTMAN added for 2214199
   l_domain_count NUMBER;  --MPUTMAN added for 2214199
   l_browser VARCHAR2(400);  --MPUTMAN added for 2214199
   l_browser_is_IE BOOLEAN;  --MPUTMAN added for 2214199
BEGIN
   l_validated:=icx_sec.recreate_session(i_1,i_2,p_enc_session,p_mode);

   --/*  Fix not ready for release.  Will release in future patch.
   --begin fix for 2214199
   l_browser := owa_util.get_cgi_env('HTTP_USER_AGENT');
   IF (instrb(l_browser,'MSIE')>0) THEN
      l_browser_is_IE := TRUE;
   ELSE
      l_browser_is_IE := FALSE;
   END IF;
   IF l_browser_is_IE THEN
     l_server_name := owa_util.get_cgi_env('SERVER_NAME');
     l_domain_count := instr(l_server_name,'.',-1,2);
     if l_domain_count > 0
         then
         l_domain_count := instr(l_server_name,'.',1,1);
         l_server_name := substr(l_server_name,l_domain_count,length(l_server_name));
         l_domain_count := instr(l_server_name,'.',-1,3);
         IF  l_domain_count > 0 THEN
            l_server_name := substr(l_server_name,l_domain_count,length(l_server_name));
            END IF;--SECOND domain count
            end if;--FIRST domain count
                  IF ((instr(l_server_name,'.',1,1))=1) THEN
                    l_server_name:=substr(l_server_name,2);
                  END IF;

            --l_server_name now holds the domain value.
            htp.p('<script>
                   document.domain="'||l_server_name||'"
                   </script>');
            END IF;--l_browser_is_IE

            --end fix for 2214199
   --*/ -- mputman


   IF  l_validated ='1' THEN

      htp.p('<script>

            window.name="";
            if (opener){
                if (opener != null) {
                parent.opener.location.reload();
                }
            }
            window.close();');

      htp.p('</script>');

   ELSE
      htp.p('<script>

            window.name="";
            if (opener){
                if (opener != null) {
                parent.opener.location.reload();
                }
            }
            window.close();');

      htp.p('</script>');

   END IF;
END;

--  ***********************************************
--     Procedure connectLogin
--  ***********************************************
procedure connectLogin(c_message in VARCHAR2,
		                 c_display in VARCHAR2,
		                 c_logo    in VARCHAR2,
                       c_mode IN NUMBER,
                       c_lang IN VARCHAR2)
is
   c_session_id            number;
	c_language_code		varchar2(30);
   c_title		 	varchar2(80);
   c_prompts		icx_util.g_prompts_table;
   l_host_instance varchar2(80);
   l_agent  varchar2(80);
   l_text VARCHAR2(240);
   c_error_msg VARCHAR2(240);
   c_login_msg VARCHAR2(240);
   l_nls_lang VARCHAR2(30);
   c_nls_language VARCHAR2(40);
   c_upper_lang VARCHAR2(30);
   b_hosted BOOLEAN DEFAULT FALSE;
   l_hosted_profile VARCHAR2(50);
BEGIN

   if  c_lang is not null
   then
      c_upper_lang:=upper(c_lang);
      begin
         select  b.language_code, b.nls_language
            into    c_language_code, c_nls_language
            from    fnd_languages b
            where   b.language_code = c_upper_lang;


         exception
            when NO_DATA_FOUND then

               select        LANGUAGE_CODE, nls_language
                  into          c_language_code, c_nls_language
                  from          FND_LANGUAGES
                  where         INSTALLED_FLAG = 'B';
               end;
               FND_GLOBAL.set_nls_context(p_nls_language =>c_nls_language);
       --c_nls_language := ''''||c_nls_language||'''';
       --dbms_session.set_nls('NLS_LANGUAGE'   , c_nls_language);--removed in favor of above call to fnd_global -- mputman
       end if;
   fnd_profile.get(name    => 'ENABLE_SECURITY_GROUPS',
                   val     => l_hosted_profile);

   IF (upper(l_hosted_profile)='HOSTED') THEN
      b_hosted:=TRUE;
   END IF;
   icx_util.getPrompts(601,'ICX_LOGIN',c_title,c_prompts);
   icx_util.copyright;
   htp.p('<META Http-Equiv="Pragma" Content="no-cache">');
   htp.title(c_title);
   htp.p('<SCRIPT LANGUAGE="JavaScript">');
   htp.p('function logon_submit()
                     {
                     document.Logon0.i_1.value = document.Logon1.i_1.value;
                     document.Logon0.i_2.value = document.Logon2.i_2.value;');
   IF b_hosted THEN
              htp.p('document.Logon0.c_sec_grp_id.value = document.Logon3.site.value;');
   END IF;
              htp.p('document.Logon0.submit();
                     }');  --mputman hosted update
   htp.p('</SCRIPT>');
   htp.p('<SCRIPT LANGUAGE="JavaScript">');
   htp.p('<!-- Hide from old Browsers');
   icx_admin_sig.help_win_script('/OA_DOC/'||c_language_code||'/aic/icxhlpl.htm', c_language_code);
   htp.p('// -->');
   htp.p('</SCRIPT>');
   if c_display = 'IC' and c_logo = 'Y'
      then
      htp.img(curl => '/OA_MEDIA/FNDLOGOS.gif',
              cattributes => 'BORDER=0');
      htp.tableRowClose;
      htp.tableClose;
      htp.line;
      end if;
   htp.p(nvl(c_message,'<H2>'||c_title||'</H2>'));
   l_host_instance := FND_WEB_CONFIG.DATABASE_ID;
   l_agent := icx_plug_utilities.getPLSQLagent;
   htp.p('<FORM NAME=Logon0 ACTION="OracleMyPage.Home" METHOD="POST" TARGET="_top">');
   htp.formHidden('i_1','');
   htp.formHidden('i_2','');
   htp.formHidden('c_sec_grp_id','');             --mputman hosted update
   htp.formHidden('rmode','2');
   htp.formClose;
   htp.tableOpen;

   IF b_hosted THEN
   htp.tableRowOpen;                             -- SITE --mputman hosted update
   htp.tableData(c_prompts(5),'RIGHT');
   htp.p('<FORM NAME=Logon3 ACTION="javascript:document.Logon1.i_1.focus();" METHOD="POST">');
   htp.tableData(htf.formText('site',30));
   htp.formClose;
   htp.p('<td></td>');
   htp.tableRowClose;
   END IF;

   htp.tableRowOpen;                             -- Username
   htp.tableData(c_prompts(1),'RIGHT');
   htp.p('<FORM NAME=Logon1 ACTION="javascript:document.Logon2.i_2.focus();" METHOD="POST">');
   htp.tableData(htf.formText('i_1',30));
   htp.formClose;
   htp.p('<td></td>');
   htp.tableRowClose;
   htp.tableRowOpen;                             -- Password
   htp.tableData(c_prompts(2),'RIGHT');
   htp.p('<FORM NAME=Logon2 ACTION="javascript:logon_submit();" METHOD="POST">');
   htp.tableData(htf.formPassword('i_2',30));
   htp.formClose;
   htp.p('<td>');
   icx_plug_utilities.buttonBoth(c_prompts(3),'javascript:logon_submit()','FNDJLFOK.gif'); --  Connect
   htp.p('</td>');
   htp.tableRowClose;
   htp.tableClose;
   htp.formClose;
   htp.p('<SCRIPT LANGUAGE="JavaScript">');
   htp.p('<!-- Hide from old Browsers');
   htp.p('document.Logon1.i_1.focus();');
   htp.p('// -->');
   htp.p('</SCRIPT>');
exception
   when others then
--        htp.p(SQLERRM);
          htp.p(dbms_utility.format_error_stack);
end;

--  ***********************************************
--     Procedure convertSession
--  ***********************************************
procedure convertSession(c_token in VARCHAR2,
                      i_1 IN VARCHAR2,
                      i_2 IN VARCHAR2,
                      i_S IN VARCHAR2,
                      c_message in VARCHAR2)

is

PRAGMA AUTONOMOUS_TRANSACTION;

   c_session_id            number;
	c_language_code		varchar2(30);
   c_title		 	varchar2(80);
   c_prompts		icx_util.g_prompts_table;
   l_host_instance varchar2(80);
   l_agent  varchar2(80);
   --l_text VARCHAR2(240);
   c_error_msg VARCHAR2(240);
   c_login_msg VARCHAR2(240);
   l_nls_lang VARCHAR2(30);
   c_nls_language VARCHAR2(40);
   c_upper_lang VARCHAR2(30);
   b_hosted BOOLEAN DEFAULT FALSE;
   l_hosted_profile VARCHAR2(50);

l_text varchar2(2000);
l_parameters    icx_on_utilities.v2000_table;
l_resp_appl_id number;
l_responsibility_id number;
l_security_group_id number;
l_function_id number;
l_function_type varchar2(30);
l_menu_id number;
l_session_id number;
l_url VARCHAR2(800);
l_validated VARCHAR2(5);
l_message VARCHAR2(600);
l_user_id NUMBER;
l_enc_params VARCHAR2(2000);

 l_language     varchar2(80);
 l_language_code      varchar2(30);
 l_date_format     varchar2(150);
 l_date_language      varchar2(30);
 l_numeric_characters varchar2(30);
 l_nls_sort        varchar2(30);
 l_nls_territory         varchar2(30);
 l_limit_time      number;
 l_limit_connects  number;
 l_multi_org_flag        varchar2(1);
 l_org_id                varchar2(50);
   l_apps_sso VARCHAR2(20);
   l_portal        BOOLEAN DEFAULT FALSE;
   l_portal_sso    BOOLEAN DEFAULT FALSE;
   l_SSWA          BOOLEAN DEFAULT FALSE;
   l_SSWA_SSO      BOOLEAN DEFAULT FALSE;
   l_use_portal    BOOLEAN DEFAULT FALSE;
   e_portal_no_sso EXCEPTION;

 l_timeout               number;
 l_new_xsid       varchar2(32);

BEGIN
   --add redirect code to send to portal and sso if portal agent profile is not null
        fnd_profile.get(name    => 'APPS_SSO',
                        val     => l_apps_sso);
        IF l_apps_sso = 'PORTAL' THEN
            l_portal:=TRUE;
        ELSIF l_apps_sso = 'SSO_SDK' THEN
            l_portal_sso:=TRUE;
        ELSIF l_apps_sso = 'SSWA' THEN
            l_SSWA:=TRUE;
        ELSIF l_apps_sso = 'SSWA_SSO' THEN
            l_SSWA_SSO:=TRUE;
        ELSIF l_apps_sso IS NULL THEN
            l_SSWA:=TRUE;
        END IF;
        IF l_portal OR l_portal_sso THEN
            l_use_portal:=TRUE;
            ELSE
            l_use_portal:=FALSE;
        END IF;
--   htp.p('MPUTMAN - ConvertSession Begin');

   IF l_use_portal THEN -- just a double check

      IF l_portal_sso THEN

         OracleSSWA.convertSession;
      ELSIF l_portal THEN

         RAISE e_portal_no_sso;
      END IF;
   ELSE

   fnd_profile.get(name    => 'ENABLE_SECURITY_GROUPS',
                   val     => l_hosted_profile);

   IF (upper(l_hosted_profile)='HOSTED') THEN
      b_hosted:=TRUE;
   END IF;
    --this is not a portal instance, let ICX code do it's magic!
      l_text := icx_call.decrypt(c_token);

      icx_on_utilities.unpack_parameters(l_text,l_parameters);
      l_session_id := l_parameters(1);
      l_resp_appl_id := nvl(l_parameters(2),178);
      l_responsibility_id := l_parameters(3);
      l_security_group_id := l_parameters(4);
      l_function_id := l_parameters(5);
      l_enc_params := l_parameters(6);
      l_language_code := l_parameters(7);

      IF l_language_code IS NOT NULL THEN
        BEGIN
          select nls_language
            into l_language
            from fnd_languages_vl
            where LANGUAGE_CODE = l_language_code;
          FND_GLOBAL.set_nls_context(p_nls_language => l_language);

          EXCEPTION
           WHEN OTHERS THEN
           l_language_code :='';   -- bogus value, set to null
        END;
     END IF;
      --make sure session is valid too.
      IF (icx_sec.check_session(l_session_id) <> 'INVALID') THEN

        IF ((i_1 IS NOT NULL) AND (i_2 IS NOT NULL)) THEN

          IF ((b_hosted) AND (i_S IS NOT NULL)) THEN

            fnd_global.SET_SECURITY_GROUP_ID_CONTEXT(i_S);
            --fnd_global.apps_initialize(user_id => -1,
            --                           resp_id => -1,
            --                           resp_appl_id => -1,
            --                           security_group_id => i_S);--mputman hosted update
          END IF;
          --htp.p('MPUTMAN - pre validate pwd');htp.nl;
         l_validated := fnd_web_sec.validate_login(upper(i_1), i_2);
         IF l_validated ='N' THEN --login failed
         --htp.p('MPUTMAN - pwd NOT validated');htp.nl;
         fnd_message.set_name('ICX','ICX_SIGNIN_INVALID');
         l_message := fnd_message.get;
         fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
         l_message := l_message||' '||fnd_message.get;

         OracleApps.convertSession(c_token => c_token,
                                   c_message =>l_message);
         ELSE  --valid login
             --htp.p('MPUTMAN - PWD VALID');htp.nl;
            --update session for new user.
            BEGIN
               SELECT user_id
               INTO l_user_id
               FROM fnd_user
               WHERE user_name = upper(i_1);

               icx_sec.setUserNLS(l_user_id,
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

               -- Bug 13487530 - modified SELECT to capture XSID in case
               -- instance is pre-R12.1.  The hijacking feature is not
               -- available in pre-R12.1 envs.
               SELECT user_id, XSID INTO l_org_id, l_new_xsid
               FROM icx_sessions
               WHERE session_id=l_session_id;

               l_org_id:='';

               -- Bug 13487530 - if hijacking feature is supported (R12.1+)
               -- then use the NewXSID.
               if (fnd_session_management.is_hijack_session) then
                  -- Session Hijacking:
                  --    Re-set XSID whenever icx session is re-established.
                  l_new_xsid := fnd_session_management.NewXSID;
               end if;

               UPDATE icx_sessions
               SET user_id = l_user_id,
                   first_connect = SYSDATE,
                   last_connect = SYSDATE,
                   counter =1,
                   nls_language = l_language,
                   language_code = l_language_code,
		             date_format_mask = l_date_format,
                   nls_date_language = l_date_language,
		             nls_numeric_characters = l_numeric_characters,
		             nls_sort = l_nls_sort,
		             nls_territory = l_nls_territory,
             		 limit_time = l_limit_time,
		             limit_connects = l_limit_connects,
         RESPONSIBILITY_APPLICATION_ID = l_resp_appl_id,
         RESPONSIBILITY_ID = l_responsibility_id,
         SECURITY_GROUP_ID = l_security_group_id,
         FUNCTION_ID = l_function_id,
                   org_id = l_org_id,
                   xsid = l_new_xsid
               WHERE session_id = l_session_id;
               COMMIT;

               -- Bug 13487530 - if hijacking feature is supported (R12.1+)
               -- then use the NewXSID.
               if (fnd_session_management.is_hijack_session) then
                  -- Session Hijacking:
                  --   As XSID is modified, send the new XSID value
                  icx_sec.sendsessioncookie(l_session_id);
               end if;

               EXCEPTION
               WHEN OTHERS THEN
               NULL;
                  END;
            --htp.p('MPUTMAN - pre VSP');htp.nl;
            icx_sec.g_prog_appl_id := -999;--need to set back everywhere!!

            IF (icx_sec.VALIDATESessionPrivate(c_session_id => l_session_id,
                                               c_function_id => l_function_id,
                                               c_validate_only =>'Y')) THEN
            icx_sec.g_prog_appl_id := -1;
           --run it
           /*
           OracleApps.runfunction(p_resp_appl_id => l_resp_appl_id,
                                  p_responsibility_id => l_responsibility_id,
                                  p_security_group_id => nvl(l_security_group_id,'0'),
                                  p_function_type => f_type,
                                  c_function_id => l_function_id,
                                  n_session_id => icx_Sec.g_session_id,
                                  c_parameters => l_params);

           */
           IF l_enc_params IS NOT NULL THEN
            OracleApps.runFunction(p_resp_appl_id => l_resp_appl_id,
                                  p_responsibility_id => l_responsibility_id,
                                  p_security_group_id => nvl(l_security_group_id,'0'),
                                  c_function_id => l_function_id,
                                  n_session_id  => l_session_id,
                                  c_parameters => icx_call.decrypt(l_enc_params));

           ELSE
            OracleApps.runFunction(p_resp_appl_id => l_resp_appl_id,
                                  p_responsibility_id => l_responsibility_id,
                                  p_security_group_id => nvl(l_security_group_id,'0'),
                                  c_function_id => l_function_id,
                                  n_session_id  => l_session_id);
           END IF;
            -- htp.p('SUCCESS!!!!');
        ELSE
          icx_sec.g_prog_appl_id := -1;
          OracleApps.convertSession(c_token => c_token);
        END IF;
        icx_sec.g_prog_appl_id := -1;

         END IF;   --validate_login
      ELSE --i_1 || i_2 are null


 -------------
   icx_util.getPrompts(601,'ICX_LOGIN',c_title,c_prompts);
   icx_util.copyright;
   htp.p('<META Http-Equiv="Pragma" Content="no-cache">');
   htp.title(c_title);
   htp.p('<SCRIPT LANGUAGE="JavaScript">');
   htp.p('function logon_submit()
                     {
                     document.Logon0.i_1.value = document.Logon1.i_1.value;
                     document.Logon0.i_2.value = document.Logon2.i_2.value;');
   IF b_hosted THEN
              htp.p('document.Logon0.i_S.value = document.Logon3.site.value;');
   END IF;
              htp.p('document.Logon0.submit();
                     }');  --mputman hosted update
   htp.p('</SCRIPT>');
   htp.p('<SCRIPT LANGUAGE="JavaScript">');
   htp.p('<!-- Hide from old Browsers');
   icx_admin_sig.help_win_script('/OA_DOC/'||c_language_code||'/aic/icxhlpl.htm', c_language_code);
   htp.p('// -->');
   htp.p('</SCRIPT>');
--   if c_display = 'IC' and c_logo = 'Y'
--      then
      htp.img(curl => '/OA_MEDIA/FNDLOGOS.gif',
              cattributes => 'BORDER=0');
      htp.tableRowClose;
      htp.tableClose;
      htp.line;
--      end if;
   htp.p(nvl(c_message,'<H2>'||c_title||'</H2>'));
   l_host_instance := FND_WEB_CONFIG.DATABASE_ID;
   l_agent := icx_plug_utilities.getPLSQLagent;
   htp.p('<FORM NAME=Logon0 ACTION="OracleApps.convertSession" METHOD="POST" TARGET="_top">');
   --htp.formHidden('c_token',wfa_html.conv_special_url_chars(c_token));
   htp.formHidden('c_token',c_token);
   htp.formHidden('i_1','');
   htp.formHidden('i_2','');
   htp.formHidden('i_S','');
   htp.formClose;

   IF b_hosted THEN
   htp.tableRowOpen;                             -- SITE --mputman hosted update
   htp.tableData(c_prompts(5),'RIGHT');
   htp.p('<FORM NAME=Logon3 ACTION="javascript:document.Logon1.i_1.focus();" METHOD="POST">');
   htp.tableData(htf.formText('site',30));
   htp.formClose;
   htp.p('<td></td>');
   htp.tableRowClose;
   END IF;

   htp.tableOpen;
   htp.tableRowOpen;                             -- Username
   htp.tableData(c_prompts(1),'RIGHT');
   htp.p('<FORM NAME=Logon1 ACTION="javascript:document.Logon2.i_2.focus();" METHOD="POST">');
   htp.tableData(htf.formText('i_1',30));
   htp.formClose;
   htp.p('<td></td>');
   htp.tableRowClose;
   htp.tableRowOpen;                             -- Password
   htp.tableData(c_prompts(2),'RIGHT');
   htp.p('<FORM NAME=Logon2 ACTION="javascript:logon_submit();" METHOD="POST">');
   htp.tableData(htf.formPassword('i_2',30));
   htp.formClose;
   htp.p('<td>');
   icx_plug_utilities.buttonBoth(c_prompts(3),'javascript:logon_submit()','FNDJLFOK.gif'); --  Connect
   htp.p('</td>');
   htp.tableRowClose;
   htp.tableClose;
   htp.formClose;
   htp.p('<SCRIPT LANGUAGE="JavaScript">');
   htp.p('<!-- Hide from old Browsers');
   htp.p('document.Logon1.i_1.focus();');
   htp.p('// -->');
   htp.p('</SCRIPT>');
   END IF;  --i_1 and i_2 null check
      ELSE --check_session failed
        OracleApps.displayLogin;
   END IF; -- check_session
 END IF; --portal
 COMMIT;
exception
   WHEN e_portal_no_sso THEN

      OracleApps.displayLogin;

   when others then
   rollback;
   icx_sec.g_prog_appl_id := -1;
--        htp.p(SQLERRM);
          htp.p(dbms_utility.format_error_stack);
end;


end OracleApps;

/
