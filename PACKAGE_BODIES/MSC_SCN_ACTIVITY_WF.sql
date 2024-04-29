--------------------------------------------------------
--  DDL for Package Body MSC_SCN_ACTIVITY_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SCN_ACTIVITY_WF" AS
/* $Header: MSCSCWFB.pls 120.1 2008/02/19 12:32:45 skakani noship $*/


PROCEDURE SendFYINotification ( userID IN NUMBER, -- sender user id
                               respID in NUMBER, --sender resp id
                               language IN Varchar2,
                               wfName IN VARCHAR2,
                               wfProcessName IN varchar2,
                               p_activity_id IN NUMBER,
                               status IN OUT NOCOPY VARCHAR2
                               ) is

l_itemtype varchar2(30);
l_itemkey varchar2(300);
v_email varchar2(100);
v_receiver varchar2(80);

CURSOR C_ACTIVITYINFO (p_activity_id in number) IS
SELECT MSA.ACTIVITY_NAME, MSA.FINISH_BY, MSA.PRIORITY, MSA.STATUS, MSA.OWNER, MSA.ALTERNATE_OWNER,
  MSA.ACT_COMMENT,
  MS.SCENARIO_NAME, MSS.SCENARIO_SET_NAME
  FROM MSC_SCENARIO_ACTIVITIES MSA,
    MSC_SCENARIOS MS,
    MSC_SCENARIO_SETS MSS
WHERE
    ACTIVITY_ID= p_activity_id
    AND MSA.SCENARIO_ID=MS.SCENARIO_ID(+)
    AND MSA.SCENARIO_SET_ID=MSS.SCENARIO_SET_ID(+);

l_activity_name varchar2(80);
l_finish_by date;
l_priority number;
l_status number;
l_owner number;
l_alternate_owner number;
l_act_comment varchar2(4000);
l_itemowner varchar2(80);
l_scenario_name varchar2(80);
l_scenario_set_name varchar2(80);
l_owner_name varchar2(80);
l_alt_owner_name varchar2(80);
l_status_name varchar2(80);


begin
        -- call fnd_global.apps_initialize
        MSC_WS_COMMON.VALIDATE_USER_RESP(status, userId, respId);
        IF (status <> 'OK') THEN
           RETURN;
        END IF;

        -- validation of wfName and tokenValues array

        if wfName = 'SCN_MGMT' and p_activity_id is null then
           status:= 'ERROR_NO_ACTIVITY_ID';
           return;
        end if;

        select MSC_FORM_QUERY_S.nextval into l_itemkey from dual;

        select user_name into l_itemowner from fnd_user where user_id=userId; --WF owner

        open  c_activityinfo(p_activity_id);
        fetch  c_activityinfo into l_activity_name, l_finish_by, l_priority, l_status,
        l_owner, l_alternate_owner, l_act_comment, l_scenario_name ,l_scenario_set_name;
        close  c_activityinfo;

        --dbms_output.put_line('p_activity_id='||p_activity_id ||'l_activity_name='||l_activity_name);

        begin
          select user_name into l_owner_name from fnd_user where user_id = l_owner;
          select user_name into l_alt_owner_name from fnd_user where user_id = l_alternate_owner;
          select meaning into l_status_name from mfg_lookups where lookup_type like 'MSC_SCN_ACTIVITY_STATES' and lookup_code=l_status;

        exception when others then
          null;
          --DBMS_OUTPUT.PUT_LINE('SQLcode='||SQLCODE);
          --DBMS_OUTPUT.PUT_LINE(SQLERRM);
        end;

        if(wfProcessName = 'ACT_OWNER_PROCESS') then
          v_receiver := l_owner_name;   --owner -notifcation recipent
        else
          v_receiver := l_alt_owner_name;  --alt owner -notifcation recipent
        end if;

        --dbms_output.put_line(' NotifIcation recipent='||v_receiver);

        l_itemtype := wfName;

        wf_engine.CreateProcess( l_itemtype, l_itemkey, wfProcessName);

        wf_engine.setitemuserkey( l_itemtype, l_itemkey, 'USERKEY_SCN ' || l_itemkey);

        wf_engine.setitemowner( l_itemtype, l_itemkey, l_itemowner );

        wf_engine.setitemattrtext(l_itemtype, l_itemkey, 'SEND_TO_ROLE', v_receiver);
        wf_engine.setitemattrtext(l_itemtype, l_itemkey, 'ACTIVITY_NAME_ATTR', l_activity_name);
        wf_engine.setitemattrdate(l_itemtype, l_itemkey, 'FINISH_BY_ATTR', l_finish_by);
        wf_engine.setitemattrtext(l_itemtype, l_itemkey, 'STATUS_ATTR', l_status_name);
        wf_engine.setitemattrtext(l_itemtype, l_itemkey, 'OWNER_ATTR',l_owner_name);
        wf_engine.setitemattrtext(l_itemtype, l_itemkey, 'ALT_OWNER_ATTR',l_alt_owner_name);
        wf_engine.setitemattrtext(l_itemtype, l_itemkey, 'SCENARIO_ATTR',l_scenario_name);
        wf_engine.setitemattrtext(l_itemtype, l_itemkey, 'SCENARIO_SET_ATTR',l_scenario_set_name);


        wf_engine.startprocess(l_itemtype, l_itemkey);

        --DBMS_OUTPUT.PUT_LINE('WF started -Process='|| wfProcessName || ' USERKEY_SCN ' || l_itemkey);

        status:= 'SUCCESS';

        RETURN;

