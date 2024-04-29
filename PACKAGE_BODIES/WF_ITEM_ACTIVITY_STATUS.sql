--------------------------------------------------------
--  DDL for Package Body WF_ITEM_ACTIVITY_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ITEM_ACTIVITY_STATUS" as
/* $Header: wfengb.pls 120.25.12010000.17 2014/09/09 00:17:09 alsosa ship $ */

-- Runtime cache
c_itemtype varchar2(8);
c_itemkey varchar2(240);
c_actid number;
c_status varchar2(8);
c_result varchar2(30);
c_assigned_user varchar2(320);
c_notification_id number;
c_begindate date;
c_enddate date;
c_duedate date;
c_errname varchar2(30);
c_errmsg varchar2(2000);
c_errstack varchar2(4000);

-- Global Execution Counter (PRIVATE)
g_ExecCounter number := 0;

--
-- ClearCache
--   Clear runtime cache
--
procedure ClearCache
is
begin
  wf_item_activity_status.c_itemtype := '';
  wf_item_activity_status.c_itemkey := '';
  wf_item_activity_status.c_actid := '';
  wf_item_activity_status.c_status := '';
  wf_item_activity_status.c_result := '';
  wf_item_activity_status.c_assigned_user := '';
  wf_item_activity_status.c_notification_id := '';
  wf_item_activity_status.c_begindate := to_date(NULL);
  wf_item_activity_status.c_enddate := to_date(NULL);
  wf_item_activity_status.c_duedate := to_date(NULL);
  wf_item_activity_status.c_errname := '';
  wf_item_activity_status.c_errmsg := '';
  wf_item_activity_status.c_errstack := '';
exception
  when others then
    Wf_Core.Context('Wf_Item_Activity_Status', 'ClearCache');
    raise;
end ClearCache;

--
-- InitCache
--   Initialize runtime cache
--
procedure InitCache(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number,
  ignore_notfound in boolean default FALSE)

is
begin
  -- Check for refresh
  if ((itemtype = wf_item_activity_status.c_itemtype) and
      (itemkey = wf_item_activity_status.c_itemkey) and
      (actid = wf_item_activity_status.c_actid)) then
    return;
  end if;

  -- SYNCHMODE: Error if this is not current activity.
  if (itemkey = wf_engine.eng_synch) then
    Wf_Core.Token('ITEMTYPE', itemtype);
    Wf_Core.Token('ITEMKEY', itemkey);
    Wf_Core.Token('ACTID', to_char(actid));
    Wf_Core.Raise('WFSQL_INTERNAL');
  end if;

  -- Query new values
  select WIAS.ACTIVITY_STATUS, WIAS.ACTIVITY_RESULT_CODE,
         WIAS.ASSIGNED_USER,
         WIAS.NOTIFICATION_ID,
         WIAS.BEGIN_DATE, WIAS.END_DATE,
         WIAS.DUE_DATE,
         WIAS.ERROR_NAME, WIAS.ERROR_MESSAGE,
         WIAS.ERROR_STACK
  into wf_item_activity_status.c_status, wf_item_activity_status.c_result,
       wf_item_activity_status.c_assigned_user,
       wf_item_activity_status.c_notification_id,
       wf_item_activity_status.c_begindate, wf_item_activity_status.c_enddate,
       wf_item_activity_status.c_duedate,
       wf_item_activity_status.c_errname, wf_item_activity_status.c_errmsg,
       wf_item_activity_status.c_errstack
  from WF_ITEM_ACTIVITY_STATUSES WIAS
  where WIAS.ITEM_TYPE = itemtype
  and WIAS.ITEM_KEY = itemkey
  and WIAS.PROCESS_ACTIVITY = actid;

  -- Save cache key values
  wf_item_activity_status.c_itemtype := itemtype;
  wf_item_activity_status.c_itemkey := itemkey;
  wf_item_activity_status.c_actid := actid;

exception

 when NO_DATA_FOUND then
  if (ignore_notfound) then
      WF_ITEM_ACTIVITY_STATUS.ClearCache;

  else

     Wf_Core.Context('Wf_Item_Activity_Status', 'InitCache',
        itemtype, itemkey, to_char(actid));
     raise;

  end if;

 when others then
    Wf_Core.Context('Wf_Item_Activity_Status', 'InitCache',
        itemtype, itemkey, to_char(actid));
    raise;
end InitCache;

