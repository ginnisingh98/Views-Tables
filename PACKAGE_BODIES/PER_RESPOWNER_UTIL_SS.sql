--------------------------------------------------------
--  DDL for Package Body PER_RESPOWNER_UTIL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RESPOWNER_UTIL_SS" AS
/* $Header: perroutl.pkb 120.0 2005/05/31 19:40:30 appldev noship $ */

FUNCTION getTableSchema RETURN VARCHAR2 IS
l_status    VARCHAR2(100) := '';
l_industry  VARCHAR2(100) := '';
l_result    BOOLEAN;
l_schema_owner VARCHAR2(10) := '';
l_debug_level number := fnd_log.g_current_runtime_level;
l_stat_level number := fnd_log.level_statement;

BEGIN
    l_result := FND_INSTALLATION.GET_APP_INFO(
                'PER',
                 l_status,
                 l_industry,
                 l_schema_owner);

    if( l_stat_level >= l_debug_level  ) then
        fnd_log.string(fnd_log.level_statement,
        'per.plsql.'||gv_package||'.getTableSchema', 'l_schema_owner : '||l_schema_owner );
    end if;

    IF l_result THEN
       RETURN l_schema_owner;
    ELSE
       RETURN 'HR';
    END IF;
END getTableSchema;

---This is an internal function. Not in spec
---Function get_object_id
------------------------------
Function get_object_id(p_object_name in varchar2
                       ) return number is
v_object_id number;
l_api_name             CONSTANT VARCHAR2(30) := 'GET_OBJECT_ID';
Begin
      select object_id
      into v_object_id
      from fnd_objects
      where obj_name=p_object_name;

     return v_object_id;
exception
   when no_data_found then
     return null;
end;

FUNCTION get_owned_responsibilites(
     p_fnd_object in varchar2
    ,p_user_name in varchar2)
RETURN resp_owner_table IS

CURSOR owned_resps(p_object_id in number,
                   p_owner_name in varchar2) IS
 SELECT GNT.INSTANCE_PK1_VALUE, GNT.INSTANCE_PK2_VALUE, GNT.INSTANCE_PK3_VALUE
 FROM fnd_grants gnt, fnd_responsibility fr
 WHERE GNT.object_id = p_object_id AND
      (((GNT.grantee_type = 'USER' AND
      GNT.grantee_key = ''||p_owner_name||'') OR (GNT.grantee_type = 'GROUP' AND
      GNT.grantee_key in (select role_name from wf_user_roles wur where wur.user_name = fnd_global.user_name()
      and wur.user_orig_system = 'PER' and
      wur.user_orig_system_id = fnd_global.employee_id() and
      (start_date is NULL or start_date <= SYSDATE) and
      (expiration_date is NULL or expiration_date >= SYSDATE))))) AND
      (GNT.ctx_secgrp_id = -1 OR GNT.ctx_secgrp_id = FND_GLOBAL.SECURITY_GROUP_ID) AND
      (GNT.ctx_resp_id = -1 OR GNT.ctx_resp_id = FND_GLOBAL.RESP_ID) AND
      (GNT.ctx_resp_appl_id = -1 OR GNT.ctx_resp_appl_id = FND_GLOBAL.RESP_APPL_ID) AND
      (GNT.ctx_org_id = -1 OR GNT.ctx_org_id = FND_PROFILE.VALUE('ORG_ID')) AND
      GNT.start_date <= sysdate AND
      (GNT.end_date IS NULL OR GNT.end_date >= sysdate) AND
      ((GNT.INSTANCE_TYPE = 'INSTANCE')
      AND fr.responsibility_id = GNT.INSTANCE_PK1_VALUE
      AND fr.application_id = GNT.INSTANCE_PK2_VALUE
      AND trunc(sysdate) between trunc(fr.start_date) and nvl(fr.end_date, trunc(sysdate)));

l_resp_owner_table resp_owner_table;
I integer default 0;
l_debug_level number := fnd_log.g_current_runtime_level;
l_proc_level number := fnd_log.level_procedure;

