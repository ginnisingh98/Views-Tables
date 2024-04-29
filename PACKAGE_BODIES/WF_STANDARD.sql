--------------------------------------------------------
--  DDL for Package Body WF_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_STANDARD" as
/* $Header: wfstdb.pls 120.11.12010000.5 2012/11/13 19:24:32 alsosa ship $ */



-------------------------------------------------------------------------------
------------------------------- PRIVATE API DECLARATIONS ----------------------
-------------------------------------------------------------------------------
-- ContinueMasterFlow
--   Signal Master Flow to continue if all Detail flows have executed
--   Continuation Activity
-- OUT
--   result    - 'NULL'
procedure ContinueMasterFlow(   itemtype                in varchar2,
                                itemkey                 in varchar2,
                                actid                   in number,
                                waiting_activity        in varchar2,
                                resultout               in out nocopy varchar2);

-- ContinueDetailFlow
--   Signal Detail Flows to continue
-- IN
--   waiting_activity - The Name of the activity that is waiting
-- OUT
--   resultout    - 'NULL'
procedure ContinueDetailFlow(   itemtype                in varchar2,
                                itemkey                 in varchar2,
                                actid                   in number,
                                waiting_activity        in varchar2,
                                resultout               out nocopy varchar2
                                 );

-- WaitForDetailFlow
--   Wait for all detail flows to complete continuation activity
-- IN
--   continuation_activity - The Name of the activity that in waiting
-- OUT
--   result    - 'NULL'
procedure WaitForDetailFlow(    itemtype                in varchar2,
                                itemkey                 in varchar2,
                                actid                   in number,
                                continuation_activity   in varchar2,
                                resultout               out nocopy varchar2);

-- WaitForMasterFlow
--   Wait for Master flows to complete continuation activity
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - 'NULL'
procedure WaitForMasterFlow(    itemtype                in varchar2,
                                itemkey                 in varchar2,
                                actid                   in number,
                                continuation_activity   in varchar2,
                                resultout               out nocopy varchar2 );

-------------------------------------------------------------------------------
------------------------------- PUBLIC APIs -----------------------------------
-------------------------------------------------------------------------------


-- AbortProcess
--   cover to wf_engine abort process used in error process.
procedure AbortProcess(itemtype   in varchar2,
                     itemkey    in varchar2,
                     actid      in number,
                     funcmode   in varchar2,
                     resultout  in out nocopy varchar2) is

 l_error_itemtype varchar2(8);
 l_error_itemkey  varchar2(240);

begin
  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

    --
    -- Get the type and the key of the process that errored out
    -- these were set in the erroring out process by Execute_Error_Process
    --
    l_error_itemkey := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_ITEM_KEY' );
    l_error_itemtype := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_ITEM_TYPE' );

   -- now abort the process: dont specify the process so it defaults to the root
   Wf_Engine.AbortProcess(itemtype => l_error_itemtype, itemkey=>l_error_itemkey);
   resultout := wf_engine.eng_null;

