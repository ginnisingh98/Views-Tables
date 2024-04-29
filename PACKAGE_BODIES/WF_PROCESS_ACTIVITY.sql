--------------------------------------------------------
--  DDL for Package Body WF_PROCESS_ACTIVITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_PROCESS_ACTIVITY" as
/* $Header: wfengb.pls 120.25.12010000.17 2014/09/09 00:17:09 alsosa ship $ */

type InstanceArrayTyp is table of pls_integer
index by binary_integer;

--
-- RootInstanceId
--   Globals to cache RootInstanceId result for effeciency
--
c_itemtype varchar2(8);
c_itemkey varchar2(240);
c_process varchar2(30);
c_rootid pls_integer;

--
-- ClearCache
--   Clear runtime cache
--
procedure ClearCache
is
begin
  wf_process_activity.c_itemtype := '';
  wf_process_activity.c_itemkey := '';
  wf_process_activity.c_process := '';
  wf_process_activity.c_rootid := '';
exception
  when others then
    Wf_Core.Context('Wf_Process_Activity', 'ClearCache');
    raise;
end ClearCache;

--
-- RootInstanceId (PRIVATE)
--   Return the instance id for the process activity under the given item
--   type.  If there is no row found, returns null.
-- NOTE
--   This function only returns the 'ROOT' row for a process in
--   WF_PROCESS_ACTIVITIES.  It assumes there will be exactly 1 row
--   looking like:
--     PROCESS_ITEM_TYPE = itemtype
--     PROCESS_NAME = 'ROOT'
--     PROCESS_VERSION = version
--     INSTANCE_LABEL = process
--   for each process in WF_PROCESS_ACTIVITIES.
-- IN
--   itemtype - Item type of process
--   itemkey - Item key
--   process - Process name
--
function RootInstanceId(itemtype in varchar2,
                        itemkey in varchar2,
                        process  in varchar2)
return number is
  actdate date;
  instid pls_integer;
begin
  -- Check cache for a valid value
  if ((itemtype = wf_process_activity.c_itemtype) and
      (itemkey = wf_process_activity.c_itemkey) and
      (process = wf_process_activity.c_process)) then
    return(wf_process_activity.c_rootid);
  end if;

  -- No joy.  Select a new value.
  actdate := Wf_Item.Active_Date(itemtype, itemkey);

  select INSTANCE_ID
  into instid
  from WF_PROCESS_ACTIVITIES PA, WF_ACTIVITIES A
  where A.ITEM_TYPE = itemtype
  and A.NAME = 'ROOT'
  and actdate >= A.BEGIN_DATE
  and actdate < NVL(A.END_DATE, actdate+1)
  and PA.PROCESS_NAME = 'ROOT'
  and PA.PROCESS_ITEM_TYPE = itemtype
  and PA.PROCESS_VERSION = A.VERSION
  and PA.INSTANCE_LABEL = process;

  -- Save value to cache
  wf_process_activity.c_itemtype := itemtype;
  wf_process_activity.c_itemkey := itemkey;
  wf_process_activity.c_process := process;
  wf_process_activity.c_rootid := instid;

  return instid;

exception
  when NO_DATA_FOUND then
    return '';
  when OTHERS then
    Wf_Core.Context('Wf_Process_Activity', 'RootInstanceId', itemtype,
                    itemkey, process);
    raise;
end RootInstanceId;

--
-- ActivityName
--   Return the activity type and name, given instance id
-- IN
--   actid - instance id
-- OUT
--   act_itemtype - activity itemtype
--   act_name - activity name
--
procedure ActivityName(
  actid in number,
  act_itemtype out NOCOPY varchar2,
  act_name out NOCOPY varchar2)
is
  status  PLS_INTEGER;

