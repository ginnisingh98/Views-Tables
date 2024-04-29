--------------------------------------------------------
--  DDL for Package Body ZPB_WF_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_WF_EVENT" AS
/* $Header: zpbwfevent.plb 120.5 2007/12/04 16:22:37 mbhat noship $ */


  procedure SET_ATTRIBUTES (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2)
   AS

   ACID number;
   ACNAME varchar2(300);
   retval varchar2(4000);
   l_result  varchar2(16);
   workflowProcess varchar2(30);
   TaskID  number;
   ACstatusID number;
   ACstatusCode varchar2(30);
   owner varchar2(30);
   ownerID      number;
   respID number;
   respAppID number;
  -- l_business_area  varchar2(140);
   l_business_area_id number;

   BEGIN


IF (funcmode = 'RUN') THEN


    resultout := 'ERROR';

   ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
             Itemkey => ItemKey,
             aname => 'ACID');

   l_result := wf_engine.GetItemAttrText(Itemtype => ItemType,
             Itemkey => ItemKey,
             aname => 'RESULT');

  ownerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
             Itemkey => ItemKey,
             aname => 'OWNERID');
  respID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
             Itemkey => ItemKey,
             aname => 'RESPID');
  respAPPID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
             Itemkey => ItemKey,
             aname => 'RESPAPPID');

  -- BUSINESS AREA ID.
  l_business_area_id := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'BUSINESSAREAID');


  fnd_global.apps_initialize(ownerID, respID, RespAppId);


  -- Get status and name of AC
  --
  -- AGB 11/07/2003 Publish change
  select STATUS_CODE, NAME, PUBLISHED_BY
  into ACstatusCode, ACname, OwnerID
  from zpb_analysis_cycles
  where ANALYSIS_CYCLE_ID = ACID;

  Owner := ZPB_WF_NTF.ID_to_FNDUser(OwnerID);




-- set item key for execute concurrent program


wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'ARG1',
                           avalue => ItemKey);

-- Set current value of Taskseq [not sure if it is always 1 might be for startup]
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'TASKSEQ',
                           avalue => 0);
-- set Cycle ID!
-- wf_engine.SetItemAttrNumber(Itemtype => ItemType,
--                           Itemkey => ItemKey,
--                           aname => 'ACID',
--                           avalue => ACID);
-- set cycle Name!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'ACNAME',
                           avalue => ACNAME);



 /*
   -- future use currently just useing ID not display name.
   -- set business area info if we have it
      if l_business_area_id  is not null or  l_business_area_id > 0 then

          -- get business area display name
          select NAME into  l_business_area
           from zpb_business_areas_vl
           where BUSINESS_AREA_ID = l_business_area_id;

          -- SET business area display name to BUSINESSAREA in notification
          wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'BUSINESSAREA',
                           avalue =>  l_business_area);
       end if;

 */


-- globals set to WF attributes

-- This should be the EPB controller user.
   wf_engine.SetItemOwner(ItemType => ItemType,
                           ItemKey => ItemKey,
                           owner => owner);

-- set EPBPerformer to owner name for notifications DEFAULT!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'EPBPERFORMER',
                           avalue => owner);

-- will get error notifications
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'WF_ADMINISTRATOR',
                           avalue => owner);







--  wf_engine.SetItemAttrText(Itemtype => ItemType,
--                           Itemkey => ItemKey,
--                           aname => 'FNDUSERNAM',
--                           avalue => owner);
--
--  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
--                           Itemkey => ItemKey,
--                           aname => 'OWNERID',
--                           avalue => ownerID);

--  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
--                           Itemkey => ItemKey,
--                           aname => 'RESPID',
--                           avalue => respID);

--  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
--                           Itemkey => ItemKey,
--                           aname => 'RESPAPPID',
--                           avalue => respAppID);

   resultout := 'COMPLETE';
 end if;

 return;

exception
    when others then
        WF_CORE.CONTEXT('ZPB_WF_EVENT.SET_ATTRIBUTES', itemtype, itemkey, to_char(actid), funcmode);
        raise;
end SET_ATTRIBUTES;



procedure GET_ATTRIBUTES (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2)

   AS

   InstanceID  number;
   ACID number;
   InstDesc varchar2(300);
   retval varchar2(4000);
   l_result  varchar2(30);
   workflowProcess varchar2(30);
   TaskID  number;
   ACstatusID number;
   ACstatusCode varchar2(30);
   owner varchar2(30);
   ownerID      number;
   respID number;
   respAppID number;
   workflow varchar(30);
   thisRecipient varchar2(100);
   rolename varchar2(100);
   relative number;
   l_errorname varchar(30);
   l_errormsg  varchar2(2000);


   BEGIN


