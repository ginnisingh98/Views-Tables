--------------------------------------------------------
--  DDL for Package Body CAC_AVLBLTY_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_AVLBLTY_EVENTS_PVT" AS
/* $Header: caccabeb.pls 120.1 2005/07/02 02:17:31 appldev noship $ */


/*******************************************************************************
** Private APIs
*******************************************************************************/


FUNCTION getItemKey(p_EventName IN VARCHAR2)
RETURN VARCHAR2
IS
  l_key varchar2(240);
BEGIN
  SELECT p_EventName ||'-'|| cac_sr_wf_events_s.NEXTVAL INTO l_key FROM DUAL;
  RETURN l_key;
END getItemKey;


PROCEDURE RAISE_CREATE_SCHEDULE
/*******************************************************************************
**
** RAISE_CREATE_SCHEDULE
**
**   Raise business event
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Category    IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
)
IS

 l_ParameterList      WF_PARAMETER_LIST_T;
 l_ItemKey            VARCHAR2(240);
 l_EventName          VARCHAR2(240);

BEGIN

  l_EventName := 'oracle.apps.jtf.cac.scheduleRep.createSchedule';

  --
  -- Get the item key
  --
  l_ItemKey := getItemKey(l_EventName);

  --
  -- construct the parameter list
  --
  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_ID'
                             , p_value         => TO_CHAR(p_Schedule_Id)
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_CATEGORY'
                             , p_value         => p_Schedule_Category
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_START_DATE'
                             , p_value         => TO_CHAR(p_Schdl_Start_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_END_DATE'
                             , p_value         => TO_CHAR(p_Schdl_End_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );
  --
  -- Raise the event
  --
  WF_EVENT.RAISE3( p_event_name     => l_EventName
                 , p_event_key      => l_ItemKey
                 , p_event_data     => NULL
                 , p_parameter_list => l_ParameterList
                 , p_send_date      => SYSDATE
                 );

  --
  -- Clean up parameter list
  --
  l_ParameterList.DELETE;

END RAISE_CREATE_SCHEDULE;


PROCEDURE RAISE_UPDATE_SCHEDULE
/*******************************************************************************
**
** RAISE_UPDATE_SCHEDULE
**
**   Raise business event
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Category    IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
)
IS

 l_ParameterList      WF_PARAMETER_LIST_T;
 l_ItemKey            VARCHAR2(240);
 l_EventName          VARCHAR2(240);

BEGIN

  l_EventName := 'oracle.apps.jtf.cac.scheduleRep.updateSchedule';

  --
  -- Get the item key
  --
  l_ItemKey := getItemKey(l_EventName);

  --
  -- construct the parameter list
  --
  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_ID'
                             , p_value         => TO_CHAR(p_Schedule_Id)
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_CATEGORY'
                             , p_value         => p_Schedule_Category
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_START_DATE'
                             , p_value         => TO_CHAR(p_Schdl_Start_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_END_DATE'
                             , p_value         => TO_CHAR(p_Schdl_End_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );
  --
  -- Raise the event
  --
  WF_EVENT.RAISE3( p_event_name     => l_EventName
                 , p_event_key      => l_ItemKey
                 , p_event_data     => NULL
                 , p_parameter_list => l_ParameterList
                 , p_send_date      => SYSDATE
                 );

  --
  -- Clean up parameter list
  --
  l_ParameterList.DELETE;

END RAISE_UPDATE_SCHEDULE;


PROCEDURE RAISE_DELETE_SCHEDULE
/*******************************************************************************
**
** RAISE_DELETE_SCHEDULE
**
**   Raise business event
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Category    IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
)
IS

 l_ParameterList      WF_PARAMETER_LIST_T;
 l_ItemKey            VARCHAR2(240);
 l_EventName          VARCHAR2(240);

BEGIN

  l_EventName := 'oracle.apps.jtf.cac.scheduleRep.deleteSchedule';

  --
  -- Get the item key
  --
  l_ItemKey := getItemKey(l_EventName);

  --
  -- construct the parameter list
  --
  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_ID'
                             , p_value         => TO_CHAR(p_Schedule_Id)
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_CATEGORY'
                             , p_value         => p_Schedule_Category
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_START_DATE'
                             , p_value         => TO_CHAR(p_Schdl_Start_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_END_DATE'
                             , p_value         => TO_CHAR(p_Schdl_End_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );
  --
  -- Raise the event
  --
  WF_EVENT.RAISE3( p_event_name     => l_EventName
                 , p_event_key      => l_ItemKey
                 , p_event_data     => NULL
                 , p_parameter_list => l_ParameterList
                 , p_send_date      => SYSDATE
                 );

  --
  -- Clean up parameter list
  --
  l_ParameterList.DELETE;

END RAISE_DELETE_SCHEDULE;


PROCEDURE RAISE_ADD_RESOURCE
/*******************************************************************************
**
** RAISE_ADD_RESOURCE
**
**   Raise business event
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Category    IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
, p_Object_Type          IN     VARCHAR2
, p_Object_Id            IN     NUMBER
, p_Object_Start_Date    IN     DATE
, p_Object_End_Date      IN     DATE
)
IS

 l_ParameterList      WF_PARAMETER_LIST_T;
 l_ItemKey            VARCHAR2(240);
 l_EventName          VARCHAR2(240);

BEGIN

  l_EventName := 'oracle.apps.jtf.cac.scheduleRep.addResource';

  --
  -- Get the item key
  --
  l_ItemKey := getItemKey(l_EventName);

  --
  -- construct the parameter list
  --
  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_ID'
                             , p_value         => TO_CHAR(p_Schedule_Id)
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_CATEGORY'
                             , p_value         => p_Schedule_Category
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_START_DATE'
                             , p_value         => TO_CHAR(p_Schdl_Start_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_END_DATE'
                             , p_value         => TO_CHAR(p_Schdl_End_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );
  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'OBJECT_ID'
                             , p_value         => TO_CHAR(p_Object_Id)
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'OBJECT_CODE'
                             , p_value         => p_Object_Type
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'OBJECT_START_DATE'
                             , p_value         => TO_CHAR(p_Object_Start_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'OBJECT_END_DATE'
                             , p_value         => TO_CHAR(p_Object_End_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );
  --
  -- Raise the event
  --
  WF_EVENT.RAISE3( p_event_name     => l_EventName
                 , p_event_key      => l_ItemKey
                 , p_event_data     => NULL
                 , p_parameter_list => l_ParameterList
                 , p_send_date      => SYSDATE
                 );

  --
  -- Clean up parameter list
  --
  l_ParameterList.DELETE;

END RAISE_ADD_RESOURCE;


PROCEDURE RAISE_UPDATE_RESOURCE
/*******************************************************************************
**
** RAISE_UPDATE_RESOURCE
**
**   Raise business event
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Category    IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
, p_Object_Type          IN     VARCHAR2
, p_Object_Id            IN     NUMBER
, p_Object_Start_Date    IN     DATE
, p_Object_End_Date      IN     DATE
)
IS

 l_ParameterList      WF_PARAMETER_LIST_T;
 l_ItemKey            VARCHAR2(240);
 l_EventName          VARCHAR2(240);

BEGIN

  l_EventName := 'oracle.apps.jtf.cac.scheduleRep.updateResource';

  --
  -- Get the item key
  --
  l_ItemKey := getItemKey(l_EventName);

  --
  -- construct the parameter list
  --
  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_ID'
                             , p_value         => TO_CHAR(p_Schedule_Id)
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_CATEGORY'
                             , p_value         => p_Schedule_Category
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_START_DATE'
                             , p_value         => TO_CHAR(p_Schdl_Start_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_END_DATE'
                             , p_value         => TO_CHAR(p_Schdl_End_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );
  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'OBJECT_ID'
                             , p_value         => TO_CHAR(p_Object_Id)
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'OBJECT_CODE'
                             , p_value         => p_Object_Type
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'OBJECT_START_DATE'
                             , p_value         => TO_CHAR(p_Object_Start_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'OBJECT_END_DATE'
                             , p_value         => TO_CHAR(p_Object_End_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );
  --
  -- Raise the event
  --
  WF_EVENT.RAISE3( p_event_name     => l_EventName
                 , p_event_key      => l_ItemKey
                 , p_event_data     => NULL
                 , p_parameter_list => l_ParameterList
                 , p_send_date      => SYSDATE
                 );

  --
  -- Clean up parameter list
  --
  l_ParameterList.DELETE;

END RAISE_UPDATE_RESOURCE;


PROCEDURE RAISE_REMOVE_RESOURCE
/*******************************************************************************
**
** RAISE_REMOVE_RESOURCE
**
**   Raise business event
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Category    IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
, p_Object_Type          IN     VARCHAR2
, p_Object_Id            IN     NUMBER
, p_Object_Start_Date    IN     DATE
, p_Object_End_Date      IN     DATE
)
IS

 l_ParameterList      WF_PARAMETER_LIST_T;
 l_ItemKey            VARCHAR2(240);
 l_EventName          VARCHAR2(240);

BEGIN

  l_EventName := 'oracle.apps.jtf.cac.scheduleRep.removeResource';

  --
  -- Get the item key
  --
  l_ItemKey := getItemKey(l_EventName);

  --
  -- construct the parameter list
  --
  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_ID'
                             , p_value         => TO_CHAR(p_Schedule_Id)
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_CATEGORY'
                             , p_value         => p_Schedule_Category
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_START_DATE'
                             , p_value         => TO_CHAR(p_Schdl_Start_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SCHEDULE_END_DATE'
                             , p_value         => TO_CHAR(p_Schdl_End_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );
  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'OBJECT_ID'
                             , p_value         => TO_CHAR(p_Object_Id)
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'OBJECT_CODE'
                             , p_value         => p_Object_Type
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'OBJECT_START_DATE'
                             , p_value         => TO_CHAR(p_Object_Start_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );

  WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'OBJECT_END_DATE'
                             , p_value         => TO_CHAR(p_Object_End_Date,'MM/DD/YYYY')
                             , p_parameterlist => l_ParameterList
                             );
  --
  -- Raise the event
  --
  WF_EVENT.RAISE3( p_event_name     => l_EventName
                 , p_event_key      => l_ItemKey
                 , p_event_data     => NULL
                 , p_parameter_list => l_ParameterList
                 , p_send_date      => SYSDATE
                 );

  --
  -- Clean up parameter list
  --
  l_ParameterList.DELETE;

END RAISE_REMOVE_RESOURCE;


END CAC_AVLBLTY_EVENTS_PVT;

/