BEGIN

  OPEN owned_resps(get_object_id(p_fnd_object),  p_user_name);
  LOOP
    I := I + 1;
    FETCH owned_resps into l_resp_owner_table(I);
    EXIT WHEN owned_resps%NOTFOUND;
  END LOOP;
  CLOSE owned_resps;  -- close cursor variable
  return l_resp_owner_table;

END get_owned_responsibilites;

PROCEDURE populate_respowner_temp_table (
     p_fnd_object in varchar2
    ,p_user_name in varchar2
)
IS
l_resp_owner_table resp_owner_table;
I integer default 0;
l_debug_level number := fnd_log.g_current_runtime_level;
l_proc_level number := fnd_log.level_procedure;
l_event_level number := fnd_log.level_event;

BEGIN

    if( l_event_level >= l_debug_level  ) then
      fnd_log.string(fnd_log.level_event,
      'per.plsql.'||gv_package||'.populate_respowner_temp_table', 'Entered, p_user_name : '||p_user_name);
    end if;

    --first get the owned responsibilites for the passed in user
    l_resp_owner_table := get_owned_responsibilites(
                          p_fnd_object => p_fnd_object
          		 ,p_user_name => p_user_name);

    --truncate the table before inserting
    execute immediate 'truncate table '||getTableSchema||'.per_responsibility_owner';
    FOR I IN 1 ..l_resp_owner_table.count LOOP
      insert into per_responsibility_owner(responsibility_id,
                                           application_id,
                                           security_group_id)
      values (l_resp_owner_table(I).responsibility_id
             ,l_resp_owner_table(I).application_id
	     ,l_resp_owner_table(I).security_group_id);
    END LOOP;
    commit;

    if( l_proc_level >= l_debug_level  ) then
      fnd_log.string(fnd_log.level_procedure,
      'per.plsql.'||gv_package||'.populate_respowner_temp_table', 'Rows Inserted : '||to_char(I));
    end if;

    if( l_event_level >= l_debug_level  ) then
      fnd_log.string(fnd_log.level_event,
      'per.plsql.'||gv_package||'.populate_respowner_temp_table', 'Leaving ..');
    end if;

END populate_respowner_temp_table;


FUNCTION getValueForParameter(pName in varchar2,
                              pParameters in wf_parameter_list_t)
RETURN VARCHAR2 IS
    pos     number := 1;
BEGIN
    if (pParameters is null) then
      return NULL;
    end if;

    pos := pParameters.LAST;
    while(pos is not null) loop
      if (pParameters(pos).getName() = pName) then
        return pParameters(pos).getValue();
      end if;
      pos := pParameters.PRIOR(pos);
    end loop;
    return NULL;
END getValueForParameter;


PROCEDURE CompleteNotiActivity(username in varchar2,
                               itemtype in varchar2,
                               itemkey  in varchar2,
                               activity in varchar2,
                               result   in varchar2)
IS

l_debug_level number := fnd_log.g_current_runtime_level;
l_event_level number := fnd_log.level_event;
l_exp_level number := fnd_log.level_exception;

BEGIN

  if( l_event_level >= l_debug_level  ) then
     fnd_log.string(fnd_log.level_event,
     'per.plsql.'||gv_package||'.CompleteNotiActivity', 'Entered, Revoke user : '||username);
  end if;

  IF (username is null) THEN
     return;
  END IF;

  wf_engine.SetItemAttrText(itemtype => itemtype,
                          itemkey  => itemkey,
                          aname => 'HR_REVOKE_ACCESS_USER_NAME',
                          avalue => username);

  wf_engine.CompleteActivity(itemtype => itemtype,
                             itemkey  => itemkey,
                             activity => activity,
                             result => result);
EXCEPTION
-- when other retry
 WHEN OTHERS THEN
     if( l_exp_level >= l_debug_level  ) then
       fnd_log.string(fnd_log.level_exception,
       'per.plsql.'||gv_package||'.CompleteNotiActivity', 'Exception, Could not send notification to Revoke user : '||username);
     end if;
     wf_engine.HandleError(itemtype => itemtype,
                           itemkey  => itemkey,
                           activity => activity,
                           command  => 'RETRY');
END CompleteNotiActivity;


