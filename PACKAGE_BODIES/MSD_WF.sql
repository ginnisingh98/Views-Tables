--------------------------------------------------------
--  DDL for Package Body MSD_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_WF" AS
/* $Header: msddpwfb.pls 120.2 2006/02/13 12:29:07 faliu noship $ */

express_server varchar2(240);
 DBName    varchar2(80);
 CodeLoc   varchar2(80);
 SharedLoc varchar2(80);
 PlName    varchar2(30);
 planID    varchar2(15);
 Owner     varchar2(320);
 DPAdmin   varchar2(320);
 FixedDate varchar2(30);
 g_owner   varchar2(340);
 Master    varchar2(1);   --agb 02/15/02 is ODP Master controling cycle
 gItemType varchar2(30);     -- noks 10/20/03 added for developers only,
 gItemKey  varchar2(250);    -- to allow to debug code with private CODE.AW.

 gMaster_ItemKey varchar2(250);


-- connects to OES and run programs in OES and gets values back.
PROCEDURE DOEXPRESS (itemtype in varchar2,
		  itemkey  in varchar2,
		  actid    in number,
		  funcmode in varchar2,
                  resultout   out NOCOPY varchar2)
   IS
    ActEntry     varchar2(16);
    ActRetCode    varchar2(2000);
    ActRetText   varchar2(2000);
    ActRetVal    varchar2(2000);
    ActRetErr    varchar2(2000);
    thisrole     varchar2(320);
    TempDate     date;
    TxtDate      varchar2(16);   -- agb 06/14/00 to deal with ambiguous date
    Process      varchar2(30);  -- agb 03/19/02 B2173260 added to wf.setactivity
    Script       varchar(2000);

   BEGIN

	gItemType := ItemType;
 	gItemKey := ItemKey;

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


      -- call to wf.setactivity and get return values

      execute_dml(actentry, planid, dbname, SharedLoc, dpadmin, thisrole, itemkey, master, process,
                  actretcode, actrettext, actretval, actreterr);



      if ActRetCode = 'Y' then
         resultout :='COMPLETE:Y';
      end if;

      if ActRetCode = 'MSG' then
        -- corrected this name
        if ActEntry = 'ODPSUBSTAT'
           then
            TxtDate := to_char(sysdate, 'YY MM DD HH24:MI');
            TempDate := to_date(TxtDate, 'YY MM DD HH24:MI');
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
            TxtDate := to_char(sysdate, 'YY MM DD HH24:MI');
            TempDate := to_date(TxtDate, 'YY MM DD HH24:MI');
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
     if instr(upper(SQLERRM), 'EXPRESS') > 0 or instr(upper(SQLERRM), 'SNAPI') > 0
	then
         resultout :='COMPLETE:N';
         wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'DPPROBLEM',
				   avalue => substr(SQLERRM, 1, 200));

	   update msd_demand_plans
		    set DP_BUILD_ERROR_FLAG = 'YES'
		    where demand_plan_id = to_number(PlanID);
	   commit;

         return;
	else
     	   WF_CORE.CONTEXT('MSD_WF', 'DOEXPRESS',
    	   itemtype, itemkey, to_char(actid), funcmode);
         raise;
	end if;

end DOEXPRESS;

-- Starts a Workflow process.
PROCEDURE STARTPRO (WorkflowProcess in varchar2,
                      iteminput in varchar2,
                      inputkey in varchar2,
                      inowner  in varchar2,
                      inrole   in varchar2,
                      inplan   in varchar2,
                      inCDate  in varchar2,
			    inCodeDB in varchar2)

IS
   itemtype varchar2(30);
   itemkey varchar2(240);
   owner varchar2(320);
   CompDate date;

   userID number;
   respID  number;
   respApplID number;

BEGIN
   itemtype := iteminput;
   itemkey := inputkey;
   owner := inowner;
   userID := fnd_global.user_id;
   respID  := fnd_global.resp_id;
   respApplID := fnd_global.resp_appl_id;


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

   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'CODEDB',
				   avalue => inCodeDB);

  wf_engine.SetItemAttrNumber(Itemtype => ItemType,
	      		   Itemkey => ItemKey,
	      		   aname => 'USER_ID',
	      		   avalue => userID);
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
	      		   Itemkey => ItemKey,
	      		   aname => 'RESP_ID',
	      		   avalue => respID);
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
	      		   Itemkey => ItemKey,
	      		   aname => 'RESP_APPL_ID',
	      		   avalue => respApplID);

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

   commit;

   wf_engine.StartProcess(ItemType => ItemType,
                         ItemKey => ItemKey);
   return;
   exception
     when others then
        WF_CORE.CONTEXT('MSD_WF', 'STARTPRO',
         itemtype, itemkey);
   raise;
