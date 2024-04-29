--------------------------------------------------------
--  DDL for Package Body IRC_LOGIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_LOGIN" as
/* $Header: irclogin.pkb 120.3 2008/01/21 14:59:30 gaukumar noship $ */
--
function createExecLink2
(p_function_name varchar2
,p_application_short_name varchar2
,p_responsibility_key varchar2
,p_security_group_key varchar2
,p_server_name varchar2
,p_parameters varchar2 default null)
return varchar2 is
  --
  l_retval varchar2(32767);
  l_b boolean;
  l_server_id number := null;
  --
  cursor get_func_id is
  select function_id
  from fnd_form_functions
  where function_name=p_function_name;
  l_function_id fnd_form_functions.function_id%type;
  --
  cursor get_user_id is
  select user_id
  from fnd_user
  where user_name=substr(FND_WEB_SEC.GET_GUEST_USERNAME_PWD()
                        ,0
                        ,instr(FND_WEB_SEC.GET_GUEST_USERNAME_PWD(),'/')-1);
  l_user_id fnd_user.user_id%type;
  --
  cursor get_resp_id is
  select responsibility_id
  from fnd_responsibility
  where responsibility_key=p_responsibility_key;
  l_responsibility_id fnd_responsibility.responsibility_id%type;
  --
  cursor get_app_id is
  select application_id
  from fnd_application
  where application_short_name=p_application_short_name;
  l_application_id fnd_application.application_id%type;
  --
  cursor get_sec_grp_id is
  select security_group_id
  from fnd_security_groups
  where security_group_key=p_security_group_key;
  l_security_group_id fnd_security_groups.security_group_id%type;
  --
  cursor get_server_id is
  select node_id
  from fnd_nodes
  where lower(node_name)=lower(p_server_name);

  cursor get_server_id2 is
  select node_id
  from fnd_nodes
  where lower(webhost)=lower(p_server_name);
  --
  begin
  --
  open get_func_id;
  fetch get_func_id into l_function_id;
  close get_func_id;
  --
  open get_user_id;
  fetch get_user_id into l_user_id;
  close get_user_id;
  --
  open get_resp_id;
  fetch get_resp_id into l_responsibility_id;
  close get_resp_id;
  --
  open get_app_id;
  fetch get_app_id into l_application_id;
  close get_app_id;
  --
  open get_sec_grp_id;
  fetch get_sec_grp_id into l_security_group_id;
  close get_sec_grp_id;
  --
  open get_server_id2;
  fetch get_server_id2 into l_server_id;
  close get_server_id2;
  --
  if l_server_id is null then
    open get_server_id;
    fetch get_server_id into l_server_id;
    close get_server_id;
  end if;
  --
  if l_server_id is null then
    fnd_global.apps_initialize
    (user_id          =>l_user_id
    ,resp_id          => l_responsibility_id
    ,resp_appl_id     => l_application_id
    ,security_group_id=>l_security_group_id);
  else
    fnd_global.apps_initialize
    (user_id          =>l_user_id
    ,resp_id          => l_responsibility_id
    ,resp_appl_id     => l_application_id
    ,security_group_id=>l_security_group_id
    ,server_id        =>l_server_id);
  end if;
  --
  l_retval:=icx_portlet.createExecLink
  (p_application_id   =>l_application_id
  ,p_responsibility_id=>l_responsibility_id
  ,p_security_group_id=>l_security_group_id
  ,p_function_id      =>l_function_id
  ,p_parameters       =>p_parameters
  ,p_link_name        =>''
  ,p_url_only         =>'Y');
  --
  return l_retval;
end createExecLink2;
--
FUNCTION validate_login(
    p_user    IN VARCHAR2,
    p_pwd     IN VARCHAR2,
    p_disable in varchar2) return VARCHAR2 is
--
    user        VARCHAR2(100) := upper(p_user);
    userID      NUMBER := -1;
    l_result    varchar2(10) := 'N';
    l_loginID   number;
    l_expired   varchar2(10);
--
begin
  hr_utility.set_location('calling validate_login user_name='||p_user||' and pwd:'||p_pwd||' and disable='||p_disable,10);
  l_result := fnd_web_sec.validate_login(p_user => p_user,
                                         p_pwd  => p_pwd);
  hr_utility.set_location('result='||l_result,20);

  if l_result = 'N' and p_disable = 'Y'  then
    begin
      hr_utility.set_location('calling disable user',30);
      select user_id into userID
      from fnd_user
      where user_name = user AND
      user_id <> 6 and
      (start_date <= sysdate) AND
      (end_date is null or end_date > sysdate);
      fnd_web_sec.unsuccessful_login(userID);
      hr_utility.set_location('called disable user',40);
      exception
        when no_data_found then
        hr_utility.set_location('No data found',10);
        return 'N';
    end;
  end if;
  if l_result = 'Y' and p_disable = 'Y'then
    hr_utility.set_location('creating new session loginid='||l_loginID||' expired='||l_expired,10);
--    fnd_signon.new_icx_session(userID, l_loginID, l_expired);
  end if;
  hr_utility.set_location('final result:='||l_result,40);
  --
  return l_result;
  --
end validate_login;
--
procedure convertSession(p_token in VARCHAR2,
                         p_username IN VARCHAR2,
                         p_password IN VARCHAR2) is
begin
  hr_utility.set_location('calling for user_name'||p_username,10);
  OracleApps.convertSession(
               c_token => p_token
              ,i_1     => p_username
              ,i_2     => p_password);
  hr_utility.set_location('done calling convertsession'||p_username,20);
  FND_USER_PKG.UpdateUser (
               x_user_name       => p_username
              ,x_owner           => null
              ,x_last_logon_date => sysdate
              );
  hr_utility.set_location('update usre:'||p_username||
                          ' with date'||to_char(sysdate,'DD-MON-YYYY hh:mm:ss'),30);
end convertSession;
--
end irc_login;

/
