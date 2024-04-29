--------------------------------------------------------
--  DDL for Package Body WF_QUEUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_QUEUE" AS
/* $Header: wfqueb.pls 120.5.12010000.3 2009/09/17 03:14:51 vshanmug ship $ */

  --
  -- Exceptions
  --
  dequeue_timeout exception;
  pragma EXCEPTION_INIT(dequeue_timeout, -25228);

  dequeue_disabled exception;
  pragma EXCEPTION_INIT(dequeue_disabled, -25226);

  dequeue_outofseq exception;
  pragma EXCEPTION_INIT(dequeue_outofseq, -25237);

  no_queue exception;
  pragma EXCEPTION_INIT(no_queue, -24010);

  shutdown_pending exception;

  no_savepoint exception;
  pragma EXCEPTION_INIT(no_savepoint, -1086);

  msgid_notfound exception;
  pragma EXCEPTION_INIT(msgid_notfound, -25263);

  -- Bug 4005674
  -- private global variables to store the item_type:item_key:actid at dequeue time
  g_dequeue_item_type       varchar2(8);
  g_dequeue_item_key        varchar2(240);
  g_dequeue_actid           number;
  g_background_begin_date   date;
  g_Key                     number;

  TYPE ActivityHistoryREC IS RECORD (
       ITEM_TYPE             VARCHAR2(8),
       ITEM_KEY              VARCHAR2(240),
       ACTID                 NUMBER,
       HISTORY_COUNT         NUMBER );

  TYPE ActivityHistoryCountTAB IS TABLE OF ActivityHistoryREC INDEX BY BINARY_INTEGER;
  g_ActivityHistoryCount    ActivityHistoryCountTAB;

-- ====================================================================
--
-- Private Routine to check for shutdown
--
-- ====================================================================

function check_instance return boolean
as
  shutdown  varchar2(3);
begin

  select shutdown_pending into shutdown from v$instance;

  if shutdown = 'YES' then
    return(TRUE);
  else
    return(FALSE);
  end if;

end;

-- ====================================================================
--
-- Private Procedure which processes the payload dequeued off the
-- Inbound queue .
--
-- ====================================================================

-- Process_Inbound_Event (PRIVATE)
-- Executes the payload dequeued off the inbound queue
-- IN
--   itemtype - itemtype,itemkey,actid to uniquely identify the
--   itemkey  - activity
--   actid    -
--   message_handle - pointer to queue message
--   p_payload - the message payload . Lets have it as in/out parameter
--   so that if callback (for which it is in/out) changes something
--   we can have it.

procedure Process_Inbound_Event(itemtype in varchar2,
                         itemkey        in varchar2,
                         actid          in number,
                         message_handle in raw,
                         p_payload      in out nocopy system.wf_payload_t)
as
colon           number;
status          varchar2(30);

plist     varchar2(4000);
attrpair  varchar2(4000);
delimiter number;
aname     varchar2(40);
avalue    varchar2(4000);
lcorrelation varchar2(80);

nvalue number; --required but not used by wf_engine.CB
dvalue date;   --required but not used by wf_engine.CB

begin

  --process the parameter list.
  plist:= p_payload.param_list;

  if plist is not null then
    loop
      -- if plist is null then EXIT; end if;
      delimiter:=instr(plist,'^');

      if delimiter = 0 then
        attrpair:=plist;
      else
        attrpair:=substr(plist,1,delimiter-1);
      end if;

      aname    := upper(substr(attrpair,1,instr(attrpair,'=')-1));
      avalue   := substr(attrpair,instr(attrpair,'=')+1);

      begin
        --Set the value for the attribute
        wf_engine.SetItemAttrText(itemtype, itemkey,
                                     aname, avalue);
      exception when others then
        if ( wf_core.error_name = 'WFENG_ITEM_ATTR' ) then
           --If the attribute does not exist first create it
           --and then add the value
           Wf_Engine.AddItemAttr(itemtype, itemkey, aname);
           Wf_Engine.SetItemAttrText(itemtype, itemkey, aname, avalue);
        else
           raise;
        end if;
      end;

      exit when delimiter = 0;

      plist := substr(plist,delimiter+1);

     end loop;
     end if;

     --if payload contains a colon, then its ERROR else its COMPLETE status

     colon:= instr(p_payload.result,':');
     if colon=0 or p_payload.result is null then
       -- check if activity is already complete
       wf_item_activity_status.status(itemtype,itemkey,actid,status);
       if  (status is not null)
        and (status <> 'COMPLETE') then
            -- mark activity as Complete:<result>
            wf_engine.CB(command => 'COMPLETE',
                         context =>itemtype||':'||
                                   itemkey ||':'||
                                   actid,
                         text_value => p_payload.result,
                         number_value => nvalue,
                         date_value   => dvalue);
        end if;
     else
       -- at the moment we only accept :ERROR:<error text> (may add other statuses later)
       if substr(p_payload.result,colon+1,5) = 'ERROR' then

         begin
         wf_core.clear;
         -- set the function name for courtesy.
         wf_core.token('FUNCTION_NAME',
                        Wf_Activity.activity_function(itemtype,
                                    itemkey,actid));
         wf_core.raise('WF_EXT_FUNCTION');
         exception when others then null;
         end;
         --function name on payload is upto 200 char so use it to record error
         wf_core.error_stack := p_payload.function_name;

         wf_engine.CB(command => 'ERROR',
                      context =>itemtype||':'||
                                itemkey ||':'||
                                actid,
                      text_value => p_payload.result,
                      number_value => nvalue,
                      date_value   => dvalue);
       end if;
      end if;

   --If we came successfully till here let us purge off the
   --data from the Q
   wf_queue.PurgeEvent(wf_queue.InboundQueue, message_handle, FALSE);

exception
  when others then
    Wf_Core.Context('Wf_Queue', 'Process_Inbound_Event', itemtype,itemkey);

    raise;

end Process_Inbound_Event;

-- ====================================================================
-- Queue Setup Functions (PUBLIC)
-- ====================================================================
function DeferredQueue return varchar2
as
begin
   if (wf_queue.name_init = FALSE) then
       wf_queue.set_queue_names;
   end if;
   return (wf_queue.deferred_queue_name);
   exception
     when others then
     Wf_Core.Context('Wf_Queue', 'DeferredQueue');
     raise;
end;

function OutboundQueue return varchar2
as
begin
   if (wf_queue.name_init = FALSE) then
       wf_queue.set_queue_names;
   end if;
   return (wf_queue.outbound_queue_name);
exception
    when others then
    Wf_Core.Context('Wf_Queue', 'OutboundQueue');
    raise;
end;

function InboundQueue return varchar2
as
begin
   if (wf_queue.name_init = FALSE) then
       wf_queue.set_queue_names;
   end if;
   return (wf_queue.inbound_queue_name);
exception
     when others then
     Wf_Core.Context('Wf_Queue', 'InboundQueue');
     raise;
end;

-- NAME: Set_queue_names (PRIVATE)
-- called once at the beginning of a session to set up queue names
-- when AQ supports db synonyms, remove this and use synonyms instead
procedure set_queue_names as

schema_name varchar2(320);

begin

   --dont bother re-executing this if already initialized.
   if wf_queue.name_init then
      return;
   end if;

   schema_name := wf_core.translate('WF_SCHEMA');

   -- Do not determine account name by STANDALONE vs. EMBEDDED any more

   -- Current_schema is the schema in effect.
   -- Sys_context is an 8i feature.  Below allows us to tag on the
   -- intended schema whether the install is with invoker's right or
   -- definer's right (default).
   begin
     select sys_context('USERENV', 'CURRENT_SCHEMA')
       into wf_queue.account_name
       from sys.dual;
   exception
     when OTHERS then
       wf_queue.account_name := NULL;
   end;

   wf_queue.deferred_queue_name := schema_name||'.WF_DEFERRED_QUEUE_M';
   wf_queue.outbound_queue_name := schema_name||'.WF_OUTBOUND_QUEUE';
   wf_queue.inbound_queue_name  := schema_name||'.WF_INBOUND_QUEUE';
   wf_queue.name_init := TRUE;
exception
    when others then
    Wf_Core.Context('Wf_Queue', 'Set_queue_names');
    raise;
end set_queue_names;


-- ====================================================================
-- Public routines
-- ====================================================================

-- NAME: PurgeEvent
-- removes the event from the specified queue WITHOUT PROCESSING
-- queuename - the queue to purge
-- message_handle - the specific event to purge
--
procedure PurgeEvent(queuename in varchar2,
                     message_handle in raw,
                     multiconsumer in boolean default FALSE) as

  event                 system.wf_payload_t;
  dequeue_options       dbms_aq.dequeue_options_t;
  message_properties    dbms_aq.message_properties_t;
  msg_id                raw(16);
begin
  if message_handle is not null then

     dequeue_options.dequeue_mode := dbms_aq.REMOVE;
     dequeue_options.msgid        := message_handle;
     dequeue_options.wait         := dbms_aq.NO_WAIT;
     dequeue_options.navigation   := dbms_aq.FIRST_MESSAGE;

     -- check if we need to have a consumer
     if (multiconsumer) then
       dequeue_options.consumer_name := wf_queue.account_name;
     end if;

     dbms_aq.dequeue
     (
       queue_name => queuename,
       dequeue_options => dequeue_options,
       message_properties => message_properties,
       payload => event,
       msgid => msg_id
     );

  end if;

exception
    when dequeue_timeout then
     null; -- not found on queue so must already be removed.

    when msgid_notfound then
     null; -- Already purged from the queue.

    when others then
      Wf_Core.Context('Wf_Queue', 'PurgeEvent', queuename,
                       rawtohex(message_handle));
      raise;

end PurgeEvent;

-- NAME: PurgeItemtype
-- removes all events belonging to an itemtype from the specified queue
-- ** WARNING ** IT DOES NOT PROCESS THE EVENT
-- queuename - the queue to purge
-- itemtype - the itemtype to purge
--
procedure PurgeItemtype(queuename in varchar2,
                        itemtype in varchar2 default null,
                        correlation in varchar2 default null )
as
      event                 system.wf_payload_t;
      dequeue_options       dbms_aq.dequeue_options_t;
      message_properties    dbms_aq.message_properties_t;
      msg_id                raw(16);

begin
    dequeue_options.dequeue_mode := dbms_aq.REMOVE;
    dequeue_options.wait := dbms_aq.NO_WAIT;
    dequeue_options.navigation  := dbms_aq.FIRST_MESSAGE;
    wf_queue.set_queue_names;

    if correlation is not null then
       dequeue_options.correlation := correlation;
    else
       dequeue_options.correlation := wf_queue.account_name||nvl(itemtype,'%');
    end if;

  LOOP
        dbms_aq.dequeue
        (
          queue_name => queuename,
          dequeue_options => dequeue_options,
          message_properties => message_properties,
          payload => event,
          msgid => msg_id
        );

  END LOOP;

exception
    when dequeue_timeout then
         null; -- nothing left on queue to remove
    when others then
    Wf_Core.Context('Wf_Queue', 'PurgeItemtype', queuename, itemtype);
    raise;
end PurgeItemtype;

-- ProcessDeferredEvent (PRIVATE)
-- Executes the event payload dequeued off the deferred queue
-- IN
--   itemtype - itemtype,itemkey,actid to uniquely identify the
--   itemkey  - activity
--   actid    -
--   message_handle - pointer to queue message
--   minthreshold - threshold levels of the background engine
--   maxthreshold
--
procedure ProcessDeferredEvent(itemtype in varchar2,
                         itemkey        in varchar2,
                         actid          in number,
                         message_handle in raw,
                         minthreshold   in number,
                         maxthreshold   in number)
as
begin
      Wf_Item_Activity_Status.Create_Status(itemtype, itemkey, actid,
         wf_engine.eng_active, null, null, null);

      -- Continue processing on activity
      begin

       begin
        begin

        savepoint wf_savepoint;

        Wf_Engine_Util.Process_Activity(itemtype, itemkey, actid,
            maxthreshold, TRUE);

        -- we successfully processed the activity so dequeue it.
        wf_queue.PurgeEvent(wf_queue.DeferredQueue, message_handle, TRUE);


        Exception
         when others then
          -- In the unlikely event this process thread raises an exception:
          -- 1. rollback any work in this process thread
          -- raise an error for the next excption handler to complete
          -- remaining steps.

          rollback to wf_savepoint;
          raise;
        end;
       exception
         when NO_SAVEPOINT then
           -- Catch any savepoint error in case of a commit happened.
           Wf_Core.Token('ACTIVITY', Wf_Engine.GetActivityLabel(actid));
           Wf_Core.Raise('WFENG_COMMIT_IN_PROCESS');
       end;
      exception
        when OTHERS then
          -- Remaining steps for proces thread raises an exception:
          -- 2. set this activity to error status
          -- 3. execute the error process (if any)
          -- 4. clear the error to continue with next activity
          -- **note the error stack will refer to the actid that has been
          -- rolled back!
          Wf_Core.Context('Wf_Queue', 'ProcessDeferredEvent', itemtype,
              to_char(minthreshold), to_char(maxthreshold));
          Wf_Item_Activity_Status.Set_Error(itemtype, itemkey, actid,
              wf_engine.eng_exception, FALSE);
          Wf_Engine_Util.Execute_Error_Process(itemtype, itemkey,
              actid, wf_engine.eng_exception);
          Wf_Core.Clear;
      end;

      -- Commit work to insure this activity thread doesn't interfere
      -- with others.
      commit;

      Fnd_Concurrent.Set_Preferred_RBS;

exception
  when others then
    Wf_Core.Context('Wf_Queue', 'ProcessDeferredEvent', itemtype,
                    to_char(minthreshold), to_char(maxthreshold));
    raise;
end ProcessDeferredEvent;


--Name: EnqueueInbound (PUBLIC)
--Enqueues the result from an outbound event onto
--the inbound queue. Wf will mark this as complete with the
--given result when it processes the queue.

procedure EnqueueInbound(
                        itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        result          in varchar2 default null,
                        attrlist        in varchar2 default null,
                        correlation     in varchar2 default null,
                        error_stack     in varchar2 default null)