end STARTPRO;
PROCEDURE LAUNCH (itemtype in varchar2,
		  itemkey  in varchar2,
		  actid    in number,
		  funcmode in varchar2,
                  resultout   out NOCOPY varchar2)
   IS
    ActEntry     varchar2(16);
    ActRetCode    varchar2(2000);
    ActRetVal    varchar2(2000);
    ActRetText   varchar2(2000);
    ActRetErr    varchar2(2000);
    thisrole     varchar2(320);
    LaunchMgr    varchar2(12);
    AttachDBName varchar2(240);
    script       varchar2(2000);
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
   --  This is set by MSD_WF.GOVERNOR.
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

	 gItemType := ItemType;
 	 gItemKey := ItemKey;

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

      execute_dml(actentry, planid, dbname, SharedLoc, dpadmin, thisrole, itemkey, master, '',
                  actretcode, actrettext, actretval, actreterr);

     commit;

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
     if instr(upper(SQLERRM), 'EXPRESS') > 0 or instr(upper(SQLERRM), 'SNAPI') > 0
	then
         resultout :='COMPLETE:N';
         wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'DPPROBLEM',
				   avalue => substr(SQLERRM, 1, 200));

	   update msd_demand_plans
		    set DP_BUILD_ERROR_FLAG = 'YES'
		    where demand_plan_id = to_number(PlanID);
	   commit;

         return;
	else
     	   WF_CORE.CONTEXT('MSD_WF', 'LAUNCH',
    	   itemtype, itemkey, to_char(actid), funcmode, ActRetErr);
         raise;
	end if;

end LAUNCH;

PROCEDURE GOVERNOR (itemtype in varchar2,
		  itemkey  in varchar2,
		  actid    in number,
		  funcmode in varchar2,
                  resultout   out NOCOPY varchar2)
   IS
    ActEntry     varchar2(16);
    ActRetCode    varchar2(2000);
    ActRetText   varchar2(2000);
    ActRetVal    varchar2(2000);
    ActRetErr    varchar2(2000);
    thisrole     varchar2(320);
    PlanID       varchar2(200);

   BEGIN

	gItemType := ItemType;
 	gItemKey := ItemKey;

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

      -- call to wf.setactivity and get return values
      execute_dml(actentry, planid, dbname, SharedLoc, DPAdmin, thisrole, itemkey, master, '',
                  actretcode, actrettext, actretval, actreterr);
   commit;

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
     if instr(upper(SQLERRM), 'EXPRESS') > 0 or instr(upper(SQLERRM), 'SNAPI') > 0
	then
         resultout :='COMPLETE:N';
         wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'DPPROBLEM',
				   avalue => substr(SQLERRM, 1, 200));

	   planID:=wf_engine.GetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
  	              		   aname => 'ODPPLAN');
	   update msd_demand_plans
		    set DP_BUILD_ERROR_FLAG = 'YES'
		    where demand_plan_id = to_number(planID);
         commit;

         return;
	else
     	   WF_CORE.CONTEXT('MSD_WF', 'GOVERNOR',
         itemtype, itemkey, to_char(actid), funcmode, ActRetErr);
         raise;
	end if;
end GOVERNOR;

--========================================================================
--
-- StartConcProc
--
-- As of 11.5.10, this program directly launches the MSDWFBG concurrent program
-- instead of starting a workflow process.
--
-- itemtype - A valid item type from WF_ITEM_TYPES table (generally ODPCYCLE)
-- itemKey  - An ItemKey of the process whose Activity was deferred
--

procedure StartConcProc(itemtype in varchar2,
	                itemkey in varchar2) is
  l_ret number;