PROCEDURE send_notification (
           p_seq in varchar2
          ,p_parameters in wf_parameter_list_t
          ,p_resp_name in varchar2
          ,p_owner in varchar2
          ,p_userid_clause in varchar2
) IS

block_actid number;
l_noti_ref_cursor ref_cursor;
l_user_name fnd_user.user_name%type;
l_debug_level number := fnd_log.g_current_runtime_level;
l_stat_level number := fnd_log.level_statement;
l_event_level number := fnd_log.level_event;

BEGIN
  if( l_event_level >= l_debug_level  ) then
     fnd_log.string(fnd_log.level_event,
     'per.plsql.'||gv_package||'.send_notification', 'Entered, p_resp_name : '||p_resp_name||
                   ' , itemtype : RESPOWN, itemKey : '||p_seq);
  end if;

  -- Create the notfication workflow process
  wf_engine.CreateProcess(itemtype => 'RESPOWN',
                        itemkey  => p_seq,
                        process  => 'HR_REVOKE_ACCESS_JSP_PRC');
  -- set the owner
  wf_engine.SetItemOwner(itemtype=> 'RESPOWN'
                        ,itemkey => p_seq
		        ,owner => p_owner);
  -- set other required attributes
  wf_engine.SetItemAttrText(itemtype => 'RESPOWN',
                            itemkey  => p_seq,
                            aname => 'FROM_USER_NAME',
                            avalue => p_owner);

  wf_engine.SetItemAttrText(itemtype => 'RESPOWN',
                            itemkey  => p_seq,
                            aname => 'RESPONSIBILITY',
                            avalue => p_resp_name);

  wf_engine.SetItemAttrText(itemtype => 'RESPOWN',
                            itemkey  => p_seq,
                            aname => 'JUSTIFICATION',
                            avalue => getValueForParameter('MESSAGE',
			                                   p_parameters));

  -- Start the notfication workflow process
  wf_engine.StartProcess(itemtype => 'RESPOWN',
                        itemkey  => p_seq);


  -- get the block activity id
  block_actid := wf_engine.GetItemAttrNumber(itemtype => 'RESPOWN',
			                         itemkey  => p_seq,
                                                 aname => 'HR_REVOKE_ACCESS_BLOCK_ACTID');

  if( l_stat_level >= l_debug_level  ) then
     fnd_log.string(fnd_log.level_statement,
     'per.plsql.'||gv_package||'.send_notification', 'Revoke Block Actid : '||block_actid);
  end if;

  --Loop thru the users and send notification
  OPEN l_noti_ref_cursor FOR(gv_user_name_stmt || ' and '|| p_userid_clause);
   LOOP
     FETCH l_noti_ref_cursor into l_user_name;
        IF(l_noti_ref_cursor%FOUND) THEN
	  CompleteNotiActivity(username => l_user_name,
		               itemtype => 'RESPOWN',
			       itemkey  => p_seq,
	                       activity => wf_engine.GetActivityLabel(block_actid),
		               result => 'Y');
          l_user_name := null;
	END IF;
     EXIT WHEN l_noti_ref_cursor%NOTFOUND;
   END LOOP;
  CLOSE l_noti_ref_cursor;  -- close cursor variable

  -- Now end the process
  wf_engine.CompleteActivity(itemtype => 'RESPOWN',
                             itemkey  => p_seq,
                             activity => wf_engine.GetActivityLabel(block_actid),
                             result => 'N');

  if( l_event_level >= l_debug_level  ) then
     fnd_log.string(fnd_log.level_event,
     'per.plsql.'||gv_package||'.send_notification', 'Leaving ...');
  end if;

END send_notification;


PROCEDURE raise_wfevent(
     p_event_name in varchar2
    ,p_event_data in wf_parameter_list_t
    ,p_resp_name in varchar2
    ,p_owner in varchar2
    ,p_userid_clause in varchar2 default null
)IS

  l_event_key number;
  l_message varchar2(10);
  --
  cursor get_seq is
  select hr_api_transactions_s.nextval from dual;
  --
  l_debug_level number := fnd_log.g_current_runtime_level;
  l_proc_level number := fnd_log.level_procedure;
  l_event_level number := fnd_log.level_event;

