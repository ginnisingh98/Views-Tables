--------------------------------------------------------
--  DDL for Package Body PVX_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_EVENT_PKG" AS
/*$Header: pvxbuevb.pls 115.1 2003/09/01 06:48:55 nramu noship $ */

 FUNCTION Item_Key(p_event_name  IN VARCHAR2) RETURN VARCHAR2
 -----------------------------------------------------
 -- Return Item_Key according to Hz Event to be raised
 -- Item_Key is <Event_Name>-pvwfapp_s.nextval
 -----------------------------------------------------
 IS
  RetKey VARCHAR2(240);
 BEGIN
  SELECT p_event_name || pv_wf_items_s.nextval INTO RetKey FROM DUAL;
  RETURN RetKey;
 END Item_Key;

 FUNCTION Check_Event(p_event_name IN VARCHAR2) RETURN VARCHAR2
 -----------------------------------------------
 -- Return event name if the entered event exist
 -- Otherwise return NOTFOUND
 -----------------------------------------------
 IS
   CURSOR c_event_name IS
     SELECT name
       FROM wf_events
       WHERE name = p_event_name;
   RetEvent VARCHAR2(240);
 BEGIN
   OPEN c_event_name;
   FETCH c_event_name INTO RetEvent;
   IF c_event_name%NOTFOUND THEN
     RetEvent := 'NOTFOUND';
   END IF;
   CLOSE c_event_name;
   RETURN RetEvent;
 END Check_Event;

 PROCEDURE AddParamEnvToList
------------------------------------------------------
-- Add Application-Context parameter to the enter list
------------------------------------------------------
( x_list              IN OUT NOCOPY  WF_PARAMETER_LIST_T,
  p_user_id           IN VARCHAR2  DEFAULT NULL,
  p_resp_id           IN VARCHAR2  DEFAULT NULL,
  p_resp_appl_id      IN VARCHAR2  DEFAULT NULL,
  p_security_group_id IN VARCHAR2  DEFAULT NULL,
  p_org_id            IN VARCHAR2  DEFAULT NULL)
 IS
   l_user_id           VARCHAR2(255) := p_user_id;
   l_resp_appl_id      VARCHAR2(255) := p_resp_appl_id;
   l_resp_id           VARCHAR2(255) := p_resp_id;
   l_security_group_id VARCHAR2(255) := p_security_group_id;
   l_org_id            VARCHAR2(255) := p_org_id;
   l_param             WF_PARAMETER_T;
   l_rang              NUMBER;
 BEGIN
   l_rang :=  0;

   IF l_user_id IS NULL THEN
     l_user_id := fnd_profile.value( 'USER_ID');
   END IF;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'USER_ID' );
   l_param.SetValue( l_user_id);
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   IF l_resp_id IS NULL THEN
      l_resp_id := fnd_profile.value( 'RESP_ID');
   END IF;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'RESP_ID' );
   l_param.SetValue( l_resp_id );
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   IF l_resp_appl_id IS NULL THEN
      l_resp_appl_id := fnd_profile.value( 'RESP_APPL_ID');
   END IF;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'RESP_APPL_ID' );
   l_param.SetValue( l_resp_appl_id );
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   IF  l_security_group_id IS NULL THEN
       l_security_group_id := fnd_profile.value( 'SECURITY_GROUP_ID');
   END IF;
   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'SECURITY_GROUP_ID' );
   l_param.SetValue( l_security_group_id );
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   IF l_org_id IS NULL THEN
      l_org_id :=  fnd_profile.value( 'ORG_ID');
   END IF;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'ORG_ID' );
   l_param.SetValue(l_org_id );
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

 END AddParamEnvToList;

 PROCEDURE Raise_Event
 ----------------------------------------------
 -- Check if Event exist
 -- Get the item_key
 -- Raise event
 ----------------------------------------------
 (p_event_name          IN   VARCHAR2,
  p_event_key           IN   VARCHAR2,
  p_data                IN   CLOB DEFAULT NULL,
  p_parameters          IN   wf_parameter_list_t DEFAULT NULL)
 IS
  l_item_key      VARCHAR2(240);
  l_event         VARCHAR2(240);
  EventNotFound   EXCEPTION;
  EventNotPV      EXCEPTION;
 BEGIN

  SAVEPOINT pv_raise_event;

--  IF SUBSTR(l_event,1,15) <> 'oracle.apps.pv.' THEN
--    RAISE EventNotPV;
--  END IF;

  l_event := Check_Event(p_event_name);

  IF l_event = 'NOTFOUND' THEN
    RAISE EventNotFound;
  END IF;

  Wf_Event.Raise
  ( p_event_name   =>  l_event,
    p_event_key    =>  p_event_key,
    p_parameters   =>  p_parameters,
    p_event_data   =>  p_data);

  EXCEPTION
    WHEN EventNotFound THEN
        FND_MESSAGE.SET_NAME( 'PV', 'PV_DEBUG_MESSAGE');
        FND_MESSAGE.SET_TOKEN( 'TEXT',p_event_name || ' Event not found' );
        FND_MSG_PUB.ADD;

    WHEN EventNotPV    THEN
        FND_MESSAGE.SET_NAME( 'PV', 'PV_DEBUG_MESSAGE');
        FND_MESSAGE.SET_TOKEN( 'EVENT' ,p_event_name || ' is not a PRM event' );
        FND_MSG_PUB.ADD;

    WHEN OTHERS        THEN
        ROLLBACK TO pv_raise_event;

        FND_MESSAGE.SET_NAME( 'PV', 'PV_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR',SQLERRM );
        FND_MSG_PUB.ADD;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END Raise_Event;


END pvx_event_pkg;

/
