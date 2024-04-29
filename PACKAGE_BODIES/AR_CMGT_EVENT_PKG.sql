--------------------------------------------------------
--  DDL for Package Body AR_CMGT_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_EVENT_PKG" AS
/*$Header: ARCMBEVB.pls 120.0.12010000.2 2009/12/28 21:33:47 mraymond ship $ */

 FUNCTION exist_subscription(p_event_name IN VARCHAR2) RETURN VARCHAR2
 IS
  CURSOR cu0 IS
   SELECT 'Y'
     FROM wf_events              eve,
          wf_event_subscriptions sub
    WHERE eve.name   = p_event_name
      AND eve.status = 'ENABLED'
      AND eve.guid   = sub.event_filter_guid
      AND sub.status = 'ENABLED'
      AND sub.source_type = 'LOCAL';
  l_yn  VARCHAR2(1);
 BEGIN
  OPEN cu0;
   FETCH cu0 INTO l_yn;
   IF cu0%NOTFOUND THEN
      l_yn := 'N';
   END IF;
  CLOSE cu0;
  RETURN l_yn;
 END;

 FUNCTION item_key(p_event_name  IN VARCHAR2,
                   p_unique_identifier  NUMBER) RETURN VARCHAR2
 IS
  RetKey VARCHAR2(240);
 BEGIN
   RetKey := p_event_name||'_'||to_char(p_unique_identifier)||'_'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS');
 Return RetKey;
 END item_key;


 FUNCTION event(p_event_name IN VARCHAR2) RETURN VARCHAR2
 -----------------------------------------------
 -- Return event name if the entered event exist
 -- Otherwise return NOTFOUND
 -----------------------------------------------
 IS
  RetEvent VARCHAR2(240);
  CURSOR get_event IS
   SELECT name
     FROM wf_events
    WHERE name = p_event_name;
 BEGIN
   OPEN get_event;

   FETCH get_event INTO RetEvent;
    IF get_event%NOTFOUND THEN
     RetEvent := 'NOTFOUND';
    END IF;
   CLOSE get_event;

   RETURN RetEvent;
 END event;

/*
FUNCTION org_id RETURN NUMBER
--------------------------------------------
-- Return the org_id for the current session
--------------------------------------------
IS
res  NUMBER;
BEGIN
 IF SUBSTRB( USERENV('CLIENT_INFO'),1,1) <> ' ' THEN
   res := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10));
 ELSE
   res := NULL;
 END IF;
 RETURN res;
END;
*/

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

   /* 9216062 - Use correct profile option name! */
   IF  l_security_group_id IS NULL THEN
       l_security_group_id := fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL');
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

END;


 PROCEDURE raise_event
 (p_event_name          IN   VARCHAR2,
  p_event_key           IN   VARCHAR2,
  p_data                IN   CLOB DEFAULT NULL,
  p_parameters          IN   wf_parameter_list_t DEFAULT NULL)
 IS
  l_item_key      VARCHAR2(240);
  l_event         VARCHAR2(240);
  EventNotFound   EXCEPTION;
  EventNotARCMGT  EXCEPTION;
 BEGIN

  SAVEPOINT ar_cmgt_raise_event;

  l_event := event(p_event_name);

  IF l_event = 'NOTFOUND' THEN
    RAISE EventNotFound;
  END IF;

  IF SUBSTRB(l_event,1,15) <> 'oracle.apps.ar.' THEN
    RAISE EventNotARCMGT;
  END IF;

  Wf_Event.Raise
  ( p_event_name   =>  l_event,
    p_event_key    =>  p_event_key,
    p_parameters   =>  p_parameters,
    p_event_data   =>  p_data);


  EXCEPTION
    WHEN EventNotFound THEN

        FND_MESSAGE.SET_NAME( 'AR', 'AR_EVENTNOTFOUND');
        FND_MESSAGE.SET_TOKEN( 'EVENT' ,p_event_name );
        app_exception.raise_exception;

    WHEN EventNotARCMGT    THEN
        FND_MESSAGE.SET_NAME( 'AR', 'AR_EVENTNOTAR');
        FND_MESSAGE.SET_TOKEN( 'EVENT' ,p_event_name );
        app_exception.raise_exception;

    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO ar_cmgt_raise_event;

        FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        app_exception.raise_exception;


    WHEN OTHERS        THEN
        ROLLBACK TO ar_cmgt_raise_event;

        FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        app_exception.raise_exception;



  END raise_event;


END;

/