--
-- Update_Notification (PRIVATE)
--   Update the notification id and assigned user in WF_ITEM_ACTIVITY_STATUSES
--   table for a given item activity.
-- IN
--   itemtype - Activity item type.
--   itemkey  - The item key.
--   actid    - Process activity (instance id).
--   notid    - Notification id for this notification activity.
--   user     - The perform user for this notification activity.
--
procedure Update_Notification(itemtype in varchar2,
                              itemkey  in varchar2,
                              actid    in number,
                              notid    in number,
                              user     in varchar2)
is
begin
  update
    WF_ITEM_ACTIVITY_STATUSES set
    NOTIFICATION_ID = notid,
    ASSIGNED_USER = user
  where ITEM_TYPE = itemtype
  and   ITEM_KEY = itemkey
  and   PROCESS_ACTIVITY = actid;

  -- Update runtime cache if this is the current row
  if ((wf_item_activity_status.c_itemtype = itemtype) and
      (wf_item_activity_status.c_itemkey = itemkey) and
      (wf_item_activity_status.c_actid = actid)) then
    wf_item_activity_status.c_assigned_user := user;
    wf_item_activity_status.c_notification_id := notid;
  end if;

  if (Wf_Engine.Debug) then
    commit;
  end if;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Item_Activity_Status', 'Update_Notification', itemtype,
                    itemkey, to_char(actid), to_char(notid), user);
    raise;
end Update_Notification;

--
-- Root_Status (PRIVATE)
--   Returns the status and result for the root process of this item.
--   If the process is not yet active, the status and result will be null.
-- IN
--   itemtype - Activity item type.
--   itemkey  - The item key.
-- OUT
--   status   - Activity status for root process of this item
--   result   - Result code for root process of this item
--
procedure Root_Status(itemtype in varchar2,
                 itemkey  in varchar2,
                 status   out NOCOPY varchar2,
                 result   out NOCOPY varchar2)
is
  root varchar2(30);
  version pls_integer;
  rootid pls_integer;
begin
  -- Get root process
  Wf_Item.root_process(itemtype, itemkey, root, version);
  if (root is null) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM');
  end if;

  -- Get root process actid
  rootid := Wf_Process_Activity.RootInstanceId(itemtype, itemkey, root);
  if (rootid is null) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('NAME', root);
    Wf_Core.Raise('WFENG_PROCESS_RUNNABLE');
  end if;

  -- Get status
  Wf_Item_Activity_Status.Result(itemtype, itemkey, rootid, status, result);

exception
  when others then
    Wf_Core.Context('Wf_Item_Activity_Status', 'Root_Status',
                    itemtype, itemkey);
    raise;
end Root_Status;

--
-- LastResult
--   Get the instid and status of current row in cache.
--   Only used in SYNCHMODE.
-- IN
--   itemtype - itemtype of item
--   itemkey - itemkey of item
-- OUT
--   actid - instance id of current activity in cache
--   status - status of current activity in cache
--   result - result of current activity in cache
-- NOTE: ### Used by Flex - inform them of any api changes.
--
procedure LastResult(
  itemtype in varchar2,
  itemkey in varchar2,
  actid out NOCOPY number,
  status out NOCOPY varchar2,
  result out NOCOPY varchar2)
is
begin
  -- Check that the item matches one in the cache
  if ((itemtype <> nvl(wf_item_activity_status.c_itemtype, 'x')) or
      (itemkey <> nvl(wf_item_activity_status.c_itemkey, 'x'))) then
    Wf_Core.Token('ITEMTYPE', itemtype);
    Wf_Core.Token('ITEMKEY', itemkey);
    Wf_Core.Raise('WFENG_SYNCH_ITEM');
  end if;

  actid := wf_item_activity_status.c_actid;
  status := wf_item_activity_status.c_status;
  result := wf_item_activity_status.c_result;
exception
  when others then
    Wf_Core.Context('Wf_Item_Activity_Status', 'LastResult',
        itemtype, itemkey);
    raise;
end LastResult;

--
-- Status (PRIVATE)
--   Returns the status for this item activity. If there is no row in
--   the WF_ITEM_ACTIVITY_STATUSES table, the status out variable will be null.
-- IN
--   itemtype - Activity item type.
--   itemkey  - The item key.
--   actid    - Process activity (instance id).
-- OUT
--   status   - Activity status for this item activity.
--
procedure Status(itemtype in varchar2,
                 itemkey  in varchar2,
                 actid    in number,
                 status   out NOCOPY varchar2)
is
begin

  Wf_Item_Activity_Status.InitCache(itemtype, itemkey, actid,
                                    ignore_notfound=>TRUE);
  status := wf_item_activity_status.c_status;
  return;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Item_Activity_Status', 'Status', itemtype,
                    itemkey, to_char(actid));
    raise;
