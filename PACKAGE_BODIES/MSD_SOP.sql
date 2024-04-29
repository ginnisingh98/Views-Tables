--------------------------------------------------------
--  DDL for Package Body MSD_SOP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_SOP" AS
/* $Header: msdspwfb.pls 120.1 2006/02/13 12:47:38 faliu noship $ */


express_server varchar2(240);
 DBName varchar2(80);
 CodeLoc varchar2(80);
 SharedLoc varchar2(80);
 PlName    varchar2(30);
 planID    varchar2(15);
 Owner     varchar2(320);
 DPAdmin   varchar2(320);
 FixedDate varchar2(30);
 g_owner varchar2(340);
 Master       varchar2(1);   --agb 02/15/02 is ODP Master controling cycle
 gItemType varchar2(30);     -- noks 10/20/03 added for developers only,
 gItemKey  varchar2(250);
 gPlanID varchar2(20);

-- ========================================================================
-- Set_Master_Attributes
--
--  This program creates process named by ProcessName and
--  sets basic attributes for it.
-- IN
-- 	PlanName	           - A valid plan name from msd_demand_plans_v
--	NumDays_to_delayDist   - Number of days to delay the distribution process
-- 	NumDays_to_collect     - Number of days for running collection
--	NumDays_to_delayUpld   - Number of days to delay the upload process
-- OUT
--	errbuf -  error message : process or PL/SQL error.
--    retcode - return code (0 = success, 2 = error).

procedure Set_Master_Attributes(
		    errbuf out NOCOPY varchar2,
                retcode out NOCOPY number,
      	    PlanName in varchar2,
                Days_tocollect in varchar2,
		    Days_delayUpld in varchar2,
		    ProcessName in varchar2)
IS

   retText     	varchar2(200);
   dispMesg 	varchar2(200);
   itemtype 	varchar2(8);
   owner 	varchar2(320);
   instcode 	varchar2(3);
   org 		varchar2(8);
   PlanID   	varchar2(16);
   itemkey 	      varchar2(240);
   numDaysToCol   number;
   DelayDaysToUpld   number;
   codeDBName     varchar2(20);

   userID number;
   respID  number;
   respApplID number;

 BEGIN

   itemtype := 'ODPCYCLE';
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

numDaysToCol := to_number(Days_tocollect);
DelayDaysToUpld := to_number(Days_delayUpld);

-- Set item key
itemKey := org || '-' || PlanName || '-' || to_char( sysdate, 'MM/DD/YYYY-HH24:MI:SS') || '-' || ProcessName || '-' || TO_CHAR(DBMS_RANDOM.RANDOM);

gItemType := ItemType;
gItemKey  := itemKey;
gPlanID := PlanID;

-- Create WF Automate process instance
    wf_engine.CreateProcess(ItemType => ItemType,
                         itemKey => ItemKey,
                         process => ProcessName);

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

   return;

exception
   when others then
    retcode :='2';
    errbuf:=substr(sqlerrm, 1, 255);
     raise;



end Set_Master_Attributes;

--
--
-- ========================================================================
-- Start_SOP_Master
--
-- Procedure which is used by concurrent program MSDSOPMASTER
-- to run the S&OP Master Process (SOPAUTOMATE)
--
--
-- IN
-- 	PlanName	           - A valid plan name from msd_demand_plans_v
--	NumDays_to_delayDist   - Number of days to delay the distribution process
-- 	NumDays_to_collect     - Number of days for running collection
--	NumDays_to_delayUpld   - Number of days to delay the upload process
-- OUT
--	errbuf -  error message : process or PL/SQL error.
--    retcode - return code (0 = success, 2 = error).
--

procedure Start_SOP_Master(
		    errbuf out NOCOPY varchar2,
                retcode out NOCOPY number,
      	    PlanName in varchar2,
		    NumDays_to_delayDist in varchar2,
                NumDays_to_collect in varchar2,
		    NumDays_to_delayUpld in varchar2)

IS

itemtype 	varchar2(8);
workflowProcess varchar2(11);
DelayDaysToDist   number;
script varchar2(500);
aw_name varchar2(20);

BEGIN

workflowProcess := 'SOPAUTOMATE';

 MSD_SOP.Set_Master_Attributes(errbuf, retcode,
			     PlanName => PlanName,
			     Days_tocollect => NumDays_to_collect,
			     Days_delayUpld => NumDays_to_delayUpld,
			     ProcessName => workflowProcess);

-- set attributes for SOP process
wf_engine.SetItemAttrNumber(Itemtype => gItemType,
				    Itemkey => gItemKey,
				    aname =>  'DELAYDAYSDIST',
				    avalue => to_number(NumDays_to_delayDist)
				    );

wf_engine.SetItemAttrNumber(Itemtype => gItemType,
				    Itemkey => gItemKey,
				    aname =>  'LAUNCHSNPSHT',
				    avalue => 3);

wf_engine.SetItemAttrNumber(Itemtype => gItemType,
				    Itemkey => gItemKey,
				    aname =>  'LAUNCHPLANNER',
				    avalue => 1);

wf_engine.SetItemAttrText(Itemtype => gItemType,
				    Itemkey => gItemKey,
				    aname =>  'MASTER_TYPE',
				    avalue => 'SOP');

