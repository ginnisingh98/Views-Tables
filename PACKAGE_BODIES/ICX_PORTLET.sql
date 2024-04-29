--------------------------------------------------------
--  DDL for Package Body ICX_PORTLET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_PORTLET" as
/* $Header: ICXPUTIB.pls 120.0 2005/10/07 12:17:48 gjimenez noship $ */

procedure responsibilities(p_portlet_id       in number,
                           p_responsibilities out NOCOPY icx_portlet.responsibilityTable) is

l_counter             pls_integer;
l_security_group_name varchar2(80);

cursor functions is
      select  fr.RESPONSIBILITY_NAME,
              fr.APPLICATION_ID,
              fr.RESPONSIBILITY_ID,
              furg.SECURITY_GROUP_ID
      from    FND_MENU_ENTRIES fme,
              FND_RESPONSIBILITY_VL fr,
              FND_USER_RESP_GROUPS furg
      where   furg.USER_ID = icx_sec.g_user_id
      and     furg.RESPONSIBILITY_APPLICATION_ID = fr.APPLICATION_ID
      and     furg.RESPONSIBILITY_ID = fr.RESPONSIBILITY_ID
      and     fr.MENU_ID = fme.MENU_ID
      and     fme.FUNCTION_ID = p_portlet_id;

begin

  p_responsibilities(0).ids  := '0*0*0**]';
  p_responsibilities(0).name := '';

  l_counter := 0;
  for f in functions loop
    p_responsibilities(l_counter).ids  := f.application_id||'*'||
                                          f.responsibility_id||'*'||
                                          f.security_group_id||'**]';
    p_responsibilities(l_counter).name := f.responsibility_name;

    if OracleNavigate.security_group(f.responsibility_id,f.application_id)
    then
      select security_group_name
      into l_security_group_name
      from fnd_security_groups_vl
      where security_group_id = f.security_group_id;

      p_responsibilities(l_counter).name := p_responsibilities(l_counter).name||', '||l_security_group_name;
    end if;
    l_counter := l_counter + 1;
  end loop;

end;


function validateSessionPart1
  return number is

  l_session_id            number;
  l_gen_redirect_url      varchar2(2024);
  l_urlrequested          varchar2(2024);
  l_urlcancel             varchar2(2024);
  l_listener_token        varchar2(240);
  l_procedure_call        varchar2(32000);
  l_call                  integer;
  l_dummy                 integer;
  l_defined               boolean;

begin

  l_session_id := icx_sec.getsessioncookie;

  if l_session_id = -1
  then

    l_urlrequested :=
      lower(owa_util.get_cgi_env('REQUEST_PROTOCOL'))||'://'||
      owa_util.get_cgi_env('SERVER_NAME')||':'||
      owa_util.get_cgi_env('SERVER_PORT')||
      owa_util.get_cgi_env('SCRIPT_NAME')||
      owa_util.get_cgi_env('PATH_INFO')||'?'||
      owa_util.get_cgi_env('QUERY_STRING');

    fnd_profile.get_specific(name_z    => 'APPS_PORTAL',
                             val_z     => l_urlcancel,
                             defined_z => l_defined );

    l_gen_redirect_url := ICX_PORTLET.SSORedirect(l_urlrequested,l_urlcancel);
    owa_util.redirect_url(l_gen_redirect_url);
  end if;

  return l_session_id;

exception
  when others then
    htp.p(SQLERRM);

end;

function validateSessionpart2(p_session_id        in NUMBER,
                              p_application_id    in NUMBER,
                              p_responsibility_id in NUMBER,
                              p_security_group_id in NUMBER,
                              p_function_id       in NUMBER)
  return boolean is

  l_valid boolean;

begin

  l_valid := icx_sec.validateSessionPrivate(c_session_id => p_session_id,
                                            c_resp_appl_id => p_application_id,
                                            c_responsibility_id => p_responsibility_id,
                                            c_security_group_id => p_security_group_id,
                                            c_function_id => p_function_id);

  return l_valid;

exception
  when others then
    htp.p(SQLERRM);

end;