end Status;

--
-- Result (PRIVATE)
--   Returns the status and result for this item activity. If there is no
--   row in the WF_ITEM_ACTIVITY_STATUSES table, both status and result
--   out variables will be null.
-- IN
--   itemtype - Activity item type.
--   itemkey  - The item key.
--   actid    - Process activity (instance id).
-- OUT
--   status   - Activity status for this item activity.
--   result   - Activity result for this item activity.
--
procedure Result(itemtype in varchar2,
                 itemkey  in varchar2,
                 actid    in number,
                 status   out NOCOPY varchar2,
                 result   out NOCOPY varchar2) is

begin

  Wf_Item_Activity_Status.InitCache(itemtype, itemkey, actid,
                                    ignore_notfound=>TRUE);

  status := wf_item_activity_status.c_status;
  result := wf_item_activity_status.c_result;
  return;

exception
  when NO_DATA_FOUND then
    status := '';
    result := '';
  when OTHERS then
    Wf_Core.Context('Wf_Item_Activity_Status', 'Result', itemtype,
                    itemkey, to_char(actid));
    raise;
end Result;

--
-- Due_Date (PRIVATE)
--   Returns the duedate of an activity that will timeout
-- IN
--   itemtype - Activity item type.
--   itemkey  - The item key.
--   actid    - Process activity (instance id).
-- RETURNS
--   duedate - Date activity will timeout
--
function Due_Date(
  itemtype in varchar2,
  itemkey  in varchar2,
  actid    in number)
return date
is
begin

  Wf_Item_Activity_Status.InitCache(itemtype, itemkey, actid);
  return(wf_item_activity_status.c_duedate);

exception
  when others then
    Wf_Core.Context('Wf_Item_Activity_Status', 'Due_Date', itemtype,
                    itemkey, to_char(actid));
    raise;
end Due_Date;

--
-- Notification_Status (PRIVATE)
--   Returns the notification id and assigned user for this item activity.
--   If there is no row in the WF_ITEM_ACTIVITY_STATUSES table, the notid
--   and user out variables will contain null.
-- IN
--   itemtype - Activity item type.
--   itemkey  - The item key.
--   actid    - Process activity (instance id).
-- OUT
--   notid   - The notification id for this notification activity.
--   user    - The assigned user for this notification activity.
--
procedure Notification_Status(itemtype in varchar2,
                              itemkey  in varchar2,
                              actid    in number,
                              notid    out NOCOPY number,
                              user     out NOCOPY varchar2)
is
begin

  Wf_Item_Activity_Status.InitCache(itemtype, itemkey, actid,
                                    ignore_notfound=>TRUE);
  notid := wf_item_activity_status.c_notification_id;
  user := wf_item_activity_status.c_assigned_user;
  return;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Item_Activity_Status', 'Notification_Status', itemtype,
                    itemkey, to_char(actid));
    raise;
end Notification_Status;

--
-- Error_Info (PRIVATE)
--   Returns all error info for an activity.
-- IN
--   itemtype - Activity item type.
--   itemkey  - The item key.
--   actid    - Process activity (instance id).
-- OUT
--   errname - Error name
--   errmsg - Error message
--   errstack - Error stack
--
procedure Error_Info(itemtype in varchar2,
                     itemkey  in varchar2,
                     actid    in number,
                     errname out NOCOPY varchar2,
                     errmsg out NOCOPY varchar2,
                     errstack out NOCOPY varchar2)
is
begin

  Wf_Item_Activity_Status.InitCache(itemtype, itemkey, actid);
  errname := wf_item_activity_status.c_errname;
  errmsg := wf_item_activity_status.c_errmsg;
  errstack := wf_item_activity_status.c_errstack;
  return;

exception
  when NO_DATA_FOUND then
    Wf_Core.Context('Wf_Item_Activity_Status', 'Error_Info', itemtype,
                    itemkey, to_char(actid));
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ACTID', to_char(actid));
    Wf_Core.Raise('WFENG_ITEM_ACTIVITY_STATUS');
  when OTHERS then
    Wf_Core.Context('Wf_Item_Activity_Status', 'Error_Info', itemtype,
                    itemkey, to_char(actid));
    raise;
end Error_Info;