begin
  WF_CACHE.GetProcessActivity(actid, status);

  if (status <> WF_CACHE.task_SUCCESS) then

    select WPA.PROCESS_ITEM_TYPE, WPA.PROCESS_NAME, WPA.PROCESS_VERSION,
           WPA.ACTIVITY_ITEM_TYPE, WPA.ACTIVITY_NAME, WPA.INSTANCE_ID,
           WPA.INSTANCE_LABEL, WPA.PERFORM_ROLE, WPA.PERFORM_ROLE_TYPE,
           WPA.START_END, WPA.DEFAULT_RESULT
    into   WF_CACHE.ProcessActivities(actid)
    from   WF_PROCESS_ACTIVITIES WPA
    where  WPA.INSTANCE_ID = actid;

  end if;

  act_itemtype := WF_CACHE.ProcessActivities(actid).ACTIVITY_ITEM_TYPE;
  act_name     := WF_CACHE.ProcessActivities(actid).ACTIVITY_NAME;

exception
  when no_data_found then
    Wf_Core.Token('ACTID', to_char(actid));
    Wf_Core.Token('DATE', '');
    Wf_Core.Raise('WFENG_ACTID');
  when others then
    Wf_Core.Context('Wf_Process_Activity', 'ActivityName', to_char(actid));
    raise;
end ActivityName;

--
-- StartInstanceId (PRIVATE)
--   Returns instance_id for a start activity, given root process
--   name, itemtype, and version.
-- IN
--   itemtype - Itemtype of process
--   process - Process name
--   version - Process version
--   activity - Start activity instance label
--
function StartInstanceId(itemtype in varchar2,
                    process  in varchar2,
                    version in number,
                    activity in varchar2)
return number
is
  instid pls_integer;
  colon pls_integer;
  label varchar2(30);
begin
  -- Parse activity arg into <process_name> and <instance_label> components.
  colon := instr(activity, ':');
  if (colon <> 0) then
    -- Activity arg is <process name>:<instance label>
    label := substr(activity, colon+1);
  else
    -- Activity arg is just instance label
    label := activity;
  end if;

  select
  WPA.INSTANCE_ID
  into instid
  from WF_PROCESS_ACTIVITIES WPA
  where WPA.INSTANCE_LABEL = StartInstanceId.label
  and WPA.PROCESS_ITEM_TYPE = StartInstanceId.itemtype
  and WPA.PROCESS_NAME = StartInstanceId.process
  and WPA.PROCESS_VERSION = StartInstanceId.version
  and WPA.START_END = wf_engine.eng_start;

  return instid;
exception
  when no_data_found then
      Wf_Core.Context('Wf_Process_Activity', 'StartInstanceId', itemtype,
                      process, to_char(version), activity);
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('PROCESS', process);
      Wf_Core.Token('NAME', activity);
      Wf_Core.Raise('WFENG_NOT_START');
  when too_many_rows then
    Wf_Core.Context('Wf_Process_Activity', 'StartInstanceId', itemtype,
                    process, to_char(version), activity);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('PROCESS', process);
    Wf_Core.Token('NAME', activity);
    Wf_Core.Raise('WFENG_ACTIVITY_UNIQUE');
  when others then
    Wf_Core.Context('Wf_Process_Activity', 'StartInstanceId', itemtype,
                    process, to_char(version), activity);
    raise;
end StartInstanceId;

--
-- ActiveInstanceId (PRIVATE)
--   Returns instance_id for an active instance of an activity.
-- NOTE
--   This is a more efficient version of FindActivity, to be used whenever
--   the current status the activity must have is already known.
--   It is also able to distinguish between duplicate activities, where
--   only one may be active at a given time.
-- IN
--   itemtype - Itemtype of item
--   itemkey - Itemkey of item
--   activity - Activity searching for, specified in the form
--              [<process_name>:]<instance_label>
--   status - Status of activity, or null if status not known
-- RETURNS
--   Instance id of activity
--
function ActiveInstanceId(itemtype in varchar2,
                          itemkey in varchar2,
                          activity in varchar2,
                          status in varchar2)
return number
is
  colon pls_integer;
  process varchar2(30);
  label varchar2(30);
  instid pls_integer;
  cur_actid pls_integer;
  cur_status varchar2(8);
  cur_result varchar2(30);
