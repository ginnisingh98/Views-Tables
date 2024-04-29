--------------------------------------------------------
--  DDL for Package Body JTF_AUTH_PRINCIPALS_B_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AUTH_PRINCIPALS_B_UPDATE" as
/* $Header: jtfusersyncb.pls 120.1.12010000.2 2018/04/02 13:28:24 ctilley noship $*/
function sync_uname(p_subscription_guid in raw,p_event in out NOCOPY WF_EVENT_T) return varchar2 is

l_param_list             WF_PARAMETER_LIST_T;
old_user_name            JTF_AUTH_PRINCIPALS_B.PRINCIPAL_NAME%TYPE;
l_event_name             VARCHAR2(2000);
l_event_key              JTF_AUTH_PRINCIPALS_B.PRINCIPAL_NAME%TYPE;
l_exists                 varchar2(1);
l_user_name              FND_USER.USER_NAME%TYPE;

begin

  l_event_name := p_event.getEventName();
  l_event_key  := p_event.GetEventKey();
  l_param_list := p_event.getparameterlist();


  if l_param_list is not null then
     for i in l_param_list.FIRST..l_param_list.LAST loop
         if (l_param_list(i).getName() = 'OLD_USERNAME') then
            old_user_name := l_param_list(i).getValue();
         end if;
     end loop;
  end if;

  if old_user_name is null then
       WF_EVENT.setErrorInfo(p_event,'ERROR');
       FND_MESSAGE.SET_NAME('JTF','JTF_SYNCH_NULL_NAME');
       app_exception.RAISE_EXCEPTION;
  end if;


  begin
       select 'Y' into l_exists from JTF_AUTH_PRINCIPALS_B
       where principal_name = old_user_name;

  exception when no_data_found then
       l_exists := 'N';
       return 'SUCCESS';
  end;

  begin
       update JTF_AUTH_PRINCIPALS_B
       set principal_name = l_event_key
       where  principal_name = old_user_name;

       return 'SUCCESS';
  end;

end sync_uname;

end JTF_AUTH_PRINCIPALS_B_UPDATE;

/