--
-- Set_Error (PRIVATE)
--   Set error status and save current error info for this item activity.
--   To be called when a client activity function has raised an
--   unhandled exception.
-- IN
--   itemtype - Activity item type
--   itemkey - Item Key
--   actid - Process activity id
--   errcode - Result code of activity
--   error_process - Flag if this error is in the error process,
--                   not in original activity
--
procedure Set_Error(itemtype in varchar2,
                    itemkey in varchar2,
                    actid in number,
                    errcode in varchar2,
                    error_process in boolean default FALSE)
is
  errname varchar2(30);
  errmsg varchar2(2000);
  errstack varchar2(4000);
  l_errname varchar2(30);
  l_errmsg varchar2(2000);
  l_errstack varchar2(4000);
  prefix varchar2(80);
  l_exist number(1);
begin
  -- First look for a standard WF_CORE exception.
  Wf_Core.Get_Error(errname, errmsg, errstack);

  if (errname is null) then
    -- If no WF_CORE exception, look for an Oracle error.
    errname := to_char(sqlcode);
    errmsg := sqlerrm;
  end if;

  if (error_process) then
    -- For an error in the error process, append the error info,
    -- but do NOT change the status or result.  Those come from the
    -- original error.

    -- SYNCHMODE:  This should NEVER happen in synchmode, since
    -- error processes are not allowed.
    if (itemkey = wf_engine.eng_synch) then
        wf_core.token('OPERATION',
            'Wf_Item_Activity_Status.Set_Error(error_process)');
        wf_core.raise('WFENG_SYNCH_DISABLED');
    end if;

    prefix := substrb(' ['||Wf_Core.Translate('WFENG_ERR_PROC_ERROR')||': ',
              1, 80);

    select
    error_name,error_message,error_stack
    into l_errname,l_errmsg,l_errstack
    from WF_ITEM_ACTIVITY_STATUSES
    where ITEM_TYPE = itemtype
    and ITEM_KEY = itemkey
    and PROCESS_ACTIVITY = actid;

    l_errname:= substrb(l_errname||prefix||errname||']', 1, 30);
    l_errmsg:=substrb(l_errmsg||prefix||errmsg||']', 1, 2000);
    l_errstack:=substrb(l_errstack||prefix||errstack||']', 1, 4000);
    update
      WF_ITEM_ACTIVITY_STATUSES set
      ERROR_NAME=l_errname,
      ERROR_MESSAGE = l_errmsg,
      ERROR_STACK = l_errstack
    where ITEM_TYPE = itemtype
    and ITEM_KEY = itemkey
    and PROCESS_ACTIVITY = actid;


    -- Update runtime cache
    if ((wf_item_activity_status.c_itemtype = itemtype) and
        (wf_item_activity_status.c_itemkey = itemkey) and
        (wf_item_activity_status.c_actid = actid)) then

      wf_item_activity_status.c_errname :=
          substrb(wf_item_activity_status.c_errname||prefix||errname||']',
                  1, 30);
      wf_item_activity_status.c_errmsg :=
          substrb(wf_item_activity_status.c_errmsg||prefix||errmsg||']',
                  1, 2000);
      wf_item_activity_status.c_errstack :=
          substrb(wf_item_activity_status.c_errstack||prefix||errstack||']',
                  1, 4000);

    end if;

  else
    -- Update runtime cache
    if ((wf_item_activity_status.c_itemtype = itemtype) and
        (wf_item_activity_status.c_itemkey = itemkey) and
        (wf_item_activity_status.c_actid = actid)) then

      wf_item_activity_status.c_errname := errname;
      wf_item_activity_status.c_errmsg := errmsg;
      wf_item_activity_status.c_errstack := errstack;
      wf_item_activity_status.c_status := wf_engine.eng_error;
      wf_item_activity_status.c_result := errcode;

    end if;

    -- SYNCHMODE:  In synch mode stop after updating internal cache.
    -- Note the ONLY place this should be called in synchmode
    -- is function_call or execute_activity if an activity raises
    -- an unhandled exception.
    if (itemkey = wf_engine.eng_synch) then
      return;
    end if;

    -- Store error info and set status/result

    update
    WF_ITEM_ACTIVITY_STATUSES set
      ACTIVITY_STATUS = wf_engine.eng_error,
      ACTIVITY_RESULT_CODE = errcode,
      ERROR_NAME = errname,
      ERROR_MESSAGE = errmsg,
      ERROR_STACK = errstack
    where ITEM_TYPE = itemtype
    and ITEM_KEY = itemkey
    and PROCESS_ACTIVITY = actid;


  end if;

  -- Bug 3960517
  -- No record was found in WF_ITEM_ACTIVITY_STATUSES.  We will check
  -- the history table.  If record exists in WF_ITEM_ACTIVITY_STATUSES_H,
  -- we may have re-entered a node causing engine to prepare for looping.
  -- But instead of going through all the activities along the loop, it has
  -- progressed through a different path.  Since there maybe multiple records
  -- in the history table with the same item type, item key and actid, we may
  -- not be able to mark the error accordingly, so we just simply ignore the error.
  if (SQL%NOTFOUND) then
    select 1 into l_exist
    from WF_ITEM_ACTIVITY_STATUSES_H
    where ITEM_TYPE = itemtype
    and ITEM_KEY= itemkey
    and process_activity = actid
    and rownum < 2;
    --raise NO_DATA_FOUND;
  end if;

  if (Wf_Engine.Debug) then
    commit;
  end if;
