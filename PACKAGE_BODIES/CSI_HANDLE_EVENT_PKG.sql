--------------------------------------------------------
--  DDL for Package Body CSI_HANDLE_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_HANDLE_EVENT_PKG" AS
/* $Header: csitbesb.pls 120.2 2007/11/10 01:00:35 fli noship $ */

   --------------------------------------
   -- package global variable declaration
   --------------------------------------
   G_DEBUG_COUNT       NUMBER  := 0;

   FUNCTION exist_subscription(p_event_name IN VARCHAR2) RETURN VARCHAR2
   IS
      CURSOR cu0 IS
      SELECT 'Y'
      FROM   wf_events              eve,
             wf_event_subscriptions sub,
   	     wf_systems             ws
      WHERE eve.name        = p_event_name
      AND   eve.status      = 'ENABLED'
      AND   eve.guid        = sub.event_filter_guid
      AND   sub.status      = 'ENABLED'
      AND   ws.guid         = sub.system_guid
      AND   sub.source_type = 'LOCAL';

      l_yn  VARCHAR2(1);
   BEGIN
      OPEN  cu0;
      FETCH cu0 INTO l_yn;
      IF cu0%NOTFOUND THEN
         l_yn := 'N';
      END IF;
      CLOSE cu0;
      RETURN l_yn;
   END;

   FUNCTION item_key(p_event_name  IN VARCHAR2) RETURN VARCHAR2
   -----------------------------------------------------
   -- Return Item_Key according to CSI Event to be raised
   -- Item_Key is <Event_Name>-CSI_WF_ITEM_KEY_NUMBER_S.nextval
   -----------------------------------------------------
   IS
      RetKey VARCHAR2(240);
   BEGIN
      SELECT p_event_name || CSI_WF_ITEM_KEY_NUMBER_S.nextval
      INTO   RetKey
      FROM   DUAL;
      RETURN RetKey;
   END item_key;

   FUNCTION event(p_event_name IN VARCHAR2) RETURN VARCHAR2
   -----------------------------------------------
   -- Return event name if the entered event exist
   -- Otherwise return NOTFOUND
   -----------------------------------------------
   IS
      RetEvent VARCHAR2(240);
   BEGIN
      SELECT name
      INTO   RetEvent
      FROM   wf_events
      WHERE  name = p_event_name;

      IF SQL%NOTFOUND THEN
         RetEvent := 'NOTFOUND';
      END IF;
      RETURN RetEvent;
   END event;

   PROCEDURE raise_event
   ----------------------------------------------
   -- Check if Event exist
   -- Check if Event is like 'oracle.apps.csi%'
   -- Get the item_key
   -- Raise event
   ----------------------------------------------
      (p_api_version          IN   NUMBER
       ,p_commit              IN   VARCHAR2
       ,p_init_msg_list       IN   VARCHAR2
       ,p_validation_level    IN   NUMBER
       ,p_event_name          IN   VARCHAR2
       ,p_event_key           IN   VARCHAR2
       ,p_instance_id         IN   NUMBER
       ,p_subject_instance_Id IN   NUMBER
       ,p_correlation_value   IN   VARCHAR2
     )
   IS
      l_item_key      VARCHAR2(240);
      l_event         VARCHAR2(240);
      EventNotFound   EXCEPTION;
      EventNotCSI     EXCEPTION;
      l_debug_level   NUMBER;
      l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
   BEGIN
      SAVEPOINT csi_raise_event;

      l_debug_level := fnd_profile.value('CSI_DEBUG_LEVEL');

      IF (l_debug_level > 0) THEN
         csi_gen_utility_pvt.put_line
            ( 'CSI_HANDLE_EVENT_PKG'                     ||'-'||
              p_api_version                              ||'-'||
              nvl(p_commit,FND_API.G_FALSE)              ||'-'||
              nvl(p_init_msg_list,FND_API.G_FALSE)       ||'-'||
              nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) );
      END IF;

      l_event := event(p_event_name);

      IF l_event = 'NOTFOUND' THEN
         RAISE EventNotFound;
      END IF;

      IF SUBSTR(l_event,1,16) <> 'oracle.apps.csi.' THEN
         RAISE EventNotCSI;
      END IF;

      wf_event.AddParameterToList(p_name   => 'CUSTOMER_PRODUCT_ID'
                                 ,p_value  => p_instance_id
                                 ,p_parameterlist => l_parameter_list);

      wf_event.AddParameterToList(p_name   => 'CHILD_CUSTOMER_PRODUCT_ID'
                                 ,p_value  => p_subject_instance_id
                                 ,p_parameterlist => l_parameter_list);

      wf_event.AddParameterToList(p_name   => 'Q_CORRELATION_ID'
                                 ,p_value  => p_correlation_value
                                 ,p_parameterlist => l_parameter_list);

      Wf_Event.Raise
         (p_event_name   =>  l_event,
          p_event_key    =>  p_event_key,
          p_parameters   =>  l_parameter_list);

      IF (l_debug_level > 1) THEN
        csi_gen_utility_pvt.put_line('Raise Business Event');
        csi_gen_utility_pvt.put_line('  Event Name                  : '||l_event);
        csi_gen_utility_pvt.put_line('  Event Key                   : '||p_event_key);
        csi_gen_utility_pvt.put_line('  Customer Product Id         : '||p_instance_id);
        csi_gen_utility_pvt.put_line('  Child Customer Product Id   : '||p_subject_instance_id);
        csi_gen_utility_pvt.put_line('  Q Correlation Id            : '||p_correlation_value);
      END IF;

   EXCEPTION
      WHEN EventNotFound THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_EVENT_NOT_FOUND');
	 FND_MESSAGE.SET_TOKEN('EVENT',p_event_name);
	 FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      WHEN EventNotCSI THEN
         FND_MESSAGE.SET_NAME('CSI','CSI_EVENT_NOT_CSI');
	 FND_MESSAGE.SET_TOKEN('EVENT',p_event_name);
	 FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      WHEN NO_DATA_FOUND THEN
         CSI_GEN_UTILITY_PVT.Put_Line('NO_DATA_FOUND ... Rollback to CSI_RAISE_EVENT');
         ROLLBACK TO csi_raise_event;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      WHEN OTHERS  THEN
         CSI_GEN_UTILITY_PVT.Put_Line('WHEN OTHERS ... Rollback to CSI_RAISE_EVENT');
         ROLLBACK TO csi_raise_event;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END raise_event;
END;

/
