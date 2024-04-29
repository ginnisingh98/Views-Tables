--------------------------------------------------------
--  DDL for Package Body ZPB_WF_ERROR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_WF_ERROR" AS
/* $Header: zpbwferror.plb 120.5 2007/12/04 16:22:19 mbhat noship $  */


-- ======================================================================
-- Procedure
--     SET_ERROR
-- Purpose
--     This gets called when an exception is raised to an EPB WF process.
--     It gets WF itemkey information for the WF item that just errored and then
--     it uses this to get more BP data and send notifications to BP owner.
--     It will also set the BP run and task status to ERROR if it can.
--     Called by EPB WF error process: ZPB_WFERR as a wf activity.
-- History
--     abudnik  10/27/2005    Created
-- Arguments
--     standard WF arguments. procuedure is called by WF activity.
-- ======================================================================

PROCEDURE SET_ERROR(itemtype in VARCHAR2,
                    itemkey  in VARCHAR2,
                    actid    in NUMBER,
                    funcmode in VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2)
IS


l_error_item_type varchar2(8);
l_error_item_key  varchar2(240);
l_ACNAME          varchar2(150);
l_ACID            NUMBER;
l_TASKID          NUMBER;
l_TASKNAME        varchar2(140);
l_INSTANCEID      NUMBER;
l_INSTANCEDESC    varchar2(140);
l_BUSINESSAREA    varchar2(140);
l_BUSINESSAREAID    number;
l_requestid       number;
l_req_status      varchar2(1);
l_ERRMSG          varchar2(240);
l_reqlog          varchar2(240);

-- bug 5251227
l_ownerID         NUMBER;
l_RoleName varchar2(320);
l_thisRecipient varchar2(100);
l_label varchar2(50);
l_NewDispName varchar2(360);

BEGIN


 resultout :='ERROR';

 IF (funcmode = 'RUN') THEN

    resultout :='COMPLETE';
    --
    -- Get the type and the key of the process that errored out
    -- these were set in the erroring out process by Execute_Error_Process
    --Error Item Type  EPBCYCLE
    --Error Item Key  bp-15082-2-MANAGE_SUBMISSION-09/04/2005
    --


       l_error_item_key := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_ITEM_KEY' );
       l_error_item_type := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_ITEM_TYPE' );


    --
    -- Get details of the process that errored out using above l_error_item_key
    -- these were set in the erroring out process by Execute_Error_Process


       l_ACNAME := WF_ENGINE.GetItemAttrText(
                                itemtype        => l_error_item_type,
                                itemkey         => l_error_item_key,
                                aname           => 'ACNAME');
       l_ACID := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => l_error_item_type,
                                itemkey         => l_error_item_key,
                                aname           => 'ACID');

       l_TASKID := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => l_error_item_type,
                                itemkey         => l_error_item_key,
                                aname           => 'TASKID');
       l_TASKNAME := WF_ENGINE.GetItemAttrText(
                                itemtype        => l_error_item_type,
                                itemkey         => l_error_item_key,
                                aname           => 'TASKNAME');
       l_INSTANCEID := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => l_error_item_type,
                                itemkey         => l_error_item_key,
                                aname           => 'INSTANCEID');
       l_INSTANCEDESC := WF_ENGINE.GetItemAttrText(
                                itemtype        => l_error_item_type,
                                itemkey         => l_error_item_key,
                                aname           => 'INSTANCEDESC');
       l_BUSINESSAREAID := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => l_error_item_type,
                                itemkey         => l_error_item_key,
                                aname           => 'BUSINESSAREAID');

       --  bug 5251227
       l_OWNERID := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => l_error_item_type,
                                itemkey         => l_error_item_key,
                                aname           => 'OWNERID');



      -- set business area info if we have it
      if l_BUSINESSAREAID > 0 then

          -- get business area display name
          select NAME into l_BUSINESSAREA
           from zpb_business_areas_vl
           where BUSINESS_AREA_ID = l_BUSINESSAREAID;

          -- SET business area display name to BUSINESSAREA in notification
          wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'BUSINESSAREA',
                           avalue => l_BUSINESSAREA);
       end if;


    -- add shadows for owner b5251227 FOR ERROR MESSAGE=====================

    l_thisRecipient := zpb_wf_ntf.ID_to_FNDUser(l_OWNERID);

    if zpb_wf_ntf.has_Shadow(l_OWNERID) = 'Y' then
      l_rolename := zpb_wf_ntf.MakeRoleName(l_INSTANCEID, l_TASKID);

      select distinct display_name
       into l_NewDispName
       from wf_users
       where name = l_thisRecipient;

      -- add (And Shadows) display to role dispaly name
      FND_MESSAGE.SET_NAME ('ZPB', 'ZPB_NTF_ANDSHADOWS');
      l_label := FND_MESSAGE.GET;
      l_NewDispName := l_NewDispName || l_label;
      zpb_wf_ntf.SetRole(l_rolename, 7, l_NewDispName);

      ZPB_UTIL_PVT.AddUsersToAdHocRole(l_rolename, l_thisRecipient);
      zpb_wf_ntf.add_Shadow(l_rolename, l_OWNERID);
    else
      l_rolename := l_thisRecipient;
    end if;

    if l_rolename is not null then

        wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => ItemKey,
            aname => 'WF_ADMINISTRATOR',
            avalue => l_rolename);
     end if;

  -- end b5251227 ====================================================


    -- Set attribures for NOTIFICATION if itemtype is ZPBWFERR only.
    -- for EPBCYCLE or ZPBSCHED these are already set.

       -- BP Name
       wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'ACNAME',
                           avalue => l_ACNAME);

       --ACID
       wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'ACID',
                           avalue => l_ACID);

       --TASKID
       wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'TASKID',
                           avalue => l_TASKID);
       --TASKNAME
       wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'TASKNAME',
                           avalue => l_TASKNAME);

       wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'INSTANCEID',
                           avalue => l_INSTANCEID);

       wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'INSTANCEDESC',
                           avalue => l_INSTANCEDESC);


       wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'BUSINESSAREAID',
                           avalue => l_BUSINESSAREAID);




    -- 1 if have taskID then set error status for it.
    if l_TASKID is NOT NULL  then

     update zpb_analysis_cycle_tasks
       set status_code = 'ERROR',
         LAST_UPDATED_BY =  fnd_global.USER_ID,
         LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       where task_id = l_TaskID;

    end if;

    -- 2 if have instance ID set BP run status to error.
    if l_instanceID is NOT NULL then

      update zpb_ANALYSIS_CYCLES
       set status_code = 'ERROR',
       LAST_UPDATED_BY =  fnd_global.USER_ID,
       LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       where ANALYSIS_CYCLE_ID = l_InstanceID;

      update zpb_analysis_cycle_instances
       set last_update_date = sysdate,
       LAST_UPDATED_BY =  fnd_global.USER_ID,
       LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       where instance_ac_id = l_InstanceID;

    else
       -- return 'NOINFO';
       return;
    end if;