exception
  when NO_DATA_FOUND then
    Wf_Core.Context('Wf_Item_Activity_Status', 'Set_Error',
                    itemtype, itemkey, to_char(actid), errcode);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ACTID', to_char(actid));
    Wf_Core.Raise('WFENG_ITEM_ACTIVITY_STATUS');
  when OTHERS then
    Wf_Core.Context('Wf_Item_Activity_Status', 'Set_Error',
                    itemtype, itemkey, to_char(actid), errcode);

    raise;
end Set_Error;

--
-- Delete_Status (PRIVATE)
--   Deletes the row for this item activity from WF_ITEM_ACTIVITY_STATUSES.
-- IN
--   itemtype - Activity item type.
--   itemkey  - The item key.
--   actid    - Process activity (instance id).
--
procedure Delete_Status(itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number)
is
begin
  delete
  from WF_ITEM_ACTIVITY_STATUSES
  where ITEM_TYPE = itemtype
  and ITEM_KEY = itemkey
  and PROCESS_ACTIVITY = actid;

  -- Clear runtime cache if needed
  if ((wf_item_activity_status.c_itemtype = itemtype) and
      (wf_item_activity_status.c_itemkey = itemkey) and
      (wf_item_activity_status.c_actid = actid)) then
    wf_item_activity_status.c_itemtype := '';
    wf_item_activity_status.c_itemkey := '';
    wf_item_activity_status.c_actid := '';
  end if;

  if (Wf_Engine.Debug) then
    commit;
  end if;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Item_Activity_Status', 'Delete_Status', itemtype,
                    itemkey, to_char(actid));
    raise;
end Delete_Status;

--
-- Create_Status (PRIVATE)
--   If this item activity status already exists, then update its
--   status, result, begin date and end date.
--   Otherwise, create the activity status by inserting a new row into WIAS
--   table with the supplied status and result.
-- IN
--   itemtype - Activity item type.
--   itemkey  - The item key.
--   actid    - Process activity (instance id).
--   status   - Activity status for this item activity.
--   result   - Activity result for this item activity.
--   beginning - Activity begin_date, or null to leave unchanged
--   ending    - Activity end_date, or null to leave unchanged
--   callout   - determines if activity is a call outside the database
--   suspended - flag only ever set when called from Process_Activity
--               when parent is suspended
procedure Create_Status(itemtype  in varchar2,
                        itemkey   in varchar2,
                        actid     in number,
                        status    in varchar2,
                        result    in varchar2,
                        beginning in date,
                        ending    in date,
                        suspended in boolean,
                        newStatus in boolean)
is
  root varchar2(30);          -- Root process of activity
  version pls_integer;        -- Root process version
  rootid  pls_integer;        -- Id of root process
  act_fname varchar2(240);
  act_ftype varchar2(30);
  delay  number; -- dont use pls_integer or numeric overflow can occur.
  msg_id  raw(16):=null;
  l_result number;

  -- Timeout processing stuff
  duedate date;
  timeout number;
  msg varchar2(30);
  msgtype varchar2(8);
  expand_role varchar2(8);

  -- status flags
  l_newStatus boolean default FALSE;

