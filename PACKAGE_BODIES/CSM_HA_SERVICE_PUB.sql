--------------------------------------------------------
--  DDL for Package Body CSM_HA_SERVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_HA_SERVICE_PUB" AS
/* $Header: csmhsrvb.pls 120.0.12010000.1 2010/04/08 06:39:15 saradhak noship $*/

Function GET_HA_STATUS return VARCHAR2
IS
BEGIN
 return NVL(CSM_HA_EVENT_PKG.GET_HA_PROFILE_VALUE,'HA_STOP');
END GET_HA_STATUS;

/*
For all "enabled" checks,
If profile value=HA_RECORD , return value of ENABLED_ON_RECORD column
If profile value=HA_APPLY , return value of ENABLED_ON_APPLY column
If profile value=HA_STOP , return NULL - for no information
*/

Function IS_WF_ITEM_TYPE_ENABLED( p_item_type IN VARCHAR2) return VARCHAR2
IS
CURSOR c_status IS
 SELECT DECODE(CSM_HA_SERVICE_PUB.GET_HA_STATUS,
              'HA_RECORD',ENABLED_ON_RECORD,
              'HA_APPLY',ENABLED_ON_APPLY)
 FROM CSM_HA_ACTIVE_WF_COMPONENTS
 WHERE WF_ITEM_TYPE=p_item_type;

 l_status VARCHAR2(1);
BEGIN

  OPEN c_status;
  FETCH c_status INTO l_status;
  CLOSE c_status;

  return l_status;

END IS_WF_ITEM_TYPE_ENABLED;

Function IS_WF_EVENT_ENABLED( p_event_name  IN VARCHAR2) return VARCHAR2
IS
CURSOR c_status IS
 SELECT DECODE(CSM_HA_SERVICE_PUB.GET_HA_STATUS,
              'HA_RECORD',ENABLED_ON_RECORD,
              'HA_APPLY',ENABLED_ON_APPLY)
 FROM CSM_HA_ACTIVE_WF_COMPONENTS
 WHERE WF_EVENT_NAME=p_event_name
 AND  WF_EVENT_SUBSCRIPTION_GUID IS NULL;

 l_status VARCHAR2(1);
BEGIN

  OPEN c_status;
  FETCH c_status INTO l_status;
  CLOSE c_status;

  return l_status;

END IS_WF_EVENT_ENABLED;

Function IS_WF_BES_ENABLED(p_sub_guid IN RAW) return VARCHAR2
IS
CURSOR c_status IS
 SELECT DECODE(CSM_HA_SERVICE_PUB.GET_HA_STATUS,
              'HA_RECORD',ENABLED_ON_RECORD,
              'HA_APPLY',ENABLED_ON_APPLY)
 FROM CSM_HA_ACTIVE_WF_COMPONENTS
 WHERE  WF_EVENT_NAME IS NOT NULL
 AND WF_EVENT_SUBSCRIPTION_GUID =p_sub_guid;

 l_status VARCHAR2(1);
BEGIN

  OPEN c_status;
  FETCH c_status INTO l_status;
  CLOSE c_status;

  return l_status;
END IS_WF_BES_ENABLED;

END CSM_HA_SERVICE_PUB;


/