as
handle raw(16);
lcorrelation varchar2(80);
lresult varchar2(30);
begin


  if correlation is not null then
     lcorrelation := correlation;
  else
     wf_queue.set_queue_names;
     lcorrelation := wf_queue.account_name||itemtype;
  end if;

  -- if error stack is defined then set result to ERROR.
  if error_stack is null then
     lresult := result;
  else
     lresult := ':ERROR';
  end if;


  wf_queue.Enqueue_Event(queuename      =>wf_queue.InboundQueue,
                        itemtype        =>enqueueInbound.itemtype,
                        itemkey         =>enqueueInbound.itemkey,
                        actid           =>enqueueInbound.actid,
                        funcname        =>enqueueInbound.error_stack,
                        correlation     =>lcorrelation,
                        paramlist       =>enqueueInbound.attrlist,
                        result          =>lresult,
                        message_handle  =>handle);
exception
  when others then
    Wf_Core.Context('Wf_Queue', 'EnqueueInbound', itemtype,
                    itemkey, actid);
    raise;
end EnqueueInbound;


function Get_param_list (itemtype       in varchar2,
                         itemkey        in varchar2,
                         actid          in number) return varchar2

as

startdate  date;
paramlist  varchar2(4000);
lvalue     varchar2(4000);

cursor attr_list is
select  aa.name,
        aa.value_type, -- CONSTANT or ITEMATTR
        aa.type,       -- NUMBER/TEXT/DATE etc
        aa.format,
        av.TEXT_VALUE,
        av.NUMBER_VALUE,
        av.DATE_VALUE
from wf_activity_attr_values av,
     wf_activity_attributes aa,
     wf_activities a,
     wf_process_activities pa
where pa.activity_item_type = a.item_type
and pa.activity_name = a.name
and pa.instance_id=actid
and a.begin_date< startdate and nvl(a.end_date,startdate) >= startdate
and a.item_type = aa.activity_item_type
and a.name = aa.activity_name
and a.version = aa.activity_version
and av.process_activity_id = actid
and av.name=aa.name
order by aa.sequence;

begin
  paramlist:=null;
  startdate:=wf_item.active_date(itemtype,itemkey);

  for attr_row in attr_list loop
      if (attr_row.value_type = 'ITEMATTR' and
          attr_row.text_value is not null) then
         -- null itemattr text_value means null value, not an error
         lvalue := wf_engine.GetItemAttrText(itemtype,itemkey,
                        attr_row.text_value);
      else --must be CONSTANT
        if (attr_row.type = 'NUMBER') then
          if (attr_row.format is null) then
            lvalue := to_char(attr_row.NUMBER_VALUE);
          else
            lvalue := to_char(attr_row.NUMBER_VALUE, attr_row.format);
          end if;
        elsif (attr_row.type = 'DATE') then
          if (attr_row.format is null) then
            lvalue := to_char(attr_row.DATE_VALUE);
          else
            lvalue := to_char(attr_row.DATE_VALUE, attr_row.format);
          end if;
        else
          lvalue := attr_row.text_value;
        end if;
      end if;

      if paramlist is not null then
         -- Overflow, cannot hold anymore attributes.
         if (lengthb(paramlist||'^') > 4000) then
            exit;
         else
            paramlist := paramlist||'^';
         end if;
      end if;

      if (lengthb(paramlist||attr_row.name||'='||lvalue) > 4000) then
         -- Overflow, cannot hold anymore attributes.
         paramlist:=substrb(paramlist||attr_row.name||'='||lvalue, 1, 4000);
         exit;
      else
         paramlist := paramlist||attr_row.name||'='||lvalue;
      end if;
  end loop;

  return(paramlist);

exception
  when others then
    Wf_Core.Context('Wf_Queue', 'Get_param_list', itemtype,
                    itemkey, actid);
    raise;
end Get_param_list;



--Name: DequeueOutbound (PUBLIC)

procedure DequeueOutbound(
                        dequeuemode     in  number,
                        navigation      in  number   default 1,
                        correlation     in  varchar2 default null,
                        itemtype        in  varchar2 default null,
                        payload         out NOCOPY system.wf_payload_t,
                        message_handle  in out NOCOPY raw,
                        timeout         out NOCOPY boolean)

as
lcorrelation varchar2(80);
begin
     wf_queue.set_queue_names;

     if correlation is not null then
        lcorrelation := correlation;
     else
        lcorrelation := wf_queue.account_name||nvl(itemtype,'%');
     end if;

     wf_queue.Dequeue_Event(queuename   =>wf_queue.OutboundQueue,
                        dequeuemode     =>DequeueOutbound.dequeuemode,
                        navigation      =>DequeueOutbound.navigation,
                        correlation     =>lcorrelation,
                        payload         =>DequeueOutbound.payload,
                        message_handle  =>DequeueOutbound.message_handle,
                        timeout         =>DequeueOutbound.timeout);



exception
  when others then
    Wf_Core.Context('Wf_Queue', 'DequeueOutbound', payload.itemtype,
                    payload.itemkey, payload.actid);
    raise;

end DequeueOutbound;

--Name: DequeueEventDetail (PUBLIC)
--
--Wrapper to Dequeue_Event in which the payload is EXPanded out to avoid
--use of type itemtypes.

procedure DequeueEventDetail(
                        dequeuemode     in  number,
                        navigation      in  number   default 1,
                        correlation     in  varchar2 default null,
                        itemtype        in  out NOCOPY varchar2,
                        itemkey         out NOCOPY varchar2,
                        actid           out NOCOPY number,
                        function_name   out NOCOPY varchar2,
                        param_list      out NOCOPY varchar2,
                        message_handle  in out NOCOPY raw,
                        timeout         out NOCOPY boolean)
as
event system.wf_payload_t;
lcorrelation varchar2(80);
begin
  wf_queue.set_queue_names;

  --use the correlation or default it if null
  if DequeueEventDetail.correlation is not  null then
     lcorrelation := DequeueEventDetail.correlation;
  else
     lcorrelation := wf_queue.account_name||nvl(itemtype,'%');
  end if;

  -- call dequeue to retrieve the event
  wf_queue.Dequeue_Event(queuename=>wf_queue.OutboundQueue,
                         dequeuemode=>DequeueEventDetail.dequeuemode,
                         navigation =>DequeueEventDetail.navigation,
                         correlation=>lcorrelation,
                         payload=>event,
                         message_handle=>DequeueEventDetail.message_handle,
                         timeout =>DequeueEventDetail.timeout);

  --expand the payload structure
  DequeueEventDetail.itemtype:=event.itemtype;
  DequeueEventDetail.itemkey:=event.itemkey;
  DequeueEventDetail.actid:=event.actid;
  DequeueEventDetail.function_name:=event.function_name;
  DequeueEventDetail.param_list:=event.param_list;


exception
  when others then
    Wf_Core.Context('Wf_Queue', 'DequeueEventDetail', itemtype||':'||itemkey,to_char(actid));
    raise;

end DequeueEventDetail;


--Dequeue_Event (PRIVATE)
--
--Dequeues an event (message) from any queue
--IN
-- QueueName - the queue name, may contain owner or database
-- DeQueueMode - either 1 (Browse), 2 (Locked) or 3 (Remove)
-- Navigation - either First or Next
-- Correlation - helps restrict the queue
-- Payload - the event actually dequeued
-- message_handle - id for the event
-- timeout - determines if anything was found or if the q timedout.

procedure Dequeue_Event(queuename       in  varchar2,
                        dequeuemode     in  number,
                        navigation      in  number default 1,
                        correlation     in  varchar2 default null,
                        payload         out NOCOPY system.wf_payload_t,
                        message_handle  in out NOCOPY raw,
                        timeout         out NOCOPY boolean,
                        multiconsumer   in  boolean default FALSE)
as

  dequeue_options       dbms_aq.dequeue_options_t;
  message_properties    dbms_aq.message_properties_t;
  snap_too_old exception;
  pragma exception_init(snap_too_old, -1555);
begin

  -- find out the schema name
  wf_queue.set_queue_names;

  dequeue_options.dequeue_mode := dequeuemode;
  dequeue_options.wait := dbms_aq.NO_WAIT;
  dequeue_options.navigation   := navigation;

  -- if message_handle is set then use it instead of correlation
  -- NOTE: if message_handle is set FIRST/NEXT_MESSAGE dont have effect

  if message_handle is not null then
      dequeue_options.msgid        := message_handle;
      dequeue_options.correlation  := null;
      message_handle := null;
  else
      -- set correlation to item_type or % if its null
      if correlation is null then
          dequeue_options.correlation := '%';
      else
          dequeue_options.correlation := correlation;
      end if;

  end if;

  -- check if we need to have a consumer
  if (multiconsumer) then
    dequeue_options.consumer_name := wf_queue.account_name;
  end if;

  begin
    dbms_aq.dequeue( queue_name => Dequeue_Event.queuename,
                     dequeue_options => dequeue_options,
                     message_properties => message_properties,
                     payload => Dequeue_Event.payload,
                     msgid => message_handle );

  exception
    when snap_too_old then
      --Workaround for AQ when receiving ORA-01555 using NEXT_MESSAGE as
      --navigation.  We will try to set to FIRST_MESSAGE and dequeue to
      --silently handle this exception.
      if (dequeue_options.navigation = dbms_aq.FIRST_MESSAGE) then
        raise;
      else
        dequeue_options.navigation := dbms_aq.FIRST_MESSAGE;
        dbms_aq.dequeue( queue_name => Dequeue_Event.queuename,
                         dequeue_options => dequeue_options,
                         message_properties => message_properties,
                         payload => Dequeue_Event.payload,
                         msgid => message_handle );
      end if;

    when OTHERS then
      raise;

  end;

  timeout:= FALSE;

exception
  when dequeue_timeout then
    timeout := TRUE;
  when others then
    if correlation is null then
      Wf_Core.Context('WF_QUEUE', 'Dequeue_Event', queuename, '%');
    else
      Wf_Core.Context('WF_QUEUE', 'Dequeue_Event', queuename, correlation);
    end if;
    timeout := FALSE;
    raise;

end Dequeue_Event;

-- Activity_Valid (PRIVATE)
-- checks the deferred activity is valid for processing
--
-- IN
-- event - the event to check
-- message_handle of event in the deferred queue
-- maxthreshold - the threshold level
-- minthreshold
--
function activity_valid (event        in system.wf_payload_t,
                         message_handle in raw,
                         maxthreshold in number default null,
                         minthreshold in number default null)
return BOOLEAN is
  cost           pls_integer;
  litemtype      varchar2(8);
  l_begdate      date;          -- <dlam:3070112>

  resource_busy exception;
  pragma exception_init(resource_busy, -00054);

begin


      -- Activity must be valid if
      -- 1) in given cost range
      -- 2) parent is not suspended
      --    note: suspendprocess/resumeprocess will remove/add deferred jobs


      -- <dlam:3070112> check begin date as well
      -- move the BEGIN_DATE, SYSDATE comparion to a separate clause
      SELECT CWA.COST, CWIAS.BEGIN_DATE
      into cost, l_begdate
      FROM WF_ITEM_ACTIVITY_STATUSES CWIAS,
           WF_PROCESS_ACTIVITIES CWPA,
           WF_ITEMS WI,
           WF_ACTIVITIES CWA
      where CWIAS.ACTIVITY_STATUS = 'DEFERRED'
      and CWIAS.PROCESS_ACTIVITY = CWPA.INSTANCE_ID
      and CWPA.ACTIVITY_ITEM_TYPE = CWA.ITEM_TYPE
      and CWPA.ACTIVITY_NAME = CWA.NAME
      and CWIAS.ITEM_TYPE = WI.ITEM_TYPE
      and CWIAS.ITEM_KEY = WI.ITEM_KEY
      and WI.BEGIN_DATE >= CWA.BEGIN_DATE
      and WI.BEGIN_DATE < nvl(CWA.END_DATE, WI.BEGIN_DATE+1)
      and CWIAS.ITEM_TYPE = event.itemtype
      and CWIAS.ITEM_KEY = event.itemkey
      and CWIAS.PROCESS_ACTIVITY = event.actid;

-- dont bother locking: the original msg has been locked on the queue
--      for update of CWIAS.ACTIVITY_STATUS NOWAIT;

     -- dont bother checking if parent is suspended.
     -- the suspend process should remove any jobs from the queue,
     -- but if any get through, process_activity will manage it.

      -- <dlam:3070112>
      -- begin date has not reached yet, leave the message alone.
      -- this is to work around a problem where the aq delay seems to
      -- to be shorter than expected
      if (l_begdate > sysdate) then
        return(FALSE);
      end if;

      if cost < nvl(minthreshold,cost) or cost > nvl(maxthreshold,cost) then
         return(FALSE);
      else
         return(TRUE);
      end if;

exception
   when no_data_found then
     -- this event is no longer valid so remove it from the queue
     -- happens when a rewind moved activity to history table
     -- or the activity status is no longer defered
     wf_queue.PurgeEvent(wf_queue.DeferredQueue,message_handle,TRUE);
     return(FALSE);
   when resource_busy then
     return(FALSE);
   when others then
     Wf_Core.Context('Wf_Queue', 'Activity_valid', 'Invalid',
                     event.itemtype||':'||event.itemkey, to_char(event.actid));
     return(FALSE);
end activity_valid;

--
-- ====================================================================
--
-- Enqueue_Event (PRIVATE)
-- Enqueues a message onto any WF queue (because all queues have same payload)
--

procedure Enqueue_Event(queuename       in varchar2,
                        itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        correlation     in varchar2 default null,
                        delay           in number   default 0,
                        funcname        in varchar2 default null,
                        paramlist       in varchar2 default null,
                        result          in varchar2 default null,
                        message_handle  in out NOCOPY raw,
                        priority        in number default null)

as
  event              system.wf_payload_t;
  enqueue_options    dbms_aq.enqueue_options_t;
  message_properties dbms_aq.message_properties_t;
  l_increment_delay         number;
  l_min_delay               number;
  l_background_occurrence   number;