BEGIN
  l_ret := fnd_request.submit_request('MSD', 'MSDWFBG',null,null,null,
                                      ItemType, ItemKey,
                                      chr(0),null,null,null,null,null,null,null,null,null,
                                      null,null,null,null,null,null,null,null,null,null,
                                      null,null,null,null,null,null,null,null,null,null,
                                      null,null,null,null,null,null,null,null,null,null,
                                      null,null,null,null,null,null,null,null,null,null,
                                      null,null,null,null,null,null,null,null,null,null,
                                      null,null,null,null,null,null,null,null,null,null,
                                      null,null,null,null,null,null,null,null,null,null,
                                      null,null,null,null,null,null,null,null,null,null,
                                      null,null,null,null,null,null,null,null);
  commit;
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

 procedure ConcLoop(errbuf out NOCOPY varchar2,
		      retcode out NOCOPY number,
			itemtype in varchar2,
		      itemkey  in varchar2)
IS

 status_code varchar2(50);
 seconds number;
 result     varchar2(200);
 deferred_found varchar2(3);
 RootAct varchar2(30);

BEGIN
  seconds := 20;

  errbuf := ' ';
  retcode := 0;

  status_code := 'NONE';
  deferred_found := 'NO';

  --**********************
  --agb Emerson 08/12/2003
  select ROOT_ACTIVITY into RootAct
  from WF_ITEMS_V
  where item_type = 'ODPCYCLE' and item_key = itemkey;


  -- run Background Engine Program in the loop for each Deferred
  -- Activity until the Process with Deferred Activities is not completed.

  Loop

    --*************************************************
    --agb Emerson 08/12/2003
    -- moved sleep here to pace the loop at one minute
    -- This should be more than sufficent

    dbms_lock.sleep(45);

    wf_engine.ItemStatus(itemType, itemkey, status_code, result);

    if RTRIM(status_code) = 'COMPLETE' then
	exit;
    end if;

    if RootAct = 'ODPDISTPLANS' then
         --*****************************************************
         --  agb Emerson 08/12/2003
         --  if this is the controling Distrbution process then just
         --  do a call to background once a minute.  This will check the WAIT
         --  and intiate any deferred thread for the distribtuion.

	  wf_engine.Background(itemtype);
    else
	--*****************************************************
         --  agb inspired from Emerson mod 08/12/2003
         --  This path WILL NOT be taken for distribution!
         --  HERE if we find a deferrd activity waiting to be be
         --  run by a background engine we will ONLY then call
         --  wf_engine.Background(itemtype).  Note this is select is
         --  itemkey specific.

    	  select distinct ACTIVITY_STATUS_CODE into status_code
        from wf_item_activity_statuses_v
 	  where  item_type = itemtype
  	  and    item_key  = itemkey
  	  and    ACTIVITY_STATUS_CODE = 'DEFERRED';

       if status_code = 'DEFERRED' then
          deferred_found := 'YES';

	    -- agb inspired from Emerson mod 08/12/2003
          -- This should give time for the deferred item to be
	    -- in both WF status and on the deferred queue
	    dbms_lock.sleep(15);
	    wf_engine.Background(itemtype);

      end if;

   end if;

end loop;

 return;

   exception

   when NO_DATA_FOUND then
	if deferred_found = 'YES' then
 	   return;
      else
	   WF_CORE.CONTEXT('MSD_WF', 'ConcLoop', itemtype, itemkey, ' NO_DATA_FOUND_BUN');
         retcode := 2;
    	   errbuf:=substr(sqlerrm, 1, 255);
	   raise;
      end if;

   when others then
        WF_CORE.CONTEXT('MSD_WF', 'ConcLoop', itemtype, itemkey);
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

procedure RunConcLoop(errbuf out NOCOPY varchar2,
                      retcode out NOCOPY number,
			    ItemType in varchar2,
                      cost_ItemKey in varchar2)

    IS
    retText     varchar2(200);
    planName varchar2(100);
    dispMesg varchar2(200);

BEGIN


	errbuf := ' ';

      MSD_WF.ConcLoop(errbuf, retcode, itemtype, cost_ItemKey);


	return;

   exception
   when others then
    retcode :='2';
    errbuf:=substr(sqlerrm, 1, 255);


     raise;