exception
  when others then
    Wf_Core.Context('Wf_Standard', 'AbortProcess', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end AbortProcess;

-- OrJoin
--   Parallel Or Join.
--   Always returns 'NULL' result immediately, since an 'Or' succeeds
--   as soon as first in-transition activity completes.
-- OUT
--   result    - 'NULL'
procedure OrJoin(itemtype  in varchar2,
                 itemkey   in varchar2,
                 actid   in number,
                 funcmode  in varchar2,
                 resultout in out nocopy varchar2)
is
begin
  resultout := wf_engine.eng_null;
exception
  when others then
    Wf_Core.Context('Wf_Standard', 'OrJoin', itemtype, itemkey,
                    to_char(actid), funcmode);
    raise;
end OrJoin;


-- AndJoin
--   Parallel And Join
--   Returns 'NULL' if all in-transition activities have completed.
--   Returns 'WAITING' if at least one in-transition activity is not
--   complete, or is complete with the wrong result.
-- OUT
--   result    - 'WAITING' | 'NULL'
procedure AndJoin(itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funcmode  in varchar2,
                  resultout in out nocopy varchar2)
is
    cnt pls_integer;
begin
  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- SYNCHMODE: Not allowed
  if (itemkey = wf_engine.eng_synch) then
    Wf_Core.Token('OPERATION', 'Wf_Standard.AndJoin');
    Wf_Core.Raise('WFENG_SYNCH_DISABLED');
  end if;

  -- The And fails if there is at least one in-transition which is either
  -- incomplete or complete with the wrong result.
  SELECT count(1)
  into cnt
  FROM WF_ACTIVITY_TRANSITIONS WAT
  WHERE WAT.TO_PROCESS_ACTIVITY = actid
  AND NOT EXISTS
    (SELECT NULL
     FROM WF_ITEM_ACTIVITY_STATUSES WIAS
     WHERE WIAS.PROCESS_ACTIVITY = WAT.FROM_PROCESS_ACTIVITY
     AND WIAS.ITEM_TYPE = itemtype
     AND WIAS.ITEM_KEY = itemkey
     AND WIAS.ACTIVITY_STATUS = 'COMPLETE'
     AND (WAT.RESULT_CODE in (WIAS.ACTIVITY_RESULT_CODE,
                              wf_engine.eng_trans_any)
          OR (WAT.RESULT_CODE = wf_engine.eng_trans_default
              AND NOT EXISTS
                  (SELECT NULL
                   FROM WF_ACTIVITY_TRANSITIONS WAT2
                   WHERE WAT2.FROM_PROCESS_ACTIVITY =
                         WAT.FROM_PROCESS_ACTIVITY
                   AND WAT2.RESULT_CODE = WIAS.ACTIVITY_RESULT_CODE)
             )
         )
    );

  if (cnt > 0) then
    -- This means there is at least one in-transition either incomplete
    -- or complete with the wrong result.
    -- The LogicalAnd fails, return a result of 'WAITING'.
    resultout := wf_engine.eng_waiting;
  else
    -- This means there are no in-transition activities that are either
    -- incomplete or complete with the wrong result.
    -- The LogicalAnd succeeds, return a result of 'NULL' to continue.
    resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
  end if;
  return;
exception
  when others then
    Wf_Core.Context('Wf_Standard', 'AndJoin', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end AndJoin;


-- Assign
--   Assign a value to an item attribute
-- OUT
--   result - null
-- ACTIVITY ATTRIBUTES REFERENCED
--   ATTR         - Item attribute
--   DATE_VALUE   - date value
--   NUMBER_VALUE - number value
--   TEXT_VALUE   - text value
procedure Assign(itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funcmode  in varchar2,
                  resultout in out nocopy varchar2)
is
  atype    varchar2(8);
  asubtype varchar2(8);
  aformat  varchar2(240);
  aname    varchar2(30);
begin
  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- Get attribute info
  aname := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'ATTR');
  wf_engine.GetItemAttrInfo(itemtype, aname, atype, asubtype, aformat);

  -- NUMBER value
  if (atype = 'NUMBER') then
    wf_engine.SetItemAttrNumber(itemtype,itemkey,aname,
      wf_engine.GetActivityAttrNumber(itemtype,itemkey,actid, 'NUMBER_VALUE'));

  -- DATE value
  elsif (atype = 'DATE') then
    wf_engine.SetItemAttrDate(itemtype,itemkey,aname,
      wf_engine.GetActivityAttrDate(itemtype,itemkey,actid, 'DATE_VALUE'));

  -- TEXT value (VARCHAR2, LOOKUP, FORM, URL, DOCUMENT, etc)
  else
    wf_engine.SetItemAttrText(itemtype,itemkey,aname,
      wf_engine.GetActivityAttrText(itemtype,itemkey,actid, 'TEXT_VALUE'));
  end if;

  resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
exception
  when others then
    Wf_Core.Context('Wf_Standard', 'Assign', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end Assign;


-- GetURL
--   Get monitor URL, store in item attribute
-- OUT
--   result    - 'NULL'
-- ACTIVITY ATTRIBUTES REFERENCED
--   ATTR         - Item attribute to set
--   ADMIN_MODE   - administration mode (Y / N)
procedure GetURL(itemtype  in varchar2,
                 itemkey   in varchar2,
                 actid     in number,
                 funcmode  in varchar2,
                 resultout in out nocopy varchar2)
is
  aname    varchar2(30);
  admin    varchar2(8);
begin
  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- SYNCHMODE: Not allowed
  if (itemkey = wf_engine.eng_synch) then
    Wf_Core.Token('OPERATION', 'Wf_Standard.GetUrl');
    Wf_Core.Raise('WFENG_SYNCH_DISABLED');
  end if;

  -- Get item attribute name
  aname := wf_engine.GetActivityAttrText(itemtype,itemkey,actid, 'ATTR');

  -- Get admin mode
  admin := wf_engine.GetActivityAttrText(itemtype,itemkey,actid, 'ADMIN_MODE');

  -- Set item attribute
  wf_engine.SetItemAttrText(itemtype, itemkey, aname,
    wf_monitor.geturl(
      wf_core.translate('WF_WEB_AGENT'), itemtype, itemkey, admin));

  resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
exception
  when others then
    Wf_Core.Context('Wf_Standard', 'GetUrl', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end GetURL;


-- Compare
--   Standard Compare function.
-- OUT
--   comparison value (LT, EQ, GT, NULL)
-- ACTIVITY ATTRIBUTES REFERENCED
--   VALUE1 - Test value
--   VALUE2 - Reference value
procedure Compare(itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funcmode  in varchar2,
                  resultout in out nocopy varchar2)
is
  atype    varchar2(8);
  asubtype varchar2(8);
  aformat  varchar2(240);
  aname    varchar2(30);
  nval1    number;
  nval2    number;
  dval1    date;
  dval2    date;
  tval1    varchar2(4000);
  tval2    varchar2(4000);
begin
  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- Get comparison data type
  Wf_Engine.GetActivityAttrInfo(itemtype, itemkey, actid, 'VALUE1',
                                atype, asubtype, aformat);

  tval1 := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'VALUE1');


  --
  -- NUMBER value
  --
  if (atype = 'NUMBER') then
    -- Get the two number values
    nval1 := Wf_Engine.GetActivityAttrNumber(itemtype,itemkey,actid, 'VALUE1');
    nval2 := Wf_Engine.GetActivityAttrNumber(itemtype,itemkey,actid, 'VALUE2');

    -- Compare
    if (nval1 is null or nval2 is null) then
      resultout := wf_engine.eng_completed||':NULL';
    elsif (nval1 < nval2) then
      resultout := wf_engine.eng_completed||':LT';
    elsif (nval1 > nval2) then
      resultout := wf_engine.eng_completed||':GT';
    elsif (nval1 = nval2) then
      resultout := wf_engine.eng_completed||':EQ';
    end if;

  --
  -- DATE value
  --
  elsif (atype = 'DATE') then
    -- Get the two date values
    dval1 := Wf_Engine.GetActivityAttrDate(itemtype,itemkey,actid, 'VALUE1');
    dval2 := Wf_Engine.GetActivityAttrDate(itemtype,itemkey,actid, 'VALUE2');

    -- Compare
    if (dval1 is null or dval2 is null) then
      resultout := wf_engine.eng_completed||':NULL';
    elsif (dval1 < dval2) then
      resultout := wf_engine.eng_completed||':LT';
    elsif (dval1 > dval2) then
      resultout := wf_engine.eng_completed||':GT';
    elsif (dval1 = dval2) then
      resultout := wf_engine.eng_completed||':EQ';
    end if;

  --
  -- TEXT value (VARCHAR2, LOOKUP, FORM, URL, DOCUMENT, etc)
  --
  else
    -- Get the two text values
    tval1 := Wf_Engine.GetActivityAttrText(itemtype,itemkey,actid, 'VALUE1');
    tval2 := Wf_Engine.GetActivityAttrText(itemtype,itemkey,actid, 'VALUE2');

    -- Compare
    if (tval1 is null or tval2 is null) then
      resultout := wf_engine.eng_completed||':NULL';
    elsif (tval1 < tval2) then
      resultout := wf_engine.eng_completed||':LT';
    elsif (tval1 > tval2) then
      resultout := wf_engine.eng_completed||':GT';
    elsif (tval1 = tval2) then
      resultout := wf_engine.eng_completed||':EQ';
    end if;
  end if;

exception
  when others then
    Wf_Core.Context('Wf_Standard', 'Compare', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end Compare;


-- CompareExecutionTime
--   Compare Execution Time function.
-- OUT
--   comparison value (LT, EQ, GT, NULL)
-- ACTIVITY ATTRIBUTES REFERENCED
--   EXECUTIONTIME - Execution time Test value in seconds
--   PARENTTYPE    - Either ROOT or SUBPROCESS
procedure CompareExecutionTime(itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funcmode  in varchar2,
                  resultout in out nocopy varchar2)
is
  etime     number;
  delta     number;
  processid number;
  ptype     varchar2(30);

  cursor GetRunningTime (itemtype in varchar2,
                         itemkey in varchar2, actid in number) is
  select (sysdate - nvl(begin_date,sysdate))*86400
  from   wf_item_activity_statuses
  where  item_type = itemtype
  and    item_key = itemkey
  and    process_activity = actid;

  cursor GetExecutionTime (itemtype in varchar2,
                         itemkey in varchar2) is
  select (sysdate - begin_date)*86400
  from   wf_items
  where  item_type = itemtype
  and    item_key = itemkey;

begin
  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  Ptype := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'PARENTTYPE');

  if Ptype = 'ROOT' then
     -- calculate the execution time
     open  GetExecutionTime(itemtype, itemkey);
     fetch GetExecutionTime into delta;
     close GetExecutionTime;
  else
     processid := WF_ENGINE_UTIL.activity_parent_process(itemtype, itemkey, actid);

     -- calculate the execution time
     open  GetRunningTime(itemtype, itemkey, processid);
     fetch GetRunningTime into delta;
     close GetRunningTime;
  end if;

  -- look up the test value for execution time
  Etime := Wf_Engine.GetActivityAttrNumber(itemtype, itemkey, actid, 'EXECUTIONTIME');

  -- execute comparison
  if (delta is null or etime is null) then
    resultout := wf_engine.eng_completed||':NULL';
  elsif (delta < etime) then
    resultout := wf_engine.eng_completed||':LT';
  elsif (delta > etime) then
    resultout := wf_engine.eng_completed||':GT';
  elsif (delta = etime) then
    resultout := wf_engine.eng_completed||':EQ';
  end if;

exception
  when others then
    Wf_Core.Context('Wf_Standard', 'CompareExecutionTime', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end CompareExecutionTime;


-- CompareEventProperty
--  Compare a property on an event
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   comparison result (WFSTD_COMPARISON lookup code)
--   GT LT EQ NULL
-- ACTIVITY ATTRIBUTES REFERENCED
--   EVENT - Event whose property is to be compared
--   PROPERTY - Event Property Reference (Based on the lookup of EVENTPROPERTY
--   PARAMETER - Parameter Name if Lookup type = Parameter
--   VALUE - Constant value of correct type
procedure CompareEventProperty(itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funcmode  in varchar2,
                  resultout in out nocopy varchar2)
is
  lEvent WF_EVENT_T;
  lAgent WF_AGENT_T;
  lNVal NUMBER;
  lDVal DATE;
  lTVal VARCHAR2 (4000);
  lProperty VARCHAR2 (20);
  lParameter VARCHAR2(200);
  lType VARCHAR2 (20);
  lSubType VARCHAR2 (20);
  lFormat VARCHAR2 (20);

begin
   lEvent := wf_engine.getActivityAttrEvent(itemtype, itemkey,
                                            actid, 'EVENT');
   lProperty := wf_engine.getActivityAttrText(itemtype, itemkey,
                                              actid, 'PROPERTY');

   if (lProperty = 'PRIORITY') then
      lNVal := wf_engine.getActivityAttrNumber(itemtype, itemkey,
                                                  actid, 'NUMBER_VALUE');
      if (lEvent.priority is NULL or lNVal is NULL) then
         resultout := wf_engine.eng_completed||':NULL';
      elsif (lEvent.priority < lNVal) then
         resultout := wf_engine.eng_completed||':LT';
      elsif (lEvent.priority > lNVal) then
         resultout := wf_engine.eng_completed||':GT';
      elsif (lEvent.priority = lNVal) then
         resultout := wf_engine.eng_completed||':EQ';
      end if;

   elsif (lProperty = 'SEND_DATE') then
      lDVal := wf_engine.getActivityAttrDate(itemtype, itemkey,
                                                  actid, 'DATE_VALUE');
      if (lEvent.send_date is NULL or lDVal is null) then
         resultout := wf_engine.eng_completed||':NULL';
      elsif (lEvent.send_date < lDVal) then
         resultout := wf_engine.eng_completed||':LT';
      elsif (lEvent.send_date > lDVal) then
         resultout := wf_engine.eng_completed||':GT';
      elsif (lEvent.send_date = lDVal) then
         resultout := wf_engine.eng_completed||':EQ';
      end if;
   elsif (lProperty = 'RECEIVE_DATE') then
      lDVal := wf_engine.getActivityAttrDate(itemtype, itemkey,
                                                  actid, 'DATE_VALUE');
      if (lEvent.receive_date is NULL or lDVal is null) then
         resultout := wf_engine.eng_completed||':NULL';
      elsif (lEvent.receive_date < lDVal) then
         resultout := wf_engine.eng_completed||':LT';
      elsif (lEvent.receive_date > lDVal) then
         resultout := wf_engine.eng_completed||':GT';
      elsif (lEvent.receive_date = lDVal) then
         resultout := wf_engine.eng_completed||':EQ';
      end if;
   elsif (lProperty = 'CORRELATION_ID') then
      lTVal := wf_engine.getActivityAttrText(itemtype, itemkey,
                                            actid, 'TEXT_VALUE');
      if (LEvent.correlation_id is NULL or lTVal is NULL) then
         resultout := wf_engine.eng_completed||':NULL';
      elsif (LEvent.correlation_id < lTVal) then
         resultout := wf_engine.eng_completed||':LT';
      elsif (LEvent.correlation_id > lTVal) then
         resultout := wf_engine.eng_completed||':GT';
      elsif (LEvent.correlation_id = lTVal) then
         resultout := wf_engine.eng_completed||':EQ';
      end if;
   elsif (lProperty = 'EVENT_NAME') then
      lTVal := wf_engine.getActivityAttrText(itemtype, itemkey,
                                            actid, 'TEXT_VALUE');
      if (LEvent.event_name is NULL or lTVal is NULL) then
         resultout := wf_engine.eng_completed||':NULL';
      elsif (LEvent.event_name < lTVal) then
         resultout := wf_engine.eng_completed||':LT';
      elsif (LEvent.event_name > lTVal) then
         resultout := wf_engine.eng_completed||':GT';
      elsif (LEvent.event_name = lTVal) then
         resultout := wf_engine.eng_completed||':EQ';
      end if;
   elsif (lProperty = 'EVENT_KEY') then
      lTVal := wf_engine.getActivityAttrText(itemtype, itemkey,
                                            actid, 'TEXT_VALUE');
      if (LEvent.event_key is NULL or lTVal is NULL) then
         resultout := wf_engine.eng_completed||':NULL';
      elsif (LEvent.event_key < lTVal) then
         resultout := wf_engine.eng_completed||':LT';
      elsif (LEvent.event_key > lTVal) then
         resultout := wf_engine.eng_completed||':GT';
      elsif (LEvent.event_key = lTVal) then
         resultout := wf_engine.eng_completed||':EQ';
      end if;
   elsif (lProperty = 'FROM_AGENT_NAME') then
      lTVal := wf_engine.getActivityAttrText(itemtype, itemkey,
                                            actid, 'TEXT_VALUE');
      if (LEvent.From_Agent.Name is NULL or lTVal is NULL) then
         resultout := wf_engine.eng_completed||':NULL';
      elsif (LEvent.From_Agent.Name < lTVal) then
         resultout := wf_engine.eng_completed||':LT';
      elsif (LEvent.From_Agent.Name > lTVal) then
         resultout := wf_engine.eng_completed||':GT';
      elsif (LEvent.From_Agent.Name = lTVal) then
         resultout := wf_engine.eng_completed||':EQ';
      end if;
   elsif (lProperty = 'FROM_AGENT_SYSTEM') then
      lTVal := wf_engine.getActivityAttrText(itemtype, itemkey,
                                            actid, 'TEXT_VALUE');
      if (LEvent.From_Agent.System is NULL or lTVal is NULL) then
         resultout := wf_engine.eng_completed||':NULL';
      elsif (LEvent.From_Agent.System < lTVal) then
         resultout := wf_engine.eng_completed||':LT';
      elsif (LEvent.From_Agent.System > lTVal) then
         resultout := wf_engine.eng_completed||':GT';
      elsif (LEvent.From_Agent.System = lTVal) then
         resultout := wf_engine.eng_completed||':EQ';
      end if;
   elsif (lProperty = 'TO_AGENT_NAME') then
      lTVal := wf_engine.getActivityAttrText(itemtype, itemkey,
                                            actid, 'TEXT_VALUE');
      if (LEvent.To_Agent.Name is NULL or lTVal is NULL) then
         resultout := wf_engine.eng_completed||':NULL';
      elsif (LEvent.To_Agent.Name < lTVal) then
         resultout := wf_engine.eng_completed||':LT';
      elsif (LEvent.To_Agent.Name > lTVal) then
         resultout := wf_engine.eng_completed||':GT';
      elsif (LEvent.To_Agent.Name = lTVal) then
         resultout := wf_engine.eng_completed||':EQ';
      end if;
   elsif (lProperty = 'TO_AGENT_SYSTEM') then
      lTVal := wf_engine.getActivityAttrText(itemtype, itemkey,
                                            actid, 'TEXT_VALUE');
      if (LEvent.To_Agent.System is NULL or lTVal is NULL) then
         resultout := wf_engine.eng_completed||':NULL';
      elsif (LEvent.To_Agent.System < lTVal) then
         resultout := wf_engine.eng_completed||':LT';
      elsif (LEvent.To_Agent.System > lTVal) then
         resultout := wf_engine.eng_completed||':GT';
      elsif (LEvent.To_Agent.System = lTVal) then
         resultout := wf_engine.eng_completed||':EQ';
      end if;
   elsif (lProperty = 'FROM_AGENT') then
      lTVal := wf_engine.getActivityAttrText(itemtype, itemkey,
                                            actid, 'TEXT_VALUE');
      if (LEvent.From_Agent.Name is NULL
	  or LEvent.From_Agent.System is NULL or lTVal is NULL) then
         resultout := wf_engine.eng_completed||':NULL';
      elsif (LEvent.From_Agent.Name||'@'||LEvent.From_Agent.System < lTVal) then
         resultout := wf_engine.eng_completed||':LT';
      elsif (LEvent.From_Agent.Name||'@'||LEvent.From_Agent.System > lTVal) then
         resultout := wf_engine.eng_completed||':GT';
      elsif (LEvent.From_Agent.Name||'@'||LEvent.From_Agent.System = lTVal) then
         resultout := wf_engine.eng_completed||':EQ';
      end if;
   elsif (lProperty = 'TO_AGENT') then
      lTVal := wf_engine.getActivityAttrText(itemtype, itemkey,
                                            actid, 'TEXT_VALUE');
      if (LEvent.To_Agent.Name is NULL
          or LEvent.To_Agent.System is NULL or lTVal is NULL) then
         resultout := wf_engine.eng_completed||':NULL';
      elsif (LEvent.To_Agent.Name||'@'||LEvent.To_Agent.System < lTVal) then
         resultout := wf_engine.eng_completed||':LT';
      elsif (LEvent.To_Agent.Name||'@'||LEvent.To_Agent.System > lTVal) then
         resultout := wf_engine.eng_completed||':GT';
      elsif (LEvent.To_Agent.Name||'@'||LEvent.To_Agent.System = lTVal) then
         resultout := wf_engine.eng_completed||':EQ';
      end if;
   elsif (lProperty = 'PARAMETER') then
      lTVal := wf_engine.getActivityAttrText(itemtype, itemkey,
                                            actid, 'TEXT_VALUE');
      lParameter := wf_engine.getActivityAttrText(itemtype => itemtype,
                                                 itemkey => itemkey,
                                                 actid => actid,
                                                 aname => 'PARAMETER');
      if (LEvent.GetValueForParameter(lParameter)) is NULL then
         resultout := wf_engine.eng_completed||':NULL';
      elsif (LEvent.GetValueForParameter(lParameter) < lTVal) then
         resultout := wf_engine.eng_completed||':LT';
      elsif (LEvent.GetValueForParameter(lParameter) > lTVal) then
         resultout := wf_engine.eng_completed||':GT';
      elsif (LEvent.GetValueForParameter(lParameter) = lTVal) then
         resultout := wf_engine.eng_completed||':EQ';
      end if;
   else
      -- Unhandled property. Return NULL
      resultout := wf_engine.eng_completed||':NULL';
   end if;

exception
  when others then
    Wf_Core.Context('Wf_Standard', 'CompareEventProperty', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end CompareEventProperty;

--  SetEventProperty
--  Set the property in an Event to a given value
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   NONE
-- ACTIVITY ATTRIBUTES REFERENCED
--   EVENT - Event whose property is to be compared
--   PROPERTY - Event Property Reference (Based on the lookup of EVENTPROPERTY
--   PARAMETER - Parameter name
--   VALUE - Constant value of correct type
procedure SetEventProperty(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out nocopy varchar2)
is
  lEvent WF_EVENT_T;
  lNVal NUMBER;
  lDVal DATE;
  lTVal VARCHAR2 (4000);
  lAName VARCHAR2(30);
  lProperty VARCHAR2 (20);
  lParameter VARCHAR2(200);
  lType VARCHAR2 (20);
  lSubType VARCHAR2 (20);
  lFormat VARCHAR2 (20);
  lRefFlag VARCHAR2(8);
  lAtSign PLS_INTEGER;
  lFromAgent WF_AGENT_T := WF_AGENT_T(NULL, NULL);
  lToAgent WF_AGENT_T := WF_AGENT_T(NULL, NULL);

begin
   if (funcmode = 'RUN') then

      -- First get the name of the Item Attribute that EVENT points to
      select WAAV.VALUE_TYPE, substrb(WAAV.TEXT_VALUE, 1, 30)
      into LRefflag, LAName
      from WF_ACTIVITY_ATTR_VALUES WAAV
      where WAAV.PROCESS_ACTIVITY_ID = actid
      and WAAV.NAME = 'EVENT';

     /* Should be able to use the GetActivityAttrEvent to do this
     lEvent := wf_engine.getItemAttrEvent(itemtype => itemtype,
                                           itemkey => itemkey,
                                           name => LAName);
     */


      lEvent := wf_engine.getActivityAttrEvent(itemtype, itemkey,
                                            actid, 'EVENT');

      lProperty := wf_engine.getActivityAttrText(itemtype => itemtype,
                                                 itemkey => itemkey,
                                                 actid => actid,
                                                 aname => 'PROPERTY');
      if (lProperty = 'PRIORITY') then
         lNVal := wf_engine.getActivityAttrNumber(itemtype => itemtype,
                                                  itemkey => itemkey,
                                                  actid => actid,
                                                  aname => 'NUMBER_VALUE');
         lEvent.setPriority(lNVal);
      elsif (lProperty = 'SEND_DATE') then
         lDVal := wf_engine.getActivityAttrDate(itemtype => itemtype,
                                                itemkey => itemkey,
                                                actid =>  actid,
                                                aname => 'DATE_VALUE');
         lEvent.setSendDate(lDVal);
      elsif (lProperty = 'RECEIVE_DATE') then
         lDVal := wf_engine.getActivityAttrDate(itemtype => itemtype,
                                                itemkey => itemkey,
                                                actid => actid,
                                                aname => 'DATE_VALUE');
         lEvent.setReceiveDate(lDVal);
      elsif (lProperty = 'CORRELATION_ID') then
         lTVal := wf_engine.getActivityAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                actid => actid,
                                                aname => 'TEXT_VALUE');
         lEvent.setCorrelationID(lTVal);
      elsif (lProperty = 'EVENT_NAME') then
         lTVal := wf_engine.getActivityAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                actid => actid,
                                                aname => 'TEXT_VALUE');
         lEvent.setEventName(lTVal);
      elsif (lProperty = 'EVENT_KEY') then
         lTVal := wf_engine.getActivityAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                actid => actid,
                                                aname => 'TEXT_VALUE');
         lEvent.setEventKey(lTVal);
      elsif (lProperty = 'FROM_AGENT_NAME') then
         lTVal := wf_engine.getActivityAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                actid => actid,
                                                aname => 'TEXT_VALUE');
         if lEvent.GetFromAgent() is not null then
           lFromAgent := lEvent.GetFromAgent();
         end if;
         lFromAgent.SetName(lTVal);
         lEvent.SetFromAgent(lFromAgent);
      elsif (lProperty = 'FROM_AGENT_SYSTEM') then
         lTVal := wf_engine.getActivityAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                actid => actid,
                                                aname => 'TEXT_VALUE');
         if lEvent.GetFromAgent() is not null then
           lFromAgent := lEvent.GetFromAgent();
         end if;
         lFromAgent.SetSystem(lTVal);
         lEvent.SetFromAgent(lFromAgent);
      elsif (lProperty = 'TO_AGENT_NAME') then
         lTVal := wf_engine.getActivityAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                actid => actid,
                                                aname => 'TEXT_VALUE');
         if lEvent.GetToAgent() is not null then
           lToAgent := lEvent.GetToAgent();
         end if;
         lToAgent.SetName(lTVal);
         lEvent.SetToAgent(lToAgent);
      elsif (lProperty = 'TO_AGENT_SYSTEM') then
         lTVal := wf_engine.getActivityAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                actid => actid,
                                                aname => 'TEXT_VALUE');
         if lEvent.GetToAgent() is not null then
           lToAgent := lEvent.GetToAgent();
         end if;
         lToAgent.SetSystem(lTVal);
         lEvent.SetToAgent(lToAgent);
      elsif (lProperty = 'FROM_AGENT') then
         lTVal := wf_engine.getActivityAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                actid => actid,
                                                aname => 'TEXT_VALUE');
         lAtSign := instr(lTVal, '@');
         lFromAgent.SetName(substr(lTVal, 1, lAtSign-1));
         lFromAgent.SetSystem(substr(lTVal, lAtSign+1));
         lEvent.SetFromAgent(lFromAgent);
      elsif (lProperty = 'TO_AGENT') then
         lTVal := wf_engine.getActivityAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                actid => actid,
                                                aname => 'TEXT_VALUE');
         lAtSign := instr(lTVal, '@');
         lToAgent.SetName(substr(lTVal, 1, lAtSign-1));
         lToAgent.SetSystem(substr(lTVal, lAtSign+1));
         lEvent.SetToAgent(lToAgent);
      elsif (lProperty = 'PARAMETER') then
         lTVal := wf_engine.getActivityAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                actid => actid,
                                                aname => 'TEXT_VALUE');
         lParameter := wf_engine.getActivityAttrText(itemtype => itemtype,
                                                 itemkey => itemkey,
                                                 actid => actid,
                                                 aname => 'PARAMETER');
         lEvent.AddParameterToList(lParameter, lTVal);
      end if;

      wf_engine.setItemAttrEvent(itemtype => itemtype,
                                 itemkey => itemkey,
                                 name => lAName,
                                 event => lEvent);
      resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
   end if; -- RUN

