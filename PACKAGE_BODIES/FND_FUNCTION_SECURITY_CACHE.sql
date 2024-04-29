--------------------------------------------------------
--  DDL for Package Body FND_FUNCTION_SECURITY_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FUNCTION_SECURITY_CACHE" as
/* $Header: AFFSCIB.pls 120.2 2005/11/09 07:05:07 rosthoma ship $ */

procedure raise_event(p_event_name in varchar2, p_event_key in varchar2 ,p_parameters in wf_parameter_list_t default NULL)
is
begin
  wf_event.raise(p_event_name=>p_event_name,p_event_key=>p_event_key,p_parameters => p_parameters);
  -- dbms_output.put_line('['||p_event_name||']['||p_event_key||']');
  exception when others then null;
end;

procedure delete_function(p_function_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin
 wf_event.addparametertolist(p_name          => 'FND_FUNCTION_ID',
                             p_value         => p_function_id,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.function.delete',
    p_event_key=>to_char(p_function_id));
end;

procedure insert_function(p_function_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin
  wf_event.addparametertolist(p_name         => 'FND_FUNCTION_ID',
                             p_value         => p_function_id,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.function.insert',
    p_event_key=>to_char(p_function_id),
    p_parameters => l_parameters);
end;

procedure update_function(p_function_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin
  wf_event.addparametertolist(p_name         => 'FND_FUNCTION_ID',
                             p_value         => p_function_id,
                             p_parameterlist => l_parameters);


  raise_event(p_event_name=>'oracle.apps.fnd.function.update',
    p_event_key=>to_char(p_function_id),
    p_parameters => l_parameters);
end;

procedure delete_grant(p_grant_guid in raw, p_grantee_type in varchar2,
  p_grantee_key in varchar2)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin
   wf_event.addparametertolist(p_name         => 'FND_GRANT_GUID',
                             p_value         => p_grant_guid,
                             p_parameterlist => l_parameters);


    wf_event.addparametertolist(p_name         => 'FND_GRANTEE_TYPE',
                             p_value         => p_grantee_type,
                             p_parameterlist => l_parameters);

    wf_event.addparametertolist(p_name         => 'FND_GRANTEE_KEY',
                             p_value         => p_grantee_key,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.grant.delete',
    p_event_key=>p_grant_guid||':'||p_grantee_type||':'||p_grantee_key,
    p_parameters => l_parameters);
end;

procedure insert_grant(p_grant_guid in raw, p_grantee_type in varchar2,
  p_grantee_key in varchar2)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin
   wf_event.addparametertolist(p_name         => 'FND_GRANT_GUID',
                             p_value         => p_grant_guid,
                             p_parameterlist => l_parameters);


    wf_event.addparametertolist(p_name         => 'FND_GRANTEE_TYPE',
                             p_value         => p_grantee_type,
                             p_parameterlist => l_parameters);

    wf_event.addparametertolist(p_name         => 'FND_GRANTEE_KEY',
                             p_value         => p_grantee_key,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.grant.insert',
    p_event_key=>p_grant_guid||':'||p_grantee_type||':'||p_grantee_key,
    p_parameters => l_parameters);
end;

procedure update_grant(p_grant_guid in raw, p_grantee_type in varchar2,
  p_grantee_key in varchar2)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin
   wf_event.addparametertolist(p_name         => 'FND_GRANT_GUID',
                             p_value         => p_grant_guid,
                             p_parameterlist => l_parameters);


    wf_event.addparametertolist(p_name         => 'FND_GRANTEE_TYPE',
                             p_value         => p_grantee_type,
                             p_parameterlist => l_parameters);

    wf_event.addparametertolist(p_name         => 'FND_GRANTEE_KEY',
                             p_value         => p_grantee_key,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.grant.update',
    p_event_key=>p_grant_guid||':'||p_grantee_type||':'||p_grantee_key,
    p_parameters => l_parameters);
end;

procedure delete_menu(p_menu_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin

  wf_event.addparametertolist(p_name         => 'FND_MENU_ID',
                             p_value         => p_menu_id,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.menu.delete',
    p_event_key=>to_char(p_menu_id),
    p_parameters => l_parameters);
end;

procedure insert_menu(p_menu_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin
  wf_event.addparametertolist(p_name         => 'FND_MENU_ID',
                             p_value         => p_menu_id,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.menu.insert',
    p_event_key=>to_char(p_menu_id),
    p_parameters => l_parameters);
end;

procedure update_menu(p_menu_id in number)
is
 l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin

  wf_event.addparametertolist(p_name         => 'FND_MENU_ID',
                             p_value         => p_menu_id,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.menu.update',
    p_event_key=>to_char(p_menu_id),
    p_parameters => l_parameters);
end;

procedure delete_menu_entry(p_menu_id in number, p_sub_menu_id in number,
  p_function_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin
  update_menu(p_menu_id);
  wf_event.addparametertolist(p_name         => 'FND_MENU_ID',
                             p_value         => p_menu_id,
                             p_parameterlist => l_parameters);

  wf_event.addparametertolist(p_name         => 'FND_SUB_MENU_ID',
                             p_value         => p_sub_menu_id,
                             p_parameterlist => l_parameters);

  wf_event.addparametertolist(p_name         => 'FND_FUNCTION_ID',
                             p_value         => p_menu_id,
                             p_parameterlist => l_parameters);



  raise_event(p_event_name=>'oracle.apps.fnd.menu.entry.delete',
    p_event_key=>to_char(p_menu_id)||':'||to_char(p_sub_menu_id)||':'||
      to_char(p_function_id),
      p_parameters => l_parameters);
end;

procedure insert_menu_entry(p_menu_id in number, p_sub_menu_id in number,
  p_function_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin
  update_menu(p_menu_id);

  wf_event.addparametertolist(p_name         => 'FND_MENU_ID',
                             p_value         => p_menu_id,
                             p_parameterlist => l_parameters);

  wf_event.addparametertolist(p_name         => 'FND_SUB_MENU_ID',
                             p_value         => p_sub_menu_id,
                             p_parameterlist => l_parameters);

  wf_event.addparametertolist(p_name         => 'FND_FUNCTION_ID',
                             p_value         => p_menu_id,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.menu.entry.insert',
    p_event_key=>to_char(p_menu_id)||':'||to_char(p_sub_menu_id)||':'||
      to_char(p_function_id),
      p_parameters => l_parameters);
end;

procedure update_menu_entry(p_menu_id in number, p_sub_menu_id in number,
  p_function_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin
  update_menu(p_menu_id);

   wf_event.addparametertolist(p_name         => 'FND_MENU_ID',
                             p_value         => p_menu_id,
                             p_parameterlist => l_parameters);

  wf_event.addparametertolist(p_name         => 'FND_SUB_MENU_ID',
                             p_value         => p_sub_menu_id,
                             p_parameterlist => l_parameters);

  wf_event.addparametertolist(p_name         => 'FND_FUNCTION_ID',
                             p_value         => p_menu_id,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.menu.entry.update',
    p_event_key=>to_char(p_menu_id)||':'||to_char(p_sub_menu_id)||':'||
      to_char(p_function_id),
      p_parameters => l_parameters);
end;

procedure delete_resp(p_resp_id in number, p_resp_appl_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin

  wf_event.addparametertolist(p_name         => 'FND_RESPONSIBILITY_ID',
                             p_value         => p_resp_id,
                             p_parameterlist => l_parameters);

  wf_event.addparametertolist(p_name         => 'FND_RESPONSIBILITY_APPS_ID',
                             p_value         => p_resp_appl_id,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.resp.delete',
    p_event_key=>p_resp_id||':'||p_resp_appl_id,
    p_parameters => l_parameters);
end;

procedure insert_resp(p_resp_id in number, p_resp_appl_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin

  wf_event.addparametertolist(p_name         => 'FND_RESPONSIBILITY_ID',
                             p_value         => p_resp_id,
                             p_parameterlist => l_parameters);

  wf_event.addparametertolist(p_name         => 'FND_RESPONSIBILITY_APPS_ID',
                             p_value         => p_resp_appl_id,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.resp.insert',
    p_event_key=>p_resp_id||':'||p_resp_appl_id,
    p_parameters => l_parameters);
end;

procedure update_resp(p_resp_id in number, p_resp_appl_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin

  wf_event.addparametertolist(p_name         => 'FND_RESPONSIBILITY_ID',
                             p_value         => p_resp_id,
                             p_parameterlist => l_parameters);

  wf_event.addparametertolist(p_name         => 'FND_RESPONSIBILITY_APPS_ID',
                             p_value         => p_resp_appl_id,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.resp.update',
    p_event_key=>p_resp_id||':'||p_resp_appl_id,
    p_parameters => l_parameters);
end;

procedure delete_secgrp(p_security_group_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin

  wf_event.addparametertolist(p_name         => 'FND_SECURITY_GROUP_ID',
                             p_value         => p_security_group_id,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.secgrp.delete',
    p_event_key=>to_char(p_security_group_id),
    p_parameters => l_parameters);
end;

procedure insert_secgrp(p_security_group_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin
  wf_event.addparametertolist(p_name         => 'FND_SECURITY_GROUP_ID',
                             p_value         => p_security_group_id,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.secgrp.insert',
    p_event_key=>to_char(p_security_group_id),
    p_parameters => l_parameters);
end;

procedure update_secgrp(p_security_group_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin

  wf_event.addparametertolist(p_name         => 'FND_SECURITY_GROUP_ID',
                             p_value         => p_security_group_id,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.secgrp.update',
    p_event_key=>to_char(p_security_group_id),
    p_parameters => l_parameters);
end;

procedure delete_user(p_user_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin
  wf_event.addparametertolist(p_name         => 'FND_USER_ID',
                             p_value         => p_user_id,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.user.delete',
    p_event_key=>to_char(p_user_id),
    p_parameters => l_parameters);
end;

procedure insert_user(p_user_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin
  raise_event(p_event_name=>'oracle.apps.fnd.user.insert',
    p_event_key=>to_char(p_user_id),
    p_parameters => l_parameters);
end;

procedure update_user(p_user_id in number)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin

  wf_event.addparametertolist(p_name         => 'FND_USER_ID',
                             p_value         => p_user_id,
                             p_parameterlist => l_parameters);

  raise_event(p_event_name=>'oracle.apps.fnd.user.update',
    p_event_key=>to_char(p_user_id),
    p_parameters => l_parameters);
end;

procedure delete_user_resp(p_user_id in number, p_resp_id in number,
  p_resp_appl_id in number)
is
begin
  return;
end;

procedure insert_user_resp(p_user_id in number, p_resp_id in number,
  p_resp_appl_id in number)
is
begin
 return;
end;

procedure update_user_resp(p_user_id in number, p_resp_id in number,
  p_resp_appl_id in number)
is
begin
 return;
end;

procedure delete_user_role(p_user_id in number, p_role_name in varchar2)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin
  wf_event.addparametertolist(p_name         => 'FND_USER_ID',
                             p_value         => p_user_id,
                             p_parameterlist => l_parameters);

  wf_event.addparametertolist(p_name         => 'FND_ROLE',
                             p_value         => p_role_name,
                             p_parameterlist => l_parameters);


  raise_event(p_event_name=>'oracle.apps.fnd.user.role.delete',
    p_event_key=>to_char(p_user_id)||':'||p_role_name,
    p_parameters => l_parameters);
end;

procedure insert_user_role(p_user_id in number, p_role_name in varchar2)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin

  wf_event.addparametertolist(p_name         => 'FND_USER_ID',
                             p_value         => p_user_id,
                             p_parameterlist => l_parameters);

  wf_event.addparametertolist(p_name         => 'FND_ROLE',
                             p_value         => p_role_name,
                             p_parameterlist => l_parameters);



  raise_event(p_event_name=>'oracle.apps.fnd.user.role.insert',
    p_event_key=>to_char(p_user_id)||':'||p_role_name,
    p_parameters => l_parameters);
end;

procedure update_user_role(p_user_id in number, p_role_name in varchar2)
is
l_parameters wf_parameter_list_t := wf_parameter_list_t();
begin

  wf_event.addparametertolist(p_name         => 'FND_USER_ID',
                             p_value         => p_user_id,
                             p_parameterlist => l_parameters);

  wf_event.addparametertolist(p_name         => 'FND_ROLE',
                             p_value         => p_role_name,
                             p_parameterlist => l_parameters);



  raise_event(p_event_name=>'oracle.apps.fnd.user.role.update',
              p_event_key=>to_char(p_user_id)||':'||p_role_name,
	      p_parameters => l_parameters);
end;

end FND_FUNCTION_SECURITY_CACHE;

/
