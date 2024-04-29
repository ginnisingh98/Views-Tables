--------------------------------------------------------
--  DDL for Package Body JTF_NOTES_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_NOTES_EVENTS_PVT" AS
/* $Header: jtfntbeb.pls 115.3 2003/10/24 00:43:18 hbouten noship $ */


  FUNCTION getItemKey(p_EventName IN VARCHAR2)
  RETURN VARCHAR2
  IS
    l_key varchar2(240);
  BEGIN
  	SELECT p_EventName ||'-'|| jtf_notes_wf_events_s.NEXTVAL INTO l_key FROM DUAL;
	RETURN l_key;
  END getItemKey;


  PROCEDURE RaiseCreateNote
  ( p_NoteID            IN   NUMBER
  , p_SourceObjectCode  IN   VARCHAR2
  , p_SourceObjectID    IN   VARCHAR2
  )
  IS
   l_ParameterList      WF_PARAMETER_LIST_T;
   l_ItemKey            VARCHAR2(240);
   l_EventName          VARCHAR2(240) := 'oracle.apps.jtf.cac.notes.create';

  BEGIN
    --
    -- Get the item key
    --
    l_ItemKey := getItemKey(l_EventName);

    --
    -- construct the parameter list
    --
    WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'NOTE_ID'
                               , p_value         => TO_CHAR(p_NoteID)
                               , p_parameterlist => l_ParameterList
                               );


    WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SOURCE_OBJECT_CODE'
                               , p_value         => p_SourceObjectCode
                               , p_parameterlist => l_ParameterList
                               );

    WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SOURCE_OBJECT_ID'
                               , p_value         => p_SourceObjectID
                               , p_parameterlist => l_ParameterList
                               );
    --
    -- Raise the event
    --
    WF_EVENT.RAISE3( p_event_name     => 'oracle.apps.jtf.cac.notes.create'
                   , p_event_key      => l_ItemKey
                   , p_event_data     => NULL
                   , p_parameter_list => l_ParameterList
                   , p_send_date      => SYSDATE
                   );

    --
    -- Clean up parameter list
    --
    l_ParameterList.DELETE;


  END RaiseCreateNote;


  PROCEDURE RaiseUpdateNote
  ( p_NoteID            IN   NUMBER
  , p_SourceObjectCode  IN   VARCHAR2
  , p_SourceObjectID    IN   VARCHAR2
  )
  IS
   l_ParameterList      WF_PARAMETER_LIST_T;
   l_ItemKey            VARCHAR2(240);
   l_EventName          VARCHAR2(240) := 'oracle.apps.jtf.cac.notes.update';

  BEGIN
    --
    -- Get the item key
    --
    l_ItemKey := getItemKey(l_EventName);

    --
    -- construct the parameter list
    --
    WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'NOTE_ID'
                               , p_value         => p_NoteID
                               , p_parameterlist => l_ParameterList
                               );


    WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SOURCE_OBJECT_CODE'
                               , p_value         => p_SourceObjectCode
                               , p_parameterlist => l_ParameterList
                               );

    WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SOURCE_OBJECT_ID'
                               , p_value         => p_SourceObjectID
                               , p_parameterlist  => l_ParameterList
                               );
    --
    -- Raise the event
    --
    WF_EVENT.RAISE3( p_event_name     => 'oracle.apps.jtf.cac.notes.update'
                   , p_event_key      => l_ItemKey
                   , p_event_data     => NULL
                   , p_parameter_list => l_ParameterList
                   , p_send_date      => SYSDATE
                   );

    --
    -- Clean up parameter list
    --
    l_ParameterList.DELETE;


  END RaiseUpdateNote;

  PROCEDURE RaiseDeleteNote
  ( p_NoteID            IN   NUMBER
  , p_SourceObjectCode  IN   VARCHAR2
  , p_SourceObjectID    IN   VARCHAR2
  )
  IS
   l_ParameterList      WF_PARAMETER_LIST_T;
   l_ItemKey            VARCHAR2(240);
   l_EventName          VARCHAR2(240) := 'oracle.apps.jtf.cac.notes.delete';

  BEGIN
    --
    -- Get the item key
    --
    l_ItemKey := getItemKey(l_EventName);

    --
    -- construct the parameter list
    --
    WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'NOTE_ID'
                               , p_value         => p_NoteID
                               , p_parameterlist => l_ParameterList
                               );


    WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SOURCE_OBJECT_CODE'
                               , p_value         => p_SourceObjectCode
                               , p_parameterlist => l_ParameterList
                               );

    WF_EVENT.ADDPARAMETERTOLIST( p_name          => 'SOURCE_OBJECT_ID'
                               , p_value         => p_SourceObjectID
                               , p_parameterlist => l_ParameterList
                               );
    --
    -- Raise the event
    --
    WF_EVENT.RAISE3( p_event_name     => 'oracle.apps.jtf.cac.notes.delete'
                   , p_event_key      => l_ItemKey
                   , p_event_data     => NULL
                   , p_parameter_list => l_ParameterList
                   , p_send_date      => SYSDATE
                   );

    --
    -- Clean up parameter list
    --
    l_ParameterList.DELETE;

  END RaiseDeleteNote;



END JTF_NOTES_EVENTS_PVT; -- end package body JTF_NOTES_EVENTS_PVT

/