exception
  when others then
    Wf_Core.Context('Wf_Standard', 'SetEventProperty', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end SetEventProperty;


--  GetEventProperty
--  Get a property of an Event and assign it to an Item Attribute
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   NONE
-- ACTIVITY ATTRIBUTES REFERENCED
--   EVENT - Event whose property is to be compared
--   PROPERTY - Event Property Reference (Based on the lookup of EVENTPROPERTY
--   PARAMETER - Event Parameter Name
--   VALUE - Constant value of correct type
procedure GetEventProperty(itemtype  in varchar2,
                           itemkey   in varchar2,
                           actid     in number,
                           funcmode  in varchar2,
                           resultout in out nocopy varchar2)
is
  lEvent WF_EVENT_T;
  lNVal NUMBER;
  lDVal DATE;
  lTVal VARCHAR2 (4000);
  lAName VARCHAR2(30);
  lProperty VARCHAR2 (20);
  lParameter VARCHAR2(200);
  lType VARCHAR2 (20);
  lSubType VARCHAR2 (20);
  lFormat VARCHAR2 (20);
  lRefFlag VARCHAR2(8);

begin
   if (funcmode = 'RUN') then


      lEvent := wf_engine.getActivityAttrEvent(itemtype => itemtype,
                                               itemkey => itemkey,
                                               actid => actid,
                                               name => 'EVENT');

      lProperty := wf_engine.getActivityAttrText(itemtype => itemtype,
                                                 itemkey => itemkey,
                                                 actid => actid,
                                                 aname => 'PROPERTY');


      lAName := wf_engine.getActivityAttrText(itemtype => itemtype,
                                              itemkey => itemkey,
                                              actid => actid,
                                              aname => 'ATTR');
      if (lProperty = 'PRIORITY') then
         wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => LAName,
                                     avalue => lEvent.getPriority());
         lEvent.setPriority(lNVal);
      elsif (lProperty = 'SEND_DATE') then
         wf_engine.SetItemAttrDate(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => LAName,
                                   avalue => lEvent.getSendDate());
      elsif (lProperty = 'RECEIVE_DATE') then
         wf_engine.SetItemAttrDate(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => LAName,
                                   avalue => lEvent.getReceiveDate());
      elsif (lProperty = 'CORRELATION_ID') then
         wf_engine.SetItemAttrText(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => LAName,
                                   avalue => lEvent.getCorrelationID());
      elsif (lProperty = 'EVENT_NAME') then
         wf_engine.SetItemAttrText(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => LAName,
                                   avalue => lEvent.getEventName());
      elsif (lProperty = 'EVENT_KEY') then
         wf_engine.SetItemAttrText(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => LAName,
                                   avalue => lEvent.getEventKey());
      elsif (lProperty = 'FROM_AGENT_NAME') then
         wf_engine.SetItemAttrText(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => LAName,
                                   avalue => lEvent.getFromAgent().getName());
      elsif (lProperty = 'FROM_AGENT_SYSTEM') then
         wf_engine.SetItemAttrText(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => LAName,
                                   avalue => lEvent.getFromAgent().getSystem());
      elsif (lProperty = 'TO_AGENT_NAME') then
         wf_engine.SetItemAttrText(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => LAName,
                                   avalue => lEvent.getToAgent().getName());
      elsif (lProperty = 'TO_AGENT_SYSTEM') then
         wf_engine.SetItemAttrText(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => LAName,
                                   avalue => lEvent.getToAgent().getSystem());
      elsif (lProperty = 'FROM_AGENT') then
         wf_engine.SetItemAttrText(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => LAName,
                                   avalue =>
					lEvent.getFromAgent().getName()||
					'@'||lEvent.getFromAgent().getSystem());
      elsif (lProperty = 'TO_AGENT') then
         wf_engine.SetItemAttrText(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => LAName,
                                   avalue =>
                                        lEvent.getToAgent().getName()||
                                        '@'||lEvent.getToAgent().getSystem());
      elsif (lProperty = 'PARAMETER') then
         lParameter := wf_engine.getActivityAttrText(itemtype => itemtype,
                                                 itemkey => itemkey,
                                                 actid => actid,
                                                 aname => 'PARAMETER');

         wf_engine.SetItemAttrText(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => LAName,
                                   avalue =>
                                      lEvent.GetValueForParameter(lParameter));
      end if;
      resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
   end if; -- RUN

exception
  when others then
    Wf_Core.Context('Wf_Standard', 'GetEventProperty', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end GetEventProperty;


-- LaunchProcess
--   launches a process
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - NULL
-- ACTIVITY ATTRIBUTES REFERENCED
--   START_ITEMTYPE,START_ITEMKEY,START_PROCESS,START_USER_KEY,START_OWNER
procedure LaunchProcess
              (itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2) is
SItemtype varchar2(8);
SItemKey  varchar2(30);
SProcess  varchar2(30);
SUserKey  varchar2(320);
SOwner    varchar2(320);
Deferit   varchar2(2);
Launch_count number;
status    varchar2(8);
result    varchar2(30);

loop_flag BOOLEAN;
begin
  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;


  SItemtype := upper(Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ITEMTYPE'));
  Deferit   := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'DEFER');

  if SItemtype is null then
     wf_core.token('ITEMTYPE','NULL');
     wf_core.raise('WFSQL_ARGS');
  end if;

  if deferit = 'Y' then
     -- Check if this is the first or second execution of this activity.
     -- First -> result_code will be null (really null).
     -- Second -> result_code will be '#NULL' (set that way by execution 1).
     Wf_Item_Activity_Status.Result(itemtype, itemkey, actid, status, result);

     if (result = wf_engine.eng_null) then
       -- Second execution.
       -- Defer must have been picked up by the background engine,
       -- so return complete result.
       resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
     else
       -- Return deferred result
       resultout := wf_engine.eng_deferred;
       return;
     end if;
  end if;

  -- if we have got this far, go ahead and launch the process.
  SItemkey  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'ITEMKEY');
  SProcess  := upper(Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'PROCESS_NAME'));
  SUserkey  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'USER_KEY');
  SOwner    := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'OWNER');
  if sItemkey is not null then
     wf_engine.LaunchProcess(SItemtype, SItemkey, SProcess, SUserkey, SOwner);

  else
       begin
        launch_count := wf_engine.GetItemAttrNumber(
                          itemtype, itemkey, 'LAUNCH_COUNT');
       exception
        when others then
            --
            -- If item attribute does not exist then create it;
            --
            if ( wf_core.error_name = 'WFENG_ITEM_ATTR' ) then
                wf_engine.AddItemAttr(itemtype,itemkey, 'LAUNCH_COUNT');
                launch_count := 0;
            else
                raise;
            end if;
       end;

       loop_flag:=TRUE;
       while loop_flag loop
       begin
	 launch_count:=launch_count+1;
         -- imtetype:itemkey is unique so the new itemkey should be unique
	 sItemkey := itemtype||':'||itemkey||'-'||to_char(launch_count);
	 wf_engine.LaunchProcess(SItemtype, SItemkey, SProcess,
                                 SUserkey, SOwner);
         loop_flag:=FALSE;
	 exception
	  when others then
	      --
	      -- Dont raise error if its a dup name: instead we will loop
	      -- around and increment the counter.
	      if ( wf_core.error_name <> 'WFENG_ITEM_UNIQUE' ) then
		  raise;
	      end if;
       end;
       end loop;

       wf_engine.SetItemAttrNumber(
            itemtype, itemkey, 'LAUNCH_COUNT',launch_count);

  end if;


  resultout := wf_engine.eng_completed;

exception
  when others then
    Wf_Core.Context('Wf_Standard', 'LaunchProcess', itemtype,
                    itemkey, to_char(actid), Sitemtype||':'||Sitemkey||SProcess);
    raise;
end LaunchProcess;

-- LaunchProcess
--   Forks the item by creating a duplicate item with the same history.
--   The new forked item will be identical up to the point of this activity.
--   However this activity will be marked as NOTIFIED. It will be upto the user
--   to push it forward using CompleteActivity.
--   NOTE: this is not permitted for #SYNCH items.
-- IN
--   itemtype  - item type
--   itemkey   - item key
--   actid     - process activity instance id
--   funcmode  - execution mode
-- OUT
--   result    - NULL
-- ACTIVITY ATTRIBUTES REFERENCED
--   NEW_ITEMKEY   - the itemkey for the new item (required)
--   SAME_VERSION  - TRUE creates a duplicate, FALSE uses the latest version
procedure ForkItem(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2) is

sitemkey varchar2(30);
sameversion boolean;
sameversionFlag varchar2(1);

begin

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  if (itemkey = wf_engine.eng_synch) then
    Wf_Core.Token('OPERATION', 'Wf_Standard.ForkItem');
    Wf_Core.Raise('WFENG_SYNCH_DISABLED');
  end if;



  SItemkey := upper(Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'NEW_ITEMKEY'));
  SameVersionFlag   := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'SAME_VERSION');

  if SItemkey is null
  or SameVersionFlag is null then
     wf_core.token('ITEMKEY',Sitemkey);
     wf_core.token('SAME_VERSION',SameVersionFlag);
     wf_core.raise('WFSQL_ARGS');
  end if;

  if SameVersionFlag = 'T' then
     sameversion := TRUE;
  else
     sameversion := FALSE;
  end if;

  -- go ahead and create the new process.
  wf_engine.CreateForkProcess(Itemtype, Itemkey, SItemkey, SameVersion);

  -- start the new process
  wf_engine.StartForkProcess(Itemtype, SItemkey);

  resultout := wf_engine.eng_completed;

exception
  when others then
    Wf_Core.Context('Wf_Standard', 'ForkItem', itemtype,
                    itemkey, to_char(actid), Sitemkey);
    raise;
end ForkItem;

-- Noop
--   Does nothing
-- OUT
--   result    - NULL
procedure Noop(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2)
is
begin
  resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
exception
  when others then
    Wf_Core.Context('Wf_Standard', 'Noop', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end Noop;

-- Notify
--   Public wrapper to engine notification call
--   the engine notification package will retrieve the activity attributes.
-- OUT
--   result    - NULL
procedure Notify(itemtype   in varchar2,
                 itemkey    in varchar2,
                 actid      in number,
                 funcmode   in varchar2,
                 resultout  in out nocopy varchar2)
is
    msg varchar2(30);
    msgtype varchar2(8);
    prole varchar2(320);
    expand_role varchar2(1);

    colon pls_integer;
    avalue varchar2(240);

begin
   -- Do nothing in cancel or timeout mode
   if (funcmode <> wf_engine.eng_run) then
     resultout := wf_engine.eng_null;
     return;
   end if;


   -- lookup notification base info
   Wf_Activity.Notification_Info(itemtype, itemkey, actid, msg, msgtype,
                                 expand_role);

   -- see if this activity is already assigned to a role
   prole := Wf_Activity.Perform_Role(itemtype, itemkey, actid);

   -- if it isnt then use the value from activity attribute
   if prole is null then
      prole := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'PERFORMER');
   end if;

   if prole is null then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('ACTID', to_char(actid));
    Wf_Core.Raise('WFENG_NOTIFICATION_PERFORMER');
   end if;

   -- message name and expand roles will be null. Get these from attributes
   avalue := upper(Wf_Engine.GetActivityAttrText(itemtype, itemkey,
                 actid, 'MESSAGE'));

   -- let notification_send catch a missing message name.
   expand_role := nvl(Wf_Engine.GetActivityAttrText(itemtype, itemkey,
                 actid, 'EXPANDROLES'),'N');

   -- parse out the message type if given
   colon := instr(avalue, ':');
   if colon = 0   then
      msgtype := itemtype;
      msg := avalue;
   else
     msgtype := substr(avalue, 1, colon - 1);
     msg := substr(avalue, colon + 1);
   end if;


   -- Actually send the notification
   Wf_Engine_Util.Notification_Send(itemtype, itemkey, actid,
                       msg, msgtype, prole, expand_role,
                       resultout);


   --resultout is determined by Notification_Send as either
   --NULL                  if notification is FYI
   --NOTIFIED:notid:role   if notification requires responce