function validateSession(p_application_id    in NUMBER,
                         p_responsibility_id in NUMBER,
                         p_security_group_id in NUMBER,
                         p_function_id       in NUMBER)
  return boolean is

  l_session_id number;
  l_valid      boolean;

begin

  l_session_id := validateSessionPart1;

  l_valid := icx_sec.validateSessionPrivate(c_session_id => l_session_id,
                                            c_resp_appl_id => p_application_id,
                                            c_responsibility_id => p_responsibility_id,
                                            c_security_group_id => p_security_group_id,
                                            c_function_id => p_function_id);

  return l_valid;

exception
  when others then
    htp.p(SQLERRM);

end;

function createBookmarkLink( p_text             VARCHAR2,
                       p_application_id         NUMBER,
                       p_responsibility_id      NUMBER,
                       p_security_group_id      NUMBER,
                       p_function_id            NUMBER,
                       p_function_type          VARCHAR2,
                       p_web_html_call          VARCHAR2,
                       p_target                 VARCHAR2,
                       p_session_id             NUMBER,
                       p_agent                  VARCHAR2,
                       p_parameters             VARCHAR2)
         return varchar2 is

l_url        varchar2(4000) := null;
/*
l_link       varchar2(4000) := null;
l_session_id number;
l_agent      varchar2(240);
*/

begin

  -- 2758891 nlbarlow
  l_url := icx_portlet.createExecLink(p_application_id => p_application_id,
                       p_responsibility_id => p_responsibility_id,
                       p_security_group_id => p_security_group_id,
                       p_function_id => p_function_id,
                       p_parameters => p_parameters,
                       p_target => p_target,
                       p_link_name => p_text,
                       p_url_only => 'N');

  return l_url;

/*
  if p_session_id is null
  then
    l_session_id := nvl(icx_sec.getsessioncookie,-999);
  else
    l_session_id := p_session_id;
  end if;

  if p_agent is null
  then
    l_agent := FND_WEB_CONFIG.PLSQL_AGENT;
  else
    l_agent := p_agent;
  end if;

  if substr(p_web_html_call,1,10) = 'javascript'
  then
    l_link := replace(p_web_html_call,'"','''');
    l_link := replace(l_link,'[RESPONSIBILITY_ID]',p_responsibility_id);
    l_link := replace(l_link,'[PLSQL_AGENT]',icx_plug_utilities.getPLSQLagent);
    l_link := '<A HREF="'||l_link||'">'||p_text||'</A>';
  else
    l_url := l_agent||'OracleSSWA.BookmarkThis?icxtoken='
                        ||icx_call.encrypt4(p_application_id
                        ||'*'||p_responsibility_id
                        ||'*'||p_security_group_id
                        ||'*'||p_function_id||'**]'
                        ,l_session_id);
    if p_parameters is not null
    then
      l_url := l_url||'&'||'p='||icx_call.encrypt4(p_parameters,l_session_id);
    end if;

    if p_function_type = 'WWK'
    then
      l_link := '<A HREF="javascript:void window.open ('''
                        ||l_url
                        ||''',''function_window'',''status=yes,resizable=yes,scrollbars=yes,menubar=no,toolbar=no'')" TARGET='''||p_target||'''>'
                        ||p_text||'</A>';
    else
      l_link := '<A HREF="'||l_url
                        ||'" TARGET='''||p_target||'''>'
                        ||p_text||'</A>';
    end if;
  end if;

  return l_link;
*/

end createBookmarkLink;


function createFwkBookmarkLink(p_text          varchar2,
                       p_application_id         number,
                       p_responsibility_id      number,
                       p_security_group_id      number,
                       p_function_id            number,
                       p_function_type          varchar2,
                       p_web_html_call          varchar2,
                       p_target                 varchar2,
                       p_session_id             number,
                       p_agent                  varchar2,
                       p_parameters             varchar2)
         return varchar2 is
