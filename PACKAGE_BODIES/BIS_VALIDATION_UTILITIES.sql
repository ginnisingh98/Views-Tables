--------------------------------------------------------
--  DDL for Package Body BIS_VALIDATION_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_VALIDATION_UTILITIES" AS
/*$Header: BISVAUTB.pls 115.0 2003/06/26 20:52:09 tiwang noship $*/

g_request_id     	number;
g_concurrent_id  	number;
g_user_id               PLS_INTEGER     := 0;
g_login_id              PLS_INTEGER     := 0;


PROCEDURE PUT_MISSING_CURRENCY(
 p_object_type in varchar2,
 p_object_name in varchar2,
 p_EXCEPTION_MESSAGE in VARCHAR2 default null,
 p_CORRECTIVE_ACTION_FF in varchar2 default null,
 p_Rate_type in varchar2 default null,
 p_From_currency in varchar2 default null,
 p_To_currency in varchar2 default null,
 p_effective_date in date default null) is

begin
 g_concurrent_id:=FND_GLOBAL.conc_program_id;
 g_request_id:=FND_GLOBAL.conc_request_id;
 g_user_id := fnd_global.user_id;
 g_login_id := fnd_global.login_id;

 insert into bis_refresh_log(
  Request_id,
  Concurrent_id,
  object_type,
  Object_name,
  ERROR_TYPE,
  CORRECTIVE_ACTION_FF,
  Exception_message,
  Creation_date,
  Created_by,
  Last_update_date,
  Last_update_login,
  Last_updated_by,
  Attribute1,
  Attribute2,
  Attribute3,
  Attribute4,
  Attribute5,
  Attribute6,
  Attribute7,
  Attribute8,
  Attribute9,
  Attribute10 )
values (
g_request_id,
g_concurrent_id,
p_object_type,
p_object_name,
'MISSING_CURRENCY', --error type
p_CORRECTIVE_ACTION_FF,
p_EXCEPTION_MESSAGE,
sysdate,
g_user_id,
sysdate,
g_login_id,
g_user_id,
p_Rate_type,---attribute 1
p_From_currency,---attribute 2
p_To_currency,---attribute 3
p_effective_date,---attribute 4
null,---attribute 5
null ,---attribute 6
null,---attribute 7
null,---attribute 8
null, ---attribute 9
null); ---attribute 10

exception
  when others then
   raise;
end;


 PROCEDURE PUT_MISSING_UOM(
  p_object_type in varchar2,
 p_object_name in varchar2,
 p_EXCEPTION_MESSAGE in VARCHAR2 default null,
 p_CORRECTIVE_ACTION_FF in varchar2 default null,
 p_From_UOM in varchar2 default null,
 p_To_UOM in varchar2 default null,
 p_Inventory_items in varchar2 default null) is

begin
 g_concurrent_id:=FND_GLOBAL.conc_program_id;
 g_request_id:=FND_GLOBAL.conc_request_id;
 g_user_id := fnd_global.user_id;
 g_login_id := fnd_global.login_id;

 insert into bis_refresh_log(
  Request_id,
  Concurrent_id,
  object_type,
  Object_name,
  ERROR_TYPE,
  CORRECTIVE_ACTION_FF,
  Exception_message,
  Creation_date,
  Created_by,
  Last_update_date,
  Last_update_login,
  Last_updated_by,
  Attribute1,
  Attribute2,
  Attribute3,
  Attribute4,
  Attribute5,
  Attribute6,
  Attribute7,
  Attribute8,
  Attribute9,
  Attribute10 )
values (
g_request_id,
g_concurrent_id,
p_object_type,
p_object_name,
'MISSING_UOM', --error type
p_CORRECTIVE_ACTION_FF,
p_EXCEPTION_MESSAGE,
sysdate,
g_user_id,
sysdate,
g_login_id,
g_user_id,
p_From_UOM,---attribute 1
p_To_UOM,---attribute 2
p_Inventory_items,---attribute 3
null,---attribute 4
null,---attribute 5
null,---attribute 6
null,---attribute 7
null,---attribute 8
null, ---attribute 9
null); ---attribute 10

exception
  when others then
   raise;
end;




 PROCEDURE PUT_MISSING_PERIOD(
  p_object_type in varchar2,
  p_object_name in varchar2,
 p_EXCEPTION_MESSAGE in VARCHAR2 default null,
 p_CORRECTIVE_ACTION_FF in varchar2 default null,
 p_period_name in varchar2 default null,
 p_calendar in varchar2 default null) is

begin
 g_concurrent_id:=FND_GLOBAL.conc_program_id;
 g_request_id:=FND_GLOBAL.conc_request_id;
 g_user_id := fnd_global.user_id;
 g_login_id := fnd_global.login_id;

 insert into bis_refresh_log(
  Request_id,
  Concurrent_id,
  object_type,
  Object_name,
  ERROR_TYPE,
  CORRECTIVE_ACTION_FF,
  Exception_message,
  Creation_date,
  Created_by,
  Last_update_date,
  Last_update_login,
  Last_updated_by,
  Attribute1,
  Attribute2,
  Attribute3,
  Attribute4,
  Attribute5,
  Attribute6,
  Attribute7,
  Attribute8,
  Attribute9,
  Attribute10 )
values (
g_request_id,
g_concurrent_id,
p_object_type,
p_object_name,
'MISSING_PERIOD', --error type
p_CORRECTIVE_ACTION_FF,
p_EXCEPTION_MESSAGE,
sysdate,
g_user_id,
sysdate,
g_login_id,
g_user_id,
p_period_name,---attribute 1
p_calendar,---attribute 2
null,---attribute 3
null,---attribute 4
null,---attribute 5
null,---attribute 6
null,---attribute 7
null,---attribute 8
null, ---attribute 9
null); ---attribute 10

