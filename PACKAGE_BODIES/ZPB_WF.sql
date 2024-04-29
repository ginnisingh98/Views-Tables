--------------------------------------------------------
--  DDL for Package Body ZPB_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_WF" AS
/* $Header: zpbwrkfl.plb 120.18 2007/12/04 16:24:57 mbhat ship $ */


 Owner     varchar2(30);
 g_owner varchar2(50) := ' ';
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'ZPB_WF';

/*+=========================================================================+
  | ACStart
  |
  | Start a specific AC schedule FROM UI with a Wait. Pause until start date + run
  | MakeInstance to start new instance.
  |
  | Notes:
  |  1. Manages context for WF.
  |  2. Reads ZPB_AC schema to get AC info.
  |  3. Starts WF scheduler.
  |  4. Submits Concurrent program to manges Workflow Background Engine for
  |     WAIT activities that could pause for days.
  |
  | IN
  | ACID                    A valid ID from zpb_ac
  | PublishedBefore         If Y then check to see if we should abort and restart.
  +========================================================================+
*/
procedure ACStart(ACID in number, PublishedBefore in varchar2, isEvent in varchar2 default 'N')

   IS

   ACname       varchar2(300);
   -- 04/23/03 AGB ZPBSCHED
   itemtype     varchar2(8) := 'ZPBSCHED';
   workflowProcess varchar2(30);
   itemkey            varchar2(240);
   TaskID  number;
   ParamID number;
   ACstatusID number;
   ACstatusCode varchar2(30);
   WaitMode varchar2(24);
   StartDateTxt varchar(100);
   StartDateDt  date;
   charDate varchar2(30);
   owner varchar2(30) := fnd_global.user_name;
   ownerID      number := fnd_global.USER_ID;
   respNam varchar2(80) := fnd_global.RESP_NAME;
   respID number := fnd_global.RESP_ID;
   --Bug 5223405: Change start
   --appNam varchar2(3) := fnd_global.APPLICATION_SHORT_NAME;
   appName FND_APPLICATION.APPLICATION_SHORT_NAME%type := fnd_global.APPLICATION_SHORT_NAME;
   --Bug 5223405: Change end
   respAppID number := fnd_global.RESP_APPL_ID;
   EngItemKey     varchar2(200);
   errbuf varchar2(80);
   bkgREQID number;
   InstanceCount number;
   WfRetcode number;
   retcode number;
   rphase varchar2(30);
   rstatus varchar2(30);
   dphase  varchar2(30);
   dstatus varchar2(30);
   message varchar2(240);
   call_status boolean;
   request_id number;
   freqType varchar2(30);
   schedProfileOption varchar2(80);
   l_business_area_id  number;  -- abudnik 17NOV2005 BUSINESS AREA ID

 BEGIN

 errbuf := ' ';

If PublishedBefore = 'Y' and isEvent = 'N' then

       CallWFAbort(ACID);

        -- Ignore this code for now AGB 02/20/2004
        -- In future will need to remap instances
          retcode := 1;
end if;


-- Get status and name of AC
--
-- AGB 11/07/2003 Publish change
select STATUS_CODE, NAME, PUBLISHED_BY
into ACstatusCode, ACname, OwnerID
from zpb_analysis_cycles
where ANALYSIS_CYCLE_ID = ACID;
Owner := ZPB_WF_NTF.ID_to_FNDUser(OwnerID);


-- Get start date for WF WAIT
select TAG as PARAM_ID
into paramID
from FND_LOOKUP_VALUES_VL WHERE LOOKUP_CODE = 'CALENDAR_START_DATE'
and LOOKUP_TYPE = 'ZPB_PARAMS';

select value
Into StartDateTxt
from ZPB_AC_PARAM_VALUES
where ANALYSIS_CYCLE_ID = ACID and PARAM_ID = paramID;

StartDateDt := to_date(StartDateTxt, 'YYYY/MM/DD-HH24:MI:SS');

/*
If Sysdate is passed the StartDate, set the StartDate to
the Sysdate plus one day at midnight.  This ensures that no instances
are kicked off during re-publish.  The exception is BPs that have
their calendar frequency set to either ONE_TIME_ONLY or EVENT.
*/


begin

select pva.value into freqType
from zpb_ac_param_values pva,
     fnd_lookup_values_vl pna
where pna.lookup_code='CALENDAR_FREQUENCY_TYPE'
      and pna.tag = pva.param_id and
      pna.lookup_type = 'ZPB_PARAMS' and
      pva.analysis_cycle_id=ACID;

exception
     when NO_DATA_FOUND then
            freqType:='NOT_FOUND';
end;


if freqType = 'EXTERNAL_EVENT' then
    return;
end if;


schedProfileOption:=  FND_PROFILE.VALUE_SPECIFIC('ZPB_BPSCHEDULER_TYPE', OwnerId);

-- BUG 4291814 - WORKFLOW COMPONENTS: START BP EXTERNALLY
if schedProfileOption<>'DEBUG' then

         if freqType <> 'EVENT' and freqType <> 'ONE_TIME_ONLY' and sysdate > StartDateDt then

                StartDateDt := trunc(sysdate+1);

        end if;


end if; -- profile option



-- Start the Workflow Process
if isEvent = 'Y' then
   WorkflowProcess := 'ACIDEVENT';
else
   WorkflowProcess := 'SCHEDULER';
end if;

-- abudnik 17NOV2005 BUSINESS AREA ID.
select BUSINESS_AREA_ID
     into l_business_area_id
     from ZPB_ANALYSIS_CYCLES
     where ANALYSIS_CYCLE_ID = ACId;

-- create itemkey for workflow
charDate := to_char(sysdate, 'MM/DD/YYYY-HH24-MI-SS');
itemkey := rtrim(substr(ACName, 1, 50), ' ') || '-' || to_char(ACID) || '-0-' || workflowprocess || '-' || charDate ;

-- Create WF start process instance
    wf_engine.CreateProcess(ItemType => ItemType,
                         itemKey => ItemKey,
                         process => WorkflowProcess);

-- abudnik 17NOV2005 BUSINESS AREA ID.
-- set Bus Area ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'BUSINESSAREAID',
                           avalue => l_business_area_id);


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
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'ACID',
                           avalue => ACID);
-- set cycle Name!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'ACNAME',
                           avalue => ACNAME);

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

  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'FNDUSERNAM',
                           avalue => owner);

  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'OWNERID',
                           avalue => ownerID);

  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'RESPID',
                           avalue => respID);

  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'RESPAPPID',
                           avalue => respAppID);

-- end global stuff


  wf_engine.SetItemAttrDate(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'ABSOLUTE_START_DATE',
                                   avalue => StartDateDt);

-- if calendar frequency is yearly and we have reset the startDate
-- make sure that an instance is not immediately created once
-- modified start date is reached.  Get flag here set wf attribute below

if freqType='YEARLY' and sysdate<StartDateDt then

            wf_engine.SetItemAttrText(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'FREQBEHAVIOR',
                                   avalue => 'YEARLYRESET');

end if;


-- Now that all is created and set: START the PROCESS!

   wf_engine.StartProcess(ItemType => ItemType,
                          ItemKey => ItemKey);
--   commit;

/*+======================================================================+
  -- abudnik b 4725904 COMMENTING OUT OUR USE OF ZPB BACKGROUND ENGINES.
  -- THIS WILL NOW BE DONE BY STANDARD WORKFLOW via OAM

   -- WF BACKGROUND ENGINE TO RUN deferred activities like WAIT.
   call_status := FND_CONCURRENT.GET_REQUEST_STATUS(request_id, 'ZPB', 'ZPB_WFBKGMGR', rphase,rstatus,dphase,dstatus, message);

   if call_status = TRUE then
      if dphase <> 'RUNNING' then
         bkgREQID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_WFBKGMGR', NULL, NULL, FALSE, Itemtype, itemkey );
         wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'BKGREQID',
                           avalue => bkgREQID);
       end if;
   else
         bkgREQID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_WFBKGMGR', NULL, NULL, FALSE, Itemtype, itemkey );
         wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'BKGREQID',
                           avalue => bkgREQID);
   end if;

  +======================================================================+*/

--  commit;
  return;

  exception
     when NO_DATA_FOUND then
            Null;
     when others then
      errbuf:=substr(sqlerrm, 1, 255);
      raise;

end ACStart;


/*+=================================================================+
  | RUN the next task in the AC that is currently running
  +=================================================================+*/

procedure RunNextTask (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2)
   IS

-- NOTE: all values are for the WF that is ending need new values set for the
-- process to be started.

    CurrtaskSeq number;
    ACID number;
    ACNAME varchar2(300);
    ACstatusCode varchar2(30);
    InstatusCode varchar2(30);
    TaskID number;
    priorTaskID number;
    owner  varchar2(30);
    ownerID number;
    respID number;
    respAppID number;
    charDate varchar2(30);
    newitemkey varchar2(240);
    workflowprocess varchar2(30);
    TaskName varchar2(256);
    bkgREQID number;
    InstanceID number;
    Marked varchar2(16);
    l_REQID number;
    retcode number;
    rphase varchar2(30);
    rstatus varchar2(30);
    dphase  varchar2(30);
    dstatus varchar2(30);
    message varchar2(240);
    call_status boolean;
    request_id number;
    l_migration varchar2(4000);
    usr_paused_BP_Name varchar2(30);
    usr_paused_BP_ID number;
    l_business_area_id  number;   -- abudnik 17NOV2005 BUSINESS AREA ID
    l_business_area varchar2(60); -- A. Budnik 04/12/2006  bugs 3126256, 3856551 and others
    l_InstanceDesc varchar2(300); -- A. Budnik 04/12/2006  bugs 3126256, 3856551 and others

    CURSOR c_tasks is
      select *
      from zpb_analysis_cycle_tasks
      where ANALYSIS_CYCLE_ID = InstanceID
      and Sequence = CurrtaskSeq+1;
    v_tasks c_Tasks%ROWTYPE;


    -- 28 MIGRATION_INSTANCE
    CURSOR c_mparams is
      select value
      from ZPB_AC_PARAM_VALUES
      where ANALYSIS_CYCLE_ID = InstanceID and PARAM_ID = 28;

    v_mparams c_mparams%ROWTYPE;



   BEGIN

   IF (funcmode = 'RUN') THEN
       -- Default is do not RUN NEXT TASK. Must have adequate values to run next task.
       resultout :='COMPLETE:N';

       -- Get current global attributes to run next WF task!
       CurrtaskSeq := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'TASKSEQ');
       ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'ACID');
       ACNAME := wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'ACNAME');
       ownerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'OWNERID');
       respID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPID');
       respAppID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPAPPID');
       owner := wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'FNDUSERNAM');
       InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'INSTANCEID');
       l_InstanceDesc := wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'INSTANCEDESC');
       PriorTaskID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'TASKID');

       -- abudnik 17NOV2005 BUSINESS AREA ID.
       l_business_area_id := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'BUSINESSAREAID');
       l_business_area  := wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'BUSINESSAREA');




    -- agb DISABLE 07/16/2003
    select STATUS_CODE
    into ACstatusCode
    from ZPB_ANALYSIS_CYCLES
    where ANALYSIS_CYCLE_ID = ACID;


    /*  agb DISABLE 07/16/2003
    select STATUS_CODE
    into ACstatusCode
    from ZPB_PUBLISHED_CYCLES_V
    where ANALYSIS_CYCLE_ID = ACID;
    */

    --  First set prior task to complete - one that just finished.
       update zpb_analysis_cycle_tasks
       set status_code = 'COMPLETE',
       LAST_UPDATED_BY =  fnd_global.USER_ID,
       LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       where ANALYSIS_CYCLE_ID = InstanceID and TASK_ID = priorTaskID;

    --  Get next task [wf process] to run - if NONE you are COMPLETE!
    workflowprocess := 'NONE';
    TaskID := NULL;

    for  v_Tasks in c_Tasks loop
         TaskID := v_Tasks.TASK_ID;
         workflowprocess := v_Tasks.wf_process_name;
         taskName := v_Tasks.task_name;
    end loop;

    select STATUS_CODE
    into InstatusCode
    from ZPB_ANALYSIS_CYCLES
    where ANALYSIS_CYCLE_ID = InstanceID;

    -- If instance is marked for deletion do not mark it as complete
    -- Clean up the instance measures and quit
    if InstatusCode = 'MARKED_FOR_DELETION' then
        l_REQID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_WF_DELAWINST', NULL, NULL, FALSE, InstanceID, ownerID, l_business_area_id);

        -- Clean up Current Instance Measure if Appropriate
        DeleteCurrInstMeas(ACID, ownerID);

        resultout :='COMPLETE:N';
        return;
    end if;

    -- LAST TASK FOR THIS INSTANCE
    if workflowprocess = 'NONE' then

       update zpb_ANALYSIS_CYCLES
       set status_code = 'COMPLETE',
        LAST_UPDATED_BY =  fnd_global.USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
        where ANALYSIS_CYCLE_ID = INSTANCEID;

       update zpb_analysis_cycle_instances
       set LAST_UPDATED_BY =  fnd_global.USER_ID,
                LAST_UPDATE_DATE = SYSDATE, LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       where instance_ac_id = INSTANCEID;

       l_migration := 'N';
       for  v_mparams in c_mparams loop
          l_migration := v_mparams.VALUE;
       end loop;

       if l_migration = 'N' then
         -- Mark for delete
         zpb_wf.markfordelete(ACID, ownerID, respID, respAppID);
        end if;

       resultout :='COMPLETE:RUN_COMPLETE';
       return;
    end if;

    -- IF PAUSED or PAUSING EXIT.

    if (InstatusCode = 'PAUSED') THEN
      resultout :='COMPLETE:PAUSED';
      return;
      elsif (InstatusCode = 'PAUSING') THEN
             select LAST_UPDATED_BY into usr_paused_BP_ID
             from zpb_ANALYSIS_CYCLES where ANALYSIS_CYCLE_ID = INSTANCEID;

             update zpb_ANALYSIS_CYCLES
             set status_code = 'PAUSED',
                 LAST_UPDATED_BY =  fnd_global.USER_ID,
                 LAST_UPDATE_DATE = SYSDATE, LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
             where ANALYSIS_CYCLE_ID = INSTANCEID;

             update zpb_analysis_cycle_instances
             set LAST_UPDATED_BY =  fnd_global.USER_ID,
                 LAST_UPDATE_DATE = SYSDATE, LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
             where instance_ac_id = INSTANCEID;

             select user_name into usr_paused_BP_Name from
             FND_USER where user_id = usr_paused_BP_ID;

             resultout :='COMPLETE:PAUSED';
             wf_engine.SetItemAttrText(
                   Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => '#FROM_ROLE',
               avalue => usr_paused_BP_Name);

             return;
      elsif (InstatusCode = 'DISABLE_ASAP') then
       resultout :='COMPLETE:N';
       return;
      elsif (InstatusCode = 'ENABLE_FIRST') then
       -- if this instance has been marked for enable first, we submit a CM
       -- that will clean its previous measure out, and restart from Task 1
       l_REQID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_CLEANANDRESTARTINST', NULL, NULL, FALSE, ACID, InstanceID, l_business_area_id);
       resultout :='COMPLETE:N';
       return;

    end if;

    -- A. Budnik 08/26/04   B: 3856388 Migration and disable_asap
    -- Do not run if DISABLED!
    if ACstatusCode = 'DISABLE_ASAP' and  l_migration = 'N' then
       resultout :='COMPLETE:N';
       return;
    end if;


  -- Set item key and date
  charDate := to_char(sysdate, 'MM/DD/YYYY-HH24-MI-SS');
  newitemkey := rtrim(substr(ACName, 1, 50), ' ') || '-' || to_char(ACID) || '-' || to_char(CurrtaskSeq+1) || '-' || workflowprocess || '-' || charDate;


-- +============================================================+
-- +============================================================+
-- set newItemKey for submit engine mgr proc IN CURRENT PROCESS!
-- This will have the bkg engine pushing the new task through.
-- +============================================================+
    wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'ARG2',
                           avalue => newItemKey);
-- +============================================================+

-- Create WF start process instance
   wf_engine.CreateProcess(ItemType => ItemType,
                         itemKey => newItemKey,
                         process => WorkflowProcess);

-- This should be the EPB controller.
   wf_engine.SetItemOwner(ItemType => ItemType,
                           ItemKey => NEWItemKey,
                           owner => owner);

-- Set current value of Taskseq [not sure if it is always 1 might be for startup]
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'TASKSEQ',
                           avalue => CurrtaskSeq+1);

-- +============================================================+
-- set globals for new key

-- abudnik 17NOV2005 BUSINESS AREA ID.
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'BUSINESSAREAID',
                           avalue => l_business_area_id);

  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'BUSINESSAREA',
                           avalue => l_business_area);

-- set Cycle ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'ACID',
                           avalue => ACID);

-- set workflow with Instance Cycle ID!
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'INSTANCEID',
                           avalue => InstanceID);

   wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'INSTANCEDESC',
                           avalue => l_InstanceDesc);

-- set cycle Name!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'ACNAME',
                           avalue => ACNAME);
-- set Task ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'TASKID',
                           avalue => TaskID);
-- set Task Name!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'TASKNAME',
                           avalue => TaskName);

-- set owner name attr!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'FNDUSERNAM',
                           avalue => owner);

-- set EPBPerformer to owner name for notifications DEFAULT!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'EPBPERFORMER',
                           avalue => owner);

-- AGB 11/07/2003 Publish change
-- will get error notifications
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'WF_ADMINISTRATOR',
                           avalue => owner);

-- set owner ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'OWNERID',
                           avalue => ownerID);
-- set resp ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'RESPID',
                           avalue => respID);
-- set resp ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'RESPAPPID',
                           avalue => respAppID);

if workflowprocess = 'EXCEPTION' then
     -- plsql document procedure
     wf_engine.SetItemAttrText(itemtype => itemtype,
                  itemkey  =>  newItemKey,
                  aname    => 'RESPNOTE',
                  avalue   => 'PLSQL:ZPB_EXCEPTION_ALERT.NON_RESPONDERS/' || newItemKey );