l_link       varchar2(4000) := null;
begin

    -- Get the normal bookmark link
    l_link := ICX_PORTLET.createBookmarkLink(p_text,
                                             p_application_id,
                                             p_responsibility_id,
                                             p_security_group_id,
                                             p_function_id,
                                             p_function_type,
                                             p_web_html_call,
                                             p_target,
                                             p_session_id,
                                             p_agent,
                                             p_parameters);

    -- If it has a call to BookmarkThis, replace it with FwkBookmarkThis
    l_link := replace(l_link,
                      'OracleSSWA.BookmarkThis',
                      'OracleSSWA.FwkBookmarkThis');

    return l_link;

end createFwkBookmarkLink;

procedure updCacheByUser(p_user_name varchar2)
is

l_user_id number;

begin

select user_id
into l_user_id
from fnd_user
where user_name = p_user_name;

update icx_portlet_customizations
set caching_key = TO_CHAR(TO_NUMBER(NVL(caching_key, '0')) + 1)
where  user_id = l_user_id;

end;

procedure updCacheByFuncName(p_function_name varchar2)
is

l_function_id number;

begin

select function_id
into l_function_id
from fnd_form_functions
where function_name = p_function_name;

update icx_portlet_customizations
set caching_key = TO_CHAR(TO_NUMBER(NVL(caching_key, '0')) + 1)
where  function_id = l_function_id;

end;

procedure updateCacheByUserFunc(p_user_name varchar2, p_function_name varchar2)
is

l_function_id number;
l_user_id number;

begin

select user_id
into l_user_id
from fnd_user
where user_name = p_user_name;

select function_id
into l_function_id
from fnd_form_functions
where function_name = p_function_name;

update icx_portlet_customizations
set caching_key = TO_CHAR(TO_NUMBER(NVL(caching_key, '0')) + 1)
where  function_id = l_function_id
and    user_id = l_user_id;

end;

procedure updCacheKeyValueByUser(p_user_name varchar2, p_caching_key_value varchar2) is
  l_user_id number;
  l_caching_key_value varchar2(55);
begin
select user_id
into l_user_id
from fnd_user
where user_name = p_user_name;

l_caching_key_value := p_caching_key_value;

update icx_portlet_customizations
set caching_key = l_caching_key_value
where  user_id = l_user_id;

end;

procedure updCacheKeyValueByFuncName(p_function_name varchar2, p_caching_key_value varchar2) is

l_function_id number;
l_caching_key_value varchar2(55);

begin

select function_id
into l_function_id
from fnd_form_functions
where function_name = p_function_name;

l_caching_key_value := p_caching_key_value;

update icx_portlet_customizations
set caching_key = l_caching_key_value
where  function_id = l_function_id;

end;


procedure updateCacheKeyValueByUserFunc(p_user_name varchar2, p_function_name varchar2, p_caching_key_value varchar2) is

l_function_id number;
l_user_id number;
l_caching_key_value varchar2(55);

begin

select user_id
into l_user_id
from fnd_user
where user_name = p_user_name;

select function_id
into l_function_id
from fnd_form_functions
where function_name = p_function_name;

l_caching_key_value := p_caching_key_value;

update icx_portlet_customizations
set caching_key = l_caching_key_value
where  function_id = l_function_id
and    user_id = l_user_id;

end;

procedure updCacheKeyValueByPortletRef(p_reference_path varchar2, p_caching_key_value varchar2) is

l_reference_path varchar2(100);
l_caching_key_value varchar2(55);

begin

l_caching_key_value := p_caching_key_value;

update icx_portlet_customizations
set caching_key = l_caching_key_value
where reference_path = l_reference_path;

end;


  function createExecLink2(p_application_short_name         VARCHAR2,
                           p_responsibility_key      VARCHAR2,
                           p_security_group_key      VARCHAR2,
                           p_function_name            VARCHAR2,
                           p_parameters             VARCHAR2,
                           p_target                 VARCHAR2,
                           p_link_name              VARCHAR2,
                           p_url_only               VARCHAR2)

         return varchar2 is
l_application_id         NUMBER;
l_responsibility_id      number;
l_security_group_id      number;
l_function_id            number;
l_RFLink       varchar2(2000) := null;
l_session_id   number;
l_hosted_profile VARCHAR2(50);
b_hosted BOOLEAN :=FALSE;
e_bad_parameters       exception;


