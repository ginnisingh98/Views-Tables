--------------------------------------------------------
--  DDL for Package Body WF_ACTIVITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ACTIVITY" as
/* $Header: wfengb.pls 120.25.12010000.17 2014/09/09 00:17:09 alsosa ship $ */


c_actid pls_integer;
c_actdate date;
c_type varchar2(8);
c_rerun varchar2(8);
c_cost number;
c_error_type varchar2(8);
c_error_process varchar2(30);
c_message varchar2(30);
c_msgtype varchar2(8);
c_expand_role varchar(1);
c_function varchar2(240);
c_function_type varchar2(30);
c_prole varchar2(320);
c_prole_type varchar2(8);
c_start_end varchar2(8);
c_event_name varchar2(240);
c_direction varchar2(8);

--
-- ClearCache
--   Clear runtime cache
--
procedure ClearCache
is
begin
  wf_activity.c_actid := '';
  wf_activity.c_actdate := to_date(NULL);
  wf_activity.c_type := '';
  wf_activity.c_rerun := '';
  wf_activity.c_cost := '';
  wf_activity.c_error_type := '';
  wf_activity.c_error_process := '';
  wf_activity.c_message := '';
  wf_activity.c_msgtype := '';
  wf_activity.c_expand_role := '';
  wf_activity.c_function := '';
  wf_activity.c_function_type := '';
  wf_activity.c_prole := '';
  wf_activity.c_prole_type := '';
  wf_activity.c_start_end := '';
  wf_activity.c_event_name := '';
  wf_activity.c_direction := '';
exception
  when others then
    Wf_Core.Context('Wf_Activity', 'ClearCache');
    raise;
end ClearCache;

--
-- InitCache (PRIVATE)
--   Initialize package cache
-- IN
--   actid - activity instance id
--   actdate - active date
--
procedure InitCache(
  actid in number,
  actdate in date)
is

  waIND   NUMBER;
  status  PLS_INTEGER;

begin
  -- Check for refresh
  if ((actid = wf_activity.c_actid) and
      (actdate = wf_activity.c_actdate)) then
    return;
  end if;

  -- Checking global cache.
  WF_CACHE.GetProcessActivityInfo(actid, actdate, status, waIND);

  if (status <> WF_CACHE.task_SUCCESS) then
    waIND := 0;

    select WA.ITEM_TYPE, WA.NAME, WA.VERSION, WA.TYPE, WA.RERUN,
           WA.EXPAND_ROLE, WA.COST, WA.ERROR_ITEM_TYPE, WA.ERROR_PROCESS,
           WA.FUNCTION, WA.FUNCTION_TYPE, WA.MESSAGE, WA.BEGIN_DATE,
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
           WF_CACHE.ProcessActivities(actid).PROCESS_ITEM_TYPE,
           WF_CACHE.ProcessActivities(actid).PROCESS_NAME,
           WF_CACHE.ProcessActivities(actid).PROCESS_VERSION,
           WF_CACHE.ProcessActivities(actid).ACTIVITY_ITEM_TYPE,
           WF_CACHE.ProcessActivities(actid).ACTIVITY_NAME,
           WF_CACHE.ProcessActivities(actid).INSTANCE_ID,
           WF_CACHE.ProcessActivities(actid).INSTANCE_LABEL,
           WF_CACHE.ProcessActivities(actid).PERFORM_ROLE,
           WF_CACHE.ProcessActivities(actid).PERFORM_ROLE_TYPE,
           WF_CACHE.ProcessActivities(actid).START_END,
           WF_CACHE.ProcessActivities(actid).DEFAULT_RESULT

    from   WF_PROCESS_ACTIVITIES WPA, WF_ACTIVITIES WA

    where  WPA.INSTANCE_ID = actid
    and    WA.ITEM_TYPE = WPA.ACTIVITY_ITEM_TYPE
    and    WA.NAME = WPA.ACTIVITY_NAME
    and    actdate >= WA.BEGIN_DATE
    and    actdate < NVL(WA.END_DATE, actdate+1);

    waIND :=
     WF_CACHE.HashKey(WF_CACHE.ProcessActivities(actid).ACTIVITY_ITEM_TYPE ||
     WF_CACHE.ProcessActivities(actid).ACTIVITY_NAME);

    WF_CACHE.Activities(waIND) := WF_CACHE.Activities(0);

  end if;

  wf_activity.c_type          := WF_CACHE.Activities(waIND).TYPE;
  wf_activity.c_rerun         := WF_CACHE.Activities(waIND).RERUN;
  wf_activity.c_cost          := WF_CACHE.Activities(waIND).COST;
  wf_activity.c_error_type    := WF_CACHE.Activities(waIND).ERROR_ITEM_TYPE;
  wf_activity.c_error_process := WF_CACHE.Activities(waIND).ERROR_PROCESS;
  wf_activity.c_expand_role   := WF_CACHE.Activities(waIND).EXPAND_ROLE;
  wf_activity.c_function      := WF_CACHE.Activities(waIND).FUNCTION;
  wf_activity.c_function_type := nvl(WF_CACHE.Activities(waIND).FUNCTION_TYPE,
                                     'PL/SQL');
  wf_activity.c_message       := WF_CACHE.Activities(waIND).MESSAGE;
  wf_activity.c_msgtype       := WF_CACHE.Activities(waIND).ITEM_TYPE;
  wf_activity.c_event_name    := WF_CACHE.Activities(waIND).EVENT_NAME;
  wf_activity.c_direction     := WF_CACHE.Activities(waIND).DIRECTION;
  wf_activity.c_prole         := WF_CACHE.ProcessActivities(actid).PERFORM_ROLE;
  wf_activity.c_prole_type    := WF_CACHE.ProcessActivities(actid).PERFORM_ROLE_TYPE;
  wf_activity.c_start_end     := WF_CACHE.ProcessActivities(actid).START_END;

  -- Save cache key values
  wf_activity.c_actid := actid;
  wf_activity.c_actdate := actdate;