exception
  when others then
    Wf_Core.Context('Wf_Standard', 'Notify', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end Notify;


-- Block
--   Stop and wait for external completion
-- OUT
--   result    - NOTIFIED
procedure Block(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2)
is
begin
  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  resultout := wf_engine.eng_notified||':'||wf_engine.eng_null||
                 ':'||wf_engine.eng_null;
exception
  when others then
    Wf_Core.Context('Wf_Standard', 'Block', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end Block;


-- Block
--   Defers the thread by requesting a wait of zero seconds
-- OUT
--   result    - DEFERRED
--
procedure Defer(itemtype   in varchar2,
                itemkey    in varchar2,
                actid      in number,
                funcmode   in varchar2,
                resultout  in out nocopy varchar2)
is
  status    varchar2(8);
  result    varchar2(30);
begin
  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- Check if this is the first or second execution of this activity.
  -- First -> result_code will be null (really null).
  -- Second -> result_code will be '#NULL' (set that way by execution 1).
  Wf_Item_Activity_Status.Result(itemtype, itemkey, actid, status, result);

  if (result = wf_engine.eng_null) then
    -- Second execution.
    -- Defer must have been picked up by the background engine,
    -- so return complete result.
    resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
  else
    -- Return deferred result
    resultout := wf_engine.eng_deferred;
  end if;

exception
  when others then
    Wf_Core.Context('Wf_Standard', 'Defer', itemtype, itemkey,
                    to_char(actid), funcmode);
    raise;
end Defer;

-- Wait
--   Wait until given date and time.
-- OUT
--   result    - 'DEFERRED' or 'NULL'
--     'DEFERRED' if this is the first call and wait is beginning
--     'NULL' if this is the second call and wait period has completed
-- ACTIVITY ATTRIBUTES REFERENCED
--   WAIT_MODE - Lookup
--     'ABSOLUTE' - Wait until date in WAIT_ABSOLUTE_DATE
--     'RELATIVE' - Wait until time WAIT_RELATIVE_TIME after current date
--     'DAY_OF_WEEK' - Wait until next occurrence of day of week
--     'DAY_OF_MONTH' - Wait until next occurrence of day of month
--   WAIT_ABSOLUTE_DATE - Date
--     Date to wait until if WAIT_MODE = 'ABSOLUTE'
--     (Ignored if mode <> 'ABSOLUTE')
--   WAIT_RELATIVE_TIME - Number (expressed in <days>.<fraction of days>)
--     Time to wait after current date if WAIT_MODE = 'RELATIVE'
--     (Ignored if mode <> 'RELATIVE')
--   WAIT_DAY_OF_WEEK - Lookup
--     Next day of week (SUNDAY, MONDAY, etc) after current date
--     (Ignored if mode <> 'DAY_OF_WEEK')
--   WAIT_DAY_OF_MONTH - Lookup
--     Next day of month (1, 2, ..., 31, LAST) after current date
--     (Ignored if mode <> 'DAY_OF_MONTH')
--   WAIT_TIME - Date (format HH24:MI)
--     Time of day to complete activity.   Valid for all wait modes.
--     If null default time to 00:00 (midnight), except RELATIVE mode.
--     For RELATIVE mode, if time is null then complete relative to current
--     date and time.
-- NOTE:
--     For all WAIT_MODEs, the completion day is determined by the attribute
--   associated with the mode, and the completion time by the WAIT_TIME
--   attribute.
--     For all modes except RELATIVE, the completion time is WAIT_TIME on
--   the day selected by the mode's attribute.  If WAIT_TIME is null, the
--   default is 00:00 (midnight).
--     For RELATIVE mode, if WAIT_TIME is null the completion time is
--   figured relative to the current date and time.  If WAIT_TIME is not
--   null the completion time is WAIT_TIME on the day selected regardless
--   of the current time.
procedure Wait(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2)
is
  status    varchar2(8);
  result    varchar2(30);
  wait_mode varchar2(30);
  wait_date date;
  wakeup    date;
  daybuf    varchar2(30);
  time      date;
  wf_invalid_mode exception;
begin
  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- SYNCHMODE: Not allowed
  if (itemkey = wf_engine.eng_synch) then
    Wf_Core.Token('OPERATION', 'Wf_Standard.Wait');
    Wf_Core.Raise('WFENG_SYNCH_DISABLED');
  end if;

  -- Check if this is the first or second execution of this activity.
  -- First -> result_code will be null (really null).
  -- Second -> result_code will be '#NULL' (set that way by execution 1).
  Wf_Item_Activity_Status.Result(itemtype, itemkey, actid, status, result);

  if (result = wf_engine.eng_null) then
    -- Second execution.
    -- Wait is completed, return complete result.
    resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
  else
    -- First execution.
    wait_mode := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid,
                   'WAIT_MODE');

    if (wait_mode = 'ABSOLUTE') then
      -- Absolute date
      wakeup := Wf_Engine.GetActivityAttrDate(itemtype, itemkey, actid,
                   'WAIT_ABSOLUTE_DATE');

    elsif (wait_mode = 'RELATIVE') then
      -- Relative date.  Figure offset from sysdate.
      wakeup := Wf_Engine.GetActivityAttrNumber(itemtype, itemkey, actid,
                   'WAIT_RELATIVE_TIME') + sysdate;

    elsif (wait_mode = 'DAY_OF_WEEK') then
      -- Day of week.
      daybuf := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid,
                   'WAIT_DAY_OF_WEEK');
      wakeup := next_day(trunc(sysdate), daybuf);

    elsif (wait_mode = 'DAY_OF_MONTH') then
      daybuf := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid,
                   'WAIT_DAY_OF_MONTH');

      -- Figure wakeup time as offset from beginning of current month
      if (daybuf = 'LAST') then
        -- Set to last day of current month
        wakeup := last_day(to_date('01/'||to_char(sysdate, 'MM/YYYY'),
                                   'DD/MM/YYYY'));
      else
        -- Set to day x of current month
        wakeup := to_date('01/'||to_char(sysdate, 'MM/YYYY'),
                          'DD/MM/YYYY') + to_number(daybuf) - 1;
      end if;

      -- If wakeup is before current date, then shift to next month
      if (wakeup <= sysdate) then
        if (daybuf = 'LAST') then
          -- Set to last day of following month
          wakeup := last_day(add_months(to_date('01/'||to_char(sysdate,
                                                              'MM/YYYY'),
                                               'DD/MM/YYYY'), 1));
        else
          -- Set to day x of the following month
          wakeup := add_months(to_date('01/'||to_char(sysdate, 'MM/YYYY'),
                                       'DD/MM/YYYY'), 1)
                    + to_number(daybuf) - 1;

        end if;
      end if;
    else
      raise wf_invalid_mode;
    end if;

    -- Add the WAIT_TIME to the wakeup if specified
    time := Wf_Engine.GetActivityAttrDate(itemtype, itemkey, actid,
                   'WAIT_TIME');
    if (time is not null) then
      wakeup := to_date(to_char(wakeup, 'DD/MM/YYYY')||
                        to_char(time, ' HH24:MI'), 'DD/MM/YYYY HH24:MI');
    end if;

    -- Return deferred result with wakeup time appended
    resultout := wf_engine.eng_deferred||':'||
                 to_char(wakeup, wf_engine.date_format);
  end if;

exception
  when wf_invalid_mode then
    Wf_Core.Context('Wf_Standard', 'Wait', itemtype, itemkey,
                    to_char(actid), funcmode);
    Wf_Core.Token('COMMAND', wait_mode);
    Wf_Core.Raise('WFSQL_COMMAND');
  when others then
    Wf_Core.Context('Wf_Standard', 'Wait', itemtype, itemkey,
                    to_char(actid), funcmode);
    raise;
end Wait;


-- ResetError
--   Reset the status of an errored activity in an WFERROR process.
-- OUT
--   result    - 'NULL'
-- ACTIVITY ATTRIBUTES REFERENCED
--   COMMAND - 'SKIP' or 'RETRY'
--        'SKIP' marks the errored activity complete and continues processing
--        'RETRY' clears the errored activity and runs it again
--   RESULT - Result code to complete the activity with if COMMAND = 'SKIP'
procedure ResetError(itemtype   in varchar2,
                     itemkey    in varchar2,
                     actid      in number,
                     funcmode   in varchar2,
                     resultout  in out nocopy varchar2)
is
  cmd varchar2(8);
  result varchar2(30);
  err_itemtype varchar2(8);
  err_itemkey varchar2(240);
  err_actlabel varchar2(62);
  wf_invalid_command exception;
begin
  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- SYNCHMODE: Not allowed
  if (itemkey = wf_engine.eng_synch) then
    Wf_Core.Token('OPERATION', 'Wf_Standard.ResetError');
    Wf_Core.Raise('WFENG_SYNCH_DISABLED');
  end if;

  -- Get RETRY or SKIP command
  cmd := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'COMMAND');

  -- Get original errored activity info
  err_itemtype := Wf_Engine.GetItemAttrText(itemtype, itemkey,
                                            'ERROR_ITEM_TYPE');
  err_itemkey := Wf_Engine.GetItemAttrText(itemtype, itemkey,
                                           'ERROR_ITEM_KEY');
  err_actlabel := Wf_Engine.GetItemAttrText(itemtype, itemkey,
                                           'ERROR_ACTIVITY_LABEL');

  if (cmd = wf_engine.eng_retry) then
    -- Rerun activity
    Wf_Engine.HandleError(err_itemtype, err_itemkey, err_actlabel,
                          cmd, '');

/* Disallow skip mode because it is too difficult to
   assign and validate the RESULT value
  elsif (cmd = wf_engine.eng_skip) then
    -- Get result code
    result := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid,
              'RESULT');
    -- Mark activity complete and continue processing
    Wf_Engine.HandleError(err_itemtype, err_itemkey, err_actlabel,
                          cmd, result);
*/
  else
    raise wf_invalid_command;
  end if;

  resultout := wf_engine.eng_null;