begin

  l_increment_delay := delay;

  -- Bug 4005674
  -- Check the occurrence of item_type:item_key:actid.  If this is the same
  -- activity which we just dequeued, calculate the number of occurrence
  -- from history table since the background engine started.
  if (wf_queue.g_dequeue_item_type = enqueue_event.itemtype and
      wf_queue.g_dequeue_item_key = enqueue_event.itemkey and
      wf_queue.g_dequeue_actid = enqueue_event.actid) then

    g_Key := WF_CACHE.HashKey(enqueue_event.itemtype||':'||
                enqueue_event.itemkey||':'||enqueue_event.actid);

    -- If hashkey does not exist or the itemtype:itemkey:actid do not match,
    -- get the history count from base table, else increment the l_background_occurrence
    if (not g_ActivityHistoryCount.EXISTS(g_Key) or
       (g_ActivityHistoryCount(g_Key).ITEM_TYPE <> enqueue_event.itemtype) or
       (g_ActivityHistoryCount(g_Key).ITEM_KEY <> enqueue_event.itemkey) or
       (g_ActivityHistoryCount(g_Key).ACTID <> enqueue_event.actid)) then

      select count(process_activity)
      into   l_background_occurrence
      from   wf_item_activity_statuses_h
      where  item_type = enqueue_event.itemtype
      and    item_key = enqueue_event.itemkey
      and    process_activity = enqueue_event.actid
      and    begin_date >= g_background_begin_date;
    else
      l_background_occurrence := g_ActivityHistoryCount(g_Key).HISTORY_COUNT + 1;
    end if;

    -- Record the itemtype:itemkey:actid:history_count in hash table
    g_ActivityHistoryCount(g_Key).ITEM_TYPE     := enqueue_event.itemtype;
    g_ActivityHistoryCount(g_Key).ITEM_KEY      := enqueue_event.itemkey;
    g_ActivityHistoryCount(g_Key).ACTID         := enqueue_event.actid;
    g_ActivityHistoryCount(g_Key).HISTORY_COUNT := l_background_occurrence;

    -- Bug 4005674
    -- For every 100 occurrences, add 5 mins to the delay up to a max of 60 mins
    l_min_delay := floor(l_background_occurrence/wf_queue.g_defer_occurrence)
                   * wf_queue.g_add_delay_seconds;

    if (l_min_delay < wf_queue.g_max_delay_seconds) then
      l_increment_delay := l_increment_delay + l_min_delay;
    elsif (l_min_delay >= wf_queue.g_max_delay_seconds) then
      l_increment_delay := l_increment_delay + wf_queue.g_max_delay_seconds;
    end if;

    begin
      -- Add a run-time item attribute of #DELAY_ACTID_<actid> to track the
      -- continuous loop
      Wf_Engine.SetItemAttrNumber(itemtype=>enqueue_event.itemtype,
                                  itemkey=>enqueue_event.itemkey,
                                  aname=>'#DELAY_ACTID_'||enqueue_event.actid,
                                  avalue=>l_increment_delay);
    exception
      when others then
        if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
          Wf_Core.Clear;
          Wf_Engine.AddItemAttr(itemtype=>enqueue_event.itemtype,
                                itemkey=>enqueue_event.itemkey,
                                aname=>'#DELAY_ACTID_'||enqueue_event.actid,
                                number_value=>l_increment_delay);
        else
          raise;
        end if;
    end;
  end if;

  wf_queue.set_queue_names;
  -- construct the event object
  event:=system.wf_payload_t(itemtype,itemkey,actid,funcname,paramlist,result);

  -- dont make the data visible on the queue until a commit is issued
  -- this way queue data and normal table data (wf statuses) are in synch.
  enqueue_options.visibility := DBMS_AQ.ON_COMMIT;

  -- Set the delay if any
  if l_increment_delay < 0  then
     message_properties.delay := 0;
  else
     -- message_properties.delay is BINARY_INTEGER, so check if delay is
     -- too big, and set the max delay to be (2**31)-1.
     if (l_increment_delay >= power(2,31)) then
       message_properties.delay := power(2,31)-1;
     else
       message_properties.delay := l_increment_delay;
     end if;

  end if;

  if correlation is not null then
     message_properties.correlation := enqueue_event.correlation;
  else
     message_properties.correlation := wf_queue.account_name||itemtype;
  end if;

  -- check the correlation is always set to something
  -- else it wil never be dequeued because we always default the dequeue
  -- corellation to '%'
  if message_properties.correlation is null then
     -- this shouldnt happen.
     message_properties.correlation := '%';
  end if;

  -- Set the priority so that we can dequeue by priority
  if priority is not null then
    message_properties.priority := priority;
  end if;

  dbms_aq.enqueue
  (
    queue_name => Enqueue_Event.queuename,
    enqueue_options => enqueue_options,
    message_properties => message_properties,
    payload => event,
    msgid => message_handle
  );


exception
  when others then
    Wf_Core.Context('Wf_Queue', 'Enqueue_event', itemtype,
                    itemkey, to_char(actid), to_char(delay));
    raise;

end;


-- ProcessInboundQueue (PUBLIC)
-- reads everythig off the Inbound queue and records it as complete
-- with the given result and updates item attributes as specified in
-- the paramlist


procedure ProcessInboundQueue (itemtype     in varchar2 default null,
                               correlation  in varchar2 default null)
as

payload         system.wf_payload_t;
navigation      varchar2(10);
timeout         boolean:= FALSE;
cursor_name     number;
row_processed   integer;
message_handle  raw(16);
-- first_time      boolean := TRUE;
plist     varchar2(4000);
lcorrelation varchar2(80);
nothing_processed  boolean := TRUE;

begin
  commit;

  Fnd_Concurrent.Set_Preferred_RBS;

  wf_queue.set_queue_names;

  if correlation is not null then
       lcorrelation := correlation;
  else
       lcorrelation := wf_queue.account_name||nvl(itemtype,'%');
  end if;

 -- loop through the inbound queue.
 loop --Process until nothing left on the queue

  navigation := dbms_aq.FIRST_MESSAGE;
  nothing_processed :=TRUE;

   loop -- Process till timeout

     message_handle:=null;
     --Lets set a savepoint here
     --We would use this savepoint to rollback if we found that a
     --lock is not possible in this session for the reterived itemytype key

     wf_queue.Dequeue_Event(wf_queue.InboundQueue,
                             dbms_aq.LOCKED,
                             navigation,
                             lcorrelation,
                             payload,
                             message_handle,
                             timeout);

     -- if no message is found, the message may be enqueued with the
     -- old correlation format, so reset the correlation id and retry.
     if (navigation = dbms_aq.FIRST_MESSAGE and message_handle is null
         and correlation is null and lcorrelation <> nvl(itemtype,'%')) then

       lcorrelation := nvl(itemtype,'%');
       goto nextmesg;
     end if;

     --else check timeout
     if (timeout) then
       EXIT;
     end if;

     --Bug 2607770
     --Ensure that we have got a message
     --Now try to acquire the lock
     --Check the parameterlist null/not within Process_Inbound_Event

     if wf_item.acquire_lock(payload.itemtype, payload.itemkey) then
       --Process the payload
       wf_queue.Process_Inbound_Event(itemtype=>payload.itemtype,
                           itemkey=>payload.itemkey,
                           actid=>payload.actid,
                           message_handle=>ProcessInboundQueue.message_handle,
                           p_payload => payload);

       -- bug 7828862 - Resynch apps context from cached values if it changed
       wfa_sec.Restore_Ctx();

       nothing_processed:=FALSE;

      end if;

      -- commit any processing or any clean up
      commit;
      Fnd_Concurrent.Set_Preferred_RBS;

     navigation := dbms_aq.NEXT_MESSAGE;

     <<nextmesg>>  -- This is for the case when we reset the corrid and verify
     null;
   end loop;       -- process till timeout

  exit when nothing_processed;
 end loop;
exception
  when others then
    Wf_Core.Context('Wf_Queue', 'ProcessInboundQueue');
    raise;
end ProcessInboundQueue;

procedure ProcessDeferredQueue (itemtype     in varchar2 default null,
                                minthreshold in number default null,
                                maxthreshold in number default null,
                                correlation  in varchar2 default null)

as
payload        system.wf_payload_t;
timeout        boolean:= FALSE;
navigation     varchar2(10);
row_processed  integer;
message_handle raw(16);
-- first_time boolean := TRUE;
nothing_processed boolean:=TRUE;
lcorrelation   varchar2(80);

begin

  -- Bug 4005674
  -- Record the sysdate when background engine started.
  g_background_begin_date := sysdate;

  wf_queue.set_queue_names;

  if correlation is not null then
     lcorrelation := correlation;

  -- for standalone, we first try the old correlation id format.
  elsif (wf_core.translate('WF_INSTALL') = 'STANDALONE'
         and itemtype is not null) then
     lcorrelation := itemtype;

  -- for embedded, there was never the old format, so we are fine.
  -- or it is standalone with null item type, we cannot support the
  -- old correlation id format; otherwise, it will pick up everything.
  else
     lcorrelation := wf_queue.account_name||nvl(itemtype,'%');
  end if;

  loop -- keep processing the queue until there is nothing left

    navigation := dbms_aq.FIRST_MESSAGE;
    nothing_processed :=TRUE;

    loop -- keep processing until a timeout.

      message_handle:=null;
      wf_queue.Dequeue_Event(
               wf_queue.DeferredQueue,
               dbms_aq.LOCKED,
               navigation,
               lcorrelation,
               payload,
               message_handle,
               timeout,
               TRUE);

      -- Bug 4005674
      -- Record the item_type:item_key:actid at dequeue time
      wf_queue.g_dequeue_item_type := payload.itemtype;
      wf_queue.g_dequeue_item_key  := payload.itemkey;
      wf_queue.g_dequeue_actid     := payload.actid;

      -- if no message is found, the message may be enqueued with the
      -- new correlation format, so reset the correlation id and retry.
      if (navigation = dbms_aq.FIRST_MESSAGE and message_handle is null
          and correlation is null and lcorrelation = itemtype) then

        lcorrelation := wf_queue.account_name||nvl(itemtype,'%');

      -- otherwise, process the message
      else
        if (timeout) then
           EXIT;
        end if;

        --
        -- Execute the PL/SQL call stored in the payload if this is valid
        --
        if activity_valid (payload,
                           message_handle,
                           maxthreshold,
                           minthreshold )
                           AND
           wf_item.acquire_lock(payload.itemtype,payload.itemkey) then

           wf_queue.ProcessDeferredEvent(itemtype=>payload.itemtype,
                           itemkey=>payload.itemkey,
                           actid=>payload.actid,
                           message_handle=>ProcessDeferredQueue.message_handle,
                           minthreshold=>ProcessDeferredQueue.minthreshold,
                           maxthreshold=>ProcessDeferredQueue.maxthreshold);

           -- bug 7828862 - Resynch apps context from cached values if it changed
           wfa_sec.Restore_Ctx();

           nothing_processed:=FALSE;

        end if;

        -- commit any processing or any clean up from activity_valid
        commit;
        Fnd_Concurrent.Set_Preferred_RBS;

        --
        -- Test for Instance Shutdown
        --
        if wf_queue.check_instance then
          raise shutdown_pending;
        end if;

        navigation := dbms_aq.NEXT_MESSAGE;

      end if;
    end loop;  -- process till time out

    exit when nothing_processed;

  end loop;

exception
  when dequeue_disabled then
    Wf_Core.Context('Wf_Queue', 'ProcessDeferredQueue', 'Queue shutdown');
    raise;
  when shutdown_pending then
    Wf_Core.Context('Wf_Queue', 'ProcessDeferredQueue', 'DB shutting down');
    raise;
  when others then
    Wf_Core.Context('Wf_Queue', 'ProcessDeferredQueue');
    raise;
end ProcessDeferredQueue;


--============================================================
-- Support utilities. not sure if we want to release these
--============================================================
-- GetMessageHandle
-- does a sequential search through the queue for the message handle

function   GetMessageHandle(queuename in varchar2,
                            itemtype  in varchar2,
                            itemkey   in varchar2,
                            actid     in number,
                            correlation in varchar2 default null,
                            multiconsumer in boolean default FALSE) return raw
is
   event                 system.wf_payload_t;
   dequeue_options       dbms_aq.dequeue_options_t;
   message_properties    dbms_aq.message_properties_t;
   msg_id raw(16);
begin
   dequeue_options.dequeue_mode := dbms_aq.BROWSE;
   dequeue_options.wait := dbms_aq.NO_WAIT;
   wf_queue.set_queue_names;
   if correlation is not null  then
      dequeue_options.correlation := correlation;
   else
      dequeue_options.correlation := wf_queue.account_name||nvl(itemtype,'%');
   end if;

  if (multiconsumer) then
    dequeue_options.consumer_name := wf_queue.account_name;
  end if;

   --execute first read
   dequeue_options.navigation   := dbms_aq.FIRST_MESSAGE;
   dbms_aq.dequeue
        (
          queue_name => queuename,
          dequeue_options => dequeue_options,
          message_properties => message_properties,
          payload => event,
          msgid => msg_id
        );

   if  event.itemtype = itemtype
   and event.itemkey  = itemkey
   and event.actid    = nvl(actid,event.actid) then
      return (msg_id);
   end if;

   -- loop with next message
   LOOP
        dequeue_options.navigation   := dbms_aq.NEXT_MESSAGE;
        dbms_aq.dequeue
        (
          queue_name => queuename,
          dequeue_options => dequeue_options,
          message_properties => message_properties,
          payload => event,
          msgid => msg_id
        );

       if  event.itemtype = itemtype
       and event.itemkey  = itemkey
       and event.actid    = actid      then
          return (msg_id);
       end if;

   END LOOP;

   return(null);

  exception -- timeout will fall to here
  when others then
       return(null);
end GetMessageHandle;
--=============================================================
-- PUBLIC API to dequeue from exception queue to wf_error
-- queue
--=============================================================
procedure DequeueException (queuename in varchar2)
is

  l_event               wf_event_t;
  x_dequeue_options     dbms_aq.dequeue_options_t;
  x_message_properties  dbms_aq.message_properties_t;
  x_msgid               RAW(16);
  erragt    wf_agent_t;
  lsysname  varchar2(30);
  cmd       varchar2(1000);
  no_messages           exception;
  pragma exception_init (no_messages, -25228);

