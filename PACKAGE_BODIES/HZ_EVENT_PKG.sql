--------------------------------------------------------
--  DDL for Package Body HZ_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EVENT_PKG" AS
/*$Header: ARHEVESB.pls 120.7 2005/05/25 15:37:31 rborah noship $ */
 --------------------------------------
 -- package global variable declaration
 --------------------------------------
 G_DEBUG_COUNT       NUMBER  := 0;
 --G_DEBUG             BOOLEAN := FALSE;

 ------------------------------------
 -- declaration of private procedures
 ------------------------------------
 /*PROCEDURE enable_debug;

 PROCEDURE disable_debug;
 */

 ------------------------------------------
 -- PRIVATE PROCEDURE enable_debug
 -- DESCRIPTION
 --     Turn on debug mode.
 -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 --     HZ_UTILITY_V2PUB.enable_debug
 -- MODIFICATION HISTORY
 --   07-31-2001    H. YU      o Created.
 ------------------------------------------
 /*PROCEDURE enable_debug IS
 BEGIN
    G_DEBUG_COUNT := G_DEBUG_COUNT + 1;
    IF G_DEBUG_COUNT = 1 THEN
        IF FND_PROFILE.value( 'HZ_API_FILE_DEBUG_ON' ) = 'Y' OR
           FND_PROFILE.value( 'HZ_API_DBMS_DEBUG_ON' ) = 'Y'
        THEN
           HZ_UTILITY_V2PUB.enable_debug;
           G_DEBUG := TRUE;
        END IF;
    END IF;
 END enable_debug;
 */


 --------------------------------------------
 -- PRIVATE PROCEDURE disable_debug
 -- DESCRIPTION
 --     Turn off debug mode.
 -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 --     HZ_UTILITY_V2PUB.disable_debug
 -- MODIFICATION HISTORY
 --   07-31-2001    H. YU      o Created.
 --------------------------------------------
 /*PROCEDURE disable_debug IS
 BEGIN
    IF G_DEBUG THEN
        G_DEBUG_COUNT := G_DEBUG_COUNT - 1;
        IF G_DEBUG_COUNT = 0 THEN
            HZ_UTILITY_V2PUB.disable_debug;
            G_DEBUG := FALSE;
        END IF;
    END IF;
 END disable_debug;
 */


 FUNCTION exist_subscription(p_event_name IN VARCHAR2) RETURN VARCHAR2
 -----------------------------------------------------------------------
 -- Return 'Y' if the subscription hz_event_elt.hz_param_delete exist
 -- Otherwise it returns 'N'
 -----------------------------------------------------------------------
 IS
-- Bug 3784725 : Modify the cursor so that it can use index
--		 WF_EVENT_SUBSCRIPTIONS_N1 defined on
--		 table wf_event_subscriptions for better performance.
  CURSOR cu0 IS
   SELECT 'Y'
     FROM wf_events              eve,
          wf_event_subscriptions sub,
	  wf_systems ws
    WHERE eve.name   = p_event_name
      AND eve.status = 'ENABLED'
      AND eve.guid   = sub.event_filter_guid
      AND UPPER(sub.rule_function) = 'HZ_EVENT_ELT.HZ_PARAM_DELETE'
      AND sub.status = 'ENABLED'
      AND ws.GUID = sub.SYSTEM_GUID
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

 FUNCTION item_key(p_event_name  IN VARCHAR2) RETURN VARCHAR2
 -----------------------------------------------------
 -- Return Item_Key according to Hz Event to be raised
 -- Item_Key is <Event_Name>-hzwfapp_s.nextval
 -----------------------------------------------------
 IS
  RetKey VARCHAR2(240);
 BEGIN
  SELECT p_event_name || hz_wf_items_s.nextval INTO RetKey FROM DUAL;
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
   SELECT name INTO RetEvent
     FROM wf_events
    WHERE name = p_event_name;
   IF SQL%NOTFOUND THEN
     RetEvent := 'NOTFOUND';
   END IF;
   RETURN RetEvent;
 END event;


