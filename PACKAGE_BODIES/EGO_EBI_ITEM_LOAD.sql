--------------------------------------------------------
--  DDL for Package Body EGO_EBI_ITEM_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_EBI_ITEM_LOAD" AS
/* $Header: EGOVEILB.pls 120.0.12010000.4 2009/07/20 11:12:01 aashah noship $ */
--Private prcoedure for raising the events
PROCEDURE RAISE_ITEM_LOAD_EVENT(
        p_event_name           IN             VARCHAR2
        ,p_event_id            IN             NUMBER    DEFAULT NULL
        ,x_msg_data            OUT NOCOPY     VARCHAR2
        ,x_return_status       OUT NOCOPY     VARCHAR2
        );

--Purge load events from Event log table
PROCEDURE PURGE_EVENTLOG
IS
 BEGIN
    DELETE FROM EGO_EBI_ITEM_LOAD_LOG;
    COMMIT;
END PURGE_EVENTLOG;

--Genrate Item Load Events
PROCEDURE GENERATE_EVENTS( p_organization_id   IN           NUMBER
                          ,p_batch_size        IN            NUMBER      DEFAULT 20
                          ,p_max_events        IN            NUMBER      DEFAULT NULL
                          ,x_err_msg           OUT NOCOPY VARCHAR2)
IS
l_logItemCount           NUMBER;
l_ItemCount              NUMBER;
l_eventId                NUMBER;
l_eventsRaised           NUMBER :=0;
l_msg_data               VARCHAR2(500);
l_return_status          VARCHAR2(500);
l_batch_size             NUMBER;
l_max_events             NUMBER;


 BEGIN
  x_err_msg := '';
  l_batch_size := p_batch_size;
  l_max_events := p_max_events;

  -- Get the Item count in the event log
  SELECT count(*) INTO  l_logItemCount  FROM EGO_EBI_ITEM_LOAD_LOG;

  --if there are no records in the event log table Insert records to Event Log table .
    IF (l_logItemCount = 0) THEN
    BEGIN
       --Insert required item records into event log table .
     x_err_msg := x_err_msg || '\n Inserting Records to Event log table';
     -- Initialize Event Id to 0
     l_eventId := 0;
     INSERT INTO EGO_EBI_ITEM_LOAD_LOG (INVENTORY_ITEM_ID,ORGANIZATION_ID, EVENT_ID)
        SELECT INVENTORY_ITEM_ID, ORGANIZATION_ID, NULL
        FROM MTL_SYSTEM_ITEMS_B
        WHERE ORGANIZATION_ID = p_organization_id
          AND bom_item_type in (1, 2, 4)
          AND customer_order_flag = 'Y'
          AND customer_order_enabled_flag = 'Y';
      COMMIT;
    END;
    ELSE
    -- Initialize Event Id from the last run of the generate_events
     SELECT MAX(NVL(EVENT_ID,0)) into l_eventId FROM EGO_EBI_ITEM_LOAD_LOG;
    END IF;
    x_err_msg := 'Event Id Initialized to ' || TO_CHAR(l_eventId) ;

      --Get Count of Item  for which the Event should be raised
     SELECT count(*) INTO l_ItemCount FROM EGO_EBI_ITEM_LOAD_LOG WHERE EVENT_ID IS NULL;
     WHILE (l_ItemCount > 0 AND (l_max_events IS NULL OR l_eventsRaised < l_max_events)) LOOP
     BEGIN
       --Generate new <event-id>
       l_eventId  := l_eventId +1;
       x_err_msg := 'Event Id ' ||TO_CHAR(l_eventId)|| ' updating';
       UPDATE EGO_EBI_ITEM_LOAD_LOG
        SET EVENT_ID = l_eventId
       WHERE EVENT_ID IS NULl AND  ROWNUM < l_batch_size +1;
       l_ItemCount := l_ItemCount - l_batch_size;

       --Raise event <event-id>
       Raise_Item_LOAD_Event (EGO_EBI_ITEM_LOAD.G_ITEM_LOAD_EVENT, l_eventId, l_msg_data, l_return_status);
       x_err_msg := 'Raised Event' || TO_CHAR(l_eventId) || ' with return status = ' || l_return_status ;
       l_eventsRaised := l_eventsRaised +1;
        COMMIT;
    END;
    END LOOP;
    x_err_msg := 'Raised ' || TO_CHAR(l_eventsRaised) || ' events. ';
    IF ( l_ItemCount >0 ) THEN
     x_err_msg :=  x_err_msg || ' There are ' || TO_CHAR(l_ItemCount) || ' more items pending.';
    END IF;