begin

  -- To Dequeue from Exception Queue, consumer name must be null
  x_dequeue_options.consumer_name := null;
  x_dequeue_options.wait          := 1;

  loop
    begin
      dbms_aq.dequeue(queue_name         => queuename,
                    dequeue_options    => x_dequeue_options,
                    message_properties => x_message_properties, /* OUT */
                    payload            => l_event,              /* OUT */
                    msgid              => x_msgid);             /* OUT */

      /*
      ** Update the event to let everyone know it expired
      */
      l_event.SetErrorMessage(wf_core.translate('WFE_MESSAGE_EXPIRED'));
      l_event.addParameterToList('ERROR_NAME',
                        wf_core.translate('WFE_MESSAGE_EXPIRED') );
      l_event.addParameterToList('ERROR_TYPE', 'ERROR');

      /*
      ** As we can't use the private API SaveErrorToQueue
      ** we copy a little bit of code to do it
      */
      select name into lsysname
      from   wf_systems
      where  guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'));

      erragt := wf_agent_t('WF_ERROR', lsysname);
      cmd := 'begin WF_ERROR_QH.enqueue(:v1, :v2); end;';
      execute immediate cmd using in l_event,
                              in erragt;

      commit;

      exception
        when no_messages then
        if (wf_log_pkg.level_event >= fnd_log.g_current_runtime_level) then
           wf_log_pkg.string(wf_log_pkg.level_event,
                            'wf.plsql.WF_QUEUE.DequeueException.queue_empty',
                            'No more messages in ExceptionDequeue.');
        end if;
        exit;
    end;
  end loop;
exception
  when others then
    Wf_Core.Context('Wf_Queue', 'DequeueException',queuename);
    raise;
end DequeueException;
--=============================================================
-- Declare all developer APIs for Inbound queue manipulation
--
--=============================================================

--
-- ClearMsgStack
--   Clears runtime cache
procedure ClearMsgStack
is
begin
  wf_queue.stck_itemtype(1) := '';
  wf_queue.stck_itemkey(1) := '';
  wf_queue.stck_actid(1) := 0;
  wf_queue.stck_ctr := 0;
exception
  when others then
    Wf_Core.Context('Wf_Queue', 'ClearMsgStack');
    raise;
end ClearMsgStack;


--Name: WriteMsg
--writes a message from stack to the queue
procedure WriteMsg (
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number)
is
i pls_integer;
begin

  i := wf_queue.SearchMsgStack(itemtype,itemkey,actid);

  wf_queue.EnqueueInbound(
                        itemtype=>wf_queue.stck_itemtype(i),
                        itemkey =>wf_queue.stck_itemkey(i),
                        actid   =>wf_queue.stck_actid(i),
                        result  =>wf_queue.stck_result(i),
                        attrlist=>wf_queue.stck_attrlist(i));


exception
  when others then
    Wf_Core.Context('Wf_Queue', 'WriteMsg');
    raise;

end WriteMsg;

--Name: CreateMsg
--creates a message on the stack
--
procedure CreateMsg (
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number)
is
i pls_integer;
begin

  i := wf_queue.SearchMsgStack(itemtype,itemkey,actid);

exception
  when others then
    Wf_Core.Context('Wf_Queue', 'CreateMsg');
    raise;

end CreateMsg;



--Name: SetMsgAttr (PUBLIC)
--Appends message attributes.
--
procedure SetMsgAttr(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number,
  attrName in varchar2,
  attrValue in varchar2)
is
i pls_integer;
begin
  i := SearchMsgStack (itemtype, itemkey, actid);

  if wf_queue.stck_attrlist(i) is null then
     wf_queue.stck_attrlist(i) := upper(attrName)||'='||AttrValue;
  else
     wf_queue.stck_attrlist(i) :=
           wf_queue.stck_attrlist(i) ||'^'||attrName||'='||AttrValue;
  end if;

exception
  when others then
    Wf_Core.Context('Wf_Queue', 'SetMsgAttr',
        itemtype, itemkey, actid, to_char(stck_ctr));
    raise;
end SetMsgAttr;

--Name: SetMsgResult (PUBLIC)
--Sets the result value for this message.
--
procedure SetMsgResult(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number,
  result in varchar2)
is
i pls_integer;
begin
  i := SearchMsgStack (itemtype, itemkey, actid);

  wf_queue.stck_result(i) :=result;

exception
  when others then
    Wf_Core.Context('Wf_Queue', 'AddResult',
        itemtype, itemkey, actid, to_char(stck_ctr));
    raise;
end SetMsgResult;

--
-- AddNewMsg (PRIVATE)
--   Add a new message to the stack
-- IN
--   itemtype - item itemtype
--   itemkey - item itemkey
--   actid - instance id of process
--
procedure AddNewMsg(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number)
is
begin

  -- Add the process to the stack
  wf_queue.stck_ctr := wf_queue.stck_ctr + 1;
  wf_queue.stck_itemtype(wf_queue.stck_ctr) := itemtype;
  wf_queue.stck_itemkey(wf_queue.stck_ctr) := itemkey;
  wf_queue.stck_actid(wf_queue.stck_ctr) := actid;
  wf_queue.stck_result(wf_queue.stck_ctr) := null;
  wf_queue.stck_AttrList(wf_queue.stck_ctr) := null;

exception
  when others then
    Wf_Core.Context('Wf_Queue', 'AddNewMsg',
        itemtype, itemkey, actid, to_char(stck_ctr));
    raise;
end AddNewMsg;

--Name: SearchMsgStack (PRIVATE)
--Desc: sequential search of the message stack
--      starting from the top
--
function SearchMsgStack (
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number) RETURN number
is

i pls_integer;

begin

  if ( nvl(wf_queue.stck_ctr, 0) > 0) then
       for i in reverse 1 .. wf_queue.stck_ctr loop
          if ((itemtype = wf_queue.stck_itemtype(i)) and
             (itemkey   = wf_queue.stck_itemkey(i)) and
             (actid     = wf_queue.stck_actid(i))) then
             -- Found a match.
             return(i);
          end if;
       end loop;
   end if;

   -- not in the Stack so add it.
   AddNewMsg(itemtype,itemkey,actid);
   return (stck_ctr);

end SearchMsgStack;

--
-- Generic_Queue_Display
--   Produce list of generic_queues
--
-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 - added alt attrib for IMG tag for ADA
--             - Added summary attr for table tags for ADA
--             - Added ID attr for TD tags for ADA
--
procedure Generic_Queue_Display
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
  admin_mode varchar2(1) := 'N';
  realname varchar2(360);   -- Display name of username
  s0 varchar2(2000);       -- Dummy
  l_error_msg varchar2(240);
  l_url                varchar2(240);
  l_media              varchar2(240) := wfa_html.image_loc;
  l_icon               varchar2(40);
  l_text               varchar2(240);
  l_onmouseover        varchar2(240);


  cursor queues_cursor is
    select  wfq.protocol,
            wfq.inbound_outbound,
            wfq.description,
            wfq.queue_count
    from    wf_queues wfq
    where   NVL(wfq.disable_flag, 'N') = 'N'
    order by     wfq.protocol, wfq.inbound_outbound;

  rowcount number;

begin

  -- Check current user has admin authority
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_directory.GetRoleInfo(username, realname, s0, s0, s0, s0);

  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
     Wf_Directory.IsPerformer(username, admin_role)) then
         admin_mode := 'Y';
  else

     l_error_msg := wf_core.translate('WFPREF_INVALID_ADMIN');

  end if;

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.p('<BASE TARGET="_top">');
  htp.title(wf_core.translate('WFGENERIC_QUEUE_TITLE'));
  wfa_html.create_help_function('wf/links/dmr.htm?DMREP');
  htp.headClose;
  wfa_sec.Header(FALSE, '',wf_core.translate('WFGENERIC_QUEUE_TITLE'), FALSE);
  htp.br;

  IF (admin_mode = 'N') THEN

     htp.center(htf.bold(l_error_msg));
     return;

  END IF;

  -- Column headers
  htp.tableOpen(cattributes=>'border=1 cellpadding=3 bgcolor=white width="100%" summary=""');
  htp.tableRowOpen(cattributes=>'bgcolor=#006699');


  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('PROTOCOL')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' || wf_core.translate('PROTOCOL') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('QUEUE_DESCRIPTION')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' || wf_core.translate('QUEUE_DESCRIPTION') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('INBOUND_PROMPT')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' || wf_core.translate('INBOUND_PROMPT') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('QUEUE_COUNT')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' || wf_core.translate('QUEUE_COUNT') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('VIEW_DETAIL')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' || wf_core.translate('VIEW_DETAIL') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('DELETE')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' || wf_core.translate('DELETE') || '"');

  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableRowClose;

  -- Show all nodes
  for queues in queues_cursor loop

    htp.tableRowOpen(null, 'TOP');


    htp.tableData(htf.anchor2(
                    curl=>wfa_html.base_url||
                      '/wf_queue.generic_queue_edit?p_protocol='||
                      queues.protocol||'&p_inbound_outbound='||
                      queues.inbound_outbound,
                  ctext=>queues.protocol, ctarget=>'_top'),
                  'Left',
                  cattributes=>'headers="' ||
                            wf_core.translate('PROTOCOL') || '"');

    htp.tableData(queues.description, 'left',
                  cattributes=>'headers="' || wf_core.translate('QUEUE_DESCRIPTION') || '"');

    htp.tableData(queues.inbound_outbound, 'left',
                  cattributes=>'headers="' || wf_core.translate('INBOUND_PROMPT') || '"');

    htp.tableData(queues.queue_count, 'left',
                  cattributes=>'headers="' || wf_core.translate('QUEUE_COUNT') || '"');

    htp.tableData(htf.anchor2(curl=>wfa_html.base_url||
                                  '/wf_queue.Generic_Queue_View_Detail?p_protocol='||
                                  queues.protocol||'&p_inbound_outbound='||
                                  queues.inbound_outbound,
                              ctext=>'<IMG SRC="'||wfa_html.image_loc||'affind.gif" alt="'||wf_core.translate('FIND') || '"BORDER=0>'),
                              'center', cattributes=>'valign="MIDDLE"
           headers="' || wf_core.translate('VIEW_DETAIL') || '"');

    htp.tableData(htf.anchor2(curl=>wfa_html.base_url||
                                  '/wf_queue.generic_queue_confirm_delete?p_protocol='||
                                  queues.protocol||'&p_inbound_outbound='||
                                   queues.inbound_outbound,
                              ctext=>'<IMG SRC="'||wfa_html.image_loc||'FNDIDELR.gif" alt="' || wf_core.translate('WFRTG_DELETE') || '" BORDER=0>'),
                              'center', cattributes=>'valign="MIDDLE"
                     headers="' || wf_core.translate('DELETE') || '"');


  end loop;

  htp.tableclose;

  htp.br;

  htp.tableopen(calign=>'CENTER',cattributes=>'summary=""');

  --Add new node Button
  htp.tableRowOpen;

  l_url         := wfa_html.base_url||'/wf_queue.generic_queue_edit';
  l_icon        := 'FNDJLFOK.gif';
  l_text        := wf_core.translate ('WFQUEUE_CREATE');
  l_onmouseover := wf_core.translate ('WFQUEUE_CREATE');

  htp.p('<TD ID="">');

  wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

  htp.p('</TD>');

  htp.tableRowClose;

  htp.tableclose;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when others then
    wf_core.context('FND_DOCUMENT_MANAGEMENT', 'Generic_Queue_Display');
    raise;
end Generic_Queue_Display;

--
-- Generic_Queue_View_Detail
--   Produce list of generic_queues
--
-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 - added alt attrib for IMG tag for ADA
--             - Added summary attribute for table tags for ADA
--
procedure Generic_Queue_View_Detail (
p_protocol         IN VARCHAR2 DEFAULT NULL,
p_inbound_outbound IN VARCHAR2 DEFAULT NULL
) IS
  l_count   number := 0;
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
  admin_mode varchar2(1) := 'N';
  realname varchar2(360);   -- Display name of username
  s0 varchar2(2000);       -- Dummy
  l_error_msg varchar2(240);
  l_url                varchar2(240);
  l_media              varchar2(240) := wfa_html.image_loc;
  l_icon               varchar2(40);
  l_text               varchar2(240);
  l_onmouseover        varchar2(240);
  l_sql                varchar2(1000);

begin

  -- Check current user has admin authority
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_directory.GetRoleInfo(username, realname, s0, s0, s0, s0);

  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
     Wf_Directory.IsPerformer(username, admin_role)) then
         admin_mode := 'Y';
  else

     l_error_msg := wf_core.translate('WFPREF_INVALID_ADMIN');

  end if;

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.p('<BASE TARGET="_top">');
  htp.title(wf_core.translate('WFGENERIC_QUEUE_TITLE'));
  wfa_html.create_help_function('wf/links/dmr.htm?DMREP');
  htp.headClose;
  wfa_sec.Header(FALSE, '',wf_core.translate('WFGENERIC_QUEUE_TITLE'), FALSE);
  htp.br;

  IF (admin_mode = 'N') THEN

     htp.center(htf.bold(l_error_msg));
     return;

  END IF;

  SELECT queue_count
  INTO   l_count
  FROM   wf_queues
  WHERE  UPPER(p_protocol) = protocol
  AND    p_inbound_outbound = inbound_outbound;

  -- Column headers
  htp.tableOpen(cattributes=>'border=1 cellpadding=3 bgcolor=white width="100%" summary=""');
  htp.tableRowOpen(cattributes=>'bgcolor=#006699');

  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('PROTOCOL')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                     wf_core.translate('PROTOCOL') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('QUEUE_NUMBER')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                     wf_core.translate('QUEUE_NUMBER') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('QUEUE_NAME')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                     wf_core.translate('QUEUE_NAME') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('QUEUE_COUNT')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                     wf_core.translate('QUEUE_COUNT') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('VIEW_DETAIL')||'</font>',
                  calign=>'Center',
                  cattributes=>'id="' ||
                     wf_core.translate('VIEW_DETAIL') || '"');

  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableRowClose;

  -- Show all queues for the given protocol
  for ii in 1..l_count loop

    htp.tableRowOpen(null, 'TOP');

    htp.tableData(p_protocol, 'left', cattributes=>'headers="' ||
           wf_core.translate('PROTOCOL') || '"');

    htp.tableData(to_char(ii), 'left', cattributes=>'headers="' ||
           wf_core.translate('QUEUE_NUMBER') || '"');

    -- p_protocol and p_inbound_outbound were verified above
    -- ii must be a number
    -- BINDVAR_SCAN_IGNORE
    htp.tableData(wf_core.translate('WF_SCHEMA')||'.'||'WF_'||p_protocol||'_'||substr(p_inbound_outbound, 1, 1)||'_'||to_char(ii)||'_QUEUE', 'left', cattributes=>'headers="' || wf_core.translate('QUEUE_NAME') || '"');

    /*
    ** Check to see if there are any messages in the specified queue
    */
    l_sql := 'SELECT COUNT(1) FROM WF_'||p_protocol||'_'||substr(p_inbound_outbound, 1, 1)||'_'||to_char(ii)||'_TABLE';

    execute immediate l_sql INTO l_count;

    htp.tableData(to_char(l_count), 'left', cattributes=>'headers="' ||
        wf_core.translate('QUEUE_COUNT') || '"');

    htp.tableData(htf.anchor2(curl=>wfa_html.base_url||
                                  '/wf_queue.generic_queue_display_contents?p_protocol='||
                                  p_protocol||'&p_inbound_outbound='||
                                  p_inbound_outbound||'&p_queue_number='||
                                  to_char(ii)||'&p_message_number=1',
                              ctext=>'<IMG SRC="'||wfa_html.image_loc||'affind.gif"  alt="' || wf_core.translate('FIND') || '" BORDER=0>'),
                              'center', cattributes=>'valign="MIDDLE" headers="' || wf_core.translate('VIEW_DETAIL') || '"');


  end loop;

  htp.tableclose;

  htp.br;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when others then
    wf_core.context('FND_DOCUMENT_MANAGEMENT', 'Generic_Queue_View_Detail');
    raise;