begin
  -- Parse activity arg into <process_name> and <instance_label> components.
  colon := instr(activity, ':');
  if (colon <> 0) then
    -- Activity arg is <process name>:<instance label>
    process := substr(activity, 1, colon-1);
    label := substr(activity, colon+1);
  else
    -- Activity arg is just instance label
    process := '';
    label := activity;
  end if;

  -- SYNCHMODE:
  -- In synchmode, the row in the WIAS runtime cache MUST be this row,
  -- because synch processes can only operate on the current activity.
  --
  if (itemkey = wf_engine.eng_synch) then
    -- Get the current item and status in the cache
    Wf_Item_Activity_Status.LastResult(itemtype, itemkey,
        cur_actid, cur_status, cur_result);

    -- If status doesn't match one asked for, immediate trouble
    if (nvl(status, '1') <> nvl(cur_status, '2')) then
      raise no_data_found;
    end if;

    -- Check that activity label passed in matched the current actid
    select WPA.INSTANCE_ID
    into instid
    from WF_PROCESS_ACTIVITIES WPA
    where WPA.INSTANCE_LABEL = activeinstanceid.label
    and WPA.PROCESS_NAME = nvl(activeinstanceid.process, WPA.PROCESS_NAME)
    and WPA.INSTANCE_ID = activeinstanceid.cur_actid;
  else
    -- NORMAL mode
    select WPA.INSTANCE_ID
    into instid
    from WF_ITEM_ACTIVITY_STATUSES WIAS, WF_PROCESS_ACTIVITIES WPA
    where WIAS.ITEM_TYPE = activeinstanceid.itemtype
    and WIAS.ITEM_KEY = activeinstanceid.itemkey
    and WIAS.ACTIVITY_STATUS = nvl(activeinstanceid.status,
                                   WIAS.ACTIVITY_STATUS)
    and WIAS.PROCESS_ACTIVITY = WPA.INSTANCE_ID
    and WPA.INSTANCE_LABEL = activeinstanceid.label
    and WPA.PROCESS_NAME = nvl(activeinstanceid.process, WPA.PROCESS_NAME);
  end if;

  return instid;
exception
  when no_data_found then
    return '';
  when too_many_rows then
    Wf_Core.Context('Wf_Process_Activity', 'ActiveInstanceId', itemtype,
                    itemkey, activity, status);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('NAME', activity);
    Wf_Core.Raise('WFENG_ITEM_ACTIVITY_UNIQUE');
  when others then
    Wf_Core.Context('Wf_Process_Activity', 'ActiveInstanceId', itemtype,
                    itemkey, activity, status);
    raise;
end ActiveInstanceId;

--
--  IsChild (PRIVATE)
--   Search for any occurrence of an activity in a process tree, either
--   as a direct child, or referenced in an error process attached to a
--   child.
--   This function does a recursive search of the tree.  It should only be
--   used if:
--   1. There may not be an entry in WIAS yet for this activity.
--   2. You do not know the immediate parent of the activity.
-- IN
--   rootid - The instance_id of the parent process
--   acttype - Activity itemtype searching for
--   actname - Activity name searching for
--   actdate - Active date
-- RETURNS
--   True is activity found anywhere in process tree.
--
function IsChild(
  rootid in number,
  acttype in varchar2,
  actname in varchar2,
  actdate in date)
return boolean
is
  cursor curs(parentid in pls_integer, actdate in date) is
    select WPA2.INSTANCE_ID, WPA2.ACTIVITY_ITEM_TYPE, WPA2.ACTIVITY_NAME
    from WF_PROCESS_ACTIVITIES WPA1,
         WF_ACTIVITIES WA,
         WF_PROCESS_ACTIVITIES WPA2
    where WPA1.INSTANCE_ID = parentid
    and WPA2.PROCESS_ITEM_TYPE = WA.ITEM_TYPE
    and WPA2.PROCESS_NAME = WA.NAME
    and WA.ITEM_TYPE = WPA1.ACTIVITY_ITEM_TYPE
    and WA.NAME = WPA1.ACTIVITY_NAME
    and actdate >= WA.BEGIN_DATE
    and actdate < NVL(WA.END_DATE, actdate+1)
    and WPA2.PROCESS_VERSION = WA.VERSION;

  childarr InstanceArrayTyp;
  i pls_integer := 0;
  errid   pls_integer;

  found boolean;

  status PLS_INTEGER;
  waIND  NUMBER;