begin
  if (itemkey = wf_engine.eng_synch) then

    -- SYNCHMODE:  Only update runtime cache.
    if ((wf_item_activity_status.c_itemtype = itemtype) and
        (wf_item_activity_status.c_itemkey = itemkey) and
        (wf_item_activity_status.c_actid = actid)) then
      -- Existing row.  Only update relevant parts
      wf_item_activity_status.c_status := status;
      if (result is not null) then
        wf_item_activity_status.c_result := result;
      end if;
      if (beginning is not null) then
        wf_item_activity_status.c_begindate := beginning;
      end if;
      if (ending is not null) then
        wf_item_activity_status.c_enddate := ending;
      end if;
    else
      -- Fresh new row.  Re-initialize everything.
      wf_item_activity_status.c_itemtype := itemtype;
      wf_item_activity_status.c_itemkey := itemkey;
      wf_item_activity_status.c_actid := actid;
      wf_item_activity_status.c_status := status;
      wf_item_activity_status.c_result := result;
      wf_item_activity_status.c_begindate := beginning;
      wf_item_activity_status.c_enddate := ending;
      wf_item_activity_status.c_duedate := to_date(NULL);
      wf_item_activity_status.c_assigned_user := '';
      wf_item_activity_status.c_notification_id := '';
      wf_item_activity_status.c_errname := '';
      wf_item_activity_status.c_errmsg := '';
      wf_item_activity_status.c_errstack := '';
    end if;

  else
    -- NORMAL mode:

    -- TIMEOUT PROCESSING
    -- Calculate new timeout date if begin_date is being changed.
    if (beginning is not null) then
      begin
        -- 1. Look first for a '#TIMEOUT' NUMBER attribute
        timeout := Wf_Engine.GetActivityAttrNumber(itemtype, itemkey,
                       actid, wf_engine.eng_timeout_attr,
                       ignore_notfound=>TRUE);

        if (nvl(timeout, 0) <> 0) then
          -- Figure duedate as offset from begin time.
          -- NOTE: Default timeout is in units of minutes, not days like
          -- all other 'date as number' values, thus the 1440 fudge factor.
          duedate := beginning + (timeout / 1440);
        else
          -- 2. Look for a '#TIMEOUT' DATE attribute
          duedate := Wf_Engine.GetActivityAttrDate(itemtype, itemkey,
                         actid, wf_engine.eng_timeout_attr,
                         ignore_notfound=>TRUE);
        end if;
      exception
        when others then
          if (wf_core.error_name = 'WFENG_ACTIVITY_ATTR') then
            -- No #TIMEOUT attr means no timeout
            wf_core.clear;
            duedate := null;
          else
            raise;
          end if;
      end;
    end if;

    -- DEFERRED QUEUE PROCESSING
    -- if deferred, insert into the deferred queue
    -- but not if parent is SUSPENDED or we get infinite loop in queue
    if create_status.status = wf_engine.eng_deferred
    and (not create_status.suspended )then

      act_fname:= Wf_Activity.activity_function(itemtype,itemkey,actid);
      act_ftype:= Wf_Activity.activity_function_type(itemtype,itemkey,actid);

      -- If enqueue fails, only the activity should error and not the root
      begin
        if act_ftype = 'PL/SQL' then

           if beginning is null then
              delay :=0;
           else
              delay := round((beginning - sysdate)*24*60*60 + 0.5);
           end if;
           wf_queue.enqueue_event
            (queuename=>wf_queue.DeferredQueue,
             itemtype=> itemtype,
             itemkey=>create_status.itemkey,
             actid=>create_status.actid,
             delay=>delay,
             message_handle=>msg_id);
            -- even when internal, keep message for cross reference.
            -- msg_id :=null;
        elsif act_ftype = 'EXTERNAL' then
           -- this is a callout so write to OUTBOUND queue
           -- do not set the correlation here for compatibility reason
           wf_queue.enqueue_event
            (queuename=>wf_queue.OutboundQueue,
             itemtype=> create_status.itemtype,
             itemkey=>create_status.itemkey,
             actid=>create_status.actid,
             funcname=>act_fname,
             paramlist=>wf_queue.get_param_list(itemtype,itemkey,actid),
             message_handle=>msg_id);
        else
           -- this is a callout so write to OUTBOUND queue for other type
           wf_queue.enqueue_event
            (queuename=>wf_queue.OutboundQueue,
             itemtype=> create_status.itemtype,
             itemkey=>create_status.itemkey,
             actid=>create_status.actid,
             correlation=>act_ftype,
             funcname=>act_fname,
             paramlist=>wf_queue.get_param_list(itemtype,itemkey,actid),
             message_handle=>msg_id);
        end if;
      exception
        when others then
            -- If any error while enqueing, set the activity status to ERROR
            Wf_Item_Activity_Status.Create_Status(itemtype, itemkey, actid,
                                         wf_engine.eng_error, wf_engine.eng_exception,
                                         sysdate, null, newStatus=>TRUE);
            Wf_Item_Activity_Status.Set_Error(itemtype, itemkey, actid,
                                              wf_engine.eng_exception, FALSE);
            Wf_Engine_Util.Execute_Error_Process(itemtype, itemkey, actid,
                                                 wf_engine.eng_exception);
            return;
      end;
    end if;

    -- Increment Counter
    g_ExecCounter := (g_ExecCounter + 1);

    -- Update the status in db. The execution_time is also reset if:
    -- 1. Changing status to active
    -- 2. Changing status to complete/error AND the execution_time is
    --    not yet set (activity has been aborted without being executed).

   if not (newStatus) then
    update
      WF_ITEM_ACTIVITY_STATUSES set
      ACTIVITY_STATUS = create_status.status,
      ACTIVITY_RESULT_CODE = nvl(create_status.result, ACTIVITY_RESULT_CODE),
      BEGIN_DATE = nvl(create_status.beginning, BEGIN_DATE),
      END_DATE = nvl(create_status.ending, END_DATE),
      DUE_DATE = decode(create_status.beginning,
                        to_date(NULL), DUE_DATE,
                        create_status.duedate),
      OUTBOUND_QUEUE_ID = msg_id,
      EXECUTION_TIME =
          decode(create_status.status,
              wf_engine.eng_active, g_ExecCounter,
              wf_engine.eng_completed, nvl(EXECUTION_TIME, g_ExecCounter),
              wf_engine.eng_error, nvl(EXECUTION_TIME, g_ExecCounter),
              EXECUTION_TIME)
    where ITEM_TYPE = create_status.itemtype
    and ITEM_KEY = create_status.itemkey
    and PROCESS_ACTIVITY = create_status.actid;
   end if;

    -- Create the status if not found
    if ((newStatus) or (SQL%ROWCOUNT = 0)) then
     begin
      insert
        into WF_ITEM_ACTIVITY_STATUSES (
        ITEM_TYPE,
        ITEM_KEY,
        PROCESS_ACTIVITY,
        ACTIVITY_STATUS,
        ACTIVITY_RESULT_CODE,
        ASSIGNED_USER,
        NOTIFICATION_ID,
        BEGIN_DATE,
        END_DATE,
        DUE_DATE,
        EXECUTION_TIME,
        OUTBOUND_QUEUE_ID
      ) values (
        create_status.itemtype,
        create_status.itemkey,
        create_status.actid,
        create_status.status,
        create_status.result,
        null,
        null,
        create_status.beginning,
        create_status.ending,
        create_status.duedate,
        decode(create_status.status,
            wf_engine.eng_active, g_ExecCounter,
            wf_engine.eng_completed, g_ExecCounter,
            wf_engine.eng_error, g_ExecCounter,
            null),
        create_status.msg_id
      );

      -- Initialize runtime cache with new row
      wf_item_activity_status.c_itemtype := itemtype;
      wf_item_activity_status.c_itemkey := itemkey;
      wf_item_activity_status.c_actid := actid;
      wf_item_activity_status.c_status := status;
      wf_item_activity_status.c_result := result;
      wf_item_activity_status.c_begindate := beginning;
      wf_item_activity_status.c_enddate := ending;
      wf_item_activity_status.c_duedate := duedate;
      wf_item_activity_status.c_assigned_user := '';
      wf_item_activity_status.c_notification_id := '';
      wf_item_activity_status.c_errname := '';
      wf_item_activity_status.c_errmsg := '';
      wf_item_activity_status.c_errstack := '';

      l_newStatus := TRUE;

     exception
    when DUP_VAL_ON_INDEX then
    -- If we are attempting to insert but the record exists, we will then
    -- automatically update to ensure fault tolerance.
     l_newStatus := FALSE;

       update
              WF_ITEM_ACTIVITY_STATUSES set
              ACTIVITY_STATUS = create_status.status,
              ACTIVITY_RESULT_CODE = nvl(create_status.result,
                                        ACTIVITY_RESULT_CODE),
              BEGIN_DATE = nvl(create_status.beginning, BEGIN_DATE),
              END_DATE = nvl(create_status.ending, END_DATE),
              DUE_DATE = decode(create_status.beginning,
                                to_date(NULL), DUE_DATE,
                                create_status.duedate),
              OUTBOUND_QUEUE_ID = msg_id,
              EXECUTION_TIME = decode(create_status.status,
                                wf_engine.eng_active, g_ExecCounter,
                                wf_engine.eng_completed, nvl(EXECUTION_TIME,
                                                             g_ExecCounter),
                                wf_engine.eng_error, nvl(EXECUTION_TIME,
                                                         g_ExecCounter),
                                      EXECUTION_TIME)
            where ITEM_TYPE = create_status.itemtype
            and ITEM_KEY = create_status.itemkey
            and PROCESS_ACTIVITY = create_status.actid;
     end;
    end if;


    if (not l_newStatus) then
      -- Update runtime cache with new data, if current row
      if ((wf_item_activity_status.c_itemtype = itemtype) and
          (wf_item_activity_status.c_itemkey = itemkey) and
          (wf_item_activity_status.c_actid = actid)) then
        wf_item_activity_status.c_status := status;
        if (result is not null) then
          wf_item_activity_status.c_result := result;
        end if;
        if (beginning is not null) then
          wf_item_activity_status.c_begindate := beginning;
          wf_item_activity_status.c_duedate := duedate;
        end if;
        if (ending is not null) then
          wf_item_activity_status.c_enddate := ending;
        end if;
      end if;
    end if;

    -- If the root process is being marked completed or active,
    -- then also update the end_date of the item.
    Wf_Item.Root_Process(itemtype, itemkey, root, version);
    rootid := Wf_Process_Activity.RootInstanceId(itemtype, itemkey, root);
    if (actid = rootid) then
      if (status = wf_engine.eng_completed) then
        l_result := WF_ITEM.SetEndDate(itemtype, itemkey);
      elsif (status = wf_engine.eng_active) then
        UPDATE WF_ITEMS SET
          END_DATE = to_date(NULL)
        WHERE ITEM_TYPE = itemtype
        AND ITEM_KEY = itemkey;
      end if;
    end if;
  end if;

  -- High availability support.  creates dependency on datamodel changes
  -- and WF_HA_MIGRATION package (WFHAMIG[S|B].pls)
  --if (WF_HA_MIGRATION.GET_CACHED_HA_MAINT_MODE = 'MAINT') then
  --        WF_HA_MIGRATION.SET_HA_FLAG(itemtype, itemkey);
  --end if;

  if (Wf_Engine.Debug) then
    commit;
  end if;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Item_Activity_Status', 'Create_Status', itemtype,
                    itemkey, to_char(actid), status, result);
    raise;