exception
  when wf_invalid_command then
    Wf_Core.Context('Wf_Standard', 'ResetError', itemtype,
                    itemkey, to_char(actid), funcmode);
    Wf_Core.Token('COMMAND', cmd);
    Wf_Core.Raise('WFSQL_COMMAND');
  when others then
    Wf_Core.Context('Wf_Standard', 'ResetError', itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end ResetError;


-- RoleResolution
--   Resolve A Role which comprises a group to an individual
-- OUT
--   result    - 'NULL'
-- ACTIVITY ATTRIBUTES REFERENCED
--   COMMAND - 'LOAD_BALANCE' or 'ROUND_ROBIN'
--        'LOAD_BALANCE' Assigns to user with least open notifications
--        'ROUND_ROBIN'  Assigns notification to users sequencially
procedure RoleResolution(itemtype   in varchar2,
                         itemkey    in varchar2,
                         actid      in number,
                         funcmode   in varchar2,
                         resultout  in out nocopy varchar2) is
    cmd                     varchar2(30);
    wf_invalid_command      exception;
    actdate                 date;
    label                   varchar2(30);
    prole                   varchar2(320);
    --
    --  select all out-transitions of RoleResolution Activity
    --
    cursor  out_transitions is
    SELECT  wat.to_process_activity,
            wpa.activity_name,
            wpa.perform_role,
            wpa.perform_role_type
    FROM    wf_activity_transitions wat,
            wf_process_activities wpa
    WHERE   wat.from_process_activity       = actid
    AND     wat.result_code                 = wf_engine.eng_trans_default
    AND     wat.to_process_activity         = wpa.instance_id;
    --
    -- select number of activities the user currently has in worklist
    --
    cursor load_balance(user in varchar2, act_name varchar2 ) is
    select  count(1)
    from    wf_item_activity_statuses wias,
            wf_process_activities wpa
    where   wias.item_type          = itemtype
    and     wias.activity_status    = 'NOTIFIED'
    and     wias.process_activity   = wpa.instance_id
    and     wpa.activity_name       = act_name
    and     assigned_user           = user;
    --
    -- select the date of the last time the user was notified
    --
    cursor round_robin(user in varchar2, act_name varchar2 ) is
    select max(begin_date)
    from    wf_item_activity_statuses wias,
            wf_process_activities wpa
    where   wias.item_type          = itemtype
    and     wias.process_activity   = wpa.instance_id
    and     wpa.activity_name       = act_name
    and     wias.assigned_user      = user;
    --
begin
    --
    -- Do nothing in cancel mode
    --
    if (funcmode <> wf_engine.eng_run ) then
          resultout := wf_engine.eng_null;
          return;
    end if;

    -- SYNCHMODE: Not allowed
    if (itemkey = wf_engine.eng_synch) then
      Wf_Core.Token('OPERATION', 'Wf_Standard.AndJoin');
      Wf_Core.Raise('WFENG_SYNCH_DISABLED');
    end if;

    actdate :=  wf_item.active_date(itemtype, itemkey);
    cmd :=  Wf_Engine.GetActivityAttrText(itemtype,itemkey,actid,'METHOD');

    -- loop thru all out-transiations of role resolution activity
    for trans_rec in out_transitions loop
    declare
        usertab                 wf_directory.UserTable;
        min_assigned_activities number := -1;
        min_begin_date          date;
        assigned_performer      varchar2(320);
    begin
        --
        if (Wf_Activity.Type(itemtype, trans_rec.activity_name, actdate) =
            wf_engine.eng_notification) then
            -- Get perform_role from constant or itemattr value
            if (trans_rec.perform_role_type = 'CONSTANT') then
              prole := trans_rec.perform_role;
            else
              prole := Wf_Engine.GetItemAttrText(itemtype, itemkey,
                           trans_rec.perform_role);
            end if;
            wf_directory.GetRoleUsers(prole,usertab);
            if ( cmd = 'LOAD_BALANCE' ) then
                declare
                    assigned_activities     number := 0;
                    indx                    number := 1;
                begin
                    loop -- loop until NO_DATA_FOUND
                        open    load_balance(usertab(indx),
                                             trans_rec.activity_name);
                        fetch   load_balance into assigned_activities;
                        close   load_balance;

                        if ((assigned_activities < min_assigned_activities or
                             min_assigned_activities = -1) and
                            wf_directory.UserActive(usertab(indx))) then
                            min_assigned_activities := assigned_activities;
                            assigned_performer      := usertab(indx);
                        end if;

                        indx := indx + 1;
                    end loop;
                exception
                    when NO_DATA_FOUND then
                        null;
                end;
            elsif ( cmd = 'ROUND_ROBIN' ) then
                declare
                    begin_date      date;
                    indx            number :=1;
                begin
                    loop -- until access of usertab raises NO_DATA_FOUND
                        open    round_robin(usertab(indx),
                                            trans_rec.activity_name);
                        fetch   round_robin into begin_date;
                        close   round_robin;

                        if (begin_date is null) then
                            begin_date := to_date('01/01/0001','DD/MM/YYYY');
                        end if;

                        if ((begin_date < min_begin_date or
                             min_begin_date is null) and
                             wf_directory.UserActive(usertab(indx))) then
                            min_begin_date          := begin_date;
                            assigned_performer      := usertab(indx);
                        end if;

                        indx := indx + 1;
                    end loop;
                exception
                    when NO_DATA_FOUND then
                        null;
                end;
            else
                raise wf_invalid_command;
            end if;

            if ( assigned_performer is not null ) then
                --
                -- Retreieve instance_label for activity
                --
                select wpa.instance_label
                into   label
                from   wf_process_activities wpa
                where  wpa.instance_id = trans_rec.to_process_activity;

                wf_engine.AssignActivity(itemtype,itemkey,label,
                                         assigned_performer);

            end if;

            resultout := wf_engine.eng_null;
        end if;
    end;
    end loop;
exception
    when wf_invalid_command then
        wf_core.context('Wf_Standard', 'RoleResoluion',
                        itemtype, itemkey, to_char(actid), funcmode);
        wf_core.token('COMMAND', cmd);
        wf_core.raise('WFSQL_COMMAND');
    when others then
        wf_core.Context('Wf_Standard', 'RoleResolution',
                        itemtype, itemkey, to_char(actid), funcmode);
        raise;
end RoleResolution;


-- ContinueFlow
--   Signal Flow to continue
-- OUT
--   result    - 'NULL'
-- ACTIVITY ATTRIBUTES REFERENCED
--   WAITING_ACTIVITY
--   WAITING_FLOW
procedure ContinueFlow( itemtype   in varchar2,
                        itemkey    in varchar2,
                        actid      in number,
                        funcmode   in varchar2,
                        resultout  in out nocopy varchar2 ) is
    l_waiting_activity      varchar2(30);
    l_waiting_flow          varchar2(30);
    wf_invalid_command      exception;
begin
    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;

    -- SYNCHMODE: Not allowed
    if (itemkey = wf_engine.eng_synch) then
      Wf_Core.Token('OPERATION', 'Wf_Standard.AndJoin');
      Wf_Core.Raise('WFENG_SYNCH_DISABLED');
    end if;

    l_waiting_activity := upper(Wf_Engine.GetActivityAttrText(
                                itemtype, itemkey, actid,'WAITING_ACTIVITY'));
    l_waiting_flow     := Wf_Engine.GetActivityAttrText(
                              itemtype, itemkey, actid,'WAITING_FLOW');

    if ( l_waiting_flow = 'MASTER' ) then
        ContinueMasterFlow(itemtype,itemkey,actid,l_waiting_activity,resultout);
    elsif ( l_waiting_flow = 'DETAIL' ) then
        ContinueDetailFlow(itemtype,itemkey,actid,l_waiting_activity,resultout);
    else
        raise wf_invalid_command;
    end if;

exception
    when wf_invalid_command then
        Wf_Core.Context('Wf_Standard', 'ContinueFlow',
                        itemtype,itemkey, to_char(actid), funcmode);
        Wf_Core.Token('COMMAND', l_waiting_flow );
        Wf_Core.Raise('WFSQL_COMMAND');
    when others then
        Wf_Core.Context('Wf_Standard', 'ContinueFlow',
                        itemtype,itemkey, to_char(actid), funcmode);
        raise;
end continueflow;


-- WaitForFlow
--   Wait for flow to complete
-- OUT
--   result    - 'NULL'
-- ACTIVITY ATTRIBUTES REFERENCED
--   CONTINUATION_ACTIVITY
--   CONTINUATION_FLOW
procedure WaitForFlow(  itemtype   in varchar2,
                        itemkey    in varchar2,
                        actid      in number,
                        funcmode   in varchar2,
                        resultout  in out nocopy varchar2) is
    l_continuation_activity varchar2(30);
    l_continuation_flow     varchar2(30);
    wf_invalid_command      exception;
begin
    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;

    -- SYNCHMODE: Not allowed
    if (itemkey = wf_engine.eng_synch) then
      Wf_Core.Token('OPERATION', 'Wf_Standard.WaitForFlow');
      Wf_Core.Raise('WFENG_SYNCH_DISABLED');
    end if;

    l_continuation_activity := upper(Wf_Engine.GetActivityAttrText(
                                         itemtype, itemkey, actid,
                                         'CONTINUATION_ACTIVITY'));
    l_continuation_flow     := Wf_Engine.GetActivityAttrText(
                                   itemtype,itemkey,actid,'CONTINUATION_FLOW');

    if ( l_continuation_flow = 'MASTER' ) then
        WaitForMasterFlow(itemtype,itemkey,actid,
                          l_continuation_activity,resultout);
    elsif ( l_continuation_flow = 'DETAIL' ) then
        WaitForDetailFlow(itemtype,itemkey,actid,
                          l_continuation_activity,resultout);
    else
        raise wf_invalid_command;
    end if;

exception
    when wf_invalid_command then
        Wf_Core.Context('Wf_Standard', 'WaitForFlow',
                        itemtype,itemkey, to_char(actid), funcmode);
        Wf_Core.Token('COMMAND', l_continuation_flow );
        Wf_Core.Raise('WFSQL_COMMAND');
    when others then
        Wf_Core.Context('Wf_Standard', 'WaitForFlow',
                        itemtype,itemkey, to_char(actid), funcmode);
        raise;
end WaitForFlow;


-- LoopCounter
--     Count the number of times the activity has been visited.
-- OUT
--   result    -
-- ACTIVITY ATTRIBUTES REFERENCED
--      MAX_TIMES
procedure LoopCounter(  itemtype   in varchar2,
                        itemkey    in varchar2,
                        actid      in number,
                        funcmode   in varchar2,
                        resultout  in out nocopy varchar2) is
    max_times       pls_integer;
    loop_count      pls_integer;
begin
    --
    -- Do nothing in cancel mode
    --
    if (funcmode <> wf_engine.eng_run) then
        resultout := wf_engine.eng_null;
        return;
    end if;

    -- Get maximum times activity can be executed.
    max_times := wf_engine.GetActivityAttrNumber(
                     itemtype, itemkey, actid, 'MAX_TIMES');
    if ( max_times is null ) then
        wf_core.token('MAX_TIMES',max_times);
        wf_core.raise('WFSQL_ARGS');
    end if;

    begin
        loop_count := wf_engine.GetItemAttrNumber(
                          itemtype, itemkey, 'LOOP_COUNT'||':'||actid);
    exception
        when others then
            --
            -- If item attribute does not exist then create it;
            --
            if ( wf_core.error_name = 'WFENG_ITEM_ATTR' ) then
                wf_engine.AddItemAttr(
                    itemtype,itemkey, 'LOOP_COUNT'||':'||actid);
                loop_count := 0;
            else
                raise;
            end if;
    end;

    if ( loop_count >= max_times ) then
        loop_count := 0;
        resultout := 'EXIT';
    else
        loop_count := loop_count +1;
        resultout := 'LOOP';
    end if;

    wf_engine.SetItemAttrNumber(
        itemtype, itemkey, 'LOOP_COUNT'||':'||actid,loop_count);
exception
    when others then
        wf_core.context('Wf_Standard','LoopCount',
                        itemtype, itemkey, to_char(actid), funcmode);
        raise;
end loopcounter;


-- VoteForResultType
--     Standard Voting Function
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   result    -
--
-- USED BY ACTIVITIES
--
--   WFSTD.VoteForResultType
--
-- ACTIVITY ATTRIBUTES REFERENCED
--      VOTING_OPTION
--          - WAIT_FOR_ALL_VOTES  - Evaluate voting after all votes are cast
--                                - or a Timeout condition closes the voting
--                                - polls.  When a Timeout occurs the
--                                - voting percentages are calculated as a
--                                - percentage ofvotes cast.
--
--          - REQUIRE_ALL_VOTES   - Evaluate voting after all votes are cast.
--                                - If a Timeout occurs and all votes have not
--                                - been cast then the standard timeout
--                                - transition is taken.  Votes are calculated
--                                - as a percenatage of users notified to vote.
--
--          - TALLY_ON_EVERY_VOTE - Evaluate voting after every vote or a
--                                - Timeout condition closes the voting polls.
--                                - After every vote voting percentages are
--                                - calculated as a percentage of user notified
--                                - to vote.  After a timeout voting
--                                - percentages are calculated as a percentage
--                                - of votes cast.
--
--      "One attribute for each of the activities result type codes"
--
--          - The standard Activity VOTEFORRESULTTYPE has the WFSTD_YES_NO
--          - result type assigned.
--          - Thefore activity has two activity attributes.
--
--                  Y       - Percenatage required for Yes transition
--                  N       - Percentage required for No transition
--
procedure VoteForResultType(    itemtype   in varchar2,
                                itemkey    in varchar2,
                                actid      in number,
                                funcmode   in varchar2,
                                resultout  in out nocopy varchar2)
is
  -- Select all lookup codes for an activities result type
  cursor result_codes is
  select  wfl.lookup_code result_code
  from    wf_lookups wfl,
          wf_activities wfa,
          wf_process_activities wfpa,
          wf_items wfi
  where   wfl.lookup_type         = wfa.result_type
  and     wfa.name                = wfpa.activity_name
  and     wfi.begin_date          >= wfa.begin_date
  and     wfi.begin_date          < nvl(wfa.end_date,wfi.begin_date+1)
  and     wfpa.activity_item_type = wfa.item_type
  and     wfpa.instance_id        = actid
  and     wfi.item_key            = itemkey
  and     wfi.item_type           = itemtype;

  l_code_count    pls_integer;
  l_group_id      pls_integer;
  l_user          varchar2(320);
  l_voting_option varchar2(30);
  l_per_of_total  number;
  l_per_of_vote   number;
  l_per_code      number;
  per_success     number;
  max_default     pls_integer := 0;
  default_result  varchar2(30) := '';
  result          varchar2(30) := '';
  wf_invalid_command exception;
begin
  -- Do nothing unless in RUN or TIMEOUT modes
  if  (funcmode <> wf_engine.eng_run)
  and (funcmode <> wf_engine.eng_timeout) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- SYNCHMODE: Not allowed
  if (itemkey = wf_engine.eng_synch) then
    Wf_Core.Token('OPERATION', 'Wf_Standard.VotForResultType');
    Wf_Core.Raise('WFENG_SYNCH_DISABLED');
  end if;

  -- Get Notifications group_id for activity
  Wf_Item_Activity_Status.Notification_Status(itemtype,itemkey,actid,
      l_group_id,l_user);
  l_voting_option := Wf_Engine.GetActivityAttrText(itemtype,itemkey,
                         actid,'VOTING_OPTION');
  if (l_voting_option not in ('REQUIRE_ALL_VOTES', 'WAIT_FOR_ALL_VOTES',
                               'TALLY_ON_EVERY_VOTE')) then
    raise wf_invalid_command;
  end if;

  -- If the mode is one of:
  --   a. REQUIRE_ALL_VOTES
  --   b. WAIT_FOR_ALL_VOTES and no timeout has occurred
  -- and there are still open notifications, then return WAITING to
  -- either continue voting (in run mode) or trigger timeout processing
  -- (in timeout mode).
  if ((l_voting_option = 'REQUIRE_ALL_VOTES') or
      ((funcmode = wf_engine.eng_run) and
       (l_voting_option = 'WAIT_FOR_ALL_VOTES'))) then
    if (wf_notification.OpenNotificationsExist(l_group_id)) then
      resultout := wf_engine.eng_waiting;
      return;
    end if;
  end if;

  -- If here, then the mode is one of:
  --   a. TALLY_ON_ALL_VOTES
  --   b. WAIT_FOR_ALL_VOTES and timeout has occurred
  --   c. WAIT_FOR_ALL_VOTES and all votes are cast
  --   d. REQUIRE_ALL_VOTES and all votes are cast
  -- Tally votes.
  for result_rec in result_codes loop
    -- Tally Vote Count for this result code
    Wf_Notification.VoteCount(l_group_id,result_rec.result_code,
        l_code_count,l_per_of_total,l_per_of_vote);

    -- If this is timeout mode, then use the percent of votes cast so far.
    -- If this is run mode, then use the percent of total votes possible.
    if (funcmode = wf_engine.eng_timeout) then
      l_per_code := l_per_of_vote;
    else
      l_per_code := l_per_of_total;
    end if;

    -- Get percent vote needed for this result to succeed
    per_success := Wf_Engine.GetActivityAttrNumber(itemtype,itemkey,
                       actid,result_rec.result_code);

    if (per_success is null) then
      -- Null value means this is a default result.
      -- Save the default result with max code_count.
      if (l_code_count > max_default) then
        max_default := l_code_count;
        default_result := result_rec.result_code;
      elsif (l_code_count = max_default) then
        -- Tie for default result.
        default_result := wf_engine.eng_tie;
      end if;
    else
      -- If:
      --   a. % vote for this result > % needed for success OR
      --   b. % vote is 100% AND
      --   c. at least 1 vote for this result
      -- then this result succeeds.
      if (((l_per_code > per_success) or (l_per_code = 100)) and
          (l_code_count > 0))
      then
        if (result is null) then
          -- Save satisfied result.
          result := result_rec.result_code;
        else
          -- This is the second result to be satisfied.  Return a tie.
          resultout := wf_engine.eng_completed||':'||wf_engine.eng_tie;
          return;
        end if;
      end if;
    end if;
  end loop;

  if (result is not null) then
    -- Return the satisfied result code.
    resultout := wf_engine.eng_completed||':'||result;
  else
    -- If we get here no non-default results were satisfied.
    if (funcmode = wf_engine.eng_run and
        wf_notification.OpenNotificationsExist(l_group_id)) then
      -- Not timed out and still open notifications.
      -- Return waiting to continue voting.
      resultout := wf_engine.eng_waiting;
    elsif (default_result is not null) then
      -- Either timeout or all notifications closed
      -- Return default result if one found.
      resultout := wf_engine.eng_completed||':'||default_result;
    elsif (funcmode =  wf_engine.eng_timeout) then
      -- If Timeout has occured then return result Timeout so the Timeout
      -- transition will occur - BUG2885157
      resultout := wf_engine.eng_completed||':'||wf_engine.eng_timedout;
    else
      -- All notifications closed, and no default.
      -- Return nomatch
      resultout := wf_engine.eng_completed||':'||wf_engine.eng_nomatch;
    end if;
  end if;
  return;
exception
  when wf_invalid_command then
    Wf_Core.Context('Wf_Standard', 'VoteForResultType', itemtype,
                    itemkey, to_char(actid), funcmode);
    Wf_Core.Token('COMMAND', l_voting_option);
    Wf_Core.Raise('WFSQL_COMMAND');
  when others then
    Wf_Core.Context('Wf_Standard', 'VoteForResultType',itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end VoteForResultType;


-------------------------------------------------------------------------------
------------------------------- PRIVATE APIs ----------------------------------
-------------------------------------------------------------------------------

--
-- WaitForMasterFlow
--   Wait for Master flow to complete continuation activity
-- OUT
--   result    - 'NULL'
procedure WaitForMasterFlow(    itemtype                in varchar2,
                                itemkey                 in varchar2,
                                actid                   in number,
                                continuation_activity   in varchar2,
                                resultout               out nocopy varchar2 )
is
  l_parent_itemtype       varchar2(8);
  l_parent_itemkey        varchar2(240);
  l_activity_status       varchar2(30);

  colon pls_integer;
  process varchar2(30);
  label varchar2(30);
  instid pls_integer;
  dummy varchar2(50);
begin

  -- Parse activity arg into <process_name> and <instance_label> components.
  colon := instr(continuation_activity, ':');
  if (colon <> 0) then
    -- Activity arg is <process name>:<instance label>
    process := substr(continuation_activity, 1, colon-1);
    label := substr(continuation_activity, colon+1);
  else
    -- Activity arg is just instance label
    process := '';
    label := continuation_activity;
  end if;

    select  parent_item_type, parent_item_key
    into    l_parent_itemtype, l_parent_itemkey
    from    wf_items
    where   item_type       = WaitForMasterFlow.itemtype
    and     item_key    = WaitForMasterFlow.itemkey;


    begin
        select  'master activity not complete'
        into dummy
	from WF_ITEM_ACTIVITY_STATUSES WIAS, WF_PROCESS_ACTIVITIES WPA
	where WIAS.ITEM_TYPE = l_parent_itemtype
	and WIAS.ITEM_KEY = l_parent_itemkey
	and WIAS.PROCESS_ACTIVITY = WPA.INSTANCE_ID
	and WPA.INSTANCE_LABEL = label
	and WPA.PROCESS_NAME = nvl(process, WPA.PROCESS_NAME)
	and wias.activity_status  in (wf_engine.eng_completed, wf_engine.eng_active);
    exception
        -- When not complete return NOTIFIED to cause engine to stall
        when NO_DATA_FOUND then
            resultout := wf_engine.eng_notified||':'||wf_engine.eng_null|| ':'||wf_engine.eng_null;
            return;
    end;
    resultout := wf_engine.eng_null;
exception
    when others then
        wf_core.context('Wf_Standard', 'WaitForMasterFlow',
                        itemtype,itemkey,to_char(actid),continuation_activity);
        raise;
end WaitForMasterFlow;


-- WaitForDetailFlow
--   Wait for detail flows to complete continuation activity
-- OUT
--   result    - 'NULL'
procedure WaitForDetailFlow(    itemtype                in varchar2,
                                itemkey                 in varchar2,
                                actid                   in number,
                                continuation_activity   in varchar2,
                                resultout               out nocopy varchar2) is
cursor  child_flows is
    -- select all active children of parent flow
    select  count(1)
    from    wf_items
    where   parent_item_type    = itemtype
    and     parent_item_key     = itemkey
    and     end_date        is null;

cursor child_activities (itemtype varchar2, itemkey varchar2,
                         pname varchar2, plabel varchar2) is
    select count(1)
    from WF_ITEM_ACTIVITY_STATUSES WIAS, WF_PROCESS_ACTIVITIES WPA
    where (WIAS.ITEM_TYPE, WIAS.ITEM_KEY) in (select item_type,item_key
                         from wf_items
                         where  parent_item_type =itemtype
                         and parent_item_key  =itemkey
                         and end_date is null)
    and WIAS.PROCESS_ACTIVITY = WPA.INSTANCE_ID
    and WPA.INSTANCE_LABEL = plabel
    and WPA.PROCESS_NAME = nvl(pname, WPA.PROCESS_NAME)
    and wias.activity_status  in (wf_engine.eng_completed, wf_engine.eng_active);

cursor current_process (p_actid number) is
  select instance_label
  from   wf_process_activities
  where  instance_id = p_actid;

  colon pls_integer;
  process varchar2(30);
  label varchar2(30);
  instid pls_integer;
  number_active   pls_integer;
  number_complete pls_integer;
  l_childCount number;
  l_labelCount number;
  l_waitLabel varchar2(30);
  --Bug 14784055. Need to validate the activity LABEL is not too large
  ValTooLarge EXCEPTION;
  pragma exception_init(ValTooLarge, -01401);
  ValTooLargeNew EXCEPTION;
  pragma exception_init(ValTooLargeNew, -12899);
  l_module varchar2(20) := 'WaitForDetailFlow';

begin
  -- Parse activity arg into <process_name> and <instance_label> components.
  colon := instr(continuation_activity, ':');
  if (colon <> 0) then
     -- Activity arg is <process name>:<instance label>
     process := substr(continuation_activity, 1, colon-1);
     label := substr(continuation_activity, colon+1);
  else
     -- Activity arg is just instance label
     process := '';
     label := continuation_activity;
  end if;

  --Retrieve the label for the WaitForFlow activity.
  open current_process(actid);
    fetch current_process into l_waitLabel;
  close current_process;

  l_labelCount := WF_ENGINE.GetItemAttrNumber(itemType, itemKey,
                                              '#CNT_'||l_waitLabel, TRUE);
  if (l_labelCount is NULL) then
    l_childCount := WF_ENGINE.GetItemAttrNumber(itemType, itemKey,
                                                '#WAITFORDETAIL', TRUE);
    if (l_childCount is NULL) then --Fall back to the old path.
      open   child_flows;
      fetch  child_flows into number_active;
      close  child_flows;

      if (number_active < 1) then
        resultout := wf_engine.eng_null;
      else
        open   child_activities(itemtype, itemkey, process, label);
        fetch  child_activities into number_complete;
        close  child_activities;

        if number_active > number_complete then
          resultout := wf_engine.eng_notified||':'||
                       wf_engine.eng_null||':'||wf_engine.eng_null;
        else
          resultout := wf_engine.eng_null;
        end if;

      end if; --There are no children
    else --#WAITFORDETAIL exists
      begin
        WF_ENGINE.AddItemAttr(itemtype=>WaitForDetailFlow.itemtype,
                              itemkey=>WaitForDetailFlow.itemkey,
                              aname=>'#CNT_'||l_waitLabel,
                              number_value=>l_childCount);
      exception
        when ValTooLarge OR ValTooLargeNew then
          Wf_Core.Context('WF_ENGINE', l_module, WaitForDetailFlow.itemtype,
                          WaitForDetailFlow.itemkey);
          WF_CORE.Token('LABEL', '#CNT_'||l_waitLabel);
          WF_CORE.Token('LENGTH', 30);
          WF_CORE.Raise('WFENG_LABEL_TOO_LARGE');
      end;
      if (l_childCount > 0) then
        resultout := wf_engine.eng_notified||':'||
                     wf_engine.eng_null||':'||wf_engine.eng_null;
      else
        resultout := wf_engine.eng_null;
      end if; --l_childCount > 0
    end if; -- #WAITFORDETAIL
  elsif (l_labelCount > 0) then
    --The #CNT_ attribute exists and is 1 or greater so this will remain
    --notified.
    resultout := wf_engine.eng_notified||':'||wf_engine.eng_null||
                 ':'||wf_engine.eng_null;

  else --The labelcount exists and is < 1 so we can continue.
     resultout := wf_engine.eng_null;
  end if;


exception
    when others then
        wf_core.context('Wf_Standard', 'WaitForDetailFlow',
                        itemtype,itemkey,to_char(actid),continuation_activity);
        raise;
end WaitForDetailFlow;


-- ContinueDetailFlow
--   Signal Detail Flows to continue
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The process activity(instance id).
--   waiting_activity - The Name of the activity that in waiting
-- OUT
--   resultout    - 'NULL'
procedure ContinueDetailFlow(   itemtype                in varchar2,
                                itemkey                 in varchar2,
                                actid                   in number,
                                waiting_activity        in varchar2,
                                resultout               out nocopy varchar2
                                 ) is
--
cursor child_flows is
    --
    -- select all active children of parent flow
    --
    select  item_type, item_key
    from    wf_items
    where   parent_item_type    = itemtype
    and     parent_item_key     = itemkey
    and     end_date        is null;
--
begin
    for child_flows_rec in child_flows loop
        --
        -- Complete Waiting Activity in All Detail Flows
        --
        begin
            wf_engine.CompleteActivity(child_flows_rec.item_type,
                child_flows_rec.item_key, waiting_activity,wf_engine.eng_null);
        exception
            when others then
            -- If call to CompleteActivity cannot find activity, return null
            -- As either the detail flows does not have a waiting activity OR
            -- the detail flow has not reach the waiting activity
            if ( wf_core.error_name = 'WFENG_NOT_NOTIFIED' ) then
                wf_core.clear;
            else
                raise;
            end if;
        end;
    end loop;

    ContinueDetailFlow.resultout := wf_engine.eng_null;

exception
    when others then
        wf_core.context('Wf_Standard','ContinueDetailFlow',
                        itemtype, itemkey, to_char(actid),waiting_activity);
        raise;
end ContinueDetailFlow;


-- ContinueMasterFlow
--   Signal Master Flow to continue if all Detail flows have
--   executed Continuation Activity
-- OUT
--   result    - 'NULL'
procedure ContinueMasterFlow(   itemtype                in varchar2,
                                itemkey                 in varchar2,
                                actid                   in number,
                                waiting_activity        in varchar2,
                                resultout               in out nocopy varchar2) is


  l_activity_status      varchar2(8);
  l_parent_itemtype      varchar2(8);
  l_parent_itemkey       varchar2(240);
  label                  varchar2(30);
  number_active   pls_integer;
  number_complete pls_integer;

  -- CTILLEY bug 1941013
  l_parent_context varchar2(2000);

  cursor  child_flows_mwf is
      -- This cursor is used if there are multiple WaitForFlow Activities in the
      -- parent flow (the parent_context must be set).  CTILLEY bug 1941013
      -- select all active children of parent flow excluding current work item
      select  count(1)
      from    wf_items
      where   parent_item_type    = l_parent_itemtype
      and     parent_item_key     = l_parent_itemkey
      and     parent_context      = l_parent_context
      and     (item_type          <> ContinueMasterFlow.itemtype
               or item_key        <> ContinueMasterFlow.itemkey)
      and     end_date        is null;

  cursor  child_flows2 is
      -- select all active children of parent flow excluding current work item
      select  count(1)
      from    wf_items
      where   parent_item_type    = l_parent_itemtype
      and     parent_item_key     = l_parent_itemkey
      and     (item_type          <> ContinueMasterFlow.itemtype
               or item_key        <> ContinueMasterFlow.itemkey)
      and     end_date        is null;

  cursor child_activities2 is
      select count(1)
      from  WF_ITEM_ACTIVITY_STATUSES WIAS, WF_PROCESS_ACTIVITIES WPA,
            WF_ITEMS WI
      where WIAS.ITEM_TYPE      = itemtype
      and   WIAS.ITEM_KEY       = WI.item_key
      and   WI.parent_item_type = l_parent_itemtype
      and   WI.parent_item_key  = l_parent_itemkey
      and  (WI.item_type <> itemtype OR WI.item_key <> itemkey )
      and   WI.end_date is null
      and   WIAS.PROCESS_ACTIVITY = WPA.INSTANCE_ID
      and   WPA.INSTANCE_LABEL = label
      and   wias.activity_status  in (wf_engine.eng_completed,
            wf_engine.eng_active);

  dummy varchar2(240);
  status varchar2(8);
  result varchar2(30);
  l_count number;
  l_defer varchar2(4000);
  l_childwaiting number;
  --Bug 14784055. Need to validate the activity LABEL is not too large
  ValTooLarge EXCEPTION;
  pragma exception_init(ValTooLarge, -01401);
  ValTooLargeNew EXCEPTION;
  pragma exception_init(ValTooLargeNew, -12899);
  l_module varchar2(20) := 'ContinueMasterFlow';
  l_activity_label varchar2(50);

begin
  --
  -- select parent details
  --
  select  parent_item_type,   parent_item_key, parent_context
  into    l_parent_itemtype, l_parent_itemkey, l_parent_context
  from    wf_items
  where   item_type = ContinueMasterFlow.itemtype
  and     item_key  = ContinueMasterFlow.itemkey;

  select  instance_label
  into    label
  from    wf_process_activities
  where   instance_id     = actid;

  -- Check if this is the first or second execution of this activity.
  -- First -> result_code will be null (really null).
  -- Second -> result_code will be '#NULL' (set that way by execution 1).
  Wf_Item_Activity_Status.Result(itemtype, itemkey, actid, status, result);

  if (result = wf_engine.eng_null) then
    -- Second execution.
    -- ContinueFlow() completed and was deferred.
    resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
    return;
  else
    --First execution.

    -- lock the parent item, so only one child can execute this at the time.
    select  item_key
    into    dummy
    from    wf_items
    where   item_type    = l_parent_itemtype
    and     item_key     = l_parent_itemkey
    for update;

    --Nulling out the #LBL_ attribute, if it does not exist, we will check the
    --parent flow for #WAITFORDETAIL to see if we can create the #LBL_
    --attribute.
    l_activity_label := '#LBL_'||waiting_activity;
    if NOT (WF_ENGINE.SetItemAttrText2(ContinueMasterFlow.itemtype,
                                       ContinueMasterFlow.itemkey,
                                       l_activity_label,
                                       NULL)) then
      l_childwaiting := WF_ENGINE.GetItemAttrNumber(
                          l_parent_itemtype, l_parent_itemkey,
                          '#WAITFORDETAIL', TRUE);
      if (l_childwaiting is NOT NULL) then
        --The parent has #WAITFORDETAIL, so we can create the #LBL_ attribute
        WF_ENGINE.AddItemAttr(ContinueMasterFlow.itemtype,
                              ContinueMasterFlow.itemkey,
                              l_activity_label, NULL);
    else --#WAITFORDETAIL does not exist in the parent, so we will fall back
           --to old code path.
        --  If parent_context is not set then there is one WaitForFlow Activity
        --  use original cursor.

        if (l_parent_context is null) then
          open   child_flows2;
          fetch  child_flows2 into number_active;
          close  child_flows2;
        else
          open child_flows_mwf;
          fetch  child_flows_mwf into number_active;
          close  child_flows_mwf;
        end if;

        if (number_active < 1) then
          begin
            wf_engine.CompleteActivity(l_parent_itemtype,l_parent_itemkey,
                                       waiting_activity,wf_engine.eng_null);
            resultout := wf_engine.eng_null;
          exception
            when OTHERS then
              if ( wf_core.error_name = 'WFENG_NOT_NOTIFIED' ) then
                wf_core.clear;
                ContinueMasterFlow.resultout := wf_engine.eng_null;
              else
                raise;
              end if;
          end;
        else
          open   child_activities2;
          fetch  child_activities2 into number_complete;
          close  child_activities2;

          begin
            if number_active = number_complete then
              wf_engine.CompleteActivity(l_parent_itemtype,l_parent_itemkey,
                                         waiting_activity,wf_engine.eng_null);
            end if;
            resultout := wf_engine.eng_null;

          exception
            when others then
              --
              -- If call to CompleteActivity cannot find activity, return
              -- null and wait for master flow
              --
              if ( wf_core.error_name = 'WFENG_NOT_NOTIFIED' ) then
                  wf_core.clear;
                  ContinueMasterFlow.resultout := wf_engine.eng_null;
              else
                  raise;
              end if;
          end;
        end if; -- number_active was more than 0
        return; -- done with old code path

      end if; --#WAITFORDETAIL exists in the parent
    end if; --#LBL_ is not null

    -- If we come to here, we must be progressing in the new code path.
    --Now we will try to decrement the corresponding #CNT_ attribute if it
    --exists, and will create it with a value of 0 if it does not yet exist.
    l_activity_label := '#CNT_'||waiting_activity;
    l_count := WF_ENGINE.AddToItemAttrNumber(l_parent_itemtype,
                                             l_parent_itemkey,
                                             l_activity_label, -1);

    if (l_count is NULL) then
      WF_ENGINE.AddItemAttr(itemtype=>l_parent_itemtype,
                            itemkey=>l_parent_itemkey,
                            aname=>l_activity_label,
                            number_value=>l_childwaiting - 1);
    elsif (l_count < 1) then
      begin
        wf_engine.CompleteActivity(l_parent_itemtype,l_parent_itemkey,
                                      waiting_activity,wf_engine.eng_null);
      exception
        when OTHERS then
          if ( wf_core.error_name = 'WFENG_NOT_NOTIFIED' ) then
            wf_core.clear;
            ContinueMasterFlow.resultout := wf_engine.eng_null;
          else
            raise;
          end if;
        end;
    end if;

    l_defer := WF_ENGINE.GetActivityAttrText(itemtype, itemkey, actid,
                                               '#HINT', TRUE);

    --If #HINT is not set to 'NO_DEFER', or is null we will set the
    --threshold to cause the next activity to defer.
    if ((l_defer is null) or (l_defer <> 'NO_DEFER')) then
      resultout := wf_engine.eng_deferred;
    else
      resultout := wf_engine.eng_null;
    end if;

  end if; --First execution

exception
    when ValTooLarge OR ValTooLargeNew then
      Wf_Core.Context('WF_ENGINE', l_module, ContinueMasterFlow.itemtype,
                      ContinueMasterFlow.itemkey);
      WF_CORE.Token('LABEL', l_activity_label);
      WF_CORE.Token('LENGTH', 30);
      WF_CORE.Raise('WFENG_LABEL_TOO_LARGE');

    when others then
        wf_core.context('Wf_Standard', 'ContinueMasterFlow',
                        itemtype, itemkey, to_char(actid), waiting_activity);
        raise;
end ContinueMasterFlow;




-- -------------------------------------------------------------------
-- InitializeErrors
--   checks if an item attribute for Workflow administrator exists in
--   the item that just errored out. If it does, then it uses this
--   role to send notifications to, overriding the default role
--   in this item.
-- NOTE: the item attibute in the workflow-in-error must have an
-- internal name of WF_ADMINISTRATOR.
--
-- Called by default error process.
-- -------------------------------------------------------------------
PROCEDURE InitializeErrors(     itemtype        VARCHAR2,
                                itemkey         VARCHAR2,
                                actid           NUMBER,
                                funcmode        VARCHAR2,
                                result          OUT NOCOPY VARCHAR2 ) IS

  l_error_itemtype      VARCHAR2(8);
  l_error_itemkey       VARCHAR2(240);
  l_error_name          VARCHAR2(30);
  l_error_msg           VARCHAR2(2000);
  l_timeout             PLS_INTEGER;
  l_administrator       VARCHAR2(100);

BEGIN

  IF (funcmode = 'RUN') THEN

    --
    -- Get the type and the key of the process that errored out
    -- these were set in the erroring out process by Execute_Error_Process
    --
    l_error_itemkey := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_ITEM_KEY' );
    l_error_itemtype := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_ITEM_TYPE' );

    --
    -- Check if the workflow administrator exists
    -- If it does, then assign the notification to this role
    --

        begin
              --if this item type doesnt exist an exception is raised.
              l_administrator := WF_ENGINE.GetItemAttrText(
                                itemtype        => l_error_itemtype,
                                itemkey         => l_error_itemkey,
                                aname           => 'WF_ADMINISTRATOR' );

              --<rwunderl:2775132> Put first assignemt in their own block
              --in case DEFAULT_RESET_ERROR_NTF does not exist.
              begin
                wf_engine.AssignActivity(itemtype,itemkey,
                                         'DEFAULT_RESET_ERROR_NTF',
                                         l_administrator);
              exception
                when OTHERS then
                  null; --We only null this exception because the parent
                        --block nulls the expeption.
              end;

              wf_engine.AssignActivity(itemtype,itemkey,'RETRY_ONLY_NTF',
                                         l_administrator);

        exception
          when others then null;
        end;

    --
    -- Check if a timeout value exists
    -- If it does, then set the error timeout
    --

        begin
              --if this item type doesnt exist an exception is raised.
              l_timeout  := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => l_error_itemtype,
                                itemkey         => l_error_itemkey,
                                aname           => 'ERROR_TIMEOUT' );
              wf_engine.SetItemAttrNumber(itemtype,itemkey,'TIMEOUT_VALUE',l_timeout);
              exception
                 when others then null;
        end;

     result := wf_engine.eng_completed;
  ELSIF (funcmode = 'CANCEL') THEN
     result := wf_engine.eng_completed;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context('WF_STANDARD', 'InitializeErrors',
                      itemtype, itemkey, actid, funcmode);
    RAISE;
END InitializeErrors;

-- -------------------------------------------------------------------
-- CheckErrorActive
--   checks if an error is still active and returns TRUE/FALSE.
--   Use this in an error process to exit out of a timeout loop
-- Called by default error process.
-- -------------------------------------------------------------------
PROCEDURE CheckErrorActive(     itemtype        IN VARCHAR2,
                                itemkey         IN VARCHAR2,
                                actid           IN NUMBER,
                                funcmode        IN VARCHAR2,
                                result          OUT NOCOPY VARCHAR2 ) IS

  l_error_itemtype      VARCHAR2(8);
  l_error_itemkey       VARCHAR2(240);
  l_error_actid         NUMBER;
  status                VARCHAR2(30);

  cursor activity_status (litemtype varchar2, litemkey  varchar2, lactid number ) is
  select WIAS.ACTIVITY_STATUS
  from WF_ITEM_ACTIVITY_STATUSES WIAS
  where WIAS.ITEM_TYPE = litemtype
  and WIAS.ITEM_KEY = litemkey
  and WIAS.PROCESS_ACTIVITY = lactid;


BEGIN

  IF (funcmode = 'RUN') THEN

    --
    -- Get the type and the key of the process that errored out
    -- these were set in the erroring out process by Execute_Error_Process
    --
    l_error_itemkey := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_ITEM_KEY' );
    l_error_itemtype := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_ITEM_TYPE' );

    l_error_actid := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_ACTIVITY_ID' );

    open activity_status(l_error_itemtype, l_error_itemkey, l_error_actid);
    fetch activity_status into status;
    close activity_status;

    if status = 'ERROR' then
       result:='T';
    else
       result:='F';
    end if;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context('WF_STANDARD', 'CheckErrorActive',
                      itemtype, itemkey, actid, funcmode);
    RAISE;
END CheckErrorActive;
-- -------------------------------------------------------------------
-- InitializeEventError
--   Called by the  Error Process, this sets up various
--   item attributes.
-- -------------------------------------------------------------------
PROCEDURE InitializeEventError( itemtype        VARCHAR2,
                                itemkey         VARCHAR2,
                                actid           NUMBER,
                                funcmode        VARCHAR2,
                                resultout          OUT NOCOPY VARCHAR2 ) IS
  l_event_t		wf_event_t;
  l_error_name		varchar2(240);
  l_error_type		varchar2(240);
  l_error_message	varchar2(2000);
  l_error_stack		varchar2(2000);
  l_subscription 	RAW(16);
  l_url                 varchar2(4000);
  l_eventdataurl        varchar2(4000);
  l_source		varchar2(8);


begin

  IF (funcmode = 'RUN') THEN
    --
    -- Get the Event Item Attribute
    --

    l_event_t := WF_ENGINE.GetItemAttrEvent(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                name           => 'EVENT_MESSAGE' );
    --
    -- Get the Errored Subscription GUID
    --
    l_subscription := l_event_t.GetErrorSubscription();

    --
    -- Get the Error Type from the Item Attribute - set by Engine
    --
    l_error_type := WF_ENGINE.GetItemAttrText(
				itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'ERROR_TYPE');
    --
    -- If the error type is null, this must be an UNEXPECTED event
    --
    IF l_error_type IS NULL THEN
      l_error_type := 'UNEXPECTED';
      wf_engine.SetItemAttrText(itemtype        => itemtype,
                                itemkey       => itemkey,
                                aname         => 'ERROR_TYPE',
                                avalue        => l_error_type);
    END IF;

    --
    -- Determine if this event is LOCAL or EXTERNAL
    --
    if l_subscription is not null then
      -- If a subscription found, look at its source
      select source_type into l_source
      from wf_event_subscriptions
      where guid = l_subscription;

      if l_source = 'ERROR' then
	l_source := 'LOCAL';
      end if;
    else
      -- Since no subscription found, look at from agent details
      begin
        select 'LOCAL' into l_source
        from wf_systems ws
        where ws.guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'))
        and   ws.name = nvl(l_event_t.GetFromAgent().GetSystem(),ws.name);
      exception
        when no_data_found then
          l_source := 'EXTERNAL';
      end;
    end if;

    --
    -- Get the Error Message, or set it if UNEXPECTED
    --
    l_error_message := substr(l_event_t.GetErrorMessage(),1,2000);
    IF (l_error_message is null) THEN
      -- Bug 10126673: Show 'NO_ERROR_MESSAGE' message token when error message is null
      l_error_message := wf_core.translate('NO_ERROR_MESSAGE');
    END IF;

    -- Get the Error Stack
    l_error_stack := substr(l_event_t.GetErrorStack(),1,2000);

    -- Get the Errored Subscription GUID
    l_subscription := l_event_t.GetErrorSubscription();

    -- Generate the URL
    wf_event_html.GetFWKEvtSubscriptionUrl(l_subscription, l_url);
    l_eventdataurl := wf_oam_util.GetViewXMLURL(p_eventattribute => 'EVENT_MESSAGE',
                                                p_itemtype => itemtype,
                                                p_itemkey => itemkey);

    -- Set the Item Attributes

    wf_engine.SetItemAttrText(itemtype        => itemtype,
                                itemkey       => itemkey,
                                aname         => 'ERROR_MESSAGE',
                                avalue        => l_error_message);

    wf_engine.SetItemAttrText(itemtype        => itemtype,
                                itemkey       => itemkey,
                                aname         => 'ERROR_STACK',
				avalue	      => l_error_stack);

    -- Set the PL/SQL Document for the Event Details
    wf_engine.SetItemAttrText(itemtype        => itemtype,
                                itemkey       => itemkey,
                                aname         => 'EVENT_DETAILS',
				avalue        => 'PLSQL:WF_STANDARD.EVENTDETAILS/'||ItemType||':'||ItemKey);

    wf_engine.SetItemAttrText(itemtype      => itemtype,
                              itemkey       => itemkey,
                              aname         => 'ERROR_DETAILS',
                              avalue        => 'PLSQL:WF_STANDARD.ErrorDetails/'||ItemType||':'||ItemKey);

    wf_engine.SetItemAttrText(itemtype      => itemtype,
                              itemkey       => itemkey,
                              aname         => 'SUBSCRIPTION_DETAILS',
                              avalue        => 'PLSQL:WF_STANDARD.SubscriptionDetails/'||ItemType||':'||ItemKey);

    -- Set the Value for the Error Subscription URL
    wf_engine.SetItemAttrText(itemtype        => itemtype,
                                itemkey       => itemkey,
                                aname         => 'EVENT_SUBSCRIPTION',
                                avalue        => l_url);
    -- Set the Value for the Event Data URL
    wf_engine.SetItemAttrText(itemtype        => itemtype,
                                itemkey       => itemkey,
                                aname         => 'EVENT_DATA_URL',
				avalue        => l_eventdataurl);

    IF l_error_type IN ('ERROR','UNEXPECTED') THEN
      IF l_source = 'LOCAL' THEN
	resultout := 'EVENT_ERROR';
      ELSE
        resultout := 'EVENT_EXTERNAL_ERROR';
      END IF;
    ELSE
	resultout := 'EVENT_WARNING';
    END IF;

  ELSIF (funcmode = 'CANCEL') THEN
     resultout := wf_engine.eng_completed;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context('WF_STANDARD', 'InitializeEventError',
                      itemtype, itemkey, actid, funcmode);
    RAISE;
END InitializeEventError;
-- --------------------------------------------------------------------
-- EventDetails
--   PL/SQL Document for Event Attributes
-- --------------------------------------------------------------------
procedure EventDetails   ( document_id   in varchar2,
                           display_type  in varchar2,
                           document      in out nocopy varchar2,
                           document_type in out nocopy varchar2) IS

  ItemType	varchar2(30);
  ItemKey	varchar2(30);

  l_to_agent	varchar2(60);
  l_to_system	varchar2(60);
  l_from_agent	varchar2(60);
  l_from_system	varchar2(60);
  l_priority	varchar2(10);
  l_send_date	date;
  l_send_date_text	varchar2(60);
  l_receive_date date;
  l_receive_date_text	varchar2(60);

  i		pls_integer;

  l_event_t	wf_event_t;
  l_parmlist_t	wf_parameter_list_t;
  l_cells       wf_notification.tdType;
  j             number;
  l_result      varchar2(32000);

begin

  -- parse document_id for the ':' dividing item type name from item key value
  -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
  -- release 2.5
  ItemType := nvl(substr(document_id, 1, instr(document_id,':')-1),'WFERROR');
  ItemKey  := substr(document_id
		, instr(document_id,':')+1);



  l_event_t := wf_engine.GetItemAttrEvent(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                name            => 'EVENT_MESSAGE' );

  --
  -- Get the Agent Details, we don't want any errors if the Agent
  -- didn't get populated with anything
  --
  if l_event_t.To_Agent is not null then
	l_to_agent := l_event_t.GetToAgent().GetName();
	l_to_system := l_event_t.GetToAgent().GetSystem();
  end if;

  if l_event_t.From_Agent is not null then
	l_from_agent := l_event_t.GetFromAgent().GetName();
	l_from_system := l_event_t.GetFromAgent().GetSystem();
  end if;

  --
  -- Get any date values and format if required
  --
  l_send_date := l_event_t.GetSendDate();

  IF l_send_date IS NOT NULL THEN
	l_send_date_text := WF_NOTIFICATION_UTIL.GetCalendarDate(-1, l_send_date, null, true);
  END IF;

  l_receive_date := l_event_t.GetReceiveDate();

  IF l_receive_date IS NOT NULL THEN
	l_receive_date_text := WF_NOTIFICATION_UTIL.GetCalendarDate(-1, l_receive_date, null, true);
  END IF;

  --
  -- Get the Priority
  --
  l_priority := l_event_t.GetPriority();

  --
  -- Build up the PL/SQL Document depending on the User Mail Preference
  --
  -- bug 6955474
  -- Using WF_NOTIFICATION.NTF_Table API to maintain consistency with BLAF
  --
  -- Build the Table
  if (display_type = wf_notification.doc_html) then
    i := 1;
    l_cells(i) := wf_core.translate('WF_EVENT_HEADING');
    l_cells(i) := 'S30%:'||l_cells(i);

    i := i + 1;
    l_cells(i) := wf_core.translate('WF_VALUE');
    l_cells(i) := 'S70%:'||l_cells(i);

    i := i + 1;
    l_cells(i) := 'S:'||wf_core.translate('WF_EVENT_NAME');
    i := i + 1;
    l_cells(i) := 'S:'||nvl(l_event_t.GetEventName(),'&'||'nbsp');

    i := i + 1;
    l_cells(i) := 'S:'||wf_core.translate('WF_EVENT_KEY');
    i := i + 1;
    l_cells(i) := 'S:'||nvl(l_event_t.GetEventKey(),'&'||'nbsp');

    i := i + 1;
    l_cells(i) := 'S:'||wf_core.translate('WF_TO_AGENT_NAME');
    i := i + 1;
    l_cells(i) := 'S:'||l_to_agent;
    i := i + 1;
    l_cells(i) := 'S:'||wf_core.translate('WF_TO_AGENT_SYSTEM');
    i := i + 1;
    l_cells(i) := 'S:'||l_to_system;

    i := i + 1;
    l_cells(i) := 'S:'||wf_core.translate('WF_FROM_AGENT_NAME');
    i := i + 1;
    l_cells(i) := 'S:'||l_from_agent;
    i := i + 1;
    l_cells(i) := 'S:'||wf_core.translate('WF_FROM_AGENT_SYSTEM');
    i := i + 1;
    l_cells(i) := 'S:'||l_from_system;

    i := i + 1;
    l_cells(i) := 'S:'||wf_core.translate('WF_SEND_DATE');
    i := i + 1;
    l_cells(i) := 'S:<BDO DIR="LTR">'||l_send_date_text||'</BDO>';

    i := i + 1;
    l_cells(i) := 'S:'||wf_core.translate('WF_RECEIVE_DATE');
    i := i + 1;
    l_cells(i) := 'S:<BDO DIR="LTR">'||l_receive_date_text||'</BDO>';

    i := i + 1;
    l_cells(i) := 'S:'||wf_core.translate('WF_PRIORITY');
    i := i + 1;
    l_cells(i) := 'S:'||l_priority;

    i := i + 1;
    l_cells(i) := 'S:'||wf_core.translate('WF_CORRELATION');
    i := i + 1;
    l_cells(i) := 'S:'||nvl(l_event_t.GetCorrelationId(),'&'||'nbsp');

  else
    l_result := Wf_Core.Newline||rpad(wf_core.translate('WF_EVENT_HEADING'),40)
 		||wf_core.translate('WF_VALUE')||Wf_Core.Newline;

    l_result := l_result||rpad(wf_core.translate('WF_EVENT_NAME'),40)||
		l_event_t.GetEventName()||Wf_Core.Newline||
		rpad(wf_core.translate('WF_EVENT_KEY'),40)||
		l_event_t.GetEventKey()||Wf_Core.Newline||
		rpad(wf_core.translate('WF_FROM_AGENT_NAME'),40)||
		l_From_Agent||Wf_Core.Newline||
		rpad(wf_core.translate('WF_FROM_AGENT_SYSTEM'),40)||
		l_From_System||Wf_Core.Newline||
		rpad(wf_core.translate('WF_TO_AGENT_NAME'),40)||
		l_To_Agent||Wf_Core.Newline||
		rpad(wf_core.translate('WF_TO_AGENT_SYSTEM'),40)||
                l_To_System||Wf_Core.Newline||
		rpad(wf_core.translate('WF_PRIORITY'),40)||
		l_Priority||Wf_Core.Newline||
		rpad(wf_core.translate('WF_SEND_DATE'),40)||
		l_send_date_text||Wf_Core.Newline||
		rpad(wf_core.translate('WF_RECEIVE_DATE'),40)||
                l_receive_date_text||Wf_Core.Newline||
		rpad(wf_core.translate('WF_CORRELATION'),40)||
                l_event_t.GetCorrelationId()||Wf_Core.Newline;

  end if;

  -- Display the Parameter List
  l_parmlist_t := l_event_t.getParameterList();
  if (l_parmlist_t is not null) then
    j := l_parmlist_t.FIRST;
    while (j <= l_parmlist_t.LAST) loop
      if (display_type = wf_notification.doc_html) then
        i := i + 1;
        l_cells(i) := 'S:'||wf_core.translate('WF_PARAMETER')||' : '||l_parmlist_t(j).getName();

        i := i + 1;
        l_cells(i) :=
'S:'||substr(nvl(l_parmlist_t(j).getValue(),'&'||'nbsp'),1,20);
      else
	l_result := l_result||rpad(wf_core.translate('WF_PARAMETER')
		||l_parmlist_t(j).getName(),40)
		||substr(l_parmlist_t(j).getValue(),1,20)||Wf_Core.Newline;
      end if;
      j := l_parmlist_t.NEXT(j);
    end loop;
  end if;

  if (display_type = wf_notification.doc_html) then
    document_type := wf_notification.doc_html;
    wf_notification.NTF_Table(cells => l_cells,
                              col   => 2,
                              type  => 'H',
                              rs    => l_result);
    -- Display title
    l_result := '<table  width="100%" border="0" cellspacing="1" cellpadding="1">' ||
                '<tr><td class="x3w">'||wf_core.Translate('WFITD_EVENT_DETAILS')||
                '</td></tr>'||'<tr><td>'||l_result||'</td></tr></table>';

  else
    document_type := wf_notification.doc_text;
  end if;
  document := l_result;

exception
when others then
	wf_core.context('WF_STANDARD','EventDetails',document_id, display_type);
	raise;
end EventDetails;
-- --------------------------------------------------------------------
-- Retry Raise
--   Executes command depending on notification response
-- --------------------------------------------------------------------
PROCEDURE RetryRaise	      ( itemtype in	varchar2,
                                itemkey  in     varchar2,
                                actid    in     number,
                                funcmode in     varchar2,
                                resultout out nocopy   varchar2 ) IS

  aname		varchar2(100);
  l_event_t	wf_event_t;
  l_toagent	wf_agent_t;
  l_skip_sub varchar2(300) := null;
  l_parameterList wf_parameter_list_t := null;

begin

  IF (funcmode = 'RUN') THEN

     l_event_t := wf_engine.GetItemAttrEvent(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                name            => 'EVENT_MESSAGE' );

     aname := wf_engine.GetActivityAttrText(itemtype,
						itemkey,
						actid,
						'COMMAND');

     -- Bug 4198975
     -- If the SKIP_ERROR_SUB is not null, then this parameber will
     -- be passed over to raise in all the cases.
     l_skip_sub := l_event_t.GETVALUEFORPARAMETER('SKIP_ERROR_SUB');
     if (l_skip_sub is not null) then
        l_parameterList := wf_parameter_list_t();
        wf_event.addParameterToList('SKIP_ERROR_SUB', l_skip_sub, l_parameterList);
     end if;

     IF aname = 'RAISE_KEY' THEN
       wf_event.raise(p_event_name => l_event_t.GetEventName(),
			          p_event_key => l_event_t.GetEventKey(),
			          p_parameters => l_parameterList);

     ELSIF aname = 'RAISE_KEY_DATA' THEN
       wf_event.raise(p_event_name => l_event_t.GetEventName(),
			p_event_key => l_event_t.GetEventKey(),
			p_event_data => l_event_t.GetEventData(),
			p_parameters => l_parameterList);

     ELSIF aname = 'RAISE_KEY_DATA_PARAM' THEN
       wf_event.raise(l_event_t.GetEventName(),
			l_event_t.GetEventKey(),
			l_event_t.GetEventData(),
			l_event_t.GetParameterList());
     ELSIF aname = 'ENQUEUE' THEN
       l_toagent := l_event_t.GetToAgent();
       l_event_t.SetPriority(-1); -- want this dequeued ASAP
       wf_event.enqueue(l_event_t, l_toagent);
     ELSE
       wf_core.raise('WFSQL_ARGS');

     END IF;

     resultout := wf_engine.eng_completed;

  ELSIF (funcmode = 'CANCEL') THEN
     resultout := wf_engine.eng_completed;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context('WF_STANDARD', 'RetryRaise',
                      itemtype, itemkey, actid, funcmode);
    RAISE;
end RetryRaise;
-- --------------------------------------------------------------------
-- GetAgents
--   Gets the Event Subscription Out and To Agent
-- --------------------------------------------------------------------
procedure GetAgents           ( itemtype in     varchar2,
                                itemkey  in     varchar2,
                                actid    in     number,
                                funcmode in     varchar2,
                                resultout out nocopy   varchar2)
is

  --l_subguid      raw(16);
  l_subguid      varchar2(100);
  l_outagentattr varchar2(100);
  l_toagentattr  varchar2(100);
  l_outagentguid raw(16);
  l_toagentguid  raw(16);
  l_outagent     varchar2(100);
  l_toagent      varchar2(100);

  cursor c_agents is
  select out_agent_guid, to_agent_guid
  from   wf_event_subscriptions
  where  guid = l_subguid;

begin

  IF (funcmode = 'RUN') THEN

     l_subguid := wf_engine.GetActivityAttrText(itemtype,
                                                itemkey,
                                                actid,
                                                'SUB_GUID');

     l_outagentattr := wf_engine.GetActivityAttrText(itemtype,
                                                itemkey,
                                                actid,
                                                'FROMAGENT');

     l_toagentattr := wf_engine.GetActivityAttrText(itemtype,
                                                itemkey,
                                                actid,
                                                'TOAGENT');

     -- Get the Agent Guids
     open c_agents;
     fetch c_agents into l_outagentguid, l_toagentguid;
     close c_agents;

     if l_toagentguid is not null then
       -- Get the Out Agent in the agent@system format
       if l_outagentguid is not null then
         select wfa.name||'@'||wfs.name
         into l_outagent
         from wf_agents wfa, wf_systems wfs
         where wfa.guid = l_outagentguid
         and   wfa.system_guid = wfs.guid;
       end if;

       -- Get the To Agent in the agent@system format
       select wfa.name||'@'||wfs.name
       into l_toagent
       from wf_agents wfa, wf_systems wfs
       where wfa.guid = l_toagentguid
       and   wfa.system_guid = wfs.guid;

       -- Update the agent item attributes
       wf_engine.SetItemAttrText(itemtype => itemtype,
                               itemkey => itemkey,
                               aname => l_outagentattr,
			       avalue => l_outagent);

       wf_engine.SetItemAttrText(itemtype => itemtype,
                               itemkey => itemkey,
                               aname => l_toagentattr,
                               avalue => l_toagent);
       resultout := 'T';
     else
       resultout := 'F';
     end if;
  ELSIF (funcmode = 'CANCEL') THEN
     resultout := wf_engine.eng_completed;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context('WF_STANDARD', 'GetAgents',
                      itemtype, itemkey, actid, funcmode);
    RAISE;
end GetAgents;
-- --------------------------------------------------------------------
-- GetAckAgent
--   Gets the Acknowledge To Agent based on the Event Message
-- --------------------------------------------------------------------
procedure GetAckAgent           ( itemtype in     varchar2,
                                itemkey  in     varchar2,
                                actid    in     number,
                                funcmode in     varchar2,
                                resultout out nocopy   varchar2)
is

  l_event_t	wf_event_t;
  l_toagentattr varchar2(100);
  l_system      varchar2(30);
  l_agent       varchar2(30);

  cursor c_return_agent is
  select  wfa.name agent
  from  wf_systems wfs,
        wf_agents wfa
  where wfs.name = l_system
  and   wfa.status = 'ENABLED'
  and   wfa.direction = 'IN'
  and   wfa.name not in ('WF_ERROR','WF_DEFERRED');

begin

  IF (funcmode = 'RUN') THEN

    l_event_t := wf_engine.GetActivityAttrEvent(
					itemtype => itemtype,
					itemkey  => itemkey,
					actid    => actid,
					name     => 'EVENTMESSAGE');

    l_toagentattr := wf_engine.GetActivityAttrText(itemtype,
                                                itemkey,
                                                actid,
                                                'ACKTOAGENT');

    l_system := l_event_t.GetFromAgent().GetSystem();

    open c_return_agent;
    fetch c_return_agent into l_agent;
    close c_return_agent;

    if l_agent is not null then
      wf_engine.SetItemAttrText(itemtype => itemtype,
                               itemkey => itemkey,
                               aname => l_toagentattr,
                               avalue => l_agent||'@'||l_system);
    end if;

    resultout := wf_engine.eng_completed;

  ELSIF (funcmode = 'CANCEL') THEN
     resultout := wf_engine.eng_completed;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context('WF_STANDARD', 'GetAckAgent',
                      itemtype, itemkey, actid, funcmode);
    RAISE;
end GetAckAgent;

-- SubscriptionDetails
--   PL/SQL Document to display subscription parameter details
-- IN
--   document_id
--   display_type
--   document
--   document_type
procedure SubscriptionDetails (document_id   in varchar2,
                               display_type  in varchar2,
                               document      in out nocopy varchar2,
                               document_type in out nocopy varchar2)
is
  l_item_type    varchar2(10);
  l_item_key     varchar2(240);
  l_subscription raw(16);
  l_params       varchar2(4000);
  l_rule_func    varchar2(240);
  l_cells        wf_notification.tdType;
  l_cells2       wf_notification.tdType;
  i              pls_integer;
  j              pls_integer;
  l_document     varchar2(32000);
  l_sub_param_list wf_parameter_list_t;
  l_event_t      wf_event_t;
  l_result       varchar2(22000);
  l_result2      varchar2(10000);
  l_url          varchar2(500);
  l_sub_url      varchar2(1000);
  l_evt_url      varchar2(1000);
begin
  l_item_type := nvl(substr(document_id, 1,
instr(document_id,':')-1),'WFERROR');
  l_item_key  := substr(document_id, instr(document_id,':')+1);

  l_event_t := wf_engine.GetItemAttrEvent(itemtype => l_item_type,
                                          itemkey  => l_item_key,
                                          name     => 'EVENT_MESSAGE');
  l_subscription := l_event_t.GetErrorSubscription();

  if (l_subscription is not null) then

    SELECT parameters, java_rule_func
    INTO   l_params, l_rule_func
    FROM   wf_event_subscriptions
    WHERE  guid = l_subscription;

    l_sub_param_list := wf_event.GetParamListFromString(l_params);

    if (display_type = wf_notification.doc_html) then
      i := 1;
      l_cells(i) := 'S30%:'||wf_core.Translate('WF_PARAMETER');

      i := i + 1;
      l_cells(i) := 'S70%:'||wf_core.Translate('WF_VALUE');
    else
      l_result := Wf_Core.Newline||rpad(wf_core.Translate('WF_PARAMETER'), 40)
                  ||wf_core.translate('WF_VALUE')||Wf_Core.Newline;
    end if;

    -- Show all Subscription Parameters that are currently used as
    -- meta-data store for WS definition
    if (l_sub_param_list is not null) then
      j := l_sub_param_list.FIRST;
      while (j is not null) loop
        if (display_type = wf_notification.doc_html) then
          i := i + 1;
          l_cells(i) := 'S:'||l_sub_param_list(j).getName();

          i := i + 1;
          l_cells(i) := 'S:'||l_sub_param_list(j).getValue();
        else
          l_result := l_result||rpad(l_sub_param_list(j).getName(),40)||
                                rpad(l_sub_param_list(j).getValue(),40)||wf_core.newline;
        end if;
        j := l_sub_param_list.NEXT(j);
      end loop;
    end if;

    -- Show Invoker Rule Function since it may be a Custom one extended from
    -- seeded. Also the Event Payload is WS input message
    l_evt_url := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                           itemkey  => l_item_key,
                                           aname    => 'EVENT_DATA_URL');
    l_sub_url := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                           itemkey  => l_item_key,
                                           aname    => 'EVENT_SUBSCRIPTION');

    if (display_type = wf_notification.doc_html) then
      i := i + 1;
      l_cells(i) := 'S:'||wf_core.Translate('WF_INOKER_RULE_FUNC');
      i := i + 1;
      l_cells(i) := 'S:'||l_rule_func;

      i := i + 1;
      l_cells(i) := 'S:'||wf_core.Translate('WF_WS_INPUT_MESG');
      i := i + 1;
      l_url := '<a href="'||l_evt_url||'" class="xd">'||wf_core.Translate('WF_CLICK_HERE')||'</a>';
      l_cells(i) := 'S:'||l_url;

      i := i + 1;
      l_cells(i) := 'S:'||wf_core.Translate('WF_SUBSCRIPTION_PAGE');
      i := i + 1;
      l_url := '<a href="'||l_sub_url||'" class="xd">'||wf_core.Translate('WF_CLICK_HERE')||'</a>';
      l_cells(i) := 'S:'||l_url;

      wf_notification.Ntf_Table(l_cells, 2, 'H', l_result);

      -- Display title "Web Service Details"
      l_result := '<table  width="100%" border="0" cellspacing="1" cellpadding="1">' ||
                '<tr><td class="x3w">'||wf_core.Translate('WF_WEBSERVICE_DETAILS')||'</td></tr>'||
                '<tr><td>'||l_result||'</td></tr></table>';

    else
      l_result := l_result||rpad(wf_core.Translate('WF_INOKER_RULE_FUNC'),40)||
                            rpad(l_rule_func,40)||wf_core.newline||
                            rpad(wf_core.Translate('WF_WS_INPUT_MESG'),40)||
                            rpad(l_evt_url,40)||wf_core.newline||
                            rpad(wf_core.Translate('WF_SUBSCRIPTION_PAGE'),40)||
                            rpad(l_sub_url,40)||wf_core.newline;

    end if;
  end if;
  document := l_result;