begin
  WF_CACHE.GetProcessActivityInfo(rootid, actdate, status, waIND);

  if (status <> WF_CACHE.task_SUCCESS) then
    waIND := 0;

    select WA.ITEM_TYPE, WA.NAME, WA.VERSION, WA.TYPE, WA.RERUN,
           WA.EXPAND_ROLE, WA.COST, WA.ERROR_ITEM_TYPE, WA.ERROR_PROCESS,
           WA.FUNCTION, WA.FUNCTION_TYPE,  WA.MESSAGE, WA.BEGIN_DATE,
           WA.END_DATE, WA.DIRECTION, WPA.PROCESS_ITEM_TYPE,
           WPA.PROCESS_NAME, WPA.PROCESS_VERSION, WPA.ACTIVITY_ITEM_TYPE,
           WPA.ACTIVITY_NAME, WPA.INSTANCE_ID, WPA.INSTANCE_LABEL,
           WPA.PERFORM_ROLE, WPA.PERFORM_ROLE_TYPE, WPA.START_END,
           WPA.DEFAULT_RESULT

    into   WF_CACHE.Activities(waIND).ITEM_TYPE,
           WF_CACHE.Activities(waIND).NAME,
           WF_CACHE.Activities(waIND).VERSION,
           WF_CACHE.Activities(waIND).TYPE,
           WF_CACHE.Activities(waIND).RERUN,
           WF_CACHE.Activities(waIND).EXPAND_ROLE,
           WF_CACHE.Activities(waIND).COST,
           WF_CACHE.Activities(waIND).ERROR_ITEM_TYPE,
           WF_CACHE.Activities(waIND).ERROR_PROCESS,
           WF_CACHE.Activities(waIND).FUNCTION,
           WF_CACHE.Activities(waIND).FUNCTION_TYPE,
           WF_CACHE.Activities(waIND).MESSAGE,
           WF_CACHE.Activities(waIND).BEGIN_DATE,
           WF_CACHE.Activities(waIND).END_DATE,
           WF_CACHE.Activities(waIND).DIRECTION,
           WF_CACHE.ProcessActivities(rootid).PROCESS_ITEM_TYPE,
           WF_CACHE.ProcessActivities(rootid).PROCESS_NAME,
           WF_CACHE.ProcessActivities(rootid).PROCESS_VERSION,
           WF_CACHE.ProcessActivities(rootid).ACTIVITY_ITEM_TYPE,
           WF_CACHE.ProcessActivities(rootid).ACTIVITY_NAME,
           WF_CACHE.ProcessActivities(rootid).INSTANCE_ID,
           WF_CACHE.ProcessActivities(rootid).INSTANCE_LABEL,
           WF_CACHE.ProcessActivities(rootid).PERFORM_ROLE,
           WF_CACHE.ProcessActivities(rootid).PERFORM_ROLE_TYPE,
           WF_CACHE.ProcessActivities(rootid).START_END,
           WF_CACHE.ProcessActivities(rootid).DEFAULT_RESULT

    from   WF_PROCESS_ACTIVITIES WPA, WF_ACTIVITIES WA

    where  WPA.INSTANCE_ID = rootid
    and    WA.ITEM_TYPE = WPA.ACTIVITY_ITEM_TYPE
    and    WA.NAME = WPA.ACTIVITY_NAME
    and    actdate >= WA.BEGIN_DATE
    and    actdate < NVL(WA.END_DATE, actdate+1);

    waIND := WF_CACHE.HashKey(
                      WF_CACHE.ProcessActivities(rootid).ACTIVITY_ITEM_TYPE ||
                      WF_CACHE.ProcessActivities(rootid).ACTIVITY_NAME);

    WF_CACHE.Activities(waIND) := WF_CACHE.Activities(0);

   end if;


  -- Quick check to see if root is already right
  if (((WF_CACHE.ProcessActivities(rootid).PROCESS_ITEM_TYPE = acttype) and
       (WF_CACHE.ProcessActivities(rootid).PROCESS_NAME = actname)) or
      ((WF_CACHE.Activities(waIND).ITEM_TYPE = acttype) and
       (WF_CACHE.Activities(waIND).NAME = actname))) then
    return(TRUE);
  end if;

  -- If activity at rootid has an error process, check it recursively
  -- for a reference to the activity.
  if (WF_CACHE.Activities(waIND).ERROR_PROCESS is not null) then
    -- Get root id for the error process
    begin
      select WPA.INSTANCE_ID
      into errid
      from WF_PROCESS_ACTIVITIES WPA, WF_ACTIVITIES WA
      where WPA.PROCESS_ITEM_TYPE = WF_CACHE.Activities(waIND).ERROR_ITEM_TYPE
      and WPA.PROCESS_NAME = 'ROOT'
      and WPA.PROCESS_VERSION = WA.VERSION
      and WA.ITEM_TYPE = WPA.PROCESS_ITEM_TYPE
      and WA.NAME = WPA.PROCESS_NAME
      and actdate >= WA.BEGIN_DATE
      and actdate < NVL(WA.END_DATE, actdate+1)
      and WPA.INSTANCE_LABEL = WF_CACHE.Activities(waIND).ERROR_PROCESS;
    exception
      when no_data_found then
        -- Error process is invalid, so ignore it
        errid := '';
    end;

    if (errid is not null) then
      -- If activity found in error process return immediately.
      -- If not, continue on to check proper children of rootid.
      if (IsChild(errid, acttype, actname, actdate)) then
        return(TRUE);
      end if;
    end if;
  end if;

  -- Check all children of rootid
  for child in curs(rootid, actdate) loop
    -- Desired activity found.  Return immediately.
    if ((child.activity_item_type = acttype) and
        (child.activity_name = actname)) then
      return(TRUE);
    end if;

    -- Save all other children in array to be checked
    childarr(i) := child.instance_id;
    i := i + 1;
  end loop;
  childarr(i) := '';

  -- Loop through and recursively search any PROCESS-type children.
  i := 0;
  while (childarr(i) is not null) loop
    if (Wf_Activity.Instance_Type(childarr(i), actdate) =
        wf_engine.eng_process) then
      found := IsChild(childarr(i), acttype, actname, actdate);

      -- If a non-null value is returned, then the activity was
      -- found in this sub-tree.  Return the value and exit immediately.
      if (found) then
        return(TRUE);
      end if;
    end if;
    i := i + 1;
  end loop;

  -- If you made it here the activity was not found anywhere in the tree.
  return(FALSE);