end if;

   update zpb_analysis_cycle_tasks
   set item_KEY = newitemkey,
   Start_date = to_Date(charDate,'MM/DD/YYYY-HH24-MI-SS'),
   status_code = 'ACTIVE',
   LAST_UPDATED_BY =  fnd_global.USER_ID,
   LAST_UPDATE_DATE = SYSDATE,
   LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   where ANALYSIS_CYCLE_ID = INSTANCEID and task_id = TaskID;

-- Now that all is created and set START the PROCESS!
   wf_engine.StartProcess(ItemType => ItemType,
                          ItemKey => newItemKey);


/*+======================================================================+
  -- abudnik b 4725904 COMMENTING OUT OUR USE OF ZPB BACKGROUND ENGINES.
  -- THIS WILL NOW BE DONE BY STANDARD WORKFLOW via OAM
   -- WF BACKGROUND ENGINE TO RUN deferred activities like WAIT.
   call_status := FND_CONCURRENT.GET_REQUEST_STATUS(request_id, 'ZPB', 'ZPB_WF_START', rphase,rstatus,dphase,dstatus, message);

   if call_status = TRUE then
      if dphase <> 'RUNNING' then
          resultout :='COMPLETE:Y';
      else
          resultout :='COMPLETE:NOCONC';
      end if;
   else
      resultout :='COMPLETE:Y';
   end if;

  +======================================================================+*/
  -- abudnik b 4725904 this resultout will take path in wf process that will
  -- not run a ZPB background engine.
  resultout :='COMPLETE:NOCONC';

  END IF;
  return;

  exception

   when others then
     -- b5222930 ERROR RAISED IN PROC: RUNNEXTTASK WILL PROVIDE INCORRECT ERROR MESSAGE
     -- when the error is raised here ZPBWFERR will update zpb status
     -- commits can not be done inside WF.
     -- UPDATE_STATUS('ERROR', Instanceid, NULL, NULL);

     WF_CORE.CONTEXT('ZPB_WF.RunNextTask', itemtype, itemkey, to_char(actid), funcmode);
     raise;

end RunNextTask;



-- RunLoad
-- call the load data task for current AC that is running

procedure RunLoad  (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2)
   IS


    CurrtaskSeq number;
    ACID number;
    ACNAME varchar2(300);
    TaskID number;
    retval varchar2(4000);
    ownerID number;
    owner varchar2(30);
    respID number;
    respAppID number;
    sessionID number;
    ACprgtype varchar2(2) := 'AC';
    DLcmd varchar2(100);
    reqID number;
    CodeAW varchar2(30);
    DataAW varchar2(30);
    AnnoAW varchar2(30);
    thisCount  number;
    returnStat varchar2(1000);
    msgData    varchar2(1000);
    l_business_area_id   number; -- abudnik 17NOV2005 BUSINESS AREA ID

   BEGIN

      IF (funcmode = 'RUN') THEN
         resultout :='COMPLETE:N';

       CurrtaskSeq := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'TASKSEQ');

       ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'ACID');

       ACNAME := wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'ACNAME');

       TaskID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'TASKID');

       ownerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'OWNERID');


       respID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPID');

       owner := wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'FNDUSERNAM');

       respAppID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPAPPID');

       -- abudnik 17NOV2005 BUSINESS AREA ID.
       l_business_area_id := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'BUSINESSAREAID');

        -- COMMAND TO RUN ON aw
        -- DLcmd := 'call wf.call.mgr(' || taskID || ');';
        -- 'zpbdata',
        -- 'zpbcode',

 DLcmd := 'call wf.call.mgr(' || taskID || ');';


 ZPB_AW.INITIALIZE_FOR_AC (p_api_version       => 1.0,
                           p_init_msg_list     => FND_API.G_TRUE,
                           x_return_status     => returnStat,
                           x_msg_count         => thisCount,
                           x_msg_data          => msgData,
                           p_analysis_cycle_id => ACID,
                           p_shared_rw         => FND_API.G_FALSE);

 DataAW := ZPB_AW.GET_SHARED_AW;
 CodeAW := ZPB_AW.GET_CODE_AW;
 AnnoAW := ZPB_AW.GET_ANNOTATION_AW;

 -- abudnik 17NOV2005 BUSINESS AREA ID.
 reqID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_WF_TO_AW', NULL, NULL, FALSE, ACID, taskID, dataAW, CodeAW, AnnoAW, l_business_area_id);

  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'REQUEST_ID',
                           avalue => reqID);

    resultout :='COMPLETE:Y';

   END IF;
   return;

  exception
   when others then

     -- b5222930 ERROR RAISED IN PROC: RUNNEXTTASK WILL PROVIDE INCORRECT ERROR MESSAGE
     -- when the error is raised here ZPBWFERR will update zpb status
     -- commits can not be done inside WF.
     -- UPDATE_STATUS('ERROR', NULL, taskid, NULL);

     WF_CORE.CONTEXT('ZPB_WF.RunLoad', itemtype, itemkey, to_char(actid), funcmode);
     raise;

end RunLoad;

/*+=================================================================+
  | Selector
  | ZPB_CONTROLLER_RESP  56073, ZPB 210, USER ID: ownerID
  |
  | This is an ItemType Selector function that contains callback
  | functionality to reestablish context for each process in our
  | ItemType. This is a requierment of the Concurrent Manager
  | Standard Activity to be sure that the context is set up by
  | calling:
  |    fnd_global.apps_initialize(user_id, resp_id, resp_appl_id)
  |
  | IN
  | Set of arguments for Standard Activity Function:
  | itemtype  - A valid item type from WF_ITEM_TYPES table.
  | itemkey   - string generated as WF primary key.
  | actid     - An Activity ID.
  | command   - Oracle Workflow calls selector/callback function with
  |             following commands: 'RUN', 'TEST_CTX'.
  |
  | OUT
  | resultout - A result that can be returned.
  +==================================================================+*/

procedure Selector(itemtype in varchar2,
                         itemkey  in varchar2,
                         actid    in number,
                         command  in varchar2,
                    resultout   out nocopy varchar2)
IS

ownerID     number;
respID      number;
respAppID   number;
l_wfprocess varchar2(30);

BEGIN


select root_activity into l_wfprocess
from wf_items_v
where item_key = ItemKey;


IF (command = 'SET_CTX') THEN

       ownerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'OWNERID');

       respID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPID');

       respAppID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPAPPID');


   if l_wfprocess <> 'CALCSYNCPRC' then
      fnd_global.apps_initialize(ownerID, respID, RespAppId);
   end if;

  resultout := 'COMPLETE';
  return;

 ELSIF(command = 'TEST_CTX') THEN

       ownerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'OWNERID');

       respID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPID');

       respAppID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPAPPID');

      if l_wfprocess <> 'CALCSYNCPRC' then
          fnd_global.apps_initialize(ownerID, respID, RespAppId);
      end if;

      return;

ELSE

 resultout := 'COMPLETE';
 return;

END IF;

exception

   when others then
     WF_CORE.CONTEXT('ZPB_WF.Selector', itemtype, itemkey,
         to_char(actid), command);
     raise;
end Selector;


-- Runs WF_ENGINE.BACKGROUND to monitor and interface with any deffered activities.
-- Currently used for WAIT activites.

procedure WFbkgMgr (errbuf out nocopy varchar2,
                 retcode out nocopy number,
                 itemtype in varchar2,
                 itemkey  in varchar2)
          IS
  status_code varchar2(30);
  seconds number;
  status varchar2(30);
  itemsToProcess number;

     BEGIN
     seconds := 10;
     errbuf := ' ';
     retcode := 0;
     status := 'NONE';

 -- run Background Engine Program in the loop for each Deferred
 -- Activity until no Deferred or notified Activities are found.
 -- Itemtype and Itemkey for future use

  Loop
     -- BUG 4517776 - SELECT ON WF VIEW WITHIN ZPB_WFBKGMGR SLOW
     select count(*)
       into itemsToProcess
       from  wf_items_v v
       WHERE v.ITEM_TYPE = 'ZPBSCHED' AND end_date is NULL
       AND v.item_key in (select t.item_key from  WF_ITEM_ACTIVITY_STATUSES t
       where t.item_type = 'ZPBSCHED' AND t.ACTIVITY_STATUS IN ('DEFERRED', 'NOTIFIED'));

     if itemsToProcess > 0 then
        -- giving it a few second to propigate to AQ tables.
        dbms_lock.sleep(seconds);
        wf_engine.Background(itemtype);
     else
        dbms_lock.sleep(seconds);

        -- One last look before exit
        select count(*)
          into itemsToProcess
          from  wf_items_v v
          WHERE v.ITEM_TYPE = 'ZPBSCHED' AND end_date is NULL
          AND v.item_key in (select t.item_key from  WF_ITEM_ACTIVITY_STATUSES t
          where t.item_type = 'ZPBSCHED' AND t.ACTIVITY_STATUS IN ('DEFERRED', 'NOTIFIED'));

          if itemsToProcess = 0 then
             exit;
          end if;
       end if;

  end loop;

  return;

  exception
     when others then
          retcode := 2;
          errbuf:=substr(sqlerrm, 1, 255);

end WFBkgMgr;


-- Runs WF_ENGINE.BACKGROUND to monitor and interface with concurrent
-- programs.  For WirteBack manager.
-- 04/23/03 agb ZPBSCHED
procedure STARTPRCMGR (errbuf out nocopy varchar2,
                       retcode out nocopy number,
                       TGT_ITEMTYPE in varchar2,
                       TGT_ITEMKEY in varchar2)
    IS

  status_code varchar2(30);
  seconds number;
  status varchar2(30);
  itemsToProcess number;

     BEGIN
     seconds := 10;
     errbuf := ' ';
     retcode := 0;
     status := 'NONE';

 -- run Background Engine Program in the loop for each Deferred
 -- Activity until no Deferred or notified Activities are found.
 -- TGT_ITEMTYPE and TGT_ITEMKEY for future use.

  Loop
        -- BUG 4517776 - SELECT ON WF VIEW WITHIN ZPB_WFBKGMGR SLOW
        select count(*)
          into itemsToProcess
          from wf_items_v v
          WHERE v.ITEM_TYPE = 'EPBCYCLE' AND end_date is NULL
          AND v.item_key in (select t.item_key from  WF_ITEM_ACTIVITY_STATUSES t
          where t.item_type = 'EPBCYCLE' AND t.ACTIVITY_STATUS IN ('DEFERRED', 'NOTIFIED'));

     if itemsToProcess > 0 then
        -- giving it a few second to propigate to AQ tables.
        dbms_lock.sleep(seconds);
        wf_engine.Background(TGT_ITEMTYPE);
     else
        dbms_lock.sleep(seconds);
        -- One last look before exit
        select count(*)
          into itemsToProcess
          from wf_items_v v
          WHERE v.ITEM_TYPE = 'EPBCYCLE' AND end_date is NULL
          AND v.item_key in (select t.item_key from  WF_ITEM_ACTIVITY_STATUSES t
          where t.item_type = 'EPBCYCLE' AND t.ACTIVITY_STATUS IN ('DEFERRED', 'NOTIFIED'));

          if itemsToProcess = 0 then
             exit;
          end if;
       end if;

  end loop;

  return;

  exception
     when others then
          retcode := 2;
          errbuf:=substr(sqlerrm, 1, 255);


end STARTPRCMGR;



-- Purges [deletes] completed and aborts and purges active workflows
-- for the defintion AC_ID or INSTANCE_AC_ID passed in.
-- If ACID is ths argument all of its WF instances will be purged.
-- If INSTANCE_AC_ID is passed in, just that one is purged.
-- 04/23/03 agb ZPBSCHED support for many item types.

procedure DeleteWorkflow (errbuf out nocopy varchar2,
                                retcode out nocopy varchar2,
                        inACID in Number,
                        ACIDType in varchar2 default 'I')
   IS
    --ItemType   varchar2(20);
    AttrName   varchar2(30);
    CurrStatus varchar2(20);
    result     varchar2(100);
    -- agb 01/21/02 added for select below
    -- 04/23/03 agb ZPBSCHED Need to take this further and eliminate item type restriction.
    CURSOR c_ItemKeys is
        select item_type, item_key
           from WF_ITEM_ATTRIBUTE_VALUES
           where (item_type = 'ZPBSCHED' OR item_type = 'EPBCYCLE')
           and   name = AttrName
           and   number_value = inACID;

    v_ItemKey c_ItemKeys%ROWTYPE;

BEGIN

    -- agb 01/21/02 convert to text for some selects
    -- 04/23/03 agb ZPBSCHED
    -- ItemType := 'EPBCYCLE';
    retcode := '0';

   if ACIDType = 'I' then
      AttrName := 'INSTANCEID';
   else
      AttrName := 'ACID';
   end if;

-- Check activity process for current plan
-- 04/23/03 agb ZPBSCHED  support for many item types
    for  v_ItemKey in c_ItemKeys loop

        wf_engine.ItemStatus(v_ItemKey.item_type, v_ItemKey.item_key, currStatus, result);

        if  UPPER(RTRIM(currStatus)) = 'COMPLETE' then
            WF_PURGE.Total(v_ItemKey.item_Type, v_ItemKey.item_key);
        elsif UPPER(RTRIM(currStatus)) = 'ERROR' or UPPER(RTRIM(currStatus)) = 'ACTIVE' then
          WF_ENGINE.AbortProcess(v_ItemKey.item_Type, v_ItemKey.item_key);
            WF_PURGE.Total(v_ItemKey.item_Type, v_ItemKey.item_key);
        elsif UPPER(RTRIM(currStatus)) = 'SUSPENDED' then
            NULL;
        else
           retcode := '2';
           errbuf:='Plan has an ACTIVE process and Workflow cannot be deleted.';
--         exit;
        end if;

      end loop;
      return;

  exception

   when NO_DATA_FOUND then
     retcode :='0';
   when others then
    retcode :='2';
    errbuf:=substr(sqlerrm, 1, 255);
--     raise;

end DeleteWorkflow;


-- Wrapper to call DeleteWorkflow and clean zpb_excp* tables
Procedure CallDelWF(inACID in number, ACIDType in varchar2 default 'I')
  is

  thisInst number;
  retcode  varchar2(2);
  errbuf   varchar2(100);

  CURSOR c_instances is
   select instance_ac_id
   from zpb_analysis_cycle_instances
   where analysis_cycle_id = inACID;

  v_instance c_instances%ROWTYPE;


 BEGIN

 -- find all workflows for this ACID or instance, abort and purge.
 ZPB_WF.DeleteWorkflow(errbuf, retcode, inACID, ACIDType);

 -- The default date setting for exec wf_purge.adhocdirectory is sysdate.
 -- This will purge out any ad hoc roles or users I've generated based on the expiration_date
 -- set in wf_directory.CreateAdHocRole.  This is a standard WF API.
 wf_purge.adhocdirectory;

 -- Delete task rows from zpb_excp_results, zpb_exp_explanations by instance

 if ACIDType = 'I' then
   delete from zpb_excp_results re
    where re.task_id in (select pd.task_id from zpb_process_details_v pd
    where analysis_cycle_id = inACID);
   delete from zpb_excp_explanations ex
    where ex.task_id in (select pd.task_id from zpb_process_details_v pd
    where analysis_cycle_id = inACID);
 else

  for v_instance in c_instances loop
    thisInst :=  v_instance.instance_ac_id;
    delete from zpb_excp_results re
     where re.task_id in (select pd.task_id from zpb_process_details_v pd
     where analysis_cycle_id = thisInst);
    delete from zpb_excp_explanations ex
     where ex.task_id in (select pd.task_id from zpb_process_details_v pd
     where analysis_cycle_id = thisInst);
  end loop;

 end if;

 return;

 exception

   when others then
     RAISE_APPLICATION_ERROR(-20100, 'Error in ZPB_WF.CallDelWF');
end CallDelWF;

--BPEXT
PROCEDURE updateHorizonParams(p_start_mem  IN VARCHAR2
                             ,p_end_mem    IN VARCHAR2
                             ,new_ac_id    IN NUMBER)
is
CURSOR records_cur IS
                       SELECT AcParamValuesEO.VALUE,ParamsEO.lookup_code
                       FROM ZPB_AC_PARAM_VALUES AcParamValuesEO,
                       FND_LOOKUP_VALUES_VL ParamsEO
                       WHERE AcParamValuesEO.PARAM_ID = ParamsEO.TAG and
                       ParamsEO.LOOKUP_TYPE = 'ZPB_PARAMS' and ParamsEO.TAG in (4,5,6,7,8,9,10,11,12,13,14,15,16,17) and AcParamValuesEO.ANALYSIS_CYCLE_ID = new_ac_id;
  opRec                records_cur%ROWTYPE;
  l_tmpVar              varchar2(4000);
  l_retStat varchar2(1);
  l_msgCnt  number;
  l_msgData varchar2(2000);
BEGIN
  IF (p_start_mem IS NOT NULL ) THEN
    UPDATE zpb_ac_param_values SET value = p_start_mem,
        LAST_UPDATED_BY =  fnd_global.USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