end Generic_Queue_View_Detail;


-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 - Added summary attr for table tag for ADA
--             - Added ID attr for TD tags for ADA
procedure generic_queue_display_contents
(p_protocol          IN VARCHAR2 DEFAULT NULL,
 p_inbound_outbound  IN VARCHAR2 DEFAULT NULL,
 p_queue_number      IN NUMBER   DEFAULT NULL,
 p_message_number    IN NUMBER   DEFAULT 1) IS

  username                 varchar2(320);   -- Username to query
  admin_role               varchar2(320); -- Role for admin mode
  admin_mode               varchar2(1) := 'N';
  l_media                  varchar2(240) := wfa_html.image_loc;
  l_icon                   varchar2(40) := 'FNDILOV.gif';
  l_text                   varchar2(240) := '';
  l_onmouseover            varchar2(240) := wf_core.translate ('WFPREF_LOV');
  l_url                    varchar2(4000);
  l_error_msg              varchar2(240);

  l_more_data              BOOLEAN := TRUE;
  l_message                      system.wf_message_payload_t;
  dequeue_options                dbms_aq.dequeue_options_t;
  message_properties       dbms_aq.message_properties_t;
  ii                       number := 0;
  l_loc                    number := 1;
  l_message_contents       VARCHAR2(32000);
  l_message_offset         binary_integer := 16000;
  l_queue_name             varchar2(30);
  l_msg_id                 RAW(16);

begin

  -- Check current user has admin authority
  wfa_sec.GetSession(username);
  username := upper(username);

  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
     Wf_Directory.IsPerformer(username, admin_role)) then
         admin_mode := 'Y';
  else

     l_error_msg := wf_core.translate('WFPREF_INVALID_ADMIN');

  end if;

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.title(wf_core.translate('WFQUEUE_EDIT_QUEUE_TITLE'));
  wfa_html.create_help_function('wf/links/dmr.htm?DMREP');

  wf_lov.OpenLovWinHtml;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE, '', wf_core.translate('WFQUEUE_EDIT_QUEUE_TITLE'), TRUE);

  IF (admin_mode = 'N') THEN

     htp.center(htf.bold(l_error_msg));
     return;

  END IF;

  htp.tableopen(calign=>'CENTER',cattributes=>'summary=""');

  htp.p('<FORM NAME="FND_QUEUE_CONTENTS" ACTION="wf_queue.generic_queue_update" METHOD="POST">');

  /*
  ** Create a page with a form field with the message payload
  */
  dequeue_options.dequeue_mode := dbms_aq.BROWSE;
  dequeue_options.wait := dbms_aq.NO_WAIT;
  dequeue_options.navigation   := dbms_aq.FIRST_MESSAGE;

  l_queue_name := wf_core.translate('WF_SCHEMA')||'.'||'WF_'||p_protocol||'_'||substr(p_inbound_outbound, 1, 1)||'_'||
                  to_char(p_queue_number)||'_QUEUE';

  dbms_aq.dequeue
  (queue_name => l_queue_name,
   dequeue_options => dequeue_options,
   message_properties => message_properties,
   payload => l_message,
   msgid => l_msg_id
   );

  dequeue_options.navigation   := dbms_aq.NEXT_MESSAGE;

  -- Loop until you reach the requested message
  for ii in 2..p_message_number loop

     htp.p (to_char(ii));

     dbms_aq.dequeue
     (queue_name => l_queue_name,
      dequeue_options => dequeue_options,
      message_properties => message_properties,
      payload => l_message,
      msgid => l_msg_id
      );

   end loop;

   -- Display the contents
   htp.tableRowOpen;

   htp.p ('<TD ID="" ALIGN="Left">');

   htp.p ('<TEXTAREA NAME="message_content" ROWS=26 COLS=120 WRAP="SOFT">');

   while (l_more_data = TRUE) loop

      BEGIN

          dbms_lob.read(l_message.message, l_message_offset, l_loc, l_message_contents);

          htp.p(l_message_contents);

          l_loc := l_loc + l_message_offset;

          if (l_message_offset < 16000) then

             l_more_data := FALSE;

          end if;

      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_more_data := FALSE;
          WHEN OTHERS THEN
            RAISE;
      END;

   END LOOP;

   htp.p ('</TEXTAREA>');

   htp.p ('</TD>');

  htp.tableRowClose;

  htp.tableclose;

  htp.formClose;

  htp.br;

  htp.tableopen(calign=>'CENTER',cattributes=>'summary=""');

  --Next Button

  htp.tableRowOpen;

  l_url         := wfa_html.base_url||
                   '/wf_queue.generic_queue_display_contents'||
                                  '?p_protocol='||p_protocol||
                                  '&p_inbound_outbound='||p_inbound_outbound||
                                  '&p_queue_number='||to_char(p_queue_number)||
                                  '&p_message_number='||to_char(p_message_number + 1);

  l_icon        := 'FNDJLFOK.gif';
  l_text        := wf_core.translate ('NEXT');
  l_onmouseover := wf_core.translate ('NEXT');

  htp.p('<TD ID="">');

  wfa_html.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

  htp.p('</TD>');

  if (p_message_number > 1) then

     l_url         := wfa_html.base_url||
                      '/wf_queue.generic_queue_display_contents'||
                                     '?p_protocol='||p_protocol||
                                     '&p_inbound_outbound='||p_inbound_outbound||
                                     '&p_queue_number='||to_char(p_queue_number)||
                                     '&p_message_number='||to_char(p_message_number - 1);

     l_icon        := 'FNDJLFCN.gif';
     l_text        := wf_core.translate ('PREVIOUS');
     l_onmouseover := wf_core.translate ('PREVIOUS');

     htp.p('<TD ID="">');

     wfa_html.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

     htp.p('</TD>');

  end if;

  htp.tableRowClose;

  htp.tableclose;

  wfa_sec.Footer;

  htp.htmlClose;

exception
  when others then
    Wf_Core.Context('Wf_Queue', 'generic_queue_display_contents',
                    p_protocol, p_inbound_outbound);
    raise;

end generic_queue_display_contents;



-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 - Added summary attr for table tag for ADA
--             - Added ID attr for TD tags
procedure Generic_Queue_Edit (
p_protocol         IN VARCHAR2 DEFAULT NULL,
p_inbound_outbound IN VARCHAR2 DEFAULT NULL
) IS

username varchar2(320);   -- Username to query
admin_role varchar2(320); -- Role for admin mode
admin_mode varchar2(1) := 'N';
l_inbound_selected   varchar2(1) := 'N';
l_outbound_selected  varchar2(1) := 'N';
l_description        VARCHAR2(240);
l_queue_count        NUMBER;
l_media              varchar2(240) := wfa_html.image_loc;
l_icon               varchar2(40) := 'FNDILOV.gif';
l_text               varchar2(240) := '';
l_onmouseover        varchar2(240) := wf_core.translate ('WFPREF_LOV');
l_url                varchar2(4000);
l_error_msg          varchar2(240);

BEGIN

  -- Check current user has admin authority
  wfa_sec.GetSession(username);
  username := upper(username);

  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
     Wf_Directory.IsPerformer(username, admin_role)) then
         admin_mode := 'Y';
  else

     l_error_msg := wf_core.translate('WFPREF_INVALID_ADMIN');

  end if;

  /*
  ** If this protocol already exists then go fetch the definition
  */
  IF (p_protocol IS NOT NULL) THEN

      SELECT description,
             queue_count
      INTO   l_description,
             l_queue_count
      FROM   wf_queues
      WHERE  protocol = p_protocol
      AND    inbound_outbound = p_inbound_outbound;

  END IF;

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.title(wf_core.translate('WFQUEUE_EDIT_QUEUE_TITLE'));
  wfa_html.create_help_function('wf/links/dmr.htm?DMREP');

  wf_lov.OpenLovWinHtml;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE, '', wf_core.translate('WFQUEUE_EDIT_QUEUE_TITLE'), TRUE);

  IF (admin_mode = 'N') THEN

     htp.center(htf.bold(l_error_msg));
     return;

  END IF;

  htp.tableopen(calign=>'CENTER',cattributes=>'summary="' || wf_core.translate('WFQUEUE_EDIT_QUEUE_TITLE') || '"');

  htp.p('<FORM NAME="FND_GENERIC_QUEUE" ACTION="wf_queue.generic_queue_update" METHOD="POST">');

  -- Protocol Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_protocol">' ||
                wf_core.translate('PROTOCOL') || '</LABEL>',
                calign=>'right',
                cattributes=>'id=""');

  htp.tableData(htf.formText(cname=>'p_protocol', csize=>'30',
                             cvalue=>p_protocol, cmaxlength=>'30',
                             cattributes=>'id="i_protocol"'),
                             cattributes=>'id=""');

  htp.tableRowClose;

  -- Inbound/outbound
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_inbound_outbound">' ||
                wf_core.translate('INBOUND_OUTBOUND') || '</LABEL>',
                calign=>'right',
                cattributes=>'id=""');

  if (NVL(p_inbound_outbound, 'OUTBOUND') = 'INBOUND') then

      l_inbound_selected  := 'Y';
      l_outbound_selected := NULL;

  else

      l_inbound_selected  := NULL;
      l_outbound_selected := 'Y';

  end if;

  htp.p('<TD ID="">');

  htp.formSelectOpen(cname=>'p_inbound_outbound',cattributes=>'id="i_inbound_outbound"');

  htp.formSelectOption(cvalue=>wf_core.translate('INBOUND'),
                       cattributes=>'value=INBOUND',
                       cselected=>l_inbound_selected);

  htp.formSelectOption(cvalue=>wf_core.translate('OUTBOUND'),
                       cattributes=>'value=OUTBOUND',
                       cselected=>l_outbound_selected);

  htp.formSelectClose;
  htp.p('</TD>');

  htp.tableRowClose;

  -- Description
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_description">' ||
                 wf_core.translate('DESCRIPTION') || '"',
                calign=>'right',
                cattributes=>'id=""');

  htp.tableData(htf.formText(cname=>'p_description', csize=>'30',
                             cvalue=>l_description, cmaxlength=>'240',
                             cattributes=>'id="i_description"'),
                             cattributes=>'id=""');

  htp.tableRowClose;

  -- Count
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_count">' ||
                wf_core.translate('COUNT') || '"',
                calign=>'right',
                cattributes=>'id=""');

  htp.tableData(htf.formText(cname=>'p_queue_count', csize=>'10',
                             cvalue=>l_queue_count, cmaxlength=>'20',
                             cattributes=>'id="i_count"'),
                    cattributes=>'id=""');

  htp.tableRowClose;

  -- keep track of the original protocol and the inbound/outbound
  -- value in case the name changes

  htp.formHidden(cname=>'p_original_protocol', cvalue=>p_protocol);
  htp.formHidden(cname=>'p_original_inbound', cvalue=>p_inbound_outbound);

  htp.tableclose;

  htp.br;

  htp.tableopen(calign=>'CENTER',cattributes=>'summary=""');

  --Submit Button

  htp.tableRowOpen;

  l_url         := 'javascript:document.FND_GENERIC_QUEUE.submit()';
  l_icon        := 'FNDJLFOK.gif';
  l_text        := wf_core.translate ('WFMON_OK');
  l_onmouseover := wf_core.translate ('WFMON_OK');

  htp.p('<TD ID="">');

  wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

  htp.p('</TD>');

  l_url         := wfa_html.base_url||'/fnd_document_management.Generic_Queue_Display';
  l_icon        := 'FNDJLFCN.gif';
  l_text        := wf_core.translate ('CANCEL');
  l_onmouseover := wf_core.translate ('CANCEL');

  htp.p('<TD ID="">');

  wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

  htp.p('</TD>');

  htp.tableRowClose;

  htp.tableclose;

  htp.formClose;

  wfa_sec.Footer;
  htp.htmlClose;


exception
  when others then
    wf_core.context('FND_DOCUMENT_MANAGEMENT', 'Generic_Queue_edit');
    raise;

END Generic_Queue_Edit;

procedure generic_queue_delete_check
(p_protocol          in varchar2,
 p_inbound_outbound  in varchar2,
 p_queue_start_range in number,
 p_queue_end_range   in number) IS

ii      NUMBER := 0;
l_count NUMBER := 0;
l_sql   varchar2(1000);