END Generate_Events;


--To regenrate failed event provide the event id
PROCEDURE REGENERATE_FAILED_EVENT( p_organization_id   IN         NUMBER
                                   ,p_event_id         IN         NUMBER
                                   ,x_err_msg           OUT NOCOPY VARCHAR2
                           )
IS
l_logItemCount           NUMBER;
l_msg_data               VARCHAR2(500);
l_return_status          VARCHAR2(500);
l_eventId                    NUMBER;


 BEGIN
  x_err_msg := '';
  l_return_status := '';
  l_msg_data := '';
  -- Get the Item count in the event log for the event
  SELECT count(*) INTO  l_logItemCount
  FROM EGO_EBI_ITEM_LOAD_LOG
  WHERE ORGANIZATION_ID =  p_organization_id
    AND EVENT_ID = p_event_id;

  --if there are records in the event log table Insert records to Event Log table .
    IF (l_logItemCount > 0) THEN
    BEGIN
       --Insert required item records into event log table .
     x_err_msg := x_err_msg || 'Deleting recods from Event log table for the event ' ||  TO_CHAR(p_event_id) || ' that are not active';

     DELETE FROM  EGO_EBI_ITEM_LOAD_LOG
     WHERE ORGANIZATION_ID = p_organization_id AND
           EVENT_ID = p_event_id AND
           INVENTORY_ITEM_ID NOT IN(
                    SELECT INVENTORY_ITEM_ID
                    FROM MTL_SYSTEM_ITEMS_B
                    WHERE ORGANIZATION_ID = p_organization_id
                      AND bom_item_type in (1, 2, 4)
                      AND customer_order_flag = 'Y'
                      AND customer_order_enabled_flag = 'Y');

       SELECT MAX(NVL(EVENT_ID,0))+1 into l_eventId FROM EGO_EBI_ITEM_LOAD_LOG;
       UPDATE EGO_EBI_ITEM_LOAD_LOG
            SET EVENT_ID = l_eventId
            WHERE EVENT_ID = p_event_id   ;

      --Raise event <event-id>
       Raise_Item_LOAD_Event (EGO_EBI_ITEM_LOAD.G_ITEM_LOAD_EVENT, l_eventId , l_msg_data, l_return_status);
       x_err_msg := 'Raised Event' || TO_CHAR(l_eventId ) || ' with return status = ' || l_return_status ;
      COMMIT;
    END;
     ELSE
      x_err_msg := 'Could not find event id' || TO_CHAR(p_event_id);
    END IF;

END REGENERATE_FAILED_EVENT;

PROCEDURE RAISE_ITEM_LOAD_EVENT (
                           p_event_name          IN            VARCHAR2
                          ,p_event_id            IN            NUMBER    DEFAULT NULL
                          ,x_msg_data            OUT NOCOPY    VARCHAR2
                          ,x_return_status       OUT NOCOPY    VARCHAR2
                          )
IS
  l_parameter_list         WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
  l_parameter_t            WF_PARAMETER_T:= WF_PARAMETER_T(null, null);
  l_event_name             VARCHAR2(240);
  l_event_key              VARCHAR2(240);
BEGIN

  l_event_name := p_event_name ;
  l_event_key  := p_event_id ||   SUBSTRB(l_event_name, 1, 225) || '-' || TO_CHAR(SYSDATE, 'J.SSSSS');
   --Adding the parameters  EVENT ID param not required as
  WF_EVENT.AddParameterToList( p_name            => 'EVENT_ID'
                              ,p_value           => p_event_id
                              ,p_ParameterList   => l_parameter_List);

  WF_EVENT.Raise(p_event_name => l_event_name
                ,p_event_key  => l_event_key
                ,p_parameters => l_parameter_list);
  l_parameter_list.DELETE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

END Raise_Item_LOAD_Event;


END EGO_EBI_ITEM_LOAD;

/