wf_engine.SetItemAttrText(Itemtype => gItemType,
				    Itemkey => gItemKey,
				    aname =>  'SHOW_LOG_TITLE',
				    avalue => 'Y');
commit;

-- set required variables in ODPCODE
script := 'aw attach ODPCODE ro; ';

aw_name := 'M' || 'SD.MSD' || gPlanID;

script := script || 'call odpwf.setMaster(''' || aw_name || ''');' ;
begin

  msd_common_utilities.dbms_aw_interp_silent(script);

  exception
    	when others then
        errbuf:=substr(sqlerrm, 1, 255);

     if instr(upper(SQLERRM), 'EXPRESS') > 0 or instr(upper(SQLERRM), 'SNAPI') > 0
 	then
         wf_engine.SetItemAttrText(Itemtype => gItemType,
 				   Itemkey => gItemKey,
 				   aname => 'DPPROBLEM',
 				   avalue => substr(SQLERRM, 1, 200));

         commit;
         return;
     end if;

  end;

-- Now when all is created and set, start the process!
   wf_engine.StartProcess(ItemType => gItemType,
                          ItemKey => gItemKey);
   commit;

-- Start background engine for this process.
   MSD_WF.StartConcProc('ODPCYCLE', gItemKey);
   commit;

   return;

   exception
   when others then
    retcode :='2';
    errbuf:=substr(sqlerrm, 1, 255);
     raise;


end Start_SOP_Master;

--
--

-- ========================================================================
-- Launch_ASCP_Plan
--
-- Procedure which is called by Recalculate Supply Plans activity(MSDRECALCSUP)
-- to launch ASCP Snapshot and Planner program (msc_launch_plan_pk.msc_launch_plan).
-- MSC_LAUNCH_PLAN program can be run in two different modes,
-- which are defined by values of attributes LAUNCHSNPSHT and LAUNCHPLANNER.
--
-- IN
-- 	itemtype, itemkey, actid, funcmode
-- OUT
--	resultout is Y/N.
--
--

procedure Launch_ASCP_Plan(
		  	itemtype in varchar2,
 		  	itemkey  in varchar2,
 		  	actid    in number,
 		  	funcmode in varchar2,
                      	resultout out NOCOPY varchar2)

IS
  launch_snapshot number;
  launch_planner number;
  script varchar2(4000);
  errbuf varchar2(1000);
  planID varchar2(50);

  v_status  number;
  v_request number;

  TYPE NumTable IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  requests NumTable;
  plans    NumTable;
  v_cur number;

  -- get supply plans that are attached to a demand plan
  cursor c_plans(dp_id number) IS
  select SUPPLY_PLAN_ID,SUPPLY_PLAN_NAME
  from msd_dp_scenarios
  where demand_plan_id = dp_id
  and supply_plan_id is not null;

BEGIN

   IF (funcmode = 'RUN') THEN
     resultout :='COMPLETE:N';
   end if;

   -- get attribute values
   launch_snapshot := nvl(wf_engine.GetItemAttrNumber(
				Itemtype => ItemType,
		       		Itemkey => ItemKey,
 	  	       		aname => 'LAUNCHSNPSHT'),3);

   launch_planner := nvl(wf_engine.GetItemAttrNumber(
				Itemtype => ItemType,
		       		Itemkey => ItemKey,
 	  	       		aname => 'LAUNCHPLANNER'),1);

   planID := wf_engine.GetItemAttrText(
				   Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'ODPPLAN');

   msd_common_utilities.dp_log(planID, 'Launching supply plans','BEGIN');

   -- populate denorm tables
   msd_common_utilities.dp_log(planID, 'Populating denormalized tables');
   MSD_ASCP_FLOW.populate_denorm_tables(planID);

   v_cur := 0;
   FOR plan_rec in c_plans(planID) LOOP
     v_cur := v_cur+1;
     v_request := fnd_request.submit_request('MSC', 'MSCSLPPR5',null,null,null,
                                             plan_rec.supply_plan_name,
                                             plan_rec.supply_plan_id,
                                             3,1,2,sysdate);
     commit;
     requests(v_cur) := v_request;
     plans(v_cur) := plan_rec.supply_plan_id;
     msd_common_utilities.dp_log(planID, plan_rec.supply_plan_name||' (request id '||v_request||')');
   END LOOP;

   --wait until all the requests are done
   FOR i in 1..v_cur LOOP
     msd_common_utilities.dp_log(planID, 'Waiting for request id '||v_request);

     -- wait for this plan run to complete
     MSC_LAUNCH_PLAN_PK.MSC_CHECK_PLAN_COMPLETION(requests(i),plans(i),v_status);

     msd_common_utilities.dp_log(planID, 'Request id '||v_request||' completed with status '||v_status);
   end loop;

   msd_common_utilities.dp_log(planID, 'Done launching supply plans.','END');

   resultout := 'COMPLETE:Y';

   return;

   exception
     when others then
       resultout := 'COMPLETE:N';
       errbuf:=substr(sqlerrm, 1, 255);
       raise;

end Launch_ASCP_Plan;
--================================================================================

end MSD_SOP;

/