begin

   fnd_profile.get(name    => 'ENABLE_SECURITY_GROUPS',
                   val     => l_hosted_profile);
   IF (upper(l_hosted_profile)='HOSTED') THEN
      b_hosted:=TRUE;
   END IF;

      IF b_hosted THEN

      BEGIN
      SELECT SECURITY_GROUP_ID
      INTO l_security_group_id
      FROM fnd_security_groups
      WHERE security_group_key = p_security_group_key;
      EXCEPTION
         WHEN no_data_found THEN
         raise e_bad_parameters;

      END;
      ELSE
      l_security_group_id:=0;
      END IF;

      BEGIN
      SELECT application_id
      INTO l_application_id
      FROM fnd_application
      WHERE application_short_name = p_application_short_name;

      SELECT responsibility_id
      INTO l_responsibility_id
      FROM fnd_responsibility
      WHERE responsibility_key = p_responsibility_key
      AND application_id = l_application_id;

      SELECT function_id
      INTO l_function_id
      FROM fnd_form_functions
      WHERE function_name = p_function_name;

      EXCEPTION
         WHEN OTHERS THEN
         RAISE e_bad_parameters;

      END;

  l_RFlink := icx_portlet.createExecLink
    (p_application_id => l_application_id,
     p_responsibility_id => l_responsibility_id,
     p_security_group_id => l_security_group_id,
     p_function_id => l_function_id,
     p_parameters => p_parameters,
     p_target => p_target,
     p_link_name => p_link_name,
     p_url_only => p_url_only);

   return l_RFlink;
EXCEPTION
   WHEN e_bad_parameters THEN
   RETURN '-1';

end createExecLink2;


function createExecLink(p_application_id         number,
                          p_responsibility_id      number,
                          p_security_group_id      number,
                          p_function_id            number,
                          p_parameters             VARCHAR2,
                          p_target                 VARCHAR2,
                          p_link_name              VARCHAR2,
                          p_url_only               VARCHAR2)
         return varchar2 is

l_RFLink       varchar2(4000);

begin

if p_url_only = 'N'
then

 if fnd_profile.value('APPLICATIONS_HOME_PAGE') = 'PHP'
 then
  icx_sec.ServerLevel;
 end if;

  l_RFLink := FND_RUN_FUNCTION.GET_RUN_FUNCTION_LINK
              (P_TEXT =>p_link_name,
               P_TARGET => p_target,
               P_FUNCTION_ID => p_function_id,
               P_RESP_APPL_ID => p_application_id,
               P_RESP_ID => p_responsibility_id,
               P_SECURITY_GROUP_ID => p_security_group_id,
               P_PARAMETERS => p_parameters);
else

 if fnd_profile.value('APPLICATIONS_HOME_PAGE') = 'PHP'
   then
  icx_sec.ServerLevel;
 end if;

  l_RFLink := FND_RUN_FUNCTION.GET_RUN_FUNCTION_URL
              (P_FUNCTION_ID => p_function_id,
               P_RESP_APPL_ID => p_application_id,
               P_RESP_ID => p_responsibility_id,
               P_SECURITY_GROUP_ID => p_security_group_id,
               P_PARAMETERS => p_parameters);
end if;

return l_RFlink;

end createExecLink;

function GET_CACHING_KEY(p_reference_path VARCHAR2) return varchar2
is
  cachingKey varchar2(55);
begin

  select caching_key into cachingKey
  from icx_portlet_customizations
  where reference_path = p_reference_path;

  return cachingKey;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return null;
  WHEN OTHERS THEN
    return null;

end GET_CACHING_KEY;

function listener_token return varchar2 is

    l_listener_token      VARCHAR2(240);
    l_server              VARCHAR2(240);

begin

      l_listener_token:=FND_WEB_CONFIG.DATABASE_ID;
      return l_listener_token;

end;


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

    l_listener_token := ICX_PORTLET.listener_token;
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


end ICX_PORTLET;

/