end RunConcLoop;

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
              resultout   out NOCOPY varchar2)
   IS
    TempDate     date;
    TxtDate      varchar2(16);
    NumDays      number;

   BEGIN

      IF (funcmode = 'RUN') THEN
         resultout :='COMPLETE:N';


         NumDays:=wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'NUMDAYS');

        TempDate := sysdate + NumDays;
        TxtDate := to_char(TempDate, 'YY MM DD HH24:MI');
        TempDate := to_date(TxtDate, 'YY MM DD HH24:MI');
        wf_engine.SetItemAttrDate(Itemtype => ItemType,
	 			   Itemkey => ItemKey,
				   aname => 'VALUE2',
				   avalue => TempDate);

	  wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'SETUPLDREF',
				   avalue => 'NO');

         resultout :='COMPLETE:Y';

  END IF;

  exception
   when others then
     WF_CORE.CONTEXT('MSD_WF', 'SetColDate', itemtype, itemkey, to_char(actid), funcmode);
     raise;
end SetColDate;
--========================================================================
-- SetUpldDate
--
--  WF proc to set the number of days to run the Upload Process.
--
-- IN
-- Standard  parameters supplied by WF engine:
-- itemtype , itemkey, actid, funcmode
--
-- OUT
--   resultout  'COMPLETE:N' for failure, 'COMPLETE:Y'  for success
--
procedure  SetUpldDate (itemtype in varchar2,
		  itemkey  in varchar2,
		  actid    in number,
		  funcmode in varchar2,
              resultout   out NOCOPY varchar2)
   IS
    TempDate     date;
    TxtDate      varchar2(16);
    NumDays      number;
    DelayUpldRef_flag varchar(3);

   BEGIN

      IF (funcmode = 'RUN') THEN
         resultout :='COMPLETE:N';

      TxtDate := to_char(sysdate, 'YY MM DD HH24:MI');
     	TempDate := to_date(TxtDate, 'YY MM DD HH24:MI');
     	-- obsolete agb 6/14/00 TempDate := sysdate;
     	wf_engine.SetItemAttrDate(Itemtype => ItemType,
  	    	Itemkey => ItemKey,
	    	aname => 'VALUE1',
	    	avalue => TempDate);

	-- the Delay Reference value must be loaded only once
	-- when UploadDelay process just started
	DelayUpldRef_flag := wf_engine.GetItemAttrText(Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'SETUPLDREF');

	IF (DelayUpldRef_flag <> 'YES') Then
      	NumDays:=wf_engine.GetItemAttrNumber(Itemtype => ItemType,
		       Itemkey => ItemKey,
 	  	       aname => 'DELAYDAYS');

       	TempDate := sysdate + NumDays;
       	TxtDate := to_char(TempDate, 'YY MM DD HH24:MI');
       	TempDate := to_date(TxtDate, 'YY MM DD HH24:MI');
       	wf_engine.SetItemAttrDate(Itemtype => ItemType,
	 			   Itemkey => ItemKey,
				   aname => 'VALUE2',
				   avalue => TempDate);
		wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'SETUPLDREF',
				   avalue => 'YES');
	END IF;

         resultout :='COMPLETE:Y';

  END IF;

  exception
   when others then
     WF_CORE.CONTEXT('MSD_WF', 'SetUpldDate', itemtype, itemkey, to_char(actid), funcmode);
     raise;
end SetUpldDate;

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
procedure StartMaster(errbuf out NOCOPY varchar2,
                      retcode out NOCOPY number,
      	          PlanName in varchar2,
			    NumDays_to_collect in varchar2,
			    NumDays_to_delayUpld in varchar2)

   IS

   retText     	varchar2(200);
   dispMesg 	varchar2(200);
   itemtype 	varchar2(8);
   workflowProcess varchar2(11);

   owner 	varchar2(320);
   instcode 	varchar2(3);
   org 		varchar2(8);
   PlanID   	varchar2(16);
   itemkey 	varchar2(240);
   numDaysToCol   number;
   EngItemKey     varchar2(240);
   DelayDaysToUpld   number;
   codeDBName     varchar2(20);

   userID number;
   respID  number;
   respApplID number;

 BEGIN
   itemtype := 'ODPCYCLE';
   workflowProcess := 'ODPAUTOMATE';
   owner := fnd_global.user_name;
   userID := fnd_global.user_id;
   respID := fnd_global.resp_id;
   respApplID := fnd_global.resp_appl_id;


    errbuf := ' ';

-- Get needed plan information
SELECT demand_plan_id, code_location, shared_db_prefix, shared_db_location, express_connect_string      INTO PlanID, CodeLoc, DBName, SharedLoc, express_server
from msd_demand_plans_v
where demand_plan_name=PlanName;

