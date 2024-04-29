--------------------------------------------------------
--  DDL for Package Body HZ_EBI_CUST_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EBI_CUST_LOAD" AS
/* $Header: ARHEICSTLDB.pls 120.0.12010000.6 2009/07/20 10:28:05 aashah noship $ */

PROCEDURE RAISE_CUST_LOAD_EVENT( p_event_name          IN          VARCHAR2
                                ,p_event_id            IN          NUMBER    DEFAULT NULL
                                ,x_msg_data            OUT NOCOPY  VARCHAR2
                                ,x_return_status       OUT NOCOPY  VARCHAR2
                                );

PROCEDURE PURGE_EVENTLOG
   IS
   BEGIN
      DELETE FROM HZ_EBI_CUST_LOAD_LOG;
      COMMIT;

END PURGE_EVENTLOG;

PROCEDURE GENERATE_EVENTS( p_batch_size        IN         NUMBER  DEFAULT 20
                          ,p_max_events        IN         NUMBER  DEFAULT NULL
                          ,x_err_msg           OUT NOCOPY VARCHAR2)

    IS
    l_logCustCount           NUMBER;
    l_CustCount              NUMBER;
    l_eventId                NUMBER;
    l_eventsRaised           NUMBER :=0;
    l_msg_data               VARCHAR2(500);
    l_return_status          VARCHAR2(500);
    l_batch_size             NUMBER;
    l_max_events             NUMBER;

    BEGIN
       x_err_msg := '';
       l_logCustCount := 0;
       l_batch_size := p_batch_size;
       l_max_events :=p_max_events ;

       --get count from log(HZ_EBI_CUST_LOAD_LOG) table
       SELECT count(*) INTO  l_logCustCount  FROM HZ_EBI_CUST_LOAD_LOG;

       --Insert records to Event Log table, if there are no records in the event log table.
       IF(l_logCustCount = 0) THEN
          --Insert required item records into event log table .
          x_err_msg := x_err_msg || '\n Inserting Records to Event log table';
          -- Initialize Event Id to 0
          l_eventId := 0;
          INSERT INTO HZ_EBI_CUST_LOAD_LOG( PARTY_ID , EVENT_ID)
          Select distinct party.PARTY_ID ,NULL
          from HZ_PARTIES party, HZ_CUST_ACCOUNTS accnt where
          accnt.status='A' and party.PARTY_ID = accnt.party_id;
          --Commit records.  To check commit frequency
          COMMIT;

       ELSE
           -- Initialize Event Id to 0
           SELECT MAX(NVL(EVENT_ID,0)) into l_eventId FROM HZ_EBI_CUST_LOAD_LOG;

       END IF;

       x_err_msg := 'Event Id Initialized to ' || TO_CHAR(l_eventId) ;
       --Get Count of Item  for which the Event should be raised
       SELECT count(*) INTO l_CustCount FROM HZ_EBI_CUST_LOAD_LOG WHERE EVENT_ID IS NULL;
       WHILE (l_CustCount > 0 AND (l_max_events IS NULL OR l_eventsRaised < l_max_events))
       LOOP
          --Generate new <event-id>
          l_eventId  := l_eventId +1;
          x_err_msg := 'Event Id ' ||TO_CHAR(l_eventId)|| ' updating';
          UPDATE HZ_EBI_CUST_LOAD_LOG
          SET EVENT_ID = l_eventId
          WHERE EVENT_ID IS NULL AND  ROWNUM < l_batch_size +1;
          l_CustCount := l_CustCount - l_batch_size;
          --Raise event <event-id>
          Raise_CUST_LOAD_Event (HZ_EBI_CUST_LOAD.G_CUST_LOAD_EVENT, l_eventId, l_msg_data, l_return_status);
          x_err_msg := 'Raised Event' || TO_CHAR(l_eventId) || ' with return status = ' || l_return_status ;
          l_eventsRaised := l_eventsRaised +1;
       COMMIT;

       END LOOP;
       x_err_msg := 'Raised ' || TO_CHAR(l_eventsRaised) || ' events. ';
       IF ( l_CustCount >0 ) THEN
          x_err_msg :=  x_err_msg || ' There are ' || TO_CHAR(l_CustCount ) || ' more customers pending.';
       END IF;


END Generate_Events;

 --To regenrate failed event provide the event id
PROCEDURE REGENERATE_FAILED_EVENT( p_event_id         IN         NUMBER
                                   ,x_err_msg           OUT NOCOPY VARCHAR2
                           )