/*
* TCA SSA Uptake (Bug 3456489)
*
*FUNCTION org_id RETURN NUMBER
*--------------------------------------------
*-- Return the org_id for the current session
*--------------------------------------------
*IS
*res  NUMBER;
*BEGIN
* IF SUBSTRB( USERENV('CLIENT_INFO'),1,1) <> ' ' THEN
*   res := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10));
* ELSE
*   res := NULL;
* END IF;
* RETURN res;
*END;
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
     -- Fix bug 4271565, use FND_GLOBAL
     --l_user_id := fnd_profile.value( 'USER_ID');
     l_user_id := FND_GLOBAL.USER_ID;
   END IF;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'USER_ID' );
   l_param.SetValue( l_user_id);
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   IF l_resp_id IS NULL THEN
     -- Fix bug 4271565, use FND_GLOBAL
     --l_resp_id := fnd_profile.value( 'RESP_ID');
      l_resp_id := FND_GLOBAL.RESP_ID;
   END IF;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'RESP_ID' );
   l_param.SetValue( l_resp_id );
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   IF l_resp_appl_id IS NULL THEN
     -- Fix bug 4271565, use FND_GLOBAL
     -- l_resp_appl_id := fnd_profile.value( 'RESP_APPL_ID');
      l_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;
   END IF;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'RESP_APPL_ID' );
   l_param.SetValue( l_resp_appl_id );
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   IF  l_security_group_id IS NULL THEN
       --l_security_group_id := fnd_profile.value( 'SECURITY_GROUP_ID');
       /* BugNo: 3007012 */
       l_security_group_id := fnd_global.security_group_id;
   END IF;
   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'SECURITY_GROUP_ID' );
   l_param.SetValue( l_security_group_id );
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

  /* 3456489. Removed check for null org_id. */
   IF (l_org_id IS NOT NULL) THEN
   	l_param := WF_PARAMETER_T( NULL, NULL );
   	-- fill the parameters list
   	x_list.extend;
   	l_param.SetName( 'ORG_ID' );
   	l_param.SetValue(l_org_id );
   	l_rang  := l_rang + 1;
   	x_list(l_rang) := l_param;
   END IF;


END;


 PROCEDURE raise_event
 ----------------------------------------------
 -- Check if Event exist
 -- Check if Event is like 'oracle.apps.ar.hz%'
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
  EventNotHZ      EXCEPTION;
  l_debug_prefix  VARCHAR2(30) := '';
 BEGIN

  SAVEPOINT hz_raise_event;

  --enable_debug;

  l_event := event(p_event_name);

  IF l_event = 'NOTFOUND' THEN
    RAISE EventNotFound;
  END IF;

  IF SUBSTR(l_event,1,18) <> 'oracle.apps.ar.hz.' THEN
    RAISE EventNotHZ;
  END IF;

  Wf_Event.Raise
  ( p_event_name   =>  l_event,
    p_event_key    =>  p_event_key,
    p_parameters   =>  p_parameters,
    p_event_data   =>  p_data);

  --disable_debug;

  EXCEPTION
    WHEN EventNotFound THEN

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_EVENTNOTFOUND');
        FND_MESSAGE.SET_TOKEN( 'EVENT' ,p_event_name );
        FND_MSG_PUB.ADD;

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'Tca event raise (-).  Warning hz_event_pkg :EventNotFound - '||p_event_name ||' not found.',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN EventNotHZ    THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_EVENTNOTTCA');
        FND_MESSAGE.SET_TOKEN( 'EVENT' ,p_event_name );
        FND_MSG_PUB.ADD;

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>' Tca event raise  (-).  Warning hz_event_pkg:EventNotHZ - '||p_event_name ||' isnot TCA event.',
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO hz_raise_event;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'Tca event raise (-). Error hz_event_pkg:No_DaTa_Found '||TO_CHAR(SQLCODE)||': '||SQLERRM,
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS        THEN
        ROLLBACK TO hz_raise_event;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'Tca event raise (-). Error hz_event_pkg:OTHERS'||TO_CHAR(SQLCODE)||': '||SQLERRM,
	                           p_prefix=>'SQL ERROR',
			           p_msg_level=>fnd_log.level_error);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


  END raise_event;


END;

/