BEGIN

  /*
  ** Check to make sure there are no messages in the queue before
  ** you delete it.
  */
  for ii in p_queue_start_range..p_queue_end_range loop

     /*
     ** Check to see if there are any messages in the specified queue
     */
     -- p_protocol and p_inbound was verified before coming here.
     -- BINDVAR_SCAN_IGNORE
     l_sql := 'SELECT COUNT(1) INTO :a FROM WF_'||p_protocol||'_'||substr(p_inbound_outbound, 1, 1)||'_'||to_char(ii)||'_TABLE';

     execute immediate l_sql using l_count;

     /*
     ** If you find a row then error this call
     */
     if (l_count > 0) then

        wf_core.token('PROTOCOL', p_protocol);
        wf_core.token('INBOUND_OUTBOUD', p_inbound_outbound);
        wf_core.token('QUEUE_NUMBER', to_char(ii));
        wf_core.raise('WFQUEUE_QUEUE_CONTENT');

     end if;

  end loop;

exception
  when others then
    Wf_Core.Context('Wf_Queue', 'generic_queue_delete_check',
                    p_protocol, p_inbound_outbound);
    raise;

end generic_queue_delete_check;

procedure generic_queue_delete_queues
(p_protocol          in varchar2,
 p_inbound_outbound  in varchar2,
 p_queue_start_range in number,
 p_queue_end_range   in number) IS

ii      NUMBER := 0;
l_count NUMBER := 0;

BEGIN

  /*
  ** Delete the queues and queue tables
  */
  for ii in p_queue_start_range..p_queue_end_range loop

     /*
     ** Stop the queue
     */
     dbms_aqadm.stop_queue(queue_name => wf_core.translate('WF_SCHEMA')||'.'||'WF_'||
                           p_protocol||'_'||substr(p_inbound_outbound, 1, 1)||'_'||
                           to_char(ii)||'_QUEUE');
     /*
     ** Delete the Queues
     */
     dbms_aqadm.drop_queue(
       queue_name => wf_core.translate('WF_SCHEMA')||'.'||'WF_'||p_protocol||'_'||
                     substr(p_inbound_outbound, 1, 1)||'_'||to_char(ii)||'_QUEUE');

     /*
     ** Delete the Queue Table
     */
     dbms_aqadm.drop_queue_table (
       queue_table        => wf_core.translate('WF_SCHEMA')||'.'||'WF_'||p_protocol||'_'||substr(p_inbound_outbound, 1, 1)||'_'||to_char(ii)||'_TABLE');

  end loop;

exception
  when others then
    Wf_Core.Context('Wf_Queue', 'generic_queue_delete_queues',
                    p_protocol, p_inbound_outbound);
    raise;

end generic_queue_delete_queues;



-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 - Added summary attr for table tag for ADA
--             - Added ID attr for TD tags
procedure Generic_Queue_Update (
p_protocol           IN VARCHAR2   DEFAULT NULL,
p_inbound_outbound   IN VARCHAR2   DEFAULT NULL,
p_description        IN VARCHAR2   DEFAULT NULL,
p_queue_count        IN VARCHAR2   DEFAULT NULL,
p_original_protocol  IN VARCHAR2   DEFAULT NULL,
p_original_inbound   IN VARCHAR2   DEFAULT NULL
) IS

username varchar2(320);   -- Username to query
admin_role varchar2(320); -- Role for admin mode
admin_mode varchar2(1) := 'N';
l_count              number := 0;
l_media              varchar2(240) := wfa_html.image_loc;
l_icon               varchar2(30) := 'FNDILOV.gif';
l_text               varchar2(240) := '';
l_onmouseover        varchar2(240) := wf_core.translate ('WFPREF_LOV');
l_url                varchar2(4000);
l_error_msg          varchar2(240);

BEGIN

  -- Check current user has admin authority
  wfa_sec.GetSession(username);
  username := upper(username);

  admin_role := wf_core.translate('WF_ADMIN_ROLE');

  if (admin_role = '*' or
     Wf_Directory.IsPerformer(username, admin_role)) then
         admin_mode := 'Y';
  else

     l_error_msg := wf_core.translate('WFPREF_INVALID_ADMIN');

  end if;

  IF (admin_mode = 'N') THEN

     htp.center(htf.bold(l_error_msg));
     return;

  END IF;

  -- Check to make sure the protocol does not already exist
  IF (p_original_protocol IS NULL) THEN

      SELECT count(1)
      INTO   l_count
      FROM   wf_queues
      WHERE  UPPER(p_protocol) = protocol
      AND    p_inbound_outbound = inbound_outbound;

      if (l_count > 0) then

         htp.p('<BODY bgcolor=#cccccc>');
         htp.center(htf.bold(wf_core.translate('WFQUEUE_ALREADY_EXISTS')));
         htp.br;

         htp.tableopen(calign=>'CENTER',cattributes=>'summary=""');

         --Submit Button

         htp.tableRowOpen;

         l_url         := wfa_html.base_url||
               '/wf_queue.generic_queue_edit';
         l_icon        := 'FNDJLFOK.gif';
         l_text        := wf_core.translate ('WFMON_OK');
         l_onmouseover := wf_core.translate ('WFMON_OK');

         htp.p('<TD ID="">');

         wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

         htp.p('</TD>');
         htp.tablerowclose;
         htp.tableclose;
         htp.p('</BODY>');
         return;

      else

          wf_queue.create_generic_queue (p_protocol=>p_protocol,
                                         p_inbound_outbound => p_inbound_outbound,
                                         p_description => p_description,
                                         p_queue_count => to_number(p_queue_count));

      end if;

   else
          null;

/*
          wf_queue.update_generic_queue (p_protocol=>p_protocol,
                                         p_inbound_outbound => p_inbound_outbound,
                                         p_description => p_description,
                                         p_queue_count => to_number(p_queue_count),
                                         p_original_protocol=> p_original_protocol,
                                         p_original_inbound=> p_original_inbound);

*/
   end if;


   -- use owa_util.redirect_url to redirect the URL to the home page
   owa_util.redirect_url(curl=>wfa_html.base_url ||
                            '/wf_queue.Generic_Queue_Display',
                            bclose_header=>TRUE);


exception
  when others then
    wf_core.context('FND_DOCUMENT_MANAGEMENT', 'Generic_Queue_update');
    raise;

END Generic_Queue_Update;


/*
** Create a generic queue with the object type of WF_MESSAGE_PAYLOAD_T which
** is basically just a clob
*/
procedure create_generic_queue
(p_protocol          IN VARCHAR2,
 p_inbound_outbound  IN VARCHAR2,
 p_description       IN VARCHAR2,
 p_queue_count       IN NUMBER) IS

l_count NUMBER := 0;

begin

  /*
  ** Check to see if the queue name already exists
  */
  select count(1)
  into   l_count
  from   wf_queues wfq
  where  wfq.protocol = p_protocol
  and    wfq.inbound_outbound = p_inbound_outbound;

  /*
  ** If you find a row then error this call
  */
  if (l_count > 0) then

     wf_core.token('PROTOCOL', p_protocol);
     wf_core.raise('WFQUEUE_UNIQUE_NAME');

  end if;

  for ii in 1..p_queue_count loop

     /*
     ** Create New Queue Table
     */
     dbms_aqadm.create_queue_table (
       queue_table        => wf_core.translate('WF_SCHEMA')||'.'||'WF_'||p_protocol||'_'||substr(p_inbound_outbound, 1, 1)||'_'||to_char(ii)||'_TABLE',
       queue_payload_type => 'SYSTEM.WF_MESSAGE_PAYLOAD_T',
       storage_clause     => 'storage (initial 1m next 1m pctincrease 0 )',
       sort_list                => 'PRIORITY,ENQ_TIME',
       comment          => wf_core.translate('WORKFLOW_USER_QUEUE_TABLE')||' - '||
                             wf_core.translate('WF_SCHEMA')||'.'||'WF_'||p_protocol||'_'||substr(p_inbound_outbound, 1, 1)||'_'||to_char(ii)||'_TABLE');

     /*
     ** Create New Queues
     */
     dbms_aqadm.create_queue(
       queue_name => wf_core.translate('WF_SCHEMA')||'.'||'WF_'||p_protocol||'_'||
                     substr(p_inbound_outbound, 1, 1)||'_'||to_char(ii)||'_QUEUE',
       queue_table => wf_core.translate('WF_SCHEMA')||'.'||'WF_'||p_protocol||'_'||
                     substr(p_inbound_outbound, 1, 1)||'_'||to_char(ii)||'_TABLE',
       max_retries => 0,
       comment => wf_core.translate('WORKFLOW_USER_QUEUE')||' - '||
                  wf_core.translate('WF_SCHEMA')||'.'||'WF_'||p_protocol||'_'||
                  substr(p_inbound_outbound, 1, 1)||'_'||to_char(ii)||'_QUEUE');

     /*
     ** Start the queue
     */
     dbms_aqadm.start_queue(queue_name => wf_core.translate('WF_SCHEMA')||'.'||
                   'WF_'||p_protocol||'_'||
                   substr(p_inbound_outbound, 1, 1)|| '_'||to_char(ii)||'_QUEUE');

  end loop;

  /*
  ** Create an entry in WF_QUEUES table
  */
  insert into wf_queues
   (protocol,
    inbound_outbound,
    description,
    queue_count,
    disable_flag)
  values
   (p_protocol,
    p_inbound_outbound,
    p_description,
    p_queue_count,
    'N');

exception
  when others then
    Wf_Core.Context('Wf_Queue', 'create_generic_queue', p_protocol,
                    p_inbound_outbound);
    raise;

end create_generic_queue;

/*
** delete a generic queue with the object type of WF_MESSAGE_PAYLOAD_T which
** is basically just a clob
*/
procedure delete_generic_queue
(p_protocol          IN VARCHAR2,
 p_inbound_outbound  IN VARCHAR2) IS

l_queue_count NUMBER := 0;

begin

  /*
  ** Check to see if the queue name already exists
  */
  begin

  select queue_count
  into   l_queue_count
  from   wf_queues wfq
  where  wfq.protocol = p_protocol
  and    wfq.inbound_outbound = p_inbound_outbound;

  exception
    when no_data_found then
        wf_core.token('PROTOCOL', p_protocol);
        wf_core.raise('WFQUEUE_NOEXIST');
    when others then
        raise;

  end;

  /*
  ** Make sure the queues are empty
  */
  wf_queue.generic_queue_delete_check (p_protocol, p_inbound_outbound,
      1, l_queue_count);

  /*
  ** Delete the queues and queue tables
  */
  wf_queue.generic_queue_delete_queues(p_protocol, p_inbound_outbound,
      1, l_queue_count);

  /*
  ** delete an entry in WF_QUEUES table
  */
  delete from wf_queues
  where protocol = p_protocol
  and   inbound_outbound = p_inbound_outbound;

exception
  when others then
    Wf_Core.Context('Wf_Queue', 'delele_generic_queue', p_protocol,
                    p_inbound_outbound);
    raise;

end delete_generic_queue;

/*
** Procedure:  get_hash_queue_name
**
** Description: Load all queue definitions into memory.  The use a hashing algorithm
**              to return a queue name
*/
procedure get_hash_queue_name
(p_protocol          in varchar2,
 p_inbound_outbound  in varchar2,
 p_queue_name        out NOCOPY varchar2) IS

qii            number := 1;
ii             number := 1;
l_index        number := 0;
l_queue_name   varchar2(30) := null;

cursor get_queues is
select protocol, inbound_outbound, queue_count
from   wf_queues
order by protocol, inbound_outbound;

begin

  /*
  ** Check to see if queues loaded into memory. If they are not
  ** already loaded
  */
  if (wf_queue.queue_names_index.count < 1) then

     -- Show all nodes
     for wf_queues_list in get_queues loop

         wf_queue.queue_names_index(ii).protocol   := wf_queues_list.protocol;
         wf_queue.queue_names_index(ii).inbound_outbound := wf_queues_list.inbound_outbound;
         wf_queue.queue_names_index(ii).queue_count := wf_queues_list.queue_count;

         ii := ii + 1;

     end loop;

  end if;

  -- Go find the locator in the queue list that matches the request
  for ii in 1..wf_queue.queue_names_index.count loop

     if (wf_queue.queue_names_index(ii).protocol = p_protocol AND
         wf_queue.queue_names_index(ii).inbound_outbound = p_inbound_outbound) THEN

         -- If there is more than 1 queue then choose the queue based on a random
         -- number generator
         if (wf_queue.queue_names_index(ii).queue_count > 1) then

            l_index := mod(to_number(wf_core.random), wf_queue.queue_names_index(ii).queue_count) + 1;

         else

            l_index := 1;

         end if;

     end if;

  end loop;

  if (l_index > 0) then

     p_queue_name := wf_core.translate('WF_SCHEMA')||'.'||'WF_'||p_protocol||'_'|| SUBSTR(p_inbound_outbound, 1, 1)||
                      '_'||to_char(l_index)||'_QUEUE';

  end if;

exception
  when others then
    Wf_Core.Context('Wf_Queue', 'get_hash_generic_queue',
                    p_protocol, p_inbound_outbound);
    raise;

end get_hash_queue_name;

--
-- Function: enable_exception_queue
--
-- Enable the exception queue for the queue table for dequing
-- Returns the name of the exception queue for the given queue name
--
function enable_Exception_Queue(p_queue_name in varchar2) return varchar2
is
   l_schema_name varchar(320);
   l_queue_name varchar2(30);
   l_pos integer := 0;
   l_queue_table varchar2(30);
   l_dequeue_enabled varchar2(7) := '';
   l_exception_queue varchar2(100) := '';

begin
   -- Check to see if the name has a schema. Rove it for the check.
   l_pos := instrb(p_queue_name,'.');
   if l_pos > 0 then
      l_schema_name := substrb(p_queue_name, 1, l_pos-1);
      l_queue_name := substrb(p_queue_name, l_pos+1);
   else
      l_schema_name := wf_core.translate('WF_SCHEMA');
      l_queue_name := p_queue_name;
   end if;
   begin
      select queue_table, dequeue_enabled
      into l_queue_table, l_dequeue_enabled
      from all_queues
      where owner = l_schema_name
        and name = l_queue_name;
      l_exception_queue := l_schema_name||'.'||'AQ$_'||
                           l_queue_table||'_E';
   exception
      when no_data_found then
         l_exception_queue := '';
         l_dequeue_enabled := '';
      when others then
         raise;
   end;

   if l_exception_queue <> '' and l_dequeue_enabled = 'NO' then
      dbms_aqadm.start_queue(queue_name => l_exception_queue,
                              enqueue => FALSE,
                              dequeue => TRUE);
   end if;
   return l_exception_queue;