WHERE
    analysis_cycle_id = new_ac_id AND param_id =
    ( SELECT tag FROM fnd_lookup_values_vl WHERE lookup_type = 'ZPB_PARAMS' AND
    lookup_code = 'CAL_HS_TIME_MEMBER');
  END IF;

  IF (p_end_mem IS NOT NULL ) THEN
    UPDATE zpb_ac_param_values SET value = p_end_mem,
        LAST_UPDATED_BY =  fnd_global.USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
 WHERE
    analysis_cycle_id = new_ac_id AND param_id =
    ( SELECT tag FROM fnd_lookup_values_vl WHERE lookup_type = 'ZPB_PARAMS' AND
    lookup_code = 'CAL_HE_TIME_MEMBER');
  END IF;
  --the following code adds two more params to zpb_ac_params_values
  -- to store start and end periods for the running BP so as to display
  --the hgrid in the dimensions tab
  l_tmpVar := null;
  l_tmpVar := 'call dl.getstartendnames('''||new_ac_id||''' ''';
  for opRec in records_cur loop
   l_tmpVar := l_tmpVar || opRec.lookup_code || ','||opRec.value ||':';
  end loop;
  l_tmpVar := l_tmpVar || ''' ''FROM_MAKE_INSTANCE'' )';

  zpb_aw.initialize (p_api_version      => 1.0,
                            x_return_status    => l_retStat,
                            x_msg_count        => l_msgCnt,
                            x_msg_data         => l_msgData,
                            p_business_area_id => sys_context('ZPB_CONTEXT', 'business_area_id'),
                            p_shadow_id        => sys_context('ZPB_CONTEXT','user_id'),
                            p_shared_rw        => FND_API.G_FALSE);
  zpb_aw.execute(l_tmpVar);

  return ;
  exception
  when others then
  raise;


END updateHorizonParams;
--BPEXT

procedure MakeInstance (errbuf out nocopy varchar2,
                        retcode out nocopy varchar2,
                        ItemKey in varchar2,
                        ACID in number,
                        p_business_area_id in number)
   IS

    ItemType  varchar2(8) := 'ZPBSCHED';
    InstItemType varchar2(8) := 'EPBCYCLE';
    outInstanceID number;
    CurrtaskSeq number;
    ACNAME varchar2(300);
    ACstatusCode varchar2(30);
    TaskID number;
    taskName varchar2(256);
    owner  varchar2(30);
    ownerID number;
    respID number;
    respAppID number;
    charDate varchar2(30);
    newitemkey varchar2(240);
    workflowprocess varchar2(30);
    bkgREQID number;
    InstanceID number;
    rphase varchar2(30);
    rstatus varchar2(30);
    dphase  varchar2(30);
    dstatus varchar2(30);
    message varchar2(240);
    call_status boolean;
    request_id number;
    overide_start_mem VARCHAR2(240);
    overide_end_mem   VARCHAR2(240);
    l_BUSINESSAREA varchar2(60);   -- A. Budnik 04/12/2006  bugs 3126256, 3856551
    l_InstanceDesc varchar2(300);  -- A. Budnik 04/12/2006  bugs 3126256, 3856551

BEGIN

    select STATUS_CODE
    into ACstatusCode
   -- from ZPB_PUBLISHED_CYCLES_V
    from ZPB_ANALYSIS_CYCLES
    where ANALYSIS_CYCLE_ID = ACID;

    -- Do not run if DISABLED!
    if instr(ACstatusCode, 'DISABLE') > 0 then
       retcode :='0';
       return;
    end if;

    -- Do not run if MARKED_FOR_DELETED!
    if instr(ACstatusCode, 'MARKED_FOR_DELETION') > 0 then
       retcode :='0';
       return;
    end if;

--  Begining the creation of a new Business Process Run
   FND_MESSAGE.SET_NAME('ZPB', 'ZPB_WF_NEW_BP_START');
   FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

-- call ops prg to make new instance
   ZPB_AC_OPS.CREATE_NEW_INSTANCE(ACID, outInstanceID);

-- update the horizon params if they exist
   overide_start_mem :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'OVERIDE_START_MEM',
                       ignore_notfound => true);

   overide_end_mem :=  wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'OVERIDE_END_MEM',
                       ignore_notfound => true);
   updateHorizonParams(overide_start_mem, overide_end_mem, outInstanceID);


-- set workflow with Instance Cycle ID!
-- This will be respective to the Scheduler or and Event Task
      -- GET the correct ITEMTYPE for this run
      select ITEM_TYPE into ItemType from WF_ITEMS_V
      where item_key = ItemKey;

      wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'INSTANCEID',
                           avalue => outInstanceID);

       instanceID := outInstanceID;

       ACNAME := wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'ACNAME');
       ownerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'OWNERID');
       -- AGB 11/07/2003 Publish change
       Owner := ZPB_WF_NTF.ID_to_FNDUser(OwnerID);
       respID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPID');
       respAppID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPAPPID');

-- +=================================================================+
--  Get next task [wf process] to run

     select WF_Process_Name, TASK_ID, TASK_NAME
              into workflowprocess, TaskID, taskName
              from zpb_analysis_cycle_tasks
              where ANALYSIS_CYCLE_ID = InstanceID and Sequence = 1;



-- +=================================================================+

-- b 5170327 intializes the pv_status variable
   ZPB_ERROR_HANDLER.INIT_CONC_REQ_STATUS;

-- currently calls zpb_gen_phys_model.gen_physical_model + in.run.init
   ZPB_WF.INIT_BUSINESS_PROCESS(ACID, outInstanceID, TaskID, ownerID);

-- Set item key and date
  charDate := to_char(sysdate, 'MM/DD/YYYY-HH24-MI-SS');
  newitemkey := rtrim(substr(ACName, 1, 50), ' ') || '-' || to_char(ACID) || '-1-' || workflowprocess || '-' || charDate;

-- +============================================================+
-- set newItemKey for submit engine mgr proc IN CURRENT PROCESS!
    wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'ARG2',
                           avalue => newItemKey);

-- +============================================================+
-- 04/23/03 agb ZPBSCHED support for additional item type
-- Next task New process

-- Create WF start process instance
   wf_engine.CreateProcess(ItemType => InstItemType,
                         itemKey => newItemKey,
                         process => WorkflowProcess);

-- This should be the EPB controller.
   wf_engine.SetItemOwner(ItemType => InstItemType,
                           ItemKey => NEWItemKey,
                           owner => owner);

-- Set current value of Taskseq always 1 for startup
   wf_engine.SetItemAttrNumber(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'TASKSEQ',
                           avalue => 1);

-- set globals for new key
-- set Cycle ID!  Scheduler or Target event ACID ##########################################
  wf_engine.SetItemAttrNumber(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'ACID',
                           avalue => ACID);

--***********************************************************************
-- abudnik 17NOV2005 BUSINESS AREA ID.
  wf_engine.SetItemAttrNumber(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'BUSINESSAREAID',
                           avalue => p_business_area_id);

  -- get business area display name
     select NAME into l_BUSINESSAREA
     from zpb_business_areas_vl
     where BUSINESS_AREA_ID = p_business_area_id;

 -- SET business area display name to BUSINESSAREA in notification
    wf_engine.SetItemAttrText(Itemtype => InstItemType,
       Itemkey => newItemKey,
       aname => 'BUSINESSAREA',
       avalue => l_BUSINESSAREA);


-- set workflow with Instance Cycle ID!
   wf_engine.SetItemAttrNumber(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'INSTANCEID',
                           avalue => InstanceID);

   select INSTANCE_DESCRIPTION
    into l_InstanceDesc
    from zpb_analysis_cycle_instances
    where instance_ac_id = InstanceID;


    wf_engine.SetItemAttrText(Itemtype => InstItemType,
       Itemkey => newItemKey,
       aname => 'INSTANCEDESC',
       avalue => l_InstanceDesc);
--***********************************************************************


-- set cycle Name!
  wf_engine.SetItemAttrText(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'ACNAME',
                           avalue => ACNAME);
-- set Task ID!
  wf_engine.SetItemAttrNumber(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'TASKID',
                           avalue => TaskID);

-- set Task Name!
  wf_engine.SetItemAttrText(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'TASKNAME',
                           avalue => TaskName);

-- set newItemKey for submit engine mgr proc!
  wf_engine.SetItemAttrText(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'ARG2',
                           avalue => newItemKey);

-- set owner name attr!
  wf_engine.SetItemAttrText(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'FNDUSERNAM',
                           avalue => owner);

-- set EPBPerformer to owner name for notifications DEFAULT!
  wf_engine.SetItemAttrText(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'EPBPERFORMER',
                           avalue => owner);

-- will get error notifications
  wf_engine.SetItemAttrText(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'WF_ADMINISTRATOR',
                           avalue => owner);

-- set owner ID!
  wf_engine.SetItemAttrNumber(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'OWNERID',
                           avalue => ownerID);

-- set resp ID!
  wf_engine.SetItemAttrNumber(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'RESPID',
                           avalue => respID);

-- set appresp ID!
  wf_engine.SetItemAttrNumber(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'RESPAPPID',
                           avalue => respAppID);

if workflowprocess = 'EXCEPTION' then
     -- plsql document procedure
     wf_engine.SetItemAttrText(itemtype => InstItemType,
                  itemkey  =>  newItemKey,
                  aname    => 'RESPNOTE',
                  avalue   => 'PLSQL:ZPB_EXCEPTION_ALERT.NON_RESPONDERS/' || newItemKey );
end if;

   update zpb_analysis_cycle_tasks
   set item_KEY = newitemkey,
   Start_date = to_Date(charDate,'MM/DD/YYYY-HH24-MI-SS'),
   status_code = 'ACTIVE',
   LAST_UPDATED_BY =  fnd_global.USER_ID,
   LAST_UPDATE_DATE = SYSDATE,
   LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   where ANALYSIS_CYCLE_ID = InstanceID and task_id = TaskID;

   update zpb_ANALYSIS_CYCLES
   set status_code = 'ACTIVE',
   LAST_UPDATED_BY =  fnd_global.USER_ID,
   LAST_UPDATE_DATE = SYSDATE,
   LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   where ANALYSIS_CYCLE_ID = InstanceID;

   update zpb_analysis_cycle_instances
   set last_update_date = sysdate,
   LAST_UPDATED_BY =  fnd_global.USER_ID,
   LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   where instance_ac_id = INSTANCEID;

-- Now that all is created and set START the PROCESS!
   wf_engine.StartProcess(ItemType => InstItemType,
                          ItemKey => newItemKey);

   commit;


/*+======================================================================+
  -- abudnik b 4725904 COMMENTING OUT OUR USE OF ZPB BACKGROUND ENGINES.
  -- THIS WILL NOW BE DONE BY STANDARD WORKFLOW via OAM

    -- WF BACKGROUND ENGINE TO RUN deferred activities like WAIT.
    call_status := FND_CONCURRENT.GET_REQUEST_STATUS(request_id, 'ZPB', 'ZPB_WF_START', rphase,rstatus,dphase,dstatus, message);

    if call_status = TRUE then
      if dphase <> 'RUNNING' then
         -- WF BACKGROUND ENGINE TO RUN deferred activities like WAIT.
         bkgREQID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_WF_START', NULL, NULL, FALSE, InstItemType, newitemkey );
         wf_engine.SetItemAttrNumber(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'BKGREQID',
                           avalue => bkgREQID);
       end if;
    else
        -- WF BACKGROUND ENGINE TO RUN deferred activities like WAIT.
       bkgREQID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_WF_START', NULL, NULL, FALSE, InstItemType, newitemkey );
       wf_engine.SetItemAttrNumber(Itemtype => InstItemType,
                           Itemkey => newItemKey,
                           aname => 'BKGREQID',
                           avalue => bkgREQID);
    end if;


  +======================================================================+*/


   --  The new Business Process Run has started
   FND_MESSAGE.SET_NAME('ZPB', 'ZPB_WF_NEW_BP_END');
   FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

-- b 5170327 - retcode is an OUT parameter conc program standard - 0=success, 1=warning or 2=error.
-- will have warning if set by AW dml from call to ZPB_WF.INIT_BUSINESS_PROCESS
   retcode := ZPB_ERROR_HANDLER.GET_CONC_REQ_STATUS;

   return;

  exception

   when others then
           retcode :='2';
           errbuf:=substr(sqlerrm, 1, 255);

    -- update zpb instance info with ERROR
    UPDATE_STATUS('ERROR', Instanceid, taskid, NULL);


end MakeInstance;

-- MarkforDelete
procedure MarkforDelete (ACID in Number,
          ownerID in number,
          respID in number,
          RespAppID in number)

  AS

    retValue varchar2(16);
    InstanceID number;
    InstancesToKeep number;
    InstancesToKeepT varchar2(2);
    InstancesToDel varchar2(4000);
    sessionID number;
    DLcmd varchar2(100);
    DataAW varchar2(30);
    ItemType varchar2(8) := 'EPBCYCLE';
    ThisInstace number;
    l_REQID number;
    ItemKey  varchar2(240);
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_business_area_id number;
    l_appended      varchar2(18);


     CURSOR c_instances is
      select instance_ac_id
      from zpb_analysis_cycle_instances
      where zpb_analysis_cycle_instances.ANALYSIS_CYCLE_ID = ACID
      and instance_ac_id = (select ac.ANALYSIS_CYCLE_ID from zpb_ANALYSIS_CYCLES ac
      where ac.ANALYSIS_CYCLE_ID = instance_ac_id and
            ac.status_code in ('COMPLETE','COMPLETE_WITH_WARNING', 'ERROR'))
      order by instance_ac_id DESC;

      v_instances c_instances%ROWTYPE;

     CURSOR c_params is
      select value
      from ZPB_AC_PARAM_VALUES
      where ANALYSIS_CYCLE_ID = ACID and PARAM_ID = 2;

      v_params c_params%ROWTYPE;


   BEGIN

    -- abudnik 17NOV2005 BUSINESS AREA ID.
    select BUSINESS_AREA_ID
      into l_business_area_id
      from ZPB_ANALYSIS_CYCLES
      where ANALYSIS_CYCLE_ID = ACId;

    InstancesToKeep := -1;

    --  2 CALENDAR_VERSIONS_PERSISTED
    for  v_params in c_params loop
       InstancesToKeepT := v_params.value;
       InstancesToKeep := to_number(InstancesToKeepT);
    end loop;

    DataAW := fnd_profile.VALUE_SPECIFIC('ZPB_APPMGR_AW_NAME', ownerID, respID, respAppID);

   -- obsolete instances MARKED_FOR_DELETION
   if InstancesToKeep >= 0 then

    for  v_instances in c_instances loop

       if c_instances%ROWCOUNT > InstancesToKEEP then
          -- update delete flag

          InstanceID := v_instances.instance_ac_id;

          update zpb_ANALYSIS_CYCLES
          set status_code = 'MARKED_FOR_DELETION',
            LAST_UPDATED_BY =  fnd_global.USER_ID,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
          where ANALYSIS_CYCLE_ID = InstanceID;

          update zpb_analysis_cycle_instances
          set last_update_date = sysdate,
            LAST_UPDATED_BY =  fnd_global.USER_ID,
            LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
          where instance_ac_id = INSTANCEID;

          -- now delete any Data Collection templates
          -- associated with this cycle
          zpb_dc_objects_pvt.delete_template(
          1.0, FND_API.G_TRUE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL,
          l_return_status, l_msg_count, l_msg_data, InstanceID);


          -- b5007895
          begin

           select value
            into l_appended
            from ZPB_AC_PARAM_VALUES
            where ANALYSIS_CYCLE_ID = ACID and PARAM_ID = 26;
           exception
             when NO_DATA_FOUND then
                l_appended := 'PARM_NOT_FOUND';
           end;


         -- 03/07/2004 agb new instance delete
         if rtrim(l_appended, ' ') = 'DO_NOT_APPEND_VIEW' then
           -- zpb_build_metadata.remove_instance(DataAW, InstanceID);
           l_REQID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_WF_DELAWINST', NULL, NULL, FALSE, instanceid, ownerID, l_business_area_id);
          end if;

         retValue := 'MARKED';
       end if;

    retValue := 'NONE_MARKED';
    end loop;
  else
  retValue := 'PARM_NOT_FOUND';
  end if;

  return;
  exception
   when others then
     raise;

end MarkforDelete;

/*+=========================================================================+
  | private function SET_MONTHLY_LIST
  |
  | This function takes in a list of days of the month and finds
  | the day that is closest in the future to the current day
  | It assumes that the passed in list is chronologically sorted
  |
  | IN
  | p_itemtype - The itemType of the workflow for which attributes will be updated
  | p_itemkey - The itemKey of the workflow for which attributes will be updated
  | p_daylist - list of days of the month
  |
  | OUT - the day in the list that is closest to current day
  |
  |
  +========================================================================+
*/

function set_monthly_list(p_itemtype in varchar2,
                  		  p_itemkey  in varchar2,
                  		  p_daylist    in varchar2) return varchar2

AS

    l_api_name      CONSTANT VARCHAR2(30) := 'SET_MONTHLY_LIST';

    l_todayDay number;
    l_testToUse number;
    l_testDay varchar2(100);
    l_testRemaining varchar2(100);
    l_lastDiff number;
    l_thisDiff number;
    l_loopFlag boolean:=TRUE;
    l_lastDayDiff number;
    l_lastDay number;

BEGIN

   zpb_log.write('G_PKG_NAME' || '.' || l_api_name ,
                 'prcoedure start. daylist '||p_daylist);

   -- initialize variables and first test case
   l_testDay:=upper(substr(p_daylist, 1, instr(p_daylist, ',') -1));
   l_testToUse:=to_number(l_testDay);
   l_testRemaining:=substr(p_daylist, instr(p_daylist, ',')+1);

   l_todayDay:=to_number(to_char(sysdate, 'DD'));

   -- if first day in list is today, we are done
   -- while looping over all values in list, watch out for 'LastDay' option
   if l_todayDay = l_testToUse then
		l_loopFlag:=FALSE;
   else
		if l_testToUse > l_todayDay then
           l_lastDiff:= l_testToUse-l_todayDay;
        else
           l_lastDiff:= l_testToUse-l_todayDay+31;
        end if;

        if instr(l_testRemaining, ',') > 0 then
			l_testDay:=upper(substr(l_testRemaining, 1, instr(l_testRemaining, ',') -1));
            l_testToUse:=to_number(l_testDay);
			l_testRemaining:=substr(l_testRemaining, instr(l_testRemaining, ',')+1);
		else
            l_testDay:=l_testRemaining;
            l_testToUse:=to_number(l_testDay);
            l_testRemaining:=NULL;

			if l_testDay='LastDay' then
                l_loopFlag:=FALSE;
                l_testDay:=upper(substr(p_daylist, 1, instr(p_daylist, ',') -1));
                l_testToUse:=to_number(l_testDay);
                l_testRemaining:=substr(p_daylist, instr(p_daylist, ',')+1);
            end if;
        end if;
	end if;

	while l_loopFlag=TRUE loop

		if l_testToUse =l_todayDay then
			l_loopFlag:=FALSE;
		else
    		if l_testToUse > l_todayDay then
                l_thisDiff:= l_testToUse-l_todayDay;
            else
                l_thisDiff:= l_testToUse-l_todayDay+31;
            end if;

			if l_thisDiff<l_lastDiff then
				l_loopFlag:=FALSE;
			else
				l_lastDiff:=l_thisDiff;

				if instr(l_testRemaining, ',') > 0 then
					l_testDay:=upper(substr(l_testRemaining, 1, instr(l_testRemaining, ',') -1));
                    l_testToUse:=to_number(l_testDay);
					l_testRemaining:=substr(l_testRemaining, instr(l_testRemaining, ',')+1);
				else
					if length(l_testRemaining) > 0 then
						l_testDay:=l_testRemaining;
                        l_testRemaining:=NULL;

						if l_testDay='LastDay' then
                            l_loopFlag:=FALSE;
                            l_testDay:=upper(substr(p_daylist, 1, instr(p_daylist, ',') -1));
                            l_testToUse:=to_number(l_testDay);
			                l_testRemaining:=substr(p_daylist, instr(p_daylist, ',')+1);
                        else
                            l_testToUse:=to_number(l_testDay);
                        end if;
					else
					    l_testDay:=upper(substr(p_daylist, 1, instr(p_daylist, ',') -1));
                        l_testToUse:=to_number(l_testDay);
			            l_testRemaining:=substr(p_daylist, instr(p_daylist, ',')+1);
					    l_loopFlag:=FALSE;
					end if;
				end if;
			end if;
		end if;
	end loop;

   -- Check for LAST_DAY in list
   if instr(p_daylist, 'LastDay')>0 then
        l_lastDay:=to_number(to_char(last_day(sysdate), 'DD'));
        l_lastDayDiff:=l_lastDay-l_todayDay;

        if l_testToUse >= l_todayDay then
            l_thisDiff:= l_testToUse-l_todayDay;
        else
            l_thisDiff:= l_testToUse-l_todayDay+31;
        end if;

        if l_thisDiff>l_lastDayDiff then
            l_testDay:='LAST';
            l_testRemaining:=NULL;
        end if;
   end if;

   if length(nvl(l_testRemaining, '') || ' ' ) < 2 then
	l_testRemaining:= p_daylist;
   end if;

   wf_engine.SetItemAttrText(Itemtype => p_itemtype,
                            Itemkey => p_itemkey,
                            aname =>  'REMAININGSEL',
                            avalue => l_testRemaining);

   wf_engine.SetItemAttrText(Itemtype => p_itemtype,
                            Itemkey => p_itemkey,
                            aname =>  'WAIT_DAY_OF_MONTH',
                            avalue => l_testDay);

  zpb_log.write('G_PKG_NAME' || '.' || l_api_name ,
                 'prcoedure end. closest-day '|| l_testDay || ' remainder ' || l_testRemaining);

  return l_testDay;

END set_monthly_list;

/*+=========================================================================+
  | private function SET_WEEKLY_LIST
  |
  | This function takes in a list of days of the week and finds
  | the day of the week that is closest in the future to the current day
  | It assumes that the passed in list is chronologically sorted
  |
  | IN
  | p_itemtype - The itemType of the workflow for which attributes will be updated
  | p_itemkey - The itemKey of the workflow for which attributes will be updated
  | p_daylist - list of days of the week
  |
  | OUT - the day in the list that is closest to current day
  |
  |
  +========================================================================+
*/
function set_weekly_list(p_itemtype in varchar2,
                  		  p_itemkey  in varchar2,
                  		  p_daylist    in varchar2) return varchar2
   IS

    l_api_name      CONSTANT VARCHAR2(30) := 'SET_WEEKLY_LIST';

    l_todayDay varchar2(30);
    l_testDay varchar2(100);
    l_testRemaining varchar2(100);
    l_lastDiff number;
    l_thisDiff number;
    l_loopFlag boolean:=TRUE;

BEGIN

   zpb_log.write('G_PKG_NAME' || '.' || l_api_name ,
                 'prcoedure start. daylist '||p_daylist);

   -- get current day of week for comparison
   l_todayDay :=to_char(sysdate, 'DAY') || '';

   l_testDay:=upper(substr(p_daylist, 1, instr(p_daylist, ',') -1));
   l_testRemaining:=substr(p_daylist, instr(p_daylist, ',')+1);


   -- if first day in list is today, then we do not need to loop through the list
   if to_char(sysdate, 'DAY') || '' = upper(l_testDay) then
		l_loopFlag:=FALSE;
   else
		-- set difference variable and prepare next day for comparison
		l_lastDiff:=NEXT_DAY(sysdate, l_testDay) - sysdate;
        if instr(l_testRemaining, ',') > 0 then
		 	l_testDay:=upper(substr(l_testRemaining, 1, instr(l_testRemaining, ',') -1));
			l_testRemaining:=substr(l_testRemaining, instr(l_testRemaining, ',')+1);
		else
			l_testDay:=l_testRemaining;
			l_testRemaining:=NULL;
        end if;
   end if;

   while l_loopFlag=TRUE loop

   		if upper(l_testDay) = l_todayDay then
			l_loopFlag:=FALSE;
   		else
			-- save difference
	    	l_thisDiff:=NEXT_DAY(sysdate, l_testDay) - sysdate;
			-- if found closer day, then we have looped around and are done searching
		    if l_thisDiff<l_lastDiff then
				l_loopFlag:=FALSE;
	    	else
				l_lastDiff:=l_thisDiff;
				if instr(l_testRemaining, ',') > 0 then
					l_testDay:=upper(substr(l_testRemaining, 1, instr(l_testRemaining, ',') -1));
					l_testRemaining:=substr(l_testRemaining, instr(l_testRemaining, ',')+1);
				else
					if length(l_testRemaining) > 0 then
						l_testDay:=l_testRemaining;
						l_testRemaining:=NULL;
					else
						l_testDay:=upper(substr(p_daylist, 1, instr(p_daylist, ',') -1));
			        	l_testRemaining:=substr(p_daylist, instr(p_daylist, ',')+1);
						l_loopFlag:=FALSE;
					end if; -- anything left to test
				end if; -- at least two things left to test
			end if; -- test case is today
		end if; -- first test case is today
	end loop;

  -- if closest day happens to be last in list, reset remainder to be the full list
  if length(nvl(l_testRemaining, '') || ' ' ) < 2 then
	l_testRemaining:= p_daylist;
  end if;

  -- set appropriate workflow attributess
  wf_engine.SetItemAttrText(Itemtype => p_itemtype,
                            Itemkey => p_itemkey,
                            aname =>  'REMAININGSEL',
                            avalue => l_testRemaining);

  wf_engine.SetItemAttrText(Itemtype => p_itemtype,
                            Itemkey => p_itemkey,
                            aname =>  'WAIT_DAY_OF_WEEK',
                            avalue => l_testDay);

  zpb_log.write('G_PKG_NAME' || '.' || l_api_name ,
                 'prcoedure end. closest-day '|| l_testDay || ' remainder ' || l_testRemaining);

  return l_testDay;

end set_weekly_list;

procedure FrequencyInit (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2)
   AS


    ACID number;
    ACNAME varchar2(300);
    retval varchar2(4000);
    ownerID number;
    owner varchar2(30);

    paramID number;
    FreqType varchar2(100);
    FreqRep  number;
    freqSelW  varchar2(100);
    freqSelM  varchar2(100);
    freqSel   varchar2(100);
    UntilDate date;
    errMsg  varchar2(100);
    thisValue varchar2(100);
    addMonths number;
    NewDate  date;
    thisFreqSel varchar2(100);
    curFreqBehavior varchar2(100);

    schedProfileOption varchar2(80);
    oneTimeOnlyActive number;

    compDay varchar2(100);

     CURSOR c_params is
      select param_id, value
      from ZPB_AC_PARAM_VALUES
      where ANALYSIS_CYCLE_ID = ACID and PARAM_ID IN (19, 20, 21, 22, 23, 24);

      v_params c_params%ROWTYPE;

   BEGIN
  --  24 CALENDAR_REPEAT_DAY_OF_MONTH
  --  23 CALENDAR_REPEAT_WEEKDAY
  --  22 CALENDAR_REPEAT_UNTIL_DATE
  --  21 CALENDAR_REPEAT_FREQUENCY
  --  19 CALENDAR_FREQUENCY_TYPE

 IF (funcmode = 'RUN') THEN
     resultout :='COMPLETE:N';


ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'ACID');

ACNAME := wf_engine.GetItemAttrText(Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'ACNAME');

OWNERID := wf_engine.GetItemAttrText(Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'OWNERID');

    for  v_params in c_params loop

     paramID := v_params.param_id;

     if ParamID = 19 then
        freqType := v_params.value;
        elsif ParamID = 21 then
            thisValue := v_params.value;
            freqRep := to_number(thisValue);
            elsif ParamID = 22 then
               thisValue := v_params.value;
			   -- set date to last second of chosen date so that last instance may be created
			   -- at any time of the cut off date
               UntilDate := to_date(thisValue, 'YYYY/MM/DD-HH24:MI:SS') + 1 - 1/(24*3600) ;
               elsif ParamID = 23 then
                       freqSelW := v_params.value;
                   elsif ParamID = 24 then
                         freqSelM := v_params.value;
      else
         errMsg := v_params.value;
      end if;

     end loop;

 -- +==============================================================
 --  ONE_TIME_ONLY
 --  BUG 4291814 - WORKFLOW COMPONENTS: START BP EXTERNALLY

 if freqType = 'ONE_TIME_ONLY' or freqType = 'EXTERNAL_EVENT'  then

-- if freq type is one-time-only, only create a new instance if
-- there are no active instance of this BP

schedProfileOption:=  FND_PROFILE.VALUE_SPECIFIC('ZPB_BPSCHEDULER_TYPE', OwnerId);

       resultout :='COMPLETE:BYPASS';

       wf_engine.SetItemAttrText(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'FREQBEHAVIOR',
                                   avalue => 'ONE_TIME_ONLY');
     end if;

 -- +==============================================================
 -- Set the run Until date. Used for comparison to sysdate.
 -- Reference date.
 if length(UntilDate) > 0 then
  wf_engine.SetItemAttrDate(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'VALUE2',
                           avalue => UntilDate);
 end if;

 -- +==============================================================
 -- Case Daily  Will first run based on start date
    if freqType = 'DAILY' then

       -- Sets Wait attributes for scheduling.
       wf_engine.SetItemAttrText(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'WAIT_MODE',
                                   avalue => 'RELATIVE');

       wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'WAIT_RELATIVE_TIME',
                                   avalue => freqRep);

      wf_engine.SetItemAttrText(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'FREQBEHAVIOR',
                                   avalue => 'LOOP');

      resultout :='COMPLETE:BYPASS';
      return;
    end if;

 -- +==============================================================
 -- Case Yearly

    curFreqBehavior := wf_engine.GetItemAttrText(Itemtype => ItemType,
               Itemkey => ItemKey,
               aname => 'FREQBEHAVIOR');

    if freqType = 'YEARLY' then

    wf_engine.SetItemAttrText(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'WAIT_MODE',
                                   avalue => 'ABSOLUTE');
    -- make adjustment
    addMonths := freqRep * 12;
    NewDate := add_months(sysdate, addMonths);

    wf_engine.SetItemAttrDate(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'WAIT_ABSOLUTE_DATE',
                                   avalue => NewDate);

    wf_engine.SetItemAttrText(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'FREQBEHAVIOR',
                                   avalue => 'LOOP');


     -- if the frequency is yearly and the start data has been reset,
     -- do not create instance right away
     if curFreqBehavior='YEARLYRESET' then
        resultout :='COMPLETE:LOOP';
     else
        resultout :='COMPLETE:BYPASS';
     end if;

   end if;

 -- +==============================================================
 -- Case Monthly
    if freqType = 'MONTHLY' then

       freqSel := freqSelM;
       wf_engine.SetItemAttrText(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'WAIT_MODE',
                                   avalue => 'DAY_OF_MONTH');

       --Parse selection.
       if length(freqSel) > 0 then

			thisFreqSel := set_monthly_list(ItemType, ItemKey, freqSel);

       end if; --length


       -- don't forget freqRep > 1!!!!

       if freqRep > 1 then

       -- make adjustment
       -- NewDate := add_months(sysdate, freqRep);
       NewDate := to_date((to_char(add_months(sysdate, freqRep), 'YYYY/MM') || '/01'), 'YYYY/MM/DD');

     wf_engine.SetItemAttrDate(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'ABSOLUTE_SLEEP_DATE',
                                   avalue => NewDate);

      wf_engine.SetItemAttrText(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'FREQBEHAVIOR',
                                   avalue => 'SLEEP');

       resultout :='COMPLETE:SLEEP';
       else
      wf_engine.SetItemAttrText(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'FREQBEHAVIOR',
                                   avalue => 'LOOP');

      -- Workflow WAIT blocks that are set to wait for a day on that day will not fire
      -- until that day of the next month.  Thus check if next scheduled day is today
      -- and bypass wait in this case
        if thisFreqSel='LAST' then
                compDay:= to_char(LAST_DAY(sysdate), 'dd');
        else
                compDay:= thisFreqSel;
        end if;

        -- prefix compDay with zero if appropriate
        -- to_char(sysdate) returns 04 instead of 4 for the fourth
        if length(compDay)=1 then
                compDay:= '0' || compDay;
        end if;


        if compDay = to_char(sysdate, 'dd')  then
                resultout:='COMPLETE:BYPASS';
        else
                resultout:='COMPLETE:LOOP';
        end if; -- bypassing for today

       end if; -- freqRep

    end if;

 -- +==============================================================
 -- Case Weekly
    if freqType = 'WEEKLY' then

      freqSel := freqSelW;
      wf_engine.SetItemAttrText(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'WAIT_MODE',
                                   avalue => 'DAY_OF_WEEK');

       --Parse selection.
       if length(freqSel) > 0 then

			thisFreqSel := set_weekly_list(ItemType, ItemKey, freqSel);

       end if; --length

       if freqRep > 1 then

       -- make adjustment
       NewDate := sysdate + (7*freqRep);

       wf_engine.SetItemAttrDate(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'ABSOLUTE_SLEEP_DATE',
                                   avalue => NewDate);

      wf_engine.SetItemAttrText(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'FREQBEHAVIOR',
                                   avalue => 'SLEEP');

       resultout :='COMPLETE:SLEEP';
       else

         wf_engine.SetItemAttrText(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'FREQBEHAVIOR',
                                   avalue => 'LOOP');

      -- Workflow WAIT blocks that are set to wait for a day on that day will not fire
      -- until that day of the next week.  Thus check if next scheduled day is today
      -- and bypass wait in this case
          if upper(thisFreqSel) = to_char(sysdate, 'fmDAY') then
             resultout :='COMPLETE:BYPASS';
          else
             resultout :='COMPLETE:LOOP';
           end if;
       end if;

    end if;


 END IF;
 return;

 exception
   when others then
     WF_CORE.CONTEXT('ZPB_WF.FrequencyInit', itemtype, itemkey, to_char(actid), funcmode);
 raise;

end FrequencyInit;

--
--
procedure FrequencyMgr (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2)
   AS

    ACID number;
    ACNAME varchar2(300);
    retval varchar2(4000);

    paramID number;
    FreqType varchar2(100);
    FreqRep  number;
    UntilDate date;
    errMsg  varchar2(100);
    thisValue varchar2(100);
    addMonths number;
    NewDate  date;
    thisFreqSel varchar2(100);
    freqMode  varchar2(30);
    Behavior   varchar2(16);
    freqSel varchar2(100);
    selValue varchar2(100);

   BEGIN


IF (funcmode = 'RUN') THEN
    resultout :='COMPLETE:N';


 -- Get Wait MODE

    ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'ACID');

    ACNAME := wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'ACNAME');

    freqMode := wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'WAIT_MODE');

    Behavior := wf_engine.GetItemAttrText(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'FREQBEHAVIOR');


-- Case one time only
    if Behavior = 'ONE_TIME_ONLY' then

    resultout := 'COMPLETE:ONE_TIME_ONLY';
    return;

    end if;

-- Case Daily
   if freqMode = 'RELATIVE' then

    resultout := 'COMPLETE:LOOP';
    return;

   end if;

-- Case Yearly

   if freqMode = 'ABSOLUTE' then

      select Value
      into freqRep
      from ZPB_AC_PARAM_VALUES
      where ANALYSIS_CYCLE_ID = ACID and PARAM_ID = 21;

      -- make adjustment
      addMonths := freqRep * 12;

      NewDate := add_months(sysdate, addMonths);

      wf_engine.SetItemAttrDate(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'WAIT_ABSOLUTE_DATE',
                                   avalue => NewDate);

    resultout := 'COMPLETE:LOOP';
    return;
   end if;


-- Case Monthly
   if freqMode = 'DAY_OF_MONTH' then

       -- get the remaining days and set them
       FreqSel := wf_engine.GetItemAttrText(Itemtype => ItemType,
                            Itemkey => ItemKey,
                            aname =>  'REMAININGSEL');

         --Parse selection.
         if length(FreqSel) > 0 then

            if instr(FreqSel, ',') > 0 then
               thisFreqSel := substr(FreqSel, 1, instr(freqSel, ',') -1);
               freqSel := substr(freqSel, instr(freqSel, ',')+1);
            else
               thisFreqSel := substr(freqSel, 1);

               -- have gone over all days specified; reset REMAININGSEL from DB
               -- AC Param value
               select Value
               into freqSel
               from ZPB_AC_PARAM_VALUES
               where ANALYSIS_CYCLE_ID = ACID and PARAM_ID = 24;

            end if;  -- comma

            if thisFreqSel = 'LastDay' then
              thisFreqSel := 'LAST';
            end if;

            wf_engine.SetItemAttrText(Itemtype => ItemType,
                            Itemkey => ItemKey,
                            aname =>  'WAIT_DAY_OF_MONTH',
                            avalue => thisFreqSel);

            -- adjusts freq sel.
            wf_engine.SetItemAttrText(Itemtype => ItemType,
                            Itemkey => ItemKey,
                            aname =>  'REMAININGSEL',
                            avalue => FreqSel);
         end if; -- length, length should never be 0 because above we reset REMAININGSEL when
                 -- it reaches null

      -- Only sleep

      if Behavior = 'SLEEP' then
      -- make adjustment 21 CALENDAR_REPEAT_FREQUENCY

         select Value
         into freqRep
         from ZPB_AC_PARAM_VALUES
         where ANALYSIS_CYCLE_ID = ACID and PARAM_ID = 21;

        -- NewDate := add_months(sysdate, freqRep);
       NewDate := to_date((to_char(add_months(sysdate, freqRep), 'YYYY/MM') || '/01'), 'YYYY/MM/DD');

        wf_engine.SetItemAttrDate(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'ABSOLUTE_SLEEP_DATE',
                                   avalue => NewDate);

         resultout :='COMPLETE:SLEEP';

      end if;  -- sleep

      if Behavior = 'LOOP' then
         resultout :='COMPLETE:LOOP';
      end if;

   end if;  -- end mode


-- Case Weekly
    if freqMode = 'DAY_OF_WEEK' then

          -- get the remaining days and set them
          FreqSel := wf_engine.GetItemAttrText(Itemtype => ItemType,
                            Itemkey => ItemKey,
                            aname =>  'REMAININGSEL');

          --Parse selection.
          if length(FreqSel) > 0 then

            if instr(FreqSel, ',') > 0 then
               thisFreqSel := upper(substr(FreqSel, 1, instr(freqSel, ',') -1));
               freqSel := substr(freqSel, instr(freqSel, ',')+1);
            else
               thisFreqSel := upper(substr(freqSel, 1));

               -- have gone over all days specified; reset REMAININGSEL from DB
               -- AC Param value
               select Value
               into freqSel
               from ZPB_AC_PARAM_VALUES
               where ANALYSIS_CYCLE_ID = ACID and PARAM_ID = 23;

            end if;  -- comma

            wf_engine.SetItemAttrText(Itemtype => ItemType,
                            Itemkey => ItemKey,
                            aname =>  'WAIT_DAY_OF_WEEK',
                            avalue => thisFreqSel);

            -- adjusts freq sel.
            wf_engine.SetItemAttrText(Itemtype => ItemType,
                            Itemkey => ItemKey,
                            aname =>  'REMAININGSEL',
                            avalue => FreqSel);

         end if; -- length, length should never be 0 because above we reset REMAININGSEL when
                 -- it reaches null

      -- Only sleep
      if Behavior = 'SLEEP' then
      -- make adjustment 21 CALENDAR_REPEAT_FREQUENCY

         select Value
         into freqRep
         from ZPB_AC_PARAM_VALUES
         where ANALYSIS_CYCLE_ID = ACID and PARAM_ID = 21;

         NewDate := sysdate + (7*freqRep);

        wf_engine.SetItemAttrDate(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname =>  'ABSOLUTE_SLEEP_DATE',
                                   avalue => NewDate);

        resultout :='COMPLETE:SLEEP';
      end if;  -- sleep

      if Behavior = 'LOOP' then
         resultout :='COMPLETE:LOOP';
      end if;

   end if;  -- end mode

 END IF;

 return;

 exception
   when others then
     WF_CORE.CONTEXT('ZPB_WF.FrequencyMgr', itemtype, itemkey, to_char(actid), funcmode);
 raise;

end FrequencyMgr;


procedure  SetCompDate (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
              resultout   out nocopy varchar2)
   IS

   BEGIN
   -- Test value date SYSDATE.  The desired End date is compared to this.
   --  if UntilDate is < SYSDATE keep running.

      IF (funcmode = 'RUN') THEN
         resultout :='COMPLETE:N';

        wf_engine.SetItemAttrDate(Itemtype => ItemType,
                                   Itemkey => ItemKey,
                                   aname => 'VALUE1',
                                   avalue => sysdate);

         resultout :='COMPLETE:Y';

  END IF;

  exception
   when others then
     WF_CORE.CONTEXT('ZPB_WF', 'SetCompDate', itemtype, itemkey, to_char(actid), funcmode);
     raise;
end SetCompDate;


procedure PAUSE_INSTANCE (InstanceID in number)
   IS

   InstatusCode  varchar2(30);

   BEGIN

   select STATUS_CODE
    into InstatusCode
    from ZPB_ANALYSIS_CYCLES
    where ANALYSIS_CYCLE_ID = InstanceID
    for update nowait;

   if InstatusCode = 'ACTIVE' or InstatusCode = 'WARNING' then


      update ZPB_ANALYSIS_CYCLES
      set prev_status_code = status_code
      where ANALYSIS_CYCLE_ID = InstanceID;

      -- agb 04/22/04 change from PAUSED to PAUSING.
      update ZPB_ANALYSIS_CYCLES
      set status_code = 'PAUSING',
      LAST_UPDATED_BY =  fnd_global.USER_ID,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
      where ANALYSIS_CYCLE_ID = InstanceID;
   end if;

   commit;
   return;

   exception

    when NO_DATA_FOUND then
         Null;

    when others then
         -- ORA-00054: resource busy and acquire with NOWAIT specified
         if instr(sqlerrm, 'ORA-00054') > 0 then
            Null;
            return;
         else
            raise;
         end if;

end PAUSE_INSTANCE;


procedure RESUME_INSTANCE (InstanceID in number, PResumeType varchar2 default 'NORMAL')
   IS

    CurrtaskSeq number;
    ITEMTYPE varchar(8) := 'EPBCYCLE';
    ACID number;
    ACNAME varchar2(300);
    ACstatusCode varchar2(30);
    InstanceStatusCode varchar2(30);
    InPrevStatusCode varchar2(30);
    TaskID number;
    owner  varchar2(30);
    ownerID number;
    respID number;
    respAppID number;
    charDate varchar2(30);
    newitemkey varchar2(240);
    olditemkey varchar2(240);
    workflowprocess varchar2(30);
    bkgREQID number;
    Marked varchar2(16);
    resultout varchar2(100);
    retcode number;
    l_business_area_id  number;


    CURSOR c_tasks is
      select *
      from zpb_analysis_cycle_tasks
      where ANALYSIS_CYCLE_ID = InstanceID
      and Sequence = CurrtaskSeq+1;
    v_tasks c_Tasks%ROWTYPE;
    -- 5867453 bkport of 5371156 get resume parameters from zpb not wf
    CURSOR c_respID is
     select A.RESP_ID
      from  zpb_account_states A, fnd_responsibility_vl R
        where A.ACCOUNT_STATUS = 0
        AND A.USER_ID = ownerID
        AND A.BUSINESS_AREA_ID = l_business_area_id
        AND A.RESP_ID = R.RESPONSIBILITY_ID
        AND R.RESPONSIBILITY_KEY IN
         ('ZPB_MANAGER_RESP', 'ZPB_CONTROLLER_RESP', 'ZPB_SUPER_CONTROLLER_RESP');
    v_respID c_respID%ROWTYPE;

-- This needs to

   BEGIN

    begin

    select status_code, prev_status_code
    into InstanceStatusCode, InPrevStatusCode
    from zpb_analysis_cycles
    where analysis_cycle_id = InstanceID;

    EXCEPTION
     WHEN NO_DATA_FOUND THEN
        InstanceStatusCode:='ISCNotFound';
        InPrevStatusCode:='ACTIVE';
    end;

    if InPrevStatusCode is null then
        InPrevStatusCode:='ACTIVE';
    end if;

    -- if the status of the instance to be resumed is PAUSING
    -- all we need to do is set the status to previous status code
    if InstanceStatusCode = 'PAUSING' then
        update zpb_analysis_cycles
        set status_code= InPrevStatusCode
        where analysis_cycle_id = InstanceID;

        resultout :='COMPLETE:Y';
        commit;
        return;
    end if;

    --  5867453 bkport of  5371156 add ownerID drop Item_key
    select sequence, owner_id
    into  CurrtaskSeq, ownerID
    from ZPB_ANALYSIS_CYCLE_TASKS
    where ANALYSIS_CYCLE_ID = InstanceID and
    sequence = (select MAX(SEQUENCE) from ZPB_ANALYSIS_CYCLE_TASKS
    where ANALYSIS_CYCLE_ID = InstanceID and  STATUS_CODE = 'COMPLETE');

    -- When resume_instance is called from enable_cycle there is a
    -- specal case when transitioning from DISABLE_ASAP to ENABLE_FIRST
    if PResumeType = 'RUN_FROM_TOP' then
       CurrtaskSeq := 0;
       --
       update ZPB_ANALYSIS_CYCLE_TASKS
       set STATUS_CODE = null,
         LAST_UPDATED_BY =  fnd_global.USER_ID,
       LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       where ANALYSIS_CYCLE_ID = InstanceID;
    end if;

    -- 5867453 bkport of  5371156 new source for base parmameters ownerID from task table above.
     select i.ANALYSIS_CYCLE_ID, c.name, c.BUSINESS_AREA_ID
        into  ACID, ACNAME, l_business_area_id
        from zpb_analysis_cycle_instances i,
             zpb_analysis_cycles c
        where i.INSTANCE_AC_ID = InstanceID
        and i.ANALYSIS_CYCLE_ID = c.ANALYSIS_CYCLE_ID;

     Owner := ZPB_WF_NTF.ID_to_FNDUser(OwnerID);
     respAppID := 210;
     for  v_respID in c_respID loop
         RespID := v_respID.RESP_ID;
         exit;
     end loop;

    --  Get next task [wf process] to run If none COMPLETE

    workflowprocess := 'NONE';
    TaskID := NULL;

    for  v_Tasks in c_Tasks loop
         TaskID := v_Tasks.TASK_ID;
         workflowprocess := v_Tasks.wf_process_name;
    end loop;

    -- LAST TASK FOR THIS INSTANCE
    if workflowprocess = 'NONE' then

       update zpb_ANALYSIS_CYCLES
       set status_code = 'COMPLETE',
         LAST_UPDATED_BY =  fnd_global.USER_ID,
         LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       where ANALYSIS_CYCLE_ID = INSTANCEID;

       update zpb_analysis_cycle_instances
       set last_update_date = sysdate,
         LAST_UPDATED_BY =  fnd_global.USER_ID,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       where instance_ac_id = INSTANCEID;

       -- Mark for delete
       zpb_wf.markfordelete(ACID, ownerID, respID, respAppID);

       resultout :='COMPLETE:N';
       return;
    end if;

  -- Set item key and date
  charDate := to_char(sysdate, 'MM/DD/YYYY-HH24-MI-SS');
  newitemkey := rtrim(substr(ACName, 1, 50), ' ') || '-' || to_char(ACID) || '-' || to_char(CurrtaskSeq+1) || '-' || workflowprocess || '-' || charDate;


-- Create WF start process instance
   wf_engine.CreateProcess(ItemType => ItemType,
                         itemKey => newItemKey,
                         process => WorkflowProcess);

-- This should be the EPB controller.
   wf_engine.SetItemOwner(ItemType => ItemType,
                           ItemKey => NEWItemKey,
                           owner => owner);

-- Set current value of Taskseq [not sure if it is always 1 might be for startup]
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'TASKSEQ',
                           avalue => CurrtaskSeq+1);

-- set globals for new key???

-- set Cycle ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'ACID',
                           avalue => ACID);

-- abudnik 17NOV2005 BUSINESS AREA ID.
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'BUSINESSAREAID',
                           avalue => l_business_area_id);

-- set workflow with Instance Cycle ID!
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'INSTANCEID',
                           avalue => InstanceID);

-- set cycle Name!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'ACNAME',
                           avalue => ACNAME);
-- set Task ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'TASKID',
                           avalue => TaskID);

-- set owner name attr!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'FNDUSERNAM',
                           avalue => owner);

-- set EPBPerformer to owner name for notifications!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'EPBPERFORMER',
                           avalue => owner);


-- will get error notifications
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'WF_ADMINISTRATOR',
                           avalue => owner);

-- set owner ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'OWNERID',
                           avalue => ownerID);

-- set resp ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'RESPID',
                           avalue => respID);

-- set App resp ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'RESPAPPID',
                           avalue => respAppID);

if workflowprocess = 'EXCEPTION' then
     -- plsql document procedure
     wf_engine.SetItemAttrText(itemtype => itemtype,
                  itemkey  =>  newItemKey,
                  aname    => 'RESPNOTE',
                  avalue   => 'PLSQL:ZPB_EXCEPTION_ALERT.NON_RESPONDERS/' || newItemKey );
end if;


-- Now that all is created and set START the PROCESS!
   wf_engine.StartProcess(ItemType => ItemType,
                          ItemKey => newItemKey);

   update zpb_analysis_cycle_tasks
   set item_KEY = newitemkey,
   Start_date = to_Date(charDate,'MM/DD/YYYY-HH24-MI-SS'),
   status_code = 'ACTIVE',
   LAST_UPDATED_BY =  fnd_global.USER_ID,
   LAST_UPDATE_DATE = SYSDATE,
   LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   where ANALYSIS_CYCLE_ID = INSTANCEID and task_id = TaskID;

   update ZPB_ANALYSIS_CYCLES
   set status_code = InPrevStatusCode,
   LAST_UPDATED_BY =  fnd_global.USER_ID,
   LAST_UPDATE_DATE = SYSDATE,
   LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   where ANALYSIS_CYCLE_ID = INSTANCEID;

   update zpb_analysis_cycle_instances
   set last_update_date = sysdate,
   LAST_UPDATED_BY =  fnd_global.USER_ID,
   LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   where instance_ac_id = INSTANCEID;





   resultout :='COMPLETE:Y';

   commit;
   return;

   exception
   when NO_DATA_FOUND then
         Null;

     when others then
      raise;

end RESUME_INSTANCE;
--
-- added Concurrent_Wrapper 03/27/2003
--
-- abudnik 17NOV2005 BUSINESS AREA ID.
procedure Concurrent_Wrapper (errbuf out nocopy varchar2,
                        retcode out nocopy varchar2,
                        ACID in Number,
                        TaskID in Number,
                        DataAW in Varchar2,
                        CodeAW in Varchar2,
                        AnnoAW in Varchar2,
                        P_BUSINESS_AREA_ID in Number)
   IS

   attached   varchar2(1) := 'N';
   l_migration  varchar2(4000);
   l_InstanceID number;
   thisCount    number;
   returnStat   varchar2(1000);
   msgData      varchar2(1000);
   l_api_name   varchar2(64) := 'Concurrent_Wrapper';
   l_published_by number;

    -- 28 MIGRATION_INSTANCE
    CURSOR c_mparams is
      select value
      from ZPB_AC_PARAM_VALUES
      where ANALYSIS_CYCLE_ID = l_InstanceID and PARAM_ID = 28;

    v_mparams c_mparams%ROWTYPE;




BEGIN

   retcode := '0';

  -- set olap page pool size based on ZPB_OPPS_DATA_MOVE param for BP publisher
  begin
	select published_by into l_published_by
	from zpb_analysis_cycles
	where analysis_cycle_id = ACID;

	zpb_util_pvt.set_opps(ZPB_UTIL_PVT.ZPB_OPPS_DATA_MOVE, l_published_by);

	-- if somethinf goes wrong during olap page pool setting from forms param,
	-- continue with load data request
	exception
	when others then
	zpb_log.write_event(G_PKG_NAME || '.' || l_api_name, 'Could not set olap page pool size to profile value for ' || to_char(ACID));

  end;



  select analysis_cycle_id into l_InstanceID
    from zpb_analysis_cycle_tasks
    where task_id  = TaskID;

  ZPB_AW.INITIALIZE_FOR_AC (p_api_version       => 1.0,
                            p_init_msg_list     => FND_API.G_TRUE,
                            x_return_status     => returnStat,
                            x_msg_count         => thisCount,
                            x_msg_data          => msgData,
                            p_analysis_cycle_id => l_InstanceID,
                            p_shared_rw         => FND_API.G_TRUE);
  attached := 'Y';

  l_migration := 'N';
  for  v_mparams in c_mparams loop
       l_migration := v_mparams.VALUE;
   end loop;

  -- b 5170327 intializes the pv_status variable for warnigs generated in AW
  ZPB_ERROR_HANDLER.INIT_CONC_REQ_STATUS;

  if l_migration = 'Y' then
     ZPB_GEN_PHYS_MODEL.GEN_PHYSICAL_MODEL(l_InstanceID);
  end if;

  zpb_data_load.run_data_load(TaskID, DataAW, CodeAW, AnnoAW);

  -- b 5170327 - retcode is an OUT parameter conc program standard - 0=success, 1=warning or 2=error.
  -- for warnings from just above flow of calls.
  retcode := ZPB_ERROR_HANDLER.GET_CONC_REQ_STATUS;


  ZPB_AW.DETACH_ALL;

  return;

  exception

   when others then
    retcode :='2';

    if attached = 'Y' then
       ZPB_AW.DETACH_ALL;
    end if;

    -- update zpb instance info with ERROR
    UPDATE_STATUS('ERROR', l_InstanceID, taskid, NULL);

    errbuf:=substr(sqlerrm, 1, 255);


end Concurrent_wrapper;
--
--

procedure SET_CURRINST (itemtype in varchar2,
                        itemkey  in varchar2,
                        actid    in number,
                        funcmode in varchar2,
                        resultout   out nocopy varchar2)

  IS

    CurrtaskSeq number;
    ACID number;
    ACNAME varchar2(300);
    TaskID number;
    InstanceID number;
    ownerID number;
    respID number;
    respAppID number;
    sessionID number;
    DLcmd varchar2(100);
    P_OUTVAL number;
    reqID number;
    l_business_area_id number;
  BEGIN

  IF (funcmode = 'RUN') THEN
       resultout :='ERROR';

       ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'ACID');
       InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'INSTANCEID');
       TaskID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'TASKID');


       ownerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'OWNERID');
       respID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPID');
       respAppID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPAPPID');

       sessionid := userenv('SESSIONID');

       DLcmd := 'call CM.SETCURRINST ('''||instanceID||''' '''||ACID||''')';

       select BUSINESS_AREA_ID
          into l_business_area_id
          from ZPB_ANALYSIS_CYCLES
          where ANALYSIS_CYCLE_ID = ACId;

      -- change agb to dbdata.
       ZPB_AW_WRITE_BACK.SUBMIT_WRITEBACK_REQUEST(l_business_area_id,
                                                  ownerID,
                                                  respID,
                                                  sessionID,
                                                  'SPL',
                                                  DLcmd,
                                                  NULL,
                                                  P_OUTVAL);

     -- P_OUTVAL is request ID

     reqID := P_OUTVAL;
     wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'REQUEST_ID',
                           avalue => reqID);

     resultout :='COMPLETE';
    return;
  end if;

  exception
   when others then
     WF_CORE.CONTEXT('ZPB_WF', 'SET_CURRINST', itemtype, itemkey, to_char(actid), funcmode);
     raise;

end SET_CURRINST;

function GetEventACID(taskID in number) return varchar2
   AS

   ACIDList varchar2(4000);
   ACIDtxt varchar2(30);

   CURSOR c_eventACID is
   select  analysis_cycle_id, v.status_code, v.validate_status
   from zpb_published_cycles_v v
   where v.status_code not in ('DISABLE_ASAP', 'DISABLE_NEXT') and
   v.validate_status  = 'VALID' and
   v.analysis_cycle_id in (select pa.analysis_cycle_id
   from zpb_ac_param_values pa
   where pa.param_id = 20 and pa.value in (select d.value
   from ZPB_PROCESS_DETAILS_V d
   where d.name = 'CREATE_EVENT_IDENTIFIER'  and d.task_id = TaskID));

   v_eventACID c_eventACID%ROWTYPE;


  BEGIN

  for v_eventACID in c_eventACID loop

    if c_eventACID%ROWCOUNT = 1 then
       ACIDlist := to_char(v_eventACID.analysis_cycle_id);
    else
       ACIDtxt := to_char(v_eventACID.analysis_cycle_id);
       ACIDlist := ACIDlist ||',' || ACIDtxt;
    end if;

  end loop;

  return ACIDlist;

 exception
  when others then
     raise;
END;

procedure PREP_EVENT_ACID (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2)
  IS

    ACNAME varchar2(300);
    TaskID number;
    ActEntry varchar2(30);
    InstanceID number;
    ACIDlist varchar2(300);
    thisACID varchar2(16);
    owner varchar2(30);
    EventName varchar(4000);
    EventACNAME varchar2(300);
    NameList varchar(4000);

  BEGIN

    resultout := 'COMPLETE:NO_EVENTS';

    SELECT ACTIVITY_NAME INTO ActEntry
    FROM WF_PROCESS_ACTIVITIES
    WHERE INSTANCE_ID=actid;


     --  get TaskID from attribute
    TaskID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                         Itemkey => ItemKey,
                         aname => 'TASKID');

 --   TaskName := wf_engine.GetItemAttrText(Itemtype => ItemType,
 --                      Itemkey => ItemKey,
 --                      aname => 'TASKNAME');

    -- setup event name for message
    select value into EventName from zpb_task_parameters
    where task_ID = taskID and NAME = 'CREATE_EVENT_NAME';

    wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'SUBJECT',
                           avalue => EventName);


    -- get list of event ACIDs to run

    If ActEntry = 'INIT_LIST' then
       ACIDlist := GetEventACID(taskID);
    else
       ACIDlist := wf_engine.GetItemAttrText(Itemtype => ItemType,
                         Itemkey => ItemKey,
                         aname => 'RESULT');

       NameList := wf_engine.GetItemAttrText(Itemtype => ItemType,
                         Itemkey => ItemKey,
                         aname => 'MSGHISTORY');
    end if;

   --Parse selection.

   if ACIDlist is not NULL then

     if length(ACIDlist) > 0 then

      if instr(ACIDlist, ',') > 0 then
         thisACID := substr(ACIDlist, 1, instr(ACIDlist, ',') -1);
         ACIDlist := substr(ACIDlist, instr(ACIDlist, ',')+1);
      else
         thisACID := substr(ACIDlist, 1);
         ACIDlist := NULL;
      end if;  -- comma

      select NAME into EventACname
      from zpb_all_cycles_v
      where ANALYSIS_CYCLE_ID = thisACID;


     if (NameList is not null) then
         NameList :=  NameList || fnd_global.newline || EventACName;
     else
         NameList := EventACName;
     end if;

     wf_engine.SetItemAttrText(Itemtype => ItemType,
                             Itemkey => ItemKey,
                             aname => 'MSGHISTORY',
                             avalue => NameList);


     -- wf_engine.SetItemAttrText(Itemtype => ItemType,
     --            Itemkey => ItemKey,
     --            aname => 'ISSUEMSG',
     --            avalue => EventACName);


      -- This attribute is being overloaded for now.
      -- I'm using it to hold list of ACIDs
      -- adjusted acid list
      wf_engine.SetItemAttrText(Itemtype => ItemType,
                Itemkey => ItemKey,
                    aname =>  'RESULT',
                    avalue => ACIDlist);
      zpb_wf.ACStart(thisACID, 'N', 'Y');
      dbms_lock.sleep(15);
      resultout :='COMPLETE:PROCEED';
     else
      -- 0 length remaining OR NULL
      resultout :='COMPLETE:NO_EVENTS';
     end if; -- length
  else
    resultout :='COMPLETE:NO_EVENTS';
  end if;

  return;

  exception
   when others then
     WF_CORE.CONTEXT('ZPB_WF', 'PREP_EVENT_ACID', itemtype, itemkey, to_char(actid), funcmode);
     raise;

end PREP_EVENT_ACID;


procedure ENABLE_CYCLE(Pacid in number, PStatus in varchar2)
   IS


    ACstatusCode varchar2(30);
    InSTATCode varchar2(30);
    CodeToUpdateTo varchar2(30);
    InstanceID number;
    l_REQID number;
    ownerID      number := fnd_global.USER_ID;
    respID number := fnd_global.RESP_ID;
    respAppID number := fnd_global.RESP_APPL_ID;
    ItemType     varchar2(8) := 'ZPBSCHED';
    ItemKey      varchar2(240);
    freqType     varchar2(30);
    l_business_area_id number;  -- abudnik 17NOV2005 BUSINESS AREA ID


    -- There may be active overlapping instances of an AC
    CURSOR c_instance is

        select distinct zac.analysis_cycle_id
        FROM  ZPB_ANALYSIS_CYCLE_INSTANCES zaci,
              ZPB_ANALYSIS_CYCLE_TASKS zact,
              ZPB_ANALYSIS_CYCLES zac
        WHERE zaci.analysis_cycle_id = Pacid and
              zaci.instance_ac_id = zac.analysis_cycle_id and
              zac.analysis_cycle_id = zact.analysis_cycle_id and
              zac.status_code = 'DISABLE_ASAP' and
              zact.status_code not in ('ACTIVE', 'PENDING');
    v_instnace c_instance%ROWTYPE;

  -- 5867453 bkport of  b5371156 new way to get params for setting context
  -- before submiting a request to the concurrent manager
  CURSOR c_owner_resp is
  select C.OWNER_ID, A.RESP_ID
   from zpb_analysis_cycles C, zpb_account_states A, fnd_responsibility_vl R
   where ANALYSIS_CYCLE_ID = Pacid
    AND A.ACCOUNT_STATUS = 0
    AND A.USER_ID = C.OWNER_ID
    AND C.BUSINESS_AREA_ID = A.BUSINESS_AREA_ID
    AND A.RESP_ID = R.RESPONSIBILITY_ID
    AND R.RESPONSIBILITY_KEY IN
    ('ZPB_MANAGER_RESP', 'ZPB_CONTROLLER_RESP', 'ZPB_SUPER_CONTROLLER_RESP');

   v_owner_resp c_owner_resp%ROWTYPE;

-- This needs to

   BEGIN

    -- abudnik 17NOV2005 BUSINESS AREA ID.
     select STATUS_CODE, BUSINESS_AREA_ID
     into ACstatusCode, l_business_area_id
     from ZPB_ANALYSIS_CYCLES
     where ANALYSIS_CYCLE_ID = Pacid;

    if instr(ACstatusCode, 'DISABLE') > 0 then

     -- Set the BP Status to Enable
       update ZPB_ANALYSIS_CYCLES
       set STATUS_CODE = 'ENABLE_TASK',
         LAST_UPDATED_BY =  fnd_global.USER_ID,
         LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       where ANALYSIS_CYCLE_ID = Pacid;
       commit;


       if ACstatusCode = 'DISABLE_ASAP' then

        --The type of enable determines what the status of disabled instances with active tasks
        --and the disabled instances with complete tasks should be updated to

        CodeToUpdateTo:='ACTIVE';

        if PStatus='ENABLE_TASK' then
                CodeToUpdateTo:='ACTIVE';
        end if;

        if PStatus='ENABLE_FIRST' then
                CodeToUpdateTo:='ENABLE_FIRST';
        end if;

        if PStatus='ENABLE_NEXT' then
                CodeToUpdateTo:='MARKED_FOR_DELETION';
        end if;

        -- Update active instances

        -- if updating to status ACTIVE, should in fact update to the
        -- previously saved status

        if CodeToUpdateTo = 'ACTIVE' then

                UPDATE zpb_analysis_cycles
                SET status_code=decode(prev_status_code, null, 'ACTIVE', prev_status_code)
                where analysis_cycle_id in

                (select distinct zac.analysis_cycle_id
                FROM  ZPB_ANALYSIS_CYCLE_INSTANCES zaci,
                      ZPB_ANALYSIS_CYCLE_TASKS zact,
                      ZPB_ANALYSIS_CYCLES zac
                WHERE zaci.analysis_cycle_id = Pacid and
                      zaci.instance_ac_id = zac.analysis_cycle_id and
                      zac.analysis_cycle_id = zact.analysis_cycle_id and
                      zac.status_code = 'DISABLE_ASAP' and
                      zact.status_code in ('ACTIVE', 'PENDING'));
        else
                UPDATE zpb_analysis_cycles
                SET status_code=CodeToUpdateTo
                where analysis_cycle_id in

                (select distinct zac.analysis_cycle_id
                FROM  ZPB_ANALYSIS_CYCLE_INSTANCES zaci,
                      ZPB_ANALYSIS_CYCLE_TASKS zact,
                      ZPB_ANALYSIS_CYCLES zac
                WHERE zaci.analysis_cycle_id = Pacid and
                      zaci.instance_ac_id = zac.analysis_cycle_id and
                      zac.analysis_cycle_id = zact.analysis_cycle_id and
                      zac.status_code = 'DISABLE_ASAP' and
                      zact.status_code in ('ACTIVE', 'PENDING'));
        end if;


       -- loop over instances with completetd tasks resume if enable choice is not enable next,
       -- if choice is enable next, mark for deletion and clean up instance
       -- 5867453 bkport of b5371156 new way to get params for setting context
       for v_owner_resp in c_owner_resp loop
            ownerID := v_owner_resp.owner_id;
            respID :=v_owner_resp.resp_id;
            exit;
        end loop;
        -- always EPB
        respAppID := 210;

        -- Set the context before calling submit_request
        fnd_global.apps_initialize(ownerID, respID, RespAppId);

        for  v_instance in c_instance loop

           InstanceID := v_instance.ANALYSIS_CYCLE_ID;

           -- If enable_asap we resume the instance from the left-on task
           -- The associated AW measure for the instance is unchanged
           if PStatus = 'ENABLE_TASK' then
                zpb_wf.resume_instance(InstanceID);
           end if;

           -- If enable first we restart the instance from its first task
           -- we also set the context and submit a CM request that will
           -- clean out the AW measure for the instance and recreate it again
           if PStatus = 'ENABLE_FIRST' then

                -- for monitor page display set stauts to enable_first here
                -- it will get reset to active once instance restarts
                update zpb_analysis_cycles
                       set status_code='ENABLE_FIRST'
                       where analysis_cycle_id=InstanceID;

                l_REQID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_CLEANANDRESTARTINST', NULL, NULL, FALSE, Pacid, InstanceID, l_business_area_id);
           end if;

           if PStatus = 'ENABLE_NEXT' then
                -- In the case of Enabling Next, Both active and inactive instances should be set to MARKED_FOR_DELETION
                update zpb_analysis_cycles
                set status_code='MARKED_FOR_DELETION'
                where analysis_cycle_id=InstanceID;

                -- clean the measure
                l_REQID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_WF_DELAWINST', NULL, NULL, FALSE, InstanceID, ownerID, l_business_area_id);
           end if;
        end loop;
      end if;

     -- if this BP has schedule frequency type = ONE_TIME_ONLY, we should create an instance immeditely,
     -- if no active instances exist.  To do so, we restart the scheduler for the BP

        begin

        select pva.value into freqType
        from zpb_ac_param_values pva,
             fnd_lookup_values_vl pna
        where pna.lookup_code='CALENDAR_FREQUENCY_TYPE'
              and pna.tag = pva.param_id and
              pna.lookup_type = 'ZPB_PARAMS' and
              pva.analysis_cycle_id=Pacid;

        exception
             when NO_DATA_FOUND then
                    freqType:='NOT_FOUND';
        end;

        --  BUG 4291814 - WORKFLOW COMPONENTS: START BP EXTERNALLY
		--  BUG 4496397 - Only kick off new instace in One-Time-Only and Enable
        --                    from next run case
        if (freqType='ONE_TIME_ONLY' and PStatus='ENABLE_NEXT') or freqType= 'EXTERNAL_EVENT' then
             zpb_wf.ACStart(Pacid,'Y');
        end if;


     end if; -- outermost

   commit;
   return;

   exception
   when NO_DATA_FOUND then
         Null;

     when others then
      raise;

end ENABLE_CYCLE;

procedure INIT_BUSINESS_PROCESS (ACID in Number,
          InstanceID in Number,
          TaskID in Number,
          UserID in Number)
   IS
      attached   varchar2(1) := 'N';
      thisCount  number;
      returnStat varchar2(1000);
      msgData    varchar2(1000);
BEGIN

   select count(wf_process_name)
      into thisCount
      from zpb_analysis_cycle_tasks
      where analysis_cycle_id = InstanceID and
      wf_process_name in ('LOAD_DATA', 'GENERATE_TEMPLATE', 'DISTRIBUTE_TEMPLATE', 'SOLVE', 'MANAGE_SUBMISSION');

   if thisCount > 0 then  -- build phys model

	 -- set olap page pool size based on ZPB_OPPS_AW_BUILD profile setting
	 zpb_util_pvt.set_opps(ZPB_UTIL_PVT.ZPB_OPPS_AW_BUILD, UserID);

     --log START Generate Physical Model
     FND_MESSAGE.SET_NAME('ZPB', 'ZPB_WF_GENPHYS_START');
     FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

     ZPB_AW.INITIALIZE_FOR_AC (p_api_version       => 1.0,
                               p_init_msg_list     => FND_API.G_TRUE,
                               x_return_status     => returnStat,
                               x_msg_count         => thisCount,
                               x_msg_data          => msgData,
                               p_analysis_cycle_id => InstanceID,
                               p_shared_rw         => FND_API.G_TRUE);
      -- Test run of solve
     attached := 'Y';

     ZPB_GEN_PHYS_MODEL.GEN_PHYSICAL_MODEL(InstanceID);

     ZPB_AW.DETACH_ALL;
     attached := 'N';

     --log END Generate Physical Model has completed
     FND_MESSAGE.SET_NAME('ZPB', 'ZPB_WF_GENPHYS_END');
     FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

     -- NEW CALL to intialize process run data for instance
     ZPB_WF.INIT_PROC_RUN_DATA  (ACID, InstanceID, TaskID, UserID);

   end if;
   return;

   exception
      when others then

         --log Generate Physical Model has errored
         FND_MESSAGE.SET_NAME('ZPB', 'ZPB_WF_GENPHYS_ERROR');
         FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

         if attached = 'Y' then
            ZPB_AW.DETACH_ALL;
         end if;

         -- update zpb instance info with ERROR
         UPDATE_STATUS('ERROR', Instanceid);
         raise;
end INIT_BUSINESS_PROCESS;

procedure RUN_SOLVE (errbuf out nocopy varchar2,
                     retcode out nocopy varchar2,
                     InstanceID in Number,
                     TaskID in Number,
                     UserID in Number,
                     P_BUSINESS_AREA_ID in number)
   IS

   attached   varchar2(1) := 'N';
   l_dbname   varchar2(150);
   l_count    number;

BEGIN

  retcode := '0';

  -- set olap page pool size based on ZPB_OPPS_DATA_SOLVE profile setting
  zpb_util_pvt.set_opps(ZPB_UTIL_PVT.ZPB_OPPS_DATA_SOLVE, UserID);

  -- Test run of solve
  ZPB_AW.INITIALIZE_FOR_AC (p_api_version       => 1.0,
                            p_init_msg_list     => FND_API.G_TRUE,
                            x_return_status     => retcode,
                            x_msg_count         => l_count,
                            x_msg_data          => errbuf,
                            p_analysis_cycle_id => InstanceID,
                            p_shared_rw         => FND_API.G_TRUE);
  attached := 'Y';

  l_dbname := ZPB_AW.GET_SCHEMA || '.' || ZPB_AW.GET_SHARED_AW;
  ZPB_AW.EXECUTE('APPS_USER_ID = ''' || TO_CHAR(UserID) || '''');

  -- b 5170327 intializes the pv_status variable
  ZPB_ERROR_HANDLER.INIT_CONC_REQ_STATUS;
  ZPB_AW.EXECUTE('call SV.RUN.SOLVE(''' || l_dbname || ''', ''' || TO_CHAR(Instanceid) || ''', ''' || TO_CHAR(taskid) || ''')');
  -- b 5170327 - retcode is an OUT parameter conc program standard - 0=success, 1=warning or 2=error.
  retcode := ZPB_ERROR_HANDLER.GET_CONC_REQ_STATUS;

  -- update
  ZPB_AW.EXECUTE('upd');
  commit;

  ZPB_AW.DETACH_ALL;
  attached := 'N';

  --log solve OK
  FND_MESSAGE.SET_NAME('ZPB', 'ZPB_WF_SOLVEOK');
  FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

   return;

  exception

   when others then
    retcode :='2';

    if attached = 'Y' then
       ZPB_AW.DETACH_ALL;
    end if;

    --log solve OK
    FND_MESSAGE.SET_NAME('ZPB', 'ZPB_WF_SOLVE_NOTOK');
    FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);
    errbuf:=substr(sqlerrm, 1, 255);

    -- update zpb instance info with ERROR
    UPDATE_STATUS('ERROR', Instanceid, taskid, UserID);

end RUN_SOLVE;


procedure UPDATE_STATUS (p_type in varchar2,
                        p_InstanceID in Number default NULL,
                        p_TaskID in Number default NULL,
                        p_UserID in Number default NULL)
   IS


   l_InstanceID number;
   instance_status varchar2(30);
   l_REQID number;
   ownerID number;
   ACID number;
   l_business_area_id number;

   respIDW number := fnd_global.RESP_ID;
   respAppID number := fnd_global.RESP_APPL_ID;
   ItemType     varchar2(8) := 'ZPBSCHED';
   ItemKey      varchar2(240);

   -- get RespId and RespAppId from params set on the workflow sched for this BP
   CURSOR c_wfItemKey is
         select /*+ FIRST_ROWS */ item_key
         from WF_ITEM_ATTRIBUTE_VALUES
         where item_type = 'ZPBSCHED'
         and   name = 'ACID'
         and   number_value = ACID;
   v_wfItemKey c_wfItemKey%ROWTYPE;

   -- can also get RespId and RespAppId by simply selecting first ones found for owner of BP
   CURSOR c_respFromOwner is
        select /*+ FIRST_ROWS */ responsibility_id, responsibility_application_id
        from fnd_user_resp_groups
        where user_id=ownerID;
   v_respFromOwner c_respFromOwner%ROWTYPE;


   BEGIN

   begin

    select status_code, published_by into instance_status, ownerID
    from   zpb_analysis_cycles
    where  analysis_cycle_id=p_InstanceID;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        instance_status:='NotMarkedForDelete';

   end;

   -- If instance has been marked for deletion and last task
   -- errors out, keep instancein MARKED_FOR_DELETE status
   -- and clean up its AW measure
   if instance_status='MARKED_FOR_DELETION' then

      -- abudnik 17NOV2005 BUSINESS AREA ID.
      select ANALYSIS_CYCLE_ID into ACID
        from ZPB_ANALYSIS_CYCLE_INSTANCES
        where INSTANCE_AC_ID = p_InstanceID;

       select BUSINESS_AREA_ID
          into l_business_area_id
          from ZPB_ANALYSIS_CYCLES
          where ANALYSIS_CYCLE_ID = ACId;

       -- abudnik 17NOV2005 BUSINESS AREA ID.
       l_REQID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_WF_DELAWINST', NULL, NULL, FALSE, p_InstanceID, ownerID, l_business_area_id);
       return;
   end if;


   if p_TaskID is NOT NULL  then

     update zpb_analysis_cycle_tasks
       set status_code = p_type,
         LAST_UPDATED_BY =  fnd_global.USER_ID,
         LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       where task_id = p_TaskID;
   else

     if p_instanceID is NULL then
       -- return 'NOINFO';
         return;
      end if;

   end if;



   if p_instanceID is NOT NULL then

    update zpb_ANALYSIS_CYCLES
     set status_code = p_type,
     LAST_UPDATED_BY =  fnd_global.USER_ID,
     LAST_UPDATE_DATE = SYSDATE,
     LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
     where ANALYSIS_CYCLE_ID = p_InstanceID;

     update zpb_analysis_cycle_instances
     set last_update_date = sysdate,
     LAST_UPDATED_BY =  fnd_global.USER_ID,
     LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
     where instance_ac_id = p_InstanceID;


   else

    if p_TaskID is NOT NULL then
      select distinct ANALYSIS_CYCLE_ID into l_InstanceID
      from zpb_analysis_cycle_tasks
      where task_id = p_TaskID;

     update zpb_ANALYSIS_CYCLES
      set status_code = p_type,
      LAST_UPDATED_BY =  fnd_global.USER_ID,
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
      where ANALYSIS_CYCLE_ID = l_InstanceID;

     update zpb_analysis_cycle_instances
     set last_update_date = sysdate,
     LAST_UPDATED_BY =  fnd_global.USER_ID,
     LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
     where instance_ac_id = l_InstanceID;


    end if;

   end if;

-- if updated the status to ERROR, should check to see if any instances of this BP now need to be cleaned up
if p_type='ERROR' then

      select ANALYSIS_CYCLE_ID into ACID
      from ZPB_ANALYSIS_CYCLE_INSTANCES
      where INSTANCE_AC_ID = p_InstanceID;

      ItemKey:='NOT_FOUND';

      for v_wfItemKey in c_wfItemKey loop
          ItemKey:=v_wfItemKey.item_key;
      end loop;

      -- try to get RespId and RespAppId from Scheduler workflow for this BP
      -- if that fails, get any RespId and RespAppId for BP owner
      if ItemKey<>'NOT_FOUND' and ItemKey<>null and ItemKey<>' 'then

              respIDW := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPID');

              respAppID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPAPPID');

      else

              for v_respFromOwner in c_respFromOwner loop
                  respIDW:=v_respFromOwner.responsibility_id;
                  respAppID := v_respFromOwner.responsibility_application_id;
                  exit;
              end loop;

      end if;

   -- This call will clean up as many COMPLETED/ERRORED instances
   -- as determined by the Number of Processes Stored BP option
   MarkforDelete(ACID, ownerID, respIDW, RespAppID);

   commit;
end if;



  --  return 'DONE';
    return;

  exception
   when others then
     raise;

end UPDATE_STATUS;


--
-- Kicks off a CM to submit data up to the shared
--
procedure SUBMIT_TO_SHARED (p_user       in number,
                            p_templateID in number,
                            p_retVal     out nocopy number)
   is
      l_business_area_id  number;
begin
   select distinct A.BUSINESS_AREA_ID
      into l_business_area_id
      from ZPB_ANALYSIS_CYCLES A,
         ZPB_DC_OBJECTS B
      where B.AC_INSTANCE_ID = A.ANALYSIS_CYCLE_ID
      and B.TEMPLATE_ID = p_templateID;

   ZPB_AW_WRITE_BACK.SUBMIT_WRITEBACK_REQUEST
      (l_business_area_id,
       p_user,
       FND_GLOBAL.RESP_ID,
       FND_GLOBAL.SESSION_ID,
       'SPL',
       'CALL PA.ATTACH.PERSONAL('''||p_user||''' ''ro'');'||
           'CALL DC.SUBMIT.DRIVER(''ACCEPT'' ''-100'' '''||p_user||''' '''||
           p_templateID||''')',
       sysdate,
       p_retVal);
end SUBMIT_TO_SHARED;

--
-- copies old instance of data to the new instance
--
procedure INIT_PROC_RUN_DATA  (ACID in Number,
                        InstanceID in Number,
                        TaskID in Number,
                        UserID in Number)
   IS
      attached   varchar2(1) := 'N';
      l_count    number;
      l_dbname   varchar2(150);
      retcode    varchar2(100);
      msgData    varchar2(1000);
BEGIN

  --  retcode := '0';

  --log Initialization of Business Process Run data has started
  FND_MESSAGE.SET_NAME('ZPB', 'ZPB_WF_INIT_DATA_START');
  FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

  ZPB_AW.INITIALIZE_FOR_AC (p_api_version       => 1.0,
                            p_init_msg_list     => FND_API.G_TRUE,
                            x_return_status     => retcode,
                            x_msg_count         => l_count,
                            x_msg_data          => msgData,
                            p_analysis_cycle_id => InstanceID,
                            p_shared_rw         => FND_API.G_TRUE);

  l_dbname := ZPB_AW.GET_SCHEMA || '.' || ZPB_AW.GET_SHARED_AW;
  attached := 'Y';


   ZPB_AW.EXECUTE('call in.run.init(''' || l_dbname || ''',  ''' || TO_CHAR(ACID) || ''',  ''' || TO_CHAR(taskid) || ''', ''' || TO_CHAR(Instanceid) || ''')');

  -- update
  ZPB_AW.EXECUTE('upd');
  commit;

  ZPB_AW.DETACH_ALL;
  attached := 'N';

  --log Initialization of Business Process Run data has completed
  FND_MESSAGE.SET_NAME('ZPB', 'ZPB_WF_INIT_DATA_END');
  FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

  return;

  exception
   when others then
    -- retcode :='2';

    if attached = 'Y' then
       ZPB_AW.DETACH_ALL;
    end if;

    --log Initialization of Business Process Run data encountered an error
    FND_MESSAGE.SET_NAME('ZPB', 'ZPB_WF_INIT_DATA_ERROR');
    FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);
    -- errbuf:=substr(sqlerrm, 1, 255);

    -- update zpb instance info with ERROR
    UPDATE_STATUS('ERROR', Instanceid);
    raise;

end INIT_PROC_RUN_DATA;


procedure WF_DELAWINST (errbuf out nocopy varchar2,
                        retcode out nocopy varchar2,
                        InstanceID in Number,
                        UserID in Number,
                        P_BUSINESS_AREA_ID in Number)
   IS
      attached   varchar2(1) := 'N';
      l_count    number;
      --Bug - 5126892: Change start
      instanceDesc  ZPB_ANALYSIS_CYCLE_INSTANCES.INSTANCE_DESCRIPTION%type;
      --Bug - 5126892: Change end
BEGIN

  retcode := '0';

 --log DEL INST OK
  FND_MESSAGE.SET_NAME('ZPB', 'ZPB_WF_BEGDELINST');
  FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

  delete from zpb_measures
  where instance_id = InstanceID;

  ZPB_AW.INITIALIZE_FOR_AC (p_api_version       => 1.0,
                            p_init_msg_list     => FND_API.G_TRUE,
                            x_return_status     => retcode,
                            x_msg_count         => l_count,
                            x_msg_data          => errbuf,
                            p_analysis_cycle_id => InstanceID,
                            p_shared_rw         => FND_API.G_TRUE,
                            p_annot_rw          => FND_API.G_TRUE);
  attached := 'Y';

  ZPB_AW.EXECUTE('call cm.delshinsts(''' || TO_CHAR(Instanceid) || ''')');

  --Bug - 5126892: Change start

  -- Bug: 5753320
  -- Handled the no_data_found exception
  Begin
    select instance_description
      into instanceDesc from zpb_analysis_cycle_instances
      where instance_ac_id = Instanceid;
  exception
    when no_data_found then
      instanceDesc := '-99-';
  end;

  -- Bug: 5753320
  -- If there was no record in zpb_analysis_cycle_instances,
  -- it means that the instance already got deleted.
  -- So, do not call calc.validate
  if (instanceDesc <> '-99-') then
    ZPB_AW.EXECUTE('call calc.validate(false,'''||To_CHAR(instanceDesc)||''',''' || TO_CHAR(UserID) || ''','''||'View'||''')');
  end if;
  --Bug - 5126892: Change end

  -- update
  ZPB_AW.EXECUTE('upd');
  commit;

  ZPB_AW.DETACH_ALL;
  attached := 'N';

 --log DEL INST OK
  FND_MESSAGE.SET_NAME('ZPB', 'ZPB_WF_ENDDELINST');
  FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

   return;

  exception

   when others then
    retcode :='2';

    if attached = 'Y' then
       ZPB_AW.DETACH_ALL;
    end if;

    --log DEL INST ERR
    FND_MESSAGE.SET_NAME('ZPB', 'ZPB_WF_ERRDELINST');
    FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);
    errbuf:=substr(sqlerrm, 1, 255);

    -- do not update zpb instance info with ERROR from this procedure
    -- as this would cause another DELAWISNT CM request causing
    -- an infinite loop

end WF_DELAWINST;

--
-- calls abortWorkflow with 'A' acid argument
--
Procedure CallWFAbort(inACID in number)

  is

  thisInst number;
  retcode  varchar2(2);
  errbuf   varchar2(100);

 BEGIN

   -- find all workflows for this ACID or instance, abort.
   ZPB_WF.abortWorkflow(errbuf, retcode, inACID, 'A');

 return;

 exception

   when others then
     RAISE_APPLICATION_ERROR(-20100, 'Error in ZPB_WF.CallWFABORT');

end CallWFAbort;

procedure AbortWorkflow (errbuf out nocopy varchar2,
                        retcode out nocopy varchar2,
                        inACID in Number,
                        ACIDType in varchar2 default 'A')
   IS
    --ItemType   varchar2(20);
    AttrName   varchar2(30);
    CurrStatus varchar2(20);
    result     varchar2(100);

    CURSOR c_ItemKeys is
        select item_type, item_key
           from WF_ITEM_ATTRIBUTE_VALUES
           where item_type = 'ZPBSCHED'
           and   name = AttrName
           and   number_value = inACID;

    v_ItemKey c_ItemKeys%ROWTYPE;

BEGIN

    retcode := '0';

   if ACIDType = 'I' then
      AttrName := 'INSTANCEID';
   else
      AttrName := 'ACID';
   end if;

-- Check activity process for current plan
-- 04/23/03 agb ZPBSCHED  support for many item types
    for  v_ItemKey in c_ItemKeys loop

         wf_engine.ItemStatus(v_ItemKey.item_type, v_ItemKey.item_key, currStatus, result);

         if UPPER(RTRIM(currStatus)) = 'ERROR' or UPPER(RTRIM(currStatus)) = 'ACTIVE' then
            WF_ENGINE.AbortProcess(v_ItemKey.item_Type, v_ItemKey.item_key);
         end if;

      end loop;
      return;

  exception

   when NO_DATA_FOUND then
     retcode :='0';
   when others then
    retcode :='2';
    errbuf:=substr(sqlerrm, 1, 255);
--     raise;

end AbortWorkflow;


--
-- If BP has no active instances and no completed instances, deletes CurrentInstance measure from AW
-- If BP has no active instances and some completed instances, resets CurrentInstance measure to last started instance
-- If BP has active instances does nothing
--
procedure DeleteCurrInstMeas (ACId  in number,
                              ownerId in number)
IS

activeInstances number;
completedInstances number;
currInstanceId number;
currInstExistsCnt number;
lastCompleted number;
sessionid number;
DLcmd varchar2(100);
P_OUTVAL number;
l_REQID number;
respID number := fnd_global.RESP_ID;
ACStatusCode varchar2(30);
respIDW number := fnd_global.RESP_ID;
respAppID number := fnd_global.RESP_APPL_ID;
ItemType     varchar2(8) := 'ZPBSCHED';
ItemKey      varchar2(240);
l_business_area_id number;

   -- Need itemKey for ACID to get variables to set context before
   -- calling SUBMIT_REQUEST
   CURSOR c_wfItemKey is
         select /*+ FIRST_ROWS */ item_key
         from WF_ITEM_ATTRIBUTE_VALUES
         where item_type = 'ZPBSCHED'
         and   name = 'ACID'
         and   number_value = ACId;
   v_wfItemKey c_wfItemKey%ROWTYPE;

   -- can also get RespId and RespAppId by simply selecting first ones found for owner of BP
   CURSOR c_respFromOwner is
        select /*+ FIRST_ROWS */ responsibility_id, responsibility_application_id
        from fnd_user_resp_groups
        where user_id=ownerId;
   v_respFromOwner c_respFromOwner%ROWTYPE;

begin

        begin

        -- abudnik 17NOV2005 BUSINESS AREA ID
        select status_code, BUSINESS_AREA_ID
        into ACStatusCode, l_business_area_id
        from   zpb_analysis_cycles
        where analysis_cycle_id = ACId;

         EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        ACStatusCode:='Do Not Delete';
          end;

        -- If the BP definition itself is not marked for deletion
        -- do not remove the Current Instance Measure
        if ACStatusCode<>'MARKED_FOR_DELETION' then
                return;
        end if;

		-- If the BP has never had a Set Current Instance task and therefore
		-- does not have a Current Instance, do not attempt to remove the
		-- non-existent current instance
		begin
			select current_instance_id into currInstanceId
            from zpb_analysis_cycles
            where analysis_cycle_id = ACId;

		    select count(*) into currInstExistsCnt
       		from zpb_measures
       		where instance_id = currInstanceId;

			if currInstExistsCnt = 0 then
				return;
			end if;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
         	   return;
		end;

        select count(*) into activeInstances
        FROM ZPB_ANALYSIS_CYCLE_INSTANCES zaci,
             ZPB_ANALYSIS_CYCLE_TASKS zact,
             ZPB_ANALYSIS_CYCLES zac
        WHERE zaci.analysis_cycle_id = ACId and
              zaci.instance_ac_id = zac.analysis_cycle_id and
              zac.analysis_cycle_id = zact.analysis_cycle_id and
              zact.status_code in ('ACTIVE', 'PENDING');

        -- if no active instances for this BP then can delete/reassign the CurrentInstance measure
        -- otherwise we are done here
        IF activeInstances=0 THEN

          begin

          SELECT zac2.analysis_cycle_id into lastCompleted
          FROM ZPB_ANALYSIS_CYCLE_INSTANCES zaci2,
               ZPB_ANALYSIS_CYCLE_TASKS zact2,
               ZPB_ANALYSIS_CYCLES zac2
          WHERE zaci2.analysis_cycle_id = ACId and
                zaci2.instance_ac_id = zac2.analysis_cycle_id and
                zac2.analysis_cycle_id = zact2.analysis_cycle_id and
                zact2.wf_process_name='SET_CURRENT_INSTANCE' and
                zac2.status_code in ('COMPLETE', 'COMPLETE_WITH_WARNING') and
                zact2.last_update_date =
                        (SELECT max(zact.last_update_date)
                        FROM ZPB_ANALYSIS_CYCLE_INSTANCES zaci,
                             ZPB_ANALYSIS_CYCLE_TASKS zact,
                             ZPB_ANALYSIS_CYCLES zac
                        WHERE zaci.analysis_cycle_id = ACId and
                              zaci.instance_ac_id = zac.analysis_cycle_id and
                              zac.analysis_cycle_id = zact.analysis_cycle_id and
                              zact.wf_process_name='SET_CURRENT_INSTANCE' and
                              zac.status_code in ('COMPLETE', 'COMPLETE_WITH_WARNING'));


                completedInstances:=1;

          EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        completedInstances:=0;
          end;

          IF lastCompleted IS NULL THEN
                completedInstances:=0;
          END IF;

          -- if there are no completed instances, then delete the CurrentInstance measure
          -- otherwise re-set the CurrentInstance measure to the completed instance that started last, via CM request
          IF completedInstances=0 THEN

                begin

                -- attemp to retrieve responsibility Id and responsibility App Id from BP Scheduler
                -- if BP Scheduler no longer exists, get any responsibility Id and responsibility App Id
                -- for the owner of this BP and submit the request
                ItemKey:='NOT_INITIALIZED';

                for v_wfItemKey in c_wfItemKey loop
                        ItemKey:=v_wfItemKey.item_key;
                end loop;

                if ItemKey<>'NOT_INITIALIZED' and ItemKey<>null and ItemKey<>' ' then

                        respIDW := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                               Itemkey => ItemKey,
                               aname => 'RESPID');

                        respAppID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                               Itemkey => ItemKey,
                               aname => 'RESPAPPID');
                else

                      for v_respFromOwner in c_respFromOwner loop
                          respIDW:=v_respFromOwner.responsibility_id;
                          respAppID := v_respFromOwner.responsibility_application_id;
                          exit;
                      end loop;
                end if;


               -- Set context before calling SUBMIT_REQUEST
               fnd_global.apps_initialize(ownerID, respIDW, RespAppID);

                -- abudnik 17NOV2005 BUSINESS AREA ID
                l_REQID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_WF_DELAWINST', NULL, NULL, FALSE, currInstanceId, ownerID, l_business_area_id);

                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                        NULL;
                end;

          ELSE
            -- there are completed instance, must reset CurrentInstance measure to last started instance

             sessionid := userenv('SESSIONID');
             DLcmd := 'call CM.SETCURRINST ('''||lastCompleted||''' '''||
                ACId||''')';

             select BUSINESS_AREA_ID
                into l_business_area_id
                from ZPB_ANALYSIS_CYCLES
                where ANALYSIS_CYCLE_ID = ACId;

             -- change agb to dbdata.
             ZPB_AW_WRITE_BACK.SUBMIT_WRITEBACK_REQUEST(l_business_area_id,
                                                        ownerID,
                                                        respID,
                                                        sessionID,
                                                        'SPL',
                                                        DLcmd,
                                                        NULL,
                                                        P_OUTVAL);

          END IF;
        END IF;

exception
  when others then
        null;

end DeleteCurrInstMeas;


-- This procedure is called by a CM program.  For instance P_InstanceId of BP P_ACId
-- it first deletes the AW measure associted with the instance, it then recreates and
-- initializes the AW measure.  Used when enabling BPs ENABLE_FIRST
procedure CleanAndRestartInst (errbuf out nocopy varchar2,
                               retcode out nocopy varchar2,
                               P_ACId  in number,
                               P_InstanceId in number,
                               P_BUSINESS_AREA_ID in number)

IS

ownerID number;
errbufReturned varchar2(100);
retCodeReturned varchar2(100);
TaskId number;

begin

  begin

        select published_by into ownerID
        from zpb_analysis_cycles
        where analysis_cycle_id = P_ACId;


        -- First delete the associated AW measure
        WF_DELAWINST (errbuf => errbufReturned,
                      retcode => retCodeReturned,
                      InstanceID => P_InstanceId,
                      UserID => ownerID,
                      P_BUSINESS_AREA_ID => P_BUSINESS_AREA_ID);


             select TASK_ID
                    into TaskId
                    from zpb_analysis_cycle_tasks
                    where ANALYSIS_CYCLE_ID = P_InstanceId and Sequence = 1;

        -- b 5170327 intializes the pv_status variable
        ZPB_ERROR_HANDLER.INIT_CONC_REQ_STATUS;

        -- Now initialize the instance, this will recreate the AW measure for it
        INIT_BUSINESS_PROCESS (ACID => P_ACId,
                  InstanceID => P_InstanceId,
                  TaskID => TaskId,
                  UserID => ownerID);


        -- Resume the instance from the first task
        RESUME_INSTANCE (InstanceID => P_InstanceId,
                         PResumeType => 'RUN_FROM_TOP');

        -- b 5170327 - retcode is an OUT parameter conc program standard - 0=success, 1=warning or 2=error.
        retcode := ZPB_ERROR_HANDLER.GET_CONC_REQ_STATUS;

        errbuf:=' ';

        exception
             when NO_DATA_FOUND then
                    retcode:=2;
                    errbuf:='No Data Found';
        end;

end CleanAndRestartInst;

-- API to start task for instance for migration only.

procedure RUN_MIGRATE_INST (p_InstanceID        in  NUMBER,
                            p_api_version       IN  NUMBER,
                            p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
                            p_commit            IN  VARCHAR2 := FND_API.G_TRUE,
                            p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                            x_return_status     OUT nocopy varchar2,
                            x_msg_count         OUT nocopy number,
                            x_msg_data          OUT nocopy varchar2)

   IS

    l_api_name      CONSTANT VARCHAR2(30) := 'RUN_MIGRATE_INST';
    l_api_version   CONSTANT NUMBER       := 1.0;


    CurrtaskSeq number;
    ITEMTYPE varchar(8);
    ACID number;
    ACNAME varchar2(300);
    InstanceStatusCode varchar2(30);
    InPrevStatusCode varchar2(30);
    TaskID number;
    owner  varchar2(30);
    ownerID number;
    respID number;
    respAppID number;
    charDate varchar2(30);
    newitemkey varchar2(240);
    workflowprocess varchar2(30);
    retcode number;

    CURSOR c_tasks is
      select *
      from zpb_analysis_cycle_tasks
      where ANALYSIS_CYCLE_ID = p_InstanceID
      and Sequence = 1;
    v_tasks c_Tasks%ROWTYPE;

-- This needs to

   BEGIN


  -- Standard Start of API savepoint
   SAVEPOINT zpb_request_explanation;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


    begin

    select status_code, prev_status_code
    into InstanceStatusCode, InPrevStatusCode
    from zpb_analysis_cycles
    where analysis_cycle_id = p_InstanceID;

    EXCEPTION
     WHEN NO_DATA_FOUND THEN
        InstanceStatusCode:='ISCNotFound';
        InPrevStatusCode:='ACTIVE';
    end;


     if InstanceStatusCode = 'ISCNotFound'  then
           x_msg_count := 1;
           x_msg_data := 'No Instance ws found for this Business Process.';
            -- Standard call to get message count and if count is 1, get message info.
           FND_MSG_PUB.Count_And_Get(
                p_count =>  x_msg_count,
                p_data  =>  x_msg_data );

        -- DBMS_OUTPUT.PUT_LINE('No Instance ws found for this Business Process.');
        return;
     end if;

     if InstanceStatusCode = 'ACTIVE' then
           x_msg_count := 1;
           x_msg_data := 'The instance of this Business Process is currently running.  Instance: ' || p_InstanceID ;
            -- Standard call to get message count and if count is 1, get message info.
           FND_MSG_PUB.Count_And_Get(
                p_count =>  x_msg_count,
                p_data  =>  x_msg_data );

        -- DBMS_OUTPUT.PUT_LINE('The instance of this Business Process is currently running.  Instance: ' || p_InstanceID);
        return;
     end if;

    -- get base parmameters from last completed task and itemkey.
    -- AGB MIGRATION  Get ACID and Analysis Cycle name

     CurrtaskSeq := 0;
     ITEMTYPE := 'EPBCYCLE';

     -- get ACID ACNAME and ownerid
     select ANALYSIS_CYCLE_ID into ACID
      from ZPB_ANALYSIS_CYCLE_INSTANCES
      where INSTANCE_AC_ID = p_InstanceID;

     select NAME, CREATED_BY into ACNAME, ownerID
      from ZPB_ANALYSIS_CYCLES
      where ANALYSIS_CYCLE_ID = ACID;

     -- Converted from zpb_analysis_cycles select above
     Owner := ZPB_WF_NTF.ID_to_FNDUser(OwnerID);

     -- Using ZPB_CONTROLLER_RESP as the source for this
     select RESPONSIBILITY_ID
      into respID
      from fnd_responsibility_vl
      where APPLICATION_ID = 210 and RESPONSIBILITY_KEY = 'ZPB_CONTROLLER_RESP';

      respAppID := 210;   -- Hard coded for zpb

     if InPrevStatusCode is null then
        InPrevStatusCode:='ACTIVE';
     end if;

     -- if the status of the instance to be resumed is PAUSING
     -- all we need to do is set the status to previous status code
 /*
     if InstanceStatusCode = 'PAUSING' then
        update zpb_analysis_cycles
        set status_code= InPrevStatusCode
        where analysis_cycle_id = p_InstanceID;
        commit;
        return;
      end if;
*/

    --  Get next task [wf process] to run If none COMPLETE
    workflowprocess := 'NONE';
    TaskID := NULL;

    for  v_Tasks in c_Tasks loop
         TaskID := v_Tasks.TASK_ID;
         workflowprocess := v_Tasks.wf_process_name;
    end loop;

    -- LAST TASK FOR THIS INSTANCE
    if workflowprocess = 'NONE' then

       update zpb_ANALYSIS_CYCLES
       set status_code = 'ERROR',
         LAST_UPDATED_BY =  fnd_global.USER_ID,
         LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       where ANALYSIS_CYCLE_ID = p_InstanceID;

       update zpb_analysis_cycle_instances
       set last_update_date = sysdate,
         LAST_UPDATED_BY =  fnd_global.USER_ID,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
       where instance_ac_id = p_InstanceID;

       -- Mark for delete
       -- zpb_wf.markfordelete(ACID, ownerID, respID, respAppID);

           x_msg_count := 1;
           x_msg_data := 'The Data Load task was missing the WF Process Name for this Business Process.';
            -- Standard call to get message count and if count is 1, get message info.
           FND_MSG_PUB.Count_And_Get(
                p_count =>  x_msg_count,
                p_data  =>  x_msg_data );

       -- DBMS_OUTPUT.PUT_LINE('The Data Load task was not found for this Instance of the Business Process.');
       return;
    end if;


  -- Set item key and date
  charDate := to_char(sysdate, 'MM/DD/YYYY-HH24-MI-SS');
  newitemkey := rtrim(substr(ACName, 1, 50), ' ') || '-' || to_char(p_InstanceID) || '-' || workflowprocess || '-' || charDate;


-- Create WF start process instance
   wf_engine.CreateProcess(ItemType => ItemType,
                         itemKey => newItemKey,
                         process => WorkflowProcess);

-- This should be the EPB controller.
   wf_engine.SetItemOwner(ItemType => ItemType,
                           ItemKey => NEWItemKey,
                           owner => owner);

-- Set current value of Taskseq [not sure if it is always 1 might be for startup]
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'TASKSEQ',
                           avalue => CurrtaskSeq+1);

-- set globals for new key???

-- set Cycle ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'ACID',
                           avalue => ACID);

-- set workflow with Instance Cycle ID!
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'INSTANCEID',
                           avalue => p_InstanceID);

-- set cycle Name!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'ACNAME',
                           avalue => ACNAME);
-- set Task ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'TASKID',
                           avalue => TaskID);

-- set owner name attr!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'FNDUSERNAM',
                           avalue => owner);

-- set EPBPerformer to owner name for notifications!
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'EPBPERFORMER',
                           avalue => owner);


-- will get error notifications
  wf_engine.SetItemAttrText(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'WF_ADMINISTRATOR',
                           avalue => owner);

-- set owner ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'OWNERID',
                           avalue => ownerID);

-- set resp ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'RESPID',
                           avalue => respID);

-- set resp ID!
  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => newItemKey,
                           aname => 'RESPAPPID',
                           avalue => respAppID);




-- Now that all is created and set START the PROCESS!
   wf_engine.StartProcess(ItemType => ItemType,
                          ItemKey => newItemKey);

   update zpb_analysis_cycle_tasks
   set item_KEY = newitemkey,
   Start_date = to_Date(charDate,'MM/DD/YYYY-HH24-MI-SS'),
   status_code = 'ACTIVE',
   LAST_UPDATED_BY =  fnd_global.USER_ID,
   LAST_UPDATE_DATE = SYSDATE,
   LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   where ANALYSIS_CYCLE_ID = p_InstanceID and task_id = TaskID;

   update ZPB_ANALYSIS_CYCLES
   set status_code = InPrevStatusCode,
   LAST_UPDATED_BY =  fnd_global.USER_ID,
   LAST_UPDATE_DATE = SYSDATE,
   LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   where ANALYSIS_CYCLE_ID = p_InstanceID;

   update zpb_analysis_cycle_instances
   set last_update_date = sysdate,
   LAST_UPDATED_BY =  fnd_global.USER_ID,
   LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
   where instance_ac_id = p_InstanceID;


  -- DBMS_OUTPUT.PUT_LINE('The Business Process Run has been started.');
  -- DBMS_OUTPUT.PUT_LINE('The Workflow ITEM_KEY is: ' || newitemkey);


  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
  );


  return;

 exception
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO zpb_request_explanation;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO zpb_request_explanation;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO zpb_request_explanation;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );


end RUN_MIGRATE_INST;

/*+=========================================================================+
  | REVIEW_NOTIF_RESPONCE
  |
  | This procedure does nothing functionally.
  | It is added just to get rid of the Validation warning in zpbcycle.wft
  | REVIEWNTF notification needs to have a PL/SQL function associated with it
  | for it to have 'Expand Roles' option checked.
  |
  | IN
  | itemtype  - A valid item type from WF_ITEM_TYPES table.
  | itemkey   - string generated as WF primary key.
  | actid     - An Activity ID.
  | funcmode  - The mode in which this procedure is called
  |
  | OUT
  | resultout - A result that can be returned.
  +========================================================================+
*/
procedure REVIEW_NOTIF_RESPONSE(itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out NOCOPY varchar2)
   IS
    result varchar2(24);

BEGIN
    if (funcmode = 'RUN') then
        result := wf_engine.GetItemAttrText(Itemtype => ItemType,
                   Itemkey => ItemKey,
                    aname => 'RESULT');

    	resultout := result;
    end if;
    if (funcmode = 'TIMEOUT') then
        resultout := wf_engine.eng_timedout;
    end if;
exception
    when others then
        WF_CORE.CONTEXT('ZPB_WF.REVIEW_NOTIF_RESPONSE', itemtype, itemkey, to_char(actid), funcmode);
        raise;
end REVIEW_NOTIF_RESPONSE;


-- A. Budnik 04/26/2006 b 3126256  SUBMIT_CONC_REQUEST
-- Implemented to submit concurrent programs from Workflow because WF EXECUTECONCPROG
-- does not commit for the concurrent request until the workflow process ends.

procedure SUBMIT_CONC_REQUEST (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2)
   IS

    l_ACID number;
    l_TaskID number;
    l_UserID number;
    l_respID number;
    l_InstanceID number;

    reqID number;
    l_business_area_id   number; -- abudnik 17NOV2005 BUSINESS AREA ID
    l_wfprocess varchar2(240);
    l_ActEntry  varchar2(30);

   BEGIN

      IF (funcmode = 'RUN') THEN
         resultout :='COMPLETE';


       l_ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'ACID');
       l_userID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'OWNERID');
       l_respID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPID');
       l_InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'INSTANCEID');
       l_business_area_id := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'BUSINESSAREAID');
       l_TaskID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'TASKID');


        select root_activity
         into l_wfprocess
         from wf_items_v
         where item_type = itemtype
         and item_KEY = itemkey;


        CASE l_wfprocess

          WHEN 'SET_VIEW_RESTRICTION' THEN

          --  reqID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_DVAC_TASK', NULL, NULL, FALSE, l_ACID, l_InstanceID, l_business_area_id);

          -- to add the task ID just uncomment this and comment the above call.
           reqID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_DVAC_TASK', NULL, NULL, FALSE, l_ACID, l_InstanceID, l_business_area_id, l_TaskID );

          WHEN 'EXCEPTION' THEN
              reqID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_RUN_EXCEPTION', NULL, NULL, FALSE, l_TaskID, l_userID);

          ELSE


          if substr(itemtype, 1, 8) = 'ZPBSCHED' THEN

             SELECT ACTIVITY_NAME INTO l_ActEntry
             FROM WF_PROCESS_ACTIVITIES
             WHERE INSTANCE_ID=actid;

              If  l_ActEntry =  'SUBMIT_CONC_REQUEST' then
                 reqID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_WF_INSTANCE', NULL, NULL, FALSE, itemkey, l_ACID, l_business_area_id);
                 --  l_ActEntry =  'EXECUTECONCPROG' then

              elsif l_ActEntry =  'VALIDATE_BP' then
                 -- procedure can be used by a new function activity for validate bp
                 reqID := FND_REQUEST.SUBMIT_REQUEST ('ZPB', 'ZPB_BP_VALIDATION_CP', NULL, NULL, FALSE, l_ACID, l_userID, l_respID, l_business_area_id);

              else
              reqID := -1;

              end if;

          end if;

        END CASE;


     wf_engine.SetItemAttrNumber(Itemtype => ItemType,
                           Itemkey => ItemKey,
                           aname => 'REQUEST_ID',
                           avalue => reqID);


   resultout :='COMPLETE';

 END IF;

 return;

 exception
   when others then
     Wf_Core.Context('ZPB_WF', 'SUBMIT_CONC_REQUEST', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;



END SUBMIT_CONC_REQUEST;


end ZPB_WF;


/