end Create_Status;

--
-- Audit (PRIVATE)
--   Procedure to update the item activity status record with Audit
--   information if the activity was expedited from Status Monitor
-- IN
--   itemtype  - Item Type
--   itemkey   - Item Key
--   actid     - Activity Id
--   action    - Action performed on the activity
--   performer - User performed the action
procedure Audit(itemtype  in varchar2,
                itemkey   in varchar2,
                actid     in number,
                action    in varchar2,
                performer in varchar2)
is
  l_username varchar2(320);
begin
  -- if the performer is not provided get the current session user
  if (performer is null) then
    l_username := wfa_sec.GetUser();
  else
    l_username := performer;
  end if;

  -- update the status record with the action and performer
  UPDATE wf_item_activity_statuses
  SET    action = Audit.action,
         performed_by = l_username
  WHERE  item_type = Audit.itemtype
  AND    item_key = Audit.itemkey
  AND    process_activity = Audit.actid;

  --Bug 3361746
  --The existing handleerror API does not mandatorily require an entry in
  --wf_item_activity_statuses table, hence we should not throw an
  --exception if no row is found for the activity.

exception
  when others then
    Wf_Core.Context('Wf_Item_Activity_Status', 'Audit', itemtype, itemkey, to_char(actid));
    raise;
end Audit;

-- 3966635 Workflow Provisioning Project
-- The following is added in order not to loose the changes required.
-- --
-- -- Update_Prov_Request (PRIVATE)
-- --   Procedure to update the item activity status record with Provision Request Id
-- -- IN
-- --   itemtype        - Item Type
-- --   itemkey         - Item Key
-- --   actid           - Activity Id
-- --   prov_request_id - Provision request id
-- procedure Update_Prov_Request(itemtype        in varchar2,
--                               itemkey         in varchar2,
--                               actid           in number,
--                               prov_request_id in number)
-- is
-- begin
--
--   UPDATE wf_item_activity_statuses
--   SET    prov_request_id = Update_Prov_Request.prov_request_id
--   WHERE  item_type = Update_Prov_Request.itemtype
--   AND    item_key = Update_Prov_Request.itemkey
--   AND    process_activity = Update_Prov_Request.actid;
--
-- exception
--   when others then
--     Wf_Core.Context('Wf_Item_Activity_Status', 'Update_Prov_Request', itemtype, itemkey, to_char(actid));
--     raise;
-- end Update_Prov_Request;
--
end WF_ITEM_ACTIVITY_STATUS;

/