-- Get organiztion code and instance
SELECT msc_trading_partners.organization_code, msc_apps_instances.instance_code
 INTO org, instcode
 FROM msc_trading_partners, msc_apps_instances, msd_demand_plans_v
 WHERE PlanID = msd_demand_plans_v.DEMAND_PLAN_ID AND
 msd_demand_plans_v.ORGANIZATION_ID = msc_trading_partners.sr_tp_id
 and msd_demand_plans_v.sr_instance_id  = msc_trading_partners.sr_instance_id
 and msc_trading_partners.partner_type = 3
 AND  msd_demand_plans_v.SR_INSTANCE_ID = msc_apps_instances.instance_id;

--get MSD code database name
select fnd_profile.value('MSD_CODE_AW') into codeDBName from dual;

codeDBName := nvl(codeDBName, 'ODPCODE');

numDaysToCol := to_number(NumDays_to_collect);
DelayDaysToUpld := to_number(NumDays_to_delayUpld);

-- Set item key
--org  := orgcode || ':' || instcode;
itemKey := org || '-' || PlanName || '-' || to_char( sysdate, 'MM/DD/YYYY-HH24:MI:SS') || '-' || workflowprocess;

gItemType := ItemType;
gItemKey  := itemKey;

-- Create WF Automate process instance
    wf_engine.CreateProcess(ItemType => ItemType,
                         itemKey => ItemKey,
                         process => WorkflowProcess);

-- setup attributes for Master Automation process
wf_engine.SetItemAttrText(Itemtype => ItemType,
			  Itemkey => ItemKey,
			  aname => 'CODEDB',
			  avalue => codeDBName);

wf_engine.SetItemAttrNumber(Itemtype => ItemType,
	      		   Itemkey => ItemKey,
	      		   aname => 'USER_ID',
	      		   avalue => userID);
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
	      		   Itemkey => ItemKey,
	      		   aname => 'RESP_ID',
	      		   avalue => respID);
   wf_engine.SetItemAttrNumber(Itemtype => ItemType,
	      		   Itemkey => ItemKey,
	      		   aname => 'RESP_APPL_ID',
	      		   avalue => respApplID);

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
-- set DelayDays to Upload
 wf_engine.SetItemAttrNumber(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname =>  'DELAYDAYS',
				   avalue => DelayDaysToUpld);

-- Now that all is created and set START the PROCESS!
   wf_engine.StartProcess(ItemType => ItemType,
                          ItemKey => ItemKey);
   commit;

-- Start background engine for this process.
   MSD_WF.StartConcProc('ODPCYCLE', Itemkey);
   commit;

   return;

   exception
   when others then
    retcode :='2';
    errbuf:=substr(sqlerrm, 1, 255);
     raise;

end StartMaster;
--=============================================================================

procedure setowner(p_owner in varchar2) is
begin
g_owner := p_owner;
end;

--==============================================================================

/*
  This procedure will attach the ODPCODE aw, construct a call to WF.SETACTIVITY
  and retrieve return values and codes.
*/
procedure execute_dml(p_actentry varchar2, p_planid varchar2, p_dbname varchar2,
                     p_SharedLoc varchar2, p_owner varchar2, p_role varchar2, p_itemkey varchar2,
                      p_master varchar2, p_process varchar2,
                      p_retcode out NOCOPY varchar2, p_rettext out NOCOPY varchar2,
                      p_retval out NOCOPY varchar2, p_reterr out NOCOPY varchar2) is
  script varchar2(4000);
  code_aw varchar2(50);
  user_id  number;
  resp_id  number;
  respAppl_id number;
  bFailed  boolean;

  master_type varchar2(50);
  show_log_title varchar2(50);



