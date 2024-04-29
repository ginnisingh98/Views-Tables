--------------------------------------------------------
--  DDL for Package Body MSDWF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSDWF" AS
/* $Header: msddpwfb.pls 115.17 2002/04/09 08:05:13 pkm ship     $ */

 express_server varchar2(240);
 DBName varchar2(80);
 CodeLoc varchar2(80);
 SharedLoc varchar2(80);
 PlName    varchar2(30);
 planID    varchar2(15);
 Owner     varchar2(30);
 DPAdmin   varchar2(30);
 FixedDate varchar2(30);
 g_owner varchar2(50) := ' ';
 Master       varchar2(1);   --agb 02/15/02 is ODP Master controling cycle

-- connects to OES and run programs in OES and gets values back.
PROCEDURE DOEXPRESS (itemtype in varchar2,
		  itemkey  in varchar2,
		  actid    in number,
		  funcmode in varchar2,
                  resultout   out varchar2)
   IS
    ActEntry     varchar2(16);
    ActRetCode    varchar2(2000);
    ActRetText   varchar2(2000);
    ActRetVal    varchar2(2000);
    ActRetErr    varchar2(2000);
    thisrole     varchar2(30);
    TempDate     date;
    TxtDate      varchar2(8);   -- agb 06/14/00 to deal with ambiguous date
    Process      varchar2(30);  -- agb 03/19/02 B2173260 added to wf.setactivity

   BEGIN
      IF (funcmode = 'RUN') THEN
         resultout :='COMPLETE:N';
       SELECT ACTIVITY_NAME, PROCESS_NAME INTO ActEntry, Process FROM WF_PROCESS_ACTIVITIES
         WHERE INSTANCE_ID=actid;
       SELECT TEXT_VALUE INTO thisrole FROM WF_ITEM_ATTRIBUTE_VALUES
          WHERE ITEM_KEY=itemkey AND ITEM_TYPE=itemtype AND NAME='ODPROLE';
       express_server:=wf_engine.GetItemAttrText(Itemtype => ItemType,
		       Itemkey => ItemKey,
              	       aname => 'EXPCONN');

       -- new to indicate if ODP Master is governing Cycle
       Master:=wf_engine.GetItemAttrText(Itemtype => ItemType,
		       Itemkey => ItemKey,
  		       aname => 'ISMASTER');

       DBName:=wf_engine.GetItemAttrText(Itemtype => ItemType,
		       Itemkey => ItemKey,
  		       aname => 'DBNAME');
       DPAdmin:=wf_engine.GetItemAttrText(Itemtype => ItemType,
		       Itemkey => ItemKey,
		       aname => 'DPADMIN');
       SharedLoc:=wf_engine.GetItemAttrText(Itemtype => ItemType,
	               Itemkey => ItemKey,
 	  	       aname => 'SHAREDLOC');
       CodeLoc:=wf_engine.GetItemAttrText(Itemtype => ItemType,
		       Itemkey => ItemKey,
  	               aname => 'CODELOC');
       PlanID:=wf_engine.GetItemAttrText(Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'ODPPLAN');
	SELECT C0, C1, C2, C3
        into ActRetCode, ActRetText, ActRetVal, ActRetErr
	from THE (SELECT CAST (EPS.query(express_server,
	'DB0='|| CodeLoc || '/ODPCODE\'
	|| 'DBCount=1\'
	|| 'MeasureCount=4\'
	|| 'Measure0=ACTIVITY.FORMULA\'
        || 'Measure1=ACTIVITY.TEXT\'
        || 'Measure2=ACTIVITY.RETVAL\'
        || 'Measure3=ACTIVITY.ERROR\'
	|| 'E0Count=2\'
	|| 'E0Dim0Name=PLACEHOLDER\'
	|| 'E0Dim1Name=ACTIVITY.ENTRY\'
      || 'E0Dim1Script=CALL WF.SETACTIVITY('''|| ActEntry || ''', '''|| PlanID ||''',  '''|| DBName ||''', '''|| SharedLoc ||''',  '''|| DPAdmin ||''',  '''|| thisrole ||''', '''|| ItemKey ||''', '''|| Master ||''', '''|| Process ||''')\'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL)
	 AS EPS_express_list_t)
	   from DUAL);
      if ActRetCode = 'Y' then
         resultout :='COMPLETE:Y';
      end if;

      if ActRetCode = 'MSG' then
        -- corrected this name
        if ActEntry = 'ODPSUBSTAT'
           then
            TxtDate := to_char(sysdate, 'YY MM DD');
            TempDate := to_date(TxtDate, 'YY MM DD');
            -- obsolete agb 6/14/00 TempDate := sysdate;
            wf_engine.SetItemAttrDate(Itemtype => ItemType,
	  	   Itemkey => ItemKey,
		   aname => 'VALUE1',
		   avalue => TempDate);
           end if;
         resultout :='COMPLETE:MSG';
      end if;

      if ActRetCode = 'CYCLE' then
        -- corrected this name
        if ActEntry = 'ODPSUBSTAT'
           then
            TxtDate := to_char(sysdate, 'YY MM DD');
            TempDate := to_date(TxtDate, 'YY MM DD');
            -- obsolete agb 6/14/00 TempDate := sysdate;
            wf_engine.SetItemAttrDate(Itemtype => ItemType,
	  	   Itemkey => ItemKey,
		   aname => 'VALUE1',
		   avalue => TempDate);
           end if;
        resultout :='COMPLETE:CYCLE';
      end if;

      if ActRetCode = 'BUSY' then
         resultout :='COMPLETE:BUSY';
      end if;
      if ActRetCode = 'DONE' then
         resultout :='COMPLETE:DONE';
      end if;
      if ActRetCode = 'END' then
         resultout :='COMPLETE:END';
      end if;
    if ActRetCode = 'Y' then
 	if ActEntry = 'ODPDIST'
          then
             wf_engine.SetItemAttrText(Itemtype => ItemType,
      		    Itemkey => ItemKey,
		          aname => 'ASSIGNID',
		          avalue => ActRetVal);
             wf_engine.SetItemAttrText(Itemtype => ItemType,
		          Itemkey => ItemKey,
		          aname => 'ASSIGNNAME',
		          avalue => ActRetText);
           end if;

      end if;
      if ActRetCode = 'N' then
      wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'DPPROBLEM',
				   avalue => ActRetErr);
      end if;
      return;
      END IF;
  exception
   when others then
     WF_CORE.CONTEXT('MSDWF', 'DOEXPRESS',
    itemtype, itemkey, to_char(actid), funcmode);
     raise;
end DOEXPRESS;
-- Starts a Workflow process.
PROCEDURE STARTPRO (WorkflowProcess in varchar2,
                      iteminput in varchar2,
                      inputkey in varchar2,
                      inowner  in varchar2,
                      inrole   in varchar2,
                      inplan   in varchar2,
                      inCDate  in varchar2)
IS
   itemtype varchar2(30) := iteminput;
   itemkey varchar2(200) := inputkey;
   owner varchar2(30) := inowner;
   CompDate date;
   BEGIN
   SELECT demand_plan_name, code_location, shared_db_prefix,
    shared_db_location, express_connect_string INTO PlName,
    CodeLoc, DBName, SharedLoc, express_server
    from msd_demand_plans_v
    where demand_plan_id=to_number(inPlan);
   wf_engine.CreateProcess(ItemType => ItemType,
                           itemKey => ItemKey,
                           process => WorkflowProcess);
   -- The sysinfo(user that launched the process or the Owner of the process.
   -- This would be the demand planning administrator.
   wf_engine.SetItemOwner(ItemType => ItemType,
                         ItemKey => ItemKey,
                         owner => owner);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'DPADMIN',
				   avalue => owner);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'ODPROLE',
				   avalue => inrole);
   -- Plan ID!
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'ODPPLAN',
				   avalue => inplan);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'PLNAME',
				   avalue => PlName);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'CODELOC',
				   avalue => CodeLoc);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'DBNAME',
				   avalue => DBName);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'SHAREDLOC',
				   avalue => SharedLoc);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'EXPCONN',
				   avalue => express_server);
   if WorkflowProcess = 'ODPSTDCOL'
      then
         CompDate:= to_date(inCDate, 'YY MM DD');
         wf_engine.SetItemAttrDate(Itemtype => ItemType,
	 			   Itemkey => ItemKey,
				   aname => 'VALUE2',
				   avalue => CompDate);
       end if;

    -- if fixed date for Distrbution or Standard Collection then set Wait to null.
    if WorkflowProcess = 'ODPDISTPLANS'
       then
          select count(value) into FixedDate from v$parameter
              where name like '%fixed_date%' AND length(VALUE) > 0;
          if FixedDate > 0
             then
              wf_engine.SetItemAttrNumber(Itemtype => ItemType,
	      		   Itemkey => ItemKey,
	      		   aname => 'WAIT_RELATIVE_TIME',
	      		   avalue => NULL);
          end if;
     end if;

   wf_engine.StartProcess(ItemType => ItemType,
                         ItemKey => ItemKey);
   return;
   exception
     when others then
        WF_CORE.CONTEXT('MSDWF', 'STARTPRO',
         itemtype, itemkey);
   raise;
end STARTPRO;
PROCEDURE LAUNCH (itemtype in varchar2,
		  itemkey  in varchar2,
		  actid    in number,
		  funcmode in varchar2,
                  resultout   out varchar2)
   IS
    ActEntry     varchar2(16);
    ActRetCode    varchar2(2000);
    ActRetText   varchar2(2000);
    ActRetErr    varchar2(2000);
    thisrole     varchar2(30);
    LaunchMgr    varchar2(12);
    AttachDBName varchar2(240);
   BEGIN
      IF (funcmode = 'RUN') THEN
         resultout :='COMPLETE:N';
       SELECT ACTIVITY_NAME INTO ActEntry FROM WF_PROCESS_ACTIVITIES
         WHERE INSTANCE_ID=actid;
       SELECT TEXT_VALUE INTO thisrole FROM WF_ITEM_ATTRIBUTE_VALUES
          WHERE ITEM_KEY=itemkey AND ITEM_TYPE=itemtype AND NAME='ODPROLE';
       --  Inital default is "CONTINUE". Values are CYCLE, DONE, LAUNCH
   --  LAUNCH means Make the call to launch a sub process.
   --  DONE  means all DB Assignments are complete.
   --  CYCLE means keep processing.
   --  This is set upon the start of the process.
   --  This is set by MSDWF.GOVERNOR.
       LaunchMgr:=wf_engine.GetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'LAUNCHMGR');
       PlanID:=wf_engine.GetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
  	              		   aname => 'ODPPLAN');
      if LaunchMgr = 'CYCLE' or LaunchMgr = 'DONE'
         then
            resultout :='COMPLETE:Y';
            return;
         end if;
 -- Call to Launch a process.
    if LaunchMgr = 'LAUNCH'
       then
       express_server:=wf_engine.GetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
  	  	   aname => 'EXPCONN');
       DPAdmin:=wf_engine.GetItemAttrText(Itemtype => ItemType,
		       Itemkey => ItemKey,
		       aname => 'DPADMIN');
       DBName:=wf_engine.GetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
  	  	   aname => 'DBNAME');
       SharedLoc:=wf_engine.GetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
  	  	   aname => 'SHAREDLOC');
       CodeLoc:=wf_engine.GetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
  	  	   aname => 'CODELOC');
	SELECT C0, C1, C2
        into ActRetCode, ActRetText, ActRetErr
	from THE (SELECT CAST (EPS.query(express_server,
	'DB0='|| CodeLoc || '/ODPCODE\'
	|| 'DBCount=1\'
	|| 'MeasureCount=3\'
	|| 'Measure0=ACTIVITY.FORMULA\'
        || 'Measure1=ACTIVITY.TEXT\'
        || 'Measure2=ACTIVITY.ERROR\'
	|| 'E0Count=2\'
	|| 'E0Dim0Name=PLACEHOLDER\'
	|| 'E0Dim1Name=ACTIVITY.ENTRY\'
      || 'E0Dim1Script=CALL WF.SETACTIVITY('''|| ActEntry || ''', '''|| PlanID ||''',  '''|| DBName ||''', '''|| SharedLoc ||''',  '''|| DPAdmin ||''',  '''|| thisrole ||''', '''|| ItemKey ||''',  '''|| Master ||''')\'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL)
	 AS EPS_express_list_t)
	   from DUAL);
      if ActRetCode = 'Y' then
         resultout :='COMPLETE:Y';
      end if;
 --     if ActRetCode = 'Y' then
 --      wf_engine.SetItemAttrText(Itemtype => ItemType,
 --				   Itemkey => ItemKey,
 --				   aname => 'ODPBODY',
 --				   avalue => ActRetText);
 --     end if;
     if ActRetCode = 'N' then
      wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'DPPROBLEM',
				   avalue => ActRetErr);
      end if;
   return;
   end if;
  END IF;
  exception
   when others then
     WF_CORE.CONTEXT('MSDWF', 'LAUNCH',
    itemtype, itemkey, to_char(actid), funcmode, ActRetErr);
     raise;
end LAUNCH;
PROCEDURE GOVERNOR (itemtype in varchar2,
		  itemkey  in varchar2,
		  actid    in number,
		  funcmode in varchar2,
                  resultout   out varchar2)
   IS
    ActEntry     varchar2(16);
    ActRetCode    varchar2(2000);
    ActRetText   varchar2(2000);
    ActRetVal    varchar2(2000);
    ActRetErr    varchar2(2000);
    thisrole     varchar2(30);
    owner        varchar2(30);
    PlanID       varchar2(200);
   BEGIN
      IF (funcmode = 'RUN') THEN
         resultout :='COMPLETE:N';
       SELECT ACTIVITY_NAME INTO ActEntry FROM WF_PROCESS_ACTIVITIES
         WHERE INSTANCE_ID=actid;
       SELECT TEXT_VALUE INTO thisrole FROM WF_ITEM_ATTRIBUTE_VALUES
          WHERE ITEM_KEY=itemkey AND ITEM_TYPE=itemtype AND NAME='ODPROLE';
       express_server := wf_engine.GetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
  	       aname => 'EXPCONN');
       DPAdmin:=wf_engine.GetItemAttrText(Itemtype => ItemType,
		       Itemkey => ItemKey,
		       aname => 'DPADMIN');
       DBName := wf_engine.GetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
  	              		   aname => 'DBNAME');
       SharedLoc := wf_engine.GetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
  	              		   aname => 'SHAREDLOC');
       CodeLoc := wf_engine.GetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
  	              		   aname => 'CODELOC');
	SELECT C0, C1, C2, C3
        into ActRetCode, ActRetText, ActRetVal, ActRetErr
	from THE (SELECT CAST (EPS.query(express_server,
	'DB0='|| CodeLoc || '/ODPCODE\'
	|| 'DBCount=1\'
	|| 'MeasureCount=4\'
	|| 'Measure0=ACTIVITY.FORMULA\'
      || 'Measure1=ACTIVITY.TEXT\'
      || 'Measure2=ACTIVITY.RETVAL\'
      || 'Measure3=ACTIVITY.ERROR\'
	|| 'E0Count=2\'
	|| 'E0Dim0Name=PLACEHOLDER\'
	|| 'E0Dim1Name=ACTIVITY.ENTRY\'
      || 'E0Dim1Script=CALL WF.SETACTIVITY('''|| ActEntry || ''', '''|| PlanID ||''',  '''|| DBName ||''', '''|| SharedLoc ||''',  '''|| owner ||''',  '''|| thisrole ||''',  '''|| ItemKey ||''',  '''|| Master ||''')\'
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL)
	 AS EPS_express_list_t)
	   from DUAL);
   -- This is the end. We are out.
   -- I need Y/N/DONE as possible return values.
      if ActRetCode = 'DONE' then
         resultout :='COMPLETE:DONE';
         return;
      end if;
   -- its time to launch another or contiue
   -- ActRetVal should be either LAUNCH or CYCLE.
      if ActRetCode = 'Y' then
         wf_engine.setItemAttrText(Itemtype => ItemType,
			   Itemkey => ItemKey,
			   aname => 'LAUNCHMGR',
			   avalue => ActRetVal);
         resultout :='COMPLETE:CYCLE';
      end if;
     if ActRetCode = 'N' then
      wf_engine.SetItemAttrText(Itemtype => ItemType,
			   Itemkey => ItemKey,
			   aname => 'DPPROBLEM',
  			   avalue => ActRetErr);
     end if;
   return;
 END IF;
 exception
   when others then
     WF_CORE.CONTEXT('MSDWF', 'GOVERNOR',
    itemtype, itemkey, to_char(actid), funcmode, ActRetErr);
     raise;
end GOVERNOR;

--========================================================================
--
--
-- StartConcProc
--
-- Start a small WF Process which uses only one activity named
-- the Standard Submit Concurrent Program Activity that in turn will run
-- the WF Background Program in the loop.
--
--
-- IN
-- WFProcess - A name of the process with Standard Submit Concurrent Program Activity.
-- itemtype  - A valid item type from WF_ITEM_TYPES table.
-- itemkey   - A string generated from application object's primary key.
-- owner     - A owner of the process.
-- cost_itemKey - A ItemKey of the process whose Activity was deferred.
--

procedure StartConcProc (WFProcess in varchar2,
				 itemtype in varchar2,
				 itemkey in varchar2,
                         owner  in  varchar2,
                         inplan   in varchar2,
				 cost_itemKey in varchar2)
IS

BEGIN

g_owner := owner;

wf_engine.CreateProcess(ItemType => ItemType,
                           itemKey => ItemKey,
                           process => WFProcess);

wf_engine.SetItemOwner(ItemType => ItemType,
                         ItemKey => ItemKey,
                         owner => owner);

   -- Plan ID!
wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'ODPPLAN',
				   avalue => inplan);

wf_engine.SetItemAttrText(Itemtype => ItemType,
				  Itemkey => itemKey ,
				  aname => 'ARG2',
				  avalue => cost_itemKey );

wf_engine.SetItemAttrText(Itemtype => ItemType,
				  Itemkey => itemKey ,
				  aname => 'ARG1',
				  avalue => ItemType);

wf_engine.StartProcess(ItemType => ItemType,
                         ItemKey => ItemKey);


return;

   exception
     when others then
        WF_CORE.CONTEXT('MSDWF', 'StartConcProc',
         itemtype, itemkey);
   raise;

end StartConcProc;

--========================================================================

-- ConcLoop
--
-- Run Background Engine Program in the loop for each Deferred Activity
-- until the Process with Deferred Activities is not completed.
--
-- AGBLoop has to be used from SubmitCost Concurrent program
-- to complete deferred process.
--
-- IN
-- itemtype  - A valid item type from WF_ITEM_TYPES table.
-- itemkey   - A string generated from application object's primary key.
--
-- OUT
--   errbuf -  error message : process or PL/SQL error.
--   retcode - return code (0 = success, 2 = error).
--

 procedure ConcLoop(errbuf out varchar2,
		      retcode out number,
			itemtype in varchar2,
		      itemkey  in varchar2)
IS

 status_code varchar2(50);
 seconds number;
 result     varchar2(200);
 deferred_found varchar2(3);

BEGIN
  seconds := 20;

  errbuf := ' ';
  retcode := 0;

  status_code := 'NONE';
  deferred_found := 'NO';

  dbms_lock.sleep(seconds);

  -- run Background Engine Program in the loop for each Deferred
  -- Activity until the Process with Deferred Activities is not completed.

  Loop

    wf_engine.ItemStatus(itemType, itemkey, status_code, result);

    if RTRIM(status_code) = 'COMPLETE' then
	exit;
    end if;

    select distinct ACTIVITY_STATUS_CODE into status_code
      from wf_item_activity_statuses_v
 	where  item_type = itemtype
  	and    item_key  = itemkey
  	and    ACTIVITY_STATUS_CODE = 'DEFERRED';

     if status_code = 'DEFERRED' then
        deferred_found := 'YES';
	  wf_engine.Background(itemtype);
        dbms_lock.sleep(seconds);
     end if;
  end loop;

 return;

   exception

   when NO_DATA_FOUND then
	if deferred_found = 'YES' then
 	   return;
      else
	   WF_CORE.CONTEXT('MSDWF', 'ConcLoop', itemtype, itemkey, ' NO_DATA_FOUND ');
         retcode := 2;
    	   errbuf:=substr(sqlerrm, 1, 255);
	   raise;
      end if;

   when others then
        WF_CORE.CONTEXT('MSDWF', 'ConcLoop', itemtype, itemkey);
    	  retcode := 2;
        errbuf:=substr(sqlerrm, 1, 255);

        raise;

end ConcLoop;

--========================================================================
--
-- RunConcLoop
--
-- Concurrent program that is used to run WF Background Engine in the looop
-- to complete each deferred activity for particular WF Process(ItemType/ItemKey).
--
-- This program has to be run from Standard Submit Concurrent Program Activity.
--
-- IN
-- itemtype  	- A valid item type from WF_ITEM_TYPES table.
-- cost_itemkey   - Item key of the process whose activities were deferred.
--
-- OUT
--   errbuf -  error message : process or PL/SQL error.
--   retcode - return code (0 = success, 2 = error).
--

procedure RunConcLoop(errbuf out varchar2,
                      retcode out number,
			    ItemType in varchar2,
                      cost_ItemKey in varchar2)

    IS
    retText     varchar2(200);
    planName varchar2(100);
    dispMesg varchar2(200);

BEGIN

	errbuf := ' ';

      MSDWF.ConcLoop(errbuf, retcode, itemtype, cost_ItemKey);

	return;

   exception
   when others then
    retcode :='2';
    errbuf:=substr(sqlerrm, 1, 255);

     raise;

end RunConcLoop;

--========================================================================
--
-- Selector
--
-- This is an Item Type Selector function that contains callback functionality
-- to reestablish context for each process in our Item Type.
-- This is a requrements of the Concurrent Manager Standard Activity
-- to be sure that the context is set up by calling
-- fnd_global.apps_initialize(user_id, resp_id, resp_appl_id)
--
-- IN
-- Set of arguments for Standard Activity Function:
-- itemtype  - A valid item type from WF_ITEM_TYPES table.
-- itemkey   - A string generated from application object's primary key.
-- actid     - An Activity ID.
-- command   - Oracle Workflow calls selector/callback function with
--             following commands: 'RUN', 'TEST_CTX'.
--
-- OUT
-- resultout - A result that can be returned.
--

procedure Selector(itemtype in varchar2,
		  	 itemkey  in varchar2,
		  	 actid    in number,
		  	 command  in varchar2,
                   resultout   out varchar2)
IS

temp varchar2(100);
msd_user_id number;
resp_id number;
resp_appl_id number;
user_name varchar2(50);
errbuf varchar2(240);
number_resps number;
resp_key varchar2(20);

request_responsibility_group	   exception;

BEGIN

IF (command = 'TEST_CTX') THEN

   if g_owner <> ' ' then

   	select user_id into msd_user_id
   	from fnd_user
   	where user_name = g_owner;

   /*	select r.application_id, r.responsibility_id into resp_appl_id, resp_id
     		from fnd_application a, fnd_responsibility r
     		where r.application_id = a.application_id
     		and a.application_short_name = 'MSD'
     		and r.responsibility_key = 'MSD_SYSADMIN';  */

      select count(*) into number_resps
       from fnd_responsibility r, fnd_user_resp_groups urg, fnd_application a
       where  r.application_id = a.application_id
       and r.application_id =  urg.responsibility_application_id
       and r.responsibility_id = urg.responsibility_id
       and urg.user_id = msd_user_id
       and a.application_short_name = 'MSD'
       and (r.responsibility_key = 'MSD_SYSADMIN' or
            r.responsibility_key = 'MSD_INTEGADMIN' or
            r.responsibility_key = 'MSD_ADMIN')
       and r.request_group_id <> 0;

       if number_resps = 0 then

	    raise request_responsibility_group;

       elsif number_resps = 1 then

            select  r.application_id, r.responsibility_id into resp_appl_id, resp_id
       		from fnd_responsibility r, fnd_user_resp_groups urg, fnd_application a
       		where  r.application_id = a.application_id
       		and r.application_id =  urg.responsibility_application_id
       		and r.responsibility_id = urg.responsibility_id
       		and urg.user_id = msd_user_id
       		and a.application_short_name = 'MSD'
       		and (r.responsibility_key = 'MSD_SYSADMIN' or
               	     r.responsibility_key = 'MSD_INTEGADMIN' or
               	     r.responsibility_key = 'MSD_ADMIN')
       		and r.request_group_id <> 0;

       else
	      resp_key := 'MSD_SYSADMIN';
            select  r.application_id, r.responsibility_id into resp_appl_id, resp_id
       		from fnd_responsibility r, fnd_user_resp_groups urg, fnd_application a
       		where  r.application_id = a.application_id
       		and r.application_id =  urg.responsibility_application_id
       		and r.responsibility_id = urg.responsibility_id
       		and urg.user_id = msd_user_id
       		and a.application_short_name = 'MSD'
       		and r.responsibility_key = resp_key
       		and r.request_group_id <> 0;

       end if;

   	fnd_global.apps_initialize(msd_user_id, resp_id, resp_appl_id);

   end if;

end if;

exception

   when NO_DATA_FOUND then

      errbuf:=substr(sqlerrm, 1, 255);

      raise;

    when request_responsibility_group then
	    --fnd_message.set_name ('FND', 'CONC-Illegal printer spec');
          resultout := '2';
	    return ;

   when others then

    errbuf:=substr(sqlerrm, 1, 255);

     raise;


end Selector;
--========================================================================
--========================================================================
-- SetColDate
--
--  WF proc to set the number of days to run the Standard Collection.
--
-- IN Standard  parameters supplied by WF engine:
-- itemtype , itemkey, actid, funcmode
--
-- OUT
--   resultout  'COMPLETE:N' for failure, 'COMPLETE:Y'  for success
--
procedure  SetColDate (itemtype in varchar2,
		  itemkey  in varchar2,
		  actid    in number,
		  funcmode in varchar2,
              resultout   out varchar2)
   IS
    TempDate     date;
    TxtDate      varchar2(8);
    NumDays      number;

   BEGIN

      IF (funcmode = 'RUN') THEN
         resultout :='COMPLETE:N';


         NumDays:=wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'NUMDAYS');

        TempDate := sysdate + NumDays;
        TxtDate := to_char(TempDate, 'YY MM DD');
        TempDate := to_date(TxtDate, 'YY MM DD');
        wf_engine.SetItemAttrDate(Itemtype => ItemType,
	 			   Itemkey => ItemKey,
				   aname => 'VALUE2',
				   avalue => TempDate);

         resultout :='COMPLETE:Y';

  END IF;

  exception
   when others then
     WF_CORE.CONTEXT('MSDWF', 'SetColDate', itemtype, itemkey, to_char(actid), funcmode);
     raise;
end SetColDate;

--========================================================================
-- StartMaster
--
-- Concurrent program that is used to run the ODP master WF process
--
--
-- IN
-- PlanName	              - A valid plan name from msd_demand_plans_v
-- NumDays_to_collect     -  Number of days to run the collection
-- OUT
--   errbuf -  error message : process or PL/SQL error.
--   retcode - return code (0 = success, 2 = error).
--
procedure StartMaster(errbuf out varchar2,
                retcode out number,
      	    PlanName in varchar2,
                NumDays_to_collect in varchar2)

   IS

   retText     	varchar2(200);
   dispMesg 	varchar2(200);
   itemtype 	varchar2(8) := 'ODPCYCLE';
   workflowProcess varchar2(11) := 'ODPAUTOMATE';
   owner 		varchar2(30) := fnd_global.user_name;
   orgcode 	varchar2(3);
   instcode 	varchar2(3);
   org 		varchar2(8);
   PlanID   	varchar2(16);
   itemkey 	      varchar2(200);
   numDaysToCol   number;
   EngItemKey     varchar2(200);


 BEGIN
    errbuf := ' ';

-- Get needed plan information
SELECT demand_plan_id, code_location, shared_db_prefix, shared_db_location, express_connect_string      INTO PlanID, CodeLoc, DBName, SharedLoc, express_server
from msd_demand_plans_v
where demand_plan_name=PlanName;

-- Get organiztion code and instance
SELECT msd_organization_definitions.organization_code, msc_apps_instances.instance_code
 INTO orgcode, instcode
 FROM msd_organization_definitions, msc_apps_instances, msd_demand_plans_v
 WHERE PlanID = msd_demand_plans_v.DEMAND_PLAN_ID AND
 msd_demand_plans_v.ORGANIZATION_ID = msd_organization_definitions.ORGANIZATION_ID AND  msd_demand_plans_v.SR_INSTANCE_ID = msc_apps_instances.instance_id;

numDaysToCol := to_number(NumDays_to_collect);
-- Set item key
org  := orgcode || ':' || instcode;
itemkey := org || '-' || PlanName || '-' || to_char( sysdate, 'MM/DD/YYYY-HH24:MI:SS') || '-' || workflowprocess;

-- Create WF Automate process instance
    wf_engine.CreateProcess(ItemType => ItemType,
                         itemKey => ItemKey,
                         process => WorkflowProcess);
-- This should be the demand planning administrator.
    wf_engine.SetItemOwner(ItemType => ItemType,
                         ItemKey => ItemKey,
                         owner => owner);
-- Sets new attribute Is OPD Master running.
    wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'ISMASTER',
				   avalue => 'Y');
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'DPADMIN',
				   avalue => owner);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'ODPROLE',
				   avalue => owner);
   -- Plan ID!
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'ODPPLAN',
				   avalue => PlanID);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'PLNAME',
				   avalue => PlanName);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'CODELOC',
				   avalue => CodeLoc);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'DBNAME',
				   avalue => DBName);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'SHAREDLOC',
				   avalue => SharedLoc);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'EXPCONN',
				   avalue => express_server);
-- set NumDays to collect
 wf_engine.SetItemAttrNumber(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname =>  'NUMDAYS',
				   avalue => NumDaysToCol);

-- Now that all is created and set START the PROCESS!
   wf_engine.StartProcess(ItemType => ItemType,
                          ItemKey => ItemKey);
   commit;

-- Start background engine for this process.
   EngItemKey := org || '-' || PlanName || '-' || to_char( sysdate, 'MM/DD/YYYY-HH24:MI:SS') || '- MSDWFSTRTBG';
   MSDWF.StartConcProc('MSDWFSTRTBG', 'ODPCYCLE', EngItemKey, owner, PlanID, Itemkey);
   commit;

   return;

   exception
   when others then
    retcode :='2';
    errbuf:=substr(sqlerrm, 1, 255);
     raise;

end StartMaster;
-- ========================================================================
end MSDWF;

/