exception
  when others then
    Wf_Core.Context('Wf_Activity', 'InitCache', to_char(actid),
                    to_char(actdate));
    raise;
end InitCache;

--
-- Instance_Type (PRIVATE)
--   Returns the activity type by given the process activity (instance id).
--   If no data found, raise WF_INVALID_PROCESS_ACTIVITY.(Basically this means
--   the given process activity(actid) is bad.
-- IN
--   actid - Process activity(instance id).
--   actdate - Active date
--
function Instance_Type(actid in number,
                       actdate in date)
return varchar2
is
begin

  Wf_Activity.InitCache(actid, actdate);
  return(wf_activity.c_type);

exception
  when NO_DATA_FOUND then
    Wf_Core.Context('Wf_Activity', 'Instance_Type', to_char(actid),
                    to_char(actdate));
    Wf_Core.Token('ACTID', to_char(actid));
    Wf_Core.Token('DATE', to_char(actdate));
    Wf_Core.Raise('WFENG_ACTID');
  when OTHERS then
    Wf_Core.Context('Wf_Activity', 'Instance_Type', to_char(actid),
                    to_char(actdate));
    raise;
end Instance_Type;

--
-- Type (PRIVATE)
--   Returns the activity type by given the activity name and item type.
--   If no data found, return null.
-- IN
--   itemtype - Activity item type
--   activity - Activity name
--   actdate - Active date
--
function Type(itemtype in varchar2,
              activity in varchar2,
              actdate in date)
return varchar2
is
  waIND  NUMBER;
  status PLS_INTEGER;

begin
  WF_CACHE.GetActivity(itemtype, activity, actdate, status, waIND);

  if (status <> WF_CACHE.task_SUCCESS) then

    select WA.ITEM_TYPE, WA.NAME, WA.VERSION, WA.TYPE, WA.RERUN,
           WA.EXPAND_ROLE, WA.COST, WA.ERROR_ITEM_TYPE,
           WA.ERROR_PROCESS, WA.FUNCTION, WA.FUNCTION_TYPE,  WA.EVENT_NAME,
           WA.MESSAGE, WA.BEGIN_DATE, WA.END_DATE, WA.DIRECTION

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
           WF_CACHE.Activities(waIND).EVENT_NAME,
           WF_CACHE.Activities(waIND).MESSAGE,
           WF_CACHE.Activities(waIND).BEGIN_DATE,
           WF_CACHE.Activities(waIND).END_DATE,
           WF_CACHE.Activities(waIND).DIRECTION

    from   WF_ACTIVITIES WA
    where  WA.ITEM_TYPE = itemtype
    and    WA.NAME = activity
    and    actdate >= WA.BEGIN_DATE
    and    actdate < nvl(WA.END_DATE, actdate+1);

  end if;

  return (WF_CACHE.Activities(waIND).TYPE);

exception
  when NO_DATA_FOUND then
    return '';
  when OTHERS then
    Wf_Core.Context('Wf_Activity', 'Type', itemtype, activity,
                    to_char(actdate));
    raise;
end Type;

--
-- Info (PRIVATE)
--   Returns specific information for a given activity.
--   If no data found, raise WF_INVALID_PROCESS_ACTIVITY.(Basically this means
--   the given process activity(actid) is bad.
-- IN
--   actid - Process activity(instance id).
--   actdate - Active date
-- OUT
--   rerun - Rerun/Ignore
--   type  - Activity type
--   cost  - Activity cost
--   function_type - Activity function type
procedure Info(actid in number,
               actdate in date,
               rerun out NOCOPY varchar2,
               type  out NOCOPY varchar2,
               cost  out NOCOPY number,
               function_type out NOCOPY varchar2)
is
begin

  Wf_Activity.InitCache(actid, actdate);
  rerun := wf_activity.c_rerun;
  type := wf_activity.c_type;
  cost := wf_activity.c_cost;
  function_type := wf_activity.c_function_type;


exception
  when NO_DATA_FOUND then
    Wf_Core.Context('Wf_Activity', 'Info', to_char(actid), to_char(actdate));
    Wf_Core.Token('ACTID', to_char(actid));
    Wf_Core.Token('DATE', to_char(actdate));
    Wf_Core.Raise('WFENG_ACTID');
  when OTHERS then
    Wf_Core.Context('Wf_Activity', 'Info', to_char(actid), to_char(actdate));
    raise;
end Info;

--
-- Ending (PRIVATE)
--   Check if activity is an END activity (end process)
-- IN
--   actid - Process activity(instance id).
--   actdate - Active date
--
function Ending(actid in number,
                actdate in date)
return boolean
is
begin

  Wf_Activity.InitCache(actid, actdate);
  if (wf_activity.c_start_end = wf_engine.eng_end) then
    return(TRUE);
  else
    return(FALSE);
  end if;

exception
  when NO_DATA_FOUND then
    Wf_Core.Context('Wf_Activity', 'Ending', to_char(actid), to_char(actdate));
    Wf_Core.Token('ACTID', to_char(actid));
    Wf_Core.Token('DATE', to_char(actdate));
    Wf_Core.Raise('WFENG_ACTID');
  when OTHERS then
    Wf_Core.Context('Wf_Activity', 'Ending', to_char(actid), to_char(actdate));
    raise;
end Ending;

--
-- Error_Process (PRIVATE)
--   Returns the error item type and process name for a given activity.
--   If no data found, raise WF_INVALID_PROCESS_ACTIVITY.(Basically this means
--   the given process activity(actid) is bad.
-- IN
--   actid - Process activity(instance id).
--   actdate - Active date
-- OUT
--   errortype - the item type containing errorprocess
--   errorprocess - the process to run for an error

procedure Error_Process(actid in number,
                        actdate in date,
                        errortype in out NOCOPY varchar2,
                        errorprocess in out NOCOPY varchar2)
is
begin

  Wf_Activity.InitCache(actid, actdate);
  errortype:=wf_activity.c_error_type;
  errorprocess:=wf_activity.c_error_process;

  -- for backward compatability, ensure error type is set
  -- this is not necessary for 2.5 onwards.
  if errorprocess is not null and errortype is null then
     errortype:=wf_engine.eng_wferror;
  end if;

exception
  when NO_DATA_FOUND then
    Wf_Core.Context('Wf_Activity', 'Error_Process', to_char(actid),
                    to_char(actdate));
    Wf_Core.Token('ACTID', to_char(actid));
    Wf_Core.Token('DATE', to_char(actdate));
    Wf_Core.Raise('WFENG_ACTID');
  when OTHERS then
    Wf_Core.Context('Wf_Activity', 'Error_Process', to_char(actid),
                    to_char(actdate));
    raise;
end Error_Process;

--
-- Activity_Function (PRIVATE)
--   returns the activity function name.
-- IN
--   itemtype  - A valid item type
--   itemkey   - Item key
--   actid     - The activity instance id.
--
function Activity_Function(itemtype in varchar2,
                           itemkey in varchar2,
                           actid in number)
return varchar2
is
  actdate date;
begin
  actdate := Wf_Item.Active_Date(itemtype, itemkey);
  Wf_Activity.InitCache(actid, actdate);
  return(wf_activity.c_function);
exception
  when others then
    Wf_Core.Context('Wf_Activity', 'Activity_Function', itemtype, itemkey,
                    to_char(actid));
    raise;
end Activity_Function;

--
-- Activity_Function (PRIVATE)
--   returns the activity function name.
-- IN
--   itemtype  - A valid item type
--   itemkey   - Item key
--   actid     - The activity instance id.
--
function Activity_Function_Type(itemtype in varchar2,
                           itemkey in varchar2,
                           actid in number)
return varchar2
is
  actdate date;
begin
  actdate := Wf_Item.Active_Date(itemtype, itemkey);
  Wf_Activity.InitCache(actid, actdate);
  return(wf_activity.c_function_type);
exception
  when others then
    Wf_Core.Context('Wf_Activity', 'Activity_Function_Type', itemtype, itemkey,
                    to_char(actid));
    raise;
end Activity_Function_type;

--
-- Notification_Info (PRIVATE)
--   Returns notification-related info about an activity.
--   If no data found, raise WF_INVALID_PROCESS_ACTIVITY.(Basically this means
--   the given process activity(actid) is bad.
-- IN
--   itemtype - Item type
--   itemkey - Item key
--   actid - Process activity (notification activity instance id).
-- OUT
--   message - Message sent by notification
--   msgtype - Message type
--   expand_role - Flag to expand recipient list
--
procedure Notification_Info(itemtype in varchar2,
                            itemkey in varchar2,
                            actid in number,
                            message out NOCOPY varchar2,
                            msgtype out NOCOPY varchar2,
                            expand_role out NOCOPY varchar2)
is
  actdate date;
begin

  actdate := Wf_Item.Active_Date(itemtype, itemkey);
  Wf_Activity.InitCache(actid, actdate);
  message := wf_activity.c_message;
  msgtype := wf_activity.c_msgtype;
  expand_role := wf_activity.c_expand_role;

exception
  when no_data_found then
    Wf_Core.Context('Wf_Activity', 'Notification_Info', itemtype, itemkey,
                    to_char(actid));
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ACTID', to_char(actid));
    Wf_Core.Raise('WFENG_ITEM_ACTIVITY_STATUS');
  when others then
    Wf_Core.Context('Wf_Activity', 'Notification_Info', itemtype, itemkey,
                    to_char(actid));
    raise;
end Notification_Info;

--
-- Event_Info (PRIVATE)
--   Returns event-related info about an activity.
-- IN
--   itemtype - Item type
--   itemkey - Item key
--   actid - Process activity
-- OUT
--   event_name - Event name filter
--   direction - Event direction (RECEIVE/RAISE/SEND)
--
procedure Event_Info(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number,
  event_name out NOCOPY varchar2,
  direction out NOCOPY varchar2)
is
  actdate date;
begin

  actdate := Wf_Item.Active_Date(itemtype, itemkey);
  Wf_Activity.InitCache(actid, actdate);
  event_name := wf_activity.c_event_name;
  direction := wf_activity.c_direction;

exception
  when no_data_found then
    Wf_Core.Context('Wf_Activity', 'Event_Info', itemtype, itemkey,
                    to_char(actid));
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ACTID', to_char(actid));
    Wf_Core.Raise('WFENG_ITEM_ACTIVITY_STATUS');
  when others then
    Wf_Core.Context('Wf_Activity', 'Event_Info', itemtype, itemkey,
                    to_char(actid));
    raise;
end Event_Info;

--
-- Perform_Role (PRIVATE)
--   Get performer assigned to a notification
-- IN
--   itemtype - Item type
--   itemkey - Item key
--   actid - Process activity (notification activity instance id).
-- RETURNS
--   performrole - Role notification sent to
--
function Perform_Role(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number)
return varchar2
is
  actdate date;
  assuser varchar2(320);
  performrole varchar2(320);
begin

  -- Initialize cache for design-time data
  actdate := Wf_Item.Active_Date(itemtype, itemkey);
  Wf_Activity.InitCache(actid, actdate);

  -- Query WIAS for any runtime assigned_user changes
  select
    WIAS.ASSIGNED_USER
  into assuser
  from WF_ITEM_ACTIVITY_STATUSES WIAS
  where WIAS.ITEM_TYPE = itemtype
  and WIAS.ITEM_KEY = itemkey
  and WIAS.PROCESS_ACTIVITY = actid;

  --
  -- Decode the performrole as:
  -- 1. If WIAS.assigned_user not null, use that
  -- 2. If WPA.proletype = 'CONSTANT', then use WPA.prole.
  -- 3. If WPA.proletype = 'ITEMATTR', then WPA.prole is an item attr ref.
  if (assuser is not null) then
    performrole := assuser;
  elsif (wf_activity.c_prole_type = 'CONSTANT') then
    performrole := wf_activity.c_prole;
  else -- (must be proletype = 'ITEMATTR')
    -- Let the unknown_attribute exception propagate up if raised.
    -- The substr is to prevent value errors if the attr value is too
    -- long.
    performrole := substrb(Wf_Engine.GetItemAttrText(itemtype, itemkey,
                           wf_activity.c_prole), 1, 320);
  end if;

  return(performrole);
exception
  when no_data_found then
    Wf_Core.Context('Wf_Activity', 'Perform_Role', itemtype, itemkey,
                    to_char(actid));
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ACTID', to_char(actid));
    Wf_Core.Raise('WFENG_ITEM_ACTIVITY_STATUS');
  when others then
    Wf_Core.Context('Wf_Activity', 'Perform_Role', itemtype, itemkey,
                    to_char(actid));
    raise;
end Perform_Role;

--
-- Version (PRIVATE)
--   Get the version of an activity in use on the given date.
-- IN:
--   itemtype
--   activity - Activity name
--   actdate - Active date
-- RETURNS:
--   Version of activity in use on given date
--
function Version(itemtype in varchar2,
                 activity in varchar2,
                 actdate in date)
return number
is

  waIND  NUMBER;
  status PLS_INTEGER;

begin
  WF_CACHE.GetActivity(itemtype, activity, actdate, status, waIND);

  if (status <> WF_CACHE.task_SUCCESS) then

    select WA.ITEM_TYPE, WA.NAME, WA.VERSION, WA.TYPE, WA.RERUN, WA.EXPAND_ROLE,
           WA.COST, WA.ERROR_ITEM_TYPE, WA.ERROR_PROCESS, WA.FUNCTION,
           WA.FUNCTION_TYPE, WA.EVENT_NAME, WA.MESSAGE, WA.BEGIN_DATE,
           WA.END_DATE, WA.DIRECTION

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
           WF_CACHE.Activities(waIND).EVENT_NAME,
           WF_CACHE.Activities(waIND).MESSAGE,
           WF_CACHE.Activities(waIND).BEGIN_DATE,
           WF_CACHE.Activities(waIND).END_DATE,
           WF_CACHE.Activities(waIND).DIRECTION

    from   WF_ACTIVITIES WA
    where  WA.ITEM_TYPE = itemtype
    and    WA.NAME = activity
    and    actdate >= WA.BEGIN_DATE
    and    actdate < nvl(WA.END_DATE, actdate+1);

  end if;

  return (WF_CACHE.Activities(waIND).VERSION);

exception
  when NO_DATA_FOUND then
    Wf_Core.Context('Wf_Activity', 'Version', itemtype, activity,
                    to_char(actdate));
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('NAME', activity);
    Wf_Core.Token('DATE', to_char(actdate));
    Wf_Core.Raise('WFENG_ACTIVITY');
  when OTHERS then
    Wf_Core.Context('Wf_Activity', 'Version', itemtype, activity,
                    to_char(actdate));
    raise;
end Version;

end WF_ACTIVITY;

/
