--------------------------------------------------------
--  DDL for Package WFJ_QUEUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WFJ_QUEUE" AUTHID CURRENT_USER as
/* $Header: wfjques.pls 115.5 2002/12/03 21:15:05 vebsingh noship $ */

    -- Default wait time for DequeuOutbound Operation
    dequeueDelay INTEGER := 30;

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
                  pCorrelation IN VARCHAR2, pErrorStack IN VARCHAR2);


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
                   pMessageHandle IN OUT NOCOPY VARCHAR2, pTimeOut OUT NOCOPY VARCHAR2);

   -- NAME: getEventData
   -- To retrieve the CLOB data from the event message
   -- Item Type
   -- Item Key
   -- Name of the Item Attribute containing the event
   -- Event data to be returned.
   procedure getEventData(p_item_type in VARCHAR2,
                          p_item_key in VARCHAR2,
                          p_name in VARCHAR2,
                          p_event_data out NOCOPY CLOB);

   --For supporting webServices

   -- NAME: setEventData
   -- To set the CLOB data on  the event message
   -- Item Type
   -- Item Key
   -- Name of the Item Attribute containing the event
   -- Event data to be set.
   procedure setEventData(p_item_type in VARCHAR2,
                          p_item_key in VARCHAR2,
                          p_name in VARCHAR2,
                          p_event_data in CLOB);

   function ApplyTransformation(itemtype in varchar2,
                      itemkey in varchar2,
                      srcName in varchar2,
                      dstName in varchar2)
   return ROWID;

   -- ====================================================================
   -- NAME: setDequeueDelay
   -- Provides a wrapper for the dequeueDelay spec variable
   -- pDelay - The number of seconds the dequeue operation should block for
   procedure setDequeueDelay(pDelay in INTEGER);

   -- ====================================================================
   -- NAME: getDequeueDelay
   -- Provides a wrapper for the dequeueDelay spec variable
   function getDequeueDelay return integer;

end WFJ_QUEUE;

 

/