exception
  when OTHERS then
    Wf_Core.Context('Wf_Process_Activity', 'IsChild', to_char(rootid),
                    acttype, actname, to_char(actdate));
    raise;
end IsChild;

--
--  FindActivity (PRIVATE)
--   Find the instance_id of an activity instance in the tree rooted at
--   parentid in the WPA table.
--   This function does a recursive search of the tree.  It should only be
--   used if:
--   1. There may not be an entry in WIAS yet for this activity instance.
--      (See ActiveInstanceId above)
--   2. You do not know the immediate parent of the activity.
-- IN
--   parentid - The instance_id of the parent process.
--   activity - Activity searching for, specified in the form
--              [<process_name>:]<instance_label>
--   actdate - Active date
-- RETURNS
--   Instance id of activity instance in process tree rooted at parentid.
--   Returns null if not found.
--
function FindActivity(parentid in number,
                      activity in varchar2,
                      actdate in date)
return number
is
  colon pls_integer;
  process varchar2(30);
  label varchar2(30);

  status PLS_INTEGER;

  cursor curs(parentid in pls_integer, actdate in date) is
    select WPA2.PROCESS_NAME, WPA2.INSTANCE_ID, WPA2.INSTANCE_LABEL
    from WF_PROCESS_ACTIVITIES WPA1,
         WF_ACTIVITIES WA,
         WF_PROCESS_ACTIVITIES WPA2
    where WPA1.INSTANCE_ID = parentid
    and WPA2.PROCESS_ITEM_TYPE = WA.ITEM_TYPE
    and WPA2.PROCESS_NAME = WA.NAME
    and WA.ITEM_TYPE = WPA1.ACTIVITY_ITEM_TYPE
    and WA.NAME = WPA1.ACTIVITY_NAME
    and actdate >= WA.BEGIN_DATE
    and actdate < NVL(WA.END_DATE, actdate+1)
    and WPA2.PROCESS_VERSION = WA.VERSION;

  childarr InstanceArrayTyp;
  i pls_integer := 0;

  childid pls_integer;
  actid pls_integer := '';
  wf_dup_activity exception;