begin

  code_aw :=wf_engine.GetItemAttrText(Itemtype => gItemType,
		       Itemkey => gItemKey,
 	  	       aname => 'CODEDB');

  user_id:=wf_engine.GetItemAttrNumber(Itemtype => gItemType,
       					 Itemkey => gItemKey,
       					 aname => 'USER_ID');

  resp_id:=wf_engine.GetItemAttrNumber(Itemtype => gItemType,
	       				   Itemkey => gItemKey,
  	       				   aname => 'RESP_ID');

  respAppl_id:=wf_engine.GetItemAttrNumber(Itemtype => gItemType,
	       					 Itemkey => gItemKey,
  	       					 aname => 'RESP_APPL_ID');
  -- get attributes to manage S&OP Master Automation Process

  master_type := wf_engine.GetItemAttrText(Itemtype => gItemType,
		       			     Itemkey => gItemKey,
 	  	       			     aname => 'MASTER_TYPE');
  show_log_title := wf_engine.GetItemAttrText(Itemtype => gItemType,
		       			     Itemkey => gItemKey,
 	  	       			     aname => 'SHOW_LOG_TITLE');

  fnd_global.apps_initialize(user_id, resp_id, respAppl_id);


  script := 'aw attach ap' || 'ps.' || code_aw || ' ro; ';

  if master_type = 'SOP' then
    script := script || 'SOP.MASTER = ''Y''; ';
    script := script || 'SHOW.LOG.TITLE = ''' || show_log_title || ''';';
  end if;

  script := script ||
            'CALL WF.SETACTIVITY('''|| p_ActEntry || ''', '''|| p_PlanID ||''',  '''||
                                       p_DBName ||''', '''|| p_SharedLoc ||''', '''|| p_owner ||''',  '''||
                                       p_role ||''',  '''|| p_ItemKey ||''',  '''||
                                       p_Master ||''', ''' || p_process || ''', ''' || code_aw || '''); ' ||
             'activity.retcode = activity.formula; ';
  begin
    bFailed := false;
    msd_common_utilities.dbms_aw_interp_silent(script);

    exception
      when others then
        p_RetCode := 'N';
        bFailed := true;
  end;

  if not(bFailed) then
    p_RetCode := trim(both fnd_global.local_chr(10) from dbms_lob.substr(msd_common_utilities.dbms_aw_interp('shw activity.retcode'), 2000));
  end if;

  p_RetText := trim(both fnd_global.local_chr(10) from dbms_lob.substr(msd_common_utilities.dbms_aw_interp('shw activity.text'), 2000));
  p_RetVal  := trim(both fnd_global.local_chr(10) from dbms_lob.substr(msd_common_utilities.dbms_aw_interp('shw activity.retval'), 2000));
  p_RetErr  := trim(both fnd_global.local_chr(10) from dbms_lob.substr(msd_common_utilities.dbms_aw_interp('shw activity.error'), 2000));
script := '';

   -- detach any aws if they are still attached
   msd_common_utilities.detach_all_aws;

end execute_dml;

-- ========================================================================
-- SET_ATTRIBUTES
--
--  set WF Attributes.  Currently just argument1.  Will add more as needed.
--
-- IN
--   Standard parameters supplied by WF engine: itemtype , itemkey, actid, funcmode
--
-- OUT
--   resultout 'COMPLETE' for success
--

procedure SET_ATTRIBUTES(itemtype in varchar2,
 		  		itemkey  in varchar2,
 		  		actid    in number,
 		  		funcmode in varchar2,
               		resultout   out NOCOPY varchar2)

    IS

     BEGIN

        IF (funcmode = 'RUN') THEN
           	  wf_engine.SetItemAttrText(Itemtype => ItemType,
 						   Itemkey => ItemKey,
 				   		   aname => 'ARG1',
 				   		   avalue => ItemKey);

         	resultout := 'COMPLETE';
       END IF;
       return;

    exception
    when others then
      WF_CORE.CONTEXT('MSD_WF', 'SET_ATTRIBUTES', itemtype, itemkey, to_char(actid), funcmode);
      raise;

 end SET_ATTRIBUTES;


--================================================================================
-- DISTRIBUTE
--
--  A concurrent program that connects to OES and runs ODPWF.DISTRIBUTE in Express.
--  Gets values back through EPS.
-- IN one argument:
--  itemkey
--
-- OUT
--   standard for concurrent program: errbuf, retcode: 0,1 ,2.
--

PROCEDURE DISTRIBUTE (errbuf out NOCOPY varchar2,
                      retcode out NOCOPY number,
	                itemkey  in varchar2)

    IS

     ActEntry     varchar2(16);
     ActRetCode    varchar2(2000);
     ActRetText   varchar2(2000);
     ActRetVal    varchar2(2000);
     ActRetErr    varchar2(2000);
     thisrole     varchar2(320);
     Process      varchar2(30);
     itemType     varchar2(10);

BEGIN

-- This is only run for assignment distibution.
	 itemType := 'ODPCYCLE';
       ActEntry := 'ODPDIST';
       Process := 'ODPDISTPRC';

	 gItemType := ItemType;
 	 gItemKey := ItemKey;

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

 	-- call to wf.setactivity and get return values
      execute_dml(actentry, planid, dbname, SharedLoc, dpadmin, thisrole, itemkey, master, process,
                  ActRetCode, ActRetText, ActRetVal, ActRetErr);


      if ActRetCode = 'Y' then

	retcode :='0';
        wf_engine.SetItemAttrText(Itemtype => ItemType,
       	  	    			Itemkey => ItemKey,
 		    				aname => 'ASSIGNID',
 		    				avalue => ActRetVal);

        wf_engine.SetItemAttrText(Itemtype => ItemType,
 		    				Itemkey => ItemKey,
 		    				aname => 'ASSIGNNAME',
 		    				avalue => ActRetText);
        end if;

      if ActRetCode = 'N' then
        wf_engine.SetItemAttrText(Itemtype => ItemType,
 		   				Itemkey => ItemKey,
 		   				aname => 'DPPROBLEM',
 		   				avalue => ActRetErr);
	retcode :='2';
      end if;

      commit;


      return;

     exception
    	when others then
      	retcode :='2';
      	errbuf:=substr(sqlerrm, 1, 255);

     if instr(upper(SQLERRM), 'EXPRESS') > 0 or instr(upper(SQLERRM), 'SNAPI') > 0
 	then
         wf_engine.SetItemAttrText(Itemtype => ItemType,
 				   Itemkey => ItemKey,
 				   aname => 'DPPROBLEM',
 				   avalue => substr(SQLERRM, 1, 200));

         commit;
         return;
     end if;

  end DISTRIBUTE;

-- ========================================================================
-- EXECUTE_DML2
--
--  This program is running by Purge.
--  It's identical to the EXECUTE_DML, but always uses ODPCODE only.
--  It doesn't care about CODEDB attribute .
--

procedure execute_dml2(p_actentry varchar2, p_planid varchar2, p_dbname varchar2,
                      p_SharedLoc varchar2, p_owner varchar2, p_role varchar2, p_itemkey varchar2,
                      p_master varchar2, p_process varchar2,
                      p_retcode out NOCOPY varchar2, p_rettext out NOCOPY varchar2,
                      p_retval out NOCOPY varchar2, p_reterr out NOCOPY varchar2) is
  script varchar2(4000);
  code_aw varchar2(50);

begin

  code_aw := 'odpcode';

  -- because of the GSCC error "Hard-coded Schema name 'apps',
  -- the different notation is used
  --script := 'aw attach apps.odpcode'   ||' ro; ';

  script := 'aw attach ap' || 'ps.odpcode'   ||' ro; ';

  script := script ||
            'CALL WF.SETACTIVITY('''|| p_ActEntry || ''', '''|| p_PlanID ||''',  '''||
                                       p_DBName ||''', '''|| p_SharedLoc ||''', '''|| p_owner ||''',  '''||
                                       p_role ||''',  '''|| p_ItemKey ||''',  '''||
                                       p_Master ||''', ''' || p_process || ''', ''' || code_aw || '''); ' ||
             'activity.retcode = activity.formula';

  --insert into msd_temp values(script);
  msd_common_utilities.dbms_aw_interp_silent(script);

  p_RetCode := trim(both fnd_global.local_chr(10) from dbms_lob.substr(msd_common_utilities.dbms_aw_interp('shw activity.retcode'), 2000));
  p_RetText := trim(both fnd_global.local_chr(10) from dbms_lob.substr(msd_common_utilities.dbms_aw_interp('shw activity.text'), 2000));
  p_RetVal  := trim(both fnd_global.local_chr(10) from dbms_lob.substr(msd_common_utilities.dbms_aw_interp('shw activity.retval'), 2000));
  p_RetErr  := trim(both fnd_global.local_chr(10) from dbms_lob.substr(msd_common_utilities.dbms_aw_interp('shw activity.error'), 2000));
script := '';


end execute_dml2;

--================================================================================
end MSD_WF;

/