exception
  when others then
   raise;
end;

PROCEDURE PUT_OTHER_VALIDATION(
  p_object_type in varchar2,
 p_object_name in varchar2,
 p_error_type in varchar2 default null,
 p_EXCEPTION_MESSAGE in VARCHAR2 default null,
 p_CORRECTIVE_ACTION_FF in varchar2 default null) is

 begin
 g_concurrent_id:=FND_GLOBAL.conc_program_id;
 g_request_id:=FND_GLOBAL.conc_request_id;
 g_user_id := fnd_global.user_id;
 g_login_id := fnd_global.login_id;

 insert into bis_refresh_log(
  Request_id,
  Concurrent_id,
  object_type,
  Object_name,
  ERROR_TYPE,
  CORRECTIVE_ACTION_FF,
  Exception_message,
  Creation_date,
  Created_by,
  Last_update_date,
  Last_update_login,
  Last_updated_by,
  Attribute1,
  Attribute2,
  Attribute3,
  Attribute4,
  Attribute5,
  Attribute6,
  Attribute7,
  Attribute8,
  Attribute9,
  Attribute10 )
values (
g_request_id,
g_concurrent_id,
p_object_type,
p_object_name,
p_error_type, --error type
p_CORRECTIVE_ACTION_FF,
p_EXCEPTION_MESSAGE,
sysdate,
g_user_id,
sysdate,
g_login_id,
g_user_id,
null,---attribute 1
null,---attribute 2
null,---attribute 3
null,---attribute 4
null,---attribute 5
null,---attribute 6
null,---attribute 7
null,---attribute 8
null, ---attribute 9
null); ---attribute 10

exception
  when others then
   raise;
end;

PROCEDURE PUT_MISSING_CONTRACT(
 p_object_type in varchar2,
 p_object_name in varchar2,
 p_EXCEPTION_MESSAGE in VARCHAR2 default null,
 p_CORRECTIVE_ACTION_FF in varchar2 default null,
 p_Rate_type in varchar2 default null,
 p_From_currency in varchar2 default null,
 p_To_currency in varchar2 default null,
 p_date in date default null,
 p_date_override in date default null,
 p_Contract_number in varchar2 default null,
 p_Contract_id in number default null,
 p_Contract_status in varchar2 default null) is

begin
 g_concurrent_id:=FND_GLOBAL.conc_program_id;
 g_request_id:=FND_GLOBAL.conc_request_id;
 g_user_id := fnd_global.user_id;
 g_login_id := fnd_global.login_id;

 insert into bis_refresh_log(
  Request_id,
  Concurrent_id,
  object_type,
  Object_name,
  ERROR_TYPE,
  CORRECTIVE_ACTION_FF,
  Exception_message,
  Creation_date,
  Created_by,
  Last_update_date,
  Last_update_login,
  Last_updated_by,
  Attribute1,
  Attribute2,
  Attribute3,
  Attribute4,
  Attribute5,
  Attribute6,
  Attribute7,
  Attribute8,
  Attribute9,
  Attribute10 )
values (
g_request_id,
g_concurrent_id,
p_object_type,
p_object_name,
'MISSING_CONTRACT', --error type
p_CORRECTIVE_ACTION_FF,
p_EXCEPTION_MESSAGE,
sysdate,
g_user_id,
sysdate,
g_login_id,
g_user_id,
p_Rate_type,---attribute 1
p_From_currency,---attribute 2
p_To_currency,---attribute 3
p_date,---attribute 4
p_date_override,---attribute 5
p_Contract_number,---attribute 6
p_Contract_id ,---attribute 7
p_Contract_status,---attribute 8
null,---attribute 9
null); ---attribute 10

exception
  when others then
   raise;

end;

procedure put_missing_global_setup(
  p_parameter_list       IN DBMS_SQL.VARCHAR2_TABLE) is

  l_count number := 0;
  l_profile_list varchar2(4000) := '';
  l_return_value boolean := true;
  l_profile_name varchar2(100);

begin
   l_return_value := true;
   l_profile_list := null;
   l_count := p_parameter_list.first;
   LOOP
      l_profile_name := p_parameter_list(l_count);
      IF (l_profile_name = 'EDW_DEBUG') THEN
             l_profile_name := 'BIS_PMF_DEBUG';
      ELSIF (l_profile_name = 'EDW_TRACE') THEN
              l_profile_name := 'BIS_SQL_TRACE';
      END IF;
      IF (fnd_profile.value(l_profile_name) IS NULL) THEN
                l_profile_list := l_profile_list||' '||l_profile_name;
                l_return_value := false;
      END IF;
      EXIT WHEN l_count = p_parameter_list.last;
      l_count := p_parameter_list.next(l_count);
   END LOOP;

 IF (l_return_value) THEN
                null;
 ELSE
      fnd_message.set_name('BIS', 'BIS_DBI_PROFILE_NOT_SET');
      fnd_message.set_token('PROFILE_OPTION', l_profile_list);
      --- dbms_output.put_line('profilelist: '||l_profile_list);
      ---- dbms_output.put_line('messages: '||fnd_message.get);

      PUT_OTHER_VALIDATION(
       p_object_type=>null,
       p_object_name=>null,
       p_error_type =>'MISSING_GLOBAL_SETUP',
       p_EXCEPTION_MESSAGE=>fnd_message.get ,
       p_CORRECTIVE_ACTION_FF=>'BIS_SETUP_EDW_S');
 END IF;
end;

END BIS_VALIDATION_UTILITIES;

/