begin
  -- Parse activity arg into <process_name> and <instance_label> components.
  colon := instr(activity, ':');
  if (colon <> 0) then
    -- Activity arg is <process name>:<instance label>
    process := substr(activity, 1, colon-1);
    label := substr(activity, colon+1);
  else
    -- Activity arg is just instance label
    process := '';
    label := activity;
  end if;

  WF_CACHE.GetProcessActivity(parentid, status);

  if (status <> WF_CACHE.task_SUCCESS) then

    select WPA.PROCESS_ITEM_TYPE, WPA.PROCESS_NAME, WPA.PROCESS_VERSION,
           WPA.ACTIVITY_ITEM_TYPE, WPA.ACTIVITY_NAME, WPA.INSTANCE_ID,
           WPA.INSTANCE_LABEL, WPA.PERFORM_ROLE, WPA.PERFORM_ROLE_TYPE,
           WPA.START_END, WPA.DEFAULT_RESULT
    into   WF_CACHE.ProcessActivities(parentid)
    from   WF_PROCESS_ACTIVITIES WPA
    where  WPA.INSTANCE_ID = parentid;

  end if;

  if ((WF_CACHE.ProcessActivities(parentid).PROCESS_NAME =
       nvl(process, WF_CACHE.ProcessActivities(parentid).PROCESS_NAME)) and
      (WF_CACHE.ProcessActivities(parentid).INSTANCE_LABEL = label)) then
    return(parentid);
  end if;

  for child in curs(parentid, actdate) loop
    -- Activity with this name found.
    if ((child.process_name = nvl(process, child.process_name)) and
        (child.instance_label = label)) then
      if ((actid is not null) and (actid <> child.instance_id)) then
        -- Activity already found once in this process - raise duplicate error.
        raise wf_dup_activity;
      else
        -- Save id of activity
        actid := child.instance_id;
      end if;
    end if;

    -- Save all other children in array to be checked
    childarr(i) := child.instance_id;
    i := i + 1;
  end loop;
  childarr(i) := '';

  -- Loop through and recursively search any PROCESS-type children.
  i := 0;
  while (childarr(i) is not null) loop
    if (Wf_Activity.Instance_Type(childarr(i), actdate) =
        wf_engine.eng_process) then
      childid := FindActivity(childarr(i), activity, actdate);

      -- If a non-null value is returned, then the activity was
      -- found somewhere in this sub-tree.
      if (childid is not null) then
        if ((actid is not null) and (actid <> childid)) then
          -- Activity already found somewhere else.  Raise error.
          raise wf_dup_activity;
        else
          -- Save id of activity
          actid := childid;
        end if;
      end if;
    end if;
    i := i + 1;
  end loop;

  -- Return saved actid.  If activity not found anywhere in tree this
  -- will still be null.
  return(actid);
exception
  when wf_dup_activity then
    Wf_Core.Context('Wf_Process_Activity', 'FindActivity', to_char(parentid),
                    activity, to_char(actdate));
    Wf_Core.Token('NAME', activity);
    Wf_Core.Raise('WFENG_ACTIVITY_UNIQUE');
  when OTHERS then
    Wf_Core.Context('Wf_Process_Activity', 'FindActivity', to_char(parentid),
                    activity, to_char(actdate));
    raise;
end FindActivity;

end WF_PROCESS_ACTIVITY;

/
