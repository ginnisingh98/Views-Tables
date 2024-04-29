--------------------------------------------------------
--  DDL for Package Body MSC_WS_NOTIFICATION_BPEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_WS_NOTIFICATION_BPEL" AS
/* $Header: MSCWNOTB.pls 120.2.12010000.3 2008/07/08 18:42:37 bnaghi ship $  */



--========================= NOTIFICATION =====================================


procedure set_wf_approver_role
(
  itemtype IN VARCHAR2,
  itemkey  IN VARCHAR2,
  actid    IN NUMBER,
  funcmode IN VARCHAR2,
  result in out nocopy varchar2
) is
v_role_email varchar2(100);
n_ctr NUMBER :=0;
begin
    v_role_email := upper ( wf_engine.getitemattrtext( itemtype => itemtype, itemkey =>itemkey, aname => 'SEND_TO_EMAIL'));

    select count(*)
    into n_ctr
    from wf_local_roles
    where name = v_role_email;

    if n_ctr = 0
    then
    wf_directory.createadhocrole( role_name => v_role_email,
                                    role_display_name => v_role_email,
                                    role_description => v_role_email,
                                    notification_preference => 'MAILHTML',
                                    email_address => v_role_email,
                                    status => 'ACTIVE',
                                    expiration_date => NULL);

    end if;

    wf_engine.setitemattrtext(itemtype => itemtype,
                            itemkey => itemkey,
                            aname => 'SEND_TO_ROLE',
                            avalue => v_role_email);


    result := 'complete:y';

EXCEPTION
when no_data_found then
    result := 'complete:n';
    return;
when  others then
    result:= 'UNKNOWN_ERROR';
    return;

end set_wf_approver_role;

FUNCTION SendFYINotification ( userID IN NUMBER, --- sender user id
                               respID in NUMBER, --sender resp id
                               receiver in varchar2, -- notification goes to this guy
                               language IN Varchar2,
                               wfName IN VARCHAR2,
                               wfProcessName IN varchar2,
                               tokenValues IN MsgTokenValuePairList
                               )return VARCHAR2  is
i NUMBER :=0;
status varchar2(30);
l_itemtype varchar2(30);
l_itemkey varchar2(300);
l_useritemkey varchar2(300);
v_email varchar2(100);

begin
        -- call fnd_global.apps_initialize
        MSC_WS_COMMON.VALIDATE_USER_RESP(status, userId, respId);
        IF (status <> 'OK') THEN
           RETURN status;
        END IF;

        if (tokenValues is NULL or tokenValues.Count = 0 ) then
            return 'ERROR_NO_TOKENS_PROVIDED_IN_INPUT';
        end if;


        select MSC_FORM_QUERY_S.nextval into l_itemkey from dual;

        select email_address into v_email from fnd_user where user_name = receiver;

        l_itemtype := wfName;

        wf_engine.CreateProcess( l_itemtype, l_itemkey, wfProcessName);

        -- Following to be changed to be NLS compliant
        l_useritemkey := 'Planning Process';

        wf_engine.setitemowner( l_itemtype, l_itemkey, receiver );
        wf_engine.setitemattrtext(l_itemtype, l_itemkey, 'SEND_TO_ROLE', receiver);
        wf_engine.setitemattrtext(l_itemtype, l_itemkey, 'SEND_TO_EMAIL', v_email);


        for i in 1 .. tokenValues.COUNT
        loop
           --dbms_output.put_line('t-v:  ' || tokenValues(i).token || ' and ' || tokenValues(i).value);
            wf_engine.setitemattrtext( l_itemtype, l_itemkey, tokenValues(i).token, tokenValues(i).value);

            if (tokenValues(i).token = 'PROCESS')
            then l_useritemkey := l_useritemkey || ' (' ||tokenValues(i).value|| ')';
            end if;
        end loop;


        wf_engine.setitemuserkey(l_itemtype, l_itemkey, l_useritemkey);
        wf_engine.startprocess(l_itemtype, l_itemkey);

        return 'SUCCESS';

EXCEPTION
when no_data_found then
    return 'NO_DATA_FOUND';
when  others then
    return 'UNKNOWN_ERROR';