exception
   when others then
      WF_CORE.Context('WF_QUEUE','Enable_Exception_Queue',p_queue_name);
      raise;

end enable_Exception_Queue;

-- ====================================================================
-- Add Subscriber to Queue (PUBLIC)
-- ====================================================================
procedure AddSubscriber(queuename in varchar2,
                        name      in varchar2)
as
  lagent  sys.aq$_agent;
begin
  lagent := sys.aq$_agent(name,'',0);

  DBMS_AQADM.Add_Subscriber(
    queue_name=>queuename,
    subscriber=>lagent,
    rule=>'CORRID like '''||name||'%'''
  );

exception
  when OTHERS then
      Wf_Core.Context('WF_QUEUE','AddSubscriber',queuename, name);
      raise;
end AddSubscriber;

-- Bug 2307428
-- ====================================================================
-- Enable Inbound and defrerred queues for Background Engine.
-- ====================================================================
procedure EnableBackgroundQueues as
schema      varchar2(320);
queue_name  varchar2(80);
l_qname     varchar2(80);
CURSOR    q_disabled (schema varchar2, queue_name varchar2) is
  SELECT  name
  FROM    all_queues
  WHERE   name  = queue_name
  AND     owner = schema
  AND   ((trim(enqueue_enabled) = 'NO') OR (trim(dequeue_enabled) = 'NO'));

begin
  --If the queue names haven't been set,initialise them
  if (wf_queue.name_init = FALSE) then
     wf_queue.set_queue_names;
  end if;

  --Obtain the schema
  schema     := wf_core.translate('WF_SCHEMA');

  --Enable deferred queue
  queue_name := substr(wf_queue.deferred_queue_name,length(schema)+2);
  OPEN q_disabled (schema, queue_name);
  LOOP
    FETCH q_disabled into l_qname;
    EXIT WHEN q_disabled%NOTFOUND;
    DBMS_AQADM.START_QUEUE(wf_queue.deferred_queue_name);
  END LOOP;
  CLOSE q_disabled;

  --Enable inbound queue
  queue_name := substr(wf_queue.inbound_queue_name,length(schema)+2);
  OPEN q_disabled (schema, queue_name);
  LOOP
    FETCH q_disabled into l_qname;
    EXIT WHEN q_disabled%NOTFOUND;
    DBMS_AQADM.START_QUEUE(wf_queue.inbound_queue_name);
  END LOOP;
  CLOSE q_disabled;
exception
  when others then
     Wf_core.Context('WF_QUEUE','EnableBackgroundQueues');
     raise;
end EnableBackgroundQueues;
-- ====================================================================
-- get Count Message States (PUBLIC)
-- ====================================================================
procedure getCntMsgSt
(p_agent        IN VARCHAR2 DEFAULT '%',
 p_ready        OUT NOCOPY NUMBER,
 p_wait         OUT NOCOPY NUMBER,
 p_processed    OUT NOCOPY NUMBER,
 p_expired      OUT NOCOPY NUMBER,
 p_undeliverable OUT NOCOPY NUMBER,
 p_error        OUT NOCOPY NUMBER)
is

TYPE cntmsgst_t IS REF CURSOR;
l_cntmsgst       cntmsgst_t;
l_sqlstmt	 varchar2(4000);
l_count          number := 0;
l_msgstate       varchar2(50);
l_pos		 number := 0;
l_qt	         varchar2(100);
l_owner		 varchar2(100);

-- <rraheja:2786474> Gather schema and queue name once rather than in every call for perf.
l_schema	 varchar2(100);
l_qname		 varchar2(100);


-- <rraheja:2786474> Changed upper(name) to name as queue_name should be recorded in upper case.
cursor c_localagents(p_agent varchar2) is
select queue_name
from wf_agents
where system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'))
and name like upper(p_agent);

/*
cursor c_qt is
select owner
from all_queue_tables
where queue_table = l_qt;
*/

-- <rraheja:2786474> Changed non-cursor single row query to cursor based for improved perf.
cursor c_qtable is
  select queue_table
  from all_queues
  where owner = l_schema
  and name = l_qname;
  --and queue_type = 'NORMAL_QUEUE';

TABLE_NOTFOUND exception;
pragma EXCEPTION_INIT(TABLE_NOTFOUND,-942);

INVALID_TABLE exception;
pragma EXCEPTION_INIT(INVALID_TABLE,-903);

begin

-- Initialize Out Parameters
p_ready := 0;
p_wait := 0;
p_processed := 0;
p_expired := 0;
p_undeliverable := 0;
p_error := 0;

for i in c_localagents(p_agent) loop

  -- Get the Queue Table plus owner
  l_pos := nvl(instr(i.queue_name,'.',1,1),0);

  -- <rraheja:2786474> Changed non-cursor single row query to cursor and used vars for freq used data
  l_schema := substr(i.queue_name,1,l_pos-1);
  l_qname := substr(i.queue_name,l_pos+1);
  open c_qtable;
  fetch c_qtable into l_qt;
  close c_qtable;


  -- Get the Owner of the Queue Table
  -- <rraheja:2786474> queue owner should be = queue table owner, so commenting out the code
  /*
  open c_qt;
  fetch c_qt into l_owner;
  exit when c_qt%notfound;
  close c_qt;
  */
  l_owner := l_schema;

    -- l_owner and l_qt are selected/derived from our own cursor
    -- BINDVAR_SCAN_IGNORE[2]
    l_sqlstmt := 'select msg_state, count(*) from '||l_owner||'.'||'aq$'||l_qt
		||' where (queue = :q or queue = :r) group by msg_state';
    begin
      --If the queue tables are not found then the
      --select should throw ORA 942.
      --Put the begin catch block of exception at the end
      --so that u don't have to use goto's to get out of loop
      open l_cntmsgst for l_sqlstmt using l_qname,'AQ$_'|| l_qname ||'_E';
      loop
        fetch l_cntmsgst into l_msgstate, l_count;
        if l_msgstate = 'READY'then
          --Bug 2382594
          --If the agent is WF_ERROR do not count p_error.
          if l_qname = 'WF_ERROR' and p_agent = '%' then
            p_error := p_error + l_count;
          else
            p_ready := p_ready + l_count;
          end if;
        elsif l_msgstate = 'WAIT' then
          p_wait := p_wait + l_count;
        elsif l_msgstate = 'PROCESSED' then
          p_processed := p_processed + l_count;
        elsif l_msgstate = 'EXPIRED' then
          p_expired := p_expired + l_count;
        elsif l_msgstate = 'UNDELIVERABLE' then
          p_undeliverable := p_undeliverable + l_count;
        end if;
        l_count := 0;

        exit when l_cntmsgst%notfound;
      end loop;

      close l_cntmsgst;
    exception
      when table_notfound then
       --return 0 count instead of throwing error to UI
       --all the returns are at their initialized value of 0
       --just ensure that the cursor is closed
       if (l_cntmsgst%ISOPEN) then
         close l_cntmsgst;
       end if;
      when invalid_table then
       --return 0 count instead of throwing error to UI
       --all the returns are at their initialized value of 0
       --just ensure that the cursor is closed
       if (l_cntmsgst%ISOPEN) then
         close l_cntmsgst;
       end if;
    end;


end loop; -- end loop for c_localagents

exception
  when OTHERS then
      if (l_cntmsgst%ISOPEN)
      then
         close l_cntmsgst;
      end if;

      Wf_Core.Context('WF_QUEUE','getCntMsgSt',p_agent);
      raise;
end getCntMsgSt;

--
-- move_msgs_excep2normal (CONCURRENT PROGRAM API)
--   API to move messages from the exception queue to the normal queue
--   of the given agent. Handles wf_event_t and JMS_TEXT_MESSAGE payloads.
--
-- OUT
--   errbuf  - CP error message
--   retcode - CP return code (0 = success, 1 = warning, 2 = error)
-- IN
--   p_agent_name  - Agent name
--
procedure move_msgs_excep2normal(errbuf  out nocopy varchar2,
    		                 retcode out nocopy varchar2,
  		                 p_agent_name in varchar2)
as
   l_queue_name         varchar2(100);
   l_queue_handler      varchar2(100);
   l_schema             varchar2(100);
   l_qname              varchar2(100);
   l_excp_qname         varchar2(100);
   l_object_type        varchar2(100);
   l_obj_type           varchar2(100);
   l_pos                number := 0;
   l_timeout            integer;
   l_dequeue_options    dbms_aq.dequeue_options_t;
   l_enqueue_options    dbms_aq.enqueue_options_t;
   l_message_properties dbms_aq.message_properties_t;
   l_payload_evt        wf_event_t;
   l_payload_jms        sys.aq$_JMS_TEXT_MESSAGE;
   l_msg_id             raw(16);
   invalid_agent        exception;
   invalid_type         exception;
   pragma EXCEPTION_INIT(invalid_agent, -20201);
   pragma EXCEPTION_INIT(invalid_type, -20202);

begin

   begin
      SELECT TRIM(queue_name), TRIM(queue_handler)
      INTO   l_queue_name, l_queue_handler
      FROM   wf_agents
      WHERE  name = upper(p_agent_name)
      AND    SYSTEM_GUID = wf_event.local_system_guid;
   exception
      when no_data_found then
         raise_application_error(-20201, 'Agent not found');
      when others then
         raise;
   end;

   l_pos         := instr(l_queue_name, '.', 1, 1);
   l_schema      := substr(l_queue_name, 1, l_pos-1);
   l_qname       := substr(l_queue_name, l_pos+1);
   l_excp_qname  := 'AQ$_' || l_qname || '_E';

   SELECT TRIM(object_type)
   INTO   l_object_type
   FROM   all_queue_tables
   WHERE  queue_table in
      (
         SELECT queue_table
	 FROM   all_queues
	 WHERE  name = l_qname
	 AND owner = l_schema
      )
   AND owner=l_schema;

   l_pos      := instr(l_object_type, '.', 1, 1);
   l_obj_type := substr(l_object_type, l_pos+1);

   l_timeout  := 0;
   l_dequeue_options.dequeue_mode  := dbms_aq.REMOVE;
   l_dequeue_options.wait          := dbms_aq.NO_WAIT;
   l_dequeue_options.consumer_name := null;
   l_enqueue_options.visibility    := dbms_aq.ON_COMMIT;

   if l_obj_type = 'WF_EVENT_T' then
      wf_event_t.Initialize(l_payload_evt);
      while (l_timeout = 0) loop
	 begin
	    --Dequeue the message from the exception queue
	    dbms_aq.Dequeue(queue_name         => l_schema || '.' || l_excp_qname,
			    dequeue_options    => l_dequeue_options,
			    message_properties => l_message_properties,
			    payload            => l_payload_evt,
			    msgid              => l_msg_id);
	    l_timeout := 0;
	    --Enqueue the message in the normal queue
	    l_message_properties.expiration  := dbms_aq.never;
	    if (upper(p_agent_name) = 'WF_ERROR' OR upper(p_agent_name) = 'WF_IN'
	      OR upper(p_agent_name) = 'WF_OUT') then
	        l_message_properties.recipient_list(1) := sys.aq$_agent(p_agent_name,
                                                          null,
                                                          0);
        end if;
	    dbms_aq.enqueue(queue_name         => l_queue_name,
			    enqueue_options    => l_enqueue_options,
			    message_properties => l_message_properties,
			    payload            => l_payload_evt,
			    msgid              => l_msg_id);
	    commit;

	 exception
	    when dequeue_timeout then
               l_timeout := 1;
	    when others then
	       raise;
	 end;
      end loop;    --End of while loop that handles wf_event_t payload

   elsif l_obj_type = 'AQ$_JMS_TEXT_MESSAGE' then
      l_timeout := 0;
      while (l_timeout = 0) loop
	 begin
	    --Dequeue the message from the exception queue
	    dbms_aq.Dequeue(queue_name         => l_schema || '.' || l_excp_qname,
			    dequeue_options    => l_dequeue_options,
			    message_properties => l_message_properties,
			    payload            => l_payload_jms,
			    msgid              => l_msg_id);
	    l_timeout := 0;
	    --Enqueue the message in the normal queue of the given agent
	    l_message_properties.expiration  := dbms_aq.never;
	    dbms_aq.enqueue(queue_name         => l_queue_name,
			    enqueue_options    => l_enqueue_options,
			    message_properties => l_message_properties,
			    payload            => l_payload_jms,
			    msgid              => l_msg_id);
	    commit;

	 exception
	    when dequeue_timeout then
               l_timeout := 1;
	    when others then
	       raise;
	 end;
	  end loop;     --End of while loop that handles AQ$_JMS_TEXT_MESSAGE payload

   else
      -- Payload not supported by this API, raise application error
      raise_application_error(-20202, 'Invalid payload type');
   end if;

   errbuf := '';
   retcode := '0';

exception
   when invalid_agent then
      errbuf := 'The agent ' || p_agent_name || ' is not found ';
      retcode := '2';
   when invalid_type then
      errbuf :=  'This API does not support payload of type '
                 || l_obj_type || ' for agent ' || p_agent_name;
      retcode := '2';
   when others then
      errbuf := sqlerrm;
      retcode := '2';
end move_msgs_excep2normal;

--
-- Overloaded Procedure 1 : Definition without the AGE parameter
--
-- clean_evt
--   Procedure to purge the messages in the READY state of a Queue
--   of WF_EVENT_T or AQ$_JMS_TEXT_MESSAGE payload type. Supports correlation id based purge.
--
-- IN
--   p_agent_name       - Agent Name
--   p_correlation      - Correlation ID (Default Value : NULL)
--   p_commit_frequency - Commit Level   (Default Value : 500)
--
-- OUT
--   p_msg_count        - Count of the number of purged messages
--
procedure clean_evt(p_agent_name       in  varchar2,
		    p_correlation      in  varchar2 default NULL,
		    p_commit_frequency in  number   default 500,
		    p_msg_count        out nocopy number)