EXCEPTION when  others then
      --DBMS_OUTPUT.PUT_LINE('SQLcode='||SQLCODE);
      --DBMS_OUTPUT.PUT_LINE(SQLERRM);

      status:= 'UNKNOWN_ERROR';
end SendFYINotification;


-- -------------------------------------------------------
-- skakani 13-Feb-2008 --   New procedure Monitor_Scn_Changes
-- This procedure will be executed as a C/P, which will be scheduled
-- to run every day and identifies all the activities which are either
-- NOT started or STILL in progress, but expected to be complted as on date.
-- -------------------------------------------------------------------------

PROCEDURE Monitor_Scn_Changes(errbuf OUT NOCOPY VARCHAR2,
                              retcode OUT NOCOPY VARCHAR2) IS

    CURSOR c_activity_info IS
    SELECT MSA.ACTIVITY_ID    , MSA.ACTIVITY_NAME,
           MSA.FINISH_BY      , MSA.PRIORITY     ,
           MSA.STATUS         , MSA.OWNER        ,
           MSA.ALTERNATE_OWNER, MSA.ACT_COMMENT  ,
           MS.SCENARIO_NAME   , MSS.SCENARIO_SET_NAME
    FROM MSC_SCENARIO_ACTIVITIES MSA,
         MSC_SCENARIOS MS,
         MSC_SCENARIO_SETS MSS
    WHERE MSA.STATUS IN (1,2) -- 1 Not Started , 2 In Progress
    AND   MSA.FINISH_BY < TRUNC(SYSDATE)
    AND   MSA.SCENARIO_ID=MS.SCENARIO_ID(+)
    AND   MSA.SCENARIO_SET_ID=MSS.SCENARIO_SET_ID(+);

    l_userID   NUMBER; -- sender user id
    l_respID   NUMBER; --sender resp id
    l_language VARCHAR2(30);
    l_status   VARCHAR2(100);
    l_counter  NUMBER := 0;
BEGIN
    --fnd_global.apps_initialize(1068, 23329, 724);

    l_userID:= fnd_global.USER_ID; -- 1068
    l_respID:= fnd_global.RESP_ID;-- 23329, 724
    l_language:= userenv('LANG'); --fnd_global.NLS_LANGUAGE;
    MSC_UTIL.MSC_DEBUG('Lang:'||l_language);
    MSC_UTIL.MSC_DEBUG('User_Id:'||l_userID);
    MSC_UTIL.MSC_DEBUG('Resp_Id:'||l_respID);
    MSC_UTIL.MSC_DEBUG('Starting work flow...');

    l_counter  := 0;

    FOR rec_activity_info IN c_activity_info LOOP
        DECLARE
            l_scenario_name VARCHAR2(100);
            l_scenario_set_name VARCHAR2(100);
        BEGIN
            l_counter  := l_counter +1;
            l_scenario_name:= rec_activity_info.scenario_name;
            l_scenario_set_name := rec_activity_info.scenario_set_name;

            SendFYINotification( l_userID, -- sender user id
                                 l_respID, --sender resp id
                                 l_language,
                                 'SCN_MGMT',
                                 'ACT_ALT_OWNER_PROCESS',
                                 rec_activity_info.activity_id,
                                 l_status                 );
        EXCEPTION
        WHEN OTHERS THEN
            MSC_UTIL.MSC_DEBUG('Error sending Notification#'||l_counter);
            MSC_UTIL.MSC_DEBUG('Status: '||l_status);
            MSC_UTIL.MSC_DEBUG('scenario_name:'||l_scenario_name);
            MSC_UTIL.MSC_DEBUG('scenario_set_name:'||l_scenario_set_name);
        END;
    END LOOP;
    MSC_UTIL.MSC_DEBUG('Completed sending notifications.');
    retcode := 0;
EXCEPTION
    WHEN OTHERS THEN
        MSC_UTIL.MSC_DEBUG('Error generating Notifications.');
        MSC_UTIL.MSC_DEBUG('Status: '||l_status);
        errbuf := l_status||':'||sqlerrm(sqlcode);
        retcode := 1;
END Monitor_Scn_Changes;
END MSC_SCN_ACTIVITY_WF;

/
