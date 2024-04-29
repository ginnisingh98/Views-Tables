--------------------------------------------------------
--  DDL for Package Body FND_RUN_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_RUN_FUNCTION" as
/* $Header: AFRFB.pls 120.4 2006/09/16 00:10:01 rou ship $ */

--
-- Helper function to escape quotes
-- Copied from an ICX_UTIL routine
--
function replace_onMouseOver_quotes(p_string in varchar2) return varchar2 is
 temp_string varchar2(32000);
begin
  -- replace single quotes
 temp_string := replace(p_string,'''','\''');
 temp_string := replace(temp_string,'"','`&quot;');
 -- check for double escapes
 temp_string := replace(temp_string,'\\','\');
 return temp_string;
end replace_onMouseOver_quotes;


--
-- Helper function, given the names of the function, responsibility,
-- and security group, it returns the corresponding ID's.
--
function lookup_context ( p_function_name in varchar2,
                          p_resp_appl in varchar2,
                          p_resp_key in varchar2,
                          p_security_group_key in varchar2,
                          p_function_id out nocopy number,
                          p_resp_appl_id out nocopy number,
                          p_resp_id out nocopy number,
                          p_security_group_id out nocopy number )
return boolean is
 cursor c_func is select function_id from fnd_form_functions
                  where function_name = p_function_name;
 cursor c_app is select application_id from fnd_application
                 where application_short_name = p_resp_appl;
 cursor c_resp is select responsibility_id from fnd_responsibility
                  where responsibility_key = p_resp_key;
 cursor c_sec is select security_group_id from fnd_security_groups
                 where security_group_key = p_security_group_key;
begin
 open c_func;
 fetch c_func into p_function_id;
 if ( c_func%notfound ) then
   close c_func;
   return false;
 end if;
 close c_func;

 --
 -- if null is passed in for the responsibility, use -1 for the ID's.
 --
 if ( p_resp_appl is null and p_resp_key is null ) then
   p_resp_appl_id := -1;
   p_resp_id := -1;
 else
   open c_app;
   fetch c_app into p_resp_appl_id;
   if ( c_app%notfound ) then
     close c_app;
     return false;
   end if;
   close c_app;

   open c_resp;
   fetch c_resp into p_resp_id;
   if ( c_resp%notfound ) then
     close c_resp;
     return false;
   end if;
   close c_resp;
 end if;

 --
 -- if null is passed in for the security group, use 0.
 --
 if ( p_security_group_key is null ) then
   p_security_group_id := 0;
 else
   open c_sec;
   fetch c_sec into p_security_group_id;
   if ( c_sec%notfound ) then
     close c_sec;
     return false;
   end if;
   close c_sec;
 end if;

 return true;
end;


--
-- copied from fnd_web_config, but this version uses a call to
-- fnd_profile.value_specific when getting the APPS_SERVLET_AGENT
--
function GET_JSP_AGENT ( p_resp_id number,
                         p_resp_appl_id number,
                         p_security_group_id number )
return VARCHAR2 is
  agent_url varchar2(2000) := NULL;
  index1 number;
  index2 number;
begin
   agent_url := fnd_profile.value_specific('APPS_SERVLET_AGENT',
                                           null,
                                           p_resp_id,
                                           p_resp_appl_id,
                                           p_security_group_id);
   if (agent_url is null) then
       FND_MESSAGE.SET_NAME('FND', 'PROFILES-CANNOT READ');
       FND_MESSAGE.SET_TOKEN('OPTION','APPS_SERVLET_AGENT');
       return NULL;
   end if;

   agent_url := FND_WEB_CONFIG.TRAIL_SLASH(agent_url);

   index1 := INSTRB(agent_url, '//', 1) + 2;	  /* skip 'http://' */

   index2 := INSTRB(agent_url, '/', index1);  /* get to 'http://serv:port/' */

   if(index1 <> index2) AND (index1 <> 2) AND (index2 > 2)
	 AND (index1 is not NULL) AND (index2 is not NULL) then
       return FND_WEB_CONFIG.TRAIL_SLASH(SUBSTRB(agent_url, 1, index2-1)) ||
	 'OA_HTML/';
   else
       /* Incorrect format; give an error message */
       FND_MESSAGE.SET_NAME('FND', 'AF_WCFG_BAD_AGENT_URL_FORMAT');
       FND_MESSAGE.SET_TOKEN('URL', agent_url);
       FND_MESSAGE.SET_TOKEN('PROFILE', 'APPS_SERVLET_AGENT');
       FND_MESSAGE.SET_TOKEN('FORMAT', 'http://server[:port]/');
       return NULL;
   end if;

end GET_JSP_AGENT;


--
-- Returns iframe and JavaScript initialization code needed by the
-- Forms Launcher.
--
function get_forms_launcher_setup return varchar2 is
begin
  return
    '<iframe name=formsLauncher src="/OA_HTML/blank.html" title=""
	height=5px width=5px scrolling=no frameborder=no></iframe>
     <script>
       function launchForm (url)
       {
         if ( navigator.appName == "Netscape" )
         {
           open(url, "formsWindow");
         }
         else
         {
           formsLauncher.location.replace(url + "&formsLink=yes");
         }
       }
     </script>';
end;


--
-- Returns the URL to run the specified function in the given responsibility.
-- If null is passed in for the responsibility default to -1. The security
-- group should be passed in, but if not default to 0 for backwards
-- compatibility (see bug 3353820).
--
-- Unlike its java counterpart, for WWK functions this does not
-- return a javascript call - the existing ICX code which currently
-- calls these api's already adds the javascript portion on itself.
-- The get_run_function_link api's do add the javascript as well.
--
function get_run_function_url ( p_function_id in number,
                                p_resp_appl_id in number,
                                p_resp_id in number,
                                p_security_group_id in number,
                                p_parameters in varchar2 default null,
                                p_override_agent in varchar2 default null,
                                p_org_id in number default null,
                                p_lang_code in varchar2 default null,
                                p_encryptParameters in boolean default true )
return varchar2 is
 l_db_id  varchar2(255);
 l_jsp_agent  varchar2(2000);
 l_url  varchar2(2000);
 l_mac_enabled  varchar2(255);
 l_mac_lite_enabled  varchar2(255);
 l_mac_data varchar2(2000);
 l_mac_code varchar2(2000);
 l_session_id number := -1;
 l_lang_code varchar2(62);

 cursor lc is select userenv('LANG') from dual;
begin

 if ( p_function_id is null ) then
   return null;
 end if;

 --
 -- This mirrors what the equivalent java (see RunFunction.java) code
 -- does (see bug 2942720), primarily for backwards compatibility.
 --
 l_db_id := fnd_profile.value_specific('APPS_DATABASE_ID', null, p_resp_id,
                                       p_resp_appl_id, p_security_group_id);
 if ( l_db_id is null ) then
   l_db_id := fnd_web_config.database_id;
 end if;

 if ( p_override_agent is not null ) then
   l_jsp_agent := fnd_web_config.trail_slash(p_override_agent);
 else
   l_jsp_agent := get_jsp_agent(p_resp_id, p_resp_appl_id,
                                p_security_group_id);
 end if;


 l_mac_data :=  'RF.jsp?function_id=' || p_function_id ||
                '&resp_id=' || NVL(p_resp_id, -1) ||
                '&resp_appl_id=' || NVL(p_resp_appl_id, -1) ||
                '&security_group_id=' || NVL(p_security_group_id, 0);
 if ( p_org_id is not null ) then
   l_mac_data := l_mac_data || '&org_id=' || p_org_id;
 end if;

 if ( p_lang_code is null ) then
   open lc;
   fetch lc into l_lang_code;
   if ( lc%found ) then
     l_mac_data := l_mac_data || '&lang_code=' || l_lang_code;
   end if;
 else
     l_mac_data := l_mac_data || '&lang_code=' || p_lang_code;
 end if;

 if ( p_parameters is not null ) then
   if ( p_encryptParameters ) then
     l_mac_data := l_mac_data || '&params=' ||
	           fnd_web_sec.URLEncrypt(l_db_id,p_parameters);
   else
     l_mac_data := l_mac_data || '&params2=' ||
                   wfa_html.conv_special_url_chars(p_parameters);
   end if;
 end if;

 l_url := l_jsp_agent || l_mac_data;

 if ( fnd_session_management.g_session_id <> -1 ) then
   l_session_id := fnd_session_management.g_session_id;
 elsif ( icx_sec.g_session_id <> -1 ) then
   l_session_id := icx_sec.g_session_id;
 end if;

 if ( l_session_id <> -1 ) then
   l_mac_enabled := fnd_profile.value('FND_VALIDATION_LEVEL');
	 l_mac_lite_enabled := fnd_profile.value('FND_FUNCTION_VALIDATION_LEVEL');
   if ( l_mac_enabled <> 'NONE' or l_mac_lite_enabled <> 'NONE' ) then
     l_mac_code := fnd_session_utilities.mac(l_mac_data, l_session_id);
     return l_url || '&oas=' || l_mac_code;
   end if;
 end if;

 --
 -- if the session ID is not set or mac'ing is not enabled, just return the
 -- url without the mac code.
 --
 return l_url;
end;


--
-- Version of get_run_function_url that takes names instead of ID's.
--
function get_run_function_url ( p_function_name in varchar2,
                                p_resp_appl in varchar2,
                                p_resp_key in varchar2,
                                p_security_group_key in varchar2,
                                p_parameters in varchar2 default null,
                                p_override_agent in varchar2 default null,
                                p_org_id in number default null,
                                p_lang_code in varchar2 default null,
                                p_encryptParameters in boolean default true )
return varchar2 is
 l_function_id number;
 l_resp_appl_id number;
 l_resp_id number;
 l_secgrp_id number;
 l_status boolean;
begin
 l_status := lookup_context(p_function_name,
                            p_resp_appl, p_resp_key,
                            p_security_group_key,
                            l_function_id,
                            l_resp_appl_id, l_resp_id,
                            l_secgrp_id);
 if ( not l_status ) then
   return null;
 else
   return get_run_function_url(l_function_id, l_resp_appl_id, l_resp_id,
                               l_secgrp_id, p_parameters, p_override_agent,
                               p_org_id, p_lang_code, p_encryptParameters);
 end if;
end;


--
-- Generates a link automatically - returns HTML of the form
--  <a href=...> .. </a>
-- which will run the specified function in the given responsibility.
--
-- If called on a function of type 'FORM', make sure the output from
-- 'get_forms_launcher_setup' is printed out first.
--
function get_run_function_link ( p_text  in varchar2,
                                 p_target in varchar2,
                                 p_function_id in number,
                                 p_resp_appl_id in number,
                                 p_resp_id in number,
                                 p_security_group_id in number,
                                 p_parameters in varchar2 default null,
                                 p_override_agent in varchar2 default null,
                                 p_org_id in number default null,
                                 p_lang_code in varchar2 default null,
                                 p_encryptParameters in boolean default true )
return varchar2 is
 l_url  varchar2(2000);
 l_mouse_over_text varchar2(2000);
 l_function_type varchar2(30);
 l_user_function_name varchar2(80);
 l_form_id number;

 cursor c1 is select type, user_function_name, form_id
              from fnd_form_functions_vl
              where function_id = p_function_id;
begin
 if ( p_function_id is null ) then
   return null;
 end if;

 open c1;
 fetch c1 into l_function_type, l_user_function_name, l_form_id;
 if ( c1%notfound ) then
   return null;
 end if;

 l_url := get_run_function_url(p_function_id, p_resp_appl_id, p_resp_id,
                               p_security_group_id, p_parameters,
                               p_override_agent, p_org_id, p_lang_code,
                               p_encryptParameters);

 --
 -- Display the user function name when mousing over the generated link.
 --
 l_mouse_over_text := 'onMouseOver="window.status=''' ||
                   replace_onMouseOver_quotes(l_user_function_name) ||
                   '''; return true"';

 --
 -- See bug 2767549 - the function type column for compatibility reasons
 -- has not been validated, so the values may not be correct.  We can't
 -- handle every possible invalid combination, but try to at least
 -- be robust about handling FORM functions, since the old Forms
 -- navigator didn't check for function type either, it just checked
 -- the form_id.
 --
 if ( l_function_type is null and l_form_id is not null ) then
   l_function_type := 'FORM';
 end if;

 --
 -- FORM functions need to call the javascript that is generated
 -- by the 'get_forms_launcher_setup' function above.
 --
 if ( l_function_type = 'FORM' ) then
   l_url := l_url || '&prompt=yes';
   return '<a href="javascript:launchForm(''' || l_url || ''')" ' ||
            l_mouse_over_text || '>' || p_text || '</a>';

 --
 -- Functions of type WWK need to be opened in a separate window.
 --
 elsif ( l_function_type = 'WWK') then
   return '<a href="javascript:void window.open(''' || l_url ||
          ''',''function_window'',''status=yes,resizable=yes,' ||
          'scrollbars=yes,menubar=no,toolbar=no'')" TARGET=''' ||
           p_target || ''' ' || l_mouse_over_text || '>' || p_text || '</a>';

 --
 -- All other types generate a simple link.  Note that this includes
 -- invalid function types, the link will get generated and we'll
 -- just let it pass on through to the eventual RF.jsp call.
 --
 else
   return '<a href="' || l_url || '" target=' || p_target || ' ' ||
           l_mouse_over_text || '>' || p_text || '</a>';
 end if;
end;


--
-- Version of get_run_function_link that takes names instead of ID's.
--
function get_run_function_link ( p_text  in varchar2,
                                 p_target in varchar2,
                                 p_function_name in varchar2,
                                 p_resp_appl in varchar2,
                                 p_resp_key in varchar2,
                                 p_security_group_key in varchar2,
                                 p_parameters in varchar2 default null,
                                 p_override_agent in varchar2 default null,
                                 p_org_id in number default null,
                                 p_lang_code in varchar2 default null,
                                 p_encryptParameters in boolean default true )
return varchar2 is
 l_function_id number;
 l_resp_appl_id number;
 l_resp_id number;
 l_secgrp_id number;
 l_status boolean;
begin
 l_status := lookup_context(p_function_name,
                            p_resp_appl, p_resp_key,
                            p_security_group_key,
                            l_function_id,
                            l_resp_appl_id, l_resp_id,
                            l_secgrp_id);

 if ( not l_status ) then
   return null;
 else
   return get_run_function_link(p_text, p_target, l_function_id,
                                l_resp_appl_id, l_resp_id,
                                l_secgrp_id, p_parameters,
                                p_override_agent, p_org_id, p_lang_code,
                                p_encryptParameters);
 end if;
end;

end FND_RUN_FUNCTION;

/