exception
  when others then
    wf_core.context('WF_STANDARD', 'SubscriptionDetails', document_id);
    raise;
end SubscriptionDetails;

-- ErrorDetails
--   PL/SQL Document to display event error details
-- IN
--   document_id
--   display_type
--   document
--   document_type
procedure ErrorDetails (document_id   in varchar2,
                        display_type  in varchar2,
                        document      in out nocopy varchar2,
                        document_type in out nocopy varchar2)
is
  l_result     varchar2(32000);
  l_error_name varchar2(240);
  l_item_type  varchar2(30);
  l_item_key   varchar2(240);
  l_error_message varchar2(2000);
  l_error_stack   varchar2(2000);
  l_cells     wf_notification.tdType;
  i           pls_integer;
begin

  l_item_type := nvl(substr(document_id, 1, instr(document_id,':')-1),'WFERROR');
  l_item_key  := substr(document_id, instr(document_id,':')+1);

  l_error_name := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                            itemkey  => l_item_key,
                                            aname     => 'ERROR_NAME');
  l_error_message := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                               itemkey  => l_item_key,
                                               aname     => 'ERROR_MESSAGE');
  l_error_stack := wf_engine.GetItemAttrText(itemtype => l_item_type,
                                             itemkey  => l_item_key,
                                             aname     => 'ERROR_STACK');

  if (display_type = wf_notification.doc_html) then
    document_type := wf_notification.doc_html;

    i := 1;
    if (l_error_name is not null) then
      l_cells(i) := 'E20%:'||wf_core.Translate('WFMON_ERROR_NAME');
      i := i + 1;
      l_cells(i) := 'S:'||l_error_name;
      i := i + 1;
    end if;

    l_cells(i) := 'E20%:'||wf_core.Translate('WFMON_ERROR_MESSAGE');
    i := i + 1;
    l_cells(i) := 'S:'||l_error_message;

    i := i + 1;
    l_cells(i) := 'E20%:'||wf_core.Translate('WFMON_ERROR_STACK');
    i := i + 1;
    l_cells(i) := 'S:'||l_error_stack;

    wf_notification.NTF_Table(cells => l_cells,
                              col   => 2,
                              type  => 'V',
                              rs    => l_result);

    -- Display title
    l_result := '<table  width="100%" border="0" cellspacing="1" cellpadding="1">' ||
                '<tr><td class="x3w">'||wf_core.Translate('WF_ERROR_DETAILS') ||
                '</td></tr>'||'<tr><td>'||l_result||'</td></tr></table>';
  else
    document_type := wf_notification.doc_text;
    l_result := rpad(wf_core.Translate('WFMON_ERROR_NAME'),40)||' : '||l_error_name||wf_core.newline||
                rpad(wf_core.Translate('WFMON_ERROR_MESSAGE'),40)||' : '||l_error_message||wf_core.newline||
                rpad(wf_core.Translate('WFMON_ERROR_STACK'),40)||' : '||l_error_stack||wf_core.newline;
  end if;
  document := l_result;