IF (funcmode = 'RUN') THEN

   resultout := 'ERROR';
   relative := 7;
   -- get and set the BP run desc
   InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'INSTANCEID');

  if InstanceID is not NULL then

    select INSTANCE_DESCRIPTION
    into InstDesc
    from ZPB_ANALYSIS_CYCLE_INSTANCES
    where INSTANCE_AC_ID = InstanceID;

    -- set descripton
    wf_engine.SetItemAttrText(Itemtype => ItemType,
			   Itemkey => ItemKey,
 			   aname => 'INSTANCEDESC',
			   avalue => InstDesc);
  end if;



   ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'ACID');


   ownerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
             Itemkey => ItemKey,
             aname => 'OWNERID');


  -- if result is normal when coming from conc makeinstance then send full notificaton

  select ACTIVITY_RESULT_CODE, ERROR_NAME, ERROR_MESSAGE
    into l_result, l_errorName, l_errormsg
    from wf_item_activity_statuses_v
    where item_type = 'ZPBSCHED' AND ACTIVITY_NAME = 'SUBMIT_CONC_REQUEST'
    AND ITEM_KEY = ItemKey;

  if upper(l_result) = 'NORMAL' then
      -- set up users for notifications
      ZPB_WF_EVENT.SET_AUTHORIZED_USERS (ACID, OwnerID, itemtype, itemkey, instanceID);
  else
      -- some error encountered
      -- BUG 4355208 WF_INVALID_ROLE ancillary corrections for rolename and recipients
      rolename := zpb_wf_ntf.MakeRoleName(ACID, instanceID, OwnerID);
      zpb_wf_ntf.SetRole(rolename, relative);

     -- BUG 4407850 06/02/2005 NTF NOT SENT TO CALLER changed ATTRNumber to ATTRTEXT
      thisRecipient := wf_engine.GetItemAttrText(Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'EPBPERFORMER');


      if zpb_wf_ntf.user_in_role(rolename, thisRecipient) = 'N'  then
          ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisRecipient);
      end if;

     -- BUG 4407850 06/02/2005 NTF NOT SENT TO CALLER changed ATTRNumber to ATTRTEXT
      thisRecipient := wf_engine.GetItemAttrText(Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'FNDUSERNAM');

      if zpb_wf_ntf.user_in_role(rolename, thisRecipient) = 'N'  then
         ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisRecipient);
      end if;

      -- reset EPBPERFORMER to ntf role
      wf_engine.SetItemAttrText(Itemtype => ItemType,
              Itemkey => ItemKey,
              aname => 'EPBPERFORMER',
              avalue => RoleName);


     -- set error message

       wf_engine.SetItemAttrText(Itemtype => ItemType,
                     Itemkey => ItemKey,
                     aname => 'ISSUEMSG',
                     avalue => l_result || ': '  || l_errorname || ' ' || l_errormsg);

  end if;


  resultout := 'COMPLETE';

end if;


 return;



exception
    when others then
        WF_CORE.CONTEXT('ZPB_WF_EVENT.GET_ATTRIBUTES', itemtype, itemkey, to_char(actid), funcmode);
        raise;



end GET_ATTRIBUTES;



Procedure ACSTART_EVENT(ACID in number,
             p_start_mem IN VARCHAR2,
             p_end_mem   IN VARCHAR2,
             p_send_date in date default Null,
             x_event_key out nocopy varchar2)

   IS

   ACname       varchar2(300);
   ACstatusCode varchar2(30);
   -- 04/23/03 AGB ZPBSCHED

   workflow varchar2(30);
   itemkey            varchar2(240);

   charDate varchar2(30);
   owner varchar2(30);
   ownerID      number;
   respNam varchar2(80);
   respID number;
   respAppID number;
   errbuf varchar2(80);
   retcode number;

   l_event_name varchar2(50);
   l_event_key  varchar2(250);
   l_parameter_list  wf_parameter_list_t := wf_parameter_list_t();
   taskseq number;
   l_EVENT_DATA clob;
   l_send_date date;
   l_business_area_id number;


 BEGIN

 errbuf := ' ';


-- Get status and name of AC
--
select STATUS_CODE, NAME, PUBLISHED_BY, BUSINESS_AREA_ID
into ACstatusCode, ACname, OwnerID, l_business_area_id
from zpb_analysis_cycles
where ANALYSIS_CYCLE_ID = ACID;

-- Lookfor and Abort Running process because it is a restart
ZPB_WF.CallWFAbort(ACID);


--  ownerID := fnd_global.USER_ID;
--  respID  := fnd_global.RESP_ID;
--  respAppID  := fnd_global.RESP_APPL_ID;


--==============================================================
-- Get responsiblity for published by user ID
--==============================================================
respAppID :=210;

select min(RESPONSIBILITY_ID)
into respID
from FND_USER_RESP_GROUPS g
where USER_ID = OwnerID and RESPONSIBILITY_APPLICATION_ID = respAppID
and g.RESPONSIBILITY_ID in (select r.RESPONSIBILITY_ID
from FND_RESPONSIBILITY r where RESPONSIBILITY_KEY in
('ZPB_CONTROLLER_RESP', 'ZPB_SUPER_CONTROLLER_RESP', 'ZPB_MANAGER_RESP'));

-- fnd_global.apps_initialize(ownerID, respID, RespAppId);

Owner := ZPB_WF_NTF.ID_to_FNDUser(OwnerID);
workflow := 'ACIDWFEVENT_START';