BEGIN
  if( l_event_level >= l_debug_level  ) then
     fnd_log.string(fnd_log.level_event,
     'per.plsql.'||gv_package||'.raise_wfevent', 'Entered, p_event_name : '||p_event_name);
  end if;

  -- check the status of the business event
  l_message := wf_event.test(p_event_name);
  --

  if( l_proc_level >= l_debug_level  ) then
     fnd_log.string(fnd_log.level_procedure,
     'per.plsql.'||gv_package||'.raise_wfevent', 'Subscription Type : '||l_message);
  end if;

  IF (l_message='MESSAGE') THEN
    --
    -- get a key for the event
    --
    open get_seq;
    fetch get_seq into l_event_key;
    close get_seq;


    -- raise wf_event
    wf_event.raise
    (p_event_name   =>  p_event_name,
     p_event_key    =>  l_event_key,
     p_parameters   =>  p_event_data);

    -- now send notifications to users
    send_notification(p_seq => to_char(l_event_key)
                     ,p_parameters => p_event_data
		     ,p_resp_name => p_resp_name
                     ,p_owner => p_owner
                     ,p_userid_clause => p_userid_clause);
  END IF;

  if( l_event_level >= l_debug_level  ) then
     fnd_log.string(fnd_log.level_event,
     'per.plsql.'||gv_package||'.raise_wfevent', 'Leaving ...');
  end if;

END raise_wfevent;


PROCEDURE revoke_block(
   itemtype     in  varchar2
  ,itemkey      in  varchar2
  ,actid        in  number
  ,funmode      in  varchar2
  ,result  in out nocopy varchar2)
IS
    --local variables

BEGIN
   -- Do nothing in cancel or timeout mode
   if (funmode <> wf_engine.eng_run) then
     result := wf_engine.eng_null;
     return;
   end if;
-- set the item attribute value with the current activity id
-- this will be used when the revoke access user notification is sent.
-- and to complete the blocked thread.
-- HR_REVOKE_ACCESS_USER_NAME
   wf_engine.setitemattrnumber(itemtype,itemkey,'HR_REVOKE_ACCESS_BLOCK_ACTID',actid);
   WF_STANDARD.BLOCK(itemtype,itemkey,actid,funmode,result);

--resultout := 'NOTIFIED';

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context(gv_package, '.revoke_block', itemtype,
                    itemkey, to_char(actid), funmode);
    raise;
END revoke_block;

/*
This is test subscription function to test the event 'oracle.apps.per.selfservice.respowner.revoke_access'.
Uncomment to test, btw needs to create revoke_access_table though.
FUNCTION revoke_access_wfevent_subscrb
( p_subscription_guid  in raw,
  p_event              in out NOCOPY wf_event_t)
RETURN VARCHAR2
IS

I integer := 0;
usrIdCnt number := 0;
BEGIN
usrIdCnt := to_number(p_event.GetValueForParameter('USER_COUNT'));

FOR I IN 1 .. usrIdCnt LOOP
	INSERT INTO REVOKE_ACCESS_TABLE (EVENT_KEY,
                                 EVENT_NAME,
                                 RESP_ID,
                                 RESP_APPL_ID,
				 SECURITY_GROUP_ID,
				 USERID_COUNT,
				 MESSAGE,
				 USER_NAME)

	VALUES(p_event.getEventKey,
	       p_event.getEventName,
	       to_number(p_event.GetValueForParameter('RESP_ID')),
	       to_number(p_event.GetValueForParameter('RESP_APPL_ID')),
	       to_number(p_event.GetValueForParameter('SECURITY_GROUP_ID')),
	       usrIdCnt,
	       p_event.GetValueForParameter('MESSAGE'),
	       p_event.GetValueForParameter('USER_NAME'||to_char(I)));
END LOOP;

COMMIT;

RETURN 'SUCCESS';

EXCEPTION
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('PER_RESPOWNER_UTIL_SS', 'revoke_access_wfevent_subscrb', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
END revoke_access_wfevent_subscrb;
*/


END PER_RESPOWNER_UTIL_SS;

/
