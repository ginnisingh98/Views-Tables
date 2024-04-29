--------------------------------------------------------
--  DDL for Package Body WFJ_QUEUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WFJ_QUEUE" as
/* $Header: wfjqueb.pls 120.1 2005/07/02 02:47:52 appldev noship $ */

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

    -- ====================================================================
    -- NAME: enqueueInbound
    -- Provides a wrapper for the JAVA function to enqueue the
    -- result of the function activity
    -- Item Type
    -- Item Key
    -- Result
    -- Attribute List
    -- Correlation ID
    -- Error Stack
    procedure enqueueInbound(pItemType IN VARCHAR2, pItemKey IN VARCHAR2,
                  pActID IN NUMBER, pResult IN VARCHAR2,
                  pAttrList IN VARCHAR2,
                  pCorrelation IN VARCHAR2, pErrorStack IN VARCHAR2)
   AS
   BEGIN
      WF_QUEUE.EnqueueInbound(pItemType, pItemKey, pActID, pResult,
                              pAttrList, pCorrelation, pErrorStack);
   EXCEPTION
      WHEN OTHERS THEN
         raise;
   END enqueueInbound;

   -- NAME: dequeueOutbound
   -- To remove a message from the Outbound Queue which will be a
   -- request to execute an external funtion activity
   -- The payload is seperated into the individuate data elements
   -- Dequeu Mode
   -- Navigation
   -- Correlation ID
   -- Item Type
   -- Item Key
   -- Payload.Item Type
   -- Payload.Item Key
   -- Payload.Activity ID
   -- Payload.Function Name
   -- Payload Parameter List
   -- Payload.Result
   -- Message Handle
   -- Time Out
   procedure dequeueOutbound(pDequeueMode IN NUMBER, pNavigation IN NUMBER,
                   pCorrelation IN VARCHAR2, pItemType IN VARCHAR2,
                   pPLItemType OUT NOCOPY VARCHAR2, pPLItemKey OUT NOCOPY VARCHAR2,
                   pPLActID OUT NOCOPY NUMBER, pPLFunctionName OUT NOCOPY VARCHAR2,
                   pPLParamList OUT NOCOPY VARCHAR2, pPLResult OUT NOCOPY VARCHAR2,
                   pMessageHandle IN OUT NOCOPY VARCHAR2, pTimeOut OUT NOCOPY VARCHAR2)
   AS
      lCorrelation VARCHAR2(80);
      lPayLoad SYSTEM.WF_PAYLOAD_T;
      lMessageHandle raw(16);
      lTimeout boolean;
      lDequeue_options       dbms_aq.dequeue_options_t;
      lMessage_properties    dbms_aq.message_properties_t;

   BEGIN

      wf_queue.set_queue_names;

     if pCorrelation is not null then
        lCorrelation := pCorrelation;
     else
        lCorrelation := wf_queue.account_name||nvl(pItemType,'%');
     end if;
     lDequeue_options.correlation := lCorrelation;
     lDequeue_options.dequeue_mode := pDequeueMode;
     lDequeue_options.wait := wfj_queue.dequeueDelay;
     lDequeue_options.navigation   := pNavigation;

      lMessageHandle := hextoraw(pMessageHandle);
      dbms_aq.dequeue
      (
          queue_name => wf_queue.OutboundQueue,
          dequeue_options => lDequeue_options,
          message_properties => lMessage_properties,
          payload => lPayLoad,
          msgid => lMessageHandle
      );
      pTimeout := 'FALSE';
      pPLItemType := lPayLoad.ItemType;
      pPLItemKey  := lPayload.ItemKey;
      pPLActID := lPayLoad.actID;
      pPLFunctionName := lPayLoad.Function_name;
      pPLParamList := lPayload.Param_List;
      pPLResult := lPayLoad.Result;
      pMessagehandle := rawtohex(lMessageHandle);

   EXCEPTION
      WHEN dequeue_timeout then
         pTimeout := 'TRUE';
      WHEN OTHERS THEN
         pTimeout := 'FALSE';
         raise;
   END dequeueOutBound;

   -- NAME: getEventData
   -- To retrieve the CLOB data from the event message
   -- Item Type
   -- Item Key
   -- Name of the Item Attribute containing the event
   -- Event data to be returned.
   procedure getEventData(p_item_type in VARCHAR2,
                            p_item_key in VARCHAR2,
                            p_name in VARCHAR2,
                            p_event_data out NOCOPY CLOB)
   AS

      l_event_message WF_EVENT_T;
      l_data CLOB := null;

   BEGIN
         l_event_message := wf_engine.getItemAttrEvent(p_item_type,
                                                       p_item_key, p_name);
         p_event_data := l_event_message.event_data;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
  end getEventData;
  -- For Web Services
   -- NAME: setEventData
   -- To set the CLOB data on the event message
   -- Item Type
   -- Item Key
   -- Name of the Item Attribute containing the event
   -- Event data to be set.
   procedure setEventData(p_item_type in VARCHAR2,
                            p_item_key in VARCHAR2,
                            p_name in VARCHAR2,
                            p_event_data in CLOB)
   AS

      l_event_message WF_EVENT_T;

   BEGIN
        wf_event_t.initialize(l_event_message);
        --We might have to initialize the event
        l_event_message.event_data := p_event_data;
         wf_engine.setItemAttrEvent(p_item_type,p_item_key, p_name,l_event_message);
   EXCEPTION
      WHEN OTHERS THEN
          raise ;
  end setEventData;

  --
  -- ApplyTransformation
  --   Copy the contents of the event from the source to the
  --   destination events. Then open the destination for update
  --   to receive the transformation
  -- IN
  --   itemtype - process item type
  --   itemkey - process item key
  --   name - attribute name
  -- RETURNS
  --   EVENT_DATA CLOB
  --
  function ApplyTransformation(
    itemtype in varchar2,
    itemkey in varchar2,
    srcName in varchar2,
    dstName in varchar2)
  return ROWID
  is
    srcValue wf_event_t;
    dstValue wf_event_t;
    lvalue wf_event_t;
    lRowid ROWID;

  begin
    -- Not allowed in synch mode
    if (itemkey = wf_engine.eng_synch) then
      wf_core.token('OPERATION', 'Wf_Engine.SetItemAttrEvent');
      wf_core.raise('WFENG_SYNCH_DISABLED');
    end if;

    -- Get the source event
    select EVENT_VALUE
    into srcValue
    from WF_ITEM_ATTRIBUTE_VALUES
    where ITEM_TYPE = ApplyTransformation.itemtype
    and ITEM_KEY = ApplyTransformation.itemkey
    and NAME = ApplyTransformation.srcName;

    -- Get the destination event
    select ROWID
    into lRowid
    from WF_ITEM_ATTRIBUTE_VALUES
    where ITEM_TYPE = ApplyTransformation.itemtype
    and ITEM_KEY = ApplyTransformation.itemkey
    and NAME = ApplyTransformation.dstName;

    wf_event_t.initialize(dstValue);
    dstValue.PRIORITY := srcValue.PRIORITY;
    dstValue.SEND_DATE := srcValue.SEND_DATE;
    dstValue.RECEIVE_DATE := srcValue.RECEIVE_DATE;
    dstValue.CORRELATION_ID := srcValue.CORRELATION_ID;
    dstValue.PARAMETER_LIST := srcValue.PARAMETER_LIST;
    dstValue.EVENT_NAME := srcValue.EVENT_NAME;
    dstValue.EVENT_KEY := srcValue.EVENT_KEY;
    dstValue.FROM_AGENT := srcValue.FROM_AGENT;
    dstValue.TO_AGENT := srcValue.TO_AGENT;
    dstValue.ERROR_SUBSCRIPTION := srcValue.ERROR_SUBSCRIPTION;
    dstValue.ERROR_MESSAGE := srcValue.ERROR_MESSAGE;
    dstValue.ERROR_STACK := srcValue.ERROR_STACK;

    -- Assign the source to the destination
    update WF_ITEM_ATTRIBUTE_VALUES
    set EVENT_VALUE = dstValue
    where ITEM_TYPE = ApplyTransformation.itemType
      and ITEM_KEY = ApplyTransformation.itemkey
      and NAME = ApplyTransformation.dstName;

    return(lRowid);
  exception
    when no_data_found then
      Wf_Core.Context('Wfj_Queue', 'ApplyTransformation', itemtype, itemkey,
                      srcName, dstName);
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('KEY', itemkey);
      Wf_Core.Token('ATTRIBUTE', srcName);
      Wf_Core.Token('ATTRIBUTE', dstName);
      Wf_Core.Raise('WFENG_ITEM_ATTR');
    when others then
      Wf_Core.Context('Wfj_Queue', 'ApplyTransformation', itemtype,
          itemkey, srcName, dstName);
      raise;
  end ApplyTransformation;

   -- ====================================================================
   -- NAME: setDequeueDelay
   -- Provides a wrapper for the dequeueDelay spec variable
   -- pDelay - The number of seconds the dequeue operation should block for
  procedure setDequeueDelay(pDelay in INTEGER)
  is
  begin
     wfj_queue.dequeueDelay := pDelay;
  end;

   -- ====================================================================
   -- NAME: getDequeueDelay
   -- Provides a wrapper for the dequeueDelay spec variable
  function getDequeueDelay return integer
  is
  begin
     return wfj_queue.dequeueDelay;
  end;

end WFJ_QUEUE;

/