end SendFYINotification;


procedure Lookup
(
  itemtype IN VARCHAR2,
  itemkey  IN VARCHAR2,
  actid    IN NUMBER,
  funcmode IN VARCHAR2,
  result in out nocopy varchar2
) is
actTypeId varchar2(100);
actType varchar2(100);
begin
   actTypeId := wf_engine.getitemattrtext(itemtype, itemkey, 'ACTIVITY_TYPE_ID');

   select meaning  into actType
   from mfg_lookups
   where lookup_type = 'MSC_PROCESS_ACTIVITY_TYPES'
   and lookup_code = to_number(actTypeId);

   wf_engine.setitemattrtext(itemtype, itemkey, 'ACTIVITY_TYPE', actType);

   result := 'complete:y';

EXCEPTION
when no_data_found then
    result := 'complete:n';
    return;
when  others then
    result:= 'UNKNOWN_ERROR';
    return;

end Lookup;


procedure Lookup_Plan
(
  itemtype IN VARCHAR2,
  itemkey  IN VARCHAR2,
  actid    IN NUMBER,
  funcmode IN VARCHAR2,
  result in out nocopy varchar2
) is
planName varchar2(100);
planId varchar2(100);
begin
   planId := wf_engine.getitemattrtext(itemtype, itemkey, 'PLAN_ID');

   select COMPILE_DESIGNATOR
   into planName
   from msc_plans
   where plan_id = to_number(planId);

   wf_engine.setitemattrtext(itemtype, itemkey, 'PLAN_NAME', planName);

   result := 'complete:y';

EXCEPTION
when no_data_found then
    result := 'complete:n';
    return;
when  others then
    result:= 'UNKNOWN_ERROR';
    return;
end Lookup_Plan;


procedure Lookup_Escalation
(
  itemtype IN VARCHAR2,
  itemkey  IN VARCHAR2,
  actid    IN NUMBER,
  funcmode IN VARCHAR2,
  result in out nocopy varchar2
) is
escId varchar2(100);
escLevel varchar2(100);
begin
   escId := wf_engine.getitemattrtext(itemtype, itemkey, 'ESCALATION_LEVEL_ID');

   -- 1  => 'Primary Owner'
   -- 2  => 'Alternate Owner'

   select meaning  into escLevel
   from mfg_lookups
   where lookup_type = 'MSC_ESCALATION_LEVEL'
   and lookup_code = to_number(escId);

   wf_engine.setitemattrtext(itemtype, itemkey, 'ESCALATION_LEVEL', escLevel);

   result := 'complete:y';

EXCEPTION
when no_data_found then
    result := 'complete:n';
    return;
when  others then
    result:= 'UNKNOWN_ERROR';
    return;

end Lookup_Escalation;

 FUNCTION SendFYINotificationPublic (
           UserName               IN VARCHAR2,
           RespName     IN VARCHAR2,
           RespApplName IN VARCHAR2,
           SecurityGroupName      IN VARCHAR2,
				   receiver in varchar2,
				   language IN Varchar2,
				   wfName IN VARCHAR2,
				   wfProcessName IN varchar2,
				   tokenValues IN MsgTokenValuePairList)
  return VARCHAR2 is

     userid    number;
     respid    number;
     l_String VARCHAR2(30);
     error_tracking_num number;
     l_SecutirtGroupId  NUMBER;
     status varchar2(30);
   BEGIN
     error_tracking_num :=2010;
    MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
    IF (l_String <> 'OK') THEN

        RETURN l_String;
    END IF;

     error_tracking_num :=2030;
    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSC_SCN_MANAGE_SCENARIOS',l_SecutirtGroupId);
    IF (l_String <> 'OK') THEN

       RETURN l_string;

    END IF;
    error_tracking_num :=2040;
   status := SendFYINotification ( userid,respid,receiver ,language,wfName,wfProcessName ,tokenValues);


    return status;
      EXCEPTION
      WHEN others THEN
         status := 'ERROR_UNEXPECTED_'||error_tracking_num;

         return status ;
  end SendFYINotificationPublic;

END MSC_WS_NOTIFICATION_BPEL;

/