exception
  when others then
    wf_core.context('WF_STANDARD', 'ErrorDetails', document_id);
    raise;
end ErrorDetails;

-- SubscriptionAction
--   Returns Subscription's Action Code based on which a specific notification
--   could be sent
procedure SubscriptionAction(itemtype  in varchar2,
                             itemkey   in varchar2,
                             actid     in number,
                             funcmode  in varchar2,
                             resultout in out nocopy varchar2)
is
  l_event_t      wf_event_t;
  l_subscription raw(16);
  l_action_code  varchar2(30);
begin

  if (funcmode = 'RUN') then
    l_event_t := wf_engine.GetItemAttrEvent(itemtype => itemtype,
                                            itemkey  => itemkey,
                                            name     => 'EVENT_MESSAGE');
    l_subscription := l_event_t.GetErrorSubscription();

    SELECT action_code
    INTO   l_action_code
    FROM   wf_event_subscriptions
    WHERE  guid = l_subscription;

    if (l_action_code is not null) then
      resultout := wf_engine.eng_completed||':'||l_action_code;
    else
      resultout := wf_engine.eng_completed||':CUSTOM_RG';
    end if;
  elsif (funcmode = 'CANCEL') then
    resultout := wf_engine.eng_completed;
  end if;

end SubscriptionAction;

END WF_STANDARD;

/