IS
l_logCustCount           NUMBER;
l_msg_data               VARCHAR2(500);
l_return_status          VARCHAR2(500);
l_eventId                    NUMBER;


 BEGIN
  x_err_msg := '';
  l_return_status := '';
  l_msg_data := '';
  -- Get the Item count in the event log for the event
  SELECT count(*) INTO  l_logCustCount
  FROM HZ_EBI_CUST_LOAD_LOG
  WHERE  EVENT_ID = p_event_id;

  --if there are records in the event log table for the event, then update the batch and then raise the event.
    IF (l_logCustCount > 0) THEN
    BEGIN

     x_err_msg := x_err_msg || 'Deleting recods from Event log table for the event ' ||  TO_CHAR(p_event_id) || ' that are not active';
     --Deleting recods from Event log table for the event that are not active
     DELETE FROM  HZ_EBI_CUST_LOAD_LOG
     WHERE EVENT_ID = p_event_id AND
           PARTY_ID NOT IN(
                    SELECT DISTINCT party.PARTY_ID
                     FROM HZ_PARTIES party, HZ_CUST_ACCOUNTS accnt
                     WHERE  accnt.STATUS='A' and party.PARTY_ID = accnt.PARTY_ID);

     SELECT MAX(NVL(EVENT_ID,0))+1 into l_eventId FROM HZ_EBI_CUST_LOAD_LOG;
       UPDATE HZ_EBI_CUST_LOAD_LOG
           SET EVENT_ID = l_eventId
           WHERE EVENT_ID = p_event_id    ;

      --Raise event <event-id>
       Raise_CUST_LOAD_Event (HZ_EBI_CUST_LOAD.G_CUST_LOAD_EVENT, l_eventId, l_msg_data, l_return_status);
       x_err_msg := 'Raised Event' || TO_CHAR(l_eventId) || ' with return status = ' || l_return_status ;
      COMMIT;
    END;
     ELSE
      x_err_msg := 'Could not find event id' || TO_CHAR(p_event_id);
    END IF;

END REGENERATE_FAILED_EVENT;



PROCEDURE RAISE_CUST_LOAD_EVENT (
                           p_event_name          IN          VARCHAR2
                          ,p_event_id            IN          NUMBER    DEFAULT NULL
                          ,x_msg_data            OUT NOCOPY  VARCHAR2
                          ,x_return_status       OUT NOCOPY  VARCHAR2
                          )
   IS
   l_parameter_list         WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
   l_parameter_t            WF_PARAMETER_T:= WF_PARAMETER_T(null, null);
   l_event_name             VARCHAR2(240);
   l_event_key              VARCHAR2(240);
   BEGIN
      l_event_name := p_event_name ;
      l_event_key  := p_event_id ||   SUBSTRB(l_event_name, 1, 225) || '-' || TO_CHAR(SYSDATE, 'J.SSSSS');
      WF_EVENT.AddParameterToList( p_name            => 'CDH_EVENT_ID'
                                  ,p_value           => p_event_id
                                  ,p_ParameterList   => l_parameter_List);

      WF_EVENT.Raise( p_event_name => l_event_name
                     ,p_event_key  => l_event_key
                     ,p_parameters => l_parameter_list);
      l_parameter_list.DELETE;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN Others THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data      := SQLERRM ;

END Raise_CUST_LOAD_Event;

PROCEDURE Get_Org_Custs_BO(  p_event_id             IN            NUMBER
                            ,x_org_cust_objs        OUT NOCOPY    HZ_ORG_CUST_BO_TBL
                            ,x_return_status        OUT NOCOPY    VARCHAR2
                            ,x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
                           )
   Is
   x_org_cust_obj HZ_ORG_CUST_BO;
   x_msg_data  VARCHAR2(2000);
   x_msg_count NUMBER;
   party_id NUMBER;
   l_count  NUMBER ;

   CURSOR cust_cur IS
       SELECT party_id from HZ_EBI_CUST_LOAD_LOG where event_id = p_event_id;

   BEGIN
      x_org_cust_objs := HZ_ORG_CUST_BO_TBL();
      x_messages      := HZ_MESSAGE_OBJ_TBL();
      l_count         :=0;
      OPEN cust_cur;
         LOOP
         FETCH cust_cur INTO party_id;
           EXIT WHEN cust_cur%NOTFOUND;
            x_org_cust_objs.extend(1);
            x_messages.extend(1) ;
            l_count := l_count+1;
            HZ_ORG_CUST_BO_PUB.get_org_cust_bo( p_organization_id           => party_id
                                               ,p_organization_os           =>NULL
                                               ,p_organization_osr          =>NULL
                                               ,x_org_cust_obj              => x_org_cust_obj
                                               ,x_return_status             => x_return_status
                                               ,x_msg_count                  =>  x_msg_count
                                               ,x_msg_data                   => x_msg_data
                                               );

            x_org_cust_objs(l_count) := x_org_cust_obj;
            x_messages(l_count) := HZ_MESSAGE_OBJ(x_msg_data);

     END LOOP;
     CLOSE cust_cur;

     IF (l_count =0) THEN
        x_messages.extend(1) ;
        x_msg_data :=' This event_id  : '||p_event_id||' does not Exist ';
        x_messages(1):=HZ_MESSAGE_OBJ(x_msg_data);
     END IF;


END Get_Org_Custs_BO;

END HZ_EBI_CUST_LOAD;

/