-- create itemkey and event key for workflow - they are the same value
charDate := to_char(sysdate, 'MM/DD/YYYY-HH24-MI-SS');
l_event_key := rtrim(substr(ACName, 1, 50), ' ') || '-' || to_char(ACID) || '-' || workflow ||  '-' || charDate ;

-- set out variable for item_key - Note l_event_key[BES] =item_key[WF]
x_event_key := l_event_key;
l_event_name := 'oracle.apps.zpb.bp.local.start';
l_send_date := p_send_date;


-- Set parameters

   wf_event.AddParameterToList('ACID', ACID, l_parameter_list);
   wf_event.AddParameterToList('OVERIDE_START_MEM' ,p_start_mem , l_parameter_list);
   wf_event.AddParameterToList('OVERIDE_END_MEM' ,p_end_mem , l_parameter_list);
   wf_event.AddParameterToList('RESPAPPID', respAppID, l_parameter_list);
   wf_event.AddParameterToList('RESPID', respID, l_parameter_list);
   wf_event.AddParameterToList('OWNERID', OwnerID, l_parameter_list);
   wf_event.AddParameterToList('OWNER', Owner, l_parameter_list);
   wf_event.AddParameterToList('ARG1', l_event_key, l_parameter_list);
   taskseq := 0;
   wf_event.AddParameterToList('TASKSEQ', taskseq, l_parameter_list);
   wf_event.AddParameterToList('ACNAME', ACNAME, l_parameter_list);
   wf_event.AddParameterToList('EPBPERFORMER', Owner, l_parameter_list);
   wf_event.AddParameterToList('WF_ADMINISTRATOR', Owner, l_parameter_list);
-- wf_event.AddParameterToList('FNDUSERNAM', Owner, l_parameter_list);
   -- caller of program
   wf_event.AddParameterToList('FNDUSERNAM', ZPB_WF_NTF.ID_to_FNDUser(fnd_global.USER_ID), l_parameter_list);


--  Budnik, A.   1/12/06  B 4947816 add in business area id
   wf_event.AddParameterToList('BUSINESSAREAID', l_business_area_id, l_parameter_list);

   wf_event.raise(l_event_name, l_event_key, l_event_data,  l_parameter_list, l_send_date);
   l_parameter_list.DELETE;

   commit;
   return;

   exception
     when others then
         raise;

end ACSTART_EVENT;


procedure SET_AUTHORIZED_USERS (ACID in number,
                  OwnerID in number,
                  itemtype in varchar2,
                  itemkey  in varchar2,
                  instanceID in number)

IS

  rolename varchar2(100);
  relative number := 7;
  thisRecipID  number;
  thisRecipient varchar2(100);
  thisUserID number;


  CURSOR c_notify is
    select user_id
    from ZPB_BP_EXTERNAL_USERS
    where ANALYSIS_CYCLE_ID = ACID;

    v_notify c_notify%ROWTYPE;

BEGIN
    -- BUG 4355208 WF_INVALID_ROLE  moved here from loop below.
    -- make and set role name we will always generate a role even for one user.
    rolename := zpb_wf_ntf.MakeRoleName(ACID, instanceID, OwnerID);
    zpb_wf_ntf.SetRole(rolename, relative);
    -- end BUG 4355208

     for  v_notify in c_notify loop

           thisRecipID := v_notify.user_id;
           -- convert ID to username
           thisRecipient:= zpb_wf_ntf.ID_to_FNDUser(thisrecipID);

           if zpb_wf_ntf.user_in_role(rolename, thisRecipient) = 'N'  then
              ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisRecipient);
                -- DBMS_OUTPUT.PUT_LINE('name set2: ' ||   thisRecipient);
           end if;

          -- add in shadow if there is one
          -- thisUserID := zpb_wf_ntf.fnduser_to_ID(thisRecipient);
          zpb_wf_ntf.add_Shadow(rolename, thisRecipID);

     end loop;

    -- add BP owner as recipient also
    thisRecipient := zpb_wf_ntf.ID_to_FNDUser(OwnerID);

    if zpb_wf_ntf.user_in_role(rolename, thisRecipient) = 'N'  then
       ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisRecipient);
       zpb_wf_ntf.add_Shadow(rolename, OwnerID);
       -- DBMS_OUTPUT.PUT_LINE('owner name set: ' ||   thisRecipient);
    end if;

    -- BUG 4355208 WF_INVALID_ROLE add in caller if not already there.
    -- BUG 4407850 06/02/2005 NTF NOT SENT TO CALLER changed ATTRNumber to ATTRTEXT
    thisRecipient := wf_engine.GetItemAttrText(Itemtype => ItemType,
                      Itemkey => ItemKey, aname => 'FNDUSERNAM');

    if zpb_wf_ntf.user_in_role(rolename, thisRecipient) = 'N'  then
        ZPB_UTIL_PVT.AddUsersToAdHocRole(rolename, thisRecipient);
    end if;

   -- end BUG 4355208

    wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => ItemKey,
            aname => 'EPBPERFORMER',

            avalue => RoleName);

   return;

  exception
   when others then
     raise;

end SET_AUTHORIZED_USERS;


end ZPB_WF_EVENT;


/