as
   l_xcount             integer;
   l_timeout            integer;
   l_pos                number := 0;
   l_schema             varchar2(80);
   l_qname              varchar2(80);
   l_queue_name         varchar2(80);
   l_account_name       varchar2(30);
   l_payload            wf_event_t;
   l_msgid              raw(16);
   l_message_handle     raw(16) := NULL;
   l_dequeue_options    dbms_aq.dequeue_options_t;
   l_message_properties dbms_aq.message_properties_t;

   -- Bug 6112028
   l_data_type     VARCHAR2(106);
   l_payload_jms   SYS.AQ$_JMS_TEXT_MESSAGE;

   --Define the snapshot too old error
   snap_too_old exception;
   pragma exception_init(snap_too_old, -1555);

begin
   p_msg_count   := 0;
   l_timeout     := 0;
   l_xcount      := 0;

   SELECT     queue_name
   INTO       l_queue_name
   FROM       wf_agents
   WHERE      name  = upper(p_agent_name)
   AND        SYSTEM_GUID = wf_event.local_system_guid;

   l_pos    := instr(l_queue_name, '.', 1, 1);
   l_schema := substr(l_queue_name, 1, l_pos-1);
   l_qname  := substr(l_queue_name, l_pos+1);

   SELECT TRIM(object_type)
   INTO   l_data_type
   FROM   all_queue_tables
   WHERE  queue_table in
      (
         SELECT queue_table
	 FROM   all_queues
	 WHERE  name = l_qname
	 AND owner = l_schema
      )
   AND owner=l_schema;

   l_pos      := instr(l_data_type, '.', 1, 1);
   l_data_type := substr(l_data_type, l_pos+1);

   --No processing is done on the payload data
   --So dequeue is done in the REMOVE_NODATA mode
   l_dequeue_options.navigation    := dbms_aq.FIRST_MESSAGE;
   l_dequeue_options.dequeue_mode  := dbms_aq.REMOVE_NODATA;
   l_dequeue_options.wait          := dbms_aq.NO_WAIT;
   l_dequeue_options.consumer_name := upper(p_agent_name);

   --Set the Correlation ID for dequeue only if available
   --If the given agent is a Workflow Agent then append the
   --Account Name before the Correlation ID
   if ((p_correlation is not null) or (p_correlation <> '')) then
      -- Seeded WF agents
      if (upper(p_agent_name) like 'WF_%') then
	 if (wf_event.account_name is null) then
            wf_event.SetAccountName;
	 end if;
	 l_dequeue_options.correlation := wf_event.account_name
	                                  || ':'
	                                  || p_correlation;
      else
	 l_dequeue_options.correlation := p_correlation;
      end if;
   end if;

   -- All the messages with the given correlation id are to be purged
   -- In this case, the $fnd/sql/wfevqcln.sql script logic is followed
   -- The dequeue is based on the given correlation id
   while (l_timeout = 0) loop
      begin

	 if (l_data_type = 'WF_EVENT_T') then
	   dbms_aq.Dequeue(queue_name       => l_queue_name,
			 dequeue_options    => l_dequeue_options,
			 message_properties => l_message_properties, /* OUT */
			 payload            => l_payload,            /* OUT */
			 msgid              => l_message_handle);    /* OUT */
	 elsif l_data_type = 'AQ$_JMS_TEXT_MESSAGE' then
            dbms_aq.Dequeue(queue_name      => l_queue_name,
			 dequeue_options    => l_dequeue_options,
			 message_properties => l_message_properties, /* OUT */
			 payload            => l_payload_jms,        /* OUT */
			 msgid              => l_message_handle);    /* OUT */
         else
            -- Payload not supported by this API, raise application error
	    Wf_core.token('PAYLOAD', l_data_type);
            Wf_core.raise('WFE_PAYLOAD_UNSUPP');
         end if;

	 l_xcount  := l_xcount + 1;
	 l_timeout := 0;

      exception
	 when dequeue_disabled then
            raise;
	 when dequeue_timeout then
	    l_timeout := 1;
	    --Capture the snapshot too old error
	 when snap_too_old then
	    --Workaround for AQ when receiving ORA-01555 using NEXT_MESSAGE as
	    --navigation. We will try to set to FIRST_MESSAGE and dequeue to
	    --silently handle this exception.
	    if (l_dequeue_options.navigation = dbms_aq.FIRST_MESSAGE) then
	       raise;
	    else
	       l_dequeue_options.navigation := dbms_aq.FIRST_MESSAGE;

              if (l_data_type = 'WF_EVENT_T') then
	          dbms_aq.Dequeue(queue_name         => l_queue_name,
			            dequeue_options    => l_dequeue_options,
			            message_properties => l_message_properties, /* OUT */
			            payload            => l_payload,            /* OUT */
			            msgid              => l_message_handle);    /* OUT */

              elsif l_data_type = 'AQ$_JMS_TEXT_MESSAGE' then
	          dbms_aq.Dequeue(queue_name      => l_queue_name,
			       dequeue_options    => l_dequeue_options,
			       message_properties => l_message_properties, /* OUT */
			       payload            => l_payload_jms,        /* OUT */
			       msgid              => l_message_handle);    /* OUT */
              else
                -- Payload not supported by this API, raise application error
		 Wf_core.token('PAYLOAD', l_data_type);
                 Wf_core.raise('WFE_PAYLOAD_UNSUPP');
              end if;

	       l_xcount  := l_xcount + 1;
	       l_timeout := 0;
             end if;
	 when others then
	    raise;
      end;

      l_dequeue_options.navigation := dbms_aq.NEXT_MESSAGE;
      --Commit if commit frequency
      if l_xcount >= p_commit_frequency then
	 commit;
	 p_msg_count := p_msg_count + l_xcount;
	 l_xcount    := 0;
      end if;
   end loop;

   commit;
   p_msg_count := p_msg_count + l_xcount;

exception
   when others then
      Wf_core.Context('WF_QUEUE', 'Clean_evt', p_agent_name,
		      p_correlation, to_char(p_commit_frequency));
      raise;
end clean_evt;

--
-- Overloaded Procedure 2 : Definition with the AGE parameter
--
-- clean_evt
--   Procedure to purge the messages in the READY state of a Queue
--   of WF_EVENT_T or AQ$_JMS_TEXT_MESSAGE payload type. Supports time-based selective
--   purge with correlation id.
--
-- IN
--   p_agent_name       - Agent Name
--   p_correlation      - Correlation ID (Default Value : NULL)
--   p_commit_frequency - Commit Level   (Default Value : 500)
--   p_age              - Age of the Messages (No default value
--                        as this is a overloaded procedure)
--
-- OUT
--   p_msg_count        - Count of the number of purged messages
--
procedure clean_evt(p_agent_name       in  varchar2,
		    p_correlation      in  varchar2 default NULL,
		    p_commit_frequency in  number   default 500,
		    p_msg_count        out nocopy number,
		    p_age              in  number)
as
   l_xcount             integer;
   l_pos                number := 0;
   l_schema             varchar2(80);
   l_qname              varchar2(80);
   l_corrid             varchar2(128);
   l_queue_name         varchar2(80);
   l_account_name       varchar2(30);
   l_payload            wf_event_t;
   l_msgid              raw(16);
   l_message_handle     raw(16) := NULL;
   l_dequeue_options    dbms_aq.dequeue_options_t;
   l_message_properties dbms_aq.message_properties_t;

   -- Bug 6112028
   l_data_type     VARCHAR2(106);
   l_payload_jms   SYS.AQ$_JMS_TEXT_MESSAGE;

   -- Cursor to get all messages from the queue that were enqueued before
   -- a given date.
   TYPE c_msgs_typ IS REF CURSOR;
   c_msgs c_msgs_typ;
   --Define the snapshot too old error
   snap_too_old exception;
   pragma exception_init(snap_too_old, -1555);
begin
   p_msg_count   := 0;
   l_xcount      := 0;

   SELECT     queue_name
   INTO       l_queue_name
   FROM       wf_agents
   WHERE      name  = upper(p_agent_name)
   AND        SYSTEM_GUID = wf_event.local_system_guid;

   l_pos    := instr(l_queue_name, '.', 1, 1);
   l_schema := substr(l_queue_name, 1, l_pos-1);
   l_qname  := substr(l_queue_name, l_pos+1);

   SELECT TRIM(object_type)
   INTO   l_data_type
   FROM   all_queue_tables
   WHERE  queue_table in
      (
         SELECT queue_table
	 FROM   all_queues
	 WHERE  name = l_qname
	 AND owner = l_schema
      )
   AND owner=l_schema;
   -- Query from the AQ view table
   l_qname  := l_schema || '.AQ$' || l_qname;

   l_pos      := instr(l_data_type, '.', 1, 1);
   l_data_type := substr(l_data_type, l_pos+1);

   --No processing is done on the payload data
   --So dequeue is done in the REMOVE_NODATA mode
   l_dequeue_options.navigation    := dbms_aq.FIRST_MESSAGE;
   l_dequeue_options.dequeue_mode  := dbms_aq.REMOVE_NODATA;
   l_dequeue_options.wait          := dbms_aq.NO_WAIT;
   l_dequeue_options.consumer_name := upper(p_agent_name);
   --
   --Set the Correlation ID for dequeue only if available
   --If the given agent is a Workflow Agent then append the
   --Account Name before the Correlation ID
   --
   -- All the message ids older than the specified age are queried
   -- and the dequeue is done on the retrieved message ids
   --
   if ((p_correlation is not null) or (p_correlation <> '')) then
      -- Seeded WF agents
      if (upper(p_agent_name) like 'WF_%') then
	 if (wf_event.account_name is null) then
            wf_event.SetAccountName;
	 end if;
	 l_corrid := wf_event.account_name
	             || ':'
	             || p_correlation;
      else
	 l_corrid := p_correlation;
      end if;
      -- The dequeue should be based on the msg ids retrieved in
      -- the following query, not on any correlation id.
      -- So the l_dequeue_options.correlation is not set.
      OPEN c_msgs FOR
	 'SELECT msg_id FROM '
	 || l_qname
	 || ' WHERE  msg_state = ''' || 'READY'' '
	 || ' AND enq_time < (sysdate - :1) '
	 || ' AND corr_id like :2 ' using p_age,l_corrid;
   else
      -- If the given correlation is null then the query do not
      -- need it, as we consider a null correlation to be %
      -- The dequeue_options.correlation will be null by default
      OPEN c_msgs FOR
	 'SELECT msg_id FROM '
         || l_qname
         || ' WHERE  msg_state = ''' || 'READY'' '
         || ' AND enq_time < (sysdate - :1) ' using p_age;
   end if;

   -- Dequeue messages based on the msg id
   loop
      fetch c_msgs into l_msgid;
      exit when c_msgs%notfound;
      l_dequeue_options.msgid := l_msgid;
      begin

        if (l_data_type = 'WF_EVENT_T') then
            dbms_aq.Dequeue(queue_name         => l_queue_name,
			 dequeue_options    => l_dequeue_options,
			 message_properties => l_message_properties,
			 payload            => l_payload,
			 msgid              => l_message_handle);
        elsif l_data_type = 'AQ$_JMS_TEXT_MESSAGE' then

            dbms_aq.Dequeue(queue_name         => l_queue_name,
			 dequeue_options    => l_dequeue_options,
			 message_properties => l_message_properties,
			 payload            => l_payload_jms,
			 msgid              => l_message_handle);
        else
           -- Payload not supported by this API, raise application error
	   Wf_core.token('PAYLOAD', l_data_type);
           Wf_core.raise('WFE_PAYLOAD_UNSUPP');
        end if;
	l_xcount  := l_xcount + 1;

      exception
       when dequeue_disabled then
            raise;
       when snap_too_old then
	    --Workaround for AQ when receiving ORA-01555 using NEXT_MESSAGE as
	    --navigation. We will try to set to FIRST_MESSAGE and dequeue to
	    --silently handle this exception.
	    if (l_dequeue_options.navigation = dbms_aq.FIRST_MESSAGE) then
	       raise;
	    else
	       l_dequeue_options.navigation := dbms_aq.FIRST_MESSAGE;

               if (l_data_type = 'WF_EVENT_T') then
	          dbms_aq.Dequeue(queue_name         => l_queue_name,
			            dequeue_options    => l_dequeue_options,
			            message_properties => l_message_properties, /* OUT */
			            payload            => l_payload,            /* OUT */
			            msgid              => l_message_handle);    /* OUT */

              elsif l_data_type = 'AQ$_JMS_TEXT_MESSAGE' then
	         dbms_aq.Dequeue(queue_name      => l_queue_name,
			       dequeue_options    => l_dequeue_options,
			       message_properties => l_message_properties, /* OUT */
			       payload            => l_payload_jms,        /* OUT */
			       msgid              => l_message_handle);    /* OUT */
              else
                -- Payload not supported by this API, raise application error
                  Wf_core.token('PAYLOAD', l_data_type);
                  Wf_core.raise('WFE_PAYLOAD_UNSUPP');
              end if;

	       l_xcount  := l_xcount + 1;
             end if;
       when others then
          raise;
     end; -- cursor begin

     -- Commit if commit frequency
     if l_xcount >= p_commit_frequency then
	commit;
	p_msg_count := p_msg_count + l_xcount;
	l_xcount := 0;
     end if;
   end loop;

   commit;
   p_msg_count := p_msg_count + l_xcount;

exception
   when others then
      Wf_core.Context('WF_QUEUE', 'Clean_evt', p_agent_name, p_correlation,
		      to_char(p_commit_frequency), to_char(p_age));
      raise;
end clean_evt;
--------------------------------------------------------------------------------
/*
** Bug 4005674 - Populate Continuous Loop Global Variables
*/
begin
  wf_queue.g_defer_occurrence  := 100;
  wf_queue.g_add_delay_seconds := 300;
  wf_queue.g_max_delay_seconds := 3600;
--------------------------------------------------------------------------------
end WF_QUEUE;

/

  GRANT EXECUTE ON "APPS"."WF_QUEUE" TO "EM_OAM_MONITOR_ROLE";