END IF;


return;


exception
  when others then

    Wf_Core.Context('ZPB_WF_ERROR', 'SET_ERROR', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;

END SET_ERROR;


-- ======================================================================
-- Procedure
--     SET_CONC_ERROR
-- Purpose
--     Based on the return code ACTIVITY_RESULT_CODE of the concurrent program
--     being run by WF it gets BP data and Conc request data abd sends
--     a notification to BP owner. It will also set the BP run and task status
--     to ERROR if it can.
-- History
--     abudnik  10/27/2005    Created
-- Arguments
--     standard WF arguments. procuedure is called by WF activity.
-- ======================================================================


PROCEDURE SET_CONC_ERROR(itemtype in VARCHAR2,
                    itemkey  in VARCHAR2,
                    actid    in NUMBER,
                    funcmode in VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2)
IS


l_error_item_type varchar2(8);
l_error_item_key  varchar2(240);
l_ACNAME          varchar2(150);
l_ACID            NUMBER;
l_TASKID          NUMBER;
l_TASKNAME        varchar2(140);
l_INSTANCEID      NUMBER;
l_INSTANCEDESC    varchar2(140);
l_BUSINESSAREA    varchar2(140);
l_BUSINESSAREAID    number;
l_ownerID         NUMBER;
l_appID           NUMBER;
l_result_code     varchar2(12);
l_reqlog          varchar2(255);
l_req_status      varchar2(30);
l_req_resultDisp  varchar2(30);
l_concprgID       number;
l_ConcName        varchar2(240);
l_count           number;

l_request_id number;
l_req_by   number;
-- bug 5251227
l_RoleName varchar2(320);
l_thisRecipient varchar2(100);
l_label varchar2(50);
l_NewDispName varchar2(360);



BEGIN


 resultout :='ERROR';

 IF (funcmode = 'RUN') THEN

    resultout :='COMPLETE';
    --
    -- Get details of the process that errored out using above itemkey
    -- these were set in the erroring out process by Execute_Error_Process



       l_TASKID := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'TASKID');

       l_INSTANCEID := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'INSTANCEID');


       l_OWNERID := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'OWNERID');

       l_APPID := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'RESPAPPID');

       l_BUSINESSAREAID := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'BUSINESSAREAID');

      -- set Business Area info if we have it
      if l_BUSINESSAREAID > 0 then

          -- get business area display name
          select NAME into l_BUSINESSAREA
           from zpb_business_areas_vl
           where BUSINESS_AREA_ID = l_BUSINESSAREAID;


           -- set business area display name
          wf_engine.SetItemAttrText(Itemtype => ItemType,
            Itemkey => ItemKey,
            aname => 'BUSINESSAREA',
            avalue => l_BUSINESSAREA);


       end if;



      -- check on the value of ACTIVITY_RESULT_CODE
      select DISTINCT ACTIVITY_RESULT_CODE, ACTIVITY_RESULT_DISPLAY_NAME
         into l_result_code, l_req_resultDisp
         from wf_item_activity_statuses_v
         where item_type= itemtype
         and item_key= itemkey
         and ACTIVITY_RESULT_CODE
         in ('ERROR', 'CANCELLED', 'TERMINATED', 'WARNING');


      if l_result_code in ('ERROR', 'CANCELLED', 'TERMINATED', 'WARNING') then

         dbms_lock.sleep(5);
         l_request_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'REQUEST_ID');

       --DBMS_OUTPUT.PUT_LINE('request_id: ' || l_request_id);
       -- should only be one entry. This should be 1 or there is
       -- something very wrong.
       SELECT COUNT(r.STATUS_CODE)
          INTO l_count
          FROM Fnd_Concurrent_Requests r
               WHERE r.REQUEST_ID = l_request_id
          and r.PROGRAM_APPLICATION_ID = l_appID
          and r.REQUESTED_BY = l_ownerID;

        if l_count = 1 then

         SELECT distinct R.STATUS_CODE, R.LOGFILE_NAME, CONCURRENT_PROGRAM_ID
            into l_req_status, l_reqlog, l_concprgID
          FROM Fnd_Concurrent_Requests r
               WHERE r.REQUEST_ID = l_request_id
          and r.PROGRAM_APPLICATION_ID = l_appID
          and r.REQUESTED_BY = l_ownerID;

         -- get concurrent program name
         select USER_CONCURRENT_PROGRAM_NAME
          into l_ConcName
          from fnd_concurrent_programs_vl
          where APPLICATION_ID  = 210
          and CONCURRENT_PROGRAM_ID = l_concprgID;

         wf_engine.SetItemAttrText(Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'REGISTER1',
               avalue => l_ConcName);

         wf_engine.SetItemAttrText(Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'MSGHISTORY',
               avalue => l_reqlog);

         wf_engine.SetItemAttrText(Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'ISSUEMSG',
               avalue => l_req_resultDisp);

       else

         wf_engine.SetItemAttrText(Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'ISSUEMSG',
               avalue => to_char(l_count));

       end if;

    end if;

    -- add shadows for owner b5251227 =============================
    -- This will use the BP owner ID to find shadows and set the
    -- role "EPBPERFORMER" with shadows, if there are shadows.

      zpb_wf_ntf.SHADOWS_FOR_EPBPERFORMER(ItemType,
                                          ItemKey,
                                           0,
                                          'EPB_BPOWNERID',
                                          resultout);

    -- end b5251227 ====================================================


    -- if have taskID then set error status for it.
    if l_TASKID is NOT NULL  then

     update zpb_analysis_cycle_tasks
       set status_code = 'ERROR',
         LAST_UPDATED_BY =  fnd_global.USER_ID,
         LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       where task_id = l_TaskID;

    end if;

    -- if have instance ID set BP run status to error.
    if l_instanceID is NOT NULL then

      update zpb_ANALYSIS_CYCLES
       set status_code = 'ERROR',
       LAST_UPDATED_BY =  fnd_global.USER_ID,
       LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       where ANALYSIS_CYCLE_ID = l_InstanceID;

      update zpb_analysis_cycle_instances
       set last_update_date = sysdate,
       LAST_UPDATED_BY =  fnd_global.USER_ID,
       LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       where instance_ac_id = l_InstanceID;

    else
       -- return 'NOINFO';
       return;
    end if;

END IF;


return;



exception
  when others then
    Wf_Core.Context('ZPB_WF_ERROR', 'SET_conc_ERROR', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;

END SET_CONC_ERROR;



END ZPB_WF_ERROR;

/
